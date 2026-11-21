#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Wave 63..69 Grand Shan Hai Treasury, Divine Weapons, Spirit Herbs & Neidan Expansion:
Slices 7 hand-painted 4x4 sprite sheets (112 new Wuxia/Shan Hai assets), generates all
Squirrel 3.0 item scripts, 68 new Baigong Taxidermist & Alchemy blueprints (12 -> 80 total),
registers 104x142 paperdoll armor/helmet/shield/weapon `.brush` layers, updates `art/manifest.json`
and syncs `mod_wuxia/gfx/`, `.brush` atlases, and `武侠百科.html`!

Summary of Expansion:
  1. 山海百工宝甲与奇珍 (`ShanHaiGear`): 8 -> 40 (+32: 10 Armors, 6 Helmets, 6 Famed Shields, 10 Talismans)
  2. 山海神兵红武 (`RelicWeapons` Shan Hai): 2 -> 22 (+20 across all 13 weapon families; total Relics 39 -> 59)
  3. 灵丹奇草 (`Pills` & `Herbs`): 11 -> 39 (22 Spirit Pills + 17《山海本草》Rare Spirit Herbs)
  4. 大妖内丹 (`ShanHaiCores`): 64 -> 96 (+16 Wild Beast Elder Cores + 16 Ancient Sovereign Cores, 100% resonance & recipes)
