"""Check the downloadable contract without depending on Godot's ZIP reader."""
import json, pathlib, zipfile
path=pathlib.Path(__file__).parent/'evidence/sample-session.zip'
with zipfile.ZipFile(path) as archive:
    assert set(archive.namelist())=={'session.json','session-trace.jsonl','session-summary.json','README.md'}
    metadata=json.loads(archive.read('session.json'))
    summary=json.loads(archive.read('session-summary.json'))
    rows=[json.loads(line) for line in archive.read('session-trace.jsonl').splitlines()]
    assert rows and all(a['wall_ms']<=b['wall_ms'] for a,b in zip(rows,rows[1:]))
    assert {'spawn','kill','damage_taken','xp','upgrade_committed','run_started','run_finished'} <= {row['event'] for row in rows}
    assert all(set(row)=={'event','wall_ms','active_s','run','wave','data'} for row in rows)
    assert summary['records']==len(rows) and not summary['recording']
    assert summary['trace_bytes']==len(archive.read('session-trace.jsonl'))
    # The recorder accepts whitelisted scalars, never an entire game/profile.
    raw=archive.read('session-trace.jsonl').decode()
    assert not any('"'+field+'":' in raw for field in ('profile','run_id','password','cookie','email','token'))
    print('PASS: four-file ZIP, monotonic timestamps, authoritative events, bounded trace accounting and no profile fields')
