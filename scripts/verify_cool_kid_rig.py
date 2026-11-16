"""Candidate provenance/PNG gate, and imported-resource review PCK inclusion."""
import hashlib,json,sys,struct,zlib
from pathlib import Path
def decoded_rgba(path):
    data=path.read_bytes()
    assert data[:8]==b'\x89PNG\r\n\x1a\n'
    w,h,depth,color,comp,filt,interlace=struct.unpack_from('>IIBBBBB',data,16)
    assert (w,h,depth,color,comp,filt,interlace)==(192,192,8,6,0,0,0)
    compressed=[];offset=8
    while offset<len(data):
        size=struct.unpack_from('>I',data,offset)[0]
        if data[offset+4:offset+8]==b'IDAT':compressed.append(data[offset+8:offset+8+size])
        offset+=size+12
    stream=zlib.decompress(b''.join(compressed));stride=w*4
    previous=bytearray(stride);result=bytearray();offset=0
    for _ in range(h):
        kind=stream[offset];offset+=1;row=bytearray(stream[offset:offset+stride]);offset+=stride
        assert kind<=4
        for x in range(stride):
            a=row[x-4] if x>=4 else 0;b=previous[x];c=previous[x-4] if x>=4 else 0
            if kind==1:predict=a
            elif kind==2:predict=b
            elif kind==3:predict=(a+b)//2
            elif kind==4:
                p=a+b-c;pa,pb,pc=abs(p-a),abs(p-b),abs(p-c)
                predict=a if pa<=pb and pa<=pc else b if pb<=pc else c
            else:predict=0
            row[x]=(row[x]+predict)&255
        result.extend(row);previous=row
    assert min(result[3::4])==0
    return bytes(result)
R=Path(__file__).resolve().parents[1]
D=R/'assets/art-candidates/cool-kid/articulated-rig-v2'
m=json.loads((D/'manifest.json').read_text())
script=(R/'scripts/cool_kid_articulated.gd').read_text()
assert hashlib.sha256((D/'manifest.json').read_bytes()).hexdigest() in script
assert m['status']=='CANDIDATE_NOT_APPROVED' and m['hero_id']=='cool-kid'
names=set()
entries=[e for view in m['views'] for e in view['parts']]
assert len(m['views'])==8 and len(entries)==128
for view in m['views']:
 names=set()
 for e in view['parts']:
  assert e['parent']=='root' or e['parent'] in names
  assert e['name'] not in names;names.add(e['name'])
for e in entries:
 p=D/e['file'];pixels=decoded_rgba(p)
 assert hashlib.sha256(p.read_bytes()).hexdigest()==e['sha256']
 assert hashlib.sha256(pixels).hexdigest()==e['rgba_sha256']
 assert 'process/fix_alpha_border=false' in Path(str(p)+'.import').read_text()
if len(sys.argv)>1:
 from check_icon_pack import directory
 paths=directory(Path(sys.argv[1]).read_bytes())
 assert not any(p.startswith(('docs/art/evidence/cool-kid-rig-v2/','build/')) for p in paths)
 prefix=D.relative_to(R).as_posix()+'/'
 if '--production' in sys.argv:
  assert not any(p.startswith("assets/art-candidates/cool-kid/") for p in paths)
 else:
  assert prefix+'manifest.json' in paths
  for e in entries:
   assert prefix+e['file']+'.import' in paths
   assert any(p.startswith('.godot/imported/'+Path(e['file']).name+'-') and p.endswith('.ctex') for p in paths)
print('PASS: 8 directional views / 128 source/RGBA hashes, transparency, parent order, pinned manifest, lossless import'+('; PCK inclusion/exclusion' if len(sys.argv)>1 else ''))
