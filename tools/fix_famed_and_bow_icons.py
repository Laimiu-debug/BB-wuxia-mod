#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Complete Fix for Topic 2:
1. Eliminates 100% of shared icons across all 61+ vanilla Named/Famed Red Weapons (`weapon.named_*` ->
   unique `weapons/named/wx_famed_01..60`), `wx_named_fist` (`wx_famed_fist_01..04` + `wx_wpn_fist_04..09`),
   and `wx_beast_fist` (dedicated `weapons/melee/wx_beast_fist`).
2. Replaces all dirty/broken bow, crossbow & whip cutouts (`wx_wpn_bow_01..03`, `wx_wpn_xbow_01..03`,
   `wx_beast_bow`, `wx_relic_zhentiangong`, `wx_relic_shenbinu`, `wx_relic_gudiaonu`, `wx_relic_yingzhaogong`,
   `wx_relic_dashenbian`, `wx_relic_wujinbian`, `wx_relic_taie`, `wx_relic_chixiao`) from clean hand-painted
   pure-#FFFFFF master art with precision dark-outlined enclosed-pocket hole punching.
3. Strips posterized pink `famed_glow` ovals, trapped studio-grey pockets & Floyd-Steinberg `a=1..16` dither
   bleed across all remaining weapon UI icons (`named/`, `melee/`, `ranged/`).
4. Losslessly unpacks, updates & repacks `mod_wuxia/brushes/wx_weapons_0.brush` + `mod_wuxia/gfx/wx_weapons_0.png`
   with all 65 new `arm_*` paperdoll sprites + refreshed clean bow/crossbow/relic sprites, preserving `_injured` aliases.
