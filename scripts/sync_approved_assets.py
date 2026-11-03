#!/usr/bin/env python3
"""Validate vendored approved art, optionally importing it once from a local snapshot.

Normal builds are strictly offline with respect to game artwork. The Phaser
repository is historical provenance, never a runtime or build-time dependency.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "assets" / "approved-assets.json"


def validate_entry(item: dict) -> None:
    path = item["source_path"]
    dest = item["destination"]
    if not path.startswith("public/assets/") or ".." in Path(path).parts:
        raise ValueError(f"Unsafe provenance path: {path}")
    if not dest.startswith("assets/approved/") or ".." in Path(dest).parts:
        raise ValueError(f"Unsafe approved art path: {dest}")
    if len(item["git_blob_sha1"]) != 40 or item["bytes"] < 0:
        raise ValueError(f"Invalid blob metadata: {path}")
    if "sha256" in item and len(item["sha256"]) != 64:
        raise ValueError(f"Invalid SHA-256 metadata: {path}")


def verify(raw: bytes, item: dict) -> None:
    if len(raw) != item["bytes"]:
        raise ValueError(f"Unexpected byte size: {item['destination']}")
    git_hash = hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\x00" + raw).hexdigest()
    if git_hash != item["git_blob_sha1"]:
        raise ValueError(f"Git blob mismatch: {item['destination']}")
    if "sha256" in item and hashlib.sha256(raw).hexdigest() != item["sha256"]:
        raise ValueError(f"SHA-256 mismatch: {item['destination']}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check-manifest", action="store_true", help="Only validate manifest metadata.")
    parser.add_argument(
        "--import-from",
        type=Path,
        help="One-time local copy of exact source bytes from an existing Phaser checkout. "
        "Never used by builds; no network access or repository credentials required here.",
    )
    args = parser.parse_args()

    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if manifest["source_repo"] != "pedro-ai-coder/aura-farmer":
        raise ValueError("Unexpected historical approved source")
    if len(manifest["source_commit"]) != 40:
        raise ValueError("Missing immutable source revision")
    assets = manifest["assets"]
    destinations: set[str] = set()
    for item in assets:
        validate_entry(item)
        if item["destination"] in destinations:
            raise ValueError("Duplicate approved asset destination")
        destinations.add(item["destination"])

    if args.check_manifest:
        print(f"PASS: {len(assets)} approved asset paths and checksums validated")
        return

    imported = 0
    missing: list[str] = []
    snapshot = args.import_from.resolve() if args.import_from else None
    for item in assets:
        target = ROOT / item["destination"]
        if not target.is_file() and snapshot is not None:
            source = snapshot / item["source_path"]
            if not source.is_file():
                missing.append(item["destination"])
                continue
            raw = source.read_bytes()
            verify(raw, item)
            target.parent.mkdir(parents=True, exist_ok=True)
            temporary = target.with_suffix(target.suffix + ".importing")
            temporary.write_bytes(raw)
            temporary.replace(target)
            imported += 1
        if not target.is_file():
            missing.append(item["destination"])
            continue
        verify(target.read_bytes(), item)

    if missing:
        raise SystemExit(
            "ERROR: Missing " + str(len(missing)) + " approved local asset(s):\n  "
            + "\n  ".join(missing)
            + "\nBuilds never download Phaser artwork. Restore the pinned source bytes once "
            "using --import-from PATH and commit the exact files to this repository."
        )
    print(f"PASS: {len(assets)} approved assets are local and checksum verified"
          + (f"; imported {imported} exact assets" if imported else "; zero network requests"))


if __name__ == "__main__":
    main()
