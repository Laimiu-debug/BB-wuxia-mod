#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Canonical 171-Skill Next-Gen Wuxia Kinetic Choreography Catalog Builder (40-Atlas Expansion A!)
Single source of truth for BOTH:
  1. In-Game Squirrel Registry: `mod_wuxia/mod_wuxia/systems/wx_kinetic_catalog.nut`
  2. Wiki Encyclopedia Theater:  `tools/wx_kinetic_catalog.json`

Spreads all 171 Wuxia active skills evenly across ALL 40 handcrafted 10-12 frame painterly
sequences (`wx_kinetic_0..6.brush`, 430 total sprites), 16 space-making 60 FPS actor motions,
5 hitstop target reactions, and 10 elemental visual themes — with STRICT ZERO exact visual collisions!
"""

import collections
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
MOD_DIR = ROOT / "mod_wuxia"
ACTIVES_DIR = MOD_DIR / "scripts" / "skills" / "actives"
VFX_NUT = MOD_DIR / "mod_wuxia" / "systems" / "wx_vfx_system.nut"
OUT_NUT = MOD_DIR / "mod_wuxia" / "systems" / "wx_kinetic_catalog.nut"
OUT_JSON = ROOT / "tools" / "wx_kinetic_catalog.json"

THEME_META = {
    "cyan":      {"col": "#52e4ff", "core": "#e4fcff", "tint": [255, 255, 255]},
    "gold":      {"col": "#ffcb42", "core": "#fff4c6", "tint": [255, 240, 190]},
    "fire":      {"col": "#ff6828", "core": "#ffe5be", "tint": [255, 224, 185]},
    "violet":    {"col": "#b67cff", "core": "#f3e8ff", "tint": [235, 210, 255]},
    "celestial": {"col": "#ffe88e", "core": "#f6fcff", "tint": [255, 255, 255]},
    "crimson":   {"col": "#ff364c", "core": "#ffe2e6", "tint": [255, 195, 200]},
    "jade":      {"col": "#2ce89a", "core": "#dcfff0", "tint": [200, 255, 232]},
    "frost":     {"col": "#68dcff", "core": "#eefbff", "tint": [218, 248, 255]},
    "venom":     {"col": "#58eb44", "core": "#e8ffd8", "tint": [215, 255, 198]},
    "ink":       {"col": "#a6b4e6", "core": "#eef2ff", "tint": [224, 230, 255]},
}

VALID_SEQS = {
    # Page 0..3 (Original 22)
    "wx_kin_sword_slash", "wx_kin_dragon_surge", "wx_kin_flame_cleave",
    "wx_kin_flame_pillar", "wx_kin_thunder_bolt", "wx_kin_celestial_beam",
    "wx_kin_blood_arc", "wx_kin_spear_drill", "wx_kin_whirl_cyclone",
    "wx_kin_claw_rend", "wx_kin_whip_lash", "wx_kin_shadow_cross",
    "wx_kin_buddha_palm", "wx_kin_frost_burst", "wx_kin_venom_mire",
    "wx_kin_earth_shatter", "wx_kin_arrow_barrage", "wx_kin_sonic_wave",
    "wx_kin_taiji_seal", "wx_kin_golden_dome", "wx_kin_qinggong_gust",
    "wx_kin_soul_vortex",
    # Page 4..6 (Expansion A: 18 Brand-New Handcrafted 10-Frame Sequences!)
    "wx_kin_lotus_poke", "wx_kin_fist_flurry", "wx_kin_giant_axe",
    "wx_kin_phoenix_spear", "wx_kin_bamboo_bind", "wx_kin_flying_knives",
    "wx_kin_peacock_fan", "wx_kin_cannon_blast", "wx_kin_war_banner",
    "wx_kin_xuanwu_aegis", "wx_kin_tidal_wave", "wx_kin_gold_needles",
    "wx_kin_snow_step", "wx_kin_warp_seal", "wx_kin_smoke_cloud",
    "wx_kin_prism_burst", "wx_kin_sword_rain", "wx_kin_moon_crescent",
}

VALID_MOTIONS = {
    "kin_dash_combo3", "kin_dragon_palm", "kin_flame_leap", "kin_thunder_slam",
    "kin_celestial_beam", "kin_spear_drill", "kin_whirl_spin", "kin_shadow_blink",
    "kin_heavy_chop", "kin_upcut_launch", "kin_whip_snap", "kin_bow_draw",
    "kin_throw_fan", "kin_stance_channel", "kin_roar_pulse", "kin_qg_vault",
}

VALID_REACTS = {
    "kin_hit_heavy", "kin_hit_launch", "kin_hit_electro", "kin_hit_frost", "kin_hit_venom",
}

# 40 Distinct Archetype Defaults (1-to-1 aligned with our 40 multi-frame sequences!)
ARCH_DEFAULTS = {
    "sword_combo3": {
        "seq": "wx_kin_sword_slash", "seq2": "", "motion": "kin_dash_combo3", "react": "kin_hit_heavy",
        "impactMs": 405, "releaseMs": 540, "totalMs": 880, "hits": [175, 290, 405], "ground": "",
        "tag": "后撤蓄锋 → 3段交叉水墨剑弧 → 穿身越背残影 + 顿帧",
        "beats": ["1. 后撤蓄锋", "2. 交叉疾斩", "3. 穿身顿帧", "4. 残影收剑"],
    },
    "dragon_surge": {
        "seq": "wx_kin_dragon_surge", "seq2": "", "motion": "kin_dragon_palm", "react": "kin_hit_launch",
        "impactMs": 420, "releaseMs": 560, "totalMs": 980, "hits": [420], "ground": "scorch",
        "tag": "马步聚气内收 → 12帧水墨真龙跨格冲袭 → 冲击波裂地",
        "beats": ["1. 沉步蓄劲", "2. 真龙出渊", "3. 穿阵击飞", "4. 双波余威"],
    },
    "flame_leap": {
        "seq": "wx_kin_flame_cleave", "seq2": "wx_kin_flame_pillar", "motion": "kin_flame_leap", "react": "kin_hit_launch",
        "impactMs": 410, "releaseMs": 555, "totalMs": 1020, "hits": [410], "ground": "scorch",
        "tag": "纵身跃空(+78px) → 10帧烈焰重劈 → 冲天炎柱 + 焦痕裂地",
        "beats": ["1. 纵身拔葱", "2. 凌空火刃", "3. 炎柱冲天", "4. 焦痕余烬"],
    },
    "thunder_slam": {
        "seq": "wx_kin_thunder_bolt", "seq2": "", "motion": "kin_thunder_slam", "react": "kin_hit_electro",
        "impactMs": 405, "releaseMs": 560, "totalMs": 1020, "hits": [405], "ground": "scorch",
        "tag": "举兵引霄蓄雷 → 10帧九天分叉狂雷劈顶 → 碎石触电震屏",
        "beats": ["1. 引雷蓄势", "2. 紫雷贯顶", "3. 触电爆石", "4. 雷环余震"],
    },
    "celestial_beam": {
        "seq": "wx_kin_celestial_beam", "seq2": "", "motion": "kin_celestial_beam", "react": "kin_hit_heavy",
        "impactMs": 425, "releaseMs": 575, "totalMs": 1000, "hits": [425], "ground": "",
        "tag": "凌空后飘聚芒 → 飞剑/剑气合流 → 10帧白虹贯日 + 一闪切屏",
        "beats": ["1. 凌空凝芒", "2. 气虹聚势", "3. 白虹一闪", "4. 星芒流散"],
    },
    "blood_cleave": {
        "seq": "wx_kin_blood_arc", "seq2": "", "motion": "kin_heavy_chop", "react": "kin_hit_heavy",
        "impactMs": 385, "releaseMs": 525, "totalMs": 920, "hits": [385], "ground": "scorch",
        "tag": "血煞压步蓄刀 → 10帧修罗泼墨血月大弧 → 猩红血雾飞溅",
        "beats": ["1. 血煞凝锋", "2. 血月横空", "3. 裂甲溅血", "4. 残血归元"],
    },
    "spear_drill": {
        "seq": "wx_kin_spear_drill", "seq2": "", "motion": "kin_spear_drill", "react": "kin_hit_heavy",
        "impactMs": 365, "releaseMs": 500, "totalMs": 860, "hits": [365], "ground": "",
        "tag": "沉腰后拉蓄枪 → 10帧螺旋破音穿甲长虹 → 音爆环贯穿",
        "beats": ["1. 沉腰拉锋", "2. 螺旋贯刺", "3. 破音透甲", "4. 枪花收势"],
    },
    "whirl_cyclone": {
        "seq": "wx_kin_whirl_cyclone", "seq2": "", "motion": "kin_whirl_spin", "react": "kin_hit_launch",
        "impactMs": 370, "releaseMs": 515, "totalMs": 900, "hits": [220, 370], "ground": "",
        "tag": "跨步旋身起势 → 10帧360°八方水墨罡风龙卷 → 群敌击退",
        "beats": ["1. 旋身借势", "2. 罡风骤起", "3. 龙卷横扫", "4. 气浪散开"],
    },
    "claw_rend": {
        "seq": "wx_kin_claw_rend", "seq2": "", "motion": "kin_shadow_blink", "react": "kin_hit_heavy",
        "impactMs": 355, "releaseMs": 495, "totalMs": 860, "hits": [230, 355], "ground": "",
        "tag": "诡步突袭扑身 → 10帧三道水墨裂空鬼爪/兽爪撕裂 → 暗影残片",
        "beats": ["1. 伏身突袭", "2. 利爪破风", "3. 三痕撕裂", "4. 煞气弥散"],
    },
    "whip_lash": {
        "seq": "wx_kin_whip_lash", "seq2": "", "motion": "kin_whip_snap", "react": "kin_hit_heavy",
        "impactMs": 365, "releaseMs": 505, "totalMs": 880, "hits": [365], "ground": "",
        "tag": "后扯抖腕聚劲 → 10帧灵蛇S形波浪长鞭抽击 → 鞭梢音爆星闪",
        "beats": ["1. 抖腕蓄鞭", "2. 灵蛇游走", "3. 鞭梢炸响", "4. 锁敌余波"],
    },
    "shadow_cross": {
        "seq": "wx_kin_shadow_cross", "seq2": "", "motion": "kin_shadow_blink", "react": "kin_hit_heavy",
        "impactMs": 360, "releaseMs": 500, "totalMs": 860, "hits": [210, 360], "ground": "",
        "tag": "魅影瞬步贴背 → 10帧紫电/寒光十字交剪绝杀 → 十字星爆顿帧",
        "beats": ["1. 隐身闪步", "2. 一线起斩", "3. 十字交爆", "4. 残影退身"],
    },
    "buddha_palm": {
        "seq": "wx_kin_buddha_palm", "seq2": "", "motion": "kin_dragon_palm", "react": "kin_hit_launch",
        "impactMs": 415, "releaseMs": 560, "totalMs": 980, "hits": [415], "ground": "scorch",
        "tag": "禅音合十聚金罡 → 10帧如来巨掌从天压落 → 梵文金环震地",
        "beats": ["1. 梵音合十", "2. 巨掌降世", "3. 镇岳击飞", "4. 金莲余光"],
    },
    "frost_burst": {
        "seq": "wx_kin_frost_burst", "seq2": "", "motion": "kin_upcut_launch", "react": "kin_hit_frost",
        "impactMs": 390, "releaseMs": 530, "totalMs": 940, "hits": [390], "ground": "frost",
        "tag": "极寒吐纳凝霜 → 10帧玄冥七棱冰刺破地冲起 → 寒霜冻土碎晶",
        "beats": ["1. 凝霜蓄寒", "2. 冰刺破土", "3. 寒狱冻结", "4. 冰晶纷飞"],
    },
    "venom_mire": {
        "seq": "wx_kin_venom_mire", "seq2": "", "motion": "kin_throw_fan", "react": "kin_hit_venom",
        "impactMs": 380, "releaseMs": 520, "totalMs": 940, "hits": [380], "ground": "venom",
        "tag": "催毒聚瘴起势 → 10帧五毒碧磷瘴柱喷涌 → 剧毒腐池与毒泡",
        "beats": ["1. 催毒起瘴", "2. 瘴柱翻涌", "3. 蚀骨毒爆", "4. 腐池弥漫"],
    },
    "earth_shatter": {
        "seq": "wx_kin_earth_shatter", "seq2": "", "motion": "kin_flame_leap", "react": "kin_hit_launch",
        "impactMs": 410, "releaseMs": 555, "totalMs": 980, "hits": [410], "ground": "scorch",
        "tag": "蓄力腾跃重砸 → 10帧裂地崩山巨岩地刺冲霄 → 焦痕裂隙飞石",
        "beats": ["1. 蓄力腾起", "2. 重兵砸地", "3. 裂岩冲霄", "4. 碎石尘烟"],
    },
    "heavy_cleave": {
        "seq": "wx_kin_flame_cleave", "seq2": "", "motion": "kin_heavy_chop", "react": "kin_hit_launch",
        "impactMs": 380, "releaseMs": 520, "totalMs": 900, "hits": [380], "ground": "",
        "tag": "沉身蓄力挥弧 → 10帧210°宽幅炽刃重斩 → 破甲气浪",
        "beats": ["1. 沉身蓄势", "2. 大弧劈落", "3. 重击顿帧", "4. 气劲余波"],
    },
    "arrow_barrage": {
        "seq": "wx_kin_arrow_barrage", "seq2": "", "motion": "kin_bow_draw", "react": "kin_hit_heavy",
        "impactMs": 330, "releaseMs": 470, "totalMs": 860, "hits": [260, 330], "ground": "",
        "tag": "拉弦扣矢瞄准 → 10帧破空流矢连珠齐射 → 穿透星爆",
        "beats": ["1. 拉弦蓄势", "2. 流星破空", "3. 贯甲星爆", "4. 尾焰消散"],
    },
    "sonic_wave": {
        "seq": "wx_kin_sonic_wave", "seq2": "", "motion": "kin_roar_pulse", "react": "kin_hit_heavy",
        "impactMs": 360, "releaseMs": 500, "totalMs": 900, "hits": [360], "ground": "",
        "tag": "丹田提气聚声 → 10帧四叠金刚雷音气浪扩散 → 震魂失衡",
        "beats": ["1. 丹田提气", "2. 声波初绽", "3. 四叠震荡", "4. 余音绕梁"],
    },
    "taiji_seal": {
        "seq": "wx_kin_taiji_seal", "seq2": "", "motion": "kin_stance_channel", "react": "kin_hit_heavy",
        "impactMs": 350, "releaseMs": 490, "totalMs": 880, "hits": [350], "ground": "",
        "tag": "云手划圆借劲 → 10帧阴阳鱼太极八卦旋转法阵 → 清浊二气环",
        "beats": ["1. 云手划圆", "2. 阴阳初分", "3. 八卦流转", "4. 化劲归元"],
    },
    "golden_dome": {
        "seq": "wx_kin_golden_dome", "seq2": "", "motion": "kin_stance_channel", "react": "kin_hit_heavy",
        "impactMs": 290, "releaseMs": 420, "totalMs": 820, "hits": [290], "ground": "",
        "tag": "沉气顿足聚罡 → 10帧少林金钟梵罩凝结护体 → 圣光涟漪",
        "beats": ["1. 沉气顿足", "2. 金罡凝罩", "3. 梵钟震鸣", "4. 护体常驻"],
    },
    "qinggong_gust": {
        "seq": "wx_kin_qinggong_gust", "seq2": "", "motion": "kin_qg_vault", "react": "kin_hit_heavy",
        "impactMs": 180, "releaseMs": 380, "totalMs": 740, "hits": [180], "ground": "",
        "tag": "提气轻身起纵 → 10帧水墨流风步影腾挪 → 落点清风残影",
        "beats": ["1. 提气轻身", "2. 踏风腾跃", "3. 掠影落位", "4. 余风消散"],
    },
    "soul_vortex": {
        "seq": "wx_kin_soul_vortex", "seq2": "", "motion": "kin_stance_channel", "react": "kin_hit_heavy",
        "impactMs": 330, "releaseMs": 470, "totalMs": 880, "hits": [330], "ground": "",
        "tag": "逆脉催动黑渊 → 10帧漩涡气海强噬真元 → 奇点吞吐归元",
        "beats": ["1. 吐纳引势", "2. 气漩成型", "3. 吞吐归元", "4. 余韵生辉"],
    },
    # === Expansion A: 18 Brand-New Bespoke Archetypes! ===
    "lotus_poke": {
        "seq": "wx_kin_lotus_poke", "seq2": "", "motion": "kin_spear_drill", "react": "kin_hit_heavy",
        "impactMs": 355, "releaseMs": 490, "totalMs": 860, "hits": [230, 355], "ground": "",
        "tag": "兰花拂柳认穴 → 10帧七星点穴金莲法印绽放 → 封脉停滞",
        "beats": ["1. 拂柳认穴", "2. 七星点落", "3. 金莲绽放", "4. 经脉锁闭"],
    },
    "fist_flurry": {
        "seq": "wx_kin_fist_flurry", "seq2": "", "motion": "kin_dash_combo3", "react": "kin_hit_heavy",
        "impactMs": 365, "releaseMs": 505, "totalMs": 880, "hits": [180, 275, 365], "ground": "",
        "tag": "踏步沉肩蓄拳 → 10帧六叠残影连珠冲拳爆气 → 拳环炸裂",
        "beats": ["1. 踏步沉肩", "2. 残影连捶", "3. 寸劲爆环", "4. 收拳定势"],
    },
    "giant_axe": {
        "seq": "wx_kin_giant_axe", "seq2": "", "motion": "kin_heavy_chop", "react": "kin_hit_launch",
        "impactMs": 400, "releaseMs": 545, "totalMs": 960, "hits": [400], "ground": "scorch",
        "tag": "双手高举巨兵 → 10帧盘古开天厚重青铜巨钺劈裂 → 裂隙震屏",
        "beats": ["1. 举钺开山", "2. 巨弧压落", "3. 裂地断盾", "4. 焦土飞石"],
    },
    "phoenix_spear": {
        "seq": "wx_kin_phoenix_spear", "seq2": "", "motion": "kin_spear_drill", "react": "kin_hit_heavy",
        "impactMs": 375, "releaseMs": 515, "totalMs": 900, "hits": [240, 375], "ground": "",
        "tag": "抖枪如凤展翅 → 10帧炽翼凰影五枪攒刺贯穿 → 炎羽爆散",
        "beats": ["1. 抖枪展翼", "2. 凰影合流", "3. 五枪攒刺", "4. 烈羽余辉"],
    },
    "bamboo_bind": {
        "seq": "wx_kin_bamboo_bind", "seq2": "", "motion": "kin_whip_snap", "react": "kin_hit_heavy",
        "impactMs": 360, "releaseMs": 500, "totalMs": 880, "hits": [360], "ground": "",
        "tag": "青竹横扫盘根 → 10帧翠影竹节交缠与利叶飞斩 → 缠足封步",
        "beats": ["1. 青竹起势", "2. 盘根缠足", "3. 竹叶飞斩", "4. 借势卸兵"],
    },
    "flying_knives": {
        "seq": "wx_kin_flying_knives", "seq2": "", "motion": "kin_throw_fan", "react": "kin_hit_heavy",
        "impactMs": 325, "releaseMs": 465, "totalMs": 840, "hits": [210, 325], "ground": "",
        "tag": "反手扣腕旋掷 → 10帧七星旋转柳叶飞刀扇雨 → 寒芒爆点",
        "beats": ["1. 扣腕藏刃", "2. 七刀齐旋", "3. 寒星穿甲", "4. 流光消散"],
    },
    "peacock_fan": {
        "seq": "wx_kin_peacock_fan", "seq2": "", "motion": "kin_throw_fan", "react": "kin_hit_heavy",
        "impactMs": 350, "releaseMs": 495, "totalMs": 900, "hits": [220, 290, 350], "ground": "",
        "tag": "机括轻启展开 → 10帧孔雀开屏九道七彩神芒翎眼 → 绚丽绝杀",
        "beats": ["1. 机括初启", "2. 七彩开屏", "3. 翎眼齐爆", "4. 虹屑纷飞"],
    },
    "cannon_blast": {
        "seq": "wx_kin_cannon_blast", "seq2": "", "motion": "kin_bow_draw", "react": "kin_hit_launch",
        "impactMs": 360, "releaseMs": 510, "totalMs": 960, "hits": [360], "ground": "scorch",
        "tag": "引燃赤硝轰发 → 10帧霹雳火球烈焰蘑菇云轰天爆 → 硝烟焦坑",
        "beats": ["1. 引信蓄硝", "2. 火球轰发", "3. 烈焰炸裂", "4. 硝烟焦坑"],
    },
    "war_banner": {
        "seq": "wx_kin_war_banner", "seq2": "", "motion": "kin_roar_pulse", "react": "kin_hit_heavy",
        "impactMs": 300, "releaseMs": 430, "totalMs": 840, "hits": [300], "ground": "",
        "tag": "竖旗顿地扬威 → 10帧赤金帅旗猎猎招展与军令波 → 振奋全军",
        "beats": ["1. 擎旗高呼", "2. 帅旗立地", "3. 金波传令", "4. 军威浩荡"],
    },
    "xuanwu_aegis": {
        "seq": "wx_kin_xuanwu_aegis", "seq2": "", "motion": "kin_stance_channel", "react": "kin_hit_heavy",
        "impactMs": 290, "releaseMs": 420, "totalMs": 820, "hits": [290], "ground": "",
        "tag": "沉盾踏罡结壁 → 10帧六棱玄武龟甲金碧盾阵锁合 → 铜墙铁壁",
        "beats": ["1. 沉盾定桩", "2. 六棱甲生", "3. 龟壁合锁", "4. 金芒流转"],
    },
    "tidal_wave": {
        "seq": "wx_kin_tidal_wave", "seq2": "", "motion": "kin_upcut_launch", "react": "kin_hit_launch",
        "impactMs": 385, "releaseMs": 525, "totalMs": 920, "hits": [385], "ground": "",
        "tag": "蓄劲掀起墨涛 → 10帧沧溟巨浪卷沫拍岸崩击 → 水花四溅",
        "beats": ["1. 沉步起潮", "2. 巨浪翻卷", "3. 怒涛拍岸", "4. 沧溟水雾"],
    },
    "gold_needles": {
        "seq": "wx_kin_gold_needles", "seq2": "", "motion": "kin_stance_channel", "react": "kin_hit_heavy",
        "impactMs": 300, "releaseMs": 430, "totalMs": 820, "hits": [300], "ground": "",
        "tag": "指捻九根金针 → 10帧五气金针渡穴聚光生机环 → 祛毒回春",
        "beats": ["1. 九针悬空", "2. 金针归穴", "3. 生机绽放", "4. 碧金余暖"],
    },
    "snow_step": {
        "seq": "wx_kin_snow_step", "seq2": "", "motion": "kin_qg_vault", "react": "kin_hit_frost",
        "impactMs": 210, "releaseMs": 400, "totalMs": 780, "hits": [210], "ground": "frost",
        "tag": "踏霜轻跃起雪 → 10帧六棱冰晶雪花阵翩然盛开 → 踏雪无痕",
        "beats": ["1. 提气凌霜", "2. 雪花初绽", "3. 晶羽掠影", "4. 寒雪落定"],
    },
    "warp_seal": {
        "seq": "wx_kin_warp_seal", "seq2": "", "motion": "kin_qg_vault", "react": "kin_hit_heavy",
        "impactMs": 200, "releaseMs": 390, "totalMs": 780, "hits": [200], "ground": "",
        "tag": "步踏星斗缩地 → 10帧星门折跃光环与空间裂隙 → 咫尺天涯",
        "beats": ["1. 星盘启门", "2. 空间折叠", "3. 瞬步现身", "4. 星环收拢"],
    },
    "smoke_cloud": {
        "seq": "wx_kin_smoke_cloud", "seq2": "", "motion": "kin_throw_fan", "react": "kin_hit_venom",
        "impactMs": 320, "releaseMs": 460, "totalMs": 860, "hits": [320], "ground": "",
        "tag": "抛洒奇门墨烟 → 10帧浓墨烟云翻卷障目隐形 → 诡影难测",
        "beats": ["1. 抬手掷烟", "2. 墨云爆开", "3. 浓烟障目", "4. 幽雾弥漫"],
    },
    "prism_burst": {
        "seq": "wx_kin_prism_burst", "seq2": "", "motion": "kin_dragon_palm", "react": "kin_hit_launch",
        "impactMs": 395, "releaseMs": 540, "totalMs": 940, "hits": [395], "ground": "scorch",
        "tag": "五行真气逆冲 → 10帧五色奇劲裂体放射爆裂 → 震伤脏腑",
        "beats": ["1. 五气逆聚", "2. 奇劲初裂", "3. 五行爆散", "4. 乱劲余震"],
    },
    "sword_rain": {
        "seq": "wx_kin_sword_rain", "seq2": "", "motion": "kin_celestial_beam", "react": "kin_hit_heavy",
        "impactMs": 410, "releaseMs": 555, "totalMs": 980, "hits": [220, 315, 410], "ground": "",
        "tag": "凌空剑指苍穹 → 10帧天河十二流光飞剑倾盆而降 → 剑阵贯地",
        "beats": ["1. 剑指苍穹", "2. 天河剑雨", "3. 万剑贯地", "4. 剑芒余震"],
    },
    "moon_crescent": {
        "seq": "wx_kin_moon_crescent", "seq2": "", "motion": "kin_upcut_launch", "react": "kin_hit_heavy",
        "impactMs": 370, "releaseMs": 510, "totalMs": 880, "hits": [370], "ground": "",
        "tag": "反撩起势映月 → 10帧银金孤月冷辉逆弧掠刃 → 星尘漫散",
        "beats": ["1. 沉刃映月", "2. 孤月逆弧", "3. 冷辉透骨", "4. 星尘收刃"],
    },
}

# Handcrafted Zero-Collision 171-Skill Registry spread evenly across ALL 40 multi-frame sequences!
EXPLICIT_171 = {
    # === 5 Flagship Prototypes (Untouched signature feel!) ===
    "wx_sword_combo":     ("sword_combo3",  "cyan",      "连剑", {"impactMs": 410, "releaseMs": 545, "totalMs": 880, "hits": [180, 295, 410], "shakePow": 6}),
    "wx_fist_xianglong":  ("dragon_surge",  "gold",      "绝学", {"impactMs": 420, "releaseMs": 560, "totalMs": 980, "hits": [420], "shakePow": 9}),
    "wx_saber_ranmu":     ("flame_leap",    "fire",      "烈阳", {"impactMs": 410, "releaseMs": 560, "totalMs": 1020, "hits": [410], "shakePow": 8}),
    "wx_hammer_leiting":  ("thunder_slam",  "violet",    "天雷", {"impactMs": 405, "releaseMs": 565, "totalMs": 1040, "hits": [405], "shakePow": 9}),
    "wx_sword_tianwai":   ("celestial_beam","celestial", "孤本", {"impactMs": 430, "releaseMs": 585, "totalMs": 1020, "hits": [430], "shakePow": 8}),

    # === 1. SWORD FAMILY (21 additional skills) ===
    "wx_acupoint_strike": ("lotus_poke",    "jade",      "点穴", {"tint": [180, 255, 224]}),
    "wx_sword_counter":   ("taiji_seal",    "cyan",      "守势", {"impactMs": 280, "releaseMs": 410, "totalMs": 780}),
    "wx_sword_pierce":    ("spear_drill",   "cyan",      "破甲", {"motion": "kin_spear_drill", "tint": [210, 248, 255]}),
    "wx_sword_duoming":   ("shadow_cross",  "violet",    "幻剑", {"seq2": "wx_kin_sword_slash", "motion": "kin_dash_combo3", "hits": [175, 295, 405]}),
    "wx_sword_cuixin":    ("spear_drill",   "jade",      "摧心", {"tint": [145, 255, 210]}),
    "wx_sword_dugu":      ("sword_rain",    "celestial", "破剑", {"seq2": "wx_kin_shadow_cross", "motion": "kin_dash_combo3", "tint": [255, 242, 185]}),
    "wx_sword_taiji":     ("taiji_seal",    "cyan",      "太极", {"seq2": "wx_kin_sword_slash", "motion": "kin_whirl_spin"}),
    "wx_sword_zhongjian": ("giant_axe",     "gold",      "重剑", {"seq2": "wx_kin_earth_shatter", "motion": "kin_heavy_chop", "tint": [255, 220, 140]}),
    "wx_sword_feixian":   ("sword_rain",    "celestial", "飞仙", {"seq2": "wx_kin_celestial_beam", "motion": "kin_celestial_beam", "tint": [215, 245, 255]}),
    "wx_sword_wanjian":   ("sword_rain",    "cyan",      "万剑", {"seq2": "wx_kin_whirl_cyclone", "motion": "kin_celestial_beam", "hits": [220, 320, 415]}),
    "wx_sword_yunv":      ("moon_crescent", "frost",     "双剑", {"motion": "kin_dash_combo3", "tint": [215, 244, 255]}),
    "wx_sword_canhe":     ("lotus_poke",    "cyan",      "参合", {"seq2": "wx_kin_taiji_seal", "motion": "kin_dash_combo3", "tint": [175, 248, 255]}),
    "wx_sword_bixue":     ("tidal_wave",    "jade",      "碧水", {"seq2": "wx_kin_sword_slash", "tint": [140, 255, 215]}),
    "wx_sword_xuanbing":  ("frost_burst",   "frost",     "玄冰", {"seq2": "wx_kin_sword_slash", "motion": "kin_upcut_launch"}),
    "wx_sword_miejian":   ("moon_crescent", "gold",      "灭剑", {"motion": "kin_flame_leap", "tint": [255, 232, 148], "ground": "scorch"}),
    "wx_sword_zixia":     ("celestial_beam","violet",    "紫霞", {"tint": [226, 170, 255]}),
    "wx_sword_zhenwu":    ("sword_rain",    "gold",      "真武", {"seq2": "wx_kin_taiji_seal", "motion": "kin_celestial_beam", "tint": [255, 234, 155]}),
    "wx_sword_huifeng":   ("moon_crescent", "cyan",      "回锋", {"motion": "kin_dash_combo3", "tint": [185, 250, 255]}),
    "wx_sword_kuangfeng": ("flying_knives", "jade",      "落英", {"seq2": "wx_kin_sword_slash", "motion": "kin_dash_combo3", "tint": [255, 185, 215]}),
    "wx_sword_qinggang":  ("spear_drill",   "frost",     "青釭", {"tint": [195, 248, 255]}),
    "wx_sword_yinsha":    ("smoke_cloud",   "ink",       "阴煞", {"seq2": "wx_kin_claw_rend", "motion": "kin_shadow_blink", "tint": [190, 175, 255]}),

    # === 2. SABER FAMILY (20 additional skills) ===
    "wx_poise_charge":    ("moon_crescent", "gold",      "蓄势", {"motion": "kin_stance_channel", "impactMs": 280, "releaseMs": 410, "totalMs": 780}),
    "wx_saber_cleave":    ("heavy_cleave",  "fire",      "重刀", {"tint": [255, 215, 165]}),
    "wx_saber_duanyue":   ("giant_axe",     "gold",      "断岳", {"motion": "kin_flame_leap", "tint": [255, 218, 128]}),
    "wx_saber_sweep":     ("tidal_wave",    "cyan",      "狂澜", {"seq2": "wx_kin_whirl_cyclone", "motion": "kin_whirl_spin", "tint": [155, 240, 255]}),
    "wx_saber_kuangfeng": ("sword_combo3",  "jade",      "狂风", {"motion": "kin_dash_combo3", "tint": [180, 255, 220]}),
    "wx_saber_fanzhen":   ("shadow_cross",  "frost",     "冰火", {"seq": "wx_kin_flame_cleave", "seq2": "wx_kin_frost_burst", "motion": "kin_dash_combo3", "ground": "frost"}),
    "wx_saber_modao":     ("moon_crescent", "gold",      "陌刀", {"seq2": "wx_kin_giant_axe", "motion": "kin_upcut_launch", "tint": [255, 224, 150]}),
    "wx_saber_xuehai":    ("blood_cleave",  "crimson",   "血海", {"seq2": "wx_kin_soul_vortex"}),
    "wx_saber_huoyandao": ("cannon_blast",  "fire",      "炎刀", {"seq2": "wx_kin_flame_cleave", "motion": "kin_heavy_chop", "tint": [255, 210, 155]}),
    "wx_saber_abi":       ("blood_cleave",  "crimson",   "阿鼻", {"seq2": "wx_kin_whirl_cyclone", "motion": "kin_whirl_spin", "hits": [220, 390]}),
    "wx_saber_xinyue":    ("moon_crescent", "celestial", "孤月", {"tint": [255, 232, 165]}),
    "wx_saber_shishen":   ("blood_cleave",  "crimson",   "噬神", {"seq2": "wx_kin_claw_rend", "motion": "kin_shadow_blink"}),
    "wx_saber_podao":     ("giant_axe",     "fire",      "破刀", {"seq2": "wx_kin_flame_cleave", "motion": "kin_heavy_chop", "tint": [255, 188, 125]}),
    "wx_saber_kuanglan":  ("whirl_cyclone", "gold",      "霸刀", {"seq2": "wx_kin_moon_crescent", "tint": [255, 215, 115]}),
    "wx_saber_bagua":     ("taiji_seal",    "jade",      "八卦", {"seq2": "wx_kin_moon_crescent", "motion": "kin_whirl_spin"}),
    "wx_saber_tuxiong":   ("claw_rend",     "crimson",   "屠熊", {"motion": "kin_heavy_chop", "tint": [255, 130, 120]}),
    "wx_saber_zhanlang":  ("tidal_wave",    "cyan",      "斩浪", {"seq2": "wx_kin_sonic_wave", "motion": "kin_upcut_launch"}),
    "wx_saber_baji":      ("fist_flurry",   "gold",      "八极", {"seq2": "wx_kin_spear_drill", "motion": "kin_dragon_palm", "tint": [255, 215, 120]}),
    "wx_saber_lingnan":   ("bamboo_bind",   "jade",      "滚堂", {"seq2": "wx_kin_shadow_cross", "motion": "kin_shadow_blink", "tint": [145, 255, 195]}),
    "wx_saber_chiyou":    ("giant_axe",     "crimson",   "兵主", {"seq": "wx_kin_blood_arc", "seq2": "wx_kin_giant_axe", "motion": "kin_flame_leap"}),

    # === 3. FIST / PALM / FINGER / CLAW FAMILY (23 additional skills) ===
    "wx_fist_jab":        ("fist_flurry",   "gold",      "冲拳", {"impactMs": 345, "hits": [185, 345]}),
    "wx_fist_shock":      ("fist_flurry",   "cyan",      "寸劲", {"seq2": "wx_kin_sonic_wave", "motion": "kin_dragon_palm", "tint": [175, 245, 255]}),
    "wx_fist_acupoint":   ("lotus_poke",    "gold",      "拈花", {"tint": [255, 232, 155]}),
    "wx_fist_disarm":     ("taiji_seal",    "cyan",      "夺兵", {"seq2": "wx_kin_whip_lash", "motion": "kin_whip_snap"}),
    "wx_fist_grapple":    ("whip_lash",     "gold",      "擒龙", {"seq2": "wx_kin_dragon_surge", "tint": [255, 215, 110]}),
    "wx_fist_jingang":    ("buddha_palm",   "gold",      "如来", {}),
    "wx_fist_taiji":      ("taiji_seal",    "jade",      "云手", {"motion": "kin_whirl_spin", "tint": [180, 255, 232]}),
    "wx_fist_qishang":    ("prism_burst",   "crimson",   "七伤", {"seq2": "wx_kin_sonic_wave", "tint": [255, 225, 230]}),
    "wx_fist_jiuyin":     ("claw_rend",     "violet",    "九阴", {}),
    "wx_fist_yiyang":     ("celestial_beam","gold",      "一阳", {"seq2": "wx_kin_lotus_poke", "tint": [255, 224, 125]}),
    "wx_fist_xuanming":   ("frost_burst",   "frost",     "玄冥", {}),
    "wx_hama_push":       ("venom_mire",    "venom",     "蛤蟆", {"seq2": "wx_kin_sonic_wave", "motion": "kin_flame_leap", "react": "kin_hit_launch"}),
    "wx_fist_rulai":      ("buddha_palm",   "gold",      "万佛", {"seq2": "wx_kin_sonic_wave", "shakePow": 9}),
    "wx_fist_nuchao":     ("tidal_wave",    "cyan",      "怒潮", {"motion": "kin_dragon_palm", "tint": [140, 238, 255]}),
    "wx_fist_qianzhu":    ("venom_mire",    "venom",     "千蛛", {"seq2": "wx_kin_claw_rend"}),
    "wx_fist_piaoxue":    ("snow_step",     "frost",     "飘雪", {"seq2": "wx_kin_buddha_palm", "motion": "kin_dragon_palm", "tint": [210, 246, 255]}),
    "wx_fist_longzhao":   ("claw_rend",     "gold",      "龙爪", {"tint": [255, 212, 110]}),
    "wx_fist_xiongzhao":  ("claw_rend",     "fire",      "熊爪", {"motion": "kin_heavy_chop", "tint": [255, 165, 95], "ground": "scorch"}),
    "wx_fist_canhezhi":   ("celestial_beam","cyan",      "剑指", {"tint": [175, 245, 255]}),
    "wx_fist_nianhua":    ("lotus_poke",    "violet",    "锁脉", {"motion": "kin_whip_snap", "tint": [228, 195, 255]}),
    "wx_fist_tiegang":    ("fist_flurry",   "fire",      "铁线", {"motion": "kin_dragon_palm", "ground": "scorch", "tint": [255, 190, 125]}),
    "wx_fist_heisha":     ("smoke_cloud",   "ink",       "黑砂", {"seq2": "wx_kin_venom_mire", "motion": "kin_dragon_palm", "ground": "venom", "tint": [180, 140, 245]}),
    "wx_fist_luohan":     ("fist_flurry",   "gold",      "罗汉", {"seq2": "wx_kin_buddha_palm", "motion": "kin_dash_combo3", "hits": [195, 355]}),

    # === 4. SPEAR / POLEARM / STAFF FAMILY (22 skills) ===
    "wx_spear_guard":     ("xuanwu_aegis",  "cyan",      "枪阵", {"seq2": "wx_kin_spear_drill", "impactMs": 280, "releaseMs": 410, "totalMs": 780, "tint": [175, 244, 255]}),
    "wx_spear_thrust2":   ("phoenix_spear", "fire",      "朝凤", {"motion": "kin_dash_combo3", "hits": [185, 345]}),
    "wx_spear_liuhua":    ("phoenix_spear", "cyan",      "梨花", {"seq2": "wx_kin_flying_knives", "tint": [195, 248, 255]}),
    "wx_spear_bawang":    ("dragon_surge",  "gold",      "霸王", {"motion": "kin_upcut_launch"}),
    "wx_spear_liangyin":  ("phoenix_spear", "celestial", "白虎", {"seq2": "wx_kin_spear_drill", "tint": [235, 248, 255]}),
    "wx_pole_sweep":      ("whirl_cyclone", "crimson",   "横扫", {"tint": [255, 145, 145]}),
    "wx_pole_goulian":    ("bamboo_bind",   "gold",      "钩镰", {"seq2": "wx_kin_whip_lash", "tint": [245, 224, 155]}),
    "wx_pole_fangtian":   ("giant_axe",     "celestial", "画戟", {"seq2": "wx_kin_whirl_cyclone", "motion": "kin_whirl_spin", "tint": [255, 232, 162]}),
    "wx_staff_challenge": ("war_banner",    "gold",      "怒喝", {"seq2": "wx_kin_sonic_wave", "impactMs": 300, "releaseMs": 430, "totalMs": 820}),
    "wx_staff_dagou":     ("bamboo_bind",   "jade",      "打狗", {"tint": [145, 255, 185]}),
    "wx_spear_panlong":   ("dragon_surge",  "cyan",      "盘龙", {"seq2": "wx_kin_spear_drill", "motion": "kin_spear_drill", "tint": [165, 245, 255]}),
    "wx_spear_xuelong":   ("frost_burst",   "frost",     "雪龙", {"seq2": "wx_kin_snow_step", "motion": "kin_upcut_launch"}),
    "wx_spear_zhenbiao":  ("phoenix_spear", "gold",      "镇岳", {"seq2": "wx_kin_dragon_surge", "tint": [255, 224, 130]}),
    "wx_spear_shouguan":  ("spear_drill",   "gold",      "守关", {"seq2": "wx_kin_xuanwu_aegis", "tint": [255, 225, 145]}),
    "wx_spear_yaqi":      ("war_banner",    "fire",      "牙旗", {"seq2": "wx_kin_whirl_cyclone", "motion": "kin_whirl_spin", "tint": [255, 210, 125]}),
    "wx_pole_pojun":      ("whirl_cyclone", "fire",      "破军", {"seq2": "wx_kin_earth_shatter", "tint": [255, 175, 105], "ground": "scorch"}),
    "wx_pole_fenjiang":   ("tidal_wave",    "jade",      "分江", {"seq2": "wx_kin_spear_drill", "motion": "kin_spear_drill", "tint": [140, 250, 230]}),
    "wx_staff_qingou":    ("bamboo_bind",   "jade",      "无狗", {"seq2": "wx_kin_whirl_cyclone", "motion": "kin_whirl_spin", "tint": [155, 255, 195]}),
    "wx_staff_fengmo":    ("buddha_palm",   "fire",      "伏魔", {"seq": "wx_kin_flame_cleave", "seq2": "wx_kin_golden_dome", "motion": "kin_flame_leap"}),
    "wx_staff_weituo":    ("thunder_slam",  "gold",      "韦陀", {"tint": [255, 224, 130]}),
    "wx_staff_lianhua":   ("bamboo_bind",   "gold",      "莲花", {"seq2": "wx_kin_lotus_poke", "tint": [235, 255, 175]}),
    "wx_staff_zhenjiang": ("tidal_wave",    "cyan",      "镇江", {"seq2": "wx_kin_whirl_cyclone", "motion": "kin_whirl_spin", "tint": [165, 232, 255]}),

    # === 5. HAMMER / AXE / SHIELD FAMILY (16 additional skills) ===
    "wx_hammer_shatter":  ("earth_shatter", "gold",      "碎甲", {"motion": "kin_heavy_chop"}),
    "wx_hammer_quake":    ("earth_shatter", "fire",      "裂地", {"seq2": "wx_kin_sonic_wave", "shakePow": 9}),
    "wx_axe_split":       ("giant_axe",     "fire",      "劈山", {"motion": "kin_heavy_chop", "tint": [255, 196, 128]}),
    "wx_axe_whirl":       ("blood_cleave",  "crimson",   "狂斧", {"seq": "wx_kin_whirl_cyclone", "seq2": "wx_kin_blood_arc", "motion": "kin_whirl_spin", "tint": [255, 120, 130]}),
    "wx_axe_kaishan":     ("giant_axe",     "gold",      "开天", {"seq2": "wx_kin_earth_shatter", "motion": "kin_flame_leap", "shakePow": 9}),
    "wx_shield_bash_qi":  ("xuanwu_aegis",  "gold",      "铁壁", {"seq2": "wx_kin_sonic_wave", "motion": "kin_dragon_palm", "ground": "scorch"}),
    "wx_shield_tiebi":    ("xuanwu_aegis",  "gold",      "明王", {"impactMs": 280, "releaseMs": 410, "totalMs": 780, "tint": [255, 228, 145]}),
    "wx_hammer_pocheng":  ("cannon_blast",  "fire",      "破城", {"seq2": "wx_kin_earth_shatter", "motion": "kin_flame_leap", "shakePow": 9}),
    "wx_hammer_qianjun":  ("earth_shatter", "gold",      "万钧", {"motion": "kin_thunder_slam", "shakePow": 8}),
    "wx_hammer_jingua":   ("earth_shatter", "fire",      "金瓜", {"motion": "kin_heavy_chop", "tint": [255, 205, 120]}),
    "wx_hammer_polu":     ("sonic_wave",    "gold",      "擂鼓", {"seq2": "wx_kin_earth_shatter", "motion": "kin_roar_pulse", "ground": "scorch"}),
    "wx_hammer_faqiu":    ("earth_shatter", "ink",       "发丘", {"motion": "kin_heavy_chop", "tint": [210, 195, 240]}),
    "wx_axe_kaitian":     ("giant_axe",     "fire",      "神钺", {"seq2": "wx_kin_earth_shatter", "motion": "kin_flame_leap", "shakePow": 9}),
    "wx_axe_xueming":     ("giant_axe",     "crimson",   "血斧", {"seq2": "wx_kin_blood_arc", "motion": "kin_whirl_spin", "tint": [255, 125, 135]}),
    "wx_axe_poche":       ("giant_axe",     "gold",      "破车", {"seq2": "wx_kin_sonic_wave", "motion": "kin_heavy_chop", "tint": [255, 215, 135]}),
    "wx_shield_xuanwu":   ("xuanwu_aegis",  "jade",      "玄武", {"tint": [185, 255, 220], "impactMs": 280, "releaseMs": 410, "totalMs": 780}),

    # === 6. DAGGER / WHIP / FLAIL / BOW / CROSSBOW / THROW / GUN (30 skills) ===
    "wx_dagger_vital":    ("shadow_cross",  "crimson",   "断脉", {"tint": [255, 130, 150]}),
    "wx_dagger_fuxue":    ("shadow_cross",  "ink",       "背刺", {"seq2": "wx_kin_claw_rend"}),
    "wx_dagger_execute":  ("shadow_cross",  "violet",    "绝杀", {"seq2": "wx_kin_celestial_beam", "tint": [215, 155, 255]}),
    "wx_flail_lash":      ("whip_lash",     "jade",      "软鞭", {}),
    "wx_flail_entangle":  ("whip_lash",     "gold",      "锁喉", {"tint": [255, 220, 130]}),
    "wx_whip_suohou":     ("whip_lash",     "venom",     "毒鞭", {"seq2": "wx_kin_venom_mire", "ground": "venom", "react": "kin_hit_venom"}),
    "wx_bow_snipe":       ("arrow_barrage", "cyan",      "贯日", {"seq2": "wx_kin_celestial_beam", "tint": [185, 245, 255]}),
    "wx_bow_liuxing":     ("arrow_barrage", "gold",      "连珠", {"hits": [220, 290, 355]}),
    "wx_crossbow_shenji": ("arrow_barrage", "fire",      "劲弩", {"seq2": "wx_kin_spear_drill", "tint": [255, 200, 130]}),
    "wx_throwing_rain":   ("peacock_fan",   "gold",      "千针", {"seq2": "wx_kin_arrow_barrage", "hits": [210, 275, 340], "tint": [255, 232, 165]}),
    "wx_throw_fan":       ("flying_knives", "cyan",      "飞刀", {"tint": [190, 245, 255]}),
    "wx_throw_duzhen":    ("venom_mire",    "venom",     "毒钉", {"seq2": "wx_kin_arrow_barrage", "motion": "kin_throw_fan"}),
    "wx_throw_pilidan":   ("cannon_blast",  "fire",      "雷火", {"seq2": "wx_kin_thunder_bolt", "motion": "kin_throw_fan", "impactMs": 360, "shakePow": 9}),
    "wx_smoke_cast":      ("smoke_cloud",   "ink",       "墨烟", {"tint": [190, 200, 225]}),
    "wx_dagger_jingke":   ("celestial_beam","celestial", "图穷", {"seq2": "wx_kin_shadow_cross", "motion": "kin_shadow_blink"}),
    "wx_dagger_zhuanzhu": ("spear_drill",   "cyan",      "藏剑", {"motion": "kin_shadow_blink"}),
    "wx_dagger_yingci":   ("claw_rend",     "ink",       "无影", {"seq2": "wx_kin_shadow_cross"}),
    "wx_dagger_shenghuo": ("peacock_fan",   "fire",      "圣火", {"seq2": "wx_kin_flame_pillar", "motion": "kin_shadow_blink", "tint": [255, 175, 105]}),
    "wx_flail_panlong":   ("whip_lash",     "gold",      "九节", {"seq2": "wx_kin_dragon_surge", "tint": [255, 215, 120]}),
    "wx_flail_jinshe":    ("whip_lash",     "venom",     "金蛇", {"seq2": "wx_kin_bamboo_bind", "ground": "venom", "react": "kin_hit_venom", "tint": [225, 255, 130]}),
    "wx_flail_liuxing":   ("whip_lash",     "gold",      "流星", {"seq2": "wx_kin_sonic_wave", "motion": "kin_whirl_spin", "tint": [255, 215, 120]}),
    "wx_bow_luori":       ("dragon_surge",  "fire",      "落日", {"seq2": "wx_kin_flame_pillar", "motion": "kin_bow_draw", "tint": [255, 175, 95]}),
    "wx_bow_jiuxing":     ("peacock_fan",   "celestial", "九星", {"seq2": "wx_kin_celestial_beam", "motion": "kin_bow_draw", "hits": [220, 290, 355]}),
    "wx_bow_yanxing":     ("arrow_barrage", "jade",      "鸣镝", {"tint": [165, 255, 215]}),
    "wx_crossbow_liannu": ("arrow_barrage", "venom",     "连弩", {"seq2": "wx_kin_venom_mire", "tint": [165, 255, 130], "ground": "venom", "react": "kin_hit_venom"}),
    "wx_gun_leihuo":      ("cannon_blast",  "fire",      "神机", {"seq2": "wx_kin_thunder_bolt", "impactMs": 350, "shakePow": 9}),
    "wx_gun_huolong":     ("cannon_blast",  "fire",      "火龙", {"seq2": "wx_kin_dragon_surge", "impactMs": 360, "shakePow": 9}),
    "wx_throw_liuyedao":  ("flying_knives", "gold",      "子母", {"tint": [255, 228, 155]}),
    "wx_throw_kongque":   ("peacock_fan",   "celestial", "孔雀", {"hits": [200, 270, 345]}),
    "wx_whip_xiangxi":    ("whip_lash",     "violet",    "摄魂", {"seq2": "wx_kin_soul_vortex", "tint": [210, 155, 255]}),

    # === 7. NEIGONG / HENGLIAN / QINGGONG / TACTICS (34 skills) ===
    "wx_meditate":        ("gold_needles",  "jade",      "吐纳", {"seq2": "wx_kin_taiji_seal", "tint": [175, 255, 225], "impactMs": 280, "releaseMs": 410, "totalMs": 780}),
    "wx_blood_burst":     ("prism_burst",   "crimson",   "燃血", {"seq2": "wx_kin_soul_vortex", "motion": "kin_roar_pulse", "tint": [255, 110, 125], "impactMs": 310, "releaseMs": 440, "totalMs": 820}),
    "wx_neigong_jinzhong":("golden_dome",   "gold",      "金钟", {"impactMs": 290, "releaseMs": 420, "totalMs": 800}),
    "wx_neigong_xixing":  ("soul_vortex",   "violet",    "噬气", {}),
    "wx_qinggong_zongyue":("qinggong_gust", "cyan",      "梯云", {}),
    "wx_qinggong_lingbo": ("warp_seal",     "jade",      "凌波", {"seq2": "wx_kin_taiji_seal", "tint": [175, 255, 225]}),
    "wx_rally_command":   ("war_banner",    "gold",      "帅令", {"impactMs": 300, "releaseMs": 430, "totalMs": 820}),
    "wx_tactics_jinzhen": ("gold_needles",  "jade",      "金针", {"tint": [195, 255, 220]}),
    "wx_tactics_shihou":  ("sonic_wave",    "gold",      "狮吼", {"motion": "kin_roar_pulse", "shakePow": 8}),
    "wx_neigong_zixia":   ("prism_burst",   "violet",    "紫霞", {"motion": "kin_stance_channel", "tint": [228, 172, 255], "impactMs": 290, "releaseMs": 420, "totalMs": 800, "ground": ""}),
    "wx_neigong_yijin":   ("gold_needles",  "gold",      "易筋", {"seq2": "wx_kin_golden_dome", "impactMs": 290, "releaseMs": 420, "totalMs": 800}),
    "wx_neigong_hanbing": ("snow_step",     "frost",     "寒气", {"seq2": "wx_kin_frost_burst", "motion": "kin_stance_channel", "impactMs": 300, "releaseMs": 430, "totalMs": 820}),
    "wx_neigong_douzhuan":("warp_seal",     "violet",    "斗转", {"seq2": "wx_kin_taiji_seal", "motion": "kin_stance_channel", "tint": [210, 175, 255], "impactMs": 290, "releaseMs": 420, "totalMs": 800}),
    "wx_neigong_wudu":    ("venom_mire",    "venom",     "万蛊", {"motion": "kin_roar_pulse", "impactMs": 320, "releaseMs": 450, "totalMs": 840}),
    "wx_neigong_guiyuan": ("gold_needles",  "cyan",      "归元", {"tint": [185, 248, 255], "impactMs": 280, "releaseMs": 410, "totalMs": 780}),
    "wx_neigong_taotie":  ("soul_vortex",   "crimson",   "饕餮", {"seq2": "wx_kin_prism_burst", "motion": "kin_roar_pulse", "tint": [255, 110, 135], "impactMs": 320, "releaseMs": 460, "totalMs": 860}),
    "wx_neigong_chaoxi":  ("tidal_wave",    "cyan",      "潮生", {"motion": "kin_stance_channel", "tint": [155, 240, 255], "impactMs": 280, "releaseMs": 410, "totalMs": 780}),
    "wx_neigong_junwu":   ("war_banner",    "fire",      "杀伐", {"seq2": "wx_kin_flame_pillar", "tint": [255, 175, 115], "impactMs": 300, "releaseMs": 430, "totalMs": 820}),
    "wx_qinggong_yanxing":("qinggong_gust", "jade",      "飞燕", {"tint": [175, 255, 225]}),
    "wx_qinggong_shuishang":("tidal_wave",  "cyan",      "渡江", {"seq2": "wx_kin_qinggong_gust", "motion": "kin_qg_vault", "tint": [155, 248, 255]}),
    "wx_qinggong_feiyan": ("warp_seal",     "celestial", "穿云", {"seq2": "wx_kin_qinggong_gust", "tint": [225, 248, 255]}),
    "wx_qinggong_meiying":("smoke_cloud",   "violet",    "魅影", {"seq2": "wx_kin_qinggong_gust", "motion": "kin_qg_vault", "tint": [215, 165, 255]}),
    "wx_qinggong_shenxing":("qinggong_gust","gold",      "神行", {"tint": [255, 234, 165]}),
    "wx_qinggong_xuelian":("snow_step",     "frost",     "踏雪", {"tint": [210, 248, 255], "ground": "frost"}),
    "wx_qinggong_chanchu":("qinggong_gust", "venom",     "金蟾", {"seq2": "wx_kin_sonic_wave", "tint": [170, 255, 155]}),
    "wx_qinggong_suodi":  ("warp_seal",     "celestial", "缩地", {"tint": [255, 238, 175]}),
    "wx_henglian_tiebushan":("golden_dome", "fire",      "铁布", {"motion": "kin_roar_pulse", "tint": [255, 204, 130], "impactMs": 290, "releaseMs": 420, "totalMs": 800}),
    "wx_henglian_jinchan":("gold_needles",  "jade",      "金蝉", {"seq2": "wx_kin_golden_dome", "tint": [180, 255, 220], "impactMs": 280, "releaseMs": 410, "totalMs": 780}),
    "wx_henglian_tongtou":("fist_flurry",   "gold",      "铜头", {"seq2": "wx_kin_earth_shatter", "motion": "kin_dragon_palm", "impactMs": 370, "ground": "scorch"}),
    "wx_henglian_panshi": ("xuanwu_aegis",  "gold",      "磐石", {"seq2": "wx_kin_earth_shatter", "impactMs": 290, "releaseMs": 420, "totalMs": 800}),
    "wx_tactics_guigu":   ("war_banner",    "celestial", "鬼谷", {"seq2": "wx_kin_taiji_seal", "tint": [255, 236, 170], "impactMs": 300, "releaseMs": 430, "totalMs": 820}),
    "wx_tactics_kuiniu":  ("thunder_slam",  "violet",    "夔牛", {"seq2": "wx_kin_sonic_wave", "motion": "kin_roar_pulse", "impactMs": 360, "shakePow": 9}),
    "wx_tactics_bamen":   ("war_banner",    "jade",      "八门", {"seq2": "wx_kin_xuanwu_aegis", "tint": [185, 255, 215], "impactMs": 300, "releaseMs": 430, "totalMs": 820}),
    "wx_tactics_qimen":   ("smoke_cloud",   "ink",       "奇门", {"seq2": "wx_kin_taiji_seal", "motion": "kin_stance_channel", "tint": [190, 200, 245], "impactMs": 300, "releaseMs": 430, "totalMs": 820}),
}


def parse_skill_sources():
    vfx_txt = VFX_NUT.read_text(encoding="utf-8")
    choreo = {}
    pat = re.compile(
        r'(wx_[a-z0-9_]+)\s*=\s*\[\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*(\d+)\s*,\s*(\d+)\s*\]'
    )
    for m in pat.finditer(vfx_txt):
        choreo[m.group(1)] = {
            "label": m.group(2), "anim": m.group(3), "mode": m.group(4),
            "vfx": m.group(5), "sig": m.group(6), "volleys": int(m.group(7)), "shake": int(m.group(8)),
        }

    meta = {}
    for f in sorted(ACTIVES_DIR.glob("wx_*.nut")):
        if f.name == "wx_move_base.nut":
            continue
        sid = f.stem
        txt = f.read_text(encoding="utf-8", errors="replace")
        nm = re.search(r'this\.m\.Name\s*=\s*"([^"]+)"', txt)
        name = nm.group(1) if nm else sid
        is_targeted = "IsTargeted = false" not in txt
        is_attack = "IsAttack = false" not in txt
        is_ranged = "IsRanged = true" in txt
        is_qinggong = sid.startswith("wx_qinggong_")
        is_footwork = 'inherit("scripts/skills/actives/footwork"' in txt
        is_aoe = ("IsAOE = true" in txt) or ("getAllInstancesAsArray" in txt) or ("for (local d = 0" in txt)
        if is_qinggong:
            kind = "qinggong"
        elif not is_targeted:
            kind = "stance"
        elif not is_attack:
            kind = "util"
        elif is_ranged:
            kind = "ranged"
        else:
            kind = "melee"
        meta[sid] = {
            "name": name,
            "kind": kind,
            "isFootwork": is_footwork,
            "isAoe": is_aoe,
            "choreo": choreo[sid],
        }
    return meta


def sq_str(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def build_catalog():
    meta = parse_skill_sources()
    assert len(meta) == 171, f"Expected 171 active skill files, found {len(meta)}"
    missing = set(meta.keys()) - set(EXPLICIT_171.keys())
    extra = set(EXPLICIT_171.keys()) - set(meta.keys())
    assert not missing, f"Skills missing from EXPLICIT_171: {sorted(missing)}"
    assert not extra, f"Unknown skills in EXPLICIT_171: {sorted(extra)}"

    catalog = {}
    seen_exact = collections.defaultdict(list)
    used_seqs = collections.Counter()

    for sid in sorted(meta.keys()):
        m = meta[sid]
        arch, theme, seal, ov = EXPLICIT_171[sid]
        assert arch in ARCH_DEFAULTS, f"Invalid arch {arch} for {sid}"
        assert theme in THEME_META, f"Invalid theme {theme} for {sid}"
        base = dict(ARCH_DEFAULTS[arch])
        base.update(ov)

        seq = base["seq"]
        seq2 = base.get("seq2", "")
        motion = base["motion"]
        react = base["react"]
        assert seq in VALID_SEQS, f"Invalid seq {seq} for {sid}"
        if seq2:
            assert seq2 in VALID_SEQS, f"Invalid seq2 {seq2} for {sid}"
        assert motion in VALID_MOTIONS, f"Invalid motion {motion} for {sid}"
        assert react in VALID_REACTS, f"Invalid react {react} for {sid}"

        tint = base.get("tint") or THEME_META[theme]["tint"]
        impact_ms = int(base["impactMs"])
        release_ms = int(base["releaseMs"])
        total_ms = int(base["totalMs"])
        hits = [int(h) for h in base["hits"]]
        shake_pow = int(base.get("shakePow", max(4, min(9, m["choreo"]["shake"]))))
        ground = base.get("ground", "")

        used_seqs[seq] += 1
        sig = (arch, seq, seq2, motion, theme, tuple(tint), ground)
        seen_exact[sig].append(f"{sid}({m['name']})")

        catalog[sid] = {
            "id": f"actives.{sid}",
            "key": sid,
            "title": m["name"],
            "subtitle": m["choreo"]["label"],
            "seal": seal,
            "arch": arch,
            "seq": seq,
            "seq2": seq2,
            "motion": motion,
            "react": react,
            "theme": theme,
            "col": THEME_META[theme]["col"],
            "core": THEME_META[theme]["core"],
            "tint": tint,
            "kind": m["kind"],
            "isFootwork": m["isFootwork"],
            "isAoe": m["isAoe"],
            "ground": ground,
            "impactMs": impact_ms,
            "releaseMs": release_ms,
            "totalMs": total_ms,
            "hits": hits,
            "shakePow": shake_pow,
            "tag": base["tag"],
            "beats": base["beats"],
        }

    collisions = {k: v for k, v in seen_exact.items() if len(v) > 1}
    assert not collisions, f"Exact visual collisions found ({len(collisions)} groups): {list(collisions.values())}"
    unused_primary = VALID_SEQS - set(used_seqs.keys()) - {"wx_kin_flame_pillar"}
    print(f"Sequence spread: {len(used_seqs)} primary seqs used (max per seq={used_seqs.most_common(1)[0]}), unused_primary={sorted(unused_primary)}")
    print("ZERO exact visual collisions verified: 171/171 distinct visual recipes!")

    OUT_JSON.write_text(json.dumps(catalog, ensure_ascii=False, indent=2), encoding="utf-8")

    lines = [
        "// Auto-generated Canonical 171-Skill Next-Gen Kinetic VFX Choreography Catalog (40-Atlas Expansion A)",
        "// Generated by `tools/build_171_kinetic_catalog.py` — do not hand-edit.",
        "// 171/171 strictly distinct visual combinations across 40 multi-frame sequences & 16 motions.",
        "",
        "if (!(\"KineticVFX\" in ::Wuxia)) ::Wuxia.KineticVFX <- {};",
        "",
        "::Wuxia.KineticVFX.Profiles <- {",
    ]
    keys = sorted(catalog.keys())
    for idx, sid in enumerate(keys):
        c = catalog[sid]
        comma = "," if idx < len(keys) - 1 else ""
        hits_sq = "[" + ", ".join(str(x) for x in c["hits"]) + "]"
        tint_sq = "[" + ", ".join(str(x) for x in c["tint"]) + "]"
        lines.append(
            f"\t{sid} = {{ "
            f"title = {sq_str(c['title'])}, subtitle = {sq_str(c['subtitle'])}, seal = {sq_str(c['seal'])}, "
            f"arch = {sq_str(c['arch'])}, seq = {sq_str(c['seq'])}, seq2 = {sq_str(c['seq2'])}, "
            f"motionKind = {sq_str(c['motion'])}, react = {sq_str(c['react'])}, "
            f"theme = {sq_str(c['theme'])}, tint = {tint_sq}, kind = {sq_str(c['kind'])}, "
            f"isFootwork = {'true' if c['isFootwork'] else 'false'}, isAoe = {'true' if c['isAoe'] else 'false'}, "
            f"ground = {sq_str(c['ground'])}, impactMs = {c['impactMs']}, releaseMs = {c['releaseMs']}, "
            f"totalMs = {c['totalMs']}, hits = {hits_sq}, shakePow = {c['shakePow']} }}{comma}"
        )
    lines.append("};")
    lines.append("")
    OUT_NUT.write_text("\n".join(lines), encoding="utf-8")

    print(f"Built 171-skill Kinetic Catalog: {OUT_NUT.relative_to(ROOT)} & {OUT_JSON.relative_to(ROOT)}")


if __name__ == "__main__":
    build_catalog()
