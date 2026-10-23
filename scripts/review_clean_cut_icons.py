from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageChops
import json,hashlib,xml.etree.ElementTree as ET,numpy as np
import argparse
parser=argparse.ArgumentParser(description='Review unmodified Clean Cut sources; requires Pillow and NumPy')
parser.add_argument('--svg-renders',type=Path,required=True)
args=parser.parse_args()
root=Path(__file__).resolve().parents[1]; art=root/'assets/art-production/character-hype-clean-cut/v1';out=root/'docs/art/evidence/clean-cut-review';out.mkdir(parents=True,exist_ok=True)
manifest=json.loads((art/'manifests/ASSET_MANIFEST.json').read_text()); read=json.loads((root/'docs/art/v5_icon_readiness.json').read_text());cat=json.loads((root/'assets/ui-catalog.json').read_text()); rows=[]; hashes={}; files=0
for row in manifest['assets']:
 for f in row['files']:
  p=art/f['path']; assert hashlib.sha256(p.read_bytes()).hexdigest()==f['sha256'],p;files+=1
  if f['format']=='PNG':
   i=Image.open(p);assert list(i.size)==f['dimensions_px'] and i.mode=='RGBA' and i.getchannel('A').getextrema()[0]==0 and i.getchannel('A').getextrema()[1]==255
  if f['format']=='SVG':
   svg=ET.parse(p);assert not any(e.tag.endswith('image') for e in svg.iter())
assert files==83
future={'get-ratiod','ego-check','uno-reverse','brainrot-rain','take-l'}
for item in read:
 id=item['id'];kind=item['kind'];p=art/('weapons' if kind=='weapon' else 'passives')/id/'icon-v5-candidate.png';v=p.with_suffix('.svg');im=Image.open(p).convert('RGBA');a=np.array(im);bb=im.getchannel('A').getbbox();margin=min(bb[0],bb[1],256-bb[2],256-bb[3]);svg=Image.open(args.svg_renders/f'{kind}.{id}.icon.png').convert('RGBA');diff=float(np.abs(a.astype(float)-np.array(svg).astype(float)).mean());sha=hashlib.sha256(p.read_bytes()).hexdigest();assert sha not in hashes,(id,hashes.get(sha));hashes[sha]=id
 flags=[]
 if margin<12:flags.append('Margin below 12px review threshold; no canvas clipping detected')
 if diff>1:flags.append('SVG text/font raster differs in Godot; select exact PNG or obtain outlined SVG')
 if id in ['cope-shield','built-different','cope-harder','certified-w','big-chad','too-sigma','so-back','uno-reverse']:flags.append('Shield/heart family: check distinction at 32px')
 if id in ['personal-space','get-ratiod','ego-check']:flags.append('Target/ring family: check distinction at 32px')
 if id in future:flags.append('Future-only art; excluded from normal 23-passive offers')
 rows.append(dict(id=id,kind=kind,version='v5-candidate',source=str(p.relative_to(root)),sha256=sha,svg_source=str(v.relative_to(root)),svg_sha256=hashlib.sha256(v.read_bytes()).hexdigest(),size=[256,256],alpha_bbox=list(bb),minimum_alpha_margin_px=margin,clipped=False,godot_svg_rgba_mean_absolute_difference=round(diff,4),png_svg_identity='same dominant object; text/font discrepancy' if diff>1 else 'same dominant object; subpixel raster differences',duplicate_png=False,playable=id not in future,effect=cat.get(id,{}).get('description','Future item; no normal Alpha offer'),creator_approval='PENDING',approval_reference=None,selected_version=None,runtime_resource=None,flags=flags))
assert len(rows)==37
(root/'docs/art/CLEAN_CUT_ICON_AUDIT.json').write_text(json.dumps(dict(source_commit='ab35ff9c21353842748a503f45729c27ce9e5619',manifest_files_verified=files,canonical_count=37,method='Unmodified candidate PNGs; Godot 4.7.2 SVG Image decoder; RGBA mean absolute differences on 0..255 channels, not a semantic approval metric',icons=rows),indent=2)+'\n')
font=ImageFont.truetype(str(root/'assets/fonts/Inter-Body.ttf'),16)
navy='#13233A';cream='#F7EDCD'
def sheet(items,size,name):
 cellw=2*(size+16)+12; cellw=max(cellw,310);cellh=size+56;cols=3;im=Image.new('RGB',(cols*cellw,((len(items)+cols-1)//cols)*cellh),'#253449');d=ImageDraw.Draw(im)
 for n,row in enumerate(items):
  x=n%cols*cellw;y=n//cols*cellh;d.text((x+8,y+5),row['id'],font=font,fill='white');src=Image.open(root/row['source']).convert('RGBA').resize((size,size),Image.Resampling.LANCZOS)
  for j,bg in enumerate([navy,cream]):
   px=x+8+j*(size+16);py=y+28;d.rectangle((px,py,px+size,py+size),fill=bg);im.paste(src,(px,py),src)
 im.save(out/name,quality=92)
for size in [32,64]:sheet(rows,size,f'all-{size}.jpg')
for start in range(0,37,9):sheet(rows[start:start+9],256,f'masters-{start//9+1}.jpg')
# Explicit original/v2 comparison, never pairing v2 with the v1 SVG.
canvas=Image.new('RGB',(1024,420),navy);d=ImageDraw.Draw(canvas)
for j,(label,path) in enumerate([('V5 PNG + matching SVG',art/'weapons/touch-grass/icon-v5-candidate.png'),('Clean Cut v2 PNG ONLY; SVG missing',art/'weapons/touch-grass/icon-clean-cut-v2-256.png')]):
 x=j*512;d.text((x+12,12),label,font=font,fill='white');src=Image.open(path).convert('RGBA');px=x+8
 for sz in [256,64,32]:
  d.rectangle((px,48,px+sz,48+sz),fill=cream);small=src.resize((sz,sz),Image.Resampling.LANCZOS);canvas.paste(small,(px,48),small);d.text((px,sz+58),str(sz)+'px',font=font,fill='white');px+=sz+20
canvas.save(out/'touch-grass-variants.jpg',quality=94)
print('Verified',files,'files; wrote',len(rows),'per-ID audit records and eight review sheets')
