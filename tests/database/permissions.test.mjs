import { PGlite } from '@electric-sql/pglite';
import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { loadBaseline } from './fixture.mjs';

const db=new PGlite();
const id=n=>'00000000-0000-4000-8000-'+String(n).padStart(12,'0');
const users={admin:1,ambiente:2,ambiente2:3,gerencia:4,jefeVI:5,jefeIV:6,tecnico:7,capataz:8,lector:9,inactivo:10,sinPerfil:11,operativa:12};
let passed=0;
async function as(who,fn,{commit=false}={}) {
  await db.exec('BEGIN');
  try {
    const role=who==='anon'?'anon':'authenticated';
    await db.query("SELECT set_config('request.jwt.claims',$1,true)",[JSON.stringify({sub:who==='anon'?undefined:id(users[who]),role})]);
    await db.exec('SET LOCAL ROLE '+role);
    const r=await fn();
    await db.exec(commit?'COMMIT':'ROLLBACK');
    return r;
  } catch(e) { await db.exec('ROLLBACK');throw e; }
}
async function test(name,fn){await fn();passed++;console.log('OK '+name);}
const count=async(sql,args=[])=>Number((await db.query(sql,args)).rows[0].n);
const denied=async(fn)=>{await assert.rejects(fn,e=>['42501','23514','P0001'].includes(e.code));};
const visible=async(who,rid)=>as(who,()=>count('SELECT count(*) n FROM public.relevamientos WHERE id=$1',[rid]));
const insert=async(who,extra={})=>as(who,()=>{
  const reg={ruta:'RP30',progresiva:'10',tipo:'sin_clasificar',zona:'VI',estado_workflow:'campo',lat:-35,lng:-59,...extra};
  return db.query(`INSERT INTO public.relevamientos(${Object.keys(reg).join(',')}) VALUES(${Object.keys(reg).map((_,i)=>'$'+(i+1)).join(',')}) RETURNING id,autor_id,contexto_trabajo,zona,version`,Object.values(reg));
},{commit:true});

