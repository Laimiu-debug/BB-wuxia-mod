// M4 Martial Manuals: Formation/Tactical puzzles, Fodder-salvage common manuals, Duelist/Banner unbinding, and Shaolin Fist line.

// =========================================================================
// 一、战术协同外功（唐家堡弓弩 & 丐帮护阵棒）
// =========================================================================

::Wuxia.Config.Manuals.wx_manual_yanxing <- {
	ID = "wx_manual_yanxing", Name = "雁行掩射谱", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Bow", "Crossbow"], Icon = "ui/perks/perk_02.png",
	Description = "弓手与前排合击。弓箭或弩矢命中与另一名友军相邻的敌人时，有机会打出破绽，使其下一次受击伤害提高 15%。每回合最多触发一次。",
	BasePrice = 2100, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { RangedSkill = 72 },
	Levels = [
		{ ExpNeeded = 0, Stats = { RangedSkill = 2 }, GrantSkills = [], Flags = { SupportShotChance = 35 }, Summary = "射艺 +2，掩射有 35% 几率打出破绽。" },
		{ ExpNeeded = 160, Stats = { RangedSkill = 3 }, GrantSkills = [], Flags = { SupportShotChance = 65 }, Summary = "射艺 +3，掩射有 65% 几率打出破绽。" },
		{ ExpNeeded = 360, Stats = { RangedSkill = 5 }, GrantSkills = [], Flags = { SupportShotChance = 100 }, Summary = "射艺 +5，命中符合条件的目标必定打出破绽。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_huzhen <- {
	ID = "wx_manual_huzhen", Name = "护阵棒法", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Staff"], Icon = "ui/perks/perk_38.png",
	Description = "持木棍、短棒或钉头长棍叫阵，逼迫敌人把注意力转向自己，为同伴撤步争取时间。",
	BasePrice = 1750, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Bravery = 48 },
	Levels = [
		{ ExpNeeded = 0, Stats = { MeleeDefense = 1 }, GrantSkills = ["actives.wx_staff_challenge"], Flags = {}, Summary = "招架 +1，学会「横杖叫阵」，引敌来攻。" },
		{ ExpNeeded = 160, Stats = { MeleeDefense = 2, Bravery = 3 }, GrantSkills = ["actives.wx_staff_challenge"], Flags = {}, Summary = "招架 +2，定力 +3。" },
		{ ExpNeeded = 360, Stats = { MeleeDefense = 3, Bravery = 5 }, GrantSkills = ["actives.wx_staff_challenge"], Flags = { StaffGuard = true }, Summary = "招架 +3，定力 +5。持棒抵消敌方普通包围加成，已学原版抗围攻的角色只计一次。" }
	]
};

// =========================================================================
// 二、施工块 1：低星炮灰救星大路货 + 单手孤锋诀 + 统帅聚义令（横练/杂学）
// =========================================================================

::Wuxia.Config.Manuals.wx_manual_chanzi <- {
	ID = "wx_manual_chanzi", Name = "缠字诀", Category = "henglian", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_32.png",
	Description = "市井散人与趟子手相传的缠斗诀窍：招式落空后顺势摸清敌路叠加命中，群起合围时更具准头，专救根骨平平的底层弟兄。",
	BasePrice = 320, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0,   Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { FastAdaptBonus = 6 }, Summary = "武艺 +1；攻击落空时下次命中叠加 +6（最多 4 层，命中后重置）。" },
		{ ExpNeeded = 80,  Stats = { MeleeSkill = 2 }, GrantSkills = [], Flags = { FastAdaptBonus = 8, SurroundHitBonus = 3 }, Summary = "武艺 +2；落空叠命中提至 +8/层，合围时每多一名友军近战命中额外 +3。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3 }, GrantSkills = [], Flags = { FastAdaptBonus = 10, SurroundHitBonus = 5 }, Summary = "武艺 +3；落空叠命中 +10/层（相当于速应），合围每名友军额外 +5 命中（相当于背刺）。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_guixi <- {
	ID = "wx_manual_guixi", Name = "龟息护脉桩", Category = "henglian", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_07.png",
	Description = "江湖跑滩卖艺与军伍前卒保命的闭气护心桩：每场战斗遭遇致命重创时可锁住一线生机不死。",
	BasePrice = 340, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0,   Stats = { Hitpoints = 4 },             GrantSkills = ["perk.nine_lives"], Flags = { GuixiTier = 1 }, Summary = "气血 +4；每场战斗首次承受致命伤时锁血存活并清除流血，当回合守势大增。" },
		{ ExpNeeded = 80,  Stats = { Hitpoints = 8 },             GrantSkills = ["perk.nine_lives"], Flags = { GuixiTier = 2 }, Summary = "气血 +8；触发龟息保命时同步逼出体内暗器剧毒并稳住失衡。" },
		{ ExpNeeded = 180, Stats = { Hitpoints = 12, Bravery = 4 }, GrantSkills = ["perk.nine_lives"], Flags = { GuixiTier = 3 }, Summary = "气血 +12，定力 +4；触发龟息保命时额外激起残气回复 8 点气血与 10 点内息。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_gufeng <- {
	ID = "wx_manual_gufeng", Name = "孤锋诀", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_41.png",
	Description = "名门剑客与独行刀客不屑持盾的潇洒心诀：主手持单手兵刃且副手悬空时，劲力凝于一点大幅洞穿重甲。",
	BasePrice = 2400, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 68 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Initiative = 3 },                  GrantSkills = [], Flags = { EmptyOffhandPen = 0.10 }, Summary = "身法 +3；单手兵器且副手为空时，穿甲伤害率 +10%。" },
		{ ExpNeeded = 160, Stats = { Initiative = 5, MeleeDefense = 2 }, GrantSkills = [], Flags = { EmptyOffhandPen = 0.18 }, Summary = "身法 +5，招架 +2；单手空副手穿甲伤害率提至 +18%。" },
		{ ExpNeeded = 360, Stats = { Initiative = 8, MeleeDefense = 3 }, GrantSkills = [], Flags = { EmptyOffhandPen = 0.25 }, Summary = "身法 +8，招架 +3；单手空副手穿甲 +25%（与外功自带穿甲合计封顶 +25%，对齐原版决斗家）。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_juyiling <- {
	ID = "wx_manual_juyiling", Name = "聚义令", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_28.png",
	Description = "总镖头与帮派龙头统御群豪的号令法门：无需弃剑扛旗，凭自身定力即可镇住四方同伴心神、喝退邪祟恐惧。",
	BasePrice = 2300, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Bravery = 55 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Bravery = 5 },  GrantSkills = ["actives.wx_rally_command"], Flags = { CommandAuraPct = 0.05 }, Summary = "定力 +5；解锁主动技「聚义号令」稳固军心；4 格内友军享自身 5% 定力光环。" },
		{ ExpNeeded = 160, Stats = { Bravery = 10 }, GrantSkills = ["actives.wx_rally_command"], Flags = { CommandAuraPct = 0.08, RallyBonus = 10 }, Summary = "定力 +10；4 格定力光环提至 8%，「聚义号令」重整战意检定额外 +10。" },
		{ ExpNeeded = 360, Stats = { Bravery = 15 }, GrantSkills = ["actives.wx_rally_command"], Flags = { CommandAuraPct = 0.10, RallyBonus = 20 }, Summary = "定力 +15；4 格友军享自身 10% 定力光环（对齐战旗且不与战旗叠算），「聚义号令」检定额外 +20。" }
	]
};

