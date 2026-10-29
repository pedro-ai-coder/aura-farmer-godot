"""Verify candidate provenance without granting creator approval."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
folder=ROOT/'assets/ui-button-candidates/v1'
m=json.loads((folder/'manifest.json').read_text())
assert m['status']=='CREATOR_REVIEW_PENDING'
assert len(m['assets'])==24
for row in m['assets']:
 for kind in ['source','runtime']:
  p=ROOT/row[kind]['path'];assert hashlib.sha256(p.read_bytes()).hexdigest()==row[kind]['sha256'],str(p)
 source=(ROOT/row['source']['path']).read_text()
 assert '<image' not in source and '<text' not in source and 'href=' not in source
if len(sys.argv)>1:
 from check_icon_pack import directory
 paths=directory(Path(sys.argv[1]).read_bytes())
 assert not any(p.startswith('assets/ui-button-candidates/v1/source/') for p in paths)
 assert 'assets/ui-button-candidates/v1/manifest.json' in paths
 for row in m['assets']:
  p=row['runtime']['path'];assert p+'.import' in paths,p
  assert any(x.startswith('.godot/imported/'+Path(p).name+'-') and x.endswith('.ctex') for x in paths),p
print('PASS: 24 original button states, exact SVG/PNG hashes, unapproved candidate status'+('; Web PNGs/manifest present, editable sources excluded' if len(sys.argv)>1 else ''))
