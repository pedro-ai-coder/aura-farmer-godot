"""Build clearly labeled sheets from actual native Godot captures (no UI synthesis)."""
import hashlib,json,gzip,subprocess,io
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2]
CAPTURES=ROOT.parent/'evidence-final'
OUT=Path(__file__).parent/'evidence';OUT.mkdir(exist_ok=True)
SOURCES=['scripts/solo_run.gd','scripts/passive_feedback.gd','scripts/passive_feedback_view.gd','scripts/clean_cut_skin.gd','scripts/clean_cut_secondary.gd']
source_hashes={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in SOURCES}
font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',18)
provenance={'baseline_commit':'59b2595885cb11342607fbcbbec24855de525935','engine':'4.7.2.stable.official.ed1daf0bf','renderer':'Compatibility / native X11 Mesa llvmpipe','source_sha256':source_hashes,'new_art_resources':0,'review_status':'CREATOR_REVIEW_REQUIRED','capture_method':'DisplayServer.screen_get_image(0), exact client region; native scripted canonical simulation, not human/browser/physical-device evidence','image_encoding':'WebP quality 94 for standalone native frames; 92 for labeled sheets. Frames are not retouched. Sheet labels/crops are outside gameplay evidence.','frames':[],'sheets':{},'reused_approved_icons':[]}
reports=[]
for p in sorted(CAPTURES.glob('*.json')):
 if p.name.startswith('performance-'):continue
 data=json.loads(p.read_text())
 assert data['source_sha256']==source_hashes,('Stale capture',p)
 for state in data['states']:
  f=CAPTURES/state['file'];im=Image.open(f)
  expected=tuple(map(int,p.stem.split('-')[-1].split('x')))
  assert im.size==expected,(f,im.size,expected)
 reports.append({'report':p.name,**data})
for after in [r for r in reports if r['report'].startswith('after-all-')]:
 before=next(r for r in reports if r['report']==after['report'].replace('after-','before-',1))
 assert len(after['states'])==len(before['states'])
 for a,b in zip(after['states'],before['states']):
  for key in ['frame','mode','time','hp','shield','damage','rng','cook','timers']:
   assert a[key]==b[key],('Non-equivalent comparison state',a['file'],key)
with gzip.open(OUT/'runtime-records.json.gz','wt') as f:json.dump(reports,f,separators=(',',':'))

def native(stage,state,w=844,h=390,frame=17,suite='all'):
 return CAPTURES/f'{stage}-{suite}-{state}-{w}x{h}-{frame:03d}.png'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def encode_webp(im,dest,quality):
 for method in [6,4]:
  buffer=io.BytesIO();im.save(buffer,'WEBP',quality=quality,method=method)
  data=buffer.getvalue()
  if len(data)>1000 and data[:4]==b'RIFF' and data[8:12]==b'WEBP':break
 else:raise ValueError('Empty WebP encoder output: '+str(dest))
 temp=dest.with_suffix('.tmp');temp.write_bytes(data);temp.replace(dest)
 with Image.open(dest) as check:
  check.load();assert check.size==im.size
 assert dest.stat().st_size==len(data)

def save_frame(stage,state,w,h,frame=17,suite='all'):
 src=native(stage,state,w,h,frame,suite);dest=OUT/f'{stage}-{state}-{w}x{h}.webp'
 encode_webp(Image.open(src).convert('RGB'),dest,94)
 provenance['frames'].append({'path':str(dest.relative_to(ROOT)),'source_capture':src.name,'native_dimensions':[w,h],'source_png_sha256':sha(src),'webp_sha256':sha(dest)})
 return dest

