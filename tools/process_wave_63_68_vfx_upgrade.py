#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Wave 63..68 Complete Wuxia Qi-Aura & 72-Skill Zero-Duplicate Action VFX Upgrade Pipeline:
  1. Copies & slices `sheet_63.jpg` -> 16 genuine hand-painted Battle Brothers Wuxia FX elements
     (`art/fx_elements/wx_fx_*.png`), replacing 100% of legacy Pillow geometric shapes!
  2. Copies & slices `sheet_64..68.jpg` -> +20 brand-new 4-frame hand-painted Wuxia action sequences
     (`wx_anim_17..36`, 80 new frames -> 36 pure hand-painted 4-frame sequences = 144 frames).
  3. Synthesizes `wx_anim_37..72` (36 bespoke skill-specific 4-frame sequences combining hand-painted
     base sequences + bespoke `wx_vfx_01..32` Qi-auras + `wx_fx_*` / `wx_proj_*` + hue/angle transforms)
     so ALL 72/72 Wuxia Active Skills own a strictly 1-to-1 unique 4-frame action sequence (`wx_anim_01..72`)!
  4. Patches all 72 `mod_wuxia/scripts/skills/actives/*.nut` files with their unique `WX_AnimID`,
     `WX_VfxBrush`, `WX_AnimMode`, and `WX_ChoreoID`, and updates `art/manifest.json`.
