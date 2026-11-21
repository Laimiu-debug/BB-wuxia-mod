#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
《战场兄弟：武侠江湖》— 100% From-Scratch Local Zero-Cloud ComfyUI Pipeline
ZERO Runway / ZERO cloud assets! Starts strictly from raw game sprites (art/hd/, art/busts/).

Stage 1 (keyframes): Qwen Image 2.1 + 8-step Turbo LoRA -> 1472x832 widescreen keyframes (incl. Chinese calligraphy)
Stage 2 (videos):    MiniMax H3 FL2VA + 8-step Turbo LoRA -> 1056x608 24fps videos with native stereo audio (music+SFX+Chinese narration)

Usage:
  python promo/from_scratch_local_pipeline.py --stage keyframes
  python promo/from_scratch_local_pipeline.py --stage videos
  python promo/from_scratch_local_pipeline.py --stage all
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

BASE_OUT = os.path.join("promo", "from_scratch_local")
KF_DIR = os.path.join(BASE_OUT, "keyframes")
CLIP_DIR = os.path.join(BASE_OUT, "clips")
os.makedirs(KF_DIR, exist_ok=True)
os.makedirs(CLIP_DIR, exist_ok=True)

QWEN_TURBO_SIGMAS = "1.0, 0.978453, 0.95418, 0.926626, 0.89508, 0.845148, 0.704534, 0.414568, 0"

