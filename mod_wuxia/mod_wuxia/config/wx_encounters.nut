// Each school fighter uses its native archetype's tactical AI, equipment & bespoke Wuxia / 1000-Faces bust.
::Wuxia.Config.Fighters <- {
	// === Core 11 Jianghu & Sect Vanguard Archetypes ===
	hammer_adept = {
		Name = "震岳重锤好手", BaseTroop = "BanditRaider", Weapon = "warhammer", DropChance = 42, IsBoss = false, CustomBust = null,
		Manuals = [{ ManualID = "wx_manual_zhenyue_chui", Tier = 2, Weight = 60 }, { ManualID = "wx_manual_tiebushan", Tier = 2, Weight = 40 }]
	},
	axe_vanguard = {
		Name = "劈山巨斧前锋", BaseTroop = "BanditRaider", Weapon = "fighting_axe", DropChance = 42, IsBoss = false, CustomBust = null,
		Manuals = [{ ManualID = "wx_manual_pishan_fu", Tier = 2, Weight = 65 }, { ManualID = "wx_manual_xingqi", Tier = 2, Weight = 35 }]
	},
	whip_stalker = {
		Name = "云梦赤练软鞭手", BaseTroop = "BanditRaider", Weapon = "flail", DropChance = 42, IsBoss = false, CustomBust = "wx_enemy_yunmeng_viper",
		Manuals = [{ ManualID = "wx_manual_chansi_bian", Tier = 2, Weight = 65 }, { ManualID = "wx_manual_chanzi", Tier = 2, Weight = 35 }]
	},
	shadow_dagger = {
		Name = "幽冥鬼面执匕死士", BaseTroop = "BanditRaider", Weapon = "rondel_dagger", DropChance = 45, IsBoss = false, CustomBust = "wx_enemy_youming_assassin",
		Manuals = [{ ManualID = "wx_manual_youming_bi", Tier = 2, Weight = 45 }, { ManualID = "wx_manual_fenshui_ci", Tier = 3, Weight = 55 }]
	},
	monk_fighter = {
		Name = "少室戒律武僧", BaseTroop = "BanditRaider", Weapon = "wx_fist_iron", DropChance = 45, IsBoss = false, CustomBust = "wx_enemy_shaolin_monk",
		Manuals = [{ ManualID = "wx_manual_jingang", Tier = 2, Weight = 55 }, { ManualID = "wx_manual_nianhua", Tier = 1, Weight = 20 }, { ManualID = "wx_manual_tiebushan", Tier = 2, Weight = 25 }]
	},
	staff_guard = {
		Name = "丐帮护棒弟子", BaseTroop = "BanditRaider", Weapon = "bludgeon", DropChance = 40, IsBoss = false, CustomBust = null,
		Manuals = [{ ManualID = "wx_manual_huzhen", Tier = 3, Weight = 60 }, { ManualID = "wx_manual_yingpi", Tier = 2, Weight = 40 }]
	},
	escort = {
		Name = "威远精锐镖师", BaseTroop = "BanditRaider", Weapon = "fighting_spear", DropChance = 40, IsBoss = false, CustomBust = null,
		Manuals = [{ ManualID = "wx_manual_weiyuan", Tier = 2, Weight = 60 }, { ManualID = "wx_manual_songtao", Tier = 2, Weight = 40 }]
	},
	disciple = {
		Name = "清风入室剑客", BaseTroop = "BanditRaider", Weapon = "arming_sword", DropChance = 40, IsBoss = false, CustomBust = null,
		Manuals = [{ ManualID = "wx_manual_qingfeng", Tier = 2, Weight = 65 }, { ManualID = "wx_manual_taxue", Tier = 1, Weight = 35 }]
	},
	dartist = {
		Name = "黑风淬毒暗手", BaseTroop = "BanditMarksman", Weapon = "javelin", DropChance = 40, IsBoss = false, CustomBust = null,
		Manuals = [{ ManualID = "wx_manual_baoyu", Tier = 2, Weight = 35 }, { ManualID = "wx_manual_xiushou", Tier = 2, Weight = 65 }]
	},
	blood_chief = {
		Name = "血煞魔窟总瓢把", BaseTroop = "BanditLeader", Weapon = "military_cleaver", DropChance = 100, IsBoss = true, CustomBust = "wx_enemy_xuesha_juggernaut",
		Manuals = [{ ManualID = "wx_manual_xuesha", Tier = 3, Weight = 45 }, { ManualID = "wx_manual_duanyue", Tier = 3, Weight = 35 }, { ManualID = "wx_manual_tiebushan", Tier = 3, Weight = 20 }]
	},
	renegade = {
		Name = "叛门绝顶剑首", BaseTroop = "Swordmaster", Weapon = "noble_sword", DropChance = 100, IsBoss = true, CustomBust = "wx_enemy_sword_saint",
		Manuals = [{ ManualID = "wx_manual_tianwai", Tier = 3, Weight = 40 }, { ManualID = "wx_manual_huifeng", Tier = 3, Weight = 30 }, { ManualID = "wx_manual_taxue", Tier = 3, Weight = 30 }]
	},

	// === Stage 3 Expansion: +21 Sect Masters, Imperial Garrison, Five-Venoms & Folkloric Elites (32 Total) ===
	shaolin_bronze = {
		Name = "少室护寺铜人僧", BaseTroop = "BanditLeader", Weapon = "wx_fist_heavy", DropChance = 68, IsBoss = true, CustomBust = "wx_enemy_shaolin_monk",
		Manuals = [{ ManualID = "wx_manual_shaolin_tongren", Tier = 3, Weight = 55 }, { ManualID = "wx_manual_shaolin_jinzhong", Tier = 3, Weight = 45 }]
	},
	taihe_elder = {
		Name = "太和紫霄执剑道长", BaseTroop = "Swordmaster", Weapon = "noble_sword", DropChance = 72, IsBoss = true, CustomBust = "wx_enemy_taihe_elder",
		Manuals = [{ ManualID = "wx_manual_taiji_zhenjian", Tier = 3, Weight = 50 }, { ManualID = "wx_manual_taihe_liangyi", Tier = 3, Weight = 50 }]
	},
	gaibang_elder = {
		Name = "丐帮九袋护法长老", BaseTroop = "BanditLeader", Weapon = "two_handed_mace", DropChance = 70, IsBoss = true, CustomBust = "wx_enemy_gaibang_elder",
		Manuals = [{ ManualID = "wx_manual_gaibang_qingou", Tier = 3, Weight = 55 }, { ManualID = "wx_manual_gaibang_xianglong", Tier = 3, Weight = 45 }]
	},
	emei_sword = {
		Name = "峨眉玄衣执刺女剑侍", BaseTroop = "Swordmaster", Weapon = "fencing_sword", DropChance = 55, IsBoss = false, CustomBust = "wx_enemy_emei_sword",
		Manuals = [{ ManualID = "wx_manual_emei_mie_jian", Tier = 3, Weight = 50 }, { ManualID = "wx_manual_emei_dianxue", Tier = 2, Weight = 50 }]
	},
	tangmen_killer = {
		Name = "唐门机括毒匣杀手", BaseTroop = "BanditMarksman", Weapon = "heavy_crossbow", DropChance = 55, IsBoss = false, CustomBust = "wx_enemy_tangmen_killer",
		Manuals = [{ ManualID = "wx_manual_tangmen_guanyin_lei", Tier = 3, Weight = 45 }, { ManualID = "wx_manual_tangmen_liannu", Tier = 2, Weight = 55 }]
	},
	weiyuan_captain = {
		Name = "威远虎头重甲总镖头", BaseTroop = "BanditLeader", Weapon = "fighting_spear", DropChance = 68, IsBoss = true, CustomBust = "wx_enemy_weiyuan_captain",
		Manuals = [{ ManualID = "wx_manual_weiyuan_zhenbiao", Tier = 3, Weight = 55 }, { ManualID = "wx_manual_juyiling", Tier = 2, Weight = 45 }]
	},
	garrison_general = {
		Name = "藩镇玄甲长戟都统", BaseTroop = "BanditLeader", Weapon = "billhook", DropChance = 70, IsBoss = true, CustomBust = "wx_enemy_garrison_general",
		Manuals = [{ ManualID = "wx_manual_hengshan_tiebi", Tier = 3, Weight = 55 }, { ManualID = "wx_manual_yanmen_zhenjun", Tier = 2, Weight = 45 }]
	},
	shenji_musketeer = {
		Name = "神机营红夷火铳手", BaseTroop = "BanditMarksman", Weapon = "oriental/handgonne", DropChance = 48, IsBoss = false, CustomBust = "wx_enemy_shenji_musketeer",
		Manuals = [{ ManualID = "wx_manual_shazhou_leihuo_chong", Tier = 2, Weight = 60 }, { ManualID = "wx_manual_wuwei_shuaiqi", Tier = 2, Weight = 40 }]
	},
	liushan_bailiff = {
		Name = "六扇门朱衣铁索捕头", BaseTroop = "BanditLeader", Weapon = "flail", DropChance = 58, IsBoss = false, CustomBust = "wx_enemy_liushan_bailiff",
		Manuals = [{ ManualID = "wx_manual_juyiling", Tier = 2, Weight = 50 }, { ManualID = "wx_manual_chansi_bian", Tier = 3, Weight = 50 }]
	},
	dongchang_agent = {
		Name = "东厂绣春飞鱼缇骑", BaseTroop = "Swordmaster", Weapon = "scimitar", DropChance = 65, IsBoss = true, CustomBust = "wx_enemy_dongchang_agent",
		Manuals = [{ ManualID = "wx_manual_huaiyang_jindao", Tier = 3, Weight = 55 }, { ManualID = "wx_manual_youming_guibu", Tier = 3, Weight = 45 }]
	},
	mobei_centurion = {
		Name = "漠北苍狼弯刀百夫长", BaseTroop = "BanditLeader", Weapon = "shamshir", DropChance = 62, IsBoss = true, CustomBust = "wx_enemy_mobei_centurion",
		Manuals = [{ ManualID = "wx_manual_hanhai_xinyue", Tier = 3, Weight = 55 }, { ManualID = "wx_manual_hanhai_wandao_ru", Tier = 2, Weight = 45 }]
	},
	mingzun_fawang = {
		Name = "西域圣火拜火法王", BaseTroop = "BanditLeader", Weapon = "wx_fist_heavy", DropChance = 75, IsBoss = true, CustomBust = "wx_enemy_mingzun_hierophant",
		Manuals = [{ ManualID = "wx_manual_mingzun_shenghuoling", Tier = 3, Weight = 55 }, { ManualID = "wx_manual_mingzun_huo", Tier = 3, Weight = 45 }]
	},
	dongting_pirate = {
		Name = "洞庭连环水寨翻江寇", BaseTroop = "BanditLeader", Weapon = "hooked_blade", DropChance = 60, IsBoss = true, CustomBust = "wx_enemy_dongting_pirate",
		Manuals = [{ ManualID = "wx_manual_dongting_langdao", Tier = 2, Weight = 50 }, { ManualID = "wx_manual_dongting_fenjiang_cha", Tier = 3, Weight = 50 }]
	},
	liaodong_boss = {
		Name = "辽东劈山黑熊寨主", BaseTroop = "BanditLeader", Weapon = "greataxe", DropChance = 68, IsBoss = true, CustomBust = "wx_enemy_liaodong_boss",
		Manuals = [{ ManualID = "wx_manual_pishan_kaitian", Tier = 3, Weight = 55 }, { ManualID = "wx_manual_pishan_fu", Tier = 2, Weight = 45 }]
	},
	wudu_blowgun = {
		Name = "五毒密林吹箭伏兵", BaseTroop = "BanditMarksman", Weapon = "javelin", DropChance = 38, IsBoss = false, CustomBust = "wx_enemy_wudu_blowgun",
		Manuals = [{ ManualID = "wx_manual_wudu_chuijian", Tier = 2, Weight = 55 }, { ManualID = "wx_manual_wudu_shehang", Tier = 2, Weight = 45 }]
	},
	wudu_gushaman = {
		Name = "五毒银冠花蛛蛊师", BaseTroop = "BanditLeader", Weapon = "rondel_dagger", DropChance = 68, IsBoss = true, CustomBust = "wx_enemy_wudu_gushaman",
		Manuals = [{ ManualID = "wx_manual_wudu_wanxian", Tier = 3, Weight = 55 }, { ManualID = "wx_manual_wudu", Tier = 3, Weight = 45 }]
	},
	wanxian_patriarch = {
		Name = "万仙坛赤发毒魔老祖", BaseTroop = "OrcWarlord", Weapon = "ancient/crypt_cleaver", DropChance = 95, IsBoss = true, CustomBust = "wx_enemy_wanxian_patriarch",
		Manuals = [{ ManualID = "wx_manual_wudu_wanxian", Tier = 3, Weight = 55 }, { ManualID = "wx_manual_jinzhong", Tier = 3, Weight = 45 }]
	},
	heishui_berserker = {
		Name = "关外黑水熊首狂战", BaseTroop = "OrcBerserker", Weapon = "greataxe", DropChance = 48, IsBoss = false, CustomBust = "wx_enemy_heishui_berserker",
		Manuals = [{ ManualID = "wx_manual_heishui_kuangfu", Tier = 2, Weight = 55 }, { ManualID = "wx_manual_heishui_xue", Tier = 2, Weight = 45 }]
	},
	bronze_yaoren = {
		Name = "邪派铁枷铜尸药人", BaseTroop = "OrcBerserker", Weapon = "wx_fist_heavy", DropChance = 52, IsBoss = false, CustomBust = "wx_enemy_bronze_yaoren",
		Manuals = [{ ManualID = "wx_manual_jinzhong", Tier = 2, Weight = 45 }, { ManualID = "wx_manual_tiebushan", Tier = 3, Weight = 35 }, { ManualID = "wx_manual_hamagong", Tier = 2, Weight = 20 }]
	},
	tomb_general = {
		Name = "前朝镇陵金甲机关将", BaseTroop = "SkeletonHeavy", Weapon = "ancient/warscythe", DropChance = 85, IsBoss = true, CustomBust = "wx_enemy_tomb_general",
		Manuals = [{ ManualID = "wx_manual_zhenhun", Tier = 3, Weight = 55 }, { ManualID = "wx_manual_tiebushan", Tier = 3, Weight = 45 }]
	},
	chenzhou_herder = {
		Name = "湘西辰州摇铃赶尸匠", BaseTroop = "Necromancer", Weapon = "dagger", DropChance = 80, IsBoss = true, CustomBust = "wx_enemy_chenzhou_herder",
		Manuals = [{ ManualID = "wx_manual_zhenhun", Tier = 3, Weight = 60 }, { ManualID = "wx_manual_wudu", Tier = 2, Weight = 40 }]
	}
};