try {
  await loadBaseline(db);
  for(const n of Object.values(users))await db.query('INSERT INTO auth.users(id,email) VALUES($1,$2)',[id(n),'test'+n+'@example.invalid']);
  for(const [who,rol,zona,activo] of [
    ['admin','admin',null,true],['ambiente','tecnico','VI',true],['ambiente2','tecnico','VI',true],
    ['gerencia','gerencia',null,true],['jefeVI','jefe_tecnica','VI',true],['jefeIV','jefe_zona','IV',true],
    ['tecnico','tecnico','VI',true],['capataz','capataz','VI',true],['lector','jefe_administrativa','VI',true],
    ['inactivo','admin',null,false],['operativa','jefe_operativa','VI',true]
  ])await db.query('INSERT INTO public.usuarios_perfil(user_id,nombre,rol,zona,activo) VALUES($1,$2,$3,$4,$5)',[id(users[who]),who,rol,zona,activo]);
  const files=(await readdir(new URL('../../supabase/candidatas/',import.meta.url))).filter(f=>f.endsWith('_permisos_etapa_1.sql'));
  assert.equal(files.length,1);
  await db.exec(await readFile(new URL('../../supabase/candidatas/'+files[0],import.meta.url),'utf8'));
  await test('migración completa sobre esquema auditado',async()=>assert.ok(true));
  for(const who of ['ambiente','ambiente2'])await db.query(`UPDATE public.usuarios_perfil SET area_codigo='ambiente',contexto_captura='ambiente',alcance_lectura='propios',alcance_captura='provincial',zona=NULL WHERE user_id=$1`,[id(users[who])]);
  // Registros ficticios; los históricos permanecen sin autor.
  for(const [rid,zona,autor] of [[101,'VI',id(users.tecnico)],[102,'IV',id(users.jefeIV)],[103,'VI',null]])
    await db.query("INSERT INTO public.relevamientos(id,ruta,progresiva,zona,tipo,autor_id) VALUES($1,'RP30','10',$2,'calzada',$3)",[rid,zona,autor]);
  await db.exec("SELECT setval('public.relevamientos_id_seq',1000)");
  await db.exec("INSERT INTO public.catalogo_tareas(id,nombre) VALUES(1,'Prueba'); INSERT INTO public.partes_diarios(id,fecha,tarea_id,tipo_via,ruta,zona) VALUES(201,current_date,1,'rp','RP30','VI')");
  await test('A01 sin perfil no lee registros',async()=>assert.equal(await visible('sinPerfil',101),0));
  await test('A02 sin perfil no se crea admin',()=>denied(()=>as('sinPerfil',()=>db.query("INSERT INTO public.usuarios_perfil(user_id,nombre,rol,alcance_lectura,alcance_captura) VALUES($1,'intruso','admin','provincial_operativo','provincial')",[id(users.sinPerfil)]))));
  await test('A03 inactivo no lee ni conserva rol',async()=>{
    assert.equal(await visible('inactivo',101),0);
    const r=await as('inactivo',()=>db.query('SELECT public.current_user_rol() rol'));assert.equal(r.rows[0].rol,null);
  });
  for(const who of ['sinPerfil','inactivo','tecnico'])await test(who+' no consulta RPC administrativa',()=>denied(()=>as(who,()=>db.query('SELECT count(*) FROM public.admin_listar_usuarios()'))));
  await test('A04 Ambiente inserta en provincia con autoría real',async()=>{
    const a=await insert('ambiente',{zona:'IV'});const r=a.rows[0];assert.equal(r.autor_id,id(users.ambiente));assert.equal(r.contexto_trabajo,'ambiente');assert.equal(r.zona,null);
  });
  const own=(await insert('ambiente')).rows[0].id;
  const other=(await insert('ambiente2')).rows[0].id;
  await test('A05 Ambiente no ve operativa zonal',async()=>assert.equal(await visible('ambiente',101),0));
  await test('A06 Ambiente ve propios',async()=>assert.equal(await visible('ambiente',own),1));
  await test('A07 compañeros de Ambiente aislados',async()=>assert.equal(await visible('ambiente',other),0));
  for(const who of ['gerencia','jefeVI','jefeIV','tecnico','lector'])await test(who+' no ve Ambiente privado',async()=>assert.equal(await visible(who,own),0));
  await test('A17 autor edita borrador',async()=>{
    const r=await as('ambiente',()=>db.query('SELECT * FROM public.ambiente_editar($1,1,$2)',[own,{observaciones:'Prueba'}]),{commit:true});assert.equal(r.rows.length,1);
  });
  await test('A32 dos ediciones con misma versión: segunda rechazada',async()=>assert.rejects(
    ()=>as('ambiente',()=>db.query('SELECT * FROM public.ambiente_editar($1,1,$2)',[own,{observaciones:'Sobrescritura'}])),e=>e.code==='40001'));
  await test('edición Ambiente no evita control de versión con PATCH',()=>denied(()=>as('ambiente',()=>db.query("UPDATE public.relevamientos SET observaciones='ataque' WHERE id=$1",[own]))));
  await test('A19 autoría inmutable al editar',()=>denied(()=>as('ambiente',()=>db.query('UPDATE public.relevamientos SET autor_id=$1 WHERE id=$2',[id(users.admin),own]))));
  await test('no suplantación al insertar',()=>denied(()=>insert('ambiente',{autor_id:id(users.admin)})));
  await test('no autoaprobación al crear',()=>denied(()=>insert('ambiente',{estado_workflow:'aprobado'})));
  await test('no foto pública para Ambiente',()=>denied(()=>insert('ambiente',{foto_url:'https://example.invalid/public.jpg'})));
  await test('A20 capataz no modifica relevamiento ajeno',async()=>assert.equal((await as('capataz',()=>db.query("UPDATE public.relevamientos SET observaciones='ataque' WHERE id=101 RETURNING id"))).rows.length,0));
  await db.query(`INSERT INTO public.asignaciones_tarea(id,categoria,tipo,ruta,zona,asignado_por,capataz_id,fecha_prevista,relevamiento_origen_id)
    VALUES($1,'conservacion','Prueba','RP30','VI',$2,$3,current_date,101)`,[id(301),id(users.operativa),id(users.capataz)]);
  await test('capataz consulta el relevamiento de su tarea asignada',async()=>assert.equal(await visible('capataz',101),1));
  await test('capataz no cambia el origen para obtener acceso a otro registro',async()=>{
    const r=await as('capataz',()=>db.query('UPDATE public.asignaciones_tarea SET relevamiento_origen_id=102 WHERE id=$1 RETURNING id',[id(301)]));
    assert.equal(r.rows.length,0);
  });
  await test('capataz no se reasigna ni altera instrucciones de planificación',async()=>{
    const r=await as('capataz',()=>db.query("UPDATE public.asignaciones_tarea SET notas_asignacion='alteradas',asignado_por=$1 WHERE id=$2 RETURNING id",[id(users.capataz),id(301)]));
    assert.equal(r.rows.length,0);
  });
  await test('capataz no autoaprueba un cierre mediante PATCH genérico',async()=>{
    const r=await as('capataz',()=>db.query("UPDATE public.asignaciones_tarea SET estado_asignacion='completada',registro_cierre_id=101 WHERE id=$1 RETURNING id",[id(301)]));
    assert.equal(r.rows.length,0);
  });
  await test('un vínculo histórico inconsistente no revela registros de otra zona',async()=>{
    await db.query(`INSERT INTO public.asignaciones_tarea(id,categoria,tipo,ruta,zona,asignado_por,capataz_id,fecha_prevista,relevamiento_origen_id)
      VALUES($1,'conservacion','Prueba','RP30','VI',$2,$3,current_date,102)`,[id(302),id(users.operativa),id(users.capataz)]);
    assert.equal(await visible('capataz',102),0);
  });
  await test('jefe operativo conserva edición de planificación y queda auditada',async()=>{
    await as('operativa',()=>db.query("UPDATE public.asignaciones_tarea SET notas_asignacion='Instrucción válida' WHERE id=$1",[id(301)]),{commit:true});
    assert.equal(await count("SELECT count(*) n FROM dvba_privado.auditoria WHERE tabla='asignaciones_tarea' AND accion='UPDATE' AND actor_id=$1",[id(users.operativa)]),1);
  });
  await test('A21 gerencia no altera hijos de partes',()=>denied(()=>as('gerencia',()=>db.exec('INSERT INTO public.parte_fotos(parte_id,relevamiento_id,momento) VALUES(201,101,\'previa\')'))));
  await test('A22 anon no lista objetos',async()=>assert.equal(await as('anon',()=>count('SELECT count(*) n FROM storage.objects')),0));
  await test('A22 anon no carga fotos',()=>denied(()=>as('anon',()=>db.exec("INSERT INTO storage.objects(bucket_id,name) VALUES('relevamientos','ataque.jpg')"))));
  await test('A24 lector no carga fotos',()=>denied(()=>as('lector',()=>db.exec("INSERT INTO storage.objects(bucket_id,name) VALUES('relevamientos','ataque.jpg')"))));
  let foto;
  await test('autor reserva foto privada',async()=>{foto=(await as('ambiente',()=>db.query('SELECT * FROM public.ambiente_reservar_foto($1)',[own]),{commit:true})).rows[0];assert.equal(foto.bucket,'ambiente_privado');});
  await test('reserva de foto con UUID estable es idempotente',async()=>{
    const a=(await as('ambiente',()=>db.query('SELECT * FROM public.ambiente_reservar_foto($1,$2)',[own,id(950)]),{commit:true})).rows[0];
    const b=(await as('ambiente',()=>db.query('SELECT * FROM public.ambiente_reservar_foto($1,$2)',[own,id(950)]),{commit:true})).rows[0];
    assert.equal(a.id,b.id);assert.equal(a.object_path,b.object_path);
    await denied(()=>as('ambiente2',()=>db.query('SELECT * FROM public.ambiente_reservar_foto($1,$2)',[other,id(950)])));
    await denied(()=>as('ambiente',()=>db.query('SELECT * FROM public.ambiente_reservar_foto($1,$2)',[other,id(950)])));
  });
  await test('autor sube solamente ruta reservada',async()=>{
    await as('ambiente',()=>db.query('INSERT INTO storage.objects(bucket_id,name) VALUES($1,$2)',[foto.bucket,foto.object_path]),{commit:true});
    await denied(()=>as('ambiente',()=>db.exec("INSERT INTO storage.objects(bucket_id,name) VALUES('ambiente_privado','ajeno.jpg')")));
  });
  await test('A23 foto privada ajena no visible',async()=>assert.equal(await as('ambiente2',()=>count('SELECT count(*) n FROM storage.objects WHERE name=$1',[foto.object_path])),0));
  await test('A10 borrador no se comparte',()=>denied(()=>as('ambiente',()=>db.query("SELECT public.ambiente_compartir($1,2,'VI','Prueba')",[own]))));
  let version=Number((await db.query('SELECT version FROM public.relevamientos WHERE id=$1',[own])).rows[0].version);
  await test('A32 transición con versión vieja falla',async()=>assert.rejects(()=>as('ambiente',()=>db.query("SELECT public.ambiente_transicion($1,0,'presentado')",[own])),e=>e.code==='40001'));
  await test('autor presenta su registro',async()=>{version=Number((await as('ambiente',()=>db.query("SELECT public.ambiente_transicion($1,$2,'presentado') version",[own,version]),{commit:true})).rows[0].version);});
  await test('A18 presentado no se edita directamente',async()=>assert.equal((await as('ambiente',()=>db.query("UPDATE public.relevamientos SET observaciones='ataque' WHERE id=$1 RETURNING id",[own]))).rows.length,0));
  await test('A10 compartir explícitamente con VI',async()=>{await as('ambiente',()=>db.query("SELECT public.ambiente_compartir($1,$2,'VI','Revisar drenaje')",[own,version]),{commit:true});version++;});
  await test('A11 jefe destinatario ve registro y foto',async()=>{
    assert.equal(await visible('jefeVI',own),1);assert.equal(await as('jefeVI',()=>count('SELECT count(*) n FROM storage.objects WHERE name=$1',[foto.object_path])),1);
  });
  for(const who of ['jefeIV','gerencia','tecnico','lector','ambiente2'])await test('A12-14 compartición no se propaga a '+who,async()=>assert.equal(await visible(who,own),0));
  await test('A15 jefe receptor no edita original',async()=>assert.equal((await as('jefeVI',()=>db.query("UPDATE public.relevamientos SET observaciones='ataque' WHERE id=$1 RETURNING id",[own]))).rows.length,0));
  await test('A16 revocar corta registro y foto',async()=>{
    await as('ambiente',()=>db.query("SELECT public.ambiente_revocar($1,$2,'VI')",[own,version]),{commit:true});
    assert.equal(await visible('jefeVI',own),0);assert.equal(await as('jefeVI',()=>count('SELECT count(*) n FROM storage.objects WHERE name=$1',[foto.object_path])),0);
  });
  await test('A25 admin cambia alcance y genera auditoría',async()=>{
    await as('admin',()=>db.query("UPDATE public.usuarios_perfil SET alcance_captura='provincial' WHERE user_id=$1",[id(users.tecnico)]),{commit:true});
    assert.ok(await count("SELECT count(*) n FROM dvba_privado.auditoria WHERE tabla='usuarios_perfil' AND actor_id=$1",[id(users.admin)]));
  });
  await test('A26 técnico no aprueba por API directa',()=>denied(()=>as('tecnico',()=>db.exec("UPDATE public.relevamientos SET estado_workflow='aprobado' WHERE id=101"))));
  await test('A34 histórico sin autor no es editable por técnico',async()=>assert.equal((await as('tecnico',()=>db.exec("UPDATE public.relevamientos SET observaciones='ataque' WHERE id=103 RETURNING id")))[0].rows.length,0));
  await test('A35 gerencia mantiene lectura zonal provincial',async()=>{assert.equal(await visible('gerencia',101),1);assert.equal(await visible('gerencia',102),1);});
  await test('A38 Ambiente no ve partes ni tareas operativas',async()=>assert.equal(await as('ambiente',()=>count('SELECT count(*) n FROM public.partes_diarios')),0));
  await test('INSERT RETURNING de parte propio sigue funcionando',async()=>{
    const r=await as('tecnico',()=>db.query("INSERT INTO public.partes_diarios(fecha,tarea_id,tipo_via,ruta,zona) VALUES(current_date,1,'rp','RP30','VI') RETURNING id,autor_id"));
    assert.equal(r.rows.length,1);assert.equal(r.rows[0].autor_id,id(users.tecnico));
  });
  await test('no revocar al último administrador activo',()=>denied(()=>as('admin',()=>db.query('UPDATE public.usuarios_perfil SET activo=false WHERE user_id=$1',[id(users.admin)]))));
  await test('A36 jefe no archiva zona ajena',()=>denied(()=>as('jefeIV',()=>db.query("SELECT public.soft_delete_relevamiento(101,'Motivo de prueba completo')"))));
  await db.exec("INSERT INTO public.relevamientos(id,ruta,progresiva,zona) VALUES(104,'RP30','10',NULL)");
  await test('jefe no archiva zona NULL por guard ambiguo',()=>denied(()=>as('jefeIV',()=>db.query("SELECT public.soft_delete_relevamiento(104,'Motivo de prueba completo')"))));
  for(const who of ['sinPerfil','inactivo','ambiente','gerencia'])await test(who+' no archiva por RPC',()=>denied(()=>as(who,()=>db.query("SELECT public.soft_delete_relevamiento(101,'Motivo de prueba completo')"))));
  await test('A37 admin archiva y restaura sin perder historial',async()=>{
    await as('admin',()=>db.query("SELECT public.soft_delete_relevamiento(101,'Motivo de prueba completo')"),{commit:true});
    assert.equal(await visible('tecnico',101),0);
    await as('admin',()=>db.query("SELECT public.restaurar_registro('relevamientos',101,'Restauración verificada')"),{commit:true});
    assert.equal(await visible('tecnico',101),1);
    assert.ok(await count("SELECT count(*) n FROM dvba_privado.auditoria WHERE tabla='relevamientos' AND clave='101'"));
  });
  await test('un perfil propio no puede ampliarse alcances',async()=>assert.equal((await as('tecnico',()=>db.query("UPDATE public.usuarios_perfil SET alcance_captura='provincial' WHERE user_id=$1 RETURNING user_id",[id(users.tecnico)]))).rows.length,0));
  await test('desactivación corta permisos de inmediato en siguiente operación',async()=>{
    await as('admin',()=>db.query('UPDATE public.usuarios_perfil SET activo=false WHERE user_id=$1',[id(users.ambiente2)]),{commit:true});
    assert.equal(await visible('ambiente2',other),0);
    await denied(()=>insert('ambiente2'));
    await as('admin',()=>db.query('UPDATE public.usuarios_perfil SET activo=true WHERE user_id=$1',[id(users.ambiente2)]),{commit:true});
  });
  await test('restricciones de configuración impiden Ambiente provincial lector',async()=>assert.rejects(
    ()=>as('admin',()=>db.query("UPDATE public.usuarios_perfil SET alcance_lectura='provincial_operativo' WHERE user_id=$1",[id(users.ambiente)])),e=>e.code==='23514'));
  await test('A29 crear con UUID estable es idempotente',async()=>{
    const captura=id(900),payload={lat:-35,lng:-59,observaciones:'Captura original'};
    const a=await as('ambiente',()=>db.query('SELECT * FROM public.ambiente_crear($1,$2)',[captura,payload]),{commit:true});
    const b=await as('ambiente',()=>db.query('SELECT * FROM public.ambiente_crear($1,$2)',[captura,{...payload,observaciones:'No reemplazar'}]),{commit:true});
    assert.equal(a.rows[0].id,b.rows[0].id);assert.equal(b.rows[0].observaciones,'Captura original');
    await denied(()=>as('ambiente2',()=>db.query('SELECT * FROM public.ambiente_crear($1,$2)',[captura,payload])));
  });
  await test('RPC crear rechaza campos protegidos',()=>denied(()=>as('ambiente',()=>db.query('SELECT * FROM public.ambiente_crear($1,$2)',[id(901),{lat:-35,lng:-59,autor_id:id(users.admin)}]))));
  await test('RPC editar rechaza cambio de autor',()=>denied(()=>as('ambiente',()=>db.query('SELECT * FROM public.ambiente_editar($1,1,$2)',[other,{autor_id:id(users.ambiente)}]))));
  await test('transición no acepta versión NULL',async()=>assert.rejects(()=>as('ambiente',()=>db.query("SELECT public.ambiente_transicion($1,NULL,'cerrado')",[own])),e=>e.code==='40001'));
  await test('no borrado directo incluso como admin de aplicación',()=>denied(()=>as('admin',()=>db.exec('DELETE FROM public.relevamientos WHERE id=101'))));
  await test('no truncate con rol de aplicación',()=>denied(()=>as('admin',()=>db.exec('TRUNCATE public.relevamientos CASCADE'))));
  await test('private bucket y límites explícitos',async()=>{
    const r=(await db.query("SELECT * FROM storage.buckets WHERE id='ambiente_privado'")).rows[0];assert.equal(r.public,false);assert.equal(Number(r.file_size_limit),10485760);
  });
  await test('funciones nuevas no ejecutables por anon',async()=>assert.equal(await count("SELECT count(*) n FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='dvba_privado' AND has_function_privilege('anon',p.oid,'EXECUTE')"),0));
  await test('todas las funciones privilegiadas nuevas fijan search_path',async()=>assert.equal(await count("SELECT count(*) n FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='dvba_privado' AND p.prosecdef AND p.proconfig IS NULL"),0));
  await test('envoltorios públicos nuevos son INVOKER',async()=>assert.equal(await count("SELECT count(*) n FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.proname LIKE 'ambiente_%' AND p.prosecdef"),0));
  console.log(`\n${passed} pruebas PostgreSQL aprobadas. Sin conexión a producción.`);
} catch(e) {console.error('FALLO:',e.message,'SQLSTATE:',e.code??'n/a',e.where??'');process.exitCode=1;}
finally {await db.close();}
