"""Verify the exact Pixel Vixen V2 candidate sources and optional Web PCK entries."""
import argparse
import hashlib
import json
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1]
DIRECTORY = Path("assets/art-candidates/pixel-vixen/v2")
V1 = "assets/art-candidates/pixel-vixen/v1/"
ASSETS = (
    ("atlas", "atlas_sha256", "atlas_dimensions", "pixel-vixen-atlas-v2.png", (896, 672)),
    ("portrait", "portrait_sha256", "portrait_dimensions", "pixel-vixen-portrait-v2.png", (520, 460)),
    ("hud_portrait", "hud_sha256", "hud_dimensions", "pixel-vixen-hud-v2.png", (480, 320)),
)

def validate(root=ROOT):
    manifest = json.loads((root / DIRECTORY / "manifest.json").read_text())
    if (manifest.get("hero_id") != "sigma" or manifest.get("appearance") != "female"
            or manifest.get("status") != "UNAPPROVED_CREATOR_REVIEW_CANDIDATE"
            or manifest.get("runtime_authorization") != "PREVIEW_ONLY"):
        raise ValueError("Pixel Vixen must remain a preview-only Sigma cosmetic candidate")
    missing = [name for _, _, _, name, _ in ASSETS if not (root / DIRECTORY / name).is_file()]
    if missing:
        raise ValueError("Required Pixel Vixen V2 source PNGs are absent: " + ", ".join(missing)
                         + ". Import pixel_vixen_v2_upload_ready.zip; V1 is not a fallback.")
    paths = []
    for field, hash_key, size_key, name, size in ASSETS:
        if manifest.get(field) != name or tuple(manifest.get(size_key, [])) != size:
            raise ValueError("Unexpected Pixel Vixen source manifest geometry/path: " + name)
        path = root / DIRECTORY / name
        data = path.read_bytes()
        if hashlib.sha256(data).hexdigest() != manifest.get(hash_key):
            raise ValueError("Pixel Vixen source SHA-256 mismatch: " + name)
        if (len(data) < 33 or data[:8] != b"\x89PNG\r\n\x1a\n" or data[12:16] != b"IHDR"
                or struct.unpack_from(">II", data, 16) != size):
            raise ValueError("Pixel Vixen PNG dimensions/header mismatch: " + name)
        paths.append((DIRECTORY / name).as_posix())
    return paths

def validate_pack(paths, sources):
    if (DIRECTORY / "manifest.json").as_posix() not in paths:
        raise ValueError("Pixel Vixen V2 provenance manifest is missing from Web PCK")
    if any(path.startswith(V1) for path in paths):
        raise ValueError("Superseded Pixel Vixen V1 source leaked into Web PCK")
    for source in sources:
        if source + ".import" not in paths or not any(
                path.startswith(".godot/imported/" + Path(source).name + "-")
                and path.endswith(".ctex") for path in paths):
            raise ValueError("Required illustrated V2 texture is missing from Web PCK: " + source)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pack", type=Path, nargs="?")
    args = parser.parse_args()
    try:
        sources = validate()
        if args.pack:
            from check_icon_pack import directory
            validate_pack(directory(args.pack.read_bytes()), sources)
        print("PASS: Three exact Pixel Vixen V2 PNGs, geometry and pending-art status"
              + ("; Web textures/manifest present and V1 excluded" if args.pack else ""))
    except (ValueError, OSError, struct.error) as error:
        parser.exit(1, "ERROR: " + str(error) + "\n")
