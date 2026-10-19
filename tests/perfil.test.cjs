const test=require('node:test'),assert=require('node:assert/strict'),vm=require('node:vm'),fs=require('node:fs'),path=require('node:path');
const source=fs.readFileSync(path.join(__dirname,'../datos/perfil.js'),'utf8');
function perfil(){
  const storage=new Map(),ctx={console:{log(){},warn(){}}};
  ctx.localStorage={getItem:k=>storage.get(k)||null,setItem:(k,v)=>storage.set(k,v),removeItem:k=>storage.delete(k)};ctx.window=ctx;
  vm.createContext(ctx);vm.runInContext(source,ctx);return {api:ctx.DVBA_PERFIL,storage};
}
const cliente=(user,data,error)=>({auth:{getUser:async()=>({data:{user:{id:user}}})},from:()=>({select(){return this;},eq(){return this;},async maybeSingle(){return {data,error};}})});
test('perfil ausente no inventa técnico activo ni zona VI',async()=>{
  const {api}=perfil();assert.equal(await api.cargar(cliente('A',null)),null);assert.equal(api.rol(),null);assert.equal(api.zonaActual(),null);
});
test('error de consulta no conserva permisos anteriores',async()=>{
  const {api,storage}=perfil();await api.cargar(cliente('A',{user_id:'A',rol:'admin',activo:true}));
  await api.cargar(cliente('A',null,{code:'42501'}));assert.equal(api.rol(),null);assert.equal(storage.has('dvba_perfil'),false);
});
test('cambiar de cuenta no devuelve el perfil anterior cacheado',async()=>{
  const {api}=perfil();await api.cargar(cliente('A',{user_id:'A',rol:'admin',activo:true}));
  await api.cargar(cliente('B',{user_id:'B',rol:'tecnico',activo:true,zona:'IV'}));assert.equal(api.rol(),'tecnico');assert.equal(api.zona(),'IV');
});
test('perfil inactivo o de otra cuenta se rechaza',async()=>{
  const {api}=perfil();for(const data of [{user_id:'A',activo:false},{user_id:'B',activo:true}])assert.equal(await api.cargar(cliente('A',data)),null);
});
test('Ambiente conserva alcances y no hereda VI como ubicación',async()=>{
  const {api}=perfil();await api.cargar(cliente('A',{user_id:'A',rol:'tecnico',activo:true,area_codigo:'ambiente',alcance_captura:'provincial'}));
  assert.equal(api.get().area_codigo,'ambiente');assert.equal(api.zonaActual(),null);
});
test('un logout impide que una lectura anterior repueble la caché',async()=>{
  const {api}=perfil();let resolver;
  const supa=cliente('A',{user_id:'A',rol:'admin',activo:true});supa.auth.getUser=()=>new Promise(r=>resolver=r);
  const carga=api.cargar(supa);api.limpiar();resolver({data:{user:{id:'A'}}});assert.equal(await carga,null);assert.equal(api.get(),null);
});
