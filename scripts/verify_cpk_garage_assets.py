"""Verify pinned approved brand derivatives and separately proposed Garage bytes."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
brand=ROOT/'assets/production/cpk-brand-2026-11-13-v1'
manifest=json.loads((brand/'manifest.json').read_text())
assert manifest['decision']=='CPK-BRAND-2026-11-13-01'
for row in manifest['assets']:
    assert hashlib.sha256((brand/row['path']).read_bytes()).hexdigest()==row['sha256'],row['path']
garage=ROOT/'assets/production/garage-candidate-v1'
manifest=json.loads((garage/'manifest.json').read_text())
assert manifest['status']=='PROPOSED' and not manifest['original_reference_recovered']
assert hashlib.sha256((garage/manifest['path']).read_bytes()).hexdigest()==manifest['sha256']
print('PASS: Exact approved CPK export hashes, pinned Art sources, separately PROPOSED Garage background')
factory=ROOT/'assets/experimental/cpk-level-zero-study'
if factory.exists():
    manifest=json.loads((factory/'manifest.json').read_text(encoding='utf-8'))
    assert manifest['status']=='EXPERIMENTAL_CANDIDATE'
    for row in manifest['assets']:
        assert hashlib.sha256((factory/row['path']).read_bytes()).hexdigest()==row['sha256']
    print('PASS: Exact preserved experimental factory backdrop/underlay hashes')
if len(sys.argv)>1:
    from check_icon_pack import directory
    paths=directory(Path(sys.argv[1]).read_bytes())
    for resource in [
        'assets/production/cpk-brand-2026-11-13-v1/cpk-wordmark-color-1024.png',
        'assets/production/cpk-brand-2026-11-13-v1/cpk-emblem-color-96.png',
        'assets/production/garage-candidate-v1/garage-backdrop.png',
        'assets/experimental/cpk-level-zero-study/factory-backdrop.png',
        'assets/experimental/cpk-level-zero-study/factory-underlay.png',
    ]:assert resource+'.import' in paths,resource
    for resource in ['assets/production/cpk-brand-2026-11-13-v1/manifest.json','assets/production/garage-candidate-v1/manifest.json','assets/experimental/cpk-level-zero-study/manifest.json']:
        assert resource in paths,resource
    print('PASS: Export includes pinned brand/Garage/factory resource imports and provenance manifests')
