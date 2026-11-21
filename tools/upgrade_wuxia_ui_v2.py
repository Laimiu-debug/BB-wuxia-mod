#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BB Wuxia Mod - UI Visual Upgrade v2 (Scheme A Xuan-Scroll + Vanilla-Format Fidelity)
Fixes:
  1. Guardian Statues (`wx_background_inventory.png`): removes ALL enclosed white holes
     (between boots, sword, dragon coils, halberd crescent & sleeves), eliminates white/grey
     JPEG halos, keeps full unclipped halberd tip, adds 3D Rosewood Scroll Rods + gilded caps
     + crimson silk tassels while 100% preserving vanilla Character Screen compartments
     (including the bottom 18-slot Company Brothers Roster tray!).
  2. Main Menu Logo (`wx_main_menu_logo.png`): removes the murky dark radial smudge box.
  3. Non-boxy Martial Medallions & Close Seal:
     - `wx_slot_dantian.png` (Circular Celadon-Jade Bagua Medallion for Main Neigong)
     - `wx_slot_acupoint.png` (Octagonal Gilded-Bronze Acupoint Medallion for Slots 2..7)
     - `wx_seal_close.png` (Circular Cinnabar Wax Seal Close Button)
     - `wx_xuan_paper_bg.png` (Warm Aged Xuan-Paper `#eae0c8` surface texture)
  4. Town Interior Seamless Grounding (`gfx/ui/settlements/`):
     - Feathers vertical/horizontal hard crop cuts on `wx_ui_center_*` & `wx_ui_houses_*`
     - Adds grounded bluestone stepped courtyard/plaza shading to `wx_bg_*` so shops sit naturally.
