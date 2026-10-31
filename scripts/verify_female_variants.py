"""Pin the two remaining cosmetic candidates and verify their exported resources."""
import argparse
import hashlib
import json
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1]
VARIANTS = {"byte-baddie": ("cool-kid", "BYTE BADDIE"), "block-queen": ("alpha", "BLOCK QUEEN")}
STATES = {name: [i*4, i*4+3] for i, name in enumerate(("idle", "run", "attack", "hurt", "flex", "defeat"))}
KINDS = (("atlas", "atlas", (1024,1536)), ("portrait", "portrait", (1254,1254)),
         ("hud", "hud_portrait", (1536,1024)))

def validate(root=ROOT):
    sources, metadata = [], []
    for slug, (hero_id, name) in VARIANTS.items():
        folder = Path("assets/art-candidates") / slug / "v2"
        manifest = json.loads((root/folder/"manifest.json").read_text())
        if (manifest.get("hero_id") != hero_id or manifest.get("appearance") != "female"
                or manifest.get("display_name") != name or manifest.get("asset_slug") != slug
                or manifest.get("status") != "UNAPPROVED_CREATOR_REVIEW_CANDIDATE"
                or manifest.get("runtime_authorization") != "PREVIEW_ONLY"):
            raise ValueError("Invalid preview-only canonical cosmetic identity: " + slug)
        for suffix, key, size in KINDS:
            filename = f"{slug}-{suffix}-v2.png"
            checksum = "hud_sha256" if suffix == "hud" else key+"_sha256"
            dimensions = "hud_dimensions" if suffix == "hud" else key+"_dimensions"
            path = folder/filename
            if manifest.get(key) != filename or tuple(manifest.get(dimensions, [])) != size:
                raise ValueError("Incorrect source geometry/path: " + filename)
            if not (root/path).is_file(): raise ValueError("Missing required female asset: " + filename)
            data = (root/path).read_bytes()
            if hashlib.sha256(data).hexdigest() != manifest.get(checksum):
                raise ValueError("Source SHA-256 mismatch: " + filename)
            if (len(data)<33 or data[:8]!=b"\x89PNG\r\n\x1a\n" or data[12:16]!=b"IHDR"
                    or struct.unpack_from(">II",data,16)!=size or data[24:26]!=b"\x08\x06"):
                raise ValueError("Expected full-resolution RGBA PNG: " + filename)
            sources.append(path.as_posix())
        if manifest.get("states") != STATES or manifest.get("frame_count") != 24:
            raise ValueError("All six animated states are mandatory: " + slug)
        if manifest.get("frame_geometry") != "frames.json" or not 0<float(manifest.get("world_scale",0))<1:
            raise ValueError("Invalid source registration: " + slug)
        geometry = (root/folder/"frames.json").read_bytes()
        if hashlib.sha256(geometry).hexdigest() != manifest.get("frame_geometry_sha256"):
            raise ValueError("Frame geometry SHA-256 mismatch: " + slug)
        frames = json.loads(geometry)
        if len(frames) != 24: raise ValueError("Missing animated poses: " + slug)
        for frame in frames:
            r, p, masks = frame["source_rect"], frame["pivot"], frame["mask_rects"]
            if (len(r)!=4 or len(p)!=2 or not masks or not all(type(v) is int for v in r)
                    or min(r[:2])<0 or min(r[2:])<=0 or r[0]+r[2]>1024 or r[1]+r[3]>1536):
                raise ValueError("Invalid atlas source region: " + slug)
            for x,y,w,h in masks:
                if min(x,y)<0 or min(w,h)<=0 or x+w>r[2] or y+h>r[3]:
                    raise ValueError("Frame mask escapes its source region: " + slug)
        metadata.extend([(folder/"manifest.json").as_posix(), (folder/"frames.json").as_posix()])
    return sources, metadata

def validate_pack(paths, sources, metadata):
    for path in metadata:
        if path not in paths: raise ValueError("Missing Web provenance/geometry: " + path)
    for path in sources:
        if path+".import" not in paths or not any(p.startswith(".godot/imported/"+Path(path).name+"-") and p.endswith(".ctex") for p in paths):
            raise ValueError("Missing female Web texture: " + path)
    if any(p.startswith("assets/art-candidates/"+slug+"/v1/") for p in paths for slug in VARIANTS):
        raise ValueError("V1 fallback leaked into the female roster export")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pack", type=Path, nargs="?")
    args = parser.parse_args()
    try:
        sources, metadata = validate()
        if args.pack:
            from check_icon_pack import directory
            validate_pack(directory(args.pack.read_bytes()), sources, metadata)
        print("PASS: Byte Baddie/Block Queen exact RGBA art, six animated states, geometry and preview-only canonical mappings"
              + ("; all six Web textures/geometry/manifests present, V1 excluded" if args.pack else ""))
    except (ValueError, OSError, KeyError, TypeError, struct.error) as error:
        parser.exit(1, "ERROR: " + str(error) + "\n")
