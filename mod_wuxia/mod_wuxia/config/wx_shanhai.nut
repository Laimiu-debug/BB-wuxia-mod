// Shan Hai Jing (《山海经》) Mythical Apex Bosses, Neidan Cores & Craftable Red Gear Registry
// All CustomBodySprite / CustomHeadSprite / CustomWorldBrush / CustomIcon fields default to null (vanilla placeholders)
// so standalone custom Shan Hai Jing artwork can be plugged in later without touching gameplay code!

::Wuxia.Config.ShanHaiBosses <- {
	boss_zhuyan = {
		Key = "zhuyan", BossID = "boss_zhuyan", Name = "【山海凶兽】小次山·朱厌猿王",
		EntityType = "UnholdFrost", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_zhuyan", ParentScript = "scripts/entity/tactical/enemies/unhold_frost_armored",
		HpMult = 1.45, MeleeSkillBonus = 10, MeleeDefBonus = 8, BraveryBonus = 40, Strength = 55,
		TraitName = "见则大兵·沸血狂猿", TraitDesc = "《西山经》凶猿之王：每回合活血自愈 25 气血（中毒或流血时减至 8 点）；气血低于六成时沸血狂暴，武艺 +12、总伤 +25% 且免眩晕缴械！",
		CoreID = "wx_core_zhuyan", LairID = "shanhai_zhuyan",
		CustomBodySprite = null, CustomHeadSprite = null
	},
	boss_feiyi = {
		Key = "feiyi", BossID = "boss_feiyi", Name = "【山海凶兽】太华山·六足肥遗王",
		EntityType = "Lindwurm", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_feiyi", ParentScript = "scripts/entity/tactical/enemies/lindwurm",
		HpMult = 1.35, MeleeSkillBonus = 8, MeleeDefBonus = 6, BraveryBonus = 50, Strength = 65,
		TraitName = "见则大旱·蚀甲旱火瘴", TraitDesc = "《西山经》太华毒蛟之王：周身 2 格弥漫赤旱毒热瘴气，每回合灼毁近身敌军 12 点身甲并蒸干 8 点内息，宜以两格长兵或劲弩讨伐！",
		CoreID = "wx_core_feiyi", LairID = "shanhai_feiyi",
		CustomBodySprite = null, CustomHeadSprite = null
	},
	boss_qiongqi = {
		Key = "qiongqi", BossID = "boss_qiongqi", Name = "【山海凶兽】邽山·裂风穷奇",
		EntityType = "Hyena", BaseTroop = "Hyena",
		Script = "scripts/entity/tactical/enemies/wx_boss_qiongqi", ParentScript = "scripts/entity/tactical/enemies/hyena_high",
		HpMult = 3.40, MeleeSkillBonus = 18, MeleeDefBonus = 14, BraveryBonus = 60, Strength = 52,
		TraitName = "惩善助恶·裂风噬喉", TraitDesc = "《北山经》四大凶兽之一：常驻 11 AP、身法暴涨，撕咬必致深创流血，且专噬高定力君子（目标定力≥65 时命中 +12、伤害 +15%）！",
		CoreID = "wx_core_qiongqi", LairID = "shanhai_qiongqi",
		CustomBodySprite = null, CustomHeadSprite = null
	},
	boss_taotie = {
		Key = "taotie", BossID = "boss_taotie", Name = "【山海凶兽】钩吾山·吞天饕餮王",
		EntityType = "Ghoul", BaseTroop = "Ghoul",
		Script = "scripts/entity/tactical/enemies/wx_boss_taotie", ParentScript = "scripts/entity/tactical/enemies/ghoul_high",
		HpMult = 2.60, MeleeSkillBonus = 14, MeleeDefBonus = 12, BraveryBonus = 65, Strength = 56,
		TraitName = "贪食无厌·吞血回天", TraitDesc = "《北山经》羊身人面虎齿贪兽之祖：铜头免爆头，每次噬咬直接吸取等同伤血量（最高 35 点）恢复自身并抽散目标 10 点内息！",
		CoreID = "wx_core_taotie", LairID = "shanhai_taotie",
		CustomBodySprite = null, CustomHeadSprite = null
	},
	boss_jiuwei = {
		Key = "jiuwei", BossID = "boss_jiuwei", Name = "【山海大妖】青丘山·九尾天狐主",
		EntityType = "Hexe", BaseTroop = "Hexe",
		Script = "scripts/entity/tactical/enemies/wx_boss_jiuwei", ParentScript = "scripts/entity/tactical/enemies/hexe",
		HpMult = 3.50, MeleeSkillBonus = 10, MeleeDefBonus = 15, BraveryBonus = 60, Strength = 55,
		TraitName = "千娇百媚·青丘迷魂障", TraitDesc = "《南山经》青丘千年妖主：高额避暗护体，周身 3 格弥漫迷魂香雾令定力不坚者陷入失衡，并施展妖咒魅惑我方高手倒戈！",
		CoreID = "wx_core_jiuwei", LairID = "shanhai_jiuwei",
		CustomBodySprite = null, CustomHeadSprite = null
	},
	boss_bashe = {
		Key = "bashe", BossID = "boss_bashe", Name = "【山海凶兽】苍梧渊·吞象巴蛇王",
		EntityType = "Serpent", BaseTroop = "Serpent",
		Script = "scripts/entity/tactical/enemies/wx_boss_bashe", ParentScript = "scripts/entity/tactical/enemies/serpent",
		HpMult = 3.00, MeleeSkillBonus = 14, MeleeDefBonus = 12, BraveryBonus = 55, Strength = 52,
		TraitName = "巴蛇食象·玄鳞奇瘴", TraitDesc = "《海内南经》三岁出骨之巨蟒王：玄鳞减免三成箭矢暗器伤害，缠卷撕咬瞬间注入奇瘴剧毒并令猎物失衡！",
		CoreID = "wx_core_bashe", LairID = "shanhai_bashe",
		CustomBodySprite = null, CustomHeadSprite = null
	},
	boss_jumang = {
		Key = "jumang", BossID = "boss_jumang", Name = "【山海神木】都广野·句芒建木王",
		EntityType = "Schrat", BaseTroop = "Schrat",
		Script = "scripts/entity/tactical/enemies/wx_boss_jumang", ParentScript = "scripts/entity/tactical/enemies/schrat",
		HpMult = 1.45, MeleeSkillBonus = 10, MeleeDefBonus = 8, BraveryBonus = 60, Strength = 58,
		TraitName = "生生建木·铁棘反刺", TraitDesc = "《海内经》通天建木化生树王：每回合自愈 20 气血；非斧类近战兵刃劈砍其木躯时，铁棘反震攻击者 10 点护甲与 5 点气血（宜遣巨斧手破盾伐木）！",
		CoreID = "wx_core_jumang", LairID = "shanhai_jumang",
		CustomBodySprite = null, CustomHeadSprite = null
	},
	boss_wuzhiqi = {
		Key = "wuzhiqi", BossID = "boss_wuzhiqi", Name = "【山海大妖】龟山寒渊·淮水无支祁",
		EntityType = "UnholdBog", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_wuzhiqi", ParentScript = "scripts/entity/tactical/enemies/unhold_bog",
		HpMult = 1.50, MeleeSkillBonus = 12, MeleeDefBonus = 10, BraveryBonus = 55, Strength = 56,
		TraitName = "兴风作浪·寒渊锁脉劲", TraitDesc = "上古淮水奇猿大妖，金目雪牙力逾九象：每次挥臂重击附带寒渊阴水劲，封锁敌手气穴减半回气并震至失衡！",
		CoreID = "wx_core_wuzhiqi", LairID = "shanhai_wuzhiqi",
		CustomBodySprite = null, CustomHeadSprite = null
	},
	boss_xingtian = {
		Key = "xingtian", BossID = "boss_xingtian", Name = "【山海凶煞】常羊山·刑天无首战魂",
		EntityType = "SkeletonBoss", BaseTroop = "SkeletonHeavy",
		Script = "scripts/entity/tactical/enemies/wx_boss_xingtian", ParentScript = "scripts/entity/tactical/enemies/skeleton_boss",
		HpMult = 2.10, MeleeSkillBonus = 14, MeleeDefBonus = 10, BraveryBonus = 99, Strength = 62,
		TraitName = "刑天舞干戚·无首不灭", TraitDesc = "《海外西经》断首战神遗骸：免疫爆头、眩晕、缴械与点穴奇毒；半血以下总伤暴涨 30%，每回合首杀立返 3 AP 连环劈杀！",
		CoreID = "wx_core_xingtian", LairID = "shanhai_xingtian",
		CustomBodySprite = null, CustomHeadSprite = null
	},
};