"""

import json
import os
import shutil
import sys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))

import build_wuxia_bust_system as bsys
import build_stage2_stage3_assets as s23
from collections import deque
from optimize_equipment_sprites import extract_white_cell_clean
from fix_visuals_icons_corpses_town import render_clean_item_icon
from process_wiki_art import fit_rgba_centered, strip_small_disconnected_components


def make_clean_hd(rgba: Image.Image, punch_pure_cord: bool = False) -> Image.Image:
    rgba = strip_small_disconnected_components(rgba, min_ratio=0.035)
    if punch_pure_cord:
        out = rgba.copy()
        w, h = out.size
        px = out.load()
        vis = bytearray(w * h)
        for y in range(1, h - 1):
            for x in range(1, w - 1):
                idx = y * w + x
                r, g, b, a = px[x, y]
                if not vis[idx] and a > 120 and min(r, g, b) >= 250 and (max(r, g, b) - min(r, g, b)) <= 5:
                    vis[idx] = 1
                    q = deque([(x, y)])
                    pts = [(x, y)]
                    while q:
                        cx, cy = q.popleft()
                        for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
                            if 0 <= nx < w and 0 <= ny < h:
                                nidx = ny * w + nx
                                nr, ng, nb, na = px[nx, ny]
                                if not vis[nidx] and na > 80 and min(nr, ng, nb) >= 247 and (max(nr, ng, nb) - min(nr, ng, nb)) <= 6:
                                    vis[nidx] = 1
                                    q.append((nx, ny))
                                    pts.append((nx, ny))
                    if len(pts) >= 20:
                        for kx, ky in pts:
                            px[kx, ky] = (0, 0, 0, 0)
        rgba = bsys.decontaminate_white_fringe(out, passes=1)
    return fit_rgba_centered(rgba, 256, 256, pad_x=8, pad_y=8, add_shadow=False)

ART_DIR = ROOT / "art"
SHEETS_DIR = ART_DIR / "sheets"
HD_DIR = ART_DIR / "hd"
GAME_ITEMS_DIR = ART_DIR / "game" / "ui" / "items"
BUSTS_DIR = ART_DIR / "busts"
MOD_ROOT = ROOT / "mod_wuxia"
BRAIN_DIR = Path(r"C:\Users\25647\.gemini\antigravity\brain\2b9036cc-a555-4e16-a55f-86514d9b25a2")

RAW_SHEETS = {
    63: BRAIN_DIR / "shan_hai_jing_armor_helmets_4x4_1795224157865.jpg",
    64: BRAIN_DIR / "shanhai_shields_talismans_4x4_final_1795224205624.jpg",
    65: BRAIN_DIR / "shan_hai_jing_weapons_4x4_v2_1795224193020.jpg",
    66: BRAIN_DIR / "wuxia_shanhai_4x4_spritesheet_1795224161622.jpg",
    67: BRAIN_DIR / "shanhaijing_rare_herbs_4x4_sheet_1795224162248.jpg",
    68: BRAIN_DIR / "neidan_orbs_4x4_spritesheet_1795224376149.jpg",
    69: BRAIN_DIR / "primordial_sovereign_cores_4x4_refined_1795224192342.jpg",
}

# ==============================================================================
# 1. SHEET 63: 10 SHAN HAI ARMORS + 6 SHAN HAI HELMETS/CROWNS
# ==============================================================================
# Armor tuple: (id, name, base_script, value, min_cond, max_cond, max_stam, min_stam, core_id, sec_mat, sub, desc)
NEW_ARMORS = [
    ("wx_armor_xuangui", "山海·杻阳玄龟镇海重铠", "green_coat_of_plates_armor", 8400, 350, 0, -31, 0,
     "wx_core_xuangui", "scripts/items/misc/lindwurm_scales_item", "山海重铠 · 杻阳玄龟甲",
     "取《南山经》杻阳鸟首玄龟皇镇海元珠与六角古甲千锤百锻而成的至强镇线重铠，坚若磐岳，钝兵箭矢难损分毫。"),
    ("wx_armor_yinglong", "山海·凶犁应龙逆鳞金甲", "green_coat_of_plates_armor", 8600, 335, 0, -27, 0,
     "wx_core_yinglong", "scripts/items/misc/lindwurm_scales_item", "山海重铠 · 应龙逆鳞甲",
     "融上古真龙应龙逆鳞宝珠与青铜鎏金龙鳞甲叶铸就的统帅神铠，兼具浩瀚护甲厚度与卓绝行气效率。"),
    ("wx_armor_chiyou", "山海·凶黎蚩尤铜头战铠", "green_coat_of_plates_armor", 8500, 342, 0, -29, 0,
     "wx_core_chiyou", "scripts/items/misc/unhold_bones_item", "山海重铠 · 兵主凶煞甲",
     "以万古兵主蚩尤战魄配古铜兽面吞肩锻成的霸道重铠，凶威凛冽，专为横练巨斧与重锤猛将量身打造。"),
    ("wx_armor_kui", "山海·流波夔牛紫电革铠", "lindwurm_armor", 7800, 275, 0, -21, 0,
     "wx_core_kui", "scripts/items/misc/unhold_hide_item", "山海中重甲 · 流波雷牛革",
     "取东海流波山独足夔牛厚革与紫电雷核鞣制嵌铁而成，革韧如铁鼓而分量适中，攻守进退皆宜。"),
    ("wx_armor_luwu", "山海·昆仑陆吾九部虎贲甲", "named_plated_fur_armor", 8000, 305, 0, -24, 0,
     "wx_core_luwu", "scripts/items/misc/hyena_fur_item", "山海重甲 · 昆仑虎神铠",
     "肩披昆仑神兽陆吾雪白虎裘、胸覆错金虎纹钢札的镇山宝甲，威仪堂皇。"),
    ("wx_armor_zhuyin", "山海·钟山烛阴寒暑龙鳞袍", "lindwurm_armor", 8200, 265, 0, -19, 0,
     "wx_core_zhuyin", "scripts/items/misc/serpent_skin_item", "山海中甲 · 寒暑龙鳞袍",
     "以钟山烛九阴昼夜龙珠淬炼赤火与寒冰双色龙鳞编缀的奇门战袍，水火不侵且内息滞涩极轻。"),
    ("wx_armor_feilian", "山海·鹿台飞廉御风羽衣", "leopard_armor", 7500, 172, 188, -8, -6,
     "wx_core_feilian", "scripts/items/misc/hyena_fur_item", "山海轻甲 · 风伯轻装衣",
     "融风伯飞廉御风神丹与青翎熟革精裁的绝顶轻甲：负重仅寥寥数点（完美触发《金蝉卸力》），游侠刺客梦寐以求之羽衣！"),
    ("wx_armor_bifang", "山海·章莪毕方讹火赤翎衣", "leopard_armor", 7400, 166, 182, -7, -6,
     "wx_core_bifang", "scripts/items/misc/spider_silk_item", "山海轻甲 · 毕方赤羽衣",
     "取章莪毕方讹火翎丹配天韧蛛丝与赤羽织就的潇洒劲装，轻盈似火云，丝毫不碍提纵身法。"),
    ("wx_armor_baize", "山海·东望白泽通玄雪裘甲", "leopard_armor", 7700, 180, 195, -9, -7,
     "wx_core_baize", "scripts/items/misc/glowing_resin_item", "山海轻中甲 · 白泽瑞兽裘",
     "以东望山瑞兽白泽宝丹与雪绒银鳞精制的宗师轻甲，防护冠绝同侪而仍契合轻装卸力门径。"),
    ("wx_armor_xiangliu", "山海·共工相柳九首毒鳞甲", "lindwurm_armor", 7900, 288, 0, -23, 0,
     "wx_core_xiangliuwang", "scripts/items/misc/serpent_skin_item", "山海中重甲 · 九首毒渊铠",
     "取共工台九首相柳苦毒源珠与翠紫蛇鳞密编而成的诡谲重鳞甲，滑溜卸刃、刀剑难入。"),
]

# Helmet tuple: (id, name, base_script, hat_tpl, value, min_cond, max_cond, max_stam, fixed_vis, core_id, sec_mat, sub, desc)
NEW_HELMETS = [
    ("wx_helm_kaiming", "山海·昆仑开明九首虎冕", "named_metal_bull_helmet", "wx_hat_30", 6000, 315, 0, -16, None,
     "wx_core_kaiming", "scripts/items/misc/ghoul_horn_item", "山海重胄 · 昆仑虎神冕",
     "仿昆仑百神门主开明兽怒虎金颜精铸的重型战冕，护额坚厚无比，威慑四方宵小。"),
    ("wx_helm_chiyou", "山海·蚩尤铜头铁额魔鍪", "named_metal_bull_helmet", "wx_hat_29", 6400, 338, 0, -18, None,
     "wx_core_chiyou", "scripts/items/misc/unhold_bones_item", "山海重胄 · 铜头铁额鍪",
     "《大荒北经》载蚩尤铜头铁额！以蚩尤战魄熔古赤铜与寒铁重锻的双角霸胄，硬接重锤亦难伤天灵。"),
    ("wx_helm_jinwu", "山海·汤谷金乌大日火羽冠", "lindwurm_helmet", "wx_hat_25", 5900, 175, 192, -6, 0,
     "wx_core_jinwu", "scripts/items/misc/wx_herb_huolingzhi", "山海轻冠 · 扶桑金乌冠",
     "嵌汤谷三足金乌真丹、两侧斜插赤金火翎的束发战冠：毫无视野遮蔽（0 视野惩罚），神射与剑侠绝配！"),
    ("wx_helm_dijiang", "山海·天山帝江幻空丹面", "lindwurm_helmet", "wx_hat_25", 5700, 162, 180, -5, 0,
     "wx_core_dijiang", "scripts/items/misc/spider_silk_item", "山海轻冠 · 帝江丹红翼冠",
     "取天山六足四翼异神帝江幻空丹精制的丹漆金翼轻冠，轻若无物且耳目通明（0 视野惩罚）。"),
    ("wx_helm_siwang", "山海·苍梧青兕独角重兜", "named_metal_bull_helmet", "wx_hat_30", 5800, 290, 0, -14, None,
     "wx_core_siwang", "scripts/items/misc/ghoul_horn_item", "山海中重胄 · 苍梧独角兜",
     "以苍梧独角青兕王镇岳丹与巨犀铁角锻打的乌钢护颊重兜，顶撞格架稳如泰山。"),
    ("wx_helm_bingyi", "山海·从极冰夷御龙寒玉冠", "lindwurm_helmet", "wx_hat_25", 6000, 225, 245, -9, 0,
     "wx_core_bingyi", "scripts/items/misc/wx_herb_bingpocao", "山海中冠 · 河伯双龙玉冠",
     "从极渊冰夷寒髓配寒玉银钢雕琢的双龙盘首战冠，清凉醒神、不掩视野，兼顾中坚防护与灵便内息。"),
]

# ==============================================================================
# 2. SHEET 64: 6 SHAN HAI FAMED SHIELDS + 10 SHAN HAI ACCESSORIES
# ==============================================================================
# Shield tuple: (id, name, value, min_cond, base_mdef, base_rdef, max_stam, core_id, sec_mat, sub, desc)
NEW_SHIELDS = [
    ("wx_shd_xuangui", "山海·杻阳玄龟不坏巨盾", 6800, 96, 22, 26, -16,
     "wx_core_xuangui", "scripts/items/misc/unhold_bones_item", "山海神盾 · 玄龟重橹盾",
     "整副杻阳玄龟皇背甲镶熟铜重框制成的传世巨盾，耐久与防矢冠绝天下，可正面硬扛巨斧狂劈。"),
    ("wx_shd_zaochi", "山海·畴华凿齿破军戈盾", 6500, 82, 25, 18, -14,
     "wx_core_zaochi", "scripts/items/misc/ghoul_horn_item", "山海神盾 · 凿齿凶牙盾",
     "《海外南经》畴华凿齿王遗制精铁兽面圆盾，外圈密布六尺凶牙骨刺，近身格架密不透风。"),
    ("wx_shd_kui", "山海·东海夔牛雷音皮盾", 6200, 74, 21, 22, -10,
     "wx_core_kui", "scripts/items/misc/unhold_hide_item", "山海神盾 · 夔牛雷音团牌",
     "蒙多层流波山夔牛苍革、正中嵌紫电雷铜盾鼻的团牌，敌刃砍中声若惊雷，轻韧耐用。"),
    ("wx_shd_jumang", "山海·都广建木盘根藤牌", 6000, 68, 20, 23, -6,
     "wx_core_jumang", "scripts/items/misc/glowing_resin_item", "山海神盾 · 建木轻灵藤盾",
     "以都广建木生机神枝编盘并浸满琥珀灵脂的传世藤牌，内息负担极低，刀盾游侠守线神物。"),
    ("wx_shd_fangfeng", "山海·会稽防风专车骨橹", 6700, 92, 21, 28, -17,
     "wx_core_fangfeng", "scripts/items/misc/unhold_bones_item", "山海神盾 · 巨神专车骨盾",
     "取会稽古冢防风氏专车巨骨箍黑铁重带制成的立式巨盾，箭雨火铳皆难穿其壁垒。"),
    ("wx_shd_yinglong", "山海·应龙蓄水逆鳞团牌", 6900, 86, 24, 24, -12,
     "wx_core_yinglong", "scripts/items/misc/lindwurm_scales_item", "山海神盾 · 应龙逆鳞圆盾",
     "覆凶犁应龙青金逆鳞的百炼圆盾，弧面旋水卸力，近远双防俱臻化境。"),
]

# Accessory tuple: (id, name, value, core_id, sec_mat, sub, bonuses_squirrel, tooltip_lines_squirrel, desc)
NEW_ACCESSORIES = [
    ("wx_acc_baize", "山海·白泽达知万物图谱佩", 5600, "wx_core_baize", "scripts/items/misc/wx_herb_migu",
     "山海异佩 · 洞悉万招",
     "{ MeleeDefense = 4, RangedDefense = 4, Bravery = 8 }",
     '[ { Icon = "ui/icons/melee_defense.png", Text = "达知万物招路：近防 [color=#135213]+4[/color]、远防 [color=#135213]+4[/color]" }, { Icon = "ui/icons/bravery.png", Text = "瑞兽镇心：定力 [color=#135213]+8[/color]" } ]',
     "以东望白泽通玄宝丹配迷榖灵木雕成的羊脂白玉兽佩。洞悉百鬼兵势，近远双防 +4、定力 +8。"),
    ("wx_acc_hundun", "山海·浑沌无窍定岳黄囊", 5800, "wx_core_hundun", "scripts/items/misc/unhold_hide_item",
     "山海异佩 · 免晕稳阵",
     "{ Hitpoints = 10, ImmuneStun = true }",
     '[ { Icon = "ui/icons/health.png", Text = "浑沌元胎：气血上限 [color=#135213]+10[/color]" }, { Icon = "ui/icons/special.png", Text = "七窍俱泯：彻底免疫棒槌震晕（Stun）" } ]',
     "仿天山神魔浑沌黄囊丹火缝制的护身奇囊。佩之气血 +10，且周身混元无窍、免疫钝器击晕！"),
    ("wx_acc_chenghuang", "山海·白民乘黄二千岁琥珀", 5500, "wx_core_chenghuang", "scripts/items/misc/glowing_resin_item",
     "山海异佩 · 益寿生机",
     "{ Hitpoints = 16, FatigueRecoveryRate = 2 }",
     '[ { Icon = "ui/icons/health.png", Text = "乘黄寿元：气血上限 [color=#135213]+16[/color]" }, { Icon = "ui/icons/fatigue.png", Text = "生机绵长：每回合额外回气 [color=#135213]+2[/color]" } ]',
     "封存海外白民国乘黄神狐寿元丹的千年血珀。佩于胸前气血上限 +16、每回合回气 +2。"),
    ("wx_acc_fuzhu", "山海·敖岸夫诸四角凝霜佩", 5300, "wx_core_fuzhu", "scripts/items/misc/wx_herb_bingpocao",
     "山海异佩 · 寒玉纳气",
     "{ Stamina = 12, FatigueRecoveryRate = 2 }",
     '[ { Icon = "ui/icons/fatigue.png", Text = "寒溪清气：内息上限 [color=#135213]+12[/color]，每回合额外回气 [color=#135213]+2[/color]" } ]',
     "敖岸山四角白鹿夫诸霜丹配冰魄草琢成的寒玉鹿佩，令丹田清凉不竭，内息上限 +12、回气 +2。"),
    ("wx_acc_boshi", "山海·基山猼訑背目无畏佩", 5600, "wx_core_boshi", "scripts/items/misc/wx_herb_dixiu",
     "山海异佩 · 著之不畏",
     "{ MeleeDefense = 5, Bravery = 10, AntiFearBravery = 12 }",
     '[ { Icon = "ui/icons/melee_defense.png", Text = "其目在背：近防 [color=#135213]+5[/color]" }, { Icon = "ui/icons/bravery.png", Text = "著之不畏：定力 [color=#135213]+10[/color]，抗惊骇检定额外 [color=#135213]+12[/color]" } ]',
     "《南山经》载猼訑『其目在背，佩之不畏』：嵌背目无畏丹的乌铜兽瞳佩，近防 +5、定力 +10 且无惧鬼啸。"),
    ("wx_acc_wuluo", "山海·青要武罗穿耳鸣玉环", 5400, "wx_core_wuluo", "scripts/items/misc/spider_silk_item",
     "山海异佩 · 轻灵避矢",
     "{ Initiative = 14, RangedDefense = 6 }",
     '[ { Icon = "ui/icons/initiative.png", Text = "鸣玉轻身：身法 [color=#135213]+14[/color]" }, { Icon = "ui/icons/ranged_defense.png", Text = "幻步拨矢：远防 [color=#135213]+6[/color]" } ]',
     "青要山神女武罗魅神珠炼制的双连豹纹翡翠鸣环，步履间清音流转，身法 +14、远防 +6。"),
    ("wx_acc_xingxing", "山海·招摇狌狌通晓往事佩", 5200, "wx_core_xingxing", "scripts/items/misc/wx_herb_zhichu",
     "山海异佩 · 悟道博闻",
     "{ Vision = 1, XPGainMult = 1.15 }",
     '[ { Icon = "ui/icons/vision.png", Text = "慧目远眺：视野 [color=#135213]+1[/color]" }, { Icon = "ui/icons/xp_received.png", Text = "通晓往事：实战历练经验获取 [color=#135213]+15%[/color]" } ]',
     "招摇山白耳狌狌通明丹镶嵌的古龟甲玉牌，助新秀侠客融会战阵得失，视野 +1、人物经验获取 +15%！"),
    ("wx_acc_jingwei", "山海·发鸠精卫衔石不屈坠", 5500, "wx_core_jingwei", "scripts/items/misc/wx_herb_shatang",
     "山海异佩 · 沧海不屈",
     "{ Bravery = 14, RangedReceivedMult = 0.90, ImmuneKnockback = true }",
     '[ { Icon = "ui/icons/bravery.png", Text = "千载执念：定力 [color=#135213]+14[/color]" }, { Icon = "ui/icons/ranged_defense.png", Text = "衔石镇海：所受远程伤害减免 [color=#135213]10%[/color] 且免疫击退抓取" } ]',
     "发鸠精卫填海魂晶雕成的海蓝宝坠，千载波涛不能移其志，定力 +14、远伤减免 10% 且免疫击退抓取。"),
    ("wx_acc_dangkang", "山海·钦山当康丰穰青玉牙", 5300, "wx_core_dangkang", "scripts/items/misc/wx_herb_zhuyu",
     "山海异佩 · 丰穰壮骨",
     "{ Hitpoints = 12, Stamina = 10 }",
     '[ { Icon = "ui/icons/health.png", Text = "丰穰气血：气血上限 [color=#135213]+12[/color]" }, { Icon = "ui/icons/fatigue.png", Text = "巨牙壮力：内息上限 [color=#135213]+10[/color]" } ]',
     "钦山瑞凶巨兽当康丰穰髓包裹的错金青玉獠牙，气血上限 +12、内息上限 +10。"),
    ("wx_acc_yayu", "山海·少咸猰貐贰负续命珏", 5600, "wx_core_yayu", "scripts/items/misc/wx_herb_longxuejie",
     "山海异佩 · 泣血护命",
     "{ Hitpoints = 15, MeleeDefense = 3, Bravery = 6 }",
     '[ { Icon = "ui/icons/health.png", Text = "逆命血珀：气血上限 [color=#135213]+15[/color]" }, { Icon = "ui/icons/melee_defense.png", Text = "龙首凶威：近防 [color=#135213]+3[/color]、定力 [color=#135213]+6[/color]" } ]',
     "少咸山龙首猰貐逆命血丹琢成的暗红龙纹玉玦，蕴藏凶神顽强生机，气血 +15、近防 +3、定力 +6。"),
]

# ==============================================================================
# 3. SHEETS 65 & 66 (ROW 1): 20 NEW SHAN HAI DIVINE RED WEAPONS (`wx_relic_*`)
# ==============================================================================
# Weapon tuple: (sheet, cell_idx, id, name, family, base_named_script, min_val, categories_or_none, core_id, sec_mat, sub, desc)
NEW_SHANHAI_RELICS = [
    # Sheet 65 (0..15): 16 Melee Shan Hai Divine Red Weapons
    (65, 0, "wx_relic_yinglongjian", "应龙斩魔蓄水剑", "Sword", "scripts/items/weapons/named/named_sword", 8200, None,
     "wx_core_yinglong", "scripts/items/misc/lindwurm_scales_item", "山海神兵 · 单手名剑",
     "《大荒东经》应龙逆鳞珠混百炼寒钢精铸的上古神剑，青铜龙翼护手吞吐沧海寒芒，削铁破甲如探囊取物。"),
    (65, 1, "wx_relic_zhuyinjian", "烛九阴寒暑两仪巨剑", "Sword", "scripts/items/weapons/named/named_greatsword", 8600, None,
     "wx_core_zhuyin", "scripts/items/misc/wx_herb_bingpocao", "山海神兵 · 双手巨剑",
     "取钟山烛龙昼夜龙珠重铸的阴阳双色巨剑，左刃凝万载玄霜、右刃燃大日赤火，一剑横扫寒暑皆灭！"),
    (65, 2, "wx_relic_jinwudao", "汤谷金乌十日焚天刀", "Saber", "scripts/items/weapons/named/named_khopesh", 8100, None,
     "wx_core_jinwu", "scripts/items/misc/wx_herb_huolingzhi", "山海神兵 · 单手狂刀",
     "扶桑三足金乌大日真丹入炉淬火的赤金弯刀，刀槽流淌熔金火纹，刀出如烈日灼空、割肉焚甲。"),
    (65, 3, "wx_relic_taowudao", "荒中檮杌傲狠断岳刀", "Cleaver", "scripts/items/weapons/named/named_crypt_cleaver", 8500, None,
     "wx_core_taowu", "scripts/items/misc/unhold_bones_item", "山海神兵 · 双手重刀",
     "四大凶兽檮杌凶魂丹配脊骨重铁锻成的锯背狂刀，虎口吞刃凶戾绝伦，当者披靡。"),
    (65, 4, "wx_relic_xiangliuqiang", "共工相柳九首蚀骨枪", "Spear", "scripts/items/weapons/named/named_spear", 8000, None,
     "wx_core_xiangliuwang", "scripts/items/misc/poison_gland_item", "山海神兵 · 单手毒枪",
     "九首相柳苦毒源珠镶嵌吞口的青铜九蛇盘首枪，螺旋暗刃专透重铠护心镜。"),
    (65, 5, "wx_relic_gonggongshuo", "不周共工怒触天倾槊", "Spear", "scripts/items/weapons/named/named_spetum", 8500, None,
     "wx_core_gonggong", "scripts/items/misc/lindwurm_bones_item", "山海神兵 · 双手重槊",
     "融不周山共工黑水珠与寒铁龙鳞杆锻就的破阵大槊，两格攒刺势若天柱倾塌！"),
    (65, 6, "wx_relic_qiangliangge", "北山强良虎首衔蛇戈", "Polearm", "scripts/items/weapons/named/named_billhook", 8400, None,
     "wx_core_qiangliang", "scripts/items/misc/serpent_skin_item", "山海神兵 · 双手长戈戟",
     "仿《大荒北经》凶神强良法相精铸的虎首衔赤蛇青铜重戈戟，钩拉劈刺招招夺命。"),
    (65, 7, "wx_relic_jiufengji", "北极九凤泣血摄魂戟", "Polearm", "scripts/items/weapons/named/named_swordlance", 8400, None,
     "wx_core_jiufeng", "scripts/items/misc/witch_hair_item", "山海神兵 · 双手偃月戟",
     "大荒北极九首妖皇泣血珠祭炼的暗红羽翼眉尖大戟，扇面横扫血雾漫天。"),
    (65, 8, "wx_relic_kuafuzhang", "逐日夸父邓林盘桃杖", "Staff", "scripts/items/weapons/named/named_two_handed_mace", 8300, "棍棒, 双手",
     "wx_core_kuafu", "scripts/items/misc/glowing_resin_item", "山海神兵 · 双手神木杖",
     "《海外北经》夸父弃杖化邓林之千年焦桃神木心重箍熟铜而成，重逾百斤，完美催动天下棍杖绝学！"),
    (65, 9, "wx_relic_luwuzhao", "昆仑陆吾司天九尾爪", "Fist", "scripts/items/weapons/named/wx_named_fist", 8200, None,
     "wx_core_luwu", "scripts/items/misc/ghoul_horn_item", "山海神兵 · 成对锁副手拳爪",
     "昆仑镇神陆吾九部帝丹配白虎利爪精锻的成对护手（占双手槽，4 AP 疾攻），寸劲透甲裂骨碎脏！"),
    (65, 10, "wx_relic_kuiguchui", "流波夔牛震天雷骨锤", "Hammer", "scripts/items/weapons/named/named_two_handed_hammer", 8600, None,
     "wx_core_kui", "scripts/items/misc/unhold_bones_item", "山海神兵 · 双手雷霆重锤",
     "以流波山雷兽夔牛独足巨骨包紫电玄铜铸成的万钧战锤，轰落之际铁甲重盾尽化齑粉！"),
    (65, 11, "wx_relic_bojian", "中曲铁驳食虎独角锏", "Hammer", "scripts/items/weapons/named/named_warhammer", 7900, None,
     "wx_core_bo", "scripts/items/misc/ghoul_horn_item", "山海神兵 · 单手破甲独角锏",
     "取《中山经》食虎豹猛兽铁驳之螺旋钢角配铁驳战丹打制的单手重锏，隔甲碎骨专克横练。"),
    (65, 12, "wx_relic_chiyoufu", "凶黎蚩尤五兵裂天钺", "Axe", "scripts/items/weapons/named/named_bardiche", 8800, None,
     "wx_core_chiyou", "scripts/items/misc/unhold_heart_item", "山海神兵 · 双手兵主大钺",
     "万古兵主蚩尤铜头战魄亲铸制式的绿锈血纹青铜巨钺，开山断盾冠绝古今凶兵之首！"),
    (65, 13, "wx_relic_mingshebian", "鲜山鸣蛇四翼磬音鞭", "Flail", "scripts/items/weapons/named/named_battle_whip", 7800, None,
     "wx_core_mingshe", "scripts/items/misc/serpent_skin_item", "山海神兵 · 奇门四翼软鞭",
     "鲜山四翼鸣蛇磬音胆与蛇脊乌钢编连的九节长鞭，挥动声如古磬，隔步抽面缴械无算。"),
    (65, 14, "wx_relic_qinyuanbi", "昆仑钦原蜇石蚀骨刺", "Dagger", "scripts/items/weapons/named/named_qatal_dagger", 8000, None,
     "wx_core_qinyuan", "scripts/items/misc/poison_gland_item", "山海神兵 · 毒皇破甲短刺",
     "《西山经》蜇石则烂之昆仑毒皇钦原尾针配万蛊毒珠磨制的幽碧弯刺，专趁破绽失衡一刺穿心！"),
    (65, 15, "wx_relic_hujiaobian", "玉山虎蛟裂甲铁链枷", "Flail", "scripts/items/weapons/named/named_three_headed_flail", 7900, None,
     "wx_core_hujiao", "scripts/items/misc/lindwurm_scales_item", "山海神兵 · 三首绕盾链枷",
     "玉山虎蛟内丹配三枚蛟首毒牙钢锤扣连的奇门重连枷，越过铁盾直砸面门天灵。"),

    # Sheet 66 Row 1 (0..3): 4 Ranged Shan Hai Divine Red Weapons
    (66, 0, "wx_relic_yingzhaogong", "昆仑英招四海巡狩弓", "Bow", "scripts/items/weapons/named/named_warbow", 8300, None,
     "wx_core_yingzhao", "scripts/items/misc/unhold_hide_item", "山海神兵 · 巡天龙角大弓",
     "天帝司圃神孽英招巡天金丹嵌弣、虎纹巨角合胎的九石神弓，一箭破云百步贯颅！"),
    (66, 1, "wx_relic_gudiaonu", "鹿吴蛊雕裂颅重弩", "Crossbow", "scripts/items/weapons/named/named_crossbow", 8200, None,
     "wx_core_gudiaowang", "scripts/items/misc/ghoul_horn_item", "山海神兵 · 攒角破甲重弩",
     "鹿吴山攒角蛊雕王头骨与摄魂丹加持的乌钢踏张重弩，钢矢激射洞穿百炼重铠。"),
    (66, 2, "wx_relic_huodouchong", "厌火祸斗喷炎神铳", "Firearm", "scripts/items/weapons/named/named_handgonne", 8400, None,
     "wx_core_huodou", "scripts/items/misc/wx_herb_huolingzhi", "山海神兵 · 喷炎兽首火铳",
     "南荒厌火国食炭凶犬祸斗炎珠熔铸铳膛的兽口重火器，轰击之时烈焰铅砂吞没敌阵！"),
    (66, 3, "wx_relic_tiangoubiao", "阴山天狗坠星飞梭", "Throwing", "scripts/items/weapons/named/named_javelin", 7800, None,
     "wx_core_tiangouwang", "scripts/items/misc/hyena_fur_item", "山海神兵 · 陨铁贯甲飞梭",
     "阴山奔星天狗皇坠星核混天外白陨铁精锻的破盾重飞梭，出手如流星坠地、碎盾贯胸！"),
]

# ==============================================================================
# 4. SHEET 66 (ROWS 2-4): 12 NEW SPIRIT PILLS & SHEET 67: 16 NEW RARE HERBS
# ==============================================================================
SHEET66_PILLS = [
    (4,  "wx_pill_zhuyu",    "祝余辟谷丹",       "山海灵丹 · 补血壮气（+16气/+3回）"),
    (5,  "wx_pill_duheng",   "杜衡追风丸",       "山海灵丹 · 疾行抢先（+18身/+5远防）"),
    (6,  "wx_pill_dixiu",    "帝休定岳丹",       "山海灵丹 · 镇心免晕（+14定/免击晕）"),
    (7,  "wx_pill_longxue",  "血竭续骨圣膏",     "杏林圣膏 · 拔除全部外伤并回65血"),
    (8,  "wx_pill_bingxin",  "天山雪莲冰心丹",   "清脉宝丹 · 化内伤散功并下战免毒免夜"),
    (9,  "wx_pill_jiuhua",   "九花玉露丸",       "名门灵丹 · 灌注 +230 火候并回30血"),
    (10, "wx_pill_zijin",    "太虚紫金大丹",     "天人仙丹 · 灌注 +480 火候并清散功内伤"),
    (11, "wx_pill_guiyuan",  "首乌归元培气丸",   "培元宝丸 · 回血且下战 +18气血/+2回气"),
    (12, "wx_pill_baishe",   "五毒百草辟瘴丸",   "奇门辟瘴 · 下战免毒且双防 +4"),
    (13, "wx_pill_jinzun",   "金刚铁骨护体丸",   "横练金丸 · 下战减伤12%且免击退"),
    (14, "wx_pill_shennong", "神农百草返魂丹",   "杏林至宝 · 满血并尽除内外伤散功"),
    (15, "wx_pill_zaohua",   "山海造化护脉金丹", "洗髓圣丹 · 洗髓 +9% 成率且败而无震荡"),
]

SHEET67_HERBS = [
    (0,  "wx_herb_zhuyu",      "招摇祝余仙草",     "《南山经》奇草 · 食之不饥"),
    (1,  "wx_herb_migu",       "招摇迷榖神枝",     "《南山经》神木 · 佩之不迷"),
    (2,  "wx_herb_bili",       "小华山萆荔血藤",   "《西山经》奇藤 · 已心腹痛"),
    (3,  "wx_herb_xuncao",     "天帝山荀草朱实",   "《西山经》灵草 · 活血生肌"),
    (4,  "wx_herb_shatang",    "昆仑沙棠金果",     "《西山经》仙果 · 御水护脉"),
    (5,  "wx_herb_dixiu",      "少室帝休黄华枝",   "《中山经》神枝 · 服者不怒"),
    (6,  "wx_herb_duheng",     "天帝杜衡走马草",   "《西山经》香草 · 食之善走"),
    (7,  "wx_herb_jiarong",    "半石山嘉荣碧草",   "《中山经》奇草 · 辟雷解蛊"),
    (8,  "wx_herb_zhichu",     "敖岸植楮醒神叶",   "《中山经》灵叶 · 醒神护体"),
    (9,  "wx_herb_guicao",     "姑媱帝女鬼草",     "《中山经》仙草 · 通幽凝魄"),
    (10, "wx_herb_longxuejie", "苍梧千年血竭晶",   "《海内南经》脂晶 · 续筋接骨"),
    (11, "wx_herb_xuelian",    "天山绝顶寒玉雪莲", "《西山经》冰莲 · 涤脉清髓"),
    (12, "wx_herb_heshouwu",   "云梦千年人形首乌", "《中山经》宝根 · 固本培元"),
    (13, "wx_herb_zizhi",      "华岳九叶紫金灵芝", "《西山经》仙芝 · 紫气灌顶"),
    (14, "wx_herb_huolingzhi", "太华旱渊赤火芝",   "《西山经》火芝 · 纯阳淬兵"),
    (15, "wx_herb_bingpocao",  "从极渊万载冰魄草", "《海内北经》寒草 · 玄冥冰心"),
]

# ==============================================================================
# 5. SHEETS 68 & 69: 32 NEW GREAT DEMON & SOVEREIGN NEIDAN CORES (`wx_core_*`)
# ==============================================================================
# Core tuple: (sheet, cell_idx, id, chapter, name, value, exp_amt, tier_group, affinity, sub, desc)
NEW_CORES_32 = [
    # Sheet 68: 16 Wild Shan Hai Beast Elder Inner Cores (dropped in live tactical battles!)
    (68, 0,  "wx_core_esha",       "西山经",   "【山泽妖丹】幽谷讹兽梦魇幻丹", 1450, 260, "wild", "tactics",
     "野外讹兽妖丹 · 奇术共鸣", "幽谷梦魇讹兽眉心凝结的紫雾幻丹：可在百工坊合炼「明目定神散」或灌注武学火候。"),
    (68, 1,  "wx_core_chizhu",     "南山经",   "【山泽妖丹】毒谷赤蛛万丝毒丹", 1350, 240, "wild", "neigong_yin",
     "野外赤蛛妖丹 · 阴柔共鸣", "毒谷鬼面赤蛛母腹内银丝缠裹的碧血毒珠：可在百工坊合炼「五毒百草辟瘴丸」或灌注火候。"),
    (68, 2,  "wx_core_canglang",   "西山经",   "【山泽妖丹】阴山苍狼啸月寒丹", 1400, 250, "wild", "qinggong",
     "野外苍狼妖丹 · 轻功共鸣", "阴山异种苍狼王吞吐月华凝成的银铁寒丹：可在百工坊合炼「杜衡追风丸」或灌注火候。"),
    (68, 3,  "wx_core_shuiyuan",   "中山经",   "【山泽妖丹】云梦水猿寒瘴水丹", 1550, 280, "wild", "neigong_yin",
     "野外水猿妖丹 · 阴柔共鸣", "云梦毒泽老水猿丹田漩流不息的深青水珠：可在百工坊合炼「护脉丹」或灌注火候。"),
    (68, 4,  "wx_core_shujing",    "海内经",   "【山泽妖丹】都广树精盘根苍木丹", 1600, 290, "wild", "henglian",
     "野外树精木丹 · 横练共鸣", "都广建木树精核心盘结的琥珀苍木灵核：可在百工坊合炼「金刚铁骨护体丸」或灌注火候。"),
    (68, 5,  "wx_core_yaomei",     "南山经",   "【山泽妖丹】青丘妖魅惑心香丹", 1600, 290, "wild", "tactics",
     "野外妖魅内丹 · 奇术共鸣", "青丘惑心妖魅体内流转霞光的胭脂玉丹：可在百工坊合炼「九花玉露丸」或灌注火候。"),
    (68, 6,  "wx_core_paoxiao",    "北山经",   "【山泽妖丹】北山狍鸮裂骨贪食丹", 1450, 260, "wild", "henglian",
     "野外狍鸮妖丹 · 横练共鸣", "北山食人狍鸮老兽胃囊凝出的骨齿血丹：可在百工坊合炼「虎骨壮气丸」或灌注火候。"),
    (68, 7,  "wx_core_gudiao",     "南山经",   "【山泽妖丹】西山蛊雕裂风斑丹", 1450, 260, "wild", "waigong",
     "野外蛊雕妖丹 · 外功共鸣", "西山蛊雕猛兽体内风刃割裂纹路的豹斑内丹：可在百工坊合炼「凝神丸」或灌注火候。"),
    (68, 8,  "wx_core_mangshe",    "海内南经", "【山泽妖丹】苍梧巨蟒蜕骨碧丹", 1500, 270, "wild", "neigong_yin",
     "野外巴蛇妖丹 · 阴柔共鸣", "苍梧吞鹿巴蛇百年蜕骨所结深碧蛇胆内丹：可在百工坊合炼「首乌归元培气丸」或灌注火候。"),
    (68, 9,  "wx_core_jianmo",     "古墓秘录", "【山泽妖丹】古墓剑魔血影煞丹", 1650, 300, "wild", "waigong",
     "古墓剑魔煞丹 · 外功共鸣", "前朝古墓血影剑魔溃散所遗剑痕黑曜血丹：最契合刀剑外功参悟，亦可入炉合炼「九转大还丹」。"),
    (68, 10, "wx_core_shiwang",    "湘西异闻", "【山泽妖丹】湘西尸王不化骨丹", 1700, 310, "wild", "henglian",
     "湘西尸王骨丹 · 横练共鸣", "湘西千年尸王胸骨淬炼幽绿尸火的不化铜骨丹：可在百工坊合炼「血竭续骨圣膏」或灌注火候。"),
    (68, 11, "wx_core_yuanling",   "荒冢志怪", "【山泽妖丹】荒冢怨灵凝魄寒珠", 1500, 270, "wild", "qinggong",
     "荒冢怨灵魂珠 · 轻功共鸣", "夺魄怨灵消散凝成的冰蓝多面魂晶：可在百工坊合炼「天山雪莲冰心丹」或灌注火候。"),
    (68, 12, "wx_core_zelong",     "海外北经", "【山海巨妖】大泽九首毒触妖丹", 2400, 380, "wild", "neigong_yin",
     "九首泽妖霸主丹 · 阴柔共鸣", "盘踞绝命毒泽的九首相柳巨妖本命内丹：可在百工坊直接炼制「洗髓丹」或「太虚紫金大丹」！"),
    (68, 13, "wx_core_shenlu",     "海外西经", "【山海瑞灵】昆仑神鹿幻彩灵丹", 2400, 380, "wild", "neigong_yang",
     "昆仑神鹿圣丹 · 阳刚共鸣", "林海幻境昆仑神鹿遗留的金角青玉圣丹：可在百工坊直接炼制「洗髓丹」或「神农百草返魂丹」！"),
    (68, 14, "wx_core_yaoren",     "邪派秘录", "【魔窟炉鼎】炼体药人炉鼎血髓丹", 1700, 310, "wild", "neigong_yang",
     "药人瓢把子血丹 · 阳刚共鸣", "邪派炼体总瓢把子以百草炉火锁入铁链的赤铜血髓丹：可在百工坊合炼「祝余辟谷丹」或灌注火候。"),
    (68, 15, "wx_core_jiguanyong", "墨家玄宫", "【前朝枢机】玄宫镇陵墨家机括核", 1750, 320, "wild", "tactics",
     "前朝霸主枢机核 · 奇术共鸣", "前朝镇陵霸主体内咬合水银光球的青铜机关核心：可在百工坊合炼「帝休定岳丹」或灌注火候。"),

    # Sheet 69: 16 Ancient《山海经》Sovereign Mythic Inner Cores (found in Shan Hai Lairs & Ghost Auctions!)
    (69, 0,  "wx_core_qilin",      "海内经",   "【太古圣丹】昆仑仁兽麒麟瑞丹", 2900, 420, "sovereign", "neigong_yang",
     "太古五彩瑞丹 · 阳刚共鸣", "集五方祥瑞之气的五彩龙鳞玉丹：可在百工坊主炼「山海造化护脉金丹」与「洗髓丹」，灌顶火候浩瀚！"),
    (69, 1,  "wx_core_fenghuang",  "南山经",   "【太古圣丹】丹穴五采凤凰涅槃丹", 3000, 440, "sovereign", "neigong_yang",
     "丹穴涅槃圣珠 · 阳刚共鸣", "《南山经》丹穴之山五采神鸟浴火真丹：可在百工坊主炼「神农百草返魂丹」与「太虚紫金大丹」！"),
    (69, 2,  "wx_core_xuanwu",     "北山经",   "【太古圣丹】北冥玄武龟蛇冥丹", 2950, 430, "sovereign", "henglian",
     "北冥镇世冥丹 · 横练共鸣", "龟甲玄冥与寒蛇缠绕的太古水德神丹：最契合横练硬功大成突破，亦可入炉炼制「洗髓丹」！"),
    (69, 3,  "wx_core_baihu",      "西山经",   "【太古圣丹】西极庚金白虎杀伐丹", 2950, 430, "sovereign", "waigong",
     "西极杀伐金丹 · 外功共鸣", "锋锐庚金杀气凝聚的白金虎纹圣丹：天下刀剑枪戟外功灌顶至宝，亦可入炉合炼仙丹！"),
    (69, 4,  "wx_core_qinglong",   "东山经",   "【太古圣丹】东极苍龙岁星木灵丹", 2950, 430, "sovereign", "neigong_yang",
     "东极岁星龙丹 · 阳刚共鸣", "雷木春生之气奔涌的苍翠龙鳞圣丹：最契合正宗内家心法，亦可入炉合炼「洗髓丹」！"),
    (69, 5,  "wx_core_suanyu",     "北山经",   "【山海异丹】景山酸与四翼惊魂丹", 2250, 360, "sovereign", "tactics",
     "《北山经》酸与妖丹 · 奇术共鸣", "景山四翼六目奇鸟酸与内丹，见则邑有恐：可在百工坊合炼「太虚紫金大丹」或灌注奇门杂学。"),
    (69, 6,  "wx_core_feifei",     "中山经",   "【山海瑞丹】霍山腓腓忘忧灵丹", 2300, 360, "sovereign", "tactics",
     "《中山经》腓腓灵丹 · 奇术共鸣", "霍山白尾狸身奇兽腓腓灵珠，蓄之可以解忧：可在百工坊合炼「山海造化护脉金丹」或灌注火候。"),
    (69, 7,  "wx_core_tianma",     "北山经",   "【山海瑞丹】马成山天马飞雪丹", 2400, 380, "sovereign", "qinggong",
     "《北山经》天马神丹 · 轻功共鸣", "马成山白身黑尾飞天骏兽内丹：天下轻功身法共鸣至宝，亦可入炉合炼「太虚紫金大丹」！"),
    (69, 8,  "wx_core_shuhu",      "西山经",   "【山海异丹】崦嵫孰湖人面翼马丹", 2350, 370, "sovereign", "qinggong",
     "《西山经》孰湖妖丹 · 轻功共鸣", "崦嵫落日神山马身鸟翼蛇尾异兽内丹：契合轻功提纵，亦可入炉合炼高阶灵丹。"),
    (69, 9,  "wx_core_xiezhi",     "东山经",   "【山海瑞丹】东望獬豸明断独角丹", 2500, 390, "sovereign", "waigong",
     "明刑独角瑞丹 · 外功共鸣", "触不直者之独角神兽獬豸宝丹，刚正破邪：契合外功兵道，亦可入炉合炼「山海造化护脉金丹」。"),
    (69, 10, "wx_core_bixi",       "东海经",   "【山海神丹】沧海赑屃负岳龙龟丹", 2600, 400, "sovereign", "henglian",
     "沧海负碑龙龟丹 · 横练共鸣", "好负重三山五岳之龙子赑屃石纹金丹：契合重甲横练突破，亦可入炉炼制「洗髓丹」。"),
    (69, 11, "wx_core_jiaolong",   "中山经",   "【山海神丹】洞庭走蛟化龙雷珠", 2650, 400, "sovereign", "waigong",
     "走蛟渡劫雷珠 · 外功共鸣", "五百年寒蛟借暴雨走江化龙时凝结的银蓝雷珠：契合枪棒刀剑外功，亦可入炉合炼仙丹。"),
    (69, 12, "wx_core_chimi",      "大荒南经", "【山海异丹】南荒魑魅山精古丹", 2250, 360, "sovereign", "neigong_yin",
     "南荒山精古丹 · 阴柔共鸣", "深山古瘴木石感千年日月精气所化碧火妖丹：契合阴柔奇门内功，亦可入炉炼丹。"),
    (69, 13, "wx_core_guiche",     "大荒北经", "【山海凶丹】荆楚鬼车十首滴血丹", 2550, 390, "sovereign", "neigong_yin",
     "夜行鬼车妖丹 · 阴柔共鸣", "晦夜掠空滴血成灾的十首妖禽暗红血玉丹：契合魔道阴柔内功，亦可入炉合炼「太虚紫金大丹」。"),
    (69, 14, "wx_core_yingyu",     "西山经",   "【山海异丹】东海赢鱼赤翼洪涛丹", 2300, 360, "sovereign", "neigong_yin",
     "《西山经》赢鱼水丹 · 阴柔共鸣", "鱼身鸟翼音如鸳鸯、见则大水之赢鱼海蓝宝珠：契合绵长内息心法，亦可入炉炼丹。"),
    (69, 15, "wx_core_zhulong",    "海外北经", "【创世圣珠】钟山太古烛龙创世珠", 3500, 480, "sovereign", "neigong_yang",
     "山海万妖至尊珠 · 全脉大共鸣", "视为昼、瞑为夜、吹为冬、呼为夏之钟山创世古神真珠：山海万丹之冠，可主炼「洗髓丹」与「太虚紫金大丹」！"),
]

# Affinity map for the existing 64 Shan Hai Boss Cores so ALL 96 cores have full Resonance & Crafting uses!
EXISTING_64_AFFINITY = {
    "wx_core_zhuyan": "waigong",      "wx_core_feiyi": "henglian",      "wx_core_qiongqi": "qinggong",   "wx_core_taotie": "henglian",
    "wx_core_jiuwei": "tactics",      "wx_core_bashe": "neigong_yin",   "wx_core_jumang": "henglian",    "wx_core_wuzhiqi": "neigong_yin",
    "wx_core_xingtian": "waigong",    "wx_core_bifang": "qinggong",     "wx_core_gudiaowang": "waigong", "wx_core_xingxing": "tactics",
    "wx_core_zhujian": "qinggong",    "wx_core_xuangui": "henglian",    "wx_core_yuanchu": "neigong_yang","wx_core_yingzhao": "waigong",
    "wx_core_luwu": "waigong",        "wx_core_qinyuan": "neigong_yin", "wx_core_tiangouwang": "qinggong","wx_core_zheng": "waigong",
    "wx_core_hundun": "henglian",     "wx_core_yayu": "neigong_yin",    "wx_core_zhuyin": "neigong_yang","wx_core_dijiang": "qinggong",
    "wx_core_paoxiaowang": "henglian","wx_core_changyou": "neigong_yin","wx_core_mengji": "qinggong",    "wx_core_kui": "henglian",
    "wx_core_fei": "neigong_yin",     "wx_core_yinglong": "waigong",    "wx_core_taowu": "waigong",      "wx_core_hujiao": "waigong",
    "wx_core_zhuhuai": "waigong",     "wx_core_shebishi": "neigong_yin","wx_core_jingwei": "tactics",    "wx_core_jiuying": "neigong_yang",
    "wx_core_feilian": "qinggong",    "wx_core_baize": "tactics",       "wx_core_shanhui": "qinggong",   "wx_core_bo": "waigong",
    "wx_core_huodou": "neigong_yang", "wx_core_xiangliuwang": "neigong_yin", "wx_core_kuafu": "waigong", "wx_core_chiyou": "waigong",
    "wx_core_zaochi": "henglian",     "wx_core_erfu": "henglian",       "wx_core_nvchou": "neigong_yang","wx_core_fangfeng": "henglian",
    "wx_core_kaiming": "henglian",    "wx_core_jinwu": "neigong_yang",  "wx_core_zouyu": "qinggong",     "wx_core_gonggong": "waigong",
    "wx_core_wuluo": "qinggong",      "wx_core_siwang": "henglian",     "wx_core_jiufeng": "waigong",    "wx_core_mingshe": "waigong",
    "wx_core_huashe": "neigong_yin",  "wx_core_fuzhu": "neigong_yin",   "wx_core_chenghuang": "neigong_yang", "wx_core_dangkang": "henglian",
    "wx_core_boshi": "tactics",       "wx_core_jiao": "waigong",        "wx_core_bingyi": "neigong_yin", "wx_core_qiangliang": "waigong",
}

# ==============================================================================
# 6. +15 NEW ALCHEMY PILL & SOVEREIGN CORE BLUEPRINTS (`wx_bp_pill_*`)
# ==============================================================================
# Tuple: (bp_name, out_pill_id, out_count, cost, ingredients_list)
NEW_PILL_BLUEPRINTS = [
    ("wx_bp_pill_zhuyu",    "wx_pill_zhuyu",    2, 320, [("scripts/items/misc/wx_herb_zhuyu", 1), ("scripts/items/misc/wx_core_yaoren", 1)]),
    ("wx_bp_pill_duheng",   "wx_pill_duheng",   2, 320, [("scripts/items/misc/wx_herb_duheng", 1), ("scripts/items/misc/wx_core_canglang", 1)]),
    ("wx_bp_pill_dixiu",    "wx_pill_dixiu",    2, 360, [("scripts/items/misc/wx_herb_dixiu", 1), ("scripts/items/misc/wx_core_jiguanyong", 1)]),
    ("wx_bp_pill_longxue",  "wx_pill_longxue",  2, 420, [("scripts/items/misc/wx_herb_longxuejie", 1), ("scripts/items/misc/unhold_bones_item", 1)]),
    ("wx_bp_pill_bingxin",  "wx_pill_bingxin",  2, 480, [("scripts/items/misc/wx_herb_xuelian", 1), ("scripts/items/misc/wx_herb_bingpocao", 1)]),
    ("wx_bp_pill_jiuhua",   "wx_pill_jiuhua",   2, 450, [("scripts/items/misc/wx_herb_xuncao", 1), ("scripts/items/misc/wx_herb_migu", 1)]),
    ("wx_bp_pill_guiyuan",  "wx_pill_guiyuan",  2, 380, [("scripts/items/misc/wx_herb_heshouwu", 1), ("scripts/items/misc/wx_core_mangshe", 1)]),
    ("wx_bp_pill_baishe",   "wx_pill_baishe",   2, 380, [("scripts/items/misc/wx_herb_jiarong", 1), ("scripts/items/misc/poison_gland_item", 1)]),
    ("wx_bp_pill_jinzun",   "wx_pill_jinzun",   2, 420, [("scripts/items/misc/wx_herb_zhichu", 1), ("scripts/items/misc/glowing_resin_item", 1)]),
    ("wx_bp_pill_dahuan",   "wx_pill_dahuan",   2, 650, [("scripts/items/misc/wx_herb_guicao", 1), ("scripts/items/misc/wx_herb_bili", 1), ("scripts/items/misc/ghoul_brain_item", 1)]),
    ("wx_bp_pill_zijin",    "wx_pill_zijin",    1, 900, [("scripts/items/misc/wx_herb_zizhi", 1), ("scripts/items/misc/wx_herb_huolingzhi", 1)]),
    ("wx_bp_pill_shennong", "wx_pill_shennong", 1, 850, [("scripts/items/misc/wx_herb_xuelian", 1), ("scripts/items/misc/wx_herb_heshouwu", 1), ("scripts/items/misc/wx_herb_zhuyu", 1)]),
    ("wx_bp_pill_zaohua",   "wx_pill_zaohua",   1, 950, [("scripts/items/misc/wx_herb_shatang", 1), ("scripts/items/misc/wx_herb_bili", 1), ("scripts/items/misc/unhold_heart_item", 1)]),
    ("wx_bp_pill_xisui_qilin", "wx_pill_xisui", 1, 1200, [("scripts/items/misc/wx_core_qilin", 1), ("scripts/items/misc/wx_herb_zizhi", 1)]),
    ("wx_bp_pill_xisui_zhulong","wx_pill_xisui", 2, 1500, [("scripts/items/misc/wx_core_zhulong", 1), ("scripts/items/misc/wx_herb_shatang", 1)]),
]


def ensure_dirs():
    for d in [
        SHEETS_DIR, HD_DIR,
        GAME_ITEMS_DIR / "armor",
        GAME_ITEMS_DIR / "helmets",
        GAME_ITEMS_DIR / "shields",
        GAME_ITEMS_DIR / "accessory",
        GAME_ITEMS_DIR / "weapons" / "named",
        GAME_ITEMS_DIR / "consumables",
        GAME_ITEMS_DIR / "misc",
        BUSTS_DIR / "body",
        BUSTS_DIR / "hat",
        BUSTS_DIR / "hat_back",
        BUSTS_DIR / "hat_front",
        BUSTS_DIR / "shield",
        BUSTS_DIR / "weapon",
        MOD_ROOT / "scripts" / "items" / "armor" / "named",
        MOD_ROOT / "scripts" / "items" / "helmets" / "named",
        MOD_ROOT / "scripts" / "items" / "shields" / "named",
        MOD_ROOT / "scripts" / "items" / "accessory",
        MOD_ROOT / "scripts" / "items" / "weapons" / "named",
        MOD_ROOT / "scripts" / "items" / "misc",
        MOD_ROOT / "scripts" / "crafting" / "blueprints",
    ]:
        d.mkdir(parents=True, exist_ok=True)


def crop_4x4(sheet_img: Image.Image, cell_idx: int) -> Image.Image:
    cw, ch = sheet_img.width // 4, sheet_img.height // 4
    r, c = divmod(cell_idx, 4)
    # Trim 4px inside cell box so neighboring ink never touches edge
    pad = 4
    return sheet_img.crop((c * cw + pad, r * ch + pad, (c + 1) * cw - pad, (r + 1) * ch - pad))


def count_generated_files() -> int:
    cnt = 0
    for base in (ART_DIR, MOD_ROOT / "gfx"):
        if base.exists():
            for _, _, fns in os.walk(base):
                cnt += sum(1 for fn in fns if fn.endswith((".png", ".jpg")))
    return cnt


def write_nut(rel_path: str, content: str):
    p = MOD_ROOT / rel_path
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(content, encoding="utf-8")


def main():
    ensure_dirs()
    for snum, src_p in RAW_SHEETS.items():
        dst_p = SHEETS_DIR / f"sheet_{snum:02d}.jpg"
        if src_p.exists():
            shutil.copy2(src_p, dst_p)
        elif not dst_p.exists():
            raise FileNotFoundError(f"Missing sprite sheet {snum}: {src_p}")

    sheets = {snum: Image.open(SHEETS_DIR / f"sheet_{snum:02d}.jpg") for snum in RAW_SHEETS}
    _, _, ped_tmask = bsys.make_pedestal_layers()
    ped_clip = s23.make_handheld_pedestal_clip()

    manifest_assets = []

    # --------------------------------------------------------------------------
    # A. Process Sheet 63: 10 Armors + 6 Helmets
    # --------------------------------------------------------------------------
    for idx, arm in enumerate(NEW_ARMORS):
        aid, name, base_sc, val, min_c, max_c, max_s, min_s, core_id, sec_mat, sub, desc = arm
        rgba = extract_white_cell_clean(crop_4x4(sheets[63], idx), bg_thresh=24, feather=16, punch_holes=False)
        hd_256 = make_clean_hd(rgba)
        hd_rel = f"art/hd/{aid}.png"
        lg_rel = f"art/game/ui/items/armor/{aid}.png"
        sm_rel = f"art/game/ui/items/armor/{aid}_70x70.png"
        bust_rel = f"art/busts/body/{aid}.png"

        hd_256.save(ROOT / hd_rel)
        render_clean_item_icon(hd_256, 70, 140, pad_x=3, pad_y=6).save(ROOT / lg_rel)
        render_clean_item_icon(hd_256, 70, 70, pad_x=4, pad_y=4).save(ROOT / sm_rel)
        bsys.register_torso_bust(hd_256, ped_tmask).save(ROOT / bust_rel)

        # Item .nut + Blueprint .nut
        write_nut(f"scripts/items/armor/named/{aid}.nut", f"""// Shan Hai Mythical Named Armor: {name}
