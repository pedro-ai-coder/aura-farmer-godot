"""Alternate identical fixtures, changing only the collision implementation.

GODOT_COMMAND may be a JSON argv array (for an X11 wrapper). Assets/imports are
read through symlinks; source files are copied to a disposable baseline tree.
Run outside any other benchmark; headless results contain no rendering FPS.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('output', type=Path)
parser.add_argument('--native', action='store_true')
parser.add_argument('--passes', type=int, default=2)
parser.add_argument('--frames', type=int, default=360)
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
output = args.output.resolve()
output.mkdir(parents=True, exist_ok=True)
engine = json.loads(os.environ.get('GODOT_COMMAND', '["godot"]'))
reference = root / 'tests/frame_pacing/baseline_world.gd'
with tempfile.TemporaryDirectory(prefix='aura-pacing-') as folder:
    baseline = Path(folder)
    shutil.copytree(root / 'scripts', baseline / 'scripts')
    shutil.copytree(root / 'scenes', baseline / 'scenes')
    shutil.copy2(root / 'project.godot', baseline / 'project.godot')
    for name in ['assets', '.godot', 'tests', 'web']:
        (baseline / name).symlink_to(root / name, target_is_directory=True)
    (baseline / 'scripts/solo_world_rules.gd').write_text('class_name SoloWorldRules\n' + reference.read_text())
    manifest = {'baseline_revision': 'f6034fcb61c56f9ba3af083238cc673583028c34',
                'scope': 'Same current instrumentation/fixtures; only world collision source changes',
                'baseline_source_sha256': hashlib.sha256(reference.read_bytes()).hexdigest(),
                'after_source_sha256': hashlib.sha256((root / 'scripts/solo_world_rules.gd').read_bytes()).hexdigest(),
                'native': args.native, 'frames': args.frames, 'passes': args.passes,
                'not_browser_or_device_validation': True, 'runs': []}
    for trial in range(args.passes):
        order = [('before', baseline), ('after', root)]
        if trial % 2:order.reverse()
        for version, project in order:
            run = f'{trial+1}-{version}'
            command = engine + ([] if args.native else ['--headless']) + [
                '--path', str(project), '--audio-driver', 'Dummy', '--rendering-driver', 'opengl3',
                '--script', 'res://tests/frame_pacing/measure.gd', '--', str(output / run),
                '844', '390', str(args.frames), '1.5', 'all', '--trace']
            print('Measuring', run, flush=True)
            result = subprocess.run(command, capture_output=True, text=True)
            (output / f'{run}.log').write_text(result.stdout + result.stderr)
            if result.returncode or any(token in result.stdout + result.stderr for token in ['SCRIPT ERROR:', 'ERROR:', 'Parse Error:']):
                raise RuntimeError(f'{run} failed; inspect its log')
            manifest['runs'].append(run)
    (output / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print('Completed paired', 'native render' if args.native else 'headless CPU', 'measurements')
