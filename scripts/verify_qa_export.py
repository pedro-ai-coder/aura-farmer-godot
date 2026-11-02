"""Fail closed if QA instrumentation leaks into an ordinary export."""
import argparse
from pathlib import Path
from check_icon_pack import directory
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('pack',type=Path);p.add_argument('--review',action='store_true')
a=p.parse_args();paths=directory(a.pack.read_bytes())
qa=[x for x in paths if x.startswith('qa/')]
if bool(qa)!=a.review:p.exit(1,f'ERROR: QA files present={bool(qa)}, expected={a.review}\n')
if a.review:
    for item in ('main.tscn','review_run.gd','recorder.gd','toolbar.gd','README.md','build.json','scenarios.gd','settings_ui.gd','diagnostics.gd','geometry.gd'):
        if not any(x=='qa/'+item or x.startswith('qa/'+item+'.') or x=='qa/'+item+'c' for x in qa):
            p.exit(1,'ERROR: Missing QA resource '+item+'\n')
if any(x.startswith('tests/qa_recorder/') for x in paths):p.exit(1,'ERROR: Test fixtures included\n')
print('PASS: QA export isolation, review='+str(a.review))
