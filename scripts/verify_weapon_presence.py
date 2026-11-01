"""Verify candidate VFX and exact reused weapon art, including Web packaging."""
import hashlib,json,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
FOLDER='assets/art-candidates/weapon-presence/v1/'
MANIFEST=FOLDER+'manifest.json'
NAMES={'ratio-bolt':(128,48),'impact-sheet':(192,64)}

def validate(root=ROOT):
    m=json.loads((root/MANIFEST).read_text())
    if m.get('status')!='CANDIDATE_PENDING_CREATOR_REVIEW' or m.get('runtime_authorization')!='REVIEW_BRANCH_ONLY':
        raise ValueError('Weapon presence must retain candidate status')
    if len(m['resources'])!=2:raise ValueError('Exactly two essential new VFX textures')
    textures=[]
    for r in m['resources']:
        slug=Path(r['path']).stem
        if slug not in NAMES or r['path']!=FOLDER+slug+'.png' or r['source_path']!=FOLDER+'source/'+slug+'.svg' or r['status']!='CANDIDATE_PENDING_EXACT_BYTE_CREATOR_APPROVAL':
            raise ValueError('Incorrect candidate resource mapping')
        for key,h in [('path','sha256'),('source_path','source_sha256')]:
            p=root/r[key]
            if not p.is_file():raise ValueError('Missing weapon presentation asset: '+r[key])
            if hashlib.sha256(p.read_bytes()).hexdigest()!=r[h]:raise ValueError('Weapon SHA-256 mismatch: '+r[key])
        data=(root/r['path']).read_bytes()
        if data[:8]!=b'\x89PNG\r\n\x1a\n' or struct.unpack('>II',data[16:24])!=NAMES[slug] or data[24:26]!=b'\x08\x06' or r['dimensions']!=list(NAMES[slug]):
            raise ValueError('Wrong transparent RGBA texture dimensions')
        if any(t in (root/r['source_path']).read_text() for t in ['<text','<image','href=','<filter']):raise ValueError('VFX source must be self-contained editable vector')
        textures.append(r['path'])
    if {Path(p).stem for p in textures}!=set(NAMES):raise ValueError('Distinct VFX resources required')
    icons={r['id']:r for r in json.loads((root/'assets/runtime-icons/manifest.json').read_text())['icons'] if r['category']=='weapon'}
    refs=m['reused_approved_icons']
    if len(refs)!=9 or {r['id'] for r in refs}!=set(icons):raise ValueError('Exactly nine canonical approved weapon references')
    for row in refs:
        approved=icons[row['id']]
        if row['path']!=approved['resource_path'].removeprefix('res://') or row['sha256']!=approved['promoted_sha256']:
            raise ValueError('Wrong approved weapon art/version')
        if hashlib.sha256((root/row['path']).read_bytes()).hexdigest()!=row['sha256']:raise ValueError('Approved weapon art changed')
    if hashlib.sha256((root/m['attachment_source']).read_bytes()).hexdigest()!=m['attachment_sha256']:raise ValueError('Attachment provenance mismatch')
    return textures

def validate_pack(paths,textures):
    if MANIFEST not in paths:raise ValueError('Missing weapon presentation manifest')
    for path in textures:
        if path+'.import' not in paths or not any(p.startswith('.godot/imported/'+Path(path).name+'-') and p.endswith('.ctex') for p in paths):
            raise ValueError('Missing exported weapon presentation texture: '+path)
    if any(p.startswith(FOLDER+'source/') or p.startswith('tests/weapon_presence/') for p in paths):raise ValueError('Review/source resources leaked into Web export')

if __name__=='__main__':
    try:
        textures=validate()
        if len(sys.argv)>1:
            from check_icon_pack import directory
            validate_pack(directory(Path(sys.argv[1]).read_bytes()),textures)
        print('PASS: two exact RGBA VFX candidates, editable sources, nine unchanged approved weapon PNGs, six-appearance attachment provenance'+('; Web textures/manifest present, review sources excluded' if len(sys.argv)>1 else ''))
    except (OSError,ValueError,KeyError) as e:raise SystemExit('ERROR: '+str(e))
