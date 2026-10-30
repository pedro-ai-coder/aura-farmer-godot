"""Validate/promote exact creator-approved PNGs. This tool cannot grant approval."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import shutil

ROOT = Path(__file__).resolve().parents[1]
CANDIDATES = Path('assets/art-production/character-hype-clean-cut/v1')
RUNTIME = Path('assets/runtime-icons')

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def approved_rows(root):
    catalog = json.loads((root/'docs/art/v5_icon_readiness.json').read_text())
    ids = {(r['kind'], r['id']) for r in catalog}
    ledger = json.loads((root/'docs/art/icon_approvals.json').read_text())
    if ledger.get('schema_version') != 1:
        raise ValueError('Unsupported approval schema')
    source_manifest = json.loads((root/CANDIDATES/'manifests/ASSET_MANIFEST.json').read_text())
    declared = {f['path']: f['sha256'] for row in source_manifest['assets'] for f in row['files'] if f['format'] == 'PNG'}
    rows = []
    seen = set()
    for row in ledger['approvals']:
        key = (row['category'], row['id'])
        if key not in ids or key in seen:
            raise ValueError('Unknown category/ID or duplicate approval: '+str(key))
        seen.add(key)
        if row.get('approval_status') != 'CREATOR_APPROVED' or not str(row.get('approval_reference','')).strip():
            raise ValueError('Explicit creator approval and reference required: '+str(key))
        if row.get('remaining_conditions') != []:
            raise ValueError('Unresolved or unspecified approval conditions: '+str(key))
        if not re.fullmatch('[0-9a-f]{64}', row.get('source_sha256','')):
            raise ValueError('Exact source SHA-256 required')
        folder = 'weapons' if row['category'] == 'weapon' else 'passives'
        version = row['artwork_version']
        filename = {'v5-candidate':'icon-v5-candidate.png', 'clean-cut-v2':'icon-clean-cut-v2-256.png'}.get(version)
        if filename is None or (version == 'clean-cut-v2' and key != ('weapon','touch-grass')):
            raise ValueError('Unsupported source version for item')
        source = CANDIDATES/folder/row['id']/filename
        if row['source_path'] != source.as_posix() or declared.get(source.relative_to(CANDIDATES).as_posix()) != row['source_sha256'] or digest(root/source) != row['source_sha256']:
            raise ValueError('Approved source path/hash mismatch: '+str(key))
        # Runtime PNG is an unchanged copy; never pair v2 with the older SVG.
        path = RUNTIME/folder/row['id']/(row['source_sha256']+'.png')
        rows.append(dict(id=row['id'], category=row['category'], artwork_version=version,
                         source_path=source.as_posix(), resource_path='res://'+path.as_posix(),
                         source_sha256=row['source_sha256'], promoted_sha256=row['source_sha256'],
                         approval_status='CREATOR_APPROVED', approval_reference=row['approval_reference'],
                         usage=['offer-card','legendary-card','equipment','hud']))
    return sorted(rows,key=lambda r:(r['category'],r['id']))

def validate(root=ROOT):
    expected = approved_rows(root)
    manifest = json.loads((root/RUNTIME/'manifest.json').read_text())
    if manifest != dict(schema_version=1,icons=expected):
        raise ValueError('Runtime manifest differs from exact approved ledger')
    allowed = set()
    for row in expected:
        path = root/row['resource_path'].removeprefix('res://')
        allowed.add(path)
        if not path.is_file() or digest(path) != row['promoted_sha256']:
            raise ValueError('Promoted PNG missing or changed: '+str(path))
    # all_resources must never sweep up unregistered files, even after approval removal.
    discovered = {p for p in (root/RUNTIME).rglob('*') if p.is_file() and p != root/RUNTIME/'manifest.json'}
    allowed_sidecars = {Path(str(p)+'.import') for p in allowed}
    unexpected = discovered - allowed - allowed_sidecars
    if unexpected:
        raise ValueError('Unregistered runtime icon files: '+str(sorted(map(str,unexpected))))
    if not (root/'assets/art-production/.gdignore').is_file():
        raise ValueError('Candidate import isolation is missing')
    presets = (root/'export_presets.cfg').read_text()
    sections = re.findall(r'^\[preset\.\d+\]\n(.*?)(?=^\[|\Z)',presets,re.M|re.S)
    names = [re.findall(r'^name="([^"]*)"',section,re.M) for section in sections]
    filters = [re.findall(r'^exclude_filter="([^"]*)"',section,re.M) for section in sections]
    # Additional development presets must preserve the same art exclusions;
    # validate every preset instead of assuming exactly three will exist.
    if (any(len(n)!=1 for n in names) or not {'Web','Android','iOS'}.issubset({n[0] for n in names})
            or any(len(f)!=1 or 'assets/art-production/*' not in f[0].split(',') for f in filters)):
        raise ValueError('Candidate exclusions required on Web/Android/iOS')
    return expected

def promote(root=ROOT):
    rows = approved_rows(root)  # validate every approval before any writes
    for row in rows:
        destination = root/row['resource_path'].removeprefix('res://')
        if destination.exists() and digest(destination) != row['promoted_sha256']:
            raise ValueError('Refusing to overwrite changed immutable runtime art')
    for row in rows:
        destination = root/row['resource_path'].removeprefix('res://')
        destination.parent.mkdir(parents=True,exist_ok=True)
        if not destination.exists(): shutil.copyfile(root/row['source_path'],destination)
    (root/RUNTIME/'manifest.json').write_text(json.dumps(dict(schema_version=1,icons=rows),indent=2)+'\n')
    return validate(root)

if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--promote',action='store_true',help='Copy only versions already approved in the committed ledger')
    args=parser.parse_args()
    try:
        rows=promote() if args.promote else validate()
        print(f'PASS: {len(rows)} exact creator-approved runtime icons; candidate isolation preserved')
    except (KeyError,ValueError,OSError) as error:
        parser.exit(1,'ERROR: '+str(error)+'\n')
