#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Master Encyclopedia Synchronizer (`山海武侠.html`) for the Shan-Hai Wuxia Deep Overhaul:
  1. 百工铸兵与传世名器 (`DB.equipment` 121 -> 152, `DB.equipmentSets` 8, `DB.forgeMeta`):
     - 37 Historical Relics (`relic_*` bespoke spirits, zero white-board entries)
     - 62 Shan-Hai Divine Gear (`22` weapons + `14` armors + `8` helmets + `6` shields + `12` talismans)
     - 16 Beast Craft Gear & Upgrades (`12` `wx_beast_*` + `4` `wx_up_*`)
     - 6 Base Beast Materials (`wx_mat_*`) + 12 Boss Part-Break Essences (`wx_pmat_*` with 64-Boss part links)
     - 13 Mainhand Weapon Attachments (`wx_wmod_*`) + 6 Belt Tactical Gadgets (`wx_gadget_*`)
     - 5 Quench Catalysts (`QuenchCatalysts`) & Stat-Lock Reforging (`百炼锁词精铸`)
  2. 丹鼎本草与奇药涂毒 (`DB.alchemy`):
     - 65 Spirit Pills & 65 Bagua Cauldron Formulas (incl. 10 Dan-Wu baseline upgrades, 3 Hidden Reverse-Fate
       Mutations `两仪/枯荣/神魔`, and 12 Apex Boss Signature Ancient Formulas `RequiredCoreKey`)
     - 49《山海本草》Spirit Herbs (`17 -> 49`, full Volumes 1-3 with 48x48 WebP icons)
     - 96 Shan-Hai Inner Cores with 96/96 1-to-1 `CoreImprints` (`【本命妖丹丹韵】`), signature pill & forged gear links
     - 9 Mid-Battle Tactical Powders & Multi-Sect Blade Coatings (`wx_tact_*`)
     - 3 Furnace Fire Modes (`文火温养 / 中火守正 / 武火催霞`) & 6 Four-Vein `AuxInfusions`
  3. 武学招式、连段变式与状态 (`DB.manuals` 276, `DB.skills` 173, `DB.statuses` 16):
     - Live skill descriptions & combo forms + 2 HUD-converged belt skills (`奇门机括`, `奇药涂散`)
     - 4 new combat statuses (`断续封生`, `兵刃淬膏`, `寸劲伏脉`, `武道气机流转`)
  4. 《山海经·万妖全志》64 尊多格/多部位大妖同步 (`DB.bestiary.creatures` 139):
     - Live `ShanHaiBossSpecs` (`TraitName`, `CanonQuote`, `TraitDesc`, `CounterHint`, `StructureMode`, `Parts`),
       all 194 bespoke Boss geometric moves (`ShanHaiBossMoves` + 3 flagships), and 64/64 `partBreakLoot` cross-links!
  5. 系统玩法十卷 (`DB.guides`) 与 `DB.stats` / `DB.icons` 离线单文件无损同步。
