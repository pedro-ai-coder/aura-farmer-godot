#!/usr/bin/env python3
"""Reconstruct the exact experimental Level Zero arena PNG before Godot imports.

The creator-uploaded original is stored in lossless, Git-tracked base64 chunks.
No synthetic art and no effect on normal Ruin Alley. Fail closed on bad sources.
"""
import base64
import hashlib
from pathlib import Path
import struct
import sys

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "assets" / "experimental" / "level_zero"
TARGET = BASE / "print_press_arena_candidate.png"
CHUNKS = [BASE / "_source" / ("print_press_arena_candidate.png.b64.%03d" % i) for i in (1, 2, 3)]
HASHES = {
    "print_press_arena_candidate.png": ("0eb3f31bc22d5508c4fb3553335fe3279e3de3ec46566a3581a11d0f8931ed23", (1672, 941)),
    "torn_poster_foreground_candidate.png": ("ceff210f3f642457ae4bd01507b96e9be431728cb0c339b9cbe3847fd1acb76d", (1672, 941)),
    "big_hater_imitation_candidate.png": ("7510fb0805f8ec9afa2ce1148a6ca50e2bb996bbc721bc6a6c4a90d68ae67fcb", (1312, 1199)),
}

def assert_original(name: str, raw: bytes) -> None:
    expected_sha, size = HASHES[name]
    if hashlib.sha256(raw).hexdigest() != expected_sha:
        raise ValueError(name + ": original SHA256 mismatch")
    if len(raw) < 26 or raw[:8] != b"\x89PNG\r\n\x1a\n" or raw[12:16] != b"IHDR":
        raise ValueError(name + ": original PNG header mismatch")
    dims = struct.unpack(">II", raw[16:24])
    if dims != size:
        raise ValueError(name + ": original PNG dimensions mismatch")

def stage_originals(base: Path = BASE) -> str:
    pack = base / "visual_pack_v1.json"
    if not pack.exists():
        return "No experimental art pack staged; normal Ruin Alley unchanged"
    target = base / "print_press_arena_candidate.png"
    if not target.exists():
        parts = [base / "_source" / p.name for p in CHUNKS]
        if not all(p.is_file() for p in parts):
            raise FileNotFoundError("Missing a byte-preserving arena source part")
        b64 = "".join("".join(p.read_text(encoding="ascii").split()) for p in parts)
        arena = base64.b64decode(b64, validate=True)
        assert_original(target.name, arena)
        target.write_bytes(arena)
    for name in HASHES:
        file = base / name
        if not file.is_file():
            raise FileNotFoundError(name + ": missing exact experimental art candidate")
        assert_original(name, file.read_bytes())
    return "PASS: 3 exact experimental Level Zero PNGs ready for Godot import"

if __name__ == "__main__":
    try:
        print(stage_originals())
    except (OSError, ValueError) as exc:
        print("ERROR:", exc, file=sys.stderr)
        sys.exit(1)
