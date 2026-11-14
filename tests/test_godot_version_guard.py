"""Regression tests for the Godot validation executable preflight.

Uses mock version commands; no Godot binary, network or game runtime is required.
"""
from pathlib import Path
import os
import subprocess
import shutil
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
VALIDATOR = ROOT / "scripts" / "validate.sh"
PREFLIGHT_END = '\ncd "$(dirname "$0")/.."'

class GodotVersionGuardTests(unittest.TestCase):
    def run_preflight(self, godot_version, godot4_version, override=None):
        source = VALIDATOR.read_text(encoding="utf-8")
        self.assertIn(PREFLIGHT_END, source)
        preflight = source.split(PREFLIGHT_END, 1)[0]
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name, version in (("godot", godot_version), ("godot4", godot4_version)):
                if version is None:
                    continue
                executable = root / name
                executable.write_text("#!/bin/sh\nprintf '%s\\n' '" + version + "'\n", encoding="utf-8", newline="\n")
                executable.chmod(0o755)
            environment = os.environ.copy()
            environment["PATH"] = str(root)
            environment.pop("GODOT_BIN", None)
            if override is not None:
                environment["GODOT_BIN"] = (root / override).as_posix()
            return subprocess.run(
                [shutil.which("bash") or "/bin/bash", "-c", preflight + '\nprintf "SELECTED=%s\\n" "$GODOT_BIN"\n'],
                env=environment, capture_output=True, text=True, check=False,
            )

    def test_chooses_godot4_when_godot_is_outdated(self):
        result = self.run_preflight("4.6.3.stable.official", "4.7.2.stable.official")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("/godot4", result.stdout)

    def test_prefers_compatible_godot(self):
        result = self.run_preflight("4.7.2.stable.official", "4.6.3.stable.official")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("/godot\n", result.stdout)

    def test_respects_compatible_explicit_override(self):
        result = self.run_preflight("4.6.3.stable.official", "4.7.2.stable.official", "godot4")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("/godot4", result.stdout)

    def test_rejects_outdated_explicit_override(self):
        result = self.run_preflight("4.6.3.stable.official", "4.7.2.stable.official", "godot")
        self.assertEqual(result.returncode, 2)
        self.assertIn("4.7.2 stable required", result.stderr)

    def test_rejects_pre_release(self):
        result = self.run_preflight("4.7.2.dev", "4.6.3.stable.official")
        self.assertEqual(result.returncode, 2)

    def test_rejects_missing_executables(self):
        result = self.run_preflight(None, None)
        self.assertEqual(result.returncode, 2)

if __name__ == "__main__":
    unittest.main()
