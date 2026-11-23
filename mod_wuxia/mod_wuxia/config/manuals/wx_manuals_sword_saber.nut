// Expanded Waigong Library I: Sword & Saber/Cleaver Lineages
// Auto-audited against AGENTS.md stat & non-stacking redlines.

::Wuxia.Config.Manuals.wx_manual_songyang_tiejian_ru <- {
	ID = "wx_manual_songyang_tiejian_ru", Name = "嵩阳重剑入门", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_songyang_tiejian_ru.png",
	Description = "嵩阳铁剑门外门弟子演练的阔剑劈砍架子，不尚花巧，专砸甲衣。",
	BasePrice = 370, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { ArmorDmgBonus = 0.06 }, Summary = "武艺 +1；破甲 +6%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2 }, GrantSkills = [], Flags = { ArmorDmgBonus = 0.12, WeaponQiDiscount = 0.08 }, Summary = "武艺 +2；招式耗气 -8%，破甲 +12%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 1 }, GrantSkills = ["actives.wx_sword_qinggang"], Flags = { ArmorDmgBonus = 0.18, WeaponQiDiscount = 0.14 }, Summary = "武艺 +3，招架 +1；招式耗气 -14%，破甲 +18%；习得「青釭透甲剑」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_qingcheng_kuaijian <- {
	ID = "wx_manual_qingcheng_kuaijian", Name = "青城偏锋剑", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_qingcheng_kuaijian.png",
	Description = "川西道观流传的斜刺快剑，剑走偏锋专削手腕见血。",
	BasePrice = 340, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1, Initiative = 2 }, GrantSkills = [], Flags = { BleedOnHitPct = 15 }, Summary = "武艺 +1，身法 +2；伤血割裂流血 15%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, Initiative = 4 }, GrantSkills = [], Flags = { BleedOnHitPct = 25 }, Summary = "武艺 +2，身法 +4；伤血割裂流血 25%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, Initiative = 6 }, GrantSkills = ["actives.wx_sword_kuangfeng"], Flags = { BleedOnHitPct = 35, FirstRoundHit = 4 }, Summary = "武艺 +3，身法 +6；首轮命中 +4，伤血割裂流血 35%；习得「落英疾风剑」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zhongzhou_peijian <- {
	ID = "wx_manual_zhongzhou_peijian", Name = "游侠佩剑术", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_zhongzhou_peijian.png",
	Description = "南北仗剑游侠防身的基本格刺剑法，攻守均衡且善寻破绽。",
	BasePrice = 400, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1, MeleeDefense = 1 }, GrantSkills = [], Flags = {}, Summary = "武艺 +1，招架 +1。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = [], Flags = { ExposeOnHitPct = 15 }, Summary = "武艺 +2，招架 +1；普攻寻隙留破绽 15%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = [], Flags = { ExposeOnHitPct = 25 }, Summary = "武艺 +3，招架 +2；普攻寻隙留破绽 25%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shuyuan_junzijian <- {
	ID = "wx_manual_shuyuan_junzijian", Name = "君子守礼剑", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_shuyuan_junzijian.png",
	Description = "中原儒生与年轻趟子手习练的雅正剑式，先守后攻、定心不乱。",
	BasePrice = 400, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeDefense = 1, Bravery = 2 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.08 }, Summary = "招架 +1，定力 +2；招式耗气 -8%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, MeleeDefense = 2, Bravery = 3 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.12 }, Summary = "武艺 +2，招架 +2，定力 +3；招式耗气 -12%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 2, Bravery = 5 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.18, FormationBondDef = 2 }, Summary = "武艺 +3，招架 +2，定力 +5；招式耗气 -18%，邻接同袍结阵守御定力 +2。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_taihe_liangyi <- {
	ID = "wx_manual_taihe_liangyi", Name = "太和两仪剑", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_taihe_liangyi.png",
	Description = "太和玄门镇观剑法，剑圈圆转绵密，敌进我退、敌退我刺，守中寓反击。",
	BasePrice = 2260, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64, MeleeDefense = 15 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_sword_taiji"], Flags = { CounterBonus = 6 }, Summary = "武艺 +2，招架 +1；习得「两仪化劲剑」；反击命中 +6。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_sword_taiji"], Flags = { CounterBonus = 10, WeaponQiDiscount = 0.12 }, Summary = "武艺 +4，招架 +2；招式耗气 -12%，反击命中 +10。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_sword_taiji", "actives.wx_sword_dugu"], Flags = { CounterBonus = 15, WeaponQiDiscount = 0.18, OnDodgeQiRegen = 3 }, Summary = "武艺 +5，招架 +3；招式耗气 -18%，反击命中 +15，闪避回 3 内息。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_songyang_zhongjian <- {
	ID = "wx_manual_songyang_zhongjian", Name = "大嵩阳寒铁剑", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_songyang_zhongjian.png",
	Description = "嵩阳铁剑门镇门刚猛剑法，将长剑当作重铁锏使，重劈碎甲并震得对手失衡！",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65, Stamina = 96 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2 }, GrantSkills = ["actives.wx_sword_zhongjian"], Flags = { ArmorDmgBonus = 0.12, DazeOnHeavyHitPct = 20 }, Summary = "武艺 +2；习得「重剑无锋劈」；破甲 +12%，重击震荡失衡 20%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 1 }, GrantSkills = ["actives.wx_sword_zhongjian"], Flags = { ArmorDmgBonus = 0.18, DazeOnHeavyHitPct = 35 }, Summary = "武艺 +4，招架 +1；破甲 +18%，重击震荡失衡 35%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 2 }, GrantSkills = ["actives.wx_sword_zhongjian", "actives.wx_sword_feixian"], Flags = { ArmorDmgBonus = 0.25, DazeOnHeavyHitPct = 50, ShieldBreakBonus = 10 }, Summary = "武艺 +5，招架 +2；破甲 +25%，重击震荡失衡 50%，碎盾劲 +10。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_huashan_duoming <- {
	ID = "wx_manual_huashan_duoming", Name = "西岳夺命三仙剑", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_huashan_duoming.png",
	Description = "西岳紫霞观险峻奇快剑路，起手抢攻一剑快似一剑，专刺咽喉甲缝。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 66, Initiative = 98 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Initiative = 4 }, GrantSkills = ["actives.wx_sword_duoming"], Flags = { FirstRoundHit = 5, DirectDmgBonus = 0.06 }, Summary = "武艺 +2，身法 +4；穿甲 +6%，首轮命中 +5；习得「夺命三仙剑」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, Initiative = 6 }, GrantSkills = ["actives.wx_sword_duoming"], Flags = { FirstRoundHit = 8, DirectDmgBonus = 0.10 }, Summary = "武艺 +4，身法 +6；穿甲 +10%，首轮命中 +8。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Initiative = 9, MeleeDefense = 2 }, GrantSkills = ["actives.wx_sword_duoming", "actives.wx_sword_kuangfeng"], Flags = { FirstRoundHit = 10, DirectDmgBonus = 0.14, CritHeadBonus = 8 }, Summary = "武艺 +5，身法 +9，招架 +2；穿甲 +14%，击头 +8%，首轮命中 +10；习得「落英疾风剑」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_qingcheng_songfeng <- {
	ID = "wx_manual_qingcheng_songfeng", Name = "松风摧心剑", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_qingcheng_songfeng.png",
	Description = "青城幽谷观阴狠快剑，如松风穿林无孔不入，刺伤见血且专杀残血之敌。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65, Initiative = 96 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Initiative = 4 }, GrantSkills = ["actives.wx_sword_cuixin"], Flags = { BleedOnHitPct = 25 }, Summary = "武艺 +2，身法 +4；伤血割裂流血 25%；习得「松风摧心刺」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, Initiative = 6 }, GrantSkills = ["actives.wx_sword_cuixin"], Flags = { BleedOnHitPct = 40, ExecuteLowHpDmg = 0.08 }, Summary = "武艺 +4，身法 +6；对半血残敌伤害 +8%，伤血割裂流血 40%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Initiative = 8, MeleeDefense = 2 }, GrantSkills = ["actives.wx_sword_cuixin", "actives.wx_sword_yinsha"], Flags = { BleedOnHitPct = 55, ExecuteLowHpDmg = 0.14, NightOwl = true }, Summary = "武艺 +5，身法 +8，招架 +2；对半血残敌伤害 +14%，伤血割裂流血 55%，夜战无视视野惩罚；习得「幽冥追魂剑」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_emei_huaying <- {
	ID = "wx_manual_emei_huaying", Name = "金顶分花拂柳剑", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_emei_huaying.png",
	Description = "峨眉金顶庵轻灵剑术，剑尖挑穴认脉，一旦对手露出破绽便封住其经脉。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65, Initiative = 96 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_acupoint_strike"], Flags = { ExposeOnHitPct = 25 }, Summary = "武艺 +2，招架 +1；普攻寻隙留破绽 25%；习得「清风点穴」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_acupoint_strike", "actives.wx_sword_kuangfeng"], Flags = { ExposeOnHitPct = 35, AcupointOnCritPct = 25 }, Summary = "武艺 +4，招架 +2、「清风点穴」；普攻寻隙留破绽 35%，乘隙/击头封穴 25%；习得「落英疾风剑」。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_acupoint_strike", "actives.wx_sword_kuangfeng"], Flags = { ExposeOnHitPct = 50, AcupointOnCritPct = 40 }, Summary = "武艺 +5，招架 +3；普攻寻隙留破绽 50%，乘隙/击头封穴 40%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_gusumu_canhe <- {
	ID = "wx_manual_gusumu_canhe", Name = "姑苏慕氏柳絮剑", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_gusumu_canhe.png",
	Description = "姑苏慕氏剑庄家传巧剑，随风顺势拆解来招，反击准头刁钻。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 66, MeleeDefense = 16 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_sword_canhe"], Flags = { CounterBonus = 8 }, Summary = "武艺 +2，招架 +1；反击命中 +8；习得「柳絮随风剑」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_sword_canhe", "actives.wx_sword_counter"], Flags = { CounterBonus = 12, ExposeOnHitPct = 25 }, Summary = "武艺 +4，招架 +2；普攻寻隙留破绽 25%，反击命中 +12；习得「回锋架势」。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_sword_canhe", "actives.wx_sword_counter"], Flags = { CounterBonus = 16, ExposeOnHitPct = 40, DirectDmgBonus = 0.10 }, Summary = "武艺 +5，招架 +3；穿甲 +10%，普攻寻隙留破绽 40%，反击命中 +16。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zhongnan_yunv <- {
	ID = "wx_manual_zhongnan_yunv", Name = "终南冷月快剑", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_zhongnan_yunv.png",
	Description = "终南活死人庐幽冷剑法，剑势清冷迅捷，对无甲或破甲目标杀伤尤为惊人。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 66, Initiative = 100 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Initiative = 5 }, GrantSkills = ["actives.wx_sword_yunv"], Flags = { DirectDmgBonus = 0.06 }, Summary = "武艺 +2，身法 +5；穿甲 +6%；习得「冷月双飞剑」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, Initiative = 8 }, GrantSkills = ["actives.wx_sword_yunv"], Flags = { DirectDmgBonus = 0.10, UnarmoredBonusDmg = 0.10 }, Summary = "武艺 +4，身法 +8；穿甲 +10%，对破甲/无甲实伤 +10%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Initiative = 10, MeleeDefense = 3 }, GrantSkills = ["actives.wx_sword_yunv", "actives.wx_sword_pierce"], Flags = { DirectDmgBonus = 0.14, UnarmoredBonusDmg = 0.18 }, Summary = "武艺 +5，身法 +10，招架 +3；穿甲 +14%，对破甲/无甲实伤 +18%；习得「穿云透甲刺」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_wuyi_bixue <- {
	ID = "wx_manual_wuyi_bixue", Name = "碧水听涛剑", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_wuyi_bixue.png",
	Description = "武夷碧水轩清雅剑术，挥剑拨打流矢如泼水不进，远近兼顾。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1, RangedDefense = 1 }, GrantSkills = ["actives.wx_sword_bixue"], Flags = {}, Summary = "武艺 +2，招架 +1，避暗 +1；习得「碧水惊涛剑」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2, RangedDefense = 2 }, GrantSkills = ["actives.wx_sword_bixue"], Flags = { DodgeRangedBonus = 4, WeaponQiDiscount = 0.12 }, Summary = "武艺 +4，招架 +2，避暗 +2；招式耗气 -12%，听风避矢 +4。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3, RangedDefense = 3 }, GrantSkills = ["actives.wx_sword_bixue", "actives.wx_sword_combo"], Flags = { DodgeRangedBonus = 6, WeaponQiDiscount = 0.18 }, Summary = "武艺 +5，招架 +3，避暗 +3；招式耗气 -18%，听风避矢 +6；习得「清风连环剑」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_taiji_zhenjian <- {
	ID = "wx_manual_taiji_zhenjian", Name = "太和真武无极剑", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_taiji_zhenjian.png",
	Description = "太和玄门剑道绝学，以慢打快、后发先至，身陷群敌合围亦能滴水不漏反刺要害！",
	BasePrice = 4630, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, MeleeDefense = 24 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_sword_taiji"], Flags = { CounterBonus = 12, UnderdogGuard = true }, Summary = "武艺 +3，招架 +2；反击命中 +12，免除被围攻近防惩罚；习得「两仪化劲剑」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 4 }, GrantSkills = ["actives.wx_sword_taiji", "actives.wx_sword_zhenwu"], Flags = { CounterBonus = 16, UnderdogGuard = true, OnHitDrainQi = 5 }, Summary = "武艺 +5，招架 +4；反击命中 +16，免除被围攻近防惩罚，命中震散敌内息 5 点；习得「真武七星剑」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_sword_taiji", "actives.wx_sword_zhenwu", "actives.wx_sword_counter"], Flags = { CounterBonus = 20, UnderdogGuard = true, OnHitDrainQi = 7, DirectDmgBonus = 0.14 }, Summary = "武艺 +7，招架 +5；穿甲 +14%，反击命中 +20，免除被围攻近防惩罚，命中震散敌内息 7 点；习得「回锋架势」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_dugu_pojian <- {
	ID = "wx_manual_dugu_pojian", Name = "紫霞破兵九式", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_dugu_pojian.png",
	Description = "西岳紫霞观剑宗不世绝学：只攻不守直指兵刃破绽，单挑孤战之时锋芒无人可撄。",
	BasePrice = 4600, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 82, Initiative = 108 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_sword_zixia"], Flags = { ExposeOnHitPct = 35, DirectDmgBonus = 0.08 }, Summary = "武艺 +3，招架 +2；穿甲 +8%，普攻寻隙留破绽 35%；习得「紫霞破气剑」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_sword_zixia", "actives.wx_sword_dugu"], Flags = { ExposeOnHitPct = 50, DirectDmgBonus = 0.12, LoneWolfBonus = 4 }, Summary = "武艺 +5，招架 +3；穿甲 +12%，普攻寻隙留破绽 50%，孤身两格无友军时攻防 +4；习得「破刃荡剑式」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_sword_zixia", "actives.wx_sword_dugu"], Flags = { ExposeOnHitPct = 65, DirectDmgBonus = 0.15, LoneWolfBonus = 6, HitChanceBonus = 8 }, Summary = "武艺 +7，招架 +5；穿甲 +15%，近战命中 +8，普攻寻隙留破绽 65%，孤身两格无友军时攻防 +6。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_emei_mie_jian <- {
	ID = "wx_manual_emei_mie_jian", Name = "峨眉金顶绝剑", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_emei_mie_jian.png",
	Description = "峨眉金顶庵护教杀伐绝剑，一改禅门慈悲，剑剑点穴断脉、斩尽残敌。",
	BasePrice = 4600, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, Initiative = 106 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_acupoint_strike"], Flags = { DirectDmgBonus = 0.08 }, Summary = "武艺 +3，招架 +2「点穴剑指」；穿甲 +8%；习得「清风点穴」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_acupoint_strike", "actives.wx_sword_miejian"], Flags = { DirectDmgBonus = 0.12, AcupointOnCritPct = 35 }, Summary = "武艺 +5，招架 +3；穿甲 +12%，乘隙/击头封穴 35%；习得「金顶绝命剑」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_acupoint_strike", "actives.wx_sword_miejian"], Flags = { DirectDmgBonus = 0.15, AcupointOnCritPct = 50, ExecuteLowHpDmg = 0.16 }, Summary = "武艺 +7，招架 +5；穿甲 +15%，对半血残敌伤害 +16%，乘隙/击头封穴 50%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_xuanbing_hanjian <- {
	ID = "wx_manual_xuanbing_hanjian", Name = "昆仑玄霜剑谱", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_xuanbing_hanjian.png",
	Description = "昆仑玄冰宫寒气逼人的上古剑谱，剑锋所过寒霜凝结，重创敌方内息并使其失衡。",
	BasePrice = 4660, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, Bravery = 55 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_sword_xuanbing"], Flags = { OnHitDrainQi = 4, InflictOffBalancePct = 30 }, Summary = "武艺 +3，招架 +2；招式致失衡 30%，命中震散敌内息 4 点；习得「昆仑玄霜剑」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 4 }, GrantSkills = ["actives.wx_sword_xuanbing", "actives.wx_sword_qinggang"], Flags = { OnHitDrainQi = 6, InflictOffBalancePct = 50, DirectDmgBonus = 0.10 }, Summary = "武艺 +5，招架 +4；穿甲 +10%，招式致失衡 50%，命中震散敌内息 6 点；习得「青釭透甲剑」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_sword_xuanbing", "actives.wx_sword_qinggang"], Flags = { OnHitDrainQi = 8, InflictOffBalancePct = 70, DirectDmgBonus = 0.15 }, Summary = "武艺 +7，招架 +5；穿甲 +15%，招式致失衡 70%，命中震散敌内息 8 点。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_wanjian_guizong <- {
	ID = "wx_manual_wanjian_guizong", Name = "万剑归宗总诀", Category = "waigong", Quality = "unique",
	Element = null, WeaponTypes = ["Sword"], Icon = "ui/perks/wx_manual_wanjian_guizong.png",
	Description = "剑冢石壁拓印的无上剑道孤本：融穿甲奇刺、回锋反击与天外剑气于一炉，斩敌顺势返还步法劲力！",
	BasePrice = 11800, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 90, MeleeDefense = 28 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_sword_qinggang", "actives.wx_sword_dugu"], Flags = { DirectDmgBonus = 0.10, CounterBonus = 12 }, Summary = "武艺 +4，招架 +2「回锋架势」；穿甲 +10%，反击命中 +12、「破刃荡剑式」；习得「青釭透甲剑」、「破刃荡剑式」。" },
		{ ExpNeeded = 320, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_sword_qinggang", "actives.wx_sword_dugu"], Flags = { DirectDmgBonus = 0.15, CounterBonus = 18, ExposeOnHitPct = 40 }, Summary = "武艺 +7，招架 +4；穿甲 +15%，普攻寻隙留破绽 40%，反击命中 +18。" },
		{ ExpNeeded = 800, Stats = { MeleeSkill = 10, MeleeDefense = 6 }, GrantSkills = ["actives.wx_sword_qinggang", "actives.wx_sword_dugu", "actives.wx_sword_wanjian"], Flags = { DirectDmgBonus = 0.20, CounterBonus = 22, ExposeOnHitPct = 55, OnKillAPRefund = 2 }, Summary = "武艺 +10，招架 +6；穿甲 +20%，普攻寻隙留破绽 55%，反击命中 +22，每回合首杀返 +2 AP；习得「万剑归宗诀」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_yanyun_zhandao <- {
	ID = "wx_manual_yanyun_zhandao", Name = "边军斩马刀式", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_yanyun_zhandao.png",
	Description = "九边步营劈砍马腿与皮甲的制式刀法，重劈见血、省力耐战。",
	BasePrice = 310, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.08 }, Summary = "武艺 +1；招式耗气 -8%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.14, BleedOnHitPct = 20 }, Summary = "武艺 +2；招式耗气 -14%，伤血割裂流血 20%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 1 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.20, BleedOnHitPct = 30 }, Summary = "武艺 +3，招架 +1；招式耗气 -20%，伤血割裂流血 30%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_lingnan_duandao <- {
	ID = "wx_manual_lingnan_duandao", Name = "藤牌滚堂刀", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_lingnan_duandao.png",
	Description = "岭南藤牌卒贴地翻滚专砍小腿的凶悍短刀术，配合盾牌守御严密。",
	BasePrice = 370, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1, MeleeDefense = 1 }, GrantSkills = [], Flags = {}, Summary = "武艺 +1，招架 +1。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = [], Flags = { ShieldDefBonus = 2 }, Summary = "武艺 +2，招架 +1；持盾双防 +2。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_saber_lingnan"], Flags = { ShieldDefBonus = 3, BleedOnHitPct = 25 }, Summary = "武艺 +3，招架 +2；伤血割裂流血 25%，持盾双防 +3；习得「南岭滚堂刀」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_hanhai_wandao_ru <- {
	ID = "wx_manual_hanhai_wandao_ru", Name = "沙匪掠风弯刀", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_hanhai_wandao_ru.png",
	Description = "西域沙匪骑驼掠阵的快弯刀，专欺衣甲单薄之敌。",
	BasePrice = 310, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1, Initiative = 2 }, GrantSkills = [], Flags = { UnarmoredBonusDmg = 0.06 }, Summary = "武艺 +1，身法 +2；对破甲/无甲实伤 +6%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, Initiative = 4 }, GrantSkills = [], Flags = { UnarmoredBonusDmg = 0.10 }, Summary = "武艺 +2，身法 +4；对破甲/无甲实伤 +10%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, Initiative = 6 }, GrantSkills = ["actives.wx_saber_kuangfeng"], Flags = { UnarmoredBonusDmg = 0.15, ExecuteLowHpDmg = 0.08 }, Summary = "武艺 +3，身法 +6；对破甲/无甲实伤 +15%，对半血残敌伤害 +8%；习得「狂风快刀斩」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_paoge_kuaidao <- {
	ID = "wx_manual_paoge_kuaidao", Name = "川江分水快刀", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_paoge_kuaidao.png",
	Description = "巴蜀码头袍哥争地盘使的单刀套路，起手狠辣抢先机。",
	BasePrice = 400, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { FirstRoundHit = 4 }, Summary = "武艺 +1；首轮命中 +4。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, Bravery = 2 }, GrantSkills = [], Flags = { FirstRoundHit = 6, ArmorDmgBonus = 0.08 }, Summary = "武艺 +2，定力 +2；破甲 +8%，首轮命中 +6。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, Bravery = 4 }, GrantSkills = [], Flags = { FirstRoundHit = 8, ArmorDmgBonus = 0.14 }, Summary = "武艺 +3，定力 +4；破甲 +14%，首轮命中 +8。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_huaiyang_jindao <- {
	ID = "wx_manual_huaiyang_jindao", Name = "淮阳八极金刀", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_huaiyang_jindao.png",
	Description = "淮阳金刀门镇宅刀谱，刀背厚重镶金环，晃环夺魄、重劈破甲兼备招架。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_saber_baji"], Flags = { ArmorDmgBonus = 0.10 }, Summary = "武艺 +2，招架 +1；破甲 +10%；习得「淮阳八极斩」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_saber_baji"], Flags = { ArmorDmgBonus = 0.16, DazeOnHeavyHitPct = 25 }, Summary = "武艺 +4，招架 +2；破甲 +16%，重击震荡失衡 25%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_saber_baji", "actives.wx_poise_charge"], Flags = { ArmorDmgBonus = 0.22, DazeOnHeavyHitPct = 40 }, Summary = "武艺 +5，招架 +3；破甲 +22%，重击震荡失衡 40%；习得「沉刀蓄势」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_hanhai_xinyue <- {
	ID = "wx_manual_hanhai_xinyue", Name = "瀚海新月弯刀", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_hanhai_xinyue.png",
	Description = "瀚海弯刀盟成名绝技，刀光如大漠冷月掠沙，对破甲与半血残敌具有恐怖收割力！",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 66, Initiative = 96 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Initiative = 4 }, GrantSkills = ["actives.wx_saber_xinyue"], Flags = { BleedOnHitPct = 30, ExecuteLowHpDmg = 0.08 }, Summary = "武艺 +2，身法 +4；对半血残敌伤害 +8%，伤血割裂流血 30%；习得「瀚海弯月斩」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, Initiative = 7 }, GrantSkills = ["actives.wx_saber_xinyue"], Flags = { BleedOnHitPct = 45, ExecuteLowHpDmg = 0.14, UnarmoredBonusDmg = 0.10 }, Summary = "武艺 +4，身法 +7；对破甲/无甲实伤 +10%，对半血残敌伤害 +14%，伤血割裂流血 45%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Initiative = 10 }, GrantSkills = ["actives.wx_saber_xinyue", "actives.wx_saber_kuangfeng"], Flags = { BleedOnHitPct = 60, ExecuteLowHpDmg = 0.18, UnarmoredBonusDmg = 0.16 }, Summary = "武艺 +5，身法 +10；对破甲/无甲实伤 +16%，对半血残敌伤害 +18%，伤血割裂流血 60%；习得「狂风快刀斩」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_lingnan_zhandao <- {
	ID = "wx_manual_lingnan_zhandao", Name = "南岭破阵腰刀谱", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_lingnan_zhandao.png",
	Description = "岭南藤牌悍卒营正印战刀谱，左手藤牌护身、右手腰刀割裂敌阵。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64, MeleeDefense = 14 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_saber_lingnan"], Flags = { ShieldDefBonus = 2, WeaponQiDiscount = 0.10 }, Summary = "武艺 +2，招架 +1；招式耗气 -10%，持盾双防 +2；习得「南岭滚堂刀」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_saber_lingnan"], Flags = { ShieldDefBonus = 3, WeaponQiDiscount = 0.15, BleedOnHitPct = 35 }, Summary = "武艺 +4，招架 +2；招式耗气 -15%，伤血割裂流血 35%，持盾双防 +3。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_saber_lingnan", "actives.wx_shield_bash_qi"], Flags = { ShieldDefBonus = 4, WeaponQiDiscount = 0.20, BleedOnHitPct = 50 }, Summary = "武艺 +5，招架 +3；招式耗气 -20%，伤血割裂流血 50%，持盾双防 +4；习得「铁壁震山靠」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shaolin_jiedao <- {
	ID = "wx_manual_shaolin_jiedao", Name = "少室燃木戒刀", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_shaolin_jiedao.png",
	Description = "少室禅院护院僧兵所习阳刚刀法，刀劲凝而不散，不伤性命却能震碎重甲盾牌！",
	BasePrice = 2260, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65, Stamina = 96 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_saber_baji"], Flags = { UnbrokenArmorBonus = 0.12 }, Summary = "武艺 +2，招架 +1；对厚甲破甲 +12%；习得「淮阳八极斩」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_saber_baji"], Flags = { UnbrokenArmorBonus = 0.18, ShieldBreakBonus = 8 }, Summary = "武艺 +4，招架 +2；对厚甲破甲 +18%，碎盾劲 +8。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_saber_baji", "actives.wx_saber_ranmu"], Flags = { UnbrokenArmorBonus = 0.25, ShieldBreakBonus = 14, OnHitDrainQi = 4 }, Summary = "武艺 +5，招架 +3；对厚甲破甲 +25%，碎盾劲 +14，命中震散敌内息 4 点；习得「燃木烈阳劈」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_taihe_xuanxu <- {
	ID = "wx_manual_taihe_xuanxu", Name = "玄虚八卦刀", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_taihe_xuanxu.png",
	Description = "太和玄门俗家弟子必修八卦走转刀法，步踏九宫、群战之中刀光泼水不进。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_saber_bagua"], Flags = {}, Summary = "武艺 +2，招架 +1；习得「玄虚八卦刀」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_saber_bagua"], Flags = { UnderdogGuard = true, ExposeOnHitPct = 20 }, Summary = "武艺 +4，招架 +2；普攻寻隙留破绽 20%，免除被围攻近防惩罚。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_saber_bagua", "actives.wx_saber_fanzhen"], Flags = { UnderdogGuard = true, ExposeOnHitPct = 35, WeaponQiDiscount = 0.15 }, Summary = "武艺 +5，招架 +3；招式耗气 -15%，普攻寻隙留破绽 35%，免除被围攻近防惩罚；习得「两仪合璧斩」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_heishui_zhandao <- {
	ID = "wx_manual_heishui_zhandao", Name = "黑水屠熊狂刀", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_heishui_zhandao.png",
	Description = "关外黑水战帮搏杀荒原棕熊的悍命大刀，刀刀奔头颅要害而去，斩敌饮血愈战愈勇。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65, Hitpoints = 70 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2 }, GrantSkills = ["actives.wx_saber_tuxiong"], Flags = { CritHeadBonus = 6, OnKillHealHP = 4 }, Summary = "武艺 +2；击头 +6%，击杀生人回 4 气血；习得「黑水屠熊劈」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4 }, GrantSkills = ["actives.wx_saber_tuxiong"], Flags = { CritHeadBonus = 10, OnKillHealHP = 6, ArmorDmgBonus = 0.15 }, Summary = "武艺 +4；破甲 +15%，击头 +10%，击杀生人回 6 气血。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Bravery = 5 }, GrantSkills = ["actives.wx_saber_tuxiong", "actives.wx_saber_sweep"], Flags = { CritHeadBonus = 14, OnKillHealHP = 9, ArmorDmgBonus = 0.22 }, Summary = "武艺 +5，定力 +5；破甲 +22%，击头 +14%，击杀生人回 9 气血；习得「八方狂澜斩」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_dongting_langdao <- {
	ID = "wx_manual_dongting_langdao", Name = "洞庭翻江斩浪刀", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_dongting_langdao.png",
	Description = "洞庭连环水寨大当家跳帮夺船的看家横扫刀法，一刀荡开数敌令其站立不稳。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2 }, GrantSkills = ["actives.wx_saber_zhanlang"], Flags = { ArmorDmgBonus = 0.10 }, Summary = "武艺 +2；破甲 +10%；习得「洞庭翻江斩」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 1 }, GrantSkills = ["actives.wx_saber_zhanlang"], Flags = { ArmorDmgBonus = 0.16, SurroundHitBonus = 3 }, Summary = "武艺 +4，招架 +1；破甲 +16%，合围每名友军 +3 命中。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 2 }, GrantSkills = ["actives.wx_saber_zhanlang", "actives.wx_saber_sweep"], Flags = { ArmorDmgBonus = 0.22, SurroundHitBonus = 5, DazeOnHeavyHitPct = 35 }, Summary = "武艺 +5，招架 +2；破甲 +22%，重击震荡失衡 35%，合围每名友军 +5 命中；习得「八方狂澜斩」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_huaiyang_kuanglan <- {
	ID = "wx_manual_huaiyang_kuanglan", Name = "八荒六合金刀录", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_huaiyang_kuanglan.png",
	Description = "淮阳金刀门传家宝刀谱：兼具八方横扫与沉刀蓄势，重装前排挥舞起来如铜墙推进！",
	BasePrice = 4600, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, Stamina = 102 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_saber_baji"], Flags = { ArmorDmgBonus = 0.14 }, Summary = "武艺 +3，招架 +2；破甲 +14%；习得「淮阳八极斩」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_saber_baji", "actives.wx_saber_kuanglan"], Flags = { ArmorDmgBonus = 0.20, DirectDmgBonus = 0.08 }, Summary = "武艺 +5，招架 +3；破甲 +20%，穿甲 +8%；习得「八荒六合斩」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_saber_baji", "actives.wx_saber_kuanglan"], Flags = { ArmorDmgBonus = 0.25, DirectDmgBonus = 0.14, UnderdogGuard = true }, Summary = "武艺 +7，招架 +5；破甲 +25%，穿甲 +14%，免除被围攻近防惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_hanhai_shishen <- {
	ID = "wx_manual_hanhai_shishen", Name = "天狼弯月噬血刀", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_hanhai_shishen.png",
	Description = "大漠马贼王令商队闻风丧胆的弯刀绝学：见血封喉、残血必诛，连斩收割返还行动点！",
	BasePrice = 4600, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 80, Initiative = 104 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, Initiative = 4 }, GrantSkills = ["actives.wx_saber_xinyue"], Flags = { BleedOnHitPct = 45, ExecuteLowHpDmg = 0.10 }, Summary = "武艺 +3，身法 +4；对半血残敌伤害 +10%，伤血割裂流血 45%；习得「瀚海弯月斩」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, Initiative = 7, MeleeDefense = 2 }, GrantSkills = ["actives.wx_saber_xinyue", "actives.wx_saber_shishen"], Flags = { BleedOnHitPct = 60, ExecuteLowHpDmg = 0.15, OnKillAPRefund = 2 }, Summary = "武艺 +5，身法 +7，招架 +2；对半血残敌伤害 +15%，伤血割裂流血 60%，每回合首杀返 +2 AP；习得「天狼噬魂斩」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, Initiative = 10, MeleeDefense = 4 }, GrantSkills = ["actives.wx_saber_xinyue", "actives.wx_saber_shishen"], Flags = { BleedOnHitPct = 65, ExecuteLowHpDmg = 0.20, OnKillAPRefund = 3 }, Summary = "武艺 +7，身法 +10，招架 +4；对半血残敌伤害 +20%，伤血割裂流血 65%，每回合首杀返 +3 AP。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_heifeng_xuedao <- {
	ID = "wx_manual_heifeng_xuedao", Name = "血海修罗刀经", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_heifeng_xuedao.png",
	Description = "黑风血煞宗邪道刀经，刀路诡辣专走偏锋，斩杀敌军即可吸摄精血自愈创伤。",
	BasePrice = 4630, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, Bravery = 55 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3 }, GrantSkills = ["actives.wx_saber_duanyue"], Flags = { OnKillHealHP = 6, DirectDmgBonus = 0.08 }, Summary = "武艺 +3；习得「断岳狂斩」；穿甲 +8%，击杀生人回 6 气血。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 2 }, GrantSkills = ["actives.wx_saber_duanyue"], Flags = { OnKillHealHP = 8, DirectDmgBonus = 0.12, BleedOnHitPct = 45 }, Summary = "武艺 +5，招架 +2；穿甲 +12%，伤血割裂流血 45%，击杀生人回 8 气血。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_saber_duanyue", "actives.wx_saber_xuehai"], Flags = { OnKillHealHP = 10, DirectDmgBonus = 0.15, BleedOnHitPct = 65, OnKillQiRegen = 10 }, Summary = "武艺 +7，招架 +4；大成习得「修罗饮血斩」；穿甲 +15%，伤血割裂流血 65%，击杀回 10 内息，击杀生人回 10 气血。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_yanmen_podao <- {
	ID = "wx_manual_yanmen_podao", Name = "雁门破虏斩马录", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_yanmen_podao.png",
	Description = "边镇名将亲撰的重装双手斩马刀秘本，专破关外重骑铁甲与木盾。",
	BasePrice = 4600, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, Stamina = 105 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_saber_podao"], Flags = { UnbrokenArmorBonus = 0.14, ShieldBreakBonus = 10 }, Summary = "武艺 +3，招架 +2；对厚甲破甲 +14%，碎盾劲 +10；习得「雁门斩马劈」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_saber_podao", "actives.wx_saber_modao"], Flags = { UnbrokenArmorBonus = 0.20, ShieldBreakBonus = 14, ArmorDmgBonus = 0.18 }, Summary = "武艺 +5，招架 +3；破甲 +18%，对厚甲破甲 +20%，碎盾劲 +14；习得「陌刀碎骑斩」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_saber_podao", "actives.wx_saber_modao"], Flags = { UnbrokenArmorBonus = 0.25, ShieldBreakBonus = 18, ArmorDmgBonus = 0.25 }, Summary = "武艺 +7，招架 +4；破甲 +25%，对厚甲破甲 +25%，碎盾劲 +18。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_xiuluo_shigu <- {
	ID = "wx_manual_xiuluo_shigu", Name = "阿鼻霸刀绝录", Category = "waigong", Quality = "unique",
	Element = null, WeaponTypes = ["Cleaver", "Saber"], Icon = "ui/perks/wx_manual_xiuluo_shigu.png",
	Description = "前朝乱世魔帅遗留的刀道极境孤本：集八方狂扫、断岳重劈、斩杀饮血与连斩返步于一身！",
	BasePrice = 11860, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 90, Stamina = 110 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_saber_duanyue"], Flags = { ArmorDmgBonus = 0.15, DirectDmgBonus = 0.08 }, Summary = "武艺 +4，招架 +2「八方狂澜斩」；破甲 +15%，穿甲 +8%；习得「断岳狂斩」。" },
		{ ExpNeeded = 320, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_saber_duanyue", "actives.wx_saber_xuehai"], Flags = { ArmorDmgBonus = 0.20, DirectDmgBonus = 0.14, ExecuteLowHpDmg = 0.15 }, Summary = "武艺 +7，招架 +4；破甲 +20%，穿甲 +14%，对半血残敌伤害 +15%；习得「修罗饮血斩」。" },
		{ ExpNeeded = 800, Stats = { MeleeSkill = 10, MeleeDefense = 6 }, GrantSkills = ["actives.wx_saber_duanyue", "actives.wx_saber_xuehai", "actives.wx_saber_abi"], Flags = { ArmorDmgBonus = 0.25, DirectDmgBonus = 0.20, ExecuteLowHpDmg = 0.20, OnKillAPRefund = 3 }, Summary = "武艺 +10，招架 +6；破甲 +25%，穿甲 +20%，对半血残敌伤害 +20%，每回合首杀返 +3 AP；习得「阿鼻修罗斩」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_taiyuan_huoyandao <- {
	ID = "wx_manual_taiyuan_huoyandao", Name = "太原火焰刀", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Cleaver", "Saber", "Fist"], Icon = "ui/perks/wx_manual_taiyuan_huoyandao.png",
	Description = "晋阳太原一脉刚猛无匹的烈阳刀谱，亦可以掌缘代刀催发虚空炎罡：招式大开大合气吞山河，隔步劈出炽烈火焰刀气焚甲慑魂！",
	BasePrice = 4680, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, Stamina = 102 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { MeleeSkill = 3, MeleeDefense = 1 }, GrantSkills = ["actives.wx_saber_huoyandao"], Flags = { ArmorDmgBonus = 0.12, DirectDmgBonus = 0.06 }, Summary = "武艺 +3，招架 +1；习得绝技「太原火焰斩」（1~2格隔空烈焰刀罡）；破甲 +12%，穿甲 +6%。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_saber_huoyandao", "actives.wx_poise_charge"], Flags = { ArmorDmgBonus = 0.18, DirectDmgBonus = 0.10, UnbrokenArmorBonus = 0.15 }, Summary = "武艺 +5，招架 +3；习得「沉刀蓄势」；破甲 +18%，穿甲 +10%，对厚甲破甲 +15%。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_saber_huoyandao", "actives.wx_poise_charge"], Flags = { ArmorDmgBonus = 0.24, DirectDmgBonus = 0.15, UnbrokenArmorBonus = 0.22, DazeOnHeavyHitPct = 45 }, Summary = "武艺 +7，招架 +4；破甲 +24%，穿甲 +15%，对厚甲破甲 +22%，重击震荡失衡 45%。" }
	]
};