::Wuxia.Config.Vendettas <- {
	wx_zhenyue_hammers     = { Name = "太行震岳问罪队", Troops = ["garrison_general", "hammer_adept", "hammer_adept"] },
	wx_pishan_axemen       = { Name = "辽东劈山追剿队", Troops = ["liaodong_boss", "axe_vanguard", "axe_vanguard"] },
	wx_jiujie_whips        = { Name = "云梦软鞭缉拿队", Troops = ["whip_stalker", "whip_stalker", "dongting_pirate"] },
	wx_yinsha_assassins    = { Name = "幽冥隐杀刺客团", Troops = ["dongchang_agent", "shadow_dagger", "shadow_dagger"] },
	wx_shenji_gunners      = { Name = "神机营追缉铳队", Troops = ["shenji_musketeer", "shenji_musketeer", "liushan_bailiff"] },
	wx_wudu_ambushers      = { Name = "五毒蛊影追杀队", Troops = ["wudu_gushaman", "wudu_blowgun", "wudu_blowgun", "dartist"] },
	wx_shaolin_monks       = { Name = "少室戒律武僧队", Troops = ["shaolin_bronze", "monk_fighter", "monk_fighter"] },
	wx_tangmen_skirmishers = { Name = "唐门追影毒匣队", Troops = ["tangmen_killer", "tangmen_killer", "dartist"] },
	wx_gaibang_guards      = { Name = "丐帮九袋护法队", Troops = ["gaibang_elder", "staff_guard", "staff_guard"] },
	wx_weiyuan_escorts     = { Name = "威远总镖头问罪队", Troops = ["weiyuan_captain", "escort", "escort"] },
	wx_qingfeng_hunters    = { Name = "名山玄门追缉剑队", Troops = ["taihe_elder", "emei_sword", "disciple"] },
	wx_heifeng_raiders     = { Name = "绿林黑道寻仇队", Troops = ["mobei_centurion", "mingzun_fawang", "dartist"] }
};

