"""Pin the existing source-isolated Vixen derivative and its exported resource."""
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOLDER = Path('assets/production/pixel-vixen/cpk-v2')
manifest = json.loads((ROOT/FOLDER/'manifest.json').read_text())
assert manifest['source_sha256'] == '5a16816eb51b6ca1d5e3f7f4036064243bd7152d561fdf866c5bd543ca29b490'
assert manifest['source_approval'] == 'CPK-ART-PIXEL-VIXEN-2026-11-10-01'
assert manifest['atlas_sha256'] == 'a96d48d6922f515cbc4fc456b5c658c7916e11765082d6d61e994e0d6dad5d02'
assert hashlib.sha256((ROOT/FOLDER/'atlas.png').read_bytes()).hexdigest() == manifest['atlas_sha256']
assert manifest['cell'] == [144,144] and manifest['pivot'] == [72,120]
assert len(manifest['frames']) == 49
if len(sys.argv)>1:
    from check_icon_pack import directory
    paths = directory(Path(sys.argv[1]).read_bytes())
    assert (FOLDER/'manifest.json').as_posix() in paths
    assert (FOLDER/'atlas.png.import').as_posix() in paths
    assert any(p.startswith('.godot/imported/atlas.png-') and p.endswith('.ctex') for p in paths)
print('PASS: exact source-isolated Vixen derivative, approved source, 49 cells and exported resources when supplied')
