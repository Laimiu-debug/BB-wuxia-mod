#!/usr/bin/env python3
r"""
Automated BBMOD install + live Battle Brothers smoke-test runner for mod_wuxia.
Uses the local G:\CODE\bbmod\app\core ModManager, game launcher, and gamelog parser.
"""

import html
import os
import re
import shutil
import subprocess
import sys
import time
import zipfile
from dataclasses import dataclass
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(line_buffering=True)
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(line_buffering=True)

BBMOD_APP = Path(r"G:\CODE\bbmod\app")
GAME_ROOT = Path(r"F:\SteamLibrary\steamapps\common\Battle Brothers")
WUXIA_ZIP = Path(__file__).resolve().parent.parent / "dist" / "mod_wuxia.zip"
TEST_PROFILE = "武侠开发测试"
TEST_ENABLED = {"mod_fox_008.zip", "mod_bbmod_zhcn.zip", "mod_wuxia.zip"}

USE_BBMOD_CORE = BBMOD_APP.exists()
if USE_BBMOD_CORE:
    sys.path.insert(0, str(BBMOD_APP))
    from core.modmanager import ModManager
    from core import game, gamelog
else:
    @dataclass
    class _FallbackLogRow:
        level: str
        time: str
        tag: str
        text: str

        def __str__(self) -> str:
            return f"[{self.time}] [{self.level.upper()}] [{self.tag}] {self.text}"

    _ROW_RE = re.compile(
        r'<div class="row ([^"]+)">\s*<div class="entry-container">\s*'
        r'<div class="time">([^<]*)</div>\s*<div class="tag">([^<]*)</div>\s*'
        r'<div class="text">(.*?)</div>\s*</div>\s*</div>',
        re.S,
    )

    class _FallbackGame:
        @staticmethod
        def is_game_running() -> bool:
            res = subprocess.run(
                ["tasklist", "/FI", "IMAGENAME eq BattleBrothers.exe"],
                capture_output=True, text=True, errors="replace",
            )
            return "BattleBrothers.exe" in res.stdout

        @staticmethod
        def kill_game() -> None:
            subprocess.run(
                ["taskkill", "/F", "/IM", "BattleBrothers.exe"],
                capture_output=True, text=True, errors="replace",
            )

        @staticmethod
        def find_log_write_path() -> Path | None:
            p = Path.home() / "Documents" / "Battle Brothers"
            return p if p.exists() else None

    class _FallbackGamelog:
        LogRow = _FallbackLogRow

        @staticmethod
        def load_log(path: Path) -> list[_FallbackLogRow]:
            raw = path.read_text(encoding="utf-8", errors="replace")
            out: list[_FallbackLogRow] = []
            for lvl, tm, tag, body in _ROW_RE.findall(raw):
                clean = html.unescape(re.sub(r"<[^>]+>", "", body)).strip()
                out.append(_FallbackLogRow(level=lvl.strip().lower(), time=tm.strip(), tag=tag.strip(), text=clean))
            return out

    game = _FallbackGame
    gamelog = _FallbackGamelog

SELFTEST_RESULT = re.compile(r"\[WX-SELFTEST\] =+ Result: (\d+) PASSED, (\d+) FAILED =+")
CORE_LOADED = "[mod_wuxia] Loaded"
MAIN_MENU_READY = "Screen 'MainMenuScreen' successfully registered."


def package_runs_selftest(package: Path) -> bool:
    with zipfile.ZipFile(package) as archive:
        preload = archive.read("scripts/!mods_preload/mod_wuxia.nut").decode("utf-8-sig")
    flags = dict(re.findall(r"^\s*(Debug|RunSelfTest)\s*=\s*(true|false)\b", preload, re.M))
    if len(flags) != 2:
        raise ValueError(f"Missing Wuxia build flags in {package}")
    return "true" in flags.values()


def startup_confirmed(rows, expect_selftest: bool) -> bool:
    return (any(CORE_LOADED in row.text for row in rows)
            and any(MAIN_MENU_READY in row.text for row in rows)
            and (not expect_selftest or any(SELFTEST_RESULT.search(row.text) for row in rows)))


