const test=require('node:test'),assert=require('node:assert/strict'),vm=require('node:vm'),fs=require('node:fs'),path=require('node:path');
const ctx={};vm.createContext(ctx);vm.runInContext(fs.readFileSync(path.join(__dirname,'../datos/ambiente.js'),'utf8'),ctx);
function cliente(){
  const state={user:'A',active:true,role:'tecnico',area:'ambiente',items:[],calls:[],removed:[],objects:new Map()};let n=0;
  const api=ctx.DVBA_AMBIENTE.crear({
    auth:{getUser:async()=>({data:{user:{id:state.user}}})},
    from(table){return {select(){return this;},eq(){return this;},async maybeSingle(){return {data:{user_id:state.user,activo:state.active,rol:state.role,area_codigo:state.area,contexto_captura:'ambiente',alcance_lectura:'propios',alcance_captura:'provincial'}};}};},
    async rpc(name,args){state.calls.push({name,args});
      if(state.error)return {error:state.error};
      if(name==='ambiente_crear')return {data:{id:1,autor_id:'A',contexto_trabajo:'ambiente'}};
      if(name==='ambiente_reservar_foto')return {data:{bucket:state.bucket||'ambiente_privado',object_path:'A/'+args.p_foto+'.jpg'}};
      return {data:2};
    },
    storage:{from(bucket){assert.equal(bucket,'ambiente_privado');return {
      async upload(key,blob,opts){assert.equal(opts.upsert,false);if(state.uploadError)return {error:state.uploadError};if(state.objects.has(key))return {error:{statusCode:'409'}};state.objects.set(key,blob);return {};},
      async download(key){return {data:state.objects.get(key)};}
    };}}
  },'A',{uuid:()=>String(++n),pendientes:{async guardar(p){if(state.quota)throw new Error('QuotaExceededError');state.items=state.items.filter(x=>x.captura!==p.captura);state.items.push(p);},async listar(user){return state.items.filter(p=>p.usuario===user);},async quitar(id){state.removed.push(id);state.items=state.items.filter(p=>p.captura!==id);}}});
  return {api,state};
}
const foto=()=>new Blob(['foto de prueba'],{type:'image/jpeg'});
test('registro y foto se confirman antes de retirar el pendiente',async()=>{
  const {api,state}=cliente(),p=await api.guardar({lat:-35,lng:-59},foto());
  assert.equal(state.calls.length,0);assert.equal(state.items.length,1);
  await api.enviar(p);assert.equal(state.items.length,0);assert.equal(state.objects.size,1);
  assert.equal(state.calls[0].args.p_captura,p.captura);assert.equal(state.calls[1].args.p_foto,p.fotoId);
});
test('otra cuenta no envía una captura ni llama RPC',async()=>{
  const {api,state}=cliente();const p=await api.guardar({},foto());p.usuario='B';
  await assert.rejects(()=>api.enviar(p),/otra cuenta/);assert.equal(state.calls.length,0);assert.equal(state.items.length,1);
});
test('cambio de sesión no usa pendientes de la cuenta anterior',async()=>{
  const {api,state}=cliente(),p=await api.guardar({},foto());state.user='B';
  await assert.rejects(()=>api.enviar(p),/cuenta cambió/);assert.equal(state.calls.length,0);assert.equal(state.items.length,1);
});
for(const [name,change] of [['inactiva',{active:false}],['admin sin perfil Ambiente',{role:'admin'}],['técnico zonal',{area:'vialidad'}]])
  test(name+' no sincroniza',async()=>{const {api,state}=cliente(),p=await api.guardar({},foto());Object.assign(state,change);await assert.rejects(()=>api.enviar(p),/habilitada/);assert.equal(state.calls.length,0);assert.equal(state.items.length,1);});
test('fallo de cuota no anuncia guardado ni inicia red',async()=>{
  const {api,state}=cliente();state.quota=true;await assert.rejects(()=>api.guardar({},foto()),/Quota/);assert.equal(state.items.length,0);assert.equal(state.calls.length,0);
});
test('fallo de subida conserva blob y UUID para reintentar',async()=>{
  const {api,state}=cliente(),p=await api.guardar({},foto());state.uploadError={statusCode:403};
  await assert.rejects(()=>api.enviar(p));assert.equal(state.items[0].foto,p.foto);state.uploadError=null;
  await api.enviar(p);assert.equal(state.calls[0].args.p_captura,state.calls[2].args.p_captura);assert.equal(state.calls[1].args.p_foto,state.calls[3].args.p_foto);
});
test('respuesta perdida se recupera verificando bytes sin reemplazar la foto',async()=>{
  const {api,state}=cliente(),p=await api.guardar({},foto());state.objects.set('A/'+p.fotoId+'.jpg',p.foto);
  await api.enviar(p);assert.equal(state.items.length,0);assert.equal(state.objects.size,1);
});
test('conflicto con otra foto conserva pendiente',async()=>{
  const {api,state}=cliente(),p=await api.guardar({},foto());state.objects.set('A/'+p.fotoId+'.jpg',new Blob(['distinta']));
  await assert.rejects(()=>api.enviar(p),/no coincide/);assert.equal(state.items.length,1);
});
test('destino público se rechaza',async()=>{
  const {api,state}=cliente(),p=await api.guardar({},foto());state.bucket='relevamientos';
  await assert.rejects(()=>api.enviar(p),/privado/);assert.equal(state.items.length,1);assert.equal(state.objects.size,0);
});
test('compartir solo se ejecuta por acción explícita y con versión',async()=>{
  const {api,state}=cliente();await api.guardar({},null);assert.equal(state.calls.length,0);
  await api.compartir(1,4,'VI','Revisión');assert.equal(state.calls[0].name,'ambiente_compartir');assert.equal(state.calls[0].args.p_version,4);
});
test('no presenta un registro cuya foto sigue pendiente',async()=>{
  const {api,state}=cliente(),p=await api.guardar({},foto());state.uploadError={statusCode:403};
  await assert.rejects(()=>api.enviar(p));
  await assert.rejects(()=>api.transicion(1,1,'presentado'),/fotos pendientes/);
  assert.equal(state.calls.some(c=>c.name==='ambiente_transicion'),false);
});
test('la lista de pendientes solo incluye los de su cuenta',async()=>{
  const {api,state}=cliente();await api.guardar({},null);state.items.push({captura:'otra',usuario:'B'});
  assert.equal((await api.pendientes()).length,1);
});
