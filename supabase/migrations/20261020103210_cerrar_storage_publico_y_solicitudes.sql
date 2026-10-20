BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='30s';

-- Requiere el piloto compatible; no aplicar la candidata integral.
DO $$ BEGIN
 IF to_regprocedure('dvba_privado.perfil()') IS NULL THEN RAISE EXCEPTION 'Falta el piloto compatible'; END IF;
END $$;

CREATE OR REPLACE FUNCTION dvba_privado.capturador_vial() RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
 SELECT coalesce((SELECT p.area_codigo='vialidad' AND p.rol IN
 ('admin','tecnico','jefe_zona','jefe_tecnica','jefe_operativa','capataz')
 FROM dvba_privado.perfil() p),false)
$$;
REVOKE ALL ON FUNCTION dvba_privado.capturador_vial() FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION dvba_privado.capturador_vial() TO authenticated;

CREATE OR REPLACE FUNCTION dvba_privado.actualizar_foto_zonal(p_name text,p_owner text) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
 SELECT coalesce((SELECT p.area_codigo='vialidad' AND (
 p.rol='admin' OR (p.rol IN ('tecnico','capataz','jefe_zona','jefe_tecnica','jefe_operativa') AND p_owner=p.user_id::text)
 OR (p.rol IN ('jefe_zona','jefe_tecnica','jefe_operativa') AND EXISTS(
 SELECT 1 FROM public.relevamientos r WHERE r.contexto_trabajo='zonal' AND r.zona=p.zona AND r.borrado_en IS NULL
 AND r.foto_url='https://txjlfpffyzuhdqtfhlmc.supabase.co/storage/v1/object/public/relevamientos/'||p_name)))
 FROM dvba_privado.perfil() p),false)
