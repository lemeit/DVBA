-- ETAPA 1 / CANDIDATA LOCAL. No desplegar sin integrar clientes y validar en staging.
-- Requiere el esquema auditado 2026-10-19 (SQL_0..34); NO es un esquema inicial.
BEGIN;
REVOKE CREATE ON SCHEMA public FROM PUBLIC,anon,authenticated;
CREATE SCHEMA IF NOT EXISTS dvba_privado;
REVOKE ALL ON SCHEMA dvba_privado FROM PUBLIC, anon, authenticated;
GRANT USAGE ON SCHEMA dvba_privado TO authenticated;

ALTER TABLE public.usuarios_perfil
  ADD COLUMN area_codigo text NOT NULL DEFAULT 'vialidad',
  ADD COLUMN contexto_captura text NOT NULL DEFAULT 'zonal',
  ADD COLUMN alcance_lectura text,
  ADD COLUMN alcance_captura text,
  ADD COLUMN permisos_version bigint NOT NULL DEFAULT 1;
UPDATE public.usuarios_perfil SET
  alcance_lectura = CASE WHEN rol IN ('admin','gerencia') THEN 'provincial_operativo'
    WHEN rol='capataz' THEN 'tareas_asignadas' WHEN rol='publico' THEN 'ninguna' ELSE 'zonal' END,
  alcance_captura = CASE WHEN rol='admin' THEN 'provincial'
    WHEN rol IN ('tecnico','jefe_zona','jefe_tecnica','jefe_operativa') THEN 'zonal' ELSE 'ninguna' END;
ALTER TABLE public.usuarios_perfil
  ALTER COLUMN alcance_lectura SET NOT NULL,
  ALTER COLUMN alcance_captura SET NOT NULL,
  DROP CONSTRAINT IF EXISTS chk_zona_operativo_obligatoria,
  ADD CONSTRAINT dvba_perfil_config CHECK (
    (area_codigo='ambiente' AND rol='tecnico' AND contexto_captura='ambiente'
      AND alcance_lectura='propios' AND alcance_captura='provincial') OR
    (area_codigo='vialidad' AND contexto_captura='zonal' AND (
      (rol='admin' AND alcance_lectura='provincial_operativo' AND alcance_captura='provincial') OR
      (rol='gerencia' AND alcance_lectura='provincial_operativo' AND alcance_captura='ninguna') OR
      (rol='tecnico' AND zona IS NOT NULL AND alcance_lectura='zonal' AND alcance_captura IN ('zonal','provincial')) OR
      (rol IN ('jefe_zona','jefe_tecnica','jefe_operativa') AND zona IS NOT NULL AND alcance_lectura='zonal' AND alcance_captura='zonal') OR
      (rol IN ('jefe_administrativa','jefe_automotores') AND zona IS NOT NULL AND alcance_lectura='zonal' AND alcance_captura='ninguna') OR
      (rol='capataz' AND zona IS NOT NULL AND alcance_lectura='tareas_asignadas' AND alcance_captura='ninguna') OR
      (rol='publico' AND alcance_lectura='ninguna' AND alcance_captura='ninguna')
    ))),
  ADD CONSTRAINT dvba_perfil_zona CHECK (zona IS NULL OR zona IN ('I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII'));

CREATE TABLE dvba_privado.auditoria (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  actor_id uuid, fecha timestamptz NOT NULL DEFAULT clock_timestamp(),
  tabla text NOT NULL, accion text NOT NULL, clave text NOT NULL,
  anterior jsonb, nuevo jsonb
);
ALTER TABLE dvba_privado.auditoria ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON dvba_privado.auditoria FROM PUBLIC, anon, authenticated;

CREATE FUNCTION dvba_privado.perfil() RETURNS public.usuarios_perfil
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT p FROM public.usuarios_perfil p WHERE p.user_id=auth.uid() AND p.activo
$$;
CREATE FUNCTION dvba_privado.activo() RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT EXISTS(SELECT 1 FROM public.usuarios_perfil WHERE user_id=auth.uid() AND activo AND rol<>'publico')
$$;
CREATE FUNCTION dvba_privado.admin() RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT EXISTS(SELECT 1 FROM public.usuarios_perfil WHERE user_id=auth.uid() AND activo AND rol='admin')
$$;
CREATE OR REPLACE FUNCTION public.current_user_rol() RETURNS text
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT rol FROM public.usuarios_perfil WHERE user_id=auth.uid() AND activo
$$;
CREATE OR REPLACE FUNCTION public.current_user_zona() RETURNS text
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT zona FROM public.usuarios_perfil WHERE user_id=auth.uid() AND activo AND area_codigo='vialidad'
$$;

-- Reemplazar completamente las policies de perfiles; ninguna autoprovisión.
DO $$ DECLARE p record; BEGIN
  FOR p IN SELECT policyname FROM pg_policies WHERE schemaname='public' AND tablename='usuarios_perfil' LOOP
    EXECUTE format('DROP POLICY %I ON public.usuarios_perfil',p.policyname);
  END LOOP;
END $$;
REVOKE ALL ON public.usuarios_perfil FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON public.usuarios_perfil TO authenticated;
ALTER TABLE public.usuarios_perfil ENABLE ROW LEVEL SECURITY;
CREATE POLICY perfil_lectura ON public.usuarios_perfil FOR SELECT TO authenticated
  USING ((SELECT dvba_privado.admin()) OR (user_id=(SELECT auth.uid()) AND activo));
CREATE POLICY perfil_alta ON public.usuarios_perfil FOR INSERT TO authenticated WITH CHECK ((SELECT dvba_privado.admin()));
CREATE POLICY perfil_cambio ON public.usuarios_perfil FOR UPDATE TO authenticated
  USING ((SELECT dvba_privado.admin())) WITH CHECK ((SELECT dvba_privado.admin()));

CREATE FUNCTION dvba_privado.auditar() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
BEGIN
  INSERT INTO dvba_privado.auditoria(actor_id,tabla,accion,clave,anterior,nuevo)
    VALUES(auth.uid(),TG_TABLE_NAME,TG_OP,coalesce(to_jsonb(NEW)->>'id',to_jsonb(NEW)->>'user_id',to_jsonb(OLD)->>'id'),
      CASE WHEN TG_OP<>'INSERT' THEN to_jsonb(OLD) END,CASE WHEN TG_OP<>'DELETE' THEN to_jsonb(NEW) END);
  RETURN NULL;
