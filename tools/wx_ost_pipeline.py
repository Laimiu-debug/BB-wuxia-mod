#!/usr/bin/env python3
"""
BB Wuxia Mod OST Pipeline:
1. Download raw Runway-generated MP3 tracks into assets_raw/music/raw/
2. Create 25s QA preview clips & measure vanilla-BB acoustic alignment (body RMS, dynamic std, Low/Mid/Hi EQ)
3. Master & encode into mod_wuxia/music/wx_*.ogg (44100Hz stereo Ogg Vorbis, BB-matched loudness & warm EQ)
"""

import json
import math
import pathlib
import shutil
import struct
import subprocess
import sys
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parent.parent
RAW_DIR = ROOT / "assets_raw" / "music" / "raw"
QA_DIR = ROOT / "assets_raw" / "music" / "qa_clips"
OUT_DIR = ROOT / "mod_wuxia" / "music"
MANIFEST_PATH = ROOT / "assets_raw" / "music" / "manifest.json"

FALLBACK_FFMPEG = pathlib.Path(
    r"G:\CODE\CFGCN\.local\audio\ink-trial-v1\tools\imageio_ffmpeg\binaries\ffmpeg-win-x86_64-v7.1.exe"
)

TRACKS = [
    {
        "id": "wx_barbarians_01",
        "title": "铁骑撼山 (关外铁骑 / 药人战曲)",
        "role": "combat_heavy",
        "target_lufs": -15.5,
        "task_id": "2c11a364-5cb0-424a-bc2a-c78ccb65299c",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/2c11a364-5cb0-424a-bc2a-c78ccb65299c/BB_Wuxia_OST_01v2___Frontier_Horsehead___Throat_Chant__wx_barbarians_01_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiN2QwZGFjMTY2NjY1MDgwZCIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTMwMjQyMn0.5KFiHh6AmsBMmXAqY_l4aUyxl9SJyY1SIrwJkJTCbWM",
    },
    {
        "id": "wx_beasts_01",
        "title": "蛊雾迷踪 (五毒奇门 / 山海凶兽战曲)",
        "role": "combat_eerie",
        "target_lufs": -16.5,
        "task_id": "069b5e7a-efff-4f79-8294-d54841ae01e7",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/069b5e7a-efff-4f79-8294-d54841ae01e7/BB_Wuxia_OST_02v2___Ancient_Forest_Ritual___Pipa_Stalk__wx_beasts_01_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiNjA2MWY0YjJjNGYzMzQzZSIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTI3NTU3MH0.ffjDS8EAzzzQUcnSP5Exc87iQjEqOIfdcaDm4Oo4r8k",
    },
    {
        "id": "wx_undead_01",
        "title": "阴兵借道 (湘西尸傀 / 古墓机关战曲)",
        "role": "combat_heavy",
        "target_lufs": -16.0,
        "task_id": "9008ff02-0b26-4791-ab2c-8583ea293f84",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/9008ff02-0b26-4791-ab2c-8583ea293f84/BB_Wuxia_OST_03___Corpse_Puppet_Legion__wx_undead_01_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiM2JlYTA0ODBjMzgyNjNkYyIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTMyMDMyMH0.8CqK57E6Ea06a08zTfY4kK_hWXMRGRdZ0QJ1sBfHr1g",
    },
    {
        "id": "wx_bandits_01",
        "title": "血染黑风寨 (绿林山寨 / 塞外马贼战曲)",
        "role": "combat_std",
        "target_lufs": -16.5,
        "task_id": "ad89cd64-c0d6-4efa-9c12-5861cf5a361f",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/ad89cd64-c0d6-4efa-9c12-5861cf5a361f/BB_Wuxia_OST_04v2___Acoustic_Outlaw_Jianghu_Duel__wx_bandits_01_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiZjE1NjJkMDUxZGIzY2QzMSIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTI5OTA3N30.Fivl-vJIq33hFmvmSFQQV2KKXZ8E8h0AsTagkUtGWMc",
    },
    {
        "id": "wx_noble_01",
        "title": "玄甲镇关 (藩镇官军 / 重甲长戟战曲)",
        "role": "combat_heavy",
        "target_lufs": -15.5,
        "task_id": "cd9b792e-1532-4559-b5ba-46adc338c39e",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/cd9b792e-1532-4559-b5ba-46adc338c39e/BB_Wuxia_OST_05___Imperial_Heavy_Phalanx__wx_noble_01_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiNjlhNjg1ZTllOGNiNzQ1MCIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTMzMDUzN30.JskNfE2xC9RUMdy7OhQki3W0d9H49Z7HBk3A_gEKy_g",
    },
    {
        "id": "wx_title_01",
        "title": "孤剑赴江湖 (主菜单主题曲)",
        "role": "title",
        "target_lufs": -17.5,
        "task_id": "10b75e1b-6fdf-40ec-9175-580f5ab63a46",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/10b75e1b-6fdf-40ec-9175-580f5ab63a46/BB_Wuxia_OST_06v2___Pure_Acoustic_Jianghu_Title__wx_title_01_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiN2ZjOGUxM2M3MzRhODE3YSIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTMzMzY5Mn0.2N3CWW12A9W4jWcs3OjlNrUx-F0S8V87uanPmfyYCRE",
    },
    {
        "id": "wx_worldmap_01",
        "title": "关山独行 (大地图行旅曲)",
        "role": "worldmap",
        "target_lufs": -18.0,
        "task_id": "dae2428f-679c-4515-b194-3df50a8c5aad",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/dae2428f-679c-4515-b194-3df50a8c5aad/BB_Wuxia_OST_07___Wasteland_Roads_Worldmap__wx_worldmap_01_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiYTM5MGZlN2RlMjBkNmNmNSIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTM0Mzc0MX0.o8exSaXmXW4cLJXffObOT86k88-AgVS4Lbq42C48uAo",
    },
    {
        "id": "wx_settlement_01",
        "title": "荒驿残灯 (城镇市集 / 客栈曲)",
        "role": "settlement",
        "target_lufs": -18.5,
        "task_id": "44d12cd8-f134-4607-ab3c-5f7e2dabe4f4",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/44d12cd8-f134-4607-ab3c-5f7e2dabe4f4/BB_Wuxia_OST_08___Frontier_Tavern___Town__wx_settlement_01_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiZjI4MTQ1MjM0MzkxNjVhOSIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTI4NzcxNX0.CfCq2Kwzme01JCaPSkWGCfiZH_Q4suUNisxqY7uJ5Bs",
    },
    # --- Wave 2: 100% Pure Instrumental Authentic Wuxia OST Expansion ---
    {
        "id": "wx_worldmap_02",
        "title": "寒鸦古道 (大地图行旅 2 · 烟雨古道)",
        "role": "worldmap",
        "target_lufs": -18.0,
        "task_id": "4a82778e-ebc1-4988-9a46-e43005dbbebb",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/4a82778e-ebc1-4988-9a46-e43005dbbebb/BB_Wuxia_OST_W2_01___Misty_Road_Jianghu_Worldmap__wx_worldmap_02_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiODU1ZWIzNDk1OGYxYzUxMCIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTI5NDQwOX0.Qo1EKMBlh-_7qRhd6X5SCPwwm1BnstDpHGjJTN_-pcg",
    },
    {
        "id": "wx_worldmap_03",
        "title": "塞外孤烟 (大地图行旅 3 · 边塞豪情)",
        "role": "worldmap",
        "target_lufs": -18.0,
        "task_id": "56ec6778-273e-4b98-9c1d-757766a38d03",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/56ec6778-273e-4b98-9c1d-757766a38d03/BB_Wuxia_OST_W2_02___Frontier_Dust___Lone_Horse__wx_worldmap_03_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiYzNiZjY4NzY3MjNlOWU4NCIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTM0MjgzOH0.9MXoDOczGl2BCcVpQhvruFBNhx8RNf1IpQCKpjBz9WE",
    },
    {
        "id": "wx_settlement_02",
        "title": "茶寮听风 (城镇客栈 2 · 江湖市集)",
        "role": "settlement",
        "target_lufs": -18.5,
        "task_id": "b92234dc-6568-4091-bc7e-68192e5e6355",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/b92234dc-6568-4091-bc7e-68192e5e6355/BB_Wuxia_OST_W2_03___Jianghu_Teahouse___Inn__wx_settlement_02_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiYWMzZGUwMzZiNmE1YTIyZSIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTMwNzQ0Nn0.howyEAzfcR_ZcqaEGe9jqpzTbH0vIRFtbRIi2n4kqDM",
    },
    {
        "id": "wx_bandits_02",
        "title": "快意恩仇 (绿林血战 2 · 客栈竹林死斗)",
        "role": "combat_std",
        "target_lufs": -16.5,
        "task_id": "994ce41b-6ed5-4582-a1e9-e9b50acd64d0",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/994ce41b-6ed5-4582-a1e9-e9b50acd64d0/BB_Wuxia_OST_W2_04___Bamboo_Forest___Inn_Duel__wx_bandits_02_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiNGQ0ZDc0NWNlYzQ5YTBkMSIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTI3Njg5Mn0.8BESiRozEwbftQL9Njr4SMgpiNG3lSNG6zjKIBm89xE",
    },
    {
        "id": "wx_noble_02",
        "title": "铁马冰河 (藩镇官军 2 · 沙场血战)",
        "role": "combat_heavy",
        "target_lufs": -15.5,
        "task_id": "0621249a-9ff6-4867-9766-c2c75d03b129",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/0621249a-9ff6-4867-9766-c2c75d03b129/BB_Wuxia_OST_W2_05___Iron_Cavalry___Imperial_Banner__wx_noble_02_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiY2I3M2M2ZTY1ODc0MmEwMCIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTM0OTYwNn0.Rp-kTFswplwB9OAPfcN0TnZHAnswRoXR14-hUwalSNI",
    },
    {
        "id": "wx_barbarians_02",
        "title": "朔风破阵 (关外铁骑 / 药人 · 纯器乐版)",
        "role": "combat_heavy",
        "target_lufs": -15.5,
        "task_id": "2fa3c217-0508-42d2-af19-dab156dc3a1d",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/2fa3c217-0508-42d2-af19-dab156dc3a1d/BB_Wuxia_OST_W2_06___Northern_Frontier_Charge__wx_barbarians_02_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiYzcwZDczODg0OWY1NmE4ZCIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTMyMDMyOH0.Wvzns6VNPeK6CqnKOSDyP78uiIWNU3OhZgb1_8BbR5Y",
    },
    {
        "id": "wx_beasts_02",
        "title": "鬼林绝杀 (五毒奇门 / 山海凶兽 · 纯器乐版)",
        "role": "combat_eerie",
        "target_lufs": -16.5,
        "task_id": "a9f115f7-e2c6-4b38-92c4-120bb96cffbd",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/a9f115f7-e2c6-4b38-92c4-120bb96cffbd/BB_Wuxia_OST_W2_07___Poison_Mist___Shanhai_Ambush__wx_beasts_02_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiZTBmYjgxZmE5OTkxZDZjYiIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTMyNzk5NH0.krBNnFeJokdOfaCvQ8Og_esHD2TxxMxY9_Mp8AUiDgs",
    },
    {
        "id": "wx_undead_02",
        "title": "古墓惊魂 (湘西尸傀 / 古墓机关 · 纯器乐版)",
        "role": "combat_heavy",
        "target_lufs": -16.0,
        "task_id": "8445ae6a-7039-4cc4-bc2c-42530fb83300",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-pro/8445ae6a-7039-4cc4-bc2c-42530fb83300/BB_Wuxia_OST_W2_08___Ancient_Tomb___Bronze_Bells__wx_undead_02_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiYzgxZjQxNzdhMzVjNGEwNCIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTI5MzE3NX0.BCg7gkVliNIzYPAmdxsVOaw0Q90gFczjlZZYvyzMUVE",
    },
    {
        "id": "wx_victory_01",
        "title": "凯旋收剑 (胜战短曲)",
        "role": "sting",
        "target_lufs": -17.0,
        "task_id": "4b4e1c85-34e7-4c1e-bc66-3995513db3ca",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-clip/4b4e1c85-34e7-4c1e-bc66-3995513db3ca/BB_Wuxia_OST_W2_09___Jianghu_Victory_Sting__wx_victory_01_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiYzE4N2MyZDg3ODNmMjZhYSIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTI5MzUyOH0.HxpBE--gaPAVEHViPDic89JJhdAyCiWuiRILzAhRpVk",
    },
    {
        "id": "wx_defeat_01",
        "title": "孤剑折戟 (战败挽歌)",
        "role": "sting",
        "target_lufs": -18.0,
        "task_id": "1b5b136e-0888-4cb7-9ce1-ed65ed8c23dd",
        "url": "https://dnznrvs05pmza.cloudfront.net/lyria3-clip/1b5b136e-0888-4cb7-9ce1-ed65ed8c23dd/BB_Wuxia_OST_W2_10___Broken_Blade_Defeat_Sting__wx_defeat_01_.mp3?_jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlIYXNoIjoiYjIwZmM0YWUyZjNhYzIxMiIsImJ1Y2tldCI6InJ1bndheS10YXNrLWFydGlmYWN0cyIsInN0YWdlIjoicHJvZCIsImV4cCI6MTc5NTMxNzAzOH0.stpzhU4cRoJcbwLe3AlGKRUWOWmpChg6Iexnq0w21oI",
    },
]


