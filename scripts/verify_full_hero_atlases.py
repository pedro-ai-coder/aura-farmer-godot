"""Structural asset gate, not a gameplay or creator-acceptance test."""
from pathlib import Path
import json, hashlib, struct, sys
ROOT=Path(__file__).resolve().parents[1]
PACK=ROOT/'assets/production/heroes/full-atlases-v2'
HEROES={'the-sigma':'sigma','cool-kid':'cool-kid','pixel-vixen':'sigma','byte-baddie':'cool-kid','alpha-chad':'alpha','block-queen':'alpha'}

def verify(pack_path=None):
    data=json.loads((PACK/'manifest.json').read_text(encoding='utf-8'))
    assert {s:d['kit_id'] for s,d in data['heroes'].items()}==HEROES
    assert data['format']['frame_count']==64
    for slug,entry in data['heroes'].items():
        source=ROOT/entry['source'];atlas=PACK/slug/'atlas.png'
        assert hashlib.sha256(source.read_bytes()).hexdigest()==entry['source_sha256']
        assert hashlib.sha256(atlas.read_bytes()).hexdigest()==entry['atlas_sha256']
        raw=atlas.read_bytes();assert raw[:8]==b'\x89PNG\r\n\x1a\n'
        w,h,depth,kind=struct.unpack_from('>IIBB',raw,16)
        assert [w,h]==entry['dimensions'] and depth==8 and kind==6
        assert len(entry['frames'])==entry['unique_frame_count']==64
        assert len({f['pixel_sha256'] for f in entry['frames']})==64
        assert float(entry['world_scale'])>0
        for index,frame in enumerate(entry['frames']):
            x,y,cw,ch=frame['cell_rect']
            assert frame['index']==index and 0<=x and 0<=y and x+cw<=w and y+ch<=h
            assert 0<=entry['foot_pivot'][0]<cw and 0<=entry['foot_pivot'][1]<ch
    if pack_path:
        from check_icon_pack import directory
        paths=directory(Path(pack_path).read_bytes());prefix=PACK.relative_to(ROOT).as_posix()+'/'
        assert prefix+'manifest.json' in paths
        for slug in HEROES:assert prefix+slug+'/atlas.png.import' in paths
        assert not any(p.startswith('source/hero-atlases-v2/') for p in paths)
    print('Full atlas files: six RGBA sheets, 384 individually drawn cells, hashes/rectangles registered. Gameplay tests remain creator-owned.')

if __name__=='__main__':verify(sys.argv[1] if len(sys.argv)>1 else None)
