#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Repairs:
  1. 7 melee weapon icons (`wx_wpn_axe_01`, `axe_05`, `fist_04`, `fist_08`, `fist_09`, `flail_01`, `flail_02`)
     rebuilt cleanly from transparent `art/hd/*.png` (eliminating white/grey studio squares).
  2. Daytime Town Interior landscapes (`wx_bg_*.jpg`, 1024x588), center halls (`wx_ui_center_*.png`, 1024x588),
     architecturally oriented flanking houses (`wx_ui_houses_*_left/right.png`, 1024x588, zero mid-air ghost cuts),
     and full-resolution daytime shop buildings (`wx_bldg_*.png`) matching `_b.png` & `_night.png` 1:1.
"""

import os
import shutil
import sys
import zipfile
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))
import build_wuxia_bust_system as bsys
from process_wave_56_62_world_and_banners import (
    SHEET57_TOWN_UI_ARCH,
    extract_2x2_landscape_quads,
    make_ui_hover_highlight,
    make_ui_night_layer,
    make_ui_snow_layer,
    remove_stray_specks,
)

ART_DIR = ROOT / "art"
HD_DIR = ART_DIR / "hd"
SHEETS_DIR = ART_DIR / "sheets"
ORIG_BLDG_DIR = ART_DIR / "town_buildings_orig"
MOD_SET_DIR = ROOT / "mod_wuxia" / "gfx" / "ui" / "settlements"


def fit_icon_transparent(rgba: Image.Image, tw: int, th: int, pad_x: int = 4, pad_y: int = 4) -> Image.Image:
    bbox = rgba.getchannel("A").point(lambda a: 255 if a > 16 else 0).getbbox()
    src = rgba.crop(bbox) if bbox else rgba
    mw = max(1, tw - 2 * pad_x)
    mh = max(1, th - 2 * pad_y)
    # Keep 70x140 weapon icon crisp & centered (same visual scale as 70x70 stash icon)
    if tw == 70 and th == 140:
        mh = min(mh, 96)
    s = min(mw / float(src.width), mh / float(src.height))
    nw = max(1, int(round(src.width * s)))
    nh = max(1, int(round(src.height * s)))
    rs = src.resize((nw, nh), Image.Resampling.LANCZOS)
    out = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    out.alpha_composite(rs, ((tw - nw) // 2, (th - nh) // 2))
    return out


def repair_seven_weapon_icons():
    targets = [
        "wx_wpn_axe_01",
        "wx_wpn_axe_05",
        "wx_wpn_fist_04",
        "wx_wpn_fist_08",
        "wx_wpn_fist_09",
        "wx_wpn_flail_01",
        "wx_wpn_flail_02",
    ]
    mod_melee = ROOT / "mod_wuxia" / "gfx" / "ui" / "items" / "weapons" / "melee"
    wiki_melee = ART_DIR / "game" / "ui" / "items" / "weapons" / "melee"
    mod_melee.mkdir(parents=True, exist_ok=True)
    wiki_melee.mkdir(parents=True, exist_ok=True)

    for wid in targets:
        hd_im = Image.open(HD_DIR / f"{wid}.png").convert("RGBA")
        ic_140 = fit_icon_transparent(hd_im, 70, 140, pad_x=4, pad_y=6)
        ic_70 = fit_icon_transparent(hd_im, 70, 70, pad_x=4, pad_y=4)
        for d in (mod_melee, wiki_melee):
            ic_140.save(d / f"{wid}.png")
            ic_70.save(d / f"{wid}_70x70.png")
    print(f"Rebuilt {len(targets)} weapon icon pairs (70x140 + 70x70) cleanly from transparent HD sources.")


def clean_water_house_gable_edge(rgba: Image.Image) -> Image.Image:
    """
    In `art/hd/wx_ui_houses_water.png` (256x256), the rear white-walled gable's dark timber corner post
    sits around x=223, while x=224..250 has a chopped partial balcony from an adjacent building.
    Trimming cleanly along that architectural corner line eliminates any vertical cut in mid-air!
    """
    im = rgba.copy()
    w, h = im.size
    px = im.load()
    # Find exact roof overhang & wall corner x on the right side of the second house
    for y in range(h):
        # Eave tip at top of rear roof extends slightly further (~227) than the vertical wall post (~222)
        cut_x = 226 if y < 86 else 222
        for x in range(cut_x, w):
            px[x, y] = (0, 0, 0, 0)
        # Reinforce crisp dark ink vertical corner line along the trimmed wall (y=86..209)
        if 86 <= y <= 209:
            r, g, b, a = px[cut_x - 1, y]
            if a > 80:
                px[cut_x - 1, y] = (24, 20, 16, 255)
                r2, g2, b2, a2 = px[cut_x - 2, y]
                if a2 > 80:
                    px[cut_x - 2, y] = (max(0, int(r2 * 0.55)), max(0, int(g2 * 0.52)), max(0, int(b2 * 0.48)), 255)
    return im


def clean_sect_center_mist(rgba: Image.Image) -> Image.Image:
    """Strips the pale grey background mist wedge behind the left pine tree in `wx_ui_center_sect.png`."""
    im = rgba.copy()
    w, h = im.size
    px = im.load()
    for y in range(h):
        for x in range(68):
            r, g, b, a = px[x, y]
            if a > 0:
                sat = max(r, g, b) - min(r, g, b)
                lum = 0.299 * r + 0.587 * g + 0.114 * b
                if lum > 152 and sat < 24:
                    px[x, y] = (0, 0, 0, 0)
    return remove_stray_specks(im, min_pixels=30)


def repair_town_landscapes():
    MOD_SET_DIR.mkdir(parents=True, exist_ok=True)
    # 1. Sheet 62 (1376x768) -> plains, mountains, forest, swamp at full crisp 1024x588
    sh62 = Image.open(SHEETS_DIR / "sheet_62.jpg").convert("RGB")
    q62 = extract_2x2_landscape_quads(sh62)
    for idx, bid in enumerate(["wx_bg_plains", "wx_bg_mountains", "wx_bg_forest", "wx_bg_swamp"]):
        im = q62[idx].filter(ImageFilter.UnsharpMask(radius=1.0, percent=115, threshold=2))
        im.save(MOD_SET_DIR / f"{bid}.jpg", quality=93)

    # 2. Sheet 63 landscapes from `art/hd/wx_bg_*.jpg` (512x294 -> 1024x588 with crisp ink detail pass)
    for bid in ["wx_bg_snow", "wx_bg_desert", "wx_bg_coast", "wx_bg_steppe"]:
        src = Image.open(HD_DIR / f"{bid}.jpg").convert("RGB")
        up = src.resize((1024, 588), Image.Resampling.LANCZOS)
        up = up.filter(ImageFilter.UnsharpMask(radius=1.15, percent=135, threshold=2))
        up.save(MOD_SET_DIR / f"{bid}.jpg", quality=93)
    print("Rebuilt all 8 daytime `wx_bg_*.jpg` landscapes at crisp 1024x588.")


def repair_town_centers_and_houses():
    # Houses whose LEFT edge is the tall/cut wall (so `_left` = unmirrored at x=0, `_right` = mirrored at x=1024)
    left_flush_houses = {"wx_ui_houses_04", "wx_ui_houses_fort"}

    for (_, aid, role, bbox_target, _, _, _) in SHEET57_TOWN_UI_ARCH:
        rgba = Image.open(HD_DIR / f"{aid}.png").convert("RGBA")
        if aid == "wx_ui_center_sect":
            rgba = clean_sect_center_mist(rgba)

        tc = bsys.decontaminate_white_fringe(bsys.tight_crop(remove_stray_specks(rgba, min_pixels=25)), passes=1)

        if role == "center":
            x0, y0, x1, y1 = bbox_target
            y1_tucked = y1 + 14  # Tuck foundation cleanly behind `ramp_01.png` crest (`y~344`)
            bw, bh = x1 - x0, y1_tucked - y0
            s = min(bw / float(tc.width), bh / float(tc.height))
            nw, nh = max(1, int(round(tc.width * s))), max(1, int(round(tc.height * s)))
            im_s = tc.resize((nw, nh), Image.Resampling.LANCZOS)
            im_s = im_s.filter(ImageFilter.UnsharpMask(radius=0.9, percent=115, threshold=3))

            day_im = Image.new("RGBA", (1024, 588), (0, 0, 0, 0))
            px = x0 + (bw - nw) // 2
            py = y1_tucked - nh
            day_im.alpha_composite(im_s, (px, py))

            night_im = make_ui_night_layer(day_im)
            snow_im = make_ui_snow_layer(day_im)
            snow_night_im = make_ui_night_layer(snow_im)

            day_im.save(MOD_SET_DIR / f"{aid}.png")
            night_im.save(MOD_SET_DIR / f"{aid}_night.png")
            snow_im.save(MOD_SET_DIR / f"{aid}_snow.png")
            snow_night_im.save(MOD_SET_DIR / f"{aid}_snow_night.png")
        else:
            if aid in left_flush_houses:
                left_src = tc
                right_src = ImageOps.mirror(tc)
            else:
                # Right edge is taller/cut in HD (`01`, `02`, `03`, `sect`), so mirror for `_left` (x=0) and keep unmirrored for `_right` (x=1024)!
                left_src = ImageOps.mirror(tc)
                right_src = tc

            for side, (x0, y0, x1, y1), src_im in (
                ("left",  (0, 132, 356, 466), left_src),
                ("right", (668, 138, 1024, 466), right_src),
            ):
                bw, bh = x1 - x0, y1 - y0
                s = min(bw / float(src_im.width), bh / float(src_im.height))
                nw, nh = max(1, int(round(src_im.width * s))), max(1, int(round(src_im.height * s)))
                im_s = src_im.resize((nw, nh), Image.Resampling.LANCZOS)
                im_s = im_s.filter(ImageFilter.UnsharpMask(radius=0.9, percent=115, threshold=3))

                # Subtle bottom foundation feather (8px) so houses sit organically into `ramp_01.png` hillside grass
                w_s, h_s = im_s.size
                spx = im_s.load()
                for yy in range(max(0, h_s - 8), h_s):
                    fade = (h_s - 1 - yy) / 8.0 * 0.65 + 0.35
                    for xx in range(w_s):
                        r, g, b, a = spx[xx, yy]
                        if a > 0:
                            spx[xx, yy] = (r, g, b, int(a * fade))

                layer = Image.new("RGBA", (1024, 588), (0, 0, 0, 0))
                pos_x = 0 if side == "left" else (1024 - nw)
                pos_y = y1 - nh
                layer.alpha_composite(im_s, (pos_x, pos_y))

                night_im = make_ui_night_layer(layer)
                snow_im = make_ui_snow_layer(layer)
                snow_night_im = make_ui_night_layer(snow_im)

                base_n = f"{aid}_{side}"
                layer.save(MOD_SET_DIR / f"{base_n}.png")
                night_im.save(MOD_SET_DIR / f"{base_n}_night.png")
                snow_im.save(MOD_SET_DIR / f"{base_n}_snow.png")
                snow_night_im.save(MOD_SET_DIR / f"{base_n}_snow_night.png")

            # Remove stale unused `wx_ui_houses_XX.png` 180x136 thumbnail from mod_wuxia/gfx/ui/settlements if present
            stale = MOD_SET_DIR / f"{aid}.png"
            if stale.exists():
                stale.unlink()

    print("Rebuilt all 9 `wx_ui_center_*` halls and 7 `wx_ui_houses_*_left/right` sets at crisp 1024x588.")


def repair_town_shop_buildings():
    resize_targets = {
        "wx_bldg_marketplace":   (380, 138),
        "wx_bldg_crowd":         (182, 90),
        "wx_bldg_tavern":        (390, 228),
        "wx_bldg_training_hall": (380, 232),
        "wx_bldg_port":          (320, 240),
        "wx_bldg_arena":         (370, 215),
    }

    restored = 0
    for bak in sorted(ORIG_BLDG_DIR.glob("wx_bldg_*.png")):
        dst = MOD_SET_DIR / bak.name
        matched = False
        for prefix, (tw, th) in resize_targets.items():
            if bak.stem == prefix or bak.stem.startswith(prefix + "_"):
                src = Image.open(bak).convert("RGBA")
                bbox = src.getchannel("A").point(lambda a: 255 if a > 12 else 0).getbbox()
                if bbox:
                    src = src.crop(bbox)
                scale = min((tw - 8) / float(src.width), (th - 6) / float(src.height))
                nw = max(1, int(round(src.width * scale)))
                nh = max(1, int(round(src.height * scale)))
                rs = src.resize((nw, nh), Image.Resampling.LANCZOS)
                out = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
                out.alpha_composite(rs, ((tw - nw) // 2, th - nh - 2))
                out.save(dst)
                matched = True
                break
        if not matched:
            shutil.copy2(bak, dst)
        restored += 1
    print(f"Restored {restored} full-resolution `wx_bldg_*.png` shop sprites (day, night, closed, hover).")


def render_verification_previews(scratch_dir: Path):
    scratch_dir.mkdir(parents=True, exist_ok=True)
    data_dat = Path(r"F:\SteamLibrary\steamapps\common\Battle Brothers\data\data_001.dat")
    slot_frame = None
    ramp_01 = None
    water_01 = None
    if data_dat.exists():
        with zipfile.ZipFile(data_dat, "r") as zf:
            slot_frame = Image.open(zf.open("gfx/ui/skin/inventory_slot.png")).convert("RGBA")
            ramp_01 = Image.open(zf.open("gfx/ui/settlements/ramp_01.png")).convert("RGBA")
            water_01 = Image.open(zf.open("gfx/ui/settlements/water_01.png")).convert("RGBA")

    # 1. Verify 7 repaired weapons on dark brown BB stash slots
    wpns = ["wx_wpn_axe_01", "wx_wpn_axe_05", "wx_wpn_fist_04", "wx_wpn_fist_08", "wx_wpn_fist_09", "wx_wpn_flail_01", "wx_wpn_flail_02"]
    wsheet = Image.new("RGBA", (len(wpns) * 92 + 16, 250), (35, 25, 18, 255))
    dr = ImageDraw.Draw(wsheet)
    mod_melee = ROOT / "mod_wuxia" / "gfx" / "ui" / "items" / "weapons" / "melee"
    for i, wid in enumerate(wpns):
        ox = 12 + i * 92
        if slot_frame is not None:
            wsheet.alpha_composite(slot_frame, (ox, 12))
        ic70 = Image.open(mod_melee / f"{wid}_70x70.png").convert("RGBA")
        ic140 = Image.open(mod_melee / f"{wid}.png").convert("RGBA")
        wsheet.alpha_composite(ic70, (ox + 2, 14))
        wsheet.alpha_composite(ic140, (ox + 2, 96))
        dr.text((ox, 234), wid.replace("wx_wpn_", ""), fill=(235, 215, 170, 255))
    wsheet.save(scratch_dir / "verify_repaired_weapons.png")

    # 2. Verify 2 full 1024x588 Town Screen composites:
    #    (a) Coastal Fishing Village (`鄱阳渡埠` exact reproduction!)
    #    (b) Mid-size Jianghu Prefecture Town
    if ramp_01 is not None and water_01 is not None:
        comp_a = Image.open(MOD_SET_DIR / "wx_bg_coast.jpg").convert("RGBA")
        comp_a.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_center_village.png").convert("RGBA"))
        comp_a.alpha_composite(water_01)
        comp_a.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_houses_water_right.png").convert("RGBA"))
        comp_a.alpha_composite(ramp_01)
        comp_a.alpha_composite(Image.open(MOD_SET_DIR / "wx_bldg_port.png").convert("RGBA"), (95, 315))
        comp_a.alpha_composite(Image.open(MOD_SET_DIR / "wx_bldg_marketplace.png").convert("RGBA"), (320, 285))
        comp_a.alpha_composite(Image.open(MOD_SET_DIR / "wx_bldg_crowd.png").convert("RGBA"), (415, 442))

        comp_b = Image.open(MOD_SET_DIR / "wx_bg_plains.jpg").convert("RGBA")
        comp_b.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_center_town.png").convert("RGBA"))
        comp_b.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_houses_02_left.png").convert("RGBA"))
        comp_b.alpha_composite(Image.open(MOD_SET_DIR / "wx_ui_houses_02_right.png").convert("RGBA"))
        comp_b.alpha_composite(ramp_01)
        comp_b.alpha_composite(Image.open(MOD_SET_DIR / "wx_bldg_tavern.png").convert("RGBA"), (75, 260))
        comp_b.alpha_composite(Image.open(MOD_SET_DIR / "wx_bldg_marketplace.png").convert("RGBA"), (325, 285))
        comp_b.alpha_composite(Image.open(MOD_SET_DIR / "wx_bldg_weaponsmith.png").convert("RGBA"), (640, 290))
        comp_b.alpha_composite(Image.open(MOD_SET_DIR / "wx_bldg_crowd.png").convert("RGBA"), (415, 442))

        both = Image.new("RGBA", (1024, 588 * 2 + 12), (20, 16, 12, 255))
        both.alpha_composite(comp_a, (0, 0))
        both.alpha_composite(comp_b, (0, 588 + 12))
        both.save(scratch_dir / "verify_repaired_towns.png")
    print("Saved verification previews into:", scratch_dir)


if __name__ == "__main__":
    repair_seven_weapon_icons()
    repair_town_landscapes()
    repair_town_centers_and_houses()
    repair_town_shop_buildings()
    scratch_p = Path(r"C:\Users\25647\.gemini\antigravity\brain\87708e7d-e9ac-4127-a817-d8e4e6bad370\scratch")
    if scratch_p.exists():
        render_verification_previews(scratch_p)