"""

import math
import os
import random
from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter, ImageFont, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART_SHEETS = os.path.join(ROOT, "art", "sheets")
MOD_GFX = os.path.join(ROOT, "mod_wuxia", "gfx")
WX_ICONS_DIR = os.path.join(MOD_GFX, "ui", "wx_icons")
WX_SKIN_DIR = os.path.join(MOD_GFX, "ui", "wx_skin")
SET_DIR = os.path.join(MOD_GFX, "ui", "settlements")
FONT_PATH = os.path.join(ROOT, "mod_wuxia", "ui", "mods", "mod_wuxia", "fonts", "wx_ming_serif.ttf")


def clean_statue_alpha(im_rgb: Image.Image) -> Image.Image:
    """
    Cleans BOTH outer white background AND all interior enclosed white holes
    (between boots, cape, dragon coils, halberd shaft & blade) on dark bronze-stone statues,
    then decontaminates edge pixels so zero white/grey fringe remains on dark backgrounds.
    """
    rgba = im_rgb.convert("RGBA")
    w, h = rgba.size
    px = rgba.load()

    # Step 1: Compute continuous alpha based on distance from neutral white studio backdrop.
    # Dark stone/bronze statues have either low luminance OR warm bronze chroma.
    alpha = Image.new("L", (w, h), 255)
    apx = alpha.load()
    for y in range(h):
        for x in range(w):
            r, g, b, _ = px[x, y]
            mn = min(r, g, b)
            mx = max(r, g, b)
            chroma = mx - mn
            lum = (r * 299 + g * 587 + b * 114) // 1000
            # Pure/near neutral white background (including enclosed interior pockets!)
            if lum >= 224 and chroma <= 22:
                apx[x, y] = 0
            elif lum >= 182 and chroma <= 28:
                # Smooth ramp across anti-aliased ink edge (182 -> 255, 224 -> 0)
                t = (224 - lum) / 42.0
                apx[x, y] = max(0, min(255, int(t * t * 255)))
            else:
                apx[x, y] = 255

    # Step 2: 3x3 minimum filter nudge + slight blur to shave 1px JPEG fringe cleanly
    eroded = alpha.filter(ImageFilter.MinFilter(3))
    blended_a = ImageChops.lighter(
        eroded,
        alpha.point(lambda a: int(a * 0.65) if a < 245 else 255),
    )
    # Remove tiny isolated dust specks
    soft_a = blended_a.filter(ImageFilter.GaussianBlur(0.6))
    spx = soft_a.load()

    # Step 3: Color decontamination — pull any semi-transparent edge pixel RGB toward dark ink (16, 13, 10)
    for y in range(h):
        for x in range(w):
            a = spx[x, y]
            if a <= 14:
                px[x, y] = (0, 0, 0, 0)
            elif a < 245:
                r, g, b, _ = px[x, y]
                k = a / 255.0
                # Remove white contribution: C_true = clamp((C - (1-k)*245) / k)
                nr = max(10, min(r, int((r - (1.0 - k) * 235) / max(0.25, k))))
                ng = max(8, min(g, int((g - (1.0 - k) * 235) / max(0.25, k))))
                nb = max(6, min(b, int((b - (1.0 - k) * 235) / max(0.25, k))))
                px[x, y] = (nr, ng, nb, a)
            else:
                r, g, b, _ = px[x, y]
                px[x, y] = (r, g, b, 255)

    # Tight crop non-zero alpha
    bbox = rgba.getchannel("A").point(lambda a: 255 if a > 10 else 0).getbbox()
    return rgba.crop(bbox) if bbox else rgba


def generate_warm_wood(w: int, h: int, base_rgb=(44, 31, 22), amp=8, seed=77) -> Image.Image:
    """Warm antique rosewood / walnut plank matching vanilla BB Character Screen luminance."""
    rng = random.Random(seed)
    gw, gh = max(8, w // 14), max(8, h // 2)
    noise = Image.new("L", (gw, gh))
    npx = noise.load()
    for y in range(gh):
        rb = rng.randint(-10, 10)
        for x in range(gw):
            npx[x, y] = max(0, min(255, 128 + rb + rng.randint(-22, 22)))
    grain = noise.resize((w, h), Image.Resampling.BICUBIC)
    gpx = grain.load()

    out = Image.new("RGBA", (w, h), (*base_rgb, 255))
    opx = out.load()
    for y in range(h):
        vy = abs(y - h * 0.5) / max(1.0, h * 0.5)
        seam = -8 if (y % 48 == 0) else (3 if y % 48 == 1 else 0)
        for x in range(w):
            vx = abs(x - w * 0.5) / max(1.0, w * 0.5)
            vig = int(-9 * (vx * vx * 0.5 + vy * vy * 0.5))
            d = int((gpx[x, y] - 128) * amp / 32.0) + seam + vig
            opx[x, y] = (
                max(0, min(255, base_rgb[0] + d)),
                max(0, min(255, base_rgb[1] + int(d * 0.84))),
                max(0, min(255, base_rgb[2] + int(d * 0.68))),
                255,
            )
    return out


def generate_xuan_paper(w: int, h: int, base_rgb=(234, 223, 198), edge_darken=16, seed=108) -> Image.Image:
    """Warm aged ripe Xuan-paper (`熟宣 #eadfc6`) with subtle mulberry fibers & tea-toned edge patina."""
    rng = random.Random(seed)
    cw, ch = max(8, w // 10), max(8, h // 10)
    cloud = Image.new("L", (cw, ch))
    cpx = cloud.load()
    for y in range(ch):
        for x in range(cw):
            cpx[x, y] = rng.randint(105, 152)
    cloud_lg = cloud.resize((w, h), Image.Resampling.BICUBIC).filter(ImageFilter.GaussianBlur(5))

    fw, fh = max(12, w // 2), max(12, h // 2)
    fiber = Image.new("L", (fw, fh))
    fpx = fiber.load()
    for y in range(fh):
        for x in range(fw):
            fpx[x, y] = rng.randint(118, 138)
    fiber_lg = fiber.resize((w, h), Image.Resampling.BILINEAR)

    out = Image.new("RGBA", (w, h), (*base_rgb, 255))
    opx = out.load()
    cl_px = cloud_lg.load()
    fb_px = fiber_lg.load()
    for y in range(h):
        vy = (y - h * 0.5) / max(1.0, h * 0.5)
        for x in range(w):
            vx = (x - w * 0.5) / max(1.0, w * 0.5)
            dist2 = vx * vx * 0.85 + vy * vy * 0.85
            vig = int(-edge_darken * dist2)
            d = int((cl_px[x, y] - 128) * 0.25 + (fb_px[x, y] - 128) * 0.18) + vig
            opx[x, y] = (
                max(0, min(255, base_rgb[0] + d)),
                max(0, min(255, base_rgb[1] + int(d * 0.92))),
                max(0, min(255, base_rgb[2] + int(d * 0.78))),
                255,
            )
    return out


def draw_scroll_rod_vertical(canvas: Image.Image, cx: int, y_top: int, y_bot: int, rod_r: int = 10):
    """Draws a 3D cylindrical Rosewood Scroll Rod with gilded bronze finials and crimson silk tassel."""
    dr = ImageDraw.Draw(canvas)
    # Soft drop shadow
    sh = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    sdr = ImageDraw.Draw(sh)
    sdr.rounded_rectangle([cx - rod_r - 3, y_top - 18, cx + rod_r + 5, y_bot + 20], radius=8, fill=(0, 0, 0, 175))
    sh = sh.filter(ImageFilter.GaussianBlur(5))
    canvas.alpha_composite(sh)

    # Cylindrical wood shaft with specular highlight
    for dx in range(-rod_r, rod_r + 1):
        nx = dx / float(max(1, rod_r))
        spec = max(0.0, 1.0 - abs(nx + 0.32) * 1.65)
        shade = math.cos(nx * 1.35)
        r = int(26 + 44 * shade + 36 * spec)
        g = int(15 + 24 * shade + 24 * spec)
        b = int(11 + 16 * shade + 14 * spec)
        dr.line([(cx + dx, y_top), (cx + dx, y_bot)], fill=(r, g, b, 255), width=1)
    dr.rectangle([cx - rod_r, y_top, cx + rod_r, y_bot], outline=(14, 9, 6, 255), width=1)

    # Top & Bottom Gilded Bronze Scroll Finials (轴头)
    for cap_y, is_top in ((y_top - 18, True), (y_bot + 2, False)):
        ch = 18
        for dy in range(ch):
            y = cap_y + dy
            if y < 0 or y >= canvas.height:
                continue
            w_cur = rod_r + 3 if (4 <= dy <= 13) else rod_r + 1
            for dx in range(-w_cur, w_cur + 1):
                px_x = cx + dx
                if px_x < 0 or px_x >= canvas.width:
                    continue
                nx = dx / float(max(1, w_cur))
                spec = max(0.0, 1.0 - abs(nx + 0.28) * 1.8)
                shade = max(0.15, math.cos(nx * 1.3))
                r = min(255, int(92 + 108 * shade + 52 * spec))
                g = min(255, int(68 + 82 * shade + 42 * spec))
                b = min(255, int(30 + 38 * shade + 24 * spec))
                canvas.putpixel((px_x, y), (r, g, b, 255))
        dr.rectangle([cx - rod_r - 3, cap_y + 4, cx + rod_r + 3, cap_y + 13], outline=(32, 22, 12, 235), width=1)

    # Crimson silk cord + hanging tassel below top finial (upper outer side)
    t_top = y_top + 95
    dr.line([(cx, y_top + 6), (cx, t_top)], fill=(158, 34, 26, 235), width=2)
    # Gold bead knot
    dr.ellipse([cx - 5, t_top - 4, cx + 5, t_top + 6], fill=(208, 162, 78, 255), outline=(42, 26, 12, 255))
    # Fanning silk threads
    for tx in range(-6, 7, 2):
        dr.line([(cx + tx // 2, t_top + 6), (cx + tx, t_top + 48)], fill=(172, 38, 28, 225), width=2)
    dr.line([(cx - 4, t_top + 12), (cx + 4, t_top + 12)], fill=(216, 172, 86, 240), width=2)


def build_character_screen_v2(statue_l_raw: Image.Image, statue_r_raw: Image.Image, compass_png: Image.Image) -> Image.Image:
    """
    Rebuilds `wx_background_inventory.png` (1421x906):
    - 100% preserves vanilla Character Screen layout compartments (Left Paperdoll/Bag/Stats,
      Right Upper Module, AND Right Bottom 18-Brother Roster Tray!).
    - Crystal-clean statue cutouts (all interior white pockets removed + soft bottom pedestal blend + unclipped halberd!).
    - Protruding 3D Rosewood Scroll Rods with gilded finials & crimson tassels on left/right edges!
    - Warm walnut-rosewood & aged Xuan-wood luminance so ALL vanilla white/gold/green/red text is 100% crisp!
    """
    W, H = 1421, 906
    canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))

    def prep_clean_statue(raw_rgb: Image.Image, max_w: int, max_h: int, flip_x: bool = False) -> Image.Image:
        cut = clean_statue_alpha(raw_rgb)
        if flip_x:
            cut = ImageOps.mirror(cut)
        s = min(max_w / float(cut.width), max_h / float(cut.height))
        nw, nh = max(1, int(round(cut.width * s))), max(1, int(round(cut.height * s)))
        im = cut.resize((nw, nh), Image.Resampling.LANCZOS)

        # Rich antique bronze-stone grading + gentle bottom mist fade so pedestal blends organically
        rgb = ImageEnhance.Brightness(im.convert("RGB")).enhance(0.76)
        rgb = ImageEnhance.Contrast(rgb).enhance(1.08)
        r, g, b = rgb.split()
        a = im.getchannel("A").copy()
        apx = a.load()
        for y in range(nh - 26, nh):
            fade = max(0.0, (nh - y) / 26.0)
            for x in range(nw):
                apx[x, y] = int(apx[x, y] * (0.35 + 0.65 * fade))
        return Image.merge("RGBA", (r, g, b, a))

    # Left General & Right Dragon Monk — positioned completely clear of the scroll rods (`206` & `1251`)!
    sl = prep_clean_statue(statue_l_raw, 198, 825, flip_x=False)
    sr = prep_clean_statue(statue_r_raw, 172, 855, flip_x=False)

    canvas.alpha_composite(sl, (max(2, (196 - sl.width) // 2), H - 6 - sl.height))
    canvas.alpha_composite(sr, (min(W - sr.width - 2, 1258 + max(0, (160 - sr.width) // 2)), H - 6 - sr.height))

    # Main Board (`209..1248, 125..905` -> `1039 x 780`, exact vanilla coordinates!)
    bx0, by0, bx1, by1 = 209, 125, 1248, 905
    bw, bh = bx1 - bx0, by1 - by0

    # Warm walnut-rosewood base matching vanilla BB's medium-warm wood value so vanilla labels pop!
    board = generate_warm_wood(bw, bh, base_rgb=(50, 36, 25), amp=8, seed=77)

    # Paperdoll stage (`4..336, 88..428`): warm recessed dark-tea silk with faint Bagua watermark
    p_stage = generate_warm_wood(332, 340, base_rgb=(38, 28, 20), amp=5, seed=301)
    wm = compass_png.resize((208, 208), Image.Resampling.LANCZOS)
    wm_a = wm.getchannel("A").point(lambda a: int(a * 0.16))
    wm_faint = Image.merge("RGBA", (*wm.convert("RGB").split(), wm_a))
    p_stage.alpha_composite(wm_faint, ((332 - 208) // 2, 62))
    board.alpha_composite(p_stage, (4, 88))

    # Right upper recess (`344..1035, 42..518`): warm dark-walnut recess for Stash grid (while Wuxia tabs overlay warm Xuan scroll!)
    r_upper = generate_warm_wood(691, 476, base_rgb=(36, 26, 19), amp=5, seed=509)
    board.alpha_composite(r_upper, (344, 42))

    # Right bottom Roster Tray (`344..1035, 524..776` -> 18 Company Brothers Slots!):
    # Distinct silk-lined ebony roster tray so brothers' busts stand out sharply!
    r_roster = generate_warm_wood(691, 252, base_rgb=(42, 30, 21), amp=6, seed=612)
    board.alpha_composite(r_roster, (344, 524))

    # Header lacquer bands
    hdr_l = generate_warm_wood(332, 82, base_rgb=(56, 30, 22), amp=5, seed=11)
    hdr_r = generate_warm_wood(691, 38, base_rgb=(54, 30, 22), amp=5, seed=12)
    board.alpha_composite(hdr_l, (4, 4))
    board.alpha_composite(hdr_r, (344, 4))

    # Gilded Bronze Dividers & Huiwen Corners
    bdr = ImageDraw.Draw(board)
    gold_hi = (188, 148, 84, 240)
    gold_mid = (142, 108, 58, 235)
    ink_dark = (16, 11, 8, 255)

    def hline(xa, xb, y):
        bdr.line([(xa, y - 1), (xb, y - 1)], fill=ink_dark, width=1)
        bdr.line([(xa, y), (xb, y)], fill=gold_mid, width=2)
        bdr.line([(xa, y + 2), (xb, y + 2)], fill=ink_dark, width=1)

    def vline(x, ya, yb):
        bdr.line([(x - 1, ya), (x - 1, yb)], fill=ink_dark, width=1)
        bdr.line([(x, ya), (x, yb)], fill=gold_mid, width=2)
        bdr.line([(x + 2, ya), (x + 2, yb)], fill=ink_dark, width=1)

    vline(340, 2, bh - 3)
    hline(3, 338, 86)
    hline(3, 338, 430)
    hline(3, 338, 520)
    hline(342, bw - 4, 40)
    hline(342, bw - 4, 520)

    # Outer gilded trim
    bdr.rectangle([0, 0, bw - 1, bh - 1], outline=ink_dark, width=2)
    bdr.rectangle([2, 2, bw - 3, bh - 3], outline=gold_hi, width=2)
    bdr.rectangle([5, 5, bw - 6, bh - 6], outline=(76, 56, 34, 210), width=1)

    canvas.alpha_composite(board, (bx0, by0))

    # Protruding 3D Rosewood Scroll Rods along Left (`x=205`) and Right (`x=1252`) edges!
    draw_scroll_rod_vertical(canvas, bx0 - 3, by0 + 4, by1 - 22, rod_r=9)
    draw_scroll_rod_vertical(canvas, bx1 + 3, by0 + 4, by1 - 22, rod_r=9)

    return canvas


def build_clean_main_menu_logo(compass_png: Image.Image, seal_png: Image.Image) -> Image.Image:
    """Rebuilds `wx_main_menu_logo.png` WITHOUT the murky grey radial smudge box."""
    lw, lh = 400, 350
    logo = Image.new("RGBA", (lw, lh), (0, 0, 0, 0))

    ring_lg = compass_png.resize((204, 204), Image.Resampling.LANCZOS)
    # Tight drop shadow strictly under the circular medallion (no huge grey fog rectangle!)
    med_sh = Image.new("RGBA", (lw, lh), (0, 0, 0, 0))
    msd = ImageDraw.Draw(med_sh)
    msd.ellipse([(lw - 196) // 2, 10, (lw + 196) // 2, 206], fill=(0, 0, 0, 185))
    med_sh = med_sh.filter(ImageFilter.GaussianBlur(7))
    logo.alpha_composite(med_sh)

    crest_src = os.path.join(ROOT, "art", "hd", "wx_crest_xuanniao.png")
    if os.path.exists(crest_src):
        raw_c = Image.open(crest_src).convert("RGBA").resize((174, 174), Image.Resampling.LANCZOS)
        cmask = Image.new("L", (174, 174), 0)
        ImageDraw.Draw(cmask).ellipse([12, 12, 162, 162], fill=255)
        cmask = cmask.filter(ImageFilter.GaussianBlur(3))
        raw_c.putalpha(cmask)
        logo.alpha_composite(raw_c, ((lw - 174) // 2, 20))
    logo.alpha_composite(ring_lg, ((lw - 204) // 2, 5))

    if os.path.exists(FONT_PATH):
        f_main = ImageFont.truetype(FONT_PATH, 54)
        f_sub = ImageFont.truetype(FONT_PATH, 18)
        txt = Image.new("RGBA", (lw, lh), (0, 0, 0, 0))
        tdr = ImageDraw.Draw(txt)

        title_str = "山海武侠"
        bb = tdr.textbbox((0, 0), title_str, font=f_main)
        tw = bb[2] - bb[0]
        tx = (lw - tw) // 2 - 10
        ty = 198

        # Crisp tight stroke + shadow directly around characters
        for ox, oy in ((-3, 3), (3, 3), (0, 4), (-2, -2), (2, -2), (-3, 0), (3, 0)):
            tdr.text((tx + ox, ty + oy), title_str, font=f_main, fill=(10, 7, 5, 250))
        for ox, oy in ((-1, 1), (1, 1), (0, 2)):
            tdr.text((tx + ox, ty + oy), title_str, font=f_main, fill=(124, 40, 20, 240))
        tdr.text((tx, ty), title_str, font=f_main, fill=(248, 214, 132, 255))

        seal_sm = seal_png.resize((34, 34), Image.Resampling.LANCZOS)
        txt.alpha_composite(seal_sm, (tx + tw + 8, ty + 18))

        sub_str = "九 州 风 云  ·  奇 经 百 派"
        sbb = tdr.textbbox((0, 0), sub_str, font=f_sub)
        sw = sbb[2] - sbb[0]
        sx = (lw - sw) // 2
        sy = 274
        tdr.line([(42, sy - 6), (lw - 42, sy - 6)], fill=(196, 154, 84, 225), width=2)
        for ox, oy in ((-2, 2), (2, 2), (0, 2), (-1, -1), (1, -1)):
            tdr.text((sx + ox, sy + oy), sub_str, font=f_sub, fill=(8, 6, 4, 245))
        tdr.text((sx, sy), sub_str, font=f_sub, fill=(240, 224, 190, 255))
        logo.alpha_composite(txt)

    return logo


def build_non_boxy_medallions_and_seals(compass_png: Image.Image):
    """Generates non-rectangular Jade Bagua Dantian, Octagonal Bronze Acupoint, Cloud Tab, & Cinnabar Close Seal."""
    # 1. `wx_slot_dantian.png` (96x96): Celadon-Jade Bagua Medallion
    sz = 96
    dan = Image.new("RGBA", (sz, sz), (0, 0, 0, 0))
    dr = ImageDraw.Draw(dan)
    dr.ellipse([3, 3, sz - 4, sz - 4], fill=(42, 68, 58, 245), outline=(176, 142, 78, 255), width=3)
    dr.ellipse([8, 8, sz - 9, sz - 9], fill=(28, 46, 40, 250), outline=(112, 168, 144, 210), width=2)
    comp_fit = compass_png.resize((88, 88), Image.Resampling.LANCZOS)
    # Tint compass subtly jade-gold
    dan.alpha_composite(comp_fit, (4, 4))
    dr.ellipse([20, 20, sz - 21, sz - 21], fill=(26, 36, 32, 228), outline=(186, 152, 86, 220), width=1)
    dan.save(os.path.join(WX_SKIN_DIR, "wx_slot_dantian.png"))

    # 2. `wx_slot_acupoint.png` (84x84): Octagonal Antique Bronze Acupoint Plate (non-square!)
    asz = 84
    acu = Image.new("RGBA", (asz, asz), (0, 0, 0, 0))
    adr = ImageDraw.Draw(acu)
    c = 19
    oct_outer = [(c, 2), (asz - 1 - c, 2), (asz - 3, c), (asz - 3, asz - 1 - c),
                 (asz - 1 - c, asz - 3), (c, asz - 3), (2, asz - 1 - c), (2, c)]
    c2 = 21
    oct_inner = [(c2, 6), (asz - 1 - c2, 6), (asz - 7, c2), (asz - 7, asz - 1 - c2),
                 (asz - 1 - c2, asz - 7), (c2, asz - 7), (6, asz - 1 - c2), (6, c2)]
    adr.polygon(oct_outer, fill=(58, 43, 28, 250), outline=(32, 22, 14, 255))
    adr.line(oct_outer + [oct_outer[0]], fill=(178, 138, 76, 250), width=2)
    adr.polygon(oct_inner, fill=(32, 24, 17, 248))
    adr.line(oct_inner + [oct_inner[0]], fill=(124, 96, 54, 210), width=1)
    acu.save(os.path.join(WX_SKIN_DIR, "wx_slot_acupoint.png"))

    # 3. `wx_seal_close.png` (48x48): Circular Cinnabar Wax/Lacquer Close Seal
    csz = 48
    seal = Image.new("RGBA", (csz, csz), (0, 0, 0, 0))
    sdr = ImageDraw.Draw(seal)
    sdr.ellipse([2, 2, csz - 3, csz - 3], fill=(156, 30, 22, 252), outline=(44, 12, 8, 255), width=2)
    sdr.ellipse([5, 5, csz - 6, csz - 6], fill=(176, 38, 28, 255), outline=(232, 184, 106, 235), width=2)
    # Crisp gold-cream '×' glyph
    sdr.line([(16, 16), (csz - 17, csz - 17)], fill=(255, 238, 208, 255), width=3)
    sdr.line([(csz - 17, 16), (16, csz - 17)], fill=(255, 238, 208, 255), width=3)
    seal.save(os.path.join(WX_SKIN_DIR, "wx_seal_close.png"))

    # 4. `wx_xuan_paper_bg.png` (512x384): Warm Aged Ripe Xuan-Paper Surface (`#eadfc6`)
    xuan = generate_xuan_paper(512, 384, base_rgb=(235, 224, 199), edge_darken=14, seed=2026)
    xuan.save(os.path.join(WX_SKIN_DIR, "wx_xuan_paper_bg.png"))

    # 5. Cloud-notched Tab Plaques (`wx_btn_tab_*.png`, 174x43 with transparent chamfered top corners!)
    for st, (rgb_base, hi_col) in (
        ("default",  ((52, 36, 24), (168, 130, 72, 240))),
        ("hover",    ((86, 34, 24), (232, 188, 106, 255))),
        ("pressed",  ((68, 26, 18), (196, 152, 82, 250))),
        ("disabled", ((36, 31, 27), (96, 84, 70, 190))),
    ):
        tw, th = 174, 43
        wood = generate_warm_wood(tw, th, base_rgb=rgb_base, amp=5, seed=tw + len(st))
        mask = Image.new("L", (tw, th), 0)
        mdr = ImageDraw.Draw(mask)
        chf = 10
        poly = [(chf, 2), (tw - 1 - chf, 2), (tw - 2, chf + 2), (tw - 2, th - 2),
                (tw - 6, th - 2), (5, th - 2), (2, th - 2), (2, chf + 2)]
        mdr.polygon(poly, fill=255)
        wood.putalpha(mask)
        tdr = ImageDraw.Draw(wood)
        tdr.line(poly + [poly[0]], fill=(18, 12, 8, 255), width=2)
        inner = [(chf + 2, 5), (tw - 3 - chf, 5), (tw - 5, chf + 4), (tw - 5, th - 5), (5, th - 5), (5, chf + 4)]
        tdr.line(inner + [inner[0]], fill=hi_col, width=1)
        wood.save(os.path.join(WX_SKIN_DIR, f"wx_btn_tab_{st}.png"))


def polish_town_settlement_layers():
    """
    Eliminates vertical/horizontal knife-cut edges on `wx_ui_center_*.png` & `wx_ui_houses_*.png`,
    and adds a grounded bluestone stepped town plaza onto `wx_bg_*.jpg` so all 6 clickable shops
    sit naturally on a continuous town courtyard instead of floating in mid-air.
    """
    if not os.path.isdir(SET_DIR):
        return

    # 1. Feather hard cut edges on `wx_ui_center_*.png` and `wx_ui_houses_*.png`
    for fn in sorted(os.listdir(SET_DIR)):
        if not fn.endswith(".png"):
            continue
        if not (fn.startswith("wx_ui_center_") or fn.startswith("wx_ui_houses_")):
            continue
        p = os.path.join(SET_DIR, fn)
        im = Image.open(p).convert("RGBA")
        w, h = im.size  # 1024 x 588
        r, g, b, a = im.split()
        bbox = a.point(lambda v: 255 if v > 8 else 0).getbbox()
        if not bbox:
            continue
        x0, y0, x1, y1 = bbox
        apx = a.load()

        is_left = "_left" in fn
        is_right = "_right" in fn
        is_center = fn.startswith("wx_ui_center_")

        fade_w = 44 if is_center else 52
        fade_bot = 34

        for y in range(y0, y1):
            # Soft bottom blend into town ground
            by_k = 1.0
            if y > y1 - fade_bot:
                by_k = max(0.0, (y1 - y) / float(fade_bot))

            for x in range(x0, x1):
                cur_a = apx[x, y]
                if cur_a == 0:
                    continue
                kx = 1.0
                if is_center:
                    if x < x0 + fade_w:
                        kx = min(kx, (x - x0) / float(fade_w))
                    if x > x1 - fade_w:
                        kx = min(kx, (x1 - x) / float(fade_w))
                elif is_left:
                    # Keep outer left edge solid, softly feather right inner cut edge (`x1`)
                    if x > x1 - fade_w:
                        kx = min(kx, (x1 - x) / float(fade_w))
                elif is_right:
                    # Softly feather left inner cut edge (`x0`), keep outer right edge solid
                    if x < x0 + fade_w:
                        kx = min(kx, (x - x0) / float(fade_w))

                k = kx * by_k
                if k < 0.999:
                    # Smoothstep curve for natural mist dissolve
                    ks = k * k * (3.0 - 2.0 * k)
                    apx[x, y] = int(cur_a * ks)

        out = Image.merge("RGBA", (r, g, b, a))
        out.save(p)

    # 2. Ground `wx_bg_*.jpg` (`1024x588`) with an atmospheric bluestone courtyard/terrace foundation (`y=275..588`)
    #    Use idempotent backup `art/sheets/sheet_62.jpg` & `sheet_63.jpg` if present, or subtle earth-stone terrace overlay
    bg_files = [f for f in sorted(os.listdir(SET_DIR)) if f.startswith("wx_bg_") and f.endswith(".jpg")]
    for fn in bg_files:
        p = os.path.join(SET_DIR, fn)
        im = Image.open(p).convert("RGBA")
        w, h = im.size
        is_night = "_night" in fn
        is_snow = "snow" in fn
        is_desert = "desert" in fn

        terrace = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        tdr = ImageDraw.Draw(terrace)

        if is_night:
            stone_col = (28, 32, 38)
            step_hi = (52, 58, 68)
        elif is_snow:
            stone_col = (146, 152, 158)
            step_hi = (188, 194, 202)
        elif is_desert:
            stone_col = (148, 124, 92)
            step_hi = (178, 152, 116)
        else:
            stone_col = (96, 92, 82)
            step_hi = (126, 120, 108)

        # Gentle perspective stone-flagged town plaza & central stepped avenue (`y=290..588`)
        for y in range(285, h):
            t = (y - 285) / float(h - 285)
            alpha_row = int(175 * (t ** 1.35))
            tdr.line([(0, y), (w - 1, y)], fill=(*stone_col, alpha_row), width=1)
            # Subtle horizontal stone step courses every ~22px
            if y > 320 and (y % 22 == 0):
                half_road = int(110 + 260 * t)
                cx = w // 2
                tdr.line([(cx - half_road, y), (cx + half_road, y)], fill=(*step_hi, int(alpha_row * 0.65)), width=1)
                tdr.line([(cx - half_road, y + 1), (cx + half_road, y + 1)], fill=(18, 15, 12, int(alpha_row * 0.55)), width=1)

        terrace = terrace.filter(ImageFilter.GaussianBlur(0.8))
        # Blend gently (only if not already grounded — check marker file)
        marker = os.path.join(ART_SHEETS, ".wx_plaza_v2_done")
        if not os.path.exists(marker):
            im.alpha_composite(terrace)
            im.convert("RGB").save(p, "JPEG", quality=90, optimize=True)

    # 3. Build `wx_ui_ramp_stone` (+ `_night`, `_snow`, `_snow_night`, 1024x588) for `settlement.m.UIRamp`
    for suf, (base_c, step_hi, step_lo, wall_c) in (
        ("",           ((116, 110, 98), (154, 147, 132), (56, 50, 42), (92, 86, 76))),
        ("_night",     ((44, 48, 58),   (68, 74, 88),    (18, 20, 26), (34, 38, 46))),
        ("_snow",      ((186, 192, 200),(222, 228, 236), (98, 106, 116),(142, 148, 158))),
        ("_snow_night",((68, 76, 92),   (98, 108, 128),  (28, 32, 42), (52, 58, 72))),
    ):
        rw, rh = 1024, 588
        ramp = Image.new("RGBA", (rw, rh), (0, 0, 0, 0))
        rdr = ImageDraw.Draw(ramp)
        rng = random.Random(303)
        # Sloped town hill & stone terrace (`y=295..588`)
        for y in range(295, rh):
            t = (y - 295) / float(rh - 295)
            # Crown arch higher in center (`y=295`) and sloping gently down to sides (`y=340`)
            for x in range(rw):
                dx = abs(x - 512) / 512.0
                y_start = 295 + int(42 * (dx ** 1.6))
                if y < y_start:
                    continue
                ty = (y - y_start) / float(max(1, rh - y_start))
                alpha = min(250, int(255 * min(1.0, ty * 3.8)))
                # Central stepped bluestone avenue (`|x - 512| < 95 + 190 * ty`)
                half_ave = int(92 + 195 * ty)
                in_ave = abs(x - 512) <= half_ave
                n = ((x * 13 + y * 7) % 17) - 8
                if in_ave:
                    if (y % 18) == 0:
                        c = step_hi
                    elif (y % 18) == 1:
                        c = step_lo
                    else:
                        joint = -7 if ((x + (y // 18) * 23) % 46 == 0) else 0
                        c = (base_c[0] + n // 2 + joint, base_c[1] + n // 2 + joint, base_c[2] + n // 2 + joint)
                else:
                    c = (wall_c[0] + n // 2, wall_c[1] + n // 2, wall_c[2] + n // 2)
                ramp.putpixel((x, y), (max(0, min(255, c[0])), max(0, min(255, c[1])), max(0, min(255, c[2])), alpha))
        ramp = ramp.filter(ImageFilter.GaussianBlur(0.5))
        ramp.save(os.path.join(SET_DIR, f"wx_ui_ramp_stone{suf}.png"))


def main():
    os.makedirs(WX_SKIN_DIR, exist_ok=True)
    sh_statues = Image.open(os.path.join(ART_SHEETS, "wx_ui_guardian_statues.jpg"))
    compass_png = Image.open(os.path.join(WX_SKIN_DIR, "wx_compass_dantian.png")).convert("RGBA")
    seal_png = Image.open(os.path.join(WX_ICONS_DIR, "wx_seal_cinnabar.png")).convert("RGBA")

    mid_x = sh_statues.width // 2
    raw_l = sh_statues.crop((0, 0, mid_x, sh_statues.height))
    raw_r = sh_statues.crop((mid_x, 0, sh_statues.width, sh_statues.height))

    inv_bg = build_character_screen_v2(raw_l, raw_r, compass_png)
    inv_bg.save(os.path.join(WX_SKIN_DIR, "wx_background_inventory.png"))

    logo = build_clean_main_menu_logo(compass_png, seal_png)
    logo.save(os.path.join(WX_SKIN_DIR, "wx_main_menu_logo.png"))

    build_non_boxy_medallions_and_seals(compass_png)
    polish_town_settlement_layers()

    # Remove `.wx_plaza_v2_done` from mod_wuxia before zip packaging? Keep marker in `art/` instead!
    dot_marker = os.path.join(SET_DIR, ".wx_plaza_v2_done")
    if os.path.exists(dot_marker):
        os.remove(dot_marker)
        with open(os.path.join(ART_SHEETS, ".wx_plaza_v2_done"), "w", encoding="utf-8") as af:
            af.write("ok\n")

    print("[WX-UI-V2] Rebuilt clean statues, scroll Character frame, clean logo, non-boxy medallions & grounded town layers.")


if __name__ == "__main__":
    main()
