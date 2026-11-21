#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Slices, frames, alpha-keys, and deploys Wave 54..58 (Milestone 5: 江湖奇遇插画与过场界面):
  1. 32 Event Illustrations (`wx_ev_01`..`wx_ev_32`, 210×210 RGBA PNG with authentic Overhype 6px frame)
  2. 4 Main Menu Scrolls (`wx_menu_bg_01`..`04.jpg`, 1920×1080 RGB JPEG) + 2 Main Menu Skin PNGs
     (`wx_main_menu_banner.png` 245×595 RGBA, `wx_main_menu_logo.png` 400×350 RGBA)
  3. 8 Loading Scrolls (`wx_loading_01`..`08.jpg`, 1920×1080 RGB JPEG with subtle bottom tip vignette)
  4. 5 Epilogue Scrolls (`wx_game_lost.jpg` + `wx_retirement_01`..`04.jpg`, 1920×1080 RGB JPEG with smooth right-side text fade)
  5. 26 Campfire & Retinue Assets (`wx_camp_bg_day/night.jpg`, `wx_campfire_tents_01.png`, `wx_fire_01.png`,
     `wx_cart_01..04.png` + `_b.png`, `wx_free_slot.png` + `_b.png`, `wx_locked_slot.png` + `_b.png`,
     and all 18 seated Wuxia retinue followers `wx_<stem>.png` + `_b.png` at exact vanilla dimensions).
