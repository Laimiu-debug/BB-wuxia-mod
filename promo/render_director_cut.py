#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
《战场兄弟：武侠江湖》(BB Wuxia Mod) — 1080p Director's Cut Promotional Trailer Renderer
100% local offline pipeline (Python + OpenCV + Pillow + SciPy + bundled FFmpeg, ZERO cloud credits).

Combines:
- 6 animated video clips (promo/clips/shot_01..06.mp4) with native SFX
- 6 2K keyframes (promo/keyframes/)
- 38 real in-game Mod assets (art/hd/ & art/anim/) for animated 7-slot UI, relics, VFX, and Shanhaijing bestiary intercuts
- 38s custom dark wuxia trailer score (promo/audio/trailer_bgm_38s.mp3) with automatic VO side-chain ducking
- 36.6s Chinese narrator voiceover (promo/audio/trailer_vo_zh.mp3) with frame-accurate subtitles & calligraphy stamps

Output: promo/BB_Wuxia_Mod_DirectorCut_1080p.mp4 (1920x1080, 24fps, H.264 + AAC 192kbps)
"""

import argparse
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
TOTAL_DUR = 38.0
TOTAL_FRAMES = int(round(TOTAL_DUR * FPS))  # 912 frames
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()

CLIPS_DIR = os.path.join("promo", "clips")
OUT_MP4 = os.path.join("promo", "BB_Wuxia_Mod_DirectorCut_1080p.mp4")
TMP_WAV = os.path.join("promo", "_tmp_master_audio.wav")

# Fonts (Windows built-in Chinese calligraphy & serif fonts)
FONT_CALLIG = r"C:\Windows\Fonts\STXINWEI.TTF"   # 华文新魏 (bold authoritative wuxia title)
FONT_BRUSH  = r"C:\Windows\Fonts\STXINGKA.TTF"   # 华文行楷 (flowing brush seal/accent)
FONT_SERIF  = r"C:\Windows\Fonts\STZHONGS.TTF"   # 华文中宋 (editorial subtitles & labels)
FONT_SANS   = r"C:\Windows\Fonts\msyhbd.ttc"     # 微软雅黑粗体 (crisp badges/stats)


def load_font(path, size):
    try:
        return ImageFont.truetype(path, size)
    except Exception:
        return ImageFont.truetype(r"C:\Windows\Fonts\simhei.ttf", size)


F_TITLE_LG  = load_font(FONT_CALLIG, 68)
F_TITLE_MD  = load_font(FONT_CALLIG, 48)
F_STAMP     = load_font(FONT_BRUSH,  34)
F_CALLOUT   = load_font(FONT_SERIF,  34)
F_CALLOUT_S = load_font(FONT_SANS,   22)
F_SUB       = load_font(FONT_SERIF,  42)
F_CARD_NAME = load_font(FONT_SERIF,  26)
F_CARD_SUB  = load_font(FONT_SANS,   19)
F_SLOT_LBL  = load_font(FONT_SANS,   20)
F_RIBBON    = load_font(FONT_SERIF,  28)


# ==============================================================================
# 1. AUDIO MASTERING (BGM + VO Side-Chain Ducking + Filtered Scene SFX)
# ==============================================================================
def decode_stereo_pcm(path, sr=48000):
    cmd = [FFMPEG, "-i", path, "-f", "s16le", "-ac", "2", "-ar", str(sr), "-v", "error", "pipe:1"]
    p = subprocess.run(cmd, capture_output=True, check=True)
    arr = np.frombuffer(p.stdout, dtype=np.int16).astype(np.float32) / 32768.0
    return arr.reshape(-1, 2)


def highpass(sig, cutoff_hz=180.0, sr=48000):
    sos = butter(3, cutoff_hz / (0.5 * sr), btype="highpass", output="sos")
    out = np.empty_like(sig)
    out[:, 0] = sosfilt(sos, sig[:, 0])
    out[:, 1] = sosfilt(sos, sig[:, 1])
    return out


def build_master_audio():
    sr = 48000
    n_tot = int(TOTAL_DUR * sr)
    print("[Audio] Decoding BGM, Chinese VO, and 6 scene SFX tracks...")

    bgm = decode_stereo_pcm("promo/audio/trailer_bgm_38s.mp3", sr)
    vo = decode_stereo_pcm("promo/audio/trailer_vo_zh.mp3", sr)

    def fit_len(arr, target):
        if len(arr) >= target:
            return arr[:target].copy()
        out = np.zeros((target, 2), dtype=np.float32)
        out[:len(arr)] = arr
        return out

    bgm = fit_len(bgm, n_tot)
    vo = fit_len(vo, n_tot)

    # Normalize VO gently and compute smooth ducking envelope
    vo_peak = np.max(np.abs(vo)) + 1e-6
    vo = vo * (0.86 / vo_peak)

    # Smooth RMS envelope of VO (250ms moving average)
    vo_mono = np.mean(np.abs(vo), axis=1)
    win = int(0.32 * sr)
    kernel = np.ones(win, dtype=np.float32) / win
    env = np.convolve(vo_mono, kernel, mode="same")
    # Map speech activity -> BGM gain between 0.36 (speaking) and 0.78 (action/pauses)
    speech_factor = np.clip((env - 0.012) / 0.045, 0.0, 1.0)
    bgm_gain = 0.78 - 0.42 * speech_factor

    # Extra dramatic swell during big title ending (35.5s-37.3s) then clean fade out (37.2-38.0s)
    fade_out_samples = int(0.85 * sr)
    fade_curve = np.linspace(1.0, 0.0, fade_out_samples, dtype=np.float32) ** 1.5
    bgm_gain[-fade_out_samples:] *= fade_curve

    mix = bgm * bgm_gain[:, None] + vo * 1.05

    # Layer subtle high-passed native scene SFX from each AI video clip at its exact placement
    sfx_placements = [
        (os.path.join(CLIPS_DIR, "shot_01_heroes.mp4"),         0.00,  3.55, 0.30),
        (os.path.join(CLIPS_DIR, "shot_02_cultivation.mp4"),    3.55,  3.30, 0.24),
        (os.path.join(CLIPS_DIR, "shot_03_combat_vfx.mp4"),    12.60,  4.04, 0.34),
        (os.path.join(CLIPS_DIR, "shot_04_shanhai_bosses.mp4"),20.55,  3.90, 0.30),
        (os.path.join(CLIPS_DIR, "shot_05_xingtian_clash.mp4"),24.45,  5.00, 0.36),
        (os.path.join(CLIPS_DIR, "shot_06_title_card.mp4"),    30.45,  4.00, 0.25),
    ]
    for path, t_start, dur, gain in sfx_placements:
        try:
            sfx = decode_stereo_pcm(path, sr)
            sfx = highpass(sfx, 190.0, sr)
            n_use = min(len(sfx), int(dur * sr))
            sfx = sfx[:n_use]
            # Smooth 150ms fade-in/out on SFX edges
            fe = min(int(0.18 * sr), n_use // 3)
            sfx[:fe] *= np.linspace(0.0, 1.0, fe, dtype=np.float32)[:, None]
            sfx[-fe:] *= np.linspace(1.0, 0.0, fe, dtype=np.float32)[:, None]
            i0 = int(t_start * sr)
            i1 = min(n_tot, i0 + n_use)
            # Slightly duck SFX under VO too
            local_duck = 1.0 - 0.35 * speech_factor[i0:i1]
            mix[i0:i1] += sfx[:i1 - i0] * (gain * local_duck)[:, None]
        except Exception as e:
            print(f"  [Warn] SFX skip {path}: {e}")

    # Soft master limiter (clean -0.7 dBFS ceiling, zero digital clipping)
    mix = np.tanh(mix * 1.12) * 0.92
    pcm16 = np.clip(mix * 32767.0, -32768, 32767).astype(np.int16)

    with wave.open(TMP_WAV, "wb") as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(pcm16.tobytes())
    print(f"[Audio] Mastered stereo WAV saved: {TMP_WAV} ({TOTAL_DUR:.1f}s @ {sr}Hz)")


# ==============================================================================
# 2. VIDEO CLIP & ART ASSET LOADING
# ==============================================================================
def load_video_frames_1080p(path):
    """Load video clip frames as RGB uint8 scaled cleanly to 1920x1080 with crisp ink sharpening."""
    cap = cv2.VideoCapture(path)
    frames = []
    while True:
        ok, bgr = cap.read()
        if not ok:
            break
        rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
        # Aspect-fill resize to 1920x1080 (center crop tiny vertical diff if 1280x704)
        sh, sw = rgb.shape[:2]
        scale = max(W / sw, H / sh)
        nw, nh = int(round(sw * scale)), int(round(sh * scale))
        resized = cv2.resize(rgb, (nw, nh), interpolation=cv2.INTER_LANCZOS4)
        x0 = (nw - W) // 2
        y0 = (nh - H) // 2
        cropped = resized[y0:y0 + H, x0:x0 + W]
        # Subtle ink-outline sharpening
        blur = cv2.GaussianBlur(cropped, (0, 0), 1.0)
        sharp = cv2.addWeighted(cropped, 1.16, blur, -0.16, 0)
        frames.append(sharp)
    cap.release()
    print(f"  Loaded {os.path.basename(path)}: {len(frames)} frames -> 1920x1080")
    return frames


def load_rgba(path, target_size=None):
    im = Image.open(path).convert("RGBA")
    if target_size is not None:
        tw, th = target_size
        scale = min(tw / im.width, th / im.height)
        nw, nh = max(1, int(round(im.width * scale))), max(1, int(round(im.height * scale)))
        im = im.resize((nw, nh), Image.LANCZOS)
    return im


def load_bg_1080p(path, dark=0.32, blur_r=10):
    im = Image.open(path).convert("RGB")
    scale = max(W / im.width, H / im.height)
    nw, nh = int(round(im.width * scale)), int(round(im.height * scale))
    im = im.resize((nw, nh), Image.LANCZOS)
    x0, y0 = (nw - W) // 2, (nh - H) // 2
    im = im.crop((x0, y0, x0 + W, y0 + H))
    if blur_r > 0:
        im = im.filter(ImageFilter.GaussianBlur(blur_r))
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
    cw = W / zoom
    ch = H / zoom
    x0 = cx * W - cw * 0.5 + dx
    y0 = cy * H - ch * 0.5 + dy
    x0 = max(0.0, min(W - cw, x0))
    y0 = max(0.0, min(H - ch, y0))
    M = np.array([[zoom, 0, -x0 * zoom], [0, zoom, -y0 * zoom]], dtype=np.float32)
    return cv2.warpAffine(rgb, M, (W, H), flags=cv2.INTER_LINEAR, borderMode=cv2.BORDER_REPLICATE)


def build_vignette_mask():
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    nx = (xx - W * 0.5) / (W * 0.5)
    ny = (yy - H * 0.5) / (H * 0.5)
    r2 = nx * nx * 0.72 + ny * ny * 0.92
    vig = np.clip(1.0 - 0.42 * (r2 ** 1.35), 0.42, 1.0)
    return vig[:, :, None].astype(np.float32)


def draw_text_glow(draw, pos, text, font, fill=(246, 226, 178, 255), shadow=(8, 6, 5, 235), offset=3, anchor=None):
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


# ==============================================================================
# 3. PRE-BUILT HIGH-CRAFT OVERLAYS & PROCEDURAL EMBERS
# ==============================================================================
def make_callout_overlay(seal_text, main_title, sub_title):
    """Top-left Ming-wuxia vermilion seal + dark-ink ribbon feature callout."""
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)

    # Dark ink brush ribbon backing behind callout
    rx0, ry0, rx1, ry1 = 68, 56, 860, 166
    for x in range(rx0, rx1):
        t = (x - rx0) / float(rx1 - rx0)
        a = int(185 * (1.0 - max(0.0, (t - 0.58) / 0.42) ** 1.4))
        d.line([(x, ry0), (x, ry1)], fill=(12, 10, 10, a))
    # Antique gold thin top/bottom hairlines
    d.line([(rx0 + 78, ry0 + 2), (rx0 + 620, ry0 + 2)], fill=(208, 168, 92, 170), width=2)
    d.line([(rx0 + 78, ry1 - 2), (rx0 + 520, ry1 - 2)], fill=(208, 168, 92, 110), width=1)

    # Vermilion carved Chinese seal box
    sx0, sy0, sx1, sy1 = 80, 68, 148, 154
    d.rectangle([sx0, sy0, sx1, sy1], fill=(158, 28, 24, 240), outline=(228, 186, 120, 210), width=2)
    d.rectangle([sx0 + 4, sy0 + 4, sx1 - 4, sy1 - 4], outline=(245, 224, 200, 130), width=1)
    # Vertical two-character seal text
    if len(seal_text) == 2:
        d.text(((sx0 + sx1) // 2, sy0 + 24), seal_text[0], font=F_STAMP, fill=(250, 236, 214, 255), anchor="mm")
        d.text(((sx0 + sx1) // 2, sy0 + 62), seal_text[1], font=F_STAMP, fill=(250, 236, 214, 255), anchor="mm")
    else:
        d.text(((sx0 + sx1) // 2, (sy0 + sy1) // 2), seal_text, font=F_STAMP, fill=(250, 236, 214, 255), anchor="mm")

    draw_text_glow(d, (168, 72), main_title, F_CALLOUT, fill=(248, 226, 174, 255), offset=2)
    draw_text_glow(d, (170, 120), sub_title, F_CALLOUT_S, fill=(205, 198, 186, 245), offset=2)
    return im


def make_subtitle_overlay(text, bottom_margin=96):
    """Crisp cinema-grade centered bottom Chinese subtitle with subtle dark-ink gradient strip."""
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    cy = H - bottom_margin
    y_top, y_bot = max(0, cy - 58), min(H, cy + 56)
    for y in range(y_top, y_bot):
        u = (y - y_top) / float(max(1, y_bot - y_top))
        bell = math.sin(u * math.pi)
        a = int(160 * bell)
        d.line([(260, y), (W - 260, y)], fill=(8, 7, 7, a))
    bbox = d.textbbox((0, 0), text, font=F_SUB)
    tw = bbox[2] - bbox[0]
    draw_text_glow(d, (W // 2, cy), text, F_SUB, fill=(252, 244, 226, 255), shadow=(6, 5, 5, 250), offset=3, anchor="mm")
    lx = W // 2 - tw // 2 - 28
    rx = W // 2 + tw // 2 + 28
    d.polygon([(lx, cy - 5), (lx + 6, cy), (lx, cy + 5), (lx - 6, cy)], fill=(214, 172, 94, 210))
    d.polygon([(rx, cy - 5), (rx + 6, cy), (rx, cy + 5), (rx - 6, cy)], fill=(214, 172, 94, 210))
    return im


def make_outro_ribbon_overlay():
    """Prestige top stats bar fading in cleanly above the Blood-Moon Title Card with zero overlap."""
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    text = "272 独创秘籍   ◆   44 江湖门派   ◆   39 传世神兵   ◆   64 尊山海大妖   ◆   7 槽武学革新"
    y_c = 64
    d.rectangle([230, y_c - 28, W - 230, y_c + 28], fill=(12, 9, 9, 185))
    d.line([(260, y_c - 28), (W - 260, y_c - 28)], fill=(212, 166, 86, 185), width=2)
    d.line([(260, y_c + 28), (W - 260, y_c + 28)], fill=(212, 166, 86, 185), width=2)
    draw_text_glow(d, (W // 2, y_c), text, F_RIBBON, fill=(244, 216, 152, 255), offset=2, anchor="mm")
    return im


class EmberSystem:
    def __init__(self, count=70, seed=42):
        rng = np.random.default_rng(seed)
        self.x0 = rng.uniform(0, W, count)
        self.y0 = rng.uniform(0, H, count)
        self.vy = rng.uniform(45, 165, count)
        self.vx = rng.uniform(-35, 45, count)
        self.phase = rng.uniform(0, 2 * math.pi, count)
        self.radius = rng.integers(2, 5, count)
        self.bright = rng.uniform(0.55, 1.0, count)

    def render(self, rgb, t, tint=(255, 165, 68), intensity=0.8):
        if intensity <= 0.01:
            return rgb
        out = rgb.copy()
        for i in range(len(self.x0)):
            x = int((self.x0[i] + self.vx[i] * t + 28.0 * math.sin(t * 1.9 + self.phase[i])) % W)
            y = int((self.y0[i] - self.vy[i] * t) % H)
            flick = (0.65 + 0.35 * math.sin(t * 8.0 + self.phase[i])) * self.bright[i] * intensity
            r = int(self.radius[i])
            col = (
                min(255, int(tint[0] * flick)),
                min(255, int(tint[1] * flick)),
                min(255, int(tint[2] * flick)),
            )
            cv2.circle(out, (x, y), r, col, -1, lineType=cv2.LINE_AA)
            if r >= 3:
                cv2.circle(out, (x, y), r + 2, (col[0] // 3, col[1] // 3, col[2] // 3), 1, lineType=cv2.LINE_AA)
        return out


# ==============================================================================
# 4. BESPOKE REAL-MOD-ASSET MOTION GRAPHICS INTERCUTS
# ==============================================================================
class IntercutAssets:
    def __init__(self):
        print("[Assets] Loading real in-game Mod assets for showcase intercuts...")
        self.bg_cult = load_bg_1080p("promo/keyframes/shot_02_cultivation.png", dark=0.28, blur_r=14)
        self.bg_wpn  = load_bg_1080p("promo/keyframes/shot_03_combat_vfx.png", dark=0.22, blur_r=14)
        self.bg_boss = load_bg_1080p("promo/keyframes/shot_04_shanhai_bosses.png", dark=0.24, blur_r=12)
        self.bg_forge = load_bg_1080p("promo/keyframes/shot_05_xingtian_clash.png", dark=0.26, blur_r=12)
        self.title_hd = load_bg_1080p("promo/keyframes/shot_06_title_card.png", dark=1.0, blur_r=0)

        # Intercut 2B: 7-Slot Martial Arts UI items
        self.slots = [
            ("1级 · 主修内功", "太虚真经",     "gold",   load_rgba("art/hd/wx_book_neigong_unique.png", (132, 132))),
            ("1级 · 基础外功", "天外一剑",     "gold",   load_rgba("art/hd/wx_book_waigong_unique.png", (132, 132))),
            ("3级 · 轻功身法", "凌波御风步",   "gold",   load_rgba("art/hd/wx_emblem_qinggong.png",     (132, 132))),
            ("5级 · 横练杂学", "金刚铁布衫",   "purple", load_rgba("art/hd/wx_emblem_henglian.png",     (132, 132))),
            ("7级 · 进阶专精", "清风连环剑",   "blue",   load_rgba("art/hd/wx_emblem_sword.png",        (132, 132))),
            ("9级 · 辅修自由", "太阴归元诀",   "purple", load_rgba("art/hd/wx_emblem_neigong.png",      (132, 132))),
            ("11级· 宗师自由", "山海图腾孤本", "gold",   load_rgba("art/hd/wx_martial_container.png",   (132, 132))),
        ]
        self.pill_xisui = load_rgba("art/hd/wx_pill_xisui.png", (150, 150))

        # Intercut 3A: Real Legendary Relic Weapons + 4-frame VFX animations
        self.relics = [
            ("太阿古剑",     "传世神兵 · 剑",   load_rgba("art/hd/wx_relic_taie.png",       (210, 260))),
            ("七星龙渊剑",   "传世神兵 · 剑",   load_rgba("art/hd/wx_relic_longyuan.png",   (210, 260))),
            ("温侯方天画戟", "传世神兵 · 长兵", load_rgba("art/hd/wx_relic_huaji.png",      (210, 260))),
            ("沥泉盘龙神枪", "传世神兵 · 枪",   load_rgba("art/hd/wx_relic_liquan.png",     (210, 260))),
            ("穷奇裂风血骨爪","山海神兵 · 拳爪", load_rgba("art/hd/wx_relic_qiongqizhao.png",(210, 260))),
        ]
        self.vfx_anims = [
            [load_rgba(f"art/anim/wx_anim_01_f{i}.png", (320, 320)) for i in range(1, 5)],
            [load_rgba(f"art/anim/wx_anim_03_f{i}.png", (320, 320)) for i in range(1, 5)],
            [load_rgba(f"art/anim/wx_anim_05_f{i}.png", (320, 320)) for i in range(1, 5)],
        ]

        # Intercut 4A: 8 Real Shanhaijing Apex Bosses
        self.bosses = [
            ("钩吾山 · 吞天饕餮", "山海四凶", load_rgba("art/hd/wx_boss_taotie.png",       (250, 250))),
            ("青丘山 · 九尾天狐", "南山大妖", load_rgba("art/hd/wx_boss_jiuwei.png",       (250, 250))),
            ("凶犁丘 · 折翼应龙", "东山真龙", load_rgba("art/hd/wx_boss_yinglong.png",     (250, 250))),
            ("共工台 · 九首相柳", "大荒凶神", load_rgba("art/hd/wx_boss_xiangliuwang.png", (250, 250))),
            ("凶黎冢 · 铜头蚩尤", "上古兵主", load_rgba("art/hd/wx_boss_chiyou.png",       (250, 250))),
            ("钟山巅 · 烛九阴裔", "北山古神", load_rgba("art/hd/wx_boss_zhuyin.png",       (250, 250))),
            ("汤谷树 · 三足金乌", "大荒妖皇", load_rgba("art/hd/wx_boss_jinwu.png",        (250, 250))),
            ("邽山渊 · 裂风穷奇", "山海四凶", load_rgba("art/hd/wx_boss_qiongqi.png",      (250, 250))),
        ]

        # Intercut 5B: Neidan & Forged Shanhai Boss Gear
        self.neidan_xingtian = load_rgba("art/hd/wx_core_xingtian.png",  (300, 300))
        self.forge_gear = [
            ("饕餮吞天兽面胄", load_rgba("art/hd/wx_helm_taotie.png",   (220, 220))),
            ("穷奇裂风羽鳞甲", load_rgba("art/hd/wx_armor_qiongqi.png", (220, 220))),
            ("朱厌白首狂血铠", load_rgba("art/hd/wx_armor_zhuyan.png",  (220, 220))),
        ]

    def render_2b_seven_slots(self, local_t, dur):
        """Shot 2B (6.85-9.60s): Animated 7-Slot Martial Arts UI + Wash Marrow AP Breakthrough."""
        u = local_t / dur
        base = zoom_crop(self.bg_cult, zoom=1.02 + 0.05 * u)
        im = Image.fromarray(base).convert("RGBA")
        d = ImageDraw.Draw(im)

        # Center gilded panel frame echoing character_screen_wuxia_module.js
        px0, py0, px1, py1 = 150, 175, W - 150, 865
        d.rounded_rectangle([px0, py0, px1, py1], radius=16, fill=(14, 11, 10, 210), outline=(196, 152, 82, 220), width=3)
        d.rounded_rectangle([px0 + 8, py0 + 8, px1 - 8, py1 - 8], radius=12, outline=(120, 92, 50, 140), width=1)

        # Panel Header
        draw_text_glow(d, (W // 2, py0 + 58), "【 七 槽 武 学 修 为 】", F_TITLE_MD, fill=(248, 220, 148, 255), offset=2, anchor="mm")

        # Animated AP counter (9 -> 10 -> 11)
        ap_val = 9 if u < 0.35 else (10 if u < 0.65 else 11)
        ap_color = (242, 226, 182, 255) if ap_val == 9 else ((136, 232, 186, 255) if ap_val == 10 else (255, 206, 86, 255))
        sub_stats = f"废除原版 Perk 树   ·   272 本独创秘籍   ·   常驻行动点 AP :  {ap_val}"
        draw_text_glow(d, (W // 2, py0 + 114), sub_stats, F_RIBBON, fill=ap_color, offset=2, anchor="mm")

        # 7 Martial Arts Slots lighting up sequentially
        tier_colors = {
            "gold":   (236, 182, 72, 255),
            "purple": (186, 112, 236, 255),
            "blue":   (92, 178, 232, 255),
        }
        slot_w, slot_h = 188, 240
        gap = 24
        total_w = 7 * slot_w + 6 * gap
        start_x = (W - total_w) // 2
        slot_y = py0 + 165

        for idx, (lvl_lbl, name, tier, icon) in enumerate(self.slots):
            appear = ease_out_cubic((u - idx * 0.085) / 0.22)
            if appear <= 0.01:
                continue
            sx = start_x + idx * (slot_w + gap)
            sy = int(slot_y + (1.0 - appear) * 42)
            col = tier_colors[tier]
            border_c = (col[0], col[1], col[2], int(240 * appear))

            # Glowing aura behind slot
            glow = Image.new("RGBA", (slot_w + 24, slot_h + 24), (0, 0, 0, 0))
            gd = ImageDraw.Draw(glow)
            gd.rounded_rectangle([12, 12, slot_w + 12, slot_h + 12], radius=12, fill=(col[0], col[1], col[2], int(45 * appear)))
            glow = glow.filter(ImageFilter.GaussianBlur(8))
            im.alpha_composite(glow, (sx - 12, sy - 12))

            d = ImageDraw.Draw(im)
            d.rounded_rectangle([sx, sy, sx + slot_w, sy + slot_h], radius=10, fill=(24, 20, 18, int(238 * appear)), outline=border_c, width=3)

            # Paste icon centered
            ix = sx + (slot_w - icon.width) // 2
            iy = sy + 18 + (136 - icon.height) // 2
            im.alpha_composite(icon, (ix, iy))
            d = ImageDraw.Draw(im)

            # Mastery 3 dots (●●●)
            for k in range(3):
                dx = sx + slot_w // 2 + (k - 1) * 20
                dy = sy + 168
                lit = (u > idx * 0.085 + 0.14 + k * 0.06)
                dc = col if lit else (75, 68, 62, 200)
                d.ellipse([dx - 5, dy - 5, dx + 5, dy + 5], fill=dc)

            draw_text_glow(d, (sx + slot_w // 2, sy + 196), name, F_SLOT_LBL, fill=(246, 232, 198, int(255 * appear)), offset=1, anchor="mm")
            d.text((sx + slot_w // 2, sy + 222), lvl_lbl, font=F_CARD_SUB, fill=(176, 168, 152, int(230 * appear)), anchor="mm")

        # Bottom Marrow-Wash Elixir showcase strip
        wash_appear = ease_out_cubic((u - 0.35) / 0.30)
        if wash_appear > 0.01:
            by = py1 - 196
            d.rounded_rectangle([W // 2 - 430, by, W // 2 + 430, by + 162], radius=12,
                                fill=(34, 18, 16, int(215 * wash_appear)), outline=(238, 154, 72, int(220 * wash_appear)), width=2)
            im.alpha_composite(self.pill_xisui, (W // 2 - 405, by + 6))
            d = ImageDraw.Draw(im)
            draw_text_glow(d, (W // 2 - 220, by + 42), "【洗经伐髓 · 冲星易筋】", F_CALLOUT, fill=(255, 212, 118, int(255 * wash_appear)), offset=2)
            d.text((W // 2 - 220, by + 98), "残页拼合 / 残本强修 / 散功重修 / 内息与疲劳合一", font=F_CARD_NAME, fill=(224, 212, 194, int(240 * wash_appear)))

        return np.array(im.convert("RGB"), dtype=np.uint8)

    def render_3a_relics_vfx(self, local_t, dur):
        """Shot 3A (9.60-12.60s): 39 Legendary Historical Weapons & Live 4-Frame VFX Showcase."""
        u = local_t / dur
        base = zoom_crop(self.bg_wpn, zoom=1.04 + 0.06 * u)
        im = Image.fromarray(base).convert("RGBA")

        # Kinetic 4-frame real combat VFX sprites cycling behind weapon cards
        f_idx = int(local_t * 10) % 4
        vfx_positions = [(220, 260), (W // 2 - 160, 180), (W - 540, 270)]
        for k, anim in enumerate(self.vfx_anims):
            sp = anim[(f_idx + k) % 4]
            im.alpha_composite(sp, vfx_positions[k])

        d = ImageDraw.Draw(im)
        draw_text_glow(d, (W // 2, 195), "三十九柄传世神兵  ·  七十三式绝学气芒", F_TITLE_MD, fill=(252, 224, 156, 255), offset=3, anchor="mm")

        # 5 Legendary red-tier weapon cards sweeping cleanly across center
        cw, ch = 292, 430
        gap = 34
        tot = 5 * cw + 4 * gap
        x0 = (W - tot) // 2
        y_base = 290

        for idx, (name, sub, icon) in enumerate(self.relics):
            p = ease_out_cubic((u - idx * 0.11) / 0.28)
            if p <= 0.01:
                continue
            cx = int(x0 + idx * (cw + gap) + (1.0 - p) * 140)
            cy = int(y_base + math.sin(local_t * 3.0 + idx) * 6)

            # Crimson-gold red-rarity weapon card
            d.rounded_rectangle([cx, cy, cx + cw, cy + ch], radius=14,
                                fill=(22, 14, 14, int(232 * p)), outline=(218, 78, 56, int(235 * p)), width=3)
            d.rounded_rectangle([cx + 7, cy + 7, cx + cw - 7, cy + ch - 7], radius=10,
                                outline=(232, 182, 92, int(140 * p)), width=1)

            # Soft crimson aura behind weapon
            glow = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
            gd = ImageDraw.Draw(glow)
            gd.ellipse([cw // 2 - 95, 55, cw // 2 + 95, 290], fill=(185, 38, 28, int(85 * p)))
            glow = glow.filter(ImageFilter.GaussianBlur(22))
            im.alpha_composite(glow, (cx, cy))

            ix = cx + (cw - icon.width) // 2
            iy = cy + 32 + (270 - icon.height) // 2
            im.alpha_composite(icon, (ix, iy))
            d = ImageDraw.Draw(im)

            draw_text_glow(d, (cx + cw // 2, cy + 342), name, F_CARD_NAME, fill=(252, 224, 162, int(255 * p)), offset=2, anchor="mm")
            d.text((cx + cw // 2, cy + 384), sub, font=F_CARD_SUB, fill=(220, 142, 118, int(235 * p)), anchor="mm")

        return np.array(im.convert("RGB"), dtype=np.uint8)

    def render_4a_shanhai_bestiary(self, local_t, dur):
        """Shot 4A (16.65-20.55s): Ominous Parallax Scroll of 8 Real Shanhaijing Bosses."""
        u = local_t / dur
        base = zoom_crop(self.bg_boss, zoom=1.03 + 0.08 * u)
        # Blood-crimson tint shift for dark mythological reveal
        tinted = base.astype(np.float32)
        tinted[:, :, 0] = np.clip(tinted[:, :, 0] * 1.25 + 16, 0, 255)
        tinted[:, :, 1] *= 0.85
        tinted[:, :, 2] *= 0.88
        im = Image.fromarray(tinted.astype(np.uint8)).convert("RGBA")
        d = ImageDraw.Draw(im)

        hdr_a = ease_out_cubic(u / 0.22)
        draw_text_glow(d, (W // 2, 155), "《山海经 · 五臧大荒万妖全卷》", F_TITLE_LG,
                       fill=(248, 198, 128, int(255 * hdr_a)), shadow=(18, 4, 4, 250), offset=3, anchor="mm")

        # Two counter-scrolling parallax rows of 4 bosses each
        cw, ch = 360, 315
        gap = 42
        row1 = self.bosses[:4]
        row2 = self.bosses[4:]
        drift = int((u - 0.5) * 140)

        for r_idx, row in enumerate([row1, row2]):
            tot = 4 * cw + 3 * gap
            base_x = (W - tot) // 2 + (drift if r_idx == 0 else -drift)
            ry = 228 + r_idx * (ch + 28)
            for idx, (name, tag, icon) in enumerate(row):
                p = ease_out_cubic((u - (idx * 0.06 + r_idx * 0.14)) / 0.24)
                if p <= 0.01:
                    continue
                cx = base_x + idx * (cw + gap)
                if cx + cw < -40 or cx > W + 40:
                    continue
                d.rounded_rectangle([cx, ry, cx + cw, ry + ch], radius=14,
                                    fill=(18, 12, 14, int(230 * p)), outline=(176, 62, 48, int(230 * p)), width=3)
                ix = cx + (cw - icon.width) // 2
                iy = ry + 10
                im.alpha_composite(icon, (ix, iy))
                d = ImageDraw.Draw(im)
                # Bottom gradient label inside card
                d.rectangle([cx + 4, ry + ch - 68, cx + cw - 4, ry + ch - 4], fill=(12, 8, 9, int(215 * p)))
                draw_text_glow(d, (cx + cw // 2, ry + ch - 46), name, F_CARD_NAME, fill=(248, 224, 174, int(255 * p)), offset=2, anchor="mm")
                d.text((cx + cw // 2, ry + ch - 18), tag, font=F_CARD_SUB, fill=(214, 108, 90, int(235 * p)), anchor="mm")

        return np.array(im.convert("RGB"), dtype=np.uint8)

    def render_5b_neidan_forge(self, local_t, dur):
        """Shot 5B (29.45-30.45s): Punchy 1-second Neidan & Forged Shanhai Boss Gear Impact Flash."""
        u = local_t / dur
        base = zoom_crop(self.bg_forge, zoom=1.08 + 0.12 * u)
        im = Image.fromarray(base).convert("RGBA")
        d = ImageDraw.Draw(im)

        # Blazing crimson-gold radial flash behind upper-center Xingtian Neidan
        nc_y = 385
        glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        gd = ImageDraw.Draw(glow)
        rad = int(190 + 90 * ease_out_cubic(u))
        gd.ellipse([W // 2 - rad, nc_y - rad, W // 2 + rad, nc_y + rad], fill=(220, 62, 34, 145))
        gd.ellipse([W // 2 - rad // 2, nc_y - rad // 2, W // 2 + rad // 2, nc_y + rad // 2], fill=(255, 198, 84, 170))
        glow = glow.filter(ImageFilter.GaussianBlur(38))
        im.alpha_composite(glow)

        # Central Neidan pulsing upward cleanly above the forged gear row
        sc = 0.80 + 0.18 * ease_out_cubic(u)
        nw, nh = int(self.neidan_xingtian.width * sc), int(self.neidan_xingtian.height * sc)
        nd = self.neidan_xingtian.resize((nw, nh), Image.LANCZOS)
        im.alpha_composite(nd, (W // 2 - nw // 2, nc_y - nh // 2))

        # 3 Forged Shanhai Boss Armor / Helmets arranged cleanly in a symmetric bottom row
        positions = [(520, 725), (W // 2, 725), (W - 520, 725)]
        for idx, ((name, g_im), (gx, gy)) in enumerate(zip(self.forge_gear, positions)):
            p = ease_out_cubic((u - idx * 0.10) / 0.42)
            if p <= 0.01:
                continue
            bx, by = gx - 135, gy - 135
            d = ImageDraw.Draw(im)
            d.rounded_rectangle([bx, by, bx + 270, by + 270], radius=16, fill=(20, 14, 13, int(230 * p)), outline=(232, 174, 82, int(245 * p)), width=3)
            g_fit = g_im.resize((190, 190), Image.LANCZOS)
            im.alpha_composite(g_fit, (gx - 95, by + 22))
            d = ImageDraw.Draw(im)
            draw_text_glow(d, (gx, by + 242), name, F_CARD_SUB, fill=(252, 224, 158, int(255 * p)), offset=2, anchor="mm")

        draw_text_glow(d, (W // 2, 142), "斩 妖 取 丹   ·   百 工 铸 传 世 神 甲", F_TITLE_MD, fill=(255, 226, 152, 255), offset=3, anchor="mm")
        return np.array(im.convert("RGB"), dtype=np.uint8)


# ==============================================================================
# 5. MAIN TIMELINE COMPOSITOR & DIRECT FFMPEG STREAM ENCODER
# ==============================================================================
def sample_clip(frames, local_t, clip_dur):
    """Smoothly map local_t over clip_dur onto clip frames with mild micro-zoom."""
    n = len(frames)
    u = max(0.0, min(1.0, local_t / max(0.001, clip_dur)))
    f_pos = u * (n - 1)
    i0 = int(math.floor(f_pos))
    i1 = min(n - 1, i0 + 1)
    frac = f_pos - i0
    if frac < 0.01 or i0 == i1:
        return frames[i0]
    return cv2.addWeighted(frames[i0], 1.0 - frac, frames[i1], frac, 0)


def render_director_cut():
    t0 = time.time()
    build_master_audio()

    print(f"[Video] Preloading 6 animated clips from {CLIPS_DIR} at 1920x1080...")
    c1 = load_video_frames_1080p(os.path.join(CLIPS_DIR, "shot_01_heroes.mp4"))
    c2 = load_video_frames_1080p(os.path.join(CLIPS_DIR, "shot_02_cultivation.mp4"))
    c3 = load_video_frames_1080p(os.path.join(CLIPS_DIR, "shot_03_combat_vfx.mp4"))
    c4 = load_video_frames_1080p(os.path.join(CLIPS_DIR, "shot_04_shanhai_bosses.mp4"))
    c5 = load_video_frames_1080p(os.path.join(CLIPS_DIR, "shot_05_xingtian_clash.mp4"))
    c6 = load_video_frames_1080p(os.path.join(CLIPS_DIR, "shot_06_title_card.mp4"))

    assets = IntercutAssets()
    vig = build_vignette_mask()
    embers = EmberSystem(count=75, seed=2026)

    # Pre-render static UI overlays (zero per-frame text layout overhead!)
    callouts = [
        (0.45,  3.35, make_callout_overlay("江湖", "明末暗黑志怪武侠 · 12人铁人战团", "72 项出身原地武侠映射 · 44 大地域江湖门派")),
        (3.85,  6.70, make_callout_overlay("武学", "废除原版专长树 · 独创 7 槽武学修为", "内功 / 外功 / 轻功 / 横练四脉自由拖拽装配")),
        (12.85, 16.45, make_callout_overlay("百兵", "轻装卸力游斗 · 重甲横练擎天", "13 类百兵阶梯 · 64 帧实机招式气芒特效")),
        (20.80, 24.25, make_callout_overlay("山海", "《山海经》64 尊上古凶神首领", "动态山海秘境轮替现世 · 刑天 / 饕餮 / 应龙 / 九尾")),
        (24.75, 29.25, make_callout_overlay("血战", "以凡躯硬撼古神 · 斩妖取丹炼化", "64 枚山海内丹拖拽灌注火候 · 锻造传世宝甲")),
    ]

    subtitles = [
        (0.05,  3.15, make_subtitle_overlay("乱世无主角，生死皆江湖。")),
        (3.80,  7.22, make_subtitle_overlay("废除死板天赋树，七槽秘籍随心悟，")),
        (7.28,  9.30, make_subtitle_overlay("洗经伐髓破凡胎！")),
        (10.00, 13.82, make_subtitle_overlay("三十九柄传世神兵，七十三式绝学气芒——")),
        (13.92, 16.32, make_subtitle_overlay("轻装破阵，重甲擎天！")),
        (17.02, 20.42, make_subtitle_overlay("然而江湖深处，远不止人心险恶——")),
        (20.62, 24.22, make_subtitle_overlay("大荒禁开，六十四尊山海凶神现世！")),
        (24.78, 30.18, make_subtitle_overlay("以凡人之躯，斩上古凶神，夺山海内丹，铸传世兵甲！")),
        (30.82, 33.08, make_subtitle_overlay("《战场兄弟：武侠江湖》——", bottom_margin=56)),
        (33.18, 36.65, make_subtitle_overlay("踏入暗黑大荒，写下你的血色传奇。", bottom_margin=56)),
    ]
    outro_ribbon = make_outro_ribbon_overlay()

    # Exact segment timetable (start, end, render_fn)
    def get_scene_frame(t):
        if t < 3.55:
            return sample_clip(c1, t, 3.55)
        elif t < 6.85:
            return sample_clip(c2, t - 3.55, 3.30)
        elif t < 9.60:
            return assets.render_2b_seven_slots(t - 6.85, 2.75)
        elif t < 12.60:
            return assets.render_3a_relics_vfx(t - 9.60, 3.00)
        elif t < 16.65:
            return sample_clip(c3, t - 12.60, 4.05)
        elif t < 20.55:
            return assets.render_4a_shanhai_bestiary(t - 16.65, 3.90)
        elif t < 24.45:
            return sample_clip(c4, t - 20.55, 3.90)
        elif t < 29.45:
            return sample_clip(c5, t - 24.45, 5.00)
        elif t < 30.45:
            return assets.render_5b_neidan_forge(t - 29.45, 1.00)
        elif t < 34.45:
            return sample_clip(c6, t - 30.45, 4.00)
        else:
            # Smooth hold & majestic slow zoom on high-res 2K title card
            lt = t - 34.45
            z = 1.00 + 0.045 * (lt / 3.55)
            hd = zoom_crop(assets.title_hd, zoom=z)
            if lt < 0.65:
                blend = ease_in_out(lt / 0.65)
                return cv2.addWeighted(c6[-1], 1.0 - blend, hd, blend, 0)
            return hd

    # Transition cut points for smooth 0.24s crossfades & beat flashes
    cuts = [3.55, 6.85, 9.60, 12.60, 16.65, 20.55, 24.45, 29.45, 30.45]
    impact_cuts = {12.60, 20.55, 24.45, 29.45, 30.45}

    # Launch FFmpeg encoding pipeline directly from raw RGB24 frames + mastered WAV
    cmd = [
        FFMPEG, "-y",
        "-f", "rawvideo",
        "-vcodec", "rawvideo",
        "-pix_fmt", "rgb24",
        "-s", f"{W}x{H}",
        "-r", str(FPS),
        "-i", "pipe:0",
        "-i", TMP_WAV,
        "-c:v", "libx264",
        "-preset", "medium",
        "-crf", "18",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac",
        "-b:a", "192k",
        "-ar", "48000",
        "-movflags", "+faststart",
        "-shortest",
        OUT_MP4,
    ]
    print(f"[Encode] Rendering {TOTAL_FRAMES} frames ({TOTAL_DUR:.1f}s @ 1080p {FPS}fps) -> {OUT_MP4}")
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stderr=subprocess.PIPE)

    for fi in range(TOTAL_FRAMES):
        t = fi / float(FPS)
        frame = get_scene_frame(t)

        # Crossfade across cut boundaries (+/- 0.14s)
        for cut_t in cuts:
            dt = t - cut_t
            if -0.14 <= dt <= 0.14:
                a_img = get_scene_frame(cut_t - 0.001)
                b_img = get_scene_frame(cut_t + 0.001)
                alpha = ease_in_out((dt + 0.14) / 0.28)
                frame = cv2.addWeighted(a_img, 1.0 - alpha, b_img, alpha, 0)
                # Subtle golden-crimson impact flash on high-energy cuts
                if cut_t in impact_cuts:
                    flash = math.sin(alpha * math.pi) * 0.28
                    flash_col = np.array([255, 195, 125], dtype=np.float32) if cut_t >= 29.0 else np.array([235, 95, 68], dtype=np.float32)
                    frame = np.clip(frame.astype(np.float32) * (1.0 - flash) + flash_col * flash, 0, 255).astype(np.uint8)
                break

        # Micro camera impact shake right after combat/boss hits
        for hit_t in (12.60, 20.55, 24.45, 29.45):
            if 0.0 <= t - hit_t < 0.28:
                decay = 1.0 - (t - hit_t) / 0.28
                sx = math.sin((t - hit_t) * 75.0) * 10.0 * decay
                sy = math.cos((t - hit_t) * 62.0) * 7.0 * decay
                frame = zoom_crop(frame, zoom=1.025, dx=sx, dy=sy)
                break

        # Cinematic vignette
        frame = np.clip(frame.astype(np.float32) * vig, 0, 255).astype(np.uint8)

        # Subtle rising embers matched to act mood
        if t < 3.55:
            frame = embers.render(frame, t, tint=(180, 210, 230), intensity=0.25)
        elif t < 16.65:
            frame = embers.render(frame, t, tint=(255, 195, 96), intensity=0.60)
        elif t < 30.45:
            frame = embers.render(frame, t, tint=(255, 108, 56), intensity=0.82)
        else:
            frame = embers.render(frame, t, tint=(255, 168, 72), intensity=0.72)

        # Top-left Chinese feature callouts
        for ts, te, ov in callouts:
            if ts <= t <= te:
                fa = min(1.0, (t - ts) / 0.35, (te - t) / 0.35)
                frame = alpha_blit_rgba(frame, ov, ease_in_out(fa))
                break

        # Prestige bottom summary bar on final title hold (33.5s - 37.8s)
        if t >= 33.4:
            ra = ease_in_out(min(1.0, (t - 33.4) / 0.7))
            frame = alpha_blit_rgba(frame, outro_ribbon, ra)

        # Synchronized bottom Chinese subtitles
        for ts, te, ov in subtitles:
            if ts <= t <= te:
                fa = min(1.0, (t - ts) / 0.18, (te - t) / 0.20)
                frame = alpha_blit_rgba(frame, ov, ease_in_out(fa))
                break

        # Global opening fade-in (0.0-0.45s) & closing fade-out (37.2-38.0s)
        if t < 0.45:
            frame = (frame.astype(np.float32) * ease_in_out(t / 0.45)).astype(np.uint8)
        elif t > 37.2:
            frame = (frame.astype(np.float32) * ease_in_out(max(0.0, (38.0 - t) / 0.8))).astype(np.uint8)

        proc.stdin.write(frame.tobytes())
        if (fi + 1) % 120 == 0 or fi == TOTAL_FRAMES - 1:
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
    ap = argparse.ArgumentParser()
    ap.add_argument("--clips-dir", default=os.path.join("promo", "clips"), help="Directory containing shot_01..06.mp4")
    ap.add_argument("--output", default=os.path.join("promo", "BB_Wuxia_Mod_DirectorCut_1080p.mp4"), help="Output MP4 path")
    args = ap.parse_args()
    CLIPS_DIR = args.clips_dir
    OUT_MP4 = args.output
    render_director_cut()
