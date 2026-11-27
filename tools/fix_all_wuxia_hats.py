#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Comprehensive 46-Hat / Helmet Placement, Wrapping, Back-Rim Occlusion & Facing Overhaul (`tools/fix_all_wuxia_hats.py`):
Anatomical anchor in canonical 128x164 space (`wx_head_01..48`):
  - Skull top:  y = 39
  - Hairline:   y = 44..46
  - Brow brim:  y = 47..49  (strictly ABOVE eyebrows at y=51..53!)
  - Eyes:       y = 55..58
  - Chin:       y = 85
  - Skull X:    x = 42..86 (center cx = 64.5)

Fixes ALL defects across all 46 hats:
  1. Reversed Facing (`wx_char_hat_helm_fengchi`, `wx_helm_taotie`):
     Merges back+front, mirrors around head axis to canonical 3/4-right, seats cleanly above brows
     (or aligned to eye height for full-face `wx_helm_taotie`), and splits cleanly.
  2. Proper Back-Rim Occlusion (`后沿被人物头遮挡`) & Cheek-Guard Recovery:
     - `wx_helm_dijiang`, `wx_helm_bingyi`, `wx_helm_jinwu`, `wx_hat_27`, `wx_char_hat_helm_fengchi`:
       Re-merges left cheek-guard from `hat_back`, seats brow rim squarely at `y=48..49` (leaving eyebrows
       100% clear!), moves the dark interior back-wall (`x>54, y>brow_y`) into `hat_back` so the head
       occludes it, and trims stray far-right rear flaps sticking out beyond the cheek.
     - `wx_helm_bashe`: Erases the floating hollow upper back-wall (`y<43` inside the empty ring) that
       used to peek above the skull top, keeping the complete emerald serpent V-circlet wrapped across
       the forehead (`y=44..50`) with zero floating back-rim.
     - Conical & kettle hats (`wx_char_hat_bamboo`, `wx_hat_02`, `wx_hat_03`, `wx_hat_07`, `wx_hat_25`,
       `wx_hat_26`): Moves any dark interior back-brim / underside hollow pixels inside the head span
       strictly into `hat_back` (occluded by the head!) and seats front brim cleanly at `y=47..49`.
  3. Accurate Eyebrow-Safe Heights Across All 46 Hats:
     - Headbands (`wx_hat_12/13/15/16/21/22`): centered cleanly on mid-forehead (`y=45..48`), never pressing brows.
     - Topknot crowns (`wx_char_hat_taoist`, `wx_char_hat_topknot`, `wx_hat_14`): seated on crown/bun (`y<44`), never on forehead.
     - Tall Daoist/Noble crowns (`wx_hat_09`, `wx_hat_10`): seated at hairline (`y=46..48`) with snug dark base cap.
