import {PGlite} from '@electric-sql/pglite';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {loadBaseline} from './fixture.mjs';
const db=new PGlite(),id=n=>'30000000-0000-4000-8000-'+String(n).padStart(12,'0');
const cuentas={admin:1,gerencia:2,jefe:3,jefeIV:4,lector:5,tecnico:6,capataz:7,inactivo:8,sinPerfil:9,ambiente:10};
let passed=0;
async function test(name,fn){await fn();passed++;console.log('OK '+name);}
async function as(who,sql,args=[],commit=false){await db.exec('BEGIN');try{
 const role=who==='anon'?'anon':'authenticated';
 await db.query("SELECT set_config('request.jwt.claims',$1,true)",[JSON.stringify({role,sub:who==='anon'?null:id(cuentas[who])})]);
 await db.exec('SET LOCAL ROLE '+role);const r=await db.query(sql,args);await db.exec(commit?'COMMIT':'ROLLBACK');return r.rows;
}catch(e){await db.exec('ROLLBACK');throw e;}}
const denied=fn=>assert.rejects(fn,e=>['42501','P0001','23514'].includes(e.code));
try{
 await loadBaseline(db);
 for(const [who,n] of Object.entries(cuentas))await db.query('INSERT INTO auth.users(id,email) VALUES($1,$2)',[id(n),who+'@example.invalid']);
 for(const [who,rol,zona,activo] of [['admin','admin',null,true],['gerencia','gerencia',null,true],['jefe','jefe_zona','VI',true],['jefeIV','jefe_tecnica','IV',true],['lector','jefe_administrativa','VI',true],['tecnico','tecnico','VI',true],['capataz','capataz','VI',true],['inactivo','admin',null,false],['ambiente','tecnico','VI',true]])
 await db.query('INSERT INTO public.usuarios_perfil(user_id,nombre,rol,zona,activo) VALUES($1,$2,$3,$4,$5)',[id(cuentas[who]),who,rol,zona,activo]);
 await db.exec("INSERT INTO public.relevamientos(id,ruta,progresiva,zona,tipo,foto_url) VALUES(101,'RP30','1','VI','calzada','https://txjlfpffyzuhdqtfhlmc.supabase.co/storage/v1/object/public/relevamientos/ajena.jpg'),(102,'RP30','2','IV','calzada',NULL)");
 await db.exec(await readFile(new URL('../../supabase/migrations/20261019194627_piloto_ambiente_compatible.sql',import.meta.url),'utf8'));
 await db.exec("INSERT INTO public.catalogo_tareas(id,nombre) VALUES(1,'Tarea ficticia')");
 await db.exec("INSERT INTO public.partes_diarios(id,fecha,tarea_id,tipo_via,ruta,zona) VALUES(201,current_date,1,'rp','RP30','VI')");
 await db.exec("INSERT INTO storage.objects(bucket_id,name,owner_id) VALUES('relevamientos','ajena.jpg','otro-autor')");
 await as('admin',"UPDATE public.usuarios_perfil SET rol='tecnico',zona=NULL,area_codigo='ambiente',contexto_captura='ambiente',alcance_lectura='propios',alcance_captura='provincial' WHERE user_id=$1",[id(cuentas.ambiente)],true);
 await db.exec(await readFile(new URL('../../supabase/migrations/20261020103210_cerrar_storage_publico_y_solicitudes.sql',import.meta.url),'utf8'));
 for(const who of ['anon','gerencia','lector','inactivo','sinPerfil','ambiente'])await test(who+' no sube fotos zonales',()=>denied(()=>as(who,"INSERT INTO storage.objects(bucket_id,name,owner_id) VALUES('relevamientos','nueva.jpg',$1)",[who==='anon'?null:id(cuentas[who])])));
 for(const who of ['admin','jefe','tecnico','capataz'])await test(who+' conserva subida autenticada propia',async()=>assert.equal((await as(who,"INSERT INTO storage.objects(bucket_id,name,owner_id) VALUES('relevamientos','nueva.jpg',$1) RETURNING id",[id(cuentas[who])])).length,1));
 for(const who of ['gerencia','lector','tecnico','jefeIV'])await test(who+' no altera foto ajena fuera de permiso',async()=>assert.equal((await as(who,"UPDATE storage.objects SET metadata='{}' WHERE name='ajena.jpg' RETURNING id")).length,0));
 await test('jefe conserva sellado de una foto vinculada a su zona',async()=>assert.equal((await as('jefe',"UPDATE storage.objects SET metadata='{}' WHERE name='ajena.jpg' RETURNING id")).length,1));
 for(const who of ['gerencia','jefe','tecnico','capataz','lector'])await test(who+' no borra archivos',async()=>assert.equal((await as(who,"DELETE FROM storage.objects WHERE name='ajena.jpg' RETURNING id")).length,0));
 await test('admin conserva borrado de archivo',async()=>assert.equal((await as('admin',"DELETE FROM storage.objects WHERE name='ajena.jpg' RETURNING id")).length,1));
 for(const who of ['jefe','gerencia','lector'])await test(who+' no archiva mediante RPC',()=>denied(()=>as(who,"SELECT public.soft_delete_relevamiento(101,'Motivo de prueba suficientemente largo')")));
 await test('jefe no oculta un registro mediante PATCH directo',()=>denied(()=>as('jefe',"UPDATE public.relevamientos SET borrado_en=now() WHERE id=101")));
 await test('admin conserva archivo con motivo',async()=>assert.equal((await as('admin',"SELECT public.soft_delete_relevamiento(101,'Motivo de prueba suficientemente largo') id"))[0].id,101));
 const solicitud=(who,target=101,zona='VI',mensaje='Registro duplicado para revisar')=>as(who,"INSERT INTO public.comentarios_zona(target_tabla,target_id,target_zona,tipo,autor_id,autor_rol,mensaje) VALUES('relevamientos',$1,$2,'eliminar',$3,$4,$5) RETURNING id",[target,zona,id(cuentas[who]),who==='jefe'?'jefe_zona':who==='lector'?'jefe_administrativa':who==='jefeIV'?'jefe_tecnica':who==='ambiente'?'tecnico':who,mensaje],true);
 let pedido;
 await test('jefe solicita con motivo sin borrar el registro',async()=>{pedido=(await solicitud('jefe'))[0].id;assert.equal((await as('jefe','SELECT id FROM public.relevamientos WHERE id=101')).length,1);});
 await test('gerencia solicita sin eliminar',async()=>assert.equal((await solicitud('gerencia')).length,1));
 await test('jefe de consulta también puede solicitar',async()=>assert.equal((await solicitud('lector')).length,1));
 await test('no se permite motivo insuficiente',()=>denied(()=>solicitud('jefe',101,'VI','corto')));
 await test('no se falsifica zona del destino',()=>denied(()=>solicitud('jefe',102,'VI')));
 await test('jefe no solicita sobre zona ajena',()=>denied(()=>solicitud('jefeIV',101,'VI')));
 await test('Ambiente no solicita borrar operativa ajena',()=>denied(()=>solicitud('ambiente')));
 await test('solicitudes llegan al listado administrativo',async()=>assert.ok((await as('admin','SELECT id FROM public.get_solicitudes_admin()')).some(r=>r.id===pedido)));
 await test('jefe no resuelve su solicitud',async()=>assert.equal((await as('jefe',"UPDATE public.comentarios_zona SET estado='resuelto' WHERE id=$1 RETURNING id",[pedido])).length,0));
 await test('admin resuelve y deja respuesta',async()=>assert.equal((await as('admin',"UPDATE public.comentarios_zona SET estado='resuelto',respuesta='Revisado por administrador',respondido_por=$1,respondido_en=now() WHERE id=$2 RETURNING id",[id(cuentas.admin),pedido])).length,1));
 await test('borrado físico permanece reservado a admin',async()=>{assert.equal((await as('jefe','DELETE FROM public.relevamientos WHERE id=101 RETURNING id')).length,0);assert.equal((await as('admin','DELETE FROM public.relevamientos WHERE id=101 RETURNING id')).length,1);});
 await test('bucket zonal limita tamaño y formato',async()=>{const b=(await db.query("SELECT * FROM storage.buckets WHERE id='relevamientos'")).rows[0];assert.equal(Number(b.file_size_limit),10485760);assert.ok(b.allowed_mime_types.includes('image/jpeg'));});
 await test('Ambiente conserva captura y foto privadas tras el cierre',async()=>{
  const r=(await as('ambiente','SELECT * FROM public.ambiente_crear($1,$2)',[id(50),{lat:-35,lng:-59,ruta:'RP30'}],true))[0];
  const f=(await as('ambiente','SELECT * FROM public.ambiente_reservar_foto($1,$2)',[r.id,id(51)],true))[0];
  assert.equal((await as('ambiente','INSERT INTO storage.objects(bucket_id,name,owner_id) VALUES($1,$2,$3) RETURNING id',[f.bucket,f.object_path,id(cuentas.ambiente)])).length,1);
  assert.equal((await as('gerencia','SELECT id FROM public.relevamientos WHERE id=$1',[r.id])).length,0);
 });
 console.log(passed+' pruebas del cierre de seguridad aprobadas. Sin conexión remota.');
}catch(e){console.error(e.message,e.code,e.where);process.exitCode=1;}finally{await db.close();}
