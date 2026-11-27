// Monster-Hunter-Style Beast & Shan Hai Jing Forging Registry (猎妖采材 · 百工铸兵 · 山海神通全谱)
// Strictly adheres to AGENTS.md D100 anti-inflation rules:
//   - Zero permanent AP bloat, zero uncapped armor-pen stacking, light-mechanism lore passives!
//   - Dual-tier progression:
//       Tier A (百工奇物): 6 Forging Materials (`wx_mat_*`) -> 12 Mid-tier Wild-Beast Weapons/Shield/Armors/Helmets + 4 Armor Attachments
//       Tier B (山海神装): Non-destructively binds lore-accurate `【山海神通】` passives onto all 22 Shan-Hai Relic Weapons & 28 Shan-Hai Armors/Crowns/Shields!

::Wuxia.Config.BeastMaterials <- {
	wx_mat_chiling = {
		ID = "wx_mat_chiling", Name = "赤炎妖禽翎", Value = 420,
		Icon = "misc/wx_mat_chiling.png",
		Description = "取自山海凶禽与荒原狂兽翅尾的炽热硬翎，火炙不焦、破风无声。可在「百工丹坊」锻造快刀、明目皮冠与赤炎妖翎披风，亦可投入八卦丹炉。"
	},
	wx_mat_xuanlin = {
		ID = "wx_mat_xuanlin", Name = "寒渊真龙逆鳞", Value = 480,
		Icon = "misc/wx_mat_xuanlin.png",
		Description = "剥自太古蛟蟒、泽妖与真龙遗种胸腹的幽寒重鳞，水火刀箭难侵。可在「百工丹坊」锻造青鳞快剑、青鳞软甲、盘根重藤牌与寒渊真龙护心镜。"
	},
	wx_mat_xiongjiao = {
		ID = "wx_mat_xiongjiao", Name = "裂岳太古凶角", Value = 450,
		Icon = "misc/wx_mat_xiongjiao.png",
		Description = "锯自荒山独角猛兽与雷兽额顶的弯钩铁角，质逾百炼乌钢。可在「百工丹坊」锻造蚀铁骨枪与朱厌千钧巨骨锤，亦可入炉炼制阳刚丹药。"
	},
	wx_mat_shagu = {
		ID = "wx_mat_shagu", Name = "万钧战神煞骨", Value = 480,
		Icon = "misc/wx_mat_shagu.png",
		Description = "采自巨猿凶兽与上古战神遗骸的暗纹重骨，沉凝如山岳。可在「百工丹坊」锻造朱厌铁骨重札甲与战神煞骨吞肩甲，乃横练猛士至宝。"
	},
	wx_mat_renjin = {
		ID = "wx_mat_renjin", Name = "百韧天妖蛟筋", Value = 400,
		Icon = "misc/wx_mat_renjin.png",
		Description = "抽自疾风恶兽与寒潭大妖脊背的千钧韧筋，柔中带刚。可在「百工丹坊」绞制裂骨虎齿拳、赤蛛天弦角弓与天狗轻猎衣。"
	},
	wx_mat_gujing = {
		ID = "wx_mat_gujing", Name = "幽冥蚀骨毒晶", Value = 440,
		Icon = "misc/wx_mat_gujing.png",
		Description = "凝自毒谷蛊皇与幽冥异神髓腔的碧紫寒晶，奇毒阴煞交融。可在「百工丹坊」淬炼古墓寒晶镇魂胄与幽冥毒晶辟邪囊，亦可入炉合炼奇毒丹散。"
	},
	// ==================== 12 种山海大妖「破部精粹奇材」（断首/斩尾/破壳/碎阵眼定向剥取） ====================
	wx_pmat_longni = {
		ID = "wx_pmat_longni", Name = "【破部精粹】太古真龙逆鳞髓", Value = 920, IsPartEssence = true,
		Icon = "misc/wx_mat_xuanlin.png",
		Description = "击破应龙、烛阴、共工、巴蛇等真龙遗脉护心逆鳞方能剥取的沧海髓片。可在「百工丹坊」锻造剑枪器魂铭文或作寒潭锁词奇材。"
	},
	wx_pmat_jiushou = {
		ID = "wx_pmat_jiushou", Name = "【破部精粹】九首凶妖再生毒腺", Value = 880, IsPartEssence = true,
		Icon = "misc/wx_mat_gujing.png",
		Description = "斩断相柳、九婴、九凤、肥遗等九首大妖毒颈所截获的活体毒腺。乃淬炼断续封生秘膏与奇毒血槽铭文的怨念主材。"
	},
	wx_pmat_xuanjia = {
		ID = "wx_pmat_xuanjia", Name = "【破部精粹】不坏玄甲镇海残片", Value = 900, IsPartEssence = true,
		Icon = "misc/wx_mat_shagu.png",
		Description = "以重锤寸劲轰碎杻阳玄龟、防风巨骨、凿齿戈盾所得的太古玄壳残片。可锻造破障奇门重器与重甲百炼锁词。"
	},
	wx_pmat_jinwu_yu = {
		ID = "wx_pmat_jinwu_yu", Name = "【破部精粹】十日扶桑真火金翎", Value = 900, IsPartEssence = true,
		Icon = "misc/wx_mat_chiling.png",
		Description = "折断三足金乌、毕方、鹓鶵、祸斗炎翼所得的不灭金翎。可镶铸狂刀火铳刀锷铭，或引动地肺赤火塑形。"
	},
	wx_pmat_fengyi = {
		ID = "wx_pmat_fengyi", Name = "【破部精粹】裂空幻步天妖风翼", Value = 860, IsPartEssence = true,
		Icon = "misc/wx_mat_renjin.png",
		Description = "斩落帝江、飞廉、穷奇、天狗风翼疾爪所得的幻空翼膜。可编织太清流云剑穗与神射弓弦。"
	},
	wx_pmat_bingzhu_jiao = {
		ID = "wx_pmat_bingzhu_jiao", Name = "【破部精粹】万古兵主裂岳凶角", Value = 940, IsPartEssence = true,
		Icon = "misc/wx_mat_xiongjiao.png",
		Description = "碎额拔自蚩尤、铁驳、青兕、赤狰的百炼钢角。可锻造墨家断龙破障钉与破甲刀戟配件。"
	},
	wx_pmat_leigu = {
		ID = "wx_pmat_leigu", Name = "【破部精粹】流波紫电雷兽夔骨", Value = 910, IsPartEssence = true,
		Icon = "misc/wx_mat_shagu.png",
		Description = "击碎夔牛独足、朱厌狂臂、檮杌虎骨所得的紫电雷髓骨。可雕琢昆仑寒玉寸劲箍与雷音锤箍。"
	},
	wx_pmat_baize_tong = {
		ID = "wx_pmat_baize_tong", Name = "【破部精粹】通玄破妄灵兽神瞳", Value = 920, IsPartEssence = true,
		Icon = "misc/wx_mat_gujing.png",
		Description = "破除白泽、九尾天狐、武罗、猼訑护身妖阵凝出的澄澈灵瞳。可打造奇门破障机括与通玄丹引。"
	},
	wx_pmat_qinyuan_zhen = {
		ID = "wx_pmat_qinyuan_zhen", Name = "【破部精粹】昆仑蜇石蚀骨尾针", Value = 890, IsPartEssence = true,
		Icon = "misc/wx_mat_gujing.png",
		Description = "斩尾拔自昆仑毒皇钦原、太山白首蜚的幽碧蚀石毒针。乃合炼《钦原断续蚀壳膏》与拒马毒蒺藜的核心奇材！"
	},
	wx_pmat_taotie_chi = {
		ID = "wx_pmat_taotie_chi", Name = "【破部精粹】吞天凶神噬元虎齿", Value = 900, IsPartEssence = true,
		Icon = "misc/wx_mat_xiongjiao.png",
		Description = "碎颚拔自饕餮、狍鸮、猰貐的噬血凶牙。可用于凶兽煞血淬火塑形与饮血重兵锻造。"
	},
	wx_pmat_xingtian_sui = {
		ID = "wx_pmat_xingtian_sui", Name = "【破部精粹】常羊不灭战神刑髓", Value = 950, IsPartEssence = true,
		Icon = "misc/wx_mat_shagu.png",
		Description = "击破常羊刑天、疏属贰负、奢比尸战魂阵核所得的不灭战髓。可锻造镇尸奇门器械与绝境战魂铭文。"
	},
	wx_pmat_jianmu_zhi = {
		ID = "wx_pmat_jianmu_zhi", Name = "【破部精粹】都广建木万年灵脂", Value = 880, IsPartEssence = true,
		Icon = "misc/wx_mat_renjin.png",
		Description = "伐枝取自句芒建木、陆吾、乘黄、夫诸的生生灵脂。可温养护腕盾牌或逆炼生机奇丹。"
	}
};

// Wild Shan-Hai Beasts drop forging materials when slain by player-controlled units (strictly gated on swarm mobs)
::Wuxia.Config.WildBeastDrops <- {
	Unhold      = { Chance = 28, Pool = ["wx_mat_shagu", "wx_mat_xiongjiao"] },
	UnholdFrost = { Chance = 32, Pool = ["wx_mat_shagu", "wx_mat_xuanlin"] },
	UnholdBog   = { Chance = 30, Pool = ["wx_mat_renjin", "wx_mat_shagu"] },
	Lindwurm    = { Chance = 38, Pool = ["wx_mat_xuanlin", "wx_mat_renjin"] },
	Serpent     = { Chance = 10, Pool = ["wx_mat_xuanlin", "wx_mat_renjin"] },
	Direwolf    = { Chance = 6,  Pool = ["wx_mat_renjin", "wx_mat_chiling"] },
	Hyena       = { Chance = 6,  Pool = ["wx_mat_chiling", "wx_mat_renjin"] },
	Ghoul       = { Chance = 6,  Pool = ["wx_mat_renjin", "wx_mat_xiongjiao"] },
	Spider      = { Chance = 5,  Pool = ["wx_mat_renjin"] },
	Alp         = { Chance = 12, Pool = ["wx_mat_gujing"] },
	Hexe        = { Chance = 32, Pool = ["wx_mat_gujing", "wx_mat_chiling"] },
	Schrat      = { Chance = 35, Pool = ["wx_mat_shagu", "wx_mat_renjin"] },
	Kraken      = { Chance = 100, Pool = ["wx_mat_xuanlin", "wx_mat_gujing"] }
};

// Every single one of the 64 Shan-Hai Lair Apex Bosses drops:
//   1x Boss Neidan Core (`wx_core_*`) + 1~2x Forging Material (`wx_mat_*`) + 1x Beast Trophy (`scripts/items/misc/*_item`)
::Wuxia.Config.BossBonusLoot <- {
	zhuyan       = { Mat = "wx_mat_shagu",    Trophy = "unhold_hide_item" },
	feiyi        = { Mat = "wx_mat_xuanlin",  Trophy = "lindwurm_scales_item" },
	qiongqi      = { Mat = "wx_mat_renjin",   Trophy = "hyena_fur_item" },
	taotie       = { Mat = "wx_mat_xiongjiao",Trophy = "ghoul_horn_item" },
	jiuwei       = { Mat = "wx_mat_gujing",   Trophy = "witch_hair_item" },
	bashe        = { Mat = "wx_mat_xuanlin",  Trophy = "serpent_skin_item" },
	jumang       = { Mat = "wx_mat_shagu",    Trophy = "glowing_resin_item" },
	wuzhiqi      = { Mat = "wx_mat_renjin",   Trophy = "poison_gland_item" },
	xingtian     = { Mat = "wx_mat_shagu",    Trophy = "unhold_bones_item" },
	bifang       = { Mat = "wx_mat_chiling",  Trophy = "vampire_dust_item" },
	gudiaowang   = { Mat = "wx_mat_chiling",  Trophy = "hyena_fur_item" },
	xingxing     = { Mat = "wx_mat_renjin",   Trophy = "unhold_hide_item" },
	zhujian      = { Mat = "wx_mat_xiongjiao",Trophy = "ghoul_teeth_item" },
	xuangui      = { Mat = "wx_mat_xuanlin",  Trophy = "lindwurm_scales_item" },
	yuanchu      = { Mat = "wx_mat_chiling",  Trophy = "vampire_dust_item" },
	yingzhao     = { Mat = "wx_mat_chiling",  Trophy = "hyena_fur_item" },
	luwu         = { Mat = "wx_mat_xiongjiao",Trophy = "unhold_hide_item" },
	qinyuan      = { Mat = "wx_mat_gujing",   Trophy = "poison_gland_item" },
	tiangouwang  = { Mat = "wx_mat_chiling",  Trophy = "werewolf_pelt_item" },
	zheng        = { Mat = "wx_mat_xiongjiao",Trophy = "hyena_fur_item" },
	hundun       = { Mat = "wx_mat_shagu",    Trophy = "unhold_heart_item" },
	yayu         = { Mat = "wx_mat_gujing",   Trophy = "ghoul_teeth_item" },
	zhuyin       = { Mat = "wx_mat_xuanlin",  Trophy = "lindwurm_bones_item" },
	dijiang      = { Mat = "wx_mat_renjin",   Trophy = "spider_silk_item" },
	paoxiaowang  = { Mat = "wx_mat_xiongjiao",Trophy = "ghoul_brain_item" },
	changyou     = { Mat = "wx_mat_renjin",   Trophy = "unhold_hide_item" },
	mengji       = { Mat = "wx_mat_renjin",   Trophy = "werewolf_pelt_item" },
	kui          = { Mat = "wx_mat_xiongjiao",Trophy = "unhold_hide_item" },
	fei          = { Mat = "wx_mat_gujing",   Trophy = "poison_gland_item" },
	yinglong     = { Mat = "wx_mat_xuanlin",  Trophy = "lindwurm_scales_item" },
	taowu        = { Mat = "wx_mat_shagu",    Trophy = "unhold_bones_item" },
	hujiao       = { Mat = "wx_mat_xuanlin",  Trophy = "glistening_scales_item" },
	zhuhuai      = { Mat = "wx_mat_xiongjiao",Trophy = "ghoul_horn_item" },
	shebishi     = { Mat = "wx_mat_gujing",   Trophy = "parched_skin_item" },
	jingwei      = { Mat = "wx_mat_chiling",  Trophy = "petrified_scream_item" },
	jiuying      = { Mat = "wx_mat_xuanlin",  Trophy = "lindwurm_blood_item" },
	feilian      = { Mat = "wx_mat_chiling",  Trophy = "werewolf_pelt_item" },
	baize        = { Mat = "wx_mat_gujing",   Trophy = "third_eye_item" },
	shanhui      = { Mat = "wx_mat_renjin",   Trophy = "werewolf_pelt_item" },
	bo           = { Mat = "wx_mat_xiongjiao",Trophy = "unhold_bones_item" },
	huodou       = { Mat = "wx_mat_chiling",  Trophy = "werewolf_pelt_item" },
	xiangliuwang = { Mat = "wx_mat_renjin",   Trophy = "lindwurm_blood_item" },
	kuafu        = { Mat = "wx_mat_shagu",    Trophy = "heart_of_the_forest_item" },
	chiyou       = { Mat = "wx_mat_shagu",    Trophy = "unhold_bones_item" },
	zaochi       = { Mat = "wx_mat_shagu",    Trophy = "ghoul_teeth_item" },
	erfu         = { Mat = "wx_mat_gujing",   Trophy = "parched_skin_item" },
	nvchou       = { Mat = "wx_mat_gujing",   Trophy = "witch_hair_item" },
	fangfeng     = { Mat = "wx_mat_shagu",    Trophy = "unhold_bones_item" },
	kaiming      = { Mat = "wx_mat_xiongjiao",Trophy = "unhold_hide_item" },
	jinwu        = { Mat = "wx_mat_chiling",  Trophy = "vampire_dust_item" },
	zouyu        = { Mat = "wx_mat_renjin",   Trophy = "hyena_fur_item" },
	gonggong     = { Mat = "wx_mat_xuanlin",  Trophy = "glistening_scales_item" },
	wuluo        = { Mat = "wx_mat_gujing",   Trophy = "witch_hair_item" },
	siwang       = { Mat = "wx_mat_xiongjiao",Trophy = "unhold_hide_item" },
	jiufeng      = { Mat = "wx_mat_chiling",  Trophy = "witch_hair_item" },
	mingshe      = { Mat = "wx_mat_xuanlin",  Trophy = "serpent_skin_item" },
	huashe       = { Mat = "wx_mat_xuanlin",  Trophy = "glistening_scales_item" },
	fuzhu        = { Mat = "wx_mat_xiongjiao",Trophy = "werewolf_pelt_item" },
	chenghuang   = { Mat = "wx_mat_xiongjiao",Trophy = "hyena_fur_item" },
	dangkang     = { Mat = "wx_mat_xiongjiao",Trophy = "ghoul_teeth_item" },
	boshi        = { Mat = "wx_mat_gujing",   Trophy = "third_eye_item" },
	jiao         = { Mat = "wx_mat_xiongjiao",Trophy = "werewolf_pelt_item" },
	bingyi       = { Mat = "wx_mat_xuanlin",  Trophy = "petrified_scream_item" },
	qiangliang   = { Mat = "wx_mat_shagu",    Trophy = "poison_gland_item" }
};

