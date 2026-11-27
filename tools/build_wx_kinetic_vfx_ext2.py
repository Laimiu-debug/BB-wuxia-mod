#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Expansion Pack A: 18 Additional Next-Gen Wuxia 2D Kinetic Animation Sequences
(Pages 4..6: 180 new handcrafted painterly ink-wash & elemental frames -> 40 sequences total!)
Imported by `tools/build_wx_kinetic_vfx.py`.
"""

import math
import numpy as np


def build_expansion_a_groups(helpers):
    smoothstep = helpers["smoothstep"]
    fbm_2d = helpers["fbm_2d"]
    blur_channel = helpers["blur_channel"]
    add_layer = helpers["add_layer"]
    buf_to_image = helpers["buf_to_image"]
    dist_to_segment = helpers["dist_to_segment"]
    dist_to_polyline = helpers["dist_to_polyline"]
    make_jagged_bolt = helpers["make_jagged_bolt"]

    # -----------------------------------------------------------------------
    # 23. LOTUS ACUPOINT MERIDIAN SEAL (`wx_kin_lotus_poke`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_lotus_poke_frames():
        W, H = 240, 240
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.50
        dx0, dy0 = xx - cx, yy - cy
        r = np.sqrt(dx0 * dx0 + dy0 * dy0)
        ang = np.arctan2(dy0, dx0)
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            rot = t * 0.85
            sc = 0.55 + 0.52 * (t ** 0.62)

            # Blooming 8-petal golden-jade lotus mandala
            pa = ang - rot
            petal_r = (92.0 + 72.0 * np.abs(np.cos(pa * 4.0))) * sc
            in_petal = (1.0 - smoothstep(petal_r - 6.0, petal_r + 6.0, r)) * smoothstep(24.0 * sc, 52.0 * sc, r)
            rim_p = np.exp(-((np.abs(r - petal_r) / 6.5) ** 2))
            add_layer(buf, blur_channel(in_petal, 6.0) * 0.55 * env, (0.20, 0.90, 0.65), additive=True)
            add_layer(buf, blur_channel(rim_p, 5.0) * 1.05 * env, (1.00, 0.82, 0.28), additive=True)
            add_layer(buf, rim_p * 1.25 * env, (1.00, 0.98, 0.86), additive=True)

            # 7 Glowing acupoint star-nodes lighting up sequentially!
            for ni in range(7):
                nt = max(0.0, min(1.0, (t - ni * 0.055) / 0.35))
                if nt <= 0.02:
                    continue
                na = (ni / 7.0) * math.pi * 2.0 + rot
                nr = (0.0 if ni == 0 else 108.0 * sc)
                nx = cx + math.cos(na) * nr
                ny = cy + math.sin(na) * nr
                gx, gy = xx - nx, yy - ny
                gr = np.sqrt(gx * gx + gy * gy)
                star = (
                    np.exp(-gr / 18.0) * 0.95
                    + np.exp(-(np.abs(gy) / 3.0) - np.abs(gx) / 36.0) * 1.1
                    + np.exp(-(np.abs(gx) / 3.0) - np.abs(gy) / 36.0) * 1.1
                ) * math.sin(min(1.0, nt) * math.pi * 0.85 + 0.15) * env
                add_layer(buf, blur_channel(star, 4.0) * 0.9, (1.00, 0.84, 0.32), additive=True)
                add_layer(buf, star * 1.2, (1.00, 1.00, 0.95), additive=True)

            frames.append((f"wx_kin_lotus_poke_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 24. RAPID AFTERIMAGE FIST FLURRY (`wx_kin_fist_flurry`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_fist_flurry_frames():
        W, H = 260, 210
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cy = SH * 0.50
        punches = [
            (-86.0, 0.00, 1.0),
            (54.0,  0.10, 0.92),
            (-24.0, 0.20, 1.12),
            (88.0,  0.30, 0.96),
            (-62.0, 0.38, 1.04),
            (10.0,  0.48, 1.28),
        ]
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.12, t) * (1.0 - smoothstep(0.80, 1.06, t))
            for y_off, dl, psc in punches:
                pt = (t - dl) / 0.46
                if pt <= 0.01 or pt >= 1.05:
                    continue
                pe = math.sin(min(1.0, pt) * math.pi)
                hx = SW * (0.20 + 0.64 * (min(1.0, pt) ** 0.68))
                tx = max(SW * 0.05, hx - 168.0 * psc)
                py = cy + y_off
                # Comet speed trail behind fist
                d, s = dist_to_segment(xx, yy, tx, py, hx, py)
                w = (5.0 + 24.0 * (s ** 0.9)) * psc
                trail = np.exp(-((d / w) ** 2.0)) * smoothstep(0.0, 0.22, s) * pe * env
                add_layer(buf, blur_channel(trail, 5.5) * 0.95, (1.00, 0.64, 0.14), additive=True)
                add_layer(buf, np.exp(-((d / (w * 0.42)) ** 2.0)) * smoothstep(0.25, 0.95, s) * pe * env * 1.25, (1.00, 0.96, 0.78), additive=True)
                # Blunt impact shock-dome + vertical punch ring at fist head!
                fd = np.sqrt(((xx - hx) / (30.0 * psc)) ** 2 + ((yy - py) / (34.0 * psc)) ** 2)
                fist = (1.0 - smoothstep(0.75, 1.08, fd)) * pe * env
                add_layer(buf, fist * 1.15, (1.00, 0.92, 0.62), additive=True)
                rr = np.sqrt(((xx - (hx - 14.0)) / (18.0 + pt * 26.0)) ** 2 + ((yy - py) / (38.0 + pt * 52.0)) ** 2)
                rm = np.exp(-((np.abs(rr - 1.0) / 0.16) ** 2)) * pe * env
                add_layer(buf, rm * 1.15, (1.00, 0.95, 0.72), additive=True)

            frames.append((f"wx_kin_fist_flurry_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 25. PANGU GIANT AXE / HALBERD CLEAVE (`wx_kin_giant_axe`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_giant_axe_frames():
        W, H = 260, 230
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.36, SH * 0.56
        dx = (xx - cx) / 1.16
        dy = (yy - cy) / 1.04
        r = np.sqrt(dx * dx + dy * dy)
        ang = np.arctan2(dy, dx)
        noise = fbm_2d(xx, yy, scale=28.0, seed=4103)
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            head_a = -2.18 + 3.42 * (t ** 0.68)
            tail_a = -2.26 + 2.15 * (max(0.0, (t - 0.22) / 0.78) ** 1.32)
            span = max(0.55, head_a - tail_a)
            u = (ang - tail_a) / span
            in_arc = smoothstep(0.0, 0.10, u) * (1.0 - smoothstep(0.92, 1.0, u))
            uc = np.clip(u, 0.0, 1.0)

            # Massive broad metallic axe-moon blade (very thick!)
            r_mid = 166.0 + 28.0 * np.sin(uc * math.pi) + (noise - 0.5) * 20.0
            thick = (28.0 + 78.0 * (uc ** 0.78) * np.sin(uc * math.pi * 0.88)) * (1.0 - t * 0.18)
            dist = np.abs(r - r_mid)

            # Heavy volcanic-bronze ink body
            ink = np.exp(-((dist / np.maximum(thick * 1.08, 4.0)) ** 2.2)) * in_arc * (0.55 + 0.45 * noise) * env
            add_layer(buf, ink * 0.94, (0.16, 0.08, 0.03), additive=False)
            # Glowing forged bronze-amber middle
            mid = np.exp(-((dist / np.maximum(thick * 0.66, 3.0)) ** 2.0)) * in_arc * env
            add_layer(buf, blur_channel(mid, 7.0) * 1.05, (0.98, 0.48, 0.08), additive=True)
            add_layer(buf, mid * 0.96, (1.00, 0.78, 0.24), additive=True)
            # Blazing white-gold outer axe edge + metallic crackle
            edge = np.exp(-((np.abs(r - (r_mid + thick * 0.44)) / np.maximum(thick * 0.16, 2.0)) ** 2.0)) * smoothstep(0.20, 0.95, uc) * in_arc * env
            add_layer(buf, edge * 1.40, (1.00, 0.98, 0.88), additive=True)

            # Vertical ground-splitting shock rift at bottom impact (`t >= 0.48`)
            if t >= 0.46:
                rk = math.sin(((t - 0.46) / 0.54) * math.pi)
                d_r, _ = dist_to_segment(xx, yy, SW * 0.58, SH * 0.42, SW * 0.78, SH * 0.86)
                rm = np.exp(-((d_r / 12.0) ** 2)) * rk
                add_layer(buf, blur_channel(rm, 6.0) * 1.15, (1.00, 0.58, 0.12), additive=True)
                add_layer(buf, np.exp(-((d_r / 4.0) ** 2)) * rk * 1.35, (1.00, 0.98, 0.90), additive=True)

            frames.append((f"wx_kin_giant_axe_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 26. PHOENIX WING SPEAR VOLLEY (`wx_kin_phoenix_spear`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_phoenix_spear_frames():
        W, H = 290, 180
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cy = SH * 0.50
        noise = fbm_2d(xx, yy, scale=22.0, seed=4209)
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            lead_x = SW * (0.24 + 0.68 * (t ** 0.74))

            # Fiery Swept-Back Phoenix Wings flanking the central spear lance!
            for sgn in (-1.0, 1.0):
                pts = []
                ws = []
                for k in range(13):
                    s = k / 12.0
                    px = lead_x - 36.0 - s * 225.0
                    py = cy + sgn * (18.0 + 115.0 * (s ** 0.78) + math.sin(s * math.pi * 2.0 - t * 6.0) * 16.0)
                    pts.append((px, py))
                    ws.append(max(2.5, (20.0 * (1.0 - s * 0.65) + 8.0 * math.sin(s * math.pi))))
                nd, _ = dist_to_polyline(xx, yy, pts, ws)
                wm = np.exp(-((nd / 1.05) ** 2.0)) * (0.65 + 0.35 * noise) * env
                add_layer(buf, blur_channel(wm, 7.0) * 1.05, (0.98, 0.24, 0.06), additive=True)
                add_layer(buf, wm * 1.05, (1.00, 0.72, 0.18), additive=True)
                add_layer(buf, np.exp(-((nd / 0.38) ** 2.0)) * env * 1.25, (1.00, 0.96, 0.80), additive=True)

            # 5 Converging Spear-Phantom Lances streaking through center!
            for si, sy_off in enumerate((-42.0, -20.0, 0.0, 20.0, 42.0)):
                hx = lead_x - abs(sy_off) * 0.85
                tx = max(SW * 0.04, hx - 220.0)
                d, s = dist_to_segment(xx, yy, tx, cy + sy_off * 1.1, hx, cy + sy_off * 0.35)
                w = (3.0 + 10.5 * (s ** 0.9)) * (1.25 if si == 2 else 0.78)
                lm = np.exp(-((d / w) ** 2.0)) * smoothstep(0.0, 0.16, s) * env
                add_layer(buf, blur_channel(lm, 4.5) * 1.0, (1.00, 0.56, 0.12), additive=True)
                add_layer(buf, np.exp(-((d / (w * 0.42)) ** 2.0)) * env * 1.35, (1.00, 0.99, 0.90), additive=True)

            frames.append((f"wx_kin_phoenix_spear_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 27. EMERALD BAMBOO STAFF & LEAF BIND (`wx_kin_bamboo_bind`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_bamboo_bind_frames():
        W, H = 260, 220
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.52
        noise = fbm_2d(xx, yy, scale=22.0, seed=4311)
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))

            # 3 interlocking emerald-bamboo whipping staff-arcs coiling around center!
            for bi, y_shift, ph in ((0, -54.0, 0.0), (1, 0.0, 1.8), (2, 54.0, 3.6)):
                pts = []
                ws = []
                for k in range(15):
                    s = k / 14.0
                    a = -2.2 + s * 4.4 + t * 2.8 + ph
                    rad = (128.0 - bi * 12.0) * (0.78 + 0.25 * math.sin(t * math.pi))
                    px = cx + math.cos(a) * rad * 1.22
                    py = cy + y_shift * 0.65 + math.sin(a) * rad * 0.42
                    pts.append((px, py))
                    ws.append(max(2.5, 11.0 * math.sin(s * math.pi)))
                nd, _ = dist_to_polyline(xx, yy, pts, ws)
                add_layer(buf, np.exp(-((nd / 1.35) ** 2.0)) * 0.85 * env, (0.02, 0.16, 0.06), additive=False)
                m = np.exp(-((nd / 0.88) ** 2.0)) * (0.70 + 0.30 * noise) * env
                add_layer(buf, blur_channel(m, 5.5) * 1.05, (0.14, 0.86, 0.42), additive=True)
                add_layer(buf, np.exp(-((nd / 0.36) ** 2.0)) * env * 1.25, (0.88, 1.00, 0.86), additive=True)

            # 10 sharp Chinese ink bamboo leaves slicing outward!
            for li in range(10):
                la = li * (math.pi * 2.0 / 10.0) + t * 1.6
                lr = 68.0 + t * 135.0 + (li % 3) * 20.0
                lx = cx + math.cos(la) * lr * 1.15
                ly = cy + math.sin(la) * lr * 0.88
                ca, sa = math.cos(la), math.sin(la)
                rx = (xx - lx) * ca + (yy - ly) * sa
                ry = -(xx - lx) * sa + (yy - ly) * ca
                ld = np.sqrt((rx / 24.0) ** 2 + (ry / 6.2) ** 2)
                lm = (1.0 - smoothstep(0.80, 1.05, ld)) * env
                add_layer(buf, lm * 0.92, (0.06, 0.36, 0.18), additive=False)
                add_layer(buf, lm * 0.95, (0.38, 1.00, 0.62), additive=True)

            frames.append((f"wx_kin_bamboo_bind_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 28. SPINNING FLYING KNIVES FAN (`wx_kin_flying_knives`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_flying_knives_frames():
        W, H = 290, 170
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cy = SH * 0.50
        angles = [-0.38, -0.24, -0.12, 0.0, 0.12, 0.24, 0.38]
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.12, t) * (1.0 - smoothstep(0.80, 1.06, t))
            for ki, ang in enumerate(angles):
                kt = max(0.0, min(1.0, (t - (ki % 3) * 0.05) / 0.84))
                if kt <= 0.01:
                    continue
                dist_f = 60.0 + 440.0 * (kt ** 0.78)
                kx = SW * 0.08 + math.cos(ang) * dist_f
                ky = cy + math.sin(ang) * dist_f * 0.62
                # Curved shimmer tail
                tx = max(SW * 0.04, kx - math.cos(ang) * 145.0)
                ty = ky - math.sin(ang) * 145.0 * 0.62
                d, s = dist_to_segment(xx, yy, tx, ty, kx, ky)
                tm = np.exp(-((d / (2.5 + 7.0 * s)) ** 2.0)) * smoothstep(0.0, 0.2, s) * env
                add_layer(buf, blur_channel(tm, 4.0) * 0.9, (0.28, 0.86, 1.00), additive=True)
                # Spinning leaf-knife crescent blade at head!
                spin = t * 14.0 + ki * 1.1
                cs, sn = math.cos(spin), math.sin(spin)
                rx = (xx - kx) * cs + (yy - ky) * sn
                ry = -(xx - kx) * sn + (yy - ky) * cs
                bd = np.sqrt((rx / 22.0) ** 2 + (ry / 6.5) ** 2)
                bm = (1.0 - smoothstep(0.75, 1.05, bd)) * env
                add_layer(buf, bm * 1.25, (0.94, 0.99, 1.00), additive=True)
                # Spin ring around blade
                sr = np.sqrt((xx - kx) ** 2 + (yy - ky) ** 2)
                ring = np.exp(-((np.abs(sr - 20.0) / 3.2) ** 2)) * env * 0.75
                add_layer(buf, ring, (0.45, 0.92, 1.00), additive=True)

            frames.append((f"wx_kin_flying_knives_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 29. PEACOCK PLUME PRISMATIC FAN (`wx_kin_peacock_fan`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_peacock_fan_frames():
        W, H = 270, 220
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        ox, oy = SW * 0.14, SH * 0.54
        palette = [
            (0.18, 0.94, 0.86), (0.34, 0.98, 0.44), (1.00, 0.82, 0.22),
            (0.98, 0.36, 0.78), (0.46, 0.68, 1.00),
        ]
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            unfold = min(1.0, (t / 0.65) ** 0.70)
            for bi in range(9):
                u_b = (bi - 4.0) / 4.0  # [-1..+1]
                ang = u_b * (0.88 * unfold)
                length = (140.0 + 280.0 * (1.0 - abs(u_b) * 0.20)) * unfold
                ex = ox + math.cos(ang) * length
                ey = oy + math.sin(ang) * length
                d, s = dist_to_segment(xx, yy, ox, oy, ex, ey)
                w = 3.0 + 13.0 * (s ** 0.8)
                col = palette[bi % len(palette)]
                bm = np.exp(-((d / w) ** 2.0)) * smoothstep(0.0, 0.14, s) * env
                add_layer(buf, blur_channel(bm, 5.5) * 0.95, col, additive=True)
                add_layer(buf, np.exp(-((d / (w * 0.34)) ** 2.0)) * env * 1.2, (1.00, 1.00, 0.96), additive=True)
                # Iridescent Peacock Feather Eye-Spot at beam tip!
                ed = np.sqrt((xx - ex) ** 2 + (yy - ey) ** 2)
                eye_outer = np.exp(-((np.abs(ed - 19.0) / 5.0) ** 2)) * env
                eye_inner = np.exp(-((ed / 11.0) ** 2)) * env
                add_layer(buf, eye_outer * 1.1, (1.00, 0.86, 0.28), additive=True)
                add_layer(buf, eye_inner * 1.2, col, additive=True)

            frames.append((f"wx_kin_peacock_fan_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 30. BLACK-POWDER CANNON / THUNDERBOMB BLAST (`wx_kin_cannon_blast`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_cannon_blast_frames():
        W, H = 260, 240
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.58
        dx, dy = xx - cx, yy - cy
        r = np.sqrt(dx * dx + dy * dy)
        ang = np.arctan2(dy, dx)
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.12, t) * (1.0 - smoothstep(0.76, 1.06, t))
            n = fbm_2d(xx, yy + t * 140.0, scale=28.0, seed=4507)

            # Dark gunpowder billowing blast smoke ring
            rad_s = (68.0 + 148.0 * (t ** 0.65))
            sm = np.exp(-(((r - rad_s * 0.62) / (68.0 + 28.0 * t)) ** 2.0)) * smoothstep(0.24, 0.76, n) * env
            add_layer(buf, blur_channel(sm, 6.0) * 0.90, (0.14, 0.11, 0.10), additive=False)

            # Jagged explosive blast spikes bursting radially!
            spikes = 0.55 + 0.45 * np.abs(np.cos(ang * 7.0 + n * 2.2))
            blast_r = (48.0 + 146.0 * (t ** 0.55)) * spikes
            bm = (1.0 - smoothstep(blast_r * 0.72, blast_r * 1.08, r)) * (0.60 + 0.40 * n) * (1.0 - t * 0.30) * env
            add_layer(buf, blur_channel(bm, 8.0) * 1.15, (0.98, 0.24, 0.04), additive=True)
            add_layer(buf, bm * 1.05, (1.00, 0.66, 0.14), additive=True)

            # Incandescent white-hot blast core
            core_r = 28.0 + 62.0 * math.sin(t * math.pi)
            core = np.exp(-((r / max(8.0, core_r)) ** 2.0)) * env
            add_layer(buf, core * 1.35, (1.00, 0.97, 0.80), additive=True)

            # Shockwave blast halo
            sh_r = 55.0 + 175.0 * (t ** 0.72)
            shm = np.exp(-((np.abs(r - sh_r) / 10.0) ** 2)) * env
            add_layer(buf, shm * 1.15, (1.00, 0.82, 0.36), additive=True)

            frames.append((f"wx_kin_cannon_blast_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 31. IMPERIAL WAR-BANNER COMMAND (`wx_kin_war_banner`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_war_banner_frames():
        W, H = 240, 260
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx = SW * 0.44
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            plant = min(1.0, (t / 0.32) ** 0.65)
            y_off = -95.0 * (1.0 - plant)

            # Golden radiant command halo behind banner
            hr = np.sqrt(((xx - cx) / 165.0) ** 2 + ((yy - (SH * 0.42 + y_off)) / 165.0) ** 2)
            rays = 0.55 + 0.45 * np.cos(np.arctan2(yy - (SH * 0.42 + y_off), xx - cx) * 10.0 + t * 3.0)
            halo = np.exp(-(hr ** 1.8) * 1.5) * rays * env
            add_layer(buf, blur_channel(halo, 7.0) * 0.88, (1.00, 0.72, 0.16), additive=True)

            # Vertical Spear-Flagpole
            d_p, _ = dist_to_segment(xx, yy, cx, SH * 0.10 + y_off, cx, SH * 0.84 + y_off)
            pole = (1.0 - smoothstep(5.0, 8.0, d_p)) * env
            add_layer(buf, pole * 0.96, (0.28, 0.16, 0.06), additive=False)
            add_layer(buf, np.exp(-((d_p / 3.2) ** 2)) * env * 1.25, (1.00, 0.92, 0.55), additive=True)

            # Fluttering Crimson-Gold Martial Pennant Flag!
            u_x = (xx - cx) / 172.0
            wave = np.sin(u_x * 6.5 - t * 11.0) * (16.0 * np.clip(u_x, 0.0, 1.0))
            top_y = SH * 0.16 + y_off + wave
            bot_y = SH * 0.52 + y_off + wave - 38.0 * np.clip(u_x, 0.0, 1.0)
            in_flag = smoothstep(0.0, 0.04, u_x) * (1.0 - smoothstep(0.95, 1.02, u_x)) * smoothstep(top_y - 4.0, top_y + 4.0, yy) * (1.0 - smoothstep(bot_y - 4.0, bot_y + 4.0, yy)) * env
            # Gold trim border on banner
            trim = in_flag * np.maximum(np.exp(-((np.abs(yy - top_y) / 9.0) ** 2)), np.exp(-((np.abs(yy - bot_y) / 9.0) ** 2)))
            add_layer(buf, in_flag * 0.92, (0.76, 0.10, 0.08), additive=False)
            add_layer(buf, blur_channel(in_flag, 5.0) * 0.55, (1.00, 0.34, 0.12), additive=True)
            add_layer(buf, trim * 1.25, (1.00, 0.88, 0.38), additive=True)

            # Ground command shockwave ring when flagpole plants!
            if t >= 0.24:
                uk = (t - 0.24) / 0.76
                er = np.sqrt(((xx - cx) / (195.0 * (0.25 + uk * 0.85))) ** 2 + ((yy - SH * 0.82) / (62.0 * (0.25 + uk * 0.85))) ** 2)
                rm = np.exp(-((np.abs(er - 1.0) / 0.14) ** 2)) * math.sin(uk * math.pi)
                add_layer(buf, blur_channel(rm, 5.0) * 1.05, (1.00, 0.76, 0.18), additive=True)
                add_layer(buf, rm * 1.25, (1.00, 0.98, 0.82), additive=True)

            frames.append((f"wx_kin_war_banner_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 32. XUANWU HEXAGONAL TORTOISE AEGIS (`wx_kin_xuanwu_aegis`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_xuanwu_aegis_frames():
        W, H = 240, 240
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.52

        def hex_dist(px, py, rad):
            ax = np.abs(px)
            ay = np.abs(py)
            return np.maximum(ax * 0.866025 + ay * 0.5, ay) / rad

        hex_centers = [
            (0.0, 0.0), (0.0, -96.0), (0.0, 96.0),
            (-84.0, -48.0), (84.0, -48.0), (-84.0, 48.0), (84.0, 48.0),
        ]
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            sc = 0.72 + 0.30 * (t ** 0.60)
            # Outer protective jade-gold shell mask
            all_hex = np.zeros_like(xx)
            all_edge = np.zeros_like(xx)
            for hi, (hx, hy) in enumerate(hex_centers):
                ht = max(0.0, min(1.0, (t - hi * 0.04) / 0.38))
                if ht <= 0.02:
                    continue
                hd = hex_dist((xx - (cx + hx * sc)), (yy - (cy + hy * sc)), 52.0 * sc * (0.7 + 0.3 * ht))
                plate = (1.0 - smoothstep(0.90, 1.02, hd)) * ht
                edge = np.exp(-((np.abs(hd - 0.94) / 0.08) ** 2)) * ht
                all_hex = np.maximum(all_hex, plate)
                all_edge = np.maximum(all_edge, edge)

            add_layer(buf, blur_channel(all_hex, 6.0) * 0.62 * env, (0.12, 0.72, 0.58), additive=True)
            add_layer(buf, all_hex * 0.36 * env, (0.48, 0.98, 0.80), additive=True)
            add_layer(buf, blur_channel(all_edge, 4.5) * 1.10 * env, (1.00, 0.80, 0.24), additive=True)
            add_layer(buf, all_edge * 1.35 * env, (0.98, 1.00, 0.88), additive=True)

            # Diagonal shimmer sweep across shield face!
            sw_pos = -220.0 + t * 440.0
            shimmer = np.exp(-(((xx - cx + (yy - cy) * 0.6 - sw_pos) / 36.0) ** 2)) * all_hex * env
            add_layer(buf, shimmer * 1.1, (1.00, 1.00, 0.96), additive=True)

            frames.append((f"wx_kin_xuanwu_aegis_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 33. SURGING INK-TURQUOISE TIDAL WAVE (`wx_kin_tidal_wave`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_tidal_wave_frames():
        W, H = 280, 200
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        noise = fbm_2d(xx, yy, scale=26.0, seed=4703)
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            surge_x = SW * (0.28 + 0.56 * (t ** 0.76))

            # Curling Great-Wave crest polyline + foaming turquoise body!
            pts = []
            ws = []
            for k in range(17):
                s = k / 16.0
                # Base sweeps up from left -> curls forward into dramatic crashing hook on right!
                if s < 0.72:
                    u = s / 0.72
                    px = surge_x - 245.0 * (1.0 - u)
                    py = SH * 0.80 - 215.0 * (u ** 1.35)
                else:
                    u = (s - 0.72) / 0.28
                    a = -math.pi * 0.55 + u * math.pi * 1.12
                    px = surge_x + math.cos(a) * 68.0
                    py = SH * 0.34 + 52.0 + math.sin(a) * 64.0
                pts.append((px, py))
                ws.append(max(6.0, 38.0 * (1.0 - s * 0.52) + 18.0 * math.sin(s * math.pi)))
            nd, sp = dist_to_polyline(xx, yy, pts, ws)
            # Deep Prussian-ink ocean body
            body = np.exp(-((nd / 1.35) ** 2.0)) * (0.58 + 0.42 * noise) * env
            add_layer(buf, body * 0.92, (0.04, 0.18, 0.28), additive=False)
            # Vivid turquoise sea-jade current
            aqua = np.exp(-((nd / 0.92) ** 2.0)) * env
            add_layer(buf, blur_channel(aqua, 6.5) * 1.05, (0.10, 0.76, 0.92), additive=True)
            # White crashing seafoam along leading crest!
            foam = np.exp(-((nd / 0.44) ** 2.0)) * smoothstep(0.35, 0.92, sp) * (0.65 + 0.35 * noise) * env
            add_layer(buf, foam * 1.35, (0.94, 0.99, 1.00), additive=True)

            # Spray droplets bursting off curling crest!
            tx, ty = pts[-1]
            for di in range(10):
                da = -0.8 + di * 0.22
                dr = 24.0 + t * (58.0 + (di % 4) * 26.0)
                dd = np.sqrt((xx - (tx + math.cos(da) * dr)) ** 2 + (yy - (ty + math.sin(da) * dr)) ** 2)
                add_layer(buf, np.exp(-((dd / 6.5) ** 2)) * env * 1.1, (0.86, 0.98, 1.00), additive=True)

            frames.append((f"wx_kin_tidal_wave_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 34. GOLDEN ACUPUNCTURE HEALING NEEDLES (`wx_kin_gold_needles`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_gold_needles_frames():
        W, H = 250, 230
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.50
        r = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2)
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))

            # Warm healing emerald-gold vitality halo
            halo = np.exp(-((r / (115.0 + 40.0 * math.sin(t * math.pi))) ** 2.0)) * env
            add_layer(buf, halo * 0.65, (0.24, 0.94, 0.62), additive=True)
            ring = np.exp(-((np.abs(r - (65.0 + 95.0 * t)) / 7.0) ** 2)) * env
            add_layer(buf, blur_channel(ring, 5.0) * 1.0, (1.00, 0.84, 0.30), additive=True)

            # 9 Golden Acupuncture Needles converging gracefully inward then blooming!
            rad_in = 175.0 * (1.0 - min(1.0, t / 0.68) * 0.72)
            for ni in range(9):
                na = (ni / 9.0) * math.pi * 2.0 + t * 0.55
                x0 = cx + math.cos(na) * (rad_in + 62.0)
                y0 = cy + math.sin(na) * (rad_in + 62.0)
                x1 = cx + math.cos(na) * rad_in
                y1 = cy + math.sin(na) * rad_in
                d, s = dist_to_segment(xx, yy, x0, y0, x1, y1)
                w = 2.0 + 5.5 * (1.0 - s * 0.6)
                nm = np.exp(-((d / w) ** 2.0)) * env
                add_layer(buf, blur_channel(nm, 4.0) * 0.95, (1.00, 0.78, 0.18), additive=True)
                add_layer(buf, np.exp(-((d / (w * 0.42)) ** 2.0)) * env * 1.35, (1.00, 0.99, 0.88), additive=True)

            frames.append((f"wx_kin_gold_needles_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 35. WINTER SNOWFLAKE QINGGONG STEP (`wx_kin_snow_step`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_snow_step_frames():
        W, H = 260, 210
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.54
        dx0, dy0 = xx - cx, yy - cy
        r = np.sqrt(dx0 * dx0 + dy0 * dy0)
        ang = np.arctan2(dy0, dx0)
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            rot = t * 1.25
            sc = 0.62 + 0.48 * (t ** 0.68)

            # Giant spinning 6-branch crystalline snowflake mandala
            for bi in range(6):
                ba = bi * (math.pi / 3.0) + rot
                ex = cx + math.cos(ba) * 165.0 * sc
                ey = cy + math.sin(ba) * 145.0 * sc
                d, s = dist_to_segment(xx, yy, cx, cy, ex, ey)
                sm = np.exp(-((d / (6.0 * (1.0 - s * 0.45))) ** 2)) * env
                add_layer(buf, blur_channel(sm, 4.5) * 0.95, (0.36, 0.86, 1.00), additive=True)
                add_layer(buf, np.exp(-((d / 2.2) ** 2)) * env * 1.25, (0.98, 1.00, 1.00), additive=True)
                # Side crystal chevron branches
                for side in (-0.65, 0.65):
                    mx = cx + math.cos(ba) * 95.0 * sc
                    my = cy + math.sin(ba) * 85.0 * sc
                    d2, _ = dist_to_segment(xx, yy, mx, my, mx + math.cos(ba + side) * 48.0 * sc, my + math.sin(ba + side) * 44.0 * sc)
                    add_layer(buf, np.exp(-((d2 / 3.6) ** 2)) * env * 1.05, (0.78, 0.96, 1.00), additive=True)

            # Swirling snow-drift ribbon + drifting snow sparkles
            rr = 128.0 * sc + 16.0 * np.sin(ang * 3.0 - rot * 2.0)
            rm = np.exp(-((np.abs(r - rr) / 14.0) ** 2)) * env * 0.72
            add_layer(buf, blur_channel(rm, 6.0), (0.48, 0.90, 1.00), additive=True)

            frames.append((f"wx_kin_snow_step_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 36. SPATIAL WARP / STAR-GATE STEP (`wx_kin_warp_seal`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_warp_seal_frames():
        W, H = 250, 230
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.50
        dx, dy = xx - cx, yy - cy
        r = np.sqrt(dx * dx + dy * dy)
        ang = np.arctan2(dy, dx)
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))

            # Collapsing-then-bursting concentric golden-indigo warp rings!
            pulse = math.sin(t * math.pi)
            for ri, base_r, col in ((0, 172.0, (0.36, 0.72, 1.00)), (1, 122.0, (1.00, 0.84, 0.34)), (2, 74.0, (0.86, 0.96, 1.00))):
                rr = base_r * (1.15 - 0.55 * t) if ri == 0 else base_r * (0.55 + 0.65 * pulse)
                dashes = 0.55 + 0.45 * np.cos(ang * (6 + ri * 2) + t * 5.0 * (1 if ri % 2 == 0 else -1))
                rm = np.exp(-((np.abs(r - rr) / 6.5) ** 2)) * dashes * env
                add_layer(buf, blur_channel(rm, 5.0) * 1.05, col, additive=True)
                add_layer(buf, rm * 1.25, (1.00, 1.00, 0.96), additive=True)

            # Vertical dimensional tear flash in center!
            tear = np.exp(-((np.abs(dx) / (4.5 + 18.0 * pulse)) ** 2 + (np.abs(dy) / (155.0 * pulse + 15.0)) ** 2)) * env
            add_layer(buf, blur_channel(tear, 6.0) * 1.05, (0.48, 0.84, 1.00), additive=True)
            add_layer(buf, np.exp(-((np.abs(dx) / 3.8) ** 2 + (np.abs(dy) / (165.0 * pulse + 12.0)) ** 2)) * env * 1.4, (1.00, 0.99, 0.92), additive=True)

            frames.append((f"wx_kin_warp_seal_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 37. SUMI-E INK SMOKE CLOUD (`wx_kin_smoke_cloud`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_smoke_cloud_frames():
        W, H = 260, 220
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.54
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.76, 1.06, t))
            n1 = fbm_2d(xx - t * 60.0, yy + t * 90.0, scale=34.0, seed=5101)
            n2 = fbm_2d(xx + t * 50.0, yy + t * 130.0, scale=16.0, seed=5109)

            # 5 Billowing sumi-e ink-wash puffs expanding smoothly outward!
            puffs = [
                (0.0, 0.0, 128.0), (-96.0, 18.0, 92.0), (96.0, 12.0, 96.0),
                (-54.0, -56.0, 88.0), (62.0, -52.0, 86.0),
            ]
            cloud = np.zeros_like(xx)
            for ox, oy, pr in puffs:
                px = cx + ox * (0.45 + 0.72 * t)
                py = cy + oy * (0.45 + 0.72 * t) - t * 28.0
                d = np.sqrt((xx - px) ** 2 + (yy - py) ** 2)
                cloud = np.maximum(cloud, np.exp(-((d / (pr * (0.65 + 0.48 * t))) ** 2.2)))

            ink = cloud * smoothstep(0.24, 0.74, n1) * env
            add_layer(buf, blur_channel(ink, 6.0) * 0.92, (0.07, 0.08, 0.12), additive=False)
            # Silver-indigo misty edge highlight so it reads crisply on dark battlefields!
            rim = cloud * smoothstep(0.42, 0.80, n2) * (1.0 - ink * 0.45) * env
            add_layer(buf, blur_channel(rim, 4.5) * 0.88, (0.58, 0.66, 0.88), additive=True)
            add_layer(buf, rim * 0.72, (0.88, 0.92, 1.00), additive=True)

            frames.append((f"wx_kin_smoke_cloud_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 38. FIVE-ELEMENT PRISM INTERNAL BURST (`wx_kin_prism_burst`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_prism_burst_frames():
        W, H = 260, 220
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.50
        elem_cols = [
            (1.00, 0.22, 0.24),  # Fire/Blood
            (1.00, 0.82, 0.20),  # Metal/Gold
            (0.20, 0.94, 0.52),  # Wood/Jade
            (0.24, 0.84, 1.00),  # Water/Cyan
            (0.76, 0.34, 1.00),  # Spirit/Violet
        ]
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.12, t) * (1.0 - smoothstep(0.78, 1.06, t))

            # 5 jagged multi-element internal-qi lightning/shards rupturing outward!
            for ei in range(5):
                ang = ei * (math.pi * 2.0 / 5.0) - math.pi * 0.5 + t * 0.55
                len_r = 45.0 + 178.0 * (t ** 0.68)
                pts = make_jagged_bolt(cx, cy, cx + math.cos(ang) * len_r, cy + math.sin(ang) * len_r, 6, 16.0, 5300 + ei * 37 + fi * 3)
                ws = [16.0, 14.0, 12.0, 10.0, 8.0, 6.0, 3.0]
                nd, _ = dist_to_polyline(xx, yy, pts, ws)
                col = elem_cols[ei]
                m = np.exp(-((nd / 1.05) ** 2.0)) * env
                add_layer(buf, blur_channel(m, 6.5) * 1.10, col, additive=True)
                add_layer(buf, np.exp(-((nd / 0.38) ** 2.0)) * env * 1.30, (1.00, 0.99, 0.96), additive=True)

            # Imploding-to-shattering white-gold internal core
            r = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2)
            core = np.exp(-((r / (36.0 + 38.0 * math.sin(t * math.pi))) ** 2)) * env
            add_layer(buf, core * 1.25, (1.00, 0.96, 0.88), additive=True)

            frames.append((f"wx_kin_prism_burst_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 39. TEN-THOUSAND SWORDS SKY RAIN (`wx_kin_sword_rain`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_sword_rain_frames():
        W, H = 260, 250
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        swords = [
            (-118.0, 0.00), (-72.0, 0.08), (-32.0, 0.03), (8.0, 0.12),
            (48.0, 0.05), (92.0, 0.14), (-92.0, 0.18), (-12.0, 0.22),
            (66.0, 0.20), (118.0, 0.10),
        ]
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.12, t) * (1.0 - smoothstep(0.80, 1.06, t))

            for si, (x_off, dl) in enumerate(swords):
                st = max(0.0, min(1.0, (t - dl) / 0.68))
                if st <= 0.02:
                    continue
                se = smoothstep(0.0, 0.12, st) * (1.0 - smoothstep(0.82, 1.0, st))
                # Diagonal rain falling top-left -> bottom-right into target ground!
                tip_x = SW * 0.52 + x_off + st * 78.0
                tip_y = SH * (0.12 + 0.74 * (st ** 0.82))
                tail_x = tip_x - 42.0
                tail_y = tip_y - 118.0
                d, s = dist_to_segment(xx, yy, tail_x, tail_y, tip_x, tip_y)
                w = 2.2 + 5.8 * (s ** 0.7)
                sm = np.exp(-((d / w) ** 2.0)) * smoothstep(0.0, 0.15, s) * se * env
                col = (0.28, 0.88, 1.00) if si % 2 == 0 else (1.00, 0.84, 0.36)
                add_layer(buf, blur_channel(sm, 4.5) * 1.05, col, additive=True)
                add_layer(buf, np.exp(-((d / (w * 0.36)) ** 2.0)) * se * env * 1.35, (1.00, 1.00, 0.96), additive=True)
                # Crossguard glint
                gx = tail_x + (tip_x - tail_x) * 0.34
                gy = tail_y + (tip_y - tail_y) * 0.34
                gd = np.sqrt((xx - gx) ** 2 + (yy - gy) ** 2)
                add_layer(buf, np.exp(-gd / 11.0) * se * env, (1.00, 0.96, 0.74), additive=True)
                # Impact ground splash spark on arrival!
                if st > 0.72:
                    ik = math.sin(((st - 0.72) / 0.28) * math.pi)
                    idist = np.sqrt(((xx - tip_x) / 34.0) ** 2 + ((yy - tip_y) / 14.0) ** 2)
                    add_layer(buf, np.exp(-((np.abs(idist - 1.0) / 0.22) ** 2)) * ik * 1.15, col, additive=True)

            frames.append((f"wx_kin_sword_rain_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 40. SILVER-GOLD LONE MOON CRESCENT (`wx_kin_moon_crescent`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_moon_crescent_frames():
        W, H = 260, 220
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.46, SH * 0.52
        dx = (xx - cx) / 1.16
        dy = (yy - cy) / 0.96
        r = np.sqrt(dx * dx + dy * dy)
        ang = np.arctan2(dy, dx)
        noise = fbm_2d(xx, yy, scale=28.0, seed=5509)
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            # Sweeping inverse upward-crescent silvery moon arc!
            head_a = 2.25 - 4.35 * (t ** 0.72)
            tail_a = 2.35 - 2.65 * (max(0.0, (t - 0.18) / 0.82) ** 1.25)
            lo_a = min(head_a, tail_a)
            hi_a = max(head_a, tail_a)
            span = max(0.55, hi_a - lo_a)
            u = (hi_a - ang) / span  # 1.0 at leading tip!
            in_arc = smoothstep(0.0, 0.10, u) * (1.0 - smoothstep(0.92, 1.0, u))
            uc = np.clip(u, 0.0, 1.0)

            r_base = 152.0 + 30.0 * np.sin(uc * math.pi)
            thick = (14.0 + 48.0 * (uc ** 0.72) * np.sin(uc * math.pi * 0.92)) * (1.0 - t * 0.22)
            dist = np.abs(r - r_base)

            # Silvery-indigo nocturnal halo + pale gold-ivory crescent edge!
            glow = np.exp(-((dist / np.maximum(thick * 1.05, 3.0)) ** 2.0)) * in_arc * (0.65 + 0.35 * noise) * env
            add_layer(buf, blur_channel(glow, 7.5) * 1.05, (0.58, 0.74, 1.00), additive=True)
            add_layer(buf, glow * 0.92, (0.98, 0.92, 0.68), additive=True)
            razor = np.exp(-((np.abs(r - (r_base + thick * 0.34)) / np.maximum(thick * 0.18, 1.6)) ** 2.0)) * smoothstep(0.22, 0.95, uc) * in_arc * env
            add_layer(buf, razor * 1.40, (1.00, 1.00, 0.98), additive=True)

            # Twinkling starlight motes trailing behind moon arc!
            for si in range(9):
                sa = hi_a - span * (0.14 + 0.78 * ((si * 0.618) % 1.0))
                sr = r_base_s = 155.0 + (si % 3 - 1) * 28.0
                sx = cx + math.cos(sa) * sr * 1.16
                sy = cy + math.sin(sa) * sr * 0.96
                sd = np.sqrt((xx - sx) ** 2 + (yy - sy) ** 2)
                add_layer(buf, np.exp(-sd / 7.5) * env * 1.15, (1.00, 0.96, 0.80), additive=True)

            frames.append((f"wx_kin_moon_crescent_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    return {
        "page4": [
            ("lotus_poke",    gen_lotus_poke_frames()),
            ("fist_flurry",   gen_fist_flurry_frames()),
            ("giant_axe",     gen_giant_axe_frames()),
            ("phoenix_spear", gen_phoenix_spear_frames()),
            ("bamboo_bind",   gen_bamboo_bind_frames()),
            ("flying_knives", gen_flying_knives_frames()),
        ],
        "page5": [
            ("peacock_fan",   gen_peacock_fan_frames()),
            ("cannon_blast",  gen_cannon_blast_frames()),
            ("war_banner",    gen_war_banner_frames()),
            ("xuanwu_aegis",  gen_xuanwu_aegis_frames()),
            ("tidal_wave",    gen_tidal_wave_frames()),
            ("gold_needles",  gen_gold_needles_frames()),
        ],
        "page6": [
            ("snow_step",     gen_snow_step_frames()),
            ("warp_seal",     gen_warp_seal_frames()),
            ("smoke_cloud",   gen_smoke_cloud_frames()),
            ("prism_burst",   gen_prism_burst_frames()),
            ("sword_rain",    gen_sword_rain_frames()),
            ("moon_crescent", gen_moon_crescent_frames()),
        ],
    }
