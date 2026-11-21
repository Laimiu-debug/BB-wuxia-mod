#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
True Boolean & Master-Skull-Registered Battle Brothers Bust Engine (v4):
Implements exact 2D Boolean CSG operations (`∪`, `∩`, `⊖`) across Master Skull, Face Window,
Hairstyles, Tucked Under-Hat Hair, and Split Front/Back Hats & Helmets:

1. Master Skull & Face Contour (`MASTER_HEAD_SILHOUETTE` & `MASTER_FACE_MASK`):
   - Every head (`wx_head_01..48`) is landmark-aligned (eyes at y=111, jaw at y=156, right cheek at x=142)
     and boolean-clamped on its upper cranium (`y < 108`) to `MASTER_HEAD_SILHOUETTE` so ALL 48 faces
     share ONE identical temple/skull contour!
2. Compact Boolean Hair (`Hair_Final = ((MASTER_SCALP_SHELL ∪ Compressed_Hair) ⊖ MASTER_FACE_EAR_MASK)`):
   - Compresses tall upper hair domes so hair hugs 5-9px above skull (topknots max 16px),
   - Fills exact temple-to-hairline contact via `MASTER_SCALP_SHELL` (drawn in matching hair texture)
     and boolean-subtracts `MASTER_FACE_EAR_MASK` + redraws a crisp 1.5px dark hairline contour!
