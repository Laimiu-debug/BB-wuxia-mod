#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Master Art Asset Processor for BB-wuxia-mod (All 18 Sprite Sheets -> 312/312 Assets):
  - Volume 1 (1_icons):      139 / 139 (Pills, 48 Shan Hai Cores, Blueprint, 20 Books/Pages, 35 Skills+_sw, 9 Statuses+_sw, 20 Medallions+_sw)
  - Volume 2 (2_weapons):     50 /  50 (3 Fist Weapons, 39 Historical/ShanHai Relic Weapons, 8 ShanHai Armors/Helms/Talismans — 70x140 + 70x70!)
  - Volume 3 (3_characters):  16 /  16 (10 Wuxia Robes/Armors, 4 Hats/Crowns/Helms, 2 Enemy Corpse/Yaoren Busts)
  - Volume 4 (4_beasts):     107 / 107 (48 Shan Hai Apex Bosses, 11 Wild Shan Hai Beasts, 48 Shan Hai World Map Lairs across 12 Biome Landmarks)
"""

import json
import os
import re
import shutil
from collections import deque
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageOps
from wiki_art_expansion_data import EXPANSION_CELLS, EXPANSION_FLIP_CELLS, EXPANSION_SHEET_SPECS

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART_DIR = os.path.join(ROOT, "art")
SHEETS_DIR = os.path.join(ART_DIR, "sheets")
HD_DIR = os.path.join(ART_DIR, "hd")
GAME_DIR = os.path.join(ART_DIR, "game")


def ensure_dirs():
    for d in (ART_DIR, SHEETS_DIR, HD_DIR, GAME_DIR):
        os.makedirs(d, exist_ok=True)


def make_grayscale_sw(rgba_img):
    r, g, b, a = rgba_img.split()
    gray = rgba_img.convert("RGB").convert("L")
    gray = ImageEnhance.Brightness(gray).enhance(0.86)
    gray = ImageEnhance.Contrast(gray).enhance(0.92)
    return Image.merge("RGBA", (gray, gray, gray, a))


def trim_grid_border(cell_img, max_trim=10):
    """Trim thin solid black/white grid divider lines around cells (e.g. Sheet 12 / Sheet 16)."""
    im = cell_img.convert("RGB")
    w, h = im.size
    px = im.load()

    def is_uniform_edge_col(x):
        c0 = px[x, h // 2]
        same = sum(1 for y in range(h // 6, 5 * h // 6) if max(abs(px[x, y][0] - c0[0]), abs(px[x, y][1] - c0[1]), abs(px[x, y][2] - c0[2])) < 20)
        return same > (2 * h // 3) * 0.88 and (c0[0] + c0[1] + c0[2] < 45 or c0[0] + c0[1] + c0[2] > 680)

    def is_uniform_edge_row(y):
        c0 = px[w // 2, y]
        same = sum(1 for x in range(w // 6, 5 * w // 6) if max(abs(px[x, y][0] - c0[0]), abs(px[x, y][1] - c0[1]), abs(px[x, y][2] - c0[2])) < 20)
        return same > (2 * w // 3) * 0.88 and (c0[0] + c0[1] + c0[2] < 45 or c0[0] + c0[1] + c0[2] > 680)

    in_c = px[12, h // 2]
    ed_c = px[0, h // 2]
    if abs((in_c[0] + in_c[1] + in_c[2]) - (ed_c[0] + ed_c[1] + ed_c[2])) > 90:
        x0, x1, y0, y1 = 0, w - 1, 0, h - 1
        while x0 < max_trim and is_uniform_edge_col(x0):
            x0 += 1
        while x1 > w - 1 - max_trim and is_uniform_edge_col(x1):
            x1 -= 1
        while y0 < max_trim and is_uniform_edge_row(y0):
            y0 += 1
        while y1 > h - 1 - max_trim and is_uniform_edge_row(y1):
            y1 -= 1
        if x0 > 0 or y0 > 0 or x1 < w - 1 or y1 < h - 1:
            return cell_img.crop((x0 + 1, y0 + 1, x1, y1))
    return cell_img


def flood_extract_rgba(cell_img, bg_thresh=28, feather_band=16, bust_mode=False):
    cell_img = trim_grid_border(cell_img)
    im = cell_img.convert("RGB")
    w, h = im.size
    px = im.load()

    border_vals = []
    for x in range(w):
        border_vals.append(px[x, 0])
        if not bust_mode:
            border_vals.append(px[x, h - 1])
    for y in range(h // 2 if bust_mode else h):
        border_vals.append(px[0, y])
        border_vals.append(px[w - 1, y])
    border_vals.sort(key=lambda c: c[0] + c[1] + c[2])
    bg = border_vals[len(border_vals) // 2]

    def dist(c):
        return max(abs(c[0] - bg[0]), abs(c[1] - bg[1]), abs(c[2] - bg[2]))

    visited = bytearray(w * h)
    q = deque()

    def seed(sx, sy):
        idx = sy * w + sx
        if not visited[idx]:
            d = dist(px[sx, sy])
            if d <= bg_thresh + feather_band:
                visited[idx] = 1 if d <= bg_thresh else 2
                if d <= bg_thresh:
                    q.append((sx, sy))

    for x in range(w):
        seed(x, 0)
        seed(x, 1)
        if not bust_mode:
            seed(x, h - 1)
            seed(x, h - 2)
    for y in range(h):
        seed(0, y)
        seed(1, y)
        seed(w - 1, y)
        seed(w - 2, y)

    while q:
        cx, cy = q.popleft()
        for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
            if 0 <= nx < w and 0 <= ny < h:
                nidx = ny * w + nx
                if not visited[nidx]:
                    d = dist(px[nx, ny])
                    if d <= bg_thresh:
                        visited[nidx] = 1
                        q.append((nx, ny))
                    elif d <= bg_thresh + feather_band:
                        visited[nidx] = 2

    alpha = Image.new("L", (w, h), 255)
    apx = alpha.load()
    for y in range(h):
        row = y * w
        for x in range(w):
            v = visited[row + x]
            if v == 1:
                apx[x, y] = 0
            elif v == 2:
                d = dist(px[x, y])
                apx[x, y] = int(255 * max(0.0, min(1.0, (d - bg_thresh) / float(feather_band))))

    alpha = alpha.filter(ImageFilter.GaussianBlur(radius=0.75))
    rgba = im.convert("RGBA")
    rgba.putalpha(alpha)

    # Clear enclosed pure-#FFFFFF holes inside closed loops (prayer beads, chinstraps, sword-box straps, headband arches, beard mouth cutouts)
    if bg[0] > 235 and bg[1] > 235 and bg[2] > 235:
        rpx = rgba.load()
        hole_vis = bytearray(w * h)
        for y in range(1, h - 1):
            row = y * w
            for x in range(1, w - 1):
                idx = row + x
                if not hole_vis[idx] and rpx[x, y][3] > 200:
                    r0, g0, b0, _ = rpx[x, y]
                    if min(r0, g0, b0) >= 245 and (max(r0, g0, b0) - min(r0, g0, b0)) <= 6:
                        hole_vis[idx] = 1
                        hq = deque([(x, y)])
                        hpts = [(x, y)]
                        sum_lum = (r0 + g0 + b0) / 3.0
                        while hq:
                            hx, hy = hq.popleft()
                            for nx, ny in ((hx - 1, hy), (hx + 1, hy), (hx, hy - 1), (hx, hy + 1)):
                                if 0 <= nx < w and 0 <= ny < h:
                                    nidx = ny * w + nx
                                    if not hole_vis[nidx] and rpx[nx, ny][3] > 180:
                                        nr, ng, nb, _ = rpx[nx, ny]
                                        if min(nr, ng, nb) >= 241 and (max(nr, ng, nb) - min(nr, ng, nb)) <= 9:
                                            hole_vis[nidx] = 1
                                            hq.append((nx, ny))
                                            hpts.append((nx, ny))
                                            sum_lum += (nr + ng + nb) / 3.0
                        if len(hpts) >= 40 and (sum_lum / len(hpts)) >= 250.2:
                            for (kx, ky) in hpts:
                                rpx[kx, ky] = (0, 0, 0, 0)
                            for (kx, ky) in hpts:
                                for dy in (-1, 0, 1):
                                    for dx in (-1, 0, 1):
                                        bx, by = kx + dx, ky + dy
                                        if 0 <= bx < w and 0 <= by < h:
                                            br, bg_c, bb, ba = rpx[bx, by]
                                            if ba > 0 and min(br, bg_c, bb) >= 225:
                                                rpx[bx, by] = (int(br * 0.45), int(bg_c * 0.45), int(bb * 0.45), int(ba * 0.35))

    if (bg[0] + bg[1] + bg[2]) > 140:
        rpx = rgba.load()
        for y in range(h):
            for x in range(w):
                r, g, b, a = rpx[x, y]
                if 0 < a < 240:
                    f = (a / 255.0) ** 1.35
                    rpx[x, y] = (int(r * f), int(g * f), int(b * f), a)

    return rgba


def strip_small_disconnected_components(rgba, min_ratio=0.22):
    """Keep main sprite component(s) and strip disconnected text labels / corner specks."""
    w, h = rgba.size
    rpx = rgba.load()
    vis = bytearray(w * h)
    comps = []

    for y in range(h):
        row = y * w
        for x in range(w):
            idx = row + x
            if not vis[idx] and rpx[x, y][3] > 24:
                vis[idx] = 1
                q = deque([(x, y)])
                pts = [(x, y)]
                while q:
                    cx, cy = q.popleft()
                    for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
                        if 0 <= nx < w and 0 <= ny < h:
                            nidx = ny * w + nx
                            if not vis[nidx] and rpx[nx, ny][3] > 24:
                                vis[nidx] = 1
                                q.append((nx, ny))
                                pts.append((nx, ny))
                comps.append(pts)

    if not comps:
        return rgba
    max_len = max(len(c) for c in comps)
    thresh = max(32, int(max_len * min_ratio))
    out = rgba.copy()
    opx = out.load()
    for pts in comps:
        if len(pts) < thresh:
            for (px_x, px_y) in pts:
                # Also clear 1px halo around removed glyph pixels
                for dy in (-1, 0, 1):
                    for dx in (-1, 0, 1):
                        nx, ny = px_x + dx, px_y + dy
                        if 0 <= nx < w and 0 <= ny < h and opx[nx, ny][3] < 245:
                            opx[nx, ny] = (0, 0, 0, 0)
                opx[px_x, px_y] = (0, 0, 0, 0)
    return out


def fit_rgba_centered(rgba, canvas_w, canvas_h=None, pad_x=4, pad_y=4, add_shadow=True, famed_glow=False):
    if canvas_h is None:
        canvas_h = canvas_w
    alpha = rgba.getchannel("A")
    mask = alpha.point(lambda a: 255 if a > 18 else 0)
    bbox = mask.getbbox()
    if bbox:
        bx0 = max(0, bbox[0] - 2)
        by0 = max(0, bbox[1] - 2)
        bx1 = min(rgba.width, bbox[2] + 2)
        by1 = min(rgba.height, bbox[3] + 2)
        rgba = rgba.crop((bx0, by0, bx1, by1))

    max_w = canvas_w - 2 * pad_x
    max_h = canvas_h - 2 * pad_y
    cw, ch = rgba.size
    scale = min(max_w / float(cw), max_h / float(ch))
    nw = max(1, int(round(cw * scale)))
    nh = max(1, int(round(ch * scale)))
    resized = rgba.resize((nw, nh), Image.Resampling.LANCZOS)

    rgb_sharp = resized.convert("RGB").filter(ImageFilter.UnsharpMask(radius=0.65, percent=90, threshold=2))
    r_a = resized.getchannel("A")
    item = rgb_sharp.convert("RGBA")
    item.putalpha(r_a)

    out = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))
    if famed_glow:
        gp = out.load()
        cx, cy = canvas_w / 2.0, canvas_h / 2.0
        rx, ry = canvas_w * 0.46, canvas_h * 0.44
        for y in range(canvas_h):
            for x in range(canvas_w):
                d2 = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
                if d2 < 1.0:
                    gp[x, y] = (145, 26, 20, int(86 * ((1.0 - d2) ** 1.6)))

    ox = (canvas_w - nw) // 2
    oy = (canvas_h - nh) // 2

    if add_shadow:
        sh_a = r_a.point(lambda a: int(a * 0.5))
        shadow = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))
        shadow.paste((6, 5, 4, 255), (min(canvas_w - nw, ox + 1), min(canvas_h - nh, oy + 2)), sh_a)
        shadow = shadow.filter(ImageFilter.GaussianBlur(radius=1.5 if canvas_w <= 90 else 2.8))
        out = Image.alpha_composite(out, shadow)

    out.alpha_composite(item, (ox, oy))
    return out


def process_skill_square(cell_img):
    im = cell_img.convert("RGB")
    w, h = im.size
    px = im.load()
    border_c = px[w // 2, 0]
    is_light_bg = (border_c[0] + border_c[1] + border_c[2]) > 380

    def is_gutter_x(x):
        m = sum(1 for y in range(h // 6, 5 * h // 6) if ((px[x, y][0] > 180 and px[x, y][1] > 180 and px[x, y][2] > 180) if is_light_bg else (px[x, y][0] < 22 and px[x, y][1] < 22 and px[x, y][2] < 22)))
        return m > (2 * h // 3) * 0.85

    def is_gutter_y(y):
        m = sum(1 for x in range(w // 6, 5 * w // 6) if ((px[x, y][0] > 180 and px[x, y][1] > 180 and px[x, y][2] > 180) if is_light_bg else (px[x, y][0] < 22 and px[x, y][1] < 22 and px[x, y][2] < 22)))
        return m > (2 * w // 3) * 0.85

    x0, x1, y0, y1 = 0, w - 1, 0, h - 1
    while x0 < w // 4 and is_gutter_x(x0):
        x0 += 1
    while x1 > 3 * w // 4 and is_gutter_x(x1):
        x1 -= 1
    while y0 < h // 4 and is_gutter_y(y0):
        y0 += 1
    while y1 > 3 * h // 4 and is_gutter_y(y1):
        y1 -= 1

    inset = 4
    art = im.crop((min(x0 + inset, w // 3), min(y0 + inset, h // 3), max(x1 - inset, 2 * w // 3), max(y1 - inset, 2 * h // 3)))

    def build_beveled(target_sz, margin):
        inner = target_sz - 2 * margin
        scaled = art.resize((inner, inner), Image.Resampling.LANCZOS).filter(ImageFilter.UnsharpMask(radius=0.65, percent=95, threshold=2))
        canvas = Image.new("RGBA", (target_sz, target_sz), (0, 0, 0, 0))
        canvas.paste(scaled.convert("RGBA"), (margin, margin))
        d = ImageDraw.Draw(canvas)
        d.rectangle([margin - 1, margin - 1, margin + inner, margin + inner], outline=(10, 9, 8, 255))
        xL, yT, xR, yB = margin, margin, margin + inner - 1, margin + inner - 1
        d.line([(xL, yT), (xR, yT)], fill=(158, 152, 142, 235))
        d.line([(xL, yT), (xL, yB)], fill=(142, 136, 128, 235))
        d.line([(xL, yB), (xR, yB)], fill=(44, 40, 36, 240))
        d.line([(xR, yT), (xR, yB)], fill=(52, 48, 44, 240))
        return canvas

    hd = build_beveled(256, 12)
    game56 = build_beveled(56, 3)
    return hd, game56, make_grayscale_sw(game56)


def process_medallion(cell_img, reinforce_ring=False):
    rgba = flood_extract_rgba(cell_img, bg_thresh=30, feather_band=18)
    if reinforce_ring:
        hd = fit_rgba_centered(rgba, 256, pad_x=10, pad_y=10, add_shadow=False)
        game56 = fit_rgba_centered(rgba, 56, pad_x=2, pad_y=2, add_shadow=False)
        ring = Image.new("RGBA", (224, 224), (0, 0, 0, 0))
        rd = ImageDraw.Draw(ring)
        rd.ellipse([8, 8, 215, 215], outline=(118, 112, 104, 215), width=6)
        rd.ellipse([6, 6, 217, 217], outline=(18, 16, 14, 245), width=3)
        game56 = Image.alpha_composite(game56, ring.resize((56, 56), Image.Resampling.LANCZOS))
        ring_hd = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
        rhd = ImageDraw.Draw(ring_hd)
        rhd.ellipse([10, 10, 245, 245], outline=(118, 112, 104, 215), width=5)
        rhd.ellipse([8, 8, 247, 247], outline=(18, 16, 14, 245), width=3)
        hd = Image.alpha_composite(hd, ring_hd)
    else:
        hd = fit_rgba_centered(rgba, 256, pad_x=10, pad_y=10, add_shadow=True)
        game56 = fit_rgba_centered(rgba, 56, pad_x=2, pad_y=2, add_shadow=True)
    return hd, game56, make_grayscale_sw(game56)


def process_item70(cell_img, famed_glow=False):
    rgba = flood_extract_rgba(cell_img, bg_thresh=26, feather_band=16)
    hd = fit_rgba_centered(rgba, 256, pad_x=14, pad_y=14, add_shadow=True, famed_glow=famed_glow)
    game70 = fit_rgba_centered(rgba, 70, pad_x=4, pad_y=4, add_shadow=True, famed_glow=famed_glow)
    return hd, game70


def process_tall140(cell_img, famed_glow=True, is_armor=False, clean_labels=False):
    """Produce HD (200x320), 70x140 IconLarge, AND 70x70 Icon."""
    if clean_labels:
        cw, ch = cell_img.size
        cell_img = cell_img.crop((8, 8, cw - 8, ch - 8))
    rgba = flood_extract_rgba(cell_img, bg_thresh=24 if is_armor else 28, feather_band=14)
    if clean_labels:
        rgba = strip_small_disconnected_components(rgba, min_ratio=0.22)
    alpha = rgba.getchannel("A")
    bbox = alpha.point(lambda a: 255 if a > 18 else 0).getbbox()
    if bbox:
        rgba = rgba.crop((max(0, bbox[0] - 2), max(0, bbox[1] - 2), min(rgba.width, bbox[2] + 2), min(rgba.height, bbox[3] + 2)))

    hd = fit_rgba_centered(rgba, 200, 320, pad_x=10, pad_y=12, add_shadow=True, famed_glow=famed_glow)
    icon140 = fit_rgba_centered(rgba, 70, 140, pad_x=3 if is_armor else 4, pad_y=12 if is_armor else 5, add_shadow=True, famed_glow=famed_glow)

    if rgba.height > rgba.width * 1.45:
        sub = rgba.crop((0, 0, rgba.width, max(1, int(rgba.height * (0.68 if is_armor else 0.58)))))
    else:
        sub = rgba
    icon70 = fit_rgba_centered(sub, 70, 70, pad_x=4, pad_y=4, add_shadow=True, famed_glow=famed_glow)
    return hd, icon140, icon70


def process_paperdoll_layer(cell_img, game_sz=128):
    """Extract clean transparent modular paperdoll part (face, hair, beard, hat, cloak/back-gear)."""
    rgba = flood_extract_rgba(cell_img, bg_thresh=20, feather_band=13)
    hd = fit_rgba_centered(rgba, 256, 256, pad_x=12, pad_y=12, add_shadow=True)
    game_im = fit_rgba_centered(rgba, game_sz, game_sz, pad_x=4, pad_y=4, add_shadow=True)
    return hd, game_im


def process_bust(cell_img, flip_left=False):
    if flip_left:
        cell_img = ImageOps.mirror(cell_img)
    rgba = flood_extract_rgba(cell_img, bg_thresh=26, feather_band=16, bust_mode=True)
    hd = fit_rgba_centered(rgba, 256, 256, pad_x=8, pad_y=8, add_shadow=True)
    game_bust = fit_rgba_centered(rgba, 128, 128, pad_x=4, pad_y=4, add_shadow=True)
    return hd, game_bust


# ==============================================================================
# ALL 18 MASTER SHEETS (grid_cols, grid_rows, source_path)
# ==============================================================================
BRAIN = r"C:\Users\25647\.gemini\antigravity\brain\fa3a61d2-2588-454a-a04d-cca189377964"
SHEET_SPECS = {
    1:  (4, 4, os.path.join(BRAIN, "wuxia_items_4x4_spritesheet_v3_1795155353604.jpg")),
    2:  (4, 4, os.path.join(BRAIN, "wuxia_manuals_4x4_spritesheet_v2_1795155550431.jpg")),
    3:  (4, 4, os.path.join(BRAIN, "wuxia_combat_skills_4x4_grid_1795155513774.jpg")),
    4:  (4, 4, os.path.join(BRAIN, "wuxia_combat_skills_sheet_1795155513764.jpg")),
    5:  (4, 4, os.path.join(BRAIN, "wuxia_skills_status_sheet_4x4_blackbg_1795155556173.jpg")),
    6:  (4, 4, os.path.join(BRAIN, "bb_wuxia_perk_sheet_4x4_final_1795155562135.jpg")),
    7:  (4, 4, os.path.join(BRAIN, "shanhai_beast_cores_4x4_blackbg_1795157954303.jpg")),
    8:  (4, 4, os.path.join(BRAIN, "neidan_beast_cores_4x4_final_1795157979109.jpg")),
    9:  (4, 4, os.path.join(BRAIN, "shanhai_4x4_spritesheet_v3_1795157993727.jpg")),
    10: (4, 3, os.path.join(BRAIN, "bb_legendary_chinese_swords_4x3_v3_1795159177612.jpg")),
    11: (4, 3, os.path.join(BRAIN, "legendary_wuxia_polearms_sheet_final_1795159183738.jpg")),
    12: (4, 3, os.path.join(BRAIN, "bb_wuxia_legendary_weapons_sheet_final_1795159189825.jpg")),
    13: (4, 4, os.path.join(BRAIN, "wuxia_armors_gauntlets_4x4_fixed_1795159173388.jpg")),
    14: (4, 4, os.path.join(BRAIN, "bb_wuxia_spritesheet_4x4_final_1795159194967.jpg")),
    15: (4, 4, os.path.join(BRAIN, "shanhaijing_monster_boss_spritesheet_4x4_final_1795159435662.jpg")),
    16: (4, 4, os.path.join(BRAIN, "shan_hai_jing_bosses_13_to_28_sheet_clean_1795159413045.jpg")),
    17: (4, 4, os.path.join(BRAIN, "shan_hai_jing_bosses_29_44_sheet_v2_1795159430126.jpg")),
    18: (4, 4, os.path.join(BRAIN, "shanhai_bosses_landmarks_sheet_black_1795159443483.jpg")),
}

# Tuple: (sheet, cell_idx, id, stage, group, name, sub, proc_kind, rel_gfx, fallback, coderef, brief)
MASTER_CELLS = [
    # === Sheet 1: Pills, Herb, 9 Original Shan Hai Cores & Blueprint ===
    (1, 0, "wx_pill_jinchuang", "1_icons", "灵丹与奇草", "金疮散", "跌打外伤丹药", "item70", "ui/items/consumables/wx_pill_jinchuang.png", "consumables/bandages_01.png", "mod_wuxia/config/consumables.nut", "粗陶红布塞药瓶配麻绳，微散暗红止血药末"),
    (1, 1, "wx_pill_huxin", "1_icons", "灵丹与奇草", "护心丹", "化解内伤散功灵丹", "item70", "ui/items/consumables/wx_pill_huxin.png", "consumables/antidote_01.png", "mod_wuxia/config/consumables.nut", "冰裂纹青玉描铜葫芦丹瓶，泛温润护脉碧光"),
    (1, 2, "wx_pill_ningshen", "1_icons", "灵丹与奇草", "凝神丸", "灌注武学火候宝丸", "item70", "ui/items/consumables/wx_pill_ningshen.png", "consumables/pills_01.png", "mod_wuxia/config/consumables.nut", "古铜錾花圆丹盒微启，内盛三颗莹白凝神丸"),
    (1, 3, "wx_pill_xisui", "1_icons", "灵丹与奇草", "洗髓丹", "伐毛洗髓冲星奇药", "item70", "ui/items/consumables/wx_pill_xisui.png", "consumables/potion_01.png", "mod_wuxia/config/consumables.nut", "紫铜八卦丹匣盛放赤金龙纹洗髓神丹"),
    (1, 4, "wx_pill_humai", "1_icons", "灵丹与奇草", "护脉丹", "洗髓护脉免暗疾宝丹", "item70", "ui/items/consumables/wx_pill_humai.png", "consumables/potion_02.png", "mod_wuxia/config/consumables.nut", "羊脂白玉莲瓣小瓶，内嵌琥珀色温脉宝丹"),
    (1, 5, "wx_marrow_herb", "1_icons", "灵丹与奇草", "洗髓血芝", "炼丹百工奇材", "item70", "ui/items/misc/wx_marrow_herb.png", "misc/inventory_unhold_01.png", "scripts/items/misc/wx_marrow_herb.nut", "寒岩裂石上生长的暗赤血脉千年灵芝"),
    (1, 6, "wx_core_zhuyan", "1_icons", "山海内丹与图谱", "朱厌沸血丹核", "《西山经》朱厌猿王内丹", "item70", "ui/items/misc/wx_core_zhuyan.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "熔岩裂纹赤红凶猿妖丹，内涌沸血火星"),
    (1, 7, "wx_core_feiyi", "1_icons", "山海内丹与图谱", "肥遗旱火毒丹", "《西山经》六足肥遗王内丹", "item70", "ui/items/misc/wx_core_feiyi.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "细密紫赤毒鳞包裹的旱火蛇蛟内丹，散焦热暗烟"),
    (1, 8, "wx_core_qiongqi", "1_icons", "山海内丹与图谱", "穷奇裂风妖丹", "《北山经》裂风穷奇内丹", "item70", "ui/items/misc/wx_core_qiongqi.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "青苍锋棱风蚀妖丹，周身盘绕墨青裂风气旋"),
    (1, 9, "wx_core_taotie", "1_icons", "山海内丹与图谱", "饕餮噬元凶丹", "《北山经》吞天饕餮王内丹", "item70", "ui/items/misc/wx_core_taotie.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "镌刻青铜饕餮獠牙兽面的暗金凶丹，吞吐血雾"),
    (1, 10, "wx_core_jiuwei", "1_icons", "山海内丹与图谱", "青丘九尾幻丹", "《南山经》九尾天狐主内丹", "item70", "ui/items/misc/wx_core_jiuwei.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "流转胭脂粉与幽紫迷雾的通灵狐魅幻珠"),
    (1, 11, "wx_core_bashe", "1_icons", "山海内丹与图谱", "苍梧巴蛇吞象胆", "《南山经》吞象巴蛇王内丹", "item70", "ui/items/misc/wx_core_bashe.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "墨翡深碧巨蟒苦胆内丹，隐现盘蛇鳞影"),
    (1, 12, "wx_core_jumang", "1_icons", "山海内丹与图谱", "都广建木神心", "《中山经》句芒建木王内丹", "item70", "ui/items/misc/wx_core_jumang.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "苍古铁木盘根包裹的翠绿神木心，萌发金叶嫩芽"),
    (1, 13, "wx_core_wuzhiqi", "1_icons", "山海内丹与图谱", "无支祁寒渊定水珠", "《中山经》淮水无支祁宝珠", "item70", "ui/items/misc/wx_core_wuzhiqi.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "断裂玄铁重锁缠绕的冰蓝寒渊定水宝珠"),
    (1, 14, "wx_core_xingtian", "1_icons", "山海内丹与图谱", "常羊刑天不灭战髓", "《大荒海内经》刑天战魂神髓", "item70", "ui/items/misc/wx_core_xingtian.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "青铜战斧箍带束缚的暗赤不灭战髓晶石"),
    (1, 15, "wx_blueprint_shanhai", "1_icons", "山海内丹与图谱", "百工山海锻造图谱", "9张百工坊山海红装图纸", "item70", "ui/items/misc/wx_blueprint_shanhai.png", "misc/inventory_anatomists_book_02.png", "scripts/crafting/blueprints/wx_bp_*.nut", "麻绳半卷的古旧兽皮锻造图谱，朱砂勾勒山海重铠"),

    # === Sheet 2: 16 Manual Books (4 Categories x 4 Qualities) ===
    (2, 0, "wx_book_neigong_common", "1_icons", "秘籍书册与残页", "内功秘籍·大路货", "灰麻线装吐纳本", "item70", "ui/items/misc/wx_book_neigong_common.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "粗麻灰皮线装薄册，墨绘莲花吐纳纹"),
    (2, 1, "wx_book_neigong_sect", "1_icons", "秘籍书册与残页", "内功秘籍·门派上乘", "玄青云绸太极本", "item70", "ui/items/misc/wx_book_neigong_sect.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "暗青暗云纹丝绸封册，镶古铜阴阳双鱼搭扣"),
    (2, 2, "wx_book_neigong_supreme", "1_icons", "秘籍书册与残页", "内功秘籍·镇派绝学", "紫金锦函周天经", "item70", "ui/items/misc/wx_book_neigong_supreme.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "紫檀织金锦缎包角宝典，嵌鎏金周天星宿圆盘"),
    (2, 3, "wx_book_neigong_unique", "1_icons", "秘籍书册与残页", "内功秘籍·江湖孤本", "韦编古竹简配青玉印", "item70", "ui/items/misc/wx_book_neigong_unique.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "牛皮绳编连的沧桑古竹简，旁镇青玉古印"),
    (2, 4, "wx_book_waigong_common", "1_icons", "秘籍书册与残页", "外功秘籍·大路货", "黄麻手抄刀剑谱", "item70", "ui/items/misc/wx_book_waigong_common.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "毛边草纸线装手抄谱，绘交剑墨纹与暗血迹"),
    (2, 5, "wx_book_waigong_sect", "1_icons", "秘籍书册与残页", "外功秘籍·门派上乘", "绛红铁角武技册", "item70", "ui/items/misc/wx_book_waigong_sect.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "暗绛红布封铆钉护角册，嵌寒铁双剑徽记"),
    (2, 6, "wx_book_waigong_supreme", "1_icons", "秘籍书册与残页", "外功秘籍·镇派绝学", "乌金盘龙兵书匣", "item70", "ui/items/misc/wx_book_waigong_supreme.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "黑金织锦重装宝函，浮雕赤铜盘龙搭扣"),
    (2, 7, "wx_book_waigong_unique", "1_icons", "秘籍书册与残页", "外功秘籍·江湖孤本", "玄铁残碑古拓卷", "item70", "ui/items/misc/wx_book_waigong_unique.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "铁轴石拓残碑长卷，朱砂拓印上古方天战戟纹"),
    (2, 8, "wx_book_qinggong_common", "1_icons", "秘籍书册与残页", "轻功秘籍·大路货", "灰蓝薄装飞燕册", "item70", "ui/items/misc/wx_book_qinggong_common.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "轻薄灰蓝线装小册，墨绘掠水飞燕剪影"),
    (2, 9, "wx_book_qinggong_sect", "1_icons", "秘籍书册与残页", "轻功秘籍·门派上乘", "苍碧银燕绢本", "item70", "ui/items/misc/wx_book_qinggong_sect.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "深碧绢帛软封秘谱，银线精绣回风飞燕环"),
    (2, 10, "wx_book_qinggong_supreme", "1_icons", "秘籍书册与残页", "轻功秘籍·镇派绝学", "天青白玉翎锦卷", "item70", "ui/items/misc/wx_book_qinggong_supreme.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "天青织金云纹玉轴长卷，束白玉雕翎羽带扣"),
    (2, 11, "wx_book_qinggong_unique", "1_icons", "秘籍书册与残页", "轻功秘籍·江湖孤本", "素绡鲲鹏乘风卷", "item70", "ui/items/misc/wx_book_qinggong_unique.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "古旧蚕丝素绡卷轴，隐现青苍鲲鹏展翼暗纹"),
    (2, 12, "wx_book_henglian_common", "1_icons", "秘籍书册与残页", "横练杂学·大路货", "厚牛皮铜钱硬功本", "item70", "ui/items/misc/wx_book_henglian_common.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "粗厚褐牛皮缝装册，镶古旧黄铜护心方孔钱"),
    (2, 13, "wx_book_henglian_sect", "1_icons", "秘籍书册与残页", "横练杂学·门派上乘", "黑革铜角金钟谱", "item70", "ui/items/misc/wx_book_henglian_sect.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "熟铜包角黑牛革重册，中嵌古寺铜钟徽章"),
    (2, 14, "wx_book_henglian_supreme", "1_icons", "秘籍书册与残页", "横练杂学·镇派绝学", "玄铁箍甲兽面典", "item70", "ui/items/misc/wx_book_henglian_supreme.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "铆钉玄铁十字箍重典，镇青铜兽首盾徽"),
    (2, 15, "wx_book_henglian_unique", "1_icons", "秘籍书册与残页", "横练杂学·山海孤本", "蛮荒兽皮骨编秘录", "item70", "ui/items/misc/wx_book_henglian_unique.png", "misc/inventory_anatomists_book_01.png", "scripts/items/misc/wx_manual_item.nut", "凶兽粗毛兽皮配巨骨装帧古卷，烙血红山海图腾"),

    # === Sheet 3: 16 Active Skills (Blades, Spears, Polearms, Daggers, Bow) ===
    (3, 0, "wx_sword_combo", "1_icons", "主动武学招式", "清风连环剑", "剑法主动技 · 56×56", "skill56", "skills/wx_sword_combo.png", "skills/active_02.png", "scripts/skills/actives/wx_sword_combo.nut", "青锋长剑疾挥三道青白剑弧残影"),
    (3, 1, "wx_sword_counter", "1_icons", "主动武学招式", "回锋架势", "剑法反击架势 · 56×56", "skill56", "skills/wx_sword_counter.png", "skills/active_04.png", "scripts/skills/actives/wx_sword_counter.nut", "双剑交击迸发炽烈火星，剑锋蓄势反刺"),
    (3, 2, "wx_sword_pierce", "1_icons", "主动武学招式", "穿云透甲刺", "剑法破甲刺击 · 56×56", "skill56", "skills/wx_sword_pierce.png", "skills/active_03.png", "scripts/skills/actives/wx_sword_pierce.nut", "寒霜剑尖凝白芒一剑洞穿铆钉铁甲"),
    (3, 3, "wx_sword_tianwai", "1_icons", "主动武学招式", "天外一剑", "绝学突进剑招 · 56×56", "skill56", "skills/wx_sword_tianwai.png", "skills/active_30.png", "scripts/skills/actives/wx_sword_tianwai.nut", "孤高寒剑自暗夜苍穹斜贯而下，白虹裂空"),
    (3, 4, "wx_acupoint_strike", "1_icons", "主动武学招式", "清风点穴", "剑指封穴技 · 56×56", "skill56", "skills/wx_acupoint_strike.png", "skills/active_03.png", "scripts/skills/actives/wx_acupoint_strike.nut", "剑柄铜首配合双指疾点敌身赤红要穴"),
    (3, 5, "wx_saber_cleave", "1_icons", "主动武学招式", "劈空重斩", "刀法裂伤斩 · 56×56", "skill56", "skills/wx_saber_cleave.png", "skills/active_23.png", "scripts/skills/actives/wx_saber_cleave.nut", "雁翎弯刀挟腥红血浪自上而下怒斩"),
    (3, 6, "wx_saber_duanyue", "1_icons", "主动武学招式", "断岳狂斩", "重刀崩山绝技 · 56×56", "skill56", "skills/wx_saber_duanyue.png", "skills/active_82.png", "scripts/skills/actives/wx_saber_duanyue.nut", "锯背厚重鬼头大刀轰然劈裂黑岩迸发赤光"),
    (3, 7, "wx_saber_sweep", "1_icons", "主动武学招式", "八方狂澜斩", "刀法旋斩群攻 · 56×56", "skill56", "skills/wx_saber_sweep.png", "skills/active_25.png", "scripts/skills/actives/wx_saber_sweep.nut", "阔刃弯刀回旋拉出满月形暗红刀罡风暴"),
    (3, 8, "wx_poise_charge", "1_icons", "主动武学招式", "沉刀蓄势", "刀客蓄力架势 · 56×56", "skill56", "skills/wx_poise_charge.png", "skills/active_29.png", "scripts/skills/actives/wx_poise_charge.nut", "双手沉腰按刀，刀锋缠绕炽橙蓄势气劲"),
    (3, 9, "wx_spear_guard", "1_icons", "主动武学招式", "威远守线刺", "枪法拒敌守线 · 56×56", "skill56", "skills/wx_spear_guard.png", "skills/active_09.png", "scripts/skills/actives/wx_spear_guard.nut", "红缨百炼铁枪斜指如林，枪尖寒光凛冽"),
    (3, 10, "wx_spear_thrust2", "1_icons", "主动武学招式", "百鸟朝凤刺", "两格攒刺枪招 · 56×56", "skill56", "skills/wx_spear_thrust2.png", "skills/active_08.png", "scripts/skills/actives/wx_spear_thrust2.nut", "红缨长枪瞬间幻化七朵寒星枪芒破空疾刺"),
    (3, 11, "wx_pole_sweep", "1_icons", "主动武学招式", "横扫千军", "长兵扇面横扫 · 56×56", "skill56", "skills/wx_pole_sweep.png", "skills/active_81.png", "scripts/skills/actives/wx_pole_sweep.nut", "偃月大刀拉出耀眼赤金弧光横扫敌阵"),
    (3, 12, "wx_staff_challenge", "1_icons", "主动武学招式", "横杖叫阵", "棍杖嘲讽护阵 · 56×56", "skill56", "skills/wx_staff_challenge.png", "skills/active_18.png", "scripts/skills/actives/wx_staff_challenge.nut", "熟铜箍齐眉重棍猛顿地面震碎山石"),
    (3, 13, "wx_dagger_execute", "1_icons", "主动武学招式", "追魂透骨刺", "短兵处决绝刺 · 56×56", "skill56", "skills/wx_dagger_execute.png", "skills/active_202.png", "scripts/skills/actives/wx_dagger_execute.nut", "反握寒铁短匕狠辣刺穿重甲肋缝溅血"),
    (3, 14, "wx_dagger_vital", "1_icons", "主动武学招式", "分水断脉刺", "奇门断筋短刺 · 56×56", "skill56", "skills/wx_dagger_vital.png", "skills/active_202.png", "scripts/skills/actives/wx_dagger_vital.nut", "精钢分水峨眉刺精准划断手腕经脉"),
    (3, 15, "wx_bow_snipe", "1_icons", "主动武学招式", "流星追月箭", "神射贯甲狙杀 · 56×56", "skill56", "skills/wx_bow_snipe.png", "skills/active_17.png", "scripts/skills/actives/wx_bow_snipe.nut", "铁簇雕翎重箭撕裂夜空，尾曳寒星白芒"),

    # === Sheet 4: 16 Active Skills (Fist, Axe, Hammer, Flail, Shield, Hidden) ===
    (4, 0, "wx_fist_jab", "1_icons", "主动武学招式", "冲拳", "拳掌基础快拳 · 56×56", "skill56", "skills/wx_fist_jab.png", "skills/active_01.png", "scripts/skills/actives/wx_fist_jab.nut", "麻布缠手铁拳破空直击，激起白色气劲波"),
    (4, 1, "wx_fist_shock", "1_icons", "主动武学招式", "寸劲震脉", "拳掌隔甲内伤 · 56×56", "skill56", "skills/wx_fist_shock.png", "skills/active_15.png", "scripts/skills/actives/wx_fist_shock.nut", "近身立掌贴击胸甲，透出层层暗金震腑波纹"),
    (4, 2, "wx_fist_acupoint", "1_icons", "主动武学招式", "拈花点穴指", "指法封脉定身 · 56×56", "skill56", "skills/wx_fist_acupoint.png", "skills/active_03.png", "scripts/skills/actives/wx_fist_acupoint.nut", "双指并拢凝一点金芒精准点中眉心死穴"),
    (4, 3, "wx_fist_grapple", "1_icons", "主动武学招式", "擒龙探爪", "爪功破防锁拿 · 56×56", "skill56", "skills/wx_fist_grapple.png", "skills/active_71.png", "scripts/skills/actives/wx_fist_grapple.nut", "玄铁利爪护手五指箕张挟血风猛扑锁喉"),
    (4, 4, "wx_fist_disarm", "1_icons", "主动武学招式", "空手夺白刃", "拳掌缴械绝技 · 56×56", "skill56", "skills/wx_fist_disarm.png", "skills/active_200.png", "scripts/skills/actives/wx_fist_disarm.nut", "缠布肉掌凌空合十硬生生夹住劈落钢刀"),
    (4, 5, "wx_fist_jingang", "1_icons", "主动武学招式", "金刚摧心掌", "佛门刚猛绝掌 · 56×56", "skill56", "skills/wx_fist_jingang.png", "skills/active_15.png", "scripts/skills/actives/wx_fist_jingang.nut", "古铜金光怒掌轰然推出，卷起刚猛旋风碎石"),
    (4, 6, "wx_axe_split", "1_icons", "主动武学招式", "力劈华山", "重斧碎盾重劈 · 56×56", "skill56", "skills/wx_axe_split.png", "skills/active_24.png", "scripts/skills/actives/wx_axe_split.nut", "长柄月牙巨斧挟赤红雷火一斧劈裂圆木盾"),
    (4, 7, "wx_axe_whirl", "1_icons", "主动武学招式", "旋风断魂斧", "巨斧狂飙群斩 · 56×56", "skill56", "skills/wx_axe_whirl.png", "skills/active_26.png", "scripts/skills/actives/wx_axe_whirl.nut", "双刃重战斧高速回旋卷起黑红杀气漩涡"),
    (4, 8, "wx_hammer_shatter", "1_icons", "主动武学招式", "震岳碎甲击", "重锤摧甲猛击 · 56×56", "skill56", "skills/wx_hammer_shatter.png", "skills/active_33.png", "scripts/skills/actives/wx_hammer_shatter.nut", "八棱黄铜重锤当胸砸瘪钢甲，铆钉崩飞"),
    (4, 9, "wx_hammer_quake", "1_icons", "主动武学招式", "裂地崩山锤", "双手锤震地群伤 · 56×56", "skill56", "skills/wx_hammer_quake.png", "skills/active_34.png", "scripts/skills/actives/wx_hammer_quake.nut", "黄金巨锤轰砸地面，熔火地裂与乱石迸溅"),
    (4, 10, "wx_flail_lash", "1_icons", "主动武学招式", "云梦绕盾抽", "软兵无视盾防 · 56×56", "skill56", "skills/wx_flail_lash.png", "skills/active_40.png", "scripts/skills/actives/wx_flail_lash.nut", "铁刺流星锤划出弧影绕过铁边木盾狠抽"),
    (4, 11, "wx_flail_entangle", "1_icons", "主动武学招式", "锁喉缠丝劲", "软鞭锁喉封刃 · 56×56", "skill56", "skills/wx_flail_entangle.png", "skills/active_200.png", "scripts/skills/actives/wx_flail_entangle.nut", "玄铁锁链九节鞭死死绞住敌刃与护喉铁领"),
    (4, 12, "wx_shield_bash_qi", "1_icons", "主动武学招式", "铁壁震山靠", "刀盾真气猛撞 · 56×56", "skill56", "skills/wx_shield_bash_qi.png", "skills/active_10.png", "scripts/skills/actives/wx_shield_bash_qi.nut", "熟铜猛虎浮雕圆盾裹挟黄钟气浪迎面撞击"),
    (4, 13, "wx_throwing_rain", "1_icons", "主动武学招式", "暴雨毒针", "暗器淬毒攒射 · 56×56", "skill56", "skills/wx_throwing_rain.png", "skills/active_210.png", "scripts/skills/actives/wx_throwing_rain.nut", "玄衣宽袖一抖激射数十枚幽绿淬毒寒针"),
    (4, 14, "wx_throw_fan", "1_icons", "主动武学招式", "漫天花雨", "铁扇暗器齐发 · 56×56", "skill56", "skills/wx_throw_fan.png", "skills/active_210.png", "scripts/skills/actives/wx_throw_fan.nut", "精铁折扇骤开甩出数枚寒光弯月飞刃"),
    (4, 15, "wx_smoke_cast", "1_icons", "主动武学招式", "掷烟蔽目", "奇门烟幕掩护 · 56×56", "skill56", "skills/wx_smoke_cast.png", "skills/active_207.png", "scripts/skills/actives/wx_smoke_cast.nut", "碎裂黑陶雷火弹涌出滚滚紫灰障目浓烟"),

    # === Sheet 5: 3 Final Active Skills + 4 Quality Pages + 9 Status Effect Medallions ===
    (5, 0, "wx_meditate", "1_icons", "主动武学招式", "调息吐纳", "内功回气运功 · 56×56", "skill56", "skills/wx_meditate.png", "skills/active_35.png", "scripts/skills/actives/wx_meditate.nut", "武者盘膝五心朝天，胸前丹田凝聚青白清气"),
    (5, 1, "wx_blood_burst", "1_icons", "主动武学招式", "燃血催劲", "燃血爆发增AP · 56×56", "skill56", "skills/wx_blood_burst.png", "skills/active_36.png", "scripts/skills/actives/wx_blood_burst.nut", "赤膊武者紧握铁拳，周身蒸腾赤红燃血烈焰"),
    (5, 2, "wx_rally_command", "1_icons", "主动武学招式", "聚义号令", "统帅稳固军心 · 56×56", "skill56", "skills/wx_rally_command.png", "skills/active_42.png", "scripts/skills/actives/wx_rally_command.nut", "铁甲护腕高擎赤金烈阳聚义战旗振奋三军"),
    (5, 3, "wx_page_common", "1_icons", "秘籍书册与残页", "武学残页·大路货", "焦边黄麻手绘残页", "item70", "ui/items/misc/wx_page_common.png", "misc/inventory_anatomists_book_02.png", "scripts/items/misc/wx_page_item.nut", "残损泛黄粗纸页，墨绘马步运掌招式人形"),
    (5, 4, "wx_page_sect", "1_icons", "秘籍书册与残页", "武学残页·门派上乘", "洒金青绢朱印残卷", "item70", "ui/items/misc/wx_page_sect.png", "misc/inventory_anatomists_book_02.png", "scripts/items/misc/wx_page_item.nut", "撕裂的暗青洒金绢卷，留存半枚朱砂门派大印"),
    (5, 5, "wx_page_supreme", "1_icons", "秘籍书册与残页", "武学残页·镇派绝学", "紫锦金脉奥义断章", "item70", "ui/items/misc/wx_page_supreme.png", "misc/inventory_anatomists_book_02.png", "scripts/items/misc/wx_page_item.nut", "紫金锦面残章，金线荧光勾勒奇经八脉图"),
    (5, 6, "wx_page_unique", "1_icons", "秘籍书册与残页", "武学残页·江湖孤本", "沧桑骨竹血篆残简", "item70", "ui/items/misc/wx_page_unique.png", "misc/inventory_anatomists_book_02.png", "scripts/items/misc/wx_page_item.nut", "裂纹古骨残片，刻有发光赤红上古符篆"),
    (5, 7, "wx_internal_injury", "1_icons", "真气与内伤状态", "内伤", "脏腑受创回气削减 · 56×56", "medallion56_ring", "skills/wx_internal_injury.png", "skills/status_effect_01.png", "scripts/skills/effects/wx_internal_injury.nut", "肋骨寸断的人体胸廓内迸发暗红淤血"),
    (5, 8, "wx_scatter_weakness", "1_icons", "真气与内伤状态", "散功虚弱", "化功散气虚弱态 · 56×56", "medallion56_ring", "skills/wx_scatter_weakness.png", "skills/status_effect_54.png", "scripts/skills/effects/wx_scatter_weakness.nut", "龟裂破碎的冰蓝丹田气团化作灰烟逸散"),
    (5, 9, "wx_status_acupoint", "1_icons", "真气与内伤状态", "点穴封气", "经脉受制AP削减 · 56×56", "medallion56_ring", "skills/wx_status_acupoint.png", "skills/status_effect_87.png", "scripts/skills/effects/wx_status_acupoint.nut", "三枚金针与黑铁锁链死死钉封赤红气穴"),
    (5, 10, "wx_status_counter_stance", "1_icons", "真气与内伤状态", "回锋架势（状态）", "剑客借力反击态 · 56×56", "medallion56_ring", "skills/wx_status_counter_stance.png", "skills/status_effect_79.png", "scripts/skills/effects/wx_status_counter_stance.nut", "刀剑十字格架绽放刺目银白反击星芒"),
    (5, 11, "wx_status_offbalance", "1_icons", "真气与内伤状态", "失衡", "下盘不稳攻防骤降 · 56×56", "medallion56_ring", "skills/wx_status_offbalance.png", "skills/status_effect_87.png", "scripts/skills/effects/wx_status_offbalance.nut", "歪斜踉跄的侠客黑影配昏黄震荡裂纹"),
    (5, 12, "wx_status_opening", "1_icons", "真气与内伤状态", "破绽", "门户大开易受重创 · 56×56", "medallion56_ring", "skills/wx_status_opening.png", "skills/status_effect_84.png", "scripts/skills/effects/wx_status_opening.nut", "破裂铁胸甲中央亮起赤红索命准星斩痕"),
    (5, 13, "wx_status_poise_charge", "1_icons", "真气与内伤状态", "蓄势（状态）", "沉刀敛气次击暴涨 · 56×56", "medallion56_ring", "skills/wx_status_poise_charge.png", "skills/status_effect_65.png", "scripts/skills/effects/wx_status_poise_charge.nut", "微出鞘的宝刀缠绕狂暴橙金雷电内劲"),
    (5, 14, "wx_status_poison_dart", "1_icons", "真气与内伤状态", "暗器剧毒", "见血封喉奇毒蚀体 · 56×56", "medallion56_ring", "skills/wx_status_poison_dart.png", "skills/status_effect_54.png", "scripts/skills/effects/wx_status_poison_dart.nut", "滴淌翠绿毒液的骨刺贯穿漆黑骷髅"),
    (5, 15, "wx_status_smoke_screen", "1_icons", "真气与内伤状态", "烟幕蔽目", "浓烟遮蔽远防大增 · 56×56", "medallion56_ring", "skills/wx_status_smoke_screen.png", "skills/status_effect_52.png", "scripts/skills/effects/wx_status_smoke_screen.nut", "翻涌紫黑迷烟中微露一双冷冽双眸"),

    # === Sheet 6: 16 Martial Cultivation, Category & Shan Hai Totem Medallions ===
    (6, 0, "wx_martial_container", "1_icons", "武学槽位与孤本圆章", "武学修为总纲", "角色核心武学容器 · 56×56", "medallion56", "ui/perks/wx_martial_container.png", "skills/passive_03.png", "scripts/skills/special/wx_martial_container.nut", "古铜八卦阴阳圆盘环绕刀枪剑拳百兵浮雕"),
    (6, 1, "wx_shanhai_boss_trait", "1_icons", "武学槽位与孤本圆章", "山海凶威", "山海首领特质圆章 · 56×56", "medallion56", "ui/perks/wx_shanhai_boss_trait.png", "skills/status_effect_81.png", "scripts/skills/special/wx_shanhai_boss_trait.nut", "黑铁铆钉圆环内铸赤目双角上古凶神青铜面"),
    (6, 2, "wx_perk_neigong_yin", "1_icons", "武学槽位与孤本圆章", "太阴内功总章", "阴柔系内功槽位圆章 · 56×56", "medallion56", "ui/perks/wx_perk_neigong_yin.png", "ui/perks/perk_21.png", "mod_wuxia/config/manuals/wx_manuals_neigong.nut", "寒铁圆环内绘幽蓝弦月与重重沧浪水纹"),
    (6, 3, "wx_perk_neigong_yang", "1_icons", "武学槽位与孤本圆章", "纯阳内功总章", "阳刚系内功槽位圆章 · 56×56", "medallion56", "ui/perks/wx_perk_neigong_yang.png", "ui/perks/perk_07.png", "mod_wuxia/config/manuals/wx_manuals_neigong.nut", "寒铁圆环内绘赤金大日烘炉烈焰翻腾"),
    (6, 4, "wx_perk_neigong_harmony", "1_icons", "武学槽位与孤本圆章", "太极调和内功章", "调和系内功槽位圆章 · 56×56", "medallion56", "ui/perks/wx_perk_neigong_harmony.png", "ui/perks/perk_54.png", "mod_wuxia/config/manuals/wx_manuals_neigong.nut", "古铁圆环内流转苍翠清气的玄白阴阳太极图"),
    (6, 5, "wx_perk_neigong_evil", "1_icons", "武学槽位与孤本圆章", "诡道奇门内功章", "奇诡魔道内功槽位圆章 · 56×56", "medallion56", "ui/perks/wx_perk_neigong_evil.png", "ui/perks/perk_36.png", "mod_wuxia/config/manuals/wx_manuals_neigong.nut", "荆棘铁刺外环配妖异紫红竖瞳与血脉诡纹"),
    (6, 6, "wx_perk_qinggong", "1_icons", "武学槽位与孤本圆章", "乘风轻功总章", "轻功身法槽位圆章 · 56×56", "medallion56", "ui/perks/wx_perk_qinggong.png", "ui/perks/perk_23.png", "mod_wuxia/config/manuals/wx_manuals_qinggong.nut", "翠竹清风间一掠而过的玄燕身法圆章"),
    (6, 7, "wx_perk_henglian", "1_icons", "武学槽位与孤本圆章", "金刚横练总章", "硬功护体槽位圆章 · 56×56", "medallion56", "ui/perks/wx_perk_henglian.png", "ui/perks/perk_40.png", "mod_wuxia/config/manuals/wx_manuals_henglian.nut", "古铜梵钟护佑重甲胸膛迸溅火星"),
    (6, 8, "wx_perk_tactics", "1_icons", "武学槽位与孤本圆章", "奇门统帅总章", "军心号令杂学圆章 · 56×56", "medallion56", "ui/perks/wx_perk_tactics.png", "ui/perks/perk_28.png", "mod_wuxia/config/manuals/wx_manuals_henglian.nut", "黄金虎符、绛红帅旗与青铜八卦阵盘"),
    (6, 9, "wx_perk_waigong_blade", "1_icons", "武学槽位与孤本圆章", "刀剑外功总章", "剑法刀法槽位圆章 · 56×56", "medallion56", "ui/perks/wx_perk_waigong_blade.png", "ui/perks/perk_46.png", "mod_wuxia/config/manuals/wx_manuals_sword_saber.nut", "寒铁圆环内名剑与厚背雁翎刀十字交锋"),
    (6, 10, "wx_perk_waigong_pole_fist", "1_icons", "武学槽位与孤本圆章", "枪棍拳掌总章", "长兵与拳掌槽位圆章 · 56×56", "medallion56", "ui/perks/wx_perk_waigong_pole_fist.png", "ui/perks/perk_45.png", "mod_wuxia/config/manuals/wx_manuals_pole_fist.nut", "红缨铁枪与熟铜铁拳护腕刚猛并立"),
    (6, 11, "wx_perk_waigong_heavy_ranged", "1_icons", "武学槽位与孤本圆章", "重兵奇门弓弩章", "锤斧鞭与远射槽位圆章 · 56×56", "medallion56", "ui/perks/wx_perk_waigong_heavy_ranged.png", "ui/perks/perk_44.png", "mod_wuxia/config/manuals/wx_manuals_heavy_odd_ranged.nut", "碎甲铁锤、牛角强弓与玄铁锁链交错成徽"),
    (6, 12, "wx_manual_shanhai_zhuyan", "1_icons", "武学槽位与孤本圆章", "《朱厌沸血神功》", "山海图腾孤本专属章 · 56×56", "medallion56", "ui/perks/wx_manual_shanhai_zhuyan.png", "ui/perks/perk_15.png", "mod_wuxia/config/manuals/wx_manuals_shanhai.nut", "鎏金古铜环内白首赤毛巨猿浴火咆哮"),
    (6, 13, "wx_manual_shanhai_taotie", "1_icons", "武学槽位与孤本圆章", "《饕餮吞天魔功》", "山海图腾孤本专属章 · 56×56", "medallion56", "ui/perks/wx_manual_shanhai_taotie.png", "ui/perks/perk_36.png", "mod_wuxia/config/manuals/wx_manuals_shanhai.nut", "鎏金古铜环内弯角饕餮巨口吞噬血煞狂澜"),
    (6, 14, "wx_manual_shanhai_qiongqi", "1_icons", "武学槽位与孤本圆章", "《穷奇逐风翼步》", "山海图腾孤本专属章 · 56×56", "medallion56", "ui/perks/wx_manual_shanhai_qiongqi.png", "ui/perks/perk_26.png", "mod_wuxia/config/manuals/wx_manuals_shanhai.nut", "鎏金古铜环内双翼凶虎穷奇乘青苍疾风扑杀"),
    (6, 15, "wx_manual_shanhai_xingtian", "1_icons", "武学槽位与孤本圆章", "《刑天干戚战舞》", "山海图腾孤本专属章 · 56×56", "medallion56", "ui/perks/wx_manual_shanhai_xingtian.png", "ui/perks/perk_40.png", "mod_wuxia/config/manuals/wx_manuals_shanhai.nut", "鎏金古铜环内无首古神左手执盾右手高举巨戚"),

    # === Sheet 7: 16 Shan Hai Neidan Cores (#10 to #25) ===
    (7, 0, "wx_core_bifang", "1_icons", "山海内丹与图谱", "章莪毕方讹火翎丹", "《南山经》毕方妖皇内丹", "item70", "ui/items/misc/wx_core_bifang.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "青翠羽翼包裹、燃起赤红讹火的毕方妖皇内丹"),
    (7, 1, "wx_core_gudiaowang", "1_icons", "山海内丹与图谱", "鹿吴蛊雕摄魂丹", "《南山经》蛊雕王内丹", "item70", "ui/items/misc/wx_core_gudiaowang.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "豹斑琥珀顶生弯钩凶角的蛊雕王摄魂内丹"),
    (7, 2, "wx_core_xingxing", "1_icons", "山海内丹与图谱", "招摇狌狌通明丹", "《南山经》狌狌老祖内丹", "item70", "ui/items/misc/wx_core_xingxing.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "云雾内蕴、晶莹通透的招摇山通明灵丹"),
    (7, 3, "wx_core_zhujian", "1_icons", "山海内丹与图谱", "单狐猪建狂风丹", "《南山经》豹尾猪建王内丹", "item70", "ui/items/misc/wx_core_zhujian.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "刚鬃獠牙环绕疾风气流的猪建狂兽内丹"),
    (7, 4, "wx_core_xuangui", "1_icons", "山海内丹与图谱", "杻阳玄龟镇海元珠", "《南山经》鸟首玄龟皇内丹", "item70", "ui/items/misc/wx_core_xuangui.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "六棱墨黑古龟甲纹镇海元珠，沉逾玄铁"),
    (7, 5, "wx_core_yuanchu", "1_icons", "山海内丹与图谱", "丹穴堕火涅槃晶", "《南山经》堕火鹓鶵内丹", "item70", "ui/items/misc/wx_core_yuanchu.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "暗紫火山熔晶交织赤金火脉的古禽涅槃晶"),
    (7, 6, "wx_core_yingzhao", "1_icons", "山海内丹与图谱", "昆仑英招巡天金丹", "《西山经》英招巡狩内丹", "item70", "ui/items/misc/wx_core_yingzhao.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "黑金虎纹配青铜双翼扣的昆仑巡狩金丹"),
    (7, 7, "wx_core_luwu", "1_icons", "山海内丹与图谱", "昆仑陆吾九部帝丹", "《西山经》九尾虎神内丹", "item70", "ui/items/misc/wx_core_luwu.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "九枚青铜尾环拱卫的白金昆仑虎神帝丹"),
    (7, 8, "wx_core_qinyuan", "1_icons", "山海内丹与图谱", "昆仑钦原万蛊毒珠", "《西山经》钦原蛊皇内丹", "item70", "ui/items/misc/wx_core_qinyuan.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "滴淌荧光碧绿剧毒的蜂巢状钦原万蛊毒珠"),
    (7, 9, "wx_core_tiangouwang", "1_icons", "山海内丹与图谱", "阴山天狗坠星核", "《西山经》奔星天狗皇内丹", "item70", "ui/items/misc/wx_core_tiangouwang.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "迸射炽白寒星光芒的陨铁天狗核心"),
    (7, 10, "wx_core_zheng", "1_icons", "山海内丹与图谱", "章峨赤狰独角丹", "《西山经》五尾独角狰内丹", "item70", "ui/items/misc/wx_core_zheng.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "黄铜独角锋刺贯穿的赤红碧玉狰兽内丹"),
    (7, 11, "wx_core_hundun", "1_icons", "山海内丹与图谱", "天山浑沌无窍元胎", "《西山经》四凶浑沌内丹", "item70", "ui/items/misc/wx_core_hundun.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "状如赤金丹火皮囊、无面无窍的四凶浑沌元胎"),
    (7, 12, "wx_core_yayu", "1_icons", "山海内丹与图谱", "少咸猰貐逆命血丹", "《北山经》龙首猰貐内丹", "item70", "ui/items/misc/wx_core_yayu.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "暗黑龙鳞包裹、跳动如鲜红心脏的猰貐血丹"),
    (7, 13, "wx_core_zhuyin", "1_icons", "山海内丹与图谱", "钟山烛阴昼夜龙珠", "《北山经》烛九阴血裔龙珠", "item70", "ui/items/misc/wx_core_zhuyin.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "左半玄冰彻骨、右半烈阳焚天的钟山烛阴龙珠"),
    (7, 14, "wx_core_dijiang", "1_icons", "山海内丹与图谱", "天山帝江幻空丹", "《北山经》六足帝江内丹", "item70", "ui/items/misc/wx_core_dijiang.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "层层空间赤红波纹荡漾的丹火帝江神丹"),
    (7, 15, "wx_core_paoxiaowang", "1_icons", "山海内丹与图谱", "北山狍鸮腋目妖珠", "《北山经》狍鸮老祖内丹", "item70", "ui/items/misc/wx_core_paoxiaowang.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "正中睁开金黄凶戾竖瞳的暗红狍鸮妖珠"),

    # === Sheet 8: 16 Shan Hai Neidan Cores (#26 to #41) ===
    (8, 0, "wx_core_changyou", "1_icons", "山海内丹与图谱", "小侯长右听涛寒丹", "《北山经》四耳长右内丹", "item70", "ui/items/misc/wx_core_changyou.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "深海漩涡怒涛翻涌的寒水妖猿内丹"),
    (8, 1, "wx_core_mengji", "1_icons", "山海内丹与图谱", "石者孟极隐猎白丹", "《北山经》白豹孟极内丹", "item70", "ui/items/misc/wx_core_mengji.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "冷白如玉、遍布墨黑豹斑的孟极兽皇内丹"),
    (8, 2, "wx_core_kui", "1_icons", "山海内丹与图谱", "流波夔牛紫电雷核", "《东山经》独足夔牛内丹", "item70", "ui/items/misc/wx_core_kui.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "紫白雷电交织炸裂的苍青夔牛雷核"),
    (8, 3, "wx_core_fei", "1_icons", "山海内丹与图谱", "太山白首蜚疫源毒丹", "《东山经》一目蜚皇内丹", "item70", "ui/items/misc/wx_core_fei.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "龟裂枯灰、渗出黄绿大疫毒烟的灾兽凶丹"),
    (8, 4, "wx_core_yinglong", "1_icons", "山海内丹与图谱", "凶犁应龙真灵逆鳞珠", "《东山经》折翼应龙龙珠", "item70", "ui/items/misc/wx_core_yinglong.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "残损青铜龙翼护拥的苍蓝金纹上古应龙宝珠"),
    (8, 5, "wx_core_taowu", "1_icons", "山海内丹与图谱", "荒中檮杌傲狠凶魂丹", "《东山经》四凶檮杌内丹", "item70", "ui/items/misc/wx_core_taowu.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "刀疤纵横、獠牙外露的四凶檮杌凶魂兽丹"),
    (8, 6, "wx_core_hujiao", "1_icons", "山海内丹与图谱", "玉山虎蛟斑斓内丹", "《东山经》四足虎蛟内丹", "item70", "ui/items/misc/wx_core_hujiao.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "半覆猛虎黄黑斑纹、半覆黑蛇细鳞的虎蛟内丹"),
    (8, 7, "wx_core_zhuhuai", "1_icons", "山海内丹与图谱", "北岳诸怀四角凶丹", "《东山经》四角诸怀内丹", "item70", "ui/items/misc/wx_core_zhuhuai.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "耸立弯骨凶角的漆黑血斑诸怀内丹"),
    (8, 8, "wx_core_shebishi", "1_icons", "山海内丹与图谱", "大荒奢比尸青蛇尸丹", "《东山经》奢比尸古神丹", "item70", "ui/items/misc/wx_core_shebishi.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "两条碧绿毒蛇死死盘绕的苍青古尸神冥丹"),
    (8, 9, "wx_core_jingwei", "1_icons", "山海内丹与图谱", "发鸠精卫填海魂晶", "《东山经》精卫溺魂晶核", "item70", "ui/items/misc/wx_core_jingwei.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "澄澈海蓝魂晶之中凝封一截枯枝与白石"),
    (8, 10, "wx_core_jiuying", "1_icons", "山海内丹与图谱", "凶水九婴水火双生丹", "《中山经》九首九婴内丹", "item70", "ui/items/misc/wx_core_jiuying.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "上半赤焰翻腾、下半寒涛汹涌的水火双生妖丹"),
    (8, 11, "wx_core_feilian", "1_icons", "山海内丹与图谱", "鹿台飞廉御风神丹", "《中山经》风伯飞廉内丹", "item70", "ui/items/misc/wx_core_feilian.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "生有鹿角、盘旋翠青风刃的古铜飞廉神丹"),
    (8, 12, "wx_core_baize", "1_icons", "山海内丹与图谱", "东望白泽通玄宝丹", "《中山经》白泽古兽宝丹", "item70", "ui/items/misc/wx_core_baize.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "温润象牙白玉腰束青铜八卦箍的通玄宝丹"),
    (8, 13, "wx_core_shanhui", "1_icons", "山海内丹与图谱", "狱法山挥疾风妖丸", "《中山经》山挥王内丹", "item70", "ui/items/misc/wx_core_shanhui.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "沙石碎砾高速环绕旋转的黄褐疾风妖丸"),
    (8, 14, "wx_core_bo", "1_icons", "山海内丹与图谱", "中曲食虎铁驳战丹", "《中山经》独角铁驳内丹", "item70", "ui/items/misc/wx_core_bo.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "锤纹百炼寒银铸就、斜刺锯齿独角的铁驳战丹"),
    (8, 15, "wx_core_huodou", "1_icons", "山海内丹与图谱", "厌火祸斗焚天炎珠", "《中山经》食火祸斗内丹", "item70", "ui/items/misc/wx_core_huodou.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "焦炭裂隙喷涌浓黑毒烟与熔火的祸斗炎珠"),

    # === Sheet 9: Final 7 Cores + 4 Totem Medallions + 5 Shan Hai Gear ===
    (9, 0, "wx_core_xiangliuwang", "1_icons", "山海内丹与图谱", "共工台相柳九首苦毒源珠", "《大荒海内经》九首相柳内丹", "item70", "ui/items/misc/wx_core_xiangliuwang.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "九颗毒蛇首级环伺、滴落紫绿苦毒的相柳本源毒晶"),
    (9, 1, "wx_core_kuafu", "1_icons", "山海内丹与图谱", "逐日夸父邓林神木髓", "《大荒海内经》夸父巨神骨髓", "item70", "ui/items/misc/wx_core_kuafu.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "炙阳焦金巨骨上斜生一枝粉艳邓林桃花的夸父神髓"),
    (9, 2, "wx_core_chiyou", "1_icons", "山海内丹与图谱", "凶黎蚩尤铜头兵主战魄", "《大荒海内经》兵主蚩尤神核", "item70", "ui/items/misc/wx_core_chiyou.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "刺出古剑巨斧锋芒的赤铜尖刺兵主战魄"),
    (9, 3, "wx_core_zaochi", "1_icons", "山海内丹与图谱", "畴华凿齿破甲凶牙髓", "《大荒海内经》持盾凿齿内丹", "item70", "ui/items/misc/wx_core_zaochi.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "铆铁箍顶、刻满暗血回纹的丈长凿齿巨牙髓"),
    (9, 4, "wx_core_erfu", "1_icons", "山海内丹与图谱", "疏属贰负缚神怨丹", "《大荒海内经》贰负尸皇内丹", "item70", "ui/items/misc/wx_core_erfu.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "锈蚀断铁锁链死死捆缚的幽紫蛇鳞古神怨丹"),
    (9, 5, "wx_core_nvchou", "1_icons", "山海内丹与图谱", "十日女丑赤旱魃珠", "《大荒海内经》女丑旱魃内丹", "item70", "ui/items/misc/wx_core_nvchou.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "如大旱龟裂赤土般蒸腾热浪的女丑旱魃珠"),
    (9, 6, "wx_core_fangfeng", "1_icons", "山海内丹与图谱", "会稽防风专车神骨髓", "《大荒海内经》防风氏巨骨髓", "item70", "ui/items/misc/wx_core_fangfeng.png", "misc/unhold_heart_01.png", "mod_wuxia/config/wx_shanhai.nut", "双道青铜重箍束紧的万钧石化巨人神骨晶柱"),
    (9, 7, "wx_manual_shanhai_zhuyin", "1_icons", "武学槽位与孤本圆章", "《烛阴瞑昼玄功》", "山海图腾孤本专属章 · 56×56", "medallion56", "ui/perks/wx_manual_shanhai_zhuyin.png", "ui/perks/perk_54.png", "mod_wuxia/config/manuals/wx_manuals_shanhai.nut", "鎏金古铜环内赤色烛龙盘绕烈日与寒月"),
    (9, 8, "wx_manual_shanhai_kunpeng", "1_icons", "武学槽位与孤本圆章", "《北冥鲲鹏逍遥步》", "山海图腾孤本专属章 · 56×56", "medallion56", "ui/perks/wx_manual_shanhai_kunpeng.png", "ui/perks/perk_23.png", "mod_wuxia/config/manuals/wx_manuals_shanhai.nut", "鎏金古铜环内北冥巨鲲展双翼跃出怒海扶摇直上"),
    (9, 9, "wx_manual_shanhai_kuiniu", "1_icons", "武学槽位与孤本圆章", "《东海夔牛雷音功》", "山海图腾孤本专属章 · 56×56", "medallion56", "ui/perks/wx_manual_shanhai_kuiniu.png", "ui/perks/perk_30.png", "mod_wuxia/config/manuals/wx_manuals_shanhai.nut", "鎏金古铜环内东海雷兽沐浴万道紫白闪电咆哮"),
    (9, 10, "wx_manual_shanhai_chiyou", "1_icons", "武学槽位与孤本圆章", "《蚩尤五兵破阵诀》", "山海图腾孤本专属章 · 56×56", "medallion56", "ui/perks/wx_manual_shanhai_chiyou.png", "ui/perks/perk_46.png", "mod_wuxia/config/manuals/wx_manuals_shanhai.nut", "鎏金古铜环内双角铜头兵主面具背负刀剑枪斧锤五兵"),
    (9, 11, "wx_acc_jiuwei", "2_weapons", "山海百工宝甲与奇珍", "山海·青丘定魂辟邪佩", "山海辟邪奇珍 · 70×70", "item70_famed", "ui/items/accessory/wx_acc_jiuwei.png", "accessory/hexe_trophy.png", "scripts/items/accessory/wx_acc_jiuwei.nut", "红绳盘结悬挂的羊脂白玉九尾灵狐辟邪玉佩"),
    (9, 12, "wx_acc_wuzhiqi", "2_weapons", "山海百工宝甲与奇珍", "山海·淮水辟毒寒渊珠", "山海辟邪奇珍 · 70×70", "item70_famed", "ui/items/accessory/wx_acc_wuzhiqi.png", "accessory/alp_trophy.png", "scripts/items/accessory/wx_acc_wuzhiqi.nut", "玄铁猿爪镶托的冰蓝荧光辟毒寒渊佩珠"),
    (9, 13, "wx_helm_taotie", "2_weapons", "山海百工宝甲与奇珍", "山海·饕餮吞天兽面胄", "山海百工兽胄 · 70×70", "item70_famed", "ui/items/helmets/wx_helm_taotie.png", "helmets/inventory_faction_helmet_01.png", "mod_wuxia/config/wx_shanhai.nut", "狰狞双角青铜獠牙饕餮兽面重铁胄"),
    (9, 14, "wx_helm_bashe", "2_weapons", "山海百工宝甲与奇珍", "山海·苍梧巴蛇碧鳞冠", "山海百工兽胄 · 70×70", "item70_famed", "ui/items/helmets/wx_helm_bashe.png", "helmets/inventory_faction_helmet_02.png", "mod_wuxia/config/wx_shanhai.nut", "细密墨碧巨蟒青鳞编缀的轻装束发鳞冠"),
    (9, 15, "wx_relic_qiongqizhao", "2_weapons", "传世与山海神兵红武", "穷奇裂风血骨爪", "传世拳爪 · Fist", "weapon140_famed", "ui/items/weapons/named/wx_relic_qiongqizhao.png", "wx_named_fist", "scripts/items/weapons/named/wx_relic_qiongqizhao.nut", "取西极凶兽穷奇弯钩利爪配裂风妖丹精炼的成对凶兵护手，出爪如恶风撕喉！"),

    # === Sheet 10 (4x3): 12 Relic Swords & Sabers ===
    (10, 0, "wx_relic_taie", "2_weapons", "传世与山海神兵红武", "太阿古剑", "传世名剑 · Sword", "weapon140_famed", "ui/items/weapons/named/wx_relic_taie.png", "named_sword", "scripts/items/weapons/named/wx_relic_taie.nut", "春秋铸剑宗师欧冶子、干将合铸之威道名剑，青铜云纹剑格配苍古寒刃。"),
    (10, 1, "wx_relic_longyuan", "2_weapons", "传世与山海神兵红武", "七星龙渊剑", "传世名剑 · Sword", "weapon140_famed", "ui/items/weapons/named/wx_relic_longyuan.png", "named_sword", "scripts/items/weapons/named/wx_relic_longyuan.nut", "采茨山之铜与天外寒铁所铸高洁之剑，剑脊嵌铜七星，俯视如临万丈深渊。"),
    (10, 2, "wx_relic_chengying", "2_weapons", "传世与山海神兵红武", "承影细剑", "传世名剑 · Sword", "weapon140_famed", "ui/items/weapons/named/wx_relic_chengying.png", "named_fencing_sword", "scripts/items/weapons/named/wx_relic_chengying.nut", "商周传世古剑，暮色微光下唯有淡淡幽影掠喉，轻捷无双。"),
    (10, 3, "wx_relic_ganjiang", "2_weapons", "传世与山海神兵红武", "干将百炼阳剑", "传世名剑 · Sword", "weapon140_famed", "ui/items/weapons/named/wx_relic_ganjiang.png", "named_estoc", "scripts/items/weapons/named/wx_relic_ganjiang.nut", "吴地名匠干将采五山铁精所铸雄剑，剑面布满百炼龟甲暗纹，专刺重铠缝隙。"),
    (10, 4, "wx_relic_moye", "2_weapons", "传世与山海神兵红武", "莫邪流水阴剑", "传世名剑 · Sword", "weapon140_famed", "ui/items/weapons/named/wx_relic_moye.png", "named_shamshir", "scripts/items/weapons/named/wx_relic_moye.nut", "与干将并称之传世雌剑，剑纹漫理如秋水白莲，拂过甲衣便见血封喉。"),
    (10, 5, "wx_relic_chixiao", "2_weapons", "传世与山海神兵红武", "赤霄斩蛇长剑", "传世名剑 · Sword", "weapon140_famed", "ui/items/weapons/named/wx_relic_chixiao.png", "named_warbrand", "scripts/items/weapons/named/wx_relic_chixiao.nut", "芒砀山云气所钟帝道双手长剑，刃如霜雪而泛赤霞，劈刺兼备。"),
    (10, 6, "wx_relic_juque", "2_weapons", "传世与山海神兵红武", "巨阙至尊大剑", "传世名剑 · Sword", "weapon140_famed", "ui/items/weapons/named/wx_relic_juque.png", "named_greatsword", "scripts/items/weapons/named/wx_relic_juque.nut", "越王勾践五剑之首，阔刃厚背钝重如宫阙巨石，挥剑则金石俱裂。"),
    (10, 7, "wx_relic_longque", "2_weapons", "传世与山海神兵红武", "大夏龙雀宝刀", "传世宝刀 · Saber", "weapon140_famed", "ui/items/weapons/named/wx_relic_longque.png", "named_cleaver", "scripts/items/weapons/named/wx_relic_longque.nut", "赫连勃勃百炼名刀，刀环雕金龙衔雀，血槽深邃斩铁如泥。"),
    (10, 8, "wx_relic_minghong", "2_weapons", "传世与山海神兵红武", "鸣鸿古刀", "传世宝刀 · Saber", "weapon140_famed", "ui/items/weapons/named/wx_relic_minghong.png", "named_khopesh", "scripts/items/weapons/named/wx_relic_minghong.nut", "上古铸鼎遗金凝成之神刀，鹤翼护手暗赤微弯，出鞘发清越鹤鸣。"),
    (10, 9, "wx_relic_xiuchun", "2_weapons", "传世与山海神兵红武", "御赐龙鳞绣春刀", "传世宝刀 · Saber", "weapon140_famed", "ui/items/weapons/named/wx_relic_xiuchun.png", "named_cleaver", "scripts/items/weapons/named/wx_relic_xiuchun.nut", "明廷内府御用监璇纹钢千折百锻之指挥使佩刀，鎏金龙鳞装具。"),
    (10, 10, "wx_relic_modao", "2_weapons", "传世与山海神兵红武", "大唐嗣业斩马陌刀", "斩马重刃 · Cleaver", "weapon140_famed", "ui/items/weapons/named/wx_relic_modao.png", "named_crypt_cleaver", "scripts/items/weapons/named/wx_relic_modao.nut", "安西陌刀将李嗣业破阵遗兵，重十五斤双刃长柄，人马俱碎！"),
    (10, 11, "wx_relic_kunwu", "2_weapons", "传世与山海神兵红武", "昆吾割玉弯刀", "传世宝刀 · Saber", "weapon140_famed", "ui/items/weapons/named/wx_relic_kunwu.png", "named_two_handed_scimitar", "scripts/items/weapons/named/wx_relic_kunwu.nut", "西域昆吾山赤铜铁精所铸双手重弯刀，切美玉如切凝脂。"),

    # === Sheet 11 (4x3): 12 Relic Greatsaber, Spears, Polearms, Staves & Hammers ===
    (11, 0, "wx_relic_tulong", "2_weapons", "传世与山海神兵红武", "玄铁沉水重宝刀", "斩马重刃 · Cleaver", "weapon140_famed", "ui/items/weapons/named/wx_relic_tulong.png", "named_rusty_warblade", "scripts/items/weapons/named/wx_relic_tulong.nut", "海底乌金沉铁掺陨铁重铸的无锋阔背狂刀，专破横练金钟。"),
    (11, 1, "wx_relic_liquan", "2_weapons", "传世与山海神兵红武", "沥泉盘龙神枪", "名将神枪 · Spear", "weapon140_famed", "ui/items/weapons/named/wx_relic_liquan.png", "named_spear", "scripts/items/weapons/named/wx_relic_liquan.nut", "岳武穆沥泉奇洞所得神枪，古铜盘龙吞口配赤红枪缨，万夫莫开。"),
    (11, 2, "wx_relic_hutouqiang", "2_weapons", "传世与山海神兵红武", "虎头湛金长枪", "名将神枪 · Spear", "weapon140_famed", "ui/items/weapons/named/wx_relic_hutouqiang.png", "named_spetum", "scripts/items/weapons/named/wx_relic_hutouqiang.nut", "吞口铸咆哮黄金猛虎、枪尖百炼精钢的名将重枪，两格透甲刺喉。"),
    (11, 3, "wx_relic_huaji", "2_weapons", "传世与山海神兵红武", "温侯方天画戟", "长柄重兵 · Polearm", "weapon140_famed", "ui/items/weapons/named/wx_relic_huaji.png", "named_billhook", "scripts/items/weapons/named/wx_relic_huaji.nut", "两侧对称寒霜月牙刃配中宫枪尖与红缨的旷世画戟，钩拉劈刺皆具神威！"),
    (11, 4, "wx_relic_yanyue", "2_weapons", "传世与山海神兵红武", "青龙冷艳锯", "长柄重兵 · Polearm", "weapon140_famed", "ui/items/weapons/named/wx_relic_yanyue.png", "named_swordlance", "scripts/items/weapons/named/wx_relic_yanyue.nut", "重八十二斤的传世青龙偃月大刀，金龙吞口锯齿刀背，横扫衣甲尽裂。"),
    (11, 5, "wx_relic_goulianqiang", "2_weapons", "传世与山海神兵红武", "破虏神机钩镰枪", "长柄重兵 · Polearm", "weapon140_famed", "ui/items/weapons/named/wx_relic_goulianqiang.png", "named_bladed_pike", "scripts/items/weapons/named/wx_relic_goulianqiang.nut", "宋明边军专为克制铁浮屠重骑秘造的百炼倒钩长枪。"),
    (11, 6, "wx_relic_bawangqiang", "2_weapons", "传世与山海神兵红武", "乌金霸王破阵枪", "名将神枪 · Spear", "weapon140_famed", "ui/items/weapons/named/wx_relic_bawangqiang.png", "named_pike", "scripts/items/weapons/named/wx_relic_bawangqiang.nut", "西楚遗风乌金盘龙大枪，枪身沉逾百斤，一刺震退万军。"),
    (11, 7, "wx_relic_huntiegun", "2_weapons", "传世与山海神兵红武", "紧那罗混铁盘龙棍", "禅宗奇杖 · Staff", "weapon140_famed", "ui/items/weapons/named/wx_relic_huntiegun.png", "named_two_handed_mace", "scripts/items/weapons/named/wx_relic_huntiegun.nut", "少室护寺神僧遗留百斤齐眉混铁棍，浮雕赤铜双龙。"),
    (11, 8, "wx_relic_lvzhuzhang", "2_weapons", "传世与山海神兵红武", "天下丐帮绿玉竹杖", "禅宗奇杖 · Staff", "weapon140_famed", "ui/items/weapons/named/wx_relic_lvzhuzhang.png", "named_mace", "scripts/items/weapons/named/wx_relic_lvzhuzhang.nut", "天下第一大帮历代帮主传承信物，碧绿似玉却坚逾精钢。"),
    (11, 9, "wx_relic_wengjinchui", "2_weapons", "传世与山海神兵红武", "擂鼓瓮金巨锤", "破甲金锤 · Hammer", "weapon140_famed", "ui/items/weapons/named/wx_relic_wengjinchui.png", "named_two_handed_hammer", "scripts/items/weapons/named/wx_relic_wengjinchui.nut", "隋唐猛将遗制八棱瓮金巨锤，轰落之时铁甲金盔尽成齑粉！"),
    (11, 10, "wx_relic_shutongjian", "2_weapons", "传世与山海神兵红武", "四棱熟铜瓦面锏", "破甲金锤 · Hammer", "weapon140_famed", "ui/items/weapons/named/wx_relic_shutongjian.png", "named_warhammer", "scripts/items/weapons/named/wx_relic_shutongjian.nut", "唐初秦叔宝成名重器，无刃四棱沉铜铸就，专破锁甲隔甲碎骨。"),
    (11, 11, "wx_relic_jinzuan_chui", "2_weapons", "传世与山海神兵红武", "八宝震山长柄金锤", "破甲金锤 · Hammer", "weapon140_famed", "ui/items/weapons/named/wx_relic_jinzuan_chui.png", "named_polehammer", "scripts/items/weapons/named/wx_relic_jinzuan_chui.nut", "边关上将破城长柄重金锤，带破甲鹰嘴倒刺，隔阵砸碎重盾铁盔。"),

    # === Sheet 12 (4x3): 12 Relic Axes, Flails, Daggers, Bow, Crossbow, Handgonne, Throwing ===
    (12, 0, "wx_relic_xuanhuafu", "2_weapons", "传世与山海神兵红武", "混金八卦宣花大斧", "开山巨斧 · Axe", "weapon140_famed", "ui/items/weapons/named/wx_relic_xuanhuafu.png", "named_greataxe", "scripts/items/weapons/named/wx_relic_xuanhuafu.nut", "程知节成名巨斧，月牙阔刃嵌太极八卦金章，劈盾断人势不可挡。"),
    (12, 1, "wx_relic_pochengyue", "2_weapons", "传世与山海神兵红武", "商周饕餮青铜重钺", "开山巨斧 · Axe", "weapon140_famed", "ui/items/weapons/named/wx_relic_pochengyue.png", "named_bardiche", "scripts/items/weapons/named/wx_relic_pochengyue.nut", "古墓王陵出土天子征伐大钺，绿锈青铜镂雕狰狞饕餮兽面。"),
    (12, 2, "wx_relic_kaitian_changfu", "2_weapons", "传世与山海神兵红武", "辽东玄铁开山长斧", "开山巨斧 · Axe", "weapon140_famed", "ui/items/weapons/named/wx_relic_kaitian_changfu.png", "named_poleaxe", "scripts/items/weapons/named/wx_relic_kaitian_changfu.nut", "辽东劈山盟历代盟主执掌的两格长杆玄铁重战斧。"),
    (12, 3, "wx_relic_xingtianqi", "2_weapons", "传世与山海神兵红武", "刑天舞干断首戚", "开山巨斧 · Axe", "weapon140_famed", "ui/items/weapons/named/wx_relic_xingtianqi.png", "named_heavy_rusty_axe", "scripts/items/weapons/named/wx_relic_xingtianqi.nut", "常羊战魂不灭神髓重铸的上古血脉青铜巨戚，破甲碎盾无人可挡！"),
    (12, 4, "wx_relic_wujinbian", "2_weapons", "传世与山海神兵红武", "呼延乌金竹节钢鞭", "奇门鞭锏 · Flail", "weapon140_famed", "ui/items/weapons/named/wx_relic_wujinbian.png", "named_three_headed_flail", "scripts/items/weapons/named/wx_relic_wujinbian.nut", "河东呼延将门三链竹节铁刺连枷重鞭，绕过铁盾直敲天灵。"),
    (12, 5, "wx_relic_dashenbian", "2_weapons", "传世与山海神兵红武", "云梦软金九节龙鞭", "奇门鞭锏 · Flail", "weapon140_famed", "ui/items/weapons/named/wx_relic_dashenbian.png", "named_battle_whip", "scripts/items/weapons/named/wx_relic_dashenbian.nut", "揉合赤金箍与乌钢编连的奇门九节长软鞭，隔步卷刃锁喉。"),
    (12, 6, "wx_relic_yuchang", "2_weapons", "传世与山海神兵红武", "专诸鱼肠短剑", "刺客凶匕 · Dagger", "weapon140_famed", "ui/items/weapons/named/wx_relic_yuchang.png", "named_dagger", "scripts/items/weapons/named/wx_relic_yuchang.nut", "欧冶子所铸勇绝短剑，鱼鳞百炼螺旋钢纹，刺透三层棠溪重甲！"),
    (12, 7, "wx_relic_xufuren", "2_weapons", "传世与山海神兵红武", "徐夫人淬血寒匕", "刺客凶匕 · Dagger", "weapon140_famed", "ui/items/weapons/named/wx_relic_xufuren.png", "named_qatal_dagger", "scripts/items/weapons/named/wx_relic_xufuren.nut", "燕太子丹以百草奇毒淬炼之图穷匕见凶刃，寸铁封喉。"),
    (12, 8, "wx_relic_zhentiangong", "2_weapons", "传世与山海神兵红武", "薛家震天铁胎神弓", "铁胎神弓 · Bow", "weapon140_famed", "ui/items/weapons/named/wx_relic_zhentiangong.png", "named_warbow", "scripts/items/weapons/named/wx_relic_zhentiangong.nut", "三箭定天山之传世铁胎黑牛角强弓，一矢破空百步贯甲！"),
    (12, 9, "wx_relic_shenbinu", "2_weapons", "传世与山海神兵红武", "大宋克敌神臂重弩", "破阵劲弩 · Crossbow", "weapon140_famed", "ui/items/weapons/named/wx_relic_shenbinu.png", "named_crossbow", "scripts/items/weapons/named/wx_relic_shenbinu.nut", "韩世忠改良之精钢弩担重劲弩，专射重甲铁骑胸膛。"),
    (12, 10, "wx_relic_xunleichong", "2_weapons", "传世与山海神兵红武", "赵氏神机五雷连铳", "神机火器 · Firearm", "weapon140_famed", "ui/items/weapons/named/wx_relic_xunleichong.png", "named_handgonne", "scripts/items/weapons/named/wx_relic_xunleichong.nut", "明工部赵士祯精铸五管转轮神机重火铳，铅砂轰鸣震慑千军！"),
    (12, 11, "wx_relic_feidaonang", "2_weapons", "传世与山海神兵红武", "百炼寒星柳叶飞刀", "绝命暗器 · Throwing", "weapon140_famed", "ui/items/weapons/named/wx_relic_feidaonang.png", "named_javelin", "scripts/items/weapons/named/wx_relic_feidaonang.nut", "牛皮飞刀囊斜插五柄寒星陨铁柳叶飞刀，出手无影例不虚发。"),

    # === Sheet 13 (4x4): 5 Fist Gauntlets + 4 Shan Hai Red Armors + 7 Wuxia Outfits ===
    (13, 0, "wx_fist_wraps", "2_weapons", "拳掌护手兵装", "麻布缠手", "基础拳掌兵装（双持锁副手）", "weapon140_plain", "ui/items/weapons/melee/wx_fist_wraps.png", "unarmed_01.png", "scripts/items/weapons/wx_fist_wraps.nut", "粗麻布层层缠裹指节并浸桐油砂砾的江湖搏击缠手，染有陈年暗血渍"),
    (13, 1, "wx_fist_iron", "2_weapons", "拳掌护手兵装", "精铁指虎", "进阶拳掌兵装（双持锁副手）", "weapon140_plain", "ui/items/weapons/melee/wx_fist_iron.png", "unarmed_01.png", "scripts/items/weapons/wx_fist_iron.nut", "百炼乌铁铆接尖刺的成对指虎皮铁护腕，专破锁甲"),
    (13, 2, "wx_fist_heavy", "2_weapons", "拳掌护手兵装", "玄铁拳套", "重型拳掌兵装（双持锁副手）", "weapon140_plain", "ui/items/weapons/melee/wx_fist_heavy.png", "unarmed_01.png", "scripts/items/weapons/wx_fist_heavy.nut", "厚重乌金玄铁甲叶覆满手背并雕猛虎吞口的成对重型破甲拳套"),
    (13, 3, "wx_relic_longlinzhao", "2_weapons", "传世与山海神兵红武", "天蚕乌金龙鳞爪", "传世拳爪 · Fist", "weapon140_famed", "ui/items/weapons/named/wx_relic_longlinzhao.png", "wx_named_fist", "scripts/items/weapons/named/wx_relic_longlinzhao.nut", "雪山天蚕丝混织乌金龙鳞锻成的成对利爪护手，刀剑难伤。"),
    (13, 4, "wx_relic_jingangwan", "2_weapons", "传世与山海神兵红武", "达摩伏虎金刚护腕", "传世拳爪 · Fist", "weapon140_famed", "ui/items/weapons/named/wx_relic_jingangwan.png", "wx_named_fist", "scripts/items/weapons/named/wx_relic_jingangwan.nut", "少室禅院代代相传的寒铁重护腕，浮雕金刚杵纹，隔甲震腑。"),
    (13, 5, "wx_armor_zhuyan", "2_weapons", "山海百工宝甲与奇珍", "山海·朱厌白首狂血铠", "山海百工重铠 · 310耐久", "armor140_famed", "ui/items/armor/wx_armor_zhuyan.png", "named_plate_armor", "mod_wuxia/config/wx_shanhai.nut", "赤铁胸甲嵌熔火血脉、肩披白首朱厌巨猿厚毛的山海传世重铠。"),
    (13, 6, "wx_armor_feiyi", "2_weapons", "山海百工宝甲与奇珍", "山海·太华肥遗逆鳞甲", "山海百工鳞甲 · 260耐久", "armor140_famed", "ui/items/armor/wx_armor_feiyi.png", "named_scale_armor", "mod_wuxia/config/wx_shanhai.nut", "紫赤与墨黑肥遗毒蛟逆鳞层叠编缀的宝甲，水火毒血难侵。"),
    (13, 7, "wx_armor_qiongqi", "2_weapons", "山海百工宝甲与奇珍", "山海·穷奇逐风翼皮甲", "山海轻装皮甲 · 仅-8内息", "armor140_famed", "ui/items/armor/wx_armor_qiongqi.png", "named_leather_armor", "mod_wuxia/config/wx_shanhai.nut", "西山异兽豹斑革配苍青穷奇风羽护肩的绝顶轻装宝甲，完美契合《金蝉卸力》。"),
    (13, 8, "wx_armor_jumang", "2_weapons", "山海百工宝甲与奇珍", "山海·句芒建木生机甲", "山海神木札甲 · 325耐久", "armor140_famed", "ui/items/armor/wx_armor_jumang.png", "named_lamellar_armor", "mod_wuxia/config/wx_shanhai.nut", "都广建木万年苍翠铁木甲札编就的重铠，生机流转大幅节省内息消耗。"),
    (13, 9, "wx_char_cloth_short", "3_characters", "江湖人物衣冠与敌军造型", "江湖劲装短打", "布衣轻装 · 身甲立绘", "armor140_plain", "ui/items/armor/wx_char_cloth_short.png", "cloth_tunic", "mod_wuxia/config/wx_ecology.nut", "藏青粗布交领短打配牛皮宽束腰，江湖趟子手与游侠标配装束。"),
    (13, 10, "wx_char_robe_swordsman", "3_characters", "江湖人物衣冠与敌军造型", "潇洒剑客青衫", "名门轻装 · 身甲立绘", "armor140_plain", "ui/items/armor/wx_char_robe_swordsman.png", "noble_tunic", "mod_wuxia/config/wx_ecology.nut", "靛青交领剑客长衫配单侧乌皮护肩与青玉腰佩。"),
    (13, 11, "wx_char_robe_taoist", "3_characters", "江湖人物衣冠与敌军造型", "玄门阴阳道袍", "道家门派服 · 身甲立绘", "armor140_plain", "ui/items/armor/wx_char_robe_taoist.png", "monk_robe", "mod_wuxia/config/wx_ecology.nut", "玄白分明交领道袍，腰束太极铜扣布带。"),
    (13, 12, "wx_char_robe_monk", "3_characters", "江湖人物衣冠与敌军造型", "古刹苦行僧衣", "佛门门派服 · 身甲立绘", "armor140_plain", "ui/items/armor/wx_char_robe_monk.png", "monk_robe", "mod_wuxia/config/wx_ecology.nut", "赭黄水田百衲偏袒僧衣配熟铜戒环，古朴刚健。"),
    (13, 13, "wx_char_robe_beggar", "3_characters", "江湖人物衣冠与敌军造型", "丐帮百衲战衣", "江湖帮派服 · 身甲立绘", "armor140_plain", "ui/items/armor/wx_char_robe_beggar.png", "ragged_surcoat", "mod_wuxia/config/wx_ecology.nut", "粗麻补丁无袖战衣斜缠麻绳并悬布袋，豪迈悍勇。"),
    (13, 14, "wx_char_armor_brigandine", "3_characters", "江湖人物衣冠与敌军造型", "边军铁叶布面甲", "中装内衬甲 · 身甲立绘", "armor140_plain", "ui/items/armor/wx_char_armor_brigandine.png", "footman_armor", "mod_wuxia/config/wx_ecology.nut", "暗绛红绒面密布百枚黄铜钢钉、胸缀精钢护心镜的明末边军棉甲。"),
    (13, 15, "wx_char_armor_shanwen", "3_characters", "江湖人物衣冠与敌军造型", "藩镇山文重铠", "重甲横练系 · 身甲立绘", "armor140_plain", "ui/items/armor/wx_char_armor_shanwen.png", "coat_of_plates", "mod_wuxia/config/wx_ecology.nut", "百炼山字纹铁甲配吞肩金兽首与圆护心宝镜的将军重铠。"),

    # === Sheet 14 (4x4): Remaining 9 Stage-3 Outfits/Hats/Enemies + First 7 Wild Shan Hai Beasts ===
    (14, 0, "wx_char_armor_jinyi", "3_characters", "江湖人物衣冠与敌军造型", "内府飞鱼曳撒甲", "官军锦衣系 · 身甲立绘", "armor140_plain", "ui/items/armor/wx_char_armor_jinyi.png", "southern_mail", "mod_wuxia/config/wx_ecology.nut", "暗绯织金飞鱼蟠龙纹曳撒内衬精钢锁子甲，腰悬乌木牙牌。"),
    (14, 1, "wx_char_armor_wudu", "3_characters", "江湖人物衣冠与敌军造型", "南疆五毒百蛊衣", "奇门邪派服 · 身甲立绘", "armor140_plain", "ui/items/armor/wx_char_armor_wudu.png", "assassin_robe", "mod_wuxia/config/wx_ecology.nut", "幽紫蛇皮劲装镶苗银蝎扣，腰挂多枚牛皮奇毒药囊。"),
    (14, 2, "wx_char_raincape", "3_characters", "江湖人物衣冠与敌军造型", "烟雨蓑衣", "江湖行旅披挂 · 身甲立绘", "armor140_plain", "ui/items/armor/wx_char_raincape.png", "leather_wraps", "mod_wuxia/config/wx_ecology.nut", "棕草密编披肩防雨蓑衣内衬玄色夜行衣，刀客风雪独行标配。"),
    (14, 3, "wx_char_hat_bamboo", "3_characters", "江湖人物衣冠与敌军造型", "侠客青竹斗笠", "轻装头冠 · 70×70", "item70", "ui/items/helmets/wx_char_hat_bamboo.png", "hood", "mod_wuxia/config/wx_ecology.nut", "苍青细篾编织宽檐斗笠，下垂破旧黑纱遮面。"),
    (14, 4, "wx_char_hat_topknot", "3_characters", "江湖人物衣冠与敌军造型", "江湖束发木簪冠", "侠客发式 · 70×70", "item70", "ui/items/helmets/wx_char_hat_topknot.png", "headband", "mod_wuxia/config/wx_ecology.nut", "乌黑劲武高束发髻配雕花乌木长簪与抹额布带。"),
    (14, 5, "wx_char_hat_taoist", "3_characters", "江湖人物衣冠与敌军造型", "混元莲花道冠", "玄门头冠 · 70×70", "item70", "ui/items/helmets/wx_char_hat_taoist.png", "cultist_hood", "mod_wuxia/config/wx_ecology.nut", "温润青玉雕琢仰覆莲瓣子午道冠，横插白银道簪。"),
    (14, 6, "wx_char_hat_helm_fengchi", "3_characters", "江湖人物衣冠与敌军造型", "凤翅兜鍪铁胄", "重装头胄 · 70×70", "item70", "ui/items/helmets/wx_char_hat_helm_fengchi.png", "nasal_helmet", "mod_wuxia/config/wx_ecology.nut", "百炼精铁顿项重盔，两侧高耸鎏金双凤翅并垂绛红盔缨。"),
    (14, 7, "wx_char_enemy_corpse", "3_characters", "江湖人物衣冠与敌军造型", "湘西铜甲尸傀造型", "邪祟敌军 · 角色立绘", "bust", "entity/wx_char_enemy_corpse.png", "zombie_knight", "mod_wuxia/config/wx_ecology.nut", "青灰干瘪尸面额贴朱砂镇尸黄符、身披斑驳铜绿古甲的湘西铁尸。"),
    (14, 8, "wx_char_enemy_yaoren", "3_characters", "江湖人物衣冠与敌军造型", "邪派血狂药人造型", "炼体敌军 · 角色立绘", "bust", "entity/wx_char_enemy_yaoren.png", "orc_berserker", "mod_wuxia/config/wx_ecology.nut", "浑身暴起妖紫毒脉、肩背插满黄铜药液管针的邪派炼体狂人。"),
    (14, 9, "wx_beast_tiangou", "4_beasts", "山海经野外山泽异兽", "阴山天狗苍狼", "《西山经》野兽群 · Direwolf", "bust_flip", "entity/wx_beast_tiangou.png", "Direwolf", "mod_wuxia/config/wx_ecology.nut", "白首赤喙如奔星落雷的阴山异种巨狼，双目幽绿嗜血。"),
    (14, 10, "wx_beast_gudiao", "4_beasts", "山海经野外山泽异兽", "西山蛊雕狂兽", "《南山经》野兽群 · Hyena", "bust_flip", "entity/wx_beast_gudiao.png", "Hyena", "mod_wuxia/config/wx_ecology.nut", "状如巨雕而顶生弯角、覆豹斑羽毛的食人凶禽。"),
    (14, 11, "wx_beast_bashe_wild", "4_beasts", "山海经野外山泽异兽", "苍梧吞鹿巴蛇", "《海内南经》巨蟒群 · Serpent", "bust_flip", "entity/wx_beast_bashe_wild.png", "Serpent", "mod_wuxia/config/wx_ecology.nut", "青黑黄斑交错的南疆深泽巨蟒，张口露毒牙可缠杀披甲武夫。"),
    (14, 12, "wx_beast_chizhu", "4_beasts", "山海经野外山泽异兽", "毒谷鬼面赤蛛", "五毒谷异虫群 · Spider", "bust", "entity/wx_beast_chizhu.png", "Spider", "mod_wuxia/config/wx_ecology.nut", "暗赤腹甲烙印惨白骷髅鬼面的岭南剧毒巨蛛。"),
    (14, 13, "wx_beast_paoxiao", "4_beasts", "山海经野外山泽异兽", "北山狍鸮食尸兽", "《北山经》饕餮支裔 · Ghoul", "bust_flip", "entity/wx_beast_paoxiao.png", "Ghoul", "mod_wuxia/config/wx_ecology.nut", "弯角羊身人面、腋下裂开凶目的北山食尸凶兽。"),
    (14, 14, "wx_beast_eshou", "4_beasts", "山海经野外山泽异兽", "幽谷梦魇讹兽", "《神异经》惑梦妖兽 · Alp", "bust_flip", "entity/wx_beast_eshou.png", "Alp", "mod_wuxia/config/wx_ecology.nut", "苍白诡谲、眉心竖开紫色摄魂妖眼的荒谷梦魇精怪。"),
    (14, 15, "wx_beast_jiuwei_wild", "4_beasts", "山海经野外山泽异兽", "青丘惑心妖魅", "《南山经》狐魅 · Hexe", "bust", "entity/wx_beast_jiuwei_wild.png", "Hexe", "mod_wuxia/config/wx_ecology.nut", "身披雪白狐裘、背后舒展苍白狐尾的青丘惑心妖魅。"),

    # === Sheet 15 (4x4): Remaining 4 Wild Beasts + Bosses #1 to #12 (flip right->left) ===
    (15, 0, "wx_beast_jianmu", "4_beasts", "山海经野外山泽异兽", "都广建木树精", "《海内经》神木妖 · Schrat", "bust", "entity/wx_beast_jianmu.png", "Schrat", "mod_wuxia/config/wx_ecology.nut", "盘根错节、树干裂开翠绿灵光巨目的万年化生古木精。"),
    (15, 1, "wx_beast_zhuyan_wild", "4_beasts", "山海经野外山泽异兽", "小次山朱厌巨猿", "《西山经》凶猿 · Unhold", "bust_flip", "entity/wx_beast_zhuyan_wild.png", "Unhold", "mod_wuxia/config/wx_ecology.nut", "白首赤毛、身高逾丈的狂暴山岳巨猿，挥臂可碎坚盾。"),
    (15, 2, "wx_beast_feiyi_wild", "4_beasts", "山海经野外山泽异兽", "太华六足肥遗蛟", "《西山经》旱灾毒蛟 · Lindwurm", "bust_flip", "entity/wx_beast_feiyi_wild.png", "Lindwurm", "mod_wuxia/config/wx_ecology.nut", "六足双翼、浑身紫赤逆鳞流淌蚀铁毒血的太华山巨蛟。"),
    (15, 3, "wx_beast_xiangliu", "4_beasts", "山海经野外山泽异兽", "九首相柳泽妖", "《海外北经》共工臣属 · Kraken", "bust", "entity/wx_beast_xiangliu.png", "Kraken", "mod_wuxia/config/wx_ecology.nut", "盘踞九泽毒渊的人面蛇身九首凶神巨妖。"),
]

# Programmatically append Bosses #1..#12 (Sheet 15 cells 4..15), #13..#28 (Sheet 16 cells 0..15),
# #29..#44 (Sheet 17 cells 0..15), and #45..#48 + 12 Lairs (Sheet 18 cells 0..15)!
BOSS_SHEET_PLACEMENT = (
    [(15, 4 + i, True) for i in range(12)] +     # Bosses 1..12 on Sheet 15 (flip to face left)
    [(16, i, False) for i in range(16)] +        # Bosses 13..28 on Sheet 16 (already facing left!)
    [(17, i, True) for i in range(16)] +         # Bosses 29..44 on Sheet 17 (flip to face left)
    [(18, i, False) for i in range(4)]           # Bosses 45..48 on Sheet 18 Row 1
)

LAIR_BIOME_CELLS = [
    (18, 4, "wx_shanhai_zhuyan"),
    (18, 5, "wx_shanhai_feiyi"),
    (18, 6, "wx_shanhai_qiongqi"),
    (18, 7, "wx_shanhai_taotie"),
    (18, 8, "wx_shanhai_jiuwei"),
    (18, 9, "wx_shanhai_bashe"),
    (18, 10, "wx_shanhai_jumang"),
    (18, 11, "wx_shanhai_wuzhiqi"),
    (18, 12, "wx_shanhai_xingtian"),
    (18, 13, "wx_shanhai_zhuyin"),
    (18, 14, "wx_shanhai_kui"),
    (18, 15, "wx_shanhai_chiyou"),
]


def main():
    ensure_dirs()

    all_sheet_specs = dict(SHEET_SPECS)
    all_sheet_specs.update(EXPANSION_SHEET_SPECS)

    loaded_sheets = {}
    for snum, (cols, rows, spath) in all_sheet_specs.items():
        dst = os.path.join(SHEETS_DIR, f"sheet_{snum:02d}.jpg")
        if os.path.exists(spath):
            shutil.copy2(spath, dst)
        loaded_sheets[snum] = (cols, rows, Image.open(dst))

    # Parse all 48 Bosses & 48 Lairs from live .nut files
    sh_txt = open(os.path.join(ROOT, "mod_wuxia/mod_wuxia/config/wx_shanhai.nut"), encoding="utf-8").read()
    boss_block = sh_txt.split("::Wuxia.Config.ShanHaiCores")[0]
    boss_defs = re.findall(
        r'boss_(\w+)\s*=\s*\{[\s\S]*?Chapter\s*=\s*"([^"]+)",\s*Name\s*=\s*"([^"]+)",\s*EntityType\s*=\s*"([^"]+)"[\s\S]*?TraitName\s*=\s*"([^"]+)",\s*TraitDesc\s*=\s*"([^"]+)"',
        boss_block
    )
    assert len(boss_defs) == 48, f"Expected 48 bosses, found {len(boss_defs)}"

    all_cells = list(MASTER_CELLS) + list(EXPANSION_CELLS)
    for idx, (bkey, bchap, bnm, etype, tnm, tdesc) in enumerate(boss_defs):
        snum, cidx, do_flip = BOSS_SHEET_PLACEMENT[idx]
        all_cells.append((
            snum, cidx, f"wx_boss_{bkey}", "4_beasts", f"山海经首领 ·《{bchap}》",
            bnm, f"{tnm} · 原型骨架 {etype}", "bust_flip" if do_flip else "bust",
            f"entity/bosses/wx_boss_{bkey}.png", etype,
            f"scripts/entity/tactical/enemies/wx_boss_{bkey}.nut", tdesc
        ))

    enc_txt = open(os.path.join(ROOT, "mod_wuxia/mod_wuxia/config/wx_encounters.nut"), encoding="utf-8").read()
    lair_defs = {}
    for lm in re.finditer(r'shanhai_(\w+)\s*=\s*\{\s*Name\s*=\s*"([^"]+)",\s*Chapter\s*=\s*"([^"]+)",\s*Description\s*=\s*"([^"]+)",\s*Brush\s*=\s*"([^"]+)"', enc_txt):
        lkey, lnm, lchap, ldesc, lbrush = lm.groups()
        lair_defs[f"wx_shanhai_{lkey}"] = (lkey, lnm, lchap, ldesc, lbrush)

    direct_lair_ids = {lid for (_, _, lid) in LAIR_BIOME_CELLS}
    for (snum, cidx, lid) in LAIR_BIOME_CELLS:
        lkey, lnm, lchap, ldesc, lbrush = lair_defs[lid]
        all_cells.append((
            snum, cidx, lid, "4_beasts", "山海秘境大地图地标（48处）",
            lnm, f"《{lchap}》核心秘境地标 · 原版基底 {lbrush}", "lair",
            f"world/locations/{lid}.png", lbrush,
            f"scripts/entity/world/locations/{lid}.nut", ldesc
        ))

    manifest_items = []
    png_count = 0

    for (snum, cell_idx, aid, stage, grp, name, sub, kind, rel_gfx, fallback, coderef, brief) in all_cells:
        cols, rows, sheet = loaded_sheets[snum]
        cw, ch = sheet.width // cols, sheet.height // rows
        r, c = divmod(cell_idx, cols)
        cell = sheet.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))
        if snum != 33 and cell_idx in EXPANSION_FLIP_CELLS.get(snum, ()):
            cell = ImageOps.mirror(cell)

        hd_rel = f"art/hd/{aid}.png"
        hd_abs = os.path.join(ROOT, hd_rel)
        game_rel = f"art/game/{rel_gfx}"
        game_abs = os.path.join(ROOT, game_rel)
        os.makedirs(os.path.dirname(game_abs), exist_ok=True)

        sw_rel = ""
        small_rel = ""
        pd_role = ""

        if kind in ("item70", "item70_famed"):
            hd_im, game_im = process_item70(cell, famed_glow=(kind == "item70_famed"))
            hd_im.save(hd_abs)
            game_im.save(game_abs)
            png_count += 2
            spec_str = "70×70 RGBA 透明底背包图标"
            slot_kind = "item70"
        elif kind == "skill56":
            hd_im, game_im, sw_im = process_skill_square(cell)
            hd_im.save(hd_abs)
            game_im.save(game_abs)
            sw_rel = f"art/game/{rel_gfx[:-4]}_sw.png"
            sw_im.save(os.path.join(ROOT, sw_rel))
            png_count += 3
            spec_str = "56×56 铁框技能图标 + 56×56 _sw 置灰版"
            slot_kind = "skill56"
        elif kind in ("medallion56", "medallion56_ring"):
            hd_im, game_im, sw_im = process_medallion(cell, reinforce_ring=(kind == "medallion56_ring"))
            hd_im.save(hd_abs)
            game_im.save(game_abs)
            sw_rel = f"art/game/{rel_gfx[:-4]}_sw.png"
            sw_im.save(os.path.join(ROOT, sw_rel))
            png_count += 3
            spec_str = "56×56 圆章图标 + 56×56 _sw 置灰版"
            slot_kind = "medallion56"
        elif kind in ("weapon140_famed", "weapon140_plain", "weapon140_clean"):
            famed = (kind == "weapon140_famed")
            hd_im, im140, im70 = process_tall140(cell, famed_glow=famed, is_armor=False, clean_labels=(kind == "weapon140_clean"))
            hd_im.save(hd_abs)
            im140.save(game_abs)
            small_rel = f"art/game/{rel_gfx[:-4]}_70x70.png"
            im70.save(os.path.join(ROOT, small_rel))
            png_count += 3
            spec_str = "70×140 装备大格立绘 + 70×70 行囊小格图标"
            slot_kind = "weapon140"
            pd_role = "weapon"
        elif kind in ("shield140_famed", "shield140_plain"):
            famed = (kind == "shield140_famed")
            hd_im, im140, im70 = process_tall140(cell, famed_glow=famed, is_armor=False, clean_labels=False)
            hd_im.save(hd_abs)
            im140.save(game_abs)
            small_rel = f"art/game/{rel_gfx[:-4]}_70x70.png"
            im70.save(os.path.join(ROOT, small_rel))
            png_count += 3
            spec_str = "70×140 副手盾具立绘 + 70×70 行囊小格图标"
            slot_kind = "weapon140"
            pd_role = "shield"
        elif kind in ("armor140_famed", "armor140_plain"):
            famed = (kind == "armor140_famed")
            hd_im, im140, im70 = process_tall140(cell, famed_glow=famed, is_armor=True)
            hd_im.save(hd_abs)
            im140.save(game_abs)
            small_rel = f"art/game/{rel_gfx[:-4]}_70x70.png"
            im70.save(os.path.join(ROOT, small_rel))
            png_count += 3
            spec_str = "70×140 身甲纸娃娃立绘 + 70×70 行囊小格图标"
            slot_kind = "armor140"
            if aid.startswith("wx_body_"):
                pd_role = "torso"
        elif kind == "paperdoll_head":
            hd_im, bust_im = process_paperdoll_layer(cell, game_sz=128)
            hd_im.save(hd_abs)
            bust_im.save(game_abs)
            png_count += 2
            spec_str = "128×128 角色面孔基底贴图 (.brush) + 256×256 原画"
            slot_kind = "boss"
            pd_role = "face"
        elif kind in ("paperdoll_hair", "paperdoll_beard"):
            hd_im, bust_im = process_paperdoll_layer(cell, game_sz=128)
            hd_im.save(hd_abs)
            bust_im.save(game_abs)
            png_count += 2
            spec_str = "128×128 模块化发髻/胡须组件 (.brush) + 256×256 原画"
            slot_kind = "boss"
            pd_role = "hair" if kind == "paperdoll_hair" else "beard"
        elif kind == "paperdoll_hat":
            hd_im, game_im = process_paperdoll_layer(cell, game_sz=70)
            hd_im.save(hd_abs)
            game_im.save(game_abs)
            png_count += 2
            spec_str = "70×70 头冠战盔图标 + 纸娃娃顶戴层 (.brush)"
            slot_kind = "item70"
            pd_role = "hat"
        elif kind == "paperdoll_back":
            hd_im, game_im = process_paperdoll_layer(cell, game_sz=70)
            hd_im.save(hd_abs)
            game_im.save(game_abs)
            png_count += 2
            spec_str = "70×70 披挂佩饰图标 + 纸娃娃背饰层 (.brush)"
            slot_kind = "item70"
            pd_role = "back"
        elif kind in ("bust", "bust_flip", "lair"):
            hd_im, bust_im = process_bust(cell, flip_left=(kind == "bust_flip"))
            hd_im.save(hd_abs)
            bust_im.save(game_abs)
            png_count += 2
            spec_str = "大地图秘境地标原画与贴图 (.brush)" if kind == "lair" else "战场立绘原画与躯干首级贴图 (.brush)"
            slot_kind = "boss"
        else:
            raise ValueError(f"Unknown kind: {kind}")

        item_obj = {
            "id": aid,
            "stage": stage,
            "group": grp,
            "name": name,
            "sub": sub,
            "spec": spec_str,
            "slotKind": slot_kind,
            "status": "wiki_ready",
            "hdPath": hd_rel,
            "previewPath": game_rel,
            "swPath": sw_rel,
            "smallPath": small_rel,
            "gameTarget": f"gfx/{rel_gfx}",
            "vanillaFallback": fallback,
            "codeRef": coderef,
            "brief": brief
        }
        if pd_role:
            item_obj["pdRole"] = pd_role
        manifest_items.append(item_obj)

    # Map the remaining 36 Shan Hai Lairs to their matching custom biome landmark from the 12 created Shan Hai Lair Landmarks!
    brush_to_landmark = {
        "world_cave_01": "wx_shanhai_zhuyan",
        "world_cave_steppe_01": "wx_shanhai_qiongqi",
        "world_abandoned_village": "wx_shanhai_taotie",
        "world_ancient_statue": "wx_shanhai_kui",
        "world_ancient_temple": "wx_shanhai_jumang",
        "world_buried_castle": "wx_shanhai_wuzhiqi",
        "world_battlefield_01": "wx_shanhai_feiyi",
        "world_battlefield_02": "wx_shanhai_xingtian",
        "world_bandit_camp_steppe_01": "wx_shanhai_qiongqi",
        "world_bandit_camp_03": "wx_shanhai_chiyou",
        "world_desert_ruins_01": "wx_shanhai_feiyi",
        "world_desert_ruins_02": "wx_shanhai_zhuyin",
        "world_ancient_watchtower": "wx_shanhai_kui",
        "world_goblin_camp_02": "wx_shanhai_bashe",
        "world_goblin_camp_03": "wx_shanhai_qiongqi",
        "world_crypt_01": "wx_shanhai_taotie",
        "world_crypt_02": "wx_shanhai_jiuwei",
        "world_fortress_ruins": "wx_shanhai_chiyou",
    }
    for lid, (lkey, lnm, lchap, ldesc, lbrush) in lair_defs.items():
        if lid in direct_lair_ids:
            continue
        ref_lid = brush_to_landmark.get(lbrush, "wx_shanhai_xingtian")
        manifest_items.append({
            "id": lid,
            "stage": "4_beasts",
            "group": "山海秘境大地图地标（48处）",
            "name": lnm,
            "sub": f"《{lchap}》秘境地标 · 同地貌图谱 ({ref_lid.replace('wx_shanhai_', '')})",
            "spec": "大地图秘境地标原画与贴图 (.brush)",
            "slotKind": "boss",
            "status": "wiki_ready",
            "hdPath": f"art/hd/{ref_lid}.png",
            "previewPath": f"art/game/world/locations/{ref_lid}.png",
            "swPath": "",
            "smallPath": "",
            "gameTarget": f"brushes/wx_world_locations.brush ({lid})",
            "vanillaFallback": lbrush,
            "codeRef": f"scripts/entity/world/locations/{lid}.nut",
            "brief": ldesc
        })

    manifest = {
        "version": "0.6.2-art-paperdoll-552",
        "summary": {
            "total": len(manifest_items),
            "wiki_ready": sum(1 for x in manifest_items if x["status"] == "wiki_ready"),
            "in_game": sum(1 for x in manifest_items if x["status"] == "in_game"),
            "planned": sum(1 for x in manifest_items if x["status"] == "planned"),
            "png_files_generated": png_count,
        },
        "stages": [
            {"id": "1_icons", "name": "第一卷 · 图标总录", "desc": "灵丹、全部48枚山海内丹、分品阶秘籍残页、35式主动招式、状态与孤本圆章（139/139 已全部创制）"},
            {"id": "2_weapons", "name": "第二卷 · 神兵与百兵武库", "desc": "覆盖13条中华常规兵器阶梯、12面藤铁铜盾、39柄历史/山海神兵与百工宝甲（146/146 已全部创制）"},
            {"id": "3_characters", "name": "第三卷 · 千人千面人物衣冠", "desc": "16东方面孔×16发须×36冠胄面具×58市井门派衣甲×16背饰+18敌首立绘（160/160 已全部创制）"},
            {"id": "4_beasts", "name": "第四卷 · 山海经万妖异兽", "desc": "全部48尊《山海经》首领、11种野外山泽异兽与48座山海秘境大地图地标（107/107 已全部创制）"},
        ],
        "assets": manifest_items
    }

    manifest_path = os.path.join(ART_DIR, "manifest.json")
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)

    print(f"SUCCESS: Generated {png_count} PNG files across all {len(all_sheet_specs)} master sprite sheets!")
    print(f"Manifest written: {manifest_path} -> {manifest['summary']}")


if __name__ == "__main__":
    main()