$$;
REVOKE ALL ON FUNCTION dvba_privado.actualizar_foto_zonal(text,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION dvba_privado.actualizar_foto_zonal(text,text) TO authenticated;

DROP POLICY IF EXISTS storage_insert_publico ON storage.objects;
CREATE POLICY perimetro_anon_no_insert ON storage.objects AS RESTRICTIVE
 FOR INSERT TO anon WITH CHECK(false);
DROP POLICY piloto_storage_insert ON storage.objects;
CREATE POLICY piloto_storage_insert ON storage.objects AS RESTRICTIVE FOR INSERT TO authenticated
 WITH CHECK((bucket_id='relevamientos' AND dvba_privado.capturador_vial() AND owner_id=auth.uid()::text)
 OR (bucket_id='ambiente_privado' AND dvba_privado.subir_objeto(bucket_id,name)));
DROP POLICY piloto_storage_update ON storage.objects;
CREATE POLICY piloto_storage_update ON storage.objects AS RESTRICTIVE FOR UPDATE TO authenticated
 USING(bucket_id='relevamientos' AND dvba_privado.actualizar_foto_zonal(name,owner_id))
 WITH CHECK(bucket_id='relevamientos' AND dvba_privado.actualizar_foto_zonal(name,owner_id));
DROP POLICY piloto_storage_delete ON storage.objects;
CREATE POLICY piloto_storage_delete ON storage.objects AS RESTRICTIVE FOR DELETE TO authenticated
 USING(bucket_id='relevamientos' AND dvba_privado.admin());
UPDATE storage.buckets SET file_size_limit=10485760,
 allowed_mime_types=ARRAY['image/jpeg','image/png','image/webp']
 WHERE id='relevamientos';

-- Proteger campos de archivo también frente a PATCH directo, no solo el botón.
CREATE OR REPLACE FUNCTION dvba_privado.proteger_archivo() RETURNS trigger
LANGUAGE plpgsql SET search_path='' AS $$
BEGIN
 IF current_user NOT IN ('postgres','service_role') AND NOT dvba_privado.admin() AND (
 NEW.borrado_en IS DISTINCT FROM OLD.borrado_en OR NEW.borrado_por IS DISTINCT FROM OLD.borrado_por
 OR NEW.motivo_borrado IS DISTINCT FROM OLD.motivo_borrado
 OR NEW.restaurado_en IS DISTINCT FROM OLD.restaurado_en OR NEW.restaurado_por IS DISTINCT FROM OLD.restaurado_por
 OR NEW.motivo_restauracion IS DISTINCT FROM OLD.motivo_restauracion) THEN
 RAISE EXCEPTION 'Solo el administrador puede archivar o restaurar; envie una solicitud' USING ERRCODE='42501';
 END IF;
 RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION dvba_privado.proteger_archivo() FROM PUBLIC,anon,authenticated;
CREATE TRIGGER perimetro_archivo_relev BEFORE UPDATE ON public.relevamientos
 FOR EACH ROW EXECUTE FUNCTION dvba_privado.proteger_archivo();
CREATE TRIGGER perimetro_archivo_parte BEFORE UPDATE ON public.partes_diarios
 FOR EACH ROW EXECUTE FUNCTION dvba_privado.proteger_archivo();

-- Guard adicional al comienzo de ambas RPC heredadas: solo admin activo.
DO $cambio$
DECLARE f regprocedure; src text;
BEGIN
 FOREACH f IN ARRAY ARRAY['public.soft_delete_relevamiento(bigint,text)'::regprocedure,
 'public.soft_delete_parte_diario(bigint,text)'::regprocedure] LOOP
 src:=pg_get_functiondef(f);
 IF position('BEGIN' IN src)=0 THEN RAISE EXCEPTION 'RPC sin cuerpo esperado'; END IF;
 src:=regexp_replace(src,'BEGIN',E'BEGIN\n IF NOT dvba_privado.admin() THEN RAISE EXCEPTION ''Solo admin puede archivar; envie una solicitud'' USING ERRCODE=''42501''; END IF;');
 EXECUTE src;
 END LOOP;
END $cambio$;

-- Solicitudes persistentes en la bandeja administrativa existente.
DO $constraint$
DECLARE c record;
BEGIN
 FOR c IN SELECT conname FROM pg_constraint WHERE conrelid='public.comentarios_zona'::regclass
 AND contype='c' AND pg_get_constraintdef(oid) LIKE '%autor_rol%' LOOP
 EXECUTE format('ALTER TABLE public.comentarios_zona DROP CONSTRAINT %I',c.conname);
 END LOOP;
END $constraint$;
ALTER TABLE public.comentarios_zona ADD CONSTRAINT comentarios_autor_rol_perimetro
 CHECK(autor_rol IN ('admin','gerencia','tecnico','jefe_zona','jefe_tecnica','jefe_operativa','jefe_administrativa','jefe_automotores'));

CREATE OR REPLACE FUNCTION dvba_privado.puede_solicitar_borrado(p_tabla text,p_id bigint,p_zona text)
RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE p public.usuarios_perfil; z text; contexto text;
BEGIN
 p:=dvba_privado.perfil();
 IF p.user_id IS NULL OR p.area_codigo<>'vialidad' OR p.rol NOT IN
 ('admin','gerencia','jefe_zona','jefe_tecnica','jefe_operativa','jefe_administrativa','jefe_automotores') THEN RETURN false; END IF;
 IF p_tabla='relevamientos' THEN
 SELECT zona,contexto_trabajo INTO z,contexto FROM public.relevamientos WHERE id=p_id AND borrado_en IS NULL;
 IF NOT FOUND OR (contexto<>'zonal' AND p.rol<>'admin') THEN RETURN false; END IF;
 ELSIF p_tabla='partes_diarios' THEN
 SELECT zona INTO z FROM public.partes_diarios WHERE id=p_id AND borrado_en IS NULL;
 IF NOT FOUND THEN RETURN false; END IF;
 ELSE RETURN false;
 END IF;
 RETURN z IS NOT DISTINCT FROM p_zona AND (p.rol IN ('admin','gerencia') OR z=p.zona);
END $$;
REVOKE ALL ON FUNCTION dvba_privado.puede_solicitar_borrado(text,bigint,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION dvba_privado.puede_solicitar_borrado(text,bigint,text) TO authenticated;
CREATE POLICY solicitud_borrado_insert ON public.comentarios_zona FOR INSERT TO authenticated
 WITH CHECK(tipo='eliminar' AND autor_id=auth.uid() AND autor_rol=public.current_user_rol()
 AND estado='abierto' AND respuesta IS NULL AND respondido_por IS NULL AND respondido_en IS NULL
 AND length(trim(mensaje))>=10 AND dvba_privado.puede_solicitar_borrado(target_tabla,target_id,target_zona));

CREATE OR REPLACE FUNCTION dvba_privado.proteger_solicitud_borrado() RETURNS trigger
LANGUAGE plpgsql SET search_path='' AS $$
BEGIN
 IF TG_OP='UPDATE' AND (OLD.tipo='eliminar' OR NEW.tipo='eliminar') AND NOT dvba_privado.admin()
 AND current_user NOT IN ('postgres','service_role') THEN
 RAISE EXCEPTION 'Solo admin resuelve o cambia una solicitud de borrado' USING ERRCODE='42501';
 END IF;
 IF TG_OP='INSERT' AND NEW.tipo='eliminar' AND current_user NOT IN ('postgres','service_role') THEN
 IF NOT dvba_privado.puede_solicitar_borrado(NEW.target_tabla,NEW.target_id,NEW.target_zona)
 OR NEW.autor_id IS DISTINCT FROM auth.uid() OR length(trim(NEW.mensaje))<10
 OR NEW.estado IS DISTINCT FROM 'abierto' OR NEW.respuesta IS NOT NULL
 OR NEW.respondido_por IS NOT NULL OR NEW.respondido_en IS NOT NULL THEN
 RAISE EXCEPTION 'Solicitud de borrado invalida o sin justificacion' USING ERRCODE='42501';
 END IF;
 NEW.autor_rol:=public.current_user_rol();NEW.autor_zona:=public.current_user_zona();
 END IF;
 RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION dvba_privado.proteger_solicitud_borrado() FROM PUBLIC,anon,authenticated;
CREATE TRIGGER perimetro_solicitud_borrado BEFORE INSERT OR UPDATE ON public.comentarios_zona
 FOR EACH ROW EXECUTE FUNCTION dvba_privado.proteger_solicitud_borrado();

-- El solicitante puede consultar su pedido, no resolverlo.
CREATE POLICY solicitud_borrado_lectura ON public.comentarios_zona FOR SELECT TO authenticated
 USING(tipo='eliminar' AND autor_id=auth.uid() AND dvba_privado.activo());
COMMIT;
