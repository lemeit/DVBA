const test=require('node:test'),assert=require('node:assert/strict'),vm=require('node:vm'),fs=require('node:fs'),path=require('node:path');
function worker(offline=false){
 const handlers={},writes=[];
 const cached=new Response('portal anterior');
 const ctx={URL,Response,setTimeout,clearTimeout,console,
  self:{location:{origin:'https://example.invalid'},registration:{scope:'https://example.invalid/DVBA/'},addEventListener:(name,fn)=>handlers[name]=fn},
  caches:{match:async()=>cached,open:async()=>({put:async(...args)=>writes.push(args)})},
  fetch:async()=>{if(offline)throw new Error('sin red');return new Response('visor actual');}};
 vm.createContext(ctx);vm.runInContext(fs.readFileSync(path.join(__dirname,'../sw.js'),'utf8'),ctx);
 return {handlers,writes};
}
test('portal con conexión recibe el visor actual aunque exista HTML viejo en caché',async()=>{
 const w=worker();let result;w.handlers.fetch({request:{method:'GET',url:'https://example.invalid/DVBA/index.html?zona=VI'},respondWith:r=>result=r});
 assert.equal(await (await result).text(),'visor actual');assert.equal(w.writes.length,1);
});
test('portal sin conexión conserva su propio HTML disponible',async()=>{
 const w=worker(true);let result;w.handlers.fetch({request:{method:'GET',url:'https://example.invalid/DVBA/index.html?zona=VI'},respondWith:r=>result=r});
 assert.equal(await (await result).text(),'portal anterior');
});
test('captura móvil conserva la respuesta inmediata desde caché',async()=>{
 const w=worker();let result;w.handlers.fetch({request:{method:'GET',url:'https://example.invalid/DVBA/dvba_campo_lite.html'},respondWith:r=>result=r});
 assert.equal(await (await result).text(),'portal anterior');
});
