"""Guard the small read-only feedback adapter and its ordinary Web packaging."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SCRIPTS=['scripts/passive_feedback.gd','scripts/passive_feedback_view.gd']

def validate(root=ROOT):
    # Only existing hash-pinned icons are reused. No new art approval is implied.
    rows=json.loads((root/'assets/runtime-icons/manifest.json').read_text())['icons']
    passives=[r for r in rows if r['category']=='passive']
    if len(passives)!=28:raise ValueError('Preserve all 28 approved passive icons, including five future-only references')
    for row in passives:
        data=(root/row['resource_path'].removeprefix('res://')).read_bytes()
        if hashlib.sha256(data).hexdigest()!=row['promoted_sha256']:raise ValueError('Approved passive icon changed: '+row['id'])
    for path in SCRIPTS:
        source=(root/path).read_text()
        for forbidden in ['RandomNumberGenerator','randf(', 'randi(', 'create_tween(', 'Image.create(', 'Image.load(', 'profile["settings"]["reducedMotion"] =']:
            if forbidden in source:raise ValueError('Unexpected allocation/simulation/setting mutation in '+path)
    evidence=root/'tests/passive_feedback/evidence'
    provenance=json.loads((evidence/'provenance.json').read_text())
    if provenance.get('new_art_resources')!=0:raise ValueError('No new art resources expected in this feedback pass')
    # Capture source hashes are historical provenance, not a permanent lock
    # on future gameplay edits. Image bytes remain independently verified.
    for row in provenance['frames']+list(provenance['sheets'].values()):
        data=(root/row['path']).read_bytes()
        if len(data)<1000 or data[:4]!=b'RIFF' or data[8:12]!=b'WEBP':raise ValueError('Missing/corrupt real runtime evidence: '+row['path'])
        if hashlib.sha256(data).hexdigest()!=row.get('webp_sha256',row.get('sha256')):raise ValueError('Review image hash mismatch: '+row['path'])
    video=provenance['video'];data=(root/video['path']).read_bytes()
    if len(data)<10000 or hashlib.sha256(data).hexdigest()!=video['sha256']:raise ValueError('Review video hash mismatch')
    return SCRIPTS

def validate_pack(paths):
    for path in SCRIPTS:
        if not any(p in [path,path+'c',path+'.remap'] for p in paths):raise ValueError('Feedback runtime script absent: '+path)
    if any(p.startswith('tests/passive_feedback/') for p in paths):raise ValueError('Feedback review fixtures/evidence shipped in Web export')

if __name__=='__main__':
    try:
        validate()
        if len(sys.argv)>1:
            from check_icon_pack import directory
            validate_pack(directory(Path(sys.argv[1]).read_bytes()))
        print('PASS: approved passive art unchanged, bounded read-only feedback resources'+('; runtime scripts present and fixtures excluded from Web export' if len(sys.argv)>1 else ''))
    except (OSError,ValueError,KeyError) as e:raise SystemExit('ERROR: '+str(e))