::Wuxia.Config.Strongholds <- {
	blood_keep = {
		Name = "血煞总寨", Description = "红旗下守着黑风刀手、邪派铜尸药人与毒暗手。血煞总瓢把亲自坐镇，寨中藏有洗髓血芝，可带往城里的剥制师处炼丹。",
		Brush = "wx_set_outpost_01", Fortified = true, Troops = ["blood_chief", "bronze_yaoren", "dartist", "dartist", "BanditRaider", "BanditRaider"],
		RewardManual = "wx_manual_xuesha", GivesHerb = true
	},
	sword_retreat = {
		Name = "叛门剑首据点", Description = "山居中藏着叛出师门的剑首，峨眉叛徒与清风弃徒为他守关。攻下此地可取《天外一剑》残页。",
		Brush = "wx_set_sect_mountain", Fortified = false, FactionType = "Bandits", Troops = ["renegade", "emei_sword", "disciple", "disciple"],
		RewardManual = "wx_manual_tianwai", ExtraManual = null, GivesHerb = false
	},
	ancient_tomb = {
		Name = "【武林禁地】前朝玄宫秘冢", Description = "阴雾笼罩的前朝地下玄宫，镇陵金甲机关将、辰州赶尸匠与古墓血影剑魔长眠于此（机关尸傀经脉死寂，免疫点穴与奇毒）。破阵可得孤本《九幽镇魂录》《太虚真经》残页与洗髓血芝。",
		Brush = "wx_lair_ancient_tomb", Fortified = false, FactionType = "Undead",
		Troops = ["tomb_general", "chenzhou_herder", "SkeletonHeavy", "SkeletonMedium", "SkeletonMedium", "SkeletonPriest", "Vampire", "Vampire"],
		RewardManual = "wx_manual_zhenhun", ExtraManual = "wx_manual_taixu", GivesHerb = true
	},
	wudu_sanctum = {
		Name = "【武林禁地】五毒炼药魔窟", Description = "深谷毒瘴中万仙坛赤发毒魔老祖、五毒花蛛蛊师与铜尸药人盘踞的魔窟。踏平魔窟可夺绝学《血煞金钟罩》、孤本《凌波御风步》残页与洗髓血芝。",
		Brush = "world_bandit_camp_01", Fortified = true, FactionType = "Orcs",
		Troops = ["wanxian_patriarch", "wudu_gushaman", "bronze_yaoren", "bronze_yaoren", "heishui_berserker", "wudu_blowgun", "wudu_blowgun", "dartist"],
		RewardManual = "wx_manual_jinzhong", ExtraManual = "wx_manual_lingbo", GivesHerb = true
	},
	shanhai_zhuyan = {
		Name = "【山海秘境】小次山血猿绝谷", Chapter = "西山经", Description = "绝谷寒雾中回荡着震裂山石的猿啼——《西山经》凶兽『白首赤足』的朱厌猿王盘踞于此！斩杀大妖可获【朱厌沸血丹核】与《朱厌沸血神功》残页。",
		Brush = "wx_lair_zhuyan", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_zhuyan", "Unhold", "Unhold"],
		RewardManual = "wx_manual_shanhai_zhuyan", ExtraManual = "wx_manual_dari_rulai", GivesHerb = true, IsShanHai = true
	},
	shanhai_feiyi = {
		Name = "【山海秘境】太华赤旱毒渊", Chapter = "西山经", Description = "草木枯焦、赤地千里的深渊裂谷，上古毒蛟『六足四翼』肥遗王蛰伏谷底。讨平此渊可夺【肥遗旱火毒丹】与孤本残页。",
		Brush = "wx_lair_feiyi", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_feiyi", "Serpent", "Serpent"],
		RewardManual = "wx_manual_shennong_baicao", ExtraManual = "wx_manual_taixu", GivesHerb = true, IsShanHai = true
	},
	shanhai_qiongqi = {
		Name = "【山海秘境】邽山恶风荒冢", Chapter = "北山经", Description = "狂风呼啸如牛鸣的塞外荒丘，凶兽穷奇率领成群西山蛊雕伺机扑杀正道侠客。破巢可得【穷奇裂风妖丹】与《穷奇逐风翼步》残页。",
		Brush = "wx_lair_qiongqi", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_qiongqi", "Hyena", "Hyena", "Hyena", "Hyena"],
		RewardManual = "wx_manual_shanhai_qiongqi", ExtraManual = "wx_manual_lingbo", GivesHerb = true, IsShanHai = true
	},
	shanhai_taotie = {
		Name = "【山海秘境】钩吾噬骨魔渊", Chapter = "北山经", Description = "白骨堆积如山的幽暗深坑，上古贪兽饕餮率北山狍鸮群盘踞其中。诛灭首恶可得【饕餮噬元凶丹】与《饕餮吞天魔功》残页。",
		Brush = "wx_lair_taotie", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_taotie", "Ghoul", "Ghoul", "Ghoul", "Ghoul"],
		RewardManual = "wx_manual_shanhai_taotie", ExtraManual = "wx_manual_tianmo_jieti", GivesHerb = true, IsShanHai = true
	},
	shanhai_jiuwei = {
		Name = "【山海秘境】青丘迷魂幽谷", Chapter = "南山经", Description = "桃花瘴雾终年不散的诡异幽谷，千年九尾妖主驱使梦魇讹兽与巨猿护法，心志不坚者慎入！",
		Brush = "wx_lair_jiuwei", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_jiuwei", "Alp", "Alp", "Unhold", "Spider", "Spider"],
		RewardManual = "wx_manual_beiming_huaqi", ExtraManual = "wx_manual_shenxing_baibian", GivesHerb = true, IsShanHai = true
	},
	shanhai_bashe = {
		Name = "【山海秘境】洞庭苍梧黑泽", Chapter = "南山经", Description = "巨象枯骨半沉泥沼的黑水大泽，苍梧吞象巴蛇王率群蟒潜伏芦苇深处。斩蛇取胆可铸无双鳞冠。",
		Brush = "wx_lair_bashe", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_bashe", "Serpent", "Serpent", "Serpent", "Spider"],
		RewardManual = "wx_manual_youlong_jinghong", ExtraManual = "wx_manual_jingke_cixin", GivesHerb = true, IsShanHai = true
	},
	shanhai_jumang = {
		Name = "【山海秘境】都广建木神林", Chapter = "中山经", Description = "古树参天蔽日的太古秘林，句芒建木王盘根错节，凡刀剑轻砍皆受铁棘反伤，唯有开山巨斧可断其根！",
		Brush = "wx_lair_jumang", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_jumang", "Schrat", "Schrat"],
		RewardManual = "wx_manual_pangu_kaitian", ExtraManual = "wx_manual_xuanwu_budong", GivesHerb = true, IsShanHai = true
	},
	shanhai_wuzhiqi = {
		Name = "【山海秘境】龟山寒渊水眼", Chapter = "中山经", Description = "铁索崩断的深潭水眼，上古水猿大妖无支祁破封而出，寒涛掌风专封武人经脉。",
		Brush = "wx_lair_wuzhiqi", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_wuzhiqi", "Unhold", "Serpent", "Serpent"],
		RewardManual = "wx_manual_senluo_wanxiang", ExtraManual = "wx_manual_bawang_xiejia", GivesHerb = true, IsShanHai = true
	},
	shanhai_xingtian = {
		Name = "【山海秘境】常羊古战祭坛", Chapter = "大荒海内经", Description = "残戈断戟插满焦土的上古祭坛，无首巨人战魂犹自挥舞干戚守卫山陵，乃天下武人检验至刚破邪绝学的试金石！",
		Brush = "wx_lair_xingtian", Fortified = false, FactionType = "Undead",
		Troops = ["boss_xingtian", "SkeletonHeavy", "SkeletonHeavy", "SkeletonHeavy", "SkeletonPriest"],
		RewardManual = "wx_manual_shanhai_xingtian", ExtraManual = "wx_manual_jiuyao_pocheng", GivesHerb = true, IsShanHai = true
	},
	shanhai_bifang = {
		Name = "【山海秘境】章莪讹火焦林", Chapter = "南山经", Description = "怪石赤红如火烧的章莪枯林，独足毕方妖皇携诡火残影掠空扑杀，重甲步卒稍不留神便被讹火焚穿衣甲！",
		Brush = "wx_lair_bifang", Fortified = false, FactionType = "Undead",
		Troops = ["boss_bifang", "Vampire", "Vampire", "SkeletonMedium", "SkeletonMedium"],
		RewardManual = "wx_manual_shanhai_kunpeng", ExtraManual = "wx_manual_tianwai", GivesHerb = true, IsShanHai = true
	},
	shanhai_gudiaowang = {
		Name = "【山海秘境】鹿吴泽更血滩", Chapter = "南山经", Description = "芦苇染血的泽更水浅滩，夜闻婴儿啼哭，实乃鹿吴山攒角蛊雕王设伏噬人之地。",
		Brush = "wx_lair_gudiaowang", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_gudiaowang", "Hyena", "Hyena", "Hyena", "Alp"],
		RewardManual = "wx_manual_shanhai_qiongqi", ExtraManual = "wx_manual_youming_bi", GivesHerb = true, IsShanHai = true
	},
	shanhai_xingxing = {
		Name = "【山海秘境】招摇迷踪石林", Chapter = "南山经", Description = "桂木摩天、迷雾锁径的招摇奇峰，千年白耳狌狌老祖洞悉天下招法破绽，寻常快剑难伤分毫。",
		Brush = "wx_lair_xingxing", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_xingxing", "Unhold", "GoblinAmbusher", "GoblinAmbusher"],
		RewardManual = "wx_manual_taixu", ExtraManual = "wx_manual_huifeng", GivesHerb = true, IsShanHai = true
	},
	shanhai_zhujian = {
		Name = "【山海秘境】单狐狂风乱岗", Chapter = "南山经", Description = "怪风怒号飞沙走石的荒岗，豹尾猪建王乘风冲阵，前排盾卫稍有不慎便被撞得人仰盾翻。",
		Brush = "wx_lair_zhujian", Fortified = false, FactionType = "Orcs",
		Troops = ["boss_zhujian", "OrcBerserker", "OrcBerserker", "Hyena", "Hyena"],
		RewardManual = "wx_manual_pishan_fu", ExtraManual = "wx_manual_duanyue", GivesHerb = true, IsShanHai = true
	},
	shanhai_xuangui = {
		Name = "【山海秘境】杻阳怪水深潭", Chapter = "南山经", Description = "怪水幽潭浮起小山般的玄黑巨甲，刀剑弓弩打在鸟首玄龟皇背上只溅火星，唯有携重锤金锏名家方可碎甲屠龟！",
		Brush = "wx_lair_xuangui", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_xuangui", "Unhold", "Serpent", "Serpent"],
		RewardManual = "wx_manual_xuanwu_budong", ExtraManual = "wx_manual_zhenyue_chui", GivesHerb = true, IsShanHai = true
	},
	shanhai_yuanchu = {
		Name = "【山海秘境】丹穴焚天古祠", Chapter = "南山经", Description = "地火喷涌的南荒残破石祠，堕火鹓鶵古妖操控毒火瘴气与金甲火卫封锁通途。",
		Brush = "wx_lair_yuanchu", Fortified = false, FactionType = "Undead",
		Troops = ["boss_yuanchu", "SkeletonHeavy", "SkeletonHeavy", "Vampire", "SkeletonMedium"],
		RewardManual = "wx_manual_dari_rulai", ExtraManual = "wx_manual_shanhai_zhuyan", GivesHerb = true, IsShanHai = true
	},
	shanhai_yingzhao = {
		Name = "【山海秘境】昆仑悬圃荒台", Chapter = "西山经", Description = "云海崩塌后的昆仑悬圃废墟，疯魔的人面虎纹古神英招仍按远古律令诛杀一切踏入禁地之生灵。",
		Brush = "wx_lair_yingzhao", Fortified = false, FactionType = "Orcs",
		Troops = ["boss_yingzhao", "OrcWarrior", "OrcWarrior", "OrcBerserker", "Hyena"],
		RewardManual = "wx_manual_shanhai_chiyou", ExtraManual = "wx_manual_bawang_xiejia", GivesHerb = true, IsShanHai = true
	},
	shanhai_luwu = {
		Name = "【山海秘境】昆仑九部神门", Chapter = "西山经", Description = "九重巨石堆砌的昆仑外门，九尾虎神陆吾踞守神阶，双爪过处精铁重铠亦如败革。",
		Brush = "wx_lair_luwu", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_luwu", "Unhold", "Hyena", "Hyena", "Direwolf"],
		RewardManual = "wx_manual_shanhai_kuiniu", ExtraManual = "wx_manual_jingang", GivesHerb = true, IsShanHai = true
	},
	shanhai_qinyuan = {
		Name = "【山海秘境】昆仑阳枯木毒巢", Chapter = "西山经", Description = "林木尽数枯黑腐朽的昆仑南麓死谷，蜇石钦原蛊皇统御万千鬼面赤蛛吐丝结阵。",
		Brush = "wx_lair_qinyuan", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_qinyuan", "Spider", "Spider", "Spider", "Spider", "Serpent"],
		RewardManual = "wx_manual_baoyu", ExtraManual = "wx_manual_shennong_baicao", GivesHerb = true, IsShanHai = true
	},
	shanhai_tiangouwang = {
		Name = "【山海秘境】阴山坠星狼台", Chapter = "西山经", Description = "陨铁碎石散落的阴山绝顶，奔星天狗皇快逾流光，后排脆皮稍露空隙便遭连环噬喉！",
		Brush = "wx_lair_tiangouwang", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_tiangouwang", "Direwolf", "Direwolf", "Direwolf", "Hyena"],
		RewardManual = "wx_manual_shanhai_qiongqi", ExtraManual = "wx_manual_tianwai", GivesHerb = true, IsShanHai = true
	},
	shanhai_zheng = {
		Name = "【山海秘境】章峨击石赤崖", Chapter = "西山经", Description = "寸草不生、遍地碧瑶美玉的章峨绝壁，五尾独角狰王吼声如金石崩裂。",
		Brush = "wx_lair_zheng", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_zheng", "Hyena", "Hyena", "Direwolf", "Direwolf"],
		RewardManual = "wx_manual_zhenyue_chui", ExtraManual = "wx_manual_tiebushan", GivesHerb = true, IsShanHai = true
	},
	shanhai_hundun = {
		Name = "【山海秘境】天山浑沌丹火渊", Chapter = "西山经", Description = "丹火云雾翻涌的天山深渊，无面无目的四凶浑沌随妖歌狂舞，贴身群殴者反受浑沌气劲震裂五脏！",
		Brush = "wx_lair_hundun", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_hundun", "Unhold", "Unhold", "Alp", "Alp"],
		RewardManual = "wx_manual_shanhai_zhuyin", ExtraManual = "wx_manual_taixu", GivesHerb = true, IsShanHai = true
	},
	shanhai_yayu = {
		Name = "【山海秘境】少咸赤水血窟", Chapter = "北山经", Description = "敦水东流染赤的少咸山洞窟，死而复生的龙首凶神猰貐蛰伏血池，不备斩首绝技难断其生机！",
		Brush = "wx_lair_yayu", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_yayu", "Ghoul", "Ghoul", "Ghoul", "Unhold"],
		RewardManual = "wx_manual_shanhai_taotie", ExtraManual = "wx_manual_xuesha", GivesHerb = true, IsShanHai = true
	},
	shanhai_zhuyin = {
		Name = "【山海秘境】钟山极夜冰火巅", Chapter = "北山经", Description = "极北不见日月的钟山寒渊，烛九阴寒螟血裔呼吸成风、开合昼夜，乃山海秘境至高试炼之一！",
		Brush = "wx_lair_zhuyin", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_zhuyin", "Lindwurm", "Serpent", "Alp"],
		RewardManual = "wx_manual_shanhai_zhuyin", ExtraManual = "wx_manual_taixu", GivesHerb = true, IsShanHai = true
	},
	shanhai_dijiang = {
		Name = "【山海秘境】天山北歌舞荒坛", Chapter = "北山经", Description = "空谷回荡诡异鼓乐的荒古石坛，丹红帝江瞬息百变，弓弩暗器皆落空处。",
		Brush = "wx_lair_dijiang", Fortified = false, FactionType = "Undead",
		Troops = ["boss_dijiang", "Vampire", "Alp", "Alp", "Ghost"],
		RewardManual = "wx_manual_shanhai_kunpeng", ExtraManual = "wx_manual_lingbo", GivesHerb = true, IsShanHai = true
	},
	shanhai_paoxiaowang = {
		Name = "【山海秘境】钩吾北食人骨涧", Chapter = "北山经", Description = "残甲断骨铺满涧底的北山险谷，腋下生目的狍鸮老祖四面皆可视物，围攻合击难讨便宜。",
		Brush = "wx_lair_paoxiaowang", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_paoxiaowang", "Unhold", "Ghoul", "Ghoul", "Ghoul"],
		RewardManual = "wx_manual_shanhai_taotie", ExtraManual = "wx_manual_tiebushan", GivesHerb = true, IsShanHai = true
	},
	shanhai_changyou = {
		Name = "【山海秘境】小侯滔天寒涧", Chapter = "北山经", Description = "山洪终年咆哮的寒潭石窟，四耳长右水猿出则郡县大水，阴寒水劲专克刚猛外家。",
		Brush = "wx_lair_changyou", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_changyou", "Unhold", "Unhold", "Serpent"],
		RewardManual = "wx_manual_beiming_huaqi", ExtraManual = "wx_manual_songtao", GivesHerb = true, IsShanHai = true
	},
	shanhai_mengji = {
		Name = "【山海秘境】石者山冷玉荒原", Chapter = "北山经", Description = "白石皑皑难辨兽踪的塞北荒原，白豹孟极兽皇伏于乱石之间，伺机一击断喉。",
		Brush = "wx_lair_mengji", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_mengji", "Direwolf", "Direwolf", "Hyena", "Hyena"],
		RewardManual = "wx_manual_shenxing_baibian", ExtraManual = "wx_manual_jingke_cixin", GivesHerb = true, IsShanHai = true
	},
	shanhai_kui = {
		Name = "【山海秘境】东海流波雷音岛", Chapter = "东山经", Description = "惊涛拍岸、紫电盘空的东海孤崖，独足雷神夔牛一吼如万鼓齐鸣，震得百炼铁甲寸寸欲裂！",
		Brush = "wx_lair_kui", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_kui", "Unhold", "Unhold", "Direwolf"],
		RewardManual = "wx_manual_shanhai_kuiniu", ExtraManual = "wx_manual_jinzhong", GivesHerb = true, IsShanHai = true
	},
	shanhai_fei = {
		Name = "【山海秘境】太山枯水绝命渊", Chapter = "东山经", Description = "溪流干涸、飞鸟绝迹的枯死荒村，一目白首灾兽蜚皇盘踞井口，未佩辟毒寒渊珠或护心丹者切莫轻进！",
		Brush = "wx_lair_fei", Fortified = false, FactionType = "Orcs",
		Troops = ["boss_fei", "OrcWarrior", "OrcWarrior", "Spider", "Spider", "Serpent"],
		RewardManual = "wx_manual_shennong_baicao", ExtraManual = "wx_manual_shanhai_taotie", GivesHerb = true, IsShanHai = true
	},
	shanhai_yinglong = {
		Name = "【山海秘境】凶犁折翼古龙冢", Chapter = "东山经", Description = "乌云低垂暴雨如注的古战场土丘，折翼应龙的一缕不散战魂盘踞龙骨之上，威压冠绝四海！",
		Brush = "wx_lair_yinglong", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_yinglong", "Lindwurm", "Serpent", "Serpent"],
		RewardManual = "wx_manual_shanhai_chiyou", ExtraManual = "wx_manual_shanhai_kunpeng", GivesHerb = true, IsShanHai = true
	},
	shanhai_taowu = {
		Name = "【山海秘境】荒中檮杌碎甲岭", Chapter = "东山经", Description = "断垣残壁间虎啸震天的荒中险岭，四凶檮杌王傲狠死战至最后一滴血，专碎退缩者脊梁！",
		Brush = "wx_lair_taowu", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_taowu", "Unhold", "Unhold", "Hyena", "Hyena"],
		RewardManual = "wx_manual_shanhai_xingtian", ExtraManual = "wx_manual_duanyue", GivesHerb = true, IsShanHai = true
	},
	shanhai_hujiao = {
		Name = "【山海秘境】玉山虎蛟寒潭", Chapter = "东山经", Description = "寒水幽深的玉山峡涧，四足虎纹的千年虎蛟王潜伏潭底，伺机将过往武人拖入深渊。",
		Brush = "wx_lair_hujiao", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_hujiao", "Serpent", "Serpent", "Serpent", "Unhold"],
		RewardManual = "wx_manual_youlong_jinghong", ExtraManual = "wx_manual_chansi_bian", GivesHerb = true, IsShanHai = true
	},
	shanhai_zhuhuai = {
		Name = "【山海秘境】北岳四角碎骨坡", Chapter = "东山经", Description = "遍地碎裂铁盾的荒山斜坡，四角诸怀王咆哮如鸣雁，冲锋之势重盾难挡。",
		Brush = "wx_lair_zhuhuai", Fortified = false, FactionType = "Orcs",
		Troops = ["boss_zhuhuai", "OrcBerserker", "OrcBerserker", "OrcWarrior", "Hyena"],
		RewardManual = "wx_manual_pangu_kaitian", ExtraManual = "wx_manual_pishan_fu", GivesHerb = true, IsShanHai = true
	},
	shanhai_shebishi = {
		Name = "【山海秘境】大荒奢比古尸冢", Chapter = "东山经", Description = "青雾弥漫的上古大荒尸冢，犬耳贯青蛇的古尸神奢比尸率毒蟒与铜甲尸卫镇守冥门。",
		Brush = "wx_lair_shebishi", Fortified = false, FactionType = "Undead",
		Troops = ["boss_shebishi", "SkeletonHeavy", "SkeletonMedium", "Serpent", "Serpent"],
		RewardManual = "wx_manual_zhenhun", ExtraManual = "wx_manual_tianmo_jieti", GivesHerb = true, IsShanHai = true
	},
	shanhai_jingwei = {
		Name = "【山海秘境】发鸠望海怨魂崖", Chapter = "东山经", Description = "白喙赤足灵禽盘旋的海边绝壁，千年不散的精卫溺魂尖啸裂魄，定力不足者闻声即溃！",
		Brush = "wx_lair_jingwei", Fortified = false, FactionType = "Undead",
		Troops = ["boss_jingwei", "Ghost", "Ghost", "SkeletonHeavy", "SkeletonMedium"],
		RewardManual = "wx_manual_zhenhun", ExtraManual = "wx_manual_lingbo", GivesHerb = true, IsShanHai = true
	},
	shanhai_jiuying = {
		Name = "【山海秘境】凶水九首水火潭", Chapter = "中山经", Description = "一半沸腾如汤、一半凝冰刺骨的凶水深潭，九首大妖九婴盘踞水眼，水火交替侵蚀万物！",
		Brush = "wx_lair_jiuying", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_jiuying", "Lindwurm", "Serpent", "Serpent"],
		RewardManual = "wx_manual_shanhai_zhuyin", ExtraManual = "wx_manual_senluo_wanxiang", GivesHerb = true, IsShanHai = true
	},
	shanhai_feilian = {
		Name = "【山海秘境】鹿台八风古祭坛", Chapter = "中山经", Description = "罡风呼啸卷飞巨石的鹿台山巅，飞廉妖尊统御八风瞬息切入后阵，专克弓弩暗器名家。",
		Brush = "wx_lair_feilian", Fortified = false, FactionType = "Undead",
		Troops = ["boss_feilian", "Vampire", "Vampire", "Direwolf", "Direwolf"],
		RewardManual = "wx_manual_shanhai_kunpeng", ExtraManual = "wx_manual_shenxing_baibian", GivesHerb = true, IsShanHai = true
	},
	shanhai_baize = {
		Name = "【山海秘境】东望云海白泽台", Chapter = "中山经", Description = "云雾缭绕的东望灵峰，通晓天下鬼神百兵破绽的古老白泽试炼来犯武人。",
		Brush = "wx_lair_baize", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_baize", "Unhold", "Schrat", "Alp"],
		RewardManual = "wx_manual_taixu", ExtraManual = "wx_manual_huifeng", GivesHerb = true, IsShanHai = true
	},
	shanhai_shanhui = {
		Name = "【山海秘境】狱法飞石怪风谷", Chapter = "中山经", Description = "怪笑回荡的乱石风谷，犬形人面的山挥王携奇门伏兵飞石攒射、来去如风。",
		Brush = "wx_lair_shanhui", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_shanhui", "GoblinAmbusher", "GoblinAmbusher", "GoblinSkirmisher", "Hyena", "Hyena"],
		RewardManual = "wx_manual_baoyu", ExtraManual = "wx_manual_taxue", GivesHerb = true, IsShanHai = true
	},
	shanhai_bo = {
		Name = "【山海秘境】中曲伏虎白石谷", Chapter = "中山经", Description = "猛虎残骸散落谷口的白石山坳，专食虎豹的独角铁驳王昂首嘶鸣，声震十里。",
		Brush = "wx_lair_bo", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_bo", "Unhold", "Direwolf", "Direwolf", "Hyena"],
		RewardManual = "wx_manual_shanhai_kuiniu", ExtraManual = "wx_manual_bawang_xiejia", GivesHerb = true, IsShanHai = true
	},
	shanhai_huodou = {
		Name = "【山海秘境】厌火焦土熔岩窟", Chapter = "中山经", Description = "硫磺黑烟滚滚的南荒熔岩废墟，食炭喷炎的祸斗妖犬王踏火而行，近身劈砍者衣甲尽燃！",
		Brush = "wx_lair_huodou", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_huodou", "Direwolf", "Direwolf", "Hyena", "Serpent"],
		RewardManual = "wx_manual_dari_rulai", ExtraManual = "wx_manual_shanhai_zhuyan", GivesHerb = true, IsShanHai = true
	},
	shanhai_xiangliuwang = {
		Name = "【山海秘境】共工九首苦毒大泽", Chapter = "大荒海内经", Description = "飞鸟不渡、百兽莫居的共工台北苦毒黑泽，上古凶神九首相柳皇盘踞泽心，毒威滔天！",
		Brush = "wx_lair_xiangliuwang", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_xiangliuwang", "Lindwurm", "Serpent", "Serpent", "Spider"],
		RewardManual = "wx_manual_shennong_baicao", ExtraManual = "wx_manual_shanhai_taotie", GivesHerb = true, IsShanHai = true
	},
	shanhai_kuafu = {
		Name = "【山海秘境】邓林逐日巨神墟", Chapter = "大荒海内经", Description = "桃林漫山掩映万丈枯骨的大荒古泽，逐日巨神夸父遗骸手执邓林神杖不倒，酷热渴气蒸干来人真元！",
		Brush = "wx_lair_kuafu", Fortified = false, FactionType = "Undead",
		Troops = ["boss_kuafu", "SkeletonHeavy", "SkeletonHeavy", "SkeletonPriest", "Schrat"],
		RewardManual = "wx_manual_pangu_kaitian", ExtraManual = "wx_manual_dari_rulai", GivesHerb = true, IsShanHai = true
	},
	shanhai_chiyou = {
		Name = "【山海秘境】凶黎五兵战神冢", Chapter = "大荒海内经", Description = "古兵残骸堆积成山的凶黎血冢，铜头铁额的兵主蚩尤战魄执掌百兵杀伐，唯有当世武林宗师可与争锋！",
		Brush = "wx_lair_chiyou", Fortified = false, FactionType = "Orcs",
		Troops = ["boss_chiyou", "OrcWarrior", "OrcWarrior", "OrcBerserker", "OrcBerserker"],
		RewardManual = "wx_manual_shanhai_chiyou", ExtraManual = "wx_manual_shanhai_xingtian", GivesHerb = true, IsShanHai = true
	},
	shanhai_zaochi = {
		Name = "【山海秘境】畴华古盾白骨泽", Chapter = "大荒海内经", Description = "残破青铜大盾散落的南荒泥泽，持盾凿齿凶魔结成铜墙铁壁，寻常刀剑难越雷池。",
		Brush = "wx_lair_zaochi", Fortified = false, FactionType = "Undead",
		Troops = ["boss_zaochi", "SkeletonHeavy", "SkeletonHeavy", "SkeletonMedium", "SkeletonMedium"],
		RewardManual = "wx_manual_xuanwu_budong", ExtraManual = "wx_manual_jiuyao_pocheng", GivesHerb = true, IsShanHai = true
	},
	shanhai_erfu = {
		Name = "【山海秘境】疏属断枷锁神崖", Chapter = "大荒海内经", Description = "千年神木拴着碗口粗玄铁断链的疏属绝壁，受刑古神贰负尸皇拖曳铁枷咆哮人间。",
		Brush = "wx_lair_erfu", Fortified = false, FactionType = "Undead",
		Troops = ["boss_erfu", "SkeletonHeavy", "SkeletonHeavy", "SkeletonPriest"],
		RewardManual = "wx_manual_zhenhun", ExtraManual = "wx_manual_chansi_bian", GivesHerb = true, IsShanHai = true
	},
	shanhai_nvchou = {
		Name = "【山海秘境】十日炙魂曝尸峰", Chapter = "大荒海内经", Description = "寸水不存、岩石龟裂的十日山顶，青衣蔽面的女丑旱魃魂操纵焦尸与热浪惑乱人心。",
		Brush = "wx_lair_nvchou", Fortified = false, FactionType = "Undead",
		Troops = ["boss_nvchou", "SkeletonHeavy", "SkeletonHeavy", "Alp", "Alp", "Ghost"],
		RewardManual = "wx_manual_dari_rulai", ExtraManual = "wx_manual_shanhai_zhuyin", GivesHerb = true, IsShanHai = true
	},
	shanhai_fangfeng = {
		Name = "【山海秘境】会稽涂山巨骨陵", Chapter = "大荒海内经", Description = "巨骨如山梁横卧的涂山古陵，守风之神防风氏巨骨苏醒，非破甲金锤名家莫敢撄其锋！",
		Brush = "wx_lair_fangfeng", Fortified = false, FactionType = "Undead",
		Troops = ["boss_fangfeng", "Unhold", "SkeletonHeavy", "SkeletonHeavy", "SkeletonPriest"],
		RewardManual = "wx_manual_shanhai_kuiniu", ExtraManual = "wx_manual_xuanwu_budong", GivesHerb = true, IsShanHai = true
	},
	shanhai_kaiming = {
		Name = "【山海秘境】昆仑九井百神门", Chapter = "海内西经", Description = "上古昆仑虚东向石门遗迹，虎身九首人面的开明神兽矗立玉阶，百兵围攻亦难觅其死角！",
		Brush = "wx_lair_kaiming", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_kaiming", "Unhold", "Unhold", "Direwolf", "Direwolf"],
		RewardManual = "wx_manual_taixu", ExtraManual = "wx_manual_xuanwu_budong", GivesHerb = true, IsShanHai = true
	},
	shanhai_jinwu = {
		Name = "【山海秘境】汤谷扶桑焦木坛", Chapter = "大荒东经", Description = "黑齿国北沸水海谷，焦赤扶桑巨木之巅栖息三足金乌皇，酷烈阳火令重甲武士未战先竭！",
		Brush = "wx_lair_jinwu", Fortified = false, FactionType = "Undead",
		Troops = ["boss_jinwu", "Vampire", "Vampire", "Ghost", "Ghost"],
		RewardManual = "wx_manual_dari_rulai", ExtraManual = "wx_manual_taixu", GivesHerb = true, IsShanHai = true
	},
	shanhai_zouyu = {
		Name = "【山海秘境】林氏五色竹海涧", Chapter = "海内北经", Description = "异竹丛生、云霞流转的幽深山涧，尾长于身的五采驺虞王瞬息千里试炼入山豪杰。",
		Brush = "wx_lair_zouyu", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_zouyu", "Hyena", "Hyena", "Direwolf", "Direwolf"],
		RewardManual = "wx_manual_shenxing_baibian", ExtraManual = "wx_manual_taxue", GivesHerb = true, IsShanHai = true
	},
	shanhai_gonggong = {
		Name = "【山海秘境】不周折柱寒潮渊", Chapter = "大荒西经", Description = "天柱倾折、黑水倒灌的上古绝渊，赤发蛇身的共工水煞盘踞断崖掀起滔天寒浪！",
		Brush = "wx_lair_gonggong", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_gonggong", "Lindwurm", "UnholdBog", "Serpent", "Serpent"],
		RewardManual = "wx_manual_beiming_huaqi", ExtraManual = "wx_manual_shanhai_zhuyin", GivesHerb = true, IsShanHai = true
	},
	shanhai_wuluo = {
		Name = "【山海秘境】青要畛水女神祠", Chapter = "中山经", Description = "水鸟百族栖息的青要秘谷古祠，豹纹神女武罗吟唱古歌，心志微摇者立堕幻境！",
		Brush = "wx_lair_wuluo", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_wuluo", "Hexe", "Alp", "Alp", "Direwolf", "Direwolf"],
		RewardManual = "wx_manual_lingbo", ExtraManual = "wx_manual_taixu", GivesHerb = true, IsShanHai = true
	},
	shanhai_siwang = {
		Name = "【山海秘境】苍梧断盾铁角原", Chapter = "海内南经", Description = "古松折断、重铠凹陷的苍梧荒原，重逾千钧的独角青兕王低首蓄势，铁壁盾阵亦难正面撄锋！",
		Brush = "wx_lair_siwang", Fortified = false, FactionType = "Orcs",
		Troops = ["boss_siwang", "OrcWarrior", "OrcWarrior", "OrcBerserker", "Unhold"],
		RewardManual = "wx_manual_jinzhong", ExtraManual = "wx_manual_jiuyao_pocheng", GivesHerb = true, IsShanHai = true
	},
	shanhai_jiufeng = {
		Name = "【山海秘境】大荒鬼国九首栖魔崖", Chapter = "大荒北经", Description = "阴风惨惨不见天日的北极绝壁，九首人面的九凤妖皇展翅遮月，滴血化作妖邪鬼影！",
		Brush = "wx_lair_jiufeng", Fortified = false, FactionType = "Undead",
		Troops = ["boss_jiufeng", "Vampire", "Vampire", "Alp", "Ghost"],
		RewardManual = "wx_manual_heifeng_xuedao", ExtraManual = "wx_manual_tianmo_jieti", GivesHerb = true, IsShanHai = true
	},
	shanhai_mingshe = {
		Name = "【山海秘境】鲜山金玉旱鸣窟", Chapter = "中山经", Description = "草木枯焦而金玉裸露的鲜山石窟，生有四翼的鸣蛇盘旋洞顶，磬音未落毒牙已至！",
		Brush = "wx_lair_mingshe", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_mingshe", "Serpent", "Serpent", "Serpent", "Lindwurm"],
		RewardManual = "wx_manual_wudu_jinshe_bian", ExtraManual = "wx_manual_chansi_bian", GivesHerb = true, IsShanHai = true
	},
	shanhai_huashe = {
		Name = "【山海秘境】阳山浊水淹城墟", Chapter = "中山经", Description = "洪水漫溢的古镇废墟，人面鸟翼的化蛇潜行断垣浊浪之间，专断渡水行旅生路！",
		Brush = "wx_lair_huashe", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_huashe", "Lindwurm", "UnholdBog", "Serpent", "Serpent"],
		RewardManual = "wx_manual_taixu", ExtraManual = "wx_manual_taixu", GivesHerb = true, IsShanHai = true
	},
	shanhai_fuzhu = {
		Name = "【山海秘境】敖岸寒溪白鹿林", Chapter = "中山经", Description = "白雾终年笼罩的寒溪古林，生有四只玉角的巨大白鹿夫诸踏水无痕，似瑞实凶！",
		Brush = "wx_lair_fuzhu", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_fuzhu", "UnholdFrost", "Direwolf", "Direwolf", "Alp"],
		RewardManual = "wx_manual_taxue", ExtraManual = "wx_manual_hanbing", GivesHerb = true, IsShanHai = true
	},
	shanhai_chenghuang = {
		Name = "【山海秘境】白民古丘乘黄坛", Chapter = "海外西经", Description = "白石堆砌的西荒古祭丘，背生双角的金色神狐乘黄卧于古柏之下，轻身功夫冠绝大荒。",
		Brush = "wx_lair_chenghuang", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_chenghuang", "Hyena", "Hyena", "Direwolf", "Unhold"],
		RewardManual = "wx_manual_taixu", ExtraManual = "wx_manual_lingbo", GivesHerb = true, IsShanHai = true
	},
	shanhai_dangkang = {
		Name = "【山海秘境】钦山裂岩野猪林", Chapter = "东山经", Description = "古树尽被巨牙拱断的钦山密林，自呼其名的巨牙当康王咆哮冲阵，寻常步卒触之即溃！",
		Brush = "wx_lair_dangkang", Fortified = false, FactionType = "Orcs",
		Troops = ["boss_dangkang", "OrcBerserker", "OrcBerserker", "OrcWarrior", "Direwolf"],
		RewardManual = "wx_manual_tiebushan", ExtraManual = "wx_manual_pishan_fu", GivesHerb = true, IsShanHai = true
	},
	shanhai_boshi = {
		Name = "【山海秘境】基山奇岩九尾坡", Chapter = "南山经", Description = "温玉散落的南山奇坡，九尾四耳、双目长在脊背上的猼訑王静立山巅，十面埋伏亦奈何不得！",
		Brush = "wx_lair_boshi", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_boshi", "Unhold", "Hyena", "Hyena", "Direwolf"],
		RewardManual = "wx_manual_juyiling", ExtraManual = "wx_manual_xuanwu_budong", GivesHerb = true, IsShanHai = true
	},
	shanhai_jiao = {
		Name = "【山海秘境】玉山西王母猎兽谷", Chapter = "西山经", Description = "毗邻西王母瑶池的险峻猎谷，生有牛角的豹纹巨犬神狡成群巡猎，专碎重甲护卫咽喉！",
		Brush = "wx_lair_jiao", Fortified = false, FactionType = "Beasts",
		Troops = ["boss_jiao", "Direwolf", "Direwolf", "Direwolf", "Hyena", "Hyena"],
		RewardManual = "wx_manual_taixu", ExtraManual = "wx_manual_dugu_pojian", GivesHerb = true, IsShanHai = true
	},
	shanhai_bingyi = {
		Name = "【山海秘境】从极三百仞冰河宫", Chapter = "海内北经", Description = "终年冰封千尺的大河深渊古殿，人面乘双龙的冰夷水君端坐玄冰王座，寒气冻彻骨髓！",
		Brush = "wx_lair_bingyi", Fortified = false, FactionType = "Undead",
		Troops = ["boss_bingyi", "SkeletonHeavy", "SkeletonHeavy", "UnholdFrost", "Ghost"],
		RewardManual = "wx_manual_hanbing", ExtraManual = "wx_manual_taixu", GivesHerb = true, IsShanHai = true
	},
	shanhai_qiangliang = {
		Name = "【山海秘境】大荒北山衔蛇血祭坛", Chapter = "大荒北经", Description = "赤蛇盘柱、巨戈林立的北荒古祭坛，虎首人身的凶神强良咆哮督战，霸烈无匹！",
		Brush = "wx_lair_qiangliang", Fortified = false, FactionType = "Orcs",
		Troops = ["boss_qiangliang", "OrcWarrior", "OrcWarrior", "OrcBerserker", "Serpent", "Serpent"],
		RewardManual = "wx_manual_shanhai_chiyou", ExtraManual = "wx_manual_bawang_xiejia", GivesHerb = true, IsShanHai = true
	},
};
