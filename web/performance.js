/* Development-only recorder, present only in Web Performance Review exports.
 * Nothing is transmitted. No GL queries/timer ownership or gameplay changes. */
(function () {
  if (window.__auraPerformance) return;
  const params=new URLSearchParams(location.search);
  if (params.get('perf')!=='1') return;
  const capacity=3600, intervals=new Float64Array(capacity), inputs=new Float64Array(capacity);
  let used=0,total=0,index=0,previous=0,active=false,engine=null,inputCount=0,inputIndex=0,lastMode='menu';
  const stalls=[],contexts=[],env={userAgent:navigator.userAgent,brands:navigator.userAgentData?.brands||null,platform:navigator.platform,deviceLabel:params.get('perf_device')||'not supplied',deviceLabelSource:'creator supplied, not inferred',dpr:devicePixelRatio,hardwareConcurrency:navigator.hardwareConcurrency||null,webgl:null,webglTimerExtension:false};
  const ratio=Number(params.get('perf_raster'));
  const rasterRatio=[1,1.25,1.5].includes(ratio)?ratio:null;
  const canvas=document.getElementById('canvas');
  function graphics() {
    if(!canvas)return;
    env.cssExtent=[innerWidth,innerHeight];env.canvasPixels=[canvas.width,canvas.height];
    try {
      const gl=canvas.getContext('webgl2');
      if(!gl){env.webgl='unavailable';return;}
      env.framebufferPixels=[gl.drawingBufferWidth,gl.drawingBufferHeight];env.webgl=gl.getParameter(gl.VERSION);
      const debug=gl.getExtension('WEBGL_debug_renderer_info');
      env.reportedRenderer=debug?gl.getParameter(debug.UNMASKED_RENDERER_WEBGL):gl.getParameter(gl.RENDERER);
      env.reportedVendor=debug?gl.getParameter(debug.UNMASKED_VENDOR_WEBGL):gl.getParameter(gl.VENDOR);
      env.webglTimerExtension=!!gl.getExtension('EXT_disjoint_timer_query_webgl2');
    } catch(e){env.webgl='unavailable';}
  }
  function stats(values) {
    if(!values.length)return {samples:0,median:null,p95:null,p99:null,max:null,mean:null};
    const sorted=values.slice().sort((a,b)=>a-b),n=sorted.length;
    return {samples:n,median:(sorted[Math.floor((n-1)/2)]+sorted[Math.floor(n/2)])/2,p95:sorted[Math.ceil(n*.95)-1],p99:sorted[Math.ceil(n*.99)-1],max:sorted[n-1],mean:sorted.reduce((a,b)=>a+b,0)/n};
  }
  function ordered(buffer,n,at){return Array.from({length:n},(_,i)=>buffer[(at-n+i+capacity)%capacity]);}
  function snapshot(){
    graphics();const values=ordered(intervals,used,index),time=values.reduce((a,b)=>a+b,0);
    return {schema:1,build:window.__auraPerfBuild||null,environment:env,source:'browser requestAnimationFrame callbacks while visible/playing, not physical scanout',rollingCapacity:capacity,totalRafFrames:total,rafFps:time?values.length*1000/time:null,frameTimeMs:stats(values),longFrames:{over25:values.filter(x=>x>25).length,over33_334:values.filter(x=>x>33.334).length,over50:values.filter(x=>x>50).length},inputDispatchDelayMs:stats(ordered(inputs,inputCount,inputIndex)),longTasks:stalls.slice(),contextEvents:contexts.slice(),engine,rawRafMs:values,limitations:['InputEvent timing starts at engine receipt; browser event-dispatch delay is reported separately.','GPU data is available only if the engine reports nonzero timers.','No hardware/OS-to-photon latency or physical device result is inferred.']};
  }
  function tick(now){
    if(active&&document.visibilityState==='visible'){
      if(previous){intervals[index]=now-previous;index=(index+1)%capacity;used=Math.min(capacity,used+1);total++;}
      previous=now;
    }else previous=0;
    requestAnimationFrame(tick);
  }
  document.addEventListener('visibilitychange',()=>{previous=0;});
  document.addEventListener('pointermove',event=>{
    if(!active||event.pointerType!=='touch'||!event.isTrusted)return;
    const delay=performance.now()-event.timeStamp;
    if(delay>=0&&delay<60000){inputs[inputIndex]=delay;inputIndex=(inputIndex+1)%capacity;inputCount=Math.min(capacity,inputCount+1);}
  },{capture:true,passive:true});
  if(canvas)for(const name of ['webglcontextlost','webglcontextrestored'])canvas.addEventListener(name,()=>{if(contexts.length===32)contexts.shift();contexts.push({event:name,at:performance.now()});});
  if(typeof PerformanceObserver==='function')try{
    new PerformanceObserver(list=>{for(const entry of list.getEntries()){if(!active)continue;if(stalls.length===128)stalls.shift();stalls.push({at:entry.startTime,duration:entry.duration});}}).observe({type:'longtask',buffered:false});
  }catch(_){}
  const button=document.createElement('button');button.id='aura-performance-report';button.type='button';button.textContent='DEV · PERF REPORT';
  button.style.cssText='position:fixed;top:6px;left:50%;transform:translateX(-50%);z-index:40;padding:8px 12px;min-height:44px;background:#13233a;color:#fff9e9;border:1px solid #f8c45f;font:700 13px system-ui';
  const dialog=document.createElement('dialog');dialog.style.cssText='max-width:min(700px,90vw);max-height:80vh;overflow:auto;background:#13233a;color:#fff9e9;border:2px solid #f8c45f;font:14px system-ui';
  const title=document.createElement('h2');title.textContent='Development performance report';dialog.appendChild(title);
  const help=document.createElement('p');help.textContent='Measured on this browser only. Download the JSON for comparison; no data is uploaded.';dialog.appendChild(help);
  const pre=document.createElement('pre');pre.style.cssText='white-space:pre-wrap;font:12px monospace';dialog.appendChild(pre);
  const download=document.createElement('button');download.textContent='DOWNLOAD JSON';download.type='button';
  download.addEventListener('click',()=>{const data=snapshot(),blob=new Blob([JSON.stringify(data,null,2)],{type:'application/json'}),url=URL.createObjectURL(blob),link=document.createElement('a');link.href=url;link.download='aura-performance-'+Date.now()+'.json';link.click();setTimeout(()=>URL.revokeObjectURL(url),1000);});dialog.appendChild(download);
  const close=document.createElement('button');close.type='button';close.textContent='CLOSE';close.addEventListener('click',()=>dialog.close());dialog.appendChild(close);
  button.addEventListener('click',()=>{const r=snapshot();pre.textContent=JSON.stringify({environment:r.environment,rafFps:r.rafFps,frameTimeMs:r.frameTimeMs,longFrames:r.longFrames,engineFrames:r.engine?.sample_count,engineRenderFps:r.engine?.delivered_render_fps},null,2);dialog.showModal();});
  document.body.appendChild(button);document.body.appendChild(dialog);
  function setMode(mode){
    const was=active;lastMode=mode;active=mode==='playing';
    button.hidden=!['menu','paused','options'].includes(mode);
    if(active&&!was){previous=0;graphics();}
    if(!active&&was)previous=0;
    if(active&&dialog.open)dialog.close();
  }
  window.__auraPerformance={enabled:true,detailed:params.get('perf_detail')==='1',rasterRatio,setMode,engineReport:report=>{engine=report;},snapshot,stats};
  setMode('menu');requestAnimationFrame(tick);
  fetch('build.json').then(r=>r.json()).then(value=>{window.__auraPerfBuild=value;}).catch(()=>{});
})();