"""

from __future__ import annotations

import base64
import io
import json
import re
import sys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
MOD_DIR = ROOT / "mod_wuxia"
WIKI_PATH = ROOT / "山海武侠.html"

# Complete mapping of vanilla beast trophy script stems -> (Chinese Wuxia Name, In-Game Drop Sources)
TROPHY_ITEM_ZH = {
    "unhold_bones_item":        ("朱厌千钧铁骨", "讨伐刑天/蚩尤/檮杌等山海秘境首领伴生掉落，或猎杀野外「小次山朱厌巨猿群」获得"),
    "ghoul_horn_item":          ("狍鸮弯钩凶角", "讨伐饕餮/诸怀秘境首领伴生掉落，或清剿野外「北山狍鸮兽群」获得"),
    "lindwurm_scales_item":     ("肥遗赤黑重鳞", "讨伐应龙/肥遗/玄龟秘境首领伴生掉落，或猎杀大泽「太华肥遗毒蛟」获得"),
    "serpent_skin_item":        ("苍梧巴蛇青鳞皮", "讨伐巴蛇/鸣蛇秘境首领伴生掉落，或猎杀沙海山林「苍梧巴蛇毒虺群」获得"),
    "unhold_hide_item":         ("朱厌白首厚革", "讨伐朱厌/陆吾/夔牛/开明兽/青兕秘境首领伴生掉落，或猎杀「朱厌巨猿群」获得"),
    "glowing_resin_item":       ("建木琥珀灵脂", "讨伐句芒建木秘境首领伴生掉落，或猎杀深林「都广建木树精」获得"),
    "hyena_fur_item":           ("西山蛊雕斑革", "讨伐穷奇/蛊雕王/英招/狰/驺虞/乘黄秘境首领伴生掉落，或猎杀荒原「蛊雕狂兽群」获得"),
    "poison_gland_item":        ("异兽五毒腺囊", "讨伐钦原/蜚/无支祁/强良秘境首领伴生掉落，或清剿密林「毒谷赤蛛群」获得"),
    "spider_silk_item":         ("鬼面赤蛛天韧丝", "讨伐天山帝江秘境首领伴生掉落，或清剿密林「毒谷赤蛛群」获得"),
    "witch_hair_item":          ("青丘妖魅惑心发", "讨伐九尾天狐/女丑/武罗/九凤秘境首领伴生掉落，或破除「青丘妖魅群」获得"),
    "lindwurm_bones_item":      ("肥遗毒蛟龙脊骨", "讨伐钟山烛九阴秘境首领伴生掉落，或猎杀「太华肥遗毒蛟」获得"),
    "unhold_heart_item":        ("朱厌心头赤血核", "讨伐天山浑沌秘境首领伴生掉落，或猎杀「朱厌巨猿群」获得"),
    "ghoul_teeth_item":         ("狍鸮裂骨虎齿", "讨伐诸犍/猰貐/凿齿/当康秘境首领伴生掉落，或清剿「北山狍鸮兽群」获得"),
    "werewolf_pelt_item":       ("阴山天狗苍裘", "讨伐天狗皇/孟极/飞廉/山挥/祸斗/夫诸/神狡秘境首领伴生掉落，或清剿「阴山天狗群」获得"),
    "glistening_scales_item":   ("巴蛇微光逆鳞", "讨伐虎蛟/共工/化蛇秘境首领伴生掉落，或猎杀「苍梧巴蛇毒虺群」获得"),
    "third_eye_item":           ("讹兽梦魇诡眼", "讨伐东望白泽/猼訑秘境首领伴生掉落，或清剿「幽谷讹兽群」获得"),
    "petrified_scream_item":    ("荒冢凝魄寒晶", "讨伐发鸠精卫/从极冰夷秘境首领伴生掉落，或清剿「幽谷讹兽群」获得"),
    "vampire_dust_item":        ("幽冥剑魔灵烬", "讨伐毕方/鹓鶵/金乌秘境首领伴生掉落，或攻破前朝古墓斩杀「血影剑魔」获得"),
    "ghoul_brain_item":         ("狍鸮颅内髓珠", "讨伐钩吾狍鸮老祖秘境首领伴生掉落，或清剿野外「北山狍鸮兽群」获得"),
    "parched_skin_item":        ("古神焦枯蜕皮", "讨伐奢比尸/疏属贰负秘境首领伴生掉落，或清剿古墓尸傀获得"),
    "lindwurm_blood_item":      ("九首毒蛟酸血", "讨伐九首相柳皇/凶水九婴秘境首领伴生掉落，或猎杀「太华肥遗毒蛟」获得"),
    "heart_of_the_forest_item": ("邓林盘桃神木心", "讨伐逐日夸父秘境首领伴生掉落，或猎杀深林「都广建木树精」获得"),
}

VANILLA_SKILL_NAMES = {
    "actives.footwork":    "滑步脱身",
    "actives.rotation":    "换位护友",
    "actives.indomitable": "沉岳硬抗",
    "actives.recover":     "吐纳回气",
    "perk.brawny":         "披甲行气",
    "perk.steel_brow":     "铜头铁额",
    "perk.fearsome":       "凶威摄魂",
    "perk.nine_lives":     "九死护脉",
}

GEO_TO_THEATER = {
    "cone_3":         ("dragon_breath",        "#ff6e3a", "扇面吐息 · 三格覆压", "wx_fx_claw_slash",    "wx_vfx_02"),
    "tail_sweep_arc": ("coiled_crush",         "#5ec47a", "巨尾横扫 · 震退破阵", "wx_fx_earth_fissure", "wx_vfx_15"),
    "line_pierce_3":  ("dragon_breath",        "#52c8ff", "贯线吐息 · 三格穿刺", "wx_fx_ice_spikes",    "wx_vfx_10"),
    "line_charge_3":  ("horn_gore_charge",     "#ff8533", "直线蛮冲 · 破阵撞飞", "wx_fx_earth_fissure", "wx_vfx_05"),
    "leap_slam_3":    ("sky_talon_dive",       "#ff595e", "腾空扑击 · 裂地重砸", "wx_fx_earth_fissure", "wx_vfx_05"),
    "ring_quake_6":   ("ape_titan_slam",       "#ff4d36", "环形震岳 · 六格崩裂", "wx_fx_earth_fissure", "wx_vfx_05"),
    "pull_devour":    ("abyss_tentacle_drag",  "#7bd858", "卷摄拖拽 · 噬血吞元", "wx_fx_blood_orb",     "wx_vfx_28"),
    "ranged_barrage": ("venom_needle_barrage", "#9be25f", "攒射毒雨 · 破甲贯颅", "wx_fx_poison_skull",  "wx_vfx_22"),
    "totem_ray":      ("sun_crow_nova",        "#ffae33", "阵眼交辉 · 焚天射线", "wx_fx_thunder_bolt",  "wx_vfx_02"),
    "totem_swap":     ("dream_shadow_ambush",  "#c88cff", "移形换影 · 乾坤易位", "wx_fx_bagua",         "wx_vfx_25"),
    "field_detonate": ("thunder_hoof_stomp",   "#75d8ff", "引爆地脉 · 天灾喷薄", "wx_fx_thunder_bolt",  "wx_vfx_28"),
    "sonic_roar":     ("sonic_dread_roar",     "#e09eff", "凶威怒啸 · 夺魄乱神", "wx_fx_sonic_ring",    "wx_vfx_30"),
    "hex_curse":      ("fox_charm_miasma",     "#d97aff", "妖咒摄心 · 迷魂蚀气", "wx_fx_poison_skull",  "wx_vfx_30"),
    "telegraph_omen": ("sun_crow_nova",        "#ffcc4d", "蓄势天象 · 灭世预警", "wx_fx_bagua",         "wx_vfx_26"),
    "single":         ("feral_pounce",         "#ff6242", "凶牙裂甲 · 绝命扑杀", "wx_fx_claw_slash",    "wx_vfx_04"),
}

GEO_RANGE_LABEL = {
    "cone_3":         "正前扇形3格",
    "tail_sweep_arc": "侧翼弧面3格",
    "line_pierce_3":  "直线贯通3格",
    "line_charge_3":  "直线冲撞3格",
    "leap_slam_3":    "1~3格跃击",
    "ring_quake_6":   "周身6格环震",
    "pull_devour":    "1~2格卷拽",
    "ranged_barrage": "1~4格攒射",
    "totem_ray":      "阵眼连线贯射",
    "totem_swap":     "全场阵眼换位",
    "field_detonate": "全场天灾地脉",
    "sonic_roar":     "周身3格音啸",
    "hex_curse":      "1~4格摄魂咒",
    "telegraph_omen": "全场天象蓄势",
    "single":         "近身1格凶击",
}

STRUCT_LABELS = {
    "segments":   "多格蜿蜒真躯（可碎甲封招）",
    "appendages": "多首/独立肢体（可斩断封招）",
    "totems":     "伴生天地阵眼（可点破反噬）",
    "colossus":   "太古巨灵霸躯",
    "duelist":    "疾影奇袭妖身",
}


def clean_bbcode(s: str) -> str:
    if not s:
        return ""
    out = re.sub(r"\[/?color[^\]]*\]", "", s)
    out = re.sub(r"\[/?[biu]\]", "", out)
    return out.strip()


def extract_balanced_block(src: str, open_brace_idx: int) -> tuple[str, int]:
    depth = 0
    in_str = False
    esc = False
    for idx in range(open_brace_idx, len(src)):
        ch = src[idx]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == '"':
                in_str = False
            continue
        if ch == '"':
            in_str = True
        elif ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return src[open_brace_idx + 1 : idx], idx + 1
    raise ValueError(f"Unbalanced braces starting at {open_brace_idx}")


def parse_named_blocks(section: str, key_pattern: str = r"([A-Za-z0-9_]+)") -> dict[str, str]:
    out: dict[str, str] = {}
    pos = 0
    rx = re.compile(rf"(?<![A-Za-z0-9_.]){key_pattern}\s*(?:<-|=)\s*\{{")
    while True:
        m = rx.search(section, pos)
        if not m:
            break
        key = m.group(1)
        brace_idx = section.find("{", m.end() - 1)
        body, next_pos = extract_balanced_block(section, brace_idx)
        out[key] = body
        pos = next_pos
    return out


def get_str(body: str, field: str, default: str = "") -> str:
    m = re.search(rf'\b{field}\s*=\s*"((?:\\.|[^"\\])*)"', body)
    return m.group(1).replace('\\"', '"').replace("\\n", "\n") if m else default


def get_int(body: str, field: str, default: int = 0) -> int:
    m = re.search(rf"\b{field}\s*=\s*(-?\d+)", body)
    return int(m.group(1)) if m else default


def get_float(body: str, field: str, default: float = 0.0) -> float:
    m = re.search(rf"\b{field}\s*=\s*(-?\d+(?:\.\d+)?)", body)
    return float(m.group(1)) if m else default


def get_bool(body: str, field: str, default: bool = False) -> bool:
    m = re.search(rf"\b{field}\s*=\s*(true|false)", body)
    return (m.group(1) == "true") if m else default


def get_str_list(body: str, field: str) -> list[str]:
    m = re.search(rf"\b{field}\s*=\s*\[([^\]]*)\]", body, re.S)
    return re.findall(r'"([^"]+)"', m.group(1)) if m else []


def encode_item_webp_48(png_path: Path, tint_rgb: tuple[int, int, int] | None = None) -> str:
    im = Image.open(png_path).convert("RGBA")
    bbox = im.getchannel("A").point(lambda a: 255 if a > 12 else 0).getbbox()
    if bbox:
        im = im.crop(bbox)
    if tint_rgb is not None:
        r, g, b, a = im.split()
        tr, tg, tb = tint_rgb
        r = r.point(lambda v: min(255, int(v * (0.72 + 0.50 * (tr / 255.0)))))
        g = g.point(lambda v: min(255, int(v * (0.72 + 0.50 * (tg / 255.0)))))
        b = b.point(lambda v: min(255, int(v * (0.72 + 0.50 * (tb / 255.0)))))
        im = Image.merge("RGBA", (r, g, b, a))
    s = min(44.0 / max(1, im.width), 44.0 / max(1, im.height))
    nw, nh = max(1, int(round(im.width * s))), max(1, int(round(im.height * s)))
    rs = im.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    canvas.alpha_composite(rs, ((48 - nw) // 2, (48 - nh) // 2))
    buf = io.BytesIO()
    canvas.save(buf, format="WEBP", lossless=True, method=6)
    return "data:image/webp;base64," + base64.b64encode(buf.getvalue()).decode("ascii")


def encode_skill_webp_48(png_path: Path) -> str:
    im = Image.open(png_path).convert("RGBA").resize((48, 48), Image.Resampling.LANCZOS)
    buf = io.BytesIO()
    im.save(buf, format="WEBP", quality=92, method=6)
    return "data:image/webp;base64," + base64.b64encode(buf.getvalue()).decode("ascii")


def resolve_gfx_png(rel: str) -> Path:
    candidates = [
        MOD_DIR / "gfx/ui/items" / rel,
        MOD_DIR / "gfx/ui" / rel,
        MOD_DIR / "gfx" / rel,
    ]
    if rel.startswith("skills/"):
        stem = Path(rel).name
        candidates.insert(0, MOD_DIR / "gfx/ui/skills" / stem)
        candidates.insert(1, MOD_DIR / "gfx/skills" / stem)
    for c in candidates:
        if c.exists():
            return c
    raise FileNotFoundError(f"Cannot resolve icon PNG for '{rel}' (tried {[str(x) for x in candidates]})")


def collect_referenced_icons(obj, out: set[str]):
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k == "icons":
                continue
            if k == "icon" and isinstance(v, str) and v:
                out.add(v)
            else:
                collect_referenced_icons(v, out)
    elif isinstance(obj, list):
        for item in obj:
            collect_referenced_icons(item, out)


def parse_live_manuals(skill_names: dict[str, str]) -> dict[str, list[dict]]:
    manual_files = [
        MOD_DIR / "mod_wuxia/config/manuals.nut",
        MOD_DIR / "mod_wuxia/config/wx_m4_manuals.nut",
    ] + sorted((MOD_DIR / "mod_wuxia/config/manuals").glob("*.nut"))

    out = {}
    for mf in manual_files:
        src = mf.read_text(encoding="utf-8")
        hdrs = list(re.finditer(r"(?<![A-Za-z0-9_])(wx_manual_\w+)\s*(?:<-|=)\s*\{", src))
        for i, hm in enumerate(hdrs):
            st = hm.start()
            end = hdrs[i + 1].start() if i + 1 < len(hdrs) else len(src)
            body = src[st:end]
            mid = hm.group(1)
            gs_lists = re.findall(r"GrantSkills\s*=\s*\[([^\]]*)\]", body)
            sums = re.findall(r'Summary\s*=\s*"([^"]*)"', body)
            assert len(gs_lists) == 3 and len(sums) == 3, f"Unexpected level count on {mid}"
            tiers = []
            for ti in range(3):
                sk_ids = re.findall(r'"([^"]+)"', gs_lists[ti])
                sk_objs = [
                    {"id": sid, "name": skill_names.get(sid, VANILLA_SKILL_NAMES.get(sid, sid))}
                    for sid in sk_ids
                ]
                tiers.append({"skills": sk_objs, "summary": clean_bbcode(sums[ti])})
            out[mid] = tiers
    return out


def main():
    html = WIKI_PATH.read_text(encoding="utf-8")
    m_bundle = re.search(r'(<script[^>]*id="wx-bundle"[^>]*>)(.*?)(</script>)', html, re.S)
    assert m_bundle, "Could not find <script id='wx-bundle'> in 山海武侠.html"
    bundle = json.loads(m_bundle.group(2))
    icons: dict[str, str] = bundle["icons"]
    uri_to_icon_id: dict[str, str] = {v: k for k, v in icons.items()}
    max_idx = max(int(k[1:]) for k in icons.keys() if k.startswith("i") and k[1:].isdigit())

    def alloc_icon_uri(uri: str, existing_key: str | None = None) -> str:
        nonlocal max_idx
        if existing_key and existing_key in icons:
            icons[existing_key] = uri
            uri_to_icon_id[uri] = existing_key
            return existing_key
        if uri in uri_to_icon_id:
            return uri_to_icon_id[uri]
        max_idx += 1
        ik = f"i{max_idx}"
        icons[ik] = uri
        uri_to_icon_id[uri] = ik
        return ik

    # ==========================================================================
    # 1. READ ALL LIVE NUT CONFIGS
    # ==========================================================================
    beast_nut = (MOD_DIR / "mod_wuxia/config/wx_beast_craft.nut").read_text("utf-8")
    relic_nut = (MOD_DIR / "mod_wuxia/config/wx_relic_weapons.nut").read_text("utf-8")
    sh_nut = (MOD_DIR / "mod_wuxia/config/wx_shanhai.nut").read_text("utf-8")
    sh_exp_nut = (MOD_DIR / "mod_wuxia/config/wx_shanhai_expansion.nut").read_text("utf-8")
    sets_nut = (MOD_DIR / "mod_wuxia/config/wx_shanhai_sets.nut").read_text("utf-8")
    forge_nut = (MOD_DIR / "mod_wuxia/systems/wx_forge_system.nut").read_text("utf-8")
    bridge_nut = (MOD_DIR / "mod_wuxia/systems/wx_craft_combat_bridge.nut").read_text("utf-8")
    cons_nut = (MOD_DIR / "mod_wuxia/config/consumables.nut").read_text("utf-8")
    alch_nut = (MOD_DIR / "mod_wuxia/config/wx_alchemy.nut").read_text("utf-8")

    # Parse BossPartEssenceMap (64 bosses -> 12 wx_pmat_*)
    bp_hdr = bridge_nut.find("BossPartEssenceMap = {")
    bp_sec, _ = extract_balanced_block(bridge_nut, bridge_nut.find("{", bp_hdr))
    boss_part_map: dict[str, dict] = {}
    for bkey, bbody in parse_named_blocks(bp_sec).items():
        boss_part_map[bkey] = {
            "essenceId": get_str(bbody, "EssenceID"),
            "partLabel": get_str(bbody, "PartLabel"),
            "partKey": get_str(bbody, "PartKey"),
        }
    assert len(boss_part_map) == 64, f"Expected 64 BossPartEssenceMap entries, got {len(boss_part_map)}"

    # Parse BeastMaterials (6 wx_mat_* + 12 wx_pmat_*)
    bm_hdr = beast_nut.find("::Wuxia.Config.BeastMaterials <- {")
    bm_sec, _ = extract_balanced_block(beast_nut, beast_nut.find("{", bm_hdr))
    beast_mats = parse_named_blocks(bm_sec)
    assert len(beast_mats) == 18, f"Expected 18 BeastMaterials, got {len(beast_mats)}"

    # Parse GearTraits (all 111 traits: 12 beast + 37 relic + 62 shanhai)
    gt_hdr = beast_nut.find("::Wuxia.Config.GearTraits <- {")
    gt_sec, _ = extract_balanced_block(beast_nut, beast_nut.find("{", gt_hdr))
    gear_traits: dict[str, dict] = {}
    TIER_LABELS = {"beast": "百工兽魄", "relic": "名器器灵", "shanhai": "山海神通"}
    for tid, tbody in parse_named_blocks(gt_sec).items():
        raw_tier = get_str(tbody, "Tier", "shanhai")
        gear_traits[tid] = {
            "id": tid,
            "tier": TIER_LABELS.get(raw_tier, raw_tier),
            "title": get_str(tbody, "Title"),
            "text": clean_bbcode(get_str(tbody, "Text")),
        }

    # Parse Relic & ShanHai Trait Maps from wx_beast_craft.nut
    rtm_hdr = beast_nut.find("local relicTraitMap = {")
    rtm_sec, _ = extract_balanced_block(beast_nut, beast_nut.find("{", rtm_hdr))
    item_to_trait_id = dict(re.findall(r"(wx_\w+)\s*=\s*\"(\w+)\"", rtm_sec))

    gtm_hdr = beast_nut.find("local gearTraitMap = {")
    gtm_sec, _ = extract_balanced_block(beast_nut, beast_nut.find("{", gtm_hdr))
    item_to_trait_id.update(dict(re.findall(r"(wx_\w+)\s*=\s*\"(\w+)\"", gtm_sec)))

    # Parse BeastGear (12 wx_beast_* + 4 wx_up_*)
    bg_hdr = beast_nut.find("::Wuxia.Config.BeastGear <- {")
    bg_sec, _ = extract_balanced_block(beast_nut, beast_nut.find("{", bg_hdr))
    beast_gear_blocks = parse_named_blocks(bg_sec)
    for gid, gbody in beast_gear_blocks.items():
        tid = get_str(gbody, "TraitID")
        if tid:
            item_to_trait_id[gid] = tid

    # Parse WeaponAttachments (13 wx_wmod_*)
    wm_hdr = beast_nut.find("::Wuxia.Config.WeaponAttachments <- {")
    wm_sec, _ = extract_balanced_block(beast_nut, beast_nut.find("{", wm_hdr))
    wmod_blocks = parse_named_blocks(wm_sec)
    assert len(wmod_blocks) == 13, f"Expected 13 WeaponAttachments, got {len(wmod_blocks)}"

    # Parse BagGadgets (6 wx_gadget_*)
    gd_hdr = beast_nut.find("::Wuxia.Config.BagGadgets <- {")
    gd_sec, _ = extract_balanced_block(beast_nut, beast_nut.find("{", gd_hdr))
    gadget_blocks = parse_named_blocks(gd_sec)
    assert len(gadget_blocks) == 6, f"Expected 6 BagGadgets, got {len(gadget_blocks)}"

    # Parse TacticalConsumables (9 wx_tact_*)
    tc_hdr = beast_nut.find("::Wuxia.Config.TacticalConsumables <- {")
    tc_sec, _ = extract_balanced_block(beast_nut, beast_nut.find("{", tc_hdr))
    tact_blocks = parse_named_blocks(tc_sec)
    assert len(tact_blocks) == 9, f"Expected 9 TacticalConsumables, got {len(tact_blocks)}"

    # Parse CraftBlueprints
    cb_hdr = beast_nut.find("::Wuxia.Config.CraftBlueprints <- {")
    cb_sec, _ = extract_balanced_block(beast_nut, beast_nut.find("{", cb_hdr))
    craft_bp_blocks = parse_named_blocks(cb_sec)

    # Parse Herbs (49) & Pills (22 + 43 = 65)
    herbs_hdr = cons_nut.find("::Wuxia.Config.Herbs <- {")
    herbs_sec, _ = extract_balanced_block(cons_nut, cons_nut.find("{", herbs_hdr))
    herb_blocks = parse_named_blocks(herbs_sec)
    assert len(herb_blocks) == 49, f"Expected 49 Herbs, got {len(herb_blocks)}"

    pills_c_hdr = cons_nut.find("::Wuxia.Config.Pills <- {")
    pills_c_sec, _ = extract_balanced_block(cons_nut, cons_nut.find("{", pills_c_hdr))
    pill_blocks = parse_named_blocks(pills_c_sec)

    pills_a_hdr = alch_nut.find("local wxDeepPills = {")
    pills_a_sec, _ = extract_balanced_block(alch_nut, alch_nut.find("{", pills_a_hdr))
    pill_blocks.update(parse_named_blocks(pills_a_sec))
    assert len(pill_blocks) == 65, f"Expected 65 total Pills, got {len(pill_blocks)}"

    # Parse HerbNatures, KnownMaterials, AuxInfusions, FireModes, CoreImprints, Formulas from wx_alchemy.nut
    hn_hdr = alch_nut.find("HerbNatures = {")
    hn_sec, _ = extract_balanced_block(alch_nut, alch_nut.find("{", hn_hdr))
    herb_natures = {
        hid: {"nature": get_str(hb, "Nature", "vital"), "potency": get_int(hb, "Potency", 3)}
        for hid, hb in parse_named_blocks(hn_sec).items()
    }

    km_hdr = alch_nut.find("KnownMaterials = {")
    km_sec, _ = extract_balanced_block(alch_nut, alch_nut.find("{", km_hdr))
    pmat_natures: dict[str, dict] = {}
    for m_km in re.finditer(r'\["misc\.(wx_\w+)"\]\s*=\s*\{([^}]+)\}', km_sec):
        pmat_natures[m_km.group(1)] = {
            "nature": get_str(m_km.group(2), "Nature", "origin"),
            "potency": get_int(m_km.group(2), "Potency", 4),
        }

    aux_hdr = alch_nut.find("AuxInfusions = {")
    aux_sec, _ = extract_balanced_block(alch_nut, alch_nut.find("{", aux_hdr))
    aux_infusions = {}
    for aid, abody in parse_named_blocks(aux_sec).items():
        aux_infusions[aid] = {
            "ID": aid,
            "Title": get_str(abody, "Title"),
            "Color": get_str(abody, "Color"),
            "Bit": get_int(abody, "Bit"),
            "PrepDesc": clean_bbcode(get_str(abody, "PrepDesc")),
            "InfuseDesc": clean_bbcode(get_str(abody, "InfuseDesc")),
            "HealDesc": clean_bbcode(get_str(abody, "HealDesc")),
        }

    fm_hdr = alch_nut.find("FireModes = {")
    fm_sec, _ = extract_balanced_block(alch_nut, alch_nut.find("{", fm_hdr))
    fire_modes = {}
    for fid, fbody in parse_named_blocks(fm_sec).items():
        fire_modes[fid] = {
            "id": fid,
            "title": get_str(fbody, "Title"),
            "short": get_str(fbody, "Short"),
            "color": get_str(fbody, "Color"),
            "costMult": get_float(fbody, "CostMult", 1.0),
            "grade2Bonus": get_int(fbody, "Grade2Bonus", 0),
            "grade3Bonus": get_int(fbody, "Grade3Bonus", 0),
            "doubleBonus": get_int(fbody, "DoubleBonus", 0),
            "minPotencyFloor": get_int(fbody, "MinPotencyFloor", 92),
            "allowTribulation": get_bool(fbody, "AllowTribulation", False),
            "desc": clean_bbcode(get_str(fbody, "Desc")),
        }

    cim_hdr = alch_nut.find("CoreImprintModes = {")
    cim_sec, _ = extract_balanced_block(alch_nut, alch_nut.find("{", cim_hdr))
    core_imprint_modes = {
        mid: {
            "color": get_str(mbody, "Color", "#f0bc42"),
            "prepDesc": clean_bbcode(get_str(mbody, "PrepDesc")),
        }
        for mid, mbody in parse_named_blocks(cim_sec).items()
    }

    ci_hdr = alch_nut.find("CoreImprints = {")
    ci_sec, _ = extract_balanced_block(alch_nut, alch_nut.find("{", ci_hdr))
    core_imprints = {}
    for cid, cbody in parse_named_blocks(ci_sec).items():
        mode_k = get_str(cbody, "Mode")
        minfo = core_imprint_modes.get(mode_k, {"color": "#f0bc42", "prepDesc": ""})
        core_imprints[cid] = {
            "title": get_str(cbody, "Title"),
            "mode": mode_k,
            "color": minfo["color"],
            "prepDesc": minfo["prepDesc"],
        }
    assert len(core_imprints) == 96, f"Expected 96 CoreImprints, got {len(core_imprints)}"

    # Parse 65 Cauldron Formulas
    form_hdr = alch_nut.find("Formulas = [")
    form_end = alch_nut.rfind("]")
    form_raw = alch_nut[form_hdr:form_end]
    formulas_by_pill: dict[str, dict] = {}
    pos = 0
    while True:
        b_open = form_raw.find("{", pos)
        if b_open == -1:
            break
        fbody, next_pos = extract_balanced_block(form_raw, b_open)
        pos = next_pos
        fid = get_str(fbody, "ID")
        pid = get_str(fbody, "PillID")
        if not fid or not pid:
            continue
        req_core_raw = get_str(fbody, "RequiredCoreKey")
        req_core_id = req_core_raw.split(":", 1)[1] if req_core_raw.startswith("core:") else ""
        byp_id = get_str(fbody, "BonusByproduct")
        byp_name = get_str(pill_blocks.get(byp_id, ""), "Name") if byp_id else ""
        formulas_by_pill[pid] = {
            "id": fid,
            "category": get_str(fbody, "Category"),
            "baseYield": get_int(fbody, "BaseYield", 1),
            "junNatures": get_str_list(fbody, "JunNatures"),
            "minJunPotency": get_int(fbody, "MinJunPotency", 1),
            "requireRareJun": get_bool(fbody, "RequireRareJun", False),
            "minAuxCount": get_int(fbody, "MinAuxCount", 1),
            "targetPotency": get_int(fbody, "TargetPotency", 3),
            "silverCost": get_int(fbody, "SilverCost", 100),
            "byproduct": byp_name,
            "note": clean_bbcode(get_str(fbody, "FormulaNote")),
            "requiredCoreId": req_core_id,
            "isHiddenMutation": get_bool(fbody, "IsHiddenMutation", False),
        }
    assert len(formulas_by_pill) == 65, f"Expected 65 Formulas, got {len(formulas_by_pill)}"

    # Build Chinese ingredient resolver for CraftBlueprints
    existing_cores_by_id = {c["id"]: c for c in bundle["alchemy"]["cores"]}
    creature_by_id = {c["id"]: c for c in bundle["bestiary"]["creatures"]}

    # Reverse map: which bosses drop each wx_pmat_*
    pmat_boss_drops: dict[str, list[dict]] = {k: [] for k in beast_mats if k.startswith("wx_pmat_")}
    for bkey, pspec in boss_part_map.items():
        eid = pspec["essenceId"]
        cr_id = f"wx_boss_{bkey}"
        cr_obj = creature_by_id.get(cr_id, {})
        bname = cr_obj.get("shortName") or cr_obj.get("name") or bkey
        pmat_boss_drops[eid].append({
            "bossId": cr_id,
            "bossName": bname,
            "partLabel": pspec["partLabel"],
            "partKey": pspec["partKey"],
        })

    def resolve_ingredient_zh(script_path: str, num: int) -> tuple[str, str]:
        stem = Path(script_path).stem
        qty = f"×{num}"
        if stem in TROPHY_ITEM_ZH:
            nm, src_h = TROPHY_ITEM_ZH[stem]
            return f"【异兽奇材】{nm} {qty}", src_h
        if stem in beast_mats:
            mb = beast_mats[stem]
            nm = get_str(mb, "Name")
            if stem.startswith("wx_pmat_"):
                drops = pmat_boss_drops.get(stem, [])
                sample_bosses = "、".join(f"{d['bossName']}({d['partLabel']})" for d in drops[:4])
                if len(drops) > 4:
                    sample_bosses += f"等{len(drops)}尊大妖"
                return f"{nm} {qty}", f"讨伐 {sample_bosses} 时击破对应部位 100% 必掉（常规讨伐亦有 20% 概率剥得）"
            return f"【猎妖百工材】{nm} {qty}", "猎杀大地图荒泽异兽群或讨伐山海秘境首领伴生掉落"
        if stem in herb_blocks:
            nm = get_str(herb_blocks[stem], "Name")
            ch = get_str(herb_blocks[stem], "Chapter")
            return f"【山海本草】{nm} {qty}", f"《{ch}》道地奇草，可在 44 宗门「本门药庐」、山海秘境或采药奇遇中获取"
        if stem in existing_cores_by_id:
            nm = existing_cores_by_id[stem]["name"]
            return f"【山海内丹】{nm} {qty}", "讨伐对应《山海经》秘境大妖首领 100% 必掉"
        return f"{stem} {qty}", ""

    recipes_by_product_stem: dict[str, dict] = {}
    pmat_used_in: dict[str, list[dict]] = {k: [] for k in beast_mats if k.startswith("wx_pmat_")}

    for bpid, bpbody in craft_bp_blocks.items():
        prod_script = get_str(bpbody, "Product")
        prod_stem = Path(prod_script).stem
        cost = get_int(bpbody, "Cost", 500)
        ing_raw = re.findall(r'Script\s*=\s*"([^"]+)"\s*,\s*Num\s*=\s*(\d+)', bpbody)
        ing_labels = []
        src_notes = []
        raw_stems = []
        for sp, cnt_s in ing_raw:
            lbl, shint = resolve_ingredient_zh(sp, int(cnt_s))
            ing_labels.append(lbl)
            raw_stems.append(Path(sp).stem)
            if shint and shint not in src_notes:
                src_notes.append(shint)
        recipes_by_product_stem[prod_stem] = {
            "id": bpid,
            "cost": cost,
            "ingredients": ing_labels,
            "rawStems": raw_stems,
            "source": "；".join(src_notes),
        }

    # ==========================================================================
    # 2. SYNC `DB.equipment`, `DB.equipmentSets`, AND `DB.forgeMeta`
    # ==========================================================================
    # Remove any previously synced `part_material` / `weapon_mod` / `tactical_gadget` so re-runs are 100% idempotent
    base_equipment = [
        eq for eq in bundle["equipment"]
        if eq.get("group") not in ("part_material", "weapon_mod", "tactical_gadget")
    ]

    forged_gear_by_core: dict[str, list[dict]] = {}

    for eq in base_equipment:
        eid = eq["id"]
        # Attach live bespoke GearTrait!
        tid = item_to_trait_id.get(eid)
        if tid and tid in gear_traits:
            eq["trait"] = dict(gear_traits[tid])
        elif eid in beast_gear_blocks and get_str(beast_gear_blocks[eid], "Kind") == "upgrade":
            ub = beast_gear_blocks[eid]
            btxt = clean_bbcode(get_str(ub, "BonusText"))
            m_title = re.search(r"【([^】]+)】", btxt)
            eq["trait"] = {
                "id": eid,
                "tier": "百工镶缀",
                "title": m_title.group(1) if m_title else "甲胄奇门挂件",
                "text": btxt,
            }
            eq["desc"] = clean_bbcode(get_str(ub, "Description", eq["desc"]))

        # Update BeastGear & BeastMaterials descriptions from live nut
        if eid in beast_gear_blocks:
            eq["desc"] = clean_bbcode(get_str(beast_gear_blocks[eid], "Description", eq["desc"]))
        elif eid in beast_mats:
            mb = beast_mats[eid]
            nat_i = pmat_natures.get(eid, {"nature": "origin", "potency": 3})
            nat_zh = bundle["alchemy"]["natures"].get(nat_i["nature"], {}).get("Short", nat_i["nature"])
            eq["desc"] = clean_bbcode(get_str(mb, "Description", eq["desc"]))
            eq["statsText"] = f"百工锻造主材 · 药柜属性【{nat_zh} · 药力 {nat_i['potency']}】 · 自动归入百草药柜"

        # Enrich weapon statsText to mention Quench / Lock / Inlay
        if eq["group"] in ("relic_weapon", "shanhai_weapon"):
            eq["statsText"] = f"估值 {eq['value']} 两起 · 四阶品相 · 支持五引淬火塑形、百炼锁词与镶缀兵刃铭文"

        # Refresh recipe if in CraftBlueprints
        if eid in recipes_by_product_stem:
            r = recipes_by_product_stem[eid]
            eq["recipe"] = {
                "cost": r["cost"],
                "ingredients": r["ingredients"],
                "source": r["source"],
            }

        # Track core -> forged Shan-Hai gear cross-links
        if eq.get("recipe"):
            for ing_s in eq["recipe"].get("ingredients", []):
                for cid, cobj in existing_cores_by_id.items():
                    if cobj["name"] in ing_s:
                        forged_gear_by_core.setdefault(cid, []).append({"id": eid, "name": eq["name"], "group": eq["group"]})

    # Tints to visually distinguish the 12 part-break essences & 13 weapon attachments cleanly
    PMAT_TINTS = {
        "wx_pmat_longni":       (110, 195, 255),
        "wx_pmat_jiushou":      (155, 235, 95),
        "wx_pmat_xuanjia":      (215, 185, 120),
        "wx_pmat_jinwu_yu":     (255, 155, 70),
        "wx_pmat_fengyi":       (130, 240, 200),
        "wx_pmat_bingzhu_jiao": (235, 110, 95),
        "wx_pmat_leigu":        (195, 145, 255),
        "wx_pmat_baize_tong":   (210, 175, 255),
        "wx_pmat_qinyuan_zhen": (120, 225, 130),
        "wx_pmat_taotie_chi":   (240, 120, 120),
        "wx_pmat_xingtian_sui": (255, 135, 105),
        "wx_pmat_jianmu_zhi":   (115, 230, 145),
    }

    # Add 12 Part-Break Essences (`wx_pmat_*`, group: `part_material`)
    new_pmat_entries = []
    for pid, mbody in beast_mats.items():
        if not pid.startswith("wx_pmat_"):
            continue
        nm = get_str(mbody, "Name")
        val = get_int(mbody, "Value", 900)
        icon_rel = get_str(mbody, "Icon")
        desc = clean_bbcode(get_str(mbody, "Description"))
        nat_i = pmat_natures.get(pid, {"nature": "origin", "potency": 4})
        nat_zh = bundle["alchemy"]["natures"].get(nat_i["nature"], {}).get("Short", nat_i["nature"])
        ik = alloc_icon_uri(encode_item_webp_48(resolve_gfx_png(icon_rel), PMAT_TINTS.get(pid)))
        drops = pmat_boss_drops.get(pid, [])
        new_pmat_entries.append({
            "id": pid,
            "name": nm,
            "group": "part_material",
            "family": "material",
            "value": val,
            "statsText": f"破部怨念奇材 · 药性【{nat_zh} · 药力 {nat_i['potency']}】 · 对应 {len(drops)} 尊大妖破部位 100% 必掉",
            "trait": {
                "id": pid,
                "tier": "破部取粹",
                "title": f"关联 {len(drops)} 尊大妖部位破坏",
                "text": "可捕获对象：" + "、".join(f"{d['bossName']}【{d['partLabel']}】" for d in drops),
            },
            "recipe": None,
            "desc": desc,
            "partDrops": drops,
            "usedIn": [],  # populated below
            "icon": ik,
        })

    # Add 13 Mainhand Weapon Attachments (`wx_wmod_*`, group: `weapon_mod`)
    WMOD_SKILL_ICON_MAP = {
        "wx_wmod_sword_tassel":  "skills/wx_sword_combo.png",
        "wx_wmod_saber_guard":   "skills/wx_saber_xinyue.png",
        "wx_wmod_cleaver_ring":  "skills/wx_saber_chiyou.png",
        "wx_wmod_spear_tassel":  "skills/wx_spear_thrust2.png",
        "wx_wmod_polearm_hook":  "skills/wx_pole_goulian.png",
        "wx_wmod_staff_ferrule": "skills/wx_staff_weituo.png",
        "wx_wmod_fist_cuff":     "skills/wx_fist_shock.png",
        "wx_wmod_hammer_stud":   "skills/wx_hammer_quake.png",
        "wx_wmod_axe_wedge":     "skills/wx_axe_kaitian.png",
        "wx_wmod_flail_ring":    "skills/wx_flail_liuxing.png",
        "wx_wmod_dagger_groove": "skills/wx_dagger_execute.png",
        "wx_wmod_bow_string":    "skills/wx_bow_luori.png",
        "wx_wmod_mech_spring":   "skills/wx_crossbow_liannu.png",
    }
    new_wmod_entries = []
    for wid, wbody in wmod_blocks.items():
        nm = get_str(wbody, "Name")
        fam = get_str(wbody, "Family")
        fams = get_str_list(wbody, "Families") or [fam]
        fam_lbl = get_str(wbody, "FamilyLabel")
        val = get_int(wbody, "Value", 1400)
        btxt = clean_bbcode(get_str(wbody, "BonusText"))
        desc = clean_bbcode(get_str(wbody, "Description"))
        sk_icon_rel = WMOD_SKILL_ICON_MAP.get(wid, get_str(wbody, "Icon"))
        ik = alloc_icon_uri(encode_skill_webp_48(resolve_gfx_png(sk_icon_rel)))
        rec_raw = recipes_by_product_stem.get(wid)
        rec_obj = {"cost": rec_raw["cost"], "ingredients": rec_raw["ingredients"], "source": rec_raw["source"]} if rec_raw else None
        if rec_raw:
            for st in rec_raw["rawStems"]:
                if st in pmat_used_in:
                    pmat_used_in[st].append({"kind": "equip", "id": wid, "name": nm, "tag": "兵刃铭配"})
        new_wmod_entries.append({
            "id": wid,
            "name": nm,
            "group": "weapon_mod",
            "family": fam,
            "families": fams,
            "value": val,
            "statsText": f"适配：{fam_lbl} · 行囊右键无损镶缀（替换旧铭配自动退回行囊）",
            "trait": {
                "id": wid,
                "tier": "器魂铭文",
                "title": fam_lbl,
                "text": btxt,
            },
            "recipe": rec_obj,
            "desc": desc,
            "icon": ik,
        })

    # Add 6 Belt Tactical Gadgets (`wx_gadget_*`, group: `tactical_gadget`)
    new_gadget_entries = []
    for gid, gbody in gadget_blocks.items():
        nm = get_str(gbody, "Name")
        val = get_int(gbody, "Value", 1600)
        ap = get_int(gbody, "APCost", 3)
        qi = get_int(gbody, "QiCost", 10)
        min_r = get_int(gbody, "MinRange", 1)
        max_r = get_int(gbody, "MaxRange", 3)
        chg = get_int(gbody, "MaxCharges", 2)
        sk_icon_rel = get_str(gbody, "SkillIcon") or get_str(gbody, "Icon")
        ik = alloc_icon_uri(encode_skill_webp_48(resolve_gfx_png(sk_icon_rel)))
        desc = clean_bbcode(get_str(gbody, "Description"))
        rec_raw = recipes_by_product_stem.get(gid)
        rec_obj = {"cost": rec_raw["cost"], "ingredients": rec_raw["ingredients"], "source": rec_raw["source"]} if rec_raw else None
        if rec_raw:
            for st in rec_raw["rawStems"]:
                if st in pmat_used_in:
                    pmat_used_in[st].append({"kind": "equip", "id": gid, "name": nm, "tag": "奇门器械"})
        new_gadget_entries.append({
            "id": gid,
            "name": nm,
            "group": "tactical_gadget",
            "family": "Throwing",
            "value": val,
            "statsText": f"腰包战术器械 · {ap} AP / {qi} 内息 · 射程 {min_r}~{max_r} 格 · 单场 {chg} 发（战后自动补满 · 统一收敛于底栏「奇门机括」）",
            "trait": {
                "id": gid,
                "tier": "百工奇门",
                "title": f"{ap}AP · 单场{chg}发自补",
                "text": desc.split("：", 1)[1] if "：" in desc else desc,
            },
            "recipe": rec_obj,
            "desc": desc,
            "icon": ik,
        })

    # ==========================================================================
    # 3. SYNC `DB.alchemy` (65 Pills, 49 Herbs, 96 CoreImprints, 9 Tactical Powders/Coatings, 3 FireModes)
    # ==========================================================================
    # 3a. 9 Mid-Battle Tactical Powders & Multi-Sect Blade Coatings (`wx_tact_*`)
    SUBMODE_LABELS = {
        "tile":    "外抛改地散 · 零丹毒",
        "oral":    "战中内服散 · 计入丹毒",
        "coating": "门派涂刃膏 · 零丹毒",
        "thrown":  "丹劫火毒散 · 零丹毒",
    }
    tactical_items = []
    for tid, tbody in tact_blocks.items():
        nm = get_str(tbody, "Name")
        subm = get_str(tbody, "SubMode", "tile")
        val = get_int(tbody, "Value", 700)
        ap = get_int(tbody, "APCost", 2)
        qi = get_int(tbody, "QiCost", 0)
        min_r = get_int(tbody, "MinRange", 0)
        max_r = get_int(tbody, "MaxRange", 0)
        chg = get_int(tbody, "MaxCharges", 2)
        icon_rel = get_str(tbody, "Icon")
        ik = alloc_icon_uri(encode_item_webp_48(resolve_gfx_png(icon_rel)))
        desc = clean_bbcode(get_str(tbody, "Description"))
        rec_raw = recipes_by_product_stem.get(tid)
        if rec_raw:
            rec_obj = {"cost": rec_raw["cost"], "ingredients": rec_raw["ingredients"], "source": rec_raw["source"]}
            for st in rec_raw["rawStems"]:
                if st in pmat_used_in:
                    pmat_used_in[st].append({"kind": "tact", "id": tid, "name": nm, "tag": "战中奇散/秘膏"})
        else:
            rec_obj = {
                "cost": 0,
                "ingredients": ["八卦丹炉【武火催霞】遭遇六脉相克且无大妖内丹镇鼎时丹劫异变凝成"],
                "source": "随身八卦丹炉选择【武火催霞】炼药触发丹劫异变获得",
            }
        tactical_items.append({
            "id": tid,
            "name": nm,
            "subMode": subm,
            "subModeLabel": SUBMODE_LABELS.get(subm, subm),
            "ap": ap,
            "qi": qi,
            "minRange": min_r,
            "maxRange": max_r,
            "charges": chg,
            "countsDanToxin": (subm == "oral"),
            "value": val,
            "desc": desc,
            "recipe": rec_obj,
            "icon": ik,
        })

    # Attach `usedIn` onto `new_pmat_entries`
    for pm in new_pmat_entries:
        pm["usedIn"] = pmat_used_in.get(pm["id"], [])

    bundle["equipment"] = base_equipment + new_wmod_entries + new_gadget_entries + new_pmat_entries
    assert len(bundle["equipment"]) == 152, f"Expected 152 equipment entries, got {len(bundle['equipment'])}"

    # Re-sync `DB.equipmentSets` (`8` sets + `11` totem pairs) onto `bundle["equipment"]`
    eq_by_id = {eq["id"]: eq for eq in bundle["equipment"]}
    for eq in bundle["equipment"]:
        eq.pop("setInfo", None)
        eq.pop("totemInfo", None)

    set_order = re.findall(r'"(wx_set_\w+)"', re.search(r"ShanHaiSetOrder\s*<-\s*\[(.*?)\]", sets_nut, re.S).group(1))
    totem_order = re.findall(r'"(\w+)"', re.search(r"ShanHaiTotemOrder\s*<-\s*\[(.*?)\]", sets_nut, re.S).group(1))
    sets_sec, _ = extract_balanced_block(sets_nut, sets_nut.find("{", sets_nut.find("ShanHaiSets <- {")))
    totem_sec, _ = extract_balanced_block(sets_nut, sets_nut.find("{", sets_nut.find("ShanHaiTotemPairs <- {")))
    parsed_sets = parse_named_blocks(sets_sec)
    parsed_totems = parse_named_blocks(totem_sec)

    totem_by_piece = {}
    totem_objs = {}
    for tid in totem_order:
        tb = parsed_totems[tid]
        pids = get_str_list(tb, "Pieces")
        t_obj = {
            "id": tid,
            "title": get_str(tb, "Title"),
            "need": get_int(tb, "Need", 2),
            "pieceIds": pids,
            "pieceNames": [eq_by_id[p]["name"] for p in pids if p in eq_by_id],
            "text": clean_bbcode(get_str(tb, "Text")),
        }
        totem_objs[tid] = t_obj
        for p in pids:
            totem_by_piece[p] = {"id": tid, "title": t_obj["title"], "text": t_obj["text"]}

    out_sets = []
    for sid in set_order:
        sb = parsed_sets[sid]
        icon_rel = get_str(sb, "Icon")
        ik = alloc_icon_uri(encode_skill_webp_48(MOD_DIR / "gfx" / icon_rel))
        pids = get_str_list(sb, "Pieces")
        bonuses = [
            {"need": int(bm.group(1)), "title": bm.group(2), "text": clean_bbcode(bm.group(3))}
            for bm in re.finditer(r'Need\s*=\s*(\d+)\s*,\s*Title\s*=\s*"([^"]+)"\s*,\s*Text\s*=\s*"([^"]+)"', sb)
        ]
        piece_objs = []
        set_tids = []
        for p in pids:
            eq = eq_by_id[p]
            eq["setInfo"] = {"id": sid, "name": get_str(sb, "Name"), "shortName": get_str(sb, "ShortName")}
            if p in totem_by_piece:
                eq["totemInfo"] = totem_by_piece[p]
                if totem_by_piece[p]["id"] not in set_tids:
                    set_tids.append(totem_by_piece[p]["id"])
            piece_objs.append({"id": p, "name": eq["name"], "group": eq["group"]})
        out_sets.append({
            "id": sid,
            "name": get_str(sb, "Name"),
            "shortName": get_str(sb, "ShortName"),
            "tier": get_str(sb, "Tier"),
            "styleTag": get_str(sb, "StyleTag"),
            "color": get_str(sb, "Color"),
            "icon": ik,
            "lore": clean_bbcode(get_str(sb, "Lore")),
            "bonuses": bonuses,
            "pieces": piece_objs,
            "totems": [
                {"id": tid, "title": totem_objs[tid]["title"], "text": totem_objs[tid]["text"], "pieceNames": totem_objs[tid]["pieceNames"]}
                for tid in set_tids
            ],
        })
    bundle["equipmentSets"] = out_sets

    # Build `DB.forgeMeta` (Quench Catalysts & Stat-Lock Reforging)
    qc_hdr = forge_nut.find("QuenchCatalysts = {")
    qc_sec, _ = extract_balanced_block(forge_nut, forge_nut.find("{", qc_hdr))
    quench_list = []
    for qid, qbody in parse_named_blocks(qc_sec).items():
        quench_list.append({
            "id": qid,
            "name": get_str(qbody, "Name"),
            "short": get_str(qbody, "Short"),
            "color": get_str(qbody, "Color"),
            "affixTitle": get_str(qbody, "AffixTitle"),
            "affixDesc": clean_bbcode(get_str(qbody, "AffixDesc")),
        })
    bundle["forgeMeta"] = {
        "quenchCatalysts": quench_list,
        "lockRules": [
            {"mode": "不锁词重铸", "cost": "常规百工材 ×1 + 工具 ×2 + 基础重锻银", "desc": "重摇全部主次词条，累计五锤炉温保底（满 5 锤必出百炼/神工）"},
            {"mode": "锁定主词条 (F1)", "cost": "额外消耗【破部精粹奇材 ×1】+ 工钱 ×1.5", "desc": "锁死当前武器基伤 / 甲盾主耐久上限百分比，仅重铸次要破甲与轻量化负重"},
            {"mode": "锁定辅词条 (F2)", "cost": "额外消耗【破部精粹奇材 ×1】+ 工钱 ×1.5", "desc": "锁死当前破甲率 / 轻量化减重或双防词条百分比，仅重铸第一主词条"},
        ],
    }

    # 3b. Sync all 65 Spirit Pills (`DB.alchemy.pills`)
    existing_pill_icons = {p["id"]: p.get("icon") for p in bundle["alchemy"]["pills"]}
    signature_pill_by_core: dict[str, dict] = {}
    synced_pills = []
    for pid, pbody in pill_blocks.items():
        nm = get_str(pbody, "Name")
        sub_lbl = get_str(pbody, "SubLabel")
        qual = get_str(pbody, "Quality", "sect")
        kind = get_str(pbody, "Kind", "buff")
        val = get_int(pbody, "Value", 500)
        exp_amt = get_int(pbody, "ExpAmount", 0)
        desc = clean_bbcode(get_str(pbody, "Description"))
        icon_rel = get_str(pbody, "Icon")
        ik = alloc_icon_uri(encode_item_webp_48(resolve_gfx_png(icon_rel)), existing_pill_icons.get(pid))
        fm = formulas_by_pill.get(pid)
        if fm and fm.get("requiredCoreId"):
            cid = fm["requiredCoreId"]
            cname = existing_cores_by_id.get(cid, {}).get("name", cid)
            fm["requiredCoreName"] = cname
            signature_pill_by_core[cid] = {"id": pid, "name": nm}
        synced_pills.append({
            "id": pid,
            "name": nm,
            "subLabel": sub_lbl,
            "quality": qual,
            "kind": kind,
            "value": val,
            "expAmount": exp_amt,
            "desc": desc,
            "formula": fm,
            "icon": ik,
        })

    # 3c. Sync all 49《山海本草》Spirit Herbs (`DB.alchemy.herbs`)
    existing_herb_icons = {h["id"]: h.get("icon") for h in bundle["alchemy"]["herbs"]}
    synced_herbs = []
    for hid, hbody in herb_blocks.items():
        nm = get_str(hbody, "Name")
        chap = get_str(hbody, "Chapter", "山海本草")
        sub_lbl = get_str(hbody, "SubLabel")
        qual = get_str(hbody, "Quality", "sect")
        val = get_int(hbody, "Value", 500)
        exp_amt = get_int(hbody, "ExpAmount", 0)
        desc = clean_bbcode(get_str(hbody, "Description"))
        icon_rel = get_str(hbody, "Icon")
        ik = alloc_icon_uri(encode_item_webp_48(resolve_gfx_png(icon_rel)), existing_herb_icons.get(hid))
        hn = herb_natures.get(hid, {"nature": "vital", "potency": 3})
        synced_herbs.append({
            "id": hid,
            "name": nm,
            "chapter": chap,
            "subLabel": sub_lbl,
            "quality": qual,
            "nature": hn["nature"],
            "potency": hn["potency"],
            "value": val,
            "expAmount": exp_amt,
            "desc": desc,
            "icon": ik,
        })
    assert len(synced_herbs) == 49, f"Expected 49 synced herbs, got {len(synced_herbs)}"

    # 3d. Enrich all 96 `DB.alchemy.cores` with `imprint`, `signaturePill`, and `forgedGear`
    for cobj in bundle["alchemy"]["cores"]:
        cid = cobj["id"]
        cobj["imprint"] = core_imprints.get(cid)
        cobj["signaturePill"] = signature_pill_by_core.get(cid)
        cobj["forgedGear"] = forged_gear_by_core.get(cid, [])

    bundle["alchemy"]["auxInfusions"] = aux_infusions
    bundle["alchemy"]["fireModes"] = fire_modes
    bundle["alchemy"]["pills"] = synced_pills
    bundle["alchemy"]["herbs"] = synced_herbs
    bundle["alchemy"]["tacticalItems"] = tactical_items

    # ==========================================================================
    # 4. SYNC `DB.skills` (173), `DB.manuals` (276), AND `DB.statuses` (16)
    # ==========================================================================
    # Update live descriptions/AP/Qi/ComboForms on all existing skills
    for sk in bundle["skills"]:
        p = MOD_DIR / "scripts/skills/actives" / f"{sk['key']}.nut"
        if not p.exists():
            continue
        s_src = p.read_text("utf-8")
        nm_m = re.search(r'this\.m\.Name\s*=\s*"([^"]+)"', s_src)
        ds_m = re.search(r'this\.m\.Description\s*=\s*"([^"]+)"', s_src)
        ap_m = re.search(r"this\.m\.ActionPointCost\s*=\s*(\d+)", s_src)
        qi_m = re.search(r"this\.m\.FatigueCost\s*=\s*(\d+)", s_src)
        if nm_m:
            sk["name"] = clean_bbcode(nm_m.group(1))
        if ds_m:
            sk["desc"] = clean_bbcode(ds_m.group(1))
        if ap_m:
            sk["ap"] = int(ap_m.group(1))
        if qi_m:
            sk["qi"] = int(qi_m.group(1))
        # Parse WX_ComboForms if present!
        if "this.m.WX_ComboForms = [" in s_src:
            cf_start = s_src.find("this.m.WX_ComboForms = [")
            cf_end = s_src.find("];", cf_start)
            if cf_end != -1:
                cf_raw = s_src[cf_start:cf_end]
                forms = [
                    clean_bbcode(fm.group(1))
                    for fm in re.finditer(r'Name\s*=\s*"([^"]+)"', cf_raw)
                ]
                if forms:
                    sk["comboForms"] = forms

    # Ensure the 2 HUD-converged belt skills (`wx_item_bag_gadget`, `wx_item_tactical_powder`) are in `DB.skills`
    extra_hud_skills = [
        (
            "wx_item_bag_gadget",
            "奇门机括",
            "百工奇门腰包收敛技（无论随身携带多少件断龙钉/铁蒺藜/震天雷/墨斗网等奇门器械，底栏永远只占 1 格技能位，严守 6~9 技能上限）：催动当前选定的腰包奇门器械破除大妖妖障、打断天灾蓄势或封锁走位。",
            3, 10, 1, 4, ["Throwing"], "skills/wx_throw_duzhen.png",
            {"label": "墨门机括 · 破障断龙", "anim": "wx_anim_54", "mode": "bomb_arc", "vfx": "wx_vfx_19", "sig": "wx_fx_thunder_bolt", "volleys": 1, "shake": 6, "fam": "throw", "color": "#f0bc42"},
        ),
        (
            "wx_item_tactical_powder",
            "奇药涂散",
            "丹鼎腰包灵散与涂刃收敛技（无论携带多少份改地散/救急破穴散/门派涂刃秘膏，底栏统一收敛为单格技能）：战中耗 2 AP 瞬间净化周身天灾地脉、冲解点穴震慑，或为兵刃涂抹断续蚀壳/纯阳朱砂/子母引蛊秘膏。",
            2, 4, 0, 3, [], "skills/wx_smoke_cast.png",
            {"label": "灵散辟秽 · 秘膏淬锋", "anim": "wx_anim_70", "mode": "smoke_screen", "vfx": "wx_vfx_25", "sig": "wx_fx_lotus_seal", "volleys": 1, "shake": 4, "fam": "fist", "color": "#5ec47a"},
        ),
    ]
    sk_by_id = {sk["id"]: sk for sk in bundle["skills"]}
    for key, nm, desc, ap, qi, min_r, max_r, wpns, ic_rel, choreo in extra_hud_skills:
        fid = f"actives.{key}"
        prev_ic = sk_by_id.get(fid, {}).get("icon")
        ik = alloc_icon_uri(encode_skill_webp_48(resolve_gfx_png(ic_rel)), prev_ic)
        sk_obj = {
            "id": fid,
            "key": key,
            "name": nm,
            "desc": desc,
            "ap": ap,
            "qi": qi,
            "minRange": min_r,
            "maxRange": max_r,
            "directMult": None,
            "cooldown": 0,
            "weapons": wpns,
            "icon": ik,
            "manuals": [],
            "choreo": choreo,
        }
        if fid in sk_by_id:
            idx = bundle["skills"].index(sk_by_id[fid])
            bundle["skills"][idx] = sk_obj
        else:
            bundle["skills"].append(sk_obj)
        sk_by_id[fid] = sk_obj

    # Rebuild manual -> skill & skill -> manuals cross-links across all 276 manuals
    all_sk_names = {sk["id"]: sk["name"] for sk in bundle["skills"]}
    for sk in bundle["skills"]:
        sk["manuals"] = []
    live_manuals = parse_live_manuals(all_sk_names)
    for man in bundle["manuals"]:
        mid = man["id"]
        if mid not in live_manuals:
            continue
        tiers = live_manuals[mid]
        first_unlock: dict[str, int] = {}
        for ti in range(3):
            man["levels"][ti]["skills"] = tiers[ti]["skills"]
            man["levels"][ti]["summary"] = tiers[ti]["summary"]
            for s_entry in tiers[ti]["skills"]:
                sid = s_entry["id"]
                if sid.startswith("actives.wx_") and sid not in first_unlock:
                    first_unlock[sid] = ti + 1
        for sid, ut in first_unlock.items():
            if sid in sk_by_id:
                sk_by_id[sid]["manuals"].append({"id": mid, "name": man["name"], "tier": ut})

    # Sync 16 Combat & Cultivation Statuses (`DB.statuses`)
    st_by_id = {st["id"]: st for st in bundle["statuses"]}
    if "effects.wx_pill_battle_buff" in st_by_id:
        st_by_id["effects.wx_pill_battle_buff"]["name"] = "丹药行气 · 丹武催化"
        st_by_id["effects.wx_pill_battle_buff"]["desc"] = "战前备战灵丹或战中救急内服散药力在奇经八脉间奔涌，催化内外轻横四脉武学并激发药引丹韵与本命妖丹神韵。"
        st_by_id["effects.wx_pill_battle_buff"]["effects"] = [
            "单场战斗人体安全承受 2 份内服丹散（战前备战丹与战中内服散共享阈值）；强服第 3 份引发「丹毒郁结」（内息上限 -15、回气 -3），第 4 份彻底封锁",
            "外抛改地散（如玄霜散/破妄香）与门派兵刃涂膏走外用通道，不计入体内丹毒阈值",
            "八卦丹炉臣佐药可赋予六脉【四脉武学催化丹韵】，96 枚山海内丹作君药更可烙印独门【本命妖丹丹韵】",
        ]

    new_statuses = [
        (
            "effects.wx_status_regen_seal",
            "断续封生",
            "《钦原断续蚀壳膏》或《五毒腐骨瘴气瓮》侵入骨髓的奇毒禁制：彻底锁死受创者当前气血上限水位，截断山海大妖每回合初气血自愈与濒死复生！",
            [
                "持续期间（默认 2 回合），目标在回合开始时一切活血自愈（如朱厌沸血、建木生生、相柳生肌首、猰貐贰负复生）全部归零失效",
                "专克高回血山海秘境首领，配合重锤或蚀壳膏更可同步剥裂大妖【太古玄壳】",
            ],
            "skills/wx_status_poison_dart.png",
        ),
        (
            "effects.wx_status_blade_coating",
            "兵刃淬膏",
            "战中耗 2 AP 为主手兵刃涂抹五毒、血刀、天师道或钦原秘膏（默认维持 4 次有效命中，短匕镶《幽冥藏毒深血槽》延长至 6 击）。",
            [
                "支持《钦原断续蚀壳膏》（封再生+破玄壳）、《化血透骨寸劲膏》（引爆流血内伤真伤）、《纯阳朱砂雷火油》（焚甲+重创尸傀封复生）、《子母连环引蛊脂》（亡语跃迁传蛊）",
                "新涂秘膏直接覆盖旧涂层，不额外占用体内丹毒额度",
            ],
            "skills/wx_gun_leihuo.png",
        ),
        (
            "effects.wx_status_hidden_force",
            "寸劲伏脉",
            "少室与内家拳掌打入奇经八脉的潜伏暗劲（1~3 重）：初看皮肉无伤，每层压制目标内息恢复 -2；叠满 3 重瞬间在五脏内轰然引爆！",
            [
                "叠满第 3 重（或被刚猛催劲招式引爆）时，当场造成 28 点无视护甲的脏腑爆裂实伤，并附加【内伤】与 -12 定力动摇检定",
                "配合《昆仑寒玉寸劲箍》或陆吾护手可极速叠层破除重甲铁罐头",
            ],
            "skills/wx_fist_shock.png",
        ),
        (
            "effects.wx_stream_combo_state",
            "武道气机流转",
            "门派真传同槽连段与流派势能中枢：在不突破底栏 6~9 技能上限的前提下，驱动同槽招式随实战节奏「起 → 承 → 转合」动态变招。",
            [
                "统御连段升阶、潜龙叠浪、轻功乘风势、居合纳刀藏锋、血海刀煞（至多15%护体，受60%上限约束）、铁枪拒马（+6近防）、疯魔劲与金蟾蓄劲",
                "与传世名器器灵及 13 类兵刃铭配深度共鸣，打出流派专属节奏",
            ],
            "skills/wx_sword_combo.png",
        ),
    ]
    for sid, nm, desc, effs, ic_rel in new_statuses:
        prev_ic = st_by_id.get(sid, {}).get("icon")
        ik = alloc_icon_uri(encode_skill_webp_48(resolve_gfx_png(ic_rel)), prev_ic)
        st_obj = {"id": sid, "name": nm, "desc": desc, "effects": effs, "icon": ik}
        if sid in st_by_id:
            idx = bundle["statuses"].index(st_by_id[sid])
            bundle["statuses"][idx] = st_obj
        else:
            bundle["statuses"].append(st_obj)
        st_by_id[sid] = st_obj

    # ==========================================================================
    # 5. SYNC ALL 64 SHAN-HAI MULTI-PART / BESPOKE BOSSES IN `DB.bestiary.creatures`
    # ==========================================================================
    cat_s12 = (MOD_DIR / "mod_wuxia/systems/wx_shanhai_boss_catalog_s1_s2.nut").read_text("utf-8")
    cat_s345 = (MOD_DIR / "mod_wuxia/systems/wx_shanhai_boss_catalog_s3_s4_s5.nut").read_text("utf-8")
    cat_all = cat_s12 + "\n" + cat_s345

    boss_specs: dict[str, dict] = {}
    boss_moves: dict[str, dict] = {}
    boss_move_lists: dict[str, list[str]] = {}

    for m_sp in re.finditer(r"::Wuxia\.ShanHaiBossSpecs\.(\w+)\s*<-\s*\{", cat_all):
        bkey = m_sp.group(1)
        sbody, _ = extract_balanced_block(cat_all, cat_all.find("{", m_sp.end() - 1))
        parts = []
        if "Parts = [" in sbody:
            p_start = sbody.find("Parts = [")
            p_end = sbody.find("]", p_start)
            p_raw = sbody[p_start:p_end]
            for pm in re.finditer(r"\{([^}]+)\}", p_raw):
                pb = pm.group(1)
                parts.append({
                    "key": get_str(pb, "Key"),
                    "name": get_str(pb, "Name"),
                    "hp": get_int(pb, "HP", 0) or get_int(pb, "Hitpoints", 0),
                    "bodyArmor": get_int(pb, "BodyArmor", 0),
                    "lockedSkill": get_str(pb, "LockedSkillID"),
                })
        boss_specs[bkey] = {
            "traitName": get_str(sbody, "TraitName"),
            "canonQuote": clean_bbcode(get_str(sbody, "CanonQuote")),
            "traitDesc": clean_bbcode(get_str(sbody, "TraitDesc")),
            "counterHint": clean_bbcode(get_str(sbody, "CounterHint")),
            "structureMode": get_str(sbody, "StructureMode", "colossus"),
            "parts": parts,
        }

    for m_mv in re.finditer(r"::Wuxia\.ShanHaiBossMoves\.(\w+)\s*<-\s*\{", cat_all):
        mkey = m_mv.group(1)
        mbody, _ = extract_balanced_block(cat_all, cat_all.find("{", m_mv.end() - 1))
        boss_moves[mkey] = {
            "key": mkey,
            "name": get_str(mbody, "Name"),
            "desc": clean_bbcode(get_str(mbody, "Desc")),
            "geo": get_str(mbody, "Geo", "single"),
            "ap": get_int(mbody, "AP", 5),
            "qi": get_int(mbody, "Qi", 18),
            "cd": get_int(mbody, "CD", 2),
            "dmgMult": get_float(mbody, "Dmg", 1.15),
            "penAdd": get_float(mbody, "Pen", 0.08),
            "armMult": get_float(mbody, "Arm", 1.15),
            "vfx": get_str(mbody, "Vfx", "wx_vfx_05"),
        }

    for m_bs in re.finditer(r"::Wuxia\.ShanHai\.BespokeBossSpecs\.boss_(\w+)\s*<-\s*\{", cat_all):
        bkey = m_bs.group(1)
        bbody, _ = extract_balanced_block(cat_all, cat_all.find("{", m_bs.end() - 1))
        sk_paths = get_str_list(bbody, "Skills")
        boss_move_lists[bkey] = [Path(sp).stem for sp in sk_paths]

    # Add the 3 Flagship Prototype Multi-Tile Bosses (`zhuyin`, `xiangliuwang`, `nvchou`)
    boss_specs["zhuyin"] = {
        "traitName": "视为昼瞑为夜·千里真龙躯",
        "canonQuote": "《海外北经》：“钟山之神，名曰烛阴，视为昼，瞑为夜，吹为冬，呼为夏，不饮，不食，不息，息为风，身长千里。”",
        "traitDesc": "三格蜿蜒真龙躯（神首·赤鳞龙躯·盘山龙尾）：单数轮【视为昼】正面神瞳灼目（正面攻首命中-8）；双数轮【瞑为夜】阖目敛息蓄太古朔风（露七寸破绽，点穴/纯阳重击满3点破招可震断朔风）；碎赤鳞龙躯永久废除盘山绞，碎龙尾大削近防！",
        "counterHint": "重兵先碎【赤鳞龙躯/盘山龙尾】破盘绞；切忌踩玄冥冻土硬接夏炎吐息（触发寒暑蒸汽爆）；趁偶轮阖目以点穴/纯阳/断龙钉截断朔风！",
        "structureMode": "segments",
        "parts": [
            {"key": "body_seg", "name": "烛九阴·赤鳞龙躯", "hp": 0, "bodyArmor": 260, "lockedSkill": "actives.wx_boss_zhuyin_coil_crush"},
            {"key": "tail_seg", "name": "烛九阴·盘山龙尾", "hp": 0, "bodyArmor": 210, "lockedSkill": ""},
        ],
    }
    boss_move_lists["zhuyin"] = [
        "wx_boss_zhuyin_winter_breath",
        "wx_boss_zhuyin_summer_gale",
        "wx_boss_zhuyin_coil_crush",
        "wx_boss_zhuyin_primordial_wind",
    ]
    boss_moves.update({
        "wx_boss_zhuyin_winter_breath": {"key": "wx_boss_zhuyin_winter_breath", "name": "吹为冬·玄冥霜息", "desc": "向正前扇形 3 格喷吐太古玄冥寒潮（削12内息并挂点穴封气，化【玄冥冻土】；若轰在赤旱焦土上立即引爆寒暑蒸汽崩裂！）。", "geo": "cone_3", "ap": 5, "qi": 18, "cd": 2, "dmgMult": 1.18, "penAdd": 0.10, "armMult": 1.15, "vfx": "wx_vfx_10"},
        "wx_boss_zhuyin_summer_gale": {"key": "wx_boss_zhuyin_summer_gale", "name": "呼为夏·钟山炎风", "desc": "沿直线贯通 3 格喷射钟山赤炎（熔毁22点身甲并蒸干内息，化【赤旱焦土】；若贯入玄冥冻土立即引爆寒暑蒸汽崩裂！）。", "geo": "line_pierce_3", "ap": 5, "qi": 18, "cd": 2, "dmgMult": 1.22, "penAdd": 0.12, "armMult": 1.30, "vfx": "wx_vfx_02"},
        "wx_boss_zhuyin_coil_crush": {"key": "wx_boss_zhuyin_coil_crush", "name": "千里盘山绞", "desc": "催动千里赤鳞龙躯盘山绞杀贴身敌军（崩毁20护甲、震散14内息并致失衡；打碎【赤鳞龙躯】鳞甲即永久废除！）。", "geo": "tail_sweep_arc", "ap": 5, "qi": 16, "cd": 2, "dmgMult": 1.25, "penAdd": 0.15, "armMult": 1.25, "vfx": "wx_vfx_05"},
        "wx_boss_zhuyin_primordial_wind": {"key": "wx_boss_zhuyin_primordial_wind", "name": "息为风·太古移岳", "desc": "双数轮阖目蓄满太古朔风后席卷周遭 4 格敌军将其震飞击退、抽散14内息并卷起沙暴（蓄风轮打满3点破招值可截断！）。", "geo": "ring_quake_6", "ap": 6, "qi": 22, "cd": 3, "dmgMult": 1.28, "penAdd": 0.12, "armMult": 1.20, "vfx": "wx_vfx_26"},
    })

    boss_specs["xiangliuwang"] = {
        "traitName": "九首食九山·断颈化苦泽",
        "canonQuote": "《海外北经》：“共工之臣曰相柳氏，九首，以食于九山。相柳之所抵，厥为泽溪。禹杀相柳，其血腥，不可以树五谷种。”",
        "traitDesc": "盘环主躯周围探出【噬山铁首、苦毒瘴首、惑心妖首、生肌血首】四具独立凶首（共占5格）：斩断任意蛇首立即封印对应凶招并反噬主躯；若未以纯阳/烈火灼封断口，腥血将化平地为【苦毒腐泽】，且生肌血首每3轮可汲毒泽重长断首！",
        "counterHint": "优先斩灭【生肌血首】与【苦毒瘴首】并涂《钦原断续蚀壳膏》或《纯阳朱砂雷火油》封死再生；撒《玄霜净地散》涤清苦毒腐泽！",
        "structureMode": "appendages",
        "parts": [
            {"key": "crusher", "name": "相柳·噬山铁首", "hp": 175, "bodyArmor": 130, "lockedSkill": "actives.wx_boss_xiangliu_mire_ram"},
            {"key": "venom", "name": "相柳·苦毒瘴首", "hp": 155, "bodyArmor": 95, "lockedSkill": "actives.wx_boss_xiangliu_poison_deluge"},
            {"key": "hex", "name": "相柳·惑心妖首", "hp": 145, "bodyArmor": 85, "lockedSkill": "actives.wx_boss_xiangliu_miasma_hex"},
            {"key": "regen", "name": "相柳·生肌血首", "hp": 160, "bodyArmor": 100, "lockedSkill": ""},
        ],
    }
    boss_move_lists["xiangliuwang"] = [
        "wx_boss_xiangliu_nine_devour",
        "wx_boss_xiangliu_mire_ram",
        "wx_boss_xiangliu_poison_deluge",
        "wx_boss_xiangliu_miasma_hex",
    ]
    boss_moves.update({
        "wx_boss_xiangliu_nine_devour": {"key": "wx_boss_xiangliu_nine_devour", "name": "九首食于九山", "desc": "催动所有存活凶首发起连环噬咬（每存1具副首多噬1口，最多4口），每击汲取12气血回哺主躯并染奇毒！", "geo": "pull_devour", "ap": 5, "qi": 18, "cd": 2, "dmgMult": 1.18, "penAdd": 0.10, "armMult": 1.15, "vfx": "wx_vfx_28"},
        "wx_boss_xiangliu_mire_ram": {"key": "wx_boss_xiangliu_mire_ram", "name": "所抵成泽·噬山崩撞", "desc": "催动【噬山铁首】崩碎目标盾牌35耐久、震退失衡并将地面塌陷为【苦毒腐泽】（斩断噬山铁首即永久封印！）。", "geo": "line_charge_3", "ap": 5, "qi": 18, "cd": 2, "dmgMult": 1.22, "penAdd": 0.10, "armMult": 1.35, "vfx": "wx_vfx_05"},
        "wx_boss_xiangliu_poison_deluge": {"key": "wx_boss_xiangliu_poison_deluge", "name": "禹厥三沮·苦泉漫灌", "desc": "催动【苦毒瘴首】引爆全场所有苦毒腐泽喷涌毒泉，蚀甲16、实伤14并染奇毒（登高台或斩断苦毒瘴首可破！）。", "geo": "field_detonate", "ap": 5, "qi": 20, "cd": 3, "dmgMult": 1.20, "penAdd": 0.12, "armMult": 1.20, "vfx": "wx_vfx_28"},
        "wx_boss_xiangliu_miasma_hex": {"key": "wx_boss_xiangliu_miasma_hex", "name": "腥风夺魄·九首妖啸", "desc": "催动【惑心妖首】震慑3格内敌军定力（失败则动摇、散功虚弱并露破绽；斩断惑心妖首即封印！）。", "geo": "sonic_roar", "ap": 4, "qi": 16, "cd": 2, "dmgMult": 1.05, "penAdd": 0.05, "armMult": 1.00, "vfx": "wx_vfx_30"},
    })

    boss_specs["nvchou"] = {
        "traitName": "以袂蔽面·十日居上",
        "canonQuote": "《海外西经》：“女丑之尸，生而十日炙杀之，在丈夫北。以右手鄣其面。十日居上，女丑居山之上。”",
        "traitDesc": "战场高悬 3 轮【汤谷炙魂日冕】阵眼：每存1轮日冕每回合蒸干敌军4点内息并赋予女丑18%阳炎减伤；右手青袂障面令正面受击卸劲35%（侧背盲区无遮挡）。远程『后羿射日』点灭日冕可破护障并当场打断灭世大咒！",
        "counterHint": "神射手与唐门机括优先『后羿射日』点灭空中 3 轮【汤谷炙魂日冕】破阳炎障并断灭世咒；轻功刺客绕左后盲区背刺！",
        "structureMode": "totems",
        "parts": [
            {"key": "sun_1", "name": "汤谷炙魂日冕·东曦", "hp": 85, "bodyArmor": 0, "lockedSkill": ""},
            {"key": "sun_2", "name": "汤谷炙魂日冕·南明", "hp": 85, "bodyArmor": 0, "lockedSkill": ""},
            {"key": "sun_3", "name": "汤谷炙魂日冕·西昊", "hp": 85, "bodyArmor": 0, "lockedSkill": ""},
        ],
    }
    boss_move_lists["nvchou"] = [
        "wx_boss_nvchou_ten_suns_ray",
        "wx_boss_nvchou_sleeve_shift",
        "wx_boss_nvchou_scorch_apocalypse",
    ]
    boss_moves.update({
        "wx_boss_nvchou_ten_suns_ray": {"key": "wx_boss_nvchou_ten_suns_ray", "name": "十日焦山·交叉阳炎线", "desc": "招引场上所有存活【炙魂日冕】投射交叉大日火线，灼穿『日冕—女丑』连线敌军（熔甲18、直伤16并铺赤旱焦土）。", "geo": "totem_ray", "ap": 5, "qi": 18, "cd": 2, "dmgMult": 1.22, "penAdd": 0.14, "armMult": 1.25, "vfx": "wx_vfx_02"},
        "wx_boss_nvchou_sleeve_shift": {"key": "wx_boss_nvchou_sleeve_shift", "name": "青袂障面·移日换影", "desc": "挥起青衣长袂掩面化虹，与距离最远的一轮【炙魂日冕】乾坤易位脱围，并在原地留下灼目迷障。", "geo": "totem_swap", "ap": 3, "qi": 14, "cd": 2, "dmgMult": 1.00, "penAdd": 0.00, "armMult": 1.00, "vfx": "wx_vfx_25"},
        "wx_boss_nvchou_scorch_apocalypse": {"key": "wx_boss_nvchou_scorch_apocalypse", "name": "十日同炙·赤地千里咒", "desc": "两拍灭世天象：首轮聚敛日冕真火（期间射落任意1轮日冕即可破咒反噬女丑30血！），次轮十日齐爆焚灼全场！", "geo": "telegraph_omen", "ap": 6, "qi": 24, "cd": 3, "dmgMult": 1.35, "penAdd": 0.18, "armMult": 1.35, "vfx": "wx_vfx_02"},
    })

    assert len(boss_specs) == 64, f"Expected 64 boss_specs, got {len(boss_specs)}"

    pmat_name_by_id = {pm["id"]: pm["name"] for pm in new_pmat_entries}
    updated_boss_cnt = 0
    for cr in bundle["bestiary"]["creatures"]:
        if cr.get("kind") != "boss":
            continue
        bkey = cr["key"]
        bspec = boss_specs[bkey]
        cr["classicQuote"] = bspec["canonQuote"] or cr.get("classicQuote", "")
        cr["traitName"] = bspec["traitName"]
        cr["traitDesc"] = bspec["traitDesc"]
        cr["counterplay"] = bspec["counterHint"]
        smode = bspec["structureMode"]
        cr["structureMode"] = smode
        cr["structureLabel"] = STRUCT_LABELS.get(smode, smode)

        # Format anatomical / totem parts with resolved locked skill names
        part_list = []
        for pt in bspec["parts"]:
            lsk = pt["lockedSkill"].replace("actives.", "")
            lsk_nm = boss_moves.get(lsk, {}).get("name", "")
            part_list.append({
                "name": pt["name"],
                "hp": pt["hp"],
                "bodyArmor": pt["bodyArmor"],
                "lockedSkillName": lsk_nm,
            })
        cr["parts"] = part_list

        # Sync 3~4 bespoke Boss geometric skills while preserving 60fps Shan-Hai Theater compatibility!
        mv_keys = boss_move_lists.get(bkey, [])
        if mv_keys:
            new_cr_skills = []
            for mk in mv_keys:
                mv = boss_moves[mk]
                geo = mv["geo"]
                amode, acol, albl, fx_k, vfx_default = GEO_TO_THEATER.get(geo, GEO_TO_THEATER["single"])
                lo_dmg = int(round(52 * mv["dmgMult"]))
                hi_dmg = int(round(82 * mv["dmgMult"]))
                dmg_txt = f"{lo_dmg} - {hi_dmg}" if geo not in ("totem_swap", "telegraph_omen") else "法相天象"
                new_cr_skills.append({
                    "name": mv["name"],
                    "ap": mv["ap"],
                    "qi": mv["qi"],
                    "range": GEO_RANGE_LABEL.get(geo, "近身凶招"),
                    "dmg": dmg_txt,
                    "desc": mv["desc"],
                    "animMode": amode,
                    "animColor": acol,
                    "animLabel": albl,
                    "fx": fx_k,
                    "vfx": mv["vfx"] or vfx_default,
                    "directPct": int(round((0.30 + mv["penAdd"]) * 100)),
                    "armorPct": int(round(mv["armMult"] * 100)),
                    "cd": f"冷却{mv['cd']}轮" if mv["cd"] > 0 else "无冷却",
                })
            cr["skills"] = new_cr_skills

        # Attach Part-Break Essence (`wx_pmat_*`) + CoreImprint + Signature Ancient Pill onto `cr`!
        pinfo = boss_part_map[bkey]
        cr["partBreakLoot"] = {
            "essenceId": pinfo["essenceId"],
            "essenceName": pmat_name_by_id[pinfo["essenceId"]],
            "partLabel": pinfo["partLabel"],
            "partKey": pinfo["partKey"],
        }
        if cr.get("core") and cr["core"].get("id"):
            cid = cr["core"]["id"]
            if cid in core_imprints:
                cr["core"]["imprintTitle"] = core_imprints[cid]["title"]
                cr["core"]["imprintDesc"] = core_imprints[cid]["prepDesc"]
            if cid in signature_pill_by_core:
                cr["signaturePill"] = signature_pill_by_core[cid]
        updated_boss_cnt += 1

    assert updated_boss_cnt == 64, f"Expected to update 64 Bosses, got {updated_boss_cnt}"

    # ==========================================================================
    # 6. UPDATE SYSTEM GAMEPLAY GUIDES (`DB.guides` 卷四 / 卷五 / 卷六 / 卷八)
    # ==========================================================================
    for g in bundle["guides"]:
        if g["id"] == "sys-combat":
            g["subtitle"] = "9~11 AP 严格阶梯 · 同槽连段变招 · 轻重装双轨与腰包奇门"
            g["summary"] = "战场交锋围绕行动点（AP）、真气内息、十三类兵装距离、同槽「起承转合」流派连段及十六种武学状态展开。腰包奇门器械与战中灵散涂膏统一收敛，严守底栏 6~9 主动技铁律。"
            g["highlights"] = [
                ["常驻 AP 封顶", "基准 9 AP → 孤本大成最高常驻 11 AP"],
                ["流派气机流转", "同槽连段变招 · 寸劲伏脉三叠爆五脏"],
                ["腰包防溢出收敛", "奇门机括 + 奇药涂散各仅占 1 格技能栏"],
                ["全局防膨胀封顶", "额外穿甲 ≤+25% · 气血实伤减免 ≤60%"],
            ]
        elif g["id"] == "sys-alchemy":
            g["subtitle"] = "四十九味山海本草 · 文武三段控火 · 六十五方与九十六妖丹丹韵"
            g["summary"] = "采自五臧大荒的四十九味《山海本草》、九十六枚山海内丹与十二种破部精粹自动归入零占格「百草药柜」。随身开启八卦丹炉，借文武三段炉火、六脉生克与大妖本命内丹，可炼就六十五种灵丹与九款战中破局奇散秘膏。"
            g["highlights"] = [
                ["49 味山海本草", "五臧山经至大荒仙株全收录，零占格入柜"],
                ["文武控火与逆炼", "文火稳产 · 武火催丹霞并逆炼 3 大奇丹"],
                ["96 妖丹本命韵", "64 大妖一对一丹韵 + 12 道古神本命秘方"],
                ["三维战中奇药", "备战丹 + 2AP 改地/破穴散 + 四派涂刃秘膏"],
            ]
            g["sections"] = [
                {
                    "h": "一、三段炉温控火、六脉生克与阴阳逆命奇丹",
                    "p": [
                        "随身开启青铜八卦丹炉时，可自由抉择三档炉温火候：君臣药性相生可放大成丹品阶，而以【武火催霞】配合山海大妖内丹镇压两极相克药引（赤阳×玄阴、生机×奇毒、镇魂×奇毒），更可逆炼出常规丹书不载的三大【阴阳逆命奇丹】！",
                    ],
                    "table": {
                        "headers": ["控火模式", "炭火工钱与保底", "品阶与双丹修正", "丹劫与逆命机制"],
                        "rows": [
                            ["文火温养", "工钱 9 折 · 保底药效 ≥98%", "灵纹率 +8%（丹霞略降）", "零丹劫风险，最宜稳炼天品洗髓丹与断续圣膏"],
                            ["中火守正", "标准工钱 · 保底药效 ≥92%", "标准品阶与紫气双丹率", "阴阳平和，零丹劫走火风险"],
                            ["武火催霞", "工钱 1.2 倍 · 保底药效 ≥95%", "丹霞极品率 +18% · 双丹率 +15%", "可逆炼【两仪/枯荣/神魔】三大逆命奇丹；无内丹镇压相克时有概率触发丹劫凝成《暴烈奇毒散》"],
                        ],
                    },
                },
                {
                    "h": "二、丹武合一：四脉催化、96 妖丹本命韵与战中涂散",
                    "p": [
                        "1. 四脉武学催化：六脉臣佐辅药与十大江湖常备丹均与角色所修【阳刚/阴柔/中正/五毒内功】及【外功/轻功/横练】产生机制共振（如阳刚灼甲、阴柔反凝寒霜、调息增效、横练减甲损）。",
                        "2. 九十六内丹去白板化：拒绝把山海大妖内丹当普通药力烧掉！64 尊秘境大妖与 32 种荒泽/四圣内丹作君药入鼎时，100% 烙印独门【本命妖丹丹韵】；烛阴、白泽、建木、饕餮、应龙、蚩尤、金乌、相柳、玄龟、帝江、九尾、刑天十二尊古神更拥有唯一指定君药的【古神本命奇丹】。",
                        "3. 战中破局奇散与多门派涂刃秘膏：腰包可携带耗 2 AP 瞬发的《玄霜净地辟秽散》（扑灭十日焦土/苦毒腐泽化清明地脉）、《龙虎醒神破穴散》（立解点穴失衡，与备战丹共享单场 2 药安全丹毒阈值），以及《钦原断续蚀壳膏》（封死大妖再生并破玄壳）、《纯阳朱砂雷火油》、《化血透骨寸劲膏》、《子母连环引蛊脂》四大门派涂刃奇膏。",
                    ],
                },
            ]
        elif g["id"] == "sys-forging":
            g["subtitle"] = "破部取粹十二奇材 · 百一十一道器灵魂通 · 五引淬火与锁词精铸"
            g["summary"] = "打破白板红武与无脑摇号：37 柄历史传世神兵全数觉醒典故器灵，62 件山海神装承载大妖原典神通；猎杀 64 大妖破部位剥取 12 种专属精粹，打造全 13 类主手兵刃铭配与 6 大腰包奇门器械，并在重锻台以五路淬火引子与锁词精铸打磨传世神工。"
            g["highlights"] = [
                ["115 件有魂神兵甲", "37 传世器灵 + 62 山海神通 + 16 百工兽魄"],
                ["破部取粹与铭配", "64 妖部位破坏 → 12 精粹 → 13 兵种专属铭文"],
                ["引子塑形·锁词精铸", "五路淬火引子定向偏置词条 + 破部奇材锁主/辅词条"],
                ["六大腰包奇门器械", "断龙破障钉 · 拒马铁蒺藜 · 震天雷 · 镇尸墨斗网"],
            ]
            g["sections"] = [
                {
                    "h": "一、名器有魂、破部取粹与十三兵类铭配",
                    "p": [
                        "37 把历史名器（如《干将》《莫邪》同阵雌雄剑气共鸣、《承影》夜雾必中、《巨阙》重击碎盾震退、《绿玉竹杖》绊摔借力）与 62 件山海神装（含 12 枚山海异佩）均具备独立机制词条。",
                        "讨伐 64 尊山海大妖时，针对性击破其龙躯、毒首、玄壳、风翼或阵眼，100% 定向掉落 12 种【破部精粹奇材】（`wx_pmat_*`），可在「百工丹坊」锻造镶嵌于全部 13 类主手兵刃的【器魂铭文配件】（如太清流云剑穗、吞口血槽刀锷铭、昆仑寒玉寸劲箍、墨家神机连发簧）及 6 种单场自补的【腰包奇门器械】。",
                    ],
                },
                {
                    "h": "二、五路淬火引子塑形与百炼锁词精铸",
                    "p": [
                        "在「神兵重锻」台重淬红武神装或百工兵甲时，除保留凡锻/良工/百炼/神工四阶与五锤百炼保底外，可投喂百草药柜中的灵泉、赤火、雷骨或煞血作为【淬火引子】定向拉升目标属性区间并烙印专属淬锋词条，亦可消耗 1 份破部精粹锁死满意的核心词条：",
                    ],
                    "table": {
                        "headers": ["淬火引子 / 精铸操作", "定向塑形倾向", "附加【淬火词条】与精铸规则"],
                        "rows": [
                            ["寒潭灵泉引（玄阴淬）", "轻量化减重 & 透甲倾向 +18%", "烙印【寒泉淬锋】：战斗中每回合额外回气 +1"],
                            ["地肺赤火引（赤阳淬）", "基伤上限 & 破甲倾向 +18%", "烙印【赤火淬锋】：近战攻击命中额外灼损目标 5 点身甲"],
                            ["天雷紫电引（惊雷淬）", "基伤上限 & 器物耐久倾向 +18%", "烙印【惊雷淬锋】：开场首轮先攻身法 +8"],
                            ["凶兽煞血引（煞血淬）", "主属性 & 器物耐久倾向 +18%", "烙印【煞血淬锋】：斩杀血肉活物回血 +5（每轮限 1 次）"],
                            ["百炼锁词精铸（锁 F1 / F2）", "100% 保留已锁定的主词条或辅词条满值", "额外消耗 1 份【破部精粹奇材】与 1.5 倍重锻银，仅重摇未锁定词条"],
                        ],
                    },
                },
            ]
        elif g["id"] == "sys-shanhai":
            g["subtitle"] = "六十四尊多部位法相大妖 · 天灾地脉交互 · 破部狩猎闭环"
            g["summary"] = "大荒迷雾深处盘踞着六十四尊按《山海经》原典重塑的多格盘躯、多首断肢与伴生阵眼大妖（共 194 式专属几何凶招），配合破部取粹、奇门断龙钉与改地灵散构成硬核猎妖考题。"
            g["highlights"] = [
                ["64 尊原典法相大妖", "三格烛阴 · 五格九首相柳 · 十日女丑阵眼"],
                ["194 式几何凶招", "扇面霜息、日冕交叉射线、苦泉漫灌，零通用换皮"],
                ["部位破坏封招夺粹", "碎龙躯/斩毒首/射日冕当场废除凶招并必掉破部精粹"],
                ["丹器克制矩阵", "断龙钉破蓄势 · 玄霜散净天灾 · 钦原膏封再生"],
            ]

    # ==========================================================================
    # 7. GARBAGE-COLLECT UNREFERENCED ICONS & UPDATE `DB.stats`
    # ==========================================================================
    ref_icons: set[str] = set()
    collect_referenced_icons(bundle, ref_icons)
    bundle["icons"] = {k: v for k, v in icons.items() if k in ref_icons}

    bundle["stats"]["manuals"] = len(bundle["manuals"])
    bundle["stats"]["skills"] = len(bundle["skills"])
    bundle["stats"]["statuses"] = len(bundle["statuses"])
    bundle["stats"]["equipment"] = len(bundle["equipment"])
    bundle["stats"]["equipmentSets"] = len(bundle["equipmentSets"])
    bundle["stats"]["pills"] = len(bundle["alchemy"]["pills"])
    bundle["stats"]["herbs"] = len(bundle["alchemy"]["herbs"])
    bundle["stats"]["cores"] = len(bundle["alchemy"]["cores"])
    bundle["stats"]["tacticalItems"] = len(bundle["alchemy"]["tacticalItems"])
    bundle["stats"]["creatures"] = len(bundle["bestiary"]["creatures"])
    bundle["stats"]["icons"] = len(bundle["icons"])

    new_json = json.dumps(bundle, ensure_ascii=False, separators=(",", ":"))
    new_html = html[: m_bundle.start(2)] + new_json + html[m_bundle.end(2) :]
    WIKI_PATH.write_text(new_html, encoding="utf-8")

    print("=== 山海武侠.html BUNDLE SYNC COMPLETE ===")
    for k, v in bundle["stats"].items():
        print(f"  {k}: {v}")


if __name__ == "__main__":
    main()
