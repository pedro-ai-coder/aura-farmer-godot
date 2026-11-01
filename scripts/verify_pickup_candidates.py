"""Exact-byte candidate validation and fail-closed exported pickup resources."""
import hashlib
import json
from pathlib import Path
import struct
import sys

ROOT = Path(__file__).resolve().parents[1]
FOLDER = "assets/art-candidates/pickups/v1/"
MANIFEST = FOLDER + "manifest.json"
EXPECTED = {"aura": ("xp-orb", "XP Orb", 32), "snack": ("street-snack", "Street Snack", 40), "magnet": ("aura-magnet", "Aura Magnet", 40)}

def validate(root=ROOT):
    m = json.loads((root / MANIFEST).read_text())
    if m.get("status") != "CANDIDATE_PENDING_CREATOR_REVIEW" or m.get("runtime_authorization") != "REVIEW_BRANCH_ONLY":
        raise ValueError("Pickup artwork must remain a review candidate")
    rows = m["resources"]
    if len(rows) != 3 or {r["kind"] for r in rows} != set(EXPECTED):
        raise ValueError("Exactly the three canonical pickup mappings are required")
    for row in rows:
        slug, label, extent = EXPECTED[row["kind"]]
        if (row["runtime_path"], row["source_path"], row["display_name"], row["world_extent"], row["dimensions"], row["approval_status"]) != (FOLDER+slug+".png", FOLDER+"source/"+slug+".svg", label, extent, [128,128], "CANDIDATE_PENDING_CREATOR_REVIEW"):
            raise ValueError("Incorrect canonical pickup artwork mapping")
        for key, sha_key in [("runtime_path", "sha256"), ("source_path", "source_sha256")]:
            p = root / row[key]
            if not p.is_file(): raise ValueError("Missing pickup asset: " + row[key])
            if hashlib.sha256(p.read_bytes()).hexdigest() != row[sha_key]:
                raise ValueError("Pickup SHA-256 mismatch: " + row[key])
        png = (root / row["runtime_path"]).read_bytes()
        if png[:8] != b"\x89PNG\r\n\x1a\n" or struct.unpack(">II", png[16:24]) != (128,128) or png[24:26] != b"\x08\x06":
            raise ValueError("Pickup requires a 128x128 RGBA PNG")
        svg = (root / row["source_path"]).read_text()
        if any(token in svg for token in ["<text", "<image", "href=", "<filter"]):
            raise ValueError("Pickup sources must be self-contained editable vectors")
    return [r["runtime_path"] for r in rows]

def validate_pack(paths, textures):
    if MANIFEST not in paths: raise ValueError("Missing exported pickup manifest")
    for p in textures:
        if p+".import" not in paths: raise ValueError("Missing exported pickup import: " + p)
        if not any(x.startswith(".godot/imported/"+Path(p).name+"-") and x.endswith(".ctex") for x in paths):
            raise ValueError("Missing exported pickup texture: " + p)
    if any(p.startswith(FOLDER+"source/") or p.startswith("tests/pickup_refresh/") for p in paths):
        raise ValueError("Editable sources/review fixtures must not ship in the Web pack")

if __name__ == "__main__":
    try:
        textures = validate()
        if len(sys.argv) > 1:
            from check_icon_pack import directory
            validate_pack(directory(Path(sys.argv[1]).read_bytes()), textures)
        print("PASS: three exact-byte pickup candidates, canonical mappings and transparency" + ("; Web textures/manifest present and review fixtures excluded" if len(sys.argv)>1 else ""))
    except (ValueError, KeyError, OSError) as exc:
        raise SystemExit("ERROR: " + str(exc))