def find_ffmpeg() -> str:
    found = shutil.which("ffmpeg")
    if found:
        return found
    if FALLBACK_FFMPEG.exists():
        return str(FALLBACK_FFMPEG)
    raise RuntimeError("ffmpeg not found")


def download_all() -> None:
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(json.dumps(TRACKS, ensure_ascii=False, indent=2), encoding="utf-8")
    for t in TRACKS:
        dst = RAW_DIR / f"{t['id']}.mp3"
        if dst.exists() and dst.stat().st_size > 100_000:
            print(f"[SKIP] {dst.name} ({dst.stat().st_size} bytes)")
            continue
        print(f"[GET]  {t['id']} -> {dst.name}")
        req = urllib.request.Request(t["url"], headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=60) as resp:
            dst.write_bytes(resp.read())
        print(f"[OK]   {dst.name} ({dst.stat().st_size} bytes)")


def analyze_and_clips() -> None:
    ffmpeg = find_ffmpeg()
    QA_DIR.mkdir(parents=True, exist_ok=True)
    for t in TRACKS:
        src = RAW_DIR / f"{t['id']}.mp3"
        if not src.exists():
            print(f"[MISSING] {src}")
            continue
        # Decode 8kHz mono for vanilla-BB comparison metrics
        proc = subprocess.run(
            [ffmpeg, "-v", "error", "-i", str(src), "-ac", "1", "-ar", "8000", "-f", "s16le", "-"],
            capture_output=True,
            check=True,
        )
        raw = proc.stdout
        n = len(raw) // 2
        s = struct.unpack(f"<{n}h", raw)
        dur = n / 8000.0
        a = min(n, 20 * 8000) if dur > 50 else 0
        z = max(a + 8000, n - 20 * 8000) if dur > 50 else n
        body = s[a:z]
        blk = 5 * 8000
        dbs = []
        for i in range(0, len(body) - blk, blk):
            seg = body[i : i + blk]
            rms = math.sqrt(sum(x * x for x in seg) / len(seg)) / 32768.0
            dbs.append(20 * math.log10(max(rms, 1e-6)))
        mean_b = sum(dbs) / len(dbs) if dbs else -99.0
        std_b = math.sqrt(sum((x - mean_b) ** 2 for x in dbs) / len(dbs)) if dbs else 0.0
        lp1 = lp2 = 0.0
        e_low = e_mid = e_high = 0.0
        for x in body[: 8000 * 30]:
            lp1 += 0.19 * (x - lp1)
            lp2 += 0.586 * (x - lp2)
            low = lp1
            mid = lp2 - lp1
            high = x - lp2
            e_low += low * low
            e_mid += mid * mid
            e_high += high * high
        tot = e_low + e_mid + e_high + 1e-9
        print(
            f"{t['id']:18s} | {dur:5.1f}s | body_mean {mean_b:5.1f}dB | body_std {std_b:4.1f}dB | "
            f"EQ Low/Mid/Hi: {100*e_low/tot:4.1f}% / {100*e_mid/tot:4.1f}% / {100*e_high/tot:4.1f}%"
        )
        # Create compact 26s QA preview clip from core body
        clip = QA_DIR / f"{t['id']}_qa.mp3"
        ss = "00:00:30" if dur > 75 else "00:00:00"
        clip_dur = "26" if dur > 30 else str(int(dur))
        subprocess.run(
            [ffmpeg, "-y", "-v", "error", "-ss", ss, "-t", clip_dur, "-i", str(src), "-ac", "1", "-ar", "22050", "-b:a", "64k", str(clip)],
            check=True,
        )


