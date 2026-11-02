// Real Chromium/WebGL2, actual canvas input and trusted-click ZIP downloads.
const {chromium}=require('playwright');
const fs=require('node:fs');
const path=require('node:path');
const out=process.env.QA_EVIDENCE||'tests/qa_recorder/evidence/web';
(async()=>{
 fs.mkdirSync(out,{recursive:true});
 const browser=await chromium.launch({headless:true,args:['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
 for(const [width,height] of [[1600,900],[1050,810],[844,390]]){
  const context=await browser.newContext({viewport:{width,height},acceptDownloads:true,recordVideo:{dir:out,size:{width,height}}});
  const page=await context.newPage();const errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  page.on('console',m=>{if(m.type()==='error' && /SCRIPT ERROR|Parse Error/.test(m.text()))errors.push(m.text());});
  await page.goto(process.env.QA_URL||'http://127.0.0.1:8080',{waitUntil:'networkidle',timeout:120000});
  await page.waitForFunction(()=>window.__qaReviewState?.controls.start,{timeout:90000});
  const before=await page.evaluate(()=>localStorage.getItem('aura-farmer:profile:v2'));
  async function click(name){
   const point=await page.evaluate(n=>{const s=window.__qaReviewState,r=s.controls[n],c=document.getElementById('canvas').getBoundingClientRect();if(!r)throw Error('Missing control '+n);return [c.x+(r[0]+r[2]/2)*c.width/s.view[0],c.y+(r[1]+r[3]/2)*c.height/s.view[1]]},name);
   await page.mouse.click(...point);
  }
  if(await page.evaluate(()=>window.__qaReviewState.recording))throw Error('Recording enabled by default');
  // Real mouse interaction with fixed header/footer, at both desktop and 844x390.
  await click('scenario');
  await page.waitForFunction(()=>window.__qaReviewState?.scenario_open===true);
  await page.waitForFunction(()=>window.__qaReviewState?.controls.qa_close);
  const rects=await page.evaluate(()=>({
   view:window.__qaReviewState.view,
   close:window.__qaReviewState.controls.qa_close,
   cancel:window.__qaReviewState.controls.qa_cancel,
   launch:window.__qaReviewState.controls.qa_launch
  }));
  for(const name of ['close','cancel','launch']){
   const [x,y,w,h]=rects[name];
   if(x<0 || y<0 || w<=0 || h<=0 || x+w>rects.view[0] || y+h>rects.view[1])
    throw Error('Scenario '+name+' button outside viewport '+width+'x'+height);
  }
  await page.screenshot({path:path.join(out,`scenario-dialog-${width}.png`)});
  await click('qa_close');
  await page.waitForFunction(()=>window.__qaReviewState?.scenario_open===false);
  await click('scenario');
  await page.waitForFunction(()=>window.__qaReviewState?.scenario_open===true);
  await page.mouse.move(width/2,height/2);
  await page.mouse.wheel(0,1500);
  await click('qa_cancel');
  await page.waitForFunction(()=>window.__qaReviewState?.scenario_open===false);
  await click('scenario');
  await page.waitForFunction(()=>window.__qaReviewState?.scenario_open===true);
  await page.keyboard.press('Escape');
  await page.waitForFunction(()=>window.__qaReviewState?.scenario_open===false);
  await page.screenshot({path:path.join(out,`off-${width}.png`)});
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
  await page.screenshot({path:path.join(out,`paused-${width}.png`)});
  const downloadPromise=page.waitForEvent('download',{timeout:15000});
  await click('export');const download=await downloadPromise;
  await download.saveAs(path.join(out,`session-${width}.zip`));
  await page.waitForFunction(()=>!window.__qaReviewState.recording);
  const after=await page.evaluate(()=>localStorage.getItem('aura-farmer:profile:v2'));
  if(before!==after)throw Error('QA wrote canonical profile');
  if(errors.length)throw Error(errors.join('\n'));
  fs.writeFileSync(path.join(out,`browser-${width}.json`),JSON.stringify({viewport:[width,height],profileUnchanged:true,errors,renderer:'Chromium WebGL2 software; not physical-device performance'},null,2));
  await context.close();
 }
 await browser.close();console.log('PASS: real WebGL dialog close/header/footer/Escape, visible actions, recording, pause, ZIP download and profile isolation at desktop, creator screenshot size and mobile landscape viewports');
})().catch(e=>{console.error(e);process.exit(1)});
