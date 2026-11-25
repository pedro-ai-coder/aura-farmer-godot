"""Stage a local Windows or Web review export with the game's original entry scene."""
import argparse
from pathlib import Path
import re
import shutil
import sys

ROOT = Path(__file__).resolve().parents[2]
RENDERER = "scripts/vfx/six_to_seven.gd"
NEON_RENDERER = "scripts/vfx/six_to_seven_neon_impact.gd"


def stage(destination: Path, target: str) -> None:
    if destination == ROOT or ROOT in destination.parents:
        raise ValueError("Stage the export in a fresh folder outside this checkout")
    destination.mkdir(parents=True, exist_ok=False)
    for name in ("scripts", "assets", "scenes", "web"):
        shutil.copytree(ROOT / name, destination / name, ignore=shutil.ignore_patterns(
            "__pycache__", "performance_probe.gd*", "performance.js"))
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    project = re.sub(r"(?m)^config/name=.*$", 'config/name="CLUTCHPUNKS Six to Seven Review"', project)
    (destination / "project.godot").write_text(project, encoding="utf-8")
    presets = (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
    preset = presets.split("[preset.1]", 1)[0]
    preset = preset.replace('custom_features=""', 'custom_features="six_to_seven_review"')
    preset = preset.replace(",scripts/vfx/*", "")
    if target == "windows":
        preset = preset[:preset.index("[preset.0.options]")]
        preset = preset.replace('name="Web"', 'name="Six to Seven Review"')
        preset = preset.replace('platform="Web"', 'platform="Windows Desktop"')
        preset = preset.replace('export_path="build/web/index.html"', 'export_path="build/CLUTCHPUNKS Six to Seven Review.exe"')
        preset += '''[preset.0.options]
binary_format/embed_pck=false
binary_format/architecture="x86_64"
application/modify_resources=false
codesign/enable=false
'''
    (destination / "export_presets.cfg").write_text(preset, encoding="utf-8")
    (destination / "build").mkdir()


def verify(path: Path, included: bool) -> None:
    sys.path.insert(0, str(ROOT / "scripts"))
    from check_icon_pack import directory

    entries = directory(path.read_bytes())
    assert not any(name.startswith("tests/") or name.startswith("qa/") for name in entries), "QA resources in gameplay pack"
    renderer = {name for name in entries if name.startswith("scripts/vfx/")}
    # V3 is now approved for both regular gameplay and review packages.
    expected = {name + suffix for name in (RENDERER, NEON_RENDERER)
                for suffix in (".remap", "c")}
    if renderer != expected:
        raise ValueError(f"Unexpected renderer packaging: {renderer!r}")
    print(f"PASS: {'review' if included else 'production'} includes approved V3 renderer; gameplay pack excludes QA resources")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--stage", type=Path)
    group.add_argument("--verify", type=Path)
    parser.add_argument("--target", choices=("windows", "web"), default="windows")
    parser.add_argument("--review", action="store_true")
    args = parser.parse_args()
    if args.stage:
        stage(args.stage.resolve(), args.target)
    else:
        verify(args.verify.resolve(), args.review)
