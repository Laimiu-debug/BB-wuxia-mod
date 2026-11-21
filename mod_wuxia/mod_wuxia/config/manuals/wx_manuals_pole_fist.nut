// Expanded Waigong Library II: Spear, Polearm, Staff & Paired Fist Lineages
// Auto-audited against AGENTS.md stat & non-stacking redlines.

::Wuxia.Config.Manuals.wx_manual_luoyang_kuaiqiang <- {
	ID = "wx_manual_luoyang_kuaiqiang", Name = "趟子追风枪", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Spear", "Polearm"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "洛阳长风镖局趟子手护住镖车两侧的快刺白蜡杆枪，先手出枪准头稳。",
	BasePrice = 280, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1, Initiative = 3 }, GrantSkills = [], Flags = {}, Summary = "武艺 +1，身法 +3。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, Initiative = 5 }, GrantSkills = [], Flags = { FirstRoundHit = 4 }, Summary = "武艺 +2，身法 +5；首轮命中 +4。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, Initiative = 8, MeleeDefense = 1 }, GrantSkills = [], Flags = { FirstRoundHit = 7, ZoCBonusHit = 8 }, Summary = "武艺 +3，身法 +8，招架 +1；首轮命中 +7，拦截命中 +8。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_junying_changmao <- {
	ID = "wx_manual_junying_changmao", Name = "步营拒马枪阵", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Spear", "Polearm"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "官军步卒并肩列阵攒刺突骑的枪矛操典，结阵守御且精于拦截。",
	BasePrice = 370, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1, MeleeDefense = 1 }, GrantSkills = [], Flags = { FormationBondDef = 1 }, Summary = "武艺 +1，招架 +1；邻接同袍结阵守御定力 +1。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = [], Flags = { FormationBondDef = 2, ZoCBonusHit = 6 }, Summary = "武艺 +2，招架 +1；拦截命中 +6，邻接同袍结阵守御定力 +2。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = [], Flags = { FormationBondDef = 3, ZoCBonusHit = 10 }, Summary = "武艺 +3，招架 +2；拦截命中 +10，邻接同袍结阵守御定力 +3。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_changbai_liecha <- {
	ID = "wx_manual_changbai_liecha", Name = "山林猎虎叉法", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Spear", "Polearm"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "长白山猎户持钢叉长矛抵住猛虎扑咬的狠劲枪叉法，重刺流血。",
	BasePrice = 400, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { BleedOnHitPct = 15 }, Summary = "武艺 +1；伤血割裂流血 15%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, Hitpoints = 4 }, GrantSkills = [], Flags = { BleedOnHitPct = 25, WeaponQiDiscount = 0.10 }, Summary = "武艺 +2，气血 +4；招式耗气 -10%，伤血割裂流血 25%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, Hitpoints = 8 }, GrantSkills = [], Flags = { BleedOnHitPct = 35, WeaponQiDiscount = 0.16 }, Summary = "武艺 +3，气血 +8；招式耗气 -16%，伤血割裂流血 35%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_pojia_changbing <- {
	ID = "wx_manual_pojia_changbing", Name = "钩镰破甲戟式", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Polearm", "Spear"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "后排长戟兵钩拉劈砸前线铁甲的军中套路，擅破满甲目标。",
	BasePrice = 340, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { UnbrokenArmorBonus = 0.08 }, Summary = "武艺 +1；对厚甲破甲 +8%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2 }, GrantSkills = [], Flags = { UnbrokenArmorBonus = 0.14 }, Summary = "武艺 +2；对厚甲破甲 +14%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3 }, GrantSkills = [], Flags = { UnbrokenArmorBonus = 0.20, ArmorDmgBonus = 0.12 }, Summary = "武艺 +3；破甲 +12%，对厚甲破甲 +20%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_hebei_cuijia <- {
	ID = "wx_manual_hebei_cuijia", Name = "崔家梨花盘龙枪", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Spear", "Polearm"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "河北神枪崔家名满中原的家传枪法：枪花如瑞雪纷飞，一招百鸟朝凤震退贴身强敌！",
	BasePrice = 2260, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 66 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_spear_thrust2"], Flags = { ZoCBonusHit = 8 }, Summary = "武艺 +2，招架 +1；习得「百鸟朝凤刺」；拦截命中 +8。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_spear_thrust2"], Flags = { ZoCBonusHit = 12, ExposeOnHitPct = 25 }, Summary = "武艺 +4，招架 +2；普攻寻隙留破绽 25%，拦截命中 +12。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_spear_thrust2", "actives.wx_spear_guard"], Flags = { ZoCBonusHit = 16, ExposeOnHitPct = 40, DirectDmgBonus = 0.10 }, Summary = "武艺 +5，招架 +3；习得「威远守线刺」；穿甲 +10%，普攻寻隙留破绽 40%，拦截命中 +16。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_luoyang_panlong <- {
	ID = "wx_manual_luoyang_panlong", Name = "长风八步追魂枪", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Spear", "Polearm"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "洛阳长风镖局镖头压阵快枪，来去如风，既可两格穿刺又能横扫护住镖旗。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64, Initiative = 95 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Initiative = 4 }, GrantSkills = ["actives.wx_spear_thrust2"], Flags = { WeaponQiDiscount = 0.10 }, Summary = "武艺 +2，身法 +4；习得「百鸟朝凤刺」；招式耗气 -10%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, Initiative = 6, MeleeDefense = 1 }, GrantSkills = ["actives.wx_spear_thrust2"], Flags = { WeaponQiDiscount = 0.15, FirstRoundHit = 6 }, Summary = "武艺 +4，身法 +6，招架 +1；招式耗气 -15%，首轮命中 +6。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Initiative = 9, MeleeDefense = 3 }, GrantSkills = ["actives.wx_spear_thrust2", "actives.wx_pole_sweep"], Flags = { WeaponQiDiscount = 0.20, FirstRoundHit = 10 }, Summary = "武艺 +5，身法 +9，招架 +3；习得「横扫千军」；招式耗气 -20%，首轮命中 +10。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_yanmen_fangtian <- {
	ID = "wx_manual_yanmen_fangtian", Name = "雁门方天断戟谱", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Polearm", "Spear"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "雁门戍边义勇将领大戟战法，长杆横扫千军破甲碎盾，威猛绝伦。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 66, Stamina = 98 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2 }, GrantSkills = ["actives.wx_pole_sweep"], Flags = { ArmorDmgBonus = 0.12, ShieldBreakBonus = 6 }, Summary = "武艺 +2；习得「横扫千军」；破甲 +12%，碎盾劲 +6。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 1 }, GrantSkills = ["actives.wx_pole_sweep"], Flags = { ArmorDmgBonus = 0.18, ShieldBreakBonus = 10 }, Summary = "武艺 +4，招架 +1；破甲 +18%，碎盾劲 +10。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 2 }, GrantSkills = ["actives.wx_pole_sweep", "actives.wx_pole_fangtian"], Flags = { ArmorDmgBonus = 0.25, ShieldBreakBonus = 15, DazeOnHeavyHitPct = 35 }, Summary = "武艺 +5，招架 +2；破甲 +25%，重击震荡失衡 35%，碎盾劲 +15。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_baima_yinqiang <- {
	ID = "wx_manual_baima_yinqiang", Name = "白马银枪破阵谱", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Spear", "Polearm"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "白马义从营精锐突击枪术，先发抢刺直取敌阵头目面门。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65, Bravery = 50 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Initiative = 4 }, GrantSkills = ["actives.wx_spear_thrust2"], Flags = { FirstRoundInit = 8, CritHeadBonus = 5 }, Summary = "武艺 +2，身法 +4；习得「百鸟朝凤刺」；击头 +5%，首轮身法 +8。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, Initiative = 7 }, GrantSkills = ["actives.wx_spear_thrust2"], Flags = { FirstRoundInit = 12, CritHeadBonus = 8, DirectDmgBonus = 0.08 }, Summary = "武艺 +4，身法 +7；穿甲 +8%，击头 +8%，首轮身法 +12。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Initiative = 10, MeleeDefense = 2 }, GrantSkills = ["actives.wx_spear_thrust2", "actives.wx_pole_goulian"], Flags = { FirstRoundInit = 16, CritHeadBonus = 12, DirectDmgBonus = 0.12 }, Summary = "武艺 +5，身法 +10，招架 +2；穿甲 +12%，击头 +12%，首轮身法 +16。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_hengshan_shouguan <- {
	ID = "wx_manual_hengshan_shouguan", Name = "北岳守隘铁矛录", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Spear", "Polearm"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "北岳守塞堂依托山隘以少敌多的死守枪法，免除合围惩罚且拦截百发百中。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64, MeleeDefense = 18 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_spear_guard"], Flags = { ZoCBonusHit = 10 }, Summary = "武艺 +2，招架 +1；习得「威远守线刺」；拦截命中 +10。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_spear_guard"], Flags = { ZoCBonusHit = 14, UnderdogGuard = true }, Summary = "武艺 +3，招架 +2；拦截命中 +14，免除被围攻近防惩罚。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_spear_guard", "actives.wx_pole_sweep"], Flags = { ZoCBonusHit = 18, UnderdogGuard = true, FormationBondDef = 3 }, Summary = "武艺 +5，招架 +3；习得「横扫千军」；拦截命中 +18，免除被围攻近防惩罚，邻接同袍结阵守御定力 +3。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_dongting_fenjiang_cha <- {
	ID = "wx_manual_dongting_fenjiang_cha", Name = "分江夜叉戟", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Polearm", "Spear"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "洞庭水寇头领所持倒刺三叉戟恶毒招数，一刺一拉撕开巨创流血不止。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2 }, GrantSkills = ["actives.wx_spear_thrust2"], Flags = { BleedOnHitPct = 30 }, Summary = "武艺 +2；习得「百鸟朝凤刺」；伤血割裂流血 30%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4 }, GrantSkills = ["actives.wx_spear_thrust2"], Flags = { BleedOnHitPct = 45, ExecuteLowHpDmg = 0.10 }, Summary = "武艺 +4；对半血残敌伤害 +10%，伤血割裂流血 45%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 2 }, GrantSkills = ["actives.wx_spear_thrust2", "actives.wx_pole_sweep"], Flags = { BleedOnHitPct = 60, ExecuteLowHpDmg = 0.15 }, Summary = "武艺 +5，招架 +2；习得「横扫千军」；对半血残敌伤害 +15%，伤血割裂流血 60%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_cuijia_liuhua <- {
	ID = "wx_manual_cuijia_liuhua", Name = "六合神枪绝谱", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Spear", "Polearm"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "河北神枪崔家传嫡不传庶的枪道绝学：集百鸟朝凤击退、守线失衡与透甲绝杀于一杆大枪！",
	BasePrice = 4570, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 80, MeleeDefense = 22 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_spear_thrust2", "actives.wx_spear_guard"], Flags = { DirectDmgBonus = 0.08, ZoCBonusHit = 12 }, Summary = "武艺 +3，招架 +2；习得「百鸟朝凤刺」「威远守线刺」；穿甲 +8%，拦截命中 +12。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 4 }, GrantSkills = ["actives.wx_spear_thrust2", "actives.wx_spear_guard"], Flags = { DirectDmgBonus = 0.12, ZoCBonusHit = 16, InflictOffBalancePct = 55 }, Summary = "武艺 +5，招架 +4；穿甲 +12%，招式致失衡 55%，拦截命中 +16。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_spear_thrust2", "actives.wx_spear_guard", "actives.wx_spear_liuhua"], Flags = { DirectDmgBonus = 0.15, ZoCBonusHit = 20, InflictOffBalancePct = 75, HitChanceBonus = 6 }, Summary = "武艺 +7，招架 +5；大成习得「梨花暴雨枪」；穿甲 +15%，近战命中 +6，招式致失衡 75%，拦截命中 +20。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_weiyuan_zhenbiao <- {
	ID = "wx_manual_weiyuan_zhenbiao", Name = "威远定鼎神枪", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Spear", "Polearm"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "威远总镖局老总镖头威震南北九省的看家绝艺，一人横枪立马便可稳住整条前排阵线。",
	BasePrice = 4540, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, MeleeDefense = 24 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_spear_guard", "actives.wx_pole_sweep"], Flags = { UnderdogGuard = true }, Summary = "武艺 +3，招架 +2；习得「威远守线刺」「横扫千军」；免除被围攻近防惩罚。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 4 }, GrantSkills = ["actives.wx_spear_guard", "actives.wx_pole_sweep"], Flags = { UnderdogGuard = true, FormationBondDef = 3, ArmorDmgBonus = 0.15 }, Summary = "武艺 +5，招架 +4；破甲 +15%，免除被围攻近防惩罚，邻接同袍结阵守御定力 +3。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_spear_guard", "actives.wx_pole_sweep"], Flags = { UnderdogGuard = true, FormationBondDef = 5, ArmorDmgBonus = 0.22, InflictOffBalancePct = 70 }, Summary = "武艺 +7，招架 +5；破甲 +22%，招式致失衡 70%，免除被围攻近防惩罚，邻接同袍结阵守御定力 +5。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_pojun_shenji <- {
	ID = "wx_manual_pojun_shenji", Name = "破军龙骧大戟录", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Polearm", "Spear"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "边军帅帐秘传重戟绝学，专克重甲武士与盾阵，斩杀强敌瞬间提振气力返步追击。",
	BasePrice = 4540, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 80, Stamina = 105 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3 }, GrantSkills = ["actives.wx_pole_sweep"], Flags = { ArmorDmgBonus = 0.15, UnbrokenArmorBonus = 0.12 }, Summary = "武艺 +3；习得「横扫千军」；破甲 +15%，对厚甲破甲 +12%。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 2 }, GrantSkills = ["actives.wx_pole_sweep", "actives.wx_spear_thrust2"], Flags = { ArmorDmgBonus = 0.20, UnbrokenArmorBonus = 0.18, OnKillAPRefund = 2 }, Summary = "武艺 +5，招架 +2；习得「百鸟朝凤刺」；破甲 +20%，对厚甲破甲 +18%，每回合首杀返 +2 AP。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_pole_sweep", "actives.wx_spear_thrust2"], Flags = { ArmorDmgBonus = 0.25, UnbrokenArmorBonus = 0.25, OnKillAPRefund = 3 }, Summary = "武艺 +7，招架 +4；破甲 +25%，对厚甲破甲 +25%，每回合首杀返 +3 AP。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_changbai_xuelong <- {
	ID = "wx_manual_changbai_xuelong", Name = "雪龙穿云枪", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Spear", "Polearm"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "关外隐世枪豪观冰瀑飞流所创奇枪，枪出如白龙穿云，刺穴见血令巨兽悍匪寸步难行。",
	BasePrice = 4540, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, Initiative = 104 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, Initiative = 5 }, GrantSkills = ["actives.wx_spear_thrust2"], Flags = { DirectDmgBonus = 0.08, BleedOnHitPct = 35 }, Summary = "武艺 +3，身法 +5；习得「百鸟朝凤刺」；穿甲 +8%，伤血割裂流血 35%。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, Initiative = 8, MeleeDefense = 2 }, GrantSkills = ["actives.wx_spear_thrust2"], Flags = { DirectDmgBonus = 0.12, BleedOnHitPct = 50, AcupointOnCritPct = 30 }, Summary = "武艺 +5，身法 +8，招架 +2；穿甲 +12%，伤血割裂流血 50%，乘隙/击头封穴 30%。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, Initiative = 12, MeleeDefense = 4 }, GrantSkills = ["actives.wx_spear_thrust2", "actives.wx_pole_sweep"], Flags = { DirectDmgBonus = 0.15, BleedOnHitPct = 65, AcupointOnCritPct = 45 }, Summary = "武艺 +7，身法 +12，招架 +4；习得「横扫千军」；穿甲 +15%，伤血割裂流血 65%，乘隙/击头封穴 45%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_bawang_xiejia <- {
	ID = "wx_manual_bawang_xiejia", Name = "霸王卸甲神枪谱", Category = "waigong", Quality = "unique",
	Element = null, WeaponTypes = ["Spear", "Polearm"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "古墓战神冢出土的枪戟至尊孤本：一枪挑飞重盾、二枪洞穿百炼重甲、三枪横扫万军辟易！",
	BasePrice = 11740, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 90, Stamina = 110 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_spear_thrust2", "actives.wx_pole_sweep"], Flags = { DirectDmgBonus = 0.10, ArmorDmgBonus = 0.15 }, Summary = "武艺 +4，招架 +2；习得「百鸟朝凤刺」「横扫千军」；破甲 +15%，穿甲 +10%。" },
		{ ExpNeeded = 320, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_spear_thrust2", "actives.wx_pole_sweep"], Flags = { DirectDmgBonus = 0.15, ArmorDmgBonus = 0.20, ShieldBreakBonus = 14 }, Summary = "武艺 +7，招架 +4；破甲 +20%，穿甲 +15%，碎盾劲 +14。" },
		{ ExpNeeded = 800, Stats = { MeleeSkill = 10, MeleeDefense = 6 }, GrantSkills = ["actives.wx_spear_thrust2", "actives.wx_pole_sweep", "actives.wx_spear_bawang"], Flags = { DirectDmgBonus = 0.20, ArmorDmgBonus = 0.25, ShieldBreakBonus = 18, UnderdogGuard = true }, Summary = "武艺 +10，招架 +6；大成习得「霸王挑鼎枪」；破甲 +25%，穿甲 +20%，碎盾劲 +18，免除被围攻近防惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shaolin_qimeigun <- {
	ID = "wx_manual_shaolin_qimeigun", Name = "少室齐眉棍", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Staff"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "少室禅院火头僧与行脚僧护身的白蜡齐眉棍，舞动如风车守身且省力。",
	BasePrice = 280, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1, MeleeDefense = 1 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.10 }, Summary = "武艺 +1，招架 +1；招式耗气 -10%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.15, DazeOnHeavyHitPct = 15 }, Summary = "武艺 +2，招架 +1；招式耗气 -15%，重击震荡失衡 15%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.20, DazeOnHeavyHitPct = 25 }, Summary = "武艺 +3，招架 +2；招式耗气 -20%，重击震荡失衡 25%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_qianfu_bang <- {
	ID = "wx_manual_qianfu_bang", Name = "川江纤夫号子棒", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Staff"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "巴蜀滩头纤夫用竹杠木棒合力驱赶水匪的把式，群殴合围准头极稳。",
	BasePrice = 280, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { SurroundHitBonus = 2 }, Summary = "武艺 +1；合围每名友军 +2 命中。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, Hitpoints = 4 }, GrantSkills = [], Flags = { SurroundHitBonus = 4 }, Summary = "武艺 +2，气血 +4；合围每名友军 +4 命中。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, Hitpoints = 8 }, GrantSkills = [], Flags = { SurroundHitBonus = 5, ArmorDmgBonus = 0.15 }, Summary = "武艺 +3，气血 +8；破甲 +15%，合围每名友军 +5 命中。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shaolin_weituogun <- {
	ID = "wx_manual_shaolin_weituogun", Name = "韦陀伏魔杵棍", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Staff"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "少室禅院护法武僧刚猛棍法，棒影横扫千军，对重甲与尸傀邪祟尤具摧折之力。",
	BasePrice = 2260, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64, Bravery = 48 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_pole_sweep"], Flags = { ArmorDmgBonus = 0.12 }, Summary = "武艺 +2，招架 +1；习得「横扫千军」；破甲 +12%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_pole_sweep"], Flags = { ArmorDmgBonus = 0.18, VsUndeadDmg = 0.10 }, Summary = "武艺 +4，招架 +2；破甲 +18%，对尸傀机关总伤 +10%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_pole_sweep", "actives.wx_staff_challenge"], Flags = { ArmorDmgBonus = 0.25, VsUndeadDmg = 0.16, DazeOnHeavyHitPct = 45 }, Summary = "武艺 +5，招架 +3；习得「横杖叫阵」；破甲 +25%，重击震荡失衡 45%，对尸傀机关总伤 +16%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_gaibang_lianhua <- {
	ID = "wx_manual_gaibang_lianhua", Name = "莲花落缠丝棒", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Staff"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "天下丐帮净衣与污衣弟子皆修的缠字棒法，棒头拨打四两拨千斤，处处引敌露绽。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_staff_challenge"], Flags = { ExposeOnHitPct = 25 }, Summary = "武艺 +2，招架 +1；习得「横杖叫阵」；普攻寻隙留破绽 25%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_staff_challenge", "actives.wx_pole_sweep"], Flags = { ExposeOnHitPct = 40, StaffGuard = true }, Summary = "武艺 +4，招架 +2；习得「横扫千军」；普攻寻隙留破绽 40%，持棒免除被围攻惩罚。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_staff_challenge", "actives.wx_pole_sweep"], Flags = { ExposeOnHitPct = 55, StaffGuard = true, OnHitDrainQi = 5 }, Summary = "武艺 +5，招架 +3；普攻寻隙留破绽 55%，持棒免除被围攻惩罚，命中震散敌内息 5 点。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_bashu_zhenjiang_bang <- {
	ID = "wx_manual_bashu_zhenjiang_bang", Name = "川江镇水盘龙棒", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Staff"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "川江袍哥盐帮龙头铁头长棒绝活，专为兄弟扛线叫阵，重击敲闷棍极易打懵强敌。",
	BasePrice = 2260, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 63, Bravery = 50 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1, Bravery = 3 }, GrantSkills = ["actives.wx_staff_challenge"], Flags = { DazeOnHeavyHitPct = 25 }, Summary = "武艺 +2，招架 +1，定力 +3；习得「横杖叫阵」；重击震荡失衡 25%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2, Bravery = 5 }, GrantSkills = ["actives.wx_staff_challenge"], Flags = { DazeOnHeavyHitPct = 40, StaffGuard = true }, Summary = "武艺 +4，招架 +2，定力 +5；重击震荡失衡 40%，持棒免除被围攻惩罚。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3, Bravery = 8 }, GrantSkills = ["actives.wx_staff_challenge", "actives.wx_pole_sweep"], Flags = { DazeOnHeavyHitPct = 55, StaffGuard = true, CritHeadBonus = 10 }, Summary = "武艺 +5，招架 +3，定力 +8；习得「横扫千军」；击头 +10%，重击震荡失衡 55%，持棒免除被围攻惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zhongzhou_wulang_gun <- {
	ID = "wx_manual_zhongzhou_wulang_gun", Name = "五郎八卦棍谱", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Staff"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "中州振武堂名传四方的军阵变体棍术，圈点挑劈一气呵成，结阵联防稳如磐石。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_pole_sweep"], Flags = { FormationBondDef = 2 }, Summary = "武艺 +2，招架 +1；习得「横扫千军」；邻接同袍结阵守御定力 +2。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_pole_sweep"], Flags = { FormationBondDef = 3, DirectDmgBonus = 0.08 }, Summary = "武艺 +4，招架 +2；穿甲 +8%，邻接同袍结阵守御定力 +3。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_pole_sweep", "actives.wx_staff_dagou"], Flags = { FormationBondDef = 4, DirectDmgBonus = 0.12, StaffGuard = true }, Summary = "武艺 +5，招架 +3；穿甲 +12%，持棒免除被围攻惩罚，邻接同袍结阵守御定力 +4。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_gaibang_qingou <- {
	ID = "wx_manual_gaibang_qingou", Name = "天下无狗神棒录", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Staff"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "天下丐帮帮主传位绿玉杖绝学：绊、劈、缠、戳变化万千，一根竹棒可令百炼重甲英雄束手！",
	BasePrice = 4540, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 80, Initiative = 105 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_pole_sweep", "actives.wx_staff_challenge"], Flags = { DirectDmgBonus = 0.08, ExposeOnHitPct = 35 }, Summary = "武艺 +3，招架 +2；习得「横扫千军」「横杖叫阵」；穿甲 +8%，普攻寻隙留破绽 35%。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 4 }, GrantSkills = ["actives.wx_pole_sweep", "actives.wx_staff_challenge"], Flags = { DirectDmgBonus = 0.12, ExposeOnHitPct = 50, StaffGuard = true }, Summary = "武艺 +5，招架 +4；穿甲 +12%，普攻寻隙留破绽 50%，持棒免除被围攻惩罚。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_pole_sweep", "actives.wx_staff_challenge"], Flags = { DirectDmgBonus = 0.15, ExposeOnHitPct = 65, StaffGuard = true, AcupointOnCritPct = 45, HitChanceBonus = 8 }, Summary = "武艺 +7，招架 +5；穿甲 +15%，近战命中 +8，普攻寻隙留破绽 65%，乘隙/击头封穴 45%，持棒免除被围攻惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shaolin_fengmogun <- {
	ID = "wx_manual_shaolin_fengmogun", Name = "紧那罗伏魔神棍", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Staff"], Icon = "ui/perks/wx_emblem_pole.png",
	Description = "少室禅院护寺神僧紧那罗王遗传疯魔重棍，棍风呼啸碎甲裂颅，重击震慑四座！",
	BasePrice = 4540, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, Stamina = 104 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_pole_sweep"], Flags = { ArmorDmgBonus = 0.15, DazeOnHeavyHitPct = 30 }, Summary = "武艺 +3，招架 +2；习得「横扫千军」；破甲 +15%，重击震荡失衡 30%。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_pole_sweep"], Flags = { ArmorDmgBonus = 0.20, DazeOnHeavyHitPct = 45, DirectDmgBonus = 0.10 }, Summary = "武艺 +5，招架 +3；破甲 +20%，穿甲 +10%，重击震荡失衡 45%。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_pole_sweep", "actives.wx_staff_challenge"], Flags = { ArmorDmgBonus = 0.25, DazeOnHeavyHitPct = 60, DirectDmgBonus = 0.15, StaffGuard = true }, Summary = "武艺 +7，招架 +5；习得「横杖叫阵」；破甲 +25%，穿甲 +15%，重击震荡失衡 60%，持棒免除被围攻惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zhongzhou_changquan <- {
	ID = "wx_manual_zhongzhou_changquan", Name = "太祖长拳谱", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/wx_emblem_fist.png",
	Description = "中原武馆无人不晓的开蒙拳路，寸劲刚直，堂堂正正。",
	BasePrice = 340, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1, Bravery = 2 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.08 }, Summary = "武艺 +1，定力 +2；招式耗气 -8%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, Bravery = 4 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.14, HitChanceBonus = 3 }, Summary = "武艺 +2，定力 +4；招式耗气 -14%，近战命中 +3。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 2, Bravery = 6 }, GrantSkills = ["actives.wx_fist_jab"], Flags = { WeaponQiDiscount = 0.20, HitChanceBonus = 5 }, Summary = "武艺 +3，招架 +2，定力 +6；精熟「罗汉冲拳」；招式耗气 -20%，近战命中 +5。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_qianjiang_kaibei <- {
	ID = "wx_manual_qianjiang_kaibei", Name = "盐场开碑手", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/wx_emblem_fist.png",
	Description = "浙东盐帮力夫拍击青石铁砂练就的硬巴掌，专砸甲片胸骨。",
	BasePrice = 310, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { ArmorDmgBonus = 0.08 }, Summary = "武艺 +1；破甲 +8%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2 }, GrantSkills = [], Flags = { ArmorDmgBonus = 0.14 }, Summary = "武艺 +2；破甲 +14%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 1 }, GrantSkills = [], Flags = { ArmorDmgBonus = 0.20, ShieldBreakBonus = 6 }, Summary = "武艺 +3，招架 +1；破甲 +20%，碎盾劲 +6。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shilin_yingzhao <- {
	ID = "wx_manual_shilin_yingzhao", Name = "分筋小擒拿", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/wx_emblem_fist.png",
	Description = "官府捕快与镖师锁拿匪徒关节的实用手法，顺势扯开破绽。",
	BasePrice = 370, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1, MeleeDefense = 1 }, GrantSkills = [], Flags = {}, Summary = "武艺 +1，招架 +1。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = [], Flags = { ExposeOnHitPct = 20 }, Summary = "武艺 +2，招架 +1；普攻寻隙留破绽 20%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = [], Flags = { ExposeOnHitPct = 35 }, Summary = "武艺 +3，招架 +2；普攻寻隙留破绽 35%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_taihe_mianzhang <- {
	ID = "wx_manual_taihe_mianzhang", Name = "太和绕指绵掌", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/wx_emblem_fist.png",
	Description = "太和玄门以内家柔劲催发的绵掌，掌力似轻实重，渗透护甲直散敌手真气。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64, Bravery = 48 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_fist_acupoint"], Flags = { DirectDmgBonus = 0.06, OnHitDrainQi = 4 }, Summary = "武艺 +2，招架 +1；习得「拈花点穴指」；穿甲 +6%，命中震散敌内息 4 点。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_fist_acupoint"], Flags = { DirectDmgBonus = 0.10, OnHitDrainQi = 6 }, Summary = "武艺 +4，招架 +2；穿甲 +10%，命中震散敌内息 6 点。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_fist_acupoint", "actives.wx_fist_taiji"], Flags = { DirectDmgBonus = 0.15, OnHitDrainQi = 8, WeaponQiDiscount = 0.15 }, Summary = "武艺 +5，招架 +3；大成习得「太极云手拳」；招式耗气 -15%，穿甲 +15%，命中震散敌内息 8 点。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_emei_piaoxue <- {
	ID = "wx_manual_emei_piaoxue", Name = "金顶佛光绵掌", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/wx_emblem_fist.png",
	Description = "峨眉金顶庵飘忽掌法，虚实相生令人无从招架，掌影过处留破绽且封气穴。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65, Initiative = 96 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Initiative = 4 }, GrantSkills = ["actives.wx_fist_acupoint"], Flags = { ExposeOnHitPct = 25 }, Summary = "武艺 +2，身法 +4；习得「拈花点穴指」；普攻寻隙留破绽 25%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, Initiative = 7, MeleeDefense = 1 }, GrantSkills = ["actives.wx_fist_acupoint"], Flags = { ExposeOnHitPct = 40, DirectDmgBonus = 0.08 }, Summary = "武艺 +4，身法 +7，招架 +1；穿甲 +8%，普攻寻隙留破绽 40%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Initiative = 10, MeleeDefense = 3 }, GrantSkills = ["actives.wx_fist_acupoint", "actives.wx_fist_grapple"], Flags = { ExposeOnHitPct = 55, DirectDmgBonus = 0.13 }, Summary = "武艺 +5，身法 +10，招架 +3；习得「擒龙探爪」；穿甲 +13%，普攻寻隙留破绽 55%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_qianjiang_nuchao_zhang <- {
	ID = "wx_manual_qianjiang_nuchao_zhang", Name = "钱塘惊涛裂岸掌", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/wx_emblem_fist.png",
	Description = "钱塘怒潮帮镇帮掌法，双掌推出如怒潮拍岸，摧甲碎盾并震晕失衡。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65, Stamina = 96 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2 }, GrantSkills = ["actives.wx_fist_jingang"], Flags = { ArmorDmgBonus = 0.12, ShieldBreakBonus = 8 }, Summary = "武艺 +2；习得「金刚摧心掌」；破甲 +12%，碎盾劲 +8。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 1 }, GrantSkills = ["actives.wx_fist_jingang"], Flags = { ArmorDmgBonus = 0.18, ShieldBreakBonus = 12 }, Summary = "武艺 +4，招架 +1；破甲 +18%，碎盾劲 +12。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 2 }, GrantSkills = ["actives.wx_fist_jingang", "actives.wx_fist_jiuyin"], Flags = { ArmorDmgBonus = 0.25, ShieldBreakBonus = 16, JingangStunPct = 40 }, Summary = "武艺 +5，招架 +2；破甲 +25%，金刚掌震晕 40%，碎盾劲 +16。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shaolin_longzhao <- {
	ID = "wx_manual_shaolin_longzhao", Name = "少室擒龙鹰爪功", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/wx_emblem_fist.png",
	Description = "少室禅院三十六路鹰爪擒拿手，隔步探爪将敌方射手拽入阵前分筋错骨！",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 66 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_fist_grapple"], Flags = { BleedOnHitPct = 25 }, Summary = "武艺 +2，招架 +1；习得「擒龙探爪」；伤血割裂流血 25%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_fist_grapple"], Flags = { BleedOnHitPct = 40, DirectDmgBonus = 0.08 }, Summary = "武艺 +4，招架 +2；穿甲 +8%，伤血割裂流血 40%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_fist_grapple", "actives.wx_fist_disarm"], Flags = { BleedOnHitPct = 55, DirectDmgBonus = 0.12, DisarmHitBonus = 6 }, Summary = "武艺 +5，招架 +3；习得「空手夺白刃」；穿甲 +12%，伤血割裂流血 55%，夺刃命中 +6。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_wudu_qianzhu <- {
	ID = "wx_manual_wudu_qianzhu", Name = "五毒千蛛摧心手", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/wx_emblem_fist.png",
	Description = "南疆五毒奇门喂饲花蛛淬炼指套的毒掌，抓伤皮肉即染剧毒，对中毒者招招致命。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64, Initiative = 95 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Initiative = 4 }, GrantSkills = ["actives.wx_fist_acupoint"], Flags = { WuduPoisonPct = 35 }, Summary = "武艺 +2，身法 +4；习得「拈花点穴指」；伤血染奇毒 35%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, Initiative = 7 }, GrantSkills = ["actives.wx_fist_acupoint"], Flags = { WuduPoisonPct = 60, VsPoisonedHit = 5 }, Summary = "武艺 +4，身法 +7；伤血染奇毒 60%，对中毒目标命中 +5。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Initiative = 10, MeleeDefense = 2 }, GrantSkills = ["actives.wx_fist_acupoint", "actives.wx_fist_qishang"], Flags = { WuduPoisonPct = 85, VsPoisonedHit = 8, DirectDmgBonus = 0.12 }, Summary = "武艺 +5，身法 +10，招架 +2；穿甲 +12%，伤血染奇毒 85%，对中毒目标命中 +8。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_heishui_xiongzhao <- {
	ID = "wx_manual_heishui_xiongzhao", Name = "黑水裂山熊罴爪", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/wx_emblem_fist.png",
	Description = "黑水战帮勇士佩铁钩指虎搏杀野兽的凶残爪法，撕裂皮肉且斩敌回血。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65, Hitpoints = 72 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Hitpoints = 4 }, GrantSkills = ["actives.wx_fist_grapple"], Flags = { BleedOnHitPct = 35 }, Summary = "武艺 +2，气血 +4；习得「擒龙探爪」；伤血割裂流血 35%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, Hitpoints = 8 }, GrantSkills = ["actives.wx_fist_grapple"], Flags = { BleedOnHitPct = 50, UnarmoredBonusDmg = 0.12 }, Summary = "武艺 +4，气血 +8；对破甲/无甲实伤 +12%，伤血割裂流血 50%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Hitpoints = 12, MeleeDefense = 2 }, GrantSkills = ["actives.wx_fist_grapple", "actives.wx_fist_jingang"], Flags = { BleedOnHitPct = 65, UnarmoredBonusDmg = 0.18, OnKillHealHP = 8 }, Summary = "武艺 +5，气血 +12，招架 +2；习得「金刚摧心掌」；对破甲/无甲实伤 +18%，伤血割裂流血 65%，击杀生人回 8 气血。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_gaibang_xianglong <- {
	ID = "wx_manual_gaibang_xianglong", Name = "亢龙震天十八掌", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/wx_emblem_fist.png",
	Description = "天下至刚至猛的掌道绝学：掌出如神龙摆尾无坚不摧，破甲、透劲与震晕俱臻巅峰！",
	BasePrice = 4540, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 82, Stamina = 106 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_fist_jingang"], Flags = { ArmorDmgBonus = 0.15, DirectDmgBonus = 0.08 }, Summary = "武艺 +3，招架 +2；习得「金刚摧心掌」；破甲 +15%，穿甲 +8%。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_fist_jingang", "actives.wx_fist_grapple"], Flags = { ArmorDmgBonus = 0.20, DirectDmgBonus = 0.12, JingangStunPct = 45 }, Summary = "武艺 +5，招架 +3；习得「擒龙探爪」；破甲 +20%，穿甲 +12%，金刚掌震晕 45%。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_fist_jingang", "actives.wx_fist_xianglong"], Flags = { ArmorDmgBonus = 0.25, DirectDmgBonus = 0.15, JingangStunPct = 65, ShieldBreakBonus = 16 }, Summary = "武艺 +7，招架 +5；大成习得「亢龙有悔掌」；破甲 +25%，穿甲 +15%，金刚掌震晕 65%，碎盾劲 +16。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_xuanbing_hanzhang <- {
	ID = "wx_manual_xuanbing_hanzhang", Name = "玄冥寒毒神掌", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/wx_emblem_fist.png",
	Description = "昆仑玄冰宫阴毒绝伦的寒冰掌力，中掌者真气冻结散逸、全身僵直失衡。",
	BasePrice = 4570, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, Bravery = 56 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_fist_acupoint"], Flags = { OnHitDrainQi = 5, DirectDmgBonus = 0.08 }, Summary = "武艺 +3，招架 +2；习得「拈花点穴指」；穿甲 +8%，命中震散敌内息 5 点。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_fist_acupoint", "actives.wx_fist_jingang"], Flags = { OnHitDrainQi = 7, DirectDmgBonus = 0.12, DazeOnHeavyHitPct = 40 }, Summary = "武艺 +5，招架 +3；习得「金刚摧心掌」；穿甲 +12%，重击震荡失衡 40%，命中震散敌内息 7 点。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_fist_acupoint", "actives.wx_fist_xuanming"], Flags = { OnHitDrainQi = 8, DirectDmgBonus = 0.15, DazeOnHeavyHitPct = 60, FrostChillOnHit = true }, Summary = "武艺 +7，招架 +5；大成习得「玄冥寒毒掌」；穿甲 +15%，重击震荡失衡 60%，受近战寒劲反侵令敌失衡，命中震散敌内息 8 点。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_mingzun_qishang <- {
	ID = "wx_manual_mingzun_qishang", Name = "圣火七伤摧脉拳", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/wx_emblem_fist.png",
	Description = "西域圣火明尊教护教法王霸道拳经，一拳内蕴七股诡异暗劲，专透重甲震裂脏腑。",
	BasePrice = 4660, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 80, Bravery = 58 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_fist_jingang"], Flags = { DirectDmgBonus = 0.10, AcupointOnCritPct = 25 }, Summary = "武艺 +3，招架 +2；习得「金刚摧心掌」；穿甲 +10%，乘隙/击头封穴 25%。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_fist_jingang", "actives.wx_fist_acupoint"], Flags = { DirectDmgBonus = 0.13, AcupointOnCritPct = 40, CritHeadBonus = 8 }, Summary = "武艺 +5，招架 +3；习得「拈花点穴指」；穿甲 +13%，击头 +8%，乘隙/击头封穴 40%。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_fist_jingang", "actives.wx_fist_acupoint"], Flags = { DirectDmgBonus = 0.15, AcupointOnCritPct = 50, CritHeadBonus = 12, ExecuteLowHpDmg = 0.16 }, Summary = "武艺 +7，招架 +4；穿甲 +15%，对半血残敌伤害 +16%，击头 +12%，乘隙/击头封穴 50%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_gusumu_canhezhi <- {
	ID = "wx_manual_gusumu_canhezhi", Name = "参合幻影截脉指", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/wx_emblem_fist.png",
	Description = "姑苏慕氏剑庄凌厉指功绝学，指劲破空点穴夺兵，令敌手一身武艺无从施展。",
	BasePrice = 4570, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 80, Initiative = 106 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_fist_acupoint"], Flags = { DirectDmgBonus = 0.08, ExposeOnHitPct = 30 }, Summary = "武艺 +3，招架 +2；习得「拈花点穴指」；穿甲 +8%，普攻寻隙留破绽 30%。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 4 }, GrantSkills = ["actives.wx_fist_acupoint", "actives.wx_fist_disarm"], Flags = { DirectDmgBonus = 0.12, ExposeOnHitPct = 45, DisarmHitBonus = 8 }, Summary = "武艺 +5，招架 +4；习得「空手夺白刃」；穿甲 +12%，普攻寻隙留破绽 45%，夺刃命中 +8。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_fist_yiyang", "actives.wx_fist_disarm"], Flags = { DirectDmgBonus = 0.15, ExposeOnHitPct = 60, DisarmHitBonus = 12, HitChanceBonus = 8 }, Summary = "武艺 +7，招架 +5；大成习得「一阳贯日指」；穿甲 +15%，近战命中 +8，普攻寻隙留破绽 60%，夺刃命中 +12。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_senluo_wanxiang <- {
	ID = "wx_manual_senluo_wanxiang", Name = "如来千手神掌总纲", Category = "waigong", Quality = "unique",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/wx_emblem_fist.png",
	Description = "摩崖石窟秘藏的拳掌极境孤本：擒龙探爪、点穴夺刃、金刚震晕一念收发，隔甲透劲冠绝江湖！",
	BasePrice = 11740, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 90, Stamina = 108 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_fist_jingang", "actives.wx_fist_grapple"], Flags = { DirectDmgBonus = 0.10, ArmorDmgBonus = 0.15 }, Summary = "武艺 +4，招架 +2；习得「金刚摧心掌」「擒龙探爪」；破甲 +15%，穿甲 +10%。" },
		{ ExpNeeded = 320, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_fist_jingang", "actives.wx_fist_grapple", "actives.wx_fist_disarm"], Flags = { DirectDmgBonus = 0.15, ArmorDmgBonus = 0.20, JingangStunPct = 50 }, Summary = "武艺 +7，招架 +4；习得「空手夺白刃」；破甲 +20%，穿甲 +15%，金刚掌震晕 50%。" },
		{ ExpNeeded = 800, Stats = { MeleeSkill = 10, MeleeDefense = 6 }, GrantSkills = ["actives.wx_fist_jingang", "actives.wx_fist_grapple", "actives.wx_fist_disarm"], Flags = { DirectDmgBonus = 0.20, ArmorDmgBonus = 0.25, JingangStunPct = 70, DisarmHitBonus = 12 }, Summary = "武艺 +10，招架 +6；破甲 +25%，穿甲 +20%，金刚掌震晕 70%，夺刃命中 +12。" }
	]
};
