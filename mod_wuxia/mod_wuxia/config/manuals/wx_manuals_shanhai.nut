// Shan Hai Jing Mythical Beast Totem Unique Manuals (山海凶兽图腾孤本)
// Strictly adheres to AGENTS.md stat & non-stacking redlines.

::Wuxia.Config.Manuals.wx_manual_shanhai_zhuyan <- {
	ID = "wx_manual_shanhai_zhuyan", Name = "朱厌沸血神功", Category = "neigong", Quality = "unique",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_shanhai_zhuyan.png",
	Description = "观《西山经》白首凶猿朱厌搏杀气韵所创的至阳图腾孤本：气血狂烈如山火沸腾，重击震碎敌手重心，且残血之时愈战愈猛！",
	BasePrice = 12200, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Hitpoints = 82, Stamina = 108 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Stamina = 16, Hitpoints = 8, FatigueRecoveryRate = 2 },  GrantSkills = ["actives.wx_meditate"], Flags = { DazeOnHeavyHitPct = 25 }, Summary = "内息 +16，气血 +8，回气 +2；重击震荡失衡 25%。" },
		{ ExpNeeded = 320, Stats = { Stamina = 28, Hitpoints = 14, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_meditate"], Flags = { DazeOnHeavyHitPct = 45, InjuryThresholdMult = 1.25 }, Summary = "内息 +28，气血 +14，回气 +4；重击失衡 45%，外伤门槛 +25%。" },
		{ ExpNeeded = 800, Stats = { Stamina = 40, Hitpoints = 20, FatigueRecoveryRate = 6 }, GrantSkills = ["actives.wx_meditate", "actives.wx_blood_burst"], Flags = { DazeOnHeavyHitPct = 60, InjuryThresholdMult = 1.35, BloodBurstAP = 2 }, Summary = "内息 +40，气血 +20，回气 +6；重击失衡 60%，习得「燃血催劲」（+2 AP）！" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shanhai_taotie <- {
	ID = "wx_manual_shanhai_taotie", Name = "饕餮吞天魔功", Category = "neigong", Quality = "unique",
	Element = "evil", WeaponTypes = [], Icon = "ui/perks/wx_manual_shanhai_taotie.png",
	Description = "自北山钩吾贪兽饕餮凶骨中参悟的霸道魔门孤本：出招鲸吞敌手真气，斩敌立噬精血回元，纵横尸山血海而不竭！",
	BasePrice = 12400, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Hitpoints = 80, Bravery = 65 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Stamina = 16, Hitpoints = 6 },                          GrantSkills = ["actives.wx_meditate"], Flags = { OnHitDrainQi = 4, OnKillHealHP = 5 }, Summary = "内息 +16，气血 +6；命中震散敌内息 4 点，击杀生人回 5 气血。" },
		{ ExpNeeded = 320, Stats = { Stamina = 28, Hitpoints = 12, FatigueRecoveryRate = 3 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnHitDrainQi = 6, OnKillHealHP = 8, OnKillQiRegen = 14 }, Summary = "内息 +28，气血 +12，回气 +3；散气 6 点，击杀回 8 气血与 14 内息。" },
		{ ExpNeeded = 800, Stats = { Stamina = 40, Hitpoints = 18, FatigueRecoveryRate = 5 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnHitDrainQi = 8, OnKillHealHP = 10, OnKillQiRegen = 22, GrantWashChance = 1 }, Summary = "内息 +40，气血 +18，回气 +5；散气 8 点，击杀回 10 气血与 22 内息，首次大成赠 1 次洗经伐髓契机！" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shanhai_qiongqi <- {
	ID = "wx_manual_shanhai_qiongqi", Name = "穷奇逐风翼步", Category = "qinggong", Quality = "unique",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_shanhai_qiongqi.png",
	Description = "摹写西极凶兽穷奇乘恶风扑杀之姿的绝世身法孤本：首轮暴起快逾疾电，孤身掠阵时凶威滔天！",
	BasePrice = 12000, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Initiative = 124 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Initiative = 14 }, GrantSkills = [], Flags = { TerrainCostHalved = true, FirstRoundInit = 15, InitToDefRatio = 0.13 }, Summary = "身法 +14；地形减耗，首轮身法 +15，有效身法 13% 转双防。" },
		{ ExpNeeded = 320, Stats = { Initiative = 22 }, GrantSkills = ["actives.footwork"], Flags = { TerrainCostHalved = true, FirstRoundInit = 20, FirstRoundHit = 8, InitToDefRatio = 0.17 }, Summary = "身法 +22；首轮身法 +20、命中 +8，身法 17% 转双防，习得脱身步法。" },
		{ ExpNeeded = 800, Stats = { Initiative = 30 }, GrantSkills = ["actives.footwork"], Flags = { TerrainCostHalved = true, FirstRoundInit = 25, FirstRoundHit = 12, InitToDefRatio = 0.20, MoveAPDiscount = 1 }, Summary = "身法 +30；首轮身法 +25、命中 +12，身法 20% 转双防，移动耗点 -1！" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shanhai_xingtian <- {
	ID = "wx_manual_shanhai_xingtian", Name = "刑天干戚战舞", Category = "henglian", Quality = "unique",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_shanhai_xingtian.png",
	Description = "常羊山不灭战魂遗留的上古战舞孤本：『刑天舞干戚，猛志固常在』——免除爆头重创、濒死锁血不屈、身陷重围死战斩敌！",
	BasePrice = 12500, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Hitpoints = 82, Bravery = 70 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Hitpoints = 8, Bravery = 6, MeleeSkill = 2 },  GrantSkills = ["perk.steel_brow"], Flags = { UnderdogGuard = true }, Summary = "气血 +8，定力 +6，武艺 +2；习得铜头铁额免爆头，且免除被围攻近防惩罚。" },
		{ ExpNeeded = 320, Stats = { Hitpoints = 14, Bravery = 12, MeleeSkill = 3 }, GrantSkills = ["perk.steel_brow", "perk.nine_lives"], Flags = { UnderdogGuard = true, GuixiTier = 3, ExecuteLowHpDmg = 0.12 }, Summary = "气血 +14，定力 +12，武艺 +3；习得九死锁血，对半血残敌伤害 +12%。" },
		{ ExpNeeded = 800, Stats = { Hitpoints = 20, Bravery = 18, MeleeSkill = 5 }, GrantSkills = ["perk.steel_brow", "perk.nine_lives", "actives.indomitable"], Flags = { UnderdogGuard = true, GuixiTier = 3, ExecuteLowHpDmg = 0.20, ShieldBreakBonus = 16 }, Summary = "气血 +20，定力 +18，武艺 +5；习得沉岳硬抗，残敌处决 +20%，碎盾劲 +16！" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shanhai_zhuyin <- {
	ID = "wx_manual_shanhai_zhuyin", Name = "烛阴瞑昼玄功", Category = "neigong", Quality = "unique",
	Element = "harmony", WeaponTypes = [], Icon = "ui/perks/wx_manual_shanhai_zhuyin.png",
	Description = "参悟钟山古神烛九阴『视为昼、瞑为夜』之呼吸吐纳至理：调和冰火阴阳，真气护体与绵长回气兼备，万毒暗伤难侵！",
	BasePrice = 12800, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Stamina = 110, Bravery = 68 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Stamina = 16, Bravery = 6, FatigueRecoveryRate = 2 },  GrantSkills = ["actives.wx_meditate"], Flags = { QiShieldPct = 0.15, AntiInternalInjury = true }, Summary = "内息 +16，定力 +6，回气 +2；真气护体减伤 15%，免疫内伤。" },
		{ ExpNeeded = 320, Stats = { Stamina = 28, Bravery = 10, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_meditate"], Flags = { QiShieldPct = 0.25, AntiInternalInjury = true, OnDodgeQiRegen = 4, OnDodgeQiCap = 8 }, Summary = "内息 +28，定力 +10，回气 +4；真气护体 25%，闪避回气 4 点。" },
		{ ExpNeeded = 800, Stats = { Stamina = 40, Bravery = 15, FatigueRecoveryRate = 6 }, GrantSkills = ["actives.wx_meditate"], Flags = { QiShieldPct = 0.35, AntiInternalInjury = true, OnDodgeQiRegen = 6, OnDodgeQiCap = 12, GrantWashChance = 1 }, Summary = "内息 +40，定力 +15，回气 +6；真气护体 35%，闪避回气 6 点，大成赠 1 次洗髓契机！" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shanhai_kunpeng <- {
	ID = "wx_manual_shanhai_kunpeng", Name = "北冥鲲鹏逍遥步", Category = "qinggong", Quality = "unique",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_shanhai_kunpeng.png",
	Description = "观北海巨鲲化鹏抟扶摇而上九万里之神姿所创的轻功至宝：踏空卸力、脱身无影，于千军箭雨之中翩然游走！",
	BasePrice = 12600, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Initiative = 125 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Initiative = 14 }, GrantSkills = [], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.14, DodgeRangedBonus = 4 }, Summary = "身法 +14；地形减耗，有效身法 14% 转双防，避暗补正 +4。" },
		{ ExpNeeded = 320, Stats = { Initiative = 22 }, GrantSkills = ["actives.footwork"], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.17, DodgeRangedBonus = 6, OnDodgeQiRegen = 4, OnDodgeQiCap = 8 }, Summary = "身法 +22；身法 17% 转双防，避暗 +6，闪避回气 4 点，习得脱身步法。" },
		{ ExpNeeded = 800, Stats = { Initiative = 30 }, GrantSkills = ["actives.footwork"], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.20, DodgeRangedBonus = 8, OnDodgeQiRegen = 6, OnDodgeQiCap = 12, PermanentAPBonus = 1 }, Summary = "身法 +30；身法 20% 转双防，避暗 +8，常驻 +1 AP（受全身 +2 上限约束）！" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shanhai_kuiniu <- {
	ID = "wx_manual_shanhai_kuiniu", Name = "东海夔牛雷音功", Category = "henglian", Quality = "unique",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_shanhai_kuiniu.png",
	Description = "摹东海流波山独足神兽夔牛苍革雷音所创的重装统帅至高硬功：披重铠如履平地，一声雷吼稳固全军战意！",
	BasePrice = 12500, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Hitpoints = 82, Bravery = 70 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Hitpoints = 8, Bravery = 8 },  GrantSkills = ["perk.brawny"], Flags = { HeavyArmorScale = 0.02 }, Summary = "气血 +8，定力 +8；习得披甲行气并减免损甲。" },
		{ ExpNeeded = 320, Stats = { Hitpoints = 14, Bravery = 14 }, GrantSkills = ["perk.brawny", "perk.steel_brow", "actives.wx_rally_command"], Flags = { HeavyArmorScale = 0.03, UnderdogGuard = true, RallyBonus = 8 }, Summary = "气血 +14，定力 +14；免爆头、免围攻近防惩罚，习得聚义雷音号令。" },
		{ ExpNeeded = 800, Stats = { Hitpoints = 20, Bravery = 20 }, GrantSkills = ["perk.brawny", "perk.steel_brow", "actives.wx_rally_command", "actives.indomitable"], Flags = { HeavyArmorScale = 0.04, UnderdogGuard = true, RallyBonus = 12, ReflectArmorDmg = 12 }, Summary = "气血 +20，定力 +20；习得沉岳硬抗，受近战劈砍雷音反震敌甲 12 点！" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shanhai_chiyou <- {
	ID = "wx_manual_shanhai_chiyou", Name = "蚩尤五兵破阵诀", Category = "waigong", Quality = "unique",
	Element = null, WeaponTypes = ["Sword", "Saber", "Cleaver", "Spear", "Polearm", "Axe", "Hammer"], Icon = "ui/perks/wx_manual_shanhai_chiyou.png",
	Description = "自凶黎古冢兵主蚩尤战魄参悟的上古百兵杀伐总纲：刀枪剑戟斧锤皆可融会贯通，摧甲碎盾势若破竹！",
	BasePrice = 12800, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 84, Stamina = 108 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = [], Flags = { DirectDmgBonus = 0.08, ArmorDmgBonus = 0.10 }, Summary = "武艺 +4，近防 +2；穿甲伤害 +8%，破甲伤害 +10%（适配刀剑枪戟斧锤）。" },
		{ ExpNeeded = 320, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_poise_charge", "actives.wx_saber_fanzhen"], Flags = { DirectDmgBonus = 0.14, ArmorDmgBonus = 0.18, ShieldBreakBonus = 12 }, Summary = "武艺 +7，近防 +4；穿甲 +14%，破甲 +18%，碎盾 +12，习得蓄势。" },
		{ ExpNeeded = 800, Stats = { MeleeSkill = 10, MeleeDefense = 6 }, GrantSkills = ["actives.wx_poise_charge"], Flags = { DirectDmgBonus = 0.20, ArmorDmgBonus = 0.25, ShieldBreakBonus = 18, ExecuteLowHpDmg = 0.15 }, Summary = "武艺 +10，近防 +6；穿甲 +20%，破甲 +25%，碎盾 +18，对残敌处决伤害 +15%！" }
	]
};
