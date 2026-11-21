#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Playtest Visual Overhaul Builder:
  1. Generates 15 new distinct Faction & Regional Settlement Banners (`wx_fbanner_noble_03..10`,
     `wx_fbanner_south_02..03`, `wx_fbanner_civ_01..06`) in `art/world_entity/` + `mod_wuxia/gfx/ui/banners/`
     and registers them in `art/world_entity/_meta.json` so every Noble House, Oasis State & Regional Town
     flies a distinct Chinese standard on the world map.
  2. Grounds all 7 Town Interior flanking house sets (`wx_ui_houses_*_left/right.png`) with extended
     weathered stone plinths down to `y=548` (eliminating the floating mid-air cutoff on left/right edges).
  3. Builds painterly Song/Ming bluestone stepped town square & pathway overlays (`wx_ui_pathway_stone.png`,
     `_night`, `_snow`, `_snow_night` and `wx_ui_pathway_sand.png`, `_night`) for `UIRampPathway`, turning the
     bare green central mound into a cohesive paved Jianghu town square.
  4. Upgrades `wx_bldg_marketplace` & `wx_bldg_crowd` scale and grounds shop buildings cleanly.
  5. Recompiles `.brush` atlases (`compile_wuxia_brushes.py`) so all 19 left-facing enemy busts now face
     3/4-right in `.brush` (facing LEFT toward the player in combat!) and all new world banners are packed.
