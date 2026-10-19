const test=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.join(__dirname,'..');
const original=JSON.parse(fs.readFileSync(path.join(__dirname,'interfaz_campo_original.json'),'utf8'));
for(const name of ['dvba_campo.html','dvba_campo_lite.html']){
 const source=fs.readFileSync(path.join(root,name),'utf8');
 test(name+' conserva la estructura visual original y sus controles',()=>{
  const vista=source.slice(source.indexOf('<body')).replace(/\r\n/g,'\n').replace(/<!--[\s\S]*?-->/g,'').replace(/<script\b[^>]*>[\s\S]*?<\/script>/gi,'').replace(/v?9\.95\.\d+/g,'VERSION').replace(/\s+/g,' ').trim();
  assert.equal(crypto.createHash('sha256').update(vista).digest('hex'),original[name]);
 });
 test(name+' no deriva a otra aplicación ni incorpora un mapa',()=>{
  assert.doesNotMatch(source,/abrirAmbiente\(|location\.replace\(['"]ambiente\.html/);assert.match(source,/DVBA_CAMPO_AMBIENTE\.guardar\(reg,/);assert.doesNotMatch(source,/id=["']mapa["']|ambiente_pantalla\.js/);
 });
}
test('el portal de escritorio mantiene su mapa sin una pantalla nueva',()=>{
 const source=fs.readFileSync(path.join(root,'index.html'),'utf8');assert.doesNotMatch(source,/location\.replace\(['"]ambiente\.html/);assert.match(source,/id="map"/);
});
