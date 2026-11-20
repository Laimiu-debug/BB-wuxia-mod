#!/usr/bin/env python3
r"""
Automated BBMOD install + live Battle Brothers smoke-test runner for mod_wuxia.
Uses the local G:\CODE\bbmod\app\core ModManager, game launcher, and gamelog parser.
"""

import re
import subprocess
import sys
import time
from pathlib import Path

BBMOD_APP = Path(r"G:\CODE\bbmod\app")
GAME_ROOT = Path(r"F:\SteamLibrary\steamapps\common\Battle Brothers")
WUXIA_ZIP = Path(__file__).resolve().parent.parent / "dist" / "mod_wuxia.zip"
TEST_PROFILE = "武侠开发测试"
TEST_ENABLED = {"mod_fox_008.zip", "mod_bbmod_zhcn.zip", "mod_wuxia.zip"}

sys.path.insert(0, str(BBMOD_APP))
from core.modmanager import ModManager
from core import game, gamelog

SELFTEST_RESULT = re.compile(r"\[WX-SELFTEST\] =+ Result: (\d+) PASSED, (\d+) FAILED =+")
MAIN_MENU_READY = "Screen 'MainMenuScreen' successfully registered."


def is_game_error(row: gamelog.LogRow) -> bool:
    message = row.text.upper()
    return row.level in ("error", "critical") or "EXCEPTION" in message or "COMPILE ERROR" in message


def install_and_switch() -> None:
    mgr = ModManager(GAME_ROOT)
    # Remove disabled copy if previously disabled so install_many overwrites cleanly
    disabled_wuxia = mgr.disabled_dir / WUXIA_ZIP.name
    if disabled_wuxia.exists():
        mgr.enable(WUXIA_ZIP.name)

    mgr.install_many([WUXIA_ZIP], overwrite=True)
    mgr.apply_enabled(TEST_ENABLED, validate=True)
    mgr.save_profile(TEST_PROFILE)
    print(f"[BBMOD] Installed {WUXIA_ZIP.name} and switched to profile '{TEST_PROFILE}': {sorted(TEST_ENABLED)}")


def run_smoke_test(wait_seconds: int = 120, keep_open: bool = False) -> int:
    if game.is_game_running():
        print("[TEST] BattleBrothers.exe is already running; closing existing test instance first.")
        game.kill_game()
        time.sleep(2)

    log_dir = game.find_log_write_path()
    log_file = (log_dir / "log.html") if log_dir else None
    before_mtime = log_file.stat().st_mtime_ns if (log_file and log_file.exists()) else 0
    print(f"[TEST] Log path: {log_file}")

    exe_path = GAME_ROOT / "win32" / "BattleBrothers.exe"
    print(f"[TEST] Launching {exe_path}...")
    subprocess.Popen([str(exe_path)], cwd=str(exe_path.parent))

    # Wait until log.html updates and settles (up to wait_seconds), retrying launch if Steam was still syncing
    deadline = time.time() + wait_seconds
    last_launch = time.time()
    updated = False
    while time.time() < deadline:
        time.sleep(1.5)
        if not updated and (time.time() - last_launch) >= 15.0 and not game.is_game_running():
            print("[TEST] No game process yet; retrying the launch...")
            subprocess.Popen([str(exe_path)], cwd=str(exe_path.parent))
            last_launch = time.time()
        if log_file is None:
            log_dir = game.find_log_write_path()
            log_file = (log_dir / "log.html") if log_dir else None
        if log_file and log_file.exists():
            cur_mtime = log_file.stat().st_mtime_ns
            if cur_mtime > before_mtime:
                updated = True
                rows = gamelog.load_log(log_file)
                menu_ready = any(MAIN_MENU_READY in row.text for row in rows)
                test_finished = any(SELFTEST_RESULT.search(row.text) for row in rows)
                if any(is_game_error(row) for row in rows):
                    break
                if menu_ready and test_finished:
                    time.sleep(2)
                    break

    if not keep_open:
        game.kill_game()
        time.sleep(1)

    if not updated or not log_file or not log_file.exists():
        print("[TEST] ERROR: The game did not write a fresh log.html before the deadline.")
        return 2

    rows = gamelog.load_log(log_file)
    print(f"[TEST] Parsed {len(rows)} rows from {log_file} (updated={updated})")

    errors = [r for r in rows if is_game_error(r)]
    wuxia_rows = [r for r in rows if "wuxia" in r.text.lower() or "wx-selftest" in r.text.lower() or "modern hooks" in r.text.lower() or "running queue" in r.text.lower()]

    print("=== WUXIA / HOOKS LOG ROWS ===")
    for r in wuxia_rows:
        print(" ", r)

    print(f"=== ERRORS / CRITICALS ({len(errors)}) ===")
    for r in errors[:40]:
        print(" ", r)

    if errors:
        return 1

    results = [match for row in rows if (match := SELFTEST_RESULT.search(row.text))]
    if not results or not any(MAIN_MENU_READY in row.text for row in rows):
        print("[TEST] ERROR: The log does not confirm both the Wuxia self-test and main menu initialization.")
        return 2

    passed, failed = map(int, results[-1].groups())
    if passed == 0 or failed:
        print(f"[TEST] ERROR: Wuxia self-test reported {passed} passed and {failed} failed.")
        return 1

    return 0


def main() -> int:
    install_and_switch()
    keep = "--keep-open" in sys.argv
    if "--install-only" in sys.argv:
        return 0
    return run_smoke_test(keep_open=keep)


if __name__ == "__main__":
    sys.exit(main())
