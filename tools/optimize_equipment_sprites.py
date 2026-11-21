#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Comprehensive Wuxia Equipment UI Icon & Paperdoll Sprite Optimizer:
1. Re-extracts dark-background Sheets 19, 20 & 23 without eating wood/steel limbs, and enhances
   bow/crossbow UI icon visibility.
2. Re-extracts white-background Sheet 22 (`wx_wpn_axe_01..08`, `wx_wpn_fist_04..09`, `wx_wpn_flail_01..02`)
   after trimming thick black cell borders so ZERO white background squares or trapped white holes remain.
3. Cleans trapped grey/white background pockets on `wx_relic_shenbinu`, `wx_relic_dashenbian` & `wx_relic_zhentiangong`,
   polishes `wx_fist_wraps/iron/heavy`, Shan Hai red armors (`wx_armor_*`) & `wx_helm_bashe`.
4. Slices & deploys `art/sheets/sheet_ammo_tools_3x3.jpg` -> Wuxia Ammo (`wx_ammo_*`), Offhand Bombs/Flasks
   (`wx_tool_*` 70x140 + 70x70 + `shd_wx_tool_*` offhand brushes), and hand-painted `wx_page_common.png`.
5. Rebuilds all handheld weapon/shield bust layers and recompiles `.brush` atlases.
"""

from collections import deque
import json
import os
import shutil
import sys
from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))

import build_wuxia_bust_system as bsys
import build_stage2_stage3_assets as s23
from compile_wuxia_brushes import compile_all
from wiki_art_expansion_data import EXPANSION_CELLS

ART_DIR = os.path.join(ROOT, "art")
SHEETS_DIR = os.path.join(ART_DIR, "sheets")
HD_DIR = os.path.join(ART_DIR, "hd")
BUSTS_DIR = os.path.join(ART_DIR, "busts")
MOD_ROOT = os.path.join(ROOT, "mod_wuxia")

GEN_AMMO_TOOLS_SRC = r"C:\Users\25647\.gemini\antigravity\brain\b07bb794-2b79-4ab7-8a5c-036ffe9f56c2\wuxia_ammo_tools_3x3_1795188392239.jpg"
AMMO_TOOLS_SHEET = os.path.join(SHEETS_DIR, "sheet_ammo_tools_3x3.jpg")

DARK_BG_SHEETS = {19, 20, 23}


def extract_dark_sheet_cell(cell_img: Image.Image) -> Image.Image:
    im = cell_img.convert("RGB")
    w, h = im.size
    px = im.load()

    margin = 3
    border_samples = []
    for x in range(margin, w - margin):
        border_samples.append(px[x, margin])
        border_samples.append(px[x, h - 1 - margin])
    for y in range(margin, h - margin):
        border_samples.append(px[margin, y])
        border_samples.append(px[w - 1 - margin, y])
    border_samples.sort(key=lambda c: c[0] + c[1] + c[2])
    bg = border_samples[len(border_samples) // 3]

    bg_thresh = 11
    feather = 8

    def dist(c):
        return max(abs(c[0] - bg[0]), abs(c[1] - bg[1]), abs(c[2] - bg[2]))

    vis = bytearray(w * h)
    q = deque()

    def seed(sx, sy):
        idx = sy * w + sx
        if not vis[idx]:
            d = dist(px[sx, sy])
            if d <= bg_thresh + feather:
                vis[idx] = 1 if d <= bg_thresh else 2
                if d <= bg_thresh:
                    q.append((sx, sy))

    for x in range(w):
        for sy in (0, 1, 2, h - 1, h - 2, h - 3):
            seed(x, sy)
    for y in range(h):
        for sx in (0, 1, 2, w - 1, w - 2, w - 3):
            seed(sx, y)

    while q:
        cx, cy = q.popleft()
        for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
            if 0 <= nx < w and 0 <= ny < h:
                nidx = ny * w + nx
                if not vis[nidx]:
                    d = dist(px[nx, ny])
                    if d <= bg_thresh:
                        vis[nidx] = 1
                        q.append((nx, ny))
                    elif d <= bg_thresh + feather:
                        vis[nidx] = 2

    alpha = Image.new("L", (w, h), 255)
    apx = alpha.load()
    for y in range(h):
        row = y * w
        for x in range(w):
            v = vis[row + x]
            if v == 1:
                apx[x, y] = 0
            elif v == 2:
                d = dist(px[x, y])
                apx[x, y] = int(255 * max(0.0, min(1.0, (d - bg_thresh) / float(feather))))

    # Clear enclosed near-black loops (bowstring gap, crossbow frame window, ring pommel hole)
    hvis = bytearray(w * h)
    for y in range(2, h - 2):
        for x in range(2, w - 2):
            idx = y * w + x
            if not hvis[idx] and apx[x, y] > 180 and dist(px[x, y]) <= bg_thresh + 2:
                hvis[idx] = 1
                hq = deque([(x, y)])
                pts = [(x, y)]
                while hq:
                    hx, hy = hq.popleft()
                    for nx, ny in ((hx - 1, hy), (hx + 1, hy), (hx, hy - 1), (hx, hy + 1)):
                        if 1 <= nx < w - 1 and 1 <= ny < h - 1:
                            nidx = ny * w + nx
                            if not hvis[nidx] and apx[nx, ny] > 100 and dist(px[nx, ny]) <= bg_thresh + 4:
                                hvis[nidx] = 1
                                hq.append((nx, ny))
                                pts.append((nx, ny))
                if len(pts) >= 18:
                    for px_x, px_y in pts:
                        apx[px_x, px_y] = 0

    alpha = alpha.filter(ImageFilter.GaussianBlur(0.45))
    rgb_lifted = ImageEnhance.Brightness(im).enhance(1.12)
    rgb_lifted = ImageEnhance.Contrast(rgb_lifted).enhance(1.08)
    rgba = rgb_lifted.convert("RGBA")
    rgba.putalpha(alpha)
    return bsys.tight_crop(rgba, thresh=20)


def extract_white_cell_clean(
    cell_img: Image.Image,
    border_trim: int = 0,
    bg_thresh: int = 28,
    feather: int = 20,
    punch_holes: bool = True,
    hole_min_lum: int = 232,
    allow_grey_vignette: bool = False,
) -> Image.Image:
    """
    Trims any black grid divider border first, flood-removes `#FFFFFF` (and optional smooth neutral
    grey vignette) background from all edges, punches out enclosed background holes, and decontaminates fringes.
    """
    im = cell_img.convert("RGB")
    if border_trim > 0 and im.width > 2 * border_trim + 20:
        im = im.crop((border_trim, border_trim, im.width - border_trim, im.height - border_trim))
    w, h = im.size
    px = im.load()

    def wdist(c):
        if allow_grey_vignette and (max(c) - min(c)) <= 10 and min(c) >= 150:
            # Treat smooth neutral vignette (150..255, low chroma) as background while stopping at dark ink (<140)
            return max(0, 162 - min(c))
        return max(255 - c[0], 255 - c[1], 255 - c[2])

    vis = bytearray(w * h)
    q = deque()

    def seed(sx, sy):
        idx = sy * w + sx
        if not vis[idx]:
            d = wdist(px[sx, sy])
            if d <= bg_thresh + feather:
                vis[idx] = 1 if d <= bg_thresh else 2
                if d <= bg_thresh:
                    q.append((sx, sy))

    for x in range(w):
        for sy in (0, 1, 2, 3, h - 1, h - 2, h - 3, h - 4):
            seed(x, sy)
    for y in range(h):
        for sx in (0, 1, 2, 3, w - 1, w - 2, w - 3, w - 4):
            seed(sx, y)

    while q:
        cx, cy = q.popleft()
        for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
            if 0 <= nx < w and 0 <= ny < h:
                nidx = ny * w + nx
                if not vis[nidx]:
                    d = wdist(px[nx, ny])
                    if d <= bg_thresh:
                        vis[nidx] = 1
                        q.append((nx, ny))
                    elif d <= bg_thresh + feather:
                        vis[nidx] = 2

    alpha = Image.new("L", (w, h), 255)
    apx = alpha.load()
    for y in range(h):
        row = y * w
        for x in range(w):
            v = vis[row + x]
            if v == 1:
                apx[x, y] = 0
            elif v == 2:
                d = wdist(px[x, y])
                apx[x, y] = int(255 * max(0.0, min(1.0, (d - bg_thresh) / float(feather))))

    # Punch out enclosed pure-white / light-grey background holes (between paired gauntlets, inside ring loops, chain gaps, corner wedges)
    if punch_holes:
        hvis = bytearray(w * h)
        for y in range(1, h - 1):
            for x in range(1, w - 1):
                idx = y * w + x
                r0, g0, b0 = px[x, y]
                if not hvis[idx] and apx[x, y] > 100 and min(r0, g0, b0) >= hole_min_lum and (max(r0, g0, b0) - min(r0, g0, b0)) <= 14:
                    hvis[idx] = 1
                    hq = deque([(x, y)])
                    pts = [(x, y)]
                    touches_margin = (x <= 10 or x >= w - 11 or y <= 10 or y >= h - 11)
                    while hq:
                        hx, hy = hq.popleft()
                        if hx <= 10 or hx >= w - 11 or hy <= 10 or hy >= h - 11:
                            touches_margin = True
                        for nx, ny in ((hx - 1, hy), (hx + 1, hy), (hx, hy - 1), (hx, hy + 1)):
                            if 0 <= nx < w and 0 <= ny < h:
                                nidx = ny * w + nx
                                nr, ng, nb = px[nx, ny]
                                if not hvis[nidx] and apx[nx, ny] > 60 and min(nr, ng, nb) >= (hole_min_lum - 14) and (max(nr, ng, nb) - min(nr, ng, nb)) <= 16:
                                    hvis[nidx] = 1
                                    hq.append((nx, ny))
                                    pts.append((nx, ny))
                    if touches_margin or len(pts) >= 14:
                        for px_x, px_y in pts:
                            apx[px_x, px_y] = 0

    alpha = alpha.filter(ImageFilter.GaussianBlur(0.45))
    rgba = im.convert("RGBA")
    rgba.putalpha(alpha)
    rgba = bsys.decontaminate_white_fringe(rgba, passes=2)
    return bsys.tight_crop(rgba, thresh=24)


def fit_ui_icon(rgba: Image.Image, target_w: int, target_h: int, pad: int = 4, thin_outline: bool = False) -> Image.Image:
    im = bsys.tight_crop(rgba.convert("RGBA"), thresh=22)
    mw = max(1, target_w - 2 * pad)
    mh = max(1, target_h - 2 * pad)
    s = min(mw / float(max(1, im.width)), mh / float(max(1, im.height)))
    nw, nh = max(1, int(round(im.width * s))), max(1, int(round(im.height * s)))
    im_s = im.resize((nw, nh), Image.Resampling.LANCZOS)

    out = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    ox = (target_w - nw) // 2
    oy = (target_h - nh) // 2

    if thin_outline:
        # Crisp 1px dark rim for thin bows & crossbows so they stand out in brown inventory slots
        core_a = im_s.getchannel("A").point(lambda v: v if v >= 85 else 0)
        dil = core_a.filter(ImageFilter.MaxFilter(3))
        ol = Image.new("RGBA", (nw, nh), (16, 13, 10, 0))
        ol.putalpha(dil.point(lambda v: min(225, int(v * 0.85))))
        out.alpha_composite(ol, (ox, oy))

    sh_a = im_s.getchannel("A").filter(ImageFilter.GaussianBlur(1.8)).point(lambda a: int(a * 0.58))
    sh = Image.new("RGBA", (nw, nh), (0, 0, 0, 0))
    sh.putalpha(sh_a)
    out.alpha_composite(sh, (min(target_w - nw, ox + 1), min(target_h - nh, oy + 2)))
    out.alpha_composite(im_s, (ox, oy))
    return out


def solidify_and_outline_handheld(im_s: Image.Image, is_fist: bool = False) -> Image.Image:
    w, h = im_s.size
    out = im_s.copy()
    px = out.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 28:
                px[x, y] = (0, 0, 0, 0)
            elif a >= 95:
                na = min(255, int(165 + (a - 95) * (90.0 / 160.0)))
                px[x, y] = (r, g, b, na)

    core_a = out.getchannel("A").point(lambda v: v if v >= 120 else 0)
    dilated = core_a.filter(ImageFilter.MaxFilter(3))
    rim_a = dilated.point(lambda v: min(230, int(v * 0.88)))
    base = Image.new("RGBA", (w + 4, h + 4), (0, 0, 0, 0))
    ol = Image.new("RGBA", (w, h), (18, 15, 13, 0))
    ol.putalpha(rim_a)
    base.alpha_composite(ol, (2, 2))

    if is_fist:
        hl_mask = bsys.bool_subtract(dilated, core_a).filter(ImageFilter.GaussianBlur(0.6))
        hl = Image.new("RGBA", (w, h), (190, 175, 148, 0))
        hl.putalpha(hl_mask.point(lambda v: int(v * 0.28)))
        base.alpha_composite(hl, (1, 1))

    base.alpha_composite(out, (2, 2))
    return base


def build_crisp_weapon_bust_layer(hd_rgba: Image.Image, aid: str, ped_clip: Image.Image, from_white_bg: bool) -> Image.Image:
    W, H = 208, 284
    tc = bsys.tight_crop(hd_rgba, thresh=26)
    if from_white_bg:
        tc = bsys.decontaminate_white_fringe(tc, passes=1)
    im = bsys.bb_grade(s23.orient_weapon_upright_right(tc, aid))

    is_fist = ("fist" in aid or aid in ("wx_relic_qiongqizhao", "wx_relic_longlinzhao", "wx_relic_jingangwan"))
    is_bow_xbow = any(k in aid for k in ("_bow_", "_xbow_", "zhentiangong", "shenbinu"))
    is_gun = any(k in aid for k in ("_gun_", "xunleichong"))
    is_throw = ("throw" in aid or "feidaonang" in aid)
    is_dagger = ("dagger" in aid or aid in ("wx_relic_yuchang", "wx_relic_xufuren"))
    is_long_2h = (
        aid in s23.TWO_HAND_LONG_IDS
        or any(k in aid for k in ("_spear_05", "_spear_06", "_spear_07", "_spear_08", "_pole_", "_staff_", "_hammer_06", "_hammer_07", "_hammer_08", "_axe_06", "_axe_07", "_axe_08"))
    )

    if is_fist:
        max_w, max_h = 92, 86
        cx, cy = 138, 210
    elif is_throw:
        max_w, max_h = 84, 92
        cx, cy = 158, 182
    elif is_bow_xbow:
        max_w, max_h = 98, 156
        cx, cy = 154, 166
    elif is_gun:
        max_w, max_h = 92, 146
        cx, cy = 158, 172
    elif is_dagger:
        max_w, max_h = 78, 110
        cx, cy = 158, 182
    elif is_long_2h:
        max_w, max_h = 98, 198
        cx, cy = 160, 138
    else:
        max_w, max_h = 90, 146
        cx, cy = 160, 164

    s = min(max_w / float(max(1, im.width)), max_h / float(max(1, im.height)))
    nw, nh = max(1, int(round(im.width * s))), max(1, int(round(im.height * s)))
    im_s = im.resize((nw, nh), Image.Resampling.LANCZOS)
    if from_white_bg:
        im_s = bsys.decontaminate_white_fringe(im_s, passes=1)
    im_s = solidify_and_outline_handheld(im_s, is_fist=is_fist)
    nw2, nh2 = im_s.size

    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    px = max(2, min(W - nw2 - 2, cx - nw2 // 2))
    py = max(4, min(258 - nh2, cy - nh2 // 2))
    layer.alpha_composite(im_s, (px, py))

    face_guard = Image.new("L", (W, H), 0)
    ImageDraw.Draw(face_guard).ellipse([94, 88, 140, 154], fill=255)
    face_guard = face_guard.filter(ImageFilter.GaussianBlur(1.2))
    a_ch = bsys.bool_subtract(layer.getchannel("A"), face_guard)
    a_ch = bsys.bool_intersect(a_ch, ped_clip)
    layer.putalpha(a_ch)

    return bsys.bake_self_drop_shadow(layer, dx=-3, dy=3, blur=2.2, alpha_scale=0.52)


def build_offhand_pouch_layer(hd_rgba: Image.Image, ped_clip: Image.Image) -> Image.Image:
    W, H = 208, 284
    tc = bsys.tight_crop(hd_rgba, thresh=24)
    im = bsys.bb_grade(tc)
    max_w, max_h = 64, 74
    s = min(max_w / float(max(1, im.width)), max_h / float(max(1, im.height)))
    nw, nh = max(1, int(round(im.width * s))), max(1, int(round(im.height * s)))
    im_s = solidify_and_outline_handheld(im.resize((nw, nh), Image.Resampling.LANCZOS), is_fist=False)
    nw2, nh2 = im_s.size
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    px = max(8, 62 - nw2 // 2)
    py = max(164, 214 - nh2 // 2)
    layer.alpha_composite(im_s, (px, py))
    layer.putalpha(bsys.bool_intersect(layer.getchannel("A"), ped_clip))
    return bsys.bake_self_drop_shadow(layer, dx=2, dy=3, blur=2.0, alpha_scale=0.52)


def clean_neutral_matte_pockets(hd_path: str, min_size: int = 55, allow_bright_white: bool = False):
    if not os.path.exists(hd_path):
        return None
    im = Image.open(hd_path).convert("RGBA")
    w, h = im.size
    px = im.load()
    vis = bytearray(w * h)
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            idx = y * w + x
            r0, g0, b0, a0 = px[x, y]
            if vis[idx] or a0 <= 120:
                continue
            mn0, mx0 = min(r0, g0, b0), max(r0, g0, b0)
            is_grey = (110 <= mn0 and mx0 <= 152 and (mx0 - mn0) <= 8)
            is_white = (allow_bright_white and mn0 >= 150 and (mx0 - mn0) <= 12)
            if is_grey or is_white:
                vis[idx] = 1
                q = deque([(x, y)])
                pts = [(x, y)]
                while q:
                    qx, qy = q.popleft()
                    for nx, ny in ((qx - 1, qy), (qx + 1, qy), (qx, qy - 1), (qx, qy + 1)):
                        if 0 <= nx < w and 0 <= ny < h:
                            nidx = ny * w + nx
                            nr, ng, nb, na = px[nx, ny]
                            if not vis[nidx] and na > 80:
                                nmn, nmx = min(nr, ng, nb), max(nr, ng, nb)
                                ok_g = (105 <= nmn and nmx <= 160 and (nmx - nmn) <= 10)
                                ok_w = (allow_bright_white and nmn >= 145 and (nmx - nmn) <= 16)
                                if ok_g or ok_w:
                                    vis[nidx] = 1
                                    q.append((nx, ny))
                                    pts.append((nx, ny))
                if len(pts) >= min_size:
                    for px_x, px_y in pts:
                        px[px_x, px_y] = (0, 0, 0, 0)
    if allow_bright_white:
        im = bsys.decontaminate_white_fringe(im, passes=2)
    im.save(hd_path)
    return im


def main():
    ped_clip = s23.make_handheld_pedestal_clip()

    # 1. Re-extract all 48 weapons from dark-background Sheets 19, 20 & 23
    sheets_cache = {}
    for cell in EXPANSION_CELLS:
        sh_no, cell_idx, aid, _stage, _grp, _nm, _sub, _pk, rel_gfx, *_ = cell
        if sh_no not in DARK_BG_SHEETS:
            continue
        if sh_no not in sheets_cache:
            sheets_cache[sh_no] = Image.open(os.path.join(SHEETS_DIR, f"sheet_{sh_no}.jpg")).convert("RGB")
        sh = sheets_cache[sh_no]
        cw, ch = sh.width // 4, sh.height // 4
        r, c = divmod(cell_idx, 4)
        crop = sh.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))
        hd_clean = extract_dark_sheet_cell(crop)
        is_bow_xbow = ("_bow_" in aid or "_xbow_" in aid)
        if is_bow_xbow:
            # Extra wood/steel lift for thin bow & crossbow inventory icons
            r_c, g_c, b_c, a_c = hd_clean.split()
            rgb = Image.merge("RGB", (r_c, g_c, b_c))
            rgb = ImageEnhance.Brightness(rgb).enhance(1.22)
            rgb = ImageEnhance.Contrast(rgb).enhance(1.12)
            hd_clean = Image.merge("RGBA", (*rgb.split(), a_c))
        hd_clean.save(os.path.join(HD_DIR, f"{aid}.png"))

        dst_140 = os.path.join(MOD_ROOT, "gfx", rel_gfx)
        dst_70 = dst_140[:-4] + "_70x70.png"
        os.makedirs(os.path.dirname(dst_140), exist_ok=True)
        fit_ui_icon(hd_clean, 70, 140, pad=3 if is_bow_xbow else 4, thin_outline=is_bow_xbow).save(dst_140)
        fit_ui_icon(hd_clean, 70, 70, pad=2 if is_bow_xbow else 3, thin_outline=is_bow_xbow).save(dst_70)

    # 2. Re-extract ALL 16 weapons/gauntlets/flails from Sheet 22 after trimming thick black grid lines!
    sh22 = Image.open(os.path.join(SHEETS_DIR, "sheet_22.jpg")).convert("RGB")
    cw22, ch22 = sh22.width // 4, sh22.height // 4
    sh22_cnt = 0
    for cell in EXPANSION_CELLS:
        sh_no, cell_idx, aid, _stage, _grp, _nm, _sub, _pk, rel_gfx, *_ = cell
        if sh_no != 22:
            continue
        r, c = divmod(cell_idx, 4)
        crop = sh22.crop((c * cw22, r * ch22, (c + 1) * cw22, (r + 1) * ch22))
        # Bottom row of sheet_22 has a radial neutral-grey (~166..230) vignette background
        is_r3 = (r == 3)
        do_holes = (aid != "wx_wpn_fist_09")
        h_lum = 172 if aid == "wx_wpn_flail_01" else (210 if is_r3 else 232)
        hd_clean = extract_white_cell_clean(
            crop,
            border_trim=8,
            bg_thresh=28,
            feather=18,
            punch_holes=do_holes,
            hole_min_lum=h_lum,
            allow_grey_vignette=is_r3,
        )
        hd_clean.save(os.path.join(HD_DIR, f"{aid}.png"))

        dst_140 = os.path.join(MOD_ROOT, "gfx", rel_gfx)
        dst_70 = dst_140[:-4] + "_70x70.png"
        fit_ui_icon(hd_clean, 70, 140, pad=4).save(dst_140)
        fit_ui_icon(hd_clean, 70, 70, pad=3).save(dst_70)
        sh22_cnt += 1
    print(f"Cleaned all {sh22_cnt} Sheet 22 icons (removed black grid frames & 100% of white background squares/holes).")

    # 3. Clean trapped matte pockets on `wx_relic_shenbinu`, `wx_relic_dashenbian` & `wx_relic_zhentiangong`
    named_dir = os.path.join(MOD_ROOT, "gfx", "ui", "items", "weapons", "named")
    for rid, min_sz, allow_w in [
        ("wx_relic_zhentiangong", 100, False),
        ("wx_relic_shenbinu", 100, False),
        ("wx_relic_dashenbian", 35, True),
    ]:
        cleaned = clean_neutral_matte_pockets(os.path.join(HD_DIR, f"{rid}.png"), min_size=min_sz, allow_bright_white=allow_w)
        if cleaned is not None:
            fit_ui_icon(cleaned, 70, 140, pad=4).save(os.path.join(named_dir, f"{rid}.png"))
            fit_ui_icon(cleaned, 70, 70, pad=3).save(os.path.join(named_dir, f"{rid}_70x70.png"))
    print("Cleaned trapped grey/white background pockets on wx_relic_shenbinu, wx_relic_dashenbian & wx_relic_zhentiangong.")

    # 4. Polish starter/progression Fist Gauntlets (`wx_fist_wraps`, `wx_fist_iron`, `wx_fist_heavy`),
    #    Shan Hai Red Armors (`wx_armor_*`) & `wx_helm_bashe` UI icons
    melee_dir = os.path.join(MOD_ROOT, "gfx", "ui", "items", "weapons", "melee")
    for fid in ("wx_fist_wraps", "wx_fist_iron", "wx_fist_heavy"):
        fp = os.path.join(HD_DIR, f"{fid}.png")
        if os.path.exists(fp):
            fim = Image.open(fp).convert("RGBA")
            fpx = fim.load()
            for y in range(fim.height):
                for x in range(fim.width):
                    r0, g0, b0, a0 = fpx[x, y]
                    if a0 < 48:
                        fpx[x, y] = (0, 0, 0, 0)
            fim = bsys.tight_crop(fim, thresh=48)
            r_c, g_c, b_c, a_c = fim.split()
            rgb = ImageEnhance.Contrast(ImageEnhance.Brightness(Image.merge("RGB", (r_c, g_c, b_c)), ).enhance(1.10)).enhance(1.12)
            fim = Image.merge("RGBA", (*rgb.split(), a_c))
            fit_ui_icon(fim, 70, 140, pad=4, thin_outline=True).save(os.path.join(melee_dir, f"{fid}.png"))
            fit_ui_icon(fim, 70, 70, pad=3, thin_outline=True).save(os.path.join(melee_dir, f"{fid}_70x70.png"))

    armor_dir = os.path.join(MOD_ROOT, "gfx", "ui", "items", "armor")
    for aid in ("wx_armor_feiyi", "wx_armor_jumang", "wx_armor_qiongqi", "wx_armor_zhuyan"):
        ap = os.path.join(HD_DIR, f"{aid}.png")
        if os.path.exists(ap):
            aim = Image.open(ap).convert("RGBA")
            apx = aim.load()
            for y in range(aim.height):
                for x in range(aim.width):
                    r0, g0, b0, a0 = apx[x, y]
                    if a0 < 82:
                        apx[x, y] = (0, 0, 0, 0)
            aim = bsys.tight_crop(aim, thresh=82)
            r_c, g_c, b_c, a_c = aim.split()
            rgb = ImageEnhance.Contrast(ImageEnhance.Brightness(Image.merge("RGB", (r_c, g_c, b_c))).enhance(1.12)).enhance(1.10)
            aim = Image.merge("RGBA", (*rgb.split(), a_c))
            fit_ui_icon(aim, 70, 140, pad=3, thin_outline=True).save(os.path.join(armor_dir, f"{aid}.png"))
            fit_ui_icon(aim, 70, 70, pad=2, thin_outline=True).save(os.path.join(armor_dir, f"{aid}_70x70.png"))

    bashe_hd = os.path.join(HD_DIR, "wx_helm_bashe.png")
    if os.path.exists(bashe_hd):
        bim = bsys.tight_crop(Image.open(bashe_hd).convert("RGBA"), thresh=45)
        r_c, g_c, b_c, a_c = bim.split()
        rgb = ImageEnhance.Contrast(ImageEnhance.Brightness(Image.merge("RGB", (r_c, g_c, b_c))).enhance(1.24)).enhance(1.12)
        bim = Image.merge("RGBA", (*rgb.split(), a_c))
        fit_ui_icon(bim, 70, 70, pad=3, thin_outline=True).save(os.path.join(MOD_ROOT, "gfx", "ui", "items", "helmets", "wx_helm_bashe.png"))

    # 5. Build Throwing Net (`wx_wpn_tool_01`) + Slice 9 New Ammo, Tactical Bombs/Flasks & Common Page Icons!
    tools_dir = os.path.join(MOD_ROOT, "gfx", "ui", "items", "tools")
    ammo_dir = os.path.join(MOD_ROOT, "gfx", "ui", "items", "ammo")
    misc_dir = os.path.join(MOD_ROOT, "gfx", "ui", "items", "misc")
    os.makedirs(tools_dir, exist_ok=True)
    os.makedirs(ammo_dir, exist_ok=True)
    os.makedirs(misc_dir, exist_ok=True)

    tool_hd_p = os.path.join(HD_DIR, "wx_wpn_tool_01.png")
    if os.path.exists(tool_hd_p):
        tool_hd = Image.open(tool_hd_p).convert("RGBA")
        fit_ui_icon(tool_hd, 70, 140, pad=5).save(os.path.join(tools_dir, "wx_wpn_tool_01.png"))
        fit_ui_icon(tool_hd, 70, 70, pad=3).save(os.path.join(tools_dir, "wx_wpn_tool_01_70x70.png"))
        s23.build_shield_bust_layer(tool_hd, ped_clip).save(os.path.join(BUSTS_DIR, "shield", "wx_wpn_tool_01.png"))

    if os.path.exists(GEN_AMMO_TOOLS_SRC) and not os.path.exists(AMMO_TOOLS_SHEET):
        shutil.copy2(GEN_AMMO_TOOLS_SRC, AMMO_TOOLS_SHEET)

    if os.path.exists(AMMO_TOOLS_SHEET):
        sh_at = Image.open(AMMO_TOOLS_SHEET).convert("RGB")
        cw_at, ch_at = sh_at.width // 3, sh_at.height // 3
        grid_specs = [
            (0, 0, "ammo", "wx_ammo_arrows"),
            (0, 1, "ammo", "wx_ammo_bolts"),
            (0, 2, "ammo", "wx_ammo_powder"),
            (1, 0, "tool", "wx_tool_fire_bomb"),
            (1, 1, "tool", "wx_tool_smoke_bomb"),
            (1, 2, "tool", "wx_tool_daze_bomb"),
            (2, 0, "tool", "wx_tool_acid_flask"),
            (2, 1, "tool", "wx_tool_holy_water"),
            (2, 2, "misc", "wx_page_common"),
        ]
        for r, c, kind, item_id in grid_specs:
            crop = sh_at.crop((c * cw_at, r * ch_at, (c + 1) * cw_at, (r + 1) * ch_at))
            hd_rgba = extract_white_cell_clean(
                crop,
                border_trim=4,
                bg_thresh=24,
                feather=18,
                punch_holes=(item_id != "wx_tool_holy_water"),
                hole_min_lum=238,
            )
            hd_rgba = bsys.bb_grade(hd_rgba)
            hd_rgba.save(os.path.join(HD_DIR, f"{item_id}.png"))

            if kind == "ammo":
                fit_ui_icon(hd_rgba, 70, 70, pad=3).save(os.path.join(ammo_dir, f"{item_id}.png"))
            elif kind == "tool":
                fit_ui_icon(hd_rgba, 70, 140, pad=5).save(os.path.join(tools_dir, f"{item_id}.png"))
                fit_ui_icon(hd_rgba, 70, 70, pad=3).save(os.path.join(tools_dir, f"{item_id}_70x70.png"))
                build_offhand_pouch_layer(hd_rgba, ped_clip).save(os.path.join(BUSTS_DIR, "shield", f"{item_id}.png"))
            elif kind == "misc":
                fit_ui_icon(hd_rgba, 70, 70, pad=3).save(os.path.join(misc_dir, f"{item_id}.png"))
        print("Sliced & deployed 3 Wuxia Ammo icons, 5 Tactical Bomb/Flask icons + offhand brushes, and hand-painted wx_page_common.png!")

    # 6. Rebuild all 126 weapon bust layers with clean Sheet 22 & cleaned Relic HD assets
    white_sheet_ids = {
        cell[2] for cell in EXPANSION_CELLS
        if cell[0] in (21, 22, 24) and not cell[2].startswith("wx_shd_")
    }
    manifest = json.load(open(os.path.join(ART_DIR, "manifest.json"), "r", encoding="utf-8"))
    rebuilt = 0
    for a in manifest["assets"]:
        if a["stage"] != "2_weapons":
            continue
        aid = a["id"]
        if aid.startswith(("wx_shd_", "wx_armor_", "wx_helm_", "wx_acc_")):
            continue
        hd_p = os.path.join(HD_DIR, f"{aid}.png")
        if not os.path.exists(hd_p) and a.get("hdPath"):
            hd_p = os.path.join(ROOT, a["hdPath"])
        if not os.path.exists(hd_p):
            continue
        hd_im = Image.open(hd_p).convert("RGBA")
        from_white = (aid in white_sheet_ids)
        layer = build_crisp_weapon_bust_layer(hd_im, aid, ped_clip, from_white_bg=from_white)
        layer.save(os.path.join(BUSTS_DIR, "weapon", f"{aid}.png"))
        rebuilt += 1

    print(f"Rebuilt {rebuilt} crisp handheld weapon layers in art/busts/weapon/.")

    # 7. Recompile all binary .brush atlases into mod_wuxia/brushes/ & mod_wuxia/gfx/
    compile_all()


if __name__ == "__main__":
    main()
