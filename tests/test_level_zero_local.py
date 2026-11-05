"""Regress the Windows checkout blocker and false-green local Godot checks."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("level_zero_local", ROOT / "scripts/level_zero.py")
LOCAL = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(LOCAL)


class LocalChecks(unittest.TestCase):
    def test_zero_exit_script_error_is_failure(self):
        with tempfile.TemporaryDirectory() as folder:
            result = LOCAL.run_check("fake-godot", [sys.executable, "-c", "print('SCRIPT ERROR: broken scene')"], Path(folder), os.environ.copy())
            self.assertEqual(result["exit_code"], 0)
            self.assertFalse(result["passed"])

    def test_nonzero_exit_is_failure(self):
        with tempfile.TemporaryDirectory() as folder:
            result = LOCAL.run_check("failed-process", [sys.executable, "-c", "raise SystemExit(3)"], Path(folder), os.environ.copy())
            self.assertEqual(result["exit_code"], 3)
            self.assertFalse(result["passed"])

    def test_timeout_retains_log(self):
        with tempfile.TemporaryDirectory() as folder:
            result = LOCAL.run_check("hung-process", [sys.executable, "-c", "import time; time.sleep(10)"], Path(folder), os.environ.copy(), timeout=1)
            self.assertTrue(result["timeout"])
            self.assertFalse(result["passed"])
            self.assertIn("timed out", Path(result["log"]).read_text())

    def test_windows_checkout_preserves_manifest_geometry_hashes(self):
        # Exercise real Git checkout with Windows' autocrlf=true, even on Linux.
        with tempfile.TemporaryDirectory() as folder:
            checkout = Path(folder)
            def git(*args):
                return subprocess.check_output(["git", *args], cwd=checkout, stderr=subprocess.STDOUT)
            git("init", "--quiet")
            git("config", "core.autocrlf", "true")
            (checkout / ".gitattributes").write_bytes((ROOT / ".gitattributes").read_bytes())
            expected = {}
            for slug in ("byte-baddie", "block-queen"):
                relative = Path("assets/art-candidates") / slug / "v2/frames.json"
                target = checkout / relative
                target.parent.mkdir(parents=True)
                # HEAD holds the unchanged, manifest-approved geometry bytes.
                target.write_bytes(subprocess.check_output(["git", "show", f"HEAD:{relative.as_posix()}"], cwd=ROOT))
                expected[relative] = json.loads((ROOT / relative.parent / "manifest.json").read_text())["frame_geometry_sha256"]
            git("add", ".")
            for relative, digest in expected.items():
                (checkout / relative).unlink()
                git("checkout-index", "--", relative.as_posix())
                self.assertEqual(hashlib.sha256((checkout / relative).read_bytes()).hexdigest(), digest)


if __name__ == "__main__":
    unittest.main()