::Wuxia.Config.ShanHaiCores <- {
	wx_core_zhuyan = {
		ID = "wx_core_zhuyan", Name = "【山海内丹】朱厌沸血丹核", Value = 1800,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = null,
		Description = "取自小次山朱厌猿王胸腔的滚烫赤红内丹，可在城镇剥制师（百工坊）锻造传世重铠【山海·朱厌白首狂血铠】。"
	},
	wx_core_feiyi = {
		ID = "wx_core_feiyi", Name = "【山海内丹】肥遗旱火毒丹", Value = 1800,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = null,
		Description = "太华六足肥遗王体内凝结的紫赤毒丹，可在百工坊配合肥遗重鳞锻造【山海·太华肥遗逆鳞甲】。"
	},
	wx_core_qiongqi = {
		ID = "wx_core_qiongqi", Name = "【山海内丹】穷奇裂风妖丹", Value = 1800,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = null,
		Description = "旋绕恶风的青苍色凶兽内丹，可在百工坊打造极品布衣轻甲【山海·穷奇逐风翼皮甲】或凶兵【穷奇裂风血骨爪】。"
	},
	wx_core_taotie = {
		ID = "wx_core_taotie", Name = "【山海内丹】饕餮噬元凶丹", Value = 1800,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = null,
		Description = "凶煞逼人的暗金兽丹，吞吐血气不止，可在百工坊锻造传世重胄【山海·饕餮吞天兽面胄】。"
	},
	wx_core_jiuwei = {
		ID = "wx_core_jiuwei", Name = "【山海内丹】青丘九尾幻丹", Value = 1800,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = null,
		Description = "流转九色霞光的通灵妖丹，清香醒神，可在百工坊炼制传世佩饰【山海·青丘定魂辟邪佩】。"
	},
	wx_core_bashe = {
		ID = "wx_core_bashe", Name = "【山海内丹】苍梧巴蛇吞象胆", Value = 1800,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = null,
		Description = "碧绿如翡翠的千年蛇王苦胆内丹，可在百工坊配合巴蛇鳞皮裁制【山海·苍梧巴蛇碧鳞冠】。"
	},
	wx_core_jumang = {
		ID = "wx_core_jumang", Name = "【山海内丹】都广建木神心", Value = 1800,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = null,
		Description = "蕴藏蓬勃草木精气的万年神木核心，可在百工坊锻造轻灵省气的重片甲【山海·句芒建木生机甲】。"
	},
	wx_core_wuzhiqi = {
		ID = "wx_core_wuzhiqi", Name = "【山海内丹】无支祁寒渊定水珠", Value = 1800,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = null,
		Description = "淮水妖王口含千年的冰蓝水灵宝珠，可在百工坊镶嵌炼制异宝【山海·淮水辟毒寒渊珠】（加内息回气且百毒不侵）。"
	},
	wx_core_xingtian = {
		ID = "wx_core_xingtian", Name = "【山海内丹】常羊刑天不灭战髓", Value = 1800,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = null,
		Description = "凝结千年不屈战意的暗赤神髓，可在百工坊重铸《山海经》无上凶兵【传世·刑天舞干断首戚】！"
	},
};