END $$;
CREATE FUNCTION dvba_privado.version_perfil() RETURNS trigger
LANGUAGE plpgsql SET search_path='' AS $$
BEGIN
  IF NEW.user_id IS DISTINCT FROM OLD.user_id THEN RAISE EXCEPTION 'Identidad inmutable' USING ERRCODE='42501'; END IF;
  IF OLD.rol='admin' AND OLD.activo AND (NEW.rol IS DISTINCT FROM 'admin' OR NOT NEW.activo) THEN
    PERFORM pg_catalog.pg_advisory_xact_lock(742013);
    IF NOT EXISTS(SELECT 1 FROM public.usuarios_perfil p WHERE p.rol='admin' AND p.activo AND p.user_id<>OLD.user_id) THEN
      RAISE EXCEPTION 'Debe conservar al menos un administrador activo' USING ERRCODE='23514';
    END IF;
  END IF;
  NEW.permisos_version := OLD.permisos_version+1;
  RETURN NEW;
END $$;
CREATE TRIGGER dvba_perfil_version BEFORE UPDATE ON public.usuarios_perfil
  FOR EACH ROW EXECUTE FUNCTION dvba_privado.version_perfil();
CREATE TRIGGER dvba_perfil_audit AFTER INSERT OR UPDATE OR DELETE ON public.usuarios_perfil
  FOR EACH ROW EXECUTE FUNCTION dvba_privado.auditar();

-- Campos nuevos: no se atribuye autoría ni se cambia ubicación de históricos.
ALTER TABLE public.relevamientos
  ADD COLUMN contexto_trabajo text NOT NULL DEFAULT 'zonal' CHECK (contexto_trabajo IN ('zonal','ambiente')),
  ADD COLUMN estado_registro text NOT NULL DEFAULT 'borrador' CHECK (estado_registro IN ('borrador','presentado','observado','cerrado','archivado')),
  ADD COLUMN captura_id uuid NOT NULL DEFAULT gen_random_uuid(),
  ADD COLUMN version bigint NOT NULL DEFAULT 1;
CREATE UNIQUE INDEX dvba_relev_captura ON public.relevamientos(captura_id);
CREATE INDEX dvba_relev_contexto_autor ON public.relevamientos(contexto_trabajo,autor_id);

CREATE TABLE public.relevamiento_zonas_compartidas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  relevamiento_id bigint NOT NULL REFERENCES public.relevamientos(id),
  zona_destino text NOT NULL CHECK (zona_destino IN ('I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII')),
  compartido_por uuid NOT NULL REFERENCES auth.users(id), compartido_en timestamptz NOT NULL DEFAULT now(),
  motivo text NOT NULL CHECK(length(trim(motivo))>=3),
  revocado_por uuid REFERENCES auth.users(id), revocado_en timestamptz,
  CHECK ((revocado_por IS NULL)=(revocado_en IS NULL))
);
CREATE UNIQUE INDEX dvba_compartido_activo ON public.relevamiento_zonas_compartidas(relevamiento_id,zona_destino) WHERE revocado_en IS NULL;
CREATE TABLE public.registro_fotos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  relevamiento_id bigint NOT NULL REFERENCES public.relevamientos(id),
  cargada_por uuid NOT NULL REFERENCES auth.users(id),
  bucket text NOT NULL DEFAULT 'ambiente_privado' CHECK(bucket='ambiente_privado'),
  object_path text NOT NULL UNIQUE, creada_en timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX dvba_registro_fotos_relev ON public.registro_fotos(relevamiento_id);
ALTER TABLE public.relevamiento_zonas_compartidas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registro_fotos ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.relevamiento_zonas_compartidas,public.registro_fotos FROM PUBLIC,anon,authenticated;
GRANT SELECT ON public.relevamiento_zonas_compartidas,public.registro_fotos TO authenticated;

CREATE FUNCTION dvba_privado.leer_fila_relevamiento(p_id bigint,p_autor uuid,p_contexto text,p_zona text,p_borrado timestamptz) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT EXISTS (
    SELECT 1 FROM dvba_privado.perfil() p
    WHERE p.user_id IS NOT NULL AND p.rol<>'publico' AND (
      p.rol='admin' OR (p_borrado IS NULL AND (
        (p_contexto='ambiente' AND (
          (p_autor=p.user_id AND p.area_codigo='ambiente') OR
          (p.area_codigo='vialidad' AND p.rol IN ('jefe_zona','jefe_tecnica','jefe_operativa') AND EXISTS(
            SELECT 1 FROM public.relevamiento_zonas_compartidas c WHERE c.relevamiento_id=p_id
            AND c.zona_destino=p.zona AND c.revocado_en IS NULL)))) OR
        (p_contexto='zonal' AND p.area_codigo='vialidad' AND (
          p.alcance_lectura='provincial_operativo' OR
          (p.alcance_lectura='zonal' AND p_zona=p.zona) OR
          (p_autor=p.user_id AND p.alcance_captura='provincial') OR
          (p.rol='capataz' AND p_zona=p.zona AND EXISTS(SELECT 1 FROM public.asignaciones_tarea a WHERE a.capataz_id=p.user_id
            AND a.zona=p.zona AND (a.relevamiento_origen_id=p_id OR a.registro_cierre_id=p_id))))
        )
      ))
    )
  )
$$;
CREATE FUNCTION dvba_privado.leer_relevamiento(p_id bigint) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT coalesce((SELECT dvba_privado.leer_fila_relevamiento(r.id,r.autor_id,r.contexto_trabajo,r.zona,r.borrado_en)
    FROM public.relevamientos r WHERE r.id=p_id),false)
$$;
CREATE FUNCTION dvba_privado.capturar(p_contexto text,p_zona text) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT coalesce((SELECT p.rol IN ('admin','tecnico','jefe_zona','jefe_tecnica','jefe_operativa')
    AND p.contexto_captura=p_contexto AND (
      p.alcance_captura='provincial' OR (p.alcance_captura='zonal' AND p.zona=p_zona))
    FROM dvba_privado.perfil() p),false)
