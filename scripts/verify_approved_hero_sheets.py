"""Offline checksum/alpha/geometry gate for the creator-approved six-hero pack."""
import json, hashlib, sys
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
PACK=ROOT/'assets/production/heroes/individual-sheets-v1'
def verify(pack=None):
    data=json.loads((PACK/'manifest.json').read_text(encoding='utf-8'))
    expected={'the-sigma':'sigma','cool-kid':'cool-kid','pixel-vixen':'sigma','byte-baddie':'cool-kid','alpha-chad':'alpha','block-queen':'alpha'}
    assert {s:d['kit_id'] for s,d in data['heroes'].items()}==expected
    for slug,hero in data['heroes'].items():
        folder=PACK/slug
        for file,field in [('approved-source.png','source_sha256'),('atlas.png','atlas_sha256'),('portrait.png','portrait_sha256'),('hud.png','hud_sha256')]:
            assert hashlib.sha256((folder/file).read_bytes()).hexdigest()==hero[field],(slug,file)
        atlas=Image.open(folder/'atlas.png')
        assert atlas.mode=='RGBA' and atlas.size==(1536,1056)
        assert len(hero['frames'])==12 and hero['foot_pivot']==[192,330]
        for frame in hero['frames']:
            x,y,w,h=frame['cell_rect'];cell=atlas.crop((x,y,x+w,y+h));box=cell.getbbox()
            assert box and box[0]>0 and box[1]>0 and box[2]<384 and box[3]<352,(slug,frame['pose'])
            assert cell.getpixel((0,0))[3]==0
    if pack:
        from check_icon_pack import directory
        paths=directory(Path(pack).read_bytes())
        prefix='assets/production/heroes/individual-sheets-v1/'
        assert prefix+'manifest.json' in paths
        assert not any(p.startswith('assets/production/pixel-vixen/cpk-v1/') for p in paths)
        assert not any('approved-source.png' in p and p.startswith(prefix) for p in paths)
        for slug in expected:
            for name in ['atlas','portrait','hud']:
                assert prefix+slug+'/'+name+'.png.import' in paths,(slug,name)
    print('PASS: 24 exact asset hashes, 72 transparent cells, six identities and unchanged kit IDs'+('; exported resources complete, original masters/rejected derivative excluded' if pack else ''))
if __name__=='__main__':verify(sys.argv[1] if len(sys.argv)>1 else None)
