#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Slices and processes Wave 39..46 (8 Master Sheets = 128 new hand-painted Wuxia assets):
  - Sheet 39 (16 Active Skill Icons Part I):  `wx_sword_zhongjian` .. `wx_staff_dagou` (`56x56` + `_sw.png`)
  - Sheet 40 (16 Active Skill Icons Part II): `wx_fist_xianglong` .. `wx_qinggong_lingbo` (`56x56` + `_sw.png`)
  - Sheet 41 (6 Active Skill Icons + 2 Meridian Statuses + 8 Company Crests)
  - Sheet 42 (16 Wuxia Combat VFX Sprites Part I): `wx_vfx_01..16` (Stage `5_vfx`)
  - Sheet 43 (16 Wuxia Combat VFX Sprites Part II): `wx_vfx_17..32` (Stage `5_vfx`)
  - Sheet 44 (16 New Shan Hai Jing Apex Bosses #49..#64): `wx_boss_kaiming` .. `wx_boss_qiangliang`
  - Sheet 45 (16 New Shan Hai Jing World Lairs #49..#64): `wx_lair_kaiming` .. `wx_lair_qiangliang`
  - Sheet 46 (16 New Shan Hai Jing Neidan Cores #49..#64): `wx_core_kaiming` .. `wx_core_qiangliang`
Brings `art/manifest.json` from 628 -> 756 total Wuxia art assets!
"""

import json
import os
import shutil
from PIL import Image
from process_wiki_art import fit_rgba_centered, make_grayscale_sw, process_skill_square
from build_wuxia_bust_system import flood_white_bg

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART_DIR = os.path.join(ROOT, "art")
SHEETS_DIR = os.path.join(ART_DIR, "sheets")
BRAIN = r"C:\Users\25647\.gemini\antigravity\brain\fa3a61d2-2588-454a-a04d-cca189377964"

RAW_SHEETS = {
    39: os.path.join(BRAIN, "wuxia_combat_skills_sheet_v3_1795173424637.jpg"),
    40: os.path.join(BRAIN, "wuxia_skills_sheet_1_v2_1795173426363.jpg"),
    41: os.path.join(BRAIN, "wuxia_bb_icons_4x4_1795173551154.jpg"),
    42: os.path.join(BRAIN, "wuxia_combat_vfx_sheet_v2_1795173426405.jpg"),
    43: os.path.join(BRAIN, "wuxia_vfx_sheet_fixed_1795173419847.jpg"),
    44: os.path.join(BRAIN, "shanhaijing_boss_busts_4x4_v2_1795173582477.jpg"),
    45: os.path.join(BRAIN, "wuxia_world_lairs_4x4_final_1795173605894.jpg"),
    46: os.path.join(BRAIN, "shanhaijing_neidan_orbs_4x4_1795173551911.jpg"),
}

SHEET39_SKILLS = [
    ("wx_sword_zhongjian", "重剑无锋劈", "剑宗绝艺 · 6 AP / 26 内息", "大巧不工重剑劈砸，破甲伤害 +40% 并震得对手失衡。"),
    ("wx_sword_duoming", "夺命三仙剑", "剑宗绝艺 · 5 AP / 22 内息", "西岳险峻奇快连环三剑，命中 +10、击头率 +15%。"),
    ("wx_sword_cuixin", "松风摧心刺", "剑宗绝艺 · 4 AP / 18 内息", "青城阴狠快剑专刺残敌心脉，对伤血之敌总伤 +25% 并留破绽。"),
    ("wx_sword_taiji", "两仪化劲剑", "剑宗绝艺 · 5 AP / 20 内息", "玄门圆转借力粘连剑圈，震散对手锐气致其散劲虚弱。"),
    ("wx_sword_feixian", "天河落星剑", "剑宗绝艺 · 6 AP / 28 内息", "名门越步飞剑凌空贯刺 2 格目标，穿甲 +15%。"),
    ("wx_sword_dugu", "破刃荡剑式", "剑宗绝艺 · 5 AP / 24 内息", "专破天下兵刃守势，一剑荡开盾墙、枪阵与反击架势。"),
    ("wx_saber_kuangfeng", "狂风快刀斩", "刀门霸斩 · 4 AP / 16 内息", "大漠狂风骤雨斜劈，伤血必致非尸傀目标割裂流血。"),
    ("wx_saber_ranmu", "燃木烈阳劈", "刀门霸斩 · 6 AP / 26 内息", "禅门纯阳刀罡炽烈如火焚木，破甲 +35% 并震慑定力。"),
    ("wx_saber_xuehai", "修罗饮血斩", "刀门霸斩 · 5 AP / 22 内息", "魔道血刀随自身伤势增威，斩中血肉汲取生机回血。"),
    ("wx_saber_fanzhen", "两仪合璧斩", "刀门霸斩 · 5 AP / 20 内息", "正派双刀呼应阵斩，邻接同袍时命中与穿甲大幅提升。"),
    ("wx_saber_modao", "陌刀碎骑斩", "刀门霸斩 · 6 AP / 28 内息", "军阵重型长刀两格纵劈重创敌阵，硬生生劈退目标一格。"),
    ("wx_spear_liuhua", "梨花暴雨枪", "枪戟长兵 · 5 AP / 22 内息", "将门快枪如梨花瑞雪攒刺两格目标，命中 +10 并必留破绽。"),
    ("wx_spear_bawang", "霸王挑山枪", "枪戟长兵 · 6 AP / 26 内息", "军阵霸枪自下而上猛挑两格敌手，击退目标并震至失衡。"),
    ("wx_pole_fangtian", "画戟月牙斩", "枪戟长兵 · 6 AP / 28 内息", "方天长戟月牙钩劈重甲头颈，破甲 +30%、击头率 +12%。"),
    ("wx_pole_goulian", "钩镰锁足拽", "枪戟长兵 · 5 AP / 20 内息", "破骑钩镰长兵自两格外钩拽敌腿拉至身前并致失衡。"),
    ("wx_staff_dagou", "绊字缠足杖", "枪戟长兵 · 4 AP / 18 内息", "丐门竹棒贴地横扫脚踝，高命中致敌失衡并耗损内息。"),
]

SHEET40_SKILLS = [
    ("wx_fist_xianglong", "亢龙有悔掌", "拳掌指爪 · 6 AP / 28 内息", "天下至刚阳掌透甲重击（总伤 +25%，穿甲 +20%），震退敌手并附内伤。"),
    ("wx_fist_xuanming", "玄冥寒毒掌", "拳掌指爪 · 5 AP / 24 内息", "西域苦寒奇掌冻结真元，穿甲 +15% 并附寒毒蚀脉与内息凝滞。"),
    ("wx_fist_yiyang", "一阳贯脉指", "拳掌指爪 · 5 AP / 24 内息", "凝纯阳真气于食指隔空两格认穴贯刺，极高穿甲并封脉点穴。"),
    ("wx_fist_jiuyin", "九阴摧心爪", "拳掌指爪 · 4 AP / 20 内息", "五指如钩直扣天灵与心脉，击头率 +20% 并致流血。"),
    ("wx_fist_qishang", "七伤总诀拳", "拳掌指爪 · 5 AP / 22 内息", "自震微血催发七股刚柔暗劲，总伤 +30% 并双附内伤与破绽。"),
    ("wx_fist_taiji", "揽雀借力掌", "拳掌指爪 · 4 AP / 16 内息", "四两拨千斤圆转推掌，高命中震退来敌并致散劲虚弱。"),
    ("wx_hammer_leiting", "雷霆碎岳锤", "重兵奇门 · 6 AP / 28 内息", "挟风雷万钧之威猛砸重铠，破甲伤害 +50% 并震伤内腑。"),
    ("wx_axe_kaishan", "旋风开山斩", "重兵奇门 · 6 AP / 26 内息", "绿林霸主双斧力劈华山，总伤 +22%、破甲 +25% 并留破绽。"),
    ("wx_whip_suohou", "灵蛇锁喉鞭", "重兵奇门 · 5 AP / 20 内息", "三格软鞭如毒蛇绕盾抽击咽喉，击头率 +15% 并致流血。"),
    ("wx_dagger_fuxue", "透骨分筋刺", "重兵奇门 · 4 AP / 18 内息", "贴身短匕乘敌破绽/失衡/封穴时命中 +18、穿甲 +22% 绝杀。"),
    ("wx_shield_tiebi", "不动明王盾", "刀盾守御 · 4 AP / 18 内息", "副手持藤牌或铁盾沉肩立阵，近远双防 +15 且免疫击退抓取。"),
    ("wx_bow_liuxing", "流星连珠箭", "弓弩唐门 · 4 AP / 18 内息", "塞外神射搭箭如流星赶月连珠疾射，压制敌方远程与轻甲。"),
    ("wx_crossbow_shenji", "神机透甲矢", "弓弩唐门 · 5 AP / 20 内息", "神机劲弩铁矢直贯护心重铠，额外穿甲 +20%、破甲 +25%。"),
    ("wx_throw_pilidan", "霹雳雷火弹", "弓弩唐门 · 5 AP / 26 内息", "蜀中唐门硫磺铁蒺藜爆弹，轰碎护甲并剧烈震慑敌军定力。"),
    ("wx_throw_duzhen", "五毒丧门钉", "弓弩唐门 · 4 AP / 18 内息", "南疆唐门喂毒暗器精准攒射，令血肉之躯中奇毒蚀血损气。"),
    ("wx_qinggong_lingbo", "凌波腾挪步", "轻功身法 · 3 AP / 18 内息", "循八卦方位轻灵滑步脱出重围，完全无视敌军控制区截击。"),
]

SHEET41_ITEMS = [
    # 0..5: 6 Active Skills (completing all 72/72 active moves!)
    ("skill", "wx_qinggong_zongyue", "梯云纵跃步", "轻功身法 · 4 AP / 22 内息", "武林绝顶提纵轻功，拔地纵跃跨入 2 格空地抢占高地或切入侧翼。"),
    ("skill", "wx_neigong_jinzhong", "金钟护体罡", "内功横练 · 4 AP / 24 内息", "鼓荡梵钟护体金罡，气血与护甲受创减免 35% 且免震晕击退。"),
    ("skill", "wx_neigong_xixing", "北冥噬气诀", "奇门内功 · 4 AP / 12 内息", "掌心气璇强行抽散近身活人 18 点内息并导引 14 点归入自身丹田。"),
    ("skill", "wx_tactics_shihou", "金刚狮子吼", "禅门统帅 · 5 AP / 28 内息", "吐气如雷震慑周身 2 格全体敌军定力并令其陷入失衡。"),
    ("skill", "wx_tactics_jinzhen", "金针渡穴诀", "杏林杂学 · 5 AP / 22 内息", "为自身或相邻同袍施针止血、拔除奇毒封穴并稳固 14 点气血。"),
    ("skill", "wx_fist_jab", "寸劲碎甲拳", "拳掌指爪 · 4 AP / 13 内息", "贴身一寸发力透甲重拳，轻快连击直震脏腑。"),
    # 6..7: 2 Meridian Statuses
    ("status", "wx_status_qi_deviation", "走火入魔", "经脉异状 · 逆血乱神", "强催霸道魔功或内息逆行所致，双防下降而凶性暴烈。"),
    ("status", "wx_status_meridian_harmony", "奇经贯通", "经脉异状 · 周天圆满", "任督二脉与奇经八脉生生流转，回气与运劲圆融无碍。"),
    # 8..15: 8 Mercenary Company Crests
    ("crest", "wx_crest_longhu", "威远龙虎镖旗徽", "武林旗号 · 镖局战徽 01", "金虎咆哮、苍龙盘绕的中原老字号总镖局纹章。"),
    ("crest", "wx_crest_xuanniao", "孤剑玄鸟盟徽", "武林旗号 · 游侠战徽 02", "血月之下孤剑立影、玄燕掠空的独行剑盟纹章。"),
    ("crest", "wx_crest_bagua", "太和八卦玄门徽", "武林旗号 · 道门战徽 03", "古铜阴阳双鱼配先天八卦爻象的玄门正宗纹章。"),
    ("crest", "wx_crest_jinlian", "少室金莲禅武徽", "武林旗号 · 禅宗战徽 04", "八叶赤金宝莲悬于交错齐眉铁棍之上的护法武僧纹章。"),
    ("crest", "wx_crest_wudu", "南疆五毒奇门徽", "武林旗号 · 奇门战徽 05", "碧蝎、百足与毒虺盘绕炼蛊银鼎的南疆奇门纹章。"),
    ("crest", "wx_crest_tianji", "天机星盘奇巧徽", "武林旗号 · 机关战徽 06", "精密黄铜齿轮与浑天星象罗盘咬合的墨家天机纹章。"),
    ("crest", "wx_crest_canglang", "塞外苍狼铁骑徽", "武林旗号 · 边塞战徽 07", "银鬃怒狼与双角筋弓交错的关外马帮劲旅纹章。"),
    ("crest", "wx_crest_pojun", "破军节度战旗徽", "武林旗号 · 藩镇战徽 08", "双戟赤焰配青铜饕餮兽面盾的地方藩镇精锐纹章。"),
]

VFX_32_DEFS = [
    # Sheet 42 (01..16)
    ("wx_vfx_01", "青霜快剑斩弧", "刀剑气芒 · 剑宗快斩特效", "凌厉青白剑气破空划出的新月斩弧，绑定快剑与轻刀招式。"),
    ("wx_vfx_02", "烈阳霸刀火罡", "刀剑气芒 · 至阳重劈特效", "裹挟赤金烈焰与黑烟的刚猛刀斧重劈气芒，绑定燃木劈山类招式。"),
    ("wx_vfx_03", "穿云破甲枪芒", "刀剑气芒 · 贯刺突击特效", "凝若寒星螺旋破风的直线枪剑突刺气锥，绑定长枪透甲与劲矢招式。"),
    ("wx_vfx_04", "紫电夺命连闪", "刀剑气芒 · 连环快刺特效", "三道紫电寒芒瞬息交错的夺命剑影，绑定三仙剑与要害快刺。"),
    ("wx_vfx_05", "玄铁裂地重斩波", "刀剑气芒 · 崩山碎甲特效", "重剑陌刀或巨锤砸地激起的碎石琥珀气浪，绑定重剑无锋与震地锤。"),
    ("wx_vfx_06", "修罗血海旋刀芒", "刀剑气芒 · 魔刀旋斩特效", "墨黑煞气与暗红血刃盘旋绞杀的旋风刀阵，绑定饮血斩与横扫招式。"),
    ("wx_vfx_07", "独孤十字破刃印", "刀剑气芒 · 绝杀破势特效", "锐不可当的赤金十字交斩剑印，绑定天外一剑、破刃式与合璧斩。"),
    ("wx_vfx_08", "天河落星飞剑雨", "刀剑气芒 · 凌空剑阵特效", "五道青冥寒剑自九天斜掠而下的剑雨残影，绑定天河落星剑。"),
    ("wx_vfx_09", "亢龙金罡真龙掌印", "拳掌内劲 · 至刚阳掌特效", "金龙盘绕怒啸、正中烙印浑厚金罡掌印，绑定亢龙掌与金刚拳。"),
    ("wx_vfx_10", "玄冥寒霜冰晶掌印", "拳掌内劲 · 极阴寒掌特效", "幽蓝寒冰掌印炸裂出森森冰棱碎晶，绑定玄冥寒毒掌。"),
    ("wx_vfx_11", "七伤赤煞震脉拳劲", "拳掌内劲 · 刚柔裂脉特效", "赤黑内劲自拳心轰然炸开七道裂脉纹路，绑定七伤总诀拳与震脉劲。"),
    ("wx_vfx_12", "一阳纯金贯日指芒", "拳掌内劲 · 隔空指劲特效", "凝聚全身纯阳真气贯透涟漪气环的金色指芒，绑定一阳指与剑指点穴。"),
    ("wx_vfx_13", "九阴森白撕裂爪痕", "拳掌内劲 · 奇门利爪特效", "五道暗紫带血的凌厉利爪撕裂残痕，绑定九阴摧心爪。"),
    ("wx_vfx_14", "雷霆万钧碎岳震环", "拳掌内劲 · 重钝轰击特效", "金紫雷电交织的环形大地崩裂冲击波，绑定雷霆碎岳锤与碎甲重击。"),
    ("wx_vfx_15", "太极阴阳化劲气旋", "拳掌内劲 · 借力卸劲特效", "水墨与青玉交融流转的阴阳太极化劲圆旋，绑定两仪剑、揽雀尾与夺刃。"),
    ("wx_vfx_16", "截脉点穴封气金环", "拳掌内劲 · 认穴封脉特效", "铭刻经络暗纹、三点金芒齐闪的封穴气环，绑定点穴截脉手。"),
    # Sheet 43 (17..32)
    ("wx_vfx_17", "金钟罩梵文护体金钟", "内功护体 · 沉岳硬功特效", "浮现古朴梵印暗纹的半透明古铜护体大钟，绑定金钟护体罡与明王盾。"),
    ("wx_vfx_18", "先天清气吐纳莲台", "内功护体 · 调息归元特效", "青碧真气盘旋托起清净莲花的吐纳灵光，绑定调息吐纳。"),
    ("wx_vfx_19", "北冥噬气黑紫漩涡", "内功护体 · 噬气导引特效", "吞噬周遭真元内息的幽暗紫黑气璇，绑定北冥噬气诀。"),
    ("wx_vfx_20", "燃血天魔赤煞气柱", "内功护体 · 燃血爆发特效", "冲天而起的暗红血焰与墨黑煞气柱，绑定燃血爆发魔功。"),
    ("wx_vfx_21", "寒冰真气六角霜环", "内功护体 · 寒玉护身特效", "自脚下向四周急速蔓延的寒冰棱刺霜阵，绑定极寒内功。"),
    ("wx_vfx_22", "杏林金针翠绿生机光", "内功护体 · 医家渡穴特效", "三枚金针悬空、翠叶灵气萦绕的疗伤光华，绑定金针渡穴与蓄势。"),
    ("wx_vfx_23", "金刚狮子吼音波震环", "军心音功 · 雷音威慑特效", "怒目金狮虚影咆哮荡开层层金色音波巨环，绑定金刚狮子吼与聚义令。"),
    ("wx_vfx_24", "聚义战旗赤金军心光环", "军心音功 · 统帅稳阵特效", "赤金战火升腾的脚下阵法光环，稳固四周同袍战意。"),
    ("wx_vfx_25", "凌波微步青烟残影", "轻功奇门 · 身法幻影特效", "水墨青烟勾勒出的潇洒武者瞬移残影，绑定凌波腾挪步与烟幕弹。"),
    ("wx_vfx_26", "梯云纵跃旋风气浪", "轻功奇门 · 拔地提纵特效", "螺旋拔地而起的苍青疾风气柱，绑定梯云纵跃步。"),
    ("wx_vfx_27", "暴雨梨花千枚银针幕", "轻功奇门 · 暗器攒射特效", "漫天寒星般倾泻而下的精钢飞针与柳叶镖雨，绑定满天星雨与折扇暗器。"),
    ("wx_vfx_28", "五毒碧璘剧毒奇瘴", "轻功奇门 · 南疆毒雾特效", "翻涌墨紫与碧绿毒气的剧毒瘴云，绑定五毒丧门钉与毒砂。"),
    ("wx_vfx_29", "唐门霹雳雷火爆炸云", "轻功奇门 · 火器轰炸特效", "赤橙火光与黑铁碎片四射的火药爆裂云，绑定霹雳雷火弹与神机火器。"),
    ("wx_vfx_30", "湘西控魂幽绿鬼火阵", "轻功奇门 · 尸傀邪术特效", "幽青磷火环绕升腾的控尸邪阵，用于古墓湘西尸傀妖道。"),
    ("wx_vfx_31", "钩镰天罗缚足铁锁网", "轻功奇门 · 擒拿困缚特效", "寒铁锁链与金丝捕网交错收拢的困敌特效，绑定钩镰拽与缠丝枷。"),
    ("wx_vfx_32", "灵蛇软鞭寒芒旋影", "轻功奇门 · 奇兵抽击特效", "如毒蛇游走并溅起血花的 S 形寒铁鞭影，绑定灵蛇锁喉鞭。"),
]

from expand_actives_shanhai_and_vfx_code import NEW_SHANHAI_16


def main():
    for snum, raw_p in RAW_SHEETS.items():
        if not os.path.exists(raw_p):
            raise FileNotFoundError(f"Missing generated sheet {snum}: {raw_p}")
        shutil.copy2(raw_p, os.path.join(SHEETS_DIR, f"sheet_{snum:02d}.jpg"))

    manifest_p = os.path.join(ART_DIR, "manifest.json")
    manifest = json.load(open(manifest_p, "r", encoding="utf-8"))

    # Add Stage `5_vfx` if not present!
    stage_ids = [s["id"] for s in manifest["stages"]]
    if "5_vfx" not in stage_ids:
        manifest["stages"].append({
            "id": "5_vfx",
            "name": "五、招式气芒与战斗特效",
            "desc": "刀剑罡气、真龙掌印、点穴金环、护体金钟、凌波残影与唐门雷火等 32 款原版 .brush 实机技能特效"
        })

    # Clean out any prior entries from this wave so script is idempotent
    wave_ids = set(
        [x[0] for x in SHEET39_SKILLS] +
        [x[0] for x in SHEET40_SKILLS] +
        [x[1] for x in SHEET41_ITEMS] +
        [x[0] for x in VFX_32_DEFS] +
        [f"wx_boss_{x[0]}" for x in NEW_SHANHAI_16] +
        [f"wx_lair_{x[0]}" for x in NEW_SHANHAI_16] +
        [f"wx_core_{x[0]}" for x in NEW_SHANHAI_16]
    )
    assets = [a for a in manifest["assets"] if a["id"] not in wave_ids]

    new_icons = []
    new_beasts = []
    new_vfx = []

    # 1. Process Sheets 39 & 40 (32 Active Skill Icons)
    for snum, defs in ((39, SHEET39_SKILLS), (40, SHEET40_SKILLS)):
        im = Image.open(os.path.join(SHEETS_DIR, f"sheet_{snum:02d}.jpg"))
        cw, ch = im.width // 4, im.height // 4
        for idx, (aid, nm, sub, brf) in enumerate(defs):
            r, c = divmod(idx, 4)
            hd_256, g_56, sw_56 = process_skill_square(im.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)))
            hd_rel = f"art/hd/{aid}.png"
            g_rel = f"art/game/skills/{aid}.png"
            sw_rel = f"art/game/skills/{aid}_sw.png"
            os.makedirs(os.path.join(ROOT, "art/game/skills"), exist_ok=True)
            hd_256.save(os.path.join(ROOT, hd_rel))
            g_56.save(os.path.join(ROOT, g_rel))
            sw_56.save(os.path.join(ROOT, sw_rel))
            new_icons.append({
                "id": aid, "stage": "1_icons", "group": "武学主动招式图标（全72式）",
                "name": nm, "sub": sub, "spec": "56×56 技能底栏图标 + _sw.png 置灰态",
                "slotKind": "skill56", "status": "wiki_ready", "hdPath": hd_rel, "previewPath": g_rel,
                "swPath": sw_rel, "smallPath": "",
                "gameTarget": f"gfx/skills/{aid}.png", "vanillaFallback": "skills/active_01.png",
                "codeRef": f"scripts/skills/actives/{aid}.nut", "brief": brf
            })

    # Also update existing 35 active skill group label in `assets` so all 72 appear unified!
    for a in assets:
        if a["stage"] == "1_icons" and "武学主动招式" in a["group"]:
            a["group"] = "武学主动招式图标（全72式）"

    # 2. Process Sheet 41 (6 Active Skills + 2 Statuses + 8 Company Crests)
    im41 = Image.open(os.path.join(SHEETS_DIR, "sheet_41.jpg"))
    cw, ch = im41.width // 4, im41.height // 4
    for idx, (kind, aid, nm, sub, brf) in enumerate(SHEET41_ITEMS):
        r, c = divmod(idx, 4)
        hd_256, g_56, sw_56 = process_skill_square(im41.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)))
        hd_rel = f"art/hd/{aid}.png"
        hd_256.save(os.path.join(ROOT, hd_rel))
        if kind == "skill":
            g_rel = f"art/game/skills/{aid}.png"
            sw_rel = f"art/game/skills/{aid}_sw.png"
            g_56.save(os.path.join(ROOT, g_rel))
            sw_56.save(os.path.join(ROOT, sw_rel))
            new_icons.append({
                "id": aid, "stage": "1_icons", "group": "武学主动招式图标（全72式）",
                "name": nm, "sub": sub, "spec": "56×56 技能底栏图标 + _sw.png 置灰态",
                "slotKind": "skill56", "status": "wiki_ready", "hdPath": hd_rel, "previewPath": g_rel,
                "swPath": sw_rel, "smallPath": "",
                "gameTarget": f"gfx/skills/{aid}.png", "vanillaFallback": "skills/active_01.png",
                "codeRef": f"scripts/skills/actives/{aid}.nut", "brief": brf
            })
        elif kind == "status":
            g_rel = f"art/game/skills/{aid}.png"
            g_56.save(os.path.join(ROOT, g_rel))
            new_icons.append({
                "id": aid, "stage": "1_icons", "group": "战斗状态与心法徽记",
                "name": nm, "sub": sub, "spec": "56×56 状态栏图标",
                "slotKind": "skill56", "status": "wiki_ready", "hdPath": hd_rel, "previewPath": g_rel,
                "swPath": "", "smallPath": "",
                "gameTarget": f"gfx/skills/{aid}.png", "vanillaFallback": "skills/status_effect_01.png",
                "codeRef": "mod_wuxia/systems/combat_rules.nut", "brief": brf
            })
        else:
            os.makedirs(os.path.join(ROOT, "art/game/ui/crests"), exist_ok=True)
            g_rel = f"art/game/ui/crests/{aid}.png"
            g_70 = hd_256.resize((70, 70), Image.Resampling.LANCZOS)
            g_70.save(os.path.join(ROOT, g_rel))
            new_icons.append({
                "id": aid, "stage": "1_icons", "group": "武林战团旗徽与门派纹章（8款）",
                "name": nm, "sub": sub, "spec": "70×70 战团徽章与出身图腾",
                "slotKind": "item70", "status": "wiki_ready", "hdPath": hd_rel, "previewPath": g_rel,
                "swPath": "", "smallPath": "",
                "gameTarget": f"gfx/ui/icons/{aid}.png", "vanillaFallback": "ui/banners/banner_01.png",
                "codeRef": "mod_wuxia/config/sects.nut", "brief": brf
            })

    # 3. Process Sheet 46 (16 New Shan Hai Neidan Cores #49..#64)
    im46 = Image.open(os.path.join(SHEETS_DIR, "sheet_46.jpg"))
    cw, ch = im46.width // 4, im46.height // 4
    os.makedirs(os.path.join(ROOT, "art/game/items/misc"), exist_ok=True)
    for idx, sdef in enumerate(NEW_SHANHAI_16):
        key, chap, bname, _, _, _, _, _, _, _, _, _, _, _, cname, _, cdesc, _, _, _, _, _, _, _ = sdef
        aid = f"wx_core_{key}"
        r, c = divmod(idx, 4)
        rgba = flood_white_bg(im46.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)))
        hd_256 = fit_rgba_centered(rgba, 256, 256, pad_x=18, pad_y=18, add_shadow=True)
        g_70 = fit_rgba_centered(rgba, 70, 70, pad_x=5, pad_y=5, add_shadow=True)
        hd_rel = f"art/hd/{aid}.png"
        g_rel = f"art/game/items/misc/{aid}.png"
        hd_256.save(os.path.join(ROOT, hd_rel))
        g_70.save(os.path.join(ROOT, g_rel))
        new_icons.append({
            "id": aid, "stage": "1_icons", "group": "山海六十四大妖内丹（64款）",
            "name": cname.replace("【山海内丹】", ""), "sub": f"{chap} · 灌顶 +350 武学火候",
            "spec": "70×70 背包灵丹图标", "slotKind": "item70", "status": "wiki_ready",
            "hdPath": hd_rel, "previewPath": g_rel, "swPath": "", "smallPath": "",
            "gameTarget": f"gfx/ui/items/misc/{aid}.png", "vanillaFallback": "misc/inventory_anatomists_book_01.png",
            "codeRef": "mod_wuxia/config/wx_shanhai.nut", "brief": cdesc
        })
    for a in assets:
        if a["id"].startswith("wx_core_"):
            a["group"] = "山海六十四大妖内丹（64款）"

    # 4. Process Sheets 44 & 45 (16 New Shan Hai Bosses + 16 New Shan Hai Lairs -> 64 total!)
    im44 = Image.open(os.path.join(SHEETS_DIR, "sheet_44.jpg"))
    im45 = Image.open(os.path.join(SHEETS_DIR, "sheet_45.jpg"))
    cw44, ch44 = im44.width // 4, im44.height // 4
    cw45, ch45 = im45.width // 4, im45.height // 4
    os.makedirs(os.path.join(ROOT, "art/game/entity/shanhai"), exist_ok=True)
    os.makedirs(os.path.join(ROOT, "art/game/world/lairs"), exist_ok=True)

    for idx, sdef in enumerate(NEW_SHANHAI_16):
        key, chap, bname, _, _, _, _, _, _, _, _, tname, tdesc, _, _, _, _, lname, ldesc, lbrush, _, _, _, _ = sdef
        r, c = divmod(idx, 4)
        # Boss bust
        bid = f"wx_boss_{key}"
        b_rgba = flood_white_bg(im44.crop((c * cw44, r * ch44, (c + 1) * cw44, (r + 1) * ch44)))
        b_hd = fit_rgba_centered(b_rgba, 256, 256, pad_x=12, pad_y=12, add_shadow=True)
        b_g = fit_rgba_centered(b_rgba, 128, 128, pad_x=6, pad_y=6, add_shadow=True)
        b_hd_rel = f"art/hd/{bid}.png"
        b_g_rel = f"art/game/entity/shanhai/{bid}.png"
        b_hd.save(os.path.join(ROOT, b_hd_rel))
        b_g.save(os.path.join(ROOT, b_g_rel))
        new_beasts.append({
            "id": bid, "stage": "4_beasts", "group": f"山海经六十四大妖 · {chap}",
            "name": bname.replace("【山海镇神】", "").replace("【山海神禽】", "").replace("【山海仁瑞】", "")
                         .replace("【山海古神】", "").replace("【山海神女】", "").replace("【山海凶兽】", "")
                         .replace("【山海妖皇】", "").replace("【山海凶蟒】", "").replace("【山海凶蛟】", "")
                         .replace("【山海异兽】", "").replace("【山海神兽】", "").replace("【山海瑞凶】", "")
                         .replace("【山海河伯】", "").replace("【山海尸神】", ""),
            "sub": f"{chap}大妖 · {tname}",
            "spec": "156×156 战场首领实体贴图 (wx_beasts_0.brush)",
            "slotKind": "boss", "status": "wiki_ready", "hdPath": b_hd_rel, "previewPath": b_g_rel,
            "swPath": "", "smallPath": "",
            "gameTarget": f"brushes/wx_beasts_0.brush#{bid}", "vanillaFallback": key,
            "codeRef": f"scripts/entity/tactical/enemies/{bid}.nut", "brief": tdesc
        })

        # World lair
        lid = f"wx_lair_{key}"
        l_rgba = flood_white_bg(im45.crop((c * cw45, r * ch45, (c + 1) * cw45, (r + 1) * ch45)))
        l_hd = fit_rgba_centered(l_rgba, 256, 256, pad_x=14, pad_y=14, add_shadow=True)
        l_g = fit_rgba_centered(l_rgba, 128, 128, pad_x=6, pad_y=6, add_shadow=True)
        l_hd_rel = f"art/hd/{lid}.png"
        l_g_rel = f"art/game/world/lairs/{lid}.png"
        l_hd.save(os.path.join(ROOT, l_hd_rel))
        l_g.save(os.path.join(ROOT, l_g_rel))
        new_beasts.append({
            "id": lid, "stage": "4_beasts", "group": "山海六十四秘境巢穴地标（64处）",
            "name": lname.replace("【山海秘境】", ""), "sub": f"{chap}大地图秘境地标",
            "spec": "164×124 大地图据点贴图 (wx_world_0.brush)",
            "slotKind": "boss", "status": "wiki_ready", "hdPath": l_hd_rel, "previewPath": l_g_rel,
            "swPath": "", "smallPath": "",
            "gameTarget": f"brushes/wx_world_0.brush#{lid}", "vanillaFallback": lbrush,
            "codeRef": f"scripts/entity/world/locations/wx_shanhai_{key}.nut", "brief": ldesc
        })
    for a in assets:
        if a["id"].startswith("wx_lair_"):
            a["group"] = "山海六十四秘境巢穴地标（64处）"

    # 5. Process Sheets 42 & 43 (32 Wuxia Combat Skill VFX Sprites -> Stage `5_vfx`)
    im42 = Image.open(os.path.join(SHEETS_DIR, "sheet_42.jpg"))
    im43 = Image.open(os.path.join(SHEETS_DIR, "sheet_43.jpg"))
    os.makedirs(os.path.join(ROOT, "art/game/effects"), exist_ok=True)
    for idx, (aid, nm, sub, brf) in enumerate(VFX_32_DEFS):
        src_sheet = im42 if idx < 16 else im43
        cw, ch = src_sheet.width // 4, src_sheet.height // 4
        r, c = divmod(idx % 16, 4)
        v_rgba = flood_white_bg(src_sheet.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)), bg_thresh=30, feather=28)
        v_hd = fit_rgba_centered(v_rgba, 256, 256, pad_x=14, pad_y=14, add_shadow=False)
        v_g = fit_rgba_centered(v_rgba, 136, 136, pad_x=6, pad_y=6, add_shadow=False)
        hd_rel = f"art/hd/{aid}.png"
        g_rel = f"art/game/effects/{aid}.png"
        v_hd.save(os.path.join(ROOT, hd_rel))
        v_g.save(os.path.join(ROOT, g_rel))
        grp = "刀剑枪戟气芒特效（8款）" if idx < 8 else (
              "拳掌指爪内劲特效（8款）" if idx < 16 else (
              "内功罡气与音功特效（8款）" if idx < 24 else "轻功残影与奇门毒火特效（8款）"))
        new_vfx.append({
            "id": aid, "stage": "5_vfx", "group": grp,
            "name": nm, "sub": sub,
            "spec": "136×136 战场招式特效贴图 (wx_effects_0.brush)",
            "slotKind": "boss", "status": "wiki_ready", "hdPath": hd_rel, "previewPath": g_rel,
            "swPath": "", "smallPath": "",
            "gameTarget": f"brushes/wx_effects_0.brush#{aid}", "vanillaFallback": "effect_slash_left",
            "codeRef": "mod_wuxia/systems/wx_vfx_system.nut", "brief": brf
        })

    # Insert into `assets` grouped cleanly by stage!
    s1_end = max(i for i, a in enumerate(assets) if a["stage"] == "1_icons") + 1
    assets[s1_end:s1_end] = new_icons
    s4_end = max(i for i, a in enumerate(assets) if a["stage"] == "4_beasts") + 1
    assets[s4_end:s4_end] = new_beasts
    assets.extend(new_vfx)

    manifest["version"] = "0.7.0-in-game-brushes-756"
    manifest["summary"]["total"] = len(assets)
    manifest["summary"]["wiki_ready"] = sum(1 for x in assets if x["status"] == "wiki_ready")
    manifest["summary"]["in_game"] = sum(1 for x in assets if x["status"] == "in_game")
    manifest["summary"]["planned"] = sum(1 for x in assets if x["status"] == "planned")
    manifest["assets"] = assets
    with open(manifest_p, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)

    print(f"SUCCESS: Processed Wave 39..46 (+128 new assets) -> Total manifest assets = {len(assets)}")


if __name__ == "__main__":
    main()