// Declarative Equipment Passive Trait Registry (drives BOTH item tooltips & `special.wx_gear_spirit_trait` runtime!)
::Wuxia.Config.GearTraits <- {
	// ==================== Tier A: 百工兽魄 (12 件百工兵甲全谱深度机制化) ====================
	beast_fist_leech = {
		Tier = "beast", Title = "噬血裂骨", Icon = "ui/icons/health.png",
		Text = "攻击流血或【失衡】猎物额外崩损 [color=#0a4213]8[/color] 点身甲；近战斩杀活物啖血恢复 [color=#0a4213]+8[/color] 气血与 [color=#0a4213]+3[/color] 内息（每轮限 1 次）",
		OnKillHealHP = 8, OnKillQiRegen = 3, KillHealCap = 1, BeastMode = "fist_leech"
	},
	beast_sword_venom = {
		Tier = "beast", Title = "青鳞催毒", Icon = "ui/icons/special.png",
		Text = "伤血 ≥4 时 [color=#0a4213]40%[/color] 施加【暗器奇毒】；刺中已中毒猎物时滑刃命中 [color=#0a4213]+5[/color] 并抽散其 [color=#0a4213]5[/color] 点内息",
		OnHitPoisonPct = 40, BeastMode = "sword_venom"
	},
	beast_saber_dread = {
		Tier = "beast", Title = "婴啼裂创", Icon = "ui/icons/melee_skill.png",
		Text = "攻击动摇/崩溃之敌命中 [color=#0a4213]+8[/color]（[color=#0a4213]45%[/color] 撕开流血）；斩中已流血目标发出凄厉婴啼迫使其执行 [color=#0a4213]-8[/color] 定力检定",
		VsShakenHit = 8, OnHitBleedPct = 45, BeastMode = "saber_dread"
	},
	beast_spear_acid = {
		Tier = "beast", Title = "紫血蚀壳", Icon = "ui/icons/armor_damage.png",
		Text = "肥遗毒血专克荒兽硬皮：迎战异兽与山海大妖总伤 [color=#0a4213]+10%[/color]，近战刺中额外腐蚀 [color=#0a4213]10[/color] 点身甲",
		VsBeastDmgPct = 0.10, OnHitArmorBurn = 10
	},
	beast_hammer_quake = {
		Tier = "beast", Title = "千钧震岳", Icon = "ui/icons/special.png",
		Text = "重击（≥14 气血伤或 ≥25 损甲）有 [color=#0a4213]45%[/color] 概率将敌手震至【失衡】，对蓄力凶兽破招值 [color=#0a4213]+1[/color]",
		OnHitOffbalanceHeavyPct = 45, OnHeavyBossBreak = 1
	},
	beast_bow_venom = {
		Tier = "beast", Title = "蛛丝缠脉", Icon = "ui/icons/ranged_skill.png",
		Text = "伤血 ≥4 时 [color=#0a4213]40%[/color] 施加【暗器奇毒】并削减目标本轮 [color=#0a4213]10[/color] 先攻；射击被蛛网/捕网/藤蔓定身目标破甲额外 [color=#0a4213]+20%[/color]",
		OnHitPoisonPct = 40, BeastMode = "bow_venom"
	},
	beast_shield_regen = {
		Tier = "beast", Title = "生机盘根", Icon = "ui/icons/shield_damage.png",
		Text = "建木灵脂滋养藤牌：每回合初修复 [color=#0a4213]4[/color] 点盾耐久（立于草泽/寒露清明地脉翻倍至 [color=#0a4213]8[/color] 点），远伤 [color=#0a4213]-10%[/color]",
		TurnRegenShield = 4, EcoDoubleShieldRegen = true, RangedDmgMult = 0.90
	},
	beast_armor_swift = {
		Tier = "beast", Title = "天狗逐风", Icon = "ui/icons/initiative.png",
		Text = "轻韧无声（契合《金蝉卸力》）：常驻身法 [color=#0a4213]+6[/color]、开场首轮额外 [color=#0a4213]+8[/color]，且林莽雪泽跋涉行气消耗 [color=#0a4213]-25%[/color]",
		Stats = { Initiative = 6 }, FirstRoundInit = 8, BeastMode = "armor_swift"
	},
	beast_armor_scales = {
		Tier = "beast", Title = "滑鳞卸刃", Icon = "ui/icons/ranged_defense.png",
		Text = "避暗 [color=#0a4213]+5[/color]、远伤 [color=#0a4213]-15%[/color]；每轮首次遭近战劈砍滑卸 [color=#0a4213]-15%[/color] 破甲冲击且 [color=#0a4213]25%[/color] 反染微毒",
		Stats = { RangedDefense = 5 }, RangedDmgMult = 0.85, ThornsPoisonPct = 25, BeastMode = "armor_scales"
	},
	beast_armor_vital = {
		Tier = "beast", Title = "巨猿磐骨", Icon = "ui/icons/health.png",
		Text = "气血上限 [color=#0a4213]+10[/color]、外伤承受阈值 [color=#0a4213]+20%[/color]，下盘沉稳免疫击退抓取，半血以下定力额外 [color=#0a4213]+8[/color]",
		Stats = { Hitpoints = 10 }, InjuryThresholdMult = 1.20, ImmuneKnockback = true, LowHpThreshold = 0.50, LowHpResolve = 8
	},
	beast_helm_owl = {
		Tier = "beast", Title = "三目勘幻", Icon = "ui/icons/vision.png",
		Text = "嵌讹兽灵眸：定力 [color=#0a4213]+6[/color]，夜战视物如昼，且在烟幕/青丘迷雾中攻击命中额外 [color=#0a4213]+6[/color]",
		Stats = { Bravery = 6 }, NightOwl = true, SmokeSightHit = 6
	},
	beast_helm_ward = {
		Tier = "beast", Title = "寒晶破魇", Icon = "ui/icons/bravery.png",
		Text = "定力 [color=#0a4213]+8[/color]、抗惊骇检定 [color=#0a4213]+12[/color]；每回合初寒晶清灵自动震破自身【魅惑 / 梦魇沉眠】幻术",
		Stats = { Bravery = 8 }, AntiFearBonus = 12, BeastMode = "helm_ward"
	},

	// ==================== Tier R: 37 把历史传世名器 · 专属器灵神韵（全谱实装） ====================
	relic_taie = {
		Tier = "relic", Title = "威道三军", Icon = "ui/icons/bravery.png",
		Text = "《越绝书》威道名剑：【战意高昂】时近战命中迫使敌手执行 [color=#0a4213]-12[/color] 定力检定；攻击动摇/崩溃之敌破甲 [color=#0a4213]+15%[/color] 且持盾目标近防失效 [color=#0a4213]+12[/color] 命中",
		RelicMode = "taie"
	},
	relic_longyuan = {
		Tier = "relic", Title = "临渊澄心", Icon = "ui/icons/melee_defense.png",
		Text = "七星铜钉导气：施展【穿步】或处于【反击架势】时剑招耗气 [color=#0a4213]-15%[/color]；自身未露破绽/失衡时常驻招架 [color=#0a4213]+4[/color]、借机反击命中 [color=#0a4213]+10[/color]",
		ZoCBonusHit = 10, RelicMode = "longyuan"
	},
	relic_chengying = {
		Tier = "relic", Title = "暮色无影", Icon = "ui/icons/vision.png",
		Text = "《列子》旦暮有影莫知其形：处于夜间、烟幕或雾瘴地格时近战命中 [color=#0a4213]+18[/color] 且无视敌手闪避；施展穿步剑招或刺中受控目标返还 [color=#0a4213]+4[/color] 内息（每轮限 2 次）",
		ChengyingMode = true
	},
	relic_ganjiang = {
		Tier = "relic", Title = "龟纹寻隙·雄剑共鸣", Icon = "ui/icons/armor_damage.png",
		Text = "专刺重铠甲缝（身甲≥90 目标 [color=#0a4213]45%[/color] 震露【破绽】，施展乘隙招式额外削 [color=#0a4213]14[/color] 身甲）；4 格内同袍执《莫邪》时激发【雌雄双剑共鸣】：近防 [color=#0a4213]+3[/color]，命中令双剑侠客各回 [color=#0a4213]+3[/color] 内息",
		PartnerRelic = "wx_relic_moye", ResonanceMDef = 3, GanjiangMode = true
	},
	relic_moye = {
		Tier = "relic", Title = "秋水封喉·雌剑共鸣", Icon = "ui/icons/melee_skill.png",
		Text = "薄刃见血（伤血≥4 时 [color=#0a4213]55%[/color] 撕开流血，施展引血招式自回 [color=#0a4213]+4[/color] 内息）；4 格内同袍执《干将》时激发【雌雄双剑共鸣】：近防 [color=#0a4213]+3[/color]，命中破绽/流血敌引爆 [color=#0a4213]10[/color] 点剑气实伤与 [color=#0a4213]10[/color] 损甲",
		PartnerRelic = "wx_relic_ganjiang", ResonanceMDef = 3, OnHitBleedPct = 55, MoyeMode = true
	},
	relic_chixiao = {
		Tier = "relic", Title = "芒砀斩蛇", Icon = "ui/icons/bravery.png",
		Text = "帝道斩蛇长剑：迎战异兽、山海大妖与尸傀总伤 [color=#0a4213]+14%[/color]；重创（伤血≥25）或斩杀时振奋周身 2 格内动摇同袍重归稳定（每场限 2 次）",
		RelicMode = "chixiao"
	},
	relic_juque = {
		Tier = "relic", Title = "重剑裂阙", Icon = "ui/icons/shield_damage.png",
		Text = "越王五剑之首：劈盾额外 [color=#0a4213]+18[/color] 碎盾伤；单击造成 ≥28 损甲时以千钧巨力震退目标 1 格（受阻则化 [color=#0a4213]+12[/color] 撞击损甲）并施加【失衡】",
		ShieldBreakBonus = 18, RelicMode = "juque"
	},
	relic_longque = {
		Tier = "relic", Title = "金龙衔雀", Icon = "ui/icons/armor_damage.png",
		Text = "赫连百炼环首刀：对护甲完好度 ≥50% 之敌破甲效能 [color=#0a4213]+18%[/color]；斩碎目标身甲或重创裸甲之敌时刀环金鸣迫检 [color=#0a4213]-15[/color] 定力并必露【破绽】",
		RelicMode = "longque"
	},
	relic_minghong = {
		Tier = "relic", Title = "未出先鸣", Icon = "ui/icons/initiative.png",
		Text = "轩辕遗金神刀：处于【居合蓄势】或每场对每名敌手拔刀首击时命中 [color=#0a4213]+12[/color]，刀鸣先至震散目标 [color=#0a4213]8[/color] 点内息",
		RelicMode = "minghong"
	},
	relic_xiuchun = {
		Tier = "relic", Title = "缇骑缉枭", Icon = "ui/icons/melee_skill.png",
		Text = "锦衣指挥使佩刀：施展【步进刀招】或攻击流血/点穴/破绽目标命中 [color=#0a4213]+8[/color]；斩杀敌手立回 [color=#0a4213]+5[/color] 内息且下轮先攻身法 [color=#0a4213]+12[/color]",
		OnKillQiRegen = 5, RelicMode = "xiuchun"
	},
	relic_modao = {
		Tier = "relic", Title = "如墙俱碎", Icon = "ui/icons/armor_damage.png",
		Text = "安西破阵长柄陌刀：持刀免疫冲撞击退；迎战山海巨妖、异兽及蓄力目标总伤 [color=#0a4213]+15%[/color]，命中强行斩断敌方反击与盾墙架势",
		ImmuneKnockback = true, RelicMode = "modao"
	},
	relic_kunwu = {
		Tier = "relic", Title = "流沙切玉", Icon = "ui/icons/melee_skill.png",
		Text = "西域赤铜重弯刀：弧刃走滑对持盾目标近战命中 [color=#0a4213]+10[/color]；同回合连斩同一目标第 2 刀必撕开深创流血（8 点/轮）",
		RelicMode = "kunwu"
	},
	relic_tulong = {
		Tier = "relic", Title = "大巧不工", Icon = "ui/icons/armor_damage.png",
		Text = "乌金沉水重刀：施展【震甲重招】或损甲≥22 时额外震散目标 [color=#0a4213]10[/color] 点内息，并震碎山海大妖 [color=#0a4213]1[/color] 层【太古玄壳】",
		RelicMode = "tulong"
	},
	relic_liquan = {
		Tier = "relic", Title = "万夫莫开", Icon = "ui/icons/melee_defense.png",
		Text = "岳武穆抗金神枪：控制区借机拦击命中 [color=#0a4213]+12[/color]、拦击耗气减半，且刺中突进之敌 [color=#0a4213]50%[/color] 概率令其【失衡】",
		ZoCBonusHit = 12, RelicMode = "liquan"
	},
	relic_hutouqiang = {
		Tier = "relic", Title = "金虎透背", Icon = "ui/icons/chance_to_hit_head.png",
		Text = "名将两格攒刺重枪：施展【贯线刺】取首率 [color=#0a4213]+12%[/color]；刺中已露【破绽】之敌时枪劲透背震损相邻敌影 [color=#0a4213]12[/color] 点身甲",
		RelicMode = "hutouqiang"
	},
	relic_huaji = {
		Tier = "relic", Title = "画戟钩锁", Icon = "ui/icons/special.png",
		Text = "双月牙耳配中宫枪尖：施展【钩拉/破防】招式命中必同时挂上【破绽】与【失衡】；攻击兼负破绽与失衡之敌总伤 [color=#0a4213]+14%[/color]",
		RelicMode = "huaji"
	},
	relic_yanyue = {
		Tier = "relic", Title = "锯背裂阵", Icon = "ui/icons/armor_damage.png",
		Text = "八十二斤冷艳锯：周身 2 格内存在 ≥2 名敌军时破甲效能 [color=#0a4213]+18%[/color]，锯齿回拖有 [color=#0a4213]50%[/color] 概率撕裂流血",
		OnHitBleedPct = 50, RelicMode = "yanyue"
	},
	relic_goulianqiang = {
		Tier = "relic", Title = "倒钩破骑", Icon = "ui/icons/melee_skill.png",
		Text = "专克重骑巨兽：攻击身甲≥120 重甲敌或异兽时命中 [color=#0a4213]+9[/color]，命中 [color=#0a4213]45%[/color] 概率钩伤下盘同挂【破绽】与【失衡】",
		RelicMode = "goulianqiang"
	},
	relic_bawangqiang = {
		Tier = "relic", Title = "力拔山河", Icon = "ui/icons/armor_damage.png",
		Text = "西楚百斤乌金枪：重刺造成 ≥18 气血伤时震退目标 1 格；若目标免退或身后受阻，则化为额外 [color=#0a4213]14[/color] 点撞击损甲与 [color=#0a4213]6[/color] 点散气",
		RelicMode = "bawangqiang"
	},
	relic_huntiegun = {
		Tier = "relic", Title = "护寺雷音", Icon = "ui/icons/melee_defense.png",
		Text = "少室齐眉混铁棍：抗围近防补正 [color=#0a4213]+3[/color]；施展【震甲】棍招命中时盘龙棍风同时震散主目标与相邻敌影各 [color=#0a4213]6[/color] 点内息",
		RelicMode = "huntiegun"
	},
	relic_lvzhuzhang = {
		Tier = "relic", Title = "打狗绊摔", Icon = "ui/icons/melee_defense.png",
		Text = "丐帮帮主信物：借机反击或控场棍招命中 [color=#0a4213]55%[/color] 绊倒敌手【失衡】；敌方近战攻击自身落空时借力回 [color=#0a4213]+3[/color] 内息（每轮限 2 次）",
		RelicMode = "lvzhuzhang"
	},
	relic_longlinzhao = {
		Tier = "relic", Title = "锁刃探爪", Icon = "ui/icons/melee_skill.png",
		Text = "天蚕乌金鹰爪：施展点穴/擒拿/夺刃拳招命中 [color=#0a4213]+9[/color]、耗气 [color=#0a4213]-15%[/color]；抓中持械敌手震麻手腕散气 [color=#0a4213]5[/color] 点并 [color=#0a4213]45%[/color] 致失衡",
		RelicMode = "longlinzhao"
	},
	relic_jingangwan = {
		Tier = "relic", Title = "隔甲震腑", Icon = "ui/icons/direct_damage.png",
		Text = "少室寒铁重护腕：攻击身甲≥80 目标激发隔山寸劲，额外穿甲 [color=#0a4213]+8%[/color]（严守 25% 上限）、震损 [color=#0a4213]10[/color] 甲，并对蓄力大妖注入 [color=#0a4213]+1[/color] 破招值",
		RelicMode = "jingangwan"
	},
	relic_wengjinchui = {
		Tier = "relic", Title = "双瓮轰雷", Icon = "ui/icons/armor_damage.png",
		Text = "隋唐阔面双瓮锤：重锤命中额外崩碎 [color=#0a4213]20[/color] 点身甲，讨伐【玄甲磐石】大妖时每次重击额外多碎 [color=#0a4213]1[/color] 层太古硬壳",
		OnHitArmorBurn = 20, RelicMode = "wengjinchui"
	},
	relic_shutongjian = {
		Tier = "relic", Title = "杀手撒手锏", Icon = "ui/icons/special.png",
		Text = "秦叔宝四棱重铜锏：造成外伤阈值降低 [color=#0a4213]20%[/color]；乘敌【破绽】一锏命中时有 [color=#0a4213]45%[/color] 概率直接截脉【点穴】",
		RelicMode = "shutongjian"
	},
	relic_jinzuan_chui = {
		Tier = "relic", Title = "隔阵碎橹", Icon = "ui/icons/shield_damage.png",
		Text = "边关破城长柄锤：两格砸盾额外 [color=#0a4213]+16[/color] 碎盾伤，单击损甲 ≥25 时必将目标砸入【失衡】",
		ShieldBreakBonus = 16, RelicMode = "jinzuan_chui"
	},
	relic_xuanhuafu = {
		Tier = "relic", Title = "宣花三板斧", Icon = "ui/icons/armor_damage.png",
		Text = "程知节三板定江山：每场战斗前 [color=#0a4213]3[/color] 记近战劈砍激发神威——命中 [color=#0a4213]+8[/color]、破甲 [color=#0a4213]+20%[/color] 且挥斧返还 [color=#0a4213]+3[/color] 内息",
		RelicMode = "xuanhuafu"
	},
	relic_pochengyue = {
		Tier = "relic", Title = "王陵血祭", Icon = "ui/icons/health.png",
		Text = "商周饕餮青铜钺：攻击流血目标总伤 [color=#0a4213]+10%[/color]（45% 撕裂流血）；劈中流血活物或斩杀时吞血恢复 [color=#0a4213]+6[/color] 血 [color=#0a4213]+3[/color] 气（每轮限 2 次）",
		OnHitBleedPct = 45, RelicMode = "pochengyue"
	},
	relic_kaitian_changfu = {
		Tier = "relic", Title = "劈山断橹", Icon = "ui/icons/shield_damage.png",
		Text = "辽东两格开山斧：碎盾伤害 [color=#0a4213]+15[/color]；施展【破盾】招式或劈击持盾敌手时裂劲透盾削去 [color=#0a4213]18[/color] 点身甲并挂【破绽】",
		ShieldBreakBonus = 15, RelicMode = "kaitian_changfu"
	},
	relic_wujinbian = {
		Tier = "relic", Title = "越盾敲颅", Icon = "ui/icons/fatigue.png",
		Text = "呼延乌金竹节鞭：绕盾或击中头部额外震散目标 [color=#0a4213]9[/color] 点内息，击头有 [color=#0a4213]50%[/color] 概率令敌陷入【失衡】",
		RelicMode = "wujinbian"
	},
	relic_dashenbian = {
		Tier = "relic", Title = "蛟筋卷脉", Icon = "ui/icons/special.png",
		Text = "九节软金长鞭：抽击伤血≥5 必挂流血，并对蓄力读条之大妖/强敌造成锁喉扰气（【破招值】 [color=#0a4213]+1[/color]）",
		RelicMode = "dashenbian"
	},
	relic_yuchang = {
		Tier = "relic", Title = "炙鱼透甲", Icon = "ui/icons/direct_damage.png",
		Text = "刺透三层棠溪甲：攻击受控【破绽/失衡/点穴/眩晕/网缚】目标时命中 [color=#0a4213]+10[/color]、额外穿甲 [color=#0a4213]+10%[/color]（严守全身 25% 封顶）",
		RelicMode = "yuchang"
	},
	relic_xufuren = {
		Tier = "relic", Title = "图穷匕见", Icon = "ui/icons/special.png",
		Text = "燕丹百草淬毒寒匕：合围背刺或烟幕出匕时取首率 [color=#0a4213]+12%[/color]，伤血 ≥4 有 [color=#0a4213]55%[/color] 概率注入【暗器奇毒】",
		OnHitPoisonPct = 55, RelicMode = "xufuren"
	},
	relic_zhentiangong = {
		Tier = "relic", Title = "三箭定天山", Icon = "ui/icons/ranged_skill.png",
		Text = "薛仁贵铁胎龙角弓：占据高地或距离 ≥5 格远射时破甲效能 [color=#0a4213]+20%[/color]，且箭劲有 [color=#0a4213]45%[/color] 概率震开目标【破绽】",
		RelicMode = "zhentiangong"
	},
	relic_shenbinu = {
		Tier = "relic", Title = "踏张贯铁", Icon = "ui/icons/ranged_skill.png",
		Text = "韩世忠改良克敌重弩：射击身甲≥100 重甲敌或山海大妖时远程命中 [color=#0a4213]+8[/color]、额外贯损 [color=#0a4213]14[/color] 点身甲",
		RelicMode = "shenbinu"
	},
	relic_xunleichong = {
		Tier = "relic", Title = "五雷连珠·硝烟蔽阵", Icon = "ui/icons/armor_damage.png",
		Text = "赵士祯《神器谱》五雷连珠铳：铅砂轰击对每名命中目标灼损 [color=#0a4213]10[/color] 身甲（[color=#0a4213]40%[/color] 失衡）；同回合轰中 ≥2 名敌军时激发连珠硝烟——立回 [color=#0a4213]+4[/color] 内息且本轮避暗 [color=#0a4213]+8[/color]",
		OnHitArmorBurn = 10, OnHitOffbalancePct = 40, RelicMode = "xunleichong"
	},
	relic_feidaonang = {
		Tier = "relic", Title = "例不虚发", Icon = "ui/icons/ranged_skill.png",
		Text = "巴蜀十二柳叶寒星刀：≤3 格对已露【破绽】之敌投掷命中 [color=#0a4213]+12[/color]；乘隙命中或斩杀时回收 [color=#0a4213]1[/color] 枚飞刀（每场限 3 枚）",
		RelicMode = "feidaonang"
	},

	// ==================== Tier B1: 山海神通 · 22 柄山海神兵（法相神通重塑） ====================
	shanhai_xingtian = {
		Tier = "shanhai", Title = "常羊不灭战魂", Icon = "ui/icons/shield_damage.png",
		Text = "劈盾额外 [color=#0a4213]+12[/color] 碎盾伤；气血低于 50% 时激发无首战魂——总伤 [color=#0a4213]+12%[/color] 且彻底免疫棒槌震晕",
		ShieldBreakBonus = 12, LowHpThreshold = 0.50, LowHpDmgPct = 0.12, LowHpImmuneStun = true
	},
	shanhai_qiongqi_wpn = {
		Tier = "shanhai", Title = "裂风噬忠", Icon = "ui/icons/melee_skill.png",
		Text = "专噬忠勇豪杰：对定力 ≥60 或高昂之敌命中 [color=#0a4213]+8[/color]，伤血 ≥5 时 [color=#0a4213]50%[/color] 撕裂流血并夺其 [color=#0a4213]4[/color] 点内息",
		VsHighResolveHit = 8, OnHitBleedPct = 50, OnHitDrainQi = 4
	},
	shanhai_yinglong = {
		Tier = "shanhai", Title = "沧海蓄水·引雷导脉", Icon = "ui/icons/armor_damage.png",
		Text = "处于浅水/沼泽/霜雪/寒露地脉时近战命中 [color=#0a4213]+6[/color]、出招省气 [color=#0a4213]-2[/color]；命中震损 [color=#0a4213]12[/color] 身甲（35% 破绽），水泽导电或施展【贯线刺】时激起应龙雷弧电击相邻敌影（[color=#0a4213]10[/color] 雷伤 + 散气 [color=#0a4213]6[/color]）",
		OnHitArmorBurn = 12, OnHitOpeningPct = 35, YinglongLightning = true
	},
	shanhai_zhuyin_wpn = {
		Tier = "shanhai", Title = "视为昼瞑为夜", Icon = "ui/icons/special.png",
		Text = "单数轮【瞑夜寒冬】自身双防 [color=#0a4213]+4[/color]、近战抽散 [color=#0a4213]8[/color] 气并 [color=#0a4213]45%[/color] 凝结寒霜；双数轮【开目赤昼】总伤 [color=#0a4213]+12%[/color]、灼毁 [color=#0a4213]14[/color] 身甲并自涤寒凝",
		ZhuyinBladeCycle = true
	},
	shanhai_jinwu_saber = {
		Tier = "shanhai", Title = "十日焚锋", Icon = "ui/icons/armor_damage.png",
		Text = "汤谷真火流淌：近战命中灼毁 [color=#0a4213]12[/color] 身甲（40% 流血），迎战尸傀机关或处于焦土火海地格之敌总伤额外 [color=#0a4213]+12%[/color]",
		OnHitArmorBurn = 12, OnHitBleedPct = 40, JinwuSolarBonus = true
	},
	shanhai_taowu = {
		Tier = "shanhai", Title = "傲狠绝退", Icon = "ui/icons/melee_skill.png",
		Text = "凶戾绝伦不退半步：免疫击退，攻击动摇/崩溃之敌命中 [color=#0a4213]+6[/color]（50% 流血），斩杀活物回血 [color=#0a4213]+8[/color]",
		ImmuneKnockback = true, VsShakenHit = 6, OnHitBleedPct = 50, OnKillHealHP = 8, KillHealCap = 1
	},
	shanhai_xiangliu = {
		Tier = "shanhai", Title = "九首传蛊", Icon = "ui/icons/special.png",
		Text = "九首腥苦源毒：命中蚀损 [color=#0a4213]8[/color] 身甲、[color=#0a4213]50%[/color] 注入【暗器奇毒】；刺中已中毒目标时毒雾传染相邻 1 名敌军",
		OnHitArmorBurn = 8, OnHitPoisonPct = 50, SpreadPoisonAdj = true
	},
	shanhai_gonggong = {
		Tier = "shanhai", Title = "怒触天倾", Icon = "ui/icons/fatigue.png",
		Text = "黑水寒涛贯体：命中抽取 [color=#0a4213]8[/color] 内息（40% 失衡），处于水泽湿地作战时破甲效能额外 [color=#0a4213]+15%[/color]",
		OnHitDrainQi = 8, OnHitOffbalancePct = 40, WetArmorBonus = 0.15
	},
	shanhai_qiangliang = {
		Tier = "shanhai", Title = "衔蛇钩魂", Icon = "ui/icons/special.png",
		Text = "虎首重戈钩拉破门：施展钩拉或命中时 [color=#0a4213]45%[/color] 破开【破绽】、[color=#0a4213]40%[/color] 注入奇毒，对破绽敌额外抽散 [color=#0a4213]5[/color] 内息",
		OnHitOpeningPct = 45, OnHitPoisonPct = 40
	},
	shanhai_jiufeng = {
		Tier = "shanhai", Title = "九首泣血", Icon = "ui/icons/health.png",
		Text = "摄魂妖戟：攻击动摇/流血之敌命中 [color=#0a4213]+8[/color]，近战斩杀活物汲血恢复 [color=#0a4213]+10[/color] 气血（每轮限 2 次）",
		VsShakenHit = 8, OnKillHealHP = 10, KillHealCap = 2
	},
	shanhai_kuafu = {
		Tier = "shanhai", Title = "邓林渴渊", Icon = "ui/icons/fatigue.png",
		Text = "大日枯泽神木劲：近战命中蒸干目标 [color=#0a4213]10[/color] 点内息反哺自身 [color=#0a4213]+4[/color] 内息（每轮限 2 次），并压制目标蓄力破招 [color=#0a4213]+1[/color]",
		OnHitDrainQi = 10, OnHitSelfQi = 4, OnHeavyBossBreak = 1
	},
	shanhai_luwu = {
		Tier = "shanhai", Title = "司天寸劲", Icon = "ui/icons/melee_skill.png",
		Text = "镇守昆仑帝门：借机拦击命中 [color=#0a4213]+10[/color] 且必露【破绽】；施展震甲或点穴拳招时对蓄力大妖额外注入 [color=#0a4213]+1[/color] 破招值",
		ZoCBonusHit = 10, OnHitOpeningPct = 45, LuwuFistMode = true
	},
	shanhai_kui = {
		Tier = "shanhai", Title = "流波雷音", Icon = "ui/icons/armor_damage.png",
		Text = "一锤声闻五百里：近战命中崩碎 [color=#0a4213]15[/color] 身甲（重击 50% 失衡），雷音余波震散相邻 1 名敌影 [color=#0a4213]5[/color] 点内息",
		OnHitArmorBurn = 15, OnHitOffbalanceHeavyPct = 50, AdjQiShock = 5
	},
	shanhai_bo = {
		Tier = "shanhai", Title = "食虎碎壳", Icon = "ui/icons/armor_damage.png",
		Text = "《西山经》食虎豹白马独角锏：破甲 [color=#0a4213]+10%[/color]，对身甲≥100 或山海异兽命中 [color=#0a4213]+8[/color]（抽散 6 气、40% 破绽）；击中已露【破绽】大妖额外震碎 [color=#0a4213]1[/color] 层【太古玄壳】",
		ArmorDmgBonus = 0.10, OnHitDrainQi = 6, OnHitOpeningPct = 40, ShanHaiMode = "bo"
	},
	shanhai_chiyou = {
		Tier = "shanhai", Title = "五兵煞主", Icon = "ui/icons/armor_damage.png",
		Text = "万古兵主凶锋：破甲 [color=#0a4213]+10%[/color]、碎盾 [color=#0a4213]+12[/color]；周身 2 格每有 1 名流血/破绽敌军则命中 [color=#0a4213]+3[/color]（至多+9），斩敌回 [color=#0a4213]+4[/color] 气 [color=#0a4213]+8[/color] 血并震慑相邻敌影检定 [color=#0a4213]-10[/color] 定力",
		ArmorDmgBonus = 0.10, ShieldBreakBonus = 12, OnKillQiRegen = 4, OnKillHealHP = 8, KillHealCap = 2, ShanHaiMode = "chiyou_wpn"
	},
	shanhai_mingshe = {
		Tier = "shanhai", Title = "四翼磬音·旱火燎阵", Icon = "ui/icons/fatigue.png",
		Text = "《中山经》鸣蛇音如古磬见则大旱：抽散目标 [color=#0a4213]7[/color] 气（40% 失衡）；绕盾或击头时引动旱火灼损目标 [color=#0a4213]10[/color] 身甲并蒸干相邻敌影 [color=#0a4213]5[/color] 内息",
		OnHitDrainQi = 7, OnHitOffbalancePct = 40, ShanHaiMode = "mingshe"
	},
	shanhai_qinyuan_dag = {
		Tier = "shanhai", Title = "蜇石枯木·断续封生", Icon = "ui/icons/health.png",
		Text = "刺中受控猎物汲血 [color=#0a4213]+8[/color]（50% 奇毒）；昆仑毒蜂尾针刺入伤血时蚀穿 [color=#0a4213]10[/color] 身甲并施加 1 回合【断续封生印】（封断大妖自愈再生）",
		VsControlledDrainHP = 8, OnHitPoisonPct = 50, ShanHaiMode = "qinyuan_dag"
	},
	shanhai_hujiao = {
		Tier = "shanhai", Title = "三首越盾·毒蛟翻浪", Icon = "ui/icons/armor_damage.png",
		Text = "三枚蛟首越盾砸落：对持盾敌近战命中 [color=#0a4213]+8[/color]、震损 [color=#0a4213]10[/color] 身甲（45% 奇毒），砸中已中毒目标必追加【失衡】",
		OnHitArmorBurn = 10, OnHitPoisonPct = 45, ShanHaiMode = "hujiao"
	},
	shanhai_yingzhao = {
		Tier = "shanhai", Title = "平圃巡天·游射贯云", Icon = "ui/icons/ranged_skill.png",
		Text = "《西山经》司帝平圃神射：占据高地或游走步射时拉弓耗气 [color=#0a4213]-20%[/color]、命中 [color=#0a4213]+6[/color]，箭矢贯损 [color=#0a4213]12[/color] 身甲且 [color=#0a4213]45%[/color] 震露【破绽】",
		OnHitArmorBurn = 12, OnHitOpeningPct = 45, ShanHaiMode = "yingzhao"
	},
	shanhai_gudiao = {
		Tier = "shanhai", Title = "婴啼裂魄", Icon = "ui/icons/ranged_skill.png",
		Text = "攻击动摇/崩溃敌远程命中 [color=#0a4213]+10[/color]（50% 流血）；重矢伤血 ≥12 时发出凄厉婴啼迫使目标执行 [color=#0a4213]-12[/color] 定力动摇检定",
		VsShakenHit = 10, OnHitBleedPct = 50, ShanHaiMode = "gudiao"
	},
	shanhai_jinwu = {
		Tier = "shanhai", Title = "厌火吞炭·引瘴爆燃", Icon = "ui/icons/armor_damage.png",
		Text = "《海外南经》祸斗烈焰铅砂：轰击每目标灼毁 [color=#0a4213]14[/color] 身甲、蒸干 [color=#0a4213]5[/color] 气；命中已中毒或身陷蛛网目标时引爆火毒追加 [color=#0a4213]10[/color] 点纯阳实伤",
		OnHitArmorBurn = 14, OnHitDrainQi = 5, ShanHaiMode = "huodouchong"
	},
	shanhai_tiangou = {
		Tier = "shanhai", Title = "坠星破阵", Icon = "ui/icons/ranged_skill.png",
		Text = "≤3 格近投命中 [color=#0a4213]+8[/color]；飞梭击中气血 ≥80% 完好强敌必震露【破绽】，斩敌或乘破绽命中回收 [color=#0a4213]1[/color] 发备弹（单场限 3 发）",
		CloseRangeHit = 8, OnKillRefundAmmo = 1, ShanHaiMode = "tiangou"
	},

	// ==================== Tier B2: 山海神通 · 14 领山海宝甲（全谱法相化） ====================
	shanhai_armor_zhuyan = {
		Tier = "shanhai", Title = "白首沸血", Icon = "ui/icons/health.png",
		Text = "气血上限 [color=#0a4213]+12[/color]；气血 <60% 激发狂猿战意（总伤 [color=#0a4213]+12%[/color]、定力 [color=#0a4213]+12[/color]），且残血受近战打击沸血反哺自身 [color=#0a4213]+3[/color] 内息（每轮限 2 次）",
		Stats = { Hitpoints = 12 }, LowHpThreshold = 0.60, LowHpDmgPct = 0.12, LowHpResolve = 12, ShanHaiMode = "armor_zhuyan"
	},
	shanhai_armor_feiyi = {
		Tier = "shanhai", Title = "六足旱鳞", Icon = "ui/icons/armor_body.png",
		Text = "免疫山海毒火光环与酸液蚀甲；受近战反灼来敌 [color=#0a4213]8[/color] 身甲，若来敌身负毒素则旱火引毒额外反噬其 [color=#0a4213]6[/color] 点气血",
		ImmuneAcidAndFireAura = true, ThornsMeleeArmor = 8, ShanHaiMode = "armor_feiyi"
	},
	shanhai_armor_qiongqi = {
		Tier = "shanhai", Title = "乘风助恶", Icon = "ui/icons/initiative.png",
		Text = "轻若鸿毛（契合《金蝉卸力》）：常驻身法 [color=#0a4213]+10[/color]、首轮额外 [color=#0a4213]+10[/color]；攻击动摇或流血猎物命中后疾风旋身令本轮双防 [color=#0a4213]+4[/color]",
		Stats = { Initiative = 10 }, FirstRoundInit = 10, ShanHaiMode = "armor_qiongqi"
	},
	shanhai_armor_jumang = {
		Tier = "shanhai", Title = "生生建木", Icon = "ui/icons/health.png",
		Text = "都广神木灵脉流转：每回合初恢复 [color=#0a4213]+6[/color] 受损气血、修复 [color=#0a4213]+6[/color] 身甲，并自动挣脱/化消自身流血或蛛网藤蔓缠绕",
		TurnRegenHP = 6, TurnRegenBodyArmor = 6, ShanHaiMode = "armor_jumang"
	},
	shanhai_armor_xuangui = {
		Tier = "shanhai", Title = "镇海磐岳", Icon = "ui/icons/ranged_defense.png",
		Text = "承受远程伤害 [color=#0a4213]-20%[/color]、外伤承受阈值 [color=#0a4213]+25%[/color]；每轮首次遭受 ≥20 破甲重击时古龟甲壳卸去 [color=#0a4213]30%[/color] 破甲损耗",
		RangedDmgMult = 0.80, InjuryThresholdMult = 1.25, ShanHaiMode = "armor_xuangui"
	},
	shanhai_armor_yinglong = {
		Tier = "shanhai", Title = "沧海龙罡", Icon = "ui/icons/fatigue.png",
		Text = "定力 [color=#0a4213]+8[/color]、回气 [color=#0a4213]+2[/color]；受近战攻击引沧海雷水反震来敌 [color=#0a4213]6[/color] 身甲与 [color=#0a4213]4[/color] 内息（水泽湿地翻倍）",
		Stats = { Bravery = 8, FatigueRecoveryRate = 2 }, ThornsMeleeArmor = 6, ThornsMeleeQi = 4, ShanHaiMode = "armor_yinglong"
	},
	shanhai_armor_chiyou = {
		Tier = "shanhai", Title = "兵主辟易", Icon = "ui/icons/armor_body.png",
		Text = "气血上限 [color=#0a4213]+12[/color]、承受破甲损耗 [color=#0a4213]-15%[/color]；身陷重围时抗围近防补正 [color=#0a4213]+4[/color] 且免疫眩晕失神（Dazed）",
		Stats = { Hitpoints = 12 }, ArmorDmgTakenMult = 0.85, ShanHaiMode = "armor_chiyou"
	},
	shanhai_armor_kui = {
		Tier = "shanhai", Title = "紫电鸣鼓", Icon = "ui/icons/fatigue.png",
		Text = "刀兵击中革铠声闻五百里：定力 [color=#0a4213]+8[/color]，受近战反震攻击者 [color=#0a4213]6[/color] 内息并有 [color=#0a4213]30%[/color] 概率震令其【失衡】",
		Stats = { Bravery = 8 }, ThornsMeleeQi = 6, ShanHaiMode = "armor_kui"
	},
	shanhai_armor_luwu = {
		Tier = "shanhai", Title = "司天虎威", Icon = "ui/icons/bravery.png",
		Text = "定力 [color=#0a4213]+10[/color]、抗惊骇 [color=#0a4213]+12[/color]、每轮修甲 [color=#0a4213]+4[/color]；执行控制区借机拦击或施展拳掌寸劲时破甲额外 [color=#0a4213]+15%[/color]",
		Stats = { Bravery = 10 }, AntiFearBonus = 12, TurnRegenBodyArmor = 4, ShanHaiMode = "armor_luwu"
	},
	shanhai_armor_zhuyin = {
		Tier = "shanhai", Title = "寒暑轮转", Icon = "ui/icons/special.png",
		Text = "视为昼、瞑为夜：单数轮【瞑夜】近远双防 [color=#0a4213]+5[/color]、回气 [color=#0a4213]+3[/color]；双数轮【赤昼】攻击总伤 [color=#0a4213]+10%[/color]",
		CycleZhuyin = true
	},
	shanhai_armor_feilian = {
		Tier = "shanhai", Title = "御风幻影", Icon = "ui/icons/initiative.png",
		Text = "风伯青翎御气乘风（契合《金蝉卸力》）：常驻身法 [color=#0a4213]+12[/color]，每轮首次受远程或重击时激发幻空折跃额外偏折 [color=#0a4213]20%[/color] 实伤（严守60%上限）",
		Stats = { Initiative = 12 }, RangedDmgMult = 0.88, PhaseShiftPct = 0.20
	},
	shanhai_armor_bifang = {
		Tier = "shanhai", Title = "讹火焚缚", Icon = "ui/icons/initiative.png",
		Text = "常驻身法 [color=#0a4213]+8[/color]，免疫毒火光环与酸蚀，受近战反灼 [color=#0a4213]8[/color] 身甲，且每回合初讹火自涤寒霜迟缓与蛛网束缚",
		Stats = { Initiative = 8 }, ImmuneAcidAndFireAura = true, ThornsMeleeArmor = 8, ShanHaiMode = "armor_bifang"
	},
	shanhai_armor_baize = {
		Tier = "shanhai", Title = "达知逢凶", Icon = "ui/icons/melee_defense.png",
		Text = "通玄雪裘（契合《金蝉卸力》）：招架 [color=#0a4213]+4[/color]、避暗 [color=#0a4213]+4[/color]、外伤阈值 [color=#0a4213]+20%[/color]；敌方近战落空时识破招路令下次反击命中 [color=#0a4213]+6[/color]",
		Stats = { MeleeDefense = 4, RangedDefense = 4 }, InjuryThresholdMult = 1.20, ShanHaiMode = "armor_baize"
	},
	shanhai_armor_xiangliu = {
		Tier = "shanhai", Title = "苦泽毒鳞", Icon = "ui/icons/ranged_defense.png",
		Text = "百毒不侵且远程受击 [color=#0a4213]-15%[/color]；遭受近战攻击时毒鳞迸溅苦毒反蚀攻击者 [color=#0a4213]6[/color] 身甲并 [color=#0a4213]35%[/color] 概率染毒",
		PoisonImmune = true, RangedDmgMult = 0.85, ThornsMeleeArmor = 6, ThornsPoisonPct = 35
	},

	// ==================== Tier B3: 山海神通 · 8 顶山海宝冠战胄（全谱法相化） ====================
	shanhai_helm_taotie = {
		Tier = "shanhai", Title = "吞天噬元", Icon = "ui/icons/armor_head.png",
		Text = "内置【铜头铁额】免疫头部额外暴击倍率；近战斩杀活物吞噬精元恢复 [color=#0a4213]+8[/color] 气血与 [color=#0a4213]+4[/color] 内息（每轮限 1 次）",
		SteelBrow = true, OnKillHealHP = 8, OnKillQiRegen = 4, KillHealCap = 1
	},
	shanhai_helm_bashe = {
		Tier = "shanhai", Title = "吞象听风", Icon = "ui/icons/vision.png",
		Text = "避暗 [color=#0a4213]+6[/color]、视野 [color=#0a4213]+1[/color]；处于夜雾烟幕或迎战山海巨妖/异兽时近远攻击命中额外 [color=#0a4213]+5[/color]",
		Stats = { RangedDefense = 6, Vision = 1 }, SmokeSightHit = 5, ShanHaiMode = "helm_bashe"
	},
	shanhai_helm_kaiming = {
		Tier = "shanhai", Title = "九首环视", Icon = "ui/icons/bravery.png",
		Text = "内置【铜头铁额】免爆头，定力 [color=#0a4213]+10[/color]、抗惊骇 [color=#0a4213]+15[/color]，九首警觉额外提供抗围近防补正 [color=#0a4213]+3[/color]",
		SteelBrow = true, Stats = { Bravery = 10 }, AntiFearBonus = 15, ShanHaiMode = "helm_kaiming"
	},
	shanhai_helm_chiyou = {
		Tier = "shanhai", Title = "铜头触岳", Icon = "ui/icons/armor_head.png",
		Text = "内置【铜头铁额】免爆头、破甲损耗 [color=#0a4213]-10%[/color]；遭近战击中头部时凶神铜角反震攻击者 [color=#0a4213]10[/color] 身甲与 [color=#0a4213]5[/color] 内息",
		SteelBrow = true, ArmorDmgTakenMult = 0.90, ShanHaiMode = "helm_chiyou"
	},
	shanhai_helm_jinwu = {
		Tier = "shanhai", Title = "大日破障", Icon = "ui/icons/vision.png",
		Text = "夜战视物如昼、身法 [color=#0a4213]+8[/color]；每回合初金乌真火涤除自身致盲与魅惑幻术，攻击尸傀邪祟命中 [color=#0a4213]+6[/color]",
		NightOwl = true, Stats = { Initiative = 8 }, ShanHaiMode = "helm_jinwu"
	},
	shanhai_helm_dijiang = {
		Tier = "shanhai", Title = "幻空错位", Icon = "ui/icons/ranged_defense.png",
		Text = "六足四翼空间灵觉：避暗 [color=#0a4213]+8[/color]，每轮首次遭受远程射击或 ≥22 重击时空间折跃偏折 [color=#0a4213]25%[/color] 气血实伤（严守60%上限）",
		Stats = { RangedDefense = 8 }, RangedDmgMult = 0.90, PhaseShiftPct = 0.25
	},
	shanhai_helm_siwang = {
		Tier = "shanhai", Title = "独角抵岳", Icon = "ui/icons/health.png",
		Text = "气血上限 [color=#0a4213]+10[/color]、免击退钩拉；施展【步进】冲锋招式或重击命中时青兕独角额外崩碎目标 [color=#0a4213]8[/color] 点身甲",
		Stats = { Hitpoints = 10 }, ImmuneKnockback = true, ShanHaiMode = "helm_siwang"
	},
	shanhai_helm_bingyi = {
		Tier = "shanhai", Title = "寒渊御龙", Icon = "ui/icons/fatigue.png",
		Text = "内息上限 [color=#0a4213]+8[/color]、回气 [color=#0a4213]+2[/color]；受近战打击时从极寒气反侵攻击者经脉削减其本轮 [color=#0a4213]8[/color] 先攻并散气 [color=#0a4213]3[/color] 点",
		Stats = { Stamina = 8, FatigueRecoveryRate = 2 }, ThornsMeleeQi = 3, ShanHaiMode = "helm_bingyi"
	},

	// ==================== Tier B4: 山海神通 · 6 面山海传世神盾（全谱法相化） ====================
	shanhai_shd_xuangui = {
		Tier = "shanhai", Title = "玄甲归藏", Icon = "ui/icons/ranged_defense.png",
		Text = "远伤 [color=#0a4213]-20%[/color]、受近战反震 [color=#0a4213]5[/color] 气；开启【盾墙】架势时古龟玄壳额外卸去 [color=#0a4213]15%[/color] 气血实伤（严守60%上限）",
		RangedDmgMult = 0.80, ThornsMeleeQi = 5, ShanHaiMode = "shd_xuangui"
	},
	shanhai_shd_zaochi = {
		Tier = "shanhai", Title = "凶牙钩破", Icon = "ui/icons/armor_damage.png",
		Text = "受近战攻击反削来敌 [color=#0a4213]10[/color] 身甲；敌方近战攻击落空时盾圈六尺凶牙有 [color=#0a4213]35%[/color] 概率反钩撕开其【破绽】",
		ThornsMeleeArmor = 10, ShanHaiMode = "shd_zaochi"
	},
	shanhai_shd_kui = {
		Tier = "shanhai", Title = "雷鼓骇魄", Icon = "ui/icons/fatigue.png",
		Text = "定力 [color=#0a4213]+8[/color]、受近战反震 [color=#0a4213]7[/color] 内息；遭受重击时雷音震耳迫使攻击者执行 [color=#0a4213]-10[/color] 定力动摇检定",
		Stats = { Bravery = 8 }, ThornsMeleeQi = 7, ShanHaiMode = "shd_kui"
	},
	shanhai_shd_jumang = {
		Tier = "shanhai", Title = "生生涤秽", Icon = "ui/icons/shield_damage.png",
		Text = "每回合初自动修复 [color=#0a4213]+6[/color] 盾耐久、自愈 [color=#0a4213]+4[/color] 气血，并借建木灵气涤除持盾者身上 1 层奇毒或酸蚀",
		TurnRegenShield = 6, TurnRegenHP = 4, ShanHaiMode = "shd_jumang"
	},
	shanhai_shd_fangfeng = {
		Tier = "shanhai", Title = "专车不摧", Icon = "ui/icons/ranged_defense.png",
		Text = "远伤 [color=#0a4213]-20%[/color]、持盾免击退抓取；防风巨骨坚不可摧，承受敌方劈盾破盾伤害降低 [color=#0a4213]-30%[/color] 且每轮自修 [color=#0a4213]+3[/color] 盾耐久",
		RangedDmgMult = 0.80, ImmuneKnockback = true, TurnRegenShield = 3, ShanHaiMode = "shd_fangfeng"
	},
	shanhai_shd_yinglong = {
		Tier = "shanhai", Title = "旋水借劲", Icon = "ui/icons/shield_damage.png",
		Text = "每轮修盾 [color=#0a4213]+4[/color]、甲损 [color=#0a4213]-15%[/color]；敌方近战攻击落空时旋水弧面借劲导气恢复自身 [color=#0a4213]+3[/color] 内息（每轮限 2 次）",
		TurnRegenShield = 4, ArmorDmgTakenMult = 0.85, ShanHaiMode = "shd_yinglong"
	},

	// ==================== Tier B5: 山海神通 · 12 件山海奇珍异佩（全谱补齐本命神通！） ====================
	shanhai_acc_jiuwei = {
		Tier = "shanhai", Title = "青丘护魄", Icon = "ui/icons/bravery.png",
		Text = "每场战斗首次陷入动摇/魅惑/梦魇时，青丘九尾灵光自动清心破幻重归稳定并立回 [color=#0a4213]+6[/color] 内息",
		ShanHaiMode = "acc_jiuwei"
	},
	shanhai_acc_wuzhiqi = {
		Tier = "shanhai", Title = "定水化瘴", Icon = "ui/icons/fatigue.png",
		Text = "立于浅水沼泽或遭受毒系/水寒攻击时，寒渊定水珠引秽化元每轮额外恢复 [color=#0a4213]+3[/color] 内息",
		ShanHaiMode = "acc_wuzhiqi"
	},
	shanhai_acc_baize = {
		Tier = "shanhai", Title = "通万物情", Icon = "ui/icons/vision.png",
		Text = "洞悉山海百怪命门：迎战异兽与山海大妖近远命中 [color=#0a4213]+5[/color]，且战后全身武学参战火候额外 [color=#0a4213]+15%[/color]",
		ShanHaiMode = "acc_baize"
	},
	shanhai_acc_hundun = {
		Tier = "shanhai", Title = "混元封窍", Icon = "ui/icons/special.png",
		Text = "七窍俱泯经脉浑圆：每回合初自动化消自身【点穴封气】或【眩晕失神】并回哺 [color=#0a4213]+4[/color] 内息",
		ShanHaiMode = "acc_hundun"
	},
	shanhai_acc_chenghuang = {
		Tier = "shanhai", Title = "千岁生机", Icon = "ui/icons/health.png",
		Text = "气血 ≥70% 时每回合初温养修复 [color=#0a4213]+5[/color] 身甲；气血 <70% 时转为每回合初自愈 [color=#0a4213]+5[/color] 气血",
		ShanHaiMode = "acc_chenghuang"
	},
	shanhai_acc_fuzhu = {
		Tier = "shanhai", Title = "寒鹿润脉", Icon = "ui/icons/fatigue.png",
		Text = "主修阴柔或中正内功时武技内息消耗 [color=#0a4213]-8%[/color]，施展【调息】技能额外多恢复 [color=#0a4213]+6[/color] 内息",
		ShanHaiMode = "acc_fuzhu"
	},
	shanhai_acc_boshi = {
		Tier = "shanhai", Title = "背目破围", Icon = "ui/icons/melee_defense.png",
		Text = "《南山经》其目在背：抗围近防补正 [color=#0a4213]+3[/color]，敌方近战合围落空时有 [color=#0a4213]30%[/color] 概率反露【破绽】",
		ShanHaiMode = "acc_boshi"
	},
	shanhai_acc_wuluo = {
		Tier = "shanhai", Title = "鸣环游影", Icon = "ui/icons/initiative.png",
		Text = "施展【穿步】或步射移动招式命中后，翡翠鸣环清音惑敌令本轮近远双防额外 [color=#0a4213]+3[/color]",
		ShanHaiMode = "acc_wuluo"
	},
	shanhai_acc_xingxing = {
		Tier = "shanhai", Title = "识名知往", Icon = "ui/icons/melee_skill.png",
		Text = "开场首轮先攻身法 [color=#0a4213]+10[/color]；攻击已受损（非满血）敌手时洞悉旧绽近远命中 [color=#0a4213]+4[/color]",
		FirstRoundInit = 10, ShanHaiMode = "acc_xingxing"
	},
	shanhai_acc_jingwei = {
		Tier = "shanhai", Title = "衔石镇海", Icon = "ui/icons/bravery.png",
		Text = "千载执念愈战愈坚：气血低于 55% 时攻击破甲 [color=#0a4213]+12%[/color] 且承受气血实伤额外减免 [color=#0a4213]10%[/color]（严守60%上限）",
		ShanHaiMode = "acc_jingwei"
	},
	shanhai_acc_dangkang = {
		Tier = "shanhai", Title = "丰穰凯歌", Icon = "ui/icons/health.png",
		Text = "入阵首轮自动提振一级战意；近战或远程斩杀敌手时恢复 [color=#0a4213]+5[/color] 气血与 [color=#0a4213]+3[/color] 内息（每轮限 1 次）",
		OnKillHealHP = 5, OnKillQiRegen = 3, KillHealCap = 1, ShanHaiMode = "acc_dangkang"
	},
	shanhai_acc_yayu = {
		Tier = "shanhai", Title = "贰负续命", Icon = "ui/icons/health.png",
		Text = "昆仑不死神药余韵：单场战斗气血首次跌破 35% 时触发【续命回元】立回 [color=#0a4213]+18[/color] 气血并涤清流血创口",
		ShanHaiMode = "acc_yayu"
	}
};

