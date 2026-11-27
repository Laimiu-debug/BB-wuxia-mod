#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Unpacks ALL overhauled Wuxia 1000-Faces paperdoll layers (`mod_wuxia/brushes/wx_busts_0.brush`,
128x164) and curated representative weapons & shields (`mod_wuxia/brushes/wx_weapons_0.brush`)
as compact embedded WebP data URIs into `<script id="wx-bundle">` inside `山海武侠.html`,
and injects an interactive offline 「千人千面 · 纸娃娃换装试衣工坊」 (`paperdoll`) tab.

100% standalone single-file HTML (zero external `art/` path dependencies) and 100% idempotent.
"""

import base64
import io
import json
import math
import re
import struct
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parent.parent
MOD_DIR = ROOT / "mod_wuxia"
WIKI_PATH = ROOT / "山海武侠.html"
APPEARANCE_NUT = MOD_DIR / "mod_wuxia" / "config" / "wx_appearance.nut"
EQUIP_VIS_NUT = MOD_DIR / "mod_wuxia" / "systems" / "wx_equipment_visuals.nut"
SHANHAI_NUTS = [
    MOD_DIR / "mod_wuxia" / "config" / "wx_shanhai.nut",
    MOD_DIR / "mod_wuxia" / "config" / "wx_shanhai_expansion.nut",
    MOD_DIR / "mod_wuxia" / "config" / "wx_beast_craft.nut",
]

CSS_START = "/* === WX_PAPERDOLL_STUDIO_CSS_START === */"
CSS_END = "/* === WX_PAPERDOLL_STUDIO_CSS_END === */"
JS_START = "// === WX_PAPERDOLL_STUDIO_JS_START ==="
JS_END = "// === WX_PAPERDOLL_STUDIO_JS_END ==="
EVT_START = "// --- WX_PAPERDOLL_EVENTS_START ---"
EVT_END = "// --- WX_PAPERDOLL_EVENTS_END ---"
CHG_START = "// --- WX_PAPERDOLL_CHANGE_START ---"
CHG_END = "// --- WX_PAPERDOLL_CHANGE_END ---"


def load_brush_sprites(brush_path: Path) -> dict[str, Image.Image]:
    data = brush_path.read_bytes()
    magic, _ver, gfx_len = struct.unpack_from("<IHH", data, 0)
    assert magic == 0xBAADFAAD, f"Invalid brush magic in {brush_path}"
    gfx_rel = data[8 : 8 + gfx_len].decode("ascii").replace("\\", "/")
    pos = 8 + gfx_len
    aw, ah = struct.unpack_from("<HH", data, pos)
    pos += 4 + 12
    rec_cnt, _, _ = struct.unpack_from("<IHI", data, pos)
    pos += 10

    atlas = Image.open(MOD_DIR / gfx_rel).convert("RGBA")
    sprites: dict[str, Image.Image] = {}
    for _ in range(rec_cnt):
        _, sid_len = struct.unpack_from("<QH", data, pos)
        pos += 10
        sid = data[pos : pos + sid_len].decode("ascii")
        pos += sid_len
        _, w, h, _ox, _oy = struct.unpack_from("<QIIhh", data, pos)
        pos += 20 + 25 + 4 + 4
        _f_cnt, src_len = struct.unpack_from("<HH", data, pos)
        pos += 4 + src_len
        u0, u1, v0, v1, fL, _fR, _fT, fB = struct.unpack_from("<8f", data, pos)
        pos += 32 + 3

        ax0 = int(round(u0 * aw))
        ax1 = int(round(u1 * aw))
        ay0 = int(round(v0 * ah))
        ay1 = int(round(v1 * ah))
        crop = ImageOps.flip(atlas.crop((ax0, ay0, ax1, ay1)))
        bx0 = int(round(fL + w / 2.0))
        by0 = int(round(h / 2.0 - fB))
        canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        canvas.paste(crop, (max(0, bx0), max(0, by0)))
        sprites[sid] = canvas
    return sprites


def to_webp_uri(im: Image.Image, quality: int = 80) -> str:
    buf = io.BytesIO()
    im.save(buf, format="WEBP", quality=quality, method=5)
    return "data:image/webp;base64," + base64.b64encode(buf.getvalue()).decode("ascii")


def make_bb_pedestal_layers(w: int = 128, h: int = 164) -> tuple[Image.Image, Image.Image]:
    """Generate authentic dark-iron Battle Brothers tactical pedestal back & front rim hugging the y=135 torso waist."""
    cx, cy = 64, 127
    rx, ry = 34, 9

    back = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    bd = ImageDraw.Draw(back)
    # Soft drop shadow under socket
    shadow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.ellipse((cx - rx - 6, cy - ry + 5, cx + rx + 6, cy + ry + 11), fill=(0, 0, 0, 150))
    shadow = shadow.filter(ImageFilter.GaussianBlur(3.2))
    back.alpha_composite(shadow)

    # Recessed dark interior cavity behind the torso waist
    bd.ellipse((cx - rx, cy - ry, cx + rx, cy + ry + 6), fill=(16, 13, 11, 248), outline=(56, 48, 41, 255), width=2)
    bd.ellipse((cx - rx + 3, cy - ry + 2, cx + rx - 3, cy + ry + 2), fill=(9, 7, 6, 250))

    # Front metallic curved socket lip hugging torso hem cleanly (`y=134..143`)
    front = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    fpx = front.load()
    for y in range(cy - 1, cy + ry + 10):
        for x in range(cx - rx - 3, cx + rx + 4):
            dx = (x - cx) / float(rx)
            if abs(dx) > 1.06:
                continue
            curve_y = cy + math.sqrt(max(0.0, 1.0 - min(1.0, dx * dx))) * ry
            dist = y - curve_y
            # Upper metallic bevel lip + lower iron band
            if -2.2 <= dist <= 7.8 and abs(dx) <= 1.03:
                light = 0.55 + 0.45 * math.cos((dx + 0.25) * 1.4)
                if dist < 0.8:
                    v = int(115 * light + 38)
                    r, g, b = min(255, int(v * 1.05)), min(255, int(v * 0.99)), min(255, int(v * 0.88))
                    a = 255 if dist >= -1.2 else int(255 * (dist + 2.2))
                elif dist < 5.6:
                    shade = 1.0 - (dist - 0.8) / 7.2 * 0.52
                    v = int((76 * light + 22) * shade)
                    r, g, b = int(v * 1.04), int(v * 0.98), int(v * 0.90)
                    a = 255
                else:
                    r, g, b = 22, 18, 15
                    a = int(255 * max(0.0, 1.0 - (dist - 5.6) / 2.2))
                for rv_x in (-0.72, -0.36, 0.0, 0.36, 0.72):
                    if abs(dx - rv_x) < 0.055 and 1.6 <= dist <= 4.3:
                        r, g, b = min(255, r + 48), min(255, g + 36), min(255, b + 16)
                fpx[x, y] = (max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)), max(0, min(255, a)))

    return back, front


def parse_nut_string_array(text: str, key: str) -> list[str]:
    m = re.search(rf"\b{re.escape(key)}\s*=\s*\[(.*?)\]", text, re.S)
    assert m, f"Could not find array {key}"
    return re.findall(r'"([^"]*)"', m.group(1))


def parse_nut_set(text: str, key: str) -> list[str]:
    m = re.search(rf"\b{re.escape(key)}\s*=\s*\{{(.*?)\}}", text, re.S)
    assert m, f"Could not find set {key}"
    return re.findall(r"([A-Za-z0-9_]+)\s*=\s*true", m.group(1))


def collect_labels() -> dict:
    app_txt = APPEARANCE_NUT.read_text(encoding="utf-8")
    eq_txt = EQUIP_VIS_NUT.read_text(encoding="utf-8")

    face_labels = parse_nut_string_array(app_txt, "FaceLabels")[1:]  # 1..48
    hair_labels = parse_nut_string_array(app_txt, "HairLabels")      # 0..24
    beard_labels = parse_nut_string_array(app_txt, "BeardLabels")    # 0..24
    scar_labels = parse_nut_string_array(app_txt, "ScarLabels")      # 0..12
    open_crown = parse_nut_set(app_txt, "OpenCrownHats")
    hide_hair = parse_nut_set(app_txt, "HideHairHats")
    hide_beard = parse_nut_set(app_txt, "HideBeardHats")

    body_names: dict[str, str] = {}
    hat_names: dict[str, str] = {}
    wpn_names: dict[str, str] = {}
    shd_names: dict[str, str] = {}
    up_names: dict[str, str] = {}

    # ArmorMap & ExtraArmorMap
    for txt in (eq_txt, app_txt):
        for m in re.finditer(r'\[\s*"armor\.body\.[^"]+"\s*\]\s*=\s*\[\s*"([^"]+)"\s*,\s*"([^"]+)"\s*\]', txt):
            body_names.setdefault(m.group(1), m.group(2))
        for m in re.finditer(r'\[\s*"armor\.head\.[^"]+"\s*\]\s*=\s*\[\s*"([^"]+)"\s*,\s*"([^"]+)"\s*\]', txt):
            hat_names.setdefault(m.group(1), m.group(2))
        for m in re.finditer(r'\[\s*"weapon\.[^"]+"\s*\]\s*=\s*\[\s*"([^"]+)"\s*,\s*"[^"]+"\s*,\s*"([^"]+)"\s*\]', txt):
            wpn_names.setdefault(m.group(1), m.group(2))
        for m in re.finditer(r'\[\s*"shield\.[^"]+"\s*\]\s*=\s*\[\s*"([^"]+)"\s*,\s*"([^"]+)"\s*\]', txt):
            shd_names.setdefault(m.group(1), m.group(2))

    # Shan-Hai & Beast Craft custom names
    for p in SHANHAI_NUTS:
        if not p.exists():
            continue
        t = p.read_text(encoding="utf-8")
        for m in re.finditer(r'ID\s*=\s*"(wx_(?:armor|helm|beast_armor|beast_helm|up|shd)_[a-z0-9_]+)"[^}\n]*Name\s*=\s*"([^"]+)"', t):
            cid, cname = m.group(1), m.group(2)
            if cid.startswith(("wx_armor_", "wx_beast_armor_")):
                body_names[cid] = cname
            elif cid.startswith(("wx_helm_", "wx_beast_helm_")):
                hat_names[cid] = cname
            elif cid.startswith("wx_up_"):
                up_names[cid] = cname
            elif cid.startswith("wx_shd_"):
                shd_names[cid] = cname

    # Authentic fallback names for non-ArmorMap fallback bodies & hats
    body_names.update({
        "wx_body_civ_07": "客栈伙计青布短襟褂",
        "wx_body_civ_10": "山林猎户兽皮绑腿衣",
        "wx_body_sect_07": "墨儒青莲长襟书生袍",
        "wx_body_sect_08": "峨眉月白素锦女侠袍",
        "wx_body_sect_11": "五毒墨紫银饰苗疆袍",
        "wx_body_sect_14": "六扇门玄青飞鱼公服",
        "wx_body_sect_15": "药王谷青竹悬壶长衫",
        "wx_body_sect_16": "昆仑霜白鹤氅剑仙袍",
    })
    hat_names.update({
        "wx_hat_10": "华岳青玉折棱逍遥冠",
        "wx_hat_11": "峨眉白玉流苏素锦带",
        "wx_hat_14": "唐门乌铁暗扣护额抹额",
        "wx_hat_16": "锦衣卫黑漆飞檐乌纱帽",
        "wx_hat_21": "少室乌金戒箍护额环",
        "wx_hat_22": "绿林赤红英雄双尾抹额",
    })

    # Fist & extra weapon labels
    wpn_names.update({
        "wx_wpn_fist_04": "精铁穿云护指拳套",
        "wx_wpn_fist_06": "百炼玄钢虎口拳套",
        "wx_wpn_fist_08": "金刚伏魔鎏金拳铠",
        "wx_wpn_gun_02": "神机三眼连珠火铳",
        "wx_wpn_spear_08": "镇国虎头湛金长枪",
    })
    shd_names.setdefault("wx_beast_shield", "百工·建木青鳞重藤牌")

    return {
        "faceLabels": face_labels,
        "hairLabels": hair_labels,
        "beardLabels": beard_labels,
        "scarLabels": scar_labels,
        "openCrown": open_crown,
        "hideHair": hide_hair,
        "hideBeard": hide_beard,
        "bodyNames": body_names,
        "hatNames": hat_names,
        "wpnNames": wpn_names,
        "shdNames": shd_names,
        "upNames": up_names,
    }


def classify_body_group(bid: str) -> str:
    if bid.startswith("wx_body_civ_") or bid in ("wx_char_cloth_short", "wx_char_raincape"):
        return "civ"
    if bid.startswith("wx_body_sect_") or bid.startswith("wx_char_robe_"):
        return "sect"
    if bid.startswith("wx_body_arm_") or bid in ("wx_char_armor_brigandine", "wx_char_armor_jinyi", "wx_char_armor_wudu"):
        return "arm"
    if bid.startswith("wx_body_hvy_") or bid == "wx_char_armor_shanwen":
        return "hvy"
    return "myth"


def classify_hat_group(hid: str) -> str:
    if hid.startswith(("wx_helm_", "wx_beast_helm_")):
        return "myth"
    if hid in ("wx_char_hat_helm_fengchi",) or (hid.startswith("wx_hat_") and int(hid[-2:]) >= 25):
        return "hvy"
    if hid in ("wx_char_hat_bamboo", "wx_char_hat_taoist", "wx_char_hat_topknot") or (hid.startswith("wx_hat_") and 8 <= int(hid[-2:]) <= 24):
        return "sect"
    return "civ"


CURATED_WEAPONS = [
    ("wx_wpn_sword_03", False),
    ("wx_wpn_sword_04", False),
    ("wx_wpn_sword_06", False),
    ("wx_wpn_sword_07", True),
    ("wx_wpn_sword_08", True),
    ("wx_wpn_saber_02", False),
    ("wx_wpn_saber_03", False),
    ("wx_wpn_saber_05", False),
    ("wx_wpn_saber_06", True),
    ("wx_wpn_saber_08", True),
    ("wx_wpn_spear_03", False),
    ("wx_wpn_spear_04", False),
    ("wx_wpn_spear_07", True),
    ("wx_wpn_pole_03", True),
    ("wx_wpn_pole_05", True),
    ("wx_wpn_pole_06", True),
    ("wx_wpn_pole_07", True),
    ("wx_wpn_staff_02", True),
    ("wx_wpn_staff_04", True),
    ("wx_wpn_hammer_03", False),
    ("wx_wpn_hammer_04", False),
    ("wx_wpn_hammer_07", True),
    ("wx_wpn_axe_02", False),
    ("wx_wpn_axe_05", True),
    ("wx_wpn_axe_07", True),
    ("wx_wpn_fist_04", True),
    ("wx_wpn_fist_08", True),
    ("wx_wpn_dagger_03", False),
    ("wx_wpn_whip_03", False),
    ("wx_wpn_bow_03", True),
    ("wx_wpn_xbow_03", True),
    ("wx_wpn_gun_01", True),
]

CURATED_SHIELDS = [
    "wx_shd_01", "wx_shd_02", "wx_shd_03", "wx_shd_04", "wx_shd_05",
    "wx_shd_06", "wx_shd_07", "wx_shd_08", "wx_shd_09", "wx_shd_10",
    "wx_shd_11", "wx_shd_12", "wx_beast_shield", "wx_shd_xuangui", "wx_shd_yinglong",
]


def strip_pedestal(im: Image.Image, target_size=(96, 132), fade_start_y: int = 106, cut_y: int = 116) -> Image.Image:
    """Resizes a bust to 96x132 and smoothly fades out the bottom torso waist edge for the 60fps skill theater."""
    rs = im.convert("RGBA").resize(target_size, Image.Resampling.LANCZOS)
    w, h = rs.size
    px = rs.load()
    span = max(1, cut_y - fade_start_y)
    for y in range(fade_start_y, h):
        mult = 0.0 if y >= cut_y else max(0.0, 1.0 - (y - fade_start_y) / span)
        for x in range(w):
            r, g, b, a = px[x, y]
            if a:
                px[x, y] = (r, g, b, int(round(a * mult)))
    return rs


def rebuild_skill_theater_rigs(busts: dict[str, Image.Image], open_crown: list[str]) -> dict[str, dict[str, str]]:
    """Refreshes the 8 articulated hero rigs in DB.vfxAssets.rigs from the overhauled wx_busts_0.brush."""
    open_set = set(open_crown)
    rig_specs = {
        "taoist":    ("wx_body_sect_02", "wx_head_09", "wx_hair_14", "wx_beard_21", "wx_hat_09"),
        "monk":      ("wx_body_sect_01", "wx_head_30", None,         None,          "wx_hat_21"),
        "scholar":   ("wx_body_sect_07", "wx_head_33", "wx_hair_12", None,          "wx_hat_12"),
        "beggar":    ("wx_body_sect_05", "wx_head_11", "wx_hair_08", "wx_beard_18", "wx_hat_13"),
        "assassin":  ("wx_body_sect_10", "wx_head_07", "wx_hair_02", None,          "wx_hat_08"),
        "tangmen":   ("wx_body_sect_06", "wx_head_13", "wx_hair_11", None,          "wx_hat_14"),
        "general":   ("wx_body_hvy_02",  "wx_head_15", "wx_hair_17", "wx_beard_01", "wx_hat_30"),
        "swordsman": ("wx_body_sect_03", "wx_head_01", "wx_hair_09", None,          None),
    }
    rigs: dict[str, dict[str, str]] = {}
    for rname, (body_k, head_k, hair_k, beard_k, hat_k) in rig_specs.items():
        bw, bh = busts[body_k].size
        torso_raw = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
        if hat_k and f"{hat_k}_back" in busts:
            torso_raw.alpha_composite(busts[f"{hat_k}_back"])
        torso_raw.alpha_composite(busts[body_k])
        torso_clean = strip_pedestal(torso_raw, (96, 132), fade_start_y=106, cut_y=116)

        eff_hair = hair_k
        if hair_k and hat_k and hat_k not in open_set and f"{hair_k}_tucked" in busts:
            eff_hair = f"{hair_k}_tucked"

        head_raw = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
        for part_k in (head_k, beard_k, eff_hair, f"{hat_k}_front" if hat_k else None):
            if part_k and part_k in busts:
                head_raw.alpha_composite(busts[part_k])
        head_clean = head_raw.resize((96, 132), Image.Resampling.LANCZOS)
        rigs[rname] = {
            "torso": to_webp_uri(torso_clean, quality=82),
            "head": to_webp_uri(head_clean, quality=82),
        }
    return rigs


def build_paperdoll_bundle() -> tuple[dict, dict[str, dict[str, str]]]:
    busts = load_brush_sprites(MOD_DIR / "brushes" / "wx_busts_0.brush")
    weapons = load_brush_sprites(MOD_DIR / "brushes" / "wx_weapons_0.brush")
    meta = collect_labels()

    sprites: dict[str, str] = {}

    # 1. Pedestal layers
    ped_back, ped_front = make_bb_pedestal_layers(128, 164)
    sprites["pedestal_back"] = to_webp_uri(ped_back, quality=84)
    sprites["pedestal_front"] = to_webp_uri(ped_front, quality=84)

    # 2. All 48 heads
    faces = []
    for i in range(1, 49):
        fid = f"wx_head_{i:02d}"
        assert fid in busts, f"Missing {fid}"
        sprites[fid] = to_webp_uri(busts[fid], quality=82)
        faces.append({
            "id": fid,
            "idx": i,
            "name": meta["faceLabels"][i - 1],
            "fem": i >= 33,
        })

    # 3. All 24 hairs (full + tucked x 4 authentic tones)
    tone_suffixes = ["", "_brown", "_grey", "_white"]
    hairs = []
    for i in range(1, 25):
        hid = f"wx_hair_{i:02d}"
        hairs.append({"id": hid, "idx": i, "name": meta["hairLabels"][i]})
        for base in (hid, f"{hid}_tucked"):
            for suf in tone_suffixes:
                k = base + suf
                if k in busts:
                    sprites[k] = to_webp_uri(busts[k], quality=80)

    # 4. All 24 beards (x 4 authentic tones)
    beards = []
    for i in range(1, 25):
        bid = f"wx_beard_{i:02d}"
        beards.append({"id": bid, "idx": i, "name": meta["beardLabels"][i]})
        for suf in tone_suffixes:
            k = bid + suf
            if k in busts:
                sprites[k] = to_webp_uri(busts[k], quality=80)

    # 5. All 12 scars
    scars = []
    for i in range(1, 13):
        sid = f"wx_scar_{i:02d}"
        assert sid in busts, f"Missing {sid}"
        sprites[sid] = to_webp_uri(busts[sid], quality=82)
        scars.append({"id": sid, "idx": i, "name": meta["scarLabels"][i]})

    # 6. All 46 hats (`_back` + `_front`)
    hat_ids = sorted(k[:-6] for k in busts if k.endswith("_front") and not k.endswith("_injured"))
    hats = []
    for hid in hat_ids:
        fk, bk = f"{hid}_front", f"{hid}_back"
        sprites[fk] = to_webp_uri(busts[fk], quality=80)
        has_back = bk in busts and busts[bk].getbbox() is not None
        if has_back:
            sprites[bk] = to_webp_uri(busts[bk], quality=80)
        hats.append({
            "id": hid,
            "name": meta["hatNames"].get(hid, hid),
            "grp": classify_hat_group(hid),
            "hasBack": has_back,
        })

    # 7. All 75 bodies/robes/armors
    body_ids = sorted(
        k for k in busts
        if not k.endswith("_injured")
        and (
            k.startswith("wx_body_")
            or k.startswith("wx_armor_")
            or k.startswith("wx_beast_armor_")
            or k.startswith("wx_char_robe_")
            or k.startswith("wx_char_armor_")
            or k in ("wx_char_cloth_short", "wx_char_raincape")
        )
    )
    bodies = []
    for bid in body_ids:
        sprites[bid] = to_webp_uri(busts[bid], quality=80)
        bodies.append({
            "id": bid,
            "name": meta["bodyNames"].get(bid, bid),
            "grp": classify_body_group(bid),
        })

    # 8. All 4 Baigong surcoat upgrades (`wx_up_*`)
    upgrades = []
    for uid in sorted(k for k in busts if k.startswith("wx_up_") and not k.endswith("_injured")):
        sprites[uid] = to_webp_uri(busts[uid], quality=80)
        upgrades.append({"id": uid, "name": meta["upNames"].get(uid, uid)})

    # 9. Curated weapons & shields (`128x164`, exact 1:1 overlap!)
    wpns = []
    for wid, two_h in CURATED_WEAPONS:
        ak = f"arm_{wid}"
        if ak in weapons:
            sprites[ak] = to_webp_uri(weapons[ak], quality=80)
            wpns.append({"id": ak, "name": meta["wpnNames"].get(wid, wid), "twoH": two_h})

    shds = []
    for sid in CURATED_SHIELDS:
        sk = f"shd_{sid}"
        if sk in weapons:
            sprites[sk] = to_webp_uri(weapons[sk], quality=80)
            shds.append({"id": sk, "name": meta["shdNames"].get(sid, sid)})

    # 10. Optional Before/After comparison sheet (if available in session artifacts)
    compare_uri = ""
    cand_paths = [
        Path(r"C:\Users\25647\.gemini\antigravity\brain\86c6bebb-e8ff-4e4b-a478-c60be0ad2ca2\before_vs_after_2x.jpg"),
    ]
    for cp in cand_paths:
        if cp.exists():
            cim = Image.open(cp).convert("RGB")
            if cim.width > 1280:
                nh = int(round(cim.height * 1280 / cim.width))
                cim = cim.resize((1280, nh), Image.Resampling.LANCZOS)
            compare_uri = to_webp_uri(cim, quality=80)
            break

    rigs = rebuild_skill_theater_rigs(busts, meta["openCrown"])

    return {
        "sprites": sprites,
        "faces": faces,
        "hairs": hairs,
        "beards": beards,
        "scars": scars,
        "hats": hats,
        "bodies": bodies,
        "upgrades": upgrades,
        "weapons": wpns,
        "shields": shds,
        "tones": [
            {"suf": "", "name": "乌墨黑"},
            {"suf": "_brown", "name": "风霜褐"},
            {"suf": "_grey", "name": "两鬓霜灰"},
            {"suf": "_white", "name": "鹤发银白"},
        ],
        "openCrown": meta["openCrown"],
        "hideHair": meta["hideHair"],
        "hideBeard": meta["hideBeard"],
        "compareUri": compare_uri,
        "counts": {
            "faces": len(faces),
            "hairs": len(hairs),
            "beards": len(beards),
            "scars": len(scars),
            "hats": len(hats),
            "bodies": len(bodies),
            "upgrades": len(upgrades),
            "weapons": len(wpns),
            "shields": len(shds),
            "totalSprites": len(sprites),
        },
    }, rigs


PAPERDOLL_CSS = f"""{CSS_START}
/* === 千人千面 · 实机纸娃娃换装工坊 (128x164 实时拼装台) === */
.pd-shell {{ display: grid; gap: 16px; }}
.pd-workbench {{
  background: var(--paper);
  border: 1px solid var(--line-strong);
  border-top: 3px solid var(--jade);
  border-radius: 4px;
  padding: 16px 18px;
  box-shadow: 0 2px 10px rgba(28,22,18,.07);
}}
.pd-wb-head {{
  display: flex; align-items: baseline; justify-content: space-between;
  gap: 12px; flex-wrap: wrap; padding-bottom: 10px; margin-bottom: 14px;
  border-bottom: 1px solid var(--line);
}}
.pd-wb-head h2 {{ margin: 0; font: 700 20px/1.3 var(--serif); color: var(--ebony); }}
.pd-wb-head small {{ font-size: 12.5px; color: var(--muted); }}
.pd-showcase-strip {{
  display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 14px; align-items: center;
}}
.pd-showcase-strip .lbl {{ font-size: 12px; color: var(--muted); font-weight: 600; margin-right: 4px; }}
.pd-pill-btn {{
  padding: 4px 10px; border-radius: 999px; font-size: 12px;
  border: 1px solid var(--line-strong); background: var(--paper-alt); color: var(--ink);
  transition: background .12s, border-color .12s, color .12s;
}}
.pd-pill-btn:hover {{ background: #e8e0cf; border-color: var(--bronze-dark); }}
.pd-pill-btn[aria-pressed="true"] {{
  background: var(--jade); border-color: var(--jade); color: #fff8ea; font-weight: 600;
}}
.pd-wb-grid {{
  display: grid; grid-template-columns: 310px minmax(0, 1fr); gap: 18px; align-items: start;
}}
@media (max-width: 900px) {{ .pd-wb-grid {{ grid-template-columns: 1fr; }} }}
.pd-stage-col {{ display: grid; gap: 10px; }}
.pd-stage-box {{
  position: relative; width: 100%; height: 344px;
  border-radius: 4px; border: 1px solid #634f38;
  background: radial-gradient(circle at 50% 48%, #3a2f24 0%, #1c1611 66%, #110d0a 100%);
  box-shadow: inset 0 2px 14px rgba(0,0,0,.65);
  display: grid; place-items: center; overflow: hidden;
}}
.pd-stage-box.bg-hex {{
  background:
    radial-gradient(circle at 50% 45%, rgba(164,142,102,.18), rgba(14,11,8,.86) 78%),
    repeating-linear-gradient(60deg, rgba(212,180,122,.08) 0 1px, transparent 1px 28px),
    repeating-linear-gradient(-60deg, rgba(212,180,122,.08) 0 1px, transparent 1px 28px),
    #221c16;
}}
.pd-stage-box.bg-light {{
  background: repeating-conic-gradient(#d8d2c5 0% 25%, #ebe6da 0% 50%) 50% / 16px 16px;
}}
.pd-stage-meta {{
  position: absolute; left: 8px; top: 8px; z-index: 20;
  display: flex; gap: 5px; flex-wrap: wrap; pointer-events: none;
}}
.pd-stage-tag {{
  font-size: 11px; padding: 2px 7px; border-radius: 3px;
  background: rgba(16,12,9,.82); color: #efe0c2; border: 1px solid rgba(182,141,82,.45);
}}
.pd-stage-tag.warn {{ color: #ffd694; border-color: #c89143; }}
.pd-bust-frame {{
  position: relative; width: 256px; height: 328px;
  transition: transform .15s ease;
}}
.pd-bust-frame.z1 {{ width: 128px; height: 164px; }}
.pd-bust-frame.flipped {{ transform: scaleX(-1); }}
.pd-bust-frame img {{
  position: absolute; inset: 0; width: 100%; height: 100%;
  object-fit: contain; pointer-events: none; user-select: none;
  image-rendering: auto;
}}
.pd-bust-frame.z2 img {{ image-rendering: auto; }}
.pd-stage-controls {{
  display: flex; flex-wrap: wrap; gap: 6px; justify-content: center;
}}
.pd-mini-btn {{
  padding: 4px 9px; font-size: 12px; border-radius: 3px;
  background: #271f18; color: #efe3ca; border: 1px solid #69533a;
}}
.pd-mini-btn:hover {{ background: #3b2f23; border-color: #cfa668; }}
.pd-mini-btn[aria-pressed="true"] {{ background: var(--jade); border-color: #69a395; color: #fffaf0; }}
.pd-stack-trace {{
  font: 11px/1.55 Consolas, "Courier New", monospace;
  background: #1a1510; color: #cbb99a; border: 1px solid #4d3d2c;
  border-radius: 3px; padding: 7px 9px; word-break: break-all;
}}
.pd-stack-trace b {{ color: #f0cc8b; font-weight: 600; }}
.pd-ctrl-col {{ display: grid; gap: 7px; }}
.pd-ctrl-row {{
  display: grid; grid-template-columns: 78px 30px minmax(0, 1fr) 30px;
  gap: 6px; align-items: center;
}}
.pd-ctrl-row .rlbl {{
  font-size: 12.5px; font-weight: 650; color: var(--ebony);
  display: flex; flex-direction: column; line-height: 1.2;
}}
.pd-ctrl-row .rlbl small {{ font-weight: 400; font-size: 10.5px; color: var(--muted); }}
.pd-step-btn {{
  height: 31px; border-radius: 3px; border: 1px solid var(--line-strong);
  background: var(--paper-alt); color: var(--ebony); font-size: 12px; font-weight: 700;
}}
.pd-step-btn:hover {{ background: #e6ddcb; border-color: var(--bronze-dark); }}
.pd-ctrl-row select {{
  width: 100%; height: 31px; padding: 0 8px; font-size: 13px;
  border: 1px solid var(--line-strong); border-radius: 3px;
  background: #fffdf8; color: var(--ink);
}}
.pd-wb-actions {{
  display: flex; flex-wrap: wrap; gap: 8px; margin-top: 8px; padding-top: 10px;
  border-top: 1px dashed var(--line); align-items: center; justify-content: space-between;
}}
.pd-primary-btn {{
  padding: 6px 14px; border-radius: 3px; font-size: 13px; font-weight: 650;
  background: var(--jade); color: #fff9eb; border: 1px solid #163b34;
}}
.pd-primary-btn:hover {{ background: #265f54; }}
.pd-tone-chips {{ display: flex; gap: 5px; flex-wrap: wrap; align-items: center; }}
.pd-tone-dot {{
  display: inline-flex; align-items: center; gap: 5px; padding: 3px 9px;
  border-radius: 999px; font-size: 12px; border: 1px solid var(--line-strong);
  background: var(--paper-alt); color: var(--ink);
}}
.pd-tone-dot i {{
  width: 11px; height: 11px; border-radius: 50%; display: inline-block;
  border: 1px solid rgba(0,0,0,.35);
}}
.pd-tone-dot[aria-pressed="true"] {{
  background: var(--ebony); color: #fff6e2; border-color: var(--bronze);
}}

/* === 12人江湖战团群像阅兵场 === */
.pd-squad-box {{
  background: var(--paper); border: 1px solid var(--line-strong);
  border-top: 3px solid var(--bronze-dark); border-radius: 4px; padding: 14px 16px;
}}
.pd-squad-bar {{
  display: flex; align-items: center; justify-content: space-between;
  gap: 10px; flex-wrap: wrap; margin-bottom: 12px;
  padding-bottom: 10px; border-bottom: 1px solid var(--line);
}}
.pd-squad-presets {{ display: flex; gap: 6px; flex-wrap: wrap; align-items: center; }}
.pd-squad-grid {{
  display: grid; grid-template-columns: repeat(auto-fill, minmax(min(100%, 196px), 1fr));
  gap: 11px;
}}
.pd-card {{
  background: #1b1511; color: #efe3cb; border: 1px solid #5a4632;
  border-top: 2px solid #9f7c4a; border-radius: 4px; padding: 8px 9px;
  display: flex; flex-direction: column; gap: 6px;
  transition: transform .12s, border-color .12s, box-shadow .12s;
}}
.pd-card:hover {{ border-color: #d6ae6c; box-shadow: 0 4px 12px rgba(0,0,0,.32); }}
.pd-card.active {{ border-color: #e2be79; box-shadow: 0 0 0 2px rgba(226,190,121,.45); }}
.pd-card-head {{ display: flex; justify-content: space-between; align-items: center; gap: 6px; }}
.pd-card-who strong {{ display: block; font: 700 14px/1.2 var(--serif); color: #fbf0d8; }}
.pd-card-who span {{ display: block; font-size: 11px; color: #bda88a; }}
.pd-card-stage {{
  position: relative; width: 100%; height: 184px; cursor: pointer;
  background: radial-gradient(circle at 50% 48%, #352a20 0%, #14100c 84%);
  border: 1px solid #493827; border-radius: 3px; display: grid; place-items: center; overflow: hidden;
}}
.pd-card-bust {{ position: relative; width: 140px; height: 179px; }}
.pd-card-bust img {{
  position: absolute; inset: 0; width: 100%; height: 100%;
  object-fit: contain; pointer-events: none;
}}
.pd-card-chips {{ display: flex; flex-wrap: wrap; gap: 3px; margin-top: auto; }}
.pd-card-chip {{
  font-size: 10.5px; line-height: 1.3; padding: 1px 5px; border-radius: 2px;
  background: #271f17; border: 1px solid #4d3d2b; color: #d1c0a3;
  max-width: 100%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}}
.pd-card-foot {{ display: flex; gap: 5px; margin-top: 2px; }}
.pd-card-foot button {{
  flex: 1; padding: 3px 6px; font-size: 11.5px; border-radius: 2px;
  background: #2c2219; border: 1px solid #6e573e; color: #f2e4c9;
}}
.pd-card-foot button:hover {{ background: #3f3124; border-color: #d7af6d; }}
.pd-card-foot button.edit-btn {{ background: #1e4d44; border-color: #538f82; }}
.pd-card-foot button.edit-btn:hover {{ background: #29665a; }}

/* === 修复前后像素对比折叠抽屉 === */
.pd-compare-details {{
  background: var(--paper); border: 1px solid var(--line-strong);
  border-left: 4px solid var(--cinnabar); border-radius: 4px; padding: 11px 15px;
}}
.pd-compare-details summary {{
  cursor: pointer; font: 700 15.5px/1.35 var(--serif); color: var(--ebony);
  display: flex; align-items: center; justify-content: space-between; gap: 10px;
}}
.pd-compare-details summary small {{ font: 400 12px var(--sans); color: var(--muted); }}
.pd-compare-body {{ margin-top: 11px; display: grid; gap: 10px; }}
.pd-compare-body img {{
  width: 100%; max-width: 1120px; border-radius: 4px;
  border: 1px solid #594631; box-shadow: 0 3px 12px rgba(0,0,0,.22);
}}
.pd-compare-notes {{
  display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 8px;
  font-size: 12.5px; color: #3a403d;
}}
.pd-compare-note {{
  background: var(--paper-alt); border: 1px solid var(--line); border-radius: 3px; padding: 8px 10px;
}}
.pd-compare-note strong {{ display: block; color: var(--jade); margin-bottom: 2px; }}
.hero-pd-cta {{
  display: inline-flex; align-items: center; gap: 6px; margin-top: 10px;
  padding: 6px 13px; border-radius: 3px; font: 650 13px/1.3 var(--serif);
  background: linear-gradient(180deg, #b68d52, #8c6630); color: #fffaf0;
  border: 1px solid #e0be85; box-shadow: 0 2px 6px rgba(0,0,0,.28);
}}
.hero-pd-cta:hover {{ filter: brightness(1.08); }}
{CSS_END}"""


PAPERDOLL_JS = f"""{JS_START}
  // === 千人千面 · 纸娃娃换装试衣工坊 (100% 离线真 brush 分层) ===
  const PD = DB.paperdollAssets || null;
  const PD_OPEN_CROWN = new Set((PD && PD.openCrown) || []);
  const PD_HIDE_HAIR = new Set((PD && PD.hideHair) || []);
  const PD_HIDE_BEARD = new Set((PD && PD.hideBeard) || []);
  const PD_SURNAMES = ['沈','顾','萧','林','陆','陈','赵','秦','韩','谢','苏','周','叶','魏','程','石','岳','裴','燕','唐','穆','姜','雷','霍'];
  const PD_GIVEN_M = ['青锋','长风','惊鸿','破岳','承影','听雪','归尘','云帆','铁衣','无咎','玄策','镇岳','断水','凌云','少卿','沧海'];
  const PD_GIVEN_F = ['寒梅','轻鸿','霜竹','昭雪','凌薇','红袖','映月','晚舟','秋水','青萝','凝霜','寒烟','佩兰','素心','明珠','芷青'];
  const PD_BGS = {{
    mixed: ['退隐老剑客','走镖趟子手','名门少侠','行脚武僧','江湖游侠','六扇捕快','西域刀客','药谷医者','绿林好汉','塞外猎手','锦衣暗探','镇边老卒'],
    heroine: ['峨眉女侠','镖局少主','塞外女骑','客栈掌柜','药谷医女','南疆蛊女','六扇女捕','书香才女','黑道女魁','刀马旦','圣女传人','江湖女侠'],
    sect: ['太和道长','少室武僧','清风剑客','华岳弟子','丐帮护法','唐门机括手','峨眉女侠','昆仑剑仙','药王传人','锦衣飞鱼','五毒使者','墨儒书生'],
    army: ['披甲悍将','镇边校尉','神机营炮手','戚家军刀牌手','禁军重骑','铁浮屠甲士','关外百夫长','步人重甲兵','山海镇魔将','九边总旗','金龙帅卫','古墓镇守'],
    civ: ['庄稼把式','码头脚夫','老渔翁','铁匠学徒','游方郎中','客栈伙计','寒窗书生','走街货郎','山林猎户','杀猪屠户','茶肆跑堂','江湖卖艺人'],
    outlaw: ['黑风寨大当家','夜行刺客','绿林快刀','塞外马贼','南疆毒师','血煞教徒','水寨恶霸','鬼市飞刀','黑水狂徒','丐帮悍乞','江湖江洋盗','关外独行匪']
  }};

  // 6 个精选验货预设（含截图高危对照样本）
  const PD_CLASSIC_PRESETS = [
    {{
      id: 'shot_scar', label: '截图对照 · 刀疤红甲笠子盔',
      name: '韩铁衣', bg: '九边老卒',
      faceIdx: 24, hairIdx: 17, toneIdx: 0, beardIdx: 0, scarIdx: 3,
      hatId: 'wx_hat_25', bodyId: 'wx_body_arm_07', upId: '', wpnId: 'arm_wx_wpn_saber_03', shdId: 'shd_wx_shd_05'
    }},
    {{
      id: 'shot_elder', label: '截图对照 · 白须老镖头',
      name: '石镇岳', bg: '威远老镖头',
      faceIdx: 4, hairIdx: 18, toneIdx: 3, beardIdx: 17, scarIdx: 0,
      hatId: 'wx_hat_26', bodyId: 'wx_body_arm_07', upId: '', wpnId: 'arm_wx_wpn_axe_02', shdId: 'shd_wx_shd_04'
    }},
    {{
      id: 'shot_general', label: '截图对照 · 鱼鳞铠双翼冠',
      name: '岳破岳', bg: '披甲悍将',
      faceIdx: 15, hairIdx: 1, toneIdx: 1, beardIdx: 1, scarIdx: 0,
      hatId: 'wx_hat_30', bodyId: 'wx_body_hvy_01', upId: '', wpnId: 'arm_wx_wpn_pole_07', shdId: ''
    }},
    {{
      id: 'heroine_emei', label: '女侠验货 · 披肩长发青衫',
      name: '顾寒梅', bg: '峨眉女侠',
      faceIdx: 33, hairIdx: 10, toneIdx: 0, beardIdx: 0, scarIdx: 0,
      hatId: 'wx_hat_12', bodyId: 'wx_body_sect_08', upId: '', wpnId: 'arm_wx_wpn_sword_04', shdId: ''
    }},
    {{
      id: 'bamboo_knight', label: '江湖游侠 · 青竹斗笠断水剑',
      name: '萧惊鸿', bg: '退隐剑客',
      faceIdx: 1, hairIdx: 12, toneIdx: 0, beardIdx: 13, scarIdx: 2,
      hatId: 'wx_char_hat_bamboo', bodyId: 'wx_char_robe_swordsman', upId: 'wx_up_chiling', wpnId: 'arm_wx_wpn_sword_06', shdId: ''
    }},
    {{
      id: 'shanhai_titan', label: '山海神装 · 玄龟重铠饕餮胄',
      name: '秦无咎', bg: '山海斩妖大将',
      faceIdx: 30, hairIdx: 4, toneIdx: 2, beardIdx: 8, scarIdx: 1,
      hatId: 'wx_helm_taotie', bodyId: 'wx_armor_xuangui', upId: 'wx_up_shagu', wpnId: 'arm_wx_wpn_hammer_07', shdId: ''
    }}
  ];

  const pdState = {{
    preset: 'mixed',
    squad: [],
    activeIdx: -1,
    zoom: 2,
    bg: 'dark',
    flipped: false,
    showPedestal: true,
    showWeapons: true,
    previewBare: false,
    squadHelmets: true,
    squadWeapons: true,
    cur: Object.assign({{}}, PD_CLASSIC_PRESETS[0])
  }};

  function pdShuffle(arr) {{
    const a = arr.slice();
    for (let i = a.length - 1; i > 0; i--) {{
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }}
    return a;
  }}

  function pdIsTwoHandWeapon(wpnId) {{
    if (!PD || !wpnId) return false;
    const w = PD.weapons.find(x => x.id === wpnId);
    return !!(w && w.twoH);
  }}

  function pdResolveLayers(ch, opts) {{
    if (!PD) return {{ imgs: [], trace: [], hairMode: '无' }};
    const S = PD.sprites;
    const bare = !!(opts && opts.bare);
    const showPed = opts && opts.pedestal !== undefined ? opts.pedestal : true;
    const showWpn = opts && opts.weapons !== undefined ? opts.weapons : true;

    const fi = Math.max(1, Math.min(48, Number(ch.faceIdx) || 1));
    const isFem = fi >= 33;
    const hi = Math.max(0, Math.min(24, Number(ch.hairIdx) || 0));
    const ti = Math.max(0, Math.min(3, Number(ch.toneIdx) || 0));
    const suf = (PD.tones[ti] && PD.tones[ti].suf) || '';
    const bi = isFem ? 0 : Math.max(0, Math.min(24, Number(ch.beardIdx) || 0));
    const si = Math.max(0, Math.min(12, Number(ch.scarIdx) || 0));
    const hatId = (!bare && ch.hatId) ? ch.hatId : '';
    const bodyId = ch.bodyId || 'wx_char_cloth_short';
    const upId = ch.upId || '';
    const wpnId = showWpn ? (ch.wpnId || '') : '';
    const shdId = (showWpn && ch.shdId && !pdIsTwoHandWeapon(wpnId)) ? ch.shdId : '';

    const imgs = [];
    const trace = [];
    const pushSpr = (k, label) => {{
      if (k && S[k]) {{
        imgs.push({{ key: k, src: S[k] }});
        trace.push(label ? `${{label}}:${{k}}` : k);
      }}
    }};

    // Exact runtime Battle Brothers z-order from `wx_appearance_system.nut`
    if (showPed) pushSpr('pedestal_back', '');
    pushSpr(bodyId, '衣');
    if (showPed) pushSpr('pedestal_front', '');
    if (upId) pushSpr(upId, '挂');
    if (hatId && S[hatId + '_back']) pushSpr(hatId + '_back', '冠后');

    const headKey = 'wx_head_' + String(fi).padStart(2, '0');
    pushSpr(headKey, '面');

    if (si > 0) pushSpr('wx_scar_' + String(si).padStart(2, '0'), '疤');

    const hideBeard = isFem || bi <= 0 || (hatId && PD_HIDE_BEARD.has(hatId));
    if (!hideBeard) {{
      const bBase = 'wx_beard_' + String(bi).padStart(2, '0');
      pushSpr(S[bBase + suf] ? (bBase + suf) : bBase, '须');
    }}

    let hairMode = hi <= 0 ? '落发光头' : '完整披发';
    const hideHair = hi <= 0 || (hatId && PD_HIDE_HAIR.has(hatId));
    if (hatId && PD_HIDE_HAIR.has(hatId) && hi > 0) {{
      hairMode = '全盔隐发';
    }}
    if (!hideHair) {{
      const useTucked = !!hatId && !PD_OPEN_CROWN.has(hatId);
      hairMode = useTucked ? '帽下收鬓 (tucked)' : (hatId ? '露顶穿冠 (full)' : '完整披发 (full)');
      const hBase = 'wx_hair_' + String(hi).padStart(2, '0') + (useTucked ? '_tucked' : '');
      pushSpr(S[hBase + suf] ? (hBase + suf) : hBase, '发');
    }}

    if (hatId) pushSpr(hatId + '_front', '冠前');
    if (shdId) pushSpr(shdId, '盾');
    if (wpnId) pushSpr(wpnId, '兵');

    return {{ imgs, trace, hairMode, isFem }};
  }}

  function pdRollOne(preset, idx) {{
    if (!PD) return Object.assign({{}}, PD_CLASSIC_PRESETS[0]);
    const p = preset || pdState.preset || 'mixed';
    const maleFaces = PD.faces.filter(f => !f.fem);
    const femFaces = PD.faces.filter(f => f.fem);
    let facePool = maleFaces;
    let bodyPool = PD.bodies;
    let hatPool = PD.hats;

    if (p === 'mixed') {{
      facePool = (idx % 4 === 3) ? femFaces : maleFaces;
      hatPool = PD.hats.filter(h => !PD_HIDE_HAIR.has(h.id));
    }} else if (p === 'heroine') {{
      facePool = femFaces;
      bodyPool = PD.bodies.filter(b => b.grp === 'sect' || b.grp === 'civ' || /wx_body_arm_0[159]|wx_body_arm_10|wx_armor_(qiongqi|feilian|baize|bifang)/.test(b.id));
      hatPool = PD.hats.filter(h => /^wx_hat_(07|1[012456])$|^wx_char_hat_(bamboo|topknot)$|^wx_helm_(bashe|bingyi)$/.test(h.id));
    }} else if (p === 'sect') {{
      facePool = (idx % 3 === 2) ? femFaces : maleFaces;
      bodyPool = PD.bodies.filter(b => b.grp === 'sect');
      hatPool = PD.hats.filter(h => h.grp === 'sect');
    }} else if (p === 'army') {{
      bodyPool = PD.bodies.filter(b => b.grp === 'hvy' || b.grp === 'myth' || b.grp === 'arm');
      hatPool = PD.hats.filter(h => h.grp === 'hvy' || h.grp === 'myth');
    }} else if (p === 'civ') {{
      facePool = (idx % 5 === 4) ? femFaces : maleFaces;
      bodyPool = PD.bodies.filter(b => b.grp === 'civ');
      hatPool = PD.hats.filter(h => h.grp === 'civ' || h.id === 'wx_char_hat_bamboo');
    }} else if (p === 'outlaw') {{
      facePool = (idx % 5 === 4) ? femFaces : maleFaces;
      bodyPool = PD.bodies.filter(b => b.grp === 'arm' || /wx_body_sect_(05|06|09|10|11|12)|wx_body_hvy_09|wx_char_armor_wudu|wx_char_robe_beggar/.test(b.id));
      hatPool = PD.hats.filter(h => /^wx_hat_(07|08|13|14|15|17|18|19|21|22|24)$/.test(h.id));
    }}

    const face = facePool[Math.floor(Math.random() * facePool.length)] || PD.faces[0];
    const isFem = face.fem;
    const body = bodyPool[Math.floor(Math.random() * bodyPool.length)] || PD.bodies[0];
    const wearHat = pdState.squadHelmets && (p === 'army' ? true : Math.random() < 0.78);
    const hat = wearHat ? (hatPool[Math.floor(Math.random() * hatPool.length)] || null) : null;
    const femSafeHairs = [1, 2, 9, 10, 11, 12, 14, 17, 20, 22, 23];
    const hairIdx = isFem
      ? femSafeHairs[Math.floor(Math.random() * femSafeHairs.length)]
      : (Math.random() < 0.08 ? 0 : 1 + Math.floor(Math.random() * 24));
    const elderFaces = new Set([4, 8, 9, 40]);
    const toneIdx = elderFaces.has(face.idx)
      ? (Math.random() < 0.5 ? 2 : 3)
      : (Math.random() < 0.68 ? 0 : (Math.random() < 0.6 ? 1 : (Math.random() < 0.6 ? 2 : 3)));
    const beardIdx = isFem ? 0 : (Math.random() < 0.62 ? 1 + Math.floor(Math.random() * 24) : 0);
    const scarIdx = Math.random() < (p === 'outlaw' || p === 'army' ? 0.36 : 0.20) ? 1 + Math.floor(Math.random() * 12) : 0;
    const upId = (p === 'army' || Math.random() < 0.16) && PD.upgrades.length
      ? PD.upgrades[Math.floor(Math.random() * PD.upgrades.length)].id
      : '';
    const wpn = PD.weapons[Math.floor(Math.random() * PD.weapons.length)];
    const shd = (wpn && !wpn.twoH && Math.random() < (p === 'army' ? 0.72 : 0.42))
      ? PD.shields[Math.floor(Math.random() * PD.shields.length)]
      : null;

    const sur = PD_SURNAMES[Math.floor(Math.random() * PD_SURNAMES.length)];
    const givList = isFem ? PD_GIVEN_F : PD_GIVEN_M;
    const bgList = isFem && p !== 'heroine' ? PD_BGS.heroine : (PD_BGS[p] || PD_BGS.mixed);
    return {{
      name: sur + givList[Math.floor(Math.random() * givList.length)],
      bg: bgList[idx % bgList.length],
      faceIdx: face.idx,
      hairIdx,
      toneIdx,
      beardIdx,
      scarIdx,
      hatId: hat ? hat.id : '',
      bodyId: body.id,
      upId,
      wpnId: wpn ? wpn.id : '',
      shdId: shd ? shd.id : ''
    }};
  }}

  function pdGenerateSquad(preset) {{
    if (!PD) return;
    pdState.preset = preset || pdState.preset || 'mixed';
    const seenFaces = new Set();
    const seenBodies = new Set();
    const list = [];
    for (let i = 0; i < 12; i++) {{
      let ch = pdRollOne(pdState.preset, i);
      for (let t = 0; t < 8; t++) {{
        if (!seenFaces.has(ch.faceIdx) && !seenBodies.has(ch.bodyId)) break;
        ch = pdRollOne(pdState.preset, i);
      }}
      seenFaces.add(ch.faceIdx);
      seenBodies.add(ch.bodyId);
      list.push(ch);
    }}
    pdState.squad = list;
  }}

  function pdStepField(field, dir) {{
    if (!PD) return;
    const c = pdState.cur;
    if (field === 'faceIdx') {{
      c.faceIdx = ((c.faceIdx - 1 + dir + 48) % 48) + 1;
      if (c.faceIdx >= 33) c.beardIdx = 0;
    }} else if (field === 'hairIdx') {{
      c.hairIdx = (c.hairIdx + dir + 25) % 25;
    }} else if (field === 'toneIdx') {{
      c.toneIdx = (c.toneIdx + dir + 4) % 4;
    }} else if (field === 'beardIdx') {{
      c.beardIdx = (c.beardIdx + dir + 25) % 25;
    }} else if (field === 'scarIdx') {{
      c.scarIdx = (c.scarIdx + dir + 13) % 13;
    }} else if (field === 'hatId') {{
      const ids = [''].concat(PD.hats.map(x => x.id));
      const idx = Math.max(0, ids.indexOf(c.hatId || ''));
      c.hatId = ids[(idx + dir + ids.length) % ids.length];
    }} else if (field === 'bodyId') {{
      const ids = PD.bodies.map(x => x.id);
      const idx = Math.max(0, ids.indexOf(c.bodyId));
      c.bodyId = ids[(idx + dir + ids.length) % ids.length];
    }} else if (field === 'upId') {{
      const ids = [''].concat(PD.upgrades.map(x => x.id));
      const idx = Math.max(0, ids.indexOf(c.upId || ''));
      c.upId = ids[(idx + dir + ids.length) % ids.length];
    }} else if (field === 'wpnId') {{
      const ids = [''].concat(PD.weapons.map(x => x.id));
      const idx = Math.max(0, ids.indexOf(c.wpnId || ''));
      c.wpnId = ids[(idx + dir + ids.length) % ids.length];
      if (pdIsTwoHandWeapon(c.wpnId)) c.shdId = '';
    }} else if (field === 'shdId') {{
      const ids = [''].concat(PD.shields.map(x => x.id));
      const idx = Math.max(0, ids.indexOf(c.shdId || ''));
      c.shdId = ids[(idx + dir + ids.length) % ids.length];
    }}
    if (pdState.activeIdx >= 0 && pdState.squad[pdState.activeIdx]) {{
      pdState.squad[pdState.activeIdx] = Object.assign({{}}, c);
    }}
  }}

  function renderPaperdollStudioHtml() {{
    if (!PD) return '<div class="empty-box">纸娃娃贴图包尚未注入。</div>';
    if (!pdState.squad.length) pdGenerateSquad(pdState.preset);
    const c = pdState.cur;
    const res = pdResolveLayers(c, {{
      bare: pdState.previewBare,
      pedestal: pdState.showPedestal,
      weapons: pdState.showWeapons
    }});
    const cnt = PD.counts;
    const toneColors = ['#18171a', '#5f432b', '#878b91', '#dedcd4'];

    const faceOpts = PD.faces.map(f =>
      `<option value="${{f.idx}}" ${{c.faceIdx === f.idx ? 'selected' : ''}}>${{String(f.idx).padStart(2,'0')}} · ${{f.fem ? '【女】' : '【男】'}}${{esc(f.name)}}</option>`
    ).join('');
    const hairOpts = `<option value="0" ${{c.hairIdx === 0 ? 'selected' : ''}}>00 · 落发光头</option>` +
      PD.hairs.map(h => `<option value="${{h.idx}}" ${{c.hairIdx === h.idx ? 'selected' : ''}}>${{String(h.idx).padStart(2,'0')}} · ${{esc(h.name)}}</option>`).join('');
    const beardOpts = `<option value="0" ${{c.beardIdx === 0 ? 'selected' : ''}}>00 · ${{c.faceIdx >= 33 ? '女侠净面' : '净面无须'}}</option>` +
      PD.beards.map(b => `<option value="${{b.idx}}" ${{c.beardIdx === b.idx ? 'selected' : ''}}>${{String(b.idx).padStart(2,'0')}} · ${{esc(b.name)}}</option>`).join('');
    const scarOpts = `<option value="0" ${{c.scarIdx === 0 ? 'selected' : ''}}>00 · 白璧无瑕</option>` +
      PD.scars.map(s => `<option value="${{s.idx}}" ${{c.scarIdx === s.idx ? 'selected' : ''}}>${{String(s.idx).padStart(2,'0')}} · ${{esc(s.name)}}</option>`).join('');

    const grpLbl = {{ civ: '市井布衣', sect: '宗门冠袍', arm: '轻中甲胄', hvy: '重甲铁铠', myth: '百工/山海神装' }};
    const hatOpts = `<option value="" ${{(c.hatId || '') === '' ? 'selected' : ''}}>免冠露发（不戴帽）</option>` +
      ['civ','sect','hvy','myth'].map(g => {{
        const list = PD.hats.filter(h => h.grp === g);
        if (!list.length) return '';
        return `<optgroup label="${{grpLbl[g]}} (${{list.length}})">` +
          list.map(h => `<option value="${{esc(h.id)}}" ${{c.hatId === h.id ? 'selected' : ''}}>${{esc(h.name)}} [${{h.id}}]</option>`).join('') +
          `</optgroup>`;
      }}).join('');

    const bodyOpts = ['civ','sect','arm','hvy','myth'].map(g => {{
      const list = PD.bodies.filter(b => b.grp === g);
      if (!list.length) return '';
      return `<optgroup label="${{grpLbl[g]}} (${{list.length}})">` +
        list.map(b => `<option value="${{esc(b.id)}}" ${{c.bodyId === b.id ? 'selected' : ''}}>${{esc(b.name)}} [${{b.id}}]</option>`).join('') +
        `</optgroup>`;
    }}).join('');

    const upOpts = `<option value="" ${{(c.upId || '') === '' ? 'selected' : ''}}>无披挂镶件</option>` +
      PD.upgrades.map(u => `<option value="${{esc(u.id)}}" ${{c.upId === u.id ? 'selected' : ''}}>${{esc(u.name)}}</option>`).join('');
    const wpnOpts = `<option value="" ${{(c.wpnId || '') === '' ? 'selected' : ''}}>空手（不持兵）</option>` +
      PD.weapons.map(w => `<option value="${{esc(w.id)}}" ${{c.wpnId === w.id ? 'selected' : ''}}>${{esc(w.name)}}${{w.twoH ? '（双手）' : ''}}</option>`).join('');
    const twoH = pdIsTwoHandWeapon(c.wpnId);
    const shdOpts = `<option value="" ${{(c.shdId || '') === '' ? 'selected' : ''}}>${{twoH ? '双手武器占用副手' : '空副手（孤锋诀）'}}</option>` +
      PD.shields.map(s => `<option value="${{esc(s.id)}}" ${{c.shdId === s.id ? 'selected' : ''}}>${{esc(s.name)}}</option>`).join('');

    const ctrlRow = (field, label, sub, optsHtml) => `
      <div class="pd-ctrl-row">
        <span class="rlbl">${{label}}<small>${{sub}}</small></span>
        <button type="button" class="pd-step-btn" data-pd-step="${{field}}:-1" title="上一款">◀</button>
        <select data-pd-sel="${{field}}" aria-label="${{label}}">${{optsHtml}}</select>
        <button type="button" class="pd-step-btn" data-pd-step="${{field}}:1" title="下一款">▶</button>
      </div>`;

    const bodyNameById = new Map(PD.bodies.map(b => [b.id, b.name]));
    const hatNameById = new Map(PD.hats.map(h => [h.id, h.name]));
    const faceNameByIdx = new Map(PD.faces.map(f => [f.idx, f.name]));

    const squadPresets = [
      ['mixed', '综合战团'], ['heroine', '江湖女侠 (12位)'], ['sect', '名门宗派'],
      ['army', '重甲军阵'], ['civ', '市井行当'], ['outlaw', '绿林奇门']
    ];

    const squadCardsHtml = pdState.squad.map((m, idx) => {{
      const mr = pdResolveLayers(m, {{ bare: !pdState.squadHelmets, pedestal: true, weapons: pdState.squadWeapons }});
      return `
        <article class="pd-card ${{pdState.activeIdx === idx ? 'active' : ''}}">
          <div class="pd-card-head">
            <div class="pd-card-who">
              <strong>${{esc(m.name)}}</strong>
              <span>${{esc(m.bg)}} · ${{m.faceIdx >= 33 ? '女侠' : '男侠'}}</span>
            </div>
            <span class="badge ${{m.hatId && pdState.squadHelmets ? 'b-gold' : 'b-sect'}}">${{esc(mr.hairMode.split(' ')[0])}}</span>
          </div>
          <div class="pd-card-stage" data-pd-load="${{idx}}" title="点击载入上方实机精调台">
            <div class="pd-card-bust">
              ${{mr.imgs.map(im => `<img src="${{im.src}}" alt="">`).join('')}}
            </div>
          </div>
          <div class="pd-card-chips">
            <span class="pd-card-chip">面：${{esc((faceNameByIdx.get(m.faceIdx) || '').replace(/面$/, ''))}}</span>
            <span class="pd-card-chip">衣：${{esc(bodyNameById.get(m.bodyId) || m.bodyId)}}</span>
            ${{m.hatId && pdState.squadHelmets ? `<span class="pd-card-chip">冠：${{esc(hatNameById.get(m.hatId) || m.hatId)}}</span>` : ''}}
          </div>
          <div class="pd-card-foot">
            <button type="button" class="edit-btn" data-pd-load="${{idx}}">精调此人</button>
            <button type="button" data-pd-reroll-one="${{idx}}">重随</button>
          </div>
        </article>`;
    }}).join('');

    const compareHtml = PD.compareUri ? `
      <details class="pd-compare-details">
        <summary>
          <span>🔍 查看本次纸娃娃重制前后像素对照图（原版截图 6 位高危样本实测）</span>
          <small>点击展开 / 收起</small>
        </summary>
        <div class="pd-compare-body">
          <img src="${{PD.compareUri}}" alt="纸娃娃重制前后对比">
          <div class="pd-compare-notes">
            <div class="pd-compare-note"><strong>1. 头身比与领口中轴锁合</strong>将头颅比例从过度放大的 1.21× 回正至 1.12×，身躯按胸肩领口精校对中，并为全部 48 张面孔补齐自适应肤色阴暗过渡脖颈。</div>
            <div class="pd-compare-note"><strong>2. 48 面容统一古画质感</strong>压平过曝粉白面与灰绿偏色面，补齐暖墨细描边与明暗立面，告别贴纸割裂感。</div>
            <div class="pd-compare-note"><strong>3. 24 发型 × 4 色实机重绘</strong>清除耳旁白点杂边、重构收鬓弧线，全部 4 种发色/须色均直读实机 brush 贴图，不再偏糊。</div>
            <div class="pd-compare-note"><strong>4. 笠子盔/斗笠贴合与漏袖修补</strong>重绘红缨笠子盔去除额前黑块、下坐高浮斗笠与道冠，为 14 套重铠/宗门甲补齐暗影内袖。</div>
          </div>
        </div>
      </details>` : '';

    return `
      <div class="pd-shell" id="wx-pd-studio">
        ${{compareHtml}}
        <section class="pd-workbench">
          <div class="pd-wb-head">
            <h2>🎭 千人千面 · 128×164 实机纸娃娃精调换装台</h2>
            <small>直读游戏内 <code>wx_busts_0.brush</code> 与 <code>wx_weapons_0.brush</code> 全量 ${{cnt.totalSprites}} 张重制图层（${{cnt.faces}}面 × 25发 × 4真发色 × 25须 × 13疤 × ${{cnt.hats + 1}}冠 × ${{cnt.bodies}}甲）</small>
          </div>

          <div class="pd-showcase-strip">
            <span class="lbl">一键验货预设：</span>
            ${{PD_CLASSIC_PRESETS.map(pr => `<button type="button" class="pd-pill-btn" data-pd-classic="${{esc(pr.id)}}">${{esc(pr.label)}}</button>`).join('')}}
          </div>

          <div class="pd-wb-grid">
            <div class="pd-stage-col">
              <div class="pd-stage-box ${{pdState.bg === 'hex' ? 'bg-hex' : pdState.bg === 'light' ? 'bg-light' : ''}}">
                <div class="pd-stage-meta">
                  <span class="pd-stage-tag">${{esc(c.name || '自定义侠客')}} · ${{res.isFem ? '女侠' : '男侠'}}</span>
                  <span class="pd-stage-tag ${{pdState.previewBare ? 'warn' : ''}}">${{pdState.previewBare ? '裸头验发中' : esc(res.hairMode)}}</span>
                </div>
                <div class="pd-bust-frame ${{pdState.zoom === 1 ? 'z1' : 'z2'}} ${{pdState.flipped ? 'flipped' : ''}}">
                  ${{res.imgs.map(im => `<img src="${{im.src}}" alt="">`).join('')}}
                </div>
              </div>

              <div class="pd-stage-controls">
                <button type="button" class="pd-mini-btn" data-pd-act="zoom" aria-pressed="${{pdState.zoom === 2}}">${{pdState.zoom === 2 ? '2× 高清放大' : '1× 实机原大'}}</button>
                <button type="button" class="pd-mini-btn" data-pd-act="bg">底色：${{pdState.bg === 'dark' ? '墨黑' : pdState.bg === 'hex' ? '六角战棋' : '透明格'}}</button>
                <button type="button" class="pd-mini-btn" data-pd-act="flip" aria-pressed="${{pdState.flipped}}">左右翻转</button>
                <button type="button" class="pd-mini-btn" data-pd-act="ped" aria-pressed="${{pdState.showPedestal}}">铁底座</button>
                <button type="button" class="pd-mini-btn" data-pd-act="bare" aria-pressed="${{pdState.previewBare}}">免冠看发型</button>
                <button type="button" class="pd-mini-btn" data-pd-act="wpn" aria-pressed="${{pdState.showWeapons}}">手持兵盾</button>
              </div>

              <div class="pd-stack-trace">
                <b>实机渲染图层栈（低 → 高）：</b><br>${{esc(res.trace.join(' → '))}}
              </div>
            </div>

            <div class="pd-ctrl-col">
              ${{ctrlRow('faceIdx', '面容相貌', cnt.faces + ' 款', faceOpts)}}
              ${{ctrlRow('hairIdx', '江湖发式', '25 态', hairOpts)}}
              <div class="pd-ctrl-row">
                <span class="rlbl">发须色泽<small>4 真色贴图</small></span>
                <button type="button" class="pd-step-btn" data-pd-step="toneIdx:-1">◀</button>
                <div class="pd-tone-chips">
                  ${{PD.tones.map((t, ti) => `<button type="button" class="pd-tone-dot" data-pd-tone="${{ti}}" aria-pressed="${{c.toneIdx === ti}}"><i style="background:${{toneColors[ti]}}"></i>${{esc(t.name)}}</button>`).join('')}}
                </div>
                <button type="button" class="pd-step-btn" data-pd-step="toneIdx:1">▶</button>
              </div>
              ${{ctrlRow('beardIdx', '颌下胡须', '25 态', beardOpts)}}
              ${{ctrlRow('scarIdx', '面疤眼罩', '13 态', scarOpts)}}
              ${{ctrlRow('hatId', '冠帽兜鍪', (cnt.hats + 1) + ' 态', hatOpts)}}
              ${{ctrlRow('bodyId', '袍服甲胄', cnt.bodies + ' 款', bodyOpts)}}
              ${{ctrlRow('upId', '百工披挂', (cnt.upgrades + 1) + ' 态', upOpts)}}
              ${{ctrlRow('wpnId', '主手兵刃', (cnt.weapons + 1) + ' 态', wpnOpts)}}
              ${{ctrlRow('shdId', '副手盾牌', (cnt.shields + 1) + ' 态', shdOpts)}}

              <div class="pd-wb-actions">
                <div style="display:flex;gap:8px;flex-wrap:wrap">
                  <button type="button" class="pd-primary-btn" data-pd-act="rand-cur">🎲 随机生成一位侠客</button>
                  <button type="button" class="pd-pill-btn" data-pd-act="rand-fem">🎲 随机女侠</button>
                  <button type="button" class="pd-pill-btn" data-pd-act="strip-hat">摘下头盔</button>
                </div>
                <small style="color:var(--muted)">与游戏内 <code>wx_appearance_system.nut</code> 布尔收鬓与防穿模规则 100% 一致</small>
              </div>
            </div>
          </div>
        </section>

        <section class="pd-squad-box">
          <div class="pd-squad-bar">
            <div class="pd-squad-presets">
              <strong style="font-family:var(--serif);font-size:16px;margin-right:4px">12人江湖战团群像：</strong>
              ${{squadPresets.map(([pid, plbl]) => `<button type="button" class="pd-pill-btn" data-pd-preset="${{pid}}" aria-pressed="${{pdState.preset === pid}}">${{plbl}}</button>`).join('')}}
            </div>
            <div style="display:flex;gap:6px;flex-wrap:wrap">
              <button type="button" class="pd-pill-btn" data-pd-act="squad-helm" aria-pressed="${{pdState.squadHelmets}}">${{pdState.squadHelmets ? '全队戴盔（点击验发）' : '全队免冠（点击戴盔）'}}</button>
              <button type="button" class="pd-pill-btn" data-pd-act="squad-wpn" aria-pressed="${{pdState.squadWeapons}}">${{pdState.squadWeapons ? '显兵盾：开' : '显兵盾：关'}}</button>
              <button type="button" class="pd-primary-btn" data-pd-act="reroll-all">🎲 重新洗牌 12 人</button>
            </div>
          </div>
          <div class="pd-squad-grid">${{squadCardsHtml}}</div>
        </section>
      </div>`;
  }}

  function refreshPaperdollStudioDom() {{
    const el = document.getElementById('wx-pd-studio');
    if (el) el.outerHTML = renderPaperdollStudioHtml();
  }}
{JS_END}"""


def patch_html(html: str, bundle: dict) -> str:
    # 1. Replace wx-bundle JSON
    bundle_json = json.dumps(bundle, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
    html, n_b = re.subn(
        r'(<script[^>]*id="wx-bundle"[^>]*>).*?(</script>)',
        lambda m: m.group(1) + bundle_json + m.group(2),
        html,
        count=1,
        flags=re.S,
    )
    assert n_b == 1, "Could not replace wx-bundle JSON"

    # 2. Inject CSS idempotently before </style>
    html = re.sub(rf"\n?{re.escape(CSS_START)}.*?{re.escape(CSS_END)}\n?", "\n", html, flags=re.S)
    assert "</style>" in html, "Could not locate </style>"
    html = html.replace("</style>", "\n" + PAPERDOLL_CSS + "\n</style>", 1)

    # 3. Add `paperdoll` section to WIKI_SECTIONS (idempotent)
    if "id: 'paperdoll'" not in html:
        target_sec = "{ id: 'world',     name: '奇遇委托与博戏', count: DB.world.events.length + DB.world.contracts.length + DB.world.ambitions.length + DB.world.gambling.length }"
        new_sec = (
            target_sec
            + ",\n    { id: 'paperdoll', name: '千面纸娃娃工坊', count: (DB.paperdollAssets && DB.paperdollAssets.counts ? DB.paperdollAssets.counts.totalSprites : 535) }"
        )
        assert target_sec in html, "Could not locate WIKI_SECTIONS tail entry"
        html = html.replace(target_sec, new_sec, 1)
    html = html.replace("railSub.textContent = '八大库';", "railSub.textContent = '九大库';", 1)

    # 4. Add Hero quick-jump CTA button to Paperdoll Workshop (idempotent)
    if 'data-jump-paperdoll="1"' not in html:
        hero_pills_end = """<span class="stat-pill"><b>${s.creatures}</b>尊山海万妖</span>
          </div>"""
        hero_pills_new = """<span class="stat-pill"><b>${s.creatures}</b>尊山海万妖</span>
          </div>
          <button type="button" class="hero-pd-cta" data-jump-paperdoll="1">🎭 进入「千人千面 · 纸娃娃换装试衣工坊」实时预览重制效果 →</button>"""
        assert hero_pills_end in html, "Could not locate Hero stat-pills end"
        html = html.replace(hero_pills_end, hero_pills_new, 1)

    # 5. Inject Paperdoll Studio JS before `// === Navigation & Top Bar Rendering ===`
    html = re.sub(rf"\n?{re.escape(JS_START)}.*?{re.escape(JS_END)}\n?", "\n", html, flags=re.S)
    nav_anchor = "  // === Navigation & Top Bar Rendering ==="
    assert nav_anchor in html, "Could not locate Navigation anchor"
    html = html.replace(nav_anchor, PAPERDOLL_JS + "\n\n" + nav_anchor, 1)

    # 6. Hook `state.wikiTab === 'paperdoll'` inside `renderWikiView()` (idempotent)
    if "if (state.wikiTab === 'paperdoll')" not in html:
        rw_anchor = "    if (state.wikiTab === 'manuals') {"
        rw_hook = """    if (state.wikiTab === 'paperdoll') {
      if (typeof stopStageVfx === 'function') stopStageVfx();
      if (typeof stopShanHaiStage === 'function') stopShanHaiStage();
      document.getElementById('toolbar-slot').innerHTML = '';
      document.getElementById('content-slot').innerHTML = renderPaperdollStudioHtml();
      return;
    }
    if (state.wikiTab === 'manuals') {"""
        assert rw_anchor in html, "Could not locate renderWikiView manuals branch"
        html = html.replace(rw_anchor, rw_hook, 1)

    # 7. Inject Click Event Delegation (idempotent)
    html = re.sub(rf"\n    {re.escape(EVT_START)}.*?{re.escape(EVT_END)}\n", "\n", html, flags=re.S)
    pd_click_handlers = f"""
    {EVT_START}
    const jumpPd = e.target.closest('[data-jump-paperdoll]');
    if (jumpPd) {{
      state.mode = 'wiki';
      state.wikiTab = 'paperdoll';
      state.subTab = '';
      state.f1 = ''; state.f2 = ''; state.f3 = '';
      state.page = 1;
      render();
      window.scrollTo({{ top: 0, behavior: 'smooth' }});
      return;
    }}
    const pdClassic = e.target.closest('[data-pd-classic]');
    if (pdClassic) {{
      const hit = PD_CLASSIC_PRESETS.find(x => x.id === pdClassic.dataset.pdClassic);
      if (hit) {{
        pdState.cur = Object.assign({{}}, hit);
        pdState.activeIdx = -1;
        pdState.previewBare = false;
        refreshPaperdollStudioDom();
      }}
      return;
    }}
    const pdStep = e.target.closest('[data-pd-step]');
    if (pdStep) {{
      const [fld, dir] = pdStep.dataset.pdStep.split(':');
      pdStepField(fld, Number(dir) || 1);
      refreshPaperdollStudioDom();
      return;
    }}
    const pdTone = e.target.closest('[data-pd-tone]');
    if (pdTone) {{
      pdState.cur.toneIdx = Number(pdTone.dataset.pdTone) || 0;
      if (pdState.activeIdx >= 0 && pdState.squad[pdState.activeIdx]) pdState.squad[pdState.activeIdx].toneIdx = pdState.cur.toneIdx;
      refreshPaperdollStudioDom();
      return;
    }}
    const pdPreset = e.target.closest('[data-pd-preset]');
    if (pdPreset) {{
      pdState.activeIdx = -1;
      pdGenerateSquad(pdPreset.dataset.pdPreset);
      refreshPaperdollStudioDom();
      return;
    }}
    const pdLoad = e.target.closest('[data-pd-load]');
    if (pdLoad) {{
      const idx = Number(pdLoad.dataset.pdLoad);
      if (pdState.squad[idx]) {{
        pdState.activeIdx = idx;
        pdState.cur = Object.assign({{}}, pdState.squad[idx]);
        refreshPaperdollStudioDom();
        window.scrollTo({{ top: 120, behavior: 'smooth' }});
      }}
      return;
    }}
    const pdRerollOne = e.target.closest('[data-pd-reroll-one]');
    if (pdRerollOne) {{
      const idx = Number(pdRerollOne.dataset.pdRerollOne);
      pdState.squad[idx] = pdRollOne(pdState.preset, idx);
      if (pdState.activeIdx === idx) pdState.cur = Object.assign({{}}, pdState.squad[idx]);
      refreshPaperdollStudioDom();
      return;
    }}
    const pdAct = e.target.closest('[data-pd-act]');
    if (pdAct) {{
      const act = pdAct.dataset.pdAct;
      if (act === 'zoom') pdState.zoom = pdState.zoom === 2 ? 1 : 2;
      else if (act === 'bg') pdState.bg = pdState.bg === 'dark' ? 'hex' : (pdState.bg === 'hex' ? 'light' : 'dark');
      else if (act === 'flip') pdState.flipped = !pdState.flipped;
      else if (act === 'ped') pdState.showPedestal = !pdState.showPedestal;
      else if (act === 'bare') pdState.previewBare = !pdState.previewBare;
      else if (act === 'wpn') pdState.showWeapons = !pdState.showWeapons;
      else if (act === 'squad-helm') pdState.squadHelmets = !pdState.squadHelmets;
      else if (act === 'squad-wpn') pdState.squadWeapons = !pdState.squadWeapons;
      else if (act === 'reroll-all') {{ pdState.activeIdx = -1; pdGenerateSquad(pdState.preset); }}
      else if (act === 'rand-cur') {{ pdState.activeIdx = -1; pdState.cur = pdRollOne('mixed', Math.floor(Math.random() * 12)); }}
      else if (act === 'rand-fem') {{ pdState.activeIdx = -1; pdState.cur = pdRollOne('heroine', Math.floor(Math.random() * 12)); }}
      else if (act === 'strip-hat') {{
        pdState.cur.hatId = '';
        if (pdState.activeIdx >= 0 && pdState.squad[pdState.activeIdx]) pdState.squad[pdState.activeIdx].hatId = '';
      }}
      refreshPaperdollStudioDom();
      return;
    }}
    {EVT_END}
"""
    click_anchor = "document.addEventListener('click', e => {"
    assert click_anchor in html, "Could not locate click event listener"
    html = html.replace(click_anchor, click_anchor + pd_click_handlers, 1)

    # 8. Inject Change Event Delegation for `<select data-pd-sel="...">` (idempotent)
    html = re.sub(rf"\n    {re.escape(CHG_START)}.*?{re.escape(CHG_END)}\n", "\n", html, flags=re.S)
    pd_change_handlers = f"""
    {CHG_START}
    if (e.target.dataset.pdSel) {{
      const fld = e.target.dataset.pdSel;
      const val = e.target.value;
      if (fld === 'faceIdx' || fld === 'hairIdx' || fld === 'toneIdx' || fld === 'beardIdx' || fld === 'scarIdx') {{
        pdState.cur[fld] = Number(val) || 0;
        if (fld === 'faceIdx' && pdState.cur.faceIdx >= 33) pdState.cur.beardIdx = 0;
      }} else {{
        pdState.cur[fld] = val;
        if (fld === 'wpnId' && pdIsTwoHandWeapon(val)) pdState.cur.shdId = '';
      }}
      if (pdState.activeIdx >= 0 && pdState.squad[pdState.activeIdx]) {{
        pdState.squad[pdState.activeIdx] = Object.assign({{}}, pdState.cur);
      }}
      refreshPaperdollStudioDom();
      return;
    }}
    {CHG_END}
"""
    change_anchor = "document.addEventListener('change', e => {"
    assert change_anchor in html, "Could not locate change event listener"
    html = html.replace(change_anchor, change_anchor + pd_change_handlers, 1)

    return html


def main():
    html = WIKI_PATH.read_text(encoding="utf-8")
    m = re.search(r'(<script[^>]*id="wx-bundle"[^>]*>)(.*?)(</script>)', html, re.S)
    assert m, "Could not locate wx-bundle in 山海武侠.html"
    bundle = json.loads(m.group(2))

    pd_assets, refreshed_rigs = build_paperdoll_bundle()
    bundle["paperdollAssets"] = pd_assets
    if "vfxAssets" in bundle and isinstance(bundle["vfxAssets"], dict):
        bundle["vfxAssets"]["rigs"] = refreshed_rigs

    out_html = patch_html(html, bundle)
    WIKI_PATH.write_text(out_html, encoding="utf-8")

    size_mb = WIKI_PATH.stat().st_size / (1024 * 1024)
    c = pd_assets["counts"]
    print(
        f"Injected offline Paperdoll Studio + refreshed {len(refreshed_rigs)} VFX hero rigs into {WIKI_PATH.name}: "
        f"{c['totalSprites']} embedded WebP layers "
        f"({c['faces']} faces, {c['hairs']}x2x4 hairs, {c['beards']}x4 beards, "
        f"{c['scars']} scars, {c['hats']} hats, {c['bodies']} bodies, "
        f"{c['upgrades']} upgrades, {c['weapons']} weapons, {c['shields']} shields, "
        f"compare={'YES' if pd_assets['compareUri'] else 'NO'}) -> {size_mb:.2f} MiB"
    )


if __name__ == "__main__":
    main()
