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
assert manifest['status']=='APPROVED_EXACT_REVIEWED_GAME_USE' and not manifest['original_reference_recovered']
assert manifest['approval_decision']=='CPK-NEON-PRODUCTION-2026-11-15-01'
assert (ROOT/manifest['approval_record']).is_file()
assert manifest['approved_game_commit']=='b6e9813c101b1ef099b1a3a170c1c6b2270a8ab3'
assert hashlib.sha256((garage/manifest['path']).read_bytes()).hexdigest()==manifest['sha256']
print('PASS: Exact approved CPK export hashes, pinned Art sources, creator-approved exact Garage background and approval provenance')