// Tier A: 12 Mid-Tier Wild-Beast Weapons, Shield, Armors & Helmets + 4 Beast Armor Upgrades
::Wuxia.Config.BeastGear <- {
	wx_beast_fist = {
		ID = "wx_beast_fist", Kind = "weapon", Family = "Fist", Name = "百工·狍鸮裂骨虎齿拳", Value = 1650,
		Script = "scripts/items/weapons/wx_beast_fist", BaseScript = "scripts/items/weapons/wx_fist_base",
		Icon = "weapons/melee/wx_beast_fist_70x70.png", IconLarge = "weapons/melee/wx_beast_fist.png", ArmBrush = "arm_wx_beast_fist",
		Condition = 72.0, StaminaModifier = -8, RegularDamage = 33, RegularDamageMax = 46, ArmorDamageMult = 0.95, DirectDamageMult = 0.38,
		TraitID = "beast_fist_leech",
		Description = "取北山狍鸮锯齿凶牙缠缚百韧天妖蛟筋缝制的成对猎妖拳套（占双手槽，4 AP 疾攻），贴身搏杀可啖血回元。"
	},
	wx_beast_sword = {
		ID = "wx_beast_sword", Kind = "weapon", Family = "Sword", Name = "百工·巴蛇青鳞快剑", Value = 1850,
		Script = "scripts/items/weapons/wx_beast_sword", BaseScript = "scripts/items/weapons/arming_sword",
		Icon = "weapons/melee/wx_beast_sword_70x70.png", IconLarge = "weapons/melee/wx_beast_sword.png", ArmBrush = "arm_wx_beast_sword",
		Condition = 72.0, StaminaModifier = -7, RegularDamage = 42, RegularDamageMax = 50, ArmorDamageMult = 0.85, DirectDamageMult = 0.25,
		TraitID = "beast_sword_venom",
		Description = "以寒渊真龙逆鳞合巴蛇青皮夹钢千锻的青碧长剑，血槽暗藏蛇鳞余毒，见血即封麻敌手经脉。"
	},
	wx_beast_saber = {
		ID = "wx_beast_saber", Kind = "weapon", Family = "Saber", Name = "百工·蛊雕裂风弯刀", Value = 1800,
		Script = "scripts/items/weapons/wx_beast_saber", BaseScript = "scripts/items/weapons/military_cleaver",
		Icon = "weapons/melee/wx_beast_saber_70x70.png", IconLarge = "weapons/melee/wx_beast_saber.png", ArmBrush = "arm_wx_beast_saber",
		Condition = 72.0, StaminaModifier = -9, RegularDamage = 40, RegularDamageMax = 58, ArmorDamageMult = 0.95, DirectDamageMult = 0.25,
		TraitID = "beast_saber_dread",
		Description = "刀柄缠蛊雕斑革、血槽嵌赤炎妖禽翎导风的凶悍快刀，挥斩破风隐作凄厉婴啼，最善追斩胆寒溃敌。"
	},
	wx_beast_spear = {
		ID = "wx_beast_spear", Kind = "weapon", Family = "Spear", Name = "百工·肥遗蚀铁骨枪", Value = 2100,
		Script = "scripts/items/weapons/wx_beast_spear", BaseScript = "scripts/items/weapons/fighting_spear",
		Icon = "weapons/melee/wx_beast_spear_70x70.png", IconLarge = "weapons/melee/wx_beast_spear.png", ArmBrush = "arm_wx_beast_spear",
		Condition = 76.0, StaminaModifier = -9, RegularDamage = 38, RegularDamageMax = 46, ArmorDamageMult = 1.15, DirectDamageMult = 0.25,
		TraitID = "beast_spear_acid",
		Description = "以裂岳太古凶角为锋、截取太华肥遗毒蛟脊骨为杆的猎妖长枪，守线攒刺可迅速蚀穿重甲。"
	},
	wx_beast_hammer = {
		ID = "wx_beast_hammer", Kind = "weapon", Family = "Hammer", Name = "百工·朱厌千钧巨骨锤", Value = 2400,
		Script = "scripts/items/weapons/wx_beast_hammer", BaseScript = "scripts/items/weapons/two_handed_hammer",
		Icon = "weapons/melee/wx_beast_hammer_70x70.png", IconLarge = "weapons/melee/wx_beast_hammer.png", ArmBrush = "arm_wx_beast_hammer",
		Condition = 96.0, StaminaModifier = -16, RegularDamage = 60, RegularDamageMax = 88, ArmorDamageMult = 1.85, DirectDamageMult = 0.50,
		TraitID = "beast_hammer_quake",
		Description = "以朱厌千钧铁骨嵌裂岳太古凶角重箍而成的双手破甲巨锤，当头轰落足以将铁浮屠与古墓铜甲砸至失衡！"
	},
	wx_beast_bow = {
		ID = "wx_beast_bow", Kind = "weapon", Family = "Bow", Name = "百工·赤蛛天弦角弓", Value = 1950,
		Script = "scripts/items/weapons/wx_beast_bow", BaseScript = "scripts/items/weapons/short_bow",
		Icon = "weapons/ranged/wx_beast_bow_70x70.png", IconLarge = "weapons/ranged/wx_beast_bow.png", ArmBrush = "arm_wx_beast_bow",
		Condition = 76.0, StaminaModifier = -8, RegularDamage = 48, RegularDamageMax = 68, ArmorDamageMult = 0.65, DirectDamageMult = 0.35,
		TraitID = "beast_bow_venom",
		Description = "以百韧天妖蛟筋合鬼面赤蛛天韧丝绞弦的异兽强弓，拉弦轻省而箭带寒毒。"
	},
	wx_beast_shield = {
		ID = "wx_beast_shield", Kind = "shield", Name = "百工·建木盘根重藤牌", Value = 1600,
		Script = "scripts/items/shields/wx_beast_shield", BaseScript = "scripts/items/shields/heater_shield",
		Icon = "shields/wx_beast_shield_70x70.png", IconLarge = "shields/wx_beast_shield.png", ShieldBrush = "shd_wx_beast_shield",
		Condition = 64, MeleeDefense = 18, RangedDefense = 22, StaminaModifier = -11,
		TraitID = "beast_shield_regen",
		Description = "以建木琥珀灵脂反复浸润老藤、中心嵌寒渊真龙逆鳞的百工圆盾，受创后木脉自合、箭矢难穿。"
	},
	wx_beast_armor_light = {
		ID = "wx_beast_armor_light", Kind = "armor", Name = "百工·赤蛛天狗轻猎衣", Value = 2100,
		Script = "scripts/items/armor/wx_beast_armor_light", BaseScript = "scripts/items/armor/mail_shirt",
		Icon = "armor/wx_beast_armor_light_70x70.png", IconLarge = "armor/wx_beast_armor_light.png", BodyBrush = "wx_beast_armor_light",
		Condition = 125, StaminaModifier = -9,
		TraitID = "beast_armor_swift",
		Description = "外裁阴山天狗苍裘、内穿百韧天妖蛟筋束甲的猎妖轻装：总重极轻（完美适配《金蝉卸力》），夜行林莽捷若奔狼。"
	},
	wx_beast_armor_med = {
		ID = "wx_beast_armor_med", Kind = "armor", Name = "百工·巴蛇青鳞软甲", Value = 2350,
		Script = "scripts/items/armor/wx_beast_armor_med", BaseScript = "scripts/items/armor/mail_hauberk",
		Icon = "armor/wx_beast_armor_med_70x70.png", IconLarge = "armor/wx_beast_armor_med.png", BodyBrush = "wx_beast_armor_med",
		Condition = 175, StaminaModifier = -14,
		TraitID = "beast_armor_scales",
		Description = "将苍梧巴蛇微光青鳞与寒渊真龙逆鳞密缀成甲，鳞面滑不留刃，飞蝗箭雨射中往往滑脱卸力。"
	},
	wx_beast_armor_heavy = {
		ID = "wx_beast_armor_heavy", Kind = "armor", Name = "百工·朱厌铁骨重札甲", Value = 2900,
		Script = "scripts/items/armor/wx_beast_armor_heavy", BaseScript = "scripts/items/armor/mail_hauberk",
		Icon = "armor/wx_beast_armor_heavy_70x70.png", IconLarge = "armor/wx_beast_armor_heavy.png", BodyBrush = "wx_beast_armor_heavy",
		Condition = 255, StaminaModifier = -26,
		TraitID = "beast_armor_vital",
		Description = "以双层朱厌白首厚革打底、胸腹嵌满万钧战神煞骨，乃中前期横练猛士冲阵扛线的坚实重铠。"
	},
	wx_beast_helm_light = {
		ID = "wx_beast_helm_light", Kind = "helmet", Name = "百工·讹兽明目皮冠", Value = 1550,
		Script = "scripts/items/helmets/wx_beast_helm_light", BaseScript = "scripts/items/helmets/hunters_hat",
		Icon = "helmets/wx_beast_helm_light.png", HatID = "wx_beast_helm_light",
		Condition = 105, StaminaModifier = -4, Vision = 0,
		TraitID = "beast_helm_owl",
		Description = "额心镶嵌不腐讹兽诡眼、两侧插赤炎妖禽翎的轻便猎妖皮冠，黑夜密林中视物纤毫毕现。"
	},
	wx_beast_helm_heavy = {
		ID = "wx_beast_helm_heavy", Kind = "helmet", Name = "百工·古墓寒晶镇魂胄", Value = 2150,
		Script = "scripts/items/helmets/wx_beast_helm_heavy", BaseScript = "scripts/items/helmets/kettle_hat",
		Icon = "helmets/wx_beast_helm_heavy.png", HatID = "wx_beast_helm_heavy",
		Condition = 225, StaminaModifier = -13, Vision = -1,
		TraitID = "beast_helm_ward",
		Description = "以幽冥蚀骨毒晶合凝魄寒晶熔铸眉庇的重型战胄，阴邪鬼啸难撼佩戴者心神分毫。"
	},

	// 4 Craftable Beast Armor Attachments (`armor_upgrade.*` — right-click onto ANY body armor!)
	wx_up_chiling = {
		ID = "wx_up_chiling", Kind = "upgrade", Name = "百工·赤炎妖翎披风", Value = 1200,
		Script = "scripts/items/armor_upgrades/wx_up_chiling", BackBrush = "wx_up_chiling",
		ArmorBonus = 20, StaminaModifier = 0, InitiativeBonus = 8, BraveryBonus = 0, RangedMult = 1.0, ArmorDmgMult = 1.0, PoisonImmune = false,
		MechTail = "，且【赤翎辟寒】每轮自涤霜寒迟缓、跋涉行气 -15%",
		BonusText = "护甲耐久 [color=#0a4213]+20[/color]（零负重）、提纵身法 [color=#0a4213]+8[/color]，且【赤翎辟寒】每轮自涤霜寒迟缓、跋涉行气 -15%",
		Description = "编缀赤炎妖禽翎与毕方灵灰的烈火红披风。右键镶缀于任意身甲之上：耐久 +20（零负重）、身法 +8，并辟除寒霜迟缓、减轻地形跋涉耗气。"
	},
	wx_up_xuanlin = {
		ID = "wx_up_xuanlin", Kind = "upgrade", Name = "百工·寒渊真龙护心镜", Value = 1500,
		Script = "scripts/items/armor_upgrades/wx_up_xuanlin", BackBrush = "wx_up_xuanlin",
		ArmorBonus = 45, StaminaModifier = -2, InitiativeBonus = 0, BraveryBonus = 0, RangedMult = 0.85, ArmorDmgMult = 1.0, PoisonImmune = false,
		MechTail = "，且【逆鳞辟火】免疫山海灼甲光环、外伤阈值 +15%",
		BonusText = "护甲耐久 [color=#0a4213]+45[/color]（负重 -2）、远伤 [color=#0a4213]-15%[/color]，且【逆鳞辟火】免疫山海灼甲光环、外伤阈值 +15%",
		Description = "以寒渊真龙逆鳞合肥遗重鳞锻成的护心背甲。右键镶缀于身甲：耐久 +45、远伤 -15%，并免疫大妖毒火酸蚀光环、提高外伤阈值。"
	},
	wx_up_shagu = {
		ID = "wx_up_shagu", Kind = "upgrade", Name = "百工·战神煞骨吞肩甲", Value = 1600,
		Script = "scripts/items/armor_upgrades/wx_up_shagu", BackBrush = "wx_up_shagu",
		ArmorBonus = 55, StaminaModifier = -3, InitiativeBonus = 0, BraveryBonus = 0, RangedMult = 1.0, ArmorDmgMult = 0.85, PoisonImmune = false,
		MechTail = "，且【煞骨反震】受近战反削来敌 5 身甲、抗围近防 +2",
		BonusText = "护甲耐久 [color=#0a4213]+55[/color]（负重 -3）、损甲 [color=#0a4213]-15%[/color]，且【煞骨反震】受近战反削来敌 5 身甲、抗围近防 +2",
		Description = "以万钧战神煞骨配朱厌铁骨精制的狰狞护肩。右键镶缀于身甲：耐久 +55、损甲 -15%，且受近战反削敌甲、补强抗围近防。"
	},
	wx_up_gujing = {
		ID = "wx_up_gujing", Kind = "upgrade", Name = "百工·幽冥毒晶辟邪囊", Value = 1350,
		Script = "scripts/items/armor_upgrades/wx_up_gujing", BackBrush = "wx_up_gujing",
		ArmorBonus = 25, StaminaModifier = 0, InitiativeBonus = 0, BraveryBonus = 8, RangedMult = 1.0, ArmorDmgMult = 1.0, PoisonImmune = true,
		MechTail = "，且【化毒归元】立于毒泽或受毒击每轮转化恢复 +2 内息",
		BonusText = "护甲耐久 [color=#0a4213]+25[/color]、定力 [color=#0a4213]+8[/color]、百毒不侵，且【化毒归元】立于毒泽或受毒击每轮转化恢复 +2 内息",
		Description = "内封幽冥蚀骨毒晶与五毒腺囊的护身奇门腰肩囊。右键镶缀于身甲：耐久 +25、定力 +8、百毒不侵，并可化沼泽毒瘴为自身内息。"
	}
};

