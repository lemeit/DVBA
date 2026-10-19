const test = require('node:test');
const assert = require('node:assert/strict');
const vm = require('node:vm');
const fs = require('node:fs');
const path = require('node:path');

// Ejecutar las funciones reales del portal sin mapa, red ni credenciales.
const html = fs.readFileSync(path.join(__dirname, '../index.html'), 'utf8');
function section(start, end) {
  const a = html.indexOf(start), b = html.indexOf(end, a);
  assert.ok(a >= 0 && b > a, 'Funciones del portal localizadas');
  return html.slice(a,b);
}
const functions = section('let _sincronizandoSupa = null;', '// v7.95/v7.97') +
  section('async function requireAuth(', 'async function hacerLogin(') +
  section('async function cargarRegs()', 'let capasR=');

function portal() {
  const storage = new Map([
    ['dvba_session','sesion-ficticia'],
    ['fotos_pendientes','captura-sin-enviar'],
    ['dvba_z6v6',JSON.stringify([{id:999,obs:'caché de otro contexto'}])]
  ]);
  const state={restores:0,queries:0,prompts:0,invalid:false,queryError:null,
    data:[{id:1,ruta:'RP30',progresiva:'10',zona:'VI'}]};
  const elements = new Map();
  const ctx = {
    console:{log(){},warn(){}},
    localStorage:{getItem:k=>storage.get(k)??null,removeItem:k=>storage.delete(k)},
    document:{getElementById(id){
      if(!elements.has(id)) elements.set(id,{textContent:'',classList:{add(){},remove(){}}});
      return elements.get(id);
    }},
    location:{search:'?zona=VI',pathname:'/DVBA/',hash:'',replace(){}},
    dvbaAuth:{estaLogueado:()=>storage.has('dvba_session'),session:async()=>({access_token:'token-ficticio',refresh_token:'refresh-ficticio'})},
    DVBA_PERFIL:{get:()=>({user_id:'usuario-ficticio',rol:'admin'}),cargar:async()=>{},limpiar:()=>{state.invalid=true;}},
    _supa:{
      auth:{setSession:async()=>{
        state.restores++;
        if(state.gate) await state.gate;
        if(state.authError) return {data:{session:null},error:state.authError};
        return {data:{session:state.noSession?null:{user:{id:'usuario-ficticio'}}},error:null};
      }},
      from(){
        const q={select(){return q;},order(){return q;},or(){return q;},then(resolve){
          state.queries++;return Promise.resolve({data:state.data,error:state.queryError}).then(resolve);
        }};
        return q;
      }
    },
    aplicarVisibilidadRol(){},aplicarModoSesion(){},abrirLogin(){state.prompts++;},
    renderRegs(){},drawRegMarkers(){},buildRegTags(){},setModoIndicador(){},actualizarBadgeCola(){},cargarRestauracionesPendientes(){},
    _parsearSubAtrib(){return null;}, regs:[],ZONA_ACTUAL:'VI'
  };
  ctx.window=ctx;
  vm.createContext(ctx);vm.runInContext(functions,ctx);
  return {ctx,state,storage,elements};
}

test('la consulta espera a que la sesión esté restaurada y comparte la restauración en curso',async()=>{
  const {ctx,state}=portal();let ready;
  state.gate=new Promise(resolve=>{ready=resolve;});
  const restore=ctx.sincronizarSupaConSesion();const load=ctx.cargarRegs();
  await new Promise(resolve=>setImmediate(resolve));
  assert.equal(state.restores,1);assert.equal(state.queries,0);
  ready();assert.equal(await restore,true);await load;
  assert.equal(state.queries,1);assert.equal(ctx.regs[0].id,1);
});
test('session_not_found devuelve false, pide login y conserva las capturas pendientes',async()=>{
  const {ctx,state,storage,elements}=portal();
  state.authError={code:'session_not_found',status:403};
  await ctx.cargarRegs();
  assert.equal(state.queries,0);assert.equal(state.prompts,1);assert.equal(ctx.regs.length,0);
  assert.equal(storage.has('dvba_session'),false);assert.equal(storage.get('fotos_pendientes'),'captura-sin-enviar');
  assert.match(elements.get('login-err').textContent,/iniciar sesión/);
});
test('un error de red conserva sesión y permite reintentar',async()=>{
  const {ctx,state,storage}=portal();state.authError={name:'TypeError',status:0};
  assert.equal(await ctx.sincronizarSupaConSesion(),false);
  assert.equal(storage.has('dvba_session'),true);assert.equal(state.prompts,0);
  state.authError=null;
  assert.equal(await ctx.sincronizarSupaConSesion(),true);assert.equal(state.restores,2);
});
test('setSession sin sesión no se trata como éxito',async()=>{
  const {ctx,state}=portal();state.noSession=true;
  assert.equal(await ctx.sincronizarSupaConSesion(),false);assert.equal(state.prompts,1);
});
test('requireAuth rechaza la operación si falló la restauración',async()=>{
  const {ctx,state}=portal();state.authError={code:'session_not_found',status:403};
  assert.equal(await ctx.requireAuth(),false);
});
test('una consulta rechazada no muestra caché de otro contexto',async()=>{
  const {ctx,state}=portal();state.queryError={code:'42501'};
  await ctx.cargarRegs();assert.equal(ctx.regs.length,0);assert.equal(state.queries,1);
});
test('el modo público no consulta registros operativos',async()=>{
  const {ctx,state,storage}=portal();storage.delete('dvba_session');
  await ctx.cargarRegs();assert.equal(state.restores,0);assert.equal(state.queries,0);
});
