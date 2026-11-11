"""Offline source lineage, runtime hashes and optional exported PCK integrity."""
import argparse
import hashlib
import json
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1]
DIRECTORY = Path("assets/production/cool-kid/cpk-v1")
SOURCE_SHA = "c50232da6978c9751768319f1f59454cff548173cc0bd5b15f7a1d206f649ddf"
ATLAS_SHA = "0a190b57982dfd8556da6b8e05cf38aae4f83e392461ef8a6c2bb42c2340925d"


def validate(root=ROOT):
    folder = root / DIRECTORY
    manifest = json.loads((folder / "manifest.json").read_text())
    if manifest["source"]["sha256"] != SOURCE_SHA or manifest["source"]["git_blob"] != "08810472f1a95cddc745869fa57684e6e6b6fe3f":
        raise ValueError("Unapproved source lineage")
    if manifest["atlas"]["sha256"] != ATLAS_SHA:
        raise ValueError("Unexpected derivative revision")
    if manifest["kit_id"] != "cool-kid" or len(manifest["frames"]) != 49:
        raise ValueError("Kit/frame contract changed")
    for role, dimensions in [("atlas",(1008,1008)),("portrait",(146,184))]:
        record = manifest[role]
        data = (folder / record["path"]).read_bytes()
        if hashlib.sha256(data).hexdigest() != record["sha256"]:
            raise ValueError("SHA-256 mismatch: " + role)
        if data[:8] != b"\x89PNG\r\n\x1a\n" or struct.unpack_from(">II",data,16) != dimensions or data[25] != 6:
            raise ValueError("RGBA PNG geometry mismatch: " + role)
    for index, frame in enumerate(manifest["frames"]):
        if frame["index"] != index or frame["origin"] != [72,120] or frame["cell"] != [index%7*144,index//7*144,144,144]:
            raise ValueError("Frame geometry/pivot mismatch")
        left, top, right, bottom = frame["alpha_bounds"]
        if min(left,top) <= 1 or max(right,bottom) >= 143:
            raise ValueError("Clipped or unpadded frame")
    return manifest


def validate_pack(pack, manifest):
    from check_icon_pack import directory
    paths = directory(pack.read_bytes())
    required = [str(DIRECTORY / "manifest.json").replace('\\','/')]
    for role in ["atlas","portrait"]:
        path = (DIRECTORY / manifest[role]["path"]).as_posix()
        required += [path+".import"]
        if not any(p.startswith(".godot/imported/"+manifest[role]["path"]+"-") and p.endswith(".ctex") for p in paths):
            raise ValueError("Missing imported CPK texture: " + role)
    if not all(path in paths for path in required):
        raise ValueError("Missing exported import descriptor or provenance manifest")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pack",type=Path,nargs="?")
    args = parser.parse_args()
    manifest = validate()
    if args.pack:
        validate_pack(args.pack,manifest)
    print("PASS: Cool Kid exact lineage, hashes, RGBA geometry and 49 padded foot pivots" + ("; exported PCK resources" if args.pack else ""))