// Non-destructively attach `TraitID` onto Historical Famous Relics & 22 Shan-Hai Relic Weapons!
if ("RelicWeapons" in ::Wuxia.Config)
{
	local relicTraitMap = {
		// 37 把历史传世名器全谱挂载器灵
		wx_relic_taie          = "relic_taie",
		wx_relic_longyuan      = "relic_longyuan",
		wx_relic_chengying     = "relic_chengying",
		wx_relic_ganjiang      = "relic_ganjiang",
		wx_relic_moye          = "relic_moye",
		wx_relic_chixiao       = "relic_chixiao",
		wx_relic_juque         = "relic_juque",
		wx_relic_longque       = "relic_longque",
		wx_relic_minghong      = "relic_minghong",
		wx_relic_xiuchun       = "relic_xiuchun",
		wx_relic_modao         = "relic_modao",
		wx_relic_kunwu         = "relic_kunwu",
		wx_relic_tulong        = "relic_tulong",
		wx_relic_liquan        = "relic_liquan",
		wx_relic_hutouqiang    = "relic_hutouqiang",
		wx_relic_huaji         = "relic_huaji",
		wx_relic_yanyue        = "relic_yanyue",
		wx_relic_goulianqiang  = "relic_goulianqiang",
		wx_relic_bawangqiang   = "relic_bawangqiang",
		wx_relic_huntiegun     = "relic_huntiegun",
		wx_relic_lvzhuzhang    = "relic_lvzhuzhang",
		wx_relic_longlinzhao   = "relic_longlinzhao",
		wx_relic_jingangwan    = "relic_jingangwan",
		wx_relic_wengjinchui   = "relic_wengjinchui",
		wx_relic_shutongjian   = "relic_shutongjian",
		wx_relic_jinzuan_chui  = "relic_jinzuan_chui",
		wx_relic_xuanhuafu     = "relic_xuanhuafu",
		wx_relic_pochengyue    = "relic_pochengyue",
		wx_relic_kaitian_changfu = "relic_kaitian_changfu",
		wx_relic_wujinbian     = "relic_wujinbian",
		wx_relic_dashenbian    = "relic_dashenbian",
		wx_relic_yuchang       = "relic_yuchang",
		wx_relic_xufuren       = "relic_xufuren",
		wx_relic_zhentiangong  = "relic_zhentiangong",
		wx_relic_shenbinu      = "relic_shenbinu",
		wx_relic_xunleichong   = "relic_xunleichong",
		wx_relic_feidaonang    = "relic_feidaonang",
		// 22 柄山海神兵
		wx_relic_xingtianqi    = "shanhai_xingtian",
		wx_relic_qiongqizhao   = "shanhai_qiongqi_wpn",
		wx_relic_yinglongjian  = "shanhai_yinglong",
		wx_relic_zhuyinjian    = "shanhai_zhuyin_wpn",
		wx_relic_jinwudao      = "shanhai_jinwu_saber",
		wx_relic_taowudao      = "shanhai_taowu",
		wx_relic_xiangliuqiang = "shanhai_xiangliu",
		wx_relic_gonggongshuo  = "shanhai_gonggong",
		wx_relic_qiangliangge  = "shanhai_qiangliang",
		wx_relic_jiufengji     = "shanhai_jiufeng",
		wx_relic_kuafuzhang    = "shanhai_kuafu",
		wx_relic_luwuzhao      = "shanhai_luwu",
		wx_relic_kuiguchui     = "shanhai_kui",
		wx_relic_bojian        = "shanhai_bo",
		wx_relic_chiyoufu      = "shanhai_chiyou",
		wx_relic_mingshebian   = "shanhai_mingshe",
		wx_relic_qinyuanbi     = "shanhai_qinyuan_dag",
		wx_relic_hujiaobian    = "shanhai_hujiao",
		wx_relic_yingzhaogong  = "shanhai_yingzhao",
		wx_relic_gudiaonu      = "shanhai_gudiao",
		wx_relic_huodouchong   = "shanhai_jinwu",
		wx_relic_tiangoubiao   = "shanhai_tiangou"
	};
	foreach (rid, tid in relicTraitMap)
	{
		if (rid in ::Wuxia.Config.RelicWeapons)
			::Wuxia.Config.RelicWeapons[rid].TraitID <- tid;
	}
}

