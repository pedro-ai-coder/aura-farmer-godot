"""Validate the creator-approved Clean Cut V2 runtime promotion, byte-for-byte.

The approval in docs/art/CREATOR_CLEAN_CUT_V2_APPROVAL_2026-10-24.md
covers exact source versions only, never older rejected compositions.
"""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "assets/runtime-clean-cut/v2/manifest.json"


def validate() -> list[dict]:
    payload = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if payload.get("status") != "CREATOR_APPROVED" or payload.get("source_commit") != "c1e13cdca5e0645e5f809dc6453ee75f979c8d4e":
        raise ValueError("Clean Cut runtime manifest is not pinned to the creator-approved package")
    resources = payload.get("resources", {})
    if len(resources) != 84:
        raise ValueError(f"Expected 84 approved runtime resources, got {len(resources)}")
    expected = set()
    records = []
    for key, row in resources.items():
        source = ROOT / row["source_path"]
        if not row.get("resource_path", "").startswith("res://assets/runtime-clean-cut/v2/"):
            raise ValueError(f"Unsafe runtime path for {key}")
        destination = ROOT / row["resource_path"].removeprefix("res://")
        if not source.is_file() or not destination.is_file():
            raise ValueError(f"Missing Clean Cut source/runtime resource: {key}")
        if destination.suffix not in (".png", ".svg"):
            raise ValueError(f"Unsupported Clean Cut runtime type for {key}")
        sha = hashlib.sha256(source.read_bytes()).hexdigest()
        if sha != row["source_sha256"] or hashlib.sha256(destination.read_bytes()).hexdigest() != sha:
            raise ValueError(f"Approved source/hash/byte mismatch: {key}")
        if row.get("approval_status") != "CREATOR_APPROVED" or "2026-10-24" not in row.get("approval_reference", ""):
            raise ValueError(f"No explicit creator approval recorded: {key}")
        expected.add(destination.resolve())
        records.append({"id": key, "path": str(destination.relative_to(ROOT)), "sha256": sha})
    runtime_root = ROOT / "assets/runtime-clean-cut/v2"
    actual = {f.resolve() for f in runtime_root.rglob("*") if f.is_file() and f.name != "manifest.json" and not f.name.endswith(".import")}
    if actual != expected:
        raise ValueError(f"Unregistered Clean Cut runtime assets: {sorted(str(x) for x in actual ^ expected)}")
    return records


if __name__ == "__main__":
    items = validate()
    print(f"PASS: {len(items)} immutable creator-approved Clean Cut visual resources match SHA-256 sources")
