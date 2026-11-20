// Each school fighter uses its native archetype's tactical AI and equipment.
::Wuxia.Config.Fighters <- {
	hammer_adept = {
		Name = "震岳重锤好手", BaseTroop = "BanditRaider", Weapon = "warhammer", DropChance = 42, IsBoss = false,
		Manuals = [{ ManualID = "wx_manual_zhenyue_chui", Tier = 2, Weight = 60 }, { ManualID = "wx_manual_tiebushan", Tier = 2, Weight = 40 }]
	},
	axe_vanguard = {
		Name = "劈山巨斧前锋", BaseTroop = "BanditRaider", Weapon = "fighting_axe", DropChance = 42, IsBoss = false,
		Manuals = [{ ManualID = "wx_manual_pishan_fu", Tier = 2, Weight = 65 }, { ManualID = "wx_manual_xingqi", Tier = 2, Weight = 35 }]
	},
	whip_stalker = {
		Name = "云梦软鞭手", BaseTroop = "BanditRaider", Weapon = "flail", DropChance = 42, IsBoss = false,
		Manuals = [{ ManualID = "wx_manual_chansi_bian", Tier = 2, Weight = 65 }, { ManualID = "wx_manual_chanzi", Tier = 2, Weight = 35 }]
	},
	shadow_dagger = {
		Name = "幽冥执匕刺客", BaseTroop = "BanditRaider", Weapon = "rondel_dagger", DropChance = 45, IsBoss = false,
		Manuals = [{ ManualID = "wx_manual_youming_bi", Tier = 2, Weight = 45 }, { ManualID = "wx_manual_fenshui_ci", Tier = 3, Weight = 55 }]
	},
	monk_fighter = {
		Name = "少室戒律武僧", BaseTroop = "BanditRaider", Weapon = "wx_fist_iron", DropChance = 45, IsBoss = false,
		Manuals = [{ ManualID = "wx_manual_jingang", Tier = 2, Weight = 55 }, { ManualID = "wx_manual_nianhua", Tier = 1, Weight = 20 }, { ManualID = "wx_manual_tiebushan", Tier = 2, Weight = 25 }]
	},
	staff_guard = {
		Name = "丐帮护棒弟子", BaseTroop = "BanditRaider", Weapon = "bludgeon", DropChance = 40, IsBoss = false,
		Manuals = [{ ManualID = "wx_manual_huzhen", Tier = 3, Weight = 60 }, { ManualID = "wx_manual_yingpi", Tier = 2, Weight = 40 }]
	},
	escort = {
		Name = "威远镖师", BaseTroop = "BanditRaider", Weapon = "fighting_spear", DropChance = 40, IsBoss = false,
		Manuals = [{ ManualID = "wx_manual_weiyuan", Tier = 2, Weight = 60 }, { ManualID = "wx_manual_songtao", Tier = 2, Weight = 40 }]
	},
	disciple = {
		Name = "清风剑客", BaseTroop = "BanditRaider", Weapon = "arming_sword", DropChance = 40, IsBoss = false,
		Manuals = [{ ManualID = "wx_manual_qingfeng", Tier = 2, Weight = 65 }, { ManualID = "wx_manual_taxue", Tier = 1, Weight = 35 }]
	},
	dartist = {
		Name = "黑风毒暗手", BaseTroop = "BanditMarksman", Weapon = "javelin", DropChance = 40, IsBoss = false,
		Manuals = [{ ManualID = "wx_manual_baoyu", Tier = 2, Weight = 35 }, { ManualID = "wx_manual_xiushou", Tier = 2, Weight = 65 }]
	},
	blood_chief = {
		Name = "血煞帮主", BaseTroop = "BanditLeader", Weapon = "military_cleaver", DropChance = 100, IsBoss = true,
		Manuals = [{ ManualID = "wx_manual_xuesha", Tier = 3, Weight = 45 }, { ManualID = "wx_manual_duanyue", Tier = 3, Weight = 35 }, { ManualID = "wx_manual_tiebushan", Tier = 3, Weight = 20 }]
	},
	renegade = {
		Name = "叛门剑首", BaseTroop = "Swordmaster", Weapon = "noble_sword", DropChance = 100, IsBoss = true,
		Manuals = [{ ManualID = "wx_manual_tianwai", Tier = 3, Weight = 40 }, { ManualID = "wx_manual_huifeng", Tier = 3, Weight = 30 }, { ManualID = "wx_manual_taxue", Tier = 3, Weight = 30 }]
	}
};

