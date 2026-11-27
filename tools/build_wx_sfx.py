#!/usr/bin/env python3
"""
BB Wuxia Mod - Procedural Physical-Modeled Wuxia Acoustic SFX Generator
Generates 24 authentic 44.1kHz 16-bit mono PCM .wav sound effects matching Battle Brothers'
exact acoustic loudness profile (peak ~15k-22k, RMS ~900-1800, zero clipping):
  - mod_wuxia/sounds/wx_combat/*.wav (18 martial arts combat SFX)
  - mod_wuxia/sounds/wx_ritual/*.wav (6 cultivation, alchemy, forge & command SFX)
"""

import math
import pathlib
import random
import struct
import wave

SR = 44100
ROOT = pathlib.Path(__file__).resolve().parent.parent
COMBAT_DIR = ROOT / "mod_wuxia" / "sounds" / "wx_combat"
RITUAL_DIR = ROOT / "mod_wuxia" / "sounds" / "wx_ritual"


def make_noise(n: int, seed: int) -> list[float]:
    rng = random.Random(seed)
    return [rng.uniform(-1.0, 1.0) for _ in range(n)]


def biquad_bandpass(samples: list[float], freq: float, q: float) -> list[float]:
    w0 = 2.0 * math.pi * max(20.0, min(SR * 0.45, freq)) / SR
    alpha = math.sin(w0) / (2.0 * max(0.15, q))
    b0 = alpha
    b1 = 0.0
    b2 = -alpha
    a0 = 1.0 + alpha
    a1 = -2.0 * math.cos(w0)
    a2 = 1.0 - alpha
    b0 /= a0
    b1 /= a0
    b2 /= a0
    a1 /= a0
    a2 /= a0
    out = [0.0] * len(samples)
    x1 = x2 = y1 = y2 = 0.0
    for i, x0 in enumerate(samples):
        y0 = b0 * x0 + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        out[i] = y0
        x2, x1 = x1, x0
        y2, y1 = y1, y0
    return out


def swept_bandpass(samples: list[float], f_start: float, f_peak: float, f_end: float, peak_pos: float, q: float) -> list[float]:
    n = len(samples)
    out = [0.0] * n
    x1 = x2 = y1 = y2 = 0.0
    for i, x0 in enumerate(samples):
        u = i / max(1, n - 1)
        if u < peak_pos:
            t = u / max(0.01, peak_pos)
            freq = f_start + (f_peak - f_start) * (t ** 0.85)
        else:
            t = (u - peak_pos) / max(0.01, 1.0 - peak_pos)
            freq = f_peak + (f_end - f_peak) * (t ** 0.75)
        if i % 32 == 0:
            w0 = 2.0 * math.pi * max(30.0, min(SR * 0.44, freq)) / SR
            alpha = math.sin(w0) / (2.0 * max(0.2, q))
            a0 = 1.0 + alpha
            b0 = alpha / a0
            b2 = -alpha / a0
            a1 = (-2.0 * math.cos(w0)) / a0
            a2 = (1.0 - alpha) / a0
        y0 = b0 * x0 + b2 * x2 - a1 * y1 - a2 * y2
        out[i] = y0
        x2, x1 = x1, x0
        y2, y1 = y1, y0
    return out


def env_ad(u: float, attack: float, decay_rate: float) -> float:
    if u < 0.0 or u > 1.0:
        return 0.0
    if u < attack:
        return (u / max(1e-5, attack)) ** 0.7
    return math.exp(-decay_rate * (u - attack))


def add_reverb_tail(buf: list[float], delays_ms: list[tuple[float, float]]) -> list[float]:
    n = len(buf)
    out = list(buf)
    for d_ms, gain in delays_ms:
        d = int(SR * d_ms / 1000.0)
        for i in range(d, n):
            out[i] += out[i - d] * gain * 0.45
    return out


