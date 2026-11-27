#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Theater V2 Visual & Interactive Upgrade Module for《山海武侠 · 江湖总录与百科图鉴》(`山海武侠.html`).

Upgrades BOTH 60fps Interactive Action Theaters:
  1.《山海万妖 · 多格法相与断部阵眼演武台》(`WX_SHANHAI_THEATER`):
     - Unpacks all `wx_tail_*` (+ `_injured`) sub-part sprites from `wx_beasts_0.brush` into `DB.bestiaryAssets.busts`.
     - Maps all 64 bespoke《山海经》Bosses (`segments` / `appendages` / `totems` / `mythic_law` & `duelist`)
       onto a true 2D Isometric Battle Brothers 5x3 Multi-Hex Arena (occupying 2~5 hexes!).
     - Adds interactive【⚔ 破部 / 斩首 / 射日沙盘】controls in both the main theater and creature detail modal,
       visibly shattering/cauterizing hex parts, severing totem tethers, and sealing bound Boss skills live!
     - Upgrades all 194 bespoke Boss moves & 225 wild beast moves from legacy geometric lines/polygons
       to HiDPI Retina (`devicePixelRatio`) 10~12-frame hand-painted `KINETIC_ASSETS` sequences + 28 particle sprites
       + exact 2D hex telegraph warnings + persistent `TileField` ground decals!

  2.《十三系国风流派 · 60fps 逐帧水墨演武剧场》(`WX_SKILL_VFX`):
     - Adds HiDPI Retina canvas scaling (`wxSetupHiDPICanvas`) + luminous core-preserving `wxGetTintedStrip`
       across both stage and modal canvases (fixing low-DPI stretch blur & dark multiply muddiness).
     - Upgrades floor to a 2.5D staggered isometric hex grid and adds bespoke multi-hex / multi-enemy
       stream choreographies for the refactored 13-family flagships:
         * 气剑驻场 & 万剑归宗 (`wx_sword_combo`, `wx_sword_zixia`, `wx_neigong_zixia`, `wx_sword_wanjian`)
         * 太极借力打力 / 姑苏斗转星移 2-enemy deflection (`wx_sword_taiji`, `wx_neigong_douzhuan`)
         * 少室隔山打牛 through-tank shockwave & 寸劲伏脉 3-stack burst (`wx_fist_shock`, `wx_fist_tiegang`, `wx_fist_luohan`, `wx_fist_rulai`)
         * 霸王挑山 / 盘龙过肩挑飞换位 (`wx_spear_bawang`, `wx_spear_panlong`)
         * 独孤九剑识兵破盾缴械 (`wx_sword_dugu`)
         * 大漠居合纳刀·孤月残心一闪 (`wx_saber_xinyue`, `wx_poise_charge`)
         * 唐门子母铁蒺藜·银丝倒卷收镖 (`wx_throw_fan`, `wx_throw_liuyedao`, `wx_throwing_rain`)
         * 寒暑蒸汽爆 / 烈火焚泽 / 雷池导电 (`wx_bow_luori`, `wx_gun_huolong`, `wx_hammer_leiting`)
     - Adds a dedicated `☯ 十三流派新机制` filter tab &同槽多段变招 indicator bar.
