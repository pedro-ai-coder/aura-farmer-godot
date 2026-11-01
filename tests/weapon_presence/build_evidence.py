"""Build labeled review media from actual Godot captures; never generate frames."""
import argparse,gzip,hashlib,json,math,subprocess
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('raw',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
raw=a.raw.resolve();out=a.output.resolve();out.mkdir(parents=True,exist_ok=True)
font=ImageFont.truetype(str(ROOT/'assets/fonts/hero-clash/Archivo.ttf'),22)
hashfile=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
reports={}
for stem in ['before-starters-1600x900','before-starters-844x390','after-starters-1600x900','after-remaining-1600x900','after-all-1600x900','after-all-844x390','after-dense-844x390','after-legendary-1600x900']:
    m=json.loads((raw/(stem+'.json')).read_text());reports[stem]=m
    if stem.startswith('after'):
        assert m.get('source_sha256'),stem
        for path,h in m['source_sha256'].items():assert hashfile(ROOT/path)==h,(stem,path,'stale capture')
before=reports['before-starters-1600x900']['states'];after=reports['after-starters-1600x900']['states']
for b,z in zip(before,after):
    assert (b['id'],b['appearance'],b['final_rng'],b['damage'],b['kills'])==(z['id'],z['appearance'],z['final_rng'],z['damage'],z['kills'])
records=[]
def still(source,target):
    im=Image.open(raw/source).convert('RGB');dest=out/target;im.save(dest,'WEBP',lossless=True,method=6)
    assert Image.open(dest).convert('RGB').tobytes()==im.tobytes()
    records.append(dict(file=target,dimensions=list(im.size),source_png=source,source_sha256=hashfile(raw/source),sha256=hashfile(dest),lossless_rgb=True))
still('after-all-ban-hammer-female-1600x900-16.png','desktop-combat.webp')
still('after-all-touch-grass-female-844x390-08.png','mobile-combat.webp')
still('after-dense-cope-shield-original-844x390-16.png','dense-mobile.webp')
# Each tile is a labeled crop from the actual arena, scaled for this contact sheet.
choices=[('no-cap','original',6),('ratio-blaster','original',6),('brainrot-feed','female',12),('keyboard-warrior','female',8),('ban-hammer','female',16),('touch-grass','female',8),('cope-shield','original',8),('chad-hands','female',8),('personal-space','original',8)]
sheet=Image.new('RGB',(1440,1008),'#102233');draw=ImageDraw.Draw(sheet)
for i,(id,appearance,frame) in enumerate(choices):
    source=raw/f'after-all-{id}-{appearance}-1600x900-{frame:02d}.png';im=Image.open(source).convert('RGB')
    tile=im.crop((620,270,1220,660)).resize((480,312),Image.Resampling.LANCZOS)
    x=(i%3)*480;y=(i//3)*336;sheet.paste(tile,(x,y+24));draw.text((x+10,y),id+' / '+appearance,font=font,fill='#fff9e9')
sheet.save(out/'nine-weapons.webp','WEBP',lossless=True,method=6)
sheet=Image.new('RGB',(1260,660),'#102233');draw=ImageDraw.Draw(sheet)
for i,(id,appearance) in enumerate([(id,appearance) for id in ['no-cap','keyboard-warrior','cope-shield'] for appearance in ['original','female']]):
    im=Image.open(raw/f'after-all-{id}-{appearance}-1600x900-08.png').convert('RGB')
    tile=im.crop((620,260,1160,650)).resize((420,303),Image.Resampling.LANCZOS)
    x=(i%3)*420;y=(i//3)*330;sheet.paste(tile,(x,y+27));draw.text((x+8,y),id+' / '+appearance,font=font,fill='#fff9e9')
sheet.save(out/'six-appearances.webp','WEBP',lossless=True,method=6)
for extent in ['1600x900','844x390']:
    w,h=map(int,extent.split('x'));scale=0.5 if w==1600 else 1.0;dw,dh=int(w*scale),int(h*scale)
    sheet=Image.new('RGB',(dw*2,dh+40),'#102233');draw=ImageDraw.Draw(sheet)
    for i,stage in enumerate(['before','after']):
        name=f'{stage}-'+('starters' if stage=='before' else 'all')+f'-keyboard-warrior-female-{extent}-08.png'
        im=Image.open(raw/name).convert('RGB')
        if scale!=1:im=im.resize((dw,dh),Image.Resampling.LANCZOS)
        sheet.paste(im,(i*dw,40));draw.text((i*dw+12,7),stage.upper()+f' / {extent} at {int(scale*100)}%',font=font,fill='#fff9e9')
    sheet.save(out/('before-after-desktop.webp' if w==1600 else 'before-after-mobile.webp'),'WEBP',lossless=True,method=6)
def run(cmd):subprocess.run(cmd,check=True,stdout=subprocess.DEVNULL)
videos=[]
for source,target in [('before-starters.avi','before-starters.mp4'),('after-starters.avi','after-starters.mp4'),('after-remaining.avi','remaining-weapons.mp4'),('legendary.avi','legendary.mp4')]:
    run(['ffmpeg','-y','-loglevel','error','-i',str(raw/source),'-an','-c:v','libx264','-preset','fast','-crf','23','-pix_fmt','yuv420p','-movflags','+faststart',str(out/target)])
    meta=json.loads(subprocess.check_output(['ffprobe','-v','error','-select_streams','v:0','-show_entries','stream=width,height,r_frame_rate,nb_frames,duration','-of','json',str(out/target)]))['streams'][0]
    videos.append(dict(file=target,sha256=hashfile(out/target),source_avi_sha256=hashfile(raw/source),**meta))
vf="[0:v]scale=640:360,setpts=PTS-STARTPTS[a];[1:v]scale=640:360,setpts=PTS-STARTPTS[b];[a][b]hstack=inputs=2,pad=1280:400:0:40:color=0x102233,drawtext=fontfile='"+str(ROOT/'assets/fonts/hero-clash/Archivo.ttf')+"':text='BEFORE - actual Godot':x=20:y=8:fontsize=24:fontcolor=white,drawtext=fontfile='"+str(ROOT/'assets/fonts/hero-clash/Archivo.ttf')+"':text='AFTER - actual Godot':x=660:y=8:fontsize=24:fontcolor=white[v]"
run(['ffmpeg','-y','-loglevel','error','-i',str(out/'before-starters.mp4'),'-i',str(out/'after-starters.mp4'),'-filter_complex',vf,'-map','[v]','-an','-c:v','libx264','-crf','22','-pix_fmt','yuv420p','-movflags','+faststart',str(out/'starter-before-after.mp4')])
perf=json.loads((raw/'performance-844x390.json').read_text());gzip_data=gzip.compress(json.dumps(perf,separators=(',',':')).encode(),mtime=0);(out/'performance-raw.json.gz').write_bytes(gzip_data)
summary={}
for label,flag in [('before',False),('after',True)]:
    rows=[r for r in perf if r['comparison']['after']==flag];metrics={}
    for key in ['draw_us','simulation_us','render_gpu_ms','render_cpu_ms']:
        values=sorted(v for r in rows for v in r['samples'][key] if key.endswith('_us') or v>0)
        metrics[key]=dict(samples=len(values),median=(values[(len(values)-1)//2]+values[len(values)//2])/2,p95=values[math.ceil(len(values)*.95)-1],p99=values[math.ceil(len(values)*.99)-1])
    summary[label]=metrics
(out/'performance.json').write_text(json.dumps(dict(scope='Four alternating native llvmpipe blocks, fixed 1/60 simulation; 45 warm-up + 120 retained frames each. Software-renderer costs only, not Android frame pacing.',window=[844,390],enemies_max=71,new_contacts_peak=31,new_gestures_peak=3,draw_calls='Not exposed by this Compatibility backend',metrics=summary,raw='performance-raw.json.gz',environment=perf[-1]['environment']),indent=2)+'\n')
(out/'provenance.json').write_text(json.dumps(dict(baseline='bd66c202595eabcdf7f8f23b28887f19b28d840b',native='Godot 4.7.2 Compatibility/X11 llvmpipe',not_human_web_or_device_testing=True,source_sha256=reports['after-starters-1600x900']['source_sha256'],matching_starter_simulation_verified=True,video_mode='Offline fixed 30 FPS Movie Maker; delivered FPS is not measured',videos=videos,stills=records,states=reports),indent=2)+'\n')
print(json.dumps(summary,indent=2));print('PASS: real clips, matching simulation, exact final source hashes, native captures and lossless screenshots')
