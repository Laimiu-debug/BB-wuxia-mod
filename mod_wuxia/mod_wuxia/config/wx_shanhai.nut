// Shan Hai Jing (《山海经·五臧大荒万妖全卷》) 48 Mythical Apex Bosses, 48 Neidan Cores & Red Gear Registry
// All CustomBodySprite / CustomHeadSprite / CustomWorldBrush / CustomIcon fields default to null (vanilla placeholders)
// so standalone custom Shan Hai Jing artwork created in 山海武侠.html can be plugged in step-by-step!

::Wuxia.Config.ShanHaiBosses <- {
	boss_zhuyan = {
		Key = "zhuyan", BossID = "boss_zhuyan", Chapter = "西山经", Name = "【山海凶兽】小次山·朱厌猿王",
		EntityType = "UnholdFrost", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_zhuyan", ParentScript = "scripts/entity/tactical/enemies/unhold_frost_armored",
		HpMult = 1.45, MeleeSkillBonus = 10, MeleeDefBonus = 8, BraveryBonus = 40, Strength = 55,
		TraitName = "见则大兵·沸血狂猿", TraitDesc = "《西山经》凶猿之王：每回合活血自愈 25 气血（中毒或流血时减至 8 点）；气血低于六成时沸血狂暴，武艺 +12、总伤 +25% 且免眩晕缴械！",
		Mechanics = { RegenHP = 25, PoisonCutsRegen = 8, EnrageBelowPct = 0.60, EnrageMSkill = 12, EnrageDmgMult = 1.25, EnrageImmuneCC = true },
		CoreID = "wx_core_zhuyan", LairID = "shanhai_zhuyan",
		CustomBodySprite = "wx_boss_zhuyan", CustomHeadSprite = null
	},
	boss_feiyi = {
		Key = "feiyi", BossID = "boss_feiyi", Chapter = "西山经", Name = "【山海凶兽】太华山·六足肥遗王",
		EntityType = "Lindwurm", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_feiyi", ParentScript = "scripts/entity/tactical/enemies/lindwurm",
		HpMult = 1.35, MeleeSkillBonus = 8, MeleeDefBonus = 6, BraveryBonus = 50, Strength = 65,
		TraitName = "见则大旱·蚀甲旱火瘴", TraitDesc = "《西山经》太华毒蛟之王：周身 2 格弥漫赤旱毒热瘴气，每回合灼毁近身敌军 12 点身甲并蒸干 8 点内息，宜以两格长兵或劲弩讨伐！",
		Mechanics = { BonusMDef = 6, BonusRDef = 10, AuraRadius = 2, AuraArmorDmg = 12, AuraFatigue = 8 },
		CoreID = "wx_core_feiyi", LairID = "shanhai_feiyi",
		CustomBodySprite = "wx_boss_feiyi", CustomHeadSprite = null
	},
	boss_qiongqi = {
		Key = "qiongqi", BossID = "boss_qiongqi", Chapter = "北山经", Name = "【山海四凶】邽山·裂风穷奇",
		EntityType = "Hyena", BaseTroop = "Hyena",
		Script = "scripts/entity/tactical/enemies/wx_boss_qiongqi", ParentScript = "scripts/entity/tactical/enemies/hyena_high",
		HpMult = 3.40, MeleeSkillBonus = 18, MeleeDefBonus = 14, BraveryBonus = 60, Strength = 52,
		TraitName = "惩善助恶·裂风噬喉", TraitDesc = "《北山经》四大凶兽之一：常驻 11 AP、身法暴涨，撕咬必致深创流血，且专噬高定力君子（目标定力≥65 时命中 +12、伤害 +15%）！",
		Mechanics = { MinAP = 11, BonusInit = 35, BonusMSkill = 10, BonusMDef = 10, VsHighResolve = true, OnHitBleed = 8 },
		CoreID = "wx_core_qiongqi", LairID = "shanhai_qiongqi",
		CustomBodySprite = "wx_boss_qiongqi", CustomHeadSprite = null
	},
	boss_taotie = {
		Key = "taotie", BossID = "boss_taotie", Chapter = "北山经", Name = "【山海四凶】钩吾山·吞天饕餮王",
		EntityType = "Ghoul", BaseTroop = "Ghoul",
		Script = "scripts/entity/tactical/enemies/wx_boss_taotie", ParentScript = "scripts/entity/tactical/enemies/ghoul_high",
		HpMult = 2.60, MeleeSkillBonus = 14, MeleeDefBonus = 12, BraveryBonus = 65, Strength = 56,
		TraitName = "贪食无厌·吞血回天", TraitDesc = "《北山经》羊身人面虎齿贪兽之祖：铜头免爆头，每次噬咬直接吸取等同伤血量（最高 35 点）恢复自身并抽散目标 10 点内息！",
		Mechanics = { SteelBrow = true, BonusMSkill = 12, BonusMDef = 8, OnHitDrainHP = 35, OnHitDrainQi = 10 },
		CoreID = "wx_core_taotie", LairID = "shanhai_taotie",
		CustomBodySprite = "wx_boss_taotie", CustomHeadSprite = null
	},
	boss_jiuwei = {
		Key = "jiuwei", BossID = "boss_jiuwei", Chapter = "南山经", Name = "【山海大妖】青丘山·九尾天狐主",
		EntityType = "Hexe", BaseTroop = "Hexe",
		Script = "scripts/entity/tactical/enemies/wx_boss_jiuwei", ParentScript = "scripts/entity/tactical/enemies/hexe",
		HpMult = 3.50, MeleeSkillBonus = 10, MeleeDefBonus = 15, BraveryBonus = 60, Strength = 55,
		TraitName = "千娇百媚·青丘迷魂障", TraitDesc = "《南山经》青丘千年妖主：高额避暗护体，周身 3 格弥漫迷魂香雾令定力不坚者陷入失衡，并施展妖咒魅惑我方高手倒戈！",
		Mechanics = { BonusMDef = 18, BonusRDef = 28, BonusBravery = 35, RegularMult = 0.65, AuraRadius = 3, AuraResolveOffbalance = true },
		CoreID = "wx_core_jiuwei", LairID = "shanhai_jiuwei",
		CustomBodySprite = "wx_boss_jiuwei", CustomHeadSprite = null
	},
	boss_bashe = {
		Key = "bashe", BossID = "boss_bashe", Chapter = "南山经", Name = "【山海凶兽】苍梧渊·吞象巴蛇王",
		EntityType = "Serpent", BaseTroop = "Serpent",
		Script = "scripts/entity/tactical/enemies/wx_boss_bashe", ParentScript = "scripts/entity/tactical/enemies/serpent",
		HpMult = 3.00, MeleeSkillBonus = 14, MeleeDefBonus = 12, BraveryBonus = 55, Strength = 52,
		TraitName = "巴蛇食象·玄鳞奇瘴", TraitDesc = "《海内南经》三岁出骨之巨蟒王：玄鳞减免三成箭矢暗器伤害，缠卷撕咬瞬间注入奇瘴剧毒并令猎物失衡！",
		Mechanics = { BonusMSkill = 12, BonusMDef = 10, BonusRDef = 15, RangedMult = 0.70, OnHitPoison = true, OnHitOffbalance = true },
		CoreID = "wx_core_bashe", LairID = "shanhai_bashe",
		CustomBodySprite = "wx_boss_bashe", CustomHeadSprite = null
	},
	boss_jumang = {
		Key = "jumang", BossID = "boss_jumang", Chapter = "中山经", Name = "【山海神木】都广野·句芒建木王",
		EntityType = "Schrat", BaseTroop = "Schrat",
		Script = "scripts/entity/tactical/enemies/wx_boss_jumang", ParentScript = "scripts/entity/tactical/enemies/schrat",
		HpMult = 1.45, MeleeSkillBonus = 10, MeleeDefBonus = 8, BraveryBonus = 60, Strength = 58,
		TraitName = "生生建木·铁棘反刺", TraitDesc = "《海内经》通天建木化生树王：每回合自愈 20 气血；非斧类近战兵刃劈砍其木躯时，铁棘反震攻击者 10 点护甲与 5 点气血（宜遣巨斧手破盾伐木）！",
		Mechanics = { RegenHP = 20, ThornsNonAxe = true },
		CoreID = "wx_core_jumang", LairID = "shanhai_jumang",
		CustomBodySprite = "wx_boss_jumang", CustomHeadSprite = null
	},
	boss_wuzhiqi = {
		Key = "wuzhiqi", BossID = "boss_wuzhiqi", Chapter = "中山经", Name = "【山海大妖】龟山寒渊·淮水无支祁",
		EntityType = "UnholdBog", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_wuzhiqi", ParentScript = "scripts/entity/tactical/enemies/unhold_bog",
		HpMult = 1.50, MeleeSkillBonus = 12, MeleeDefBonus = 10, BraveryBonus = 55, Strength = 56,
		TraitName = "兴风作浪·寒渊锁脉劲", TraitDesc = "上古淮水奇猿大妖，金目雪牙力逾九象：每次挥臂重击附带寒渊阴水劲，封锁敌手气穴减半回气并震至失衡！",
		Mechanics = { BonusMSkill = 12, BonusMDef = 10, BonusInit = 15, OnHitAcupoint = true, OnHitOffbalance = true },
		CoreID = "wx_core_wuzhiqi", LairID = "shanhai_wuzhiqi",
		CustomBodySprite = "wx_boss_wuzhiqi", CustomHeadSprite = null
	},
	boss_xingtian = {
		Key = "xingtian", BossID = "boss_xingtian", Chapter = "大荒海内经", Name = "【山海凶煞】常羊山·刑天无首战魂",
		EntityType = "SkeletonBoss", BaseTroop = "SkeletonHeavy",
		Script = "scripts/entity/tactical/enemies/wx_boss_xingtian", ParentScript = "scripts/entity/tactical/enemies/skeleton_boss",
		HpMult = 2.10, MeleeSkillBonus = 14, MeleeDefBonus = 10, BraveryBonus = 99, Strength = 62,
		TraitName = "刑天舞干戚·无首不灭", TraitDesc = "《海外西经》断首战神遗骸：免疫爆头、眩晕、缴械与点穴奇毒；半血以下总伤暴涨 30%，每回合首杀立返 3 AP 连环劈杀！",
		Mechanics = { SteelBrow = true, BonusMSkill = 14, BonusMDef = 10, ImmuneStun = true, ImmuneDisarm = true, EnrageBelowPct = 0.50, EnrageDmgMult = 1.30, KillRefundAP = 3 },
		CoreID = "wx_core_xingtian", LairID = "shanhai_xingtian",
		CustomBodySprite = "wx_boss_xingtian", CustomHeadSprite = null
	},
	boss_bifang = {
		Key = "bifang", BossID = "boss_bifang", Chapter = "南山经", Name = "【山海凶禽】章莪山·独足毕方妖皇",
		EntityType = "Vampire", BaseTroop = "Vampire",
		Script = "scripts/entity/tactical/enemies/wx_boss_bifang", ParentScript = "scripts/entity/tactical/enemies/vampire",
		HpMult = 2.30, MeleeSkillBonus = 14, MeleeDefBonus = 16, BraveryBonus = 65, Strength = 56,
		TraitName = "见则讹火·赤翎焚甲掠影", TraitDesc = "《西山/南荒》青质赤纹白喙独足神禽：化火影瞬移掠阵，每次攻击讹火焚毁目标 18 点身甲并蒸干 10 点内息，高闪避免流血！",
		Mechanics = { MinAP = 10, BonusInit = 30, BonusMDef = 14, BonusRDef = 20, OnHitArmorBurn = 18, OnHitDrainQi = 10 },
		CoreID = "wx_core_bifang", LairID = "shanhai_bifang",
		CustomBodySprite = "wx_boss_bifang", CustomHeadSprite = null
	},
	boss_gudiaowang = {
		Key = "gudiaowang", BossID = "boss_gudiaowang", Chapter = "南山经", Name = "【山海凶禽】鹿吴山·攒角蛊雕王",
		EntityType = "Hyena", BaseTroop = "Hyena",
		Script = "scripts/entity/tactical/enemies/wx_boss_gudiaowang", ParentScript = "scripts/entity/tactical/enemies/hyena_high",
		HpMult = 3.20, MeleeSkillBonus = 16, MeleeDefBonus = 12, BraveryBonus = 55, Strength = 52,
		TraitName = "婴啼摄魂·乘怯裂颅", TraitDesc = "《南山经》泽更水食人妖禽之王：周身 3 格发出凄厉婴啼动摇敌军心智，对定力低于 55 或动摇敌手命中 +15、伤害 +25% 并致流血！",
		Mechanics = { BonusInit = 28, BonusMSkill = 12, AuraRadius = 3, AuraResolveOffbalance = true, VsShaken = true, OnHitBleed = 10 },
		CoreID = "wx_core_gudiaowang", LairID = "shanhai_gudiaowang",
		CustomBodySprite = "wx_boss_gudiaowang", CustomHeadSprite = null
	},
	boss_xingxing = {
		Key = "xingxing", BossID = "boss_xingxing", Chapter = "南山经", Name = "【山海大妖】招摇山·白耳狌狌老祖",
		EntityType = "Unhold", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_xingxing", ParentScript = "scripts/entity/tactical/enemies/unhold",
		HpMult = 1.50, MeleeSkillBonus = 14, MeleeDefBonus = 18, BraveryBonus = 60, Strength = 56,
		TraitName = "通晓往事·识破万招", TraitDesc = "《南山经》招摇山人面老妖，知人名识往事：洞悉刀剑来路获 +18 近防且免围攻惩罚，命中必看破门户施加【破绽】与【失衡】！",
		Mechanics = { Underdog = true, BonusMSkill = 10, BonusMDef = 18, OnHitOpening = true, OnHitOffbalance = true },
		CoreID = "wx_core_xingxing", LairID = "shanhai_xingxing",
		CustomBodySprite = "wx_boss_xingxing", CustomHeadSprite = null
	},
	boss_zhujian = {
		Key = "zhujian", BossID = "boss_zhujian", Chapter = "南山经", Name = "【山海凶兽】单狐山·豹尾猪建王",
		EntityType = "OrcBerserker", BaseTroop = "OrcBerserker",
		Script = "scripts/entity/tactical/enemies/wx_boss_zhujian", ParentScript = "scripts/entity/tactical/enemies/orc_berserker",
		HpMult = 2.60, MeleeSkillBonus = 15, MeleeDefBonus = 10, BraveryBonus = 65, Strength = 54,
		TraitName = "行则生风·狂飙碎阵", TraitDesc = "《北/南山荒谷》人目猪鬃豹尾狂兽：出动则大风拔木，身法 +30、免疫眩晕，每次重击震碎盾牌并吸取战意自愈 15 气血！",
		Mechanics = { BonusInit = 30, BonusMSkill = 12, ImmuneStun = true, OnHitDrainHP = 15, OnHitOffbalance = true },
		CoreID = "wx_core_zhujian", LairID = "shanhai_zhujian",
		CustomBodySprite = "wx_boss_zhujian", CustomHeadSprite = null
	},
	boss_xuangui = {
		Key = "xuangui", BossID = "boss_xuangui", Chapter = "南山经", Name = "【山海异兽】杻阳山·鸟首玄龟皇",
		EntityType = "Unhold", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_xuangui", ParentScript = "scripts/entity/tactical/enemies/unhold_armored",
		HpMult = 1.65, MeleeSkillBonus = 10, MeleeDefBonus = 14, BraveryBonus = 75, Strength = 58,
		TraitName = "玄甲不坏·唯锤可破", TraitDesc = "《南山经》怪水鸟首虺尾玄龟之皇：铜头免爆头，千年古甲对非锤锏钝器及远程伤害直接减免 45%，受近战劈砍反震攻击者 8 点内息！",
		Mechanics = { SteelBrow = true, RangedMult = 0.50, HammerWeakOnly = true, ThornsMeleeQi = 8 },
		CoreID = "wx_core_xuangui", LairID = "shanhai_xuangui",
		CustomBodySprite = "wx_boss_xuangui", CustomHeadSprite = null
	},
	boss_yuanchu = {
		Key = "yuanchu", BossID = "boss_yuanchu", Chapter = "南山经", Name = "【山海妖尊】丹穴山·堕火鹓鶵古妖",
		EntityType = "SkeletonPriest", BaseTroop = "SkeletonPriest",
		Script = "scripts/entity/tactical/enemies/wx_boss_yuanchu", ParentScript = "scripts/entity/tactical/enemies/skeleton_priest",
		HpMult = 2.80, MeleeSkillBonus = 10, MeleeDefBonus = 16, BraveryBonus = 80, Strength = 56,
		TraitName = "丹穴腐火·焚心妖阵", TraitDesc = "丹穴火山堕入魔障的上古妖禽祭灵：远防 +30，周身 3 格燃起丹穴毒火每回合灼烧敌军 8 气血与 10 护甲，群尸火卫贴身护法！",
		Mechanics = { BonusMDef = 14, BonusRDef = 30, RegularMult = 0.70, AuraRadius = 3, AuraHpDmg = 8, AuraArmorDmg = 10 },
		CoreID = "wx_core_yuanchu", LairID = "shanhai_yuanchu",
		CustomBodySprite = "wx_boss_yuanchu", CustomHeadSprite = null
	},
	boss_yingzhao = {
		Key = "yingzhao", BossID = "boss_yingzhao", Chapter = "西山经", Name = "【山海神孽】昆仑圃·人面英招巡狩",
		EntityType = "OrcWarlord", BaseTroop = "OrcWarlord",
		Script = "scripts/entity/tactical/enemies/wx_boss_yingzhao", ParentScript = "scripts/entity/tactical/enemies/orc_warlord",
		HpMult = 1.75, MeleeSkillBonus = 14, MeleeDefBonus = 12, BraveryBonus = 85, Strength = 62,
		TraitName = "天帝司圃·四海巡狩威压", TraitDesc = "《西山经》马身人面虎纹鸟翼巡守古神：常驻 10 AP、免眩晕缴械，雷霆战吼震慑全场，对破绽或动摇目标伤害暴涨 25%！",
		Mechanics = { MinAP = 10, ImmuneStun = true, ImmuneDisarm = true, BonusMSkill = 12, BonusMDef = 10, VsShaken = true, OnHitOpening = true },
		CoreID = "wx_core_yingzhao", LairID = "shanhai_yingzhao",
		CustomBodySprite = "wx_boss_yingzhao", CustomHeadSprite = null
	},
	boss_luwu = {
		Key = "luwu", BossID = "boss_luwu", Chapter = "西山经", Name = "【山海古神】昆仑丘·九尾虎神陆吾",
		EntityType = "Unhold", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_luwu", ParentScript = "scripts/entity/tactical/enemies/unhold_armored",
		HpMult = 1.65, MeleeSkillBonus = 16, MeleeDefBonus = 14, BraveryBonus = 85, Strength = 64,
		TraitName = "司天九部·九尾虎威", TraitDesc = "《西山经》虎身九尾人面之昆仑镇神：铜头免爆头、免围攻惩罚，巨爪挥击必撕开深创流血并击溃架势【破绽】！",
		Mechanics = { SteelBrow = true, Underdog = true, ImmuneStun = true, BonusMSkill = 14, BonusMDef = 12, OnHitBleed = 12, OnHitOpening = true },
		CoreID = "wx_core_luwu", LairID = "shanhai_luwu",
		CustomBodySprite = "wx_boss_luwu", CustomHeadSprite = null
	},
	boss_qinyuan = {
		Key = "qinyuan", BossID = "boss_qinyuan", Chapter = "西山经", Name = "【山海毒尊】昆仑阳·蜇石钦原蛊皇",
		EntityType = "Spider", BaseTroop = "Spider",
		Script = "scripts/entity/tactical/enemies/wx_boss_qinyuan", ParentScript = "scripts/entity/tactical/enemies/spider",
		HpMult = 3.80, MeleeSkillBonus = 18, MeleeDefBonus = 18, BraveryBonus = 65, Strength = 52,
		TraitName = "蜇石则烂·蚀骨双绝毒", TraitDesc = "《西山经》状如巨蜂之昆仑毒皇，蜇鸟兽则死蜇木则枯：常驻 11 AP、身法如电，尾针贯甲同时注入【暗器剧毒】与【脏腑内伤】！",
		Mechanics = { MinAP = 11, BonusInit = 45, BonusMSkill = 14, BonusMDef = 16, BonusRDef = 22, OnHitPoison = true, OnHitInternalInjury = true },
		CoreID = "wx_core_qinyuan", LairID = "shanhai_qinyuan",
		CustomBodySprite = "wx_boss_qinyuan", CustomHeadSprite = null
	},
	boss_tiangouwang = {
		Key = "tiangouwang", BossID = "boss_tiangouwang", Chapter = "西山经", Name = "【山海凶星】阴山顶·奔星天狗皇",
		EntityType = "Direwolf", BaseTroop = "Hyena",
		Script = "scripts/entity/tactical/enemies/wx_boss_tiangouwang", ParentScript = "scripts/entity/tactical/enemies/direwolf_high",
		HpMult = 3.30, MeleeSkillBonus = 18, MeleeDefBonus = 16, BraveryBonus = 65, Strength = 54,
		TraitName = "流星坠地·噬月连扑", TraitDesc = "《西山经》阴山白首赤喙凶星兽皇：常驻 12 AP 疾电扑杀，首杀立返 3 AP、回复 30 气血并激起漫天星尘【烟幕蔽目】！",
		Mechanics = { MinAP = 12, BonusInit = 40, BonusMSkill = 14, BonusMDef = 14, KillRefundAP = 3, KillHealHP = 30, KillSmoke = true },
		CoreID = "wx_core_tiangouwang", LairID = "shanhai_tiangouwang",
		CustomBodySprite = "wx_boss_tiangouwang", CustomHeadSprite = null
	},
	boss_zheng = {
		Key = "zheng", BossID = "boss_zheng", Chapter = "西山经", Name = "【山海凶兽】章峨山·五尾独角狰王",
		EntityType = "Hyena", BaseTroop = "Hyena",
		Script = "scripts/entity/tactical/enemies/wx_boss_zheng", ParentScript = "scripts/entity/tactical/enemies/hyena_high",
		HpMult = 3.20, MeleeSkillBonus = 16, MeleeDefBonus = 15, BraveryBonus = 65, Strength = 54,
		TraitName = "音如击石·独角崩甲", TraitDesc = "《西山经》赤豹五尾一角凶兽：皮毛坚硬减免 25% 气血实伤，独角冲撞每次崩毁目标 20 点护甲并震至【失衡】！",
		Mechanics = { RegularMult = 0.75, BonusMSkill = 12, BonusMDef = 14, OnHitArmorBurn = 20, OnHitOffbalance = true },
		CoreID = "wx_core_zheng", LairID = "shanhai_zheng",
		CustomBodySprite = "wx_boss_zheng", CustomHeadSprite = null
	},
	boss_hundun = {
		Key = "hundun", BossID = "boss_hundun", Chapter = "西山经", Name = "【山海四凶】天山渊·六足无面浑沌",
		EntityType = "UnholdFrost", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_hundun", ParentScript = "scripts/entity/tactical/enemies/unhold_frost_armored",
		HpMult = 1.85, MeleeSkillBonus = 12, MeleeDefBonus = 10, BraveryBonus = 99, Strength = 66,
		TraitName = "浑沌无窍·狂舞震岳", TraitDesc = "《西山经》天山神魔、四大凶兽之浑沌，状如黄囊赤如丹火六足四翼无面目：彻底免疫爆头、眩晕、致盲与惊骇；受近战攻击时浑沌气劲反震周身敌军 10 气血！",
		Mechanics = { SteelBrow = true, Underdog = true, ImmuneStun = true, RegenHP = 18, ThornsAoE = 10 },
		CoreID = "wx_core_hundun", LairID = "shanhai_hundun",
		CustomBodySprite = "wx_boss_hundun", CustomHeadSprite = null
	},
	boss_yayu = {
		Key = "yayu", BossID = "boss_yayu", Chapter = "北山经", Name = "【山海凶神】少咸山·龙首猰貐血尊",
		EntityType = "Ghoul", BaseTroop = "Ghoul",
		Script = "scripts/entity/tactical/enemies/wx_boss_yayu", ParentScript = "scripts/entity/tactical/enemies/ghoul_high",
		HpMult = 2.80, MeleeSkillBonus = 16, MeleeDefBonus = 14, BraveryBonus = 75, Strength = 58,
		TraitName = "贰负复生·噬骨锁脉", TraitDesc = "《海内/北山经》原为天神、死后化生之龙首食人凶神：每回合自愈 20 气血，首次濒死时逆命复生暴涨 130 气血，利爪附带【点穴封气】！",
		Mechanics = { RegenHP = 20, ReviveOnceHP = 130, BonusMSkill = 14, BonusMDef = 12, OnHitAcupoint = true, OnHitBleed = 10 },
		CoreID = "wx_core_yayu", LairID = "shanhai_yayu",
		CustomBodySprite = "wx_boss_yayu", CustomHeadSprite = null
	},
	boss_zhuyin = {
		Key = "zhuyin", BossID = "boss_zhuyin", Chapter = "北山经", Name = "【山海古神】钟山巅·烛九阴寒螟裔",
		EntityType = "Lindwurm", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_zhuyin", ParentScript = "scripts/entity/tactical/enemies/lindwurm",
		HpMult = 1.65, MeleeSkillBonus = 14, MeleeDefBonus = 12, BraveryBonus = 95, Strength = 68,
		TraitName = "视为昼瞑为夜·寒暑轮转", TraitDesc = "《海外北经》钟山神烛龙血裔：单数轮【瞑夜寒冬】冰封 3 格内敌军 12 内息并致失衡；双数轮【开目赤昼】自身武艺 +18、总伤 +25%！",
		Mechanics = { SteelBrow = true, ImmuneStun = true, CycleMode = "zhuyin", AuraRadius = 3 },
		CoreID = "wx_core_zhuyin", LairID = "shanhai_zhuyin",
		CustomBodySprite = "wx_boss_zhuyin", CustomHeadSprite = null
	},
	boss_dijiang = {
		Key = "dijiang", BossID = "boss_dijiang", Chapter = "北山经", Name = "【山海异神】天山北·丹红六足帝江",
		EntityType = "Vampire", BaseTroop = "Vampire",
		Script = "scripts/entity/tactical/enemies/wx_boss_dijiang", ParentScript = "scripts/entity/tactical/enemies/vampire",
		HpMult = 2.60, MeleeSkillBonus = 14, MeleeDefBonus = 22, BraveryBonus = 80, Strength = 56,
		TraitName = "空间神韵·幻步乱神", TraitDesc = "《西/北山界》识歌舞通空间之六足四翼丹红异神：远防 +35 几近免疫弓弩，幻步移形每击震散敌手真气【散功虚弱】并致失衡！",
		Mechanics = { MinAP = 10, BonusMDef = 20, BonusRDef = 35, RangedMult = 0.45, OnHitScatter = true, OnHitOffbalance = true },
		CoreID = "wx_core_dijiang", LairID = "shanhai_dijiang",
		CustomBodySprite = "wx_boss_dijiang", CustomHeadSprite = null
	},
	boss_paoxiaowang = {
		Key = "paoxiaowang", BossID = "boss_paoxiaowang", Chapter = "北山经", Name = "【山海凶兽】钩吾北·腋目狍鸮老祖",
		EntityType = "UnholdBog", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_paoxiaowang", ParentScript = "scripts/entity/tactical/enemies/unhold_bog",
		HpMult = 1.60, MeleeSkillBonus = 14, MeleeDefBonus = 14, BraveryBonus = 70, Strength = 58,
		TraitName = "腋下生目·四面无漏", TraitDesc = "《北山经》羊身人面目在腋下虎齿人爪之老祖：彻底免除被围攻近防惩罚，噬咬吸取 25 气血并重创敌手经脉【内伤】！",
		Mechanics = { Underdog = true, SteelBrow = true, BonusMSkill = 12, BonusMDef = 14, OnHitDrainHP = 25, OnHitInternalInjury = true },
		CoreID = "wx_core_paoxiaowang", LairID = "shanhai_paoxiaowang",
		CustomBodySprite = "wx_boss_paoxiaowang", CustomHeadSprite = null
	},
	boss_changyou = {
		Key = "changyou", BossID = "boss_changyou", Chapter = "北山经", Name = "【山海大妖】小侯山·四耳长右水猿",
		EntityType = "UnholdBog", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_changyou", ParentScript = "scripts/entity/tactical/enemies/unhold_bog",
		HpMult = 1.55, MeleeSkillBonus = 12, MeleeDefBonus = 14, BraveryBonus = 65, Strength = 56,
		TraitName = "见则大水·四耳听风寒潮", TraitDesc = "《东/北山寒泽》状如禺而四耳之大水灾猿：四耳听风免疫远射偷袭（远伤 -35%），重掌寒潮每次震散目标 14 内息并致【散功虚弱】！",
		Mechanics = { RangedMult = 0.65, RegenHP = 15, BonusMDef = 12, BonusRDef = 20, OnHitDrainQi = 14, OnHitScatter = true },
		CoreID = "wx_core_changyou", LairID = "shanhai_changyou",
		CustomBodySprite = "wx_boss_changyou", CustomHeadSprite = null
	},
	boss_mengji = {
		Key = "mengji", BossID = "boss_mengji", Chapter = "北山经", Name = "【山海异兽】石者山·白豹孟极兽皇",
		EntityType = "Direwolf", BaseTroop = "Hyena",
		Script = "scripts/entity/tactical/enemies/wx_boss_mengji", ParentScript = "scripts/entity/tactical/enemies/direwolf_high",
		HpMult = 3.10, MeleeSkillBonus = 18, MeleeDefBonus = 18, BraveryBonus = 60, Strength = 52,
		TraitName = "文题白身·善伏破绽袭杀", TraitDesc = "《北山经》白身黑纹善潜伏之奇豹皇：身法 +35、近防 +16，每次利爪扑击精准撕开甲缝施加【破绽】与【深创流血】！",
		Mechanics = { MinAP = 11, BonusInit = 35, BonusMSkill = 14, BonusMDef = 16, OnHitOpening = true, OnHitBleed = 10 },
		CoreID = "wx_core_mengji", LairID = "shanhai_mengji",
		CustomBodySprite = "wx_boss_mengji", CustomHeadSprite = null
	},
	boss_kui = {
		Key = "kui", BossID = "boss_kui", Chapter = "东山经", Name = "【山海雷兽】东海流波山·独足雷神夔牛",
		EntityType = "Unhold", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_kui", ParentScript = "scripts/entity/tactical/enemies/unhold_armored",
		HpMult = 1.75, MeleeSkillBonus = 14, MeleeDefBonus = 12, BraveryBonus = 90, Strength = 64,
		TraitName = "日月雷音·震裂万甲", TraitDesc = "《大荒东经》流波山苍身无角一足神兽，声如雷霆：每回合引雷震荡 3 格内敌军 10 点护甲与 8 点内息，硬革减免 25% 气血实伤！",
		Mechanics = { SteelBrow = true, ImmuneStun = true, RegularMult = 0.75, AuraRadius = 3, AuraArmorDmg = 10, AuraFatigue = 8, OnHitOffbalance = true },
		CoreID = "wx_core_kui", LairID = "shanhai_kui",
		CustomBodySprite = "wx_boss_kui", CustomHeadSprite = null
	},
	boss_fei = {
		Key = "fei", BossID = "boss_fei", Chapter = "东山经", Name = "【山海灾兽】太山渊·一目白首蜚皇",
		EntityType = "OrcWarlord", BaseTroop = "OrcWarlord",
		Script = "scripts/entity/tactical/enemies/wx_boss_fei", ParentScript = "scripts/entity/tactical/enemies/orc_warlord",
		HpMult = 1.80, MeleeSkillBonus = 14, MeleeDefBonus = 10, BraveryBonus = 85, Strength = 64,
		TraitName = "见则大疫·枯水死草瘟瘴", TraitDesc = "《东山经》太山牛形白首一目蛇尾灾兽，行水则竭行草则死：周身 2 格绝命大疫毒瘴每回合直接蚀扣敌军 10 气血并染【暗器剧毒】！",
		Mechanics = { SteelBrow = true, ImmuneStun = true, AuraRadius = 2, AuraHpDmg = 10, AuraPoison = true, OnHitPoison = true },
		CoreID = "wx_core_fei", LairID = "shanhai_fei",
		CustomBodySprite = "wx_boss_fei", CustomHeadSprite = null
	},
	boss_yinglong = {
		Key = "yinglong", BossID = "boss_yinglong", Chapter = "东山经", Name = "【山海真龙】凶犁土丘·折翼应龙战魂",
		EntityType = "Lindwurm", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_yinglong", ParentScript = "scripts/entity/tactical/enemies/lindwurm",
		HpMult = 1.70, MeleeSkillBonus = 16, MeleeDefBonus = 16, BraveryBonus = 95, Strength = 68,
		TraitName = "斩魔蓄水·古龙逆鳞威", TraitDesc = "《大荒东经》昔助禹治水、斩蚩尤夸父而折翼坠土之真龙遗魄：双防 +14，半血以下真龙逆鳞觉醒免控且伤害 +30%，击中必碎甲封脉！",
		Mechanics = { SteelBrow = true, BonusMSkill = 14, BonusMDef = 14, BonusRDef = 14, EnrageBelowPct = 0.55, EnrageDmgMult = 1.30, EnrageImmuneCC = true, OnHitArmorBurn = 20, OnHitAcupoint = true },
		CoreID = "wx_core_yinglong", LairID = "shanhai_yinglong",
		CustomBodySprite = "wx_boss_yinglong", CustomHeadSprite = null
	},
	boss_taowu = {
		Key = "taowu", BossID = "boss_taowu", Chapter = "东山经", Name = "【山海四凶】荒中凶兽·人面虎足檮杌王",
		EntityType = "UnholdFrost", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_taowu", ParentScript = "scripts/entity/tactical/enemies/unhold_frost_armored",
		HpMult = 1.75, MeleeSkillBonus = 16, MeleeDefBonus = 12, BraveryBonus = 99, Strength = 64,
		TraitName = "傲狠难训·搅乱荒中死战", TraitDesc = "《神异/山海》四大凶兽之一，人面虎足猪口尾长丈八，好战不退：免疫惊骇眩晕缴械，气血越低攻势越狂（<65% 气血武艺 +16、总伤 +30%）且重击致残内伤！",
		Mechanics = { SteelBrow = true, Underdog = true, ImmuneStun = true, ImmuneDisarm = true, EnrageBelowPct = 0.65, EnrageMSkill = 16, EnrageDmgMult = 1.30, OnHitInternalInjury = true },
		CoreID = "wx_core_taowu", LairID = "shanhai_taowu",
		CustomBodySprite = "wx_boss_taowu", CustomHeadSprite = null
	},
	boss_hujiao = {
		Key = "hujiao", BossID = "boss_hujiao", Chapter = "东山经", Name = "【山海毒蛟】玉山涧·四足虎纹虎蛟王",
		EntityType = "Serpent", BaseTroop = "Serpent",
		Script = "scripts/entity/tactical/enemies/wx_boss_hujiao", ParentScript = "scripts/entity/tactical/enemies/serpent",
		HpMult = 3.20, MeleeSkillBonus = 16, MeleeDefBonus = 14, BraveryBonus = 65, Strength = 54,
		TraitName = "鱼身虎爪·缠杀透甲毒", TraitDesc = "《南/东山涧泽》鱼身蛇尾虎纹四足凶蛟：缠卷近身猎物削其双防【破绽】，毒牙穿透铁甲直伤脏腑【内伤】与【剧毒】！",
		Mechanics = { BonusMSkill = 14, BonusMDef = 12, RangedMult = 0.75, OnHitOpening = true, OnHitPoison = true, OnHitInternalInjury = true },
		CoreID = "wx_core_hujiao", LairID = "shanhai_hujiao",
		CustomBodySprite = "wx_boss_hujiao", CustomHeadSprite = null
	},
	boss_zhuhuai = {
		Key = "zhuhuai", BossID = "boss_zhuhuai", Chapter = "东山经", Name = "【山海凶兽】北岳山·四角人目诸怀王",
		EntityType = "OrcBerserker", BaseTroop = "OrcBerserker",
		Script = "scripts/entity/tactical/enemies/wx_boss_zhuhuai", ParentScript = "scripts/entity/tactical/enemies/orc_berserker",
		HpMult = 2.80, MeleeSkillBonus = 16, MeleeDefBonus = 12, BraveryBonus = 70, Strength = 56,
		TraitName = "四角冲阵·噬人回威", TraitDesc = "《北/东山界》牛形四角人目猪耳食人凶兽：四角狂冲崩毁敌军 22 点护甲，每斩杀一人立返 2 AP 并狂回 35 气血！",
		Mechanics = { SteelBrow = true, ImmuneStun = true, BonusMSkill = 14, OnHitArmorBurn = 22, KillRefundAP = 2, KillHealHP = 35 },
		CoreID = "wx_core_zhuhuai", LairID = "shanhai_zhuhuai",
		CustomBodySprite = "wx_boss_zhuhuai", CustomHeadSprite = null
	},
	boss_shebishi = {
		Key = "shebishi", BossID = "boss_shebishi", Chapter = "东山经", Name = "【山海尸神】大荒东·青蛇贯耳奢比尸",
		EntityType = "ZombieBoss", BaseTroop = "SkeletonHeavy",
		Script = "scripts/entity/tactical/enemies/wx_boss_shebishi", ParentScript = "scripts/entity/tactical/enemies/zombie_boss",
		HpMult = 2.40, MeleeSkillBonus = 14, MeleeDefBonus = 12, BraveryBonus = 99, Strength = 60,
		TraitName = "青蛇贯耳·不腐尸煞噬血", TraitDesc = "《海外东经》人面兽身犬耳珥两青蛇之古尸神：死躯免毒免点穴，每回合再生 25 气血，挥击同时汲取 25 气血并染【暗器剧毒】！",
		Mechanics = { RegenHP = 25, SteelBrow = true, ImmuneStun = true, OnHitDrainHP = 25, OnHitPoison = true },
		CoreID = "wx_core_shebishi", LairID = "shanhai_shebishi",
		CustomBodySprite = "wx_boss_shebishi", CustomHeadSprite = null
	},
	boss_jingwei = {
		Key = "jingwei", BossID = "boss_jingwei", Chapter = "东山经", Name = "【山海怨魂】发鸠山·东海溺魂精卫妖主",
		EntityType = "Ghost", BaseTroop = "SkeletonHeavy",
		Script = "scripts/entity/tactical/enemies/wx_boss_jingwei", ParentScript = "scripts/entity/tactical/enemies/ghost_knight",
		HpMult = 2.80, MeleeSkillBonus = 14, MeleeDefBonus = 24, BraveryBonus = 99, Strength = 56,
		TraitName = "衔石填海·千载不散怨啸", TraitDesc = "《北/东海界》炎帝少女溺亡东海所化千年执念战魂：灵体虚化近远双防 +22、常规刀剑实伤减半，怨啸直碎敌军定力并致【失衡】！",
		Mechanics = { BonusMDef = 22, BonusRDef = 26, RegularMult = 0.50, AuraRadius = 3, AuraResolveOffbalance = true, OnHitScatter = true },
		CoreID = "wx_core_jingwei", LairID = "shanhai_jingwei",
		CustomBodySprite = "wx_boss_jingwei", CustomHeadSprite = null
	},
	boss_jiuying = {
		Key = "jiuying", BossID = "boss_jiuying", Chapter = "中山经", Name = "【山海凶妖】凶水渊·水火九首九婴皇",
		EntityType = "Lindwurm", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_jiuying", ParentScript = "scripts/entity/tactical/enemies/lindwurm",
		HpMult = 1.65, MeleeSkillBonus = 15, MeleeDefBonus = 12, BraveryBonus = 90, Strength = 66,
		TraitName = "九首喷吐·水火相济灭世", TraitDesc = "《淮南/山海北狄》凶水之中既能喷水又能喷火之九首蛇妖：每回合再生 22 气血；单数轮寒毒水雾侵蚀 2 格敌军气血染毒，双数轮烈火焚毁 16 点护甲！",
		Mechanics = { RegenHP = 22, CycleMode = "jiuying", AuraRadius = 2, OnHitPoison = true, OnHitArmorBurn = 16 },
		CoreID = "wx_core_jiuying", LairID = "shanhai_jiuying",
		CustomBodySprite = "wx_boss_jiuying", CustomHeadSprite = null
	},
	boss_feilian = {
		Key = "feilian", BossID = "boss_feilian", Chapter = "中山经", Name = "【山海风伯】鹿台山·雀首蛇尾飞廉妖尊",
		EntityType = "Vampire", BaseTroop = "Vampire",
		Script = "scripts/entity/tactical/enemies/wx_boss_feilian", ParentScript = "scripts/entity/tactical/enemies/vampire",
		HpMult = 2.50, MeleeSkillBonus = 16, MeleeDefBonus = 20, BraveryBonus = 80, Strength = 58,
		TraitName = "风伯统御·裂空回风障", TraitDesc = "《楚辞/山海》鹿身头如雀有角蛇尾豹纹之风伯妖尊：11 AP 乘风瞬移，狂风护体令远程伤害降低 55%，风刃连斩必挂流血与破绽！",
		Mechanics = { MinAP = 11, BonusInit = 40, BonusMDef = 18, BonusRDef = 30, RangedMult = 0.45, OnHitBleed = 10, OnHitOpening = true },
		CoreID = "wx_core_feilian", LairID = "shanhai_feilian",
		CustomBodySprite = "wx_boss_feilian", CustomHeadSprite = null
	},
	boss_baize = {
		Key = "baize", BossID = "boss_baize", Chapter = "中山经", Name = "【山海瑞煞】东望山·通万物情白泽古兽",
		EntityType = "UnholdFrost", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_baize", ParentScript = "scripts/entity/tactical/enemies/unhold_frost_armored",
		HpMult = 1.60, MeleeSkillBonus = 14, MeleeDefBonus = 20, BraveryBonus = 95, Strength = 60,
		TraitName = "达知万物·万法破绽洞微", TraitDesc = "《山海图赞》能言达知万物鬼神情状之昆仑东望古兽：免围攻、免眩晕缴械，每回合自愈 20 气血并看破 3 格内敌军武学套路，反击必破架势！",
		Mechanics = { Underdog = true, ImmuneStun = true, ImmuneDisarm = true, RegenHP = 20, BonusMDef = 20, BonusRDef = 20, OnHitOpening = true, OnHitScatter = true },
		CoreID = "wx_core_baize", LairID = "shanhai_baize",
		CustomBodySprite = "wx_boss_baize", CustomHeadSprite = null
	},
	boss_shanhui = {
		Key = "shanhui", BossID = "boss_shanhui", Chapter = "中山经", Name = "【山海疾兽】狱法山·犬形人面山挥王",
		EntityType = "GoblinWolfrider", BaseTroop = "GoblinSkirmisher",
		Script = "scripts/entity/tactical/enemies/wx_boss_shanhui", ParentScript = "scripts/entity/tactical/enemies/goblin_wolfrider",
		HpMult = 3.20, MeleeSkillBonus = 18, MeleeDefBonus = 18, BraveryBonus = 65, Strength = 52,
		TraitName = "见则大风·善投飞石惊走", TraitDesc = "《北/中山经》状如犬而人面善投、见人则笑行如疾风：常驻 11 AP 游走如电，重击敲碎头盔护甲并令目标【失衡】封穴！",
		Mechanics = { MinAP = 11, BonusInit = 42, BonusMSkill = 14, BonusMDef = 16, BonusRDef = 20, OnHitArmorBurn = 16, OnHitOffbalance = true },
		CoreID = "wx_core_shanhui", LairID = "shanhai_shanhui",
		CustomBodySprite = "wx_boss_shanhui", CustomHeadSprite = null
	},
	boss_bo = {
		Key = "bo", BossID = "boss_bo", Chapter = "中山经", Name = "【山海猛兽】中曲山·独角食虎铁驳王",
		EntityType = "Unhold", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_bo", ParentScript = "scripts/entity/tactical/enemies/unhold_armored",
		HpMult = 1.65, MeleeSkillBonus = 16, MeleeDefBonus = 12, BraveryBonus = 80, Strength = 60,
		TraitName = "音如击鼓·食虎碎甲神角", TraitDesc = "《西/中山经》状如白马锯牙食虎豹之神猛巨兽：铜头免爆头，咆哮如战鼓壮胆，锯牙独角一击崩碎 25 点重甲并致深创流血！",
		Mechanics = { SteelBrow = true, ImmuneStun = true, BonusMSkill = 16, BonusMDef = 10, OnHitArmorBurn = 25, OnHitBleed = 12 },
		CoreID = "wx_core_bo", LairID = "shanhai_bo",
		CustomBodySprite = "wx_boss_bo", CustomHeadSprite = null
	},
	boss_huodou = {
		Key = "huodou", BossID = "boss_huodou", Chapter = "中山经", Name = "【山海火妖】厌火南荒·食炭喷炎祸斗王",
		EntityType = "Direwolf", BaseTroop = "Hyena",
		Script = "scripts/entity/tactical/enemies/wx_boss_huodou", ParentScript = "scripts/entity/tactical/enemies/direwolf_high",
		HpMult = 3.30, MeleeSkillBonus = 16, MeleeDefBonus = 14, BraveryBonus = 70, Strength = 56,
		TraitName = "食火喷炎·火星溅甲反灼", TraitDesc = "《海外南经》厌火国食火凶犬之王，所至火灾不绝：近战兵刃砍中其身时迸溅烈焰反灼攻击者 12 点护甲与 6 气血，扑咬焚甲蒸气！",
		Mechanics = { MinAP = 10, BonusInit = 30, BonusMSkill = 14, ThornsMeleeFire = true, OnHitArmorBurn = 18, OnHitDrainQi = 8 },
		CoreID = "wx_core_huodou", LairID = "shanhai_huodou",
		CustomBodySprite = "wx_boss_huodou", CustomHeadSprite = null
	},
	boss_xiangliuwang = {
		Key = "xiangliuwang", BossID = "boss_xiangliuwang", Chapter = "大荒海内经", Name = "【山海凶神】共工台·九首毒渊相柳皇",
		EntityType = "Lindwurm", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_xiangliuwang", ParentScript = "scripts/entity/tactical/enemies/lindwurm",
		HpMult = 1.75, MeleeSkillBonus = 16, MeleeDefBonus = 12, BraveryBonus = 95, Strength = 68,
		TraitName = "九首食九山·苦泽百毒不生", TraitDesc = "《海外北经》水神共工之臣，九首人面蛇身青色，所抵成苦泽：每回合九首再生 30 气血（中毒减半），周身 2 格苦毒腐泽每回合蚀毁 12 护甲、6 气血并染剧毒！",
		Mechanics = { RegenHP = 30, PoisonCutsRegen = 15, AuraRadius = 2, AuraArmorDmg = 12, AuraHpDmg = 6, AuraPoison = true, OnHitPoison = true },
		CoreID = "wx_core_xiangliuwang", LairID = "shanhai_xiangliuwang",
		CustomBodySprite = "wx_boss_xiangliuwang", CustomHeadSprite = null
	},
	boss_kuafu = {
		Key = "kuafu", BossID = "boss_kuafu", Chapter = "大荒海内经", Name = "【山海巨神】成都载天·逐日夸父枯骸",
		EntityType = "SkeletonHeavy", BaseTroop = "SkeletonHeavy",
		Script = "scripts/entity/tactical/enemies/wx_boss_kuafu", ParentScript = "scripts/entity/tactical/enemies/skeleton_heavy_polearm",
		HpMult = 2.60, MeleeSkillBonus = 16, MeleeDefBonus = 12, BraveryBonus = 99, Strength = 64,
		TraitName = "邓林桃杖·大日渴渊", TraitDesc = "《海外北经》耳珥两黄蛇、逐日渴死于大泽之巨神枯骸：死躯免毒免惊骇免爆头，炙阳渴气每回合蒸干 3 格内敌军 12 点内息，神木长杖两格碎甲！",
		Mechanics = { SteelBrow = true, ImmuneStun = true, ImmuneDisarm = true, BonusMSkill = 16, BonusMDef = 12, AuraRadius = 3, AuraFatigue = 12, OnHitArmorBurn = 20 },
		CoreID = "wx_core_kuafu", LairID = "shanhai_kuafu",
		CustomBodySprite = "wx_boss_kuafu", CustomHeadSprite = null
	},
	boss_chiyou = {
		Key = "chiyou", BossID = "boss_chiyou", Chapter = "大荒海内经", Name = "【山海兵主】凶黎古冢·铜头铁额蚩尤战魄",
		EntityType = "OrcWarlord", BaseTroop = "OrcWarlord",
		Script = "scripts/entity/tactical/enemies/wx_boss_chiyou", ParentScript = "scripts/entity/tactical/enemies/orc_warlord",
		HpMult = 1.90, MeleeSkillBonus = 18, MeleeDefBonus = 14, BraveryBonus = 99, Strength = 68,
		TraitName = "铜头铁额·万古五兵之主", TraitDesc = "《大荒北经》造五兵兴云雾之万古兵主残魄：铜头免爆头、免眩晕缴械、免围攻惩罚；半血以下五兵煞气总伤 +30%，每击崩甲破绽！",
		Mechanics = { SteelBrow = true, Underdog = true, ImmuneStun = true, ImmuneDisarm = true, MinAP = 10, BonusMSkill = 16, BonusMDef = 14, EnrageBelowPct = 0.55, EnrageDmgMult = 1.30, OnHitArmorBurn = 24, OnHitOpening = true },
		CoreID = "wx_core_chiyou", LairID = "shanhai_chiyou",
		CustomBodySprite = "wx_boss_chiyou", CustomHeadSprite = null
	},
	boss_zaochi = {
		Key = "zaochi", BossID = "boss_zaochi", Chapter = "大荒海内经", Name = "【山海凶魔】畴华野·丈齿持盾凿齿王",
		EntityType = "SkeletonBoss", BaseTroop = "SkeletonHeavy",
		Script = "scripts/entity/tactical/enemies/wx_boss_zaochi", ParentScript = "scripts/entity/tactical/enemies/skeleton_boss",
		HpMult = 2.25, MeleeSkillBonus = 15, MeleeDefBonus = 18, BraveryBonus = 99, Strength = 60,
		TraitName = "丈齿戈盾·铁壁噬心", TraitDesc = "《海外南经》畴华之野齿长六尺如凿、持戈盾抗神羿之凶魔：巨盾护体近远双防 +20，反击撕咬直穿重铠造成【内伤】与【流血】！",
		Mechanics = { SteelBrow = true, ImmuneDisarm = true, BonusMSkill = 12, BonusMDef = 20, BonusRDef = 22, OnHitInternalInjury = true, OnHitBleed = 10 },
		CoreID = "wx_core_zaochi", LairID = "shanhai_zaochi",
		CustomBodySprite = "wx_boss_zaochi", CustomHeadSprite = null
	},
	boss_erfu = {
		Key = "erfu", BossID = "boss_erfu", Chapter = "大荒海内经", Name = "【山海缚神】疏属山·桎梏龙身贰负尸皇",
		EntityType = "ZombieBetrayer", BaseTroop = "SkeletonHeavy",
		Script = "scripts/entity/tactical/enemies/wx_boss_erfu", ParentScript = "scripts/entity/tactical/enemies/zombie_betrayer",
		HpMult = 2.70, MeleeSkillBonus = 14, MeleeDefBonus = 10, BraveryBonus = 99, Strength = 62,
		TraitName = "疏属反缚·枷锁怨毒复起", TraitDesc = "《海内西经》疏属山右足反缚、人面蛇身之受刑古神怨尸：铁躯减伤 25%、首次濒死挣断铁索复苏 140 气血，枷锁横砸震晕封穴！",
		Mechanics = { SteelBrow = true, RegularMult = 0.75, ReviveOnceHP = 140, BonusMSkill = 14, OnHitAcupoint = true, OnHitOffbalance = true },
		CoreID = "wx_core_erfu", LairID = "shanhai_erfu",
		CustomBodySprite = "wx_boss_erfu", CustomHeadSprite = null
	},
	boss_nvchou = {
		Key = "nvchou", BossID = "boss_nvchou", Chapter = "大荒海内经", Name = "【山海旱魃】十日炙山·青衣赤魃女丑魂",
		EntityType = "Hexe", BaseTroop = "Hexe",
		Script = "scripts/entity/tactical/enemies/wx_boss_nvchou", ParentScript = "scripts/entity/tactical/enemies/hexe",
		HpMult = 3.60, MeleeSkillBonus = 12, MeleeDefBonus = 18, BraveryBonus = 90, Strength = 58,
		TraitName = "十日暴尸·赤地千里旱魃咒", TraitDesc = "《海外西经》丈夫国北十日炙杀山顶、以袂蔽面之大旱女丑尸魂：周身 3 格十日炙热每回合蒸干敌军 10 内息、灼毁 10 护甲，且妖术惑心！",
		Mechanics = { BonusMDef = 18, BonusRDef = 26, RegularMult = 0.70, AuraRadius = 3, AuraFatigue = 10, AuraArmorDmg = 10, AuraResolveOffbalance = true },
		CoreID = "wx_core_nvchou", LairID = "shanhai_nvchou",
		CustomBodySprite = "wx_boss_nvchou", CustomHeadSprite = null
	},
	boss_fangfeng = {
		Key = "fangfeng", BossID = "boss_fangfeng", Chapter = "大荒海内经", Name = "【山海巨灵】会稽古冢·守风防风氏巨骨",
		EntityType = "Unhold", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_fangfeng", ParentScript = "scripts/entity/tactical/enemies/unhold_armored",
		HpMult = 1.90, MeleeSkillBonus = 14, MeleeDefBonus = 12, BraveryBonus = 99, Strength = 66,
		TraitName = "骨节专车·山岳镇压不坏", TraitDesc = "《国语/大荒》大禹会诸侯于涂山所戮防风氏万钧巨骨灵：身躯坚逾顽石（非钝器重锤仅受 60% 伤害），巨骨轰击崩毁重铠并致【内伤】失衡！",
		Mechanics = { SteelBrow = true, ImmuneStun = true, ImmuneDisarm = true, HammerWeakOnly = true, RegenHP = 15, OnHitArmorBurn = 22, OnHitInternalInjury = true, OnHitOffbalance = true },
		CoreID = "wx_core_fangfeng", LairID = "shanhai_fangfeng",
		CustomBodySprite = "wx_boss_fangfeng", CustomHeadSprite = null
	},
	boss_kaiming = {
		Key = "kaiming", BossID = "boss_kaiming", Chapter = "海内西经", Name = "【山海镇神】昆仑虚·九首开明兽",
		EntityType = "Unhold", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_kaiming", ParentScript = "scripts/entity/tactical/enemies/unhold_armored",
		HpMult = 1.50, MeleeSkillBonus = 14, MeleeDefBonus = 14, BraveryBonus = 65, Strength = 58,
		TraitName = "九首环伺·镇守帝门", TraitDesc = "《海内西经》昆仑百神门主：身大类虎而九首人面，免疫爆头、眩晕与围攻近防惩罚，每回合自愈 20 气血且挥爪震退来敌！",
		Mechanics = { SteelBrow = true, Underdog = true, RegenHP = 20, BonusMSkill = 12, BonusMDef = 12, OnHitOffbalance = true },
		CoreID = "wx_core_kaiming", LairID = "shanhai_kaiming",
		CustomBodySprite = "wx_boss_kaiming", CustomHeadSprite = null
	},
	boss_jinwu = {
		Key = "jinwu", BossID = "boss_jinwu", Chapter = "大荒东经", Name = "【山海神禽】汤谷扶桑·三足金乌皇",
		EntityType = "Vampire", BaseTroop = "Vampire",
		Script = "scripts/entity/tactical/enemies/wx_boss_jinwu", ParentScript = "scripts/entity/tactical/enemies/vampire",
		HpMult = 2.45, MeleeSkillBonus = 16, MeleeDefBonus = 16, BraveryBonus = 70, Strength = 58,
		TraitName = "十日耀天·大日焚甲罡", TraitDesc = "《大荒东经》扶桑神木之主：三足金鸦浴火瞬移，周身 2 格大日真火每回合灼毁敌军 15 点身甲并蒸干 10 点内息！",
		Mechanics = { MinAP = 10, BonusInit = 32, BonusMDef = 16, BonusRDef = 22, AuraRadius = 2, AuraArmorDmg = 15, AuraFatigue = 10 },
		CoreID = "wx_core_jinwu", LairID = "shanhai_jinwu",
		CustomBodySprite = "wx_boss_jinwu", CustomHeadSprite = null
	},
	boss_zouyu = {
		Key = "zouyu", BossID = "boss_zouyu", Chapter = "海内北经", Name = "【山海仁瑞】林氏国·五采驺虞王",
		EntityType = "Hyena", BaseTroop = "Hyena",
		Script = "scripts/entity/tactical/enemies/wx_boss_zouyu", ParentScript = "scripts/entity/tactical/enemies/hyena_high",
		HpMult = 3.45, MeleeSkillBonus = 18, MeleeDefBonus = 16, BraveryBonus = 65, Strength = 54,
		TraitName = "日行千里·五采仁威", TraitDesc = "《海内北经》尾长于身之五采神虎：常驻 11 AP、极速先手，每回合首杀回返 3 AP，利爪撕裂护甲并令恶徒动摇！",
		Mechanics = { MinAP = 11, BonusInit = 38, BonusMSkill = 14, BonusMDef = 14, KillRefundAP = 3, OnHitBleed = 10 },
		CoreID = "wx_core_zouyu", LairID = "shanhai_zouyu",
		CustomBodySprite = "wx_boss_zouyu", CustomHeadSprite = null
	},
	boss_gonggong = {
		Key = "gonggong", BossID = "boss_gonggong", Chapter = "大荒西经", Name = "【山海古神】不周山·共工怒涛水煞",
		EntityType = "Lindwurm", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_gonggong", ParentScript = "scripts/entity/tactical/enemies/lindwurm",
		HpMult = 1.45, MeleeSkillBonus = 12, MeleeDefBonus = 10, BraveryBonus = 75, Strength = 66,
		TraitName = "怒触不周·天倾黑水潮", TraitDesc = "《大荒西经》赤发人面蛇身水神遗煞：免疫爆头与点穴，周身 2 格黑水寒潮每回合侵蚀 8 点气血并封锁敌军内息！",
		Mechanics = { SteelBrow = true, BonusMSkill = 12, BonusMDef = 10, AuraRadius = 2, AuraHpDmg = 8, AuraFatigue = 10, OnHitAcupoint = true },
		CoreID = "wx_core_gonggong", LairID = "shanhai_gonggong",
		CustomBodySprite = "wx_boss_gonggong", CustomHeadSprite = null
	},
	boss_wuluo = {
		Key = "wuluo", BossID = "boss_wuluo", Chapter = "中山经", Name = "【山海神女】青要山·豹纹武罗妖神",
		EntityType = "Hexe", BaseTroop = "Hexe",
		Script = "scripts/entity/tactical/enemies/wx_boss_wuluo", ParentScript = "scripts/entity/tactical/enemies/hexe",
		HpMult = 3.60, MeleeSkillBonus = 14, MeleeDefBonus = 18, BraveryBonus = 65, Strength = 56,
		TraitName = "穿耳金鐻·青要摄魂歌", TraitDesc = "《中山经》帝之密都神女：人面豹纹小腰白齿，鸣玉环摄夺敌军心魄，高额身法避暗并魅惑前排猛士自相残杀！",
		Mechanics = { BonusInit = 26, BonusMDef = 20, BonusRDef = 30, RegularMult = 0.65, AuraRadius = 3, AuraResolveOffbalance = true },
		CoreID = "wx_core_wuluo", LairID = "shanhai_wuluo",
		CustomBodySprite = "wx_boss_wuluo", CustomHeadSprite = null
	},
	boss_siwang = {
		Key = "siwang", BossID = "boss_siwang", Chapter = "海内南经", Name = "【山海凶兽】苍梧野·独角青兕王",
		EntityType = "Unhold", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_siwang", ParentScript = "scripts/entity/tactical/enemies/unhold_armored",
		HpMult = 1.55, MeleeSkillBonus = 14, MeleeDefBonus = 10, BraveryBonus = 60, Strength = 58,
		TraitName = "苍兕裂甲·重角破城冲", TraitDesc = "《海内南经》苍黑一角重甲巨兽：铜头铁额减免远射伤害三成，重角顶撞直接碎裂护甲并震飞盾卫！",
		Mechanics = { SteelBrow = true, RangedMult = 0.70, BonusMSkill = 14, BonusMDef = 10, OnHitArmorBurn = 22, OnHitOffbalance = true },
		CoreID = "wx_core_siwang", LairID = "shanhai_siwang",
		CustomBodySprite = "wx_boss_siwang", CustomHeadSprite = null
	},
	boss_jiufeng = {
		Key = "jiufeng", BossID = "boss_jiufeng", Chapter = "大荒北经", Name = "【山海妖皇】大荒北极·九首鬼车九凤",
		EntityType = "Vampire", BaseTroop = "Vampire",
		Script = "scripts/entity/tactical/enemies/wx_boss_jiufeng", ParentScript = "scripts/entity/tactical/enemies/vampire",
		HpMult = 2.50, MeleeSkillBonus = 16, MeleeDefBonus = 16, BraveryBonus = 70, Strength = 58,
		TraitName = "九首泣血·北极摄魂瘴", TraitDesc = "《大荒北经》北极人面九首妖禽：夜影瞬移噬血回春，每次扑击吸取 30 点气血并散播泣血奇瘴动摇军心！",
		Mechanics = { MinAP = 10, BonusInit = 28, BonusMDef = 16, OnHitDrainHP = 30, OnHitBleed = 10, AuraRadius = 3, AuraResolveOffbalance = true },
		CoreID = "wx_core_jiufeng", LairID = "shanhai_jiufeng",
		CustomBodySprite = "wx_boss_jiufeng", CustomHeadSprite = null
	},
	boss_mingshe = {
		Key = "mingshe", BossID = "boss_mingshe", Chapter = "中山经", Name = "【山海凶蟒】鲜山·四翼磐音鸣蛇",
		EntityType = "Serpent", BaseTroop = "Serpent",
		Script = "scripts/entity/tactical/enemies/wx_boss_mingshe", ParentScript = "scripts/entity/tactical/enemies/serpent",
		HpMult = 3.15, MeleeSkillBonus = 15, MeleeDefBonus = 14, BraveryBonus = 60, Strength = 54,
		TraitName = "其音如磬·四翼旱雷震", TraitDesc = "《中山经》蛇身四翼奇蟒：翼振声如古磬震裂耳膜，周身 2 格散播燥热音障削耗内息，噬咬附剧毒与失衡！",
		Mechanics = { BonusInit = 28, BonusMSkill = 14, BonusMDef = 14, AuraRadius = 2, AuraFatigue = 9, AuraResolveOffbalance = true, OnHitPoison = true },
		CoreID = "wx_core_mingshe", LairID = "shanhai_mingshe",
		CustomBodySprite = "wx_boss_mingshe", CustomHeadSprite = null
	},
	boss_huashe = {
		Key = "huashe", BossID = "boss_huashe", Chapter = "中山经", Name = "【山海凶蛟】阳山·人面鸟翼化蛇",
		EntityType = "Lindwurm", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_huashe", ParentScript = "scripts/entity/tactical/enemies/lindwurm",
		HpMult = 1.38, MeleeSkillBonus = 12, MeleeDefBonus = 12, BraveryBonus = 60, Strength = 62,
		TraitName = "见则大水·寒渊翼蛟噬", TraitDesc = "《中山经》人面豺身鸟翼蛇行大妖：寒水鳞甲减免远射，挥尾横扫封锁经脉并抽取近身敌手 12 点内息！",
		Mechanics = { BonusMSkill = 12, BonusMDef = 12, BonusRDef = 18, RangedMult = 0.72, OnHitDrainQi = 12, OnHitAcupoint = true },
		CoreID = "wx_core_huashe", LairID = "shanhai_huashe",
		CustomBodySprite = "wx_boss_huashe", CustomHeadSprite = null
	},
	boss_fuzhu = {
		Key = "fuzhu", BossID = "boss_fuzhu", Chapter = "中山经", Name = "【山海异兽】敖岸山·四角白鹿夫诸",
		EntityType = "UnholdFrost", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_fuzhu", ParentScript = "scripts/entity/tactical/enemies/unhold_frost",
		HpMult = 1.45, MeleeSkillBonus = 14, MeleeDefBonus = 16, BraveryBonus = 60, Strength = 54,
		TraitName = "四角凝霜·白鹿幻水障", TraitDesc = "《中山经》状如白鹿而四角之灵异大妖：高闪避灵动腾跃，每回合自愈 22 气血，霜角挑刺直透重甲并封穴！",
		Mechanics = { RegenHP = 22, BonusInit = 25, BonusMSkill = 14, BonusMDef = 16, BonusRDef = 20, OnHitAcupoint = true },
		CoreID = "wx_core_fuzhu", LairID = "shanhai_fuzhu",
		CustomBodySprite = "wx_boss_fuzhu", CustomHeadSprite = null
	},
	boss_chenghuang = {
		Key = "chenghuang", BossID = "boss_chenghuang", Chapter = "海外西经", Name = "【山海神兽】白民国·背角神狐乘黄",
		EntityType = "Hyena", BaseTroop = "Hyena",
		Script = "scripts/entity/tactical/enemies/wx_boss_chenghuang", ParentScript = "scripts/entity/tactical/enemies/hyena_high",
		HpMult = 3.35, MeleeSkillBonus = 16, MeleeDefBonus = 18, BraveryBonus = 65, Strength = 54,
		TraitName = "寿逾二千·乘黄瑞角反噬", TraitDesc = "《海外西经》背生龙角之长寿神狐：常驻 11 AP、极高双防与生机自愈，咬击汲血并令贪功冒进者露破绽！",
		Mechanics = { MinAP = 11, RegenHP = 18, BonusInit = 35, BonusMDef = 18, BonusRDef = 20, OnHitDrainHP = 20, OnHitOffbalance = true },
		CoreID = "wx_core_chenghuang", LairID = "shanhai_chenghuang",
		CustomBodySprite = "wx_boss_chenghuang", CustomHeadSprite = null
	},
	boss_dangkang = {
		Key = "dangkang", BossID = "boss_dangkang", Chapter = "东山经", Name = "【山海瑞凶】钦山·巨牙当康兽王",
		EntityType = "OrcBerserker", BaseTroop = "OrcBerserker",
		Script = "scripts/entity/tactical/enemies/wx_boss_dangkang", ParentScript = "scripts/entity/tactical/enemies/orc_berserker",
		HpMult = 2.35, MeleeSkillBonus = 16, MeleeDefBonus = 10, BraveryBonus = 65, Strength = 54,
		TraitName = "其鸣自叫·巨牙破阵突", TraitDesc = "《东山经》状如巨豚而獠牙如刀之猛兽：气血低于七成即狂暴增伤 30%、免疫眩晕，巨牙猛拱连破重甲与战意！",
		Mechanics = { SteelBrow = true, EnrageBelowPct = 0.70, EnrageMSkill = 12, EnrageDmgMult = 1.30, EnrageImmuneCC = true, OnHitArmorBurn = 20, OnHitBleed = 10 },
		CoreID = "wx_core_dangkang", LairID = "shanhai_dangkang",
		CustomBodySprite = "wx_boss_dangkang", CustomHeadSprite = null
	},
	boss_boshi = {
		Key = "boshi", BossID = "boss_boshi", Chapter = "南山经", Name = "【山海异兽】基山·背目九尾猼訑",
		EntityType = "Unhold", BaseTroop = "Unhold",
		Script = "scripts/entity/tactical/enemies/wx_boss_boshi", ParentScript = "scripts/entity/tactical/enemies/unhold",
		HpMult = 1.48, MeleeSkillBonus = 12, MeleeDefBonus = 18, BraveryBonus = 80, Strength = 54,
		TraitName = "其目在背·著之不畏", TraitDesc = "《南山经》九尾四耳背生神目之异兽：背后生眼令一切围攻夹击失效（免围攻惩罚、近防暴涨），且定力如山永不动摇！",
		Mechanics = { Underdog = true, SteelBrow = true, BonusMDef = 18, BonusRDef = 16, BonusBravery = 50, RegenHP = 18 },
		CoreID = "wx_core_boshi", LairID = "shanhai_boshi",
		CustomBodySprite = "wx_boss_boshi", CustomHeadSprite = null
	},
	boss_jiao = {
		Key = "jiao", BossID = "boss_jiao", Chapter = "西山经", Name = "【山海异兽】玉山·豹纹牛角神狡",
		EntityType = "Direwolf", BaseTroop = "Direwolf",
		Script = "scripts/entity/tactical/enemies/wx_boss_jiao", ParentScript = "scripts/entity/tactical/enemies/direwolf_high",
		HpMult = 3.50, MeleeSkillBonus = 18, MeleeDefBonus = 14, BraveryBonus = 60, Strength = 52,
		TraitName = "豹文牛角·裂甲噬喉扑", TraitDesc = "《西山经》王母玉山异兽：状如巨犬而豹纹牛角，兼具恶狼连扑与重角破甲之威，每击焚毁 16 点护甲并致深创流血！",
		Mechanics = { MinAP = 10, BonusInit = 30, BonusMSkill = 16, BonusMDef = 12, OnHitArmorBurn = 16, OnHitBleed = 12 },
		CoreID = "wx_core_jiao", LairID = "shanhai_jiao",
		CustomBodySprite = "wx_boss_jiao", CustomHeadSprite = null
	},
	boss_bingyi = {
		Key = "bingyi", BossID = "boss_bingyi", Chapter = "海内北经", Name = "【山海河伯】从极渊·御龙冰夷水君",
		EntityType = "SkeletonBoss", BaseTroop = "SkeletonHeavy",
		Script = "scripts/entity/tactical/enemies/wx_boss_bingyi", ParentScript = "scripts/entity/tactical/enemies/skeleton_boss",
		HpMult = 2.15, MeleeSkillBonus = 14, MeleeDefBonus = 14, BraveryBonus = 99, Strength = 60,
		TraitName = "乘两龙行·从极万古霜", TraitDesc = "《海内北经》深渊三百仞河伯古神：免疫点穴奇毒与爆头，周身 2 格万古寒霜每回合冻结敌军 12 点内息并令其失衡！",
		Mechanics = { SteelBrow = true, ImmuneStun = true, BonusMSkill = 14, BonusMDef = 14, AuraRadius = 2, AuraFatigue = 12, AuraResolveOffbalance = true, OnHitAcupoint = true },
		CoreID = "wx_core_bingyi", LairID = "shanhai_bingyi",
		CustomBodySprite = "wx_boss_bingyi", CustomHeadSprite = null
	},
	boss_qiangliang = {
		Key = "qiangliang", BossID = "boss_qiangliang", Chapter = "大荒北经", Name = "【山海尸神】大荒北山·虎首衔蛇强良",
		EntityType = "OrcWarlord", BaseTroop = "OrcWarlord",
		Script = "scripts/entity/tactical/enemies/wx_boss_qiangliang", ParentScript = "scripts/entity/tactical/enemies/orc_warlord",
		HpMult = 1.85, MeleeSkillBonus = 16, MeleeDefBonus = 12, BraveryBonus = 85, Strength = 62,
		TraitName = "虎首衔蛇·北山戮神戈", TraitDesc = "《大荒北经》虎首人身四蹄长肘凶神：口衔赤蛇、执掌重戈，半血狂暴总伤 +28%，击中同时注入赤蛇奇毒并每轮首杀返 3 AP！",
		Mechanics = { SteelBrow = true, Underdog = true, EnrageBelowPct = 0.55, EnrageDmgMult = 1.28, KillRefundAP = 3, OnHitPoison = true, OnHitBleed = 10 },
		CoreID = "wx_core_qiangliang", LairID = "shanhai_qiangliang",
		CustomBodySprite = "wx_boss_qiangliang", CustomHeadSprite = null
	},
};