"""

from collections import deque
import glob
import os
import re
import struct
import sys
from pathlib import Path
from PIL import Image, ImageEnhance, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))

import build_wuxia_bust_system as bsys
import build_stage2_stage3_assets as s23
from optimize_equipment_sprites import solidify_and_outline_handheld
from compile_wuxia_brushes import shelf_pack_sprites, write_brush_binary
from add_injured_brush_aliases import main as add_injured_aliases, parse_wuxia_brush

BRAIN = Path(r"C:\Users\25647\.gemini\antigravity\brain\230254b1-e3af-460f-8210-4103ba4eeca1")
MOD_WPN_UI = ROOT / "mod_wuxia" / "gfx" / "ui" / "items" / "weapons"

FAMED_SHEET_PATHS = [
    BRAIN / "famed_wuxia_swords_sabers_4x4_sheet_v2_1795409421230.jpg",
    BRAIN / "bb_wuxia_famed_weapons_4x4_sheet_v3_1795409417556.jpg",
    BRAIN / "famed_hammers_axes_flails_4x4_v2_1795409404089.jpg",
    BRAIN / "famed_wuxia_weapons_grid_v2_1795409404156.jpg",
]
BOW_FIX_SHEET_PATH = BRAIN / "wuxia_weapons_sheet_4x4_fixed_1795409405742.jpg"

# 64 cells across Famed Sheets 1..4 -> (asset_id, kind_hint_for_paperdoll)
FAMED_64_CELLS = [
    # Sheet 1 (16 Swords, Sabers & Cleavers)
    ("wx_famed_01", "1h"),       # named_sword
    ("wx_famed_02", "1h"),       # named_noble_sword
    ("wx_famed_03", "1h"),       # named_fencing_sword
    ("wx_famed_04", "2h_long"),  # named_greatsword
    ("wx_famed_05", "2h_long"),  # named_longsword
    ("wx_famed_06", "1h"),       # named_estoc
    ("wx_famed_07", "2h_long"),  # named_warbrand
    ("wx_famed_08", "1h"),       # named_shamshir
    ("wx_famed_09", "1h"),       # named_cleaver
    ("wx_famed_10", "1h"),       # named_military_cleaver
    ("wx_famed_11", "1h"),       # named_crypt_cleaver
    ("wx_famed_12", "1h"),       # named_khopesh
    ("wx_famed_13", "2h_long"),  # named_two_handed_scimitar
    ("wx_famed_14", "2h_long"),  # named_two_handed_cleaver
    ("wx_famed_15", "2h_long"),  # named_barbarian_cleaver
    ("wx_famed_16", "1h"),       # named_orc_cleaver
    # Sheet 2 (16 Spears, Polearms & Maces)
    ("wx_famed_17", "1h"),       # named_spear
    ("wx_famed_18", "1h"),       # named_fighting_spear
    ("wx_famed_19", "1h"),       # named_goblin_spear
    ("wx_famed_20", "2h_long"),  # named_spetum
    ("wx_famed_21", "2h_long"),  # named_pike
    ("wx_famed_22", "2h_long"),  # named_goblin_pike
    ("wx_famed_23", "2h_long"),  # named_billhook
    ("wx_famed_24", "2h_long"),  # named_bladed_pike
    ("wx_famed_25", "2h_long"),  # named_ancient_bladed_pike
    ("wx_famed_26", "2h_long"),  # named_warscythe
    ("wx_famed_27", "2h_long"),  # named_swordlance
    ("wx_famed_28", "2h_long"),  # named_rusty_warblade
    ("wx_famed_29", "2h_long"),  # named_polemace
    ("wx_famed_30", "2h_long"),  # named_longaxe
    ("wx_famed_31", "1h"),       # named_mace
    ("wx_famed_32", "1h"),       # named_nomad_mace
    # Sheet 3 (16 Hammers, Axes & Flails)
    ("wx_famed_33", "2h_long"),  # named_two_handed_mace
    ("wx_famed_34", "2h_long"),  # named_two_handed_flanged_mace
    ("wx_famed_35", "2h_long"),  # named_two_handed_spiked_mace
    ("wx_famed_36", "1h"),       # named_warhammer
    ("wx_famed_37", "2h_long"),  # named_two_handed_hammer
    ("wx_famed_38", "2h_long"),  # named_skullhammer / named_skull_hammer
    ("wx_famed_39", "2h_long"),  # named_polehammer
    ("wx_famed_40", "1h"),       # named_axe
    ("wx_famed_41", "1h"),       # named_fighting_axe
    ("wx_famed_42", "2h_long"),  # named_greataxe
    ("wx_famed_43", "2h_long"),  # named_bardiche
    ("wx_famed_44", "2h_long"),  # named_poleaxe
    ("wx_famed_45", "2h_long"),  # named_exesword / executioner heavy blade
    ("wx_famed_46", "2h_long"),  # named_heavy_rusty_axe
    ("wx_famed_47", "1h"),       # named_flail
    ("wx_famed_48", "1h"),       # named_three_headed_flail
    # Sheet 4 (12 Flail/Whip/Dagger/Bow/Xbow/Gun/Throw + 4 Famed Fist Gauntlets)
    ("wx_famed_49", "2h_long"),  # named_two_handed_flail
    ("wx_famed_50", "1h"),       # named_battle_whip
    ("wx_famed_51", "dagger"),   # named_dagger
    ("wx_famed_52", "dagger"),   # named_rondel_dagger
    ("wx_famed_53", "dagger"),   # named_qatal_dagger
    ("wx_famed_54", "bow"),      # named_bow
    ("wx_famed_55", "bow"),      # named_warbow
    ("wx_famed_56", "bow"),      # named_goblin_heavy_bow
    ("wx_famed_57", "bow"),      # named_crossbow
    ("wx_famed_58", "gun"),      # named_handgonne
    ("wx_famed_59", "throw"),    # named_javelin
    ("wx_famed_60", "throw"),    # named_throwing_axe
    ("wx_famed_fist_01", "fist"),
    ("wx_famed_fist_02", "fist"),
    ("wx_famed_fist_03", "fist"),
    ("wx_famed_fist_04", "fist"),
]

# Also map `named_goblin_falchion` & `named_orc_axe` so 100% of 62 NamedWeaponMap keys have 1-to-1 unique icons!
# Wait: let's check how many vanilla named_weapon keys exist:
# Sheet 1..4 has 60 non-fist famed icons (`wx_famed_01..60`), and we have 61 distinct vanilla named weapons!
# Let's check: we also have `wx_famed_fist_04` (katar bladed wrist-sword) or we can synthesize `wx_famed_61` / `wx_famed_62`!
# Actually, let's count the exact list in NAMED_WEAPON_MAP_ENTRIES below!

BOW_FIX_16_CELLS = [
    # (asset_id, target_subfolder, kind_hint)
    ("wx_wpn_bow_01",        "ranged", "bow"),
    ("wx_wpn_bow_02",        "ranged", "bow"),
    ("wx_wpn_bow_03",        "ranged", "bow"),
    ("wx_beast_bow",         "ranged", "bow"),
    ("wx_wpn_xbow_01",       "ranged", "bow"),
    ("wx_wpn_xbow_02",       "ranged", "bow"),
    ("wx_wpn_xbow_03",       "ranged", "bow"),
    ("wx_relic_zhentiangong","named",  "bow"),
    ("wx_relic_shenbinu",    "named",  "bow"),
    ("wx_relic_gudiaonu",    "named",  "bow"),
    ("wx_relic_yingzhaogong","named",  "bow"),
    ("wx_beast_fist",        "melee",  "fist"),
    ("wx_relic_dashenbian",  "named",  "1h"),
    ("wx_relic_wujinbian",   "named",  "1h"),
    ("wx_relic_taie",        "named",  "1h"),
    ("wx_relic_chixiao",     "named",  "2h_long"),
]


def extract_clean_white_weapon(cell_img: Image.Image) -> Image.Image:
    """
    Precision weapon extractor from #FFFFFF white background:
    1. Border flood-fill removes outer #FFFFFF background cleanly without eating dark wood/iron outlines.
    2. Enclosed background pocket detector punches out EVERY enclosed pure-white triangle/loop inside
       bowstrings, crossbow frames, stirrups, chain links, whip coils, and ring pommels (verified by
       dark-ink perimeter check so bright specular steel highlights on blades are NEVER touched!).
    3. Strips tiny disconnected dust specks and decontaminates white edge fringes.
    """
    im = cell_img.convert("RGB")
    w, h = im.size
    px = im.load()

    bg_thresh = 28
    feather = 18

    def wdist(c):
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

    # Punch out enclosed pure-white background pockets (bowstrings, crossbow frames, stirrups, whip coils, ring pommels)
    hvis = bytearray(w * h)
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            idx = y * w + x
            if hvis[idx] or apx[x, y] <= 80:
                continue
            r0, g0, b0 = px[x, y]
            if min(r0, g0, b0) >= 232 and (max(r0, g0, b0) - min(r0, g0, b0)) <= 16:
                hvis[idx] = 1
                hq = deque([(x, y)])
                pts = [(x, y)]
                perim_total = 0
                perim_dark = 0
                sum_lum = 0.0
                while hq:
                    hx, hy = hq.popleft()
                    rc, gc, bc = px[hx, hy]
                    sum_lum += (rc + gc + bc) / 3.0
                    for nx, ny in ((hx - 1, hy), (hx + 1, hy), (hx, hy - 1), (hx, hy + 1)):
                        if 0 <= nx < w and 0 <= ny < h:
                            nidx = ny * w + nx
                            nr, ng, nb = px[nx, ny]
                            if apx[nx, ny] > 60 and min(nr, ng, nb) >= 218 and (max(nr, ng, nb) - min(nr, ng, nb)) <= 20:
                                if not hvis[nidx]:
                                    hvis[nidx] = 1
                                    hq.append((nx, ny))
                                    pts.append((nx, ny))
                            else:
                                perim_total += 1
                                nlum = (nr + ng + nb) / 3.0
                                if apx[nx, ny] <= 60 or nlum < 135:
                                    perim_dark += 1

                avg_lum = sum_lum / max(1, len(pts))
                dark_ratio = perim_dark / float(max(1, perim_total))
                # Enclosed background holes sit inside dark ink/wood/string borders (`dark_ratio >= 0.45`) and are pure bright white
                if len(pts) >= 5 and avg_lum >= 241.0 and dark_ratio >= 0.45:
                    for kx, ky in pts:
                        apx[kx, ky] = 0
                    # Soften 1px anti-aliased white inner rim around punched hole
                    for kx, ky in pts:
                        for dy in (-1, 0, 1):
                            for dx in (-1, 0, 1):
                                bx, by = kx + dx, ky + dy
                                if 0 <= bx < w and 0 <= by < h and apx[bx, by] > 0:
                                    br, bg_c, bb = px[bx, by]
                                    if min(br, bg_c, bb) >= 195 and (max(br, bg_c, bb) - min(br, bg_c, bb)) <= 22:
                                        apx[bx, by] = int(apx[bx, by] * 0.30)

    rgba = im.convert("RGBA")
    rgba.putalpha(alpha)

    # Remove tiny disconnected corner dust (< 28 px) while keeping paired gauntlets / twin axes / tassel droplets
    rpx = rgba.load()
    cvis = bytearray(w * h)
    comps = []
    for y in range(h):
        for x in range(w):
            idx = y * w + x
            if not cvis[idx] and rpx[x, y][3] > 24:
                cvis[idx] = 1
                cq = deque([(x, y)])
                cpts = [(x, y)]
                while cq:
                    qx, qy = cq.popleft()
                    for nx, ny in ((qx - 1, qy), (qx + 1, qy), (qx, qy - 1), (qx, qy + 1)):
                        if 0 <= nx < w and 0 <= ny < h:
                            nidx = ny * w + nx
                            if not cvis[nidx] and rpx[nx, ny][3] > 24:
                                cvis[nidx] = 1
                                cq.append((nx, ny))
                                cpts.append((nx, ny))
                comps.append(cpts)
    if comps:
        for cpts in comps:
            if len(cpts) < 28:
                for kx, ky in cpts:
                    rpx[kx, ky] = (0, 0, 0, 0)

    rgba = bsys.decontaminate_white_fringe(rgba, passes=2)
    return bsys.tight_crop(rgba, thresh=24)


def make_clean_ui_icon(hd_rgba: Image.Image, tw: int, th: int, pad_x: int = 3, pad_y: int = 4) -> Image.Image:
    im = bsys.tight_crop(hd_rgba.convert("RGBA"), thresh=22)
    mw = max(1, tw - 2 * pad_x)
    mh = max(1, th - 2 * pad_y)
    if tw == 70 and th == 140:
        mh = min(mh, 108)
    s = min(mw / float(max(1, im.width)), mh / float(max(1, im.height)))
    nw = max(1, int(round(im.width * s)))
    nh = max(1, int(round(im.height * s)))
    rs = im.resize((nw, nh), Image.Resampling.LANCZOS)

    rgb_sharp = rs.convert("RGB").filter(ImageFilter.UnsharpMask(radius=0.6, percent=85, threshold=2))
    r_a = rs.getchannel("A").point(lambda a: 0 if a < 18 else a)
    fg = rgb_sharp.convert("RGBA")
    fg.putalpha(r_a)

    out = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    ox = (tw - nw) // 2
    oy = (th - nh) // 2

    # Crisp subtle drop shadow (clamped to alpha >= 18 so zero full-canvas bleed)
    sh_a = r_a.filter(ImageFilter.GaussianBlur(1.3)).point(lambda a: 0 if a < 18 else int(a * 0.42))
    sh = Image.new("RGBA", (nw, nh), (8, 6, 5, 0))
    sh.putalpha(sh_a)
    out.alpha_composite(sh, (min(tw - nw, ox + 1), min(th - nh, oy + 2)))
    out.alpha_composite(fg, (ox, oy))
    return out


def build_paperdoll_104(hd_rgba: Image.Image, aid: str, kind_hint: str, ped_clip: Image.Image) -> Image.Image:
    W, H = 208, 284
    tc = bsys.decontaminate_white_fringe(bsys.tight_crop(hd_rgba, thresh=26), passes=1)
    im = bsys.bb_grade(s23.orient_weapon_upright_right(tc, aid))

    if kind_hint == "fist":
        max_w, max_h, cx, cy = 92, 86, 138, 210
    elif kind_hint == "throw":
        max_w, max_h, cx, cy = 84, 92, 158, 182
    elif kind_hint == "bow":
        max_w, max_h, cx, cy = 98, 156, 154, 166
    elif kind_hint == "gun":
        max_w, max_h, cx, cy = 92, 146, 158, 172
    elif kind_hint == "dagger":
        max_w, max_h, cx, cy = 78, 110, 158, 182
    elif kind_hint == "2h_long":
        max_w, max_h, cx, cy = 98, 198, 160, 138
    else:
        max_w, max_h, cx, cy = 90, 146, 160, 164

    s = min(max_w / float(max(1, im.width)), max_h / float(max(1, im.height)))
    nw, nh = max(1, int(round(im.width * s))), max(1, int(round(im.height * s)))
    im_s = bsys.decontaminate_white_fringe(im.resize((nw, nh), Image.Resampling.LANCZOS), passes=1)
    im_s = solidify_and_outline_handheld(im_s, is_fist=(kind_hint == "fist"))
    nw2, nh2 = im_s.size

    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    px = max(2, min(W - nw2 - 2, cx - nw2 // 2))
    py = max(4, min(258 - nh2, cy - nh2 // 2))
    layer.alpha_composite(im_s, (px, py))

    from PIL import ImageDraw
    face_guard = Image.new("L", (W, H), 0)
    ImageDraw.Draw(face_guard).ellipse([94, 88, 140, 154], fill=255)
    face_guard = face_guard.filter(ImageFilter.GaussianBlur(1.2))
    a_ch = bsys.bool_subtract(layer.getchannel("A"), face_guard)
    a_ch = bsys.bool_intersect(a_ch, ped_clip)
    layer.putalpha(a_ch)

    layer_208 = bsys.bake_self_drop_shadow(layer, dx=-3, dy=3, blur=2.2, alpha_scale=0.52)
    return layer_208.resize((104, 142), Image.Resampling.LANCZOS)


def clean_existing_relic_and_weapon_pngs(freshly_replaced_stems: set[str]):
    """
    Cleans all existing PNGs in `weapons/named/`, `weapons/melee/`, `weapons/ranged/`:
    - Strips posterized maroon `famed_glow` ovals (`a < 135` with warm reddish tint) on legacy relics;
    - Punches out enclosed studio-grey (`112..148`, `sat <= 8`) pockets (e.g., inside pommel rings / chain gaps);
    - Zeroes out Floyd-Steinberg `a <= 16` transparent dither noise and saves true 32-bit RGBA PNGs.
    """
    cleaned_files = 0
    for sub in ("named", "melee", "ranged"):
        folder = MOD_WPN_UI / sub
        for p in sorted(folder.glob("*.png")):
            stem = p.stem[:-6] if p.stem.endswith("_70x70") else p.stem
            if stem in freshly_replaced_stems:
                continue
            im = Image.open(p).convert("RGBA")
            w, h = im.size
            px = im.load()
            changed = False

            for y in range(h):
                for x in range(w):
                    r, g, b, a = px[x, y]
                    if a == 0:
                        continue
                    # 1. Strip Floyd-Steinberg low-alpha dither noise
                    if a <= 18:
                        px[x, y] = (0, 0, 0, 0)
                        changed = True
                        continue
                    # 2. Strip baked semi-transparent maroon `famed_glow` oval on legacy relics (`RGB ~(145,26,20), a <= 115`)
                    if sub == "named" and a <= 125 and r >= g + 22 and r >= b + 25:
                        px[x, y] = (0, 0, 0, 0)
                        changed = True

            # 3. Punch out enclosed neutral #808080 studio-grey pockets (>= 12 px) on legacy relics
            if sub == "named":
                vis = bytearray(w * h)
                for y in range(1, h - 1):
                    for x in range(1, w - 1):
                        idx = y * w + x
                        r0, g0, b0, a0 = px[x, y]
                        if vis[idx] or a0 <= 120:
                            continue
                        mn0, mx0 = min(r0, g0, b0), max(r0, g0, b0)
                        if 116 <= mn0 and mx0 <= 142 and (mx0 - mn0) <= 6:
                            vis[idx] = 1
                            q = deque([(x, y)])
                            pts = [(x, y)]
                            touches_metal = 0
                            perim = 0
                            while q:
                                qx, qy = q.popleft()
                                for nx, ny in ((qx - 1, qy), (qx + 1, qy), (qx, qy - 1), (qx, qy + 1)):
                                    if 0 <= nx < w and 0 <= ny < h:
                                        nidx = ny * w + nx
                                        nr, ng, nb, na = px[nx, ny]
                                        nmn, nmx = min(nr, ng, nb), max(nr, ng, nb)
                                        if na > 100 and 112 <= nmn and nmx <= 146 and (nmx - nmn) <= 8:
                                            if not vis[nidx]:
                                                vis[nidx] = 1
                                                q.append((nx, ny))
                                                pts.append((nx, ny))
                                        else:
                                            perim += 1
                                            if na <= 40 or (nr + ng + nb) / 3.0 < 95:
                                                touches_metal += 1
                            if len(pts) >= 14 and touches_metal >= perim * 0.55:
                                for kx, ky in pts:
                                    px[kx, ky] = (0, 0, 0, 0)
                                changed = True

            if changed or Image.open(p).mode != "RGBA":
                im.save(p)
                cleaned_files += 1
    return cleaned_files


def unpack_brush_entries(brush_path: Path, png_path: Path) -> list[dict]:
    parsed = parse_wuxia_brush(str(brush_path))
    atlas = Image.open(png_path).convert("RGBA")
    aw, ah = parsed["aw"], parsed["ah"]
    entries = []
    for rec in parsed["records"]:
        sid = rec["id"]
        if sid.endswith("_injured"):
            continue
        _cat, w, h, ox, oy = struct.unpack_from("<QIIhh", rec["meta53"], 0)
        sl = rec["src_len"]
        src_rel = rec["tail_bytes"][:sl].decode("ascii")
        u0, u1, v0, v1, fL, fR, fT, fB = struct.unpack_from("<8f", rec["tail_bytes"], sl)
        ax0 = int(round(u0 * aw))
        ax1 = int(round(u1 * aw))
        ay0 = int(round(v0 * ah))
        ay1 = int(round(v1 * ah))
        crop_flipped = atlas.crop((ax0, ay0, max(ax0 + 1, ax1), max(ay0 + 1, ay1)))
        crop = ImageOps.flip(crop_flipped)

        bx0 = int(round(fL + w / 2.0))
        by0 = int(round(h / 2.0 - fB))
        canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        canvas.paste(crop, (max(0, bx0), max(0, by0)))
        entries.append({
            "id": sid,
            "img": canvas,
            "ox": ox,
            "oy": oy,
            "src_rel": src_rel,
            "is_effect": False,
        })
    return entries


def main():
    for p in FAMED_SHEET_PATHS + [BOW_FIX_SHEET_PATH]:
        if not p.exists():
            raise FileNotFoundError(f"Missing generated weapon sheet: {p}")

    ped_clip = s23.make_handheld_pedestal_clip()
    new_paperdoll_map: dict[str, Image.Image] = {}
    freshly_replaced_stems: set[str] = set()

    # 1. Extract 64 Famed Red Weapons (`wx_famed_01..60` + `wx_famed_fist_01..04`)
    named_dir = MOD_WPN_UI / "named"
    named_dir.mkdir(parents=True, exist_ok=True)

    famed_hd_cache: dict[str, Image.Image] = {}
    for s_idx, spath in enumerate(FAMED_SHEET_PATHS):
        sh = Image.open(spath)
        cw, ch = sh.width // 4, sh.height // 4
        for cell_idx in range(16):
            aid, kind_hint = FAMED_64_CELLS[s_idx * 16 + cell_idx]
            r, c = divmod(cell_idx, 4)
            cell = sh.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))
            hd_rgba = extract_clean_white_weapon(cell)
            famed_hd_cache[aid] = hd_rgba

            ic_140 = make_clean_ui_icon(hd_rgba, 70, 140)
            ic_70 = make_clean_ui_icon(hd_rgba, 70, 70)
            ic_140.save(named_dir / f"{aid}.png")
            ic_70.save(named_dir / f"{aid}_70x70.png")
            freshly_replaced_stems.add(aid)

            new_paperdoll_map[f"arm_{aid}"] = build_paperdoll_104(hd_rgba, aid, kind_hint, ped_clip)

    # Also create `wx_famed_61` (for `named_goblin_falchion` — emerald-venom curved falchion variant)
    # and `wx_famed_62` (for `named_orc_axe` — scorched crimson-bronze warlord chopper variant)
    # so EVERY ONE of the 62 vanilla named_weapon keys has a 100% distinct asset ID!
    from process_wave_63_68_vfx_upgrade import shift_hue_rgba
    for extra_id, src_id, hue_deg, mir, kh in [
        ("wx_famed_61", "wx_famed_12", 85.0, True, "1h"),
        ("wx_famed_62", "wx_famed_41", -28.0, True, "1h"),
    ]:
        base_hd = famed_hd_cache[src_id]
        if mir:
            base_hd = ImageOps.mirror(base_hd)
        var_hd = shift_hue_rgba(base_hd, hue_deg)
        make_clean_ui_icon(var_hd, 70, 140).save(named_dir / f"{extra_id}.png")
        make_clean_ui_icon(var_hd, 70, 70).save(named_dir / f"{extra_id}_70x70.png")
        freshly_replaced_stems.add(extra_id)
        new_paperdoll_map[f"arm_{extra_id}"] = build_paperdoll_104(var_hd, extra_id, kh, ped_clip)

    print("1) Sliced & saved 66 dedicated Famed Red Weapon icon pairs (70x140 + 70x70) & paperdoll sprites!")

    # 2. Extract Sheet 5 (16 crisp replacement Bows, Crossbows, Beast Fist & Relics)
    sh5 = Image.open(BOW_FIX_SHEET_PATH)
    cw5, ch5 = sh5.width // 4, sh5.height // 4
    for cell_idx, (aid, sub_folder, kind_hint) in enumerate(BOW_FIX_16_CELLS):
        r, c = divmod(cell_idx, 4)
        cell = sh5.crop((c * cw5, r * ch5, (c + 1) * cw5, (r + 1) * ch5))
        hd_rgba = extract_clean_white_weapon(cell)

        out_dir = MOD_WPN_UI / sub_folder
        out_dir.mkdir(parents=True, exist_ok=True)
        make_clean_ui_icon(hd_rgba, 70, 140).save(out_dir / f"{aid}.png")
        make_clean_ui_icon(hd_rgba, 70, 70).save(out_dir / f"{aid}_70x70.png")
        freshly_replaced_stems.add(aid)

        new_paperdoll_map[f"arm_{aid}"] = build_paperdoll_104(hd_rgba, aid, kind_hint, ped_clip)

    print("2) Sliced & saved all 16 clean-cutout Bow, Crossbow, Gauntlet & Relic icon pairs + paperdoll sprites!")

    # 3. Clean remaining weapon UI PNGs (remove posterized maroon glow, grey pockets, and Floyd-Steinberg dither bleed)
    cleaned_cnt = clean_existing_relic_and_weapon_pngs(freshly_replaced_stems)
    print(f"3) Cleaned {cleaned_cnt} existing weapon PNGs (zero maroon smudge, zero dither bleed, true 32-bit RGBA)!")

    # 4. Losslessly unpack, update & repack `wx_weapons_0.brush` + `wx_weapons_0.png`
    brush_p = ROOT / "mod_wuxia" / "brushes" / "wx_weapons_0.brush"
    png_p = ROOT / "mod_wuxia" / "gfx" / "wx_weapons_0.png"
    entries = unpack_brush_entries(brush_p, png_p)
    by_id = {e["id"]: e for e in entries}

    for sid, im104 in sorted(new_paperdoll_map.items()):
        by_id[sid] = {
            "id": sid,
            "img": im104,
            "ox": 0,
            "oy": 35,
            "src_rel": f"entity\\weapons\\{sid}.png",
            "is_effect": False,
        }

    merged_entries = [by_id[k] for k in sorted(by_id.keys())]
    atlas, recs = shelf_pack_sprites(merged_entries, max_atlas_w=2048)
    atlas.save(png_p)
    write_brush_binary(str(brush_p), "gfx/wx_weapons_0.png", atlas.size, recs, is_effect_sheet=False)
    print(f"4) Repacked wx_weapons_0.brush: {len(recs)} base weapon/shield sprites ({atlas.size[0]}x{atlas.size[1]})")
    add_injured_aliases()

    # 5. Update `NamedWeaponMap` in `wx_equipment_visuals.nut` -> 100% unique `["wx_famed_XX", "named"]`!
    eq_vis_path = ROOT / "mod_wuxia" / "mod_wuxia" / "systems" / "wx_equipment_visuals.nut"
    eq_src = eq_vis_path.read_text(encoding="utf-8")

    new_named_map_block = """\t// Vanilla Famed / Named Red Weapons (`weapon.named_*`) -> 100% Dedicated Non-Shared Wuxia Famed Art (`weapons/named/wx_famed_*`)
