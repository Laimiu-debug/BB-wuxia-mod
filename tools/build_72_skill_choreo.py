#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generates 16 high-clarity bespoke Wuxia FX element sprites (`art/fx_elements/wx_fx_*.png`)
for multi-layered tactical choreography in `wx_effects_0.brush`, and assigns 72/72 strictly
unique `WX_ChoreoID`s across all 72 active skill `.nut` scripts & `art/manifest.json`!
"""

import glob
import json
import math
import os
import re
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FX_DIR = os.path.join(ROOT, "art", "fx_elements")
SKILLS_DIR = os.path.join(ROOT, "mod_wuxia", "scripts", "skills", "actives")
MANIFEST_PATH = os.path.join(ROOT, "art", "manifest.json")

# 72 / 72 Strictly Unique Skill Choreography Definitions (ZERO duplicate labels or profiles!)
SKILL_CHOREO_72 = {
    # === 1. Sword (10 Unique Choreographies) ===
    "wx_sword_combo":     ("清风三叠·连环疾斩", "wx_anim_01", "combo3",      "#7cf5ff", "三道青碧弧光左右交错疾劈，连环三击步步进逼"),
    "wx_acupoint_strike": ("拂柳认穴·七星封脉", "wx_anim_01", "acupoint",    "#6ce8ff", "剑尖幻化北斗七星经络图直点膻中要穴"),
    "wx_sword_counter":   ("回锋守月·借剑反撩", "wx_anim_16", "counter",     "#a8dcff", "圆融剑幕格开来袭锋芒，寒光一闪反撩咽喉"),
    "wx_sword_pierce":    ("穿云破甲·螺旋贯胸", "wx_anim_09", "drill_lunge", "#d8f0ff", "压身蓄势化作银白音障螺旋剑锥透甲穿胸"),
    "wx_sword_duoming":   ("夺命三仙·幻影合击", "wx_anim_01", "clone3",      "#c8a2ff", "瞬息分出三道持剑残影自天地人三才合围绝杀"),
    "wx_sword_cuixin":    ("松风摧心·青旋透脏", "wx_anim_02", "spiral_stab", "#6ef2b8", "青苍松针剑旋聚于一点直透心脉震碎内息"),
    "wx_sword_dugu":      ("独孤破刃·九宫荡剑", "wx_anim_01", "disarm_arc",  "#e2b8ff", "九宫紫金剑理斜挑敌手兵刃，震飞长兵直取中宫"),
    "wx_sword_taiji":     ("两仪化劲·阴阳鱼阵", "wx_anim_16", "taiji_field", "#f2f6ff", "足下展开黑白阴阳太极剑图，柔云借力牵引震退"),
    "wx_sword_zhongjian": ("玄铁无锋·大巧崩山", "wx_anim_10", "gravity_cut", "#ffb85c", "乌金重剑挟千钧重力当头砸劈，大地崩裂岩浆迸溅"),
    "wx_sword_feixian":   ("天河落星·七曜剑雨", "wx_anim_02", "star_rain",   "#8cd6ff", "纵跃九霄引七道璀璨星河剑影自天幕斜坠攒刺"),
    "wx_sword_tianwai":   ("天外飞仙·御剑化虹", "wx_anim_02", "flying_虹",   "#fff099", "剑指一点本命飞剑悬空化作贯日长虹一闪断魂"),

    # === 2. Saber (8 Unique Choreographies) ===
    "wx_poise_charge":    ("沉刀按锷·虎踞蓄意", "wx_anim_03", "poise_draw",  "#ffad42", "按刀沉腰蓄积霸烈刀势，虎啸金芒沿刀脊节节暴涨"),
    "wx_saber_cleave":    ("劈空裂风·半月重斩", "wx_anim_03", "crescent",    "#ff7b47", "欺身踏步挥出炽烈半月刀罡正劈面门"),
    "wx_saber_duanyue":   ("断岳腾空·翻身碎岩", "wx_anim_03", "leap_cleave", "#ff6238", "拔地翻身自半空全力下劈，刀气斩裂山石飞溅"),
    "wx_saber_sweep":     ("八方狂澜·沧溟旋斩", "wx_anim_11", "tidal_sweep", "#4dc8ff", "刀卷怒涛化作三百六十度沧溟狂澜席卷四方"),
    "wx_saber_kuangfeng": ("狂风骤雨·六合乱刃", "wx_anim_04", "omnislash6",  "#b5f5ff", "快逾奔雷瞬息交织六道十字狂风刀网绞碎护甲"),
    "wx_saber_fanzhen":   ("两仪刀剑·冰火十字", "wx_anim_04", "twin_cross",  "#ff9d5c", "赤金刀芒与寒冰剑气十字交剪轰然炸裂"),
    "wx_saber_modao":     ("唐军陌刀·碎骑挑斩", "wx_anim_11", "modao_upcut", "#ff5247", "双手长柄陌刀自贴地斜撩而起，人马重铠一刀两断"),
    "wx_saber_ranmu":     ("燃木烈阳·焚天火柱", "wx_anim_03", "fire_pillar", "#ff4518", "至阳刀风摩擦成炎，引爆冲天赤金烈焰火柱"),
    "wx_saber_xuehai":    ("修罗血海·噬魂归元", "wx_anim_04", "blood_siphon","#ff2442", "妖异血月弯弧斩破血肉，漫天血珠倒卷入体回元"),

    # === 3. Fist / Palm / Finger / Claw (12 Unique Choreographies) ===
    "wx_fist_jab":        ("少林冲拳·连珠破风", "wx_anim_05", "rapid_jab",   "#ffd480", "双拳连环直冲打出两道凝实白金拳风气爆"),
    "wx_fist_shock":      ("贴山寸劲·隔甲透背", "wx_anim_05", "inch_pulse",  "#ffbe55", "寸距发力打出三层穿透躯干的透背内劲波纹"),
    "wx_fist_acupoint":   ("拈花一笑·金莲锁穴", "wx_anim_07", "lotus_poke",  "#ffe484", "金色禅莲飘旋指尖，隔空轻弹封闭奇经八脉"),
    "wx_fist_disarm":     ("空手入刃·盘龙夺兵", "wx_anim_08", "disarm_grab", "#9ce6ff", "欺入怀中双爪锁腕一拧，硬生生夺飞敌手兵刃"),
    "wx_fist_grapple":    ("擒龙探爪·虚空摄敌", "wx_anim_08", "vacuum_pull", "#ffb84d", "五指成爪生出金色旋涡吸力，隔空将敌手硬拽至身前"),
    "wx_fist_jingang":    ("大日如来·金刚巨掌", "wx_anim_05", "buddha_palm", "#ffd74a", "身后浮现丈六金身虚影，梵文巨掌当胸轰印"),
    "wx_fist_taiji":      ("揽雀云手·太极借力", "wx_anim_16", "taiji_orb",   "#b8f2ff", "双掌画圆凝成流转太极气球，四两拨千钧震飞强敌"),
    "wx_fist_qishang":    ("崆峒七伤·五行乱劲", "wx_anim_05", "prism5_hit",  "#ff6bf5", "一拳同发赤金青蓝紫五色阴阳乱劲层层内爆"),
    "wx_fist_jiuyin":     ("九阴白骨·鬼爪撕天", "wx_anim_08", "ghost_claw",  "#c85cff", "阴风惨惨五道紫黑森然鬼爪撕裂护甲直抓天灵"),
    "wx_fist_yiyang":     ("大理一阳·金虹贯日", "wx_anim_07", "sun_laser",   "#ffe866", "食指凝成炽白大日金虹瞬息洞穿全场"),
    "wx_fist_xuanming":   ("玄冥神掌·寒晶冰狱", "wx_anim_06", "frost_tomb",  "#4ce8ff", "森寒碧绿毒掌拍出，刺骨玄冰棱柱将敌冻结"),
    "wx_fist_xianglong":  ("亢龙有悔·真龙盘空", "wx_anim_05", "dragon_coil", "#ffcf40", "金色真气巨龙昂首咆哮破阵而出，盘旋回首余威不绝"),

    # === 4. Spear / Polearm / Staff (9 Unique Choreographies) ===
    "wx_spear_guard":     ("威远枪阵·拒马铁壁", "wx_anim_09", "spear_wall",  "#9ad8ff", "横枪顿地立起寒芒拒马枪阵，迎面逼退来犯之敌"),
    "wx_spear_thrust2":   ("百鸟朝凤·九影攒刺", "wx_anim_09", "phoenix9",    "#ff6e4a", "红缨急抖幻化九道赤金凤羽枪芒扇面攒刺"),
    "wx_spear_liuhua":    ("梨花暴雨·万点寒星", "wx_anim_09", "petal_storm", "#e8f6ff", "银枪如雪卷起漫天梨花寒星密集攒刺"),
    "wx_spear_bawang":    ("霸王挑山·破甲升龙", "wx_anim_09", "dragon_up",   "#ff8c38", "沉枪贯入甲缝猛然向上挑飞，霸道枪罡冲霄而起"),
    "wx_pole_sweep":      ("横扫千军·烈风龙卷", "wx_anim_11", "cyclone_pole","#ffd07a", "长兵满圆回旋卷起烈风沙尘横扫周身六合"),
    "wx_pole_goulian":    ("钩镰破甲·锁足倒拽", "wx_anim_11", "hook_pull",   "#75e6c8", "倒刺钩镰贴地横削锁住双足，猛力回拽令敌扑跌"),
    "wx_pole_fangtian":   ("方天画戟·无双月斩", "wx_anim_11", "halberd_x",   "#ff4242", "画戟高举劈出霸绝天下的赤黑双月十字斩"),
    "wx_staff_challenge": ("横杖顿地·金刚怒喝", "wx_anim_10", "taunt_slam",  "#ffc44d", "重杖轰然顿裂青石，金波扩散震慑全场敌胆"),
    "wx_staff_dagou":     ("打狗缠字·青竹盘根", "wx_anim_11", "bamboo_bind", "#5ef28a", "翠竹棒影如灵蛇盘树，道道青藤气环死死缠锁双腿"),

    # === 5. Hammer / Axe / Shield (8 Unique Choreographies) ===
    "wx_hammer_shatter":  ("震岳碎甲·崩星重击", "wx_anim_10", "armor_break", "#ffb84d", "八棱铁锤正面轰碎胸甲，碎裂甲片与金星四散迸射"),
    "wx_hammer_quake":    ("裂地崩山·三叠地刺", "wx_anim_10", "earth_wave",  "#ff7830", "腾空重锤砸地掀翻三格连环岩刺与赤红地裂"),
    "wx_hammer_leiting":  ("雷霆碎岳·九天落雷", "wx_anim_10", "sky_thunder", "#b88cff", "双锤引动九霄紫白狂雷轰顶劈落，电弧炸裂"),
    "wx_axe_split":       ("力劈华山·断盾裂颅", "wx_anim_10", "shield_split","#ff5e3a", "巨斧当头直劈将坚盾硬生生一分为二"),
    "wx_axe_whirl":       ("黑水狂斧·血风轮转", "wx_anim_11", "berserk_spin","#ff3d4d", "狂暴旋身化作赤红高速战斧绞肉风轮"),
    "wx_axe_kaishan":     ("盘古开天·巨钺分海", "wx_anim_10", "giant_axe",   "#ffd666", "凝聚数丈古铜开山神钺虚影劈开天地浊浪"),
    "wx_shield_bash_qi":  ("铁壁靠山·崩云撞击", "wx_anim_10", "shield_ram",  "#e6b86a", "沉肩持盾挟古铜气墙蛮横撞飞面前强敌"),
    "wx_shield_tiebi":    ("不动明王·玄武甲阵", "wx_anim_16", "hex_fortress","#ffcf5c", "周身浮现六合玄武金甲盾阵，刀剑矢石尽数弹开"),

    # === 6. Dagger / Whip / Flail / Bow / Crossbow / Throwing (14 Unique Choreographies) ===
    "wx_dagger_vital":    ("分水断脉·双刺剪血", "wx_anim_01", "twin_fang",   "#ff4d6d", "贴地滑步双刺交错剪开动脉，血线冲天迸裂"),
    "wx_dagger_fuxue":    ("鬼影附骨·瞬步背刺", "wx_anim_15", "backstab",    "#75d8ff", "化作黑烟消失原地，瞬息闪现敌后寒芒截脉"),
    "wx_dagger_execute":  ("幽冥绝杀·暗夜一线", "wx_anim_08", "night_exec",  "#d44dff", "天地骤暗唯余一道凄艳紫红死线横贯咽喉"),
    "wx_flail_lash":      ("云梦软鞭·越盾击顶", "wx_anim_11", "over_shield", "#ff9e5e", "铁链长鞭划出高抛弧线越过盾牌直抽天灵"),
    "wx_flail_entangle":  ("锁喉缠丝·三匝绞杀", "wx_anim_11", "neck_coil",   "#cbd8ff", "柔韧银索如毒蟒三匝缠紧脖颈猛力绞杀"),
    "wx_whip_suohou":     ("灵蛇出洞·青鳞毒鞭", "wx_anim_11", "viper_whip",  "#52f296", "长鞭化作昂首碧磷毒蛇闪电咬向咽喉"),
    "wx_bow_snipe":       ("流星追月·破音贯日", "wx_anim_12", "sonic_arrow", "#7ce8ff", "满月开弓扯出三道破音风环，银白流光一箭穿心"),
    "wx_bow_liuxing":     ("落日连珠·三矢追星", "wx_anim_12", "triple_arc",  "#ffcc52", "弓弦连响三支金翎火流星划破天际接踵轰落"),
    "wx_crossbow_shenji": ("神机劲弩·旋钢透甲", "wx_anim_12", "heavy_bolt",  "#a8e0ff", "踏张机括轰鸣射出高速旋转破甲乌钢重矢"),
    "wx_throwing_rain":   ("唐门暴雨·梨花千针", "wx_anim_13", "needle24",    "#c46bff", "青铜机匣怒张喷涌二十四道紫芒毒针覆盖敌阵"),
    "wx_throw_fan":       ("漫天花雨·七星飞刀", "wx_anim_13", "fan_knives7", "#9ee8ff", "扬手一振七柄寒星柳叶飞刀呈扇面旋飞攒射"),
    "wx_throw_duzhen":    ("五毒丧门·百足瘴钉", "wx_anim_13", "venom_spikes","#62f26f", "三枚倒刺丧门毒钉贯体，腾起碧绿毒骷瘴雾"),
    "wx_throw_pilidan":   ("霹雳雷火·赤硝轰天", "wx_anim_14", "bomb_arc",    "#ff6826", "黑铁雷火弹抛射轰爆，刺目白光与赤硝蘑菇云冲天"),
    "wx_smoke_cast":      ("奇门瘴雾·墨烟障目", "wx_anim_15", "smoke_screen","#9aa8b8", "樟脑烟弹碎裂涌出滚滚浓墨迷雾遮蔽敌军耳目"),

    # === 7. Neigong / Qinggong / Tactics (10 Unique Choreographies) ===
    "wx_meditate":        ("周天吐纳·三花聚顶", "wx_anim_16", "lotus_breath","#7ef5d8", "盘息敛气丹田升起三道清澄周天光环与灵韵光点"),
    "wx_blood_burst":     ("天魔燃血·赤焰破限", "wx_anim_04", "blood_flame", "#ff2b4a", "心脉擂鼓燃起滔天血焰真气，强行冲破行动极限"),
    "wx_neigong_jinzhong":("少林金钟·梵音护体", "wx_anim_16", "golden_bell", "#ffd64d", "一口镌刻梵文金钟虚影当头罩落，洪钟大吕万法不侵"),
    "wx_neigong_xixing":  ("北冥黑渊·鲸吞噬气", "wx_anim_06", "black_hole",  "#6b7cff", "掌心张开幽蓝北冥漩涡，强行鲸吞敌手护体内息"),
    "wx_qinggong_zongyue":("武当梯云·踏风登天", "wx_anim_15", "cloud_jump",  "#b5f5ff", "左足踏右足凭空拔起二段登云，潇洒飞越敌阵"),
    "wx_qinggong_lingbo": ("凌波微步·八卦残影", "wx_anim_15", "mirage_step", "#9ce8ff", "足踏洛书八卦水纹连留四道水墨残影，敌刃尽斩空处"),
    "wx_rally_command":   ("总瓢把令·帅旗招展", "wx_anim_16", "war_banner",  "#ffbf47", "高擎绛红金龙聚义帅旗迎风猎猎，金光涤荡全军畏惧"),
    "wx_tactics_jinzhen": ("扁鹊渡穴·五气金针", "wx_anim_07", "heal_needles","#7ef59e", "五枚毫芒金针悬空化弧精准渡入大穴，翠金生机涌流"),
    "wx_tactics_shihou":  ("佛门狮吼·五叠震魂", "wx_anim_16", "lion_roar",   "#ffd24c", "金毛怒狮法相仰天咆哮，五重金色音波震溃群敌心胆"),
}


def make_fx_sprites():
    os.makedirs(FX_DIR, exist_ok=True)
    S = 144

    def new_cv():
        return Image.new("RGBA", (S, S), (0, 0, 0, 0))

    # 1. wx_fx_bagua: Luminous Taiji Bagua Yin-Yang Array
    im = new_cv()
    d = ImageDraw.Draw(im)
    cx, cy = S // 2, S // 2
    d.ellipse([10, 10, S - 10, S - 10], outline=(190, 238, 255, 235), width=3)
    d.ellipse([20, 20, S - 20, S - 20], outline=(120, 205, 255, 190), width=2)
    d.pieslice([28, 28, S - 28, S - 28], 90, 270, fill=(235, 248, 255, 220))
    d.pieslice([28, 28, S - 28, S - 28], -90, 90, fill=(28, 42, 68, 225))
    d.ellipse([cx - 22, 28, cx + 22, cx], fill=(235, 248, 255, 225))
    d.ellipse([cx - 22, cx, cx + 22, S - 28], fill=(28, 42, 68, 225))
    d.ellipse([cx - 6, 44, cx + 6, 56], fill=(28, 42, 68, 240))
    d.ellipse([cx - 6, S - 56, cx + 6, S - 44], fill=(235, 248, 255, 240))
    for i in range(8):
        ang = i * math.pi / 4
        for r0 in (13, 17):
            x0 = cx + math.cos(ang - 0.14) * (S // 2 - r0)
            y0 = cy + math.sin(ang - 0.14) * (S // 2 - r0)
            x1 = cx + math.cos(ang + 0.14) * (S // 2 - r0)
            y1 = cy + math.sin(ang + 0.14) * (S // 2 - r0)
            d.line([(x0, y0), (x1, y1)], fill=(225, 245, 255, 220), width=2)
    im.filter(ImageFilter.GaussianBlur(0.5)).save(os.path.join(FX_DIR, "wx_fx_bagua.png"))

    # 2. wx_fx_golden_bell: Inscribed Buddhist Golden Bell Dome
    im = new_cv(); d = ImageDraw.Draw(im)
    d.pieslice([22, 16, S - 22, S - 14], 180, 360, fill=(255, 205, 64, 115), outline=(255, 232, 130, 245), width=3)
    d.rectangle([22, cx, S - 22, S - 20], fill=(255, 196, 52, 108), outline=(255, 232, 130, 235), width=3)
    d.ellipse([18, S - 28, S - 18, S - 10], outline=(255, 240, 160, 250), width=4)
    for x in (44, 72, 100):
        d.line([(x, 42), (x, S - 24)], fill=(255, 238, 155, 190), width=2)
        d.ellipse([x - 5, 68, x + 5, 78], fill=(255, 246, 190, 230))
    im.filter(ImageFilter.GaussianBlur(0.5)).save(os.path.join(FX_DIR, "wx_fx_golden_bell.png"))

    # 3. wx_fx_dragon_head: Roaring Golden Qi Dragon Head
    im = new_cv(); d = ImageDraw.Draw(im)
    d.polygon([(12, 82), (48, 42), (96, 30), (134, 54), (118, 72), (134, 92), (88, 104), (42, 98)], fill=(255, 194, 46, 235), outline=(255, 245, 180, 255))
    d.polygon([(38, 44), (14, 16), (62, 34)], fill=(255, 232, 120, 245))
    d.polygon([(52, 38), (28, 10), (76, 30)], fill=(255, 215, 88, 240))
    d.ellipse([86, 48, 104, 62], fill=(255, 255, 230, 255))
    d.line([(98, 68), (136, 66)], fill=(120, 42, 12, 220), width=3)
    im.filter(ImageFilter.GaussianBlur(0.6)).save(os.path.join(FX_DIR, "wx_fx_dragon_head.png"))

    # 4. wx_fx_sword_phantom: Blazing Celestial Flying Sword Phantom
    im = new_cv(); d = ImageDraw.Draw(im)
    d.polygon([(8, 72), (104, 63), (138, 72), (104, 81)], fill=(210, 246, 255, 245), outline=(110, 215, 255, 255))
    d.line([(16, 72), (134, 72)], fill=(255, 255, 255, 255), width=3)
    d.polygon([(34, 50), (44, 72), (34, 94), (26, 72)], fill=(255, 218, 110, 245))
    im.filter(ImageFilter.GaussianBlur(0.5)).save(os.path.join(FX_DIR, "wx_fx_sword_phantom.png"))

    # 5. wx_fx_ice_spikes: Xuanming Crystalline Ice Spikes
    im = new_cv(); d = ImageDraw.Draw(im)
    spikes = [((24, 126), (14, 56), (48, 126)), ((44, 128), (58, 22), (82, 128)), ((70, 128), (94, 30), (114, 128)), ((96, 126), (128, 52), (124, 126))]
    for tri in spikes:
        d.polygon(tri, fill=(92, 228, 255, 215), outline=(225, 252, 255, 250))
    im.filter(ImageFilter.GaussianBlur(0.4)).save(os.path.join(FX_DIR, "wx_fx_ice_spikes.png"))

    # 6. wx_fx_blood_orb: Crimson Blood-Essence Siphon Vortex
    im = new_cv(); d = ImageDraw.Draw(im)
    for r, a in ((56, 70), (42, 130), (28, 200), (16, 250)):
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(225, 24, 52, a))
    d.arc([16, 16, S - 16, S - 16], 20, 290, fill=(255, 130, 150, 240), width=4)
    im.filter(ImageFilter.GaussianBlur(0.8)).save(os.path.join(FX_DIR, "wx_fx_blood_orb.png"))

    # 7. wx_fx_sonic_ring: Buddhist Lion's Roar Golden Shockwave Ring
    im = new_cv(); d = ImageDraw.Draw(im)
    d.ellipse([10, 22, S - 10, S - 22], outline=(255, 216, 76, 245), width=5)
    d.ellipse([22, 34, S - 22, S - 34], outline=(255, 244, 175, 200), width=3)
    im.filter(ImageFilter.GaussianBlur(0.6)).save(os.path.join(FX_DIR, "wx_fx_sonic_ring.png"))

    # 8. wx_fx_gold_needle: Hair-Thin Gleaming Golden Acupuncture / Rain Needle
    im = new_cv(); d = ImageDraw.Draw(im)
    for dy in (-14, 0, 14):
        d.polygon([(18, cy + dy), (112, cy + dy - 3), (136, cy + dy), (112, cy + dy + 3)], fill=(255, 232, 115, 245))
    im.filter(ImageFilter.GaussianBlur(0.4)).save(os.path.join(FX_DIR, "wx_fx_gold_needle.png"))

    # 9. wx_fx_whip_arc: Coiling Serpent Whip / Iron Chain S-Curve
    im = new_cv(); d = ImageDraw.Draw(im)
    pts = []
    for i in range(28):
        t = i / 27.0
        px = 12 + t * 120
        py = cy + math.sin(t * math.pi * 2.2) * 34
        pts.append((px, py))
    d.line(pts, fill=(102, 245, 162, 245), width=6)
    d.line(pts, fill=(230, 255, 240, 250), width=2)
    im.filter(ImageFilter.GaussianBlur(0.5)).save(os.path.join(FX_DIR, "wx_fx_whip_arc.png"))

    # 10. wx_fx_thunder_bolt: Jagged Nine-Heavens Purple-White Lightning Bolt
    im = new_cv(); d = ImageDraw.Draw(im)
    bolt = [(78, 6), (52, 46), (82, 50), (44, 94), (74, 96), (56, 138)]
    d.line(bolt, fill=(186, 132, 255, 235), width=11)
    d.line(bolt, fill=(250, 245, 255, 255), width=4)
    im.filter(ImageFilter.GaussianBlur(0.5)).save(os.path.join(FX_DIR, "wx_fx_thunder_bolt.png"))

    # 11. wx_fx_earth_fissure: Tectonic Magma Ground Crack & Rock Spikes
    im = new_cv(); d = ImageDraw.Draw(im)
    d.polygon([(8, 108), (44, 92), (74, 106), (108, 88), (138, 108), (106, 122), (72, 114), (40, 124)], fill=(255, 104, 28, 235), outline=(255, 218, 110, 250))
    for x0, h0 in ((34, 56), (72, 42), (106, 58)):
        d.polygon([(x0 - 12, 108), (x0, h0), (x0 + 12, 108)], fill=(112, 88, 68, 245), outline=(255, 164, 68, 220))
    im.filter(ImageFilter.GaussianBlur(0.4)).save(os.path.join(FX_DIR, "wx_fx_earth_fissure.png"))

    # 12. wx_fx_banner_crest: Jianghu Crimson-Gold Command Flag Halo
    im = new_cv(); d = ImageDraw.Draw(im)
    d.line([(36, 14), (36, 132)], fill=(228, 185, 96, 255), width=5)
    d.polygon([(38, 20), (126, 34), (106, 58), (128, 82), (38, 92)], fill=(198, 34, 34, 235), outline=(255, 214, 98, 250))
    d.ellipse([60, 42, 92, 72], outline=(255, 226, 122, 245), width=3)
    im.filter(ImageFilter.GaussianBlur(0.4)).save(os.path.join(FX_DIR, "wx_fx_banner_crest.png"))

    # 13. wx_fx_poison_skull: Five-Venoms Emerald Miasma Cloud
    im = new_cv(); d = ImageDraw.Draw(im)
    for ox, oy, r in ((52, 76, 30), (92, 78, 28), (72, 54, 34)):
        d.ellipse([ox - r, oy - r, ox + r, oy + r], fill=(64, 218, 92, 175))
    d.ellipse([56, 46, 68, 58], fill=(220, 255, 140, 245))
    d.ellipse([76, 46, 88, 58], fill=(220, 255, 140, 245))
    im.filter(ImageFilter.GaussianBlur(1.2)).save(os.path.join(FX_DIR, "wx_fx_poison_skull.png"))

    # 14. wx_fx_lotus_seal: Acupoint Meridian Seven-Star Seal
    im = new_cv(); d = ImageDraw.Draw(im)
    d.ellipse([24, 24, S - 24, S - 24], outline=(124, 238, 255, 225), width=3)
    stars = [(42, 48), (62, 38), (82, 46), (92, 66), (86, 92), (108, 102), (116, 80)]
    d.line(stars, fill=(170, 245, 255, 220), width=2)
    for sx, sy in stars:
        d.ellipse([sx - 4, sy - 4, sx + 4, sy + 4], fill=(255, 250, 190, 255))
    im.filter(ImageFilter.GaussianBlur(0.4)).save(os.path.join(FX_DIR, "wx_fx_lotus_seal.png"))

    # 15. wx_fx_buddha_palm: Radiant Golden Vajra Palm Imprint
    im = new_cv(); d = ImageDraw.Draw(im)
    d.rounded_rectangle([44, 58, 100, 118], radius=16, fill=(255, 206, 58, 225), outline=(255, 248, 190, 255), width=3)
    for fx, fy, fh in ((36, 42, 28), (52, 22, 38), (70, 16, 44), (88, 24, 36), (104, 48, 28)):
        d.rounded_rectangle([fx - 6, fy, fx + 6, fy + fh], radius=5, fill=(255, 214, 72, 230), outline=(255, 248, 190, 245), width=2)
    d.ellipse([60, 76, 84, 100], outline=(185, 82, 18, 235), width=3)
    im.filter(ImageFilter.GaussianBlur(0.5)).save(os.path.join(FX_DIR, "wx_fx_buddha_palm.png"))

    # 16. wx_fx_claw_slash: Five-Talon Nine-Yin Purple Ghost Rip
    im = new_cv(); d = ImageDraw.Draw(im)
    for i in range(5):
        off = (i - 2) * 18
        d.polygon([(18, 26 + off), (76, 64 + off), (128, 116 + off), (70, 74 + off)], fill=(208, 86, 255, 240))
        d.line([(22, 28 + off), (124, 114 + off)], fill=(255, 225, 255, 245), width=2)
    im.filter(ImageFilter.GaussianBlur(0.5)).save(os.path.join(FX_DIR, "wx_fx_claw_slash.png"))


def update_skill_nuts_and_manifest():
    patched = 0
    for p in sorted(glob.glob(os.path.join(SKILLS_DIR, "*.nut"))):
        bn = os.path.splitext(os.path.basename(p))[0]
        if bn == "wx_move_base":
            continue
        if bn not in SKILL_CHOREO_72:
            raise RuntimeError(f"Missing choreography spec for {bn}!")
        lbl, anim_id, choreo_mode, color_hex, desc_note = SKILL_CHOREO_72[bn]
        src = open(p, "r", encoding="utf-8").read()

        # Replace or inject WX_AnimID, WX_AnimMode, and unique WX_ChoreoID = bn!
        src = re.sub(r'\s*this\.m\.WX_ChoreoID\s*<-\s*"[^"]*";', "", src)
        if "this.m.WX_AnimID" in src:
            src = re.sub(r'this\.m\.WX_AnimID\s*(?:<-|=)\s*"[^"]*";', f'this.m.WX_AnimID <- "{anim_id}";', src)
            src = re.sub(
                r'(this\.m\.WX_AnimMode\s*(?:<-|=)\s*"[^"]*";)',
                f'this.m.WX_AnimMode <- "{choreo_mode}";\n\t\tthis.m.WX_ChoreoID <- "{bn}";',
                src,
                count=1,
            )
        else:
            src = re.sub(
                r'(this\.m\.Overlay\s*=\s*"[^"]*";)',
                f'\\1\n\t\tthis.m.WX_AnimID <- "{anim_id}";\n\t\tthis.m.WX_AnimMode <- "{choreo_mode}";\n\t\tthis.m.WX_ChoreoID <- "{bn}";',
                src,
                count=1,
            )
        with open(p, "w", encoding="utf-8") as f:
            f.write(src)
        patched += 1

    manifest = json.load(open(MANIFEST_PATH, "r", encoding="utf-8"))
    for a in manifest["assets"]:
        aid = a["id"]
        if aid in SKILL_CHOREO_72:
            lbl, anim_id, choreo_mode, color_hex, desc_note = SKILL_CHOREO_72[aid]
            a["animId"] = anim_id
            a["animMode"] = choreo_mode
            a["choreoId"] = aid
            a["choreoLabel"] = lbl
            a["choreoColor"] = color_hex
            a["choreoDesc"] = desc_note
    with open(MANIFEST_PATH, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)
    print(f"Patched {patched} active skill .nut files and manifest.json with 72/72 unique WX_ChoreoIDs!")


if __name__ == "__main__":
    assert len(SKILL_CHOREO_72) == 72, f"Expected 72 skills, got {len(SKILL_CHOREO_72)}"
    assert len({v[0] for v in SKILL_CHOREO_72.values()}) == 72, "Duplicate choreo labels!"
    assert len({v[2] for v in SKILL_CHOREO_72.values()}) == 72, "Duplicate choreo modes!"
    make_fx_sprites()
    update_skill_nuts_and_manifest()