$$;
CREATE FUNCTION dvba_privado.editar_relevamiento(p_id bigint) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT EXISTS(SELECT 1 FROM public.relevamientos r, dvba_privado.perfil() p WHERE r.id=p_id
    AND p.user_id IS NOT NULL AND (p.rol='admin' OR (r.borrado_en IS NULL AND (
      (p.rol='tecnico' AND r.autor_id=p.user_id AND p.contexto_captura=r.contexto_trabajo
        AND r.estado_workflow='campo' AND r.estado_registro IN ('borrador','observado')) OR
      (r.contexto_trabajo='zonal' AND p.area_codigo='vialidad' AND p.rol IN ('jefe_zona','jefe_tecnica','jefe_operativa')
        AND p.zona=r.zona)))))
$$;
CREATE POLICY fotos_meta_lectura ON public.registro_fotos FOR SELECT TO authenticated
  USING (dvba_privado.leer_relevamiento(relevamiento_id));
CREATE POLICY compartidos_lectura ON public.relevamiento_zonas_compartidas FOR SELECT TO authenticated
  USING (dvba_privado.leer_relevamiento(relevamiento_id) AND (
    (SELECT dvba_privado.admin()) OR compartido_por=(SELECT auth.uid()) OR
    (zona_destino=(SELECT public.current_user_zona()) AND revocado_en IS NULL)));

-- Políticas anteriores son permisivas (OR). Quitarlas, no superponer otras.
DO $$ DECLARE p record; BEGIN
  FOR p IN SELECT tablename,policyname FROM pg_policies WHERE schemaname='public'
    AND tablename IN ('relevamientos','partes_diarios','parte_fotos','parte_maquinarias') LOOP
    EXECUTE format('DROP POLICY %I ON public.%I',p.policyname,p.tablename);
  END LOOP;
END $$;
REVOKE ALL ON public.relevamientos,public.partes_diarios,public.parte_fotos,public.parte_maquinarias FROM anon,authenticated;
GRANT SELECT,INSERT,UPDATE ON public.relevamientos,public.partes_diarios,public.parte_fotos,public.parte_maquinarias TO authenticated;
GRANT USAGE ON SEQUENCE public.relevamientos_id_seq,public.partes_diarios_id_seq TO authenticated;
CREATE POLICY relev_v2_read ON public.relevamientos FOR SELECT TO authenticated
  USING(dvba_privado.leer_fila_relevamiento(id,autor_id,contexto_trabajo,zona,borrado_en));
CREATE POLICY relev_v2_insert ON public.relevamientos FOR INSERT TO authenticated WITH CHECK(
  autor_id=(SELECT auth.uid()) AND dvba_privado.capturar(contexto_trabajo,zona));
CREATE POLICY relev_v2_update ON public.relevamientos FOR UPDATE TO authenticated
  USING(dvba_privado.editar_relevamiento(id)) WITH CHECK(
    (SELECT dvba_privado.admin()) OR dvba_privado.capturar(contexto_trabajo,zona));

CREATE FUNCTION dvba_privado.leer_parte(p_id bigint) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT EXISTS(SELECT 1 FROM public.partes_diarios d,dvba_privado.perfil() p
    WHERE d.id=p_id AND p.user_id IS NOT NULL AND p.area_codigo='vialidad' AND (
      p.rol='admin' OR (d.borrado_en IS NULL AND p.rol<>'capataz' AND p.rol<>'publico'
        AND (p.alcance_lectura='provincial_operativo' OR (p.alcance_lectura='zonal' AND d.zona=p.zona)))))
$$;
CREATE FUNCTION dvba_privado.leer_fila_parte(p_zona text,p_borrado timestamptz) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT EXISTS(SELECT 1 FROM dvba_privado.perfil() p WHERE p.user_id IS NOT NULL AND p.area_codigo='vialidad' AND (
    p.rol='admin' OR (p_borrado IS NULL AND p.rol NOT IN ('capataz','publico') AND
      (p.alcance_lectura='provincial_operativo' OR (p.alcance_lectura='zonal' AND p_zona=p.zona)))))
$$;
CREATE FUNCTION dvba_privado.editar_parte(p_id bigint) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT EXISTS(SELECT 1 FROM public.partes_diarios d,dvba_privado.perfil() p
    WHERE d.id=p_id AND p.user_id IS NOT NULL AND p.area_codigo='vialidad' AND (
      p.rol='admin' OR (d.borrado_en IS NULL AND p.zona=d.zona AND (
        p.rol IN ('jefe_zona','jefe_tecnica','jefe_operativa') OR
        (p.rol='tecnico' AND d.autor_id=p.user_id AND NOT coalesce(d.enviado_admin,false))))))
$$;
CREATE POLICY partes_v2_read ON public.partes_diarios FOR SELECT TO authenticated USING(dvba_privado.leer_fila_parte(zona,borrado_en));
CREATE POLICY partes_v2_insert ON public.partes_diarios FOR INSERT TO authenticated WITH CHECK(
  autor_id=(SELECT auth.uid()) AND dvba_privado.capturar('zonal',zona));
CREATE POLICY partes_v2_update ON public.partes_diarios FOR UPDATE TO authenticated
  USING(dvba_privado.editar_parte(id)) WITH CHECK(dvba_privado.capturar('zonal',zona));
CREATE POLICY parte_fotos_v2_read ON public.parte_fotos FOR SELECT TO authenticated
  USING(dvba_privado.leer_parte(parte_id) AND dvba_privado.leer_relevamiento(relevamiento_id));
CREATE POLICY parte_fotos_v2_insert ON public.parte_fotos FOR INSERT TO authenticated
  WITH CHECK(dvba_privado.editar_parte(parte_id) AND EXISTS(SELECT 1 FROM public.relevamientos r
    WHERE r.id=relevamiento_id AND r.contexto_trabajo='zonal' AND dvba_privado.leer_relevamiento(r.id)));
CREATE POLICY parte_maq_v2_read ON public.parte_maquinarias FOR SELECT TO authenticated USING(dvba_privado.leer_parte(parte_id));
CREATE POLICY parte_maq_v2_insert ON public.parte_maquinarias FOR INSERT TO authenticated WITH CHECK(dvba_privado.editar_parte(parte_id));
CREATE POLICY parte_maq_v2_update ON public.parte_maquinarias FOR UPDATE TO authenticated
  USING(dvba_privado.editar_parte(parte_id)) WITH CHECK(dvba_privado.editar_parte(parte_id));

