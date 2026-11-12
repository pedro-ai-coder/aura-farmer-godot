"""Rebuild selection framing only from immutable approved Art repository sources."""
import argparse,hashlib,json
from pathlib import Path
from PIL import Image,ImageOps
import numpy as np
from scipy import ndimage
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def framed(im):
    im=im.convert('RGBA');im=im.crop(im.getbbox())
    im=ImageOps.contain(im,(464,464),Image.Resampling.LANCZOS)
    out=Image.new('RGBA',(512,512));out.paste(im,((512-im.width)//2,(512-im.height)//2));return out

def main(source_root):
    for slug in ['alpha-chad','block-queen']:
        folder=ROOT/'assets/art-candidates'/slug/'cpk-v1-proposed'
        m=json.loads((folder/'manifest.json').read_text())
        source=source_root/m['source']['path'];assert sha(source)==m['source']['sha256']
        framed(Image.open(source)).save(folder/'portrait.png')
        m['files']['portrait.png']=sha(folder/'portrait.png')
        m['portrait_derivation']='Full nonempty source bounds, aspect fit within 464x464, centred on transparent 512x512; no artwork edits.'
        (folder/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    source=source_root/'source/characters/pixel-vixen/creator-approved/pixel-vixen-approved-source.png'
    expected='5a16816eb51b6ca1d5e3f7f4036064243bd7152d561fdf866c5bd543ca29b490'
    assert sha(source)==expected
    a=np.array(Image.open(source).convert('RGBA'))
    mask=(a[:,:,3]>32)&~((a[:,:,0]>180)&(a[:,:,1]<70)&(a[:,:,2]<90))
    labels,_=ndimage.label(mask)
    components=[(n,r) for n,r in enumerate(ndimage.find_objects(labels),1) if r is not None and np.count_nonzero(labels[r]==n)>2000]
    components.sort(key=lambda c:(int((c[1][0].start+c[1][0].stop)/2/179),c[1][1].start))
    label,region=components[0];c=a[region].copy();c[:,:,3]=np.where(labels[region]==label,c[:,:,3],0);c[c[:,:,3]==0]=0
    # Native source pixels with padding, never upscale the 96px runtime frame.
    master=Image.fromarray(c);portrait=Image.new('RGBA',(master.width+32,master.height+32));portrait.paste(master,(16,16))
    folder=ROOT/'assets/production/pixel-vixen/cpk-v1';out=folder/'selection-portrait.png';portrait.save(out)
    y,x=region
    (folder/'selection-portrait.json').write_text(json.dumps({'source_repository':'pedro-ai-coder/clutchpunks-art-pipeline','source_sha256':expected,'source_bounds_xywh':[x.start,y.start,x.stop-x.start,y.stop-y.start],'derivation':'First approved idle pose at native source resolution, isolated alpha component, 16px transparent padding','dimensions':portrait.size,'sha256':sha(out)},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('source_root',type=Path);main(p.parse_args().source_root)
