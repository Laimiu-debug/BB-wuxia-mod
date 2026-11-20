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

// =========================================================================
// 四、M4.2 低魔志怪生态秘籍（五毒奇门毒功 + 炼体金钟横练绝学 + 九幽镇魂孤本）
// =========================================================================

::Wuxia.Config.Manuals.wx_manual_wudu <- {
	ID = "wx_manual_wudu", Name = "五毒吹影功", Category = "henglian", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_50.png",
	Description = "南疆五毒奇门秘传毒经：兵刃或暗器见血即染奇瘴剧毒（古墓机关与湘西尸傀无效），修至深处自身百毒不侵。",
	BasePrice = 2300, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 95 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Initiative = 4 },                   GrantSkills = [], Flags = { WuduPoisonPct = 35 }, Summary = "身法 +4；攻击造成至少 4 点气血伤时，35% 几率染上奇毒（持续损血散气）。" },
		{ ExpNeeded = 160, Stats = { Initiative = 7, RangedDefense = 2 }, GrantSkills = [], Flags = { WuduPoisonPct = 65, PoisonImmune = true }, Summary = "身法 +7，避暗 +2；染毒几率提至 65%，自身免疫各类蛛毒与奇门暗器毒。" },
		{ ExpNeeded = 360, Stats = { Initiative = 10, RangedDefense = 4 }, GrantSkills = [], Flags = { WuduPoisonPct = 100, PoisonImmune = true, VsPoisonedHit = 6 }, Summary = "身法 +10，避暗 +4；伤血必染奇毒、百毒不侵，攻击已中毒目标命中额外 +6。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_jinzhong <- {
	ID = "wx_manual_jinzhong", Name = "血煞金钟罩", Category = "henglian", Quality = "secret",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_40.png",
	Description = "邪派药人魁首与外家大宗师梦寐以求的护体硬功绝学：凝气成钟覆护重甲，受近身重击时反震敌方兵甲。",
	BasePrice = 4900, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Hitpoints = 80, Stamina = 100 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Hitpoints = 10, Initiative = -6 },              GrantSkills = ["perk.brawny"], Flags = { HeavyArmorScale = 0.04 }, Summary = "气血 +10，身法 -6；披甲行气减重 30%，按头身总护甲减免护甲损伤。" },
		{ ExpNeeded = 250, Stats = { Hitpoints = 15, Bravery = 5, Initiative = -8 }, GrantSkills = ["perk.brawny", "actives.indomitable"], Flags = { HeavyArmorScale = 0.05, InjuryThresholdMult = 1.25 }, Summary = "气血 +15，定力 +5；护甲减伤提至战锻满额，外伤门槛 +25%，习得沉岳硬抗。" },
		{ ExpNeeded = 600, Stats = { Hitpoints = 20, Bravery = 10, Initiative = -10 }, GrantSkills = ["perk.brawny", "actives.indomitable", "perk.steel_brow"], Flags = { HeavyArmorScale = 0.06, InjuryThresholdMult = 1.35, ReflectArmorDmg = 12 }, Summary = "气血 +20，定力 +10；铜头铁额免爆头暴击，护体金钟受近战命中时反震攻击者身甲 12 点！" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zhenhun <- {
	ID = "wx_manual_zhenhun", Name = "九幽镇魂录", Category = "henglian", Quality = "unique",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_27.png",
	Description = "自前朝玄宫秘冢出土的镇邪奇书孤本：心神坚不可摧，出招直慑生人魂魄，且专破古墓机关与湘西尸傀邪气。",
	BasePrice = 11800, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Bravery = 70 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Bravery = 8 },  GrantSkills = [], Flags = { VsUndeadDmg = 0.08 }, Summary = "定力 +8；对古墓机关与湘西尸傀邪祟造成总伤害 +8%。" },
		{ ExpNeeded = 320, Stats = { Bravery = 14 }, GrantSkills = ["perk.fearsome"], Flags = { VsUndeadDmg = 0.12 }, Summary = "定力 +14；破邪总伤 +12%，习得「九幽慑魂」（伤及生人1点气血即触发战意动摇检定）。" },
		{ ExpNeeded = 800, Stats = { Bravery = 20 }, GrantSkills = ["perk.fearsome"], Flags = { VsUndeadDmg = 0.18, AntiFearAura = true }, Summary = "定力 +20；破邪总伤 +18%，自身对抗怨灵惊骇等负面战意检定额外 +15 定力！" }
	]
};

