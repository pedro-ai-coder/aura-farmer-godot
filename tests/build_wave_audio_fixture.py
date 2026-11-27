"""Build a small synthetic Godot Web export for the browser audio regression."""

import argparse
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("godot", help="Godot 4.7.2 console executable with Web templates installed")
    parser.add_argument("output", type=Path, help="Directory to serve over HTTP")
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    commit = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()

    with tempfile.TemporaryDirectory(prefix="cpk-wave-audio-") as temporary:
        project = Path(temporary)
        (project / "scripts").mkdir()
        for file in ("combat_audio.gd", "m0_wave_music.gd"):
            shutil.copyfile(ROOT / "scripts" / file, project / "scripts" / file)
        shutil.copytree(ROOT / "assets/audio/big-hater-v1", project / "assets/audio/big-hater-v1")
        shutil.copyfile(ROOT / "tests/web_wave_audio_fixture.gd", project / "fixture.gd")
        (project / "fixture.tscn").write_text(
            '[gd_scene load_steps=2 format=3]\n'
            '[ext_resource type="Script" path="res://fixture.gd" id="1"]\n'
            '[node name="SyntheticWaveAudio" type="Node"]\nscript = ExtResource("1")\n',
            encoding="utf-8",
        )
        (project / "project.godot").write_text(
            'config_version=5\n[application]\nconfig/name="Synthetic wave audio fixture"\n'
            'run/main_scene="res://fixture.tscn"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n',
            encoding="utf-8",
        )
        (project / "export_presets.cfg").write_text(
            '[preset.0]\nname="Web"\nplatform="Web"\nexport_filter="all_resources"\ninclude_filter=""\nexclude_filter=""\n'
            '[preset.0.options]\nvariant/thread_support=false\n',
            encoding="utf-8",
        )
        godot = [args.godot, "--headless", "--path", str(project)]
        for command in (["--import"], ["--export-release", "Web", str(output / "index.html")]):
            result = subprocess.run(godot + command, check=True, capture_output=True, text=True)
            if "ERROR:" in result.stderr or "ERROR:" in result.stdout:
                raise RuntimeError(result.stdout + result.stderr)
        (output / "build.json").write_text(
            json.dumps({"commit": commit, "fixture": True}), encoding="utf-8"
        )


if __name__ == "__main__":
    main()