::Wuxia.Config.ShanHaiCores <- {
	wx_core_zhuyan = {
		ID = "wx_core_zhuyan", Chapter = "西山经", Name = "【山海内丹】朱厌沸血丹核", Value = 1800, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_zhuyan.png",
		Description = "取自小次山朱厌猿王胸腔的滚烫赤红内丹：可在百工坊锻造【山海·朱厌白首狂血铠】，亦可拖入武学槽炼化灌注 350 点火候。"
	},
	wx_core_feiyi = {
		ID = "wx_core_feiyi", Chapter = "西山经", Name = "【山海内丹】肥遗旱火毒丹", Value = 1800, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_feiyi.png",
		Description = "太华六足肥遗王体内凝结的紫赤毒丹：可在百工坊配合肥遗重鳞锻造【山海·太华肥遗逆鳞甲】，或拖入武学槽炼化灌顶。"
	},
	wx_core_qiongqi = {
		ID = "wx_core_qiongqi", Chapter = "北山经", Name = "【山海内丹】穷奇裂风妖丹", Value = 1800, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_qiongqi.png",
		Description = "旋绕恶风的青苍色凶兽内丹：可在百工坊打造【山海·穷奇逐风翼皮甲】或凶兵【穷奇裂风血骨爪】，亦可拖入武学槽炼化灌顶。"
	},
	wx_core_taotie = {
		ID = "wx_core_taotie", Chapter = "北山经", Name = "【山海内丹】饕餮噬元凶丹", Value = 1800, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_taotie.png",
		Description = "凶煞逼人的暗金兽丹：可在百工坊锻造传世重胄【山海·饕餮吞天兽面胄】，亦可拖入武学槽炼化灌顶。"
	},
	wx_core_jiuwei = {
		ID = "wx_core_jiuwei", Chapter = "南山经", Name = "【山海内丹】青丘九尾幻丹", Value = 1800, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_jiuwei.png",
		Description = "流转九色霞光的通灵妖丹：可在百工坊炼制传世佩饰【山海·青丘定魂辟邪佩】，亦可拖入武学槽炼化灌顶。"
	},
	wx_core_bashe = {
		ID = "wx_core_bashe", Chapter = "南山经", Name = "【山海内丹】苍梧巴蛇吞象胆", Value = 1800, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_bashe.png",
		Description = "碧绿如翡翠的千年蛇王苦胆内丹：可在百工坊裁制【山海·苍梧巴蛇碧鳞冠】，亦可拖入武学槽炼化灌顶。"
	},
	wx_core_jumang = {
		ID = "wx_core_jumang", Chapter = "中山经", Name = "【山海内丹】都广建木神心", Value = 1800, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_jumang.png",
		Description = "蕴藏蓬勃草木精气的万年神木核心：可在百工坊锻造【山海·句芒建木生机甲】，亦可拖入武学槽炼化灌顶。"
	},
	wx_core_wuzhiqi = {
		ID = "wx_core_wuzhiqi", Chapter = "中山经", Name = "【山海内丹】无支祁寒渊定水珠", Value = 1800, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_wuzhiqi.png",
		Description = "淮水妖王口含千年的冰蓝水灵宝珠：可在百工坊炼制【山海·淮水辟毒寒渊珠】，亦可拖入武学槽炼化灌顶。"
	},
	wx_core_xingtian = {
		ID = "wx_core_xingtian", Chapter = "大荒海内经", Name = "【山海内丹】常羊刑天不灭战髓", Value = 2200, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_xingtian.png",
		Description = "凝结千年不屈战意的暗赤神髓：可在百工坊重铸无上凶兵【刑天舞干断首戚】，亦可拖入武学槽炼化灌顶。"
	},
	wx_core_bifang = {
		ID = "wx_core_bifang", Chapter = "南山经", Name = "【山海内丹】章莪毕方讹火翎丹", Value = 1950, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_bifang.png",
		Description = "跳动幽青诡火的毕方妖皇内丹，触之炽热不灭，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_gudiaowang = {
		ID = "wx_core_gudiaowang", Chapter = "南山经", Name = "【山海内丹】鹿吴蛊雕摄魂丹", Value = 1850, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_gudiaowang.png",
		Description = "隐现凄厉怨音的斑斓妖丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_xingxing = {
		ID = "wx_core_xingxing", Chapter = "南山经", Name = "【山海内丹】招摇狌狌通明丹", Value = 1900, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_xingxing.png",
		Description = "晶莹澄澈的招摇山老妖灵丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_zhujian = {
		ID = "wx_core_zhujian", Chapter = "南山经", Name = "【山海内丹】单狐猪建狂风丹", Value = 1850, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_zhujian.png",
		Description = "狂飙内敛的赤褐兽丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_xuangui = {
		ID = "wx_core_xuangui", Chapter = "南山经", Name = "【山海内丹】杻阳玄龟镇海元珠", Value = 2000, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_xuangui.png",
		Description = "沉重如山岳的墨黑龟甲元珠，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_yuanchu = {
		ID = "wx_core_yuanchu", Chapter = "南山经", Name = "【山海内丹】丹穴堕火涅槃晶", Value = 2000, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_yuanchu.png",
		Description = "赤紫妖火凝固而成的古禽晶核，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_yingzhao = {
		ID = "wx_core_yingzhao", Chapter = "西山经", Name = "【山海内丹】昆仑英招巡天金丹", Value = 2100, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_yingzhao.png",
		Description = "烙印虎纹风翼的赤金神孽内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_luwu = {
		ID = "wx_core_luwu", Chapter = "西山经", Name = "【山海内丹】昆仑陆吾九部帝丹", Value = 2200, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_luwu.png",
		Description = "堂皇威严的九道金纹白虎神丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_qinyuan = {
		ID = "wx_core_qinyuan", Chapter = "西山经", Name = "【山海内丹】昆仑钦原万蛊毒珠", Value = 1950, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_qinyuan.png",
		Description = "墨绿幽光流转的剧毒蛊皇宝珠，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_tiangouwang = {
		ID = "wx_core_tiangouwang", Chapter = "西山经", Name = "【山海内丹】阴山天狗坠星核", Value = 2000, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_tiangouwang.png",
		Description = "宛如天外陨铁般炽白滚烫的天狗妖丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_zheng = {
		ID = "wx_core_zheng", Chapter = "西山经", Name = "【山海内丹】章峨赤狰独角丹", Value = 1900, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_zheng.png",
		Description = "铿锵作金石之音的赤褐晶丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_hundun = {
		ID = "wx_core_hundun", Chapter = "西山经", Name = "【山海内丹】天山浑沌无窍元胎", Value = 2300, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_hundun.png",
		Description = "混沌未分、丹火流转的四凶元胎至宝，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_yayu = {
		ID = "wx_core_yayu", Chapter = "北山经", Name = "【山海内丹】少咸猰貐逆命血丹", Value = 2150, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_yayu.png",
		Description = "跳动如活物心脏的暗红凶神内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_zhuyin = {
		ID = "wx_core_zhuyin", Chapter = "北山经", Name = "【山海内丹】钟山烛阴昼夜龙珠", Value = 2500, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_zhuyin.png",
		Description = "半边冰魄彻骨、半边赤阳焚天之太古龙珠，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_dijiang = {
		ID = "wx_core_dijiang", Chapter = "北山经", Name = "【山海内丹】天山帝江幻空丹", Value = 2050, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_dijiang.png",
		Description = "赤如丹火、隐现涟漪波纹的奇异神丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_paoxiaowang = {
		ID = "wx_core_paoxiaowang", Chapter = "北山经", Name = "【山海内丹】北山狍鸮腋目妖珠", Value = 1950, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_paoxiaowang.png",
		Description = "状若森然竖瞳的暗赤妖珠，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_changyou = {
		ID = "wx_core_changyou", Chapter = "北山经", Name = "【山海内丹】小侯长右听涛寒丹", Value = 1900, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_changyou.png",
		Description = "泛着滔天水汽的苍蓝妖丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_mengji = {
		ID = "wx_core_mengji", Chapter = "北山经", Name = "【山海内丹】石者孟极隐猎白丹", Value = 1900, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_mengji.png",
		Description = "莹白如雪、隐现黑豹雷纹的兽皇内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_kui = {
		ID = "wx_core_kui", Chapter = "东山经", Name = "【山海内丹】流波夔牛紫电雷核", Value = 2300, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_kui.png",
		Description = "雷弧噼啪作响的苍青夔牛内丹，黄帝曾取其皮为鼓声闻五百里，可在「武学修为」页炼化灌顶（+350 火候）。"
	},
	wx_core_fei = {
		ID = "wx_core_fei", Chapter = "东山经", Name = "【山海内丹】太山白首蜚疫源毒丹", Value = 2250, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_fei.png",
		Description = "灰白死气萦绕的太山灾兽凶丹，唯有至强心法可炼化其霸道精元（拖入武学槽 +350 火候）。"
	},
	wx_core_yinglong = {
		ID = "wx_core_yinglong", Chapter = "东山经", Name = "【山海内丹】凶犁应龙真灵逆鳞珠", Value = 2600, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_yinglong.png",
		Description = "蕴藏上古应龙浩瀚水雷神力的无上龙珠，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_taowu = {
		ID = "wx_core_taowu", Chapter = "东山经", Name = "【山海内丹】荒中檮杌傲狠凶魂丹", Value = 2300, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_taowu.png",
		Description = "凶戾霸道绝不屈服的四凶檮杌战丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_hujiao = {
		ID = "wx_core_hujiao", Chapter = "东山经", Name = "【山海内丹】玉山虎蛟斑斓内丹", Value = 1900, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_hujiao.png",
		Description = "黄黑虎斑交织的水蛟毒丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_zhuhuai = {
		ID = "wx_core_zhuhuai", Chapter = "东山经", Name = "【山海内丹】北岳诸怀四角凶丹", Value = 1900, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_zhuhuai.png",
		Description = "生有四道骨棱的赤黑凶兽内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_shebishi = {
		ID = "wx_core_shebishi", Chapter = "东山经", Name = "【山海内丹】大荒奢比尸青蛇尸丹", Value = 2100, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_shebishi.png",
		Description = "两条碧绿小蛇魂影盘绕的古尸神冥丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_jingwei = {
		ID = "wx_core_jingwei", Chapter = "东山经", Name = "【山海内丹】发鸠精卫填海魂晶", Value = 2050, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_jingwei.png",
		Description = "封存一缕沧海不屈执念的湛蓝魂晶，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_jiuying = {
		ID = "wx_core_jiuying", Chapter = "中山经", Name = "【山海内丹】凶水九婴水火双生丹", Value = 2400, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_jiuying.png",
		Description = "水蓝与赤火九窍交融的旷世大妖内丹，昔日羿射杀九婴之处遗种，可拖入武学槽炼化灌顶（+350 火候）。"
	},
	wx_core_feilian = {
		ID = "wx_core_feilian", Chapter = "中山经", Name = "【山海内丹】鹿台飞廉御风神丹", Value = 2150, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_feilian.png",
		Description = "疾风流转不止的青金风伯内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_baize = {
		ID = "wx_core_baize", Chapter = "中山经", Name = "【山海内丹】东望白泽通玄宝丹", Value = 2350, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_baize.png",
		Description = "澄明浩瀚、映照百鬼图谱的雪白神兽宝丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_shanhui = {
		ID = "wx_core_shanhui", Chapter = "中山经", Name = "【山海内丹】狱法山挥疾风妖丸", Value = 1850, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_shanhui.png",
		Description = "轻灵回旋的青褐妖丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_bo = {
		ID = "wx_core_bo", Chapter = "中山经", Name = "【山海内丹】中曲食虎铁驳战丹", Value = 2000, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_bo.png",
		Description = "银白坚硬如百炼精钢的猛兽内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_huodou = {
		ID = "wx_core_huodou", Chapter = "中山经", Name = "【山海内丹】厌火祸斗焚天炎珠", Value = 1950, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_huodou.png",
		Description = "吞吐赤黑毒烟的火妖内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_xiangliuwang = {
		ID = "wx_core_xiangliuwang", Chapter = "大荒海内经", Name = "【山海内丹】共工台相柳九首苦毒源珠", Value = 2550, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_xiangliuwang.png",
		Description = "腥苦霸道、腐蚀万物的九首凶神本源毒珠，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_kuafu = {
		ID = "wx_core_kuafu", Chapter = "大荒海内经", Name = "【山海内丹】逐日夸父邓林神木髓", Value = 2400, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_kuafu.png",
		Description = "滚烫如烈日余烬又生桃木清气的巨神骨髓，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_chiyou = {
		ID = "wx_core_chiyou", Chapter = "大荒海内经", Name = "【山海内丹】凶黎蚩尤铜头兵主战魄", Value = 2600, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_chiyou.png",
		Description = "刀枪剑戟虚影铮鸣的赤铜兵主神核，天下外家武人梦寐以求之至宝（拖入武学槽 +350 火候）。"
	},
	wx_core_zaochi = {
		ID = "wx_core_zaochi", Chapter = "大荒海内经", Name = "【山海内丹】畴华凿齿破甲凶牙髓", Value = 2100, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_zaochi.png",
		Description = "森白锋锐如百炼铁凿的凶神牙髓，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_erfu = {
		ID = "wx_core_erfu", Chapter = "大荒海内经", Name = "【山海内丹】疏属贰负缚神怨丹", Value = 2200, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_erfu.png",
		Description = "缠绕玄铁怨气的暗紫古神尸丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_nvchou = {
		ID = "wx_core_nvchou", Chapter = "大荒海内经", Name = "【山海内丹】十日女丑赤旱魃珠", Value = 2200, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_nvchou.png",
		Description = "酷烈无匹、滴水不存的青赤旱魃魂珠，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_fangfeng = {
		ID = "wx_core_fangfeng", Chapter = "大荒海内经", Name = "【山海内丹】会稽防风专车神骨髓", Value = 2450, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_fangfeng.png",
		Description = "一节足装一车之防风巨神万古骨髓晶核，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_kaiming = {
		ID = "wx_core_kaiming", Chapter = "海内西经", Name = "【山海内丹】昆仑开明九首虎魄丹", Value = 2450, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_kaiming.png",
		Description = "流转昆仑金芒的九窍虎神宝丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_jinwu = {
		ID = "wx_core_jinwu", Chapter = "大荒东经", Name = "【山海内丹】汤谷三足金乌大日真丹", Value = 2550, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_jinwu.png",
		Description = "炽白夺目如小太阳般滚烫的神鸦火丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_zouyu = {
		ID = "wx_core_zouyu", Chapter = "海内北经", Name = "【山海内丹】林氏五采驺虞瑞虎丸", Value = 2250, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_zouyu.png",
		Description = "五色祥光萦绕的灵虎内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_gonggong = {
		ID = "wx_core_gonggong", Chapter = "大荒西经", Name = "【山海内丹】不周共工天倾黑水珠", Value = 2600, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_gonggong.png",
		Description = "沉重如万钧寒渊之水的赤纹玄珠，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_wuluo = {
		ID = "wx_core_wuluo", Chapter = "中山经", Name = "【山海内丹】青要武罗鸣玉魅神珠", Value = 2200, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_wuluo.png",
		Description = "清脆铮鸣如佩环相击的斑斓宝珠，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_siwang = {
		ID = "wx_core_siwang", Chapter = "海内南经", Name = "【山海内丹】苍梧独角青兕镇岳丹", Value = 2300, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_siwang.png",
		Description = "青黑厚重如古铁锭的巨兕内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_jiufeng = {
		ID = "wx_core_jiufeng", Chapter = "大荒北经", Name = "【山海内丹】北极九凤泣血妖皇珠", Value = 2500, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_jiufeng.png",
		Description = "九道赤黑血丝盘旋流转的妖皇内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_mingshe = {
		ID = "wx_core_mingshe", Chapter = "中山经", Name = "【山海内丹】鲜山四翼鸣蛇磬音胆", Value = 2150, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_mingshe.png",
		Description = "轻叩即发金石清磬之音的赤金蛇胆，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_huashe = {
		ID = "wx_core_huashe", Chapter = "中山经", Name = "【山海内丹】阳山鸟翼化蛇玄水珠", Value = 2250, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_huashe.png",
		Description = "幽蓝寒气凝聚不散的异蛟水丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_fuzhu = {
		ID = "wx_core_fuzhu", Chapter = "中山经", Name = "【山海内丹】敖岸四角夫诸霜鹿茸丹", Value = 2150, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_fuzhu.png",
		Description = "洁白莹润如万年寒玉的四角灵鹿内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_chenghuang = {
		ID = "wx_core_chenghuang", Chapter = "海外西经", Name = "【山海内丹】白民乘黄二千岁寿元丹", Value = 2400, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_chenghuang.png",
		Description = "琥珀金光流淌、馥郁延年的神狐内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_dangkang = {
		ID = "wx_core_dangkang", Chapter = "东山经", Name = "【山海内丹】钦山巨牙当康丰穰髓", Value = 2100, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_dangkang.png",
		Description = "蕴藏磅礴生机与蛮横气力的青玉兽髓，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_boshi = {
		ID = "wx_core_boshi", Chapter = "南山经", Name = "【山海内丹】基山背目猼訑无畏丹", Value = 2150, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_boshi.png",
		Description = "四窍九纹、佩之令人胆气豪壮的奇兽内丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_jiao = {
		ID = "wx_core_jiao", Chapter = "西山经", Name = "【山海内丹】玉山豹纹神狡破甲丸", Value = 2150, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_jiao.png",
		Description = "烙有金钱豹纹的赤金兽丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_bingyi = {
		ID = "wx_core_bingyi", Chapter = "海内北经", Name = "【山海内丹】从极渊冰夷御龙寒髓", Value = 2500, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_bingyi.png",
		Description = "冰封两条微缩龙影的万载玄冰神髓，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
	wx_core_qiangliang = {
		ID = "wx_core_qiangliang", Chapter = "大荒北经", Name = "【山海内丹】北山强良虎首衔蛇煞丹", Value = 2550, ExpAmount = 350,
		Icon = "misc/inventory_anatomists_book_01.png", CustomIcon = "misc/wx_core_qiangliang.png",
		Description = "虎煞刀兵气与赤蛇毒火交织的霸道凶丹，可在「武学修为」页拖入插槽炼化灌顶（+350 火候）。"
	},
};

::Wuxia.Config.ShanHaiGear <- {
	wx_armor_zhuyan = {
		ID = "wx_armor_zhuyan", Kind = "armor", Name = "山海·朱厌白首狂血铠", Value = 7500,
		MinCondition = 310, MaxStamPen = -28,
		CustomIcon = "armor/wx_armor_zhuyan_70x70.png", CustomIconLarge = "armor/wx_armor_zhuyan.png",
		Description = "以小次山朱厌猿王沸血丹核与白首巨猿厚革千锤百锻而成的山海重铠，坚逾精铁而血气暗涌。"
	},
	wx_armor_feiyi = {
		ID = "wx_armor_feiyi", Kind = "armor", Name = "山海·太华肥遗逆鳞甲", Value = 7600,
		MinCondition = 260, MaxStamPen = -21,
		CustomIcon = "armor/wx_armor_feiyi_70x70.png", CustomIconLarge = "armor/wx_armor_feiyi.png",
		Description = "取太华六足肥遗王毒丹与赤黑逆鳞编缀的传世宝甲，水火毒血难侵，攻守兼备。"
	},
	wx_armor_qiongqi = {
		ID = "wx_armor_qiongqi", Kind = "armor", Name = "山海·穷奇逐风翼皮甲", Value = 7200,
		MinCondition = 168, MaxStamPen = -8,
		CustomIcon = "armor/wx_armor_qiongqi_70x70.png", CustomIconLarge = "armor/wx_armor_qiongqi.png",
		Description = "融穷奇裂风妖丹与西山异兽斑革精裁的绝顶布衣轻甲：轻若鸿毛（完美契合《金蝉卸力》），防护却傲视寻常皮甲！"
	},
	wx_armor_jumang = {
		ID = "wx_armor_jumang", Kind = "armor", Name = "山海·句芒建木生机甲", Value = 7600,
		MinCondition = 325, MaxStamPen = -26,
		CustomIcon = "armor/wx_armor_jumang_70x70.png", CustomIconLarge = "armor/wx_armor_jumang.png",
		Description = "以都广建木万年神心与灵脂浸润甲叶锻成的苍翠重铠，生机流转，较寻常重甲大幅节省内息消耗。"
	},
	wx_helm_taotie = {
		ID = "wx_helm_taotie", Kind = "helmet", Name = "山海·饕餮吞天兽面胄", Value = 5800,
		MinCondition = 310, MaxStamPen = -16,
		CustomIcon = "helmets/wx_helm_taotie.png", CustomIconLarge = null,
		Description = "铸有狰狞钩吾饕餮双角兽面的山海重胄，嵌饕餮噬元凶丹，正面硬撼重锤巨斧亦岿然不动。"
	},
	wx_helm_bashe = {
		ID = "wx_helm_bashe", Kind = "helmet", Name = "山海·苍梧巴蛇碧鳞冠", Value = 5600,
		MinCondition = 165, MaxStamPen = -6,
		CustomIcon = "helmets/wx_helm_bashe.png", CustomIconLarge = null,
		Description = "以苍梧吞象巴蛇胆淬炼青鳞编成的轻便束发鳞冠，丝毫不碍耳目远射，轻装与游侠至宝。"
	},
	wx_acc_jiuwei = {
		ID = "wx_acc_jiuwei", Kind = "accessory", Name = "山海·青丘定魂辟邪佩", Value = 5200,
		MinCondition = 0, MaxStamPen = 0,
		Bonuses = { Bravery = 12, AntiFearBravery = 15, NightOwl = true },
		TooltipLines = [
			{ Icon = "ui/icons/bravery.png", Text = "青丘定魄：定力 [color=#135213]+12[/color]，抗惊骇魅惑检定额外 [color=#135213]+15[/color]" },
			{ Icon = "ui/icons/vision.png", Text = "夜战心明如昼（免除夜间视野与射艺惩罚）" }
		],
		CustomIcon = "accessory/wx_acc_jiuwei.png", CustomIconLarge = null,
		Description = "以青丘九尾幻丹配妖魅白发炼成的通灵玉佩。佩于腰间：定力 +12、夜战无视视野惩罚，且对抗惊骇魅惑检定额外 +15 定力！"
	},
	wx_acc_wuzhiqi = {
		ID = "wx_acc_wuzhiqi", Kind = "accessory", Name = "山海·淮水辟毒寒渊珠", Value = 5400,
		MinCondition = 0, MaxStamPen = 0,
		Bonuses = { Stamina = 10, FatigueRecoveryRate = 2, PoisonImmune = true },
		TooltipLines = [
			{ Icon = "ui/icons/fatigue.png", Text = "寒渊定水：内息上限 [color=#135213]+10[/color]，每回合额外回气 [color=#135213]+2[/color]" },
			{ Icon = "ui/icons/special.png", Text = "百毒不侵（免疫蛛毒、五毒瘴气与暗器奇毒）" }
		],
		CustomIcon = "accessory/wx_acc_wuzhiqi.png", CustomIconLarge = null,
		Description = "淮水大妖无支祁口含千年的寒渊定水宝珠。佩于身侧：内息上限 +10、每回合回气 +2，且令佩戴者百毒不侵！"
	},
};
