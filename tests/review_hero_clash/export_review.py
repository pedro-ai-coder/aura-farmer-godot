"""Prepare a separate review project without editing production export settings.
Usage: python3 tests/review_hero_clash/export_review.py /absolute/output/directory
Then: godot --headless --path OUTPUT --import
      godot --headless --path OUTPUT --export-release Web OUTPUT/build/index.html
This local review export is NOT a public release or production preset.
"""
import re
import shutil
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[2]
out = Path(sys.argv[1]).resolve()
if out == root or root in out.parents:
    raise SystemExit('Use an output directory outside the production checkout')
out.mkdir(parents=True, exist_ok=False)
for name in ('scripts', 'assets', 'tests', 'scenes', 'web'):
    source = root / name
    if source.exists():
        shutil.copytree(source, out / name, ignore=shutil.ignore_patterns('.git', '.godot', 'evidence'))
project = (root / 'project.godot').read_text()
project = re.sub(r'run/main_scene=.*', 'run/main_scene="res://tests/review_hero_clash/review.tscn"', project)
(out / 'project.godot').write_text(project)
presets = (root / 'export_presets.cfg').read_text().replace('assets/art-production/*,tests/*', 'assets/art-production/*')
presets = presets.replace('include_filter="', 'include_filter="tests/review_hero_clash/fonts/*/OFL.txt,tests/review_hero_clash/fonts/manifest.json,')
(out / 'export_presets.cfg').write_text(presets)
(out / 'build').mkdir()
print(out)