"""

from collections import deque
import colorsys
import glob
import json
import math
import os
import re
import shutil
import sys
from PIL import Image, ImageEnhance, ImageOps

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import build_wuxia_bust_system as bsys

ART_DIR = os.path.join(ROOT, "art")
SHEETS_DIR = os.path.join(ART_DIR, "sheets")
ANIM_DIR = os.path.join(ART_DIR, "anim")
FX_DIR = os.path.join(ART_DIR, "fx_elements")
SKILLS_DIR = os.path.join(ROOT, "mod_wuxia", "scripts", "skills", "actives")
MANIFEST_PATH = os.path.join(ART_DIR, "manifest.json")

BRAIN_DIR = r"C:\Users\25647\.gemini\antigravity\brain\57963b44-b384-49c8-b890-176d046c7072"

RAW_SHEETS = {
    "sheet_63.jpg": "raw_sheet_63_fx16_1795223588143.jpg",
    "sheet_64.jpg": "raw_sheet_64_anim_blade_1795223590704.jpg",
    "sheet_65.jpg": "raw_sheet_65_anim_fist_clean_1795223644940.jpg",
    "sheet_66.jpg": "raw_sheet_66_anim_pole_1795223594776.jpg",
    "sheet_67.jpg": "raw_sheet_67_anim_heavy_1795223604316.jpg",
    "sheet_68.jpg": "raw_sheet_68_anim_odd_1795223601603.jpg",
}

# 16 Hand-Painted FX Signature Elements from Sheet 63
FX16_DEFS = [
    (0, "wx_fx_bagua",        "先天八卦阴阳阵印", "太极奇门 · 脚下法阵与借力化劲元素", "水墨与青玉辉映的先天八卦阴阳双鱼大阵，供两仪化劲剑、揽雀云手与凌波微步叠加实装。"),
    (1, "wx_fx_golden_bell",  "少室梵文护体金钟", "佛门横练 · 沉岳护罩与反震金钟元素", "镌刻鎏金梵文真言的古铜护体大钟虚影，供金钟护体罡与横练反震实装。"),
    (2, "wx_fx_dragon_head",  "亢龙金罡咆哮龙首", "降龙至刚 · 破阵真龙冲击波核心元素", "穿破三重金环昂首怒啸的纯阳真气金龙首，供亢龙有悔掌与霸王升龙枪实装。"),
    (3, "wx_fx_sword_phantom","青冥化虹御空飞剑", "剑仙绝艺 · 凌空飞剑与夺兵残影元素", "裹挟金青剑罡破空疾掠的古剑幻影，供天外一剑、天河落星剑与夺刃式实装。"),
    (4, "wx_fx_ice_spikes",   "玄冥极寒碎晶冰刺", "苦寒阴毒 · 破地玄冰棱柱封冻元素", "自冻土骤然刺出的幽蓝玄冥冰晶棱柱群，供玄冥寒毒掌与寒冰真气实装。"),
    (5, "wx_fx_blood_orb",    "修罗噬魂赤煞血璇", "魔道血功 · 饮血归元与燃血气旋元素", "墨黑煞气缠绕的暗红噬魂血漩涡，供修罗饮血斩与天魔燃血功实装。"),
    (6, "wx_fx_sonic_ring",   "洪钟大吕雷音震环", "音功震慑 · 多重扩散音波冲击环元素", "迸发金电裂纹的三重同心纯金音波巨环，供金刚狮子吼、寸劲拳与破音贯刺实装。"),
    (7, "wx_fx_gold_needle",  "杏林五气渡穴金针", "医家奇门 · 悬空毫芒金针翠气元素", "拖曳翠绿生机灵气的五枚纯金毫针，供金针渡穴诀与梨花寒星攒刺实装。"),
    (8, "wx_fx_whip_arc",     "灵蛇锁链碧鳞鞭影", "软兵缠缚 · 毒蟒铁链S形抽击元素", "寒铁锁链与碧鳞毒蛇交融的S形凌厉鞭影，供灵蛇锁喉鞭、云梦软鞭与打狗棒实装。"),
    (9, "wx_fx_thunder_bolt", "九霄紫电狂雷轰顶", "风雷重兵 · 天降紫白霹雳电弧元素", "自九天劈落炸开碎电的紫白狂雷闪电，供雷霆碎岳锤与霹雳雷火实装。"),
    (10,"wx_fx_earth_fissure","崩山裂地熔岩地刺", "万钧重击 · 碎岩地裂与岩浆喷涌元素", "重兵轰击掀起的黑岩尖刺与赤金地裂熔火，供裂地崩山锤、重剑无锋与断岳斩实装。"),
    (11,"wx_fx_banner_crest", "聚义金龙烈焰帅旗", "统帅军心 · 猎猎绛红蟠龙战旗元素", "烈焰金芒环绕的绛红金龙聚义帅旗，供聚义号令与统帅定力光环实装。"),
    (12,"wx_fx_poison_skull", "南疆五毒碧璘骷髅瘴","五毒奇门 · 蚀骨毒烟与尸瘴毒雾元素", "翻涌紫黑与碧绿毒雾的五毒骷髅奇瘴，供五毒丧门钉、奇门烟幕与毒修实装。"),
    (13,"wx_fx_lotus_seal",   "北斗七星认穴封脉印","点穴截脉 · 七星经络金青锁环元素", "铭刻北斗七星连线与周天穴位的青金封脉环，供拂柳认穴剑与拈花点穴手实装。"),
    (14,"wx_fx_buddha_palm",  "大日如来法轮金掌", "禅宗绝学 · 掌心法轮万丈佛光元素", "掌心流转八辐法轮、放射万道金芒的如来巨掌，供金刚摧心掌实装。"),
    (15,"wx_fx_claw_slash",   "九阴森紫五指鬼爪痕","阴毒爪功 · 撕裂护甲暗紫血爪元素", "五道凌厉森然的暗紫带血利爪撕裂残痕，供九阴摧心爪与鬼影背刺实装。"),
]

# 20 Brand-New Pure Hand-Painted 4-Frame Sequences (`wx_anim_17..36`) from Sheets 64..68
NEW_ANIM_20_DEFS = [
    # Sheet 64
    ("wx_anim_17", "sheet_64.jpg", 0, "紫电三仙·四帧幻剑", "剑法序列动画 17 · 紫雷聚星→三剑分影→夺命交刺→电弧散逸", "紫电剑星骤亮，瞬息分出三柄紫雷幻剑并进攒刺，炸开耀眼雷十字剑芒。", "phantom_tri"),
    ("wx_anim_18", "sheet_64.jpg", 1, "两仪太极·四帧化剑", "剑法序列动画 18 · 水墨太极→双剑旋卸→阴阳双鱼震→清波归元", "水墨青玉太极圆转成形，双剑顺势旋引来劲，双鱼齐跃震散强敌锐气。", "bagua_wave"),
    ("wx_anim_19", "sheet_64.jpg", 2, "玄铁无锋·四帧崩山", "剑法序列动画 19 · 重剑沉环→乌金直劈→巨岩崩碎→琥珀尘环", "玄铁重剑激发千钧重力气环，大巧不工当头砸落，轰碎山岩掀起厚重尘浪。", "tectonic_cut"),
    ("wx_anim_20", "sheet_64.jpg", 3, "冰火两仪·四帧合璧", "刀剑序列动画 20 · 霜炎交汇→寒剑炎刀十字剪→冰火双爆→霜烬余烟", "寒冰剑气与烈阳刀芒左右并起，十字交剪轰然引爆冰棱与赤焰。", "cross_burst"),
    # Sheet 65
    ("wx_anim_21", "sheet_65.jpg", 0, "大日如来·四帧佛掌", "拳掌序列动画 21 · 宝轮金莲→烈焰佛掌压顶→金刚法阵轰印→梵光涟漪", "八辐金法轮庄严浮现，万丈金光巨掌自天际轰然按落，震开梵文护法金阵。", "sky_palm"),
    ("wx_anim_22", "sheet_65.jpg", 1, "崆峒七伤·四帧五劲", "拳掌序列动画 22 · 五行攒拳→五彩螺旋冲拳→七脉乱劲内爆→五气散烟", "赤金青蓝紫五行内劲聚于铁拳，螺旋轰入敌体引爆七道裂脉彩光。", "flurry6"),
    ("wx_anim_23", "sheet_65.jpg", 2, "拈花金莲·四帧封穴", "指法序列动画 23 · 禅莲盛放→金叶指虹→七星大穴锁印→飞瓣归寂", "八叶金莲于指端绽放，化作凝练金虹点中要穴，亮起七星封脉金印。", "seal_strike"),
    ("wx_anim_24", "sheet_65.jpg", 3, "北冥黑渊·四帧噬气", "内功序列动画 24 · 幽冥暗漩→归墟鲸吞旋涡→强夺真元蓝珠→寒渊余波", "掌心洞开深邃幽蓝冥海旋涡，强行扯出敌手真元光球鲸吞入体。", "siphon_back"),
    # Sheet 66
    ("wx_anim_25", "sheet_66.jpg", 0, "百鸟朝凤·四帧凰枪", "枪棒序列动画 25 · 朱雀燃魂→七道火凰枪芒→凤翼破甲爆→金翎飘火", "红缨化作展翅火凤啼鸣，七道赤金枪芒如百鸟朝凤攒刺贯破铁甲。", "flurry6"),
    ("wx_anim_26", "sheet_66.jpg", 1, "方天画戟·四帧双月", "枪棒序列动画 26 · 霸戟雷煞→赤黑双月交斩→碎铠十字血爆→残月煞痕", "方天画戟凝聚黑红霸气，双耳月牙划出撕裂天地的赤黑十字重斩。", "cross_burst"),
    ("wx_anim_27", "sheet_66.jpg", 2, "打狗缠竹·四帧盘根", "枪棒序列动画 27 · 翠竹旋风→青蛇棒影缠绕→三重竹环锁足→飞叶清风", "绿玉竹杖带起飞叶旋风，化作灵动青蛇盘绕敌腿连锁三重翠玉气环。", "whip_bind"),
    ("wx_anim_28", "sheet_66.jpg", 3, "钩镰破骑·四帧锁拽", "枪棒序列动画 28 · 寒钩乍现→铁链贴地横掠→倒刺锁足火星→曳尘回拉", "精钢钩镰闪出冷冽青芒，贴地挥锁双足猛力回拽，激起刺目金铁火星与烟尘。", "hook_pull"),
    # Sheet 67
    ("wx_anim_29", "sheet_67.jpg", 0, "雷霆碎岳·四帧落雷", "重兵序列动画 29 · 乌云紫电→神锤引雷轰落→狂雷碎甲爆坑→残雷焦环", "滚滚雷云汇聚紫白电蛇，重锤引动九霄落雷轰顶砸碎重铠与山石。", "sky_thunder"),
    ("wx_anim_30", "sheet_67.jpg", 1, "盘古开天·四帧巨钺", "重兵序列动画 30 · 炎钺燃罡→开山巨斧直劈→两半断岩火爆→分浪烟尘", "古铜巨钺腾起熊熊烈焰，自高空力劈而下将巨岩坚盾生生劈作两半。", "giant_axe"),
    ("wx_anim_31", "sheet_67.jpg", 2, "不动玄武·四帧铁壁", "盾卫序列动画 31 · 龟甲金符→六合玄武盾墙→弹剑碎刃金光→镇岳铜环", "玄武六角铜纹浮空凝合，筑起坚不可摧的金铜盾墙震断来犯刀剑。", "guard_dome"),
    ("wx_anim_32", "sheet_67.jpg", 3, "灵蛇锁喉·四帧毒鞭", "奇兵序列动画 32 · 碧虺盘信→S形毒鞭疾抽→三匝缠颈血溅→绿瘴游烟", "浸毒软鞭如碧鳞毒蛇昂首吐信，划出S形残影缠颈绞杀并爆开毒血。", "whip_bind"),
    # Sheet 68
    ("wx_anim_33", "sheet_68.jpg", 0, "幽冥断脉·四帧鬼刺", "短兵序列动画 33 · 墨烟寒眸→双刺剪喉交闪→凄艳紫红血线→暗影飞花", "刺客隐入浓墨鬼烟寒眸乍亮，双刺十字剪开咽喉留下一道凄艳紫红血线。", "cross_burst"),
    ("wx_anim_34", "sheet_68.jpg", 1, "落日连珠·四帧流星", "弓弩序列动画 34 · 金弓耀日→三矢破音流星→熔甲三连炎爆→火羽旋风", "满月金弓如烈日当空，三支火流星金箭破开音障接连轰碎铁甲。", "volley_rain"),
    ("wx_anim_35", "sheet_68.jpg", 2, "金刚狮吼·四帧雷音", "音功序列动画 35 · 金狮怒相→连环金圈扩音→震碎敌胆雷爆→九叠余音", "脑后显现怒目金毛雄狮法相，咆哮吐出层层纯金音波震碎群敌心胆。", "roar_rings"),
    ("wx_anim_36", "sheet_68.jpg", 3, "聚义号令·四帧帅旗", "统帅序列动画 36 · 帅旗顿地→赤焰金龙旗扬→蟠龙军心火阵→金星升腾", "聚义蟠龙帅旗轰然顿地，烈焰战意冲霄化作赤金龙纹大阵稳固三军。", "banner_halo"),
]

# 36 Bespoke Synthesized 4-Frame Sequences (`wx_anim_37..72`) so ALL 72/72 Skills Have 100% Unique 4-Frame Action Sequences!
# `(anim_id, base_anim, vfx_overlay, fx_overlay, hue_shift_deg, rot_deg, mirror_x, name, sub, brief)`
SYNTH_ANIM_36_DEFS = [
    ("wx_anim_37", "wx_anim_23", "wx_vfx_12", "wx_fx_lotus_seal",   155,   0, False, "拂柳七星·四帧认穴剑", "剑法序列动画 37 · 青星剑指→流云点刺→北斗封脉环→寒韵", "剑尖化出青碧北斗七星丝线，轻灵绕过守御精准点封膻中气穴。"),
    ("wx_anim_38", "wx_anim_18", "wx_vfx_01", "wx_fx_sword_phantom", 22,   0, True,  "回锋守月·四帧反撩剑", "剑法序列动画 38 · 圆月守剑→卸力格挡→银弧反撩→收剑清辉", "剑画满月格开敌刃火星，借势旋身一记冷冽银白剑弧反撩咽喉。"),
    ("wx_anim_39", "wx_anim_09", "wx_vfx_01", "wx_fx_lotus_seal",   -48, -12, False, "松风摧心·四帧青旋刺", "剑法序列动画 39 · 青松凝芒→翠风螺旋刺→透脏青爆→松针散气", "巴山青松寒气聚于剑尖，高速青翠气旋直透伤敌心脉。"),
    ("wx_anim_40", "wx_anim_17", "wx_vfx_07", "wx_fx_sword_phantom", 88,  15, False, "独孤破刃·四帧荡剑式", "剑法序列动画 40 · 紫金剑理→斜挑断势→十字破刃印→飞兵残芒", "洞悉破绽一剑斜挑，赤金十字剑印硬生生荡散盾墙枪阵。"),
    ("wx_anim_41", "wx_anim_02", "wx_vfx_08", "wx_fx_sword_phantom", 36,  32, False, "天河落星·四帧飞剑雨", "剑法序列动画 41 · 星图剑阵→五剑斜坠→寒星攒刺爆→星屑流光", "半空星河剑图大盛，五柄青冥寒剑自九天斜掠倾泻攒刺敌身。"),
    ("wx_anim_42", "wx_anim_03", "wx_vfx_24", "wx_fx_sonic_ring",    18,   0, False, "虎踞按锷·四帧蓄刀势", "刀法序列动画 42 · 按刀敛火→虎啸金环→刀脊燃罡→霸气凝身", "五指按紧刀镡沉腰蓄势，脚下升起赤金火环令下一刀威力倍增。"),
    ("wx_anim_43", "wx_anim_30", "wx_vfx_02", "wx_fx_sonic_ring",   -12, -18, True,  "五虎断门·四帧烈刀劈", "刀法序列动画 43 · 猛虎起刀→炽烈半月斩→劈门裂甲爆→火浪翻卷", "猛虎下山之势挥出炽盛半月火刀罡，正面劈裂坚甲木盾。"),
    ("wx_anim_44", "wx_anim_19", "wx_vfx_05", "wx_fx_earth_fissure",-18,  10, False, "断岳腾空·四帧碎岩斩", "刀法序列动画 44 · 拔地跃刀→赤琥重刀砸劈→崩岩裂地→碎石飞溅", "旱地拔葱翻身下劈，沉猛刀罡将青石地面斩出数尺裂谷。"),
    ("wx_anim_45", "wx_anim_11", "wx_vfx_21", "wx_fx_sonic_ring",   175,   0, False, "八方狂澜·四帧沧溟斩", "刀法序列动画 45 · 怒涛涌动→沧溟寒浪旋斩→三百六十度水龙卷→浪花", "宝刀卷起汹涌沧海碧涛，化作三百六十度狂澜刀涡席卷群敌。"),
    ("wx_anim_46", "wx_anim_01", "wx_vfx_26", "wx_fx_claw_slash",    24, -22, True,  "狂风骤雨·四帧六合刀", "刀法序列动画 46 · 朔风疾闪→六合乱刃刀网→狂飙割裂爆→残风血珠", "大漠狂风裹挟快刀瞬息连劈六记，交织成密不透风的银青刀网。"),
    ("wx_anim_47", "wx_anim_26", "wx_vfx_05", "wx_fx_earth_fissure", 14, -28, False, "唐军陌刀·四帧碎骑撩", "刀法序列动画 47 · 沉锋贴地→赤电长刀斜撩→人马俱碎爆→血尘冲霄", "双手嗣业长陌刀贴地逆撩而起，霸烈赤芒自下而上将重骑劈飞。"),
    ("wx_anim_48", "wx_anim_05", "wx_vfx_09", "wx_fx_sonic_ring",    16,   0, True,  "寸劲破风·四帧连珠拳", "拳掌序列动画 48 · 沉肘敛气→双拳连珠音爆→透甲金拳印→破风气圈", "一寸之距骤然发力，双拳连环打出刺耳白金音爆气环直透胸甲。"),
    ("wx_anim_49", "wx_anim_22", "wx_vfx_11", "wx_fx_sonic_ring",   -28,   8, False, "贴山透背·四帧震脉劲", "拳掌序列动画 49 · 贴身凝煞→三叠暗红冲击波→隔甲裂脉爆→震荡残波", "肩拳贴山一撞，三层暗红透背波纹隔着重铠将内腑震裂。"),
    ("wx_anim_50", "wx_anim_28", "wx_vfx_15", "wx_fx_sword_phantom", 35,  20, True,  "空手入刃·四帧夺兵手", "拳掌序列动画 50 · 欺身锁腕→盘龙旋拧→震飞兵刃寒光→擒拿收势", "欺入白刃之间双爪叩腕猛拧，将敌手兵刃硬生生夺飞半空。"),
    ("wx_anim_51", "wx_anim_24", "wx_vfx_09", "wx_fx_dragon_head",  135,   0, True,  "擒龙探爪·四帧摄敌功", "拳掌序列动画 51 · 金爪虚张→苍龙吸力旋涡→隔空硬拽金芒→震地尘环", "五指成爪催动纯阳吸力金璇，隔着两格将强敌硬生生摄至面前。"),
    ("wx_anim_52", "wx_anim_18", "wx_vfx_15", "wx_fx_bagua",        -20,  25, False, "揽雀云手·四帧太极掌", "拳掌序列动画 52 · 云手画圆→太极气球流转→四两拨千斤震退→清风", "双掌绵绵画圆凝成阴阳气球，顺势一送将莽汉连人带甲震飞。"),
    ("wx_anim_53", "wx_anim_31", "wx_vfx_03", "wx_fx_sonic_ring",   165,   0, False, "威远枪阵·四帧拒马壁", "枪棒序列动画 53 · 攒枪顿地→寒铁拒马枪墙→迎面攒刺反击→银星护阵", "长枪斜指筑起森严寒芒枪阵，凡踏入半步者立遭迎头痛刺。"),
    ("wx_anim_54", "wx_anim_25", "wx_vfx_27", "wx_fx_gold_needle",  185,   0, False, "梨花暴雨·四帧寒星枪", "枪棒序列动画 54 · 银缨抖雪→漫天梨花枪星→万点寒芒透甲→瑞雪飞花", "银枪急抖幻出万点冰雪梨花寒星，笼罩两格令敌避无可避。"),
    ("wx_anim_55", "wx_anim_09", "wx_vfx_02", "wx_fx_dragon_head", -145, -35, False, "霸王挑山·四帧升龙枪", "枪棒序列动画 55 · 沉枪贯缝→赤金升龙猛挑→挑飞碎甲烈爆→冲霄霸气", "大枪贯入重甲缝隙猛然上挑，赤金升龙枪罡将敌手挑飞震退。"),
    ("wx_anim_56", "wx_anim_35", "wx_vfx_14", "wx_fx_earth_fissure",-14,   0, False, "横杖顿地·四帧怒喝威", "枪棒序列动画 56 · 禅杖高擎→顿裂青石金波→金刚怒喝锁敌→镇山铜韵", "混铁禅杖轰然顿裂大地，金雷音波席卷迫使强敌不敢妄动。"),
    ("wx_anim_57", "wx_anim_10", "wx_vfx_14", "wx_fx_sonic_ring",    22, -10, True,  "震岳碎甲·四帧崩星锤", "重兵序列动画 57 · 重锤蓄雷→流星当胸猛砸→铁甲四分五裂→金星飞迸", "八棱重锤挟万钧巨力正面轰中护心镜，碎铁甲片漫天飞溅。"),
    ("wx_anim_58", "wx_anim_30", "wx_vfx_02", "wx_fx_earth_fissure", -22,  12, False, "力劈华山·四帧断盾斧", "重兵序列动画 58 · 双手举斧→赤炎直劈天灵→木铁坚盾崩裂→碎木火星", "巨斧自头顶笔直劈落，狂暴火罡将面前大盾连同肩甲一劈两断。"),
    ("wx_anim_59", "wx_anim_11", "wx_vfx_06", "wx_fx_blood_orb",    -32,  24, True,  "旋风断魂·四帧血轮斧", "重兵序列动画 59 · 狂血起旋→赤黑战斧风轮→横扫三敌撕裂→血雾飞旋", "黑水战帮狂暴旋身，巨斧化作腥红高速绞肉风轮横扫周身。"),
    ("wx_anim_60", "wx_anim_31", "wx_vfx_05", "wx_fx_golden_bell",  -16,   0, True,  "铁壁靠山·四帧撞山盾", "盾卫序列动画 60 · 沉肩蓄劲→古铜气墙猛撞→崩云震退碎石→余威护身", "肩顶大盾催动横练气墙蛮横冲撞，将当面之敌硬生生撞翻击退。"),
    ("wx_anim_61", "wx_anim_33", "wx_vfx_25", "wx_fx_claw_slash",   150,  18, True,  "鬼影附骨·四帧瞬背刺", "短兵序列动画 61 · 青烟遁形→敌后鬼影乍现→分筋透骨寒刺→墨影敛迹", "身形化作青墨轻烟瞬息绕至敌后，专寻破绽一匕刺入骨缝。"),
    ("wx_anim_62", "wx_anim_08", "wx_vfx_30", "wx_fx_claw_slash",    34, -15, False, "幽冥绝杀·四帧暗夜刺", "短兵序列动画 62 · 夜幕森寒→幽紫一线断喉→鬼火血泉迸裂→残魂幽烟", "天地骤暗唯余一道妖异紫绿寒光划过咽喉，专斩垂死残敌。"),
    ("wx_anim_63", "wx_anim_32", "wx_vfx_31", "wx_fx_whip_arc",    -115, -16, True,  "云梦软鞭·四帧越盾抽", "奇兵序列动画 63 · 铁链高抛→金赤鞭弧越盾→当头抽裂脑门→回鞭脆响", "九节铁鞭划出高抛金赤弧线绕过盾牌，重重抽击敌首天灵。"),
    ("wx_anim_64", "wx_anim_28", "wx_vfx_31", "wx_fx_whip_arc",      52,  18, False, "锁喉缠丝·四帧绞杀索", "奇兵序列动画 64 · 银索飞旋→三匝铁网缠颈→窒息封穴电光→收索冷芒", "柔韧银索如天罗铁网连绕脖颈三匝，猛力收紧令敌窒息封脉。"),
    ("wx_anim_65", "wx_anim_12", "wx_vfx_29", "wx_fx_sonic_ring",    68,   0, False, "神机劲弩·四帧透甲矢", "弓弩序列动画 65 · 机括怒张→旋钢乌矢破音→轰穿重铠火光→硝烟铁屑", "踏张神臂弩弦雷鸣，四棱乌钢重矢撕裂音障轰穿重铠护心镜。"),
    ("wx_anim_66", "wx_anim_13", "wx_vfx_27", "wx_fx_sword_phantom", 75,  14, True,  "漫天花雨·四帧七星镖", "暗器序列动画 66 · 十指齐扬→七柄柳叶飞刀扇射→连环穿甲寒芒→残星", "十指连弹洒出漫天寒星柳叶飞刀，覆盖敌阵令数人同露破绽。"),
    ("wx_anim_67", "wx_anim_13", "wx_vfx_28", "wx_fx_poison_skull", -42,  -8, False, "五毒丧门·四帧瘴钉雨", "暗器序列动画 67 · 乌筒碧光→倒刺丧门毒钉→蚀骨骷髅毒爆→浓绿奇瘴", "南疆五毒暗器破空攒入血肉，瞬间腾起蚀骨销魂的碧绿骷髅瘴云。"),
    ("wx_anim_68", "wx_anim_15", "wx_vfx_28", "wx_fx_poison_skull",  28,   0, True,  "奇门瘴雾·四帧墨烟弹", "奇门序列动画 68 · 陶丸碎裂→樟脑墨烟翻涌→遮天迷雾障目→暗影潜行", "奇门烟弹掷地炸开滚滚浓墨迷雾，彻底遮断敌军弓弩视线。"),
    ("wx_anim_69", "wx_anim_16", "wx_vfx_18", "wx_fx_lotus_seal",   128,   0, False, "周天吐纳·四帧清莲功", "内功序列动画 69 · 丹田聚气→青碧莲台升腾→三花聚顶归元→清气缭绕", "盘膝敛神引动奇经八脉，脚下托起青碧净莲涤荡周身疲敝浊气。"),
    ("wx_anim_70", "wx_anim_04", "wx_vfx_20", "wx_fx_blood_orb",     -8,   0, True,  "天魔燃血·四帧破限功", "内功序列动画 70 · 心脉擂鼓→冲天赤黑血焰→魔煞破限气爆→血火缠身", "逆催心头精血化作滔天赤黑魔焰气柱，强行冲破肉身行动极限。"),
    ("wx_anim_71", "wx_anim_15", "wx_vfx_26", "wx_fx_sonic_ring",   -24, -14, False, "武当梯云·四帧登天步", "轻功序列动画 71 · 足踏旋风→苍青气柱拔地→二段凭空纵跃→流云残影", "左足借右足之力卷起苍青旋风气浪，拔地纵跃潇洒飞越重围。"),
    ("wx_anim_72", "wx_anim_23", "wx_vfx_22", "wx_fx_gold_needle",   62,   0, False, "扁鹊渡穴·四帧济世针", "杂学序列动画 72 · 翠叶灵光→五枚金针悬渡→奇经拔毒生春→暖玉生机", "五枚毫芒金针裹挟温润翠玉药气渡入大穴，立止流血拔除奇毒。"),
]

# Complete 72 / 72 Active Skill Master Choreography Table:
# `skill_id: (choreo_label, unique_anim_id, anim_mode, vfx_qi_aura, sig_fx, color_hex, choreo_desc)`
# Notice:
#   - 72/72 unique `choreo_label`s
#   - 72/72 unique `unique_anim_id`s (`wx_anim_01` .. `wx_anim_72`)!
#   - 72/72 unique `anim_mode`s!
#   - All 32 `wx_vfx_01..32` Qi-auras & all 16 `wx_fx_*` signature sprites integrated!
SKILL_CHOREO_72 = {
    # === 1. Sword (11) ===
    "wx_sword_combo":     ("清风三叠·连环疾斩", "wx_anim_01", "combo3",       "wx_vfx_01", "wx_fx_sword_phantom", "#7cf5ff", "三道青碧弧光左右交错疾劈，连环三击步步进逼"),
    "wx_acupoint_strike": ("拂柳认穴·七星封脉", "wx_anim_37", "acupoint",     "wx_vfx_12", "wx_fx_lotus_seal",    "#6ce8ff", "剑尖幻化北斗七星经络图直点膻中要穴"),
    "wx_sword_counter":   ("回锋守月·借剑反撩", "wx_anim_38", "counter",      "wx_vfx_01", "wx_fx_bagua",         "#a8dcff", "圆融剑幕格开来袭锋芒，寒光一闪反撩咽喉"),
    "wx_sword_pierce":    ("穿云破甲·螺旋贯胸", "wx_anim_09", "drill_lunge",  "wx_vfx_03", "wx_fx_sonic_ring",    "#d8f0ff", "压身蓄势化作银白音障螺旋剑锥透甲穿胸"),
    "wx_sword_duoming":   ("夺命三仙·幻影合击", "wx_anim_17", "clone3",       "wx_vfx_04", "wx_fx_sword_phantom", "#c8a2ff", "瞬息分出三道持剑紫电残影自天地人三才合围绝杀"),
    "wx_sword_cuixin":    ("松风摧心·青旋透脏", "wx_anim_39", "spiral_stab",  "wx_vfx_01", "wx_fx_lotus_seal",    "#6ef2b8", "青苍松针剑旋聚于一点直透心脉震碎内息"),
    "wx_sword_dugu":      ("独孤破刃·九宫荡剑", "wx_anim_40", "disarm_arc",   "wx_vfx_07", "wx_fx_sword_phantom", "#e2b8ff", "九宫紫金剑理斜挑敌手兵刃，十字剑印荡破守势"),
    "wx_sword_taiji":     ("两仪化劲·阴阳鱼阵", "wx_anim_18", "taiji_field",  "wx_vfx_15", "wx_fx_bagua",         "#9ef2e8", "足下展开水墨青玉太极剑图，双鱼旋引震散敌劲"),
    "wx_sword_zhongjian": ("玄铁无锋·大巧崩山", "wx_anim_19", "gravity_cut",  "wx_vfx_05", "wx_fx_earth_fissure", "#ffb85c", "乌金重剑挟千钧重力当头砸劈，巨岩崩碎尘浪翻涌"),
    "wx_sword_feixian":   ("天河落星·七曜剑雨", "wx_anim_41", "star_rain",    "wx_vfx_08", "wx_fx_sword_phantom", "#8cd6ff", "纵跃九霄引漫天璀璨星河飞剑自天幕斜坠攒刺"),
    "wx_sword_tianwai":   ("天外飞仙·御剑化虹", "wx_anim_02", "flying_虹",    "wx_vfx_07", "wx_fx_sword_phantom", "#fff099", "剑指一点本命飞剑悬空化作贯日长虹一闪断魂"),

    # === 2. Saber (9) ===
    "wx_poise_charge":    ("沉刀按锷·虎踞蓄意", "wx_anim_42", "poise_draw",   "wx_vfx_24", "wx_fx_sonic_ring",    "#ffad42", "按刀沉腰燃起赤金虎踞火环，刀脊金芒节节暴涨"),
    "wx_saber_cleave":    ("劈空裂风·半月重斩", "wx_anim_43", "crescent",     "wx_vfx_02", "wx_fx_sonic_ring",    "#ff7b47", "欺身踏步挥出炽烈半月火刀罡正劈面门"),
    "wx_saber_duanyue":   ("断岳腾空·翻身碎岩", "wx_anim_44", "leap_cleave",  "wx_vfx_05", "wx_fx_earth_fissure", "#ff6238", "拔地翻身自半空全力下劈，刀气斩裂山石飞溅"),
    "wx_saber_sweep":     ("八方狂澜·沧溟旋斩", "wx_anim_45", "tidal_sweep",  "wx_vfx_21", "wx_fx_sonic_ring",    "#4dc8ff", "刀卷怒涛化作三百六十度沧溟寒浪刀涡席卷扇面"),
    "wx_saber_kuangfeng": ("狂风骤雨·六合乱刃", "wx_anim_46", "omnislash6",   "wx_vfx_26", "wx_fx_claw_slash",    "#b5f5ff", "快逾奔雷瞬息交织六道狂风刀网割裂血脉"),
    "wx_saber_fanzhen":   ("两仪刀剑·冰火十字", "wx_anim_20", "twin_cross",   "wx_vfx_21", "wx_fx_ice_spikes",    "#ff9d5c", "烈阳赤刀与寒霜冰剑十字交剪轰然双爆"),
    "wx_saber_modao":     ("唐军陌刀·碎骑挑斩", "wx_anim_47", "modao_upcut",  "wx_vfx_05", "wx_fx_earth_fissure", "#ff5247", "双手长柄陌刀贴地逆撩而起，霸烈刀罡劈飞强敌"),
    "wx_saber_ranmu":     ("燃木烈阳·焚天火柱", "wx_anim_03", "fire_pillar",  "wx_vfx_02", "wx_fx_earth_fissure", "#ff4518", "至阳刀风摩擦成炎，引爆冲天赤金烈焰火柱"),
    "wx_saber_xuehai":    ("修罗血海·噬魂归元", "wx_anim_04", "blood_siphon", "wx_vfx_06", "wx_fx_blood_orb",     "#ff2442", "妖异血月旋刃斩破血肉，漫天赤血珠倒卷入体回元"),

    # === 3. Fist / Palm / Finger / Claw (12) ===
    "wx_fist_jab":        ("少林冲拳·连珠破风", "wx_anim_48", "rapid_jab",    "wx_vfx_09", "wx_fx_sonic_ring",    "#ffd480", "双拳连环直冲打出两道凝实白金破风拳印气爆"),
    "wx_fist_shock":      ("贴山寸劲·隔甲透背", "wx_anim_49", "inch_pulse",   "wx_vfx_11", "wx_fx_sonic_ring",    "#ff7855", "寸距发力打出三层穿透重铠的赤煞裂脉冲击波"),
    "wx_fist_acupoint":   ("拈花一笑·金莲锁穴", "wx_anim_23", "lotus_poke",   "wx_vfx_16", "wx_fx_lotus_seal",    "#ffe484", "八叶金莲绽于指尖，隔空轻弹锁死奇经八脉金环"),
    "wx_fist_disarm":     ("空手入刃·盘龙夺兵", "wx_anim_50", "disarm_grab",  "wx_vfx_15", "wx_fx_sword_phantom", "#9ce6ff", "欺入怀中双爪锁腕猛拧，硬生生夺飞敌手兵刃"),
    "wx_fist_grapple":    ("擒龙探爪·虚空摄敌", "wx_anim_51", "vacuum_pull",  "wx_vfx_09", "wx_fx_dragon_head",   "#ffb84d", "五指成爪催动金龙旋涡吸力，隔空将敌手硬拽至身前"),
    "wx_fist_jingang":    ("大日如来·金刚巨掌", "wx_anim_21", "buddha_palm",  "wx_vfx_09", "wx_fx_buddha_palm",   "#ffd74a", "八辐法轮耀世，万丈如来金掌自天际当胸轰印"),
    "wx_fist_taiji":      ("揽雀云手·太极借力", "wx_anim_52", "taiji_orb",    "wx_vfx_15", "wx_fx_bagua",         "#b8f2ff", "双掌画圆凝成流转阴阳气球，四两拨千斤震退来敌"),
    "wx_fist_qishang":    ("崆峒七伤·五行乱劲", "wx_anim_22", "prism5_hit",   "wx_vfx_11", "wx_fx_blood_orb",     "#ff6bf5", "一拳同发赤金青蓝紫五行七股暗劲层层裂脉内爆"),
    "wx_fist_jiuyin":     ("九阴白骨·鬼爪撕天", "wx_anim_08", "ghost_claw",   "wx_vfx_13", "wx_fx_claw_slash",    "#c85cff", "阴风惨惨五道紫黑森然利爪撕裂护甲直扣天灵"),
    "wx_fist_yiyang":     ("大理一阳·金虹贯日", "wx_anim_07", "sun_laser",    "wx_vfx_12", "wx_fx_lotus_seal",    "#ffe866", "食指凝成炽白纯阳贯日指芒隔空两格洞穿经脉"),
    "wx_fist_xuanming":   ("玄冥神掌·寒晶冰狱", "wx_anim_06", "frost_tomb",   "wx_vfx_10", "wx_fx_ice_spikes",    "#4ce8ff", "极阴寒冰掌浪拍至，刺骨玄冥冰棱拔地冻结真元"),
    "wx_fist_xianglong":  ("亢龙有悔·真龙盘空", "wx_anim_05", "dragon_coil",  "wx_vfx_09", "wx_fx_dragon_head",   "#ffcf40", "金色真气巨龙昂首穿环咆哮破阵，烙下撼天金龙掌印"),

    # === 4. Spear / Polearm / Staff (9) ===
    "wx_spear_guard":     ("威远枪阵·拒马铁壁", "wx_anim_53", "spear_wall",   "wx_vfx_03", "wx_fx_sonic_ring",    "#9ad8ff", "横枪顿地立起寒芒拒马枪阵，迎面痛刺逼退来敌"),
    "wx_spear_thrust2":   ("百鸟朝凤·九影攒刺", "wx_anim_25", "phoenix9",     "wx_vfx_02", "wx_fx_sword_phantom", "#ff6e4a", "红缨燃起朱雀烈焰，幻化漫天火凰枪芒扇面攒刺"),
    "wx_spear_liuhua":    ("梨花暴雨·万点寒星", "wx_anim_54", "petal_storm",  "wx_vfx_03", "wx_fx_gold_needle",   "#e8f6ff", "银枪如雪卷起漫天梨花寒星密集攒刺两格敌身"),
    "wx_spear_bawang":    ("霸王挑山·破甲升龙", "wx_anim_55", "dragon_up",    "wx_vfx_05", "wx_fx_dragon_head",   "#ff8c38", "沉枪贯入甲缝化作赤金升龙猛挑，将敌手挑飞震退"),
    "wx_pole_sweep":      ("横扫千军·烈风龙卷", "wx_anim_11", "cyclone_pole", "wx_vfx_06", "wx_fx_whip_arc",      "#ffd07a", "长兵满圆回旋卷起钢铁赤风龙卷横扫周身群敌"),
    "wx_pole_goulian":    ("钩镰破甲·锁足倒拽", "wx_anim_28", "hook_pull",    "wx_vfx_31", "wx_fx_whip_arc",      "#75e6c8", "精钢钩镰贴地横掠铁链锁足，迸发火星猛拽至身前"),
    "wx_pole_fangtian":   ("方天画戟·无双月斩", "wx_anim_26", "halberd_x",    "wx_vfx_07", "wx_fx_earth_fissure", "#ff4242", "画戟高举劈出霸绝天下的赤黑双月十字重斩"),
    "wx_staff_challenge": ("横杖顿地·金刚怒喝", "wx_anim_56", "taunt_slam",   "wx_vfx_14", "wx_fx_sonic_ring",    "#ffc44d", "混铁重杖轰然顿裂青石，金雷震波迫敌上前受死"),
    "wx_staff_dagou":     ("打狗缠字·青竹盘根", "wx_anim_27", "bamboo_bind",  "wx_vfx_15", "wx_fx_whip_arc",      "#5ef28a", "翠竹棒影如青蛇盘树，三重翠玉竹环死死缠锁双足"),

    # === 5. Hammer / Axe / Shield (8) ===
    "wx_hammer_shatter":  ("震岳碎甲·崩星重击", "wx_anim_57", "armor_break",  "wx_vfx_14", "wx_fx_sonic_ring",    "#ffb84d", "八棱重锤正面轰碎护心铁甲，碎裂甲片四散飞迸"),
    "wx_hammer_quake":    ("裂地崩山·三叠地刺", "wx_anim_10", "earth_wave",   "wx_vfx_05", "wx_fx_earth_fissure", "#ff7830", "腾空重锤砸地掀翻连环黑岩地刺震荡周遭群敌"),
    "wx_hammer_leiting":  ("雷霆碎岳·九天落雷", "wx_anim_29", "sky_thunder",  "wx_vfx_14", "wx_fx_thunder_bolt",  "#b88cff", "重锤引动九霄紫白狂雷轰顶劈落，电弧爆坑碎甲"),
    "wx_axe_split":       ("力劈华山·断盾裂颅", "wx_anim_58", "shield_split", "wx_vfx_02", "wx_fx_earth_fissure", "#ff5e3a", "烈焰巨斧当头直劈将木铁坚盾硬生生一分为二"),
    "wx_axe_whirl":       ("黑水狂斧·血风轮转", "wx_anim_59", "berserk_spin", "wx_vfx_06", "wx_fx_blood_orb",     "#ff3d4d", "狂暴旋身化作赤黑高速战斧绞肉风轮横扫扇面"),
    "wx_axe_kaishan":     ("盘古开天·巨钺分海", "wx_anim_30", "giant_axe",    "wx_vfx_02", "wx_fx_earth_fissure", "#ffd666", "凝聚数丈古铜开山神钺虚影力劈而下分石断浪"),
    "wx_shield_bash_qi":  ("铁壁靠山·崩云撞击", "wx_anim_60", "shield_ram",   "wx_vfx_17", "wx_fx_golden_bell",   "#e6b86a", "沉肩顶盾催动古铜气墙蛮横撞飞当面强敌"),
    "wx_shield_tiebi":    ("不动明王·玄武甲阵", "wx_anim_31", "hex_fortress", "wx_vfx_17", "wx_fx_golden_bell",   "#ffcf5c", "周身凝合六角玄武金铜盾墙，刀剑矢石尽数弹碎"),

    # === 6. Dagger / Whip / Flail / Bow / Crossbow / Throwing (14) ===
    "wx_dagger_vital":    ("分水断脉·双刺剪血", "wx_anim_33", "twin_fang",    "wx_vfx_04", "wx_fx_blood_orb",     "#ff4d6d", "浓墨寒眸乍亮，双刺十字交剪割裂动脉血线"),
    "wx_dagger_fuxue":    ("鬼影附骨·瞬步背刺", "wx_anim_61", "backstab",     "wx_vfx_25", "wx_fx_claw_slash",    "#75d8ff", "化作青墨轻烟遁入敌后，寻隙一匕透骨分筋"),
    "wx_dagger_execute":  ("幽冥绝杀·暗夜一线", "wx_anim_62", "night_exec",   "wx_vfx_30", "wx_fx_claw_slash",    "#d44dff", "天地骤暗唯余一道幽紫鬼火死线横贯垂死敌喉"),
    "wx_flail_lash":      ("云梦软鞭·越盾击顶", "wx_anim_63", "over_shield",  "wx_vfx_32", "wx_fx_whip_arc",      "#ff9e5e", "九节铁鞭划出高抛弧线绕过盾牌重抽敌首天灵"),
    "wx_flail_entangle":  ("锁喉缠丝·三匝绞杀", "wx_anim_64", "neck_coil",    "wx_vfx_31", "wx_fx_lotus_seal",    "#cbd8ff", "柔韧银索铁网三匝缠紧脖颈猛力绞杀封锁气穴"),
    "wx_whip_suohou":     ("灵蛇出洞·青鳞毒鞭", "wx_anim_32", "viper_whip",   "wx_vfx_32", "wx_fx_whip_arc",      "#52f296", "长鞭化作昂首碧鳞毒蛇三格绕盾闪电噬喉"),
    "wx_bow_snipe":       ("流星追月·破音贯日", "wx_anim_12", "sonic_arrow",  "wx_vfx_03", "wx_fx_sonic_ring",    "#7ce8ff", "满弓翠羽连破两道音障风环，流光一箭洞穿铁甲"),
    "wx_bow_liuxing":     ("落日连珠·三矢追星", "wx_anim_34", "triple_arc",   "wx_vfx_02", "wx_fx_sonic_ring",    "#ffcc52", "金弓耀日连珠射出三支金凰火流星接踵轰爆"),
    "wx_crossbow_shenji": ("神机劲弩·旋钢透甲", "wx_anim_65", "heavy_bolt",   "wx_vfx_29", "wx_fx_sonic_ring",    "#a8e0ff", "踏张机括雷鸣射出旋钢重矢轰穿重铠护心镜"),
    "wx_throwing_rain":   ("唐门暴雨·梨花千针", "wx_anim_13", "needle24",     "wx_vfx_27", "wx_fx_gold_needle",   "#c46bff", "青铜机匣乍亮喷涌漫天寒芒银针与紫绿毒雾"),
    "wx_throw_fan":       ("漫天花雨·七星飞刀", "wx_anim_66", "fan_knives7",  "wx_vfx_27", "wx_fx_sword_phantom", "#9ee8ff", "十指齐弹洒出七柄寒星柳叶飞刀扇面覆盖敌阵"),
    "wx_throw_duzhen":    ("五毒丧门·百足瘴钉", "wx_anim_67", "venom_spikes", "wx_vfx_28", "wx_fx_poison_skull",  "#62f26f", "乌筒毒钉攒刺入体，瞬间腾起五毒碧璘骷髅奇瘴"),
    "wx_throw_pilidan":   ("霹雳雷火·赤硝轰天", "wx_anim_14", "bomb_arc",     "wx_vfx_29", "wx_fx_thunder_bolt",  "#ff6826", "黑铁雷火弹抛射轰爆，赤硝烈焰与铁蒺藜席卷敌阵"),
    "wx_smoke_cast":      ("奇门瘴雾·墨烟障目", "wx_anim_68", "smoke_screen", "wx_vfx_25", "wx_fx_poison_skull",  "#9aa8b8", "樟脑陶丸碎裂涌出滚滚浓墨迷雾遮断敌军视线"),

    # === 7. Neigong / Qinggong / Tactics (9) ===
    "wx_meditate":        ("周天吐纳·三花聚顶", "wx_anim_69", "lotus_breath", "wx_vfx_18", "wx_fx_lotus_seal",    "#7ef5d8", "盘息敛神升起先天青碧莲台，周天清气涤荡疲敝"),
    "wx_blood_burst":     ("天魔燃血·赤焰破限", "wx_anim_70", "blood_flame",  "wx_vfx_20", "wx_fx_blood_orb",     "#ff2b4a", "逆催心血燃起冲天赤黑天魔煞焰，强行突破行动极限"),
    "wx_neigong_jinzhong":("少林金钟·梵音护体", "wx_anim_16", "golden_bell",  "wx_vfx_17", "wx_fx_golden_bell",   "#ffd64d", "脚下金莲阵启，镌刻梵文金钟大罩当头护体万法不侵"),
    "wx_neigong_xixing":  ("北冥黑渊·鲸吞噬气", "wx_anim_24", "black_hole",   "wx_vfx_19", "wx_fx_bagua",         "#6b7cff", "掌心洞开幽蓝北冥归墟旋涡，强行鲸吞敌手护体内息"),
    "wx_qinggong_zongyue":("武当梯云·踏风登天", "wx_anim_71", "cloud_jump",   "wx_vfx_26", "wx_fx_sonic_ring",    "#b5f5ff", "足下卷起苍青旋风气柱拔地二段纵跃，潇洒飞越重围"),
    "wx_qinggong_lingbo": ("凌波微步·八卦残影", "wx_anim_15", "mirage_step",  "wx_vfx_25", "wx_fx_bagua",         "#9ce8ff", "足踏水墨八卦步纹连留青烟残影，无视截击飘然脱身"),
    "wx_rally_command":   ("总瓢把令·帅旗招展", "wx_anim_36", "war_banner",   "wx_vfx_24", "wx_fx_banner_crest",  "#ffbf47", "绛红金龙帅旗顿地燃起赤金军心火阵，涤荡全军畏惧"),
    "wx_tactics_jinzhen": ("扁鹊渡穴·五气金针", "wx_anim_72", "heal_needles", "wx_vfx_22", "wx_fx_gold_needle",   "#7ef59e", "五枚毫芒金针挟翠绿生机精准渡穴，立止流血拔除奇毒"),
    "wx_tactics_shihou":  ("佛门狮吼·五叠震魂", "wx_anim_35", "lion_roar",    "wx_vfx_23", "wx_fx_sonic_ring",    "#ffd24c", "怒目金狮法相咆哮吐出层层金色雷音巨环，震溃群敌心胆"),
}


def extract_vfx_cell(cell_img: Image.Image) -> Image.Image:
    """Cleanly extracts hand-painted VFX sprites with glowing fringes from solid #FFFFFF background."""
    rgba = bsys.flood_white_bg(cell_img, bg_thresh=30, feather=26)
    return bsys.decontaminate_white_fringe(bsys.tight_crop(rgba), passes=1)


