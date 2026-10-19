import {PGlite} from '@electric-sql/pglite';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {loadBaseline} from './fixture.mjs';
const db=new PGlite(),id=n=>'10000000-0000-4000-8000-'+String(n).padStart(12,'0');let passed=0;
const users={admin:1,env:2,env2:3,jefe:4,gerencia:5,capataz:6,tecnico:7,sinPerfil:8,inactivo:9};
async function as(who,sql,args=[],commit=false){await db.exec('BEGIN');try{
 await db.query("SELECT set_config('request.jwt.claims',$1,true)",[JSON.stringify({sub:id(users[who]),role:'authenticated'})]);
 await db.exec('SET LOCAL ROLE authenticated');const r=await db.query(sql,args);await db.exec(commit?'COMMIT':'ROLLBACK');return r.rows;
}catch(e){await db.exec('ROLLBACK');throw e;}}
async function test(name,fn){await fn();passed++;console.log('OK '+name);}
const visible=async(who,rid)=>(await as(who,'SELECT id FROM public.relevamientos WHERE id=$1',[rid])).length;
const denied=fn=>assert.rejects(fn,e=>['42501','23514','P0001'].includes(e.code));
try{
await loadBaseline(db);
await db.exec("INSERT INTO public.partidos_zona(partido_numero,nombre,zona) VALUES(93,'Saladillo','VI'),(54,'Junín','IV')");
for(const [who,n] of Object.entries(users))await db.query('INSERT INTO auth.users(id,email) VALUES($1,$2)',[id(n),who+'@example.invalid']);
for(const [who,rol,zona,activo] of [['admin','admin',null,true],['env','admin',null,true],['env2','tecnico','VI',true],['jefe','jefe_zona','VI',true],['gerencia','gerencia',null,true],['capataz','capataz','VI',true],['tecnico','tecnico','VI',true],['inactivo','admin',null,false]])
 await db.query('INSERT INTO public.usuarios_perfil(user_id,nombre,rol,zona,activo) VALUES($1,$2,$3,$4,$5)',[id(users[who]),who,rol,zona,activo]);
await db.exec("INSERT INTO public.relevamientos(id,ruta,progresiva,zona,tipo) VALUES(101,'RP30','10','VI','calzada'),(102,'RP30','20','IV','calzada');SELECT setval('public.relevamientos_id_seq',1000)");
await db.exec(await readFile(new URL('../../supabase/migrations/20261019194627_piloto_ambiente_compatible.sql',import.meta.url),'utf8'));
for(const who of ['env','env2'])await as('admin',"UPDATE public.usuarios_perfil SET rol='tecnico',zona=NULL,area_codigo='ambiente',contexto_captura='ambiente',alcance_lectura='propios',alcance_captura='provincial' WHERE user_id=$1",[id(users[who])],true);
await test('Ambiente no consulta operativa VI ni IV',async()=>{assert.equal(await visible('env',101),0);assert.equal(await visible('env',102),0);});
const create=async(who,n,partido)=>(await as(who,'SELECT * FROM public.ambiente_crear($1,$2)',[id(n),{lat:-35,lng:-59,partido,observaciones:'Prueba privada'}],true))[0];
const a=await create('env',301,'Saladillo'),b=await create('env',302,'Junín'),c=await create('env2',303,'Saladillo');
await test('Ambiente captura en IV y VI con autoría propia',async()=>{assert.equal(a.zona,'VI');assert.equal(b.zona,'IV');assert.equal(b.autor_id,id(users.env));assert.equal(await visible('env',b.id),1);});
await test('Ambiente no consulta otro integrante del área',async()=>assert.equal(await visible('env',c.id),0));
await test('gerencia y jefe no consultan Ambiente privado',async()=>{assert.equal(await visible('gerencia',a.id),0);assert.equal(await visible('jefe',a.id),0);});
await test('técnico conserva lectura y captura zonal',async()=>{
 assert.equal(await visible('tecnico',101),1);
 const r=await as('tecnico',"INSERT INTO public.relevamientos(ruta,progresiva,zona,tipo) VALUES('RP30','1','VI','calzada') RETURNING id,contexto_trabajo");assert.equal(r[0].contexto_trabajo,'zonal');
});
await test('capataz conserva su cierre zonal heredado',async()=>assert.equal((await as('capataz',"UPDATE public.relevamientos SET estado_workflow='aprobado' WHERE id=101 RETURNING id")).length,1));
await test('Ambiente no usa inserción ni PATCH zonales',async()=>{
 await denied(()=>as('env',"INSERT INTO public.relevamientos(ruta,progresiva,zona,tipo) VALUES('RP30','1','VI','calzada')"));
 assert.equal((await as('env',"UPDATE public.relevamientos SET tipo='otro' WHERE id=101 RETURNING id")).length,0);
});
await test('las fotos públicas zonales conservan su flujo',async()=>assert.equal((await as('tecnico',"INSERT INTO storage.objects(bucket_id,name) VALUES('relevamientos','piloto-zonal.jpg') RETURNING id")).length,1));
await test('Ambiente no carga ni borra en bucket público',async()=>{
 await denied(()=>as('env',"INSERT INTO storage.objects(bucket_id,name) VALUES('relevamientos','piloto-env.jpg')"));
});
const f=(await as('env','SELECT * FROM public.ambiente_reservar_foto($1,$2)',[a.id,id(401)],true))[0];
await test('reserva idempotente y objeto privado',async()=>{
 const again=(await as('env','SELECT * FROM public.ambiente_reservar_foto($1,$2)',[a.id,id(401)]))[0];assert.equal(f.object_path,again.object_path);
 await as('env','INSERT INTO storage.objects(bucket_id,name) VALUES($1,$2)',[f.bucket,f.object_path],true);
 assert.equal((await as('env','SELECT id FROM storage.objects WHERE name=$1',[f.object_path])).length,1);
 assert.equal((await as('env2','SELECT id FROM storage.objects WHERE name=$1',[f.object_path])).length,0);
});
let version=(await as('env',"SELECT public.ambiente_transicion($1,1,'presentado') v",[a.id],true))[0].v;
await as('env',"SELECT public.ambiente_compartir($1,$2,'VI','Prueba explícita')",[a.id,version],true);version++;
await test('compartir permite al jefe y no a gerencia',async()=>{assert.equal(await visible('jefe',a.id),1);assert.equal(await visible('gerencia',a.id),0);});
await test('jefe no edita ni archiva el original compartido',async()=>{
 assert.equal((await as('jefe',"UPDATE public.relevamientos SET observaciones='otro' WHERE id=$1 RETURNING id",[a.id])).length,0);
 await denied(()=>as('jefe',"SELECT public.soft_delete_relevamiento($1,'Prueba de rechazo')",[a.id]));
});
await as('env',"SELECT public.ambiente_revocar($1,$2,'VI')",[a.id,version],true);
await test('revocar corta registro y foto al destinatario',async()=>{assert.equal(await visible('jefe',a.id),0);assert.equal((await as('jefe','SELECT id FROM storage.objects WHERE name=$1',[f.object_path])).length,0);});
await test('Ambiente no ve partes ni planificación',async()=>{assert.equal((await as('env','SELECT * FROM public.partes_diarios')).length,0);assert.equal((await as('env','SELECT * FROM public.asignaciones_tarea')).length,0);});
await test('sin perfil no se autoasigna admin',()=>denied(()=>as('sinPerfil',"INSERT INTO public.usuarios_perfil(user_id,nombre,rol,alcance_lectura,alcance_captura) VALUES($1,'Intruso','admin','provincial_operativo','provincial')",[id(users.sinPerfil)])));
await test('sin perfil e inactivo no usan RPC administrativa',async()=>{for(const who of ['sinPerfil','inactivo','env'])await denied(()=>as(who,'SELECT * FROM public.admin_listar_usuarios()'));});
await test('Ambiente no filtra conteos privilegiados',async()=>assert.deepEqual((await as('env','SELECT public.comentarios_contadores() x'))[0].x,{}));
await test('perfil Ambiente se modifica sólo por administrador',async()=>assert.equal((await as('env',"UPDATE public.usuarios_perfil SET rol='admin' WHERE user_id=$1 RETURNING user_id",[id(users.env)])).length,0));
await test('las tablas zonales conservan sus policies originales',async()=>assert.ok((await db.query("SELECT count(*)::int n FROM pg_policies WHERE policyname IN ('asig_update','relev_update_zonal','partes_insert_zonal')")).rows[0].n>=2));
console.log(`${passed} pruebas del piloto compatibles aprobadas.`);
}catch(e){console.error(e.message,e.code,e.where);process.exitCode=1;}finally{await db.close();}
