#!/usr/bin/env python3
"""Assemble labeled comparisons from genuine Godot captures; never paints runtime UI."""
import argparse,hashlib,json,shutil
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
p=argparse.ArgumentParser();p.add_argument('--before',type=Path,required=True);p.add_argument('--after',type=Path,required=True);args=p.parse_args()
root=Path(__file__).resolve().parents[2];out=root/'tests/hud_v2/evidence';out.mkdir(exist_ok=True)
font=ImageFont.truetype(str(root/'assets/fonts/hero-clash/ArchivoBlack.ttf'),24)
small=ImageFont.truetype(str(root/'assets/fonts/hero-clash/Archivo.ttf'),17)
rows=[]
for label,folder in [('before',args.before),('after',args.after)]:
 target=out/label;target.mkdir(exist_ok=True)
 for f in sorted(folder.glob('*.png')):
  image=Image.open(f).convert('RGB');dest=target/(f.stem+'.jpg');image.save(dest,quality=90)
  rows.append({'file':str(dest.relative_to(out)),'pixels':list(image.size),'source_png_sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'jpeg_sha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'kind':'actual native Godot state fixture','baseline':label=='before'})
 for f in folder.glob('report-*.json'):shutil.copy(f,target/f.name)
def compare(a,b,title_a,title_b,name,width=1000):
 a=Image.open(a).convert('RGB');b=Image.open(b).convert('RGB')
 height=round(a.height*width/a.width)
 canvas=Image.new('RGB',(width*2,height+54),'#102236');d=ImageDraw.Draw(canvas)
 d.text((18,12),title_a,font=font,fill='#fff9e9');d.text((width+18,12),title_b,font=font,fill='#ffce30')
 canvas.paste(a.resize((width,height),Image.Resampling.LANCZOS),(0,54));canvas.paste(b.resize((width,height),Image.Resampling.LANCZOS),(width,54));canvas.save(out/name,quality=92)
compare(root/'tests/hud_v2/reference/creator-hud-v2.png',args.after/'start-1600x900.png','CREATOR COMPOSITION REFERENCE','ACTUAL GODOT / HUD V2','reference-vs-runtime.jpg')
for size in ['1600x900','844x390','390x844']:
 compare(args.before/f'start-{size}.png',args.after/f'start-{size}.png','BEFORE / PR #82','AFTER / HUD V2',f'before-after-{size}.jpg',780 if size=='390x844' else 1000)
# Matched native crops, with review-only labels outside every crop.
entries=[('PLAYER / FULL HP','start',(20,30,700,218)),('PLAYER / SHIELD','shield',(20,30,700,218)),('PLAYER / LOW HP','low-hp',(20,30,700,218)),('FLEX / 9%','start',(1275,560,1598,895)),('FLEX / READY','ready',(1275,560,1598,895)),('FLEX / ACTIVE','active',(1275,560,1598,895)),('FLEX / RECOVERY','recovery',(1275,560,1598,895)),('PAUSE / FOCUS','pause-focus',(1450,30,1598,180)),('PAUSE / PRESSED','pause-pressed',(1450,30,1598,180))]
gallery=Image.new('RGB',(1440,1035),'#102236');d=ImageDraw.Draw(gallery)
for i,(title,state,box) in enumerate(entries):
 x=(i%3)*480;y=(i//3)*345
 d.text((x+18,y+12),title,font=small,fill='#ffce30')
 crop=Image.open(args.after/f'{state}-1600x900.png').convert('RGB').crop(box);crop.thumbnail((450,286),Image.Resampling.LANCZOS)
 gallery.paste(crop,(x+(480-crop.width)//2,y+45))
gallery.save(out/'component-states.jpg',quality=92)
(out/'capture-manifest.json').write_text(json.dumps({'engine':'4.7.2.stable.official.ed1daf0bf','renderer':'Compatibility / Mesa llvmpipe / native X11','baseline_commit':'499baf14c28b4b3124660f47217e37495ca0be52','capture_script':'tests/hud_v2/capture.gd','human_gameplay':False,'browser':False,'physical_device':False,'review_composites':'Only resizing, cropping and review labels around actual outputs. Raw PNG SHA-256 recorded below; CI artifact retains PNG outputs.','reference_sha256':hashlib.sha256((root/'tests/hud_v2/reference/creator-hud-v2.png').read_bytes()).hexdigest(),'captures':rows},indent=2)+'\n')
print('Prepared',len(rows),'actual screenshots and five labeled review comparisons/galleries')
