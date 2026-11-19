#!/usr/bin/env python3
r"""
Automated BBMOD install + live Battle Brothers smoke-test runner for mod_wuxia.
Uses the local G:\CODE\bbmod\app\core ModManager, game launcher, and gamelog parser.
"""

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


def run_smoke_test(wait_seconds: int = 20, keep_open: bool = False) -> int:
    if game.is_game_running():
        print("[TEST] BattleBrothers.exe is already running; closing existing test instance first.")
        game.kill_game()
        time.sleep(2)

    log_dir = game.find_log_write_path()
    log_file = (log_dir / "log.html") if log_dir else None
    before_mtime = log_file.stat().st_mtime_ns if (log_file and log_file.exists()) else 0
    print(f"[TEST] Log path: {log_file}")

    info = game.GameInfo(
        root=GAME_ROOT,
        exe=GAME_ROOT / "win32" / "BattleBrothers.exe",
        version="1.5.2.3",
        data_dir=GAME_ROOT / "data",
    )
    print("[TEST] Launching BattleBrothers.exe...")
    game.launch_game(info, via_steam=False)

    # Wait until log.html updates and settles (up to wait_seconds)
    deadline = time.time() + wait_seconds
    updated = False
    while time.time() < deadline:
        time.sleep(1.5)
        if log_file is None:
            log_dir = game.find_log_write_path()
            log_file = (log_dir / "log.html") if log_dir else None
        if log_file and log_file.exists():
            cur_mtime = log_file.stat().st_mtime_ns
            if cur_mtime > before_mtime:
                updated = True
                # Check if main menu / preload finished
                rows = gamelog.load_log(log_file)
                if any("MainMenuState" in r.text or "mod_wuxia" in r.text or r.level in ("error", "critical") for r in rows):
                    time.sleep(4)
                    break

    if not keep_open:
        game.kill_game()
        time.sleep(1)

    if not log_file or not log_file.exists():
        print("[TEST] ERROR: Could not locate log.html!")
        return 2

    rows = gamelog.load_log(log_file)
    print(f"[TEST] Parsed {len(rows)} rows from {log_file} (updated={updated})")

    errors = [r for r in rows if r.level in ("error", "critical") or "EXCEPTION" in r.text.upper() or "COMPILE ERROR" in r.text.upper()]
    wuxia_rows = [r for r in rows if "wuxia" in r.text.lower() or "modern hooks" in r.text.lower() or "running queue" in r.text.lower()]

    print("=== WUXIA / HOOKS LOG ROWS ===")
    for r in wuxia_rows:
        print(" ", r)

    print(f"=== ERRORS / CRITICALS ({len(errors)}) ===")
    for r in errors[:40]:
        print(" ", r)

    return 1 if errors else 0


def main() -> int:
    install_and_switch()
    keep = "--keep-open" in sys.argv
    if "--install-only" in sys.argv:
        return 0
    return run_smoke_test(wait_seconds=25, keep_open=keep)


if __name__ == "__main__":
    sys.exit(main())