// =========================================================================
// 三、施工块 2：少室禅院与成对拳套外功线（Fist 钝劲内伤/震慑/点穴/夺刃）
// =========================================================================

::Wuxia.Config.Manuals.wx_manual_luohan <- {
	ID = "wx_manual_luohan", Name = "罗汉散手", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/perk_13.png",
	Description = "禅门外院与市井拳师常见的护身拳脚，架势严整、发力省气。",
	BasePrice = 340, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0,   Stats = { MeleeSkill = 1 },                   GrantSkills = [], Flags = { WeaponQiDiscount = 0.08 }, Summary = "佩护手武艺 +1，拳掌招式内息消耗 -8%。" },
		{ ExpNeeded = 80,  Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.14 }, Summary = "佩护手武艺 +2，招架 +1，拳掌招式消耗 -14%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.20, DirectDmgBonus = 0.05 }, Summary = "佩护手武艺 +3，招架 +2，拳掌消耗 -20%，穿甲 +5%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_jingang <- {
	ID = "wx_manual_jingang", Name = "大金刚掌", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/perk_15.png",
	Description = "少室禅院护法刚猛掌法，掌力隔甲震腑、损耗敌方真气，大成后一掌可震晕铁甲悍敌。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65, Stamina = 95 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { MeleeSkill = 2 },                   GrantSkills = ["actives.wx_fist_jingang"], Flags = { ArmorDmgBonus = 0.10 }, Summary = "武艺 +2，破甲 +10%；解锁「金刚摧心掌」（透甲震气致失衡）。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_fist_jingang"], Flags = { ArmorDmgBonus = 0.18, DirectDmgBonus = 0.08 }, Summary = "武艺 +4，招架 +2；破甲 +18%，穿甲 +8%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_fist_jingang"], Flags = { ArmorDmgBonus = 0.25, DirectDmgBonus = 0.12, JingangStunPct = 50 }, Summary = "武艺 +5，招架 +3；破甲 +25%，穿甲 +12%，「金刚摧心掌」命中 50% 几率震晕对手！" }
	]
};

::Wuxia.Config.Manuals.wx_manual_nianhua <- {
	ID = "wx_manual_nianhua", Name = "拈花擒拿手", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Fist"], Icon = "ui/perks/perk_51.png",
	Description = "禅宗上乘指穴与分筋错骨绝技，点穴截脉、空手入白刃，令重兵猛将有刃难施。",
	BasePrice = 4600, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 78, Initiative = 100 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_fist_acupoint"], Flags = {}, Summary = "武艺 +3，招架 +2；解锁「拈花点穴指」（高准头封穴减回气）。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_fist_acupoint", "actives.wx_fist_disarm"], Flags = { DirectDmgBonus = 0.10 }, Summary = "武艺 +5，招架 +3，穿甲 +10%；解锁绝技「空手夺白刃」（卸除敌方主手兵器 1 回合）。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_fist_acupoint", "actives.wx_fist_disarm"], Flags = { DirectDmgBonus = 0.15, HitChanceBonus = 8, DisarmHitBonus = 10 }, Summary = "武艺 +7，招架 +5，穿甲 +15%，近战命中 +8%，「空手夺白刃」额外 +10 命中！" }
	]
};
