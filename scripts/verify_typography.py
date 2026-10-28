"""Verify packaged OFL font bytes and, optionally, their real Web PCK entries."""
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
manifest = json.loads((ROOT / 'assets/fonts/clean-cut/manifest.json').read_text())
for row in manifest['fonts']:
    source = ROOT / row['path']
    assert hashlib.sha256(source.read_bytes()).hexdigest() == row['sha256'], row['path']
    assert source.stat().st_size == row['bytes'], row['path']
for path in ['assets/fonts/clean-cut/OFL.txt', 'assets/fonts/OFL.txt']:
    assert 'SIL OPEN FONT LICENSE' in (ROOT / path).read_text(), path
# Approved Barlow typography remains intact, while the Hero Clash review
# candidate carries separately licensed, hash-pinned Archivo source files.
candidate = json.loads((ROOT / 'assets/fonts/hero-clash/manifest.json').read_text())
assert candidate['status'] == 'CREATOR_REVIEW_CANDIDATE'
for row in candidate['fonts']:
    source = ROOT / row['path']
    assert hashlib.sha256(source.read_bytes()).hexdigest() == row['sha256'], row['path']
    assert source.stat().st_size == row['bytes'], row['path']
    assert 'SIL OPEN FONT LICENSE' in (ROOT / row['license']).read_text(), row['license']

if len(sys.argv) > 1:
    from check_icon_pack import directory
    paths = directory(Path(sys.argv[1]).read_bytes())
    for row in manifest['fonts']:
        name = Path(row['path']).name
        assert row['path'] + '.import' in paths, row['path']
        assert any(p.startswith('.godot/imported/' + name + '-') and p.endswith('.fontdata') for p in paths), name
    for row in candidate['fonts']:
        name = Path(row['path']).name
        assert row['path'] + '.import' in paths, row['path']
        assert any(p.startswith('.godot/imported/' + name + '-') and p.endswith('.fontdata') for p in paths), name
    for path in ['assets/fonts/clean-cut/OFL.txt', 'assets/fonts/OFL.txt', 'assets/fonts/clean-cut/manifest.json',
                 'assets/fonts/hero-clash/manifest.json']:
        assert path in paths, path
    for row in candidate['fonts']:
        assert row['license'] in paths, row['license']
print('PASS: four approved Barlow fonts and two separately licensed Hero Clash candidate fonts' + (' in Web export' if len(sys.argv) > 1 else ''))