// =========================================================================
// 五、M4.1b 全兵器补完与玄门/玄冰心法（重锤 / 大斧 / 软鞭连枷 / 短匕 / 神机火器）
// =========================================================================

::Wuxia.Config.Manuals.wx_manual_hanshan_chui <- {
	ID = "wx_manual_hanshan_chui", Name = "撼山锤法", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Hammer"], Icon = "ui/perks/perk_44.png",
	Description = "朔方与太行力士惯习的基础重锤套路，沉腰坐马、专砸铁甲。",
	BasePrice = 340, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0,   Stats = { MeleeSkill = 1 },                   GrantSkills = [], Flags = { WeaponQiDiscount = 0.08 }, Summary = "持锤武艺 +1，锤招内息消耗 -8%。" },
		{ ExpNeeded = 80,  Stats = { MeleeSkill = 2 },                   GrantSkills = [], Flags = { WeaponQiDiscount = 0.14, ArmorDmgBonus = 0.08 }, Summary = "持锤武艺 +2，破甲 +8%，锤招消耗 -14%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.20, ArmorDmgBonus = 0.15 }, Summary = "持锤武艺 +3，招架 +2，破甲 +15%，锤招消耗 -20%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zhenyue_chui <- {
	ID = "wx_manual_zhenyue_chui", Name = "震岳碎甲锤", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Hammer"], Icon = "ui/perks/perk_44.png",
	Description = "太行震岳门镇派重锤法，锤出如山崩石裂，隔着百炼重甲亦能震碎五脏。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65, Stamina = 100 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_hammer_shatter"], Flags = { ArmorDmgBonus = 0.12 }, Summary = "武艺 +2，招架 +1，破甲 +12%；解锁「震岳碎甲击」（高破甲保底震伤致失衡）。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_hammer_shatter"], Flags = { ArmorDmgBonus = 0.18, DirectDmgBonus = 0.06 }, Summary = "武艺 +4，招架 +2；破甲 +18%，穿甲 +6%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_hammer_shatter"], Flags = { ArmorDmgBonus = 0.25, DirectDmgBonus = 0.12 }, Summary = "武艺 +5，招架 +3；破甲 +25%，穿甲 +12%，专克重甲铁卫与金甲古墓卫。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_kaishan_fu <- {
	ID = "wx_manual_kaishan_fu", Name = "开山斧法", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Axe"], Icon = "ui/perks/perk_43.png",
	Description = "关外樵客与绿林前锋常用的劈砍斧式，势大力沉、易伤头颅。",
	BasePrice = 340, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0,   Stats = { MeleeSkill = 1 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.08 }, Summary = "持斧武艺 +1，斧招内息消耗 -8%。" },
		{ ExpNeeded = 80,  Stats = { MeleeSkill = 2 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.14, CritHeadBonus = 5 }, Summary = "持斧武艺 +2，击头几率 +5%，斧招消耗 -14%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.20, CritHeadBonus = 10 }, Summary = "持斧武艺 +3，击头几率 +10%，斧招消耗 -20%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_pishan_fu <- {
	ID = "wx_manual_pishan_fu", Name = "劈山断门斧", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Axe"], Icon = "ui/perks/perk_43.png",
	Description = "辽东劈山盟刚猛斧法，遇盾碎盾、无盾断门，专破刀盾龟缩阵线。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 65 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { MeleeSkill = 2 }, GrantSkills = ["actives.wx_axe_split"], Flags = { ArmorDmgBonus = 0.10, CritHeadBonus = 5 }, Summary = "武艺 +2，破甲 +10%；解锁「力劈华山」（持盾碎盾、无盾增伤留破绽）。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4 }, GrantSkills = ["actives.wx_axe_split"], Flags = { ArmorDmgBonus = 0.18, CritHeadBonus = 8 }, Summary = "武艺 +4；破甲 +18%，击头几率 +8%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 2 }, GrantSkills = ["actives.wx_axe_split"], Flags = { ArmorDmgBonus = 0.25, CritHeadBonus = 12 }, Summary = "武艺 +5，招架 +2；破甲 +25%，击头几率 +12%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_chansi_bian <- {
	ID = "wx_manual_chansi_bian", Name = "缠丝软鞭谱", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Flail"], Icon = "ui/perks/perk_42.png",
	Description = "云梦软鞭门奇门鞭枷谱：流星锤与九节鞭诡谲拐弯，专绕盾牌死角猛抽面门。",
	BasePrice = 2150, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { MeleeSkill = 64 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { MeleeSkill = 2, MeleeDefense = 1 }, GrantSkills = ["actives.wx_flail_lash"], Flags = { CritHeadBonus = 6, WeaponQiDiscount = 0.10 }, Summary = "武艺 +2，招架 +1；解锁「云梦绕盾抽」（无视盾防、高击头致失衡）。" },
		{ ExpNeeded = 160, Stats = { MeleeSkill = 4, MeleeDefense = 2 }, GrantSkills = ["actives.wx_flail_lash"], Flags = { CritHeadBonus = 10, WeaponQiDiscount = 0.15 }, Summary = "武艺 +4，招架 +2；击头几率 +10%，鞭枷消耗 -15%。" },
		{ ExpNeeded = 360, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_flail_lash"], Flags = { CritHeadBonus = 15, WeaponQiDiscount = 0.20, DirectDmgBonus = 0.10 }, Summary = "武艺 +5，招架 +3；击头 +15%，穿甲 +10%，鞭枷消耗 -20%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_fenshui_ci <- {
	ID = "wx_manual_fenshui_ci", Name = "分水透骨刺", Category = "waigong", Quality = "common",
	Element = null, WeaponTypes = ["Dagger"], Icon = "ui/perks/perk_51.png",
	Description = "江淮水寨与夜行人惯使的贴身短匕刺法，出手狠快，专寻甲叶缝隙。",
	BasePrice = 350, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0,   Stats = { MeleeSkill = 1, Initiative = 3 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.08 }, Summary = "持匕武艺 +1，身法 +3，短刃消耗 -8%。" },
		{ ExpNeeded = 80,  Stats = { MeleeSkill = 2, Initiative = 5 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.14 }, Summary = "持匕武艺 +2，身法 +5，短刃消耗 -14%。" },
		{ ExpNeeded = 180, Stats = { MeleeSkill = 3, Initiative = 8 }, GrantSkills = [], Flags = { WeaponQiDiscount = 0.20, DirectDmgBonus = 0.08 }, Summary = "持匕武艺 +3，身法 +8，短刃消耗 -20%，穿甲 +8%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_youming_bi <- {
	ID = "wx_manual_youming_bi", Name = "幽冥绝命匕", Category = "waigong", Quality = "secret",
	Element = null, WeaponTypes = ["Dagger"], Icon = "ui/perks/perk_51.png",
	Description = "幽冥隐杀楼不传刺客绝学：借队友打出的破绽、失衡或点穴窗口欺身透甲，一匕封喉。",
	BasePrice = 4600, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { MeleeSkill = 76, Initiative = 105 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { MeleeSkill = 3, MeleeDefense = 2 }, GrantSkills = ["actives.wx_dagger_execute"], Flags = { DirectDmgBonus = 0.08 }, Summary = "武艺 +3，招架 +2，穿甲 +8%；解锁「追魂透骨刺」（对受制敌高命暴伤处决）。" },
		{ ExpNeeded = 250, Stats = { MeleeSkill = 5, MeleeDefense = 3 }, GrantSkills = ["actives.wx_dagger_execute"], Flags = { DirectDmgBonus = 0.12, HitChanceBonus = 5 }, Summary = "武艺 +5，招架 +3；穿甲 +12%，近战命中 +5%。" },
		{ ExpNeeded = 600, Stats = { MeleeSkill = 7, MeleeDefense = 5 }, GrantSkills = ["actives.wx_dagger_execute"], Flags = { DirectDmgBonus = 0.15, HitChanceBonus = 8, CritHeadBonus = 10 }, Summary = "武艺 +7，招架 +5；穿甲 +15%，命中 +8%，击头 +10%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shenji <- {
	ID = "wx_manual_shenji", Name = "神机火器谱", Category = "waigong", Quality = "sect",
	Element = null, WeaponTypes = ["Firearm", "Crossbow"], Icon = "ui/perks/perk_49.png",
	Description = "神机火器营秘传铅弹火铳与劲弩阵法，轰雷掣电震慑敌阵，令当面之敌魂飞失衡。",
	BasePrice = 2400, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { RangedSkill = 66 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { RangedSkill = 2, RangedDefense = 1 }, GrantSkills = [], Flags = { FirearmDazePct = 30 }, Summary = "射艺 +2，避暗 +1；火铳或劲弩命中时 30% 几率震得目标「失衡」。" },
		{ ExpNeeded = 160, Stats = { RangedSkill = 4, RangedDefense = 2 }, GrantSkills = [], Flags = { FirearmDazePct = 55, ArmorDmgBonus = 0.12 }, Summary = "射艺 +4，避暗 +2；火铳/劲弩震慑失衡率 55%，破甲伤害 +12%。" },
		{ ExpNeeded = 360, Stats = { RangedSkill = 5, RangedDefense = 3 }, GrantSkills = [], Flags = { FirearmDazePct = 80, ArmorDmgBonus = 0.20, DirectDmgBonus = 0.08 }, Summary = "射艺 +5，避暗 +3；火铳/劲弩命中 80% 几率致「失衡」，破甲 +20%，穿甲 +8%。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_taihe <- {
	ID = "wx_manual_taihe", Name = "太和纯阳功", Category = "neigong", Quality = "secret",
	Element = "neutral", WeaponTypes = [], Icon = "ui/perks/perk_21.png",
	Description = "太和玄门镇山道家内功绝学，圆融冲和、全无偏执相克之虞，兼具绵长回气与借力护体真气。",
	BasePrice = 4700, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Bravery = 58, Stamina = 100 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Stamina = 15, Bravery = 6, FatigueRecoveryRate = 2 },  GrantSkills = ["actives.wx_meditate"], Flags = {}, Summary = "内息 +15，定力 +6，每回合回气 +2。" },
		{ ExpNeeded = 250, Stats = { Stamina = 25, Bravery = 12, FatigueRecoveryRate = 4 }, GrantSkills = ["actives.wx_meditate"], Flags = { QiShieldPct = 0.25 }, Summary = "内息 +25，定力 +12，回气 +4；解锁 25% 真气护体。" },
		{ ExpNeeded = 600, Stats = { Stamina = 35, Bravery = 18, FatigueRecoveryRate = 6 }, GrantSkills = ["actives.wx_meditate"], Flags = { QiShieldPct = 0.35, OnDodgeQiRegen = 4, OnDodgeQiCap = 2 }, Summary = "内息 +35，定力 +18，回气 +6；35% 真气护体，近战闪避借力回 4 内息。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_hanbing <- {
	ID = "wx_manual_hanbing", Name = "寒冰护脉诀", Category = "neigong", Quality = "sect",
	Element = "yin", WeaponTypes = [], Icon = "ui/perks/perk_11.png",
	Description = "昆仑玄冰宫阴寒心法，真气凛冽似万年玄冰，大成后近身犯我者必受寒劲反侵。",
	BasePrice = 2000, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Bravery = 48 },
	Levels = [
		{ ExpNeeded = 0,   Stats = { Stamina = 10, Bravery = 4 },  GrantSkills = ["actives.wx_meditate"], Flags = { OnDodgeQiRegen = 2, OnDodgeQiCap = 2 }, Summary = "内息 +10，定力 +4；近战闪避回 2 内息。" },
		{ ExpNeeded = 160, Stats = { Stamina = 18, Bravery = 8 },  GrantSkills = ["actives.wx_meditate"], Flags = { OnDodgeQiRegen = 3, OnDodgeQiCap = 2, QiShieldPct = 0.25 }, Summary = "内息 +18，定力 +8；解锁 25% 玄冰真气护体。" },
		{ ExpNeeded = 360, Stats = { Stamina = 25, Bravery = 12 }, GrantSkills = ["actives.wx_meditate"], Flags = { OnDodgeQiRegen = 4, OnDodgeQiCap = 3, QiShieldPct = 0.30, FrostChillOnHit = true }, Summary = "内息 +25，定力 +12；30% 真气护体，受近战命中时寒劲反侵令攻击者陷入「失衡」！" }
	]
};
