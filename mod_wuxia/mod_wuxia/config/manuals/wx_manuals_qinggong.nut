// Expanded Qinggong Manual Library (Regional Footwork & Agility Arts)
// Auto-audited against AGENTS.md stat & non-stacking redlines.

::Wuxia.Config.Manuals.wx_manual_shanlin_bu <- {
	ID = "wx_manual_shanlin_bu", Name = "穿林跃涧步", Category = "qinggong", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_23.png",
	Description = "巴蜀山民与猎户攀藤越涧的轻快步法，林地高坡往来省力。",
	BasePrice = 370, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 5 }, GrantSkills = [], Flags = { ElevationDiscount = true }, Summary = "身法 +5；高低坡行动点 -1。" },
		{ ExpNeeded = 80, Stats = { Initiative = 8 }, GrantSkills = [], Flags = { ElevationDiscount = true, TerrainCostHalved = true }, Summary = "身法 +8；复杂地形减耗，高低坡行动点 -1。" },
		{ ExpNeeded = 180, Stats = { Initiative = 12 }, GrantSkills = [], Flags = { ElevationDiscount = true, TerrainCostHalved = true, FirstRoundInit = 6 }, Summary = "身法 +12；首轮身法 +6，复杂地形减耗，高低坡行动点 -1。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shuishang_piao <- {
	ID = "wx_manual_shuishang_piao", Name = "芦苇踏浪步", Category = "qinggong", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_01.png",
	Description = "江淮水寇在泥沼船舷间练就的滑溜步子，沼泽浅滩不陷脚。",
	BasePrice = 400, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 5 }, GrantSkills = [], Flags = { TerrainCostHalved = true }, Summary = "身法 +5；复杂地形减耗。" },
		{ ExpNeeded = 80, Stats = { Initiative = 8, RangedDefense = 1 }, GrantSkills = [], Flags = { TerrainCostHalved = true }, Summary = "身法 +8，避暗 +1；复杂地形减耗。" },
		{ ExpNeeded = 180, Stats = { Initiative = 12, RangedDefense = 2 }, GrantSkills = [], Flags = { TerrainCostHalved = true, OnDodgeQiRegen = 2 }, Summary = "身法 +12，避暗 +2；复杂地形减耗，闪避回 2 内息。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_xueyuan_zong <- {
	ID = "wx_manual_xueyuan_zong", Name = "踏冰追鹿功", Category = "qinggong", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_23.png",
	Description = "长白参客与雪原猎手踩着冰壳积雪疾行的步法，抢占先机且雪地不累。",
	BasePrice = 280, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 5 }, GrantSkills = [], Flags = { TerrainCostHalved = true }, Summary = "身法 +5；复杂地形减耗。" },
		{ ExpNeeded = 80, Stats = { Initiative = 9 }, GrantSkills = [], Flags = { TerrainCostHalved = true, FirstRoundInit = 5 }, Summary = "身法 +9；首轮身法 +5，复杂地形减耗。" },
		{ ExpNeeded = 180, Stats = { Initiative = 12 }, GrantSkills = [], Flags = { TerrainCostHalved = true, FirstRoundInit = 10 }, Summary = "身法 +12；首轮身法 +10，复杂地形减耗。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_liusha_bu <- {
	ID = "wx_manual_liusha_bu", Name = "大漠孤烟步", Category = "qinggong", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_01.png",
	Description = "西域向导踏过浮沙不留深印的巧劲步法，且善侧身避开流矢。",
	BasePrice = 400, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 4 }, GrantSkills = [], Flags = { TerrainCostHalved = true }, Summary = "身法 +4；复杂地形减耗。" },
		{ ExpNeeded = 80, Stats = { Initiative = 8 }, GrantSkills = [], Flags = { TerrainCostHalved = true, DodgeRangedBonus = 2 }, Summary = "身法 +8；复杂地形减耗，听风避矢 +2。" },
		{ ExpNeeded = 180, Stats = { Initiative = 12 }, GrantSkills = [], Flags = { TerrainCostHalved = true, DodgeRangedBonus = 4 }, Summary = "身法 +12；复杂地形减耗，听风避矢 +4。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_yexing_shu <- {
	ID = "wx_manual_yexing_shu", Name = "梁上飞燕功", Category = "qinggong", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_51.png",
	Description = "市井飞贼翻墙越脊的轻身功夫，夜黑风高之时尤为灵便。",
	BasePrice = 370, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 5 }, GrantSkills = [], Flags = { FirstRoundInit = 5 }, Summary = "身法 +5；首轮身法 +5。" },
		{ ExpNeeded = 80, Stats = { Initiative = 8 }, GrantSkills = [], Flags = { FirstRoundInit = 8, ElevationDiscount = true }, Summary = "身法 +8；首轮身法 +8，高低坡行动点 -1。" },
		{ ExpNeeded = 180, Stats = { Initiative = 12 }, GrantSkills = [], Flags = { FirstRoundInit = 12, ElevationDiscount = true, NightOwl = true }, Summary = "身法 +12；首轮身法 +12，高低坡行动点 -1，夜战无视视野惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zui_babu <- {
	ID = "wx_manual_zui_babu", Name = "市井滑泥步", Category = "qinggong", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_32.png",
	Description = "丐帮外围乞儿在闹市钻空子躲棍棒的油滑身法，借身法微补闪避。",
	BasePrice = 370, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 4 }, GrantSkills = [], Flags = { InitToDefRatio = 0.05 }, Summary = "身法 +4；有效身法 5% 转双防。" },
		{ ExpNeeded = 80, Stats = { Initiative = 8 }, GrantSkills = [], Flags = { InitToDefRatio = 0.08 }, Summary = "身法 +8；有效身法 8% 转双防。" },
		{ ExpNeeded = 180, Stats = { Initiative = 12 }, GrantSkills = [], Flags = { InitToDefRatio = 0.10 }, Summary = "身法 +12；有效身法 10% 转双防。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_junzhong_jixing <- {
	ID = "wx_manual_junzhong_jixing", Name = "急行军奔步", Category = "qinggong", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_28.png",
	Description = "白马义从与斥候日行百里的奔袭步法，开战抢位迅捷。",
	BasePrice = 400, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 5 }, GrantSkills = [], Flags = { FirstRoundInit = 6 }, Summary = "身法 +5；首轮身法 +6。" },
		{ ExpNeeded = 80, Stats = { Initiative = 8 }, GrantSkills = [], Flags = { FirstRoundInit = 10, FirstRoundHit = 3 }, Summary = "身法 +8；首轮身法 +10，首轮命中 +3。" },
		{ ExpNeeded = 180, Stats = { Initiative = 12 }, GrantSkills = [], Flags = { FirstRoundInit = 14, FirstRoundHit = 5 }, Summary = "身法 +12；首轮身法 +14，首轮命中 +5。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_nuannuo_bu <- {
	ID = "wx_manual_nuannuo_bu", Name = "穿花绕树步", Category = "qinggong", Quality = "common",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_01.png",
	Description = "采茶女与山林剑客穿梭茶垄竹林的灵巧步法，专避飞蝗暗器。",
	BasePrice = 340, FragmentsNeeded = 0, AllowFragmentLearn = false, Requirements = {},
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 4, RangedDefense = 1 }, GrantSkills = [], Flags = {}, Summary = "身法 +4，避暗 +1。" },
		{ ExpNeeded = 80, Stats = { Initiative = 8, RangedDefense = 2 }, GrantSkills = [], Flags = { DodgeRangedBonus = 2 }, Summary = "身法 +8，避暗 +2；听风避矢 +2。" },
		{ ExpNeeded = 180, Stats = { Initiative = 12, RangedDefense = 2 }, GrantSkills = [], Flags = { DodgeRangedBonus = 4, OnDodgeQiRegen = 2 }, Summary = "身法 +12，避暗 +2；听风避矢 +4，闪避回 2 内息。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_taihe_yunbu <- {
	ID = "wx_manual_taihe_yunbu", Name = "太和梯云纵", Category = "qinggong", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_01.png",
	Description = "太和玄门名震天下的提纵轻功，左脚踏右脚借力拔高，险峰绝壁如履平地。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 102 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 8 }, GrantSkills = [], Flags = { TerrainCostHalved = true, ElevationDiscount = true }, Summary = "身法 +8；复杂地形减耗，高低坡行动点 -1。" },
		{ ExpNeeded = 160, Stats = { Initiative = 13 }, GrantSkills = [], Flags = { TerrainCostHalved = true, ElevationDiscount = true, InitToDefRatio = 0.12 }, Summary = "身法 +13；有效身法 12% 转双防，复杂地形减耗，高低坡行动点 -1。" },
		{ ExpNeeded = 360, Stats = { Initiative = 18 }, GrantSkills = ["actives.footwork"], Flags = { TerrainCostHalved = true, ElevationDiscount = true, InitToDefRatio = 0.15 }, Summary = "身法 +18；习得「灵巧脱身步」；有效身法 15% 转双防，复杂地形减耗，高低坡行动点 -1。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_tangmen_guiying <- {
	ID = "wx_manual_tangmen_guiying", Name = "唐门鬼影迷踪", Category = "qinggong", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_26.png",
	Description = "蜀中唐家堡独门诡异身法，忽左忽右难测落点，配合快手换镖与脱身步法。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 104 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 9 }, GrantSkills = [], Flags = { QuickHands = true, FirstRoundInit = 8 }, Summary = "身法 +9；首轮身法 +8，每回合首次换装免耗点。" },
		{ ExpNeeded = 160, Stats = { Initiative = 14 }, GrantSkills = [], Flags = { QuickHands = true, FirstRoundInit = 12, InitToDefRatio = 0.11 }, Summary = "身法 +14；首轮身法 +12，有效身法 11% 转双防，每回合首次换装免耗点。" },
		{ ExpNeeded = 360, Stats = { Initiative = 18 }, GrantSkills = ["actives.footwork"], Flags = { QuickHands = true, FirstRoundInit = 16, InitToDefRatio = 0.15 }, Summary = "身法 +18；习得「灵巧脱身步」；首轮身法 +16，有效身法 15% 转双防，每回合首次换装免耗点。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_wudu_shehang <- {
	ID = "wx_manual_wudu_shehang", Name = "金蛇盘草步", Category = "qinggong", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_50.png",
	Description = "南疆五毒奇门模仿毒蛇草丛游走的伏低身法，泥沼密林不减其速，更善躲避箭矢。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 100 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 8 }, GrantSkills = [], Flags = { TerrainCostHalved = true, DodgeRangedBonus = 3 }, Summary = "身法 +8；复杂地形减耗，听风避矢 +3。" },
		{ ExpNeeded = 160, Stats = { Initiative = 13 }, GrantSkills = [], Flags = { TerrainCostHalved = true, DodgeRangedBonus = 5, InitToDefRatio = 0.11 }, Summary = "身法 +13；有效身法 11% 转双防，复杂地形减耗，听风避矢 +5。" },
		{ ExpNeeded = 360, Stats = { Initiative = 18 }, GrantSkills = ["actives.footwork"], Flags = { TerrainCostHalved = true, DodgeRangedBonus = 7, InitToDefRatio = 0.14 }, Summary = "身法 +18；习得「灵巧脱身步」；有效身法 14% 转双防，复杂地形减耗，听风避矢 +7。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_xuanbing_feixue <- {
	ID = "wx_manual_xuanbing_feixue", Name = "昆仑飞雪飘踪", Category = "qinggong", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_01.png",
	Description = "昆仑玄冰宫轻身步法，身姿轻若寒风柳絮，借敌掌风飘然卸力回气。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 105 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 9 }, GrantSkills = [], Flags = { TerrainCostHalved = true, OnDodgeQiRegen = 2 }, Summary = "身法 +9；复杂地形减耗，闪避回 2 内息。" },
		{ ExpNeeded = 160, Stats = { Initiative = 14 }, GrantSkills = [], Flags = { TerrainCostHalved = true, OnDodgeQiRegen = 3, InitToDefRatio = 0.12 }, Summary = "身法 +14；有效身法 12% 转双防，复杂地形减耗，闪避回 3 内息。" },
		{ ExpNeeded = 360, Stats = { Initiative = 18 }, GrantSkills = ["actives.footwork"], Flags = { TerrainCostHalved = true, OnDodgeQiRegen = 4, InitToDefRatio = 0.16 }, Summary = "身法 +18；习得「灵巧脱身步」；有效身法 16% 转双防，复杂地形减耗，闪避回 4 内息。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_emei_chanyun <- {
	ID = "wx_manual_emei_chanyun", Name = "金顶穿云步", Category = "qinggong", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_26.png",
	Description = "峨眉金顶庵灵动身法，讲究与同门换位救援、进退相护。",
	BasePrice = 2170, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 100 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 8 }, GrantSkills = [], Flags = { InitToDefRatio = 0.08 }, Summary = "身法 +8；有效身法 8% 转双防。" },
		{ ExpNeeded = 160, Stats = { Initiative = 13 }, GrantSkills = ["actives.rotation"], Flags = { InitToDefRatio = 0.12 }, Summary = "身法 +13；习得「换位援护」；有效身法 12% 转双防。" },
		{ ExpNeeded = 360, Stats = { Initiative = 18 }, GrantSkills = ["actives.rotation", "actives.footwork"], Flags = { InitToDefRatio = 0.15 }, Summary = "身法 +18；习得「灵巧脱身步」；有效身法 15% 转双防。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_qingcheng_meipiao <- {
	ID = "wx_manual_qingcheng_meipiao", Name = "幽谷魅影步", Category = "qinggong", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_51.png",
	Description = "青城幽谷观夜袭奇步，暗夜之中如鬼魅贴身，首轮抢攻凌厉无比。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 102 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 9 }, GrantSkills = [], Flags = { NightOwl = true, FirstRoundInit = 10 }, Summary = "身法 +9；首轮身法 +10，夜战无视视野惩罚。" },
		{ ExpNeeded = 160, Stats = { Initiative = 14 }, GrantSkills = [], Flags = { NightOwl = true, FirstRoundInit = 15, InitToDefRatio = 0.11 }, Summary = "身法 +14；首轮身法 +15，有效身法 11% 转双防，夜战无视视野惩罚。" },
		{ ExpNeeded = 360, Stats = { Initiative = 18 }, GrantSkills = ["actives.footwork"], Flags = { NightOwl = true, FirstRoundInit = 20, FirstRoundHit = 8, InitToDefRatio = 0.14 }, Summary = "身法 +18；习得「灵巧脱身步」；首轮身法 +20，首轮命中 +8，有效身法 14% 转双防，夜战无视视野惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_zhongnan_feiyan <- {
	ID = "wx_manual_zhongnan_feiyan", Name = "古墓迎风拂柳步", Category = "qinggong", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_01.png",
	Description = "终南活死人庐在幽暗石室捉雀习得的极巧身法，身法转防效率极高。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 106 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 9 }, GrantSkills = [], Flags = { InitToDefRatio = 0.10 }, Summary = "身法 +9；有效身法 10% 转双防。" },
		{ ExpNeeded = 160, Stats = { Initiative = 14 }, GrantSkills = [], Flags = { InitToDefRatio = 0.13, NightOwl = true }, Summary = "身法 +14；有效身法 13% 转双防，夜战无视视野惩罚。" },
		{ ExpNeeded = 360, Stats = { Initiative = 18 }, GrantSkills = ["actives.footwork"], Flags = { InitToDefRatio = 0.16, NightOwl = true }, Summary = "身法 +18；习得「灵巧脱身步」；有效身法 16% 转双防，夜战无视视野惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_wuyi_tingfeng <- {
	ID = "wx_manual_wuyi_tingfeng", Name = "武夷听风辨影步", Category = "qinggong", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_23.png",
	Description = "武夷碧水轩茶山绝技，未见箭影先闻弦音，专克弓弩火器齐射。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 100 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 8, RangedDefense = 1 }, GrantSkills = [], Flags = { DodgeRangedBonus = 4 }, Summary = "身法 +8，避暗 +1；听风避矢 +4。" },
		{ ExpNeeded = 160, Stats = { Initiative = 13, RangedDefense = 2 }, GrantSkills = [], Flags = { DodgeRangedBonus = 6, InitToDefRatio = 0.11 }, Summary = "身法 +13，避暗 +2；有效身法 11% 转双防，听风避矢 +6。" },
		{ ExpNeeded = 360, Stats = { Initiative = 18, RangedDefense = 2 }, GrantSkills = ["actives.footwork"], Flags = { DodgeRangedBonus = 8, InitToDefRatio = 0.14 }, Summary = "身法 +18，避暗 +2；习得「灵巧脱身步」；有效身法 14% 转双防，听风避矢 +8。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_luoyang_zongma <- {
	ID = "wx_manual_luoyang_zongma", Name = "八百里追风步", Category = "qinggong", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_28.png",
	Description = "洛阳长风镖局八百里加急趟子手秘传步法，擅长与受困同僚换位解围。",
	BasePrice = 2230, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 98 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 8 }, GrantSkills = [], Flags = { TerrainCostHalved = true }, Summary = "身法 +8；复杂地形减耗。" },
		{ ExpNeeded = 160, Stats = { Initiative = 13 }, GrantSkills = ["actives.rotation"], Flags = { TerrainCostHalved = true, FormationBondDef = 2 }, Summary = "身法 +13；习得「换位援护」；邻接同袍结阵守御定力 +2，复杂地形减耗。" },
		{ ExpNeeded = 360, Stats = { Initiative = 18 }, GrantSkills = ["actives.rotation"], Flags = { TerrainCostHalved = true, FormationBondDef = 3, InitToDefRatio = 0.12 }, Summary = "身法 +18；邻接同袍结阵守御定力 +3，有效身法 12% 转双防，复杂地形减耗。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_mobei_langben <- {
	ID = "wx_manual_mobei_langben", Name = "苍狼掠草步", Category = "qinggong", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_23.png",
	Description = "漠北苍狼部斥候在草原雪地追踪猎物的奔狼步，孤身迂回侧翼时战力倍增。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 102 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 8 }, GrantSkills = [], Flags = { TerrainCostHalved = true, LoneWolfBonus = 3 }, Summary = "身法 +8；孤身两格无友军时攻防 +3，复杂地形减耗。" },
		{ ExpNeeded = 160, Stats = { Initiative = 13 }, GrantSkills = [], Flags = { TerrainCostHalved = true, LoneWolfBonus = 5, InitToDefRatio = 0.10 }, Summary = "身法 +13；孤身两格无友军时攻防 +5，有效身法 10% 转双防，复杂地形减耗。" },
		{ ExpNeeded = 360, Stats = { Initiative = 18 }, GrantSkills = ["actives.footwork"], Flags = { TerrainCostHalved = true, LoneWolfBonus = 6, InitToDefRatio = 0.14 }, Summary = "身法 +18；习得「灵巧脱身步」；孤身两格无友军时攻防 +6，有效身法 14% 转双防，复杂地形减耗。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_loulan_youmu <- {
	ID = "wx_manual_loulan_youmu", Name = "摸金倒斗身法", Category = "qinggong", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_51.png",
	Description = "楼兰摸金商会出入流沙地宫躲避翻板暗弩的绝活，夜视、避箭、脱困俱佳。",
	BasePrice = 2140, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 100 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 8 }, GrantSkills = [], Flags = { NightOwl = true, DodgeRangedBonus = 3 }, Summary = "身法 +8；听风避矢 +3，夜战无视视野惩罚。" },
		{ ExpNeeded = 160, Stats = { Initiative = 13 }, GrantSkills = [], Flags = { NightOwl = true, DodgeRangedBonus = 5, TerrainCostHalved = true }, Summary = "身法 +13；复杂地形减耗，听风避矢 +5，夜战无视视野惩罚。" },
		{ ExpNeeded = 360, Stats = { Initiative = 18 }, GrantSkills = ["actives.footwork"], Flags = { NightOwl = true, DodgeRangedBonus = 7, TerrainCostHalved = true, InitToDefRatio = 0.13 }, Summary = "身法 +18；习得「灵巧脱身步」；有效身法 13% 转双防，复杂地形减耗，听风避矢 +7，夜战无视视野惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shaolin_yipiao <- {
	ID = "wx_manual_shaolin_yipiao", Name = "一苇渡江功", Category = "qinggong", Quality = "sect",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_01.png",
	Description = "少室禅院上乘提气轻身术，虽披僧衣护腕亦步履轻盈，进可突阵、退可换位护友。",
	BasePrice = 2200, FragmentsNeeded = 3, AllowFragmentLearn = true, Requirements = { Initiative = 100, Stamina = 95 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 8 }, GrantSkills = [], Flags = { TerrainCostHalved = true }, Summary = "身法 +8；复杂地形减耗。" },
		{ ExpNeeded = 160, Stats = { Initiative = 13 }, GrantSkills = ["actives.rotation"], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.11 }, Summary = "身法 +13；习得「换位援护」；有效身法 11% 转双防，复杂地形减耗。" },
		{ ExpNeeded = 360, Stats = { Initiative = 18 }, GrantSkills = ["actives.rotation", "actives.footwork"], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.15 }, Summary = "身法 +18；习得「灵巧脱身步」；有效身法 15% 转双防，复杂地形减耗。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_jiutian_fuyao <- {
	ID = "wx_manual_jiutian_fuyao", Name = "扶摇九天步", Category = "qinggong", Quality = "secret",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_26.png",
	Description = "太和玄门轻功绝学，乘风扶摇直上，身法转防臻至上乘且每步移动节省内力。",
	BasePrice = 4540, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Initiative = 115 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 12 }, GrantSkills = [], Flags = { TerrainCostHalved = true, ElevationDiscount = true, InitToDefRatio = 0.12 }, Summary = "身法 +12；有效身法 12% 转双防，复杂地形减耗，高低坡行动点 -1。" },
		{ ExpNeeded = 250, Stats = { Initiative = 18 }, GrantSkills = ["actives.footwork"], Flags = { TerrainCostHalved = true, ElevationDiscount = true, InitToDefRatio = 0.15 }, Summary = "身法 +18；习得「灵巧脱身步」；有效身法 15% 转双防，复杂地形减耗，高低坡行动点 -1。" },
		{ ExpNeeded = 600, Stats = { Initiative = 24 }, GrantSkills = ["actives.footwork", "actives.rotation"], Flags = { TerrainCostHalved = true, ElevationDiscount = true, InitToDefRatio = 0.18, MoveAPDiscount = 1 }, Summary = "身法 +24；习得「换位援护」；有效身法 18% 转双防，复杂地形减耗，高低坡行动点 -1，移动耗点 -1。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_youming_guibu <- {
	ID = "wx_manual_youming_guibu", Name = "幽冥无影纵", Category = "qinggong", Quality = "secret",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_51.png",
	Description = "幽冥隐杀楼刺客梦寐以求的暗夜鬼步，黑夜来去无踪，首轮切入后排一击脱离。",
	BasePrice = 4630, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Initiative = 116 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 12 }, GrantSkills = [], Flags = { NightOwl = true, FirstRoundInit = 12, InitToDefRatio = 0.12 }, Summary = "身法 +12；首轮身法 +12，有效身法 12% 转双防，夜战无视视野惩罚。" },
		{ ExpNeeded = 250, Stats = { Initiative = 18 }, GrantSkills = ["actives.footwork"], Flags = { NightOwl = true, FirstRoundInit = 18, InitToDefRatio = 0.15 }, Summary = "身法 +18；习得「灵巧脱身步」；首轮身法 +18，有效身法 15% 转双防，夜战无视视野惩罚。" },
		{ ExpNeeded = 600, Stats = { Initiative = 24 }, GrantSkills = ["actives.footwork"], Flags = { NightOwl = true, FirstRoundInit = 25, FirstRoundHit = 10, InitToDefRatio = 0.18, MoveAPDiscount = 1 }, Summary = "身法 +24；首轮身法 +25，首轮命中 +10，有效身法 18% 转双防，移动耗点 -1，夜战无视视野惩罚。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_tangmen_liuxing <- {
	ID = "wx_manual_tangmen_liuxing", Name = "浮光掠影步", Category = "qinggong", Quality = "secret",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_26.png",
	Description = "唐家堡暗器宗师游射步法，快手换镖、听风避矢与移形脱困融为一炉。",
	BasePrice = 4570, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Initiative = 114 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 12 }, GrantSkills = [], Flags = { QuickHands = true, DodgeRangedBonus = 4 }, Summary = "身法 +12；每回合首次换装免耗点，听风避矢 +4。" },
		{ ExpNeeded = 250, Stats = { Initiative = 18 }, GrantSkills = ["actives.footwork"], Flags = { QuickHands = true, DodgeRangedBonus = 6, InitToDefRatio = 0.15 }, Summary = "身法 +18；习得「灵巧脱身步」；有效身法 15% 转双防，每回合首次换装免耗点，听风避矢 +6。" },
		{ ExpNeeded = 600, Stats = { Initiative = 24 }, GrantSkills = ["actives.footwork"], Flags = { QuickHands = true, DodgeRangedBonus = 8, InitToDefRatio = 0.18, MoveAPDiscount = 1 }, Summary = "身法 +24；有效身法 18% 转双防，移动耗点 -1，每回合首次换装免耗点，听风避矢 +8。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_mingzun_nuoyi <- {
	ID = "wx_manual_mingzun_nuoyi", Name = "圣火幻影步", Category = "qinggong", Quality = "secret",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_28.png",
	Description = "西域圣火明尊教护教身法绝技，残影重重迷惑强敌，闪避同时积蓄反扑内息。",
	BasePrice = 4660, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Initiative = 115 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 12 }, GrantSkills = [], Flags = { OnDodgeQiRegen = 3, InitToDefRatio = 0.12 }, Summary = "身法 +12；有效身法 12% 转双防，闪避回 3 内息。" },
		{ ExpNeeded = 250, Stats = { Initiative = 18 }, GrantSkills = ["actives.footwork"], Flags = { OnDodgeQiRegen = 4, InitToDefRatio = 0.15 }, Summary = "身法 +18；习得「灵巧脱身步」；有效身法 15% 转双防，闪避回 4 内息。" },
		{ ExpNeeded = 600, Stats = { Initiative = 24 }, GrantSkills = ["actives.footwork", "actives.rotation"], Flags = { OnDodgeQiRegen = 5, OnDodgeQiCap = 3, InitToDefRatio = 0.18, MoveAPDiscount = 1 }, Summary = "身法 +24；习得「换位援护」；有效身法 18% 转双防，移动耗点 -1，闪避回 5 内息。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_xuanbing_hanhong <- {
	ID = "wx_manual_xuanbing_hanhong", Name = "惊鸿踏雪步", Category = "qinggong", Quality = "secret",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_01.png",
	Description = "昆仑玄冰宫绝顶轻功，翩若惊鸿掠过冰峰，独战群丑亦能从容游走。",
	BasePrice = 4570, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Initiative = 116 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 12 }, GrantSkills = [], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.12 }, Summary = "身法 +12；有效身法 12% 转双防，复杂地形减耗。" },
		{ ExpNeeded = 250, Stats = { Initiative = 18 }, GrantSkills = ["actives.footwork"], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.15, LoneWolfBonus = 4 }, Summary = "身法 +18；习得「灵巧脱身步」；孤身两格无友军时攻防 +4，有效身法 15% 转双防，复杂地形减耗。" },
		{ ExpNeeded = 600, Stats = { Initiative = 24 }, GrantSkills = ["actives.footwork"], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.18, LoneWolfBonus = 7, MoveAPDiscount = 1 }, Summary = "身法 +24；孤身两格无友军时攻防 +7，有效身法 18% 转双防，复杂地形减耗，移动耗点 -1。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_qingfeng_liufeng <- {
	ID = "wx_manual_qingfeng_liufeng", Name = "流风回雪步", Category = "qinggong", Quality = "secret",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_26.png",
	Description = "清风剑派轻功绝学，步随剑转如回风舞雪，借闪避余势寻敌破绽。",
	BasePrice = 4570, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Initiative = 115 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 12 }, GrantSkills = [], Flags = { InitToDefRatio = 0.12, OnDodgeQiRegen = 2 }, Summary = "身法 +12；有效身法 12% 转双防，闪避回 2 内息。" },
		{ ExpNeeded = 250, Stats = { Initiative = 18 }, GrantSkills = ["actives.footwork"], Flags = { InitToDefRatio = 0.15, OnDodgeQiRegen = 4 }, Summary = "身法 +18；习得「灵巧脱身步」；有效身法 15% 转双防，闪避回 4 内息。" },
		{ ExpNeeded = 600, Stats = { Initiative = 24 }, GrantSkills = ["actives.footwork"], Flags = { InitToDefRatio = 0.18, OnDodgeQiRegen = 5, ExposeOnHitPct = 30, MoveAPDiscount = 1 }, Summary = "身法 +24；普攻寻隙留破绽 30%，有效身法 18% 转双防，移动耗点 -1，闪避回 5 内息。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_youlong_jinghong <- {
	ID = "wx_manual_youlong_jinghong", Name = "游龙惊鸿影", Category = "qinggong", Quality = "unique",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_26.png",
	Description = "前朝剑仙遗留的身法孤本：孤身入万军之中如游龙戏水，身法化防达至极境且独行全能大增。",
	BasePrice = 11860, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Initiative = 124 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 14 }, GrantSkills = [], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.13, LoneWolfBonus = 4 }, Summary = "身法 +14；孤身两格无友军时攻防 +4，有效身法 13% 转双防，复杂地形减耗。" },
		{ ExpNeeded = 320, Stats = { Initiative = 22 }, GrantSkills = ["actives.footwork"], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.17, LoneWolfBonus = 6 }, Summary = "身法 +22；习得「灵巧脱身步」；孤身两格无友军时攻防 +6，有效身法 17% 转双防，复杂地形减耗。" },
		{ ExpNeeded = 800, Stats = { Initiative = 30 }, GrantSkills = ["actives.footwork", "actives.rotation"], Flags = { TerrainCostHalved = true, InitToDefRatio = 0.20, LoneWolfBonus = 8, MoveAPDiscount = 1 }, Summary = "身法 +30；习得「换位援护」；孤身两格无友军时攻防 +8，有效身法 20% 转双防，复杂地形减耗，移动耗点 -1。" }
	]
};

