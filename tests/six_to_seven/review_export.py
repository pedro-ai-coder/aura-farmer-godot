"""Stage a local Windows or Web review export with the game's original entry scene."""
import argparse
from pathlib import Path
import re
import shutil
import sys

ROOT = Path(__file__).resolve().parents[2]
RENDERER = "scripts/vfx/six_to_seven.gd"
NEON_RENDERER = "scripts/vfx/six_to_seven_neon_impact.gd"
NO_U_RESOURCES = ("scripts/review/no_u_scenario.gd", "scripts/vfx/no_u_counter_pulse.gd",
                  "scripts/review/no_u_reverse_scenario.gd", "scripts/vfx/no_u_reverse_impact.gd", "scripts/vfx/no_u_reverse_impact_v3.gd")


def stage(destination: Path, target: str, no_u: bool = False) -> None:
    if destination == ROOT or ROOT in destination.parents:
        raise ValueError("Stage the export in a fresh folder outside this checkout")
    destination.mkdir(parents=True, exist_ok=False)
    for name in ("scripts", "assets", "scenes", "web"):
        shutil.copytree(ROOT / name, destination / name, ignore=shutil.ignore_patterns(
            "__pycache__", "performance_probe.gd*", "performance.js"))
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    review_name = "No U Review" if no_u else "Six to Seven Review"
    project = re.sub(r"(?m)^config/name=.*$", f'config/name="CLUTCHPUNKS {review_name}"', project)
    (destination / "project.godot").write_text(project, encoding="utf-8")
    presets = (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
    preset = presets.split("[preset.1]", 1)[0]
    feature = "no_u_review" if no_u else "six_to_seven_review"
    preset = preset.replace('custom_features=""', f'custom_features="{feature}"')
    if no_u:
        for name in NO_U_RESOURCES:
            preset = preset.replace("," + name, "")
    if target == "windows":
        preset = preset[:preset.index("[preset.0.options]")]
        preset = preset.replace('name="Web"', f'name="{review_name}"')
        preset = preset.replace('platform="Web"', 'platform="Windows Desktop"')
        preset = preset.replace('export_path="build/web/index.html"', f'export_path="build/CLUTCHPUNKS {review_name}.exe"')
        preset += '''[preset.0.options]
binary_format/embed_pck=false
binary_format/architecture="x86_64"
application/modify_resources=false
codesign/enable=false
'''
    (destination / "export_presets.cfg").write_text(preset, encoding="utf-8")
    (destination / "build").mkdir()


def verify(path: Path, included: bool, no_u: bool = False) -> None:
    sys.path.insert(0, str(ROOT / "scripts"))
    from check_icon_pack import directory

    entries = directory(path.read_bytes())
    assert not any(name.startswith("tests/") or name.startswith("qa/") for name in entries), "QA resources in gameplay pack"
    renderer = {name for name in entries if name.startswith("scripts/vfx/")}
    # V3 is now approved for both regular gameplay and review packages.
    expected = {name + suffix for name in (RENDERER, NEON_RENDERER)
                for suffix in (".remap", "c")}
    no_u_entries = {name + suffix for name in NO_U_RESOURCES for suffix in (".remap", "c")}
    actual_no_u = {name for name in entries if name.startswith(NO_U_RESOURCES)}
    if actual_no_u != (no_u_entries if no_u else set()):
        raise ValueError(f"Unexpected Counter-Pulse packaging: {actual_no_u!r}")
    expected |= {name for name in no_u_entries if no_u and name.startswith("scripts/vfx/")}
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
    parser.add_argument("--no-u", action="store_true")
    args = parser.parse_args()
    if args.stage:
        stage(args.stage.resolve(), args.target, args.no_u)
    else:
        verify(args.verify.resolve(), args.review or args.no_u, args.no_u)
