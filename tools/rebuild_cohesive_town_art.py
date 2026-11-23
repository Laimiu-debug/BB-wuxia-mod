#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Stage 2 Cohesive Wuxia Town Interior Layered Art Pipeline:
Rebuilds all 173 Town Interior UI assets under `mod_wuxia/gfx/ui/settlements/`
from a unified Song/Ming Qingming-scroll sumi-ink & muted painterly style sheet set,
keeping full 32-bit smooth-alpha RGBA (zero 8-bit FASTOCTREE grey shadow banding),
true translucent multiply ground-contact shadows, centered hilltop landmarks,
natural tree/gable terminations on flanking houses, and hand-painted Chinese
stepped bluestone & sandstone foreground plazas (`wx_ui_ramp_*`).
"""

from collections import deque
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parent.parent
MOD_SET_DIR = ROOT / "mod_wuxia" / "gfx" / "ui" / "settlements"
MOD_SPR_DIR = ROOT / "mod_wuxia" / "gfx" / "ui" / "settlement_sprites"

BRAIN_DIR = Path(r"C:\Users\25647\.gemini\antigravity\brain\fd61ce99-c4e8-4c78-8aa2-69c7230b31e4")
SCRATCH_DIR = BRAIN_DIR / "scratch"

RAW_RAMP_STONE = BRAIN_DIR / "ramp_stone_raw_1795303724624.jpg"
RAW_RAMP_SAND  = BRAIN_DIR / "ramp_sand_raw_1795303767395.jpg"
RAW_HOUSES     = BRAIN_DIR / "houses_4x2_raw_1795303755183.jpg"
RAW_CENTERS    = BRAIN_DIR / "centers_3x3_raw_notext_1795303791240.jpg"
RAW_BUILDINGS  = BRAIN_DIR / "buildings_4x4_raw_1795303737353.jpg"


def is_bg_white(r: int, g: int, b: int, lum_thresh: float = 237.0, sat_thresh: int = 20) -> bool:
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    sat = max(r, g, b) - min(r, g, b)
    return lum >= lum_thresh and sat <= sat_thresh


def extract_sprite_from_white_cell(
    cell_rgb: Image.Image,
    clear_interior_pure_white: bool = True,
    keep_largest_only: bool = False,
) -> Image.Image:
    """
    Flood-fills pure/near-white background from cell borders, optionally clears pure neutral
    paper-white sky holes (e.g. between awning posts, arena poles, fence pickets), removes
    disconnected text/dust specks, decontaminates white edge fringes, and softens 1px contour alpha.
    """
    rgb = cell_rgb.convert("RGB")
    w, h = rgb.size
    px = rgb.load()

    bg = bytearray(w * h)
    q = deque()

    for x in range(w):
        for y in (0, h - 1):
            r, g, b = px[x, y]
            if is_bg_white(r, g, b, 234.0, 24):
                idx = y * w + x
                if not bg[idx]:
                    bg[idx] = 1
                    q.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            r, g, b = px[x, y]
            if is_bg_white(r, g, b, 234.0, 24):
                idx = y * w + x
                if not bg[idx]:
                    bg[idx] = 1
                    q.append((x, y))

    while q:
        cx, cy = q.popleft()
        for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
            if 0 <= nx < w and 0 <= ny < h:
                nidx = ny * w + nx
                if not bg[nidx]:
                    r, g, b = px[nx, ny]
                    if is_bg_white(r, g, b, 235.0, 22):
                        bg[nidx] = 1
                        q.append((nx, ny))

    if clear_interior_pure_white:
        # Clear enclosed pure paper-white sky gaps (`RGB >= 246`, `sat <= 7`) without touching warm plaster walls!
        seed_sky = []
        for y in range(1, h - 1):
            for x in range(1, w - 1):
                idx = y * w + x
                if bg[idx]:
                    continue
                r, g, b = px[x, y]
                if min(r, g, b) >= 247 and (max(r, g, b) - min(r, g, b)) <= 7:
                    bg[idx] = 1
                    seed_sky.append((x, y))
        sq = deque(seed_sky)
        while sq:
            cx, cy = sq.popleft()
            for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
                if 0 <= nx < w and 0 <= ny < h:
                    nidx = ny * w + nx
                    if not bg[nidx]:
                        r, g, b = px[nx, ny]
                        if min(r, g, b) >= 243 and (max(r, g, b) - min(r, g, b)) <= 10:
                            bg[nidx] = 1
                            sq.append((nx, ny))

    # Build initial foreground mask and filter connected components (removes text labels & stray specks!)
    vis = bytearray(w * h)
    comps = []
    for y in range(h):
        for x in range(w):
            idx = y * w + x
            if not bg[idx] and not vis[idx]:
                vis[idx] = 1
                cq = deque([(x, y)])
                pts = [(x, y)]
                while cq:
                    qx, qy = cq.popleft()
                    for nx, ny in (
                        (qx - 1, qy), (qx + 1, qy), (qx, qy - 1), (qx, qy + 1),
                        (qx - 1, qy - 1), (qx + 1, qy - 1), (qx - 1, qy + 1), (qx + 1, qy + 1),
                    ):
                        if 0 <= nx < w and 0 <= ny < h:
                            nidx = ny * w + nx
                            if not bg[nidx] and not vis[nidx]:
                                vis[nidx] = 1
                                cq.append((nx, ny))
                                pts.append((nx, ny))
                comps.append(pts)

    if comps:
        max_len = max(len(c) for c in comps)
        for pts in comps:
            if keep_largest_only:
                if len(pts) < int(max_len * 0.15):
                    for px_x, px_y in pts:
                        bg[px_y * w + px_x] = 1
            else:
                if len(pts) < max(45, int(max_len * 0.004)):
                    for px_x, px_y in pts:
                        bg[px_y * w + px_x] = 1

    # Build smooth anti-aliased alpha & decontaminate white boundary pixels
    alpha = Image.new("L", (w, h), 0)
    apx = alpha.load()
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    opx = out.load()

    for y in range(h):
        for x in range(w):
            if not bg[y * w + x]:
                apx[x, y] = 255

    # Erode 1px of bright white halo along outer silhouette & feather smoothly
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            if apx[x, y] == 0:
                continue
            touches_bg = (
                bg[(y - 1) * w + x] or bg[(y + 1) * w + x]
                or bg[y * w + (x - 1)] or bg[y * w + (x + 1)]
            )
            r, g, b = px[x, y]
            if touches_bg:
                lum = 0.299 * r + 0.587 * g + 0.114 * b
                if lum > 215:
                    apx[x, y] = 0
                    continue
                elif lum > 175:
                    apx[x, y] = 155
                else:
                    apx[x, y] = 225
                # Pull edge color slightly darker toward ink contour to prevent pale fringe
                r = int(r * 0.72)
                g = int(g * 0.71)
                b = int(b * 0.69)
            opx[x, y] = (r, g, b, apx[x, y])

    # Fill interior non-border pixels cleanly
    for y in range(h):
        for x in range(w):
            a_val = apx[x, y]
            if a_val > 0 and opx[x, y][3] == 0:
                r, g, b = px[x, y]
                opx[x, y] = (r, g, b, a_val)

    return out


def tight_crop_rgba(rgba: Image.Image, alpha_min: int = 16) -> Image.Image:
    bbox = rgba.getchannel("A").point(lambda a: 255 if a >= alpha_min else 0).getbbox()
    return rgba.crop(bbox) if bbox else rgba


def grade_wuxia_parchment(rgba: Image.Image, haze_mix: float = 0.0, haze_rgb=(176, 172, 160)) -> Image.Image:
    """Unifies saturation, warm Battle Brothers sepia-slate balance, and optional depth haze."""
    a = rgba.getchannel("A")
    rgb = rgba.convert("RGB")
    rgb = ImageEnhance.Color(rgb).enhance(0.90)
    rgb = ImageEnhance.Contrast(rgb).enhance(1.04)
    warm = Image.new("RGB", rgba.size, (198, 182, 154))
    rgb = Image.blend(rgb, ImageChops.multiply(rgb, warm), 0.10)
    if haze_mix > 0.0:
        hz = Image.new("RGB", rgba.size, haze_rgb)
        rgb = Image.blend(rgb, hz, haze_mix)
    out = rgb.convert("RGBA")
    out.putalpha(a)
    return out


def add_grounded_contact_shadow(sprite_rgba: Image.Image, tw: int, th: int, pad_x: int = 10, pad_bottom: int = 8) -> Image.Image:
    """
    Fits `sprite_rgba` into `(tw, th)` and paints a soft, translucent warm-umber contact shadow
    (`RGBA(14, 10, 7, 0..138)`) directly beneath the building's base — zero grey sticker ovals!
    """
    tc = tight_crop_rgba(sprite_rgba)
    mw = max(1, tw - 2 * pad_x)
    mh = max(1, th - pad_bottom - 6)
    s = min(mw / float(tc.width), mh / float(tc.height))
    nw = max(1, int(round(tc.width * s)))
    nh = max(1, int(round(tc.height * s)))
    rs = tc.resize((nw, nh), Image.Resampling.LANCZOS)
    rs = rs.filter(ImageFilter.UnsharpMask(radius=0.85, percent=110, threshold=3))

    ox = (tw - nw) // 2
    oy = th - pad_bottom - nh

    # Build soft ground contact shadow from bottom 18% of the sprite's alpha footprint
    foot = Image.new("L", (tw, th), 0)
    src_a = rs.getchannel("A")
    band_h = max(8, int(nh * 0.18))
    foot_strip = src_a.crop((0, nh - band_h, nw, nh)).resize((nw, max(6, int(band_h * 0.55))), Image.Resampling.BILINEAR)
    foot.paste(foot_strip, (ox, oy + nh - foot_strip.height + 3))
    foot_blur = foot.filter(ImageFilter.GaussianBlur(6.0))
    foot_alpha = foot_blur.point(lambda v: min(138, int(v * 0.72)))

    shadow = Image.new("RGBA", (tw, th), (14, 10, 7, 0))
    shadow.putalpha(foot_alpha)

    out = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    out = Image.alpha_composite(out, shadow)
    out.alpha_composite(rs, (ox, oy))
    return out


def make_warm_lantern_glow(rgba: Image.Image, boost: float = 1.0) -> Image.Image:
    """ Strictly illuminates ONLY true red/amber paper lanterns, braziers & forge fire (zero roof/wall speckles). """
    w, h = rgba.size
    px = rgba.load()
    seed = Image.new("L", (w, h), 0)
    spx = seed.load()
    for y in range(int(h * 0.08), int(h * 0.92)):
        for x in range(int(w * 0.05), int(w * 0.95)):
            r, g, b, a = px[x, y]
            if a < 185:
                continue
            # True cinnabar/crimson-orange lanterns or glowing forge coals (`r` strongly dominates both `g` and `b`)
            is_red_lantern = (r >= 162 and (r - g) >= 28 and (r - b) >= 64)
            is_bright_flame = (r >= 218 and g >= 135 and b <= 98 and (r - b) >= 115)
            if is_red_lantern or is_bright_flame:
                spx[x, y] = 255

    # Remove tiny isolated 1-3px warm specks via MinFilter->MaxFilter opening
    clean_seed = seed.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.MaxFilter(3))
    core_alpha = clean_seed.point(lambda v: min(245, int(v * 0.92 * boost)))
    halo_wide = clean_seed.filter(ImageFilter.GaussianBlur(7.5)).point(lambda v: min(195, int(v * 1.35 * boost)))
    halo_tight = clean_seed.filter(ImageFilter.GaussianBlur(2.5)).point(lambda v: min(235, int(v * 1.15 * boost)))

    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    l_wide = Image.new("RGBA", (w, h), (255, 166, 54, 0))
    l_wide.putalpha(halo_wide)
    l_tight = Image.new("RGBA", (w, h), (255, 204, 96, 0))
    l_tight.putalpha(halo_tight)
    l_core = Image.new("RGBA", (w, h), (255, 232, 156, 0))
    l_core.putalpha(core_alpha)

    out = Image.alpha_composite(out, l_wide)
    out = Image.alpha_composite(out, l_tight)
    out = Image.alpha_composite(out, l_core)
    sil = rgba.getchannel("A").filter(ImageFilter.GaussianBlur(1.5))
    out.putalpha(ImageChops.multiply(out.getchannel("A"), sil))
    return out


def make_night_rgba(rgba: Image.Image, lantern_boost: float = 1.0) -> Image.Image:
    w, h = rgba.size
    rgb = rgba.convert("RGB")
    dark = ImageEnhance.Brightness(rgb).enhance(0.45)
    moon = Image.new("RGB", (w, h), (30, 44, 70))
    night_rgb = Image.blend(dark, moon, 0.38)
    out = night_rgb.convert("RGBA")
    out.putalpha(rgba.getchannel("A"))
    if lantern_boost > 0.0:
        glow = make_warm_lantern_glow(rgba, boost=lantern_boost)
        out = Image.alpha_composite(out, glow)
        out.putalpha(rgba.getchannel("A"))
    return out


def make_snow_rgba(rgba: Image.Image, ground_mode: bool = False) -> Image.Image:
    w, h = rgba.size
    out = rgba.copy()
    px = rgba.load()
    snow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    spx = snow.load()

    if ground_mode:
        # Frost & drifted snow patches across stone terraces and curbs while keeping stone cracks visible
        for y in range(h):
            for x in range(w):
                r, g, b, a = px[x, y]
                if a < 40:
                    continue
                lum = 0.299 * r + 0.587 * g + 0.114 * b
                # Earthy shoulders accumulate thicker snow; central swept flagstones get light frost
                warm_earth = (r - b) > 14 and lum > 75
                if warm_earth:
                    spx[x, y] = (226, 234, 242, min(215, int(a * 0.78)))
                elif lum > 68:
                    spx[x, y] = (218, 228, 238, min(125, int(a * 0.36)))
        snow_soft = snow.filter(ImageFilter.GaussianBlur(1.4))
        out = Image.alpha_composite(out, snow_soft)
        out.putalpha(rgba.getchannel("A"))
        return out

    for y in range(2, int(h * 0.80)):
        for x in range(1, w - 1):
            r, g, b, a = px[x, y]
            if a < 190:
                continue
            above_open = px[x, max(0, y - 3)][3] < 90
            lum = 0.299 * r + 0.587 * g + 0.114 * b
            is_roof_tile = (abs(r - b) < 26 and 48 < lum < 155 and y < h * 0.60)
            if above_open:
                spx[x, y] = (234, 240, 246, 215)
            elif is_roof_tile and ((x + y * 2) % 4 != 0):
                spx[x, y] = (228, 236, 244, 108)
    snow_soft = snow.filter(ImageFilter.GaussianBlur(0.95))
    out = Image.alpha_composite(out, snow_soft)
    out.putalpha(rgba.getchannel("A"))
    return out


def make_hover_highlight(rgba: Image.Image) -> Image.Image:
    """Warm golden rim glow + 14% brightness lift for clickable building mouseover (`_b.png`)."""
    w, h = rgba.size
    a = rgba.getchannel("A")
    dilated = a.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.GaussianBlur(1.4))
    rim_a = ImageChops.subtract(dilated, a).point(lambda v: min(235, int(v * 1.45)))
    rim = Image.new("RGBA", (w, h), (246, 202, 98, 0))
    rim.putalpha(rim_a)

    bright_rgb = ImageEnhance.Brightness(rgba.convert("RGB")).enhance(1.13)
    bright = bright_rgb.convert("RGBA")
    bright.putalpha(a)

    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out = Image.alpha_composite(out, rim)
    out = Image.alpha_composite(out, bright)
    return out


def harmonize_panoramic_backdrops():
    """
    Harmonizes all 8 `wx_bg_*.jpg` + `_night.jpg` (1024x588) with subtle sumi-ink mountain ridge
    brushwork, unified Song/Ming parchment palette, and a soft horizon mist band around y=250..375
    so hilltop architecture sits inside the same painting!
    """
    mist_colors = {
        "wx_bg_plains":    (188, 186, 172),
        "wx_bg_mountains": (182, 186, 184),
        "wx_bg_forest":    (176, 182, 170),
        "wx_bg_swamp":     (174, 180, 172),
        "wx_bg_snow":      (204, 210, 216),
        "wx_bg_desert":    (208, 186, 148),
        "wx_bg_coast":     (186, 192, 192),
        "wx_bg_steppe":    (196, 184, 158),
    }

    # Build reusable vertical horizon mist alpha mask (`1024x588`, peaking smoothly around y=318)
    mist_mask = Image.new("L", (1024, 588), 0)
    mpx = mist_mask.load()
    for y in range(588):
        if 210 <= y <= 430:
            dist = abs(y - 318) / 112.0
            v = int(max(0.0, 1.0 - dist * dist) * 92)
            for x in range(1024):
                mpx[x, y] = v

    for stem, mcol in mist_colors.items():
        p = MOD_SET_DIR / f"{stem}.jpg"
        if not p.exists():
            continue
        rgb = Image.open(p).convert("RGB").resize((1024, 588), Image.Resampling.LANCZOS)
        # Subtle multi-scale sumi-ink ridge contour on distant mountains/trees
        gray = ImageOps.grayscale(rgb)
        blur_sm = gray.filter(ImageFilter.GaussianBlur(0.8))
        blur_lg = gray.filter(ImageFilter.GaussianBlur(2.6))
        diff = ImageChops.difference(blur_sm, blur_lg)
        ink_mask = diff.point(lambda d: min(88, max(0, (d - 4) * 5)))
        # Fade ink contours out in top sky (`y < 95`)
        ipx = ink_mask.load()
        for y in range(95):
            scale = y / 95.0
            for x in range(1024):
                ipx[x, y] = int(ipx[x, y] * scale)

        rgb = ImageEnhance.Color(rgb).enhance(0.84)
        warm = Image.new("RGB", (1024, 588), (206, 194, 172))
        rgb = Image.blend(rgb, ImageChops.multiply(rgb, warm), 0.12)

        rgba = rgb.convert("RGBA")
        ink_layer = Image.new("RGBA", (1024, 588), (24, 20, 16, 0))
        ink_layer.putalpha(ink_mask)
        rgba = Image.alpha_composite(rgba, ink_layer)

        mist_layer = Image.new("RGBA", (1024, 588), (mcol[0], mcol[1], mcol[2], 0))
        mist_layer.putalpha(mist_mask)
        rgba = Image.alpha_composite(rgba, mist_layer)

        day_rgb = rgba.convert("RGB")
        day_rgb.save(MOD_SET_DIR / f"{stem}.jpg", "JPEG", quality=90, optimize=True)

        # Atmospheric moonlit night backdrop
        n_dark = ImageEnhance.Brightness(day_rgb).enhance(0.38)
        n_tint = Image.new("RGB", (1024, 588), (24, 36, 60))
        night_rgb = Image.blend(n_dark, n_tint, 0.42)
        night_rgb.save(MOD_SET_DIR / f"{stem}_night.jpg", "JPEG", quality=88, optimize=True)

    print("Harmonized all 8 panoramic `wx_bg_*.jpg` + `_night.jpg` backdrops.")


def extract_ramp_terrace(raw_path: Path) -> Image.Image:
    """Extracts 1024x588 foreground terrace from 16:9 raw sheet with pure white upper sky."""
    src = Image.open(raw_path).convert("RGB").resize((1024, 588), Image.Resampling.LANCZOS)
    w, h = src.size
    px = src.load()

    bg = bytearray(w * h)
    q = deque()
    for x in range(w):
        r, g, b = px[x, 0]
        if is_bg_white(r, g, b, 232.0, 26):
            bg[x] = 1
            q.append((x, 0))
    for y in range(int(h * 0.72)):
        for x in (0, w - 1):
            idx = y * w + x
            if not bg[idx]:
                r, g, b = px[x, y]
                if is_bg_white(r, g, b, 232.0, 26):
                    bg[idx] = 1
                    q.append((x, y))

    while q:
        cx, cy = q.popleft()
        for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
            if 0 <= nx < w and 0 <= ny < h:
                nidx = ny * w + nx
                if not bg[nidx]:
                    r, g, b = px[nx, ny]
                    if is_bg_white(r, g, b, 234.0, 24):
                        bg[nidx] = 1
                        q.append((nx, ny))

    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    opx = out.load()
    for y in range(h):
        for x in range(w):
            if bg[y * w + x]:
                continue
            r, g, b = px[x, y]
            touches_sky = y > 0 and bg[(y - 1) * w + x]
            if touches_sky:
                lum = 0.299 * r + 0.587 * g + 0.114 * b
                a_val = 140 if lum > 180 else 220
                opx[x, y] = (int(r * 0.78), int(g * 0.77), int(b * 0.75), a_val)
            else:
                opx[x, y] = (r, g, b, 255)

    out = grade_wuxia_parchment(out, haze_mix=0.0)
    return out


def make_subtle_pathway_sheen(ramp_rgba: Image.Image, warm_sand: bool = False) -> Image.Image:
    """
    Creates a subtle, seamless 32-bit RGBA central avenue depth/curb accent (`wx_ui_pathway_*`)
    with ZERO harsh black lines or white halos, complementing the stepped avenue already painted on `wx_ui_ramp_*`.
    """
    w, h = ramp_rgba.size
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    dr = ImageDraw.Draw(out)
    # Very soft warm stone highlight along central avenue (`x=420..604` at crest -> `x=330..694` at bottom)
    col = (224, 198, 148, 22) if warm_sand else (210, 206, 194, 18)
    dr.polygon([(442, 316), (582, 316), (696, 588), (328, 588)], fill=col)
    out = out.filter(ImageFilter.GaussianBlur(8.0))
    out.putalpha(ImageChops.multiply(out.getchannel("A"), ramp_rgba.getchannel("A")))
    return out


def rebuild_ramps_and_pathways():
    ramp_stone = extract_ramp_terrace(RAW_RAMP_STONE)
    ramp_sand  = extract_ramp_terrace(RAW_RAMP_SAND)
    ramp_snow  = make_snow_rgba(ramp_stone, ground_mode=True)

    ramp_stone_night = make_night_rgba(ramp_stone, lantern_boost=0.0)
    ramp_sand_night  = make_night_rgba(ramp_sand, lantern_boost=0.0)
    ramp_snow_night  = make_night_rgba(ramp_snow, lantern_boost=0.0)

    for name, im in (
        ("wx_ui_ramp_stone.png",            ramp_stone),
        ("wx_ui_ramp_stone_night.png",      ramp_stone_night),
        ("wx_ui_ramp_stone_snow.png",       ramp_snow),
        ("wx_ui_ramp_stone_snow_night.png", ramp_snow_night),
        ("wx_ui_ramp_sand.png",             ramp_sand),
        ("wx_ui_ramp_sand_night.png",       ramp_sand_night),
    ):
        im.save(MOD_SET_DIR / name, "PNG", optimize=True, compress_level=9)

    pw_stone = make_subtle_pathway_sheen(ramp_stone, warm_sand=False)
    pw_sand  = make_subtle_pathway_sheen(ramp_sand, warm_sand=True)
    for name, im in (
        ("wx_ui_pathway_stone.png",            pw_stone),
        ("wx_ui_pathway_stone_night.png",      make_night_rgba(pw_stone, lantern_boost=0.0)),
        ("wx_ui_pathway_stone_snow.png",       pw_stone),
        ("wx_ui_pathway_stone_snow_night.png", make_night_rgba(pw_stone, lantern_boost=0.0)),
        ("wx_ui_pathway_sand.png",             pw_sand),
        ("wx_ui_pathway_sand_night.png",       make_night_rgba(pw_sand, lantern_boost=0.0)),
    ):
        im.save(MOD_SET_DIR / name, "PNG", optimize=True, compress_level=9)

    print("Rebuilt 32-bit RGBA `wx_ui_ramp_*` and `wx_ui_pathway_*` ground terraces.")


def rebuild_centers():
    sheet = Image.open(RAW_CENTERS).convert("RGB")
    sw, sh = sheet.size
    cw, ch = sw / 3.0, sh / 3.0

    # (row, col, id, max_w, max_h, y_bottom_on_1024x588)
    specs = [
        (0, 0, "wx_ui_center_village",    470, 255, 336),
        (0, 1, "wx_ui_center_town",       520, 275, 336),
        (0, 2, "wx_ui_center_prefecture", 550, 295, 336),
        (1, 0, "wx_ui_center_sect",       510, 295, 338),
        (1, 1, "wx_ui_center_monastery",  535, 290, 336),
        (1, 2, "wx_ui_center_outpost",    490, 265, 336),
        (2, 0, "wx_ui_center_garrison",   520, 280, 336),
        (2, 1, "wx_ui_center_citadel",    550, 295, 336),
        (2, 2, "wx_ui_center_oasis",      535, 285, 338),
    ]

    for r, c, cid, mw, mh, y_bot in specs:
        x0 = int(round(c * cw)) + 6
        y0 = int(round(r * ch)) + 6
        x1 = int(round((c + 1) * cw)) - 6
        # Crop above the bottom English caption line (~bottom 11% of each cell)
        y1 = int(round((r + 1) * ch - ch * 0.115))
        cell = sheet.crop((x0, y0, x1, y1))

        spr = extract_sprite_from_white_cell(cell, clear_interior_pure_white=True, keep_largest_only=False)
        tc = tight_crop_rgba(spr)
        tc = grade_wuxia_parchment(tc, haze_mix=0.07, haze_rgb=(184, 180, 168))

        s = min(mw / float(tc.width), mh / float(tc.height))
        nw = max(1, int(round(tc.width * s)))
        nh = max(1, int(round(tc.height * s)))
        rs = tc.resize((nw, nh), Image.Resampling.LANCZOS)
        rs = rs.filter(ImageFilter.UnsharpMask(radius=0.85, percent=108, threshold=3))

        canvas = Image.new("RGBA", (1024, 588), (0, 0, 0, 0))
        px = (1024 - nw) // 2
        py = y_bot - nh
        canvas.alpha_composite(rs, (px, py))

        night = make_night_rgba(canvas, lantern_boost=1.0)
        snow  = make_snow_rgba(canvas, ground_mode=False)
        snow_night = make_night_rgba(snow, lantern_boost=1.0)

        canvas.save(MOD_SET_DIR / f"{cid}.png", "PNG", optimize=True, compress_level=9)
        night.save(MOD_SET_DIR / f"{cid}_night.png", "PNG", optimize=True, compress_level=9)
        snow.save(MOD_SET_DIR / f"{cid}_snow.png", "PNG", optimize=True, compress_level=9)
        snow_night.save(MOD_SET_DIR / f"{cid}_snow_night.png", "PNG", optimize=True, compress_level=9)

    print("Rebuilt all 9 centered 32-bit RGBA `wx_ui_center_*` hilltop complexes (zero cut edges).")


def rebuild_flanking_houses():
    sheet = Image.open(RAW_HOUSES).convert("RGB")
    sw, sh = sheet.size
    cw, ch = sw / 4.0, sh / 2.0

    # 7 flanking house pairs + 1 coastal quay left layer (`wx_ui_water_left`)
    specs = [
        (0, 0, "wx_ui_houses_01",    True),
        (0, 1, "wx_ui_houses_02",    True),
        (0, 2, "wx_ui_houses_03",    True),
        (0, 3, "wx_ui_houses_04",    True),
        (1, 0, "wx_ui_houses_sect",  True),
        (1, 1, "wx_ui_houses_water", True),
        (1, 2, "wx_ui_houses_fort",  True),
        (1, 3, "wx_ui_water",        False),  # -> `wx_ui_water_left` (+ snow/night)
    ]

    for r, c, hid, both_sides in specs:
        x0 = int(round(c * cw)) + 6
        y0 = int(round(r * ch)) + 6
        x1 = int(round((c + 1) * cw)) - 6
        y1 = int(round((r + 1) * ch)) - 6
        cell = sheet.crop((x0, y0, x1, y1))

        spr = extract_sprite_from_white_cell(cell, clear_interior_pure_white=True, keep_largest_only=False)
        tc = tight_crop_rgba(spr)
        tc = grade_wuxia_parchment(tc, haze_mix=0.04, haze_rgb=(182, 178, 166))

        mw, mh = (340, 240) if both_sides else (345, 210)
        s = min(mw / float(tc.width), mh / float(tc.height))
        nw = max(1, int(round(tc.width * s)))
        nh = max(1, int(round(tc.height * s)))
        rs_left = tc.resize((nw, nh), Image.Resampling.LANCZOS).filter(
            ImageFilter.UnsharpMask(radius=0.85, percent=108, threshold=3)
        )
        rs_right = ImageOps.mirror(rs_left)

        sides = [("left", rs_left, 4, 392)]
        if both_sides:
            sides.append(("right", rs_right, 1024 - nw - 4, 392))
        else:
            sides = [("left", rs_left, 6, 396)]

        for side_name, side_im, pos_x, y_bot in sides:
            canvas = Image.new("RGBA", (1024, 588), (0, 0, 0, 0))
            canvas.alpha_composite(side_im, (pos_x, y_bot - nh))

            night = make_night_rgba(canvas, lantern_boost=1.0)
            snow  = make_snow_rgba(canvas, ground_mode=False)
            snow_night = make_night_rgba(snow, lantern_boost=1.0)

            stem = f"{hid}_{side_name}"
            canvas.save(MOD_SET_DIR / f"{stem}.png", "PNG", optimize=True, compress_level=9)
            night.save(MOD_SET_DIR / f"{stem}_night.png", "PNG", optimize=True, compress_level=9)
            snow.save(MOD_SET_DIR / f"{stem}_snow.png", "PNG", optimize=True, compress_level=9)
            snow_night.save(MOD_SET_DIR / f"{stem}_snow_night.png", "PNG", optimize=True, compress_level=9)

    print("Rebuilt all 7 `wx_ui_houses_*` pairs + `wx_ui_water_left` coastal harbor layer.")


def rebuild_shop_buildings():
    sheet = Image.open(RAW_BUILDINGS).convert("RGB")
    sw, sh = sheet.size
    cw, ch = sw / 4.0, sh / 4.0

    # Exact target canvas dimensions matching slot layout in `wx_global_theme.css`
    specs = [
        (0, 0, "wx_bldg_crowd",         232, 124, False),
        (0, 1, "wx_bldg_marketplace",   396, 182, True),
        (0, 2, "wx_bldg_tavern",        390, 232, True),
        (0, 3, "wx_bldg_temple",        324, 212, True),
        (1, 0, "wx_bldg_weaponsmith",   324, 224, True),
        (1, 1, "wx_bldg_armorsmith",    312, 224, True),
        (1, 2, "wx_bldg_fletcher",      356, 202, True),
        (1, 3, "wx_bldg_training_hall", 380, 228, True),
        (2, 0, "wx_bldg_taxidermist",   344, 226, True),
        (2, 1, "wx_bldg_alchemist",     350, 228, True),
        (2, 2, "wx_bldg_arena",         374, 216, True),
        (2, 3, "wx_bldg_arena_closed",  374, 216, False),
        (3, 0, "wx_bldg_port",          336, 240, True),
        (3, 1, "wx_bldg_barber",        346, 214, True),
        (3, 2, "wx_bldg_kennel",        384, 216, True),
    ]

    for r, c, bid, tw, th, make_variants in specs:
        x0 = int(round(c * cw)) + (26 if bid == "wx_bldg_barber" else 6)
        y0 = int(round(r * ch)) + 6
        x1 = int(round((c + 1) * cw)) - 6
        y1 = int(round((r + 1) * ch)) - 6
        cell = sheet.crop((x0, y0, x1, y1))

        keep_single = bid in ("wx_bldg_barber", "wx_bldg_marketplace", "wx_bldg_tavern", "wx_bldg_training_hall", "wx_bldg_port")
        spr = extract_sprite_from_white_cell(cell, clear_interior_pure_white=True, keep_largest_only=keep_single)
        spr = grade_wuxia_parchment(spr, haze_mix=0.0)
        day = add_grounded_contact_shadow(spr, tw, th, pad_x=10, pad_bottom=8)
        day_b = make_hover_highlight(day)

        day.save(MOD_SET_DIR / f"{bid}.png", "PNG", optimize=True, compress_level=9)
        day_b.save(MOD_SET_DIR / f"{bid}_b.png", "PNG", optimize=True, compress_level=9)

        if bid == "wx_bldg_crowd":
            night = make_night_rgba(day, lantern_boost=1.0)
            night_b = make_hover_highlight(night)
            night.save(MOD_SET_DIR / f"{bid}_night.png", "PNG", optimize=True, compress_level=9)
            night_b.save(MOD_SET_DIR / f"{bid}_night_b.png", "PNG", optimize=True, compress_level=9)
        elif make_variants:
            night = make_night_rgba(day, lantern_boost=1.15)
            night_b = make_hover_highlight(night)
            night.save(MOD_SET_DIR / f"{bid}_night.png", "PNG", optimize=True, compress_level=9)
            night_b.save(MOD_SET_DIR / f"{bid}_night_b.png", "PNG", optimize=True, compress_level=9)

    print("Rebuilt all 14 clickable 32-bit RGBA `wx_bldg_*` shop sets (day, hover, night, night-hover, closed).")


def render_town_composites():
    """Renders 4 full 1024x588 Town Interior scenes matching exact in-game CSS slot coordinates."""
    SCRATCH_DIR.mkdir(parents=True, exist_ok=True)

    def place_slot(canvas: Image.Image, bldg_name: str, slot_idx: int):
        im = Image.open(MOD_SET_DIR / bldg_name).convert("RGBA")
        w, h = im.size
        if slot_idx == 0:    # right: 17.5rem (175px), bottom: 22.0rem (220px)
            x, y = 1024 - 175 - w, 588 - 220 - h
        elif slot_idx == 1:  # left: 13.5rem (135px), bottom: 19.8rem (198px)
            x, y = 135, 588 - 198 - h
        elif slot_idx == 2:  # center, top: 28.4rem (284px), max-height: 16.4rem (164px)
            if h > 164:
                s = 164.0 / h
                im = im.resize((int(round(w * s)), 164), Image.Resampling.LANCZOS)
                w, h = im.size
            x, y = (1024 - w) // 2, 284
        elif slot_idx == 3:  # right: 68.5rem -> right edge at 339px, bottom: 4.2rem (42px)
            x, y = 1024 - 685 - w, 588 - 42 - h
        elif slot_idx == 4:  # left: 68.5rem (685px), bottom: 4.2rem (42px)
            x, y = 685, 588 - 42 - h
        else:                # slot 5: center, bottom: 2.2rem (22px), max-height: 11.8rem (118px)
            if h > 118:
                s = 118.0 / h
                im = im.resize((int(round(w * s)), 118), Image.Resampling.LANCZOS)
                w, h = im.size
            x, y = (1024 - w) // 2, 588 - 22 - h
        canvas.alpha_composite(im, (max(0, min(1024 - w, x)), max(0, min(588 - h, y))))

    # 1. Central Plains Prefecture City (Day) — includes Tavern, Marketplace, Weaponsmith, Taxidermist, Barber (Disguise Pavilion!), Crowd
    c1 = Image.open(MOD_SET_DIR / "wx_bg_plains.jpg").convert("RGBA")
    c1.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_center_prefecture.png").convert("RGBA"))
    c1.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_houses_03_left.png").convert("RGBA"))
    c1.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_houses_03_right.png").convert("RGBA"))
    c1.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_ramp_stone.png").convert("RGBA"))
    c1.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_pathway_stone.png").convert("RGBA"))
    place_slot(c1, "wx_bldg_tavern.png", 1)
    place_slot(c1, "wx_bldg_barber.png", 0)
    place_slot(c1, "wx_bldg_marketplace.png", 2)
    place_slot(c1, "wx_bldg_weaponsmith.png", 3)
    place_slot(c1, "wx_bldg_taxidermist.png", 4)
    place_slot(c1, "wx_bldg_crowd.png", 5)
    c1.save(SCRATCH_DIR / "preview_town_plains_day.png")

    # 2. County Town (Night)
    c2 = Image.open(MOD_SET_DIR / "wx_bg_mountains_night.jpg").convert("RGBA")
    c2.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_center_town_night.png").convert("RGBA"))
    c2.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_houses_02_left_night.png").convert("RGBA"))
    c2.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_houses_02_right_night.png").convert("RGBA"))
    c2.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_ramp_stone_night.png").convert("RGBA"))
    place_slot(c2, "wx_bldg_tavern_night.png", 1)
    place_slot(c2, "wx_bldg_temple_night.png", 0)
    place_slot(c2, "wx_bldg_marketplace_night.png", 2)
    place_slot(c2, "wx_bldg_training_hall_night.png", 3)
    place_slot(c2, "wx_bldg_armorsmith_night.png", 4)
    c2.save(SCRATCH_DIR / "preview_town_night.png")

    # 3. Silk-Road Oasis City (Day) + Coastal Port Snow/Water check
    c3 = Image.open(MOD_SET_DIR / "wx_bg_desert.jpg").convert("RGBA")
    c3.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_center_oasis.png").convert("RGBA"))
    c3.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_houses_04_left.png").convert("RGBA"))
    c3.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_houses_04_right.png").convert("RGBA"))
    c3.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_ramp_sand.png").convert("RGBA"))
    place_slot(c3, "wx_bldg_alchemist.png", 1)
    place_slot(c3, "wx_bldg_arena.png", 0)
    place_slot(c3, "wx_bldg_marketplace.png", 2)
    place_slot(c3, "wx_bldg_crowd.png", 5)
    c3.save(SCRATCH_DIR / "preview_town_oasis.png")

    # 4. Coastal Water Port Town
    c4 = Image.open(MOD_SET_DIR / "wx_bg_coast.jpg").convert("RGBA")
    c4.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_center_village.png").convert("RGBA"))
    c4.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_water_left.png").convert("RGBA"))
    c4.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_houses_water_right.png").convert("RGBA"))
    c4.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_ramp_stone.png").convert("RGBA"))
    place_slot(c4, "wx_bldg_tavern.png", 0)
    place_slot(c4, "wx_bldg_marketplace.png", 2)
    place_slot(c4, "wx_bldg_port.png", 3)
    place_slot(c4, "wx_bldg_crowd.png", 5)
    c4.save(SCRATCH_DIR / "preview_town_coastal.png")

    print("Saved 4 full 1024x588 town composite previews into:", SCRATCH_DIR)


def optimize_static_arch_layers():
    """Compresses full-canvas opaque-silhouette `wx_ui_*` layers while keeping all `wx_bldg_*` & `wx_ui_pathway_*` in 32-bit RGBA."""
    for p in sorted(MOD_SET_DIR.glob("wx_ui_*.png")):
        if p.name.startswith("wx_ui_pathway_"):
            continue
        q = Image.open(p).convert("RGBA").quantize(colors=256, method=Image.Quantize.FASTOCTREE)
        q.save(p, "PNG", optimize=True, compress_level=9)


if __name__ == "__main__":
    import sys
    if "--with-bg" in sys.argv:
        harmonize_panoramic_backdrops()
    rebuild_ramps_and_pathways()
    rebuild_centers()
    rebuild_flanking_houses()
    rebuild_shop_buildings()
    optimize_static_arch_layers()
    render_town_composites()
