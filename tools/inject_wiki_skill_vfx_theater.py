#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Unpacks all 171 Wuxia active skill 4-frame sequences (684 frames), 32 Qi-auras,
16 Dharma/array signature FX, 8 articulated hero rigs, handheld weapons/shields,
faction opponents, and flying projectiles directly from `mod_wuxia/brushes/*.brush`
and `mod_wuxia/gfx/ui/items/`, and integrates the offline 60fps Martial Action &
VFX Theater + Detail Modal Live Animator into `山海武侠.html`.

100% standalone single-file HTML output (zero external `art/` path dependencies)
and 100% idempotent on repeated runs.
"""

import base64
import colorsys
import io
import json
import re
import struct
from pathlib import Path
from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parent.parent
MOD_DIR = ROOT / "mod_wuxia"
WIKI_PATH = ROOT / "山海武侠.html"
VFX_NUT = MOD_DIR / "mod_wuxia" / "systems" / "wx_vfx_system.nut"

CSS_START = "/* === WX_SKILL_VFX_CSS_START === */"
CSS_END = "/* === WX_SKILL_VFX_CSS_END === */"
JS_START = "// === WX_SKILL_VFX_JS_START ==="
JS_END = "// === WX_SKILL_VFX_JS_END ==="


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


def to_webp_uri(im: Image.Image, quality: int = 78) -> str:
    buf = io.BytesIO()
    im.save(buf, format="WEBP", quality=quality, method=4)
    return "data:image/webp;base64," + base64.b64encode(buf.getvalue()).decode("ascii")


def strip_pedestal(im: Image.Image, target_size=(96, 132), fade_start_y: int = 98, cut_y: int = 112) -> Image.Image:
    """Resizes a 104x142 bust to 96x132 and smoothly fades out the bottom stone pedestal."""
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


def extract_dominant_glow_hex(im1: Image.Image, im2: Image.Image) -> str:
    """Computes a vivid Qi-arc accent hex color directly from a skill's hand-painted VFX/frame sprites."""
    r_sum = g_sum = b_sum = w_sum = 0.0
    for im in (im1, im2):
        small = im.convert("RGBA").resize((32, 32), Image.Resampling.BILINEAR)
        raw = small.tobytes()
        for idx in range(0, len(raw), 4):
            r, g, b, a = raw[idx], raw[idx + 1], raw[idx + 2], raw[idx + 3]
            if a < 45:
                continue
            rf, gf, bf = r / 255.0, g / 255.0, b / 255.0
            h, s, v = colorsys.rgb_to_hsv(rf, gf, bf)
            if v < 0.25:
                continue
            weight = (a / 255.0) * (0.35 + s * 1.6) * (0.4 + v)
            r_sum += rf * weight
            g_sum += gf * weight
            b_sum += bf * weight
            w_sum += weight
    if w_sum <= 1e-5:
        return "#ffd070"
    rf, gf, bf = r_sum / w_sum, g_sum / w_sum, b_sum / w_sum
    h, s, v = colorsys.rgb_to_hsv(rf, gf, bf)
    s = min(1.0, max(0.58, s * 1.25))
    v = min(1.0, max(0.88, v * 1.22))
    rr, gg, bb = colorsys.hsv_to_rgb(h, s, v)
    return f"#{int(rr * 255):02x}{int(gg * 255):02x}{int(bb * 255):02x}"


def classify_skill_family(sid: str, weapons: list[str]) -> str:
    s = sid.lower()
    if s.startswith("wx_sword_") or s == "wx_acupoint_strike" or "Sword" in weapons:
        if "Saber" not in weapons or s.startswith("wx_sword_"):
            return "sword"
    if s.startswith("wx_saber_") or s == "wx_poise_charge" or "Saber" in weapons or "Cleaver" in weapons:
        return "saber"
    if s.startswith("wx_fist_") or s == "wx_hama_push" or "Fist" in weapons:
        return "fist"
    if s.startswith(("wx_spear_", "wx_pole_", "wx_staff_")) or "Spear" in weapons or "Polearm" in weapons:
        return "pole"
    if s.startswith(("wx_hammer_", "wx_axe_", "wx_shield_")) or any(w in weapons for w in ("Hammer", "Mace", "Axe", "Shield")):
        return "heavy"
    if s.startswith(("wx_dagger_", "wx_whip_", "wx_flail_", "wx_bow_", "wx_crossbow_", "wx_throw_", "wx_gun_")) or s == "wx_smoke_bomb" or any(
        w in weapons for w in ("Dagger", "Flail", "Bow", "Crossbow", "Throwing", "Firearm")
    ):
        return "odd"
    return "inner"


def parse_skill_choreo() -> dict[str, dict]:
    txt = VFX_NUT.read_text(encoding="utf-8")
    pat = re.compile(
        r'(wx_[a-z0-9_]+)\s*=\s*\[\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*(\d+)\s*,\s*(\d+)\s*\]'
    )
    out = {}
    for m in pat.finditer(txt):
        out[m.group(1)] = {
            "label": m.group(2),
            "anim": m.group(3),
            "mode": m.group(4),
            "vfx": m.group(5),
            "sig": m.group(6),
            "volleys": int(m.group(7)),
            "shake": int(m.group(8)),
        }
    assert len(out) == 171, f"Expected 171 SkillChoreo entries in wx_vfx_system.nut, got {len(out)}"
    return out


def build_vfx_assets_and_choreo(skills: list[dict]) -> dict:
    effs: dict[str, Image.Image] = {}
    for bp in sorted((MOD_DIR / "brushes").glob("wx_effects_*.brush")):
        effs.update(load_brush_sprites(bp))
    busts = load_brush_sprites(MOD_DIR / "brushes" / "wx_busts_0.brush")
    beasts = load_brush_sprites(MOD_DIR / "brushes" / "wx_beasts_0.brush")
    projs = load_brush_sprites(MOD_DIR / "brushes" / "wx_projectiles_0.brush")
    choreo_table = parse_skill_choreo()

    # 1) 171 4-frame strips (384x96 RGBA WebP)
    strips: dict[str, str] = {}
    used_vfx: set[str] = set()
    used_fx: set[str] = set()

    for sk in skills:
        sid = sk["id"].split(".")[-1]
        sk["key"] = sid
        assert sid in choreo_table, f"Skill {sid} missing from SkillChoreo!"
        ch = dict(choreo_table[sid])
        anim_id = ch["anim"]
        if anim_id not in strips:
            strip_im = Image.new("RGBA", (384, 96), (0, 0, 0, 0))
            for fi in range(1, 5):
                fk = f"{anim_id}_f{fi}"
                assert fk in effs, f"Missing frame sprite {fk}"
                frm = effs[fk].convert("RGBA").resize((96, 96), Image.Resampling.LANCZOS)
                strip_im.alpha_composite(frm, ((fi - 1) * 96, 0))
            strips[anim_id] = to_webp_uri(strip_im, quality=75)
        used_vfx.add(ch["vfx"])
        used_fx.add(ch["sig"])
        ch["fam"] = classify_skill_family(sid, sk.get("weapons") or [])
        ch["color"] = extract_dominant_glow_hex(effs[ch["vfx"]], effs[f"{anim_id}_f3"])
        sk["choreo"] = ch
        sk.pop("_searchStr", None)

    # 2) All 32 Qi-Auras + All 16 Signature FX elements
    vfx_uris: dict[str, str] = {}
    for vk in sorted(k for k in effs if k.startswith("wx_vfx_")):
        vfx_uris[vk] = to_webp_uri(effs[vk].convert("RGBA").resize((96, 96), Image.Resampling.LANCZOS), quality=78)

    fx_uris: dict[str, str] = {}
    for fk in sorted(k for k in effs if k.startswith("wx_fx_")):
        fx_uris[fk] = to_webp_uri(effs[fk].convert("RGBA").resize((96, 96), Image.Resampling.LANCZOS), quality=80)

    assert used_vfx.issubset(vfx_uris.keys()), f"Missing vfx keys: {used_vfx - vfx_uris.keys()}"
    assert used_fx.issubset(fx_uris.keys()), f"Missing fx keys: {used_fx - fx_uris.keys()}"

    # 3) 8 Articulated Martial Caster Rigs (Torso + Head composite, pedestal removed, tucked hair under closed hats)
    open_crown_hats = {
        "wx_hat_01", "wx_hat_09", "wx_hat_10", "wx_hat_12", "wx_hat_13", "wx_hat_14",
        "wx_hat_15", "wx_hat_16", "wx_hat_17", "wx_hat_21", "wx_hat_22",
        "wx_char_hat_topknot", "wx_char_hat_taoist",
    }
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
        if hair_k and hat_k and hat_k not in open_crown_hats and f"{hair_k}_tucked" in busts:
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

    # 4) 7 Faction Opponents (pedestal removed cleanly)
    enemy_specs = {
        "sword": "wx_enemy_dongchang_agent",
        "saber": "wx_enemy_liaodong_boss",
        "fist":  "wx_enemy_bronze_yaoren",
        "pole":  "wx_enemy_mobei_centurion",
        "heavy": "wx_enemy_tomb_general",
        "odd":   "wx_enemy_wudu_gushaman",
        "inner": "wx_enemy_xuesha_juggernaut",
    }
    enemies: dict[str, str] = {}
    for ek, bkey in enemy_specs.items():
        enemies[ek] = to_webp_uri(strip_pedestal(beasts[bkey], (96, 132), fade_start_y=98, cut_y=112), quality=82)

    # 5) Projectiles (64x64 RGBA WebP)
    proj_uris: dict[str, str] = {}
    for pk in (
        "wx_proj_liuxingjian",
        "wx_proj_diaolingjian",
        "wx_proj_liuyefeidao",
        "wx_proj_jinqianbiao",
        "wx_proj_lihuazhen",
        "wx_proj_kongqueling",
        "wx_proj_huochongdan",
        "wx_proj_pilileihuo",
    ):
        proj_uris[pk] = to_webp_uri(projs[pk].convert("RGBA").resize((64, 64), Image.Resampling.LANCZOS), quality=82)

    # 6) Handheld Weapons & Shields from `mod_wuxia/gfx/ui/items`
    ui_items = MOD_DIR / "gfx" / "ui" / "items"
    wpn_files = {
        "juque":       "weapons/named/wx_relic_juque.png",
        "taiji_sword": "weapons/melee/wx_wpn_sword_05.png",
        "chengying":   "weapons/named/wx_relic_chengying.png",
        "yinglong":    "weapons/named/wx_relic_yinglongjian.png",
        "modao":       "weapons/named/wx_relic_modao.png",
        "xiuchun":     "weapons/named/wx_relic_xiuchun.png",
        "minghong":    "weapons/named/wx_relic_minghong.png",
        "tulong":      "weapons/named/wx_relic_tulong.png",
        "qiongqizhao": "weapons/named/wx_relic_qiongqizhao.png",
        "jingangwan":  "weapons/named/wx_relic_jingangwan.png",
        "huaji":       "weapons/named/wx_relic_huaji.png",
        "goulian":     "weapons/named/wx_relic_goulianqiang.png",
        "lvzhuzhang":  "weapons/named/wx_relic_lvzhuzhang.png",
        "huntiegun":   "weapons/named/wx_relic_huntiegun.png",
        "bawangqiang": "weapons/named/wx_relic_bawangqiang.png",
        "wengjinchui": "weapons/named/wx_relic_wengjinchui.png",
        "xuanhuafu":   "weapons/named/wx_relic_xuanhuafu.png",
        "shd_12":      "shields/wx_shd_12.png",
        "shd_xuangui": "shields/wx_shd_xuangui.png",
        "yuchang":     "weapons/named/wx_relic_yuchang.png",
        "whip":        "weapons/melee/wx_wpn_whip_03.png",
        "dashenbian":  "weapons/named/wx_relic_dashenbian.png",
        "shenbinu":    "weapons/named/wx_relic_shenbinu.png",
        "zhentiangong":"weapons/named/wx_relic_zhentiangong.png",
        "xunleichong": "weapons/named/wx_relic_xunleichong.png",
        "feidao":      "weapons/melee/wx_wpn_dagger_04.png",
    }
    weapons_uris: dict[str, str] = {}
    for wk, rel in wpn_files.items():
        p = ui_items / rel
        if not p.exists():
            matches = [c for c in ui_items.rglob(Path(rel).name) if "_70x70" not in c.name]
            assert matches, f"Missing weapon PNG for {wk}: {rel}"
            p = matches[0]
        wim = Image.open(p).convert("RGBA")
        s = min(64.0 / max(1, wim.width), 120.0 / max(1, wim.height), 1.0)
        nw, nh = max(1, int(round(wim.width * s))), max(1, int(round(wim.height * s)))
        weapons_uris[wk] = to_webp_uri(wim.resize((nw, nh), Image.Resampling.LANCZOS), quality=84)

    # 7) Unpack ALL 4 Next-Gen Kinetic VFX Atlases (`wx_kinetic_0..3.brush`: 22 multi-frame sequences + 28 micro-particles)
    kinetic_data: dict = {"strips": {}, "meta": {}, "parts": {}, "catalog": {}}
    kin_sprites: dict[str, Image.Image] = {}
    for kbp in sorted((MOD_DIR / "brushes").glob("wx_kinetic_*.brush")):
        kin_sprites.update(load_brush_sprites(kbp))
    if kin_sprites:
        kin_seqs = [
            ("wx_kin_sword_slash",    10, 195, 165),
            ("wx_kin_dragon_surge",   12, 240, 150),
            ("wx_kin_flame_cleave",   10, 195, 195),
            ("wx_kin_flame_pillar",   10, 150, 210),
            ("wx_kin_thunder_bolt",   10, 165, 255),
            ("wx_kin_celestial_beam", 10, 255, 128),
            ("wx_kin_blood_arc",      10, 195, 165),
            ("wx_kin_spear_drill",    10, 225, 120),
            ("wx_kin_whirl_cyclone",  10, 195, 158),
            ("wx_kin_claw_rend",      10, 188, 165),
            ("wx_kin_whip_lash",      10, 218, 128),
            ("wx_kin_shadow_cross",   10, 188, 165),
            ("wx_kin_buddha_palm",    10, 180, 195),
            ("wx_kin_frost_burst",    10, 180, 180),
            ("wx_kin_venom_mire",     10, 180, 180),
            ("wx_kin_earth_shatter",  10, 195, 165),
            ("wx_kin_arrow_barrage",  10, 225, 120),
            ("wx_kin_sonic_wave",     10, 195, 165),
            ("wx_kin_taiji_seal",     10, 180, 180),
            ("wx_kin_golden_dome",    10, 180, 180),
            ("wx_kin_qinggong_gust",  10, 195, 150),
            ("wx_kin_soul_vortex",    10, 188, 172),
            ("wx_kin_lotus_poke",     10, 180, 180),
            ("wx_kin_fist_flurry",    10, 195, 158),
            ("wx_kin_giant_axe",      10, 195, 172),
            ("wx_kin_phoenix_spear",  10, 218, 135),
            ("wx_kin_bamboo_bind",    10, 195, 165),
            ("wx_kin_flying_knives",  10, 218, 128),
            ("wx_kin_peacock_fan",    10, 202, 165),
            ("wx_kin_cannon_blast",   10, 195, 180),
            ("wx_kin_war_banner",     10, 180, 195),
            ("wx_kin_xuanwu_aegis",   10, 180, 180),
            ("wx_kin_tidal_wave",     10, 210, 150),
            ("wx_kin_gold_needles",   10, 188, 172),
            ("wx_kin_snow_step",      10, 195, 158),
            ("wx_kin_warp_seal",      10, 188, 172),
            ("wx_kin_smoke_cloud",    10, 195, 165),
            ("wx_kin_prism_burst",    10, 195, 165),
            ("wx_kin_sword_rain",     10, 195, 188),
            ("wx_kin_moon_crescent",  10, 195, 165),
        ]
        for prefix, cnt, fw, fh in kin_seqs:
            strip_im = Image.new("RGBA", (fw * cnt, fh), (0, 0, 0, 0))
            ok = True
            for fi in range(cnt):
                sk_name = f"{prefix}_{fi:02d}"
                if sk_name not in kin_sprites:
                    ok = False
                    break
                frm = kin_sprites[sk_name].convert("RGBA").resize((fw, fh), Image.Resampling.LANCZOS)
                strip_im.alpha_composite(frm, (fi * fw, 0))
            if ok:
                kinetic_data["strips"][prefix] = to_webp_uri(strip_im, quality=82)
                kinetic_data["meta"][prefix] = {"count": cnt, "fw": fw, "fh": fh}
        for pk, pim in sorted(kin_sprites.items()):
            if pk.startswith("wx_pt_"):
                sw = min(132, pim.width)
                sh = max(1, int(round(pim.height * (sw / float(max(1, pim.width))))))
                kinetic_data["parts"][pk] = to_webp_uri(pim.convert("RGBA").resize((sw, sh), Image.Resampling.LANCZOS), quality=82)

    cat_json_path = ROOT / "tools" / "wx_kinetic_catalog.json"
    assert cat_json_path.exists(), f"Missing {cat_json_path}; run tools/build_171_kinetic_catalog.py first"
    raw_cat = json.loads(cat_json_path.read_text(encoding="utf-8"))
    for _k, c in raw_cat.items():
        cycle_ms = max(1160, min(1680, int(round(c["totalMs"] * 1.54))))
        imp_p = max(0.32, min(0.62, round(c["impactMs"] / float(max(600, c["totalMs"])) * 1.15, 3)))
        kinetic_data["catalog"][c["id"]] = {
            "title": c["title"],
            "sub": c["subtitle"],
            "seal": c["seal"],
            "arch": c["arch"],
            "seq": c["seq"],
            "seq2": c["seq2"],
            "motion": c["motion"],
            "react": c["react"],
            "theme": c["theme"],
            "col": c["col"],
            "core": c["core"],
            "tint": c["tint"],
            "kind": c["kind"],
            "ground": c["ground"],
            "shakePow": c["shakePow"],
            "cycleMs": cycle_ms,
            "impactP": imp_p,
            "tag": c["tag"],
            "beats": c["beats"],
        }

    return {
        "strips": strips,
        "vfx": vfx_uris,
        "fx": fx_uris,
        "rigs": rigs,
        "enemies": enemies,
        "projs": proj_uris,
        "weapons": weapons_uris,
        "kinetic": kinetic_data,
    }


VFX_CSS_BLOCK = f"""{CSS_START}
.wx-vfx-theater {{
  background: linear-gradient(180deg, #241b15 0%, #17110d 100%);
  border: 1.5px solid var(--bronze);
  border-radius: 5px;
  padding: 14px 16px;
  margin: 0 0 18px;
  color: #f4ebd9;
  box-shadow: 0 6px 20px rgba(0, 0, 0, .22);
}}
.wx-vfx-head {{
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  flex-wrap: wrap;
  padding-bottom: 10px;
  margin-bottom: 10px;
  border-bottom: 1px solid rgba(182, 141, 82, .32);
}}
.wx-vfx-head-title strong {{
  display: block;
  font: 700 17px/1.3 var(--serif);
  color: #ffe3a3;
  letter-spacing: .03em;
}}
.wx-vfx-head-title small {{
  display: block;
  font-size: 12px;
  color: #c7b495;
  margin-top: 2px;
}}
.wx-vfx-head-actions {{
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
}}
.wx-vfx-btn {{
  padding: 5px 11px;
  border-radius: 3px;
  background: #2f241c;
  border: 1px solid #6f5332;
  color: #ebd9b9;
  font-size: 12.5px;
  font-weight: 600;
  transition: background .15s, border-color .15s, color .15s;
}}
.wx-vfx-btn:hover {{
  background: #3d2e23;
  border-color: #c59b5f;
  color: #fff5df;
}}
.wx-vfx-btn[aria-pressed="true"] {{
  background: linear-gradient(180deg, #873024, #631d14);
  border-color: #e2b46d;
  color: #fff7e6;
}}
.wx-vfx-cats {{
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 12px;
}}
.wx-vfx-cat {{
  padding: 4px 10px;
  border-radius: 3px;
  background: #271e17;
  border: 1px solid #574128;
  color: #d7c5a6;
  font-size: 12.3px;
}}
.wx-vfx-cat:hover {{ border-color: #b68d52; color: #fff2d6; }}
.wx-vfx-cat[aria-pressed="true"] {{
  background: #3d2d1d;
  border-color: #dfb26c;
  color: #ffe7b0;
  font-weight: 700;
}}
.wx-vfx-grid {{
  display: grid;
  grid-template-columns: minmax(300px, 490px) 1fr;
  gap: 14px;
  align-items: start;
}}
.wx-vfx-stage-col {{
  display: flex;
  flex-direction: column;
  gap: 8px;
}}
.wx-vfx-canvas-box {{
  position: relative;
  background: #100b08;
  border: 1px solid #6e5231;
  border-radius: 4px;
  overflow: hidden;
  box-shadow: inset 0 0 24px rgba(0, 0, 0, .75);
}}
.wx-vfx-canvas-box canvas {{
  display: block;
  width: 100%;
  height: auto;
  aspect-ratio: 480 / 264;
}}
.wx-vfx-ctrl-row {{
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  flex-wrap: wrap;
}}
.wx-vfx-ctrl-left {{
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}}
.wx-vfx-meta-tag {{
  font-size: 12px;
  color: #dec8a2;
}}
.wx-vfx-frames {{
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 6px;
}}
.wx-frame-btn {{
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 6px 4px;
  background: #211913;
  border: 1px solid #4f3b25;
  border-radius: 3px;
  color: #d6c3a3;
  font-size: 11.5px;
}}
.wx-frame-btn:hover {{ border-color: #b88f54; color: #fff1d0; }}
.wx-frame-btn[aria-pressed="true"] {{
  background: #382819;
  border-color: #f0c274;
  color: #ffe8b3;
  box-shadow: 0 0 0 1px rgba(240, 194, 116, .35);
}}
.wx-frame-thumb {{
  width: 58px;
  height: 58px;
  display: block;
  background-repeat: no-repeat;
  background-size: 400% 100%;
  border-radius: 3px;
  background-color: rgba(12, 9, 7, .65);
  border: 1px solid rgba(182, 141, 82, .25);
}}
.wx-vfx-roster {{
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(195px, 1fr));
  gap: 6px;
  max-height: 392px;
  overflow-y: auto;
  padding: 4px;
  background: rgba(15, 11, 8, .52);
  border: 1px solid #4a3723;
  border-radius: 4px;
}}
.wx-vfx-pick {{
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 8px;
  border-radius: 3px;
  background: #251c15;
  border: 1px solid #463421;
  text-align: left;
  color: #eadac0;
}}
.wx-vfx-pick:hover {{
  background: #33261c;
  border-color: #a98149;
}}
.wx-vfx-pick[aria-pressed="true"] {{
  background: linear-gradient(90deg, #4b2419 0%, #2f1d15 100%);
  border-color: #e7b96f;
  box-shadow: inset 2px 0 0 #f2c77e;
}}
.wx-vfx-pick img {{
  width: 34px;
  height: 34px;
  border-radius: 3px;
  border: 1px solid #6b5031;
  background: #140f0c;
  flex-shrink: 0;
}}
.wx-vfx-pick-txt {{
  min-width: 0;
  flex: 1;
}}
.wx-vfx-pick-txt b {{
  display: block;
  font-size: 13px;
  color: #fff2d9;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}}
.wx-vfx-pick-txt small {{
  display: block;
  font-size: 11px;
  color: #bfa987;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}}
.wx-vfx-proto-badge {{
  display: inline-block;
  margin-left: 5px;
  padding: 1px 5px;
  border-radius: 2px;
  background: linear-gradient(90deg, #a62b1c, #d48224);
  color: #fff6dc;
  font-size: 10px;
  font-weight: 700;
  vertical-align: middle;
}}
.wx-vfx-cat[data-vfx-cat="kinetic"] {{
  border-color: #e5a94e;
  color: #ffe8a8;
  background: linear-gradient(180deg, #4b2416, #2d160e);
}}
.wx-vfx-cat[data-vfx-cat="kinetic"][aria-pressed="true"] {{
  background: linear-gradient(180deg, #98321e, #661c10);
  border-color: #ffd57a;
  color: #fff8e2;
  box-shadow: 0 0 10px rgba(240, 178, 72, .35);
}}
.wx-vfx-proto-bar {{
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  flex-wrap: wrap;
  padding: 7px 10px;
  border-radius: 4px;
  background: linear-gradient(90deg, rgba(138, 42, 24, .34), rgba(38, 28, 20, .78));
  border: 1px solid rgba(235, 182, 92, .48);
  font-size: 12px;
  color: #f3dfb8;
}}
.wx-modal-vfx {{
  background: linear-gradient(180deg, #231a14 0%, #16100c 100%);
  border: 1.5px solid var(--bronze);
  border-radius: 4px;
  padding: 12px;
  margin: 0 0 14px;
  color: #f3e8d4;
}}
.wx-modal-vfx-grid {{
  display: grid;
  grid-template-columns: minmax(260px, 1.35fr) minmax(190px, 1fr);
  gap: 12px;
  align-items: center;
}}
@media (max-width: 980px) {{
  .wx-vfx-grid {{ grid-template-columns: 1fr; }}
  .wx-vfx-roster {{ max-height: 250px; }}
  .wx-modal-vfx-grid {{ grid-template-columns: 1fr; }}
}}
{CSS_END}"""


