/* Fotos privadas dentro del mismo visor del portal; sin cambiar la interfaz. */
(function(global){
'use strict';
const fotos=new Map();
function limpiar(){for(const f of fotos.values())if(f.url)URL.revokeObjectURL(f.url);fotos.clear();}
async function abrir(supa,id){
 const f=fotos.get(String(id));if(!f)return null;
 const r=await supa.storage.from(f.bucket).download(f.object_path);if(r.error)throw r.error;
 if(f.url)URL.revokeObjectURL(f.url);f.url=URL.createObjectURL(r.data);return f.url;
}
async function cargar(supa,registros){
 limpiar();const ids=registros.filter(r=>r.contexto_trabajo==='ambiente').map(r=>r.id);
 if(!ids.length)return registros;
 const res=await supa.from('registro_fotos').select('relevamiento_id,bucket,object_path').in('relevamiento_id',ids);
 if(res.error)throw res.error;
 for(const f of res.data||[])if(f.bucket==='ambiente_privado' && !fotos.has(String(f.relevamiento_id)))fotos.set(String(f.relevamiento_id),f);
 const salida=[];
 for(const r of registros){
  if(!fotos.has(String(r.id))){salida.push(r);continue;}
  try{salida.push({...r,foto_url:await abrir(supa,r.id)});}catch(e){console.warn('[foto privada] no se pudo descargar',r.id);salida.push(r);}
 }return salida;
}
global.addEventListener?.('pagehide',limpiar);
global.DVBA_FOTOS_PRIVADAS={cargar,abrir,esPrivada:id=>fotos.has(String(id))};
})(window);
