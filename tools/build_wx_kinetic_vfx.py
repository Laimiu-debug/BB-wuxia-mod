#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Next-Gen Wuxia Kinetic Combat Animation & Micro-Particle Atlas Generator
Produces true 10-12 frame continuous 2D painterly ink-wash & elemental animation
sequences + 16 GPU micro-particle primitives, compiled directly into Battle Brothers
v17 OpenGL `.brush` sheets (`mod_wuxia/brushes/wx_kinetic_*.brush` + `gfx/wx_kinetic_*.png`).

Also saves dark-background visual review contact sheets into `scratch_out` if provided.
"""

import math
import os
import sys
import numpy as np
from PIL import Image, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import compile_wuxia_brushes as cwb

MOD_ROOT = os.path.join(ROOT, "mod_wuxia")


# ---------------------------------------------------------------------------
# Fast Vectorized Float32 Painterly Noise & Compositing Utilities
# ---------------------------------------------------------------------------

def smoothstep(edge0, edge1, x):
    if np.all(edge0 == edge1):
        return np.zeros_like(x, dtype=np.float32)
    t = np.clip((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


def value_noise_2d(xx, yy, scale=18.0, seed=0):
    """Smooth continuous 2D value noise in [0, 1] using pure vectorized numpy."""
    gx = xx / scale
    gy = yy / scale
    ix = np.floor(gx).astype(np.int64)
    iy = np.floor(gy).astype(np.int64)
    fx = gx - ix
    fy = gy - iy
    ux = fx * fx * (3.0 - 2.0 * fx)
    uy = fy * fy * (3.0 - 2.0 * fy)

    def h2(a, b):
        n = (a * 374761393 + b * 668265263 + seed * 1442695041) & 0xFFFFFFFF
        n = ((n ^ (n >> 13)) * 1274126177) & 0xFFFFFFFF
        n = n ^ (n >> 16)
        return (n & 0xFFFF).astype(np.float32) / 65535.0

    v00 = h2(ix, iy)
    v10 = h2(ix + 1, iy)
    v01 = h2(ix, iy + 1)
    v11 = h2(ix + 1, iy + 1)
    vx0 = v00 + (v10 - v00) * ux
    vx1 = v01 + (v11 - v01) * ux
    return vx0 + (vx1 - vx0) * uy


def fbm_2d(xx, yy, scale=28.0, seed=0):
    n1 = value_noise_2d(xx, yy, scale=scale, seed=seed)
    n2 = value_noise_2d(xx, yy, scale=scale * 0.48, seed=seed + 17)
    n3 = value_noise_2d(xx, yy, scale=scale * 0.23, seed=seed + 53)
    return 0.56 * n1 + 0.30 * n2 + 0.14 * n3


def blur_channel(arr_f32, radius):
    if radius <= 0.1:
        return arr_f32
    im = Image.fromarray(np.clip(arr_f32 * 255.0, 0, 255).astype(np.uint8), mode="L")
    im = im.filter(ImageFilter.GaussianBlur(radius=radius))
    return np.asarray(im, dtype=np.float32) / 255.0


def add_layer(buf, mask, rgb, additive=False):
    """Composites a float32 mask [0..1] colored with rgb (0..1) into RGBA float32 buffer."""
    m = np.clip(mask, 0.0, 1.0)
    if additive:
        buf[..., 0] = np.clip(buf[..., 0] + m * rgb[0], 0.0, 1.0)
        buf[..., 1] = np.clip(buf[..., 1] + m * rgb[1], 0.0, 1.0)
        buf[..., 2] = np.clip(buf[..., 2] + m * rgb[2], 0.0, 1.0)
        buf[..., 3] = np.clip(buf[..., 3] + m * (1.0 - buf[..., 3] * 0.35), 0.0, 1.0)
    else:
        a_out = m + buf[..., 3] * (1.0 - m)
        safe_a = np.maximum(a_out, 1e-6)
        for c in range(3):
            buf[..., c] = (rgb[c] * m + buf[..., c] * buf[..., 3] * (1.0 - m)) / safe_a
        buf[..., 3] = a_out


def buf_to_image(buf, target_size=None):
    """Converts RGBA float32 buffer to PIL Image with crisp edge de-ringing."""
    arr = np.clip(buf * 255.0 + 0.5, 0, 255).astype(np.uint8)
    im = Image.fromarray(arr, mode="RGBA")
    if target_size is not None and im.size != target_size:
        im = im.resize(target_size, Image.Resampling.LANCZOS)
    return im


def dist_to_segment(xx, yy, x0, y0, x1, y1):
    vx = x1 - x0
    vy = y1 - y0
    l2 = vx * vx + vy * vy + 1e-6
    t = np.clip(((xx - x0) * vx + (yy - y0) * vy) / l2, 0.0, 1.0)
    px = x0 + t * vx
    py = y0 + t * vy
    return np.sqrt((xx - px) ** 2 + (yy - py) ** 2), t


def dist_to_polyline(xx, yy, pts, widths):
    """Returns (min_norm_dist, best_progress_s [0..1]) for a tapered polyline."""
    best_nd = np.full_like(xx, 999.0, dtype=np.float32)
    best_s = np.zeros_like(xx, dtype=np.float32)
    n_seg = len(pts) - 1
    for i in range(n_seg):
        x0, y0 = pts[i]
        x1, y1 = pts[i + 1]
        w0, w1 = widths[i], widths[i + 1]
        d, t = dist_to_segment(xx, yy, x0, y0, x1, y1)
        w = np.maximum(w0 + (w1 - w0) * t, 0.6)
        nd = d / w
        s_val = (i + t) / float(n_seg)
        better = nd < best_nd
        best_nd = np.where(better, nd, best_nd)
        best_s = np.where(better, s_val, best_s)
    return best_nd, best_s


# ---------------------------------------------------------------------------
# 1. QINGFENG CYAN INK-SWORD CRESCENT SLASH (`wx_kin_sword_slash`, 10 frames)
# ---------------------------------------------------------------------------

def gen_sword_slash_frames():
    W, H = 260, 220
    SW, SH = W * 2, H * 2
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    cx, cy = SW * 0.44, SH * 0.52
    # Slightly elliptical dynamic battle perspective
    dx = (xx - cx) / 1.12
    dy = (yy - cy) / 0.96
    r = np.sqrt(dx * dx + dy * dy)
    ang = np.arctan2(dy, dx)  # [-pi, pi]
    noise = fbm_2d(xx, yy, scale=34.0, seed=101)
    dry = fbm_2d(xx * 0.7 + yy * 0.5, yy * 1.4, scale=14.0, seed=202)

    frames = []
    N = 10
    for fi in range(N):
        t = fi / float(N - 1)  # 0..1
        buf = np.zeros((SH, SW, 4), dtype=np.float32)

        # Wide 215-degree sweeping crescent arc! Head whips fast, tail lags far behind -> HUGE sweeping ribbon!
        head_deg = -128.0 + 250.0 * min(1.0, ((t + 0.06) * 1.65) ** 0.72)
        tail_deg = -134.0 + 235.0 * (max(0.0, (t - 0.24) / 0.76) ** 1.38)
        head_rad = math.radians(head_deg)
        tail_rad = math.radians(tail_deg)

        a_rel = (ang - tail_rad + math.pi * 3.0) % (math.pi * 2.0) - math.pi
        span = max(0.32, head_rad - tail_rad)
        u = a_rel / span  # 0 at tail, 1 at head
        in_arc = (a_rel >= -0.22) & (a_rel <= span + 0.14)

        base_r = 148.0 + 38.0 * (t ** 0.70) + 16.0 * np.sin(np.clip(u, 0, 1) * math.pi)
        u_c = np.clip(u, 0.0, 1.0)
        arc_env = (u_c ** 0.55) * ((1.0 - u_c) ** 0.36) * 2.25
        life_env = smoothstep(-0.05, 0.08, t) * (1.0 - smoothstep(0.68, 1.05, t))
        width = (22.0 + 62.0 * arc_env) * (0.78 + 0.38 * (1.0 - t * 0.35))

        dr = r - base_r
        band = np.where(
            dr >= 0.0,
            np.exp(-((dr / np.maximum(width * 0.24, 3.0)) ** 2)),
            np.exp(-((dr / np.maximum(width * 0.96, 5.0)) ** 2)),
        )
        ang_mask = smoothstep(-0.06, 0.14, u) * (1.0 - smoothstep(0.90, 1.05, u))
        ang_mask = np.where(in_arc, ang_mask, 0.0)

        dissolve = smoothstep(0.54, 1.02, t)
        brush_tex = np.clip((dry * 0.60 + noise * 0.40) - dissolve * 0.48, 0.0, 1.0)
        brush_tex = smoothstep(0.10, 0.54, brush_tex)

        # Layer 1: Bold Wuxia sumi-e dark-cyan ink shadow trailing inner curve
        ink_band = np.exp(-(((dr + width * 0.34) / np.maximum(width * 0.50, 6.0)) ** 2)) * ang_mask
        ink_mask = ink_band * (0.45 + 0.55 * brush_tex) * life_env * 0.76
        add_layer(buf, ink_mask, (0.03, 0.11, 0.18), additive=False)

        # Layer 2: Wide luminous cyan-jade atmospheric glow
        glow_raw = band * ang_mask * (0.65 + 0.35 * noise) * life_env
        glow = blur_channel(glow_raw, radius=11.0) * 1.00
        add_layer(buf, glow, (0.12, 0.80, 0.96), additive=True)

        # Layer 3: Razor-bright cyan-aquamarine calligraphic ribbon
        body_mask = band * ang_mask * (0.42 + 0.58 * brush_tex) * life_env
        add_layer(buf, body_mask * 1.05, (0.44, 0.95, 1.00), additive=True)

        # Layer 4: Incandescent white-hot outer cutting edge
        core_band = np.exp(-(((dr - width * 0.04) / np.maximum(width * 0.15, 3.0)) ** 2))
        core_mask = core_band * smoothstep(0.18, 0.95, u) * ang_mask * life_env * (1.0 - dissolve * 0.45)
        add_layer(buf, core_mask * 1.25, (0.95, 0.99, 1.00), additive=True)

        # Layer 5: Blade-tip 4-point star glint during startup & peak
        if fi <= 6:
            hx = cx + math.cos(head_rad) * (148.0 + 38.0 * (t ** 0.70)) * 1.12
            hy = cy + math.sin(head_rad) * (148.0 + 38.0 * (t ** 0.70)) * 0.96
            gx, gy = xx - hx, yy - hy
            g_rad = np.sqrt(gx * gx + gy * gy)
            star_sz = 46.0 * (1.12 - t * 0.45)
            star = (
                np.exp(-g_rad / (star_sz * 0.45)) * 0.90
                + np.exp(-(np.abs(gy) / 3.5) - np.abs(gx) / (star_sz * 1.5)) * 1.05
                + np.exp(-(np.abs(gx) / 3.5) - np.abs(gy) / (star_sz * 1.2)) * 0.88
            ) * (1.0 - t * 0.35)
            add_layer(buf, star, (0.95, 1.0, 1.0), additive=True)

        # Layer 6: Flying tangential steel sparks & ink flecks during mid-to-late frames
        if fi >= 2:
            for sp in range(9):
                sp_u = 0.18 + sp * 0.095
                sp_ang = tail_rad + sp_u * span + (sp % 2 - 0.5) * 0.18
                sp_r = 152.0 + 44.0 * t + (t - 0.15) * (64.0 + (sp % 3) * 26.0)
                sx = cx + math.cos(sp_ang) * sp_r * 1.12
                sy = cy + math.sin(sp_ang) * sp_r * 0.96
                tx_v, ty_v = -math.sin(sp_ang), math.cos(sp_ang)
                slen = 18.0 + (sp % 3) * 10.0
                d_sp, _ = dist_to_segment(xx, yy, sx - tx_v * slen, sy - ty_v * slen, sx + tx_v * slen, sy + ty_v * slen)
                sp_m = np.exp(-((d_sp / 3.5) ** 2)) * (1.0 - smoothstep(0.68, 1.05, t)) * 0.95
                col = (0.88, 0.99, 1.0) if (sp % 2 == 0) else (0.18, 0.84, 0.98)
                add_layer(buf, sp_m, col, additive=True)

        frames.append((f"wx_kin_sword_slash_{fi:02d}", buf_to_image(buf, (W, H))))
    return frames


# ---------------------------------------------------------------------------
# 2. XIANGLONG SURGING GOLDEN INK-DRAGON (`wx_kin_dragon_surge`, 12 frames)
# ---------------------------------------------------------------------------

def gen_dragon_surge_frames():
    W, H = 320, 200
    SW, SH = W * 2, H * 2
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    noise = fbm_2d(xx, yy, scale=26.0, seed=303)
    fine = fbm_2d(xx, yy, scale=11.0, seed=404)

    frames = []
    N = 12
    for fi in range(N):
        t = fi / float(N - 1)
        buf = np.zeros((SH, SW, 4), dtype=np.float32)

        # Bold muscular Chinese golden Qi dragon surging across 640px width (visible from frame 0 through 11!)
        head_x = 135.0 + 415.0 * min(1.0, ((t + 0.05) / 0.84) ** 0.78)
        tail_x = max(18.0, head_x - (190.0 + 265.0 * math.sin(min(1.0, (t + 0.12) * 1.12) * math.pi * 0.66)))
        if t > 0.68:
            k_end = (t - 0.68) / 0.32
            tail_x = tail_x + (head_x - tail_x) * (k_end ** 1.35) * 0.72

        fade_in = smoothstep(-0.06, 0.08, t)
        fade_out = 1.0 - smoothstep(0.76, 1.06, t)
        vis = fade_in * fade_out

        # Muscular coiling serpentine spine with tall dynamic wave amplitude
        pts = []
        widths = []
        segs = 20
        phase = t * 11.5
        for i in range(segs + 1):
            s = i / float(segs)
            px = tail_x + (head_x - tail_x) * s
            amp = (32.0 + 52.0 * math.sin(s * math.pi * 0.92)) * (1.0 - 0.30 * max(0.0, t - 0.68) / 0.32)
            py = SH * 0.50 + math.sin(s * 6.8 - phase) * amp
            pts.append((px, py))
            w = 10.0 + 42.0 * (s ** 0.68) * (0.85 + 0.25 * math.sin(s * math.pi))
            if s > 0.86:
                w *= 1.18
            widths.append(w)

        nd, prog = dist_to_polyline(xx, yy, pts, widths)

        # Layer 1: Dark ink-bronze dragon scale rim & dorsal flame ridge
        scale_wave = 0.50 + 0.50 * np.sin(prog * 52.0 - phase * 2.2 + fine * 3.5)
        body_shape = np.exp(-(nd ** 2.1) * 1.35) * (0.58 + 0.42 * noise)
        ink_edge = smoothstep(0.50, 1.12, nd) * np.exp(-((nd - 0.96) / 0.45) ** 2) * (0.45 + 0.55 * fine)
        add_layer(buf, ink_edge * vis * 0.76, (0.24, 0.08, 0.02), additive=False)

        # Layer 2: Wide blazing amber-orange Qi dragon halo
        glow = blur_channel(body_shape * vis, radius=14.0)
        add_layer(buf, glow * 1.05, (1.00, 0.52, 0.06), additive=True)

        # Layer 3: Sculpted imperial gold dragon scales & dorsal fire mane
        body_m = body_shape * (0.70 + 0.30 * scale_wave) * vis
        add_layer(buf, body_m * 1.00, (1.00, 0.78, 0.20), additive=True)

        # Layer 4: Incandescent golden-white central Qi spine
        spine_m = np.exp(-((nd / 0.36) ** 2)) * smoothstep(0.05, 0.95, prog) * vis
        add_layer(buf, spine_m * 1.18, (1.00, 0.98, 0.80), additive=True)

        # Layer 5: LARGE, FIERCE Sculpted Roaring Dragon Head (snout, open jaws, fangs, antlers, whiskers, eye!)
        hx, hy = pts[-1]
        prev_x, prev_y = pts[-2]
        ang_h = math.atan2(hy - prev_y, hx - prev_x)
        ca, sa = math.cos(ang_h), math.sin(ang_h)
        lx = (xx - hx) * ca + (yy - hy) * sa
        ly = -(xx - hx) * sa + (yy - hy) * ca

        jaw_open = 24.0 + 12.0 * math.sin(t * 9.5)
        d_uj, _ = dist_to_segment(lx, ly, -22.0, -14.0, 82.0, -jaw_open * 0.52)
        uj_m = np.exp(-((d_uj / 20.0) ** 2)) * smoothstep(-38.0, 6.0, lx)
        d_lj, _ = dist_to_segment(lx, ly, -16.0, 14.0, 68.0, jaw_open * 0.78)
        lj_m = np.exp(-((d_lj / 15.0) ** 2)) * smoothstep(-30.0, 4.0, lx)
        # Upper & lower sharp luminous dragon fangs
        d_f1, _ = dist_to_segment(lx, ly, 58.0, -jaw_open * 0.42, 54.0, -2.0)
        d_f2, _ = dist_to_segment(lx, ly, 48.0, jaw_open * 0.56, 46.0, 8.0)
        # Swept-back majestic antlers + flowing flame-mane & whiskers
        d_h1, _ = dist_to_segment(lx, ly, -10.0, -20.0, -104.0, -72.0)
        d_h2, _ = dist_to_segment(lx, ly, -18.0, -14.0, -90.0, -44.0)
        d_w1, _ = dist_to_segment(lx, ly, 40.0, 10.0, -78.0, 74.0 + math.sin(phase) * 18.0)
        d_w2, _ = dist_to_segment(lx, ly, 42.0, -12.0, -72.0, -76.0 - math.cos(phase) * 16.0)
        orn_m = (
            np.exp(-((d_h1 / 8.0) ** 2))
            + np.exp(-((d_h2 / 6.8) ** 2))
            + np.exp(-((d_w1 / 5.5) ** 2)) * 0.90
            + np.exp(-((d_w2 / 5.5) ** 2)) * 0.90
            + np.exp(-((d_f1 / 4.2) ** 2)) * 1.15
            + np.exp(-((d_f2 / 4.0) ** 2)) * 1.05
        )
        head_vis = vis * (1.0 - smoothstep(0.80, 1.02, t))
        head_m = np.clip(uj_m + lj_m + orn_m, 0.0, 1.0) * head_vis
        add_layer(buf, blur_channel(head_m, 9.0) * 0.95, (1.0, 0.56, 0.08), additive=True)
        add_layer(buf, head_m * 1.00, (1.0, 0.86, 0.34), additive=True)
        eye_m = np.exp(-(((lx - 14.0) ** 2 + (ly + 16.0) ** 2) / 85.0)) * head_vis
        mouth_m = np.exp(-(((lx - 40.0) ** 2) / 620.0 + ((ly - 2.0) ** 2) / 280.0)) * head_vis
        add_layer(buf, eye_m * 1.5, (1.0, 1.0, 0.95), additive=True)
        add_layer(buf, mouth_m * 1.25, (1.0, 0.96, 0.72), additive=True)

        # Layer 6: Pierced Golden Qi Rings along the dragon's surge path!
        for ri, rx_frac in enumerate((0.24, 0.50, 0.74)):
            rx = SW * rx_frac
            if head_x > rx - 40.0:
                age = np.clip((head_x - (rx - 40.0)) / 270.0, 0.0, 1.0)
                ry_r = 42.0 + 108.0 * (age ** 0.72)
                rx_r = ry_r * 0.36
                rd = np.abs(np.sqrt(((xx - rx) / rx_r) ** 2 + ((yy - SH * 0.50) / ry_r) ** 2) - 1.0)
                rm = np.exp(-((rd / 0.14) ** 2)) * (1.0 - age * 0.88) * fade_in * 1.00
                add_layer(buf, rm, (1.0, 0.88, 0.42), additive=True)

        # Layer 7: Climax Golden Dragon Shockwave Burst (frames 7..11 — stays rich & visible through frame 11!)
        if fi >= 7:
            bt = (fi - 7) / 4.5
            bx, by = SW * 0.76, SH * 0.50
            br = np.sqrt(((xx - bx) / 1.18) ** 2 + ((yy - by) / 0.95) ** 2)
            ring_r = 38.0 + 158.0 * (bt ** 0.68)
            b_ring = np.exp(-(((br - ring_r) / (22.0 + 18.0 * bt)) ** 2)) * (1.0 - bt * 0.76)
            b_ring2 = np.exp(-(((br - ring_r * 0.62) / 14.0) ** 2)) * (1.0 - bt * 0.82)
            b_core = np.exp(-((br / (68.0 + 52.0 * bt)) ** 2)) * (1.0 - bt * 0.85) * (0.62 + 0.38 * noise)
            add_layer(buf, (b_ring + b_ring2 * 0.75) * 1.05, (1.0, 0.74, 0.18), additive=True)
            add_layer(buf, b_core * 1.25, (1.0, 0.96, 0.68), additive=True)

        frames.append((f"wx_kin_dragon_surge_{fi:02d}", buf_to_image(buf, (W, H))))
    return frames


# ---------------------------------------------------------------------------
# 3. RANMU BLAZING SOLAR CLEAVE (`wx_kin_flame_cleave`, 10 frames)
# ---------------------------------------------------------------------------

def gen_flame_cleave_frames():
    W, H = 260, 260
    SW, SH = W * 2, H * 2
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    cx, cy = SW * 0.40, SH * 0.54
    dx = xx - cx
    dy = yy - cy
    r = np.sqrt(dx * dx + dy * dy)
    ang = np.arctan2(dy, dx)

    frames = []
    N = 10
    for fi in range(N):
        t = fi / float(N - 1)
        buf = np.zeros((SH, SW, 4), dtype=np.float32)
        # Advect flame turbulence upward & outward for real burning motion!
        flame_n = fbm_2d(xx - t * 65.0, yy + t * 110.0, scale=28.0, seed=505)
        licks = fbm_2d(xx * 1.1, yy * 0.8 + t * 150.0, scale=14.0, seed=606)

        # Huge 210-degree sweeping overhead solar flame crescent!
        head_deg = -135.0 + 225.0 * min(1.0, ((t + 0.06) * 1.62) ** 0.72)
        tail_deg = -142.0 + 205.0 * (max(0.0, (t - 0.26) / 0.74) ** 1.35)
        head_rad = math.radians(head_deg)
        tail_rad = math.radians(tail_deg)

        a_rel = (ang - tail_rad + math.pi * 3.0) % (math.pi * 2.0) - math.pi
        span = max(0.36, head_rad - tail_rad)
        u = a_rel / span
        in_arc = (a_rel >= -0.22) & (a_rel <= span + 0.14)

        u_c = np.clip(u, 0.0, 1.0)
        base_r = 162.0 + 38.0 * (t ** 0.68) + (flame_n - 0.5) * 28.0
        width = 28.0 + 74.0 * (u_c ** 0.58) * ((1.0 - u_c) ** 0.34) * 2.2
        life = smoothstep(-0.05, 0.08, t) * (1.0 - smoothstep(0.66, 1.05, t))

        dr = r - base_r
        ang_m = smoothstep(-0.08, 0.10, u) * (1.0 - smoothstep(0.90, 1.06, u))
        ang_m = np.where(in_arc, ang_m, 0.0)

        # Turbulent fiery tongues extending backward from the crescent
        turb_band = np.where(
            dr >= 0.0,
            np.exp(-((dr / np.maximum(width * 0.28, 3.0)) ** 2)),
            np.exp(-((dr / np.maximum(width * (0.85 + 0.45 * licks), 6.0)) ** 2)),
        )
        dissolve = smoothstep(0.45, 0.98, t)
        fire_tex = smoothstep(0.15 + dissolve * 0.42, 0.72, 0.55 * flame_n + 0.45 * licks)

        # Dark charcoal ink outer smoke outline (pure Wuxia flame-ink contrast!)
        smoke_m = np.exp(-(((dr + width * 0.45) / np.maximum(width * 0.60, 8.0)) ** 2)) * ang_m * fire_tex * life * 0.65
        add_layer(buf, smoke_m, (0.14, 0.04, 0.02), additive=False)

        # Deep blazing crimson-orange fire glow
        raw_fire = turb_band * ang_m * (0.45 + 0.55 * fire_tex) * life
        add_layer(buf, blur_channel(raw_fire, 11.0) * 0.95, (1.00, 0.22, 0.04), additive=True)

        # Bright molten orange-gold fire body
        add_layer(buf, raw_fire * 0.95, (1.00, 0.54, 0.10), additive=True)

        # White-hot blazing blade edge
        edge_m = np.exp(-(((dr - width * 0.03) / np.maximum(width * 0.16, 3.0)) ** 2)) * ang_m * smoothstep(0.20, 0.95, u) * life * (1.0 - dissolve * 0.45)
        add_layer(buf, edge_m * 1.25, (1.00, 0.96, 0.74), additive=True)

        frames.append((f"wx_kin_flame_cleave_{fi:02d}", buf_to_image(buf, (W, H))))
    return frames


# ---------------------------------------------------------------------------
# 4. RANMU ERUPTING FIRE PILLAR (`wx_kin_flame_pillar`, 10 frames)
# ---------------------------------------------------------------------------

def gen_flame_pillar_frames():
    W, H = 200, 280
    SW, SH = W * 2, H * 2
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    cx = SW * 0.50
    base_y = SH * 0.86

    frames = []
    N = 10
    for fi in range(N):
        t = fi / float(N - 1)
        buf = np.zeros((SH, SW, 4), dtype=np.float32)
        # Strong upward fire advection!
        n1 = fbm_2d(xx * 1.15, yy + t * 280.0, scale=32.0, seed=707)
        n2 = fbm_2d(xx * 1.4, yy + t * 420.0, scale=15.0, seed=808)

        # Pillar shoots up from base_y to top rapidly in frames 0..4, flares, dissolves frames 6..9
        grow = min(1.0, (t / 0.42) ** 0.72)
        pillar_h = 65.0 + (SH * 0.78) * grow
        y_from_base = base_y - yy
        h_frac = y_from_base / np.maximum(pillar_h, 1.0)
        vert_m = smoothstep(-0.08, 0.06, h_frac) * (1.0 - smoothstep(0.68, 1.05, h_frac))

        # Helical double-ribbon twist + central blazing column
        w_col = (54.0 + 30.0 * t) * (1.0 - 0.35 * np.clip(h_frac, 0.0, 1.0)) + 26.0 * (n1 - 0.5)
        swirl_x = cx + np.sin(h_frac * 7.5 - t * 12.0) * (18.0 * np.clip(h_frac, 0.0, 1.0))
        dx_col = np.abs(xx - swirl_x)
        col_m = np.exp(-((dx_col / np.maximum(w_col, 8.0)) ** 2.1)) * vert_m

        # Twin rising spiral fire ribbons wrapping around the column
        r1x = cx + np.sin(h_frac * 9.0 - t * 14.0) * (w_col * 0.95)
        r2x = cx - np.sin(h_frac * 9.0 - t * 14.0) * (w_col * 0.95)
        rib = (
            np.exp(-(((xx - r1x) / 14.0) ** 2))
            + np.exp(-(((xx - r2x) / 14.0) ** 2))
        ) * vert_m * 0.75

        life = smoothstep(0.0, 0.10, t) * (1.0 - smoothstep(0.58, 1.0, t))
        dissolve = smoothstep(0.52, 0.98, t)
        ftex = smoothstep(0.16 + dissolve * 0.44, 0.74, 0.58 * n1 + 0.42 * n2)

        # Ground isometric magma ring at base
        gr_r = np.sqrt(((xx - cx) / 1.45) ** 2 + ((yy - base_y) / 0.58) ** 2)
        ring_rad = 38.0 + 82.0 * (t ** 0.65)
        g_ring = np.exp(-(((gr_r - ring_rad) / 18.0) ** 2)) * (1.0 - smoothstep(0.45, 0.95, t))

        # Charcoal smoke fringe
        smoke_m = np.clip(col_m * 1.15, 0.0, 1.0) * smoothstep(0.30, 0.95, h_frac) * (0.4 + 0.6 * n1) * (1.0 - smoothstep(0.75, 1.0, t)) * 0.62
        add_layer(buf, smoke_m, (0.12, 0.05, 0.03), additive=False)

        # Crimson outer bloom
        fire_all = np.clip((col_m + rib) * (0.4 + 0.6 * ftex) + g_ring * 0.85, 0.0, 1.0) * life
        add_layer(buf, blur_channel(fire_all, 10.0) * 0.95, (1.00, 0.24, 0.04), additive=True)
        # Molten orange body
        add_layer(buf, fire_all * 0.95, (1.00, 0.58, 0.12), additive=True)
        # Incandescent yellow-white inner furnace core
        core_m = np.exp(-((dx_col / np.maximum(w_col * 0.36, 5.0)) ** 2)) * vert_m * (1.0 - dissolve * 0.6) * life
        add_layer(buf, (core_m + g_ring * 0.6) * 1.15, (1.00, 0.96, 0.74), additive=True)

        frames.append((f"wx_kin_flame_pillar_{fi:02d}", buf_to_image(buf, (W, H))))
    return frames


# ---------------------------------------------------------------------------
# 5. NINE-HEAVENS SKY-TO-EARTH LIGHTNING COLUMN (`wx_kin_thunder_bolt`, 10 frames)
# ---------------------------------------------------------------------------

def make_jagged_bolt(x0, y0, x1, y1, steps, jitter, rng_seed):
    rng = np.random.RandomState(rng_seed)
    pts = [(x0, y0)]
    for i in range(1, steps):
        f = i / float(steps)
        bx = x0 + (x1 - x0) * f + rng.uniform(-jitter, jitter) * math.sin(f * math.pi)
        by = y0 + (y1 - y0) * f + rng.uniform(-jitter * 0.25, jitter * 0.25)
        pts.append((bx, by))
    pts.append((x1, y1))
    return pts


def gen_thunder_bolt_frames():
    W, H = 220, 340
    SW, SH = W * 2, H * 2
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    cx = SW * 0.50
    top_y = 24.0
    bot_y = SH * 0.88
    noise = fbm_2d(xx, yy, scale=26.0, seed=909)

    frames = []
    N = 10
    for fi in range(N):
        t = fi / float(N - 1)
        buf = np.zeros((SH, SW, 4), dtype=np.float32)

        # Top storm cloud halo (dark indigo-violet thunderhead crown)
        cloud_d = np.sqrt(((xx - cx) / 155.0) ** 2 + ((yy - 44.0) / 48.0) ** 2)
        cloud_m = np.exp(-(cloud_d ** 2.0)) * (0.55 + 0.45 * noise) * (1.0 - smoothstep(0.68, 1.0, t))
        add_layer(buf, cloud_m * 0.75, (0.10, 0.06, 0.22), additive=False)
        add_layer(buf, cloud_m * 0.55, (0.52, 0.30, 1.00), additive=True)

        # Frame progression:
        # 0-1: probing leader bolts descending halfway
        # 2-4: FULL blinding main strike + forks + ground plasma blast
        # 5: brief natural flicker dip then 6: secondary re-strike!
        # 7-9: fracturing ionized residual arcs
        if fi <= 1:
            reach = 0.48 if fi == 0 else 0.82
            end_y = top_y + (bot_y - top_y) * reach
            bolt = make_jagged_bolt(cx, top_y, cx + (fi * 18 - 10), end_y, 12, 46.0, 1000 + fi * 13)
            widths = [5.5] * len(bolt)
            nd, _ = dist_to_polyline(xx, yy, bolt, widths)
            m = np.exp(-((nd / 1.1) ** 2))
            add_layer(buf, blur_channel(m, 9.0) * 0.9, (0.64, 0.36, 1.00), additive=True)
            add_layer(buf, m * 1.1, (0.94, 0.90, 1.00), additive=True)
        else:
            intensity = 1.0
            if fi == 5:
                intensity = 0.58
            elif fi == 6:
                intensity = 0.94
            elif fi >= 7:
                intensity = max(0.0, 1.0 - (fi - 6) / 3.4)

            seed_idx = 2000 + (fi if fi >= 5 else 2) * 37
            jitter = 52.0 if fi in (2, 3, 6) else 68.0
            trunk_w = 13.5 if fi in (2, 3) else (10.0 if fi in (4, 6) else 5.5)
            bolt = make_jagged_bolt(cx + (fi % 3 - 1) * 10.0, top_y, cx, bot_y, 15, jitter, seed_idx)
            widths = [trunk_w * (1.15 - 0.35 * (k / float(len(bolt) - 1))) for k in range(len(bolt))]
            nd, _ = dist_to_polyline(xx, yy, bolt, widths)

            # Forked side-branches shooting out from trunk nodes
            branch_m = np.zeros_like(xx)
            for bi, node_idx in enumerate((3, 6, 9, 11)):
                if fi >= 8 and bi % 2 == 1:
                    continue
                bx0, by0 = bolt[node_idx]
                side = -1.0 if (bi % 2 == 0) else 1.0
                b_pts = make_jagged_bolt(
                    bx0, by0,
                    bx0 + side * (80.0 + bi * 18.0),
                    min(bot_y, by0 + 115.0 + bi * 12.0),
                    6, 26.0, seed_idx + 91 + bi * 17
                )
                bnd, _ = dist_to_polyline(xx, yy, b_pts, [trunk_w * 0.48 * (1.0 - k / 7.0) for k in range(len(b_pts))])
                branch_m = np.maximum(branch_m, np.exp(-((bnd / 1.05) ** 2)))

            # Fragmentation mask for late frames (fi >= 7)
            frag = 1.0
            if fi >= 7:
                frag = smoothstep(0.28 + (fi - 7) * 0.16, 0.72, noise)

            trunk_m = np.exp(-((nd / 1.05) ** 2)) * frag
            all_elec = np.clip(trunk_m + branch_m * 0.80 * frag, 0.0, 1.0) * intensity

            # Electric violet outer plasma halo + crisp cyan-violet mid + blinding white core
            add_layer(buf, blur_channel(all_elec, 14.0) * 1.15, (0.58, 0.24, 1.00), additive=True)
            add_layer(buf, blur_channel(all_elec, 5.0) * 0.95, (0.78, 0.62, 1.00), additive=True)
            core_elec = np.exp(-((nd / 0.42) ** 2)) * frag * intensity
            add_layer(buf, np.clip(core_elec + branch_m * 0.45 * frag * intensity, 0.0, 1.0) * 1.30, (0.98, 0.97, 1.00), additive=True)

            # Ground impact plasma dome + isometric electric shockwave ring at bot_y!
            gt = max(0.0, (fi - 2) / 7.0)
            gr = np.sqrt(((xx - cx) / 1.45) ** 2 + ((yy - bot_y) / 0.62) ** 2)
            g_rad = 22.0 + 118.0 * (gt ** 0.62)
            g_ring = np.exp(-(((gr - g_rad) / (15.0 + 10.0 * gt)) ** 2)) * (1.0 - gt * 0.9)
            g_core = np.exp(-((gr / (52.0 * (1.0 - gt * 0.4))) ** 2)) * (1.0 - smoothstep(0.0, 0.65, gt))
            add_layer(buf, g_ring * 1.05, (0.68, 0.42, 1.00), additive=True)
            add_layer(buf, g_core * 1.35, (0.98, 0.95, 1.00), additive=True)

        frames.append((f"wx_kin_thunder_bolt_{fi:02d}", buf_to_image(buf, (W, H))))
    return frames


# ---------------------------------------------------------------------------
# 6. TIANWAI CELESTIAL PIERCING SWORD-BEAM (`wx_kin_celestial_beam`, 10 frames)
# ---------------------------------------------------------------------------

def gen_celestial_beam_frames():
    W, H = 340, 170
    SW, SH = W * 2, H * 2
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    cy = SH * 0.50
    noise = fbm_2d(xx * 0.35, yy * 1.8, scale=22.0, seed=1111)

    frames = []
    N = 10
    for fi in range(N):
        t = fi / float(N - 1)
        buf = np.zeros((SH, SW, 4), dtype=np.float32)

        # Frame 0-1: Blinding golden star condensation at left origin
        # Frame 2-4: Razor piercing beam shoots instantaneously across 680px!
        # Frame 5-6: Classic Issen (一闪) hairline white-gold cut + vertical star cross-rupture!
        # Frame 7-9: Shatters into horizontal light ribbons & golden stardust!
        if fi <= 1:
            ox = 95.0 + fi * 28.0
            gx, gy = xx - ox, yy - cy
            gr = np.sqrt(gx * gx + gy * gy)
            sz = 46.0 + fi * 28.0
            star = (
                np.exp(-gr / (sz * 0.48)) * 0.9
                + np.exp(-(np.abs(gy) / 4.2) - np.abs(gx) / (sz * 2.2)) * 1.15
                + np.exp(-(np.abs(gx) / 4.2) - np.abs(gy) / (sz * 1.5)) * 0.95
            )
            # Contracting golden ring
            ring_r = 78.0 - fi * 26.0
            ring = np.exp(-(((gr - ring_r) / 7.5) ** 2)) * 0.8
            add_layer(buf, blur_channel(star + ring, 8.0) * 0.95, (1.0, 0.78, 0.28), additive=True)
            add_layer(buf, star * 1.25, (1.0, 0.98, 0.88), additive=True)
        else:
            bt = (fi - 2) / 7.0
            x_start = 24.0 + 90.0 * max(0.0, bt - 0.35)
            x_end = min(SW - 18.0, 290.0 + 420.0 * min(1.0, (fi - 1) * 0.55))

            # Horizontal taper: pointed sword-tip front, sleek feathered tail
            x_u = (xx - x_start) / np.maximum(x_end - x_start, 1.0)
            in_x = smoothstep(-0.04, 0.08, x_u) * (1.0 - smoothstep(0.90, 1.03, x_u))

            # Beam thickness blooms at peak (fi=2,3,4), then snaps razor-thin for Issen (fi=5,6)!
            if fi <= 4:
                half_h = (28.0 + 18.0 * math.sin((fi - 1) * 0.9)) * (0.45 + 0.55 * np.sin(np.clip(x_u, 0, 1) * math.pi))
            else:
                half_h = max(3.5, 22.0 * ((1.0 - bt) ** 1.6)) * (0.4 + 0.6 * np.sin(np.clip(x_u, 0, 1) * math.pi))

            dy = np.abs(yy - cy)
            beam_body = np.exp(-((dy / np.maximum(half_h, 2.5)) ** 1.8)) * in_x
            # Longitudinal speed streaks
            streaks = np.exp(-((dy / np.maximum(half_h * 1.9, 6.0)) ** 2)) * smoothstep(0.42, 0.82, noise) * in_x
            life = 1.0 - smoothstep(0.62, 1.0, bt)

            # Azure-celestial outer aura + imperial gold mid + blinding white hairline sword-core
            add_layer(buf, blur_channel((beam_body + streaks * 0.65) * life, 11.0) * 0.95, (0.36, 0.82, 1.00), additive=True)
            add_layer(buf, (beam_body * 0.85 + streaks * 0.70) * life, (1.00, 0.84, 0.36), additive=True)

            core_h = np.maximum(half_h * 0.28, 2.6)
            core_m = np.exp(-((dy / core_h) ** 2)) * in_x * (1.0 - smoothstep(0.75, 1.0, bt))
            add_layer(buf, core_m * 1.35, (1.00, 0.99, 0.94), additive=True)

            # Pierced elliptical celestial sonic rings along the sword-beam shaft!
            if fi <= 6:
                for ri, rx_f in enumerate((0.22, 0.50, 0.76)):
                    rx = SW * rx_f
                    if x_end > rx:
                        r_age = np.clip((bt + ri * 0.06), 0.0, 1.0)
                        ry_r = 28.0 + 78.0 * (r_age ** 0.70)
                        rx_r = ry_r * 0.24
                        rd = np.abs(np.sqrt(((xx - rx) / rx_r) ** 2 + ((yy - cy) / ry_r) ** 2) - 1.0)
                        rm = np.exp(-((rd / 0.16) ** 2)) * (1.0 - r_age) * 0.95
                        add_layer(buf, rm, (0.92, 0.96, 1.00) if ri == 1 else (1.0, 0.86, 0.42), additive=True)

            # Classic Issen (一闪) vertical diamond rupture flash at target center on frames 4..7!
            if 4 <= fi <= 7:
                it = (fi - 4) / 3.0
                fx, fy = xx - SW * 0.64, yy - cy
                v_flash = (
                    np.exp(-(np.abs(fx) / (5.5 * (1.1 - it * 0.5))) - np.abs(fy) / (115.0 * (1.0 - it * 0.3)))
                    + np.exp(-(np.abs(fy) / (4.5 * (1.1 - it * 0.5))) - np.abs(fx) / (170.0 * (1.0 - it * 0.2)))
                ) * (1.0 - it * 0.85)
                add_layer(buf, blur_channel(v_flash, 6.0) * 0.9, (1.0, 0.84, 0.36), additive=True)
                add_layer(buf, v_flash * 1.3, (1.0, 1.0, 0.96), additive=True)

        frames.append((f"wx_kin_celestial_beam_{fi:02d}", buf_to_image(buf, (W, H))))
    return frames


# ---------------------------------------------------------------------------
# 7. 16 HIGH-CRAFT MICRO-PARTICLE & AFTERMATH PRIMITIVES (`wx_pt_*`)
# ---------------------------------------------------------------------------

def gen_micro_particles():
    out = []

    # 1-4. Directional velocity sparks (cyan, gold, fire, violet)
    def make_spark(name, glow_rgb, core_rgb, jagged=False):
        W, H = 56, 26
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        buf = np.zeros((SH, SW, 4), dtype=np.float32)
        if jagged:
            pts = [(10, SH * 0.5), (38, SH * 0.30), (68, SH * 0.68), (102, SH * 0.46)]
            nd, _ = dist_to_polyline(xx, yy, pts, [5.5, 4.5, 4.5, 2.5])
            m = np.exp(-((nd / 1.05) ** 2))
            core = np.exp(-((nd / 0.45) ** 2))
        else:
            cx, cy = SW * 0.58, SH * 0.50
            dx = (xx - cx) / (SW * 0.40)
            dy = (yy - cy) / (SH * 0.22)
            # Tapered teardrop streak
            taper = np.where(dx < 0, 1.0 + dx * 0.4, 1.0 - dx * 0.65)
            d2 = dx * dx + (dy / np.maximum(taper, 0.2)) ** 2
            m = np.exp(-d2 * 2.8)
            core = np.exp(-d2 * 9.5)
        add_layer(buf, blur_channel(m, 4.0) * 0.95, glow_rgb, additive=True)
        add_layer(buf, core * 1.25, core_rgb, additive=True)
        out.append((name, buf_to_image(buf, (W, H))))

    make_spark("wx_pt_spark_cyan",   (0.22, 0.88, 1.00), (0.95, 1.00, 1.00))
    make_spark("wx_pt_spark_gold",   (1.00, 0.72, 0.16), (1.00, 0.98, 0.82))
    make_spark("wx_pt_spark_fire",   (1.00, 0.36, 0.06), (1.00, 0.92, 0.58))
    make_spark("wx_pt_spark_violet", (0.68, 0.36, 1.00), (0.98, 0.95, 1.00), jagged=True)

    # 5. Sumi-e ink drop splatter (`wx_pt_ink_drop`)
    W, H = 48, 48
    SW, SH = W * 2, H * 2
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    n = fbm_2d(xx, yy, scale=18.0, seed=1201)
    r = np.sqrt((xx - SW * 0.5) ** 2 + (yy - SH * 0.5) ** 2)
    buf = np.zeros((SH, SW, 4), dtype=np.float32)
    m = 1.0 - smoothstep(14.0, 32.0, r + (n - 0.5) * 24.0)
    add_layer(buf, m * 0.90, (0.04, 0.07, 0.10), additive=False)
    rim = (1.0 - smoothstep(18.0, 28.0, r)) * smoothstep(10.0, 18.0, r) * n
    add_layer(buf, rim * 0.55, (0.28, 0.82, 0.96), additive=True)
    out.append(("wx_pt_ink_drop", buf_to_image(buf, (W, H))))

    # 6. Glowing Ember Mote (`wx_pt_ember`)
    W, H = 36, 36
    SW, SH = W * 2, H * 2
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    r = np.sqrt((xx - SW * 0.5) ** 2 + (yy - SH * 0.5) ** 2)
    buf = np.zeros((SH, SW, 4), dtype=np.float32)
    add_layer(buf, np.exp(-((r / 20.0) ** 2)) * 0.90, (1.00, 0.45, 0.08), additive=True)
    add_layer(buf, np.exp(-((r / 8.0) ** 2)) * 1.25, (1.00, 0.96, 0.72), additive=True)
    out.append(("wx_pt_ember", buf_to_image(buf, (W, H))))

    # 7. Painterly Battle Smoke / Dust Cloud (`wx_pt_smoke`)
    W, H = 96, 96
    SW, SH = W * 2, H * 2
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    n = fbm_2d(xx, yy, scale=36.0, seed=1302)
    r = np.sqrt((xx - SW * 0.5) ** 2 + (yy - SH * 0.5) ** 2)
    buf = np.zeros((SH, SW, 4), dtype=np.float32)
    m = np.exp(-((r / 58.0) ** 2.2)) * smoothstep(0.22, 0.75, n) * 0.68
    add_layer(buf, blur_channel(m, 4.0), (0.36, 0.34, 0.32), additive=False)
    out.append(("wx_pt_smoke", buf_to_image(buf, (W, H))))

    # 8. Shattered Dark Stone / Armor Splinter (`wx_pt_rock`)
    W, H = 40, 40
    SW, SH = W * 2, H * 2
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    ang = np.arctan2(yy - SH * 0.5, xx - SW * 0.5)
    r = np.sqrt((xx - SW * 0.5) ** 2 + (yy - SH * 0.5) ** 2)
    poly_r = 22.0 + 7.0 * np.cos(ang * 3.0 + 0.6) + 5.0 * np.sin(ang * 5.0)
    buf = np.zeros((SH, SW, 4), dtype=np.float32)
    m = 1.0 - smoothstep(poly_r - 2.0, poly_r + 2.0, r)
    add_layer(buf, m * 0.96, (0.24, 0.21, 0.19), additive=False)
    hi = m * (1.0 - smoothstep(-20.0, 2.0, (xx - SW * 0.5) + (yy - SH * 0.5))) * 0.75
    add_layer(buf, hi, (0.98, 0.76, 0.44), additive=True)
    out.append(("wx_pt_rock", buf_to_image(buf, (W, H))))

    # 9-12. Isometric Perspective Shockwave Rings (gold, cyan, fire, violet)
    def make_ring(name, outer_rgb, core_rgb):
        W, H = 160, 108
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        n = fbm_2d(xx, yy, scale=22.0, seed=1400 + len(name))
        rx = (xx - SW * 0.5) / (SW * 0.40)
        ry = (yy - SH * 0.5) / (SH * 0.38)
        rr = np.sqrt(rx * rx + ry * ry)
        dist = np.abs(rr - (0.86 + (n - 0.5) * 0.06))
        buf = np.zeros((SH, SW, 4), dtype=np.float32)
        m_out = np.exp(-((dist / 0.13) ** 2)) * (0.65 + 0.35 * n)
        m_core = np.exp(-((dist / 0.045) ** 2))
        add_layer(buf, blur_channel(m_out, 6.0) * 0.95, outer_rgb, additive=True)
        add_layer(buf, m_core * 1.15, core_rgb, additive=True)
        out.append((name, buf_to_image(buf, (W, H))))

    make_ring("wx_pt_ring_gold",   (1.00, 0.70, 0.14), (1.00, 0.96, 0.74))
    make_ring("wx_pt_ring_cyan",   (0.22, 0.86, 1.00), (0.92, 0.99, 1.00))
    make_ring("wx_pt_ring_fire",   (1.00, 0.30, 0.05), (1.00, 0.90, 0.54))
    make_ring("wx_pt_ring_violet", (0.64, 0.30, 1.00), (0.96, 0.92, 1.00))

    # 13. Crisp 4-Point Wuxia Star/Blade Glint (`wx_pt_glint_star`)
    W, H = 128, 128
    SW, SH = W * 2, H * 2
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    gx, gy = xx - SW * 0.5, yy - SH * 0.5
    gr = np.sqrt(gx * gx + gy * gy)
    buf = np.zeros((SH, SW, 4), dtype=np.float32)
    star = (
        np.exp(-gr / 28.0) * 0.85
        + np.exp(-(np.abs(gy) / 4.0) - np.abs(gx) / 96.0) * 1.15
        + np.exp(-(np.abs(gx) / 4.0) - np.abs(gy) / 96.0) * 1.05
        + np.exp(-(np.abs(gx + gy) / 6.0) - np.abs(gx - gy) / 44.0) * 0.45
        + np.exp(-(np.abs(gx - gy) / 6.0) - np.abs(gx + gy) / 44.0) * 0.45
    )
    add_layer(buf, blur_channel(star, 7.0) * 0.85, (0.72, 0.92, 1.00), additive=True)
    add_layer(buf, star * 1.25, (1.00, 1.00, 0.98), additive=True)
    out.append(("wx_pt_glint_star", buf_to_image(buf, (W, H))))

    # 14. Isometric Cracked Ground Scorch / Magma Crater (`wx_pt_crater_scorch`)
    W, H = 164, 108
    SW, SH = W * 2, H * 2
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    cx, cy = SW * 0.5, SH * 0.52
    n = fbm_2d(xx, yy, scale=20.0, seed=1505)
    er = np.sqrt(((xx - cx) / 118.0) ** 2 + ((yy - cy) / 68.0) ** 2)
    buf = np.zeros((SH, SW, 4), dtype=np.float32)
    # Dark charred crater floor
    scorch = np.exp(-(er ** 2.2) * 1.6) * (0.60 + 0.40 * n) * 0.85
    add_layer(buf, scorch, (0.06, 0.04, 0.04), additive=False)
    # 7 radiating jagged magma/energy fissures
    cracks = np.zeros_like(xx)
    for ci in range(7):
        ca = ci * (math.pi * 2.0 / 7.0) + 0.25
        pts = make_jagged_bolt(cx, cy, cx + math.cos(ca) * 124.0, cy + math.sin(ca) * 70.0, 5, 11.0, 1600 + ci * 19)
        cnd, _ = dist_to_polyline(xx, yy, pts, [5.5, 4.5, 3.6, 2.8, 2.0, 1.2])
        cracks = np.maximum(cracks, np.exp(-((cnd / 1.0) ** 2)))
    add_layer(buf, blur_channel(cracks, 4.5) * 0.9, (1.00, 0.36, 0.06), additive=True)
    add_layer(buf, cracks * 1.1, (1.00, 0.86, 0.42), additive=True)
    out.append(("wx_pt_crater_scorch", buf_to_image(buf, (W, H))))

    # 15. Calligraphic Tapered Wind / Qi Wisp (`wx_pt_wind_wisp`)
    W, H = 96, 48
    SW, SH = W * 2, H * 2
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    pts = [(12 + i * 16.5, SH * 0.5 + math.sin(i * 0.62) * 20.0) for i in range(11)]
    widths = [2.5 + 8.5 * math.sin((i / 10.0) * math.pi) for i in range(11)]
    nd, _ = dist_to_polyline(xx, yy, pts, widths)
    buf = np.zeros((SH, SW, 4), dtype=np.float32)
    m = np.exp(-((nd / 1.05) ** 2))
    add_layer(buf, blur_channel(m, 4.0) * 0.85, (0.34, 0.90, 1.00), additive=True)
    add_layer(buf, np.exp(-((nd / 0.45) ** 2)) * 1.1, (0.94, 1.00, 1.00), additive=True)
    out.append(("wx_pt_wind_wisp", buf_to_image(buf, (W, H))))

    # 16. Sleek Luminous Phantom Flying Sword Silhouette (`wx_pt_sword_ray`)
    W, H = 140, 44
    SW, SH = W * 2, H * 2
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    cy = SH * 0.50
    buf = np.zeros((SH, SW, 4), dtype=np.float32)
    blade_u = (xx - 64.0) / 196.0
    blade_w = np.where(blade_u < 0.82, 10.5 - blade_u * 2.5, np.maximum(1.2, (1.0 - blade_u) / 0.18 * 8.5))
    blade_m = smoothstep(-0.02, 0.02, blade_u) * (1.0 - smoothstep(0.98, 1.02, blade_u)) * np.exp(-((np.abs(yy - cy) / np.maximum(blade_w, 1.2)) ** 2.2))
    guard_m = np.exp(-(((xx - 62.0) / 7.5) ** 2 + ((yy - cy) / 28.0) ** 2))
    hilt_m = smoothstep(20.0, 26.0, xx) * (1.0 - smoothstep(58.0, 64.0, xx)) * np.exp(-(((yy - cy) / 4.8) ** 2))
    all_sw = np.clip(blade_m + guard_m * 0.95 + hilt_m * 0.85, 0.0, 1.0)
    add_layer(buf, blur_channel(all_sw, 6.5) * 0.95, (0.38, 0.86, 1.00), additive=True)
    add_layer(buf, all_sw * 0.95, (1.00, 0.88, 0.45), additive=True)
    add_layer(buf, (blade_m * np.exp(-(((yy - cy) / 3.2) ** 2))) * 1.3, (1.00, 1.00, 0.96), additive=True)
    out.append(("wx_pt_sword_ray", buf_to_image(buf, (W, H))))

    return out


def save_contact_sheet(groups, out_path):
    """Creates a clean dark-battlefield contact sheet to visually inspect every animation frame."""
    row_h = 156
    pad = 10
    max_cols = max(len(g[1]) for g in groups)
    cw = 148
    sheet_w = pad + max_cols * (cw + pad)
    sheet_h = pad + len(groups) * (row_h + pad)
    sheet = Image.new("RGBA", (sheet_w, sheet_h), (24, 27, 22, 255))

    for ri, (_title, items) in enumerate(groups):
        y0 = pad + ri * (row_h + pad)
        for ci, (_sid, im) in enumerate(items):
            x0 = pad + ci * (cw + pad)
            # Subtle tile box background
            tile_bg = Image.new("RGBA", (cw, row_h), (34, 38, 32, 255))
            sheet.paste(tile_bg, (x0, y0))
            s = min((cw - 8) / float(im.width), (row_h - 8) / float(im.height))
            nw, nh = max(1, int(im.width * s)), max(1, int(im.height * s))
            thumb = im.resize((nw, nh), Image.Resampling.LANCZOS)
            sheet.alpha_composite(thumb, (x0 + (cw - nw) // 2, y0 + (row_h - nh) // 2))

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    sheet.convert("RGB").save(out_path)
    print(f"Saved visual review contact sheet: {out_path} ({sheet_w}x{sheet_h})")


def _entries_from_items(all_items):
    entries = []
    for sid, im in all_items:
        oy = 18
        if sid.startswith("wx_kin_thunder_bolt_"):
            oy = 115
        elif sid.startswith("wx_kin_flame_pillar_"):
            oy = 92
        elif sid.startswith("wx_kin_frost_burst_"):
            oy = 52
        elif sid.startswith("wx_kin_venom_mire_"):
            oy = 42
        elif sid.startswith("wx_kin_buddha_palm_"):
            oy = 36
        elif sid.startswith("wx_kin_earth_shatter_"):
            oy = 32
        elif sid.startswith("wx_kin_golden_dome_"):
            oy = 32
        elif sid.startswith("wx_kin_war_banner_") or sid.startswith("wx_kin_sword_rain_"):
            oy = 54
        elif sid.startswith("wx_kin_cannon_blast_"):
            oy = 36
        elif sid.startswith("wx_kin_xuanwu_aegis_"):
            oy = 28
        elif sid in ("wx_pt_crater_scorch", "wx_pt_frost_patch", "wx_pt_venom_pool"):
            oy = -18
        entries.append({
            "id": sid,
            "img": im,
            "ox": 0,
            "oy": oy,
            "src_rel": f"effects\\{sid}.png",
            "is_effect": True,
        })
    return entries


def _compile_kinetic_page(page_idx, entries):
    at, rc = cwb.shelf_pack_sprites(entries, max_atlas_w=2048, pad=2)
    assert at.size[1] <= 2048, f"Page {page_idx} exceeded 2048 height: {at.size}"
    gfx_rel = f"gfx/wx_kinetic_{page_idx}.png"
    brush_rel = f"brushes/wx_kinetic_{page_idx}.brush"
    at.save(os.path.join(MOD_ROOT, gfx_rel))
    cwb.write_brush_binary(os.path.join(MOD_ROOT, brush_rel), gfx_rel, at.size, rc, is_effect_sheet=True)
    print(f"Compiled {brush_rel}: {len(rc)} kinetic sprites ({at.size[0]}x{at.size[1]})")
    return len(rc)


def main():
    import build_wx_kinetic_vfx_ext as ext
    import build_wx_kinetic_vfx_ext2 as ext2

    print("Rendering ALL 40 next-gen Wuxia 2D kinetic VFX animations & 28 micro-particles (7 atlas pages)...")
    # Page 0: Original 6 Showcase Sequences + 16 Core Micro-Particles (78 sprites)
    g_sword  = gen_sword_slash_frames()
    g_dragon = gen_dragon_surge_frames()
    g_fcleav = gen_flame_cleave_frames()
    g_fpill  = gen_flame_pillar_frames()
    g_thund  = gen_thunder_bolt_frames()
    g_beam   = gen_celestial_beam_frames()
    g_parts  = gen_micro_particles()
    page0_items = g_sword + g_dragon + g_fcleav + g_fpill + g_thund + g_beam + g_parts

    # Pages 1..6: 34 Extended Sequences + 12 Extra Micro-Particles & Ground Decals (352 sprites)
    helpers = {
        "smoothstep": smoothstep,
        "fbm_2d": fbm_2d,
        "blur_channel": blur_channel,
        "add_layer": add_layer,
        "buf_to_image": buf_to_image,
        "dist_to_segment": dist_to_segment,
        "dist_to_polyline": dist_to_polyline,
        "make_jagged_bolt": make_jagged_bolt,
    }
    ext_pages = ext.build_extended_kinetic_groups(helpers)
    ext2_pages = ext2.build_expansion_a_groups(helpers)
    all_ext = {}
    all_ext.update(ext_pages)
    all_ext.update(ext2_pages)

    # Clean old kinetic pages
    for idx in range(16):
        for rel in (f"brushes/wx_kinetic_{idx}.brush", f"gfx/wx_kinetic_{idx}.png"):
            old_p = os.path.join(MOD_ROOT, rel)
            if os.path.exists(old_p):
                os.remove(old_p)

    total = 0
    total += _compile_kinetic_page(0, _entries_from_items(page0_items))
    for p_idx in range(1, 7):
        p_key = f"page{p_idx}"
        items = []
        for _name, grp in all_ext[p_key]:
            items.extend(grp)
        total += _compile_kinetic_page(p_idx, _entries_from_items(items))
    print(f"TOTAL KINETIC SPRITES COMPILED: {total} across 7 <=2048x2048 OpenGL brush sheets!")

    import build_wx_mirrored_vfx as mirror_mod
    mirror_mod.build_mirrored_pages()

    if len(sys.argv) > 1:
        out_base = sys.argv[1]
        base_noext, base_ext = os.path.splitext(out_base)
        if not base_ext:
            base_ext = ".png"
        for p_idx in range(4, 7):
            save_contact_sheet(all_ext[f"page{p_idx}"], f"{base_noext}_p{p_idx}{base_ext}")


if __name__ == "__main__":
    main()
