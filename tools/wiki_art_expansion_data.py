#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Expansion Art Definitions (Sheets 19..33 -> +240 Assets = 552 Total):
  - Sheets 19..24: +96 Regular Tiered Chinese Weapons, Firearms, Tools & Shields (Volume 2 -> 146 items)
  - Sheets 25..33: +144 Modular East-Asian Character Paperdoll Layers & Jianghu Enemy Busts (Volume 3 -> 160 items)
"""

import os

BRAIN = r"C:\Users\25647\.gemini\antigravity\brain\fa3a61d2-2588-454a-a04d-cca189377964"

EXPANSION_SHEET_SPECS = {
    19: (4, 4, os.path.join(BRAIN, "wuxia_swords_sabers_4x4_v3_1795160691076.jpg")),
    20: (4, 4, os.path.join(BRAIN, "wuxia_spears_polearms_4x4_obsidian_1795160691224.jpg")),
    21: (4, 4, os.path.join(BRAIN, "wuxia_staves_maces_4x4_v3_1795162453447.jpg")),
    22: (4, 4, os.path.join(BRAIN, "wuxia_axes_gauntlets_flails_sheet_final_1795160664622.jpg")),
    23: (4, 4, os.path.join(BRAIN, "wuxia_whips_daggers_bows_crossbows_4x4_padded_1795160672741.jpg")),
    24: (4, 4, os.path.join(BRAIN, "wuxia_firearms_shields_4x4_v3_1795160892439.jpg")),
    25: (4, 4, os.path.join(BRAIN, "wuxia_heads_spritesheet_4x4_v3_1795160897579.jpg")),
    26: (4, 4, os.path.join(BRAIN, "wuxia_hair_beard_spritesheet_v3_1795160916536.jpg")),
    27: (4, 4, os.path.join(BRAIN, "wuxia_hats_crowns_4x4_final_1795160878787.jpg")),
    28: (4, 4, os.path.join(BRAIN, "wuxia_helmets_4x4_spritesheet_black_1795160893691.jpg")),
    29: (4, 4, os.path.join(BRAIN, "wuxia_civilian_sect_torsos_4x4_v2_1795161237884.jpg")),
    30: (4, 4, os.path.join(BRAIN, "jianghu_light_armor_sheet_4x4_left_1795161266157.jpg")),
    31: (4, 4, os.path.join(BRAIN, "chinese_heavy_armors_4x4_final_1795161266329.jpg")),
    32: (4, 4, os.path.join(BRAIN, "wuxia_back_accessories_4x4_v3_1795161260367.jpg")),
    33: (4, 4, os.path.join(BRAIN, "wuxia_enemy_busts_4x4_v3_1795161269068.jpg")),
}

# Per-sheet cell indices that need horizontal mirror so ALL paperdoll parts & busts face 3/4 LEFT:
EXPANSION_FLIP_CELLS = {
    26: set(range(16)),                                # All 16 hairstyles & beards face 3/4 right -> flip to 3/4 left
    27: {i for i in range(16) if i not in (1, 2, 4, 6)},  # Flip right-angled hats/crowns/hoods to 3/4 left
    28: {i for i in range(16) if i not in (5, 8, 9)},     # Flip right-angled masks/war-helmets to 3/4 left
    29: set(range(16)),                                # All 16 civilian/sect torsos face 3/4 right -> flip to 3/4 left
    30: set(range(16)),                                # All 16 sect robes/light armors face 3/4 right -> flip to 3/4 left
    31: set(range(16)),                                # All 16 medium/heavy armors face 3/4 right -> flip to 3/4 left
    32: {0, 2, 9, 12},                                 # Flip right-facing cloaks/bandolier/rain-capelet to 3/4 left
    33: {i for i in range(16) if i != 7},              # Flip 15 right-facing enemy busts (cell 7 already faces 3/4 left)
}

# Tuple: (sheet, cell_idx, id, stage, group, name, sub, proc_kind, rel_gfx, fallback, coderef, brief)
EXPANSION_CELLS = [
    # ==========================================================================
    # Sheet 19: 8 Tiered Chinese Swords + 8 Tiered Chinese Sabers
    # ==========================================================================
    (19, 0, "wx_wpn_sword_01", "2_weapons", "百兵图谱 · 刀剑阶梯", "朽木演武剑", "剑系 T0 · 武馆习艺木剑", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_sword_01.png", "wooden_stick", "mod_wuxia/config/wx_weapons.nut", "老枣木削制、麻绳缠柄的乡村武馆演武木剑，剑脊磨痕累累。"),
    (19, 1, "wx_wpn_sword_02", "2_weapons", "百兵图谱 · 刀剑阶梯", "锈铁云头短剑", "剑系 T1 · 江湖防身铁剑", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_sword_02.png", "shortsword", "mod_wuxia/config/wx_weapons.nut", "缺口斑驳的粗锻生铁短剑，黄铜旧云头护手，市井游侠起步兵刃。"),
    (19, 2, "wx_wpn_sword_03", "2_weapons", "百兵图谱 · 刀剑阶梯", "青钢制式长剑", "剑系 T2 · 门派弟子标配", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_sword_03.png", "arming_sword", "mod_wuxia/config/wx_weapons.nut", "青白夹钢锻打的三尺长剑，黑鲨鱼皮缠柄配暗青剑穗。"),
    (19, 3, "wx_wpn_sword_04", "2_weapons", "百兵图谱 · 刀剑阶梯", "百炼松纹宝剑", "剑系 T3 · 名家花纹钢剑", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_sword_04.png", "noble_sword", "mod_wuxia/config/wx_weapons.nut", "折叠百锻显露苍劲松皮暗纹的上乘利剑，白玉剑首配吞口金装。"),
    (19, 4, "wx_wpn_sword_05", "2_weapons", "百兵图谱 · 刀剑阶梯", "玄门阴阳太极剑", "剑系 T3 · 道门内家佩剑", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_sword_05.png", "noble_sword", "mod_wuxia/config/wx_weapons.nut", "古铜阴阳双鱼剑格配太和云纹剑身，柔韧借力宜施回锋剑诀。"),
    (19, 5, "wx_wpn_sword_06", "2_weapons", "百兵图谱 · 刀剑阶梯", "寒星游龙细刺剑", "剑系 T3 · 身法突刺细剑", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_sword_06.png", "fencing_sword", "mod_wuxia/config/wx_weapons.nut", "窄刃血槽镂空护手的轻捷细剑，随身法暴起一刺封喉。"),
    (19, 6, "wx_wpn_sword_07", "2_weapons", "百兵图谱 · 刀剑阶梯", "八面汉制双手长剑", "剑系 T3 · 双手劈刺大剑", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_sword_07.png", "longsword", "mod_wuxia/config/wx_weapons.nut", "修长双手握柄配八面破甲剑脊，兼顾阵战横扫与重刺。"),
    (19, 7, "wx_wpn_sword_08", "2_weapons", "百兵图谱 · 刀剑阶梯", "乌金无锋重铁剑", "剑系 T4 · 刚猛破甲巨剑", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_sword_08.png", "greatsword", "mod_wuxia/config/wx_weapons.nut", "阔背厚脊不假锋芒的黑铁双手巨剑，以内力催动重剑无锋大巧不工。"),
    (19, 8, "wx_wpn_saber_01", "2_weapons", "百兵图谱 · 刀剑阶梯", "柴房豁口砍柴刀", "刀系 T0 · 农猎粗铁短刀", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_saber_01.png", "butchers_cleaver", "mod_wuxia/config/wx_weapons.nut", "庄稼汉与山野樵夫顺手操起的厚背豁口柴刀，凶悍接地气。"),
    (19, 9, "wx_wpn_saber_02", "2_weapons", "百兵图谱 · 刀剑阶梯", "绿林铁盘柳叶刀", "刀系 T1 · 趟子手/山贼佩刀", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_saber_02.png", "falchion", "mod_wuxia/config/wx_weapons.nut", "微弯如柳叶、配圆铁护盘的江湖常见腰刀，出刀利落。"),
    (19, 10, "wx_wpn_saber_03", "2_weapons", "百兵图谱 · 刀剑阶梯", "百炼军镇雁翎刀", "刀系 T2 · 边军制式佩刀", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_saber_03.png", "scimitar", "mod_wuxia/config/wx_weapons.nut", "刀尖反刃如雁翎、血槽笔直的明末边军精锻佩刀，劈刺俱佳。"),
    (19, 11, "wx_wpn_saber_04", "2_weapons", "百兵图谱 · 刀剑阶梯", "江湖宽刃牛尾刀", "刀系 T2 · 捕快豪客重腰刀", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_saber_04.png", "military_cleaver", "mod_wuxia/config/wx_weapons.nut", "刀头阔大呈弧形的清刚牛尾厚刀，专擅劈斩皮肉筋骨。"),
    (19, 12, "wx_wpn_saber_05", "2_weapons", "百兵图谱 · 刀剑阶梯", "铁环九连鬼头大刀", "刀系 T3 · 绿林瓢把子凶刀", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_saber_05.png", "military_cleaver", "mod_wuxia/config/wx_weapons.nut", "刀背穿挂九枚精铁响环的厚背鬼头砍刀，挥舞金铁震魂。"),
    (19, 13, "wx_wpn_saber_06", "2_weapons", "百兵图谱 · 刀剑阶梯", "戚家双手长苗刀", "刀系 T3 · 双手疾斩长刀", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_saber_06.png", "warbrand", "mod_wuxia/config/wx_weapons.nut", "刃长五尺、双手运使如禾苗修长的破阵长刀，步战进退如电。"),
    (19, 14, "wx_wpn_saber_07", "2_weapons", "百兵图谱 · 刀剑阶梯", "塞外镔铁马贼弯刀", "刀系 T3 · 割裂流血弯刃", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_saber_07.png", "shamshir", "mod_wuxia/config/wx_weapons.nut", "大弧度旋纹镔铁弯刀配狼牙铜护手，掠身即开深长血口。"),
    (19, 15, "wx_wpn_saber_08", "2_weapons", "百兵图谱 · 刀剑阶梯", "双手破甲斩马厚刀", "刀系 T4 · 重装步战狂刀", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_saber_08.png", "two_handed_scimitar", "mod_wuxia/config/wx_weapons.nut", "沉重修长的黑铁双手斩马重刃，一刀断马腿破重铠。"),

    # ==========================================================================
    # Sheet 20: 8 Spears + 8 Polearms
    # ==========================================================================
    (20, 0, "wx_wpn_spear_01", "2_weapons", "百兵图谱 · 枪矛长兵", "削尖火烤毛竹矛", "枪系 T0 · 山民抗暴竹矛", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_spear_01.png", "militia_spear", "mod_wuxia/config/wx_weapons.nut", "老毛竹斜削成尖再经桐油火烤硬化的简陋长矛。"),
    (20, 1, "wx_wpn_spear_02", "2_weapons", "百兵图谱 · 枪矛长兵", "乡勇生铁短矛", "枪系 T1 · 村寨团练步矛", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_spear_02.png", "militia_spear", "mod_wuxia/config/wx_weapons.nut", "梣木粗杆套接生铁叶形矛头，乡勇守栅看家标配。"),
    (20, 2, "wx_wpn_spear_03", "2_weapons", "百兵图谱 · 枪矛长兵", "白蜡杆红缨快枪", "枪系 T2 · 镖局武师长枪", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_spear_03.png", "boar_spear", "mod_wuxia/config/wx_weapons.nut", "柔韧白蜡木杆配百炼钢枪尖与喋血红缨，枪花抖动眩敌双目。"),
    (20, 3, "wx_wpn_spear_04", "2_weapons", "百兵图谱 · 枪矛长兵", "威远十字横挡铁枪", "枪系 T2 · 拒敌守线重枪", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_spear_04.png", "boar_spear", "mod_wuxia/config/wx_weapons.nut", "枪头下方横出精铁月牙挡翼，架枪守线可死死卡住扑击凶兽。"),
    (20, 4, "wx_wpn_spear_05", "2_weapons", "百兵图谱 · 枪矛长兵", "丈八曲刃蛇矛枪", "枪系 T3 · 破甲撕裂奇枪", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_spear_05.png", "fighting_spear", "mod_wuxia/config/wx_weapons.nut", "蜿蜒如游蛇吐信的双曲波浪枪刃，刺入甲缝拧转创口极深。"),
    (20, 5, "wx_wpn_spear_06", "2_weapons", "百兵图谱 · 枪矛长兵", "边军四棱透甲锥枪", "枪系 T3 · 专破铁铠重枪", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_spear_06.png", "fighting_spear", "mod_wuxia/config/wx_weapons.nut", "无刃窄长四棱破甲钢锥枪头，专为贯穿铁札重甲锻造。"),
    (20, 6, "wx_wpn_spear_07", "2_weapons", "百兵图谱 · 枪矛长兵", "军阵攒竹步战长槊", "枪系 T3 · 两格军阵长枪", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_spear_07.png", "pike", "mod_wuxia/config/wx_weapons.nut", "胶漆麻绳密缠复合竹木杆的军阵长槊，隔阵两格攒刺拒马。"),
    (20, 7, "wx_wpn_spear_08", "2_weapons", "百兵图谱 · 枪矛长兵", "百炼乌钢重马槊", "枪系 T4 · 将门破阵大槊", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_spear_08.png", "spetum", "mod_wuxia/config/wx_weapons.nut", "修长八面百炼乌钢槊首配黄铜吞口，重甲猛将摧锋利器。"),
    (20, 8, "wx_wpn_pole_01", "2_weapons", "百兵图谱 · 枪矛长兵", "庄户三齿铁草叉", "长兵 T0 · 农夫抗匪长叉", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_pole_01.png", "pitchfork", "mod_wuxia/config/wx_weapons.nut", "晒场翻草的三股熟铁长叉，乱世庄稼汉结阵自保长兵。"),
    (20, 9, "wx_wpn_pole_02", "2_weapons", "百兵图谱 · 枪矛长兵", "水寨倒刺钩镰枪", "长兵 T1 · 钩拉破阵长兵", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_pole_02.png", "hooked_blade", "mod_wuxia/config/wx_weapons.nut", "侧生锋利弯钩的水陆寨栅长兵，可将前排盾卫硬生生拽离阵线。"),
    (20, 10, "wx_wpn_pole_03", "2_weapons", "百兵图谱 · 枪矛长兵", "行脚僧月牙方便铲", "长兵 T2 · 佛门护法重铲", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_pole_03.png", "billhook", "mod_wuxia/config/wx_weapons.nut", "前端平阔钢铲、后端新月护刃的行脚苦行僧重长兵，势沉力猛。"),
    (20, 11, "wx_wpn_pole_04", "2_weapons", "百兵图谱 · 枪矛长兵", "边关长杆朴刀", "长兵 T2 · 步卒砍劈长刀", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_pole_04.png", "bladed_pike", "mod_wuxia/config/wx_weapons.nut", "双手长木柄安装宽厚斩刀刃的江湖朴刀，后排跨格猛劈。"),
    (20, 12, "wx_wpn_pole_05", "2_weapons", "百兵图谱 · 枪矛长兵", "武科制式偃月大刀", "长兵 T3 · 扇面横扫大刀", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_pole_05.png", "swordlance", "mod_wuxia/config/wx_weapons.nut", "吞口铜兽衔阔弯刀身的武举重型大刀，一记横扫连斩三敌。"),
    (20, 13, "wx_wpn_pole_06", "2_weapons", "百兵图谱 · 枪矛长兵", "清源三尖两刃刀", "长兵 T3 · 劈刺兼备奇刃", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_pole_06.png", "swordlance", "mod_wuxia/config/wx_weapons.nut", "刀尖分三叉呈山字锋芒的奇门长柄重刃，挑刺横斩变幻莫测。"),
    (20, 14, "wx_wpn_pole_07", "2_weapons", "百兵图谱 · 枪矛长兵", "藩镇单耳青铁长戟", "长兵 T3 · 官军节度长戟", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_pole_07.png", "billhook", "mod_wuxia/config/wx_weapons.nut", "枪尖侧旁横出小枝月牙戈刃的藩镇牙兵制式铁戟，钩啄破甲。"),
    (20, 15, "wx_wpn_pole_08", "2_weapons", "百兵图谱 · 枪矛长兵", "塞外长柄狼牙槊", "长兵 T4 · 重骑步战碎甲槊", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_pole_08.png", "polehammer", "mod_wuxia/config/wx_weapons.nut", "长铁杆顶端密布钢刺尖棱的北方重型破甲长槊，隔阵敲碎头盔。"),

    # ==========================================================================
    # Sheet 21: 8 Staves + 8 Hammers & Maces (clean_text=True strips top-left labels!)
    # ==========================================================================
    (21, 0, "wx_wpn_staff_01", "2_weapons", "百兵图谱 · 棍杖锤锏", "齐眉白蜡木长棍", "棍杖 T0 · 武林百兵之祖", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_staff_01.png", "wooden_stick", "mod_wuxia/config/wx_weapons.nut", "手汗浸润包浆油亮的韧性白蜡木齐眉棍，点扫拨架轻灵周密。"),
    (21, 1, "wx_wpn_staff_02", "2_weapons", "百兵图谱 · 棍杖锤锏", "少室熟铜包头棍", "棍杖 T1 · 护院武僧制式棍", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_staff_02.png", "winged_mace", "mod_wuxia/config/wx_weapons.nut", "硬檀木棍身两端套接厚重熟铜箍套，闷棍敲击震荡脑髓。"),
    (21, 2, "wx_wpn_staff_03", "2_weapons", "百兵图谱 · 棍杖锤锏", "精铁螺纹少林棍", "棍杖 T2 · 刚猛重铁齐眉棍", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_staff_03.png", "two_handed_mace", "mod_wuxia/config/wx_weapons.nut", "通体生铁铸就、中段缠牛皮防滑的三十斤重铁棍，横扫断骨。"),
    (21, 3, "wx_wpn_staff_04", "2_weapons", "百兵图谱 · 棍杖锤锏", "沧桑铁木龙头拐杖", "棍杖 T2 · 江湖耆宿奇门杖", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_staff_04.png", "morning_star", "mod_wuxia/config/wx_weapons.nut", "百年铁黎木根雕狰狞龙头杖首，暗藏沉铁杖尾，老辣刁钻。"),
    (21, 4, "wx_wpn_staff_05", "2_weapons", "百兵图谱 · 棍杖锤锏", "精钢锁环三节棍", "棍杖 T3 · 绕防奇门软硬棍", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_staff_05.png", "flail", "mod_wuxia/config/wx_weapons.nut", "三截乌钢短棍以粗铁环扣连，长可横扫、短可绕盾急抽。"),
    (21, 5, "wx_wpn_staff_06", "2_weapons", "百兵图谱 · 棍杖锤锏", "疯魔精铁方便杖", "棍杖 T3 · 双手重型降魔杖", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_staff_06.png", "two_handed_mace", "mod_wuxia/config/wx_weapons.nut", "沉铁重杆配厚钝铲头与铜环，施展疯魔杖法状若狂狮。"),
    (21, 6, "wx_wpn_staff_07", "2_weapons", "百兵图谱 · 棍杖锤锏", "九环苦行金锡杖", "棍杖 T3 · 高僧镇邪法杖", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_staff_07.png", "two_handed_mace", "mod_wuxia/config/wx_weapons.nut", "黄铜塔轮杖首穿挂九枚梵音铜环的佛门重锡杖，荡涤尸傀邪祟。"),
    (21, 7, "wx_wpn_staff_08", "2_weapons", "百兵图谱 · 棍杖锤锏", "乌木错金盘纹重杖", "棍杖 T4 · 宗师镇山大杖", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_staff_08.png", "two_handed_flanged_mace", "mod_wuxia/config/wx_weapons.nut", "阴沉铁力乌木嵌熟铜龙鳞箍的八十斤重杖，一杖顿地碎石裂甲。"),
    (21, 8, "wx_wpn_hammer_01", "2_weapons", "百兵图谱 · 棍杖锤锏", "铁钉枣木骨朵棒", "锤锏 T0 · 草寇闷棍钝器", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_hammer_01.png", "wooden_flail", "mod_wuxia/config/wx_weapons.nut", "疙瘩硬枣木球头敲入十余枚粗铁钉的绿林骨朵，震晕活捉利器。"),
    (21, 9, "wx_wpn_hammer_02", "2_weapons", "百兵图谱 · 棍杖锤锏", "塞外短柄狼牙铁棒", "锤锏 T1 · 破血碎骨钝棒", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_hammer_02.png", "morning_star", "mod_wuxia/config/wx_weapons.nut", "纺锤形生铁棒头密布尖锐狼牙铁刺，连砸带撕血肉模糊。"),
    (21, 10, "wx_wpn_hammer_03", "2_weapons", "百兵图谱 · 棍杖锤锏", "八棱百炼精铁单锤", "锤锏 T2 · 步战碎甲单手锤", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_hammer_03.png", "winged_mace", "mod_wuxia/config/wx_weapons.nut", "八面棱角分明的沉铁单手战锤，配藤牌守线专敲重甲关节。"),
    (21, 11, "wx_wpn_hammer_04", "2_weapons", "百兵图谱 · 棍杖锤锏", "黄铜蒜头破甲骨朵", "锤锏 T2 · 宋明军校腰锤", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_hammer_04.png", "warhammer", "mod_wuxia/config/wx_weapons.nut", "形似饱满独头紫皮蒜的熟铜瓜锤，隔甲传递恐怖内震。"),
    (21, 12, "wx_wpn_hammer_05", "2_weapons", "百兵图谱 · 棍杖锤锏", "铁匠铺开山大铁锤", "锤锏 T3 · 双手蛮力破甲锤", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_hammer_05.png", "two_handed_wooden_hammer", "mod_wuxia/config/wx_weapons.nut", "方正沉黑的锻炉重型双手大铁锤，一锤将胸甲砸成凹坑。"),
    (21, 13, "wx_wpn_hammer_06", "2_weapons", "百兵图谱 · 棍杖锤锏", "捕头四棱精钢单锏", "锤锏 T3 · 专克硬功破甲锏", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_hammer_06.png", "warhammer", "mod_wuxia/config/wx_weapons.nut", "无刃凹槽四棱精钢长锏，抽击硬功护体者一锏断肋散气。"),
    (21, 14, "wx_wpn_hammer_07", "2_weapons", "百兵图谱 · 棍杖锤锏", "玄铁立瓜双手重锤", "锤锏 T4 · 摧甲震地重锤", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_hammer_07.png", "two_handed_hammer", "mod_wuxia/config/wx_weapons.nut", "硕大玄铁立瓜重锤，专为击碎山海玄龟甲与重装铁浮屠而生。"),
    (21, 15, "wx_wpn_hammer_08", "2_weapons", "百兵图谱 · 棍杖锤锏", "鹰嘴倒刺长柄破城锤", "锤锏 T4 · 两格破甲重长锤", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_hammer_08.png", "polehammer", "mod_wuxia/config/wx_weapons.nut", "锤面配锐利穿甲鹰嘴的双手长杆重战锤，隔阵敲碎重铠盾墙。"),

    # ==========================================================================
    # Sheet 22: 8 Axes + 6 Paired Fist Gauntlets + 2 Heavy Flails
    # ==========================================================================
    (22, 0, "wx_wpn_axe_01", "2_weapons", "百兵图谱 · 斧钺拳爪", "山林樵夫伐木短斧", "斧钺 T0 · 劈盾劳作手斧", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_axe_01.png", "hatchet", "mod_wuxia/config/wx_weapons.nut", "曲木短柄楔紧的粗铁伐木斧，穷苦樵夫进山防狼劈木盾利器。"),
    (22, 1, "wx_wpn_axe_02", "2_weapons", "百兵图谱 · 斧钺拳爪", "黑风寨阔口铁板斧", "斧钺 T1 · 绿林步战短板斧", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_axe_02.png", "hand_axe", "mod_wuxia/config/wx_weapons.nut", "平头阔刃沉铁板斧，李逵式草莽悍匪贴身乱劈凶器。"),
    (22, 2, "wx_wpn_axe_03", "2_weapons", "百兵图谱 · 斧钺拳爪", "精铁新月单手战斧", "斧钺 T2 · 边军破盾战斧", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_axe_03.png", "fighting_axe", "mod_wuxia/config/wx_weapons.nut", "弯弧新月钢刃配背刺铁锤头的军用单手战斧，两斧劈裂圆木盾。"),
    (22, 3, "wx_wpn_axe_04", "2_weapons", "百兵图谱 · 斧钺拳爪", "乌钢凤头破甲单斧", "斧钺 T3 · 名门重装手斧", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_axe_04.png", "fighting_axe", "mod_wuxia/config/wx_weapons.nut", "乌钢错铜云纹厚背战斧，劈入锁甲深可见骨。"),
    (22, 4, "wx_wpn_axe_05", "2_weapons", "百兵图谱 · 斧钺拳爪", "双手劈山大板斧", "斧钺 T3 · 旋斩破盾巨斧", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_axe_05.png", "greataxe", "mod_wuxia/config/wx_weapons.nut", "磨盘大小的双面寒铁巨斧，命中身躯头部同时重创。"),
    (22, 5, "wx_wpn_axe_06", "2_weapons", "百兵图谱 · 斧钺拳爪", "步战长杆蛾眉战斧", "斧钺 T3 · 两格碎盾长斧", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_axe_06.png", "longaxe", "mod_wuxia/config/wx_weapons.nut", "七尺铁木长杆配狭长蛾眉月牙斧刃，后排跨格一击碎盾。"),
    (22, 6, "wx_wpn_axe_07", "2_weapons", "百兵图谱 · 斧钺拳爪", "镇边玄铁长柯重钺", "斧钺 T4 · 官军斩将大钺", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_axe_07.png", "bardiche", "mod_wuxia/config/wx_weapons.nut", "长刃沿杆下延固定的重型破阵大钺，劈砍威力冠绝军阵。"),
    (22, 7, "wx_wpn_axe_08", "2_weapons", "百兵图谱 · 斧钺拳爪", "关外蛮骨重铁巨斧", "斧钺 T4 · 北境战帮凶斧", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_axe_08.png", "heavy_rusty_axe", "mod_wuxia/config/wx_weapons.nut", "粗犷生铁巨刃绑缚凶兽獠牙骨饰的关外战帮巨斧，蛮力透甲。"),
    (22, 8, "wx_wpn_fist_04", "2_weapons", "拳掌护手兵装", "浸油老牛皮铆钉护腕", "拳掌 T1 · 成对锁副手（4AP）", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_fist_04.png", "unarmed_01.png", "mod_wuxia/config/wx_weapons.nut", "厚实熟牛皮镶扁平铁泡钉的成对拳师护腕，硬接刀剑不伤手腕。"),
    (22, 9, "wx_wpn_fist_05", "2_weapons", "拳掌护手兵装", "熟铜兽首碎骨指虎", "拳掌 T2 · 成对锁副手（4AP）", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_fist_05.png", "unarmed_01.png", "mod_wuxia/config/wx_weapons.nut", "黄铜精铸咆哮虎首护指环，寸劲重拳可隔着棉甲震裂胸骨。"),
    (22, 10, "wx_wpn_fist_06", "2_weapons", "拳掌护手兵装", "唐门三钩精铁鹰爪", "拳掌 T2 · 成对锁副手（4AP）", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_fist_06.png", "unarmed_01.png", "mod_wuxia/config/wx_weapons.nut", "手背延伸三道弯钩钢爪的成对奇门利爪，专擅擒龙撕脉与夺刃。"),
    (22, 11, "wx_wpn_fist_07", "2_weapons", "拳掌护手兵装", "罗汉堂百炼铜箍护手", "拳掌 T3 · 成对锁副手（4AP）", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_fist_07.png", "unarmed_01.png", "mod_wuxia/config/wx_weapons.nut", "每只穿套五枚沉重熟铜铁环的少室武僧护手，双拳挥动金铁雷鸣。"),
    (22, 12, "wx_wpn_fist_08", "2_weapons", "拳掌护手兵装", "黑道淬毒狼牙铁拳套", "拳掌 T3 · 成对锁副手（4AP）", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_fist_08.png", "unarmed_01.png", "mod_wuxia/config/wx_weapons.nut", "乌黑铁甲拳面焊接幽绿毒刺的凶狠拳套，拳风过处皮开毒入。"),
    (22, 13, "wx_wpn_fist_09", "2_weapons", "拳掌护手兵装", "峨眉白银分水刺护手", "拳掌 T3 · 成对锁副手（4AP）", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_fist_09.png", "unarmed_01.png", "mod_wuxia/config/wx_weapons.nut", "轻灵银钢护腕中指旋转双锋峨眉分水刺，贴身点穴断脉无声无息。"),
    (22, 14, "wx_wpn_flail_01", "2_weapons", "百兵图谱 · 奇门弓弩", "绿林双链铁刺连枷", "软兵 T2 · 无视盾防连枷", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_flail_01.png", "flail", "mod_wuxia/config/wx_weapons.nut", "铁链悬吊两枚带刺生铁锤球的单手连枷，越过藤牌铁盾直砸天灵。"),
    (22, 15, "wx_wpn_flail_02", "2_weapons", "百兵图谱 · 奇门弓弩", "边关双手重铁扫子枷", "软兵 T3 · 双手狂扫重连枷", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_flail_02.png", "two_handed_flail", "mod_wuxia/config/wx_weapons.nut", "长木杆铁链拖曳巨型棱铁重棒的守城重连枷，抡圆横扫人仰盾翻。"),

    # ==========================================================================
    # Sheet 23: 4 Whips/Odd + 6 Daggers + 6 Bows & Crossbows
    # ==========================================================================
    (23, 0, "wx_wpn_whip_01", "2_weapons", "百兵图谱 · 奇门弓弩", "浸油牛皮牧马长鞭", "软鞭 T1 · 两格抽击缴械鞭", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_whip_01.png", "battle_whip", "mod_wuxia/config/wx_weapons.nut", "四股生牛皮浸桐油编织的塞外长鞭，鞭梢炸响可隔步卷落敌兵。"),
    (23, 1, "wx_wpn_whip_02", "2_weapons", "百兵图谱 · 奇门弓弩", "江湖精铁七节鞭", "软鞭 T2 · 锁喉绕盾铁软鞭", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_whip_02.png", "battle_whip", "mod_wuxia/config/wx_weapons.nut", "七截精铁圆柱配响环连缀的随身奇门软鞭，收放自如绕盾锁喉。"),
    (23, 2, "wx_wpn_whip_03", "2_weapons", "百兵图谱 · 奇门弓弩", "乌钢倒刺九节龙鞭", "软鞭 T3 · 撕裂缴械重软鞭", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_whip_03.png", "battle_whip", "mod_wuxia/config/wx_weapons.nut", "鞭节密生细倒刺、顶端配破甲锥头的九节重钢鞭，沾身便扯落血肉。"),
    (23, 3, "wx_wpn_whip_04", "2_weapons", "百兵图谱 · 奇门弓弩", "内廷铁链血滴子", "软鞭 T4 · 诡道索首奇门器", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_whip_04.png", "three_headed_flail", "mod_wuxia/config/wx_weapons.nut", "长铁链操控内藏机簧环刃的精铜镂空索命笼罩，专取首级惊骇敌胆。"),
    (23, 4, "wx_wpn_dagger_01", "2_weapons", "百兵图谱 · 奇门弓弩", "猎户剥皮小尖刀", "短匕 T0 · 贴身快刺小刀", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_dagger_01.png", "knife", "mod_wuxia/config/wx_weapons.nut", "鹿角柄粗铁剥皮尖刀，行囊常备亦可在贴身肉搏时捅刺甲缝。"),
    (23, 5, "wx_wpn_dagger_02", "2_weapons", "百兵图谱 · 奇门弓弩", "水陆绿林牛耳尖刀", "短匕 T1 · 江湖靴筒暗藏匕", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_dagger_02.png", "dagger", "mod_wuxia/config/wx_weapons.nut", "刀尖上翘形似牛耳的宽腹短刀，好汉靴筒贴身暗藏防身利刃。"),
    (23, 6, "wx_wpn_dagger_03", "2_weapons", "百兵图谱 · 奇门弓弩", "寒铁三棱透甲锥匕", "短匕 T2 · 专刺甲缝破甲匕", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_dagger_03.png", "rondel_dagger", "mod_wuxia/config/wx_weapons.nut", "厚实圆盘护手配三棱放血槽钢刺，无视重铠专挑腋窝脖颈扎入。"),
    (23, 7, "wx_wpn_dagger_04", "2_weapons", "百兵图谱 · 奇门弓弩", "水上漂精钢分水刺", "短匕 T2 · 翻江水匪奇门匕", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_dagger_04.png", "rondel_dagger", "mod_wuxia/config/wx_weapons.nut", "护指铁环配双刃棱形尖刺的水路奇兵，水陆近战格架反刺极快。"),
    (23, 8, "wx_wpn_dagger_05", "2_weapons", "百兵图谱 · 奇门弓弩", "西域寒月处决弯匕", "短匕 T3 · 失衡重创凶匕", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_dagger_05.png", "qatal_dagger", "mod_wuxia/config/wx_weapons.nut", "错银兽纹把手的深弧度西域刺客弯匕，趁敌失衡点穴之际连刺绝命。"),
    (23, 9, "wx_wpn_dagger_06", "2_weapons", "百兵图谱 · 奇门弓弩", "五毒青磷蛇形短剑", "短匕 T3 · 奇毒蚀脉怪匕", "weapon140_plain", "ui/items/weapons/melee/wx_wpn_dagger_06.png", "qatal_dagger", "mod_wuxia/config/wx_weapons.nut", "曲折如毒虺游走、刃槽常年浸渍碧磷蛇毒的南疆阴毒短兵。"),
    (23, 10, "wx_wpn_bow_01", "2_weapons", "百兵图谱 · 奇门弓弩", "山野桑木猎户短弓", "弓弩 T1 · 轻便游猎短弓", "weapon140_plain", "ui/items/weapons/ranged/wx_wpn_bow_01.png", "short_bow", "mod_wuxia/config/wx_weapons.nut", "山桑木配麻弦制成的猎户轻弓，射速轻快宜林间游斗。"),
    (23, 11, "wx_wpn_bow_02", "2_weapons", "百兵图谱 · 奇门弓弩", "塞外牛角桦皮筋弓", "弓弩 T2 · 马贼复合骑弓", "weapon140_plain", "ui/items/weapons/ranged/wx_wpn_bow_02.png", "hunting_bow", "mod_wuxia/config/wx_weapons.nut", "水牛角片、牛背筋与白桦树皮胶合的反曲强弓，弓小力沉。"),
    (23, 12, "wx_wpn_bow_03", "2_weapons", "百兵图谱 · 奇门弓弩", "边关九石铁胎大弓", "弓弩 T3 · 远程贯甲重战弓", "weapon140_plain", "ui/items/weapons/ranged/wx_wpn_bow_03.png", "war_bow", "mod_wuxia/config/wx_weapons.nut", "精钢夹胎配猛虎纹护弣的军中神射重弓，非臂力过人者不能开满。"),
    (23, 13, "wx_wpn_xbow_01", "2_weapons", "百兵图谱 · 奇门弓弩", "猎寨青竹药箭轻弩", "弓弩 T1 · 低门槛防身木弩", "weapon140_plain", "ui/items/weapons/ranged/wx_wpn_xbow_01.png", "light_crossbow", "mod_wuxia/config/wx_weapons.nut", "硬木弩臂配铜牙悬刀的轻便猎弩，未经苦练的学徒亦可稳稳射中。"),
    (23, 14, "wx_wpn_xbow_02", "2_weapons", "百兵图谱 · 奇门弓弩", "军镇神机踏张铁弩", "弓弩 T3 · 重型破甲劲弩", "weapon140_plain", "ui/items/weapons/ranged/wx_wpn_xbow_02.png", "heavy_crossbow", "mod_wuxia/config/wx_weapons.nut", "前端设精铁脚踏环、需全身腰腿合力上弦的破甲重弩，近射洞穿铁铠。"),
    (23, 15, "wx_wpn_xbow_03", "2_weapons", "百兵图谱 · 奇门弓弩", "蜀传机巧诸葛连珠弩", "弓弩 T3 · 木匣速射机簧弩", "weapon140_plain", "ui/items/weapons/ranged/wx_wpn_xbow_03.png", "crossbow", "mod_wuxia/config/wx_weapons.nut", "弩身上置十矢桐木箭匣，推拉机柄即可连珠激射压制敌阵。"),

    # ==========================================================================
    # Sheet 24: 4 Firearms/Tools + 12 Tiered Chinese Rattan/Iron/Bronze Shields
    # ==========================================================================
    (24, 0, "wx_wpn_gun_01", "2_weapons", "百兵图谱 · 火器与盾牌", "边军火绳单管手铳", "火器 T2 · 轰鸣震胆铅砂铳", "weapon140_plain", "ui/items/weapons/ranged/wx_wpn_gun_01.png", "handgonne", "mod_wuxia/config/wx_weapons.nut", "明末边军鸟嘴手铳式样，燃点药捻喷吐扇面铅砂与硝烟，动摇军心。"),
    (24, 1, "wx_wpn_gun_02", "2_weapons", "百兵图谱 · 火器与盾牌", "辽东神机三眼铁铳", "火器 T3 · 远射近砸两用铳", "weapon140_plain", "ui/items/weapons/ranged/wx_wpn_gun_02.png", "handgonne", "mod_wuxia/config/wx_weapons.nut", "三根粗厚熟铁铳管品字箍连，齐射轰击后更可倒转当重铁骨朵猛砸！"),
    (24, 2, "wx_wpn_throw_01", "2_weapons", "百兵图谱 · 火器与盾牌", "走镖飞蝗鹅卵石袋", "暗器 T1 · 眩晕打断投石囊", "weapon140_plain", "ui/items/weapons/ranged/wx_wpn_throw_01.png", "sling", "mod_wuxia/config/wx_weapons.nut", "粗牛皮囊满盛河滩精挑棱角铁胆石，运内劲甩掷专打面门眼眶。"),
    (24, 3, "wx_wpn_tool_01", "2_weapons", "百兵图谱 · 火器与盾牌", "南疆浸油牛筋捕兽网筒", "奇门副手 · 困敌定身网具", "item70", "ui/items/tools/wx_wpn_tool_01.png", "throwing_net", "mod_wuxia/config/wx_weapons.nut", "竹铜机筒弹射沉重铅坠牛筋大网，罩住高闪避刺客与凶兽使其寸步难行。"),
    (24, 4, "wx_shd_01", "2_weapons", "百兵图谱 · 火器与盾牌", "乡勇包铁榆木圆盾", "盾具 T1 · 基础步战木盾", "shield140_plain", "ui/items/shields/wx_shd_01.png", "wooden_shield", "mod_wuxia/config/wx_weapons.nut", "厚榆木板拼合外箍生铁圈与铁盾鼻的村镇护卫圆盾。"),
    (24, 5, "wx_shd_02", "2_weapons", "百兵图谱 · 火器与盾牌", "闽粤桐油老藤牌", "盾具 T2 · 轻灵防矢藤盾", "shield140_plain", "ui/items/shields/wx_shd_02.png", "buckler_shield", "mod_wuxia/config/wx_weapons.nut", "深山百年老白藤盘编并反复浸煮桐油的轻韧圆藤牌，内息负担极轻且善挡箭矢。"),
    (24, 6, "wx_shd_03", "2_weapons", "百兵图谱 · 火器与盾牌", "戚家军虎头彩绘藤牌", "盾具 T2 · 威慑刀盾兵标配", "shield140_plain", "ui/items/shields/wx_shd_03.png", "heater_shield", "mod_wuxia/config/wx_weapons.nut", "韧藤牌面浓墨重彩手绘怒目斑斓猛虎，矮身滚进专砍长枪马腿。"),
    (24, 7, "wx_shd_04", "2_weapons", "百兵图谱 · 火器与盾牌", "威远镖局铆钉铁边盾", "盾具 T2 · 走镖护车坚盾", "shield140_plain", "ui/items/shields/wx_shd_04.png", "heater_shield", "mod_wuxia/config/wx_weapons.nut", "双层硬木蒙黑牛皮并密钉精铁泡钉的镖局重圆盾，稳守镖车阵线。"),
    (24, 8, "wx_shd_05", "2_weapons", "百兵图谱 · 火器与盾牌", "百炼乌钢护心圆盾", "盾具 T3 · 高耐久精铁手盾", "shield140_plain", "ui/items/shields/wx_shd_05.png", "kite_shield", "mod_wuxia/config/wx_weapons.nut", "整块百炼乌钢锻压成型的微拱铁圆盾，硬抗重斧不易崩裂。"),
    (24, 9, "wx_shd_06", "2_weapons", "百兵图谱 · 火器与盾牌", "藩镇吞兽熟铜团牌", "盾具 T3 · 官军刀牌都头盾", "shield140_plain", "ui/items/shields/wx_shd_06.png", "kite_shield", "mod_wuxia/config/wx_weapons.nut", "边缘内凹便于出刀窥敌、正中浮雕狰狞铜兽面的藩镇精锐重盾。"),
    (24, 10, "wx_shd_07", "2_weapons", "百兵图谱 · 火器与盾牌", "军阵窥窗步兵立盾", "盾具 T3 · 防弩重型大橹盾", "shield140_plain", "ui/items/shields/wx_shd_07.png", "kite_shield", "mod_wuxia/config/wx_weapons.nut", "包铁长方形厚重军阵大盾，留有横条窥视孔，顶着强弩火铳推进如墙。"),
    (24, 11, "wx_shd_08", "2_weapons", "百兵图谱 · 火器与盾牌", "前朝镇墓饕餮绿锈铜盾", "盾具 T3 · 古墓尸卫重铜盾", "shield140_plain", "ui/items/shields/wx_shd_08.png", "ancient_shield", "mod_wuxia/config/wx_weapons.nut", "布满苍翠千年铜绿、高浮雕上古饕餮纹的沉重青铜古盾。"),
    (24, 12, "wx_shd_09", "2_weapons", "百兵图谱 · 火器与盾牌", "西域错金弯月铁盾", "盾具 T3 · 奇门锁刃缺口盾", "shield140_plain", "ui/items/shields/wx_shd_09.png", "sipar_shield", "mod_wuxia/config/wx_weapons.nut", "左侧留有月牙缺口便于架锁敌方长兵的西域几何铜纹圆盾。"),
    (24, 13, "wx_shd_10", "2_weapons", "百兵图谱 · 火器与盾牌", "玄门八卦黄铜圆盾", "盾具 T3 · 卸力反震内家盾", "shield140_plain", "ui/items/shields/wx_shd_10.png", "sipar_shield", "mod_wuxia/config/wx_weapons.nut", "打磨微凸的厚黄铜圆盾，借弧面滑开劈砍劲力。"),
    (24, 14, "wx_shd_11", "2_weapons", "百兵图谱 · 火器与盾牌", "五毒青鳞尖刺铁盾", "盾具 T3 · 撞击放血奇门盾", "shield140_plain", "ui/items/shields/wx_shd_11.png", "orc_heavy_shield", "mod_wuxia/config/wx_weapons.nut", "覆满碧绿巨蟒鳞甲、外圈焊死八根破血钢刺的南疆凶盾。"),
    (24, 15, "wx_shd_12", "2_weapons", "百兵图谱 · 火器与盾牌", "禁军盘龙鎏金重盾", "盾具 T4 · 传世级御前金盾", "shield140_famed", "ui/items/shields/wx_shd_12.png", "named_shield", "mod_wuxia/config/wx_weapons.nut", "椭圆形乌钢胎体高浮雕升云金龙的殿前宿卫重盾，固若金汤。"),

    # ==========================================================================
    # Sheet 25: 16 East-Asian Base Character Heads (3/4 Left Paperdoll Layer!)
    # ==========================================================================
    (25, 0, "wx_head_01", "3_characters", "千人千面 · 东方面孔基底", "俊朗剑眉少侠面", "纸娃娃面孔 01 · 青年正派", "paperdoll_head", "entity/bodies/wx_head_01.png", "head_01", "mod_wuxia/config/wx_appearance.nut", "剑眉星目、轮廓清隽坚毅的东土青年少侠面庞。"),
    (25, 1, "wx_head_02", "3_characters", "千人千面 · 东方面孔基底", "方颐阔口壮汉面", "纸娃娃面孔 02 · 豪侠猛士", "paperdoll_head", "entity/bodies/wx_head_02.png", "head_02", "mod_wuxia/config/wx_appearance.nut", "下颌方正有力、神色沉稳刚毅的中年豪侠面庞。"),
    (25, 2, "wx_head_03", "3_characters", "千人千面 · 东方面孔基底", "独眼纵疤悍匪面", "纸娃娃面孔 03 · 刀口余生", "paperdoll_head", "entity/bodies/wx_head_03.png", "head_03", "mod_wuxia/config/wx_appearance.nut", "左眼泛白失明并留有狰狞贯目刀疤的百战狠辣武夫面庞。"),
    (25, 3, "wx_head_04", "3_characters", "千人千面 · 东方面孔基底", "饱经风霜老镖头面", "纸娃娃面孔 04 · 江湖宿老", "paperdoll_head", "entity/bodies/wx_head_04.png", "head_04", "mod_wuxia/config/wx_appearance.nut", "额纹深镌如刀刻、眼神老辣审慎的走南闯北老江湖面庞。"),
    (25, 4, "wx_head_05", "3_characters", "千人千面 · 东方面孔基底", "白面清冷儒生面", "纸娃娃面孔 05 · 寒门书剑", "paperdoll_head", "entity/bodies/wx_head_05.png", "head_05", "mod_wuxia/config/wx_appearance.nut", "肤色白皙、鼻梁修直、神情清冷内敛的书生剑客面庞。"),
    (25, 5, "wx_head_06", "3_characters", "千人千面 · 东方面孔基底", "高颧古铜塞外汉面", "纸娃娃面孔 06 · 朔漠风沙", "paperdoll_head", "entity/bodies/wx_head_06.png", "head_06", "mod_wuxia/config/wx_appearance.nut", "大漠烈日风沙磨砺出红铜肤色与高耸颧骨的塞外汉子面庞。"),
    (25, 6, "wx_head_07", "3_characters", "千人千面 · 东方面孔基底", "鹰钩鼻阴鸷刺客面", "纸娃娃面孔 07 · 诡道暗桩", "paperdoll_head", "entity/bodies/wx_head_07.png", "head_07", "mod_wuxia/config/wx_appearance.nut", "两颊深陷、鼻若鹰钩、眼窝幽暗如毒蛇伺猎的夜行人面庞。"),
    (25, 7, "wx_head_08", "3_characters", "千人千面 · 东方面孔基底", "慈眉善目老衲面", "纸娃娃面孔 08 · 佛门禅者", "paperdoll_head", "entity/bodies/wx_head_08.png", "head_08", "mod_wuxia/config/wx_appearance.nut", "双耳垂肩、含笑微眯却暗藏金刚定力的古刹老僧面庞。"),
    (25, 8, "wx_head_09", "3_characters", "千人千面 · 东方面孔基底", "清癯孤高道骨面", "纸娃娃面孔 09 · 玄门清修", "paperdoll_head", "entity/bodies/wx_head_09.png", "head_09", "mod_wuxia/config/wx_appearance.nut", "颧瘦下颌微长、气度超然物外的山野清修羽士面庞。"),
    (25, 9, "wx_head_10", "3_characters", "千人千面 · 东方面孔基底", "黝黑敦厚庄稼汉面", "纸娃娃面孔 10 · 苦力把式", "paperdoll_head", "entity/bodies/wx_head_10.png", "head_10", "mod_wuxia/config/wx_appearance.nut", "浓眉塌鼻、皮肤黝黑粗糙、憨直耐劳的农夫脚夫面庞。"),
    (25, 10, "wx_head_11", "3_characters", "千人千面 · 东方面孔基底", "酒糟红鼻醉侠面", "纸娃娃面孔 11 · 落拓浪子", "paperdoll_head", "entity/bodies/wx_head_11.png", "head_11", "mod_wuxia/config/wx_appearance.nut", "鼻头双颊微醺泛红、嘴角噙着三分戏谑笑意的市井酒徒面庞。"),
    (25, 11, "wx_head_12", "3_characters", "千人千面 · 东方面孔基底", "拧眉横肉恶霸面", "纸娃娃面孔 12 · 黑道凶徒", "paperdoll_head", "entity/bodies/wx_head_12.png", "head_12", "mod_wuxia/config/wx_appearance.nut", "眉骨凸起紧锁、满脸横肉凶相毕露的屠户恶霸面庞。"),
    (25, 12, "wx_head_13", "3_characters", "千人千面 · 东方面孔基底", "丹凤狭目冷探面", "纸娃娃面孔 13 · 官府鹰犬", "paperdoll_head", "entity/bodies/wx_head_13.png", "head_13", "mod_wuxia/config/wx_appearance.nut", "细长凌厉上挑丹凤眼、薄唇紧抿不苟言笑的密探高手面庞。"),
    (25, 13, "wx_head_14", "3_characters", "千人千面 · 东方面孔基底", "惨青病容试毒师面", "纸娃娃面孔 14 · 南疆药蛊", "paperdoll_head", "entity/bodies/wx_head_14.png", "head_14", "mod_wuxia/config/wx_appearance.nut", "长年以身试蛊导致眼圈青黑、肤泛黄绿病气的毒谷怪杰面庞。"),
    (25, 14, "wx_head_15", "3_characters", "千人千面 · 东方面孔基底", "浓眉国字威严将面", "纸娃娃面孔 15 · 统帅宿将", "paperdoll_head", "entity/bodies/wx_head_15.png", "head_15", "mod_wuxia/config/wx_appearance.nut", "卧蚕浓眉、堂堂国字重颐、不怒自威的边关宿将面庞。"),
    (25, 15, "wx_head_16", "3_characters", "千人千面 · 东方面孔基底", "枯槁灰白邪修面", "纸娃娃面孔 16 · 练魔伤脉", "paperdoll_head", "entity/bodies/wx_head_16.png", "head_16", "mod_wuxia/config/wx_appearance.nut", "强练奇诡魔功致骨瘦如柴、瞳仁惨白无血色的老魔头面庞。"),

    # ==========================================================================
    # Sheet 26: 8 Modular Hairstyles + 8 Modular Beards (Flipped to 3/4 Left!)
    # ==========================================================================
    (26, 0, "wx_hair_01", "3_characters", "千人千面 · 发髻与胡须", "红绳劲武高马尾", "模块化发式 01 · 少侠劲装", "paperdoll_hair", "entity/bodies/wx_hair_01.png", "hair_01", "mod_wuxia/config/wx_appearance.nut", "乌黑长发以朱红麻绳高束脑后，干练飒爽。"),
    (26, 1, "wx_hair_02", "3_characters", "千人千面 · 发髻与胡须", "狂放披肩乱散发", "模块化发式 02 · 浪客狂刀", "paperdoll_hair", "entity/bodies/wx_hair_02.png", "hair_02", "mod_wuxia/config/wx_appearance.nut", "不羁披散至肩颈的墨黑乱发，额前碎绺随刀风飘动。"),
    (26, 2, "wx_hair_03", "3_characters", "千人千面 · 发髻与胡须", "斑白道家高挽髻", "模块化发式 03 · 宗师耆宿", "paperdoll_hair", "entity/bodies/wx_hair_03.png", "hair_03", "mod_wuxia/config/wx_appearance.nut", "两鬓霜白、头顶端庄盘挽的子午高发髻。"),
    (26, 3, "wx_hair_04", "3_characters", "千人千面 · 发髻与胡须", "头陀铁箍落发式", "模块化发式 04 · 破戒武僧", "paperdoll_hair", "entity/bodies/wx_hair_04.png", "hair_04", "mod_wuxia/config/wx_appearance.nut", "头顶剃光、两侧留硬茬短鬓并箍铆钉黑铁圈的行者发式。"),
    (26, 4, "wx_hair_05", "3_characters", "千人千面 · 发髻与胡须", "兽骨横簪浪人髻", "模块化发式 05 · 山野游侠", "paperdoll_hair", "entity/bodies/wx_hair_05.png", "hair_05", "mod_wuxia/config/wx_appearance.nut", "苍白兽骨长簪横贯乌发圆髻，两缕龙须刘海垂颊。"),
    (26, 5, "wx_hair_06", "3_characters", "千人千面 · 发髻与胡须", "塞外铜环多股辫", "模块化发式 06 · 关外胡风", "paperdoll_hair", "entity/bodies/wx_hair_06.png", "hair_06", "mod_wuxia/config/wx_appearance.nut", "两侧青皮微剃、编结多股紧实长辫并束铜箍的北疆胡骑发式。"),
    (26, 6, "wx_hair_07", "3_characters", "千人千面 · 发髻与胡须", "青布束髻书生发", "模块化发式 07 · 市井儒生", "paperdoll_hair", "entity/bodies/wx_hair_07.png", "hair_07", "mod_wuxia/config/wx_appearance.nut", "齐整梳拢并以靛青粗布包裹顶髻的寒士发式。"),
    (26, 7, "wx_hair_08", "3_characters", "千人千面 · 发髻与胡须", "草绳蓬乱乞儿发", "模块化发式 08 · 丐帮流民", "paperdoll_hair", "entity/bodies/wx_hair_08.png", "hair_08", "mod_wuxia/config/wx_appearance.nut", "枯黄草绳随意捆扎的蓬松褐黑乱发，风尘仆仆。"),
    (26, 8, "wx_beard_01", "3_characters", "千人千面 · 发髻与胡须", "关圣垂胸美髯须", "模块化胡须 01 · 义薄云天", "paperdoll_beard", "entity/bodies/wx_beard_01.png", "beard_01", "mod_wuxia/config/wx_appearance.nut", "乌黑油亮、顺垂胸前的修长三绺美髯，威重凛然。"),
    (26, 9, "wx_beard_02", "3_characters", "千人千面 · 发髻与胡须", "虬髯豪客张扬须", "模块化胡须 02 · 草莽雄杰", "paperdoll_beard", "entity/bodies/wx_beard_02.png", "beard_02", "mod_wuxia/config/wx_appearance.nut", "八字上翘、满腮怒张如戟刺的风尘虬髯。"),
    (26, 10, "wx_beard_03", "3_characters", "千人千面 · 发髻与胡须", "精明账房山羊须", "模块化胡须 03 · 师爷奇士", "paperdoll_beard", "entity/bodies/wx_beard_03.png", "beard_03", "mod_wuxia/config/wx_appearance.nut", "细长下垂八字胡配尖翘山羊胡，透出三分精明算计。"),
    (26, 11, "wx_beard_04", "3_characters", "千人千面 · 发髻与胡须", "西域浓密卷曲须", "模块化胡须 04 · 胡商刀客", "paperdoll_beard", "entity/bodies/wx_beard_04.png", "beard_04", "mod_wuxia/config/wx_appearance.nut", "深褐浓密、呈细卷团簇状的西域胡人满腮大胡。"),
    (26, 12, "wx_beard_05", "3_characters", "千人千面 · 发髻与胡须", "仙风霜白长寿须", "模块化胡须 05 · 白发宗师", "paperdoll_beard", "entity/bodies/wx_beard_05.png", "beard_05", "mod_wuxia/config/wx_appearance.nut", "如银丝霜雪般飘洒颔下的老剑仙苍白长须。"),
    (26, 13, "wx_beard_06", "3_characters", "千人千面 · 发髻与胡须", "铜箍双股铁辫须", "模块化胡须 06 · 塞外重装", "paperdoll_beard", "entity/bodies/wx_beard_06.png", "beard_06", "mod_wuxia/config/wx_appearance.nut", "灰黑浓须编成粗壮战辫并以黄铜环箍紧，防止近战被扯。"),
    (26, 14, "wx_beard_07", "3_characters", "千人千面 · 发髻与胡须", "青黑沧桑短胡茬", "模块化胡须 07 · 独行刀客", "paperdoll_beard", "entity/bodies/wx_beard_07.png", "beard_07", "mod_wuxia/config/wx_appearance.nut", "沿下颌与唇周密布的硬刺短胡茬，冷峻干练。"),
    (26, 15, "wx_beard_08", "3_characters", "千人千面 · 发髻与胡须", "连鬓恶虎钢针须", "模块化胡须 08 · 屠户悍卒", "paperdoll_beard", "entity/bodies/wx_beard_08.png", "beard_08", "mod_wuxia/config/wx_appearance.nut", "下巴净刮而两侧腮帮怒立钢针般黑鬓毛的悍勇须式。"),

    # ==========================================================================
    # Sheet 27: 16 Civilian & Martial Sect Hats / Crowns / Hoods
    # ==========================================================================
    (27, 0, "wx_hat_01", "3_characters", "千人千面 · 市井门派冠巾", "伙夫靛青包头布巾", "轻装冠巾 01 · 店伴趟子手", "paperdoll_hat", "ui/items/helmets/wx_hat_01.png", "headscarf", "mod_wuxia/config/wx_appearance.nut", "耐脏靛青粗棉布层层缠裹额头的市井伙计头巾。"),
    (27, 1, "wx_hat_02", "3_characters", "千人千面 · 市井门派冠巾", "庄稼汉毛边遮阳草帽", "轻装冠巾 02 · 田间农夫", "paperdoll_hat", "ui/items/helmets/wx_hat_02.png", "straw_hat", "mod_wuxia/config/wx_appearance.nut", "金黄麦秆手工粗编、帽檐散毛的田舍遮阳草帽。"),
    (27, 2, "wx_hat_03", "3_characters", "千人千面 · 市井门派冠巾", "江南桐油竹骨雨笠", "轻装冠巾 03 · 渡口舟子", "paperdoll_hat", "ui/items/helmets/wx_hat_03.png", "straw_hat", "mod_wuxia/config/wx_appearance.nut", "竹骨撑起深褐油布圆檐的江南防雨笠帽。"),
    (27, 3, "wx_hat_04", "3_characters", "千人千面 · 市井门派冠巾", "关外狐毛护耳暖帽", "轻装冠巾 04 · 北境猎户", "paperdoll_hat", "ui/items/helmets/wx_hat_04.png", "fur_hat", "mod_wuxia/config/wx_appearance.nut", "熟牛皮缝制、翻卷厚实灰褐狐狸毛护耳的关外御寒皮帽。"),
    (27, 4, "wx_hat_05", "3_characters", "千人千面 · 市井门派冠巾", "掌柜六瓣瓜皮小帽", "轻装冠巾 05 · 商贾账房", "paperdoll_hat", "ui/items/helmets/wx_hat_05.png", "feathered_hat", "mod_wuxia/config/wx_appearance.nut", "玄黑绸面六瓣缝合、顶缀一颗黄铜小算珠的城镇账房小帽。"),
    (27, 5, "wx_hat_06", "3_characters", "千人千面 · 市井门派冠巾", "寒儒青布东坡幅巾", "轻装冠巾 06 · 游方书生", "paperdoll_hat", "ui/items/helmets/wx_hat_06.png", "headscarf", "mod_wuxia/config/wx_appearance.nut", "折角方正、后垂双带的士子文人青灰幅巾。"),
    (27, 6, "wx_hat_07", "3_characters", "千人千面 · 市井门派冠巾", "青苍竹篾尖顶斗笠", "轻装冠巾 07 · 独行刀客", "paperdoll_hat", "ui/items/helmets/wx_hat_07.png", "hood", "mod_wuxia/config/wx_appearance.nut", "斜风细雨不须归的尖顶青竹篾斗笠，压低帽檐遮住半张冷面。"),
    (27, 7, "wx_hat_08", "3_characters", "千人千面 · 市井门派冠巾", "幽冥玄布蒙面风帽", "轻装冠巾 08 · 刺客夜行人", "paperdoll_hat", "ui/items/helmets/wx_hat_08.png", "assassin_mask", "mod_wuxia/config/wx_appearance.nut", "墨黑软布兜帽连体面罩，仅露一双森寒杀机双目。"),
    (27, 8, "wx_hat_09", "3_characters", "千人千面 · 市井门派冠巾", "太和紫金八卦道冠", "门派冠巾 09 · 玄门高功", "paperdoll_hat", "ui/items/helmets/wx_hat_09.png", "cultist_hood", "mod_wuxia/config/wx_appearance.nut", "紫铜鎏金镌刻先天八卦纹的庄严高道冠，横插如意铜簪。"),
    (27, 9, "wx_hat_10", "3_characters", "千人千面 · 市井门派冠巾", "古刹绛红五佛毗卢冠", "门派冠巾 10 · 禅宗高僧", "paperdoll_hat", "ui/items/helmets/wx_hat_10.png", "mitre", "mod_wuxia/config/wx_appearance.nut", "五片莲瓣状绛红织金冠叶高耸的佛门法会宝冠。"),
    (27, 10, "wx_hat_11", "3_characters", "千人千面 · 市井门派冠巾", "峨眉素雪镶蓝风帽", "门派冠巾 11 · 清修剑派", "paperdoll_hat", "ui/items/helmets/wx_hat_11.png", "hood", "mod_wuxia/config/wx_appearance.nut", "素白细麻滚浅靛蓝布边的清雅风帽，纤尘不染。"),
    (27, 11, "wx_hat_12", "3_characters", "千人千面 · 市井门派冠巾", "清风云纹嵌玉抹额", "门派冠巾 12 · 名门少侠", "paperdoll_hat", "ui/items/helmets/wx_hat_12.png", "headband", "mod_wuxia/config/wx_appearance.nut", "天青暗花绸带正中镶嵌温润青白玉牌的少侠束额带。"),
    (27, 12, "wx_hat_13", "3_characters", "千人千面 · 市井门派冠巾", "丐帮五帝铜钱麻额箍", "门派冠巾 13 · 污衣净衣帮众", "paperdoll_hat", "ui/items/helmets/wx_hat_13.png", "headband", "mod_wuxia/config/wx_appearance.nut", "麻绳穿连五枚古旧方孔黄铜钱束于额前的豪爽额带。"),
    (27, 13, "wx_hat_14", "3_characters", "千人千面 · 市井门派冠巾", "蜀中机簧齿轮铁额箍", "门派冠巾 14 · 唐门机巧师", "paperdoll_hat", "ui/items/helmets/wx_hat_14.png", "headband", "mod_wuxia/config/wx_appearance.nut", "乌黑弹簧钢片嵌精密黄铜小齿轮的机巧门人护额箍。"),
    (27, 14, "wx_hat_15", "3_characters", "千人千面 · 市井门派冠巾", "南疆苗银新月流苏冠", "门派冠巾 15 · 五毒奇门", "paperdoll_hat", "ui/items/helmets/wx_hat_15.png", "southern_head_wrap", "mod_wuxia/config/wx_appearance.nut", "白银锻打新月牛角配细密蝶花银链流苏的南疆奇冠。"),
    (27, 15, "wx_hat_16", "3_characters", "千人千面 · 市井门派冠巾", "昆仑银鼠毛白玉抹额", "门派冠巾 16 · 西域雪山派", "paperdoll_hat", "ui/items/helmets/wx_hat_16.png", "headband", "mod_wuxia/config/wx_appearance.nut", "灰白雪貂皮滚边、正面嵌冰裂纹流云玉饰的雪山剑客抹额。"),

    # ==========================================================================
    # Sheet 28: 16 Outlaw Masks & Historical Chinese War-Helmets
    # ==========================================================================
    (28, 0, "wx_hat_17", "3_characters", "千人千面 · 面具与历代战胄", "黑铁獠牙夜叉半面具", "凶煞面具 17 · 黑道杀手", "paperdoll_hat", "ui/items/helmets/wx_hat_17.png", "fang_helmet", "mod_wuxia/config/wx_appearance.nut", "生铁锻出狰狞外翻獠牙的下半脸护颌鬼面，夜袭摄人心魄。"),
    (28, 1, "wx_hat_18", "3_characters", "千人千面 · 面具与历代战胄", "哭丧青铜兰陵全脸面", "凶煞面具 18 · 破阵诡面", "paperdoll_hat", "ui/items/helmets/wx_hat_18.png", "ancient_helmet", "mod_wuxia/config/wx_appearance.nut", "眼角铸有凄厉铜绿泪痕的覆面青铜战面，刀箭难伤面门。"),
    (28, 2, "wx_hat_19", "3_characters", "千人千面 · 面具与历代战胄", "朔北苍狼吞首皮兜", "蛮荒头罩 19 · 关外战帮", "paperdoll_hat", "ui/items/helmets/wx_hat_19.png", "wolf_helmet", "mod_wuxia/config/wx_appearance.nut", "整张巨型塞外苍狼头皮硝制而成，白森森狼牙垂于额前。"),
    (28, 3, "wx_hat_20", "3_characters", "千人千面 · 面具与历代战胄", "西域缠巾锁子护颈盔", "中装战盔 20 · 丝路胡骑", "paperdoll_hat", "ui/items/helmets/wx_hat_20.png", "turban_helmet", "mod_wuxia/config/wx_appearance.nut", "精钢圆盔外缠黄麻布巾，下垂细密铁环锁子顿项护住咽喉。"),
    (28, 4, "wx_hat_21", "3_characters", "千人千面 · 面具与历代战胄", "苦行精铁铆钉戒箍", "轻装铁箍 21 · 横练行者", "paperdoll_hat", "ui/items/helmets/wx_hat_21.png", "headband", "mod_wuxia/config/wx_appearance.nut", "十斤重乌铁锻打的宽厚护额铁箍，配合铜头铁额硬抗钝击。"),
    (28, 5, "wx_hat_22", "3_characters", "千人千面 · 面具与历代战胄", "荒野铁刺血果荆棘冠", "奇诡头饰 22 · 苦修邪道", "paperdoll_hat", "ui/items/helmets/wx_hat_22.png", "witchhunter_hat", "mod_wuxia/config/wx_appearance.nut", "枯黑铁棘藤盘绕暗红毒莓编成的山泽怪杰头环。"),
    (28, 6, "wx_hat_23", "3_characters", "千人千面 · 面具与历代战胄", "前朝绿锈护鼻覆面铜胄", "重装古胄 23 · 王陵古墓甲", "paperdoll_hat", "ui/items/helmets/wx_hat_23.png", "ancient_household_helmet", "mod_wuxia/config/wx_appearance.nut", "斑驳铜绿包裹整张面庞的上古青铜重胄，仅留幽深T字眼缝。"),
    (28, 7, "wx_hat_24", "3_characters", "千人千面 · 面具与历代战胄", "湘西麻绳披孝尖风帽", "邪道头罩 24 · 哭丧赶尸派", "paperdoll_hat", "ui/items/helmets/wx_hat_24.png", "cultist_leather_hood", "mod_wuxia/config/wx_appearance.nut", "惨白粗麻丧布缝制并以黑麻绳捆额的诡异高尖帽。"),
    (28, 8, "wx_hat_25", "3_characters", "千人千面 · 面具与历代战胄", "大宋红缨精铁笠子盔", "中装战盔 25 · 禁军步卒", "paperdoll_hat", "ui/items/helmets/wx_hat_25.png", "kettle_hat", "mod_wuxia/config/wx_appearance.nut", "宽檐防矢铁盔顶飘绛红马尾盔缨，两侧铆钉铁护颊严密护颈。"),
    (28, 9, "wx_hat_26", "3_characters", "千人千面 · 面具与历代战胄", "明军黑漆宽檐铁军笠", "中装战盔 26 · 边墩夜不收", "paperdoll_hat", "ui/items/helmets/wx_hat_26.png", "padded_kettle_hat", "mod_wuxia/config/wx_appearance.nut", "黑漆防锈宽檐生铁笠帽配朱红颔绳，防坠石流矢视野开阔。"),
    (28, 10, "wx_hat_27", "3_characters", "千人千面 · 面具与历代战胄", "唐风鎏金眉庇护鼻重盔", "重装战胄 27 · 藩镇牙兵", "paperdoll_hat", "ui/items/helmets/wx_hat_27.png", "nasal_helmet_with_mail", "mod_wuxia/config/wx_appearance.nut", "精钢圆钵盔额镶鎏金卷云眉庇与护鼻铁条，垂朱漆铁札顿项。"),
    (28, 11, "wx_hat_28", "3_characters", "千人千面 · 面具与历代战胄", "边镇尖顶铁札兜鍪", "重装战胄 28 · 北庭重骑", "paperdoll_hat", "ui/items/helmets/wx_hat_28.png", "nordic_helmet", "mod_wuxia/config/wx_appearance.nut", "圆锥形滑开重锤劈砍的尖顶钢盔，四层玄铁甲片严护后颈。"),
    (28, 12, "wx_hat_29", "3_characters", "千人千面 · 面具与历代战胄", "铁浮屠冷锻全覆铁面胄", "极重战胄 29 · 重甲铁塔", "paperdoll_hat", "ui/items/helmets/wx_hat_29.png", "full_helm", "mod_wuxia/config/wx_appearance.nut", "铆死厚重钢铁护面、仅露双目窄缝的破阵重骑铁塔巨盔！"),
    (28, 13, "wx_hat_30", "3_characters", "千人千面 · 面具与历代战胄", "内府鎏金盘龙双翼铁冠", "官军名胄 30 · 镇抚指挥使", "paperdoll_hat", "ui/items/helmets/wx_hat_30.png", "barbute_helmet", "mod_wuxia/config/wx_appearance.nut", "乌纱铁胎额嵌金龙戏珠，两侧斜耸锋锐金翎双翼的朝廷重臣战冠。"),
    (28, 14, "wx_hat_31", "3_characters", "千人千面 · 面具与历代战胄", "神机营棉衬熟铁护耳盔", "中装战盔 31 · 火器重步", "paperdoll_hat", "ui/items/helmets/wx_hat_31.png", "padded_nasal_helmet", "mod_wuxia/config/wx_appearance.nut", "内衬厚实棉毡隔绝火铳震耳轰鸣的熟铁铆钉护耳军盔。"),
    (28, 15, "wx_hat_32", "3_characters", "千人千面 · 面具与历代战胄", "节度使金龙吞脊帅字胄", "极重帅胄 32 · 镇国大将军", "paperdoll_hat", "ui/items/helmets/wx_hat_32.png", "named_full_helm", "mod_wuxia/config/wx_appearance.nut", "盔脊昂首盘踞纯金怒龙、配鎏金护面与赤红长缨的大帅传世宝胄。"),

    # ==========================================================================
    # Sheet 29: 12 Civilian/Trade Clothes + 4 Righteous Sect Robes (Headless 3/4 Left!)
    # ==========================================================================
    (29, 0, "wx_body_civ_01", "3_characters", "千人千面 · 市井百业衣衫", "庄稼汉草绳褐麻短褐", "市井衣衫 01 · 农夫苦力", "armor140_plain", "ui/items/armor/wx_body_civ_01.png", "sackcloth", "mod_wuxia/config/wx_appearance.nut", "粗粝耐磨的无袖黄褐麻布短衣，腰间紧紧缠绕两道稻草麻绳。"),
    (29, 1, "wx_body_civ_02", "3_characters", "千人千面 · 市井百业衣衫", "铁匠焦痕厚牛皮围裙装", "市井衣衫 02 · 锻炉匠人", "armor140_plain", "ui/items/armor/wx_body_civ_02.png", "butcher_apron", "mod_wuxia/config/wx_appearance.nut", "炭灰麻衫外罩布满火星烙痕的加厚熟牛皮铁匠大围裙，自带防护。"),
    (29, 2, "wx_body_civ_03", "3_characters", "千人千面 · 市井百业衣衫", "屠户暗血油皮护胸装", "市井衣衫 03 · 市井屠夫", "armor140_plain", "ui/items/armor/wx_body_civ_03.png", "butcher_apron", "mod_wuxia/config/wx_appearance.nut", "浸满陈年猪牛血渍的硬油皮护胸围裙，腰带斜挂一枚寒铁挂肉钩。"),
    (29, 3, "wx_body_civ_04", "3_characters", "千人千面 · 市井百业衣衫", "老渔翁芦苇披领补丁褂", "市井衣衫 04 · 江河渔夫", "armor140_plain", "ui/items/armor/wx_body_civ_04.png", "linen_tunic", "mod_wuxia/config/wx_appearance.nut", "洗得发白的蓝布补丁褂外披一圈防浪芦苇草编短披领。"),
    (29, 4, "wx_body_civ_05", "3_characters", "千人千面 · 市井百业衣衫", "矿工铆皮护肩粗帆衣", "市井衣衫 05 · 采矿苦力", "armor140_plain", "ui/items/armor/wx_body_civ_05.png", "thick_tunic", "mod_wuxia/config/wx_appearance.nut", "双肩缝死厚硬牛皮垫肩以防碎石背篓磨损的灰褐粗帆布工衣。"),
    (29, 5, "wx_body_civ_06", "3_characters", "千人千面 · 市井百业衣衫", "游方郎中青布百草囊衫", "市井衣衫 06 · 悬壶医者", "armor140_plain", "ui/items/armor/wx_body_civ_06.png", "linen_tunic", "mod_wuxia/config/wx_appearance.nut", "温和松青棉布交领衫，腰间布带悬着三四只鼓囊囊的药材小布袋。"),
    (29, 6, "wx_body_civ_07", "3_characters", "千人千面 · 市井百业衣衫", "算命先生回纹补丁布袍", "市井衣衫 07 · 江湖术士", "armor140_plain", "ui/items/armor/wx_body_civ_07.png", "monk_robe", "mod_wuxia/config/wx_appearance.nut", "灰蓝陈旧宽袖布衫，交领织有褪色回纹，肘部缀着两块粗布补丁。"),
    (29, 7, "wx_body_civ_08", "3_characters", "千人千面 · 市井百业衣衫", "码头脚夫搭肩白汗巾褂", "市井衣衫 08 · 挑夫力士", "armor140_plain", "ui/items/armor/wx_body_civ_08.png", "cloth_tunic", "mod_wuxia/config/wx_appearance.nut", "汗渍斑斑的对襟无袖黑布马甲，脖颈随手搭着一条擦汗粗白布巾。"),
    (29, 8, "wx_body_civ_09", "3_characters", "千人千面 · 市井百业衣衫", "深山猎户金钱豹皮坎肩", "市井衣衫 09 · 山林猎手", "armor140_plain", "ui/items/armor/wx_body_civ_09.png", "leather_wraps", "mod_wuxia/config/wx_appearance.nut", "暗绿麻衣外披硝制野金钱豹皮背心，皮毛柔韧保暖且防荆棘兽爪。"),
    (29, 9, "wx_body_civ_10", "3_characters", "千人千面 · 市井百业衣衫", "塞外马夫翻毛老羊皮袄", "市井衣衫 10 · 牧马边民", "armor140_plain", "ui/items/armor/wx_body_civ_10.png", "goat_skin", "mod_wuxia/config/wx_appearance.nut", "翻露出暖白羊毛内里的粗犷羊皮无袖坎肩，牛角扣束胸。"),
    (29, 10, "wx_body_civ_11", "3_characters", "千人千面 · 市井百业衣衫", "落第寒儒洗白皂边澜衫", "市井衣衫 11 · 穷酸秀才", "armor140_plain", "ui/items/armor/wx_body_civ_11.png", "noble_tunic", "mod_wuxia/config/wx_appearance.nut", "浆洗得微微泛白却衣冠端正的灰白交领儒衫，镶皂黑领缘。"),
    (29, 11, "wx_body_civ_12", "3_characters", "千人千面 · 市井百业衣衫", "江湖戏班绛红武生劲装", "市井衣衫 12 · 卖艺武师", "armor140_plain", "ui/items/armor/wx_body_civ_12.png", "padded_surcoat", "mod_wuxia/config/wx_appearance.nut", "立领盘扣绛红窄袖武生短打，配黑皮护腕与黄铜宽板带，身手矫健。"),
    (29, 12, "wx_body_sect_01", "3_characters", "千人千面 · 门派帮会袍服", "少室武僧杏黄交领僧衣", "门派袍服 01 · 佛门正宗", "armor140_plain", "ui/items/armor/wx_body_sect_01.png", "monk_robe", "mod_wuxia/config/wx_appearance.nut", "古朴杏黄粗棉武僧短袍，深褐布带紧束丹田，拳脚施展毫无滞碍。"),
    (29, 13, "wx_body_sect_02", "3_characters", "千人千面 · 门派帮会袍服", "太和紫霄飞鹤阴阳道袍", "门派袍服 02 · 道门正宗", "armor140_plain", "ui/items/armor/wx_body_sect_02.png", "monk_robe", "mod_wuxia/config/wx_appearance.nut", "沉静靛蓝道袍袖领暗绣白鹤流云，腰系碧玉阴阳太极扣。"),
    (29, 14, "wx_body_sect_03", "3_characters", "千人千面 · 门派帮会袍服", "清风剑派竹青云领剑衫", "门派袍服 03 · 潇洒剑宗", "armor140_plain", "ui/items/armor/wx_body_sect_03.png", "noble_tunic", "mod_wuxia/config/wx_appearance.nut", "竹青配素白双层交领剑客劲衫，领缘银丝织就回云暗纹。"),
    (29, 15, "wx_body_sect_04", "3_characters", "千人千面 · 门派帮会袍服", "华岳紫霞暗云丝绸劲袍", "门派袍服 04 · 关中名门", "armor140_plain", "ui/items/armor/wx_body_sect_04.png", "noble_tunic", "mod_wuxia/config/wx_appearance.nut", "低饱和暗紫熟罗劲袍配云锦宽束腰，透出世家剑派清贵气象。"),

    # ==========================================================================
    # Sheet 30: 12 Sect Robes + 4 Light Martial Leather Armors (Headless 3/4 Left!)
    # ==========================================================================
    (30, 0, "wx_body_sect_05", "3_characters", "千人千面 · 门派帮会袍服", "丐帮九袋麻绳百结战衣", "门派袍服 05 · 天下第一帮", "armor140_plain", "ui/items/armor/wx_body_sect_05.png", "ragged_surcoat", "mod_wuxia/config/wx_appearance.nut", "各色粗麻补丁密密缝缀的丐帮长老战衣，粗麻绳悬袋豪气干云。"),
    (30, 1, "wx_body_sect_06", "3_characters", "千人千面 · 门派帮会袍服", "蜀中唐门机袖毒囊劲装", "门派袍服 06 · 暗器世家", "armor140_plain", "ui/items/armor/wx_body_sect_06.png", "leather_tunic", "mod_wuxia/config/wx_appearance.nut", "靛黑紧身劲装双臂套接黄铜袖箭护臂，胸前斜挎一排精钢飞镖管。"),
    (30, 2, "wx_body_sect_07", "3_characters", "千人千面 · 门派帮会袍服", "峨眉金顶月白水田剑衣", "门派袍服 07 · 蜀山清派", "armor140_plain", "ui/items/armor/wx_body_sect_07.png", "linen_tunic", "mod_wuxia/config/wx_appearance.nut", "月白与豆青布帛拼接如水田格纹的轻灵剑衣，绑腿束腕利落非常。"),
    (30, 3, "wx_body_sect_08", "3_characters", "千人千面 · 门派帮会袍服", "昆仑寒玉白狐领劲袍", "门派袍服 08 · 西昆仑派", "armor140_plain", "ui/items/armor/wx_body_sect_08.png", "padded_leather", "mod_wuxia/config/wx_appearance.nut", "苍蓝厚绒交领武服肩覆蓬松雪白狐裘大领，傲立昆仑绝顶寒风。"),
    (30, 4, "wx_body_sect_09", "3_characters", "千人千面 · 门派帮会袍服", "血煞魔宗赤黑铆钉皮衣", "门派袍服 09 · 黑道魔门", "armor140_plain", "ui/items/armor/wx_body_sect_09.png", "studded_leather", "mod_wuxia/config/wx_appearance.nut", "黑牛皮衬暗红血槽滚边、密镶寒铁铆钉的邪派杀手无袖皮甲衣。"),
    (30, 5, "wx_body_sect_10", "3_characters", "千人千面 · 门派帮会袍服", "无常鬼市飞刀夜行黑衣", "门派袍服 10 · 暗夜死士", "armor140_plain", "ui/items/armor/wx_body_sect_10.png", "assassin_robe", "mod_wuxia/config/wx_appearance.nut", "哑光墨黑夜行劲衣，胸前十字皮带倒插两柄随时暴起的柳叶飞刀。"),
    (30, 6, "wx_body_sect_11", "3_characters", "千人千面 · 门派帮会袍服", "云梦泽青鲨鱼鳞水靠", "门派袍服 11 · 大泽水寨", "armor140_plain", "ui/items/armor/wx_body_sect_11.png", "leather_lamellar", "mod_wuxia/config/wx_appearance.nut", "水滑灰绿大鱼皮压印细鳞纹缝制的贴身水靠，入水不濡滑开刀锋。"),
    (30, 7, "wx_body_sect_12", "3_characters", "千人千面 · 门派帮会袍服", "东海沧溟帮盘绳海客衣", "门派袍服 12 · 海寇巨帮", "armor140_plain", "ui/items/armor/wx_body_sect_12.png", "thick_tunic", "mod_wuxia/config/wx_appearance.nut", "海盐侵蚀的深蓝厚帆布海船短衣，胸前斜缠坚韧登船粗麻缆绳。"),
    (30, 8, "wx_body_sect_13", "3_characters", "千人千面 · 门派帮会袍服", "西域圣火暗纹绯红锦袍", "门派袍服 13 · 波斯明尊教", "armor140_plain", "ui/items/armor/wx_body_sect_13.png", "southern_tunic", "mod_wuxia/config/wx_appearance.nut", "绛红织锦满绣升腾圣火暗纹的西域武学名门立领劲袍。"),
    (30, 9, "wx_body_sect_14", "3_characters", "千人千面 · 门派帮会袍服", "大雪山绛红氆氇偏袒僧披", "门派袍服 14 · 密宗番僧", "armor140_plain", "ui/items/armor/wx_body_sect_14.png", "monk_robe", "mod_wuxia/config/wx_appearance.nut", "厚重暗绛红藏绒氆氇斜披肩头并扣黄铜戒环的雪域金刚僧衣。"),
    (30, 10, "wx_body_sect_15", "3_characters", "千人千面 · 门派帮会袍服", "药王谷苍翠悬葫采药袍", "门派袍服 15 · 医毒双绝", "armor140_plain", "ui/items/armor/wx_body_sect_15.png", "linen_tunic", "mod_wuxia/config/wx_appearance.nut", "深山松针绿棉麻宽袍，麻绳腰带垂挂一只装满灵丹的油亮药葫芦。"),
    (30, 11, "wx_body_sect_16", "3_characters", "千人千面 · 门派帮会袍服", "天机阁铜星罗盘玄披衫", "门派袍服 16 · 奇门军师", "armor140_plain", "ui/items/armor/wx_body_sect_16.png", "wizard_robe", "mod_wuxia/config/wx_appearance.nut", "玄灰立领披肩长衫，胸前镇有一枚八角精铜占星罗盘徽章。"),
    (30, 12, "wx_body_arm_01", "3_characters", "千人千面 · 江湖轻中皮铁甲", "威远镖局护胸黑革趟子甲", "轻装皮甲 01 · 镖师精锐", "armor140_plain", "ui/items/armor/wx_body_arm_01.png", "padded_leather", "mod_wuxia/config/wx_appearance.nut", "玄黑劲装外挂一整块黄铜泡钉熟牛皮护心板，走镖挡箭实用首选。"),
    (30, 13, "wx_body_arm_02", "3_characters", "千人千面 · 江湖轻中皮铁甲", "绿林水磨硬牛皮柳叶札甲", "轻装皮甲 02 · 山寨头目", "armor140_plain", "ui/items/armor/wx_body_arm_02.png", "leather_lamellar", "mod_wuxia/config/wx_appearance.nut", "数百片桐油反复浸泡压硬的深褐牛皮甲札编缀，轻便耐劈砍。"),
    (30, 14, "wx_body_arm_03", "3_characters", "千人千面 · 江湖轻中皮铁甲", "朔漠白骨扣双层生牛皮甲", "轻装皮甲 03 · 塞外游骑", "armor140_plain", "ui/items/armor/wx_body_arm_03.png", "worn_mail_shirt", "mod_wuxia/config/wx_appearance.nut", "未经染色的粗厚双层野牛皮胸甲，胸前三道兽骨大搭扣锁紧。"),
    (30, 15, "wx_body_arm_04", "3_characters", "千人千面 · 江湖轻中皮铁甲", "大宋步人漆皮披膊熟革甲", "中装皮甲 04 · 官军步卒", "armor140_plain", "ui/items/armor/wx_body_arm_04.png", "basic_mail_shirt", "mod_wuxia/config/wx_appearance.nut", "烤硬大漆熟牛皮配叠片护肩披膊的军中制式步兵皮铠。"),

    # ==========================================================================
    # Sheet 31: 6 Light/Medium Martial Armors + 10 Heavy Chinese Lamellar/Plate Armors
    # ==========================================================================
    (31, 0, "wx_body_arm_05", "3_characters", "千人千面 · 江湖轻中皮铁甲", "南诏浸油老藤编织胸铠", "轻装奇甲 05 · 刀箭难入轻甲", "armor140_plain", "ui/items/armor/wx_body_arm_05.png", "leather_scale", "mod_wuxia/config/wx_appearance.nut", "采哀牢山老藤经油浸晒干十余遍编成的藤甲，轻若无物专契轻功卸力（惧烈火）。"),
    (31, 1, "wx_body_arm_06", "3_characters", "千人千面 · 江湖轻中皮铁甲", "边关夜不收苍狼皮锁子甲", "中装锁甲 06 · 斥候游侠", "armor140_plain", "ui/items/armor/wx_body_arm_06.png", "mail_shirt", "mod_wuxia/config/wx_appearance.nut", "细密精铁锁子甲衫肩披整张灰白苍狼毛皮，兼顾机动与防割。"),
    (31, 2, "wx_body_arm_07", "3_characters", "千人千面 · 江湖轻中皮铁甲", "九边军镇绛红铜钉棉铁甲", "中装棉甲 07 · 明军战兵", "armor140_plain", "ui/items/armor/wx_body_arm_07.png", "footman_armor", "mod_wuxia/config/wx_appearance.nut", "内衬暗铁甲叶与多层丝绵、外覆朱红绒面并钉满黄铜泡钉的明代布面铁甲。"),
    (31, 3, "wx_body_arm_08", "3_characters", "千人千面 · 江湖轻中皮铁甲", "神机营防火铁胸黑革罩甲", "中装铁甲 08 · 火铳卫队", "armor140_plain", "ui/items/armor/wx_body_arm_08.png", "reinforced_mail_hauberk", "mod_wuxia/config/wx_appearance.nut", "防火星引燃的厚黑革外衣正胸铆接四块精铁护板。"),
    (31, 4, "wx_body_arm_09", "3_characters", "千人千面 · 江湖轻中皮铁甲", "靖海楼水师青蛟皮软鳞甲", "轻装宝甲 09 · 水陆精锐", "armor140_plain", "ui/items/armor/wx_body_arm_09.png", "light_scale_armor", "mod_wuxia/config/wx_appearance.nut", "深海巨鲨与水蛟厚皮裁成鱼鳞甲片并扣黄铜盘扣的贴身轻软甲。"),
    (31, 5, "wx_body_arm_10", "3_characters", "千人千面 · 江湖轻中皮铁甲", "桃花传世金丝软猬倒刺甲", "内穿奇甲 10 · 反伤防抓内甲", "armor140_plain", "ui/items/armor/wx_body_arm_10.png", "noble_mail_armor", "mod_wuxia/config/wx_appearance.nut", "金铁细丝混编并密布锋利倒刺的贴身内甲，刀剑难损且令徒手擒拿者自伤！"),
    (31, 6, "wx_body_hvy_01", "3_characters", "千人千面 · 历代铁札重铠", "百炼精钢鱼鳞护心重甲", "重装铁铠 01 · 武将主力甲", "armor140_plain", "ui/items/armor/wx_body_hvy_01.png", "scale_armor", "mod_wuxia/config/wx_appearance.nut", "数百枚弧形精钢鱼鳞甲片层叠密编，走动间金鳞闪烁坚不可摧。"),
    (31, 7, "wx_body_hvy_02", "3_characters", "千人千面 · 历代铁札重铠", "盛唐遗制双圆护心镜明光铠", "重装铁铠 02 · 名将威仪铠", "armor140_plain", "ui/items/armor/wx_body_hvy_02.png", "lamellar_harness", "mod_wuxia/config/wx_appearance.nut", "胸前左、右对称镶嵌两面打磨如镜精钢圆护心宝镜，朱红绦绳十字束甲。"),
    (31, 8, "wx_body_hvy_03", "3_characters", "千人千面 · 历代铁札重铠", "武经总要宋制步人重铁札甲", "重装铁铠 03 · 步战抗骑神铠", "armor140_plain", "ui/items/armor/wx_body_hvy_03.png", "heavy_lamellar_armor", "mod_wuxia/config/wx_appearance.nut", "由一千八百余片冷锻长方黑铁甲叶以皮条穿缀而成的五十斤重步人甲！"),
    (31, 9, "wx_body_hvy_04", "3_characters", "千人千面 · 历代铁札重铠", "北庭冷锻叠板铁浮屠重铠", "重装铁铠 04 · 重装横练毕业铠", "armor140_plain", "ui/items/armor/wx_body_hvy_04.png", "coat_of_plates", "mod_wuxia/config/wx_appearance.nut", "宽幅冷锻黑钢胸板与层叠铁披膊严丝合缝，唯有重锤破甲锥方能撼动。"),
    (31, 10, "wx_body_hvy_05", "3_characters", "千人千面 · 历代铁札重铠", "关外黑貂领连环铁镜重甲", "重装铁铠 05 · 辽金重甲骑将", "armor140_plain", "ui/items/armor/wx_body_hvy_05.png", "heavy_iron_armor", "mod_wuxia/config/wx_appearance.nut", "浓密黑熊貂毛大领下覆双层铁环锁子与竖排精铁甲板，御寒防箭两绝。"),
    (31, 11, "wx_body_hvy_06", "3_characters", "千人千面 · 历代铁札重铠", "镇国大将黄金吞兽鱼鳞帅铠", "重装铁铠 06 · 节度使统帅金甲", "armor140_famed", "ui/items/armor/wx_body_hvy_06.png", "coat_of_scales", "mod_wuxia/config/wx_appearance.nut", "通体鎏金百炼鳞甲，双肩及腹吞铸咆哮雄狮金首，统帅三军威震沙场。"),
    (31, 12, "wx_body_hvy_07", "3_characters", "千人千面 · 历代铁札重铠", "少室金刚乌金巨铆横练重铠", "重装铁铠 07 · 外家横练神装", "armor140_plain", "ui/items/armor/wx_body_hvy_07.png", "coat_of_plates", "mod_wuxia/config/wx_appearance.nut", "哑光乌金玄铁厚板敲入拳头大生铁铆钉，非天生神力兼修《铁布衫》者难穿。"),
    (31, 13, "wx_body_hvy_08", "3_characters", "千人千面 · 历代铁札重铠", "前朝地宫铜绿饕餮镇陵古铠", "重装铁铠 08 · 王陵出土古铜甲", "armor140_plain", "ui/items/armor/wx_body_hvy_08.png", "ancient_plate_harness", "mod_wuxia/config/wx_appearance.nut", "满布斑驳碧绿古锈、胸腹高浮雕狰狞饕餮鬼面的商周秦汉镇陵重铜铠。"),
    (31, 14, "wx_body_hvy_09", "3_characters", "千人千面 · 历代铁札重铠", "黑道霸主尖刺锁链黑铁重甲", "重装铁铠 09 · 邪派巨寇凶甲", "armor140_plain", "ui/items/armor/wx_body_hvy_09.png", "reinforced_animal_hide_armor", "mod_wuxia/config/wx_appearance.nut", "刀痕交错的黑铁胸铠斜缠碗口粗锈蚀铁链，双肩耸立破血钢刺。"),
    (31, 15, "wx_body_hvy_10", "3_characters", "千人千面 · 历代铁札重铠", "葱岭大食旋纹镔铁明镜重铠", "重装铁铠 10 · 西域传世钢铠", "armor140_plain", "ui/items/armor/wx_body_hvy_10.png", "southern_heavy_plate", "mod_wuxia/config/wx_appearance.nut", "一整块流淌水波云纹的西域大马士革镔铁锻成胸铠，坚韧轻灵远胜凡铁。"),

    # ==========================================================================
    # Sheet 32: 16 Modular Cloaks, Back-Scabbards, Gourds, Baskets & War-Banners
    # ==========================================================================
    (32, 0, "wx_back_01", "3_characters", "千人千面 · 披风背匣与挂件", "残血猩红大将披风", "背饰披挂 01 · 宿将威风斗篷", "paperdoll_back", "ui/items/accessory/wx_back_01.png", "neck_cloak", "mod_wuxia/config/wx_appearance.nut", "下摆被刀剑劈成锯齿残缕的暗红战将大斗篷，胸扣双兽黄铜链。"),
    (32, 1, "wx_back_02", "3_characters", "千人千面 · 披风背匣与挂件", "夜鸦墨黑破边短披风", "背饰披挂 02 · 轻功刺客披挂", "paperdoll_back", "ui/items/accessory/wx_back_02.png", "neck_cloak", "mod_wuxia/config/wx_appearance.nut", "融入暗夜阴影的鸦羽状破边黑布披风，疾行如鬼魅掠影。"),
    (32, 2, "wx_back_03", "3_characters", "千人千面 · 披风背匣与挂件", "塞外雪狼厚毛护肩大氅", "背饰披挂 03 · 关外豪侠毛领", "paperdoll_back", "ui/items/accessory/wx_back_03.png", "wolf_pelt", "mod_wuxia/config/wx_appearance.nut", "整张灰白苍狼厚绒巨皮缝制的披肩大氅，狼骨铁链横锁胸前。"),
    (32, 3, "wx_back_04", "3_characters", "千人千面 · 披风背匣与挂件", "背负铜角沉香古木剑匣", "背饰披挂 04 · 剑痴藏锋重匣", "paperdoll_back", "ui/items/accessory/wx_back_04.png", "quiver", "mod_wuxia/config/wx_appearance.nut", "黄铜包角老榆木长剑匣斜背肩后，内藏不轻易出鞘的传世名剑。"),
    (32, 4, "wx_back_05", "3_characters", "千人千面 · 披风背匣与挂件", "背后十字双雁翎刀鞘", "背饰披挂 05 · 双刀豪客背挂", "paperdoll_back", "ui/items/accessory/wx_back_05.png", "quiver", "mod_wuxia/config/wx_appearance.nut", "牛皮十字背带交叉固定两具包铁乌木刀鞘，尽显江湖快刀客本色。"),
    (32, 5, "wx_back_06", "3_characters", "千人千面 · 披风背匣与挂件", "朱漆红绳老酒大葫芦", "背饰披挂 06 · 醉拳浪客随身物", "paperdoll_back", "ui/items/accessory/wx_back_06.png", "waterskin", "mod_wuxia/config/wx_appearance.nut", "盛满十斤烧刀子烈酒的油润朱红大葫芦，粗红麻绳绾结悬腰。"),
    (32, 6, "wx_back_07", "3_characters", "千人千面 · 披风背匣与挂件", "神农百草青竹采药背篓", "背饰披挂 07 · 郎中药师背具", "paperdoll_back", "ui/items/accessory/wx_back_07.png", "bag", "mod_wuxia/config/wx_appearance.nut", "细篾编结的采药竹背篓，满满塞着灵芝老参、晒干草药与医书卷轴。"),
    (32, 7, "wx_back_08", "3_characters", "千人千面 · 披风背匣与挂件", "威远走镖黑底金纹小令旗", "背饰披挂 08 · 镖头趟子手背旗", "paperdoll_back", "ui/items/accessory/wx_back_08.png", "banner", "mod_wuxia/config/wx_appearance.nut", "插于后腰皮套的锯齿边黑底黄字走镖三角令旗，绿林借道凭证。"),
    (32, 8, "wx_back_09", "3_characters", "千人千面 · 披风背匣与挂件", "节度镇军四面护背大靠旗", "背饰披挂 09 · 统帅武将靠旗", "paperdoll_back", "ui/items/accessory/wx_back_09.png", "banner", "mod_wuxia/config/wx_appearance.nut", "精铁背座斜插四面迎风猎猎作响的绛红将门三角护背靠旗，军心中枢标志！"),
    (32, 9, "wx_back_10", "3_characters", "千人千面 · 披风背匣与挂件", "千机百宝牛皮暗器腰肩囊", "背饰披挂 10 · 奇门暗器行囊", "paperdoll_back", "ui/items/accessory/wx_back_10.png", "ammo_bag", "mod_wuxia/config/wx_appearance.nut", "十字武装皮带密布十余只独立小皮匣，分装毒针、铁蒺藜与雷火弹。"),
    (32, 10, "wx_back_11", "3_characters", "千人千面 · 披风背匣与挂件", "少室百八颗碗口紫檀念珠", "背饰披挂 11 · 苦行花和尚挂珠", "paperdoll_back", "ui/items/accessory/wx_back_11.png", "necklace", "mod_wuxia/config/wx_appearance.nut", "每颗皆如核桃大小、沉甸甸斜挂胸背的老紫檀木大念珠串。"),
    (32, 11, "wx_back_12", "3_characters", "千人千面 · 披风背匣与挂件", "朱砂红线百枚古铜钱辟邪剑", "背饰披挂 12 · 捉妖道士背器", "paperdoll_back", "ui/items/accessory/wx_back_12.png", "charm", "mod_wuxia/config/wx_appearance.nut", "历代五铢通宝铜钱以浸鸡血朱砂红绳紧编而成的道门镇尸法剑。"),
    (32, 12, "wx_back_13", "3_characters", "千人千面 · 披风背匣与挂件", "寒江棕草防雨护肩蓑披", "背饰披挂 13 · 江湖风雪行装", "paperdoll_back", "ui/items/accessory/wx_back_13.png", "neck_cloak", "mod_wuxia/config/wx_appearance.nut", "老棕榈叶与蓑草层叠密编的护肩雨披，风雪江湖路不湿衣甲。"),
    (32, 13, "wx_back_14", "3_characters", "千人千面 · 披风背匣与挂件", "吊睛白额猛虎皮英雄披肩", "背饰披挂 14 · 打虎寨主霸气披挂", "paperdoll_back", "ui/items/accessory/wx_back_14.png", "hyena_fur", "mod_wuxia/config/wx_appearance.nut", "整张斑斓华南猛虎皮斜披肩背，带爪虎掌垂于胸前霸气绝伦！"),
    (32, 14, "wx_back_15", "3_characters", "千人千面 · 披风背匣与挂件", "铁算盘神算子乌金腰挂", "背饰披挂 15 · 商帮奇侠兵挂", "paperdoll_back", "ui/items/accessory/wx_back_15.png", "charm", "mod_wuxia/config/wx_appearance.nut", "铁链悬腰的生铁框架乌金珠算盘，既算天下钱粮亦可拨打点穴。"),
    (32, 15, "wx_back_16", "3_characters", "千人千面 · 披风背匣与挂件", "铜箍油皮山川舆图背筒", "背饰披挂 16 · 堪舆斥候行具", "paperdoll_back", "ui/items/accessory/wx_back_16.png", "scroll", "mod_wuxia/config/wx_appearance.nut", "两端黄铜密封防水的熟牛皮圆画筒，内藏山海秘境舆图与秘籍古卷。"),

    # ==========================================================================
    # Sheet 33: 16 Distinct Jianghu Human / Mutant / Undead Enemy Busts (3/4 Left!)
    # ==========================================================================
    (33, 0, "wx_enemy_bandit_lord", "3_characters", "江湖六大阵营敌首立绘", "绿林独眼虎皮大寨主", "绿林山寨 · 头目立绘 (Bandit Leader)", "bust_flip", "entity/enemies/wx_enemy_bandit_lord.png", "bandit_leader", "mod_wuxia/config/wx_ecology.nut", "独眼刀疤、披斑斓猛虎皮内衬乌铁札甲的连云十八寨总瓢把子。"),
    (33, 1, "wx_enemy_nomad_khan", "3_characters", "江湖六大阵营敌首立绘", "黑水塞外马贼大当家", "塞外马贼 · 头目立绘 (Nomad Leader)", "bust_flip", "entity/enemies/wx_enemy_nomad_khan.png", "nomad_leader", "mod_wuxia/config/wx_ecology.nut", "戴白狼头铁盔、双肩耸立弯牛角的塞外响马头领，凶悍善骑射弯刀。"),
    (33, 2, "wx_enemy_garrison_capt", "3_characters", "江湖六大阵营敌首立绘", "地方藩镇持戟铁甲都头", "藩镇官军 · 军官立绘 (Sergeant)", "bust_flip", "entity/enemies/wx_enemy_garrison_capt.png", "sergeant", "mod_wuxia/config/wx_ecology.nut", "红缨重盔、身披冷锻步人铁甲背负方耳长戟的节度使麾下精锐都头。"),
    (33, 3, "wx_enemy_shenji_officer", "3_characters", "江湖六大阵营敌首立绘", "神机营硝烟火铳百户", "世家官军 · 火器军官 (Gunner)", "bust_flip", "entity/enemies/wx_enemy_shenji_officer.png", "gunner", "mod_wuxia/config/wx_ecology.nut", "宽檐铁笠、面染火药黑烟、身着铜钉防火罩甲的朝廷神机营百户。"),
    (33, 4, "wx_enemy_sword_saint", "3_characters", "江湖六大阵营敌首立绘", "退隐白眉绝顶老剑宿", "江湖名宿 · 宗师立绘 (Swordmaster)", "bust_flip", "entity/enemies/wx_enemy_sword_saint.png", "swordmaster", "mod_wuxia/config/wx_ecology.nut", "长眉入鬓、一袭粗麻灰衣返璞归真却近防高绝的江湖顶尖老剑客。"),
    (33, 5, "wx_enemy_hedge_general", "3_characters", "江湖六大阵营敌首立绘", "沙场脱籍独行披甲悍将", "江湖悍将 · 重装立绘 (Hedge Knight)", "bust_flip", "entity/enemies/wx_enemy_hedge_general.png", "hedge_knight", "mod_wuxia/config/wx_ecology.nut", "满面创疤、身披刀痕累累重钢板甲独行江湖的百战猛将。"),
    (33, 6, "wx_enemy_blade_dancer", "3_characters", "江湖六大阵营敌首立绘", "西域绯巾双刃舞剑宗师", "西域奇人 · 高闪立绘 (Blade Dancer)", "bust_flip", "entity/enemies/wx_enemy_blade_dancer.png", "blade_dancer", "mod_wuxia/config/wx_ecology.nut", "绯红丝巾蒙面、背插双弯刀、身法诡快如旋风的葱岭剑舞宗师。"),
    (33, 7, "wx_enemy_wudu_shaman", "3_characters", "江湖六大阵营敌首立绘", "南疆百足兜帽吹箭蛊师", "五毒奇门 · 毒师立绘 (Goblin Shaman)", "bust", "entity/enemies/wx_enemy_wudu_shaman.png", "goblin_shaman", "mod_wuxia/config/wx_ecology.nut", "额绣金蜈蚣黑兜帽、胸挂一排剧毒竹吹筒的五毒教控蛊长老。"),
    (33, 8, "wx_enemy_wudu_overseer", "3_characters", "江湖六大阵营敌首立绘", "五毒教青铜鬼面督主", "五毒奇门 · 督阵首领 (Goblin Overseer)", "bust_flip", "entity/enemies/wx_enemy_wudu_overseer.png", "goblin_leader", "mod_wuxia/config/wx_ecology.nut", "戴诡异绿锈青铜面具、披碧绿蟒鳞披风压阵指挥的五毒分坛督主。"),
    (33, 9, "wx_enemy_barb_chosen", "3_characters", "江湖六大阵营敌首立绘", "关外黑熊皮碎骨重兵誓卫", "关外战帮 · 狂暴重卫 (Chosen)", "bust_flip", "entity/enemies/wx_enemy_barb_chosen.png", "barbarian_chosen", "mod_wuxia/config/wx_ecology.nut", "头顶咆哮巨熊皮、肩绑巨兽骨刺甲的关外铁骑死士重卫。"),
    (33, 10, "wx_enemy_barb_drummer", "3_characters", "江湖六大阵营敌首立绘", "关外赤膊狼图腾催战力士", "关外战帮 · 战鼓中枢 (Drummer)", "bust_flip", "entity/enemies/wx_enemy_barb_drummer.png", "barbarian_drummer", "mod_wuxia/config/wx_ecology.nut", "赤裸上身刺满苍狼战纹、双腕套玄铁重箍擂鼓催动全军回气的猛汉。"),
    (33, 11, "wx_enemy_yaoren_lord", "3_characters", "江湖六大阵营敌首立绘", "铁箍锁链炼体药人巨擘", "邪派药人 · 霸主立绘 (Orc Warlord)", "bust_flip", "entity/enemies/wx_enemy_yaoren_lord.png", "orc_warlord", "mod_wuxia/config/wx_ecology.nut", "暴起血管如虬龙、下颌钉铁齿箍、胸缠粗铁链撞碎盾墙的药人霸主！"),
    (33, 12, "wx_enemy_corpse_taoist", "3_characters", "江湖六大阵营敌首立绘", "湘西黄符竹笠控魂妖道", "湘西尸宗 · 驭尸邪道 (Necromancer)", "bust_flip", "entity/enemies/wx_enemy_corpse_taoist.png", "necromancer", "mod_wuxia/config/wx_ecology.nut", "戴垂落镇魂黄符破竹笠、面色死灰摇摄魂铃驱使铁尸狂攻的湘西妖道。"),
    (33, 13, "wx_enemy_tomb_wraith", "3_characters", "江湖六大阵营敌首立绘", "古冢披发惨白夺魄怨灵", "湘西尸宗 · 尖啸幽魂 (Geist)", "bust_flip", "entity/enemies/wx_enemy_tomb_wraith.png", "ghost", "mod_wuxia/config/wx_ecology.nut", "黑发凌空狂舞、张口发穿魂凄厉尖啸令侠客战意崩溃的千年怨魂。"),
    (33, 14, "wx_enemy_ancient_lord", "3_characters", "江湖六大阵营敌首立绘", "前朝幽瞳金龙胄镇陵尸王", "前朝古墓 · 镇陵霸主 (Ancient Honor Guard)", "bust_flip", "entity/enemies/wx_enemy_ancient_lord.png", "skeleton_heavy", "mod_wuxia/config/wx_ecology.nut", "眼窝燃幽青冥火、披鎏金双龙吞肩古铜铠的前朝不灭镇陵大将军。"),
    (33, 15, "wx_enemy_blood_vampire", "3_characters", "江湖六大阵营敌首立绘", "古墓裂瓷面赤衣血影剑魔", "古墓血魔 · 瞬移剑妖 (Necrosavant)", "bust_flip", "entity/enemies/wx_enemy_blood_vampire.png", "vampire", "mod_wuxia/config/wx_ecology.nut", "银发飞扬、戴碎裂白瓷古面具、化血雾瞬移斩杀后排的古墓千年剑魔。"),
]
