// Complete declarative registry for the 24 MVP Martial Manuals
// Placeholder icons use standard vanilla perk icons until custom art is added.

::Wuxia.Config.Manuals <- {

	// =========================================================================
	// 一、大路货 (8 本) — 书肆常卖 / 杂兵掉落 / 出身自带
	// =========================================================================

	wx_manual_tuna = {
		ID = "wx_manual_tuna",
		Name = "粗浅吐纳",
		Category = "neigong",
		Quality = "common",
		Element = "neutral",
		WeaponTypes = [],
		Icon = "ui/perks/wx_manual_tuna.png",
		Description = "江湖广为流传的入门吐纳法，稳固气息、解锁基础调息。",
		BasePrice = 300,
		FragmentsNeeded = 0,
		AllowFragmentLearn = false,
		Requirements = {},
		Levels = [
			{ ExpNeeded = 0,   Stats = { Stamina = 5 },                         GrantSkills = ["actives.wx_meditate"], Flags = {}, Summary = "内息上限 +5；解锁「调息」。" },
			{ ExpNeeded = 80,  Stats = { Stamina = 10, Bravery = 3 },           GrantSkills = ["actives.wx_meditate"], Flags = {}, Summary = "内息上限 +10，定力 +3。" },
			{ ExpNeeded = 180, Stats = { Stamina = 15, Bravery = 5, FatigueRecoveryRate = 1 }, GrantSkills = ["actives.wx_meditate"], Flags = {}, Summary = "内息上限 +15，定力 +5，每回合回气 +1。" }
		]
	},

	wx_manual_xingqi = {
		ID = "wx_manual_xingqi",
		Name = "行气桩",
		Category = "neigong",
		Quality = "common",
		Element = "yang",
		WeaponTypes = [],
		Icon = "ui/perks/wx_manual_xingqi.png",
		Description = "偏阳刚的入门站桩行气功，提振气血与出招劲力。",
		BasePrice = 320,
		FragmentsNeeded = 0,
		AllowFragmentLearn = false,
		Requirements = {},
		Levels = [
			{ ExpNeeded = 0,   Stats = { Stamina = 5, Hitpoints = 4 },          GrantSkills = ["actives.wx_meditate"], Flags = { OnHitQiRegen = 1 }, Summary = "内息 +5，气血 +4；近战命中回 1 内息。" },
			{ ExpNeeded = 80,  Stats = { Stamina = 10, Hitpoints = 7 },         GrantSkills = ["actives.wx_meditate"], Flags = { OnHitQiRegen = 2 }, Summary = "内息 +10，气血 +7；近战命中回 2 内息。" },
			{ ExpNeeded = 180, Stats = { Stamina = 15, Hitpoints = 10 },        GrantSkills = ["actives.wx_meditate"], Flags = { OnHitQiRegen = 3, OnHitQiCap = 2 }, Summary = "内息 +15，气血 +10；近战命中回 3 内息（每回合最多 2 次）。" }
		]
	},

	wx_manual_jichujian = {
		ID = "wx_manual_jichujian",
		Name = "基础剑式",
		Category = "waigong",
		Quality = "common",
		Element = null,
		WeaponTypes = ["Sword"],
		Icon = "ui/perks/wx_manual_jichujian.png",
		Description = "武馆常见的基础剑法，提升持剑准头并降低出剑内息消耗。",
		BasePrice = 350,
		FragmentsNeeded = 0,
		AllowFragmentLearn = false,
		Requirements = {},
		Levels = [
			{ ExpNeeded = 0,   Stats = { MeleeSkill = 1 },                      GrantSkills = [], Flags = { WeaponQiDiscount = 0.08 }, Summary = "持剑武艺 +1，剑招内息消耗 -8%。" },
			{ ExpNeeded = 80,  Stats = { MeleeSkill = 2, MeleeDefense = 1 },    GrantSkills = [], Flags = { WeaponQiDiscount = 0.14 }, Summary = "持剑武艺 +2，招架 +1，剑招消耗 -14%。" },
			{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 2 },    GrantSkills = ["actives.wx_sword_combo"], Flags = { WeaponQiDiscount = 0.20 }, Summary = "持剑武艺 +3，招架 +2，剑招消耗 -20%；习得「清风连环剑」。" }
		]
	},

	wx_manual_wuhudao = {
		ID = "wx_manual_wuhudao",
		Name = "五虎断门刀",
		Category = "waigong",
		Quality = "common",
		Element = null,
		WeaponTypes = ["Cleaver", "Saber"],
		Icon = "ui/perks/wx_manual_wuhudao.png",
		Description = "江湖散客惯用的实用刀法，招式大开大合，擅破轻甲。",
		BasePrice = 350,
		FragmentsNeeded = 0,
		AllowFragmentLearn = false,
		Requirements = {},
		Levels = [
			{ ExpNeeded = 0,   Stats = { MeleeSkill = 1 },                      GrantSkills = [], Flags = { ArmorDmgBonus = 0.05 }, Summary = "持刀武艺 +1，破甲伤害 +5%。" },
			{ ExpNeeded = 80,  Stats = { MeleeSkill = 2 },                      GrantSkills = [], Flags = { ArmorDmgBonus = 0.10, WeaponQiDiscount = 0.10 }, Summary = "持刀武艺 +2，破甲伤害 +10%，刀招消耗 -10%。" },
			{ ExpNeeded = 180, Stats = { MeleeSkill = 3 },                      GrantSkills = ["actives.wx_saber_cleave"], Flags = { ArmorDmgBonus = 0.15, WeaponQiDiscount = 0.15 }, Summary = "持刀武艺 +3，破甲伤害 +15%，刀招消耗 -15%；习得「劈空重斩」。" }
		]
	},

	wx_manual_liuheqiang = {
		ID = "wx_manual_liuheqiang",
		Name = "六合基础枪",
		Category = "waigong",
		Quality = "common",
		Element = null,
		WeaponTypes = ["Spear", "Polearm"],
		Icon = "ui/perks/wx_manual_liuheqiang.png",
		Description = "行伍与镖师常见的枪矛入门套路，稳扎稳打、长于守线。",
		BasePrice = 350,
		FragmentsNeeded = 0,
		AllowFragmentLearn = false,
		Requirements = {},
		Levels = [
			{ ExpNeeded = 0,   Stats = { MeleeSkill = 1, MeleeDefense = 1 },    GrantSkills = [], Flags = { WeaponQiDiscount = 0.08 }, Summary = "持枪武艺 +1，招架 +1，枪招消耗 -8%。" },
			{ ExpNeeded = 80,  Stats = { MeleeSkill = 2, MeleeDefense = 1 },    GrantSkills = [], Flags = { WeaponQiDiscount = 0.14 }, Summary = "持枪武艺 +2，招架 +1，枪招消耗 -14%。" },
			{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 2 },    GrantSkills = ["actives.wx_spear_thrust2"], Flags = { WeaponQiDiscount = 0.20 }, Summary = "持枪武艺 +3，招架 +2，枪招消耗 -20%；习得「百鸟朝凤刺」。" }
		]
	},

	wx_manual_jianbu = {
		ID = "wx_manual_jianbu",
		Name = "健步功",
		Category = "qinggong",
		Quality = "common",
		Element = null,
		WeaponTypes = [],
		Icon = "ui/perks/wx_manual_jianbu.png",
		Description = "行脚客与镖师必备的基础提纵术，减少泥沼与高坡移动消耗。",
		BasePrice = 320,
		FragmentsNeeded = 0,
		AllowFragmentLearn = false,
		Requirements = {},
		Levels = [
			{ ExpNeeded = 0,   Stats = { Initiative = 5 },                      GrantSkills = [], Flags = { TerrainCostHalved = true }, Summary = "身法 +5；复杂地形移动内息消耗降低。" },
			{ ExpNeeded = 80,  Stats = { Initiative = 8 },                     GrantSkills = [], Flags = { TerrainCostHalved = true, ElevationDiscount = true }, Summary = "身法 +8；上下坡行动点消耗 -1。" },
			{ ExpNeeded = 180, Stats = { Initiative = 12 },                     GrantSkills = [], Flags = { TerrainCostHalved = true, ElevationDiscount = true }, Summary = "身法 +12；全面减免复杂地形移动与内息消耗（相当于原版寻路者）。" }
		]
	},

	wx_manual_yingpi = {
		ID = "wx_manual_yingpi",
		Name = "硬皮桩",
		Category = "henglian",
		Quality = "common",
		Element = null,
		WeaponTypes = [],
		Icon = "ui/perks/wx_manual_yingpi.png",
		Description = "锤炼筋骨皮膜的粗浅横练，大幅稳固气血与抗外伤阈值。",
		BasePrice = 320,
		FragmentsNeeded = 0,
		AllowFragmentLearn = false,
		Requirements = {},
		Levels = [
			{ ExpNeeded = 0,   Stats = { Hitpoints = 8 },                       GrantSkills = [], Flags = {}, Summary = "气血 +8。" },
			{ ExpNeeded = 80,  Stats = { Hitpoints = 14 },                      GrantSkills = [], Flags = { InjuryThresholdMult = 1.15 }, Summary = "气血 +14，外伤触发门槛 +15%。" },
			{ ExpNeeded = 180, Stats = { Hitpoints = 20 },                      GrantSkills = [], Flags = { InjuryThresholdMult = 1.25 }, Summary = "气血 +20，外伤触发门槛 +25%。" }
		]
	},

	wx_manual_xiushou = {
		ID = "wx_manual_xiushou",
		Name = "袖手暗器",
		Category = "henglian",
		Quality = "common",
		Element = null,
		WeaponTypes = ["Throwing"],
		Icon = "ui/perks/wx_manual_xiushou.png",
		Description = "暗器手法与袖里乾坤巧劲，切换兵器/暗器更迅捷。",
		BasePrice = 350,
		FragmentsNeeded = 0,
		AllowFragmentLearn = false,
		Requirements = {},
		Levels = [
			{ ExpNeeded = 0,   Stats = { RangedSkill = 3 },                    GrantSkills = [], Flags = {}, Summary = "射艺/暗器 +3。" },
			{ ExpNeeded = 80,  Stats = { RangedSkill = 4 },                    GrantSkills = [], Flags = { QuickHands = true }, Summary = "射艺/暗器 +4，每回合首次换装不耗 AP。" },
			{ ExpNeeded = 180, Stats = { RangedSkill = 5, RangedDefense = 4 }, GrantSkills = [], Flags = { QuickHands = true, ThrowingDmgBonus = 0.15 }, Summary = "射艺 +5，避暗 +4，暗器伤害 +15%，首次换装免 AP。" }
		]
	},

	// =========================================================================
	// 二、门派上乘 (8 本) — 门派交情兑换 / 委托 / 精英掉落（3 张残页合成）
	// =========================================================================

	wx_manual_songtao = {
		ID = "wx_manual_songtao",
		Name = "松涛心法",
		Category = "neigong",
		Quality = "sect",
		Element = "neutral",
		WeaponTypes = [],
		Icon = "ui/perks/wx_manual_songtao.png",
		Description = "中正平和的名门上乘内功，回气绵长、定力深厚，兼容任意辅修内功。",
		BasePrice = 1800,
		FragmentsNeeded = 3,
		AllowFragmentLearn = true,
		Requirements = { Bravery = 45 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { Stamina = 10, Bravery = 5, FatigueRecoveryRate = 2 },  GrantSkills = ["actives.wx_meditate"], Flags = {}, Summary = "内息 +10，定力 +5，回气 +2/回合；解锁调息。" },
			{ ExpNeeded = 160, Stats = { Stamina = 18, Bravery = 10, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_meditate"], Flags = {}, Summary = "内息 +18，定力 +10，回气 +4/回合。" },
			{ ExpNeeded = 360, Stats = { Stamina = 25, Bravery = 15, FatigueRecoveryRate = 6 }, GrantSkills = ["actives.wx_meditate"], Flags = { AntiInternalInjury = true }, Summary = "内息 +25，定力 +15，回气 +6/回合，临时内伤的属性减益与行气失控概率减半。" }
		]
	},

	wx_manual_guiyuan = {
		ID = "wx_manual_guiyuan",
		Name = "归元阴诀",
		Category = "neigong",
		Quality = "sect",
		Element = "yin",
		WeaponTypes = [],
		Icon = "ui/perks/wx_manual_guiyuan.png",
		Description = "清风剑派一脉阴柔心法，闪避回气，二重起解锁「真气护体」护住轻装侠客。",
		BasePrice = 1900,
		FragmentsNeeded = 3,
		AllowFragmentLearn = true,
		Requirements = { Initiative = 95 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { Stamina = 10, Initiative = 5 },        GrantSkills = ["actives.wx_meditate"], Flags = { OnDodgeQiRegen = 3, OnDodgeQiCap = 2 }, Summary = "内息 +10，身法 +5；近战闪避回 3 内息。" },
			{ ExpNeeded = 160, Stats = { Stamina = 18, Initiative = 8 },        GrantSkills = ["actives.wx_meditate"], Flags = { OnDodgeQiRegen = 4, OnDodgeQiCap = 2, QiShieldPct = 0.25 }, Summary = "内息 +18，身法 +8；解锁「真气护体」（1:2 耗内息抵消最多 25% 气血伤）。" },
			{ ExpNeeded = 360, Stats = { Stamina = 25, Initiative = 12 },       GrantSkills = ["actives.wx_meditate"], Flags = { OnDodgeQiRegen = 5, OnDodgeQiCap = 3, QiShieldPct = 0.35 }, Summary = "内息 +25，身法 +12；闪避回 5 内息，「真气护体」上限提至 35%。" }
		]
	},

	wx_manual_qingfeng = {
		ID = "wx_manual_qingfeng",
		Name = "清风连环剑",
		Category = "waigong",
		Quality = "sect",
		Element = null,
		WeaponTypes = ["Sword"],
		Icon = "ui/perks/wx_manual_qingfeng.png",
		Description = "清风剑派上乘剑法，轻灵迅疾，命中易在敌身留下「破绽」。",
		BasePrice = 2200,
		FragmentsNeeded = 3,
		AllowFragmentLearn = true,
		Requirements = { MeleeSkill = 65 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { MeleeSkill = 2, Initiative = 4 },      GrantSkills = ["actives.wx_sword_combo"], Flags = { InflictOpeningPct = 25 }, Summary = "武艺 +2，身法 +4；解锁主动招式「清风连环剑」（留破绽）。" },
			{ ExpNeeded = 160, Stats = { MeleeSkill = 3, Initiative = 6 },      GrantSkills = ["actives.wx_sword_combo", "actives.wx_acupoint_strike"], Flags = { InflictOpeningPct = 45, ArmorPenBonus = 0.08 }, Summary = "武艺 +3，身法 +6；可使清风点穴，破绽率 45%，剑招穿甲 +8%。" },
			{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Initiative = 10 },    GrantSkills = ["actives.wx_sword_combo", "actives.wx_acupoint_strike"], Flags = { InflictOpeningPct = 65, ArmorPenBonus = 0.12 }, Summary = "武艺 +5，身法 +10；可使清风点穴，破绽率 65%，剑招穿甲 +12%。" }
		]
	},

	wx_manual_weiyuan = {
		ID = "wx_manual_weiyuan",
		Name = "威远护镖枪",
		Category = "waigong",
		Quality = "sect",
		Element = null,
		WeaponTypes = ["Spear", "Polearm"],
		Icon = "ui/perks/wx_manual_weiyuan.png",
		Description = "威远镖局镇局枪法，长于控距守线与令冲阵之敌「失衡」。",
		BasePrice = 2000,
		FragmentsNeeded = 3,
		AllowFragmentLearn = true,
		Requirements = { MeleeDefense = 15 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { MeleeSkill = 2, MeleeDefense = 1 },    GrantSkills = ["actives.wx_spear_guard"], Flags = { InflictOffBalancePct = 30 }, Summary = "武艺 +2，招架 +1；解锁主动招式「威远守线刺」（1~2格致失衡）。" },
			{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 },    GrantSkills = ["actives.wx_spear_guard"], Flags = { InflictOffBalancePct = 50, ZoCBonusHit = 10 }, Summary = "武艺 +4，招架 +2；借机拦截命中 +10%，失衡率 50%。" },
			{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 },  GrantSkills = ["actives.wx_spear_guard"], Flags = { InflictOffBalancePct = 70, ZoCBonusHit = 15 }, Summary = "武艺 +5，招架 +3；借机拦截命中 +15%，失衡率 70%。" }
		]
	},

	wx_manual_heifeng = {
		ID = "wx_manual_heifeng",
		Name = "黑风劈空刀",
		Category = "waigong",
		Quality = "sect",
		Element = null,
		WeaponTypes = ["Cleaver", "Saber"],
		Icon = "ui/perks/wx_manual_heifeng.png",
		Description = "黑风寨头目惯用狠辣重刀，专破重甲与撕裂流血。",
		BasePrice = 2100,
		FragmentsNeeded = 3,
		AllowFragmentLearn = true,
		Requirements = { MeleeSkill = 65 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { MeleeSkill = 2 },                      GrantSkills = ["actives.wx_saber_cleave"], Flags = { ArmorDmgBonus = 0.11 }, Summary = "武艺 +2；解锁主动招式「劈空重斩」（高破甲流血）。" },
			{ ExpNeeded = 160, Stats = { MeleeSkill = 3 },                      GrantSkills = ["actives.wx_saber_cleave"], Flags = { ArmorDmgBonus = 0.18, DirectDmgBonus = 0.08 }, Summary = "武艺 +3；破甲 +18%，穿甲 +8%。" },
			{ ExpNeeded = 360, Stats = { MeleeSkill = 5 },                     GrantSkills = ["actives.wx_saber_cleave"], Flags = { ArmorDmgBonus = 0.25, DirectDmgBonus = 0.14 }, Summary = "武艺 +5；破甲 +25%，穿甲 +14%，重击易致深创。" }
		]
	},

	wx_manual_taxue = {
		ID = "wx_manual_taxue",
		Name = "踏雪无痕",
		Category = "qinggong",
		Quality = "sect",
		Element = null,
		WeaponTypes = [],
		Icon = "ui/perks/wx_manual_taxue.png",
		Description = "上乘轻身提纵术，高身法实时转化为招架与避暗，大成可无视控制区脱身。",
		BasePrice = 2400,
		FragmentsNeeded = 3,
		AllowFragmentLearn = true,
		Requirements = { Initiative = 105 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { Initiative = 9 },                     GrantSkills = [], Flags = { TerrainCostHalved = true }, Summary = "身法 +9；减免地形移动消耗。" },
			{ ExpNeeded = 160, Stats = { Initiative = 14 },                     GrantSkills = [], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.12 }, Summary = "身法 +14；当前有效身法的 12% 转化为招架与避暗（轻装专属收益）。" },
			{ ExpNeeded = 360, Stats = { Initiative = 18 },                     GrantSkills = ["actives.wx_qinggong_xuelian"], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.15 }, Summary = "身法 +18；身法转化率提至 15%；解锁无视控制区脱身步法；习得「踏雪无痕步」。" }
		]
	},

	wx_manual_jinchan = {
		ID = "wx_manual_jinchan",
		Name = "金蝉卸力",
		Category = "henglian",
		Quality = "sect",
		Element = null,
		WeaponTypes = [],
		Icon = "ui/perks/wx_manual_jinchan.png",
		Description = "轻装侠客立身核心法门：衣甲总负重不超过 15 时大幅卸去气血实伤。",
		BasePrice = 2500,
		FragmentsNeeded = 3,
		AllowFragmentLearn = true,
		Requirements = { Hitpoints = 65 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { Hitpoints = 6 },                       GrantSkills = [], Flags = { LightArmorMitigation = 0.25 }, Summary = "气血 +6；轻装（头身负重≤15）气血实伤减免最高 25%。" },
			{ ExpNeeded = 160, Stats = { Hitpoints = 10 },                      GrantSkills = [], Flags = { LightArmorMitigation = 0.40 }, Summary = "气血 +10；轻装气血实伤减免最高 40%。" },
			{ ExpNeeded = 360, Stats = { Hitpoints = 14 },                      GrantSkills = ["actives.wx_henglian_jinchan"], Flags = { LightArmorMitigation = 0.55 }, Summary = "气血 +14；轻装气血实伤减免最高 55%（布衣流核心支柱）；习得「金蝉卸甲劲」。" }
		]
	},

	wx_manual_tiebushan = {
		ID = "wx_manual_tiebushan",
		Name = "铁布衫",
		Category = "henglian",
		Quality = "sect",
		Element = null,
		WeaponTypes = [],
		Icon = "ui/perks/wx_manual_tiebushan.png",
		Description = "重甲与硬功横练核心法门：按护甲厚度大幅减免损甲，稳如泰山但略碍身法。",
		BasePrice = 2500,
		FragmentsNeeded = 3,
		AllowFragmentLearn = true,
		Requirements = { Hitpoints = 70 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { Hitpoints = 8, Initiative = -5 },      GrantSkills = ["perk.brawny"], Flags = { HeavyArmorScale = 0.03 }, Summary = "气血 +8，身法 -5；按头身总护甲减免护甲伤害。披甲行气使头身负重减轻 30%。" },
			{ ExpNeeded = 160, Stats = { Hitpoints = 14, Initiative = -8 },     GrantSkills = ["perk.brawny", "actives.wx_henglian_tiebushan"], Flags = { HeavyArmorScale = 0.04 }, Summary = "气血 +14，身法 -8；重甲护身减伤强化。披甲行气减轻负重 30%，可用沉岳架势抗击退、震慑；习得「铁布横练功」。" },
			{ ExpNeeded = 360, Stats = { Hitpoints = 20, Initiative = -10 },    GrantSkills = ["perk.brawny", "actives.wx_henglian_tiebushan", "perk.steel_brow"], Flags = { HeavyArmorScale = 0.05, InjuryThresholdMult = 1.25 }, Summary = "气血 +20，身法 -10；满额铁布衫减伤（相当于原版战锻）+ 抗外伤阈值 +25%。披甲行气减轻负重 30%，铜头铁额免除爆头额外伤害，可用沉岳架势。" }
		]
	},

	// =========================================================================
	// 三、绝学 (5 本) — 高危据点 / 成名高手 / 拍卖会 / 擂台（5 张残页合成）
	// =========================================================================

	wx_manual_xuesha = {
		ID = "wx_manual_xuesha",
		Name = "血煞吞元功",
		Category = "neigong",
		Quality = "secret",
		Element = "evil",
		WeaponTypes = [],
		Icon = "ui/perks/wx_manual_xuesha.png",
		Description = "血煞帮邪派绝学，击杀大量吸纳内息，三重大成可燃血换取单回合临时 AP 爆发；与正派强阳混修极易走火入魔。",
		BasePrice = 4800,
		FragmentsNeeded = 5,
		AllowFragmentLearn = true,
		Requirements = { Bravery = 55, Hitpoints = 75 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { Stamina = 15, Hitpoints = 8 },         GrantSkills = ["actives.wx_meditate"], Flags = { OnKillQiRegen = 15 }, Summary = "内息 +15，气血 +8；击杀回复 15 内息。" },
			{ ExpNeeded = 250, Stats = { Stamina = 25, Hitpoints = 14 },        GrantSkills = ["actives.wx_meditate"], Flags = { OnKillQiRegen = 20 }, Summary = "内息 +25，气血 +14；击杀回复 20 内息。" },
			{ ExpNeeded = 600, Stats = { Stamina = 35, Hitpoints = 20 },        GrantSkills = ["actives.wx_meditate", "actives.wx_blood_burst"], Flags = { OnKillQiRegen = 25, BloodBurstAP = 2 }, Summary = "内息 +35，气血 +20；击杀回 25 内息，解锁「燃血催劲」（单回合临时 +2 AP）。" }
		]
	},

	wx_manual_huifeng = {
		ID = "wx_manual_huifeng",
		Name = "回锋惊鸿剑",
		Category = "waigong",
		Quality = "secret",
		Element = null,
		WeaponTypes = ["Sword"],
		Icon = "ui/perks/wx_manual_huifeng.png",
		Description = "清风派不传剑道绝学，兼具凌厉反击架势与高伤剑气。",
		BasePrice = 4500,
		FragmentsNeeded = 5,
		AllowFragmentLearn = true,
		Requirements = { MeleeSkill = 80, MeleeDefense = 25 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { MeleeSkill = 3, MeleeDefense = 2 },    GrantSkills = ["actives.wx_sword_counter"], Flags = { CounterBonus = 10 }, Summary = "武艺 +3，招架 +2（敌近战落空自动反击）；习得「回锋架势」。" },
			{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 },   GrantSkills = ["actives.wx_sword_counter", "actives.wx_sword_huifeng"], Flags = { CounterBonus = 15, DirectDmgBonus = 0.10 }, Summary = "武艺 +5，招架 +3；反击命中 +15%，穿甲 +10%；习得「回锋惊鸿刺」。" },
			{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 },  GrantSkills = ["actives.wx_sword_counter", "actives.wx_sword_huifeng"], Flags = { CounterBonus = 20, DirectDmgBonus = 0.15 }, Summary = "武艺 +7，招架 +5；反击命中 +20%，穿甲 +15%。" }
		]
	},

	wx_manual_duanyue = {
		ID = "wx_manual_duanyue",
		Name = "断岳狂刀",
		Category = "waigong",
		Quality = "secret",
		Element = null,
		WeaponTypes = ["Cleaver", "Saber"],
		Icon = "ui/perks/wx_manual_duanyue.png",
		Description = "大开大合的狂猛刀道绝学，大成后一刀斩敌立返 3 AP，令狂刀大哥化身战场收割机。",
		BasePrice = 4600,
		FragmentsNeeded = 5,
		AllowFragmentLearn = true,
		Requirements = { MeleeSkill = 80, Stamina = 105 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { MeleeSkill = 3 },                      GrantSkills = ["actives.wx_saber_duanyue"], Flags = { ArmorDmgBonus = 0.13 }, Summary = "武艺 +3；解锁绝学重招「断岳狂斩」（高伤高破甲致失衡）。" },
			{ ExpNeeded = 250, Stats = { MeleeSkill = 5 },                     GrantSkills = ["actives.wx_saber_duanyue", "actives.wx_poise_charge"], Flags = { ArmorDmgBonus = 0.18, OnKillAPRefund = 2 }, Summary = "武艺 +5；可沉刀蓄势，刀招击杀每回合首次返还 +2 AP。" },
			{ ExpNeeded = 600, Stats = { MeleeSkill = 7 },                     GrantSkills = ["actives.wx_saber_duanyue", "actives.wx_poise_charge"], Flags = { ArmorDmgBonus = 0.25, OnKillAPRefund = 3 }, Summary = "武艺 +7；破甲 +25%，可沉刀蓄势，刀招击杀每回合首次返还 +3 AP（短时可破 12 AP）。" }
		]
	},

	wx_manual_baoyu = {
		ID = "wx_manual_baoyu",
		Name = "暴雨暗器谱",
		Category = "waigong",
		Quality = "secret",
		Element = null,
		WeaponTypes = ["Throwing"],
		Icon = "ui/perks/wx_manual_baoyu.png",
		Description = "专克高招架轻装高手的暗器绝学，毒针穿甲、烟幕蔽目。",
		BasePrice = 4200,
		FragmentsNeeded = 5,
		AllowFragmentLearn = true,
		Requirements = { RangedSkill = 75 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { RangedSkill = 4 },                     GrantSkills = ["actives.wx_throwing_rain"], Flags = { ThrowingDmgBonus = 0.15 }, Summary = "射艺 +4（3 AP 疾射附暗器剧毒）；习得「暴雨毒针」。" },
			{ ExpNeeded = 250, Stats = { RangedSkill = 5, Initiative = 6 },    GrantSkills = ["actives.wx_throwing_rain", "actives.wx_smoke_cast"], Flags = { ThrowingDmgBonus = 0.25, DirectDmgBonus = 0.10 }, Summary = "射艺 +5，身法 +6；可掷烟蔽目，暗器伤害 +25%，穿甲 +10%；习得「掷烟蔽目」。" },
			{ ExpNeeded = 600, Stats = { RangedSkill = 7, Initiative = 10 },   GrantSkills = ["actives.wx_throwing_rain", "actives.wx_smoke_cast", "actives.wx_throw_pilidan"], Flags = { ThrowingDmgBonus = 0.35, DirectDmgBonus = 0.15, IgnoreDodgeHalf = true }, Summary = "射艺 +7，身法 +10；可掷烟蔽目，暗器伤害 +35%，穿甲 +15%，专破轻装闪避；习得「霹雳雷火弹」。" }
		]
	},

	wx_manual_suodi = {
		ID = "wx_manual_suodi",
		Name = "缩地成寸",
		Category = "qinggong",
		Quality = "secret",
		Element = null,
		WeaponTypes = [],
		Icon = "ui/perks/wx_manual_suodi.png",
		Description = "顶尖游斗身法绝学，缩步越地形直切敌阵后排。",
		BasePrice = 4500,
		FragmentsNeeded = 5,
		AllowFragmentLearn = true,
		Requirements = { Initiative = 115 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { Initiative = 12 },                     GrantSkills = [], Flags = { TerrainCostHalved = true }, Summary = "身法 +12，减免地形移动消耗。" },
			{ ExpNeeded = 250, Stats = { Initiative = 17 },                     GrantSkills = ["actives.wx_qinggong_yanxing"], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.15 }, Summary = "身法 +17，解锁脱身步法与身法转防御；习得「燕子抄水步」。" },
			{ ExpNeeded = 600, Stats = { Initiative = 24 },                     GrantSkills = ["actives.wx_qinggong_yanxing", "actives.wx_qinggong_suodi"], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.18, MoveAPDiscount = 1 }, Summary = "身法 +24，解锁脱身与换位身法，大幅强化切阵机动；习得「缩地成寸步」。" }
		]
	},

	// =========================================================================
	// 四、江湖孤本 (3 本) — 终极 Boss / 武林禁地 / 压轴拍卖（5 张残页合成）
	// =========================================================================

	wx_manual_taixu = {
		ID = "wx_manual_taixu",
		Name = "太虚真经",
		Category = "neigong",
		Quality = "unique",
		Element = "neutral",
		WeaponTypes = [],
		Icon = "ui/perks/wx_manual_taixu.png",
		Description = "失传已久的中正至高内功孤本：二重调和阴阳冲突，三重大成永久突破 +1 AP 并赐予一次洗经伐髓契机。",
		BasePrice = 12000,
		FragmentsNeeded = 5,
		AllowFragmentLearn = true,
		Requirements = { Bravery = 65, Stamina = 110 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { Stamina = 15, Bravery = 6, FatigueRecoveryRate = 2 },  GrantSkills = ["actives.wx_neigong_guiyuan"], Flags = {}, Summary = "内息 +15，定力 +6，回气 +2/回合；习得「太和归元劲」。" },
			{ ExpNeeded = 320, Stats = { Stamina = 25, Bravery = 12, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_neigong_guiyuan"], Flags = { HarmonizeConflict = true, QiShieldPct = 0.25 }, Summary = "内息 +25，定力 +12，回气 +4；调和辅修内功相克，解锁 25% 真气护体。" },
			{ ExpNeeded = 800, Stats = { Stamina = 40, Bravery = 18, FatigueRecoveryRate = 6 }, GrantSkills = ["actives.wx_neigong_guiyuan"], Flags = { HarmonizeConflict = true, QiShieldPct = 0.35, PermanentAPBonus = 1, GrantWashChance = 1 }, Summary = "内息 +40，定力 +18，回气 +6；常驻行动点 +1（上限 11），首次大成获赠 1 次洗经伐髓契机！。" }
		]
	},

	wx_manual_lingbo = {
		ID = "wx_manual_lingbo",
		Name = "凌波御风步",
		Category = "qinggong",
		Quality = "unique",
		Element = null,
		WeaponTypes = [],
		Icon = "ui/perks/wx_manual_lingbo.png",
		Description = "天下第一轻功孤本，踏风而行、三重大成永久突破 +1 AP。",
		BasePrice = 11500,
		FragmentsNeeded = 5,
		AllowFragmentLearn = true,
		Requirements = { Initiative = 125 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { Initiative = 14 },                     GrantSkills = ["actives.wx_qinggong_lingbo"], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.13 }, Summary = "身法 +14，地形减耗，身法 13% 转招架/避暗；习得「凌波腾挪步」。" },
			{ ExpNeeded = 320, Stats = { Initiative = 21 },                     GrantSkills = ["actives.wx_qinggong_lingbo"], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.16 }, Summary = "身法 +21，身法 16% 转招架/避暗，解锁无视控制区步法。" },
			{ ExpNeeded = 800, Stats = { Initiative = 30 },                     GrantSkills = ["actives.wx_qinggong_lingbo", "actives.wx_qinggong_shuishang"], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.20, PermanentAPBonus = 1 }, Summary = "身法 +30，身法 20% 转招架/避暗；常驻行动点 +1（上限 11）！；习得「踏浪水上漂」。" }
		]
	},

	wx_manual_tianwai = {
		ID = "wx_manual_tianwai",
		Name = "天外一剑",
		Category = "waigong",
		Quality = "unique",
		Element = null,
		WeaponTypes = ["Sword"],
		Icon = "ui/perks/wx_manual_tianwai.png",
		Description = "剑道极境孤本，剑意透骨穿甲，配合突破 9 AP 的宗师方能游刃施展。",
		BasePrice = 12000,
		FragmentsNeeded = 5,
		AllowFragmentLearn = true,
		Requirements = { MeleeSkill = 90, Initiative = 110 },
		Levels = [
			{ ExpNeeded = 0,   Stats = { MeleeSkill = 4 },                      GrantSkills = ["actives.wx_sword_qinggang"], Flags = { DirectDmgBonus = 0.08 }, Summary = "武艺 +4，剑招穿甲 +8%；习得「青釭透甲剑」。" },
			{ ExpNeeded = 320, Stats = { MeleeSkill = 7, MeleeDefense = 4 },   GrantSkills = ["actives.wx_sword_qinggang", "actives.wx_sword_feixian"], Flags = { DirectDmgBonus = 0.13, HitChanceBonus = 8 }, Summary = "武艺 +7，招架 +4；剑招穿甲 +13%，命中 +8%；习得「天河落星剑」。" },
			{ ExpNeeded = 800, Stats = { MeleeSkill = 10, MeleeDefense = 6 },  GrantSkills = ["actives.wx_sword_qinggang", "actives.wx_sword_feixian", "actives.wx_sword_tianwai"], Flags = { DirectDmgBonus = 0.20, HitChanceBonus = 12, CritHeadBonus = 15 }, Summary = "武艺 +10，招架 +6；解锁孤本杀招「天外一剑」（7 AP 两格穿甲剑气）！；习得「天外一剑」。" }
		]
	}
};
