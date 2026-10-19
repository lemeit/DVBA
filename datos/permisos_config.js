(function(global){
'use strict';
const ZONAS=['I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII'];
function configurar({rol,area='vialidad',zona=null,capturaProvincial=false}){
  if(area==='ambiente'){
    if(rol!=='tecnico')throw new Error('Ambiente usa el rol Técnico, sin administración.');
    return {rol,zona:null,area_codigo:'ambiente',contexto_captura:'ambiente',alcance_lectura:'propios',alcance_captura:'provincial'};
  }
  if(area!=='vialidad')throw new Error('Área desconocida.');
  let lectura,captura;
  if(rol==='admin'){lectura='provincial_operativo';captura='provincial';zona=null;}
  else if(rol==='gerencia'){lectura='provincial_operativo';captura='ninguna';zona=null;}
  else if(rol==='publico'){lectura='ninguna';captura='ninguna';zona=null;}
  else{
    if(!ZONAS.includes(zona))throw new Error('Este rol necesita una zona de adscripción válida.');
    if(rol==='tecnico'){lectura='zonal';captura=capturaProvincial?'provincial':'zonal';}
    else if(['jefe_zona','jefe_tecnica','jefe_operativa'].includes(rol)){lectura='zonal';captura='zonal';}
    else if(['jefe_administrativa','jefe_automotores'].includes(rol)){lectura='zonal';captura='ninguna';}
    else if(rol==='capataz'){lectura='tareas_asignadas';captura='ninguna';}
    else throw new Error('Rol desconocido.');
  }
  return {rol,zona,area_codigo:'vialidad',contexto_captura:'zonal',alcance_lectura:lectura,alcance_captura:captura};
}
global.DVBA_PERMISOS_CONFIG={configurar};
})(typeof window==='undefined'?globalThis:window);