this.{aid} <- this.inherit("scripts/items/armor/named/{base_sc}", {{
\tm = {{}},
\tfunction create()
\t{{
\t\tthis.{base_sc}.create();
\t\t::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "{aid}", false);
\t}}
\tfunction onDeserialize( _in )
\t{{
\t\tthis.{base_sc}.onDeserialize(_in);
\t\t::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "{aid}", true);
\t}}
}});
""")
        bp_id = f"wx_bp_{aid[3:]}"
        write_nut(f"scripts/crafting/blueprints/{bp_id}.nut", f"""this.{bp_id} <- this.inherit("scripts/crafting/blueprint", {{
\tfunction create()
\t{{
\t\tthis.blueprint.create();
\t\tthis.m.ID = "blueprint.{bp_id}";
\t\tthis.m.PreviewCraftable = ::new("scripts/items/armor/named/{aid}");
\t\tthis.m.Cost = 2200;
\t\tthis.init([
\t\t\t{{ Script = "scripts/items/misc/{core_id}", Num = 1 }},
\t\t\t{{ Script = "{sec_mat}", Num = 1 }}
\t\t]);
\t}}
\tfunction onCraft( _stash ) {{ _stash.add(::new("scripts/items/armor/named/{aid}")); }}
}});
""")
        manifest_assets.append({
            "id": aid, "stage": "2_weapons", "group": "山海百工宝甲与奇珍（40件）",
            "name": name, "sub": sub, "spec": "70×140 装备大格 + 70×70 + 104×142 纸娃娃胸像",
            "slotKind": "armor140", "status": "in_game",
            "hdPath": hd_rel, "previewPath": lg_rel, "swPath": "", "smallPath": sm_rel,
            "pdRole": "torso", "bustPath": bust_rel,
            "gameTarget": f"gfx/ui/items/armor/{aid}.png",
            "vanillaFallback": "ui/items/armor/named/named_armor_01.png",
            "codeRef": f"scripts/items/armor/named/{aid}.nut", "brief": desc,
        })

    for h_i, hlm in enumerate(NEW_HELMETS):
        cell_idx = 10 + h_i
        aid, name, base_sc, hat_tpl, val, min_c, max_c, max_s, f_vis, core_id, sec_mat, sub, desc = hlm
        rgba = extract_white_cell_clean(crop_4x4(sheets[63], cell_idx), bg_thresh=24, feather=16, punch_holes=False)
        hd_256 = make_clean_hd(rgba)
        hd_rel = f"art/hd/{aid}.png"
        sm_rel = f"art/game/ui/items/helmets/{aid}.png"
        hb_rel = f"art/busts/hat_back/{aid}.png"
        hf_rel = f"art/busts/hat_front/{aid}.png"
        hc_rel = f"art/busts/hat/{aid}.png"

        hd_256.save(ROOT / hd_rel)
        render_clean_item_icon(hd_256, 70, 70, pad_x=4, pad_y=4).save(ROOT / sm_rel)
        hb, hf, hcomb = bsys.register_hat_boolean(hd_256, hat_tpl)
        hb.save(ROOT / hb_rel)
        hf.save(ROOT / hf_rel)
        hcomb.save(ROOT / hc_rel)

        write_nut(f"scripts/items/helmets/named/{aid}.nut", f"""// Shan Hai Mythical Named Helmet: {name}
