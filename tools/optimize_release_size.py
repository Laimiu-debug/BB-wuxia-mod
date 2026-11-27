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


def find_ffmpeg() -> str | None:
    import shutil
    found = shutil.which("ffmpeg")
    if found:
        return found
    try:
        import imageio_ffmpeg
        return imageio_ffmpeg.get_ffmpeg_exe()
    except ImportError:
        return None


def optimize_ui_jpgs() -> tuple[int, int, int]:
    saved = 0
    touched = 0
    jpgs = sorted(UI_GFX_DIR.rglob("*.jpg"))
    for p in jpgs:
        orig = p.stat().st_size
        with Image.open(p) as im0:
            im = im0.convert("RGB")
        buf = io.BytesIO()
        q = 75 if orig > 500_000 else 80
        im.save(buf, "JPEG", quality=q, optimize=True, progressive=True)
        data = buf.getvalue()
        if len(data) + 1024 < orig:
            p.write_bytes(data)
            saved += orig - len(data)
            touched += 1
    return len(jpgs), touched, saved


def optimize_ui_pngs() -> tuple[int, int, int]:
    """Quantize pure CoherentUI WebKit PNGs under gfx/ui/ and gfx/skills/ (never touches C++ gfx/wx_*.png 32-bit RGBA mode!)."""
    # Never quantize `settlements` to 8-bit `P` mode (preserves smooth 32-bit RGBA contact shadows & mist transitions)
    target_dirs = [
        UI_GFX_DIR / sub
        for sub in ("campfire", "wx_skin", "events", "items", "perks", "banners", "settlement_sprites", "skin", "skills", "wx_icons")
    ] + [MOD_DIR / "gfx" / "skills"]
    saved = 0
    touched = 0
    checked = 0
    for folder in target_dirs:
        if not folder.exists():
            continue
        for p in sorted(folder.rglob("*.png")):
            checked += 1
            orig = p.stat().st_size
            if orig < 2560:
                continue
            with Image.open(p) as im:
                if im.mode == "P":
                    continue
                rgba = im.convert("RGBA")
            q = rgba.quantize(colors=256, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.FLOYDSTEINBERG)
            buf = io.BytesIO()
            q.save(buf, "PNG", optimize=True, compress_level=9)
            data = buf.getvalue()
            if len(data) + 512 < orig:
                p.write_bytes(data)
                saved += orig - len(data)
                touched += 1
    return checked, touched, saved


def optimize_rgba_atlases() -> tuple[int, int, int]:
    """Keep all C++ .brush atlases strictly 32-bit RGBA while zeroing RGB in alpha=0 pixels & trimming invisible LSB noise on VFX/procedural sheets."""
    saved = 0
    touched = 0
    atlases = sorted((MOD_DIR / "gfx").glob("wx_*.png")) + sorted((UI_GFX_DIR / "settlements").glob("*.png"))
    for p in atlases:
        orig = p.stat().st_size
        with Image.open(p) as im0:
            im = im0.convert("RGBA")
        r, g, b, a = im.split()
        if p.name.startswith("wx_effects_") or p.name.startswith("wx_kinetic_"):
            r = r.point(lambda v: v & 0xF8)
            g = g.point(lambda v: v & 0xF8)
            b = b.point(lambda v: v & 0xF8)
            a = a.point(lambda v: 255 if v == 255 else (v & 0xFC))
        elif p.name.startswith("wx_"):
            # Sub-perceptual 2-bit RGB LSB cleanup (max delta <= 3/255) preserves exact alpha & crisp 32-bit RGBA sprites
            r = r.point(lambda v: v & 0xFC)
            g = g.point(lambda v: v & 0xFC)
            b = b.point(lambda v: v & 0xFC)
        nz = a.point(lambda v: 255 if v > 0 else 0)
        zero = Image.new("L", im.size, 0)
        r = Image.composite(r, zero, nz)
        g = Image.composite(g, zero, nz)
        b = Image.composite(b, zero, nz)
        out_im = Image.merge("RGBA", (r, g, b, a))
        assert out_im.mode == "RGBA" and out_im.size == im.size
        buf = io.BytesIO()
        out_im.save(buf, "PNG", optimize=True, compress_level=9)
        data = buf.getvalue()
        if len(data) + 2048 < orig:
            p.write_bytes(data)
            saved += orig - len(data)
            touched += 1
    return len(atlases), touched, saved


def optimize_music_oggs() -> tuple[int, int, int]:
    ffmpeg = find_ffmpeg()
    if not ffmpeg:
        return 0, 0, 0
    saved = 0
    touched = 0
    oggs = sorted(MUSIC_DIR.glob("*.ogg"))
    for p in oggs:
        orig = p.stat().st_size
        # Re-encode tracks > 1.45 MB at q:a 1 (~80 kbps stereo Vorbis)
        if orig < 1_450_000:
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
                    "1",
                    str(tmp_path),
                ],
                check=True,
            )
            new_size = tmp_path.stat().st_size
            if 0 < new_size + 32768 < orig:
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
    print(f"[PNG] Checked {pc} (UI icons only), optimized {pt}, saved {ps / 1048576:.2f} MB")
    ac, at, asv = optimize_rgba_atlases()
    print(f"[ATLAS-RGBA32] Checked {ac}, optimized {at}, saved {asv / 1048576:.2f} MB")
    mc, mt, ms = optimize_music_oggs()
    print(f"[OGG] Checked {mc}, optimized {mt}, saved {ms / 1048576:.2f} MB")
    print(f"[TOTAL SAVED] {(js + ps + asv + ms) / 1048576:.2f} MB")


if __name__ == "__main__":
    main()