// Non-destructively attach `TraitID` onto all 28 Shan-Hai Armors (14), Helmets (8) & Famed Shields (6)!
if ("ShanHaiGear" in ::Wuxia.Config)
{
	local gearTraitMap = {
		// 14 Armors
		wx_armor_zhuyan   = "shanhai_armor_zhuyan",
		wx_armor_feiyi    = "shanhai_armor_feiyi",
		wx_armor_qiongqi  = "shanhai_armor_qiongqi",
		wx_armor_jumang   = "shanhai_armor_jumang",
		wx_armor_xuangui  = "shanhai_armor_xuangui",
		wx_armor_yinglong = "shanhai_armor_yinglong",
		wx_armor_chiyou   = "shanhai_armor_chiyou",
		wx_armor_kui      = "shanhai_armor_kui",
		wx_armor_luwu     = "shanhai_armor_luwu",
		wx_armor_zhuyin   = "shanhai_armor_zhuyin",
		wx_armor_feilian  = "shanhai_armor_feilian",
		wx_armor_bifang   = "shanhai_armor_bifang",
		wx_armor_baize    = "shanhai_armor_baize",
		wx_armor_xiangliu = "shanhai_armor_xiangliu",
		// 8 Helmets
		wx_helm_taotie    = "shanhai_helm_taotie",
		wx_helm_bashe     = "shanhai_helm_bashe",
		wx_helm_kaiming   = "shanhai_helm_kaiming",
		wx_helm_chiyou    = "shanhai_helm_chiyou",
		wx_helm_jinwu     = "shanhai_helm_jinwu",
		wx_helm_dijiang   = "shanhai_helm_dijiang",
		wx_helm_siwang    = "shanhai_helm_siwang",
		wx_helm_bingyi    = "shanhai_helm_bingyi",
		// 6 Shields
		wx_shd_xuangui    = "shanhai_shd_xuangui",
		wx_shd_zaochi     = "shanhai_shd_zaochi",
		wx_shd_kui        = "shanhai_shd_kui",
		wx_shd_jumang     = "shanhai_shd_jumang",
		wx_shd_fangfeng   = "shanhai_shd_fangfeng",
		wx_shd_yinglong   = "shanhai_shd_yinglong",
		// 12 Talismans / Accessories (`wx_acc_*`) -> Total 40 Non-Weapon + 22 Weapon = 62/62 Shan-Hai Divine Gear!
		wx_acc_jiuwei     = "shanhai_acc_jiuwei",
		wx_acc_wuzhiqi    = "shanhai_acc_wuzhiqi",
		wx_acc_baize      = "shanhai_acc_baize",
		wx_acc_hundun     = "shanhai_acc_hundun",
		wx_acc_chenghuang = "shanhai_acc_chenghuang",
		wx_acc_fuzhu      = "shanhai_acc_fuzhu",
		wx_acc_boshi      = "shanhai_acc_boshi",
		wx_acc_wuluo      = "shanhai_acc_wuluo",
		wx_acc_xingxing   = "shanhai_acc_xingxing",
		wx_acc_jingwei    = "shanhai_acc_jingwei",
		wx_acc_dangkang   = "shanhai_acc_dangkang",
		wx_acc_yayu       = "shanhai_acc_yayu"
	};
	foreach (gid, tid in gearTraitMap)
	{
		if (gid in ::Wuxia.Config.ShanHaiGear)
			::Wuxia.Config.ShanHaiGear[gid].TraitID <- tid;
	}
}

