// Expanded Waigong Library III: Hammer, Axe, Flail, Dagger, Bow, Crossbow, Throwing & Firearm
// Auto-audited against AGENTS.md stat & non-stacking redlines.

::Wuxia.Config.Manuals.wx_manual_kuanggong_gao <- {
	ID = "wx_manual_kuanggong_gao", Name = "开山鹤嘴镐法", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Hammer"], Icon = "ui/perks/wx_manual_kuanggong_gao.png",
	Description = "矿夫与发丘力士挥舞铁镐重锤凿石破甲的实用功夫，对厚甲尤为致命。",
	BasePrice = 370, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { UnbrokenArmorBonus = 0.08 }, Summary = "武艺 +1；对厚甲破甲 +8%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2 }, GrantSkills = [], Flags = { UnbrokenArmorBonus = 0.14 }, Summary = "武艺 +2；对厚甲破甲 +14%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, Hitpoints = 6 }, GrantSkills = [], Flags = { UnbrokenArmorBonus = 0.20, DirectDmgBonus = 0.06 }, Summary = "武艺 +3，气血 +6；穿甲 +6%，对厚甲破甲 +20%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_tiejiang_duanchui <- {
	ID = "wx_manual_tiejiang_duanchui", Name = "百炼锻铁锤式", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Hammer"], Icon = "ui/perks/wx_manual_tiejiang_duanchui.png",
	Description = "军器监铁匠抡锤打铁练出的沉稳锤路，久抡不乏力，重击震脑。",
	BasePrice = 340, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.10 }, Summary = "武艺 +1；招式耗气 -10%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, Stamina = 4 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.15, DazeOnHeavyHitPct = 15 }, Summary = "武艺 +2，内息 +4；招式耗气 -15%，重击震荡失衡 15%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, Stamina = 8 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.20, DazeOnHeavyHitPct = 25 }, Summary = "武艺 +3，内息 +8；招式耗气 -20%，重击震荡失衡 25%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shuofang_jingua <- {
	ID = "wx_manual_shuofang_jingua", Name = "朔方八棱金瓜锤", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Hammer"], Icon = "ui/perks/wx_manual_shuofang_jingua.png",
	Description = "朔方金瓜力士堂成名锤谱，专砸铁盔脑门与盾墙，一锤下去骨断筋折。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64, Stamina = 98 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2 }, GrantSkills = ["actives.wx_hammer_jingua"], Flags = { CritHeadBonus = 6, ArmorDmgBonus = 0.12 }, Summary = "武艺 +2；破甲 +12%，击头 +6%；习得「八棱金瓜砸」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 1 }, GrantSkills = ["actives.wx_hammer_jingua"], Flags = { CritHeadBonus = 10, ArmorDmgBonus = 0.18, ShieldBreakBonus = 8 }, Summary = "武艺 +4，招架 +1；破甲 +18%，击头 +10%，碎盾劲 +8。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 2 }, GrantSkills = ["actives.wx_hammer_jingua", "actives.wx_hammer_shatter"], Flags = { CritHeadBonus = 14, ArmorDmgBonus = 0.24, ShieldBreakBonus = 14 }, Summary = "武艺 +5，招架 +2；破甲 +24%，击头 +14%，碎盾劲 +14；习得「震岳碎甲击」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_hengshan_polu_chui <- {
	ID = "wx_manual_hengshan_polu_chui", Name = "北岳破虏擂鼓锤", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Hammer"], Icon = "ui/perks/wx_manual_hengshan_polu_chui.png",
	Description = "北岳守塞堂重装锤士结阵攻坚套路，锤势连环如战鼓雷鸣，震荡周遭敌军。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65, Stamina = 100 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_hammer_polu"], Flags = { FormationBondDef = 2 }, Summary = "武艺 +2，招架 +1；邻接同袍结阵守御定力 +2；习得「北岳擂鼓震」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_hammer_polu"], Flags = { FormationBondDef = 3, ArmorDmgBonus = 0.16 }, Summary = "武艺 +4，招架 +2；破甲 +16%，邻接同袍结阵守御定力 +3。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_hammer_polu", "actives.wx_hammer_quake"], Flags = { FormationBondDef = 4, ArmorDmgBonus = 0.22 }, Summary = "武艺 +5，招架 +3；破甲 +22%，邻接同袍结阵守御定力 +4；习得「裂地崩山锤」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_loulan_faqiu_chui <- {
	ID = "wx_manual_loulan_faqiu_chui", Name = "发丘分金破墓锤", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Hammer"], Icon = "ui/perks/wx_manual_loulan_faqiu_chui.png",
	Description = "楼兰摸金商会专为轰碎石门与古墓金甲机关卫所创的重锤秘技，克邪破甲双绝！",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64, Bravery = 50 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Bravery = 4 }, GrantSkills = ["actives.wx_hammer_faqiu"], Flags = { VsUndeadDmg = 0.08, UnbrokenArmorBonus = 0.12 }, Summary = "武艺 +2，定力 +4；对厚甲破甲 +12%，对尸傀机关总伤 +8%；习得「发丘分金锤」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, Bravery = 7 }, GrantSkills = ["actives.wx_hammer_faqiu"], Flags = { VsUndeadDmg = 0.14, UnbrokenArmorBonus = 0.18 }, Summary = "武艺 +4，定力 +7；对厚甲破甲 +18%，对尸傀机关总伤 +14%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Bravery = 10, MeleeDefense = 2 }, GrantSkills = ["actives.wx_hammer_faqiu", "actives.wx_hammer_shatter"], Flags = { VsUndeadDmg = 0.18, UnbrokenArmorBonus = 0.25, DirectDmgBonus = 0.10 }, Summary = "武艺 +5，定力 +10，招架 +2；穿甲 +10%，对厚甲破甲 +25%，对尸傀机关总伤 +18%；习得「震岳碎甲击」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zhenyue_bapi <- {
	ID = "wx_manual_zhenyue_bapi", Name = "太行崩岩重锤录", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Hammer"], Icon = "ui/perks/wx_manual_zhenyue_bapi.png",
	Description = "太行震岳门长老传授的地裂锤法，以巨力引发震波，令扎堆敌军东倒西歪。",
	BasePrice = 2260, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 66, Stamina = 100 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2 }, GrantSkills = ["actives.wx_hammer_quake"], Flags = { DazeOnHeavyHitPct = 25 }, Summary = "武艺 +2；习得「裂地崩山锤」；重击震荡失衡 25%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 1 }, GrantSkills = ["actives.wx_hammer_quake"], Flags = { DazeOnHeavyHitPct = 40, ArmorDmgBonus = 0.18 }, Summary = "武艺 +4，招架 +1；破甲 +18%，重击震荡失衡 40%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_hammer_quake"], Flags = { DazeOnHeavyHitPct = 55, ArmorDmgBonus = 0.25 }, Summary = "武艺 +5，招架 +3；破甲 +25%，重击震荡失衡 55%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zhenyue_qianjun <- {
	ID = "wx_manual_zhenyue_qianjun", Name = "太行万钧碎星锤", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Hammer"], Icon = "ui/perks/wx_manual_zhenyue_qianjun.png",
	Description = "太行震岳门镇山绝学：一锤碎甲、二锤裂地，任何百炼重凯在锤下皆如薄纸！",
	BasePrice = 4540, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 80, Stamina = 108 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_hammer_qianjun"], Flags = { ArmorDmgBonus = 0.16, UnbrokenArmorBonus = 0.12 }, Summary = "武艺 +3，招架 +2「裂地崩山锤」；破甲 +16%，对厚甲破甲 +12%；习得「太行碎星锤」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_hammer_qianjun", "actives.wx_hammer_quake"], Flags = { ArmorDmgBonus = 0.22, UnbrokenArmorBonus = 0.18, DirectDmgBonus = 0.10 }, Summary = "武艺 +5，招架 +3；破甲 +22%，穿甲 +10%，对厚甲破甲 +18%；习得「裂地崩山锤」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_hammer_qianjun", "actives.wx_hammer_quake"], Flags = { ArmorDmgBonus = 0.25, UnbrokenArmorBonus = 0.25, DirectDmgBonus = 0.15, DazeOnHeavyHitPct = 60 }, Summary = "武艺 +7，招架 +5；破甲 +25%，穿甲 +15%，对厚甲破甲 +25%，重击震荡失衡 60%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shuofang_leishen <- {
	ID = "wx_manual_shuofang_leishen", Name = "轰天雷神双锤谱", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Hammer"], Icon = "ui/perks/wx_manual_shuofang_leishen.png",
	Description = "朔方金瓜力士堂堂主秘传凶悍锤谱，专轰头颅盾牌并抽散敌方真气。",
	BasePrice = 4570, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, Stamina = 105 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 1 }, GrantSkills = ["actives.wx_hammer_polu"], Flags = { CritHeadBonus = 8, OnHitDrainQi = 5 }, Summary = "武艺 +3，招架 +1；击头 +8%，命中震散敌内息 5 点；习得「北岳擂鼓震」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_hammer_polu", "actives.wx_hammer_leiting"], Flags = { CritHeadBonus = 12, OnHitDrainQi = 7, ShieldBreakBonus = 12 }, Summary = "武艺 +5，招架 +3；击头 +12%，碎盾劲 +12，命中震散敌内息 7 点；习得「雷霆碎岳锤」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_hammer_polu", "actives.wx_hammer_leiting"], Flags = { CritHeadBonus = 15, OnHitDrainQi = 8, ShieldBreakBonus = 18, DirectDmgBonus = 0.14 }, Summary = "武艺 +7，招架 +4；穿甲 +14%，击头 +15%，碎盾劲 +18，命中震散敌内息 8 点。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_jiuyao_pocheng <- {
	ID = "wx_manual_jiuyao_pocheng", Name = "九曜破城神锤录", Category = "waigong", Quality = "unique",
	Element = null, WeaponTypes = ["Hammer"], Icon = "ui/perks/wx_manual_jiuyao_pocheng.png",
	Description = "传说中猛将擂碎城门铁锁的无双锤道孤本：满甲攻坚、隔甲震腑、裂地群控一锤定乾坤！",
	BasePrice = 11800, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 90, Stamina = 112 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_hammer_leiting"], Flags = { ArmorDmgBonus = 0.16, DirectDmgBonus = 0.10 }, Summary = "武艺 +4，招架 +2、「裂地崩山锤」「裂地崩山锤」；破甲 +16%，穿甲 +10%；习得「雷霆碎岳锤」。" },
		{ ExpNeeded = 320, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_hammer_leiting", "actives.wx_hammer_qianjun"], Flags = { ArmorDmgBonus = 0.22, DirectDmgBonus = 0.15, UnbrokenArmorBonus = 0.20 }, Summary = "武艺 +7，招架 +4；破甲 +22%，穿甲 +15%，对厚甲破甲 +20%；习得「太行碎星锤」。" },
		{ ExpNeeded = 800, Stats = { MeleeSkill = 10, MeleeDefense = 6 }, GrantSkills = ["actives.wx_hammer_leiting", "actives.wx_hammer_qianjun", "actives.wx_hammer_pocheng"], Flags = { ArmorDmgBonus = 0.25, DirectDmgBonus = 0.20, UnbrokenArmorBonus = 0.25, ShieldBreakBonus = 18 }, Summary = "武艺 +10，招架 +6；破甲 +25%，穿甲 +20%，对厚甲破甲 +25%，碎盾劲 +18；习得「九曜破城锤」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_taihang_luanfu <- {
	ID = "wx_manual_taihang_luanfu", Name = "绿林三板斧", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Axe"], Icon = "ui/perks/wx_manual_taihang_luanfu.png",
	Description = "太行山寨头领起手唬人的三招猛斧，开局首轮威猛绝伦。",
	BasePrice = 400, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { FirstRoundHit = 5 }, Summary = "武艺 +1；首轮命中 +5。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2 }, GrantSkills = [], Flags = { FirstRoundHit = 8, ShieldBreakBonus = 5 }, Summary = "武艺 +2；首轮命中 +8，碎盾劲 +5。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, Bravery = 4 }, GrantSkills = [], Flags = { FirstRoundHit = 10, ShieldBreakBonus = 8, CritHeadBonus = 6 }, Summary = "武艺 +3，定力 +4；击头 +6%，首轮命中 +10，碎盾劲 +8。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_fumu_qiaofu <- {
	ID = "wx_manual_fumu_qiaofu", Name = "林海伐木劲斧", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Axe"], Icon = "ui/perks/wx_manual_fumu_qiaofu.png",
	Description = "辽东老樵夫砍伐百年铁松练出的腰臂沉劲，劈盾破甲干脆利落。",
	BasePrice = 280, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { ShieldBreakBonus = 5 }, Summary = "武艺 +1；碎盾劲 +5。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2 }, GrantSkills = [], Flags = { ShieldBreakBonus = 8, ArmorDmgBonus = 0.08 }, Summary = "武艺 +2；破甲 +8%，碎盾劲 +8。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 1 }, GrantSkills = [], Flags = { ShieldBreakBonus = 12, ArmorDmgBonus = 0.15 }, Summary = "武艺 +3，招架 +1；破甲 +15%，碎盾劲 +12。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_taihang_duanhun_fu <- {
	ID = "wx_manual_taihang_duanhun_fu", Name = "太行追命手斧谱", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Axe"], Icon = "ui/perks/wx_manual_taihang_duanhun_fu.png",
	Description = "太行十八寨大寨主狠辣单双斧术，专剁敌手脑门与残血伤员。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2 }, GrantSkills = ["actives.wx_axe_poche"], Flags = { CritHeadBonus = 6, BleedOnHitPct = 25 }, Summary = "武艺 +2；击头 +6%，伤血割裂流血 25%；习得「宣花碎车劈」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4 }, GrantSkills = ["actives.wx_axe_poche"], Flags = { CritHeadBonus = 10, BleedOnHitPct = 40, ExecuteLowHpDmg = 0.10 }, Summary = "武艺 +4；对半血残敌伤害 +10%，击头 +10%，伤血割裂流血 40%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 2 }, GrantSkills = ["actives.wx_axe_poche", "actives.wx_axe_split"], Flags = { CritHeadBonus = 14, BleedOnHitPct = 55, ExecuteLowHpDmg = 0.16 }, Summary = "武艺 +5，招架 +2；对半血残敌伤害 +16%，击头 +14%，伤血割裂流血 55%；习得「力劈华山」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_pishan_xuanfeng <- {
	ID = "wx_manual_pishan_xuanfeng", Name = "辽东旋风巨斧录", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Axe"], Icon = "ui/perks/wx_manual_pishan_xuanfeng.png",
	Description = "辽东劈山盟长老群战巨斧套路，身陷重围时抡起大斧旋斩八方！",
	BasePrice = 2260, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 66, Stamina = 98 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2 }, GrantSkills = ["actives.wx_axe_whirl"], Flags = { ArmorDmgBonus = 0.10 }, Summary = "武艺 +2；习得「旋风断魂斧」；破甲 +10%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 1 }, GrantSkills = ["actives.wx_axe_whirl"], Flags = { ArmorDmgBonus = 0.16, UnderdogGuard = true }, Summary = "武艺 +4，招架 +1；破甲 +16%，免除被围攻近防惩罚。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_axe_whirl", "actives.wx_axe_split"], Flags = { ArmorDmgBonus = 0.22, UnderdogGuard = true }, Summary = "武艺 +5，招架 +3；习得「力劈华山」；破甲 +22%，免除被围攻近防惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_heishui_kuangfu <- {
	ID = "wx_manual_heishui_kuangfu", Name = "黑水血战劈颅斧", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Axe"], Icon = "ui/perks/wx_manual_heishui_kuangfu.png",
	Description = "黑水战帮前锋弃守强攻的狂野斧法，孤身冲阵威力暴涨，斩敌回气回血。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65, Bravery = 50 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Bravery = 4 }, GrantSkills = ["actives.wx_axe_split"], Flags = { LoneWolfBonus = 3, OnKillHealHP = 4 }, Summary = "武艺 +2，定力 +4；习得「力劈华山」；孤身两格无友军时攻防 +3，击杀生人回 4 气血。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, Bravery = 6 }, GrantSkills = ["actives.wx_axe_split"], Flags = { LoneWolfBonus = 5, OnKillHealHP = 6, CritHeadBonus = 8 }, Summary = "武艺 +4，定力 +6；击头 +8%，孤身两格无友军时攻防 +5，击杀生人回 6 气血。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Bravery = 10 }, GrantSkills = ["actives.wx_axe_split", "actives.wx_axe_whirl"], Flags = { LoneWolfBonus = 6, OnKillHealHP = 8, CritHeadBonus = 12 }, Summary = "武艺 +5，定力 +10；习得「旋风断魂斧」；击头 +12%，孤身两格无友军时攻防 +6，击杀生人回 8 气血。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_yanmen_poche_fu <- {
	ID = "wx_manual_yanmen_poche_fu", Name = "边军碎盾宣花斧", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Axe"], Icon = "ui/perks/wx_manual_yanmen_poche_fu.png",
	Description = "九边选锋营专门用来劈碎盾墙重甲的宣花大斧战法，碎盾劲力冠绝诸兵。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_axe_poche"], Flags = { ShieldBreakBonus = 8, ArmorDmgBonus = 0.10 }, Summary = "武艺 +2，招架 +1；破甲 +10%，碎盾劲 +8；习得「宣花碎车劈」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_axe_poche"], Flags = { ShieldBreakBonus = 13, ArmorDmgBonus = 0.16 }, Summary = "武艺 +4，招架 +2；破甲 +16%，碎盾劲 +13。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_axe_poche"], Flags = { ShieldBreakBonus = 18, ArmorDmgBonus = 0.24 }, Summary = "武艺 +5，招架 +3；破甲 +24%，碎盾劲 +18。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_pishan_kaitian <- {
	ID = "wx_manual_pishan_kaitian", Name = "劈山裂岳神斧经", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Axe"], Icon = "ui/perks/wx_manual_pishan_kaitian.png",
	Description = "辽东劈山盟盟主秘传绝学：力劈华山与旋风断魂收发由心，碎盾破甲如摧枯拉朽！",
	BasePrice = 4630, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 80, Stamina = 106 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 1 }, GrantSkills = ["actives.wx_axe_kaitian"], Flags = { ArmorDmgBonus = 0.15, ShieldBreakBonus = 10 }, Summary = "武艺 +3，招架 +1「旋风断魂斧」；破甲 +15%，碎盾劲 +10；习得「裂岳开天钺」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_axe_kaitian", "actives.wx_axe_whirl"], Flags = { ArmorDmgBonus = 0.20, ShieldBreakBonus = 14, CritHeadBonus = 10 }, Summary = "武艺 +5，招架 +3；破甲 +20%，击头 +10%，碎盾劲 +14；习得「旋风断魂斧」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_axe_kaitian", "actives.wx_axe_whirl"], Flags = { ArmorDmgBonus = 0.25, ShieldBreakBonus = 18, CritHeadBonus = 15, DirectDmgBonus = 0.14 }, Summary = "武艺 +7，招架 +4；破甲 +25%，穿甲 +14%，击头 +15%，碎盾劲 +18。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_heishui_xueming_fu <- {
	ID = "wx_manual_heishui_xueming_fu", Name = "荒原狂魔血斧录", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Axe"], Icon = "ui/perks/wx_manual_heishui_xueming_fu.png",
	Description = "关外黑水战帮大萨满供奉的狂战士秘卷：孤身陷阵大杀四方，每逢斩首立返行动点继续追劈！",
	BasePrice = 4630, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 80, Hitpoints = 78 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3 }, GrantSkills = ["actives.wx_axe_xueming"], Flags = { LoneWolfBonus = 4, OnKillHealHP = 6 }, Summary = "武艺 +3；孤身两格无友军时攻防 +4，击杀生人回 6 气血；习得「荒原饮血斧」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 2 }, GrantSkills = ["actives.wx_axe_xueming", "actives.wx_axe_whirl"], Flags = { LoneWolfBonus = 6, OnKillHealHP = 8, OnKillAPRefund = 2 }, Summary = "武艺 +5，招架 +2；孤身两格无友军时攻防 +6，击杀生人回 8 气血，每回合首杀返 +2 AP；习得「旋风断魂斧」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_axe_xueming", "actives.wx_axe_whirl"], Flags = { LoneWolfBonus = 8, OnKillHealHP = 10, OnKillAPRefund = 3, UnderdogGuard = true }, Summary = "武艺 +7，招架 +4；免除被围攻近防惩罚，孤身两格无友军时攻防 +8，击杀生人回 10 气血，每回合首杀返 +3 AP。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_pangu_kaitian <- {
	ID = "wx_manual_pangu_kaitian", Name = "盘古开天巨斧图", Category = "waigong", Quality = "unique",
	Element = null, WeaponTypes = ["Axe"], Icon = "ui/perks/wx_manual_pangu_kaitian.png",
	Description = "上古神工石刻孤本：至重至烈，当头一斧无视坚盾厚甲，旋斩横扫令十步之内血肉横飞！",
	BasePrice = 11830, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 90, Stamina = 112 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_axe_kaishan", "actives.wx_axe_whirl"], Flags = { ArmorDmgBonus = 0.16, DirectDmgBonus = 0.10 }, Summary = "武艺 +4，招架 +2；习得「旋风开山斩」、「旋风断魂斧」「旋风断魂斧」；破甲 +16%，穿甲 +10%。" },
		{ ExpNeeded = 320, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_axe_kaishan", "actives.wx_axe_whirl"], Flags = { ArmorDmgBonus = 0.22, DirectDmgBonus = 0.15, CritHeadBonus = 12 }, Summary = "武艺 +7，招架 +4；破甲 +22%，穿甲 +15%，击头 +12%。" },
		{ ExpNeeded = 800, Stats = { MeleeSkill = 10, MeleeDefense = 6 }, GrantSkills = ["actives.wx_axe_kaishan", "actives.wx_axe_whirl"], Flags = { ArmorDmgBonus = 0.25, DirectDmgBonus = 0.20, CritHeadBonus = 15, OnKillAPRefund = 3 }, Summary = "武艺 +10，招架 +6；破甲 +25%，穿甲 +20%，击头 +15%，每回合首杀返 +3 AP。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shaozi_gun <- {
	ID = "wx_manual_shaozi_gun", Name = "农家打麦连枷式", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Flail"], Icon = "ui/perks/wx_manual_shaozi_gun.png",
	Description = "庄稼汉将打麦连枷改作防身奇兵的抡砸手法，绕盾抽头省力实用。",
	BasePrice = 310, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.08, CritHeadBonus = 4 }, Summary = "武艺 +1；招式耗气 -8%，击头 +4%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.14, CritHeadBonus = 7 }, Summary = "武艺 +2；招式耗气 -14%，击头 +7%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 1 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.20, CritHeadBonus = 10 }, Summary = "武艺 +3，招架 +1；招式耗气 -20%，击头 +10%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_mabei_changbian <- {
	ID = "wx_manual_mabei_changbian", Name = "牧马响鞭术", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Flail"], Icon = "ui/perks/wx_manual_mabei_changbian.png",
	Description = "塞北牧民抽打烈马练出的脆响长鞭，专抽手脸皮肉见血。",
	BasePrice = 400, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1, Initiative = 3 }, GrantSkills = [], Flags = { BleedOnHitPct = 15 }, Summary = "武艺 +1，身法 +3；伤血割裂流血 15%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, Initiative = 5 }, GrantSkills = [], Flags = { BleedOnHitPct = 25 }, Summary = "武艺 +2，身法 +5；伤血割裂流血 25%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, Initiative = 7 }, GrantSkills = [], Flags = { BleedOnHitPct = 35, ExposeOnHitPct = 20 }, Summary = "武艺 +3，身法 +7；伤血割裂流血 35%，普攻寻隙留破绽 20%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_mobei_taoma_bian <- {
	ID = "wx_manual_mobei_taoma_bian", Name = "苍狼缚虎套马鞭", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Flail"], Icon = "ui/perks/wx_manual_mobei_taoma_bian.png",
	Description = "漠北苍狼部勇士马上步下生擒敌将的套索长鞭，锁喉封穴令敌手窒息乏力！",
	BasePrice = 2260, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Initiative = 4 }, GrantSkills = ["actives.wx_flail_entangle"], Flags = { OnHitDrainQi = 4 }, Summary = "武艺 +2，身法 +4；命中震散敌内息 4 点；习得「锁喉缠丝劲」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, Initiative = 7 }, GrantSkills = ["actives.wx_flail_entangle"], Flags = { OnHitDrainQi = 6, ExposeOnHitPct = 25 }, Summary = "武艺 +4，身法 +7；普攻寻隙留破绽 25%，命中震散敌内息 6 点。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Initiative = 10, MeleeDefense = 2 }, GrantSkills = ["actives.wx_flail_entangle", "actives.wx_flail_liuxing"], Flags = { OnHitDrainQi = 8, ExposeOnHitPct = 40 }, Summary = "武艺 +5，身法 +10，招架 +2；普攻寻隙留破绽 40%，命中震散敌内息 8 点；习得「三首流星砸」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_dongting_shuijiao_bian <- {
	ID = "wx_manual_dongting_shuijiao_bian", Name = "洞庭毒蛟倒刺鞭", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Flail"], Icon = "ui/perks/wx_manual_dongting_shuijiao_bian.png",
	Description = "洞庭连环水寨以铁蒺藜编入皮鞭的水战凶器谱，一鞭抽下皮开肉绽流血不止。",
	BasePrice = 2260, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2 }, GrantSkills = ["actives.wx_flail_lash"], Flags = { BleedOnHitPct = 35 }, Summary = "武艺 +2；习得「云梦绕盾抽」；伤血割裂流血 35%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 1 }, GrantSkills = ["actives.wx_flail_lash"], Flags = { BleedOnHitPct = 50, UnarmoredBonusDmg = 0.10 }, Summary = "武艺 +4，招架 +1；对破甲/无甲实伤 +10%，伤血割裂流血 50%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 2 }, GrantSkills = ["actives.wx_flail_lash", "actives.wx_whip_suohou"], Flags = { BleedOnHitPct = 65, UnarmoredBonusDmg = 0.16, CritHeadBonus = 10 }, Summary = "武艺 +5，招架 +2；对破甲/无甲实伤 +16%，击头 +10%，伤血割裂流血 65%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_xiangxi_ganhun_bian <- {
	ID = "wx_manual_xiangxi_ganhun_bian", Name = "辰州摄魂引路鞭", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Flail"], Icon = "ui/perks/wx_manual_xiangxi_ganhun_bian.png",
	Description = "湘西辰州符水门赶尸匠黑夜抽响的引魂麻鞭，鞭梢带阴煞破邪且摄人心魄。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 63, Bravery = 52 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Bravery = 4 }, GrantSkills = ["actives.wx_whip_xiangxi"], Flags = { VsUndeadDmg = 0.08, NightOwl = true }, Summary = "武艺 +2，定力 +4；夜战无视视野惩罚，对尸傀机关总伤 +8%；习得「辰州摄魂鞭」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, Bravery = 7 }, GrantSkills = ["actives.wx_whip_xiangxi"], Flags = { VsUndeadDmg = 0.14, NightOwl = true, DazeOnHeavyHitPct = 30 }, Summary = "武艺 +4，定力 +7；重击震荡失衡 30%，夜战无视视野惩罚，对尸傀机关总伤 +14%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Bravery = 10, MeleeDefense = 2 }, GrantSkills = ["actives.wx_whip_xiangxi", "perk.fearsome"], Flags = { VsUndeadDmg = 0.18, NightOwl = true, DazeOnHeavyHitPct = 45 }, Summary = "武艺 +5，定力 +10，招架 +2；重击震荡失衡 45%，夜战无视视野惩罚，对尸傀机关总伤 +18%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_jiujie_liuxing <- {
	ID = "wx_manual_jiujie_liuxing", Name = "云梦三首流星枷", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Flail"], Icon = "ui/perks/wx_manual_jiujie_liuxing.png",
	Description = "云梦软鞭门重器分支，三颗铜流星锤呼啸砸头，专克举盾铁甲卫士。",
	BasePrice = 2260, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2 }, GrantSkills = ["actives.wx_flail_liuxing"], Flags = { CritHeadBonus = 8, ArmorDmgBonus = 0.10 }, Summary = "武艺 +2；破甲 +10%，击头 +8%；习得「三首流星砸」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 1 }, GrantSkills = ["actives.wx_flail_liuxing"], Flags = { CritHeadBonus = 12, ArmorDmgBonus = 0.16 }, Summary = "武艺 +4，招架 +1；破甲 +16%，击头 +12%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_flail_liuxing", "actives.wx_flail_lash"], Flags = { CritHeadBonus = 15, ArmorDmgBonus = 0.22, DazeOnHeavyHitPct = 40 }, Summary = "武艺 +5，招架 +3；破甲 +22%，击头 +15%，重击震荡失衡 40%；习得「云梦绕盾抽」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_jiujie_panlong_bian <- {
	ID = "wx_manual_jiujie_panlong_bian", Name = "九节金龙软鞭绝谱", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Flail"], Icon = "ui/perks/wx_manual_jiujie_panlong_bian.png",
	Description = "云梦软鞭门镇派绝学：软如灵蛇锁喉封穴，硬如铁锏绕盾碎颅，令刀盾手形同虚设！",
	BasePrice = 4630, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, Initiative = 104 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_flail_panlong"], Flags = { CritHeadBonus = 8, DirectDmgBonus = 0.08 }, Summary = "武艺 +3，招架 +2；穿甲 +8%，击头 +8%；习得「九节金龙抽」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 4 }, GrantSkills = ["actives.wx_flail_panlong", "actives.wx_flail_entangle"], Flags = { CritHeadBonus = 12, DirectDmgBonus = 0.12, AcupointOnCritPct = 35 }, Summary = "武艺 +5，招架 +4；穿甲 +12%，击头 +12%，乘隙/击头封穴 35%；习得「锁喉缠丝劲」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_flail_panlong", "actives.wx_flail_entangle"], Flags = { CritHeadBonus = 15, DirectDmgBonus = 0.15, AcupointOnCritPct = 50, HitChanceBonus = 8 }, Summary = "武艺 +7，招架 +5；穿甲 +15%，近战命中 +8，击头 +15%，乘隙/击头封穴 50%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_wudu_jinshe_bian <- {
	ID = "wx_manual_wudu_jinshe_bian", Name = "金蛇缠魂毒鞭录", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Flail"], Icon = "ui/perks/wx_manual_wudu_jinshe_bian.png",
	Description = "五毒奇门以蛇骨奇铁打造的毒鞭秘录，鞭影噬血染毒、绞缠要穴，中者十死无生。",
	BasePrice = 4660, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, Initiative = 105 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, Initiative = 5 }, GrantSkills = ["actives.wx_flail_jinshe"], Flags = { WuduPoisonPct = 45, BleedOnHitPct = 35 }, Summary = "武艺 +3，身法 +5；伤血割裂流血 35%，伤血染奇毒 45%；习得「金蛇缠魂鞭」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, Initiative = 8, MeleeDefense = 2 }, GrantSkills = ["actives.wx_flail_jinshe", "actives.wx_whip_suohou"], Flags = { WuduPoisonPct = 70, BleedOnHitPct = 50, VsPoisonedHit = 6 }, Summary = "武艺 +5，身法 +8，招架 +2；伤血割裂流血 50%，伤血染奇毒 70%，对中毒目标命中 +6；习得「灵蛇锁喉鞭」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, Initiative = 12, MeleeDefense = 4 }, GrantSkills = ["actives.wx_flail_jinshe", "actives.wx_whip_suohou"], Flags = { WuduPoisonPct = 95, BleedOnHitPct = 65, VsPoisonedHit = 8, DirectDmgBonus = 0.14 }, Summary = "武艺 +7，身法 +12，招架 +4；穿甲 +14%，伤血割裂流血 65%，伤血染奇毒 95%，对中毒目标命中 +8。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shijing_bodao <- {
	ID = "wx_manual_shijing_bodao", Name = "庖丁剔骨小刀术", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Dagger"], Icon = "ui/perks/wx_manual_shijing_bodao.png",
	Description = "市井屠户与外科刀客顺着骨缝下刀的准巧手法，专透皮肉且易致流血。",
	BasePrice = 400, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { BleedOnHitPct = 20 }, Summary = "武艺 +1；伤血割裂流血 20%。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2 }, GrantSkills = [], Flags = { BleedOnHitPct = 30, DirectDmgBonus = 0.05 }, Summary = "武艺 +2；穿甲 +5%，伤血割裂流血 30%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, Initiative = 5 }, GrantSkills = [], Flags = { BleedOnHitPct = 40, DirectDmgBonus = 0.09 }, Summary = "武艺 +3，身法 +5；穿甲 +9%，伤血割裂流血 40%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_anxiang_bici <- {
	ID = "wx_manual_anxiang_bici", Name = "暗巷袖里匕", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Dagger"], Icon = "ui/perks/wx_manual_anxiang_bici.png",
	Description = "黑道泼皮藏于袖中冷不防捅腰眼的阴损短刀，合围背刺准头奇毒。",
	BasePrice = 370, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 1, Initiative = 3 }, GrantSkills = [], Flags = { SurroundHitBonus = 2 }, Summary = "武艺 +1，身法 +3；合围每名友军 +2 命中。" },
		{ ExpNeeded = 80, Stats = { MeleeSkill = 2, Initiative = 5 }, GrantSkills = [], Flags = { SurroundHitBonus = 4, FirstRoundHit = 4 }, Summary = "武艺 +2，身法 +5；首轮命中 +4，合围每名友军 +4 命中。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, Initiative = 7 }, GrantSkills = [], Flags = { SurroundHitBonus = 5, FirstRoundHit = 8 }, Summary = "武艺 +3，身法 +7；首轮命中 +8，合围每名友军 +5 命中。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_kuaiji_yuchang_ci <- {
	ID = "wx_manual_kuaiji_yuchang_ci", Name = "会稽鱼肠透甲刺", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Dagger"], Icon = "ui/perks/wx_manual_kuaiji_yuchang_ci.png",
	Description = "会稽鱼肠剑庐镇庐短匕术，寸短寸险，挑筋断脉并直透重甲心窝！",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 66, Initiative = 98 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, Initiative = 4 }, GrantSkills = ["actives.wx_dagger_vital"], Flags = { DirectDmgBonus = 0.06 }, Summary = "武艺 +2，身法 +4；习得「分水断脉刺」；穿甲 +6%。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, Initiative = 7, MeleeDefense = 1 }, GrantSkills = ["actives.wx_dagger_vital"], Flags = { DirectDmgBonus = 0.10, WeaponQiDiscount = 0.14 }, Summary = "武艺 +4，身法 +7，招架 +1；招式耗气 -14%，穿甲 +10%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, Initiative = 10, MeleeDefense = 3 }, GrantSkills = ["actives.wx_dagger_vital", "actives.wx_dagger_fuxue"], Flags = { DirectDmgBonus = 0.14, WeaponQiDiscount = 0.20, ExposeOnHitPct = 35 }, Summary = "武艺 +5，身法 +10，招架 +3；招式耗气 -20%，穿甲 +14%，普攻寻隙留破绽 35%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_loulan_fenjin_ci <- {
	ID = "wx_manual_loulan_fenjin_ci", Name = "摸金分水蛾眉刺", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Dagger"], Icon = "ui/perks/wx_manual_loulan_fenjin_ci.png",
	Description = "楼兰摸金商会在狭窄墓道贴身搏杀的奇门双刺，夜战精准、卸甲破邪。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64, Initiative = 96 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_dagger_vital"], Flags = { NightOwl = true }, Summary = "武艺 +2，招架 +1；夜战无视视野惩罚；习得「分水断脉刺」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_dagger_vital"], Flags = { NightOwl = true, VsUndeadDmg = 0.10, DirectDmgBonus = 0.08 }, Summary = "武艺 +4，招架 +2；穿甲 +8%，夜战无视视野惩罚，对尸傀机关总伤 +10%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_dagger_vital", "actives.wx_dagger_zhuanzhu"], Flags = { NightOwl = true, VsUndeadDmg = 0.16, DirectDmgBonus = 0.12 }, Summary = "武艺 +5，招架 +3；穿甲 +12%，夜战无视视野惩罚，对尸傀机关总伤 +16%；习得「鱼肠弑王刺」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_mingzun_shenghuoling <- {
	ID = "wx_manual_mingzun_shenghuoling", Name = "圣火奇令短刃法", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Dagger"], Icon = "ui/perks/wx_manual_mingzun_shenghuoling.png",
	Description = "西域圣火明尊教使者将玄铁短令作匕首施展的诡异武学，磕碰之间令对手头晕失衡。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65, Initiative = 98 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_dagger_shenghuo"], Flags = { InflictOffBalancePct = 25 }, Summary = "武艺 +2，招架 +1；招式致失衡 25%；习得「圣火奇令刺」。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_dagger_shenghuo"], Flags = { InflictOffBalancePct = 40, FirstRoundInit = 12 }, Summary = "武艺 +4，招架 +2；首轮身法 +12，招式致失衡 40%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_dagger_shenghuo", "actives.wx_dagger_execute"], Flags = { InflictOffBalancePct = 55, FirstRoundInit = 18 }, Summary = "武艺 +5，招架 +3；首轮身法 +18，招式致失衡 55%；习得「追魂透骨刺」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_kuaiji_zhuanzhu <- {
	ID = "wx_manual_kuaiji_zhuanzhu", Name = "鱼肠裂甲弑王匕", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Dagger"], Icon = "ui/perks/wx_manual_kuaiji_zhuanzhu.png",
	Description = "会稽鱼肠剑庐至高短兵绝学：专为万军丛中刺杀披甲统帅而生，透甲封穴一击毙命！",
	BasePrice = 4630, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 80, Initiative = 108 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_dagger_zhuanzhu"], Flags = { DirectDmgBonus = 0.08, ExecuteLowHpDmg = 0.10 }, Summary = "武艺 +3，招架 +2「追魂透骨刺」；穿甲 +8%，对半血残敌伤害 +10%；习得「鱼肠弑王刺」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 4 }, GrantSkills = ["actives.wx_dagger_zhuanzhu", "actives.wx_dagger_fuxue"], Flags = { DirectDmgBonus = 0.12, ExecuteLowHpDmg = 0.15, AcupointOnCritPct = 35 }, Summary = "武艺 +5，招架 +4；穿甲 +12%，对半血残敌伤害 +15%，乘隙/击头封穴 35%；习得「透骨分筋刺」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_dagger_zhuanzhu", "actives.wx_dagger_fuxue"], Flags = { DirectDmgBonus = 0.15, ExecuteLowHpDmg = 0.20, AcupointOnCritPct = 50, WeaponQiDiscount = 0.20 }, Summary = "武艺 +7，招架 +5；招式耗气 -20%，穿甲 +15%，对半血残敌伤害 +20%，乘隙/击头封穴 50%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_qingcheng_yingci <- {
	ID = "wx_manual_qingcheng_yingci", Name = "幽谷无影鬼刺录", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Dagger"], Icon = "ui/perks/wx_manual_qingcheng_yingci.png",
	Description = "青城幽谷观暗堂刺杀秘传，起手电光石火，斩敌之后借势腾跃再取一人。",
	BasePrice = 4570, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, Initiative = 110 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 3, Initiative = 6 }, GrantSkills = ["actives.wx_dagger_yingci"], Flags = { FirstRoundInit = 15, FirstRoundHit = 8 }, Summary = "武艺 +3，身法 +6；首轮身法 +15，首轮命中 +8；习得「无影鬼刺杀」。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, Initiative = 10, MeleeDefense = 2 }, GrantSkills = ["actives.wx_dagger_yingci", "actives.wx_dagger_execute"], Flags = { FirstRoundInit = 20, FirstRoundHit = 10, OnKillAPRefund = 2 }, Summary = "武艺 +5，身法 +10，招架 +2；首轮身法 +20，首轮命中 +10，每回合首杀返 +2 AP；习得「追魂透骨刺」。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, Initiative = 14, MeleeDefense = 4 }, GrantSkills = ["actives.wx_dagger_yingci", "actives.wx_dagger_execute"], Flags = { FirstRoundInit = 25, FirstRoundHit = 12, OnKillAPRefund = 3, NightOwl = true }, Summary = "武艺 +7，身法 +14，招架 +4；首轮身法 +25，首轮命中 +12，夜战无视视野惩罚，每回合首杀返 +3 AP。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_jingke_cixin <- {
	ID = "wx_manual_jingke_cixin", Name = "图穷匕见绝杀录", Category = "waigong", Quality = "unique",
	Element = null, WeaponTypes = ["Dagger"], Icon = "ui/perks/wx_manual_jingke_cixin.png",
	Description = "先秦刺客列传失传孤本：三步之内王侯喋血，极境透甲配合残血处决令重甲首领瞬息授首！",
	BasePrice = 11860, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 90, Initiative = 116 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_dagger_zhuanzhu"], Flags = { DirectDmgBonus = 0.10, HitChanceBonus = 6 }, Summary = "武艺 +4，招架 +2「追魂透骨刺」；穿甲 +10%，近战命中 +6；习得「鱼肠弑王刺」。" },
		{ ExpNeeded = 320, Stats = { MeleeSkill = 7, MeleeDefense = 4 }, GrantSkills = ["actives.wx_dagger_zhuanzhu", "actives.wx_dagger_yingci"], Flags = { DirectDmgBonus = 0.15, HitChanceBonus = 9, ExecuteLowHpDmg = 0.15 }, Summary = "武艺 +7，招架 +4；穿甲 +15%，对半血残敌伤害 +15%，近战命中 +9；习得「无影鬼刺杀」。" },
		{ ExpNeeded = 800, Stats = { MeleeSkill = 10, MeleeDefense = 6 }, GrantSkills = ["actives.wx_dagger_zhuanzhu", "actives.wx_dagger_yingci", "actives.wx_dagger_jingke"], Flags = { DirectDmgBonus = 0.20, HitChanceBonus = 12, ExecuteLowHpDmg = 0.20, OnKillAPRefund = 3 }, Summary = "武艺 +10，招架 +6；穿甲 +20%，对半血残敌伤害 +20%，近战命中 +12，每回合首杀返 +3 AP；习得「图穷匕见刺」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shanlin_liegong <- {
	ID = "wx_manual_shanlin_liegong", Name = "猎户穿林射谱", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Bow"], Icon = "ui/perks/wx_manual_shanlin_liegong.png",
	Description = "深山猎户追踪獐鹿飞禽的步弓口诀，远射心稳、善射咽喉。",
	BasePrice = 340, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 1 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.08 }, Summary = "射艺 +1；招式耗气 -8%。" },
		{ ExpNeeded = 80, Stats = { RangedSkill = 2 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.14, LongRangeAccBonus = 3 }, Summary = "射艺 +2；招式耗气 -14%，远距射艺 +3。" },
		{ ExpNeeded = 180, Stats = { RangedSkill = 3, RangedDefense = 2 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.20, LongRangeAccBonus = 5, RangedHeadshotBonus = 5 }, Summary = "射艺 +3，避暗 +2；招式耗气 -20%，远射爆头 +5%，远距射艺 +5。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_junzhong_jin_nu <- {
	ID = "wx_manual_junzhong_jin_nu", Name = "城防神臂弩操", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Crossbow"], Icon = "ui/perks/wx_manual_junzhong_jin_nu.png",
	Description = "官军守城弩手三段轮射操典，弩矢强劲专破重甲前锋。",
	BasePrice = 310, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 1 }, GrantSkills = [], Flags = { ArmorDmgBonus = 0.06 }, Summary = "射艺 +1；破甲 +6%。" },
		{ ExpNeeded = 80, Stats = { RangedSkill = 2 }, GrantSkills = [], Flags = { ArmorDmgBonus = 0.12 }, Summary = "射艺 +2；破甲 +12%。" },
		{ ExpNeeded = 180, Stats = { RangedSkill = 3, RangedDefense = 2 }, GrantSkills = [], Flags = { ArmorDmgBonus = 0.18, UnbrokenArmorBonus = 0.12 }, Summary = "射艺 +3，避暗 +2；破甲 +18%，对厚甲破甲 +12%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_jianghu_feibiao <- {
	ID = "wx_manual_jianghu_feibiao", Name = "甩手金钱镖谱", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Throwing"], Icon = "ui/perks/wx_manual_jianghu_feibiao.png",
	Description = "镖局趟子手与走方武师防身的铜钱梭镖手法，近距甩手快准。",
	BasePrice = 370, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 1 }, GrantSkills = [], Flags = { CloseRangeShotBonus = 4 }, Summary = "射艺 +1；近距快射命中 +4。" },
		{ ExpNeeded = 80, Stats = { RangedSkill = 2 }, GrantSkills = [], Flags = { CloseRangeShotBonus = 7, ThrowingDmgBonus = 0.08 }, Summary = "射艺 +2；近距快射命中 +7，暗器伤害 +8%。" },
		{ ExpNeeded = 180, Stats = { RangedSkill = 3, RangedDefense = 2 }, GrantSkills = [], Flags = { CloseRangeShotBonus = 10, ThrowingDmgBonus = 0.15 }, Summary = "射艺 +3，避暗 +2；近距快射命中 +10，暗器伤害 +15%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_bianzhen_huochong <- {
	ID = "wx_manual_bianzhen_huochong", Name = "边镇三眼铳操", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Firearm", "Crossbow"], Icon = "ui/perks/wx_manual_bianzhen_huochong.png",
	Description = "边镇墩台戍卒施放三眼火铳与轻弩的操法，贴脸齐射声威骇人。",
	BasePrice = 310, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 1, Bravery = 2 }, GrantSkills = [], Flags = { CloseRangeShotBonus = 4 }, Summary = "射艺 +1，定力 +2；近距快射命中 +4。" },
		{ ExpNeeded = 80, Stats = { RangedSkill = 2, Bravery = 4 }, GrantSkills = [], Flags = { CloseRangeShotBonus = 7, FirearmDazePct = 15 }, Summary = "射艺 +2，定力 +4；近距快射命中 +7，火铳劲弩震慑失衡 15%。" },
		{ ExpNeeded = 180, Stats = { RangedSkill = 3, Bravery = 6 }, GrantSkills = [], Flags = { CloseRangeShotBonus = 10, FirearmDazePct = 25 }, Summary = "射艺 +3，定力 +6；近距快射命中 +10，火铳劲弩震慑失衡 25%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_baima_lianzhugong <- {
	ID = "wx_manual_baima_lianzhugong", Name = "白马连珠羽箭谱", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Bow"], Icon = "ui/perks/wx_manual_baima_lianzhugong.png",
	Description = "白马义从营神弓手百步穿杨秘谱：解锁「流星追月箭」，远距狙杀直取敌酋首级！",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { RangedSkill = 68 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 2, RangedDefense = 1 }, GrantSkills = ["actives.wx_bow_snipe"], Flags = { LongRangeAccBonus = 4 }, Summary = "射艺 +2，避暗 +1；习得「流星追月箭」；远距射艺 +4。" },
		{ ExpNeeded = 160, Stats = { RangedSkill = 4, RangedDefense = 2 }, GrantSkills = ["actives.wx_bow_snipe"], Flags = { LongRangeAccBonus = 6, RangedHeadshotBonus = 6 }, Summary = "射艺 +4，避暗 +2；远射爆头 +6%，远距射艺 +6。" },
		{ ExpNeeded = 360, Stats = { RangedSkill = 5, RangedDefense = 3 }, GrantSkills = ["actives.wx_bow_snipe", "actives.wx_bow_liuxing"], Flags = { LongRangeAccBonus = 8, RangedHeadshotBonus = 12, DirectDmgBonus = 0.10 }, Summary = "射艺 +5，避暗 +3；穿甲 +10%，远射爆头 +12%，远距射艺 +8。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_mobei_diaoling_gong <- {
	ID = "wx_manual_mobei_diaoling_gong", Name = "漠北射雕铁胎弓", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Bow"], Icon = "ui/perks/wx_manual_mobei_diaoling_gong.png",
	Description = "漠北苍狼部神射手拉开三石牛角强弓的绝艺，箭大力沉撕裂血肉，专杀伤残逃敌。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { RangedSkill = 68, Stamina = 95 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 2 }, GrantSkills = ["actives.wx_bow_yanxing"], Flags = { BleedOnHitPct = 25, ArmorDmgBonus = 0.10 }, Summary = "射艺 +2；破甲 +10%，伤血割裂流血 25%；习得「苍狼追魂箭」。" },
		{ ExpNeeded = 160, Stats = { RangedSkill = 4, RangedDefense = 1 }, GrantSkills = ["actives.wx_bow_yanxing"], Flags = { BleedOnHitPct = 40, ArmorDmgBonus = 0.16, ExecuteLowHpDmg = 0.10 }, Summary = "射艺 +4，避暗 +1；破甲 +16%，对半血残敌伤害 +10%，伤血割裂流血 40%。" },
		{ ExpNeeded = 360, Stats = { RangedSkill = 5, RangedDefense = 2 }, GrantSkills = ["actives.wx_bow_yanxing", "actives.wx_bow_snipe"], Flags = { BleedOnHitPct = 55, ArmorDmgBonus = 0.22, ExecuteLowHpDmg = 0.16 }, Summary = "射艺 +5，避暗 +2；破甲 +22%，对半血残敌伤害 +16%，伤血割裂流血 55%；习得「流星追月箭」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_wuyi_chuanlin_jian <- {
	ID = "wx_manual_wuyi_chuanlin_jian", Name = "武夷落叶追风箭", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Bow", "Crossbow"], Icon = "ui/perks/wx_manual_wuyi_chuanlin_jian.png",
	Description = "武夷碧水轩林间游射谱，箭矢穿过枝叶专破高闪避轻装客，并与前排默契掩射。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { RangedSkill = 66 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 2, Initiative = 4 }, GrantSkills = [], Flags = { SupportShotChance = 40, FirstRoundInit = 8 }, Summary = "射艺 +2，身法 +4；掩射留破绽 40%，首轮身法 +8。" },
		{ ExpNeeded = 160, Stats = { RangedSkill = 4, Initiative = 7, RangedDefense = 2 }, GrantSkills = [], Flags = { SupportShotChance = 70, IgnoreDodgeHalf = true }, Summary = "射艺 +4，身法 +7，避暗 +2；破除敌方半数身法闪避，掩射留破绽 70%。" },
		{ ExpNeeded = 360, Stats = { RangedSkill = 5, Initiative = 10, RangedDefense = 3 }, GrantSkills = ["actives.wx_bow_snipe", "actives.wx_crossbow_shenji"], Flags = { SupportShotChance = 100, IgnoreDodgeHalf = true }, Summary = "射艺 +5，身法 +10，避暗 +3；习得「流星追月箭」；破除敌方半数身法闪避，掩射留破绽 100%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_tangmen_liannu <- {
	ID = "wx_manual_tangmen_liannu", Name = "唐门追魂机括弩", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Crossbow"], Icon = "ui/perks/wx_manual_tangmen_liannu.png",
	Description = "蜀中唐家堡精钢机括劲弩谱，弩箭喂毒穿甲，夜战暗算百发百中。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { RangedSkill = 66 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 2, Initiative = 4 }, GrantSkills = ["actives.wx_crossbow_liannu"], Flags = { DirectDmgBonus = 0.06, WuduPoisonPct = 30 }, Summary = "射艺 +2，身法 +4；穿甲 +6%，伤血染奇毒 30%；习得「唐门连珠矢」。" },
		{ ExpNeeded = 160, Stats = { RangedSkill = 4, Initiative = 7 }, GrantSkills = ["actives.wx_crossbow_liannu"], Flags = { DirectDmgBonus = 0.10, WuduPoisonPct = 55, NightOwl = true }, Summary = "射艺 +4，身法 +7；穿甲 +10%，夜战无视视野惩罚，伤血染奇毒 55%。" },
		{ ExpNeeded = 360, Stats = { RangedSkill = 5, Initiative = 10, RangedDefense = 3 }, GrantSkills = ["actives.wx_crossbow_liannu", "actives.wx_crossbow_shenji"], Flags = { DirectDmgBonus = 0.15, WuduPoisonPct = 80, NightOwl = true, RangedHeadshotBonus = 10 }, Summary = "射艺 +5，身法 +10，避暗 +3；穿甲 +15%，远射爆头 +10%，夜战无视视野惩罚，伤血染奇毒 80%；习得「神机透甲矢」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_tangmen_mantian <- {
	ID = "wx_manual_tangmen_mantian", Name = "唐门子母飞刀谱", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Throwing"], Icon = "ui/perks/wx_manual_tangmen_mantian.png",
	Description = "蜀中唐家堡成名暗器手法，子母双刃一虚一实，可使「漫天花雨」扇面压制敌阵！",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { RangedSkill = 66, Initiative = 96 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 2, Initiative = 4 }, GrantSkills = ["actives.wx_throw_liuyedao"], Flags = { ThrowingDmgBonus = 0.12 }, Summary = "射艺 +2，身法 +4；暗器伤害 +12%；习得「寒星追命镖」。" },
		{ ExpNeeded = 160, Stats = { RangedSkill = 4, Initiative = 7 }, GrantSkills = ["actives.wx_throw_liuyedao"], Flags = { ThrowingDmgBonus = 0.18, QuickHands = true }, Summary = "射艺 +4，身法 +7；暗器伤害 +18%，每回合首次换装免耗点。" },
		{ ExpNeeded = 360, Stats = { RangedSkill = 5, Initiative = 10, RangedDefense = 2 }, GrantSkills = ["actives.wx_throw_liuyedao", "actives.wx_throw_duzhen"], Flags = { ThrowingDmgBonus = 0.25, QuickHands = true, CloseRangeShotBonus = 8 }, Summary = "射艺 +5，身法 +10，避暗 +2；近距快射命中 +8，暗器伤害 +25%，每回合首次换装免耗点；习得「五毒丧门钉」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_wudu_chuijian <- {
	ID = "wx_manual_wudu_chuijian", Name = "五毒含沙吹箭术", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Throwing", "Bow"], Icon = "ui/perks/wx_manual_wudu_chuijian.png",
	Description = "南疆五毒奇门密林伏击秘术，细管毒针无声无息，见血即染瘴毒并封锁破绽。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { RangedSkill = 65 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 2, RangedDefense = 1 }, GrantSkills = ["actives.wx_throwing_rain"], Flags = { WuduPoisonPct = 40 }, Summary = "射艺 +2，避暗 +1；习得「暴雨毒针」；伤血染奇毒 40%。" },
		{ ExpNeeded = 160, Stats = { RangedSkill = 4, RangedDefense = 2 }, GrantSkills = ["actives.wx_throwing_rain"], Flags = { WuduPoisonPct = 65, VsPoisonedHit = 5 }, Summary = "射艺 +4，避暗 +2；伤血染奇毒 65%，对中毒目标命中 +5。" },
		{ ExpNeeded = 360, Stats = { RangedSkill = 5, RangedDefense = 3 }, GrantSkills = ["actives.wx_throwing_rain", "actives.wx_smoke_cast"], Flags = { WuduPoisonPct = 90, VsPoisonedHit = 8, ExposeOnHitPct = 35 }, Summary = "射艺 +5，避暗 +3；习得「掷烟蔽目」；普攻寻隙留破绽 35%，伤血染奇毒 90%，对中毒目标命中 +8。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shazhou_leihuo_chong <- {
	ID = "wx_manual_shazhou_leihuo_chong", Name = "西域红夷迅雷铳", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Firearm", "Crossbow"], Icon = "ui/perks/wx_manual_shazhou_leihuo_chong.png",
	Description = "沙州驼铃商帮重金聘请西域火器匠师编练的排铳术，近距轰击碎甲摄魂！",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { RangedSkill = 65 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 2 }, GrantSkills = ["actives.wx_gun_leihuo"], Flags = { CloseRangeShotBonus = 6, UnbrokenArmorBonus = 0.10 }, Summary = "射艺 +2；对厚甲破甲 +10%，近距快射命中 +6；习得「沙州雷火铳」。" },
		{ ExpNeeded = 160, Stats = { RangedSkill = 4, Bravery = 4 }, GrantSkills = ["actives.wx_gun_leihuo"], Flags = { CloseRangeShotBonus = 9, UnbrokenArmorBonus = 0.18, FirearmDazePct = 40 }, Summary = "射艺 +4，定力 +4；对厚甲破甲 +18%，近距快射命中 +9，火铳劲弩震慑失衡 40%。" },
		{ ExpNeeded = 360, Stats = { RangedSkill = 5, Bravery = 8, RangedDefense = 2 }, GrantSkills = ["actives.wx_gun_leihuo", "perk.fearsome"], Flags = { CloseRangeShotBonus = 12, UnbrokenArmorBonus = 0.25, FirearmDazePct = 65 }, Summary = "射艺 +5，定力 +8，避暗 +2；对厚甲破甲 +25%，近距快射命中 +12，火铳劲弩震慑失衡 65%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_baima_luori_jian <- {
	ID = "wx_manual_baima_luori_jian", Name = "九星贯日神射经", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Bow"], Icon = "ui/perks/wx_manual_baima_luori_jian.png",
	Description = "军中箭神不传秘经：开弓如满月、箭去似流星，超远距狙杀洞穿重盔且破尽轻功闪避！",
	BasePrice = 4630, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { RangedSkill = 82 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 3, RangedDefense = 2 }, GrantSkills = ["actives.wx_bow_jiuxing"], Flags = { LongRangeAccBonus = 5, DirectDmgBonus = 0.08 }, Summary = "射艺 +3，避暗 +2；穿甲 +8%，远距射艺 +5；习得「九星贯日箭」。" },
		{ ExpNeeded = 250, Stats = { RangedSkill = 5, RangedDefense = 3 }, GrantSkills = ["actives.wx_bow_jiuxing"], Flags = { LongRangeAccBonus = 7, DirectDmgBonus = 0.12, RangedHeadshotBonus = 10 }, Summary = "射艺 +5，避暗 +3；穿甲 +12%，远射爆头 +10%，远距射艺 +7。" },
		{ ExpNeeded = 600, Stats = { RangedSkill = 7, RangedDefense = 5 }, GrantSkills = ["actives.wx_bow_jiuxing", "actives.wx_bow_liuxing"], Flags = { LongRangeAccBonus = 8, DirectDmgBonus = 0.15, RangedHeadshotBonus = 15, IgnoreDodgeHalf = true }, Summary = "射艺 +7，避暗 +5；穿甲 +15%，远射爆头 +15%，远距射艺 +8，破除敌方半数身法闪避；习得「流星连珠箭」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shenji_huolong <- {
	ID = "wx_manual_shenji_huolong", Name = "神机火龙摧城谱", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Firearm", "Crossbow"], Icon = "ui/perks/wx_manual_shenji_huolong.png",
	Description = "神机火器营压箱底禁宫图谱：火铳重弩齐发如火龙吐珠，成片震懵敌阵并撕碎重甲心防！",
	BasePrice = 4660, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { RangedSkill = 78, Bravery = 55 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 3, RangedDefense = 2 }, GrantSkills = ["actives.wx_gun_leihuo"], Flags = { FirearmDazePct = 45, ArmorDmgBonus = 0.14 }, Summary = "射艺 +3，避暗 +2；破甲 +14%，火铳劲弩震慑失衡 45%；习得「沙州雷火铳」。" },
		{ ExpNeeded = 250, Stats = { RangedSkill = 5, RangedDefense = 3 }, GrantSkills = ["actives.wx_gun_leihuo", "perk.fearsome"], Flags = { FirearmDazePct = 65, ArmorDmgBonus = 0.20, DirectDmgBonus = 0.10 }, Summary = "射艺 +5，避暗 +3；破甲 +20%，穿甲 +10%，火铳劲弩震慑失衡 65%。" },
		{ ExpNeeded = 600, Stats = { RangedSkill = 7, RangedDefense = 5 }, GrantSkills = ["actives.wx_gun_leihuo", "actives.wx_gun_huolong", "perk.fearsome"], Flags = { FirearmDazePct = 85, ArmorDmgBonus = 0.25, DirectDmgBonus = 0.15, CloseRangeShotBonus = 10 }, Summary = "射艺 +7，避暗 +5；破甲 +25%，穿甲 +15%，近距快射命中 +10，火铳劲弩震慑失衡 85%；习得「神机火龙炮」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_tangmen_guanyin_lei <- {
	ID = "wx_manual_tangmen_guanyin_lei", Name = "唐门天女散花总诀", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Throwing"], Icon = "ui/perks/wx_manual_tangmen_guanyin_lei.png",
	Description = "蜀中唐家堡暗器最高秘传：暴雨毒针单点穿心、漫天花雨群体破绽，十步之内无人近身！",
	BasePrice = 4660, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { RangedSkill = 80, Initiative = 106 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 3, Initiative = 5 }, GrantSkills = ["actives.wx_throw_fan"], Flags = { ThrowingDmgBonus = 0.18, QuickHands = true }, Summary = "射艺 +3，身法 +5「暴雨毒针」；暗器伤害 +18%，每回合首次换装免耗点；习得「漫天花雨」。" },
		{ ExpNeeded = 250, Stats = { RangedSkill = 5, Initiative = 8, RangedDefense = 2 }, GrantSkills = ["actives.wx_throw_fan", "actives.wx_throwing_rain"], Flags = { ThrowingDmgBonus = 0.26, QuickHands = true, DirectDmgBonus = 0.10 }, Summary = "射艺 +5，身法 +8，避暗 +2；穿甲 +10%，暗器伤害 +26%，每回合首次换装免耗点；习得「暴雨毒针」。" },
		{ ExpNeeded = 600, Stats = { RangedSkill = 7, Initiative = 12, RangedDefense = 4 }, GrantSkills = ["actives.wx_throw_fan", "actives.wx_throwing_rain", "actives.wx_throw_kongque"], Flags = { ThrowingDmgBonus = 0.35, QuickHands = true, DirectDmgBonus = 0.15, IgnoreDodgeHalf = true }, Summary = "射艺 +7，身法 +12，避暗 +4；大成；穿甲 +15%，暗器伤害 +35%，破除敌方半数身法闪避，每回合首次换装免耗点；习得「孔雀翎绝杀」。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_mobei_langwang_she <- {
	ID = "wx_manual_mobei_langwang_she", Name = "苍狼追魂骑射绝录", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Bow", "Throwing"], Icon = "ui/perks/wx_manual_mobei_langwang_she.png",
	Description = "漠北狼主射杀大漠飞雕的绝顶射术，箭镖双绝，射杀目标瞬间返还步法行动点！",
	BasePrice = 4660, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { RangedSkill = 80, Initiative = 104 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 3, Initiative = 5 }, GrantSkills = ["actives.wx_bow_yanxing"], Flags = { ExecuteLowHpDmg = 0.10, QuickHands = true }, Summary = "射艺 +3，身法 +5；对半血残敌伤害 +10%，每回合首次换装免耗点；习得「苍狼追魂箭」。" },
		{ ExpNeeded = 250, Stats = { RangedSkill = 5, Initiative = 8, RangedDefense = 2 }, GrantSkills = ["actives.wx_bow_yanxing", "actives.wx_bow_jiuxing"], Flags = { ExecuteLowHpDmg = 0.15, QuickHands = true, OnKillAPRefund = 2 }, Summary = "射艺 +5，身法 +8，避暗 +2；对半血残敌伤害 +15%，每回合首次换装免耗点，每回合首杀返 +2 AP；习得「九星贯日箭」。" },
		{ ExpNeeded = 600, Stats = { RangedSkill = 7, Initiative = 12, RangedDefense = 4 }, GrantSkills = ["actives.wx_bow_yanxing", "actives.wx_bow_jiuxing"], Flags = { ExecuteLowHpDmg = 0.20, QuickHands = true, OnKillAPRefund = 3, DirectDmgBonus = 0.14 }, Summary = "射艺 +7，身法 +12，避暗 +4；穿甲 +14%，对半血残敌伤害 +20%，每回合首次换装免耗点，每回合首杀返 +3 AP。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_dahuang_luori <- {
	ID = "wx_manual_dahuang_luori", Name = "大荒落日神弓经", Category = "waigong", Quality = "unique",
	Element = null, WeaponTypes = ["Bow", "Crossbow"], Icon = "ui/perks/wx_manual_dahuang_luori.png",
	Description = "上古射日传说遗留的神射孤本：视百步如咫尺、穿重铠若败革，一箭诛敌立返气劲再开雕弓！",
	BasePrice = 11740, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { RangedSkill = 90, Initiative = 110 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 4, RangedDefense = 2 }, GrantSkills = ["actives.wx_bow_jiuxing"], Flags = { DirectDmgBonus = 0.10, LongRangeAccBonus = 5 }, Summary = "射艺 +4，避暗 +2；穿甲 +10%，远距射艺 +5；习得「九星贯日箭」。" },
		{ ExpNeeded = 320, Stats = { RangedSkill = 7, RangedDefense = 4 }, GrantSkills = ["actives.wx_bow_jiuxing", "actives.wx_bow_snipe"], Flags = { DirectDmgBonus = 0.15, LongRangeAccBonus = 7, RangedHeadshotBonus = 12, IgnoreDodgeHalf = true }, Summary = "射艺 +7，避暗 +4；穿甲 +15%，远射爆头 +12%，远距射艺 +7，破除敌方半数身法闪避；习得「流星追月箭」。" },
		{ ExpNeeded = 800, Stats = { RangedSkill = 10, RangedDefense = 6 }, GrantSkills = ["actives.wx_bow_jiuxing", "actives.wx_bow_snipe", "actives.wx_bow_luori"], Flags = { DirectDmgBonus = 0.20, LongRangeAccBonus = 8, RangedHeadshotBonus = 15, IgnoreDodgeHalf = true, OnKillAPRefund = 3 }, Summary = "射艺 +10，避暗 +6；穿甲 +20%，远射爆头 +15%，远距射艺 +8，破除敌方半数身法闪避，每回合首杀返 +3 AP；习得「大荒落日箭」。" }
	]
};