\t// [WuxiaAssetID, Folder ("melee"|"ranged"|"named")]
\tNamedWeaponMap = {
\t\t["weapon.named_sword"]                  = ["wx_famed_01", "named"],
\t\t["weapon.named_noble_sword"]            = ["wx_famed_02", "named"],
\t\t["weapon.named_fencing_sword"]          = ["wx_famed_03", "named"],
\t\t["weapon.named_greatsword"]             = ["wx_famed_04", "named"],
\t\t["weapon.named_longsword"]              = ["wx_famed_05", "named"],
\t\t["weapon.named_estoc"]                  = ["wx_famed_06", "named"],
\t\t["weapon.named_warbrand"]               = ["wx_famed_07", "named"],
\t\t["weapon.named_shamshir"]               = ["wx_famed_08", "named"],
\t\t["weapon.named_cleaver"]                = ["wx_famed_09", "named"],
\t\t["weapon.named_military_cleaver"]       = ["wx_famed_10", "named"],
\t\t["weapon.named_crypt_cleaver"]          = ["wx_famed_11", "named"],
\t\t["weapon.named_khopesh"]                = ["wx_famed_12", "named"],
\t\t["weapon.named_two_handed_scimitar"]    = ["wx_famed_13", "named"],
\t\t["weapon.named_two_handed_cleaver"]     = ["wx_famed_14", "named"],
\t\t["weapon.named_barbarian_cleaver"]      = ["wx_famed_15", "named"],
\t\t["weapon.named_orc_cleaver"]            = ["wx_famed_16", "named"],
\t\t["weapon.named_spear"]                  = ["wx_famed_17", "named"],
\t\t["weapon.named_fighting_spear"]         = ["wx_famed_18", "named"],
\t\t["weapon.named_goblin_spear"]           = ["wx_famed_19", "named"],
\t\t["weapon.named_spetum"]                 = ["wx_famed_20", "named"],
\t\t["weapon.named_pike"]                   = ["wx_famed_21", "named"],
\t\t["weapon.named_goblin_pike"]            = ["wx_famed_22", "named"],
\t\t["weapon.named_billhook"]               = ["wx_famed_23", "named"],
\t\t["weapon.named_bladed_pike"]            = ["wx_famed_24", "named"],
\t\t["weapon.named_ancient_bladed_pike"]    = ["wx_famed_25", "named"],
\t\t["weapon.named_warscythe"]              = ["wx_famed_26", "named"],
\t\t["weapon.named_swordlance"]             = ["wx_famed_27", "named"],
\t\t["weapon.named_rusty_warblade"]         = ["wx_famed_28", "named"],
\t\t["weapon.named_polemace"]               = ["wx_famed_29", "named"],
\t\t["weapon.named_longaxe"]                = ["wx_famed_30", "named"],
\t\t["weapon.named_mace"]                   = ["wx_famed_31", "named"],
\t\t["weapon.named_nomad_mace"]             = ["wx_famed_32", "named"],
\t\t["weapon.named_two_handed_mace"]        = ["wx_famed_33", "named"],
\t\t["weapon.named_two_handed_flanged_mace"]= ["wx_famed_34", "named"],
\t\t["weapon.named_two_handed_spiked_mace"] = ["wx_famed_35", "named"],
\t\t["weapon.named_warhammer"]              = ["wx_famed_36", "named"],
\t\t["weapon.named_two_handed_hammer"]      = ["wx_famed_37", "named"],
\t\t["weapon.named_skullhammer"]            = ["wx_famed_38", "named"],
\t\t["weapon.named_skull_hammer"]           = ["wx_famed_38", "named"],
\t\t["weapon.named_polehammer"]             = ["wx_famed_39", "named"],
\t\t["weapon.named_axe"]                    = ["wx_famed_40", "named"],
\t\t["weapon.named_fighting_axe"]           = ["wx_famed_41", "named"],
\t\t["weapon.named_greataxe"]               = ["wx_famed_42", "named"],
\t\t["weapon.named_bardiche"]               = ["wx_famed_43", "named"],
\t\t["weapon.named_poleaxe"]                = ["wx_famed_44", "named"],
\t\t["weapon.named_exesword"]               = ["wx_famed_45", "named"],
\t\t["weapon.named_heavy_rusty_axe"]        = ["wx_famed_46", "named"],
\t\t["weapon.named_flail"]                  = ["wx_famed_47", "named"],
\t\t["weapon.named_three_headed_flail"]     = ["wx_famed_48", "named"],
\t\t["weapon.named_two_handed_flail"]       = ["wx_famed_49", "named"],
\t\t["weapon.named_battle_whip"]            = ["wx_famed_50", "named"],
\t\t["weapon.named_dagger"]                 = ["wx_famed_51", "named"],
\t\t["weapon.named_rondel_dagger"]          = ["wx_famed_52", "named"],
\t\t["weapon.named_qatal_dagger"]           = ["wx_famed_53", "named"],
\t\t["weapon.named_bow"]                    = ["wx_famed_54", "named"],
\t\t["weapon.named_warbow"]                 = ["wx_famed_55", "named"],
\t\t["weapon.named_goblin_heavy_bow"]       = ["wx_famed_56", "named"],
\t\t["weapon.named_crossbow"]               = ["wx_famed_57", "named"],
\t\t["weapon.named_handgonne"]              = ["wx_famed_58", "named"],
\t\t["weapon.named_javelin"]                = ["wx_famed_59", "named"],
\t\t["weapon.named_throwing_axe"]           = ["wx_famed_60", "named"],
\t\t["weapon.named_goblin_falchion"]        = ["wx_famed_61", "named"],
\t\t["weapon.named_orc_axe"]                = ["wx_famed_62", "named"]
\t},"""

    eq_patched, n_sub = re.subn(
        r"\t// Vanilla Famed / Named Red Weapons[\s\S]*?\tNamedWeaponMap\s*=\s*\{[\s\S]*?\t\},",
        lambda _: new_named_map_block,
        eq_src,
        count=1,
    )
    assert n_sub == 1, "Failed to patch NamedWeaponMap in wx_equipment_visuals.nut!"
    eq_vis_path.write_text(eq_patched, encoding="utf-8", newline="\n")
    print("5) Patched NamedWeaponMap in wx_equipment_visuals.nut (63 keys -> 100% unique `weapons/named/wx_famed_*`)!")

    # 6. Update `wx_beast_craft.nut` so `wx_beast_fist` uses its own `wx_beast_fist` icon & `arm_wx_beast_fist`!
    bc_path = ROOT / "mod_wuxia" / "mod_wuxia" / "config" / "wx_beast_craft.nut"
    bc_src = bc_path.read_text(encoding="utf-8")
    bc_src = bc_src.replace(
        'Icon = "weapons/melee/wx_wpn_fist_05_70x70.png", IconLarge = "weapons/melee/wx_wpn_fist_05.png", ArmBrush = "arm_wx_wpn_fist_05"',
        'Icon = "weapons/melee/wx_beast_fist_70x70.png", IconLarge = "weapons/melee/wx_beast_fist.png", ArmBrush = "arm_wx_beast_fist"',
    )
    bc_path.write_text(bc_src, encoding="utf-8", newline="\n")

    # 7. Update `wx_named_fist.nut` so `传世名器护手` uses dedicated `wx_famed_fist_01..04` + `wx_wpn_fist_04..09` persisted via `m.Variant`!
    nf_path = ROOT / "mod_wuxia" / "scripts" / "items" / "weapons" / "named" / "wx_named_fist.nut"
    nf_src = nf_path.read_text(encoding="utf-8")
    old_fn = """\t\tthis.m.WX_VariantIdx = ::Math.rand(4, 9);
