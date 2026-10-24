"""Inspect the real Godot 4.7.2 PCK directory, not raw substring occurrences."""
import argparse
import hashlib
import json
import re
from pathlib import Path
import struct
from promote_approved_icons import validate

def directory(data):
    if data[:4] != b'GDPC' or struct.unpack_from('<I',data,4)[0] != 4:
        raise ValueError('Expected pinned Godot 4.7.2 PCK format 4')
    offset=struct.unpack_from('<Q',data,32)[0]
    count=struct.unpack_from('<I',data,offset)[0];offset+=4
    paths=[]
    for _ in range(count):
        length=struct.unpack_from('<I',data,offset)[0];offset+=4
        paths.append(data[offset:offset+length].rstrip(b'\0').decode('utf-8'));offset+=length+36
    if offset != len(data): raise ValueError('Malformed PCK directory')
    return paths

def inspect(data,approved,originals=(),require_enemy_frames=False,require_runtime_manifest=False):
    paths=directory(data)
    if require_runtime_manifest and "assets/runtime-icons/manifest.json" not in paths:
        raise ValueError("Runtime icon manifest absent from export")
    forbidden=[p for p in paths if 'art-production/' in p or 'icon-v5-candidate' in p or 'icon-clean-cut-v2' in p or 'clean-cut-review/' in p or 'clean_cut_review/' in p or 'review_clean_cut_candidates' in p or 'test_clean_cut_review' in p]
    if forbidden: raise ValueError('Unapproved/review resources shipped: '+str(forbidden[:5]))
    allowed_paths={'assets/runtime-icons/manifest.json'} | {r['resource_path'].removeprefix('res://')+'.import' for r in approved}
    allowed_hashes={r['promoted_sha256'] for r in approved}
    for path in paths:
        if path.startswith('assets/runtime-icons/') and path not in allowed_paths:
            raise ValueError('Unregistered runtime icon export: '+path)
        match=re.match(r'^\.godot/imported/([0-9a-f]{64})\.png-',path)
        if match and match.group(1) not in allowed_hashes:
            raise ValueError('Unregistered imported runtime texture: '+path)
    for row in approved:
        source=row['resource_path'].removeprefix('res://')
        if source+'.import' not in paths or not any(p.startswith('.godot/imported/'+row['promoted_sha256']+'.png-') and p.endswith('.ctex') for p in paths):
            raise ValueError('Approved icon texture absent from export: '+source)
    for source in originals:
        name=Path(source).name
        if source+'.import' not in paths or not any(p.startswith('.godot/imported/'+name+'-') and p.endswith('.ctex') for p in paths):
            raise ValueError('Original approved master absent: '+source)
    if require_enemy_frames and 'assets/approved-enemy-frames.json' not in paths:
        raise ValueError('Approved enemy animation metadata absent')
    return dict(bytes=len(data),sha256=hashlib.sha256(data).hexdigest(),directory_entries=len(paths),approved_icon_count=len(approved),candidate_entries=0,original_masters=len(originals),enemy_metadata=require_enemy_frames)

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('pack',type=Path);args=parser.parse_args()
    try:
        root=Path(__file__).resolve().parents[1]
        originals=[r['destination'] for r in json.loads((root/'assets/approved-assets.json').read_text())['assets']]
        print('PASS: '+json.dumps(inspect(args.pack.read_bytes(),validate(),originals,True,True)))
    except (ValueError,OSError,struct.error,UnicodeError) as error: parser.exit(1,'ERROR: '+str(error)+'\n')
