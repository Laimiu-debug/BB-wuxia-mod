#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
《战场兄弟：武侠江湖 · 山海兵主篇》— 100% From-Scratch Local Zero-Cloud 1080p Renderer
ZERO Runway / ZERO cloud assets!

Inputs (100% local):
- 3 local Qwen Image 2.1 keyframes: promo/from_scratch_local/keyframes/sc_01..03.png
- 3 local MiniMax H3 FL2VA videos with native stereo audio: promo/from_scratch_local/clips/sc_01..03.mp4
- Raw in-game mod sprites: art/hd/wx_boss_*.png, art/hd/wx_core_*.png, art/anim/wx_anim_*.png

Output:
- promo/from_scratch_local/BB_Wuxia_FromScratch_Local_1080p.mp4 (1920x1080, 24fps, H.264 + AAC 192k)
"""

import math
import os
import subprocess
import time
import wave
import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont
from scipy.signal import butter, sosfilt
import imageio_ffmpeg

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

W, H = 1920, 1080
FPS = 24
TOTAL_DUR = 19.00
TOTAL_FRAMES = int(round(TOTAL_DUR * FPS))  # 456 frames
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()

BASE_DIR = os.path.join("promo", "from_scratch_local")
KF_DIR = os.path.join(BASE_DIR, "keyframes")
CLIP_DIR = os.path.join(BASE_DIR, "clips")
OUT_MP4 = os.path.join(BASE_DIR, "BB_Wuxia_FromScratch_Local_1080p.mp4")
TMP_WAV = os.path.join(BASE_DIR, "_tmp_scratch_audio.wav")

FONT_CALLIG = r"C:\Windows\Fonts\STXINWEI.TTF"   # 华文新魏
FONT_BRUSH  = r"C:\Windows\Fonts\STXINGKA.TTF"   # 华文行楷
FONT_SERIF  = r"C:\Windows\Fonts\STZHONGS.TTF"   # 华文中宋
FONT_SANS   = r"C:\Windows\Fonts\msyhbd.ttc"     # 微软雅黑粗体


def load_font(path, size):
    try:
        return ImageFont.truetype(path, size)
    except Exception:
        return ImageFont.truetype(r"C:\Windows\Fonts\simhei.ttf", size)


F_TITLE_LG  = load_font(FONT_CALLIG, 62)
F_STAMP     = load_font(FONT_BRUSH,  34)
F_CALLOUT   = load_font(FONT_SERIF,  34)
F_CALLOUT_S = load_font(FONT_SANS,   22)
F_SUB       = load_font(FONT_SERIF,  42)
F_CARD_NAME = load_font(FONT_SERIF,  30)
F_CARD_SUB  = load_font(FONT_SANS,   20)
F_RIBBON    = load_font(FONT_SERIF,  22)


# ==============================================================================
# 1. 100% LOCAL AUDIO MASTERING (MiniMax H3 Native Stereo + Procedural War Drums)
# ==============================================================================
def decode_stereo_pcm(path, sr=48000):
    cmd = [FFMPEG, "-i", path, "-f", "s16le", "-ac", "2", "-ar", str(sr), "-v", "error", "pipe:1"]
    p = subprocess.run(cmd, capture_output=True, check=True)
    arr = np.frombuffer(p.stdout, dtype=np.int16).astype(np.float32) / 32768.0
    if len(arr) == 0:
        return np.zeros((sr, 2), dtype=np.float32)
    return arr.reshape(-1, 2)


def lowpass(sig, cutoff_hz=320.0, sr=48000):
    sos = butter(3, cutoff_hz / (0.5 * sr), btype="lowpass", output="sos")
    out = np.empty_like(sig)
    out[:, 0] = sosfilt(sos, sig[:, 0])
    out[:, 1] = sosfilt(sos, sig[:, 1])
    return out


def rms_normalize(sig, target_rms=0.19, max_peak=0.88):
    rms = float(np.sqrt(np.mean(sig ** 2))) + 1e-6
    g = min(target_rms / rms, max_peak / (float(np.max(np.abs(sig))) + 1e-6))
    return sig * g


def synth_war_drum_bridge(dur_s, sr=48000):
    """Synthesize a dark cinematic taiko war-drum + sub-riser bed for the 3.0s raw-asset intercut."""
    n = int(round(dur_s * sr))
    t = np.arange(n, dtype=np.float32) / sr
    out = np.zeros((n, 2), dtype=np.float32)
    rng = np.random.default_rng(777)

    # 3 heavy taiko war-drum hits at 0.05s, 1.05s, 2.05s + fast double-hit at 2.68s
    for hit_t, amp, base_f in [(0.04, 0.58, 62.0), (1.04, 0.52, 58.0), (2.04, 0.62, 54.0), (2.68, 0.45, 70.0)]:
        i0 = int(hit_t * sr)
        hit_len = min(n - i0, int(0.95 * sr))
        if hit_len <= 0:
            continue
        lt = np.arange(hit_len, dtype=np.float32) / sr
        # Pitch drop boom (120Hz -> base_f)
        phase = 2.0 * np.pi * (base_f * lt + 70.0 * (1.0 - np.exp(-lt * 16.0)) / 16.0)
        body = np.sin(phase) * np.exp(-lt * 4.2)
        # Muffled skin slap transient
        noise = rng.standard_normal(hit_len).astype(np.float32) * np.exp(-lt * 34.0) * 0.25
        hit = (body + noise) * amp
        out[i0:i0 + hit_len, 0] += hit
        out[i0:i0 + hit_len, 1] += hit * 0.96

    # Low ominous sub-drone + rising tension swell into Act 2 boss clash
    riser_env = (t / dur_s) ** 2.2
    drone = (
        0.14 * np.sin(2.0 * np.pi * 49.0 * t)
        + 0.09 * np.sin(2.0 * np.pi * 73.4 * t)
        + 0.16 * riser_env * np.sin(2.0 * np.pi * (55.0 + 45.0 * riser_env) * t)
    )
    # Filtered dark wind texture
    wind = rng.standard_normal((n, 2)).astype(np.float32) * (0.04 + 0.09 * riser_env)[:, None]
    wind = lowpass(wind, 420.0, sr)

    out[:, 0] += drone
    out[:, 1] += drone
    out += wind
    # Smooth edges
    fe = int(0.18 * sr)
    out[:fe] *= np.linspace(0.0, 1.0, fe, dtype=np.float32)[:, None]
    out[-fe:] *= np.linspace(1.0, 0.0, fe, dtype=np.float32)[:, None]
    return out


def build_master_audio():
    sr = 48000
    n_tot = int(round(TOTAL_DUR * sr))
    print("[Audio] Mastering 100% local MiniMax H3 native stereo tracks + taiko bridge...")

    a1 = rms_normalize(decode_stereo_pcm(os.path.join(CLIP_DIR, "sc_01_chiyou_awakens.mp4"), sr), target_rms=0.21)
    a2 = rms_normalize(decode_stereo_pcm(os.path.join(CLIP_DIR, "sc_02_duel_chiyou.mp4"), sr), target_rms=0.22)
    a3 = rms_normalize(decode_stereo_pcm(os.path.join(CLIP_DIR, "sc_03_title_chiyou.mp4"), sr), target_rms=0.19)

    mix = np.zeros((n_tot, 2), dtype=np.float32)

    def place_clip(sig, t_start, dur_s, fade_in=0.12, fade_out=0.22):
        n_use = min(len(sig), int(round(dur_s * sr)))
        seg = sig[:n_use].copy()
        fi = min(int(fade_in * sr), n_use // 3)
        fo = min(int(fade_out * sr), n_use // 3)
        if fi > 0:
            seg[:fi] *= np.linspace(0.0, 1.0, fi, dtype=np.float32)[:, None]
        if fo > 0:
            seg[-fo:] *= np.linspace(1.0, 0.0, fo, dtype=np.float32)[:, None]
        i0 = int(round(t_start * sr))
        i1 = min(n_tot, i0 + n_use)
        mix[i0:i1] += seg[:i1 - i0]

    # Act 1 (0.00 - 5.17s)
    place_clip(a1, 0.00, 5.17, fade_in=0.10, fade_out=0.30)

    # Intercut dark ambient bed (4.95 - 8.25s) using low-passed tail resonance of a1 + procedural taiko drums
    bridge_dur = 3.30
    bridge = synth_war_drum_bridge(bridge_dur, sr)
    tail_src = a1[-min(len(a1), int(1.8 * sr)):]
    tail_lp = lowpass(tail_src, 260.0, sr) * 0.45
    # Mirror-loop tail_lp to cover bridge_dur smoothly
    tail_loop = np.concatenate([tail_lp, tail_lp[::-1], tail_lp], axis=0)[:len(bridge)].copy()
    fe = int(0.35 * sr)
    tail_loop[:fe] *= np.linspace(0.0, 1.0, fe, dtype=np.float32)[:, None]
    tail_loop[-fe:] *= np.linspace(1.0, 0.0, fe, dtype=np.float32)[:, None]
    i0 = int(round(4.95 * sr))
    i1 = min(n_tot, i0 + len(bridge))
    mix[i0:i1] += (bridge + tail_loop)[:i1 - i0]

    # Act 2 (8.10 - 13.27s)
    place_clip(a2, 8.10, 5.17, fade_in=0.14, fade_out=0.28)

    # Act 3 (13.20 - 17.66s) + resonant gong/xiao reverb tail decaying cleanly to 19.00s
    place_clip(a3, 13.20, 4.46, fade_in=0.16, fade_out=0.35)
    # Extend last 1.4s of a3 as a soft low-passed fading echo over the 17.66-19.00s title hold
    hold_tail = a3[-min(len(a3), int(1.55 * sr)):].copy()
    hold_tail = lowpass(hold_tail, 950.0, sr) * 0.55
    decay = np.linspace(1.0, 0.0, len(hold_tail), dtype=np.float32) ** 1.8
    hold_tail *= decay[:, None]
    h0 = int(round(17.40 * sr))
    h1 = min(n_tot, h0 + len(hold_tail))
    mix[h0:h1] += hold_tail[:h1 - h0]

    # Global final fade-out (18.15 - 19.00s)
    fo_n = int(0.85 * sr)
    mix[-fo_n:] *= (np.linspace(1.0, 0.0, fo_n, dtype=np.float32) ** 1.5)[:, None]

    # Soft master limiter (clean -0.7 dBFS ceiling)
    mix = np.tanh(mix * 1.10) * 0.92
    pcm16 = np.clip(mix * 32767.0, -32768, 32767).astype(np.int16)
    with wave.open(TMP_WAV, "wb") as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(pcm16.tobytes())
    print(f"[Audio] Saved 100% local mastered WAV: {TMP_WAV} ({TOTAL_DUR:.2f}s @ {sr}Hz)")


# ==============================================================================
# 2. VIDEO / IMAGE HELPERS
# ==============================================================================
def load_video_frames_1080p(path):
    cap = cv2.VideoCapture(path)
    frames = []
    while True:
        ok, bgr = cap.read()
        if not ok:
            break
        rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
        sh, sw = rgb.shape[:2]
        scale = max(W / sw, H / sh)
        nw, nh = int(round(sw * scale)), int(round(sh * scale))
        resized = cv2.resize(rgb, (nw, nh), interpolation=cv2.INTER_LANCZOS4)
        x0, y0 = (nw - W) // 2, (nh - H) // 2
        cropped = resized[y0:y0 + H, x0:x0 + W]
        blur = cv2.GaussianBlur(cropped, (0, 0), 1.0)
        sharp = cv2.addWeighted(cropped, 1.15, blur, -0.15, 0)
        frames.append(sharp)
    cap.release()
    print(f"  Loaded {os.path.basename(path)}: {len(frames)} frames -> 1920x1080")
    return frames


def load_rgba(path, max_size=None):
    im = Image.open(path).convert("RGBA")
    if max_size is not None:
        tw, th = max_size
        scale = min(tw / im.width, th / im.height)
        nw, nh = max(1, int(round(im.width * scale))), max(1, int(round(im.height * scale)))
        im = im.resize((nw, nh), Image.LANCZOS)
    return im


def load_bg_1080p(path, dark=0.28, blur_r=10):
    im = Image.open(path).convert("RGB")
    scale = max(W / im.width, H / im.height)
    nw, nh = int(round(im.width * scale)), int(round(im.height * scale))
    im = im.resize((nw, nh), Image.LANCZOS)
    x0, y0 = (nw - W) // 2, (nh - H) // 2
    im = im.crop((x0, y0, x0 + W, y0 + H))
    if blur_r > 0:
        im = im.filter(ImageFilter.GaussianBlur(blur_r))
    if dark != 1.0:
        im = ImageEnhance.Brightness(im).enhance(dark)
    return np.array(im, dtype=np.uint8)


def ease_out_cubic(x):
    x = max(0.0, min(1.0, x))
    return 1.0 - (1.0 - x) ** 3


def ease_in_out(x):
    x = max(0.0, min(1.0, x))
    return x * x * (3.0 - 2.0 * x)


def zoom_crop(rgb, zoom=1.0, cx=0.5, cy=0.5, dx=0.0, dy=0.0):
    if abs(zoom - 1.0) < 1e-4 and abs(dx) < 0.5 and abs(dy) < 0.5:
        return rgb
    cw, ch = W / zoom, H / zoom
    x0 = max(0.0, min(W - cw, cx * W - cw * 0.5 + dx))
    y0 = max(0.0, min(H - ch, cy * H - ch * 0.5 + dy))
    M = np.array([[zoom, 0, -x0 * zoom], [0, zoom, -y0 * zoom]], dtype=np.float32)
    return cv2.warpAffine(rgb, M, (W, H), flags=cv2.INTER_LINEAR, borderMode=cv2.BORDER_REPLICATE)


def build_vignette_mask():
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    nx = (xx - W * 0.5) / (W * 0.5)
    ny = (yy - H * 0.5) / (H * 0.5)
    r2 = nx * nx * 0.70 + ny * ny * 0.90
    vig = np.clip(1.0 - 0.38 * (r2 ** 1.35), 0.48, 1.0)
    return vig[:, :, None].astype(np.float32)


def draw_text_glow(draw, pos, text, font, fill=(246, 226, 178, 255), shadow=(8, 6, 5, 240), offset=3, anchor=None):
    x, y = pos
    for ox, oy in [(-offset, 0), (offset, 0), (0, -offset), (0, offset), (offset, offset), (-offset, offset)]:
        draw.text((x + ox, y + oy), text, font=font, fill=shadow, anchor=anchor)
    draw.text((x, y), text, font=font, fill=fill, anchor=anchor)


def alpha_blit_rgba(base_rgb, overlay_rgba, alpha_mult=1.0):
    if alpha_mult <= 0.001:
        return base_rgb
    ov = np.array(overlay_rgba, dtype=np.float32)
    a = (ov[:, :, 3:4] / 255.0) * alpha_mult
    out = base_rgb.astype(np.float32) * (1.0 - a) + ov[:, :, :3] * a
    return np.clip(out, 0, 255).astype(np.uint8)


def sample_clip(frames, local_t, clip_dur):
    n = len(frames)
    u = max(0.0, min(1.0, local_t / max(0.001, clip_dur)))
    f_pos = u * (n - 1)
    i0 = int(math.floor(f_pos))
    i1 = min(n - 1, i0 + 1)
    frac = f_pos - i0
    if frac < 0.01 or i0 == i1:
        return frames[i0]
    return cv2.addWeighted(frames[i0], 1.0 - frac, frames[i1], frac, 0)


# ==============================================================================
# 3. OVERLAYS & PROCEDURAL EMBERS
# ==============================================================================
def make_callout_overlay(seal_text, main_title, sub_title):
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    rx0, ry0, rx1, ry1 = 68, 54, 880, 164
    for x in range(rx0, rx1):
        t = (x - rx0) / float(rx1 - rx0)
        a = int(190 * (1.0 - max(0.0, (t - 0.56) / 0.44) ** 1.4))
        d.line([(x, ry0), (x, ry1)], fill=(12, 9, 9, a))
    d.line([(rx0 + 78, ry0 + 2), (rx0 + 640, ry0 + 2)], fill=(208, 168, 92, 175), width=2)
    d.line([(rx0 + 78, ry1 - 2), (rx0 + 540, ry1 - 2)], fill=(208, 168, 92, 115), width=1)

    sx0, sy0, sx1, sy1 = 80, 66, 148, 152
    d.rectangle([sx0, sy0, sx1, sy1], fill=(162, 28, 24, 242), outline=(228, 186, 120, 215), width=2)
    d.rectangle([sx0 + 4, sy0 + 4, sx1 - 4, sy1 - 4], outline=(245, 224, 200, 130), width=1)
    if len(seal_text) == 2:
        d.text(((sx0 + sx1) // 2, sy0 + 24), seal_text[0], font=F_STAMP, fill=(250, 236, 214, 255), anchor="mm")
        d.text(((sx0 + sx1) // 2, sy0 + 62), seal_text[1], font=F_STAMP, fill=(250, 236, 214, 255), anchor="mm")
    else:
        d.text(((sx0 + sx1) // 2, (sy0 + sy1) // 2), seal_text, font=F_STAMP, fill=(250, 236, 214, 255), anchor="mm")

    draw_text_glow(d, (168, 70), main_title, F_CALLOUT, fill=(248, 226, 174, 255), offset=2)
    draw_text_glow(d, (170, 118), sub_title, F_CALLOUT_S, fill=(208, 200, 188, 248), offset=2)
    return im


def make_subtitle_overlay(text, bottom_margin=84):
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    cy = H - bottom_margin
    y_top, y_bot = max(0, cy - 56), min(H, cy + 54)
    for y in range(y_top, y_bot):
        u = (y - y_top) / float(max(1, y_bot - y_top))
        a = int(165 * math.sin(u * math.pi))
        d.line([(280, y), (W - 280, y)], fill=(8, 6, 6, a))
    bbox = d.textbbox((0, 0), text, font=F_SUB)
    tw = bbox[2] - bbox[0]
    draw_text_glow(d, (W // 2, cy), text, F_SUB, fill=(252, 244, 226, 255), shadow=(6, 5, 5, 252), offset=3, anchor="mm")
    lx, rx = W // 2 - tw // 2 - 28, W // 2 + tw // 2 + 28
    d.polygon([(lx, cy - 5), (lx + 6, cy), (lx, cy + 5), (lx - 6, cy)], fill=(214, 172, 94, 215))
    d.polygon([(rx, cy - 5), (rx + 6, cy), (rx, cy + 5), (rx - 6, cy)], fill=(214, 172, 94, 215))
    return im


def make_outro_ribbon_overlay():
    """Sleek bottom footer bar at y=1046 (below y=1008 calligraphy, leaving top halberd & blood moon 100% clear)."""
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    text = "272 独创秘籍   ◆   44 江湖门派   ◆   39 传世神兵   ◆   64 尊山海大妖   ◆   7 槽武学革新"
    y_c = 1046
    d.rectangle([280, y_c - 22, W - 280, y_c + 22], fill=(10, 7, 7, 195))
    d.line([(310, y_c - 22), (W - 310, y_c - 22)], fill=(214, 168, 88, 175), width=1)
    d.line([(310, y_c + 22), (W - 310, y_c + 22)], fill=(214, 168, 88, 130), width=1)
    draw_text_glow(d, (W // 2, y_c), text, F_RIBBON, fill=(244, 214, 152, 255), offset=2, anchor="mm")
    return im


class EmberSystem:
    def __init__(self, count=72, seed=888):
        rng = np.random.default_rng(seed)
        self.x0 = rng.uniform(0, W, count)
        self.y0 = rng.uniform(0, H, count)
        self.vy = rng.uniform(45, 160, count)
        self.vx = rng.uniform(-35, 42, count)
        self.phase = rng.uniform(0, 2 * math.pi, count)
        self.radius = rng.integers(2, 5, count)
        self.bright = rng.uniform(0.55, 1.0, count)

    def render(self, rgb, t, tint=(255, 152, 64), intensity=0.75):
        if intensity <= 0.01:
            return rgb
        out = rgb.copy()
        for i in range(len(self.x0)):
            x = int((self.x0[i] + self.vx[i] * t + 26.0 * math.sin(t * 2.0 + self.phase[i])) % W)
            y = int((self.y0[i] - self.vy[i] * t) % H)
            flick = (0.65 + 0.35 * math.sin(t * 8.5 + self.phase[i])) * self.bright[i] * intensity
            r = int(self.radius[i])
            col = tuple(int(min(255, c * flick)) for c in tint)
            cv2.circle(out, (x, y), r, col, -1, lineType=cv2.LINE_AA)
            if r >= 3:
                glow = tuple(int(min(255, c * flick * 0.35)) for c in tint)
                cv2.circle(out, (x, y), r + 3, glow, 1, lineType=cv2.LINE_AA)
        return out


# ==============================================================================
# 4. LOCAL RAW-ASSET INTERCUT: CHIYOU & FOUR FIENDS BESTIARY + REAL VFX FRAMES
# ==============================================================================
class RawBestiaryIntercut:
    def __init__(self):
        self.bg = load_bg_1080p(os.path.join(KF_DIR, "sc_01_chiyou_awakens.png"), dark=0.28, blur_r=12)
        self.title_hd = load_bg_1080p(os.path.join(KF_DIR, "sc_03_title_chiyou.png"), dark=1.0, blur_r=0)
        self.cards = [
            ("兵主 · 蚩尤", "铜头铁额 · 战魄压阵",
             load_rgba("art/hd/wx_boss_chiyou.png", (335, 345)),
             load_rgba("art/hd/wx_core_chiyou.png", (96, 96))),
            ("裂风 · 穷奇", "双翼撕风 · 极速突袭",
             load_rgba("art/hd/wx_boss_qiongqi.png", (335, 345)),
             load_rgba("art/hd/wx_core_qiongqi.png", (96, 96))),
            ("凶顽 · 梼杌", "披甲虎魔 · 狂暴破甲",
             load_rgba("art/hd/wx_boss_taowu.png", (335, 345)),
             load_rgba("art/hd/wx_core_taowu.png", (96, 96))),
            ("无面 · 浑沌", "漆黑噬心 · 迷雾邪祟",
             load_rgba("art/hd/wx_boss_hundun.png", (335, 345)),
             load_rgba("art/hd/wx_core_hundun.png", (96, 96))),
        ]
        # Real 4-frame battle VFX sprites from art/anim/
        self.vfx_fire = [load_rgba(f"art/anim/wx_anim_02_f{k}.png", (420, 420)) for k in range(1, 5)]
        self.vfx_crimson = [load_rgba(f"art/anim/wx_anim_03_f{k}.png", (420, 420)) for k in range(1, 5)]

    def render(self, local_t, dur):
        u = local_t / max(0.001, dur)
        base = zoom_crop(self.bg, zoom=1.03 + 0.08 * u)
        # Subtle dark crimson mythological color grade
        tinted = base.astype(np.float32)
        tinted[:, :, 0] = np.clip(tinted[:, :, 0] * 1.24 + 14, 0, 255)
        tinted[:, :, 1] *= 0.86
        tinted[:, :, 2] *= 0.88
        im = Image.fromarray(tinted.astype(np.uint8)).convert("RGBA")

        # Animated real 4-frame in-game VFX glowing softly behind the flanks
        vf_idx = int(local_t * 9.0) % 4
        v1 = self.vfx_fire[vf_idx].copy()
        v2 = self.vfx_crimson[(vf_idx + 2) % 4].copy()
        a1 = v1.split()[3].point(lambda p: int(p * 0.42))
        v1.putalpha(a1)
        a2 = v2.split()[3].point(lambda p: int(p * 0.42))
        v2.putalpha(a2)
        im.alpha_composite(v1, (40, 240))
        im.alpha_composite(v2, (W - 460, 240))

        d = ImageDraw.Draw(im)
        hdr_a = ease_out_cubic(u / 0.22)
        draw_text_glow(
            d, (W // 2, 128), "《山海经 · 兵主蚩尤与上古四凶》", F_TITLE_LG,
            fill=(248, 206, 134, int(255 * hdr_a)), shadow=(16, 4, 4, 250), offset=3, anchor="mm",
        )
        draw_text_glow(
            d, (W // 2, 186), "实机原生手绘立绘 × 专属山海内丹掉落 × 招式气芒逐帧特效", F_CALLOUT_S,
            fill=(218, 178, 132, int(240 * hdr_a)), offset=2, anchor="mm",
        )

        # 4 tall showcase cards centered horizontally (y: 235..795, leaving clean space for subtitle at y=996)
        cw, ch = 396, 545
        gap = 38
        total_w = 4 * cw + 3 * gap
        start_x = (W - total_w) // 2
        base_y = 240

        for idx, (name, tag, boss_im, core_im) in enumerate(self.cards):
            p = ease_out_cubic((u - idx * 0.08) / 0.28)
            if p <= 0.01:
                continue
            cx = start_x + idx * (cw + gap)
            cy = int(base_y + (1.0 - p) * 60)

            d = ImageDraw.Draw(im)
            border_col = (232, 168, 78, int(245 * p)) if idx == 0 else (184, 68, 52, int(235 * p))
            d.rounded_rectangle(
                [cx, cy, cx + cw, cy + ch], radius=16,
                fill=(18, 12, 13, int(232 * p)), outline=border_col, width=3,
            )
            # Inner crimson-gold glow behind boss sprite
            glow = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
            gd = ImageDraw.Draw(glow)
            gcol = (210, 92, 36, int(92 * p)) if idx == 0 else (175, 42, 34, int(82 * p))
            gd.ellipse([cw // 2 - 125, 45, cw // 2 + 125, 355], fill=gcol)
            glow = glow.filter(ImageFilter.GaussianBlur(24))
            im.alpha_composite(glow, (cx, cy))

            # Boss raw sprite
            ix = cx + (cw - boss_im.width) // 2
            iy = cy + 28 + (350 - boss_im.height) // 2
            im.alpha_composite(boss_im, (ix, iy))

            # Matching real Neidan orb badge in top-right corner of card
            d = ImageDraw.Draw(im)
            ox, oy = cx + cw - 108, cy + 16
            d.ellipse([ox - 4, oy - 4, ox + 100, oy + 100], fill=(14, 10, 12, int(225 * p)), outline=(228, 178, 92, int(230 * p)), width=2)
            im.alpha_composite(core_im, (ox + (96 - core_im.width) // 2, oy + (96 - core_im.height) // 2))

            # Bottom text banner inside card
            d = ImageDraw.Draw(im)
            d.rectangle([cx + 4, cy + ch - 118, cx + cw - 4, cy + ch - 4], fill=(12, 8, 9, int(224 * p)))
            d.line([(cx + 24, cy + ch - 118), (cx + cw - 24, cy + ch - 118)], fill=(208, 152, 78, int(160 * p)), width=1)
            draw_text_glow(d, (cx + cw // 2, cy + ch - 78), name, F_CARD_NAME, fill=(252, 226, 166, int(255 * p)), offset=2, anchor="mm")
            d.text((cx + cw // 2, cy + ch - 34), tag, font=F_CARD_SUB, fill=(218, 134, 112, int(242 * p)), anchor="mm")

        return np.array(im.convert("RGB"), dtype=np.uint8)


# ==============================================================================
# 5. MAIN TIMELINE & FFMPEG 1080P ENCODER
# ==============================================================================
def main():
    t0 = time.time()
    build_master_audio()

    print("[Video] Loading 3 local MiniMax H3 clips -> 1920x1080...")
    c1 = load_video_frames_1080p(os.path.join(CLIP_DIR, "sc_01_chiyou_awakens.mp4"))
    c2 = load_video_frames_1080p(os.path.join(CLIP_DIR, "sc_02_duel_chiyou.mp4"))
    c3 = load_video_frames_1080p(os.path.join(CLIP_DIR, "sc_03_title_chiyou.mp4"))

    intercut = RawBestiaryIntercut()
    vig = build_vignette_mask()
    embers = EmberSystem(count=74, seed=2026)

    callouts = [
        (0.38, 4.78, make_callout_overlay("山海", "《山海经》上古兵主 · 蚩尤战魄", "铜头铁额破冢苏醒 · 统御四凶祸乱大荒")),
        (8.42, 12.88, make_callout_overlay("血战", "沥泉盘龙枪 · 烈阳火罡斩神", "轻装腾空游斗 × 重甲持枪破阵 · 12人铁人战团")),
    ]
    subtitles = [
        (0.30, 4.75, make_subtitle_overlay("大荒古冢开，兵主蚩尤醒！")),
        (5.30, 7.90, make_subtitle_overlay("上古四凶镇大荒，斩妖夺内丹！")),
        (8.35, 12.90, make_subtitle_overlay("以凡人之躯，斩上古凶神！")),
    ]
    outro_ribbon = make_outro_ribbon_overlay()

    def get_scene_frame(t):
        if t < 5.10:
            return sample_clip(c1, t, 5.10)
        elif t < 8.10:
            return intercut.render(t - 5.10, 3.00)
        elif t < 13.20:
            return sample_clip(c2, t - 8.10, 5.10)
        elif t < 17.66:
            return sample_clip(c3, t - 13.20, 4.46)
        else:
            # Seamless gentle zoom hold continuing directly from c3[-1] (zero framing jump on calligraphy!)
            lt = t - 17.66
            z = 1.00 + 0.018 * ease_in_out(lt / 1.34)
            return zoom_crop(c3[-1], zoom=z)

    cuts = [5.10, 8.10, 13.20]
    impact_cuts = {8.10, 13.20}

    cmd = [
        FFMPEG, "-y",
        "-f", "rawvideo", "-vcodec", "rawvideo", "-pix_fmt", "rgb24",
        "-s", f"{W}x{H}", "-r", str(FPS), "-i", "pipe:0",
        "-i", TMP_WAV,
        "-c:v", "libx264", "-preset", "medium", "-crf", "18", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k", "-ar", "48000",
        "-movflags", "+faststart", "-shortest",
        OUT_MP4,
    ]
    print(f"[Encode] Rendering {TOTAL_FRAMES} frames ({TOTAL_DUR:.2f}s @ 1080p {FPS}fps) -> {OUT_MP4}")
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stderr=subprocess.PIPE)

    for fi in range(TOTAL_FRAMES):
        t = fi / float(FPS)
        frame = get_scene_frame(t)

        # Crossfades & impact flash across cut boundaries (+/- 0.14s)
        for cut_t in cuts:
            dt = t - cut_t
            if -0.14 <= dt <= 0.14:
                a_img = get_scene_frame(cut_t - 0.001)
                b_img = get_scene_frame(cut_t + 0.001)
                alpha = ease_in_out((dt + 0.14) / 0.28)
                frame = cv2.addWeighted(a_img, 1.0 - alpha, b_img, alpha, 0)
                if cut_t in impact_cuts:
                    flash = math.sin(alpha * math.pi) * 0.28
                    flash_col = np.array([255, 195, 118], dtype=np.float32) if cut_t >= 13.0 else np.array([235, 92, 62], dtype=np.float32)
                    frame = np.clip(frame.astype(np.float32) * (1.0 - flash) + flash_col * flash, 0, 255).astype(np.uint8)
                break

        # Impact micro-shake right on Act 2 clash cut
        if 0.0 <= t - 8.10 < 0.30:
            decay = 1.0 - (t - 8.10) / 0.30
            sx = math.sin((t - 8.10) * 78.0) * 11.0 * decay
            sy = math.cos((t - 8.10) * 64.0) * 8.0 * decay
            frame = zoom_crop(frame, zoom=1.028, dx=sx, dy=sy)

        # Cinematic vignette
        frame = np.clip(frame.astype(np.float32) * vig, 0, 255).astype(np.uint8)

        # Rising dark-gold / crimson embers
        if t < 8.10:
            frame = embers.render(frame, t, tint=(248, 108, 56), intensity=0.72)
        elif t < 13.20:
            frame = embers.render(frame, t, tint=(255, 178, 72), intensity=0.82)
        else:
            frame = embers.render(frame, t, tint=(255, 152, 64), intensity=0.68)

        # Top-left vermilion seal callouts
        for ts, te, ov in callouts:
            if ts <= t <= te:
                fa = min(1.0, (t - ts) / 0.32, (te - t) / 0.32)
                frame = alpha_blit_rgba(frame, ov, ease_in_out(fa))
                break

        # Top prestige stats ribbon on final title card (14.20s - 18.80s)
        if t >= 14.20:
            ra = ease_in_out(min(1.0, (t - 14.20) / 0.65))
            frame = alpha_blit_rgba(frame, outro_ribbon, ra)

        # Synced bottom Chinese subtitles (Acts 1, Intercut, Act 2 only; Act 3 title calligraphy stays unobstructed!)
        for ts, te, ov in subtitles:
            if ts <= t <= te:
                fa = min(1.0, (t - ts) / 0.18, (te - t) / 0.20)
                frame = alpha_blit_rgba(frame, ov, ease_in_out(fa))
                break

        # Opening fade-in & closing fade-out
        if t < 0.42:
            frame = (frame.astype(np.float32) * ease_in_out(t / 0.42)).astype(np.uint8)
        elif t > 18.18:
            frame = (frame.astype(np.float32) * ease_in_out(max(0.0, (19.00 - t) / 0.82))).astype(np.uint8)

        proc.stdin.write(frame.tobytes())
        if (fi + 1) % 100 == 0 or fi == TOTAL_FRAMES - 1:
            print(f"  Progress: {fi + 1}/{TOTAL_FRAMES} frames ({(fi + 1) / TOTAL_FRAMES * 100:.0f}%) [{time.time() - t0:.1f}s]")

    proc.stdin.close()
    stderr_out = proc.stderr.read().decode("utf-8", errors="ignore")
    ret = proc.wait()
    if os.path.exists(TMP_WAV):
        os.remove(TMP_WAV)
    if ret != 0:
        print("FFmpeg stderr:\n", stderr_out)
        raise SystemExit(ret)

    sz_mb = os.path.getsize(OUT_MP4) / (1024 * 1024)
    print(f"[DONE] {OUT_MP4} ({sz_mb:.2f} MB) rendered in {time.time() - t0:.1f}s!")


if __name__ == "__main__":
    main()
