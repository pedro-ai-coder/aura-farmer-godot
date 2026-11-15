"""Pack newly drawn RGBA animation frames, never manufacture motion from cutouts.

Source PNGs are generated in the built-in image tool and retained unchanged.
Only crop to their 8x8 cells, discard isolated alpha specks, and add safe gutters.
No mirroring, pose duplication, repainting, rotation or frame interpolation.
"""
from pathlib import Path
from collections import deque
import argparse, hashlib, json, math
from statistics import median
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'source/hero-atlases-v2'
PACK=ROOT/'assets/production/heroes/full-atlases-v2'
HEROES={'the-sigma':'sigma','cool-kid':'cool-kid','pixel-vixen':'sigma','byte-baddie':'cool-kid','alpha-chad':'alpha','block-queen':'alpha'}
DIRECTIONS=['east','southeast','south','southwest','west','northwest','north','northeast']

def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def frame_names():
    names=[f'run-{d}-{p}' for d in DIRECTIONS for p in ['left-contact','left-passing','right-contact','right-passing']]
    names += [f'idle-{view}-{i}' for view in ['front','back'] for i in range(4)]
    names += [f'attack-{view}-{p}' for view in ['front','back'] for p in ['windup','execution','follow-through','recovery']]
    names += [f'hurt-{view}-{p}' for view in ['front','back'] for p in ['recoil','recovery']]
    names += ['flex-windup-0','flex-windup-1','flex-execution-0','flex-execution-1','flex-recovery-0','flex-recovery-1']
    names += [f'defeat-{p}' for p in ['stagger','buckle','fall','land','settle','rest']]
    assert len(names)==64
    return names

def remove_specks(image):
    w,h=image.size;alpha=image.getchannel('A');values=list(alpha.get_flattened_data())
    seen=bytearray(w*h);kept=bytearray(w*h)
    for start in range(w*h):
        if seen[start] or values[start]<32:continue
        queue=deque([start]);seen[start]=1;component=[]
        while queue:
            k=queue.popleft();component.append(k);x=k%w;y=k//w
            for dy in [-1,0,1]:
                for dx in [-1,0,1]:
                    nx,ny=x+dx,y+dy
                    if not (0<=nx<w and 0<=ny<h):continue
                    n=ny*w+nx
                    if not seen[n] and values[n]>=32:seen[n]=1;queue.append(n)
        if len(component)>=16:
            for k in component:kept[k]=1
    # Preserve the original antialiased alpha edge around every retained part.
    edge=bytearray(kept)
    for k,v in enumerate(kept):
        if not v:continue
        x,y=k%w,k//w
        for dy in [-1,0,1]:
            for dx in [-1,0,1]:
                nx,ny=x+dx,y+dy
                if 0<=nx<w and 0<=ny<h:edge[ny*w+nx]=1
    out=image.copy()
    # Generator padding contains saturated red RGB at alpha 1-3/255.
    # Discard this near-invisible padding, including adjacent edge noise;
    # retain original RGB and every alpha edge at 4/255 or above.
    out.putalpha(Image.frombytes('L',(w,h),bytes(v if edge[i] and v>=4 else 0 for i,v in enumerate(values))))
    # Canonicalize invisible RGB so previews/import filtering cannot reveal
    # generator padding. No visible pixel color is changed.
    pixels=bytearray(out.tobytes())
    for i in range(0,len(pixels),4):
        if pixels[i+3]==0:pixels[i:i+3]=b'\x00\x00\x00'
    out=Image.frombytes('RGBA',out.size,bytes(pixels))
    return out