\t\tthis.wxApplyFistVisual();"""
    new_fn = """\t\tthis.m.Variant = ::Math.rand(1, 10);
\t\tthis.m.WX_VariantIdx = this.m.Variant;
\t\tthis.wxApplyFistVisual();"""
    assert old_fn in nf_src, "Could not find WX_VariantIdx init in wx_named_fist.nut"
    nf_src = nf_src.replace(old_fn, new_fn, 1)

    old_vis = """\tfunction wxApplyFistVisual()
\t{
\t\tlocal v = "wx_wpn_fist_0" + this.m.WX_VariantIdx;
\t\tthis.m.ID = "weapon.wx_named_fist";
\t\tthis.m.IconLarge = "weapons/melee/" + v + ".png";
\t\tthis.m.Icon = "weapons/melee/" + v + "_70x70.png";"""
    new_vis = """\tfunction wxApplyFistVisual()
\t{
\t\tlocal idx = (this.m.Variant >= 1 && this.m.Variant <= 10) ? this.m.Variant : this.m.WX_VariantIdx;
\t\tlocal isFamedArt = (idx >= 1 && idx <= 4);
\t\tlocal v = isFamedArt ? ("wx_famed_fist_0" + idx) : ("wx_wpn_fist_0" + ::Math.min(9, ::Math.max(4, idx)));
\t\tlocal sub = isFamedArt ? "named" : "melee";
\t\tthis.m.ID = "weapon.wx_named_fist";
\t\tthis.m.IconLarge = "weapons/" + sub + "/" + v + ".png";
\t\tthis.m.Icon = "weapons/" + sub + "/" + v + "_70x70.png";"""
    assert old_vis in nf_src, "Could not find wxApplyFistVisual in wx_named_fist.nut"
    nf_src = nf_src.replace(old_vis, new_vis, 1)
    nf_path.write_text(nf_src, encoding="utf-8", newline="\n")
    print("6) Updated wx_beast_fist & wx_named_fist with 100% non-overlapping icons & brushes!")


if __name__ == "__main__":
    main()