::Wuxia.Config.ShanHaiGear <- {
	wx_armor_zhuyan = {
		ID = "wx_armor_zhuyan", Kind = "armor", Name = "山海·朱厌白首狂血铠", Value = 7500,
		MinCondition = 310, MaxStamPen = -28,
		CustomIcon = null, CustomIconLarge = null,
		Description = "以小次山朱厌猿王沸血丹核与白首巨猿厚革千锤百锻而成的山海重铠，坚逾精铁而血气暗涌。"
	},
	wx_armor_feiyi = {
		ID = "wx_armor_feiyi", Kind = "armor", Name = "山海·太华肥遗逆鳞甲", Value = 7600,
		MinCondition = 260, MaxStamPen = -21,
		CustomIcon = null, CustomIconLarge = null,
		Description = "取太华六足肥遗王毒丹与赤黑逆鳞编缀的传世宝甲，水火毒血难侵，攻守兼备。"
	},
	wx_armor_qiongqi = {
		ID = "wx_armor_qiongqi", Kind = "armor", Name = "山海·穷奇逐风翼皮甲", Value = 7200,
		MinCondition = 168, MaxStamPen = -8,
		CustomIcon = null, CustomIconLarge = null,
		Description = "融穷奇裂风妖丹与西山异兽斑革精裁的绝顶布衣轻甲：轻若鸿毛（完美契合《金蝉卸力》），防护却傲视寻常皮甲！"
	},
	wx_armor_jumang = {
		ID = "wx_armor_jumang", Kind = "armor", Name = "山海·句芒建木生机甲", Value = 7600,
		MinCondition = 325, MaxStamPen = -26,
		CustomIcon = null, CustomIconLarge = null,
		Description = "以都广建木万年神心与灵脂浸润甲叶锻成的苍翠重铠，生机流转，较寻常重甲大幅节省内息消耗。"
	},
	wx_helm_taotie = {
		ID = "wx_helm_taotie", Kind = "helmet", Name = "山海·饕餮吞天兽面胄", Value = 5800,
		MinCondition = 310, MaxStamPen = -16,
		CustomIcon = null, CustomIconLarge = null,
		Description = "铸有狰狞钩吾饕餮双角兽面的山海重胄，嵌饕餮噬元凶丹，正面硬撼重锤巨斧亦岿然不动。"
	},
	wx_helm_bashe = {
		ID = "wx_helm_bashe", Kind = "helmet", Name = "山海·苍梧巴蛇碧鳞冠", Value = 5600,
		MinCondition = 165, MaxStamPen = -6,
		CustomIcon = null, CustomIconLarge = null,
		Description = "以苍梧吞象巴蛇胆淬炼青鳞编成的轻便束发鳞冠，丝毫不碍耳目远射，轻装与游侠至宝。"
	},
	wx_acc_jiuwei = {
		ID = "wx_acc_jiuwei", Kind = "accessory", Name = "山海·青丘定魂辟邪佩", Value = 5200,
		MinCondition = 0, MaxStamPen = 0,
		CustomIcon = null, CustomIconLarge = null,
		Description = "以青丘九尾幻丹配妖魅白发炼成的通灵玉佩。佩于腰间：定力 +12、夜战无视视野惩罚，且对抗惊骇魅惑检定额外 +15 定力！"
	},
	wx_acc_wuzhiqi = {
		ID = "wx_acc_wuzhiqi", Kind = "accessory", Name = "山海·淮水辟毒寒渊珠", Value = 5400,
		MinCondition = 0, MaxStamPen = 0,
		CustomIcon = null, CustomIconLarge = null,
		Description = "淮水大妖无支祁口含千年的寒渊定水宝珠。佩于身侧：内息上限 +10、每回合回气 +2，且令佩戴者百毒不侵！"
	},
};
