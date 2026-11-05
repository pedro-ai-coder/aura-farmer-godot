"""Focused optional visual pack checks; no Godot or original candidate bytes needed."""
import importlib.util
import hashlib
import json
from pathlib import Path
import struct
import tempfile
import unittest

FILE = Path(__file__).resolve().parents[1] / "scripts/verify_level_zero_visual_pack.py"
spec = importlib.util.spec_from_file_location("level_zero_pack", FILE)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class PackTests(unittest.TestCase):
    def test_absent_pack_remains_placeholder(self):
        with tempfile.TemporaryDirectory() as d:
            warnings, errors = module.check_pack(Path(d) / "visual_pack_v1.json")
            self.assertEqual(errors, [])
            self.assertEqual(len(warnings), 1)

    def test_invalid_pack_status_fails(self):
        with tempfile.TemporaryDirectory() as d:
            target = Path(d) / "visual_pack_v1.json"
            target.write_text(json.dumps({"schema_version":"level-zero-visual-pack-v1","status":"APPROVED"}))
            _, errors = module.check_pack(target)
            self.assertTrue(errors)

    def test_missing_staged_source_fails(self):
        with tempfile.TemporaryDirectory() as d:
            target = Path(d) / "visual_pack_v1.json"
            name, sha = module.RECORDS["background"]
            target.write_text(json.dumps({
                "schema_version":"level-zero-visual-pack-v1", "status":"EXPERIMENTAL_CANDIDATE",
                "background":{"path":f"res://assets/experimental/level_zero/{name}",
                    "source_sha256":sha,"status":"CANDIDATE",
                    "verified_export_sha256":"0"*64,"dimensions_px":[1672,941]}
            }))
            _, errors = module.check_pack(target)
            self.assertIn("background: missing staged PNG", errors)

    def test_wrong_hash_rejected(self):
        with tempfile.TemporaryDirectory() as d:
            target = Path(d) / "visual_pack_v1.json"
            name, sha = module.RECORDS["background"]
            (Path(d) / name).write_bytes(module.PNG_SIGNATURE + struct.pack(">I",13) + b"IHDR" + struct.pack(">II",1672,941))
            target.write_text(json.dumps({
                "schema_version":"level-zero-visual-pack-v1", "status":"EXPERIMENTAL_CANDIDATE",
                "background":{"path":f"res://assets/experimental/level_zero/{name}",
                    "source_sha256":sha,"status":"CANDIDATE",
                    "verified_export_sha256":"0"*64,"dimensions_px":[1672,941]}
            }))
            _, errors = module.check_pack(target)
            self.assertIn("background: export hash mismatch",errors)


if __name__ == "__main__":
    unittest.main()
