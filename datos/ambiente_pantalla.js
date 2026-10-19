(async function(){
'use strict';
const $=id=>document.getElementById(id);
const avisar=msg=>{$('estado').textContent=msg;};
const urls=new Set();let api,mapa,seleccion,marcas,ocupado=false;
function limpiarFotos(){for(const url of urls)URL.revokeObjectURL(url);urls.clear();}
function punto(lat,lng){
  $('lat').value=lat;$('lng').value=lng;
  if(mapa){if(seleccion)seleccion.remove();seleccion=L.marker([lat,lng]).addTo(mapa);}
}
function boton(label,accion,destino){
  const b=document.createElement('button');b.type='button';b.textContent=label;
  b.onclick=()=>ejecutar(accion);destino.append(b);return b;
}
async function ejecutar(fn){
  if(ocupado)return;ocupado=true;
  document.querySelectorAll('button').forEach(b=>{b.disabled=true;});
  try{await fn();}catch(e){avisar(e.message||'No se pudo completar la operación. Tus pendientes se conservan.');}
  finally{ocupado=false;document.querySelectorAll('button').forEach(b=>{b.disabled=false;});}
}
async function contar(){const p=await api.pendientes();$('pendientes').textContent=p.length+' capturas pendientes de envío.';return p;}
async function actualizar(){
  const registros=await api.misRegistros();limpiarFotos();$('registros').replaceChildren();marcas?.clearLayers();
  if(!registros.length)$('registros').textContent='Todavía no tenés registros enviados.';
  for(const r of registros){
    const caja=document.createElement('article');caja.className='registro';
    const titulo=document.createElement('h3');titulo.textContent=(r.partido||'Ubicación sin partido definido')+' · '+r.estado_registro;
    const texto=document.createElement('p');texto.textContent=r.observaciones||'Sin descripción';caja.append(titulo,texto);
    if(mapa && r.lat!=null && r.lng!=null)L.marker([r.lat,r.lng]).bindPopup(document.createTextNode(texto.textContent)).addTo(marcas);
    boton('Ver fotos privadas',async()=>{
      const fotos=await api.fotoPrivada(r.id);
      const visor=document.createElement('div');
      for(const blob of fotos){const img=document.createElement('img');img.alt='Foto del registro';img.src=URL.createObjectURL(blob);urls.add(img.src);visor.append(img);}
      if(!fotos.length)visor.textContent='Sin fotos adjuntas.';
      caja.querySelector('[data-fotos]')?.remove();visor.dataset.fotos='';caja.append(visor);
    },caja);
    if(['borrador','observado'].includes(r.estado_registro)){
      boton('Editar descripción',async()=>{
        const texto=prompt('Descripción del registro',r.observaciones||'');if(texto===null)return;
        await api.editar(r.id,r.version,{observaciones:texto});await actualizar();avisar('Descripción actualizada.');
      },caja);
      boton('Presentar',async()=>{await api.transicion(r.id,r.version,'presentado');await actualizar();avisar('Registro presentado. Sigue siendo privado.');},caja);
    }
    if(['presentado','cerrado'].includes(r.estado_registro)){
      boton('Compartir con una zona',async()=>{
        const zona=prompt('Zona destinataria (I a XII). Compartir es opcional.');if(zona===null)return;
        if(!['I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII'].includes(zona.trim().toUpperCase()))throw new Error('Elegí una zona válida de I a XII.');
        const motivo=prompt('Motivo para compartir');if(motivo===null)return;
        if(motivo.trim().length<3)throw new Error('Ingresá un motivo de al menos tres caracteres.');
        await api.compartir(r.id,r.version,zona.trim().toUpperCase(),motivo);await actualizar();avisar('Registro compartido solo con los jefes autorizados de esa zona.');
      },caja);
      boton('Revocar acceso de una zona',async()=>{
        const zona=prompt('Zona cuyo acceso querés revocar (I a XII)');if(zona===null)return;
        await api.revocar(r.id,r.version,zona.trim().toUpperCase());await actualizar();avisar('Compartición revocada.');
      },caja);
      if(r.estado_registro==='presentado')boton('Cerrar registro',async()=>{await api.transicion(r.id,r.version,'cerrado');await actualizar();avisar('Registro cerrado.');},caja);
    }
    $('registros').append(caja);
  }
}
async function sincronizar(){
  let enviados=0;
  try{for(const p of await contar()){await api.enviar(p);enviados++;}}
  finally{await contar();}
  await actualizar();avisar(enviados+' capturas enviadas y confirmadas.');
}
try{
  const session=await dvbaAuth.session();
  if(!session?.user?.id)throw new Error('Ingresá desde el portal principal para usar Ambiente.');
  const supa=supabase.createClient(dvbaAuth.SUPA_URL,dvbaAuth.SUPA_KEY,{auth:{persistSession:false,autoRefreshToken:false,detectSessionInUrl:false}});
  const result=await supa.auth.setSession({access_token:session.access_token,refresh_token:session.refresh_token});
  if(result.error)throw result.error;
  if(result.data?.session?.user?.id!==session.user.id)throw new Error('No se pudo confirmar la cuenta.');
  api=DVBA_AMBIENTE.crear(supa,session.user.id);await api.validar();
  $('trabajo').hidden=false;
  if(typeof L!=='undefined'){
    mapa=L.map('mapa').setView([-36.5,-60],6);L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{attribution:'© OpenStreetMap contributors',maxZoom:19}).addTo(mapa);
    marcas=L.layerGroup().addTo(mapa);mapa.on('click',e=>punto(e.latlng.lat,e.latlng.lng));
    // Solo cartografía pública: cambiar la zona del mapa no consulta registros zonales.
    Promise.all([fetch('datos/referencias/partidos_pba.geojson'),fetch('datos/referencias/partidos_pba.json')])
      .then(async respuestas=>{
        if(respuestas.some(r=>!r.ok))throw new Error('Cartografía no disponible');
        const [geometria,catalogo]=await Promise.all(respuestas.map(r=>r.json()));
        const limites={};
        for(const [zona,meta] of Object.entries(catalogo.zonas_dvba)){
          const numeros=new Set(meta.partidos.map(Number));
          const capa=L.geoJSON(geometria,{filter:f=>numeros.has(Number(f.properties.CCA)),style:{color:'#007e8c',weight:1,fillOpacity:.04},
            onEachFeature:(f,l)=>{const texto=document.createElement('span');texto.textContent=meta.nombre+' · '+f.properties.NAM;l.bindTooltip(texto);}}).addTo(mapa);
          limites[zona]=capa.getBounds();const opcion=document.createElement('option');opcion.value=zona;opcion.textContent=meta.nombre;$('zonaMapa').append(opcion);
        }
        $('zonaMapa').onchange=()=>{const z=$('zonaMapa').value;if(z==='PBA')mapa.setView([-36.5,-60],6);else if(limites[z]?.isValid())mapa.fitBounds(limites[z]);};
      }).catch(()=>{$('zonaMapa').disabled=true;});
  }else{$('mapa').textContent='No se pudo cargar el mapa. Podés usar tu ubicación o completar las coordenadas.';}
  $('ubicacion').onclick=()=>navigator.geolocation.getCurrentPosition(p=>{punto(p.coords.latitude,p.coords.longitude);mapa?.setView([p.coords.latitude,p.coords.longitude],14);},()=>avisar('No se pudo obtener tu ubicación. Podés marcarla en el mapa.'),{enableHighAccuracy:true,timeout:15000});
  $('captura').onsubmit=e=>{e.preventDefault();ejecutar(async()=>{
    const lat=Number($('lat').value),lng=Number($('lng').value);
    if(!Number.isFinite(lat)||!Number.isFinite(lng)||lat< -90||lat>90||lng< -180||lng>180)throw new Error('Revisá las coordenadas.');
    await api.guardar({lat,lng,partido:$('partido').value.trim()||null,ruta:$('ruta').value.trim()||'?',observaciones:$('descripcion').value.trim(),tipo:'sin_clasificar',fecha:new Date().toISOString()},$('foto').files[0]);
    $('captura').reset();await contar();avisar('Captura conservada en este dispositivo. Pendiente de envío.');
    if(navigator.onLine)await sincronizar();
  });};
  $('sincronizar').onclick=()=>ejecutar(sincronizar);$('actualizar').onclick=()=>ejecutar(actualizar);
  await contar();await actualizar();avisar('Ambiente habilitado. Solo consultás tus registros; compartir con una zona es opcional.');
}catch(e){avisar(e.message||'No se pudo iniciar Ambiente.');}
window.addEventListener('pagehide',limpiarFotos);
})();
