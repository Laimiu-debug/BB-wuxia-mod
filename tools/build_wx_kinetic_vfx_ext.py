#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Extended Next-Gen Wuxia 2D Kinetic VFX Animation & Micro-Particle Generators
(Pages 1..3: 16 additional 10-frame painterly sequences + 12 elemental micro-particles/decals)
Imported by `tools/build_wx_kinetic_vfx.py`.
"""

import math
import numpy as np


def build_extended_kinetic_groups(helpers):
    """Generates 16 new 10-frame kinetic animation groups + 12 new micro-particles."""
    smoothstep = helpers["smoothstep"]
    fbm_2d = helpers["fbm_2d"]
    blur_channel = helpers["blur_channel"]
    add_layer = helpers["add_layer"]
    buf_to_image = helpers["buf_to_image"]
    dist_to_segment = helpers["dist_to_segment"]
    dist_to_polyline = helpers["dist_to_polyline"]
    make_jagged_bolt = helpers["make_jagged_bolt"]

    # -----------------------------------------------------------------------
    # 7. CRIMSON DEMONIC INK-BLOOD CRESCENT (`wx_kin_blood_arc`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_blood_arc_frames():
        W, H = 260, 220
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.45, SH * 0.52
        dx = (xx - cx) / 1.14
        dy = (yy - cy) / 0.94
        r = np.sqrt(dx * dx + dy * dy)
        ang = np.arctan2(dy, dx)
        noise = fbm_2d(xx, yy, scale=30.0, seed=2101)
        splat = fbm_2d(xx * 1.1, yy * 1.1, scale=14.0, seed=2109)

        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            head_a = -2.35 + 4.45 * (t ** 0.72)
            tail_a = -2.42 + 2.75 * (max(0.0, (t - 0.18) / 0.82) ** 1.25)
            span = max(0.55, head_a - tail_a)
            u_ang = (ang - tail_a) / span
            in_arc = smoothstep(0.0, 0.10, u_ang) * (1.0 - smoothstep(0.92, 1.0, u_ang))
            u_c = np.clip(u_ang, 0.0, 1.0)
            fade_env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))

            r_base = 148.0 + 34.0 * np.sin(u_c * math.pi) + (noise - 0.5) * 24.0
            thick = (18.0 + 58.0 * (u_c ** 0.70) * np.sin(u_c * math.pi * 0.90)) * (1.0 - t * 0.22)
            dist = np.abs(r - r_base)

            # Deep obsidian-crimson ink outer body
            ink_m = np.exp(-((dist / np.maximum(thick * 1.15, 3.0)) ** 2.0)) * in_arc * (0.48 + 0.52 * splat) * fade_env
            add_layer(buf, ink_m * 0.92, (0.14, 0.01, 0.03), additive=False)

            # Blazing blood-crimson mid-blade
            red_m = np.exp(-((dist / np.maximum(thick * 0.68, 2.2)) ** 2.0)) * in_arc * (0.65 + 0.35 * noise) * fade_env
            add_layer(buf, blur_channel(red_m, 7.5) * 1.12, (0.88, 0.06, 0.10), additive=True)
            add_layer(buf, red_m * 0.98, (1.00, 0.20, 0.18), additive=True)

            # Incandescent leading razor edge
            edge_r = r_base + thick * 0.36
            edge_m = np.exp(-((np.abs(r - edge_r) / np.maximum(thick * 0.22, 1.6)) ** 2.0)) * smoothstep(0.24, 0.94, u_c) * in_arc * fade_env
            add_layer(buf, edge_m * 1.30, (1.00, 0.88, 0.82), additive=True)

            # Splattering crimson droplets flying off outer rim!
            if t > 0.12:
                for di in range(13):
                    da = tail_a + span * (0.12 + 0.84 * ((di * 0.618) % 1.0))
                    dr = 160.0 + 26.0 * math.sin(di * 1.3) + (t - 0.12) * (46.0 + (di % 4) * 26.0)
                    px = cx + math.cos(da) * dr * 1.14
                    py = cy + math.sin(da) * dr * 0.94
                    dd = np.sqrt((xx - px) ** 2 + (yy - py) ** 2)
                    dm = np.exp(-((dd / (5.5 + (di % 3) * 2.5)) ** 2)) * fade_env
                    add_layer(buf, dm * 0.92, (0.96, 0.14, 0.16) if di % 2 == 0 else (0.14, 0.02, 0.04), additive=(di % 2 == 0))

            frames.append((f"wx_kin_blood_arc_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 8. HIGH-VELOCITY SPIRAL SPEAR DRILL (`wx_kin_spear_drill`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_spear_drill_frames():
        W, H = 300, 160
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cy = SH * 0.50
        noise = fbm_2d(xx, yy, scale=22.0, seed=2203)

        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            tip_x = SW * (0.28 + 0.66 * (t ** 0.72))
            tail_x = SW * max(0.04, (t - 0.18) * 0.68)
            u = (xx - tail_x) / max(30.0, tip_x - tail_x)
            in_len = smoothstep(0.0, 0.14, u) * (1.0 - smoothstep(0.95, 1.02, u))
            uc = np.clip(u, 0.0, 1.0)

            # Tapered blazing spear lance core (widest near 0.75, sharp needle at 1.0)
            core_w = (4.0 + 18.0 * np.sin(uc * math.pi * 0.85)) * (1.0 - 0.55 * smoothstep(0.75, 1.0, uc))
            core_m = np.exp(-((np.abs(yy - cy) / np.maximum(core_w, 2.0)) ** 2.0)) * in_len * env
            add_layer(buf, blur_channel(core_m, 7.0) * 1.05, (0.24, 0.82, 1.00), additive=True)
            add_layer(buf, np.exp(-((np.abs(yy - cy) / np.maximum(core_w * 0.42, 1.4)) ** 2.0)) * in_len * env * 1.35, (0.96, 0.99, 1.00), additive=True)

            # Dual counter-rotating corkscrew energy helixes wrapping around the lance!
            phase = t * 14.0
            for strand, ph_off, col in ((0, 0.0, (0.18, 0.88, 1.00)), (1, math.pi, (0.82, 0.96, 1.00))):
                amp = (12.0 + 42.0 * (1.0 - uc * 0.72)) * np.sin(uc * math.pi * 0.92)
                hy = cy + np.sin(uc * 12.5 - phase + ph_off) * amp
                hd = np.abs(yy - hy)
                hw = 5.5 + 8.5 * (1.0 - uc * 0.5)
                hm = np.exp(-((hd / hw) ** 2.0)) * in_len * (0.65 + 0.35 * noise) * env
                add_layer(buf, blur_channel(hm, 4.5) * 0.85, (0.04, 0.16, 0.24), additive=False)
                add_layer(buf, hm * 1.05, col, additive=True)

            # 3 Tilted Sonic Mach Cone Shock-Rings expanding behind the spearhead!
            for ri in range(3):
                rt = (t * 1.55 - ri * 0.22)
                if 0.02 < rt < 0.92:
                    rx = tip_x - (55.0 + ri * 85.0) - rt * 35.0
                    rad_y = 26.0 + rt * 72.0
                    rad_x = 12.0 + rt * 22.0
                    er = np.sqrt(((xx - rx) / rad_x) ** 2 + ((yy - cy) / rad_y) ** 2)
                    rm = np.exp(-((np.abs(er - 1.0) / 0.14) ** 2)) * math.sin(rt * math.pi) * env
                    add_layer(buf, blur_channel(rm, 4.0) * 0.95, (0.35, 0.90, 1.00), additive=True)
                    add_layer(buf, rm * 1.1, (1.00, 1.00, 1.00), additive=True)

            frames.append((f"wx_kin_spear_drill_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 9. 360° INK-TEMPEST WHIRL CYCLONE (`wx_kin_whirl_cyclone`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_whirl_cyclone_frames():
        W, H = 260, 210
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.52
        # Isometric horizontal sweep ellipse
        dx = (xx - cx) / 1.25
        dy = (yy - cy) / 0.72
        r = np.sqrt(dx * dx + dy * dy)
        ang = np.arctan2(dy, dx)
        noise = fbm_2d(xx, yy, scale=26.0, seed=2307)

        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            spin = t * math.pi * 2.65
            rad_expand = 0.72 + 0.36 * (t ** 0.7)

            # 3 layered swirling wind/blade vortex ribbons
            for rib, r_base, w_base, ph, rgb in (
                (0, 152.0, 28.0, 0.0,         (0.06, 0.10, 0.15)),
                (1, 138.0, 20.0, 1.15,        (0.28, 0.86, 0.98)),
                (2, 112.0, 14.0, 2.40,        (0.96, 0.99, 1.00)),
            ):
                a_rot = (ang - spin - ph) % (math.pi * 2.0)
                arc_u = a_rot / (math.pi * 2.0)
                # Asymmetric comet-tail sweep around full 360°
                tail_w = smoothstep(0.04, 0.30, arc_u) * (1.0 - smoothstep(0.86, 1.0, arc_u))
                rr = r_base * rad_expand + 18.0 * np.sin(a_rot * 2.0 + t * 5.0) + (noise - 0.5) * 20.0
                dist = np.abs(r - rr)
                m = np.exp(-((dist / np.maximum(w_base * (0.45 + 0.75 * arc_u), 2.5)) ** 2.0)) * tail_w * (0.62 + 0.38 * noise) * env
                if rib == 0:
                    add_layer(buf, m * 0.88, rgb, additive=False)
                else:
                    add_layer(buf, blur_channel(m, 5.5) * 0.95, (0.18, 0.72, 0.95), additive=True)
                    add_layer(buf, m * 1.15, rgb, additive=True)

            # Outer dust/wind wisps spinning off tangent
            wisp_r = 165.0 * rad_expand
            w_m = np.exp(-((np.abs(r - wisp_r) / 10.0) ** 2)) * smoothstep(0.35, 0.85, np.sin(ang * 3.0 - spin * 1.4)) * env
            add_layer(buf, w_m * 0.82, (0.85, 0.96, 1.00), additive=True)

            frames.append((f"wx_kin_whirl_cyclone_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 10. SAVAGE 3-PRONGED CLAW REND (`wx_kin_claw_rend`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_claw_rend_frames():
        W, H = 250, 220
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        noise = fbm_2d(xx, yy, scale=20.0, seed=2411)

        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.12, t) * (1.0 - smoothstep(0.78, 1.06, t))

            # 3 parallel curved diagonal claw tracks ripping from top-left to bottom-right
            for ci, off in enumerate((-56.0, 0.0, 56.0)):
                ct = max(0.0, min(1.0, (t - ci * 0.045) / 0.65))
                if ct <= 0.01:
                    continue
                head_s = min(1.0, ct * 1.35)
                tail_s = max(0.0, (t - 0.34) * 1.35)
                pts = []
                widths = []
                n_seg = 12
                for k in range(n_seg + 1):
                    s = tail_s + (head_s - tail_s) * (k / float(n_seg))
                    px = SW * (0.14 + 0.72 * s) + off * 0.62 - math.sin(s * math.pi) * 26.0
                    py = SH * (0.15 + 0.70 * s) - off * 0.68 + math.sin(s * math.pi) * 22.0
                    pts.append((px, py))
                    # Sharp needle ends, thick savage gash middle
                    w = (4.0 + 18.0 * math.sin(s * math.pi) * (1.18 if ci == 1 else 0.90)) * (1.0 - max(0.0, t - 0.6) * 0.9)
                    widths.append(max(1.5, w))
                nd, _ = dist_to_polyline(xx, yy, pts, widths)
                ink_m = np.exp(-((nd / 1.35) ** 2.0)) * (0.55 + 0.45 * noise) * env
                add_layer(buf, ink_m * 0.92, (0.10, 0.03, 0.14), additive=False)
                glow_m = np.exp(-((nd / 0.85) ** 2.0)) * env
                add_layer(buf, blur_channel(glow_m, 6.0) * 1.05, (0.76, 0.22, 0.96), additive=True)
                add_layer(buf, np.exp(-((nd / 0.38) ** 2.0)) * env * 1.3, (1.00, 0.94, 1.00), additive=True)

            frames.append((f"wx_kin_claw_rend_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 11. COILING S-CURVE WHIP / CHAIN LASH (`wx_kin_whip_lash`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_whip_lash_frames():
        W, H = 290, 170
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cy = SH * 0.50
        noise = fbm_2d(xx, yy, scale=20.0, seed=2517)

        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.12, t) * (1.0 - smoothstep(0.78, 1.06, t))

            # Traveling S-wave whip snapping from left to right!
            reach = min(1.0, 0.32 + t * 1.12)
            pts = []
            widths = []
            n_pts = 18
            for k in range(n_pts + 1):
                s = k / float(n_pts)
                px = SW * (0.06 + 0.84 * reach * s)
                wave = math.sin(s * math.pi * 2.6 - t * 10.5) * (62.0 * math.sin(s * math.pi) * (1.0 - 0.35 * t))
                curl = math.cos(s * math.pi * 1.4) * 18.0 * (1.0 - s)
                py = cy + wave + curl
                pts.append((px, py))
                w = (12.0 * (1.0 - s * 0.58) + 5.5 * math.sin(s * math.pi)) * (1.0 - max(0.0, t - 0.65) * 0.8)
                widths.append(max(2.0, w))

            nd, _ = dist_to_polyline(xx, yy, pts, widths)
            add_layer(buf, np.exp(-((nd / 1.45) ** 2.0)) * 0.88 * env, (0.04, 0.14, 0.08), additive=False)
            g_m = np.exp(-((nd / 0.90) ** 2.0)) * (0.72 + 0.28 * noise) * env
            add_layer(buf, blur_channel(g_m, 6.5) * 1.05, (0.20, 0.94, 0.56), additive=True)
            add_layer(buf, np.exp(-((nd / 0.38) ** 2.0)) * env * 1.32, (0.94, 1.00, 0.88), additive=True)

            # Explosive sonic whip-crack star at the tip when fully extended (`t = 0.40..0.85`)
            if 0.34 < t < 0.90:
                ck = math.sin(((t - 0.34) / 0.56) * math.pi)
                tx, ty = pts[-1]
                gx, gy = xx - tx, yy - ty
                gr = np.sqrt(gx * gx + gy * gy)
                crack = (
                    np.exp(-gr / (38.0 * ck + 8.0)) * 0.95
                    + np.exp(-(np.abs(gy) / 4.5) - np.abs(gx) / (95.0 * ck + 10.0)) * 1.15
                    + np.exp(-(np.abs(gx) / 4.5) - np.abs(gy) / (95.0 * ck + 10.0)) * 1.15
                ) * ck
                add_layer(buf, blur_channel(crack, 5.0) * 0.95, (0.45, 1.00, 0.72), additive=True)
                add_layer(buf, crack * 1.25, (1.00, 1.00, 0.94), additive=True)

            frames.append((f"wx_kin_whip_lash_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 12. RAZOR X-CROSS ASSASSIN FLASH CUT (`wx_kin_shadow_cross`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_shadow_cross_frames():
        W, H = 250, 220
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.50
        noise = fbm_2d(xx, yy, scale=18.0, seed=2621)

        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.12, t) * (1.0 - smoothstep(0.78, 1.06, t))

            # Cut 1 (top-left -> bottom-right) & Cut 2 (bottom-left -> top-right) staggered!
            cuts = [
                (0.00, 0.65, (SW * 0.10, SH * 0.14), (SW * 0.90, SH * 0.86)),
                (0.20, 0.85, (SW * 0.12, SH * 0.86), (SW * 0.88, SH * 0.14)),
            ]
            for t0, t1, p0, p1 in cuts:
                if t < t0:
                    continue
                ct = min(1.0, (t - t0) / 0.34)
                fade = 1.0 - smoothstep(t1 - 0.15, min(1.0, t1 + 0.16), t)
                q1 = (p0[0] + (p1[0] - p0[0]) * ct, p0[1] + (p1[1] - p0[1]) * ct)
                d, s = dist_to_segment(xx, yy, p0[0], p0[1], q1[0], q1[1])
                w = (5.0 + 22.0 * np.sin(s * math.pi)) * (1.0 - max(0.0, t - 0.55) * 0.85)
                ink = np.exp(-((d / np.maximum(w * 1.5, 3.0)) ** 2.0)) * (0.58 + 0.42 * noise) * fade * env
                add_layer(buf, ink * 0.92, (0.06, 0.03, 0.12), additive=False)
                gl = np.exp(-((d / np.maximum(w * 0.78, 2.0)) ** 2.0)) * fade * env
                add_layer(buf, blur_channel(gl, 6.0) * 1.05, (0.64, 0.28, 1.00), additive=True)
                add_layer(buf, np.exp(-((d / np.maximum(w * 0.30, 1.3)) ** 2.0)) * fade * env * 1.35, (1.00, 0.96, 1.00), additive=True)

            # Blazing cross intersection diamond glint (`t = 0.26..0.78`)
            if 0.24 < t < 0.82:
                fk = math.sin(((t - 0.24) / 0.58) * math.pi)
                gx, gy = xx - cx, yy - cy
                gr = np.sqrt(gx * gx + gy * gy)
                glint = (
                    np.exp(-gr / (46.0 * fk + 8.0)) * 0.85
                    + np.exp(-(np.abs(gy) / 4.2) - np.abs(gx) / (125.0 * fk + 10.0)) * 1.25
                    + np.exp(-(np.abs(gx) / 4.2) - np.abs(gy) / (115.0 * fk + 10.0)) * 1.15
                ) * fk
                add_layer(buf, blur_channel(glint, 6.0) * 0.95, (0.78, 0.48, 1.00), additive=True)
                add_layer(buf, glint * 1.25, (1.00, 1.00, 1.00), additive=True)

            frames.append((f"wx_kin_shadow_cross_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 13. DESCENDING GOLDEN BUDDHA PALM (`wx_kin_buddha_palm`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_buddha_palm_frames():
        W, H = 240, 260
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        noise = fbm_2d(xx, yy, scale=26.0, seed=2701)

        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            # Descends fast from top sky (`0.22 -> 0.62`) and expands into massive golden seal!
            desc = min(1.0, (t / 0.56) ** 0.72)
            cy = SH * (0.26 + 0.34 * desc)
            cx = SW * 0.50
            sc = 0.84 + 0.40 * desc

            # Sculpted Dharma Palm silhouette (palm oval + 5 radiating fingers)
            px = (xx - cx) / sc
            py = (yy - cy) / sc
            palm_d = np.sqrt((px / 68.0) ** 2 + ((py - 16.0) / 76.0) ** 2)
            palm_m = 1.0 - smoothstep(0.84, 1.04, palm_d)
            fingers = [
                (-66.0, 16.0, -108.0, -28.0, 18.0),  # thumb
                (-46.0, -40.0, -56.0, -124.0, 15.5), # index
                (-14.0, -50.0, -16.0, -142.0, 16.5), # middle
                (18.0, -48.0,  22.0, -134.0, 15.5),  # ring
                (48.0, -34.0,  64.0, -106.0, 13.5),  # pinky
            ]
            f_mask = np.zeros_like(xx)
            for fx0, fy0, fx1, fy1, fw in fingers:
                fd, _ = dist_to_segment(px, py, fx0, fy0, fx1, fy1)
                f_mask = np.maximum(f_mask, 1.0 - smoothstep(fw * 0.78, fw * 1.12, fd))
            hand = np.maximum(palm_m, f_mask)

            # Downward celestial speed-streaks during descent
            if t < 0.68:
                streak = np.exp(-((np.abs(px) / 96.0) ** 2)) * smoothstep(-210.0, -40.0, py) * (1.0 - smoothstep(-10.0, 35.0, py)) * (0.45 + 0.55 * noise) * (1.0 - t / 0.72)
                add_layer(buf, streak * 0.75, (1.00, 0.80, 0.25), additive=True)

            # Dark bronze-ink contour + blazing golden radiance + luminous lotus palm emblem!
            edge = blur_channel(hand, 8.5)
            add_layer(buf, edge * (1.0 - hand * 0.45) * 0.85 * env, (0.30, 0.14, 0.02), additive=False)
            add_layer(buf, blur_channel(hand, 12.0) * 1.05 * env, (1.00, 0.68, 0.10), additive=True)
            add_layer(buf, hand * (0.68 + 0.32 * noise) * env * 0.92, (1.00, 0.88, 0.42), additive=True)

            # Radiant inner Dharma ring inside palm center
            pr = np.sqrt(px * px + (py - 12.0) ** 2)
            ring_in = np.exp(-((np.abs(pr - 34.0) / 5.5) ** 2)) * env
            add_layer(buf, ring_in * 1.35, (1.00, 0.98, 0.86), additive=True)

            # Ground impact golden mandala wave (`t >= 0.44`)
            if t >= 0.42:
                uk = (t - 0.42) / 0.58
                rr = np.sqrt(((xx - cx) / (195.0 * (0.35 + uk * 0.85))) ** 2 + ((yy - (SH * 0.72)) / (78.0 * (0.35 + uk * 0.85))) ** 2)
                wm = np.exp(-((np.abs(rr - 1.0) / 0.14) ** 2)) * math.sin(uk * math.pi)
                add_layer(buf, blur_channel(wm, 5.5) * 1.05, (1.00, 0.72, 0.16), additive=True)
                add_layer(buf, wm * 1.25, (1.00, 0.97, 0.82), additive=True)

            frames.append((f"wx_kin_buddha_palm_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 14. CRYSTALLINE GLACIAL FROST BURST (`wx_kin_frost_burst`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_frost_burst_frames():
        W, H = 240, 240
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.78
        noise = fbm_2d(xx, yy, scale=24.0, seed=2803)

        # 7 jagged glacial ice spires erupting upward in a crystalline fan
        spires = [
            (-105.0, -135.0, 22.0, 0.08),
            (-64.0,  -215.0, 26.0, 0.04),
            (-22.0,  -275.0, 30.0, 0.00),
            (26.0,   -260.0, 28.0, 0.02),
            (70.0,   -205.0, 25.0, 0.06),
            (108.0,  -128.0, 20.0, 0.10),
            (0.0,    -315.0, 34.0, 0.05),
        ]
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))

            # Swirling icy mist base
            mr = np.sqrt(((xx - cx) / 165.0) ** 2 + ((yy - (cy - 30.0)) / 95.0) ** 2)
            mist = np.exp(-(mr ** 2.0) * 1.4) * smoothstep(0.28, 0.78, noise) * env * 0.78
            add_layer(buf, blur_channel(mist, 8.0), (0.14, 0.56, 0.88), additive=True)

            # Erupting crystalline ice spikes!
            for tx_off, ty_off, base_w, delay in spires:
                st = max(0.0, min(1.0, (t - delay) / 0.42))
                if st <= 0.02:
                    continue
                grow = st ** 0.65
                bx0 = cx + tx_off * 0.25
                by0 = cy + 12.0
                tip_x = bx0 + tx_off * grow
                tip_y = by0 + ty_off * grow
                d, s = dist_to_segment(xx, yy, bx0, by0, tip_x, tip_y)
                # Sharp crystalline prism taper (diamond cross-section)
                w = base_w * (1.0 - s * 0.88) * (1.0 - max(0.0, t - 0.68) * 1.1)
                cryst = 1.0 - smoothstep(w * 0.72, w * 1.08, d)
                # Faceted highlight on one side of crystal!
                facet = cryst * (0.45 + 0.55 * smoothstep(-w * 0.4, w * 0.4, (xx - (bx0 + (tip_x - bx0) * s))))
                add_layer(buf, cryst * 0.92 * env, (0.08, 0.34, 0.66), additive=False)
                add_layer(buf, blur_channel(cryst, 5.5) * 0.85 * env, (0.28, 0.84, 1.00), additive=True)
                add_layer(buf, facet * 1.15 * env, (0.86, 0.98, 1.00), additive=True)
                # Razor central ridge line
                ridge = np.exp(-((d / np.maximum(w * 0.16, 1.4)) ** 2)) * (1.0 - smoothstep(0.95, 1.0, s)) * env
                add_layer(buf, ridge * 1.30, (1.00, 1.00, 1.00), additive=True)

            frames.append((f"wx_kin_frost_burst_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 15. FIVE-POISONS VENOM MIASMA GEYSER (`wx_kin_venom_mire`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_venom_mire_frames():
        W, H = 240, 240
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.74

        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            n1 = fbm_2d(xx, yy + t * 180.0, scale=32.0, seed=2901)
            n2 = fbm_2d(xx * 1.3, yy + t * 240.0, scale=16.0, seed=2909)

            # Rising coiled venom cloud plume
            h_reach = 80.0 + 230.0 * (t ** 0.72)
            v_u = (cy - yy) / max(40.0, h_reach)
            in_col = smoothstep(-0.12, 0.10, v_u) * (1.0 - smoothstep(0.86, 1.08, v_u))
            vc = np.clip(v_u, 0.0, 1.0)
            w_col = (58.0 + 78.0 * np.sin(vc * math.pi * 0.85)) * (0.75 + 0.45 * n1)
            swirl_x = cx + np.sin(vc * 7.0 - t * 8.0) * 32.0
            m_plume = np.exp(-(((xx - swirl_x) / np.maximum(w_col, 8.0)) ** 2.0)) * in_col * smoothstep(0.22, 0.72, n1) * env

            # Dark poisonous violet-black under-smoke
            add_layer(buf, blur_channel(m_plume, 7.0) * 0.90, (0.14, 0.05, 0.24), additive=False)
            # Boiling radioactive emerald venom wisps
            m_acid = m_plume * smoothstep(0.32, 0.78, n2)
            add_layer(buf, blur_channel(m_acid, 6.0) * 1.10, (0.18, 0.88, 0.26), additive=True)
            add_layer(buf, m_acid * 1.15, (0.68, 1.00, 0.34), additive=True)

            # Eerie glowing venom skull eyes + rising toxic bubbles!
            if 0.20 < t < 0.85:
                sk_a = math.sin(((t - 0.20) / 0.65) * math.pi)
                sy = cy - h_reach * 0.58
                for ex in (-26.0, 26.0):
                    ed = np.sqrt(((xx - (cx + ex)) / 14.0) ** 2 + ((yy - sy) / 10.0) ** 2)
                    add_layer(buf, np.exp(-(ed ** 2.0)) * sk_a * 1.25, (0.88, 1.00, 0.42), additive=True)

            for bi in range(9):
                bt = (t * 1.35 + bi * 0.11) % 1.0
                bx = cx + math.sin(bi * 2.1 + t * 4.0) * (35.0 + (bi % 4) * 24.0)
                by = cy - bt * 240.0
                bd = np.sqrt((xx - bx) ** 2 + (yy - by) ** 2)
                br = 7.0 + (bi % 3) * 4.0
                bm = np.exp(-((np.abs(bd - br) / 3.0) ** 2)) * math.sin(bt * math.pi) * env
                add_layer(buf, bm * 1.15, (0.52, 1.00, 0.32), additive=True)

            frames.append((f"wx_kin_venom_mire_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 16. TECTONIC EARTH-SHATTER SPIKES (`wx_kin_earth_shatter`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_earth_shatter_frames():
        W, H = 260, 220
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.76
        noise = fbm_2d(xx, yy, scale=22.0, seed=3001)

        rocks = [
            (-125.0, -92.0, 26.0, 0.08),
            (-76.0, -162.0, 34.0, 0.03),
            (-24.0, -210.0, 42.0, 0.00),
            (32.0,  -198.0, 38.0, 0.02),
            (84.0,  -150.0, 32.0, 0.05),
            (132.0, -86.0,  24.0, 0.09),
        ]
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))

            # Glowing subterranean seismic crack ring at ground level
            er = np.sqrt(((xx - cx) / (185.0 * (0.4 + 0.65 * t))) ** 2 + ((yy - cy) / (66.0 * (0.4 + 0.65 * t))) ** 2)
            ring = np.exp(-((np.abs(er - 1.0) / 0.16) ** 2)) * env
            add_layer(buf, blur_channel(ring, 6.0) * 1.15, (1.00, 0.56, 0.10), additive=True)
            add_layer(buf, ring * 1.25, (1.00, 0.92, 0.52), additive=True)

            # Jagged erupting dark basalt rock spikes with golden magma fissures!
            for ox, oy, bw, dl in rocks:
                st = max(0.0, min(1.0, (t - dl) / 0.34))
                if st <= 0.02:
                    continue
                grow = st ** 0.58
                bx0 = cx + ox * 0.45
                by0 = cy + 16.0
                tx = bx0 + ox * 0.55 * grow
                ty = by0 + oy * grow
                d, s = dist_to_segment(xx, yy, bx0, by0, tx, ty)
                w = bw * (1.0 - s * 0.78) * (0.85 + 0.30 * noise) * (1.0 - max(0.0, t - 0.70) * 1.0)
                rm = 1.0 - smoothstep(w * 0.78, w * 1.06, d)
                add_layer(buf, rm * 0.96 * env, (0.20, 0.16, 0.13), additive=False)
                # Rim magma/amber highlight along jagged edge
                rim = rm * smoothstep(w * 0.42, w * 0.95, d) * env
                add_layer(buf, rim * 1.05, (1.00, 0.66, 0.18), additive=True)
                add_layer(buf, blur_channel(rim, 4.0) * 0.75, (1.00, 0.42, 0.08), additive=True)

            # Shock dust burst cloud
            dr = np.sqrt(((xx - cx) / 170.0) ** 2 + ((yy - (cy - 40.0)) / 100.0) ** 2)
            dust = np.exp(-(dr ** 2.0) * 1.6) * smoothstep(0.32, 0.80, noise) * env * 0.62
            add_layer(buf, blur_channel(dust, 7.0), (0.64, 0.48, 0.28), additive=False)

            frames.append((f"wx_kin_earth_shatter_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 17. SUPERSONIC ARROW / NEEDLE BARRAGE (`wx_kin_arrow_barrage`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_arrow_barrage_frames():
        W, H = 300, 160
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cy = SH * 0.50

        streams = [
            (-82.0, -0.14, 0.00),
            (-48.0, -0.08, 0.06),
            (-18.0, -0.03, 0.12),
            (0.0,    0.00, 0.02),
            (22.0,   0.04, 0.10),
            (52.0,   0.09, 0.05),
            (84.0,   0.15, 0.14),
        ]
        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.12, t) * (1.0 - smoothstep(0.78, 1.06, t))

            for y_off, slope, dl in streams:
                st = max(0.0, min(1.0, (t - dl) / 0.86))
                if st <= 0.01:
                    continue
                s_env = smoothstep(-0.04, 0.14, st) * (1.0 - smoothstep(0.80, 1.04, st))
                head_x = SW * (0.14 + 0.82 * (st ** 0.82))
                tail_x = max(SW * 0.03, head_x - 245.0 * (0.55 + 0.45 * math.sin(st * math.pi)))
                y0 = cy + y_off * 0.55 + (tail_x - SW * 0.5) * slope
                y1 = cy + y_off * 0.55 + (head_x - SW * 0.5) * slope
                d, s = dist_to_segment(xx, yy, tail_x, y0, head_x, y1)
                w = 2.0 + 7.5 * (s ** 1.1)
                m = np.exp(-((d / w) ** 2.0)) * smoothstep(0.0, 0.18, s) * s_env * env
                add_layer(buf, blur_channel(m, 5.0) * 1.00, (1.00, 0.72, 0.18), additive=True)
                add_layer(buf, np.exp(-((d / np.maximum(w * 0.36, 1.2)) ** 2.0)) * smoothstep(0.15, 0.95, s) * s_env * env * 1.35, (1.00, 0.99, 0.90), additive=True)

                # Sparkling impact star at right edge when projectile arrives!
                if st > 0.62:
                    ik = math.sin(((st - 0.62) / 0.38) * math.pi)
                    gd = np.sqrt((xx - head_x) ** 2 + (yy - y1) ** 2)
                    add_layer(buf, np.exp(-gd / 22.0) * ik * 1.15, (1.00, 0.86, 0.38), additive=True)

            frames.append((f"wx_kin_arrow_barrage_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 18. CONCENTRIC SONIC LION-ROAR WAVE (`wx_kin_sonic_wave`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_sonic_wave_frames():
        W, H = 260, 220
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.50
        noise = fbm_2d(xx, yy, scale=24.0, seed=3109)
        rx = (xx - cx) / 1.15
        ry = (yy - cy) / 0.96
        r = np.sqrt(rx * rx + ry * ry)
        ang = np.arctan2(ry, rx)

        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))

            # 4 expanding golden-bronze acoustic ripples with calligraphic air distortion
            for wi in range(4):
                wt = t * 1.38 - wi * 0.18
                if wt <= 0.01 or wt >= 1.05:
                    continue
                w_env = math.sin(min(1.0, wt) * math.pi)
                rad = 26.0 + (wt ** 0.78) * 186.0
                wobble = (noise - 0.5) * 14.0 + np.sin(ang * 8.0 + t * 9.0) * 5.0
                dist = np.abs(r - (rad + wobble))
                thick = 16.0 * (1.0 - wt * 0.45)
                m = np.exp(-((dist / max(3.0, thick)) ** 2.0)) * w_env * env
                add_layer(buf, blur_channel(m, 6.5) * 1.05, (1.00, 0.72, 0.18), additive=True)
                add_layer(buf, np.exp(-((dist / max(1.8, thick * 0.36)) ** 2.0)) * w_env * env * 1.30, (1.00, 0.98, 0.84), additive=True)

            # Central roaring air-flash core in early frames
            if t < 0.55:
                ck = math.sin((t / 0.55) * math.pi)
                add_layer(buf, np.exp(-((r / 52.0) ** 2)) * ck * 0.95, (1.00, 0.92, 0.56), additive=True)

            frames.append((f"wx_kin_sonic_wave_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 19. ROTATING YIN-YANG TAIJI & BAGUA SEAL (`wx_kin_taiji_seal`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_taiji_seal_frames():
        W, H = 240, 240
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.50
        dx0 = xx - cx
        dy0 = yy - cy
        r = np.sqrt(dx0 * dx0 + dy0 * dy0)

        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            sc = 0.74 + 0.30 * (t ** 0.6)
            rot = t * math.pi * 1.45
            cr, sr = math.cos(rot), math.sin(rot)
            rx = (dx0 * cr - dy0 * sr) / sc
            ry = (dx0 * sr + dy0 * cr) / sc
            rr = np.sqrt(rx * rx + ry * ry)
            ang = np.arctan2(ry, rx)

            # Outer Bagua 8-trigram segmented luminous ring (`R = 148..178`)
            seg_a = ((ang + math.pi) / (math.pi * 2.0)) * 8.0
            in_trigram = smoothstep(0.12, 0.22, seg_a % 1.0) * (1.0 - smoothstep(0.78, 0.88, seg_a % 1.0))
            b_ring = (
                np.exp(-((np.abs(rr - 154.0) / 4.2) ** 2))
                + np.exp(-((np.abs(rr - 166.0) / 4.2) ** 2))
                + np.exp(-((np.abs(rr - 178.0) / 4.2) ** 2))
            ) * in_trigram * env
            add_layer(buf, blur_channel(b_ring, 4.5) * 0.95, (0.28, 0.86, 1.00), additive=True)
            add_layer(buf, b_ring * 1.15, (0.94, 0.98, 1.00), additive=True)

            # Inner Taiji Disc (`R = 112`): Dark Ink Yin half vs Radiant Cyan-Gold Yang half!
            R0 = 112.0
            in_disc = 1.0 - smoothstep(R0 - 3.0, R0 + 3.0, rr)
            # S-curve separating Yin and Yang
            d_top = np.sqrt(rx * rx + (ry + R0 * 0.5) ** 2)
            d_bot = np.sqrt(rx * rx + (ry - R0 * 0.5) ** 2)
            is_yang = (rx >= 0.0).astype(np.float32)
            is_yang = np.where(d_top < R0 * 0.5, 1.0, is_yang)
            is_yang = np.where(d_bot < R0 * 0.5, 0.0, is_yang)
            # Eyes of the two fish
            is_yang = np.where(d_top < R0 * 0.16, 0.0, is_yang)
            is_yang = np.where(d_bot < R0 * 0.16, 1.0, is_yang)
            is_yang_s = blur_channel(is_yang, 2.2)

            yin_m = in_disc * (1.0 - is_yang_s) * env
            yang_m = in_disc * is_yang_s * env
            add_layer(buf, yin_m * 0.80, (0.04, 0.07, 0.12), additive=False)
            add_layer(buf, blur_channel(yang_m, 7.0) * 0.78, (0.24, 0.88, 1.00), additive=True)
            add_layer(buf, yang_m * 0.82, (0.92, 0.98, 1.00), additive=True)

            # Bright outline ring around Taiji core
            rim = np.exp(-((np.abs(rr - R0) / 4.5) ** 2)) * env
            add_layer(buf, blur_channel(rim, 5.0) * 1.05, (1.00, 0.84, 0.36), additive=True)
            add_layer(buf, rim * 1.25, (1.00, 1.00, 0.94), additive=True)

            frames.append((f"wx_kin_taiji_seal_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 20. GOLDEN BUDDHIST BELL / XUANWU DOME (`wx_kin_golden_dome`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_golden_dome_frames():
        W, H = 240, 240
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.56
        noise = fbm_2d(xx, yy, scale=22.0, seed=3203)

        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))
            sc = 0.76 + 0.28 * (t ** 0.65)
            # Majestic temple bell silhouette (rounded dome top + gently flared skirt bottom)
            ny = (yy - cy) / (155.0 * sc)  # [-1.0 top .. +0.85 bottom]
            flare = 1.0 + 0.22 * np.clip(ny, 0.0, 1.0)
            bell_w = np.where(ny < 0.0, np.sqrt(np.maximum(0.0, 1.0 - np.clip(ny, -1.0, 0.0) ** 2)), 1.0) * 136.0 * sc * flare
            in_y = smoothstep(-1.02, -0.94, ny) * (1.0 - smoothstep(0.76, 0.84, ny))
            nx = np.abs(xx - cx) / np.maximum(bell_w, 4.0)
            in_bell = (1.0 - smoothstep(0.92, 1.04, nx)) * in_y

            # Translucent golden barrier interior + strong glowing rim edge (Fresnel look!)
            fresnel = (0.20 + 0.80 * (np.clip(nx, 0.0, 1.0) ** 2.2)) * in_bell * (0.78 + 0.22 * noise) * env
            add_layer(buf, blur_channel(fresnel, 8.0) * 0.95, (1.00, 0.68, 0.12), additive=True)
            add_layer(buf, fresnel * 0.92, (1.00, 0.88, 0.44), additive=True)

            # Sharp radiant bell contour + 3 ornate horizontal Buddhist bands
            edge_x = np.exp(-((np.abs(nx - 0.96) / 0.065) ** 2)) * in_y * env
            bands = (
                np.exp(-((np.abs(ny - 0.74) / 0.045) ** 2))
                + np.exp(-((np.abs(ny - 0.30) / 0.032) ** 2))
                + np.exp(-((np.abs(ny + 0.18) / 0.032) ** 2))
            ) * in_bell * env
            add_layer(buf, (edge_x + bands * 0.85) * 1.25, (1.00, 0.96, 0.78), additive=True)

            # Ground sacred shockwave ring expanding from bell rim
            er = np.sqrt(((xx - cx) / (178.0 * (0.55 + 0.55 * t))) ** 2 + ((yy - (cy + 115.0 * sc)) / (52.0 * (0.55 + 0.55 * t))) ** 2)
            gr = np.exp(-((np.abs(er - 1.0) / 0.14) ** 2)) * env
            add_layer(buf, blur_channel(gr, 5.0) * 1.05, (1.00, 0.74, 0.18), additive=True)
            add_layer(buf, gr * 1.20, (1.00, 0.98, 0.86), additive=True)

            frames.append((f"wx_kin_golden_dome_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 21. QINGGONG INK-CLOUD WIND GUST (`wx_kin_qinggong_gust`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_qinggong_gust_frames():
        W, H = 260, 200
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.62
        noise = fbm_2d(xx, yy, scale=24.0, seed=3301)

        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.12, t) * (1.0 - smoothstep(0.78, 1.06, t))

            # 3 graceful ascending ink-wind calligraphic ribbons swirling upward
            for ri, phase, rgb in (
                (0, 0.0,  (0.16, 0.86, 0.96)),
                (1, 2.1,  (0.46, 0.98, 0.82)),
                (2, 4.2,  (0.92, 0.99, 1.00)),
            ):
                pts = []
                widths = []
                n_pts = 16
                for k in range(n_pts + 1):
                    s = k / float(n_pts)
                    ang = phase + s * 4.2 + t * 5.2
                    rad = (45.0 + s * 110.0) * (0.72 + 0.45 * t)
                    px = cx + math.cos(ang) * rad * 1.25
                    py = cy + 28.0 - (s * 165.0 + t * 65.0) + math.sin(ang) * rad * 0.34
                    pts.append((px, py))
                    w = (3.0 + 13.0 * math.sin(s * math.pi)) * (1.0 - t * 0.28)
                    widths.append(max(1.5, w))
                nd, _ = dist_to_polyline(xx, yy, pts, widths)
                add_layer(buf, np.exp(-((nd / 1.35) ** 2)) * 0.65 * env, (0.04, 0.14, 0.18), additive=False)
                m = np.exp(-((nd / 0.85) ** 2)) * (0.70 + 0.30 * noise) * env
                add_layer(buf, blur_channel(m, 5.0) * 0.95, rgb, additive=True)
                add_layer(buf, np.exp(-((nd / 0.35) ** 2)) * env * 1.25, (1.00, 1.00, 1.00), additive=True)

            frames.append((f"wx_kin_qinggong_gust_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 22. ABYSSAL QI-SIPHON / RADIANT VORTEX (`wx_kin_soul_vortex`, 10 frames)
    # -----------------------------------------------------------------------
    def gen_soul_vortex_frames():
        W, H = 250, 230
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.50
        dx = xx - cx
        dy = yy - cy
        r = np.sqrt(dx * dx + dy * dy)
        ang = np.arctan2(dy, dx)
        noise = fbm_2d(xx, yy, scale=22.0, seed=3407)

        frames = []
        N = 10
        for fi in range(N):
            t = (fi + 0.45) / float(N)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            env = smoothstep(-0.06, 0.14, t) * (1.0 - smoothstep(0.78, 1.06, t))

            # 4 swirling spiral arms imploding toward bright vortex core!
            r_norm = r / 195.0
            spiral_a = ang * 4.0 + r_norm * 8.5 - t * 11.0
            arms = smoothstep(0.15, 0.92, np.cos(spiral_a)) * np.exp(-(r_norm ** 1.8) * 1.8) * smoothstep(0.08, 0.28, r_norm) * (0.62 + 0.38 * noise) * env

            # Dark ink outer spiral
            add_layer(buf, blur_channel(arms, 5.0) * 0.92, (0.08, 0.02, 0.16), additive=False)
            # Luminous violet-magenta spiral glow
            add_layer(buf, blur_channel(arms, 7.5) * 1.15, (0.66, 0.22, 1.00), additive=True)
            add_layer(buf, arms * 1.15, (0.96, 0.72, 1.00), additive=True)

            # Singularity eye core (dark abyssal pupil + blazing rim)
            core_r = 26.0 + 14.0 * math.sin(t * math.pi)
            pupil = (1.0 - smoothstep(core_r * 0.65, core_r * 1.0, r)) * env
            rim = np.exp(-((np.abs(r - core_r) / 6.5) ** 2)) * env
            add_layer(buf, pupil * 0.92, (0.04, 0.01, 0.08), additive=False)
            add_layer(buf, blur_channel(rim, 5.5) * 1.15, (0.82, 0.42, 1.00), additive=True)
            add_layer(buf, rim * 1.35, (1.00, 0.96, 1.00), additive=True)

            frames.append((f"wx_kin_soul_vortex_{fi:02d}", buf_to_image(buf, (W, H))))
        return frames

    # -----------------------------------------------------------------------
    # 12 NEW ELEMENTAL MICRO-PARTICLES & GROUND DECALS
    # -----------------------------------------------------------------------
    def gen_extra_particles():
        out = []

        def make_spark(name, outer_rgb, core_rgb):
            W, H = 56, 28
            SW, SH = W * 2, H * 2
            yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
            cx, cy = SW * 0.52, SH * 0.50
            dx = (xx - cx) / (SW * 0.40)
            dy = (yy - cy) / (SH * 0.20)
            buf = np.zeros((SH, SW, 4), dtype=np.float32)
            g_out = np.exp(-(dx * dx * 1.1 + dy * dy * 1.5))
            g_core = np.exp(-(dx * dx * 2.2 + dy * dy * 5.2))
            add_layer(buf, blur_channel(g_out, 5.0) * 0.95, outer_rgb, additive=True)
            add_layer(buf, g_core * 1.3, core_rgb, additive=True)
            out.append((name, buf_to_image(buf, (W, H))))

        make_spark("wx_pt_spark_crimson", (0.96, 0.14, 0.18), (1.00, 0.90, 0.88))
        make_spark("wx_pt_spark_jade",    (0.18, 0.94, 0.62), (0.94, 1.00, 0.96))
        make_spark("wx_pt_spark_frost",   (0.32, 0.86, 1.00), (0.96, 0.99, 1.00))
        make_spark("wx_pt_spark_venom",   (0.36, 0.96, 0.24), (0.90, 1.00, 0.72))

        def make_ring(name, outer_rgb, core_rgb):
            W, H = 160, 108
            SW, SH = W * 2, H * 2
            yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
            n = fbm_2d(xx, yy, scale=22.0, seed=3600 + len(name))
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

        make_ring("wx_pt_ring_crimson", (0.92, 0.12, 0.16), (1.00, 0.86, 0.82))
        make_ring("wx_pt_ring_jade",    (0.18, 0.90, 0.60), (0.92, 1.00, 0.95))
        make_ring("wx_pt_ring_frost",   (0.34, 0.86, 1.00), (0.95, 0.99, 1.00))
        make_ring("wx_pt_ring_venom",   (0.34, 0.92, 0.22), (0.86, 1.00, 0.64))

        # 9. Drifting Martial Blossom Petal (`wx_pt_petal`)
        W, H = 36, 36
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        px = (xx - SW * 0.50) / 18.0
        py = (yy - SH * 0.50) / 26.0
        d = np.sqrt((px / (0.85 - 0.25 * py)) ** 2 + py * py)
        buf = np.zeros((SH, SW, 4), dtype=np.float32)
        pm = 1.0 - smoothstep(0.84, 1.02, d)
        add_layer(buf, pm * 0.95, (1.00, 0.58, 0.72), additive=False)
        add_layer(buf, pm * smoothstep(-0.8, 0.8, -py) * 0.85, (1.00, 0.92, 0.96), additive=True)
        out.append(("wx_pt_petal", buf_to_image(buf, (W, H))))

        # 10. Crystalline Ice Shard (`wx_pt_ice_shard`)
        W, H = 40, 40
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        px = np.abs(xx - SW * 0.50)
        py = np.abs(yy - SH * 0.50)
        diam = (px / 14.0) + (py / 28.0)
        buf = np.zeros((SH, SW, 4), dtype=np.float32)
        im = 1.0 - smoothstep(0.88, 1.05, diam)
        add_layer(buf, im * 0.92, (0.28, 0.82, 1.00), additive=False)
        add_layer(buf, im * (1.0 - smoothstep(0.0, 0.65, diam)) * 1.15, (0.94, 0.99, 1.00), additive=True)
        out.append(("wx_pt_ice_shard", buf_to_image(buf, (W, H))))

        # 11. Isometric Ground Frost Rime Patch (`wx_pt_frost_patch`)
        W, H = 160, 104
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.52
        n = fbm_2d(xx, yy, scale=20.0, seed=3701)
        er = np.sqrt(((xx - cx) / 118.0) ** 2 + ((yy - cy) / 68.0) ** 2)
        buf = np.zeros((SH, SW, 4), dtype=np.float32)
        ice_base = np.exp(-(er ** 2.2) * 1.5) * (0.55 + 0.45 * n) * 0.82
        add_layer(buf, ice_base, (0.14, 0.54, 0.88), additive=False)
        cracks = np.zeros_like(xx)
        for ci in range(6):
            ca = ci * (math.pi / 3.0) + 0.2
            pts = make_jagged_bolt(cx, cy, cx + math.cos(ca) * 116.0, cy + math.sin(ca) * 66.0, 4, 9.0, 3720 + ci * 13)
            cnd, _ = dist_to_polyline(xx, yy, pts, [4.5, 3.6, 2.8, 2.0, 1.2])
            cracks = np.maximum(cracks, np.exp(-((cnd / 1.0) ** 2)))
        add_layer(buf, blur_channel(cracks, 4.0) * 0.95, (0.48, 0.92, 1.00), additive=True)
        add_layer(buf, cracks * 1.2, (0.96, 1.00, 1.00), additive=True)
        out.append(("wx_pt_frost_patch", buf_to_image(buf, (W, H))))

        # 12. Isometric Bubbling Venom Ground Pool (`wx_pt_venom_pool`)
        W, H = 160, 104
        SW, SH = W * 2, H * 2
        yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
        cx, cy = SW * 0.50, SH * 0.52
        n = fbm_2d(xx, yy, scale=20.0, seed=3801)
        er = np.sqrt(((xx - cx) / 116.0) ** 2 + ((yy - cy) / 66.0) ** 2)
        buf = np.zeros((SH, SW, 4), dtype=np.float32)
        pool = np.exp(-(er ** 2.4) * 1.6) * (0.55 + 0.45 * n) * 0.88
        add_layer(buf, pool, (0.12, 0.04, 0.20), additive=False)
        acid = np.exp(-(er ** 2.2) * 1.9) * smoothstep(0.32, 0.78, n) * 0.95
        add_layer(buf, blur_channel(acid, 4.5) * 1.05, (0.20, 0.88, 0.24), additive=True)
        add_layer(buf, acid * 1.1, (0.68, 1.00, 0.36), additive=True)
        out.append(("wx_pt_venom_pool", buf_to_image(buf, (W, H))))

        return out

    return {
        "page1": [
            ("blood_arc",     gen_blood_arc_frames()),
            ("spear_drill",   gen_spear_drill_frames()),
            ("whirl_cyclone", gen_whirl_cyclone_frames()),
            ("claw_rend",     gen_claw_rend_frames()),
            ("whip_lash",     gen_whip_lash_frames()),
            ("shadow_cross",  gen_shadow_cross_frames()),
        ],
        "page2": [
            ("buddha_palm",   gen_buddha_palm_frames()),
            ("frost_burst",   gen_frost_burst_frames()),
            ("venom_mire",    gen_venom_mire_frames()),
            ("earth_shatter", gen_earth_shatter_frames()),
            ("arrow_barrage", gen_arrow_barrage_frames()),
            ("sonic_wave",    gen_sonic_wave_frames()),
        ],
        "page3": [
            ("taiji_seal",    gen_taiji_seal_frames()),
            ("golden_dome",   gen_golden_dome_frames()),
            ("qinggong_gust", gen_qinggong_gust_frames()),
            ("soul_vortex",   gen_soul_vortex_frames()),
            ("extra_parts",   gen_extra_particles()),
        ],
    }
