const assert=require('node:assert/strict'),fs=require('node:fs'),vm=require('node:vm');
const code=fs.readFileSync(require('node:path').join(__dirname,'../web/platform.js'),'utf8');
function scenario({fullscreen=true,prefixed=false,deny=false,orientation=true,orientationDeny=false,active=true,dpr=3,touch=5,standalone=false,ios=false,width=844,height=390,performanceReview=null}={}){
 const events=new Map(),elements=new Map();let calls=0,locks=0,reads=0;
 function element(){return {style:{},hidden:false,addEventListener(type,fn){this[type]=fn},setAttribute(){}}}
 const canvas=element();canvas.width=300;canvas.height=150;elements.set('canvas',canvas);
 const root=element();
 const document={body:{style:{},appendChild(e){if(e.id)elements.set(e.id,e)}},documentElement:root,fullscreenEnabled:fullscreen,fullscreenElement:null,createElement:element,querySelector(){return{setAttribute(){}}},getElementById(id){return elements.get(id)},addEventListener(type,fn,options){events.set(type,{fn,options})}};
 async function request(){calls++;if(deny)throw Error('denied');document.fullscreenElement=root;}
 if(fullscreen)root[prefixed?'webkitRequestFullscreen':'requestFullscreen']=request;
 if(prefixed){delete document.fullscreenEnabled;document.webkitFullscreenEnabled=true;}
 const navigator={maxTouchPoints:touch,userActivation:{isActive:active}};if(ios)navigator.standalone=standalone;
 const context={window:{devicePixelRatio:dpr,__auraPerformance:performanceReview},document,navigator,screen:{orientation:orientation?{lock:async()=>{locks++;if(orientationDeny)throw Error('unsupported')}}:{}},innerWidth:width,innerHeight:height,matchMedia:q=>({matches:standalone&&q==='(display-mode: standalone)'}),getComputedStyle(){reads++;return{paddingLeft:'14px',paddingTop:'8px',paddingRight:'16px',paddingBottom:'12px'}},addEventListener(type,fn){events.set(type,{fn})}};
 vm.runInNewContext(code,context);
 return {context,document,canvas,events,elements,state:context.window.__auraPlatform,get calls(){return calls},get locks(){return locks},get reads(){return reads},deny(value){deny=value},gesture(type='pointerup',extra={}){return events.get(type).fn({type,target:canvas,pointerType:'touch',isTrusted:true,...extra})}};
}
(async()=>{
 let calls=[];let diagnostic=scenario({performanceReview:{enabled:true,rasterRatio:1,setMode:mode=>calls.push(mode)}});
 assert.equal(diagnostic.canvas.width,844);assert.equal(diagnostic.canvas.height,390);
 assert.equal(JSON.parse(diagnostic.state.metrics()).width,844);assert.equal(JSON.parse(diagnostic.state.metrics()).pixelRatio,1);
 diagnostic.state.setMode('playing');assert.deepEqual(calls,['playing']);
 diagnostic=scenario({performanceReview:{enabled:false,rasterRatio:1}});assert.equal(diagnostic.canvas.width,1266);
 let s=scenario();assert.equal(s.events.get('pointerup').options.capture,true);assert.equal(s.events.get('touchend').options.capture,true);
 await s.gesture();assert.equal(s.state.fullscreen,'active');assert.equal(s.state.orientation,'locked');assert.equal(s.calls,1);
 await s.gesture('touchend');assert.equal(s.calls,1,'Pointer/Touch duplicate does not re-enter');
 assert.deepEqual(JSON.parse(s.state.metrics()).safe,[14,8,16,12]);
 const reads=s.reads;for(let i=0;i<30;i++)s.state.metrics();assert.equal(s.reads,reads,'Polling metrics must not force DOM style reads');
 s=scenario({deny:true});await s.gesture();assert.equal(s.state.fullscreen,'denied');assert.equal(s.locks,0);await s.gesture();assert.equal(s.calls,1);
 s.deny(false);await s.elements.get('aura-fullscreen').click({isTrusted:true});assert.equal(s.state.fullscreen,'active');assert.equal(s.calls,2,'Explicit retry survives an earlier denial');
 s.document.fullscreenElement=null;s.events.get('fullscreenchange').fn();assert.equal(s.state.fullscreen,'idle');await s.gesture();assert.equal(s.calls,2,'Exit does not trap the player by automatically re-entering');
 await s.elements.get('aura-fullscreen').click({isTrusted:true});assert.equal(s.calls,3);
 s=scenario({fullscreen:false,ios:true});await s.gesture('touchend');assert.equal(s.state.fullscreen,'unavailable');assert.equal(s.calls,0);
 await s.elements.get('aura-fullscreen').click({isTrusted:true});assert.match(s.elements.get('aura-fullscreen-help').textContent,/Home Screen/);
 s=scenario({standalone:true,ios:true});assert.equal(s.state.fullscreen,'standalone');assert.equal(s.elements.get('aura-fullscreen').hidden,true);await s.gesture();assert.equal(s.calls,0);
 s=scenario({prefixed:true});await s.gesture('touchend');assert.equal(s.state.fullscreen,'active');
 s=scenario({orientation:false});await s.gesture();assert.equal(s.state.orientation,'unavailable');
 s=scenario({orientationDeny:true});await s.gesture();assert.equal(s.state.fullscreen,'active');assert.equal(s.state.orientation,'denied');
 s=scenario({active:false});await s.gesture();assert.equal(s.calls,0);s.context.navigator.userActivation.isActive=true;await s.gesture();assert.equal(s.calls,1);
 s=scenario();await s.gesture('pointerup',{pointerType:'mouse'});await s.gesture('pointerup',{isTrusted:false});assert.equal(s.calls,0);
 await s.gesture('touchend');assert.equal(s.calls,1);
 s=scenario();s.state.setMode('playing');assert.equal(s.elements.get('aura-fullscreen').hidden,true);
 for(const mode of ['heroes','choice','legendary','replace','confirm_exit','won','lost']){s.state.setMode(mode);assert.equal(s.elements.get('aura-fullscreen').hidden,true,'Launcher must not obscure game/modal controls');}
 s.state.setMode('options');assert.equal(s.elements.get('aura-fullscreen').hidden,false);
 for(const [w,h] of [[1920,1080],[1600,900],[1280,720],[915,412],[844,390],[390,844]]){
  s=scenario({width:w,height:h});const ratio=Math.min(w,h)<900?1.5:3;
  assert.equal(s.canvas.width,Math.round(w*ratio));assert.equal(s.canvas.height,Math.round(h*ratio));
  assert.equal(JSON.parse(s.state.metrics()).width,w);assert.equal(s.canvas.style.width,w+'px');
 }
 s=scenario({touch:0,dpr:2});assert.equal(s.canvas.width,1688,'Desktop retains native DPR');await s.elements.get('aura-fullscreen').click({isTrusted:true});assert.equal(s.state.touch,false,'Mouse fullscreen must not turn desktop into a mobile device');
 s=scenario({dpr:1});assert.equal(s.canvas.width,844,'Low-DPR mobile is not upscaled');
 console.log('PASS: Trusted capture/touchend, actual fullscreen/exit/retry, iOS standalone help, modal ownership, CSS/DPR raster budget and cached metrics');
})().catch(e=>{console.error(e);process.exitCode=1});
