#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BB Wuxia Mod - Comprehensive UI Asset Slicer & Dark Ming-Era Skin Synthesizer
Generates all non-destructive `wx_` UI icons, equipment silhouettes, talent stars,
guardian-flanked Character Screen frame, Xuan-paper event scroll frames, lacquer-bronze
buttons, elemental progressbars, and Main Menu / Loading visuals.
"""

import math
import os
import random
import shutil
from collections import deque
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART_SHEETS = os.path.join(ROOT, "art", "sheets")
PROMO_KEYS = os.path.join(ROOT, "promo", "keyframes")
MOD_GFX = os.path.join(ROOT, "mod_wuxia", "gfx")
WX_ICONS_DIR = os.path.join(MOD_GFX, "ui", "wx_icons")
WX_SKIN_DIR = os.path.join(MOD_GFX, "ui", "wx_skin")
FONT_PATH = os.path.join(ROOT, "mod_wuxia", "ui", "mods", "mod_wuxia", "fonts", "wx_ming_serif.ttf")

BRAIN_DIR = r"C:\Users\25647\.gemini\antigravity\brain\0dcfca23-82a8-45b3-84e5-cafbc71c228a"
RAW_SOURCES = {
    "wx_ui_sheet_a.jpg": "wx_ui_sheet_a_1795186766398.jpg",
    "wx_ui_sheet_b.jpg": "wx_ui_sheet_b_1795186778809.jpg",
    "wx_ui_guardian_statues.jpg": "wx_ui_guardian_statues_1795187048966.jpg",
    "wx_ui_header_banner.jpg": "wx_ui_header_banner_1795187060915.jpg",
}


def flood_clean_white(im_rgb: Image.Image, seed_center: bool = False, thresh: int = 34, feather: int = 22) -> Image.Image:
    """Flood-fills white background from edges (and optionally center hole for rings) with smooth alpha anti-aliasing."""
    rgba = im_rgb.convert("RGBA")
    w, h = rgba.size
    px = rgba.load()
    visited = bytearray(w * h)
    q = deque()

    def is_whiteish(x, y):
        r, g, b, _ = px[x, y]
        return (255 - r) <= thresh and (255 - g) <= thresh and (255 - b) <= thresh

    for x in range(w):
        for y in (0, h - 1):
            if is_whiteish(x, y) and not visited[y * w + x]:
                visited[y * w + x] = 1
                q.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            if is_whiteish(x, y) and not visited[y * w + x]:
                visited[y * w + x] = 1
                q.append((x, y))

    if seed_center:
        cx, cy = w // 2, h // 2
        for dx in range(-6, 7, 3):
            for dy in range(-6, 7, 3):
                sx, sy = cx + dx, cy + dy
                if 0 <= sx < w and 0 <= sy < h and is_whiteish(sx, sy) and not visited[sy * w + sx]:
                    visited[sy * w + sx] = 1
                    q.append((sx, sy))

    while q:
        cx, cy = q.popleft()
        px[cx, cy] = (0, 0, 0, 0)
        for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
            if 0 <= nx < w and 0 <= ny < h:
                idx = ny * w + nx
                if not visited[idx] and is_whiteish(nx, ny):
                    visited[idx] = 1
                    q.append((nx, ny))

    # Feather semi-white fringe pixels adjacent to transparent background
    fringe = []
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            has_trans_nb = (
                px[x - 1, y][3] == 0 or px[x + 1, y][3] == 0 or
                px[x, y - 1][3] == 0 or px[x, y + 1][3] == 0
            )
            if has_trans_nb:
                dist = max(255 - r, 255 - g, 255 - b)
                if dist < thresh + feather:
                    na = max(0, min(255, int(255 * (dist - thresh // 2) / float(feather + thresh // 2))))
                    # Decontaminate white halo slightly
                    dr = int(r * 0.78)
                    dg = int(g * 0.78)
                    db = int(b * 0.78)
                    fringe.append((x, y, dr, dg, db, na))
    for x, y, dr, dg, db, na in fringe:
        px[x, y] = (dr, dg, db, na)

    return rgba


def tight_crop_rgba(rgba: Image.Image) -> Image.Image:
    bbox = rgba.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
    if not bbox:
        return rgba
    return rgba.crop(bbox)


def fit_box(rgba: Image.Image, w: int, h: int, pad: int = 2) -> Image.Image:
    tc = tight_crop_rgba(rgba)
    mw, mh = max(1, w - 2 * pad), max(1, h - 2 * pad)
    s = min(mw / float(tc.width), mh / float(tc.height))
    nw, nh = max(1, int(round(tc.width * s))), max(1, int(round(tc.height * s)))
    im = tc.resize((nw, nh), Image.Resampling.LANCZOS)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.alpha_composite(im, ((w - nw) // 2, (h - nh) // 2))
    return out


def make_sw(rgba: Image.Image) -> Image.Image:
    g = ImageOps.grayscale(rgba.convert("RGB"))
    g = ImageEnhance.Brightness(g).enhance(0.58)
    g = ImageEnhance.Contrast(g).enhance(0.9)
    r, gg, b = g.convert("RGB").split()
    return Image.merge("RGBA", (r, gg, b, rgba.getchannel("A")))


def make_slot_silhouette(rgba: Image.Image, w: int, h: int) -> Image.Image:
    """Transforms a bronze-ink emblem into a subtle recessed paperdoll slot watermark."""
    fitted = fit_box(rgba, w, h, pad=8 if h == 70 else 10)
    g = ImageOps.grayscale(fitted.convert("RGB"))
    # Warm dark bronze-sepia tint
    tinted = ImageOps.colorize(g, black="#100c09", mid="#4d3b28", white="#8a6d4b")
    r, gg, b = tinted.split()
    a = fitted.getchannel("A").point(lambda v: int(v * 0.42))
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    # Subtle dark recessed slot inner frame
    dr = ImageDraw.Draw(out)
    dr.rectangle([1, 1, w - 2, h - 2], fill=(16, 12, 9, 135), outline=(72, 56, 38, 175), width=1)
    dr.rectangle([3, 3, w - 4, h - 4], outline=(34, 26, 18, 140), width=1)
    out.alpha_composite(Image.merge("RGBA", (r, gg, b, a)), (0, 0))
    return out


# ============================================================================
# Procedural Dark Ming-Era Wood, Smoked Xuan-Paper & Bronze Meander Primitives
# ============================================================================

def generate_ebony_wood(w: int, h: int, base_rgb=(25, 19, 14), grain_amp=9, vertical=False, seed=42) -> Image.Image:
    """Generates rich hand-rubbed dark Ming ebony wood grain texture."""
    rng = random.Random(seed)
    # Generate low-res noise stretched along grain axis for organic wood fibers
    gw = max(8, w // (2 if vertical else 14))
    gh = max(8, h // (14 if vertical else 2))
    noise = Image.new("L", (gw, gh))
    npx = noise.load()
    for y in range(gh):
        row_bias = rng.randint(-12, 12)
        for x in range(gw):
            col_bias = rng.randint(-12, 12) if vertical else 0
            v = 128 + (col_bias if vertical else row_bias) + rng.randint(-28, 28)
            npx[x, y] = max(0, min(255, v))
    grain = noise.resize((w, h), Image.Resampling.BICUBIC)

    # Plank seams every ~44px
    out = Image.new("RGBA", (w, h), (*base_rgb, 255))
    gpx = grain.load()
    opx = out.load()
    plank_step = 46
    for y in range(h):
        # Radial vignette darkening near edges
        vy = abs(y - h * 0.5) / max(1.0, h * 0.5)
        seam = 0
        if not vertical and (y % plank_step in (0, 1)):
            seam = -10 if (y % plank_step == 0) else 4
        for x in range(w):
            vx = abs(x - w * 0.5) / max(1.0, w * 0.5)
            vseam = 0
            if vertical and (x % 38 in (0, 1)):
                vseam = -9 if (x % 38 == 0) else 3
            vig = int(-11 * (vx * vx * 0.6 + vy * vy * 0.6))
            delta = int((gpx[x, y] - 128) * grain_amp / 32.0) + seam + vseam + vig
            opx[x, y] = (
                max(0, min(255, base_rgb[0] + delta)),
                max(0, min(255, base_rgb[1] + int(delta * 0.85))),
                max(0, min(255, base_rgb[2] + int(delta * 0.7))),
                255,
            )
    return out


def generate_smoked_xuan_paper(w: int, h: int, base_rgb=(32, 25, 19), seed=108) -> Image.Image:
    """Generates aged dark smoked Xuan-paper / silk-scroll texture with subtle ink-wash clouds."""
    rng = random.Random(seed)
    cw, ch = max(8, w // 12), max(8, h // 12)
    cloud = Image.new("L", (cw, ch))
    cpx = cloud.load()
    for y in range(ch):
        for x in range(cw):
            cpx[x, y] = rng.randint(90, 166)
    cloud_lg = cloud.resize((w, h), Image.Resampling.BICUBIC).filter(ImageFilter.GaussianBlur(radius=6))

    fw, fh = max(12, w // 3), max(12, h // 3)
    fiber = Image.new("L", (fw, fh))
    fpx = fiber.load()
    for y in range(fh):
        for x in range(fw):
            fpx[x, y] = rng.randint(112, 144)
    fiber_lg = fiber.resize((w, h), Image.Resampling.BILINEAR)

    out = Image.new("RGBA", (w, h), (*base_rgb, 255))
    opx = out.load()
    cl_px = cloud_lg.load()
    fb_px = fiber_lg.load()
    for y in range(h):
        vy = (y - h * 0.5) / max(1.0, h * 0.5)
        for x in range(w):
            vx = (x - w * 0.5) / max(1.0, w * 0.5)
            vig = int(-14 * (vx * vx + vy * vy))
            d = int((cl_px[x, y] - 128) * 0.22 + (fb_px[x, y] - 128) * 0.18) + vig
            opx[x, y] = (
                max(0, min(255, base_rgb[0] + d)),
                max(0, min(255, base_rgb[1] + int(d * 0.88))),
                max(0, min(255, base_rgb[2] + int(d * 0.72))),
                255,
            )
    return out


def draw_bronze_meander_corner(draw: ImageDraw.ImageDraw, x: int, y: int, size: int, flip_x: bool, flip_y: bool, color=(158, 123, 70, 235), shadow=(10, 7, 5, 210)):
    """Draws classical Chinese Ming bronze Huiwen (回纹) corner bracket ornament."""
    def tx(dx):
        return (x - dx) if flip_x else (x + dx)

    def ty(dy):
        return (y - dy) if flip_y else (y + dy)

    def seg(x1, y1, x2, y2, w=2):
        draw.line([(tx(x1) + 1, ty(y1) + 1), (tx(x2) + 1, ty(y2) + 1)], fill=shadow, width=w)
        draw.line([(tx(x1), ty(y1)), (tx(x2), ty(y2))], fill=color, width=w)

    s = size
    # Outer L-arm
    seg(0, 0, s, 0, 2)
    seg(0, 0, 0, s, 2)
    # Inner stepped meander spiral
    m1 = int(s * 0.62)
    m2 = int(s * 0.34)
    k = max(5, int(s * 0.18))
    seg(k, k, m1, k, 2)
    seg(m1, k, m1, k * 2, 2)
    seg(k, k, k, m1, 2)
    seg(k, m1, k * 2, m1, 2)
    # Spiral hook eye
    seg(k * 2, k * 2, m2 + k, k * 2, 1)
    seg(k * 2, k * 2, k * 2, m2 + k, 1)


def draw_ming_bronze_frame(im: Image.Image, rect, corner_size=28, outer_col=(14, 10, 8, 255), bronze_hi=(174, 136, 78, 245), bronze_mid=(112, 86, 48, 240), inner_dark=(38, 29, 20, 220)):
    """Draws a complete bevelled dark-iron & gilded-bronze frame with 4 Huiwen corners."""
    x0, y0, x1, y1 = rect
    dr = ImageDraw.Draw(im)
    dr.rectangle([x0, y0, x1, y1], outline=outer_col, width=2)
    dr.rectangle([x0 + 2, y0 + 2, x1 - 2, y1 - 2], outline=bronze_mid, width=2)
    dr.rectangle([x0 + 4, y0 + 4, x1 - 4, y1 - 4], outline=outer_col, width=1)
    dr.rectangle([x0 + 6, y0 + 6, x1 - 6, y1 - 6], outline=inner_dark, width=1)
    if corner_size > 0:
        draw_bronze_meander_corner(dr, x0 + 5, y0 + 5, corner_size, False, False, bronze_hi)
        draw_bronze_meander_corner(dr, x1 - 5, y0 + 5, corner_size, True, False, bronze_hi)
        draw_bronze_meander_corner(dr, x0 + 5, y1 - 5, corner_size, False, True, bronze_hi)
        draw_bronze_meander_corner(dr, x1 - 5, y1 - 5, corner_size, True, True, bronze_hi)


def build_button(w: int, h: int, state: str, is_tab: bool = False) -> Image.Image:
    """Synthesizes Ming-era lacquered ebony & bronze-capped wooden plaque buttons."""
    if state == "hover":
        base = (68, 24, 18) if not is_tab else (56, 38, 22)
        border_hi = (224, 178, 96, 255)
        border_mid = (166, 122, 58, 255)
    elif state == "pressed":
        base = (48, 17, 13)
        border_hi = (188, 144, 72, 255)
        border_mid = (120, 88, 42, 255)
    elif state == "disabled":
        base = (24, 21, 19)
        border_hi = (78, 70, 60, 200)
        border_mid = (54, 48, 42, 200)
    else:
        base = (34, 24, 18) if not is_tab else (26, 20, 15)
        border_hi = (162, 126, 70, 245)
        border_mid = (98, 75, 42, 245)

    im = generate_ebony_wood(w, h, base_rgb=base, grain_amp=6, seed=w + h)
    dr = ImageDraw.Draw(im)
    # Top subtle sheen & bottom shadow
    dr.line([(2, 2), (w - 3, 2)], fill=(*border_hi[:3], 95), width=1)
    dr.line([(2, h - 3), (w - 3, h - 3)], fill=(6, 4, 3, 180), width=2)
    # Outer dark ink outline + bronze double trim
    dr.rectangle([0, 0, w - 1, h - 1], outline=(10, 7, 5, 255), width=1)
    dr.rectangle([1, 1, w - 2, h - 2], outline=border_mid, width=1)
    dr.rectangle([3, 3, w - 4, h - 4], outline=(16, 11, 8, 180), width=1)

    # End-cap bronze brackets (bamboo-slip / plaque rivets)
    cap = min(12, h // 3)
    draw_bronze_meander_corner(dr, 3, 3, cap, False, False, border_hi)
    draw_bronze_meander_corner(dr, w - 4, 3, cap, True, False, border_hi)
    draw_bronze_meander_corner(dr, 3, h - 4, cap, False, True, border_hi)
    draw_bronze_meander_corner(dr, w - 4, h - 4, cap, True, True, border_hi)

    if state == "hover":
        # Subtle warm cinnabar-gold center glow
        glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        gdr = ImageDraw.Draw(glow)
        gdr.ellipse([w // 6, 4, w - w // 6, h - 4], fill=(210, 140, 62, 34))
        glow = glow.filter(ImageFilter.GaussianBlur(radius=6))
        im.alpha_composite(glow)
    return im


def build_progressbar(w: int, h: int, kind: str) -> Image.Image:
    """Synthesizes carved jade / cinnabar-blood / cyan-qi / Damascus-steel progressbars."""
    palettes = {
        "empty":       ((14, 11, 9),   (24, 19, 15),   (64, 50, 35)),
        "qi":          ((18, 66, 74),  (42, 138, 142), (124, 214, 206)),
        "qi_preview":  ((66, 98, 86),  (118, 182, 156),(190, 238, 212)),
        "hp":          ((76, 18, 16),  (148, 36, 28),  (212, 82, 64)),
        "ap":          ((92, 74, 34),  (178, 142, 64), (238, 210, 132)),
        "morale":      ((86, 54, 18),  (168, 112, 36), (232, 178, 78)),
        "armor":       ((48, 54, 60),  (98, 108, 118), (162, 174, 186)),
        "neutral":     ((36, 48, 44),  (68, 92, 84),   (118, 148, 136)),
        "xp":          ((58, 44, 20),  (136, 104, 44), (212, 172, 88)),
    }
    dark, mid, hi = palettes[kind]
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = im.load()
    for y in range(h):
        t = y / float(max(1, h - 1))
        # Cylindrical carved-jade highlight at ~28% from top
        if kind == "empty":
            k = 0.2 + 0.8 * t
            r = int(dark[0] * (1 - k) + mid[0] * k)
            g = int(dark[1] * (1 - k) + mid[1] * k)
            b = int(dark[2] * (1 - k) + mid[2] * k)
        else:
            band = math.exp(-((t - 0.28) ** 2) / 0.08)
            shade = 1.0 - 0.42 * max(0.0, t - 0.45)
            r = int(min(255, (mid[0] * shade) * (1 - band * 0.48) + hi[0] * (band * 0.48)))
            g = int(min(255, (mid[1] * shade) * (1 - band * 0.48) + hi[1] * (band * 0.48)))
            b = int(min(255, (mid[2] * shade) * (1 - band * 0.48) + hi[2] * (band * 0.48)))
        for x in range(w):
            px[x, y] = (r, g, b, 255)

    dr = ImageDraw.Draw(im)
    if kind == "empty":
        dr.rectangle([0, 0, w - 1, h - 1], outline=(10, 8, 6, 255), width=1)
        dr.rectangle([1, 1, w - 2, h - 2], outline=(78, 61, 42, 220), width=1)
    else:
        dr.rectangle([0, 0, w - 1, h - 1], outline=(12, 9, 7, 175), width=1)
    return im


def build_character_screen_frame(statue_l: Image.Image, statue_r: Image.Image, compass_ring: Image.Image) -> Image.Image:
    """
    Synthesizes the 1421x906 Character Screen grand frame (`wx_background_inventory.png`),
    exact-aligned to `.character-screen-container` (`left=209, top=125, width=1039, height=781`,
    left col `340px`, right col `699px`).
    """
    W, H = 1421, 906
    canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))

    # 1. Left & Right Ming Guardian Stone-Bronze Statues (replacing Norman Knight & Skeleton!)
    def prep_statue(st: Image.Image, target_h: int) -> Image.Image:
        tc = tight_crop_rgba(st)
        s = target_h / float(tc.height)
        nw = max(1, int(round(tc.width * s)))
        im = tc.resize((nw, target_h), Image.Resampling.LANCZOS)
        # Grade into moody dark architectural stone-bronze so UI content stays king
        rgb = ImageEnhance.Brightness(im.convert("RGB")).enhance(0.66)
        rgb = ImageEnhance.Contrast(rgb).enhance(1.08)
        r, g, b = rgb.split()
        return Image.merge("RGBA", (r, g, b, im.getchannel("A")))

    sl = prep_statue(statue_l, 875)
    sr = ImageOps.mirror(prep_statue(statue_r, 885))
    # Place left statue centered around x=106, bottom=904; mirrored right statue at x=1226..1420 so face & body stand completely clear of x=1248!
    canvas.alpha_composite(sl, (max(0, 106 - sl.width // 2), H - 2 - sl.height))
    canvas.alpha_composite(sr, (W - 2 - sr.width, H - 2 - sr.height))

    # Soft shadow cast between statues and main board
    sh = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sdr = ImageDraw.Draw(sh)
    sdr.rectangle([196, 116, 1260, 905], fill=(0, 0, 0, 195))
    sh = sh.filter(ImageFilter.GaussianBlur(radius=9))
    canvas.alpha_composite(sh)

    # 2. Main Board (`209..1248, 125..905`)
    bx0, by0, bx1, by1 = 209, 125, 1248, 905
    bw, bh = bx1 - bx0, by1 - by0  # 1039 x 780
    board = generate_ebony_wood(bw, bh, base_rgb=(24, 18, 14), grain_amp=7, seed=77)

    # Sub-regions inside board (`0..1039, 0..780`):
    # Left panel (`0..340`):
    #   Header: `0..86`
    #   Paperdoll stage: `86..430` (smoked xuan + faint Bagua watermark behind bust!)
    #   Backpack strip: `430..520`
    #   Stats planks: `520..780`
    # Right panel (`340..1039`):
    #   Top tab plaque bar: `0..40`
    #   Upper module (`Perks/Stash`): `40..518`
    #   Roster tray: `524..780`
    p_stage = generate_smoked_xuan_paper(332, 340, base_rgb=(28, 22, 17), seed=301)
    # Subtle watermark of the Bagua compass behind the character bust
    wm = fit_box(compass_ring, 210, 210, pad=0)
    wm_a = wm.getchannel("A").point(lambda a: int(a * 0.14))
    wm_faint = Image.merge("RGBA", (*wm.convert("RGB").split(), wm_a))
    p_stage.alpha_composite(wm_faint, ((332 - 210) // 2, 58))
    board.alpha_composite(p_stage, (4, 88))

    # Right upper Xuan-paper recess (`344..1035, 42..516`)
    r_upper = generate_smoked_xuan_paper(691, 474, base_rgb=(22, 17, 13), seed=509)
    board.alpha_composite(r_upper, (344, 42))

    # Top header lacquer strips
    hdr_l = generate_ebony_wood(332, 82, base_rgb=(38, 20, 16), grain_amp=5, seed=11)
    hdr_r = generate_ebony_wood(691, 38, base_rgb=(36, 22, 17), grain_amp=5, seed=12)
    board.alpha_composite(hdr_l, (4, 4))
    board.alpha_composite(hdr_r, (344, 4))

    bdr = ImageDraw.Draw(board)
    # Structural bronze dividers
    bronze_line = (128, 98, 55, 235)
    dark_line = (10, 7, 5, 255)

    def hline(x_a, x_b, y):
        bdr.line([(x_a, y - 1), (x_b, y - 1)], fill=dark_line, width=1)
        bdr.line([(x_a, y), (x_b, y)], fill=bronze_line, width=2)
        bdr.line([(x_a, y + 2), (x_b, y + 2)], fill=dark_line, width=1)

    def vline(x, y_a, y_b):
        bdr.line([(x - 1, y_a), (x - 1, y_b)], fill=dark_line, width=1)
        bdr.line([(x, y_a), (x, y_b)], fill=bronze_line, width=2)
        bdr.line([(x + 2, y_a), (x + 2, y_b)], fill=dark_line, width=1)

    vline(340, 2, bh - 3)       # Left / Right column split
    hline(3, 338, 86)           # Left header bottom
    hline(3, 338, 430)          # Paperdoll bottom / Backpack top
    hline(3, 338, 520)          # Backpack bottom / Stats top
    hline(342, bw - 4, 40)      # Right header tabs bottom
    hline(342, bw - 4, 520)     # Right upper panel / Roster list split

    # Grand outer bronze frame + Huiwen corners on both left & right sections
    draw_ming_bronze_frame(board, (0, 0, bw - 1, bh - 1), corner_size=32)
    draw_bronze_meander_corner(bdr, 346, 46, 22, False, False, (166, 130, 74, 210))
    draw_bronze_meander_corner(bdr, bw - 7, 46, 22, True, False, (166, 130, 74, 210))
    draw_bronze_meander_corner(bdr, 346, 526, 20, False, False, (150, 116, 66, 195))
    draw_bronze_meander_corner(bdr, bw - 7, 526, 20, True, False, (150, 116, 66, 195))

    canvas.alpha_composite(board, (bx0, by0))
    return canvas


def build_dialog_panel(w: int, h: int, is_scroll: bool = False) -> Image.Image:
    """Builds 800x720 event scroll / 1024x768 grand dialog / 600x300 & 449x250 popups."""
    if is_scroll:
        im = generate_smoked_xuan_paper(w, h, base_rgb=(27, 21, 16), seed=w * 3 + h)
    else:
        im = generate_ebony_wood(w, h, base_rgb=(24, 18, 14), grain_amp=7, seed=w * 5 + h)

    # Header band (`0..80` for large dialogs)
    if h >= 500:
        hdr = generate_ebony_wood(w - 8, 76, base_rgb=(36, 20, 16), grain_amp=5, seed=99)
        im.alpha_composite(hdr, (4, 4))
        dr = ImageDraw.Draw(im)
        dr.line([(4, 80), (w - 5, 80)], fill=(138, 106, 58, 240), width=2)
        dr.line([(4, 82), (w - 5, 82)], fill=(10, 7, 5, 255), width=1)
        # Footer divider (`h - 62`)
        dr.line([(4, h - 62), (w - 5, h - 62)], fill=(10, 7, 5, 255), width=1)
        dr.line([(4, h - 60), (w - 5, h - 60)], fill=(124, 94, 52, 225), width=2)

    csize = 34 if w >= 800 else 20
    draw_ming_bronze_frame(im, (0, 0, w - 1, h - 1), corner_size=csize)
    return im


def build_main_menu_banner_and_logo(compass_ring: Image.Image, seal_cinnabar: Image.Image):
    """Builds `wx_main_menu_banner.png` (245x595) and `wx_main_menu_logo.png` (400x350)."""
    # 1. Banner (245 x 595): Dark crimson-ebony war banner with tattered bottom swallowtails & bronze top rod
    bw, bh = 245, 595
    banner = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
    body = generate_smoked_xuan_paper(221, 560, base_rgb=(34, 16, 14), seed=888)
    bdr = ImageDraw.Draw(body)
    # Gilded vertical side borders
    bdr.rectangle([6, 6, 214, 553], outline=(154, 118, 62, 210), width=2)
    bdr.rectangle([10, 10, 210, 549], outline=(86, 58, 32, 160), width=1)

    # Tattered swallowtail alpha mask at bottom
    mask = Image.new("L", (221, 560), 255)
    mdr = ImageDraw.Draw(mask)
    rng = random.Random(2026)
    for x in range(221):
        # Swallowtail V-cut + ragged battle tears
        dist_center = abs(x - 110.5) / 110.5
        cut_h = int(38 * (1.0 - dist_center * 0.75) + rng.randint(0, 18))
        for y in range(560 - cut_h, 560):
            fade = max(0, 255 - (y - (560 - cut_h)) * 18)
            mdr.point((x, y), fill=fade)
    body.putalpha(mask)
    banner.alpha_composite(body, (12, 18))

    # Top horizontal bronze-capped spear crossbar (`0..245, 4..20`)
    rod = ImageDraw.Draw(banner)
    rod.rounded_rectangle([2, 6, bw - 3, 18], radius=5, fill=(38, 28, 20, 255), outline=(168, 130, 72, 255), width=2)
    for rx in (24, 78, 166, 220):
        rod.rectangle([rx - 5, 4, rx + 5, 22], fill=(124, 32, 24, 255), outline=(188, 146, 80, 255), width=1)
    banner.save(os.path.join(WX_SKIN_DIR, "wx_main_menu_banner.png"))

    # 2. Main Menu Title Crest (`wx_main_menu_logo.png`, 400 x 350)
    lw, lh = 400, 350
    logo = Image.new("RGBA", (lw, lh), (0, 0, 0, 0))

    # Soft dark radial backing aura so title pops against any background
    aura = Image.new("RGBA", (lw, lh), (0, 0, 0, 0))
    adr = ImageDraw.Draw(aura)
    adr.ellipse([28, 18, lw - 28, lh - 24], fill=(10, 7, 6, 185))
    aura = aura.filter(ImageFilter.GaussianBlur(radius=22))
    logo.alpha_composite(aura)

    # Composite circular-masked `wx_crest_xuanniao.png` inside Bagua bronze ring (zero square box!)
    ring_lg = fit_box(compass_ring, 206, 206, pad=0)
    crest_src = os.path.join(ROOT, "art", "hd", "wx_crest_xuanniao.png")
    if os.path.exists(crest_src):
        raw_c = Image.open(crest_src).convert("RGBA").resize((176, 176), Image.Resampling.LANCZOS)
        cmask = Image.new("L", (176, 176), 0)
        cmdr = ImageDraw.Draw(cmask)
        cmdr.ellipse([14, 14, 162, 162], fill=255)
        cmask = cmask.filter(ImageFilter.GaussianBlur(radius=4))
        raw_c.putalpha(cmask)
        logo.alpha_composite(raw_c, ((lw - 176) // 2, 19))
    logo.alpha_composite(ring_lg, ((lw - 206) // 2, 4))

    # Render sharp Ming-serif gilded title plaque: 《武侠江湖》 + subtitle `BATTLE BROTHERS · WUXIA`
    if os.path.exists(FONT_PATH):
        f_main = ImageFont.truetype(FONT_PATH, 54)
        f_sub = ImageFont.truetype(FONT_PATH, 18)
        f_seal = ImageFont.truetype(FONT_PATH, 14)

        txt_layer = Image.new("RGBA", (lw, lh), (0, 0, 0, 0))
        tdr = ImageDraw.Draw(txt_layer)

        title_str = "武侠江湖"
        bb = tdr.textbbox((0, 0), title_str, font=f_main)
        tw = bb[2] - bb[0]
        tx = (lw - tw) // 2 - 10
        ty = 198

        # Deep ink drop shadow + crimson-bronze stroke
        for ox, oy in ((-3, 3), (3, 3), (0, 4), (-2, -2), (2, -2)):
            tdr.text((tx + ox, ty + oy), title_str, font=f_main, fill=(8, 5, 4, 245))
        for ox, oy in ((-1, 1), (1, 1), (0, 2)):
            tdr.text((tx + ox, ty + oy), title_str, font=f_main, fill=(118, 42, 22, 230))
        tdr.text((tx, ty), title_str, font=f_main, fill=(244, 206, 122, 255))

        # Cinnabar red seal next to title
        seal_sm = fit_box(seal_cinnabar, 34, 34, pad=0)
        txt_layer.alpha_composite(seal_sm, (tx + tw + 8, ty + 18))

        # Ornamental divider lines + subtitle
        sub_str = "战 场 兄 弟  ·  山 海 武 林 总 改"
        sbb = tdr.textbbox((0, 0), sub_str, font=f_sub)
        sw = sbb[2] - sbb[0]
        sx = (lw - sw) // 2
        sy = 274
        tdr.line([(36, sy - 6), (lw - 36, sy - 6)], fill=(168, 130, 72, 190), width=1)
        tdr.text((sx + 1, sy + 2), sub_str, font=f_sub, fill=(8, 5, 4, 235))
        tdr.text((sx, sy), sub_str, font=f_sub, fill=(214, 194, 158, 245))
        logo.alpha_composite(txt_layer)

    logo.save(os.path.join(WX_SKIN_DIR, "wx_main_menu_logo.png"))


def main():
    os.makedirs(ART_SHEETS, exist_ok=True)
    os.makedirs(WX_ICONS_DIR, exist_ok=True)
    os.makedirs(WX_SKIN_DIR, exist_ok=True)

    # Copy raw AI sheets from brain dir into `art/sheets/` for reproducible repo builds
    for dst_name, src_name in RAW_SOURCES.items():
        src_p = os.path.join(BRAIN_DIR, src_name)
        dst_p = os.path.join(ART_SHEETS, dst_name)
        if os.path.exists(src_p):
            shutil.copy2(src_p, dst_p)
        if not os.path.exists(dst_p):
            raise FileNotFoundError(f"Missing required UI art source: {dst_p}")

    sh_a = Image.open(os.path.join(ART_SHEETS, "wx_ui_sheet_a.jpg"))
    sh_b = Image.open(os.path.join(ART_SHEETS, "wx_ui_sheet_b.jpg"))
    sh_statues = Image.open(os.path.join(ART_SHEETS, "wx_ui_guardian_statues.jpg"))
    sh_banner = Image.open(os.path.join(ART_SHEETS, "wx_ui_header_banner.jpg"))

    def cell(sh, r, c, seed_center=False):
        cw, ch = sh.width // 4, sh.height // 4
        crop = sh.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))
        return flood_clean_white(crop, seed_center=seed_center)

    # 1. Extract Sheet A icons
    sheet_a_targets = [
        (0, 0, "wx_icon_health.png",      (30, 30), 1),
        (0, 1, "wx_icon_qi.png",          (30, 30), 1),
        (0, 2, "wx_icon_bravery.png",     (30, 30), 1),
        (0, 3, "wx_icon_initiative.png",  (30, 30), 1),
        (1, 0, "wx_icon_melee_skill.png", (30, 30), 1),
        (1, 1, "wx_icon_ranged_skill.png",(30, 30), 1),
        (1, 2, "wx_icon_melee_def.png",   (30, 30), 1),
        (1, 3, "wx_icon_ranged_def.png",  (30, 30), 1),
        (2, 0, "wx_asset_money.png",      (40, 40), 2),
        (2, 1, "wx_asset_food.png",       (40, 40), 2),
        (2, 2, "wx_asset_supplies.png",   (40, 40), 2),
        (2, 3, "wx_asset_ammo.png",       (40, 40), 2),
        (3, 0, "wx_asset_medicine.png",   (40, 40), 2),
        (3, 1, "wx_glyph_mirror.png",     (36, 36), 1),
        (3, 2, "wx_glyph_lock.png",       (34, 43), 2),
        (3, 3, "wx_glyph_sect_token.png", (40, 40), 2),
    ]
    extracted_a = {}
    for r, c, fn, (tw, th), pad in sheet_a_targets:
        rgba = cell(sh_a, r, c)
        extracted_a[(r, c)] = rgba
        fit_box(rgba, tw, th, pad=pad).save(os.path.join(WX_ICONS_DIR, fn))

    # Extra size variants from Sheet A
    fit_box(extracted_a[(2, 0)], 35, 35, pad=1).save(os.path.join(WX_ICONS_DIR, "wx_icon_money.png"))
    fit_box(extracted_a[(2, 0)], 20, 20, pad=1).save(os.path.join(WX_ICONS_DIR, "wx_icon_money_small.png"))
    fit_box(extracted_a[(3, 2)], 28, 28, pad=1).save(os.path.join(WX_ICONS_DIR, "wx_glyph_lock_sm.png"))
    make_slot_silhouette(extracted_a[(2, 3)], 70, 70).save(os.path.join(WX_ICONS_DIR, "wx_slot_ammo.png"))

    # 2. Extract Sheet B icons, paperdoll slot silhouettes, talent stars & Bagua/Sundial rings
    make_slot_silhouette(cell(sh_b, 0, 0), 70, 70).save(os.path.join(WX_ICONS_DIR, "wx_slot_helmet.png"))
    make_slot_silhouette(cell(sh_b, 0, 1), 70, 140).save(os.path.join(WX_ICONS_DIR, "wx_slot_body.png"))
    make_slot_silhouette(cell(sh_b, 0, 2), 70, 140).save(os.path.join(WX_ICONS_DIR, "wx_slot_mainhand.png"))
    make_slot_silhouette(cell(sh_b, 0, 3), 70, 140).save(os.path.join(WX_ICONS_DIR, "wx_slot_offhand.png"))
    make_slot_silhouette(cell(sh_b, 1, 0), 70, 70).save(os.path.join(WX_ICONS_DIR, "wx_slot_accessory.png"))
    make_slot_silhouette(cell(sh_b, 1, 1), 70, 70).save(os.path.join(WX_ICONS_DIR, "wx_slot_bag.png"))

    # Empty general inventory slot
    empty_slot = generate_ebony_wood(70, 70, base_rgb=(18, 14, 11), grain_amp=4, seed=70)
    es_dr = ImageDraw.Draw(empty_slot)
    es_dr.rectangle([0, 0, 69, 69], outline=(62, 48, 33, 185), width=1)
    empty_slot.save(os.path.join(WX_ICONS_DIR, "wx_slot_empty.png"))

    fit_box(cell(sh_b, 1, 2), 30, 30, pad=1).save(os.path.join(WX_ICONS_DIR, "wx_icon_ap.png"))
    fit_box(cell(sh_b, 1, 3), 30, 30, pad=1).save(os.path.join(WX_ICONS_DIR, "wx_icon_morale.png"))
    fit_box(cell(sh_b, 2, 0), 30, 30, pad=1).save(os.path.join(WX_ICONS_DIR, "wx_icon_armor_head.png"))
    fit_box(cell(sh_b, 2, 1), 30, 30, pad=1).save(os.path.join(WX_ICONS_DIR, "wx_icon_armor_body.png"))

    camp_im = fit_box(cell(sh_b, 2, 2), 28, 28, pad=1)
    camp_im.save(os.path.join(WX_ICONS_DIR, "wx_icon_camp.png"))
    make_sw(camp_im).save(os.path.join(WX_ICONS_DIR, "wx_icon_camp_sw.png"))

    amb_im = fit_box(cell(sh_b, 2, 3), 26, 28, pad=1)
    amb_im.save(os.path.join(WX_ICONS_DIR, "wx_icon_ambition.png"))
    make_sw(amb_im).save(os.path.join(WX_ICONS_DIR, "wx_icon_ambition_sw.png"))

    seal_raw = cell(sh_b, 3, 0, seed_center=False)
    fit_box(seal_raw, 48, 48, pad=1).save(os.path.join(WX_ICONS_DIR, "wx_seal_cinnabar.png"))

    # Compose 0..3 Acupoint Bone-Root Stars (`wx_talent_0..3.png` at `72x36` 2x crispness -> CSS `3.6rem x 1.8rem`)
    star_raw = cell(sh_b, 3, 1)
    star_one = fit_box(star_raw, 24, 24, pad=0)
    Image.new("RGBA", (72, 36), (0, 0, 0, 0)).save(os.path.join(WX_ICONS_DIR, "wx_talent_0.png"))
    for cnt in (1, 2, 3):
        t_im = Image.new("RGBA", (72, 36), (0, 0, 0, 0))
        for idx in range(cnt):
            t_im.alpha_composite(star_one, (idx * 22, 6))
        t_im.save(os.path.join(WX_ICONS_DIR, f"wx_talent_{cnt}.png"))

    # Bagua Dantian Compass Ring & Sundial Ring (flood-clean center hole too!)
    compass_raw = cell(sh_b, 3, 2, seed_center=True)
    fit_box(compass_raw, 136, 136, pad=2).save(os.path.join(WX_SKIN_DIR, "wx_compass_dantian.png"))
    sundial_raw = cell(sh_b, 3, 3, seed_center=True)
    fit_box(sundial_raw, 88, 88, pad=2).save(os.path.join(WX_SKIN_DIR, "wx_sundial_ring.png"))

    # 3. Extract Left & Right Guardian Statues & Build `wx_background_inventory.png` (1421x906)
    mid_x = sh_statues.width // 2
    statue_l = flood_clean_white(sh_statues.crop((0, 0, mid_x, sh_statues.height)))
    statue_r = flood_clean_white(sh_statues.crop((mid_x, 0, sh_statues.width, sh_statues.height)))
    inv_bg = build_character_screen_frame(statue_l, statue_r, compass_raw)
    inv_bg.save(os.path.join(WX_SKIN_DIR, "wx_background_inventory.png"))

    # 4. Build Dialog & Scroll Panels + Jianghu Event/Town Header Banners
    build_dialog_panel(800, 720, is_scroll=True).save(os.path.join(WX_SKIN_DIR, "wx_dialog_scroll_800x720.png"))
    build_dialog_panel(800, 720, is_scroll=False).save(os.path.join(WX_SKIN_DIR, "wx_dialog_ebony_800x720.png"))
    build_dialog_panel(1024, 768, is_scroll=False).save(os.path.join(WX_SKIN_DIR, "wx_dialog_1024x768.png"))
    build_dialog_panel(600, 300, is_scroll=False).save(os.path.join(WX_SKIN_DIR, "wx_popup_600x300.png"))
    build_dialog_panel(449, 250, is_scroll=False).save(os.path.join(WX_SKIN_DIR, "wx_popup_449x250.png"))

    # Crop central panoramic band from `wx_ui_header_banner.jpg` for Dialog headers
    bw, bh = sh_banner.size
    crop_y0 = int(bh * 0.24)
    crop_y1 = int(bh * 0.66)
    hdr_strip = sh_banner.crop((0, crop_y0, bw, crop_y1)).convert("RGBA")
    hdr_strip.resize((792, 140), Image.Resampling.LANCZOS).save(os.path.join(WX_SKIN_DIR, "wx_header_jianghu.png"))
    hdr_strip.resize((1016, 140), Image.Resampling.LANCZOS).save(os.path.join(WX_SKIN_DIR, "wx_header_jianghu_large.png"))

    # 5. Build Tactical & World HUD Panels
    tac_char = generate_ebony_wood(410, 151, base_rgb=(22, 17, 13), grain_amp=6, seed=410)
    draw_ming_bronze_frame(tac_char, (0, 0, 409, 150), corner_size=18)
    ImageDraw.Draw(tac_char).line([(6, 39), (403, 39)], fill=(134, 102, 56, 210), width=1)
    tac_char.save(os.path.join(WX_SKIN_DIR, "wx_tactical_char_bg.png"))

    tac_turn = generate_smoked_xuan_paper(590, 86, base_rgb=(20, 16, 12), seed=590)
    draw_ming_bronze_frame(tac_turn, (0, 0, 589, 85), corner_size=16)
    tac_turn.save(os.path.join(WX_SKIN_DIR, "wx_tactical_turnbar.png"))

    sk_tile = generate_ebony_wood(42, 47, base_rgb=(20, 15, 12), grain_amp=4, seed=42)
    draw_ming_bronze_frame(sk_tile, (0, 0, 41, 46), corner_size=0)
    sk_tile.save(os.path.join(WX_SKIN_DIR, "wx_tactical_skill_bg.png"))

    hud_l = generate_ebony_wood(446, 90, base_rgb=(24, 18, 13), grain_amp=6, seed=446)
    draw_ming_bronze_frame(hud_l, (0, 0, 445, 89), corner_size=16)
    hud_l.save(os.path.join(WX_SKIN_DIR, "wx_hud_panel_left.png"))

    hud_r = generate_ebony_wood(446, 48, base_rgb=(24, 18, 13), grain_amp=6, seed=447)
    draw_ming_bronze_frame(hud_r, (0, 0, 445, 47), corner_size=12)
    hud_r.save(os.path.join(WX_SKIN_DIR, "wx_hud_panel_right.png"))

    hud_time = generate_ebony_wood(128, 48, base_rgb=(28, 20, 14), grain_amp=5, seed=128)
    draw_ming_bronze_frame(hud_time, (0, 0, 127, 47), corner_size=10)
    hud_time.save(os.path.join(WX_SKIN_DIR, "wx_world_time_panel.png"))

    # 6. Build Lacquer-Bronze Plaque Buttons & Tabs
    for st in ("default", "hover", "pressed", "disabled"):
        build_button(175, 43, st).save(os.path.join(WX_SKIN_DIR, f"wx_btn_01_{st}.png"))
        build_button(230, 43, st).save(os.path.join(WX_SKIN_DIR, f"wx_btn_04_{st}.png"))
        build_button(780, 43, st).save(os.path.join(WX_SKIN_DIR, f"wx_btn_05_{st}.png"))
        build_button(174, 43, st, is_tab=True).save(os.path.join(WX_SKIN_DIR, f"wx_btn_tab_{st}.png"))

    # 7. Build Progressbars (`127x22` & `196x26`)
    for kind in ("empty", "qi", "qi_preview", "hp", "ap", "morale", "armor", "neutral"):
        build_progressbar(127, 22, kind).save(os.path.join(WX_SKIN_DIR, f"wx_bar_{kind}_127.png"))
    build_progressbar(196, 26, "empty").save(os.path.join(WX_SKIN_DIR, "wx_bar_xp_empty.png"))
    build_progressbar(196, 26, "xp").save(os.path.join(WX_SKIN_DIR, "wx_bar_xp_fill.png"))

    # 8. Build Smoked Xuan-Paper Tooltip Scroll (`315x553` & `255x553`)
    for tw in (255, 315):
        tt = generate_smoked_xuan_paper(tw, 553, base_rgb=(20, 16, 12), seed=tw)
        tt_dr = ImageDraw.Draw(tt)
        tt_dr.rectangle([0, 0, tw - 1, 552], outline=(10, 7, 5, 255), width=1)
        tt_dr.rectangle([1, 1, tw - 2, 551], outline=(138, 106, 58, 235), width=2)
        tt_dr.rectangle([4, 4, tw - 5, 548], outline=(48, 36, 24, 190), width=1)
        draw_bronze_meander_corner(tt_dr, 4, 548, 16, False, True, (172, 134, 76, 225))
        draw_bronze_meander_corner(tt_dr, tw - 5, 548, 16, True, True, (172, 134, 76, 225))
        tt.save(os.path.join(WX_SKIN_DIR, f"wx_tooltip_{tw}_bottom.png"))

        top_orn = generate_ebony_wood(tw, 13, base_rgb=(36, 24, 16), grain_amp=4, seed=tw + 1)
        to_dr = ImageDraw.Draw(top_orn)
        to_dr.rectangle([0, 0, tw - 1, 12], outline=(156, 120, 66, 245), width=2)
        top_orn.save(os.path.join(WX_SKIN_DIR, f"wx_tooltip_{tw}_top.png"))

    # 9. Build Main Menu Banner, Title Crest Logo & Wuxia Key-Art Screens
    build_main_menu_banner_and_logo(compass_raw, seal_raw)

    keyframe_names = [
        ("shot_01_heroes.png", "wx_screen_bg_01.jpg"),
        ("shot_02_cultivation.png", "wx_screen_bg_02.jpg"),
        ("shot_03_combat_vfx.png", "wx_screen_bg_03.jpg"),
        ("shot_04_shanhai_bosses.png", "wx_screen_bg_04.jpg"),
    ]
    for src_fn, dst_fn in keyframe_names:
        kp = os.path.join(PROMO_KEYS, src_fn)
        if os.path.exists(kp):
            kim = Image.open(kp).convert("RGB")
            kim.save(os.path.join(WX_SKIN_DIR, dst_fn), "JPEG", quality=88, optimize=True)

    print(f"[WX-UI-SKIN] Generated {len(os.listdir(WX_ICONS_DIR))} icons in wx_icons/ and {len(os.listdir(WX_SKIN_DIR))} skin textures in wx_skin/.")


if __name__ == "__main__":
    main()