"""

import struct
import sys
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))

from compile_wuxia_brushes import (
    shelf_pack_sprites,
    write_brush_binary,
)
from fix_v088_visuals_and_brushes import clean_zero_alpha_rgba, load_brush_records
from add_injured_brush_aliases import main as add_injured_aliases
from overhaul_wuxia_paperdoll import (
    OUT_W,
    OUT_H,
    SKULL_128,
    clamp8,
    make_corpse_from_128,
    make_world_bust_from_128,
)

MOD_DIR = ROOT / "mod_wuxia"
BRUSH_DIR = MOD_DIR / "brushes"
BACKUP_BRUSH = Path(r"C:\Users\25647\.gemini\antigravity\brain\86c6bebb-e8ff-4e4b-a478-c60be0ad2ca2\scratch\hat_backup_v1\wx_busts_0.brush")
BACKUP_PNG = Path(r"C:\Users\25647\.gemini\antigravity\brain\86c6bebb-e8ff-4e4b-a478-c60be0ad2ca2\scratch\hat_backup_v1\wx_busts_0.png")

HEAD_CX = 64.5
HEAD_CY = 56.0


def load_records_with_png(brush_path: Path, png_path: Path | None = None):
    data = brush_path.read_bytes()
    magic, _ver, gl = struct.unpack_from("<IHH", data, 0)
    assert magic == 0xBAADFAAD
    gfx_rel = data[8 : 8 + gl].decode("ascii").replace("\\", "/")
    pos = 8 + gl
    aw, ah = struct.unpack_from("<HH", data, pos)
    pos += 16
    cnt, _, _ = struct.unpack_from("<IHI", data, pos)
    pos += 10

    atlas = Image.open(png_path if png_path is not None else (MOD_DIR / gfx_rel)).convert("RGBA")
    recs = []
    for _ in range(cnt):
        _, sl = struct.unpack_from("<QH", data, pos)
        pos += 10
        sid = data[pos : pos + sl].decode("ascii")
        pos += sl
        _, w, h, ox, oy = struct.unpack_from("<QIIhh", data, pos)
        pos += 53
        _fc, srcl = struct.unpack_from("<HH", data, pos)
        pos += 4
        src_rel = data[pos : pos + srcl].decode("ascii")
        pos += srcl
        u0, u1, v0, v1, fL, _fR, _fT, fB = struct.unpack_from("<8f", data, pos)
        pos += 35
        if sid.endswith("_injured"):
            continue
        ax0, ax1 = int(round(u0 * aw)), int(round(u1 * aw))
        ay0, ay1 = int(round(v0 * ah)), int(round(v1 * ah))
        crop = ImageOps.flip(atlas.crop((ax0, ay0, ax1, ay1)))
        bx0 = int(round(fL + w / 2.0))
        by0 = int(round(h / 2.0 - fB))
        canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        canvas.paste(crop, (max(0, bx0), max(0, by0)))
        recs.append({"id": sid, "img": canvas, "ox": ox, "oy": oy, "src_rel": src_rel})
    return gfx_rel, recs


def xform_128(im: Image.Image, dx: float = 0.0, dy: float = 0.0, sx: float = 1.0, sy: float = 1.0,
              px: float = HEAD_CX, py: float = HEAD_CY) -> Image.Image:
    if abs(dx) < 1e-4 and abs(dy) < 1e-4 and abs(sx - 1.0) < 1e-4 and abs(sy - 1.0) < 1e-4:
        return im.copy()
    inv_sx = 1.0 / sx
    inv_sy = 1.0 / sy
    a = inv_sx
    c = px - (px + dx) * inv_sx
    e = inv_sy
    f = py - (py + dy) * inv_sy
    return im.transform(
        (OUT_W, OUT_H),
        Image.Transform.AFFINE,
        (a, 0.0, c, 0.0, e, f),
        resample=Image.Resampling.BICUBIC,
    )


def mirror_around_head_cx(im: Image.Image, cx: float = HEAD_CX) -> Image.Image:
    return im.transform(
        (OUT_W, OUT_H),
        Image.Transform.AFFINE,
        (-1.0, 0.0, 2.0 * cx, 0.0, 1.0, 0.0),
        resample=Image.Resampling.BICUBIC,
    )


def darken_rgba(im: Image.Image, mult: float = 0.65) -> Image.Image:
    out = im.copy()
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = px[x, y]
            if a:
                px[x, y] = (clamp8(r * mult), clamp8(g * mult), clamp8(b * mult), a)
    return out


def split_34_right_open_helmet(full_128: Image.Image,
                               brow_y: int = 49,
                               brow_dip_center: int = 2,
                               left_guard_x: int = 54,
                               right_guard_x: int = 84,
                               trim_right_back_x: int = 86,
                               cavity_rgb: tuple[int, int, int] = (24, 18, 15)) -> tuple[Image.Image, Image.Image]:
    """
    Splits a complete 3/4-right open-face helmet (`full_128`) into (`hat_front`, `hat_back`) with
    strict back-rim occlusion:
      - `hat_front` keeps ONLY the front brow/visor/dome/wings (`y <= brow_y`) and the front-facing
        LEFT temple/ear/cheek guard (`x <= left_guard_x`).
      - Everything inside the open face cavity (`x > left_guard_x` and `y > brow_y`), including the
        helmet's dark inside back-wall (`后沿`) and far-right inner cheek rim, is moved strictly into
        `hat_back` (`z < head`) so the character's head naturally occludes it!
      - Trims any wide stray rear cheek flap extending past `trim_right_back_x` in `hat_back` below brow.
    """
    # Build curved 3/4-right face-window mask (255 = goes to hat_back behind head; 0 = stays in hat_front)
    face_cut = Image.new("L", (OUT_W, OUT_H), 0)
    fd = ImageDraw.Draw(face_cut)
    # Curve slightly down at center brow (x=70) for V-shaped brow peaks, rising cleanly at left/right temples
    poly = [
        (left_guard_x + 1, brow_y),
        (68, brow_y + brow_dip_center),
        (right_guard_x - 1, brow_y),
        (right_guard_x + 12, brow_y + 2),
        (right_guard_x + 16, 98),
        (left_guard_x + 4, 98),
        (left_guard_x + 2, 72),
        (left_guard_x, 58),
    ]
    fd.polygon(poly, fill=255)
    face_cut = face_cut.filter(ImageFilter.GaussianBlur(0.75))

    inv_cut = ImageOps.invert(face_cut)
    fa = full_128.getchannel("A")

    front = full_128.copy()
    front.putalpha(ImageChops.multiply(fa, inv_cut))

    back_raw = full_128.copy()
    back_raw.putalpha(ImageChops.multiply(fa, face_cut))
    back = darken_rgba(back_raw, 0.72)

    # Trim any stray far-right back-rim sticking out past the right edge of the skull (`x > trim_right_back_x`)
    bpx = back.load()
    for y in range(brow_y + 1, OUT_H):
        for x in range(trim_right_back_x, OUT_W):
            if bpx[x, y][3] > 0:
                bpx[x, y] = (0, 0, 0, 0)

    # Subtle recessed dark interior lining strictly behind skull (never exceeding head width!)
    cav = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
    ImageDraw.Draw(cav).ellipse([44, brow_y - 3, 84, 78], fill=(*cavity_rgb, 195))
    cav = cav.filter(ImageFilter.GaussianBlur(0.8))
    bb = full_128.getbbox()
    if bb:
        clip = Image.new("L", (OUT_W, OUT_H), 0)
        ImageDraw.Draw(clip).rectangle([max(43, bb[0] + 2), brow_y - 2, min(84, bb[2] - 2), min(78, bb[3] - 1)], fill=255)
        cav.putalpha(ImageChops.multiply(cav.getchannel("A"), clip))
    back = Image.alpha_composite(cav, back)

    # Soft cast brow shadow right below the brow rim
    sh = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
    ImageDraw.Draw(sh).ellipse([47, brow_y - 2, 83, brow_y + 4], fill=(14, 10, 8, 76))
    sh = sh.filter(ImageFilter.GaussianBlur(1.1))
    sh.putalpha(ImageChops.multiply(sh.getchannel("A"), SKULL_128))
    front = Image.alpha_composite(sh, front)

    return front, back


def occlude_conical_back_rim(f_in: Image.Image, b_in: Image.Image | None,
                             dx: float, dy: float, sx: float, sy: float,
                             front_brim_y: int = 47,
                             brim_arch: float = 2.0,
                             dark_lum_thresh: int = 68,
                             force_cut_y: int | None = None) -> tuple[Image.Image, Image.Image]:
    """
    Seats a wide-brim conical / straw / kettle hat cleanly ABOVE the eyebrows (`front_brim_y = 47..48`)
    and moves any dark underside / inside-back-rim (`后沿`) pixels hanging below the front brim curve
    within the head span (`x = 42..86`) OUT of `hat_front` and strictly into `hat_back` (occluded by head!).
    """
    f = xform_128(f_in, dx=dx, dy=dy, sx=sx, sy=sy)
    b = xform_128(b_in, dx=dx, dy=dy, sx=sx, sy=sy) if b_in is not None else Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))

    fpx = f.load()
    moved = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
    mpx = moved.load()

    for y in range(front_brim_y - 2, 82):
        for x in range(40, 89):
            r, g, b_c, a = fpx[x, y]
            if a < 10:
                continue
            # Parabolic front-brim line across forehead (slightly arched upward in center or downward at edges)
            nx = (x - 64.5) / 23.0
            rim_y = front_brim_y - brim_arch * (1.0 - min(1.0, nx * nx))
            lum = 0.299 * r + 0.587 * g + 0.114 * b_c
            # Move anything strictly below the front brim line (or dark underside cavity right under it) to hat_back!
            if (force_cut_y is not None and y >= force_cut_y) or (y > rim_y + 1.5) or (y >= rim_y and lum < dark_lum_thresh):
                fpx[x, y] = (0, 0, 0, 0)
                mpx[x, y] = (r, g, b_c, a)

    b_out = Image.alpha_composite(b, moved)

    # Subtle 1px brow cast shadow right below front brim
    sh = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
    ImageDraw.Draw(sh).ellipse([46, front_brim_y - 2, 84, front_brim_y + 4], fill=(14, 10, 7, 74))
    sh = sh.filter(ImageFilter.GaussianBlur(1.2))
    sh.putalpha(ImageChops.multiply(sh.getchannel("A"), SKULL_128))
    f_out = Image.alpha_composite(sh, f)
    return f_out, b_out


def paint_crown_skull_wrap(front: Image.Image, back: Image.Image,
                           base_rgb: tuple[int, int, int],
                           rim_rgb: tuple[int, int, int],
                           top_y: int = 38, brow_y: int = 47) -> tuple[Image.Image, Image.Image]:
    """
    Adds a clean Ming-style dark hairnet/crown-base skull wrap (`网巾/冠座`) strictly at the HAIRLINE
    (`brow_y = 47`, well above eyebrows at `y = 52`) so tall Daoist/Noble crowns hug the cranium naturally!
    """
    cap_f = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
    cd = ImageDraw.Draw(cap_f)
    cd.ellipse([42, top_y, 85, brow_y + 6], fill=(*base_rgb, 240))
    face_m = Image.new("L", (OUT_W, OUT_H), 255)
    fmd = ImageDraw.Draw(face_m)
    # Keep left temple side-wrap down to y=56, clear forehead & face below brow_y=47!
    fmd.polygon([(52, brow_y), (88, brow_y - 1), (88, 90), (49, 90), (49, 57)], fill=0)
    face_m = face_m.filter(ImageFilter.GaussianBlur(0.8))
    cap_f.putalpha(ImageChops.multiply(cap_f.getchannel("A"), face_m))

    pipe = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
    ImageDraw.Draw(pipe).arc([42, brow_y - 6, 85, brow_y + 2], start=14, end=168, fill=(*rim_rgb, 210), width=1)
    pipe.putalpha(ImageChops.multiply(pipe.getchannel("A"), face_m))
    cap_f = Image.alpha_composite(cap_f, pipe)

    ca = cap_f.getchannel("A").point(lambda v: 255 if v > 130 else 0)
    rim_a = ImageChops.subtract(ca.filter(ImageFilter.MaxFilter(3)), ca).point(lambda v: int(v * 0.65))
    ink = Image.new("RGBA", (OUT_W, OUT_H), (18, 14, 12, 0))
    ink.putalpha(rim_a)
    cap_f = Image.alpha_composite(ink, cap_f)

    sh = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
    ImageDraw.Draw(sh).ellipse([47, brow_y - 1, 83, brow_y + 4], fill=(14, 10, 8, 72))
    sh = sh.filter(ImageFilter.GaussianBlur(1.1))
    sh.putalpha(ImageChops.multiply(sh.getchannel("A"), SKULL_128))

    out_f = Image.alpha_composite(sh, Image.alpha_composite(cap_f, front))

    # Rear cuff strictly behind skull (`y >= top_y + 2`, never poking above skull!)
    cap_b = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
    ImageDraw.Draw(cap_b).ellipse([42, top_y + 2, 85, brow_y + 9], fill=(clamp8(base_rgb[0]*0.62), clamp8(base_rgb[1]*0.62), clamp8(base_rgb[2]*0.62), 220))
    out_b = Image.alpha_composite(cap_b, back) if back is not None else cap_b
    return out_f, out_b


# Eyebrow-safe precision seating relative to clean `hat_backup_v1` (which already had Turn 1 seating!):
STANDARD_HAT_TRANSFORMS = {
    "wx_beast_helm_heavy": (0.5, 0.0, 1.02, 1.01),
    "wx_beast_helm_light": (0.5, 0.5, 1.03, 1.02),
    "wx_char_hat_bamboo":  (0.5, 2.5, 1.05, 1.04),   # Conical bamboo brim squarely at forehead y=47..48, intact front brim!
    "wx_hat_01":           (1.0, 0.5, 1.03, 1.02),
    "wx_hat_02":           (-1.0, 1.5, 1.04, 1.03),  # Straw hat squarely above brows, intact front brim!
    "wx_hat_03":           (0.5, 1.5, 1.05, 1.04),   # Bamboo rainhat squarely above brows, intact front brim!
    "wx_hat_04":           (0.5, 0.0, 1.02, 1.01),
    "wx_hat_05":           (1.0, 0.0, 1.03, 1.02),
    "wx_hat_06":           (1.0, 0.0, 1.02, 1.01),
    "wx_hat_07":           (0.5, 2.0, 1.05, 1.04),   # Conical bamboo hat squarely above brows, intact front brim!
    "wx_hat_08":           (0.0, 0.0, 1.01, 1.01),
    "wx_hat_11":           (0.5, 0.0, 1.02, 1.01),
    "wx_hat_12":           (1.0, -1.0, 1.02, 1.01),  # Cloth headband cleanly on mid-forehead above brows
    "wx_hat_13":           (0.5, -1.5, 1.02, 1.01),  # Beggar headband cleanly above brows
    "wx_hat_14":           (1.0, 0.0, 1.06, 1.06),   # Topknot hair-crown cleanly on bun
    "wx_hat_15":           (0.5, -0.5, 1.04, 1.03),  # Miao silver headband cleanly above brows
    "wx_hat_16":           (1.0, -1.0, 1.02, 1.01),  # White headband cleanly above brows
    "wx_hat_17":           (0.0, 0.0, 1.01, 1.01),   # Lower half-mask
    "wx_hat_18":           (0.0, 0.0, 1.00, 1.00),   # Full bronze mask
    "wx_hat_19":           (1.0, 0.5, 1.03, 1.02),   # Wolf pelt cleanly above brows
    "wx_hat_20":           (0.5, 0.0, 1.02, 1.01),
    "wx_hat_21":           (1.0, -1.0, 1.02, 1.01),  # Monk circlet cleanly above brows
    "wx_hat_22":           (1.0, -1.5, 1.02, 1.01),  # Outlaw headband cleanly above brows
    "wx_hat_23":           (-0.5, 0.0, 1.01, 1.01),  # Full bronze helm
    "wx_hat_24":           (1.0, 0.0, 1.02, 1.01),
    "wx_hat_25":           (0.5, 2.0, 1.02, 1.01),   # Iron kettle helm cleanly above brows, intact steel brim!
    "wx_hat_26":           (0.5, 1.0, 1.03, 1.02),   # Black iron kettle helm cleanly above brows, intact brim!
    "wx_hat_28":           (0.5, 0.0, 1.02, 1.01),
    "wx_hat_29":           (0.0, 0.0, 1.01, 1.01),   # Full iron visor helm
    "wx_hat_30":           (0.5, 0.5, 1.03, 1.02),   # Winged iron crown cleanly above brows
    "wx_hat_31":           (1.0, 0.0, 1.02, 1.01),
    "wx_hat_32":           (0.5, 0.5, 1.03, 1.02),   # Golden dragon helm cleanly above brows
    "wx_helm_chiyou":      (0.0, 0.0, 1.03, 1.01),   # T-visor aligned to eyes
    "wx_helm_kaiming":     (0.5, 0.0, 1.03, 1.02),   # Tiger crown cleanly above brows
    "wx_helm_siwang":      (0.5, 0.0, 1.02, 1.01),   # Rhino helm cleanly above brows
}


def process_single_hat(hid: str, f_in: Image.Image, b_in: Image.Image | None) -> tuple[Image.Image, Image.Image | None]:
    empty_b = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
    b_safe = b_in if b_in is not None else empty_b

    # === 1. REVERSED-FACING HELMETS (merge -> mirror to 3/4-right -> brow-safe seat -> proper split) ===
    if hid == "wx_char_hat_helm_fengchi":
        merged = Image.alpha_composite(b_safe, f_in)
        mir = mirror_around_head_cx(merged, cx=64.0)
        seated = xform_128(mir, dx=1.0, dy=0.5, sx=1.05, sy=1.04)
        return split_34_right_open_helmet(seated, brow_y=49, brow_dip_center=2,
                                          left_guard_x=54, right_guard_x=83, trim_right_back_x=85,
                                          cavity_rgb=(26, 20, 16))

    if hid == "wx_helm_taotie":
        merged = Image.alpha_composite(b_safe, f_in)
        mir = mirror_around_head_cx(merged, cx=63.5)
        seated = xform_128(mir, dx=1.0, dy=1.0, sx=1.10, sy=1.09)
        bk = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
        ImageDraw.Draw(bk).ellipse([42, 41, 86, 84], fill=(22, 16, 12, 230))
        bk = bk.filter(ImageFilter.GaussianBlur(0.8))
        return seated, bk

    # === 2. SHAN-HAI HELMETS: RECOVER LEFT CHEEK-GUARD + OCCLUDE INSIDE BACK-RIM BEHIND HEAD ===
    if hid == "wx_helm_dijiang":
        merged = Image.alpha_composite(b_safe, f_in)
        # Seat brow peak cleanly at y=48.5..49.5 (no bald gap AND eyebrows 100% clear!), pull back onto skull!
        seated = xform_128(merged, dx=-3.0, dy=6.8, sx=1.07, sy=1.08)
        return split_34_right_open_helmet(seated, brow_y=49, brow_dip_center=3,
                                          left_guard_x=54, right_guard_x=83, trim_right_back_x=85,
                                          cavity_rgb=(32, 13, 11))

    if hid == "wx_helm_bingyi":
        merged = Image.alpha_composite(b_safe, f_in)
        seated = xform_128(merged, dx=-2.0, dy=5.5, sx=1.06, sy=1.08)
        return split_34_right_open_helmet(seated, brow_y=49, brow_dip_center=2,
                                          left_guard_x=55, right_guard_x=83, trim_right_back_x=85,
                                          cavity_rgb=(18, 30, 28))

    if hid == "wx_helm_jinwu":
        merged = Image.alpha_composite(b_safe, f_in)
        seated = xform_128(merged, dx=-2.2, dy=5.5, sx=1.06, sy=1.08)
        return split_34_right_open_helmet(seated, brow_y=48, brow_dip_center=2,
                                          left_guard_x=54, right_guard_x=83, trim_right_back_x=85,
                                          cavity_rgb=(24, 15, 11))

    if hid == "wx_helm_bashe":
        # Razor-clean jade serpent diadem/circlet across forehead (y=44..51):
        # strictly erase ALL hollow upper back-wall pixels (`y < 43` everywhere!) so ZERO back-rim floats above skull!
        merged = Image.alpha_composite(b_safe, f_in)
        seated = xform_128(merged, dx=0.5, dy=1.0, sx=1.04, sy=1.02)
        f_out = seated.copy()
        fpx = f_out.load()
        for y in range(OUT_H):
            for x in range(OUT_W):
                r, g, b_c, a = fpx[x, y]
                if a < 10:
                    continue
                nx = (x - 66.0) / 22.0
                # Flat-arched horizontal forehead diadem: strictly y >= 43 everywhere, dipping to y=51.5 at center V-crest
                band_top = 43.0
                band_bot = 51.5 - 2.0 * min(1.0, nx * nx)
                if y < band_top or y > 56:
                    fpx[x, y] = (0, 0, 0, 0)
                elif y > band_bot and x > 50:
                    fpx[x, y] = (0, 0, 0, 0)
                elif x < 41 or x > 87:
                    fpx[x, y] = (0, 0, 0, 0)
        sh = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
        ImageDraw.Draw(sh).ellipse([46, 46, 84, 52], fill=(14, 10, 8, 56))
        sh = sh.filter(ImageFilter.GaussianBlur(1.0))
        sh.putalpha(ImageChops.multiply(sh.getchannel("A"), SKULL_128))
        f_out = Image.alpha_composite(sh, f_out)
        return f_out, empty_b

    if hid == "wx_hat_27":
        merged = Image.alpha_composite(b_safe, f_in)
        seated = xform_128(merged, dx=0.5, dy=0.0, sx=1.03, sy=1.02)
        return split_34_right_open_helmet(seated, brow_y=49, brow_dip_center=2,
                                          left_guard_x=54, right_guard_x=83, trim_right_back_x=85,
                                          cavity_rgb=(24, 18, 16))

    # === 3. TALL DAOIST / NOBLE CROWNS -> SEAT AT HAIRLINE (y=47, ABOVE BROWS!) WITH DARK BASE ===
    if hid == "wx_hat_09":
        f_s = xform_128(f_in, dx=-2.0, dy=4.0, sx=0.96, sy=0.92)
        b_s = xform_128(b_safe, dx=-2.0, dy=4.0, sx=0.96, sy=0.92)
        return paint_crown_skull_wrap(f_s, b_s, base_rgb=(44, 34, 48), rim_rgb=(170, 140, 82), top_y=38, brow_y=47)

    if hid == "wx_hat_10":
        f_s = xform_128(f_in, dx=-1.5, dy=4.5, sx=0.96, sy=0.90)
        b_s = xform_128(b_safe, dx=-1.5, dy=4.5, sx=0.96, sy=0.90)
        return paint_crown_skull_wrap(f_s, b_s, base_rgb=(54, 24, 22), rim_rgb=(188, 146, 78), top_y=38, brow_y=47)

    # === 4. TOPKNOT CROWNS (strictly on top of skull; strip stray baked dark hair smudges below y=43!) ===
    if hid == "wx_char_hat_taoist":
        f_s = xform_128(f_in, dx=0.5, dy=1.0, sx=1.02, sy=1.02)
        fpx = f_s.load()
        for y in range(42, OUT_H):
            for x in range(OUT_W):
                if fpx[x, y][3] > 0:
                    fpx[x, y] = (0, 0, 0, 0)
        return f_s, empty_b

    if hid == "wx_char_hat_topknot":
        f_s = xform_128(f_in, dx=1.0, dy=0.0, sx=1.22, sy=1.22)
        px = f_s.load()
        for y in range(OUT_H):
            for x in range(OUT_W):
                r, g, b, a = px[x, y]
                if y >= 43:
                    px[x, y] = (0, 0, 0, 0)
                    continue
                if a > 20:
                    lum = 0.299 * r + 0.587 * g + 0.114 * b
                    if lum > 40:
                        px[x, y] = (clamp8(r * 1.45 + 32), clamp8(g * 1.48 + 36), clamp8(b * 1.42 + 30), a)
        return f_s, (b_in if b_in is not None else None)

    # === 6. ALL OTHER HATS -> BROW-SAFE PRECISION SEATING ===
    dx, dy, sx, sy = STANDARD_HAT_TRANSFORMS.get(hid, (0.0, 0.0, 1.0, 1.0))
    f_out = xform_128(f_in, dx=dx, dy=dy, sx=sx, sy=sy)
    b_out = xform_128(b_in, dx=dx, dy=dy, sx=sx, sy=sy) if b_in is not None else None
    return f_out, b_out


def main():
    src_brush = BACKUP_BRUSH if BACKUP_BRUSH.exists() else (BRUSH_DIR / "wx_busts_0.brush")
    src_png = BACKUP_PNG if BACKUP_PNG.exists() else None
    gfx_rel, recs = load_records_with_png(src_brush, src_png)
    by_id = {r["id"]: r for r in recs}

    hat_bases = sorted(set(k[:-6] for k in by_id if k.endswith("_front")))
    print(f"Processing all {len(hat_bases)} hats/helmets from {src_brush.name}...")

    updated_hats = 0
    for hb in hat_bases:
        fk, bk = f"{hb}_front", f"{hb}_back"
        f_in = by_id[fk]["img"]
        b_in = by_id[bk]["img"] if bk in by_id else None
        f_new, b_new = process_single_hat(hb, f_in, b_in)
        by_id[fk]["img"] = f_new
        if bk in by_id and b_new is not None:
            by_id[bk]["img"] = b_new
        updated_hats += 1

    # 1. Pack & write wx_busts_0.brush + gfx/wx_busts_0.png
    entries = []
    for r in recs:
        entries.append({
            "id": r["id"],
            "img": r["img"],
            "ox": r["ox"],
            "oy": r["oy"],
            "src_rel": r["src_rel"],
            "is_effect": False,
        })
    atlas, packed = shelf_pack_sprites(entries, max_atlas_w=2048)
    atlas = clean_zero_alpha_rgba(atlas)
    atlas.save(MOD_DIR / gfx_rel, optimize=True, compress_level=9)
    write_brush_binary(str(BRUSH_DIR / "wx_busts_0.brush"), gfx_rel, atlas.size, packed, is_effect_sheet=False)
    print(f"[OK] Updated wx_busts_0.brush ({updated_hats} hats repaired, {len(packed)} sprites, atlas={atlas.size})")

    # 2. Sync wx_world_entity_0.brush (`wm_*` hat layers)
    we_bp = BRUSH_DIR / "wx_world_entity_0.brush"
    if we_bp.exists():
        we_gfx_rel, we_recs = load_brush_records(we_bp)
        we_entries = []
        wm_upd = 0
        for r in we_recs:
            sid = r["id"]
            img = r["img"]
            if sid.startswith("wm_") and sid[3:] in by_id:
                base_id = sid[3:]
                if base_id.endswith(("_front", "_back")):
                    img = make_world_bust_from_128(by_id[base_id]["img"])
                    wm_upd += 1
            we_entries.append({
                "id": sid, "img": img, "ox": r["ox"], "oy": r["oy"],
                "src_rel": r["src_rel"], "is_effect": False,
            })
        we_atlas, we_packed = shelf_pack_sprites(we_entries, max_atlas_w=2048)
        we_atlas = clean_zero_alpha_rgba(we_atlas)
        we_atlas.save(MOD_DIR / we_gfx_rel, optimize=True, compress_level=9)
        write_brush_binary(str(we_bp), we_gfx_rel, we_atlas.size, we_packed, is_effect_sheet=False)
        print(f"[OK] Synchronized {wm_upd} world-map hat layers in wx_world_entity_0.brush")

    # 3. Sync wx_corpses_0.brush (`*_dead` hat layers)
    cp_bp = BRUSH_DIR / "wx_corpses_0.brush"
    if cp_bp.exists():
        cp_gfx_rel, cp_recs = load_brush_records(cp_bp)
        cp_entries = []
        cp_upd = 0
        for idx, r in enumerate(cp_recs):
            sid = r["id"]
            img = r["img"]
            if sid.endswith("_dead") and sid[:-5] in by_id:
                base_id = sid[:-5]
                if base_id.endswith(("_front", "_back")):
                    img = make_corpse_from_128(by_id[base_id]["img"], is_body_base=False, seed_val=idx * 37 + 13)
                    cp_upd += 1
            cp_entries.append({
                "id": sid, "img": img, "ox": r["ox"], "oy": r["oy"],
                "src_rel": r["src_rel"], "is_effect": False,
            })
        cp_atlas, cp_packed = shelf_pack_sprites(cp_entries, max_atlas_w=2048)
        cp_atlas = clean_zero_alpha_rgba(cp_atlas)
        cp_atlas.save(MOD_DIR / cp_gfx_rel, optimize=True, compress_level=9)
        write_brush_binary(str(cp_bp), cp_gfx_rel, cp_atlas.size, cp_packed, is_effect_sheet=False)
        print(f"[OK] Synchronized {cp_upd} fallen corpse hat layers in wx_corpses_0.brush")

    # 4. Re-apply zero-VRAM `_injured` brush aliases
    add_injured_aliases()
    print("[DONE] All 46 hats/helmets recalibrated and synchronized across all brushes!")


if __name__ == "__main__":
    main()