// Declarative Registry for all 16 Tier-A Beast Gear & Armor Upgrade Blueprints (`百工奇物`)
// Every recipe pairs 1x custom Forging Material (`wx_mat_*`) + 1x Wild Beast Trophy!
::Wuxia.Config.CraftBlueprints <- {
	wx_bp_beast_fist = {
		Product = "scripts/items/weapons/wx_beast_fist", Cost = 520,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_renjin", Num = 1 },
			{ Script = "scripts/items/misc/ghoul_teeth_item", Num = 1 }
		]
	},
	wx_bp_beast_sword = {
		Product = "scripts/items/weapons/wx_beast_sword", Cost = 620,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_xuanlin", Num = 1 },
			{ Script = "scripts/items/misc/serpent_skin_item", Num = 1 }
		]
	},
	wx_bp_beast_saber = {
		Product = "scripts/items/weapons/wx_beast_saber", Cost = 600,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_chiling", Num = 1 },
			{ Script = "scripts/items/misc/hyena_fur_item", Num = 1 }
		]
	},
	wx_bp_beast_spear = {
		Product = "scripts/items/weapons/wx_beast_spear", Cost = 760,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_xiongjiao", Num = 1 },
			{ Script = "scripts/items/misc/lindwurm_bones_item", Num = 1 }
		]
	},
	wx_bp_beast_hammer = {
		Product = "scripts/items/weapons/wx_beast_hammer", Cost = 880,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_xiongjiao", Num = 1 },
			{ Script = "scripts/items/misc/unhold_bones_item", Num = 1 }
		]
	},
	wx_bp_beast_bow = {
		Product = "scripts/items/weapons/wx_beast_bow", Cost = 680,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_renjin", Num = 1 },
			{ Script = "scripts/items/misc/spider_silk_item", Num = 1 }
		]
	},
	wx_bp_beast_shield = {
		Product = "scripts/items/shields/wx_beast_shield", Cost = 580,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_xuanlin", Num = 1 },
			{ Script = "scripts/items/misc/glowing_resin_item", Num = 1 }
		]
	},
	wx_bp_beast_armor_light = {
		Product = "scripts/items/armor/wx_beast_armor_light", Cost = 620,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_renjin", Num = 1 },
			{ Script = "scripts/items/misc/werewolf_pelt_item", Num = 1 }
		]
	},
	wx_bp_beast_armor_med = {
		Product = "scripts/items/armor/wx_beast_armor_med", Cost = 720,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_xuanlin", Num = 1 },
			{ Script = "scripts/items/misc/glistening_scales_item", Num = 1 }
		]
	},
	wx_bp_beast_armor_heavy = {
		Product = "scripts/items/armor/wx_beast_armor_heavy", Cost = 920,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_shagu", Num = 1 },
			{ Script = "scripts/items/misc/unhold_hide_item", Num = 1 }
		]
	},
	wx_bp_beast_helm_light = {
		Product = "scripts/items/helmets/wx_beast_helm_light", Cost = 540,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_chiling", Num = 1 },
			{ Script = "scripts/items/misc/third_eye_item", Num = 1 }
		]
	},
	wx_bp_beast_helm_heavy = {
		Product = "scripts/items/helmets/wx_beast_helm_heavy", Cost = 680,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_gujing", Num = 1 },
			{ Script = "scripts/items/misc/petrified_scream_item", Num = 1 }
		]
	},
	wx_bp_up_chiling = {
		Product = "scripts/items/armor_upgrades/wx_up_chiling", Cost = 480,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_chiling", Num = 1 },
			{ Script = "scripts/items/misc/vampire_dust_item", Num = 1 }
		]
	},
	wx_bp_up_xuanlin = {
		Product = "scripts/items/armor_upgrades/wx_up_xuanlin", Cost = 580,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_xuanlin", Num = 1 },
			{ Script = "scripts/items/misc/lindwurm_scales_item", Num = 1 }
		]
	},
	wx_bp_up_shagu = {
		Product = "scripts/items/armor_upgrades/wx_up_shagu", Cost = 620,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_shagu", Num = 1 },
			{ Script = "scripts/items/misc/unhold_bones_item", Num = 1 }
		]
	},
	wx_bp_up_gujing = {
		Product = "scripts/items/armor_upgrades/wx_up_gujing", Cost = 520,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_mat_gujing", Num = 1 },
			{ Script = "scripts/items/misc/poison_gland_item", Num = 1 }
		]
	},
	// ==================== 主手兵器配件 / 器魂铭文（样板 3 件） ====================
	wx_bp_wmod_sword_tassel = {
		Product = "scripts/items/misc/wx_wmod_sword_tassel", Cost = 580,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_fengyi", Num = 1 },
			{ Script = "scripts/items/misc/spider_silk_item", Num = 1 }
		]
	},
	wx_bp_wmod_saber_guard = {
		Product = "scripts/items/misc/wx_wmod_saber_guard", Cost = 620,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_jinwu_yu", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_chiling", Num = 1 }
		]
	},
	wx_bp_wmod_fist_cuff = {
		Product = "scripts/items/misc/wx_wmod_fist_cuff", Cost = 640,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_leigu", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_renjin", Num = 1 }
		]
	},
	// ==================== 百工奇门 · 腰包战术器械（样板 2 件） ====================
	wx_bp_gadget_duanlong = {
		Product = "scripts/items/misc/wx_gadget_duanlong", Cost = 680,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_bingzhu_jiao", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_xiongjiao", Num = 1 }
		]
	},
	wx_bp_gadget_tiejili = {
		Product = "scripts/items/misc/wx_gadget_tiejili", Cost = 560,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_qinyuan_zhen", Num = 1 },
			{ Script = "scripts/items/misc/poison_gland_item", Num = 1 }
		]
	},
	// ==================== 战中破局灵散 · 多门派兵刃涂膏（样板 3 款） ====================
	wx_bp_tact_xuanshuang = {
		Product = "scripts/items/misc/wx_tact_xuanshuang", Cost = 380,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_herb_huangguan", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_xuanlin", Num = 1 }
		]
	},
	wx_bp_tact_longhusan = {
		Product = "scripts/items/misc/wx_tact_longhusan", Cost = 420,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_herb_gurong", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_chiling", Num = 1 }
		]
	},
	wx_bp_tact_qinyuangao = {
		Product = "scripts/items/misc/wx_tact_qinyuangao", Cost = 520,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_qinyuan_zhen", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_gujing", Num = 1 }
		]
	},
	// ==================== 补齐其余 10 类主手兵刃配件蓝图（合共 13/13 全兵种） ====================
	wx_bp_wmod_cleaver_ring = {
		Product = "scripts/items/misc/wx_wmod_cleaver_ring", Cost = 640,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_bingzhu_jiao", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_shagu", Num = 1 }
		]
	},
	wx_bp_wmod_spear_tassel = {
		Product = "scripts/items/misc/wx_wmod_spear_tassel", Cost = 600,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_longni", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_chiling", Num = 1 }
		]
	},
	wx_bp_wmod_polearm_hook = {
		Product = "scripts/items/misc/wx_wmod_polearm_hook", Cost = 640,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_bingzhu_jiao", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_xiongjiao", Num = 1 }
		]
	},
	wx_bp_wmod_staff_ferrule = {
		Product = "scripts/items/misc/wx_wmod_staff_ferrule", Cost = 580,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_leigu", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_shagu", Num = 1 }
		]
	},
	wx_bp_wmod_hammer_stud = {
		Product = "scripts/items/misc/wx_wmod_hammer_stud", Cost = 660,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_xuanjia", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_xiongjiao", Num = 1 }
		]
	},
	wx_bp_wmod_axe_wedge = {
		Product = "scripts/items/misc/wx_wmod_axe_wedge", Cost = 640,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_taotie_chi", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_xiongjiao", Num = 1 }
		]
	},
	wx_bp_wmod_flail_ring = {
		Product = "scripts/items/misc/wx_wmod_flail_ring", Cost = 600,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_qinyuan_zhen", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_renjin", Num = 1 }
		]
	},
	wx_bp_wmod_dagger_groove = {
		Product = "scripts/items/misc/wx_wmod_dagger_groove", Cost = 620,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_jiushou", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_gujing", Num = 1 }
		]
	},
	wx_bp_wmod_bow_string = {
		Product = "scripts/items/misc/wx_wmod_bow_string", Cost = 620,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_fengyi", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_renjin", Num = 1 }
		]
	},
	wx_bp_wmod_mech_spring = {
		Product = "scripts/items/misc/wx_wmod_mech_spring", Cost = 640,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_baize_tong", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_renjin", Num = 1 }
		]
	},
	// ==================== 补齐其余 4 件腰包奇门器械蓝图（合共 6/6） ====================
	wx_bp_gadget_zimuxia = {
		Product = "scripts/items/misc/wx_gadget_zimuxia", Cost = 660,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_baize_tong", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_gujing", Num = 1 }
		]
	},
	wx_bp_gadget_zhentianlei = {
		Product = "scripts/items/misc/wx_gadget_zhentianlei", Cost = 740,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_jinwu_yu", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_chiling", Num = 1 }
		]
	},
	wx_bp_gadget_zhangqiweng = {
		Product = "scripts/items/misc/wx_gadget_zhangqiweng", Cost = 680,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_jiushou", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_gujing", Num = 1 }
		]
	},
	wx_bp_gadget_modouwang = {
		Product = "scripts/items/misc/wx_gadget_modouwang", Cost = 660,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_xingtian_sui", Num = 1 },
			{ Script = "scripts/items/misc/spider_silk_item", Num = 1 }
		]
	},
	// ==================== 补齐其余 5 款战中破局灵散与门派涂刃膏蓝图 ====================
	wx_bp_tact_qingfenglu = {
		Product = "scripts/items/misc/wx_tact_qingfenglu", Cost = 420,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_fengyi", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_renjin", Num = 1 }
		]
	},
	wx_bp_tact_pohuanxiang = {
		Product = "scripts/items/misc/wx_tact_pohuanxiang", Cost = 440,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_baize_tong", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_chiling", Num = 1 }
		]
	},
	wx_bp_tact_huaxuegao = {
		Product = "scripts/items/misc/wx_tact_huaxuegao", Cost = 480,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_taotie_chi", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_shagu", Num = 1 }
		]
	},
	wx_bp_tact_chunyangyou = {
		Product = "scripts/items/misc/wx_tact_chunyangyou", Cost = 500,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_jinwu_yu", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_chiling", Num = 1 }
		]
	},
	wx_bp_tact_zimuguzhi = {
		Product = "scripts/items/misc/wx_tact_zimuguzhi", Cost = 520,
		Ingredients = [
			{ Script = "scripts/items/misc/wx_pmat_jiushou", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_gujing", Num = 1 }
		]
	}
};

