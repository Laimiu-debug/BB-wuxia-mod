#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Wuxia Sect Sanctum Town-Style Art Pipeline:
Builds all 21 panoramic Sect Mountain Gate backdrops (14 Major Sects + 7 Regional Archetypes,
day + moonlit night, 1024x588 JPG) and 6 clickable Sect Hall building sprites
(知客堂 / 藏经阁 / 传功堂 / 药庐丹房 / 求贤堂 / 演武校场, day/night + hover `_b` RGBA PNGs)
under `mod_wuxia/gfx/ui/sanctums/`, matching the Song/Ming sumi-ink & Battle Brothers
settlement UI palette.
"""

from collections import deque
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "mod_wuxia" / "gfx" / "ui" / "sanctums"
BRAIN_DIR = Path(r"C:\Users\25647\.gemini\antigravity\brain\8250b7dd-e049-4254-b572-8fc5244a0632")
SCRATCH_DIR = BRAIN_DIR / "scratch"

HALL_SHEET = BRAIN_DIR / "sanctum_halls_3x2_clean_1795519838733.jpg"

HALL_GRID = [
    (0, 0, "wx_hall_zhike"),
    (1, 0, "wx_hall_cangjing"),
    (2, 0, "wx_hall_chuangong"),
    (0, 1, "wx_hall_yaolu"),
    (1, 1, "wx_hall_qiuxian"),
    (2, 1, "wx_hall_yanwu"),
]

SCENE_KEYS = [
    # 14 Major Sects
    "shaolin",
    "taihe",
    "qingfeng",
    "tangmen",
    "wudu",
    "gaibang",
    "weiyuan",
    "heifeng",
    "shenji",
    "pishan",
    "zhenyue",
    "jiujie",
    "yinsha",
    "xuanbing",
    # 7 Regional Archetypes
    "reg_plains",
    "reg_mountains",
    "reg_forest",
    "reg_swamp",
    "reg_snow",
    "reg_desert",
    "reg_outlaw",
]


def pick_latest_raw(prefix: str) -> Path:
    cands = sorted(BRAIN_DIR.glob(f"{prefix}_*.jpg"), key=lambda p: p.stat().st_mtime)
    if not cands:
        raise FileNotFoundError(f"Missing generated raw backdrop for prefix '{prefix}' in {BRAIN_DIR}")
    return cands[-1]


def is_bg_white(r: int, g: int, b: int, lum_thresh: float = 216.0, sat_thresh: int = 24) -> bool:
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    sat = max(r, g, b) - min(r, g, b)
    return lum >= lum_thresh and sat <= sat_thresh


def extract_sprite_from_white_cell(cell_rgb: Image.Image) -> Image.Image:
    rgb = cell_rgb.convert("RGB")
    w, h = rgb.size
    px = rgb.load()

    bg = bytearray(w * h)
    q = deque()

    for x in range(w):
        for y in (0, h - 1):
            r, g, b = px[x, y]
            if is_bg_white(r, g, b, 212.0, 26):
                idx = y * w + x
                if not bg[idx]:
                    bg[idx] = 1
                    q.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            r, g, b = px[x, y]
            if is_bg_white(r, g, b, 212.0, 26):
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
                    if is_bg_white(r, g, b, 214.0, 24):
                        bg[nidx] = 1
                        q.append((nx, ny))

    # Clear enclosed pure paper-white holes (between spear shafts, stone railings, awning posts)
    seed_sky = []
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            idx = y * w + x
            if bg[idx]:
                continue
            r, g, b = px[x, y]
            if min(r, g, b) >= 245 and (max(r, g, b) - min(r, g, b)) <= 8:
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
                    if min(r, g, b) >= 240 and (max(r, g, b) - min(r, g, b)) <= 12:
                        bg[nidx] = 1
                        sq.append((nx, ny))

    # Remove tiny dust specks while preserving incense tripod, alchemy cauldron & banners
    vis = bytearray(w * h)
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
                if len(pts) < 40:
                    for px_x, px_y in pts:
                        bg[px_y * w + px_x] = 1

    # Anti-aliased alpha & edge white-fringe decontamination
    alpha = Image.new("L", (w, h), 0)
    apx = alpha.load()
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    opx = out.load()

    for y in range(h):
        for x in range(w):
            if not bg[y * w + x]:
                apx[x, y] = 255

    # Two-pass soft halo trim for ultra-clean ink contours on dark or stone courtyards
    for _pass in range(2):
        to_trim = []
        for y in range(1, h - 1):
            for x in range(1, w - 1):
                if apx[x, y] == 0:
                    continue
                touches_bg = (
                    apx[x, y - 1] == 0 or apx[x, y + 1] == 0
                    or apx[x - 1, y] == 0 or apx[x + 1, y] == 0
                )
                if touches_bg:
                    r, g, b = px[x, y]
                    lum = 0.299 * r + 0.587 * g + 0.114 * b
                    if lum > 205:
                        to_trim.append((x, y, 0))
                    elif _pass == 1 and lum > 165:
                        to_trim.append((x, y, 150))
        for x, y, na in to_trim:
            apx[x, y] = na

    for y in range(h):
        for x in range(w):
            a_val = apx[x, y]
            if a_val == 0:
                continue
            r, g, b = px[x, y]
            if 0 < x < w - 1 and 0 < y < h - 1:
                touches_bg = (
                    apx[x, y - 1] < 180 or apx[x, y + 1] < 180
                    or apx[x - 1, y] < 180 or apx[x + 1, y] < 180
                )
                if touches_bg:
                    lum = 0.299 * r + 0.587 * g + 0.114 * b
                    if lum > 155:
                        a_val = min(a_val, 185)
                    r = int(r * 0.76)
                    g = int(g * 0.74)
                    b = int(b * 0.71)
            opx[x, y] = (r, g, b, a_val)

    return out


def tight_crop_rgba(rgba: Image.Image, alpha_min: int = 20) -> Image.Image:
    bbox = rgba.getchannel("A").point(lambda a: 255 if a >= alpha_min else 0).getbbox()
    return rgba.crop(bbox) if bbox else rgba


def grade_wuxia_parchment(rgba: Image.Image) -> Image.Image:
    a = rgba.getchannel("A")
    rgb = rgba.convert("RGB")
    rgb = ImageEnhance.Color(rgb).enhance(0.92)
    rgb = ImageEnhance.Contrast(rgb).enhance(1.04)
    warm = Image.new("RGB", rgba.size, (202, 186, 158))
    rgb = Image.blend(rgb, ImageChops.multiply(rgb, warm), 0.10)
    out = rgb.convert("RGBA")
    out.putalpha(a)
    return out


def add_grounded_contact_shadow(sprite_rgba: Image.Image, tw: int, th: int, pad_x: int = 12, pad_bottom: int = 10) -> Image.Image:
    tc = tight_crop_rgba(sprite_rgba)
    mw = max(1, tw - 2 * pad_x)
    mh = max(1, th - pad_bottom - 8)
    s = min(mw / float(tc.width), mh / float(tc.height))
    nw = max(1, int(round(tc.width * s)))
    nh = max(1, int(round(tc.height * s)))
    rs = tc.resize((nw, nh), Image.Resampling.LANCZOS)
    rs = rs.filter(ImageFilter.UnsharpMask(radius=0.8, percent=105, threshold=3))

    ox = (tw - nw) // 2
    oy = th - pad_bottom - nh

    foot = Image.new("L", (tw, th), 0)
    src_a = rs.getchannel("A")
    band_h = max(10, int(nh * 0.22))
    foot_strip = src_a.crop((0, nh - band_h, nw, nh)).resize((nw, max(8, int(band_h * 0.58))), Image.Resampling.BILINEAR)
    foot.paste(foot_strip, (ox, oy + nh - foot_strip.height + 4))
    foot_blur = foot.filter(ImageFilter.GaussianBlur(6.5))
    foot_alpha = foot_blur.point(lambda v: min(145, int(v * 0.72)))

    shadow = Image.new("RGBA", (tw, th), (12, 9, 6, 0))
    shadow.putalpha(foot_alpha)

    out = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    out = Image.alpha_composite(out, shadow)
    out.alpha_composite(rs, (ox, oy))
    return out


def make_warm_lantern_glow(rgba: Image.Image, boost: float = 1.0) -> Image.Image:
    w, h = rgba.size
    px = rgba.load()
    seed = Image.new("L", (w, h), 0)
    spx = seed.load()
    for y in range(int(h * 0.05), int(h * 0.94)):
        for x in range(int(w * 0.03), int(w * 0.97)):
            r, g, b, a = px[x, y]
            if a < 180:
                continue
            is_red_lantern = (r >= 158 and (r - g) >= 26 and (r - b) >= 60)
            is_bright_flame = (r >= 210 and g >= 128 and b <= 100 and (r - b) >= 105)
            if is_red_lantern or is_bright_flame:
                spx[x, y] = 255

    clean_seed = seed.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.MaxFilter(3))
    core_alpha = clean_seed.point(lambda v: min(245, int(v * 0.92 * boost)))
    halo_wide = clean_seed.filter(ImageFilter.GaussianBlur(8.0)).point(lambda v: min(195, int(v * 1.35 * boost)))
    halo_tight = clean_seed.filter(ImageFilter.GaussianBlur(2.6)).point(lambda v: min(235, int(v * 1.15 * boost)))

    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    l_wide = Image.new("RGBA", (w, h), (255, 166, 54, 0))
    l_wide.putalpha(halo_wide)
    l_tight = Image.new("RGBA", (w, h), (255, 206, 98, 0))
    l_tight.putalpha(halo_tight)
    l_core = Image.new("RGBA", (w, h), (255, 234, 160, 0))
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
    dark = ImageEnhance.Brightness(rgb).enhance(0.46)
    moon = Image.new("RGB", (w, h), (28, 42, 68))
    night_rgb = Image.blend(dark, moon, 0.36)
    out = night_rgb.convert("RGBA")
    out.putalpha(rgba.getchannel("A"))
    if lantern_boost > 0.0:
        glow = make_warm_lantern_glow(rgba, boost=lantern_boost)
        out = Image.alpha_composite(out, glow)
        out.putalpha(rgba.getchannel("A"))
    return out


def make_hover_bright(rgba: Image.Image) -> Image.Image:
    a = rgba.getchannel("A")
    rgb = rgba.convert("RGB")
    rgb = ImageEnhance.Brightness(rgb).enhance(1.22)
    rgb = ImageEnhance.Color(rgb).enhance(1.10)
    gold = Image.new("RGB", rgba.size, (255, 224, 152))
    rgb = Image.blend(rgb, gold, 0.09)
    out = rgb.convert("RGBA")
    out.putalpha(a)
    return out


def crop_cover_1024x588(img: Image.Image) -> Image.Image:
    tw, th = 1024, 588
    src = img.convert("RGB")
    sw, sh = src.size
    target_ratio = tw / float(th)
    src_ratio = sw / float(sh)
    if src_ratio > target_ratio:
        new_w = int(round(sh * target_ratio))
        left = (sw - new_w) // 2
        src = src.crop((left, 0, left + new_w, sh))
    else:
        new_h = int(round(sw / target_ratio))
        top = max(0, (sh - new_h) // 2)
        src = src.crop((0, top, sw, top + new_h))
    res = src.resize((tw, th), Image.Resampling.LANCZOS)
    res = res.filter(ImageFilter.UnsharpMask(radius=0.75, percent=95, threshold=4))
    # Subtle warm Battle Brothers parchment tone & soft dark edge vignette
    res = ImageEnhance.Color(res).enhance(0.92)
    warm = Image.new("RGB", (tw, th), (204, 188, 160))
    res = Image.blend(res, ImageChops.multiply(res, warm), 0.11)

    vig = Image.new("L", (tw, th), 255)
    draw = ImageDraw.Draw(vig)
    draw.rectangle((18, 14, tw - 18, th - 14), fill=255)
    # Soft outer shadow border
    edge = Image.new("L", (tw, th), 0)
    edraw = ImageDraw.Draw(edge)
    edraw.rectangle((22, 16, tw - 22, th - 18), fill=255)
    edge = edge.filter(ImageFilter.GaussianBlur(18))
    dark_bg = Image.new("RGB", (tw, th), (18, 14, 10))
    res = Image.composite(res, Image.blend(res, dark_bg, 0.35), edge)
    return res


def make_night_backdrop(day_rgb: Image.Image) -> Image.Image:
    rgba = day_rgb.convert("RGBA")
    night = make_night_rgba(rgba, lantern_boost=1.05)
    return night.convert("RGB")


def build_halls() -> dict[str, Image.Image]:
    sheet = Image.open(HALL_SHEET).convert("RGB")
    sw, sh = sheet.size
    cw = sw // 3
    ch = sh // 2
    built = {}

    for col, row, stem in HALL_GRID:
        x0 = col * cw
        y0 = row * ch
        x1 = sw if col == 2 else (col + 1) * cw
        y1 = sh if row == 1 else (row + 1) * ch
        cell = sheet.crop((x0, y0, x1, y1))
        extracted = extract_sprite_from_white_cell(cell)
        graded = grade_wuxia_parchment(extracted)
        day_img = add_grounded_contact_shadow(graded, 340, 240, pad_x=12, pad_bottom=10)
        day_b = make_hover_bright(day_img)
        night_img = make_night_rgba(day_img, lantern_boost=1.12)
        night_b = make_hover_bright(night_img)

        day_img.save(OUT_DIR / f"{stem}.png", optimize=True)
        day_b.save(OUT_DIR / f"{stem}_b.png", optimize=True)
        night_img.save(OUT_DIR / f"{stem}_night.png", optimize=True)
        night_b.save(OUT_DIR / f"{stem}_night_b.png", optimize=True)
        built[stem] = day_img
        print(f"  [HALL] {stem}: 4 variants saved")
    return built


def build_backdrops() -> dict[str, Image.Image]:
    built = {}
    for key in SCENE_KEYS:
        raw_path = pick_latest_raw(f"bg_{key}_raw")
        raw = Image.open(raw_path)
        day = crop_cover_1024x588(raw)
        night = make_night_backdrop(day)
        day_out = OUT_DIR / f"wx_sanctum_bg_{key}.jpg"
        night_out = OUT_DIR / f"wx_sanctum_bg_{key}_night.jpg"
        day.save(day_out, format="JPEG", quality=84, optimize=True)
        night.save(night_out, format="JPEG", quality=82, optimize=True)
        built[key] = day
        print(f"  [BG] {key}: <- {raw_path.name} ({day_out.stat().st_size // 1024}KB / {night_out.stat().st_size // 1024}KB)")
    return built


def render_composite_preview(bg_rgb: Image.Image, halls: dict[str, Image.Image], out_path: Path) -> None:
    """Visual verification mock matching the exact 6 CSS hall slots on 1024x588."""
    comp = bg_rgb.convert("RGBA")
    # Symmetrical courtyard U-arc leaving the central Mountain Gate vista completely open!
    # (stem, center_x, bottom_y, height_px)
    placements = [
        ("wx_hall_cangjing",  262, 438, 126),  # rear-left
        ("wx_hall_chuangong", 762, 438, 126),  # rear-right
        ("wx_hall_zhike",     128, 560, 144),  # front-far-left
        ("wx_hall_yaolu",     368, 560, 138),  # front-inner-left
        ("wx_hall_qiuxian",   656, 560, 140),  # front-inner-right
        ("wx_hall_yanwu",     896, 560, 144),  # front-far-right
    ]
    for stem, cx, by, h_px in placements:
        im = halls[stem]
        w_px = int(round(im.width * (h_px / float(im.height))))
        rs = im.resize((w_px, h_px), Image.Resampling.LANCZOS)
        comp.alpha_composite(rs, (cx - w_px // 2, by - h_px))
    SCRATCH_DIR.mkdir(parents=True, exist_ok=True)
    comp.convert("RGB").save(out_path, format="JPEG", quality=88)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    print("Building 6 Clickable Sect Hall Sprites...")
    halls = build_halls()
    print("Building 21 Panoramic Sect Mountain Gate Backdrops (day + night)...")
    bgs = build_backdrops()
    render_composite_preview(bgs["gaibang"], halls, SCRATCH_DIR / "sanctum_preview_gaibang.jpg")
    render_composite_preview(bgs["shaolin"], halls, SCRATCH_DIR / "sanctum_preview_shaolin.jpg")
    render_composite_preview(bgs["xuanbing"], halls, SCRATCH_DIR / "sanctum_preview_xuanbing.jpg")
    render_composite_preview(bgs["wudu"], halls, SCRATCH_DIR / "sanctum_preview_wudu.jpg")
    total_bytes = sum(p.stat().st_size for p in OUT_DIR.glob("*"))
    print(f"DONE: {len(list(OUT_DIR.glob('*')))} files in {OUT_DIR} ({total_bytes / 1048576:.2f} MiB)")


if __name__ == "__main__":
    main()