"""

from __future__ import annotations
import re
from pathlib import Path
from PIL import Image

from inject_wiki_shanhai_theater import load_brush_sprites, to_webp_uri, trim_and_fade_bust


# ==============================================================================
# 1. Sub-Part Sprite & Multi-Frame Kinetic Mapping for All 139 Shan-Hai Creatures
# ==============================================================================

SEGMENT_TAIL_MAP = {
    "zhuyin":       "wx_tail_zhuyin",
    "yinglong":     "wx_tail_yinglong",
    "feiyi":        "wx_tail_feiyi",
    "feiyi_wild":   "wx_tail_feiyi_wild",
    "gonggong":     "wx_tail_gonggong",
    "huashe":       "wx_tail_huashe",
    "xiangliuwang": "wx_tail_xiangliuwang",
    "jiuying":      "wx_tail_jiuying",
    "bashe":        "wx_tail_xiangliuwang",
    "hujiao":       "wx_tail_gonggong",
    "mingshe":      "wx_tail_feiyi",
}

TOTEM_SPRITE_HINTS = {
    "nvchou":   ("wx_boss_jinwu",      "fire"),
    "jinwu":    ("wx_boss_jinwu",      "fire"),
    "yuanchu":  ("wx_boss_jinwu",      "fire"),
    "jiuwei":   ("wx_beast_jiuwei_wild", "violet"),
    "jumang":   ("wx_beast_jianmu",    "jade"),
    "kuafu":    ("wx_beast_jianmu",    "fire"),
    "kui":      ("wx_tail_gonggong",   "violet"),
    "changyou": ("wx_tail_gonggong",   "frost"),
    "wuzhiqi":  ("wx_tail_gonggong",   "cyan"),
    "taotie":   ("wx_boss_taotie",     "crimson"),
    "dijiang":  ("wx_boss_dijiang",    "violet"),
    "chiyou":   ("wx_boss_chiyou",     "crimson"),
    "jingwei":  ("wx_beast_jingwei_wild", "cyan"),
    "yingzhao": ("wx_boss_yingzhao",   "gold"),
}

# Explicit Flagship 3 Boss Move Geometry + Field + Part-Lock Metadata
FLAGSHIP_SKILL_META = {
    "wx_boss_zhuyin_winter_breath":    {"geo": "cone_3",         "field": "abyss_frost",    "lockIdx": -1, "seq": "wx_kin_frost_burst",   "seq2": "wx_kin_tidal_wave",   "theme": "frost",   "tint": [185, 240, 255]},
    "wx_boss_zhuyin_summer_gale":      {"geo": "line_pierce_3",  "field": "drought_scorch", "lockIdx": -1, "seq": "wx_kin_flame_cleave",  "seq2": "wx_kin_flame_pillar", "theme": "fire",    "tint": [255, 200, 140]},
    "wx_boss_zhuyin_coil_crush":       {"geo": "tail_sweep_arc", "field": "",               "lockIdx": 0,  "seq": "wx_kin_bamboo_bind",   "seq2": "wx_kin_earth_shatter","theme": "gold",    "tint": [255, 220, 150]},
    "wx_boss_zhuyin_primordial_wind":  {"geo": "ring_aoe_2",     "field": "gale_sandstorm", "lockIdx": -1, "seq": "wx_kin_whirl_cyclone", "seq2": "wx_kin_sonic_wave",   "theme": "cyan",    "tint": [190, 248, 255]},
    "wx_boss_xiangliu_nine_devour":    {"geo": "multi_bite_3",   "field": "bitter_mire",    "lockIdx": -1, "seq": "wx_kin_claw_rend",     "seq2": "wx_kin_venom_mire",   "theme": "venom",   "tint": [185, 255, 150]},
    "wx_boss_xiangliu_mire_ram":       {"geo": "line_charge_3",  "field": "bitter_mire",    "lockIdx": 0,  "seq": "wx_kin_earth_shatter", "seq2": "wx_kin_venom_mire",   "theme": "venom",   "tint": [175, 255, 165]},
    "wx_boss_xiangliu_poison_deluge":  {"geo": "field_detonate", "field": "bitter_mire",    "lockIdx": 1,  "seq": "wx_kin_venom_mire",    "seq2": "wx_kin_tidal_wave",   "theme": "venom",   "tint": [160, 255, 130]},
    "wx_boss_xiangliu_miasma_hex":     {"geo": "hex_curse",      "field": "mirage_mist",    "lockIdx": 2,  "seq": "wx_kin_soul_vortex",   "seq2": "wx_kin_smoke_cloud",  "theme": "violet",  "tint": [215, 180, 255]},
    "wx_boss_nvchou_ten_suns_ray":     {"geo": "ten_suns_ray",   "field": "drought_scorch", "lockIdx": -1, "seq": "wx_kin_celestial_beam","seq2": "wx_kin_flame_pillar", "theme": "fire",    "tint": [255, 232, 155]},
    "wx_boss_nvchou_sleeve_shift":     {"geo": "totem_swap",     "field": "mirage_mist",    "lockIdx": -1, "seq": "wx_kin_warp_seal",     "seq2": "wx_kin_qinggong_gust","theme": "gold",    "tint": [255, 235, 175]},
    "wx_boss_nvchou_scorch_apocalypse":{"geo": "omen_cataclysm", "field": "drought_scorch", "lockIdx": 1,  "seq": "wx_kin_flame_pillar",  "seq2": "wx_kin_cannon_blast", "theme": "fire",    "tint": [255, 185, 115]},
}


def pick_boss_kinetic_spec(sk: dict, creature: dict) -> tuple[str, str, str, list[int]]:
    """Maps any Boss or Wild Beast skill to crisp 10~12-frame KINETIC_ASSETS sequences!"""
    sid = sk.get("id", "")
    if sid in FLAGSHIP_SKILL_META:
        m = FLAGSHIP_SKILL_META[sid]
        return m["seq"], m["seq2"], m["theme"], m["tint"]

    txt = f"{sk.get('name', '')} {sk.get('desc', '')} {' '.join(sk.get('effects') or [])}"
    fld = sk.get("field", "")
    geo = sk.get("geo", "")
    amode = sk.get("animMode", "")

    # Elemental priority first so fire/frost/venom/thunder/water/wind match canon!
    if fld == "abyss_frost" or any(k in txt for k in ("玄冥", "寒", "冰", "霜", "雪", "冻")):
        return "wx_kin_frost_burst", "wx_kin_snow_step", "frost", [195, 242, 255]
    if fld == "thunder_pool" or any(k in txt for k in ("雷", "电", "霆", "紫电", "震天鼓")):
        return "wx_kin_thunder_bolt", "wx_kin_sonic_wave", "violet", [225, 195, 255]
    if fld == "bitter_mire" or any(k in txt for k in ("毒", "瘴", "蛊", "苦泉", "腐泽", "疫", "腥")):
        seq2 = "wx_kin_flying_knives" if amode == "venom_needle_barrage" else "wx_kin_smoke_cloud"
        return "wx_kin_venom_mire", seq2, "venom", [185, 255, 150]
    if fld == "drought_scorch" or any(k in txt for k in ("炎", "火", "炙", "焚", "日", "旱", "熔")):
        if geo in ("line_pierce_3", "ten_suns_ray"):
            return "wx_kin_celestial_beam", "wx_kin_flame_pillar", "fire", [255, 215, 145]
        return "wx_kin_flame_cleave", "wx_kin_flame_pillar", "fire", [255, 198, 135]
    if any(k in txt for k in ("洪", "涛", "水", "浪", "潮", "江", "渊", "溺")):
        return "wx_kin_tidal_wave", "wx_kin_dragon_surge", "cyan", [175, 242, 255]
    if fld in ("gale_sandstorm", "gale_sand") or any(k in txt for k in ("朔风", "狂风", "沙暴", "飓", "风刃", "飙")):
        return "wx_kin_whirl_cyclone", "wx_kin_qinggong_gust", "jade", [190, 255, 230]
    if fld == "mirage_mist" or geo in ("totem_swap", "hex_curse") or amode in ("fox_charm_miasma", "dream_shadow_ambush"):
        seq1 = "wx_kin_warp_seal" if geo == "totem_swap" or amode == "dream_shadow_ambush" else "wx_kin_soul_vortex"
        return seq1, "wx_kin_sonic_wave", "violet", [225, 188, 255]

    # Geometry & Archetype fallback
    if geo in ("totem_ray", "ten_suns_ray"):
        return "wx_kin_celestial_beam", "wx_kin_flame_pillar", "celestial", [255, 236, 165]
    if geo in ("ranged_barrage",) or amode == "venom_needle_barrage":
        return "wx_kin_peacock_fan", "wx_kin_flying_knives", "gold", [255, 228, 160]
    if geo in ("multi_bite_3", "single") or amode in ("multi_head_frenzy", "feral_pounce"):
        return "wx_kin_claw_rend", "wx_kin_blood_arc", "crimson", [255, 180, 185]
    if geo in ("sky_dive", "leap_slam_3") or amode == "sky_talon_dive":
        return "wx_kin_phoenix_spear", "wx_kin_claw_rend", "gold", [255, 225, 160]
    if geo in ("boulder_throw", "omen_cataclysm", "telegraph_omen") or amode in ("ape_titan_slam", "boulder_hurl_smash", "shell_thorns_quake"):
        return "wx_kin_earth_shatter", "wx_kin_giant_axe", "gold", [255, 224, 168]
    if geo in ("ring_aoe_1", "ring_quake_6") or amode == "headless_waraxe":
        return "wx_kin_giant_axe", "wx_kin_earth_shatter", "crimson", [255, 185, 170]
    if geo in ("ring_aoe_2", "sonic_roar") or amode == "sonic_dread_roar":
        return "wx_kin_sonic_wave", "wx_kin_whirl_cyclone", "violet", [225, 195, 255]
    if geo in ("pull_devour",) or amode in ("abyss_tentacle_drag", "devour_blood_siphon"):
        return "wx_kin_whip_lash", "wx_kin_soul_vortex", "crimson", [255, 175, 190]
    if geo in ("tail_sweep_arc",) or amode in ("coiled_crush", "corpse_chain_cleave", "root_thorn_entangle"):
        return "wx_kin_bamboo_bind", "wx_kin_earth_shatter", "jade", [185, 255, 210]
    if geo in ("line_pierce_3", "line_charge_3") or amode == "horn_gore_charge":
        return "wx_kin_dragon_surge", "wx_kin_spear_drill", "gold", [255, 232, 175]

    return "wx_kin_claw_rend", "wx_kin_earth_shatter", "fire", [255, 205, 155]


# Enriched subtitles/tags for newly refactored Wuxia 13-stream skills in KINETIC_PROTOS
STREAM_PROTO_PATCHES = {
    "actives.wx_sword_combo": {
        "sub": "同槽三式递进 · 凝气驻剑",
        "seal": "三剑",
        "tag": "一式起剑 → 二式承剑凝影 → 三式贯虹在六角格布设【驻场气剑】！",
        "beats": ["1. 一式起剑", "2. 二式承锋", "3. 凝气驻剑", "4. 剑阵成形"],
    },
    "actives.wx_sword_wanjian": {
        "sub": "万剑归宗 · 拔剑直线贯通",
        "seal": "万剑",
        "tag": "拔起全场【驻场气剑】沿六角格直线破空合击贯通敌阵 + 回补16内息！",
        "beats": ["1. 驻剑共鸣", "2. 剑指苍穹", "3. 拔剑贯阵", "4. 归元回气"],
    },
    "actives.wx_sword_dugu": {
        "sub": "独孤九剑 · 识破六兵拆招",
        "seal": "破兵",
        "tag": "看破敌方所持剑/刀/枪/重兵/盾/弓六类兵装 → 针对性碎盾缴械破招！",
        "beats": ["1. 慧眼识兵", "2. 寻隙直入", "3. 碎盾夺刃", "4. 收剑无招"],
    },
    "actives.wx_sword_taiji": {
        "sub": "太极圆转 · 借力打力偏转",
        "seal": "太极",
        "tag": "云手划圆化解敌甲攻势 → 将来袭劲力原封偏转轰入相邻敌乙同伙！",
        "beats": ["1. 敌甲扑击", "2. 太极引化", "3. 借力偏转", "4. 四两拨千"],
    },
    "actives.wx_neigong_douzhuan": {
        "sub": "姑苏星璇 · 移劲反施彼身",
        "seal": "斗转",
        "tag": "星璇气海牵引来袭杀招 → 颠倒乾坤移劲轰向敌侧同伙并回补内息！",
        "beats": ["1. 星璇纳劲", "2. 乾坤逆旋", "3. 以彼之道", "4. 还施彼身"],
    },
    "actives.wx_saber_xinyue": {
        "sub": "大漠居合 · 拔刀孤月残心",
        "seal": "居合",
        "tag": "纳刀藏锋蓄势 → 必中瞬闪穿身『拔刀·孤月一闪』→ 残心归鞘返AP回气！",
        "beats": ["1. 纳刀藏锋", "2. 孤月一闪", "3. 血绽延迟", "4. 残心归鞘"],
    },
    "actives.wx_spear_bawang": {
        "sub": "霸王挑山 · 挑飞过肩换位",
        "seal": "挑山",
        "tag": "霸王神力枪尖垫步下挑 → 将正前重盾敌军挑飞翻越肩头砸入身后格！",
        "beats": ["1. 垫步沉枪", "2. 挑山拔地", "3. 过肩翻空", "4. 砸地裂阵"],
    },
    "actives.wx_spear_panlong": {
        "sub": "长风盘龙 · 挑飞撕裂前排",
        "seal": "盘龙",
        "tag": "长枪如蛟龙出水缠腰上挑 → 将敌军挑过头顶甩至身后瓦解盾阵！",
        "beats": ["1. 潜蛟入海", "2. 盘龙缠挑", "3. 腾空越顶", "4. 震坠失衡"],
    },
    "actives.wx_staff_dagou": {
        "sub": "同槽三诀 · 绊缠天下无狗",
        "seal": "打狗",
        "tag": "同槽递进『绊字诀→缠字诀→天下无狗』青竹盘根横扫群寇封步缴械！",
        "beats": ["1. 绊字封步", "2. 缠字锁脉", "3. 天下无狗", "4. 绿竹收势"],
    },
    "actives.wx_fist_shock": {
        "sub": "隔山打牛 · 透盾轰震后排",
        "seal": "隔山",
        "tag": "内家掌劲轻拍前排铁盾 → 掌力无损透体在后排敌军体内炸裂 + 叠寸劲伏脉！",
        "beats": ["1. 贴盾吐劲", "2. 掌力透体", "3. 隔山轰后", "4. 寸劲爆脉"],
    },
    "actives.wx_throw_fan": {
        "sub": "漫天花雨 · 银丝子母收镖",
        "seal": "收镖",
        "tag": "七星飞刀齐射 → 银丝倒卷拔起场上【子母铁蒺藜】背刺贯敌并回收+1弹药！",
        "beats": ["1. 扇雨齐发", "2. 钉阵共鸣", "3. 银丝收镖", "4. 归匣补弹"],
    },
    "actives.wx_bow_luori": {
        "sub": "大荒落日 · 射日破阵蒸爆",
        "seal": "射日",
        "tag": "纯阳火箭贯空点灭大妖阵眼 → 轰击玄冥冻土/苦毒腐泽引发寒暑蒸汽爆！",
        "beats": ["1. 满月挽弓", "2. 大日流星", "3. 焚冰蒸爆", "4. 赤地余威"],
    },
    "actives.wx_gun_huolong": {
        "sub": "神机火龙 · 焚泽蒸汽轰爆",
        "seal": "火龙",
        "tag": "赤硝火龙喷薄 → 瞬间烘干苦毒腐泽或引爆冻土高温蒸汽崩裂重甲！",
        "beats": ["1. 赤硝引火", "2. 火龙出膛", "3. 焚泽蒸爆", "4. 硝云漫卷"],
    },
    "actives.wx_hammer_leiting": {
        "sub": "雷霆万钧 · 流波雷池导电",
        "seal": "雷池",
        "tag": "重锤引落九天紫电轰入【流波雷池】→ 闪电沿水泽传导连环碎裂大妖玄壳！",
        "beats": ["1. 举锤引雷", "2. 紫电贯地", "3. 雷泽导电", "4. 玄壳崩碎"],
    },
}


def pack_full_part_sprite(im: Image.Image, target_size=(116, 128)) -> Image.Image:
    """Resizes dedicated `wx_part_*` / `wx_totem_*` / `wx_tail_*` sprites cleanly WITHOUT waist-cutoff fade."""
    src = im.convert("RGBA")
    tw, th = target_size
    scale = min(tw / max(1, src.width), th / max(1, src.height))
    nw = max(1, int(round(src.width * scale)))
    nh = max(1, int(round(src.height * scale)))
    rs = src.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    canvas.paste(rs, ((tw - nw) // 2, (th - nh) // 2))
    return canvas


INTERNAL_BREAK_MODE_LABELS = {
    "blunt":  "🔨 重锤/寸劲碎壳",
    "ranged": "🏹 神射/暗器点破",
    "blade":  "⚔ 利刃斩断",
    "spear":  "🔱 长兵破角",
    "heavy":  "🪓 重兵碎盾",
    "yang":   "🔥 纯阳/火器破煞",
}

TOTEM_THEME_BY_BRUSH = {
    "wx_totem_sun_corona":       "fire",
    "wx_totem_fusang_sun":       "fire",
    "wx_totem_fox_lantern":      "violet",
    "wx_totem_jianmu_root":      "jade",
    "wx_totem_peach_staff":      "jade",
    "wx_totem_chiyou_armory":    "crimson",
    "wx_totem_thunder_vortex":   "violet",
    "wx_totem_ice_dragon_pillar":"frost",
    "wx_totem_spirit_stone":     "cyan",
    "wx_totem_space_rift":       "violet",
}


def enrich_bundle_for_theaters(bundle: dict, mod_dir: Path, cat_specs: dict, cat_moves: dict):
    """Packs dedicated `wx_part_*`, `wx_totem_*`, and `wx_tail_*` sprites and enriches all 139 creatures + 171 skills."""
    beasts_brush = load_brush_sprites(mod_dir / "brushes" / "wx_beasts_0.brush")
    busts_dict = bundle.setdefault("bestiaryAssets", {}).setdefault("busts", {})

    # 1) Pack ALL dedicated `wx_tail_*`, `wx_part_*`, and `wx_totem_*` (+ `*_injured`) sprites with full un-cropped bases!
    packed_parts = 0
    for sid, im in beasts_brush.items():
        if sid.startswith(("wx_tail_", "wx_part_", "wx_totem_")):
            busts_dict[sid] = to_webp_uri(pack_full_part_sprite(im, (116, 128)), quality=82)
            packed_parts += 1

    # Also ensure wild `wx_beast_feiyi_wild` shows its 2-tile nature!
    for c in bundle["bestiary"]["creatures"]:
        key = c["key"]
        is_boss = c.get("kind") == "boss"

        if not is_boss:
            if key == "feiyi_wild":
                c["structureMode"] = "segments"
                c["structureLabel"] = "双格盘蛇躯"
                c["parts"] = [{"name": "肥遗·盘绕蛇尾", "brush": "wx_tail_feiyi_wild", "stats": "共享躯干 / 摆尾扫击", "role": "双格同进退蛇尾，协同本体发动盘尾横扫", "sprite": "wx_tail_feiyi_wild", "injuredSprite": "wx_tail_feiyi_wild_injured"}]
            for sk in c.get("skills") or []:
                seq1, seq2, thm, tnt = pick_boss_kinetic_spec(sk, c)
                sk["kinSeq"] = seq1
                sk["kinSeq2"] = seq2
                sk["kinTheme"] = thm
                sk["kinTint"] = tnt
                sk.setdefault("geo", "cone_3" if sk.get("animMode") == "dragon_breath" else "melee_crush")
            continue

        # Boss enrichment!
        smode = c.get("structureMode", "mythic_law")
        if smode == "duelist":
            c["structureMode"] = "mythic_law"
            smode = "mythic_law"

        init_field = ""
        if key in ("zhuyin", "xiangliuwang", "nvchou"):
            init_field = {"zhuyin": "abyss_frost", "xiangliuwang": "bitter_mire", "nvchou": "drought_scorch"}[key]
        elif key in cat_specs:
            init_field = cat_specs[key].get("initField", "")
        c["initField"] = init_field

        # Assign 100% dedicated compiled brush sprites directly from `.nut` `Brush` field!
        parts = c.get("parts") or []
        raw_sp_parts = (cat_specs.get(key, {}).get("parts") or []) if key in cat_specs else []
        for idx, pt in enumerate(parts):
            brush_id = pt.get("brush") or (raw_sp_parts[idx].get("brush") if idx < len(raw_sp_parts) else "")
            if not brush_id:
                brush_id = SEGMENT_TAIL_MAP.get(key, c["id"])
            assert brush_id in busts_dict, f"Missing compiled part/totem sprite in busts_dict: {brush_id} for {key}"
            inj_id = f"{brush_id}_injured" if f"{brush_id}_injured" in busts_dict else brush_id
            pt["sprite"] = brush_id
            pt["injuredSprite"] = inj_id
            if smode == "totems":
                pt["totemTheme"] = TOTEM_THEME_BY_BRUSH.get(brush_id, "gold")
            if idx < len(raw_sp_parts) and raw_sp_parts[idx].get("lockSkill"):
                pt["lockSkillId"] = raw_sp_parts[idx]["lockSkill"].replace("actives.", "")

        # Enrich 1-Hex / Master-Body `internalBreak` counterplay metadata
        ib = c.get("internalBreak")
        ib_lock_sid = ""
        if ib:
            ib["modeLabel"] = INTERNAL_BREAK_MODE_LABELS.get(ib.get("mode", "heavy"), "⚔ 破绽击破")
            ib_lock_sid = (ib.get("lockSkill") or "").replace("actives.", "")
            ib["lockSkillId"] = ib_lock_sid

        # Enrich all Boss skills with `geo`, `field`, `lockedByPartIdx`, `lockedByInternal`, and `kinSeq`!
        for sk in c.get("skills") or []:
            sid = sk.get("id", "")
            sk["lockedByInternal"] = bool(ib_lock_sid and sid == ib_lock_sid)
            if sid in FLAGSHIP_SKILL_META:
                fm = FLAGSHIP_SKILL_META[sid]
                sk["geo"] = fm["geo"]
                sk["field"] = fm["field"]
                sk["lockedByPartIdx"] = fm["lockIdx"]
                if fm["lockIdx"] >= 0 and fm["lockIdx"] < len(parts):
                    parts[fm["lockIdx"]]["lockSkillId"] = sid
            elif sid in cat_moves:
                mv = cat_moves[sid]
                sk["geo"] = mv["geo"]
                sk["field"] = mv["field"]
                lock_idx = -1
                for pidx, rpt in enumerate(raw_sp_parts):
                    if rpt.get("lockSkill") == f"actives.{sid}":
                        lock_idx = pidx
                        break
                sk["lockedByPartIdx"] = lock_idx

            seq1, seq2, thm, tnt = pick_boss_kinetic_spec(sk, c)
            sk["kinSeq"] = seq1
            sk["kinSeq2"] = seq2
            sk["kinTheme"] = thm
            sk["kinTint"] = tnt

    # 2) Patch KINETIC_PROTOS metadata for newly refactored 13-stream Wuxia skills!
    kin_cat = ((bundle.get("vfxAssets") or {}).get("kinetic") or {}).get("catalog") or {}
    for sid, patch in STREAM_PROTO_PATCHES.items():
        if sid in kin_cat:
            kin_cat[sid].update(patch)

    return packed_parts


# ==============================================================================
# 2. Upgraded CSS & JS Blocks for Both 60fps Action Theaters
# ==============================================================================

SHANHAI_THEATER_CSS_V2 = """/* === WX_SHANHAI_THEATER_CSS_START === */
.wx-sh-theater {
  margin: 0 0 18px 0;
  background: linear-gradient(180deg, #1b1411 0%, #100c0a 100%);
  border: 1.5px solid #5a3c2e;
  border-radius: 10px;
  box-shadow: 0 10px 28px rgba(24, 12, 8, 0.32);
  color: #efe2ca;
  overflow: hidden;
}
.wx-sh-head {
  display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between;
  gap: 10px; padding: 12px 16px;
  background: linear-gradient(90deg, rgba(168, 52, 34, 0.30), rgba(92, 56, 30, 0.16));
  border-bottom: 1px solid rgba(210, 126, 86, 0.28);
}
.wx-sh-head h3 {
  margin: 0; font-size: 16.5px; color: #ffdfa4; letter-spacing: 0.5px;
  display: flex; align-items: center; gap: 8px;
}
.wx-sh-head p { margin: 3px 0 0 0; font-size: 12px; color: #d2bda0; }
.wx-sh-cats {
  display: flex; flex-wrap: wrap; gap: 6px; padding: 10px 14px;
  background: rgba(12, 9, 8, 0.62);
  border-bottom: 1px solid rgba(255, 255, 255, 0.07);
}
.wx-sh-cat {
  border: 1px solid #4d362b; background: #221815; color: #decab0;
  font-size: 12px; padding: 4px 11px; border-radius: 16px; cursor: pointer;
  transition: all 0.15s;
}
.wx-sh-cat:hover { border-color: #df8956; color: #fff; }
.wx-sh-cat[aria-pressed="true"] {
  background: linear-gradient(180deg, #943022, #5d1b12);
  border-color: #f6aa6c; color: #fff8ea; font-weight: 700;
  box-shadow: 0 0 10px rgba(242, 136, 75, 0.28);
}
.wx-sh-body {
  display: grid; grid-template-columns: 282px minmax(0, 1fr);
  min-height: 460px;
}
.wx-sh-roster {
  border-right: 1px solid rgba(255, 255, 255, 0.08);
  max-height: 580px; overflow-y: auto; padding: 8px;
  background: rgba(13, 9, 8, 0.72);
}
.wx-sh-pick {
  width: 100%; display: flex; align-items: center; gap: 8px; text-align: left;
  padding: 6px 8px; margin-bottom: 5px; border-radius: 6px;
  border: 1px solid transparent; background: rgba(255, 255, 255, 0.028);
  color: #eadcc4; cursor: pointer; transition: all 0.14s;
}
.wx-sh-pick:hover { background: rgba(224, 114, 72, 0.14); border-color: rgba(236, 134, 86, 0.36); }
.wx-sh-pick[aria-pressed="true"] {
  background: linear-gradient(90deg, rgba(172, 54, 35, 0.46), rgba(74, 38, 22, 0.24));
  border-color: #f1a062; color: #fff9ec;
}
.wx-sh-pick img {
  width: 36px; height: 36px; border-radius: 5px; object-fit: cover; flex-shrink: 0;
  border: 1px solid rgba(255, 214, 152, 0.36); background: #140f0c;
}
.wx-sh-pick-meta { min-width: 0; flex: 1; }
.wx-sh-pick-name { font-size: 13px; font-weight: 700; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.wx-sh-pick-sub { font-size: 11px; color: #c2ab90; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.wx-sh-stage-col {
  padding: 14px 16px; display: flex; flex-direction: column; gap: 9px;
}
.wx-sh-stage-top {
  display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 8px;
}
.wx-sh-stage-title { font-size: 17px; font-weight: 700; color: #ffe2b4; display: flex; align-items: center; gap: 7px; flex-wrap: wrap; }
.wx-sh-pill {
  font-size: 11px; padding: 2px 8px; border-radius: 12px;
  background: rgba(242, 162, 102, 0.16); border: 1px solid rgba(242, 162, 102, 0.45);
  color: #ffda9e;
}
.wx-sh-pill.mode {
  background: rgba(168, 48, 34, 0.35); border-color: #f08c64; color: #ffe6dc;
}
.wx-sh-pill.field {
  background: rgba(34, 98, 84, 0.38); border-color: #6fd4b8; color: #dcfff3;
}
.wx-sh-law-bar {
  background: linear-gradient(90deg, rgba(124, 38, 24, 0.32), rgba(32, 22, 18, 0.72));
  border: 1px solid rgba(238, 166, 98, 0.36);
  border-radius: 7px; padding: 8px 11px; font-size: 12px; line-height: 1.5; color: #eedec6;
  display: flex; flex-direction: column; gap: 6px;
}
.wx-sh-parts-row {
  display: flex; flex-wrap: wrap; gap: 6px; align-items: center;
}
.wx-sh-part-btn {
  border: 1px solid #7d4c34; background: #2b1a14; color: #ffe3ba;
  font-size: 11.5px; padding: 3px 9px; border-radius: 5px; cursor: pointer;
  transition: all 0.14s;
}
.wx-sh-part-btn:hover { border-color: #ffba70; background: #42251a; color: #fff; }
.wx-sh-part-btn.broken {
  background: #4e1714; border-color: #ff6b5b; color: #ffd4ce;
  text-decoration: line-through;
}
.wx-sh-skill-tabs {
  display: flex; flex-wrap: wrap; gap: 6px;
}
.wx-sh-sk-tab {
  border: 1px solid #563a2c; background: #231814; color: #e2cfb6;
  font-size: 12px; padding: 6px 11px; border-radius: 7px; cursor: pointer;
  display: inline-flex; align-items: center; gap: 6px; transition: all 0.14s;
}
.wx-sh-sk-tab:hover { border-color: #e89b5d; color: #fff; }
.wx-sh-sk-tab[aria-pressed="true"] {
  background: linear-gradient(180deg, #8b2f1f, #551b11);
  border-color: #ffbd7a; color: #fff9ee; font-weight: 700;
  box-shadow: 0 0 12px rgba(242, 128, 72, 0.30);
}
.wx-sh-sk-tab.sealed {
  border-color: #8f3932; color: #e29b94; background: #2a1312;
}
.wx-sh-canvas-wrap {
  position: relative; border-radius: 8px; overflow: hidden;
  border: 1px solid #583d2e; background: #0d0907;
  display: flex; justify-content: center; align-items: center;
  box-shadow: inset 0 0 26px rgba(0, 0, 0, 0.72);
}
.wx-sh-canvas-wrap canvas {
  display: block; width: 100%; max-width: 580px; height: auto; aspect-ratio: 540 / 300;
}
.wx-sh-ctrl-bar {
  display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 8px;
}
.wx-sh-btn {
  border: 1px solid #584130; background: #261b15; color: #eddcc0;
  font-size: 12px; padding: 5px 11px; border-radius: 6px; cursor: pointer;
}
.wx-sh-btn:hover { border-color: #e8a566; color: #fff; }
.wx-sh-btn[aria-pressed="true"] { background: #7f2d1d; border-color: #f4b26e; color: #fff; font-weight: 700; }
.wx-sh-info-box {
  background: rgba(255, 255, 255, 0.038); border: 1px solid rgba(255, 214, 152, 0.16);
  border-radius: 7px; padding: 9px 12px; font-size: 12.5px; line-height: 1.55; color: #e5d5bd;
}
.wx-sh-info-meta {
  display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 5px;
}
.wx-modal-sh-box {
  margin: 0 0 14px 0; padding: 12px; border-radius: 8px;
  background: linear-gradient(180deg, #1b1411, #100c0a);
  border: 1px solid #5a3c2d; color: #efe2ca;
}
.wx-modal-sh-grid {
  display: grid; grid-template-columns: minmax(270px, 1.32fr) minmax(210px, 1fr); gap: 12px; align-items: start;
}
.wx-sh-sk-card-act {
  margin-left: auto; border: 1px solid #8a4326; background: #3b1c12; color: #ffdca8;
  font-size: 11px; padding: 3px 9px; border-radius: 12px; cursor: pointer;
}
.wx-sh-sk-card-act:hover { background: #6b2916; color: #fff; }
.wx-sh-sk-card-act[aria-pressed="true"] { background: #9c341d; border-color: #ffbe75; color: #fff; font-weight: 700; }
@media (max-width: 880px) {
  .wx-sh-body { grid-template-columns: 1fr; }
  .wx-sh-roster { max-height: 230px; border-right: none; border-bottom: 1px solid rgba(255, 255, 255, 0.08); }
  .wx-modal-sh-grid { grid-template-columns: 1fr; }
}
/* === WX_SHANHAI_THEATER_CSS_END === */"""


SKILL_VFX_TOP_JS_V2 = r"""// === WX_SKILL_VFX_JS_START ===
  const VFX_ASSETS = DB.vfxAssets || { strips: {}, vfx: {}, fx: {}, rigs: {}, enemies: {}, projs: {}, weapons: {}, kinetic: { strips: {}, meta: {}, parts: {}, catalog: {} } };
  const KINETIC_ASSETS = VFX_ASSETS.kinetic || { strips: {}, meta: {}, parts: {}, catalog: {} };
  const KINETIC_PROTOS = KINETIC_ASSETS.catalog || {};

  // HiDPI Retina Canvas Helper (eliminates CSS upscale blur on 1.25x~2x displays!)
  function wxSetupHiDPICanvas(cv, logicalW, logicalH, ctx) {
    const dpr = Math.min(2, Math.max(1, window.devicePixelRatio || 1));
    const pw = Math.round(logicalW * dpr);
    const ph = Math.round(logicalH * dpr);
    if (cv.width !== pw || cv.height !== ph) {
      cv.width = pw;
      cv.height = ph;
    }
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.imageSmoothingEnabled = true;
    if ('imageSmoothingQuality' in ctx) ctx.imageSmoothingQuality = 'high';
    return { W: logicalW, H: logicalH, dpr };
  }

  const VFX_STREAM_IDS = [
    'actives.wx_sword_combo', 'actives.wx_sword_wanjian', 'actives.wx_sword_dugu', 'actives.wx_sword_taiji',
    'actives.wx_neigong_douzhuan', 'actives.wx_saber_xinyue', 'actives.wx_saber_kuangfeng', 'actives.wx_saber_xuehai',
    'actives.wx_saber_modao', 'actives.wx_spear_bawang', 'actives.wx_spear_panlong', 'actives.wx_spear_guard',
    'actives.wx_staff_dagou', 'actives.wx_whip_suohou', 'actives.wx_fist_shock', 'actives.wx_fist_rulai',
    'actives.wx_fist_xianglong', 'actives.wx_fist_yiyang', 'actives.wx_fist_qishang', 'actives.wx_hama_push',
    'actives.wx_hammer_leiting', 'actives.wx_dagger_jingke', 'actives.wx_throw_fan', 'actives.wx_bow_luori',
    'actives.wx_gun_huolong', 'actives.wx_tactics_bamen'
  ];
  const VFX_FEATURED_IDS = [
    'actives.wx_sword_combo', 'actives.wx_sword_wanjian', 'actives.wx_sword_taiji', 'actives.wx_fist_shock',
    'actives.wx_spear_bawang', 'actives.wx_sword_dugu', 'actives.wx_saber_xinyue', 'actives.wx_throw_fan',
    'actives.wx_fist_xianglong', 'actives.wx_saber_ranmu', 'actives.wx_hammer_leiting', 'actives.wx_sword_tianwai',
    'actives.wx_saber_xuehai', 'actives.wx_staff_dagou', 'actives.wx_axe_kaitian', 'actives.wx_fist_rulai',
    'actives.wx_neigong_douzhuan', 'actives.wx_hama_push', 'actives.wx_bow_luori', 'actives.wx_gun_huolong',
    'actives.wx_throw_kongque', 'actives.wx_shield_xuanwu', 'actives.wx_rally_command', 'actives.wx_tactics_jinzhen',
    'actives.wx_qinggong_xuelian', 'actives.wx_qinggong_suodi', 'actives.wx_smoke_cast', 'actives.wx_dagger_jingke'
  ];
  const VFX_CAT_DEFS = [
    ['streams', '☯ 十三流派新机制 (26)'],
    ['featured', '✨ 镇派精选 (28)'],
    ['all', `全部逐帧动效 (${DB.skills.length})`],
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
    cat: 'streams',
    skillId: 'actives.wx_sword_wanjian',
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
    if (k.includes('jingang') || k.includes('rulai') || k.includes('weituo') || k.includes('luohan') || k.includes('yijin') || k.includes('jinzhong') || k.includes('ranmu') || k.includes('shihou') || k === 'wx_fist_shock' || k === 'wx_fist_tiegang') return 'monk';
    if (k.includes('duoming') || k.includes('canhe') || k.includes('douzhuan') || k.includes('lingbo') || k.includes('jinzhen') || k.includes('luoying') || k.includes('yunv') || k.includes('dugu')) return 'scholar';
    if (k.includes('xianglong') || k.includes('dagou') || k.includes('qigai') || k === 'wx_staff_challenge') return 'beggar';
    if (m.startsWith('shadow_') || k.includes('dagger') || k.includes('jiuyin') || k.includes('xuanming') || k.includes('xuehai') || k.includes('xixing') || k === 'wx_blood_burst') return 'assassin';
    if (k.includes('throw') || k.includes('smoke') || k.includes('crossbow') || k.includes('whip') || k.includes('flail') || k.includes('wudu') || k.includes('gun_')) return 'tangmen';
    if (k.includes('hammer') || k.includes('axe') || k.includes('shield') || k.includes('modao') || k.includes('fangtian') || k.includes('junwu') || k.includes('bawang') || k === 'wx_rally_command') return 'general';
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

  function wxDrawHex(ctx, cx, cy, rx, ry, stroke, fill, lineW) {
    ctx.beginPath();
    for (let i = 0; i < 6; i++) {
      const ang = (Math.PI / 3) * i + Math.PI / 6;
      const x = cx + Math.cos(ang) * rx;
      const y = cy + Math.sin(ang) * ry;
      if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    ctx.closePath();
    if (fill) { ctx.fillStyle = fill; ctx.fill(); }
    if (stroke) { ctx.strokeStyle = stroke; ctx.lineWidth = lineW || 1.5; ctx.stroke(); }
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
    ctx.globalAlpha = intensity * 0.32;
    ctx.strokeStyle = colorHex;
    for (let i = 0; i < 14; i++) {
      const y = 20 + ((i * 37) % (H - 40));
      const len = 56 + ((i * 29) % 115);
      const x0 = ((i * 83) % (W - 70));
      ctx.lineWidth = (i % 3 === 0) ? 2.0 : 1.0;
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

  // Luminous core-preserving strip tinting (keeps white-hot Qi cores bright while coloring ink/aura!)
  const kinTintCache = new Map();
  function wxGetTintedStrip(seqKey, tint) {
    const uri = KINETIC_ASSETS.strips && KINETIC_ASSETS.strips[seqKey];
    if (!uri) return null;
    const im = wxImg(uri);
    if (!im || !im.complete || !im.naturalWidth) return null;
    if (!tint || (tint[0] >= 248 && tint[1] >= 248 && tint[2] >= 248)) return im;
    const cKey = seqKey + ':v2:' + tint[0] + ',' + tint[1] + ',' + tint[2];
    if (kinTintCache.has(cKey)) return kinTintCache.get(cKey);
    const oc = document.createElement('canvas');
    oc.width = im.naturalWidth; oc.height = im.naturalHeight;
    const octx = oc.getContext('2d');
    octx.drawImage(im, 0, 0);
    octx.globalCompositeOperation = 'multiply';
    octx.fillStyle = 'rgba(' + tint[0] + ',' + tint[1] + ',' + tint[2] + ',0.72)';
    octx.fillRect(0, 0, oc.width, oc.height);
    octx.globalCompositeOperation = 'screen';
    octx.fillStyle = 'rgba(' + tint[0] + ',' + tint[1] + ',' + tint[2] + ',0.24)';
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

  function wxDetectStreamMode(sk) {
    const k = (sk && sk.key) || '';
    if (k === 'wx_sword_wanjian') return 'wanjian_recall';
    if (k === 'wx_sword_combo' || k === 'wx_sword_zixia' || k === 'wx_neigong_zixia') return 'sword_node_plant';
    if (k === 'wx_sword_taiji' || k === 'wx_neigong_douzhuan') return 'taiji_deflect';
    if (k === 'wx_fist_shock') return 'geshan_daniu';
    if (k === 'wx_fist_tiegang' || k === 'wx_fist_luohan' || k === 'wx_fist_rulai') return 'cunjin_stack';
    if (k === 'wx_spear_bawang' || k === 'wx_spear_panlong') return 'spear_vault_flip';
    if (k === 'wx_sword_dugu') return 'dugu_break_gear';
    if (k === 'wx_saber_xinyue' || k === 'wx_poise_charge') return 'iaido_flash';
    if (k === 'wx_throw_fan' || k === 'wx_throw_liuyedao' || k === 'wx_throwing_rain') return 'tangmen_recall';
    if (k === 'wx_hammer_leiting') return 'thunder_pool_chain';
    if (k === 'wx_bow_luori' || k === 'wx_gun_huolong') return 'steam_blast';
    return '';
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
    const oppIm2 = wxImg(VFX_ASSETS.enemies.heavy || VFX_ASSETS.enemies.pole || VFX_ASSETS.enemies.saber);
    const swordNodeIm = wxImg(VFX_ASSETS.weapons.chengying || VFX_ASSETS.weapons.yinglong);
    const daggerTrapIm = wxImg(VFX_ASSETS.weapons.feidao || VFX_ASSETS.weapons.yuchang);
    const foeShdIm = wxImg(VFX_ASSETS.weapons.shd_12 || VFX_ASSETS.weapons.shd_xuangui);
    const baguaIm = wxImg(VFX_ASSETS.fx && VFX_ASSETS.fx.wx_fx_bagua);

    const pt = key => wxImg(KINETIC_ASSETS.parts && KINETIC_ASSETS.parts[key]);
    const tCfg = KIN_THEME_CFG[proto.theme] || KIN_THEME_CFG.cyan;
    const ptRingMain = pt(tCfg.ring);
    const ptRingCyan = pt('wx_pt_ring_cyan');
    const ptRingGold = pt('wx_pt_ring_gold');
    const ptSparks = tCfg.sparks.map(pt);
    const ptGlint = pt('wx_pt_glint_star'), ptSwordRay = pt('wx_pt_sword_ray');
    const ptRock = pt('wx_pt_rock'), ptSmoke = pt('wx_pt_smoke'), ptIce = pt('wx_pt_ice_shard'), ptPetal = pt('wx_pt_petal');
    const ptFrostPatch = pt('wx_pt_frost_patch'), ptScorch = pt('wx_pt_crater_scorch'), ptVenom = pt('wx_pt_venom_pool');
    const ptGround = proto.ground === 'frost' ? ptFrostPatch
                   : (proto.ground === 'venom' ? ptVenom
                   : (proto.ground === 'scorch' ? ptScorch : null));

    const streamMode = wxDetectStreamMode(sk);
    const cycleMs = streamMode ? Math.max(1760, proto.cycleMs || 1680) : (proto.cycleMs || 1480);
    let startTs = performance.now();
    let cycleCount = 0;
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
      ctx.ellipse(cx, groundY + 38, 33 * shScale, 10.5 * shScale, 0, 0, Math.PI * 2);
      ctx.fill();

      ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
      ctx.translate(cx, groundY - jumpZ);
      if (flipX) ctx.scale(-1, 1);
      if (tintCss) ctx.filter = tintCss;

      ctx.save();
      ctx.rotate((leanDeg * Math.PI) / 180);
      ctx.scale(sx, sy);
      if (torsoIm && torsoIm.complete && torsoIm.naturalWidth) ctx.drawImage(torsoIm, -46, -66, 92, 128);
      ctx.save();
      ctx.translate(3, -18);
      ctx.rotate((-leanDeg * 0.42 * Math.PI) / 180);
      ctx.translate(-3, 18);
      if (headIm && headIm.complete && headIm.naturalWidth) ctx.drawImage(headIm, -46, -66, 92, 128);
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

    function drawFoeUnit(im, cx, groundY, jumpZ, rotDeg, flash, hasShield, labelTxt) {
      if (!im || !im.complete || !im.naturalWidth) return;
      const shS = Math.max(0.28, 1 - jumpZ / 130);
      ctx.fillStyle = 'rgba(0,0,0,' + (0.46 * shS).toFixed(2) + ')';
      ctx.beginPath(); ctx.ellipse(cx, groundY + 38, 33 * shS, 10.5 * shS, 0, 0, Math.PI * 2); ctx.fill();
      ctx.save();
      ctx.translate(cx, groundY - jumpZ);
      ctx.rotate((rotDeg * Math.PI) / 180);
      if (flash > 0.04) {
        ctx.filter = proto.react === 'kin_hit_frost' ? 'hue-rotate(155deg) brightness(' + (1 + flash * 1.5).toFixed(2) + ')'
                   : (proto.react === 'kin_hit_venom' ? 'hue-rotate(80deg) brightness(' + (1 + flash * 1.35).toFixed(2) + ')'
                   : 'brightness(' + (1 + flash * 1.95).toFixed(2) + ') contrast(1.1)');
      }
      ctx.scale(-1, 1);
      ctx.drawImage(im, -46, -66, 92, 128);
      if (hasShield && foeShdIm && foeShdIm.complete) {
        ctx.drawImage(foeShdIm, 4, -20, 44, 54);
      }
      ctx.restore();
      if (labelTxt) {
        ctx.save();
        ctx.font = 'bold 10px "Microsoft YaHei UI", sans-serif';
        ctx.textAlign = 'center';
        ctx.fillStyle = 'rgba(14,10,8,0.78)';
        const lw = ctx.measureText(labelTxt).width + 10;
        ctx.fillRect(cx - lw / 2, groundY - jumpZ - 76, lw, 14);
        ctx.fillStyle = '#f2dec0';
        ctx.fillText(labelTxt, cx, groundY - jumpZ - 65.5);
        ctx.restore();
      }
    }

    function drawPlantedQiSword(cx, hexY, pulseT, alpha) {
      if (alpha <= 0.02) return;
      ctx.save();
      ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
      if (ptRingCyan) wxDrawSprite(ctx, ptRingCyan, cx, hexY, 82 + Math.sin(pulseT * 6) * 8, 42, 0, 0.72 * alpha, false);
      const bob = Math.sin(pulseT * 5) * 4;
      if (swordNodeIm && swordNodeIm.complete) {
        wxDrawSprite(ctx, swordNodeIm, cx, hexY - 30 + bob, 36, 74, Math.PI * 0.75, 0.92 * alpha, false);
      }
      if (ptGlint) wxDrawSprite(ctx, ptGlint, cx, hexY - 46 + bob, 36, 36, pulseT * 2, 0.75 * alpha, false);
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
      const { W, H } = wxSetupHiDPICanvas(cv, isModal ? 460 : 500, isModal ? 254 : 275, ctx);
      const spd = isModal ? vfxState.modalSpeed : vfxState.speed;
      const lockF = isModal ? vfxState.modalLockFrame : vfxState.lockFrame;

      let rawP = ((now - startTs) * spd) / cycleMs;
      if (lockF >= 0 && lockF <= 3) {
        rawP = [0.18, 0.42, 0.57, 0.76][lockF];
      } else if (rawP >= 1.0) {
        startTs = now;
        rawP = rawP % 1.0;
        cycleCount = (cycleCount + 1) % 3;
      }

      const impP = proto.impactP || 0.50;
      const hitstopLen = (proto.kind === 'stance' || proto.kind === 'qinggong') ? 0.035 : 0.068;
      let p = rawP;
      let inHitstop = false;
      if (lockF < 0) {
        if (rawP >= impP && rawP < impP + hitstopLen) {
          inHitstop = true;
          p = impP + (rawP - impP) * 0.15;
        } else if (rawP >= impP + hitstopLen) {
          p = impP + hitstopLen * 0.15 + (rawP - (impP + hitstopLen)) * ((1 - (impP + hitstopLen * 0.15)) / (1 - (impP + hitstopLen)));
        }
      }

      const groundY = Math.round(H * 0.61);
      const close = vfxState.closeRange;
      const isRanged = proto.kind === 'ranged';
      const isStance = proto.kind === 'stance' && streamMode !== 'taiji_deflect' && streamMode !== 'sword_node_plant' && streamMode !== 'iaido_flash';
      const isQinggong = proto.kind === 'qinggong';

      // Bespoke spacing for multi-unit / vault / through-tank stream showcases!
      let homeX = Math.round(W * (isStance ? 0.48 : (close && !isRanged ? 0.37 : 0.23)));
      let foeHomeX = Math.round(W * (isStance ? 0.78 : (close && !isRanged ? 0.60 : 0.73)));
      if (streamMode === 'geshan_daniu') { homeX = Math.round(W * 0.25); foeHomeX = Math.round(W * 0.51); }
      else if (streamMode === 'spear_vault_flip') { homeX = Math.round(W * 0.48); foeHomeX = Math.round(W * 0.70); }
      else if (streamMode === 'taiji_deflect') { homeX = Math.round(W * 0.30); foeHomeX = Math.round(W * 0.60); }
      else if (streamMode === 'iaido_flash') { homeX = Math.round(W * 0.24); foeHomeX = Math.round(W * 0.56); }

      const spanX = foeHomeX - homeX;
      const focusX = isStance ? homeX : foeHomeX;

      let hx = homeX, hz = 0, lean = 0, sx = 1, sy = 1, wpnDeg = -22, armExt = 0, heroFlip = false, heroTint = '';
      let bx = foeHomeX, bz = 0, bLean = 0, bFlash = 0;
      let b2x = foeHomeX + 86, b2yOff = -28, b2z = 0, b2Lean = 0, b2Flash = 0;
      let shakeX = 0, shakeY = 0, camZoom = 1.0;
      const clones = [];
      const mo = proto.motion || 'kin_heavy_chop';
      const arch = proto.arch || 'heavy_cleave';

      // === Bespoke Stream Motion Overrides ===
      if (streamMode === 'taiji_deflect') {
        b2x = foeHomeX + 66; b2yOff = -30;
        if (p < 0.34) {
          const k = easeOut(p / 0.34);
          bx = foeHomeX - (spanX * 0.65) * k; bLean = -18 * k;
          hx = homeX - 8 * k; lean = -8 * k; wpnDeg = -45 * k;
        } else if (p < 0.54) {
          const k = (p - 0.34) / 0.20;
          bx = (foeHomeX - spanX * 0.65) + 22 * k; bLean = 16 * k;
          hx = homeX - 8 + 16 * k; wpnDeg = -45 + 160 * k; heroTint = 'brightness(1.22)';
        } else {
          const k = (p - 0.54) / 0.46;
          bx = (foeHomeX - spanX * 0.65 + 22) + easeOut(k) * (spanX * 0.65 - 22); bLean = 14 * (1 - k);
          b2x = (foeHomeX + 66) + arch01(Math.min(1, k * 1.4)) * 38;
          b2z = arch01(Math.min(1, k * 1.4)) * 32;
          b2Lean = 26 * arch01(Math.min(1, k * 1.4));
          b2Flash = Math.max(0, 1 - k * 2.2);
          if (k < 0.35) { shakeX = Math.sin(now * 0.1) * 7; camZoom = 1.06; }
        }
      } else if (streamMode === 'spear_vault_flip') {
        if (p < 0.28) {
          const k = easeOut(p / 0.28);
          hx = homeX - 18 * k; lean = -14 * k; wpnDeg = 58 * k;
        } else if (p < 0.72) {
          const k = easeInOut((p - 0.28) / 0.44);
          hx = homeX - 18 + 26 * Math.min(1, k * 2.2);
          lean = 18 * Math.sin(k * Math.PI);
          wpnDeg = 58 - 172 * easeOut(Math.min(1, k * 1.6));
          armExt = 24 * Math.sin(k * Math.PI);
          // Vault enemy UP and OVER hero onto rear hex (homeX - 96)!
          const rearHexX = homeX - 96;
          bx = foeHomeX + (rearHexX - foeHomeX) * k;
          bz = Math.sin(k * Math.PI) * 96;
          bLean = -k * 360;
          bFlash = k < 0.35 ? (1 - k / 0.35) : (k > 0.85 ? (k - 0.85) / 0.15 : 0);
          if (k > 0.82) { shakeY = Math.cos(now * 0.12) * 9; camZoom = 1.07; }
        } else {
          const k = (p - 0.72) / 0.28;
          const rearHexX = homeX - 96;
          bx = rearHexX; bz = 0; bLean = -18 * (1 - k);
          wpnDeg = -114 + 92 * easeOut(k);
        }
      } else if (streamMode === 'iaido_flash') {
        if (p < 0.36) {
          const k = easeOut(p / 0.36);
          hx = homeX - 10 * k; sy = 1 - 0.16 * k; sx = 1 + 0.10 * k; lean = 16 * k; wpnDeg = 82;
          heroTint = 'brightness(' + (0.92 + 0.35 * k).toFixed(2) + ')';
        } else if (p < 0.48) {
          const k = easeOut((p - 0.36) / 0.12);
          hx = (homeX - 10) + (foeHomeX + 108 - (homeX - 10)) * k;
          lean = 26; wpnDeg = -28; armExt = 22;
          clones.push({ x: homeX + spanX * 0.35, z: 2, a: 0.48, deg: 12, tint: 'brightness(1.8)' }, { x: foeHomeX - 10, z: 4, a: 0.56, deg: -20, tint: 'brightness(2.0)' });
        } else if (p < 0.80) {
          const k = (p - 0.48) / 0.32;
          hx = foeHomeX + 108; lean = 8 * (1 - k); wpnDeg = 76;
          if (k > 0.18) {
            const bk = (k - 0.18) / 0.82;
            bFlash = Math.max(0, 1 - bk * 1.8);
            bx = foeHomeX - 18 * arch01(bk); bz = 14 * arch01(bk); bLean = -22 * arch01(bk);
            if (bk < 0.35) { shakeX = Math.sin(now * 0.12) * 9; camZoom = 1.08; }
          }
        } else {
          const k = easeInOut((p - 0.80) / 0.20);
          hx = (foeHomeX + 108) - (foeHomeX + 108 - homeX) * k; wpnDeg = 76 - 98 * k;
        }
      } else if (mo === 'kin_dash_combo3') {
        if (p < 0.20) { const k = easeOut(p / 0.20); hx = homeX - 42 * k; hz = -4 * k; lean = -16 * k; wpnDeg = -22 - 58 * k; }
        else if (p < 0.36) { const k = easeOut((p - 0.20) / 0.16); hx = (homeX - 42) + (spanX * 0.48 + 42) * k; hz = 16 * arch01(k); lean = 18; armExt = 18 * k; wpnDeg = -80 + 165 * k; clones.push({ x: homeX - 20, z: 4, a: 0.42 * (1 - k * 0.4), deg: -62, tint: 'brightness(1.45)' }); if (k > 0.45) { bFlash = 0.55; bx = foeHomeX + 7; bLean = 8; } }
        else if (p < 0.50) { const k = easeOut((p - 0.36) / 0.14); hx = homeX + spanX * 0.48 + 26 * k; hz = -8 * arch01(k); lean = 22; armExt = 20; wpnDeg = 85 - 165 * k; clones.push({ x: homeX + spanX * 0.36, z: 10, a: 0.42, deg: 75, tint: 'brightness(1.5)' }); if (k > 0.40) { bFlash = 0.72; bx = foeHomeX + 11; bLean = 12; } }
        else if (p < 0.64) { const k = easeOut((p - 0.50) / 0.14); hx = (homeX + spanX * 0.48 + 26) + (foeHomeX + 78 - (homeX + spanX * 0.48 + 26)) * k; hz = 8 * arch01(k); lean = 28; armExt = 26; wpnDeg = -80 + 175 * k; clones.push({ x: homeX + spanX * 0.45, z: 6, a: 0.34, deg: 40, tint: 'brightness(1.55)' }, { x: foeHomeX + 14, z: 8, a: 0.46, deg: 85, tint: 'brightness(1.65)' }); }
        else if (p < 0.76) { hx = foeHomeX + 78; lean = 24; armExt = 24; wpnDeg = 96; clones.push({ x: foeHomeX + 24, z: 6, a: 0.34 * (1 - (p - 0.64) / 0.12), deg: 88, tint: 'brightness(1.6)' }); }
        else { const k = easeInOut((p - 0.76) / 0.24); hx = foeHomeX + 78 - (foeHomeX + 78 - homeX) * k; lean = 24 * (1 - k); wpnDeg = 96 - 118 * k; }
      }
      else if (mo === 'kin_dragon_palm') {
        if (p < 0.34) { const k = easeOut(p / 0.34); hx = homeX - 38 * k + Math.sin(p * 110) * 2 * k; sy = 1 - 0.14 * k; sx = 1 + 0.10 * k; lean = -14 * k; wpnDeg = -45 * k; heroTint = 'sepia(0.45) saturate(1.7) brightness(1.18)'; }
        else if (p < 0.52) { const k = easeOut((p - 0.34) / 0.18); hx = (homeX - 38) + 84 * k; lean = -14 + 38 * k; armExt = 26 * k; wpnDeg = -45 + 110 * k; heroTint = 'sepia(0.55) saturate(2.1) brightness(1.26)'; clones.push({ x: hx - 28, z: 4, a: 0.42, deg: 45, tint: 'sepia(0.8) saturate(2.4) brightness(1.35)' }); }
        else if (p < 0.68) { hx = homeX + 46; lean = 24; armExt = 26; wpnDeg = 65; heroTint = 'sepia(0.35) saturate(1.5) brightness(1.14)'; }
        else { const k = easeInOut((p - 0.68) / 0.32); hx = homeX + 46 * (1 - k); lean = 24 * (1 - k); armExt = 26 * (1 - k); wpnDeg = 65 - 87 * k; }
      }
      else if (mo === 'kin_flame_leap') {
        if (p < 0.14) { const k = easeOut(p / 0.14); hx = homeX - 24 * k; sy = 1 - 0.18 * k; sx = 1 + 0.12 * k; lean = -12 * k; wpnDeg = -60 * k; }
        else if (p < 0.38) { const k = easeOut((p - 0.14) / 0.24); hx = homeX - 24 + 20 * k; hz = 78 * k; lean = -16 + 10 * k; wpnDeg = -112; heroTint = 'brightness(1.2) saturate(1.5)'; clones.push({ x: hx - 8, z: Math.max(0, hz - 24), a: 0.38, deg: -112, tint: 'brightness(1.35)' }); }
        else if (p < 0.50) { const k = easeOut((p - 0.38) / 0.12); hx = (homeX - 4) + (spanX * 0.55 + 14) * k; hz = 78 * (1 - k); lean = 28 * k; armExt = 24 * k; wpnDeg = -112 + 225 * k; clones.push({ x: hx - 22, z: hz + 30, a: 0.44, deg: -40, tint: 'brightness(1.4)' }); }
        else if (p < 0.66) { hx = homeX + spanX * 0.55 + 10; hz = 0; lean = 26; armExt = 24; wpnDeg = 113; }
        else { const k = easeInOut((p - 0.66) / 0.34); hx = homeX + (spanX * 0.55 + 10) * (1 - k); lean = 26 * (1 - k); wpnDeg = 113 - 135 * k; }
      }
      else if (mo === 'kin_thunder_slam' || mo === 'kin_heavy_chop') {
        if (p < 0.34) { const k = easeOut(p / 0.34); hx = homeX - 38 * k; hz = 18 * k; lean = -18 * k; wpnDeg = -118 * k; heroTint = 'brightness(1.16)'; }
        else if (p < 0.48) { const k = easeOut((p - 0.34) / 0.14); hx = (homeX - 38) + (spanX * 0.52 + 42) * k; hz = 18 * (1 - k); lean = -18 + 46 * k; armExt = 24 * k; wpnDeg = -118 + 230 * k; clones.push({ x: hx - 24, z: hz + 12, a: 0.40, deg: -50, tint: 'brightness(1.35)' }); }
        else if (p < 0.64) { hx = homeX + spanX * 0.52 + 4; lean = 28; armExt = 24; wpnDeg = 112; }
        else { const k = easeInOut((p - 0.64) / 0.36); hx = homeX + (spanX * 0.52 + 4) * (1 - k); lean = 28 * (1 - k); wpnDeg = 112 - 134 * k; }
      }
      else if (mo === 'kin_celestial_beam') {
        if (p < 0.36) { const k = easeOut(p / 0.36); hx = homeX - 42 * k; hz = 28 * k; lean = -10 * k; wpnDeg = -70 * k; heroTint = 'brightness(1.22)'; clones.push({ x: hx + 18, z: Math.max(0, hz - 8), a: 0.34 * k, deg: -55, tint: 'brightness(1.45)' }); }
        else if (p < 0.50) { const k = easeOut((p - 0.36) / 0.14); hx = (homeX - 42) + 62 * k; hz = 28 - 4 * k; lean = 16 * k; armExt = 28 * k; wpnDeg = 72; }
        else if (p < 0.68) { hx = homeX + 20; hz = 24; lean = 16; armExt = 28; wpnDeg = 72; }
        else { const k = easeInOut((p - 0.68) / 0.32); hx = homeX + 20 * (1 - k); hz = 24 * (1 - k); lean = 16 * (1 - k); wpnDeg = 72 - 94 * k; }
      }
      else if (mo === 'kin_spear_drill') {
        if (p < 0.28) { const k = easeOut(p / 0.28); hx = homeX - 44 * k; lean = -16 * k; wpnDeg = -75 * k; }
        else if (p < 0.48) { const k = easeOut((p - 0.28) / 0.20); hx = (homeX - 44) + (spanX * 0.58 + 44) * k; hz = 10 * arch01(k); lean = 26 * k; armExt = 34 * k; wpnDeg = 78; clones.push({ x: hx - 32, z: 4, a: 0.44, deg: 74, tint: 'brightness(1.45)' }); }
        else if (p < 0.66) { hx = homeX + spanX * 0.58; lean = 26; armExt = 34; wpnDeg = 78; }
        else { const k = easeInOut((p - 0.66) / 0.34); hx = homeX + spanX * 0.58 * (1 - k); lean = 26 * (1 - k); armExt = 34 * (1 - k); wpnDeg = 78 - 100 * k; }
      }
      else if (mo === 'kin_whirl_spin') {
        if (p < 0.18) { const k = easeOut(p / 0.18); hx = homeX - 24 * k; lean = -14 * k; wpnDeg = -85 * k; }
        else if (p < 0.68) {
          const sp = (p - 0.18) / 0.50;
          hx = homeX + spanX * 0.30 * arch01(sp) + Math.cos(sp * Math.PI * 2.5) * 32;
          hz = 18 * arch01(sp);
          heroFlip = Math.sin(sp * Math.PI * 2.5) < 0;
          wpnDeg = -90 + sp * 720; armExt = 22;
          clones.push({ x: hx - 22, z: hz, a: 0.36, deg: wpnDeg - 60, flip: !heroFlip, tint: 'brightness(1.4)' });
        }
        else { const k = easeInOut((p - 0.68) / 0.32); hx = homeX + 18 * (1 - k); wpnDeg = -22; }
      }
      else if (mo === 'kin_shadow_blink') {
        if (p < 0.22) { const k = easeOut(p / 0.22); hx = homeX - 32 * k; sy = 1 - 0.15 * k; lean = -14 * k; heroTint = 'brightness(0.75) contrast(1.25)'; }
        else if (p < 0.46) { const k = easeOut((p - 0.22) / 0.24); hx = (homeX - 32) + (foeHomeX + 82 - (homeX - 32)) * k; hz = 12 * arch01(k); lean = 28; armExt = 24; wpnDeg = 92; clones.push({ x: homeX - 18, z: 2, a: 0.40, deg: -35, tint: 'brightness(0.6) hue-rotate(240deg)' }, { x: foeHomeX - 8, z: 8, a: 0.45, deg: 65, tint: 'brightness(1.45)' }); }
        else if (p < 0.66) { hx = foeHomeX + 82; heroFlip = true; lean = 16; armExt = 22; wpnDeg = 85; }
        else { const k = easeInOut((p - 0.66) / 0.34); hx = foeHomeX + 82 - (foeHomeX + 82 - homeX) * k; lean = 16 * (1 - k); wpnDeg = 85 - 107 * k; }
      }
      else if (mo === 'kin_upcut_launch') {
        if (p < 0.26) { const k = easeOut(p / 0.26); hx = homeX - 28 * k; sy = 1 - 0.18 * k; lean = -14 * k; wpnDeg = 65 * k; }
        else if (p < 0.48) { const k = easeOut((p - 0.26) / 0.22); hx = (homeX - 28) + (spanX * 0.55 + 28) * k; hz = 44 * k; lean = 22 * k; armExt = 24 * k; wpnDeg = 65 - 185 * k; clones.push({ x: hx - 20, z: Math.max(0, hz - 18), a: 0.42, deg: -50, tint: 'brightness(1.4)' }); }
        else if (p < 0.66) { hx = homeX + spanX * 0.55; hz = 44; lean = 20; armExt = 24; wpnDeg = -120; }
        else { const k = easeInOut((p - 0.66) / 0.34); hx = homeX + spanX * 0.55 * (1 - k); hz = 44 * (1 - k); lean = 20 * (1 - k); wpnDeg = -120 + 98 * k; }
      }
      else if (mo === 'kin_whip_snap' || mo === 'kin_bow_draw' || mo === 'kin_throw_fan') {
        if (p < 0.32) { const k = easeOut(p / 0.32); hx = homeX - 38 * k; hz = (mo === 'kin_throw_fan' ? 20 * k : 0); lean = -18 * k; wpnDeg = -80 * k; }
        else if (p < 0.52) { const k = easeOut((p - 0.32) / 0.20); hx = (homeX - 38) + (mo === 'kin_bow_draw' ? 12 : 68) * k; hz = (mo === 'kin_throw_fan' ? 20 * (1 - k * 0.5) : 4 * arch01(k)); lean = -18 + 38 * k; armExt = 26 * k; wpnDeg = -80 + 160 * k; }
        else { const k = easeInOut((p - 0.52) / 0.48); hx = homeX + (mo === 'kin_bow_draw' ? -26 : 30) * (1 - k); lean = 20 * (1 - k); wpnDeg = 80 - 102 * k; }
      }
      else if (mo === 'kin_qg_vault') {
        const k = easeInOut(Math.min(1, p / 0.72));
        hx = homeX + spanX * 0.92 * k;
        hz = 72 * arch01(Math.min(1, p / 0.72));
        lean = 22 * Math.sin(k * Math.PI);
        if (p > 0.14 && p < 0.78) clones.push({ x: hx - 36, z: Math.max(0, hz - 12), a: 0.42, deg: -35, tint: 'brightness(1.45)' }, { x: hx - 68, z: Math.max(0, hz - 24), a: 0.25, deg: -42, tint: 'brightness(1.3)' });
      }
      else if (mo === 'kin_roar_pulse') {
        if (p < 0.30) { const k = easeOut(p / 0.30); sy = 1 - 0.16 * k; sx = 1 + 0.12 * k; lean = -10 * k; }
        else if (p < 0.64) { const sp = (p - 0.30) / 0.34; hz = 24 * arch01(sp); hx = homeX + Math.sin(sp * 50) * 4; lean = 10; heroTint = 'brightness(1.24) saturate(1.4)'; }
        else { const k = 1 - easeInOut((p - 0.64) / 0.36); hz = 6 * k; }
      }
      else {
        hz = 22 * arch01(p);
        heroTint = 'brightness(' + (1 + 0.24 * arch01(p)).toFixed(2) + ')';
        wpnDeg = -22 - 38 * arch01(p);
      }

      // Target Hitstop + Reactions (with special through-tank `隔山打牛` & chained `雷池导电`!)
      const postImp = p - impP;
      if (streamMode === 'geshan_daniu') {
        b2x = foeHomeX + 124; b2yOff = 0;
        if (postImp >= 0 && postImp < 0.38) {
          const rk = postImp / 0.38;
          // Front shield tank barely trembles while Rear Enemy gets blasted!
          bx = foeHomeX + Math.sin(rk * 28) * 3 * (1 - rk);
          bFlash = rk < 0.18 ? 0.32 : 0;
          const arc2 = arch01(rk);
          b2x = (foeHomeX + 124) + 42 * arc2;
          b2z = 38 * arc2;
          b2Lean = 28 * arc2;
          b2Flash = rk < 0.55 ? (1 - rk / 0.55) : 0;
          if (postImp < 0.16) {
            shakeX = Math.sin(now * 0.09) * 8.5 * (1 - postImp / 0.16);
            camZoom = 1.0 + 0.065 * (1 - postImp / 0.16);
          }
        }
      } else if (streamMode !== 'taiji_deflect' && streamMode !== 'spear_vault_flip' && streamMode !== 'iaido_flash' && !isStance && !isQinggong && postImp >= 0 && postImp < 0.34) {
        const rk = postImp / 0.34;
        const arc = arch01(rk);
        bFlash = rk < 0.45 ? (1 - rk / 0.45) : 0;
        const rt = proto.react || 'kin_hit_heavy';
        if (rt === 'kin_hit_launch') { bx = foeHomeX + 40 * arc; bz = 42 * arc; bLean = 28 * arc; }
        else if (rt === 'kin_hit_electro') { bx = foeHomeX + 18 * arc + Math.sin(rk * 48) * 11 * arc; bz = 18 * arc; bLean = Math.sin(rk * 42) * 18 * arc; }
        else if (rt === 'kin_hit_frost') { bx = foeHomeX + 20 * arc + Math.sin(rk * 64) * 6 * arc; bz = 14 * arc; bLean = 14 * arc; }
        else if (rt === 'kin_hit_venom') { bx = foeHomeX + 22 * arc; bz = -6 * arc; bLean = -12 * arc + Math.sin(rk * 30) * 8 * arc; }
        else { bx = foeHomeX + 34 * arc; bz = 10 * arc; bLean = 24 * arc; }
        if (streamMode === 'thunder_pool_chain') {
          b2x = foeHomeX + 78 + Math.sin(rk * 52) * 10 * arc; b2yOff = -28;
          b2z = 16 * arc; b2Lean = -18 * arc; b2Flash = bFlash;
        }
        if (postImp < 0.16) {
          const skA = (1 - postImp / 0.16) * ((proto.shakePow || 6) >= 8 ? 9.5 : 6.8);
          shakeX = Math.sin(now * 0.09) * skA;
          shakeY = Math.cos(now * 0.11) * skA * 0.7;
          camZoom = 1.0 + 0.065 * (1 - postImp / 0.16);
        }
      }

      // === RENDER SCENE ===
      ctx.save();
      ctx.clearRect(0, 0, W, H);

      const bg = ctx.createRadialGradient(W * 0.50, H * 0.58, 16, W * 0.5, H * 0.5, W * 0.78);
      bg.addColorStop(0, '#3a3124'); bg.addColorStop(1, '#120f0b');
      ctx.fillStyle = bg; ctx.fillRect(0, 0, W, H);

      const vigA = Math.sin(Math.min(1, p * 1.12) * Math.PI) * 0.54;
      const vig = ctx.createRadialGradient(W * 0.50, H * 0.54, W * 0.16, W * 0.5, H * 0.5, W * 0.70);
      vig.addColorStop(0, 'rgba(0,0,0,0)');
      vig.addColorStop(1, tCfg.vig + (vigA * 1.1).toFixed(2) + ')');
      ctx.fillStyle = vig; ctx.fillRect(0, 0, W, H);

      ctx.translate(W * 0.5 + shakeX, H * 0.5 + shakeY);
      ctx.scale(camZoom, camZoom);
      ctx.translate(-W * 0.5, -H * 0.5);

      // 2.5D Staggered 2-Row Isometric Hex Grid (shows flanking/rear/sword-node hexes!)
      const hexStep = streamMode === 'geshan_daniu' ? 124
                    : (streamMode === 'spear_vault_flip' ? 104
                    : ((close && !isRanged && !isStance) ? Math.max(92, spanX) : Math.round(Math.max(88, spanX / 2.1))));
      [-1, 0].forEach(rOff => {
        const hy = groundY + 38 + rOff * 30;
        const xShift = rOff !== 0 ? 44 : 0;
        for (let hi = -2; hi <= 3; hi++) {
          const cx = homeX + hi * hexStep + xShift;
          if (cx < -36 || cx > W + 36) continue;
          const isHeroHex = rOff === 0 && hi === 0;
          const isFoeHex = rOff === 0 && !isStance && (Math.abs(cx - foeHomeX) < 38);
          const isRearHex = (streamMode === 'geshan_daniu' && rOff === 0 && hi === 2)
                         || (streamMode === 'spear_vault_flip' && rOff === 0 && hi === -1);
          const stroke = isHeroHex ? 'rgba(136,208,128,0.58)'
                       : (isFoeHex ? 'rgba(232,96,76,0.62)'
                       : (isRearHex ? 'rgba(255,204,96,0.58)' : 'rgba(154,132,96,0.20)'));
          const fill = isHeroHex ? 'rgba(48,80,44,0.26)'
                     : (isFoeHex ? 'rgba(102,36,28,0.26)'
                     : (isRearHex ? 'rgba(92,68,24,0.24)' : 'rgba(36,29,20,0.16)'));
          wxDrawHex(ctx, cx, hy, 44, 15.5, stroke, fill, isHeroHex || isFoeHex || isRearHex ? 1.7 : 1.2);
        }
      });

      // Elemental Terrain & Stream Hex Objects (Thunder Pool / Frost->Steam / Planted Qi Swords / Tangmen Caltrops)
      if (streamMode === 'thunder_pool_chain') {
        wxDrawSprite(ctx, pt('wx_pt_ring_violet'), foeHomeX, groundY + 36, 132, 54, 0, 0.55, false);
        wxDrawSprite(ctx, pt('wx_pt_ring_violet'), foeHomeX + 78, groundY + 8, 124, 50, 0, 0.52, false);
      } else if (streamMode === 'steam_blast') {
        if (p < impP && ptFrostPatch) wxDrawSprite(ctx, ptFrostPatch, foeHomeX, groundY + 34, 146, 88, 0, 0.85, false);
        else if (postImp >= 0 && ptScorch) wxDrawSprite(ctx, ptScorch, foeHomeX, groundY + 34, 154, 94, 0, 0.88, false);
      } else if (ptGround && postImp >= 0) {
        const scA = Math.min(1, postImp * 14) * Math.max(0, 1 - Math.max(0, postImp - 0.22) * 2.1);
        wxDrawSprite(ctx, ptGround, focusX, groundY + 34, 150, 96, 0, scA * 0.90, false);
      }

      // Stream Mechanic #1 & #2: Planted Qi Swords (`驻场气剑`) & `万剑归宗` Hex-Line Recall!
      if (streamMode === 'sword_node_plant') {
        const nAlpha = p < 0.42 ? 0 : Math.min(1, (p - 0.42) * 4) * (p > 0.88 ? (1 - (p - 0.88) / 0.12) : 1);
        drawPlantedQiSword(homeX + hexStep + 44, groundY + 8, now * 0.001, nAlpha);
        if (p > 0.55) drawPlantedQiSword(foeHomeX + 54, groundY + 38, now * 0.001 + 1.2, nAlpha);
      } else if (streamMode === 'wanjian_recall') {
        const nodes = [
          { x: homeX - 42, y: groundY + 8 },
          { x: homeX + 68, y: groundY + 8 },
          { x: foeHomeX + 72, y: groundY + 38 }
        ];
        nodes.forEach((nd, ni) => {
          if (p < 0.36) {
            drawPlantedQiSword(nd.x, nd.y, now * 0.001 + ni, 0.95);
          } else if (p < 0.72) {
            const rk = Math.max(0, Math.min(1, ((p - 0.36) / 0.26) - ni * 0.07));
            const tx = foeHomeX + 18, ty = groundY - 16;
            const sx0 = nd.x + (tx - nd.x) * easeOut(rk);
            const sy0 = (nd.y - 30) + (ty - (nd.y - 30)) * easeOut(rk);
            ctx.save();
            ctx.strokeStyle = 'rgba(130,244,255,' + ((1 - rk * 0.6) * 0.78).toFixed(2) + ')';
            ctx.lineWidth = 2.4;
            ctx.setLineDash([5, 4]);
            ctx.beginPath(); ctx.moveTo(nd.x, nd.y - 24); ctx.lineTo(sx0, sy0); ctx.stroke();
            ctx.restore();
            const ang = Math.atan2(ty - (nd.y - 30), tx - nd.x);
            if (ptSwordRay) wxDrawSprite(ctx, ptSwordRay, sx0, sy0, 96, 30, ang, 0.96, false);
          }
        });
      } else if (streamMode === 'tangmen_recall') {
        const traps = [
          { x: foeHomeX - 46, y: groundY + 10 },
          { x: foeHomeX + 56, y: groundY + 12 },
          { x: foeHomeX + 64, y: groundY + 40 }
        ];
        traps.forEach((tr, ti) => {
          if (p < 0.52) {
            if (daggerTrapIm) wxDrawSprite(ctx, daggerTrapIm, tr.x, tr.y - 8, 24, 42, 2.6 + ti * 0.3, 0.9, false);
            wxDrawSprite(ctx, ptRingCyan, tr.x, tr.y, 50, 24, 0, 0.45, false);
          } else if (p < 0.86) {
            const rk = Math.min(1, (p - 0.52) / 0.28);
            const dx = tr.x + (hx - tr.x) * easeInOut(rk);
            const dy = (tr.y - 10) + ((groundY - 14) - (tr.y - 10)) * easeInOut(rk);
            ctx.save();
            ctx.strokeStyle = 'rgba(220,248,255,' + ((1 - rk) * 0.82).toFixed(2) + ')';
            ctx.lineWidth = 1.4;
            ctx.beginPath(); ctx.moveTo(hx + 16, groundY - 12); ctx.lineTo(dx, dy); ctx.stroke();
            ctx.restore();
            if (daggerTrapIm) wxDrawSprite(ctx, daggerTrapIm, dx, dy, 26, 46, rk * 12, 1 - rk * 0.3, true);
          }
        });
      }

      // Windup Contracting Qi Rings & Glints
      if (p < 0.36) {
        const wx0 = (arch === 'thunder_slam') ? focusX : hx;
        drawRing(ptRingMain, wx0, groundY + 24, p, 0.32, 1.50, 0.28, 0.88);
        if (streamMode === 'iaido_flash' && ptGlint) {
          wxDrawSprite(ctx, ptGlint, hx - 8, groundY + 4, 72, 72, p * 8, Math.sin((p / 0.36) * Math.PI), false);
        } else if (streamMode === 'dugu_break_gear' && baguaIm) {
          wxDrawSprite(ctx, baguaIm, foeHomeX, groundY - 18, 92, 92, p * 6, Math.sin((p / 0.36) * Math.PI) * 0.85, false);
        } else if (arch === 'celestial_beam' || arch === 'sword_combo3' || arch === 'shadow_cross') {
          wxDrawSprite(ctx, ptGlint, hx + 4, groundY - 18, 72, 72, p * 9, Math.sin((p / 0.36) * Math.PI), false);
        }
      }

      // Back-Row Secondary Enemy (for `太极借力打力`, `隔山打牛`, `雷泽导电`)
      if (streamMode === 'taiji_deflect') {
        drawFoeUnit(oppIm2, b2x, groundY + b2yOff, b2z, b2Lean, b2Flash, false, '相邻敌乙');
      } else if (streamMode === 'thunder_pool_chain') {
        drawFoeUnit(oppIm2, b2x, groundY + b2yOff, b2z, b2Lean, b2Flash, false, '雷池传导');
      }

      // Primary Enemy Unit
      if (!isStance && !isQinggong) {
        const hasFoeShield = streamMode === 'geshan_daniu' || (streamMode === 'dugu_break_gear' && p < impP);
        const foeLbl = streamMode === 'geshan_daniu' ? '前排铁盾卫'
                     : (streamMode === 'taiji_deflect' ? '来袭敌甲'
                     : (streamMode === 'spear_vault_flip' ? '挑飞换位目标' : ''));
        drawFoeUnit(oppIm, bx, groundY, bz, bLean, bFlash, hasFoeShield, foeLbl);
      }
      if (streamMode === 'geshan_daniu') {
        drawFoeUnit(oppIm2, b2x, groundY, b2z, b2Lean, b2Flash, false, '后排目标');
      }

      // Dugu Broken Shield/Sword Fly-Off!
      if (streamMode === 'dugu_break_gear' && postImp >= 0 && postImp < 0.44 && foeShdIm) {
        const dk = postImp / 0.44;
        wxDrawSprite(ctx, foeShdIm, foeHomeX + 18 + dk * 68, groundY - 22 - Math.sin(dk * Math.PI) * 66, 42, 50, dk * 9, 1 - dk, false);
      }

      // Shaolin `寸劲伏脉` 3-Stack Glowing Meridian Orbs!
      if ((streamMode === 'cunjin_stack' || streamMode === 'geshan_daniu') && p > 0.22 && p < 0.86) {
        const targetX = streamMode === 'geshan_daniu' ? b2x : bx;
        const stacks = p < impP ? 2 : 3;
        for (let si = 0; si < stacks; si++) {
          const sa = (now * 0.006) + (si * Math.PI * 2) / 3;
          wxDrawSprite(ctx, ptGlint || ptRingGold, targetX + Math.cos(sa) * 24, groundY - 22 + Math.sin(sa) * 14, 28, 28, sa, 0.9, false);
        }
      }

      // Hero Afterimages + Articulated Hero
      clones.forEach(c => drawHero(c.x, groundY, c.z || 0, 18, 1, 1, c.deg !== undefined ? c.deg : wpnDeg, 14, c.a, !!c.flip, c.tint));
      drawHero(hx, groundY, hz, lean, sx, sy, wpnDeg, armExt, 1.0, heroFlip, heroTint);

      // TRUE MULTI-FRAME KINETIC ANIMATIONS + Bespoke Stream VFX Overlays!
      const seqMeta = KINETIC_ASSETS.meta[proto.seq] || { count: 10 };
      const seqCnt = seqMeta.count || 10;
      const tint = proto.tint;

      if (streamMode === 'taiji_deflect') {
        if (p >= 0.26 && p <= 0.78) {
          wxDrawKineticFrame(ctx, 'wx_kin_taiji_seal', ((p - 0.26) / 0.52) * 10, hx + 26, groundY - 12, 1.18, 0, 0.96, false, tint);
        }
        if (p >= 0.48 && p <= 0.86) {
          const dk = (p - 0.48) / 0.38;
          const rx = (hx + 30) + (b2x - (hx + 30)) * easeOut(dk);
          const ry = (groundY - 14) + ((groundY + b2yOff - 14) - (groundY - 14)) * easeOut(dk);
          wxDrawKineticFrame(ctx, 'wx_kin_dragon_surge', dk * 10, rx, ry, 0.95, -0.22, 0.95, false, tint);
        }
      } else if (streamMode === 'geshan_daniu') {
        if (p >= 0.34 && p <= 0.72) {
          wxDrawKineticFrame(ctx, 'wx_kin_fist_flurry', ((p - 0.34) / 0.38) * 10, foeHomeX - 10, groundY - 12, 0.95, 0, 0.92, false, [255, 232, 165]);
        }
        // Golden internal Qi shockwave passing THROUGH front shield tank into Rear Enemy!
        if (p >= 0.44 && p <= 0.90) {
          const gk = (p - 0.44) / 0.46;
          const wx = foeHomeX + 12 + gk * 116;
          wxDrawKineticFrame(ctx, 'wx_kin_sonic_wave', gk * 10, wx, groundY - 14, 1.12, 0, 0.96, false, [255, 226, 130]);
          if (gk > 0.25) {
            wxDrawKineticFrame(ctx, 'wx_kin_buddha_palm', ((gk - 0.25) / 0.75) * 10, b2x, groundY - 34, 1.16, 0, 0.98, false, [255, 230, 150]);
          }
        }
      } else if (streamMode === 'iaido_flash') {
        if (p >= 0.36 && p <= 0.62) {
          const fk = (p - 0.36) / 0.26;
          ctx.save();
          ctx.strokeStyle = 'rgba(255,252,235,' + Math.sin(fk * Math.PI).toFixed(2) + ')';
          ctx.shadowColor = '#ffe494'; ctx.shadowBlur = 16;
          ctx.lineWidth = 5 * Math.sin(fk * Math.PI);
          ctx.beginPath(); ctx.moveTo(homeX - 24, groundY - 12); ctx.lineTo(foeHomeX + 124, groundY - 16); ctx.stroke();
          ctx.restore();
        }
        if (p >= 0.50 && p <= 0.88) {
          wxDrawKineticFrame(ctx, 'wx_kin_moon_crescent', ((p - 0.50) / 0.38) * seqCnt, foeHomeX, groundY - 14, 1.26, 0, 1.0, false, tint);
          wxDrawKineticFrame(ctx, 'wx_kin_shadow_cross', ((p - 0.50) / 0.38) * 10, foeHomeX, groundY - 14, 1.08, 0, 0.88, false, tint);
        }
      } else if (arch === 'sword_combo3') {
        if (p >= 0.18 && p <= 0.44) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.18) / 0.26) * seqCnt, foeHomeX - 8, groundY - 12, 0.96, 0.46, 0.95, false, tint);
        if (p >= 0.34 && p <= 0.60) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.34) / 0.26) * seqCnt, foeHomeX + 4, groundY - 4, 1.04, -0.42, 0.96, true, tint);
        if (p >= 0.50 && p <= 0.84) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.50) / 0.34) * seqCnt, foeHomeX + 14, groundY - 10, 1.22, 0.02, 1.0, false, tint);
      }
      else if (arch === 'dragon_surge') {
        if (p >= 0.30 && p <= 0.88) { const u = (p - 0.30) / 0.58; wxDrawKineticFrame(ctx, proto.seq, u * seqCnt, homeX + spanX * 0.56 + u * 54, groundY - 8, 1.22, 0, 1.0, false, tint); }
      }
      else if (arch === 'flame_leap') {
        if (p >= 0.32 && p <= 0.68) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.32) / 0.36) * seqCnt, focusX - 8, groundY - 26, 1.15, 0, 1.0, false, tint);
        if (proto.seq2 && p >= 0.46 && p <= 0.92) wxDrawKineticFrame(ctx, proto.seq2, ((p - 0.46) / 0.46) * (KINETIC_ASSETS.meta[proto.seq2]?.count || 10), focusX, groundY - 52, 1.14, 0, 1.0, false, tint);
      }
      else if (arch === 'thunder_slam') {
        if (p >= 0.30 && p <= 0.88) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.30) / 0.58) * seqCnt, focusX, groundY - 70, 1.08, 0, 1.0, false, tint);
        if (streamMode === 'thunder_pool_chain' && p >= 0.42 && p <= 0.92) {
          wxDrawKineticFrame(ctx, 'wx_kin_thunder_bolt', ((p - 0.42) / 0.50) * 10, foeHomeX + 78, groundY - 92, 0.88, 0, 0.94, true, [215, 190, 255]);
        }
      }
      else if (arch === 'celestial_beam') {
        if (p >= 0.32 && p <= 0.88) { const u = (p - 0.32) / 0.56; wxDrawKineticFrame(ctx, proto.seq, u * seqCnt, homeX + spanX * 0.68 + u * 24, groundY - 18, 1.26, 0, 1.0, false, tint); }
      }
      else if (arch === 'spear_drill' || arch === 'whip_lash' || arch === 'arrow_barrage' || arch === 'phoenix_spear' || arch === 'flying_knives' || arch === 'peacock_fan' || arch === 'fist_flurry' || arch === 'tidal_wave') {
        if (p >= 0.26 && p <= 0.86) { const u = (p - 0.26) / 0.60; wxDrawKineticFrame(ctx, proto.seq, u * seqCnt, homeX + spanX * 0.56 + u * 26, groundY - 12, 1.20, 0, 1.0, false, tint); }
      }
      else if (arch === 'whirl_cyclone' || arch === 'bamboo_bind') {
        if (p >= 0.22 && p <= 0.86) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.22) / 0.64) * seqCnt, homeX + spanX * 0.48, groundY - 6, 1.28, 0, 0.98, false, tint);
      }
      else if (isQinggong) {
        if (p >= 0.46 && p <= 0.94) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.46) / 0.48) * seqCnt, foeHomeX, groundY - 10, 1.18, 0, 0.98, false, tint);
      }
      else if (arch === 'buddha_palm' || arch === 'war_banner' || arch === 'sword_rain') {
        if (p >= 0.24 && p <= 0.88) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.24) / 0.64) * seqCnt, focusX, groundY - 38, 1.20, 0, 1.0, false, tint);
      }
      else if (arch === 'frost_burst' || arch === 'venom_mire' || arch === 'earth_shatter' || arch === 'cannon_blast' || arch === 'smoke_cloud') {
        if (p >= 0.26 && p <= 0.88) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.26) / 0.62) * seqCnt, focusX, groundY - 22, 1.18, 0, 1.0, false, tint);
      }
      else if (arch === 'golden_dome' || arch === 'taiji_seal' || arch === 'soul_vortex' || arch === 'sonic_wave' || arch === 'lotus_poke' || arch === 'xuanwu_aegis' || arch === 'gold_needles' || arch === 'snow_step' || arch === 'warp_seal' || arch === 'prism_burst') {
        if (p >= 0.20 && p <= 0.88) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.20) / 0.68) * seqCnt, focusX, groundY - 16, 1.22, 0, 0.98, false, tint);
      }
      else {
        if (p >= 0.26 && p <= 0.86) wxDrawKineticFrame(ctx, proto.seq, ((p - 0.26) / 0.60) * seqCnt, focusX - 4, groundY - 14, 1.20, 0, 1.0, false, tint);
      }

      if (proto.seq2 && arch !== 'flame_leap' && streamMode !== 'geshan_daniu' && streamMode !== 'taiji_deflect' && p >= 0.44 && p <= 0.92) {
        const s2Cnt = KINETIC_ASSETS.meta[proto.seq2]?.count || 10;
        const s2Y = proto.seq2 === 'wx_kin_flame_pillar' ? groundY - 52 : (proto.seq2 === 'wx_kin_thunder_bolt' ? groundY - 70 : groundY - 18);
        wxDrawKineticFrame(ctx, proto.seq2, ((p - 0.44) / 0.48) * s2Cnt, focusX + 4, s2Y, 1.10, 0, 0.90, false, tint);
      }
      if (streamMode === 'spear_vault_flip' && p >= 0.66 && p <= 0.96) {
        wxDrawKineticFrame(ctx, 'wx_kin_earth_shatter', ((p - 0.66) / 0.30) * 10, homeX - 96, groundY - 16, 1.08, 0, 0.96, false, [255, 228, 168]);
      }

      // Impact Climax + Stream Callouts!
      if (postImp >= 0) {
        const ageSec = postImp * (cycleMs / 1000.0);
        const burstX = streamMode === 'geshan_daniu' ? b2x
                     : (streamMode === 'taiji_deflect' ? b2x
                     : (streamMode === 'spear_vault_flip' ? (homeX - 96)
                     : (isQinggong ? foeHomeX : focusX)));
        drawRing(ptRingMain, burstX, groundY + 20, ageSec, 0.38, 0.26, 2.20, 0.96);
        if (streamMode === 'steam_blast' && ptSmoke) {
          drawParticleBurst(burstX, groundY - 8, ageSec, [ptSmoke, ptIce, ...ptSparks], 30, -95, 40, 1.12);
        } else {
          const gravY = (proto.theme === 'fire' || isStance || isQinggong) ? -85 : ((arch === 'thunder_slam' || arch === 'earth_shatter') ? 240 : 140);
          const burstList = (arch === 'thunder_slam' || arch === 'earth_shatter') ? [...ptSparks, ptRock, ptSmoke]
                          : (proto.theme === 'frost' ? [...ptSparks, ptIce]
                          : (proto.theme === 'jade' ? [...ptSparks, ptPetal] : ptSparks));
          drawParticleBurst(burstX, groundY - 10, ageSec, burstList, 26, gravY, isStance ? 0 : 110, 0.90);
        }

        if (postImp < 0.18) {
          const fl = 1 - postImp / 0.18;
          wxDrawSpeedLines(ctx, W, H, proto.col, fl * 1.35);
        }

        if (postImp < 0.44) {
          const pk = postImp / 0.44;
          const dmgVal = 58 + ((sk.ap * 13 + sk.qi * 3) % 74);
          let dmgTxt = isQinggong ? '轻功腾挪 · 脱围!'
                     : isStance ? ('+' + proto.title)
                     : proto.kind === 'util' ? (proto.seal + ' · 真气运转!')
                     : ('-' + dmgVal + ' · ' + proto.seal + '破敌!');
          if (streamMode === 'wanjian_recall') dmgTxt = '万剑归宗 · 三剑贯阵 +16内息!';
          else if (streamMode === 'sword_node_plant') dmgTxt = '同槽递进 · 凝生【驻场气剑】!';
          else if (streamMode === 'taiji_deflect') dmgTxt = '借力打力 · 偏转轰击同伙 -' + dmgVal + '!';
          else if (streamMode === 'geshan_daniu') dmgTxt = '隔山打牛! 后排透震 -' + dmgVal + ' · 寸劲×3!';
          else if (streamMode === 'spear_vault_flip') dmgTxt = '挑飞过肩 · 强制换位破盾墙!';
          else if (streamMode === 'dugu_break_gear') dmgTxt = '独孤识兵 · 破盾缴械 -' + dmgVal + '!';
          else if (streamMode === 'iaido_flash') dmgTxt = '拔刀·孤月一闪（必中）· 残心归鞘!';
          else if (streamMode === 'tangmen_recall') dmgTxt = '银丝收镖 · 背刺攒射 · 弹药+1!';
          else if (streamMode === 'steam_blast') dmgTxt = '天地反应 · 寒暑蒸汽崩甲爆!';
          else if (streamMode === 'thunder_pool_chain') dmgTxt = '雷泽导电 · 连环碎裂玄壳!';
          else if (streamMode === 'cunjin_stack') dmgTxt = '寸劲伏脉 3/3 · 脏腑惊雷爆!';

          ctx.save();
          ctx.globalAlpha = Math.min(1, (1 - pk) * 2.4);
          ctx.textAlign = 'center';
          ctx.font = 'bold 14.5px "Microsoft YaHei UI", Georgia, serif';
          ctx.strokeStyle = '#0d0906'; ctx.lineWidth = 3.8;
          const popX = Math.max(105, Math.min(W - 105, burstX));
          ctx.strokeText(dmgTxt, popX, 56 - pk * 20);
          ctx.fillStyle = proto.core;
          ctx.fillText(dmgTxt, popX, 56 - pk * 20);
          ctx.restore();
        }
      }

      ctx.restore();

      // Sleek Ink-Calligraphy Cut-In Ribbon (shows live combo form name when `sk.comboForms` exists!)
      const bIn = easeOut(Math.min(1, p / 0.14));
      const bOut = p > 0.80 ? (1 - (p - 0.80) / 0.20) : 1;
      const bAlpha = bIn * bOut;
      if (bAlpha > 0.02) {
        const comboTitle = (sk.comboForms && sk.comboForms.length)
          ? sk.comboForms[Math.min(sk.comboForms.length - 1, Math.floor(p * sk.comboForms.length))].name
          : proto.title;
        const slideX = (1 - bIn) * -32 + (1 - bOut) * 16;
        ctx.save();
        ctx.globalAlpha = bAlpha;
        ctx.translate(10 + slideX, 10);
        const bw = 248, bh = 42;
        const gB = ctx.createLinearGradient(0, 0, bw, 0);
        gB.addColorStop(0, 'rgba(10,12,16,0.92)');
        gB.addColorStop(0.80, 'rgba(18,20,26,0.82)');
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
        ctx.font = 'bold 13.5px "STKaiti", "KaiTi", "Microsoft YaHei UI", serif';
        ctx.fillStyle = proto.core;
        ctx.textAlign = 'left';
        ctx.fillText(comboTitle, 52, 20);
        ctx.font = '10.5px "Microsoft YaHei UI", sans-serif';
        ctx.fillStyle = '#d4c8ae';
        ctx.fillText((sk.streamTag || proto.sub || '').slice(0, 15), 52, 35);
        ctx.save();
        ctx.translate(212, 20); ctx.rotate(-0.06);
        ctx.fillStyle = 'rgba(132,18,12,0.88)'; ctx.fillRect(-17, -10, 34, 20);
        ctx.strokeStyle = '#e84834'; ctx.lineWidth = 1.4; ctx.strokeRect(-17, -10, 34, 20);
        ctx.font = 'bold 10.5px serif'; ctx.fillStyle = '#ffe8dc'; ctx.textAlign = 'center';
        ctx.fillText(proto.seal, 0, 4);
        ctx.restore();
        ctx.restore();
      }

      // Status Pill top-right
      ctx.save();
      ctx.font = '11px "Microsoft YaHei UI", sans-serif';
      const stTxt = (sk.streamTag ? sk.streamTag.split(' · ')[0] : (isStance ? '周身真罡' : (isRanged ? '远程齐射' : '高清逐帧'))) + (inHitstop ? ' · ⚡顿帧卡肉!' : ' · Retina 60fps');
      const stw = ctx.measureText(stTxt).width + 16;
      ctx.fillStyle = inHitstop ? 'rgba(150,36,20,0.88)' : 'rgba(12,10,8,0.74)';
      ctx.fillRect(W - stw - 8, 8, stw, 20);
      ctx.strokeStyle = inHitstop ? '#ffe078' : 'rgba(200,165,105,0.45)';
      ctx.lineWidth = 1; ctx.strokeRect(W - stw - 8, 8, stw, 20);
      ctx.fillStyle = inHitstop ? '#fff6d0' : '#e4cfb0';
      ctx.textAlign = 'right'; ctx.fillText(stTxt, W - 16, 22);
      ctx.restore();

      const nextId = requestAnimationFrame(step);
      if (isModal) vfxState.modalRaf = nextId; else vfxState.stageRaf = nextId;
    }

    const initId = requestAnimationFrame(step);
    if (isModal) vfxState.modalRaf = initId; else vfxState.stageRaf = initId;
  }