VFX_JS_BLOCK = r"""// === WX_SKILL_VFX_JS_START ===
  const VFX_ASSETS = DB.vfxAssets || { strips: {}, vfx: {}, fx: {}, rigs: {}, enemies: {}, projs: {}, weapons: {}, kinetic: { strips: {}, meta: {}, parts: {}, catalog: {} } };
  const KINETIC_ASSETS = VFX_ASSETS.kinetic || { strips: {}, meta: {}, parts: {}, catalog: {} };
  const KINETIC_PROTOS = KINETIC_ASSETS.catalog || {};
  const VFX_FEATURED_IDS = [
    'actives.wx_sword_combo', 'actives.wx_fist_xianglong', 'actives.wx_saber_ranmu', 'actives.wx_hammer_leiting',
    'actives.wx_sword_tianwai', 'actives.wx_sword_wanjian', 'actives.wx_saber_xuehai', 'actives.wx_saber_xinyue',
    'actives.wx_spear_thrust2', 'actives.wx_pole_sweep', 'actives.wx_staff_dagou', 'actives.wx_axe_kaitian',
    'actives.wx_fist_rulai', 'actives.wx_fist_jab', 'actives.wx_fist_acupoint', 'actives.wx_fist_qishang',
    'actives.wx_fist_xuanming', 'actives.wx_fist_nuchao', 'actives.wx_throw_kongque', 'actives.wx_throw_fan',
    'actives.wx_throw_pilidan', 'actives.wx_shield_xuanwu', 'actives.wx_rally_command', 'actives.wx_tactics_jinzhen',
    'actives.wx_qinggong_xuelian', 'actives.wx_qinggong_suodi', 'actives.wx_smoke_cast', 'actives.wx_sword_taiji'
  ];
  const VFX_CAT_DEFS = [
    ['featured', '✨ 镇派精选 (28)'],
    ['all', '全部逐帧动效 (171)'],
    ['filtered', '当前筛选结果'],
    ['sword', '剑法'],
    ['saber', '刀法'],
    ['fist', '拳掌指爪'],
    ['pole', '枪戟棍杖'],
    ['heavy', '锤斧重盾'],
    ['odd', '奇门弓弩暗器'],
    ['inner', '内轻横练奇术']
  ];
  const VFX_FRAME_NAMES = ['F1 蓄势起手', 'F2 身兵合一', 'F3 真罡破敌', 'F4 收势回气'];

  const vfxState = {
    collapsed: false,
    cat: 'featured',
    skillId: 'actives.wx_sword_combo',
    speed: 1.0,
    lockFrame: -1,
    closeRange: true,
    useLegacyCompare: false,
    modalSpeed: 1.0,
    modalLockFrame: -1,
    stageRaf: 0,
    modalRaf: 0,
    lastFiltered: null
  };
  const vfxImgCache = new Map();

  function wxImg(uri) {
    if (!uri) return null;
    let im = vfxImgCache.get(uri);
    if (!im) {
      im = new Image();
      im.src = uri;
      vfxImgCache.set(uri, im);
    }
    return im;
  }

  function stopStageVfx() {
    if (vfxState.stageRaf) {
      cancelAnimationFrame(vfxState.stageRaf);
      vfxState.stageRaf = 0;
    }
  }

  function stopModalVfx() {
    if (vfxState.modalRaf) {
      cancelAnimationFrame(vfxState.modalRaf);
      vfxState.modalRaf = 0;
    }
  }

  function wxPickRigKey(sk) {
    const k = (sk.key || '').toLowerCase();
    const m = ((sk.choreo && sk.choreo.mode) || '').toLowerCase();
    if (k.includes('taiji') || k.includes('zhenwu') || k.includes('zixia') || k.includes('guiyuan') || k === 'wx_meditate' || k === 'wx_qinggong_zongyue') return 'taoist';
    if (k.includes('jingang') || k.includes('rulai') || k.includes('weituo') || k.includes('luohan') || k.includes('yijin') || k.includes('jinzhong') || k.includes('ranmu') || k.includes('shihou')) return 'monk';
    if (k.includes('duoming') || k.includes('canhe') || k.includes('douzhuan') || k.includes('lingbo') || k.includes('jinzhen') || k.includes('luoying') || k.includes('yunv')) return 'scholar';
    if (k.includes('xianglong') || k.includes('dagou') || k.includes('qigai') || k === 'wx_staff_challenge') return 'beggar';
    if (m.startsWith('shadow_') || k.includes('dagger') || k.includes('jiuyin') || k.includes('xuanming') || k.includes('xuehai') || k.includes('xixing') || k === 'wx_blood_burst') return 'assassin';
    if (k.includes('throw') || k.includes('smoke') || k.includes('crossbow') || k.includes('whip') || k.includes('flail') || k.includes('wudu') || k.includes('gun_')) return 'tangmen';
    if (k.includes('hammer') || k.includes('axe') || k.includes('shield') || k.includes('modao') || k.includes('fangtian') || k.includes('junwu') || k === 'wx_rally_command') return 'general';
    return 'swordsman';
  }

  function wxPickWeaponSpec(sk) {
    const k = (sk.key || '').toLowerCase();
    const wpns = sk.weapons || [];
    if (k.includes('zhongjian') || k.includes('miejian')) return { wKey: 'juque', w: 56, h: 106, kind: 'blade' };
    if (k.includes('taiji') || k.includes('zhenwu')) return { wKey: 'taiji_sword', w: 48, h: 96, kind: 'blade' };
    if (k.includes('wanjian') || k.includes('feixian')) return { wKey: 'yinglong', w: 50, h: 100, kind: 'blade' };
    if (k.startsWith('wx_sword_') || k === 'wx_acupoint_strike' || wpns.includes('Sword')) return { wKey: 'chengying', w: 48, h: 96, kind: 'blade' };
    if (k.includes('modao') || k.includes('podao')) return { wKey: 'modao', w: 60, h: 116, kind: 'pole' };
    if (k.includes('fanzhen') || k.includes('xiuchun')) return { wKey: 'xiuchun', w: 48, h: 94, kind: 'blade' };
    if (k.includes('badao') || k.includes('chiyou') || k.includes('tulong')) return { wKey: 'tulong', w: 54, h: 102, kind: 'blade' };
    if (k.startsWith('wx_saber_') || k === 'wx_poise_charge' || wpns.includes('Saber') || wpns.includes('Cleaver')) return { wKey: 'minghong', w: 52, h: 98, kind: 'blade' };
    if (k.includes('jiuyin') || k.includes('zhao') || k.includes('grapple') || k.includes('disarm')) return { wKey: 'qiongqizhao', w: 40, h: 42, kind: 'fist' };
    if (k.startsWith('wx_fist_') || wpns.includes('Fist')) return { wKey: 'jingangwan', w: 38, h: 38, kind: 'fist' };
    if (k.includes('fangtian') || k.includes('halberd') || k.includes('ji')) return { wKey: 'huaji', w: 62, h: 120, kind: 'pole' };
    if (k.includes('goulian')) return { wKey: 'goulian', w: 58, h: 114, kind: 'pole' };
    if (k.includes('dagou')) return { wKey: 'lvzhuzhang', w: 54, h: 110, kind: 'pole' };
    if (k.startsWith('wx_staff_')) return { wKey: 'huntiegun', w: 56, h: 112, kind: 'pole' };
    if (k.startsWith('wx_spear_') || k.startsWith('wx_pole_') || wpns.includes('Spear') || wpns.includes('Polearm')) return { wKey: 'bawangqiang', w: 60, h: 116, kind: 'pole' };
    if (k.startsWith('wx_hammer_') || wpns.includes('Hammer') || wpns.includes('Mace')) return { wKey: 'wengjinchui', w: 56, h: 98, kind: 'heavy' };
    if (k.startsWith('wx_axe_') || wpns.includes('Axe')) return { wKey: 'xuanhuafu', w: 58, h: 106, kind: 'heavy' };
    if (k.startsWith('wx_shield_') || wpns.includes('Shield')) return { wKey: 'shd_xuangui', w: 56, h: 68, kind: 'shield' };
    if (k.startsWith('wx_dagger_') || wpns.includes('Dagger')) return { wKey: 'yuchang', w: 38, h: 68, kind: 'dagger' };
    if (k.startsWith('wx_whip_') || k.startsWith('wx_flail_') || wpns.includes('Flail')) return { wKey: 'whip', w: 48, h: 78, kind: 'whip' };
    if (k.startsWith('wx_gun_') || wpns.includes('Firearm')) return { wKey: 'xunleichong', w: 58, h: 86, kind: 'gun' };
    if (k.startsWith('wx_crossbow_') || wpns.includes('Crossbow')) return { wKey: 'shenbinu', w: 56, h: 74, kind: 'bow' };
    if (k.startsWith('wx_bow_') || wpns.includes('Bow')) return { wKey: 'zhentiangong', w: 52, h: 92, kind: 'bow' };
    if (k.startsWith('wx_throw_') || k === 'wx_smoke_bomb' || wpns.includes('Throwing')) return { wKey: 'feidao', w: 34, h: 58, kind: 'throw' };
    return { wKey: null, w: 0, h: 0, kind: 'inner' };
  }

  function wxDrawHex(ctx, cx, cy, rx, ry, stroke, fill) {
    ctx.beginPath();
    for (let i = 0; i < 6; i++) {
      const ang = (Math.PI / 3) * i + Math.PI / 6;
      const x = cx + Math.cos(ang) * rx;
      const y = cy + Math.sin(ang) * ry;
      if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    ctx.closePath();
    if (fill) { ctx.fillStyle = fill; ctx.fill(); }
    if (stroke) { ctx.strokeStyle = stroke; ctx.lineWidth = 1.5; ctx.stroke(); }
  }

  function wxDrawSprite(ctx, im, cx, cy, w, h, rotRad, alpha, flipX) {
    if (!im || !im.complete || !im.naturalWidth || alpha <= 0.01) return;
    ctx.save();
    ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
    ctx.translate(cx, cy);
    if (rotRad) ctx.rotate(rotRad);
    if (flipX) ctx.scale(-1, 1);
    ctx.drawImage(im, -w / 2, -h / 2, w, h);
    ctx.restore();
  }

  function wxDrawStripFrame(ctx, stripIm, frameIdx, cx, cy, sz, alpha) {
    if (!stripIm || !stripIm.complete || !stripIm.naturalWidth || alpha <= 0.01) return;
    const fw = stripIm.naturalWidth / 4;
    const fh = stripIm.naturalHeight;
    ctx.save();
    ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
    ctx.translate(cx, cy);
    ctx.drawImage(stripIm, frameIdx * fw, 0, fw, fh, -sz / 2, -sz / 2, sz, sz);
    ctx.restore();
  }

  function wxDrawSlashRibbon(ctx, cx, cy, rOuter, rInner, a0, a1, colorHex, alpha) {
    if (alpha <= 0.01) return;
    ctx.save();
    ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
    ctx.beginPath();
    const steps = 22;
    for (let i = 0; i <= steps; i++) {
      const t = i / steps;
      const a = a0 + (a1 - a0) * t;
      const ro = rOuter * (0.90 + Math.sin(t * Math.PI) * 0.14);
      const x = cx + Math.cos(a) * ro;
      const y = cy + Math.sin(a) * ro;
      if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    for (let i = steps; i >= 0; i--) {
      const t = i / steps;
      const a = a0 + (a1 - a0) * t;
      const ri = rOuter - (rOuter - rInner) * Math.sin(t * Math.PI);
      ctx.lineTo(cx + Math.cos(a) * ri, cy + Math.sin(a) * ri);
    }
    ctx.closePath();
    ctx.fillStyle = colorHex;
    ctx.shadowColor = colorHex;
    ctx.shadowBlur = 15;
    ctx.fill();
    ctx.beginPath();
    ctx.arc(cx, cy, rOuter * 0.98, Math.min(a0, a1), Math.max(a0, a1));
    ctx.strokeStyle = '#ffffff';
    ctx.lineWidth = 2.4;
    ctx.stroke();
    ctx.restore();
  }

  function wxDrawSpeedLines(ctx, W, H, colorHex, intensity) {
    if (intensity <= 0.02) return;
    ctx.save();
    ctx.globalAlpha = intensity * 0.34;
    ctx.strokeStyle = colorHex;
    for (let i = 0; i < 14; i++) {
      const y = 20 + ((i * 37) % (H - 40));
      const len = 56 + ((i * 29) % 115);
      const x0 = ((i * 83) % (W - 70));
      ctx.lineWidth = (i % 3 === 0) ? 2.1 : 1.1;
      ctx.beginPath();
      ctx.moveTo(x0, y);
      ctx.lineTo(x0 + len, y);
      ctx.stroke();
    }
    ctx.restore();
  }

  const KIN_THEME_CFG = {
    cyan:      { ring: 'wx_pt_ring_cyan',    sparks: ['wx_pt_spark_cyan', 'wx_pt_ink_drop', 'wx_pt_wind_wisp'],   vig: 'rgba(4,12,18,',  flash: 'rgba(165,246,255,' },
    gold:      { ring: 'wx_pt_ring_gold',    sparks: ['wx_pt_spark_gold', 'wx_pt_ember', 'wx_pt_glint_star'],     vig: 'rgba(18,12,4,',  flash: 'rgba(255,236,162,' },
    fire:      { ring: 'wx_pt_ring_fire',    sparks: ['wx_pt_spark_fire', 'wx_pt_ember', 'wx_pt_smoke'],          vig: 'rgba(26,6,3,',   flash: 'rgba(255,182,92,'  },
    violet:    { ring: 'wx_pt_ring_violet',  sparks: ['wx_pt_spark_violet', 'wx_pt_glint_star', 'wx_pt_ink_drop'],vig: 'rgba(12,4,26,',  flash: 'rgba(220,188,255,' },
    celestial: { ring: 'wx_pt_ring_gold',    sparks: ['wx_pt_spark_gold', 'wx_pt_spark_cyan', 'wx_pt_glint_star'],vig: 'rgba(4,10,20,',  flash: 'rgba(255,250,224,' },
    crimson:   { ring: 'wx_pt_ring_crimson', sparks: ['wx_pt_spark_crimson', 'wx_pt_ink_drop', 'wx_pt_ember'],    vig: 'rgba(28,4,8,',   flash: 'rgba(255,162,175,' },
    jade:      { ring: 'wx_pt_ring_jade',    sparks: ['wx_pt_spark_jade', 'wx_pt_wind_wisp', 'wx_pt_petal'],      vig: 'rgba(4,18,14,',  flash: 'rgba(185,255,228,' },
    frost:     { ring: 'wx_pt_ring_frost',   sparks: ['wx_pt_spark_frost', 'wx_pt_ice_shard', 'wx_pt_glint_star'],vig: 'rgba(6,16,30,',  flash: 'rgba(205,244,255,' },
    venom:     { ring: 'wx_pt_ring_venom',   sparks: ['wx_pt_spark_venom', 'wx_pt_smoke', 'wx_pt_ink_drop'],      vig: 'rgba(8,20,10,',  flash: 'rgba(188,255,152,' },
    ink:       { ring: 'wx_pt_ring_violet',  sparks: ['wx_pt_ink_drop', 'wx_pt_wind_wisp', 'wx_pt_spark_violet'], vig: 'rgba(6,6,14,',   flash: 'rgba(210,218,248,' }
  };

  const kinTintCache = new Map();
  function wxGetTintedStrip(seqKey, tint) {
    const uri = KINETIC_ASSETS.strips && KINETIC_ASSETS.strips[seqKey];
    if (!uri) return null;
    const im = wxImg(uri);
    if (!im || !im.complete || !im.naturalWidth) return null;
    if (!tint || (tint[0] >= 250 && tint[1] >= 250 && tint[2] >= 250)) return im;
    const cKey = seqKey + ':' + tint[0] + ',' + tint[1] + ',' + tint[2];
    if (kinTintCache.has(cKey)) return kinTintCache.get(cKey);
    const oc = document.createElement('canvas');
    oc.width = im.naturalWidth; oc.height = im.naturalHeight;
    const octx = oc.getContext('2d');
    octx.drawImage(im, 0, 0);
    octx.globalCompositeOperation = 'multiply';
    octx.fillStyle = 'rgb(' + tint[0] + ',' + tint[1] + ',' + tint[2] + ')';
    octx.fillRect(0, 0, oc.width, oc.height);
    octx.globalCompositeOperation = 'destination-in';
    octx.drawImage(im, 0, 0);
    kinTintCache.set(cKey, oc);
    return oc;
  }

  function wxDrawKineticFrame(ctx, seqKey, frameFloat, cx, cy, scale, rotRad, alpha, flipX, tint) {
    const meta = KINETIC_ASSETS.meta && KINETIC_ASSETS.meta[seqKey];
    if (!meta || alpha <= 0.01) return;
    const src = wxGetTintedStrip(seqKey, tint);
    if (!src) return;
    const idx = Math.max(0, Math.min(meta.count - 1, Math.floor(frameFloat)));
    const dw = meta.fw * scale;
    const dh = meta.fh * scale;
    ctx.save();
    ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
    ctx.translate(cx, cy);
    if (rotRad) ctx.rotate(rotRad);
    if (flipX) ctx.scale(-1, 1);
    ctx.drawImage(src, idx * meta.fw, 0, meta.fw, meta.fh, -dw / 2, -dh / 2, dw, dh);
    ctx.restore();
  }

  function startKineticProtoCanvas(canvasId, sk, proto, isModal) {
    const cv = document.getElementById(canvasId);
    if (!cv || typeof cv.getContext !== 'function') return;
    const ctx = cv.getContext('2d');
    if (!ctx) return;
    if (isModal) stopModalVfx(); else stopStageVfx();

    const rigObj = VFX_ASSETS.rigs[wxPickRigKey(sk)] || VFX_ASSETS.rigs.swordsman || {};
    const torsoIm = wxImg(rigObj.torso);
    const headIm = wxImg(rigObj.head);
    const wSpec = wxPickWeaponSpec(sk);
    const wpnIm = wSpec.wKey ? wxImg(VFX_ASSETS.weapons[wSpec.wKey]) : null;
    const oppIm = wxImg(VFX_ASSETS.enemies[(sk.choreo && sk.choreo.fam) || 'fist'] || VFX_ASSETS.enemies.fist);

    const pt = key => wxImg(KINETIC_ASSETS.parts && KINETIC_ASSETS.parts[key]);
    const tCfg = KIN_THEME_CFG[proto.theme] || KIN_THEME_CFG.cyan;
    const ptRingMain = pt(tCfg.ring);
    const ptRingCyan = pt('wx_pt_ring_cyan');
    const ptSparks = tCfg.sparks.map(pt);
    const ptGlint = pt('wx_pt_glint_star'), ptSwordRay = pt('wx_pt_sword_ray');
    const ptRock = pt('wx_pt_rock'), ptSmoke = pt('wx_pt_smoke'), ptIce = pt('wx_pt_ice_shard'), ptPetal = pt('wx_pt_petal');
    const ptGround = proto.ground === 'frost' ? pt('wx_pt_frost_patch')
                   : (proto.ground === 'venom' ? pt('wx_pt_venom_pool')
                   : (proto.ground === 'scorch' ? pt('wx_pt_crater_scorch') : null));

    const cycleMs = proto.cycleMs || 1480;
    let startTs = performance.now();
    const easeOut = t => 1 - Math.pow(1 - Math.max(0, Math.min(1, t)), 3);
    const easeInOut = t => { const k = Math.max(0, Math.min(1, t)); return k * k * (3 - 2 * k); };
    const arch01 = t => { const k = Math.max(0, Math.min(1, t)); return 4 * k * (1 - k); };

    const seedP = [];
    for (let i = 0; i < 34; i++) {
      const a = ((i * 2.39996) % (Math.PI * 2));
      seedP.push({
        ang: a,
        vx: Math.cos(a) * (75 + (i % 7) * 32),
        vy: Math.sin(a) * (60 + (i % 5) * 28) - 42,
        rot0: (i * 47) % 360,
        tq: ((i % 2 === 0 ? 1 : -1) * (140 + (i % 5) * 75)),
        sc: 0.42 + (i % 5) * 0.16,
        life: 0.24 + (i % 4) * 0.08,
        ox: ((i * 19) % 28) - 14,
        oy: ((i * 13) % 24) - 12
      });
    }

    function drawHero(cx, groundY, jumpZ, leanDeg, sx, sy, wpnDeg, armExt, alpha, flipX, tintCss) {
      ctx.save();
      const shScale = Math.max(0.28, 1 - jumpZ / 135);
      ctx.fillStyle = 'rgba(0,0,0,' + (0.48 * shScale * alpha).toFixed(2) + ')';
      ctx.beginPath();
      ctx.ellipse(cx, groundY + 40, 34 * shScale, 11 * shScale, 0, 0, Math.PI * 2);
      ctx.fill();

      ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
      ctx.translate(cx, groundY - jumpZ);
      if (flipX) ctx.scale(-1, 1);
      if (tintCss) ctx.filter = tintCss;

      ctx.save();
      ctx.rotate((leanDeg * Math.PI) / 180);
      ctx.scale(sx, sy);
      if (torsoIm && torsoIm.complete && torsoIm.naturalWidth) ctx.drawImage(torsoIm, -48, -68, 96, 132);
      ctx.save();
      ctx.translate(3, -18);
      ctx.rotate((-leanDeg * 0.42 * Math.PI) / 180);
      ctx.translate(-3, 18);
      if (headIm && headIm.complete && headIm.naturalWidth) ctx.drawImage(headIm, -48, -68, 96, 132);
      ctx.restore();
      if (wpnIm && wpnIm.complete && wpnIm.naturalWidth) {
        ctx.save();
        ctx.translate(18 + armExt, 6);
        ctx.rotate((wpnDeg * Math.PI) / 180);
        const anchorY = wSpec.kind === 'fist' ? -wSpec.h * 0.5 : -wSpec.h * 0.78;
        ctx.drawImage(wpnIm, -wSpec.w * 0.45, anchorY, wSpec.w, wSpec.h);
        ctx.restore();
      }
      ctx.restore();
      ctx.restore();
    }

    function drawParticleBurst(cx, cy, age, imList, count, gravY, fwdBias, maxSc) {
      if (age <= 0) return;
      for (let i = 0; i < count; i++) {
        const sp = seedP[i % seedP.length];
        if (age > sp.life) continue;
        const u = age / sp.life;
        const px = cx + sp.ox + (sp.vx + fwdBias) * age;
        const py = cy + sp.oy + sp.vy * age + 0.5 * gravY * age * age;
        const a = Math.min(1, u * 6) * (1 - u * u);
        const im = imList[i % imList.length];
        if (!im || !im.complete || !im.naturalWidth) continue;
        const sc = sp.sc * maxSc * (1 - u * 0.55);
        const rot = ((sp.rot0 + sp.tq * age) * Math.PI) / 180;
        wxDrawSprite(ctx, im, px, py, im.naturalWidth * sc, im.naturalHeight * sc, rot, a, false);
      }
    }

    function drawRing(im, cx, cy, age, dur, sc0, sc1, maxA) {
      if (!im || age < 0 || age > dur) return;
      const u = age / dur;
      const sc = sc0 + (sc1 - sc0) * easeOut(u);
      const a = Math.sin(u * Math.PI) * maxA;
      wxDrawSprite(ctx, im, cx, cy, 136 * sc, 88 * sc, 0, a, false);
    }

    function step(now) {
      if (!document.getElementById(canvasId)) return;
      const W = cv.width, H = cv.height;
      const spd = isModal ? vfxState.modalSpeed : vfxState.speed;
      const lockF = isModal ? vfxState.modalLockFrame : vfxState.lockFrame;

      let rawP = ((now - startTs) * spd) / cycleMs;
      if (lockF >= 0 && lockF <= 3) {
        rawP = [0.18, 0.42, 0.57, 0.74][lockF];
      } else if (rawP >= 1.0) {
        startTs = now;
        rawP = rawP % 1.0;
      }

      const impP = proto.impactP || 0.52;
      const hitstopLen = (proto.kind === 'stance' || proto.kind === 'qinggong') ? 0.04 : 0.075;
      let p = rawP;
      let inHitstop = false;
      if (lockF < 0) {
        if (rawP >= impP && rawP < impP + hitstopLen) {
          inHitstop = true;
          p = impP + (rawP - impP) * 0.14;
        } else if (rawP >= impP + hitstopLen) {
          p = impP + hitstopLen * 0.14 + (rawP - (impP + hitstopLen)) * ((1 - (impP + hitstopLen * 0.14)) / (1 - (impP + hitstopLen)));
        }
      }

      const groundY = Math.round(H * 0.62);
      const close = vfxState.closeRange;
      const isRanged = proto.kind === 'ranged';
      const isStance = proto.kind === 'stance';
      const isQinggong = proto.kind === 'qinggong';
      const homeX = Math.round(W * (isStance ? 0.48 : (close && !isRanged ? 0.39 : 0.24)));
      const foeHomeX = Math.round(W * (isStance ? 0.78 : (close && !isRanged ? 0.59 : 0.73)));
      const spanX = foeHomeX - homeX;
      const focusX = isStance ? homeX : foeHomeX;

      let hx = homeX, hz = 0, lean = 0, sx = 1, sy = 1, wpnDeg = -22, armExt = 0, heroFlip = false, heroTint = '';
      let bx = foeHomeX, bz = 0, bLean = 0, bFlash = 0;
      let shakeX = 0, shakeY = 0, camZoom = 1.0;
      const clones = [];
      const mo = proto.motion || 'kin_heavy_chop';
      const arch = proto.arch || 'heavy_cleave';

      // === ALL 16 Space-Making Actor Choreographies ===
      if (mo === 'kin_dash_combo3') {
        if (p < 0.20) { const k = easeOut(p / 0.20); hx = homeX - 48 * k; hz = -4 * k; lean = -16 * k; wpnDeg = -22 - 58 * k; }
        else if (p < 0.36) { const k = easeOut((p - 0.20) / 0.16); hx = (homeX - 48) + (spanX * 0.48 + 48) * k; hz = 16 * arch01(k); lean = 18; armExt = 18 * k; wpnDeg = -80 + 165 * k; clones.push({ x: homeX - 24, z: 4, a: 0.42 * (1 - k * 0.4), deg: -62, tint: 'brightness(1.45)' }); if (k > 0.45) { bFlash = 0.55; bx = foeHomeX + 7; bLean = 8; } }
        else if (p < 0.50) { const k = easeOut((p - 0.36) / 0.14); hx = homeX + spanX * 0.48 + 26 * k; hz = -8 * arch01(k); lean = 22; armExt = 20; wpnDeg = 85 - 165 * k; clones.push({ x: homeX + spanX * 0.36, z: 10, a: 0.42, deg: 75, tint: 'brightness(1.5)' }); if (k > 0.40) { bFlash = 0.72; bx = foeHomeX + 11; bLean = 12; } }
        else if (p < 0.64) { const k = easeOut((p - 0.50) / 0.14); hx = (homeX + spanX * 0.48 + 26) + (foeHomeX + 86 - (homeX + spanX * 0.48 + 26)) * k; hz = 8 * arch01(k); lean = 28; armExt = 26; wpnDeg = -80 + 175 * k; clones.push({ x: homeX + spanX * 0.45, z: 6, a: 0.34, deg: 40, tint: 'brightness(1.55)' }, { x: foeHomeX + 14, z: 8, a: 0.46, deg: 85, tint: 'brightness(1.65)' }); }
        else if (p < 0.76) { hx = foeHomeX + 86; lean = 24; armExt = 24; wpnDeg = 96; clones.push({ x: foeHomeX + 24, z: 6, a: 0.34 * (1 - (p - 0.64) / 0.12), deg: 88, tint: 'brightness(1.6)' }); }
        else { const k = easeInOut((p - 0.76) / 0.24); hx = foeHomeX + 86 - (foeHomeX + 86 - homeX) * k; lean = 24 * (1 - k); wpnDeg = 96 - 118 * k; }
      }
      else if (mo === 'kin_dragon_palm') {
        if (p < 0.34) { const k = easeOut(p / 0.34); hx = homeX - 46 * k + Math.sin(p * 110) * 2 * k; sy = 1 - 0.14 * k; sx = 1 + 0.10 * k; lean = -14 * k; wpnDeg = -45 * k; heroTint = 'sepia(0.45) saturate(1.7) brightness(1.18)'; }
        else if (p < 0.52) { const k = easeOut((p - 0.34) / 0.18); hx = (homeX - 46) + 92 * k; lean = -14 + 38 * k; armExt = 26 * k; wpnDeg = -45 + 110 * k; heroTint = 'sepia(0.55) saturate(2.1) brightness(1.26)'; clones.push({ x: hx - 30, z: 4, a: 0.42, deg: 45, tint: 'sepia(0.8) saturate(2.4) brightness(1.35)' }); }
        else if (p < 0.68) { hx = homeX + 46; lean = 24; armExt = 26; wpnDeg = 65; heroTint = 'sepia(0.35) saturate(1.5) brightness(1.14)'; }
        else { const k = easeInOut((p - 0.68) / 0.32); hx = homeX + 46 * (1 - k); lean = 24 * (1 - k); armExt = 26 * (1 - k); wpnDeg = 65 - 87 * k; }
      }
      else if (mo === 'kin_flame_leap') {
        if (p < 0.14) { const k = easeOut(p / 0.14); hx = homeX - 28 * k; sy = 1 - 0.18 * k; sx = 1 + 0.12 * k; lean = -12 * k; wpnDeg = -60 * k; }
        else if (p < 0.38) { const k = easeOut((p - 0.14) / 0.24); hx = homeX - 28 + 20 * k; hz = 82 * k; lean = -16 + 10 * k; wpnDeg = -112; heroTint = 'brightness(1.2) saturate(1.5)'; clones.push({ x: hx - 8, z: Math.max(0, hz - 24), a: 0.38, deg: -112, tint: 'brightness(1.35)' }); }
        else if (p < 0.50) { const k = easeOut((p - 0.38) / 0.12); hx = (homeX - 8) + (spanX * 0.55 + 18) * k; hz = 82 * (1 - k); lean = 28 * k; armExt = 24 * k; wpnDeg = -112 + 225 * k; clones.push({ x: hx - 22, z: hz + 30, a: 0.44, deg: -40, tint: 'brightness(1.4)' }); }
        else if (p < 0.66) { hx = homeX + spanX * 0.55 + 10; hz = 0; lean = 26; armExt = 24; wpnDeg = 113; }
        else { const k = easeInOut((p - 0.66) / 0.34); hx = homeX + (spanX * 0.55 + 10) * (1 - k); lean = 26 * (1 - k); wpnDeg = 113 - 135 * k; }
      }
      else if (mo === 'kin_thunder_slam' || mo === 'kin_heavy_chop') {
        if (p < 0.34) { const k = easeOut(p / 0.34); hx = homeX - 42 * k; hz = 18 * k; lean = -18 * k; wpnDeg = -118 * k; heroTint = 'brightness(1.16)'; }
        else if (p < 0.48) { const k = easeOut((p - 0.34) / 0.14); hx = (homeX - 42) + (spanX * 0.52 + 46) * k; hz = 18 * (1 - k); lean = -18 + 46 * k; armExt = 24 * k; wpnDeg = -118 + 230 * k; clones.push({ x: hx - 24, z: hz + 12, a: 0.40, deg: -50, tint: 'brightness(1.35)' }); }
        else if (p < 0.64) { hx = homeX + spanX * 0.52 + 4; lean = 28; armExt = 24; wpnDeg = 112; }
        else { const k = easeInOut((p - 0.64) / 0.36); hx = homeX + (spanX * 0.52 + 4) * (1 - k); lean = 28 * (1 - k); wpnDeg = 112 - 134 * k; }
      }
      else if (mo === 'kin_celestial_beam') {
        if (p < 0.36) { const k = easeOut(p / 0.36); hx = homeX - 54 * k; hz = 32 * k; lean = -10 * k; wpnDeg = -70 * k; heroTint = 'brightness(1.22)'; clones.push({ x: hx + 20, z: Math.max(0, hz - 8), a: 0.34 * k, deg: -55, tint: 'brightness(1.45)' }); }
        else if (p < 0.50) { const k = easeOut((p - 0.36) / 0.14); hx = (homeX - 54) + 74 * k; hz = 32 - 4 * k; lean = 16 * k; armExt = 28 * k; wpnDeg = 72; }
        else if (p < 0.68) { hx = homeX + 20; hz = 28; lean = 16; armExt = 28; wpnDeg = 72; }
        else { const k = easeInOut((p - 0.68) / 0.32); hx = homeX + 20 * (1 - k); hz = 28 * (1 - k); lean = 16 * (1 - k); wpnDeg = 72 - 94 * k; }
      }
      else if (mo === 'kin_spear_drill') {
        if (p < 0.28) { const k = easeOut(p / 0.28); hx = homeX - 52 * k; lean = -16 * k; wpnDeg = -75 * k; }
        else if (p < 0.48) { const k = easeOut((p - 0.28) / 0.20); hx = (homeX - 52) + (spanX * 0.58 + 52) * k; hz = 10 * arch01(k); lean = 26 * k; armExt = 34 * k; wpnDeg = 78; clones.push({ x: hx - 32, z: 4, a: 0.44, deg: 74, tint: 'brightness(1.45)' }); }
        else if (p < 0.66) { hx = homeX + spanX * 0.58; lean = 26; armExt = 34; wpnDeg = 78; }
        else { const k = easeInOut((p - 0.66) / 0.34); hx = homeX + spanX * 0.58 * (1 - k); lean = 26 * (1 - k); armExt = 34 * (1 - k); wpnDeg = 78 - 100 * k; }
      }
      else if (mo === 'kin_whirl_spin') {
        if (p < 0.18) { const k = easeOut(p / 0.18); hx = homeX - 28 * k; lean = -14 * k; wpnDeg = -85 * k; }
        else if (p < 0.68) {
          const sp = (p - 0.18) / 0.50;
          hx = homeX + spanX * 0.30 * arch01(sp) + Math.cos(sp * Math.PI * 2.5) * 34;
          hz = 18 * arch01(sp);
          heroFlip = Math.sin(sp * Math.PI * 2.5) < 0;
          wpnDeg = -90 + sp * 720; armExt = 22;
          clones.push({ x: hx - 22, z: hz, a: 0.36, deg: wpnDeg - 60, flip: !heroFlip, tint: 'brightness(1.4)' });
        }
        else { const k = easeInOut((p - 0.68) / 0.32); hx = homeX + 18 * (1 - k); wpnDeg = -22; }
      }
      else if (mo === 'kin_shadow_blink') {
        if (p < 0.22) { const k = easeOut(p / 0.22); hx = homeX - 36 * k; sy = 1 - 0.15 * k; lean = -14 * k; heroTint = 'brightness(0.75) contrast(1.25)'; }
        else if (p < 0.46) { const k = easeOut((p - 0.22) / 0.24); hx = (homeX - 36) + (foeHomeX + 86 - (homeX - 36)) * k; hz = 12 * arch01(k); lean = 28; armExt = 24; wpnDeg = 92; clones.push({ x: homeX - 18, z: 2, a: 0.40, deg: -35, tint: 'brightness(0.6) hue-rotate(240deg)' }, { x: foeHomeX - 8, z: 8, a: 0.45, deg: 65, tint: 'brightness(1.45)' }); }
        else if (p < 0.66) { hx = foeHomeX + 86; heroFlip = true; lean = 16; armExt = 22; wpnDeg = 85; }
        else { const k = easeInOut((p - 0.66) / 0.34); hx = foeHomeX + 86 - (foeHomeX + 86 - homeX) * k; lean = 16 * (1 - k); wpnDeg = 85 - 107 * k; }
      }
      else if (mo === 'kin_upcut_launch') {
        if (p < 0.26) { const k = easeOut(p / 0.26); hx = homeX - 32 * k; sy = 1 - 0.18 * k; lean = -14 * k; wpnDeg = 65 * k; }
        else if (p < 0.48) { const k = easeOut((p - 0.26) / 0.22); hx = (homeX - 32) + (spanX * 0.55 + 32) * k; hz = 46 * k; lean = 22 * k; armExt = 24 * k; wpnDeg = 65 - 185 * k; clones.push({ x: hx - 20, z: Math.max(0, hz - 18), a: 0.42, deg: -50, tint: 'brightness(1.4)' }); }
        else if (p < 0.66) { hx = homeX + spanX * 0.55; hz = 46; lean = 20; armExt = 24; wpnDeg = -120; }
        else { const k = easeInOut((p - 0.66) / 0.34); hx = homeX + spanX * 0.55 * (1 - k); hz = 46 * (1 - k); lean = 20 * (1 - k); wpnDeg = -120 + 98 * k; }
      }
      else if (mo === 'kin_whip_snap' || mo === 'kin_bow_draw' || mo === 'kin_throw_fan') {
        if (p < 0.32) { const k = easeOut(p / 0.32); hx = homeX - 44 * k; hz = (mo === 'kin_throw_fan' ? 20 * k : 0); lean = -18 * k; wpnDeg = -80 * k; }
        else if (p < 0.52) { const k = easeOut((p - 0.32) / 0.20); hx = (homeX - 44) + (mo === 'kin_bow_draw' ? 14 : 74) * k; hz = (mo === 'kin_throw_fan' ? 20 * (1 - k * 0.5) : 4 * arch01(k)); lean = -18 + 38 * k; armExt = 26 * k; wpnDeg = -80 + 160 * k; }
        else { const k = easeInOut((p - 0.52) / 0.48); hx = homeX + (mo === 'kin_bow_draw' ? -30 : 30) * (1 - k); lean = 20 * (1 - k); wpnDeg = 80 - 102 * k; }
      }
      else if (mo === 'kin_qg_vault') {
        const k = easeInOut(Math.min(1, p / 0.72));
        hx = homeX + spanX * 0.92 * k;
        hz = 74 * arch01(Math.min(1, p / 0.72));
        lean = 22 * Math.sin(k * Math.PI);
        if (p > 0.14 && p < 0.78) clones.push({ x: hx - 36, z: Math.max(0, hz - 12), a: 0.42, deg: -35, tint: 'brightness(1.45)' }, { x: hx - 68, z: Math.max(0, hz - 24), a: 0.25, deg: -42, tint: 'brightness(1.3)' });
      }
      else if (mo === 'kin_roar_pulse') {
        if (p < 0.30) { const k = easeOut(p / 0.30); sy = 1 - 0.16 * k; sx = 1 + 0.12 * k; lean = -10 * k; }
        else if (p < 0.64) { const sp = (p - 0.30) / 0.34; hz = 24 * arch01(sp); hx = homeX + Math.sin(sp * 50) * 4; lean = 10; heroTint = 'brightness(1.24) saturate(1.4)'; }
        else { const k = 1 - easeInOut((p - 0.64) / 0.36); hz = 6 * k; }
      }
      else {
        // kin_stance_channel
        hz = 24 * arch01(p);
        heroTint = 'brightness(' + (1 + 0.24 * arch01(p)).toFixed(2) + ')';
        wpnDeg = -22 - 38 * arch01(p);
      }

      // Target Hitstop + 5 Bespoke Impact Reactions!
      const postImp = p - impP;
      if (!isStance && !isQinggong && postImp >= 0 && postImp < 0.34) {
        const rk = postImp / 0.34;
        const arc = arch01(rk);
        bFlash = rk < 0.45 ? (1 - rk / 0.45) : 0;
        const rt = proto.react || 'kin_hit_heavy';
        if (rt === 'kin_hit_launch') { bx = foeHomeX + 42 * arc; bz = 44 * arc; bLean = 28 * arc; }
        else if (rt === 'kin_hit_electro') { bx = foeHomeX + 18 * arc + Math.sin(rk * 48) * 11 * arc; bz = 18 * arc; bLean = Math.sin(rk * 42) * 18 * arc; }
        else if (rt === 'kin_hit_frost') { bx = foeHomeX + 20 * arc + Math.sin(rk * 64) * 6 * arc; bz = 14 * arc; bLean = 14 * arc; }
        else if (rt === 'kin_hit_venom') { bx = foeHomeX + 22 * arc; bz = -6 * arc; bLean = -12 * arc + Math.sin(rk * 30) * 8 * arc; }
        else { bx = foeHomeX + 36 * arc; bz = 10 * arc; bLean = 24 * arc; }
        if (postImp < 0.16) {
          const skA = (1 - postImp / 0.16) * ((proto.shakePow || 6) >= 8 ? 10.5 : 7.5);
          shakeX = Math.sin(now * 0.09) * skA;
          shakeY = Math.cos(now * 0.11) * skA * 0.7;
          camZoom = 1.0 + 0.07 * (1 - postImp / 0.16);
        }
      }

      // === RENDER SCENE ===
      ctx.save();
      ctx.clearRect(0, 0, W, H);

      // 1. Tactical Terrain Background
      const bg = ctx.createRadialGradient(W * 0.50, H * 0.58, 16, W * 0.5, H * 0.5, W * 0.76);
      bg.addColorStop(0, '#3a3225'); bg.addColorStop(1, '#14110d');
      ctx.fillStyle = bg; ctx.fillRect(0, 0, W, H);

      // 2. Spotlight Vignette
      const vigA = Math.sin(Math.min(1, p * 1.12) * Math.PI) * 0.58;
      const vig = ctx.createRadialGradient(W * 0.50, H * 0.54, W * 0.16, W * 0.5, H * 0.5, W * 0.68);
      vig.addColorStop(0, 'rgba(0,0,0,0)');
      vig.addColorStop(1, tCfg.vig + (vigA * 1.15).toFixed(2) + ')');
      ctx.fillStyle = vig; ctx.fillRect(0, 0, W, H);

      ctx.translate(W * 0.5 + shakeX, H * 0.5 + shakeY);
      ctx.scale(camZoom, camZoom);
      ctx.translate(-W * 0.5, -H * 0.5);

      // 3. Battle Brothers Hex Grid
      const hexStep = (close && !isRanged && !isStance) ? spanX : Math.round(Math.max(88, spanX / 2.2));
      for (let hi = -2; hi <= 3; hi++) {
        const cx = homeX + hi * hexStep;
        if (cx < -30 || cx > W + 30) continue;
        const isHeroHex = hi === 0;
        const isFoeHex = !isStance && ((close && !isRanged) ? (hi === 1) : (hi === 2));
        const stroke = isHeroHex ? 'rgba(136,202,126,0.52)' : (isFoeHex ? 'rgba(226,96,76,0.56)' : 'rgba(154,132,96,0.22)');
        const fill = isHeroHex ? 'rgba(48,78,44,0.24)' : (isFoeHex ? 'rgba(98,36,28,0.24)' : 'rgba(38,31,22,0.16)');
        wxDrawHex(ctx, cx, groundY + 40, 46, 17, stroke, fill);
      }

      // 4. Lingering Ground Aftermath (Scorch Crater / Frost Rime / Venom Pool)
      if (ptGround && postImp >= 0) {
        const scA = Math.min(1, postImp * 14) * Math.max(0, 1 - Math.max(0, postImp - 0.22) * 2.1);
        wxDrawSprite(ctx, ptGround, focusX, groundY + 34, 152, 98, 0, scA * 0.92, false);
      }

      // 5. Windup Contracting Qi Rings & Glints
      if (p < 0.34) {
        const wx0 = (arch === 'thunder_slam') ? focusX : hx;
        drawRing(ptRingMain, wx0, groundY + 24, p, 0.30, 1.55, 0.26, 0.90);
        if (arch === 'celestial_beam' || arch === 'sword_combo3' || arch === 'shadow_cross') {
          wxDrawSprite(ctx, ptGlint, hx + 4, groundY - 18, 76, 76, p * 9, Math.sin((p / 0.34) * Math.PI), false);
        }
        if (arch === 'celestial_beam' && p > 0.12) {
          const fk = (p - 0.12) / 0.22;
          wxDrawSprite(ctx, ptSwordRay, hx + 18 + fk * spanX * 0.85, groundY - 40, 92, 30, 0, Math.sin(fk * Math.PI), false);
          wxDrawSprite(ctx, ptSwordRay, hx + 6 + fk * spanX * 0.75, groundY - 12, 82, 26, -0.1, Math.sin(fk * Math.PI), false);
        }
        if (arch === 'qinggong_gust' || arch === 'snow_step' || arch === 'warp_seal') {
          wxDrawKineticFrame(ctx, proto.seq, (p / 0.34) * (KINETIC_ASSETS.meta[proto.seq]?.count || 10), homeX, groundY - 8, 1.05, 0, 0.92, false, proto.tint);
        }
      }

      // 6. Enemy Bust + Hit-Flash (hidden only on pure self-stance or pure qinggong leap)
      if (!isStance && !isQinggong && oppIm && oppIm.complete && oppIm.naturalWidth) {
        const shS = Math.max(0.32, 1 - bz / 120);
        ctx.fillStyle = 'rgba(0,0,0,' + (0.46 * shS).toFixed(2) + ')';
        ctx.beginPath(); ctx.ellipse(bx, groundY + 40, 35 * shS, 11 * shS, 0, 0, Math.PI * 2); ctx.fill();
        ctx.save();
        ctx.translate(bx, groundY - bz);
        ctx.rotate((bLean * Math.PI) / 180);
        if (bFlash > 0.04) {
          const hitFilter = proto.react === 'kin_hit_frost' ? 'hue-rotate(155deg) brightness(' + (1 + bFlash * 1.6).toFixed(2) + ')'
                          : (proto.react === 'kin_hit_venom' ? 'hue-rotate(80deg) brightness(' + (1 + bFlash * 1.4).toFixed(2) + ')'
                          : 'brightness(' + (1 + bFlash * 2.1).toFixed(2) + ') contrast(1.12)');
          ctx.filter = hitFilter;
        }
        ctx.scale(-1, 1);
        ctx.drawImage(oppIm, -48, -68, 96, 132);
        ctx.restore();
      }

      // 7. Hero Afterimages + Articulated Hero
      clones.forEach(c => drawHero(c.x, groundY, c.z || 0, 18, 1, 1, c.deg !== undefined ? c.deg : wpnDeg, 14, c.a, !!c.flip, c.tint));
      drawHero(hx, groundY, hz, lean, sx, sy, wpnDeg, armExt, 1.0, heroFlip, heroTint);

      // 8. TRUE MULTI-FRAME KINETIC ANIMATIONS (All 22 Archetypes + Secondary Layers!)
      const seqMeta = KINETIC_ASSETS.meta[proto.seq] || { count: 10 };
      const seqCnt = seqMeta.count || 10;
      const tint = proto.tint;

      if (arch === 'sword_combo3') {
        if (p >= 0.18 && p <= 0.44) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.18) / 0.26) * seqCnt, foeHomeX - 8, groundY - 12, 0.96, 0.46, 0.95, false, tint);
        if (p >= 0.34 && p <= 0.60) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.34) / 0.26) * seqCnt, foeHomeX + 4, groundY - 4, 1.04, -0.42, 0.96, true, tint);
        if (p >= 0.50 && p <= 0.84) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.50) / 0.34) * seqCnt, foeHomeX + 14, groundY - 10, 1.22, 0.02, 1.0, false, tint);
      }
      else if (arch === 'dragon_surge') {
        if (p >= 0.30 && p <= 0.88) { const u = (p - 0.30) / 0.58; wxDrawKineticFrame(ctx, proto.seq, u * seqCnt, homeX + spanX * 0.56 + u * 64, groundY - 8, 1.24, 0, 1.0, false, tint); }
      }
      else if (arch === 'flame_leap') {
        if (p >= 0.32 && p <= 0.68) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.32) / 0.36) * seqCnt, focusX - 8, groundY - 26, 1.15, 0, 1.0, false, tint);
        if (proto.seq2 && p >= 0.46 && p <= 0.92) wxDrawKineticFrame(ctx, proto.seq2, ((p - 0.46) / 0.46) * (KINETIC_ASSETS.meta[proto.seq2]?.count || 10), focusX, groundY - 52, 1.14, 0, 1.0, false, tint);
      }
      else if (arch === 'thunder_slam') {
        if (p >= 0.30 && p <= 0.88) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.30) / 0.58) * seqCnt, focusX, groundY - 72, 1.08, 0, 1.0, false, tint);
      }
      else if (arch === 'celestial_beam') {
        if (p >= 0.32 && p <= 0.88) { const u = (p - 0.32) / 0.56; wxDrawKineticFrame(ctx, proto.seq, u * seqCnt, homeX + spanX * 0.68 + u * 26, groundY - 18, 1.28, 0, 1.0, false, tint); }
      }
      else if (arch === 'spear_drill' || arch === 'whip_lash' || arch === 'arrow_barrage' || arch === 'phoenix_spear' || arch === 'flying_knives' || arch === 'peacock_fan' || arch === 'fist_flurry' || arch === 'tidal_wave') {
        if (p >= 0.26 && p <= 0.86) { const u = (p - 0.26) / 0.60; wxDrawKineticFrame(ctx, proto.seq, u * seqCnt, homeX + spanX * 0.56 + u * 30, groundY - 12, 1.22, 0, 1.0, false, tint); }
      }
      else if (arch === 'whirl_cyclone' || arch === 'bamboo_bind') {
        if (p >= 0.22 && p <= 0.86) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.22) / 0.64) * seqCnt, homeX + spanX * 0.48, groundY - 6, 1.30, 0, 0.98, false, tint);
      }
      else if (isQinggong) {
        if (p >= 0.46 && p <= 0.94) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.46) / 0.48) * seqCnt, foeHomeX, groundY - 10, 1.18, 0, 0.98, false, tint);
      }
      else if (arch === 'buddha_palm' || arch === 'war_banner' || arch === 'sword_rain') {
        if (p >= 0.24 && p <= 0.88) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.24) / 0.64) * seqCnt, focusX, groundY - 40, 1.20, 0, 1.0, false, tint);
      }
      else if (arch === 'frost_burst' || arch === 'venom_mire' || arch === 'earth_shatter' || arch === 'cannon_blast' || arch === 'smoke_cloud') {
        if (p >= 0.26 && p <= 0.88) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.26) / 0.62) * seqCnt, focusX, groundY - 22, 1.18, 0, 1.0, false, tint);
      }
      else if (arch === 'golden_dome' || arch === 'taiji_seal' || arch === 'soul_vortex' || arch === 'sonic_wave' || arch === 'lotus_poke' || arch === 'xuanwu_aegis' || arch === 'gold_needles' || arch === 'snow_step' || arch === 'warp_seal' || arch === 'prism_burst') {
        if (p >= 0.20 && p <= 0.88) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.20) / 0.68) * seqCnt, focusX, groundY - 16, 1.22, 0, 0.98, false, tint);
      }
      else {
        // blood_cleave, heavy_cleave, giant_axe, moon_crescent, claw_rend, shadow_cross
        if (p >= 0.26 && p <= 0.86) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.26) / 0.60) * seqCnt, focusX - 4, groundY - 14, 1.20, 0, 1.0, false, tint);
      }

      // Secondary Hybrid Sequence (`proto.seq2`)!
      if (proto.seq2 && arch !== 'flame_leap' && p >= 0.44 && p <= 0.92) {
        const s2Cnt = KINETIC_ASSETS.meta[proto.seq2]?.count || 10;
        const s2Y = proto.seq2 === 'wx_kin_flame_pillar' ? groundY - 52 : (proto.seq2 === 'wx_kin_thunder_bolt' ? groundY - 72 : groundY - 18);
        wxDrawKineticFrame(ctx, proto.seq2, ((p - 0.44) / 0.48) * s2Cnt, focusX + 4, s2Y, 1.12, 0, 0.92, false, tint);
      }

      // 9. EXACT-FRAME IMPACT CLIMAX (Shockwave Rings + 26..32 Physics Particles + Screen Flash!)
      if (postImp >= 0) {
        const ageSec = postImp * (cycleMs / 1000.0);
        const burstX = isQinggong ? foeHomeX : focusX;
        drawRing(ptRingMain, burstX, groundY + 20, ageSec, 0.38, 0.26, 2.25, 0.98);
        if ((proto.shakePow || 6) >= 7 || proto.theme === 'celestial') {
          drawRing(proto.theme === 'celestial' ? ptRingCyan : ptRingMain, burstX + 18, groundY + 10, ageSec - 0.06, 0.34, 0.26, 1.80, 0.84);
        }
        const gravY = (proto.theme === 'fire' || isStance || isQinggong) ? -85 : ((arch === 'thunder_slam' || arch === 'earth_shatter') ? 250 : 140);
        const burstList = (arch === 'thunder_slam' || arch === 'earth_shatter') ? [...ptSparks, ptRock, ptSmoke]
                        : (proto.theme === 'frost' ? [...ptSparks, ptIce]
                        : (proto.theme === 'jade' ? [...ptSparks, ptPetal] : ptSparks));
        drawParticleBurst(burstX, groundY - 10, ageSec, burstList, 28, gravY, isStance ? 0 : 120, 0.92);

        if (arch === 'celestial_beam' || arch === 'shadow_cross') {
          wxDrawSprite(ctx, ptGlint, burstX, groundY - 16, 114 * (1 + ageSec), 114 * (1 + ageSec), ageSec * 4, Math.max(0, 1 - ageSec * 3.8), false);
        }

        if (postImp < 0.20) {
          const fl = 1 - postImp / 0.20;
          wxDrawSpeedLines(ctx, W, H, proto.col, fl * 1.45);
          if (proto.theme === 'violet' || proto.theme === 'celestial' || proto.theme === 'crimson' || proto.theme === 'frost') {
            ctx.save();
            ctx.fillStyle = tCfg.flash + (fl * 0.24).toFixed(2) + ')';
            ctx.fillRect(0, 0, W, H);
            if (arch === 'celestial_beam') {
              ctx.strokeStyle = `rgba(255,252,232,${(fl * 0.92).toFixed(2)})`;
              ctx.lineWidth = Math.max(1.5, 8 * fl * fl);
              ctx.beginPath(); ctx.moveTo(0, groundY - 18); ctx.lineTo(W, groundY - 18); ctx.stroke();
            }
            ctx.restore();
          }
        }

        if (postImp < 0.40) {
          const pk = postImp / 0.40;
          const dmgVal = 58 + ((sk.ap * 13 + sk.qi * 3) % 74);
          const dmgTxt = isQinggong ? ('轻功腾挪 · 脱围!')
                       : isStance ? ('+' + proto.title)
                       : proto.kind === 'util' ? (proto.seal + ' · 真气运转!')
                       : ('-' + dmgVal + ' · ' + proto.seal + '破敌!');
          ctx.save();
          ctx.globalAlpha = Math.min(1, (1 - pk) * 2.4);
          ctx.textAlign = 'center';
          ctx.font = 'bold 16px Georgia, serif';
          ctx.strokeStyle = '#0d0906'; ctx.lineWidth = 4;
          ctx.strokeText(dmgTxt, isStance ? hx : bx, 58 - pk * 22);
          ctx.fillStyle = proto.core;
          ctx.fillText(dmgTxt, isStance ? hx : bx, 58 - pk * 22);
          ctx.restore();
        }
      }

      ctx.restore();

      // 10. Non-Blocking Sleek Wuxia Ink-Calligraphy Cut-In Ribbon (top-left, mirrors live in-game UI!)
      const bIn = easeOut(Math.min(1, p / 0.14));
      const bOut = p > 0.78 ? (1 - (p - 0.78) / 0.22) : 1;
      const bAlpha = bIn * bOut;
      if (bAlpha > 0.02) {
        const slideX = (1 - bIn) * -36 + (1 - bOut) * 18;
        ctx.save();
        ctx.globalAlpha = bAlpha;
        ctx.translate(10 + slideX, 10);
        const bw = 224, bh = 42;
        const gB = ctx.createLinearGradient(0, 0, bw, 0);
        gB.addColorStop(0, 'rgba(10,12,16,0.92)');
        gB.addColorStop(0.78, 'rgba(18,20,26,0.82)');
        gB.addColorStop(1, 'rgba(18,20,26,0)');
        ctx.fillStyle = gB;
        ctx.beginPath();
        ctx.moveTo(6, 0); ctx.lineTo(bw, 0); ctx.lineTo(bw - 10, bh); ctx.lineTo(0, bh); ctx.closePath();
        ctx.fill();
        ctx.fillStyle = proto.col;
        ctx.fillRect(3, 0, 3.5, bh);
        if (headIm && headIm.complete && headIm.naturalWidth && torsoIm && torsoIm.complete && torsoIm.naturalWidth) {
          ctx.save();
          ctx.beginPath(); ctx.rect(11, 4, 34, 34); ctx.clip();
          ctx.fillStyle = '#181410'; ctx.fillRect(11, 4, 34, 34);
          ctx.drawImage(torsoIm, 5, -2, 46, 62);
          ctx.drawImage(headIm, 5, -2, 46, 62);
          ctx.strokeStyle = proto.col; ctx.lineWidth = 1; ctx.strokeRect(11, 4, 34, 34);
          ctx.restore();
        }
        ctx.font = 'bold 14px "STKaiti", "KaiTi", "Microsoft YaHei UI", serif';
        ctx.fillStyle = proto.core;
        ctx.textAlign = 'left';
        ctx.fillText(proto.title, 52, 21);
        ctx.font = '10px "Microsoft YaHei UI", sans-serif';
        ctx.fillStyle = '#c8bfa6';
        ctx.fillText((proto.sub || '').slice(0, 12), 52, 35);
        ctx.save();
        ctx.translate(184, 20); ctx.rotate(-0.06);
        ctx.fillStyle = 'rgba(132,18,12,0.86)'; ctx.fillRect(-16, -10, 32, 20);
        ctx.strokeStyle = '#e03c2a'; ctx.lineWidth = 1.4; ctx.strokeRect(-16, -10, 32, 20);
        ctx.font = 'bold 10.5px serif'; ctx.fillStyle = '#ffe8dc'; ctx.textAlign = 'center';
        ctx.fillText(proto.seal, 0, 4);
        ctx.restore();
        ctx.restore();
      }

      // Status Pill top-right
      ctx.save();
      ctx.font = '11px "Microsoft YaHei UI", sans-serif';
      const stTxt = (isStance ? '周身真罡' : (isRanged ? '远程齐射' : (close ? '实战贴身1格' : '远距视角'))) + (inHitstop ? ' · ⚡顿帧卡肉!' : ' · 新版逐帧动效');
      const stw = ctx.measureText(stTxt).width + 16;
      ctx.fillStyle = inHitstop ? 'rgba(150,36,20,0.88)' : 'rgba(12,10,8,0.72)';
      ctx.fillRect(W - stw - 8, 8, stw, 20);
      ctx.strokeStyle = inHitstop ? '#ffe078' : 'rgba(200,165,105,0.45)';
      ctx.lineWidth = 1; ctx.strokeRect(W - stw - 8, 8, stw, 20);
      ctx.fillStyle = inHitstop ? '#fff6d0' : '#dec9a4';
      ctx.textAlign = 'right'; ctx.fillText(stTxt, W - 16, 22);
      ctx.restore();

      const nextId = requestAnimationFrame(step);
      if (isModal) vfxState.modalRaf = nextId; else vfxState.stageRaf = nextId;
    }

    const initId = requestAnimationFrame(step);
    if (isModal) vfxState.modalRaf = initId; else vfxState.stageRaf = initId;
  }

  function startSkillVfxCanvas(canvasId, sk, isModal) {
    if (sk && KINETIC_PROTOS[sk.id] && !vfxState.useLegacyCompare && KINETIC_ASSETS.strips && KINETIC_ASSETS.strips[KINETIC_PROTOS[sk.id].seq]) {
      startKineticProtoCanvas(canvasId, sk, KINETIC_PROTOS[sk.id], isModal);
      return;
    }
    const cv = document.getElementById(canvasId);
    if (!cv || typeof cv.getContext !== 'function' || !sk || !sk.choreo) return;
    const ctx = cv.getContext('2d');
    if (!ctx) return;

    if (isModal) stopModalVfx(); else stopStageVfx();

    const ch = sk.choreo;
    const mode = ch.mode || 'crescent';
    const col = ch.color || '#ffd070';
    const fam = ch.fam || 'fist';
    const volleys = Math.max(1, ch.volleys || 1);
    const shakeAmp = Math.max(4, Math.min(16, ch.shake || 8));

    const stripIm = wxImg(VFX_ASSETS.strips[ch.anim]);
    const vfxIm = wxImg(VFX_ASSETS.vfx[ch.vfx]);
    const sigIm = wxImg(VFX_ASSETS.fx[ch.sig]);
    const rigObj = VFX_ASSETS.rigs[wxPickRigKey(sk)] || VFX_ASSETS.rigs.swordsman || {};
    const torsoIm = wxImg(rigObj.torso);
    const headIm = wxImg(rigObj.head);
    const wSpec = wxPickWeaponSpec(sk);
    const wpnIm = wSpec.wKey ? wxImg(VFX_ASSETS.weapons[wSpec.wKey]) : null;
    const shdIm = (wSpec.kind === 'shield' || (sk.key || '').includes('xuanwu')) ? wxImg(VFX_ASSETS.weapons.shd_12) : null;
    const oppIm = wxImg(VFX_ASSETS.enemies[fam] || VFX_ASSETS.enemies.fist);

    const fxBagua = wxImg(VFX_ASSETS.fx.wx_fx_bagua);
    const fxEarth = wxImg(VFX_ASSETS.fx.wx_fx_earth_fissure);
    const fxSword = wxImg(VFX_ASSETS.fx.wx_fx_sword_phantom);
    const fxDragon = wxImg(VFX_ASSETS.fx.wx_fx_dragon_head);
    const fxSonic = wxImg(VFX_ASSETS.fx.wx_fx_sonic_ring);
    const fxBell = wxImg(VFX_ASSETS.fx.wx_fx_golden_bell);
    const fxBanner = wxImg(VFX_ASSETS.fx.wx_fx_banner_crest);
    const fxNeedle = wxImg(VFX_ASSETS.fx.wx_fx_gold_needle);
    const fxThunder = wxImg(VFX_ASSETS.fx.wx_fx_thunder_bolt);
    const fxPalm = wxImg(VFX_ASSETS.fx.wx_fx_buddha_palm);
    const fxClaw = wxImg(VFX_ASSETS.fx.wx_fx_claw_slash);
    const fxIce = wxImg(VFX_ASSETS.fx.wx_fx_ice_spikes);
    const fxBlood = wxImg(VFX_ASSETS.fx.wx_fx_blood_orb);
    const fxPoison = wxImg(VFX_ASSETS.fx.wx_fx_poison_skull);
    const fxLotus = wxImg(VFX_ASSETS.fx.wx_fx_lotus_seal);

    const projIm = (wSpec.kind === 'gun' || mode === 'earth_huolong' || mode === 'aoe_leihuo')
      ? wxImg(VFX_ASSETS.projs.wx_proj_pilileihuo)
      : (wSpec.kind === 'bow')
        ? wxImg(VFX_ASSETS.projs.wx_proj_liuxingjian)
        : (mode.includes('kongque'))
          ? wxImg(VFX_ASSETS.projs.wx_proj_kongqueling)
          : (mode.includes('needle') || mode.includes('jinzhen'))
            ? wxImg(VFX_ASSETS.projs.wx_proj_lihuazhen)
            : wxImg(VFX_ASSETS.projs.wx_proj_liuyefeidao);

    const isStance = mode.startsWith('stance_') || ['lotus_breath', 'blood_flame', 'golden_bell', 'war_banner', 'heal_needles', 'poise_draw', 'hex_fortress'].includes(mode);
    const isStep = mode.startsWith('step_') || ['cloud_jump', 'mirage_step'].includes(mode);
    const isSelfOrMove = isStance || isStep || mode === 'smoke_screen';
    const isRangedWeapon = ['bow', 'throw', 'gun'].includes(wSpec.kind) || (sk.minRange >= 2 && sk.maxRange >= 3 && !isSelfOrMove);

    const cycleMs = 1820;
    let startTs = performance.now();

    function drawHero(cx, groundY, jumpZ, leanDeg, sx, sy, wpnDeg, armExt, alpha, flipX) {
      ctx.save();
      const shScale = Math.max(0.32, 1 - jumpZ / 135);
      ctx.fillStyle = 'rgba(0,0,0,' + (0.46 * shScale * alpha).toFixed(2) + ')';
      ctx.beginPath();
      ctx.ellipse(cx, groundY + 40, 34 * shScale, 11 * shScale, 0, 0, Math.PI * 2);
      ctx.fill();

      ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
      ctx.translate(cx, groundY - jumpZ);
      if (flipX) ctx.scale(-1, 1);

      ctx.save();
      ctx.rotate((leanDeg * Math.PI) / 180);
      ctx.scale(sx, sy);

      if (torsoIm && torsoIm.complete && torsoIm.naturalWidth) {
        ctx.drawImage(torsoIm, -48, -68, 96, 132);
      }

      ctx.save();
      ctx.translate(3, -18);
      ctx.rotate((-leanDeg * 0.42 * Math.PI) / 180);
      ctx.translate(-3, 18);
      if (headIm && headIm.complete && headIm.naturalWidth) {
        ctx.drawImage(headIm, -48, -68, 96, 132);
      }
      ctx.restore();

      if (shdIm && shdIm.complete && shdIm.naturalWidth) {
        ctx.drawImage(shdIm, -42 + armExt * 0.35, -24, 52, 64);
      }

      if (wpnIm && wpnIm.complete && wpnIm.naturalWidth && wSpec.kind !== 'throw') {
        ctx.save();
        ctx.translate(18 + armExt, 6);
        ctx.rotate((wpnDeg * Math.PI) / 180);
        const anchorY = (wSpec.kind === 'fist' || wSpec.kind === 'shield' || wSpec.kind === 'bow' || wSpec.kind === 'gun') ? -wSpec.h * 0.5 : -wSpec.h * 0.78;
        ctx.drawImage(wpnIm, -wSpec.w * 0.45, anchorY, wSpec.w, wSpec.h);
        ctx.restore();
      }
      ctx.restore();
      ctx.restore();
    }

    function step(now) {
      if (!document.getElementById(canvasId)) return;
      const W = cv.width, H = cv.height;
      const spd = isModal ? vfxState.modalSpeed : vfxState.speed;
      const lockF = isModal ? vfxState.modalLockFrame : vfxState.lockFrame;

      let rawP = ((now - startTs) * spd) / cycleMs;
      if (lockF >= 0 && lockF <= 3) {
        rawP = [0.15, 0.42, 0.58, 0.84][lockF];
      } else if (rawP >= 1.0) {
        startTs = now;
        rawP = rawP % 1.0;
      }

      // Crisp Action-RPG Hit-Stop around impact (`0.49..0.55`)
      let p = rawP;
      if (!isSelfOrMove && lockF < 0) {
        if (rawP > 0.49 && rawP < 0.55) p = 0.49 + (rawP - 0.49) * 0.18;
        else if (rawP >= 0.55) p = 0.5008 + (rawP - 0.55) * (0.4992 / 0.45);
      }

      const groundY = Math.round(H * 0.58);
      const closeOld = vfxState.closeRange && KINETIC_PROTOS[sk.id];
      const homeX = Math.round(W * (closeOld ? 0.39 : 0.23)), foeHomeX = Math.round(W * (closeOld ? 0.59 : 0.76));
      const spanX = foeHomeX - homeX;
      let hx = homeX, hz = 0, lean = 0, sx = 1, sy = 1, wpnDeg = -22, armExt = 0, heroFlip = false;
      let bx = foeHomeX, bz = 0, bLean = 0, bFlash = 0, shakeX = 0, shakeY = 0, camZoom = 1.0;
      const clones = [], slashArcs = [], popups = [], projectiles = [];
      let customSigDrawn = false;

      const easeOut = t => 1 - Math.pow(1 - Math.max(0, Math.min(1, t)), 3);
      const hitWindow = (p >= 0.48 && p <= 0.80);
      const hk = hitWindow ? (p - 0.48) / 0.32 : 0;

      // === Full 171-Skill Choreography Kinematics ===
      if (mode === 'counter') {
        if (p < 0.38) {
          const k = easeOut(p / 0.38);
          bx = foeHomeX - k * (spanX * 0.68); bLean = -14 * k;
          hx = homeX + k * 14; wpnDeg = -22 - k * 35;
        } else if (p < 0.68) {
          const k = (p - 0.38) / 0.30;
          bx = (foeHomeX - spanX * 0.68) + easeOut(k) * (spanX * 0.72); bLean = 18 * Math.sin(k * Math.PI); bFlash = Math.max(0, 1 - k * 1.8);
          hx = homeX + 14 + Math.sin(k * Math.PI) * 34; lean = 16; wpnDeg = -57 + easeOut(k) * 155; armExt = 18;
          slashArcs.push({ x: hx + 28, y: groundY - 8, rO: 84, rI: 52, a0: -1.3, a1: 1.2, a: 1 - k });
          shakeX = (Math.random() - 0.5) * shakeAmp * (1 - k);
          popups.push({ x: bx, y: 52 - k * 14, txt: '卸劲反斩!', a: 1 - k, col: '#ffe58f' });
        } else {
          const k = (p - 0.68) / 0.32;
          hx = homeX + (1 - k) * 14; wpnDeg = 98 - k * 120;
        }
      }
      else if (mode === 'backstab' || mode.startsWith('shadow_')) {
        if (p < 0.24) {
          lean = 14 * (p / 0.24); sy = 1 - 0.12 * (p / 0.24);
        } else if (p < 0.75) {
          const k = (p - 0.24) / 0.51;
          hx = foeHomeX + 56; heroFlip = true; lean = 18;
          wpnDeg = -75 + easeOut(Math.min(1, k * 2.2)) * 165; armExt = 20;
          clones.push({ x: homeX, z: 0, a: Math.max(0, 0.46 - k), deg: -25 });
          if (k > 0.30) {
            const ik = (k - 0.30) / 0.70;
            bFlash = Math.max(0, 1 - ik * 1.9);
            bx = foeHomeX - Math.sin(ik * Math.PI) * 18;
            bLean = -16 * (1 - ik);
            slashArcs.push({ x: foeHomeX, y: groundY - 12, rO: 82, rI: 54, a0: 2.05, a1: 4.35, a: Math.max(0, 1 - ik * 1.8) });
            shakeX = (Math.random() - 0.5) * shakeAmp; camZoom = 1.09;
          }
        } else {
          const k = (p - 0.75) / 0.25;
          hx = (foeHomeX + 56) - easeOut(k) * (foeHomeX + 56 - homeX);
        }
      }
      else if (mode === 'clone3') {
        if (p < 0.24) {
          lean = -10 * (p / 0.24); wpnDeg = -55;
        } else if (p < 0.76) {
          const k = (p - 0.24) / 0.52;
          const e = easeOut(Math.min(1, k * 1.8));
          hx = homeX + e * (spanX * 0.74); lean = 20; wpnDeg = -60 + e * 150; armExt = 18;
          clones.push(
            { x: homeX + e * (spanX * 0.85), z: 66 * Math.sin(e * Math.PI * 0.8), a: 0.72, deg: 115, flip: false },
            { x: foeHomeX + 58 - e * 12, z: 8, a: 0.72, deg: 85, flip: true }
          );
          if (k > 0.35) {
            bFlash = Math.max(0, 1 - (k - 0.35) * 2.2); bx = foeHomeX + (Math.random() - 0.5) * 14;
            shakeX = (Math.random() - 0.5) * shakeAmp; camZoom = 1.09;
          }
        } else {
          hx = homeX + (1 - (p - 0.76) / 0.24) * (spanX * 0.74);
        }
      }
      else if (mode === 'flurry_wanjian') {
        // 万剑归宗: Sword saint levitates & commands a 12-sword celestial barrage!
        if (p < 0.26) {
          const k = easeOut(p / 0.26);
          hz = k * 34; wpnDeg = -22 - k * 88;
        } else if (p < 0.82) {
          const k = (p - 0.26) / 0.56;
          hz = 34 + Math.sin(k * Math.PI * 2) * 6;
          lean = 12; armExt = 20; wpnDeg = -110 + easeOut(Math.min(1, k * 2)) * 165;
          for (let si = 0; si < 11; si++) {
            const skp = k * 1.65 - si * 0.065;
            if (skp > 0 && skp < 1) {
              const sx0 = homeX + 20 + skp * (spanX + 16) + ((si % 3) - 1) * 18;
              const sy0 = 10 + (si % 4) * 16 + skp * (groundY - 12);
              projectiles.push({ im: fxSword, x: sx0, y: sy0, w: 80, h: 52, rot: -0.65, flip: true, a: Math.min(1, (1 - skp) * 2.6) });
            }
          }
          if (k > 0.28) {
            const sub = (k * 5) % 1;
            bx = foeHomeX + Math.sin(k * 24) * 14; bFlash = 0.82; bLean = 18;
            shakeX = (Math.random() - 0.5) * shakeAmp; camZoom = 1.10;
            popups.push({ x: bx + ((Math.floor(k * 5) % 3) - 1) * 18, y: 50 - sub * 18, txt: '-' + (26 + Math.floor(k * 5) * 6), a: Math.sin(sub * Math.PI), col });
          }
          customSigDrawn = true;
        } else {
          const k = (p - 0.82) / 0.18;
          hz = 34 * (1 - k); wpnDeg = 55 - k * 77;
        }
      }
      else if (mode.startsWith('flurry_') && isRangedWeapon) {
        // Ranged Multi-Volley (`九星连珠`, `诸葛连弩`, `柳叶飞刀`, `孔雀翎`)
        const shots = Math.max(4, volleys);
        if (p < 0.20) {
          const k = p / 0.20;
          hx = homeX - k * 8; lean = -8 * k; wpnDeg = 42 * k;
        } else if (p < 0.82) {
          const k = (p - 0.20) / 0.62;
          const sub = (k * shots) % 1;
          const sIdx = Math.floor(k * shots);
          hx = homeX + 10 - Math.sin(sub * Math.PI) * 6;
          lean = 8; armExt = 18; wpnDeg = 52 - Math.sin(sub * Math.PI) * 10;
          for (let pi = 0; pi < shots + 2; pi++) {
            const tk = k * 1.55 - pi * (0.55 / shots);
            if (tk > 0 && tk < 1) {
              const spread = ((pi % 5) - 2) * (mode === 'flurry_kongque' ? 12 : 7);
              const px = (homeX + 36) + tk * (spanX - 24);
              const py = (groundY - 18) + spread * tk - Math.sin(tk * Math.PI) * 16;
              projectiles.push({ im: projIm, x: px, y: py, w: 46, h: 46, rot: Math.PI / 2, flip: false, a: 1 });
            }
          }
          if (k > 0.22) {
            bx = foeHomeX + Math.sin(sub * Math.PI) * 14; bFlash = Math.sin(sub * Math.PI) * 0.9; bLean = 14;
            popups.push({ x: bx + ((sIdx % 3) - 1) * 16, y: 52 - sub * 18, txt: '-' + (22 + sIdx * 5), a: Math.sin(sub * Math.PI), col });
            shakeX = (Math.random() - 0.5) * (shakeAmp * 0.75);
          }
        } else {
          hx = homeX + (1 - (p - 0.82) / 0.18) * 10;
        }
      }
      else if (['combo3', 'omnislash6', 'rapid_jab', 'prism5_hit', 'silver_tiger_spear'].includes(mode) || mode.startsWith('flurry_')) {
        const hits = mode === 'omnislash6' ? 6 : (mode === 'prism5_hit' ? 5 : (mode === 'rapid_jab' ? 2 : Math.max(3, volleys)));
        if (p < 0.18) {
          lean = -12 * (p / 0.18); hx = homeX - 8 * (p / 0.18); wpnDeg = -65;
        } else if (p < 0.78) {
          const k = (p - 0.18) / 0.60;
          const sub = (k * hits) % 1;
          const stepIdx = Math.floor(k * hits);
          hx = homeX + spanX * 0.66 + (stepIdx % 2 === 0 ? 12 : -6);
          hz = (stepIdx % 3 === 2) ? Math.sin(sub * Math.PI) * 22 : 0;
          lean = 18 + (stepIdx % 2 === 0 ? 6 : -4);
          armExt = 14 + Math.sin(sub * Math.PI) * 18;
          wpnDeg = (stepIdx % 2 === 0) ? (-75 + sub * 165) : (95 - sub * 165);
          clones.push({ x: hx - 26, z: hz, a: 0.28, deg: wpnDeg - 24 });
          bx = foeHomeX + Math.sin(sub * Math.PI) * 15;
          bLean = 15 * Math.sin(sub * Math.PI);
          bFlash = Math.sin(sub * Math.PI) * 0.92;
          const arcCols = mode === 'prism5_hit' ? ['#ff4545', '#ffd24c', '#52f296', '#4dc8ff', '#d45cff'] : [col];
          const cPick = arcCols[stepIdx % arcCols.length];
          if (wSpec.kind !== 'fist') {
            slashArcs.push({ x: bx - 18, y: groundY - 12, rO: 86, rI: 56, a0: -1.4 + stepIdx * 0.7, a1: 1.3 + stepIdx * 0.7, col: cPick, a: Math.sin(sub * Math.PI) });
          }
          popups.push({ x: bx + ((stepIdx % 3) - 1) * 16, y: 54 - sub * 18, txt: '-' + (28 + stepIdx * 6), a: Math.sin(sub * Math.PI), col: cPick });
          shakeX = (Math.random() - 0.5) * (shakeAmp * 0.85); shakeY = (Math.random() - 0.5) * 5; camZoom = 1.08;
        } else {
          const k = (p - 0.78) / 0.22;
          hx = homeX + (1 - easeOut(k)) * (spanX * 0.66);
        }
      }
      else if (mode === 'toad_leap_slam') {
        // 蛤蟆功·金蟾推山扑: Deep crouching belly-swell -> explosive horizontal cannonball slam!
        if (p < 0.34) {
          const k = p / 0.34;
          sy = 1 - 0.22 * Math.sin(k * Math.PI * 0.5);
          sx = 1 + 0.18 * Math.sin(k * Math.PI * 0.5);
          lean = 12 * k;
        } else if (p < 0.56) {
          const k = easeOut((p - 0.34) / 0.22);
          hx = homeX + k * (spanX * 0.74);
          hz = Math.sin(k * Math.PI) * 38;
          lean = 32; armExt = 26 * k;
          clones.push({ x: hx - 34, z: hz * 0.7, a: 0.38, deg: 0 });
        } else if (p < 0.84) {
          const k = (p - 0.56) / 0.28;
          hx = homeX + spanX * 0.74 - k * 24; lean = 22 * (1 - k); armExt = 24 * (1 - k);
          bx = foeHomeX + easeOut(Math.min(1, k * 2)) * 38 * (1 - k * 0.5);
          bz = Math.sin(k * Math.PI) * 24; bLean = 28 * (1 - k); bFlash = Math.max(0, 1 - k * 1.8);
          shakeX = (Math.random() - 0.5) * 14 * (1 - k); shakeY = (Math.random() - 0.5) * 10 * (1 - k); camZoom = 1.13;
          popups.push({ x: bx, y: 48 - k * 16, txt: '金蟾震退!', a: 1 - k, col: '#ffe27a' });
        } else {
          hx = homeX + (1 - easeOut((p - 0.84) / 0.16)) * (spanX * 0.62);
        }
      }
      else if (mode.startsWith('sky_') || ['leap_cleave', 'gravity_cut', 'earth_wave', 'sky_thunder', 'buddha_palm', 'giant_axe', 'shield_split', 'earth_pocheng', 'earth_qianjun'].includes(mode)) {
        if (p < 0.22) {
          const k = p / 0.22;
          sy = 1 - 0.14 * k; sx = 1 + 0.10 * k; lean = -14 * k; wpnDeg = -95 * k;
        } else if (p < 0.50) {
          const k = (p - 0.22) / 0.28;
          hx = homeX + easeOut(k) * (spanX * 0.72);
          hz = Math.sin(k * Math.PI) * (mode.startsWith('earth_') ? 46 : 78);
          lean = -14 + k * 42;
          wpnDeg = -105 + Math.pow(k, 2.2) * 210;
          clones.push({ x: hx - 24, z: Math.max(0, hz - 14), a: 0.30, deg: wpnDeg - 25 });
        } else if (p < 0.82) {
          const k = (p - 0.50) / 0.32;
          hx = homeX + spanX * 0.72 - k * 16; lean = 24 - k * 12; wpnDeg = 105 - k * 20; armExt = 20;
          bx = foeHomeX + Math.sin(k * Math.PI) * 26; bz = Math.sin(Math.min(1, k * 2) * Math.PI) * 20;
          bLean = 26 * (1 - k); bFlash = Math.max(0, 1 - k * 1.85);
          if (wSpec.kind !== 'fist') {
            slashArcs.push({ x: hx + 34, y: groundY - 18, rO: 108, rI: 64, a0: -1.65, a1: 0.88, a: Math.max(0, 1 - k * 1.8) });
          }
          if (k < 0.55) { shakeX = (Math.random() - 0.5) * shakeAmp * 1.15; shakeY = (Math.random() - 0.5) * shakeAmp; camZoom = 1.13; }
        } else {
          const k = (p - 0.82) / 0.18;
          hx = homeX + (1 - easeOut(k)) * (spanX * 0.65); wpnDeg = 85 - k * 107;
        }
      }
      else if (['vacuum_pull', 'hook_pull'].includes(mode)) {
        if (p < 0.36) {
          const k = easeOut(p / 0.36);
          hx = homeX + k * 26; lean = 16 * k; armExt = k * 26; wpnDeg = 68;
        } else if (p < 0.76) {
          const k = easeOut((p - 0.36) / 0.40);
          hx = homeX + 26; lean = -10; armExt = 26 * (1 - k); wpnDeg = 68 - k * 75;
          bx = foeHomeX - k * (spanX * 0.62); bLean = -22 * (1 - k * 0.5); bFlash = Math.sin(k * Math.PI);
          shakeX = (Math.random() - 0.5) * shakeAmp;
          popups.push({ x: bx, y: 50, txt: '擒拿拖拽!', a: 1 - k, col: '#ffd97d' });
        } else {
          const k = (p - 0.76) / 0.24;
          bx = (foeHomeX - spanX * 0.62) + easeOut(k) * (spanX * 0.62); hx = homeX + (1 - k) * 26;
        }
      }
      else if (['pierce_luori', 'pierce_yanxing', 'pierce_tongtou', 'pierce_canhezhi', 'earth_huolong', 'aoe_leihuo', 'aoe_wuduzhang'].includes(mode) ||
               ['dragon_coil', 'sun_laser', 'flying_虹', 'star_rain', 'sonic_arrow', 'triple_arc', 'heavy_bolt', 'needle24', 'fan_knives7', 'venom_spikes', 'bomb_arc', 'black_hole', 'over_shield', 'neck_coil', 'viper_whip'].includes(mode) ||
               mode.startsWith('whip_')) {
        if (p < 0.26) {
          const k = p / 0.26;
          hx = homeX - k * 8; lean = -10 * k; wpnDeg = -46 * k;
          if (mode === 'star_rain') hz = easeOut(k) * 62;
        } else if (p < 0.56) {
          const k = (p - 0.26) / 0.30;
          hx = homeX + easeOut(k) * 22; lean = 15; armExt = 22; wpnDeg = 58;
          if (mode === 'star_rain') hz = 62 * (1 - k * 0.4);
        } else if (p < 0.85) {
          const k = (p - 0.56) / 0.29;
          hx = homeX + 22 * (1 - k); lean = 15 * (1 - k); armExt = 22 * (1 - k); wpnDeg = 58 - k * 80;
          bx = foeHomeX + (mode === 'black_hole' ? -Math.sin(k * Math.PI) * 34 : Math.sin(k * Math.PI) * 24);
          bLean = mode === 'black_hole' ? -18 : 22 * (1 - k);
          bFlash = Math.max(0, 1 - k * 1.8);
          if (k < 0.52) { shakeX = (Math.random() - 0.5) * shakeAmp; shakeY = (Math.random() - 0.5) * (shakeAmp * 0.8); camZoom = 1.10; }
        }
      }
      else if (mode.startsWith('pierce_') || ['drill_lunge', 'spiral_stab'].includes(mode)) {
        if (p < 0.24) {
          const k = p / 0.24;
          hx = homeX - k * 18; sy = 1 - 0.12 * k; lean = 16 * k; wpnDeg = 68;
        } else if (p < 0.70) {
          const k = easeOut((p - 0.24) / 0.46);
          hx = (homeX - 18) + k * (spanX * 0.86); lean = 26; armExt = 28; wpnDeg = 68 + Math.sin(k * Math.PI * 6) * 7;
          clones.push({ x: hx - 38, z: 0, a: 0.42, deg: 68 }, { x: hx - 76, z: 0, a: 0.22, deg: 68 });
          if (k > 0.40) {
            const ik = (k - 0.40) / 0.60;
            bx = foeHomeX + Math.sin(ik * Math.PI) * 26; bFlash = Math.max(0, 1 - ik * 1.6); bLean = 22 * (1 - ik);
            shakeX = (Math.random() - 0.5) * shakeAmp; camZoom = 1.10;
          }
        } else {
          hx = homeX + (1 - easeOut((p - 0.70) / 0.30)) * (spanX * 0.78);
        }
      }
      else if (['tidal_sweep', 'cyclone_pole', 'berserk_spin', 'aoe_abi', 'aoe_kuanglan', 'aoe_yaqi', 'aoe_pojun', 'aoe_polu', 'aoe_xueming'].includes(mode)) {
        if (p < 0.18) {
          lean = -14 * (p / 0.18);
        } else if (p < 0.78) {
          const k = (p - 0.18) / 0.60;
          hx = homeX + Math.sin(k * Math.PI * 0.85) * (spanX * 0.76);
          heroFlip = (Math.floor(k * 6) % 2 === 1);
          lean = 18; wpnDeg = k * 1080; armExt = 20;
          slashArcs.push({ x: hx, y: groundY - 4, rO: 96, rI: 52, a0: k * 16, a1: k * 16 + 4.5, a: 0.88 });
          if (k > 0.30) {
            bx = foeHomeX + Math.sin(k * Math.PI * 4) * 16; bFlash = 0.78; bLean = 18;
            shakeX = (Math.random() - 0.5) * shakeAmp;
          }
        } else {
          hx = homeX + (1 - (p - 0.78) / 0.22) * 90;
        }
      }
      else if (['aoe_taotie', 'aoe_guigu', 'aoe_kuiniu', 'aoe_bamen', 'aoe_zhenjiang', 'lion_roar', 'taunt_slam'].includes(mode)) {
        // War-Roar / Totem Surge / Eight-Gates / Banner Command shockwave!
        if (p < 0.24) {
          const k = p / 0.24;
          sy = 1 - 0.10 * k; lean = -10 * k; wpnDeg = -55 * k;
        } else if (p < 0.82) {
          const k = (p - 0.24) / 0.58;
          hx = homeX + Math.sin(k * Math.PI) * 32;
          hz = Math.sin(k * Math.PI) * 14;
          lean = 16 * (1 - k * 0.6); armExt = 20 * (1 - k * 0.5); wpnDeg = -55 + easeOut(Math.min(1, k * 2)) * 125;
          if (k > 0.20) {
            bx = foeHomeX + Math.sin(k * Math.PI * 2) * 20; bLean = 20 * (1 - k); bFlash = Math.max(0, 1 - k * 1.5);
            shakeX = (Math.random() - 0.5) * shakeAmp * (1 - k * 0.5); camZoom = 1.09;
          }
        }
      }
      else if (mode === 'spear_wall') {
        if (p < 0.36) {
          const k = easeOut(p / 0.36);
          hx = homeX + 10 * k; lean = 10 * k; wpnDeg = 56; armExt = 22 * k;
          bx = foeHomeX - k * (spanX * 0.64); bLean = -16 * k;
        } else if (p < 0.72) {
          const k = (p - 0.36) / 0.36;
          hx = homeX + 10 + Math.sin(k * Math.PI) * 18; lean = 18; wpnDeg = 64; armExt = 28;
          bx = (foeHomeX - spanX * 0.64) + easeOut(k) * (spanX * 0.70); bLean = 22 * Math.sin(k * Math.PI); bFlash = Math.max(0, 1 - k * 1.8);
          shakeX = (Math.random() - 0.5) * shakeAmp * (1 - k);
          popups.push({ x: bx, y: 48 - k * 14, txt: '拒马截击!', a: 1 - k, col: '#9ad8ff' });
        } else {
          const k = (p - 0.72) / 0.28;
          hx = homeX + 10 * (1 - k); wpnDeg = 64 - k * 86; armExt = 22 * (1 - k);
        }
      }
      else if (['twin_cross', 'halberd_x', 'twin_fang'].includes(mode)) {
        if (p < 0.20) {
          lean = -14 * (p / 0.20); wpnDeg = -82 * (p / 0.20);
        } else if (p < 0.78) {
          const k = (p - 0.20) / 0.58;
          const firstHalf = k < 0.5;
          const sub = (k * 2) % 1;
          hx = homeX + easeOut(Math.min(1, k * 2.2)) * (spanX * 0.72);
          hz = mode === 'halberd_x' ? Math.sin(k * Math.PI) * 34 : 0;
          lean = firstHalf ? 20 : 12; armExt = 22;
          wpnDeg = firstHalf ? (-82 + sub * 175) : (98 - sub * 175);
          bx = foeHomeX + Math.sin(sub * Math.PI) * 18; bFlash = Math.sin(sub * Math.PI);
          const c2 = mode === 'twin_cross' ? (firstHalf ? '#ff6a33' : '#5ce6ff') : col;
          slashArcs.push({ x: bx - 14, y: groundY - 14, rO: 94, rI: 56, a0: firstHalf ? -1.55 : 1.55, a1: firstHalf ? 1.15 : -1.15, col: c2, a: Math.sin(sub * Math.PI) });
          if (k > 0.45) { shakeX = (Math.random() - 0.5) * shakeAmp; shakeY = (Math.random() - 0.5) * 8; camZoom = 1.11; }
        } else {
          hx = homeX + (1 - easeOut((p - 0.78) / 0.22)) * (spanX * 0.72);
        }
      }
      else if (['inch_pulse', 'shield_ram'].includes(mode)) {
        if (p < 0.24) {
          hx = homeX + easeOut(p / 0.24) * (spanX * 0.64); lean = -8 * (p / 0.24);
        } else if (p < 0.44) {
          const k = (p - 0.24) / 0.20;
          hx = homeX + spanX * 0.64 - k * 10; sy = 1 - 0.10 * k; sx = 1 + 0.08 * k; wpnDeg = -35;
        } else if (p < 0.82) {
          const k = easeOut((p - 0.44) / 0.38);
          hx = homeX + spanX * 0.60 + (1 - k) * 28; lean = 24 * (1 - k * 0.6); armExt = 26 * (1 - k * 0.5); wpnDeg = 72;
          bx = foeHomeX + k * 42 * Math.sin(k * Math.PI); bLean = 26 * (1 - k); bFlash = Math.max(0, 1 - k * 2.0);
          if (k < 0.45) { shakeX = (Math.random() - 0.5) * shakeAmp * 1.1; camZoom = 1.12; }
        } else {
          hx = homeX + (1 - easeOut((p - 0.82) / 0.18)) * (spanX * 0.60);
        }
      }
      else if (mode.startsWith('taiji_')) {
        if (p < 0.42) {
          const k = p / 0.42;
          hx = homeX + Math.sin(k * Math.PI) * 34; wpnDeg = -20 + k * 180;
          bx = foeHomeX - easeOut(k) * (spanX * 0.60); bLean = -14 * k;
        } else if (p < 0.84) {
          const k = easeOut((p - 0.42) / 0.42);
          hx = homeX + 30 * (1 - k); lean = 16 * (1 - k); armExt = 24 * (1 - k); wpnDeg = 160 + k * 140;
          bx = (foeHomeX - spanX * 0.60) + k * (spanX * 0.72); bz = Math.sin(k * Math.PI) * 26; bLean = 24 * (1 - k); bFlash = Math.max(0, 1 - k * 2);
          slashArcs.push({ x: hx + 44, y: groundY - 10, rO: 88, rI: 58, a0: k * 4, a1: k * 4 + 2.8, a: 1 - k });
        }
      }
      else if (isSelfOrMove) {
        if (mode === 'cloud_jump' || mode === 'step_yanxing' || mode === 'step_feiyan' || mode === 'step_xuelian' || mode === 'step_chanchu') {
          if (p > 0.14 && p < 0.84) {
            const k = (p - 0.14) / 0.70;
            hx = homeX + Math.sin(k * Math.PI) * (spanX * 0.84);
            hz = Math.sin(k * Math.PI) * 84 + Math.abs(Math.sin(k * Math.PI * 2)) * 20;
            lean = 15 * Math.cos(k * Math.PI);
            clones.push({ x: hx - 28, z: Math.max(0, hz - 16), a: 0.36, deg: -20 }, { x: hx - 54, z: Math.max(0, hz - 32), a: 0.18, deg: -28 });
            if (p > 0.32 && p < 0.68) { bx = foeHomeX - Math.sin(((p - 0.32) / 0.36) * Math.PI) * 90; bLean = -16; }
          }
        } else if (isStep) {
          const k = Math.sin(p * Math.PI);
          hx = homeX + Math.sin(p * Math.PI * 2) * 64;
          clones.push(
            { x: homeX - 24, z: 4, a: 0.44 * k, deg: -15 },
            { x: homeX + 44, z: 8, a: 0.38 * k, deg: 12 },
            { x: homeX + 98, z: 2, a: 0.30 * k, deg: -28 }
          );
          if (p > 0.28 && p < 0.68) { bx = foeHomeX - Math.sin(((p - 0.28) / 0.40) * Math.PI) * (spanX * 0.70); bLean = -18; }
        } else if (mode === 'poise_draw') {
          const k = Math.sin(p * Math.PI);
          sy = 1 - 0.10 * k; sx = 1 + 0.06 * k; lean = 8 * k; wpnDeg = -52 - 18 * k;
        } else {
          const k = Math.sin(p * Math.PI);
          hz = k * 14;
          wpnDeg = -22 - k * 34;
        }
      }
      else {
        // Heavy Crescent / Upward Launch (`modao_upcut`, `dragon_up`, `upcut_*`) / Flame / Claw / Frost / Blood / Disarm
        const isUpcut = mode === 'modao_upcut' || mode === 'dragon_up' || mode.startsWith('upcut_');
        if (p < 0.22) {
          const k = p / 0.22;
          hx = homeX - k * 12; lean = -12 * k; sy = 1 - 0.08 * k; wpnDeg = isUpcut ? (75 * k) : (-68 * k);
        } else if (p < 0.50) {
          const k = easeOut((p - 0.22) / 0.28);
          hx = (homeX - 12) + k * (spanX * 0.74);
          lean = 22 * k; armExt = 24 * k;
          wpnDeg = isUpcut ? (115 - k * 170) : (-68 + k * 158);
          clones.push({ x: hx - 32, z: 0, a: 0.34, deg: wpnDeg - 18 }, { x: hx - 62, z: 0, a: 0.16, deg: wpnDeg - 32 });
        } else if (p < 0.80) {
          const k = (p - 0.50) / 0.30;
          hx = (homeX + spanX * 0.70) - k * 18;
          lean = 20 * (1 - k); armExt = 22 * (1 - k);
          wpnDeg = isUpcut ? (-55 + k * 32) : (90 - k * 45);
          bx = foeHomeX + Math.sin(k * Math.PI) * 24;
          if (isUpcut) bz = Math.sin(k * Math.PI) * 52;
          bLean = 22 * (1 - k); bFlash = Math.max(0, 1 - k * 1.9);
          if (wSpec.kind !== 'fist') {
            slashArcs.push({ x: bx - 16, y: groundY - 14, rO: 96, rI: 58, a0: isUpcut ? 1.35 : -1.45, a1: isUpcut ? -1.45 : 1.15, a: Math.max(0, 1 - k * 1.9) });
          }
          if (k < 0.5) { shakeX = (Math.random() - 0.5) * shakeAmp; shakeY = (Math.random() - 0.5) * (shakeAmp * 0.8); camZoom = 1.11; }
        } else {
          const k = (p - 0.80) / 0.20;
          hx = homeX + (1 - easeOut(k)) * (spanX * 0.62);
          wpnDeg = 45 - k * 67;
        }
      }

      // === Render Battlefield Scene ===
      ctx.save();
      ctx.clearRect(0, 0, W, H);

      const isNight = mode === 'night_exec' || mode === 'star_rain' || mode === 'black_hole' || mode.startsWith('shadow_');
      const bg = ctx.createRadialGradient(W * 0.52, H * 0.58, 16, W * 0.5, H * 0.5, W * 0.80);
      bg.addColorStop(0, isNight ? '#1d1532' : '#3a2a1e');
      bg.addColorStop(1, isNight ? '#08060e' : '#110c08');
      ctx.fillStyle = bg;
      ctx.fillRect(0, 0, W, H);

      ctx.translate(W * 0.5 + shakeX, H * 0.5 + shakeY);
      ctx.scale(camZoom, camZoom);
      ctx.translate(-W * 0.5, -H * 0.5);

      if (p > 0.24 && p < 0.68 && !isSelfOrMove) {
        wxDrawSpeedLines(ctx, W, H, col, Math.sin(((p - 0.24) / 0.44) * Math.PI));
      }

      // 4-Hex Tactical Battlefield Floor
      for (let hi = 0; hi < 4; hi++) {
        const cx = homeX + (spanX / 3) * hi;
        const stroke = hi === 0 ? 'rgba(136,192,120,0.48)' : (hi === 3 ? 'rgba(218,92,72,0.52)' : 'rgba(154,126,88,0.26)');
        const fill = hi === 0 ? 'rgba(48,74,42,0.22)' : (hi === 3 ? 'rgba(94,34,26,0.22)' : 'rgba(38,29,20,0.20)');
        wxDrawHex(ctx, cx, groundY + 40, 48, 17, stroke, fill);
      }

      // Ground Arrays (Taiji / Stance / Qimen / Mirage / Earth Fissures)
      if ((mode.startsWith('taiji_') || isStance || mode === 'mirage_step' || mode === 'aoe_bamen' || mode === 'aoe_guigu') && fxBagua) {
        ctx.save();
        ctx.translate(mode === 'taiji_field' ? (hx + bx) * 0.5 : hx + 8, groundY + 38);
        ctx.scale(1.38, 0.46);
        wxDrawSprite(ctx, ch.sig === 'wx_fx_lotus_seal' ? fxLotus : fxBagua, 0, 0, 148, 148, p * Math.PI * 3, 0.84, false);
        ctx.restore();
      }
      if ((mode.startsWith('earth_') || mode.startsWith('sky_') || mode === 'gravity_cut' || mode === 'leap_cleave') && p >= 0.48 && fxEarth) {
        const ek = Math.min(1, (p - 0.48) / 0.42);
        const cnt = (mode.startsWith('earth_') || mode === 'earth_wave') ? 3 : 1;
        for (let gi = 0; gi < cnt; gi++) {
          if (ek > gi * 0.14) {
            wxDrawSprite(ctx, fxEarth, bx - (cnt > 1 ? 46 : 0) + gi * 44, groundY + 26, 118, 86, 0, Math.max(0, 1 - ek * 0.85), false);
          }
        }
        if (ch.sig === 'wx_fx_earth_fissure') customSigDrawn = true;
      }

      // Draw Faction Opponent (cleanly cropped pedestal + hit flash)
      if (oppIm && oppIm.complete && oppIm.naturalWidth) {
        const shS = Math.max(0.32, 1 - bz / 120);
        ctx.fillStyle = 'rgba(0,0,0,' + (0.45 * shS).toFixed(2) + ')';
        ctx.beginPath(); ctx.ellipse(bx, groundY + 40, 35 * shS, 11 * shS, 0, 0, Math.PI * 2); ctx.fill();
        ctx.save();
        ctx.translate(bx, groundY - bz);
        ctx.rotate((bLean * Math.PI) / 180);
        if (bFlash > 0.05) ctx.filter = 'brightness(' + (1 + bFlash * 1.65).toFixed(2) + ')';
        ctx.scale(-1, 1);
        ctx.drawImage(oppIm, -48, -68, 96, 132);
        ctx.restore();
      }

      // Draw Hero Clones + Articulated Hero
      clones.forEach(c => {
        drawHero(c.x, groundY, c.z || 0, 16, 1, 1, c.deg !== undefined ? c.deg : wpnDeg, 12, c.a, !!c.flip);
      });
      drawHero(hx, groundY, hz, lean, sx, sy, wpnDeg, armExt, 1.0, heroFlip);

      // Draw Tapered Blade-Qi Ribbons & Flying Projectiles
      slashArcs.forEach(sa => {
        wxDrawSlashRibbon(ctx, sa.x, sa.y, sa.rO, sa.rI, sa.a0, sa.a1, sa.col || col, sa.a);
      });
      projectiles.forEach(pr => {
        wxDrawSprite(ctx, pr.im, pr.x, pr.y, pr.w, pr.h, pr.rot, pr.a, pr.flip);
      });

      // Smooth Cross-Faded 4-Frame Hand-Painted Sequence (`wx_anim_01..171`)
      if (stripIm && p > 0.06 && p < 0.94) {
        const fPos = (lockF >= 0 && lockF <= 3) ? lockF : (p * 3.55);
        const idx0 = Math.min(3, Math.floor(fPos));
        const idx1 = Math.min(3, idx0 + 1);
        const frac = (lockF >= 0 && lockF <= 3) ? 0 : (fPos - idx0);
        const fxX = isSelfOrMove ? hx : (p < 0.34 ? hx + 32 : (p < 0.48 ? (hx + bx) * 0.5 : bx));
        const fxY = groundY - (isSelfOrMove ? hz + 8 : bz + 10);
        const sz = hitWindow ? 148 : 118;
        wxDrawStripFrame(ctx, stripIm, idx0, fxX, fxY, sz, (1 - frac) * 0.86);
        if (idx1 !== idx0 && frac > 0.02) {
          wxDrawStripFrame(ctx, stripIm, idx1, fxX, fxY, sz * 1.05, frac * 0.86);
        }
      }

      // Hand-Painted `wx_vfx_01..32` Qi-Aura
      if (vfxIm && p > 0.36 && p < 0.88) {
        const vk = Math.sin(((p - 0.36) / 0.52) * Math.PI);
        const vx = isSelfOrMove ? hx : bx;
        const vy = groundY - (isSelfOrMove ? hz + 8 : bz + 10);
        wxDrawSprite(ctx, vfxIm, vx, vy, 130 + vk * 22, 130 + vk * 22, 0, vk * 0.80, false);
      }

      // === Bespoke Signature FX Overlays Across All 171 Modes ===
      if ((mode === 'dragon_coil' || mode === 'upcut_xuelong') && p > 0.22 && p < 0.88) {
        const dk = (p - 0.22) / 0.66;
        const headX = homeX + 28 + easeOut(Math.min(1, dk * 1.45)) * (bx - homeX + 10);
        ctx.save();
        for (let si = 16; si >= 0; si--) {
          const st = Math.max(0, dk - si * 0.026);
          const sx0 = homeX + 24 + easeOut(Math.min(1, st * 1.45)) * (bx - homeX + 10);
          const sy0 = groundY - 12 + Math.sin(st * 13 + si * 0.55) * 24;
          const rad = (18 - si * 0.75) * (dk > 0.75 ? (1 - (dk - 0.75) * 3.5) : 1);
          if (rad > 1) {
            ctx.fillStyle = si % 2 === 0 ? col : 'rgba(255,235,155,0.72)';
            ctx.beginPath(); ctx.arc(sx0, sy0, rad, 0, Math.PI * 2); ctx.fill();
          }
        }
        ctx.restore();
        const headY = groundY - 12 + Math.sin(dk * 13) * 20;
        // Flip horizontally (`true`) so `wx_fx_dragon_head` roars RIGHT toward the enemy!
        wxDrawSprite(ctx, fxDragon, headX, headY, 98, 98, Math.cos(dk * 13) * 0.22, Math.min(1, (1 - dk) * 3.2), true);
        customSigDrawn = true;
      }
      else if ((mode === 'sun_laser' || mode === 'pierce_canhezhi' || mode === 'pierce_luori' || mode === 'pierce_yanxing' || mode === 'pierce_tongtou') && p > 0.34 && p < 0.80) {
        const lk = 1 - Math.abs(((p - 0.34) / 0.46) - 0.35) * 1.5;
        ctx.save();
        ctx.globalAlpha = Math.max(0, Math.min(1, lk));
        ctx.strokeStyle = col; ctx.shadowColor = col; ctx.shadowBlur = 18;
        ctx.lineWidth = 13 * Math.max(0.2, lk);
        ctx.beginPath(); ctx.moveTo(hx + 28, groundY - 16); ctx.lineTo(W - 16, groundY - 16); ctx.stroke();
        ctx.strokeStyle = '#ffffff'; ctx.lineWidth = 4; ctx.stroke();
        ctx.restore();
        if (mode !== 'sun_laser' && projIm) {
          const pk = Math.min(1, (p - 0.34) / 0.26);
          wxDrawSprite(ctx, projIm, (hx + 32) + pk * (bx - hx - 12), groundY - 16, 56, 56, Math.PI / 2, 1, false);
        }
        wxDrawSprite(ctx, fxSonic, bx, groundY - 16, 110, 110, p * 6, Math.max(0, lk), false);
        customSigDrawn = true;
      }
      else if (mode === 'flying_虹' && p > 0.20 && p < 0.86) {
        const fk = (p - 0.20) / 0.66;
        const sx0 = fk < 0.35 ? (hx + 34) : (hx + 34 + easeOut((fk - 0.35) / 0.45) * (spanX + 55));
        const sy0 = groundY - 36 + Math.sin(fk * Math.PI * 2) * 8;
        ctx.save();
        ctx.strokeStyle = '#fff3a1'; ctx.shadowColor = col; ctx.shadowBlur = 16; ctx.lineWidth = 6;
        ctx.beginPath(); ctx.moveTo(Math.max(hx + 24, sx0 - 115), sy0); ctx.lineTo(sx0, sy0); ctx.stroke();
        ctx.restore();
        wxDrawSprite(ctx, fxSword, sx0, sy0, 104, 70, -0.78, 1, true);
        customSigDrawn = true;
      }
      else if (mode === 'star_rain' && p > 0.28 && p < 0.86) {
        const rk = (p - 0.28) / 0.58;
        for (let si = 0; si < 7; si++) {
          const skp = rk * 1.6 - si * 0.09;
          if (skp > 0 && skp < 1) {
            const x = bx - 54 + si * 18 - (1 - skp) * 70;
            const y = -20 + skp * (groundY + 42);
            wxDrawSprite(ctx, fxSword, x, y, 78, 52, 0.25, Math.min(1, (1 - skp) * 2.5), true);
          }
        }
        customSigDrawn = true;
      }
      else if (['needle24', 'fan_knives7', 'triple_arc', 'sonic_arrow', 'heavy_bolt', 'venom_spikes'].includes(mode) && p > 0.30 && p < 0.82) {
        const vk = (p - 0.30) / 0.52;
        const cnt = mode === 'needle24' ? 12 : (mode === 'fan_knives7' ? 7 : (mode === 'triple_arc' || mode === 'venom_spikes' ? 3 : 1));
        for (let i = 0; i < cnt; i++) {
          const tk = Math.max(0, Math.min(1, vk * 1.45 - (i % 4) * 0.08));
          if (tk <= 0 || tk >= 1) continue;
          const spread = (i - (cnt - 1) / 2) * (mode === 'fan_knives7' ? 11 : 6);
          const px = (hx + 34) + tk * (bx - hx - 28);
          const py = (groundY - 16) + spread * tk - (mode === 'triple_arc' ? Math.sin(tk * Math.PI) * (36 + i * 14) : 0);
          ctx.save();
          ctx.strokeStyle = col; ctx.lineWidth = cnt === 1 ? 4.8 : 2.5;
          ctx.beginPath(); ctx.moveTo(px - 28, py); ctx.lineTo(px + 8, py); ctx.stroke();
          ctx.restore();
          wxDrawSprite(ctx, projIm, px, py, 40, 40, Math.PI / 2, 1, false);
        }
        if (mode === 'venom_spikes' && vk > 0.45) wxDrawSprite(ctx, fxPoison, bx, groundY - 22 - (vk - 0.45) * 34, 116, 116, 0, 1 - (vk - 0.45) * 1.5, false);
        customSigDrawn = true;
      }
      else if ((mode.startsWith('whip_') || ['over_shield', 'neck_coil', 'viper_whip', 'bamboo_bind'].includes(mode)) && p > 0.26 && p < 0.84) {
        const wk = Math.sin(((p - 0.26) / 0.58) * Math.PI);
        ctx.save();
        ctx.strokeStyle = col; ctx.shadowColor = col; ctx.shadowBlur = 11; ctx.lineWidth = 4.4;
        ctx.beginPath();
        for (let s = 0; s <= 24; s++) {
          const t = s / 24;
          const wx = (hx + 24) + t * (bx - hx - 16);
          const arcLift = mode === 'over_shield' ? -Math.sin(t * Math.PI) * 68 : Math.sin(t * Math.PI * 3 + p * 18) * (mode === 'bamboo_bind' ? 12 : 22);
          const wy = (mode === 'bamboo_bind' ? groundY + 24 : groundY - 16) + arcLift * wk;
          if (s === 0) ctx.moveTo(wx, wy); else ctx.lineTo(wx, wy);
        }
        ctx.stroke();
        for (let r = 0; r < 3; r++) {
          ctx.beginPath(); ctx.ellipse(bx, (mode === 'bamboo_bind' ? groundY + 20 : groundY - 22) + r * 7, 26, 8, 0, 0, Math.PI * 2); ctx.stroke();
        }
        ctx.restore();
      }
      else if ((mode === 'bomb_arc' || mode === 'earth_huolong' || mode === 'aoe_leihuo' || mode === 'aoe_wuduzhang') && p > 0.22 && p < 0.90) {
        const bk = (p - 0.22) / 0.68;
        if (bk < 0.42) {
          const t = bk / 0.42;
          const px = (hx + 26) + t * (bx - hx - 22);
          const py = (groundY - 18) - Math.sin(t * Math.PI) * (mode === 'earth_huolong' ? 28 : 78);
          wxDrawSprite(ctx, projIm, px, py, 44, 44, t * 10, 1, false);
        } else {
          const ex = (bk - 0.42) / 0.58;
          ctx.save();
          const g = ctx.createRadialGradient(bx, groundY - 14, 6, bx, groundY - 14, 105 * ex + 20);
          const cMid = mode === 'aoe_wuduzhang' ? 'rgba(92,235,84,' : 'rgba(255,104,28,';
          g.addColorStop(0, 'rgba(255,252,225,' + (1 - ex).toFixed(2) + ')');
          g.addColorStop(0.45, cMid + (0.85 * (1 - ex)).toFixed(2) + ')');
          g.addColorStop(1, 'rgba(30,16,10,0)');
          ctx.fillStyle = g; ctx.beginPath(); ctx.arc(bx, groundY - 14, 118, 0, Math.PI * 2); ctx.fill();
          ctx.restore();
          if (mode === 'aoe_wuduzhang') wxDrawSprite(ctx, fxPoison, bx, groundY - 26 - ex * 26, 124, 124, 0, 1 - ex, false);
        }
        customSigDrawn = true;
      }
      else if ((mode === 'blood_siphon' || mode === 'black_hole' || mode === 'aoe_taotie') && p > 0.42 && p < 0.92) {
        const skp = (p - 0.42) / 0.50;
        for (let oi = 0; oi < 6; oi++) {
          const ot = skp * 1.4 - oi * 0.08;
          if (ot > 0 && ot < 1) {
            const ox = bx - easeOut(ot) * (bx - hx - 12);
            const oy = groundY - 16 - Math.sin(ot * Math.PI) * (28 - oi * 8);
            wxDrawSprite(ctx, mode === 'black_hole' ? fxBagua : fxBlood, ox, oy, 36, 36, ot * 8, 0.92, false);
          }
        }
        customSigDrawn = true;
      }
      else if ((mode === 'disarm_arc' || mode === 'disarm_grab') && p > 0.48 && p < 0.92) {
        const dk = (p - 0.48) / 0.44;
        wxDrawSprite(ctx, fxSword, bx + dk * 42, (groundY - 24) - Math.sin(dk * Math.PI) * 92, 68, 68, dk * 15, 1 - dk * 0.5, false);
        popups.push({ x: bx, y: 46, txt: '缴械夺兵!', a: 1 - dk, col: '#ffe27a' });
        customSigDrawn = true;
      }
      else if ((mode === 'lion_roar' || mode === 'taunt_slam' || mode === 'aoe_kuiniu') && p > 0.26 && p < 0.88) {
        const rk = (p - 0.26) / 0.62;
        for (let ri = 0; ri < 4; ri++) {
          const rt = rk * 1.4 - ri * 0.12;
          if (rt > 0 && rt < 1) {
            wxDrawSprite(ctx, fxSonic, hx + 36 + rt * (spanX * 0.95), groundY - 12, 64 + rt * 98, 84 + rt * 86, 0, 1 - rt, false);
          }
        }
        customSigDrawn = true;
      }
      else if ((mode === 'war_banner' || mode === 'aoe_zhenjiang') && p > 0.14 && p < 0.92) {
        wxDrawSprite(ctx, fxBanner, hx + 18, groundY - 38, 112, 126, Math.sin(p * 12) * 0.08, 0.95, false);
        wxDrawSprite(ctx, fxSonic, hx, groundY + 24, 165 * p, 66 * p, 0, 1 - p, false);
        customSigDrawn = true;
      }
      else if (mode === 'heal_needles' && p > 0.15 && p < 0.90) {
        const nk = (p - 0.15) / 0.75;
        for (let ni = 0; ni < 5; ni++) {
          const ang = -2.4 + ni * 0.45;
          const dist = nk < 0.45 ? 64 : 64 * (1 - easeOut((nk - 0.45) / 0.55));
          wxDrawSprite(ctx, fxNeedle, hx + Math.cos(ang) * dist, (groundY - 18) + Math.sin(ang) * dist, 48, 48, ang + Math.PI, 0.95, false);
        }
        customSigDrawn = true;
      }
      else if ((mode === 'phoenix9' || mode === 'petal_storm') && p > 0.34 && p < 0.80) {
        const pk = (p - 0.34) / 0.46;
        for (let pi = 0; pi < 9; pi++) {
          const ang = -0.55 + pi * 0.14;
          const r = 45 + easeOut(Math.min(1, pk * 1.6)) * 115;
          wxDrawSprite(ctx, fxSword, hx + 30 + Math.cos(ang) * r, (groundY - 14) + Math.sin(ang) * r, 76, 40, ang - 0.78, 1 - pk * 0.85, true);
        }
        customSigDrawn = true;
      }
      else if (mode === 'smoke_screen' && p > 0.24 && p < 0.94) {
        const skp = (p - 0.24) / 0.70;
        ctx.save();
        for (let ci = 0; ci < 7; ci++) {
          const r = 24 + skp * 46 + (ci % 3) * 12;
          ctx.fillStyle = 'rgba(148,162,175,' + (0.44 * (1 - skp * 0.6)).toFixed(2) + ')';
          ctx.beginPath(); ctx.arc(bx - 50 + ci * 22, groundY + 6 - (ci % 2) * 18 - skp * 18, r, 0, Math.PI * 2); ctx.fill();
        }
        ctx.restore();
      }

      // Rising Qi Pillar for Neigong/Stance/Flame skills
      if ((isStance || ['fire_pillar', 'taiyuan_flame', 'blood_flame', 'lotus_breath', 'poise_draw'].includes(mode)) && p > 0.18 && p < 0.92) {
        const fk = Math.sin(((p - 0.18) / 0.74) * Math.PI);
        const px = (mode === 'fire_pillar' || mode === 'taiyuan_flame') ? bx : hx;
        ctx.save();
        const grad = ctx.createLinearGradient(px, groundY + 38, px, groundY - 122);
        grad.addColorStop(0, col);
        grad.addColorStop(1, 'rgba(255,255,255,0)');
        ctx.globalAlpha = fk * 0.58;
        ctx.fillStyle = grad;
        ctx.fillRect(px - 38, groundY - 118, 76, 156);
        ctx.restore();
      }

      // Guaranteed Signature Dharma / Element Overlay (`sigIm`) if not already custom-rendered
      if (!customSigDrawn && sigIm && p > (isSelfOrMove ? 0.18 : 0.42) && p < 0.90) {
        const p0 = isSelfOrMove ? 0.18 : 0.42;
        const skp = Math.sin(((p - p0) / (0.90 - p0)) * Math.PI);
        const sx0 = isSelfOrMove ? hx : bx;
        const sy0 = groundY - (isSelfOrMove ? hz + 14 : bz + 16);
        const sz = ch.sig === 'wx_fx_golden_bell' || ch.sig === 'wx_fx_buddha_palm' ? 142 : 122;
        const flipSig = ch.sig === 'wx_fx_dragon_head';
        wxDrawSprite(ctx, sigIm, sx0, sy0, sz, sz, 0, skp * 0.86, flipSig);
      }

      // Directional Impact Sparks
      if (hitWindow && !isSelfOrMove) {
        ctx.save();
        for (let sp = 0; sp < 20; sp++) {
          const ang = (sp * 1.93) + (sk.id.length * 0.31);
          const spd0 = 28 + (sp % 5) * 19;
          const sx0 = bx - 8 + Math.cos(ang) * spd0 * hk;
          const sy0 = (groundY - 14) + Math.sin(ang) * spd0 * hk + hk * hk * 26;
          ctx.globalAlpha = Math.max(0, 1 - hk * 1.25);
          ctx.fillStyle = sp % 3 === 0 ? '#ffffff' : col;
          ctx.beginPath(); ctx.arc(sx0, sy0, 2.4 - hk * 1.4, 0, Math.PI * 2); ctx.fill();
        }
        ctx.restore();
      }

      // Top-Left Skill Choreography Banner
      ctx.save();
      ctx.font = 'bold 12.5px "Microsoft YaHei UI", "PingFang SC", sans-serif';
      const titleTxt = '⚡ ' + sk.name + ' · ' + ch.label;
      const tw = Math.min(W - 24, ctx.measureText(titleTxt).width + 22);
      ctx.fillStyle = 'rgba(14,10,7,0.84)';
      ctx.fillRect(10, 10, tw, 23);
      ctx.strokeStyle = col;
      ctx.lineWidth = 1.2;
      ctx.strokeRect(10, 10, tw, 23);
      ctx.fillStyle = '#fff3d6';
      ctx.textAlign = 'left';
      ctx.fillText(titleTxt, 20, 25.5);
      ctx.restore();

      // Floating Combat Result Text
      if (p >= 0.50 && p <= 0.92 && popups.length === 0) {
        const k = (p - 0.50) / 0.42;
        const fx = isSelfOrMove ? hx : bx;
        const fy = 56 - k * 22;
        const mainTxt = isStep ? 'MISS · 身法闪避!' :
                        isStance ? ('+' + sk.name) :
                        ('-' + (62 + ((sk.ap * 13 + sk.qi * 3) % 58)));
        ctx.save();
        ctx.globalAlpha = Math.min(1, (1 - k) * 2.2);
        ctx.textAlign = 'center';
        ctx.font = 'bold 17px Georgia, serif';
        ctx.strokeStyle = '#120b07';
        ctx.lineWidth = 4;
        ctx.strokeText(mainTxt, fx, fy);
        ctx.fillStyle = isSelfOrMove ? '#9ef5c8' : col;
        ctx.fillText(mainTxt, fx, fy);
        ctx.restore();
      }
      popups.forEach(pp => {
        ctx.save();
        ctx.globalAlpha = Math.max(0, Math.min(1, pp.a));
        ctx.textAlign = 'center';
        ctx.font = 'bold 15.5px Georgia, serif';
        ctx.strokeStyle = '#120b07';
        ctx.lineWidth = 3.5;
        ctx.strokeText(pp.txt, pp.x, pp.y);
        ctx.fillStyle = pp.col || col;
        ctx.fillText(pp.txt, pp.x, pp.y);
        ctx.restore();
      });

      ctx.restore();

      const nextId = requestAnimationFrame(step);
      if (isModal) vfxState.modalRaf = nextId; else vfxState.stageRaf = nextId;
    }

    const initId = requestAnimationFrame(step);
    if (isModal) vfxState.modalRaf = initId; else vfxState.stageRaf = initId;
  }

  function getTheaterPool(filteredSkills) {
    if (vfxState.cat === 'featured') {
      return VFX_FEATURED_IDS.map(id => skillById.get(id)).filter(Boolean);
    }
    if (vfxState.cat === 'filtered') {
      return filteredSkills && filteredSkills.length ? filteredSkills : DB.skills;
    }
    if (vfxState.cat === 'all') {
      return DB.skills;
    }
    return DB.skills.filter(s => s.choreo && s.choreo.fam === vfxState.cat);
  }

  function renderSkillTheaterInner(filteredSkills) {
    if (filteredSkills) vfxState.lastFiltered = filteredSkills;
    const effFiltered = filteredSkills || vfxState.lastFiltered || DB.skills;
    const pool = getTheaterPool(effFiltered);
    let cur = pool.find(s => s.id === vfxState.skillId) || skillById.get(vfxState.skillId) || pool[0] || DB.skills[0];
    if (!pool.includes(cur) && pool.length) cur = pool[0];
    if (!cur) return '';
    vfxState.skillId = cur.id;
    const ch = cur.choreo || {};
    const proto = KINETIC_PROTOS[cur.id] || null;
    const isNewMode = !!(proto && !vfxState.useLegacyCompare && KINETIC_ASSETS.strips && KINETIC_ASSETS.strips[proto.seq]);
    const stripUri = VFX_ASSETS.strips[ch.anim] || '';

    const famCounts = {};
    DB.skills.forEach(s => {
      const f = (s.choreo && s.choreo.fam) || 'inner';
      famCounts[f] = (famCounts[f] || 0) + 1;
    });

    const catBtns = VFX_CAT_DEFS.map(([cid, lbl]) => {
      let text = lbl;
      if (cid === 'filtered') {
        const cnt = effFiltered ? effFiltered.length : DB.skills.length;
        if (cnt === DB.skills.length) return '';
        text = `${lbl} (${cnt})`;
      } else if (famCounts[cid]) {
        text = `${lbl} (${famCounts[cid]})`;
      }
      return `<button type="button" class="wx-vfx-cat" data-vfx-cat="${esc(cid)}" aria-pressed="${vfxState.cat === cid}">${esc(text)}</button>`;
    }).join('');

    let framesHtml = '';
    if (isNewMode) {
      const kUri = KINETIC_ASSETS.strips[proto.seq] || '';
      const kMeta = KINETIC_ASSETS.meta[proto.seq] || { count: 10 };
      const sampleFrames = [1, Math.floor(kMeta.count * 0.35), Math.floor(kMeta.count * 0.58), Math.max(0, kMeta.count - 3)];
      framesHtml = proto.beats.map((bn, fi) => {
        const sf = sampleFrames[fi];
        const posPct = kMeta.count > 1 ? ((sf * 100) / (kMeta.count - 1)).toFixed(2) : '0';
        return `
          <button type="button" class="wx-frame-btn" data-vfx-frame="${fi}" aria-pressed="${vfxState.lockFrame === fi}" title="点击定格查看 ${esc(bn)}">
            <span class="wx-frame-thumb" style="width:74px;height:52px;background-image:url('${kUri}');background-size:${kMeta.count * 100}% 100%;background-position:${posPct}% 50%"></span>
            <span>${esc(bn)}</span>
          </button>`;
      }).join('');
    } else {
      framesHtml = VFX_FRAME_NAMES.map((fn, fi) => `
        <button type="button" class="wx-frame-btn" data-vfx-frame="${fi}" aria-pressed="${vfxState.lockFrame === fi}" title="点击定格查看 ${esc(fn)}">
          <span class="wx-frame-thumb" style="background-image:url('${stripUri}');background-position:${(fi * 100) / 3}% 0"></span>
          <span>${esc(fn)}</span>
        </button>`).join('');
    }

    const rosterHtml = pool.map(s => {
      const iconUri = ICONS[s.icon] || '';
      const sch = s.choreo || {};
      const hasProto = !!KINETIC_PROTOS[s.id];
      return `
        <button type="button" class="wx-vfx-pick" data-vfx-pick="${esc(s.id)}" aria-pressed="${s.id === cur.id}">
          ${iconUri ? `<img src="${iconUri}" alt="" loading="lazy">` : ''}
          <span class="wx-vfx-pick-txt">
            <b>${esc(s.name)}${hasProto ? `<span class="wx-vfx-proto-badge">${esc(KINETIC_PROTOS[s.id].seal)}</span>` : ''}</b>
            <small>${esc(hasProto ? KINETIC_PROTOS[s.id].sub : (sch.label || ''))} · ${s.ap}AP/${s.qi}气</small>
          </span>
        </button>`;
    }).join('');

    const protoBarHtml = proto ? `
      <div class="wx-vfx-proto-bar">
        <span><strong>✨ 全量逐帧动效（${esc(proto.seal)}）：</strong>${esc(proto.tag)}</span>
        <span style="display:flex;gap:6px;flex-wrap:wrap">
          <button type="button" class="wx-vfx-btn" data-vfx-ctrl="range" aria-pressed="${vfxState.closeRange}">${vfxState.closeRange ? '⚔ 实战贴身1格（已开启）' : '↔ 远距拉宽视角'}</button>
          <button type="button" class="wx-vfx-btn" data-vfx-ctrl="compare" aria-pressed="${vfxState.useLegacyCompare}">${vfxState.useLegacyCompare ? '📜 当前：旧版贴图（点击切回新版）' : '🆚 切旧版贴图对比'}</button>
        </span>
      </div>` : '';

    return `
      <div class="wx-vfx-head">
        <div class="wx-vfx-head-title">
          <strong>⚔ 全量 171 式主动武学 · 60fps 新一代逐帧水墨演武剧场（40 套专属图集 · 零撞车）</strong>
          <small>已全量重置 171/171 式招式（40 套 10~12 帧专属水墨动画共 402 帧 + 28 种微粒与焦痕冻土毒池 + 16 种 1 格贴身拉距身法 + 顿帧卡肉 + 10 主题横幅），全招式支持一键切旧版对比</small>
        </div>
        <div class="wx-vfx-head-actions">
          ${!vfxState.collapsed ? `<button type="button" class="wx-vfx-btn" data-open="skill:${esc(cur.id)}">查阅「${esc(cur.name)}」完整词条与传承 →</button>` : ''}
          <button type="button" class="wx-vfx-btn" data-vfx-toggle="1">${vfxState.collapsed ? '展开 60fps 演武台 ▼' : '收起演武台 ▲'}</button>
        </div>
      </div>
      ${vfxState.collapsed ? '' : `
        <div class="wx-vfx-cats" role="group" aria-label="演武台流派筛选">${catBtns}</div>
        ${protoBarHtml}
        <div class="wx-vfx-grid" style="margin-top:${proto ? '10px' : '0'}">
          <div class="wx-vfx-stage-col">
            <div class="wx-vfx-canvas-box">
              <canvas id="wx-vfx-stage-canvas" width="480" height="264"></canvas>
            </div>
            <div class="wx-vfx-ctrl-row">
              <div class="wx-vfx-ctrl-left">
                <button type="button" class="wx-vfx-btn" data-vfx-ctrl="play" aria-pressed="${vfxState.lockFrame < 0}">▶ 连续演武</button>
                <button type="button" class="wx-vfx-btn" data-vfx-ctrl="slow" aria-pressed="${vfxState.speed < 0.8}">${vfxState.speed < 0.8 ? '🐢 0.45× 慢镜中' : '🐢 0.45× 慢镜拆招'}</button>
              </div>
              <span class="wx-vfx-meta-tag">${cur.ap} AP · ${cur.qi} 内息 · 射程 ${cur.minRange}~${cur.maxRange} 格</span>
            </div>
            <div class="wx-vfx-frames">${framesHtml}</div>
          </div>
          <div class="wx-vfx-roster" id="wx-vfx-roster-list">${rosterHtml}</div>
        </div>`}`;
  }

  function refreshTheaterDom(filteredSkills) {
    const box = document.getElementById('wx-vfx-theater-root');
    if (!box) return;
    const prevScroll = (document.getElementById('wx-vfx-roster-list') || {}).scrollTop || 0;
    box.innerHTML = renderSkillTheaterInner(filteredSkills);
    const nextList = document.getElementById('wx-vfx-roster-list');
    if (nextList) nextList.scrollTop = prevScroll;
    if (vfxState.collapsed) {
      stopStageVfx();
    } else {
      const cur = skillById.get(vfxState.skillId);
      if (cur) requestAnimationFrame(() => startSkillVfxCanvas('wx-vfx-stage-canvas', cur, false));
    }
  }

  function renderModalSkillVfxHtml(sk) {
    if (!sk || !sk.choreo) return '';
    const ch = sk.choreo;
    const proto = KINETIC_PROTOS[sk.id] || null;
    const isNewMode = !!(proto && !vfxState.useLegacyCompare && KINETIC_ASSETS.strips && KINETIC_ASSETS.strips[proto.seq]);
    const stripUri = VFX_ASSETS.strips[ch.anim] || '';
    let modalFrames = '';
    if (isNewMode) {
      const kUri = KINETIC_ASSETS.strips[proto.seq] || '';
      const kMeta = KINETIC_ASSETS.meta[proto.seq] || { count: 10 };
      const sampleFrames = [1, Math.floor(kMeta.count * 0.35), Math.floor(kMeta.count * 0.58), Math.max(0, kMeta.count - 3)];
      modalFrames = proto.beats.map((bn, fi) => {
        const sf = sampleFrames[fi];
        const posPct = kMeta.count > 1 ? ((sf * 100) / (kMeta.count - 1)).toFixed(2) : '0';
        return `
          <button type="button" class="wx-frame-btn" data-mvfx-frame="${fi}" aria-pressed="${vfxState.modalLockFrame === fi}">
            <span class="wx-frame-thumb" style="width:62px;height:44px;background-image:url('${kUri}');background-size:${kMeta.count * 100}% 100%;background-position:${posPct}% 50%"></span>
            <span>${esc(bn.split(' ')[0])}</span>
          </button>`;
      }).join('');
    } else {
      modalFrames = VFX_FRAME_NAMES.map((fn, fi) => `
        <button type="button" class="wx-frame-btn" data-mvfx-frame="${fi}" aria-pressed="${vfxState.modalLockFrame === fi}">
          <span class="wx-frame-thumb" style="width:48px;height:48px;background-image:url('${stripUri}');background-position:${(fi * 100) / 3}% 0"></span>
          <span>${esc(fn.split(' ')[0])}</span>
        </button>`).join('');
    }
    return `
      <div class="wx-modal-vfx" id="wx-modal-vfx-box" data-skill-id="${esc(sk.id)}">
        <div class="wx-modal-vfx-grid">
          <div class="wx-vfx-canvas-box">
            <canvas id="wx-modal-vfx-canvas" width="460" height="254"></canvas>
          </div>
          <div style="display:flex;flex-direction:column;gap:8px">
            <div style="font-size:13px;color:#ffe4a8;font-weight:700">${proto ? '✨ 新一代逐帧动效（' + esc(proto.seal) + '）· ' + esc(proto.sub) : '⚡ 实战招式动作与四帧拆解 · ' + esc(ch.label)}</div>
            <div style="font-size:12px;color:#cbb899;line-height:1.5">${isNewMode
              ? '逐帧图集 <code>' + esc(proto.seq) + '</code>（' + esc(proto.tag) + '）· 支持 1 格贴身实景与旧版贴图实时对比：'
              : '独立动作序列 <code>' + esc(ch.anim) + '</code> · 真罡气芒 <code>' + esc(ch.vfx) + '</code> · 点击下方 F1~F4 可逐帧定格检视招式形态：'}</div>
            <div class="wx-vfx-ctrl-left">
              <button type="button" class="wx-vfx-btn" data-mvfx-ctrl="play" aria-pressed="${vfxState.modalLockFrame < 0}">▶ 连续演武</button>
              <button type="button" class="wx-vfx-btn" data-mvfx-ctrl="slow" aria-pressed="${vfxState.modalSpeed < 0.8}">${vfxState.modalSpeed < 0.8 ? '🐢 0.45× 慢镜中' : '🐢 0.45× 慢镜'}</button>
              ${proto ? `<button type="button" class="wx-vfx-btn" data-mvfx-ctrl="range" aria-pressed="${vfxState.closeRange}">${vfxState.closeRange ? '⚔ 贴身1格' : '↔ 拉宽'}</button>` : ''}
              ${proto ? `<button type="button" class="wx-vfx-btn" data-mvfx-ctrl="compare" aria-pressed="${vfxState.useLegacyCompare}">${vfxState.useLegacyCompare ? '切回新版' : '🆚 对比旧版'}</button>` : ''}
              <button type="button" class="wx-vfx-btn" data-vfx-goto="${esc(sk.id)}">演武台全库对比 ↗</button>
            </div>
            <div class="wx-vfx-frames">${modalFrames}</div>
          </div>
        </div>
      </div>`;
  }
// === WX_SKILL_VFX_JS_END ==="""


