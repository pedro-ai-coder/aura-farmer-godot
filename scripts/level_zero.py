#!/usr/bin/env python3
"""Focused native Level Zero launch/check loop (Python 3.10+, Windows/Linux)."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
ERRORS = re.compile(r"SCRIPT ERROR:|Parse Error:|(?:^|\s)ERROR:|Failed to load|Failed to open", re.I)
TESTS = (
    "level_zero", "level_zero_input", "phaser_rng", "game_rules", "run_clock", "solo_offer_rules",
    "hero_combat", "signature_flex", "boss_lifecycle", "profile_store",
    "female_roster", "menu_flow", "mobile_layout", "run_progression",
    "player_projectiles", "passive_effects", "clean_cut_pointer_input", "clean_cut_secondary_input",
)


def run_check(name: str, command: list[str], folder: Path, env: dict, timeout: int = 60) -> dict:
    """Keep evidence and reject Godot's zero-exit script/resource failures."""
    started = time.monotonic()
    log = folder / f"{name}.log"
    code, timed_out = None, False
    with log.open("w", encoding="utf-8") as output:
        try:
            result = subprocess.run(command, cwd=ROOT, env=env, stdout=output,
                                    stderr=subprocess.STDOUT, timeout=timeout, check=False)
            code = result.returncode
        except subprocess.TimeoutExpired:
            timed_out = True
            output.write(f"\nERROR: timed out after {timeout}s\n")
        except OSError as error:
            output.write(f"\nERROR: {error}\n")
    text = log.read_text(encoding="utf-8", errors="replace")
    ok = code == 0 and not timed_out and not ERRORS.search(text)
    print(f"{'PASS' if ok else 'FAIL'}: {name} ({time.monotonic()-started:.1f}s) - {log}", flush=True)
    return {"name": name, "command": command, "exit_code": code, "timeout": timed_out,
            "passed": bool(ok), "log": str(log), "seconds": round(time.monotonic()-started, 3)}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("check", "play"))
    parser.add_argument("--godot", default=os.environ.get("GODOT_BIN"), help="Godot 4.7.2 executable (or GODOT_BIN)")
    args = parser.parse_args()
    godot = args.godot or shutil.which("godot") or shutil.which("godot4")
    if not godot:
        parser.error("Set GODOT_BIN or --godot to the official Godot 4.7.2 executable.")
    godot = str(Path(shutil.which(godot) or godot).resolve())
    # The Windows console wrapper launches another process. Run the actual engine
    # directly so timeouts kill the engine and its stdout remains captured.
    if godot.endswith("_console.exe") and Path(godot.replace("_console.exe", ".exe")).is_file():
        godot = godot.replace("_console.exe", ".exe")
    try:
        version = subprocess.check_output([godot, "--version"], text=True, timeout=15).strip()
    except (OSError, subprocess.SubprocessError) as error:
        parser.error(f"Cannot execute Godot: {error}")
    if not version.startswith("4.7.2.stable."):
        parser.error(f"Expected Godot 4.7.2 stable; found {version}")
    if sys.platform not in ("win32", "linux"):
        parser.error("This helper isolates user data on Windows/Linux only; see the native scene instructions.")
    if args.action == "check" and not shutil.which("node"):
        parser.error("Node.js 18+ is required for the existing Web platform contract test.")

    folder = ROOT / "reports" / "level-zero" / datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    folder.mkdir(parents=True)
    env = os.environ.copy()
    data_key = "APPDATA" if sys.platform == "win32" else "XDG_DATA_HOME"
    env[data_key] = str(folder / "user-data")
    Path(env[data_key]).mkdir()
    report = {
        "started_utc": datetime.now(timezone.utc).isoformat(), "action": args.action,
        "platform": platform.platform(), "python": sys.version, "godot": version,
        "engine_sha256": hashlib.sha256(Path(godot).read_bytes()).hexdigest(),
        "head": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
        "working_tree": subprocess.check_output(["git", "status", "--short"], cwd=ROOT, text=True),
        "cwd": str(ROOT), "isolated_environment": {data_key: env[data_key]},
        "seeds": {"sigma": 451, "cool-kid": 468, "alpha": 485}, "checks": [],
        "scope": "Native automated checks; not browser, device or full-playthrough acceptance.",
    }

    def check(name: str, command: list[str], timeout: int = 60) -> bool:
        result = run_check(name, command, folder, env, timeout)
        report["checks"].append(result)
        (folder / "summary.json").write_text(json.dumps(report, indent=2)+"\n", encoding="utf-8")
        return result["passed"]

    print(f"Godot {version}\nEvidence: {folder}\nIsolated user data: {env[data_key]}", flush=True)
    for name, script in (("approved-assets", "sync_approved_assets.py"),
                         ("female-assets", "verify_female_variants.py")):
        if not check(name, [sys.executable, str(ROOT / "scripts" / script)]):
            return 1
    engine = [godot, "--headless", "--path", str(ROOT)]
    if not check("import", engine + ["--import"], 300):
        return 1
    if args.action == "play":
        command = [godot, "--path", str(ROOT), "--scene", "res://scenes/level_zero.tscn",
                   "--log-file", str(folder / "play.log")]
        report["launch_command"] = command
        (folder / "summary.json").write_text(json.dumps(report, indent=2)+"\n", encoding="utf-8")
        print("Opening Level Zero. Close the game window to return to the terminal.", flush=True)
        return subprocess.call(command, cwd=ROOT, env=env)
    for test in TESTS:
        check(test, engine + ["--script", f"res://tests/test_{test}.gd"])
    for scene in ("main", "level_zero"):
        check(f"startup-{scene}", engine + ["--scene", f"res://scenes/{scene}.tscn", "--quit-after", "10"])
    check("web-platform", [shutil.which("node"), "tests/test_web_platform.cjs"])
    check("local-tools", [sys.executable, "-m", "unittest", "discover", "-s", "tests", "-p", "test_level_zero_local.py"])
    passed = all(item["passed"] for item in report["checks"])
    print(f"{'PASS' if passed else 'FAIL'}: focused Level Zero checks. See {folder / 'summary.json'}")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
