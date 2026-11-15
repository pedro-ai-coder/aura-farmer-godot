"""Verify pinned approved brand derivatives and separately proposed Garage bytes."""
import hashlib,json
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