def write_wav(path: pathlib.Path, buf: list[float], target_peak: int = 18500) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    n = len(buf)
    fade = min(int(SR * 0.018), n // 6)
    for i in range(fade):
        buf[n - 1 - i] *= i / max(1, fade)
    pk = max((abs(x) for x in buf), default=1e-6)
    scale = target_peak / max(1e-6, pk)
    pcm = [max(-32767, min(32767, int(round(x * scale)))) for x in buf]
    with wave.open(str(path), "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SR)
        wf.writeframes(struct.pack("<" + str(n) + "h", *pcm))


def gen_sword_qi(variant: int) -> list[float]:
    dur = 0.56 if variant == 1 else 0.62
    n = int(SR * dur)
    noise = make_noise(n, 100 + variant)
    whoosh = swept_bandpass(noise, 450, 2900 if variant == 1 else 3300, 750, 0.24, 1.8)
    partials = [1380, 2240, 3560, 5120] if variant == 1 else [1520, 2490, 3910, 5680]
    out = [0.0] * n
    ph = [0.0] * len(partials)
    for i in range(n):
        t = i / SR
        u = i / n
        w_env = env_ad(u, 0.08, 6.2)
        m_env = env_ad(u, 0.012, 8.5)
        ring = 0.0
        for k, f0 in enumerate(partials):
            glide = f0 * (1.0 + 0.06 * math.exp(-18.0 * t))
            ph[k] += 2.0 * math.pi * glide / SR
            ring += math.sin(ph[k]) * (0.45 / (k + 1))
        out[i] = whoosh[i] * w_env * 1.45 + ring * m_env * 0.72
    return add_reverb_tail(out, [(23, 0.28), (47, 0.18)])


def gen_sword_hit() -> list[float]:
    dur = 0.48
    n = int(SR * dur)
    noise = make_noise(n, 120)
    crunch = biquad_bandpass(noise, 1850, 1.3)
    out = [0.0] * n
    for i in range(n):
        t = i / SR
        u = i / n
        thud = math.sin(2.0 * math.pi * (145.0 * math.exp(-16.0 * t) + 52.0) * t) * env_ad(u, 0.005, 16.0)
        ping = (
            0.5 * math.sin(2.0 * math.pi * 2180 * t)
            + 0.3 * math.sin(2.0 * math.pi * 3490 * t)
        ) * env_ad(u, 0.004, 11.0)
        out[i] = thud * 0.9 + crunch[i] * env_ad(u, 0.01, 14.0) * 1.3 + ping * 0.55
    return add_reverb_tail(out, [(19, 0.22)])


def gen_saber_gale(variant: int) -> list[float]:
    dur = 0.68 if variant == 1 else 0.74
    n = int(SR * dur)
    noise = make_noise(n, 200 + variant)
    gale = swept_bandpass(noise, 140, 920 if variant == 1 else 1080, 180, 0.28, 1.25)
    edge = swept_bandpass(noise, 900, 2100, 620, 0.26, 2.4)
    out = [0.0] * n
    for i in range(n):
        t = i / SR
        u = i / n
        sub = math.sin(2.0 * math.pi * (95.0 * math.exp(-5.5 * t) + 46.0) * t) * env_ad(u, 0.04, 6.8)
        steel = math.sin(2.0 * math.pi * (780 if variant == 1 else 860) * t) * env_ad(u, 0.02, 9.5)
        out[i] = gale[i] * env_ad(u, 0.10, 4.8) * 1.6 + edge[i] * env_ad(u, 0.07, 6.5) * 0.7 + sub * 0.75 + steel * 0.22
    return add_reverb_tail(out, [(31, 0.26), (63, 0.16)])


def gen_palm_dragon(variant: int) -> list[float]:
    dur = 0.82 if variant == 1 else 0.88
    n = int(SR * dur)
    noise = make_noise(n, 300 + variant)
    blast = swept_bandpass(noise, 90, 680, 130, 0.18, 1.1)
    roar = swept_bandpass(noise, 320, 1280, 420, 0.30, 2.8)
    base_f = 138.0 if variant == 1 else 154.0
    out = [0.0] * n
    ph1 = ph2 = ph3 = 0.0
    for i in range(n):
        t = i / SR
        u = i / n
        f_cur = base_f * (1.0 + 0.22 * math.sin(5.2 * t) * math.exp(-3.0 * t))
        ph1 += 2.0 * math.pi * f_cur / SR
        ph2 += 2.0 * math.pi * (f_cur * 1.498) / SR
        ph3 += 2.0 * math.pi * (f_cur * 2.02) / SR
        sub_boom = math.sin(2.0 * math.pi * (120.0 * math.exp(-9.0 * t) + 42.0) * t) * env_ad(u, 0.008, 7.5)
        horn = (0.55 * math.sin(ph1) + 0.32 * math.sin(ph2) + 0.18 * math.sin(ph3)) * env_ad(u, 0.06, 4.2)
        out[i] = sub_boom * 1.15 + blast[i] * env_ad(u, 0.03, 5.2) * 1.5 + roar[i] * env_ad(u, 0.08, 4.0) * 0.9 + horn * 0.65
    return add_reverb_tail(out, [(37, 0.32), (79, 0.22)])


def gen_palm_inch() -> list[float]:
    dur = 0.54
    n = int(SR * dur)
    noise = make_noise(n, 330)
    thump_air = biquad_bandpass(noise, 360, 1.1)
    out = [0.0] * n
    for i in range(n):
        t = i / SR
        u = i / n
        p1 = math.sin(2.0 * math.pi * (165.0 * math.exp(-22.0 * t) + 48.0) * t) * env_ad(u, 0.004, 14.0)
        u2 = (t - 0.075) / dur
        p2 = 0.0
        if u2 > 0.0:
            t2 = t - 0.075
            p2 = math.sin(2.0 * math.pi * (130.0 * math.exp(-15.0 * t2) + 40.0) * t2) * env_ad(u2, 0.006, 9.5)
        out[i] = p1 * 1.0 + p2 * 0.85 + thump_air[i] * env_ad(u, 0.01, 10.0) * 1.1
    return add_reverb_tail(out, [(24, 0.24)])


def gen_finger_acupoint(variant: int) -> list[float]:
    dur = 0.46
    n = int(SR * dur)
    noise = make_noise(n, 400 + variant)
    snap = swept_bandpass(noise, 1600, 4800, 1200, 0.09, 2.6)
    f1, f2 = (1760.0, 2637.0) if variant == 1 else (1975.5, 2960.0)
    out = [0.0] * n
    for i in range(n):
        t = i / SR
        u = i / n
        laser = math.sin(2.0 * math.pi * (2400.0 * math.exp(-28.0 * t) + 520.0) * t) * env_ad(u, 0.003, 18.0)
        chime = (0.6 * math.sin(2.0 * math.pi * f1 * t) + 0.38 * math.sin(2.0 * math.pi * f2 * t)) * env_ad(u, 0.008, 7.2)
        out[i] = snap[i] * env_ad(u, 0.01, 15.0) * 1.35 + laser * 0.75 + chime * 0.52
    return add_reverb_tail(out, [(29, 0.30), (61, 0.20)])


def gen_golden_bell() -> list[float]:
    dur = 1.05
    n = int(SR * dur)
    noise = make_noise(n, 500)
    strike = biquad_bandpass(noise, 720, 1.6)
    modes = [
        (220.0, 1.00, 2.8),
        (221.4, 0.65, 3.0),
        (441.0, 0.55, 3.8),
        (587.3, 0.48, 4.5),
        (882.0, 0.34, 5.8),
        (1318.5, 0.22, 7.5),
    ]
    out = [0.0] * n
    for i in range(n):
        t = i / SR
        u = i / n
        bell = 0.0
        for freq, amp, dec in modes:
            bell += amp * math.sin(2.0 * math.pi * freq * t) * env_ad(u, 0.006, dec)
        out[i] = bell * 0.75 + strike[i] * env_ad(u, 0.004, 22.0) * 0.9
    return add_reverb_tail(out, [(41, 0.34), (89, 0.24)])


def gen_qinggong_step(variant: int) -> list[float]:
    dur = 0.52
    n = int(SR * dur)
    noise = make_noise(n, 600 + variant)
    silk = swept_bandpass(noise, 900, 3400 if variant == 1 else 2850, 1300, 0.32, 1.5)
    breeze = swept_bandpass(noise, 380, 1150, 420, 0.40, 2.0)
    out = [0.0] * n
    f_air = 880.0 if variant == 1 else 1046.5
    for i in range(n):
        t = i / SR
        u = i / n
        wisp = math.sin(2.0 * math.pi * f_air * (1.0 + 0.08 * t) * t) * env_ad(u, 0.14, 6.0)
        out[i] = silk[i] * env_ad(u, 0.12, 5.8) * 1.45 + breeze[i] * env_ad(u, 0.16, 4.6) * 0.95 + wisp * 0.16
    return add_reverb_tail(out, [(27, 0.25)])


def gen_throwing_rain() -> list[float]:
    dur = 0.66
    n = int(SR * dur)
    out = [0.0] * n
    rng = random.Random(707)
    offsets = [0.01, 0.055, 0.095, 0.14, 0.185, 0.23, 0.28, 0.335, 0.39]
    noise = make_noise(n, 708)
    swish = biquad_bandpass(noise, 3200, 1.9)
    for onset in offsets:
        i0 = int(onset * SR)
        f_dart = rng.uniform(2600.0, 4100.0)
        span = int(0.14 * SR)
        for j in range(min(span, n - i0)):
            tj = j / SR
            uj = j / span
            env = env_ad(uj, 0.06, 8.5)
            whistle = math.sin(2.0 * math.pi * (f_dart * (1.0 - 0.22 * uj)) * tj)
            out[i0 + j] += (swish[i0 + j] * 1.4 + whistle * 0.42) * env
    return add_reverb_tail(out, [(21, 0.22)])


def gen_whip_crack() -> list[float]:
    dur = 0.56
    n = int(SR * dur)
    noise = make_noise(n, 801)
    whoosh = swept_bandpass(noise, 260, 2600, 900, 0.38, 1.7)
    crack_src = biquad_bandpass(noise, 2900, 0.9)
    out = [0.0] * n
    crack_idx = int(0.21 * SR)
    for i in range(n):
        u = i / n
        val = whoosh[i] * env_ad(u, 0.22, 6.5) * 1.2
        if i >= crack_idx:
            uc = (i - crack_idx) / max(1, n - crack_idx)
            tc = (i - crack_idx) / SR
            snap = math.sin(2.0 * math.pi * (1800.0 * math.exp(-35.0 * tc) + 220.0) * tc) * env_ad(uc, 0.002, 22.0)
            val += crack_src[i] * env_ad(uc, 0.003, 18.0) * 2.1 + snap * 0.95
        out[i] = val
    return add_reverb_tail(out, [(29, 0.26), (58, 0.16)])


def gen_spear_phoenix() -> list[float]:
    dur = 0.62
    n = int(SR * dur)
    noise = make_noise(n, 901)
    shaft = swept_bandpass(noise, 220, 880, 320, 0.20, 2.0)
    tip = biquad_bandpass(noise, 2750, 2.2)
    out = [0.0] * n
    bursts = [0.02, 0.15, 0.28]
    for i in range(n):
        t = i / SR
        u = i / n
        wood = math.sin(2.0 * math.pi * 195.0 * t) * env_ad(u, 0.05, 6.5) * 0.35
        val = shaft[i] * env_ad(u, 0.08, 5.2) * 1.1 + wood
        for b in bursts:
            if t >= b:
                ub = (t - b) / 0.22
                if ub < 1.0:
                    tb = t - b
                    ring = math.sin(2.0 * math.pi * 2480.0 * tb) * env_ad(ub, 0.02, 9.0) * 0.32
                    val += tip[i] * env_ad(ub, 0.03, 8.0) * 1.15 + ring
        out[i] = val
    return add_reverb_tail(out, [(24, 0.24)])


def gen_thunder_quake() -> list[float]:
    dur = 0.92
    n = int(SR * dur)
    noise = make_noise(n, 1001)
    crack = biquad_bandpass(noise, 1950, 0.85)
    rumble = swept_bandpass(noise, 480, 160, 65, 0.15, 0.9)
    out = [0.0] * n
    for i in range(n):
        t = i / SR
        u = i / n
        sub = math.sin(2.0 * math.pi * (110.0 * math.exp(-7.0 * t) + 38.0) * t) * env_ad(u, 0.006, 5.2)
        out[i] = crack[i] * env_ad(u, 0.004, 14.0) * 1.7 + rumble[i] * env_ad(u, 0.04, 3.6) * 1.65 + sub * 1.2
    return add_reverb_tail(out, [(43, 0.32), (97, 0.22)])


def gen_firelance_boom() -> list[float]:
    dur = 0.86
    n = int(SR * dur)
    noise = make_noise(n, 1101)
    fuse = biquad_bandpass(noise, 3600, 2.4)
    boom = swept_bandpass(noise, 900, 220, 75, 0.12, 0.8)
    out = [0.0] * n
    blast_i = int(0.06 * SR)
    for i in range(n):
        u = i / n
        if i < blast_i:
            out[i] = fuse[i] * (i / max(1, blast_i)) * 0.55
        else:
            tb = (i - blast_i) / SR
            ub = (i - blast_i) / max(1, n - blast_i)
            cannon = math.sin(2.0 * math.pi * (150.0 * math.exp(-10.0 * tb) + 40.0) * tb) * env_ad(ub, 0.003, 6.2)
            out[i] = boom[i] * env_ad(ub, 0.005, 4.4) * 1.9 + cannon * 1.25
    return add_reverb_tail(out, [(39, 0.30), (83, 0.20)])


def gen_breakthrough_gong() -> list[float]:
    dur = 1.25
    n = int(SR * dur)
    noise = make_noise(n, 1201)
    shimmer = swept_bandpass(noise, 600, 2400, 900, 0.35, 1.8)
    notes = [(0.0, 293.66), (0.11, 440.0), (0.22, 587.33), (0.34, 880.0)]
    gong_modes = [(146.83, 0.9), (220.0, 0.6), (295.0, 0.5), (442.0, 0.35)]
    out = [0.0] * n
    for i in range(n):
        t = i / SR
        u = i / n
        gong = sum(a * math.sin(2.0 * math.pi * f * t) for f, a in gong_modes) * env_ad(u, 0.02, 2.8)
        qin = 0.0
        for onset, fn in notes:
            if t >= onset:
                tn = t - onset
                un = tn / max(0.2, dur - onset)
                qin += (0.6 * math.sin(2.0 * math.pi * fn * tn) + 0.25 * math.sin(4.0 * math.pi * fn * tn)) * env_ad(un, 0.008, 4.2)
        out[i] = gong * 0.65 + qin * 0.55 + shimmer[i] * env_ad(u, 0.12, 4.5) * 0.45
    return add_reverb_tail(out, [(47, 0.34), (103, 0.24)])


def gen_qi_meditate() -> list[float]:
    dur = 0.95
    n = int(SR * dur)
    noise = make_noise(n, 1301)
    breath = swept_bandpass(noise, 320, 780, 280, 0.45, 2.2)
    out = [0.0] * n
    for i in range(n):
        t = i / SR
        u = i / n
        bowl = (
            0.65 * math.sin(2.0 * math.pi * 261.63 * t)
            + 0.42 * math.sin(2.0 * math.pi * 392.00 * t)
            + 0.25 * math.sin(2.0 * math.pi * 784.00 * t)
        ) * env_ad(u, 0.08, 3.2)
        out[i] = bowl * 0.75 + breath[i] * env_ad(u, 0.22, 3.8) * 0.65
    return add_reverb_tail(out, [(43, 0.32), (91, 0.22)])


def gen_alchemy_flare() -> list[float]:
    dur = 0.92
    n = int(SR * dur)
    noise = make_noise(n, 1401)
    flame = swept_bandpass(noise, 240, 1350, 380, 0.28, 1.4)
    out = [0.0] * n
    for i in range(n):
        t = i / SR
        u = i / n
        val = flame[i] * env_ad(u, 0.10, 4.2) * 1.45
        if t >= 0.24:
            tc = t - 0.24
            uc = tc / (dur - 0.24)
            jade = (0.6 * math.sin(2.0 * math.pi * 1046.5 * tc) + 0.4 * math.sin(2.0 * math.pi * 1567.98 * tc)) * env_ad(uc, 0.01, 4.8)
            val += jade * 0.62
        out[i] = val
    return add_reverb_tail(out, [(37, 0.30), (79, 0.20)])


def gen_forge_quench() -> list[float]:
    dur = 0.96
    n = int(SR * dur)
    noise = make_noise(n, 1501)
    hiss = swept_bandpass(noise, 1800, 4200, 1400, 0.45, 1.2)
    out = [0.0] * n
    for i in range(n):
        t = i / SR
        u = i / n
        anvil = (
            0.7 * math.sin(2.0 * math.pi * 932.3 * t)
            + 0.5 * math.sin(2.0 * math.pi * 1480.0 * t)
            + 0.35 * math.sin(2.0 * math.pi * 2349.0 * t)
        ) * env_ad(u, 0.003, 9.5)
        thud = math.sin(2.0 * math.pi * 135.0 * t) * env_ad(u, 0.004, 16.0)
        steam = 0.0
        if t >= 0.18:
            us = (t - 0.18) / (dur - 0.18)
            steam = hiss[i] * env_ad(us, 0.06, 4.2) * 1.25
        out[i] = anvil * 0.85 + thud * 0.75 + steam
    return add_reverb_tail(out, [(31, 0.28), (67, 0.18)])


def gen_marrow_wash() -> list[float]:
    dur = 1.05
    n = int(SR * dur)
    noise = make_noise(n, 1601)
    surge = swept_bandpass(noise, 260, 1900, 620, 0.55, 2.0)
    out = [0.0] * n
    ph = 0.0
    for i in range(n):
        t = i / SR
        u = i / n
        f_sweep = 196.0 + 392.0 * (u ** 1.3)
        ph += 2.0 * math.pi * f_sweep / SR
        pulse = math.sin(ph) * env_ad(u, 0.15, 3.0) * 0.55
        bell = math.sin(2.0 * math.pi * 1174.66 * t) * (env_ad((t - 0.32) / 0.73, 0.01, 4.5) if t >= 0.32 else 0.0) * 0.48
        out[i] = surge[i] * env_ad(u, 0.20, 3.8) * 1.15 + pulse + bell
    return add_reverb_tail(out, [(41, 0.32), (89, 0.22)])


def gen_war_horn() -> list[float]:
    dur = 0.96
    n = int(SR * dur)
    noise = make_noise(n, 1701)
    breath = biquad_bandpass(noise, 520, 2.2)
    out = [0.0] * n
    for i in range(n):
        t = i / SR
        u = i / n
        drum1 = math.sin(2.0 * math.pi * (105.0 * math.exp(-12.0 * t) + 46.0) * t) * env_ad(u, 0.005, 11.0)
        drum2 = 0.0
        if t >= 0.14:
            td = t - 0.14
            ud = td / (dur - 0.14)
            drum2 = math.sin(2.0 * math.pi * (98.0 * math.exp(-10.0 * td) + 44.0) * td) * env_ad(ud, 0.005, 9.0)
        horn_f = 196.0 * (1.0 + 0.015 * math.sin(18.0 * t))
        horn = (
            0.60 * math.sin(2.0 * math.pi * horn_f * t)
            + 0.42 * math.sin(4.0 * math.pi * horn_f * t)
            + 0.25 * math.sin(6.0 * math.pi * horn_f * t)
        ) * env_ad(u, 0.14, 2.8)
        out[i] = (drum1 + drum2 * 0.85) * 0.85 + horn * 0.72 + breath[i] * env_ad(u, 0.14, 3.2) * 0.35
    return add_reverb_tail(out, [(43, 0.32), (91, 0.22)])


def main() -> None:
    combat_specs = [
        ("wx_sword_qi_01.wav", gen_sword_qi(1), 18500),
        ("wx_sword_qi_02.wav", gen_sword_qi(2), 18500),
        ("wx_sword_hit_01.wav", gen_sword_hit(), 19500),
        ("wx_saber_gale_01.wav", gen_saber_gale(1), 19000),
        ("wx_saber_gale_02.wav", gen_saber_gale(2), 19000),
        ("wx_palm_dragon_01.wav", gen_palm_dragon(1), 20500),
        ("wx_palm_dragon_02.wav", gen_palm_dragon(2), 20500),
        ("wx_palm_inch_01.wav", gen_palm_inch(), 19500),
        ("wx_finger_acupoint_01.wav", gen_finger_acupoint(1), 18000),
        ("wx_finger_acupoint_02.wav", gen_finger_acupoint(2), 18000),
        ("wx_golden_bell_01.wav", gen_golden_bell(), 18500),
        ("wx_qinggong_step_01.wav", gen_qinggong_step(1), 15500),
        ("wx_qinggong_step_02.wav", gen_qinggong_step(2), 15500),
        ("wx_throwing_rain_01.wav", gen_throwing_rain(), 17500),
        ("wx_whip_crack_01.wav", gen_whip_crack(), 19500),
        ("wx_spear_phoenix_01.wav", gen_spear_phoenix(), 18500),
        ("wx_thunder_quake_01.wav", gen_thunder_quake(), 21000),
        ("wx_firelance_boom_01.wav", gen_firelance_boom(), 21500),
    ]
    ritual_specs = [
        ("wx_breakthrough_gong.wav", gen_breakthrough_gong(), 18500),
        ("wx_qi_meditate.wav", gen_qi_meditate(), 15500),
        ("wx_alchemy_flare.wav", gen_alchemy_flare(), 17500),
        ("wx_forge_quench.wav", gen_forge_quench(), 19000),
        ("wx_marrow_wash.wav", gen_marrow_wash(), 17500),
        ("wx_war_horn.wav", gen_war_horn(), 19000),
    ]

    total_bytes = 0
    for name, samples, pk in combat_specs:
        p = COMBAT_DIR / name
        write_wav(p, samples, pk)
        total_bytes += p.stat().st_size
    for name, samples, pk in ritual_specs:
        p = RITUAL_DIR / name
        write_wav(p, samples, pk)
        total_bytes += p.stat().st_size

    print(f"Generated {len(combat_specs)} combat SFX + {len(ritual_specs)} ritual SFX ({total_bytes / 1024:.1f} KiB total).")


if __name__ == "__main__":
    main()
