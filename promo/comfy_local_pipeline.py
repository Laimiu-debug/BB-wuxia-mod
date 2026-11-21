#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
《战场兄弟：武侠江湖》(BB Wuxia Mod) — 100% Local ComfyUI MiniMax H3 Video Pipeline
Zero cloud credits! Drives local Comfy Desktop (RTX 4070 Ti SUPER 16GB) via HTTP API.

Uses installed models in G:\\ComfyUI\\models:
- UNET: minimax_h3_fl2va_pruned_int8_convrot.safetensors
- LoRA: minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors (8-step Turbo)
- CLIP: qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors (type: minimax)
- Video VAE: minimax_h3_video_vae_int8_convrot.safetensors
- Audio VAE: minimax_h3_audio_vae_fp32.safetensors

Usage:
  python promo/comfy_local_pipeline.py --shots 1            # smoke test Shot 1
  python promo/comfy_local_pipeline.py --shots 2,3,4,5,6    # render remaining shots
  python promo/comfy_local_pipeline.py --shots all          # render all 6 shots
"""

import argparse
import functools
import json
import os
import time
import urllib.parse
import urllib.request
import uuid

print = functools.partial(print, flush=True)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

OUT_DIR = os.path.join("promo", "clips_local")
os.makedirs(OUT_DIR, exist_ok=True)

SHOTS = [
    {
        "idx": 1,
        "name": "shot_01_heroes",
        "image": "promo/keyframes/shot_01_heroes.png",
        "seed": 20260101,
        "length": 124,  # 5.17s @ 24fps (17*7 + 5)
        "prompt": (
            "Dark-fantasy Ming-dynasty Chinese wuxia tactical RPG film matching the exact bold black ink outlines "
            "and gritty hand-painted gouache style of <Picture 1>. The scene opens directly on <Picture 1>: five "
            "battle-hardened warriors stand in pouring rain on a muddy mountain courier road flanked by ruined stone "
            "watchtowers and misty bamboo under a storm sky with a crimson blood-moon. Slow cinematic low-angle push-in. "
            "Heavy rain streaks diagonally across the frame and glistens off iron lamellar armor, bronze dragon helmet, "
            "and woven straw raincape. Behind them, the tattered golden-tiger and azure-dragon war banner whips violently "
            "in fierce wind while distant lightning flickers through dark clouds. The bearded armored general tightens "
            "his grip on his poleblade and the green-robed swordsman slightly draws his sword with a cold metallic glint. "
            "Keep all five faces, outfits, and hand-painted ink lines strictly consistent. "
            "Audio: pouring storm rain, howling wind, snapping heavy cloth banner, distant thunder, solitary haunting "
            "Chinese bamboo xiao flute and a deep slow war drum beat."
        ),
    },
    {
        "idx": 2,
        "name": "shot_02_cultivation",
        "image": "promo/keyframes/shot_02_cultivation.png",
        "seed": 20260202,
        "length": 124,
        "prompt": (
            "Dark-fantasy Ming-dynasty Chinese wuxia film matching the exact bold black ink outlines and hand-painted "
            "gouache art style of <Picture 1>. Opening directly on <Picture 1> inside a candlelit ancient martial arts "
            "pavilion, the camera executes a smooth slow pull-back and gentle drift over the wooden altar table. "
            "The five floating bronze and jade martial-arts medallions slowly revolve clockwise in mid-air like a sacred "
            "constellation, pulsing rhythmically with golden and emerald qi light as glowing golden meridian threads flow "
            "between them. Inside the open ornate hexagonal box, the dragon-carved molten-gold Marrow-Wash Elixir radiates "
            "warm golden embers rising upward while wispy black ink-smoke curls around flickering tall candles and ancient "
            "bamboo scrolls. Preserve the exact hand-painted illustration texture with zero warping. "
            "Audio: crisp bamboo scroll rustle, resonant jade chimes as medallions glow, rapid plucked Chinese guzheng "
            "arpeggios building tension, deep mystical internal qi hum."
        ),
    },
    {
        "idx": 3,
        "name": "shot_03_combat_vfx",
        "image": "promo/keyframes/shot_03_combat_vfx.png",
        "seed": 20260303,
        "length": 124,
        "prompt": (
            "High-energy dark-fantasy Ming-dynasty Chinese wuxia combat film in the exact bold black ink-outline and "
            "gritty hand-painted gouache style of <Picture 1>. Starting directly from <Picture 1> in the rain-slicked "
            "ruined temple courtyard at night, dynamic side-tracking camera sweeps across the explosive battle. "
            "On the left, the bamboo-green robed swordsman dashes swiftly through swirling cyan mist, swinging his ancient "
            "sword to launch the blazing cyan crescent sword wave and five spectral jade flying blades forward. At center, "
            "the blazing fiery crimson saber arc slams hard against the armored general's translucent glowing bronze "
            "Sanskrit Golden Bell dome, bursting golden sparks and shockwave ripples outward with a crisp impact tremor. "
            "On the right, the straw-hat veteran drives his palm forward launching the coiled black-and-gold ink dragon "
            "energy blast through flying ink splatters and rain. Keep all character designs and ink-painted style locked. "
            "Audio: sharp whistling sword slash, violent metallic clash, deep resonant bronze temple bell tolling on "
            "shield impact, roaring dragon energy blast, driving Chinese war drums and sharp pipa strings."
        ),
    },
    {
        "idx": 4,
        "name": "shot_04_shanhai_bosses",
        "image": "promo/keyframes/shot_04_shanhai_bosses.png",
        "seed": 20260404,
        "length": 124,
        "prompt": (
            "Monumental dark-fantasy Chinese mythological film preserving the exact bold black ink-outline hand-painted "
            "gouache illustration style of <Picture 1>. Opening directly on <Picture 1> across a desolate volcanic "
            "wasteland beneath churning blood-red storm clouds, the low-angle camera slowly tilts upward and pushes "
            "through drifting dark volcanic ash and purple mist as colossal ancient monsters awaken. Dead-center, the "
            "towering headless bronze-armored war god Xingtian steps heavily forward, chest eyes glaring fiercely while "
            "his fanged belly mouth opens wider in a terrifying primal roar as he raises his massive notched battle-axe "
            "and ancient bronze shield. On the left, the tattered-winged teal dragon spreads its wings amidst crackling "
            "lightning while the ram-horned Taotie beast snarls exhaling dark crimson smoke. On the right, the pale "
            "Nine-Tailed Fox Empress's purple tails billow while nine venomous turquoise serpent heads writhe and hiss. "
            "High overhead, the flame-wreathed Three-Legged Golden Crow beats its fiery wings scattering embers. "
            "Audio: earth-shaking sub-bass rumble, ominous ancient bronze war horn, monstrous echoing roar, crackling "
            "thunder, eerie distant chimes."
        ),
    },
    {
        "idx": 5,
        "name": "shot_05_xingtian_clash",
        "image": "promo/keyframes/shot_05_xingtian_clash.png",
        "seed": 20260505,
        "length": 124,
        "prompt": (
            "Climactic dark-fantasy Ming-dynasty Chinese wuxia boss-battle film preserving the exact bold black ink "
            "outlines and gritty hand-painted gouache texture of <Picture 1>. Starting directly on <Picture 1> on the "
            "storm-lashed mountain battlefield, fast dramatic camera rush-in transitions into heroic slow-motion impact. "
            "The colossal headless bronze war god Xingtian swings his giant rune-carved battle-axe downward in an "
            "earth-shattering explosion of fire, shattered rocks, and flying black ink splatters while roaring furiously. "
            "Below, the gilded-dragon-helmet armored general holds his stance amidst blinding sparks, the bamboo-green "
            "robed swordsman vaults gracefully through the rain slashing a brilliant cyan crescent sword-qi arc across "
            "Xingtian's bronze pauldron, and from the right the straw-hat veteran and white-bearded Taoist unleash a "
            "surging black-and-gold ink dragon blast into the giant's flank. High at center amidst jagged white lightning, "
            "the glowing cracked crimson crystal core bound in ancient axe-etched bronze bands rotates and pulses brightly. "
            "Audio: thunderous Chinese war-drum crescendo, colossal earth-shattering axe crash, razor sword-qi slash, "
            "roaring dragon energy detonation, shimmering crystal chime."
        ),
    },
    {
        "idx": 6,
        "name": "shot_06_title_card",
        "image": "promo/keyframes/shot_06_title_card.png",
        "seed": 20260606,
        "length": 107,  # 4.46s @ 24fps (17*6 + 5)
        "prompt": (
            "Majestic dark ink-wash Chinese wuxia game title card animation strictly anchored on <Picture 1>. "
            "Steady, very slow symmetrical cinematic push-in. Keep the vertical forged-iron ancient sword with bronze "
            "cloud crossguard, the giant glowing crimson blood-moon, and all hammered antique-gold Chinese calligraphy "
            "text '战场兄弟：武侠江湖' and 'BB WUXIA MOD' completely sharp, stationary, crisp, and legible with zero "
            "distortion or character morphing. Bring subtle atmospheric life to the background: the black swallow "
            "silhouette glides gently across the crimson blood-moon, wisps of dark ink-smoke drift lazily over the "
            "jagged misty mountain peaks, glowing crimson-gold embers float slowly upward, and one crisp cold metallic "
            "gleam slides smoothly down the vertical sword blade. "
            "Audio: one final massive resonant war-drum boom and deep bronze gong decaying into mountain echo, the crisp "
            "metallic ring of a sword sliding into its scabbard, and a solitary haunting Chinese bamboo xiao flute fading "
            "into silence."
        ),
    },
]


def detect_comfy_url():
    for port in (8000, 8188, 8189):
        base = f"http://127.0.0.1:{port}"
        try:
            with urllib.request.urlopen(base + "/system_stats", timeout=2) as r:
                if r.status == 200:
                    return base
        except Exception:
            pass
    raise RuntimeError("ComfyUI local server not reachable on ports 8000/8188/8189. Please start Comfy Desktop.")


def upload_image(base_url, img_path):
    boundary = f"----ComfyBoundary{uuid.uuid4().hex}"
    filename = os.path.basename(img_path)
    with open(img_path, "rb") as f:
        img_bytes = f.read()
    body = (
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="image"; filename="{filename}"\r\n'
        f"Content-Type: image/png\r\n\r\n"
    ).encode("utf-8") + img_bytes + (
        f"\r\n--{boundary}\r\n"
        f'Content-Disposition: form-data; name="overwrite"\r\n\r\ntrue\r\n'
        f"--{boundary}--\r\n"
    ).encode("utf-8")

    req = urllib.request.Request(
        f"{base_url}/upload/image",
        data=body,
        method="POST",
        headers={"Content-Type": f"multipart/form-data; boundary={boundary}"},
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        res = json.loads(r.read().decode("utf-8"))
    return res["name"]


def build_h3_i2v_prompt(uploaded_img, prompt_text, width, height, length, steps, seed, prefix):
    """Exact API prompt graph matching official ComfyUI MiniMax H3 FL2VA + 8-step Turbo template."""
    return {
        "6": {
            "class_type": "UNETLoader",
            "inputs": {
                "unet_name": "minimax_h3_fl2va_pruned_int8_convrot.safetensors",
                "weight_dtype": "default",
            },
        },
        "121": {
            "class_type": "LoraLoaderModelOnly",
            "inputs": {
                "model": ["6", 0],
                "lora_name": "minimax_h3_fl2v_turbo_8step_v1.0_comfyui_bf16.safetensors",
                "strength_model": 1.0,
            },
        },
        "13": {
            "class_type": "CLIPLoader",
            "inputs": {
                "clip_name": "qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors",
                "type": "minimax",
                "device": "default",
            },
        },
        "11": {
            "class_type": "VAELoader",
            "inputs": {"vae_name": "minimax_h3_video_vae_int8_convrot.safetensors"},
        },
        "24": {
            "class_type": "VAELoader",
            "inputs": {"vae_name": "minimax_h3_audio_vae_fp32.safetensors"},
        },
        "114": {
            "class_type": "LoadImage",
            "inputs": {"image": uploaded_img},
        },
        "104": {
            "class_type": "MiniMaxH3ImageToVideo",
            "inputs": {
                "clip": ["13", 0],
                "vae": ["11", 0],
                "first_frame": ["114", 0],
                "prompt": prompt_text,
                "width": width,
                "height": height,
                "length": length,
            },
        },
        "15": {
            "class_type": "RandomNoise",
            "inputs": {"noise_seed": seed},
        },
        "16": {
            "class_type": "BasicGuider",
            "inputs": {
                "model": ["121", 0],
                "conditioning": ["104", 0],
            },
        },
        "17": {
            "class_type": "KSamplerSelect",
            "inputs": {"sampler_name": "res_multistep"},
        },
        "9": {
            "class_type": "BasicScheduler",
            "inputs": {
                "model": ["121", 0],
                "scheduler": "simple",
                "steps": steps,
                "denoise": 1.0,
            },
        },
        "14": {
            "class_type": "SamplerCustomAdvanced",
            "inputs": {
                "noise": ["15", 0],
                "guider": ["16", 0],
                "sampler": ["17", 0],
                "sigmas": ["9", 0],
                "latent_image": ["104", 1],
            },
        },
        "10": {
            "class_type": "VAEDecode",
            "inputs": {
                "samples": ["14", 0],
                "vae": ["11", 0],
            },
        },
        "23": {
            "class_type": "VAEDecodeAudio",
            "inputs": {
                "samples": ["14", 0],
                "vae": ["24", 0],
            },
        },
        "91": {
            "class_type": "CreateVideo",
            "inputs": {
                "images": ["10", 0],
                "audio": ["23", 0],
                "fps": 24.0,
            },
        },
        "92": {
            "class_type": "SaveVideo",
            "inputs": {
                "video": ["91", 0],
                "filename_prefix": prefix,
                "format": "auto",
                "codec": "auto",
            },
        },
    }


def submit_prompt(base_url, prompt_graph):
    payload = json.dumps({"prompt": prompt_graph, "client_id": "bb_wuxia_local"}).encode("utf-8")
    req = urllib.request.Request(
        f"{base_url}/prompt",
        data=payload,
        method="POST",
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            res = json.loads(r.read().decode("utf-8"))
        return res["prompt_id"]
    except urllib.error.HTTPError as e:
        err_body = e.read().decode("utf-8", errors="ignore")
        raise RuntimeError(f"ComfyUI rejected prompt (HTTP {e.code}): {err_body}")


def wait_and_download(base_url, prompt_id, dst_path, timeout_s=1800):
    t0 = time.time()
    last_log = 0.0
    while True:
        elapsed = time.time() - t0
        if elapsed > timeout_s:
            raise TimeoutError(f"Prompt {prompt_id} timed out after {timeout_s}s")
        with urllib.request.urlopen(f"{base_url}/history/{prompt_id}", timeout=10) as r:
            hist = json.loads(r.read().decode("utf-8"))
        if prompt_id in hist:
            entry = hist[prompt_id]
            status = entry.get("status", {})
            if status.get("status_str") == "error":
                raise RuntimeError(f"ComfyUI execution error: {json.dumps(status, ensure_ascii=False)[:1200]}")
            outputs = entry.get("outputs", {})
            # Find saved video file in SaveVideo node output
            for nid, out in outputs.items():
                for key in ("images", "videos", "gifs"):
                    for item in out.get(key, []):
                        fn = item.get("filename", "")
                        if fn.lower().endswith((".mp4", ".webm", ".mov", ".mkv")):
                            q = urllib.parse.urlencode({
                                "filename": fn,
                                "subfolder": item.get("subfolder", ""),
                                "type": item.get("type", "output"),
                            })
                            with urllib.request.urlopen(f"{base_url}/view?{q}", timeout=60) as vr:
                                data = vr.read()
                            with open(dst_path, "wb") as f:
                                f.write(data)
                            print(f"  [DONE] Saved {dst_path} ({len(data)/1024/1024:.2f} MB) in {elapsed:.1f}s")
                            return dst_path
            raise RuntimeError(f"Job finished without video output: {json.dumps(outputs, ensure_ascii=False)[:800]}")
        if elapsed - last_log >= 20.0:
            print(f"  ... generating ({elapsed:.0f}s elapsed)")
            last_log = elapsed
        time.sleep(4.0)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--shots", default="1", help="Comma-separated shot numbers (1..6) or 'all'")
    ap.add_argument("--width", type=int, default=1056)
    ap.add_argument("--height", type=int, default=608)
    ap.add_argument("--steps", type=int, default=8)
    ap.add_argument("--force", action="store_true", help="Re-render even if output mp4 exists")
    args = ap.parse_args()

    base_url = detect_comfy_url()
    print(f"[ComfyUI] Connected to {base_url}")

    if args.shots.strip().lower() == "all":
        selected = [s["idx"] for s in SHOTS]
    else:
        selected = [int(x.strip()) for x in args.shots.split(",") if x.strip()]

    for shot in SHOTS:
        if shot["idx"] not in selected:
            continue
        dst = os.path.join(OUT_DIR, f"{shot['name']}.mp4")
        if os.path.exists(dst) and os.path.getsize(dst) > 500_000 and not args.force:
            print(f"[Skip] {dst} already exists ({os.path.getsize(dst)/1024/1024:.2f} MB). Use --force to overwrite.")
            continue

        print(f"\n[Shot {shot['idx']}] Uploading {shot['image']} -> ComfyUI...")
        uploaded = upload_image(base_url, shot["image"])
        print(f"  Uploaded as: {uploaded} | Target: {args.width}x{args.height}, {shot['length']} frames, {args.steps} steps (Turbo)")
        graph = build_h3_i2v_prompt(
            uploaded_img=uploaded,
            prompt_text=shot["prompt"],
            width=args.width,
            height=args.height,
            length=shot["length"],
            steps=args.steps,
            seed=shot["seed"],
            prefix=f"bb_wuxia_local/{shot['name']}",
        )
        pid = submit_prompt(base_url, graph)
        print(f"  Queued prompt_id={pid}")
        wait_and_download(base_url, pid, dst)


if __name__ == "__main__":
    main()