::Wuxia.Config.Vendettas <- {
	wx_zhenyue_hammers     = { Name = "太行震岳问罪队", Troops = ["hammer_adept", "hammer_adept", "escort"] },
	wx_pishan_axemen       = { Name = "辽东劈山追剿队", Troops = ["axe_vanguard", "axe_vanguard", "BanditRaider"] },
	wx_jiujie_whips        = { Name = "云梦软鞭缉拿队", Troops = ["whip_stalker", "whip_stalker", "dartist"] },
	wx_yinsha_assassins    = { Name = "幽冥隐杀刺客团", Troops = ["shadow_dagger", "shadow_dagger", "dartist"] },
	wx_shenji_gunners      = { Name = "神机营追缉铳队", Troops = ["Gunner", "escort", "BanditMarksman"] },
	wx_wudu_ambushers      = { Name = "五毒蛊影追杀队", Troops = ["GoblinAmbusher", "dartist", "GoblinSkirmisher", "GoblinAmbusher"] },
	wx_shaolin_monks = { Name = "少室戒律武僧队", Troops = ["monk_fighter", "monk_fighter", "staff_guard"] },
	wx_tangmen_skirmishers = { Name = "唐门追影队", Troops = ["dartist", "BanditMarksman", "dartist"] },
	wx_gaibang_guards = { Name = "丐帮护棒队", Troops = ["staff_guard", "staff_guard", "BanditThug"] },
	wx_weiyuan_escorts  = { Name = "威远问罪镖队", Troops = ["escort", "escort", "escort"] },
	wx_qingfeng_hunters = { Name = "清风追缉剑队", Troops = ["disciple", "disciple", "disciple"] },
	wx_heifeng_raiders  = { Name = "黑风寻仇队", Troops = ["BanditRaider", "BanditThug", "dartist"] }
};

::Wuxia.Config.Strongholds <- {
	blood_keep = {
		Name = "血煞总寨", Description = "红旗下守着黑风刀手与毒暗手。血煞帮主亲自坐镇，寨中藏有洗髓血芝，可带往城里的剥制师处炼丹。",
		Brush = "world_bandit_camp_01", Fortified = true, Troops = ["blood_chief", "dartist", "dartist", "BanditRaider", "BanditRaider", "BanditThug"],
		RewardManual = "wx_manual_xuesha", GivesHerb = true
	},
	sword_retreat = {
		Name = "叛门剑首据点", Description = "山居中藏着叛出师门的剑首，三名清风弃徒为他守关。攻下此地可取《天外一剑》残页。",
		Brush = "world_homestead_01", Fortified = false, FactionType = "Bandits", Troops = ["renegade", "disciple", "disciple", "disciple"],
		RewardManual = "wx_manual_tianwai", ExtraManual = null, GivesHerb = false
	},
	ancient_tomb = {
		Name = "【武林禁地】前朝玄宫秘冢", Description = "阴雾笼罩的前朝地下玄宫，镇陵金甲卫、守陵祭司与古墓血影剑魔长眠于此（机关尸傀经脉死寂，免疫点穴与奇毒）。破阵可得孤本《九幽镇魂录》《太虚真经》残页与洗髓血芝。",
		Brush = "world_necromancer_lair_01", Fortified = false, FactionType = "Undead",
		Troops = ["SkeletonHeavy", "SkeletonHeavy", "SkeletonMedium", "SkeletonMedium", "SkeletonMedium", "SkeletonPriest", "Vampire", "Vampire"],
		RewardManual = "wx_manual_zhenhun", ExtraManual = "wx_manual_taixu", GivesHerb = true
	},
	wudu_sanctum = {
		Name = "【武林禁地】五毒炼药魔窟", Description = "深谷毒瘴中邪派总瓢把子与五毒毒手合炼血狂药人的魔窟。踏平魔窟可夺绝学《血煞金钟罩》、孤本《凌波御风步》残页与洗髓血芝。",
		Brush = "world_bandit_camp_01", Fortified = true, FactionType = "Orcs",
		Troops = ["OrcWarlord", "OrcWarrior", "OrcWarrior", "OrcBerserker", "OrcBerserker", "GoblinAmbusher", "GoblinAmbusher", "dartist"],
		RewardManual = "wx_manual_jinzhong", ExtraManual = "wx_manual_lingbo", GivesHerb = true
	}
};
