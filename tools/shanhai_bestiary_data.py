#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Complete Declarative Bestiary Specification for《山海经·万妖全志》:
  - 64 Shan Hai Jing Mythical Apex Bosses (`wx_boss_*`, parsed & enriched from `wx_shanhai.nut` & `wx_encounters.nut`)
  - 72 Shan Hai Jing Wild & Retinue Beasts (`11` existing + `61` newly painted across Sheets 66..69)
    -> Total: 136 Distinct《山海经》Species (+ 3 Summoned Battlefield Spawn Pawns = 139 Tactical Monster Pawns!)
  - 16 New World Map Marching Beast Chess Figurines (`Sheet 70`, bringing `wx_fig_beast_*` from 8 -> 24)
  - Full Battle Brothers D100 Combat Stats, Innate Traits, Immunities, Counterplay, 2~3 Active Skills per Creature,
    and 20 Distinct 60fps Tactical Hex Monster Combat Choreographies.
"""

from __future__ import annotations
import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# ==============================================================================
# 1. 16 NEW WORLD-MAP MARCHING BEAST CHESS PIECES (Sheet 70, 4x4)
# ==============================================================================
SHEET70_WORLD_BEAST_FIGS = [
    (0,  "wx_fig_beast_qiongqi",   "山海穷奇翼虎凶兽棋", "大地图游荡兽群 · 翼虎凶兽族", "双翼怒张、虎纹狰狞的穷奇虎豹族大地图行军小棋子。"),
    (1,  "wx_fig_beast_taotie",    "山海饕餮羊角贪兽棋", "大地图游荡兽群 · 饕餮狍鸮族", "盘曲巨角、血盆深渊巨口的饕餮狍鸮族大地图行军小棋子。"),
    (2,  "wx_fig_beast_xuangui",   "山海杻阳玄甲巨龟棋", "大地图游荡兽群 · 玄龟能鳖族", "鹰喙鸟首、背负黑铁重甲的玄龟水甲族大地图行军小棋子。"),
    (3,  "wx_fig_beast_fuzhu",     "山海敖岸四角霜鹿棋", "大地图游荡兽群 · 灵鹿瑞马族", "四枝寒玉长角、踏霜而行的夫诸白泽族大地图行军小棋子。"),
    (4,  "wx_fig_beast_dangkang",  "山海钦山巨牙当康棋", "大地图游荡兽群 · 凶猪豪彘族", "四根弯刀巨牙破阵狂奔的当康豪彘族大地图行军小棋子。"),
    (5,  "wx_fig_beast_jinwu",     "山海汤谷三足金乌棋", "大地图游荡兽群 · 烈焰神禽族", "三足浴火展翼掠空的金乌毕方奇禽族大地图行军小棋子。"),
    (6,  "wx_fig_beast_kui",       "山海流波独足雷夔棋", "大地图游荡兽群 · 雷牛巨兕族", "苍躯独足、周身紫电盘绕的夔牛青兕族大地图行军小棋子。"),
    (7,  "wx_fig_beast_qinyuan",   "山海昆仑剧毒钦原棋", "大地图游荡兽群 · 奇虫玄蜂族", "黑金甲壳、腹悬透铁毒针的钦原玄蜂族大地图行军小棋子。"),
    (8,  "wx_fig_beast_xiangliu",  "山海共工九首相柳棋", "大地图游荡兽群 · 多首毒蛟族", "九首昂立、毒雾弥漫的相柳九婴水妖族大地图行军小棋子。"),
    (9,  "wx_fig_beast_xingtian",  "山海常羊无首干戚棋", "大地图游荡兽群 · 战魂凶魔族", "以乳为目、执干戚战斧狂舞的刑天兵主族大地图行军小棋子。"),
    (10, "wx_fig_beast_kuafu",     "山海邓林桃杖巨神棋", "大地图游荡兽群 · 上古巨灵族", "手拄燃火桃木巨杖阔步奔行的夸父防风巨人族行军小棋子。"),
    (11, "wx_fig_beast_hundun",    "山海天山六足浑沌棋", "大地图游荡兽群 · 混沌异神族", "赤金浑圆无面、六足四翼狂舞的浑沌帝江族行军小棋子。"),
    (12, "wx_fig_beast_bingyi",    "山海从极御龙冰夷棋", "大地图游荡兽群 · 寒渊真龙族", "玄冰古甲、双寒龙护驾的冰夷应龙烛阴族行军小棋子。"),
    (13, "wx_fig_beast_eshou",     "山海幽谷三目讹兽棋", "大地图游荡兽群 · 幻影梦魇族", "眉心竖瞳、紫雾缭绕潜行的讹兽讙狸族大地图行军小棋子。"),
    (14, "wx_fig_beast_wenyao",    "山海沧溟鸟翼文鳐棋", "大地图游荡兽群 · 翼鱼水怪族", "苍鳞白首、舒展飞翼掠浪的文鳐虎蛟水妖族行军小棋子。"),
    (15, "wx_fig_beast_yumin",     "山海大荒黑羽飞妖棋", "大地图游荡兽群 · 大荒异民族", "生披铁羽、执骨矛巡猎的大荒羽民驩头异族行军小棋子。"),
]

# ==============================================================================
# 2. EXISTING 11 WILD BEASTS + 64 NEW BEASTS (61 Species + 3 Spawn Tokens)
# ==============================================================================
# Tuple schema:
#   (sheet_num_or_None, cell_idx, id, name, chapter, book_grp, rank, archetype, world_fig,
#    classic_quote, trait_name, trait_desc, counterplay, trophy_name,
#    stats_tuple(hp, h_arm, b_arm, ap, fat, frec, msk, rsk, mdef, rdef, init, res, xp),
#    skill1_key, skill2_key)

EXISTING_11_WILD_BEASTS = [
    (None, 0, "wx_beast_tiangou", "阴山天狗苍狼", "西山经", "xishan", "山海群妖", "Direwolf", "wx_fig_beast_tiangou",
     "《西山经》：“阴山，有兽焉，其状如狸而白首，名曰天狗，其音如榴榴，可以御凶。”",
     "奔星群猎·围扑噬喉", "同格周遭每多 1 头天狗或狼裔，近战命中额外 +5；对已流血或动摇目标扑咬总伤 +15%。",
     "长枪【拒马枪阵】可阻断其三连急扑；切忌让轻甲弓手暴露于侧翼空档。", "阴山天狗苍裘",
     (115, 35, 55, 10, 115, 18, 66, 0, 12, 10, 128, 58, 220), "feral_triple_bite", "star_howl_rush"),

    (None, 1, "wx_beast_gudiao", "西山蛊雕狂兽", "南山经", "nanshan", "荒泽精英", "Hyena", "wx_fig_beast_gudiao",
     "《南山经》：“鹿吴之山，泽更之水出焉，有兽焉，名曰蛊雕，其状如雕而有角，其音如婴儿之哭，是食人。”",
     "婴啼乱神·钩喙裂脉", "贴身啼鸣令相邻敌手定力临时 -8，钩喙撕咬高概率造成深创割裂流血。",
     "持藤牌或铁盾前排顶住第一波扑抓，以刀剑横扫快速清理。", "西山蛊雕斑革",
     (145, 50, 70, 10, 120, 18, 68, 0, 14, 12, 124, 62, 250), "horned_beak_rend", "infant_cry_dread"),

    (None, 2, "wx_beast_bashe_wild", "苍梧吞鹿巴蛇", "海内南经", "dahuang", "荒泽精英", "Serpent", "wx_fig_beast_bashe",
     "《海内南经》：“巴蛇食象，三岁而出其骨，君子服之，无心腹之疾。”",
     "盘身绞骨·滑鳞卸矢", "细密青鳞减免 25% 弓弩暗器伤害；可将 2 格内落单目标卷拽至蛇阵中心围噬！",
     "严守两列紧凑阵线防其卷人孤立；近身以双手劈山刀斧断其七寸。", "苍梧巴蛇青鳞皮",
     (185, 65, 95, 9, 130, 16, 68, 0, 12, 18, 102, 68, 280), "python_drag_coil", "venom_fang_snap"),

    (None, 3, "wx_beast_chizhu", "毒谷鬼面赤蛛", "西山经", "xishan", "山海群妖", "Spider", "wx_fig_beast_chizhu",
     "《山海五毒志》：“昆仑毒谷多赤斑巨蛛，背生惨白鬼面，吐天韧寒丝缚人手足，毒牙蚀心。”",
     "缚丝破甲·蚀髓蛛毒", "命中被蛛网缠缚之目标时穿甲率翻倍，并叠加蚀髓奇毒压制内息与身法。",
     "同袍被吐网缠住时须第一时间挥刃破网解救；范围横扫招式清蛛奇效。", "鬼面赤蛛天韧丝",
     (85, 25, 45, 10, 110, 18, 64, 0, 16, 18, 136, 52, 185), "silk_web_snare", "neuro_venom_bite"),

    (None, 4, "wx_beast_paoxiao", "北山狍鸮食尸兽", "北山经", "beishan", "荒泽精英", "Ghoul", "wx_fig_beast_taotie",
     "《北山经》：“钩吾之山，有兽焉，其状如羊身人面，其目在腋下，虎齿人爪，其音如婴儿，名曰狍鸮，是食人。”",
     "吞尸暴长·腋目窥隙", "吞噬战场尸骸后气血、武艺与体型暴涨一阶，腋下妖目令其被围攻时近防多保住 5 点。",
     "务必踩住阵亡敌尸格位阻其吞尸进化；趁其一阶瘦弱时集火斩杀。", "狍鸮颅内髓珠",
     (160, 45, 75, 9, 125, 16, 67, 0, 10, 8, 108, 66, 260), "tiger_fang_maul", "feast_corpse_grow"),

    (None, 5, "wx_beast_eshou", "幽谷梦魇讹兽", "神异经", "zhongshan", "荒泽精英", "Alp", "wx_fig_beast_eshou",
     "《神异经·西南荒经》：“西南荒中出讹兽，其状若菟，人面能言，常欺人，言东而西，言恶而善。”",
     "颠倒黑白·幻梦噬魂", "黑雾幻影受击即瞬移换位；隔空编织梦魇催眠低定力武人，在睡梦中直接侵蚀气血心神！",
     "由高定力掌旗核心施展《聚义令》一键震醒全队噩梦；持长柄三格内追击本体。", "讹兽梦魇诡眼",
     (130, 0, 30, 9, 120, 20, 58, 72, 20, 26, 118, 75, 290), "nightmare_slumber_hex", "shadow_mind_leech"),

    (None, 6, "wx_beast_jiuwei_wild", "青丘惑心妖魅", "南山经", "nanshan", "荒泽精英", "Hexe", "wx_fig_beast_yaomei",
     "《南山经》：“青丘之山，有兽焉，其状如狐而九尾，其音如婴儿，能食人，食者不蛊。”",
     "狐火嫁祸·媚骨惑心", "可将自身所受伤害同命转嫁给被施咒的侠客，并魅惑男丁调转刀枪砍杀同袍！",
     "佩【青丘定魂辟邪佩】或派高定力武僧/神射手远距一击毙命；被嫁祸回合切勿盲目劈砍。", "青丘妖魅惑心发",
     (95, 20, 40, 9, 125, 20, 54, 76, 18, 28, 116, 82, 360), "fox_bewitch_charm", "soul_link_hex"),

    (None, 7, "wx_beast_jianmu", "都广建木树精", "海内经", "zhongshan", "荒泽精英", "Schrat", "wx_fig_beast_jianmu",
     "《海内经》：“南海之内，黑水、青水之间，有木名曰建木，百仞无枝，有九欘，下有九枸，其实如麻。”",
     "古木盘盾·断枝化灵", "木质巨躯免疫点穴与奇毒、对穿刺箭矢减伤 60%；结成古木盾墙需巨斧劈碎，受重创会震落木灵助战！",
     "全队换装大板斧、长柯重钺执行破盾伐木；严禁三名侠客排成直线吃其地刺贯杀。", "都广建木万年灵心",
     (360, 140, 220, 9, 180, 20, 72, 0, 8, 25, 72, 100, 420), "root_line_impale", "bark_aegis_regrow"),

    (None, 8, "wx_beast_zhuyan_wild", "小次山朱厌巨猿", "西山经", "xishan", "荒泽精英", "Unhold", "wx_fig_beast_zhuyan",
     "《西山经》：“小次之山，有兽焉，其状如猿，而白首赤足，名曰朱厌，见则大兵。”",
     "气血再生·蛮臂掀阵", "每回合自动活血恢复 18% 气血上限（流血中毒可抑制）；巨臂横扫可一击震退整排盾卫打乱阵线！",
     "以狂风快刀挂流血或五毒丧门钉封其再生，长枪手外围攒刺风筝。", "朱厌心头赤血核",
     (380, 90, 130, 9, 180, 22, 72, 0, 8, 6, 85, 80, 400), "ape_sweep_fling", "furious_chest_charge"),

    (None, 9, "wx_beast_feiyi_wild", "太华六足肥遗蛟", "西山经", "xishan", "荒泽精英", "Lindwurm", "wx_fig_beast_feiyi",
     "《西山经》：“太华之山，削成而四方，有蛇焉，名曰肥遗，六足四翼，见则天下大旱。”",
     "紫毒蚀铁·双格龙躯", "首尾同占两格且免疫眩晕击退；近战劈砍其身会被紫毒真血溅射腐蚀 15~25 点身甲！",
     "切勿用名贵轻薄甲近身硬砍！宜遣两格长槊、钩镰枪与强弩手隔一格无伤屠蛟。", "肥遗赤黑重鳞",
     (520, 180, 300, 9, 220, 24, 76, 0, 10, 10, 80, 110, 520), "wyrm_gorge_chomp", "wyrm_tail_thresh"),

    (None, 10, "wx_beast_xiangliu", "九首相柳泽妖", "海外北经", "dahuang", "荒泽精英", "Kraken", "wx_fig_beast_xiangliu",
     "《海外北经》：“相柳者，九首人面，蛇身而青，不敢北射，所抵厥为源泽，不辛乃苦，百兽莫能处。”",
     "苦泽万触·断肢护首", "本体盘踞毒沼深处，驱使多条剧毒蛇触破泥抓人拖入血口；每斩断数根触手方能重创本体气血！",
     "携带高武艺快刀剑客专职斩断缠人蛇触救出同袍，稳步削减触手总血池。", "异兽五毒腺囊",
     (680, 160, 240, 10, 260, 25, 78, 0, 6, 15, 70, 130, 650), "mire_tentacle_drag", "nine_marsh_devour"),
]

# 61 Brand-New《山海经》Wild/Retinue Beasts + 3 Battlefield Spawn Tokens (Sheets 66..69 = 64 cells!)
NEW_64_SHANHAI_BEASTS = [
    # ==================== Sheet 66: 南山经·西山经 山泽奇兽 (0..15) ====================
    (66, 0, "wx_beast_luoshu", "杻阳鹿蜀斑马", "南山经", "nanshan", "山海群妖", "GoblinWolfrider", "wx_fig_beast_fuzhu",
     "《南山经》：“杻阳之山，有兽焉，其状如马而白首，其文如虎而赤尾，其音如谣，其名曰鹿蜀。”",
     "虎文疾驰·长歌振群", "移动消耗地形惩罚减半，奔袭冲刺距离越远破甲越高；嘶鸣如歌令周身友妖身法 +10。",
     "以捕网或绊字缠足杖锁其马腿，令其无法拉开冲锋距离。", "西山蛊雕斑革",
     (125, 40, 65, 10, 130, 20, 65, 0, 14, 14, 138, 60, 210), "gallop_hoof_lance", "melody_pack_chant"),

    (66, 1, "wx_beast_huanshu", "尧光猾褕豪兽", "南山经", "nanshan", "荒泽精英", "OrcBerserker", "wx_fig_beast_dangkang",
     "《南山经》：“尧光之山，有兽焉，其状如人而彘鬣，穴居而冬蛰，其名曰猾褕，其音如斫木，见则县有大繇。”",
     "彘鬣刚鬃·斫木碎盾", "背部硬如铁针的野猪刚鬃减免 20% 劈砍伤；双拳重砸如斧斤斫木，对木盾藤牌伤害翻倍！",
     "勿恃轻薄木盾硬接，趁其重击收势破绽以重兵碎骨反击。", "狍鸮裂骨虎齿",
     (210, 55, 95, 9, 145, 18, 70, 0, 6, 6, 98, 72, 275), "woodchop_fist_smash", "bristle_rage_roar"),

    (66, 2, "wx_beast_changfu", "基山三首尚付", "南山经", "nanshan", "山海群妖", "Hyena", "wx_fig_beast_gudiao",
     "《南山经》：“基山，有鸟焉，其状如鸡而三首、六目、六足、三翼，其名曰尚付，食之无卧。”",
     "六目无眠·三首连啄", "六目环视彻底免疫睡眠、致盲与烟幕降命中惩罚，一轮可发动迅捷三连铁喙快啄。",
     "重甲铁布衫可完全抵挡其高频轻啄，重锤一击即碎其脆骨。", "西山蛊雕斑革",
     (98, 30, 48, 10, 125, 20, 67, 0, 15, 14, 134, 58, 195), "triple_beak_flurry", "six_eye_glare"),

    (66, 3, "wx_beast_quuru", "祷过白首瞿如", "南山经", "nanshan", "山海群妖", "Vampire", "wx_fig_beast_yumin",
     "《南山经》：“祷过之山，有鸟焉，其状如鸼而白首，三足，人面，其名曰瞿如，其鸣自号也。”",
     "水泽掠足·怪面惊心", "水泽泥沼地形零移动惩罚；人面怪啸飞扑专抓武人面门（击头率 +15%）。",
     "戴兜鍪或修《铁布衫》铜头防其啄眼，弓弩提前半途截杀。", "西山蛊雕斑革",
     (110, 35, 50, 9, 115, 18, 66, 0, 16, 18, 126, 60, 205), "three_claw_face_rake", "marsh_shriek_swoop"),

    (66, 4, "wx_beast_huan", "翼望一目三尾讙", "西山经", "xishan", "山海群妖", "Alp", "wx_fig_beast_eshou",
     "《西山经》：“翼望之山，有兽焉，其状如狸，一目而三尾，其名曰讙，其音如夺百声，是可以御凶。”",
     "夺百兽音·乱耳迷踪", "拟仿百兽金铁嘶鸣扰乱听风辨位，使 2 格内敌军远程命中与借机攻击命中 -12。",
     "贴身短匕或双拳无视其幻音障眼法，贴脸快攻立破。", "讹兽梦魇诡眼",
     (105, 25, 45, 10, 120, 20, 64, 65, 18, 22, 135, 64, 215), "hundred_voice_babel", "three_tail_whip_claw"),

    (66, 5, "wx_beast_qitu", "嶓冢三首鵸鵌", "西山经", "xishan", "荒泽精英", "Vampire", "wx_fig_beast_jinwu",
     "《西山经》：“翼望之山，有鸟焉，其状如乌，三首六尾而善笑，名曰鵸鵌，服之使人不厌。”",
     "六尾诡笑·破胆啄心", "凄厉狂笑声引发心魔检定，对定力动摇或中梦魇者暴击穿甲额外 +20%！",
     "定力薄弱的新丁勿站前排；优先以流星连珠箭点杀。", "荒冢凝魄寒晶",
     (135, 40, 60, 10, 125, 18, 69, 0, 17, 20, 130, 68, 255), "cackle_hex_laugh", "triple_crow_gouge"),

    (66, 6, "wx_beast_xibian", "天帝赤喙溪边", "西山经", "xishan", "山海群妖", "Direwolf", "wx_fig_beast_tiangou",
     "《西山经》：“天帝之山，有兽焉，其状如狗，名曰溪边，席其皮者不蛊。”",
     "辟蛊噬气·锁腕狂咬", "天生百毒不侵（免疫一切奇毒蛊术）；凶狠撕咬手腕令猎物内息流失 12 点并散劲。",
     "五毒唐门暗器对其毒效全免，宜用实打实的刀枪硬杀。", "阴山天狗苍裘",
     (130, 45, 68, 9, 120, 18, 68, 0, 12, 10, 120, 65, 225), "anti_gu_jaw_lock", "feral_triple_bite"),

    (66, 7, "wx_beast_haozhi", "竹山黑棘豪彘", "西山经", "xishan", "荒泽精英", "GoblinAmbusher", "wx_fig_beast_dangkang",
     "《西山经》：“竹山，有兽焉，其状如豚而白毛，毛大如笄而黑端，名曰豪彘，怒则激射其毫。”",
     "怒射黑笄·刺猬反扎", "既可自 4 格内怒射破甲黑端骨刺，被近战攻击时亦反扎攻击者 8 点气血实伤！",
     "举藤牌逼近或用两格长枪/长戟刺杀，避免一格短兵贴肉被骨刺反扎。", "狍鸮弯钩凶角",
     (155, 70, 115, 9, 130, 16, 62, 72, 8, 14, 96, 64, 265), "quill_volley_shot", "tusk_bristle_ram"),

    (66, 8, "wx_beast_taodiao", "上申赤目饕雕", "西山经", "xishan", "荒泽精英", "Vampire", "wx_fig_beast_gudiao",
     "《西山经》：“白边之山，多饕雕，状如巨鹫而赤目铁爪，盘空伺猎，食人骨肉。”",
     "凌空俯掠·利爪掀盔", "无视高低差飞跃切入后排，铁爪专掀头盔（对头部护甲伤害 +45%）。",
     "后排弓医旁须留持枪护卫看护，待其落地瞬间围而歼之。", "西山蛊雕斑革",
     (140, 45, 65, 10, 130, 18, 71, 0, 18, 16, 136, 65, 270), "sky_talon_helm_rip", "wing_gust_backleap"),

    (66, 9, "wx_beast_ranyi", "英鞮六足冉遗鱼", "西山经", "xishan", "山海群妖", "Serpent", "wx_fig_beast_wenyao",
     "《西山经》：“英鞮之山，涴水出焉，是多冉遗之鱼，鱼身蛇首六足，其目如马耳，食之使人不眯。”",
     "六足攀岸·寒涎滑甲", "水陆疾行如飞，喷吐腥滑寒涎包裹敌甲，使目标下回合近防与远防双降 10 点【破绽】。",
     "火器雷火弹与阳刚刀法对其湿滑鳞皮有额外杀伤优势。", "巴蛇微光逆鳞",
     (150, 55, 85, 9, 120, 18, 66, 62, 11, 12, 106, 60, 230), "cold_slime_spit", "six_claw_serpent_bite"),

    (66, 10, "wx_beast_manman", "崇吾比翼蛮蛮", "西山经", "xishan", "山海群妖", "Vampire", "wx_fig_beast_jinwu",
     "《西山经》：“崇吾之山，有鸟焉，其状如凫，而一翼一目，相得乃飞，名曰蛮蛮，见则天下大水。”",
     "双魂同翼·合击双闪", "气血高于半数时双翼呼应近远双防 +15；半血以下双魂失调防御骤降但狂乱连击。",
     "一记重弩或飞剑先打残其半血破除比翼闪避，再顺势收割。", "西山蛊雕斑革",
     (118, 30, 50, 10, 125, 20, 68, 0, 20, 22, 138, 62, 235), "twin_wing_cross_slash", "flood_omen_squall"),

    (66, 11, "wx_beast_sanqingniao", "三危赤首三青鸟", "西山经", "xishan", "荒泽精英", "Vampire", "wx_fig_beast_jinwu",
     "《西山经》：“三危之山，三青鸟居之，赤首黑目，为西王母取食，疾若奔电。”",
     "瑶池疾羽·掠食断脉", "常驻 10 AP 极高身法先手，疾掠啄击精准截断手足经脉施加【点穴封气】！",
     "以投掷飞刀、孔雀翎或捕网先废其轻灵身法。", "西山蛊雕斑革",
     (148, 50, 75, 10, 135, 20, 73, 0, 19, 22, 144, 72, 295), "jade_lightning_peck", "wing_gust_backleap"),

    (66, 12, "wx_beast_feishu", "天池滑翼飞鼠", "北山经", "beishan", "山海群妖", "GoblinSkirmisher", "wx_fig_beast_eshou",
     "《北山经》：“天池之山，有兽焉，其状如兔而鼠首，以其背飞，其名曰飞鼠。”",
     "肉翼滑翔·脱离截击", "背生滑翔皮膜，脱离敌军控制区（ZoC）不触发借机攻击，专偷袭残血药师。",
     "用暗器、毒针或猎犬追咬，不给其反复拉扯风筝的机会。", "阴山天狗苍裘",
     (88, 20, 38, 10, 120, 20, 63, 0, 20, 22, 142, 50, 175), "gliding_throat_nip", "membrane_dart_evade"),

    (66, 13, "wx_beast_ziyu", "诸次独角毒茈鱼", "西山经", "xishan", "山海群妖", "Serpent", "wx_fig_beast_wenyao",
     "《西山经》：“诸次之水出焉，其中多茈鱼，赤鳞独角，触水成毒。”",
     "赤鳞腐水·独角钻甲", "骨角顶刺具备 45% 高穿甲率，且创口必染诸次水腐毒持续扣血。",
     "金针渡穴诀或护心丹可立解其腐水奇毒。", "异兽五毒腺囊",
     (142, 60, 88, 9, 115, 16, 67, 0, 10, 12, 104, 58, 225), "horn_venom_gore", "acid_scale_splash"),

    (66, 14, "wx_beast_wenyao", "泰器夜飞文鳐鱼", "西山经", "xishan", "荒泽精英", "Vampire", "wx_fig_beast_wenyao",
     "《西山经》：“观水出焉，是多文鳐鱼，状如鲤鱼，鱼身而鸟翼，苍文白首赤喙，常行西海，夜飞而行。”",
     "乘夜生风·掠海惊澜", "夜战非但不减命中视野，反而身法 +20、近防 +10；振翼掀起狂澜冲散前排。",
     "尽量白昼讨伐或点亮火把视野，长枪拒马克制其低空冲掠。", "巴蛇微光逆鳞",
     (162, 55, 85, 10, 135, 20, 70, 66, 16, 20, 132, 68, 285), "gale_fin_slash", "tidal_wind_blast"),

    (66, 15, "wx_beast_zhishou", "浮玉虎爪食人彘", "南山经", "nanshan", "荒泽精英", "Unhold", "wx_fig_beast_qiongqi",
     "《南山经》：“浮玉之山，有兽焉，其状如虎而牛尾，其音如吠犬，其名曰彘，是食人。”",
     "吠音震慑·牛尾扫阵", "凶悍食人巨虎身躯，前爪扑裂铁甲、粗壮牛尾横扫相邻两格敌军致【失衡】！",
     "避免两人在其正面并排站立吃满虎爪牛尾连击。", "朱厌白首厚革",
     (265, 75, 115, 9, 155, 18, 73, 0, 10, 8, 106, 74, 330), "tiger_claw_armor_tear", "ox_tail_double_sweep"),

    # ==================== Sheet 67: 北山经·东山经 荒原凶禽毒虫 (0..15) ====================
    (67, 0, "wx_beast_suanyu", "景山四翼六目酸与", "北山经", "beishan", "荒泽精英", "Serpent", "wx_fig_beast_jinwu",
     "《北山经》：“景山，有鸟焉，其状如蛇，而四翼、六目、三足，名曰酸与，其鸣自詨，见则其邑有恐。”",
     "四翼恐鸣·六目锁死", "怪鸣散布邑恐光环（2 格内敌军定力 -10），六目锁定令高闪避游侠招架减半！",
     "重甲持盾卫士不惧其扣闪避特性，稳扎稳打斩其蛇颈。", "苍梧巴蛇青鳞皮",
     (168, 50, 80, 10, 130, 18, 72, 0, 15, 18, 128, 70, 285), "four_wing_panic_dive", "venom_fang_snap"),

    (67, 1, "wx_beast_tianma", "马成黑首飞天马", "北山经", "beishan", "荒泽精英", "GoblinWolfrider", "wx_fig_beast_fuzhu",
     "《北山经》：“马成之山，有兽焉，其状如白犬而黑头，见人则飞，其名曰天马。”",
     "见人则飞·踏云越阵", "拥有 3 格无视地形纵跃突袭能力，专门越过前排重盾直扑后阵弓医！",
     "后排常备短匕护身或由二线长兵留 AP 随时回援夹击。", "阴山天狗苍裘",
     (155, 45, 75, 11, 140, 22, 69, 0, 18, 20, 145, 68, 290), "sky_steed_vault_kick", "gallop_hoof_lance"),

    (67, 2, "wx_beast_ershu", "丹熏尾飞辟毒耳鼠", "北山经", "beishan", "山海群妖", "Direwolf", "wx_fig_beast_eshou",
     "《北山经》：“丹熏之山，有兽焉，其状如鼠，而菟首麋身，其音如獋犬，以其尾飞，名曰耳鼠，食之不采，又可以御百毒。”",
     "百毒不侵·扇尾轻身", "免疫一切毒伤与内息淤滞，巨尾借风腾跃令远程避暗高达 +25。",
     "勿浪费毒镖毒针，直接以宽刃腰刀贴身封走位。", "阴山天狗苍裘",
     (102, 25, 45, 10, 125, 22, 64, 0, 18, 25, 140, 56, 195), "fan_tail_acrobat_slash", "membrane_dart_evade"),

    (67, 3, "wx_beast_jianyang", "泰戏盘角铁羬羊", "北山经", "beishan", "山海群妖", "OrcYoung", "wx_fig_beast_kui",
     "《西山经/北山经》：“华山之首，有兽焉，其状如羊而马尾，名曰羬羊，其脂可以已腊。”",
     "盘角铁颅·蓄势顶撞", "头部盘角坚若生铁（免疫爆头额外暴击），直线助跑 2 格冲撞必震晕或击退目标！",
     "在高低差石阶或枪阵后迎敌，破其直线助跑冲撞。", "狍鸮弯钩凶角",
     (165, 120, 85, 9, 135, 18, 66, 0, 8, 8, 102, 66, 230), "iron_ram_headbutt", "tusk_bristle_ram"),

    (67, 4, "wx_beast_liangqu", "历儿白首虎爪梁渠", "北山经", "beishan", "荒泽精英", "Direwolf", "wx_fig_beast_qiongqi",
     "《北山经》：“历儿之山，有兽焉，其状如狸，而白首虎爪，名曰梁渠，见则其国多兵。”",
     "兵燹凶兆·虎爪断筋", "凶煞兵气加持下穿甲率 +15%，巨型白虎利爪专断腿筋令目标下轮 AP -2【失衡】。",
     "高招架剑客开【回锋反击架势】可借其快攻反削其爪。", "狍鸮裂骨虎齿",
     (175, 55, 85, 10, 130, 18, 74, 0, 15, 12, 128, 68, 295), "tiger_claw_armor_tear", "feral_triple_bite"),

    (67, 5, "wx_beast_lingling", "空桑虎纹巨牛軨軨", "东山经", "dongshan", "荒泽精英", "Unhold", "wx_fig_beast_kui",
     "《东山经》：“空桑之山，有兽焉，其状如牛而虎文，其音如钦，其名曰軨軨，见则天下大水。”",
     "虎纹重革·浊浪踏阵", "厚重牛皮虎纹甲血厚防沉，重蹄踏地激起寒水浊浪震散周身敌军 10 点内息。",
     "双手重锤与陌刀专克此类低闪避重躯巨兽。", "朱厌千钧铁骨",
     (310, 110, 155, 9, 165, 18, 70, 0, 6, 8, 84, 78, 355), "flood_bull_trample", "iron_ram_headbutt"),

    (67, 6, "wx_beast_bibi", "姑逢旱翼火狐獙獙", "东山经", "dongshan", "山海群妖", "Hyena", "wx_fig_beast_yaomei",
     "《东山经》：“姑逢之山，有兽焉，其状如狐而有翼，其音如鸿雁，其名曰獙獙，见则天下大旱。”",
     "旱风焦羽·灼甲掠袭", "双翼扇出燥热旱风，每次掠袭额外灼烧目标 14 点护甲并扣减 8 点内息。",
     "重甲武士注意内息余量，及早以快箭射落。", "西山蛊雕斑革",
     (128, 35, 55, 10, 125, 20, 68, 64, 16, 18, 132, 60, 235), "scorch_wing_ember", "gliding_throat_nip"),

    (67, 7, "wx_beast_zhubie", "葛山六足吐珠螐鳖", "东山经", "dongshan", "荒泽精英", "Unhold", "wx_fig_beast_xuangui",
     "《东山经》：“葛山之尾，澧水出焉，有珠螐鱼，其状如肺而四目，六足有珠，其味酸甘，食之无疠。”",
     "六足石甲·激珠碎颅", "厚重石鳖背甲令刀剑箭矢伤害减免 35%；口吐水灵硬珠如炮弹远轰 3 格震晕对手！",
     "遣大铁锤、金锏手正面敲壳，切忌无盔暴露在其 3 格吐珠射界内。", "肥遗赤黑重鳞",
     (240, 150, 210, 9, 140, 16, 65, 70, 8, 22, 74, 76, 320), "pearl_cannon_spit", "iron_beak_clamp"),

    (67, 8, "wx_beast_heju", "北号赤首噬人猲狙", "东山经", "dongshan", "山海群妖", "Direwolf", "wx_fig_beast_tiangou",
     "《东山经》：“北号之山，临于北海，有兽焉，其状如狼，赤首鼠目，其音如豚，名曰猲狙，是食人。”",
     "鼠目窥瑕·嗜血狂噬", "狡诈鼠目专挑伤员下手（目标气血低于七成时命中 +12），咬穿皮肉自身回复 12 气血。",
     "受伤弟兄及时后撤或服金疮散稳住血线，防其滚雪球回血。", "阴山天狗苍裘",
     (138, 40, 62, 10, 120, 18, 69, 0, 12, 10, 126, 58, 230), "bloodthirst_fang_rip", "feral_triple_bite"),

    (67, 9, "wx_beast_qiuyu", "余峨鸱目蛇尾犰狳", "东山经", "dongshan", "山海群妖", "Serpent", "wx_fig_beast_xuangui",
     "《东山经》：“余峨之山，有兽焉，其状如菟而鸟喙，鸱目蛇尾，见人则眠，名曰犰狳，其鸣自詨，见则螽蝗为败。”",
     "诈眠诱敌·暴起反噬", "未行动前缩鳞伏地近远双防 +18，敌军一旦踏入邻格即暴起蛇尾毒钩反刺！",
     "切勿贸然单人贴脸探草，先以两格长杆兵器试探破其伏势。", "巴蛇微光逆鳞",
     (132, 85, 120, 9, 115, 18, 68, 0, 14, 16, 112, 62, 225), "feigned_sleep_ambush", "venom_fang_snap"),

    (67, 10, "wx_beast_zhuru", "耿山鱼翼恐狐朱獳", "东山经", "dongshan", "山海群妖", "Hyena", "wx_fig_beast_wenyao",
     "《东山经》：“耿山，无草木，多水碧，有兽焉，其状如狐而鱼翼，其名曰朱獳，其鸣自叫，见则其国有恐。”",
     "鱼翼滑浪·恐叫动摇", "背生棘刺鱼翼如利刃擦身割裂流血，尖啸直击敌手定力触发战意动摇检定。",
     "有《聚义令》定力光环坐镇即可无视其恐叫干扰。", "青丘妖魅惑心发",
     (120, 35, 55, 10, 120, 18, 66, 0, 15, 16, 128, 60, 210), "fin_wing_bleed_slash", "infant_cry_dread"),

    (67, 11, "wx_beast_feichong", "太山独目枯水蜚虫", "东山经", "dongshan", "山海群妖", "Spider", "wx_fig_beast_qinyuan",
     "《东山经》：“太山多金玉桢木，灾兽蜚之所居，伴生白首独目枯水疫蝻，行草则死。”",
     "枯水疫壳·蚀铁毒液", "甲壳带剧烈瘟疫酸液，死亡爆裂时向周身 1 格喷溅疫毒腐蚀 12 点护甲并染毒！",
     "最后一击尽量由两格长兵或弓弩完成，免被尸爆疫浆溅身。", "异兽五毒腺囊",
     (96, 65, 95, 9, 115, 18, 64, 62, 12, 14, 118, 65, 205), "plague_mandible_chew", "acid_scale_splash"),

    (67, 12, "wx_beast_yuanhu", "尸胡鱼目龙角妴胡", "东山经", "dongshan", "荒泽精英", "UnholdBog", "wx_fig_beast_fuzhu",
     "《东山经》：“尸胡之山，北望伊山，有兽焉，其状如麋而鱼目，名曰妴胡，其鸣自詨。”",
     "泽麋湿鳞·叉角挑甲", "沼泽水洼每回合恢复 15 气血，分叉骨角猛挑可将前排连人带盾掀翻失衡。",
     "引离水泽湿泥地块再集火围杀。", "朱厌千钧铁骨",
     (235, 80, 110, 9, 145, 18, 70, 0, 11, 12, 98, 70, 300), "antler_toss_gore", "cold_slime_spit"),

    (67, 13, "wx_beast_chiru", "青丘人面灵水赤鱬", "南山经", "nanshan", "山海群妖", "Alp", "wx_fig_beast_wenyao",
     "《南山经》：“青丘之山，英水出焉，南流注于即翼之泽，其中多赤鱬，其状如鱼而人面，其音如鸳鸯，食之不疥。”",
     "英水灵沤·清音愈群", "水灵之躯每轮为周身 2 格内受伤同伴异兽恢复 15 点气血并涤除流血状态！",
     "遭遇混编兽群时务必优先远程集火斩杀赤鱬，断绝群妖续航。", "巴蛇微光逆鳞",
     (125, 30, 55, 9, 130, 22, 56, 68, 16, 20, 115, 72, 240), "spirit_water_mend", "tidal_wind_blast"),

    (67, 14, "wx_beast_aohen", "三危四角铁蓑獓狠", "西山经", "xishan", "荒泽精英", "Unhold", "wx_fig_beast_kui",
     "《西山经》：“三危之山，有兽焉，其状如牛，白身四角，其毫如披蓑，其名曰獓狠，是食人。”",
     "铁蓑披刺·四角狂突", "全身披挂钢针般的硬毫蓑毛，远程箭矢伤害减半，四角蛮冲连破护甲与内腑！",
     "弓箭刮痧勿射獓狠，集中破甲重锤与拳掌内劲轰其胸腹。", "朱厌白首厚革",
     (340, 135, 185, 9, 170, 18, 74, 0, 8, 24, 82, 84, 395), "four_horn_cataclysm", "quill_volley_shot"),

    (67, 15, "wx_beast_leishou", "亶爰披髦双爪类兽", "南山经", "nanshan", "山海群妖", "Hyena", "wx_fig_beast_qiongqi",
     "《南山经》：“亶爰之山，多水，无草木，有兽焉，其状如狸而有髦，其名曰类，自为牝牡。”",
     "阴阳双运·迅影双抓", "体内孤阴独阳自相生息，每回合内息恢复高达 25 点，快爪连击永不力竭。",
     "高护甲硬吃其轻爪，以重刀一刀两断。", "西山蛊雕斑革",
     (135, 40, 60, 10, 145, 25, 70, 0, 17, 15, 136, 64, 245), "twin_claw_flurry", "membrane_dart_evade"),

    # ==================== Sheet 68: 中山经·巫峡神林百怪 (0..15) ====================
    (68, 0, "wx_beast_feiyi_hui", "浑夕一首双躯肥遗虺", "北山经", "beishan", "荒泽精英", "Serpent", "wx_fig_beast_feiyi",
     "《北山经》：“浑夕之山，有蛇一首两身，名曰肥遗，见则其国大旱。”",
     "一首双躯·盘绞双噬", "双蛇躯左右合击，单次出招可同时噬咬正面相邻两名敌军并注入燥旱奇毒！",
     "前排间隔站位或单盾卡位，勿给双躯同时缠咬两人的角度。", "肥遗蚀铁紫毒血",
     (225, 75, 115, 9, 140, 18, 72, 0, 12, 14, 108, 74, 315), "twin_body_double_fang", "scorch_wing_ember"),

    (68, 1, "wx_beast_zhuniao", "柜山人手夺刃鴸鸟", "南山经", "nanshan", "荒泽精英", "Vampire", "wx_fig_beast_gudiao",
     "《南山经》：“柜山，有鸟焉，其状如鸱而人手，其音如痹，其名曰鴸，其鸣自号也，见则其县多放士。”",
     "鸱翼人手·空手夺兵", "肋下生有苍劲人手精擅擒拿，俯冲扑抓有概率直接缴械夺落武人手中兵刃！",
     "拳掌宗师（成对护手免缴械）或高近防剑客迎战最为稳妥。", "西山蛊雕斑革",
     (150, 45, 70, 10, 130, 20, 73, 0, 18, 18, 134, 68, 285), "harpy_hand_disarm", "sky_talon_helm_rip"),

    (68, 2, "wx_beast_jiaochong", "平逢双首统螫骄虫", "中山经", "zhongshan", "荒泽精英", "Spider", "wx_fig_beast_qinyuan",
     "《中山经》：“平逢之山，有神焉，其状如人而二首，名曰骄虫，是为螫虫，实惟蜂蜜之庐。”",
     "百螫统领·双首号令", "在场时令全场蜘蛛、玄蜂、蜚虫等奇虫族命中 +10、身法 +15，双颚喷吐腐甲蜂毒！",
     "擒贼先擒王，以神臂强弩或梯云纵刺客率先斩落骄虫。", "异兽五毒腺囊",
     (195, 95, 140, 10, 145, 20, 72, 70, 15, 18, 124, 82, 340), "swarm_lord_command", "stinger_armor_pierce"),

    (68, 3, "wx_beast_mafu", "蔓渠人面虎身马腹", "中山经", "zhongshan", "荒泽精英", "Unhold", "wx_fig_beast_qiongqi",
     "《中山经》：“蔓渠之山，伊水出焉，有兽焉，其名曰马腹，其状如人面虎身，其音如婴儿，是食人。”",
     "凶狞人面·扑噬心腹", "兼备人智与猛虎凶力，专绕盾牌死角掏挖胸腹（无视盾牌加成一半近防，高穿甲流血）！",
     "长枪手两格拒止，配双手重刀迅速压低其血线。", "狍鸮裂骨虎齿",
     (275, 80, 125, 10, 160, 20, 76, 0, 14, 10, 116, 78, 365), "gut_ripper_pounce", "infant_cry_dread"),

    (68, 4, "wx_beast_changshe", "长舌山四耳反舌兽", "南山经", "nanshan", "山海群妖", "UnholdBog", "wx_fig_beast_zhuyan",
     "《南山经》：“长舌之山，有兽焉，其状如禺而四耳，其名曰长舌，其状如猱，其音如嗷，见则郡县大水。”",
     "四耳听矢·倒刺长舌", "四耳敏锐令远程避暗 +20；丈许倒刺长舌自 2 格外弹射锁喉将目标硬拽至身前！",
     "前排沉肩开启《不动明王盾》免疫抓取击退，废其拉人毒计。", "朱厌白首厚革",
     (190, 50, 80, 9, 135, 18, 69, 68, 12, 22, 114, 66, 275), "barbed_tongue_yank", "ape_sweep_fling"),

    (68, 5, "wx_beast_liuzhe", "流波紫电奔雷夔犊", "中山经", "zhongshan", "荒泽精英", "OrcBerserker", "wx_fig_beast_kui",
     "《山海雷泽志》：“流波山雷兽支裔，赤皮牛角，奔行间蹄下迸发紫电轰雷，震麻武人经脉。”",
     "紫电缠躯·麻痹雷震", "雷角冲撞附带紫电麻痹劲，令受击者内息暴涨 14 点且身法骤降！",
     "以高定力中正内功弟子顶线，调息化去麻痹内息。", "朱厌千钧铁骨",
     (230, 90, 135, 9, 150, 20, 72, 0, 10, 10, 112, 75, 320), "thunder_horn_jolt", "flood_bull_trample"),

    (68, 6, "wx_beast_yonghe", "丰山赤目狂恐雍和猿", "中山经", "zhongshan", "荒泽精英", "Unhold", "wx_fig_beast_zhuyan",
     "《中山经》：“丰山，有兽焉，其状如蝯，赤目、赤喙、黄身，名曰雍和，见则国有大恐。”",
     "大恐凶威·狂猿乱捶", "进场即掀动大恐煞气削弱周围敌军战意，气血受损后双拳疯狂乱捶破甲极狠！",
     "稳固军心后以破甲大斧与重剑迎头痛击。", "朱厌心头赤血核",
     (295, 70, 115, 9, 165, 20, 74, 0, 9, 6, 96, 80, 350), "dread_ape_pummel", "furious_chest_charge"),

    (68, 7, "wx_beast_longzhi", "凫丽九首虎爪蠪侄", "东山经", "dongshan", "荒泽精英", "Hyena", "wx_fig_beast_eshou",
     "《东山经/中山经》：“凫丽之山，有兽焉，其状如狐，而九尾、九首、虎爪，名曰蠪侄，其音如婴儿，是食人。”",
     "九首攒噬·九尾迷影", "九首轮番撕咬一击三伤，九尾摇曳幻影免除被围攻近防惩罚！",
     "暗器暴雨与扇面大刀横扫可破其幻影近防。", "青丘妖魅惑心发",
     (215, 65, 100, 10, 145, 20, 75, 0, 16, 16, 128, 76, 360), "nine_fox_frenzy_bite", "gut_ripper_pounce"),

    (68, 8, "wx_beast_xuanfeng", "昆仑壶腹透铁玄蜂", "海内西经", "xishan", "山海群妖", "Spider", "wx_fig_beast_qinyuan",
     "《楚辞·招魂 / 山海异虫志》：“赤蚁若象，玄蜂若壶些——昆仑黑蜂大如酒壶，尾毒透铁烂石。”",
     "飞空避刃·壶尾透甲针", "悬浮半空近远双防俱佳，尾后乌钢毒针具备恐怖 55% 穿甲率并直注蚀心蜂毒！",
     "散弹火铳、扇面飞刀或大网罩落最为干脆。", "异兽五毒腺囊",
     (92, 45, 65, 10, 125, 20, 70, 0, 19, 22, 146, 58, 220), "stinger_armor_pierce", "neuro_venom_bite"),

    (68, 9, "wx_beast_juru", "倚帝白耳啮甲狙如", "中山经", "zhongshan", "山海群妖", "Direwolf", "wx_fig_beast_tiangou",
     "《中山经》：“倚帝之山，有兽焉，其状如鼣鼠，白耳白喙，名曰狙如，见则其国有大兵。”",
     "钻隙啮扣·群鼠蚀甲", "体型低矮专钻重铠甲叶皮扣，每口啮咬直接削毁 18 点护甲耐久并令步卒失衡。",
     "长棍横扫或大刀挥斩一刀一个，切勿任其成群围住铁布衫前排。", "狍鸮裂骨虎齿",
     (82, 25, 42, 10, 120, 20, 66, 0, 18, 18, 140, 48, 170), "armor_buckle_gnaw", "gliding_throat_nip"),

    (68, 10, "wx_beast_nengbie", "苦山从水三足能鳖", "中山经", "zhongshan", "荒泽精英", "Unhold", "wx_fig_beast_xuangui",
     "《中山经》：“苦山，狂水出焉，东南流注于伊水，其中多三足龟，名曰能，食者无大疾，可以已肿。”",
     "三足铁甲·死咬不松", "墨黑古甲厚达 240 点，鹰嘴一旦咬住前排便死锁不放（定身缠足并持续碎骨）！",
     "八棱铁锤、立瓜重锤或震岳碎甲锤两击可敲裂其龟背。", "肥遗赤黑重鳞",
     (255, 165, 240, 8, 140, 16, 68, 0, 8, 24, 65, 85, 335), "iron_beak_clamp", "bark_aegis_regrow"),

    (68, 11, "wx_beast_wenbao", "荆山赤金剑齿文豹", "中山经", "zhongshan", "山海群妖", "Hyena", "wx_fig_beast_qiongqi",
     "《中山经》：“荆山，漳水出焉，多髦牛，多豹虎，赤金斑纹，伏莽跃涧，一扑断喉。”",
     "伏莽暴起·剑齿穿喉", "首轮先攻身法 +25，高处跃下扑击伤害 +20% 且专咬咽喉。",
     "抢占高地石坡，莫让文豹居高临下俯扑。", "西山蛊雕斑革",
     (145, 45, 70, 10, 130, 20, 72, 0, 16, 14, 138, 62, 250), "saber_fang_throat_rip", "feral_triple_bite"),

    (68, 12, "wx_beast_gengfu", "清冷渊神光耕父水魅", "中山经", "zhongshan", "荒泽精英", "Ghost", "wx_fig_beast_bingyi",
     "《中山经》：“丰山，神耕父处之，常游清冷之渊，出入有光，见则其国为败。”",
     "清冷神光·寒渊夺气", "出入迸发幽蓝寒渊神光致盲近身武人（命中 -15），挥戟抽取敌军内息化为寒冰护盾。",
     "内家纯阳真气或《九幽镇魂录》专克此类半灵水魅。", "荒冢凝魄寒晶",
     (165, 70, 105, 9, 150, 22, 70, 68, 20, 24, 122, 90, 330), "abyss_glare_flash", "frost_halberd_drain"),

    (68, 13, "wx_beast_lili", "柜山距爪掘地狸力", "南山经", "nanshan", "山海群妖", "OrcYoung", "wx_fig_beast_dangkang",
     "《南山经》：“柜山，有兽焉，其状如豚，有距，其音如狗吠，其名曰狸力，见则其县多土功。”",
     "铁距翻土·裂地陷足", "生有尖利鸡距铁爪，猛刨地面掀起碎石土浪，令扇形敌军集体陷入【失衡】！",
     "轻功弟子可踏过翻土碎石，重兵正面斩其前蹄。", "狍鸮弯钩凶角",
     (170, 65, 100, 9, 135, 18, 67, 0, 9, 10, 95, 64, 235), "earth_churn_tremor", "tusk_bristle_ram"),

    (68, 14, "wx_beast_shanxiao", "巫山赤发掷石山魈", "海内经", "zhongshan", "荒泽精英", "OrcBerserker", "wx_fig_beast_zhuyan",
     "《海内经 / 巫峡异闻》：“深山大泽有独足反踵巨魈，面蓝赤发，力拔山石，呼啸掷岩碎人胸骨。”",
     "拔石远掷·山林跳跃", "既可自 3 格外抱起磨盘山石猛砸重甲（造成脏腑内伤），近身亦能重拳击退！",
     "贴近其 1 格控制区即可封死其抱石远砸动作。", "狍鸮颅内髓珠",
     (220, 60, 95, 9, 150, 20, 70, 70, 12, 10, 110, 70, 305), "boulder_crag_hurl", "woodchop_fist_smash"),

    (68, 15, "wx_beast_tianwu", "朝阳谷八首天吴水裔", "海外东经", "dahuang", "荒泽精英", "Lindwurm", "wx_fig_beast_xiangliu",
     "《海外东经》：“朝阳之谷，神曰天吴，是为水伯，其为兽也，八首人面，八足八尾，皆青黄色。”",
     "水伯威压·八尾漩流", "多首环顾免疫侧后围攻夹击惩罚，掀起漩流击退周身一圈敌军并削损内息。",
     "分两路长枪远弩夹射，勿扎堆聚于水涡中心。", "肥遗赤黑重鳞",
     (390, 120, 180, 9, 185, 20, 75, 0, 12, 12, 92, 90, 440), "vortex_tail_maelstrom", "wyrm_gorge_chomp"),

    # ==================== Sheet 69: 海外·海内·大荒经 神魔眷属与伴生异体 (0..15) ====================
    (69, 0, "wx_beast_huantou", "大荒鸟喙翼人驩头", "大荒南经", "dahuang", "山海群妖", "GoblinAmbusher", "wx_fig_beast_yumin",
     "《海外南经 / 大荒南经》：“驩头国在其南，其为人人面有翼，鸟喙方捕鱼，杖翼而行。”",
     "滑翼掷叉·水陆游猎", "手执倒刺鱼骨飞叉自空中精准投射（4 格射程，附割裂流血），被逼近即振翼后撤。",
     "用弓弩对射压制，或以缩地成寸轻功贴身斩杀。", "西山蛊雕斑革",
     (125, 50, 75, 9, 125, 18, 62, 72, 14, 18, 122, 60, 230), "harpoon_dive_throw", "wing_gust_backleap"),

    (69, 1, "wx_beast_guanxiong", "海外穿胸不死尸卒", "海外南经", "dahuang", "山海群妖", "SkeletonMedium", "wx_fig_beast_xingtian",
     "《海外南经》：“贯匈国在其东，其为人匈有窍——古战死卒怨气结聚，胸穿大洞而不死。”",
     "胸穿无心·透矢不伤", "胸膛中空无心肺要害，彻底免疫点穴、奇毒、流血，且弓弩箭矢常常穿洞而过（远伤减免 65%）！",
     "严禁浪费箭矢射贯胸卒！直接用钝器锤棍敲碎其骨骼。", "古墓血魔枯蜕",
     (155, 95, 135, 9, 999, 0, 66, 0, 10, 25, 78, 99, 245), "hollow_chest_halberd", "corpse_shield_shove"),

    (69, 2, "wx_beast_yimu", "北荒竖瞳巨棒一目蛮", "海外北经", "dahuang", "荒泽精英", "Unhold", "wx_fig_beast_kuafu",
     "《海外北经》：“一目国在其东，一目中其面而居——身长丈余，手提千钧石柱横扫荒原。”",
     "独目神力·千钧破城", "天生怪力破甲倍率高达 160%，但独目视野狭窄令远防偏低且受烟幕重度克制！",
     "掷出烟幕弹迷其独目，再用强弩攒射其面门。", "朱厌千钧铁骨",
     (320, 80, 140, 9, 160, 18, 71, 0, 6, 0, 78, 78, 360), "cyclops_pillar_crush", "boulder_crag_hurl"),

    (69, 3, "wx_beast_changbi", "海外垂地丈臂抓人妖", "海外南经", "dahuang", "山海群妖", "UnholdBog", "wx_fig_beast_yumin",
     "《海外南经》：“长臂国在其东，捕鱼水中，两手各操一鱼，双臂修长垂地逾丈。”",
     "猿臂三格·隔阵擒拿", "双臂奇长可在 2~3 格距离外直接抓挠后排或将盾墙后的药师一把扯出阵线！",
     "将脆皮置于第 4 格以外，前排用大斧剁断其长臂。", "朱厌白首厚革",
     (180, 45, 75, 9, 135, 18, 70, 0, 12, 10, 110, 64, 270), "three_tile_claw_snatch", "ape_sweep_fling"),

    (69, 4, "wx_beast_yumin", "南荒赤目黑羽飞矛妖", "海外南经", "dahuang", "山海群妖", "Vampire", "wx_fig_beast_yumin",
     "《海外南经》：“羽民国在其东南，其为人长头，身生羽，赤目白首，不远飞而善俯击。”",
     "铁羽披身·俯冲贯矛", "全身黑青硬羽减免 20% 轻刃劈砍，高空俯冲骨矛直刺额外增加 20% 穿甲伤。",
     "长枪【拒马守线】天克一切俯冲飞妖。", "西山蛊雕斑革",
     (135, 55, 85, 10, 130, 20, 70, 66, 16, 18, 132, 65, 250), "feather_spear_plunge", "harpoon_dive_throw"),

    (69, 5, "wx_beast_nieer", "北荒执虎驭猫聂耳妖", "海外北经", "dahuang", "荒泽精英", "BarbarianMarauder", "wx_fig_beast_qiongqi",
     "《海外北经》：“聂耳之国在无肠国东，使两文虎，为人两手聂其耳，县居海渚。”",
     "双耳听风·文虎合扑", "巨耳听风免疫背刺与夜战惩罚；攻击时肩头斑斓山猫同步扑咬追加一段撕裂伤！",
     "重甲正面硬刚，先斩其肩头山猫削其双段输出。", "西山蛊雕斑革",
     (210, 85, 130, 9, 145, 18, 73, 0, 12, 14, 112, 74, 310), "tamed_lynx_combo", "woodchop_fist_smash"),

    (69, 6, "wx_beast_heichi", "东荒缠蛇喷瘴黑齿祝", "海外东经", "dahuang", "荒泽精英", "GoblinShaman", "wx_fig_beast_yumin",
     "《海外东经 / 大荒东经》：“黑齿国在其北，为人黑，食稻啖蛇，一赤一青，驱蛇布瘴。”",
     "青赤双虺·毒雾咒障", "远距召唤青赤毒雾笼罩 2 格区域，使踏入侠客视野受阻、内息淤滞并染蛇毒！",
     "派《凌波御风步》或《梯云纵》刺客绕后一刀枭首。", "异兽五毒腺囊",
     (120, 40, 65, 9, 140, 22, 56, 74, 14, 20, 118, 76, 295), "twin_viper_miasma", "cold_slime_spit"),

    (69, 7, "wx_beast_quanfeng", "海内盘瓠狗首狂战鬼", "海内北经", "dahuang", "山海群妖", "OrcBerserker", "wx_fig_beast_tiangou",
     "《海内北经》：“犬封国曰犬戎国，状如犬——狗首人身披骨甲，喋血狂吠死战不退。”",
     "狂犬喋血·越战越凶", "每损失 20% 气血则武艺 +4、身法 +8，残血时一回合可连扑带砍三次！",
     "不留残血犬封战鬼过夜，集中火力一轮秒杀。", "阴山天狗苍裘",
     (185, 75, 110, 10, 145, 20, 71, 0, 10, 8, 120, 75, 275), "hound_berserk_cleave", "bloodthirst_fang_rip"),

    (69, 8, "wx_beast_denglin", "大荒邓林燃火桃木灵", "海外北经", "dahuang", "荒泽精英", "Schrat", "wx_fig_beast_kuafu",
     "《海外北经》：“夸父与日逐走，弃其杖，化为邓林——桃木吸纳大日余烬化生炎木巨灵。”",
     "大日余烬·炎枝灼甲", "免疫毒与点穴；桃木巨臂横扫附带大日余火灼烧 18 点护甲，但极惧开山巨斧与寒冰劲！",
     "玄冥寒毒掌或大斧专克炎木巨灵。", "都广建木万年灵心",
     (330, 120, 195, 9, 175, 20, 72, 0, 8, 22, 76, 99, 405), "solar_peach_branch_slam", "root_line_impale"),

    (69, 9, "wx_beast_jiuli", "凶黎吞刃铜角魔兵", "大荒北经", "dahuang", "荒泽精英", "OrcWarrior", "wx_fig_beast_xingtian",
     "《述异记 / 大荒北经》：“蚩尤兄弟八十一人，并兽身人语，铜头铁额，食沙石子，造立兵杖刀戟大弩。”",
     "铜头铁额·吞砂碎刃", "免疫爆头与眩晕，厚重古铜重甲硬撼前排，撞击可强行顶开盾墙守军！",
     "用拳掌透甲内劲（亢龙掌、一阳指）隔着铜甲直震其脏腑。", "幽冥剑魔灵烬",
     (245, 210, 250, 9, 160, 18, 74, 0, 12, 12, 86, 90, 385), "bronze_horn_linebreaker", "hollow_chest_halberd"),

    (69, 10, "wx_beast_bingfeng", "轩辕前后双首黑彘", "海外西经", "dahuang", "山海群妖", "OrcYoung", "wx_fig_beast_dangkang",
     "《海外西经》：“并封在巫咸东，其状如彘，前后皆有首，黑。”",
     "前后双首·背刺无效", "首尾皆生獠牙猪首，彻底免除背刺与合围命中惩罚，受背后偷袭自动回咬反击！",
     "不必费心绕背，正面长枪大戟堂堂正正刺杀即可。", "狍鸮弯钩凶角",
     (180, 70, 105, 9, 135, 18, 69, 0, 14, 10, 104, 68, 255), "two_way_tusk_snap", "tusk_bristle_ram"),

    (69, 11, "wx_beast_honghui", "流波双首蚀甲虹虺", "大荒东经", "dahuang", "山海群妖", "Serpent", "wx_fig_beast_xiangliu",
     "《海外东经 / 大荒东经》：“蜺虹双首，饮海吐卤，青蓝毒鳞蚀金烂铁。”",
     "双首吐卤·盐雾蚀铁", "两首交替喷吐苦卤酸雾，大范围削损前排头身双甲各 15 点并致目眩。",
     "速战速决，莫打持久消耗战。", "肥遗蚀铁紫毒血",
     (175, 60, 95, 9, 125, 18, 68, 68, 12, 14, 108, 66, 260), "brine_acid_twin_spit", "twin_body_double_fang"),

    (69, 12, "wx_beast_shirou", "北荒聚肉太岁不死妖", "海外北经", "dahuang", "荒泽精英", "ZombieBetrayer", "wx_fig_beast_hundun",
     "《海外北经 / 大荒北经》：“聚肉有眼，状如牛肝，食之尽，寻复更生如故，名曰视肉。”",
     "割肉复生·血肉吞裹", "无骨无甲却拥有极高气血与每轮 35 点恐怖肉芽再生（烈火雷弹与流血可破），骨鞭纠缠吸取内息！",
     "霹雳雷火弹、燃木烈阳劈及高频割裂流血可彻底烧绝其再生肉芽。", "朱厌心头赤血核",
     (420, 0, 20, 8, 200, 25, 68, 0, 0, 5, 58, 99, 370), "flesh_tendril_engulf", "feast_corpse_grow"),

    # --- 3 Ecological Battlefield Spawn Tokens (Completing 139 Total Beast Pawns!) ---
    (69, 13, "wx_beast_chizhu_egg", "鬼面赤蛛育蛊卵囊", "西山经", "xishan", "伴生衍生物", "SpiderEggs", "wx_fig_beast_chizhu",
     "《山海五毒志》：“毒谷深处紫脉盘结之蛛母卵巢，胎动如鼓，源源孵化鬼面赤蛛扑杀生人。”",
     "搏动育蛊·破茧喷丝", "固定于菌毯巢穴无法移动，但每回合初自动孵化 1 只鬼面赤蛛，破碎时溅射黏丝！",
     "突击小队绕过蛛群第一时间捣毁卵囊，否则赤蛛无穷无尽。", "鬼面赤蛛天韧丝",
     (90, 0, 35, 0, 50, 0, 0, 0, -15, -10, 20, 99, 80), "brood_hatch_pulse", "silk_web_snare"),

    (69, 14, "wx_beast_jianmu_ling", "建木盘根护主木灵", "海内经", "zhongshan", "伴生衍生物", "SchratSmall", "wx_fig_beast_jianmu",
     "《海内经》：“都广建木九欘九枸，巨干受斧斤重创时，断落灵枝入土即化护主小木灵。”",
     "断根化生·缠足护主", "建木树精或句芒建木王受重击时自动破土而出，抢占控制区卡住侠客走位！",
     "单手快斧或顺劈横扫顺手清掉即可，莫被其卡住主力输出位。", "建木琥珀灵脂",
     (95, 45, 75, 9, 110, 18, 60, 0, 10, 18, 95, 99, 95), "sapling_root_lash", "bark_aegis_regrow"),

    (69, 15, "wx_beast_xiangliu_chu", "相柳九首剧毒触蟒", "海外北经", "dahuang", "伴生衍生物", "KrakenTentacle", "wx_fig_beast_xiangliu",
     "《海外北经》：“共工臣相柳潜于苦泽之下，九首分探泥沼如巨蟒破地，缚武人入渊噬骨。”",
     "破泽缠缚·断触伤本", "无视盾墙直接捆缚目标使其无法移动且近远双防归零，每次击破触蟒均会反震相柳本体！",
     "优先挥刀斩断缠住队友的触蟒（命中率高），救人同时削减本体血量。", "异兽五毒腺囊",
     (140, 50, 80, 9, 140, 20, 72, 0, 5, 10, 90, 99, 110), "mire_tentacle_drag", "venom_fang_snap"),
]

# ==============================================================================
# 3. MONSTER ACTIVE SKILL LIBRARY (Used by Wild Beasts & Apex Bosses!)
#    20 Distinct 60fps Monster Combat Choreographies (`animMode`)!
# ==============================================================================
MONSTER_SKILL_LIB = {
    # --- Pounce / Claw / Fang (`feral_pounce`, `multi_head_frenzy`) ---
    "feral_triple_bite": {
        "name": "疾影噬喉扑", "ap": 4, "qi": 12, "range": "1格近战", "dmg": "32 - 48", "directPct": 30, "armorPct": 90, "cd": "无冷却",
        "effects": ["割裂流血"], "animMode": "feral_pounce", "animColor": "#ff5442", "fx": "wx_fx_claw_slash",
        "desc": "压低兽躯如离弦凶星突进撕咬咽喉，轻快 4 AP 连扑，伤血必挂割裂流血。"
    },
    "anti_gu_jaw_lock": {
        "name": "辟蛊锁腕咬", "ap": 4, "qi": 14, "range": "1格近战", "dmg": "38 - 55", "directPct": 36, "armorPct": 105, "cd": "无冷却",
        "effects": ["散功虚弱", "破绽"], "animMode": "feral_pounce", "animColor": "#e63946", "fx": "wx_fx_claw_slash",
        "desc": "恶犬铁颚死死咬穿护腕脉门，震散目标 12 点内息并令其招式散乱。"
    },
    "star_howl_rush": {
        "name": "坠星奔狼袭", "ap": 5, "qi": 20, "range": "2格跃扑", "dmg": "42 - 62", "directPct": 35, "armorPct": 105, "cd": "冷却2轮",
        "effects": ["失衡"], "animMode": "feral_pounce", "animColor": "#7ee8ff", "fx": "wx_fx_claw_slash",
        "desc": "伴随闷雷狼嚎自两格外腾空扑倒目标，冲击力震得对手下盘失衡。"
    },
    "horned_beak_rend": {
        "name": "弯角钩喙裂", "ap": 4, "qi": 14, "range": "1格近战", "dmg": "38 - 56", "directPct": 35, "armorPct": 110, "cd": "无冷却",
        "effects": ["割裂流血", "破绽"], "animMode": "sky_talon_dive", "animColor": "#e85d3f", "fx": "wx_fx_claw_slash",
        "desc": "独角顶盾、铁钩利喙狠啄甲缝动脉，撕开深长血口并留门户破绽。"
    },
    "infant_cry_dread": {
        "name": "婴啼摄魄啸", "ap": 5, "qi": 22, "range": "周身2格妖音", "dmg": "心神震慑", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["战意动摇", "失衡"], "animMode": "sonic_dread_roar", "animColor": "#c96bff", "fx": "wx_fx_sonic_ring",
        "desc": "夜半凄厉婴儿啼哭直钻脑髓，令周身 2 格内敌军承受高难战意检定并陷入失衡。"
    },
    "tiger_fang_maul": {
        "name": "虎齿裂骨噬", "ap": 4, "qi": 15, "range": "1格近战", "dmg": "44 - 66", "directPct": 35, "armorPct": 120, "cd": "无冷却",
        "effects": ["脏腑内伤"], "animMode": "feral_pounce", "animColor": "#ff4d3b", "fx": "wx_fx_claw_slash",
        "desc": "人爪按肩、锯齿虎牙猛啃锁骨，凶残咬合力隔甲震伤经脉。"
    },
    "feast_corpse_grow": {
        "name": "吞骸暴血噬", "ap": 5, "qi": 18, "range": "1格尸骸/残敌", "dmg": "回复90气血", "directPct": 50, "armorPct": 100, "cd": "冷却2轮",
        "effects": ["噬血回元", "凶威暴涨"], "animMode": "devour_blood_siphon", "animColor": "#e62e45", "fx": "wx_fx_blood_orb",
        "desc": "张开深渊巨口吞食脚下尸骸或重创残敌，大幅恢复气血并令筋骨暴涨！"
    },
    "bloodthirst_fang_rip": {
        "name": "嗜血饮髓咬", "ap": 4, "qi": 15, "range": "1格近战", "dmg": "40 - 58", "directPct": 35, "armorPct": 100, "cd": "无冷却",
        "effects": ["噬血回元", "割裂流血"], "animMode": "devour_blood_siphon", "animColor": "#ff3b4e", "fx": "wx_fx_blood_orb",
        "desc": "专咬已挂彩伤员血口，汲取温热血浆回复自身生机。"
    },
    "tiger_claw_armor_tear": {
        "name": "白虎裂甲抓", "ap": 5, "qi": 18, "range": "1格近战", "dmg": "52 - 76", "directPct": 35, "armorPct": 145, "cd": "无冷却",
        "effects": ["破绽", "失衡"], "animMode": "feral_pounce", "animColor": "#ffd166", "fx": "wx_fx_claw_slash",
        "desc": "蒲扇般重爪灌注凶兽煞力横拍胸甲，甲叶崩飞并震散守势。"
    },
    "ox_tail_double_sweep": {
        "name": "铁尾扫千军", "ap": 6, "qi": 24, "range": "近身扇形2格", "dmg": "48 - 70", "directPct": 25, "armorPct": 125, "cd": "冷却1轮",
        "effects": ["击退破盾", "失衡"], "animMode": "coiled_crush", "animColor": "#f4a261", "fx": "wx_fx_earth_fissure",
        "desc": "钢鞭般的粗壮兽尾横扫身前两格，将并排守军连人带盾抽退！"
    },
    "saber_fang_throat_rip": {
        "name": "剑齿断喉扑", "ap": 5, "qi": 18, "range": "1~2格跃扑", "dmg": "48 - 72", "directPct": 42, "armorPct": 95, "cd": "无冷却",
        "effects": ["割裂流血"], "animMode": "feral_pounce", "animColor": "#ffb703", "fx": "wx_fx_claw_slash",
        "desc": "伏草蓄力一跃而起，匕首般的弯长剑齿直取咽喉要害（击头率 +20%）。"
    },
    "gut_ripper_pounce": {
        "name": "人面掏心爪", "ap": 5, "qi": 20, "range": "1格近战", "dmg": "55 - 82", "directPct": 45, "armorPct": 120, "cd": "无冷却",
        "effects": ["割裂流血", "脏腑内伤"], "animMode": "feral_pounce", "animColor": "#ff4757", "fx": "wx_fx_claw_slash",
        "desc": "诡异人面狞笑吸引注意，虎躯斜窜绕开盾牌死角猛掏心腹！"
    },
    "twin_claw_flurry": {
        "name": "阴阳连环抓", "ap": 4, "qi": 12, "range": "1格近战", "dmg": "36 - 54", "directPct": 32, "armorPct": 100, "cd": "无冷却",
        "effects": ["破绽"], "animMode": "multi_head_frenzy", "animColor": "#72efdd", "fx": "wx_fx_claw_slash",
        "desc": "双爪如风车轮转连抓两记，绵密攻势迫使对手露出破绽。"
    },
    "nine_fox_frenzy_bite": {
        "name": "九首噬心狂咬", "ap": 6, "qi": 26, "range": "1格三段连噬", "dmg": "64 - 92", "directPct": 38, "armorPct": 130, "cd": "冷却1轮",
        "effects": ["割裂流血", "破绽"], "animMode": "multi_head_frenzy", "animColor": "#ff4d6d", "fx": "wx_fx_claw_slash",
        "desc": "九颗狰狞狐首自四面八方同时噬咬同一猎物，防不胜防！"
    },
    "triple_beak_flurry": {
        "name": "三首快啄连击", "ap": 4, "qi": 14, "range": "1格三连啄", "dmg": "34 - 50", "directPct": 30, "armorPct": 95, "cd": "无冷却",
        "effects": ["破绽"], "animMode": "multi_head_frenzy", "animColor": "#ff9f1c", "fx": "wx_fx_claw_slash",
        "desc": "三颗鸡首交替疾啄眼鼻咽喉，专破轻装侠客招架。"
    },
    "six_eye_glare": {
        "name": "六目破隐凝视", "ap": 3, "qi": 12, "range": "3格锁定", "dmg": "破隐露绽", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["破绽"], "animMode": "sonic_dread_roar", "animColor": "#ffe66d", "fx": "wx_fx_lotus_seal",
        "desc": "六只金瞳射出妖芒看破烟幕与身法，令目标闪避大幅下降。"
    },
    "armor_buckle_gnaw": {
        "name": "白齿蚀扣啮", "ap": 4, "qi": 12, "range": "1格近战", "dmg": "28 - 42", "directPct": 25, "armorPct": 185, "cd": "无冷却",
        "effects": ["失衡"], "animMode": "feral_pounce", "animColor": "#adb5bd", "fx": "wx_fx_claw_slash",
        "desc": "贴地蹿入脚下专咬铁铠皮扣与靴踝，护甲耐久大损。"
    },

    # --- Serpent / Wyrm / Tentacle (`coiled_crush`, `dragon_breath`, `abyss_tentacle_drag`) ---
    "python_drag_coil": {
        "name": "巨蟒盘身卷", "ap": 5, "qi": 22, "range": "1~2格卷拽", "dmg": "45 - 65", "directPct": 35, "armorPct": 110, "cd": "冷却1轮",
        "effects": ["失衡", "拉拽移位"], "animMode": "abyss_tentacle_drag", "animColor": "#4cc9f0", "fx": "wx_fx_whip_arc",
        "desc": "碗口粗青鳞蛇躯闪电探出，将两格外猎物硬生生卷入蛇阵中央绞杀！"
    },
    "venom_fang_snap": {
        "name": "七寸毒牙噬", "ap": 4, "qi": 14, "range": "1格近战", "dmg": "38 - 56", "directPct": 38, "armorPct": 95, "cd": "无冷却",
        "effects": ["暗器剧毒"], "animMode": "coiled_crush", "animColor": "#52b788", "fx": "wx_fx_poison_skull",
        "desc": "昂首弹射毒牙贯入甲缝，注入麻痹心脉的阴寒蛇毒。"
    },
    "wyrm_gorge_chomp": {
        "name": "太华噬铁巨颚", "ap": 5, "qi": 20, "range": "1~2格近战", "dmg": "75 - 108", "directPct": 40, "armorPct": 165, "cd": "无冷却",
        "effects": ["破绽", "蚀甲焚气"], "animMode": "coiled_crush", "animColor": "#b5179e", "fx": "wx_fx_poison_skull",
        "desc": "肥遗毒蛟张开合抱巨口连人带甲猛噬，重铠如纸糊般碎裂！"
    },
    "wyrm_tail_thresh": {
        "name": "六足龙尾横扫", "ap": 6, "qi": 26, "range": "扇形3格横扫", "dmg": "62 - 90", "directPct": 30, "armorPct": 140, "cd": "冷却1轮",
        "effects": ["击退破盾", "失衡"], "animMode": "coiled_crush", "animColor": "#ff6d00", "fx": "wx_fx_earth_fissure",
        "desc": "沉重鳞尾挟腥风横扫三格弧面，整排盾卫尽数震飞！"
    },
    "mire_tentacle_drag": {
        "name": "苦泽毒触缠缚", "ap": 4, "qi": 16, "range": "1~3格缠抓", "dmg": "36 - 52", "directPct": 35, "armorPct": 100, "cd": "无冷却",
        "effects": ["蛛网缠足", "暗器剧毒"], "animMode": "abyss_tentacle_drag", "animColor": "#38b000", "fx": "wx_fx_poison_skull",
        "desc": "蛇首巨触破泥缠死猎物四肢并拖向泽心，使其近远防御大跌！"
    },
    "nine_marsh_devour": {
        "name": "九首苦渊吞天", "ap": 6, "qi": 28, "range": "1~2格绝杀", "dmg": "88 - 125", "directPct": 50, "armorPct": 160, "cd": "冷却1轮",
        "effects": ["暗器剧毒", "脏腑内伤"], "animMode": "multi_head_frenzy", "animColor": "#70e000", "fx": "wx_fx_poison_skull",
        "desc": "对已被触手缠缚之猎物九首齐下狂噬，凶威骇人！"
    },
    "twin_body_double_fang": {
        "name": "双躯交剪毒噬", "ap": 5, "qi": 20, "range": "近身双目标", "dmg": "46 - 68", "directPct": 36, "armorPct": 115, "cd": "无冷却",
        "effects": ["暗器剧毒", "失衡"], "animMode": "coiled_crush", "animColor": "#e63946", "fx": "wx_fx_poison_skull",
        "desc": "一首分驭左右双蛇躯呈剪刀势绞杀相邻两名武人。"
    },
    "brine_acid_twin_spit": {
        "name": "苦卤蚀甲双喷", "ap": 5, "qi": 24, "range": "2~4格毒息", "dmg": "35 - 52", "directPct": 30, "armorPct": 190, "cd": "冷却2轮",
        "effects": ["蚀甲焚气", "破绽"], "animMode": "dragon_breath", "animColor": "#00bbf9", "fx": "wx_fx_poison_skull",
        "desc": "双首交织喷射东海强酸苦卤，瞬间熔蚀大片铁甲。"
    },
    "cold_slime_spit": {
        "name": "寒渊腥涎喷吐", "ap": 4, "qi": 16, "range": "2~3格远程", "dmg": "28 - 42", "directPct": 25, "armorPct": 110, "cd": "冷却1轮",
        "effects": ["破绽", "失衡"], "animMode": "dragon_breath", "animColor": "#48cae4", "fx": "wx_fx_ice_spikes",
        "desc": "喷吐冰冷滑腻水妖浓涎糊住面门脚踝，令敌手步伐踉跄门户大开。"
    },
    "six_claw_serpent_bite": {
        "name": "六足攀甲毒咬", "ap": 4, "qi": 14, "range": "1格近战", "dmg": "40 - 58", "directPct": 35, "armorPct": 110, "cd": "无冷却",
        "effects": ["暗器剧毒"], "animMode": "coiled_crush", "animColor": "#00b4d8", "fx": "wx_fx_claw_slash",
        "desc": "六只利爪扣死胸甲顺势毒牙穿喉。"
    },
    "vortex_tail_maelstrom": {
        "name": "八尾惊涛漩流", "ap": 6, "qi": 28, "range": "周身1格全扫", "dmg": "56 - 80", "directPct": 30, "armorPct": 135, "cd": "冷却2轮",
        "effects": ["击退破盾", "散功虚弱"], "animMode": "coiled_crush", "animColor": "#0096c7", "fx": "wx_fx_sonic_ring",
        "desc": "八条斑斓巨尾卷起黑水狂澜360度横扫周身所有敌军！"
    },

    # --- Ape / Giant / Treant (`ape_titan_slam`, `boulder_hurl_smash`, `root_thorn_entangle`) ---
    "ape_sweep_fling": {
        "name": "白首掀山扫", "ap": 5, "qi": 22, "range": "扇形3格重扫", "dmg": "54 - 78", "directPct": 35, "armorPct": 135, "cd": "冷却1轮",
        "effects": ["击退破盾", "失衡"], "animMode": "ape_titan_slam", "animColor": "#ff595e", "fx": "wx_fx_earth_fissure",
        "desc": "通臂巨猿横抡双臂如扫落叶，将正面三格盾阵直接掀翻震退！"
    },
    "furious_chest_charge": {
        "name": "沸血蛮猿撞", "ap": 5, "qi": 24, "range": "2格冲撞", "dmg": "50 - 74", "directPct": 38, "armorPct": 140, "cd": "冷却2轮",
        "effects": ["失衡", "脏腑内伤"], "animMode": "ape_titan_slam", "animColor": "#ff924c", "fx": "wx_fx_earth_fissure",
        "desc": "捶胸咆哮后撞入敌阵并强行换位，踏碎阵眼。"
    },
    "dread_ape_pummel": {
        "name": "大恐乱岳双捶", "ap": 5, "qi": 22, "range": "1格重击", "dmg": "60 - 88", "directPct": 42, "armorPct": 155, "cd": "无冷却",
        "effects": ["脏腑内伤", "战意动摇"], "animMode": "ape_titan_slam", "animColor": "#ffca3a", "fx": "wx_fx_earth_fissure",
        "desc": "合握黄毛巨拳自头顶当胸贯砸，隔甲震裂肋骨并摄夺胆魄。"
    },
    "woodchop_fist_smash": {
        "name": "斫木碎盾重拳", "ap": 4, "qi": 16, "range": "1格近战", "dmg": "46 - 68", "directPct": 32, "armorPct": 165, "cd": "无冷却",
        "effects": ["击退破盾"], "animMode": "ape_titan_slam", "animColor": "#d4a373", "fx": "wx_fx_earth_fissure",
        "desc": "拳重如铁斧劈柴，专碎前排木盾藤牌与护肩。"
    },
    "bristle_rage_roar": {
        "name": "彘鬣铁刺怒张", "ap": 4, "qi": 18, "range": "自身架势", "dmg": "反伤护体", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["护体减伤", "近战反刺"], "animMode": "shell_thorns_quake", "animColor": "#e76f51", "fx": "wx_fx_golden_bell",
        "desc": "全身黑硬猪鬃倒竖如钢针，减伤 25% 并反扎一切贴身刀剑。"
    },
    "barbed_tongue_yank": {
        "name": "反生倒刺舌拽", "ap": 4, "qi": 18, "range": "2~3格抓取", "dmg": "34 - 50", "directPct": 35, "armorPct": 90, "cd": "冷却1轮",
        "effects": ["拉拽移位", "点穴封气"], "animMode": "abyss_tentacle_drag", "animColor": "#ff4d6d", "fx": "wx_fx_whip_arc",
        "desc": "赤红倒刺长舌破空卷住后排咽喉，一把拽至身前封脉暴打！"
    },
    "three_tile_claw_snatch": {
        "name": "丈臂隔阵探抓", "ap": 5, "qi": 18, "range": "1~3格长臂", "dmg": "42 - 64", "directPct": 35, "armorPct": 110, "cd": "无冷却",
        "effects": ["拉拽移位", "破绽"], "animMode": "abyss_tentacle_drag", "animColor": "#bc6c25", "fx": "wx_fx_claw_slash",
        "desc": "丈余怪臂越过前排重盾，直接抓扯第三格的弓医与旗手！"
    },
    "boulder_crag_hurl": {
        "name": "拔岳飞岩砸", "ap": 5, "qi": 24, "range": "2~4格投石", "dmg": "55 - 82", "directPct": 40, "armorPct": 160, "cd": "冷却1轮",
        "effects": ["脏腑内伤", "失衡"], "animMode": "boulder_hurl_smash", "animColor": "#e09f3e", "fx": "wx_fx_earth_fissure",
        "desc": "拔起千斤山岩呼啸掷入敌阵，砸凹重铠并震出严重内伤！"
    },
    "cyclops_pillar_crush": {
        "name": "独目石柱崩城", "ap": 6, "qi": 26, "range": "1~2格纵砸", "dmg": "72 - 106", "directPct": 45, "armorPct": 180, "cd": "无冷却",
        "effects": ["失衡", "脏腑内伤"], "animMode": "ape_titan_slam", "animColor": "#d62828", "fx": "wx_fx_earth_fissure",
        "desc": "双手高举断阙石柱直线猛砸两格，石破天惊！"
    },
    "root_line_impale": {
        "name": "九枸地刺穿林", "ap": 6, "qi": 24, "range": "直线3格地刺", "dmg": "58 - 86", "directPct": 40, "armorPct": 145, "cd": "无冷却",
        "effects": ["击退破盾", "失衡"], "animMode": "root_thorn_entangle", "animColor": "#52b788", "fx": "wx_fx_earth_fissure",
        "desc": "巨根钻入地下自直线三格破土穿刺，串击一条线上的武人！"
    },
    "bark_aegis_regrow": {
        "name": "建木盘根铁壁", "ap": 4, "qi": 20, "range": "自身生盾", "dmg": "再生古木盾", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["铁壁护盾", "活血回春"], "animMode": "shell_thorns_quake", "animColor": "#74c69d", "fx": "wx_fx_golden_bell",
        "desc": "盘结千年古藤重塑木盾，近远双防 +20 并恢复 30 点气血（唯巨斧易劈碎）。"
    },
    "solar_peach_branch_slam": {
        "name": "邓林大日焚杖", "ap": 6, "qi": 26, "range": "扇形2格横扫", "dmg": "64 - 94", "directPct": 38, "armorPct": 165, "cd": "无冷却",
        "effects": ["蚀甲焚气", "失衡"], "animMode": "ape_titan_slam", "animColor": "#ff7b00", "fx": "wx_fx_earth_fissure",
        "desc": "挥动燃烧烈日余火的桃木巨干横扫，灼熔重甲蒸干真元！"
    },
    "sapling_root_lash": {
        "name": "盘根缠踝抽", "ap": 4, "qi": 12, "range": "1格近战", "dmg": "28 - 42", "directPct": 30, "armorPct": 100, "cd": "无冷却",
        "effects": ["蛛网缠足"], "animMode": "root_thorn_entangle", "animColor": "#80ed99", "fx": "wx_fx_whip_arc",
        "desc": "坚韧树须缠锁小腿，令侠客无法移步支援。"
    },

    # --- Bull / Boar / Tortoise / Horned Charge (`horn_gore_charge`, `thunder_hoof_stomp`, `shell_thorns_quake`) ---
    "gallop_hoof_lance": {
        "name": "虎斑奔蹄踏", "ap": 5, "qi": 18, "range": "2格冲刺", "dmg": "42 - 60", "directPct": 35, "armorPct": 125, "cd": "无冷却",
        "effects": ["失衡"], "animMode": "horn_gore_charge", "animColor": "#ff9f1c", "fx": "wx_fx_earth_fissure",
        "desc": "借奔袭之势双蹄猛踏胸膛，距离越远冲击力越强。"
    },
    "melody_pack_chant": {
        "name": "鹿蜀清谣振群", "ap": 4, "qi": 18, "range": "周身3格友妖", "dmg": "群妖加速", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["群妖振奋"], "animMode": "sonic_dread_roar", "animColor": "#ffd166", "fx": "wx_fx_sonic_ring",
        "desc": "长嘶如古谣清歌，鼓舞周遭山海群妖武艺 +8、身法 +15。"
    },
    "quill_volley_shot": {
        "name": "黑笄暴雨攒刺", "ap": 5, "qi": 20, "range": "2~4格远程", "dmg": "38 - 56", "directPct": 42, "armorPct": 115, "cd": "冷却1轮",
        "effects": ["割裂流血"], "animMode": "venom_needle_barrage", "animColor": "#e5e5e5", "fx": "wx_fx_gold_needle",
        "desc": "抖擞脊背激射数十根黑端白骨豪猪长刺，覆盖攒射敌阵！"
    },
    "tusk_bristle_ram": {
        "name": "巨牙裂阵拱", "ap": 5, "qi": 18, "range": "1~2格冲拱", "dmg": "48 - 70", "directPct": 35, "armorPct": 145, "cd": "无冷却",
        "effects": ["击退破盾", "割裂流血"], "animMode": "horn_gore_charge", "animColor": "#e07a5f", "fx": "wx_fx_earth_fissure",
        "desc": "低首亮出弯刀獠牙蛮横猛拱，顶破盾墙撕裂大腿。"
    },
    "horn_venom_gore": {
        "name": "赤鳞毒角顶", "ap": 4, "qi": 15, "range": "1格近战", "dmg": "40 - 58", "directPct": 45, "armorPct": 120, "cd": "无冷却",
        "effects": ["暗器剧毒"], "animMode": "horn_gore_charge", "animColor": "#d90429", "fx": "wx_fx_poison_skull",
        "desc": "锋利独角直贯护心镜并注入诸次水毒。"
    },
    "acid_scale_splash": {
        "name": "蚀甲毒浆溅", "ap": 4, "qi": 18, "range": "周身1格喷溅", "dmg": "26 - 38", "directPct": 30, "armorPct": 175, "cd": "冷却2轮",
        "effects": ["蚀甲焚气", "暗器剧毒"], "animMode": "shell_thorns_quake", "animColor": "#8ac926", "fx": "wx_fx_poison_skull",
        "desc": "抖落周身腥臭腐蚀毒浆，灼伤贴身围攻者的护甲与皮肉。"
    },
    "iron_ram_headbutt": {
        "name": "铁角崩颅撞", "ap": 5, "qi": 20, "range": "1~2格助跑撞", "dmg": "46 - 68", "directPct": 38, "armorPct": 150, "cd": "冷却1轮",
        "effects": ["失衡", "击退破盾"], "animMode": "horn_gore_charge", "animColor": "#adb5bd", "fx": "wx_fx_earth_fissure",
        "desc": "盘角重羊低头猛冲，一头撞得重甲刀盾手头晕目眩连退一格！"
    },
    "flood_bull_trample": {
        "name": "浊水千钧践踏", "ap": 6, "qi": 24, "range": "1格重踏+余波", "dmg": "62 - 90", "directPct": 36, "armorPct": 155, "cd": "无冷却",
        "effects": ["失衡", "散功虚弱"], "animMode": "thunder_hoof_stomp", "animColor": "#4895ef", "fx": "wx_fx_earth_fissure",
        "desc": "重逾千钧的牛蹄轰然踏碎青石，泥浪激荡震散敌军真气。"
    },
    "pearl_cannon_spit": {
        "name": "水灵宝珠轰顶", "ap": 5, "qi": 20, "range": "2~4格弹射", "dmg": "48 - 68", "directPct": 45, "armorPct": 140, "cd": "冷却1轮",
        "effects": ["失衡", "脏腑内伤"], "animMode": "dragon_breath", "animColor": "#90e0ef", "fx": "wx_fx_sonic_ring",
        "desc": "腹鼓内劲吐出坚逾精钢的水灵内珠，如流星铁弹直轰面门！"
    },
    "iron_beak_clamp": {
        "name": "玄鳖断骨死咬", "ap": 4, "qi": 15, "range": "1格死锁", "dmg": "46 - 68", "directPct": 38, "armorPct": 140, "cd": "无冷却",
        "effects": ["蛛网缠足", "破绽"], "animMode": "shell_thorns_quake", "animColor": "#4ea8de", "fx": "wx_fx_claw_slash",
        "desc": "铡刀般的铁喙咬穿护胫死死不松，令目标寸步难行。"
    },
    "antler_toss_gore": {
        "name": "龙角挑云掀", "ap": 5, "qi": 18, "range": "1格挑飞", "dmg": "50 - 72", "directPct": 35, "armorPct": 135, "cd": "无冷却",
        "effects": ["击退破盾", "破绽"], "animMode": "horn_gore_charge", "animColor": "#4cc9f0", "fx": "wx_fx_ice_spikes",
        "desc": "分叉巨角自下而上猛挑，掀翻盾牌破开空门。"
    },
    "four_horn_cataclysm": {
        "name": "四角铁蓑破城冲", "ap": 6, "qi": 26, "range": "1~2格狂冲", "dmg": "70 - 102", "directPct": 42, "armorPct": 175, "cd": "冷却1轮",
        "effects": ["脏腑内伤", "击退破盾"], "animMode": "horn_gore_charge", "animColor": "#f8961e", "fx": "wx_fx_earth_fissure",
        "desc": "四根利角并齐如攻城重锤碾过阵线，触者骨断筋折！"
    },
    "thunder_horn_jolt": {
        "name": "紫电奔雷角", "ap": 5, "qi": 20, "range": "1~2格雷冲", "dmg": "52 - 76", "directPct": 42, "armorPct": 135, "cd": "无冷却",
        "effects": ["点穴封气", "失衡"], "animMode": "thunder_hoof_stomp", "animColor": "#9b5de5", "fx": "wx_fx_thunder_bolt",
        "desc": "牛角引落紫电雷弧贯入敌躯，电麻经络封锁回气！"
    },
    "earth_churn_tremor": {
        "name": "铁距翻山裂地", "ap": 5, "qi": 22, "range": "前方扇形3格", "dmg": "38 - 56", "directPct": 30, "armorPct": 125, "cd": "冷却1轮",
        "effects": ["失衡", "破绽"], "animMode": "shell_thorns_quake", "animColor": "#dda15e", "fx": "wx_fx_earth_fissure",
        "desc": "双距狂刨大地掀翻石板，令前方整片敌军东倒西歪。"
    },
    "two_way_tusk_snap": {
        "name": "并封首尾回旋拱", "ap": 5, "qi": 20, "range": "前后双格同击", "dmg": "46 - 68", "directPct": 35, "armorPct": 130, "cd": "无冷却",
        "effects": ["割裂流血", "失衡"], "animMode": "horn_gore_charge", "animColor": "#9d4edd", "fx": "wx_fx_claw_slash",
        "desc": "前后两颗凶猪头同时发难，夹击它的前后武人双双挂彩！"
    },

    # --- Avian / Winged / Insect (`sky_talon_dive`, `sun_crow_nova`, `venom_needle_barrage`) ---
    "three_claw_face_rake": {
        "name": "三足攫面抓", "ap": 4, "qi": 14, "range": "1格抓头", "dmg": "36 - 54", "directPct": 36, "armorPct": 100, "cd": "无冷却",
        "effects": ["割裂流血"], "animMode": "sky_talon_dive", "animColor": "#a8dadc", "fx": "wx_fx_claw_slash",
        "desc": "三只铁爪凌空扑抓面门眼眶，专克无盔轻装。"
    },
    "marsh_shriek_swoop": {
        "name": "白首掠泽袭", "ap": 5, "qi": 18, "range": "2格飞掠", "dmg": "40 - 58", "directPct": 32, "armorPct": 100, "cd": "冷却1轮",
        "effects": ["失衡"], "animMode": "sky_talon_dive", "animColor": "#90e0ef", "fx": "wx_fx_sonic_ring",
        "desc": "贴水面滑翔两格奇袭侧翼。"
    },
    "cackle_hex_laugh": {
        "name": "鵸鵌六尾诡笑", "ap": 4, "qi": 18, "range": "2~3格咒音", "dmg": "乱神减防", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["战意动摇", "破绽"], "animMode": "fox_charm_miasma", "animColor": "#b5179e", "fx": "wx_fx_sonic_ring",
        "desc": "三首齐发刺耳狂笑乱人心智，令目标双防与定力骤降。"
    },
    "triple_crow_gouge": {
        "name": "三鸦夺魄啄", "ap": 4, "qi": 15, "range": "1格近战", "dmg": "42 - 62", "directPct": 40, "armorPct": 95, "cd": "无冷却",
        "effects": ["割裂流血"], "animMode": "sky_talon_dive", "animColor": "#9d4edd", "fx": "wx_fx_claw_slash",
        "desc": "专挑动摇失神之敌三喙齐下穿刺要害。"
    },
    "sky_talon_helm_rip": {
        "name": "九霄掀胄爪", "ap": 5, "qi": 20, "range": "1~2格俯冲", "dmg": "48 - 70", "directPct": 35, "armorPct": 165, "cd": "无冷却",
        "effects": ["破绽"], "animMode": "sky_talon_dive", "animColor": "#f94144", "fx": "wx_fx_claw_slash",
        "desc": "自高空俯冲直抓头顶兜鍪，铁爪撕裂头甲护具！"
    },
    "wing_gust_backleap": {
        "name": "振翮掠风退", "ap": 3, "qi": 16, "range": "脱身跃退2格", "dmg": "无视截击脱身", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["轻灵脱围"], "animMode": "dream_shadow_ambush", "animColor": "#90be6d", "fx": "wx_fx_sonic_ring",
        "desc": "双翼猛扇罡风逼退近敌，轻巧抽身飞退两格重觅猎机。"
    },
    "twin_wing_cross_slash": {
        "name": "比翼双闪剪", "ap": 4, "qi": 15, "range": "1格双连掠", "dmg": "40 - 60", "directPct": 35, "armorPct": 100, "cd": "无冷却",
        "effects": ["割裂流血"], "animMode": "sky_talon_dive", "animColor": "#06d6a0", "fx": "wx_fx_claw_slash",
        "desc": "青赤双羽如剪刀交错掠过颈侧。"
    },
    "flood_omen_squall": {
        "name": "崇吾霖雨障", "ap": 4, "qi": 18, "range": "周身2格水雾", "dmg": "湿重压气", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["散功虚弱"], "animMode": "fox_charm_miasma", "animColor": "#118ab2", "fx": "wx_fx_ice_spikes",
        "desc": "唤来阴湿暴雨迷障，压低周围敌军远程射程与回气。"
    },
    "jade_lightning_peck": {
        "name": "三危贯脉疾啄", "ap": 4, "qi": 16, "range": "1~2格电掠", "dmg": "44 - 66", "directPct": 48, "armorPct": 95, "cd": "无冷却",
        "effects": ["点穴封气"], "animMode": "sky_talon_dive", "animColor": "#00f5d4", "fx": "wx_fx_lotus_seal",
        "desc": "快逾青电一啄正中肩井大穴，真气立时淤塞！"
    },
    "gliding_throat_nip": {
        "name": "滑翼掠影啮", "ap": 4, "qi": 12, "range": "1~2格滑袭", "dmg": "30 - 45", "directPct": 38, "armorPct": 80, "cd": "无冷却",
        "effects": ["割裂流血"], "animMode": "dream_shadow_ambush", "animColor": "#a2d2ff", "fx": "wx_fx_claw_slash",
        "desc": "借皮翼悄无声息滑过头顶啃咬后颈。"
    },
    "membrane_dart_evade": {
        "name": "乘风折跃闪", "ap": 3, "qi": 14, "range": "无视ZoC滑步", "dmg": "闪避+15", "directPct": 0, "armorPct": 0, "cd": "冷却1轮",
        "effects": ["轻灵脱围"], "animMode": "dream_shadow_ambush", "animColor": "#bde0fe", "fx": "wx_fx_bagua",
        "desc": "展开飞膜贴地滑入侧方空位并提升本轮闪避。"
    },
    "gale_fin_slash": {
        "name": "夜海苍翼斩", "ap": 4, "qi": 16, "range": "1~2格掠斩", "dmg": "45 - 66", "directPct": 35, "armorPct": 115, "cd": "无冷却",
        "effects": ["割裂流血", "失衡"], "animMode": "sky_talon_dive", "animColor": "#4cc9f0", "fx": "wx_fx_sword_phantom",
        "desc": "锋利如刀的苍纹鱼翼破风横削。"
    },
    "tidal_wind_blast": {
        "name": "西海狂飙浪", "ap": 5, "qi": 22, "range": "前方3格风浪", "dmg": "36 - 52", "directPct": 30, "armorPct": 110, "cd": "冷却2轮",
        "effects": ["击退破盾", "失衡"], "animMode": "dragon_breath", "animColor": "#00b4d8", "fx": "wx_fx_sonic_ring",
        "desc": "振翅卷起西海咸湿狂风冲击敌阵。"
    },
    "four_wing_panic_dive": {
        "name": "四翼惊邑扑", "ap": 5, "qi": 18, "range": "1~2格飞扑", "dmg": "48 - 68", "directPct": 36, "armorPct": 115, "cd": "无冷却",
        "effects": ["战意动摇", "破绽"], "animMode": "sky_talon_dive", "animColor": "#ff5d8f", "fx": "wx_fx_claw_slash",
        "desc": "四翼齐振怪啸扑顶，未战先夺人胆气。"
    },
    "sky_steed_vault_kick": {
        "name": "天马踏空蹶", "ap": 5, "qi": 22, "range": "2~3格飞跃", "dmg": "48 - 70", "directPct": 38, "armorPct": 125, "cd": "冷却1轮",
        "effects": ["失衡"], "animMode": "sky_talon_dive", "animColor": "#e0fbfc", "fx": "wx_fx_sonic_ring",
        "desc": "腾空跃过前排铁盾，双蹄自半空重踏后阵！"
    },
    "fan_tail_acrobat_slash": {
        "name": "扇尾旋身抓", "ap": 4, "qi": 12, "range": "1格轻捷", "dmg": "32 - 48", "directPct": 35, "armorPct": 90, "cd": "无冷却",
        "effects": ["破绽"], "animMode": "dream_shadow_ambush", "animColor": "#95d5b2", "fx": "wx_fx_claw_slash",
        "desc": "以巨尾借力半空翻身抓挠手腕。"
    },
    "scorch_wing_ember": {
        "name": "姑逢旱火扇", "ap": 5, "qi": 20, "range": "前方2格火风", "dmg": "38 - 56", "directPct": 32, "armorPct": 160, "cd": "冷却1轮",
        "effects": ["蚀甲焚气"], "animMode": "sun_crow_nova", "animColor": "#ff6b35", "fx": "wx_fx_dragon_head",
        "desc": "双翼扇出滚烫旱火火星，烧焦甲叶蒸干内息。"
    },
    "fin_wing_bleed_slash": {
        "name": "棘翼擦身割", "ap": 4, "qi": 14, "range": "1格游掠", "dmg": "36 - 54", "directPct": 35, "armorPct": 95, "cd": "无冷却",
        "effects": ["割裂流血", "战意动摇"], "animMode": "sky_talon_dive", "animColor": "#ef476f", "fx": "wx_fx_claw_slash",
        "desc": "背上带刺鱼翼高速掠过皮肉拉出长串血珠。"
    },
    "harpy_hand_disarm": {
        "name": "鸱翼人手夺白刃", "ap": 5, "qi": 22, "range": "1格擒拿", "dmg": "38 - 54", "directPct": 35, "armorPct": 100, "cd": "冷却2轮",
        "effects": ["缴械夺兵", "破绽"], "animMode": "sky_talon_dive", "animColor": "#ffd166", "fx": "wx_fx_sword_phantom",
        "desc": "俯冲而下以一对苍劲人手死扣敌手腕脉，硬生生夺落其主手兵刃！"
    },
    "harpoon_dive_throw": {
        "name": "大荒倒刺骨叉", "ap": 4, "qi": 16, "range": "2~4格投掷", "dmg": "42 - 62", "directPct": 42, "armorPct": 115, "cd": "无冷却",
        "effects": ["割裂流血"], "animMode": "venom_needle_barrage", "animColor": "#90e0ef", "fx": "wx_fx_gold_needle",
        "desc": "振翼悬停猛掷鲸骨倒刺渔叉，洞穿皮甲血流不止。"
    },
    "feather_spear_plunge": {
        "name": "黑羽贯云矛", "ap": 5, "qi": 20, "range": "1~2格俯刺", "dmg": "48 - 70", "directPct": 46, "armorPct": 115, "cd": "无冷却",
        "effects": ["破绽"], "animMode": "sky_talon_dive", "animColor": "#48bfe3", "fx": "wx_fx_sword_phantom",
        "desc": "收拢铁羽自半空携全身重量一矛贯刺。"
    },
    "silk_web_snare": {
        "name": "天韧鬼蛛网", "ap": 4, "qi": 18, "range": "2~3格吐网", "dmg": "定身缠足", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["蛛网缠足", "破绽"], "animMode": "venom_needle_barrage", "animColor": "#f8f9fa", "fx": "wx_fx_lotus_seal",
        "desc": "腹囊喷射粘韧白丝大网罩定目标，使其无法移动且近远防御腰斩！"
    },
    "neuro_venom_bite": {
        "name": "鬼面蚀髓牙", "ap": 4, "qi": 12, "range": "1格毒噬", "dmg": "28 - 44", "directPct": 45, "armorPct": 85, "cd": "无冷却",
        "effects": ["暗器剧毒"], "animMode": "feral_pounce", "animColor": "#80ffdb", "fx": "wx_fx_poison_skull",
        "desc": "螯牙刺入被困猎物脉门，奇毒攻心。"
    },
    "plague_mandible_chew": {
        "name": "枯水疫颚啃", "ap": 4, "qi": 14, "range": "1格近战", "dmg": "34 - 50", "directPct": 35, "armorPct": 140, "cd": "无冷却",
        "effects": ["暗器剧毒", "蚀甲焚气"], "animMode": "feral_pounce", "animColor": "#aacc00", "fx": "wx_fx_poison_skull",
        "desc": "锯齿巨颚分泌大疫毒涎啃穿铁叶。"
    },
    "swarm_lord_command": {
        "name": "平逢百螫号令", "ap": 4, "qi": 20, "range": "全场虫族", "dmg": "群虫狂暴", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["群妖振奋"], "animMode": "sonic_dread_roar", "animColor": "#ffb703", "fx": "wx_fx_sonic_ring",
        "desc": "双首共振嗡鸣催动全场毒虫奇蛛狂暴突进！"
    },
    "stinger_armor_pierce": {
        "name": "烂石透铁尾针", "ap": 4, "qi": 16, "range": "1格贯甲刺", "dmg": "42 - 64", "directPct": 58, "armorPct": 110, "cd": "无冷却",
        "effects": ["暗器剧毒", "脏腑内伤"], "animMode": "venom_needle_barrage", "animColor": "#ffd60a", "fx": "wx_fx_gold_needle",
        "desc": "乌金毒针如破甲锥直透重铠，石烂铁穿！"
    },
    "brood_hatch_pulse": {
        "name": "胎动破茧孵蛛", "ap": 0, "qi": 0, "range": "回合初自动", "dmg": "召唤鬼面赤蛛", "directPct": 0, "armorPct": 0, "cd": "每轮1次",
        "effects": ["孵化群妖"], "animMode": "shell_thorns_quake", "animColor": "#c77dff", "fx": "wx_fx_poison_skull",
        "desc": "紫黑卵囊剧烈搏动裂开，钻出一只满状态鬼面赤蛛投入厮杀！"
    },

    # --- Spirit / Hex / Illusion / Undead Relic (`fox_charm_miasma`, `dream_shadow_ambush`, `corpse_chain_cleave`, `headless_waraxe`) ---
    "nightmare_slumber_hex": {
        "name": "颠倒迷魂梦魇", "ap": 4, "qi": 18, "range": "2~4格入梦", "dmg": "沉眠封动", "directPct": 0, "armorPct": 0, "cd": "冷却1轮",
        "effects": ["梦魇沉睡"], "animMode": "fox_charm_miasma", "animColor": "#9d4edd", "fx": "wx_fx_bagua",
        "desc": "吐出黑紫诡雾颠倒东西善恶，令定力检定未过者当场坠入沉眠无法行动！"
    },
    "shadow_mind_leech": {
        "name": "幽谷噬梦爪", "ap": 4, "qi": 15, "range": "1~2格直伤气血", "dmg": "32 - 48 (无视护甲)", "directPct": 100, "armorPct": 0, "cd": "无冷却",
        "effects": ["散功虚弱"], "animMode": "dream_shadow_ambush", "animColor": "#c77dff", "fx": "wx_fx_claw_slash",
        "desc": "化黑影掠过沉眠或动摇目标心口，100% 无视铁甲直接切割心神气血！"
    },
    "fox_bewitch_charm": {
        "name": "青丘九尾魅心咒", "ap": 5, "qi": 25, "range": "2~5格摄魂", "dmg": "魅惑倒戈", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["魅惑倒戈"], "animMode": "fox_charm_miasma", "animColor": "#ff70a6", "fx": "wx_fx_lotus_seal",
        "desc": "九尾摇曳散出桃花异香，令定力失守的猛士神魂颠倒挥刀砍向同袍！"
    },
    "soul_link_hex": {
        "name": "同命连心妖印", "ap": 4, "qi": 20, "range": "2~5格咒印", "dmg": "反伤嫁祸", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["同命反伤"], "animMode": "fox_charm_miasma", "animColor": "#ff4d6d", "fx": "wx_fx_blood_orb",
        "desc": "将妖魅性命与一名侠客红线相连，妖魅受创则该侠客同受切肤之痛！"
    },
    "hundred_voice_babel": {
        "name": "一目夺百声", "ap": 4, "qi": 16, "range": "周身3格幻音", "dmg": "乱耳失准", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["破绽", "散功虚弱"], "animMode": "sonic_dread_roar", "animColor": "#ffd166", "fx": "wx_fx_sonic_ring",
        "desc": "独目闪烁拟出金鼓惨呼百种怪声，令敌军耳目错乱。"
    },
    "three_tail_whip_claw": {
        "name": "三尾幻影抽", "ap": 4, "qi": 14, "range": "1格快击", "dmg": "34 - 50", "directPct": 35, "armorPct": 90, "cd": "无冷却",
        "effects": ["失衡"], "animMode": "dream_shadow_ambush", "animColor": "#f4a261", "fx": "wx_fx_whip_arc",
        "desc": "三条豹纹长尾虚晃一招，利爪乘隙挠伤手腕。"
    },
    "feigned_sleep_ambush": {
        "name": "眠鳞暴起毒尾钩", "ap": 4, "qi": 15, "range": "1格伏击", "dmg": "44 - 64", "directPct": 45, "armorPct": 110, "cd": "无冷却",
        "effects": ["点穴封气", "暗器剧毒"], "animMode": "coiled_crush", "animColor": "#80ed99", "fx": "wx_fx_poison_skull",
        "desc": "佯装熟睡诱敌近身，蛇尾毒钩骤然弹刺小腹气海！"
    },
    "spirit_water_mend": {
        "name": "英水清音润脉", "ap": 5, "qi": 22, "range": "周身2格友妖", "dmg": "群妖回血+25", "directPct": 0, "armorPct": 0, "cd": "冷却1轮",
        "effects": ["活血回春"], "animMode": "fox_charm_miasma", "animColor": "#4cc9f0", "fx": "wx_fx_lotus_seal",
        "desc": "歌如鸳鸯清鸣，引灵泉水雾愈合周围受伤山海异兽创口。"
    },
    "abyss_glare_flash": {
        "name": "清冷渊神光曜目", "ap": 4, "qi": 18, "range": "周身2格强光", "dmg": "眩光失准", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["烟幕蔽目", "散功虚弱"], "animMode": "sun_crow_nova", "animColor": "#72efdd", "fx": "wx_fx_ice_spikes",
        "desc": "迸发清冷寒渊刺目神光，令周围武人双目流泪命中暴跌。"
    },
    "frost_halberd_drain": {
        "name": "寒渊噬气冰戟", "ap": 5, "qi": 20, "range": "1~2格寒戟", "dmg": "48 - 70", "directPct": 40, "armorPct": 125, "cd": "无冷却",
        "effects": ["点穴封气", "散功虚弱"], "animMode": "corpse_chain_cleave", "animColor": "#48cae4", "fx": "wx_fx_ice_spikes",
        "desc": "冰晶古戟隔格斜劈，抽干目标 15 点温热内息。"
    },
    "hollow_chest_halberd": {
        "name": "穿胸怨煞戈", "ap": 5, "qi": 0, "range": "1~2格古戈", "dmg": "44 - 66", "directPct": 35, "armorPct": 135, "cd": "无冷却",
        "effects": ["割裂流血"], "animMode": "headless_waraxe", "animColor": "#8ecae6", "fx": "wx_fx_sword_phantom",
        "desc": "不死尸卒毫无痛觉挥动青铜古戈死战。"
    },
    "corpse_shield_shove": {
        "name": "古铜尸盾壁", "ap": 4, "qi": 0, "range": "自身架盾", "dmg": "双防+18", "directPct": 0, "armorPct": 0, "cd": "冷却1轮",
        "effects": ["铁壁护盾"], "animMode": "shell_thorns_quake", "animColor": "#adb5bd", "fx": "wx_fx_golden_bell",
        "desc": "架起锈蚀青铜盾牌结成死寂尸墙。"
    },
    "tamed_lynx_combo": {
        "name": "执虎双煞合击", "ap": 5, "qi": 20, "range": "1格人兽双段", "dmg": "54 - 80", "directPct": 38, "armorPct": 130, "cd": "无冷却",
        "effects": ["割裂流血", "破绽"], "animMode": "multi_head_frenzy", "animColor": "#f77f00", "fx": "wx_fx_claw_slash",
        "desc": "聂耳巨汉重拳砸盾的同时，肩头文虎凌空咬咽喉！"
    },
    "twin_viper_miasma": {
        "name": "黑齿青赤双蛇瘴", "ap": 5, "qi": 24, "range": "2~4格区域毒雾", "dmg": "区域奇毒蚀气", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["暗器剧毒", "烟幕蔽目"], "animMode": "fox_charm_miasma", "animColor": "#38b000", "fx": "wx_fx_poison_skull",
        "desc": "催动颈间青赤双蛇喷出浓绿剧毒瘴云笼罩敌阵。"
    },
    "hound_berserk_cleave": {
        "name": "盘瓠狂血连斩", "ap": 4, "qi": 15, "range": "1格狂劈", "dmg": "46 - 68", "directPct": 35, "armorPct": 130, "cd": "无冷却",
        "effects": ["割裂流血"], "animMode": "headless_waraxe", "animColor": "#e63946", "fx": "wx_fx_claw_slash",
        "desc": "犬首战鬼咆哮挥动骨刃连砍带咬。"
    },
    "bronze_horn_linebreaker": {
        "name": "九黎铜头撞阵", "ap": 5, "qi": 20, "range": "1~2格破盾撞", "dmg": "56 - 82", "directPct": 42, "armorPct": 170, "cd": "冷却1轮",
        "effects": ["击退破盾", "失衡"], "animMode": "horn_gore_charge", "animColor": "#ca6702", "fx": "wx_fx_earth_fissure",
        "desc": "以铜头铁额硬生生撞碎盾墙防线！"
    },
    "flesh_tendril_engulf": {
        "name": "太岁血肉吞裹", "ap": 5, "qi": 18, "range": "1~2格触须", "dmg": "48 - 70", "directPct": 50, "armorPct": 110, "cd": "无冷却",
        "effects": ["散功虚弱", "噬血回元"], "animMode": "devour_blood_siphon", "animColor": "#d90429", "fx": "wx_fx_blood_orb",
        "desc": "蠕动血肉触须包裹敌身，强行汲取气血与内息滋养肉胎。"
    },

    # --- APEX BOSS SIGNATURE ULTIMATE MOVES (Used by the 64 Shan Hai Apex Bosses!) ---
    "boss_ult_ape_quake": {
        "name": "【凶威】白首碎岳崩天捶", "ap": 6, "qi": 28, "range": "周身1格震地", "dmg": "85 - 125", "directPct": 45, "armorPct": 175, "cd": "冷却2轮",
        "effects": ["击退破盾", "脏腑内伤", "失衡"], "animMode": "ape_titan_slam", "animColor": "#ff3b30", "fx": "wx_fx_earth_fissure",
        "desc": "大妖跃起丈余双拳轰击大地，环形气浪震飞周身一切近战武人并重创五脏！"
    },
    "boss_ult_drought_breath": {
        "name": "【凶威】赤旱焚城毒火息", "ap": 6, "qi": 28, "range": "前方扇形3格", "dmg": "72 - 105", "directPct": 42, "armorPct": 200, "cd": "冷却2轮",
        "effects": ["蚀甲焚气", "暗器剧毒"], "animMode": "dragon_breath", "animColor": "#ff5400", "fx": "wx_fx_dragon_head",
        "desc": "喷吐赤地千里的大旱紫火毒瘴，瞬间熔毁扇形三格重甲并蒸干内息！"
    },
    "boss_ult_gale_slaughter": {
        "name": "【凶威】裂风噬善连环扑", "ap": 5, "qi": 22, "range": "1~2格疾电三扑", "dmg": "78 - 112", "directPct": 48, "armorPct": 140, "cd": "冷却1轮",
        "effects": ["割裂流血", "破绽"], "animMode": "multi_head_frenzy", "animColor": "#00f5d4", "fx": "wx_fx_claw_slash",
        "desc": "穷奇乘恶风瞬息三掠，专挑定力高昂之正道君子疯狂撕喉！"
    },
    "boss_ult_glutton_devour": {
        "name": "【凶威】饕餮吞天噬元噬", "ap": 6, "qi": 26, "range": "1格深渊吞噬", "dmg": "90 - 130", "directPct": 52, "armorPct": 165, "cd": "冷却1轮",
        "effects": ["噬血回元", "散功虚弱"], "animMode": "devour_blood_siphon", "animColor": "#ff2a55", "fx": "wx_fx_blood_orb",
        "desc": "腹面巨口黑洞般吞噬猎物精血真元，单击最高吸回 35 点气血！"
    },
    "boss_ult_nine_tail_domain": {
        "name": "【凶威】青丘万狐迷仙阵", "ap": 6, "qi": 30, "range": "周身3格幻域", "dmg": "群体惑心失衡", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["魅惑倒戈", "失衡", "散功虚弱"], "animMode": "fox_charm_miasma", "animColor": "#ff66b3", "fx": "wx_fx_lotus_seal",
        "desc": "九尾齐张漫天红雾，摄夺心魄令定力不坚者倒戈相向！"
    },
    "boss_ult_waraxe_whirl": {
        "name": "【凶威】刑天舞干戚戮神斩", "ap": 6, "qi": 26, "range": "周身1格旋斩", "dmg": "92 - 135", "directPct": 48, "armorPct": 185, "cd": "冷却1轮",
        "effects": ["割裂流血", "破绽", "击退破盾"], "animMode": "headless_waraxe", "animColor": "#ff4500", "fx": "wx_fx_sword_phantom",
        "desc": "无首战魂以乳为目、以脐为口，青铜巨戚挟千载不灭战意横扫六合！"
    },
    "boss_ult_sun_crow_flare": {
        "name": "【凶威】十日扶桑焚天耀", "ap": 6, "qi": 28, "range": "周身2~3格阳炎", "dmg": "70 - 98", "directPct": 45, "armorPct": 195, "cd": "冷却2轮",
        "effects": ["蚀甲焚气", "烟幕蔽目"], "animMode": "sun_crow_nova", "animColor": "#ffbe0b", "fx": "wx_fx_dragon_head",
        "desc": "金乌化作大日火轮凌空爆耀，周遭铁甲通红欲熔、真气立涸！"
    },
    "boss_ult_thunder_drum": {
        "name": "【凶威】流波五百里雷音震", "ap": 6, "qi": 28, "range": "周身3格天雷", "dmg": "74 - 106", "directPct": 46, "armorPct": 180, "cd": "冷却2轮",
        "effects": ["失衡", "点穴封气", "蚀甲焚气"], "animMode": "thunder_hoof_stomp", "animColor": "#8338ec", "fx": "wx_fx_thunder_bolt",
        "desc": "夔牛独足踏海引落九天紫电雷暴，五百里雷音震碎百炼重铠！"
    },
    "boss_ult_abyss_frost_tide": {
        "name": "【凶威】天倾寒渊万古潮", "ap": 6, "qi": 28, "range": "前方扇形3格寒潮", "dmg": "76 - 108", "directPct": 46, "armorPct": 150, "cd": "冷却2轮",
        "effects": ["点穴封气", "散功虚弱", "失衡"], "animMode": "dragon_breath", "animColor": "#00bbf9", "fx": "wx_fx_ice_spikes",
        "desc": "掀起不周山倾折黑水寒潮，冻结经脉丹田令武人寸劲难发！"
    },
    "boss_ult_shell_fortress": {
        "name": "【凶威】太古玄甲反震罡", "ap": 5, "qi": 22, "range": "自身不坏金身", "dmg": "非锤减伤45%+反震", "directPct": 0, "armorPct": 0, "cd": "冷却2轮",
        "effects": ["铁壁护盾", "近战反刺"], "animMode": "shell_thorns_quake", "animColor": "#4cc9f0", "fx": "wx_fx_golden_bell",
        "desc": "缩首盘甲稳如泰山，刀剑箭矢尽数弹开并反震来犯者内息！"
    },
    "boss_ult_venom_stinger": {
        "name": "【凶威】昆仑烂石万蛊针", "ap": 5, "qi": 22, "range": "1~3格贯甲毒刺", "dmg": "72 - 104", "directPct": 60, "armorPct": 130, "cd": "冷却1轮",
        "effects": ["暗器剧毒", "脏腑内伤", "点穴封气"], "animMode": "venom_needle_barrage", "animColor": "#80ffdb", "fx": "wx_fx_poison_skull",
        "desc": "钦原蛊皇尾针化作墨绿流光贯透重铠，一刺双绝毒烂石枯木！"
    },
    "boss_ult_shackled_wrath": {
        "name": "【凶威】疏属断枷镇狱砸", "ap": 6, "qi": 26, "range": "1~2格铁索横扫", "dmg": "82 - 118", "directPct": 44, "armorPct": 175, "cd": "冷却1轮",
        "effects": ["点穴封气", "失衡", "脏腑内伤"], "animMode": "corpse_chain_cleave", "animColor": "#9d4edd", "fx": "wx_fx_whip_arc",
        "desc": "古神怨尸抡起缚神玄铁断链横砸两格，封穴碎骨！"
    },
}


# ==============================================================================
# 4. ENRICHMENT FOR ALL 64 APEX BOSSES (`wx_shanhai.nut` -> Full Bestiary Entry)
# ==============================================================================
BASE_ARCHETYPE_STATS = {
    "Unhold":         (480, 140, 220, 9, 220, 25, 76, 0,  10, 8,  85,  100, 750, "巨猿山岳躯"),
    "UnholdFrost":    (520, 160, 260, 9, 240, 25, 78, 0,  12, 10, 88,  110, 820, "寒渊巨兽躯"),
    "UnholdBog":      (500, 130, 210, 9, 230, 25, 76, 0,  11, 10, 86,  105, 780, "毒泽巨猿躯"),
    "Lindwurm":       (680, 220, 380, 9, 280, 28, 82, 68, 12, 12, 82,  130, 980, "太古真龙双格躯"),
    "Hyena":          (145, 75,  115, 10,160, 24, 74, 0,  16, 14, 132, 75,  680, "疾风凶兽躯"),
    "Direwolf":       (140, 70,  110, 10,165, 24, 75, 0,  16, 14, 138, 75,  680, "奔星猎兽躯"),
    "Ghoul":          (210, 85,  135, 9, 175, 22, 74, 0,  12, 10, 112, 80,  720, "噬血贪兽躯"),
    "Hexe":           (105, 45,  80,  9, 160, 24, 62, 82, 18, 26, 120, 95,  760, "惑心妖神躯"),
    "Serpent":        (185, 95,  150, 9, 175, 22, 74, 65, 14, 16, 112, 80,  700, "盘蟒奇蛟躯"),
    "Schrat":         (510, 180, 290, 9, 240, 25, 78, 0,  10, 24, 74,  120, 860, "通天神木躯"),
    "SkeletonBoss":   (260, 260, 340, 9, 999, 0,  80, 0,  16, 20, 84,  150, 880, "不灭战神古骸"),
    "SkeletonHeavy":  (210, 220, 290, 9, 999, 0,  78, 0,  14, 18, 80,  150, 820, "太古巨神枯骸"),
    "SkeletonPriest": (135, 140, 190, 9, 999, 0,  66, 80, 14, 24, 92,  140, 780, "妖火祭灵古躯"),
    "Vampire":        (175, 105, 155, 10,185, 26, 78, 72, 20, 22, 136, 95,  800, "掠空妖皇躯"),
    "OrcWarlord":     (320, 260, 360, 9, 240, 24, 80, 0,  12, 10, 96,  115, 900, "霸主魔神重躯"),
    "OrcBerserker":   (235, 110, 165, 10,210, 24, 78, 0,  10, 8,  116, 95,  740, "狂暴凶兽躯"),
    "Spider":         (115, 80,  125, 10,170, 24, 74, 72, 18, 20, 145, 80,  740, "万蛊毒皇躯"),
    "ZombieBoss":     (265, 185, 265, 9, 999, 0,  76, 0,  12, 15, 72,  150, 800, "不腐古尸神躯"),
    "ZombieBetrayer": (250, 215, 295, 9, 999, 0,  76, 0,  12, 15, 70,  150, 820, "缚神铁枷尸躯"),
    "Ghost":          (120, 0,   40,  9, 999, 0,  74, 78, 26, 30, 128, 150, 780, "千载怨魄灵躯"),
    "GoblinWolfrider":(145, 85,  125, 10,175, 24, 75, 74, 18, 18, 142, 78,  720, "疾风走兽躯"),
    "Kraken":         (680, 160, 240, 10,260, 25, 78, 0,  6,  15, 70,  130, 950, "苦泽万触妖躯"),
    "OrcYoung":       (165, 90,  120, 9, 145, 18, 68, 0,  8,  8,  102, 66,  240, "荒原猛兽躯"),
    "OrcWarrior":     (230, 200, 240, 9, 160, 18, 72, 0,  12, 10, 86,  85,  350, "重甲战魔躯"),
    "SkeletonMedium": (150, 95,  135, 9, 999, 0,  66, 0,  10, 20, 78,  99,  240, "不死尸卒躯"),
    "GoblinAmbusher": (125, 50,  75,  9, 125, 18, 62, 72, 14, 18, 122, 60,  230, "飞羽游猎躯"),
    "GoblinSkirmisher":(90, 25,  40,  10,120, 20, 63, 0,  20, 22, 142, 50,  180, "滑翼奇兽躯"),
    "GoblinShaman":   (120, 40,  65,  9, 140, 22, 56, 74, 14, 20, 118, 76,  290, "巫祝控蛇躯"),
    "BarbarianMarauder":(210,85, 130, 9, 145, 18, 73, 0,  12, 14, 112, 74,  310, "荒北驭兽躯"),
    "SpiderEggs":     (90,  0,   35,  0, 50,  0,  0,  0, -15,-10, 20,  99,  80,  "固定虫巢卵躯"),
    "SchratSmall":    (95,  45,  75,  9, 110, 18, 60, 0,  10, 18, 95,  99,  95,  "盘根小木灵躯"),
    "KrakenTentacle": (140, 50,  80,  9, 140, 20, 72, 0,  5,  10, 90,  99,  110, "破泽蛇首触躯"),
}

FOUR_FIENDS = {"qiongqi", "taotie", "hundun", "taowu"}
ANCIENT_GODS = {"xingtian", "zhuyin", "dijiang", "yinglong", "xiangliuwang", "kuafu", "chiyou", "erfu", "nvchou", "fangfeng", "kaiming", "jinwu", "gonggong", "bingyi", "qiangliang", "jumang", "baize", "shebishi", "yingzhao", "luwu"}

BOSS_WORLD_FIG_MAP = {
    "zhuyan": "wx_fig_beast_zhuyan", "wuzhiqi": "wx_fig_beast_zhuyan", "xingxing": "wx_fig_beast_zhuyan", "changyou": "wx_fig_beast_zhuyan",
    "feiyi": "wx_fig_beast_feiyi", "zhuyin": "wx_fig_beast_bingyi", "yinglong": "wx_fig_beast_bingyi", "huashe": "wx_fig_beast_wenyao",
    "qiongqi": "wx_fig_beast_qiongqi", "zouyu": "wx_fig_beast_qiongqi", "luwu": "wx_fig_beast_qiongqi", "kaiming": "wx_fig_beast_qiongqi",
    "mengji": "wx_fig_beast_qiongqi", "zheng": "wx_fig_beast_qiongqi", "jiao": "wx_fig_beast_qiongqi",
    "taotie": "wx_fig_beast_taotie", "paoxiaowang": "wx_fig_beast_taotie", "yayu": "wx_fig_beast_taotie",
    "jiuwei": "wx_fig_beast_yaomei", "wuluo": "wx_fig_beast_yaomei", "nvchou": "wx_fig_beast_yaomei", "chenghuang": "wx_fig_beast_fuzhu",
    "bashe": "wx_fig_beast_bashe", "mingshe": "wx_fig_beast_bashe", "hujiao": "wx_fig_beast_wenyao",
    "jumang": "wx_fig_beast_jianmu",
    "xingtian": "wx_fig_beast_xingtian", "chiyou": "wx_fig_beast_xingtian", "zaochi": "wx_fig_beast_xingtian",
    "qiangliang": "wx_fig_beast_xingtian", "yingzhao": "wx_fig_beast_qiongqi",
    "bifang": "wx_fig_beast_jinwu", "jinwu": "wx_fig_beast_jinwu", "yuanchu": "wx_fig_beast_jinwu",
    "jiufeng": "wx_fig_beast_jinwu", "feilian": "wx_fig_beast_jinwu", "jingwei": "wx_fig_beast_jinwu",
    "gudiaowang": "wx_fig_beast_gudiao",
    "zhujian": "wx_fig_beast_dangkang", "dangkang": "wx_fig_beast_dangkang",
    "xuangui": "wx_fig_beast_xuangui",
    "qinyuan": "wx_fig_beast_qinyuan",
    "tiangouwang": "wx_fig_beast_tiangou", "huodou": "wx_fig_beast_tiangou", "shanhui": "wx_fig_beast_tiangou",
    "hundun": "wx_fig_beast_hundun", "dijiang": "wx_fig_beast_hundun",
    "kui": "wx_fig_beast_kui", "fei": "wx_fig_beast_kui", "siwang": "wx_fig_beast_kui",
    "bo": "wx_fig_beast_kui", "zhuhuai": "wx_fig_beast_kui", "taowu": "wx_fig_beast_qiongqi", "boshi": "wx_fig_beast_fuzhu",
    "fuzhu": "wx_fig_beast_fuzhu", "baize": "wx_fig_beast_fuzhu",
    "xiangliuwang": "wx_fig_beast_xiangliu", "jiuying": "wx_fig_beast_xiangliu", "gonggong": "wx_fig_beast_xiangliu",
    "kuafu": "wx_fig_beast_kuafu", "fangfeng": "wx_fig_beast_kuafu",
    "shebishi": "wx_fig_beast_eshou", "erfu": "wx_fig_beast_xingtian", "bingyi": "wx_fig_beast_bingyi",
}

CHAPTER_TO_BOOK_GROUP = {
    "南山经": "nanshan",
    "西山经": "xishan",
    "北山经": "beishan",
    "东山经": "dongshan",
    "中山经": "zhongshan",
    "神异经": "zhongshan",
    "海内经": "zhongshan",
}


def pick_boss_skills(key: str, etype: str, mech_raw: str) -> list[str]:
    """Select 3 distinct, lore-fitting skills (1 Apex Ultimate + 2 Tactical Moves) for each of the 64 Bosses."""
    if key in ("zhuyan", "wuzhiqi", "xingxing", "changyou"):
        ult = "boss_ult_abyss_frost_tide" if key in ("wuzhiqi", "changyou") else "boss_ult_ape_quake"
        return [ult, "ape_sweep_fling", "dread_ape_pummel"]
    if key in ("feiyi", "huodou", "nvchou", "fei"):
        return ["boss_ult_drought_breath", "wyrm_gorge_chomp" if etype == "Lindwurm" else "scorch_wing_ember", "acid_scale_splash"]
    if key in ("qiongqi", "zouyu", "mengji", "tiangouwang", "jiao", "shanhui"):
        return ["boss_ult_gale_slaughter", "saber_fang_throat_rip", "star_howl_rush"]
    if key in ("taotie", "paoxiaowang", "yayu", "shebishi"):
        return ["boss_ult_glutton_devour", "tiger_fang_maul", "feast_corpse_grow"]
    if key in ("jiuwei", "wuluo", "jingwei"):
        return ["boss_ult_nine_tail_domain", "fox_bewitch_charm", "soul_link_hex"]
    if key in ("xingtian", "chiyou", "qiangliang", "zaochi", "yingzhao"):
        return ["boss_ult_waraxe_whirl", "bronze_horn_linebreaker", "hollow_chest_halberd"]
    if key in ("jinwu", "bifang", "yuanchu", "jiufeng", "feilian"):
        return ["boss_ult_sun_crow_flare", "sky_talon_helm_rip", "wing_gust_backleap"]
    if key in ("kui", "siwang", "bo", "zhuhuai", "dangkang", "zhujian", "zheng"):
        ult = "boss_ult_thunder_drum" if key == "kui" else "four_horn_cataclysm"
        return [ult, "flood_bull_trample", "tusk_bristle_ram"]
    if key in ("xuangui", "fangfeng", "boshi", "baize", "kaiming"):
        return ["boss_ult_shell_fortress", "iron_beak_clamp" if key == "xuangui" else "tiger_claw_armor_tear", "ox_tail_double_sweep"]
    if key in ("qinyuan", "bashe", "mingshe", "hujiao"):
        ult = "boss_ult_venom_stinger" if key == "qinyuan" else "boss_ult_drought_breath"
        return [ult, "python_drag_coil", "stinger_armor_pierce" if key == "qinyuan" else "venom_fang_snap"]
    if key in ("gonggong", "bingyi", "zhuyin", "yinglong", "huashe", "jiuying", "xiangliuwang", "fuzhu", "chenghuang"):
        ult = "nine_marsh_devour" if key == "xiangliuwang" else "boss_ult_abyss_frost_tide"
        return [ult, "wyrm_gorge_chomp" if etype == "Lindwurm" else "frost_halberd_drain", "wyrm_tail_thresh"]
    if key in ("jumang", "kuafu"):
        return ["solar_peach_branch_slam", "root_line_impale", "bark_aegis_regrow"]
    if key in ("erfu", "hundun", "dijiang", "taowu", "gudiaowang"):
        ult = "boss_ult_shackled_wrath" if key == "erfu" else "boss_ult_ape_quake"
        return [ult, "gut_ripper_pounce", "infant_cry_dread"]
    return ["boss_ult_ape_quake", "tiger_claw_armor_tear", "ox_tail_double_sweep"]


def parse_64_bosses_from_nut() -> list[dict]:
    import json
    sh_src = (ROOT / "mod_wuxia" / "mod_wuxia" / "config" / "wx_shanhai.nut").read_text(encoding="utf-8")
    enc_src = (ROOT / "mod_wuxia" / "mod_wuxia" / "config" / "wx_encounters.nut").read_text(encoding="utf-8")
    manifest_assets = {}
    mp = ROOT / "art" / "manifest.json"
    if mp.exists():
        for a in json.loads(mp.read_text(encoding="utf-8")).get("assets", []):
            manifest_assets[a["id"]] = a

    # Parse cores
    cores = {}
    for m in re.finditer(r'(wx_core_[a-z0-9_]+)\s*=\s*\{([\s\S]*?)\n\t\},', sh_src):
        cid, blk = m.group(1), m.group(2)
        nm = re.search(r'Name\s*=\s*"([^"]+)"', blk)
        val = re.search(r'Value\s*=\s*(\d+)', blk)
        desc = re.search(r'Description\s*=\s*"([^"]+)"', blk)
        ma = manifest_assets.get(cid, {})
        icon_p = ma.get("previewPath") or ma.get("hdPath") or f"art/game/ui/items/misc/{cid}.png"
        cores[cid] = {
            "id": cid,
            "name": nm.group(1) if nm else cid,
            "value": int(val.group(1)) if val else 2000,
            "desc": desc.group(1) if desc else "",
            "icon": icon_p,
        }

    # Parse lairs
    lairs = {}
    for m in re.finditer(r'(shanhai_[a-z0-9_]+)\s*=\s*\{([\s\S]*?)\n\t\},', enc_src):
        lid, blk = m.group(1), m.group(2)
        nm = re.search(r'Name\s*=\s*"([^"]+)"', blk)
        desc = re.search(r'Description\s*=\s*"([^"]+)"', blk)
        br = re.search(r'Brush\s*=\s*"([^"]+)"', blk)
        tr = re.search(r'Troops\s*=\s*\[([^\]]+)\]', blk)
        rman = re.search(r'RewardManual\s*=\s*"([^"]+)"', blk)
        key_part = lid.replace("shanhai_", "")
        brush_id = br.group(1) if br else f"wx_{lid}"
        if not brush_id.startswith("wx_"):
            brush_id = f"wx_lair_{key_part}"
        ma = manifest_assets.get(brush_id) or manifest_assets.get(f"wx_shanhai_{key_part}") or manifest_assets.get(f"wx_lair_{key_part}") or {}
        img_p = ma.get("hdPath") or ma.get("previewPath") or "art/hd/wx_shanhai_zhuyan.png"
        lairs[lid] = {
            "id": lid,
            "artId": brush_id,
            "name": nm.group(1) if nm else lid,
            "desc": desc.group(1) if desc else "",
            "img": img_p,
            "troops": re.findall(r'"([^"]+)"', tr.group(1)) if tr else [],
            "rewardManual": rman.group(1) if rman else "",
        }

    boss_list = []
    for m in re.finditer(r'boss_([a-z0-9_]+)\s*=\s*\{([\s\S]*?)\n\t\},', sh_src):
        key, blk = m.group(1), m.group(2)
        chap = re.search(r'Chapter\s*=\s*"([^"]+)"', blk).group(1)
        bname = re.search(r'Name\s*=\s*"([^"]+)"', blk).group(1)
        etype = re.search(r'EntityType\s*=\s*"([^"]+)"', blk).group(1)
        hpm = float(re.search(r'HpMult\s*=\s*([0-9.]+)', blk).group(1))
        msk_b = int(re.search(r'MeleeSkillBonus\s*=\s*(\d+)', blk).group(1))
        mdf_b = int(re.search(r'MeleeDefBonus\s*=\s*(\d+)', blk).group(1))
        brv_b = int(re.search(r'BraveryBonus\s*=\s*(\d+)', blk).group(1))
        tname = re.search(r'TraitName\s*=\s*"([^"]+)"', blk).group(1)
        tdesc = re.search(r'TraitDesc\s*=\s*"([^"]+)"', blk).group(1)
        mech_m = re.search(r'Mechanics\s*=\s*\{([^\}]*)\}', blk)
        mech_str = mech_m.group(1) if mech_m else ""
        cid = f"wx_core_{key}"
        lid = f"shanhai_{key}"

        base = BASE_ARCHETYPE_STATS.get(etype, BASE_ARCHETYPE_STATS["Unhold"])
        hp = max(260, int(round(base[0] * hpm)))
        h_arm = int(round(base[1] * 1.25))
        b_arm = int(round(base[2] * 1.25))
        ap_m = re.search(r'MinAP\s*=\s*(\d+)', mech_str)
        ap = int(ap_m.group(1)) if ap_m else base[3]
        init_m = re.search(r'BonusInit\s*=\s*(\d+)', mech_str)
        init = base[10] + (int(init_m.group(1)) if init_m else 0)
        rdef_m = re.search(r'BonusRDef\s*=\s*(\d+)', mech_str)
        rdef = base[9] + (int(rdef_m.group(1)) if rdef_m else 0)
        extra_msk = int(re.search(r'BonusMSkill\s*=\s*(\d+)', mech_str).group(1)) if re.search(r'BonusMSkill\s*=\s*(\d+)', mech_str) else 0
        extra_mdf = int(re.search(r'BonusMDef\s*=\s*(\d+)', mech_str).group(1)) if re.search(r'BonusMDef\s*=\s*(\d+)', mech_str) else 0

        msk = min(98, base[6] + msk_b + extra_msk // 2)
        mdef = min(42, base[8] + mdf_b + extra_mdf // 2)
        res = min(180, base[11] + brv_b)

        # Build tactical tags & immunities from Mechanics!
        tags = []
        imms = []
        if "SteelBrow = true" in mech_str:
            tags.append("铜头免爆头")
            imms.append("免疫爆头暴击倍率")
        if "Underdog = true" in mech_str:
            tags.append("免围攻惩罚")
            imms.append("无视合围扣防")
        if "ImmuneStun = true" in mech_str:
            imms.append("免疫震晕点穴")
        if "ImmuneDisarm = true" in mech_str:
            imms.append("免疫夺刃缴械")
        if etype in ("SkeletonBoss", "SkeletonHeavy", "SkeletonPriest", "ZombieBoss", "ZombieBetrayer", "Ghost", "Schrat"):
            imms.append("死寂/灵木躯（免奇毒流血）")
        if "RegenHP" in mech_str:
            rv = re.search(r'RegenHP\s*=\s*(\d+)', mech_str).group(1)
            tags.append(f"每轮自愈+{rv}血")
        if "AuraRadius" in mech_str:
            ar = re.search(r'AuraRadius\s*=\s*(\d+)', mech_str).group(1)
            tags.append(f"周身{ar}格凶煞妖域")
        if "EnrageBelowPct" in mech_str:
            tags.append("残血沸狂增伤")
        if "KillRefundAP" in mech_str:
            kv = re.search(r'KillRefundAP\s*=\s*(\d+)', mech_str).group(1)
            tags.append(f"首杀返+{kv}AP")
        if "ReviveOnceHP" in mech_str:
            tags.append("濒死逆命复生")
        if "HammerWeakOnly" in mech_str:
            tags.append("唯钝器重锤可破")
        if "Thorns" in mech_str:
            tags.append("近战反震伤甲")
        if ap >= 10:
            tags.append(f"常驻{ap}AP")

        rank = "山海四凶" if key in FOUR_FIENDS else ("太古神魔" if key in ANCIENT_GODS else "秘境妖皇")
        sock = "boss_crimson" if rank == "山海四凶" else ("boss_frost" if "寒" in tdesc or "冰" in bname or "水" in bname else ("boss_gold" if rank == "太古神魔" else "boss_mire"))
        bgrp = CHAPTER_TO_BOOK_GROUP.get(chap, "dahuang")

        # Counterplay advice
        if "HammerWeakOnly" in mech_str:
            cp = "千年硬甲对刀剑枪箭减伤四成以上！务必配备《震岳碎甲锤》《九曜破城锤》或成对重指虎攻坚。"
        elif "ThornsNonAxe" in mech_str:
            cp = "刀剑枪刺近身皆受铁棘反伤！须遣双手开山巨斧、盘古开天斧破木断根，辅以火器弓弩远轰。"
        elif "AuraRadius" in mech_str:
            cp = "切忌十二人一窝蜂贴脸吃满周身妖域损耗！前排精锐开启《金钟护体罡》顶线，主力以两格长槊、陌刀及神臂弩隔圈速杀。"
        elif "BonusRDef" in mech_str and rdef >= 32:
            cp = "高机动妖身几近免疫弓箭平射！宜用捕网、绊字缠足杖或《天罗地网》封其身法，再以必中点穴/快剑围剿。"
        elif "RegenHP" in mech_str:
            cp = "拥有强悍上古血脉自愈！务必挂上【割裂流血】或【五毒丧门钉】压制回血，一鼓作气斩绝生机。"
        else:
            cp = "先清剿秘境伴生群妖断其侧翼夹击，由持盾《不动明王》护卫接住首轮凶威，重兵破甲后短匕《透骨分筋刺》收尾。"

        short_nm = re.sub(r'^【[^】]+】', '', bname).split("·")[-1]
        skeys = pick_boss_skills(key, etype, mech_str)

        boss_list.append({
            "id": f"wx_boss_{key}",
            "key": key,
            "kind": "boss",
            "rank": rank,
            "chapter": chap,
            "bookGroup": bgrp,
            "name": bname,
            "shortName": short_nm,
            "archetype": etype,
            "bodyLabel": base[13],
            "socketTheme": sock,
            "worldFigId": BOSS_WORLD_FIG_MAP.get(key, "wx_fig_beast_zhuyan"),
            "classicQuote": f"《山海经·{chap}》古籍所载上古大妖「{short_nm}」，盘踞秘境统御一方群兽。",
            "traitName": tname,
            "traitDesc": tdesc,
            "tags": tags[:5],
            "immunities": imms if imms else ["首领霸体（免常规击退）"],
            "counterplay": cp,
            "stats": {
                "hp": hp, "headArmor": h_arm, "bodyArmor": b_arm, "ap": ap,
                "fatigue": base[4], "fatRec": base[5], "mSkill": msk, "rSkill": base[7],
                "mDef": mdef, "rDef": rdef, "init": init, "resolve": res, "xp": base[12]
            },
            "skills": [{"id": f"wx_boss_{key}_{sk}", **MONSTER_SKILL_LIB[sk]} for sk in skeys],
            "core": cores.get(cid),
            "lair": lairs.get(lid),
        })
    return boss_list


def build_all_bestiary_records() -> dict:
    bosses = parse_64_bosses_from_nut()

    # Map chapter -> wild beast IDs so every Boss Lair displays rich regionally matched《山海经》retinue pawns!
    wild_records = []
    for row in (EXISTING_11_WILD_BEASTS + NEW_64_SHANHAI_BEASTS):
        (sh_num, cidx, bid, nm, chap, bgrp, rank, arch, wfig,
         quote, tname, tdesc, cp, trophy, st, sk1, sk2) = row
        base = BASE_ARCHETYPE_STATS.get(arch, BASE_ARCHETYPE_STATS["Hyena"])
        hp, ha, ba, ap, fat, frec, msk, rsk, mdf, rdf, ini, res, xp = st

        imms = []
        if arch in ("SkeletonMedium", "ZombieBetrayer", "Ghost", "Schrat", "SchratSmall", "SpiderEggs"):
            imms.append("免奇毒与点穴")
        if "百毒不侵" in tdesc:
            imms.append("天生百毒不侵")
        if "免疫爆头" in tdesc:
            imms.append("免疫爆头暴击")
        if "免除背刺" in tdesc or "免除被围攻" in tdesc:
            imms.append("免合围扣防")

        tags = [rank, f"《{chap}》", base[13]]
        if rsk >= 60:
            tags.append("远程/妖术")
        if ap >= 10:
            tags.append(f"{ap}AP疾行")

        wild_records.append({
            "id": bid,
            "key": bid.replace("wx_beast_", ""),
            "sheetNum": sh_num,
            "cellIdx": cidx,
            "kind": "spawn" if rank == "伴生衍生物" else "wild",
            "rank": rank,
            "chapter": chap,
            "bookGroup": bgrp,
            "name": nm,
            "shortName": nm,
            "archetype": arch,
            "bodyLabel": base[13],
            "socketTheme": "spawn_mire" if rank == "伴生衍生物" else "wild_stone",
            "worldFigId": wfig,
            "classicQuote": quote,
            "traitName": tname,
            "traitDesc": tdesc,
            "tags": tags,
            "immunities": imms if imms else ["血肉妖躯（受流血/点穴/奇毒影响）"],
            "counterplay": cp,
            "trophy": trophy,
            "stats": {
                "hp": hp, "headArmor": ha, "bodyArmor": ba, "ap": ap,
                "fatigue": fat, "fatRec": frec, "mSkill": msk, "rSkill": rsk,
                "mDef": mdf, "rDef": rdf, "init": ini, "resolve": res, "xp": xp
            },
            "skills": [
                {"id": f"{bid}_{sk1}", **MONSTER_SKILL_LIB[sk1]},
                {"id": f"{bid}_{sk2}", **MONSTER_SKILL_LIB[sk2]},
            ],
            "core": None,
            "lair": None,
        })

    # Wire regional companion wild beasts into each of the 64 Boss Lairs for the Encounter Chessboard Sandbox!
    wild_by_grp = {}
    for w in wild_records:
        if w["kind"] == "wild":
            wild_by_grp.setdefault(w["bookGroup"], []).append(w["id"])

    vanilla_troop_to_beast = {
        "Direwolf": "wx_beast_tiangou",
        "Hyena": "wx_beast_gudiao",
        "Serpent": "wx_beast_bashe_wild",
        "Spider": "wx_beast_chizhu",
        "Ghoul": "wx_beast_paoxiao",
        "Alp": "wx_beast_eshou",
        "Hexe": "wx_beast_jiuwei_wild",
        "Schrat": "wx_beast_jianmu",
        "Unhold": "wx_beast_zhuyan_wild",
        "UnholdFrost": "wx_beast_zhuyan_wild",
        "UnholdBog": "wx_beast_yuanhu",
        "Lindwurm": "wx_beast_feiyi_wild",
        "Vampire": "wx_beast_sanqingniao",
        "Ghost": "wx_beast_gengfu",
        "SkeletonHeavy": "wx_beast_guanxiong",
        "SkeletonMedium": "wx_beast_guanxiong",
        "SkeletonPriest": "wx_beast_heichi",
        "OrcWarrior": "wx_beast_jiuli",
        "OrcBerserker": "wx_beast_quanfeng",
        "GoblinAmbusher": "wx_beast_haozhi",
        "GoblinSkirmisher": "wx_beast_feishu",
    }

    for idx, b in enumerate(bosses):
        grp_pool = wild_by_grp.get(b["bookGroup"], [])
        companions = []
        if b["lair"] and b["lair"]["troops"]:
            for tr in b["lair"]["troops"][1:5]:
                mapped = vanilla_troop_to_beast.get(tr)
                if mapped:
                    companions.append(mapped)
        # Also enrich with 2 regionally native newly added《山海经》wild beasts!
        if grp_pool:
            c1 = grp_pool[(idx * 2) % len(grp_pool)]
            c2 = grp_pool[(idx * 2 + 1) % len(grp_pool)]
            if len(companions) >= 2:
                companions[-2] = c1
                companions[-1] = c2
            else:
                companions.extend([c1, c2])
        b["companions"] = companions[:4]

    all_creatures = bosses + wild_records
    species_136 = [c for c in all_creatures if c["kind"] != "spawn"]
    spawns_3 = [c for c in all_creatures if c["kind"] == "spawn"]

    return {
        "summary": {
            "speciesTotal": len(species_136),   # Exact 136! (64 Bosses + 72 Wild Beasts)
            "pawnsTotal": len(all_creatures),   # 139 Total Tactical Pawns (136 + 3 Spawn Tokens)
            "bossCount": len(bosses),           # 64
            "wildCount": len(species_136) - len(bosses),  # 72
            "spawnCount": len(spawns_3),        # 3
            "lairCount": 64,
            "worldFigCount": 24,
            "skillTotal": sum(len(c["skills"]) for c in all_creatures),
        },
        "bookGroups": [
            {"id": "nanshan",   "idx": "01", "name": "南山经群妖", "classic": "《南山经·鹊山至招摇》"},
            {"id": "xishan",    "idx": "02", "name": "西山经群妖", "classic": "《西山经·太华至昆仑》"},
            {"id": "beishan",   "idx": "03", "name": "北山经群妖", "classic": "《北山经·钩吾至钟山》"},
            {"id": "dongshan",  "idx": "04", "name": "东山经群妖", "classic": "《东山经·太山至流波》"},
            {"id": "zhongshan", "idx": "05", "name": "中山经群妖", "classic": "《中山经·都广至青要》"},
            {"id": "dahuang",   "idx": "06", "name": "海外海内大荒", "classic": "《海外·海内·大荒十二经》"},
        ],
        "creatures": all_creatures,
    }


if __name__ == "__main__":
    data = build_all_bestiary_records()
    print("Bestiary summary:", data["summary"])
