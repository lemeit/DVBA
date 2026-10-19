/* Cliente Ambiente. El servidor autoriza cada operación; no usar con fotos públicas. */
(function(global){
'use strict';
const DB='dvba_ambiente', STORE='pendientes';
function comprobar(error){if(error)throw error;}
function fila(data){return Array.isArray(data)?data[0]:data;}
function abrir(){return new Promise((resolve,reject)=>{
  const r=indexedDB.open(DB,1);
  r.onupgradeneeded=()=>r.result.createObjectStore(STORE,{keyPath:'captura'});
  r.onsuccess=()=>resolve(r.result);r.onerror=()=>reject(r.error);
});}
async function transaccion(mode,operacion){
  const db=await abrir();
  try{return await new Promise((resolve,reject)=>{
    const tx=db.transaction(STORE,mode);let resultado;
    const r=operacion(tx.objectStore(STORE));
    r.onsuccess=()=>{resultado=r.result;};
    tx.oncomplete=()=>resolve(resultado);
    tx.onerror=tx.onabort=()=>reject(tx.error||new Error('No se pudo conservar la captura en el dispositivo.'));
  });}finally{db.close();}
}
const cola={
  guardar:p=>transaccion('readwrite',s=>s.put(p)),
  async listar(user){return (await transaccion('readonly',s=>s.getAll())).filter(p=>p.usuario===user);},
  quitar:id=>transaccion('readwrite',s=>s.delete(id))
};
function crear(supa,identidad,{pendientes=cola,uuid=()=>crypto.randomUUID(),cuentaActual=()=>global.dvbaAuth?.user ? global.dvbaAuth.user()?.id : identidad}={}){
  function mismaCuenta(){if(cuentaActual()!==identidad)throw new Error('La cuenta cambió. Ingresá con la cuenta que tomó esta captura.');}
  async function validar(){
    mismaCuenta();
    if(global.dvbaAuth?.session && supa.auth.setSession){
      const s=await global.dvbaAuth.session();
      if(s?.user?.id!==identidad)throw new Error('La sesión cambió o venció. Volvé a ingresar con la cuenta de la captura.');
      const sesion=await supa.auth.setSession({access_token:s.access_token,refresh_token:s.refresh_token});comprobar(sesion.error);
      if(sesion.data?.session?.user?.id!==identidad)throw new Error('No se pudo confirmar la sesión de la captura.');
    }
    const {data,error}=await supa.auth.getUser();comprobar(error);
    if(!data?.user || data.user.id!==identidad)throw new Error('La cuenta cambió. Ingresá con la cuenta que tomó esta captura.');
    const r=await supa.from('usuarios_perfil').select('*').eq('user_id',identidad).maybeSingle();comprobar(r.error);
    const p=r.data;
    if(!p || p.user_id!==identidad || !p.activo || p.rol!=='tecnico' || p.area_codigo!=='ambiente' ||
      p.contexto_captura!=='ambiente' || p.alcance_lectura!=='propios' || p.alcance_captura!=='provincial')
      throw new Error('Esta cuenta todavía no está habilitada para el acceso de Ambiente.');
    return p;
  }
  async function rpc(nombre,args){const r=await supa.rpc(nombre,args);comprobar(r.error);return fila(r.data);}
  async function guardar(datos,foto){
    mismaCuenta();
    if(foto && (!['image/jpeg','image/png','image/webp'].includes(foto.type)||foto.size>10485760))
      throw new Error('Usá una foto JPG, PNG o WebP de hasta 10 MB.');
    const p={captura:uuid(),fotoId:foto?uuid():null,usuario:identidad,datos,foto:foto||null,creada:new Date().toISOString()};
    // El blob y los UUID se conservan ANTES de usar la red; un fallo de cuota se propaga.
    await pendientes.guardar(p);return p;
  }
  async function enviar(p){
    if(p.usuario!==identidad)throw new Error('La captura pertenece a otra cuenta.');
    await validar();
    const r=await rpc('ambiente_crear',{p_captura:p.captura,p_datos:p.datos});
    if(!r?.id || r.autor_id!==identidad || r.contexto_trabajo!=='ambiente')throw new Error('No se pudo confirmar el registro privado.');
    p.registroId=r.id;await pendientes.guardar(p);
    if(p.foto){
      const f=await rpc('ambiente_reservar_foto',{p_id:r.id,p_foto:p.fotoId});
      if(f?.bucket!=='ambiente_privado' || !f.object_path?.startsWith(identidad+'/'))throw new Error('Destino privado de foto inválido.');
      await validar();
      const bucket=supa.storage.from(f.bucket);
      const upload=await bucket.upload(f.object_path,p.foto,{contentType:p.foto.type,upsert:false});
      if(upload.error){
        // Si la respuesta de una subida anterior se perdió, confirmar el objeto
        // privado y comparar el contenido antes de dar por enviado el pendiente.
        if(String(upload.error.statusCode)!=='409')throw upload.error;
        const previo=await bucket.download(f.object_path);comprobar(previo.error);
        const a=new Uint8Array(await previo.data.arrayBuffer()),b=new Uint8Array(await p.foto.arrayBuffer());
        if(a.length!==b.length || a.some((v,i)=>v!==b[i]))throw new Error('La foto remota no coincide. Conservamos la captura pendiente.');
      }
    }
    await validar();
    await pendientes.quitar(p.captura);return r;
  }
  async function misRegistros(){
    await validar();
    const r=await supa.from('relevamientos').select('*').eq('contexto_trabajo','ambiente')
      .eq('autor_id',identidad).order('fecha',{ascending:false});comprobar(r.error);return r.data||[];
  }
  async function fotoPrivada(id){
    await validar();
    const r=await supa.from('registro_fotos').select('bucket,object_path').eq('relevamiento_id',id);comprobar(r.error);
    const fotos=[];
    for(const f of r.data||[]){
      if(f.bucket!=='ambiente_privado')throw new Error('La foto no corresponde al almacenamiento privado.');
      const res=await supa.storage.from(f.bucket).download(f.object_path);comprobar(res.error);fotos.push(res.data);
    }return fotos;
  }
  async function accion(nombre,args){await validar();return rpc(nombre,args);}
  return {validar,guardar,enviar,misRegistros,fotoPrivada,
    descartar:async captura=>{mismaCuenta();if(!(await pendientes.listar(identidad)).some(p=>p.captura===captura))throw new Error('Captura no encontrada para esta cuenta.');await pendientes.quitar(captura);},
    pendientes:()=>{mismaCuenta();return pendientes.listar(identidad);},
    editar:(id,version,cambios)=>accion('ambiente_editar',{p_id:id,p_version:version,p_cambios:cambios}),
    async transicion(id,version,estado){
      if((await pendientes.listar(identidad)).some(p=>String(p.registroId)===String(id)))
        throw new Error('Primero enviá y confirmá las fotos pendientes de este registro.');
      return accion('ambiente_transicion',{p_id:id,p_version:version,p_estado:estado});
    },
    compartir:(id,version,zona,motivo)=>accion('ambiente_compartir',{p_id:id,p_version:version,p_zona:zona,p_motivo:motivo}),
    revocar:(id,version,zona)=>accion('ambiente_revocar',{p_id:id,p_version:version,p_zona:zona})};
}
global.DVBA_AMBIENTE={crear};
})(typeof window==='undefined'?globalThis:window);