3. Boolean Hat × Hair × Face Split (`hat_back`, `hat_front`, `hair_tucked`):
   - `hair_tucked = Hair_Final ∩ UNDER_BRIM_TEMPLE_MASK` (boolean-slices off all top/side hair above
     the hat crown while keeping natural sideburns & nape hair under the brim!)
   - `hat_front = Hat ⊖ MASTER_FACE_WINDOW` (boolean-punches out the 3/4-right eyes/nose/cheeks/mouth
     window so NO hat or helmet can EVER cover or erase the character's face!)
   - `hat_back = Hat ∩ BEHIND_HEAD_ZONE` (places rear brims, hoods & neck-guards BEHIND `head` in 3D!)
"""

from collections import deque
import json
import math
import os
from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART_DIR = os.path.join(ROOT, "art")
SHEETS_DIR = os.path.join(ART_DIR, "sheets")
HD_DIR = os.path.join(ART_DIR, "hd")
GAME_DIR = os.path.join(ART_DIR, "game")
BUSTS_DIR = os.path.join(ART_DIR, "busts")

W, H = 208, 284
# Canonical 3/4-Right Master Head Box: x=[69..143] (74px wide), y=[76..156] (80px tall)
HEAD_X = 69
HEAD_W = 74
SKULL_TOP_Y = 76
EYE_LINE_Y = 112
JAW_BOTTOM_Y = 156
TORSO_BOTTOM_Y = 246


def ensure_bust_dirs():
    for sub in ("", "body", "head", "scar", "beard", "hair", "hair_tucked", "hat", "hat_back", "hat_front"):
        os.makedirs(os.path.join(BUSTS_DIR, sub), exist_ok=True)
    os.makedirs(os.path.join(GAME_DIR, "entity", "bodies"), exist_ok=True)


# ==============================================================================
# 2D BOOLEAN CSG PRIMITIVES ON ALPHA MASKS (`L` mode 0..255)
# ==============================================================================
def bool_union(m1, m2):
    return ImageChops.lighter(m1, m2)


def bool_intersect(m1, m2):
    return ImageChops.multiply(m1, m2)


def bool_subtract(m1, m2):
    """m1 ⊖ m2 = m1 ∩ ¬m2"""
    return ImageChops.multiply(m1, ImageOps.invert(m2))


def build_master_head_masks():
    """
    Construct the canonical 3/4-Right Battle Brothers Master Skull, Face+Ear Cutout,
    Scalp Hair Shell, and Helmet Face-Preservation Window on the 208x284 canvas!
    """
    # 1. Master Skull Silhouette (`[69..143, 76..156]`): cranium + cheek + jaw
    skull = Image.new("L", (W, H), 0)
    sd = ImageDraw.Draw(skull)
    # Upper cranium ellipse + lower 3/4-right jaw polygon
    sd.ellipse([69, 76, 142, 138], fill=255)
    sd.polygon([(74, 112), (142, 106), (140, 136), (126, 155), (104, 156), (82, 144)], fill=255)
    skull = skull.filter(ImageFilter.GaussianBlur(0.8))

    # 2. Master Exposed Face + Ear Cutout (`MASTER_FACE_EAR_MASK`):
    #    ONE continuous skin cutout from outer ear rim `[76..89]` right across cheek `[89..145]`
    #    (NO detached ear oval -> NO black circle between ear and cheek!), with a crisp pointed
    #    Wuxia temple sideburn (`剑鬓`) V-notch carved at `x=87..93, y=97..116`!
    face_ear = Image.new("L", (W, H), 0)
    fd = ImageDraw.Draw(face_ear)
    fd.polygon([
        (95, 92),   # upper-left forehead hairline corner
        (120, 89),  # center-right hairline arch
        (143, 93),  # right brow temple edge
        (148, 115),
        (145, 140),
        (128, 158),
        (98, 158),
        (89, 142),
        (87, 130),  # bottom of ear merges continuously into jawline!
        (80, 129),  # lower-back lobe of ear
        (76, 124),  # back rim of ear
        (76, 113),  # upper-back rim of ear
        (82, 108),  # top of ear helix
        (87, 110),  # upper ear root
        (89, 116),  # pointed tip of temple sideburn (`剑鬓`)!
        (93, 112),  # front edge of temple sideburn
        (93, 97),   # upper temple hairline
    ], fill=255)
    face_ear_soft = face_ear.filter(ImageFilter.GaussianBlur(0.8))

    # 3. Inward Hairline Bridge Zone (`MASTER_SCALP_BRIDGE`):
    #    ONLY bridges narrow 1..9px gaps INSIDE the skull rim (`[73..143, 76..132]`) right up to `face_ear`,
    #    NEVER inventing a synthetic dome outside the hand-painted hair silhouette!
    outer_scalp = Image.new("L", (W, H), 0)
    od = ImageDraw.Draw(outer_scalp)
    od.ellipse([73, 76, 143, 132], fill=255)
    scalp_shell = bool_subtract(outer_scalp.filter(ImageFilter.GaussianBlur(0.6)), face_ear_soft)

    # 4. Helmet Face-Preservation T-Window (`MASTER_HELMET_FACE_WINDOW`):
    #    Strictly protects the 3/4-right front face & front hanging beard (`x=[103..146], y=[102..210]`),
    #    while keeping left steel cheek-guards / hood flaps (`x <= 102`) 100% SOLID in `hat_front`
    #    so beard sideburns NEVER clip through helmet cheek-plates!
    helm_face_win = Image.new("L", (W, H), 0)
    hd = ImageDraw.Draw(helm_face_win)
    hd.polygon([
        (102, 102), # above left eyebrow (leaves left cheek-guard x<=101 intact!)
        (124, 100), # brow bridge
        (145, 103), # right brow
        (149, 126), # nose tip & right cheek
        (146, 210), # allows central chin & long front beard to hang freely!
        (105, 210),
        (102, 146), # inner edge of left cheek-guard
    ], fill=255)
    helm_face_win = helm_face_win.filter(ImageFilter.GaussianBlur(1.1))

    # 5. Under-Brim Tucked Hair Mask (`UNDER_BRIM_MASK`):
    #    Boolean-clips hair when wearing a closed-top hat/helmet: removes 100% of hair above `y=101`
    #    and curves smoothly inward behind the ear (`y <= 135`) so ZERO boxy corners stick out!
    under_brim = Image.new("L", (W, H), 0)
    ubd = ImageDraw.Draw(under_brim)
    ubd.polygon([
        (66, 101), (98, 101), (95, 125), (86, 135), (73, 131), (66, 118)
    ], fill=255)
    under_brim = under_brim.filter(ImageFilter.GaussianBlur(1.4))

    return skull, face_ear_soft, scalp_shell, helm_face_win, under_brim


MASTER_SKULL, MASTER_FACE_EAR, MASTER_SCALP_SHELL, MASTER_HELM_FACE_WIN, UNDER_BRIM_MASK = build_master_head_masks()


def tight_crop(rgba, thresh=24):
    bbox = rgba.getchannel("A").point(lambda a: 255 if a > thresh else 0).getbbox()
    return rgba.crop(bbox) if bbox else rgba


def decontaminate_white_fringe(rgba, passes=1):
    out = rgba.copy()
    w, h = out.size
    px = out.load()
    for _ in range(max(1, min(2, passes))):
        snap = out.copy()
        spx = snap.load()
        for y in range(h):
            for x in range(w):
                r, g, b, a = spx[x, y]
                if a == 0:
                    continue
                adj_zero = (x == 0 or y == 0 or x == w - 1 or y == h - 1)
                if not adj_zero:
                    for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                        if spx[nx, ny][3] < 24:
                            adj_zero = True
                            break
                if not adj_zero and a >= 245:
                    continue
                darkest_nb = (r, g, b)
                darkest_lum = r + g + b
                for dy in (-2, -1, 0, 1, 2):
                    for dx in (-2, -1, 0, 1, 2):
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < w and 0 <= ny < h:
                            nr, ng, nb, na = spx[nx, ny]
                            if na >= 220 and (nr + ng + nb) < darkest_lum:
                                darkest_lum = nr + ng + nb
                                darkest_nb = (nr, ng, nb)
                mx, mn = max(r, g, b), min(r, g, b)
                if mn >= 110 and (mx - mn) <= 30 and darkest_lum < 210:
                    true_a = int(255 * max(0.0, min(1.0, (244.0 - mx) / 215.0)))
                    new_a = min(a, true_a)
                    px[x, y] = (0, 0, 0, 0) if new_a < 20 else (darkest_nb[0], darkest_nb[1], darkest_nb[2], new_a)
                elif a < 245:
                    af = max(0.10, a / 255.0)
                    ur = max(0, min(darkest_nb[0], int((r - (1.0 - af) * 255.0) / af)))
                    ug = max(0, min(darkest_nb[1], int((g - (1.0 - af) * 255.0) / af)))
                    ub = max(0, min(darkest_nb[2], int((b - (1.0 - af) * 255.0) / af)))
                    px[x, y] = (ur, ug, ub, int(a * 0.90))
    return out


def flood_white_bg(cell_img, bg_thresh=34, feather=24):
    im = cell_img.convert("RGB")
    cw, ch = im.size
    px = im.load()
    vis = bytearray(cw * ch)
    q = deque()
    def dist(c): return max(255 - c[0], 255 - c[1], 255 - c[2])
    for x in range(cw):
        for sy in (0, 1, ch - 1, ch - 2):
            idx = sy * cw + x
            if not vis[idx] and dist(px[x, sy]) <= bg_thresh + feather:
                vis[idx] = 1 if dist(px[x, sy]) <= bg_thresh else 2
                if vis[idx] == 1: q.append((x, sy))
    for y in range(ch):
        for sx in (0, 1, cw - 1, cw - 2):
            idx = y * cw + sx
            if not vis[idx] and dist(px[sx, y]) <= bg_thresh + feather:
                vis[idx] = 1 if dist(px[sx, y]) <= bg_thresh else 2
                if vis[idx] == 1: q.append((sx, y))
    while q:
        cx, cy = q.popleft()
        for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
            if 0 <= nx < cw and 0 <= ny < ch:
                nidx = ny * cw + nx
                if not vis[nidx]:
                    d = dist(px[nx, ny])
                    if d <= bg_thresh:
                        vis[nidx] = 1; q.append((nx, ny))
                    elif d <= bg_thresh + feather:
                        vis[nidx] = 2
    alpha = Image.new("L", (cw, ch), 255)
    apx = alpha.load()
    for y in range(ch):
        row = y * cw
        for x in range(cw):
            v = vis[row + x]
            if v == 1: apx[x, y] = 0
            elif v == 2: apx[x, y] = int(255 * max(0.0, min(1.0, (dist(px[x, y]) - bg_thresh) / float(feather))))
    rgba = im.convert("RGBA")
    rgba.putalpha(alpha)

    rpx = rgba.load()
    hvis = bytearray(cw * ch)
    for y in range(1, ch - 1):
        for x in range(1, cw - 1):
            idx = y * cw + x
            if not hvis[idx] and rpx[x, y][3] > 160:
                r0, g0, b0, _ = rpx[x, y]
                if min(r0, g0, b0) >= 242 and (max(r0, g0, b0) - min(r0, g0, b0)) <= 10:
                    hvis[idx] = 1
                    hq = deque([(x, y)])
                    pts = [(x, y)]
                    slum = (r0 + g0 + b0) / 3.0
                    while hq:
                        hx, hy = hq.popleft()
                        for nx, ny in ((hx - 1, hy), (hx + 1, hy), (hx, hy - 1), (hx, hy + 1)):
                            if 0 <= nx < cw and 0 <= ny < ch:
                                nidx = ny * cw + nx
                                if not hvis[nidx] and rpx[nx, ny][3] > 140:
                                    nr, ng, nb, _ = rpx[nx, ny]
                                    if min(nr, ng, nb) >= 230 and (max(nr, ng, nb) - min(nr, ng, nb)) <= 12:
                                        hvis[nidx] = 1; hq.append((nx, ny)); pts.append((nx, ny))
                                        slum += (nr + ng + nb) / 3.0
                    if len(pts) >= 16 and (slum / len(pts)) >= 250.5:
                        for (kx, ky) in pts:
                            rpx[kx, ky] = (0, 0, 0, 0)
    return decontaminate_white_fringe(rgba, passes=1)


def clean_sheet38_hair(cell_img, idx):
    cw, ch = cell_img.size
    rgba = flood_white_bg(cell_img, bg_thresh=34, feather=24)
    rpx = rgba.load()
    bbox = rgba.getchannel("A").point(lambda a: 255 if a > 20 else 0).getbbox()
    if not bbox:
        return rgba
    bx0, by0, bx1, by1 = bbox
    bh = by1 - by0
    if idx == 4:
        for y in range(by0 + int(bh * 0.56), ch):
            for x in range(cw):
                rpx[x, y] = (0, 0, 0, 0)
        return decontaminate_white_fringe(rgba, passes=1)
    if idx == 1:
        bw_c = bx1 - bx0
        a_ch = rgba.getchannel("A")
        ImageDraw.Draw(a_ch).ellipse([bx0 + int(bw_c * 0.06), by0 + int(bh * 0.36), bx0 + int(bw_c * 0.62), by1 + 10], fill=0)
        rgba.putalpha(a_ch)
        return decontaminate_white_fringe(rgba, passes=1)

    orig = rgba.copy()
    opx = orig.load()
    jaw_y_start = by0 + int(bh * 0.60)
    for y in range(jaw_y_start, ch):
        for x in range(bx0, bx1):
            if opx[x, y][3] > 0:
                h_run = 1
                lx = x - 1
                while lx >= 0 and opx[lx, y][3] > 50 and h_run < 16: h_run += 1; lx -= 1
                rx = x + 1
                while rx < cw and opx[rx, y][3] > 50 and h_run < 16: h_run += 1; rx += 1
                v_run = 1
                uy = y - 1
                while uy >= 0 and opx[x, uy][3] > 50 and v_run < 16: v_run += 1; uy -= 1
                dy = y + 1
                while dy < ch and opx[x, dy][3] > 50 and v_run < 16: v_run += 1; dy += 1
                if min(h_run, v_run) <= 9:
                    if idx == 3 and y < by1 - 26 and h_run <= 9 and v_run >= 14:
                        continue
                    rpx[x, y] = (0, 0, 0, 0)

    vis = bytearray(cw * ch)
    for y in range(jaw_y_start - 4, ch):
        for x in range(cw):
            i0 = y * cw + x
            if not vis[i0] and rpx[x, y][3] > 15:
                vis[i0] = 1; q = deque([(x, y)]); pts = [(x, y)]
                while q:
                    qx, qy = q.popleft()
                    for nx, ny in ((qx - 1, qy), (qx + 1, qy), (qx, qy - 1), (qx, qy + 1)):
                        if 0 <= nx < cw and 0 <= ny < ch:
                            ni = ny * cw + nx
                            if not vis[ni] and rpx[nx, ny][3] > 15:
                                vis[ni] = 1; q.append((nx, ny)); pts.append((nx, ny))
                if len(pts) < 75:
                    for (kx, ky) in pts: rpx[kx, ky] = (0, 0, 0, 0)
    return decontaminate_white_fringe(rgba, passes=1)


def warm_fix_green_skin(rgba):
    """
    Harmonize olive-green, overly yellow, or chalky corpse-grey skin tones into warm Overhype
    gouache flesh (`R > G > B`) while preserving dark ink outlines, hair/brows, and crimson accents!
    """
    out = rgba.copy(); px = out.load(); w, h = out.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a <= 20:
                continue
            lum = 0.299 * r + 0.587 * g + 0.114 * b
            if lum < 42:
                continue  # keep dark ink, pupils, brows untouched
            sat = max(r, g, b) - min(r, g, b)
            # Case 1: Olive-green or jaundiced yellow skin (`g` too close to `r`, or `b` starved relative to `g`)
            if (g >= r - 18 and g > b + 12) or (g - b > 44 and r - g < 26):
                tr = min(255, int(lum * 1.16 + 10))
                tg = min(255, int(lum * 0.93 + 2))
                tb = min(255, int(lum * 0.74 + 6))
                px[x, y] = (int(r * 0.28 + tr * 0.72), int(g * 0.28 + tg * 0.72), int(b * 0.28 + tb * 0.72), a)
            # Case 2: Chalk-white or corpse-grey skin (`sat < 28` and mid-to-high luminance)
            elif lum > 95 and sat < 30 and r < b + 24:
                tr = min(244, int(lum * 1.05 + 12))
                tg = min(226, int(lum * 0.90 + 3))
                tb = min(204, int(lum * 0.77))
                px[x, y] = (int(r * 0.30 + tr * 0.70), int(g * 0.30 + tg * 0.70), int(b * 0.30 + tb * 0.70), a)
    return out


def round_pointed_ear_tip(rgba):
    out = rgba.copy()
    b = out.getchannel("A").point(lambda a: 255 if a > 20 else 0).getbbox()
    if not b: return out
    x0, y0, x1, y1 = b
    px = out.load()
    cut_x = x0 + int((x1 - x0) * 0.89)
    for y in range(y0 + int((y1 - y0) * 0.32), y0 + int((y1 - y0) * 0.58)):
        for x in range(cut_x, x1): px[x, y] = (0, 0, 0, 0)
    return out


def bb_grade(rgba):
    rgb = ImageEnhance.Color(rgba.convert("RGB")).enhance(0.84)
    rgb = ImageEnhance.Contrast(rgb).enhance(1.09)
    r, g, b = rgb.split()
    r = r.point(lambda v: min(255, int(v * 1.02 + 2)))
    g = g.point(lambda v: int(v * 0.98))
    b = b.point(lambda v: max(0, int(v * 0.90)))
    w, h = rgba.size
    out = Image.merge("RGBA", (r, g, b, rgba.getchannel("A")))
    px = out.load()
    for y in range(h):
        vgrad = 1.05 - 0.15 * (y / float(max(1, h - 1)))
        for x in range(w):
            pr, pg, pb, pa = px[x, y]
            if pa > 0:
                px[x, y] = (max(0, min(255, int(pr * vgrad))), max(0, min(255, int(pg * vgrad))), max(0, min(255, int(pb * vgrad))), pa)
    return out


def stroke_boolean_cut_edge(rgba, cut_mask, dark_rgb=(20, 16, 13), max_y=165):
    """
    When a boolean subtraction cuts an internal boundary (e.g. hairline against MASTER_FACE_EAR
    or helmet visor rim against MASTER_HELM_FACE_WIN), paint a subtle 1px Battle Brothers ink
    crease right along the cut boundary (above `max_y`) so it looks naturally hand-drawn!
    """
    out = rgba.copy()
    px = out.load()
    cpx = cut_mask.load()
    a_orig = out.getchannel("A")
    apx = a_orig.load()
    for y in range(2, min(H - 2, max_y)):
        for x in range(2, W - 2):
            if apx[x, y] > 100:
                near_cut = False
                for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1), (x + 1, y + 1), (x - 1, y + 1)):
                    if cpx[nx, ny] > 155 and apx[nx, ny] < 85:
                        near_cut = True
                        break
                if near_cut:
                    r, g, b, a = px[x, y]
                    px[x, y] = (int(r * 0.42 + dark_rgb[0] * 0.58), int(g * 0.42 + dark_rgb[1] * 0.58), int(b * 0.42 + dark_rgb[2] * 0.58), a)
    return out


def bake_self_drop_shadow(layer_208, dx=0, dy=3, blur=3.0, alpha_scale=0.50):
    a = layer_208.getchannel("A").point(lambda v: int(v * alpha_scale))
    sh = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sh.paste((12, 8, 5, 255), (dx, dy), a)
    sh = sh.filter(ImageFilter.GaussianBlur(radius=blur))
    clip = Image.new("L", (W, H), 0)
    ImageDraw.Draw(clip).ellipse([36, 74, 174, 242], fill=255)
    clip = clip.filter(ImageFilter.GaussianBlur(radius=3.0))
    sh.putalpha(ImageChops.multiply(sh.getchannel("A"), clip))
    return Image.alpha_composite(sh, layer_208)


def make_pedestal_layers():
    back = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    bd = ImageDraw.Draw(back)
    sh = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(sh).ellipse([6, 180, 202, 272], fill=(4, 3, 2, 220))
    back.alpha_composite(sh.filter(ImageFilter.GaussianBlur(radius=7)))
    bd.ellipse([10, 172, 198, 262], fill=(34, 31, 28, 255), outline=(12, 10, 9, 255), width=3)
    bd.ellipse([16, 177, 192, 254], fill=(20, 17, 15, 255))

    tmask = Image.new("L", (W, H), 0)
    td = ImageDraw.Draw(tmask)
    td.ellipse([12, 148, 196, 248], fill=255)
    td.rectangle([12, 50, 196, 200], fill=255)
    smask = Image.new("L", (W, H), 0)
    ImageDraw.Draw(smask).ellipse([10, 74, 198, 250], fill=255)
    tmask = ImageChops.multiply(tmask, smask).filter(ImageFilter.GaussianBlur(radius=1.5))

    front = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    outer = Image.new("L", (W, H), 0); ImageDraw.Draw(outer).ellipse([10, 172, 198, 262], fill=255)
    inner = Image.new("L", (W, H), 0); ImageDraw.Draw(inner).ellipse([16, 160, 192, 242], fill=255)
    half = Image.new("L", (W, H), 0); ImageDraw.Draw(half).rectangle([0, 198, W, H], fill=255)
    lip_mask = ImageChops.multiply(ImageChops.subtract(outer, inner), half)

    lip_fill = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    lpx = lip_fill.load(); mpx = lip_mask.load()
    for y in range(198, 265):
        for x in range(8, 200):
            a = mpx[x, y]
            if a > 0:
                nx = abs(x - W / 2.0) / 94.0
                lum = max(28, min(114, int(90 - 38 * (nx ** 1.4) - (y - 228) * 0.6)))
                lpx[x, y] = (lum, int(lum * 0.95), int(lum * 0.88), a)
    front.alpha_composite(lip_fill)
    fd = ImageDraw.Draw(front)
    fd.arc([10, 172, 198, 262], start=8, end=172, fill=(12, 10, 9, 255), width=3)
    fd.arc([16, 160, 192, 242], start=14, end=166, fill=(134, 126, 112, 215), width=2)
    fd.arc([16, 162, 192, 244], start=14, end=166, fill=(18, 15, 12, 235), width=2)
    cx, cy = W // 2, 250
    for sgn in (-1, 1):
        fd.polygon([(cx + sgn * 12, cy - 3), (cx + sgn * 32, cy - 7), (cx + sgn * 28, cy + 4), (cx + sgn * 11, cy + 6)],
                   fill=(96, 90, 82, 255), outline=(16, 14, 12, 255))
    fd.polygon([(cx - 12, cy - 11), (cx + 12, cy - 11), (cx + 10, cy + 4), (cx, cy + 14), (cx - 10, cy + 4)],
               fill=(76, 71, 64, 255), outline=(12, 10, 9, 255))
    fd.polygon([(cx - 9, cy - 8), (cx + 9, cy - 8), (cx + 7, cy + 3), (cx, cy + 10), (cx - 7, cy + 3)],
               fill=(114, 107, 96, 255))
    return back, front, tmask


def fill_collar_neck_flesh(torso_layer):
    """
    Place a clean shaded anatomical neck cylinder STRICTLY BEHIND `torso_layer` (`z < torso`)
    so open V-neck collars show warm shaded neck flesh without EVER deleting or punching holes
    into the collar's own dark ink outlines!
    """
    under_neck = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ud = ImageDraw.Draw(under_neck)
    ud.polygon([
        (85, 134), (129, 134), (132, 182), (83, 182)
    ], fill=(142, 102, 76, 255), outline=(22, 16, 12, 255))
    upx = under_neck.load()
    for y in range(133, 184):
        for x in range(82, 134):
            r, g, b, a = upx[x, y]
            if a > 0:
                # Deep cast shadow directly under chin (`y=134..158`), warming slightly into collar V
                chin_sh = 0.50 + 0.42 * min(1.0, max(0.0, (y - 144) / 32.0))
                side_sh = 0.80 + 0.24 * ((x - 82) / 52.0)
                f = chin_sh * side_sh
                upx[x, y] = (int(r * f), int(g * f), int(b * f), a)
    return Image.alpha_composite(under_neck, torso_layer)


def register_torso_bust(torso_34_right, tmask):
    tc = decontaminate_white_fringe(tight_crop(torso_34_right), passes=1)
    apx = tc.getchannel("A").load()
    sx0, sx1 = tc.width, 0
    for y in range(int(tc.height * 0.08), int(tc.height * 0.42)):
        for x in range(tc.width):
            if apx[x, y] > 80:
                if x < sx0: sx0 = x
                if x > sx1: sx1 = x
    pad_s = int((sx1 - sx0) * 0.08)
    chest = tc.crop((max(0, sx0 - pad_s), 0, min(tc.width, sx1 + pad_s), int(tc.height * 0.56)))
    tw = 188
    th = max(118, min(132, int(round(tw * (chest.height / float(chest.width))))))
    chest_s = bb_grade(chest.resize((tw, th), Image.Resampling.LANCZOS))
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    layer.alpha_composite(chest_s, ((W - tw) // 2, TORSO_BOTTOM_Y - th))
    px = layer.load()
    for y in range(214, 250):
        s = max(0.36, 1.0 - (y - 214) / 52.0)
        for x in range(W):
            r, g, b, a = px[x, y]
            if a > 0: px[x, y] = (int(r * s), int(g * s), int(b * s), a)
    layer.putalpha(ImageChops.multiply(layer.getchannel("A"), tmask))
    return fill_collar_neck_flesh(layer)


def register_head_bust(head_34_right):
    """
    STAGE A (v5 Solid Chin & Anatomical Jawline):
    - NEVER flat-chops chins (`1.12` removed!) and NEVER fades chins to ghostly transparency!
    - Preserves natural oval head height (`82..90px`) so the full chin sits solidly at `y=156..160`,
      boolean-clamped along an anatomical 3/4-right jawline curve `MASTER_JAW_SILHOUETTE` with a
      crisp 1.5px Overhype dark-ink chin contour where any lower neck stump is trimmed!
    """
    hc = decontaminate_white_fringe(tight_crop(head_34_right), passes=1)
    # Detect if raw head sprite has a long neck cylinder below `y=0.78*h`
    raw_h = hc.height
    raw_w = hc.width
    hh = max(82, min(91, int(round(HEAD_W * (raw_h / float(raw_w))))))
    hs = bb_grade(hc.resize((HEAD_W, hh), Image.Resampling.LANCZOS))

    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    layer.alpha_composite(hs, (HEAD_X, SKULL_TOP_Y))

    # Build anatomical Master Head + Solid 3/4-Right Jawline Silhouette (`[69..143, 76..160]`)
    jaw_sil = Image.new("L", (W, H), 0)
    jd = ImageDraw.Draw(jaw_sil)
    jd.ellipse([69, 76, 142, 138], fill=255)
    jd.polygon([
        (73, 122),
        (79, 139),  # left angle of mandible below ear
        (91, 149),  # left jawline
        (107, 157), # chin left curve
        (122, 160), # 3/4-right anatomical chin point (100% solid opaque!)
        (134, 155), # chin right curve
        (141, 144), # right cheek/jaw
        (143, 122),
    ], fill=255)
    jaw_sil_soft = jaw_sil.filter(ImageFilter.GaussianBlur(0.6))

    orig_a = layer.getchannel("A")
    clamped_a = bool_intersect(orig_a, jaw_sil_soft)
    layer.putalpha(clamped_a)

    # Wherever a lower neck stump was trimmed off along the bottom jawline (`y >= 140`),
    # draw a crisp 1.5px Battle Brothers dark-ink chin outline so the chin never looks raw!
    px = layer.load()
    opx = orig_a.load()
    cpx = clamped_a.load()
    for y in range(138, 162):
        for x in range(76, 143):
            if cpx[x, y] > 130:
                trimmed_below = False
                for ny in (y + 1, y + 2):
                    if ny < H and cpx[x, ny] < 70 and opx[x, ny] > 110:
                        trimmed_below = True
                        break
                if trimmed_below:
                    r, g, b, a = px[x, y]
                    px[x, y] = (int(r * 0.28 + 18 * 0.72), int(g * 0.28 + 13 * 0.72), int(b * 0.28 + 10 * 0.72), 255)

    return bake_self_drop_shadow(layer, dx=0, dy=4, blur=3.2, alpha_scale=0.68)


def register_hair_boolean(hair_34_right, aid=""):
    """
    STAGE B: True Boolean Hair Registration + Vertical Crown Compression!
    1. Compress upper hair volume above `forehead_y` by `0.62x` so NO hairstyle ever towers too high!
    2. Paint `MASTER_SCALP_SHELL` in the hair's sampled color so temple/forehead/ear contact is 100% gap-free!
    3. Boolean-subtract `MASTER_FACE_EAR` (`Hair_Final = (MASTER_SCALP_SHELL ∪ Hair) ⊖ MASTER_FACE_EAR`)
       and stroke a crisp 1.5px dark hairline along the boolean cut!
    4. Also output `hair_tucked = Hair_Final ∩ UNDER_BRIM_MASK` for wearing under hats/helmets!
    """
    hr = decontaminate_white_fringe(tight_crop(hair_34_right), passes=1)
    apx = hr.getchannel("A").load()
    w, h = hr.size

    # Find inner face cutout arch `(face_x0, face_x1, forehead_y)`
    arch_ys, face_xs = [], []
    for x in range(int(w * 0.22), int(w * 0.94)):
        saw_hair = False
        for y in range(h):
            if apx[x, y] > 110:
                saw_hair = True
            elif saw_hair and apx[x, y] < 35:
                open_run = sum(1 for yy in range(y, min(h, y + max(10, int(h * 0.24)))) if apx[x, yy] < 45)
                if open_run >= max(7, int(h * 0.15)):
                    arch_ys.append(y); face_xs.append(x)
                break

    # Compress upper hair crown height (`y < forehead_y`) if taller than 32% of total hair height!
    fh_src = sorted(arch_ys)[int(len(arch_ys) * 0.30)] if len(arch_ys) >= 6 else int(h * 0.30)
    if fh_src > int(h * 0.24):
        new_top_h = max(12, int(fh_src * 0.64))  # 36% vertical crown height compression -> tight skull fit!
        top_band = hr.crop((0, 0, w, fh_src)).resize((w, new_top_h), Image.Resampling.LANCZOS)
        bot_band = hr.crop((0, fh_src, w, h))
        comp = Image.new("RGBA", (w, new_top_h + bot_band.height), (0, 0, 0, 0))
        comp.alpha_composite(top_band, (0, 0))
        comp.alpha_composite(bot_band, (0, new_top_h))
        hr = comp
        fh_src = new_top_h
        w, h = hr.size

    if len(face_xs) >= 6:
        face_x0, face_x1 = min(face_xs), max(face_xs)
        detected_face_w = max(int(w * 0.46), face_x1 - face_x0)
        scale = 58.0 / float(detected_face_w)
        has_back_tail = (face_x0 > w * 0.30)
        scale = max((HEAD_W * 1.05) / float(w), min((HEAD_W * (1.26 if has_back_tail else 1.15)) / float(w), scale))
        hrw, hrh = int(round(w * scale)), int(round(h * scale))
        hr_s = decontaminate_white_fringe(bb_grade(hr.resize((hrw, hrh), Image.Resampling.LANCZOS)), passes=1)
        hrx = int(round(142 - face_x1 * scale))
        if hrx + hrw < 143:
            hrx = 143 - hrw
        hry = int(round(92 - fh_src * scale))
        # Hard cap: never let hair rise higher than y=54 (max 22px above SKULL_TOP_Y=76 even for high buns!)
        if hry < 54:
            hry = 54
    else:
        scale = (HEAD_W * 1.12) / float(w)
        hrw, hrh = int(round(w * scale)), int(round(h * scale))
        hr_s = decontaminate_white_fringe(bb_grade(hr.resize((hrw, hrh), Image.Resampling.LANCZOS)), passes=1)
        hrx = 143 - hrw
        hry = SKULL_TOP_Y - 7

    raw_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    raw_layer.alpha_composite(hr_s, (hrx, hry))

    # 1. INWARD-ONLY CONTOUR BRIDGING (`inward_bridge_to_face`):
    #    Instead of pasting a synthetic outer oval dome (which caused grey halos around sleek hairs),
    #    we ONLY extend existing hand-painted hair pixels INWARD across narrow 1..9px gaps inside
    #    `MASTER_SCALP_SHELL` (`[73..143, max(76, hry+4)..131]`) right up to `MASTER_FACE_EAR`!
    if aid not in ("wx_hair_04", "wx_hair_13"):
        snap = raw_layer.copy()
        spx = snap.load()
        rpx = raw_layer.load()
        mpx = MASTER_SCALP_SHELL.load()
        y_lo = max(76, hry + 4)
        y_hi = min(131, hry + hrh - 2)
        for y in range(y_lo, y_hi):
            for x in range(74, 143):
                if mpx[x, y] > 90 and spx[x, y][3] < 210:
                    # Find nearest real hand-painted hair pixel within 9px (searching outward/upward)
                    best_d2 = 999
                    best_rgb = None
                    for dy in range(-8, 7):
                        ny = y + dy
                        if ny < 0 or ny >= H:
                            continue
                        for dx in range(-8, 9):
                            nx = x + dx
                            if 0 <= nx < W:
                                nr, ng, nb, na = spx[nx, ny]
                                if na >= 215:
                                    d2 = dx * dx + dy * dy
                                    if d2 < best_d2:
                                        best_d2 = d2
                                        best_rgb = (nr, ng, nb)
                    if best_rgb is not None and best_d2 <= 72:
                        sh = 0.90
                        rpx[x, y] = (int(best_rgb[0] * sh), int(best_rgb[1] * sh), int(best_rgb[2] * sh), max(spx[x, y][3], mpx[x, y]))

    # 2. BOOLEAN SUBTRACT `MASTER_FACE_EAR`:
    has_forehead_band_or_bangs = aid in ("wx_hair_02", "wx_hair_04", "wx_hair_08", "wx_hair_11", "wx_hair_16", "wx_hair_20", "wx_hair_21", "wx_hair_22", "wx_hair_23", "wx_hair_24")
    if has_forehead_band_or_bangs:
        bang_face_mask = Image.new("L", (W, H), 0)
        bfd = ImageDraw.Draw(bang_face_mask)
        bfd.polygon([
            (95, 103), (146, 103), (150, 125), (144, 156), (98, 158),
            (89, 142), (87, 130), (80, 129), (76, 124), (76, 113), (82, 108), (87, 110), (89, 116), (93, 112)
        ], fill=255)
        cut_m = bang_face_mask.filter(ImageFilter.GaussianBlur(0.8))
    else:
        cut_m = MASTER_FACE_EAR

    final_a = bool_subtract(raw_layer.getchannel("A"), cut_m)
    raw_layer.putalpha(final_a)
    full_hair = stroke_boolean_cut_edge(raw_layer, cut_m, max_y=124)
    full_hair_baked = bake_self_drop_shadow(full_hair, dx=-1, dy=2, blur=2.0, alpha_scale=0.45)

    # 3. BOOLEAN INTERSECT `tucked_hair = full_hair ∩ UNDER_BRIM_MASK` (for wearing under closed hats/helmets!)
    tucked = full_hair.copy()
    tucked.putalpha(bool_intersect(full_hair.getchannel("A"), UNDER_BRIM_MASK))
    tucked_baked = bake_self_drop_shadow(tucked, dx=-1, dy=2, blur=1.8, alpha_scale=0.40)

    return full_hair_baked, tucked_baked


def register_hat_boolean(hat_34_right, hat_id):
    """
    STAGE C (v5 True 3D Ring-Split & Cheek-Guard De-Clipping):
    1. Hollow Ring Headbands (`wx_hat_12, 13, 16, 21, 22`):
       - Splits upper/rear inner arc of the ellipse into `hat_back` (`z < head`) and lower/front brow-band
         into `hat_front` (`z > hair`), seated right across `y=89..101` so head & hair rise THROUGH the ring!
    2. Topknot Crown (`wx_hat_14`): crowns top of skull (`y=62..91`) with zero forehead overlap!
    3. Conical / Wide-Brim Hats (`wx_hat_02, 03, 07, 25, 26`):
       - Keeps 100% of conical roof & side wings solid in `hat_front` (`y <= 101` + `x < 85, x > 144`),
         moving ONLY inner underside `[85..144, y > 101]` to `hat_back` so zero bald skull ever pokes through!
    4. Hoods, Turbans & Cheek-Guard War Helmets (`wx_hat_01, 04, 11, 19, 20, 24, 27, 28, 30, 31, 32`):
       - Uses `MASTER_HELM_FACE_WIN` (`[102..146, 101..210]`) so left steel cheek-guards (`x <= 101`) remain
         100% solid in `hat_front` IN FRONT OF beard sideburns, while eyes, nose, mouth & front beard are 100% open!
    """
    ht = decontaminate_white_fringe(tight_crop(hat_34_right), passes=1)
    is_conical_brim = hat_id in ("wx_hat_02", "wx_hat_03", "wx_hat_07", "wx_hat_25", "wx_hat_26")
    is_ring_band = hat_id in ("wx_hat_12", "wx_hat_13", "wx_hat_16", "wx_hat_21", "wx_hat_22")
    is_upright_crown = hat_id in ("wx_hat_05", "wx_hat_06", "wx_hat_09", "wx_hat_10", "wx_hat_15")

    if hat_id == "wx_hat_14":       # Topknot cuff + jade hairpin
        htw = 56
    elif hat_id == "wx_hat_05":     # Six-panel melon skullcap (snug skull width!)
        htw = 80
    elif hat_id == "wx_hat_17":     # Lower-jaw iron Oni half-mask (snug to jaw, zero floating straps!)
        htw = 66
    elif hat_id == "wx_hat_18":     # Hooded bronze Nuo mask + dark cloth cowl
        htw = 98
    elif hat_id == "wx_hat_12":     # Blue headband with left fluttering tails
        htw = 92
    elif is_ring_band:              # Pure hollow forehead ring
        htw = 78
    elif hat_id == "wx_hat_15":     # Miao silver crescent-horn headband crown
        htw = 86
    elif hat_id == "wx_hat_26":     # Iron kettle hat with hanging chinstrap
        htw = 112
    elif is_conical_brim:
        htw = 116
    elif is_upright_crown:
        htw = 98
    else:
        htw = 102

    hth = min(108, max(16, int(round(htw * (ht.height / float(ht.width))))))
    ht_s = decontaminate_white_fringe(bb_grade(ht.resize((htw, hth), Image.Resampling.LANCZOS)), passes=1)

    placed = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    if hat_id == "wx_hat_14":
        htx = HEAD_X + 6
        hty = 57
    elif hat_id == "wx_hat_12":
        htx = HEAD_X + HEAD_W - htw + 3  # Right brow aligned to x=149, left tails flutter behind x=57..72!
        hty = 102 - int(hth * 0.46)
    elif is_ring_band:
        htx = HEAD_X - 1
        hty = (102 - int(hth * 0.82)) if hat_id == "wx_hat_22" else (102 - int(hth * 0.90))
    elif hat_id == "wx_hat_15":
        htx = HEAD_X + HEAD_W // 2 - htw // 2 + 1
        hty = 102 - int(hth * 0.74)  # Front silver brow-band (`0.61..0.73*hth`) sits squarely across forehead `y=89..101`!
    elif hat_id == "wx_hat_17":
        htx = HEAD_X + HEAD_W - htw + 1  # Snug [78..144] jaw lock!
        hty = 161 - hth
    elif hat_id == "wx_hat_18":
        htx = HEAD_X + HEAD_W // 2 - htw // 2 + 1
        hty = 69
    elif hat_id == "wx_hat_05":
        htx = HEAD_X - 2
        hty = 102 - int(hth * 0.63)  # Forehead rim (`0.626*hth`) hugs brow at y=102 while left flap wraps temple!
    elif is_conical_brim:
        htx = HEAD_X + HEAD_W // 2 - htw // 2 + 2
        # Seat conical hats so front brim edge crosses forehead at y=100..102!
        if hat_id == "wx_hat_26":
            hty = 103 - int(hth * 0.54)  # Iron kettle brim is at `0.532*hth` above hanging chinstrap!
        elif hat_id == "wx_hat_03":
            hty = 103 - int(hth * 0.76)
        else:
            hty = 105 - int(hth * 0.80)
    elif is_upright_crown:
        htx = HEAD_X + HEAD_W // 2 - htw // 2 + 1
        hty = 103 - hth if hat_id != "wx_hat_06" else (SKULL_TOP_Y - 14)
    else:
        htx = HEAD_X + HEAD_W // 2 - htw // 2 + 1
        hty = SKULL_TOP_Y - max(12, int(hth * 0.27))

    placed.alpha_composite(ht_s, (htx, hty))

    # Build `hat_back` (`z < head`) and `cut_win` (`hat_front = placed ⊖ cut_win`) by exact 3D topology!
    back_zone = Image.new("L", (W, H), 0)
    bzd = ImageDraw.Draw(back_zone)
    cut_win = Image.new("L", (W, H), 0)
    cwd = ImageDraw.Draw(cut_win)

    if is_ring_band:
        # Erase the tilted rear inner wall of the 3/4 ring (`[75..146, hty .. mid_y]`) so ONLY the crisp
        # front forehead band wraps across `y=88..102` and hair/skull rise naturally out of the top!
        if hat_id == "wx_hat_12":
            mid_y = hty + int(hth * 0.21)
            cwd.rectangle([76, hty, 150, mid_y], fill=255)
        elif hat_id == "wx_hat_21":
            mid_y = hty + int(hth * 0.57)
            cwd.rectangle([60, hty, 160, mid_y], fill=255)
        else:
            mid_y = hty + int(hth * 0.51)
            cwd.rectangle([60, hty, 160, mid_y], fill=255)
        # Also guarantee nothing covers eyes below y=102 on `[92..150]`
        cwd.rectangle([92, 103, 150, 180], fill=255)
        cut_win = cut_win.filter(ImageFilter.GaussianBlur(0.8))
    elif hat_id == "wx_hat_14":
        # Topknot crown sits cleanly on top of hair bun (`y=57..92`, `z > hair`), zero forehead overlap!
        cwd.rectangle([90, 95, 150, 180], fill=255)
    elif hat_id == "wx_hat_15":
        # Miao silver crown: erase rear inner dark strap `[89..133, 0.36*hth .. 0.56*hth]` while keeping
        # outer silver crescent horns (`x < 89` & `x > 133`), front silver brow-band (`y=89..101`), and side chains!
        cwd.rectangle([89, hty + int(hth * 0.36), 133, hty + int(hth * 0.56)], fill=255)
        cwd.rectangle([90, 103, 143, 180], fill=255)
        cut_win = cut_win.filter(ImageFilter.GaussianBlur(0.9))
    elif is_conical_brim:
        # Keep 100% of conical roof (`y <= 101`) & side wings (`x < 85, x > 144`) in `hat_front`,
        # move ONLY inner underside `[85..144, y > 101]` behind `head` into `hat_back`!
        bzd.rectangle([0, 98, W, H], fill=255)
        cwd.polygon([(86, 102), (145, 101), (148, 175), (82, 175)], fill=255)
        cut_win = cut_win.filter(ImageFilter.GaussianBlur(1.1))
    elif hat_id == "wx_hat_17":
        # Lower-jaw iron Oni mask: clear forehead & eyes (`y <= 118`) so eyes & hair are 100% open!
        cwd.rectangle([70, 50, 155, 118], fill=255)
        cut_win = cut_win.filter(ImageFilter.GaussianBlur(0.9))
    elif hat_id == "wx_hat_08":
        # Masked assassin hood: boolean eye-slit `[98..144, 103..119]`!
        bzd.rectangle([0, 98, W, H], fill=255)
        cwd.polygon([(98, 103), (144, 102), (145, 119), (98, 119)], fill=255)
        cut_win = cut_win.filter(ImageFilter.GaussianBlur(1.0))
    elif hat_id in ("wx_hat_18", "wx_hat_23", "wx_hat_29"):
        # True full-face armored masks (with hooded cowl on wx_hat_18): keep mask 100% intact!
        bzd.rectangle([0, 98, W, H], fill=255)
    elif is_upright_crown:
        bzd.rectangle([0, 96, W, H], fill=255)
        cwd.polygon([(92, 102), (148, 101), (150, 185), (90, 185)], fill=255)
        cut_win = cut_win.filter(ImageFilter.GaussianBlur(1.0))
    else:
        # Hoods, turbans & cheek-guard war helmets: keep left cheek-guard `x <= 101` intact in `hat_front`!
        bzd.rectangle([0, 98, W, H], fill=255)
        cut_win = MASTER_HELM_FACE_WIN

    hat_back = placed.copy()
    hb_rgb = ImageEnhance.Brightness(hat_back.convert("RGB")).enhance(0.66)
    hat_back = Image.merge("RGBA", (*hb_rgb.split(), bool_intersect(placed.getchannel("A"), back_zone)))

    hat_front = placed.copy()
    front_a = bool_subtract(placed.getchannel("A"), cut_win)
    hat_front.putalpha(front_a)
    hat_front = stroke_boolean_cut_edge(hat_front, cut_win, max_y=162)
    hat_front_baked = bake_self_drop_shadow(hat_front, dx=0, dy=3, blur=2.6, alpha_scale=0.54)

    comb = Image.alpha_composite(hat_back, hat_front_baked)
    return hat_back, hat_front_baked, comb


def clean_beard_stubble(bd_im):
    out = decontaminate_white_fringe(bd_im.copy(), passes=1)
    px = out.load(); bw, bh = out.size
    for y in range(bh):
        for x in range(bw):
            r, g, b, a = px[x, y]
            if a > 0 and min(r, g, b) > 205 and (max(r, g, b) - min(r, g, b)) < 18:
                px[x, y] = (r, g, b, 0)
    return out


def recolor_hair_tone(rgba, tone="black"):
    if tone == "black": return rgba
    out = rgba.copy(); px = out.load(); w, h = out.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a > 15:
                lum = 0.299 * r + 0.587 * g + 0.114 * b
                if lum < 22: continue
                if tone == "brown": nr, ng, nb = min(255, int(lum * 1.18 + 26)), min(255, int(lum * 0.88 + 14)), min(255, int(lum * 0.62 + 6))
                elif tone == "grey": nl = min(225, int(lum * 1.40 + 44)); nr, ng, nb = nl, nl, int(nl * 0.97)
                elif tone == "white": nl = min(236, int(lum * 1.58 + 78)); nr, ng, nb = nl, int(nl * 0.99), int(nl * 0.95)
                elif tone == "russet": nr, ng, nb = min(255, int(lum * 1.30 + 34)), min(255, int(lum * 0.78 + 12)), min(255, int(lum * 0.54 + 6))
                else: nr, ng, nb = r, g, b
                px[x, y] = (nr, ng, nb, a)
    return decontaminate_white_fringe(out, passes=1)


# Build Boolean Eye + Nose-Bridge Protection Mask (`BEARD_EYE_NOSE_GUARD`):
# Protects 100% of forehead, eyebrows, eyes, upper cheekbones & nose bridge (`y <= 129` on `[92..152]`)
# so ZERO beard pixel can EVER touch an eye or nose!
def _build_beard_eye_nose_guard():
    m = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(m)
    d.polygon([
        (92, 60), (154, 60), (154, 129), (136, 130), (125, 130), (112, 130), (96, 125)
    ], fill=255)
    return m.filter(ImageFilter.GaussianBlur(0.8))

BEARD_EYE_NOSE_GUARD = _build_beard_eye_nose_guard()


def clear_enclosed_mouth_window(rgba, is_snow_white=False):
    """
    Clears enclosed studio-white mouth openings strictly inside the central mouth box
    `[0.24*w .. 0.90*w, 0.08*h .. 0.70*h]` without ever touching snow-white outer beard braids
    or bright skin highlights on faces!
    """
    out = tight_crop(rgba)
    cw, ch = out.size
    rpx = out.load()
    hvis = bytearray(cw * ch)
    min_seed = 249 if is_snow_white else 235
    min_grow = 244 if is_snow_white else 224
    min_mean = 251.0 if is_snow_white else 239.0
    max_sat = 6 if is_snow_white else 14
    x_lo, x_hi = int(cw * 0.24), int(cw * 0.90)
    y_lo, y_hi = int(ch * 0.08), int(ch * 0.70)
    for y in range(max(1, y_lo), min(ch - 1, y_hi)):
        for x in range(max(1, x_lo), min(cw - 1, x_hi)):
            idx = y * cw + x
            if not hvis[idx] and rpx[x, y][3] > 160:
                r0, g0, b0, _ = rpx[x, y]
                if min(r0, g0, b0) >= min_seed and (max(r0, g0, b0) - min(r0, g0, b0)) <= max_sat:
                    hvis[idx] = 1
                    hq = deque([(x, y)])
                    pts = [(x, y)]
                    slum = (r0 + g0 + b0) / 3.0
                    in_box = True
                    while hq:
                        hx, hy = hq.popleft()
                        if hx < x_lo or hx > x_hi or hy < y_lo or hy > y_hi:
                            in_box = False
                        for nx, ny in ((hx - 1, hy), (hx + 1, hy), (hx, hy - 1), (hx, hy + 1)):
                            if 0 <= nx < cw and 0 <= ny < ch:
                                nidx = ny * cw + nx
                                if not hvis[nidx] and rpx[nx, ny][3] > 140:
                                    nr, ng, nb, _ = rpx[nx, ny]
                                    if min(nr, ng, nb) >= min_grow and (max(nr, ng, nb) - min(nr, ng, nb)) <= max_sat:
                                        hvis[nidx] = 1; hq.append((nx, ny)); pts.append((nx, ny))
                                        slum += (nr + ng + nb) / 3.0
                    if in_box and len(pts) >= 10 and (slum / len(pts)) >= min_mean:
                        for (kx, ky) in pts:
                            rpx[kx, ky] = (0, 0, 0, 0)
    return decontaminate_white_fringe(out, passes=1)


def register_beard_bust(beard_34_right, kind="auto"):
    """
    STAGE D (v5 Anatomical Upper-Lip / Chin Landmark Lock + Boolean Eye/Nose Guard):
    - Canonical Master Head mouth center = `x=123`, upper lip (`人中/上唇`) = `y=131`, chin = `y=142..160`.
    - Automatically detects the mustache arch `mustache_y` inside `[0.52*w .. 0.78*w]` so tall left
      sideburns NEVER push the mustache up onto the nose/eyes!
    - Boolean-subtracts `BEARD_EYE_NOSE_GUARD` so eyes & nose remain 100% untouched!
    """
    bd = decontaminate_white_fringe(tight_crop(beard_34_right), passes=1)
    w, h = bd.size
    apx = bd.getchannel("A").load()

    if kind == "goatee":
        bw = 30
        bh = max(18, int(round(bw * (h / float(w)))))
        bd_s = decontaminate_white_fringe(bb_grade(bd.resize((bw, bh), Image.Resampling.LANCZOS)), passes=1)
        bx = 123 - bw // 2
        by = 142
    elif kind == "mustache":
        bw = 44
        bh = max(14, int(round(bw * (h / float(w)))))
        bd_s = decontaminate_white_fringe(bb_grade(bd.resize((bw, bh), Image.Resampling.LANCZOS)), passes=1)
        bx = 123 - bw // 2
        by = 130
    else:
        # Measure top of mustache arch in `[0.50*w .. 0.78*w]` vs left sideburn height in `[0.04*w .. 0.28*w]`
        m_ys = []
        for x in range(int(w * 0.50), max(int(w * 0.50) + 1, int(w * 0.78))):
            for y in range(h):
                if apx[x, y] > 110:
                    m_ys.append(y)
                    break
        sb_ys = []
        for x in range(int(w * 0.04), max(int(w * 0.04) + 1, int(w * 0.28))):
            for y in range(h):
                if apx[x, y] > 110:
                    sb_ys.append(y)
                    break

        mustache_src_y = sorted(m_ys)[len(m_ys) // 2] if m_ys else int(h * 0.15)
        sb_src_y = min(sb_ys) if sb_ys else mustache_src_y
        has_sideburns = (mustache_src_y - sb_src_y) > (h * 0.08) or kind == "full"

        if kind == "mustache_goatee" or (not has_sideburns and kind == "auto"):
            bw = 46
            scale = bw / float(w)
            bh = max(22, int(round(h * scale)))
            bd_s = decontaminate_white_fringe(bb_grade(bd.resize((bw, bh), Image.Resampling.LANCZOS)), passes=1)
            bx = 123 - int(bw * 0.52)
            by = int(round(131 - mustache_src_y * scale))
        else:
            bw = 59
            scale = bw / float(w)
            bh = max(26, int(round(h * scale)))
            bd_s = decontaminate_white_fringe(bb_grade(bd.resize((bw, bh), Image.Resampling.LANCZOS)), passes=1)
            bx = 85  # Sideburn root in front of ear `x=85` -> right cheek `x=144`!
            by = max(116, min(131, int(round(131 - mustache_src_y * scale))))

    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    layer.alpha_composite(bd_s, (bx, by))
    # Boolean-subtract `BEARD_EYE_NOSE_GUARD` so eyes & nose bridge are 100% protected!
    layer.putalpha(bool_subtract(layer.getchannel("A"), BEARD_EYE_NOSE_GUARD))
    return bake_self_drop_shadow(layer, dx=0, dy=2, blur=2.0, alpha_scale=0.45)


def make_12_battle_scars():
    scars = []
    def new_scar(): return Image.new("RGBA", (W, H), (0, 0, 0, 0))
    s1 = new_scar(); d = ImageDraw.Draw(s1)
    d.line([(95, 123), (115, 117), (134, 120)], fill=(96, 34, 28, 215), width=2)
    scars.append(("wx_scar_01", "横鼻破相刀疤", "刀剑横掠鼻梁留下的缝合陈年旧疤", s1.filter(ImageFilter.GaussianBlur(0.3))))
    s2 = new_scar(); d = ImageDraw.Draw(s2)
    d.line([(105, 97), (106, 112), (104, 132)], fill=(92, 30, 26, 220), width=2)
    scars.append(("wx_scar_02", "贯眉纵目剑痕", "自额角直贯眼睑面颊的惊险剑伤", s2.filter(ImageFilter.GaussianBlur(0.3))))
    s3 = new_scar(); d = ImageDraw.Draw(s3)
    d.line([(92, 117), (108, 132)], fill=(98, 34, 28, 210), width=2)
    d.line([(107, 117), (93, 131)], fill=(98, 34, 28, 210), width=2)
    scars.append(("wx_scar_03", "左颊十字剑疤", "江湖死斗留于面颊的十字交剑旧痕", s3.filter(ImageFilter.GaussianBlur(0.3))))
    s4 = new_scar(); d = ImageDraw.Draw(s4)
    d.line([(78, 104), (138, 116)], fill=(18, 15, 13, 245), width=3)
    d.polygon([(98, 106), (115, 107), (114, 119), (104, 121), (97, 116)], fill=(32, 27, 23, 255), outline=(12, 10, 8, 255))
    scars.append(("wx_scar_04", "黑革独眼皮罩", "熟牛皮缝制斜系脑后的百战独眼罩", s4))
    s5 = new_scar(); d = ImageDraw.Draw(s5)
    d.polygon([(76, 107), (140, 106), (139, 119), (112, 121), (77, 117)], fill=(36, 33, 31, 250), outline=(12, 10, 9, 255))
    scars.append(("wx_scar_05", "听风玄布蒙眼带", "双目失明或专修听风辨器绝技的蒙目黑绸", s5))
    s6 = new_scar(); d = ImageDraw.Draw(s6)
    d.rectangle([98, 95, 108, 103], outline=(38, 56, 64, 185), width=2)
    scars.append(("wx_scar_06", "刺配青印黥纹", "官府发配边军或黑道死士刺于额角的青墨印记", s6.filter(ImageFilter.GaussianBlur(0.4))))
    s7 = new_scar(); d = ImageDraw.Draw(s7)
    d.ellipse([88, 102, 116, 136], fill=(122, 44, 34, 115))
    scars.append(("wx_scar_07", "火药焦灼赤疤", "神机火器或丹炉炸裂灼伤半面的暗红火疤", s7.filter(ImageFilter.GaussianBlur(1.8))))
    s8 = new_scar(); d = ImageDraw.Draw(s8)
    d.polygon([(120, 98), (122, 104), (120, 109), (118, 104)], fill=(168, 32, 26, 225))
    scars.append(("wx_scar_08", "眉心朱砂剑印", "内家宗门或刀马旦点于眉心的朱砂丹印", s8.filter(ImageFilter.GaussianBlur(0.25))))
    s9 = new_scar(); d = ImageDraw.Draw(s9)
    d.line([(80, 112), (99, 112)], fill=(112, 88, 46, 240), width=2)
    d.ellipse([99, 106, 115, 120], fill=(185, 205, 210, 50), outline=(128, 100, 52, 245), width=2)
    d.ellipse([122, 106, 137, 120], fill=(185, 205, 210, 50), outline=(128, 100, 52, 245), width=2)
    d.line([(115, 112), (122, 112)], fill=(128, 100, 52, 245), width=2)
    scars.append(("wx_scar_09", "西洋铜框圆目镜", "账房神算子与机关奇人鼻梁所架黄铜水晶圆镜", s9))
    s10 = new_scar(); d = ImageDraw.Draw(s10)
    d.line([(91, 108), (99, 117), (96, 129), (104, 137)], fill=(72, 36, 88, 185), width=2)
    scars.append(("wx_scar_10", "南疆噬脉青蛊纹", "常年修炼毒功浮现于面颊太阳穴的妖异紫青毒脉", s10.filter(ImageFilter.GaussianBlur(0.45))))
    s11 = new_scar(); d = ImageDraw.Draw(s11)
    for yy in (120, 125):
        d.line([(92, yy), (114, yy - 1)], fill=(138, 28, 22, 175), width=2)
        d.line([(125, yy), (138, yy + 1)], fill=(138, 28, 22, 175), width=2)
    scars.append(("wx_scar_11", "朔漠血战涂面纹", "塞外战帮临阵以兽血横抹双颊的凶悍战纹", s11.filter(ImageFilter.GaussianBlur(0.5))))
    s12 = new_scar(); d = ImageDraw.Draw(s12)
    d.line([(98, 129), (114, 136)], fill=(88, 28, 24, 215), width=2)
    scars.append(("wx_scar_12", "裂口横腮凶疤", "重兵铁锏擦过嘴角撕裂至腮帮的狰狞悍疤", s12.filter(ImageFilter.GaussianBlur(0.3))))
    return scars


def build_sculpted_beard_cuts(base_beards_right):
    b1, b2, b3, b4, b5, b6, b7, b8 = [decontaminate_white_fringe(tight_crop(b), passes=1) for b in base_beards_right]
    def crop_frac(im, x0f, y0f, x1f, y1f, feather_bottom=False):
        w, h = im.size
        sub = im.crop((int(w * x0f), int(h * y0f), int(w * x1f), int(h * y1f))).copy()
        if feather_bottom:
            sw, sh = sub.size; apx = sub.getchannel("A").load(); na = Image.new("L", (sw, sh), 0); napx = na.load()
            for y in range(sh):
                fade = min(1.0, (sh - 1 - y) / max(1.0, sh * 0.22)) if y > sh * 0.78 else 1.0
                for x in range(sw): napx[x, y] = int(apx[x, y] * fade)
            sub.putalpha(na)
        return sub
    def mask_center_chin(im):
        out = im.copy(); w, h = out.size; a = out.getchannel("A")
        ImageDraw.Draw(a).ellipse([int(w * 0.25), int(h * 0.56), int(w * 0.98), int(h * 1.15)], fill=0)
        out.putalpha(a.filter(ImageFilter.GaussianBlur(0.8))); return out
    def mask_left_sideburn(im):
        out = im.copy(); w, h = out.size; a = out.getchannel("A")
        ImageDraw.Draw(a).rectangle([0, 0, int(w * 0.36), h], fill=0)
        out.putalpha(a.filter(ImageFilter.GaussianBlur(0.8))); return out
    def arch_mustache(im, arch_top=0.42):
        out = im.copy(); w, h = out.size; a = out.getchannel("A"); ad = ImageDraw.Draw(a)
        ad.rectangle([0, 0, int(w * 0.26), h], fill=0)
        ad.ellipse([int(w * 0.34), int(h * arch_top), int(w * 0.94), int(h * 1.25)], fill=0)
        ad.rectangle([0, int(h * 0.68), w, h], fill=0)
        out.putalpha(a.filter(ImageFilter.GaussianBlur(1.2))); return tight_crop(out)

    return [
        ("wx_beard_09", "燕尾上挑飞扬髭", "模块化胡须 09 · 风流快刀髭", "唇上两端潇洒上翘如飞燕掠空的豪侠八字胡。", arch_mustache(b2, 0.38), 9, 0.70),
        ("wx_beard_10", "垂颔鲶鱼八字髭", "模块化胡须 10 · 老辣江湖髭", "修长顺滑沿嘴角两侧垂过下颌的名宿长八字髭。", mask_left_sideburn(crop_frac(b3, 0.0, 0.0, 1.0, 0.68, True)), 9, 0.70),
        ("wx_beard_11", "西域浓密一字髭", "模块化胡须 11 · 刚猛横练髭", "横亘上唇浓密厚重的一字黑胡，不留长髯更显悍勇。", arch_mustache(b4, 0.40), 10, 0.68),
        ("wx_beard_12", "银丝仙风八字髭", "模块化胡须 12 · 白发老剑客", "霜雪银丝般轻垂嘴角的清癯老宗师八字长髭。", arch_mustache(b5, 0.42), 9, 0.72),
        ("wx_beard_13", "精干寸长山羊须", "模块化胡须 13 · 奇门智士须", "两腮净刮、仅于下巴尖留一撮精干山羊短须。", tight_crop(mask_left_sideburn(b3)), 9, 0.66),
        ("wx_beard_14", "文士齐整短三绺", "模块化胡须 14 · 儒剑掌门须", "修剪齐整不拖泥带水的中年儒侠短款三绺美髯。", crop_frac(b1, 0.0, 0.0, 1.0, 0.68, True), 1, 0.88),
        ("wx_beard_15", "捕头威严短满髯", "模块化胡须 15 · 官府铁捕髯", "包裹下颌棱角分明的短款浓密满腮胡。", crop_frac(b4, 0.0, 0.08, 1.0, 0.84, True), 1, 0.88),
        ("wx_beard_16", "鲁达赤褐花和尚须", "模块化胡须 16 · 狂僧烈火髯", "天生微带赤铜虎毛色泽的怒张连鬓虬髯，烈火性情！", recolor_hair_tone(b2, "russet"), 0, 0.92),
        ("wx_beard_17", "椒盐斑白百战须", "模块化胡须 17 · 退伍老兵髯", "黑白交杂如霜雪初落的沙场老卒浓密络腮须。", recolor_hair_tone(b4, "grey"), 0, 0.90),
        ("wx_beard_18", "塞外单束铜环辫须", "模块化胡须 18 · 朔漠骑射须", "刮净两腮、仅将下巴浓须编为一股铜箍战辫。", tight_crop(mask_left_sideburn(b6)), 8, 0.70),
        ("wx_beard_19", "焦褐卷曲火铳须", "模块化胡须 19 · 神机营悍卒", "硝烟火药熏烤呈深褐色的短硬络腮胡茬。", recolor_hair_tone(b7, "brown"), 1, 0.86),
        ("wx_beard_20", "霜白硬刺老胡茬", "模块化胡须 20 · 独行老刀客", "下巴与唇周布满银白钢针般硬胡茬，沧桑冷冽。", recolor_hair_tone(b7, "white"), 1, 0.86),
        ("wx_beard_21", "刀痕断截残缺髯", "模块化胡须 21 · 破相悍匪须", "曾被利刃削去下颌半截胡须、参差凶悍的绿林残髯。", mask_center_chin(b2), 0, 0.90),
        ("wx_beard_22", "苍灰三绺宗师髯", "模块化胡须 22 · 名门太上长老", "铁灰苍劲垂落胸前的武林宿老长髯。", recolor_hair_tone(b1, "grey"), 0, 0.90),
        ("wx_beard_23", "赤褐钢针恶虎鬓", "模块化胡须 23 · 关外猛士鬓", "下巴净刮而两侧腮帮怒立赤褐钢针鬓须。", recolor_hair_tone(b8, "russet"), 1, 0.90),
        ("wx_beard_24", "百岁垂胸纯白雪髯", "模块化胡须 24 · 绝顶陆地神仙", "皓白如昆仑积雪、顺垂胸前的百岁老神仙大长髯。", recolor_hair_tone(b1, "white"), 0, 0.92),
    ]


def save_catalog_pair(rgba_right, aid, game_rel, game_sz=128):
    tc = decontaminate_white_fringe(tight_crop(rgba_right), passes=1)
    def fit(sz, pad):
        mw = sz - 2 * pad
        s = min(mw / float(tc.width), mw / float(tc.height))
        nw, nh = max(1, int(round(tc.width * s))), max(1, int(round(tc.height * s)))
        im = tc.resize((nw, nh), Image.Resampling.LANCZOS)
        out = Image.new("RGBA", (sz, sz), (0, 0, 0, 0))
        out.alpha_composite(im, ((sz - nw) // 2, (sz - nh) // 2))
        return out
    hd_rel = f"art/hd/{aid}.png"
    fit(256, 16).save(os.path.join(ROOT, hd_rel))
    g_abs = os.path.join(ROOT, "art/game", game_rel)
    os.makedirs(os.path.dirname(g_abs), exist_ok=True)
    fit(game_sz, 6).save(g_abs)
    return hd_rel, f"art/game/{game_rel}"


def main():
    ensure_bust_dirs()
    ped_back, ped_front, ped_tmask = make_pedestal_layers()
    ped_back.save(os.path.join(BUSTS_DIR, "pedestal_back.png"))
    ped_front.save(os.path.join(BUSTS_DIR, "pedestal_front.png"))

    manifest_path = os.path.join(ART_DIR, "manifest.json")
    manifest = json.load(open(manifest_path, "r", encoding="utf-8"))
    new_id_prefixes = tuple(
        [f"wx_head_{i:02d}" for i in range(17, 49)] +
        [f"wx_hair_{i:02d}" for i in range(9, 25)] +
        [f"wx_beard_{i:02d}" for i in range(9, 25)] +
        [f"wx_scar_{i:02d}" for i in range(1, 13)]
    )
    assets = [a for a in manifest["assets"] if a["id"] not in new_id_prefixes]
    by_id = {a["id"]: a for a in assets}

    # Copy Sheet 47 (16 standalone 3/4-right beards) & Sheet 48 (16 mannequin-free 3/4-right hats) if newly generated
    import shutil
    brain_dir = r"C:\Users\25647\.gemini\antigravity\brain\fa3a61d2-2588-454a-a04d-cca189377964"
    raw_47 = os.path.join(brain_dir, "wuxia_beards_spritesheet_v3_1795175784433.jpg")
    raw_48 = os.path.join(brain_dir, "wuxia_headgear_spritesheet_4x4_final_1795175679455.jpg")
    if os.path.exists(raw_47):
        shutil.copy2(raw_47, os.path.join(SHEETS_DIR, "sheet_47.jpg"))
    if os.path.exists(raw_48):
        shutil.copy2(raw_48, os.path.join(SHEETS_DIR, "sheet_48.jpg"))

    s47 = Image.open(os.path.join(SHEETS_DIR, "sheet_47.jpg"))
    cw47, ch47 = s47.width // 4, s47.height // 4
    s48 = Image.open(os.path.join(SHEETS_DIR, "sheet_48.jpg"))
    cw48, ch48 = s48.width // 4, s48.height // 4

    # 1. Sheet 26 Hairs (`wx_hair_01..08`) & Beards (`wx_beard_01..08`) -> Boolean Hair + Landmark Beard!
    s26 = Image.open(os.path.join(SHEETS_DIR, "sheet_26.jpg"))
    cw26, ch26 = s26.width // 4, s26.height // 4
    for i in range(8):
        r, c = divmod(i, 4)
        hr_clean = flood_white_bg(s26.crop((c * cw26, r * ch26, (c + 1) * cw26, (r + 1) * ch26)))
        aid = f"wx_hair_{i + 1:02d}"
        save_catalog_pair(ImageOps.mirror(hr_clean), aid, f"entity/bodies/{aid}.png", 128)
        full_h, tuck_h = register_hair_boolean(hr_clean, aid)
        full_h.save(os.path.join(ROOT, f"art/busts/hair/{aid}.png"))
        tuck_h.save(os.path.join(ROOT, f"art/busts/hair_tucked/{aid}.png"))
        by_id[aid]["bustPath"] = f"art/busts/hair/{aid}.png"
        by_id[aid]["bustTuckedPath"] = f"art/busts/hair_tucked/{aid}.png"
        by_id[aid]["group"] = "千人千面 · 模块化发式（24款）"

    for i in range(8, 16):
        r, c = divmod(i, 4)
        bd_idx = i - 7  # 1..8
        if bd_idx == 3:
            # Replace spider-eye `B03` with russet-brown tone of Sheet 47 cell 5 (three-strand master beard)!
            r47, c47 = divmod(5, 4)
            bd_clean = recolor_hair_tone(clear_enclosed_mouth_window(flood_white_bg(s47.crop((c47 * cw47, r47 * ch47, (c47 + 1) * cw47, (r47 + 1) * ch47)))), "russet")
        else:
            bd_clean = clear_enclosed_mouth_window(flood_white_bg(s26.crop((c * cw26, r * ch26, (c + 1) * cw26, (r + 1) * ch26))), is_snow_white=(bd_idx == 5))
        aid = f"wx_beard_{bd_idx:02d}"
        save_catalog_pair(ImageOps.mirror(bd_clean), aid, f"entity/bodies/{aid}.png", 128)
        b_kind = "mustache_goatee" if bd_idx in (1, 5) else "full"
        register_beard_bust(bd_clean, kind=b_kind).save(os.path.join(ROOT, f"art/busts/beard/{aid}.png"))
        by_id[aid]["bustPath"] = f"art/busts/beard/{aid}.png"
        by_id[aid]["group"] = "千人千面 · 模块化胡须（24款）"

    # 2. All Robes & Armors -> Heroic 188px shoulder busts!
    for a in assets:
        if a["slotKind"] == "armor140":
            aid = a["id"]
            src_im = Image.open(os.path.join(ROOT, a["hdPath"])).convert("RGBA")
            right_im = ImageOps.mirror(src_im) if aid.startswith("wx_body_") else src_im
            b_rel = f"art/busts/body/{aid}.png"
            register_torso_bust(right_im, ped_tmask).save(os.path.join(ROOT, b_rel))
            if aid.startswith("wx_body_"):
                a["pdRole"] = "torso"
                a["bustPath"] = b_rel

    # 3. All 48 Heads (`wx_head_01..48`) normalized to `MASTER_SKULL`!
    for i in range(1, 17):
        aid = f"wx_head_{i:02d}"
        a = by_id[aid]
        src_left = Image.open(os.path.join(ROOT, a["hdPath"])).convert("RGBA")
        b_rel = f"art/busts/head/{aid}.png"
        register_head_bust(ImageOps.mirror(src_left)).save(os.path.join(ROOT, b_rel))
        a["bustPath"] = b_rel
        a["pdGender"] = "m"
        a["group"] = "千人千面 · 东方面孔基底（48款）"

    s34 = Image.open(os.path.join(SHEETS_DIR, "sheet_34.jpg"))
    s37 = Image.open(os.path.join(SHEETS_DIR, "sheet_37.jpg"))
    s38 = Image.open(os.path.join(SHEETS_DIR, "sheet_38.jpg"))

    s34_defs = [
        ("圆脸讨喜店伴面", "青年市井 · 面孔 17", "圆头圆脑、眉眼带笑讨喜的酒楼小厮与少年学徒面庞。"),
        ("浓眉虎目武生面", "青年少侠 · 面孔 18", "剑眉斜飞入鬓、虎目炯炯有神的武馆高徒面庞。"),
        ("高鼻深目西域面", "丝路青年 · 面孔 19", "琥珀深瞳、高鼻深目轮廓分明的葱岭西域武者面庞。"),
        ("吊梢眼机灵贼面", "市井巧手 · 面孔 20", "眼尾微挑、嘴角挂一丝狡黠笑意的夜行梁上君子面庞。"),
        ("宽额煤印铁匠面", "苦力壮汉 · 面孔 21", "宽额厚唇、两颊沾染炉灰煤印的铁匠铺壮汉面庞。"),
        ("面如冠玉公子面", "世家清贵 · 面孔 22", "肤白如玉、凤目修眉气度雍容的名门世家公子面庞。"),
        ("日晒紫红水客面", "江海舟子 · 面孔 23", "常年江风烈日暴晒出紫铜肤色与眯缝精目的水路好手面庞。"),
        ("十字剑疤少侠面", "生死历练 · 面孔 24", "神情坚毅沉静、左颊留有一道清晰十字剑痕的青年剑客面庞。"),
        ("咬牙暴筋狂客面", "悍勇死士 · 面孔 25", "额角青筋暴突、龇牙怒目杀气腾腾的搏命狂刀客面庞。"),
        ("睡眼惺忪奇才面", "懒散隐逸 · 面孔 26", "眼皮微垂似睡非睡、大智若愚的市井奇才面庞。"),
        ("断鼻淤青拳手面", "地下黑拳 · 面孔 27", "鼻梁曾被重拳打歪、眼眶带暗紫旧淤的拳场硬汉面庞。"),
        ("薄唇笑面师爷面", "城府算计 · 面孔 28", "细长眯缝眼配薄唇微勾的精明账房师爷面庞。"),
        ("颌下双痣相士面", "走方算命 · 面孔 29", "面容清瘦、唇角下巴生有醒目黑痣的江湖相士面庞。"),
        ("紫膛阔颌金刚面", "外家猛士 · 面孔 30", "脸色紫黑如铁、阔口重颌天生神力的横练猛汉面庞。"),
        ("细目鹰视神射面", "百步穿杨 · 面孔 31", "长脸细目、目光凝聚如苍鹰锁猎的边塞弓手面庞。"),
        ("大耳敦实军卒面", "守城团练 · 面孔 32", "双耳阔大、鼻头圆厚、踏实肯扛硬仗的边镇步卒面庞。"),
    ]
    cw, ch = s34.width // 4, s34.height // 4
    new_assets = []
    for idx, (nm, sub, brf) in enumerate(s34_defs):
        aid = f"wx_head_{17 + idx:02d}"
        r, c = divmod(idx, 4)
        rgba = flood_white_bg(s34.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)))
        if idx == 3: rgba = round_pointed_ear_tip(rgba)
        if idx == 5: rgba = warm_fix_green_skin(rgba)
        hd_rel, g_rel = save_catalog_pair(rgba, aid, f"entity/bodies/{aid}.png", 128)
        b_rel = f"art/busts/head/{aid}.png"
        register_head_bust(ImageOps.mirror(rgba)).save(os.path.join(ROOT, b_rel))
        new_assets.append({
            "id": aid, "stage": "3_characters", "group": "千人千面 · 东方面孔基底（48款）",
            "name": nm, "sub": sub, "spec": "104×142 统一头模轮廓首级贴图 (.brush)",
            "slotKind": "boss", "status": "wiki_ready", "hdPath": hd_rel, "previewPath": g_rel,
            "swPath": "", "smallPath": "", "bustPath": b_rel, "pdRole": "face", "pdGender": "m",
            "gameTarget": f"gfx/entity/bodies/{aid}.png", "vanillaFallback": f"bust_head_{(idx % 12) + 1:02d}",
            "codeRef": "mod_wuxia/config/wx_appearance.nut", "brief": brf
        })

    s37_defs = [
        ("清冷剑眉峨眉女侠面", "江湖女侠 · 面孔 33", "肤若寒雪、眉如远山含锋的清修女剑客面庞。"),
        ("英气明眸镖局少主面", "江湖女侠 · 面孔 34", "双瞳剪水却自带三分豪爽将门英气的女镖师面庞。"),
        ("蜜色高颧塞外女骑面", "江湖女侠 · 面孔 35", "朔风烈日锤炼出健康蜜铜肤色的草原女弓手面庞。"),
        ("泪痣丹凤客栈掌柜面", "江湖女侠 · 面孔 36", "眼波流转、右眼下点缀一粒美人黑痣的边关客栈老板娘面庞。"),
        ("灵动圆颊小师妹面", "江湖女侠 · 面孔 37", "初出茅庐、神情认真清澈的名门少女弟子面庞。"),
        ("玄纱覆面圣女面", "江湖女侠 · 面孔 38", "鼻梁以下轻笼半透明墨黑薄纱的奇门圣女面庞。"),
        ("疤面冷眸女刺客面", "江湖女侠 · 面孔 39", "面无血色、右眼留有斜劈刀痕的暗夜女杀手面庞。"),
        ("慈威深纹古庵老尼面", "江湖女侠 · 面孔 40", "历经一甲子江湖风雨、满面皱纹而目光澄明的苦行老尼面庞。"),
        ("碧瞳清冷南疆蛊女面", "江湖女侠 · 面孔 41", "天生浅碧异瞳、神色幽冷莫测的五毒奇女子面庞。"),
        ("朱砂额印刀马旦面", "江湖女侠 · 面孔 42", "额间点赤红菱花印、眉宇飒爽凌厉的梨园武女面庞。"),
        ("素雅温婉药谷医女面", "江湖女侠 · 面孔 43", "眉目柔和恬静、自带草木书卷气的悬壶医女面庞。"),
        ("风霜坚韧江海渔妇面", "江湖女侠 · 面孔 44", "风浪颠簸磨砺出健康黝褐肤色的水寨女当家面庞。"),
        ("柳眉冷笑黑道女魁面", "江湖女侠 · 面孔 45", "高挑浓眉、嘴角似笑非笑杀伐果断的绿林女寨主面庞。"),
        ("端庄清丽书香才女面", "江湖女侠 · 面孔 46", "温润如白玉、神思敏捷的天机奇门才女面庞。"),
        ("金瞳深目西域胡姬面", "江湖女侠 · 面孔 47", "琥珀金瞳、鼻梁高挺的西域拜火剑舞女宗师面庞。"),
        ("铁面霜眉六扇女捕面", "江湖女侠 · 面孔 48", "法令严明、眼神锐利如鹰隼的公门资深女捕头面庞。"),
    ]
    cw, ch = s37.width // 4, s37.height // 4
    for idx, (nm, sub, brf) in enumerate(s37_defs):
        aid = f"wx_head_{33 + idx:02d}"
        r, c = divmod(idx, 4)
        right_im = flood_white_bg(s37.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)))
        right_im = warm_fix_green_skin(right_im)
        hd_rel, g_rel = save_catalog_pair(ImageOps.mirror(right_im), aid, f"entity/bodies/{aid}.png", 128)
        b_rel = f"art/busts/head/{aid}.png"
        register_head_bust(right_im).save(os.path.join(ROOT, b_rel))
        new_assets.append({
            "id": aid, "stage": "3_characters", "group": "千人千面 · 东方面孔基底（48款）",
            "name": nm, "sub": sub, "spec": "104×142 统一头模轮廓首级贴图 (.brush)",
            "slotKind": "boss", "status": "wiki_ready", "hdPath": hd_rel, "previewPath": g_rel,
            "swPath": "", "smallPath": "", "bustPath": b_rel, "pdRole": "face", "pdGender": "f",
            "gameTarget": f"gfx/entity/bodies/{aid}.png", "vanillaFallback": "bust_head_southern_01",
            "codeRef": "mod_wuxia/config/wx_appearance.nut", "brief": brf
        })

    # 4. Sheet 38 Hairstyles (`wx_hair_09..24`) -> Boolean Hair + Tucked Hair!
    s38_defs = [
        ("白玉小冠高束墨发", "模块化发式 09 · 世家少侠髻", "乌黑长发尽数束入雕云纹白玉发冠，清贵利落。"),
        ("铜簪半挽披肩长发", "模块化发式 10 · 仗剑游侠发", "古铜如意簪半挽顶髻，余发潇洒披散肩背。"),
        ("斜绺劲武高扬马尾", "模块化发式 11 · 快剑少年发", "额前碎发斜掠眉宇，脑后高扎冲天劲马尾。"),
        ("双缕龙须垂鬓剑髻", "模块化发式 12 · 风流剑宗髻", "乌木簪束圆髻，两侧太阳穴各垂一缕飘逸龙须鬓发。"),
        ("青皮短茬沙门戒发", "模块化发式 13 · 还俗武僧茬", "头顶青皮微留短硬发茬、双鬓浓密的苦行僧发式。"),
        ("太极木簪圆盘道髻", "模块化发式 14 · 玄门清修髻", "一尘不染盘挽子午圆髻，横插黄杨木道簪。"),
        ("寒儒青布方巾束髻", "模块化发式 15 · 书剑秀才巾", "靛蓝细布折成方巾包裹发髻，斯文儒雅。"),
        ("绛红英雄抹额狂发", "模块化发式 16 · 血性刀客发", "宽幅暗红绸带紧束额头，头顶黑发如烈火怒扬。"),
        ("盘顶多股精编武髻", "模块化发式 17 · 近身搏击髻", "全头发辫紧贴头皮盘结成顶髻，贴身肉搏绝无破绽。"),
        ("两鬓风霜半束灰发", "模块化发式 18 · 中年名宿发", "乌丝间染沧桑银霜的中年宗师半披长发。"),
        ("怒发冲冠纯白宗师发", "模块化发式 19 · 绝顶老剑仙", "纯白如雪、真气激荡向后飞扬的陆地神仙白发！"),
        ("少年双丫总角圆髻", "模块化发式 20 · 武馆小师弟", "红绳扎成左右两枚圆润总角髻的灵动少年发式。"),
        ("明制马尾网巾齐束发", "模块化发式 21 · 官军吏员发", "玄黑马尾细网收拢额际碎发、顶挽端正小髻。"),
        ("落拓浪子歪斜散髻", "模块化发式 22 · 醉酒游侠髻", "随手歪扎脑后、额前散落数缕不羁碎发的浪客发式。"),
        ("翠竹横簪清客中发", "模块化发式 23 · 隐逸琴客发", "一截青翠湘竹横贯发髻、发尾齐颈的清雅发式。"),
        ("乌金铆铁箍狂狮鬃发", "模块化发式 24 · 霸主雄狮发", "厚重铆钉黑铁箍束住额头，脑后浓密黑发如雄狮怒鬃！"),
    ]
    cw, ch = s38.width // 4, s38.height // 4
    for idx, (nm, sub, brf) in enumerate(s38_defs):
        aid = f"wx_hair_{9 + idx:02d}"
        r, c = divmod(idx, 4)
        rgba = clean_sheet38_hair(s38.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)), idx)
        right_im = rgba if idx in (13, 14) else ImageOps.mirror(rgba)
        hd_rel, g_rel = save_catalog_pair(ImageOps.mirror(right_im), aid, f"entity/bodies/{aid}.png", 128)
        b_rel = f"art/busts/hair/{aid}.png"
        bt_rel = f"art/busts/hair_tucked/{aid}.png"
        full_h, tuck_h = register_hair_boolean(right_im, aid)
        full_h.save(os.path.join(ROOT, b_rel))
        tuck_h.save(os.path.join(ROOT, bt_rel))
        new_assets.append({
            "id": aid, "stage": "3_characters", "group": "千人千面 · 模块化发式（24款）",
            "name": nm, "sub": sub, "spec": "104×142 布尔轮廓贴合发式贴图 (.brush)",
            "slotKind": "boss", "status": "wiki_ready", "hdPath": hd_rel, "previewPath": g_rel,
            "swPath": "", "smallPath": "", "bustPath": b_rel, "bustTuckedPath": bt_rel, "pdRole": "hair",
            "gameTarget": f"gfx/entity/bodies/{aid}.png", "vanillaFallback": f"hair_black_{(idx % 12) + 1:02d}",
            "codeRef": "mod_wuxia/config/wx_appearance.nut", "brief": brf
        })

    # 5. Sheet 47 Pure Standalone 3/4-Right Hand-Painted Beards (`wx_beard_09..24`) & Scars (`wx_scar_01..12`)
    s47_defs = [
        ("wx_beard_09", "修整雅正八字胡", "模块化胡须 09 · 名门剑侠髭", "修剪利落贴合上唇弧度的剑客八字黑髭。", "mustache"),
        ("wx_beard_10", "豪侠飞扬虎须髭", "模块化胡须 10 · 快刀豪客髭", "唇角两端威武上翘的豪侠浓密飞扬虎须。", "mustache"),
        ("wx_beard_11", "细长垂缕八字须", "模块化胡须 11 · 老辣师爷须", "沿嘴角两侧垂落过颔的修长名宿细须。", "mustache_goatee"),
        ("wx_beard_12", "精干下颌山羊须", "模块化胡须 12 · 奇门智士须", "两腮净刮、仅于下巴正中留一撮精干尖山羊短须。", "goatee"),
        ("wx_beard_13", "剑客八字配尖须", "模块化胡须 13 · 潇洒游侠须", "利落八字髭配下巴尖长山羊须，唇口开阔分明。", "mustache_goatee"),
        ("wx_beard_14", "儒雅束结三绺髯", "模块化胡须 14 · 掌门宗师须", "连鬓蓄须并以丝绦分束三股垂胸的名家美髯。", "full"),
        ("wx_beard_15", "卧蚕丹凤垂胸髯", "模块化胡须 15 · 义薄云天髯", "浓黑顺滑如墨瀑垂落胸前的武圣长髯。", "full"),
        ("wx_beard_16", "沧桑连鬓短茬胡", "模块化胡须 16 · 百战刀客茬", "贴合下颌骨硬朗生长的铁灰黑短硬络腮胡茬。", "full"),
        ("wx_beard_17", "镖头方正浓密髯", "模块化胡须 17 · 威远总镖头", "棱角方正、厚重威严的老字号镖头满腮短髯。", "full"),
        ("wx_beard_18", "绿林怒张虬髯胡", "模块化胡须 18 · 狂歌豪杰髯", "如盘虬铁丝般卷曲怒张的霸道绿林大胡。", "full"),
        ("wx_beard_19", "塞外双股铁箍辫", "模块化胡须 19 · 朔漠铁骑须", "下颌浓须编结为左右两束铁环战辫的关外猛士胡。", "full"),
        ("wx_beard_20", "连鬓留口悍刀胡", "模块化胡须 20 · 边关悍卒须", "自耳际连鬓裹住下巴、唇下留出透气豁口的悍卒短髯。", "full"),
        ("wx_beard_21", "太和鹤发银白髯", "模块化胡须 21 · 玄门太上长老", "皓白如雪、双束垂落胸前的得道高人银髯。", "full"),
        ("wx_beard_22", "铁匠花白连鬓髯", "模块化胡须 22 · 退隐老武师", "银灰交错厚实包裹下颌的沙场宿将浓髯。", "full"),
        ("wx_beard_23", "西域赤褐卷曲髯", "模块化胡须 23 · 葱岭胡商客", "天然呈古铜赤褐色泽、波浪卷曲的西域豪客浓髯。", "full"),
        ("wx_beard_24", "宗师银灰飘逸须", "模块化胡须 24 · 绝顶老剑仙", "八字银灰长髭配下颌尖须随风微扬的剑仙清须。", "mustache_goatee"),
    ]
    for idx, (aid, nm, sub, brf, b_kind) in enumerate(s47_defs):
        r, c = divmod(idx, 4)
        right_im = clear_enclosed_mouth_window(
            flood_white_bg(s47.crop((c * cw47, r * ch47, (c + 1) * cw47, (r + 1) * ch47))),
            is_snow_white=(aid in ("wx_beard_21", "wx_beard_24"))
        )
        hd_rel, g_rel = save_catalog_pair(ImageOps.mirror(right_im), aid, f"entity/bodies/{aid}.png", 128)
        b_rel = f"art/busts/beard/{aid}.png"
        register_beard_bust(right_im, kind=b_kind).save(os.path.join(ROOT, b_rel))
        new_assets.append({
            "id": aid, "stage": "3_characters", "group": "千人千面 · 模块化胡须（24款）",
            "name": nm, "sub": sub, "spec": "104×142 原版规格模块化胡须贴图 (.brush)",
            "slotKind": "boss", "status": "in_game", "hdPath": hd_rel, "previewPath": g_rel,
            "swPath": "", "smallPath": "", "bustPath": b_rel, "pdRole": "beard",
            "gameTarget": f"brushes/wx_busts_0.brush#{aid}", "vanillaFallback": "beard_black_01",
            "codeRef": "mod_wuxia/config/wx_appearance.nut", "brief": brf
        })

    for (aid, nm, brf, scar_layer_208) in make_12_battle_scars():
        b_rel = f"art/busts/scar/{aid}.png"
        scar_layer_208.save(os.path.join(ROOT, b_rel))
        hd_rel, g_rel = save_catalog_pair(scar_layer_208, aid, f"entity/bodies/{aid}.png", 128)
        new_assets.append({
            "id": aid, "stage": "3_characters", "group": "千人千面 · 刀疤眼罩与面纹（12款）",
            "name": nm, "sub": f"面部战痕与奇相 · {aid.replace('wx_scar_', '')}",
            "spec": "104×142 原版规格面部战痕贴图 (scar_*.brush)",
            "slotKind": "item70", "status": "in_game", "hdPath": hd_rel, "previewPath": g_rel,
            "swPath": "", "smallPath": "", "bustPath": b_rel, "pdRole": "scar",
            "gameTarget": f"brushes/wx_busts_0.brush#{aid}", "vanillaFallback": "scar_01_bust_naked_body_01",
            "codeRef": "mod_wuxia/config/wx_appearance.nut", "brief": brf
        })

    # 6. All 32 Hats & Helmets (`wx_hat_01..32`) -> Upgraded Mannequin-Free Sheet 48 + 3D Ring-Split!
    s28 = Image.open(os.path.join(SHEETS_DIR, "sheet_28.jpg"))
    cw28, ch28 = s28.width // 4, s28.height // 4
    # Map upgraded mannequin-free 3/4-right hats in `Sheet 48` -> exact `wx_hat_*` IDs!
    s48_override_cell = {
        "wx_hat_03": 0,   # Oiled-bamboo rain hat (eye-level 3/4-right)
        "wx_hat_05": 1,   # Six-panel melon skullcap
        "wx_hat_12": 2,   # Indigo cloth forehead band + ribbons (hollow ring!)
        "wx_hat_13": 3,   # Rattan monk circlet (hollow ring!)
        "wx_hat_14": 4,   # Ebony topknot cuff + jade hairpin (zero mannequin skin!)
        "wx_hat_15": 5,   # Miao silver crescent-horn crown (hollow ring!)
        "wx_hat_16": 6,   # White-silver jade forehead band (hollow ring!)
        "wx_hat_17": 7,   # Lower-jaw iron Oni half-mask
        "wx_hat_18": 8,   # Hooded bronze Nuo war-mask with dark cloth cowl
        "wx_hat_21": 9,   # Riveted black-iron forehead band (hollow ring!)
        "wx_hat_22": 10,  # Forest thorn & berry vine circlet (hollow ring!)
        "wx_hat_24": 11,  # Quilted white felt garrison helmet
        "wx_hat_27": 15,  # Crimson-velvet gilded Ming cheek-guard helm
    }
    for i in range(1, 33):
        aid = f"wx_hat_{i:02d}"
        a = by_id[aid]
        if aid in s48_override_cell:
            cidx = s48_override_cell[aid]
            r48, c48 = divmod(cidx, 4)
            right_im = flood_white_bg(s48.crop((c48 * cw48, r48 * ch48, (c48 + 1) * cw48, (r48 + 1) * ch48)))
            # Update catalog `hd` & `70x70` helmet icon too so card thumbnails match 100%!
            save_catalog_pair(ImageOps.mirror(right_im), aid, f"items/helmets/{aid}.png", 70)
        elif i >= 17:
            idx28 = i - 17; r, c = divmod(idx28, 4)
            cell28 = flood_white_bg(s28.crop((c * cw28, r * ch28, (c + 1) * cw28, (r + 1) * ch28)))
            right_im = ImageOps.mirror(cell28) if idx28 in (5, 8, 9) else cell28
        else:
            src_left = Image.open(os.path.join(ROOT, a["hdPath"])).convert("RGBA")
            right_im = ImageOps.mirror(src_left)

        hb, hf, hcomb = register_hat_boolean(right_im, aid)
        hb_rel = f"art/busts/hat_back/{aid}.png"
        hf_rel = f"art/busts/hat_front/{aid}.png"
        hc_rel = f"art/busts/hat/{aid}.png"
        hb.save(os.path.join(ROOT, hb_rel))
        hf.save(os.path.join(ROOT, hf_rel))
        hcomb.save(os.path.join(ROOT, hc_rel))
        a["bustPath"] = hc_rel
        a["bustBackPath"] = hb_rel
        a["bustFrontPath"] = hf_rel
        a["pdOpenTop"] = aid in ("wx_hat_12", "wx_hat_13", "wx_hat_14", "wx_hat_15", "wx_hat_16", "wx_hat_17", "wx_hat_21", "wx_hat_22")

    for na in new_assets:
        na["status"] = "in_game"

    idx_insert = max(i for i, a in enumerate(assets) if a["stage"] == "3_characters") + 1
    assets[idx_insert:idx_insert] = new_assets

    manifest["version"] = "0.7.1-v5-anatomical-busts-755"
    manifest["summary"]["total"] = len(assets)
    manifest["summary"]["wiki_ready"] = sum(1 for x in assets if x["status"] == "wiki_ready")
    manifest["summary"]["in_game"] = sum(1 for x in assets if x["status"] == "in_game")
    manifest["assets"] = assets
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)

    print(f"SUCCESS: Built v5 Anatomical Chin/Beard/3D-Hat Bust System! Total assets = {len(assets)}")


if __name__ == "__main__":
    main()
