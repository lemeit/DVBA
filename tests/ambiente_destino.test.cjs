const test=require('node:test'),assert=require('node:assert/strict'),vm=require('node:vm'),fs=require('node:fs'),path=require('node:path');
const source=fs.readFileSync(path.join(__dirname,'../datos/auth.js'),'utf8');
function auth(perfil){
  const session={user:{id:'A',email:'test@example.invalid'},access_token:'ficticio',refresh_token:'ficticio',expires_at:Math.floor(Date.now()/1000)+3600};
  const state={destino:null};const ctx={console:{log(){},warn(){}},navigator:{onLine:true},
    localStorage:{getItem:()=>JSON.stringify(session)},
    fetch:async()=>({ok:true,json:async()=>[perfil]}),location:{replace:url=>{state.destino=url;}}};
  ctx.window=ctx;vm.createContext(ctx);vm.runInContext(source,ctx);return {api:ctx.dvbaAuth,state};
}
test('solo deriva Ambiente habilitado hacia su espacio propio',async()=>{
  const {api,state}=auth({user_id:'A',rol:'tecnico',activo:true,area_codigo:'ambiente',alcance_lectura:'propios'});
  assert.equal(await api.abrirAmbiente(),true);assert.equal(state.destino,'ambiente.html');
});
for(const [name,p] of [['admin',{rol:'admin',area_codigo:'ambiente'}],['inactivo',{rol:'tecnico',activo:false,area_codigo:'ambiente'}],['zonal',{rol:'tecnico',area_codigo:'vialidad'}],['cuenta ajena',{user_id:'B',rol:'tecnico',area_codigo:'ambiente'}]])
  test(name+' no se deriva por una caché o correo',async()=>{
    const {api,state}=auth({user_id:'A',activo:true,alcance_lectura:'propios',...p});assert.equal(await api.abrirAmbiente(),false);assert.equal(state.destino,null);
  });