// Declarative Registry for Mid-Battle Tactical Powders & Multi-Sect Blade Coatings (`战中灵散 · 兵刃涂膏`)
::Wuxia.Config.TacticalConsumables <- {
	wx_tact_xuanshuang = {
		ID = "wx_tact_xuanshuang", Name = "奇散·玄霜净地辟秽散", SubMode = "tile", Value = 680,
		Icon = "consumables/wx_pill_bihuo.png", SkillIcon = "skills/wx_smoke_cast.png",
		APCost = 2, QiCost = 4, IsTargeted = false, MinRange = 0, MaxRange = 0, MaxCharges = 2,
		Description = "采北岳黄雚与寒渊龙鳞研成的改地寒散（装入腰包，战中耗 2 AP 朝周身抛洒，不计入体内丹毒）：瞬间净化自身及周围 1 环六角格上的【毒火焦土 / 相柳苦泽 / 瘴气 / 迷障】化为清明寒露地脉，同时涤除范围内友军奇毒酸蚀并修复 6 点身甲！"
	},
	wx_tact_longhusan = {
		ID = "wx_tact_longhusan", Name = "奇散·龙虎醒神破穴散", SubMode = "oral", Value = 740,
		Icon = "consumables/wx_pill_longhu.png", SkillIcon = "skills/wx_status_poise_charge.png",
		APCost = 2, QiCost = 0, IsTargeted = false, MinRange = 0, MaxRange = 0, MaxCharges = 2,
		Description = "道门救急猛药（装入腰包，战中耗 2 AP 舌下含服，严格计入单场人体 2 药安全丹毒阈值！）：当场冲开【点穴封气 / 失衡 / 眩晕震慑 / 散功虚弱】，强提 +18 点内息并稳住动摇战意！"
	},
	wx_tact_qingfenglu = {
		ID = "wx_tact_qingfenglu", Name = "奇散·扶摇清风脱身散", SubMode = "oral", Value = 720,
		Icon = "consumables/wx_pill_lingfeng.png", SkillIcon = "skills/wx_smoke_cast.png",
		APCost = 2, QiCost = 0, IsTargeted = false, MinRange = 0, MaxRange = 0, MaxCharges = 1,
		Description = "裂空风翼精炼的轻身救急散（装入腰包，战中耗 2 AP 内服，计入单场人体丹毒阈值！）：瞬间震断周身【蛛网 / 捕网 / 藤蔓定身】束缚、回复 +10 内息，且本回合脱离敌方控制区免受借机拦击！"
	},
	wx_tact_pohuanxiang = {
		ID = "wx_tact_pohuanxiang", Name = "奇散·白泽破妄醒心香", SubMode = "tile", Value = 760,
		Icon = "consumables/wx_pill_dingshen.png", SkillIcon = "skills/wx_smoke_cast.png",
		APCost = 2, QiCost = 4, IsTargeted = false, MinRange = 0, MaxRange = 0, MaxCharges = 2,
		Description = "白泽神瞳合赤翎焚炼的清心奇香（装入腰包，战中耗 2 AP 燃香散雾，外用不计体内丹毒）：驱散自身及周身 1 环同袍的【魅惑 / 梦魇沉眠 / 眩惑动摇】，提升一级战意并荡清青丘迷障与暗影地效！"
	},
	wx_tact_qinyuangao = {
		ID = "wx_tact_qinyuangao", Name = "秘膏·钦原断续蚀壳膏", SubMode = "coating", Value = 860,
		Icon = "consumables/wx_pill_kongque.png", SkillIcon = "skills/wx_status_poison_dart.png",
		APCost = 2, QiCost = 5, IsTargeted = false, MinRange = 0, MaxRange = 0, MaxCharges = 2,
		Description = "五毒教合昆仑钦原尾针秘熬的猎妖涂刃奇膏（装入腰包，战中耗 2 AP 涂抹主手兵刃，持续 4 次命中）：每次命中施加 2 回合【断续封生】（彻底封死山海大妖每轮气血自愈与濒死血契复生），并额外蚀穿 14 点身甲与 1 层【太古玄壳】！"
	},
	wx_tact_huaxuegao = {
		ID = "wx_tact_huaxuegao", Name = "秘膏·化血透骨寸劲膏", SubMode = "coating", Value = 820,
		Icon = "consumables/wx_pill_shixue.png", SkillIcon = "skills/wx_blood_burst.png",
		APCost = 2, QiCost = 5, IsTargeted = false, MinRange = 0, MaxRange = 0, MaxCharges = 2,
		Description = "血刀门合少室透骨药理熬制的凶烈涂膏（战中耗 2 AP 涂抹主手兵刃，持续 4 次命中）：命中已身负【流血 / 破绽 / 内伤】的目标时引爆旧创追加 8 点无视护甲内劲实伤，并撕开深层流血（6 点/轮）！"
	},
	wx_tact_chunyangyou = {
		ID = "wx_tact_chunyangyou", Name = "秘膏·纯阳朱砂雷火油", SubMode = "coating", Value = 840,
		Icon = "consumables/wx_pill_chunyang.png", SkillIcon = "skills/wx_gun_leihuo.png",
		APCost = 2, QiCost = 5, IsTargeted = false, MinRange = 0, MaxRange = 0, MaxCharges = 2,
		Description = "龙虎天师道以十日金翎合辰州朱砂炼就的辟邪火油（战中耗 2 AP 涂抹主手兵刃，持续 4 次命中）：每击焚毁目标 16 点身甲；迎战古墓机关人与湘西尸傀时额外轰入 14 点纯阳实伤并封断亡灵复生！"
	},
	wx_tact_zimuguzhi = {
		ID = "wx_tact_zimuguzhi", Name = "秘膏·子母连环引蛊脂", SubMode = "coating", Value = 880,
		Icon = "consumables/wx_pill_fugu.png", SkillIcon = "skills/wx_status_poison_dart.png",
		APCost = 2, QiCost = 5, IsTargeted = false, MinRange = 0, MaxRange = 0, MaxCharges = 2,
		Description = "南疆五毒教以九首毒腺秘炼的传蛊奇脂（战中耗 2 AP 涂抹主手兵刃，持续 4 次命中）：命中必种【暗器奇毒】与【子母蛊印】；宿主阵亡瞬间子蛊破体跃向 2 格内至多 2 名敌军传染奇毒与【破绽】！"
	},
	wx_tact_danjiesan = {
		ID = "wx_tact_danjiesan", Name = "奇散·丹劫暴烈奇毒散", SubMode = "thrown", Value = 620,
		Icon = "consumables/wx_pill_fugu.png", SkillIcon = "skills/wx_throw_kongque.png",
		APCost = 2, QiCost = 5, IsTargeted = true, MinRange = 1, MaxRange = 3, MaxCharges = 2,
		Description = "八卦丹炉【武火催霞】遭遇六脉相克丹劫时凝结的暴烈火毒药砂（装入腰包，战中耗 2 AP 投向 1~3 格敌阵）：炸裂腐蚀目标及相邻敌军 16 点身甲并注入【暗器奇毒】！"
	}
};