def patch_html(html: str, bundle: dict) -> str:
    # 1. Strip any previous injected CSS / JS blocks cleanly so re-runs are 100% idempotent
    html = re.sub(re.escape(CSS_START) + r".*?" + re.escape(CSS_END) + r"\r?\n?", "", html, flags=re.S)
    html = re.sub(re.escape(JS_START) + r".*?" + re.escape(JS_END) + r"\r?\n?", "", html, flags=re.S)

    # 2. Inject CSS right before `</style>`
    assert "</style>" in html, "Could not locate </style>"
    html = html.replace("</style>", VFX_CSS_BLOCK + "\n</style>", 1)

    # 3. Replace `#wx-bundle` JSON payload
    m = re.search(r'(<script[^>]*id="wx-bundle"[^>]*>)(.*?)(</script>)', html, re.S)
    assert m, "Could not locate wx-bundle"
    new_json = json.dumps(bundle, ensure_ascii=False, separators=(",", ":"))
    html = html[: m.start(2)] + new_json + html[m.end(2) :]

    # 4. Inject VFX Engine JS right after `const creatureById = ...;`
    anchor_maps = "const creatureById = new Map(DB.bestiary.creatures.map(x => [x.id, x]));"
    assert anchor_maps in html, "Could not locate creatureById lookup map"
    html = html.replace(anchor_maps, anchor_maps + "\n\n" + VFX_JS_BLOCK, 1)

    # 5. Enrich `cardSkill(sk)` with choreography badge & action hint (idempotent replacement)
    card_skill_pat = re.compile(r"function cardSkill\(sk\)\s*\{.*?\n  \}", re.S)
    new_card_skill = """function cardSkill(sk) {
    const ch = sk.choreo || {};
    const proto = KINETIC_PROTOS[sk.id] || null;
    return `
      <button type="button" class="comp-card q-sect" data-open="skill:${esc(sk.id)}">
        <div class="card-top">
          ${iconHtml(sk.icon, '招')}
          <div class="card-title-box">
            <div class="card-title-row"><h3>${esc(sk.name)}${proto ? `<span class="wx-vfx-proto-badge">${esc(proto.seal)}</span>` : ''}</h3><span class="badge b-dark">${sk.ap} AP · ${sk.qi} 内息</span></div>
            <div class="card-sub">
              ${proto ? `<span class="badge b-gold">✨ ${esc(proto.sub)}</span>` : (ch.label ? `<span class="badge b-gold">⚡ ${esc(ch.label)}</span>` : '')}
              <span class="badge">射程 ${sk.minRange}~${sk.maxRange} 格</span>
              <span class="badge">${esc(formatWeapons(sk.weapons))}</span>
              ${sk.cooldown ? `<span class="badge b-sect">冷却 ${sk.cooldown} 轮</span>` : ''}
            </div>
          </div>
        </div>
        <div class="card-desc">${esc(sk.desc)}</div>
        <div class="card-foot">
          <span>传承：<strong>${sk.manuals.length ? sk.manuals.slice(0, 2).map(x => '《' + x.name + '》').join(' ') + (sk.manuals.length > 2 ? `等${sk.manuals.length}部` : '') : '基础/内功通用'}</strong></span>
          <span style="color:var(--cinnabar);font-weight:600">${proto ? '✨ 新版演武' : '▶ 动作特效'}</span>
        </div>
      </button>`;
  }"""
    assert card_skill_pat.search(html), "Could not locate cardSkill()"
    html = card_skill_pat.sub(lambda _: new_card_skill, html, count=1)

    # 6. Stop stage canvas when switching to Systems mode (`renderSystemsView`)
    sys_view_anchor = "function renderSystemsView() {"
    if "function renderSystemsView() {\n    stopStageVfx();" not in html:
        html = html.replace(sys_view_anchor, "function renderSystemsView() {\n    stopStageVfx();", 1)

    # 7. Render the 171-Skill 60fps Theater at the top of `wikiTab === 'skills' && sub === 'actives'`
    # Preserve existing mount (e.g., co-existing with ShanHai Bestiary Theater) if already wired!
    if "const showSkillTheater =" not in html:
        wiki_end_pat = re.compile(
            r"if \(!slice\.length\) \{\s*contentSlot\.innerHTML = `<div class=\"empty-box\">.*?;\s*return;\s*\}\s*contentSlot\.innerHTML = `.*?`;\s*(?:if \(showSkillTheater[\s\S]*?\}\s*)?\}",
            re.S,
        )
        new_wiki_end = """const showSkillTheater = (state.wikiTab === 'skills' && (state.subTab || 'actives') === 'actives');
    if (!showSkillTheater) stopStageVfx();
    const theaterMount = showSkillTheater ? `<section class="wx-vfx-theater" id="wx-vfx-theater-root">${renderSkillTheaterInner(list)}</section>` : '';

    if (!slice.length) {
      contentSlot.innerHTML = `${theaterMount}<div class="empty-box">当前分卷筛选条件下未找到匹配项。${q && allHits > 0 ? '可点击上方「全书跨卷检索」查看其他分卷中的结果。' : ''}</div>`;
      if (showSkillTheater && !vfxState.collapsed) {
        const curSk = skillById.get(vfxState.skillId);
        if (curSk) requestAnimationFrame(() => startSkillVfxCanvas('wx-vfx-stage-canvas', curSk, false));
      }
      return;
    }

    contentSlot.innerHTML = `
      ${theaterMount}
      <div class="card-grid">${slice.map(renderCard).join('')}</div>
      ${totalPages > 1 ? `
        <div class="pager">
          <button type="button" data-page="${state.page - 1}" ${state.page <= 1 ? 'disabled' : ''}>← 上一页</button>
          <span>第 ${state.page} / ${totalPages} 页</span>
          <button type="button" data-page="${state.page + 1}" ${state.page >= totalPages ? 'disabled' : ''}>下一页 →</button>
        </div>` : ''}`;
    if (showSkillTheater && !vfxState.collapsed) {
      const curSk = skillById.get(vfxState.skillId);
      if (curSk) requestAnimationFrame(() => startSkillVfxCanvas('wx-vfx-stage-canvas', curSk, false));
    }
  }"""
        assert wiki_end_pat.search(html), "Could not locate end of renderWikiView()"
        html = wiki_end_pat.sub(lambda _: new_wiki_end, html, count=1)

    # Also ensure `renderGlobalSearchResults` stops stage VFX
    gs_anchor = "function renderGlobalSearchResults(q, toolSlot, contentSlot) {"
    if "function renderGlobalSearchResults(q, toolSlot, contentSlot) {\n    stopStageVfx();" not in html:
        html = html.replace(gs_anchor, "function renderGlobalSearchResults(q, toolSlot, contentSlot) {\n    stopStageVfx();", 1)

    # 8. Inject live 60fps Skill Action & 4-Frame Breakdown into `openModal('skill:...')`
    if "stopModalVfx();" not in html.split("function openModal")[1][:350]:
        html = html.replace(
            "const [kind, id] = ref.split(':');",
            "stopModalVfx();\n    const [kind, id] = ref.split(':');",
            1,
        )

    modal_skill_pat = re.compile(
        r"else if \(kind === 'skill'\)\s*\{.*?\n    \}\n    else if \(kind === 'status'\)",
        re.S,
    )
    new_modal_skill = """else if (kind === 'skill') {
      const sk = skillById.get(id);
      if (!sk) return;
      vfxState.modalLockFrame = -1;
      const ch = sk.choreo || {};
      setHead(sk.name, `<span class="badge b-dark">${sk.ap} AP</span> <span class="badge b-sect">${sk.qi} 内息</span> <span class="badge">射程 ${sk.minRange}~${sk.maxRange} 格</span> ${ch.label ? `<span class="badge b-gold">⚡ ${esc(ch.label)}</span>` : ''}`, sk.icon, '招');
      bodyEl.innerHTML = `
        ${renderModalSkillVfxHtml(sk)}
        <p class="modal-lead">${esc(sk.desc)}</p>
        <div class="kv-grid">
          <div class="kv-cell"><small>要求兵器大类</small><strong>${esc(formatWeapons(sk.weapons))}</strong></div>
          <div class="kv-cell"><small>消耗行动点 / 内息</small><strong>${sk.ap} AP · ${sk.qi} 内息</strong></div>
          ${sk.directMult !== null ? `<div class="kv-cell"><small>招式基础穿甲率</small><strong>${sk.directMult}%</strong></div>` : ''}
          <div class="kv-cell"><small>调息冷却</small><strong>${sk.cooldown ? `${sk.cooldown} 回合` : '无冷却'}</strong></div>
        </div>
        <div class="modal-sec">
          <h3>传授此招式的武学秘籍 (${sk.manuals.length})</h3>
          ${sk.manuals.length
            ? `<div class="link-pills">${sk.manuals.map(m => `<button type="button" class="link-pill" data-open="manual:${esc(m.id)}">《${esc(m.name)}》（第${m.tier}重解锁）→</button>`).join('')}</div>`
            : `<p>任意内功或特定特殊状态自带招式。</p>`}
        </div>`;
      requestAnimationFrame(() => startSkillVfxCanvas('wx-modal-vfx-canvas', sk, true));
    }
    else if (kind === 'status')"""
    assert modal_skill_pat.search(html), "Could not locate kind === 'skill' in openModal()"
    html = modal_skill_pat.sub(lambda _: new_modal_skill, html, count=1)

    # 9. Add event delegation for theater & modal VFX controls + modal close cleanup
    if "modal.addEventListener('close', stopModalVfx);" not in html:
        html = html.replace(
            "const modal = document.getElementById('detail-modal');",
            "const modal = document.getElementById('detail-modal');\n  modal.addEventListener('close', stopModalVfx);",
            1,
        )

    # Clean any prior VFX click handlers inside document.addEventListener('click', ...)
    html = re.sub(r"\n    // --- WX_VFX_EVENTS_START ---.*?// --- WX_VFX_EVENTS_END ---\n", "\n", html, flags=re.S)
    vfx_click_handlers = """
    // --- WX_VFX_EVENTS_START ---
    const vfxToggle = e.target.closest('[data-vfx-toggle]');
    if (vfxToggle) {
      vfxState.collapsed = !vfxState.collapsed;
      refreshTheaterDom();
      return;
    }
    const vfxCatBtn = e.target.closest('[data-vfx-cat]');
    if (vfxCatBtn) {
      vfxState.cat = vfxCatBtn.dataset.vfxCat;
      vfxState.lockFrame = -1;
      renderWikiView();
      return;
    }
    const vfxPickBtn = e.target.closest('[data-vfx-pick]');
    if (vfxPickBtn) {
      vfxState.skillId = vfxPickBtn.dataset.vfxPick;
      vfxState.lockFrame = -1;
      refreshTheaterDom();
      return;
    }
    const vfxCtrlBtn = e.target.closest('[data-vfx-ctrl]');
    if (vfxCtrlBtn) {
      const act = vfxCtrlBtn.dataset.vfxCtrl;
      if (act === 'play') vfxState.lockFrame = -1;
      else if (act === 'slow') vfxState.speed = vfxState.speed < 0.8 ? 1.0 : 0.45;
      else if (act === 'range') vfxState.closeRange = !vfxState.closeRange;
      else if (act === 'compare') vfxState.useLegacyCompare = !vfxState.useLegacyCompare;
      refreshTheaterDom();
      return;
    }
    const vfxFrameBtn = e.target.closest('[data-vfx-frame]');
    if (vfxFrameBtn) {
      const fi = Number(vfxFrameBtn.dataset.vfxFrame);
      vfxState.lockFrame = (vfxState.lockFrame === fi) ? -1 : fi;
      refreshTheaterDom();
      return;
    }
    const mvfxCtrl = e.target.closest('[data-mvfx-ctrl]');
    if (mvfxCtrl) {
      const box = document.getElementById('wx-modal-vfx-box');
      const sk = box ? skillById.get(box.dataset.skillId) : null;
      if (sk) {
        const act = mvfxCtrl.dataset.mvfxCtrl;
        if (act === 'play') vfxState.modalLockFrame = -1;
        else if (act === 'slow') vfxState.modalSpeed = vfxState.modalSpeed < 0.8 ? 1.0 : 0.45;
        else if (act === 'range') vfxState.closeRange = !vfxState.closeRange;
        else if (act === 'compare') vfxState.useLegacyCompare = !vfxState.useLegacyCompare;
        box.outerHTML = renderModalSkillVfxHtml(sk);
        requestAnimationFrame(() => startSkillVfxCanvas('wx-modal-vfx-canvas', sk, true));
      }
      return;
    }
    const mvfxFrame = e.target.closest('[data-mvfx-frame]');
    if (mvfxFrame) {
      const box = document.getElementById('wx-modal-vfx-box');
      const sk = box ? skillById.get(box.dataset.skillId) : null;
      if (sk) {
        const fi = Number(mvfxFrame.dataset.mvfxFrame);
        vfxState.modalLockFrame = (vfxState.modalLockFrame === fi) ? -1 : fi;
        box.outerHTML = renderModalSkillVfxHtml(sk);
        requestAnimationFrame(() => startSkillVfxCanvas('wx-modal-vfx-canvas', sk, true));
      }
      return;
    }
    const vfxGoto = e.target.closest('[data-vfx-goto]');
    if (vfxGoto) {
      const targetId = vfxGoto.dataset.vfxGoto;
      modal.close();
      state.mode = 'wiki';
      state.wikiTab = 'skills';
      state.subTab = 'actives';
      vfxState.collapsed = false;
      vfxState.cat = 'all';
      vfxState.skillId = targetId;
      vfxState.lockFrame = -1;
      render();
      requestAnimationFrame(() => {
        const activeBtn = document.querySelector('#wx-vfx-roster-list [aria-pressed="true"]');
        if (activeBtn) activeBtn.scrollIntoView({ block: 'center' });
        window.scrollTo({ top: 120, behavior: 'smooth' });
      });
      return;
    }
    // --- WX_VFX_EVENTS_END ---
"""
    click_anchor = "document.addEventListener('click', e => {"
    assert click_anchor in html, "Could not locate click event listener"
    html = html.replace(click_anchor, click_anchor + vfx_click_handlers, 1)

    return html