def build(slug):
    source=SOURCE/slug/'authored-atlas.png'
    with Image.open(source) as opened:
        if opened.mode!='RGBA':raise ValueError(f'{slug}: true RGBA source required')
        image=opened.copy()
    if min(image.getchannel('A').getextrema())!=0:raise ValueError(f'{slug}: background is not transparent')
    target=PACK/slug;target.mkdir(parents=True,exist_ok=True)
    cell=max(192,math.ceil((max(image.size)/8+18)/16)*16)
    source_frames=[]
    for i in range(64):
        col,row=i%8,i//8
        box=(round(col*image.width/8),round(row*image.height/8),round((col+1)*image.width/8),round((row+1)*image.height/8))
        frame=remove_specks(image.crop(box))
        if frame.getbbox() is None:raise ValueError(f'{slug}: empty authored cell {i}')
        source_frames.append(frame)
    ground_fraction=median(frame.getbbox()[3]/frame.height for frame in source_frames[32:36])
    bottom_margin=max(12,math.ceil((1-ground_fraction)*max(image.size)/8)+3)
    pivot=[cell//2,cell-bottom_margin]
    atlas=Image.new('RGBA',(cell*8,cell*8))
    entries=[];frame_hashes=[];heights=[]
    for i,name in enumerate(frame_names()):
        col,row=i%8,i//8
        x0,y0=round(col*image.width/8),round(row*image.height/8)
        x1,y1=round((col+1)*image.width/8),round((row+1)*image.height/8)
        frame=source_frames[i]
        box=frame.getbbox()
        if box is None:raise ValueError(f'{slug}: empty authored cell {i}')
        # One shared ground anchor; retain frame placement within source cell.
        dx=pivot[0]-round(frame.width/2);dy=pivot[1]-round(frame.height*ground_fraction)
        if min(dx,dy)<0 or dx+frame.width>cell or dy+frame.height>cell:raise ValueError('Unsafe frame placement')
        atlas.paste(frame,(col*cell+dx,row*cell+dy))
        frame_hashes.append(hashlib.sha256(frame.tobytes()).hexdigest())
        if 32<=i<36:heights.append(box[3]-box[1])
        entries.append({'index':i,'name':name,'source_rect':[x0,y0,x1-x0,y1-y0],
                        'cell_rect':[col*cell,row*cell,cell,cell],'content_rect':[col*cell+dx+box[0],row*cell+dy+box[1],box[2]-box[0],box[3]-box[1]],
                        'pixel_sha256':frame_hashes[-1]})
    if len(set(frame_hashes))!=64:raise ValueError(f'{slug}: identical source frames detected; redraw required')
    atlas.save(target/'atlas.png',compress_level=9)
    entry={'kit_id':HEROES[slug],'status':'AUTHORED_ATLAS_CANDIDATE_CREATOR_GAME_TESTS_PENDING',
           'source':f'source/hero-atlases-v2/{slug}/authored-atlas.png','source_sha256':digest(source),
           'prompt':f'source/hero-atlases-v2/{slug}/prompt.txt','atlas_sha256':digest(target/'atlas.png'),
           'dimensions':list(atlas.size),'cell_size':[cell,cell],'foot_pivot':pivot,'source_ground_fraction':ground_fraction,
           'world_scale':64.0/(sum(heights)/len(heights)),'unique_frame_count':64,'frames':entries}
    print(f'{slug}: 64 nonempty distinct authored cells packed; RGBA source preserved')
    return entry

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--hero',choices=HEROES)
    args=parser.parse_args();PACK.mkdir(parents=True,exist_ok=True)
    path=PACK/'manifest.json'
    manifest=json.loads(path.read_text(encoding='utf-8')) if path.exists() else {
        'schema_version':2,'status':'CANDIDATE_FOR_CREATOR_TESTING','source_style':'CPK-HERO-SHEETS-INTEGRATION-2026-11-14-01',
        'scope':'Newly drawn complete animation atlases, replacing provisional pose playback',
        'generator':'built-in image_gen; prompts and original generated RGBA sheets retained',
        'format':{'columns':8,'rows':8,'frame_count':64,'directions':DIRECTIONS},
        'sequences':{'run':{'start':0,'directions':8,'frames_per_direction':4},'idle_front':[32,33,34,35],
                     'idle_back':[36,37,38,39],'attack_front':[40,41,42,43],'attack_back':[44,45,46,47],
                     'hurt_front':[48,49],'hurt_back':[50,51],'flex_in':[52,53],'flex_loop':[54,55],
                     'flex_out':[56,57],'defeat':[58,59,60,61,62,63]},
        'creator_game_tests':'NOT_RUN_BY_AGENT_AT_CREATOR_REQUEST','merge_authorized_by_this_delivery':False,
        'heroes':{}}
    for slug in ([args.hero] if args.hero else list(HEROES)):
        manifest['heroes'][slug]=build(slug)
    path.write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')

if __name__=='__main__':main()
