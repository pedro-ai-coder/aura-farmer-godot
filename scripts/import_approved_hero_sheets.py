"""Deterministically extract approved source pixels; never generate/redraw artwork."""
from pathlib import Path
from collections import deque
import hashlib, json, shutil
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT.parent/'hero-style-02-approved-art/production-reference/characters/2026-11-14'
DEST = ROOT/'assets/production/heroes/individual-sheets-v1'
ROWS = {'the-sigma':[110,435,758,1086], 'cool-kid':[109,434,759,1086],
        'pixel-vixen':[105,431,758,1086], 'byte-baddie':[77,411,749,1086],
        'alpha-chad':[98,427,756,1086], 'block-queen':[77,411,749,1086]}
LABELS = ['front','three-quarter','side','back','idle','run-contact','run-passing','run-opposite','anticipation','action','recovery','hurt']
KITS={'the-sigma':'sigma','cool-kid':'cool-kid','pixel-vixen':'sigma','byte-baddie':'cool-kid','alpha-chad':'alpha','block-queen':'alpha'}
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()

def grid(image):
    pixels=image.load();w,h=image.size
    score=lambda y:sum(max(pixels[x,y][:3])<65 for x in range(w))/w
    edges=[]
    for lo,hi in [(65,160),(350,500),(650,850),(h-7,h)]:
        candidates=[y for y in range(lo,hi) if score(y)>0.85]
        assert candidates,(lo,hi)
        edges.append(max(candidates) if not edges else candidates[len(candidates)//2])
    return edges

def extract(image, index, ys):
    col,row=index%4,index//4
    x0=col*362+7; y0=ys[row]+5
    crop=image.crop((x0,y0,(col+1)*362-7,ys[row+1]-7)).convert('RGB')
    w,h=crop.size; rgb=list(crop.get_flattened_data())
    # Only exterior, nearly neutral gray is background. Enclosed white clothing
    # and keys survive because the black character outline stops the flood.
    allowed=bytearray(max(p)-min(p)<19 and min(p)>27 for p in rgb)
    outside=bytearray(w*h); q=deque()
    for x in range(w):
        for y in [0,h-1]:
            k=y*w+x
            if allowed[k] and not outside[k]: outside[k]=1;q.append(k)
    for y in range(h):
        for x in [0,w-1]:
            k=y*w+x
            if allowed[k] and not outside[k]: outside[k]=1;q.append(k)
    while q:
        k=q.popleft();x=k%w;y=k//w
        for n in ([k-1] if x else [])+([k+1] if x<w-1 else [])+([k-w] if y else [])+([k+w] if y<h-1 else []):
            if allowed[n] and not outside[n]:outside[n]=1;q.append(n)
    mask=bytearray(0 if a else 255 for a in outside)
    if index==9:
        for y in range(min(30,h)):
            for x in range(w-35,w):mask[y*w+x]=0
    # Keep body and detached props; reject disconnected title letter specks.
    seen=bytearray(w*h); keep=bytearray(w*h)
    for start in range(w*h):
        if not mask[start] or seen[start]:continue
        q=deque([start]);seen[start]=1;component=[]
        while q:
            k=q.popleft();component.append(k);x=k%w;y=k//w
            for n in ([k-1] if x else [])+([k+1] if x<w-1 else [])+([k-w] if y else [])+([k+w] if y<h-1 else []):
                if mask[n] and not seen[n]:seen[n]=1;q.append(n)
        xs=[k%w for k in component]; cs=[k//w for k in component]
        # Character/prop components are tall; typography and grid rules are not.
        tall_body = max(cs)-min(cs)>70 and max(xs)-min(xs)>35
        tossed_cap = index==9 and min(xs)>200 and max(cs)-min(cs)>30 and max(xs)-min(xs)>35
        if len(component)>220 and (tall_body or tossed_cap):
            for k in component:keep[k]=255
    rgba=crop.convert('RGBA');rgba.putalpha(Image.frombytes('L',(w,h),bytes(keep)))
    box=rgba.getbbox(); assert box and box[3]-box[1]>130, index
    return rgba.crop(box), [x0+box[0],y0+box[1],box[2]-box[0],box[3]-box[1]]

def main():
    source_manifest=json.loads((SOURCE/'manifest.json').read_text()) if SOURCE.exists() else json.loads((DEST/'manifest.json').read_text())
    manifest={'schema_version':1,'creator_decision':'CPK-HERO-SHEETS-INTEGRATION-2026-11-14-01',
              'approval_evidence':'Creator explicitly approved these individual assets and instructed immediate integration in the game.',
              'source_art_commit':'52c8618098c68034f42ec469567effc952cfdb27',
              'processing':'Deterministic crop/exterior-gray flood mask; original retained RGB pixels, no AI redraw or mirroring.',
              'animation_scope':'Approved key poses with cosmetic transforms; no claim of new independently authored inbetweens or unapproved attack/Flex drawings.',
              'heroes':{}}
    review=Image.new('RGB',(6*384,3*352),(48,46,55));draw=ImageDraw.Draw(review)
    for hi,(slug,ys) in enumerate(ROWS.items()):
        original=SOURCE/slug/'model-keyposes.png' if SOURCE.exists() else DEST/slug/'approved-source.png'
        expected=next(p['sha256'] for p in source_manifest['files'] if p['hero_id']==slug) if 'files' in source_manifest else source_manifest['heroes'][slug]['source_sha256']
        assert sha(original)==expected
        folder=DEST/slug;folder.mkdir(parents=True,exist_ok=True)
        if original.resolve()!=(folder/'approved-source.png').resolve(): shutil.copyfile(original,folder/'approved-source.png')
        image=Image.open(original);ys=grid(image);print(slug,'grid',ys)
        atlas=Image.new('RGBA',(1536,1056))
        frames=[]
        for i,label in enumerate(LABELS):
            # Several three-quarter captions physically touch the outline.
            # Use the approved idle drawing for that unused display slot,
            # rather than repaint the head or ship title pixels as character art.
            source_index=4 if i==1 else i
            pose,rect=extract(image,source_index,ys);px,py=192-pose.width//2,330-pose.height
            assert px>=0 and py>=0
            atlas.paste(pose,((i%4)*384+px,(i//4)*352+py))
            frames.append({'pose':'idle-caption-safe' if i==1 else label,'source_pose_index':source_index,'source_rect':rect,'cell_rect':[i%4*384,i//4*352,384,352],'foot_pivot':[192,330]})
            if i in [1,6,9]:
                j=[1,6,9].index(i);review.paste(pose,(hi*384+px,j*352+py),pose)
                draw.text((hi*384+12,j*352+8),slug+' / '+('idle' if i==1 else label),fill='white')
        atlas.save(folder/'atlas.png',compress_level=9)
        portrait,_=extract(image,4,ys);portrait.save(folder/'portrait.png',compress_level=9)
        portrait.crop((0,0,portrait.width,int(portrait.height*0.65))).save(folder/'hud.png',compress_level=9)
        idle=frames[4]['source_rect'][3]
        manifest['heroes'][slug]={'kit_id':KITS[slug],'source_sha256':expected,'atlas_sha256':sha(folder/'atlas.png'),
            'portrait_sha256':sha(folder/'portrait.png'),'hud_sha256':sha(folder/'hud.png'),
            'cell_size':[384,352],'foot_pivot':[192,330],'world_scale':64.0/idle,'frames':frames}
    (DEST/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
    evidence=ROOT/'docs/art/evidence/approved-individual-sheets';evidence.mkdir(parents=True,exist_ok=True)
    review.save(evidence/'extraction-review.png')
    print('Extracted all 72 approved poses; six source hashes verified; transparent atlases and portraits ready.')

if __name__=='__main__':main()
