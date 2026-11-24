"""Stage the allowlisted passive VFX Lab resources for an isolated Web preview."""
import argparse
from pathlib import Path
import re
import sys

from prepare_review_export import LAB_FILES

SOURCE = Path(__file__).resolve().parent
REVIEW_PATH = "qa/passive_vfx_lab"
SCENE = f"res://{REVIEW_PATH}/main.tscn"


def prepare(root: Path, revision: str | None) -> None:
    destination = root / REVIEW_PATH
    destination.mkdir(parents=True, exist_ok=True)
    for name in LAB_FILES:
        content = (SOURCE / name).read_text(encoding="utf-8")
        destination.joinpath(name).write_text(
            content.replace("res://tests/passive_vfx_lab/", f"res://{REVIEW_PATH}/"),
            encoding="utf-8",
        )
    project = root / "project.godot"
    config, replaced = re.subn(
        r"(?m)^run/main_scene=.*$", f'run/main_scene="{SCENE}"',
        project.read_text(encoding="utf-8"),
    )
    if replaced != 1:
        raise ValueError("Expected one Godot main scene setting")
    if revision is not None:
        if re.fullmatch(r"[a-fA-F0-9]{7,40}", revision) is None:
            raise ValueError("Invalid preview revision")
        setting = f'passive_vfx_lab_commit="{revision}"'
        config, updated = re.subn(r"(?m)^passive_vfx_lab_commit=.*$", setting, config)
        if updated == 0:
            config += "\n[qa]\n\n" + setting + "\n"
    project.write_text(config, encoding="utf-8")


def verify(pack: Path) -> None:
    sys.path.insert(0, str(SOURCE.parents[1] / "scripts"))
    from check_icon_pack import directory

    entries = directory(pack.read_bytes())
    review = {path for path in entries if path.startswith(REVIEW_PATH + "/")}
    expected = {f"{REVIEW_PATH}/{name}.remap" for name in LAB_FILES}
    expected.update(f"{REVIEW_PATH}/{name}c" for name in LAB_FILES if name.endswith(".gd"))
    if review != expected or any(path.startswith("tests/") for path in entries):
        raise ValueError("The Web review pack does not match the lab allowlist")
    print(f"PASS: {len(review)} Passive VFX Lab pack entries")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    operation = parser.add_mutually_exclusive_group(required=True)
    operation.add_argument("--prepare", type=Path)
    operation.add_argument("--verify", type=Path)
    parser.add_argument("--revision")
    args = parser.parse_args()
    if args.prepare is not None:
        prepare(args.prepare.resolve(), args.revision)
    else:
        verify(args.verify.resolve())