def main():
    html = WIKI_PATH.read_text(encoding="utf-8")
    m = re.search(r'(<script[^>]*id="wx-bundle"[^>]*>)(.*?)(</script>)', html, re.S)
    assert m, "Could not locate wx-bundle in 山海武侠.html"
    bundle = json.loads(m.group(2))

    assert len(bundle["skills"]) == 171, f"Expected 171 skills in DB.skills, got {len(bundle['skills'])}"
    vfx_assets = build_vfx_assets_and_choreo(bundle["skills"])
    bundle["vfxAssets"] = vfx_assets

    out_html = patch_html(html, bundle)
    WIKI_PATH.write_text(out_html, encoding="utf-8")

    size_mb = WIKI_PATH.stat().st_size / (1024 * 1024)
    kin = vfx_assets.get("kinetic", {})
    print(
        f"Injected 171-skill 60fps VFX Theater into {WIKI_PATH.name}: "
        f"{len(vfx_assets['strips'])} 4-frame strips (684 frames), "
        f"{len(kin.get('strips', {}))} kinetic proto strips ({sum(m['count'] for m in kin.get('meta', {}).values())} frames), "
        f"{len(kin.get('parts', {}))} micro-particles, "
        f"{len(vfx_assets['vfx'])} Qi-auras, {len(vfx_assets['fx'])} Dharma FX, "
        f"{len(vfx_assets['rigs'])} articulated rigs, {len(vfx_assets['weapons'])} weapons -> {size_mb:.2f} MiB"
    )


if __name__ == "__main__":
    main()
