#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Unified Battle Brothers Wuxia Paperdoll Overhaul Pipeline (`tools/overhaul_wuxia_paperdoll.py`):
Rebuilds `mod_wuxia/brushes/wx_busts_0.brush` (+ `gfx/wx_busts_0.png`) cleanly from the un-distorted
pre-v0.8.8 `104x142` master sprites (`dist/mod_wuxia-0.8.7.zip`), then synchronizes:
  - `wx_world_entity_0.brush` (`wm_*` modular world-map player-lead bust layers)
  - `wx_corpses_0.brush` (`*_dead` modular tactical corpse decals)
  - Zero-VRAM `_injured` brush aliases across all bust/weapon/beast sheets

Fixes all 5 root causes of visual mismatch between hair, face, hats, and bodies:
  1. Heroic Proportion & Collar-Lock Alignment (eliminating v0.8.8's 1.21x bobblehead & +4px rightward drift):
     - Bodies adaptively widened (`sx=1.14..1.22`, `sy=1.14`, waist-anchored at `worldY=-18`) with per-body
       collar horizontal centering so every torso fills the vanilla pedestal ring solidly.
     - Hollow sleeveless armor armholes (`wx_body_hvy_01`, `wx_body_arm_09/10`, `wx_body_sect_09/11`,
       `wx_armor_xuangui`, etc.) filled with shaded dark woven/leather sleeves & natural collar AO.
     - Head group uniformly scaled to `1.12x` and locked directly onto the collar axis (`head_cx≈65`,
       `chin_y≈85`), with a self-skin-matched shaded neck taper under the jawline.
  2. Overhype Gouache Skin Unification (48 Heads):
     - Tames overexposed chalk-white/porcelain faces (`wx_head_22, 24, 33, 34, 37, 43, 45, 46`, etc.)
       into warm sunlit parchment-ivory/ochre tones matching Battle Brothers' gritty dark palette.
     - Corrects unnatural green/corpse-grey casts (`wx_head_07, 14, 16, 41, 47`).
     - Adds 3/4-right chiaroscuro sculpting, micro-contrast, subtle forehead-height normalization on
       tall-dome faces, and unified 1px warm-ink contour lines.
  3. Natural Hair & Under-Hat Tucked Hair Reconstruction (24 Hairs × 4 Tones × Full/Tucked):
     - Strips stray white fringe specks (`wx_hair_01`, `03`, `07`, `09`).
     - Repairs broken hairstyles (`wx_hair_10` bald temple gap + lush shoulder-framing back hair;
       `wx_hair_04` clean iron monk headband + side/back hair; `wx_hair_13` seamless skull-hugging
       buzzed stubble; `wx_hair_12`/`20`/`23` graceful framing side-locks & nape volume).
     - Replaces harsh black cookie-cutter hairline strokes with softer feathered hairlines + subtle
       forehead cast shadows & behind-ear nape framing.
     - Redesigns `wx_hair_*_tucked` from a boxy temple chop into a curved skull-hugging under-brim cap
       that hides bald forehead strips without poking through hat crowns.
  4. Hat / Helmet Sculpting & Seating (46 Hats/Helmets):
     - Repairs `wx_hat_25` (removes solid black forehead brick & floating ear-curtains, moving rear
       neck-guard behind the head into `hat_back` and seating the iron brim cleanly above the brows).
     - Seats floating conical/bamboo hats (`wx_char_hat_bamboo`, `wx_hat_03`, `wx_hat_07`) and crowns
       (`wx_char_hat_taoist`, `wx_char_hat_topknot`, `wx_hat_14`) snugly onto the brow/topknot with
       natural cast brim shadows.
  5. Multi-Tone Regeneration & Visual QA Contact Sheets:
     - Regenerates `_brown`, `_grey`, `_white` variants cleanly from the overhauled black hairs & beards.
"""

import io
import math
import os
import random
import struct
import sys
import zipfile
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))

from compile_wuxia_brushes import (
    BRUSH_MAGIC,
    make_fallen_corpse_layer,
    make_world_bust_layer,
    shelf_pack_sprites,
    write_brush_binary,
)
from fix_v088_visuals_and_brushes import clean_zero_alpha_rgba, load_brush_records
from add_injured_brush_aliases import main as add_injured_aliases

MOD_DIR = ROOT / "mod_wuxia"
BRUSH_DIR = MOD_DIR / "brushes"
SRC_087_ZIP = ROOT / "dist" / "mod_wuxia-0.8.7.zip"

# Canonical 128x164 (ox=0, oy=35) Battle Brothers paperdoll coordinate system:
#   worldX = x - 64.0
#   worldY = (164/2 + 35) - y = 117.0 - y
OUT_W, OUT_H = 128, 164
OX, OY = 0, 35

# Body & Head coupled geometric transforms (from 0.8.7's 104x142 oy=35 space):
#   In 0.8.7: waist bottom is y=124 (worldY=-18), neck/chin seat is y=79 (worldY=+27)
#   Body sy=1.14 around pivot_wy=-18 moves neck seat to worldY = -18 + 45*1.14 = +33.3 (y=83.7)
#   Head s=1.12 anchored at neck (pivot_wy=27) shifted to worldY=+31.8 (y=85.2, tucked 1.5px into collar!)
BODY_SY = 1.14
HEAD_SCALE = 1.12
HEAD_PIVOT_WX = 1.5
HEAD_PIVOT_WY = 27.0
HEAD_SHIFT_WX = -0.7   # Moves head_cx from ~68.0 (v0.8.8) -> ~64.8 (locked onto collar center!)
HEAD_SHIFT_WY = 4.8    # Moves chin worldY from 27.0 -> 31.8 (y=85.2 on 128x164, seated snugly in collar!)


# ==============================================================================
# 1. LOAD UN-DISTORTED 0.8.7 104x142 MASTER SPRITES
# ==============================================================================
def load_087_bust_records():
    with zipfile.ZipFile(SRC_087_ZIP) as zf:
        data = zf.read("brushes/wx_busts_0.brush")
        atlas = Image.open(io.BytesIO(zf.read("gfx/wx_busts_0.png"))).convert("RGBA")
    magic, ver, gl = struct.unpack_from("<IHH", data, 0)
    assert magic == BRUSH_MAGIC
    gfx_rel = data[8 : 8 + gl].decode("ascii").replace("\\", "/")
    pos = 8 + gl
    aw, ah = struct.unpack_from("<HH", data, pos)
    pos += 16
    cnt, _, _ = struct.unpack_from("<IHI", data, pos)
    pos += 10

    recs = []
    by_id = {}
    for _ in range(cnt):
        _, sl = struct.unpack_from("<QH", data, pos)
        pos += 10
        sid = data[pos : pos + sl].decode("ascii")
        pos += sl
        _, w, h, ox, oy = struct.unpack_from("<QIIhh", data, pos)
        pos += 53
        fc, srcl = struct.unpack_from("<HH", data, pos)
        pos += 4
        src_rel = data[pos : pos + srcl].decode("ascii")
        pos += srcl
        u0, u1, v0, v1, fL, fR, fT, fB = struct.unpack_from("<8f", data, pos)
        pos += 35
        if sid.endswith("_injured"):
            continue
        ax0, ax1 = int(round(u0 * aw)), int(round(u1 * aw))
        ay0, ay1 = int(round(v0 * ah)), int(round(v1 * ah))
        crop = ImageOps.flip(atlas.crop((ax0, ay0, ax1, ay1)))
        canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        bx0 = max(0, int(round(w / 2.0 + fL)))
        by0 = max(0, int(round(h / 2.0 - fB)))
        canvas.paste(crop, (bx0, by0))
        rec = {"id": sid, "w": w, "h": h, "ox": ox, "oy": oy, "src_rel": src_rel, "img": canvas}
        recs.append(rec)
        by_id[sid] = rec
    return gfx_rel, recs, by_id


def transform_aniso(
    src: Image.Image,
    sx: float,
    sy: float,
    pivot_wx: float,
    pivot_wy: float,
    shift_wx: float = 0.0,
    shift_wy: float = 0.0,
    out_w: int = OUT_W,
    out_h: int = OUT_H,
    oy: int = OY,
) -> Image.Image:
    """High-precision subpixel affine scaling/translation from 104x142 (oy=35) -> 128x164 (oy=35)."""
    ow, oh = src.size
    px_old = pivot_wx + ow / 2.0
    py_old = oh / 2.0 + oy - pivot_wy

    px_new = (pivot_wx + shift_wx) + out_w / 2.0
    py_new = out_h / 2.0 + oy - (pivot_wy + shift_wy)

    # Inverse affine matrix: src_x = a*dst_x + b*dst_y + c
    a = 1.0 / sx
    c = px_old - px_new / sx
    e = 1.0 / sy
    f = py_old - py_new / sy

    return src.transform(
        (out_w, out_h),
        Image.Transform.AFFINE,
        (a, 0.0, c, 0.0, e, f),
        resample=Image.Resampling.BICUBIC,
    )


def shift_img(im: Image.Image, dx: float, dy: float) -> Image.Image:
    if abs(dx) < 1e-4 and abs(dy) < 1e-4:
        return im
    return im.transform(
        im.size,
        Image.Transform.AFFINE,
        (1.0, 0.0, -dx, 0.0, 1.0, -dy),
        resample=Image.Resampling.BICUBIC,
    )


def clamp8(v: float) -> int:
    return 0 if v < 0 else (255 if v > 255 else int(round(v)))


# ==============================================================================
# 2. MASTER SKULL & PEDESTAL MASKS ON 128x164 CANVAS
# ==============================================================================
def build_128_masks():
    """
    Canonical 128x164 anatomical guides aligned to `HEAD_SCALE=1.12, HEAD_SHIFT=(-0.7, +4.8)`:
      - Opaque head sits at x=[44..86] (cx=65.0), y=[39..86] (eyes at y≈59..60, brow at y≈55..56)
      - Pedestal waist sits at y=135..136, torso shoulders x=[14..114] (cx=64.0)
    """
    # Pedestal clipping mask matching vanilla bust_base_player inner bowl
    ped_clip = Image.new("L", (OUT_W, OUT_H), 0)
    pd = ImageDraw.Draw(ped_clip)
    pd.rectangle([0, 0, OUT_W, 114], fill=255)
    pd.ellipse([10, 76, 118, 137], fill=255)
    ped_clip = ped_clip.filter(ImageFilter.GaussianBlur(0.8))

    # Master Head Opaque Silhouette (used for skull-hugging hair/tucked-hair synthesis)
    skull = Image.new("L", (OUT_W, OUT_H), 0)
    sd = ImageDraw.Draw(skull)
    sd.ellipse([44, 40, 86, 77], fill=255)
    sd.polygon([(46, 58), (85, 56), (84, 74), (76, 85), (63, 86), (51, 79)], fill=255)
    skull = skull.filter(ImageFilter.GaussianBlur(0.6))

    # Exposed Face + Ear window (lower hairline & gentler brow curve than old v4 polygon!)
    face_open = Image.new("L", (OUT_W, OUT_H), 0)
    fd = ImageDraw.Draw(face_open)
    fd.polygon([
        (59, 51),  # left forehead hairline corner (lowered ~2px vs old high receding forehead!)
        (72, 49),  # central forehead arch
        (85, 52),  # right temple brow corner
        (89, 64),
        (86, 77),
        (76, 88),
        (60, 88),
        (54, 78),
        (52, 70),  # below ear
        (48, 70),  # lower ear lobe
        (46, 66),  # back ear rim
        (47, 60),  # top ear rim
        (51, 59),  # upper ear root
        (54, 63),  # subtle pointed sideburn tip
        (57, 60),
        (57, 53),
    ], fill=255)
    face_open = face_open.filter(ImageFilter.GaussianBlur(0.8))

    return ped_clip, skull, face_open


PED_CLIP_128, SKULL_128, FACE_OPEN_128 = build_128_masks()


# ==============================================================================
# 3. BODY / TORSO OVERHAUL (HEROIC SHOULDERS + HOLLOW ARMHOLE FILL + COLLAR AO)
# ==============================================================================
HOLLOW_ARMHOLE_BODIES = {
    "wx_body_hvy_01": (48, 42, 38),      # Dark chainmail/iron-grey quilted sleeve
    "wx_body_arm_09": (40, 50, 54),      # Dark blue-slate under-tunic sleeve
    "wx_body_arm_10": (54, 48, 34),      # Dark bronze-olive quilted sleeve
    "wx_body_sect_09": (56, 36, 36),     # Dark crimson-charcoal leather sleeve
    "wx_body_sect_11": (42, 52, 40),     # Dark pine-green cloth sleeve
    "wx_armor_xuangui": (54, 46, 36),    # Dark bronze-brown gambeson sleeve
    "wx_body_arm_02": (56, 45, 34),      # Warm dark-brown boiled leather sleeve
    "wx_body_arm_03": (60, 49, 36),      # Steppe rawhide dark-tan sleeve
    "wx_body_civ_01": (70, 56, 42),      # Coarse hemp-brown peasant sleeve
    "wx_body_civ_08": (62, 54, 46),      # Weathered grey-brown porter sleeve
    "wx_body_civ_10": (56, 46, 36),      # Dark wool-brown winter sleeve
    "wx_body_sect_14": (64, 36, 32),     # Deep russet monk-robe sleeve
    "wx_armor_bifang": (52, 40, 36),     # Dark lacquer under-sleeve
    "wx_char_robe_beggar": (60, 52, 42), # Patched earthy sackcloth sleeve
}


def fill_hollow_armhole(im: Image.Image, sleeve_rgb) -> Image.Image:
    """
    Replaces pitch-black empty mannequin armholes on sleeveless cuirasses (`x=[14..46], y=[78..126]`)
    with a painterly shaded dark cloth/gambeson sleeve (warm highlights, cloth folds, subtle grain)
    so armor looks worn by a solid body rather than an empty hollow shell!
    """
    out = im.copy()
    px = out.load()
    w, h = out.size
    sr, sg, sb = sleeve_rgb

    # Detect contiguous dark pixels inside the left armhole region (and small dark armpit pockets on right)
    # Keep thin 1..2px structural outlines intact by requiring >=4 dark neighbors in a 5x5 window!
    is_dark = [[False] * w for _ in range(h)]
    for y in range(74, 130):
        for x in range(12, 52):
            r, g, b, a = px[x, y]
            if a > 180 and (r + g + b) < 54 and max(r, g, b) < 26:
                is_dark[y][x] = True

    # Erode dark mask by 1px so outer crisp 1-2px armor rim outlines stay 100% dark ink!
    fill_mask = [[False] * w for _ in range(h)]
    for y in range(76, 128):
        for x in range(14, 50):
            if not is_dark[y][x]:
                continue
            nb = 0
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    if is_dark[y + dy][x + dx]:
                        nb += 1
            if nb >= 7:
                fill_mask[y][x] = True

    # Find centroid of the armhole cavity to orient cylindrical arm shading
    pts = [(x, y) for y in range(76, 128) for x in range(14, 50) if fill_mask[y][x]]
    if len(pts) < 35:
        return out

    cx = sum(p[0] for p in pts) / float(len(pts))
    cy = sum(p[1] for p in pts) / float(len(pts))
    min_x = min(p[0] for p in pts)
    max_x = max(p[0] for p in pts)
    min_y = min(p[1] for p in pts)
    max_y = max(p[1] for p in pts)
    rx = max(6.0, (max_x - min_x) * 0.55)
    ry = max(8.0, (max_y - min_y) * 0.55)

    for (x, y) in pts:
        # Distance to boundary of fill_mask for realistic rim ambient occlusion under the armor edge
        edge_d = 3
        for rad in (1, 2):
            if not (fill_mask[y - rad][x] and fill_mask[y + rad][x] and fill_mask[y][x - rad] and fill_mask[y][x + rad]):
                edge_d = rad
                break
        ao = 0.45 if edge_d == 1 else (0.76 if edge_d == 2 else 1.0)
        # Cylindrical upper-arm shading (lit slightly on upper-front, darker toward back/bottom)
        nx = (x - cx) / rx
        ny = (y - cy) / ry
        cyl = max(0.32, 1.08 - 0.36 * (nx * nx) - 0.25 * max(0.0, ny) + 0.16 * max(0.0, -ny))
        # Subtle woven-cloth fold stripes
        fold = 1.0 + 0.09 * math.sin((x * 0.55) + (y * 0.35))
        # Waist fade matching bust pedestal shadow
        waist_sh = max(0.40, 1.0 - max(0, y - 114) / 28.0)
        f = ao * cyl * fold * waist_sh
        _, _, _, a0 = px[x, y]
        px[x, y] = (clamp8(sr * f), clamp8(sg * f), clamp8(sb * f), a0)

    return out


def apply_collar_pit_ao(im: Image.Image) -> Image.Image:
    """
    Softly shades the exposed upper neck-pit interior (`x=[52..76], y=[70..89]`) on bodies
    so the old hardcoded bright-tan neck rectangle blends into natural warm-umber collar AO,
    letting every head's own skin-matched shaded neck integrate cleanly!
    """
    out = im.copy()
    px = out.load()
    w, h = out.size
    for y in range(68, 92):
        for x in range(50, 78):
            r, g, b, a = px[x, y]
            if a < 40:
                continue
            # Elliptical collar-pit zone centered right under the chin (`cx=64.5, cy=81`)
            dx = (x - 64.5) / 13.5
            dy = (y - 80.5) / 9.5
            d2 = dx * dx + dy * dy
            if d2 < 1.0:
                # Only darken flesh-colored neck pixels (R > G > B and mid-bright), leaving metal/cloth rims intact!
                lum = 0.299 * r + 0.587 * g + 0.114 * b
                is_flesh = (r > g + 8 and g > b + 4 and 48 < lum < 165)
                if is_flesh:
                    strength = (1.0 - d2) * 0.42
                    f = 1.0 - strength
                    px[x, y] = (clamp8(r * f), clamp8(g * f * 0.96), clamp8(b * f * 0.92), a)
    return out


def overhaul_body(raw_104: Image.Image, sid: str) -> Image.Image:
    """
    Normalizes a body/armor/robe sprite from 104x142 -> 128x164 with heroic BB shoulder width,
    aligned collar center X, filled hollow armholes, and grounded waist shading.
    """
    px = raw_104.load()
    sh_xs = [x for y in range(84, 108) for x in range(104) if px[x, y][3] > 180]
    col_xs = [x for y in range(68, 79) for x in range(104) if px[x, y][3] > 180]
    sh_w = (max(sh_xs) - min(sh_xs) + 1) if sh_xs else 82
    sh_cx = (max(sh_xs) + min(sh_xs)) / 2.0 if sh_xs else 52.0
    col_cx = (max(col_xs) + min(col_xs)) / 2.0 if col_xs else sh_cx

    # Adaptive heroic shoulder breadth: widen scrawny robes (76..81px) without bloating wide heavy plates!
    if sh_w <= 79:
        sx = 1.22
    elif sh_w <= 82:
        sx = 1.19
    elif sh_w <= 85:
        sx = 1.16
    else:
        sx = 1.13

    # Gently center collar horizontally around canonical x=52.5 (in 0.8.7) -> x=64.5 (in 128x164)
    shift_wx = max(-3.2, min(3.2, (52.5 - col_cx) * 0.65))

    out = transform_aniso(
        raw_104,
        sx=sx,
        sy=BODY_SY,
        pivot_wx=0.0,
        pivot_wy=-18.0,
        shift_wx=shift_wx,
        shift_wy=-0.5,
    )

    if sid in HOLLOW_ARMHOLE_BODIES:
        out = fill_hollow_armhole(out, HOLLOW_ARMHOLE_BODIES[sid])

    out = apply_collar_pit_ao(out)
    # Smooth pedestal clip at bottom so widened shoulders tuck cleanly inside vanilla metallic rim
    a = ImageChops.multiply(out.getchannel("A"), PED_CLIP_128)
    out.putalpha(a)
    return out


# ==============================================================================
# 4. HEAD OVERHAUL (OVERHYPE GOUACHE SKIN + FOREHEAD NORM + SELF-SKIN NECK)
# ==============================================================================
def sample_head_skin_tone(im: Image.Image):
    """Returns median (r, g, b) of cheek/jaw skin pixels in the head."""
    px = im.load()
    rs, gs, bs = [], [], []
    for y in range(54, 80):
        for x in range(52, 82):
            r, g, b, a = px[x, y]
            if a > 220:
                lum = 0.299 * r + 0.587 * g + 0.114 * b
                if 50 < lum < 215 and r >= g - 4:
                    rs.append(r); gs.append(g); bs.append(b)
    if not rs:
        return (152, 114, 86)
    rs.sort(); gs.sort(); bs.sort()
    m = len(rs) // 2
    return (rs[m], gs[m], bs[m])


def detect_eye_y_104(im: Image.Image) -> int:
    px = im.load()
    best = (9999.0, 57)
    for y in range(48, 64):
        vals = [0.299 * px[x, y][0] + 0.587 * px[x, y][1] + 0.114 * px[x, y][2]
                for x in range(50, 71) if px[x, y][3] > 200]
        if vals:
            dcnt = sum(1 for v in vals if v < 75)
            sc = sum(vals) / len(vals) - dcnt * 3.0
            if sc < best[0]:
                best = (sc, y)
    return best[1]


def normalize_tall_forehead_104(im: Image.Image, eye_y: int) -> Image.Image:
    """
    On faces whose eyes sit low (`eye_y >= 58`, i.e. 20-21px tall bald dome above eyes),
    subtly compress ONLY the bald upper dome above `brow_y = eye_y - 4` by 1.5..2.5px
    so hairlines sit naturally and every face shares identical cranial proportions!
    """
    if eye_y < 58:
        return im
    shift_down = min(2.5, (eye_y - 56.5) * 0.85)
    # Smooth vertical warp of upper half: pull skull top down by `shift_down` while keeping brow..chin locked!
    w, h = im.size
    brow_y = float(eye_y - 4)
    top_y = 37.0
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    # Copy lower face (brow down) untouched
    cut = int(brow_y)
    out.paste(im.crop((0, cut, w, h)), (0, cut))
    # Compress upper dome [0..cut] slightly downward into [int(round(shift_down))..cut]
    src_top = im.crop((0, 0, w, cut))
    new_h = max(1, cut - int(round(shift_down)))
    comp_top = src_top.resize((w, new_h), Image.Resampling.BICUBIC)
    # Wait: resize from y=0 shifts everything; better: crop [34..cut] (just skull top to brow) and fit into [34+d..cut]
    y0 = 33
    band = im.crop((0, y0, w, cut))
    d_px = int(round(shift_down))
    band_new_h = max(4, (cut - y0) - d_px)
    band_rs = band.resize((w, band_new_h), Image.Resampling.BICUBIC)
    out.paste(band_rs, (0, cut - band_new_h))
    return out


def grade_head_battle_brothers(im: Image.Image, face_idx: int) -> Image.Image:
    """
    Harmonizes EVERY head (`wx_head_01..48`) into Battle Brothers' cohesive dark-fantasy Overhype
    gouache painting style:
      - Tames overexposed chalk-white porcelain highlights (`med > 142` or `p90 > 192`) into warm sunlit
        ivory/parchment/ochre flesh (preserving clear feminine fairness on 33..48 without neon glow!)
      - Fixes green/olive/corpse-grey casts (`07, 14, 16, 41, 47`)
      - Applies 3/4-right directional chiaroscuro lighting + warm jaw/back-cheek depth
      - Enhances painterly brushwork contrast on eyes/brows/nose/lips + crisp 1px warm-ink outer rim
    """
    is_fem = (face_idx >= 33)
    out = im.copy()
    px = out.load()
    w, h = out.size

    # Measure current interior face luminance & chroma
    lums, rgs, gbs = [], [], []
    for y in range(44, 84):
        for x in range(48, 84):
            r, g, b, a = px[x, y]
            if a > 215:
                lum = 0.299 * r + 0.587 * g + 0.114 * b
                if lum > 42:
                    lums.append(lum); rgs.append(r - g); gbs.append(g - b)
    if not lums:
        return out
    lums.sort()
    med_l = lums[len(lums) // 2]
    p90_l = lums[int(len(lums) * 0.90)]
    mean_rg = sum(rgs) / len(rgs)
    mean_gb = sum(gbs) / len(gbs)

    # Target luminance ceilings matching Overhype's painted skin range:
    #   - Fair female / young noble faces: med capped ~150..158, highlights capped ~192
    #   - Rugged/standard male faces:      med capped ~138..146, highlights capped ~184
    max_med = 154.0 if is_fem else (146.0 if face_idx in (1, 5, 13, 17, 22, 24, 29) else 140.0)
    max_p90 = 194.0 if is_fem else 186.0

    lum_scale = 1.0
    if med_l > max_med:
        lum_scale = min(lum_scale, (max_med + (med_l - max_med) * 0.16) / med_l)
    if p90_l * lum_scale > max_p90:
        lum_scale = min(lum_scale, max_p90 / p90_l)

    # Extra mild darkening for the glaring top-offender chalk faces
    if face_idx in (22, 24, 33, 37, 43, 45, 46):
        lum_scale = min(lum_scale, 0.84 if is_fem else 0.82)

    # Warmth target: Battle Brothers skin always has rich warm ochre/peach R > G > B
    need_warmth = (mean_rg < 38.0) or (face_idx in (5, 7, 14, 16, 22, 24, 29, 33, 38, 39, 41, 43, 45, 46, 47, 48))
    fix_green = (face_idx in (14, 41, 47)) or (mean_gb > mean_rg + 4.0)

    # Per-pixel color grade + 3/4-right chiaroscuro sculpting
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 16:
                continue
            lum = 0.299 * r + 0.587 * g + 0.114 * b
            if lum < 30:
                # Keep dark ink lines, pupils, eyelashes deep warm charcoal
                px[x, y] = (clamp8(r * 0.94), clamp8(g * 0.90), clamp8(b * 0.86), a)
                continue

            rf, gf, bf = float(r), float(g), float(b)

            # 1. Green/olive cast repair (preserve green irises on wx_head_41 around eye rows y=56..63, x=60..80!)
            is_eye_iris = (face_idx == 41 and 56 <= y <= 63 and 58 <= x <= 82 and g > r + 4)
            if fix_green and not is_eye_iris:
                if gf >= rf - 36 and gf > bf + 6:
                    # Shift olive/sallow tint toward warm earthy skin
                    blend = 0.72 if face_idx == 47 else (0.52 if face_idx == 14 else 0.48)
                    tr = lum * 1.19 + 9.0
                    tg = lum * 0.93 + 0.5
                    tb = lum * 0.72
                    rf = rf * (1.0 - blend) + tr * blend
                    gf = gf * (1.0 - blend) + tg * blend
                    bf = bf * (1.0 - blend) + tb * blend
                if face_idx == 47:
                    rf = min(230.0, rf * 1.04 + 4.0)
                    gf = gf * 0.96

            # 2. Chalk/corpse grey warmth injection (keep crimson forehead mark on wx_head_42 intact!)
            is_red_mark = (rf > gf + 45 and rf > bf + 45)
            if need_warmth and not is_red_mark and not is_eye_iris and lum > 55:
                sat = max(rf, gf, bf) - min(rf, gf, bf)
                if sat < 55 or lum > 155:
                    # Warm golden-parchment skin harmony
                    w_amt = 0.36 if face_idx in (7, 16) else (0.44 if is_fem else 0.40)
                    tr = lum * 1.13 + 8.0
                    tg = lum * 0.96 + 1.0
                    tb = lum * 0.78 - 2.0
                    rf = rf * (1.0 - w_amt) + tr * w_amt
                    gf = gf * (1.0 - w_amt) + tg * w_amt
                    bf = bf * (1.0 - w_amt) + tb * w_amt

            # 3. Tame overexposure + S-curve gouache contrast (deepen shadows slightly, cap glaring whites)
            eff_lum_scale = lum_scale * (0.90 if face_idx in (7, 14, 16) and y < 56 else 1.0)
            rf *= eff_lum_scale
            gf *= eff_lum_scale
            bf *= eff_lum_scale

            # Subtle S-curve around midtone 120 for richer Battle Brothers facial volume
            cur_l = 0.299 * rf + 0.587 * gf + 0.114 * bf
            if cur_l > 165.0:
                # Soft highlight rolloff (never blow out to neon 240+)
                excess = cur_l - 165.0
                target_l = 165.0 + excess * 0.55
                sc = target_l / max(1.0, cur_l)
                rf *= sc; gf *= sc; bf *= sc
            elif 42.0 < cur_l < 110.0:
                # Slightly richer shadow depth on flat low-contrast faces
                sc = 0.93 if face_idx >= 17 else 0.97
                rf *= sc; gf *= sc; bf *= sc

            # 4. 3/4-Right Directional Chiaroscuro (key light from upper-right; rich warm shadow on left temple & under-jaw)
            #    Head sits at x=[44..86], y=[39..86]
            dx_l = max(0.0, (63.0 - x) / 20.0)     # 0 on front face -> 1.0 at back ear/temple
            dy_bot = max(0.0, (y - 68.0) / 18.0)   # 0 above mouth -> 1.0 at bottom chin/jaw
            dy_top = max(0.0, (47.0 - y) / 9.0)    # subtle dome rolloff at very top of skull
            chiaro = 1.0 - 0.16 * (dx_l ** 1.35) - 0.14 * (dy_bot ** 1.4) - 0.08 * (dy_top ** 1.2)
            # Subtle warm blush/life on cheekbones (helps female & pale faces look alive, not plastic)
            rf = rf * chiaro
            gf = gf * (chiaro * (1.0 - 0.025 * dy_bot))
            bf = bf * (chiaro * (1.0 - 0.055 * (dx_l + dy_bot) * 0.5))

            px[x, y] = (clamp8(rf), clamp8(gf), clamp8(bf), a)

    # 5. Painterly micro-contrast sharpening (makes eyes, nose, lips read crisply at game zoom!)
    rgb = out.convert("RGB")
    rgb = rgb.filter(ImageFilter.UnsharpMask(radius=0.85, percent=75 if face_idx >= 17 else 45, threshold=4))
    out = Image.merge("RGBA", (*rgb.split(), out.getchannel("A")))

    # 6. Unified subtle 1px warm-dark ink outer silhouette rim for heads 17..48 (matching BB line art!)
    if face_idx >= 17:
        core_a = out.getchannel("A").point(lambda v: 255 if v > 150 else 0)
        dil = core_a.filter(ImageFilter.MaxFilter(3))
        rim = ImageChops.subtract(dil, core_a).point(lambda v: int(v * 0.58))
        ink = Image.new("RGBA", (w, h), (26, 18, 14, 0))
        ink.putalpha(rim)
        out = Image.alpha_composite(ink, out)

    return out


def add_skin_matched_neck(head_im: Image.Image) -> Image.Image:
    """
    Paints a subtle, anatomically shaded short neck taper strictly BEHIND the jawline (`z < head`)
    sampled from THIS head's OWN graded skin tone (darkened by chin cast shadow `0.56x..0.38x`),
    eliminating the floating-chin gap and mismatched brown neck stump on clean-shaven characters!
    """
    sr, sg, sb = sample_head_skin_tone(head_im)
    neck = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
    npx = neck.load()

    # Tapered anatomical neck cylinder beneath jaw (`x=53..76, y=79..91`), fading out cleanly into collar shadow!
    for y in range(79, 92):
        t_y = (y - 79.0) / 12.0  # 0 at jaw -> 1 at collar merge
        xl = 54.0 - t_y * 1.5
        xr = 76.0 - t_y * 1.0
        for x in range(int(xl) - 1, int(xr) + 2):
            if x < xl - 0.5 or x > xr + 0.5:
                continue
            # Smooth bottom fade so neck never draws OVER high armor breastplates
            bot_fade = 1.0 if y <= 86 else max(0.0, (91.5 - y) / 5.5)
            side_dist = min(x - xl, xr - x)
            if side_dist < 0.8:
                # 1px warm-dark ink outline on neck sides
                a = int(215 * bot_fade)
                npx[x, y] = (24, 17, 13, a)
                continue
            # Deep realistic chin cast shadow directly beneath jaw (`y=79..85`), slightly warm-shaded side-to-side
            nx = (x - (xl + xr) * 0.5) / max(1.0, (xr - xl) * 0.5)
            chin_sh = 0.44 + 0.16 * min(1.0, max(0.0, (y - 82.0) / 6.0))
            side_sh = 0.80 + 0.22 * (nx * 0.5 + 0.5)
            f = chin_sh * side_sh
            a = int(248 * bot_fade)
            npx[x, y] = (clamp8(sr * f), clamp8(sg * f * 0.94), clamp8(sb * f * 0.88), a)

    return Image.alpha_composite(neck, head_im)


def overhaul_head(raw_104: Image.Image, face_idx: int) -> Image.Image:
    eye_y = detect_eye_y_104(raw_104)
    norm_104 = normalize_tall_forehead_104(raw_104, eye_y)
    scaled = transform_aniso(
        norm_104,
        sx=HEAD_SCALE,
        sy=HEAD_SCALE,
        pivot_wx=HEAD_PIVOT_WX,
        pivot_wy=HEAD_PIVOT_WY,
        shift_wx=HEAD_SHIFT_WX,
        shift_wy=HEAD_SHIFT_WY,
    )
    graded = grade_head_battle_brothers(scaled, face_idx)
    return add_skin_matched_neck(graded)


# ==============================================================================
# 5. HAIR OVERHAUL (GAP REPAIR + FRINGE CLEAN + NATURAL HAIRLINE + TUCKED CAP)
# ==============================================================================
def strip_dark_hair_white_specks(im: Image.Image, hair_idx: int) -> Image.Image:
    """
    Removes accidental white matte slivers/halo pixels along outer borders of dark hairstyles
    (e.g. wx_hair_01's infamous white ear sliver, wx_hair_03/07/09 fringe specks) while preserving
    intentional pale ornaments (jade crown on 09, bone pin on 05, silver/white hair on 03/18/19).
    """
    if hair_idx in (3, 18, 19):
        return im
    out = im.copy()
    px = out.load()
    w, h = out.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            # Keep jade crown / hairpins strictly in upper crown zone y < 44 for 05/09/14/23
            if hair_idx in (5, 9, 14, 23) and y < 44:
                continue
            mn, mx = min(r, g, b), max(r, g, b)
            lum = 0.299 * r + 0.587 * g + 0.114 * b
            # Stray white/pale-grey fringe specks on lower/side edges of dark hair (y >= 46 or low alpha)
            if y >= 46 and mn >= 104 and (mx - mn) <= 32:
                px[x, y] = (28, 24, 21, int(a * 0.65)) if lum < 195 else (0, 0, 0, 0)
            elif a < 175 and lum > 110 and (mx - mn) <= 24:
                px[x, y] = (24, 20, 18, int(a * 0.45))
    return out


def sample_hair_base_rgb(im: Image.Image, hair_idx: int):
    if hair_idx == 19:
        return (198, 194, 186)
    if hair_idx == 18:
        return (138, 134, 128)
    if hair_idx == 3:
        return (104, 100, 96)
    px = im.load()
    rs, gs, bs = [], [], []
    for y in range(30, 68):
        for x in range(36, 88):
            r, g, b, a = px[x, y]
            if a > 200:
                lum = 0.299 * r + 0.587 * g + 0.114 * b
                if 24 < lum < 120:
                    rs.append(r); gs.append(g); bs.append(b)
    if not rs:
        return (38, 32, 28)
    rs.sort(); gs.sort(); bs.sort()
    m = len(rs) // 2
    return (rs[m], gs[m], bs[m])


def paint_hair_strand_region(canvas: Image.Image, mask: Image.Image, base_rgb, seed_val: int, highlight_rgb=None, strand_angle: float = 0.35):
    """
    Paints rich Battle Brothers textured hair strands into `mask` (preserving crisp dark outlines
    and painterly directional strand highlights) and composites onto `canvas`.
    """
    w, h = canvas.size
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    lpx = layer.load()
    mpx = mask.load()
    br, bg, bb = base_rgb
    hr, hg, hb = highlight_rgb if highlight_rgb else (min(235, int(br * 1.45 + 18)), min(230, int(bg * 1.42 + 16)), min(220, int(bb * 1.38 + 14)))

    # Dilate mask slightly to get crisp 1px dark outer outline
    core = mask.point(lambda v: 255 if v > 115 else 0)
    dil = core.filter(ImageFilter.MaxFilter(3))
    rim = ImageChops.subtract(dil, core)
    rpx = rim.load()

    for y in range(h):
        for x in range(w):
            ma = mpx[x, y]
            if ma > 12:
                # Directional hair-strand texture
                u = x * math.cos(strand_angle) + y * math.sin(strand_angle)
                v = -x * math.sin(strand_angle) + y * math.cos(strand_angle)
                wave = 0.5 + 0.5 * math.sin(u * 1.85 + math.sin(v * 0.22 + seed_val) * 1.6)
                # Vertical crown-to-nape shading (brighter near temple/crown, richer darker shadow at nape)
                v_sh = max(0.55, 1.05 - max(0, y - 54) / 55.0)
                t = (wave ** 1.6) * 0.45 * v_sh
                r = (br * (1.0 - t) + hr * t) * v_sh
                g = (bg * (1.0 - t) + hg * t) * v_sh
                b = (bb * (1.0 - t) + hb * t) * v_sh
                lpx[x, y] = (clamp8(r), clamp8(g), clamp8(b), ma)
            elif rpx[x, y] > 90:
                lpx[x, y] = (18, 15, 13, min(225, rpx[x, y]))

    return Image.alpha_composite(layer, canvas)


def paint_hair_overlay_strands(canvas: Image.Image, mask: Image.Image, base_rgb, seed_val: int, strand_angle: float = 0.2):
    """Paints textured hair strands ON TOP OF `canvas` (for framing temple wisps / flowing locks)."""
    w, h = canvas.size
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    lpx = layer.load()
    mpx = mask.load()
    br, bg, bb = base_rgb
    hr, hg, hb = min(230, int(br * 1.40 + 14)), min(225, int(bg * 1.38 + 12)), min(215, int(bb * 1.34 + 10))
    for y in range(h):
        for x in range(w):
            ma = mpx[x, y]
            if ma > 12:
                u = x * math.cos(strand_angle) + y * math.sin(strand_angle)
                v = -x * math.sin(strand_angle) + y * math.cos(strand_angle)
                wave = 0.5 + 0.5 * math.sin(u * 2.1 + math.sin(v * 0.25 + seed_val) * 1.4)
                t = (wave ** 1.5) * 0.38
                r = br * (1.0 - t) + hr * t
                g = bg * (1.0 - t) + hg * t
                b = bb * (1.0 - t) + hb * t
                lpx[x, y] = (clamp8(r), clamp8(g), clamp8(b), ma)
    return Image.alpha_composite(canvas, layer)


def soften_hairline_and_add_brow_shadow(im: Image.Image) -> Image.Image:
    """
    Softens the harsh thick black cookie-cutter cut edge along the forehead (`y=46..56, x=56..86`)
    and bakes a subtle warm-dark cast shadow 1-2px below the hairline onto the forehead!
    """
    out = im.copy()
    px = out.load()
    w, h = out.size

    # Soften overly harsh pure-black hairline pixels along the lower forehead cut edge
    snap = out.copy()
    spx = snap.load()
    for y in range(46, 58):
        for x in range(56, 86):
            r, g, b, a = spx[x, y]
            if a > 120 and spx[x, y + 1][3] < 45 and spx[x, y + 2][3] < 20:
                # Bottom-most hairline rim pixel: soften alpha slightly so it blends organically onto skin
                px[x, y] = (r, g, b, int(a * 0.78))

    # Add delicate warm forehead shadow strictly 1-2px below hair over the upper face zone
    sh = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    sh_a = out.getchannel("A").point(lambda v: int(v * 0.34))
    sh.paste((18, 12, 8, 255), (0, 2), sh_a)
    sh = sh.filter(ImageFilter.GaussianBlur(1.1))
    # Confine hairline cast shadow strictly inside skull silhouette
    sh.putalpha(ImageChops.multiply(sh.getchannel("A"), SKULL_128))
    return Image.alpha_composite(sh, out)


def overhaul_hair(raw_104: Image.Image, hair_idx: int):
    """
    Transforms, repairs, and enriches each base hairstyle (`wx_hair_01..24`), and generates
    a clean curved skull-hugging `wx_hair_XX_tucked` version (replacing the old boxy temple chop!).
    """
    # Scale with unified head transform + nudge down 1.0px so hair hugs the forehead lower & snugger!
    im = transform_aniso(
        raw_104,
        sx=HEAD_SCALE,
        sy=HEAD_SCALE,
        pivot_wx=HEAD_PIVOT_WX,
        pivot_wy=HEAD_PIVOT_WY,
        shift_wx=HEAD_SHIFT_WX,
        shift_wy=HEAD_SHIFT_WY - 1.0,
    )
    im = strip_dark_hair_white_specks(im, hair_idx)
    base_rgb = sample_hair_base_rgb(im, hair_idx)

    # --- SPECIALIZED REPAIRS FOR BROKEN / THIN HAIRSTYLES ---
    if hair_idx == 4:
        # `wx_hair_04` (头陀铁箍落发式): rebuild broken floating wire into solid bronze-iron headband + gritty short back/side hair!
        rebuilt = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
        # Short dark rough hair behind ear & lower temple (below headband)
        back_m = Image.new("L", (OUT_W, OUT_H), 0)
        bd = ImageDraw.Draw(back_m)
        bd.polygon([(40, 56), (51, 56), (52, 62), (48, 70), (50, 77), (43, 81), (37, 74), (37, 63)], fill=235)
        back_m = back_m.filter(ImageFilter.GaussianBlur(0.8))
        rebuilt = paint_hair_strand_region(rebuilt, back_m, (38, 32, 28), seed_val=41, strand_angle=0.5)
        # Solid hammered dark-iron monk circlet wrapping cleanly around brow (`y=48..53`)
        dr = ImageDraw.Draw(rebuilt)
        pts_band = [(45, 55), (53, 51), (66, 48), (78, 49), (84, 52)]
        dr.line(pts_band, fill=(18, 15, 13, 255), width=5)
        dr.line(pts_band, fill=(72, 66, 58, 255), width=3)
        dr.line([(54, 50), (66, 48), (77, 49)], fill=(128, 118, 102, 235), width=1)
        # Small clasp rivet on temple
        dr.ellipse([54, 49, 59, 53], fill=(142, 126, 94, 255), outline=(22, 18, 14, 255))
        im = rebuilt

    elif hair_idx == 13:
        # `wx_hair_13` (青皮短茬沙门戒发): rebuild detached tan cap into seamless skull-hugging dark ash-blue monk buzzcut!
        stubble = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
        sm = Image.new("L", (OUT_W, OUT_H), 0)
        sd = ImageDraw.Draw(sm)
        sd.ellipse([44, 40, 85, 74], fill=225)
        # Strictly intersect with SKULL_128 and subtract face + ear cleanly -> zero outer fuzz beyond head rim!
        sm = ImageChops.multiply(sm, SKULL_128)
        sm = ImageChops.multiply(sm, ImageOps.invert(FACE_OPEN_128))
        sm = sm.filter(ImageFilter.GaussianBlur(0.6))
        rng = random.Random(1301)
        spx = stubble.load()
        mpx = sm.load()
        for y in range(38, 80):
            for x in range(42, 87):
                a = mpx[x, y]
                if a > 16:
                    dx_l = max(0.0, (65.0 - x) / 22.0)
                    grain = rng.randint(-9, 9)
                    base_v = int(66 - 22 * dx_l) + grain
                    eff_a = int(a * (0.76 if y < 48 else 0.84))
                    spx[x, y] = (clamp8(base_v * 0.94), clamp8(base_v * 0.96), clamp8(base_v * 1.02), eff_a)
        im = stubble

    elif hair_idx == 10:
        # `wx_hair_10` (铜簪半挽披肩长发 — flagship heroine & wandering swordsman hair!):
        # Completely seal the huge bald temple gap AND add lush flowing shoulder-length hair behind the ear & neck!
        fill_m = Image.new("L", (OUT_W, OUT_H), 0)
        fd = ImageDraw.Draw(fill_m)
        # Full upper scalp crown & left temple coverage (sealing the giant bald gap!)
        fd.ellipse([41, 38, 86, 66], fill=255)
        # Lush flowing shoulder-length back hair draping down behind ear & neck to collar (`y=52..88`)
        fd.polygon([
            (42, 50), (54, 52), (56, 75), (53, 86), (44, 88), (37, 82), (35, 68), (38, 56)
        ], fill=255)
        # Subtle far-side hair silhouette peeking behind right cheek/jaw (`x=82..88, y=54..82`)
        fd.polygon([(83, 52), (88, 57), (88, 73), (84, 82), (81, 78)], fill=225)
        fill_m = ImageChops.multiply(fill_m.filter(ImageFilter.GaussianBlur(0.8)), ImageOps.invert(FACE_OPEN_128))
        im = paint_hair_strand_region(im, fill_m, (34, 28, 25), seed_val=101, strand_angle=0.22)
        # Natural soft parted framing side-bangs (`垂鬓 + 偏分刘海`) curving gracefully off center-right brow
        wisp_m = Image.new("L", (OUT_W, OUT_H), 0)
        wd = ImageDraw.Draw(wisp_m)
        wd.polygon([(52, 50), (58, 50), (57, 68), (54, 75), (51, 68)], fill=215)
        wd.polygon([(56, 48), (68, 48), (72, 50), (66, 53), (57, 53)], fill=215)
        wd.polygon([(74, 48), (85, 51), (84, 54), (76, 51)], fill=195)
        wisp_m = wisp_m.filter(ImageFilter.GaussianBlur(0.6))
        im = paint_hair_overlay_strands(im, wisp_m, (34, 28, 25), seed_val=102, strand_angle=0.14)

    elif hair_idx in (1, 2, 5, 7, 9, 11, 12, 14, 17, 18, 20, 22, 23):
        # 1. Seal any subtle bald temple/scalp cracks inside upper skull contour (STRICTLY behind existing hand-painted hair!)
        scalp_fill = Image.new("L", (OUT_W, OUT_H), 0)
        sfd = ImageDraw.Draw(scalp_fill)
        sfd.ellipse([43, 40, 85, 64], fill=240)
        # Natural nape / behind-ear hair coverage connecting head smoothly toward neck/shoulders
        if hair_idx == 18:
            # Sleek tapered curved silver-grey nape (no boxy patch!)
            sfd.polygon([(42, 54), (52, 56), (52, 74), (47, 81), (41, 78), (39, 66)], fill=215)
        elif hair_idx in (2, 12, 23):
            # Longer flowing / medium hair drapes down behind ear to y=84..87
            sfd.polygon([(40, 54), (52, 56), (54, 76), (50, 86), (41, 85), (36, 76), (37, 62)], fill=245)
        elif hair_idx in (1, 9, 11, 20):
            # Heroic high-bun / ponytail / twin-bun: sleek gathered hair hugging back of skull & nape (`y=52..81`)
            sfd.polygon([(42, 52), (52, 54), (53, 74), (49, 81), (43, 79), (40, 68)], fill=235)
        else:
            # Classic knotted buns (`05, 07, 14, 17, 22`): tidy back-of-head & nape hairline (`y=52..78`)
            sfd.polygon([(43, 52), (52, 55), (52, 73), (48, 78), (43, 75), (41, 64)], fill=225)
        scalp_fill = ImageChops.multiply(scalp_fill.filter(ImageFilter.GaussianBlur(0.8)), ImageOps.invert(FACE_OPEN_128))
        nape_rgb = (int(base_rgb[0] * 0.72), int(base_rgb[1] * 0.72), int(base_rgb[2] * 0.72)) if hair_idx == 18 else base_rgb
        im = paint_hair_strand_region(im, scalp_fill, nape_rgb, seed_val=hair_idx * 17, strand_angle=0.28)

        # 2. Iconic framing locks (`双缕龙须垂鬓`) for `wx_hair_12` and gentle temple wisps for `09, 20, 23`
        if hair_idx == 12:
            lock_m = Image.new("L", (OUT_W, OUT_H), 0)
            ld = ImageDraw.Draw(lock_m)
            # Delicate tapered twin temple wisps curving along left cheek & far right cheek!
            ld.polygon([(53, 50), (57, 51), (56, 70), (53, 81), (51, 73)], fill=215)
            ld.polygon([(84, 52), (86, 53), (86, 71), (84, 79), (83, 69)], fill=195)
            lock_m = lock_m.filter(ImageFilter.GaussianBlur(0.55))
            im = paint_hair_overlay_strands(im, lock_m, base_rgb, seed_val=129, strand_angle=0.08)
        elif hair_idx in (9, 20, 23):
            lock_m = Image.new("L", (OUT_W, OUT_H), 0)
            ld = ImageDraw.Draw(lock_m)
            ld.polygon([(53, 51), (57, 51), (56, 66), (53, 71), (51, 65)], fill=195)
            lock_m = lock_m.filter(ImageFilter.GaussianBlur(0.55))
            im = paint_hair_overlay_strands(im, lock_m, base_rgb, seed_val=hair_idx * 19, strand_angle=0.1)

    elif hair_idx in (3, 6, 8, 15, 16, 19, 21, 24):
        # Tidy nape/temple backing so zero scalp gaps show
        scalp_fill = Image.new("L", (OUT_W, OUT_H), 0)
        sfd = ImageDraw.Draw(scalp_fill)
        if hair_idx not in (6, 19):  # Keep wx_hair_06's undercut & wx_hair_19's crisp spiky white crown natural
            sfd.ellipse([44, 41, 85, 62], fill=215)
        if hair_idx == 19:
            sfd.polygon([(44, 54), (51, 56), (51, 70), (47, 74), (44, 68)], fill=185)
        else:
            sfd.polygon([(43, 54), (52, 56), (52, 72), (47, 77), (43, 73)], fill=210)
        scalp_fill = ImageChops.multiply(scalp_fill.filter(ImageFilter.GaussianBlur(0.8)), ImageOps.invert(FACE_OPEN_128))
        nape_rgb = (int(base_rgb[0] * 0.72), int(base_rgb[1] * 0.72), int(base_rgb[2] * 0.72)) if hair_idx in (3, 19) else base_rgb
        im = paint_hair_strand_region(im, scalp_fill, nape_rgb, seed_val=hair_idx * 23, strand_angle=0.3)

    full_hair = soften_hairline_and_add_brow_shadow(im)

    # --- BUILD CLEAN CURVED UNDER-HAT `hair_tucked` (ZERO BOXY TEMPLE CHOP, ZERO BALD FOREHEAD!) ---
    # Instead of cutting a straight horizontal line at y=55, carve a smooth skull-hugging curved cap
    # that removes everything protruding ABOVE the hat brim (`y < 46` or outer topknots) while KEEPING:
    #   - Curved upper forehead hairline strip (`y=46..53`) so bamboo/conical hats never show a bald forehead!
    #   - Natural sideburns, temple hair & behind-ear nape hair (`x=38..56, y=47..81`)!
    tuck_mask = Image.new("L", (OUT_W, OUT_H), 0)
    td = ImageDraw.Draw(tuck_mask)
    # Smooth curved dome hugging inside the hat rim (`x=42..86, y=46..60`) + curved behind-ear nape (`x=38..56, y=54..82`)
    td.ellipse([42, 45, 86, 68], fill=255)
    td.polygon([(38, 56), (56, 54), (56, 74), (50, 82), (41, 80), (37, 70)], fill=255)
    # Trim the very top crown strictly below `y=46` (smoothly curved) so ZERO buns/ponytails poke out of closed helmets!
    td.rectangle([0, 0, OUT_W, 45], fill=0)
    # Subtract face + ear cleanly
    tuck_mask = ImageChops.multiply(tuck_mask.filter(ImageFilter.GaussianBlur(1.0)), ImageOps.invert(FACE_OPEN_128))

    tucked = full_hair.copy()
    tucked.putalpha(ImageChops.multiply(full_hair.getchannel("A"), tuck_mask))

    return full_hair, tucked


def tint_hair_or_beard(layer_rgba: Image.Image, tone: str) -> Image.Image:
    """
    Produces crisp Overhype-palette multi-tone hair/beard variants (`brown`, `grey`, `white`)
    preserving dark ink outlines & cast shadows!
    """
    out = layer_rgba.copy()
    px = out.load()
    w, h = out.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a <= 14:
                continue
            lum = 0.299 * r + 0.587 * g + 0.114 * b
            if a < 175 and lum < 26:
                continue  # keep soft cast shadows dark!
            if lum < 18:
                if tone == "white":
                    px[x, y] = (36, 33, 30, a)
                elif tone == "grey":
                    px[x, y] = (26, 24, 22, a)
                continue
            if tone == "brown":
                nr = min(220, int(lum * 1.24 + 26))
                ng = min(192, int(lum * 0.90 + 13))
                nb = min(162, int(lum * 0.62 + 5))
            elif tone == "grey":
                nl = min(204, int(lum * 1.32 + 44))
                nr, ng, nb = nl, int(nl * 0.99), int(nl * 0.95)
            elif tone == "white":
                nl = min(226, int(lum * 1.46 + 76))
                nr, ng, nb = nl, int(nl * 0.98), int(nl * 0.92)
            else:
                nr, ng, nb = r, g, b
            px[x, y] = (nr, ng, nb, a)
    return out


# ==============================================================================
# 6. HAT / HELMET OVERHAUL (FIX wx_hat_25 BLACK BRICK + SEAT FLOATING HATS!)
# ==============================================================================
def fix_hat_25_front_and_back(front_128: Image.Image, back_128: Image.Image):
    """
    Surgical reconstruction of `wx_hat_25` (`大宋红缨精铁笠子盔` — seen on BOTH characters in user screenshot!):
    1. Erases the hideous solid black rectangular block hanging right across the forehead (`y=46..56, x=50..80`)!
    2. Moves the awkward sticking-out right ear-flap (`x >= 79, y >= 47`) cleanly BEHIND the head into `hat_back`,
       and tucks/slims the wide flaring left flap into a crisp curved cheek-rim hugging the left temple/jaw!
    3. Seats the whole kettle-helmet down 1.5px right onto the brow with a natural soft brim shadow!
    """
    f = shift_img(front_128, 0.0, 1.5)
    b = shift_img(back_128, 0.0, 1.5) if back_128 is not None else Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))

    # Build a clean transfer mask for everything below the steel kettle brim (`y >= 49`) that blocks/flares past the face:
    #   - Center forehead black brick + right-cheek far-side flap -> erase black brick; transfer metallic neck-guard to `hat_back`!
    fpx = f.load()
    bpx = b.load()

    # Keep steel kettle dome & flared brim (`y <= 48`) 100% intact!
    # Below `y = 49`:
    #   - Center zone `x = 52..81, y = 49..62`: erase the black forehead brick completely!
    #   - Far-right flap `x >= 79, y >= 49`: darken slightly (0.72x) and move into `hat_back` (`z < head`)!
    #   - Left neck-guard `x <= 52, y >= 49`: trim outer flare (`x < 40`) slightly and keep snug curved steel cheek-guard (`x=41..52, y=49..67`)
    #     while moving inner-left overlap into `hat_back`!
    new_f = f.copy()
    nfpx = new_f.load()
    moved_back = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
    mbpx = moved_back.load()

    for y in range(48, 80):
        for x in range(30, 102):
            r, g, b_c, a = fpx[x, y]
            if a < 10:
                continue
            # Row 48..49: keep crisp dark underside rim of brim (1px), erase brick below y=49
            if y >= 49 and 51 <= x <= 81:
                nfpx[x, y] = (0, 0, 0, 0)
            elif y >= 49 and x > 81:
                # Trim far-right protrusion neatly so only a subtle curved rear neck-guard shows behind far cheek!
                nfpx[x, y] = (0, 0, 0, 0)
                if x <= 86 and y <= 63:
                    mbpx[x, y] = (clamp8(r * 0.65), clamp8(g * 0.65), clamp8(b_c * 0.65), int(a * 0.85))
            elif y >= 50 and x < 51:
                # Keep a sleek, hugging left cheek-rim (`x >= 43` curving inward down to `y=65`), move outer tail to back
                outer_lim = 43 - int(max(0, y - 50) * 0.18)
                if x < outer_lim or y > 65:
                    nfpx[x, y] = (0, 0, 0, 0)
                    if x >= 39 and y <= 67:
                        mbpx[x, y] = (clamp8(r * 0.72), clamp8(g * 0.72), clamp8(b_c * 0.72), a)

    # Also build a subtle dark neck-guard lining behind the head (`hat_back`) connecting left & right guards
    new_b = Image.alpha_composite(b, moved_back)

    # Add a delicate 1px brim shadow directly under the front brim (`y=48..51, x=48..84`) for 3D grounding
    sh = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(sh)
    sd.ellipse([48, 47, 84, 53], fill=(14, 10, 8, 95))
    sh = sh.filter(ImageFilter.GaussianBlur(1.2))
    sh.putalpha(ImageChops.multiply(sh.getchannel("A"), SKULL_128))
    new_f = Image.alpha_composite(sh, new_f)

    return new_f, new_b


# Per-hat vertical/horizontal fine seating tweaks on 128x164 (dx, dy) after standard HEAD_SCALE transform:
HAT_FINE_SEAT = {
    "wx_char_hat_bamboo":    (0.0, 6.0),   # Was floating 6-8px above eyebrows!
    "wx_hat_02":             (0.0, 2.5),   # Straw hat seats snugger on brow
    "wx_hat_03":             (0.0, 3.0),   # Bamboo rain hat seats snugger on brow
    "wx_hat_07":             (0.0, 3.0),   # Conical bamboo hat seats snugger on brow
    "wx_hat_26":             (0.0, 1.5),   # Iron kettle hat seats snugly
    "wx_hat_14":             (0.0, 2.5),   # Topknot cuff seats down onto bun
    "wx_char_hat_topknot":   (0.0, 2.5),   # Classic topknot pin seats down onto bun
    "wx_char_hat_taoist":    (0.0, 3.0),   # Lotus taoist crown seats down onto bun
    "wx_hat_09":             (0.0, 2.0),   # Taoist crown seats snugly
    "wx_hat_10":             (0.0, 2.0),   # Tall scholar/noble crown seats snugly
    "wx_hat_15":             (0.0, 2.5),   # Miao silver headband crown seats right across forehead
    "wx_hat_12":             (0.0, 1.5),   # Cloth headband
    "wx_hat_13":             (0.0, 1.5),   # Monk headband
    "wx_hat_16":             (0.0, 1.5),   # Jade forehead band
    "wx_hat_21":             (0.0, 1.5),   # Iron forehead band
    "wx_hat_22":             (0.0, 1.5),   # Vine circlet
}


def overhaul_hat_pair(front_104: Image.Image, back_104, hat_base: str):
    f128 = transform_aniso(
        front_104,
        sx=HEAD_SCALE,
        sy=HEAD_SCALE,
        pivot_wx=HEAD_PIVOT_WX,
        pivot_wy=HEAD_PIVOT_WY,
        shift_wx=HEAD_SHIFT_WX,
        shift_wy=HEAD_SHIFT_WY,
    )
    b128 = None
    if back_104 is not None:
        b128 = transform_aniso(
            back_104,
            sx=HEAD_SCALE,
            sy=HEAD_SCALE,
            pivot_wx=HEAD_PIVOT_WX,
            pivot_wy=HEAD_PIVOT_WY,
            shift_wx=HEAD_SHIFT_WX,
            shift_wy=HEAD_SHIFT_WY,
        )

    if hat_base == "wx_hat_25":
        return fix_hat_25_front_and_back(f128, b128)

    dx, dy = HAT_FINE_SEAT.get(hat_base, (0.0, 0.0))
    if dx != 0.0 or dy != 0.0:
        f128 = shift_img(f128, dx, dy)
        if b128 is not None:
            b128 = shift_img(b128, dx, dy)

    # Add soft grounding brow shadow under conical hats so they sit naturally on the forehead
    if hat_base in ("wx_char_hat_bamboo", "wx_hat_02", "wx_hat_03", "wx_hat_07", "wx_hat_26"):
        sh = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
        sd = ImageDraw.Draw(sh)
        sd.ellipse([46, 48, 85, 56], fill=(14, 10, 7, 88))
        sh = sh.filter(ImageFilter.GaussianBlur(1.3))
        sh.putalpha(ImageChops.multiply(sh.getchannel("A"), SKULL_128))
        f128 = Image.alpha_composite(sh, f128)

    return f128, b128


# ==============================================================================
# 7. MAIN PIPELINE + SYNCHRONIZE CORPSES & WORLD-MAP LEADER BUSTS + QA SHEETS
# ==============================================================================
def make_world_bust_from_128(im_128: Image.Image) -> Image.Image:
    """
    Converts an overhauled `128x164` (`oy=35`) paperdoll layer into an exact `68x106` (`ox=0, oy=20`)
    world-map player-lead figure layer (`wm_<id>`), keeping 100% registration across body/head/hair/hat!
    """
    # Crop active bust region `x=[10..118], y=[10..138]` (108x128) -> scale cleanly to 48x58
    sub = im_128.crop((10, 10, 118, 138)).resize((48, 57), Image.Resampling.LANCZOS)
    spx = sub.load()
    for y in range(44, 57):
        for x in range(48):
            r, g, b, a = spx[x, y]
            if a == 0:
                continue
            dx = (x - 23.5) / 22.0
            curve_y = 53.5 - 4.5 * (dx * dx)
            if y > curve_y + 1.5:
                spx[x, y] = (0, 0, 0, 0)
            elif y > curve_y - 1.5:
                fade = max(0.0, min(1.0, (curve_y + 1.5 - y) / 3.0))
                spx[x, y] = (r, g, b, int(a * fade))
    out = Image.new("RGBA", (68, 106), (0, 0, 0, 0))
    out.alpha_composite(sub, (10, 38))
    return out


def make_corpse_from_128(im_128: Image.Image, is_body_base: bool, seed_val: int) -> Image.Image:
    """
    Converts an overhauled `128x164` (`oy=35`) bust layer into a pixel-registered `131x125` (`ox=6, oy=10`)
    fallen tactical corpse decal by first mapping cleanly to canonical `104x142` framing!
    """
    # Map 128x164 (center x=64, waist y=135) -> 104x142 (center x=52, waist y=124) with fixed scale 0.86
    im_104 = transform_aniso(
        im_128,
        sx=0.86,
        sy=0.86,
        pivot_wx=0.0,
        pivot_wy=-18.0,
        shift_wx=0.0,
        shift_wy=0.0,
        out_w=104,
        out_h=142,
        oy=35,
    )
    return make_fallen_corpse_layer(im_104, is_body_base=is_body_base, seed_val=seed_val)


def build_all():
    gfx_rel, recs_087, by_087 = load_087_bust_records()
    print(f"Loaded {len(recs_087)} un-distorted 0.8.7 base sprites from {SRC_087_ZIP.name}.")

    new_imgs = {}

    # 1. Overhaul all 48 heads (`wx_head_01..48`)
    for i in range(1, 49):
        sid = f"wx_head_{i:02d}"
        if sid in by_087:
            new_imgs[sid] = overhaul_head(by_087[sid]["img"], i)

    # 2. Overhaul all 24 base hairs -> full + curved tucked + 3 multi-tone recolors (`_brown`, `_grey`, `_white`)
    for i in range(1, 25):
        hid = f"wx_hair_{i:02d}"
        if hid not in by_087:
            continue
        full_h, tuck_h = overhaul_hair(by_087[hid]["img"], i)
        new_imgs[hid] = full_h
        new_imgs[f"{hid}_tucked"] = tuck_h
        for tone in ("brown", "grey", "white"):
            new_imgs[f"{hid}_{tone}"] = tint_hair_or_beard(full_h, tone)
            new_imgs[f"{hid}_tucked_{tone}"] = tint_hair_or_beard(tuck_h, tone)

    # 3. Overhaul all 24 base beards (+ regenerate 3 tones from overhauled base)
    for i in range(1, 25):
        bid = f"wx_beard_{i:02d}"
        if bid not in by_087:
            continue
        b_im = transform_aniso(
            by_087[bid]["img"],
            sx=HEAD_SCALE,
            sy=HEAD_SCALE,
            pivot_wx=HEAD_PIVOT_WX,
            pivot_wy=HEAD_PIVOT_WY,
            shift_wx=HEAD_SHIFT_WX,
            shift_wy=HEAD_SHIFT_WY,
        )
        new_imgs[bid] = b_im
        for tone in ("brown", "grey", "white"):
            new_imgs[f"{bid}_{tone}"] = tint_hair_or_beard(b_im, tone)

    # 4. Overhaul all 12 scars (`wx_scar_01..12`) locked to head transform
    for i in range(1, 13):
        scid = f"wx_scar_{i:02d}"
        if scid in by_087:
            new_imgs[scid] = transform_aniso(
                by_087[scid]["img"],
                sx=HEAD_SCALE,
                sy=HEAD_SCALE,
                pivot_wx=HEAD_PIVOT_WX,
                pivot_wy=HEAD_PIVOT_WY,
                shift_wx=HEAD_SHIFT_WX,
                shift_wy=HEAD_SHIFT_WY,
            )

    # 5. Overhaul all 46 hats & helmets (`*_front` + `*_back`)
    hat_bases = sorted(set(k[:-6] for k in by_087 if k.endswith("_front")))
    for hb in hat_bases:
        f_raw = by_087[f"{hb}_front"]["img"]
        b_raw = by_087[f"{hb}_back"]["img"] if f"{hb}_back" in by_087 else None
        f_new, b_new = overhaul_hat_pair(f_raw, b_raw, hb)
        new_imgs[f"{hb}_front"] = f_new
        if b_new is not None and f"{hb}_back" in by_087:
            new_imgs[f"{hb}_back"] = b_new

    # 6. Overhaul all bodies, armors, robes, back cloaks & upgrades
    for r in recs_087:
        sid = r["id"]
        if sid in new_imgs:
            continue
        if sid.startswith(("wx_body_", "wx_char_cloth", "wx_char_robe", "wx_char_armor", "wx_char_raincape", "wx_armor_", "wx_beast_armor_")):
            new_imgs[sid] = overhaul_body(r["img"], sid)
        else:
            # `wx_back_*`, `wx_up_*` etc.: scale cleanly with heroic torso proportions
            im_u = transform_aniso(
                r["img"],
                sx=1.15,
                sy=BODY_SY,
                pivot_wx=0.0,
                pivot_wy=-18.0,
                shift_wx=0.0,
                shift_wy=-0.5,
            )
            im_u.putalpha(ImageChops.multiply(im_u.getchannel("A"), PED_CLIP_128))
            new_imgs[sid] = im_u

    # 7. Pack & write `mod_wuxia/brushes/wx_busts_0.brush` + `mod_wuxia/gfx/wx_busts_0.png`
    entries = []
    for r in recs_087:
        sid = r["id"]
        entries.append({
            "id": sid,
            "img": new_imgs[sid],
            "ox": OX,
            "oy": OY,
            "src_rel": r["src_rel"],
            "is_effect": False,
        })

    atlas, packed = shelf_pack_sprites(entries, max_atlas_w=2048)
    atlas = clean_zero_alpha_rgba(atlas)
    atlas.save(MOD_DIR / gfx_rel, optimize=True, compress_level=9)
    write_brush_binary(str(BRUSH_DIR / "wx_busts_0.brush"), gfx_rel, atlas.size, packed, is_effect_sheet=False)
    print(f"[OK] Rebuilt wx_busts_0.brush: {len(packed)} overhauled sprites, atlas={atlas.size}")

    # 8. Synchronize modular `wm_*` player-lead layers in `wx_world_entity_0.brush`
    we_bp = BRUSH_DIR / "wx_world_entity_0.brush"
    if we_bp.exists():
        we_gfx_rel, we_recs = load_brush_records(we_bp)
        we_entries = []
        wm_updated = 0
        for wr in we_recs:
            wid = wr["id"]
            if wid.startswith("wm_") and wid[3:] in new_imgs:
                im_wm = make_world_bust_from_128(new_imgs[wid[3:]])
                wm_updated += 1
            else:
                im_wm = wr["img"]
            we_entries.append({
                "id": wid,
                "img": im_wm,
                "ox": wr["ox"],
                "oy": wr["oy"],
                "src_rel": wr["src_rel"],
                "is_effect": False,
            })
        we_atlas, we_packed = shelf_pack_sprites(we_entries, max_atlas_w=2048)
        we_atlas = clean_zero_alpha_rgba(we_atlas)
        we_atlas.save(MOD_DIR / we_gfx_rel, optimize=True, compress_level=9)
        write_brush_binary(str(we_bp), we_gfx_rel, we_atlas.size, we_packed, is_effect_sheet=False)
        print(f"[OK] Synced wx_world_entity_0.brush: {wm_updated} wm_* modular leader layers updated, atlas={we_atlas.size}")

    # 9. Synchronize modular `*_dead` corpse decals at full 1:1 heroic scale (`wx_corpses_*.brush`)
    import build_wx_corpses as corpses_mod
    corpses_mod.build_all_corpses()

    # 10. Re-apply zero-VRAM `_injured` aliases cleanly
    add_injured_aliases()

    return new_imgs


def render_qa_sheets(new_imgs, out_dir: Path):
    out_dir.mkdir(parents=True, exist_ok=True)
    _, wrecs = load_brush_records(BRUSH_DIR / "wx_weapons_0.brush")
    wby = {r["id"]: r["img"] for r in wrecs if not r["id"].endswith("_injured")}

    def make_grid(items, cols, bg=(38, 34, 30, 255)):
        rows = (len(items) + cols - 1) // cols
        sheet = Image.new("RGBA", (cols * OUT_W, rows * (OUT_H + 18)), bg)
        dr = ImageDraw.Draw(sheet)
        for idx, (lbl, im) in enumerate(items):
            r, c = divmod(idx, cols)
            x0, y0 = c * OUT_W, r * (OUT_H + 18)
            sheet.alpha_composite(im, (x0, y0))
            dr.text((x0 + 4, y0 + OUT_H + 2), lbl, fill=(240, 225, 190, 255))
        return sheet

    ref_body = new_imgs["wx_body_arm_07"]
    ref_head_m = new_imgs["wx_head_01"]
    ref_head_f = new_imgs["wx_head_33"]

    # 1. All 48 heads on ref_body
    head_items = []
    for i in range(1, 49):
        hid = f"wx_head_{i:02d}"
        c = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
        c.alpha_composite(ref_body)
        c.alpha_composite(new_imgs[hid])
        head_items.append((hid, c))
    make_grid(head_items, 8).convert("RGB").save(out_dir / "after_heads_48.jpg", quality=93)

    # 2. All 24 hairs on male & female + tucked
    hm_items, hf_items, ht_items = [], [], []
    for i in range(1, 25):
        hk = f"wx_hair_{i:02d}"
        for lst, hd, key in ((hm_items, ref_head_m, hk), (hf_items, ref_head_f, hk), (ht_items, ref_head_m, hk + "_tucked")):
            c = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
            c.alpha_composite(ref_body)
            c.alpha_composite(hd)
            c.alpha_composite(new_imgs[key])
            lst.append((key, c))
    make_grid(hm_items, 6).convert("RGB").save(out_dir / "after_hairs_male_24.jpg", quality=93)
    make_grid(hf_items, 6).convert("RGB").save(out_dir / "after_hairs_female_24.jpg", quality=93)
    make_grid(ht_items, 6).convert("RGB").save(out_dir / "after_hairs_tucked_24.jpg", quality=93)

    # 3. All 72 bodies with ref_head_m + wx_hair_01
    body_ids = sorted(k for k in new_imgs if k.startswith(("wx_body_", "wx_char_cloth", "wx_char_robe", "wx_char_armor", "wx_char_raincape", "wx_armor_")))
    b_items = []
    for bid in body_ids:
        c = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
        c.alpha_composite(new_imgs[bid])
        c.alpha_composite(ref_head_m)
        c.alpha_composite(new_imgs["wx_hair_01"])
        b_items.append((bid, c))
    make_grid(b_items, 8).convert("RGB").save(out_dir / "after_bodies_all.jpg", quality=93)

    # 4. All 46 hats with ref_head_m + hair_10 (open crown) / hair_10_tucked (closed)
    hat_ids = sorted(set(k[:-6] for k in new_imgs if k.endswith("_front")))
    open_crown = {"wx_hat_01", "wx_hat_09", "wx_hat_10", "wx_hat_12", "wx_hat_13", "wx_hat_14", "wx_hat_15", "wx_hat_16", "wx_hat_17", "wx_hat_21", "wx_hat_22", "wx_char_hat_topknot", "wx_char_hat_taoist"}
    h_items = []
    for htid in hat_ids:
        c = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
        c.alpha_composite(ref_body)
        if (htid + "_back") in new_imgs:
            c.alpha_composite(new_imgs[htid + "_back"])
        c.alpha_composite(ref_head_m)
        hk = "wx_hair_10" if htid in open_crown else "wx_hair_10_tucked"
        c.alpha_composite(new_imgs[hk])
        c.alpha_composite(new_imgs[htid + "_front"])
        h_items.append((htid, c))
    make_grid(h_items, 8).convert("RGB").save(out_dir / "after_hats_all.jpg", quality=93)

    # 5. Heroic Showcase (recreating the EXACT 5 characters from the user's screenshot + diverse bare-head heroes/heroines WITH weapons & shields!)
    showcase_specs = [
        ("TopLeft Fixed",     "wx_body_arm_07",           "wx_head_24", "wx_hair_01_tucked", None,          "wx_hat_25",          "arm_wx_wpn_sword_03", "shd_wx_shd_04"),
        ("MidLeft Fixed",     "wx_body_arm_07",           "wx_head_04", "wx_hair_18_tucked", "wx_beard_22", "wx_hat_25",          "arm_wx_wpn_axe_02",   "shd_wx_shd_01"),
        ("MidCenter Fixed",   "wx_body_hvy_01",           "wx_head_15", "wx_hair_01_tucked", "wx_beard_17", "wx_hat_30",          "arm_wx_wpn_pole_05",  None),
        ("TopMid Fixed",      "wx_body_hvy_10",           "wx_head_30", "wx_hair_17_tucked", "wx_beard_16", "wx_hat_27",          "arm_wx_wpn_saber_04", None),
        ("Heroine Hat Fixed", "wx_char_armor_brigandine", "wx_head_33", "wx_hair_10_tucked", None,          "wx_hat_30",          "arm_wx_wpn_sword_08", None),
        ("Heroine Hair10",    "wx_body_sect_03",          "wx_head_33", "wx_hair_10",        None,          None,                 "arm_wx_wpn_sword_04", None),
        ("Heroine Hair12",    "wx_body_sect_04",          "wx_head_46", "wx_hair_12",        None,          "wx_hat_12",          "arm_wx_wpn_sword_06", None),
        ("Heroine Bamboo",    "wx_char_robe_swordsman",   "wx_head_37", "wx_hair_20_tucked", None,          "wx_char_hat_bamboo", "arm_wx_wpn_saber_03", None),
        ("YoungHero Hair09",  "wx_body_sect_01",          "wx_head_22", "wx_hair_09",        None,          None,                 "arm_wx_wpn_staff_03", None),
        ("Monk Hair04",       "wx_char_robe_monk",        "wx_head_08", "wx_hair_04",        "wx_beard_07", None,                 "arm_wx_wpn_staff_06", None),
        ("Monk Hair13",       "wx_body_sect_14",          "wx_head_10", "wx_hair_13",        None,          None,                 "arm_wx_wpn_pole_03",  None),
        ("WestHeroine 47",    "wx_body_sect_13",          "wx_head_47", "wx_hair_17",        None,          "wx_hat_15",          "arm_wx_wpn_saber_07", None),
    ]
    sc_items = []
    for lbl, bd, hd, hr, brd, ht, wpn, shd in showcase_specs:
        c = Image.new("RGBA", (OUT_W, OUT_H), (0, 0, 0, 0))
        c.alpha_composite(new_imgs[bd])
        if ht and (ht + "_back") in new_imgs:
            c.alpha_composite(new_imgs[ht + "_back"])
        c.alpha_composite(new_imgs[hd])
        if brd and brd in new_imgs:
            c.alpha_composite(new_imgs[brd])
        if hr and hr in new_imgs:
            c.alpha_composite(new_imgs[hr])
        if ht and (ht + "_front") in new_imgs:
            c.alpha_composite(new_imgs[ht + "_front"])
        if wpn and wpn in wby:
            c.alpha_composite(wby[wpn])
        if shd and shd in wby:
            c.alpha_composite(wby[shd])
        sc_items.append((lbl, c))
    sh_img = make_grid(sc_items, 4)
    sh_img.resize((sh_img.width * 2, sh_img.height * 2), Image.Resampling.NEAREST).convert("RGB").save(out_dir / "after_showcase_2x.jpg", quality=94)
    print(f"[OK] Wrote 6 visual QA sheets into {out_dir}")


if __name__ == "__main__":
    imgs = build_all()
    if "--qa" in sys.argv:
        qa_idx = sys.argv.index("--qa")
        qa_dir = Path(sys.argv[qa_idx + 1]) if qa_idx + 1 < len(sys.argv) else (ROOT / "scratch_qa")
        render_qa_sheets(imgs, qa_dir)
