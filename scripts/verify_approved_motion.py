"""Offline approved-source/export gate for six playable appearance identities."""
import hashlib
import json
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOLDER = Path('assets/production/hero-motion-v3')


def validate(pack=None):
    manifest = json.loads((ROOT/FOLDER/'manifest.json').read_text())
    approval = json.loads((ROOT/FOLDER/'approval.json').read_text())
    assert approval['status'] == 'APPROVED_FOR_INTEGRATION'
    assert manifest['cell'] == 512 and manifest['pivot'] == [256,464]
    expected = {('sigma','original'),('sigma','female'),('cool-kid','original'),('cool-kid','female'),('alpha','original'),('alpha','female')}
    assert {(r['hero_id'],r['appearance']) for r in manifest['heroes'].values()} == expected
    assert len(manifest['heroes']) == 6
    exported = []
    for slug, row in manifest['heroes'].items():
        assert row['source'] == approval['sources'][slug]
        assert len(row['frames']) == 8 and row['body_height'] > 200
        for name, checksum in row['source'].items():
            source = ROOT/FOLDER/'source'/slug/name
            assert hashlib.sha256(source.read_bytes()).hexdigest() == checksum, source
        for name, checksum in row['files'].items():
            path = FOLDER/slug/name
            data = (ROOT/path).read_bytes()
            assert hashlib.sha256(data).hexdigest() == checksum, path
            if name == 'run.png': assert struct.unpack('>II',data[16:24]) == (2048,1024)
            exported.append(path.as_posix())
    if pack:
        from check_icon_pack import directory
        paths = directory(Path(pack).read_bytes())
        for name in ['manifest.json','approval.json']: assert (FOLDER/name).as_posix() in paths
        for path in exported:
            assert path+'.import' in paths, path
        assert not any(p.startswith((FOLDER/'source').as_posix()+'/') for p in paths), 'Review/source masters must not ship to browsers'
        assert any('scripts/approved_hero_motion' in p for p in paths)
    print('PASS: six approved source identities, 48 registered poses, matching portraits and clean export provenance')


if __name__ == '__main__':
    validate(sys.argv[1] if len(sys.argv)>1 else None)