def is_game_error(row) -> bool:
    message = row.text.upper()
    return row.level in ("error", "critical") or "EXCEPTION" in message or "COMPILE ERROR" in message


def install_and_switch() -> None:
    if game.is_game_running():
        game.kill_game()
        time.sleep(2)
    if USE_BBMOD_CORE:
        mgr = ModManager(GAME_ROOT)
        disabled_wuxia = mgr.disabled_dir / WUXIA_ZIP.name
        if disabled_wuxia.exists():
            mgr.enable(WUXIA_ZIP.name)
        mgr.install_many([WUXIA_ZIP], overwrite=True)
        mgr.apply_enabled(TEST_ENABLED, validate=True)
        mgr.save_profile(TEST_PROFILE)
        print(f"[BBMOD] Installed {WUXIA_ZIP.name} and switched to profile '{TEST_PROFILE}': {sorted(TEST_ENABLED)}")
    else:
        dst = GAME_ROOT / "data" / WUXIA_ZIP.name
        shutil.copy2(WUXIA_ZIP, dst)
        print(f"[STANDALONE] Copied {WUXIA_ZIP} -> {dst}")


def run_smoke_test(wait_seconds: int = 120, keep_open: bool = False) -> int:
    expect_selftest = package_runs_selftest(GAME_ROOT / "data" / WUXIA_ZIP.name)
    if game.is_game_running():
        print("[TEST] BattleBrothers.exe is already running; closing existing test instance first.")
        game.kill_game()
        time.sleep(2)

    log_dir = game.find_log_write_path()
    log_file = (log_dir / "log.html") if log_dir else None
    before_mtime = log_file.stat().st_mtime_ns if (log_file and log_file.exists()) else 0
    print(f"[TEST] Log path: {log_file}")

    exe_path = GAME_ROOT / "win32" / "BattleBrothers.exe"
    launch_env = {**os.environ, "SteamAppId": "365360", "SteamGameId": "365360"}
    print(f"[TEST] Launching {exe_path}...")
    subprocess.Popen(
        [str(exe_path)],
        cwd=str(exe_path.parent),
        env=launch_env,
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        close_fds=True,
    )

    # Wait until log.html updates and settles (up to wait_seconds), retrying launch if Steam was still syncing
    deadline = time.time() + wait_seconds
    last_launch = time.time()
    updated = False
    while time.time() < deadline:
        time.sleep(1.5)
        if not updated and (time.time() - last_launch) >= 15.0 and not game.is_game_running():
            print("[TEST] No game process yet; retrying the launch...")
            subprocess.Popen(
                [str(exe_path)],
                cwd=str(exe_path.parent),
                env=launch_env,
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                close_fds=True,
            )
            last_launch = time.time()
        if log_file is None:
            log_dir = game.find_log_write_path()
            log_file = (log_dir / "log.html") if log_dir else None
        if log_file and log_file.exists():
            cur_mtime = log_file.stat().st_mtime_ns
            if cur_mtime > before_mtime:
                updated = True
                rows = gamelog.load_log(log_file)
                if any(is_game_error(row) for row in rows):
                    break
                if startup_confirmed(rows, expect_selftest):
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
    if not startup_confirmed(rows, expect_selftest):
        print(f"[TEST] ERROR: Incomplete startup log (core, menu and self-test if enabled, expected={expect_selftest}).")
        return 2

    if results:
        passed, failed = map(int, results[-1].groups())
        if passed == 0 or failed:
            print(f"[TEST] ERROR: Wuxia self-test reported {passed} passed and {failed} failed.")
            return 1
    else:
        print("[TEST] Release mode verified: Wuxia core loaded + MainMenuScreen ready with 0 errors (SelfTest skipped for fast boot).")

    return 0


def main() -> int:
    install_and_switch()
    keep = "--keep-open" in sys.argv
    if "--install-only" in sys.argv:
        return 0
    return run_smoke_test(keep_open=keep)


if __name__ == "__main__":
    sys.exit(main())