"""

import math
import os
import shutil
import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont
from build_wuxia_bust_system import flood_white_bg

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART_DIR = os.path.join(ROOT, "art")
HD_DIR = os.path.join(ART_DIR, "hd")
GAME_UI_DIR = os.path.join(ART_DIR, "game", "ui")
SHEETS_DIR = os.path.join(ART_DIR, "sheets")
MOD_UI_DIR = os.path.join(ROOT, "mod_wuxia", "gfx", "ui")

BRAIN = r"C:\Users\25647\.gemini\antigravity\brain\6ef7d9fb-ca0b-4c89-84c0-98f9c87c021b"
VANILLA_REF = os.path.join(BRAIN, "scratch", "vanilla_ref")
QA_DIR = os.path.join(BRAIN, "scratch")

RAW_SHEETS_ARCHIVE = {
    54: os.path.join(BRAIN, "sheet_54_wuxia_jianghu_events_a_v3_1795186802270.jpg"),
    55: os.path.join(BRAIN, "sheet_55_wuxia_shanhai_events_b_v2_1795186766728.jpg"),
    56: os.path.join(BRAIN, "wx_sheet_56_retinue_1795186776941.jpg"),
    57: os.path.join(BRAIN, "wx_sheet_57_wagons_seals_1795186801457.jpg"),
    58: os.path.join(BRAIN, "wuxia_ui_skin_sheet_1795186766911.jpg"),
}

MENU_RAW = [
    ("wx_menu_bg_01", os.path.join(BRAIN, "wuxia_menu_bg_1_v2_1795186796448.jpg")),
    ("wx_menu_bg_02", os.path.join(BRAIN, "wuxia_menu_bg_2_v2_1795186813300.jpg")),
    ("wx_menu_bg_03", os.path.join(BRAIN, "wuxia_menu_bg_3_v2_1795186824982.jpg")),
    ("wx_menu_bg_04", os.path.join(BRAIN, "wuxia_menu_bg_4_v2_1795186839591.jpg")),
]

LOADING_RAW = [
    ("wx_loading_01", os.path.join(BRAIN, "loading_scroll_01_rainy_night_ambush_1795186687600.jpg")),
    ("wx_loading_02", os.path.join(BRAIN, "loading_scroll_02_zhuyan_ape_battle_1795186711456.jpg")),
    ("wx_loading_03", os.path.join(BRAIN, "loading_scroll_03_gobi_beacon_clash_1795186730254.jpg")),
    ("wx_loading_04", os.path.join(BRAIN, "loading_scroll_04_ancient_tomb_automatons_1795186748476.jpg")),
    ("wx_loading_05", os.path.join(BRAIN, "loading_scroll_05_cliff_ambush_1795186697449.jpg")),
    ("wx_loading_06", os.path.join(BRAIN, "loading_scroll_06_warlord_phalanx_1795187019582.jpg")),
    ("wx_loading_07", os.path.join(BRAIN, "loading_scroll_07_xingtian_clash_1795187043133.jpg")),
    ("wx_loading_08", os.path.join(BRAIN, "loading_scroll_08_ghost_market_1795186706504.jpg")),
]

EPILOGUE_RAW = [
    ("wx_game_lost",     os.path.join(BRAIN, "wx_game_lost_1795186695649.jpg"),     False),
    ("wx_retirement_01", os.path.join(BRAIN, "wx_retirement_01_1795186801226.jpg"), True),
    ("wx_retirement_02", os.path.join(BRAIN, "wx_retirement_02_1795186741495.jpg"), True),
    ("wx_retirement_03", os.path.join(BRAIN, "wx_retirement_03_1795186754041.jpg"), True),
    ("wx_retirement_04", os.path.join(BRAIN, "wx_retirement_04_1795186877435.jpg"), True),
]

CAMP_BG_RAW = [
    ("wx_camp_bg_day",   os.path.join(BRAIN, "wx_camp_bg_day_1795186699178.jpg")),
    ("wx_camp_bg_night", os.path.join(BRAIN, "wx_camp_bg_night_1795186728521.jpg")),
]
CAMP_TENTS_RAW = os.path.join(BRAIN, "wx_campfire_tents_raw_1795186754555.jpg")

# Exact vanilla dimensions from data_001.dat
FOLLOWER_SPECS_SHEET56 = [
    ("alchemist_01",     (296, 303)),
    ("blacksmith_01",    (325, 306)),
    ("cook_01",          (259, 315)),
    ("drill_01",         (271, 333)),
    ("surgeon_01",       (285, 320)),
    ("scout_01",         (264, 272)),
    ("lookout_01",       (287, 316)),
    ("quartermaster_01", (276, 349)),
    ("paymaster_01",     (282, 309)),
    ("recruiter_01",     (313, 318)),
    ("trader_01",        (345, 339)),
    ("cartographer_01",  (275, 286)),
    ("bounty_hunter_01", (299, 325)),
    ("minstrel_01",      (295, 310)),
    ("negotiator_01",    (255, 346)),
    ("scavenger_01",     (300, 257)),
]

SHEET57_SPECS = [
    # (row, col, kind, stem, target_size)
    (0, 0, "follower", "agent_01",    (292, 350)),
    (0, 1, "follower", "brigand_01",  (252, 293)),
    (0, 2, "cart",     "cart_01",     (386, 434)),
    (1, 0, "cart",     "cart_02",     (442, 462)),
    (1, 1, "cart",     "cart_03",     (364, 488)),
    (1, 2, "cart",     "cart_04",     (415, 588)),
    (2, 0, "fire",     "fire_01",     (1024, 588)),
    (2, 1, "slot",     "free_slot",   (200, 190)),
    (2, 2, "slot",     "locked_slot", (200, 190)),
]


def ensure_dirs():
    for sub in ("events", "screens", "skin", "campfire"):
        os.makedirs(os.path.join(GAME_UI_DIR, sub), exist_ok=True)
        os.makedirs(os.path.join(MOD_UI_DIR, sub), exist_ok=True)
    os.makedirs(HD_DIR, exist_ok=True)
    os.makedirs(SHEETS_DIR, exist_ok=True)
    os.makedirs(QA_DIR, exist_ok=True)


def save_dual(im: Image.Image, sub_rel: str, is_jpeg: bool = False):
    p_art = os.path.join(GAME_UI_DIR, sub_rel)
    p_mod = os.path.join(MOD_UI_DIR, sub_rel)
    os.makedirs(os.path.dirname(p_art), exist_ok=True)
    os.makedirs(os.path.dirname(p_mod), exist_ok=True)
    if is_jpeg:
        rgb = im.convert("RGB")
        rgb.save(p_art, "JPEG", quality=92, subsampling=0)
        shutil.copy2(p_art, p_mod)
    else:
        im.save(p_art, "PNG", optimize=True)
        shutil.copy2(p_art, p_mod)


def crop_aspect_resize(im: Image.Image, target_w: int, target_h: int) -> Image.Image:
    w, h = im.size
    target_ratio = target_w / float(target_h)
    cur_ratio = w / float(h)
    if abs(cur_ratio - target_ratio) > 0.005:
        if cur_ratio > target_ratio:
            nw = int(round(h * target_ratio))
            x0 = (w - nw) // 2
            im = im.crop((x0, 0, x0 + nw, h))
        else:
            nh = int(round(w / target_ratio))
            y0 = (h - nh) // 2
            im = im.crop((0, y0, w, y0 + nh))
    out = im.resize((target_w, target_h), Image.Resampling.LANCZOS)
    return out.filter(ImageFilter.UnsharpMask(radius=0.9, percent=110, threshold=2))


def clean_white_cutout(cell_rgb: Image.Image, thr: int = 240) -> Image.Image:
    rgba = flood_white_bg(cell_rgb)
    arr = np.array(rgba, dtype=np.float32)
    alpha = arr[:, :, 3]
    # Remove faint near-white fringe pixels along outer 2px boundary
    lum = 0.299 * arr[:, :, 0] + 0.587 * arr[:, :, 1] + 0.114 * arr[:, :, 2]
    sat = np.max(arr[:, :, :3], axis=2) - np.min(arr[:, :, :3], axis=2)
    fringe = (alpha > 0) & (alpha < 235) & (lum > 218) & (sat < 24)
    arr[fringe, 3] *= 0.25
    # Darken semi-transparent white edge halo slightly so it never glows on dark camp backgrounds
    semi = (arr[:, :, 3] > 5) & (arr[:, :, 3] < 210) & (lum > 195)
    arr[semi, :3] *= 0.68
    out = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")
    bbox = Image.fromarray((np.array(out)[:, :, 3] > 12).astype(np.uint8) * 255).getbbox()
    if bbox:
        out = out.crop(bbox)
    return out


def make_hover_bright(rgba: Image.Image) -> Image.Image:
    """Generates Battle Brothers `_b.png` hover highlight state: warm brightness lift + golden rim glow."""
    w, h = rgba.size
    arr = np.array(rgba, dtype=np.float32)
    alpha = arr[:, :, 3]

    # Warm golden rim glow around alpha silhouette
    a_img = Image.fromarray(np.clip(alpha, 0, 255).astype(np.uint8), "L")
    dilated = a_img.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.GaussianBlur(2.2))
    glow_a = np.array(dilated, dtype=np.float32) * 0.58

    glow = np.zeros((h, w, 4), dtype=np.float32)
    glow[:, :, 0] = 255.0
    glow[:, :, 1] = 212.0
    glow[:, :, 2] = 122.0
    glow[:, :, 3] = glow_a

    # Brighten and slightly warm the foreground sprite
    fg = arr.copy()
    fg[:, :, 0] = np.clip(fg[:, :, 0] * 1.18 + 14.0, 0, 255)
    fg[:, :, 1] = np.clip(fg[:, :, 1] * 1.16 + 10.0, 0, 255)
    fg[:, :, 2] = np.clip(fg[:, :, 2] * 1.10 + 4.0, 0, 255)

    base_im = Image.fromarray(np.clip(glow, 0, 255).astype(np.uint8), "RGBA")
    fg_im = Image.fromarray(np.clip(fg, 0, 255).astype(np.uint8), "RGBA")
    return Image.alpha_composite(base_im, fg_im)


def place_bottom_centered(cutout: Image.Image, canvas_size: tuple, bottom_pad: int = 4, side_pad: int = 8) -> Image.Image:
    cw, ch = canvas_size
    avail_w = max(16, cw - side_pad * 2)
    avail_h = max(16, ch - bottom_pad - 6)
    sw, sh = cutout.size
    scale = min(avail_w / float(sw), avail_h / float(sh))
    nw = max(1, int(round(sw * scale)))
    nh = max(1, int(round(sh * scale)))
    resized = cutout.resize((nw, nh), Image.Resampling.LANCZOS)
    resized = resized.filter(ImageFilter.UnsharpMask(radius=0.7, percent=95, threshold=2))

    canvas = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    # Subtle ground contact shadow so seated followers & wagons sit naturally on camp earth
    shadow = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sx0 = (cw - int(nw * 0.82)) // 2
    sx1 = sx0 + int(nw * 0.82)
    sy1 = ch - max(1, bottom_pad // 2)
    sy0 = max(0, sy1 - max(10, int(nh * 0.11)))
    sdraw.ellipse((sx0, sy0, sx1, sy1), fill=(10, 8, 6, 115))
    shadow = shadow.filter(ImageFilter.GaussianBlur(4.5))
    canvas = Image.alpha_composite(canvas, shadow)

    ox = (cw - nw) // 2
    oy = ch - bottom_pad - nh
    canvas.alpha_composite(resized, (ox, oy))
    return canvas


def process_events():
    print("[1/5] Slicing & framing 32 Wuxia Event Illustrations (wx_ev_01..32)...")
    ev_ref = Image.open(os.path.join(VANILLA_REF, "event_01.png")).convert("RGBA")
    frame_arr = np.array(ev_ref, dtype=np.uint8)
    # Build reusable 210x210 outer frame + subtle 4px inner vignette mask (inner area is [6:205, 6:205] = 199x199)
    inner_vig = np.ones((199, 199, 1), dtype=np.float32)
    for y in range(199):
        dy = min(y, 198 - y)
        wy = 0.72 + 0.28 * min(1.0, dy / 5.0)
        for x in range(199):
            dx = min(x, 198 - x)
            wx = 0.72 + 0.28 * min(1.0, dx / 5.0)
            inner_vig[y, x, 0] = min(wx, wy)

    idx = 1
    for sheet_no in (54, 55):
        sheet_im = Image.open(RAW_SHEETS_ARCHIVE[sheet_no]).convert("RGB")
        sw, sh = sheet_im.size
        cw, ch = sw / 4.0, sh / 4.0
        for r in range(4):
            for c in range(4):
                x0 = int(round((c + 0.035) * cw))
                y0 = int(round((r + 0.035) * ch))
                x1 = int(round((c + 0.965) * cw))
                y1 = int(round((r + 0.965) * ch))
                cell = sheet_im.crop((x0, y0, x1, y1))

                ev_id = f"wx_ev_{idx:02d}"
                # Save 512x512 HD
                hd_im = cell.resize((512, 512), Image.Resampling.LANCZOS)
                hd_im = hd_im.filter(ImageFilter.UnsharpMask(radius=0.8, percent=105, threshold=2))
                hd_im.save(os.path.join(HD_DIR, f"{ev_id}.png"), "PNG", optimize=True)

                # Composite 199x199 inner art into exact 210x210 Overhype event frame
                art_199 = cell.resize((199, 199), Image.Resampling.LANCZOS)
                art_199 = art_199.filter(ImageFilter.UnsharpMask(radius=0.75, percent=115, threshold=2))
                art_np = np.clip(np.array(art_199, dtype=np.float32) * inner_vig, 0, 255).astype(np.uint8)

                out_np = frame_arr.copy()
                out_np[6:205, 6:205, :3] = art_np
                out_np[6:205, 6:205, 3] = 255
                out_im = Image.fromarray(out_np, "RGBA")
                save_dual(out_im, f"events/{ev_id}.png", is_jpeg=False)
                idx += 1


def process_screens():
    print("[2/5] Processing 17 Full-Screen 16:9 Scrolls (Menu, Loading, Game Lost & Retirement)...")
    # Menu scrolls
    for sid, raw_p in MENU_RAW:
        src = Image.open(raw_p).convert("RGB")
        full = crop_aspect_resize(src, 1920, 1080)
        save_dual(full, f"screens/{sid}.jpg", is_jpeg=True)
        full.resize((1280, 720), Image.Resampling.LANCZOS).save(
            os.path.join(HD_DIR, f"{sid}.jpg"), "JPEG", quality=90
        )

    # Loading scrolls (with subtle bottom tip-bar readability vignette)
    y_grad = np.ones((1080, 1, 1), dtype=np.float32)
    for y in range(880, 1080):
        t = (y - 880) / 200.0
        y_grad[y, 0, 0] = 1.0 - 0.52 * (t * t)

    for sid, raw_p in LOADING_RAW:
        src = Image.open(raw_p).convert("RGB")
        full = crop_aspect_resize(src, 1920, 1080)
        arr = np.clip(np.array(full, dtype=np.float32) * y_grad, 0, 255).astype(np.uint8)
        out = Image.fromarray(arr, "RGB")
        save_dual(out, f"screens/{sid}.jpg", is_jpeg=True)
        out.resize((1280, 720), Image.Resampling.LANCZOS).save(
            os.path.join(HD_DIR, f"{sid}.jpg"), "JPEG", quality=90
        )

    # Epilogue scrolls (Retirement 01..04 enforce right-side cosine fade to pure #000000 black across x=1120..1540)
    x_fade = np.ones((1, 1920, 1), dtype=np.float32)
    for x in range(1120, 1920):
        if x >= 1540:
            x_fade[0, x, 0] = 0.0
        else:
            t = (x - 1120) / float(1540 - 1120)
            x_fade[0, x, 0] = 0.5 * (1.0 + math.cos(math.pi * t))

    for sid, raw_p, fade_right in EPILOGUE_RAW:
        src = Image.open(raw_p).convert("RGB")
        full = crop_aspect_resize(src, 1920, 1080)
        if fade_right:
            arr = np.clip(np.array(full, dtype=np.float32) * x_fade, 0, 255).astype(np.uint8)
            full = Image.fromarray(arr, "RGB")
        save_dual(full, f"screens/{sid}.jpg", is_jpeg=True)
        full.resize((1280, 720), Image.Resampling.LANCZOS).save(
            os.path.join(HD_DIR, f"{sid}.jpg"), "JPEG", quality=90
        )


def render_embossed_text(canvas: Image.Image, text: str, font: ImageFont.FreeTypeFont, center_xy: tuple,
                         top_rgb=(255, 238, 182), bot_rgb=(188, 138, 58), stroke_px: int = 3):
    w, h = canvas.size
    mask_im = Image.new("L", (w, h), 0)
    mdraw = ImageDraw.Draw(mask_im)
    bbox = mdraw.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    tx = int(round(center_xy[0] - tw / 2.0 - bbox[0]))
    ty = int(round(center_xy[1] - th / 2.0 - bbox[1]))
    mdraw.text((tx, ty), text, fill=255, font=font)

    # Outer dark shadow + bronze bevel stroke
    stroke_im = Image.new("L", (w, h), 0)
    sdraw = ImageDraw.Draw(stroke_im)
    sdraw.text((tx, ty), text, fill=255, font=font, stroke_width=stroke_px, stroke_fill=255)

    shadow_a = stroke_im.filter(ImageFilter.GaussianBlur(3.2))
    shadow_layer = Image.new("RGBA", (w, h), (6, 4, 2, 0))
    shadow_layer.putalpha(ImageEnhance.Brightness(shadow_a).enhance(1.15))
    canvas.alpha_composite(shadow_layer, (0, 3))

    bevel_layer = Image.new("RGBA", (w, h), (34, 22, 10, 0))
    bevel_layer.putalpha(stroke_im)
    canvas.alpha_composite(bevel_layer)

    # Vertical metallic gold gradient fill
    grad = np.zeros((h, w, 4), dtype=np.uint8)
    y0_vis = max(0, int(center_xy[1] - th / 2.0))
    y1_vis = min(h - 1, int(center_xy[1] + th / 2.0) + 1)
    span = max(1, y1_vis - y0_vis)
    for y in range(h):
        t = min(1.0, max(0.0, (y - y0_vis) / float(span)))
        # Subtle horizon gleam in middle like vanilla BATTLE BROTHERS logo
        gleam = 26.0 * math.exp(-((t - 0.46) / 0.14) ** 2)
        r = int(np.clip(top_rgb[0] * (1 - t) + bot_rgb[0] * t + gleam, 0, 255))
        g = int(np.clip(top_rgb[1] * (1 - t) + bot_rgb[1] * t + gleam * 0.85, 0, 255))
        b = int(np.clip(top_rgb[2] * (1 - t) + bot_rgb[2] * t + gleam * 0.5, 0, 255))
        grad[y, :, 0] = r
        grad[y, :, 1] = g
        grad[y, :, 2] = b
    grad[:, :, 3] = np.array(mask_im, dtype=np.uint8)
    canvas.alpha_composite(Image.fromarray(grad, "RGBA"))


def process_menu_skin():
    print("[3/5] Processing Main Menu Hanging Banner (245×595) & Embossed Title Crest (400×350)...")
    skin_im = Image.open(RAW_SHEETS_ARCHIVE[58]).convert("RGB")
    sw, sh = skin_im.size

    # Left half: Banner
    left_crop = skin_im.crop((0, 0, int(sw * 0.49), sh))
    banner_cut = clean_white_cutout(left_crop, thr=240)
    banner_cut.resize((512, int(round(512 * banner_cut.size[1] / banner_cut.size[0]))), Image.Resampling.LANCZOS).save(
        os.path.join(HD_DIR, "wx_main_menu_banner.png"), "PNG", optimize=True
    )
    bw, bh = 245, 595
    scale_b = min((bw - 2) / float(banner_cut.size[0]), (bh - 4) / float(banner_cut.size[1]))
    nbw = int(round(banner_cut.size[0] * scale_b))
    nbh = int(round(banner_cut.size[1] * scale_b))
    banner_resized = banner_cut.resize((nbw, nbh), Image.Resampling.LANCZOS)
    banner_canvas = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
    # Soft drop shadow behind banner
    b_shad = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
    b_shad_alpha = banner_resized.getchannel("A").filter(ImageFilter.GaussianBlur(4.0))
    shad_layer = Image.new("RGBA", (nbw, nbh), (0, 0, 0, 0))
    shad_layer.putalpha(ImageEnhance.Brightness(b_shad_alpha).enhance(0.55))
    b_shad.alpha_composite(shad_layer, ((bw - nbw) // 2, 4))
    banner_canvas = Image.alpha_composite(banner_canvas, b_shad)
    banner_canvas.alpha_composite(banner_resized, ((bw - nbw) // 2, 2))
    save_dual(banner_canvas, "skin/wx_main_menu_banner.png", is_jpeg=False)

    # Right half: Bagua Jian-Dao Shield Crest -> 800x700 HD composite -> 400x350 Game Logo
    right_crop = skin_im.crop((int(sw * 0.49), 0, sw, sh))
    crest_cut = clean_white_cutout(right_crop, thr=240)

    logo_hi = Image.new("RGBA", (800, 700), (0, 0, 0, 0))
    sc_c = min(710 / float(crest_cut.size[0]), 610 / float(crest_cut.size[1]))
    cw_hi = int(round(crest_cut.size[0] * sc_c))
    ch_hi = int(round(crest_cut.size[1] * sc_c))
    crest_hi = crest_cut.resize((cw_hi, ch_hi), Image.Resampling.LANCZOS)
    # Darken center of shield slightly behind title lettering for supreme contrast
    vign = Image.new("RGBA", (800, 700), (0, 0, 0, 0))
    vdraw = ImageDraw.Draw(vign)
    vdraw.ellipse((150, 225, 650, 495), fill=(8, 6, 4, 128))
    vign = vign.filter(ImageFilter.GaussianBlur(24))

    logo_hi.alpha_composite(crest_hi, ((800 - cw_hi) // 2, (700 - ch_hi) // 2 - 4))
    # Clip vignette to crest alpha + slight spread so transparent background stays clean
    logo_hi = Image.alpha_composite(logo_hi, vign)

    zh_font_path = r"C:\Windows\Fonts\STXINGKA.TTF"
    if not os.path.exists(zh_font_path):
        zh_font_path = r"C:\Windows\Fonts\SIMLI.TTF"
    sub_font_path = r"C:\Windows\Fonts\STZHONGS.TTF"
    if not os.path.exists(sub_font_path):
        sub_font_path = r"C:\Windows\Fonts\georgia.ttf"

    font_zh = ImageFont.truetype(zh_font_path, 134)
    font_en = ImageFont.truetype(sub_font_path, 38)

    render_embossed_text(logo_hi, "武侠江湖", font_zh, (400, 326),
                         top_rgb=(255, 240, 188), bot_rgb=(190, 136, 52), stroke_px=6)

    # Metallic horizontal divider spear-rule like vanilla logo
    rule = Image.new("RGBA", (800, 700), (0, 0, 0, 0))
    rdraw = ImageDraw.Draw(rule)
    rdraw.line((76, 405, 724, 405), fill=(22, 14, 8, 220), width=7)
    rdraw.line((72, 403, 728, 403), fill=(238, 202, 128, 255), width=3)
    logo_hi = Image.alpha_composite(logo_hi, rule)

    render_embossed_text(logo_hi, "BATTLE BROTHERS", font_en, (400, 444),
                         top_rgb=(244, 222, 168), bot_rgb=(168, 122, 52), stroke_px=4)

    logo_hi.save(os.path.join(HD_DIR, "wx_main_menu_logo.png"), "PNG", optimize=True)
    logo_game = logo_hi.resize((400, 350), Image.Resampling.LANCZOS)
    logo_game = logo_game.filter(ImageFilter.UnsharpMask(radius=0.65, percent=95, threshold=2))
    save_dual(logo_game, "skin/wx_main_menu_logo.png", is_jpeg=False)


def build_seamless_tents_layer() -> Image.Image:
    raw = Image.open(CAMP_TENTS_RAW).convert("RGB")
    cut = clean_white_cutout(raw, thr=242)

    cw, ch = 1024, 588
    canvas = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))

    # Build a natural edge-to-edge earthy mossy ground strip across y=356..588 so sides/bottom never float
    ground = np.zeros((ch, cw, 4), dtype=np.float32)
    rng = np.random.default_rng(20261120)
    noise = rng.normal(0.0, 1.0, (ch // 4 + 2, cw // 4 + 2))
    noise_im = Image.fromarray(np.clip((noise * 28 + 128), 0, 255).astype(np.uint8), "L").resize(
        (cw, ch), Image.Resampling.BILINEAR
    )
    n_arr = (np.array(noise_im, dtype=np.float32) - 128.0) / 128.0

    for y in range(348, ch):
        t = (y - 348) / float(ch - 1 - 348)
        # Earthy olive-brown matching Wuxia camp palette, darkening smoothly toward bottom border
        vign_b = 1.0 - 0.35 * (t ** 1.8)
        r_base = (68.0 - 16.0 * t) * vign_b
        g_base = (65.0 - 18.0 * t) * vign_b
        b_base = (42.0 - 14.0 * t) * vign_b
        alpha_y = 255.0 if y >= 384 else 255.0 * (((y - 348) / 36.0) ** 1.6)
        ground[y, :, 0] = np.clip(r_base + n_arr[y, :] * 14.0, 14, 110)
        ground[y, :, 1] = np.clip(g_base + n_arr[y, :] * 15.0, 14, 112)
        ground[y, :, 2] = np.clip(b_base + n_arr[y, :] * 10.0, 10, 82)
        ground[y, :, 3] = alpha_y

    # Subtle side darkening vignette
    x_idx = np.linspace(-1.0, 1.0, cw)[None, :]
    side_v = 1.0 - 0.28 * (x_idx ** 4)
    ground[:, :, :3] *= side_v[:, :, None]

    canvas = Image.alpha_composite(canvas, Image.fromarray(np.clip(ground, 0, 255).astype(np.uint8), "RGBA"))

    # Scale tents cutout to span width=1008 anchored near bottom y=584
    scale = min(1008.0 / cut.size[0], 568.0 / cut.size[1])
    tw = int(round(cut.size[0] * scale))
    th = int(round(cut.size[1] * scale))
    tents_rs = cut.resize((tw, th), Image.Resampling.LANCZOS)
    tents_rs = tents_rs.filter(ImageFilter.UnsharpMask(radius=0.75, percent=100, threshold=2))

    # Remove any enclosed white paper pockets trapped inside fine ink grass cross-hatching along the ground perimeter,
    # and softly feather the outer rim of the grass island into the seamless dark-earthy ground base
    t_arr = np.array(tents_rs, dtype=np.float32)
    lum = 0.299 * t_arr[:, :, 0] + 0.587 * t_arr[:, :, 1] + 0.114 * t_arr[:, :, 2]
    sat = np.max(t_arr[:, :, :3], axis=2) - np.min(t_arr[:, :, :3], axis=2)
    paper_pocket = (np.arange(th)[:, None] > int(th * 0.50)) & (lum > 188.0) & (sat < 34.0)
    t_arr[paper_pocket, 3] = 0.0

    # Smooth distance-like alpha feather on the outer perimeter of the lower grass island (y > 0.56*th)
    ground_zone_a = Image.fromarray(np.clip(t_arr[:, :, 3], 0, 255).astype(np.uint8), "L")
    eroded_a = ground_zone_a.filter(ImageFilter.MinFilter(5)).filter(ImageFilter.GaussianBlur(3.0))
    er_np = np.array(eroded_a, dtype=np.float32)
    lower_rows = np.arange(th) > int(th * 0.58)
    t_arr[lower_rows, :, 3] = np.minimum(t_arr[lower_rows, :, 3], er_np[lower_rows, :])
    for y in range(th - 30, th):
        fy = max(0.0, (th - y) / 30.0)
        t_arr[y, :, 3] *= fy
    tents_blended = Image.fromarray(np.clip(t_arr, 0, 255).astype(np.uint8), "RGBA")

    ox = (cw - tw) // 2
    oy = ch - 4 - th
    canvas.alpha_composite(tents_blended, (ox, oy))
    return canvas


def process_campfire_and_retinue():
    print("[4/5] Processing Campfire Backdrops, Tents, Fire, 4 Escort Carts, 2 Seals & 18 Seated Followers...")
    # Day & Night Camp Backdrops (1024x588)
    for cid, raw_p in CAMP_BG_RAW:
        src = Image.open(raw_p).convert("RGB")
        bg = crop_aspect_resize(src, 1024, 588)
        save_dual(bg, f"campfire/{cid}.jpg", is_jpeg=True)
        src.resize((1280, 735), Image.Resampling.LANCZOS).save(
            os.path.join(HD_DIR, f"{cid}.jpg"), "JPEG", quality=90
        )

    # Tents & Mats Center Layer (1024x588 RGBA)
    tents_im = build_seamless_tents_layer()
    save_dual(tents_im, "campfire/wx_campfire_tents_01.png", is_jpeg=False)
    tents_im.save(os.path.join(HD_DIR, "wx_campfire_tents_01.png"), "PNG", optimize=True)

    # Sheet 56: 16 Seated Retinue Followers (4x4)
    s56 = Image.open(RAW_SHEETS_ARCHIVE[56]).convert("RGB")
    sw56, sh56 = s56.size
    cw56, ch56 = sw56 / 4.0, sh56 / 4.0
    follower_renders_for_qa = {}

    for idx, (stem, target_sz) in enumerate(FOLLOWER_SPECS_SHEET56):
        r, c = divmod(idx, 4)
        cell = s56.crop((
            int(round((c + 0.012) * cw56)),
            int(round((r + 0.012) * ch56)),
            int(round((c + 0.988) * cw56)),
            int(round((r + 0.988) * ch56)),
        ))
        cut = clean_white_cutout(cell, thr=240)
        # HD 512x512 square preview
        hd_sq = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
        sc = min(472.0 / cut.size[0], 472.0 / cut.size[1])
        nw, nh = int(round(cut.size[0] * sc)), int(round(cut.size[1] * sc))
        hd_sq.alpha_composite(cut.resize((nw, nh), Image.Resampling.LANCZOS), ((512 - nw) // 2, 512 - 16 - nh))
        hd_sq.save(os.path.join(HD_DIR, f"wx_{stem}.png"), "PNG", optimize=True)

        placed = place_bottom_centered(cut, target_sz, bottom_pad=4, side_pad=6)
        placed_b = make_hover_bright(placed)
        save_dual(placed, f"campfire/wx_{stem}.png", is_jpeg=False)
        save_dual(placed_b, f"campfire/wx_{stem}_b.png", is_jpeg=False)
        follower_renders_for_qa[stem] = placed

    # Sheet 57: 2 Followers + 4 Escort Carts + Bonfire + Free/Locked Slot Medallions (3x3)
    s57 = Image.open(RAW_SHEETS_ARCHIVE[57]).convert("RGB")
    sw57, sh57 = s57.size
    cw57, ch57 = sw57 / 3.0, sh57 / 3.0
    cart04_for_qa = None
    fire_for_qa = None

    for r, c, kind, stem, target_sz in SHEET57_SPECS:
        cell = s57.crop((
            int(round((c + 0.015) * cw57)),
            int(round((r + 0.015) * ch57)),
            int(round((c + 0.985) * cw57)),
            int(round((r + 0.985) * ch57)),
        ))
        cut = clean_white_cutout(cell, thr=240)

        # Save 512x512 HD
        hd_sq = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
        sc = min(470.0 / cut.size[0], 470.0 / cut.size[1])
        nw, nh = int(round(cut.size[0] * sc)), int(round(cut.size[1] * sc))
        hd_sq.alpha_composite(cut.resize((nw, nh), Image.Resampling.LANCZOS), ((512 - nw) // 2, (512 - nh) // 2))
        hd_sq.save(os.path.join(HD_DIR, f"wx_{stem}.png"), "PNG", optimize=True)

        if kind in ("follower", "cart"):
            placed = place_bottom_centered(cut, target_sz, bottom_pad=4, side_pad=6)
            placed_b = make_hover_bright(placed)
            save_dual(placed, f"campfire/wx_{stem}.png", is_jpeg=False)
            save_dual(placed_b, f"campfire/wx_{stem}_b.png", is_jpeg=False)
            if stem == "cart_04":
                cart04_for_qa = placed
            if kind == "follower":
                follower_renders_for_qa[stem] = placed

        elif kind == "fire":
            # Exact vanilla fire_01.png bbox inside (1024, 588): (256, 382, 559, 544) -> ~285x162 centered at (408, 463)
            fire_canvas = Image.new("RGBA", (1024, 588), (0, 0, 0, 0))
            glow = Image.new("RGBA", (1024, 588), (0, 0, 0, 0))
            gdraw = ImageDraw.Draw(glow)
            gdraw.ellipse((220, 330, 596, 566), fill=(255, 138, 36, 58))
            glow = glow.filter(ImageFilter.GaussianBlur(32))
            fire_canvas = Image.alpha_composite(fire_canvas, glow)

            f_sc = min(260.0 / cut.size[0], 162.0 / cut.size[1])
            fw, fh = int(round(cut.size[0] * f_sc)), int(round(cut.size[1] * f_sc))
            fire_rs = cut.resize((fw, fh), Image.Resampling.LANCZOS)
            fire_canvas.alpha_composite(fire_rs, (408 - fw // 2, 542 - fh))
            save_dual(fire_canvas, "campfire/wx_fire_01.png", is_jpeg=False)
            fire_for_qa = fire_canvas

        elif kind == "slot":
            # Exact vanilla free_slot.png / locked_slot.png medallion sub-rect inside (200, 190): ~60x60 centered at (101, 40)
            slot_canvas = Image.new("RGBA", (200, 190), (0, 0, 0, 0))
            med_sz = 60 if stem == "free_slot" else 56
            s_sc = min(med_sz / float(cut.size[0]), med_sz / float(cut.size[1]))
            mw, mh = int(round(cut.size[0] * s_sc)), int(round(cut.size[1] * s_sc))
            med_rs = cut.resize((mw, mh), Image.Resampling.LANCZOS)
            med_rs = med_rs.filter(ImageFilter.UnsharpMask(radius=0.6, percent=95, threshold=2))

            shad = Image.new("RGBA", (200, 190), (0, 0, 0, 0))
            sdraw = ImageDraw.Draw(shad)
            sdraw.ellipse((101 - mw // 2 - 2, 42 - mh // 2, 101 + mw // 2 + 2, 44 + mh // 2), fill=(0, 0, 0, 135))
            shad = shad.filter(ImageFilter.GaussianBlur(3.0))
            slot_canvas = Image.alpha_composite(slot_canvas, shad)
            slot_canvas.alpha_composite(med_rs, (101 - mw // 2, 40 - mh // 2))

            slot_b = make_hover_bright(slot_canvas)
            save_dual(slot_canvas, f"campfire/wx_{stem}.png", is_jpeg=False)
            save_dual(slot_b, f"campfire/wx_{stem}_b.png", is_jpeg=False)

    # Render QA full assembled campfire night scene for instant visual inspection
    bg_night = Image.open(os.path.join(MOD_UI_DIR, "campfire", "wx_camp_bg_night.jpg")).convert("RGBA")
    qa = Image.alpha_composite(bg_night, tents_im)
    if cart04_for_qa:
        c_small = cart04_for_qa.resize((220, 310), Image.Resampling.LANCZOS)
        qa.alpha_composite(c_small, (12, 235))
    sample_positions = [
        ("alchemist_01", (175, 290)),
        ("blacksmith_01", (505, 285)),
        ("minstrel_01", (665, 315)),
        ("negotiator_01", (810, 295)),
    ]
    for fstem, (fx, fy) in sample_positions:
        if fstem in follower_renders_for_qa:
            fim = follower_renders_for_qa[fstem]
            frs = fim.resize((int(fim.size[0] * 0.62), int(fim.size[1] * 0.62)), Image.Resampling.LANCZOS)
            qa.alpha_composite(frs, (fx, fy))
    if fire_for_qa:
        qa = Image.alpha_composite(qa, fire_for_qa)
    qa.convert("RGB").save(os.path.join(QA_DIR, "qa_campfire_composite.jpg"), "JPEG", quality=92)


def archive_master_sheets():
    print("[0/5] Archiving raw master sheets 54..58 into art/sheets/...")
    for num, src in RAW_SHEETS_ARCHIVE.items():
        dst = os.path.join(SHEETS_DIR, f"sheet_{num}.jpg")
        shutil.copy2(src, dst)


def main():
    ensure_dirs()
    archive_master_sheets()
    process_events()
    process_screens()
    process_menu_skin()
    process_campfire_and_retinue()
    print("[5/5] DONE! All Wave 54..58 Event Illustrations, Screens, Menu Skins, and Campfire/Retinue layers generated.")


if __name__ == "__main__":
    main()
