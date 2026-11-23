"""Stage a Windows QA export in a fresh directory outside the game checkout."""

import argparse
from pathlib import Path
import re
import shutil

SOURCE = Path(__file__).resolve().parents[2]
ENTRY = "res://tests/passive_vfx_lab/main.tscn"
LAB_FILES = (
    "main.tscn", "lab.gd", "lab_run.gd", "burst_vfx.gd", "candidate_feedback.gd",
    "scenario_builds.gd", "qa_recorder.gd",
)


def stage(output: Path) -> None:
    if output == SOURCE or SOURCE in output.parents:
        raise ValueError("Choose a fresh staging directory outside the game checkout")
    output.mkdir(parents=True, exist_ok=False)
    for folder in ("scripts", "assets", "scenes", "web"):
        shutil.copytree(SOURCE / folder, output / folder)
    target = output / "tests/passive_vfx_lab"
    target.mkdir(parents=True)
    for filename in LAB_FILES:
        shutil.copyfile(Path(__file__).with_name(filename), target / filename)

    config = (SOURCE / "project.godot").read_text(encoding="utf-8")
    config = re.sub(r"(?m)^run/main_scene=.*$", f'run/main_scene="{ENTRY}"', config)
    config = re.sub(r"(?m)^config/name=.*$", 'config/name="CLUTCHPUNKS Passive VFX Lab"', config)
    (output / "project.godot").write_text(config, encoding="utf-8")

    presets = (SOURCE / "export_presets.cfg").read_text(encoding="utf-8")
    web = presets.split("[preset.0.options]", 1)[0]
    include = next(line for line in web.splitlines() if line.startswith("include_filter="))
    exclude = next(line for line in web.splitlines() if line.startswith("exclude_filter="))
    exclude = exclude.replace(",tests/*", "")
    (output / "export_presets.cfg").write_text(
        f'''[preset.0]
name="Passive VFX Lab Windows"
platform="Windows Desktop"
runnable=true
advanced_options=false
dedicated_server=false
export_filter="all_resources"
{include}
{exclude}
export_path="build/CLUTCHPUNKS Passive VFX Lab.exe"
script_export_mode=2

[preset.0.options]
binary_format/embed_pck=false
binary_format/architecture="x86_64"
application/modify_resources=false
codesign/enable=false
''',
        encoding="utf-8",
    )
    (output / "build").mkdir()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    stage(parser.parse_args().output.resolve())