this.{aid} <- this.inherit("scripts/items/helmets/named/{base_sc}", {{
\tm = {{}},
\tfunction create()
\t{{
\t\tthis.{base_sc}.create();
\t\t::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "{aid}", false);
\t}}
\tfunction onDeserialize( _in )
\t{{
\t\tthis.{base_sc}.onDeserialize(_in);
\t\t::Wuxia.ShanHai.applyNamedArmorOrHelmet(this, "{aid}", true);
\t}}
}});
""")
        bp_id = f"wx_bp_{aid[3:]}"
        write_nut(f"scripts/crafting/blueprints/{bp_id}.nut", f"""this.{bp_id} <- this.inherit("scripts/crafting/blueprint", {{
\tfunction create()
\t{{
\t\tthis.blueprint.create();
\t\tthis.m.ID = "blueprint.{bp_id}";
\t\tthis.m.PreviewCraftable = ::new("scripts/items/helmets/named/{aid}");
\t\tthis.m.Cost = 1800;
\t\tthis.init([
\t\t\t{{ Script = "scripts/items/misc/{core_id}", Num = 1 }},
\t\t\t{{ Script = "{sec_mat}", Num = 1 }}
\t\t]);
\t}}
\tfunction onCraft( _stash ) {{ _stash.add(::new("scripts/items/helmets/named/{aid}")); }}
}});
""")
        manifest_assets.append({
            "id": aid, "stage": "2_weapons", "group": "山海百工宝甲与奇珍（40件）",
            "name": name, "sub": sub, "spec": "70×70 背包图标 + 104×142 前后布尔分拆纸娃娃冠胄",
            "slotKind": "item70", "status": "in_game",
            "hdPath": hd_rel, "previewPath": sm_rel, "swPath": "", "smallPath": "",
            "pdRole": "hat", "bustPath": hc_rel, "bustBackPath": hb_rel, "bustFrontPath": hf_rel,
            "gameTarget": f"gfx/ui/items/helmets/{aid}.png",
            "vanillaFallback": "ui/items/helmets/named/named_helmet_01.png",
            "codeRef": f"scripts/items/helmets/named/{aid}.nut", "brief": desc,
        })

    # --------------------------------------------------------------------------
    # B. Process Sheet 64: 6 Famed Shields + 10 Talismans/Accessories
    # --------------------------------------------------------------------------
    for s_i, shd in enumerate(NEW_SHIELDS):
        aid, name, val, min_c, bmdef, brdef, max_s, core_id, sec_mat, sub, desc = shd
        rgba = extract_white_cell_clean(crop_4x4(sheets[64], s_i), bg_thresh=24, feather=16, punch_holes=False)
        hd_256 = make_clean_hd(rgba)
        hd_rel = f"art/hd/{aid}.png"
        lg_rel = f"art/game/ui/items/shields/{aid}.png"
        sm_rel = f"art/game/ui/items/shields/{aid}_70x70.png"
        bust_rel = f"art/busts/shield/{aid}.png"

        hd_256.save(ROOT / hd_rel)
        render_clean_item_icon(hd_256, 70, 140, pad_x=3, pad_y=8).save(ROOT / lg_rel)
        render_clean_item_icon(hd_256, 70, 70, pad_x=4, pad_y=4).save(ROOT / sm_rel)
        s23.build_shield_bust_layer(hd_256, ped_clip).save(ROOT / bust_rel)

        write_nut(f"scripts/items/shields/named/{aid}.nut", f"""// Shan Hai Famed Shield: {name}
