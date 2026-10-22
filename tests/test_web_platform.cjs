const assert=require('node:assert/strict'),fs=require('node:fs'),vm=require('node:vm');
const code=fs.readFileSync(require('node:path').join(__dirname,'../web/platform.js'),'utf8');
async function scenario({fullscreen=true,deny=false,orientation=true,orientationDeny=false,active=true}={}){
 let handler,calls=0,locks=0;
 const document={body:{style:{},appendChild(){}},documentElement:{style:{}},fullscreenEnabled:fullscreen,fullscreenElement:null,createElement(){return{style:{}}},querySelector(){return{setAttribute(){}}},getElementById(){return{style:{},requestFullscreen:async()=>{calls++;if(deny)throw Error('denied');document.fullscreenElement={}}}},addEventListener(name,fn){if(name==='pointerup')handler=fn}};
 const context={window:{},document,navigator:{maxTouchPoints:5,userActivation:{isActive:active}},screen:{orientation:orientation?{lock:async()=>{locks++;if(orientationDeny)throw Error('unsupported on this browser')}}:{}},innerWidth:844,innerHeight:390,getComputedStyle(){return{paddingLeft:'14px',paddingTop:'8px',paddingRight:'16px',paddingBottom:'12px'}},addEventListener(){}};
 vm.runInNewContext(code,context);
 return{context,handler,get calls(){return calls},get locks(){return locks},state:context.window.__auraPlatform};
}
(async()=>{
 let s=await scenario();await s.handler({pointerType:'touch',isTrusted:true});assert.equal(s.state.fullscreen,'active');assert.equal(s.state.orientation,'locked');assert.deepEqual(JSON.parse(s.state.metrics()).safe,[14,8,16,12]);
 s=await scenario({deny:true});await s.handler({pointerType:'touch',isTrusted:true});assert.equal(s.state.fullscreen,'denied');assert.equal(s.locks,0);await s.handler({pointerType:'touch',isTrusted:true});assert.equal(s.calls,1);
 s=await scenario({fullscreen:false});await s.handler({pointerType:'touch',isTrusted:true});assert.equal(s.state.fullscreen,'unavailable');assert.equal(s.calls,0);
 s=await scenario({orientation:false});await s.handler({pointerType:'touch',isTrusted:true});assert.equal(s.state.orientation,'unavailable');
 s=await scenario({orientationDeny:true});await s.handler({pointerType:'touch',isTrusted:true});assert.equal(s.state.fullscreen,'active');assert.equal(s.state.orientation,'denied');
 s=await scenario({active:false});await s.handler({pointerType:'touch',isTrusted:true});assert.equal(s.calls,0);
 s=await scenario();await s.handler({pointerType:'mouse',isTrusted:true});await s.handler({pointerType:'touch',isTrusted:false});assert.equal(s.calls,0);
 console.log('PASS: Fullscreen permitted/denied/unavailable, orientation fallbacks, eligible gestures and safe-area metrics');
})().catch(error=>{console.error(error);process.exitCode=1});
