// Real Chromium / exported Wasm. Coordinates come from inspected native menu.
const {chromium}=require('playwright');
const fs=require('fs');
(async()=>{
 const output=process.argv[2];fs.mkdirSync(output,{recursive:true});
 const browser=await chromium.launch({headless:true,executablePath:process.env.CHROMIUM_BIN||'/usr/bin/chromium',args:['--no-sandbox','--enable-unsafe-swiftshader','--use-gl=angle','--use-angle=swiftshader']});
 const page=await browser.newPage({viewport:{width:1280,height:720}});
 const logs=[],errors=[],responses=[];
 page.on('console',m=>{logs.push(m.text());if(m.type()==='error')errors.push(m.text());});page.on('pageerror',e=>errors.push(e.message));
 page.on('response',r=>{if(r.status()>=400)responses.push({url:r.url(),status:r.status()});});
 await page.goto('http://127.0.0.1:8765');
 await page.waitForFunction(()=>document.querySelector('canvas'),{timeout:30000});
 for(let i=0;i<60&&!logs.some(s=>s.includes('valid pinned candidate / eight directions'));i++)await page.waitForTimeout(500);
 if(!logs.some(s=>s.includes('valid pinned candidate / eight directions')))throw Error('Pinned candidate did not prepare');
 await page.screenshot({path:output+'/garage.png'});
 await page.mouse.click(210,360);await page.waitForTimeout(700);await page.screenshot({path:output+'/selection.png'});
 // Return to Garage through the real back control; keyboard Escape is canonical.
 await page.keyboard.press('Escape');await page.waitForTimeout(500);
 await page.mouse.click(210,280);await page.waitForTimeout(900);
 await page.keyboard.down('d');await page.waitForTimeout(700);await page.keyboard.up('d');
 await page.screenshot({path:output+'/candidate.png'});
 await page.keyboard.press('F8');await page.waitForTimeout(300);await page.screenshot({path:output+'/legacy.png'});
 await page.keyboard.press('F8');await page.keyboard.down('w');await page.waitForTimeout(500);await page.keyboard.up('w');
 await page.keyboard.press('Escape');await page.waitForTimeout(300);await page.screenshot({path:output+'/paused.png'});
 const result={browser:await browser.version(),source:'real Chromium, exported Godot Wasm; automation, not human testing',logs,errors,http_errors:responses,status:errors.length||responses.length?'FAIL':'PASS',assertions:['exported candidate decoded pixel hashes prepared','observed menu/selection/gameplay/A-B/pause screenshots require visual inspection']};
 fs.writeFileSync(output+'/results.json',JSON.stringify(result,null,2));await browser.close();if(errors.length||responses.length)process.exitCode=1;
})().catch(e=>{console.error(e);process.exitCode=1});