this.{aid} <- this.inherit("scripts/items/shields/named/wx_shanhai_shield_base", {{
\tm = {{}},
\tfunction create()
\t{{
\t\tthis.wx_shanhai_shield_base.create();
\t\tthis.initShanHaiShield("{aid}", false);
\t}}
}});
""")
        bp_id = f"wx_bp_{aid[3:]}"
        write_nut(f"scripts/crafting/blueprints/{bp_id}.nut", f"""this.{bp_id} <- this.inherit("scripts/crafting/blueprint", {{
\tfunction create()
\t{{
\t\tthis.blueprint.create();
\t\tthis.m.ID = "blueprint.{bp_id}";
\t\tthis.m.PreviewCraftable = ::new("scripts/items/shields/named/{aid}");
\t\tthis.m.Cost = 1900;
\t\tthis.init([
\t\t\t{{ Script = "scripts/items/misc/{core_id}", Num = 1 }},
\t\t\t{{ Script = "{sec_mat}", Num = 1 }}
\t\t]);
\t}}
\tfunction onCraft( _stash ) {{ _stash.add(::new("scripts/items/shields/named/{aid}")); }}
}});
""")
        manifest_assets.append({
            "id": aid, "stage": "2_weapons", "group": "山海百工宝甲与奇珍（40件）",
            "name": name, "sub": sub, "spec": "70×140 盾具大格 + 70×70 + 104×142 副手持盾纸娃娃",
            "slotKind": "weapon140", "status": "in_game",
            "hdPath": hd_rel, "previewPath": lg_rel, "swPath": "", "smallPath": sm_rel,
            "pdRole": "shield", "bustPath": bust_rel,
            "gameTarget": f"gfx/ui/items/shields/{aid}.png",
            "vanillaFallback": "ui/items/shields/named/named_shield_01.png",
            "codeRef": f"scripts/items/shields/named/{aid}.nut", "brief": desc,
        })

    for a_i, acc in enumerate(NEW_ACCESSORIES):
        cell_idx = 6 + a_i
        aid, name, val, core_id, sec_mat, sub, _, _, desc = acc
        # Punch enclosed cord loops (>=249 pure white) while protecting pale jade (`baize`, `fuzhu`)
        punch = aid not in ("wx_acc_baize", "wx_acc_fuzhu")
        rgba = extract_white_cell_clean(crop_4x4(sheets[64], cell_idx), bg_thresh=24, feather=16, punch_holes=punch, hole_min_lum=248)
        hd_256 = make_clean_hd(rgba, punch_pure_cord=not punch)
        hd_rel = f"art/hd/{aid}.png"
        sm_rel = f"art/game/ui/items/accessory/{aid}.png"

        hd_256.save(ROOT / hd_rel)
        render_clean_item_icon(hd_256, 70, 70, pad_x=4, pad_y=4).save(ROOT / sm_rel)

        write_nut(f"scripts/items/accessory/{aid}.nut", f"""// Shan Hai Talisman: {name}