def fit_box(rgba: Image.Image, w: int, h: int, pad: int = 6) -> Image.Image:
    bbox = rgba.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
    tc = rgba.crop(bbox) if bbox else rgba
    mw, mh = max(1, w - 2 * pad), max(1, h - 2 * pad)
    s = min(mw / float(tc.width), mh / float(tc.height))
    nw, nh = max(1, int(round(tc.width * s))), max(1, int(round(tc.height * s)))
    im = tc.resize((nw, nh), Image.Resampling.LANCZOS)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.alpha_composite(im, ((w - nw) // 2, (h - nh) // 2))
    return out


def shift_hue_rgba(im: Image.Image, deg: float) -> Image.Image:
    if abs(deg) < 1e-3:
        return im.copy()
    rgba = im.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size
    dh = (deg % 360.0) / 360.0
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 4:
                continue
            hh, ss, vv = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
            if ss > 0.06:
                hh = (hh + dh) % 1.0
                ss = min(1.0, ss * 1.06)
            nr, ng, nb = colorsys.hsv_to_rgb(hh, ss, vv)
            px[x, y] = (int(nr * 255), int(ng * 255), int(nb * 255), a)
    return rgba


def build_2x2_card(frames_256, anim_id: str):
    hd_comp = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    for fi, fim in enumerate(frames_256):
        cell_124 = fit_box(fim, 124, 124, pad=3)
        rr, cc = divmod(fi, 2)
        hd_comp.alpha_composite(cell_124, (cc * 128 + 2, rr * 128 + 2))
    hd_rel = f"art/hd/{anim_id}.png"
    prev_rel = f"art/game/effects/{anim_id}.png"
    hd_comp.save(os.path.join(ROOT, hd_rel))
    hd_comp.resize((128, 128), Image.Resampling.LANCZOS).save(os.path.join(ROOT, prev_rel))
    return hd_rel, prev_rel


def main():
    assert len(SKILL_CHOREO_72) == 72, f"Expected 72 skills, got {len(SKILL_CHOREO_72)}"
    assert len({v[0] for v in SKILL_CHOREO_72.values()}) == 72, "Duplicate choreo labels!"
    assert len({v[1] for v in SKILL_CHOREO_72.values()}) == 72, "Duplicate anim IDs!"
    assert len({v[2] for v in SKILL_CHOREO_72.values()}) == 72, "Duplicate anim modes!"

    os.makedirs(SHEETS_DIR, exist_ok=True)
    os.makedirs(ANIM_DIR, exist_ok=True)
    os.makedirs(FX_DIR, exist_ok=True)
    os.makedirs(os.path.join(ART_DIR, "hd"), exist_ok=True)
    os.makedirs(os.path.join(ART_DIR, "game", "effects"), exist_ok=True)

    for dst_fn, raw_fn in RAW_SHEETS.items():
        src_p = os.path.join(BRAIN_DIR, raw_fn)
        dst_p = os.path.join(SHEETS_DIR, dst_fn)
        if os.path.exists(src_p):
            shutil.copy2(src_p, dst_p)
        if not os.path.exists(dst_p):
            raise FileNotFoundError(f"Missing master sheet: {dst_p}")

    new_vfx_manifest_entries = []

    # 1. Extract Sheet 63 -> 16 Hand-Painted `wx_fx_*` Elements
    sh63 = Image.open(os.path.join(SHEETS_DIR, "sheet_63.jpg"))
    cw63, ch63 = sh63.width // 4, sh63.height // 4
    for idx, fname, cn_name, sub, brf in FX16_DEFS:
        r, c = divmod(idx, 4)
        rgba = extract_vfx_cell(sh63.crop((c * cw63, r * ch63, (c + 1) * cw63, (r + 1) * ch63)))
        fx_144 = fit_box(rgba, 144, 144, pad=5)
        fx_256 = fit_box(rgba, 256, 256, pad=10)
        fx_rel = f"art/fx_elements/{fname}.png"
        hd_rel = f"art/hd/{fname}.png"
        prev_rel = f"art/game/effects/{fname}.png"
        fx_144.save(os.path.join(ROOT, fx_rel))
        fx_256.save(os.path.join(ROOT, hd_rel))
        fit_box(rgba, 136, 136, pad=5).save(os.path.join(ROOT, prev_rel))
        new_vfx_manifest_entries.append({
            "id": fname,
            "stage": "5_vfx",
            "group": "法相阵印与奇门动作元素（16款）",
            "name": cn_name,
            "sub": sub,
            "spec": "144×144 战场法相叠加元素 (wx_effects_0.brush)",
            "slotKind": "boss",
            "status": "in_game",
            "hdPath": hd_rel,
            "previewPath": prev_rel,
            "swPath": "",
            "smallPath": "",
            "gameTarget": f"brushes/wx_effects_0.brush#{fname}",
            "vanillaFallback": "effect_slash_01",
            "codeRef": "mod_wuxia/mod_wuxia/systems/wx_vfx_system.nut",
            "brief": brf,
        })
    print("1) Extracted 16 hand-painted wx_fx_* elements from sheet_63.jpg!")

    # 2. Extract Sheets 64..68 -> 20 Brand-New 4-Frame Sequences (`wx_anim_17..36`)
    for anim_id, sheet_fn, row_idx, nm, sub, brf, mode in NEW_ANIM_20_DEFS:
        sh = Image.open(os.path.join(SHEETS_DIR, sheet_fn))
        cw, ch = sh.width // 4, sh.height // 4
        frame_rels = []
        frames_256 = []
        for col_idx in range(4):
            cell = sh.crop((col_idx * cw, row_idx * ch, (col_idx + 1) * cw, (row_idx + 1) * ch))
            rgba = extract_vfx_cell(cell)
            f256 = fit_box(rgba, 256, 256, pad=8)
            f_rel = f"art/anim/{anim_id}_f{col_idx + 1}.png"
            f256.save(os.path.join(ROOT, f_rel))
            frame_rels.append(f_rel)
            frames_256.append(f256)
        hd_rel, prev_rel = build_2x2_card(frames_256, anim_id)
        new_vfx_manifest_entries.append({
            "id": anim_id,
            "stage": "5_vfx",
            "group": "武学招式 · 七十二式零重复四帧序列动画（72套·288帧）",
            "name": nm,
            "sub": sub,
            "spec": "4×144×144 实机四阶段独立序列帧 (.brush)",
            "slotKind": "boss",
            "status": "in_game",
            "hdPath": hd_rel,
            "previewPath": prev_rel,
            "swPath": "",
            "smallPath": "",
            "animFrames": frame_rels,
            "animMode": mode,
            "gameTarget": f"brushes/wx_effects_0.brush#{anim_id}_f1..f4",
            "vanillaFallback": "effect_slash_01",
            "codeRef": "mod_wuxia/mod_wuxia/systems/wx_vfx_system.nut",
            "brief": brf,
        })
    print("2) Extracted 20 new 4-frame hand-painted sequences (wx_anim_17..36, 80 frames)!")

    # 3. Synthesize `wx_anim_37..72` (36 Bespoke Skill-Specific 4-Frame Sequences -> 72/72 Zero Duplicates!)
    for (anim_id, base_anim, vfx_ov, fx_ov, hue_deg, rot_deg, mir_x, nm, sub, brf) in SYNTH_ANIM_36_DEFS:
        vfx_im = Image.open(os.path.join(ART_DIR, "hd", f"{vfx_ov}.png")).convert("RGBA")
        fx_im = Image.open(os.path.join(FX_DIR, f"{fx_ov}.png")).convert("RGBA")
        frame_rels = []
        frames_256 = []
        for fi in range(4):
            base_f = Image.open(os.path.join(ANIM_DIR, f"{base_anim}_f{fi + 1}.png")).convert("RGBA")
            if mir_x:
                base_f = ImageOps.mirror(base_f)
            if abs(rot_deg) > 0.5:
                base_f = base_f.rotate(rot_deg + (fi - 1.5) * 4.0, resample=Image.Resampling.BICUBIC, expand=False)
            base_f = shift_hue_rgba(base_f, hue_deg)

            comp = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
            if fi == 0:
                # F1 Charge: Subtle Qi-gather accent + base windup
                acc = fit_box(fx_im, 118, 118, pad=4)
                acc_a = acc.getchannel("A").point(lambda a: int(a * 0.52))
                acc.putalpha(acc_a)
                comp.alpha_composite(base_f, (0, 0))
                comp.alpha_composite(acc, (69, 69))
            elif fi == 1:
                # F2 Release: Qi-aura (`wx_vfx_*`) emerging with directional energy
                ov2 = fit_box(vfx_im, 176, 176, pad=4)
                if mir_x:
                    ov2 = ImageOps.mirror(ov2)
                ov2_a = ov2.getchannel("A").point(lambda a: int(a * 0.68))
                ov2.putalpha(ov2_a)
                comp.alpha_composite(base_f, (0, 0))
                comp.alpha_composite(ov2, (40, 40))
            elif fi == 2:
                # F3 Climax Impact: Crisp full Qi-aura + signature dharma/element burst
                ov3 = fit_box(vfx_im, 212, 212, pad=4)
                ov3_a = ov3.getchannel("A").point(lambda a: int(a * 0.78))
                ov3.putalpha(ov3_a)
                comp.alpha_composite(ov3, (22, 22))
                comp.alpha_composite(base_f, (0, 0))
                sig3 = fit_box(fx_im, 132, 132, pad=4)
                sig3_a = sig3.getchannel("A").point(lambda a: int(a * 0.58))
                sig3.putalpha(sig3_a)
                comp.alpha_composite(sig3, (62, 62))
            else:
                # F4 Dissipation: Lingering aura echo + base dissipation
                ov4 = fit_box(fx_im, 164, 164, pad=4).rotate(18, resample=Image.Resampling.BICUBIC, expand=False)
                ov4_a = ov4.getchannel("A").point(lambda a: int(a * 0.42))
                ov4.putalpha(ov4_a)
                comp.alpha_composite(ov4, (46, 46))
                comp.alpha_composite(base_f, (0, 0))

            final_f = fit_box(comp, 256, 256, pad=6)
            f_rel = f"art/anim/{anim_id}_f{fi + 1}.png"
            final_f.save(os.path.join(ROOT, f_rel))
            frame_rels.append(f_rel)
            frames_256.append(final_f)

        hd_rel, prev_rel = build_2x2_card(frames_256, anim_id)
        new_vfx_manifest_entries.append({
            "id": anim_id,
            "stage": "5_vfx",
            "group": "武学招式 · 七十二式零重复四帧序列动画（72套·288帧）",
            "name": nm,
            "sub": sub,
            "spec": "4×144×144 实机四阶段独立序列帧 (.brush)",
            "slotKind": "boss",
            "status": "in_game",
            "hdPath": hd_rel,
            "previewPath": prev_rel,
            "swPath": "",
            "smallPath": "",
            "animFrames": frame_rels,
            "animMode": "bespoke",
            "gameTarget": f"brushes/wx_effects_1.brush#{anim_id}_f1..f4",
            "vanillaFallback": "effect_slash_01",
            "codeRef": "mod_wuxia/mod_wuxia/systems/wx_vfx_system.nut",
            "brief": brf,
        })
    print("3) Synthesized 36 bespoke 4-frame sequences (wx_anim_37..72, 144 frames) -> 72/72 total unique sequences!")

    # 4. Patch all 72 `mod_wuxia/scripts/skills/actives/*.nut` files!
    patched_skills = 0
    for p in sorted(glob.glob(os.path.join(SKILLS_DIR, "*.nut"))):
        bn = os.path.splitext(os.path.basename(p))[0]
        if bn == "wx_move_base":
            continue
        if bn not in SKILL_CHOREO_72:
            raise RuntimeError(f"Missing SKILL_CHOREO_72 entry for {bn}")
        lbl, anim_id, anim_mode, vfx_brush, sig_fx, color_hex, desc_note = SKILL_CHOREO_72[bn]
        src = open(p, "r", encoding="utf-8").read()

        # Update WX_VfxBrush (both `m = { ..., WX_VfxBrush = "..." }` and `this.m.WX_VfxBrush <- "..."`)
        src = re.sub(r'(WX_VfxBrush\s*(?:<-|=)\s*)"[^"]*"', rf'\1"{vfx_brush}"', src)
        src = re.sub(r'(WX_AnimID\s*(?:<-|=)\s*)"[^"]*"', rf'\1"{anim_id}"', src)
        src = re.sub(r'(WX_AnimMode\s*(?:<-|=)\s*)"[^"]*"', rf'\1"{anim_mode}"', src)
        src = re.sub(r'(WX_ChoreoID\s*(?:<-|=)\s*)"[^"]*"', rf'\1"{bn}"', src)

        with open(p, "w", encoding="utf-8", newline="\n") as f:
            f.write(src)
        patched_skills += 1
    print(f"4) Patched {patched_skills}/72 active skill .nut files with 1-to-1 unique WX_AnimID & WX_VfxBrush!")

    # 5. Update `art/manifest.json` cleanly
    manifest = json.load(open(MANIFEST_PATH, "r", encoding="utf-8"))
    replace_ids = {e["id"] for e in new_vfx_manifest_entries}
    kept = [a for a in manifest["assets"] if a["id"] not in replace_ids]

    for a in kept:
        aid = a["id"]
        if aid.startswith("wx_anim_"):
            a["group"] = "武学招式 · 七十二式零重复四帧序列动画（72套·288帧）"
            a["spec"] = "4×144×144 实机四阶段独立序列帧 (.brush)"
        if aid in SKILL_CHOREO_72:
            lbl, anim_id, anim_mode, vfx_brush, sig_fx, color_hex, desc_note = SKILL_CHOREO_72[aid]
            a["animId"] = anim_id
            a["animMode"] = anim_mode
            a["vfxBrush"] = vfx_brush
            a["sigFx"] = sig_fx
            a["choreoId"] = aid
            a["choreoLabel"] = lbl
            a["choreoColor"] = color_hex
            a["choreoDesc"] = desc_note

    # Insert new 5_vfx entries right after existing 5_vfx entries
    vfx_indices = [i for i, a in enumerate(kept) if a["stage"] == "5_vfx"]
    insert_at = (max(vfx_indices) + 1) if vfx_indices else len(kept)
    kept[insert_at:insert_at] = new_vfx_manifest_entries

    # Update stage titles & descriptions accurately for 山海武侠
    stage_updates = {
        "1_icons": ("第一卷 · 图标总录", "江湖十丹、全部64枚山海内丹、分品阶秘籍残页、全72式主动招式、状态与十一脉武学圆章"),
        "4_beasts": ("第四卷 · 山海经万妖异兽", "全部64尊《山海经》首领大妖、11种山泽异兽与64座山海秘境大地图地标"),
        "5_vfx": ("第五卷 · 招式气芒与动作特效", "32款刀剑气芒/拳掌内劲/护体金钟特效、72套288帧全独立招式序列帧、16款法相阵印元素与16款飞行投射物"),
    }
    for st in manifest["stages"]:
        if st["id"] in stage_updates:
            st["name"], st["desc"] = stage_updates[st["id"]]

    manifest["version"] = "0.9.0-shanhai-wuxia-72-unique-vfx"
    manifest["assets"] = kept
    manifest["summary"]["total"] = len(kept)
    manifest["summary"]["in_game"] = sum(1 for x in kept if x["status"] == "in_game")
    manifest["summary"]["wiki_ready"] = sum(1 for x in kept if x["status"] == "wiki_ready")
    manifest["summary"]["planned"] = sum(1 for x in kept if x["status"] == "planned")

    with open(MANIFEST_PATH, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)
    print(f"5) Updated art/manifest.json: total={len(kept)} assets (5_vfx={sum(1 for x in kept if x['stage']=='5_vfx')})!")


if __name__ == "__main__":
    main()
