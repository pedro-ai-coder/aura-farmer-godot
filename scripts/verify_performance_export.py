"""Verify that opt-in diagnostics cannot leak into the ordinary Web export."""
import argparse
from pathlib import Path
from check_icon_pack import directory

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('pack', type=Path)
parser.add_argument('--review', action='store_true')
args = parser.parse_args()
paths = directory(args.pack.read_bytes())
for name in ('web/performance.js', 'scripts/performance_probe.gd'):
    present = any(p == name or p == name + '.remap' or p == name + 'c' for p in paths)
    if present != args.review:
        parser.exit(1, f'ERROR: {name}: present={present}, expected review={args.review}\n')
if any(p.startswith('tests/frame_pacing/') for p in paths):
    parser.exit(1, 'ERROR: Test fixtures shipped in Web export\n')
print('PASS: Development diagnostics ' + ('packaged only in review export' if args.review else 'excluded from ordinary Web export'))
