// Expanded Neigong Manual Library (Four-Element Breathwork & Sects)
// Auto-audited against AGENTS.md stat & non-stacking redlines.

::Wuxia.Config.Manuals.wx_manual_zuowang_tu <- {
	ID = "wx_manual_zuowang_tu", Name = "坐忘导引术", Category = "neigong", Quality = "common",
	Element = "neutral", WeaponTypes = [], Icon = "ui/perks/wx_manual_zuowang_tu.png",
	Description = "道门外院早晚课诵的静坐导引诀，澄心定虑，尤善缓解临时内伤侵扰。",
	BasePrice = 400, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 5, Bravery = 2 }, GrantSkills = ["actives.wx_meditate"], Flags = {}, Summary = "内息 +5，定力 +2；习得「调息吐纳」。" },
		{ ExpNeeded = 80, Stats = { Stamina = 10, Bravery = 5 }, GrantSkills = ["actives.wx_meditate"], Flags = {}, Summary = "内息 +10，定力 +5。" },
		{ ExpNeeded = 180, Stats = { Stamina = 14, Bravery = 8, FatigueRecoveryRate = 1 }, GrantSkills = ["actives.wx_meditate"], Flags = { AntiInternalInjury = true }, Summary = "内息 +14，定力 +8，每回合回气 +1；内伤与失控风险减半。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_chanzong_zuo <- {
	ID = "wx_manual_chanzong_zuo", Name = "禅门伏虎呼吸", Category = "neigong", Quality = "common",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_chanzong_zuo.png",
	Description = "少室沙弥挑水担柴时修习的腹式呼吸法，气大力沉、外伤难侵。",
	BasePrice = 370, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 5, Hitpoints = 3 }, GrantSkills = ["actives.wx_meditate"], Flags = {}, Summary = "内息 +5，气血 +3；习得「调息吐纳」。" },
		{ ExpNeeded = 80, Stats = { Stamina = 10, Hitpoints = 6 }, GrantSkills = ["actives.wx_meditate"], Flags = { InjuryThresholdMult = 1.10 }, Summary = "内息 +10，气血 +6；外伤门槛 +10%。" },
		{ ExpNeeded = 180, Stats = { Stamina = 15, Hitpoints = 9 }, GrantSkills = ["actives.wx_meditate"], Flags = { InjuryThresholdMult = 1.18, OnHitQiRegen = 2 }, Summary = "内息 +15，气血 +9；外伤门槛 +18%，近战命中回 2 内息。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_yangsheng_jue <- {
	ID = "wx_manual_yangsheng_jue", Name = "五禽活血诀", Category = "neigong", Quality = "common",
	Element = "neutral", WeaponTypes = [], Icon = "ui/perks/wx_manual_yangsheng_jue.png",
	Description = "杏林医家效仿虎鹿熊猿鸟编创的活血吐纳，交锋之余可自行收敛创口流血。",
	BasePrice = 280, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 4, Hitpoints = 4 }, GrantSkills = ["actives.wx_meditate"], Flags = { TurnStartCleansePct = 15 }, Summary = "内息 +4，气血 +4；习得「调息吐纳」；回合初 15% 止血祛毒微回血。" },
		{ ExpNeeded = 80, Stats = { Stamina = 9, Hitpoints = 8 }, GrantSkills = ["actives.wx_meditate"], Flags = { TurnStartCleansePct = 25 }, Summary = "内息 +9，气血 +8；回合初 25% 止血祛毒微回血。" },
		{ ExpNeeded = 180, Stats = { Stamina = 14, Hitpoints = 12 }, GrantSkills = ["actives.wx_meditate"], Flags = { TurnStartCleansePct = 35 }, Summary = "内息 +14，气血 +12；回合初 35% 止血祛毒微回血。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_junwu_nei <- {
	ID = "wx_manual_junwu_nei", Name = "边军抱元桩", Category = "neigong", Quality = "common",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_junwu_nei.png",
	Description = "九边军镇戍卒寒夜站岗所练的抱元守一法，重在结阵定神、气力绵延。",
	BasePrice = 310, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 6, Bravery = 2 }, GrantSkills = ["actives.wx_meditate"], Flags = {}, Summary = "内息 +6，定力 +2；习得「调息吐纳」。" },
		{ ExpNeeded = 80, Stats = { Stamina = 11, Bravery = 4 }, GrantSkills = ["actives.wx_meditate"], Flags = { FormationBondDef = 1 }, Summary = "内息 +11，定力 +4；邻接同袍结阵守御定力 +1。" },
		{ ExpNeeded = 180, Stats = { Stamina = 15, Bravery = 6, FatigueRecoveryRate = 1 }, GrantSkills = ["actives.wx_meditate"], Flags = { FormationBondDef = 2 }, Summary = "内息 +15，定力 +6，每回合回气 +1；邻接同袍结阵守御定力 +2。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shuixi_gong <- {
	ID = "wx_manual_shuixi_gong", Name = "江豚闭气法", Category = "neigong", Quality = "common",
	Element = "yin", WeaponTypes = [], Icon = "ui/perks/wx_manual_shuixi_gong.png",
	Description = "洞庭与川江水鬼潜水采珠所传的绵长闭气功，善于腾挪闪避间换气。",
	BasePrice = 400, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 6, Initiative = 3 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnDodgeQiRegen = 1 }, Summary = "内息 +6，身法 +3；习得「调息吐纳」；闪避回 1 内息。" },
		{ ExpNeeded = 80, Stats = { Stamina = 11, Initiative = 5 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnDodgeQiRegen = 2 }, Summary = "内息 +11，身法 +5；闪避回 2 内息。" },
		{ ExpNeeded = 180, Stats = { Stamina = 15, Initiative = 8 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnDodgeQiRegen = 3, OnDodgeQiCap = 2 }, Summary = "内息 +15，身法 +8；闪避回 3 内息。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_liesha_tuna <- {
	ID = "wx_manual_liesha_tuna", Name = "饮风吞沙功", Category = "neigong", Quality = "common",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_liesha_tuna.png",
	Description = "西域驼工顶着热风流沙赶路练就的粗犷内息，越战越悍，斩敌顺气。",
	BasePrice = 340, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 6 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnKillQiRegen = 4 }, Summary = "内息 +6；习得「调息吐纳」；击杀回 4 内息。" },
		{ ExpNeeded = 80, Stats = { Stamina = 11, Hitpoints = 4 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnKillQiRegen = 6 }, Summary = "内息 +11，气血 +4；击杀回 6 内息。" },
		{ ExpNeeded = 180, Stats = { Stamina = 15, Hitpoints = 8 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnKillQiRegen = 9 }, Summary = "内息 +15，气血 +8；击杀回 9 内息。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_chaoxi_xin <- {
	ID = "wx_manual_chaoxi_xin", Name = "海塘听潮诀", Category = "neigong", Quality = "common",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_chaoxi_xin.png",
	Description = "钱塘盐工迎着大潮呼吸吐纳的法门，一呼一吸劲力层叠，震散敌手内息。",
	BasePrice = 370, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 5 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnHitDrainQi = 2 }, Summary = "内息 +5；习得「调息吐纳」；命中震散敌内息 2 点。" },
		{ ExpNeeded = 80, Stats = { Stamina = 10, Bravery = 3 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnHitDrainQi = 3 }, Summary = "内息 +10，定力 +3；命中震散敌内息 3 点。" },
		{ ExpNeeded = 180, Stats = { Stamina = 15, Bravery = 5 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnHitDrainQi = 4, OnHitQiRegen = 2 }, Summary = "内息 +15，定力 +5；近战命中回 2 内息，命中震散敌内息 4 点。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_caishen_nuannu <- {
	ID = "wx_manual_caishen_nuannu", Name = "暖玉温脉功", Category = "neigong", Quality = "common",
	Element = "neutral", WeaponTypes = [], Icon = "ui/perks/wx_manual_caishen_nuannu.png",
	Description = "关外老参客在冰天雪地护住心脉不僵的温养吐纳，回气匀净。",
	BasePrice = 400, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 5, FatigueRecoveryRate = 1 }, GrantSkills = ["actives.wx_meditate"], Flags = {}, Summary = "内息 +5，每回合回气 +1；习得「调息吐纳」。" },
		{ ExpNeeded = 80, Stats = { Stamina = 10, Hitpoints = 4, FatigueRecoveryRate = 1 }, GrantSkills = ["actives.wx_meditate"], Flags = {}, Summary = "内息 +10，气血 +4，每回合回气 +1。" },
		{ ExpNeeded = 180, Stats = { Stamina = 15, Hitpoints = 8, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_meditate"], Flags = {}, Summary = "内息 +15，气血 +8，每回合回气 +2。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_yeying_biqi <- {
	ID = "wx_manual_yeying_biqi", Name = "敛息匿影诀", Category = "neigong", Quality = "common",
	Element = "yin", WeaponTypes = [], Icon = "ui/perks/wx_manual_yeying_biqi.png",
	Description = "梁上君子与夜行人屏住呼吸心跳的法门，开局先发抢快，夜战心明眼亮。",
	BasePrice = 310, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 5, Initiative = 4 }, GrantSkills = ["actives.wx_meditate"], Flags = { FirstRoundInit = 6 }, Summary = "内息 +5，身法 +4；习得「调息吐纳」；首轮身法 +6。" },
		{ ExpNeeded = 80, Stats = { Stamina = 10, Initiative = 7 }, GrantSkills = ["actives.wx_meditate"], Flags = { FirstRoundInit = 10 }, Summary = "内息 +10，身法 +7；首轮身法 +10。" },
		{ ExpNeeded = 180, Stats = { Stamina = 14, Initiative = 10 }, GrantSkills = ["actives.wx_meditate"], Flags = { FirstRoundInit = 14, NightOwl = true }, Summary = "内息 +14，身法 +10；首轮身法 +14，夜战无视视野惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_duzhang_bi <- {
	ID = "wx_manual_duzhang_bi", Name = "辟瘴纳气篇", Category = "neigong", Quality = "common",
	Element = "evil", WeaponTypes = [], Icon = "ui/perks/wx_manual_duzhang_bi.png",
	Description = "辰州赶尸匠与南疆采药人出入毒林尸冢的闭瘴法门，心神不惧阴煞。",
	BasePrice = 280, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 5, Bravery = 3 }, GrantSkills = ["actives.wx_meditate"], Flags = {}, Summary = "内息 +5，定力 +3；习得「调息吐纳」。" },
		{ ExpNeeded = 80, Stats = { Stamina = 10, Bravery = 6 }, GrantSkills = ["actives.wx_meditate"], Flags = { TurnStartCleansePct = 20 }, Summary = "内息 +10，定力 +6；回合初 20% 止血祛毒微回血。" },
		{ ExpNeeded = 180, Stats = { Stamina = 15, Bravery = 9 }, GrantSkills = ["actives.wx_meditate"], Flags = { TurnStartCleansePct = 30, AntiFearAura = true }, Summary = "内息 +15，定力 +9；回合初 30% 止血祛毒微回血，抗惊骇检定定力 +15。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zixia_gong <- {
	ID = "wx_manual_zixia_gong", Name = "西岳紫气诀", Category = "neigong", Quality = "sect",
	Element = "neutral", WeaponTypes = [], Icon = "ui/perks/wx_manual_zixia_gong.png",
	Description = "西岳紫霞观镇观炼气心法，紫气东来绵绵不绝，越是持久缠斗越显内力醇厚。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Bravery = 48, Stamina = 95 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 10, FatigueRecoveryRate = 2, Initiative = 4 }, GrantSkills = ["actives.wx_neigong_zixia"], Flags = {}, Summary = "内息 +10，每回合回气 +2，身法 +4；习得「紫霞流云气」。" },
		{ ExpNeeded = 160, Stats = { Stamina = 18, FatigueRecoveryRate = 4, Initiative = 7 }, GrantSkills = ["actives.wx_neigong_zixia"], Flags = { QiShieldPct = 0.20 }, Summary = "内息 +18，每回合回气 +4，身法 +7；真气护体 20%。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, FatigueRecoveryRate = 6, Initiative = 10 }, GrantSkills = ["actives.wx_neigong_zixia"], Flags = { QiShieldPct = 0.30, AntiInternalInjury = true }, Summary = "内息 +25，每回合回气 +6，身法 +10；真气护体 30%，内伤与失控风险减半。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_chanyang_gong <- {
	ID = "wx_manual_chanyang_gong", Name = "达摩伏魔功", Category = "neigong", Quality = "sect",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_chanyang_gong.png",
	Description = "少室禅院戒律院主修阳刚内功，真气浑厚如洪钟大吕，拳兵相交可震散敌方内息且破邪镇魂。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Stamina = 98, Bravery = 50 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 12, Hitpoints = 5, Bravery = 4 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnHitDrainQi = 3 }, Summary = "内息 +12，气血 +5，定力 +4；命中震散敌内息 3 点；习得「调息吐纳」。" },
		{ ExpNeeded = 160, Stats = { Stamina = 19, Hitpoints = 10, Bravery = 8 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnHitDrainQi = 5, VsUndeadDmg = 0.08 }, Summary = "内息 +19，气血 +10，定力 +8；命中震散敌内息 5 点，对尸傀机关总伤 +8%。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, Hitpoints = 15, Bravery = 12, FatigueRecoveryRate = 3 }, GrantSkills = ["actives.wx_meditate", "actives.wx_neigong_jinzhong"], Flags = { OnHitDrainQi = 6, VsUndeadDmg = 0.14 }, Summary = "内息 +25，气血 +15，定力 +12，每回合回气 +3；命中震散敌内息 6 点，对尸傀机关总伤 +14%；习得「金钟护体罡」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_emei_linji <- {
	ID = "wx_manual_emei_linji", Name = "金顶清音诀", Category = "neigong", Quality = "sect",
	Element = "yin", WeaponTypes = [], Icon = "ui/perks/wx_manual_emei_linji.png",
	Description = "峨眉金顶庵秘传动静双修心法，静若寒潭护体、动若流风活血祛毒。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Bravery = 48, Initiative = 95 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 10, Initiative = 5, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_neigong_guiyuan"], Flags = { TurnStartCleansePct = 25 }, Summary = "内息 +10，身法 +5，每回合回气 +2；回合初 25% 止血祛毒微回血；习得「太和归元劲」。" },
		{ ExpNeeded = 160, Stats = { Stamina = 18, Initiative = 8, FatigueRecoveryRate = 3 }, GrantSkills = ["actives.wx_neigong_guiyuan"], Flags = { TurnStartCleansePct = 40, QiShieldPct = 0.25 }, Summary = "内息 +18，身法 +8，每回合回气 +3；真气护体 25%，回合初 40% 止血祛毒微回血。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, Initiative = 12, FatigueRecoveryRate = 5 }, GrantSkills = ["actives.wx_neigong_guiyuan"], Flags = { TurnStartCleansePct = 55, QiShieldPct = 0.35 }, Summary = "内息 +25，身法 +12，每回合回气 +5；真气护体 35%，回合初 55% 止血祛毒微回血。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zhongnan_bi <- {
	ID = "wx_manual_zhongnan_bi", Name = "古墓寒玉功", Category = "neigong", Quality = "sect",
	Element = "yin", WeaponTypes = [], Icon = "ui/perks/wx_manual_zhongnan_bi.png",
	Description = "终南活死人庐卧寒玉石榻修习的冷冽内功，心如止水不生杂念，先手奇快且寒气侵敌。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 100 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 10, Initiative = 6 }, GrantSkills = ["actives.wx_meditate"], Flags = { FirstRoundInit = 10, OnDodgeQiRegen = 2 }, Summary = "内息 +10，身法 +6；首轮身法 +10，闪避回 2 内息；习得「调息吐纳」。" },
		{ ExpNeeded = 160, Stats = { Stamina = 18, Initiative = 10 }, GrantSkills = ["actives.wx_meditate"], Flags = { FirstRoundInit = 15, OnDodgeQiRegen = 4, QiShieldPct = 0.25 }, Summary = "内息 +18，身法 +10；首轮身法 +15，真气护体 25%，闪避回 4 内息。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, Initiative = 14 }, GrantSkills = ["actives.wx_meditate", "actives.wx_neigong_hanbing"], Flags = { FirstRoundInit = 20, OnDodgeQiRegen = 5, QiShieldPct = 0.32, FrostChillOnHit = true }, Summary = "内息 +25，身法 +14；首轮身法 +20，真气护体 32%，受近战寒劲反侵令敌失衡，闪避回 5 内息；习得「玄阴寒冰气」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_qingcheng_xuan <- {
	ID = "wx_manual_qingcheng_xuan", Name = "幽谷玄阴气", Category = "neigong", Quality = "sect",
	Element = "yin", WeaponTypes = [], Icon = "ui/perks/wx_manual_qingcheng_xuan.png",
	Description = "青城幽谷观偏门炼气法，真气幽冷刁钻，夜战目明如昼，出招顺势抽髓散气。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 96 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 10, Initiative = 5 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnHitDrainQi = 3 }, Summary = "内息 +10，身法 +5；习得「调息吐纳」；命中震散敌内息 3 点。" },
		{ ExpNeeded = 160, Stats = { Stamina = 18, Initiative = 9, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnHitDrainQi = 5, NightOwl = true }, Summary = "内息 +18，身法 +9，每回合回气 +2；夜战无视视野惩罚，命中震散敌内息 5 点。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, Initiative = 12, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnHitDrainQi = 7, NightOwl = true, QiShieldPct = 0.25 }, Summary = "内息 +25，身法 +12，每回合回气 +4；真气护体 25%，夜战无视视野惩罚，命中震散敌内息 7 点。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_wuyi_chaxin <- {
	ID = "wx_manual_wuyi_chaxin", Name = "碧水春云功", Category = "neigong", Quality = "sect",
	Element = "neutral", WeaponTypes = [], Icon = "ui/perks/wx_manual_wuyi_chaxin.png",
	Description = "武夷碧水轩品茗悟道的养生上乘内功，气息清润悠长，最善听风避矢与调和百脉。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Bravery = 46 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 10, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_neigong_chaoxi"], Flags = { DodgeRangedBonus = 3 }, Summary = "内息 +10，每回合回气 +2；听风避矢 +3；习得「沧海潮生诀」。" },
		{ ExpNeeded = 160, Stats = { Stamina = 18, FatigueRecoveryRate = 4, Initiative = 5 }, GrantSkills = ["actives.wx_neigong_chaoxi"], Flags = { DodgeRangedBonus = 5, HarmonizeConflict = true }, Summary = "内息 +18，每回合回气 +4，身法 +5；听风避矢 +5，调和阴阳正邪内息冲突。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, FatigueRecoveryRate = 6, Initiative = 8 }, GrantSkills = ["actives.wx_neigong_chaoxi"], Flags = { DodgeRangedBonus = 7, HarmonizeConflict = true }, Summary = "内息 +25，每回合回气 +6，身法 +8；听风避矢 +7，调和阴阳正邪内息冲突。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_gusumu_nei <- {
	ID = "wx_manual_gusumu_nei", Name = "参合纳虚功", Category = "neigong", Quality = "sect",
	Element = "neutral", WeaponTypes = [], Icon = "ui/perks/wx_manual_gusumu_nei.png",
	Description = "姑苏慕氏剑庄家传纳气心法，讲究借敌来势化为己用，闪避拆招之间真气生生不息。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 95, Bravery = 45 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 10, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnDodgeQiRegen = 3, OnHitQiRegen = 2 }, Summary = "内息 +10，每回合回气 +2；近战命中回 2 内息，闪避回 3 内息；习得「调息吐纳」。" },
		{ ExpNeeded = 160, Stats = { Stamina = 18, FatigueRecoveryRate = 3, Bravery = 5 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnDodgeQiRegen = 4, OnHitQiRegen = 3, QiShieldPct = 0.22 }, Summary = "内息 +18，每回合回气 +3，定力 +5；真气护体 22%，近战命中回 3 内息，闪避回 4 内息。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, FatigueRecoveryRate = 5, Bravery = 8 }, GrantSkills = ["actives.wx_meditate", "actives.wx_neigong_douzhuan"], Flags = { OnDodgeQiRegen = 5, OnHitQiRegen = 4, QiShieldPct = 0.30, HarmonizeConflict = true }, Summary = "内息 +25，每回合回气 +5，定力 +8；真气护体 30%，近战命中回 4 内息，闪避回 5 内息，调和阴阳正邪内息冲突；习得「斗转星移诀」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_qianjiang_chao <- {
	ID = "wx_manual_qianjiang_chao", Name = "怒潮叠浪功", Category = "neigong", Quality = "sect",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_qianjiang_chao.png",
	Description = "钱塘怒潮帮帮主秘传刚猛内功，发力如海潮一浪高过一浪，近战重击易震得敌手失衡。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Stamina = 98, Hitpoints = 68 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 12, Hitpoints = 5 }, GrantSkills = ["actives.wx_neigong_chaoxi"], Flags = { OnHitQiRegen = 2, DazeOnHeavyHitPct = 20 }, Summary = "内息 +12，气血 +5；重击震荡失衡 20%，近战命中回 2 内息；习得「沧海潮生诀」。" },
		{ ExpNeeded = 160, Stats = { Stamina = 19, Hitpoints = 10, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_neigong_chaoxi"], Flags = { OnHitQiRegen = 3, DazeOnHeavyHitPct = 35 }, Summary = "内息 +19，气血 +10，每回合回气 +2；重击震荡失衡 35%，近战命中回 3 内息。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, Hitpoints = 15, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_neigong_chaoxi"], Flags = { OnHitQiRegen = 4, DazeOnHeavyHitPct = 50 }, Summary = "内息 +25，气血 +15，每回合回气 +4；重击震荡失衡 50%，近战命中回 4 内息。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_xinglin_bencao <- {
	ID = "wx_manual_xinglin_bencao", Name = "青囊济脉经", Category = "neigong", Quality = "sect",
	Element = "neutral", WeaponTypes = [], Icon = "ui/perks/wx_manual_xinglin_bencao.png",
	Description = "杏林济世堂历代医圣汇总的护脉真经，百毒难侵、活血生肌，更能免疫内伤失控。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Hitpoints = 65, Bravery = 48 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 10, Hitpoints = 6, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_meditate"], Flags = { TurnStartCleansePct = 30 }, Summary = "内息 +10，气血 +6，每回合回气 +2；回合初 30% 止血祛毒微回血；习得「调息吐纳」。" },
		{ ExpNeeded = 160, Stats = { Stamina = 18, Hitpoints = 12, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_meditate"], Flags = { TurnStartCleansePct = 45, PoisonImmune = true }, Summary = "内息 +18，气血 +12，每回合回气 +4；回合初 45% 止血祛毒微回血，百毒不侵。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, Hitpoints = 18, FatigueRecoveryRate = 5 }, GrantSkills = ["actives.wx_meditate", "actives.wx_neigong_yijin"], Flags = { TurnStartCleansePct = 60, PoisonImmune = true, AntiInternalInjury = true }, Summary = "内息 +25，气血 +18，每回合回气 +5；内伤与失控风险减半，回合初 60% 止血祛毒微回血，百毒不侵；习得「易筋洗髓功」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_luoyang_changfeng <- {
	ID = "wx_manual_luoyang_changfeng", Name = "长风浩气诀", Category = "neigong", Quality = "sect",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_luoyang_changfeng.png",
	Description = "洛阳长风镖局总镖头必修的正气内功，千里走镖不疲，与同袍并肩结阵时愈发沉稳。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Stamina = 95, Bravery = 48 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 11, Bravery = 5, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_neigong_junwu"], Flags = { FormationBondDef = 2 }, Summary = "内息 +11，定力 +5，每回合回气 +2；邻接同袍结阵守御定力 +2；习得「破阵杀伐气」。" },
		{ ExpNeeded = 160, Stats = { Stamina = 18, Bravery = 9, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_neigong_junwu"], Flags = { FormationBondDef = 3 }, Summary = "内息 +18，定力 +9，每回合回气 +4；邻接同袍结阵守御定力 +3。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, Bravery = 14, FatigueRecoveryRate = 6 }, GrantSkills = ["actives.wx_neigong_junwu"], Flags = { FormationBondDef = 4, AntiFearAura = true }, Summary = "内息 +25，定力 +14，每回合回气 +6；邻接同袍结阵守御定力 +4，抗惊骇检定定力 +15。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_songyang_gang <- {
	ID = "wx_manual_songyang_gang", Name = "嵩阳赤日功", Category = "neigong", Quality = "sect",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_songyang_gang.png",
	Description = "嵩阳铁剑门至刚内功，真气炽烈如骄阳炙铁，命中回气充沛且增强抗伤筋骨。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Stamina = 98 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 12, Hitpoints = 4, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_neigong_junwu"], Flags = { OnHitQiRegen = 2 }, Summary = "内息 +12，气血 +4，每回合回气 +2；近战命中回 2 内息；习得「破阵杀伐气」。" },
		{ ExpNeeded = 160, Stats = { Stamina = 19, Hitpoints = 9, FatigueRecoveryRate = 3 }, GrantSkills = ["actives.wx_neigong_junwu"], Flags = { OnHitQiRegen = 3, InjuryThresholdMult = 1.15 }, Summary = "内息 +19，气血 +9，每回合回气 +3；外伤门槛 +15%，近战命中回 3 内息。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, Hitpoints = 14, FatigueRecoveryRate = 5 }, GrantSkills = ["actives.wx_neigong_junwu"], Flags = { OnHitQiRegen = 4, OnHitQiCap = 3, InjuryThresholdMult = 1.25 }, Summary = "内息 +25，气血 +14，每回合回气 +5；外伤门槛 +25%，近战命中回 4 内息。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_wudu_zhangqi <- {
	ID = "wx_manual_wudu_zhangqi", Name = "百蛊蚀脉功", Category = "neigong", Quality = "sect",
	Element = "evil", WeaponTypes = [], Icon = "ui/perks/wx_manual_wudu_zhangqi.png",
	Description = "南疆五毒奇门采百虫瘴气入体的诡异内功，身具奇毒免疫，近身交锋令敌中毒散气。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Bravery = 45 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 10, Initiative = 4 }, GrantSkills = ["actives.wx_meditate"], Flags = { WuduPoisonPct = 25 }, Summary = "内息 +10，身法 +4；伤血染奇毒 25%；习得「调息吐纳」。" },
		{ ExpNeeded = 160, Stats = { Stamina = 18, Initiative = 8, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_meditate"], Flags = { WuduPoisonPct = 45, PoisonImmune = true }, Summary = "内息 +18，身法 +8，每回合回气 +2；伤血染奇毒 45%，百毒不侵。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, Initiative = 12, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_meditate", "actives.wx_neigong_wudu"], Flags = { WuduPoisonPct = 65, PoisonImmune = true, OnHitDrainQi = 5 }, Summary = "内息 +25，身法 +12，每回合回气 +4；命中震散敌内息 5 点，伤血染奇毒 65%，百毒不侵；习得「万蛊噬元瘴」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_xiangxi_shiyin <- {
	ID = "wx_manual_xiangxi_shiyin", Name = "辰州伏尸阴功", Category = "neigong", Quality = "sect",
	Element = "evil", WeaponTypes = [], Icon = "ui/perks/wx_manual_xiangxi_shiyin.png",
	Description = "湘西辰州符水门夜行荒冢的阴寒心法，不惧怨灵鬼啸，对古墓尸傀更有克制奇效。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Bravery = 50 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 10, Bravery = 6 }, GrantSkills = ["actives.wx_meditate"], Flags = { VsUndeadDmg = 0.06 }, Summary = "内息 +10，定力 +6；习得「调息吐纳」；对尸傀机关总伤 +6%。" },
		{ ExpNeeded = 160, Stats = { Stamina = 18, Bravery = 11, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_meditate"], Flags = { VsUndeadDmg = 0.10, AntiFearAura = true }, Summary = "内息 +18，定力 +11，每回合回气 +2；对尸傀机关总伤 +10%，抗惊骇检定定力 +15。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, Bravery = 16, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_meditate"], Flags = { VsUndeadDmg = 0.15, AntiFearAura = true, QiShieldPct = 0.25 }, Summary = "内息 +25，定力 +16，每回合回气 +4；真气护体 25%，对尸傀机关总伤 +15%，抗惊骇检定定力 +15。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_heishui_xue <- {
	ID = "wx_manual_heishui_xue", Name = "黑水沸血功", Category = "neigong", Quality = "sect",
	Element = "evil", WeaponTypes = [], Icon = "ui/perks/wx_manual_heishui_xue.png",
	Description = "关外黑水战帮猎杀巨熊饮血练就的凶悍内功，斩敌之时气血沸腾、以战养战。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Hitpoints = 72 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 10, Hitpoints = 6 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnKillHealHP = 4, OnKillQiRegen = 6 }, Summary = "内息 +10，气血 +6；击杀回 6 内息，击杀生人回 4 气血；习得「调息吐纳」。" },
		{ ExpNeeded = 160, Stats = { Stamina = 18, Hitpoints = 11 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnKillHealHP = 7, OnKillQiRegen = 10 }, Summary = "内息 +18，气血 +11；击杀回 10 内息，击杀生人回 7 气血。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, Hitpoints = 16, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_meditate", "actives.wx_neigong_taotie"], Flags = { OnKillHealHP = 10, OnKillQiRegen = 14 }, Summary = "内息 +25，气血 +16，每回合回气 +2；击杀回 14 内息，击杀生人回 10 气血；习得「饕餮吞天诀」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_mingzun_huo <- {
	ID = "wx_manual_mingzun_huo", Name = "大漠圣火心诀", Category = "neigong", Quality = "sect",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_mingzun_huo.png",
	Description = "西域圣火明尊教传教长老必修心法，真气忽冷忽热诡奇多端，开场爆发迅猛且具护体烈焰。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 98, Bravery = 48 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 10, Initiative = 5, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_meditate"], Flags = { FirstRoundInit = 10 }, Summary = "内息 +10，身法 +5，每回合回气 +2；习得「调息吐纳」；首轮身法 +10。" },
		{ ExpNeeded = 160, Stats = { Stamina = 18, Initiative = 9, FatigueRecoveryRate = 3 }, GrantSkills = ["actives.wx_meditate"], Flags = { FirstRoundInit = 15, QiShieldPct = 0.22 }, Summary = "内息 +18，身法 +9，每回合回气 +3；首轮身法 +15，真气护体 22%。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, Initiative = 12, FatigueRecoveryRate = 5 }, GrantSkills = ["actives.wx_meditate"], Flags = { FirstRoundInit = 20, FirstRoundHit = 8, QiShieldPct = 0.30 }, Summary = "内息 +25，身法 +12，每回合回气 +5；首轮身法 +20，首轮命中 +8，真气护体 30%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_tangmen_duxin <- {
	ID = "wx_manual_tangmen_duxin", Name = "唐门锁脉玄功", Category = "neigong", Quality = "sect",
	Element = "yin", WeaponTypes = [], Icon = "ui/perks/wx_manual_tangmen_duxin.png",
	Description = "蜀中唐家堡内堂弟子淬炼指力与眼力的独门内息，夜视无碍、百毒不侵，专助暗器机关。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 95 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 10, Initiative = 5, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_meditate"], Flags = { NightOwl = true }, Summary = "内息 +10，身法 +5，每回合回气 +2；夜战无视视野惩罚；习得「调息吐纳」。" },
		{ ExpNeeded = 160, Stats = { Stamina = 18, Initiative = 9, FatigueRecoveryRate = 3 }, GrantSkills = ["actives.wx_meditate"], Flags = { NightOwl = true, PoisonImmune = true }, Summary = "内息 +18，身法 +9，每回合回气 +3；夜战无视视野惩罚，百毒不侵。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, Initiative = 13, FatigueRecoveryRate = 5 }, GrantSkills = ["actives.wx_meditate", "actives.wx_neigong_wudu"], Flags = { NightOwl = true, PoisonImmune = true, FirstRoundHit = 8 }, Summary = "内息 +25，身法 +13，每回合回气 +5；首轮命中 +8，夜战无视视野惩罚，百毒不侵；习得「万蛊噬元瘴」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_yijin_chan <- {
	ID = "wx_manual_yijin_chan", Name = "洗髓易筋禅功", Category = "neigong", Quality = "secret",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_yijin_chan.png",
	Description = "少室禅院藏经阁不传至宝心法，脱胎换骨、调和百脉，兼具磅礴回气与活血祛毒之功。",
	BasePrice = 4660, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Bravery = 60, Stamina = 105 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 16, Hitpoints = 6, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_neigong_yijin"], Flags = { TurnStartCleansePct = 30 }, Summary = "内息 +16，气血 +6，每回合回气 +2；回合初 30% 止血祛毒微回血；习得「易筋洗髓功」。" },
		{ ExpNeeded = 250, Stats = { Stamina = 26, Hitpoints = 12, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_neigong_yijin"], Flags = { TurnStartCleansePct = 45, HarmonizeConflict = true, AntiInternalInjury = true }, Summary = "内息 +26，气血 +12，每回合回气 +4；调和阴阳正邪内息冲突，内伤与失控风险减半，回合初 45% 止血祛毒微回血。" },
		{ ExpNeeded = 600, Stats = { Stamina = 35, Hitpoints = 18, FatigueRecoveryRate = 6 }, GrantSkills = ["actives.wx_neigong_yijin", "actives.wx_neigong_jinzhong"], Flags = { TurnStartCleansePct = 60, HarmonizeConflict = true, AntiInternalInjury = true, PoisonImmune = true }, Summary = "内息 +35，气血 +18，每回合回气 +6；调和阴阳正邪内息冲突，内伤与失控风险减半，回合初 60% 止血祛毒微回血，百毒不侵；习得「金钟护体罡」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zixia_shen <- {
	ID = "wx_manual_zixia_shen", Name = "紫霞先天功", Category = "neigong", Quality = "secret",
	Element = "neutral", WeaponTypes = [], Icon = "ui/perks/wx_manual_zixia_shen.png",
	Description = "西岳紫霞观掌门代代口传的先天炼气绝学，生机醇正绵密，真气护体与回气速度俱臻绝顶。",
	BasePrice = 4600, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Bravery = 58, Stamina = 102 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 15, Bravery = 6, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_neigong_zixia"], Flags = { QiShieldPct = 0.20 }, Summary = "内息 +15，定力 +6，每回合回气 +2；真气护体 20%；习得「紫霞流云气」。" },
		{ ExpNeeded = 250, Stats = { Stamina = 25, Bravery = 11, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_neigong_zixia"], Flags = { QiShieldPct = 0.28, OnHitQiRegen = 3 }, Summary = "内息 +25，定力 +11，每回合回气 +4；真气护体 28%，近战命中回 3 内息。" },
		{ ExpNeeded = 600, Stats = { Stamina = 35, Bravery = 16, FatigueRecoveryRate = 6 }, GrantSkills = ["actives.wx_neigong_zixia", "actives.wx_neigong_guiyuan"], Flags = { QiShieldPct = 0.35, OnHitQiRegen = 4, HarmonizeConflict = true }, Summary = "内息 +35，定力 +16，每回合回气 +6；真气护体 35%，近战命中回 4 内息，调和阴阳正邪内息冲突；习得「太和归元劲」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_xuannv_bing <- {
	ID = "wx_manual_xuannv_bing", Name = "玄冥凝霜神功", Category = "neigong", Quality = "secret",
	Element = "yin", WeaponTypes = [], Icon = "ui/perks/wx_manual_xuannv_bing.png",
	Description = "昆仑玄冰宫镇宫绝学，寒毒凝于掌刃经络，受击反冻来敌失衡，出手亦抽夺对手真气。",
	BasePrice = 4540, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Bravery = 56, Initiative = 105 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 15, Initiative = 6, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_neigong_hanbing"], Flags = { QiShieldPct = 0.22 }, Summary = "内息 +15，身法 +6，每回合回气 +2；真气护体 22%；习得「玄阴寒冰气」。" },
		{ ExpNeeded = 250, Stats = { Stamina = 25, Initiative = 10, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_neigong_hanbing"], Flags = { QiShieldPct = 0.30, FrostChillOnHit = true }, Summary = "内息 +25，身法 +10，每回合回气 +4；真气护体 30%，受近战寒劲反侵令敌失衡。" },
		{ ExpNeeded = 600, Stats = { Stamina = 35, Initiative = 15, FatigueRecoveryRate = 5 }, GrantSkills = ["actives.wx_neigong_hanbing"], Flags = { QiShieldPct = 0.35, FrostChillOnHit = true, OnHitDrainQi = 7 }, Summary = "内息 +35，身法 +15，每回合回气 +5；真气护体 35%，受近战寒劲反侵令敌失衡，命中震散敌内息 7 点。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shenghuo_zong <- {
	ID = "wx_manual_shenghuo_zong", Name = "乾坤圣火宝典", Category = "neigong", Quality = "secret",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_shenghuo_zong.png",
	Description = "西域圣火明尊教总坛秘典，借圣火真气颠倒乾坤卸劲，闪避、命中双双回气，更可催动燃血爆发。",
	BasePrice = 4570, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Bravery = 58, Initiative = 105 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 15, Initiative = 5, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnHitQiRegen = 3, OnDodgeQiRegen = 3 }, Summary = "内息 +15，身法 +5，每回合回气 +2；习得「调息吐纳」；近战命中回 3 内息，闪避回 3 内息。" },
		{ ExpNeeded = 250, Stats = { Stamina = 25, Initiative = 10, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnHitQiRegen = 4, OnDodgeQiRegen = 4, QiShieldPct = 0.28 }, Summary = "内息 +25，身法 +10，每回合回气 +4；真气护体 28%，近战命中回 4 内息，闪避回 4 内息。" },
		{ ExpNeeded = 600, Stats = { Stamina = 35, Initiative = 14, FatigueRecoveryRate = 5 }, GrantSkills = ["actives.wx_meditate", "actives.wx_blood_burst"], Flags = { OnHitQiRegen = 5, OnDodgeQiRegen = 5, QiShieldPct = 0.35, BloodBurstAP = 2 }, Summary = "内息 +35，身法 +14，每回合回气 +5；习得「燃血催劲」；真气护体 35%，近战命中回 5 内息，闪避回 5 内息，燃血爆发 +2 AP。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_wudu_wanxian <- {
	ID = "wx_manual_wudu_wanxian", Name = "万蛊噬心魔功", Category = "neigong", Quality = "secret",
	Element = "evil", WeaponTypes = [], Icon = "ui/perks/wx_manual_wudu_wanxian.png",
	Description = "南疆五毒奇门至高毒脉魔功，周身血气皆化奇瘴，见血染毒、斩敌噬血回元。",
	BasePrice = 4570, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Bravery = 55, Hitpoints = 72 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 15, Hitpoints = 6 }, GrantSkills = ["actives.wx_neigong_wudu"], Flags = { WuduPoisonPct = 45, PoisonImmune = true }, Summary = "内息 +15，气血 +6；伤血染奇毒 45%，百毒不侵；习得「万蛊噬元瘴」。" },
		{ ExpNeeded = 250, Stats = { Stamina = 25, Hitpoints = 12, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_neigong_wudu"], Flags = { WuduPoisonPct = 70, PoisonImmune = true, OnKillHealHP = 6 }, Summary = "内息 +25，气血 +12，每回合回气 +2；击杀生人回 6 气血，伤血染奇毒 70%，百毒不侵。" },
		{ ExpNeeded = 600, Stats = { Stamina = 35, Hitpoints = 16, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_neigong_wudu"], Flags = { WuduPoisonPct = 90, PoisonImmune = true, OnKillHealHP = 10, VsPoisonedHit = 8 }, Summary = "内息 +35，气血 +16，每回合回气 +4；击杀生人回 10 气血，伤血染奇毒 90%，百毒不侵，对中毒目标命中 +8。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_gaibang_qinlong <- {
	ID = "wx_manual_gaibang_qinlong", Name = "混天气海功", Category = "neigong", Quality = "secret",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_gaibang_qinlong.png",
	Description = "天下丐帮历代帮主口耳相传的至阳气功，气海澎湃如长江奔涌，群战之中屹立不倒。",
	BasePrice = 4660, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Stamina = 105, Hitpoints = 75 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 16, Hitpoints = 6, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_neigong_junwu"], Flags = { OnHitQiRegen = 3 }, Summary = "内息 +16，气血 +6，每回合回气 +2；近战命中回 3 内息；习得「破阵杀伐气」。" },
		{ ExpNeeded = 250, Stats = { Stamina = 26, Hitpoints = 12, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_neigong_junwu"], Flags = { OnHitQiRegen = 4, UnderdogGuard = true }, Summary = "内息 +26，气血 +12，每回合回气 +4；免除被围攻近防惩罚，近战命中回 4 内息。" },
		{ ExpNeeded = 600, Stats = { Stamina = 35, Hitpoints = 18, FatigueRecoveryRate = 6 }, GrantSkills = ["actives.wx_neigong_junwu", "actives.wx_neigong_guiyuan"], Flags = { OnHitQiRegen = 5, OnHitQiCap = 3, UnderdogGuard = true, DazeOnHeavyHitPct = 40 }, Summary = "内息 +35，气血 +18，每回合回气 +6；重击震荡失衡 40%，免除被围攻近防惩罚，近战命中回 5 内息；习得「太和归元劲」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_gusumu_douzhuan <- {
	ID = "wx_manual_gusumu_douzhuan", Name = "星璇归墟功", Category = "neigong", Quality = "secret",
	Element = "yin", WeaponTypes = [], Icon = "ui/perks/wx_manual_gusumu_douzhuan.png",
	Description = "姑苏慕氏剑庄秘阁绝学，纳万家真气归于星璇气海，兼容阴阳不生冲突，闪避回气如渊。",
	BasePrice = 4600, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Initiative = 108, Bravery = 55 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 15, Initiative = 6, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_neigong_douzhuan"], Flags = { HarmonizeConflict = true, OnDodgeQiRegen = 3 }, Summary = "内息 +15，身法 +6，每回合回气 +2；闪避回 3 内息，调和阴阳正邪内息冲突；习得「斗转星移诀」。" },
		{ ExpNeeded = 250, Stats = { Stamina = 25, Initiative = 10, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_neigong_douzhuan"], Flags = { HarmonizeConflict = true, OnDodgeQiRegen = 5, QiShieldPct = 0.28 }, Summary = "内息 +25，身法 +10，每回合回气 +4；真气护体 28%，闪避回 5 内息，调和阴阳正邪内息冲突。" },
		{ ExpNeeded = 600, Stats = { Stamina = 35, Initiative = 14, FatigueRecoveryRate = 5 }, GrantSkills = ["actives.wx_neigong_douzhuan"], Flags = { HarmonizeConflict = true, OnDodgeQiRegen = 6, OnDodgeQiCap = 3, QiShieldPct = 0.35 }, Summary = "内息 +35，身法 +14，每回合回气 +5；真气护体 35%，闪避回 6 内息，调和阴阳正邪内息冲突。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_yinsha_guixi <- {
	ID = "wx_manual_yinsha_guixi", Name = "九幽潜渊诀", Category = "neigong", Quality = "secret",
	Element = "evil", WeaponTypes = [], Icon = "ui/perks/wx_manual_yinsha_guixi.png",
	Description = "幽冥隐杀楼楼主秘修刺客心法，声息全泯宛若幽魂，首轮暴起必夺先机，对残血目标痛下杀手。",
	BasePrice = 4600, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Initiative = 110 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 14, Initiative = 8, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_meditate"], Flags = { NightOwl = true, FirstRoundInit = 15 }, Summary = "内息 +14，身法 +8，每回合回气 +2；习得「调息吐纳」；首轮身法 +15，夜战无视视野惩罚。" },
		{ ExpNeeded = 250, Stats = { Stamina = 24, Initiative = 12, FatigueRecoveryRate = 3 }, GrantSkills = ["actives.wx_meditate"], Flags = { NightOwl = true, FirstRoundInit = 20, FirstRoundHit = 8 }, Summary = "内息 +24，身法 +12，每回合回气 +3；首轮身法 +20，首轮命中 +8，夜战无视视野惩罚。" },
		{ ExpNeeded = 600, Stats = { Stamina = 34, Initiative = 16, FatigueRecoveryRate = 5 }, GrantSkills = ["actives.wx_meditate"], Flags = { NightOwl = true, FirstRoundInit = 25, FirstRoundHit = 12, ExecuteLowHpDmg = 0.15 }, Summary = "内息 +34，身法 +16，每回合回气 +5；对半血残敌伤害 +15%，首轮身法 +25，首轮命中 +12，夜战无视视野惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_yanmen_zhenjun <- {
	ID = "wx_manual_yanmen_zhenjun", Name = "山河镇岳功", Category = "neigong", Quality = "secret",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_yanmen_zhenjun.png",
	Description = "九边大将压箱底的军阵内功绝学，不动如边关雄塞，与同袍结阵联防时固若金汤。",
	BasePrice = 4540, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Stamina = 102, Bravery = 60 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 16, Bravery = 6, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_neigong_junwu"], Flags = { FormationBondDef = 3 }, Summary = "内息 +16，定力 +6，每回合回气 +2；邻接同袍结阵守御定力 +3；习得「破阵杀伐气」。" },
		{ ExpNeeded = 250, Stats = { Stamina = 26, Bravery = 12, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_neigong_junwu"], Flags = { FormationBondDef = 4, AntiFearAura = true }, Summary = "内息 +26，定力 +12，每回合回气 +4；邻接同袍结阵守御定力 +4，抗惊骇检定定力 +15。" },
		{ ExpNeeded = 600, Stats = { Stamina = 35, Bravery = 18, FatigueRecoveryRate = 6 }, GrantSkills = ["actives.wx_neigong_junwu"], Flags = { FormationBondDef = 5, AntiFearAura = true, UnderdogGuard = true }, Summary = "内息 +35，定力 +18，每回合回气 +6；免除被围攻近防惩罚，邻接同袍结阵守御定力 +5，抗惊骇检定定力 +15。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_beiming_huaqi <- {
	ID = "wx_manual_beiming_huaqi", Name = "北冥化气篇", Category = "neigong", Quality = "unique",
	Element = "yin", WeaponTypes = [], Icon = "ui/perks/wx_manual_beiming_huaqi.png",
	Description = "失传千年的庄周逍遥派孤本残卷：海纳百川化敌内息为己用，调和诸般异种真气，护体借力臻于化境。",
	BasePrice = 11740, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Stamina = 108, Initiative = 112 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 16, Initiative = 6, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_neigong_chaoxi"], Flags = { OnHitDrainQi = 4, OnHitQiRegen = 3 }, Summary = "内息 +16，身法 +6，每回合回气 +2；近战命中回 3 内息，命中震散敌内息 4 点；习得「沧海潮生诀」。" },
		{ ExpNeeded = 320, Stats = { Stamina = 28, Initiative = 12, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_neigong_chaoxi", "actives.wx_neigong_xixing"], Flags = { OnHitDrainQi = 6, OnHitQiRegen = 4, HarmonizeConflict = true, QiShieldPct = 0.28 }, Summary = "内息 +28，身法 +12，每回合回气 +4；真气护体 28%，近战命中回 4 内息，命中震散敌内息 6 点，调和阴阳正邪内息冲突；习得「北冥噬气诀」。" },
		{ ExpNeeded = 800, Stats = { Stamina = 40, Initiative = 16, FatigueRecoveryRate = 6 }, GrantSkills = ["actives.wx_neigong_chaoxi", "actives.wx_neigong_xixing"], Flags = { OnHitDrainQi = 8, OnHitQiRegen = 5, OnHitQiCap = 3, HarmonizeConflict = true, QiShieldPct = 0.35 }, Summary = "内息 +40，身法 +16，每回合回气 +6；真气护体 35%，近战命中回 5 内息，命中震散敌内息 8 点，调和阴阳正邪内息冲突。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_dari_rulai <- {
	ID = "wx_manual_dari_rulai", Name = "大日烘炉经", Category = "neigong", Quality = "unique",
	Element = "yang", WeaponTypes = [], Icon = "ui/perks/wx_manual_dari_rulai.png",
	Description = "前朝皇家大内秘藏的至阳佛门孤本：气血如烘炉烈日，万邪辟易、外伤难侵，首次大成赐予洗髓良机。",
	BasePrice = 11800, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Stamina = 112, Bravery = 68 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 16, Hitpoints = 8, FatigueRecoveryRate = 2 }, GrantSkills = ["actives.wx_neigong_yijin"], Flags = { VsUndeadDmg = 0.10 }, Summary = "内息 +16，气血 +8，每回合回气 +2；对尸傀机关总伤 +10%；习得「易筋洗髓功」。" },
		{ ExpNeeded = 320, Stats = { Stamina = 28, Hitpoints = 14, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_neigong_yijin", "actives.wx_neigong_jinzhong"], Flags = { VsUndeadDmg = 0.15, AntiFearAura = true, InjuryThresholdMult = 1.25 }, Summary = "内息 +28，气血 +14，每回合回气 +4；外伤门槛 +25%，对尸傀机关总伤 +15%，抗惊骇检定定力 +15；习得「金钟护体罡」。" },
		{ ExpNeeded = 800, Stats = { Stamina = 40, Hitpoints = 20, FatigueRecoveryRate = 6 }, GrantSkills = ["actives.wx_neigong_yijin", "actives.wx_neigong_jinzhong"], Flags = { VsUndeadDmg = 0.20, AntiFearAura = true, InjuryThresholdMult = 1.35, GrantWashChance = 1 }, Summary = "内息 +40，气血 +20，每回合回气 +6；外伤门槛 +35%，首成获洗髓契机 +1，对尸傀机关总伤 +20%，抗惊骇检定定力 +15。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_tianmo_jieti <- {
	ID = "wx_manual_tianmo_jieti", Name = "天魔解体大法", Category = "neigong", Quality = "unique",
	Element = "evil", WeaponTypes = [], Icon = "ui/perks/wx_manual_tianmo_jieti.png",
	Description = "魔道禁忌孤本：逆行奇经八脉榨取潜能，大成突破常驻 +1 AP 且可施展燃血狂飙，与至阳正气水火不容！",
	BasePrice = 11740, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Bravery = 66, Hitpoints = 82 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Stamina = 16, Hitpoints = 8 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnKillQiRegen = 12, OnKillHealHP = 5 }, Summary = "内息 +16，气血 +8；习得「调息吐纳」；击杀回 12 内息，击杀生人回 5 气血。" },
		{ ExpNeeded = 320, Stats = { Stamina = 28, Hitpoints = 14, FatigueRecoveryRate = 3 }, GrantSkills = ["actives.wx_meditate", "actives.wx_blood_burst"], Flags = { OnKillQiRegen = 18, OnKillHealHP = 8, BloodBurstAP = 2 }, Summary = "内息 +28，气血 +14，每回合回气 +3；习得「燃血催劲」；击杀回 18 内息，击杀生人回 8 气血，燃血爆发 +2 AP。" },
		{ ExpNeeded = 800, Stats = { Stamina = 40, Hitpoints = 20, FatigueRecoveryRate = 5 }, GrantSkills = ["actives.wx_meditate", "actives.wx_blood_burst"], Flags = { OnKillQiRegen = 24, OnKillHealHP = 10, BloodBurstAP = 2, PermanentAPBonus = 1 }, Summary = "内息 +40，气血 +20，每回合回气 +5；击杀回 24 内息，击杀生人回 10 气血，燃血爆发 +2 AP，常驻行动点 +1。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_hamagong <- {
	ID = "wx_manual_hamagong", Name = "蛤蟆功", Category = "neigong", Quality = "secret",
	Element = "evil", WeaponTypes = [], Icon = "ui/perks/wx_manual_hamagong.png",
	Description = "西域白驼山秘传的逆脉奇门神功：俯身鼓腮蓄劲如金蟾伏地，静则护体反震、百毒不侵，动则拔地飞扑排山倒海，一击震裂五脏六腑！",
	BasePrice = 4750, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Stamina = 104, Bravery = 56 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Stamina = 15, Hitpoints = 6, FatigueRecoveryRate = 2 },               GrantSkills = ["actives.wx_meditate"], Flags = { QiShieldPct = 0.22, PoisonImmune = true }, Summary = "内息 +15，气血 +6，每回合回气 +2；习得「调息吐纳」；鼓腹真气护体 22%，百毒不侵。" },
		{ ExpNeeded = 250, Stats = { Stamina = 25, Hitpoints = 12, Bravery = 6, FatigueRecoveryRate = 4 },  GrantSkills = ["actives.wx_meditate", "actives.wx_hama_push"], Flags = { QiShieldPct = 0.30, PoisonImmune = true, DazeOnHeavyHitPct = 35, ReflectArmorDmg = 8 }, Summary = "内息 +25，气血 +12，定力 +6，回气 +4；习得绝技「金蟾推山扑」（蓄劲飞扑透甲震退）；护体 30%，受近战反震敌甲 8 点，重击失衡 35%。" },
		{ ExpNeeded = 600, Stats = { Stamina = 35, Hitpoints = 18, Bravery = 10, FatigueRecoveryRate = 5 }, GrantSkills = ["actives.wx_meditate", "actives.wx_hama_push"], Flags = { QiShieldPct = 0.35, PoisonImmune = true, AntiInternalInjury = true, DazeOnHeavyHitPct = 55, ReflectArmorDmg = 12, OnHitDrainQi = 6 }, Summary = "内息 +35，气血 +18，定力 +10，回气 +5；护体 35%，逆脉抗内伤，受击反震敌甲 12 点，近战震散敌内息 6 点、重击失衡 55%。" }
	]
};
