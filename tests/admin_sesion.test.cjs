const test=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const vm=require('node:vm');
const html=fs.readFileSync(require('node:path').join(__dirname,'../admin_usuarios.html'),'utf8');
const source=html.slice(html.indexOf('async function chequearAcceso()'),html.indexOf('async function cargarUsuarios()'));
function panel(options={}){
  const elements=new Map();
  const state={restores:0,profiles:0};
  const ctx={console:{warn(){},error(){}},
    document:{getElementById(id){if(!elements.has(id))elements.set(id,{style:{},textContent:''});return elements.get(id);}},
    dvbaAuth:{session:async()=>options.noSession?null:{access_token:'ficticio',refresh_token:'ficticio'}},
    _supa:{auth:{setSession:async()=>{state.restores++;return {data:{session:options.empty?null:{user:{id:'cuenta-A',email:'admin@example.invalid'}}},error:options.authError};}},
      from(table){assert.equal(table,'usuarios_perfil');state.profiles++;
        return {select(){return this;},eq(key,id){assert.equal(key,'user_id');assert.equal(id,'cuenta-A');return this;},
          async maybeSingle(){return {data:options.missing?null:{user_id:'cuenta-A',rol:'admin',activo:true,...options.profile},error:options.profileError};}};
      }},
    localStorage:{getItem(){throw new Error('La caché no puede autorizar el panel');}}
  };
  ctx.window=ctx;vm.createContext(ctx);vm.runInContext(source,ctx);
  return {ctx,state,elements};
}
test('admin usa SDK local y sesión compartida',()=>{
  assert.match(html,/<script src="datos\/supabase-js.min.js"><\/script>/);
  assert.match(html,/<script src="datos\/auth.js"><\/script>/);
  assert.match(html,/persistSession: false, autoRefreshToken: false/);
});
test('admin activo accede sin sesión separada del SDK',async()=>{
  const {ctx,state,elements}=panel();assert.equal(await ctx.chequearAcceso(),true);
  assert.equal(state.restores,1);assert.equal(state.profiles,1);assert.equal(elements.get('guard').style.display,'none');
});
for(const [name,options] of [
  ['sin sesión',{noSession:true}],['sesión rechazada',{authError:{status:403}}],
  ['setSession sin sesión',{empty:true}],['perfil ausente',{missing:true}],
  ['perfil inactivo',{profile:{activo:false}}],['técnico',{profile:{rol:'tecnico'}}],
  ['perfil de otra cuenta',{profile:{user_id:'cuenta-B'}}],['fallo de lectura del perfil',{profileError:{code:'42501'}}]
])test(name+' no accede ni usa un admin cacheado',async()=>{
  const {ctx,elements}=panel(options);assert.equal(await ctx.chequearAcceso(),false);
  assert.notEqual(elements.get('guard')?.style.display,'none');
});
