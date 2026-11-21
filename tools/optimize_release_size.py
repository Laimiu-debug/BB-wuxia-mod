#!/usr/bin/env python3
"""
Optimize WebKit UI assets (gfx/ui/*) and OST Ogg Vorbis bitrate (music/*.ogg)
so dist/mod_wuxia.zip fits comfortably under BBMOD's 100 MB (104,857,600 bytes)
desktop/web limit while keeping all 11 C++ .brush atlases (gfx/wx_*.png) untouched
32-bit RGBA and preserving all 18 instrumental OST tracks + Ming serif font.
"""

import io
import subprocess
import tempfile
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
MOD_DIR = ROOT / "mod_wuxia"
UI_GFX_DIR = MOD_DIR / "gfx" / "ui"
MUSIC_DIR = MOD_DIR / "music"


def find_ffmpeg() -> str:
    import shutil
    found = shutil.which("ffmpeg")
    if found:
        return found
    import imageio_ffmpeg
    return imageio_ffmpeg.get_ffmpeg_exe()


def optimize_ui_jpgs() -> tuple[int, int, int]:
    saved = 0
    touched = 0
    jpgs = sorted(UI_GFX_DIR.rglob("*.jpg"))
    for p in jpgs:
        orig = p.stat().st_size
        im = Image.open(p).convert("RGB")
        buf = io.BytesIO()
        im.save(buf, "JPEG", quality=82, optimize=True, progressive=True)
        data = buf.getvalue()
        if len(data) + 1024 < orig:
            p.write_bytes(data)
            saved += orig - len(data)
            touched += 1
    return len(jpgs), touched, saved


def optimize_ui_pngs() -> tuple[int, int, int]:
    """Quantize pure CoherentUI WebKit PNGs under gfx/ui/ (never touches C++ gfx/wx_*.png atlases!)."""
    target_subdirs = ("settlements", "campfire", "wx_skin", "events", "items", "banners", "settlement_sprites", "skin")
    saved = 0
    touched = 0
    checked = 0
    for sub in target_subdirs:
        folder = UI_GFX_DIR / sub
        if not folder.exists():
            continue
        for p in sorted(folder.rglob("*.png")):
            checked += 1
            orig = p.stat().st_size
            if orig < 8192:
                continue
            im = Image.open(p)
            if im.mode == "P":
                continue
            rgba = im.convert("RGBA")
            q = rgba.quantize(colors=256, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.FLOYDSTEINBERG)
            buf = io.BytesIO()
            q.save(buf, "PNG", optimize=True, compress_level=9)
            data = buf.getvalue()
            if len(data) + 1024 < orig:
                p.write_bytes(data)
                saved += orig - len(data)
                touched += 1
    return checked, touched, saved


def optimize_music_oggs() -> tuple[int, int, int]:
    ffmpeg = find_ffmpeg()
    saved = 0
    touched = 0
    oggs = sorted(MUSIC_DIR.glob("*.ogg"))
    for p in oggs:
        orig = p.stat().st_size
        # Skip short stings or already-compact tracks (< 2.0 MB)
        if orig < 2_000_000:
            continue
        with tempfile.NamedTemporaryFile(suffix=".ogg", delete=False) as tf:
            tmp_path = Path(tf.name)
        try:
            subprocess.run(
                [
                    ffmpeg,
                    "-y",
                    "-v",
                    "error",
                    "-i",
                    str(p),
                    "-ar",
                    "44100",
                    "-ac",
                    "2",
                    "-c:a",
                    "libvorbis",
                    "-q:a",
                    "2",
                    str(tmp_path),
                ],
                check=True,
            )
            new_size = tmp_path.stat().st_size
            if 0 < new_size < orig:
                p.write_bytes(tmp_path.read_bytes())
                saved += orig - new_size
                touched += 1
        finally:
            tmp_path.unlink(missing_ok=True)
    return len(oggs), touched, saved


def main() -> None:
    jc, jt, js = optimize_ui_jpgs()
    print(f"[JPG] Checked {jc}, optimized {jt}, saved {js / 1048576:.2f} MB")
    pc, pt, ps = optimize_ui_pngs()
    print(f"[PNG] Checked {pc} (gfx/ui only), optimized {pt}, saved {ps / 1048576:.2f} MB")
    mc, mt, ms = optimize_music_oggs()
    print(f"[OGG] Checked {mc}, optimized {mt}, saved {ms / 1048576:.2f} MB")
    print(f"[TOTAL SAVED] {(js + ps + ms) / 1048576:.2f} MB")


if __name__ == "__main__":
    main()
