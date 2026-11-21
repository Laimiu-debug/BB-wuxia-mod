#!/usr/bin/env python3
"""
BB Wuxia Mod - Static Validator & Packager
1. Checks every .js file under mod_wuxia/ui/ for ES3 compatibility (no let/const/=>/template literals/class).
2. Checks every .nut file under mod_wuxia/ for balanced delimiters and basic Squirrel 3.0 hygiene.
3. Packages mod_wuxia/ into dist/mod_wuxia.zip ready to drop into Battle Brothers' data/ folder.
"""

import os
import re
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MOD_DIR = ROOT / "mod_wuxia"
VENDOR_DIR = ROOT / "vendor"
DIST_DIR = ROOT / "dist"
OUT_ZIP = DIST_DIR / "mod_wuxia.zip"
BUNDLE_ZIP = DIST_DIR / "BB_Wuxia_AllInOne_data.zip"


def strip_comments_and_strings(src: str) -> str:
    """Remove //, /* */, and quoted strings so delimiter & keyword checks avoid false positives."""
    out = []
    i = 0
    n = len(src)
    while i < n:
        ch = src[i]
        nxt = src[i + 1] if i + 1 < n else ""
        if ch == "/" and nxt == "/":
            while i < n and src[i] != "\n":
                i += 1
        elif ch == "/" and nxt == "*":
            i += 2
            while i + 1 < n and not (src[i] == "*" and src[i + 1] == "/"):
                if src[i] == "\n":
                    out.append("\n")
                i += 1
            i += 2
        elif ch in ("'", '"'):
            quote = ch
            out.append(" ")
            i += 1
            while i < n:
                if src[i] == "\\":
                    i += 2
                    continue
                if src[i] == quote:
                    i += 1
                    break
                if src[i] == "\n":
                    out.append("\n")
                i += 1
        else:
            out.append(ch)
            i += 1
    return "".join(out)


def check_balanced(path: Path, src: str) -> list[str]:
    clean = strip_comments_and_strings(src)
    pairs = {"(": ")", "[": "]", "{": "}"}
    closing = {")": "(", "]": "[", "}": "{"}
    stack = []
    errors = []
    line = 1
    for ch in clean:
        if ch == "\n":
            line += 1
        elif ch in pairs:
            stack.append((ch, line))
        elif ch in closing:
            if not stack or stack[-1][0] != closing[ch]:
                errors.append(f"{path.relative_to(ROOT)}:{line}: unmatched '{ch}'")
            else:
                stack.pop()
    for ch, open_line in stack:
        errors.append(f"{path.relative_to(ROOT)}:{open_line}: unclosed '{ch}'")
    return errors


def check_es3(path: Path, src: str) -> list[str]:
    clean = strip_comments_and_strings(src)
    errors = check_balanced(path, src)
    forbidden = [
        (r"\blet\b", "ES6 'let' keyword"),
        (r"\bconst\b", "ES6 'const' keyword"),
        (r"=>", "ES6 arrow function '=>'"),
        (r"`", "ES6 template literal '`'"),
        (r"\bclass\b", "ES6 'class' keyword"),
    ]
    for lineno, line in enumerate(clean.splitlines(), start=1):
        for pat, desc in forbidden:
            if re.search(pat, line):
                errors.append(f"{path.relative_to(ROOT)}:{lineno}: forbidden {desc}")
    return errors


def validate_all() -> tuple[int, int, list[str]]:
    nut_count = 0
    js_count = 0
    errors: list[str] = []

    for p in sorted(MOD_DIR.rglob("*")):
        if not p.is_file():
            continue
        if p.suffix == ".nut":
            nut_count += 1
            errors.extend(check_balanced(p, p.read_text(encoding="utf-8")))
        elif p.suffix == ".js":
            js_count += 1
            errors.extend(check_es3(p, p.read_text(encoding="utf-8")))
        elif p.suffix == ".css":
            errors.extend(check_balanced(p, p.read_text(encoding="utf-8")))

    return nut_count, js_count, errors


def build_zip(release: bool = False) -> int:
    DIST_DIR.mkdir(parents=True, exist_ok=True)
    file_count = 0
    target_val = "false" if release else "true"
    with zipfile.ZipFile(OUT_ZIP, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for p in sorted(MOD_DIR.rglob("*")):
            if p.is_file():
                rel_posix = p.relative_to(MOD_DIR).as_posix()
                # Place internal mod_wuxia/ Squirrel modules under scripts/mod_wuxia/ inside the ZIP
                # so top-level ZIP roots strictly match BBMOD's allowed ROOTS (scripts, ui, gfx, music, brushes).
                arcname = f"scripts/{rel_posix}" if rel_posix.startswith("mod_wuxia/") else rel_posix

                if rel_posix == "scripts/!mods_preload/mod_wuxia.nut":
                    src = p.read_text(encoding="utf-8")
                    patched = re.sub(r"\bDebug\s*=\s*(true|false)\b", f"Debug = {target_val}", src, count=1)
                    patched = re.sub(r"\bRunSelfTest\s*=\s*(true|false)\b", f"RunSelfTest = {target_val}", patched, count=1)
                    patched = patched.replace('::include("mod_wuxia/', '::include("scripts/mod_wuxia/')
                    zf.writestr(arcname, patched.encode("utf-8"))
                elif rel_posix == "mod_wuxia/load.nut":
                    src = p.read_text(encoding="utf-8")
                    patched = src.replace('::include("mod_wuxia/', '::include("scripts/mod_wuxia/')
                    zf.writestr(arcname, patched.encode("utf-8"))
                else:
                    zf.write(p, arcname)
                file_count += 1
    return file_count


def build_bundle() -> list[str]:
    vendor_zips = sorted(VENDOR_DIR.glob("*.zip")) if VENDOR_DIR.exists() else []
    included = []
    with zipfile.ZipFile(BUNDLE_ZIP, "w", compression=zipfile.ZIP_STORED) as zf:
        zf.write(OUT_ZIP, OUT_ZIP.name)
        included.append(OUT_ZIP.name)
        for vz in vendor_zips:
            zf.write(vz, vz.name)
            included.append(vz.name)
    return included


def main() -> int:
    if not MOD_DIR.exists():
        print(f"ERROR: {MOD_DIR} not found.")
        return 1

    nut_count, js_count, errors = validate_all()
    if errors:
        print("VALIDATION FAILED:")
        for e in errors:
            print("  -", e)
        return 1

    is_release = "--release" in sys.argv
    count = build_zip(release=is_release)
    mode_tag = "RELEASE (Debug=false)" if is_release else "DEV (Debug=true)"
    print(f"VALIDATION OK: {nut_count} .nut files, {js_count} ES3 .js files checked.")
    print(f"PACKAGED OK [{mode_tag}]: {OUT_ZIP} ({count} files)")

    if "--bundle" in sys.argv:
        included = build_bundle()
        print(f"BUNDLE OK: {BUNDLE_ZIP} -> {included}")
        if len(included) == 1:
            print("NOTE: vendor/ has no .zip files yet. Drop mod_modern_hooks*.zip & mod_msu*.zip into vendor/ for full All-In-One bundle.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