"""


SKILL_VFX_BOTTOM_JS_V2 = r"""  function getTheaterPool(filteredSkills) {
    if (vfxState.cat === 'streams') {
      return VFX_STREAM_IDS.map(id => skillById.get(id)).filter(Boolean);
    }
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
            <b>${esc(s.name)}${s.streamTag ? `<span class="wx-vfx-proto-badge">☯流派</span>` : (hasProto ? `<span class="wx-vfx-proto-badge">${esc(KINETIC_PROTOS[s.id].seal)}</span>` : '')}</b>
            <small>${esc(s.streamTag || (hasProto ? KINETIC_PROTOS[s.id].sub : (sch.label || '')))} · ${s.ap}AP/${s.qi}气</small>
          </span>
        </button>`;
    }).join('');

    const comboBarHtml = (cur.comboForms && cur.comboForms.length)
      ? `<div style="font-size:11.5px;color:#ffe4a4;padding:4px 8px;background:rgba(164,56,28,0.28);border:1px solid rgba(235,176,92,0.38);border-radius:4px">
           <strong>🔁 同槽多段递进：</strong>${cur.comboForms.map((cf, ci) => `${ci + 1}段【${esc(cf.name)}】(${cf.ap}AP/${cf.qi}气)`).join(' → ')}
         </div>` : '';

    const protoBarHtml = proto ? `
      <div class="wx-vfx-proto-bar">
        <span><strong>${cur.streamTag ? '☯ ' + esc(cur.streamTag) : '✨ 高清逐帧动效（' + esc(proto.seal) + '）'}：</strong>${esc(proto.tag)}</span>
        <span style="display:flex;gap:6px;flex-wrap:wrap">
          <button type="button" class="wx-vfx-btn" data-vfx-ctrl="range" aria-pressed="${vfxState.closeRange}">${vfxState.closeRange ? '⚔ 实战贴身1格（已开启）' : '↔ 远距拉宽视角'}</button>
          <button type="button" class="wx-vfx-btn" data-vfx-ctrl="compare" aria-pressed="${vfxState.useLegacyCompare}">${vfxState.useLegacyCompare ? '📜 当前：旧版贴图（点击切回新版）' : '🆚 切旧版贴图对比'}</button>
        </span>
      </div>` : '';

    return `
      <div class="wx-vfx-head">
        <div class="wx-vfx-head-title">
          <strong>⚔ 十三系国风武学流派 · 171 式 Retina 高清逐帧水墨演武剧场</strong>
          <small>支持双排等距六角格阵位、气剑驻场与万剑归宗拔剑、太极/斗转双敌借力偏转、隔山打牛透盾轰后排、霸王挑飞过肩换位、独孤碎盾、居合残心与唐门收镖实时演示</small>
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
              <canvas id="wx-vfx-stage-canvas" width="500" height="275"></canvas>
            </div>
            ${comboBarHtml}
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
            <div style="font-size:13px;color:#ffe4a8;font-weight:700">${proto ? '✨ 高清逐帧演武（' + esc(proto.seal) + '）· ' + esc(sk.streamTag || proto.sub) : '⚡ 实战招式动作与四帧拆解 · ' + esc(ch.label)}</div>
            <div style="font-size:12px;color:#cbb899;line-height:1.5">${isNewMode
              ? esc(proto.tag) + '（图集 <code>' + esc(proto.seq) + '</code>）：'
              : '独立动作序列 <code>' + esc(ch.anim) + '</code> · 真罡气芒 <code>' + esc(ch.vfx) + '</code>：'}</div>
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


SHANHAI_THEATER_JS_V2 = r"""// === WX_SHANHAI_THEATER_JS_START ===
  const SH_ASSETS = DB.bestiaryAssets || { busts: {} };
  const SH_FEATURED_IDS = [
    'wx_boss_zhuyin', 'wx_boss_xiangliuwang', 'wx_boss_nvchou', 'wx_boss_bashe',
    'wx_boss_jiuwei', 'wx_boss_xingtian', 'wx_boss_hundun', 'wx_boss_baize',
    'wx_boss_jumang', 'wx_boss_yinglong', 'wx_boss_chiyou', 'wx_boss_kui',
    'wx_boss_xuangui', 'wx_boss_luwu', 'wx_boss_huodou', 'wx_boss_dijiang'
  ];
  const SH_CAT_DEFS = [
    ['featured', '✨ 法相精选 (16)'],
    ['segments', '🐍 多体节巨躯 (9)'],
    ['appendages', '⚔ 多首共生断肢 (6)'],
    ['totems', '☀ 天象领域阵眼 (10)'],
    ['mythic_law', '☯ 单格本命异律 (40)'],
    ['filtered', '当前筛选结果'],
    ['all', '全部万妖 (139)']
  ];

  const shState = {
    collapsed: false,
    cat: 'featured',
    creatureId: 'wx_boss_zhuyin',
    skillIdx: 0,
    speed: 1.0,
    brokenParts: {},      // { [creatureId]: { [partIdx]: true, internal: true } }
    modalCreatureId: '',
    modalSkillIdx: 0,
    modalSpeed: 1.0,
    stageRaf: 0,
    modalRaf: 0,
    lastFiltered: null
  };

  function shIsPartBroken(cid, idx) {
    return !!(shState.brokenParts[cid] && shState.brokenParts[cid][idx]);
  }
  function shTogglePartBroken(cid, idx) {
    if (!shState.brokenParts[cid]) shState.brokenParts[cid] = {};
    shState.brokenParts[cid][idx] = !shState.brokenParts[cid][idx];
  }
  function shIsInternalBroken(cid) {
    return !!(shState.brokenParts[cid] && shState.brokenParts[cid].internal);
  }
  function shToggleInternalBroken(cid) {
    if (!shState.brokenParts[cid]) shState.brokenParts[cid] = {};
    shState.brokenParts[cid].internal = !shState.brokenParts[cid].internal;
  }
  function shIsSkillSealed(cid, sk) {
    if (!sk) return false;
    if (sk.lockedByPartIdx !== undefined && sk.lockedByPartIdx >= 0 && shIsPartBroken(cid, sk.lockedByPartIdx)) return true;
    if (sk.lockedByInternal && shIsInternalBroken(cid)) return true;
    return false;
  }
  function shResetParts(cid) {
    shState.brokenParts[cid] = {};
  }

  function stopShanHaiStage() {
    if (shState.stageRaf) { cancelAnimationFrame(shState.stageRaf); shState.stageRaf = 0; }
  }
  function stopShanHaiModal() {
    if (shState.modalRaf) { cancelAnimationFrame(shState.modalRaf); shState.modalRaf = 0; }
  }

  function shResolvePool(filteredCreatures) {
    const all = DB.bestiary.creatures || [];
    if (shState.cat === 'featured') {
      const f = SH_FEATURED_IDS.map(id => creatureById.get(id)).filter(Boolean);
      return f.length ? f : all.slice(0, 16);
    }
    if (shState.cat === 'segments' || shState.cat === 'appendages' || shState.cat === 'totems' || shState.cat === 'mythic_law') {
      const m = all.filter(c => c.structureMode === shState.cat);
      return m.length ? m : all;
    }
    if (shState.cat === 'filtered') {
      const src = filteredCreatures || shState.lastFiltered || all;
      return src.length ? src : all;
    }
    return all;
  }

  function shDrawHexPoly(ctx, cx, cy, rx, ry, stroke, fill, lw) {
    ctx.save();
    ctx.beginPath();
    for (let i = 0; i < 6; i++) {
      const a = (Math.PI / 3) * i + Math.PI / 6;
      const x = cx + Math.cos(a) * rx;
      const y = cy + Math.sin(a) * ry;
      if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    ctx.closePath();
    if (fill) { ctx.fillStyle = fill; ctx.fill(); }
    if (stroke) { ctx.strokeStyle = stroke; ctx.lineWidth = lw || 1.4; ctx.stroke(); }
    ctx.restore();
  }

  function shDrawOverheadBars(ctx, cx, topY, armPct, hpPct, armCol, hpCol, labelTxt) {
    const bw = 44;
    ctx.save();
    ctx.fillStyle = 'rgba(8,6,5,0.82)';
    ctx.fillRect(cx - bw / 2 - 1, topY - 1, bw + 2, 9);
    ctx.fillStyle = armCol || '#c5d6e8';
    ctx.fillRect(cx - bw / 2, topY, Math.max(0, bw * armPct), 3);
    ctx.fillStyle = hpCol || '#e04838';
    ctx.fillRect(cx - bw / 2, topY + 4, Math.max(0, bw * hpPct), 3.2);
    if (labelTxt) {
      ctx.font = 'bold 9.5px "Microsoft YaHei UI", sans-serif';
      ctx.textAlign = 'center';
      ctx.strokeStyle = 'rgba(0,0,0,0.9)';
      ctx.lineWidth = 2.6;
      ctx.strokeText(labelTxt, cx, topY - 3);
      ctx.fillStyle = '#ffe9c2';
      ctx.fillText(labelTxt, cx, topY - 3);
    }
    ctx.restore();
  }

  // === 60fps Retina Multi-Tile / Multi-Part / Domain-Totem Shan-Hai Boss Action Arena ===
  function startShanHaiCanvas(canvasId, creature, skillIdx, isModal) {
    const cv = document.getElementById(canvasId);
    if (!cv || typeof cv.getContext !== 'function') return;
    const ctx = cv.getContext('2d');
    if (!ctx) return;

    if (isModal) stopShanHaiModal(); else stopShanHaiStage();

    const c = creature || creatureById.get('wx_boss_zhuyin') || (DB.bestiary.creatures || [])[0];
    if (!c) return;
    const skills = c.skills || [];
    const sk = skills[skillIdx] || skills[0];
    if (!sk) return;

    const bustUri = key => (SH_ASSETS.busts && SH_ASSETS.busts[key]) || '';
    const beastIm = wxImg(bustUri(c.id) || (c.icon && DB.icons[c.icon]) || '');

    const rigGen = (VFX_ASSETS.rigs && VFX_ASSETS.rigs.general) || {};
    const rigSwd = (VFX_ASSETS.rigs && VFX_ASSETS.rigs.swordsman) || rigGen;
    const rigArc = (VFX_ASSETS.rigs && VFX_ASSETS.rigs.tangmen) || rigSwd;
    const h1Torso = wxImg(rigGen.torso), h1Head = wxImg(rigGen.head);
    const h2Torso = wxImg(rigSwd.torso), h2Head = wxImg(rigSwd.head);
    const h3Torso = wxImg(rigArc.torso), h3Head = wxImg(rigArc.head);
    const heroWpn = wxImg((VFX_ASSETS.weapons && VFX_ASSETS.weapons.minghong) || '');
    const heroShd = wxImg((VFX_ASSETS.weapons && (VFX_ASSETS.weapons.shd_xuangui || VFX_ASSETS.weapons.shd_12)) || '');
    const swdWpn  = wxImg((VFX_ASSETS.weapons && VFX_ASSETS.weapons.chengying) || '');
    const bowWpn  = wxImg((VFX_ASSETS.weapons && VFX_ASSETS.weapons.zhentiangong) || '');

    const fxMap = VFX_ASSETS.fx || {};
    const vfxMap = VFX_ASSETS.vfx || {};
    const auraIm  = wxImg(vfxMap[sk.vfx] || vfxMap.wx_vfx_05);
    const baguaIm = wxImg(fxMap.wx_fx_bagua);
    const lotusIm = wxImg(fxMap.wx_fx_lotus_seal);

    const pt = key => wxImg(KINETIC_ASSETS.parts && KINETIC_ASSETS.parts[key]);
    const tCfg = KIN_THEME_CFG[sk.kinTheme || 'fire'] || KIN_THEME_CFG.fire;
    const ptRingMain = pt(tCfg.ring);
    const ptSparks = tCfg.sparks.map(pt);
    const ptScorch = pt('wx_pt_crater_scorch'), ptVenom = pt('wx_pt_venom_pool'), ptFrost = pt('wx_pt_frost_patch');
    const ptSmoke = pt('wx_pt_smoke'), ptRock = pt('wx_pt_rock'), ptIce = pt('wx_pt_ice_shard'), ptGlint = pt('wx_pt_glint_star');
    const ptWind = pt('wx_pt_wind_wisp'), ptRingViolet = pt('wx_pt_ring_violet'), ptRingGold = pt('wx_pt_ring_gold'), ptRingCyan = pt('wx_pt_ring_cyan');

    const smode = c.structureMode || (c.kind === 'boss' ? 'mythic_law' : 'wild');
    const parts = c.parts || [];
    const geo = sk.geo || 'cone_3';
    const activeField = sk.field || c.initField || '';
    const kinSeq = sk.kinSeq || 'wx_kin_claw_rend';
    const kinSeq2 = sk.kinSeq2 || '';
    const kinTint = sk.kinTint || [255, 220, 170];
    const col = sk.animColor || '#ff6b3d';
    const isBoss = c.kind === 'boss';

    const cycleMs = 2180;
    let startTs = performance.now();
    let cycleCount = 0;

    const seedP = [];
    for (let i = 0; i < 28; i++) {
      const a = ((i * 2.39996) % (Math.PI * 2));
      seedP.push({
        vx: Math.cos(a) * (65 + (i % 6) * 28),
        vy: Math.sin(a) * (52 + (i % 5) * 24) - 36,
        rot0: (i * 53) % 360,
        tq: (i % 2 === 0 ? 1 : -1) * 180,
        sc: 0.42 + (i % 4) * 0.16,
        life: 0.28 + (i % 3) * 0.09
      });
    }

    function hexCoord(colIdx, rowIdx, W, H) {
      const sx = W / 540, sy = H / 300;
      const stagger = rowIdx !== 1 ? 22 * sx : 0;
      const cx = (78 * sx) + colIdx * (94 * sx) + stagger;
      const groundY = ([120, 158, 196][rowIdx] || 158) * sy;
      return { cx, groundY, hexY: groundY + 34 * sy, sx, sy };
    }

    // Assign exact 2D Hex Grid slots for Parts (`segments`, `appendages`, `totems`)
    const partSlots = parts.map((ptSpec, idx) => {
      let hc = 4, hr = idx === 0 ? 0 : 2;
      if (smode === 'appendages') {
        const map4 = [[2, 0], [2, 2], [4, 0], [4, 2]];
        [hc, hr] = map4[idx % 4];
      } else if (smode === 'totems') {
        const map3 = [[2, 0], [4, 0], [4, 2]];
        [hc, hr] = map3[idx % 3];
      } else {
        const mapSeg = [[4, 0], [4, 2], [4, 1]];
        [hc, hr] = mapSeg[idx % 3];
      }
      return {
        idx,
        spec: ptSpec,
        col: hc,
        row: hr,
        im: wxImg(bustUri(ptSpec.sprite) || bustUri(c.id)),
        injIm: wxImg(bustUri(ptSpec.injuredSprite) || bustUri(ptSpec.sprite) || bustUri(c.id))
      };
    });

    function drawHeroMini(torso, head, wpn, shd, cx, groundY, jumpZ, leanDeg, flash, sc, highPlinth, roleTag) {
      ctx.save();
      if (highPlinth) {
        shDrawHexPoly(ctx, cx, groundY + 34 * sc, 39 * sc, 14 * sc, '#d9b574', 'rgba(92,74,44,0.58)', 1.8);
        groundY -= 9 * sc;
      }
      const shS = Math.max(0.35, 1 - jumpZ / 120);
      ctx.fillStyle = 'rgba(0,0,0,' + (0.46 * shS).toFixed(2) + ')';
      ctx.beginPath(); ctx.ellipse(cx, groundY + 33 * sc, 27 * sc * shS, 8.5 * sc * shS, 0, 0, Math.PI * 2); ctx.fill();

      ctx.translate(cx, groundY - jumpZ);
      ctx.rotate((leanDeg * Math.PI) / 180);
      if (flash > 0.05) ctx.filter = 'brightness(' + (1 + flash * 1.65).toFixed(2) + ')';

      const w = 78 * sc, h = 108 * sc;
      if (wpn && wpn.complete && wpn.naturalWidth) {
        ctx.save(); ctx.translate(-22 * sc, 4 * sc); ctx.rotate(-0.35);
        ctx.drawImage(wpn, -15 * sc, -46 * sc, 30 * sc, 58 * sc); ctx.restore();
      }
      if (torso && torso.complete && torso.naturalWidth) ctx.drawImage(torso, -w / 2, -h * 0.56, w, h);
      if (head && head.complete && head.naturalWidth) ctx.drawImage(head, -w / 2, -h * 0.56, w, h);
      if (shd && shd.complete && shd.naturalWidth) {
        ctx.drawImage(shd, 4 * sc, -16 * sc, 36 * sc, 44 * sc);
      }
      ctx.restore();
      if (roleTag) {
        shDrawOverheadBars(ctx, cx, groundY - jumpZ - 64 * sc, 0.86, 0.92, '#9ec5e8', '#5fd37a', roleTag);
      }
    }

    function drawBeastUnit(im, cx, groundY, jumpZ, leanDeg, unitSc, alpha, faceRight, tintFilter) {
      if (!im || !im.complete || !im.naturalWidth || alpha <= 0.02) return;
      ctx.save();
      const bw = 108 * unitSc, bh = 140 * unitSc;
      const shS = Math.max(0.32, 1 - jumpZ / 140);
      ctx.fillStyle = 'rgba(0,0,0,' + (0.50 * shS * alpha).toFixed(2) + ')';
      ctx.beginPath(); ctx.ellipse(cx, groundY + 33 * unitSc, 36 * unitSc * shS, 11 * unitSc * shS, 0, 0, Math.PI * 2); ctx.fill();

      ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
      ctx.translate(cx, groundY - jumpZ);
      if (tintFilter) ctx.filter = tintFilter;
      if (!faceRight) ctx.scale(-1, 1);
      ctx.rotate(((faceRight ? leanDeg : -leanDeg) * Math.PI) / 180);
      ctx.drawImage(im, -bw / 2, -bh * 0.57, bw, bh);
      ctx.restore();
    }

    function drawFieldOnHex(cx, hexY, sc, pulseT) {
      if (!activeField) return;
      if (activeField === 'drought_scorch' && ptScorch) {
        wxDrawSprite(ctx, ptScorch, cx, hexY - 2, 92 * sc, 46 * sc, 0, 0.72, false);
      } else if (activeField === 'bitter_mire' && ptVenom) {
        wxDrawSprite(ctx, ptVenom, cx, hexY - 2, 92 * sc, 44 * sc, 0, 0.78, false);
      } else if (activeField === 'abyss_frost' && ptFrost) {
        wxDrawSprite(ctx, ptFrost, cx, hexY - 2, 92 * sc, 44 * sc, 0, 0.78, false);
      } else if (activeField === 'thunder_pool' && ptRingViolet) {
        wxDrawSprite(ctx, ptRingViolet, cx, hexY, 88 * sc, 36 * sc, pulseT * 1.5, 0.58, false);
      } else if (activeField === 'mirage_mist' && ptSmoke) {
        wxDrawSprite(ctx, ptSmoke, cx + Math.sin(pulseT * 2 + cx) * 6, hexY - 8, 78 * sc, 44 * sc, 0, 0.42, false);
      } else if ((activeField === 'gale_sandstorm' || activeField === 'gale_sand') && ptWind) {
        wxDrawSprite(ctx, ptWind, cx + Math.cos(pulseT * 4 + cx) * 10, hexY - 6, 74 * sc, 32 * sc, 0, 0.50, false);
      }
    }

    // Exact 2D Hex Telegraph Set for `sk.geo`
    function getTelegraphHexes() {
      if (geo === 'cone_3') return [[1, 0], [1, 1], [1, 2], [2, 1]];
      if (geo === 'line_pierce_3' || geo === 'line_charge_3') return [[2, 1], [1, 1], [0, 1]];
      if (geo === 'ring_aoe_1' || geo === 'ring_quake_6') return [[2, 0], [2, 1], [2, 2], [3, 0], [3, 2], [4, 1]];
      if (geo === 'ring_aoe_2' || geo === 'sonic_roar' || geo === 'omen_cataclysm' || geo === 'telegraph_omen' || geo === 'field_detonate') {
        return [[0, 0], [0, 1], [0, 2], [1, 0], [1, 1], [1, 2], [2, 0], [2, 1], [2, 2]];
      }
      if (geo === 'tail_sweep_arc') return [[2, 0], [2, 1], [2, 2]];
      if (geo === 'ten_suns_ray' || geo === 'totem_ray') return [[1, 0], [1, 1], [1, 2], [0, 0], [0, 2]];
      if (geo === 'multi_bite_3') return [[1, 0], [1, 1], [1, 2]];
      if (geo === 'boulder_throw' || geo === 'ranged_barrage' || geo === 'sky_dive' || geo === 'leap_slam_3' || geo === 'hex_curse') return [[1, 1], [0, 0], [0, 2]];
      if (geo === 'totem_swap') return [[3, 1], [4, 0]];
      return [[1, 1], [2, 1]];
    }
    const teleHexes = getTelegraphHexes();
    const teleKeySet = new Set(teleHexes.map(([x, y]) => x + ',' + y));

    function step(now) {
      if (!document.getElementById(canvasId)) return;
      const { W, H } = wxSetupHiDPICanvas(cv, isModal ? 480 : 540, isModal ? 268 : 300, ctx);
      const uSc = W / 540;
      const spd = isModal ? shState.modalSpeed : shState.speed;

      let rawP = ((now - startTs) * spd) / cycleMs;
      if (rawP >= 1.0) {
        startTs = now;
        rawP = rawP % 1.0;
        cycleCount = (cycleCount + 1) % 14;
      }

      const isLockedMove = shIsSkillSealed(c.id, sk);
      const internalBrk = shIsInternalBroken(c.id);
      const impP = 0.48;
      let p = rawP;
      if (!isLockedMove && rawP > 0.48 && rawP < 0.54) p = 0.48 + (rawP - 0.48) * 0.18;
      else if (!isLockedMove && rawP >= 0.54) p = 0.4908 + (rawP - 0.54) * (0.5092 / 0.46);

      const easeOut = t => 1 - Math.pow(1 - Math.max(0, Math.min(1, t)), 3);
      const arch01 = t => { const k = Math.max(0, Math.min(1, t)); return 4 * k * (1 - k); };

      const mHome = hexCoord(3, 1, W, H);
      const hFront = hexCoord(1, 1, W, H);
      const hTop   = hexCoord(0, 0, W, H);
      const hBot   = hexCoord(0, 2, W, H);

      let bx = mHome.cx, by = mHome.groundY, bz = 0, bLean = 0, bFaceRight = false, bAlpha = 1;
      let h1x = hFront.cx, h1z = 0, h1Lean = 0, h1Flash = 0;
      let h2Flash = 0, h3Flash = 0;
      let shakeX = 0, shakeY = 0, camZoom = 1.0;
      const pulseT = now * 0.001;

      const intactParts = partSlots.filter(ps => !shIsPartBroken(c.id, ps.idx));

      // Boss & Hero Kinematics by Geometry (`geo`)
      if (isLockedMove) {
        // Part-Broken Sealed Backlash!
        if (p > 0.25 && p < 0.72) {
          const k = (p - 0.25) / 0.47;
          bx = mHome.cx + Math.sin(k * 36) * 8 * (1 - k);
          bLean = 14 * Math.sin(k * Math.PI);
        }
      } else if (geo === 'totem_swap' && intactParts.length > 0) {
        const targetSlot = intactParts[0];
        const tPos = hexCoord(targetSlot.col, targetSlot.row, W, H);
        if (p >= 0.28 && p < 0.78) {
          const k = easeOut(Math.min(1, (p - 0.28) / 0.22));
          bx = mHome.cx + (tPos.cx - mHome.cx) * k;
          by = mHome.groundY + (tPos.groundY - mHome.groundY) * k;
          bz = arch01(k) * 28;
        } else if (p >= 0.78) {
          const k = (p - 0.78) / 0.22;
          bx = tPos.cx + (mHome.cx - tPos.cx) * easeOut(k);
          by = tPos.groundY + (mHome.groundY - tPos.groundY) * easeOut(k);
        }
      } else if (geo === 'sky_dive' || geo === 'leap_slam_3' || geo === 'line_charge_3' || geo === 'ring_aoe_1' || geo === 'ring_quake_6') {
        if (p < 0.26) {
          const k = easeOut(p / 0.26);
          bz = (geo === 'sky_dive' || geo === 'leap_slam_3') ? 76 * k * uSc : 0;
          bLean = 14 * k;
        } else if (p < 0.50) {
          const k = easeOut((p - 0.26) / 0.24);
          bx = mHome.cx + (hFront.cx + 58 * uSc - mHome.cx) * k;
          bz = (geo === 'sky_dive' || geo === 'leap_slam_3') ? 76 * (1 - k) * uSc : 14 * arch01(k);
          bLean = -22 * k;
        } else if (p < 0.82) {
          const k = (p - 0.50) / 0.32;
          bx = (hFront.cx + 58 * uSc) + (mHome.cx - (hFront.cx + 58 * uSc)) * easeOut(Math.max(0, (k - 0.35) / 0.65));
          bLean = (geo === 'ring_aoe_1' || geo === 'ring_quake_6') ? Math.sin(k * Math.PI * 4) * 24 : -16 * (1 - k);
          h1x = hFront.cx - 22 * arch01(k) * uSc; h1Lean = -22 * (1 - k); h1Flash = Math.max(0, 1 - k * 1.9);
          if (k < 0.45) { shakeX = Math.sin(now * 0.11) * 9 * (1 - k * 2); shakeY = Math.cos(now * 0.13) * 7 * (1 - k * 2); camZoom = 1.07; }
        }
      } else if (geo === 'pull_devour') {
        if (p >= 0.32 && p < 0.78) {
          const k = easeOut((p - 0.32) / 0.46);
          h1x = hFront.cx + (mHome.cx - 56 * uSc - hFront.cx) * arch01(k);
          h1Lean = 20 * arch01(k); h1Flash = Math.sin(k * Math.PI);
          if (k > 0.35 && k < 0.70) { shakeX = Math.sin(now * 0.1) * 6; }
        }
      } else {
        // Breath / Cone / Multi-Bite / Ten-Suns / Omen Cataclysm / Tail Sweep
        if (p < 0.30) {
          bLean = 12 * easeOut(p / 0.30);
        } else if (p < 0.52) {
          const k = easeOut((p - 0.30) / 0.22);
          bx = mHome.cx - 28 * k * uSc; bLean = -16 * k;
        } else if (p < 0.86) {
          const k = (p - 0.52) / 0.34;
          bx = mHome.cx - 28 * (1 - easeOut(k)) * uSc; bLean = -16 * (1 - k);
          h1x = hFront.cx - 18 * arch01(k) * uSc; h1Lean = -18 * (1 - k);
          h1Flash = Math.max(0, 1 - k * 1.8);
          h2Flash = (teleKeySet.has('0,0') || teleKeySet.has('1,0')) ? h1Flash * 0.9 : 0;
          h3Flash = (teleKeySet.has('0,2') || teleKeySet.has('1,2')) && c.key !== 'xiangliuwang' ? h1Flash * 0.9 : 0;
          if (k < 0.42) { shakeX = Math.sin(now * 0.11) * 8.5 * (1 - k * 2.2); shakeY = Math.cos(now * 0.13) * 6.5 * (1 - k * 2.2); camZoom = 1.065; }
        }
      }

      // === RENDER 2D ISOMETRIC BATTLEFIELD ===
      ctx.save();
      ctx.clearRect(0, 0, W, H);

      // Dynamic Sky / Realm Atmosphere (including `烛九阴` Day vs Night cycle!)
      const isZhuyinNight = (c.key === 'zhuyin' && (cycleCount % 2 === 1));
      const bg = ctx.createRadialGradient(W * 0.56, H * 0.52, 18, W * 0.5, H * 0.5, W * 0.85);
      if (isZhuyinNight) {
        bg.addColorStop(0, '#131d36'); bg.addColorStop(1, '#060913');
      } else if (activeField === 'abyss_frost') {
        bg.addColorStop(0, '#1a2d3d'); bg.addColorStop(1, '#0a1017');
      } else if (activeField === 'bitter_mire') {
        bg.addColorStop(0, '#1d2e20'); bg.addColorStop(1, '#0a110b');
      } else if (activeField === 'thunder_pool' || activeField === 'mirage_mist') {
        bg.addColorStop(0, '#271c36'); bg.addColorStop(1, '#0c0812');
      } else {
        bg.addColorStop(0, '#3a2319'); bg.addColorStop(1, '#0e0907');
      }
      ctx.fillStyle = bg; ctx.fillRect(0, 0, W, H);

      ctx.translate(W * 0.5 + shakeX, H * 0.5 + shakeY);
      ctx.scale(camZoom, camZoom);
      ctx.translate(-W * 0.5, -H * 0.5);

      // 1. Render 5x3 Isometric Battle Brothers Hex Grid + TileField + Telegraph Warnings!
      const showTele = !isLockedMove && p > 0.06 && p < 0.50;
      const telePulse = showTele ? (0.45 + 0.45 * Math.sin(p * 32)) : 0;

      for (let r = 0; r < 3; r++) {
        for (let colI = 0; colI < 5; colI++) {
          const hc = hexCoord(colI, r, W, H);
          const isHeroSlot = (colI === 1 && r === 1) || (colI === 0 && (r === 0 || r === 2));
          const isMasterSlot = (colI === 3 && r === 1);
          const pSlot = partSlots.find(ps => ps.col === colI && ps.row === r);
          const isBrokenSlot = pSlot && shIsPartBroken(c.id, pSlot.idx);
          const isTele = showTele && teleKeySet.has(colI + ',' + r);

          let stroke = 'rgba(154,126,88,0.24)';
          let fill = 'rgba(36,27,19,0.24)';
          let lw = 1.2;

          if (isMasterSlot) {
            stroke = 'rgba(245,92,68,0.78)'; fill = 'rgba(116,30,22,0.36)'; lw = 2.0;
          } else if (pSlot) {
            if (isBrokenSlot) {
              stroke = 'rgba(130,115,108,0.45)'; fill = 'rgba(42,32,30,0.32)'; lw = 1.3;
            } else if (smode === 'totems') {
              stroke = 'rgba(255,208,96,0.78)'; fill = 'rgba(108,74,18,0.34)'; lw = 1.8;
            } else {
              stroke = 'rgba(238,128,74,0.72)'; fill = 'rgba(98,38,22,0.32)'; lw = 1.8;
            }
          } else if (isHeroSlot) {
            stroke = 'rgba(128,206,122,0.56)'; fill = 'rgba(42,76,38,0.26)'; lw = 1.6;
          }

          shDrawHexPoly(ctx, hc.cx, hc.hexY, 43 * uSc, 15.5 * uSc, stroke, fill, lw);

          // Persistent Dynamic TileField Ground Effects on Arena Hexes
          if (colI >= 1 && colI <= 3) {
            drawFieldOnHex(hc.cx, hc.hexY, uSc, pulseT);
          }
          if (isBrokenSlot && c.key === 'xiangliuwang' && ptVenom) {
            wxDrawSprite(ctx, ptVenom, hc.cx, hc.hexY, 102 * uSc, 48 * uSc, 0, 0.90, false);
          } else if (isBrokenSlot && ptScorch) {
            wxDrawSprite(ctx, ptScorch, hc.cx, hc.hexY, 96 * uSc, 46 * uSc, 0, 0.82, false);
          }

          // Exact Multi-Hex Telegraph Overlay (`⚠ 凶招范围预警`)
          if (isTele) {
            shDrawHexPoly(
              ctx, hc.cx, hc.hexY, 41 * uSc, 14.5 * uSc,
              `rgba(255,214,102,${(telePulse * 0.95).toFixed(2)})`,
              `rgba(225,48,32,${(telePulse * 0.34).toFixed(2)})`,
              2.0
            );
          }
        }
      }

      // 2. Multi-Tile Spine Links (`segments` / `appendages`) & Domain Totem Energy Tethers (`totems`)
      partSlots.forEach(ps => {
        const broken = shIsPartBroken(c.id, ps.idx);
        const pc = hexCoord(ps.col, ps.row, W, H);
        if (smode === 'segments' || smode === 'appendages') {
          ctx.save();
          ctx.strokeStyle = broken ? 'rgba(110,95,90,0.28)' : (smode === 'segments' ? 'rgba(255,156,82,0.62)' : 'rgba(196,238,118,0.55)');
          ctx.lineWidth = (broken ? 3 : 7) * uSc;
          ctx.beginPath();
          ctx.moveTo(bx, by + 16 * uSc);
          ctx.quadraticCurveTo((bx + pc.cx) * 0.5, (by + pc.groundY) * 0.5 + 22 * uSc, pc.cx, pc.groundY + 16 * uSc);
          ctx.stroke();
          ctx.restore();
        } else if (smode === 'totems' && !broken) {
          ctx.save();
          ctx.strokeStyle = ps.spec.totemTheme === 'violet' ? 'rgba(214,148,255,0.65)' : (ps.spec.totemTheme === 'jade' ? 'rgba(110,238,176,0.65)' : 'rgba(255,208,92,0.72)');
          ctx.lineWidth = 2.4 * uSc;
          ctx.setLineDash([6, 5]);
          ctx.lineDashOffset = -now * 0.03;
          ctx.beginPath();
          ctx.moveTo(pc.cx, pc.groundY - 26 * uSc);
          ctx.lineTo(bx, by - 24 * uSc);
          ctx.stroke();
          ctx.restore();
        }
      });

      // Totem Protective Ward Shield around Boss when >=1 Totem is alive!
      if (smode === 'totems' && intactParts.length > 0 && baguaIm) {
        wxDrawSprite(ctx, baguaIm, bx, by - 14 * uSc, (118 + intactParts.length * 10) * uSc, (118 + intactParts.length * 10) * uSc, pulseT * 1.1, 0.28 + intactParts.length * 0.12, false);
      }

      // 3. Painter's Algorithm Row-Sorted Entities (Row 0 -> Row 1 -> Row 2)
      for (let rowRender = 0; rowRender < 3; rowRender++) {
        // Heroes on this row
        if (rowRender === 0 && isBoss) {
          drawHeroMini(h2Torso, h2Head, swdWpn, null, hTop.cx, hTop.groundY, 0, h2Flash > 0.1 ? -14 : 0, h2Flash, uSc * 0.88, false, '侧翼剑侠');
        }
        if (rowRender === 1) {
          drawHeroMini(h1Torso, h1Head, heroWpn, heroShd, h1x, hFront.groundY, h1z, h1Lean, h1Flash, uSc * 0.98, false, '前卫刀盾');
        }
        if (rowRender === 2 && isBoss) {
          const onHighGround = (c.key === 'xiangliuwang' || c.key === 'gonggong');
          drawHeroMini(h3Torso, h3Head, bowWpn, null, hBot.cx, hBot.groundY, 0, h3Flash > 0.1 ? -14 : 0, h3Flash, uSc * 0.90, onHighGround, onHighGround ? '高台神射' : '掠阵神射');
        }

        // Sub-Parts / Appendages / Totems on this row!
        partSlots.filter(ps => ps.row === rowRender).forEach(ps => {
          const broken = shIsPartBroken(c.id, ps.idx);
          const pc = hexCoord(ps.col, ps.row, W, H);
          let px = pc.cx, py = pc.groundY, pz = 0, pLean = 0;

          if (!broken && !isLockedMove) {
            if (smode === 'segments') {
              pz = Math.sin(pulseT * 3.8 + ps.idx * 1.4) * 5 * uSc;
              if ((geo === 'tail_sweep_arc' || sk.animMode === 'coiled_crush') && p > 0.28 && p < 0.78) {
                const sk0 = arch01((p - 0.28) / 0.50);
                px -= 98 * sk0 * uSc;
                pLean = -24 * sk0;
              }
            } else if (smode === 'appendages') {
              // Bound head or multi-head lunge!
              const isCasterPart = (sk.lockedByPartIdx === ps.idx) || geo === 'multi_bite_3';
              if (isCasterPart && p > 0.24 && p < 0.78) {
                const subP = geo === 'multi_bite_3'
                  ? Math.max(0, Math.min(1, ((p - 0.24) / 0.50) * 1.5 - ps.idx * 0.15))
                  : ((p - 0.24) / 0.54);
                const lk = arch01(subP);
                px -= 74 * lk * uSc;
                pz = 18 * lk * uSc;
                pLean = -22 * lk;
              } else {
                pz = Math.sin(pulseT * 3.2 + ps.idx) * 4 * uSc;
              }
            } else if (smode === 'totems') {
              pz = (16 + Math.sin(pulseT * 3.5 + ps.idx * 1.2) * 6) * uSc;
              if (geo === 'totem_swap' && intactParts[0] && intactParts[0].idx === ps.idx && p >= 0.28 && p < 0.78) {
                const k = easeOut(Math.min(1, (p - 0.28) / 0.22));
                px = pc.cx + (mHome.cx - pc.cx) * k;
                py = pc.groundY + (mHome.groundY - pc.groundY) * k;
              }
            }
          }

          if (broken) {
            const bSc = smode === 'totems' ? 0.72 : 0.66;
            drawBeastUnit(ps.injIm, px, py, 0, smode === 'totems' ? 6 : 16, uSc * bSc, 0.52, smode === 'totems', 'grayscale(0.75) brightness(0.72)');
            shDrawOverheadBars(ctx, px, py - 46 * uSc, 0, 0, '#666', '#666', '✕ 已破除');
          } else {
            const pSc = smode === 'totems' ? 0.84 : (smode === 'segments' ? 0.88 : 0.82);
            if (smode === 'totems' && ptRingGold) {
              const ringIm = ps.spec.totemTheme === 'violet' ? ptRingViolet : (ps.spec.totemTheme === 'frost' || ps.spec.totemTheme === 'cyan' ? ptRingCyan : ptRingGold);
              wxDrawSprite(ctx, ringIm, px, py - pz + 8 * uSc, 82 * uSc, 52 * uSc, pulseT * 1.8, 0.62, false);
            }
            drawBeastUnit(ps.im, px, py, pz, pLean, uSc * pSc, 0.98, smode === 'totems', '');
            const shortLbl = (ps.spec.name || '').split('·').pop();
            shDrawOverheadBars(ctx, px, py - pz - 58 * uSc, 0.92, 0.95, smode === 'totems' ? '#ffd978' : '#d8c29d', smode === 'totems' ? '#ff9f1c' : '#e85d44', shortLbl);
          }
        });

        // Master Boss Pawn on Row 1 (40 single-hex Bosses stand cleanly on 1 hex with bespoke law visuals!)
        if (rowRender === 1) {
          if (auraIm && p > 0.08 && p < 0.62) {
            const ak = Math.sin(((p - 0.08) / 0.54) * Math.PI);
            wxDrawSprite(ctx, auraIm, bx, by - bz - 10 * uSc, (132 + ak * 24) * uSc, (132 + ak * 24) * uSc, p * 1.4, ak * 0.68, false);
          }
          if ((c.key === 'mengji' || c.key === 'tiangouwang') && p > 0.24 && p < 0.56) {
            drawBeastUnit(beastIm, bx + 26 * uSc, by, bz * 0.6, bLean, uSc * 0.94, 0.34, false, 'brightness(1.35)');
          }
          const masterFilter = internalBrk ? 'brightness(0.92) saturate(0.86)' : '';
          drawBeastUnit(beastIm, bx, by, bz, bLean, uSc * (isBoss ? 1.04 : 0.90), bAlpha, bFaceRight, masterFilter);
          const luwuSeasons = ['春木生发', '夏火烈威', '秋金肃杀', '冬水寒封'];
          let bossTag = c.shortName || c.name;
          if (isZhuyinNight) bossTag = c.shortName + '·瞑夜露破绽';
          else if (c.key === 'zhuyin') bossTag = c.shortName + '·视昼耀目';
          else if (c.key === 'luwu') bossTag = c.shortName + '·' + luwuSeasons[cycleCount % 4];
          else if (c.key === 'huodou') bossTag = c.shortName + '·吞火畏寒';
          else if (internalBrk && c.internalBreak) bossTag = c.shortName + '·破绽已碎';
          shDrawOverheadBars(ctx, bx, by - bz - 76 * uSc, internalBrk ? 0.38 : 0.94, internalBrk ? 0.68 : 0.96, '#e5c483', '#ef4436', bossTag);

          // Bespoke 1-Hex & Flagship Law Visual Overlays
          if (isZhuyinNight && ptRingCyan) {
            wxDrawSprite(ctx, ptRingCyan, bx - 14 * uSc, by - 26 * uSc, 56 * uSc, 56 * uSc, pulseT * 3, 0.88, false);
          } else if (c.key === 'hundun') {
            const orifices = (cycleCount % 7) + 1;
            for (let oi = 0; oi < 7; oi++) {
              const oa = -Math.PI * 0.8 + (oi * Math.PI * 1.6) / 6;
              const ox = bx + Math.cos(oa) * 44 * uSc, oy = by - 26 * uSc + Math.sin(oa) * 32 * uSc;
              wxDrawSprite(ctx, oi < orifices ? ptGlint : ptRingGold, ox, oy, (oi < orifices ? 26 : 16) * uSc, (oi < orifices ? 26 : 16) * uSc, pulseT * 2, oi < orifices ? 0.95 : 0.30, false);
            }
          } else if (c.key === 'baize' && baguaIm) {
            wxDrawSprite(ctx, baguaIm, bx - 16 * uSc, by - 24 * uSc, 88 * uSc, 88 * uSc, -pulseT * 1.8, 0.72, false);
          } else if (c.key === 'luwu') {
            const sIdx = cycleCount % 4;
            const sRing = sIdx === 0 ? lotusIm : (sIdx === 1 ? ptRingGold : (sIdx === 2 ? baguaIm : ptRingCyan));
            if (sRing) wxDrawSprite(ctx, sRing, bx, by - 18 * uSc, 96 * uSc, 96 * uSc, pulseT * 1.6, 0.74, false);
          } else if (c.key === 'huodou' && ptRingGold) {
            wxDrawSprite(ctx, ptRingGold, bx - 6 * uSc, by - 20 * uSc, 84 * uSc, 84 * uSc, -pulseT * 2.4, 0.72, false);
          } else if (c.internalBreak && !internalBrk && heroShd && (c.internalBreak.mode === 'heavy' || c.internalBreak.mode === 'blunt')) {
            wxDrawSprite(ctx, ptRingGold, bx - 24 * uSc, by - 18 * uSc, 52 * uSc, 64 * uSc, pulseT * 1.2, 0.62, false);
          } else if (c.internalBreak && internalBrk && ptGlint) {
            wxDrawSprite(ctx, ptGlint, bx - 12 * uSc, by - 20 * uSc, 48 * uSc, 48 * uSc, pulseT * 3.5, 0.88, false);
          } else if (c.key === 'xingtian' && p > 0.56 && ptGlint) {
            wxDrawSprite(ctx, ptGlint, bx - 8 * uSc, by - 12 * uSc, 48 * uSc, 48 * uSc, pulseT * 4, 0.92, false);
          }
        }
      }

      // 4. AAA MULTI-FRAME KINETIC SEQUENCES + TOTEM CROSS-RAYS + PARTICLE CLIMAX!
      if (isLockedMove) {
        if (p > 0.30 && p < 0.85) {
          const lk = (p - 0.30) / 0.55;
          wxDrawSprite(ctx, ptSmoke, bx - 12 * uSc, by - 24 * uSc, 96 * uSc, 68 * uSc, lk * 2, 1 - lk, false);
          ctx.save();
          ctx.font = 'bold 14px "Microsoft YaHei UI", sans-serif';
          ctx.textAlign = 'center';
          ctx.strokeStyle = '#0d0806'; ctx.lineWidth = 4;
          const msg = '🔒 关键部位已破 · 【' + sk.name + '】永久封印！';
          ctx.strokeText(msg, W * 0.5, 62 - lk * 14);
          ctx.fillStyle = '#ff9b8a';
          ctx.fillText(msg, W * 0.5, 62 - lk * 14);
          ctx.restore();
        }
      } else {
        const s1Cnt = (KINETIC_ASSETS.meta && KINETIC_ASSETS.meta[kinSeq] && KINETIC_ASSETS.meta[kinSeq].count) || 10;
        const s2Cnt = (kinSeq2 && KINETIC_ASSETS.meta && KINETIC_ASSETS.meta[kinSeq2] && KINETIC_ASSETS.meta[kinSeq2].count) || 10;

        // Triangulated Totem Cross-Beams (`女丑·十日焦山` / `阵眼交叉射线`)!
        if ((geo === 'ten_suns_ray' || geo === 'totem_ray') && p >= 0.32 && p <= 0.86) {
          const u = (p - 0.32) / 0.54;
          const beamSources = intactParts.length ? intactParts.map(ps => hexCoord(ps.col, ps.row, W, H)) : [{ cx: bx, groundY: by - 40 * uSc }];
          beamSources.forEach((srcPos, bi) => {
            const tgt = bi % 2 === 0 ? hFront : hTop;
            const ang = Math.atan2(tgt.groundY - (srcPos.groundY - 24 * uSc), tgt.cx - srcPos.cx);
            const mx = (srcPos.cx + tgt.cx) * 0.5, my = (srcPos.groundY - 24 * uSc + tgt.groundY) * 0.5;
            wxDrawKineticFrame(ctx, 'wx_kin_celestial_beam', u * 10, mx, my, 1.05 * uSc, ang, 0.94, false, [255, 228, 145]);
          });
          wxDrawKineticFrame(ctx, 'wx_kin_flame_pillar', u * 10, hFront.cx, hFront.groundY - 38 * uSc, 1.12 * uSc, 0, 0.96, false, [255, 195, 115]);
        } else if (geo === 'totem_swap' && p >= 0.24 && p <= 0.82) {
          const u = (p - 0.24) / 0.58;
          wxDrawKineticFrame(ctx, 'wx_kin_warp_seal', u * 10, mHome.cx, mHome.groundY - 12 * uSc, 1.12 * uSc, 0, 0.94, false, kinTint);
          if (intactParts[0]) {
            const tp = hexCoord(intactParts[0].col, intactParts[0].row, W, H);
            wxDrawKineticFrame(ctx, 'wx_kin_warp_seal', u * 10, tp.cx, tp.groundY - 18 * uSc, 1.04 * uSc, 0, 0.94, false, kinTint);
          }
        } else if (p >= 0.30 && p <= 0.88) {
          const u = (p - 0.30) / 0.58;
          const fxX = (geo === 'ring_aoe_1' || geo === 'ring_aoe_2') ? bx : (hFront.cx + 24 * uSc);
          const fxY = hFront.groundY - 18 * uSc;
          wxDrawKineticFrame(ctx, kinSeq, u * s1Cnt, fxX, fxY, 1.18 * uSc, 0, 0.98, true, kinTint);
          if (kinSeq2 && p >= 0.42) {
            const u2 = (p - 0.42) / 0.48;
            const y2 = kinSeq2 === 'wx_kin_flame_pillar' ? fxY - 30 * uSc : (kinSeq2 === 'wx_kin_thunder_bolt' ? fxY - 48 * uSc : fxY);
            wxDrawKineticFrame(ctx, kinSeq2, u2 * s2Cnt, hFront.cx, y2, 1.08 * uSc, 0, 0.90, true, kinTint);
          }
          // Multi-hex Cone / Field Detonate extra bursts on flanking hexes!
          if ((geo === 'cone_3' || geo === 'field_detonate' || geo === 'omen_cataclysm' || geo === 'multi_bite_3') && p >= 0.40) {
            const uf = (p - 0.40) / 0.48;
            wxDrawKineticFrame(ctx, kinSeq, uf * s1Cnt, hTop.cx + 30 * uSc, hTop.groundY - 14 * uSc, 0.82 * uSc, 0, 0.82, true, kinTint);
            if (c.key !== 'xiangliuwang' || geo !== 'field_detonate') {
              wxDrawKineticFrame(ctx, kinSeq, uf * s1Cnt, hBot.cx + 30 * uSc, hBot.groundY - 14 * uSc, 0.82 * uSc, 0, 0.82, true, kinTint);
            }
          }
        }

        // Exact-Frame Shockwave Ring + 24 Physics Particles + Tactical Callout!
        const postImp = p - impP;
        if (postImp >= 0 && postImp < 0.42) {
          const age = postImp * (cycleMs / 1000.0);
          if (ptRingMain) {
            const rSc = (0.35 + easeOut(postImp / 0.42) * 1.85) * uSc;
            wxDrawSprite(ctx, ptRingMain, hFront.cx, hFront.hexY - 8 * uSc, 136 * rSc, 84 * rSc, 0, (1 - postImp / 0.42) * 0.92, false);
          }
          for (let i = 0; i < 22; i++) {
            const sp = seedP[i % seedP.length];
            if (age > sp.life) continue;
            const u = age / sp.life;
            const im = ptSparks[i % ptSparks.length] || ptRock;
            if (!im) continue;
            const px = hFront.cx + (sp.vx - 60) * age * uSc;
            const py = (hFront.groundY - 12 * uSc) + sp.vy * age * uSc + 90 * age * age * uSc;
            wxDrawSprite(ctx, im, px, py, im.naturalWidth * sp.sc * uSc * (1 - u * 0.5), im.naturalHeight * sp.sc * uSc * (1 - u * 0.5), (sp.rot0 + sp.tq * age) * Math.PI / 180, 1 - u * u, false);
          }

          const pk = postImp / 0.42;
          let callTxt = (sk.dmg || '凶招命中') + ((sk.effects && sk.effects[0]) ? (' · ' + sk.effects[0]) : '');
          if (c.key === 'xiangliuwang' && geo === 'multi_bite_3') {
            callTxt = `九首连噬 ×${Math.max(1, intactParts.length)}口 · 汲血染奇毒！`;
          } else if (c.key === 'xiangliuwang' && geo === 'field_detonate') {
            callTxt = '苦泉漫灌！（高台神射免伤规避）';
          } else if (c.key === 'hundun' && (cycleCount % 7) === 6) {
            callTxt = '☯ 日凿一窍 · 七窍成而混沌死！';
          }
          ctx.save();
          ctx.globalAlpha = Math.min(1, (1 - pk) * 2.3);
          ctx.font = 'bold 13.5px "Microsoft YaHei UI", sans-serif';
          ctx.textAlign = 'center';
          ctx.strokeStyle = 'rgba(0,0,0,0.9)'; ctx.lineWidth = 3.6;
          const cxTxt = Math.max(115, Math.min(W - 115, hFront.cx + 36 * uSc));
          ctx.strokeText(callTxt, cxTxt, 56 - pk * 18);
          ctx.fillStyle = '#ffe29a';
          ctx.fillText(callTxt, cxTxt, 56 - pk * 18);
          ctx.restore();
        }
      }

      ctx.restore();

      // 5. Sleek Boss Calligraphy Cut-In Ribbon (top-left) + Multi-Hex Footprint Badge (top-right)
      ctx.save();
      const gH = ctx.createLinearGradient(8, 8, 258, 8);
      gH.addColorStop(0, 'rgba(14,9,8,0.90)');
      gH.addColorStop(0.82, 'rgba(26,14,11,0.78)');
      gH.addColorStop(1, 'rgba(26,14,11,0)');
      ctx.fillStyle = gH;
      ctx.fillRect(8, 8, 254, 36);
      ctx.fillStyle = col;
      ctx.fillRect(8, 8, 3.5, 36);
      ctx.font = 'bold 13px "STKaiti", "KaiTi", "Microsoft YaHei UI", serif';
      ctx.fillStyle = '#ffe5b4';
      ctx.textAlign = 'left';
      ctx.fillText('⚡ ' + (sk.name || '山海妖技'), 18, 23);
      ctx.font = '10.5px "Microsoft YaHei UI", sans-serif';
      ctx.fillStyle = '#d6bfa2';
      ctx.fillText((sk.range || '') + (c.fieldLabel ? (' · 灾域：' + c.fieldLabel) : ''), 18, 38);

      const occupiedCnt = 1 + intactParts.length;
      const modePill = isBoss
        ? `${c.structureLabel || '本命法相'} · 实占 ${occupiedCnt} 格`
        : `${c.structureLabel || '荒泽异兽'} · ${occupiedCnt} 格`;
      ctx.font = 'bold 11px "Microsoft YaHei UI", sans-serif';
      const mpW = ctx.measureText(modePill).width + 16;
      ctx.fillStyle = 'rgba(18,11,9,0.82)';
      ctx.fillRect(W - mpW - 8, 8, mpW, 21);
      ctx.strokeStyle = 'rgba(242,166,102,0.52)';
      ctx.strokeRect(W - mpW - 8, 8, mpW, 21);
      ctx.fillStyle = '#ffdca2';
      ctx.textAlign = 'right';
      ctx.fillText(modePill, W - 16, 22.5);
      ctx.restore();

      const rafId = requestAnimationFrame(step);
      if (isModal) shState.modalRaf = rafId; else shState.stageRaf = rafId;
    }

    const firstRaf = requestAnimationFrame(step);
    if (isModal) shState.modalRaf = firstRaf; else shState.stageRaf = firstRaf;
  }

  function renderBossSandboxBarHtml(c, isModal) {
    if (!c || (c.kind !== 'boss' && !(c.parts && c.parts.length))) return '';
    const parts = c.parts || [];
    const ib = c.internalBreak || null;
    const intBrk = ib ? shIsInternalBroken(c.id) : false;
    const hasAnyBroken = intBrk || parts.some((_, idx) => shIsPartBroken(c.id, idx));
    const verb = c.structureMode === 'totems' ? '🏹 射落/拔除：'
               : (c.structureMode === 'appendages' ? '⚔ 斩断破坏：' : '🔨 碎鳞破甲：');
    const attrName = isModal ? 'data-msh-break' : 'data-sh-break';
    const intAttr  = isModal ? 'data-msh-break-internal="1"' : 'data-sh-break-internal="1"';
    const resetAttr = isModal ? 'data-msh-reset-parts="1"' : 'data-sh-reset-parts="1"';

    return `
      <div class="wx-sh-law-bar">
        <div>
          <strong style="color:#ffd898">☯ 本命法相【${esc(c.traitName || '')}】：</strong>
          <span>${esc(c.counterplay || c.traitDesc || '')}</span>
        </div>
        ${(parts.length || ib) ? `
          <div class="wx-sh-parts-row">
            <span style="font-size:11.5px;color:#d6bea0;font-weight:700">${parts.length ? '互动破局沙盘（实时演练断部/拔阵眼）：' : '单格本命破招演练（不生虚假副体）：'}</span>
            ${parts.map((pt, idx) => {
              const brk = shIsPartBroken(c.id, idx);
              return `<button type="button" class="wx-sh-part-btn ${brk ? 'broken' : ''}" ${attrName}="${idx}" title="${esc(pt.role || '')}">
                ${brk ? '✕ 已破：' : verb}${esc(pt.name)}
              </button>`;
            }).join('')}
            ${ib ? `<button type="button" class="wx-sh-part-btn ${intBrk ? 'broken' : ''}" ${intAttr} title="单格本体克制击破 ${ib.max} 次可破除【${esc(ib.name)}】${ib.lockSkillName ? ('并封印【' + esc(ib.lockSkillName) + '】') : ''}">
              ${intBrk ? '✕ 已击破：' : (esc(ib.modeLabel || '🎯 单格破招') + '：')}${esc(ib.name)}
            </button>` : ''}
            ${hasAnyBroken ? `<button type="button" class="wx-sh-btn" ${resetAttr} style="padding:2px 8px;font-size:11px">↺ 复原全盛法相</button>` : ''}
          </div>` : ''}
      </div>`;
  }

  function renderShanHaiTheaterInner(filteredCreatures) {
    if (filteredCreatures) shState.lastFiltered = filteredCreatures;
    const pool = shResolvePool(filteredCreatures);
    let cur = creatureById.get(shState.creatureId);
    if (!cur || !pool.some(x => x.id === cur.id)) {
      cur = pool[0] || (DB.bestiary.creatures || [])[0];
      if (cur) { shState.creatureId = cur.id; shState.skillIdx = 0; }
    }
    if (!cur) return '';
    const skills = cur.skills || [];
    if (shState.skillIdx >= skills.length) shState.skillIdx = 0;
    const curSk = skills[shState.skillIdx] || skills[0] || {};
    const totalHex = 1 + (cur.parts ? cur.parts.length : 0);

    return `
      <div class="wx-sh-head">
        <div>
          <h3>🐉 山海六十四大妖 · 单多格严谨法相与专属部位阵眼 60fps 实战演武台</h3>
          <p>严谨区分 8尊多体节真龙巨蟒、6尊多首共生断肢、10尊天象奇物阵眼与 40尊纯粹单格本命异律（全量 56 张手绘部位与阵眼立绘 + 零重复破局考题）</p>
        </div>
        <button type="button" class="wx-sh-btn" data-sh-toggle="1">${shState.collapsed ? '▼ 展开异兽演武台' : '▲ 收起演武台'}</button>
      </div>
      ${shState.collapsed ? '' : `
      <div class="wx-sh-cats">
        ${SH_CAT_DEFS.map(([cid, label]) => `
          <button type="button" class="wx-sh-cat" data-sh-cat="${esc(cid)}" aria-pressed="${shState.cat === cid}">${esc(label)}</button>`).join('')}
      </div>
      <div class="wx-sh-body">
        <div class="wx-sh-roster" id="wx-sh-roster-list">
          ${pool.map(c => {
            const thumb = (SH_ASSETS.busts && SH_ASSETS.busts[c.id]) || (c.icon && DB.icons[c.icon]) || '';
            const pCnt = 1 + ((c.parts && c.parts.length) || 0);
            return `
              <button type="button" class="wx-sh-pick" data-sh-pick="${esc(c.id)}" aria-pressed="${c.id === cur.id}">
                ${thumb ? `<img src="${thumb}" alt="" loading="lazy">` : ''}
                <div class="wx-sh-pick-meta">
                  <div class="wx-sh-pick-name">${esc(c.shortName || c.name)}</div>
                  <div class="wx-sh-pick-sub">${esc(c.structureLabel || c.rank)} · 占${pCnt}格 · ${(c.skills || []).length}式</div>
                </div>
              </button>`;
          }).join('')}
        </div>
        <div class="wx-sh-stage-col">
          <div class="wx-sh-stage-top">
            <div class="wx-sh-stage-title">
              <span>${esc(cur.name)}</span>
              <span class="wx-sh-pill">${esc(cur.rank)} · 《${esc(cur.chapter)}》</span>
              ${cur.structureLabel ? `<span class="wx-sh-pill mode">${esc(cur.structureLabel)}（共${totalHex}格）</span>` : ''}
              ${cur.fieldLabel ? `<span class="wx-sh-pill field">天地灾域 · ${esc(cur.fieldLabel)}</span>` : ''}
            </div>
            <button type="button" class="wx-sh-btn" data-open="creature:${esc(cur.id)}">查看原典考据与掉落 →</button>
          </div>
          ${renderBossSandboxBarHtml(cur, false)}
          <div class="wx-sh-skill-tabs">
            ${skills.map((sk, idx) => {
              const sealed = shIsSkillSealed(cur.id, sk);
              return `
                <button type="button" class="wx-sh-sk-tab ${sealed ? 'sealed' : ''}" data-sh-sk="${idx}" aria-pressed="${idx === shState.skillIdx}">
                  <span>${sealed ? '🔒 ' : '⚡ '}${esc(sk.name)}</span>
                  <span style="opacity:0.80;font-size:11px">${sealed ? '已封印' : (sk.ap + 'AP · ' + esc(sk.range || ''))}</span>
                </button>`;
            }).join('')}
          </div>
          <div class="wx-sh-canvas-wrap">
            <canvas id="wx-sh-stage-canvas" width="540" height="300"></canvas>
          </div>
          <div class="wx-sh-ctrl-bar">
            <div style="display:flex;gap:6px;flex-wrap:wrap">
              <button type="button" class="wx-sh-btn" data-sh-ctrl="replay">↺ 重放招式</button>
              <button type="button" class="wx-sh-btn" data-sh-ctrl="slow" aria-pressed="${shState.speed < 0.8}">🐢 0.45x 慢放拆解</button>
            </div>
            <div style="font-size:11.5px;color:#d2bc9e">多帧图集：<code>${esc(curSk.kinSeq || '')}</code>${curSk.kinSeq2 ? ` + <code>${esc(curSk.kinSeq2)}</code>` : ''} · 几何 <code>${esc(curSk.geo || 'melee')}</code></div>
          </div>
          <div class="wx-sh-info-box">
            <div class="wx-sh-info-meta">
              <span class="badge b-dark">${curSk.ap || 0} AP · ${curSk.qi || 0} 内息</span>
              <span class="badge">${esc(curSk.range || '')}</span>
              ${curSk.dmg ? `<span class="badge b-gold">${esc(curSk.dmg)}</span>` : ''}
              ${curSk.animLabel ? `<span class="badge b-sect">${esc(curSk.animLabel)}</span>` : ''}
              ${(curSk.effects || []).map(ef => `<span class="badge b-unique">${esc(ef)}</span>`).join('')}
            </div>
            <div>${esc(curSk.desc || '')}</div>
          </div>
        </div>
      </div>`}`;
  }

  function refreshShanHaiTheaterDom(filteredCreatures) {
    const box = document.getElementById('wx-sh-theater-root');
    if (!box) return;
    const prevScroll = (document.getElementById('wx-sh-roster-list') || {}).scrollTop || 0;
    box.innerHTML = renderShanHaiTheaterInner(filteredCreatures);
    const nextList = document.getElementById('wx-sh-roster-list');
    if (nextList) nextList.scrollTop = prevScroll;
    if (shState.collapsed) {
      stopShanHaiStage();
    } else {
      const cur = creatureById.get(shState.creatureId);
      if (cur) requestAnimationFrame(() => startShanHaiCanvas('wx-sh-stage-canvas', cur, shState.skillIdx, false));
    }
  }

  function renderModalCreatureTheaterHtml(c) {
    if (!c || !c.skills || !c.skills.length) return '';
    const idx = (shState.modalCreatureId === c.id && shState.modalSkillIdx < c.skills.length) ? shState.modalSkillIdx : 0;
    const sk = c.skills[idx] || c.skills[0];
    const totalHex = 1 + ((c.parts && c.parts.length) || 0);
    return `
      <div class="wx-modal-sh-box" id="wx-modal-sh-box" data-creature-id="${esc(c.id)}">
        <div class="wx-modal-sh-grid">
          <div class="wx-sh-canvas-wrap">
            <canvas id="wx-modal-sh-canvas" width="480" height="268"></canvas>
          </div>
          <div style="display:flex;flex-direction:column;gap:8px">
            <div style="font-size:13.5px;color:#ffe2b4;font-weight:700">🐉 ${totalHex > 1 ? `多格法相实战演武（实占 ${totalHex} 格）` : '单格独尊异律演武（实占 1 格）'} · ${esc(sk.animLabel || sk.name)}</div>
            <div class="wx-sh-skill-tabs">
              ${c.skills.map((s, si) => {
                const sealed = shIsSkillSealed(c.id, s);
                return `
                  <button type="button" class="wx-sh-sk-tab ${sealed ? 'sealed' : ''}" data-msh-sk="${si}" aria-pressed="${si === idx}">
                    ${sealed ? '🔒 ' : '⚡ '}${esc(s.name)}
                  </button>`;
              }).join('')}
            </div>
            <div style="font-size:12px;color:#d6c2a8;line-height:1.5">${esc(sk.desc || '')}</div>
            <div style="display:flex;flex-wrap:wrap;gap:5px">
              <span class="badge b-dark">${sk.ap} AP · ${sk.qi} 内息</span>
              <span class="badge">${esc(sk.range || '')}</span>
              ${sk.dmg ? `<span class="badge b-gold">${esc(sk.dmg)}</span>` : ''}
              ${(sk.effects || []).map(ef => `<span class="badge b-unique">${esc(ef)}</span>`).join('')}
            </div>
            <div style="display:flex;gap:6px;flex-wrap:wrap">
              <button type="button" class="wx-sh-btn" data-msh-ctrl="replay">↺ 重放</button>
              <button type="button" class="wx-sh-btn" data-msh-ctrl="slow" aria-pressed="${shState.modalSpeed < 0.8}">🐢 0.45x 慢放</button>
              <button type="button" class="wx-sh-btn" data-sh-goto="${esc(c.id)}">在主演武台打开 →</button>
            </div>
          </div>
        </div>
        ${((c.parts && c.parts.length) || c.internalBreak || c.kind === 'boss') ? `<div style="margin-top:10px">${renderBossSandboxBarHtml(c, true)}</div>` : ''}
      </div>`;
  }
// === WX_SHANHAI_THEATER_JS_END ==="""


SHANHAI_EVENTS_JS_V2 = r"""    // --- WX_SHANHAI_EVENTS_START ---
    const shToggle = e.target.closest('[data-sh-toggle]');
    if (shToggle) {
      shState.collapsed = !shState.collapsed;
      refreshShanHaiTheaterDom();
      return;
    }
    const shCatBtn = e.target.closest('[data-sh-cat]');
    if (shCatBtn) {
      shState.cat = shCatBtn.dataset.shCat;
      shState.skillIdx = 0;
      refreshShanHaiTheaterDom();
      return;
    }
    const shPickBtn = e.target.closest('[data-sh-pick]');
    if (shPickBtn) {
      shState.creatureId = shPickBtn.dataset.shPick;
      shState.skillIdx = 0;
      refreshShanHaiTheaterDom();
      return;
    }
    const shSkBtn = e.target.closest('[data-sh-sk]');
    if (shSkBtn) {
      shState.skillIdx = Number(shSkBtn.dataset.shSk) || 0;
      refreshShanHaiTheaterDom();
      return;
    }
    const shBreakBtn = e.target.closest('[data-sh-break]');
    if (shBreakBtn) {
      shTogglePartBroken(shState.creatureId, Number(shBreakBtn.dataset.shBreak) || 0);
      refreshShanHaiTheaterDom();
      return;
    }
    const shBreakIntBtn = e.target.closest('[data-sh-break-internal]');
    if (shBreakIntBtn) {
      shToggleInternalBroken(shState.creatureId);
      refreshShanHaiTheaterDom();
      return;
    }
    const shResetBtn = e.target.closest('[data-sh-reset-parts]');
    if (shResetBtn) {
      shResetParts(shState.creatureId);
      refreshShanHaiTheaterDom();
      return;
    }
    const shCtrlBtn = e.target.closest('[data-sh-ctrl]');
    if (shCtrlBtn) {
      const act = shCtrlBtn.dataset.shCtrl;
      if (act === 'slow') shState.speed = shState.speed < 0.8 ? 1.0 : 0.45;
      refreshShanHaiTheaterDom();
      return;
    }
    const mshSkBtn = e.target.closest('[data-msh-sk]');
    if (mshSkBtn) {
      const box = document.getElementById('wx-modal-sh-box');
      const cr = box ? creatureById.get(box.dataset.creatureId) : null;
      if (cr) {
        shState.modalCreatureId = cr.id;
        shState.modalSkillIdx = Number(mshSkBtn.dataset.mshSk) || 0;
        box.outerHTML = renderModalCreatureTheaterHtml(cr);
        document.querySelectorAll('.wx-sh-sk-card-act[data-msh-sk]').forEach(btn => {
          btn.setAttribute('aria-pressed', String(Number(btn.dataset.mshSk) === shState.modalSkillIdx));
        });
        requestAnimationFrame(() => startShanHaiCanvas('wx-modal-sh-canvas', cr, shState.modalSkillIdx, true));
      }
      return;
    }
    const mshBreakBtn = e.target.closest('[data-msh-break]');
    if (mshBreakBtn) {
      const box = document.getElementById('wx-modal-sh-box');
      const cr = box ? creatureById.get(box.dataset.creatureId) : null;
      if (cr) {
        shTogglePartBroken(cr.id, Number(mshBreakBtn.dataset.mshBreak) || 0);
        box.outerHTML = renderModalCreatureTheaterHtml(cr);
        requestAnimationFrame(() => startShanHaiCanvas('wx-modal-sh-canvas', cr, shState.modalSkillIdx, true));
      }
      return;
    }
    const mshBreakIntBtn = e.target.closest('[data-msh-break-internal]');
    if (mshBreakIntBtn) {
      const box = document.getElementById('wx-modal-sh-box');
      const cr = box ? creatureById.get(box.dataset.creatureId) : null;
      if (cr) {
        shToggleInternalBroken(cr.id);
        box.outerHTML = renderModalCreatureTheaterHtml(cr);
        requestAnimationFrame(() => startShanHaiCanvas('wx-modal-sh-canvas', cr, shState.modalSkillIdx, true));
      }
      return;
    }
    const mshResetBtn = e.target.closest('[data-msh-reset-parts]');
    if (mshResetBtn) {
      const box = document.getElementById('wx-modal-sh-box');
      const cr = box ? creatureById.get(box.dataset.creatureId) : null;
      if (cr) {
        shResetParts(cr.id);
        box.outerHTML = renderModalCreatureTheaterHtml(cr);
        requestAnimationFrame(() => startShanHaiCanvas('wx-modal-sh-canvas', cr, shState.modalSkillIdx, true));
      }
      return;
    }
    const mshCtrlBtn = e.target.closest('[data-msh-ctrl]');
    if (mshCtrlBtn) {
      const box = document.getElementById('wx-modal-sh-box');
      const cr = box ? creatureById.get(box.dataset.creatureId) : null;
      if (cr) {
        const act = mshCtrlBtn.dataset.mshCtrl;
        if (act === 'slow') shState.modalSpeed = shState.modalSpeed < 0.8 ? 1.0 : 0.45;
        box.outerHTML = renderModalCreatureTheaterHtml(cr);
        requestAnimationFrame(() => startShanHaiCanvas('wx-modal-sh-canvas', cr, shState.modalSkillIdx, true));
      }
      return;
    }
    const shGotoBtn = e.target.closest('[data-sh-goto]');
    if (shGotoBtn) {
      const targetId = shGotoBtn.dataset.shGoto;
      modal.close();
      state.mode = 'wiki';
      state.wikiTab = 'bestiary';
      state.subTab = '';
      shState.collapsed = false;
      shState.cat = 'all';
      shState.creatureId = targetId;
      shState.skillIdx = 0;
      render();
      requestAnimationFrame(() => {
        const activeBtn = document.querySelector('#wx-sh-roster-list [aria-pressed="true"]');
        if (activeBtn) activeBtn.scrollIntoView({ block: 'center' });
        window.scrollTo({ top: 120, behavior: 'smooth' });
      });
      return;
    }
    // --- WX_SHANHAI_EVENTS_END ---"""


def replace_between(text: str, start_marker: str, end_marker: str, replacement: str, include_end: bool = True) -> str:
    s_idx = text.find(start_marker)
    assert s_idx != -1, f"Marker not found: {start_marker}"
    e_idx = text.find(end_marker, s_idx)
    assert e_idx != -1, f"Marker not found: {end_marker}"
    end_pos = e_idx + (len(end_marker) if include_end else 0)
    return text[:s_idx] + replacement + text[end_pos:]


def upgrade_html_theaters(html: str) -> str:
    """Idempotently upgrades CSS, JS, HiDPI scaling & event handlers for both 60fps theaters."""
    # 1. Replace Shan-Hai Theater CSS
    html = replace_between(
        html,
        "/* === WX_SHANHAI_THEATER_CSS_START === */",
        "/* === WX_SHANHAI_THEATER_CSS_END === */",
        SHANHAI_THEATER_CSS_V2,
        include_end=True,
    )

    # 2. Upgrade Wuxia Skill VFX Top section (`WX_SKILL_VFX_JS_START` .. `function startSkillVfxCanvas`)
    html = replace_between(
        html,
        "// === WX_SKILL_VFX_JS_START ===",
        "  function startSkillVfxCanvas(canvasId, sk, isModal) {",
        SKILL_VFX_TOP_JS_V2 + "\n  function startSkillVfxCanvas(canvasId, sk, isModal) {",
        include_end=True,
    )

    # 2b. Add HiDPI scaling to legacy fallback inside `startSkillVfxCanvas` (`const W = cv.width, H = cv.height;` -> `wxSetupHiDPICanvas`)
    legacy_wh = """    function step(now) {
      if (!document.getElementById(canvasId)) return;
      const W = cv.width, H = cv.height;"""
    legacy_wh_v2 = """    function step(now) {
      if (!document.getElementById(canvasId)) return;
      const { W, H } = wxSetupHiDPICanvas(cv, isModal ? 460 : 500, isModal ? 254 : 275, ctx);"""
    html = html.replace(legacy_wh, legacy_wh_v2)

    # 2c. Upgrade Wuxia Skill VFX Bottom section (`function getTheaterPool` .. `WX_SKILL_VFX_JS_END`)
    html = replace_between(
        html,
        "  function getTheaterPool(filteredSkills) {",
        "// === WX_SKILL_VFX_JS_END ===",
        SKILL_VFX_BOTTOM_JS_V2,
        include_end=True,
    )

    # 2d. Style `streams` filter button in `WX_SKILL_VFX_CSS` nicely
    if '.wx-vfx-cat[data-vfx-cat="streams"]' not in html:
        html = html.replace(
            '.wx-vfx-cat[data-vfx-cat="kinetic"] {',
            '.wx-vfx-cat[data-vfx-cat="streams"], .wx-vfx-cat[data-vfx-cat="kinetic"] {',
        ).replace(
            '.wx-vfx-cat[data-vfx-cat="kinetic"][aria-pressed="true"] {',
            '.wx-vfx-cat[data-vfx-cat="streams"][aria-pressed="true"], .wx-vfx-cat[data-vfx-cat="kinetic"][aria-pressed="true"] {',
        )
    html = html.replace("aspect-ratio: 480 / 264;", "aspect-ratio: 500 / 275;")

    # 3. Replace Shan-Hai Theater JS (`WX_SHANHAI_THEATER_JS_START` .. `WX_SHANHAI_THEATER_JS_END`)
    html = replace_between(
        html,
        "// === WX_SHANHAI_THEATER_JS_START ===",
        "// === WX_SHANHAI_THEATER_JS_END ===",
        SHANHAI_THEATER_JS_V2,
        include_end=True,
    )

    # 4. Replace Shan-Hai Events JS (`WX_SHANHAI_EVENTS_START` .. `WX_SHANHAI_EVENTS_END`)
    html = replace_between(
        html,
        "    // --- WX_SHANHAI_EVENTS_START ---",
        "    // --- WX_SHANHAI_EVENTS_END ---",
        SHANHAI_EVENTS_JS_V2,
        include_end=True,
    )

    return html