::Wuxia.Config.Manuals.wx_manual_shenxing_baibian <- {
	ID = "wx_manual_shenxing_baibian", Name = "神行百变谱", Category = "qinggong", Quality = "unique",
	Element = null, WeaponTypes = [], Icon = "ui/perks/perk_28.png",
	Description = "奇门遁甲轻身孤本：滑不留手、移步生影，三重大成突破常驻 +1 AP 并免受夜战与箭雨之苦。",
	BasePrice = 11800, FragmentsNeeded = 5, AllowFragmentLearn = true, Requirements = { Initiative = 125 },
	Levels = [
		{ ExpNeeded = 0, Stats = { Initiative = 14 }, GrantSkills = [], Flags = { TerrainCostHalved = true, DodgeRangedBonus = 5, InitToDefRatio = 0.13 }, Summary = "身法 +14；有效身法 13% 转双防，复杂地形减耗，听风避矢 +5。" },
		{ ExpNeeded = 320, Stats = { Initiative = 22 }, GrantSkills = ["actives.footwork"], Flags = { TerrainCostHalved = true, DodgeRangedBonus = 7, InitToDefRatio = 0.16, NightOwl = true }, Summary = "身法 +22；习得「灵巧脱身步」；有效身法 16% 转双防，复杂地形减耗，听风避矢 +7，夜战无视视野惩罚。" },
		{ ExpNeeded = 800, Stats = { Initiative = 30 }, GrantSkills = ["actives.footwork"], Flags = { TerrainCostHalved = true, DodgeRangedBonus = 8, InitToDefRatio = 0.20, NightOwl = true, PermanentAPBonus = 1 }, Summary = "身法 +30；有效身法 20% 转双防，复杂地形减耗，听风避矢 +8，夜战无视视野惩罚，常驻行动点 +1。" }
	]
};
