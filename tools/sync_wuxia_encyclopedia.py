#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Master Single-Source-of-Truth Synchronizer for《山海武侠 · 江湖总录与百科图鉴》(`山海武侠.html`).

Synchronizes ALL live Mod systems directly from `mod_wuxia/` `.nut` scripts & `gfx/` assets:
  1. 64 Bespoke《山海经》Apex Bosses ("一妖一法相 · 一战一考题"):
     - Original《山海经》`CanonQuote`, bespoke `special.wx_boss_trait_<key>` (`TraitName` & `TraitDesc`),
       explicit `CounterHint`, `StructureMode` (`多体节巨躯 / 多首断肢破坏 / 伴生领域阵眼 / 原典异律法相`),
       multi-tile/appendage/totem `parts` specs, dynamic `TileField` environment, part-break essences,
       and all 194 bespoke geometric Boss active moves wired to the 60fps Shan-Hai Action Theater!
  2. 13-Family Deep Wuxia Martial Arts Streams & 171 Playable Active Moves + 276 Manuals + 24 Statuses/Fields:
     - Live `Name`, `Description`, `AP`, `Qi`, `Range`, `Cooldown`, `DirectDamageMult`, `WX_ComboForms`
       (same-slot 2/3-stage dynamic progression), and `streamTag` badges across all 171 `actives.wx_*` moves.
     - Re-syncs all 276 `DB.manuals` (`levels`, `skills`, `summary`, `hasPermAP`, `hasWash`).
     - Expands `DB.statuses` (`12 -> 24`) with all 16 live Wuxia combat/recovery effects + 8 dynamic `TileField` terrains.
  3. 59 Famous/Shan-Hai Relic Spirits & Full Forge/Tactical Ecosystem (`DB.equipment`: `121 -> 161`):
     - Populates bespoke `GearTraits` on all 37 Historical Relics, 22 Shan-Hai Weapons, 40 Shan-Hai Gear & 16 Beast Gear.
     - Adds 12 Boss Part-Break Essences (`wx_pmat_*`), 13 Weapon Attachments (`wx_wmod_*`),
       6 Belt Tactical Gadgets (`wx_gadget_*`), and 9 Mid-Battle Powders/Blade Coatings (`wx_tact_*`).
  4. Bagua Cauldron 65 Spirit Pills, 49《山海本草》Spirit Herbs & 96 Bespoke Core Imprints (`DB.alchemy`):
     - Adds all 15 Reverse-Fate Mutation & Boss Signature Neidan Pills + formulas (`50 -> 65`).
     - Adds all 32 expanded《山海本草》regional/mythic herbs (`17 -> 49`).
     - Attaches `CoreImprints` (`本命妖丹丹韵`) onto all 96 Shan-Hai Cores.
  5. Roster, Events, 10 System Gameplay Chapters (`DB.guides`) & HTML/JS Modal/Filter Renderers.

100% idempotent and produces a 100% standalone offline single-file `山海武侠.html`.
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

sys.path.insert(0, str(ROOT / "tools"))
from sync_wiki_bundle_all import TROPHY_ITEM_ZH, VANILLA_SKILL_NAMES  # noqa: E402
from theater_v2_upgrade import enrich_bundle_for_theaters, upgrade_html_theaters  # noqa: E402


# ==============================================================================
# Helper: Clean BBCode & Image Encoding
# ==============================================================================

def strip_bbcode(s: str) -> str:
    if not s:
        return ""
    s = re.sub(r"\[color=[^\]]+\]", "", s)
    s = s.replace("[/color]", "")
    s = re.sub(r"\[img\][^\[]*\[/img\]", "", s)
    return s.strip()