this.{aid} <- this.inherit("scripts/items/accessory/wx_shanhai_acc_base", {{
\tm = {{}},
\tfunction create()
\t{{
\t\tthis.wx_shanhai_acc_base.create();
\t\tthis.initShanHaiAccessory("{aid}");
\t}}
}});
""")
        bp_id = f"wx_bp_{aid[3:]}"
        write_nut(f"scripts/crafting/blueprints/{bp_id}.nut", f"""this.{bp_id} <- this.inherit("scripts/crafting/blueprint", {{
\tfunction create()
\t{{
\t\tthis.blueprint.create();
\t\tthis.m.ID = "blueprint.{bp_id}";
\t\tthis.m.PreviewCraftable = ::new("scripts/items/accessory/{aid}");
\t\tthis.m.Cost = 1600;
\t\tthis.init([
\t\t\t{{ Script = "scripts/items/misc/{core_id}", Num = 1 }},
\t\t\t{{ Script = "{sec_mat}", Num = 1 }}
\t\t]);
\t}}
\tfunction onCraft( _stash ) {{ _stash.add(::new("scripts/items/accessory/{aid}")); }}
}});
""")
        manifest_assets.append({
            "id": aid, "stage": "2_weapons", "group": "山海百工宝甲与奇珍（40件）",
            "name": name, "sub": sub, "spec": "70×70 RGBA 透明底护身异佩图标",
            "slotKind": "item70", "status": "in_game",
            "hdPath": hd_rel, "previewPath": sm_rel, "swPath": "", "smallPath": "",
            "gameTarget": f"gfx/ui/items/accessory/{aid}.png",
            "vanillaFallback": "ui/items/accessory/hexen_trophy.png",
            "codeRef": f"scripts/items/accessory/{aid}.nut", "brief": desc,
        })

    # --------------------------------------------------------------------------
    # C. Process Sheets 65 & 66 (Row 1): 20 Shan Hai Divine Red Weapons + qiongqizhao blueprint
    # --------------------------------------------------------------------------
    # Ensure existing `wx_relic_qiongqizhao` ALSO has its own Baigong blueprint!
    write_nut("scripts/crafting/blueprints/wx_bp_relic_qiongqizhao.nut", """this.wx_bp_relic_qiongqizhao <- this.inherit("scripts/crafting/blueprint", {
\tfunction create()
\t{
\t\tthis.blueprint.create();
\t\tthis.m.ID = "blueprint.wx_bp_relic_qiongqizhao";
\t\tthis.m.PreviewCraftable = ::new("scripts/items/weapons/named/wx_relic_qiongqizhao");
\t\tthis.m.Cost = 2200;
\t\tthis.init([
\t\t\t{ Script = "scripts/items/misc/wx_core_qiongqi", Num = 1 },
\t\t\t{ Script = "scripts/items/misc/ghoul_horn_item", Num = 1 }
\t\t]);
\t}
\tfunction onCraft( _stash ) { _stash.add(::new("scripts/items/weapons/named/wx_relic_qiongqizhao")); }
});
""")

    for w_spec in NEW_SHANHAI_RELICS:
        snum, cidx, rid, name, fam, base_path, min_val, cats, core_id, sec_mat, sub, desc = w_spec
        base_cls = base_path.split("/")[-1]
        punch = rid != "wx_relic_luwuzhao"
        rgba = extract_white_cell_clean(crop_4x4(sheets[snum], cidx), bg_thresh=24, feather=16, punch_holes=punch, hole_min_lum=247)
        hd_256 = make_clean_hd(rgba)
        hd_rel = f"art/hd/{rid}.png"
        lg_rel = f"art/game/ui/items/weapons/named/{rid}.png"
        sm_rel = f"art/game/ui/items/weapons/named/{rid}_70x70.png"
        bust_rel = f"art/busts/weapon/{rid}.png"

        hd_256.save(ROOT / hd_rel)
        render_clean_item_icon(hd_256, 70, 140, pad_x=3, pad_y=6).save(ROOT / lg_rel)
        render_clean_item_icon(hd_256, 70, 70, pad_x=4, pad_y=4).save(ROOT / sm_rel)
        s23.build_weapon_bust_layer(hd_256, rid, ped_clip).save(ROOT / bust_rel)

        write_nut(f"scripts/items/weapons/named/{rid}.nut", f"""// Shan Hai Divine Red Weapon: 传世·{name} ({fam})
