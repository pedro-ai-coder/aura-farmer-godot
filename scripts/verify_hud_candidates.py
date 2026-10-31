"""Verify exact candidate bytes and Web packaging without artistic promotion."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
m=json.loads((ROOT/'assets/ui-hud-candidates/v2/manifest.json').read_text())
assert m['status']=='CANDIDATE_PENDING_CREATOR_REVIEW'
assert len(m['resources'])==20
assert hashlib.sha256((ROOT/m['portrait_shader']['path']).read_bytes()).hexdigest()==m['portrait_shader']['sha256']
for row in m['resources']:
 p=ROOT/row['source_path']
 assert hashlib.sha256(p.read_bytes()).hexdigest()==row['sha256'],str(p)
 assert row['approval_status']=='CANDIDATE_PENDING_EXACT_BYTE_CREATOR_APPROVAL'
 source=p.read_text()
 assert '<image' not in source and '<text' not in source and 'href=' not in source
if len(sys.argv)>1:
 from check_icon_pack import directory
 paths=directory(Path(sys.argv[1]).read_bytes())
 assert 'assets/ui-hud-candidates/v2/manifest.json' in paths
 assert not any(p.startswith('assets/ui-hud-candidates/v2/source/') or p.startswith('tests/hud_v2/') for p in paths)
 for row in m['resources']:
  p=row['source_path'];assert p+'.import' in paths,p
  assert any(x.startswith('.godot/imported/'+Path(p).name+'-') and x.endswith('.ctex') for x in paths),p
print('PASS: 20 original editable HUD SVGs, exact hashes and pending approval'+('; Web resources present, generator/review fixtures excluded' if len(sys.argv)>1 else ''))
