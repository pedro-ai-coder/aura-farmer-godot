"""Candidate provenance/PNG gate, and imported-resource review PCK inclusion."""
import hashlib,json,sys
from pathlib import Path
from PIL import Image
R=Path(__file__).resolve().parents[1]
D=R/'assets/art-candidates/cool-kid/articulated-rig-v1'
m=json.loads((D/'manifest.json').read_text())
script=(R/'scripts/cool_kid_articulated.gd').read_text()
assert hashlib.sha256((D/'manifest.json').read_bytes()).hexdigest() in script
assert m['status']=='CANDIDATE_NOT_APPROVED' and m['hero_id']=='cool-kid'
names=set()
for e in m['parts']:
 assert e['parent']=='root' or e['parent'] in names
 assert e['name'] not in names;names.add(e['name'])
 p=D/e['file'];im=Image.open(p)
 assert im.mode=='RGBA' and im.size==(194,292) and im.getextrema()[3]==(0,255)
 assert hashlib.sha256(p.read_bytes()).hexdigest()==e['sha256']
 assert hashlib.sha256(im.tobytes()).hexdigest()==e['rgba_sha256']
 assert 'process/fix_alpha_border=false' in Path(str(p)+'.import').read_text()
if len(sys.argv)>1:
 from check_icon_pack import directory
 paths=directory(Path(sys.argv[1]).read_bytes());prefix=D.relative_to(R).as_posix()+'/'
 if '--production' in sys.argv:
  assert not any(p.startswith(prefix) for p in paths)
 else:
  assert prefix+'manifest.json' in paths
  for e in m['parts']:
   assert prefix+e['file']+'.import' in paths
   assert any(p.startswith('.godot/imported/'+e['file']+'-') and p.endswith('.ctex') for p in paths)
print('PASS: 16 source/RGBA hashes, transparency, parent order, pinned manifest, lossless import'+('; PCK inclusion/exclusion' if len(sys.argv)>1 else ''))
