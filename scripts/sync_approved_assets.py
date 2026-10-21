#!/usr/bin/env python3
"""Fetch exact approved Phaser assets for Godot Web export; fail closed on a changed byte."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from urllib.request import urlopen

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "assets" / "approved-assets.json"
PREFIX = "https://raw.githubusercontent.com/"


def validate_entry(item: dict) -> None:
    path = item["source_path"]
    dest = item["destination"]
    if not path.startswith("public/assets/") or ".." in Path(path).parts:
        raise ValueError(f"Unsafe source path: {path}")
    if not dest.startswith("assets/approved/") or ".." in Path(dest).parts:
        raise ValueError(f"Unsafe destination path: {dest}")
    if len(item["git_blob_sha1"]) != 40 or item["bytes"] < 0:
        raise ValueError(f"Invalid blob metadata: {path}")
    if "sha256" in item and len(item["sha256"]) != 64:
        raise ValueError(f"Invalid SHA-256 metadata: {path}")


def verify(raw: bytes, item: dict) -> None:
    if len(raw) != item["bytes"]:
        raise ValueError(f"Unexpected byte size: {item['source_path']}")
    git_hash = hashlib.sha1(b"blob " + str(len(raw)).encode() + bytes([0]) + raw).hexdigest()
    if git_hash != item["git_blob_sha1"]:
        raise ValueError(f"Git blob mismatch: {item['source_path']}")
    if "sha256" in item and hashlib.sha256(raw).hexdigest() != item["sha256"]:
        raise ValueError(f"SHA-256 mismatch: {item['source_path']}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check-manifest", action="store_true", help="Validate metadata without downloads")
    args = parser.parse_args()

    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if manifest["source_repo"] != "pedro-ai-coder/aura-farmer":
        raise ValueError("Unexpected source repository")
    commit = manifest["source_commit"]
    if len(commit) != 40:
        raise ValueError("Missing immutable source revision")
    assets = manifest["assets"]
    destinations = set()
    for item in assets:
        validate_entry(item)
        if item["destination"] in destinations:
            raise ValueError("Duplicate output destination")
        destinations.add(item["destination"])

    if args.check_manifest:
        print(f"PASS: {len(assets)} approved asset paths and checksums validated")
        return

    for item in assets:
        target = ROOT / item["destination"]
        if target.exists():
            raw = target.read_bytes()
            verify(raw, item)
            print(f"Verified existing approved asset: {target.name}")
            continue
        url = f"{PREFIX}{manifest['source_repo']}/{commit}/{item['source_path']}"
        print(f"Downloading approved art: {item['source_path']}", flush=True)
        with urlopen(url, timeout=90) as response:
            raw = response.read(item["bytes"] + 1)
        verify(raw, item)
        target.parent.mkdir(parents=True, exist_ok=True)
        temporary = target.with_suffix(target.suffix + ".download")
        temporary.write_bytes(raw)
        temporary.replace(target)
    print(f"PASS: {len(assets)} approved Phaser art files downloaded and hash-checked")


if __name__ == "__main__":
    main()
