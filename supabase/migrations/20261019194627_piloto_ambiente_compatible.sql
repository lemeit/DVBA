-- PILOTO COMPATIBLE. No ejecutar la candidata integral junto a este archivo.
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='30s';
-- Abortar antes de cualquier DDL si existe una aplicación anterior o parcial.
DO $$ BEGIN
 IF to_regnamespace('dvba_privado') IS NOT NULL
 OR to_regclass('public.registro_fotos') IS NOT NULL
 OR to_regclass('public.relevamiento_zonas_compartidas') IS NOT NULL
 OR EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public'
   AND ((table_name='usuarios_perfil' AND column_name IN ('area_codigo','contexto_captura','alcance_lectura','alcance_captura','permisos_version'))
   OR (table_name='relevamientos' AND column_name IN ('contexto_trabajo','estado_registro','captura_id','version')))) THEN
   RAISE EXCEPTION 'Preflight: estructura piloto ya existente; no se ejecutó la migración';
 END IF;
END $$;
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

CREATE POLICY piloto_perfil_insert ON public.usuarios_perfil AS RESTRICTIVE FOR INSERT TO authenticated WITH CHECK ((SELECT dvba_privado.admin()));
CREATE POLICY piloto_perfil_read ON public.usuarios_perfil AS RESTRICTIVE FOR SELECT TO authenticated USING ((SELECT dvba_privado.activo()) AND ((SELECT (dvba_privado.perfil()).area_codigo)<>'ambiente' OR user_id=(SELECT auth.uid())));
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

CREATE POLICY piloto_relev_read ON public.relevamientos AS RESTRICTIVE FOR SELECT TO authenticated USING((SELECT dvba_privado.activo()) AND ((contexto_trabajo='zonal' AND (SELECT (dvba_privado.perfil()).area_codigo)='vialidad') OR (contexto_trabajo='ambiente' AND dvba_privado.leer_relevamiento(id))));
CREATE POLICY piloto_relev_env_read ON public.relevamientos FOR SELECT TO authenticated USING(contexto_trabajo='ambiente' AND dvba_privado.leer_relevamiento(id));
CREATE POLICY piloto_relev_insert ON public.relevamientos AS RESTRICTIVE FOR INSERT TO authenticated WITH CHECK(contexto_trabajo='zonal' AND (SELECT dvba_privado.activo()) AND (SELECT (dvba_privado.perfil()).area_codigo)='vialidad');
CREATE POLICY piloto_relev_update ON public.relevamientos AS RESTRICTIVE FOR UPDATE TO authenticated USING(contexto_trabajo='zonal' AND (SELECT dvba_privado.activo()) AND (SELECT (dvba_privado.perfil()).area_codigo)='vialidad') WITH CHECK(contexto_trabajo='zonal' AND (SELECT dvba_privado.activo()) AND (SELECT (dvba_privado.perfil()).area_codigo)='vialidad');
CREATE POLICY piloto_relev_delete ON public.relevamientos AS RESTRICTIVE FOR DELETE TO authenticated USING(contexto_trabajo='zonal' AND (SELECT dvba_privado.admin()));
DO $$ DECLARE t text; BEGIN
FOREACH t IN ARRAY ARRAY['partes_diarios','parte_fotos','parte_maquinarias','asignaciones_tarea','comentarios_zona','caminos_alias','vehiculos','catalogo_tareas','catalogo_maquinarias','catalogo_identificadores'] LOOP
EXECUTE format('CREATE POLICY piloto_sin_ambiente ON public.%I AS RESTRICTIVE FOR ALL TO authenticated USING ((SELECT dvba_privado.activo()) AND (SELECT (dvba_privado.perfil()).area_codigo)=''vialidad'') WITH CHECK ((SELECT dvba_privado.activo()) AND (SELECT (dvba_privado.perfil()).area_codigo)=''vialidad'')',t);
END LOOP; END $$;
CREATE FUNCTION dvba_privado.proteger_ambiente() RETURNS trigger LANGUAGE plpgsql SET search_path='' AS $$ BEGIN
IF NEW.contexto_trabajo='ambiente' OR (TG_OP='UPDATE' AND OLD.contexto_trabajo='ambiente') THEN
IF current_user NOT IN ('postgres','service_role') THEN RAISE EXCEPTION 'Use las operaciones autorizadas de Ambiente' USING ERRCODE='42501'; END IF;
IF TG_OP='UPDATE' THEN NEW.version:=OLD.version+1; END IF; END IF; RETURN NEW; END $$;
CREATE TRIGGER zz_piloto_ambiente BEFORE INSERT OR UPDATE ON public.relevamientos FOR EACH ROW EXECUTE FUNCTION dvba_privado.proteger_ambiente();
CREATE TRIGGER piloto_relev_audit AFTER INSERT OR UPDATE ON public.relevamientos FOR EACH ROW WHEN (NEW.contexto_trabajo='ambiente') EXECUTE FUNCTION dvba_privado.auditar();
CREATE TRIGGER piloto_compartir_audit AFTER INSERT OR UPDATE OR DELETE ON public.relevamiento_zonas_compartidas FOR EACH ROW EXECUTE FUNCTION dvba_privado.auditar();
CREATE TRIGGER piloto_fotos_audit AFTER INSERT OR UPDATE OR DELETE ON public.registro_fotos FOR EACH ROW EXECUTE FUNCTION dvba_privado.auditar();
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
CREATE POLICY piloto_storage_read ON storage.objects AS RESTRICTIVE FOR SELECT TO authenticated USING ((bucket_id<>'ambiente_privado' AND (SELECT (dvba_privado.perfil()).area_codigo)='vialidad') OR (bucket_id='ambiente_privado' AND dvba_privado.leer_objeto(bucket_id,name)));
CREATE POLICY piloto_storage_insert ON storage.objects AS RESTRICTIVE FOR INSERT TO authenticated WITH CHECK ((bucket_id<>'ambiente_privado' AND (SELECT (dvba_privado.perfil()).area_codigo)='vialidad') OR (bucket_id='ambiente_privado' AND dvba_privado.subir_objeto(bucket_id,name)));
CREATE POLICY piloto_storage_update ON storage.objects AS RESTRICTIVE FOR UPDATE TO authenticated USING(bucket_id<>'ambiente_privado' AND (SELECT (dvba_privado.perfil()).area_codigo)='vialidad') WITH CHECK(bucket_id<>'ambiente_privado' AND (SELECT (dvba_privado.perfil()).area_codigo)='vialidad');
CREATE POLICY piloto_storage_delete ON storage.objects AS RESTRICTIVE FOR DELETE TO authenticated USING(bucket_id<>'ambiente_privado' AND (SELECT (dvba_privado.perfil()).area_codigo)='vialidad');
CREATE POLICY piloto_privado_read ON storage.objects FOR SELECT TO authenticated USING(bucket_id='ambiente_privado' AND dvba_privado.leer_objeto(bucket_id,name));
CREATE POLICY piloto_privado_insert ON storage.objects FOR INSERT TO authenticated WITH CHECK(bucket_id='ambiente_privado' AND dvba_privado.subir_objeto(bucket_id,name));
DO $$ DECLARE f record; d text; BEGIN
FOR f IN SELECT p.oid,p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.proname IN ('soft_delete_relevamiento','soft_delete_parte_diario') LOOP
 d:=pg_get_functiondef(f.oid);
 IF f.proname='soft_delete_relevamiento' THEN
 d:=replace(d,'BEGIN','BEGIN IF public.current_user_rol() IS DISTINCT FROM ''admin'' AND EXISTS(SELECT 1 FROM public.relevamientos WHERE id=p_id AND contexto_trabajo=''ambiente'') THEN RAISE EXCEPTION ''No puede archivar el original de Ambiente'' USING ERRCODE=''42501''; END IF;');
 END IF;
 d:=replace(d,'BEGIN',E'BEGIN\n IF NOT dvba_privado.activo() OR (dvba_privado.perfil()).area_codigo IS DISTINCT FROM ''vialidad'' THEN RAISE EXCEPTION ''Acceso denegado'' USING ERRCODE=''42501''; END IF;'); EXECUTE d;