"""

import colorsys
import json
import math
import os
import random
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))

import build_wuxia_bust_system as bsys
import compile_wuxia_brushes as brush_compiler
from process_wave_56_62_world_and_banners import (
    SHEET57_TOWN_UI_ARCH,
    make_ui_night_layer,
    make_ui_snow_layer,
    remove_stray_specks,
)
from repair_town_and_weapon_icons import clean_sect_center_mist, clean_water_house_gable_edge

ART_DIR = ROOT / "art"
HD_DIR = ART_DIR / "hd"
WE_DIR = ART_DIR / "world_entity"
ORIG_BLDG_DIR = ART_DIR / "town_buildings_orig"
MOD_SET_DIR = ROOT / "mod_wuxia" / "gfx" / "ui" / "settlements"
MOD_UI_BANNERS = ROOT / "mod_wuxia" / "gfx" / "ui" / "banners"


def recolor_banner_cloth(src_rgba: Image.Image, target_hue_deg: float, sat_mult: float = 1.05, val_mult: float = 1.0) -> Image.Image:
    """
    Shifts the dyed silk cloth pixels of a Chinese dragon-crossbar banner (`y=20..82`, `x=12..44`)
    while preserving metallic gold/silver dragon crossbars, spearhead, dark ink outlines & white highlights!
    """
    im = src_rgba.convert("RGBA").copy()
    w, h = im.size
    px = im.load()
    target_h = (target_hue_deg % 360.0) / 360.0

    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 16:
                continue
            # Preserve top spearhead, red tassel & bronze dragon crossbar (`y < int(h * 0.23)`)
            if y < int(h * 0.23):
                continue
            rf, gf, bf = r / 255.0, g / 255.0, b / 255.0
            hh, ss, vv = colorsys.rgb_to_hsv(rf, gf, bf)
            # Keep crisp ink outlines (`vv < 0.13`), silver/white crests (`ss < 0.16 and vv > 0.62`),
            # and bright metallic gold embroidery/borders (`0.08 <= hh <= 0.155 and ss > 0.35 and vv > 0.48`)
            if vv < 0.12:
                continue
            if ss < 0.15 and vv > 0.58:
                continue
            if 0.085 <= hh <= 0.155 and ss > 0.36 and vv > 0.50:
                continue

            # Blend cloth pixels smoothly toward target heraldic hue
            new_s = max(0.08, min(0.92, max(ss, 0.38) * sat_mult))
            new_v = max(0.08, min(0.95, vv * val_mult))
            nr, ng, nb = colorsys.hsv_to_rgb(target_h, new_s, new_v)
            px[x, y] = (int(round(nr * 255)), int(round(ng * 255)), int(round(nb * 255)), a)
    return im


def build_distinct_world_banners():
    """
    Creates 15 additional distinct world & UI banners (`wx_fbanner_noble_03..10`,
    `wx_fbanner_south_02..03`, `wx_fbanner_civ_01..06`) so settlements & factions never look identical.
    """
    MOD_UI_BANNERS.mkdir(parents=True, exist_ok=True)
    # Spec: (new_id, base_id, hue_deg_or_None, sat_mult, val_mult)
    specs = [
        # Noble Houses 03..10 (01 & 02 already exist!)
        ("wx_fbanner_noble_03", "banner_51", 215.0, 0.95, 1.08),  # Deep Imperial Navy & Gold Dragon
        ("wx_fbanner_noble_04", "banner_55", 352.0, 1.05, 1.02),  # Crimson & White Tiger
        ("wx_fbanner_noble_05", "banner_56", 14.0,  1.10, 1.02),  # Vermilion-Gold Vermilion Bird
        ("wx_fbanner_noble_06", "banner_57", 168.0, 1.05, 1.08),  # Dark Jade-Bronze Xuanwu Tortoise
        ("wx_fbanner_noble_07", "banner_58", 32.0,  0.95, 1.06),  # Ochre-Bronze Taotie War Shield
        ("wx_fbanner_noble_08", "banner_59", 278.0, 1.00, 1.04),  # Royal Purple Peacock Crest
        ("wx_fbanner_noble_09", "banner_60", 42.0,  1.05, 1.00),  # Amber-Gold Fierce Tiger
        ("wx_fbanner_noble_10", "wx_fbanner_noble_02", 142.0, 0.88, 0.98),  # Forest-Emerald Gold Qilin

        # Oasis City-States 02..03 (01 already exists!)
        ("wx_fbanner_south_02", "banner_53", 36.0,  1.08, 1.02),  # Saffron-Gold Oasis Lotus
        ("wx_fbanner_south_03", "wx_fbanner_south_01", 206.0, 1.12, 1.02),  # Lapis-Azure Sacred Sun

        # Regional Civilian Settlements 01..06 (Towns, Sect Mountains, Monasteries, Water Ports, Snow, Villages)
        ("wx_fbanner_civ_01",   "banner_54", 155.0, 0.85, 1.02),  # Celadon-Jade Crossed Blades (Central Towns)
        ("wx_fbanner_civ_02",   "banner_52", 224.0, 0.92, 1.05),  # Indigo Twin Cranes Taiji (Sect Mountain Towns)
        ("wx_fbanner_civ_03",   "banner_53", 24.0,  0.95, 0.98),  # Warm Cinnamon-Gold Lotus (Zen Monastery Towns)
        ("wx_fbanner_civ_04",   "banner_57", 196.0, 1.10, 1.15),  # River-Cerulean Tortoise (Jianghuai & Coastal Water Ports)
        ("wx_fbanner_civ_05",   "banner_62", 205.0, 0.45, 1.02),  # Frost-Silver Spirit Crest (Northern / Snow Towns)
        ("wx_fbanner_civ_06",   "banner_54", 28.0,  0.80, 0.94),  # Warm Russet-Hemp Town Guild Flag (Rural Villages)
    ]

    meta_path = WE_DIR / "_meta.json"
    meta = json.loads(meta_path.read_text(encoding="utf-8"))
    existing_ids = {m["id"]: idx for idx, m in enumerate(meta)}

    for new_id, base_id, hue_deg, sm, vm in specs:
        we_src = Image.open(WE_DIR / f"{base_id}.png").convert("RGBA")
        we_out = recolor_banner_cloth(we_src, hue_deg, sm, vm) if hue_deg is not None else we_src.copy()
        we_out.save(WE_DIR / f"{new_id}.png")

        rec = {"id": new_id, "file": f"{new_id}.png", "w": we_out.width, "h": we_out.height, "ox": 0, "oy": 28}
        if new_id in existing_ids:
            meta[existing_ids[new_id]] = rec
        else:
            meta.append(rec)
            existing_ids[new_id] = len(meta) - 1

        # Also generate UI banner (`gfx/ui/banners/<new_id>.png` & `<new_id>s.png`) if HD source exists
        hd_p = HD_DIR / f"{base_id}.png"
        if hd_p.exists():
            hd_src = Image.open(hd_p).convert("RGBA")
            hd_re = recolor_banner_cloth(hd_src, hue_deg, sm, vm) if hue_deg is not None else hd_src.copy()
            ui_big = brush_compiler.fit_canvas(hd_re, 102, 160, pad=2)
            ui_sm = brush_compiler.fit_canvas(hd_re, 51, 80, pad=1)
            ui_big.save(MOD_UI_BANNERS / f"{new_id}.png")
            ui_sm.save(MOD_UI_BANNERS / f"{new_id}s.png")

    meta_path.write_text(json.dumps(meta, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Generated {len(specs)} distinct world & UI banners in {WE_DIR} and updated _meta.json.")


def extend_house_stone_plinth(im_s: Image.Image, target_extra_h: int = 62) -> Image.Image:
    """
    Paints a solid coursed Song/Ming stone embankment/terrace wall BEHIND the lower foundation of a
    flanking house cluster (`y = h - 34 .. h + target_extra_h`), so wooden stilts & crisp ink outlines
    sit cleanly in front of an unbroken stone river-bank / town terrace with zero mid-air gaps!
    """
    w, h = im_s.size
    total_h = h + target_extra_h
    src_px = im_s.load()

    # Find horizontal span `[x_first, x_last]` where the house foundation exists in the lower third
    x_first, x_last = w, -1
    col_lowest = [-1] * w
    for x in range(w):
        for y in range(h - 1, int(h * 0.45), -1):
            if src_px[x, y][3] > 140:
                col_lowest[x] = y
                if x < x_first:
                    x_first = x
                if x > x_last:
                    x_last = x
                break

    if x_last < x_first:
        return im_s

    wall = Image.new("RGBA", (w, total_h), (0, 0, 0, 0))
    wpx = wall.load()
    rng = random.Random(w * 37 + h)

    # Precompute discrete masonry course heights (11..14px)
    courses = []
    cy = max(0, h - 42)
    c_idx = 0
    while cy < total_h:
        ch = 11 + (c_idx % 3)
        courses.append((cy, min(total_h, cy + ch), 28 + (c_idx % 2) * 6, (c_idx % 2) * 15))
        cy += ch
        c_idx += 1

    for c_i, (cy0, cy1, brick_w, stagger) in enumerate(courses):
        for y in range(cy0, cy1):
            is_h_mortar = (y == cy0)
            is_top_lip = (y == cy0 + 1)
            fade_bot = 1.0
            if y > total_h - 14:
                fade_bot = max(0.0, (total_h - y) / 14.0)

            for x in range(x_first, x_last + 1):
                # Do not start wall above the house silhouette in columns that haven't begun yet
                if col_lowest[x] < 0:
                    continue
                top_start = min(col_lowest[x] - 6, h - 22)
                if y < top_start:
                    continue
                # Slight inward taper at inner edge so terrace tucks cleanly behind ramp_01
                edge_dist = min(x - x_first, x_last - x)
                edge_fade = min(1.0, (edge_dist + 2) / 6.0) if (x > 12 and x < w - 12) else 1.0

                brick_idx = (x + stagger) // brick_w
                is_v_mortar = (((x + stagger) % brick_w) == 0)
                b_tone = (((c_i * 73 + brick_idx * 389) & 0xFF) / 255.0 - 0.5) * 14.0
                depth_shade = max(0.56, 1.0 - max(0, y - (h - 18)) / float(target_extra_h + 46))
                grain = rng.randint(-4, 4)

                r = int((76 + b_tone) * depth_shade) + grain
                g = int((73 + b_tone) * depth_shade) + grain
                b = int((66 + b_tone * 0.9) * depth_shade) + grain

                if is_h_mortar or is_v_mortar:
                    r, g, b = int(r * 0.54), int(g * 0.54), int(b * 0.54)
                elif is_top_lip:
                    r, g, b = min(255, r + 10), min(255, g + 10), min(255, b + 8)

                alpha = int(255 * fade_bot * edge_fade)
                if alpha > 4:
                    wpx[x, y] = (max(10, min(255, r)), max(10, min(255, g)), max(9, min(255, b)), alpha)

    # Composite original crisp house sprite ON TOP OF the stone embankment wall!
    wall.alpha_composite(im_s, (0, 0))
    return wall


def rebuild_grounded_town_houses():
    left_flush_houses = {"wx_ui_houses_04", "wx_ui_houses_fort"}

    for (_, aid, role, _, _, _, _) in SHEET57_TOWN_UI_ARCH:
        if role == "center":
            continue
        rgba = Image.open(HD_DIR / f"{aid}.png").convert("RGBA")
        if aid == "wx_ui_houses_water":
            rgba = clean_water_house_gable_edge(rgba)
        tc = bsys.decontaminate_white_fringe(bsys.tight_crop(remove_stray_specks(rgba, min_pixels=25)), passes=1)

        if aid in left_flush_houses:
            left_src = tc
            right_src = ImageOps.mirror(tc)
        else:
            left_src = ImageOps.mirror(tc)
            right_src = tc

        for side, (x0, y0, x1, y1), src_im in (
            ("left",  (0, 148, 376, 492), left_src),
            ("right", (648, 152, 1024, 492), right_src),
        ):
            bw, bh = x1 - x0, y1 - y0
            s = min(bw / float(src_im.width), bh / float(src_im.height))
            nw, nh = max(1, int(round(src_im.width * s))), max(1, int(round(src_im.height * s)))
            im_s = src_im.resize((nw, nh), Image.Resampling.LANCZOS)
            im_s = im_s.filter(ImageFilter.UnsharpMask(radius=0.9, percent=115, threshold=3))
            im_grounded = extend_house_stone_plinth(im_s, target_extra_h=64)

            layer = Image.new("RGBA", (1024, 588), (0, 0, 0, 0))
            pos_x = 0 if side == "left" else (1024 - im_grounded.width)
            pos_y = y1 - nh
            layer.alpha_composite(im_grounded, (pos_x, pos_y))

            night_im = make_ui_night_layer(layer)
            snow_im = make_ui_snow_layer(layer)
            snow_night_im = make_ui_night_layer(snow_im)

            base_n = f"{aid}_{side}"
            layer.save(MOD_SET_DIR / f"{base_n}.png")
            night_im.save(MOD_SET_DIR / f"{base_n}_night.png")
            snow_im.save(MOD_SET_DIR / f"{base_n}_snow.png")
            snow_night_im.save(MOD_SET_DIR / f"{base_n}_snow_night.png")

    print("Rebuilt all 7 flanking house sets (`wx_ui_houses_*_left/right`) with grounded stone plinths (zero mid-air gaps).")


def build_town_bluestone_pathway():
    """
    Creates painterly 1024x588 `wx_ui_pathway_stone.png` (+ `_night`, `_snow`, `_snow_night`)
    and `wx_ui_pathway_sand.png` (+ `_night`) for `settlement.m.UIRampPathway`.
    Uses discrete precomputed horizontal perspective courses (`y=278..588`) so every flagstone slab
    and stair step is flat, crisp, and 100% free of moiré artifacts!
    """
    W, H = 1024, 588

    def make_pathway(is_sand: bool = False) -> Image.Image:
        im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        px = im.load()
        rng = random.Random(20261122 + (7 if is_sand else 0))

        if is_sand:
            stone_base = (142, 121, 88)
            mortar_col = (66, 53, 36)
            earth_col = (116, 98, 68)
        else:
            stone_base = (108, 104, 94)
            mortar_col = (42, 39, 34)
            earth_col = (76, 78, 56)

        y_top = 278
        courses = []
        cy = y_top
        c_idx = 0
        while cy < H:
            prog = (cy - y_top) / float(H - y_top)
            ch = max(5, int(round(5.0 + (prog ** 1.15) * 12.0)))
            sw = max(20, int(round(22.0 + (prog ** 1.05) * 34.0)))
            stagger = (sw // 2) if (c_idx % 2 == 1) else 0
            is_step_course = (cy < 405 and (c_idx % 3 == 0))
            courses.append((c_idx, cy, min(H, cy + ch), sw, stagger, is_step_course))
            cy += ch
            c_idx += 1

        for c_idx, cy0, cy1, slab_w, stagger, is_step_course in courses:
            for y in range(cy0, cy1):
                t = (y - y_top) / float(H - 1 - y_top)
                cx = 512.0 + math.sin(t * 2.4) * 10.0
                main_hw = 82.0 + (t ** 1.08) * 172.0

                br_l = cx - main_hw
                br_r = cx + main_hw

                if 332 <= y <= 432:
                    bt = max(0.0, 1.0 - abs((y - 382.0) / 50.0))
                    s_ease = bt * bt * (3.0 - 2.0 * bt)
                    br_l = min(br_l, cx - main_hw - s_ease * 108.0)
                    br_r = max(br_r, cx + main_hw + s_ease * 108.0)

                if 438 <= y <= 578:
                    bt2 = max(0.0, 1.0 - abs((y - 512.0) / 70.0))
                    s_ease2 = bt2 * bt2 * (3.0 - 2.0 * bt2)
                    br_l = min(br_l, cx - main_hw - s_ease2 * 135.0)
                    br_r = max(br_r, cx + main_hw + s_ease2 * 135.0)

                in_row = y - cy0
                is_h_joint = (in_row == 0)
                is_riser_dark = is_step_course and (in_row <= 1)
                is_riser_lit = is_step_course and (in_row == 2)

                top_fade = min(1.0, (y - y_top) / 14.0)
                wob_l = math.sin(y * 0.17) * 5.0 + math.cos(y * 0.41) * 2.5
                wob_r = math.cos(y * 0.15) * 5.0 + math.sin(y * 0.39) * 2.5
                eff_l = br_l + wob_l
                eff_r = br_r + wob_r

                x_min = max(0, int(eff_l - 22))
                x_max = min(W - 1, int(eff_r + 22))

                for x in range(x_min, x_max + 1):
                    if x < eff_l:
                        d_out = eff_l - x
                    elif x > eff_r:
                        d_out = x - eff_r
                    else:
                        d_out = 0.0

                    if d_out > 20.0:
                        continue

                    if d_out > 0.0:
                        ew = 1.0 - d_out / 20.0
                        alpha = int(165 * (ew ** 1.5) * top_fade)
                        if alpha <= 4:
                            continue
                        n = rng.randint(-6, 6)
                        px[x, y] = (
                            max(0, min(255, earth_col[0] + n)),
                            max(0, min(255, earth_col[1] + n)),
                            max(0, min(255, earth_col[2] + n)),
                            alpha,
                        )
                        continue

                    d_in = min(x - eff_l, eff_r - x)
                    is_curb_border = (d_in < 3.0)
                    is_curb_block = (d_in < 11.0)

                    slab_idx = int((x + stagger) // slab_w)
                    in_slab_x = (x + stagger) % slab_w
                    is_v_joint = (in_slab_x == 0) if not is_curb_block else ((y % 18) == 0)

                    slab_tone = (((c_idx * 173 + slab_idx * 613) & 0xFF) / 255.0 - 0.5) * 16.0
                    if is_curb_block:
                        slab_tone -= 8.0
                    grain = rng.randint(-4, 4)

                    r = int(stone_base[0] + slab_tone) + grain
                    g = int(stone_base[1] + slab_tone * 0.95) + grain
                    b = int(stone_base[2] + slab_tone * 0.85) + grain

                    if is_riser_dark or is_curb_border:
                        r = int(mortar_col[0] * 0.85)
                        g = int(mortar_col[1] * 0.85)
                        b = int(mortar_col[2] * 0.85)
                    elif is_riser_lit:
                        r, g, b = min(255, r + 16), min(255, g + 15), min(255, b + 12)
                    elif is_h_joint or is_v_joint:
                        r = int(r * 0.60 + mortar_col[0] * 0.40)
                        g = int(g * 0.60 + mortar_col[1] * 0.40)
                        b = int(b * 0.60 + mortar_col[2] * 0.40)

                    alpha = int(232 * top_fade)
                    px[x, y] = (max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)), alpha)

        im = im.filter(ImageFilter.GaussianBlur(radius=0.35))
        im = im.filter(ImageFilter.UnsharpMask(radius=0.8, percent=105, threshold=2))
        return im

    stone_day = make_pathway(is_sand=False)
    stone_night = make_ui_night_layer(stone_day)
    stone_snow = make_ui_snow_layer(stone_day)
    stone_snow_night = make_ui_night_layer(stone_snow)

    stone_day.save(MOD_SET_DIR / "wx_ui_pathway_stone.png")
    stone_night.save(MOD_SET_DIR / "wx_ui_pathway_stone_night.png")
    stone_snow.save(MOD_SET_DIR / "wx_ui_pathway_stone_snow.png")
    stone_snow_night.save(MOD_SET_DIR / "wx_ui_pathway_stone_snow_night.png")

    sand_day = make_pathway(is_sand=True)
    sand_night = make_ui_night_layer(sand_day)
    sand_day.save(MOD_SET_DIR / "wx_ui_pathway_sand.png")
    sand_night.save(MOD_SET_DIR / "wx_ui_pathway_sand_night.png")

    print("Generated crisp horizontal-course Song/Ming bluestone & sandstone pathways (`wx_ui_pathway_*`).")


def add_grounded_shadow(bldg_rgba: Image.Image) -> Image.Image:
    """Adds a soft grounded elliptical contact shadow under the base of a town shop building sprite."""
    w, h = bldg_rgba.size
    bbox = bldg_rgba.getchannel("A").point(lambda a: 255 if a > 20 else 0).getbbox()
    if not bbox:
        return bldg_rgba
    bx0, by0, bx1, by1 = bbox
    sh = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    dr = ImageDraw.Draw(sh)
    pad_x = max(4, int((bx1 - bx0) * 0.04))
    sh_top = max(0, by1 - 22)
    sh_bot = min(h - 1, by1 + 2)
    dr.ellipse((max(0, bx0 - pad_x), sh_top, min(w - 1, bx1 + pad_x), sh_bot), fill=(12, 10, 8, 138))
    sh = sh.filter(ImageFilter.GaussianBlur(radius=5.0))
    sh.alpha_composite(bldg_rgba, (0, 0))
    return sh


def upgrade_shop_building_proportions():
    resize_targets = {
        "wx_bldg_marketplace":   (412, 174),
        "wx_bldg_crowd":         (232, 118),
        "wx_bldg_tavern":        (390, 228),
        "wx_bldg_training_hall": (380, 232),
        "wx_bldg_port":          (320, 240),
        "wx_bldg_arena":         (370, 215),
    }

    updated = 0
    for bak in sorted(ORIG_BLDG_DIR.glob("wx_bldg_*.png")):
        dst = MOD_SET_DIR / bak.name
        src = Image.open(bak).convert("RGBA")
        bbox = src.getchannel("A").point(lambda a: 255 if a > 12 else 0).getbbox()
        if bbox:
            src = src.crop(bbox)

        tw, th = None, None
        for prefix, dims in resize_targets.items():
            if bak.stem == prefix or bak.stem.startswith(prefix + "_"):
                tw, th = dims
                break
        if tw is None:
            # Keep original dimensions for temple/weaponsmith/armorsmith/fletcher/alchemist/taxidermist/kennel/barber
            orig_im = Image.open(bak).convert("RGBA")
            out = add_grounded_shadow(orig_im)
            out.save(dst)
            updated += 1
            continue

        scale = min((tw - 10) / float(src.width), (th - 8) / float(src.height))
        nw = max(1, int(round(src.width * scale)))
        nh = max(1, int(round(src.height * scale)))
        rs = src.resize((nw, nh), Image.Resampling.LANCZOS)
        out = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
        out.alpha_composite(rs, ((tw - nw) // 2, th - nh - 3))
        out = add_grounded_shadow(out)
        out.save(dst)
        updated += 1

    print(f"Upgraded proportions & grounded shadows on {updated} town building sprites.")


def render_scratch_verifications(scratch_dir: Path):
    scratch_dir.mkdir(parents=True, exist_ok=True)
    # 1. Verify all 50 Enemy Busts after mirroring left-facing ones
    manifest = json.loads((ART_DIR / "manifest.json").read_text(encoding="utf-8"))
    left_set = {
        "wx_char_enemy_corpse", "wx_char_enemy_yaoren", "wx_enemy_bandit_lord", "wx_enemy_nomad_khan",
        "wx_enemy_garrison_capt", "wx_enemy_shenji_officer", "wx_enemy_sword_saint", "wx_enemy_hedge_general",
        "wx_enemy_blade_dancer", "wx_enemy_wudu_shaman", "wx_enemy_wudu_overseer", "wx_enemy_barb_chosen",
        "wx_enemy_barb_drummer", "wx_enemy_yaoren_lord", "wx_enemy_corpse_taoist", "wx_enemy_tomb_wraith",
        "wx_enemy_ancient_lord", "wx_enemy_blood_vampire", "wx_enemy_emei_sword",
    }
    enemies = []
    for a in manifest["assets"]:
        aid = a["id"]
        hp = a.get("hdPath")
        if (aid.startswith("wx_enemy_") or aid.startswith("wx_char_enemy_")) and hp and (ROOT / hp).exists():
            im = Image.open(ROOT / hp).convert("RGBA")
            if aid in left_set:
                im = ImageOps.mirror(im)
            enemies.append((aid, im))

    cols, cw, ch = 8, 130, 145
    rows = (len(enemies) + cols - 1) // cols
    esheet = Image.new("RGBA", (cols * cw, rows * ch), (28, 26, 24, 255))
    dr = ImageDraw.Draw(esheet)
    for idx, (aid, im) in enumerate(enemies):
        cx, cy = (idx % cols) * cw, (idx // cols) * ch
        ims = im.copy()
        ims.thumbnail((108, 112), Image.Resampling.LANCZOS)
        esheet.alpha_composite(ims, (cx + (cw - ims.width) // 2, cy + 4))
        dr.text((cx + 4, cy + 122), f"{idx}:{aid.replace('wx_enemy_', '').replace('wx_char_enemy_', 'c_')[:16]}", fill=(180, 245, 180, 255))
    esheet.save(scratch_dir / "verify_enemies_after.png")

    # 2. Verify all World Banners (`wx_fbanner_*`)
    fb_files = sorted(WE_DIR.glob("wx_fbanner_*.png"))
    bcols = 7
    brows = (len(fb_files) + bcols - 1) // bcols
    bsheet = Image.new("RGBA", (bcols * 96, brows * 124), (30, 28, 24, 255))
    bdr = ImageDraw.Draw(bsheet)
    for idx, fp in enumerate(fb_files):
        im = Image.open(fp).convert("RGBA")
        cx, cy = (idx % bcols) * 96, (idx // bcols) * 124
        bsheet.alpha_composite(im, (cx + (96 - im.width) // 2, cy + 6))
        bdr.text((cx + 4, cy + 104), fp.stem.replace("wx_fbanner_", ""), fill=(240, 220, 165, 255))
    bsheet.save(scratch_dir / "verify_world_banners_after.png")

    # 3. Simulate exact `瓜洲古渡` Town Screen composite (`wx_bg_swamp` + `wx_ui_center_prefecture` +
    #    grounded `wx_ui_houses_water_left/right` + simulated green ramp + `wx_ui_pathway_stone` + 4 buildings!)
    comp = Image.open(MOD_SET_DIR / "wx_bg_swamp.jpg").convert("RGBA")
    comp.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_center_prefecture.png").convert("RGBA"))
    comp.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_houses_water_left.png").convert("RGBA"))
    comp.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_houses_water_right.png").convert("RGBA"))
    # Approximate vanilla `ramp_01` green hill shape for preview if vanilla dat isn't mounted in sandbox
    hill = Image.new("RGBA", (1024, 588), (0, 0, 0, 0))
    hdr = ImageDraw.Draw(hill)
    pts = [(0, 588), (0, 520), (165, 435), (295, 292), (512, 276), (725, 295), (860, 438), (1024, 522), (1024, 588)]
    hdr.polygon(pts, fill=(88, 98, 60, 248))
    hill = hill.filter(ImageFilter.GaussianBlur(radius=4.5))
    comp.alpha_composite(hill)
    comp.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_pathway_stone.png").convert("RGBA"))
    # Place the exact 4 buildings from the user's `瓜洲古渡` screenshot (`temple`, `marketplace`, `crowd`, `tavern`)
    temple = Image.open(MOD_SET_DIR / "wx_bldg_temple.png").convert("RGBA")
    market = Image.open(MOD_SET_DIR / "wx_bldg_marketplace.png").convert("RGBA")
    crowd = Image.open(MOD_SET_DIR / "wx_bldg_crowd.png").convert("RGBA")
    tavern = Image.open(MOD_SET_DIR / "wx_bldg_tavern.png").convert("RGBA")
    comp.alpha_composite(temple, (65, 588 - 44 - temple.height))
    comp.alpha_composite(tavern, (1024 - 65 - tavern.width, 588 - 44 - tavern.height))
    comp.alpha_composite(market, ((1024 - market.width) // 2, 296))
    comp.alpha_composite(crowd, ((1024 - crowd.width) // 2, 588 - 22 - crowd.height))
    comp.save(scratch_dir / "verify_town_guazhou.png")
    print("Saved verification previews into:", scratch_dir)


if __name__ == "__main__":
    town_only = "--town-only" in sys.argv
    if not town_only:
        build_distinct_world_banners()
    rebuild_grounded_town_houses()
    build_town_bluestone_pathway()
    if not town_only:
        upgrade_shop_building_proportions()
        brush_compiler.compile_all()
    scratch_out = Path(r"C:\Users\25647\.gemini\antigravity\brain\ddab900d-002d-4389-bbc9-bf40fa080c01\scratch")
    render_scratch_verifications(scratch_out)