-- Preservar políticas de otros módulos, pero cerrar acceso a perfiles ausentes,
-- inactivos y Ambiente (aún no tiene permisos para esos módulos).
DO $$ DECLARE t text; BEGIN
  FOREACH t IN ARRAY ARRAY['asignaciones_tarea','comentarios_zona','caminos_alias','vehiculos','catalogo_tareas','catalogo_maquinarias','catalogo_identificadores'] LOOP
    EXECUTE format('CREATE POLICY dvba_habilitado ON public.%I AS RESTRICTIVE FOR ALL TO authenticated
      USING ((SELECT dvba_privado.activo()) AND (SELECT (dvba_privado.perfil()).area_codigo)=''vialidad'')
      WITH CHECK ((SELECT dvba_privado.activo()) AND (SELECT (dvba_privado.perfil()).area_codigo)=''vialidad'')',t);
  END LOOP;
END $$;
REVOKE DELETE ON public.asignaciones_tarea FROM anon,authenticated;
CREATE POLICY dvba_asignar ON public.asignaciones_tarea AS RESTRICTIVE FOR INSERT TO authenticated
  WITH CHECK ((SELECT public.current_user_rol()) IN ('admin','jefe_zona','jefe_operativa'));
-- La policy heredada permite UPDATE general al capataz sobre su tarea. Puede
-- cambiar sus enlaces y obtener lecturas adicionales: denegar esa vía completa.
-- El cierre requiere una RPC específica, todavía pendiente de integración.
CREATE POLICY dvba_planificar_cambio ON public.asignaciones_tarea AS RESTRICTIVE FOR UPDATE TO authenticated
  USING ((SELECT public.current_user_rol()) IN ('admin','jefe_zona','jefe_operativa'))
  WITH CHECK ((SELECT public.current_user_rol()) IN ('admin','jefe_zona','jefe_operativa'));
CREATE TRIGGER dvba_asignacion_audit AFTER INSERT OR UPDATE OR DELETE ON public.asignaciones_tarea
  FOR EACH ROW EXECUTE FUNCTION dvba_privado.auditar();
CREATE OR REPLACE FUNCTION public.current_user_puede_asignar() RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT coalesce(public.current_user_rol() IN ('admin','jefe_zona','jefe_operativa'),false)
$$;
-- Bloquear operaciones SQL peligrosas que no están cubiertas por RLS.
DO $$ DECLARE t record; BEGIN
  FOR t IN SELECT tablename FROM pg_tables WHERE schemaname='public' LOOP
    EXECUTE format('REVOKE TRUNCATE,REFERENCES,TRIGGER ON public.%I FROM anon,authenticated',t.tablename);
  END LOOP;
END $$;

-- Corregir los guards NULL de RPCs existentes; abortar ante deriva inesperada.
DO $$ DECLARE f record; d text; BEGIN
  FOR f IN SELECT p.oid,p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname IN ('admin_listar_usuarios','admin_metricas_usuarios','admin_metricas_sistema','restaurar_registro') LOOP
    d:=pg_get_functiondef(f.oid);
    IF position('current_user_rol() != ''admin''' IN d)=0 AND position('current_user_rol() <> ''admin''' IN d)=0 THEN
      RAISE EXCEPTION 'Guard inesperado en %: revisar deriva antes de migrar',f.proname;
    END IF;
    d:=replace(replace(d,'current_user_rol() != ''admin''','current_user_rol() IS DISTINCT FROM ''admin'''),
      'current_user_rol() <> ''admin''','current_user_rol() IS DISTINCT FROM ''admin''');
    EXECUTE d;
  END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.forzar_zona_por_rol() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE p public.usuarios_perfil; z text;
BEGIN
  p:=dvba_privado.perfil();
  IF nullif(trim(NEW.partido),'') IS NOT NULL THEN z:=public.zona_por_partido(NEW.partido); END IF;
  IF z IS NOT NULL THEN NEW.zona:=z;
  ELSIF p.area_codigo='ambiente' THEN NEW.zona:=NULL;
  ELSIF NEW.zona IS NULL OR NEW.zona='PBA' THEN NEW.zona:=p.zona;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER trg_relev_forzar_zona ON public.relevamientos;
CREATE TRIGGER trg_relev_forzar_zona BEFORE INSERT OR UPDATE OF zona,partido,lat,lng ON public.relevamientos
  FOR EACH ROW EXECUTE FUNCTION public.forzar_zona_por_rol();
DROP TRIGGER trg_partes_forzar_zona ON public.partes_diarios;
CREATE TRIGGER trg_partes_forzar_zona BEFORE INSERT OR UPDATE OF zona,partido ON public.partes_diarios
  FOR EACH ROW EXECUTE FUNCTION public.forzar_zona_por_rol();

CREATE FUNCTION dvba_privado.proteger_registro() RETURNS trigger
LANGUAGE plpgsql SET search_path='' AS $$
DECLARE p public.usuarios_perfil; protegidos text[];
BEGIN
  p:=dvba_privado.perfil();
  -- Solo las RPCs verificadas (DEFINER) y mantenimiento de servidor son confiables.
  IF current_user NOT IN ('postgres','service_role') THEN
    IF p.user_id IS NULL OR p.rol='publico' THEN RAISE EXCEPTION 'Perfil operativo activo requerido' USING ERRCODE='42501'; END IF;
    IF TG_OP='INSERT' THEN
      IF NEW.autor_id IS NOT NULL AND NEW.autor_id<>auth.uid() THEN
        RAISE EXCEPTION 'No puede atribuir un registro a otro usuario' USING ERRCODE='42501';
      END IF;
      NEW.autor_id:=p.user_id; NEW.autor_rol:=p.rol; NEW.autor_zona:=p.zona;
      IF TG_TABLE_NAME='partes_diarios' THEN NEW.responsable_id:=p.user_id; END IF;
      NEW.borrado_en:=NULL; NEW.borrado_por:=NULL; NEW.motivo_borrado:=NULL;
      NEW.restaurado_en:=NULL; NEW.restaurado_por:=NULL; NEW.motivo_restauracion:=NULL; NEW.restauracion_vista:=false;
      IF TG_TABLE_NAME='relevamientos' THEN
        NEW.contexto_trabajo:=p.contexto_captura;
        NEW.estado_registro:='borrador'; NEW.version:=1;
        IF NEW.estado_workflow IS DISTINCT FROM 'campo' AND p.rol NOT IN ('admin','jefe_zona','jefe_tecnica') THEN
          RAISE EXCEPTION 'No puede aprobar al crear' USING ERRCODE='42501';
        END IF;
        IF p.area_codigo='ambiente' AND NEW.foto_url IS NOT NULL THEN
          RAISE EXCEPTION 'Ambiente requiere fotos privadas reservadas' USING ERRCODE='42501';
        END IF;
      END IF;
    ELSE
      protegidos:=ARRAY['id','autor_id','autor_rol','autor_zona','borrado_en','borrado_por','motivo_borrado',
        'restaurado_en','restaurado_por','motivo_restauracion','restauracion_vista'];
      IF TG_TABLE_NAME='partes_diarios' THEN protegidos:=protegidos||ARRAY['responsable_id']; END IF;
      IF TG_TABLE_NAME='relevamientos' THEN
        protegidos:=protegidos||ARRAY['contexto_trabajo','captura_id','estado_registro'];
        IF OLD.contexto_trabajo='ambiente' THEN
          RAISE EXCEPTION 'Edite Ambiente mediante ambiente_editar con version esperada' USING ERRCODE='42501';
        END IF;
        IF NEW.version IS DISTINCT FROM OLD.version THEN RAISE EXCEPTION 'Version gestionada por servidor' USING ERRCODE='42501'; END IF;
        IF NEW.estado_workflow IS DISTINCT FROM OLD.estado_workflow AND p.rol NOT IN ('admin','jefe_zona','jefe_tecnica') THEN
          RAISE EXCEPTION 'Aprobacion no autorizada' USING ERRCODE='42501';
        END IF;
        IF OLD.contexto_trabajo='ambiente' AND NEW.foto_url IS NOT NULL THEN
          RAISE EXCEPTION 'Ambiente requiere fotos privadas' USING ERRCODE='42501';
        END IF;
      END IF;
      IF EXISTS(SELECT 1 FROM unnest(protegidos) campo WHERE to_jsonb(NEW)->campo IS DISTINCT FROM to_jsonb(OLD)->campo) THEN
        RAISE EXCEPTION 'Campo protegido: use una operacion autorizada' USING ERRCODE='42501';
      END IF;
    END IF;
  END IF;
  IF TG_TABLE_NAME='relevamientos' AND TG_OP='UPDATE' THEN NEW.version:=OLD.version+1; END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER zz_dvba_proteger BEFORE INSERT OR UPDATE ON public.relevamientos FOR EACH ROW EXECUTE FUNCTION dvba_privado.proteger_registro();
CREATE TRIGGER zz_dvba_proteger BEFORE INSERT OR UPDATE ON public.partes_diarios FOR EACH ROW EXECUTE FUNCTION dvba_privado.proteger_registro();
CREATE TRIGGER dvba_relev_audit AFTER INSERT OR UPDATE OR DELETE ON public.relevamientos FOR EACH ROW EXECUTE FUNCTION dvba_privado.auditar();
CREATE TRIGGER dvba_partes_audit AFTER INSERT OR UPDATE OR DELETE ON public.partes_diarios FOR EACH ROW EXECUTE FUNCTION dvba_privado.auditar();
CREATE TRIGGER dvba_compartir_audit AFTER INSERT OR UPDATE OR DELETE ON public.relevamiento_zonas_compartidas FOR EACH ROW EXECUTE FUNCTION dvba_privado.auditar();

-- Las RPCs nuevas publicas son INVOKER; la elevacion queda en esquema no expuesto.
CREATE FUNCTION dvba_privado.crear_ambiente(p_captura uuid,p_datos jsonb) RETURNS public.relevamientos
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE p public.usuarios_perfil; r public.relevamientos; d public.relevamientos;
BEGIN
  p:=dvba_privado.perfil();
  IF p.user_id IS NULL OR p.area_codigo<>'ambiente' OR p.rol<>'tecnico' OR p.alcance_captura<>'provincial' THEN
    RAISE EXCEPTION 'Captura Ambiente no autorizada' USING ERRCODE='42501';
  END IF;
  IF p_captura IS NULL OR p_datos IS NULL OR jsonb_typeof(p_datos)<>'object' OR EXISTS(
    SELECT 1 FROM jsonb_object_keys(p_datos) k WHERE k<>ALL(ARRAY['ruta','partido','progresiva','tipo','estado','observaciones',
      'lat','lng','fecha','naturaleza','superficie','modalidad','tipo_via','prioridad'])) THEN
    RAISE EXCEPTION 'Datos de captura invalidos o campos protegidos' USING ERRCODE='23514';
  END IF;
  d:=jsonb_populate_record(NULL::public.relevamientos,p_datos);
  IF d.lat IS NULL OR d.lng IS NULL OR NOT(d.lat BETWEEN -90 AND 90 AND d.lng BETWEEN -180 AND 180) THEN
    RAISE EXCEPTION 'Coordenadas requeridas y dentro de rango' USING ERRCODE='23514';
  END IF;
  INSERT INTO public.relevamientos(captura_id,contexto_trabajo,autor_id,autor_rol,autor_zona,ruta,partido,progresiva,
    tipo,estado,observaciones,lat,lng,fecha,naturaleza,superficie,modalidad,tipo_via,prioridad)
  VALUES(p_captura,'ambiente',p.user_id,p.rol,p.zona,coalesce(nullif(d.ruta,''),'?'),d.partido,coalesce(d.progresiva,''),
    coalesce(d.tipo,'sin_clasificar'),d.estado,d.observaciones,d.lat,d.lng,coalesce(d.fecha,now()),
    coalesce(d.naturaleza,'relevamiento'),d.superficie,d.modalidad,coalesce(d.tipo_via,'rp'),coalesce(d.prioridad,'normal'))
  ON CONFLICT(captura_id) DO NOTHING RETURNING * INTO r;
  IF r.id IS NULL THEN
    SELECT * INTO r FROM public.relevamientos WHERE captura_id=p_captura;
    IF r.autor_id IS DISTINCT FROM p.user_id OR r.contexto_trabajo IS DISTINCT FROM 'ambiente' THEN
      RAISE EXCEPTION 'Identificador de captura ya utilizado' USING ERRCODE='42501';
    END IF;
  END IF;
  RETURN r;
END $$;
CREATE FUNCTION public.ambiente_crear(p_captura uuid,p_datos jsonb) RETURNS public.relevamientos
LANGUAGE sql SECURITY INVOKER SET search_path='' AS $$ SELECT dvba_privado.crear_ambiente(p_captura,p_datos) $$;
CREATE FUNCTION dvba_privado.editar_ambiente(p_id bigint,p_version bigint,p_cambios jsonb) RETURNS public.relevamientos
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE p public.usuarios_perfil; r public.relevamientos; d public.relevamientos;
BEGIN
  p:=dvba_privado.perfil(); SELECT * INTO r FROM public.relevamientos WHERE id=p_id FOR UPDATE;
  IF p.user_id IS NULL OR r.id IS NULL OR p.area_codigo<>'ambiente' OR r.contexto_trabajo<>'ambiente'
    OR r.autor_id IS DISTINCT FROM p.user_id OR NOT dvba_privado.editar_relevamiento(p_id) THEN
    RAISE EXCEPTION 'Edicion no autorizada' USING ERRCODE='42501';
  END IF;
  IF p_version IS NULL OR r.version<>p_version THEN RAISE EXCEPTION 'Registro modificado: recargue antes de guardar' USING ERRCODE='40001'; END IF;
  IF p_cambios IS NULL OR jsonb_typeof(p_cambios)<>'object' OR EXISTS(
    SELECT 1 FROM jsonb_object_keys(p_cambios) k WHERE k<>ALL(ARRAY['ruta','partido','progresiva','tipo','estado','observaciones',
      'lat','lng','naturaleza','superficie','modalidad','tipo_via','prioridad'])) THEN
    RAISE EXCEPTION 'Campos de edicion no permitidos' USING ERRCODE='42501';
  END IF;
  d:=jsonb_populate_record(r,p_cambios);
  IF d.lat IS NULL OR d.lng IS NULL OR NOT(d.lat BETWEEN -90 AND 90 AND d.lng BETWEEN -180 AND 180) THEN
    RAISE EXCEPTION 'Coordenadas invalidas' USING ERRCODE='23514';
  END IF;
  UPDATE public.relevamientos SET ruta=d.ruta,partido=d.partido,progresiva=d.progresiva,tipo=d.tipo,estado=d.estado,
    observaciones=d.observaciones,lat=d.lat,lng=d.lng,naturaleza=d.naturaleza,superficie=d.superficie,
    modalidad=d.modalidad,tipo_via=d.tipo_via,prioridad=d.prioridad WHERE id=p_id RETURNING * INTO r;
  RETURN r;
END $$;
CREATE FUNCTION public.ambiente_editar(p_id bigint,p_version bigint,p_cambios jsonb) RETURNS public.relevamientos
LANGUAGE sql SECURITY INVOKER SET search_path='' AS $$ SELECT dvba_privado.editar_ambiente(p_id,p_version,p_cambios) $$;
CREATE FUNCTION dvba_privado.transicion(p_id bigint,p_version bigint,p_estado text) RETURNS bigint
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE r public.relevamientos; p public.usuarios_perfil;
BEGIN
  p:=dvba_privado.perfil(); SELECT * INTO r FROM public.relevamientos WHERE id=p_id FOR UPDATE;
  IF p.user_id IS NULL OR r.id IS NULL OR r.contexto_trabajo<>'ambiente'
    OR NOT coalesce(p.rol='admin' OR (p.area_codigo='ambiente' AND r.autor_id=p.user_id),false) OR r.borrado_en IS NOT NULL THEN
    RAISE EXCEPTION 'Transicion no autorizada' USING ERRCODE='42501';
  END IF;
  IF p_version IS NULL OR r.version<>p_version THEN RAISE EXCEPTION 'Registro modificado: recargue antes de guardar' USING ERRCODE='40001'; END IF;
  IF p_estado IS NULL THEN RAISE EXCEPTION 'Estado requerido' USING ERRCODE='23514'; END IF;
  IF NOT ((r.estado_registro IN ('borrador','observado') AND p_estado='presentado') OR
    (r.estado_registro='presentado' AND p_estado='cerrado') OR
    (p.rol='admin' AND r.estado_registro IN ('presentado','cerrado') AND p_estado='observado')) THEN
    RAISE EXCEPTION 'Transicion de estado invalida' USING ERRCODE='23514';
  END IF;
  UPDATE public.relevamientos SET estado_registro=p_estado WHERE id=p_id RETURNING version INTO p_version;
  RETURN p_version;
END $$;
CREATE FUNCTION public.ambiente_transicion(p_id bigint,p_version bigint,p_estado text) RETURNS bigint
LANGUAGE sql SECURITY INVOKER SET search_path='' AS $$ SELECT dvba_privado.transicion(p_id,p_version,p_estado) $$;
CREATE FUNCTION dvba_privado.compartir(p_id bigint,p_version bigint,p_zona text,p_motivo text,p_revocar boolean) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE r public.relevamientos; p public.usuarios_perfil; c uuid;
BEGIN
  p:=dvba_privado.perfil(); SELECT * INTO r FROM public.relevamientos WHERE id=p_id FOR UPDATE;
  IF p.user_id IS NULL OR r.id IS NULL OR r.contexto_trabajo<>'ambiente' OR r.borrado_en IS NOT NULL
    OR NOT coalesce(p.rol='admin' OR (p.area_codigo='ambiente' AND r.autor_id=p.user_id),false) THEN
    RAISE EXCEPTION 'Comparticion no autorizada' USING ERRCODE='42501';
  END IF;
  IF p_version IS NULL OR r.version<>p_version THEN RAISE EXCEPTION 'Version desactualizada' USING ERRCODE='40001'; END IF;
  IF p_revocar THEN
    UPDATE public.relevamiento_zonas_compartidas SET revocado_en=now(),revocado_por=p.user_id
      WHERE relevamiento_id=p_id AND zona_destino=p_zona AND revocado_en IS NULL RETURNING id INTO c;
  ELSE
    IF r.estado_registro NOT IN ('presentado','cerrado') THEN RAISE EXCEPTION 'Presente el registro antes de compartir' USING ERRCODE='23514'; END IF;
    INSERT INTO public.relevamiento_zonas_compartidas(relevamiento_id,zona_destino,compartido_por,motivo)
      VALUES(p_id,p_zona,p.user_id,p_motivo) RETURNING id INTO c;
  END IF;
  UPDATE public.relevamientos SET version=version WHERE id=p_id;
  RETURN c;
END $$;
CREATE FUNCTION public.ambiente_compartir(p_id bigint,p_version bigint,p_zona text,p_motivo text) RETURNS uuid
LANGUAGE sql SECURITY INVOKER SET search_path='' AS $$ SELECT dvba_privado.compartir(p_id,p_version,p_zona,p_motivo,false) $$;
CREATE FUNCTION public.ambiente_revocar(p_id bigint,p_version bigint,p_zona text) RETURNS uuid
LANGUAGE sql SECURITY INVOKER SET search_path='' AS $$ SELECT dvba_privado.compartir(p_id,p_version,p_zona,NULL,true) $$;

INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
  VALUES('ambiente_privado','ambiente_privado',false,10485760,ARRAY['image/jpeg','image/png','image/webp']);
CREATE FUNCTION dvba_privado.reservar_foto(p_id bigint,p_foto uuid DEFAULT gen_random_uuid()) RETURNS public.registro_fotos
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE r public.relevamientos; p public.usuarios_perfil; f public.registro_fotos;
BEGIN
  p:=dvba_privado.perfil(); SELECT * INTO r FROM public.relevamientos WHERE id=p_id FOR UPDATE;
  IF p.user_id IS NULL OR r.id IS NULL OR r.contexto_trabajo<>'ambiente' OR r.autor_id IS DISTINCT FROM p.user_id
    OR p.area_codigo<>'ambiente' OR NOT dvba_privado.editar_relevamiento(p_id) THEN
    RAISE EXCEPTION 'No puede adjuntar foto a este registro' USING ERRCODE='42501';
  END IF;
  IF p_foto IS NULL THEN RAISE EXCEPTION 'Identificador de foto requerido' USING ERRCODE='23514'; END IF;
  INSERT INTO public.registro_fotos(id,relevamiento_id,cargada_por,object_path)
    VALUES(p_foto,p_id,p.user_id,p.user_id::text||'/'||p_foto::text||'.jpg')
    ON CONFLICT(id) DO NOTHING RETURNING * INTO f;
  IF f.id IS NULL THEN
    SELECT * INTO f FROM public.registro_fotos WHERE id=p_foto;
    IF f.cargada_por IS DISTINCT FROM p.user_id OR f.relevamiento_id IS DISTINCT FROM p_id THEN
      RAISE EXCEPTION 'Identificador de foto ya utilizado' USING ERRCODE='42501';
    END IF;
  END IF;
  RETURN f;
END $$;
CREATE FUNCTION public.ambiente_reservar_foto(p_id bigint,p_foto uuid DEFAULT gen_random_uuid()) RETURNS public.registro_fotos
LANGUAGE sql SECURITY INVOKER SET search_path='' AS $$ SELECT dvba_privado.reservar_foto(p_id,p_foto) $$;

-- Quitar TODAS las policies del bucket legacy auditadas: ninguna autoriza anon.
-- Las URLs historicas siguen publicas: esta migracion no puede revocar descargas previas.
DO $$ DECLARE p record; BEGIN
  FOR p IN SELECT policyname FROM pg_policies WHERE schemaname='storage' AND tablename='objects' LOOP
    -- Abortamos si hay policies de otro producto; no borrar accesos desconocidos.
    IF p.policyname NOT IN ('auth_update_relevamientos','fotos_borrar_auth','fotos_lectura_individual','fotos_subida_auth','storage_insert_publico') THEN
      RAISE EXCEPTION 'Policy Storage desconocida %: revisar antes de migrar',p.policyname;
    END IF;
    EXECUTE format('DROP POLICY %I ON storage.objects',p.policyname);
  END LOOP;
END $$;
CREATE FUNCTION dvba_privado.leer_objeto(p_bucket text,p_name text) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT dvba_privado.activo() AND (
    (p_bucket='ambiente_privado' AND EXISTS(SELECT 1 FROM public.registro_fotos f
      WHERE f.bucket=p_bucket AND f.object_path=p_name AND dvba_privado.leer_relevamiento(f.relevamiento_id))) OR
    (p_bucket='relevamientos' AND (dvba_privado.admin() OR EXISTS(SELECT 1 FROM public.relevamientos r
      WHERE r.contexto_trabajo='zonal' AND r.foto_url='https://txjlfpffyzuhdqtfhlmc.supabase.co/storage/v1/object/public/relevamientos/'||p_name
      AND dvba_privado.leer_relevamiento(r.id))))
  )
$$;
CREATE FUNCTION dvba_privado.subir_objeto(p_bucket text,p_name text) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
  SELECT dvba_privado.activo() AND (
    (p_bucket='ambiente_privado' AND EXISTS(SELECT 1 FROM public.registro_fotos f
      WHERE f.bucket=p_bucket AND f.object_path=p_name AND f.cargada_por=auth.uid()
        AND dvba_privado.editar_relevamiento(f.relevamiento_id))) OR
    (p_bucket='relevamientos' AND EXISTS(SELECT 1 FROM dvba_privado.perfil() p
      WHERE p.area_codigo='vialidad' AND p.rol IN ('admin','tecnico','jefe_zona','jefe_tecnica','jefe_operativa')))
  )
$$;
CREATE POLICY dvba_objeto_read ON storage.objects FOR SELECT TO authenticated USING(dvba_privado.leer_objeto(bucket_id,name));
CREATE POLICY dvba_objeto_insert ON storage.objects FOR INSERT TO authenticated WITH CHECK(dvba_privado.subir_objeto(bucket_id,name));
-- Reemplazos y borrados solo mediante futuras operaciones auditadas. Ninguna
-- policy UPDATE/DELETE general; ni siquiera un lector con cuenta autenticada.

-- Corregir RPCs de archivo para impedir uso con NULL o sobre Ambiente compartido.
CREATE OR REPLACE FUNCTION public.soft_delete_relevamiento(p_id bigint,p_motivo text) RETURNS bigint
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE r public.relevamientos; p public.usuarios_perfil;
BEGIN
  p:=dvba_privado.perfil(); SELECT * INTO r FROM public.relevamientos WHERE id=p_id FOR UPDATE;
  IF p.user_id IS NULL OR r.id IS NULL OR NOT coalesce(p.rol='admin' OR
    (p.rol='jefe_zona' AND p.area_codigo='vialidad' AND r.contexto_trabajo='zonal' AND p.zona=r.zona),false) THEN
    RAISE EXCEPTION 'Archivo no autorizado' USING ERRCODE='42501';
  END IF;
  IF length(trim(coalesce(p_motivo,'')))<10 THEN RAISE EXCEPTION 'Motivo obligatorio: minimo 10 caracteres' USING ERRCODE='23514'; END IF;
  UPDATE public.relevamientos SET borrado_en=now(),borrado_por=p.user_id,motivo_borrado=p_motivo WHERE id=p_id AND borrado_en IS NULL;
  RETURN p_id;
END $$;
CREATE OR REPLACE FUNCTION public.soft_delete_parte_diario(p_id bigint,p_motivo text) RETURNS bigint
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE r public.partes_diarios; p public.usuarios_perfil;
BEGIN
  p:=dvba_privado.perfil(); SELECT * INTO r FROM public.partes_diarios WHERE id=p_id FOR UPDATE;
  IF p.user_id IS NULL OR r.id IS NULL OR NOT coalesce(p.rol='admin' OR (p.rol='jefe_zona' AND p.area_codigo='vialidad' AND p.zona=r.zona),false) THEN
    RAISE EXCEPTION 'Archivo no autorizado' USING ERRCODE='42501';
  END IF;
  IF length(trim(coalesce(p_motivo,'')))<10 THEN RAISE EXCEPTION 'Motivo obligatorio: minimo 10 caracteres' USING ERRCODE='23514'; END IF;
  UPDATE public.partes_diarios SET borrado_en=now(),borrado_por=p.user_id,motivo_borrado=p_motivo WHERE id=p_id AND borrado_en IS NULL;
  RETURN p_id;
END $$;

-- Contadores con RLS del invocador, sin saltarse permisos ni revelar Ambiente.
CREATE OR REPLACE FUNCTION public.comentarios_contadores() RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY INVOKER SET search_path='' AS $$
DECLARE p public.usuarios_perfil;
BEGIN
  p:=dvba_privado.perfil();
  IF p.user_id IS NULL OR p.area_codigo<>'vialidad' THEN RETURN '{}'::jsonb; END IF;
  IF p.rol='admin' THEN RETURN (SELECT jsonb_build_object(
    'solicitudes_pendientes',count(*) FILTER(WHERE estado='abierto' AND tipo IN ('mover_zona','eliminar')),
    'comentarios_abiertos',count(*) FILTER(WHERE estado='abierto' AND tipo='comentario')) FROM public.comentarios_zona);
  ELSIF p.rol='gerencia' THEN RETURN (SELECT jsonb_build_object(
    'mis_comentarios_activos',count(*) FILTER(WHERE autor_id=p.user_id AND estado='abierto' AND tipo='comentario'),
    'solicitudes_mias_pendientes',count(*) FILTER(WHERE autor_id=p.user_id AND estado='abierto' AND tipo IN ('mover_zona','eliminar'))) FROM public.comentarios_zona);
  ELSIF p.rol='tecnico' THEN RETURN (SELECT jsonb_build_object(
    'comentarios_sin_responder',count(*) FILTER(WHERE target_zona=p.zona AND estado='abierto' AND tipo='comentario'),
    'mis_solicitudes_pendientes',count(*) FILTER(WHERE autor_id=p.user_id AND estado='abierto' AND tipo IN ('mover_zona','eliminar'))) FROM public.comentarios_zona);
  END IF;
  RETURN '{}'::jsonb;
END $$;
CREATE OR REPLACE FUNCTION public.marcar_restauraciones_vistas() RETURNS integer
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE p public.usuarios_perfil; n integer; m integer;
BEGIN
  p:=dvba_privado.perfil();
  IF p.user_id IS NULL OR p.area_codigo<>'vialidad' OR p.rol='publico' THEN RETURN 0; END IF;
  UPDATE public.relevamientos SET restauracion_vista=true
    WHERE restaurado_en IS NOT NULL AND NOT restauracion_vista AND dvba_privado.leer_relevamiento(id)
      AND (contexto_trabajo='zonal' OR p.rol='admin');
  GET DIAGNOSTICS n=ROW_COUNT;
  UPDATE public.partes_diarios SET restauracion_vista=true
    WHERE restaurado_en IS NOT NULL AND NOT restauracion_vista AND dvba_privado.leer_parte(id);
  GET DIAGNOSTICS m=ROW_COUNT;
  RETURN n+m;
END $$;

-- Privilegios explicitos al final: las funciones nuevas no quedan publicas por defecto.
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA dvba_privado FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION dvba_privado.perfil(),dvba_privado.activo(),dvba_privado.admin(),
  dvba_privado.leer_relevamiento(bigint),dvba_privado.editar_relevamiento(bigint),dvba_privado.capturar(text,text),
  dvba_privado.leer_fila_relevamiento(bigint,uuid,text,text,timestamptz),
  dvba_privado.leer_parte(bigint),dvba_privado.editar_parte(bigint),dvba_privado.leer_objeto(text,text),dvba_privado.subir_objeto(text,text),
  dvba_privado.leer_fila_parte(text,timestamptz),
  dvba_privado.transicion(bigint,bigint,text),dvba_privado.compartir(bigint,bigint,text,text,boolean),dvba_privado.reservar_foto(bigint,uuid)
  ,dvba_privado.crear_ambiente(uuid,jsonb),dvba_privado.editar_ambiente(bigint,bigint,jsonb)
  TO authenticated;
REVOKE ALL ON FUNCTION public.ambiente_transicion(bigint,bigint,text),public.ambiente_compartir(bigint,bigint,text,text),
  public.ambiente_revocar(bigint,bigint,text),public.ambiente_reservar_foto(bigint,uuid),
  public.ambiente_crear(uuid,jsonb),public.ambiente_editar(bigint,bigint,jsonb) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.ambiente_transicion(bigint,bigint,text),public.ambiente_compartir(bigint,bigint,text,text),
  public.ambiente_revocar(bigint,bigint,text),public.ambiente_reservar_foto(bigint,uuid),
  public.ambiente_crear(uuid,jsonb),public.ambiente_editar(bigint,bigint,jsonb) TO authenticated;
COMMIT;