ARCHIVED_VOCAL_IDS = {
    "wx_barbarians_01",
    "wx_beasts_01",
    "wx_undead_01",
    "wx_worldmap_01",
    "wx_worldmap_02",
    "wx_worldmap_03",
}


def master_to_ogg() -> None:
    ffmpeg = find_ffmpeg()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    # Remove archived vocal tracks from mod_wuxia/music/ so in-game OST is 100% pure instrumental
    for aid in ARCHIVED_VOCAL_IDS:
        old_ogg = OUT_DIR / f"{aid}.ogg"
        if old_ogg.exists():
            old_ogg.unlink()
            print(f"[REMOVED VOCAL] {old_ogg.name}")
    for t in TRACKS:
        if t["id"] in ARCHIVED_VOCAL_IDS:
            continue
        src = RAW_DIR / f"{t['id']}.mp3"
        dst = OUT_DIR / f"{t['id']}.ogg"
        if not src.exists():
            continue
        # Probe duration
        probe = subprocess.run(
            [ffmpeg, "-v", "error", "-i", str(src), "-ac", "1", "-ar", "8000", "-f", "s16le", "-"],
            capture_output=True,
            check=True,
        )
        dur = (len(probe.stdout) // 2) / 8000.0
        fade_in_d = 0.05 if t["role"] == "sting" else 0.4
        fade_out_d = 1.5 if t["role"] == "sting" else 2.5
        fade_out_start = max(0.0, dur - fade_out_d)
        af = (
            f"highshelf=f=3500:g=-2.5:t=q:w=0.7,"
            f"loudnorm=I={t['target_lufs']}:TP=-1.5:LRA=7,"
            f"afade=t=in:st=0:d={fade_in_d:.2f},"
            f"afade=t=out:st={fade_out_start:.2f}:d={fade_out_d:.2f}"
        )
        subprocess.run(
            [
                ffmpeg,
                "-y",
                "-v",
                "error",
                "-i",
                str(src),
                "-af",
                af,
                "-ar",
                "44100",
                "-ac",
                "2",
                "-c:a",
                "libvorbis",
                "-q:a",
                "5",
                str(dst),
            ],
            check=True,
        )
        print(f"[MASTERED] {dst.name} ({dst.stat().st_size / 1024:.0f} KB, target {t['target_lufs']} LUFS)")


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "all"
    if cmd == "download":
        download_all()
    elif cmd == "qa":
        analyze_and_clips()
    elif cmd == "master":
        master_to_ogg()
    elif cmd == "all":
        download_all()
        analyze_and_clips()
        master_to_ogg()
    else:
        print("Usage: wx_ost_pipeline.py [download|qa|master|all]")
        sys.exit(1)