this.{rid} <- this.inherit("{base_path}", {{
\tm = {{}},
\tfunction create()
\t{{
\t\tthis.{base_cls}.create();
\t\t::Wuxia.Relics.applyRelic(this, "{rid}");
\t}}
\tfunction onDeserialize( _in )
\t{{
\t\tthis.{base_cls}.onDeserialize(_in);
\t\t::Wuxia.Relics.applyArtOverridesOnly(this, "{rid}");
\t}}
}});
""")
        bp_id = f"wx_bp_{rid[3:]}"
        write_nut(f"scripts/crafting/blueprints/{bp_id}.nut", f"""this.{bp_id} <- this.inherit("scripts/crafting/blueprint", {{
\tfunction create()
\t{{
\t\tthis.blueprint.create();
\t\tthis.m.ID = "blueprint.{bp_id}";
\t\tthis.m.PreviewCraftable = ::new("scripts/items/weapons/named/{rid}");
\t\tthis.m.Cost = 2400;
\t\tthis.init([
\t\t\t{{ Script = "scripts/items/misc/{core_id}", Num = 1 }},
\t\t\t{{ Script = "{sec_mat}", Num = 1 }}
\t\t]);
\t}}
\tfunction onCraft( _stash ) {{ _stash.add(::new("scripts/items/weapons/named/{rid}")); }}
}});
""")
        manifest_assets.append({
            "id": rid, "stage": "2_weapons", "group": "山海神兵红武（22柄）",
            "name": f"传世·{name}", "sub": sub, "spec": "70×140 武器大格 + 70×70 + 104×142 纸娃娃手持图层",
            "slotKind": "weapon140", "status": "in_game",
            "hdPath": hd_rel, "previewPath": lg_rel, "swPath": "", "smallPath": sm_rel,
            "pdRole": "weapon", "bustPath": bust_rel,
            "gameTarget": f"gfx/ui/items/weapons/named/{rid}.png",
            "vanillaFallback": "ui/items/weapons/named/named_sword_01.png",
            "codeRef": f"scripts/items/weapons/named/{rid}.nut", "brief": desc,
        })

    # --------------------------------------------------------------------------
    # D. Process Sheet 66 (Rows 2-4): 12 New Spirit Pills + 15 Pill Blueprints
    # --------------------------------------------------------------------------
    for cidx, pid, pname, psub in SHEET66_PILLS:
        rgba = extract_white_cell_clean(crop_4x4(sheets[66], cidx), bg_thresh=24, feather=16, punch_holes=False)
        hd_256 = make_clean_hd(rgba)
        hd_rel = f"art/hd/{pid}.png"
        sm_rel = f"art/game/ui/items/consumables/{pid}.png"
        hd_256.save(ROOT / hd_rel)
        render_clean_item_icon(hd_256, 70, 70, pad_x=4, pad_y=4).save(ROOT / sm_rel)

        manifest_assets.append({
            "id": pid, "stage": "1_icons", "group": "灵丹与山海本草（39种）",
            "name": pname, "sub": psub, "spec": "70×70 RGBA 透明底仙丹图标",
            "slotKind": "item70", "status": "in_game",
            "hdPath": hd_rel, "previewPath": sm_rel, "swPath": "", "smallPath": "",
            "gameTarget": f"gfx/ui/items/consumables/{pid}.png",
            "vanillaFallback": "ui/items/consumables/herb_01.png",
            "codeRef": "mod_wuxia/config/consumables.nut", "brief": psub,
        })

    for bp_name, out_pid, out_cnt, cost, ing_list in NEW_PILL_BLUEPRINTS:
        ing_lines = ",\n".join([f'\t\t\t{{ Script = "{sc}", Num = {num} }}' for sc, num in ing_list])
        craft_body = (
            f'\t\tlocal p = ::new("scripts/items/misc/wx_pill_item");\n\t\tp.initPill("{out_pid}");\n\t\t_stash.add(p);'
            if out_cnt == 1 else
            f'\t\tfor (local i = 0; i < {out_cnt}; i = ++i)\n\t\t{{\n\t\t\tlocal p = ::new("scripts/items/misc/wx_pill_item");\n\t\t\tp.initPill("{out_pid}");\n\t\t\t_stash.add(p);\n\t\t}}'
        )
        write_nut(f"scripts/crafting/blueprints/{bp_name}.nut", f"""this.{bp_name} <- this.inherit("scripts/crafting/blueprint", {{
\tfunction makePreview()
\t{{
\t\tlocal pill = ::new("scripts/items/misc/wx_pill_item");
\t\tpill.initPill("{out_pid}");
\t\treturn pill;
\t}}
\tfunction create()
\t{{
\t\tthis.blueprint.create();
\t\tthis.m.ID = "blueprint.{bp_name}";
\t\tthis.m.PreviewCraftable = this.makePreview();
\t\tthis.m.Cost = {cost};
\t\tthis.init([
{ing_lines}
\t\t]);
\t}}
\tfunction onCraft( _stash )
\t{{
{craft_body}
\t}}
}});
""")

    # --------------------------------------------------------------------------
    # E. Process Sheet 67: 16《山海本草》Rare Spirit Herbs
    # --------------------------------------------------------------------------
    for cidx, hid, hname, hsub in SHEET67_HERBS:
        rgba = extract_white_cell_clean(crop_4x4(sheets[67], cidx), bg_thresh=24, feather=16, punch_holes=False)
        hd_256 = make_clean_hd(rgba)
        hd_rel = f"art/hd/{hid}.png"
        sm_rel = f"art/game/ui/items/misc/{hid}.png"
        hd_256.save(ROOT / hd_rel)
        render_clean_item_icon(hd_256, 70, 70, pad_x=4, pad_y=4).save(ROOT / sm_rel)

        write_nut(f"scripts/items/misc/{hid}.nut", f"""this.{hid} <- this.inherit("scripts/items/misc/wx_herb_base", {{
\tfunction create()
\t{{
\t\tthis.wx_herb_base.create();
\t\tthis.initHerb("{hid}");
\t}}
}});
""")
        manifest_assets.append({
            "id": hid, "stage": "1_icons", "group": "灵丹与山海本草（39种）",
            "name": hname, "sub": hsub, "spec": "70×70 RGBA 透明底本草仙株图标",
            "slotKind": "item70", "status": "in_game",
            "hdPath": hd_rel, "previewPath": sm_rel, "swPath": "", "smallPath": "",
            "gameTarget": f"gfx/ui/items/misc/{hid}.png",
            "vanillaFallback": "ui/items/misc/misc_01.png",
            "codeRef": f"scripts/items/misc/{hid}.nut", "brief": hsub,
        })

    # --------------------------------------------------------------------------
    # F. Process Sheets 68 & 69: 32 New Great Demon & Sovereign Inner Cores
    # --------------------------------------------------------------------------
    for c_spec in NEW_CORES_32:
        snum, cidx, cid, chap, cname, val, exp_amt, tgrp, aff, csub, cdesc = c_spec
        rgba = extract_white_cell_clean(crop_4x4(sheets[snum], cidx), bg_thresh=22, feather=14, punch_holes=False)
        hd_256 = make_clean_hd(rgba)
        hd_rel = f"art/hd/{cid}.png"
        sm_rel = f"art/game/ui/items/misc/{cid}.png"
        hd_256.save(ROOT / hd_rel)
        render_clean_item_icon(hd_256, 70, 70, pad_x=4, pad_y=4).save(ROOT / sm_rel)

        write_nut(f"scripts/items/misc/{cid}.nut", f"""this.{cid} <- this.inherit("scripts/items/misc/wx_shanhai_core_base", {{
\tm = {{}},
\tfunction create()
\t{{
\t\tthis.wx_shanhai_core_base.create();
\t\tthis.initCore("{cid}");
\t}}
}});
""")
        manifest_assets.append({
            "id": cid, "stage": "1_icons",
            "group": "山海九十六大妖与神魔内丹（96款）",
            "name": cname.replace("【山泽妖丹】", "").replace("【太古圣丹】", "").replace("【山海异丹】", "").replace("【山海瑞丹】", "").replace("【山海神丹】", "").replace("【山海凶丹】", "").replace("【创世圣珠】", "").replace("【山海巨妖】", "").replace("【山海瑞灵】", "").replace("【魔窟炉鼎】", "").replace("【前朝枢机】", ""),
            "sub": f"《{chap}》· {csub}",
            "spec": "70×70 RGBA 透明底内丹图标",
            "slotKind": "item70", "status": "in_game",
            "hdPath": hd_rel, "previewPath": sm_rel, "swPath": "", "smallPath": "",
            "gameTarget": f"gfx/ui/items/misc/{cid}.png",
            "vanillaFallback": "ui/items/misc/anatomists_book.png",
            "codeRef": "mod_wuxia/config/wx_shanhai_expansion.nut", "brief": cdesc,
        })

    # --------------------------------------------------------------------------
    # G. Generate Declarative Squirrel Expansion Config (`wx_shanhai_expansion.nut`)
    # --------------------------------------------------------------------------
    nut_lines = [
        "// Declarative Expansion Registry: +32 Shan Hai Baigong Gear, +20 Shan Hai Divine Red Weapons, +32 Neidan Cores & 96-Core Resonance",
        "",
        "// 1. Tag existing 2 Shan Hai Relics & register +20 new Shan Hai Divine Red Weapons (`39 -> 59` Relics, `2 -> 22` Shan Hai!)",
        'if ("wx_relic_xingtianqi" in ::Wuxia.Config.RelicWeapons) ::Wuxia.Config.RelicWeapons.wx_relic_xingtianqi.IsShanHai <- true;',
        'if ("wx_relic_qiongqizhao" in ::Wuxia.Config.RelicWeapons) ::Wuxia.Config.RelicWeapons.wx_relic_qiongqizhao.IsShanHai <- true;',
        "",
    ]
    for w_spec in NEW_SHANHAI_RELICS:
        _, _, rid, name, fam, base_path, min_val, cats, _, _, _, desc = w_spec
        cat_str = "null" if cats is None else f'"{cats}"'
        nut_lines.append(f"""::Wuxia.Config.RelicWeapons.{rid} <- {{
\tID = "{rid}", Name = "{name}", Family = "{fam}", IsShanHai = true,
\tScript = "scripts/items/weapons/named/{rid}", BaseNamedScript = "{base_path}",
\tMinValue = {min_val}, Categories = {cat_str},
\tCustomIcon = "weapons/named/{rid}_70x70.png", CustomIconLarge = "weapons/named/{rid}.png", CustomArmamentIcon = null,
\tDescription = "{desc}"
}};""")

    nut_lines.append("\n// 2. Register +32 Shan Hai Masterwork Armors, Helmets, Famed Shields & Talismans (`8 -> 40` ShanHaiGear!)")
    for arm in NEW_ARMORS:
        aid, name, _, val, min_c, max_c, max_s, min_s, _, _, _, desc = arm
        nut_lines.append(f"""::Wuxia.Config.ShanHaiGear.{aid} <- {{
\tID = "{aid}", Kind = "armor", Name = "{name}", Value = {val},
\tMinCondition = {min_c}, MaxCondition = {max_c}, MaxStamPen = {max_s}, MinStamPen = {min_s},
\tCustomIcon = "armor/{aid}_70x70.png", CustomIconLarge = "armor/{aid}.png",
\tDescription = "{desc}"
}};""")

    for hlm in NEW_HELMETS:
        aid, name, _, _, val, min_c, max_c, max_s, f_vis, _, _, _, desc = hlm
        vis_str = "null" if f_vis is None else str(f_vis)
        nut_lines.append(f"""::Wuxia.Config.ShanHaiGear.{aid} <- {{
\tID = "{aid}", Kind = "helmet", Name = "{name}", Value = {val},
\tMinCondition = {min_c}, MaxCondition = {max_c}, MaxStamPen = {max_s}, FixedVision = {vis_str},
\tCustomIcon = "helmets/{aid}.png", CustomIconLarge = null,
\tDescription = "{desc}"
}};""")

    for shd in NEW_SHIELDS:
        aid, name, val, min_c, bmdef, brdef, max_s, _, _, _, desc = shd
        nut_lines.append(f"""::Wuxia.Config.ShanHaiGear.{aid} <- {{
\tID = "{aid}", Kind = "shield", Name = "{name}", Value = {val},
\tMinCondition = {min_c}, BaseMDef = {bmdef}, BaseRDef = {brdef}, MaxStamPen = {max_s},
\tCustomIcon = "shields/{aid}_70x70.png", CustomIconLarge = "shields/{aid}.png",
\tDescription = "{desc}"
}};""")

    for acc in NEW_ACCESSORIES:
        aid, name, val, _, _, _, bonuses_sq, tt_sq, desc = acc
        nut_lines.append(f"""::Wuxia.Config.ShanHaiGear.{aid} <- {{
\tID = "{aid}", Kind = "accessory", Name = "{name}", Value = {val},
\tMinCondition = 0, MaxStamPen = 0,
\tBonuses = {bonuses_sq},
\tTooltipLines = {tt_sq},
\tCustomIcon = "accessory/{aid}.png", CustomIconLarge = null,
\tDescription = "{desc}"
}};""")

    nut_lines.append("\n// 3. Assign Martial Affinity Resonance to all 64 existing Boss Cores + register +32 Wild & Sovereign Cores (`64 -> 96`!)")
    for cid, aff in EXISTING_64_AFFINITY.items():
        nut_lines.append(f'if ("{cid}" in ::Wuxia.Config.ShanHaiCores) {{ ::Wuxia.Config.ShanHaiCores.{cid}.Affinity <- "{aff}"; ::Wuxia.Config.ShanHaiCores.{cid}.TierGroup <- "boss"; }}')

    for c_spec in NEW_CORES_32:
        _, _, cid, chap, cname, val, exp_amt, tgrp, aff, _, cdesc = c_spec
        nut_lines.append(f"""::Wuxia.Config.ShanHaiCores.{cid} <- {{
\tID = "{cid}", Chapter = "{chap}", Name = "{cname}", Value = {val}, ExpAmount = {exp_amt},
\tTierGroup = "{tgrp}", Affinity = "{aff}",
\tIcon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/{cid}.png",
\tDescription = "{cdesc}"
}};""")

    write_nut("mod_wuxia/config/wx_shanhai_expansion.nut", "\n".join(nut_lines) + "\n")

    # Ensure `load.nut` includes `wx_shanhai_expansion.nut` right after `wx_shanhai.nut`
    load_p = MOD_ROOT / "mod_wuxia" / "load.nut"
    load_txt = load_p.read_text(encoding="utf-8")
    inc_line = '::include("mod_wuxia/config/wx_shanhai_expansion.nut");'
    if inc_line not in load_txt:
        load_txt = load_txt.replace(
            '::include("mod_wuxia/config/wx_shanhai.nut");',
            '::include("mod_wuxia/config/wx_shanhai.nut");\n' + inc_line,
            1
        )
        load_p.write_text(load_txt, encoding="utf-8")

    # --------------------------------------------------------------------------
    # H. Update `art/manifest.json` cleanly & idempotently
    # --------------------------------------------------------------------------
    manifest_p = ART_DIR / "manifest.json"
    manifest = json.loads(manifest_p.read_text(encoding="utf-8"))

    new_ids = {a["id"] for a in manifest_assets}
    kept = []
    for a in manifest["assets"]:
        if a["id"] in new_ids:
            continue
        # Unify group labels so the 4 expanded pillars appear crisply grouped in 武侠百科.html!
        if a.get("group") in ("山海六十四大妖内丹（64款）",):
            a["group"] = "山海九十六大妖与神魔内丹（96款）"
        elif a.get("group") in ("灵丹与奇草", "丹药百工 · 江湖十丹谱系"):
            a["group"] = "灵丹与山海本草（39种）"
        elif a.get("group") == "山海百工宝甲与奇珍":
            a["group"] = "山海百工宝甲与奇珍（40件）"
        elif a["id"] in ("wx_relic_xingtianqi", "wx_relic_qiongqizhao"):
            a["group"] = "山海神兵红武（22柄）"
        elif a.get("group") == "传世与山海神兵红武":
            a["group"] = "华夏历史传世神兵（37柄）"
        kept.append(a)

    manifest["assets"] = kept + manifest_assets

    # Refresh Stage 1, 2, 4 descriptions to match exact live counts!
    for st in manifest["stages"]:
        cnt = sum(1 for a in manifest["assets"] if a["stage"] == st["id"])
        if st["id"] == "1_icons":
            st["desc"] = f"22种灵丹与17种山海本草、96枚大妖与太古神魔内丹、72式武学招式与宗门圆章（{cnt}/{cnt}）"
        elif st["id"] == "2_weapons":
            st["desc"] = f"13系中华常规兵器、12面藤铁盾、37柄历史神兵、22柄山海神兵红武与40件山海百工宝甲神盾奇珍（{cnt}/{cnt}）"
        elif st["id"] == "4_beasts":
            st["desc"] = f"64尊《山海经》首领、11种野外山泽异兽与64座山海秘境大地图地标（{cnt}/{cnt}）"

    manifest["version"] = f"1.1.0-shanhai-treasury-{len(manifest['assets'])}"
    manifest["summary"] = {
        "total": len(manifest["assets"]),
        "wiki_ready": sum(1 for a in manifest["assets"] if a["status"] == "wiki_ready"),
        "in_game": sum(1 for a in manifest["assets"] if a["status"] == "in_game"),
        "planned": sum(1 for a in manifest["assets"] if a["status"] == "planned"),
        "png_files_generated": count_generated_files(),
    }
    manifest_p.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"SUCCESS: Processed 112 new Shan Hai assets! Manifest total = {manifest['summary']['total']} (in_game={manifest['summary']['in_game']}).")


if __name__ == "__main__":
    main()