SCENES = [
    {
        "idx": 1,
        "name": "sc_01_chiyou_awakens",
        "ref_image": "promo/from_scratch_local/refs/raw_01_chiyou_fiends.png",
        "kf_seed": 880101,
        "vid_seed": 990101,
        "length": 124,  # 5.17s @ 24fps
        "kf_prompt": (
            "16:9宽银幕暗黑明末写实国风战棋游戏宣传插画，严格延续参考图1的粗黑墨线勾边、厚重暗金青铜锈水彩厚涂质感与角色造型。"
            "在血云翻涌、焦土龟裂的上古凶黎青铜古冢祭坛之中，正中央顶天立地耸立着参考图1左上角的铜头铁额上古兵主蚩尤战魄，"
            "身披锈蚀厚重青铜兽面战甲、戴双角铜面魔盔，背后斜插双斧与长矛，周身赤黑煞气翻腾；"
            "左侧残岩上盘踞着参考图1右上角青黑双翼獠牙恶虎裂风穷奇，右侧黑雾中现身参考图1左下角披甲双獠牙虎魔檮杌与右下角漆黑无面人形妖魔浑沌。"
            "雷电划破血红夜空，火星与暗墨烟雾弥漫，极强压迫感与暗黑山海志怪史诗氛围，画面中不要出现任何文字或UI。"
        ),
        "vid_prompt": (
            "Monumental dark-fantasy Chinese mythological trailer shot strictly continuing from <Picture 1>, "
            "preserving the bold black ink outlines and dark hand-painted gouache texture. Low-angle slow cinematic "
            "tilt-up and push-in over the ancient stepped bronze altar through churning crimson storm clouds and drifting ash fog. "
            "Dead-center, the colossal horned bronze-masked war god Chiyou rises menacingly with blazing crimson eyes, "
            "dark scarlet war aura surging around the crossed battle-axes and spears behind his shoulders. "
            "On the left, the dark-teal winged tiger Qiongqi spreads its jagged wings and roars above the armored tusked tiger "
            "fiend Taowu; on the right, the pitch-black faceless humanoid fiend Hundun shifts slowly through swirling dark mist "
            "while jagged crimson lightning flashes across the peaks. "
            "Audio: epic dark Chinese war trailer score with ominous bronze war horns, booming low taiko drums, "
            "thunderous monstrous growls, crackling storm lightning, and a deep authoritative gravelly Chinese male "
            "narrator speaking dramatically in Mandarin: \"大荒古冢开，兵主蚩尤醒！\""
        ),
    },
    {
        "idx": 2,
        "name": "sc_02_duel_chiyou",
        "ref_images": [
            "art/hd/wx_boss_chiyou.png",
            "promo/assets/hero_general.png",
            "promo/assets/hero_swordsman.png",
            "art/hd/wx_relic_liquan.png",
            "art/hd/wx_vfx_02.png",
        ],
        "kf_seed": 880219,
        "vid_seed": 990202,
        "length": 124,  # 5.17s @ 24fps
        "kf_prompt": (
            "16:9宽银幕高燃暗黑明末武侠Boss决战插画，粗黑墨线勾边与暗黑写实水彩厚涂战棋风格。"
            "雷雨交加的焦黑山谷战场上，画面右侧耸立着顶天立地的巨大魔神——严格按照图1的铜头铁额双角青铜魔面战神蚩尤造型，戴双角青铜恶鬼面盔、披厚重古铜战甲，正挥舞巨型战斧劈下赤黑狂岚；"
            "画面左侧两名体型正常的江湖侠客迎战巨神：下方站立着严格按图2造型的威严黑须重甲悍将（戴红缨金龙帅胄、穿山文重铠），双手紧握图4的红缨沥泉盘龙神枪向前突刺，枪尖迸射耀眼金白穿云枪芒；"
            "左上空凌空跃起严格按图3造型的年轻竹青剑衫少侠（黑发高马尾配蓝布抹额），挥剑斩出一道如同图5般炽烈弯曲的烈阳火罡弧光劈向蚩尤胸甲。"
            "每个角色只出现一次，绝不重复人物，暴雨雷电交加、火星与黑墨飞溅，无任何文字或UI。"
        ),
        "vid_prompt": (
            "Explosive high-energy dark-fantasy Chinese wuxia boss battle film strictly starting from <Picture 1>, "
            "keeping the bold black ink outlines, gritty hand-painted gouache illustration style, and exact character designs rock-solid. "
            "Fast dramatic camera rush-in transitioning into heroic slow-motion clash in pouring storm rain and flashing lightning. "
            "On the right, the giant horned bronze-armored war god Chiyou heaves his massive poleaxe downward amidst "
            "shattering rocks and swirling crimson battle-aura. Defying him from the bottom-left, the bearded heavy-armored general "
            "in the golden-dragon helmet lunges forward thrusting his red-tasseled dragon spear in a blinding golden-white piercing beam; "
            "from the top-left, the leaping young swordsman in bamboo-green robes and blue headband surges through the rain, "
            "sweeping his sword along the blazing crimson-gold fiery crescent slash straight into Chiyou's bronze chestplate amidst flying sparks and ink splatters. "
            "Audio: furious Chinese war drums crescendo, rapid guzheng and erhu battle climax, deafening metallic axe "
            "and spear clash, roaring flame burst, and a fierce gravelly Chinese male narrator proclaiming in Mandarin: "
            "\"以凡人之躯，斩上古凶神！\""
        ),
    },
    {
        "idx": 3,
        "name": "sc_03_title_chiyou",
        "ref_image": "promo/from_scratch_local/refs/raw_03_title_emblem.png",
        "kf_seed": 880303,
        "vid_seed": 990303,
        "length": 107,  # 4.46s @ 24fps
        "kf_prompt": (
            "16:9宽银幕暗黑国风武侠游戏宣传片终章片名定帧海报，严格采用参考图1的粗黑墨线水墨厚涂暗黑质感。"
            "深沉黑红烽火夜空与水墨崇山峻岭背景中，参考图1右上角的霸气方天画戟凛然竖立于画面中央，戟后高悬一轮暗红血日与飘扬残破黑旗，"
            "黑旗上清晰绘有参考图1左上角的威猛金虎与青龙交缠图腾，暗红火星与黑墨烟雾从山谷缓缓升腾。"
            "画面中下方居中位置，用极其大气苍劲、笔画清晰工整、绝不缺笔错字的鎏金狂草毛笔书法大字写着：\"战场兄弟：武侠江湖\"，"
            "鎏金主标题正下方用清晰端正的淡金色衬线中文小字写着：\"山海兵主 · 血战蚩尤\"。"
            "构图对称庄严，暗黑高级感，所有中文字体锐利清晰完全可读。"
        ),
        "vid_prompt": (
            "Majestic dark ink-wash Chinese wuxia game title card outro strictly anchored on <Picture 1>. "
            "Very slow, steady symmetrical cinematic zoom-in. Keep the central vertical Fangtian halberd, the crimson "
            "glow, and all golden Chinese calligraphy title text \"战场兄弟：武侠江湖\" and \"山海兵主 · 血战蚩尤\" "
            "completely razor-sharp, rock-steady, and legible with zero distortion or morphing. Subtle atmospheric motion: "
            "the tattered tiger-and-dragon banner ripples gently in night wind, dark ink mist curls past the mountain "
            "peaks, glowing crimson-gold embers float slowly upward, and a single cold metallic sheen travels down the "
            "halberd blade. Audio: one final massive resonant bronze gong and war-drum boom echoing across mountains, "
            "fading into a solitary haunting Chinese bamboo xiao flute, with a deep steady Chinese male narrator stating "
            "solemnly in Mandarin: \"战场兄弟，武侠江湖！\""
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
    raise RuntimeError("ComfyUI local server not reachable on ports 8000/8188/8189.")


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
        return json.loads(r.read().decode("utf-8"))["name"]


def build_qwen21_turbo_graph(uploaded_refs, prompt_text, width, height, seed, prefix):
    """Official Qwen Image 2.1 + 8-step Turbo LoRA multi-reference image graph."""
    if isinstance(uploaded_refs, str):
        uploaded_refs = [uploaded_refs]
    te_inputs = {
        "clip": ["4", 0],
        "vae": ["5", 0],
        "prompt": prompt_text,
        "negative_prompt": "",
        "resolution": 1024,
    }
    graph = {
        "1": {
            "class_type": "UNETLoader",
            "inputs": {
                "unet_name": "qwen_image_2.1_int8_convrot.safetensors",
                "weight_dtype": "default",
            },
        },
        "2": {
            "class_type": "LoraLoaderModelOnly",
            "inputs": {
                "model": ["1", 0],
                "lora_name": "qwen_image_2.1_turbo_lora_avg_rank_178_bf16.safetensors",
                "strength_model": 1.0,
            },
        },
        "3": {
            "class_type": "QwenImage21Cache",
            "inputs": {
                "model": ["2", 0],
                "device": "auto",
                "dtype": "default",
            },
        },
        "4": {
            "class_type": "CLIPLoader",
            "inputs": {
                "clip_name": "qwen3vl_8b_int8_convrot.safetensors",
                "type": "qwen_image",
                "device": "default",
            },
        },
        "5": {
            "class_type": "VAELoader",
            "inputs": {"vae_name": "qwen_image_2.1_vae_bf16.safetensors"},
        },
    }
    for i, uref in enumerate(uploaded_refs, 1):
        nid = str(200 + i)
        graph[nid] = {"class_type": "LoadImage", "inputs": {"image": uref}}
        te_inputs[f"images.image_{i}"] = [nid, 0]

    graph.update({
        "7": {"class_type": "TextEncodeQwenImage21", "inputs": te_inputs},
        "8": {
            "class_type": "EmptyLatentImage",
            "inputs": {"width": width, "height": height, "batch_size": 1},
        },
        "9": {
            "class_type": "CFGGuider",
            "inputs": {
                "model": ["3", 0],
                "positive": ["7", 0],
                "negative": ["7", 1],
                "cfg": 1.0,
            },
        },
        "10": {"class_type": "ManualSigmas", "inputs": {"sigmas": QWEN_TURBO_SIGMAS}},
        "11": {"class_type": "KSamplerSelect", "inputs": {"sampler_name": "euler"}},
        "12": {"class_type": "RandomNoise", "inputs": {"noise_seed": seed}},
        "13": {
            "class_type": "SamplerCustomAdvanced",
            "inputs": {
                "noise": ["12", 0],
                "guider": ["9", 0],
                "sampler": ["11", 0],
                "sigmas": ["10", 0],
                "latent_image": ["8", 0],
            },
        },
        "14": {"class_type": "VAEDecode", "inputs": {"samples": ["13", 0], "vae": ["5", 0]}},
        "15": {"class_type": "SaveImage", "inputs": {"images": ["14", 0], "filename_prefix": prefix}},
    })
    return graph


def build_h3_i2v_graph(uploaded_kf, prompt_text, width, height, length, steps, seed, prefix):
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
            "inputs": {"image": uploaded_kf},
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
        "15": {"class_type": "RandomNoise", "inputs": {"noise_seed": seed}},
        "16": {"class_type": "BasicGuider", "inputs": {"model": ["121", 0], "conditioning": ["104", 0]}},
        "17": {"class_type": "KSamplerSelect", "inputs": {"sampler_name": "res_multistep"}},
        "9": {"class_type": "BasicScheduler", "inputs": {"model": ["121", 0], "scheduler": "simple", "steps": steps, "denoise": 1.0}},
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
        "10": {"class_type": "VAEDecode", "inputs": {"samples": ["14", 0], "vae": ["11", 0]}},
        "23": {"class_type": "VAEDecodeAudio", "inputs": {"samples": ["14", 0], "vae": ["24", 0]}},
        "91": {"class_type": "CreateVideo", "inputs": {"images": ["10", 0], "audio": ["23", 0], "fps": 24.0}},
        "92": {"class_type": "SaveVideo", "inputs": {"video": ["91", 0], "filename_prefix": prefix, "format": "auto", "codec": "auto"}},
    }


def submit_and_fetch(base_url, graph, dst_path, exts, timeout_s=1800):
    payload = json.dumps({"prompt": graph, "client_id": "bb_wuxia_scratch"}).encode("utf-8")
    req = urllib.request.Request(
        f"{base_url}/prompt",
        data=payload,
        method="POST",
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            pid = json.loads(r.read().decode("utf-8"))["prompt_id"]
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"HTTP {e.code}: {e.read().decode('utf-8', errors='ignore')}")

    print(f"  Queued prompt_id={pid}")
    t0 = time.time()
    last_log = 0.0
    while True:
        elapsed = time.time() - t0
        if elapsed > timeout_s:
            raise TimeoutError(f"Timeout waiting for {pid}")
        with urllib.request.urlopen(f"{base_url}/history/{pid}", timeout=10) as r:
            hist = json.loads(r.read().decode("utf-8"))
        if pid in hist:
            entry = hist[pid]
            st = entry.get("status", {})
            if st.get("status_str") == "error":
                raise RuntimeError(f"Execution error: {json.dumps(st, ensure_ascii=False)[:1500]}")
            for _, out in entry.get("outputs", {}).items():
                for key in ("images", "videos", "gifs"):
                    for item in out.get(key, []):
                        fn = item.get("filename", "")
                        if fn.lower().endswith(exts):
                            q = urllib.parse.urlencode({
                                "filename": fn,
                                "subfolder": item.get("subfolder", ""),
                                "type": item.get("type", "output"),
                            })
                            with urllib.request.urlopen(f"{base_url}/view?{q}", timeout=60) as vr:
                                data = vr.read()
                            with open(dst_path, "wb") as f:
                                f.write(data)
                            print(f"  [DONE] {dst_path} ({len(data)/1024/1024:.2f} MB) in {elapsed:.1f}s")
                            return dst_path
            raise RuntimeError(f"No matching output for {exts}: {json.dumps(entry.get('outputs', {}), ensure_ascii=False)[:600]}")
        if elapsed - last_log >= 20.0:
            print(f"  ... running ({elapsed:.0f}s)")
            last_log = elapsed
        time.sleep(3.0)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--stage", choices=["keyframes", "videos", "all"], default="keyframes")
    ap.add_argument("--only", default="", help="Optional comma-separated scene numbers (e.g. 2)")
    ap.add_argument("--force", action="store_true")
    args = ap.parse_args()

    only_set = {int(x.strip()) for x in args.only.split(",") if x.strip()} if args.only else None

    base = detect_comfy_url()
    print(f"[ComfyUI] Connected to {base}")

    if args.stage in ("keyframes", "all"):
        print("\n=== STAGE 1: Qwen Image 2.1 + Turbo LoRA (From-Scratch Keyframes) ===")
        for sc in SCENES:
            if only_set and sc["idx"] not in only_set:
                continue
            dst = os.path.join(KF_DIR, f"{sc['name']}.png")
            if os.path.exists(dst) and os.path.getsize(dst) > 200_000 and not args.force:
                print(f"[Skip] {dst} exists.")
                continue
            refs = sc.get("ref_images") or [sc["ref_image"]]
            print(f"\n[KF {sc['idx']}] Uploading {len(refs)} raw mod ref(s)...")
            ups = [upload_image(base, r) for r in refs]
            g = build_qwen21_turbo_graph(
                uploaded_refs=ups,
                prompt_text=sc["kf_prompt"],
                width=1472,
                height=832,
                seed=sc["kf_seed"],
                prefix=f"bb_wuxia_scratch/kf_{sc['idx']:02d}",
            )
            submit_and_fetch(base, g, dst, (".png", ".jpg", ".webp"))

    if args.stage in ("videos", "all"):
        print("\n=== STAGE 2: MiniMax H3 FL2VA + 8-step Turbo (From-Scratch Native AV Clips) ===")
        for sc in SCENES:
            if only_set and sc["idx"] not in only_set:
                continue
            kf = os.path.join(KF_DIR, f"{sc['name']}.png")
            dst = os.path.join(CLIP_DIR, f"{sc['name']}.mp4")
            assert os.path.exists(kf), f"Missing keyframe {kf}; run --stage keyframes first"
            if os.path.exists(dst) and os.path.getsize(dst) > 500_000 and not args.force:
                print(f"[Skip] {dst} exists.")
                continue
            print(f"\n[VID {sc['idx']}] Uploading local keyframe {kf}...")
            up = upload_image(base, kf)
            g = build_h3_i2v_graph(
                uploaded_kf=up,
                prompt_text=sc["vid_prompt"],
                width=1056,
                height=608,
                length=sc["length"],
                steps=8,
                seed=sc["vid_seed"],
                prefix=f"bb_wuxia_scratch/vid_{sc['idx']:02d}",
            )
            submit_and_fetch(base, g, dst, (".mp4", ".webm", ".mov", ".mkv"))


if __name__ == "__main__":
    main()
