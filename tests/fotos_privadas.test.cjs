const test=require('node:test'),assert=require('node:assert/strict'),vm=require('node:vm'),fs=require('node:fs'),path=require('node:path');
const source=fs.readFileSync(path.join(__dirname,'../datos/fotos_privadas.js'),'utf8');
test('el mismo visor descarga fotos privadas con sesión sin crear URLs públicas',async()=>{
 let descargas=0;const ctx={console,URL:{createObjectURL:()=> 'blob:foto-privada',revokeObjectURL(){}},addEventListener(){}};ctx.window=ctx;vm.createContext(ctx);vm.runInContext(source,ctx);
 const supa={from(table){assert.equal(table,'registro_fotos');return {select(){return this;},async in(key,ids){assert.equal(key,'relevamiento_id');assert.deepEqual(Array.from(ids),[1]);return {data:[{relevamiento_id:1,bucket:'ambiente_privado',object_path:'A/foto.jpg'}]};}};},
 storage:{from(bucket){assert.equal(bucket,'ambiente_privado');return {async download(path){assert.equal(path,'A/foto.jpg');descargas++;return {data:new Blob(['foto'])};}};}}};
 const rows=await ctx.DVBA_FOTOS_PRIVADAS.cargar(supa,[{id:1,contexto_trabajo:'ambiente'},{id:2,foto_url:'foto-zonal'}]);
 assert.equal(rows[0].foto_url,'blob:foto-privada');assert.equal(rows[1].foto_url,'foto-zonal');assert.equal(descargas,1);
 await ctx.DVBA_FOTOS_PRIVADAS.abrir(supa,1);assert.equal(descargas,2);
});
test('registros zonales no consultan el almacenamiento privado',async()=>{
 const ctx={URL:{revokeObjectURL(){}},addEventListener(){}};ctx.window=ctx;vm.createContext(ctx);vm.runInContext(source,ctx);
 const rows=[{id:1,foto_url:'foto-zonal'}];assert.equal(await ctx.DVBA_FOTOS_PRIVADAS.cargar({},rows),rows);
});
