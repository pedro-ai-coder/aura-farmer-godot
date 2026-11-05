#!/usr/bin/env python3
"""Fail closed for any optionally staged Level Zero art pack.

No pack is valid for the current placeholder-only experimental build.
A staged pack must pass exact hashes and PNG IHDR size checks before export.
Metadata alone never grants artwork approval.
"""
import hashlib
import json
from pathlib import Path
import struct
import sys

ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / "assets/experimental/level_zero/visual_pack_v1.json"
RECORDS = {
    "background": ("print_press_arena_candidate.png", "0eb3f31bc22d5508c4fb3553335fe3279e3de3ec46566a3581a11d0f8931ed23"),
    "foreground": ("torn_poster_foreground_candidate.png", "ceff210f3f642457ae4bd01507b96e9be431728cb0c339b9cbe3847fd1acb76d"),
    "boss": ("big_hater_imitation_candidate.png", "7510fb0805f8ec9afa2ce1148a6ca50e2bb996bbc721bc6a6c4a90d68ae67fcb"),
}
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


def check_pack(pack_path=PACK):
    pack_path = Path(pack_path)
    if not pack_path.exists():
        return ["NO_PACK: placeholder visuals remain; candidate art was not integrated"], []
    data = json.loads(pack_path.read_text(encoding="utf-8"))
    errors = []
    if data.get("schema_version") != "level-zero-visual-pack-v1" or data.get("status") != "EXPERIMENTAL_CANDIDATE":
        errors.append("Unexpected pack schema/status")
    if set(data) - {"schema_version", "status", *RECORDS.keys(), "source_commit"}:
        errors.append("Unknown pack fields")
    base = pack_path.parent
    for role, (name, source_sha) in RECORDS.items():
        item = data.get(role)
        if item is None:
            continue
        if not isinstance(item, dict):
            errors.append(f"{role}: entry must be an object")
            continue
        expected_path = f"res://assets/experimental/level_zero/{name}"
        if item.get("path") != expected_path or item.get("source_sha256") != source_sha or item.get("status") != "CANDIDATE":
            errors.append(f"{role}: invalid path/status/source")
            continue
        source = base / name
        if not source.is_file():
            errors.append(f"{role}: missing staged PNG")
            continue
        raw = source.read_bytes()
        digest = hashlib.sha256(raw).hexdigest()
        if digest != item.get("verified_export_sha256"):
            errors.append(f"{role}: export hash mismatch")
        if len(raw) < 24 or raw[:8] != PNG_SIGNATURE or raw[12:16] != b"IHDR":
            errors.append(f"{role}: not a valid PNG header")
            continue
        width, height = struct.unpack(">II", raw[16:24])
        if [width, height] != item.get("dimensions_px"):
            errors.append(f"{role}: wrong dimensions")
        if role == "background" and (width, height) != (1672, 941):
            errors.append("background: original source dimensions changed")
        if role == "foreground":
            if item.get("render_under_actors") is not True:
                errors.append("foreground: must be an underlay behind actors and hazards")
            if len(raw) < 26 or raw[25] != 6:
                errors.append("foreground: candidate must be an RGBA PNG")
        if role == "boss":
            if item.get("standalone_candidate") is not True:
                errors.append("boss: candidate must be a standalone RGBA sprite")
            if len(raw) < 26 or raw[25] != 6:
                errors.append("boss: candidate must be an RGBA PNG")
            pivot = item.get("foot_pivot_px")
            height_world = item.get("world_height")
            if (not isinstance(pivot, list) or len(pivot) != 2 or
                not all(isinstance(v, (int, float)) and 0 <= v for v in pivot) or
                not isinstance(height_world, (int, float)) or not 0 < height_world < 4096):
                errors.append("boss: missing valid pivot/scale contract")
    return [], errors


def main():
    warnings, errors = check_pack()
    for warning in warnings:
        print(warning)
    for error in errors:
        print("ERROR:", error, file=sys.stderr)
    if errors:
        return 1
    print("PASS: staged candidate pack verified or placeholder-only build")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
