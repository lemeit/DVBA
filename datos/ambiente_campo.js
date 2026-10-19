/* Adaptador sin interfaz: conserva los modos Básico/Avanzado y su cola visual. */
(function(global){
'use strict';
let api=null,cuenta=null,cola=[],urls=[];
function esAmbiente(){
 try{const p=JSON.parse(localStorage.getItem('dvba_perfil')||'null');return !!(p?.activo && p.user_id===global.dvbaAuth?.user()?.id && p.area_codigo==='ambiente');}catch(e){return false;}
}
function pendientes(){return esAmbiente() && cuenta===global.dvbaAuth.user()?.id?cola:[];}
async function refrescar(){
 for(const u of urls)URL.revokeObjectURL(u);urls=[];
 cola=(await api.pendientes()).map(p=>{
  const foto=p.foto?URL.createObjectURL(p.foto):null;if(foto)urls.push(foto);
  return {id:p.captura,reg:p.datos,...p.datos,foto,fotoBase64:foto,ts:Date.parse(p.creada),_captura:p};
 });
 return cola;
}
async function preparar(){
 const user=global.dvbaAuth?.user();if(!user)return false;
 if(navigator.onLine){
  const r=await global.dvbaAuth.fetchAuth(global.dvbaAuth.SUPA_URL+'/rest/v1/usuarios_perfil?select=*&user_id=eq.'+encodeURIComponent(user.id));
  if(!r.ok)throw new Error('No se pudo verificar el perfil.');
  const p=(await r.json()).find(p=>p.user_id===user.id);
  if(p?.activo)localStorage.setItem('dvba_perfil',JSON.stringify(p));else localStorage.removeItem('dvba_perfil');
 }
 if(!esAmbiente())return false;
 if(!api || cuenta!==user.id){
  const supa=global.supabase.createClient(global.dvbaAuth.SUPA_URL,global.dvbaAuth.SUPA_KEY,{auth:{persistSession:false,autoRefreshToken:false,detectSessionInUrl:false}});
  cuenta=user.id;api=global.DVBA_AMBIENTE.crear(supa,cuenta);
 }
 await refrescar();return true;
}
async function guardar(reg,fotoBase64){
 if(!await preparar())throw new Error('Perfil de Ambiente no disponible.');
 const datos={};for(const k of ['ruta','partido','progresiva','tipo','estado','observaciones','lat','lng','fecha','naturaleza','superficie','modalidad','tipo_via','prioridad'])if(reg[k]!==undefined)datos[k]=reg[k];
 const foto=fotoBase64?await (await fetch(fotoBase64)).blob():null;
 const p=await api.guardar(datos,foto);await refrescar();
 if(navigator.onLine){try{const registro=await api.enviar(p);await refrescar();return {cloud:true,id:registro.id};}catch(e){await refrescar();return {cloud:false,error:e.message};}}
 return {cloud:false};
}
async function sincronizar(){
 try{if(!await preparar())throw new Error('Perfil de Ambiente no disponible.');}
 catch(e){return {ok:0,err:Math.max(1,pendientes().length),errores:[e.message]};}
 let ok=0,err=0;const errores=[];
 for(const item of [...cola])try{await api.enviar(item._captura);ok++;}catch(e){err++;errores.push(e.message);}
 await refrescar();return {ok,err,errores};
}
async function borrar(id){await api.descartar(id);await refrescar();}
global.DVBA_CAMPO_AMBIENTE={preparar,esAmbiente,pendientes,guardar,sincronizar,borrar};
})(window);
