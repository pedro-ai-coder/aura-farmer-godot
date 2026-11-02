// Real Chromium/WebGL2, actual canvas input and trusted-click ZIP downloads.
const {chromium}=require('playwright');
const fs=require('node:fs');
const path=require('node:path');
const out=process.env.QA_EVIDENCE||'tests/qa_recorder/evidence/web';
(async()=>{
 fs.mkdirSync(out,{recursive:true});
 const browser=await chromium.launch({headless:true,args:['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
 for(const [width,height,dpr] of [[1600,900,1],[1050,810,1],[844,390,1],[1280,720,1],[1050,810,1.25],[844,390,2]]){
  const context=await browser.newContext({viewport:{width,height},deviceScaleFactor:dpr,acceptDownloads:true,recordVideo:{dir:out,size:{width,height}}});
  const page=await context.newPage();const errors=[];
  // Video annotation only; passive listeners never inject game input or take focus.
  await page.addInitScript(()=>addEventListener('DOMContentLoaded',()=>{
   const label=document.createElement('div');label.id='qa-evidence-action';
   label.style.cssText='position:fixed;left:8px;bottom:26px;z-index:99999;pointer-events:none;background:#111d;color:white;padding:5px;font:13px monospace';
   document.body.appendChild(label);
   addEventListener('pointerdown',e=>{label.textContent=`POINTER ${Math.round(e.clientX)},${Math.round(e.clientY)}`},{capture:true,passive:true});
   addEventListener('keydown',e=>{label.textContent=`KEY ${e.key}`},{capture:true,passive:true});
   addEventListener('wheel',()=>{label.textContent='SCROLL'},{capture:true,passive:true});
  }));
  page.on('pageerror',e=>errors.push(e.message));
  page.on('console',m=>{if(m.type()==='error' && /SCRIPT ERROR|Parse Error/.test(m.text()))errors.push(m.text());});
  await page.goto(process.env.QA_URL||'http://127.0.0.1:8080',{waitUntil:'networkidle',timeout:120000});
  await page.waitForFunction(()=>window.__qaReviewState?.controls.start,{timeout:90000});
  const tag=`${width}-${height}-dpr${dpr}`;
  const before=await page.evaluate(()=>localStorage.getItem('aura-farmer:profile:v2'));
  async function point(name){
   const point=await page.evaluate(n=>{const s=window.__qaReviewState,r=s.controls[n],c=document.getElementById('canvas').getBoundingClientRect();if(!r)throw Error('Missing control '+n);return [c.x+(r[0]+r[2]/2)*c.width/s.view[0],c.y+(r[1]+r[3]/2)*c.height/s.view[1]]},name);
   return point;
  }
  async function click(name){await page.mouse.click(...await point(name),{delay:350});}
  async function closed(){
   await page.waitForFunction(()=>{const s=window.__qaReviewState;return !s.scenario_open&&!s.modal.card_visible&&!s.modal.shade_visible&&!s.modal.focus_in_modal});
   if(await page.evaluate(()=>window.__qaReviewState.mode)!=='menu')throw Error('Modal changed normal game mode');
  }
  async function shot(label){await page.screenshot({path:path.join(out,`${label}-${tag}.png`)});}
  async function scrollBottom(){await page.mouse.move(...await point('qa_scroll'));await page.mouse.wheel(0,2000);await page.waitForTimeout(400);}
  async function open(){await click('scenario');await page.waitForFunction(()=>window.__qaReviewState?.scenario_open);await page.waitForTimeout(300);}
  if(await page.evaluate(()=>window.__qaReviewState.recording))throw Error('Recording enabled by default');
  // Observation helpers only: every mutation below uses real pointer/keyboard input.
  let fullscreen=false;
  if(width===1050&&dpr===1){
   await page.locator('#aura-fullscreen').click();
   await page.waitForTimeout(500);
   fullscreen=await page.evaluate(()=>!!document.fullscreenElement);
  }
  await open();await shot('opened');
  const rects=await page.evaluate(()=>window.__qaReviewState);
  for(const name of ['qa_close','qa_cancel','qa_launch']){
   const [x,y,w,h]=rects.controls[name];
   if(x<0||y<0||w<=0||h<=0||x+w>rects.view[0]||y+h>rects.view[1])throw Error('Unreachable '+name);
  }
  await scrollBottom();await shot('scrolled');await click('qa_cancel');await closed();await shot('cancel-closed');
  await open();await scrollBottom();await click('qa_close');await closed();await shot('header-closed');
  await open();
  // Scroll the seed into the clipping rectangle, then focus it with a real click.
  for(let i=0;i<20;i++){
   const delta=await page.evaluate(()=>{const c=window.__qaReviewState.controls,r=c.qa_seed,v=c.qa_scroll;return r[1]<v[1]? -100:r[1]+r[3]>v[1]+v[3]?100:0});
   if(!delta)break;
   await page.mouse.move(...await point('qa_scroll'));await page.mouse.wheel(0,delta);await page.waitForTimeout(300);
  }
  await click('qa_seed');
  await page.waitForFunction(()=>window.__qaReviewState.modal.seed_focused);
  await page.waitForTimeout(650);
  if(!await page.evaluate(()=>window.__qaReviewState.modal.seed_focused))throw Error('Normal UI stole seed focus');
  await page.keyboard.press('Enter');await page.waitForTimeout(350);
  if(await page.evaluate(()=>window.__qaReviewState.mode)!=='menu')throw Error('Seed Enter started hidden gameplay');
  await shot('seed-enter');await page.keyboard.press('Escape');await closed();await shot('escape-closed');
  for(let i=0;i<2;i++){await open();await page.keyboard.press('Escape');await closed();}
  if(fullscreen){await page.evaluate(()=>document.exitFullscreen());await page.waitForTimeout(500);await open();await click('qa_close');await closed();}
  // Browser zoom shortcuts are attempted and reported; headless Chromium may ignore them.
  const zoomBefore=await page.evaluate(()=>devicePixelRatio);
  await page.keyboard.press('Control+-');await page.waitForTimeout(400);
  const zoomAfter=await page.evaluate(()=>devicePixelRatio);
  await open();await click('qa_cancel');await closed();
  await page.keyboard.press('Control+0');await page.waitForTimeout(400);
  // Start the canonical Wave 5 synthetic fixture through the real form.
  await open();await click('qa_enable');await click('qa_select');
  await page.keyboard.press('Home');for(let i=0;i<3;i++)await page.keyboard.press('ArrowDown');
  await page.keyboard.press('Enter');await click('qa_launch');
  await page.waitForFunction(()=>window.__qaReviewState.mode==='playing'&&window.__qaReviewState.synthetic&&window.__qaReviewState.scenario_id==='wave5'&&!window.__qaReviewState.scenario_open);
  await shot('wave5');
  // Fresh normal session to prove closed/hidden modal does not trap gameplay or recorder input.
  await page.reload({waitUntil:'networkidle'});await page.waitForFunction(()=>window.__qaReviewState?.controls.start);
  await click('start');
  await page.waitForFunction(()=>window.__qaReviewState.recording);
  await page.keyboard.press('Enter');
  await page.waitForFunction(()=>window.__qaReviewState.mode==='playing');
  await page.keyboard.down('d');await page.waitForTimeout(1000);await page.keyboard.up('d');
  await page.waitForTimeout(4000);
  await page.keyboard.press('Escape');
  await page.waitForFunction(()=>window.__qaReviewState.mode==='paused');
  await click('mark');
  await page.waitForTimeout(1200);
  await page.screenshot({path:path.join(out,`paused-${tag}.png`)});
  const downloadPromise=page.waitForEvent('download',{timeout:15000});
  await click('export');const download=await downloadPromise;
  await download.saveAs(path.join(out,`session-${tag}.zip`));
  await page.waitForFunction(()=>!window.__qaReviewState.recording);
  const after=await page.evaluate(()=>localStorage.getItem('aura-farmer:profile:v2'));
  if(before!==after)throw Error('QA wrote canonical profile');
  if(errors.length)throw Error(errors.join('\n'));
  fs.writeFileSync(path.join(out,`browser-${tag}.json`),JSON.stringify({viewport:[width,height],deviceScaleFactor:dpr,fullscreen,zoomBefore,zoomAfter,zoomShortcutSupported:zoomBefore!==zoomAfter,profileUnchanged:true,modal:await page.evaluate(()=>window.__qaReviewState.modal),errors,renderer:'Chromium WebGL2 software; not physical-device performance'},null,2));
  await context.close();
 }
 await browser.close();console.log('PASS: real WebGL dialog close/header/footer/Escape, visible actions, recording, pause, ZIP download and profile isolation at desktop, creator screenshot size and mobile landscape viewports');
})().catch(e=>{console.error(e);process.exit(1)});