END LOOP;
FOR f IN SELECT p.oid,p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.proname IN ('comentarios_contadores','marcar_restauraciones_vistas') LOOP
 d:=pg_get_functiondef(f.oid);
 d:=replace(d,'BEGIN','BEGIN IF NOT dvba_privado.activo() OR (dvba_privado.perfil()).area_codigo IS DISTINCT FROM ''vialidad'' THEN RETURN '||CASE WHEN f.proname='comentarios_contadores' THEN '''{}''::jsonb' ELSE '0' END||'; END IF;'); EXECUTE d;
END LOOP; END $$;
-- Privilegios explicitos al final: las funciones nuevas no quedan publicas por defecto.
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA dvba_privado FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION dvba_privado.perfil(),dvba_privado.activo(),dvba_privado.admin(),
  dvba_privado.leer_relevamiento(bigint),dvba_privado.editar_relevamiento(bigint),dvba_privado.capturar(text,text),
  dvba_privado.leer_fila_relevamiento(bigint,uuid,text,text,timestamptz),
  dvba_privado.leer_objeto(text,text),dvba_privado.subir_objeto(text,text),
  dvba_privado.transicion(bigint,bigint,text),dvba_privado.compartir(bigint,bigint,text,text,boolean),dvba_privado.reservar_foto(bigint,uuid)
  ,dvba_privado.crear_ambiente(uuid,jsonb),dvba_privado.editar_ambiente(bigint,bigint,jsonb)
  TO authenticated;
REVOKE ALL ON FUNCTION public.ambiente_transicion(bigint,bigint,text),public.ambiente_compartir(bigint,bigint,text,text),
  public.ambiente_revocar(bigint,bigint,text),public.ambiente_reservar_foto(bigint,uuid),
  public.ambiente_crear(uuid,jsonb),public.ambiente_editar(bigint,bigint,jsonb) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.ambiente_transicion(bigint,bigint,text),public.ambiente_compartir(bigint,bigint,text,text),
  public.ambiente_revocar(bigint,bigint,text),public.ambiente_reservar_foto(bigint,uuid),
  public.ambiente_crear(uuid,jsonb),public.ambiente_editar(bigint,bigint,jsonb) TO authenticated;
NOTIFY pgrst, 'reload schema';
COMMIT;
