#!/usr/bin/env python3
"""Reproducible Pixel Vixen review-atlas extraction from creator-provided art.

Use: python3 scripts/prepare_pixel_vixen_art.py path/to/sprite_atlas_da_pixel_vixen.png
Requires Pillow (offline art-production tool only; no Godot runtime dependency).
Output belongs in assets/art-candidates/pixel-vixen/v2/.
This does not grant art approval or alter the gameplay kit.
"""
from pathlib import Path
import hashlib
import json
import sys

try:
    from PIL import Image
except ImportError:
    raise SystemExit("Install Pillow in the art-production environment.")

if len(sys.argv) != 2:
    raise SystemExit("Usage: prepare_pixel_vixen_art.py SOURCE_PNG")
src_path = Path(sys.argv[1])
src = Image.open(src_path).convert("RGBA")
if src.size != (1448, 1086):
    raise SystemExit(f"Expected creator's 1448x1086 7x7 sheet, received {src.size}")

target = Path("assets/art-candidates/pixel-vixen/v2")
target.mkdir(parents=True, exist_ok=True)
atlas = Image.new("RGBA", (896, 672), (0, 0, 0, 0))
for row in range(7):
    for col in range(7):
        frame = src.crop((
            round(col * src.width / 7), round(row * src.height / 7),
            round((col + 1) * src.width / 7), round((row + 1) * src.height / 7),
        )).resize((128, 96), Image.Resampling.LANCZOS)
        atlas.alpha_composite(frame, (128 * col, 96 * row))
atlas_path = target / "pixel-vixen-atlas-v2.png"
atlas.save(atlas_path, optimize=True)

first = src.crop((0, 0, round(src.width / 7), round(src.height / 7)))
bbox = first.getchannel("A").getbbox()
if bbox is not None:
    first = first.crop(bbox)
scale = min(256 / first.width, 256 / first.height)
first = first.resize(
    (round(first.width * scale), round(first.height * scale)),
    Image.Resampling.LANCZOS,
)
portrait = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
portrait.alpha_composite(first, ((256 - first.width) // 2, (256 - first.height) // 2))
portrait_path = target / "pixel-vixen-portrait-v2.png"
portrait.save(portrait_path, optimize=True)

def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

manifest = json.loads((target / "manifest.json").read_text("utf-8"))
for field, path in [("source_sha256", src_path), ("atlas_sha256", atlas_path),
                    ("portrait_sha256", portrait_path)]:
    if sha256(path) != manifest[field]:
        raise SystemExit(f"{field} mismatch: expected {manifest[field]}, got {sha256(path)}")
print(f"Pixel Vixen candidate V2 verified: {sha256(atlas_path)}")
