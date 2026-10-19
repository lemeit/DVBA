const test=require('node:test'),assert=require('node:assert/strict'),vm=require('node:vm'),fs=require('node:fs'),path=require('node:path');
const ctx={};vm.createContext(ctx);vm.runInContext(fs.readFileSync(path.join(__dirname,'../datos/permisos_config.js'),'utf8'),ctx);
const config=ctx.DVBA_PERMISOS_CONFIG.configurar;
test('Ambiente separa lectura propia de captura provincial',()=>{
  const p=config({rol:'tecnico',area:'ambiente',zona:'VI'});
  assert.equal(p.zona,null);assert.equal(p.alcance_lectura,'propios');assert.equal(p.alcance_captura,'provincial');assert.equal(p.contexto_captura,'ambiente');
});
test('Ambiente no puede conservar admin ni gerencia',()=>{
  for(const rol of ['admin','gerencia'])assert.throws(()=>config({rol,area:'ambiente'}),/Técnico/);
});
test('gerencia consulta provincia sin captura',()=>{const p=config({rol:'gerencia'});assert.equal(p.alcance_lectura,'provincial_operativo');assert.equal(p.alcance_captura,'ninguna');});
test('técnico con captura provincial conserva lectura zonal',()=>{const p=config({rol:'tecnico',zona:'IV',capturaProvincial:true});assert.equal(p.alcance_lectura,'zonal');assert.equal(p.alcance_captura,'provincial');});
test('roles zonales no admiten zona vacía o desconocida',()=>{
  for(const rol of ['tecnico','jefe_zona','jefe_tecnica','jefe_operativa','jefe_administrativa','jefe_automotores','capataz'])for(const zona of [null,'PBA','XIII'])assert.throws(()=>config({rol,zona}),/zona/);
});
test('capataz solo consulta tareas asignadas',()=>{const p=config({rol:'capataz',zona:'VI'});assert.equal(p.alcance_lectura,'tareas_asignadas');assert.equal(p.alcance_captura,'ninguna');});