// Declarative Registry for Inlayable Mainhand Weapon Attachments (`全 13 类兵刃配件 / 器魂铭文`)
::Wuxia.Config.WeaponAttachments <- {
	wx_wmod_sword_tassel = {
		ID = "wx_wmod_sword_tassel", Name = "百工·太清流云剑穗", Family = "Sword", FamilyLabel = "剑类主手兵刃", Value = 1350,
		Icon = "armor_upgrades/wx_up_chiling.png",
		BonusText = "常驻剑法命中 [color=#0a4213]+3[/color]；施展【穿步】或【反击架势】剑招命中返气 [color=#0a4213]+2[/color]，且每次剑招命中凝起流云剑意令本轮近防 [color=#0a4213]+2[/color]（至多 +4）",
		Description = "以天妖裂空风翼混雪山蚕丝编结的剑柄流苏。在行囊右键即可缀入当前侠客主手【剑类兵刃】：契合穿步游剑与反击剑宗，灵动省气且攻中寓守。"
	},
	wx_wmod_saber_guard = {
		ID = "wx_wmod_saber_guard", Name = "百工·吞口血槽刀锷铭", Family = "Saber", FamilyLabel = "刀类主手兵刃", Value = 1420,
		Icon = "armor_upgrades/wx_up_shagu.png",
		BonusText = "处于【居合蓄势】或施展【步进追斩】刀招时破甲效能 [color=#0a4213]+12%[/color]；斩中已流血目标恢复自身 [color=#0a4213]+3[/color] 内息（每轮限 2 次）",
		Description = "熔十日真火金翎与百炼乌铜镌刻的凶兽吞口刀格。右键镶入当前侠客主手【刀类兵刃】：催动居合拔刀破甲与追枭回气。"
	},
	wx_wmod_cleaver_ring = {
		ID = "wx_wmod_cleaver_ring", Name = "百工·镇岳乌金重刀环", Family = "Cleaver", FamilyLabel = "重刀/陌刀类主手兵刃", Value = 1480,
		Icon = "armor_upgrades/wx_up_shagu.png",
		BonusText = "劈击持盾敌手额外 [color=#0a4213]+10[/color] 碎盾伤；挥斩命中后本轮获得镇岳定桩（免疫击晕），重斩额外崩损目标 [color=#0a4213]8[/color] 点身甲",
		Description = "万古兵主裂岳凶角合乌金熔铸的厚背刀环。右键镶入当前侠客主手【重刀/陌刀类兵刃】：势沉破橹、磐岳难摇。"
	},
	wx_wmod_spear_tassel = {
		ID = "wx_wmod_spear_tassel", Name = "百工·赤火盘龙枪缨", Family = "Spear", FamilyLabel = "枪类主手兵刃", Value = 1380,
		Icon = "armor_upgrades/wx_up_chiling.png",
		BonusText = "控制区枪阵借机拦击命中 [color=#0a4213]+6[/color]；施展【贯线刺】两格攒刺命中时有 [color=#0a4213]45%[/color] 概率震令目标【失衡】",
		Description = "真龙逆鳞髓浸染赤炎妖翎扎成的血红枪缨。右键镶入当前侠客主手【枪类兵刃】：枪影迷目、拦骑夺先。"
	},
	wx_wmod_polearm_hook = {
		ID = "wx_wmod_polearm_hook", Name = "百工·玄铁月牙倒钩锷", Family = "Polearm", FamilyLabel = "长兵戟镰类主手兵刃", Value = 1460,
		Icon = "armor_upgrades/wx_up_shagu.png",
		BonusText = "施展【钩拉】招式命中必撕开目标【破绽】；攻击处于【失衡】状态之敌长兵总伤 [color=#0a4213]+8%[/color]",
		Description = "裂岳凶角磨制的月牙倒钩横刃。右键镶入当前侠客主手【长兵戟镰类兵刃】：钩甲破门，与前排控场无缝连携。"
	},
	wx_wmod_staff_ferrule = {
		ID = "wx_wmod_staff_ferrule", Name = "百工·少室熟铜盘龙箍", Family = "Staff", FamilyLabel = "棍杖类主手兵刃", Value = 1360,
		Icon = "armor_upgrades/wx_up_xuanlin.png",
		BonusText = "持棍承受护甲破损降低 [color=#0a4213]-10%[/color]；施展棍杖招式命中时有 [color=#0a4213]50%[/color] 概率对蓄力大妖额外注入 [color=#0a4213]+1[/color] 点破招值",
		Description = "流波雷兽夔骨嵌熟铜打制的棍梢重箍。右键镶入当前侠客主手【棍杖类兵刃】：守御坚韧，棍音震断大妖凶招。"
	},
	wx_wmod_fist_cuff = {
		ID = "wx_wmod_fist_cuff", Name = "百工·昆仑寒玉寸劲箍", Family = "Fist", FamilyLabel = "拳掌护手兵刃", Value = 1480,
		Icon = "armor_upgrades/wx_up_xuanlin.png",
		BonusText = "施展【震甲/点穴】拳掌招式命中额外崩损 [color=#0a4213]8[/color] 点身甲；击中已【失衡/点穴】目标触发透体寸劲抽散其 [color=#0a4213]6[/color] 点内息",
		Description = "取流波紫电雷兽夔骨配寒玉打磨的成对腕箍。右键镶入当前侠客主手【拳掌护手】：令寸劲隔甲透腑、专克横练与大妖蓄势。"
	},
	wx_wmod_hammer_stud = {
		ID = "wx_wmod_hammer_stud", Name = "百工·雷纹碎壳重锤鼻", Family = "Hammer", FamilyLabel = "锤锏类主手兵刃", Value = 1520,
		Icon = "armor_upgrades/wx_up_shagu.png",
		BonusText = "近战锤击命中额外崩损 [color=#0a4213]8[/color] 点身甲；重击（损甲≥20 或【震甲】招式）额外震碎山海大妖 [color=#0a4213]1[/color] 层【太古玄壳】",
		Description = "不坏玄甲残片配太古凶角熔铸的螺棱锤鼻。右键镶入当前侠客主手【锤锏类兵刃】：专为轰破巨龟重壳与重铠而生。"
	},
	wx_wmod_axe_wedge = {
		ID = "wx_wmod_axe_wedge", Name = "百工·饕餮裂木分水楔", Family = "Axe", FamilyLabel = "斧钺类主手兵刃", Value = 1460,
		Icon = "armor_upgrades/wx_up_shagu.png",
		BonusText = "劈击持盾目标或施展【破盾】招式时裂劲透盾削去敌方 [color=#0a4213]12[/color] 点身甲；迎战机关/尸傀木石之躯总伤 [color=#0a4213]+12%[/color]",
		Description = "饕餮噬元虎齿嵌斧背的分水重楔。右键镶入当前侠客主手【斧钺类兵刃】：碎橹裂甲，克制古墓机关尸傀。"
	},
	wx_wmod_flail_ring = {
		ID = "wx_wmod_flail_ring", Name = "百工·九节摄魂响铜环", Family = "Flail", FamilyLabel = "软鞭链枷类主手兵刃", Value = 1380,
		Icon = "armor_upgrades/wx_up_gujing.png",
		BonusText = "越盾击中敌方头部时铜环摄魂，额外震散目标 [color=#0a4213]5[/color] 点内息并迫使其执行 [color=#0a4213]-8[/color] 定力动摇检定",
		Description = "钦原尾针合响铜精制的九节音环。右键镶入当前侠客主手【软鞭链枷类兵刃】：越盾敲颅、乱敌心魄。"
	},
	wx_wmod_dagger_groove = {
		ID = "wx_wmod_dagger_groove", Name = "百工·幽冥藏毒深血槽", Family = "Dagger", FamilyLabel = "短兵匕首类主手兵刃", Value = 1440,
		Icon = "armor_upgrades/wx_up_gujing.png",
		BonusText = "涂抹任何【门派兵刃秘膏】时有效命中次数额外延长 [color=#0a4213]+2[/color] 击（4→6 击）；乘【破绽】出匕取首率 [color=#0a4213]+8%[/color]",
		Description = "九首毒腺酸蚀开槽的幽深蓄药血槽。右键镶入当前侠客主手【短兵匕首类兵刃】：藏毒久持、一刺封喉。"
	},
	wx_wmod_bow_string = {
		ID = "wx_wmod_bow_string", Name = "百工·天蚕龙筋弣弦", Family = "Bow", FamilyLabel = "弓箭类主手兵刃", Value = 1450,
		Icon = "armor_upgrades/wx_up_chiling.png",
		BonusText = "拉弓射箭技能内息消耗降低 [color=#0a4213]-12%[/color]；占据高地或距离 ≥5 格远射时射艺命中额外 [color=#0a4213]+5[/color]",
		Description = "天妖裂空风翼合百韧蛟筋绞制的神射弓弦。右键镶入当前侠客主手【弓箭类兵刃】：开弓省力、百步穿杨。"
	},
	wx_wmod_mech_spring = {
		ID = "wx_wmod_mech_spring", Name = "百工·墨家神机连发簧", Family = "Crossbow", Families = ["Crossbow", "Firearm", "Throwing"], FamilyLabel = "强弩/火器/暗器类主手兵刃", Value = 1480,
		Icon = "armor_upgrades/wx_up_xuanlin.png",
		BonusText = "射击与投掷招式内息消耗降低 [color=#0a4213]-15%[/color]；命中 ≤3 格近身突进之敌时劲力贯甲额外削损 [color=#0a4213]8[/color] 点身甲",
		Description = "白泽灵瞳校准、百韧蛟筋盘制的墨家机括双簧。右键镶入当前侠客主手【强弩 / 神机火器 / 投掷暗器】：劲簧省气、近射碎甲。"
	}
};

// Declarative Registry for Belt-Slot Tactical Gadgets (`百工奇门 · 六大腰包战术器械`)
::Wuxia.Config.BagGadgets <- {
	wx_gadget_duanlong = {
		ID = "wx_gadget_duanlong", Name = "奇门·墨家断龙破障钉", Value = 1650,
		Icon = "armor_upgrades/wx_up_shagu.png", SkillIcon = "skills/wx_throw_duzhen.png",
		APCost = 3, QiCost = 10, MinRange = 1, MaxRange = 4, MaxCharges = 2, TargetEnemy = true,
		Description = "墨家巨子专为克制山海巨妖护体妖障秘制的螺旋破阵钢钉（装入随身腰包，战中耗 3 AP 发射，单场 2 发且战后自动整备补满）：造成 18~26 破障刺伤，对蓄力天灾中的大妖直接注入 +2 点【破招值】、震碎 1 层【太古玄壳】并挂【破绽】！"
	},
	wx_gadget_tiejili = {
		ID = "wx_gadget_tiejili", Name = "奇门·墨家便携拒马铁蒺藜", Value = 1450,
		Icon = "armor_upgrades/wx_up_gujing.png", SkillIcon = "skills/wx_throw_pilidan.png",
		APCost = 3, QiCost = 10, MinRange = 1, MaxRange = 3, MaxCharges = 2, TargetEnemy = false,
		Description = "混入钦原尾针余毒的折叠三角玄铁刺匣（装入随身腰包，战中耗 3 AP 向 1~3 格地面或敌阵抛洒，单场 2 匣且战后自动回收整备）：刺穿目标格及相邻突进敌军 15 点护甲、强行绊至【失衡】，并在地面布设 2 回合铁蒺藜阻滞阵！"
	},
	wx_gadget_zimuxia = {
		ID = "wx_gadget_zimuxia", Name = "奇门·唐门子母追魂机括匣", Value = 1620,
		Icon = "armor_upgrades/wx_up_gujing.png", SkillIcon = "skills/wx_crossbow_liannu.png",
		APCost = 3, QiCost = 10, MinRange = 2, MaxRange = 4, MaxCharges = 2, TargetEnemy = true,
		Description = "蜀中唐门内房秘制机括袖箭匣（装入腰包，战中耗 3 AP 攒射，无需暗器修为必中）：连射三枚透骨追魂钉贯穿 14~20 气血、注入【暗器奇毒】，并破除目标闪避幻影强制暴露【破绽】！"
	},
	wx_gadget_zhentianlei = {
		ID = "wx_gadget_zhentianlei", Name = "奇门·霹雳堂破甲震天雷", Value = 1780,
		Icon = "armor_upgrades/wx_up_chiling.png", SkillIcon = "skills/wx_gun_leihuo.png",
		APCost = 4, QiCost = 12, MinRange = 2, MaxRange = 3, MaxCharges = 1, TargetEnemy = false,
		Description = "江南霹雳堂生铁火药重雷（装入腰包，战中耗 4 AP 投掷，单场 1 枚，战后自动补装火药）：轰炸目标及相邻 6 格敌阵造成 26~36 破甲震击、+18 碎盾伤、+1 大妖破招值，并炸毁地面蛛网与荆棘！"
	},
	wx_gadget_zhangqiweng = {
		ID = "wx_gadget_zhangqiweng", Name = "奇门·五毒腐骨瘴气瓮", Value = 1680,
		Icon = "armor_upgrades/wx_up_gujing.png", SkillIcon = "skills/wx_throw_kongque.png",
		APCost = 3, QiCost = 10, MinRange = 2, MaxRange = 4, MaxCharges = 1, TargetEnemy = false,
		Description = "南疆五毒教封存九首毒雾的黒陶瓮（装入腰包，战中耗 3 AP 砸碎，单场 1 瓮）：铺开 1 环腐骨瘴雾，令范围内敌军染上【暗器奇毒】与 2 回合【断续封生印】（群体压制朱厌/相柳/九婴等大妖生机自愈）！"
	},
	wx_gadget_modouwang = {
		ID = "wx_gadget_modouwang", Name = "奇门·湘西镇尸朱砂墨斗网", Value = 1600,
		Icon = "armor_upgrades/wx_up_xuanlin.png", SkillIcon = "skills/wx_flail_entangle.png",
		APCost = 3, QiCost = 10, MinRange = 1, MaxRange = 3, MaxCharges = 2, TargetEnemy = true,
		Description = "湘西赶尸一脉以陈年黑狗血、辰砂与天蚕丝织就的困邪法网（装入腰包，战中耗 3 AP 罩落，单场 2 张）：困缚目标令其【定身失衡】并挂【破绽】；对古墓机关与湘西尸傀额外灼伤 22 点气血并彻底封死亡灵复生！"
	}
};