def encode_webp_48(png_path: Path, trim_alpha: bool = True) -> str:
    im = Image.open(png_path).convert("RGBA")
    if trim_alpha:
        bbox = im.getchannel("A").point(lambda a: 255 if a > 12 else 0).getbbox()
        if bbox:
            im = im.crop(bbox)
        s = min(44.0 / max(1, im.width), 44.0 / max(1, im.height))
        nw, nh = max(1, int(round(im.width * s))), max(1, int(round(im.height * s)))
        rs = im.resize((nw, nh), Image.Resampling.LANCZOS)
        canvas = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
        canvas.alpha_composite(rs, ((48 - nw) // 2, (48 - nh) // 2))
    else:
        canvas = im.resize((48, 48), Image.Resampling.LANCZOS)
    buf = io.BytesIO()
    canvas.save(buf, format="WEBP", quality=92, method=6)
    return "data:image/webp;base64," + base64.b64encode(buf.getvalue()).decode("ascii")


def resolve_gfx_png(rel_icon: str) -> Path | None:
    if not rel_icon:
        return None
    rel = rel_icon.lstrip("/")
    candidates = [
        MOD_DIR / "gfx" / "ui" / "items" / rel,
        MOD_DIR / "gfx" / "ui" / rel,
        MOD_DIR / "gfx" / rel,
    ]
    for c in candidates:
        if c.exists():
            return c
    return None


# ==============================================================================
# 1. Bespoke 64 Shan-Hai Bosses & 194 Geometric Boss Moves
# ==============================================================================

GEO_META = {
    "cone_3":          ("前方扇形3格",   "dragon_breath",        "太古龙息 · 扇面吐息", "#ff6b3d", "wx_fx_dragon_head",   "wx_vfx_02"),
    "line_pierce_3":   ("直线3格贯通",   "root_thorn_entangle",  "贯阵长虹 · 三格穿刺", "#ffd166", "wx_fx_earth_fissure", "wx_vfx_07"),
    "line_charge_3":   ("直线3格冲撞",   "horn_gore_charge",     "蛮角冲阵 · 破盾贯撞", "#ff7849", "wx_fx_earth_fissure", "wx_vfx_05"),
    "ring_aoe_1":      ("周身1环震荡",   "headless_waraxe",      "戮神旋斩 · 环形横扫", "#ff5a36", "wx_fx_claw_slash",    "wx_vfx_13"),
    "ring_quake_6":    ("周身六合震荡",  "headless_waraxe",      "六合崩岳 · 环形横扫", "#ff5a36", "wx_fx_earth_fissure", "wx_vfx_05"),
    "ring_aoe_2":      ("周身2环天威",   "sonic_dread_roar",     "摄魄凶啸 · 妖域震胆", "#c77dff", "wx_fx_sonic_ring",    "wx_vfx_23"),
    "sonic_roar":      ("周身妖啸震慑",  "sonic_dread_roar",     "摄魄凶啸 · 音波裂胆", "#c77dff", "wx_fx_sonic_ring",    "wx_vfx_23"),
    "pull_devour":     ("1~3格抓投吞噬", "abyss_tentacle_drag",  "深渊卷摄 · 拖入噬血", "#8ac926", "wx_fx_blood_orb",     "wx_vfx_06"),
    "sky_dive":        ("高空俯冲扑杀",   "sky_talon_dive",       "九霄俯冲 · 铁爪掀胄", "#ff9f1c", "wx_fx_claw_slash",    "wx_vfx_14"),
    "leap_slam_3":     ("1~3格飞扑崩砸", "sky_talon_dive",       "凌空飞扑 · 崩岳重砸", "#ff9f1c", "wx_fx_earth_fissure", "wx_vfx_05"),
    "omen_cataclysm":  ("两轮蓄力天灾",   "ape_titan_slam",       "太古蓄势 · 灭世崩岳", "#ff4d4d", "wx_fx_earth_fissure", "wx_vfx_17"),
    "telegraph_omen":  ("两轮蓄力天灾",   "ape_titan_slam",       "天象预警 · 灭世浩劫", "#ff4d4d", "wx_fx_earth_fissure", "wx_vfx_17"),
    "totem_swap":      ("阵眼移形换影",   "dream_shadow_ambush",  "诡影移形 · 阵眼易位", "#e0aaff", "wx_fx_bagua",         "wx_vfx_19"),
    "totem_ray":       ("阵眼交叉射线",   "sun_crow_nova",        "阵眼共鸣 · 贯空射线", "#ffb703", "wx_fx_dragon_head",   "wx_vfx_07"),
    "field_detonate":  ("引爆全场阵境",   "sun_crow_nova",        "天地共鸣 · 引爆灾域", "#ff7b00", "wx_fx_dragon_head",   "wx_vfx_28"),
    "multi_bite_3":    ("多首连环狂噬",   "multi_head_frenzy",    "多首齐下 · 连环狂噬", "#ff595e", "wx_fx_claw_slash",    "wx_vfx_06"),
    "ranged_barrage":  ("1~4格攒射飞刺", "venom_needle_barrage", "漫天飞刺 · 攒射穿甲", "#ffca3a", "wx_fx_gold_needle",   "wx_vfx_27"),
    "boulder_throw":   ("2~4格掷岳轰砸", "boulder_hurl_smash",   "掷岳巨岩 · 凌空轰砸", "#d4a373", "wx_fx_earth_fissure", "wx_vfx_05"),
    "tail_sweep_arc":  ("巨尾扇形3格扫", "coiled_crush",         "盘蟒摆尾 · 弧面震飞", "#52b788", "wx_fx_whip_arc",      "wx_vfx_31"),
    "hex_curse":       ("1~4格摄魂妖咒", "fox_charm_miasma",     "惑心妖瘴 · 隔空夺魄", "#d08bff", "wx_fx_sonic_ring",    "wx_vfx_30"),
    "single":          ("近身凶威重击",   "feral_pounce",         "凶威扑杀 · 裂甲碎骨", "#ff6b4a", "wx_fx_claw_slash",    "wx_vfx_13"),
}

FIELD_LABELS = {
    "drought_scorch": "赤旱焦土",
    "bitter_mire":    "苦毒腐泽",
    "abyss_frost":    "玄冥冻土",
    "thunder_pool":   "流波雷池",
    "mirage_mist":    "青丘迷障",
    "gale_sandstorm": "裂风沙暴",
    "gale_sand":      "裂风沙暴",
    "ancient_ward":   "太古巫阵",
}

STRUCTURE_LABELS = {
    "segments":   "多体节巨躯",
    "appendages": "多首共生断肢",
    "totems":     "天象领域阵眼",
    "mythic_law": "单格本命异律",
}

STATUS_LABELS_SHORT = {
    "bleed":      "割裂流血",
    "poison":     "山海奇毒",
    "daze":       "震荡失衡",
    "offbalance": "震荡失衡",
    "opening":    "撕露破绽",
    "acupoint":   "点穴封气",
    "chill":      "寒凝封穴",
    "injury":     "脏腑内伤",
    "shaken":     "动摇心神",
    "scatter":    "散劲虚弱",
}

FLAGSHIP_3_BOSSES = {
    "zhuyin": {
        "traitName": "视为昼瞑为夜·千里真龙躯",
        "canonQuote": "《海外北经》：“钟山之神，名曰烛阴，视为昼，瞑为夜，吹为冬，呼为夏，不饮，不食，不息，息为风，身长千里。”",
        "traitDesc": "钟山古神三格蜿蜒真龙躯（神首·赤鳞龙躯·盘山龙尾）：单数轮【视为昼】全场大明、正面神瞳灼目（正面攻首命中-8，武艺+12、总伤+15%）；双数轮【瞑为夜】夜幕低垂敛息蓄风（露出七寸破绽，以点穴/纯阳/破气注入 3 点破招值可震断太古朔风！）。击碎【赤鳞龙躯】鳞甲永久废除千里盘山绞，击碎【盘山龙尾】削其 10 点近防！",
        "counterplay": "单数轮切忌正面强攻龙首，宜从侧翼重兵轰碎【赤鳞龙躯】与【盘山龙尾】鳞甲；双数轮趁其阖目蓄风露出七寸破绽，集火施展点穴/纯阳/破气招式打断『息为风』灭世吹飞，并借冰火走位规避寒暑蒸汽爆！",
        "structureMode": "segments",
        "initField": "abyss_frost",
        "parts": [
            {"name": "烛九阴·赤鳞龙躯", "brush": "wx_part_zhuyin_body", "stats": "身甲 260 / 头甲 190 / 近防 10", "role": "同进退多格龙躯；打碎鳞甲即永久封印【千里盘山绞】"},
            {"name": "烛九阴·盘山龙尾", "brush": "wx_tail_zhuyin",      "stats": "身甲 210 / 头甲 150 / 近防 12", "role": "护翼侧后盲区；打碎鳞甲令烛阴本体常驻近防 -10"},
        ],
        "skills": [
            {
                "id": "wx_boss_zhuyin_winter_breath", "name": "吹为冬·玄冥霜息", "ap": 5, "qi": 18, "cd": 2,
                "range": "前方扇形3格", "dmg": "穿甲35% · 散气12",
                "effects": ["铺设玄冥冻土", "点穴封气", "遇焦土触发蒸汽爆"],
                "desc": "烛龙吹气成严冬：向正前方扇形 3 格喷吐太古玄冥寒潮，削减 12 内息并挂【点穴封气】，将扇面化为【玄冥冻土】（若覆盖赤旱焦土立即引发寒暑崩裂蒸汽爆！）。",
                "animMode": "dragon_breath", "animLabel": "玄冥霜息 · 扇面冰潮", "animColor": "#6db4e8", "fx": "wx_fx_ice_spikes", "vfx": "wx_vfx_10",
            },
            {
                "id": "wx_boss_zhuyin_summer_gale", "name": "呼为夏·钟山炎风", "ap": 5, "qi": 18, "cd": 2,
                "range": "直线3格贯通", "dmg": "灼甲22 · 穿甲35%",
                "effects": ["铺设赤旱焦土", "蒸干内息", "遇冻土触发蒸汽爆"],
                "desc": "烛龙呼气化酷暑：沿直线贯通 3 格喷射钟山赤炎（熔毁 22 点身甲并蒸干内息），将走廊化为【赤旱焦土】；若贯入已有【玄冥冻土】之格，当场引爆寒暑蒸汽崩裂重创周遭！",
                "animMode": "dragon_breath", "animLabel": "钟山炎风 · 贯线焚甲", "animColor": "#ff6b35", "fx": "wx_fx_dragon_head", "vfx": "wx_vfx_02",
            },
            {
                "id": "wx_boss_zhuyin_coil_crush", "name": "千里盘山绞", "ap": 4, "qi": 14, "cd": 2,
                "range": "贴身1格绞杀", "dmg": "穿甲45% · 碎甲20",
                "effects": ["无视盾防", "散气14 · 失衡", "碎龙躯即封印"],
                "desc": "催动千里赤鳞龙躯盘山绞杀：对贴身敌军施加无视盾牌的高穿甲绞碎（崩毁 20 护甲、震散 14 内息并挂失衡）；打碎【赤鳞龙躯】鳞甲即永久废除此招！",
                "animMode": "coiled_crush", "animLabel": "盘蟒绞骨 · 碎甲锁脉", "animColor": "#ff9f1c", "fx": "wx_fx_whip_arc", "vfx": "wx_vfx_05",
            },
            {
                "id": "wx_boss_zhuyin_primordial_wind", "name": "息为风·太古移岳", "ap": 4, "qi": 15, "cd": 2,
                "range": "周身4格朔风", "dmg": "全体震退 · 散气14",
                "effects": ["双数轮蓄风后释放", "铺设裂风沙暴", "可3点破招打断"],
                "desc": "《海外北经》不息，息为风：双数轮阖目蓄满太古朔风后呼啸而出，席卷 4 格内全部敌军震飞击退、抽散 14 内息并卷起【裂风沙暴】！",
                "animMode": "sonic_dread_roar", "animLabel": "太古朔风 · 移岳吹飞", "animColor": "#90e0ef", "fx": "wx_fx_sonic_ring", "vfx": "wx_vfx_26",
            },
        ],
    },
    "xiangliuwang": {
        "traitName": "九首食九山·断颈化苦泽",
        "canonQuote": "《海外北经》：“共工之臣曰相柳氏，九首，以食于九山。相柳之所抵，厥为泽溪。禹杀相柳，其血腥，不可以树五谷种。禹厥之，三仞三沮，乃以为众帝之台。”",
        "traitDesc": "共工凶臣五格盘环妖躯：主躯周围探出【噬山铁首、苦毒瘴首、惑心妖首、生肌血首】四具独立凶首。斩断任意蛇首立即封印对应凶招并反噬主躯；但若未以纯阳内功/烈火招式/神机火器灼封断颈，腥血将把平地化为【苦毒腐泽】，且【生肌血首】存活时每 3 轮可汲干毒泽重长断首！",
        "counterplay": "优先集火斩灭【生肌血首】与【苦毒瘴首】断其再生与全屏毒爆；斩首一击务必由纯阳内功侠客、燃木火刀或神机火铳收尾以『灼封断颈』阻止腥血成泽；全队抢占高地（『众帝之台』）规避平地苦泉漫灌！",
        "structureMode": "appendages",
        "initField": "bitter_mire",
        "parts": [
            {"name": "相柳·噬山铁首", "brush": "wx_part_xiangliu_iron",  "stats": "气血 175 / 身甲 130 / 近防 12", "role": "独立受击凶首；斩断即封印【所抵成泽·噬山崩撞】"},
            {"name": "相柳·苦毒瘴首", "brush": "wx_part_xiangliu_mire",  "stats": "气血 155 / 身甲 95 / 近防 10",  "role": "独立受击凶首；斩断即封印【禹厥三沮·苦泉漫灌】"},
            {"name": "相柳·惑心妖首", "brush": "wx_part_xiangliu_charm", "stats": "气血 145 / 身甲 85 / 近防 14",  "role": "独立受击凶首；斩断即封印【腥风夺魄·九首妖啸】"},
            {"name": "相柳·生肌血首", "brush": "wx_part_xiangliu_blood", "stats": "气血 160 / 身甲 100 / 近防 10", "role": "核心再生首；存活时为本体回血并每 3 轮汲取苦泽重生断首"},
        ],
        "skills": [
            {
                "id": "wx_boss_xiangliu_nine_devour", "name": "九首食于九山", "ap": 5, "qi": 18, "cd": 2,
                "range": "1~2格多首连噬", "dmg": "至多4连噬 · 每口汲血12",
                "effects": ["随存活蛇首增伤", "吸血回哺主躯", "注入奇毒"],
                "desc": "催动所有存活凶首向周遭敌军发起连环噬咬（每存 1 具副首多噬 1 口，最多 4 口），每击汲取 12 点气血回哺盘环主躯并注入山海奇毒！",
                "animMode": "multi_head_frenzy", "animLabel": "九首狂袭 · 连环噬山", "animColor": "#8ac926", "fx": "wx_fx_poison_skull", "vfx": "wx_vfx_28",
            },
            {
                "id": "wx_boss_xiangliu_mire_ram", "name": "所抵成泽·噬山崩撞", "ap": 4, "qi": 15, "cd": 2,
                "range": "1~2格破盾冲抵", "dmg": "碎盾35 · 穿甲30%",
                "effects": ["塌陷苦毒腐泽", "击退失衡", "斩噬山首即封印"],
                "desc": "《海外北经》相柳之所抵，厥为泽溪：催动【噬山铁首】猛撞阵线，崩碎盾牌 35 点耐久、震退失衡并将受击处化为【苦毒腐泽】（斩断『噬山铁首』永久封印！）。",
                "animMode": "horn_gore_charge", "animLabel": "所抵成泽 · 破盾塌陷", "animColor": "#52b788", "fx": "wx_fx_earth_fissure", "vfx": "wx_vfx_05",
            },
            {
                "id": "wx_boss_xiangliu_poison_deluge", "name": "禹厥三沮·苦泉漫灌", "ap": 4, "qi": 16, "cd": 3,
                "range": "全场苦泽引爆", "dmg": "蚀甲16 · 毒伤14",
                "effects": ["引爆全场苦毒腐泽", "登高台可规避", "斩苦毒首即封印"],
                "desc": "催动【苦毒瘴首】引爆全场所有【苦毒腐泽】喷发腥臭毒泉，重创平地泥沼中的敌军并染剧毒（登上高台『众帝之台』或斩断『苦毒瘴首』可破此招！）。",
                "animMode": "sun_crow_nova", "animLabel": "苦泉漫灌 · 全泽毒爆", "animColor": "#70e000", "fx": "wx_fx_poison_skull", "vfx": "wx_vfx_28",
            },
            {
                "id": "wx_boss_xiangliu_miasma_hex", "name": "腥风夺魄·九首妖啸", "ap": 4, "qi": 15, "cd": 3,
                "range": "周身3格妖啸", "dmg": "震慑定力 · 散劲破绽",
                "effects": ["铺设青丘迷障", "动摇心神", "斩惑心首即封印"],
                "desc": "催动【惑心妖首】吐出腥臭迷魂瘴雾：震慑 3 格内敌军定力（检定失败陷入动摇、散劲虚弱与破绽）并布下迷障（斩断『惑心妖首』即可封印！）。",
                "animMode": "fox_charm_miasma", "animLabel": "腥风妖啸 · 迷瘴夺魄", "animColor": "#b5e48c", "fx": "wx_fx_sonic_ring", "vfx": "wx_vfx_30",
            },
        ],
    },
    "nvchou": {
        "traitName": "以袂蔽面·十日居上",
        "canonQuote": "《海外西经》：“女丑之尸，生而十日炙杀之，在丈夫北。以右手鄣其面。十日居上，女丑居山之上。”",
        "traitDesc": "十日炙杀之青衣女丑尸魂：战场高悬 3 轮【汤谷炙魂日冕】阵眼。每存 1 轮日冕，每回合蒸干 4 格内敌军 4 点内息并为女丑提供 18% 大日阳炎减伤；女丑以右手青袂障面，正面受击额外卸劲 35%，唯左侧后盲区无遮挡。神射/暗器『后羿射日』点灭日冕可反噬女丑 30 气血，并在其吟唱灭世咒时当场破咒反噬！",
        "counterplay": "弓弩/暗器好手优先执行『后羿射日』逐一点灭空中 3 轮【炙魂日冕】削去阳炎减伤障、打断十日同炙灭世咒；近战侠客借轻功绕至女丑左后侧盲区背刺，避开正面『以袂蔽面』35% 卸劲，且切忌站在『日冕—女丑』三点一线上！",
        "structureMode": "totems",
        "initField": "drought_scorch",
        "parts": [
            {"name": "汤谷炙魂日冕·东曦", "brush": "wx_totem_sun_corona", "stats": "气血 85 / 避暗 4 / 近防 8", "role": "空中大日阵眼；射落可削去女丑 18% 减伤并反噬 30 气血"},
            {"name": "汤谷炙魂日冕·南明", "brush": "wx_totem_sun_corona", "stats": "气血 85 / 避暗 4 / 近防 8", "role": "空中大日阵眼；女丑蓄力灭世咒时射落即当场破咒震晕"},
            {"name": "汤谷炙魂日冕·西昊", "brush": "wx_totem_sun_corona", "stats": "气血 85 / 避暗 4 / 近防 8", "role": "空中大日阵眼；与女丑连成交叉阳炎灼穿射线"},
        ],
        "skills": [
            {
                "id": "wx_boss_nvchou_ten_suns_ray", "name": "十日焦山·交叉阳炎线", "ap": 5, "qi": 16, "cd": 2,
                "range": "1~4格三点连线", "dmg": "熔甲18 · 阳炎直伤16",
                "effects": ["日冕—女丑交叉射线", "铺设赤旱焦土", "走位错线可规避"],
                "desc": "招引空中所有存活【炙魂日冕】投射交叉大日火线：灼穿目标格及『日冕—女丑』连线上的全部敌军并铺设【赤旱焦土】。射灭日冕或错开三点一线即可规避！",
                "animMode": "dragon_breath", "animLabel": "十日射线 · 交叉焚山", "animColor": "#ffb703", "fx": "wx_fx_dragon_head", "vfx": "wx_vfx_02",
            },
            {
                "id": "wx_boss_nvchou_sleeve_shift", "name": "青袂障面·移日换影", "ap": 3, "qi": 12, "cd": 2,
                "range": "日冕乾坤换位", "dmg": "脱围换位 · 热浪迷障",
                "effects": ["与最远日冕互换位置", "原地留热浪迷障"],
                "desc": "挥起青衣长袂掩面化虹，与场上距离最远的一轮【炙魂日冕】瞬间乾坤易位脱出重围，并在原处留下灼目热浪迷障！",
                "animMode": "dream_shadow_ambush", "animLabel": "青袂化虹 · 移日换影", "animColor": "#ffd166", "fx": "wx_fx_bagua", "vfx": "wx_vfx_25",
            },
            {
                "id": "wx_boss_nvchou_scorch_apocalypse", "name": "暴衣大旱·十日同炙咒", "ap": 4, "qi": 18, "cd": 3,
                "range": "两轮蓄力全屏大旱", "dmg": "全场焚甲 · 赤地千里",
                "effects": ["首轮吟唱预警", "射落1日即破咒反噬", "玄霜散可净地"],
                "desc": "首轮仰天揭袂引十日真火入体（本轮内射灭任意 1 轮日冕即可当场破咒令女丑反噬重伤失衡！）；次轮若未破咒则十日齐爆，焚灼全场护甲气血并化赤地千里！",
                "animMode": "sun_crow_nova", "animLabel": "十日同炙 · 赤地灭世", "animColor": "#fb5607", "fx": "wx_fx_dragon_head", "vfx": "wx_vfx_17",
            },
        ],
    },
}


def parse_61_catalog_bosses() -> tuple[dict[str, dict], dict[str, dict]]:
    specs: dict[str, dict] = {}
    moves: dict[str, dict] = {}
    cat_files = [
        MOD_DIR / "mod_wuxia/systems/wx_shanhai_boss_catalog_s1_s2.nut",
        MOD_DIR / "mod_wuxia/systems/wx_shanhai_boss_catalog_s3_s4_s5.nut",
    ]
    for cf in cat_files:
        src = cf.read_text(encoding="utf-8")
        # Parse ShanHaiBossSpecs.<key> <- { ... };
        for m in re.finditer(r"::Wuxia\.ShanHaiBossSpecs\.([a-z0-9_]+)\s*<-\s*\{([\s\S]*?)\n\};", src):
            key, blk = m.group(1), m.group(2)
            get_s = lambda pat, d="": (re.search(pat, blk).group(1) if re.search(pat, blk) else d)
            parts = []
            parts_m = re.search(r"Parts\s*=\s*\[([\s\S]*?)\]", blk)
            if parts_m:
                for pm in re.finditer(r"\{([^\}]+)\}", parts_m.group(1)):
                    pblk = pm.group(1)
                    p_name = re.search(r'Name\s*=\s*"([^"]+)"', pblk)
                    p_brush = re.search(r'Brush\s*=\s*"([^"]+)"', pblk)
                    p_hp = re.search(r"(?:HP|Hitpoints)\s*=\s*(\d+)", pblk)
                    p_ba = re.search(r"BodyArmor\s*=\s*(\d+)", pblk)
                    p_ha = re.search(r"HeadArmor\s*=\s*(\d+)", pblk)
                    p_lock = re.search(r'LockedSkillID\s*=\s*"([^"]*)"', pblk)
                    st_bits = []
                    if p_hp:
                        st_bits.append(f"气血 {p_hp.group(1)}")
                    if p_ba:
                        st_bits.append(f"身甲 {p_ba.group(1)}")
                    if p_ha:
                        st_bits.append(f"头甲 {p_ha.group(1)}")
                    parts.append({
                        "name": p_name.group(1) if p_name else "伴生部位",
                        "brush": p_brush.group(1) if p_brush else "",
                        "stats": " / ".join(st_bits) if st_bits else "伴生灵体",
                        "lockSkill": p_lock.group(1) if p_lock else "",
                    })
            int_nm = get_s(r'InternalPartName\s*=\s*"([^"]+)"', "")
            int_mode = get_s(r'InternalBreakMode\s*=\s*"([^"]+)"', "")
            int_max_m = re.search(r"InternalBreakMax\s*=\s*(\d+)", blk)
            int_lock = get_s(r'InternalLockedSkill\s*=\s*"([^"]*)"', "")
            internal_break = None
            if int_nm:
                internal_break = {
                    "name": int_nm,
                    "mode": int_mode or "heavy",
                    "max": int(int_max_m.group(1)) if int_max_m else 3,
                    "lockSkill": int_lock,
                }
            specs[key] = {
                "key": key,
                "chapter": get_s(r'Chapter\s*=\s*"([^"]+)"'),
                "traitName": get_s(r'TraitName\s*=\s*"([^"]+)"'),
                "canonQuote": get_s(r'CanonQuote\s*=\s*"([^"]+)"'),
                "traitDesc": get_s(r'TraitDesc\s*=\s*"([^"]+)"'),
                "counterplay": get_s(r'CounterHint\s*=\s*"([^"]+)"'),
                "structureMode": get_s(r'StructureMode\s*=\s*"([^"]+)"', "mythic_law"),
                "initField": get_s(r'InitFieldKind\s*=\s*"([^"]*)"', ""),
                "parts": parts,
                "internalBreak": internal_break,
                "skillIds": [],
            }

        # Parse ShanHaiBossMoves.<move_id> <- { ... };
        for m in re.finditer(r"::Wuxia\.ShanHaiBossMoves\.(wx_boss_[a-z0-9_]+)\s*<-\s*\{([\s\S]*?)\n\};", src):
            mid, blk = m.group(1), m.group(2)
            get_s = lambda pat, d="": (re.search(pat, blk).group(1) if re.search(pat, blk) else d)
            get_i = lambda pat, d=0: (int(re.search(pat, blk).group(1)) if re.search(pat, blk) else d)
            get_f = lambda pat, d=1.0: (float(re.search(pat, blk).group(1)) if re.search(pat, blk) else d)
            moves[mid] = {
                "id": mid,
                "name": get_s(r'Name\s*=\s*"([^"]+)"'),
                "desc": get_s(r'Desc\s*=\s*"([^"]+)"'),
                "geo": get_s(r'Geo\s*=\s*"([^"]+)"', "cone_3"),
                "ap": get_i(r"AP\s*=\s*(\d+)", 5),
                "qi": get_i(r"Qi\s*=\s*(\d+)", 18),
                "cd": get_i(r"CD\s*=\s*(\d+)", 2),
                "field": get_s(r'Field\s*=\s*"([^"]*)"', ""),
                "hit": get_i(r"Hit\s*=\s*(-?\d+)", 0),
                "dmg": get_f(r"Dmg\s*=\s*([0-9.]+)", 1.0),
                "arm": get_f(r"Arm\s*=\s*([0-9.]+)", 1.0),
                "pen": get_f(r"Pen\s*=\s*([0-9.]+)", 0.0),
                "burnArm": get_i(r"BurnArm\s*=\s*(\d+)", 0),
                "drainQi": get_i(r"DrainQi\s*=\s*(\d+)", 0),
                "drainHP": get_i(r"DrainHP\s*=\s*(\d+)", 0),
                "status": get_s(r'Status\s*=\s*"([^"]*)"', ""),
                "vfx": get_s(r'Vfx\s*=\s*"([^"]+)"', "wx_vfx_05"),
            }

        # Parse BespokeBossSpecs.boss_<key> skill order
        for m in re.finditer(r"::Wuxia\.ShanHai\.BespokeBossSpecs\.boss_([a-z0-9_]+)\s*<-\s*\{([\s\S]*?)\n\};", src):
            key, blk = m.group(1), m.group(2)
            sk_scripts = re.findall(r'"scripts/skills/actives/(wx_boss_[a-z0-9_]+)"', blk)
            if key in specs:
                specs[key]["skillIds"] = sk_scripts

    assert len(specs) == 61, f"Expected 61 catalog Boss specs, got {len(specs)}"
    assert len(moves) == 183, f"Expected 183 catalog Boss moves, got {len(moves)}"
    return specs, moves


# ==============================================================================
# 2. Live 171 Active Skills + Deep Martial Stream Tags + 276 Manuals
# ==============================================================================

STREAM_TAG_MAP = {
    # Sword Sect (`剑宗/气宗/独孤/太极/双剑`)
    "wx_sword_combo":      "同槽三式递进 · 气剑驻场",
    "wx_sword_yunv":       "同槽双式合璧",
    "wx_sword_wanjian":    "万剑归宗 · 拔剑贯通",
    "wx_sword_zixia":      "紫霞剑意 · 气剑驻场",
    "wx_neigong_zixia":    "紫霞先天 · 凝剑归元",
    "wx_sword_dugu":       "独孤九剑 · 六类识兵破招",
    "wx_sword_taiji":      "太极圆转 · 借力打力",
    "wx_neigong_douzhuan": "斗转星移 · 移劲偏转",
    "wx_sword_zhongjian":  "玄铁重剑 · 大巧碎壳",
    # Blade Sect (`居合/狂风/血海/陌刀`)
    "wx_poise_charge":     "居合纳刀 · 藏锋蓄势",
    "wx_saber_xinyue":     "居合拔刀 · 孤月残心",
    "wx_saber_kuangfeng":  "同槽三叠快刀",
    "wx_saber_xuehai":     "血刀魔宗 · 血海刀煞",
    "wx_saber_shishen":    "血海噬血 · 燃煞斩",
    "wx_saber_abi":        "阿鼻血狱 · 沸血狂斩",
    "wx_saber_modao":      "唐军陌刀 · 截骑断冲",
    "wx_saber_fanzhen":    "鸳鸯刀阵 · 协防破境",
    # Spear / Polearm / Staff / Whip
    "wx_spear_bawang":     "霸王挑山 · 挑飞过肩换位",
    "wx_spear_panlong":    "盘龙翻江 · 挑飞过肩换位",
    "wx_spear_guard":      "铁枪拒马 · 连环双迎刺",
    "wx_spear_shouguan":   "镇关铁枪 · 拒马断冲",
    "wx_staff_dagou":      "同槽打狗三诀 · 绊缠无狗",
    "wx_staff_fengmo":     "疯魔百杖 · 焦灼碎甲",
    "wx_whip_suohou":      "软鞭绕盾 · 锁喉拖拽",
    "wx_flail_jinshe":     "金蛇诡弧 · 越盾缠腕",
    # Fist / Heavy / Dagger
    "wx_fist_shock":       "隔山打牛 · 寸劲伏脉",
    "wx_fist_tiegang":     "少室铁罡 · 寸劲叠脉",
    "wx_fist_luohan":      "伏虎罗汉 · 寸劲伏脉",
    "wx_fist_rulai":       "如来神掌 · 引爆寸劲",
    "wx_fist_xianglong":   "亢龙有悔 · 潜龙三叠浪",
    "wx_fist_yiyang":      "一阳指禅 · 隔空破煞净穴",
    "wx_fist_canhezhi":    "参合指劲 · 隔空封穴破招",
    "wx_fist_qishang":     "七伤总诀 · 阴阳化反噬",
    "wx_hama_push":        "白驼金蟾 · 蓄劲崩山扑",
    "wx_hammer_leiting":   "雷霆万钧 · 雷池导电碎壳",
    "wx_hammer_quake":     "震岳裂地 · 碎壳破阵",
    "wx_axe_kaitian":      "开天辟地 · 崩甲余波",
    "wx_dagger_jingke":    "图穷匕见 · 雾隐乘隙绝刺",
    # Ranged / Tangmen / Tactics / Qinggong / Neigong
    "wx_throw_liuyedao":   "唐门暗器 · 布设铁蒺藜",
    "wx_throwing_rain":    "暴雨梨花 · 落钉布阵",
    "wx_throw_fan":        "漫天花雨 · 子母收镖回弹",
    "wx_bow_luori":        "大荒落日 · 射日破阵蒸爆",
    "wx_gun_huolong":      "神机火龙 · 焚泽蒸汽爆",
    "wx_gun_leihuo":       "霹雳雷火 · 雷泽轰爆",
    "wx_tactics_bamen":    "奇门八门 · 辟雾靖沙",
    "wx_tactics_guigu":    "鬼谷纵横 · 勘破大妖蓄势",
    "wx_neigong_hanbing":  "玄冥真气 · 凝霜冻土",
    "wx_qinggong_shuishang": "踏波渡水 · 步生清莲净泽",
    "wx_qinggong_suodi":   "缩地成寸 · 气剑共鸣回气",
}


def parse_live_171_skills(existing_skills: list[dict], icons: dict, alloc_icon_fn) -> list[dict]:
    prev_by_id = {s["id"]: s for s in existing_skills}
    out = []

    for p in sorted((MOD_DIR / "scripts/skills/actives").glob("wx_*.nut")):
        stem = p.stem
        if stem in ("wx_move_base", "wx_shanhai_bespoke_active_base", "wx_boss_cataclysm", "wx_item_bag_gadget", "wx_item_tactical_powder") or stem.startswith("wx_boss_"):
            continue
        src = p.read_text(encoding="utf-8")
        m_id = re.search(r'this\.m\.ID\s*=\s*"(actives\.wx_[a-z0-9_]+)"', src)
        if not m_id:
            continue
        full_id = m_id.group(1)
        prev = prev_by_id.get(full_id, {})

        # Extract top-level create() properties BEFORE WX_ComboForms if present
        combo_idx = src.find("WX_ComboForms")
        head_src = src[:combo_idx] if combo_idx != -1 else src

        def find_s(pat, default=""):
            m = re.search(pat, head_src)
            return strip_bbcode(m.group(1)) if m else default

        def find_i(pat, default=0):
            m = re.search(pat, head_src)
            return int(m.group(1)) if m else default

        name = find_s(r'this\.m\.Name\s*=\s*"([^"]+)"', prev.get("name", stem))
        # Strip `·一式起剑` suffix for clean catalog title while keeping full Stage 1..3 in comboForms!
        clean_title = re.sub(r"·一式.*$", "", name)

        desc = find_s(r'this\.m\.Description\s*=\s*"([^"]+)"', prev.get("desc", ""))
        ap = find_i(r"this\.m\.ActionPointCost\s*=\s*(\d+)", prev.get("ap", 4))
        qi = find_i(r"this\.m\.FatigueCost\s*=\s*(\d+)", prev.get("qi", 15))
        min_r = find_i(r"this\.m\.MinRange\s*=\s*(\d+)", prev.get("minRange", 1))
        max_r = find_i(r"this\.m\.MaxRange\s*=\s*(\d+)", prev.get("maxRange", 1))

        dm_m = re.search(r"this\.m\.DirectDamageMult\s*=\s*([0-9.]+)", head_src)
        if dm_m:
            dm_val = float(dm_m.group(1))
            direct_pct = int(round(dm_val * 100)) if dm_val <= 1.0 else int(round(dm_val))
        else:
            old_dm = prev.get("directMult")
            direct_pct = (int(round(old_dm * 100)) if isinstance(old_dm, (int, float)) and 0 < old_dm <= 1.0 else int(round(old_dm))) if old_dm else None

        cd_m = re.search(r"this\.m\.Cooldown\s*=\s*(\d+)", src)
        cd_use_m = re.search(r"Cooldown\s*=\s*([1-9]\d*)", src[src.find("function onUse"):] if "function onUse" in src else "")
        cd_val = int(cd_use_m.group(1)) if cd_use_m else (int(cd_m.group(1)) if cd_m and int(cd_m.group(1)) > 0 else prev.get("cooldown", 0))

        wpn_m = re.search(r"this\.m\.RequiredWeaponTypes\s*=\s*\[([^\]]*)\]", head_src)
        weapons = re.findall(r'"([^"]+)"', wpn_m.group(1)) if wpn_m else prev.get("weapons", [])

        # Parse WX_ComboForms if present!
        combo_forms = []
        if combo_idx != -1:
            cf_blk = src[combo_idx:]
            cf_arr_m = re.search(r"WX_ComboForms\s*=\s*\[([\s\S]*?)\];", cf_blk)
            if cf_arr_m:
                for fm in re.finditer(r"\{([^\}]+)\}", cf_arr_m.group(1)):
                    fsrc = fm.group(1)
                    fnm = re.search(r'Name\s*=\s*"([^"]+)"', fsrc)
                    fds = re.search(r'Description\s*=\s*"([^"]+)"', fsrc)
                    fap = re.search(r"AP\s*=\s*(\d+)", fsrc)
                    fqi = re.search(r"Fatigue\s*=\s*(\d+)", fsrc)
                    if fnm and fds:
                        combo_forms.append({
                            "name": fnm.group(1),
                            "ap": int(fap.group(1)) if fap else ap,
                            "qi": int(fqi.group(1)) if fqi else qi,
                            "desc": strip_bbcode(fds.group(1)),
                        })

        icon_png = MOD_DIR / "gfx/ui/skills" / f"{stem}.png"
        if not icon_png.exists():
            icon_png = MOD_DIR / "gfx/skills" / f"{stem}.png"
        ik = prev.get("icon") or (alloc_icon_fn(icon_png, trim_alpha=False) if icon_png.exists() else "")

        rec = {
            "id": full_id,
            "key": stem,
            "name": clean_title,
            "desc": desc,
            "ap": ap,
            "qi": qi,
            "minRange": min_r,
            "maxRange": max_r,
            "directMult": direct_pct,
            "cooldown": cd_val,
            "weapons": weapons,
            "icon": ik,
            "manuals": [],
        }
        if prev.get("choreo"):
            rec["choreo"] = prev["choreo"]
        if stem in STREAM_TAG_MAP:
            rec["streamTag"] = STREAM_TAG_MAP[stem]
        if combo_forms:
            rec["comboForms"] = combo_forms
        out.append(rec)

    out.sort(key=lambda x: x["id"])
    assert len(out) == 171, f"Expected 171 playable active skills, got {len(out)}"
    return out


# ==============================================================================
# 3. Combat Statuses & Dynamic TileField Environments (12 -> 24)
# ==============================================================================

EXTRA_STATUSES_AND_FIELDS = [
    {
        "id": "effects.wx_stream_combo_state",
        "kind": "status",
        "name": "流派真意·连段蓄势",
        "iconRel": "skills/wx_sword_combo.png",
        "desc": "国风十三系深度武学流派核心状态容器：承载同槽二/三式递进变招（清风三连剑、玉女双剑、狂风三叠刀、打狗三字诀）、降龙三叠浪、血海刀煞、白驼金蟾蓄劲与铁枪拒马迎刺层数，严守底栏 6~9 主动图标上限。",
        "effects": [
            "同槽连段招式施展后自动翻转同一技能槽为二式/三式终结技，无需占用额外 HUD 栏位。",
            "承载【潜龙叠浪】（亢龙有悔逐浪增威）、【血海刀煞】（吸血爆裂流血）、【金蟾蓄劲】（受击攒层推山反扑）与【铁枪拒马】（每轮容许连续 2 次不中断枪阵迎刺）。",
            "承载四脉真气反应计数（纯阳融霜灼泽、玄阴熄火凝脉、奇诡噬血回气、冲和稳脉）。"
        ],
    },
    {
        "id": "effects.wx_status_hidden_force",
        "kind": "status",
        "name": "寸劲伏脉",
        "iconRel": "skills/wx_fist_shock.png",
        "desc": "少室禅宗与内家拳掌透甲暗劲：由《隔山寸劲掌》《铁罡碎碑拳》《罗汉伏虎拳》打入敌手奇经八脉潜伏不发，叠满 3 层或遇《如来神掌》催动时轰然引爆五脏！",
        "effects": [
            "每叠 1 层代表一道潜伏内劲；叠满 3 层当场引爆无视护甲的脏腑真伤、震散大量内息并施加【内伤】与【失衡】。",
            "施展《隔山寸劲掌》攻击前排肉盾时，内家掌力可无损穿透前排直轰后方 1~2 格敌军并同步种下寸劲伏脉；若身后无人则回震叠加双倍寸劲！"
        ],
    },
    {
        "id": "effects.wx_status_regen_seal",
        "kind": "status",
        "name": "断续封生印",
        "iconRel": "skills/wx_status_poison_dart.png",
        "desc": "五毒秘膏《钦原断续蚀壳膏》、奇门《五毒腐骨瘴气瓮》与《钦原蚀髓毒刺》种下的绝命禁疗咒印，专克山海大妖与邪派药人的强悍再生血脉。",
        "effects": [
            "持续期间锁定目标气血上限水位：回合初一切气血自愈（如朱厌沸血、相柳生肌血首、建木回春）全部归零失效！",
            "彻底封锁山海大妖的濒死逆命复生（如鵸鵌、窫窳、贰负涅槃）与血契分摊。"
        ],
    },
    {
        "id": "effects.wx_status_blade_coating",
        "kind": "status",
        "name": "百工淬刃秘膏",
        "iconRel": "skills/wx_blood_burst.png",
        "desc": "战中消耗 2 AP 将腰包内的门派秘膏（钦原断续蚀壳膏 / 化血透骨寸劲膏 / 纯阳朱砂雷火油 / 子母连环引蛊脂）涂抹于主手兵刃，赋予接下来 4 次有效命中（嵌【幽冥藏毒深血槽】延至 6 次）专属破局神效。",
        "effects": [
            "【钦原断续蚀壳膏】：命中施加 2 回合【断续封生印】禁疗，并蚀穿 14 点身甲与 1 层大妖玄壳。",
            "【化血透骨寸劲膏】：命中流血/破绽/内伤目标引爆旧创追加 8 点无视护甲实伤并挂深层流血。",
            "【纯阳朱砂雷火油】：每击焚毁 16 点身甲，对古墓机关与湘西尸傀追加 14 点纯阳真伤并禁绝亡灵复生。",
            "【子母连环引蛊脂】：命中必种奇毒与子母蛊；宿主阵亡瞬间子蛊跃向 2 格内 2 名敌军传染奇毒与破绽！"
        ],
    },
    # 8 Dynamic TileField Battlefield Environments
    {
        "id": "field.drought_scorch",
        "kind": "field",
        "name": "【天地阵境】赤旱焦土",
        "iconRel": "skills/wx_saber_ranmu.png",
        "desc": "烛九阴炎风、女丑十日射线、金乌毕方讹火或纯阳烈火武学灼烧而成的赤地焦土。",
        "effects": [
            "踏足其上的单位每回合灼损 12 点身甲并蒸干 6 点内息（服【玄冰辟火丸】或修纯阳护体可抵御）。",
            "【元素反应·寒暑蒸汽爆】：遇【玄冥冻土】或玄阴寒冰掌力激撞瞬间化作高温蒸汽爆裂，震损周遭护甲并致失衡！",
            "【元素反应·风助火势】：遇飞廉/烛阴【裂风沙暴】吹拂向顺风邻格蔓延火势；可用《玄霜净地辟秽散》净化。"
        ],
    },
    {
        "id": "field.bitter_mire",
        "kind": "field",
        "name": "【天地阵境】苦毒腐泽",
        "iconRel": "skills/wx_neigong_wudu.png",
        "desc": "相柳断颈腥血、巴蛇盘尾或共工苦泉塌陷而成的剧毒泥沼（《海外北经》：所抵厥为源泽，不辛乃苦）。",
        "effects": [
            "平地踏入者移动受阻，每回合腐蚀 10 点护甲、6 点气血并染【暗器奇毒】；相柳可施展《苦泉漫灌》引爆全场苦泽！",
            "【破局克制】：纯阳内功外功、火龙铳或落日火箭命中苦泽可『烈火焚泽』将其烘干烧灼；轻功《水上漂》与《玄霜净地辟秽散》可踏波净泽。"
        ],
    },
    {
        "id": "field.abyss_frost",
        "kind": "field",
        "name": "【天地阵境】玄冥冻土",
        "iconRel": "skills/wx_neigong_hanbing.png",
        "desc": "烛九阴吹冬霜息、冰夷寒龙或《玄阴寒冰气》冻结而成的极寒冰封地面。",
        "effects": [
            "踏足其上的单位每回合流失 8 点内息、身法降低，移动易滑倒失衡。",
            "【元素反应】：遇赤旱焦土或神机火器轰击立即触发【寒暑蒸汽爆】崩甲震慑；主修纯阳内功出招可融冰化气回补自身 5 点内息。"
        ],
    },
    {
        "id": "field.thunder_pool",
        "kind": "field",
        "name": "【天地阵境】流波雷池",
        "iconRel": "skills/wx_hammer_leiting.png",
        "desc": "东海流波山夔牛雷鼓、应龙蓄水行雷或强良衔蛇引落的紫电导电水泽。",
        "effects": [
            "踏足雷池者每回合遭紫电麻痹震散 8 点内息并削损护甲。",
            "【元素反应·雷泽导电】：重锤《雷霆万钧锤》、霹雳雷火弹或夔牛雷音落入雷池时，闪电沿相连雷池传导轰击所有池中敌军并碎裂大妖甲壳！"
        ],
    },
    {
        "id": "field.mirage_mist",
        "kind": "field",
        "name": "【天地阵境】青丘迷障",
        "iconRel": "skills/wx_smoke_cast.png",
        "desc": "青丘九尾狐火、相柳惑心妖首或奇门烟幕布下的迷魂幻雾。",
        "effects": [
            "雾中视野受阻、远程射击命中大幅折损；刺客施展《图穷匕见》或佩【承影细剑】借迷障掩护可触发潜影绝刺！",
            "【破局克制】：《狮吼功》《夔牛震天鼓》《八门金锁阵》或腰包《白泽破妄醒心香》可一举荡清迷障。"
        ],
    },
    {
        "id": "field.gale_sandstorm",
        "kind": "field",
        "name": "【天地阵境】裂风沙暴",
        "iconRel": "skills/wx_tactics_kuiniu.png",
        "desc": "飞廉御风、烛九阴太古朔风或孟极黄沙卷起的狂风飞沙领域。",
        "effects": [
            "扰乱听风辨位削减弓弩平射命中，并顺风催动【赤旱焦土】向外扩散；奇门《八门金锁阵》可定风靖沙。"
        ],
    },
    {
        "id": "field.sword_node",
        "kind": "field",
        "name": "【武学阵境】驻场气剑",
        "iconRel": "skills/wx_sword_wanjian.png",
        "desc": "剑宗与西岳紫霞一脉由《清风连环剑·二/三式》《紫霞剑气》凝于战场六角格的凌厉气剑残影（持续 3 回合）。",
        "effects": [
            "【万剑归宗拔剑】：施展《万剑归宗诀》时，场上所有属于自身的驻场气剑同时沿六角格直线破空归位，贯穿飞行路径上一切敌军（削甲伤血）并为剑主回补至多 16 点内息！",
            "【步剑共鸣】：施展轻功《缩地成寸》踏过气剑格位时触发剑意共鸣回补内息。"
        ],
    },
    {
        "id": "field.tangmen_trap",
        "kind": "field",
        "name": "【武学阵境】唐门子母钉阵",
        "iconRel": "skills/wx_throw_fan.png",
        "desc": "蜀中唐家堡施展《柳叶飞刀》《暴雨梨花针》或抛洒《拒马铁蒺藜》在目标落点布设的暗器机关钉阵。",
        "effects": [
            "敌军踏入钉阵立即遭受穿刺损甲、流血或失衡阻滞。",
            "【漫天花雨·子母收镖】：施展《漫天花雨》时丝线倒卷拔起场上所有子母暗器钉集中攒刺主目标（每枚追加 10 点实伤，至多 28 点），并当场回收 +1 枚暗器弹药与至多 12 点内息！"
        ],
    },
]


# ==============================================================================
# 4. Forge GearTraits, New Equipment (40 items) & Alchemy (65 Pills + 49 Herbs + 96 Core Imprints)
# ==============================================================================

TIER_ZH = {
    "relic":   "传世器灵",
    "shanhai": "山海神通",
    "beast":   "百工兽魄",
}


def parse_gear_traits_and_forge(icons: dict, alloc_icon_fn) -> tuple[dict, dict, dict, dict, list[dict]]:
    bc_src = (MOD_DIR / "mod_wuxia/config/wx_beast_craft.nut").read_text(encoding="utf-8")

    # 1) Parse GearTraits
    gt_sec = re.search(r"::Wuxia\.Config\.GearTraits\s*<-\s*\{([\s\S]*?)\n\};\s*\n// Non-destructively", bc_src)
    assert gt_sec, "Could not locate GearTraits in wx_beast_craft.nut"
    gt_body = gt_sec.group(1)
    gear_traits = {}
    hdrs = list(re.finditer(r"(?<![A-Za-z0-9_])([a-z0-9_]+)\s*=\s*\{", gt_body))
    for i, m in enumerate(hdrs):
        tid = m.group(1)
        if tid == "Stats":
            continue
        blk = gt_body[m.start(): hdrs[i + 1].start() if i + 1 < len(hdrs) else len(gt_body)]
        tier_m = re.search(r'Tier\s*=\s*"([^"]+)"', blk)
        title_m = re.search(r'Title\s*=\s*"([^"]+)"', blk)
        txt_m = re.search(r'Text\s*=\s*"([^"]+)"', blk)
        if tier_m and title_m and txt_m:
            gear_traits[tid] = {
                "id": tid,
                "tier": TIER_ZH.get(tier_m.group(1), tier_m.group(1)),
                "title": title_m.group(1),
                "text": strip_bbcode(txt_m.group(1)),
            }

    # 2) Parse item -> TraitID maps (RelicWeapons + ShanHaiGear + Beast Gear)
    item_to_trait = {}
    for mp_m in re.finditer(r"local\s+(?:relicTraitMap|gearTraitMap)\s*=\s*\{([\s\S]*?)\n\t\};", bc_src):
        for pair in re.finditer(r'([a-z0-9_]+)\s*=\s*"([^"]+)"', mp_m.group(1)):
            item_to_trait[pair.group(1)] = pair.group(2)

    # Also map the 12 wx_beast_* items to their beast_* traits!
    beast_item_trait_map = {
        "wx_beast_fist":        "beast_fist_leech",
        "wx_beast_sword":       "beast_sword_venom",
        "wx_beast_saber":       "beast_saber_dread",
        "wx_beast_spear":       "beast_spear_acid",
        "wx_beast_hammer":      "beast_hammer_quake",
        "wx_beast_bow":         "beast_bow_venom",
        "wx_beast_shield":      "beast_shield_regen",
        "wx_beast_armor_light": "beast_armor_swift",
        "wx_beast_armor_med":   "beast_armor_scales",
        "wx_beast_armor_heavy": "beast_armor_vital",
        "wx_beast_helm_light":  "beast_helm_owl",
        "wx_beast_helm_heavy":  "beast_helm_ward",
    }
    item_to_trait.update(beast_item_trait_map)

    # 3) Parse BeastMaterials (including 12 wx_pmat_*!) & BossBonusLoot
    bm_sec = re.search(r"::Wuxia\.Config\.BeastMaterials\s*<-\s*\{([\s\S]*?)\n\};", bc_src).group(1)
    mat_names = {}
    pmat_items = []
    for m in re.finditer(r"(wx_(?:p?mat)_[a-z0-9_]+)\s*=\s*\{([\s\S]*?)\n\t\}", bm_sec):
        mid, blk = m.group(1), m.group(2)
        nm = re.search(r'Name\s*=\s*"([^"]+)"', blk).group(1)
        val = int(re.search(r"Value\s*=\s*(\d+)", blk).group(1))
        ic_rel = re.search(r'Icon\s*=\s*"([^"]+)"', blk).group(1)
        desc = strip_bbcode(re.search(r'Description\s*=\s*"([^"]+)"', blk).group(1))
        mat_names[mid] = nm
        if mid.startswith("wx_pmat_"):
            png = resolve_gfx_png(ic_rel)
            pmat_items.append({
                "id": mid,
                "name": nm,
                "group": "part_essence",
                "family": "material",
                "value": val,
                "statsText": f"估值 {val} 两 · 讨伐山海大妖【断肢 / 破壳 / 碎阵核】定向剥取，亦可入八卦丹炉（药力 4）",
                "trait": None,
                "recipe": None,
                "desc": desc,
                "icon": alloc_icon_fn(png) if png else "",
            })

    bbl_sec = re.search(r"::Wuxia\.Config\.BossBonusLoot\s*<-\s*\{([\s\S]*?)\n\};", bc_src).group(1)
    boss_bonus_loot = {}
    for m in re.finditer(r'([a-z0-9_]+)\s*=\s*\{\s*Mat\s*=\s*"([^"]+)"\s*,\s*Trophy\s*=\s*"([^"]+)"\s*\}', bbl_sec):
        bkey, mat_id, tr_id = m.group(1), m.group(2), m.group(3)
        tr_zh = TROPHY_ITEM_ZH.get(tr_id, (tr_id, ""))[0]
        boss_bonus_loot[bkey] = f"{mat_names.get(mat_id, mat_id)} ＋ {tr_zh}"

    # Also parse Herb names from consumables.nut for blueprint recipes
    cons_src = (MOD_DIR / "mod_wuxia/config/consumables.nut").read_text(encoding="utf-8")
    herb_names = {
        m.group(1): m.group(2)
        for m in re.finditer(r'(wx_herb_[a-z0-9_]+)\s*=\s*\{[\s\S]*?Name\s*=\s*"([^"]+)"', cons_src)
    }

    # 4) Parse CraftBlueprints -> map product stem -> recipe dict
    bp_sec = re.search(r"::Wuxia\.Config\.CraftBlueprints\s*<-\s*\{([\s\S]*?)\n\};\s*\n// Declarative Registry for Mid-Battle", bc_src).group(1)
    bp_by_product = {}
    for m in re.finditer(r"(wx_bp_[a-z0-9_]+)\s*=\s*\{([\s\S]*?)\n\t\}", bp_sec):
        blk = m.group(2)
        prod_m = re.search(r'Product\s*=\s*"([^"]+)"', blk)
        cost_m = re.search(r"Cost\s*=\s*(\d+)", blk)
        if not prod_m or not cost_m:
            continue
        prod_id = prod_m.group(1).split("/")[-1]
        ings = []
        src_hints = []
        for im in re.finditer(r'Script\s*=\s*"([^"]+)"\s*,\s*Num\s*=\s*(\d+)', blk):
            stem = im.group(1).split("/")[-1]
            qty = int(im.group(2))
            if stem in mat_names:
                lbl = mat_names[stem] if stem.startswith("wx_pmat_") else f"【百工奇材】{mat_names[stem]}"
                ings.append(f"{lbl} ×{qty}")
                if stem.startswith("wx_pmat_"):
                    src_hints.append("讨伐对应山海秘境首领执行【断首/斩尾/破壳/碎阵核】定向剥取")
            elif stem in herb_names:
                ings.append(f"【山海本草】{herb_names[stem]} ×{qty}")
                src_hints.append("44 大门派山门「本门药庐」或山海秘境采集获得")
            elif stem in TROPHY_ITEM_ZH:
                zh_nm, hint = TROPHY_ITEM_ZH[stem]
                ings.append(f"【异兽奇材】{zh_nm} ×{qty}")
                src_hints.append(hint)
            else:
                ings.append(f"{stem} ×{qty}")
        bp_by_product[prod_id] = {
            "cost": int(cost_m.group(1)),
            "ingredients": ings,
            "source": "；".join(dict.fromkeys(src_hints)) if src_hints else "百工丹坊常备奇材锻造",
        }

    # 5) Parse 13 WeaponAttachments (`wx_wmod_*`), 6 BagGadgets (`wx_gadget_*`), 9 TacticalConsumables (`wx_tact_*`)
    new_eq_items = list(pmat_items)

    wmod_sec = re.search(r"::Wuxia\.Config\.WeaponAttachments\s*<-\s*\{([\s\S]*?)\n\};\s*\n// Declarative Registry for Belt", bc_src).group(1)
    for m in re.finditer(r"(wx_wmod_[a-z0-9_]+)\s*=\s*\{([\s\S]*?)\n\t\}", wmod_sec):
        wid, blk = m.group(1), m.group(2)
        nm = re.search(r'Name\s*=\s*"([^"]+)"', blk).group(1)
        fam = re.search(r'Family\s*=\s*"([^"]+)"', blk).group(1)
        flbl = re.search(r'FamilyLabel\s*=\s*"([^"]+)"', blk).group(1)
        val = int(re.search(r"Value\s*=\s*(\d+)", blk).group(1))
        ic_rel = re.search(r'Icon\s*=\s*"([^"]+)"', blk).group(1)
        btxt = strip_bbcode(re.search(r'BonusText\s*=\s*"([^"]+)"', blk).group(1))
        desc = strip_bbcode(re.search(r'Description\s*=\s*"([^"]+)"', blk).group(1))
        png = resolve_gfx_png(ic_rel)
        new_eq_items.append({
            "id": wid,
            "name": nm,
            "group": "weapon_mod",
            "family": "Hammer" if fam == "Staff" else fam,
            "value": val,
            "statsText": f"适配：{flbl} · 行囊右键无损镶缀（估值 {val} 两）",
            "trait": {"id": wid, "tier": "器魂铭配", "title": flbl, "text": btxt},
            "recipe": bp_by_product.get(wid),
            "desc": desc,
            "icon": alloc_icon_fn(png) if png else "",
        })

    gad_sec = re.search(r"::Wuxia\.Config\.BagGadgets\s*<-\s*\{([\s\S]*?)\n\};", bc_src).group(1)
    for m in re.finditer(r"(wx_gadget_[a-z0-9_]+)\s*=\s*\{([\s\S]*?)\n\t\}", gad_sec):
        gid, blk = m.group(1), m.group(2)
        nm = re.search(r'Name\s*=\s*"([^"]+)"', blk).group(1)
        val = int(re.search(r"Value\s*=\s*(\d+)", blk).group(1))
        ap = int(re.search(r"APCost\s*=\s*(\d+)", blk).group(1))
        qi = int(re.search(r"QiCost\s*=\s*(\d+)", blk).group(1))
        max_r = int(re.search(r"MaxRange\s*=\s*(\d+)", blk).group(1))
        chg = int(re.search(r"MaxCharges\s*=\s*(\d+)", blk).group(1))
        sk_ic = re.search(r'SkillIcon\s*=\s*"([^"]+)"', blk).group(1)
        desc = strip_bbcode(re.search(r'Description\s*=\s*"([^"]+)"', blk).group(1))
        png = resolve_gfx_png(sk_ic) or resolve_gfx_png(re.search(r'Icon\s*=\s*"([^"]+)"', blk).group(1))
        new_eq_items.append({
            "id": gid,
            "name": nm,
            "group": "belt_gadget",
            "family": "Throwing",
            "value": val,
            "statsText": f"腰包奇械 · {ap} AP / {qi} 内息 · 射程 1~{max_r} 格 · 每战 {chg} 发（战后自动整备补满，多件合并占 1 个 HUD 键）",
            "trait": {"id": gid, "tier": "墨家奇械", "title": f"单场 {chg} 发自动整备", "text": desc},
            "recipe": bp_by_product.get(gid),
            "desc": desc,
            "icon": alloc_icon_fn(png, trim_alpha=False) if png else "",
        })

    tact_sec = re.search(r"::Wuxia\.Config\.TacticalConsumables\s*<-\s*\{([\s\S]*?)\n\};\s*\n// Declarative Registry for Inlayable", bc_src).group(1)
    submode_zh = {"tile": "净地改脉奇散（外用零丹毒）", "oral": "战中救急灵散（计入丹毒上限）", "coating": "门派涂刃秘膏（持续4~6击）", "thrown": "丹劫爆裂毒砂（1~3格投掷）"}
    for m in re.finditer(r"(wx_tact_[a-z0-9_]+)\s*=\s*\{([\s\S]*?)\n\t\}", tact_sec):
        tid, blk = m.group(1), m.group(2)
        nm = re.search(r'Name\s*=\s*"([^"]+)"', blk).group(1)
        sm = re.search(r'SubMode\s*=\s*"([^"]+)"', blk).group(1)
        val = int(re.search(r"Value\s*=\s*(\d+)", blk).group(1))
        ap = int(re.search(r"APCost\s*=\s*(\d+)", blk).group(1))
        qi = int(re.search(r"QiCost\s*=\s*(\d+)", blk).group(1))
        chg = int(re.search(r"MaxCharges\s*=\s*(\d+)", blk).group(1))
        ic_rel = re.search(r'Icon\s*=\s*"([^"]+)"', blk).group(1)
        desc = strip_bbcode(re.search(r'Description\s*=\s*"([^"]+)"', blk).group(1))
        png = resolve_gfx_png(ic_rel)
        new_eq_items.append({
            "id": tid,
            "name": nm,
            "group": "tactical_powder",
            "family": "material",
            "value": val,
            "statsText": f"{submode_zh.get(sm, sm)} · {ap} AP / {qi} 内息 · 单瓶可用 {chg} 次（合并收敛于单颗战术灵散 HUD 键）",
            "trait": {"id": tid, "tier": "临阵奇物", "title": submode_zh.get(sm, sm).split("（")[0], "text": desc},
            "recipe": bp_by_product.get(tid),
            "desc": desc,
            "icon": alloc_icon_fn(png) if png else "",
        })

    assert len(new_eq_items) == 40, f"Expected 40 new Forge/Tactical items (12 pmat + 13 wmod + 6 gadget + 9 tact), got {len(new_eq_items)}"
    return gear_traits, item_to_trait, boss_bonus_loot, bp_by_product, new_eq_items


def sync_alchemy_bundle(alchemy: dict, icons: dict, alloc_icon_fn):
    cons_src = (MOD_DIR / "mod_wuxia/config/consumables.nut").read_text(encoding="utf-8")
    alch_src = (MOD_DIR / "mod_wuxia/config/wx_alchemy.nut").read_text(encoding="utf-8")

    # 1) Parse all Formulas in wx_alchemy.nut
    fm_sec = re.search(r"Formulas\s*=\s*\[([\s\S]*?)\n\t\]\n\};", alch_src).group(1)
    formula_by_pill = {}
    pill_name_lookup = {p["id"]: p["name"] for p in alchemy["pills"]}
    for m in re.finditer(r"\{\s*ID\s*=\s*\"(f_[a-z0-9_]+)\"([\s\S]*?)\n\t\t\}", fm_sec):
        fid, blk = m.group(1), m.group(2)
        pid = re.search(r'PillID\s*=\s*"([^"]+)"', blk).group(1)
        cat = re.search(r'Category\s*=\s*"([^"]+)"', blk).group(1)
        yld = int(re.search(r"BaseYield\s*=\s*(\d+)", blk).group(1))
        juns = re.findall(r'"([^"]+)"', re.search(r"JunNatures\s*=\s*\[([^\]]*)\]", blk).group(1))
        min_jp = int(re.search(r"MinJunPotency\s*=\s*(\d+)", blk).group(1))
        req_rare = "RequireRareJun = true" in blk
        min_aux = int(re.search(r"MinAuxCount\s*=\s*(\d+)", blk).group(1))
        t_pot = int(re.search(r"TargetPotency\s*=\s*(\d+)", blk).group(1))
        scost = int(re.search(r"SilverCost\s*=\s*(\d+)", blk).group(1))
        byp_m = re.search(r'BonusByproduct\s*=\s*"([^"]+)"', blk)
        req_core_m = re.search(r'RequiredCoreKey\s*=\s*"([^"]+)"', blk)
        is_mut = "IsHiddenMutation = true" in blk
        note = strip_bbcode(re.search(r'FormulaNote\s*=\s*"([^"]+)"', blk).group(1))
        formula_by_pill[pid] = {
            "id": fid,
            "category": cat,
            "baseYield": yld,
            "junNatures": juns,
            "minJunPotency": min_jp,
            "requireRareJun": req_rare,
            "minAuxCount": min_aux,
            "targetPotency": t_pot,
            "silverCost": scost,
            "byproduct": pill_name_lookup.get(byp_m.group(1), byp_m.group(1)) if byp_m else "",
            "requiredCore": req_core_m.group(1).replace("core:", "") if req_core_m else "",
            "isMutation": is_mut,
            "note": note,
        }

    # 2) Sync all Pills (existing 50 + 15 new = 65!)
    existing_pills = {p["id"]: p for p in alchemy["pills"]}
    deep_sec = re.search(r"local wxDeepPills\s*=\s*\{([\s\S]*?)\n\};", alch_src).group(1)
    hdrs = list(re.finditer(r"(?<![A-Za-z0-9_])(wx_pill_[a-z0-9_]+)\s*=\s*\{", deep_sec))
    for i, m in enumerate(hdrs):
        pid = m.group(1)
        blk = deep_sec[m.start(): hdrs[i + 1].start() if i + 1 < len(hdrs) else len(deep_sec)]
        nm = re.search(r'Name\s*=\s*"([^"]+)"', blk).group(1)
        sub = re.search(r'SubLabel\s*=\s*"([^"]+)"', blk)
        qual = re.search(r'Quality\s*=\s*"([^"]+)"', blk).group(1)
        kind = re.search(r'Kind\s*=\s*"([^"]+)"', blk).group(1)
        val = int(re.search(r"Value\s*=\s*(\d+)", blk).group(1))
        ic_rel = re.search(r'Icon\s*=\s*"([^"]+)"', blk).group(1)
        desc = strip_bbcode(re.search(r'Description\s*=\s*"([^"]+)"', blk).group(1))
        prev = existing_pills.get(pid, {})
        png = resolve_gfx_png(ic_rel)
        ik = prev.get("icon") or (alloc_icon_fn(png) if png else "")
        existing_pills[pid] = {
            "id": pid,
            "name": nm,
            "subLabel": sub.group(1) if sub else prev.get("subLabel", ""),
            "quality": qual,
            "kind": kind,
            "value": val,
            "expAmount": prev.get("expAmount", 0),
            "desc": desc,
            "formula": formula_by_pill.get(pid, prev.get("formula")),
            "icon": ik,
        }

    # Update formulas on base 22 pills too
    for pid, p_obj in existing_pills.items():
        if pid in formula_by_pill:
            p_obj["formula"] = formula_by_pill[pid]

    alchemy["pills"] = list(existing_pills.values())

    # 3) Sync all 49《山海本草》Spirit Herbs!
    hn_sec = re.search(r"HerbNatures\s*=\s*\{([\s\S]*?)\n\t\},", alch_src).group(1)
    herb_natures = {
        m.group(1): (m.group(2), int(m.group(3)))
        for m in re.finditer(r'(wx_[a-z0-9_]+)\s*=\s*\{\s*Nature\s*=\s*"([^"]+)"\s*,\s*Potency\s*=\s*(\d+)\s*\}', hn_sec)
    }

    existing_herbs = {h["id"]: h for h in alchemy["herbs"]}
    # Add `wx_marrow_herb` if not yet in herbs or parse all `wx_herb_*` from consumables.nut
    herb_hdrs = list(re.finditer(r"(?<![A-Za-z0-9_])(wx_(?:herb_[a-z0-9_]+|marrow_herb))\s*=\s*\{", cons_src))
    for i, m in enumerate(herb_hdrs):
        hid = m.group(1)
        blk = cons_src[m.start(): herb_hdrs[i + 1].start() if i + 1 < len(herb_hdrs) else len(cons_src)]
        nm_m = re.search(r'Name\s*=\s*"([^"]+)"', blk)
        if not nm_m or hid not in herb_natures:
            continue
        chap_m = re.search(r'Chapter\s*=\s*"([^"]+)"', blk)
        sub_m = re.search(r'SubLabel\s*=\s*"([^"]+)"', blk)
        qual_m = re.search(r'Quality\s*=\s*"([^"]+)"', blk)
        exp_m = re.search(r"ExpAmount\s*=\s*(\d+)", blk)
        val_m = re.search(r"Value\s*=\s*(\d+)", blk)
        ic_m = re.search(r'Icon\s*=\s*"([^"]+)"', blk)
        desc_m = re.search(r'Description\s*=\s*"([^"]+)"', blk)
        nat, pot = herb_natures[hid]
        prev = existing_herbs.get(hid, {})
        png = resolve_gfx_png(ic_m.group(1)) if ic_m else None
        ik = prev.get("icon") or (alloc_icon_fn(png) if png else "")
        existing_herbs[hid] = {
            "id": hid,
            "name": nm_m.group(1),
            "chapter": chap_m.group(1) if chap_m else prev.get("chapter", "山海经"),
            "subLabel": sub_m.group(1) if sub_m else prev.get("subLabel", ""),
            "quality": qual_m.group(1) if qual_m else prev.get("quality", "sect"),
            "nature": nat,
            "potency": pot,
            "expAmount": int(exp_m.group(1)) if exp_m else prev.get("expAmount", 0),
            "value": int(val_m.group(1)) if val_m else prev.get("value", 400),
            "desc": strip_bbcode(desc_m.group(1)) if desc_m else prev.get("desc", ""),
            "icon": ik,
        }
    alchemy["herbs"] = list(existing_herbs.values())

    # 4) Attach 96 Bespoke CoreImprints + FireModes onto `alchemy`!
    cim_modes_sec = re.search(r"CoreImprintModes\s*=\s*\{([\s\S]*?)\n\t\},", alch_src).group(1)
    cim_modes = {
        m.group(1): strip_bbcode(m.group(2))
        for m in re.finditer(r'([a-z0-9_]+)\s*=\s*\{[^\}]*?PrepDesc\s*=\s*"([^"]+)"', cim_modes_sec)
    }
    cim_sec = re.search(r"CoreImprints\s*=\s*\{([\s\S]*?)\n\t\},", alch_src).group(1)
    core_imprints = {
        m.group(1): {"title": m.group(2), "desc": cim_modes.get(m.group(3), "")}
        for m in re.finditer(r'(wx_core_[a-z0-9_]+)\s*=\s*\{\s*Title\s*=\s*"([^"]+)"\s*,\s*Mode\s*=\s*"([^"]+)"\s*\}', cim_sec)
    }
    for c in alchemy["cores"]:
        if c["id"] in core_imprints:
            c["imprint"] = core_imprints[c["id"]]


# ==============================================================================
# 5.Boss Part-Break Essence Mapping (`wx_craft_combat_bridge.nut`)
# ==============================================================================

def parse_boss_part_essence_map() -> dict[str, dict]:
    cb_src = (MOD_DIR / "mod_wuxia/systems/wx_craft_combat_bridge.nut").read_text(encoding="utf-8")
    bc_src = (MOD_DIR / "mod_wuxia/config/wx_beast_craft.nut").read_text(encoding="utf-8")
    pmat_names = {
        m.group(1): m.group(2)
        for m in re.finditer(r'(wx_pmat_[a-z0-9_]+)\s*=\s*\{\s*ID\s*=\s*"[^"]+"\s*,\s*Name\s*=\s*"([^"]+)"', bc_src)
    }
    out = {}
    sec_m = re.search(r"BossPartEssenceMap\s*<-\s*\{([\s\S]*?)\n\};", cb_src)
    if sec_m:
        for m in re.finditer(r'([a-z0-9_]+)\s*=\s*\{\s*EssenceID\s*=\s*"([^"]+)"\s*,\s*PartLabel\s*=\s*"([^"]+)"', sec_m.group(1)):
            bkey, eid, plbl = m.group(1), m.group(2), m.group(3)
            out[bkey] = {"id": eid, "name": pmat_names.get(eid, eid), "partLabel": plbl}
    return out


# ==============================================================================
# 6. Update 10 System Gameplay Chapters (`DB.guides`)
# ==============================================================================

def update_system_guides(guides: list[dict], pill_cnt: int, herb_cnt: int, eq_cnt: int):
    by_id = {g["id"]: g for g in guides}

    # Chapter 4: 交手博弈、十三系武学流派与天地阵境
    if "sys-combat" in by_id:
        g4 = by_id["sys-combat"]
        g4["title"] = "交手博弈、十三系流派与天地阵境"
        g4["subtitle"] = "9~11 AP 严格阶梯 · 十三系门派真机制 · 同槽连段变招 · 八大动态天地阵境"
        g4["summary"] = "战场交锋围绕行动点（AP）、真气内息、十三类兵装流派回路及八大动态天地阵境展开。严守底栏 6~9 主动图标上限，通过同槽多段递进、气剑驻场、借力打力、隔山打牛与天地元素反应构筑国风武侠博弈。"
        g4["highlights"] = [
            ["同槽递进变招", "清风三剑 / 狂风三刀 / 打狗三诀不撑爆底栏"],
            ["门派专属回路", "气剑万剑归宗 · 独孤破六兵 · 太极借力偏转"],
            ["内家拳掌真劲", "隔山打牛透震后排 · 寸劲伏脉三层爆五脏"],
            ["天地元素反应", "冰火蒸汽爆 · 雷泽导电 · 烈火焚泽 · 子母收镖"],
        ]
        # Replace/upgrade Section 4 to cover Stream Mechanics & TileField Reactions
        if len(g4["sections"]) >= 4:
            g4["sections"][3] = {
                "h": "四、十三系门派深度机制与天地阵境反应",
                "table": {
                    "headers": ["流派宗门体系", "核心战斗循环与代表绝技", "天地阵境 / 状态化学反应"],
                    "rows": [
                        ["剑宗气宗 · 剑冢独孤", "《清风连环剑》《紫霞剑气》布设驻场气剑，《万剑归宗诀》拔剑直线贯通回气；《破刃荡剑式》自动识破敌方 6 类兵装针对拆招", "轻功《缩地成寸》踏过驻场气剑触发共鸣回气；《玄铁重剑》专碎大妖太古玄壳"],
                        ["太和玄门 · 姑苏斗转", "《两仪化劲剑》《斗转星移诀》化解近战攻势，将敌方重击原封偏转轰向其相邻同伙，落单则四两拨千斤甩飞撞障", "配合【回锋架势】与清心镇魂内息，反制群狼与多首凶兽围攻"],
                        ["大漠居合 · 血刀陌刀", "《纳刀蓄势》接《瀚海弯月斩》升格为必中『拔刀·孤月一闪』，斩杀触发每轮 1 次残心归鞘；血刀门叠【血海刀煞】引爆流血吸血（严守 60% 减伤封顶）", "《唐军陌刀》列阵截断马贼与山海巨兽冲锋并追加破招值"],
                        ["霸王杨家枪 · 丐帮棍杖", "《霸王挑山枪》《盘龙棍》将正前敌军挑飞翻越肩头砸入身后格；《铁枪拒马》容许每轮连续 2 次不中断迎刺；《打狗棒法》同槽递进绊→缠→天下无狗", "专断大妖两轮天灾蓄势，挑飞换位直接撕裂敌方前排盾墙"],
                        ["少室拳掌 · 白驼蛤蟆", "《隔山寸劲掌》掌力透体不伤前排直轰后阵 1~2 格，叠满 3 层【寸劲伏脉】或接《如来神掌》爆裂五脏；《一阳指》两格隔空点穴破蓄力兼净友军封穴", "《七伤拳》凭纯阳/调和内功化解自损反噬；《蛤蟆功》受击积攒金蟾蓄劲推山反扑"],
                        ["唐门机括 · 神机奇门", "《柳叶飞刀》《暴雨梨花》落地布设子母铁蒺藜，《漫天花雨》倒卷收镖攒刺并回收 +1 暗器弹药；《八门金锁》辟除迷障沙暴", "火铳/落日弓轰击【玄冥冻土 / 苦毒腐泽】引发寒暑蒸汽爆与烈火焚泽；重锤轰入【流波雷池】全场导电裂甲"]
                    ]
                }
            }

    # Chapter 5: 百草药柜、文武控火与八卦丹炉
    if "sys-alchemy" in by_id:
        g5 = by_id["sys-alchemy"]
        g5["subtitle"] = f"零占格药柜 · 四十九味山海本草 · 文武三段控火 · {pill_cnt}种灵丹与逆命古方"
        g5["summary"] = f"采自五藏山经与海外大荒的 {herb_cnt} 味《山海本草》、96 种携专属本命丹韵的山海内丹及破部精粹自动收纳于零占格「百草药柜」。开启青铜八卦丹炉，可调遣文火/中火/武火三段控火，按六脉生克炼制 {pill_cnt} 种灵丹妙药（含武火逆命奇丹与大妖本命古丹）。"
        g5["highlights"] = [
            ["四十九味本草", "道地奇草、秘境仙株与内丹自动归柜零占格"],
            ["文武三段控火", "文火稳产零丹劫 · 武火催丹霞与阴阳逆命奇丹"],
            ["九十六妖丹丹韵", "每枚大妖内丹入鼎皆烙印独一无二本命神通"],
            ["两药丹毒铁律", "单场备战丹+战中口服散共享 2 药安全阈值"],
        ]

    # Chapter 6: 猎妖破部、五十九名器器灵与百工奇械
    if "sys-forging" in by_id:
        g6 = by_id["sys-forging"]
        g6["title"] = "猎妖破部、名器器灵与百工奇械"
        g6["subtitle"] = f"五十九柄器灵名兵 · 十二种破部精粹 · 十三系兵刃铭配 · 腰包奇械与涂刃秘膏（共{eq_cnt}件）"
        g6["summary"] = "百工丹坊贯通「部位破坏 → 破部精粹 → 器魂铭配/奇门腰包器械/门派涂刃秘膏」完整猎妖武备链：全 37 柄历史传世名兵与 22 柄山海神兵尽数觉醒独立器灵（含干将莫邪雌雄双剑共鸣），配合 13 类主手兵刃铭配、6 件自动整备墨家腰包器械与 9 款战中破局奇散秘膏。"
        g6["highlights"] = [
            ["59 柄觉醒名兵", "37 历史名器 + 22 山海神兵一对一独立器灵"],
            ["12 种破部精粹", "断相柳首/碎玄龟壳/折金乌翼定向剥取怨念材"],
            ["13 类兵刃铭配", "剑穗刀锷枪缨寸劲箍机簧覆盖全部 13 兵种"],
            ["腰包HUD双键收敛", "多件墨家奇械与灵散涂膏自动收敛为 2 颗战术键"],
        ]

    # Chapter 8: 山海六十四大妖：一妖一法相 · 一战一考题
    if "sys-shanhai" in by_id:
        g8 = by_id["sys-shanhai"]
        g8["title"] = "山海六十四大妖：一妖一法相 · 一战一考题"
        g8["subtitle"] = "零公用模板 · 8尊巨蟒真龙躯 / 6尊多首断肢 / 10尊天象阵眼 / 40尊单格本命异律 · 56张专属部位阵眼立绘"
        g8["summary"] = "六十四尊《山海经》秘境大妖彻底摒弃公用排列组合模板，严格考据原典生理构造与神话灾异：仅蜿蜒真龙巨蟒（8尊）占多格躯干、多首共生毒虺（6尊）设独立断首肢体、十日狐灯建木奇阵（10尊）立伴生阵眼，其余40尊战神凶兽皆以纯粹单格承载独立本命异律（四季天道、吞火畏寒、毒饵裂腹、记招拆解、单格破盾/射目/断角），全量配套56张手绘部位与阵眼专属立绘。"
        g8["highlights"] = [
            ["64/64 零重复法相", "逐只手写独立战斗法则 + 194 式六角格几何凶招"],
            ["严谨解剖学占格", "8巨蟒体节 · 6多首断肢 · 10天象阵眼 · 40纯粹单格异律"],
            ["56 张专属部位立绘", "龙躯腹囊 · 相柳四首 · 日冕狐灯建木魔冢全量独立绘制"],
            ["原典差异化考题", "陆吾四时流转 · 祸斗吞火畏寒 · 饕餮引毒裂腹 · 白泽识招"],
        ]


# ==============================================================================
# 7. Sync New Roster Background (`paladin`) & 2 New Jianghu Events
# ==============================================================================

def sync_roster_and_events(bundle: dict, icons: dict, alloc_icon_fn):
    bgs = bundle["roster"]["backgrounds"]
    if not any(x["id"] == "background.paladin" for x in bgs):
        bgs.append({
            "id": "background.paladin",
            "name": "守誓侠客",
            "tier": 2,
            "desc": "恪守先师重誓扶危济困的名门传人，正气凛然，剑胆琴心。",
            "specials": ["正道名门真传"],
            "sectPool": ["松涛心法", "清风剑法"],
            "commonPool": ["吐纳功", "基础剑法"],
            "sampleBios": ["昔年跪于祖师牌位前立下三不杀、三必救重誓，一柄长剑纵横南北未尝负义。"],
        })

    evs = bundle["world"]["events"]
    ev_ids = {e["id"] for e in evs}
    ev04_png = MOD_DIR / "gfx/ui/events/wx_ev_04.png"
    ev16_png = MOD_DIR / "gfx/ui/events/wx_ev_16.png"

    if "event.wx_camp_veteran_mentorship" not in ev_ids:
        evs.append({
            "id": "event.wx_camp_veteran_mentorship",
            "title": "篝火夜话传功",
            "category": "行营传功奇遇",
            "cooldown": 20,
            "triggers": ["夜间宿营或行军途中", "队内拥有三重大成宗师前辈与低辈好苗子"],
            "icon": alloc_icon_fn(ev04_png, trim_alpha=False) if ev04_png.exists() else "",
            "screens": [
                {
                    "id": "A",
                    "text": "夜露渐浓，营盘外松涛轻响。新入行伍不久的后辈仍借着篝火余光反复演练所修武学，只是每逢换气转势之际总滞涩半拍。早已将镇派绝学修至三重大成的宗师前辈拾起一截枯枝缓步上前，问是要细细拆解行气关窍，还是真刀真枪喂招三十合逼出生死潜能？",
                    "effects": [],
                    "options": [
                        {"text": "循序渐进，请前辈拆解招理、指点经脉行气关窍。", "next": "SteadyGuide"},
                        {"text": "真传须经实战！放开手脚喂招三十合，在重压之下破境开窍！", "next": "HardSpar"},
                        {"text": "明日尚需赶路迎敌，点到为止，早些歇息养神罢。", "next": "RestNow"},
                    ],
                },
                {
                    "id": "SteadyGuide",
                    "text": "前辈以枯枝代刃，一招一式引着后进体会吐纳换劲的微妙节点，平日苦思不解的经脉滞塞豁然贯通。",
                    "effects": ["后辈武学火候 +110", "师徒二人心情大振"],
                    "options": [{"text": "名师一言，胜过闭门苦练数月。", "next": ""}],
                },
                {
                    "id": "HardSpar",
                    "text": "篝火旁劲风激荡三十合，后辈虽添了几道淤青轻伤，却在生死一线间彻底悟透招意精髓！",
                    "effects": ["后辈武学火候暴涨 +185", "承受轻微皮肉淤伤"],
                    "options": [{"text": "皮肉吃些苦头，手底真功夫却扎实多了！", "next": ""}],
                },
                {
                    "id": "RestNow",
                    "text": "前辈颔首收枝，嘱其莫贪一夕之功，养足精神以迎明日恶战。",
                    "effects": ["恢复内息心境"],
                    "options": [{"text": "张弛有度，亦是修行。", "next": ""}],
                },
            ],
        })

    if "event.wx_crisis_sanctum_aid" not in ev_ids:
        evs.append({
            "id": "event.wx_crisis_sanctum_aid",
            "title": "山门血书求援",
            "category": "武林浩劫连环",
            "cooldown": 28,
            "triggers": ["后期武林浩劫烽烟期间", "名门或中立宗门山门遭邪派乱军围攻"],
            "icon": alloc_icon_fn(ev16_png, trim_alpha=False) if ev16_png.exists() else "",
            "screens": [
                {
                    "id": "A",
                    "text": "暮色苍茫，背插三支折断黑羽急翎的宗门信使翻身滚落鞍下，递上一封染血求援羽书：大股邪派凶徒与乱军先锋正昼夜猛扑山门外围关隘，恳请贵社拨银粮药材驰援或奇袭敌军侧翼！",
                    "effects": [],
                    "options": [
                        {"text": "同气连枝，岂能坐视！拨出 350 两纹银与军资药材星夜驰援！", "next": "FullAid"},
                        {"text": "命精锐好手轻装奇袭敌军侧翼，解山门外围燃眉之急！", "next": "VanguardAid"},
                        {"text": "乱世兵凶战危，本社尚需保全实力，只能婉言谢绝。", "next": "DeclineAid"},
                    ],
                },
                {
                    "id": "FullAid",
                    "text": "连夜押送银粮良药直抵山门侧隘里应外合击退凶徒。掌门长老亲自迎出山门长揖致谢，自藏经阁取出一卷本门上乘真传秘籍相赠！",
                    "effects": ["银钱 -350 两，医药修材略耗", "宗门交情 +24，声望大涨", "获赠 1 卷本门上乘武学秘籍正本"],
                    "options": [{"text": "侠义立身，患难见真情。", "next": ""}],
                },
                {
                    "id": "VanguardAid",
                    "text": "精锐夜袭焚毁敌寇粮草鹿角逼退围军，实战印证之下武学火候精进，知客长老奉上犒银与两页门派残卷致谢。",
                    "effects": ["领队武学火候 +65（轻伤）", "宗门交情 +16，犒银 +220 两", "获赠 2 页门派秘籍残页"],
                    "options": [{"text": "痛快一战，不辱本社字号！", "next": ""}],
                },
                {
                    "id": "DeclineAid",
                    "text": "信使长叹一声翻身上马冲入夜幕，该宗门与贵社情分略显疏淡。",
                    "effects": ["宗门交情微降"],
                    "options": [{"text": "乱世行路，先顾自家弟兄性命。", "next": ""}],
                },
            ],
        })


# ==============================================================================
# 8. HTML / JS Renderer Upgrades (Idempotent Patches)
# ==============================================================================

def apply_html_js_upgrades(html: str) -> str:
    # 1) Expand EQ_GROUP_LABELS with the 4 new Forge & Tactical categories
    old_eq_lbl = """  const EQ_GROUP_LABELS = {
    relic_weapon: '传世名兵', shanhai_weapon: '山海神兵',
    shanhai_armor: '山海宝甲', shanhai_helmet: '山海宝冠',
    shanhai_shield: '传世神盾', shanhai_accessory: '异宝奇佩',
    beast_gear: '百工奇物兵甲', beast_upgrade: '百工甲胄镶件', beast_material: '猎妖百工奇材'
  };"""
    new_eq_lbl = """  const EQ_GROUP_LABELS = {
    relic_weapon: '传世名兵', shanhai_weapon: '山海神兵',
    shanhai_armor: '山海宝甲', shanhai_helmet: '山海宝冠',
    shanhai_shield: '传世神盾', shanhai_accessory: '异宝奇佩',
    beast_gear: '百工奇物兵甲', beast_upgrade: '百工甲胄镶件',
    weapon_mod: '兵刃器魂铭配', belt_gadget: '墨家腰包器械',
    tactical_powder: '临阵奇散淬膏', part_essence: '山海破部精粹',
    beast_material: '猎妖百工奇材'
  };"""
    if "weapon_mod:" not in html and old_eq_lbl in html:
        html = html.replace(old_eq_lbl, new_eq_lbl, 1)

    # 2) Update Hero Banner subtitle to reflect all updated systems dynamically
    old_hero_p = "<p>涵盖八维根骨与洗经伐髓、1~11级七槽经脉、藏经阁残页融会、轻重装双轨对称、百草药柜与八卦丹炉五十方、百工四阶重锻、九州四十四宗门山门、山海六十四大妖秘境及天下武林大会。</p>"
    new_hero_p = "<p>涵盖八维根骨与洗经伐髓、1~11级七槽经脉、十三系国风武学流派、藏经阁残页融会、四十九味本草与文武控火八卦丹炉、五十九名器器灵与百工破部奇械、九州四十四宗门山门、『一妖一法相』山海六十四大妖秘境及天下武林大会。</p>"
    html = html.replace(old_hero_p, new_hero_p)

    # 3) Upgrade `cardSkill` to display `sk.streamTag` badge
    old_card_sk_sub = """            <div class="card-sub">
              ${proto ? `<span class="badge b-gold">✨ ${esc(proto.sub)}</span>` : (ch.label ? `<span class="badge b-gold">⚡ ${esc(ch.label)}</span>` : '')}"""
    new_card_sk_sub = """            <div class="card-sub">
              ${sk.streamTag ? `<span class="badge b-unique">☯ ${esc(sk.streamTag)}</span>` : ''}
              ${proto ? `<span class="badge b-gold">✨ ${esc(proto.sub)}</span>` : (ch.label ? `<span class="badge b-gold">⚡ ${esc(ch.label)}</span>` : '')}"""
    if "sk.streamTag" not in html and old_card_sk_sub in html:
        html = html.replace(old_card_sk_sub, new_card_sk_sub, 1)

    # 4) Upgrade `cardStatus` & `skills` subtab label for `天地阵境`
    html = html.replace("战斗与调养状态 (${DB.statuses.length})", "战斗状态与天地阵境 (${DB.statuses.length})")
    old_card_st = '<div class="card-title-row"><h3>${esc(st.name)}</h3><span class="badge b-secret">武学状态</span></div>'
    new_card_st = '<div class="card-title-row"><h3>${esc(st.name)}</h3><span class="badge ${st.kind === \'field\' ? \'b-unique\' : \'b-secret\'}">${st.kind === \'field\' ? \'天地阵境\' : \'武学状态\'}</span></div>'
    html = html.replace(old_card_st, new_card_st)

    # 5) Upgrade `alchemy` subtab label (`五十灵丹` -> dynamic `${DB.alchemy.pills.length}`) & `cultivate` filter fix
    html = html.replace("五十灵丹与八卦炉方 (${DB.alchemy.pills.length})", "八卦丹炉灵丹总谱 (${DB.alchemy.pills.length})")
    old_pill_flt = """            if (state.f2 === 'wash' && !p.kind.includes('wash') && !p.kind.includes('protect') && cat !== 'wash') return false;
            else if (state.f2 === 'infuse' && !p.kind.includes('infuse') && cat !== 'infuse') return false;"""
    new_pill_flt = """            if (state.f2 === 'wash' && !p.kind.includes('wash') && !p.kind.includes('protect') && p.id !== 'wx_pill_humai' && p.id !== 'wx_pill_zaohua' && p.id !== 'wx_pill_xisui') return false;
            else if (state.f2 === 'infuse' && !p.kind.includes('infuse') && !(cat === 'cultivate' && !p.kind.includes('wash') && p.id !== 'wx_pill_humai' && p.id !== 'wx_pill_zaohua' && p.id !== 'wx_pill_xisui')) return false;"""
    html = html.replace(old_pill_flt, new_pill_flt)

    # 6) Upgrade `cardCreature` to display `structureLabel` & `fieldLabel` badges on Bosses
    old_cr_sub = """            <div class="card-sub">
              <span class="badge">《${esc(c.chapter)}》</span>
              <span class="badge b-gold">${esc(c.traitName)}</span>
            </div>"""
    new_cr_sub = """            <div class="card-sub">
              <span class="badge">《${esc(c.chapter)}》</span>
              ${c.structureLabel ? `<span class="badge b-unique">${esc(c.structureLabel)}</span>` : ''}
              ${c.fieldLabel ? `<span class="badge b-sect">阵境·${esc(c.fieldLabel)}</span>` : ''}
              <span class="badge b-gold">${esc(c.traitName)}</span>
            </div>"""
    if "c.structureLabel" not in html and old_cr_sub in html:
        html = html.replace(old_cr_sub, new_cr_sub, 1)

    # 7) Upgrade `openModal` (`kind === 'skill'`) to show `streamTag` & `comboForms` progression boxes!
    old_sk_modal = """      setHead(sk.name, `<span class="badge b-dark">${sk.ap} AP</span> <span class="badge b-sect">${sk.qi} 内息</span> <span class="badge">射程 ${sk.minRange}~${sk.maxRange} 格</span> ${ch.label ? `<span class="badge b-gold">⚡ ${esc(ch.label)}</span>` : ''}`, sk.icon, '招');
      bodyEl.innerHTML = `
        ${renderModalSkillVfxHtml(sk)}
        <p class="modal-lead">${esc(sk.desc)}</p>
        <div class="kv-grid">
          <div class="kv-cell"><small>要求兵器大类</small><strong>${esc(formatWeapons(sk.weapons))}</strong></div>
          <div class="kv-cell"><small>消耗行动点 / 内息</small><strong>${sk.ap} AP · ${sk.qi} 内息</strong></div>
          ${sk.directMult !== null ? `<div class="kv-cell"><small>招式基础穿甲率</small><strong>${sk.directMult}%</strong></div>` : ''}
          <div class="kv-cell"><small>调息冷却</small><strong>${sk.cooldown ? `${sk.cooldown} 回合` : '无冷却'}</strong></div>
        </div>"""
    new_sk_modal = """      setHead(sk.name, `<span class="badge b-dark">${sk.ap} AP</span> <span class="badge b-sect">${sk.qi} 内息</span> <span class="badge">射程 ${sk.minRange}~${sk.maxRange} 格</span> ${sk.streamTag ? `<span class="badge b-unique">☯ ${esc(sk.streamTag)}</span>` : ''} ${ch.label ? `<span class="badge b-gold">⚡ ${esc(ch.label)}</span>` : ''}`, sk.icon, '招');
      bodyEl.innerHTML = `
        ${renderModalSkillVfxHtml(sk)}
        <p class="modal-lead">${esc(sk.desc)}</p>
        <div class="kv-grid">
          <div class="kv-cell"><small>要求兵器大类</small><strong>${esc(formatWeapons(sk.weapons))}</strong></div>
          <div class="kv-cell"><small>消耗行动点 / 内息</small><strong>${sk.ap} AP · ${sk.qi} 内息</strong></div>
          ${sk.directMult !== null ? `<div class="kv-cell"><small>招式基础穿甲率</small><strong>${sk.directMult <= 1 ? Math.round(sk.directMult * 100) : sk.directMult}%</strong></div>` : ''}
          <div class="kv-cell"><small>调息冷却</small><strong>${sk.cooldown ? `${sk.cooldown} 回合` : '无冷却'}</strong></div>
        </div>
        ${sk.comboForms && sk.comboForms.length ? `
          <div class="modal-sec">
            <h3>同槽动态递进变招（严守底栏 6~9 图标上限）</h3>
            ${sk.comboForms.map((cf, cfi) => `
              <div class="tier-box ${cfi === sk.comboForms.length - 1 ? 't3' : ''}">
                <strong>第 ${cfi + 1} 段 · 【${esc(cf.name)}】</strong> <span class="badge b-dark">${cf.ap} AP · ${cf.qi} 内息</span>
                <div style="margin-top:4px">${esc(cf.desc)}</div>
              </div>`).join('')}
          </div>` : ''}"""
    if "sk.comboForms" not in html and old_sk_modal in html:
        html = html.replace(old_sk_modal, new_sk_modal, 1)

    # 8) Upgrade `openModal` (`kind === 'pill'` & `kind === 'core'`) for RequiredCore / Mutation / CoreImprints!
    old_pill_fm = """              <p style="margin:0;color:var(--muted)"><strong>丹诀：</strong>${esc(fm.note)}</p>"""
    new_pill_fm = """              ${fm.requiredCore ? `<p style="margin:0 0 6px;color:var(--cinnabar)"><strong>★ 本命君药铁律：</strong>唯以对应大妖内丹（<code>${esc(fm.requiredCore)}</code>）坐镇君药鼎位方能成丹！</p>` : ''}
              ${fm.isMutation ? `<p style="margin:0 0 6px;color:var(--purple)"><strong>☯ 武火逆命奇方：</strong>须以大妖内丹镇鼎，令相克两极辅药在【武火催霞】下零丹劫逆炼化生！</p>` : ''}
              <p style="margin:0;color:var(--muted)"><strong>丹诀：</strong>${esc(fm.note)}</p>"""
    if "fm.requiredCore" not in html and old_pill_fm in html:
        html = html.replace(old_pill_fm, new_pill_fm, 1)

    old_core_modal = """          <div class="kv-cell"><small>丹坊与铸兵用途</small><strong>八卦丹炉高阶君药 / 山海神装核心灵材（估值 ${c.value} 两）</strong></div>
        </div>`;"""
    new_core_modal = """          <div class="kv-cell"><small>丹坊与铸兵用途</small><strong>八卦丹炉高阶君药 / 山海神装核心灵材（估值 ${c.value} 两）</strong></div>
        </div>
        ${c.imprint ? `
          <div class="modal-sec">
            <h3>八卦丹炉君药专属 · 【${esc(c.imprint.title)}】</h3>
            <div class="tier-box t3">以此内丹为君药炼制临阵备战丹时，额外烙印本命妖魂神通：<strong>${esc(c.imprint.desc)}</strong></div>
          </div>` : ''}`;"""
    if "c.imprint" not in html and old_core_modal in html:
        html = html.replace(old_core_modal, new_core_modal, 1)

    # 9) Upgrade `openModal` (`kind === 'creature'`) to display Multi-Tile / Appendage / Totem `c.parts` + `c.fieldLabel` + `c.partEssence`!
    old_cr_modal = """        ${c.counterplay ? `<div class="tier-box"><strong>讨伐克制对策：</strong>${esc(c.counterplay)}</div>` : ''}"""
    new_cr_modal = """        ${c.counterplay ? `<div class="tier-box"><strong>讨伐破局考题：</strong>${esc(c.counterplay)}</div>` : ''}
        ${(c.parts && c.parts.length) ? `
          <div class="modal-sec">
            <h3>法相多格构造与可破坏部位 / 伴生阵眼 (${c.parts.length})</h3>
            ${c.parts.map(pt => `
              <div class="tier-box">
                <strong>【${esc(pt.name)}】</strong> <span class="badge">${esc(pt.stats)}</span>
                <div style="margin-top:3px;color:var(--muted)">${esc(pt.role)}</div>
              </div>`).join('')}
          </div>` : ''}"""
    if "法相多格构造" not in html and old_cr_modal in html:
        html = html.replace(old_cr_modal, new_cr_modal, 1)

    old_parts_sec_end = """                <div style="margin-top:3px;color:var(--muted)">${esc(pt.role)}</div>
              </div>`).join('')}
          </div>` : ''}"""
    new_parts_sec_end = """                <div style="margin-top:3px;color:var(--muted)">${esc(pt.role)}</div>
              </div>`).join('')}
          </div>` : ''}
        ${c.internalBreak ? `
          <div class="modal-sec">
            <h3>单格本命破招关窍（纯粹单格 · 不生虚假副体）</h3>
            <div class="tier-box t3">
              <strong>【${esc(c.internalBreak.name)}】</strong>
              <span class="badge b-unique">${esc(c.internalBreak.modeLabel || '定向破招')} ×${c.internalBreak.max} 击</span>
              ${c.internalBreak.lockSkillName ? `<span class="badge b-secret">击破封印：${esc(c.internalBreak.lockSkillName)}</span>` : ''}
              <div style="margin-top:4px;color:var(--muted)">该大妖严格立于单格之内，无需额外多格占位；以对应克制兵刃或招式累计命中本体 ${c.internalBreak.max} 次即可击碎此本命依仗${c.internalBreak.lockSkillName ? `并永久封印【${esc(c.internalBreak.lockSkillName)}】` : ''}！</div>
            </div>
          </div>` : ''}"""
    if "单格本命破招关窍" not in html and old_parts_sec_end in html:
        html = html.replace(old_parts_sec_end, new_parts_sec_end, 1)

    old_cr_loot = """            ${c.core && c.core.id ? `<div class="link-pills"><button type="button" class="link-pill" data-open="core:${esc(c.core.id)}">必掉内丹：${esc(c.core.name)} →</button>${c.core.bonusMat ? `<span class="badge b-gold">必掉奇材：${esc(c.core.bonusMat)}</span>` : ''}</div>` : ''}"""
    new_cr_loot = """            ${c.core && c.core.id ? `<div class="link-pills"><button type="button" class="link-pill" data-open="core:${esc(c.core.id)}">必掉内丹：${esc(c.core.name)} →</button>${c.core.bonusMat ? `<span class="badge b-gold">必掉奇材：${esc(c.core.bonusMat)}</span>` : ''}${c.partEssence ? `<button type="button" class="link-pill" data-open="equip:${esc(c.partEssence.id)}">破部剥取：${esc(c.partEssence.name)}（碎${esc(c.partEssence.partLabel)}）→</button>` : ''}</div>` : ''}"""
    if "c.partEssence" not in html and old_cr_loot in html:
        html = html.replace(old_cr_loot, new_cr_loot, 1)

    return html


# ==============================================================================
# Main Pipeline
# ==============================================================================

def collect_referenced_icons(obj, out: set[str]):
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k == "icons":
                continue
            if k == "icon" and isinstance(v, str) and v.startswith("i") and v[1:].isdigit():
                out.add(v)
            else:
                collect_referenced_icons(v, out)
    elif isinstance(obj, list):
        for item in obj:
            collect_referenced_icons(item, out)


def parse_live_manuals_full(skill_names: dict[str, str]) -> dict[str, dict]:
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
            assert len(gs_lists) == 3 and len(sums) == 3, f"Unexpected tier count on {mid}"
            tiers = []
            for ti in range(3):
                sk_ids = re.findall(r'"([^"]+)"', gs_lists[ti])
                sk_objs = [
                    {"id": sid, "name": skill_names.get(sid, VANILLA_SKILL_NAMES.get(sid, sid))}
                    for sid in sk_ids
                ]
                tiers.append({"skills": sk_objs, "summary": strip_bbcode(sums[ti])})
            out[mid] = {
                "tiers": tiers,
                "hasPermAP": "PermanentAPBonus" in body,
                "hasWash": "GrantWashChance" in body,
            }
    assert len(out) == 276, f"Expected 276 live manuals, got {len(out)}"
    return out


def main():
    html = WIKI_PATH.read_text(encoding="utf-8")
    m = re.search(r'(<script[^>]*id="wx-bundle"[^>]*>)(.*?)(</script>)', html, re.S)
    assert m, "Could not locate <script id='wx-bundle'> in 山海武侠.html"
    bundle = json.loads(m.group(2))
    icons = bundle["icons"]
    max_idx = max(int(k[1:]) for k in icons.keys() if k.startswith("i") and k[1:].isdigit())
    uri_to_key = {v: k for k, v in icons.items()}

    def alloc_icon(png_path: Path | None, trim_alpha: bool = True) -> str:
        nonlocal max_idx
        if png_path is None or not png_path.exists():
            return ""
        uri = encode_webp_48(png_path, trim_alpha=trim_alpha)
        if uri in uri_to_key:
            return uri_to_key[uri]
        max_idx += 1
        ik = f"i{max_idx}"
        icons[ik] = uri
        uri_to_key[uri] = ik
        return ik

    # ------------------------------------------------------------------
    # Step A: Sync 64 Bespoke《山海经》Bosses & 194 Geometric Boss Moves
    # ------------------------------------------------------------------
    cat_specs, cat_moves = parse_61_catalog_bosses()
    gear_traits, item_to_trait, boss_bonus_loot, bp_by_product, new_eq_items = parse_gear_traits_and_forge(icons, alloc_icon)
    part_ess_map = parse_boss_part_essence_map()

    vfx_pool = set((bundle.get("vfxAssets") or {}).get("vfx", {}).keys())
    fx_pool = set((bundle.get("vfxAssets") or {}).get("fx", {}).keys())

    synced_bosses = 0
    total_boss_moves = 0
    for c in bundle["bestiary"]["creatures"]:
        if c.get("kind") != "boss":
            continue
        key = c["key"]
        if key in FLAGSHIP_3_BOSSES:
            fs = FLAGSHIP_3_BOSSES[key]
            c["classicQuote"] = fs["canonQuote"]
            c["traitName"] = fs["traitName"]
            c["traitDesc"] = fs["traitDesc"]
            c["counterplay"] = fs["counterplay"]
            c["structureMode"] = fs["structureMode"]
            c["structureLabel"] = STRUCTURE_LABELS[fs["structureMode"]]
            c["fieldLabel"] = FIELD_LABELS.get(fs["initField"], "")
            c["parts"] = [dict(p) for p in fs["parts"]]
            c.pop("internalBreak", None)
            sk_list = []
            for sk in fs["skills"]:
                sk_copy = dict(sk)
                if sk_copy["fx"] not in fx_pool:
                    sk_copy["fx"] = "wx_fx_claw_slash"
                if sk_copy["vfx"] not in vfx_pool:
                    sk_copy["vfx"] = "wx_vfx_05"
                sk_list.append(sk_copy)
            c["skills"] = sk_list
        else:
            assert key in cat_specs, f"Missing Boss key in catalogs: {key}"
            sp = cat_specs[key]
            c["classicQuote"] = sp["canonQuote"]
            c["traitName"] = sp["traitName"]
            c["traitDesc"] = sp["traitDesc"]
            c["counterplay"] = sp["counterplay"]
            c["structureMode"] = sp["structureMode"]
            c["structureLabel"] = STRUCTURE_LABELS.get(sp["structureMode"], "原典异律法相")
            c["fieldLabel"] = FIELD_LABELS.get(sp["initField"], "")

            # Build readable parts list with locked skill name!
            parts_out = []
            for pt in sp["parts"]:
                lock_sid = pt["lockSkill"].replace("actives.", "")
                lock_nm = cat_moves[lock_sid]["name"] if lock_sid in cat_moves else ""
                if sp["structureMode"] == "segments":
                    role_txt = f"多格联动躯干体节；重兵击碎鳞甲即永久封印【{lock_nm}】" if lock_nm else "多格联动躯干体节，分担并护持主躯阵位"
                elif sp["structureMode"] == "appendages":
                    role_txt = f"独立受击肢体；斩断即永久封印凶招【{lock_nm}】并反噬主躯" if lock_nm else "独立受击肢体，维持首领凶威再生"
                else:
                    role_txt = "伴生领域阵眼图腾；优先拔除可削去首领护体减伤障并破除阵域"
                parts_out.append({
                    "name": pt["name"],
                    "brush": pt.get("brush", ""),
                    "stats": pt["stats"],
                    "role": role_txt,
                })
            c["parts"] = parts_out
            if sp.get("internalBreak"):
                ib = dict(sp["internalBreak"])
                ib_sid = ib["lockSkill"].replace("actives.", "")
                ib["lockSkillName"] = cat_moves[ib_sid]["name"] if ib_sid in cat_moves else ""
                c["internalBreak"] = ib
            else:
                c.pop("internalBreak", None)

            sk_list = []
            for mid in sp["skillIds"]:
                mv = cat_moves[mid]
                rng_lbl, anim_mode, anim_lbl, anim_col, fx_k, vfx_fb = GEO_META.get(mv["geo"], GEO_META["cone_3"])
                vfx_k = mv["vfx"] if mv["vfx"] in vfx_pool else vfx_fb
                if vfx_k not in vfx_pool:
                    vfx_k = "wx_vfx_05"
                if fx_k not in fx_pool:
                    fx_k = "wx_fx_claw_slash"

                dmg_bits = []
                if abs(mv["dmg"] - 1.0) > 0.01:
                    dmg_bits.append(f"伤害{int(round(mv['dmg'] * 100))}%")
                if mv["burnArm"] > 0:
                    dmg_bits.append(f"灼损{mv['burnArm']}甲")
                elif abs(mv["arm"] - 1.0) > 0.01:
                    dmg_bits.append(f"破甲{int(round(mv['arm'] * 100))}%")
                if mv["drainHP"] > 0:
                    dmg_bits.append(f"汲血{mv['drainHP']}")

                effs = []
                if mv["status"] and mv["status"] in STATUS_LABELS_SHORT:
                    effs.append(STATUS_LABELS_SHORT[mv["status"]])
                if mv["drainQi"] > 0:
                    effs.append(f"散气{mv['drainQi']}")
                if mv["field"] and mv["field"] in FIELD_LABELS:
                    effs.append(f"铺设{FIELD_LABELS[mv['field']]}")
                for pt in sp["parts"]:
                    if pt["lockSkill"] == f"actives.{mid}":
                        effs.append("破部即封印")
                        break
                if sp.get("internalBreak") and sp["internalBreak"].get("lockSkill") == f"actives.{mid}":
                    effs.append("破绽击破即封印")

                sk_list.append({
                    "id": mid,
                    "name": mv["name"],
                    "ap": mv["ap"],
                    "qi": mv["qi"],
                    "cd": mv["cd"],
                    "range": rng_lbl,
                    "dmg": " · ".join(dmg_bits) if dmg_bits else "领域异术",
                    "effects": effs[:4],
                    "desc": mv["desc"],
                    "animMode": anim_mode,
                    "animLabel": anim_lbl,
                    "animColor": anim_col,
                    "fx": fx_k,
                    "vfx": vfx_k,
                })
            c["skills"] = sk_list

        if c.get("core") and key in boss_bonus_loot:
            c["core"]["bonusMat"] = boss_bonus_loot[key]
        if key in part_ess_map:
            c["partEssence"] = part_ess_map[key]

        # Refresh Boss tags cleanly (prune stale multi-part count tags first!)
        new_tags = [c["structureLabel"]]
        if c["fieldLabel"]:
            new_tags.append(f"灾域·{c['fieldLabel']}")
        if c["parts"]:
            new_tags.append(f"实占{1 + len(c['parts'])}格(含{len(c['parts'])}部位/阵眼)")
        elif c.get("internalBreak"):
            new_tags.append(f"单格破招·{c['internalBreak']['name']}")
        else:
            new_tags.append("单格独尊法相")
        stale_prefixes = ("含", "实占", "单格破招·", "单格独尊", "多体节", "多首", "伴生领域", "天象领域", "原典异律", "单格本命", "灾域·")
        for ot in c.get("tags", []):
            if any(ot.startswith(pf) for pf in stale_prefixes):
                continue
            if ot not in new_tags and len(new_tags) < 5:
                new_tags.append(ot)
        c["tags"] = new_tags

        synced_bosses += 1
        total_boss_moves += len(c["skills"])

    assert synced_bosses == 64, f"Expected 64 synced Bosses, got {synced_bosses}"
    assert total_boss_moves == 194, f"Expected 194 bespoke Boss moves, got {total_boss_moves}"
    print(f"[1/5] Synced {synced_bosses}/64 Bespoke《山海经》Bosses & {total_boss_moves}/194 geometric Boss moves!")

    # ------------------------------------------------------------------
    # Step B: Sync 171 Active Skills, 276 Manuals & 24 Statuses/Fields
    # ------------------------------------------------------------------
    skills_171 = parse_live_171_skills(bundle["skills"], icons, alloc_icon)
    sk_by_id = {s["id"]: s for s in skills_171}
    sk_names = {s["id"]: s["name"] for s in skills_171}

    live_manuals = parse_live_manuals_full(sk_names)
    for man in bundle["manuals"]:
        mid = man["id"]
        m_live = live_manuals[mid]
        man["hasPermAP"] = m_live["hasPermAP"]
        man["hasWash"] = m_live["hasWash"]
        first_unlock: dict[str, int] = {}
        for ti in range(3):
            man["levels"][ti]["skills"] = m_live["tiers"][ti]["skills"]
            man["levels"][ti]["summary"] = m_live["tiers"][ti]["summary"]
            for s_entry in m_live["tiers"][ti]["skills"]:
                sid = s_entry["id"]
                if sid in sk_by_id and sid not in first_unlock:
                    first_unlock[sid] = ti + 1
        for sid, u_tier in first_unlock.items():
            sk_by_id[sid]["manuals"].append({"id": mid, "name": man["name"], "tier": u_tier})

    bundle["skills"] = skills_171

    # Sync Statuses + Dynamic TileField Environments
    st_by_id = {st["id"]: st for st in bundle["statuses"]}
    for st in st_by_id.values():
        st.setdefault("kind", "status")
    for ex in EXTRA_STATUSES_AND_FIELDS:
        png = resolve_gfx_png(ex["iconRel"])
        prev = st_by_id.get(ex["id"], {})
        st_by_id[ex["id"]] = {
            "id": ex["id"],
            "kind": ex["kind"],
            "name": ex["name"],
            "desc": ex["desc"],
            "effects": ex["effects"],
            "icon": prev.get("icon") or (alloc_icon(png, trim_alpha=False) if png else ""),
        }
    bundle["statuses"] = list(st_by_id.values())
    print(f"[2/5] Synced {len(bundle['skills'])} Deep-Stream Active Moves, {len(bundle['manuals'])} Manuals & {len(bundle['statuses'])} Statuses/Fields!")

    # ------------------------------------------------------------------
    # Step C: Sync 59 Relic Spirits & 40 New Forge/Tactical Items
    # ------------------------------------------------------------------
    eq_by_id = {eq["id"]: eq for eq in bundle["equipment"]}
    updated_traits = 0
    for eid, eq in eq_by_id.items():
        tid = item_to_trait.get(eid)
        if tid and tid in gear_traits:
            eq["trait"] = gear_traits[tid]
            updated_traits += 1
        if eid in bp_by_product and not eq.get("recipe"):
            eq["recipe"] = bp_by_product[eid]

    for neq in new_eq_items:
        if neq["id"] in eq_by_id:
            prev_eq = eq_by_id[neq["id"]]
            if prev_eq.get("icon") and not neq["icon"]:
                neq["icon"] = prev_eq["icon"]
            if prev_eq.get("setInfo"):
                neq["setInfo"] = prev_eq["setInfo"]
        eq_by_id[neq["id"]] = neq

    bundle["equipment"] = list(eq_by_id.values())
    print(f"[3/5] Synced {updated_traits} bespoke GearTraits across Relics/ShanHai/Beast gear; total equipment = {len(bundle['equipment'])}!")

    # ------------------------------------------------------------------
    # Step D: Sync 65 Pills, 49 Spirit Herbs & 96 Core Imprints
    # ------------------------------------------------------------------
    sync_alchemy_bundle(bundle["alchemy"], icons, alloc_icon)
    print(f"[4/5] Synced Alchemy: {len(bundle['alchemy']['pills'])} Pills, {len(bundle['alchemy']['herbs'])} Spirit Herbs, {len(bundle['alchemy']['cores'])} Cores (with 96 CoreImprints)!")

    # ------------------------------------------------------------------
    # Step E: Sync Roster, Events, 10 System Guides & Stats
    # ------------------------------------------------------------------
    sync_roster_and_events(bundle, icons, alloc_icon)
    update_system_guides(
        bundle["guides"],
        pill_cnt=len(bundle["alchemy"]["pills"]),
        herb_cnt=len(bundle["alchemy"]["herbs"]),
        eq_cnt=len(bundle["equipment"]),
    )

    # Enrich both 60fps theaters (sub-part tail sprites, multi-hex layouts, HiDPI multi-frame kinetic strips)
    packed_tails = enrich_bundle_for_theaters(bundle, MOD_DIR, cat_specs, cat_moves)
    print(f"[4b/5] Enriched Theater V2: packed {packed_tails} sub-part tail sprites & wired multi-frame kinetic sequences!")

    # Garbage-collect unused icon keys
    used_icons: set[str] = set()
    collect_referenced_icons(bundle, used_icons)
    for k in [k for k in list(icons.keys()) if k not in used_icons]:
        del icons[k]

    bundle["stats"].update({
        "manuals": len(bundle["manuals"]),
        "skills": len(bundle["skills"]),
        "statuses": len(bundle["statuses"]),
        "equipment": len(bundle["equipment"]),
        "equipmentSets": len(bundle.get("equipmentSets", [])),
        "pills": len(bundle["alchemy"]["pills"]),
        "herbs": len(bundle["alchemy"]["herbs"]),
        "cores": len(bundle["alchemy"]["cores"]),
        "creatures": len(bundle["bestiary"]["creatures"]),
        "sects": len(bundle["sects"]["list"]),
        "origins": len(bundle["roster"]["origins"]),
        "backgrounds": len(bundle["roster"]["backgrounds"]),
        "retinue": len(bundle["roster"]["retinue"]),
        "events": len(bundle["world"]["events"]),
        "contracts": len(bundle["world"]["contracts"]),
        "ambitions": len(bundle["world"]["ambitions"]),
        "gambling": len(bundle["world"]["gambling"]),
        "icons": len(bundle["icons"]),
    })

    new_bundle_json = json.dumps(bundle, ensure_ascii=False, separators=(",", ":"))
    new_html = html[: m.start(2)] + new_bundle_json + html[m.end(2) :]
    new_html = apply_html_js_upgrades(new_html)
    new_html = upgrade_html_theaters(new_html)

    WIKI_PATH.write_text(new_html, encoding="utf-8")
    size_mb = WIKI_PATH.stat().st_size / (1024 * 1024)
    print(f"[5/5] Wrote updated 山海武侠.html ({size_mb:.2f} MiB) | stats = {bundle['stats']}")


if __name__ == "__main__":
    main()
