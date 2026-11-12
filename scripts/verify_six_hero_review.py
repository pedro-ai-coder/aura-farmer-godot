"""Focused source hashes and exported resources for the six-hero review."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SIGMA = Path('assets/production/the-sigma/cpk-v1')
VIXEN = Path('assets/production/pixel-vixen/cpk-v1')
SIGMA_SOURCE_SHA = 'cde14c7dbaadf1d4a04842f91623ebe01302b346ce89939a3063007b0c2a4561'

def validate():
    manifest = json.loads((ROOT/SIGMA/'manifest.json').read_text())
    assert manifest['source']['sha256'] == SIGMA_SOURCE_SHA
    assert manifest['source']['git_blob'] == '1030a2c597bbd1649a84226ed59cb1b77728d16b'
    assert manifest['source']['approval'] == 'CPK-ART-SIGMA-2026-11-10-01'
    assert len(manifest['frames']) == 49 and manifest['kit_id'] == 'sigma'
    sources = []
    for role in ['atlas','portrait']:
        path = SIGMA/manifest[role]['path']
        assert hashlib.sha256((ROOT/path).read_bytes()).hexdigest() == manifest[role]['sha256'], path
        sources.append(path.as_posix())
    vixen = json.loads((ROOT/VIXEN/'manifest.json').read_text())
    path = Path(vixen['atlas_path'])
    assert hashlib.sha256((ROOT/path).read_bytes()).hexdigest() == vixen['atlas_sha256']
    sources.append(path.as_posix())
    portrait = json.loads((ROOT/VIXEN/'selection-portrait.json').read_text())
    path = VIXEN/'selection-portrait.png'
    assert portrait['source_sha256'] == vixen['source_sha256']
    assert hashlib.sha256((ROOT/path).read_bytes()).hexdigest() == portrait['sha256']
    sources.append(path.as_posix())
    # Existing verifiers independently pin Cool Kid and all legacy female assets.
    from verify_cool_kid_cpk import validate as cool_kid
    cool_kid()
    from verify_female_variants import validate as female_variants
    female_variants()
    return sources

def validate_pack(pack, sources):
    from check_icon_pack import directory
    paths = directory(pack.read_bytes())
    for folder in [SIGMA,VIXEN]:
        assert (folder/'manifest.json').as_posix() in paths, 'Missing CPK provenance'
    for source in sources:
        assert source+'.import' in paths, 'Missing texture descriptor: '+source
        assert any(p.startswith('.godot/imported/'+Path(source).name+'-') and p.endswith('.ctex') for p in paths), source
    assert any('scripts/sigma_cpk_animation'+suffix in paths for suffix in ['.gdc','.gd','.gd.remap']), 'Missing Sigma animation adapter'

if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('pack',type=Path,nargs='?')
    args=parser.parse_args()
    sources=validate()
    if args.pack: validate_pack(args.pack,sources)
    print('PASS: Sigma approved lineage/49 poses, unchanged Pixel Vixen and Cool Kid CPK hashes, legacy female resources'
          + ('; exported CPK textures, animation and provenance' if args.pack else ''))
