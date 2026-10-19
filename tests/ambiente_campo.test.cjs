const test=require('node:test'),assert=require('node:assert/strict'),vm=require('node:vm'),fs=require('node:fs'),path=require('node:path');
const source=fs.readFileSync(path.join(__dirname,'../datos/ambiente_campo.js'),'utf8');
function app(){
 const state={id:'A',items:[],sent:[],online:true,env:true};let n=0;const storage=new Map();
 const api={
  async guardar(datos,foto){const p={captura:String(++n),fotoId:'foto-'+n,usuario:'A',datos,foto,creada:new Date().toISOString()};state.items.push(p);return p;},
  async pendientes(){return state.items;},async enviar(p){if(state.fail)throw new Error('Sin conexión');state.sent.push(p);state.items=state.items.filter(x=>x!==p);return {id:101};},
  async descartar(id){state.items=state.items.filter(p=>p.captura!==id);}
 };
 const perfil=()=>({user_id:state.id,activo:true,rol:'tecnico',area_codigo:state.env?'ambiente':'vialidad'});
 const ctx={console,URL:{createObjectURL:()=> 'blob:privada',revokeObjectURL(){}},navigator:{get onLine(){return state.online;}},
  localStorage:{getItem:k=>storage.get(k)||null,setItem:(k,v)=>storage.set(k,v),removeItem:k=>storage.delete(k)},
  dvbaAuth:{user:()=>({id:state.id}),SUPA_URL:'https://example.invalid',SUPA_KEY:'publica',fetchAuth:async()=>({ok:true,json:async()=>[perfil()]})},
  fetch:async()=>({blob:async()=>new Blob(['foto'],{type:'image/jpeg'})}),supabase:{createClient:()=>({})},DVBA_AMBIENTE:{crear:()=>api}};
 ctx.window=ctx;vm.createContext(ctx);vm.runInContext(source,ctx);return {adapter:ctx.DVBA_CAMPO_AMBIENTE,state};
}
test('ambos modos usan captura privada sin agregar interfaces',async()=>{
 const {adapter,state}=app();await adapter.preparar();const r=await adapter.guardar({ruta:'RP30',lat:-35,lng:-59,foto_url:'no enviar',zona:'VI'},'data:foto');
 assert.equal(r.cloud,true);assert.equal(r.id,101);assert.equal(state.sent[0].datos.ruta,'RP30');assert.equal('foto_url' in state.sent[0].datos,false);assert.equal('zona' in state.sent[0].datos,false);assert.equal(adapter.pendientes().length,0);
});
test('la cola conserva la foto y reintenta con el mismo identificador',async()=>{
 const {adapter,state}=app();state.fail=true;await adapter.preparar();const r=await adapter.guardar({lat:-35,lng:-59},'foto');assert.equal(r.cloud,false);
 const id=adapter.pendientes()[0].id;assert.ok(adapter.pendientes()[0].foto);state.fail=false;const sync=await adapter.sincronizar();assert.equal(sync.ok,1);assert.equal(state.sent[0].captura,id);assert.equal(adapter.pendientes().length,0);
});
test('los demás usuarios conservan la captura anterior',async()=>{const {adapter,state}=app();state.env=false;assert.equal(await adapter.preparar(),false);assert.equal(adapter.esAmbiente(),false);});
test('otra cuenta no ve pendientes anteriores',async()=>{const {adapter,state}=app();state.fail=true;await adapter.preparar();await adapter.guardar({lat:-35,lng:-59},'foto');state.id='B';assert.equal(adapter.pendientes().length,0);});
test('sin conexión conserva la foto sin enviarla',async()=>{const {adapter,state}=app();await adapter.preparar();state.online=false;const r=await adapter.guardar({lat:-35,lng:-59},'foto');assert.equal(r.cloud,false);assert.equal(state.sent.length,0);assert.equal(adapter.pendientes().length,1);});
