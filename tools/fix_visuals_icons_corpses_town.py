#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fixes:
  1. Issue 8: Stash / Paperdoll / Shop / Loot item icon blank-space mismatch:
     - `wx_slot_empty.png` -> 100% transparent `RGBA(0,0,0,0)` matching vanilla `inventory_slot_empty.png`.
     - `wx_slot_helmet/body/mainhand/offhand/accessory/bag/ammo.png` -> 100% transparent background + etched walnut silhouette.
     - Re-renders HD-backed item icons without muddy `famed_glow` maroon smudge or wide GaussianBlur shadow haze,
       and cleans all 618 `mod_wuxia/gfx/ui/items/**/*.png` so 100% of blank space outside a crisp 1px dark contour is `RGBA(0,0,0,0)`.
  2. Issue 2: Town Screen Marketplace (`wx_bldg_marketplace`) vs Recruitment (`wx_bldg_crowd`) texture compactness + bluestone `wx_ui_ramp_stone`.
  3. Issue 5 & Issue 7: Invokes `compile_wuxia_brushes.compile_all()` to compile `wx_corpses_0.brush` (`*_dead`) and `wm_*` world player busts.
"""

from collections import deque
import json
import os
import shutil
import sys
import zipfile
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))

from compile_wuxia_brushes import compile_all

ART_DIR = ROOT / "art"
HD_DIR = ART_DIR / "hd"
MOD_ROOT = ROOT / "mod_wuxia"
ITEMS_DIR = MOD_ROOT / "gfx" / "ui" / "items"
ICONS_DIR = MOD_ROOT / "gfx" / "ui" / "wx_icons"
SETTLEMENTS_UI_DIR = MOD_ROOT / "gfx" / "ui" / "settlements"


def render_clean_item_icon(rgba_src: Image.Image, cw: int, ch: int, pad_x: int = 4, pad_y: int = 4) -> Image.Image:
    """
    Centers `rgba_src` inside `(cw, ch)` with a crisp 1px dark-ink outline (`rgba(14, 10, 8, 225)`)
    and 100% pure `RGBA(0, 0, 0, 0)` blank space (zero wide blurred shadow or maroon haze).
    """
    rgba = rgba_src.convert("RGBA")
    alpha = rgba.getchannel("A")
    bbox = alpha.point(lambda a: 255 if a > 28 else 0).getbbox()
    if bbox:
        rgba = rgba.crop(bbox)

    max_w = max(1, cw - 2 * pad_x)
    max_h = max(1, ch - 2 * pad_y)
    scale = min(max_w / float(rgba.width), max_h / float(rgba.height))
    nw = max(1, int(round(rgba.width * scale)))
    nh = max(1, int(round(rgba.height * scale)))
    resized = rgba.resize((nw, nh), Image.Resampling.LANCZOS)

    rgb_sharp = resized.convert("RGB").filter(ImageFilter.UnsharpMask(radius=0.6, percent=85, threshold=2))
    r_a = resized.getchannel("A")
    # Clean ultra-faint edge bleed from LANCZOS
    apx = r_a.load()
    for y in range(nh):
        for x in range(nw):
            if apx[x, y] < 22:
                apx[x, y] = 0
    item = Image.merge("RGBA", (*rgb_sharp.split(), r_a))

    out = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    ox = (cw - nw) // 2
    oy = (ch - nh) // 2

    # Crisp 1px dark ink outline matching vanilla Battle Brothers item style (zero wide haze!)
    hard_mask = r_a.point(lambda a: 255 if a >= 85 else 0)
    dilated = hard_mask.filter(ImageFilter.MaxFilter(3))
    outline_a = dilated.point(lambda a: 215 if a > 0 else 0)
    outline = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    outline.paste((14, 10, 8, 255), (ox, oy), outline_a)

    out = Image.alpha_composite(out, outline)
    out.alpha_composite(item, (ox, oy))
    return out


def strip_icon_background_haze(im_rgba: Image.Image, clean_white_holes: bool = False) -> Image.Image:
    """
    Removes baked `famed_glow` maroon clouds, blurred outer drop-shadow halos, and corner artifacts
    from an existing `70x70` / `70x140` item PNG while preserving the item's crisp silhouette and anti-aliased 1px edge.
    """
    im = im_rgba.convert("RGBA")
    w, h = im.size
    px = im.load()

    # 1. Clear any border/corner remnants connected to the outer 2px frame with low/dark alpha or maroon glow
    vis = bytearray(w * h)
    q = deque()

    def is_bg_haze(r, g, b, a):
        if a == 0:
            return True
        # Maroon famed_glow or blurred black drop shadow (`a < 135` and dark or red-dominant)
        if a < 115:
            return True
        if a < 165 and (r + g + b) < 85:
            return True
        if a < 150 and r > g + 35 and g < 50 and b < 45:
            return True
        return False

    for x in range(w):
        for sy in (0, 1, h - 2, h - 1):
            idx = sy * w + x
            if not vis[idx]:
                r, g, b, a = px[x, sy]
                # Force outer 1px corners transparent if dark sheet remnant
                if (x in (0, 1, w - 2, w - 1) and sy in (0, 1, h - 2, h - 1) and (r + g + b) < 95) or is_bg_haze(r, g, b, a):
                    vis[idx] = 1
                    q.append((x, sy))
    for y in range(h):
        for sx in (0, 1, w - 2, w - 1):
            idx = y * w + sx
            if not vis[idx]:
                r, g, b, a = px[sx, y]
                if is_bg_haze(r, g, b, a):
                    vis[idx] = 1
                    q.append((sx, y))

    while q:
        cx, cy = q.popleft()
        for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
            if 0 <= nx < w and 0 <= ny < h:
                nidx = ny * w + nx
                if not vis[nidx]:
                    r, g, b, a = px[nx, ny]
                    if is_bg_haze(r, g, b, a):
                        vis[nidx] = 1
                        q.append((nx, ny))

    # Build clean core mask (`vis == 0` and `a >= 95`)
    core = Image.new("L", (w, h), 0)
    cpx = core.load()
    for y in range(h):
        row = y * w
        for x in range(w):
            r, g, b, a = px[x, y]
            if not vis[row + x] and a >= 95:
                if clean_white_holes and r > 235 and g > 235 and b > 235 and max(r, g, b) - min(r, g, b) < 12:
                    continue
                cpx[x, y] = 255

    # Keep only significant connected foreground components (drops tiny 1-4px stray specks in corners)
    cvis = bytearray(w * h)
    comps = []
    for y in range(h):
        for x in range(w):
            idx = y * w + x
            if not cvis[idx] and cpx[x, y] > 0:
                cvis[idx] = 1
                cq = deque([(x, y)])
                pts = [(x, y)]
                while cq:
                    qx, qy = cq.popleft()
                    for nx, ny in ((qx - 1, qy), (qx + 1, qy), (qx, qy - 1), (qx, qy + 1)):
                        if 0 <= nx < w and 0 <= ny < h:
                            nidx = ny * w + nx
                            if not cvis[nidx] and cpx[nx, ny] > 0:
                                cvis[nidx] = 1
                                cq.append((nx, ny))
                                pts.append((nx, ny))
                comps.append(pts)

    if comps:
        max_c = max(len(c) for c in comps)
        for pts in comps:
            if len(pts) < min(10, max(3, max_c // 40)):
                for px_x, px_y in pts:
                    cpx[px_x, px_y] = 0

    # Allow 1px crisp anti-aliased dark outline around `core`, zero everything outside that 1px ring!
    ring = core.filter(ImageFilter.MaxFilter(3))
    rpx = ring.load()

    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    opx = out.load()
    for y in range(h):
        for x in range(w):
            if cpx[x, y] > 0:
                r, g, b, a = px[x, y]
                opx[x, y] = (r, g, b, max(210, a))
            elif rpx[x, y] > 0:
                r, g, b, a = px[x, y]
                # Crisp dark 1px contour
                opx[x, y] = (14, 10, 8, 210 if a < 140 else min(245, a))
    return out


def fix_slot_icons():
    ICONS_DIR.mkdir(parents=True, exist_ok=True)
    # 1. `wx_slot_empty.png` MUST be 100% transparent `RGBA(0,0,0,0)` like vanilla `inventory_slot_empty.png`!
    Image.new("RGBA", (70, 70), (0, 0, 0, 0)).save(ICONS_DIR / "wx_slot_empty.png")

    # 2. Equipment & Bag slot silhouettes: 100% transparent background + etched dark walnut silhouette `(34, 24, 16, 210)`
    #    with subtle inner highlight `(66, 48, 33, 140)` matching vanilla `inventory_slot_helmet.png`!
    slot_specs = [
        ("wx_slot_helmet.png",    (70, 70),  "helmet"),
        ("wx_slot_body.png",      (70, 140), "body"),
        ("wx_slot_mainhand.png",  (70, 140), "mainhand"),
        ("wx_slot_offhand.png",   (70, 140), "offhand"),
        ("wx_slot_accessory.png", (70, 70),  "accessory"),
        ("wx_slot_bag.png",       (70, 70),  "bag"),
        ("wx_slot_ammo.png",      (70, 70),  "ammo"),
    ]
    for fname, (w, h), kind in slot_specs:
        mask = Image.new("L", (w * 2, h * 2), 0)
        dr = ImageDraw.Draw(mask)
        W2, H2 = w * 2, h * 2
        if kind == "helmet":
            # Chinese conical/scholar crown silhouette
            dr.polygon([(20, 88), (70, 34), (120, 88)], fill=255)
            dr.pieslice([42, 46, 98, 108], 180, 360, fill=255)
            dr.rectangle([44, 88, 96, 104], fill=255)
        elif kind == "body":
            # Cross-collar Wuxia robe silhouette
            dr.polygon([(46, 56), (68, 48), (70, 74), (72, 48), (94, 56), (124, 96), (108, 122), (96, 108), (102, 224), (38, 224), (44, 108), (32, 122), (16, 96)], fill=255)
        elif kind == "mainhand":
            # Diagonal Jian sword silhouette
            dr.polygon([(108, 32), (118, 42), (56, 188), (44, 178)], fill=255)
            dr.polygon([(34, 168), (72, 196), (66, 206), (28, 178)], fill=255)
            dr.polygon([(46, 188), (56, 196), (34, 238), (24, 230)], fill=255)
        elif kind == "offhand":
            # Round rattan/iron shield silhouette
            dr.ellipse([22, 86, 118, 182], fill=255)
            dr.ellipse([48, 112, 92, 156], fill=140)
        elif kind == "accessory":
            # Jade pendant with tassel cord
            dr.ellipse([54, 22, 86, 46], outline=255, width=6)
            dr.ellipse([38, 42, 102, 106], fill=255)
            dr.ellipse([58, 62, 82, 86], fill=0)
            dr.rectangle([66, 106, 74, 124], fill=255)
        elif kind == "bag":
            # Jianghu cloth pouch
            dr.polygon([(48, 30), (92, 30), (82, 50), (58, 50)], fill=255)
            dr.ellipse([32, 46, 108, 118], fill=255)
        elif kind == "ammo":
            # Quiver with 3 fletched arrows
            dr.polygon([(34, 88), (64, 118), (104, 56), (82, 38)], fill=255)
            dr.line([(78, 52), (112, 22)], fill=255, width=6)
            dr.line([(88, 62), (120, 32)], fill=255, width=6)

        m_sm = mask.resize((w, h), Image.Resampling.LANCZOS)
        out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        # Subtle warm bevel highlight 1px down-right + crisp dark etched fill
        hi_a = m_sm.point(lambda a: int(a * 0.68))
        hi = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        hi.paste((92, 68, 45, 255), (1, 1), hi_a)
        etch_a = m_sm.point(lambda a: int(a * 0.88))
        etch = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        etch.paste((18, 13, 9, 255), (0, 0), etch_a)
        out = Image.alpha_composite(out, hi)
        out = Image.alpha_composite(out, etch)
        out.save(ICONS_DIR / fname)
    print("Rebuilt wx_slot_empty.png (100% transparent) and 7 etched transparent slot icons.")


def repair_bamboo_hat_bust_and_icon():
    """Repairs over-eaten dark bamboo weave holes on `wx_char_hat_bamboo` so bust, world figure, corpse & icon are solid."""
    hf_p = ART_DIR / "busts" / "hat_front" / "wx_char_hat_bamboo.png"
    hb_p = ART_DIR / "busts" / "hat_back" / "wx_char_hat_bamboo.png"
    if not hf_p.exists():
        return
    # Paint clean solid woven conical bamboo斗笠 (`208x284` registered to head `cx=104, crown_y=40, brim_y=84`)
    hf = Image.new("RGBA", (208, 284), (0, 0, 0, 0))
    dr = ImageDraw.Draw(hf)
    # Conical woven crown (`(104, 38)` apex -> `(40, 84)` .. `(168, 84)` brim)
    dr.polygon([(104, 38), (38, 84), (170, 84)], fill=(78, 84, 56, 255), outline=(18, 15, 11, 255))
    # Subtle warm bamboo highlight ribs & weave rings
    for rib_x in (56, 74, 90, 104, 118, 134, 152):
        dr.line([(104, 40), (rib_x, 83)], fill=(104, 108, 72, 210) if rib_x <= 104 else (58, 64, 42, 220), width=2)
    for ry, x_span in [(52, 20), (63, 36), (74, 52)]:
        dr.arc([104 - x_span, ry - 4, 104 + x_span, ry + 5], 8, 172, fill=(42, 46, 30, 220), width=2)
    # Curved dark rim binding & top bamboo knot
    dr.line([(38, 84), (104, 89), (170, 84)], fill=(22, 18, 13, 255), width=4)
    dr.line([(40, 82), (104, 87), (168, 82)], fill=(122, 112, 74, 235), width=2)
    dr.ellipse([99, 35, 109, 42], fill=(96, 82, 52, 255), outline=(18, 14, 10, 255))
    hf.save(hf_p)

    # Matching rear inner-brim shadow + dark cloth rain-veil behind neck (`hat_back`)
    hb = Image.new("RGBA", (208, 284), (0, 0, 0, 0))
    dbr = ImageDraw.Draw(hb)
    dbr.ellipse([40, 78, 168, 96], fill=(32, 34, 24, 245), outline=(16, 13, 10, 255))
    hb.save(hb_p)


def fix_all_item_icons():
    repair_bamboo_hat_bust_and_icon()
    # Map ALL `art/hd/*.png` files directly on disk AND from manifest.json!
    hd_by_id = {}
    if HD_DIR.exists():
        for hp in HD_DIR.glob("*.png"):
            hd_by_id[hp.stem] = hp
    manifest = json.loads((ART_DIR / "manifest.json").read_text(encoding="utf-8"))
    for a in manifest.get("assets", []):
        if a.get("hdPath"):
            hp = ROOT / a["hdPath"]
            if hp.exists():
                hd_by_id[a["id"]] = hp

    rebuilt_hd = 0
    cleaned_inplace = 0

    for p in sorted(ITEMS_DIR.rglob("*.png")):
        stem = p.stem
        is_70 = stem.endswith("_70x70")
        base_id = stem[:-6] if is_70 else stem
        im_cur = Image.open(p).convert("RGBA")
        cw, ch = im_cur.size

        if base_id == "wx_char_hat_bamboo" and (ART_DIR / "busts" / "hat_front" / "wx_char_hat_bamboo.png").exists():
            hat_f = Image.open(ART_DIR / "busts" / "hat_front" / "wx_char_hat_bamboo.png").convert("RGBA")
            hat_b = Image.open(ART_DIR / "busts" / "hat_back" / "wx_char_hat_bamboo.png").convert("RGBA")
            comb = hat_b.copy()
            comb.alpha_composite(hat_f)
            clean_im = render_clean_item_icon(comb, cw, ch, pad_x=4, pad_y=8)
            clean_im.save(p)
            rebuilt_hd += 1
        elif base_id in hd_by_id and (
            base_id.startswith("wx_relic_")
            or base_id.startswith("wx_armor_")
            or base_id.startswith("wx_helm_")
            or base_id.startswith("wx_acc_")
            or base_id in ("wx_core_mengji", "wx_core_xingxing")
        ):
            src_hd = Image.open(hd_by_id[base_id]).convert("RGBA")
            # Strip any semi-transparent red aura or white hole specks from HD source first!
            src_hd = strip_icon_background_haze(src_hd, clean_white_holes=(base_id in ("wx_core_mengji", "wx_core_xingxing")))
            clean_im = render_clean_item_icon(src_hd, cw, ch, pad_x=4, pad_y=4)
            clean_im.save(p)
            rebuilt_hd += 1
        else:
            clean_im = strip_icon_background_haze(im_cur, clean_white_holes=False)
            clean_im.save(p)
            cleaned_inplace += 1

    print(f"Cleaned all item icons: {rebuilt_hd} rebuilt from HD, {cleaned_inplace} stripped of background haze/corners.")


def fix_town_settlement_sprites():
    orig_backup = ART_DIR / "town_buildings_orig"
    orig_backup.mkdir(parents=True, exist_ok=True)

    # Compact heights so `.slot2` (Marketplace) and `.slot5` (Recruitment) NEVER collide!
    resize_targets = {
        "wx_bldg_marketplace":   (380, 138),
        "wx_bldg_crowd":         (182, 90),
        "wx_bldg_tavern":        (390, 228),
        "wx_bldg_training_hall": (380, 232),
        "wx_bldg_port":          (320, 240),
        "wx_bldg_arena":         (370, 215),
    }

    for p in sorted(SETTLEMENTS_UI_DIR.glob("wx_bldg_*.png")):
        bak = orig_backup / p.name
        if not bak.exists():
            shutil.copy2(p, bak)

        for prefix, (tw, th) in resize_targets.items():
            if p.stem == prefix or p.stem.startswith(prefix + "_"):
                src = Image.open(bak).convert("RGBA")
                bbox = src.getchannel("A").point(lambda a: 255 if a > 12 else 0).getbbox()
                if bbox:
                    src = src.crop(bbox)
                scale = min((tw - 8) / float(src.width), (th - 6) / float(src.height))
                nw = max(1, int(round(src.width * scale)))
                nh = max(1, int(round(src.height * scale)))
                rs = src.resize((nw, nh), Image.Resampling.LANCZOS)
                out = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
                # Bottom-align so building base sits firmly on the courtyard stone ground!
                out.alpha_composite(rs, ((tw - nw) // 2, th - nh - 2))
                out.save(p)
                break

    # Generate subtle Chinese bluestone courtyard terrace paving (`wx_ui_ramp_stone*.png`, 1024x588)
    for suf, base_col, line_col in [
        ("",            (126, 118, 106), (78, 72, 64)),
        ("_night",      (68, 72, 82),    (40, 44, 52)),
        ("_snow",       (196, 202, 208), (128, 136, 146)),
        ("_snow_night", (102, 112, 128), (62, 70, 84)),
    ]:
        ramp = Image.new("RGBA", (1024, 588), (0, 0, 0, 0))
        dr = ImageDraw.Draw(ramp)
        # Wide stepped bluestone plaza terrace in lower foreground (`y=415..588`) with soft edge fade
        for step_i, (y0, y1, w_half) in enumerate([(422, 466, 320), (466, 522, 410), (522, 588, 495)]):
            cx = 512
            al = 115 + step_i * 22
            dr.polygon(
                [(cx - w_half + 28, y0), (cx + w_half - 28, y0), (cx + w_half, y1), (cx - w_half, y1)],
                fill=(*base_col, al),
                outline=(*line_col, al + 35),
            )
            # Horizontal stone riser line
            dr.line([(cx - w_half + 20, y0 + 2), (cx + w_half - 20, y0 + 2)], fill=(*line_col, al + 45), width=2)
        ramp = ramp.filter(ImageFilter.GaussianBlur(radius=0.8))
        # Soft fade on left/right/top/bottom edges so it blends organically into any terrain backdrop
        px = ramp.load()
        for y in range(415, 588):
            fy = min(1.0, (y - 415) / 28.0) * min(1.0, (588 - y) / 18.0 + 0.35)
            for x in range(1024):
                r, g, b, a = px[x, y]
                if a > 0:
                    fx = max(0.0, min(1.0, (485 - abs(x - 512)) / 95.0))
                    px[x, y] = (r, g, b, int(a * fx * min(1.0, fy)))
        ramp.save(SETTLEMENTS_UI_DIR / f"wx_ui_ramp_stone{suf}.png")

    print("Compacted Town Screen building sprites and generated wx_ui_ramp_stone*.png.")


def build_verification_sheets():
    scratch = Path(r"C:\Users\25647\.gemini\antigravity\brain\d8aea5d2-d766-4e1a-ac0a-0b21b615afd9\scratch")
    if not scratch.exists():
        return
    data_dat = Path(r"F:\SteamLibrary\steamapps\common\Battle Brothers\data\data_001.dat")
    bg_inv = Image.open(MOD_ROOT / "gfx" / "ui" / "wx_skin" / "wx_background_inventory.png").convert("RGBA")
    # Crop a 6x4 Stash patch from wx_background_inventory.png around (620, 200)
    patch = bg_inv.crop((600, 190, 600 + 6 * 78 + 16, 190 + 4 * 78 + 16)).copy()

    slot_frame = None
    vanilla_items = []
    if data_dat.exists():
        with zipfile.ZipFile(data_dat, "r") as zf:
            slot_frame = Image.open(zf.open("gfx/ui/skin/inventory_slot.png")).convert("RGBA")
            for vp in [
                "gfx/ui/items/armor/icon_body_armor_01.png",
                "gfx/ui/items/helmets/inventory_helmet_01.png",
                "gfx/ui/items/weapons/named/icon_named_sword_01_70x70.png",
                "gfx/ui/items/tools/throwing_net_70x70.png",
            ]:
                if vp in zf.namelist():
                    vanilla_items.append(Image.open(zf.open(vp)).convert("RGBA"))

    cand_paths = [
        ICONS_DIR / "wx_slot_empty.png",
        ICONS_DIR / "wx_slot_bag.png",
        ICONS_DIR / "wx_slot_helmet.png",
        ITEMS_DIR / "weapons" / "named" / "wx_relic_chixiao_70x70.png",
        ITEMS_DIR / "weapons" / "named" / "wx_relic_bawangqiang_70x70.png",
        ITEMS_DIR / "accessory" / "wx_acc_jiuwei.png",
        ITEMS_DIR / "helmets" / "wx_char_hat_bamboo.png",
        ITEMS_DIR / "helmets" / "wx_helm_taotie.png",
        ITEMS_DIR / "armor" / "wx_armor_qiongqi_70x70.png",
        ITEMS_DIR / "armor" / "wx_body_civ_01_70x70.png",
        ITEMS_DIR / "weapons" / "ranged" / "wx_wpn_bow_01_70x70.png",
        ITEMS_DIR / "weapons" / "melee" / "wx_wpn_flail_02_70x70.png",
        ITEMS_DIR / "misc" / "wx_core_mengji.png",
        ITEMS_DIR / "misc" / "wx_page_common.png",
        ITEMS_DIR / "ammo" / "wx_ammo_arrows.png",
    ]
    test_icons = [*vanilla_items]
    for cp in cand_paths:
        if cp.exists():
            test_icons.append(Image.open(cp).convert("RGBA"))

    for idx, ic in enumerate(test_icons[:24]):
        r, c = divmod(idx, 6)
        sx, sy = 8 + c * 78, 8 + r * 78
        if slot_frame is not None:
            patch.alpha_composite(slot_frame, (sx, sy))
        if ic.size == (70, 70):
            patch.alpha_composite(ic, (sx + 2, sy + 2))
    patch.save(scratch / "stash_fixed_verify.png")

    # Also preview composite fallen corpse + world marching player figure!
    from compile_wuxia_brushes import make_fallen_corpse_layer, make_world_bust_layer
    demo = Image.new("RGBA", (420, 160), (54, 62, 44, 255))
    b208 = Image.open(ART_DIR / "busts" / "body" / "wx_body_civ_02.png").convert("RGBA")
    h208 = Image.open(ART_DIR / "busts" / "head" / "wx_head_05.png").convert("RGBA")
    hr208 = Image.open(ART_DIR / "busts" / "hair_tucked" / "wx_hair_04.png").convert("RGBA")
    hb208 = Image.open(ART_DIR / "busts" / "hat_back" / "wx_char_hat_bamboo.png").convert("RGBA")
    hf208 = Image.open(ART_DIR / "busts" / "hat_front" / "wx_char_hat_bamboo.png").convert("RGBA")

    corpse_comp = Image.new("RGBA", (131, 125), (0, 0, 0, 0))
    for lyr, is_b in [(b208, True), (hb208, False), (h208, False), (hr208, False), (hf208, False)]:
        corpse_comp.alpha_composite(make_fallen_corpse_layer(lyr.resize((104, 142), Image.Resampling.LANCZOS), is_body_base=is_b, seed_val=5))
    demo.alpha_composite(corpse_comp, (20, 18))

    wm_comp = Image.new("RGBA", (68, 106), (0, 0, 0, 0))
    for lyr in [b208, hb208, h208, hr208, hf208]:
        wm_comp.alpha_composite(make_world_bust_layer(lyr))
    demo.alpha_composite(wm_comp, (240, 24))
    demo.save(scratch / "corpse_and_wm_verify.png")


if __name__ == "__main__":
    fix_slot_icons()
    fix_all_item_icons()
    fix_town_settlement_sprites()
    compile_all()
    build_verification_sheets()
