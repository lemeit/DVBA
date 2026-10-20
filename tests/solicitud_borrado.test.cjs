const test=require('node:test'),assert=require('node:assert/strict'),vm=require('node:vm'),fs=require('node:fs'),path=require('node:path');
const html=fs.readFileSync(path.join(__dirname,'../index.html'),'utf8');
const source=html.slice(html.indexOf('async function delReg(id)'),html.indexOf('// v8.86s · Borrado físico definitivo'));
for(const rol of ['gerencia','jefe_zona','jefe_tecnica','jefe_operativa','jefe_administrativa','jefe_automotores'])test(rol+' solicita y conserva el registro',async()=>{
 const calls=[];const ctx={requireAuth:async()=>true,DVBA_PERFIL:{get:()=>({rol})},regs:[{id:101,zona:'VI'}],abrirModalComentario:(...a)=>calls.push(a),_delRegAdminHard:()=>{throw Error('No debe borrar');},alert(){throw Error('No debe rechazar');}};
 vm.createContext(ctx);vm.runInContext(source,ctx);await ctx.delReg(101);assert.deepEqual(calls,[['relevamientos',101,'VI','eliminar']]);assert.equal(ctx.regs.length,1);
});
test('admin conserva la ejecución del borrado',async()=>{
 let borrado=false;const ctx={requireAuth:async()=>true,DVBA_PERFIL:{get:()=>({rol:'admin'})},_delRegAdminHard:()=>borrado=true};vm.createContext(ctx);vm.runInContext(source,ctx);await ctx.delReg(101);assert.equal(borrado,true);
});
