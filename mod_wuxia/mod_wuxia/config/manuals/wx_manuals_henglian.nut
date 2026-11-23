// Expanded Henglian & Zaxue Library (Hard Body, Shields, Tactics & Strange Arts)
// Auto-audited against AGENTS.md stat & non-stacking redlines.

::Wuxia.Config.Manuals.wx_manual_tengpai_shu <- {
	ID = "wx_manual_tengpai_shu", Name = "藤牌滚刀操", Category = "henglian", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_tengpai_shu.png",
	Description = "岭南藤牌营步卒必修的持盾守御操典，举盾严密且省内力。",
	BasePrice = 280, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeDefense = 1, RangedDefense = 1 }, GrantSkills = [], Flags = { ShieldDefBonus = 2 }, Summary = "招架 +1，避暗 +1；持盾双防 +2。" },
		{ ExpNeeded = 80, Stats = { MeleeDefense = 2, RangedDefense = 2 }, GrantSkills = [], Flags = { ShieldDefBonus = 3, ShieldWallExpert = true }, Summary = "招架 +2，避暗 +2；持盾双防 +3，专精盾术省气。" },
		{ ExpNeeded = 180, Stats = { MeleeDefense = 3, RangedDefense = 3 }, GrantSkills = [], Flags = { ShieldDefBonus = 4, ShieldWallExpert = true }, Summary = "招架 +3，避暗 +3；持盾双防 +4，专精盾术省气。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_qunjia_ce <- {
	ID = "wx_manual_qunjia_ce", Name = "群狼合围术", Category = "henglian", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_qunjia_ce.png",
	Description = "绿林山寨喽啰一拥而上以多打少的街头狠招，友军围攻越多准头越毒。",
	BasePrice = 340, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { SurroundHitBonus = 2 }, Summary = "武艺 +1；合围每名友军 +2 命中。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2 }, GrantSkills = [], Flags = { SurroundHitBonus = 4 }, Summary = "武艺 +2；合围每名友军 +4 命中。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, Bravery = 4 }, GrantSkills = [], Flags = { SurroundHitBonus = 5, ExecuteLowHpDmg = 0.08 }, Summary = "武艺 +3，定力 +4；对半血残敌伤害 +8%，合围每名友军 +5 命中。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_pijia_zhuang <- {
	ID = "wx_manual_pijia_zhuang", Name = "披甲负重桩", Category = "henglian", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_pijia_zhuang.png",
	Description = "守塞军士身披札甲跑步打桩的硬功夫，早早习得披甲行气减轻甲胄拖累。",
	BasePrice = 370, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 5 }, GrantSkills = [], Flags = {}, Summary = "气血 +5。" },
		{ ExpNeeded = 80, Stats = { Hitpoints = 10 }, GrantSkills = ["perk.brawny"], Flags = {}, Summary = "气血 +10；习得「披甲行气」。" },
		{ ExpNeeded = 180, Stats = { Hitpoints = 15 }, GrantSkills = ["perk.brawny"], Flags = { HeavyArmorScale = 0.02 }, Summary = "气血 +15；按重甲厚度减免损甲。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_tongtou_gong <- {
	ID = "wx_manual_tongtou_gong", Name = "铁头护额功", Category = "henglian", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_tongtou_gong.png",
	Description = "外家武师以木槌拍打额骨练就的硬脑壳，大成后免受重兵爆头致命暴击。",
	BasePrice = 280, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 6 }, GrantSkills = [], Flags = { InjuryThresholdMult = 1.10 }, Summary = "气血 +6；外伤门槛 +10%。" },
		{ ExpNeeded = 80, Stats = { Hitpoints = 12 }, GrantSkills = ["perk.steel_brow"], Flags = { InjuryThresholdMult = 1.18 }, Summary = "气血 +12；外伤门槛 +18%。" },
		{ ExpNeeded = 180, Stats = { Hitpoints = 16 }, GrantSkills = ["perk.steel_brow", "actives.wx_henglian_tongtou"], Flags = { InjuryThresholdMult = 1.22 }, Summary = "气血 +16；外伤门槛 +22%；习得「铜头撞山劲」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_kuaishou_nang <- {
	ID = "wx_manual_kuaishou_nang", Name = "百宝快手诀", Category = "henglian", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_kuaishou_nang.png",
	Description = "走江湖卖解与镖队趟子手切换长短兵刃、投网暗器的利落手法，不限主手兵器。",
	BasePrice = 340, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 4 }, GrantSkills = [], Flags = { QuickHands = true }, Summary = "身法 +4；每回合首次换装免耗点。" },
		{ ExpNeeded = 80, Stats = { Initiative = 7, RangedSkill = 2 }, GrantSkills = [], Flags = { QuickHands = true }, Summary = "身法 +7，射艺 +2；每回合首次换装免耗点。" },
		{ ExpNeeded = 180, Stats = { Initiative = 10, RangedSkill = 4 }, GrantSkills = [], Flags = { QuickHands = true, CloseRangeShotBonus = 6 }, Summary = "身法 +10，射艺 +4；近距快射命中 +6，每回合首次换装免耗点。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_jinzhong_rumen <- {
	ID = "wx_manual_jinzhong_rumen", Name = "排打抗揍功", Category = "henglian", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_jinzhong_rumen.png",
	Description = "川江纤夫与码头脚夫彼此排打练皮肉的土法横练，气血厚实耐殴打。",
	BasePrice = 370, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 7, Bravery = 2 }, GrantSkills = [], Flags = {}, Summary = "气血 +7，定力 +2。" },
		{ ExpNeeded = 80, Stats = { Hitpoints = 13, Bravery = 4 }, GrantSkills = [], Flags = { InjuryThresholdMult = 1.12 }, Summary = "气血 +13，定力 +4；外伤门槛 +12%。" },
		{ ExpNeeded = 180, Stats = { Hitpoints = 20, Bravery = 6 }, GrantSkills = [], Flags = { InjuryThresholdMult = 1.20 }, Summary = "气血 +20，定力 +6；外伤门槛 +20%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zhanma_tongpao <- {
	ID = "wx_manual_zhanma_tongpao", Name = "鸳鸯伍阵谱", Category = "henglian", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_zhanma_tongpao.png",
	Description = "东南抗倭军伍流传的结伍互保阵法，与同伴并肩站立时守御倍增。",
	BasePrice = 310, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Bravery = 4 }, GrantSkills = [], Flags = { FormationBondDef = 1 }, Summary = "定力 +4；邻接同袍结阵守御定力 +1。" },
		{ ExpNeeded = 80, Stats = { Bravery = 7, MeleeDefense = 1 }, GrantSkills = [], Flags = { FormationBondDef = 2 }, Summary = "定力 +7，招架 +1；邻接同袍结阵守御定力 +2。" },
		{ ExpNeeded = 180, Stats = { Bravery = 10, MeleeDefense = 2 }, GrantSkills = [], Flags = { FormationBondDef = 3 }, Summary = "定力 +10，招架 +2；邻接同袍结阵守御定力 +3。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_yexiao_yan <- {
	ID = "wx_manual_yexiao_yan", Name = "夜枭辨位术", Category = "henglian", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_yexiao_yan.png",
	Description = "暗室观香锻炼眼力的江湖异术，黑夜交锋不受视线受阻之苦。",
	BasePrice = 280, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 2, Initiative = 3 }, GrantSkills = [], Flags = {}, Summary = "射艺 +2，身法 +3。" },
		{ ExpNeeded = 80, Stats = { RangedSkill = 3, Initiative = 5 }, GrantSkills = [], Flags = { NightOwl = true }, Summary = "射艺 +3，身法 +5；夜战无视视野惩罚。" },
		{ ExpNeeded = 180, Stats = { RangedSkill = 5, Initiative = 8 }, GrantSkills = [], Flags = { NightOwl = true, LongRangeAccBonus = 4 }, Summary = "射艺 +5，身法 +8；远距射艺 +4，夜战无视视野惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shixue_kuang <- {
	ID = "wx_manual_shixue_kuang", Name = "悍匪饮血诀", Category = "henglian", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_shixue_kuang.png",
	Description = "亡命刀客见血兴奋的凶戾法门，斩杀生人敌军可略微平复自身创伤。",
	BasePrice = 340, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 5, Bravery = 2 }, GrantSkills = [], Flags = { OnKillHealHP = 3 }, Summary = "气血 +5，定力 +2；击杀生人回 3 气血。" },
		{ ExpNeeded = 80, Stats = { Hitpoints = 10, Bravery = 4 }, GrantSkills = [], Flags = { OnKillHealHP = 5 }, Summary = "气血 +10，定力 +4；击杀生人回 5 气血。" },
		{ ExpNeeded = 180, Stats = { Hitpoints = 14, Bravery = 6 }, GrantSkills = [], Flags = { OnKillHealHP = 7, ExecuteLowHpDmg = 0.08 }, Summary = "气血 +14，定力 +6；对半血残敌伤害 +8%，击杀生人回 7 气血。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_poxie_fushui <- {
	ID = "wx_manual_poxie_fushui", Name = "朱砂辟邪咒", Category = "henglian", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_poxie_fushui.png",
	Description = "辰州方士绘于兵刃甲衣上的朱砂符法，壮胆定神，略增对尸傀机关杀伤。",
	BasePrice = 280, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Bravery = 5 }, GrantSkills = [], Flags = { VsUndeadDmg = 0.05 }, Summary = "定力 +5；对尸傀机关总伤 +5%。" },
		{ ExpNeeded = 80, Stats = { Bravery = 9 }, GrantSkills = [], Flags = { VsUndeadDmg = 0.08 }, Summary = "定力 +9；对尸傀机关总伤 +8%。" },
		{ ExpNeeded = 180, Stats = { Bravery = 13 }, GrantSkills = [], Flags = { VsUndeadDmg = 0.12, AntiFearAura = true }, Summary = "定力 +13；对尸傀机关总伤 +12%，抗惊骇检定定力 +15。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_lingnan_tengdun <- {
	ID = "wx_manual_lingnan_tengdun", Name = "岭南藤牌阵解", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_lingnan_tengdun.png",
	Description = "岭南藤牌悍卒营镇营盾术：桐油老藤牌水火难侵，可施展「铁壁震山靠」撞退强敌且不惧围攻！",
	BasePrice = 2260, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeDefense = 15 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 6, MeleeDefense = 2 }, GrantSkills = ["actives.wx_shield_bash_qi"], Flags = { ShieldDefBonus = 3, ShieldWallExpert = true }, Summary = "气血 +6，招架 +2；习得「铁壁震山靠」；持盾双防 +3，专精盾术省气。" },
		{ ExpNeeded = 160, Stats = { Hitpoints = 12, MeleeDefense = 3, RangedDefense = 2 }, GrantSkills = ["actives.wx_shield_bash_qi"], Flags = { ShieldDefBonus = 4, ShieldWallExpert = true }, Summary = "气血 +12，招架 +3，避暗 +2；持盾双防 +4，专精盾术省气。" },
		{ ExpNeeded = 360, Stats = { Hitpoints = 16, MeleeDefense = 4, RangedDefense = 4 }, GrantSkills = ["actives.wx_shield_bash_qi", "actives.wx_shield_tiebi"], Flags = { ShieldDefBonus = 6, ShieldWallExpert = true, UnderdogGuard = true }, Summary = "气血 +16，招架 +4，避暗 +4；持盾双防 +6，专精盾术省气，免除被围攻近防惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_hengshan_tiebi <- {
	ID = "wx_manual_hengshan_tiebi", Name = "北岳盘石硬功", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_hengshan_tiebi.png",
	Description = "北岳守塞堂重甲护卫横练，披重甲如着单衣，铜头护额且与友军结成铁壁。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Hitpoints = 70, Stamina = 95 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 8, Initiative = -5 }, GrantSkills = ["perk.brawny"], Flags = { HeavyArmorScale = 0.03, FormationBondDef = 2 }, Summary = "气血 +8，身法 -5；邻接同袍结阵守御定力 +2，按重甲厚度减免损甲。" },
		{ ExpNeeded = 160, Stats = { Hitpoints = 14, Initiative = -7, Bravery = 5 }, GrantSkills = ["perk.brawny", "perk.steel_brow"], Flags = { HeavyArmorScale = 0.04, FormationBondDef = 3 }, Summary = "气血 +14，身法 -7，定力 +5；邻接同袍结阵守御定力 +3，按重甲厚度减免损甲。" },
		{ ExpNeeded = 360, Stats = { Hitpoints = 20, Initiative = -9, Bravery = 8 }, GrantSkills = ["perk.brawny", "perk.steel_brow", "actives.wx_henglian_panshi"], Flags = { HeavyArmorScale = 0.05, FormationBondDef = 4 }, Summary = "气血 +20，身法 -9，定力 +8；邻接同袍结阵守御定力 +4，按重甲厚度减免损甲；习得「磐石镇岳架」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shaolin_tongren <- {
	ID = "wx_manual_shaolin_tongren", Name = "少室十八铜人功", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_shaolin_tongren.png",
	Description = "少室禅院护寺铜人阵外家硬功，皮肉坚逾精铜，受近身劈砍能反震损毁敌方护甲且免围攻破防。",
	BasePrice = 2260, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Hitpoints = 72 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 8, Initiative = -4 }, GrantSkills = ["perk.brawny"], Flags = { HeavyArmorScale = 0.03, ReflectArmorDmg = 5 }, Summary = "气血 +8，身法 -4；按重甲厚度减免损甲，受近战反震敌甲 5 点。" },
		{ ExpNeeded = 160, Stats = { Hitpoints = 14, Initiative = -6 }, GrantSkills = ["perk.brawny", "actives.wx_henglian_tongtou"], Flags = { HeavyArmorScale = 0.04, ReflectArmorDmg = 8, UnderdogGuard = true }, Summary = "气血 +14，身法 -6；免除被围攻近防惩罚，按重甲厚度减免损甲，受近战反震敌甲 8 点；习得「铜头撞山劲」。" },
		{ ExpNeeded = 360, Stats = { Hitpoints = 20, Initiative = -8 }, GrantSkills = ["perk.brawny", "actives.wx_henglian_tongtou", "perk.steel_brow"], Flags = { HeavyArmorScale = 0.05, ReflectArmorDmg = 10, UnderdogGuard = true }, Summary = "气血 +20，身法 -8；免除被围攻近防惩罚，按重甲厚度减免损甲，受近战反震敌甲 10 点。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_taihe_mianjin <- {
	ID = "wx_manual_taihe_mianjin", Name = "太和柔云卸劲篇", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_taihe_mianjin.png",
	Description = "太和玄门道袍轻装护身法：不仗铁甲厚重，单凭圆转柔劲卸去泰半气血实伤。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 98 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 5, Bravery = 4 }, GrantSkills = [], Flags = { LightArmorMitigation = 0.25 }, Summary = "气血 +5，定力 +4；轻装实伤减免最高 25%。" },
		{ ExpNeeded = 160, Stats = { Hitpoints = 10, Bravery = 7 }, GrantSkills = [], Flags = { LightArmorMitigation = 0.38, OnDodgeQiRegen = 2 }, Summary = "气血 +10，定力 +7；轻装实伤减免最高 38%，闪避回 2 内息。" },
		{ ExpNeeded = 360, Stats = { Hitpoints = 14, Bravery = 10 }, GrantSkills = ["actives.wx_henglian_jinchan"], Flags = { LightArmorMitigation = 0.52, OnDodgeQiRegen = 3, AntiInternalInjury = true }, Summary = "气血 +14，定力 +10；轻装实伤减免最高 52%，闪避回 3 内息，内伤与失控风险减半；习得「金蝉卸甲劲」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_baima_zhenshu <- {
	ID = "wx_manual_baima_zhenshu", Name = "白马军阵号令", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_baima_zhenshu.png",
	Description = "白马义从营百夫长战阵指挥要诀，定力光环笼罩四方同袍，且掩护射艺更为犀利。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Bravery = 55 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Bravery = 6 }, GrantSkills = ["actives.wx_tactics_bamen"], Flags = { CommandAuraPct = 0.05, FormationBondDef = 2 }, Summary = "定力 +6；邻接同袍结阵守御定力 +2，四格定力光环 5%；习得「八门金锁阵」。" },
		{ ExpNeeded = 160, Stats = { Bravery = 11 }, GrantSkills = ["actives.wx_tactics_bamen"], Flags = { CommandAuraPct = 0.08, RallyBonus = 10, FormationBondDef = 3 }, Summary = "定力 +11；邻接同袍结阵守御定力 +3，四格定力光环 8%，聚义号令 +10。" },
		{ ExpNeeded = 360, Stats = { Bravery = 16 }, GrantSkills = ["actives.wx_tactics_bamen"], Flags = { CommandAuraPct = 0.10, RallyBonus = 18, FormationBondDef = 4 }, Summary = "定力 +16；邻接同袍结阵守御定力 +4，四格定力光环 10%，聚义号令 +18。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_xinglin_jinshen <- {
	ID = "wx_manual_xinglin_jinshen", Name = "金针渡劫护心术", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_xinglin_jinshen.png",
	Description = "杏林济世堂以金针封住奇穴的保命奇术，濒死锁血九死一生，且交战中源源止血解毒。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Bravery = 48 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 8, Bravery = 4 }, GrantSkills = ["perk.nine_lives"], Flags = { GuixiTier = 2, TurnStartCleansePct = 25 }, Summary = "气血 +8，定力 +4；习得「九死锁血」；回合初 25% 止血祛毒微回血，强化九死锁血回元。" },
		{ ExpNeeded = 160, Stats = { Hitpoints = 14, Bravery = 7 }, GrantSkills = ["perk.nine_lives"], Flags = { GuixiTier = 3, TurnStartCleansePct = 40 }, Summary = "气血 +14，定力 +7；回合初 40% 止血祛毒微回血，强化九死锁血回元。" },
		{ ExpNeeded = 360, Stats = { Hitpoints = 18, Bravery = 10 }, GrantSkills = ["perk.nine_lives", "actives.wx_tactics_jinzhen"], Flags = { GuixiTier = 3, TurnStartCleansePct = 55, PoisonImmune = true }, Summary = "气血 +18，定力 +10；大成习得「金针渡劫术」；回合初 55% 止血祛毒微回血，百毒不侵，强化九死锁血回元。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zhongzhou_wuzong <- {
	ID = "wx_manual_zhongzhou_wuzong", Name = "中州百兵通解", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_zhongzhou_wuzong.png",
	Description = "中州振武堂总教头融汇十八般武艺编纂的实战讲义，快手换兵、落空叠准，专治花架子。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 60 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, RangedSkill = 2 }, GrantSkills = [], Flags = { QuickHands = true, FastAdaptBonus = 6 }, Summary = "武艺 +2，射艺 +2；落空叠准 +6/层，每回合首次换装免耗点。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 3, RangedSkill = 3, MeleeDefense = 1 }, GrantSkills = [], Flags = { QuickHands = true, FastAdaptBonus = 8 }, Summary = "武艺 +3，射艺 +3，招架 +1；落空叠准 +8/层，每回合首次换装免耗点。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, RangedSkill = 5, MeleeDefense = 2 }, GrantSkills = [], Flags = { QuickHands = true, FastAdaptBonus = 10, ExposeOnHitPct = 25 }, Summary = "武艺 +5，射艺 +5，招架 +2；普攻寻隙留破绽 25%，落空叠准 +10/层，每回合首次换装免耗点。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_kuaiji_duanjian <- {
	ID = "wx_manual_kuaiji_duanjian", Name = "越女孤剑心解", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_kuaiji_duanjian.png",
	Description = "会稽鱼肠剑庐相传的单手轻兵秘解：空悬副手时剑匕刺击快逾闪电，直透铁甲要害。",
	BasePrice = 2260, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 68, Initiative = 98 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 4, MeleeSkill = 1 }, GrantSkills = [], Flags = { EmptyOffhandPen = 0.10, FirstRoundInit = 8 }, Summary = "身法 +4，武艺 +1；单手空副手穿甲 +10%，首轮身法 +8。" },
		{ ExpNeeded = 160, Stats = { Initiative = 7, MeleeSkill = 2, MeleeDefense = 2 }, GrantSkills = [], Flags = { EmptyOffhandPen = 0.18, FirstRoundInit = 12 }, Summary = "身法 +7，武艺 +2，招架 +2；单手空副手穿甲 +18%，首轮身法 +12。" },
		{ ExpNeeded = 360, Stats = { Initiative = 10, MeleeSkill = 3, MeleeDefense = 3 }, GrantSkills = [], Flags = { EmptyOffhandPen = 0.25, FirstRoundInit = 16 }, Summary = "身法 +10，武艺 +3，招架 +3；单手空副手穿甲 +25%，首轮身法 +16。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_hanhai_guke <- {
	ID = "wx_manual_hanhai_guke", Name = "大漠孤狼战法", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_hanhai_guke.png",
	Description = "瀚海弯刀盟独行马贼横行沙海的搏命战诀，远离友军独自切入侧翼时攻防大涨！",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 66, Bravery = 50 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Bravery = 4, MeleeSkill = 1 }, GrantSkills = [], Flags = { LoneWolfBonus = 3 }, Summary = "定力 +4，武艺 +1；孤身两格无友军时攻防 +3。" },
		{ ExpNeeded = 160, Stats = { Bravery = 7, MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = [], Flags = { LoneWolfBonus = 5, UnderdogGuard = true }, Summary = "定力 +7，武艺 +2，招架 +1；免除被围攻近防惩罚，孤身两格无友军时攻防 +5。" },
		{ ExpNeeded = 360, Stats = { Bravery = 10, MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = [], Flags = { LoneWolfBonus = 7, UnderdogGuard = true }, Summary = "定力 +10，武艺 +3，招架 +2；免除被围攻近防惩罚，孤身两格无友军时攻防 +7。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_emei_dianxue <- {
	ID = "wx_manual_emei_dianxue", Name = "金顶截脉认穴篇", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_emei_dianxue.png",
	Description = "峨眉金顶庵医武同源的经络图谱，兵刃拳掌一旦击中敌方破绽或头面，顺势封闭气穴。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 66, Initiative = 96 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Initiative = 4 }, GrantSkills = [], Flags = { AcupointOnCritPct = 20 }, Summary = "武艺 +2，身法 +4；乘隙/击头封穴 20%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 3, Initiative = 6 }, GrantSkills = [], Flags = { AcupointOnCritPct = 35, ExposeOnHitPct = 20 }, Summary = "武艺 +3，身法 +6；普攻寻隙留破绽 20%，乘隙/击头封穴 35%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 4, Initiative = 9 }, GrantSkills = [], Flags = { AcupointOnCritPct = 50, ExposeOnHitPct = 30 }, Summary = "武艺 +4，身法 +9；普攻寻隙留破绽 30%，乘隙/击头封穴 50%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shenji_huoyao <- {
	ID = "wx_manual_shenji_huoyao", Name = "神机火药轰雷术", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_shenji_huoyao.png",
	Description = "神机火器营配制猛火黑药与铁砂铅子的秘术，近距轰击准头大增且专碎重甲。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { RangedSkill = 64 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 2 }, GrantSkills = [], Flags = { CloseRangeShotBonus = 5, UnbrokenArmorBonus = 0.10 }, Summary = "射艺 +2；对厚甲破甲 +10%，近距快射命中 +5。" },
		{ ExpNeeded = 160, Stats = { RangedSkill = 3, Bravery = 4 }, GrantSkills = [], Flags = { CloseRangeShotBonus = 8, UnbrokenArmorBonus = 0.16, QuickHands = true }, Summary = "射艺 +3，定力 +4；对厚甲破甲 +16%，近距快射命中 +8，每回合首次换装免耗点。" },
		{ ExpNeeded = 360, Stats = { RangedSkill = 5, Bravery = 6 }, GrantSkills = [], Flags = { CloseRangeShotBonus = 12, UnbrokenArmorBonus = 0.22, QuickHands = true }, Summary = "射艺 +5，定力 +6；对厚甲破甲 +22%，近距快射命中 +12，每回合首次换装免耗点。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_bashu_huzhen <- {
	ID = "wx_manual_bashu_huzhen", Name = "袍哥义字铁肩功", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_bashu_huzhen.png",
	Description = "川江袍哥盐帮讲义气、替兄弟挡刀的护身把式，身陷重围不掉近防，更能换位救人。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Hitpoints = 68, Bravery = 50 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 8, Bravery = 4 }, GrantSkills = [], Flags = { UnderdogGuard = true }, Summary = "气血 +8，定力 +4；免除被围攻近防惩罚。" },
		{ ExpNeeded = 160, Stats = { Hitpoints = 14, Bravery = 8 }, GrantSkills = ["actives.rotation"], Flags = { UnderdogGuard = true, FormationBondDef = 2 }, Summary = "气血 +14，定力 +8；习得「换位援护」；免除被围攻近防惩罚，邻接同袍结阵守御定力 +2。" },
		{ ExpNeeded = 360, Stats = { Hitpoints = 20, Bravery = 12 }, GrantSkills = ["actives.rotation"], Flags = { UnderdogGuard = true, FormationBondDef = 4, InjuryThresholdMult = 1.20 }, Summary = "气血 +20，定力 +12；免除被围攻近防惩罚，邻接同袍结阵守御定力 +4，外伤门槛 +20%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_xiangxi_ganling <- {
	ID = "wx_manual_xiangxi_ganling", Name = "辰州摄魂铜铃术", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_xiangxi_ganling.png",
	Description = "湘西辰州符水门摇动摄魂铃震慑生人胆魄的秘术，亦善斩灭荒冢尸傀。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Bravery = 58 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Bravery = 6 }, GrantSkills = [], Flags = { VsUndeadDmg = 0.08, AntiFearAura = true }, Summary = "定力 +6；对尸傀机关总伤 +8%，抗惊骇检定定力 +15。" },
		{ ExpNeeded = 160, Stats = { Bravery = 11 }, GrantSkills = ["perk.fearsome"], Flags = { VsUndeadDmg = 0.12, AntiFearAura = true }, Summary = "定力 +11；习得「慑魂威压」；对尸傀机关总伤 +12%，抗惊骇检定定力 +15。" },
		{ ExpNeeded = 360, Stats = { Bravery = 16 }, GrantSkills = ["perk.fearsome"], Flags = { VsUndeadDmg = 0.16, AntiFearAura = true, OnHitDrainQi = 4 }, Summary = "定力 +16；命中震散敌内息 4 点，对尸傀机关总伤 +16%，抗惊骇检定定力 +15。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shaolin_jinzhong <- {
	ID = "wx_manual_shaolin_jinzhong", Name = "金刚不坏神功", Category = "henglian", Quality = "secret",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_shaolin_jinzhong.png",
	Description = "少室禅院外家护体至高绝学，凝真气为不坏金身，披重甲免爆头、抗震退且无惧群敌合围！",
	BasePrice = 4630, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Hitpoints = 78, Stamina = 102 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 10, Initiative = -5, Bravery = 4 }, GrantSkills = ["perk.brawny"], Flags = { HeavyArmorScale = 0.04, UnderdogGuard = true }, Summary = "气血 +10，身法 -5，定力 +4；习得「披甲行气」；免除被围攻近防惩罚，按重甲厚度减免损甲。" },
		{ ExpNeeded = 250, Stats = { Hitpoints = 15, Initiative = -7, Bravery = 8 }, GrantSkills = ["perk.brawny", "actives.indomitable"], Flags = { HeavyArmorScale = 0.05, UnderdogGuard = true, InjuryThresholdMult = 1.25 }, Summary = "气血 +15，身法 -7，定力 +8；习得「沉岳硬抗」；免除被围攻近防惩罚，按重甲厚度减免损甲，外伤门槛 +25%。" },
		{ ExpNeeded = 600, Stats = { Hitpoints = 20, Initiative = -9, Bravery = 12 }, GrantSkills = ["perk.brawny", "actives.indomitable", "perk.steel_brow", "actives.wx_tactics_shihou"], Flags = { HeavyArmorScale = 0.06, UnderdogGuard = true, InjuryThresholdMult = 1.35, ReflectArmorDmg = 10 }, Summary = "气血 +20，身法 -9，定力 +12；大成习得「金刚狮子吼」与「铜头铁额」；免除被围攻近防惩罚，按重甲厚度减免损甲，受近战反震敌甲 10 点，外伤门槛 +35%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_yuchang_cisha <- {
	ID = "wx_manual_yuchang_cisha", Name = "专诸刺王秘录", Category = "henglian", Quality = "secret",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_yuchang_cisha.png",
	Description = "会稽鱼肠剑庐压箱刺客奇书：单手空副手透甲臻至决斗极境，对半血残敌痛下必杀一击。",
	BasePrice = 4540, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 76, Initiative = 105 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Initiative = 5 }, GrantSkills = [], Flags = { EmptyOffhandPen = 0.12, ExecuteLowHpDmg = 0.08 }, Summary = "武艺 +2，身法 +5；单手空副手穿甲 +12%，对半血残敌伤害 +8%。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 4, Initiative = 8, MeleeDefense = 2 }, GrantSkills = [], Flags = { EmptyOffhandPen = 0.20, ExecuteLowHpDmg = 0.14 }, Summary = "武艺 +4，身法 +8，招架 +2；单手空副手穿甲 +20%，对半血残敌伤害 +14%。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 5, Initiative = 12, MeleeDefense = 4 }, GrantSkills = [], Flags = { EmptyOffhandPen = 0.25, ExecuteLowHpDmg = 0.20, FirstRoundHit = 8 }, Summary = "武艺 +5，身法 +12，招架 +4；单手空副手穿甲 +25%，对半血残敌伤害 +20%，首轮命中 +8。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_wuwei_shuaiqi <- {
	ID = "wx_manual_wuwei_shuaiqi", Name = "六韬统军帅印篇", Category = "henglian", Quality = "secret",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_wuwei_shuaiqi.png",
	Description = "兵家统帅秘传兵书：一人镇中军而三军胆气生，号令群豪立除溃乱，结阵守御固若长城。",
	BasePrice = 4660, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Bravery = 65 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Bravery = 8, MeleeDefense = 1 }, GrantSkills = ["actives.wx_tactics_bamen"], Flags = { CommandAuraPct = 0.06, RallyBonus = 10, FormationBondDef = 2 }, Summary = "定力 +8，招架 +1；邻接同袍结阵守御定力 +2，四格定力光环 6%，聚义号令 +10；习得「八门金锁阵」。" },
		{ ExpNeeded = 250, Stats = { Bravery = 14, MeleeDefense = 2 }, GrantSkills = ["actives.wx_tactics_bamen", "actives.wx_rally_command"], Flags = { CommandAuraPct = 0.09, RallyBonus = 18, FormationBondDef = 4 }, Summary = "定力 +14，招架 +2；邻接同袍结阵守御定力 +4，四格定力光环 9%，聚义号令 +18；习得「聚义号令」。" },
		{ ExpNeeded = 600, Stats = { Bravery = 20, MeleeDefense = 4 }, GrantSkills = ["actives.wx_tactics_bamen", "actives.wx_rally_command"], Flags = { CommandAuraPct = 0.12, RallyBonus = 25, FormationBondDef = 5, AntiFearAura = true }, Summary = "定力 +20，招架 +4；邻接同袍结阵守御定力 +5，四格定力光环 12%，聚义号令 +25，抗惊骇检定定力 +15。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_tianchan_yi <- {
	ID = "wx_manual_tianchan_yi", Name = "天蚕蜕生宝衣功", Category = "henglian", Quality = "secret",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_tianchan_yi.png",
	Description = "昆仑与苗疆奇人合创的轻衣护身绝学：布衣卸伤达至化境，且每逢濒死如天蚕蜕壳再续生机！",
	BasePrice = 4540, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Hitpoints = 68, Initiative = 105 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 8 }, GrantSkills = [], Flags = { LightArmorMitigation = 0.30 }, Summary = "气血 +8；轻装实伤减免最高 30%。" },
		{ ExpNeeded = 250, Stats = { Hitpoints = 14 }, GrantSkills = ["perk.nine_lives"], Flags = { LightArmorMitigation = 0.45, GuixiTier = 2 }, Summary = "气血 +14；轻装实伤减免最高 45%，强化九死锁血回元。" },
		{ ExpNeeded = 600, Stats = { Hitpoints = 18, RangedDefense = 4 }, GrantSkills = ["perk.nine_lives", "actives.wx_henglian_jinchan"], Flags = { LightArmorMitigation = 0.55, GuixiTier = 3, TurnStartCleansePct = 45 }, Summary = "气血 +18，避暗 +4；轻装实伤减免最高 55%，回合初 45% 止血祛毒微回血，强化九死锁血回元；习得「金蝉卸甲劲」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_lingnan_xuandun <- {
	ID = "wx_manual_lingnan_xuandun", Name = "不动明王盾阵", Category = "henglian", Quality = "secret",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_lingnan_xuandun.png",
	Description = "南疆战阵守卫绝学：一盾当关万夫莫开，精通铁壁震山靠与换位援护，群丑合围亦难撼分毫。",
	BasePrice = 4600, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeDefense = 24, Hitpoints = 72 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 8, MeleeDefense = 2, RangedDefense = 2 }, GrantSkills = ["actives.wx_shield_bash_qi"], Flags = { ShieldDefBonus = 4, ShieldWallExpert = true }, Summary = "气血 +8，招架 +2，避暗 +2；持盾双防 +4，专精盾术省气；习得「铁壁震山靠」。" },
		{ ExpNeeded = 250, Stats = { Hitpoints = 14, MeleeDefense = 3, RangedDefense = 3 }, GrantSkills = ["actives.wx_shield_bash_qi", "actives.rotation"], Flags = { ShieldDefBonus = 5, ShieldWallExpert = true, UnderdogGuard = true }, Summary = "气血 +14，招架 +3，避暗 +3；持盾双防 +5，专精盾术省气，免除被围攻近防惩罚。" },
		{ ExpNeeded = 600, Stats = { Hitpoints = 20, MeleeDefense = 5, RangedDefense = 5 }, GrantSkills = ["actives.wx_shield_bash_qi", "actives.rotation", "actives.wx_shield_xuanwu"], Flags = { ShieldDefBonus = 6, ShieldWallExpert = true, UnderdogGuard = true }, Summary = "气血 +20，招架 +5，避暗 +5；持盾双防 +6，专精盾术省气，免除被围攻近防惩罚；习得「玄武拒马盾」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_tangmen_qimen <- {
	ID = "wx_manual_tangmen_qimen", Name = "天机百变匣谱", Category = "henglian", Quality = "secret",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_tangmen_qimen.png",
	Description = "蜀中唐家堡内堂机关奇书：袖藏百宝瞬息切换，贴身冷箭与淬毒破绽令强敌防不胜防。",
	BasePrice = 4540, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { RangedSkill = 72, Initiative = 102 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 2, Initiative = 5 }, GrantSkills = [], Flags = { QuickHands = true, CloseRangeShotBonus = 6 }, Summary = "射艺 +2，身法 +5；近距快射命中 +6，每回合首次换装免耗点。" },
		{ ExpNeeded = 250, Stats = { RangedSkill = 4, Initiative = 8 }, GrantSkills = ["actives.wx_tactics_qimen"], Flags = { QuickHands = true, CloseRangeShotBonus = 9, WuduPoisonPct = 45 }, Summary = "射艺 +4，身法 +8；近距快射命中 +9，每回合首次换装免耗点，伤血染奇毒 45%；习得「奇门遁甲雾」。" },
		{ ExpNeeded = 600, Stats = { RangedSkill = 5, Initiative = 12, RangedDefense = 3 }, GrantSkills = ["actives.wx_tactics_qimen", "actives.wx_smoke_cast"], Flags = { QuickHands = true, CloseRangeShotBonus = 12, WuduPoisonPct = 75, ExposeOnHitPct = 35 }, Summary = "射艺 +5，身法 +12，避暗 +3；近距快射命中 +12，普攻寻隙留破绽 35%，每回合首次换装免耗点，伤血染奇毒 75%；习得「掷烟蔽目」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_xuanwu_budong <- {
	ID = "wx_manual_xuanwu_budong", Name = "玄武不动神甲录", Category = "henglian", Quality = "unique",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_xuanwu_budong.png",
	Description = "前朝柱国铁卫统领陪葬孤本：集披甲行气、铜头铁额、沉岳硬抗、孤胆守阵与反震甲伤于一身的重装极境宝典！",
	BasePrice = 11770, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Hitpoints = 85, Stamina = 108 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 10, Initiative = -5, MeleeDefense = 2 }, GrantSkills = ["perk.brawny"], Flags = { HeavyArmorScale = 0.04, UnderdogGuard = true }, Summary = "气血 +10，身法 -5，招架 +2；免除被围攻近防惩罚，按重甲厚度减免损甲。" },
		{ ExpNeeded = 320, Stats = { Hitpoints = 15, Initiative = -7, MeleeDefense = 3, Bravery = 6 }, GrantSkills = ["perk.brawny", "perk.steel_brow", "actives.wx_henglian_panshi"], Flags = { HeavyArmorScale = 0.05, UnderdogGuard = true, ReflectArmorDmg = 8 }, Summary = "气血 +15，身法 -7，招架 +3，定力 +6「沉岳硬抗」；免除被围攻近防惩罚，按重甲厚度减免损甲，受近战反震敌甲 8 点；习得「磐石镇岳架」。" },
		{ ExpNeeded = 800, Stats = { Hitpoints = 20, Initiative = -8, MeleeDefense = 5, Bravery = 12 }, GrantSkills = ["perk.brawny", "perk.steel_brow", "actives.wx_henglian_panshi", "actives.wx_henglian_tiebushan"], Flags = { HeavyArmorScale = 0.06, UnderdogGuard = true, ReflectArmorDmg = 14, InjuryThresholdMult = 1.40 }, Summary = "气血 +20，身法 -8，招架 +5，定力 +12；免除被围攻近防惩罚，按重甲厚度减免损甲，受近战反震敌甲 14 点，外伤门槛 +40%；习得「铁布横练功」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_guigu_zongheng <- {
	ID = "wx_manual_guigu_zongheng", Name = "鬼谷纵横兵策", Category = "henglian", Quality = "unique",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_guigu_zongheng.png",
	Description = "先秦兵家奇书孤本：运筹帷幄决胜千里，统帅光环、战阵联防、洞悉破绽与慑魂威压兼备。",
	BasePrice = 11740, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Bravery = 72 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Bravery = 8, MeleeSkill = 2 }, GrantSkills = ["actives.wx_tactics_bamen"], Flags = { CommandAuraPct = 0.08, RallyBonus = 12, FormationBondDef = 3 }, Summary = "定力 +8，武艺 +2；邻接同袍结阵守御定力 +3，四格定力光环 8%，聚义号令 +12；习得「八门金锁阵」。" },
		{ ExpNeeded = 320, Stats = { Bravery = 15, MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_tactics_bamen", "perk.fearsome"], Flags = { CommandAuraPct = 0.10, RallyBonus = 20, FormationBondDef = 4, ExposeOnHitPct = 25 }, Summary = "定力 +15，武艺 +3，招架 +2；普攻寻隙留破绽 25%，邻接同袍结阵守御定力 +4，四格定力光环 10%，聚义号令 +20。" },
		{ ExpNeeded = 800, Stats = { Bravery = 22, MeleeSkill = 5, MeleeDefense = 4 }, GrantSkills = ["actives.wx_tactics_bamen", "perk.fearsome", "actives.wx_tactics_guigu"], Flags = { CommandAuraPct = 0.12, RallyBonus = 28, FormationBondDef = 5, ExposeOnHitPct = 40, AntiFearAura = true }, Summary = "定力 +22，武艺 +5，招架 +4；普攻寻隙留破绽 40%，邻接同袍结阵守御定力 +5，四格定力光环 12%，聚义号令 +28，抗惊骇检定定力 +15；习得「鬼谷纵横策」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shennong_baicao <- {
	ID = "wx_manual_shennong_baicao", Name = "神农百草奇经", Category = "henglian", Quality = "unique",
	Element = null, WeaponTypes = [], Icon = "ui/perks/wx_manual_shennong_baicao.png",
	Description = "上古药王医毒双绝孤本：自身百毒不侵、生生止血锁命，举手投足间令来犯强敌奇毒攻心，大成赐洗髓良机！",
	BasePrice = 11770, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Hitpoints = 75, Bravery = 65 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Hitpoints = 8, Bravery = 5 }, GrantSkills = ["perk.nine_lives"], Flags = { PoisonImmune = true, TurnStartCleansePct = 35, GuixiTier = 2 }, Summary = "气血 +8，定力 +5；回合初 35% 止血祛毒微回血，百毒不侵，强化九死锁血回元。" },
		{ ExpNeeded = 320, Stats = { Hitpoints = 14, Bravery = 10 }, GrantSkills = ["perk.nine_lives", "actives.wx_tactics_jinzhen"], Flags = { PoisonImmune = true, TurnStartCleansePct = 50, GuixiTier = 3, WuduPoisonPct = 60 }, Summary = "气血 +14，定力 +10；回合初 50% 止血祛毒微回血，伤血染奇毒 60%，百毒不侵，强化九死锁血回元；习得「金针渡穴诀」。" },
		{ ExpNeeded = 800, Stats = { Hitpoints = 20, Bravery = 15 }, GrantSkills = ["perk.nine_lives", "actives.wx_tactics_jinzhen"], Flags = { PoisonImmune = true, TurnStartCleansePct = 65, GuixiTier = 3, WuduPoisonPct = 100, GrantWashChance = 1 }, Summary = "气血 +20，定力 +15；首成获洗髓契机 +1，回合初 65% 止血祛毒微回血，伤血染奇毒 100%，百毒不侵，强化九死锁血回元。" }
	]
};