def sheet(name,items,columns=2,thumb_width=None):
 images=[Image.open(p).convert('RGB') for p,label in items]
 width=thumb_width or images[0].width
 heights=[round(im.height*width/im.width) for im in images]
 band=38;rows=(len(images)+columns-1)//columns
 row_heights=[max(heights[i*columns:(i+1)*columns]) for i in range(rows)]
 canvas=Image.new('RGB',(width*columns,sum(row_heights)+band*rows),'#0b2034');d=ImageDraw.Draw(canvas)
 mappings=[]
 for i,((path,label),im) in enumerate(zip(items,images)):
  x=i%columns*width;y=sum(row_heights[:i//columns])+band*(i//columns);height=heights[i]
  if im.size!=(width,height):im=im.resize((width,height),Image.Resampling.LANCZOS)
  canvas.paste(im,(x,y+band));d.text((x+12,y+8),label,font=font,fill='#fff9e9')
  mappings.append({'capture':path.name,'label':label,'source_sha256':sha(path)})
 dest=OUT/(name+'.webp');encode_webp(canvas,dest,92)
 provenance['sheets'][name]={'path':str(dest.relative_to(ROOT)),'sha256':sha(dest),'panels':mappings}

states=[('acquired',17,'Passive acquired'),('level',17,'Existing item level up'),('timed-active',17,'Timed buffs active'),('stack-six',17,'Actual sixth-hit warning'),('healing',17,'Effective HP restored'),('shield',17,'Actual shield grant'),('legendary',17,'Confirmed Legendary acquisition'),('dense',10,'Dense stress fixture (high HP) + real effects')]
for w,h in [(1600,900),(844,390)]:
 for state,frame,_ in states:save_frame('after',state,w,h,frame)
 save_frame('before','acquired',w,h)
 sheet('before-after-desktop' if w==1600 else 'before-after-mobile',[(native(stage,'acquired',w,h),label) for stage,label in [('before','BEFORE — production HUD / feedback adapter disabled'),('after','AFTER — confirmed acquisition, actual value')]],thumb_width=w)
 sheet('desktop-feedback' if w==1600 else 'mobile-feedback',[(native('after',s,w,h,f),label+f' — native {w}×{h}') for s,f,label in states],thumb_width=800 if w==1600 else 844)
sheet('timers-stacks',[(native('after',s,frame=f),label) for s,f,label in [('timed-active',17,'Active deadlines and positional zone'),('timed-expired',189,'Actual expiry — slot levels return'),('stack-low',17,'Early real primary-hit stacks'),('stack-six',17,'6 / 7 — next primary hit bursts'),('stack-burst',10,'Actual seventh hit / two-second recovery'),('healing',17,'Actual eighth hit healing, after support/caps')]])
sheet('legendary-effects',[(native('after',s,frame=3 if s=='no-u' else 17),label) for s,label in [('cinema-flex','Absolute Cinema — successful Flex'),('wsquad-flex','W Squad — real six-second window'),('too-sigma','Too Sigma — nonfatal threshold shield'),('no-u','No U — actual 200 U pulse activation')]])
sheet('dense-reduced',[(native('after','dense',frame=10),'Dense high-HP test fixture — real danger remains on top'),(native('after','absorption',frame=50),'Actual mitigated shield absorption'),(native('after','stack-burst',frame=10,suite='motion'),'Motion — brief localized ring / restrained entrance'),(native('after','stack-burst',frame=10,suite='reduced'),'Reduced Motion — same event, static treatment')])
sheet('build-inspection',[(native('after','build',1600,900),'Desktop — real equipped levels and compact values'),(native('after','build'),'Mobile — existing scrollable inspection')],columns=1,thumb_width=1200)
# Match frame count, resolution and fixture state before encoding the short clip.
for stage in ['before','after']:
 subprocess.run(['ffmpeg','-y','-loglevel','error','-i',str(CAPTURES/(stage+'.avi')),'-an','-c:v','libx264','-preset','medium','-crf','25','-pix_fmt','yuv420p',str(OUT/(stage+'.mp4'))],check=True)
subprocess.run(['ffmpeg','-y','-loglevel','error','-i',str(OUT/'before.mp4'),'-i',str(OUT/'after.mp4'),'-filter_complex',"[0:v]pad=iw:ih+36:0:36:color=0x0b2034,drawtext=text='BEFORE - native scripted run':x=14:y=8:fontsize=20:fontcolor=white[a];[1:v]pad=iw:ih+36:0:36:color=0x0b2034,drawtext=text='AFTER - same canonical states':x=14:y=8:fontsize=20:fontcolor=white[b];[a][b]hstack=inputs=2[v]",'-map','[v]','-an','-c:v','libx264','-preset','medium','-crf','25','-pix_fmt','yuv420p',str(OUT/'before-after.mp4')],check=True)
# Labels occupy a separate comparison band in the movie; no values are painted.
for stage in ['before','after']:(OUT/(stage+'.mp4')).unlink()
for row in json.loads((ROOT/'assets/runtime-icons/manifest.json').read_text())['icons']:
 if row['category']=='passive':provenance['reused_approved_icons'].append({'id':row['id'],'path':row['resource_path'],'sha256':row['promoted_sha256']})
for row in provenance['reused_approved_icons']:
 assert sha(ROOT/row['path'].removeprefix('res://'))==row['sha256']
provenance['video']={'path':'tests/passive_feedback/evidence/before-after.mp4','sha256':sha(OUT/'before-after.mp4'),'format':'2560×756 with separate caption band; 1280×720 native frames per side, offline fixed 30 FPS; not delivered FPS','baseline_mode':'same source with read-only adapter disabled, #99 weapon presentation retained'}
(OUT/'provenance.json').write_text(json.dumps(provenance,indent=2)+'\n')
print('BUILT',len(provenance['frames']),'native frames,',len(provenance['sheets']),'comparison sheets and short real runtime video')
