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
	// ==================== Tier A: 百工兽魄 (Mid-Tier Wild-Beast Gear) ====================
	beast_fist_leech = {
		Tier = "beast", Title = "噬血虎齿", Icon = "ui/icons/health.png",
		Text = "近战斩杀血肉活物时，汲取生机恢复 [color=#0a4213]+8[/color] 气血（每回合限 1 次）",
		OnKillHealHP = 8, KillHealCap = 1
	},
	beast_sword_venom = {
		Tier = "beast", Title = "青鳞淬毒", Icon = "ui/icons/special.png",
		Text = "剑脊暗嵌巴蛇毒鳞，伤血 ≥4 时有 [color=#0a4213]35%[/color] 概率施加【暗器奇毒】",
		OnHitPoisonPct = 35
	},
	beast_saber_dread = {
		Tier = "beast", Title = "婴啼裂创", Icon = "ui/icons/melee_skill.png",
		Text = "攻击动摇/崩溃之敌命中 [color=#0a4213]+8[/color]，伤血 ≥6 时 [color=#0a4213]40%[/color] 概率撕开流血伤口",
		VsShakenHit = 8, OnHitBleedPct = 40
	},
	beast_spear_acid = {
		Tier = "beast", Title = "紫血蚀甲", Icon = "ui/icons/armor_damage.png",
		Text = "肥遗毒血浸骨，近战刺中额外腐蚀目标 [color=#0a4213]10[/color] 点身甲耐久",
		OnHitArmorBurn = 10
	},
	beast_hammer_quake = {
		Tier = "beast", Title = "千钧震岳", Icon = "ui/icons/special.png",
		Text = "重击（≥14 气血伤或 ≥25 损甲）有 [color=#0a4213]45%[/color] 概率将敌手震至【失衡】",
		OnHitOffbalanceHeavyPct = 45
	},
	beast_bow_venom = {
		Tier = "beast", Title = "蛛丝缠脉", Icon = "ui/icons/ranged_skill.png",
		Text = "毒腺浸润弓弦箭簇，箭矢伤血 ≥4 时有 [color=#0a4213]30%[/color] 概率施加【暗器奇毒】",
		OnHitPoisonPct = 30
	},
	beast_shield_regen = {
		Tier = "beast", Title = "生机琥珀", Icon = "ui/icons/shield_damage.png",
		Text = "建木灵脂滋养藤牌，每回合初自动修复 [color=#0a4213]4[/color] 点盾牌耐久，且远程受击伤害 [color=#0a4213]-10%[/color]",
		TurnRegenShield = 4, RangedDmgMult = 0.90
	},
	beast_armor_swift = {
		Tier = "beast", Title = "天狗逐风", Icon = "ui/icons/initiative.png",
		Text = "轻韧无声（完美契合《金蝉卸力》）：常驻身法 [color=#0a4213]+6[/color]，开场首轮额外 [color=#0a4213]+8[/color] 身法",
		Stats = { Initiative = 6 }, FirstRoundInit = 8
	},
	beast_armor_scales = {
		Tier = "beast", Title = "滑鳞卸矢", Icon = "ui/icons/ranged_defense.png",
		Text = "青鳞滑溜难着力：避暗 [color=#0a4213]+5[/color]，承受远程箭矢与暗器伤害 [color=#0a4213]-15%[/color]",
		Stats = { RangedDefense = 5 }, RangedDmgMult = 0.85
	},
	beast_armor_vital = {
		Tier = "beast", Title = "巨猿筋骨", Icon = "ui/icons/health.png",
		Text = "厚革重骨护持脏腑：气血上限 [color=#0a4213]+10[/color]，外伤触发承受阈值提高 [color=#0a4213]+20%[/color]",
		Stats = { Hitpoints = 10 }, InjuryThresholdMult = 1.20
	},
	beast_helm_owl = {
		Tier = "beast", Title = "三目破妄", Icon = "ui/icons/vision.png",
		Text = "嵌讹兽灵眸：定力 [color=#0a4213]+6[/color]，夜战双目如昼（免除黑夜视野与射艺惩罚）",
		Stats = { Bravery = 6 }, NightOwl = true
	},
	beast_helm_ward = {
		Tier = "beast", Title = "寒晶镇魂", Icon = "ui/icons/bravery.png",
		Text = "凝魄寒晶清守灵台：定力 [color=#0a4213]+8[/color]，对抗尸傀怨灵惊骇检定额外 [color=#0a4213]+10[/color]",
		Stats = { Bravery = 8 }, AntiFearBonus = 10
	},

	// ==================== Tier B1: 山海神通 · 22 柄山海神兵 ====================
	shanhai_xingtian = {
		Tier = "shanhai", Title = "无首战魂", Icon = "ui/icons/shield_damage.png",
		Text = "劈击持盾目标额外造成 [color=#0a4213]+12[/color] 碎盾伤害；自身气血低于 50% 时凶煞总伤 [color=#0a4213]+12%[/color]",
		ShieldBreakBonus = 12, LowHpThreshold = 0.50, LowHpDmgPct = 0.12
	},
	shanhai_qiongqi_wpn = {
		Tier = "shanhai", Title = "裂风撕喉", Icon = "ui/icons/melee_skill.png",
		Text = "专噬豪杰：对定力 ≥60 目标命中 [color=#0a4213]+6[/color]，伤血 ≥6 时 [color=#0a4213]50%[/color] 概率撕裂流血",
		VsHighResolveHit = 6, OnHitBleedPct = 50
	},
	shanhai_yinglong = {
		Tier = "shanhai", Title = "沧海破势", Icon = "ui/icons/armor_damage.png",
		Text = "应龙水雷剑气：近战命中额外震损目标 [color=#0a4213]10[/color] 点身甲，且有 [color=#0a4213]35%[/color] 概率破开【破绽】",
		OnHitArmorBurn = 10, OnHitOpeningPct = 35
	},
	shanhai_zhuyin_wpn = {
		Tier = "shanhai", Title = "寒暑两仪", Icon = "ui/icons/special.png",
		Text = "左刃玄霜、右刃赤火：近战命中同时抽散目标 [color=#0a4213]6[/color] 点内息并灼毁 [color=#0a4213]10[/color] 点身甲",
		OnHitDrainQi = 6, OnHitArmorBurn = 10
	},
	shanhai_jinwu_saber = {
		Tier = "shanhai", Title = "大日焚锋", Icon = "ui/icons/armor_damage.png",
		Text = "汤谷熔金烈焰随刃流淌：近战命中灼毁目标 [color=#0a4213]10[/color] 点身甲，伤血 ≥6 时 [color=#0a4213]40%[/color] 概率撕裂流血",
		OnHitArmorBurn = 10, OnHitBleedPct = 40
	},
	shanhai_taowu = {
		Tier = "shanhai", Title = "傲狠绝退", Icon = "ui/icons/melee_skill.png",
		Text = "凶戾绝伦：攻击动摇/崩溃之敌命中 [color=#0a4213]+6[/color]，伤血 ≥6 时 [color=#0a4213]50%[/color] 概率流血，斩杀活物回血 [color=#0a4213]+8[/color]",
		VsShakenHit = 6, OnHitBleedPct = 50, OnKillHealHP = 8, KillHealCap = 1
	},
	shanhai_xiangliu = {
		Tier = "shanhai", Title = "苦泽蚀脉", Icon = "ui/icons/special.png",
		Text = "九首腥苦奇毒：命中额外蚀损 [color=#0a4213]6[/color] 点身甲，伤血 ≥4 时 [color=#0a4213]45%[/color] 概率注入【暗器奇毒】",
		OnHitArmorBurn = 6, OnHitPoisonPct = 45
	},
	shanhai_gonggong = {
		Tier = "shanhai", Title = "天倾黑水", Icon = "ui/icons/fatigue.png",
		Text = "怒涛寒劲贯体：近战命中抽取目标 [color=#0a4213]8[/color] 点内息，且有 [color=#0a4213]35%[/color] 概率令其【失衡】",
		OnHitDrainQi = 8, OnHitOffbalancePct = 35
	},
	shanhai_qiangliang = {
		Tier = "shanhai", Title = "衔蛇钩魂", Icon = "ui/icons/special.png",
		Text = "虎首重戈钩拉破门：近战命中 [color=#0a4213]35%[/color] 概率破开【破绽】，伤血 ≥4 时 [color=#0a4213]35%[/color] 概率注入【暗器奇毒】",
		OnHitOpeningPct = 35, OnHitPoisonPct = 35
	},
	shanhai_jiufeng = {
		Tier = "shanhai", Title = "九首泣血", Icon = "ui/icons/health.png",
		Text = "摄魂妖戟：攻击动摇/崩溃之敌命中 [color=#0a4213]+8[/color]，近战斩杀活物汲血恢复 [color=#0a4213]+10[/color] 气血（每轮限 2 次）",
		VsShakenHit = 8, OnKillHealHP = 10, KillHealCap = 2
	},
	shanhai_kuafu = {
		Tier = "shanhai", Title = "邓林渴渊", Icon = "ui/icons/fatigue.png",
		Text = "大日枯泽神木劲：近战命中蒸干目标 [color=#0a4213]10[/color] 点内息，并反哺自身 [color=#0a4213]+3[/color] 内息（每轮限 2 次）",
		OnHitDrainQi = 10, OnHitSelfQi = 3
	},
	shanhai_luwu = {
		Tier = "shanhai", Title = "九部虎威", Icon = "ui/icons/melee_skill.png",
		Text = "镇守昆仑帝门：控制区借机拦击命中 [color=#0a4213]+10[/color]，近战命中 [color=#0a4213]40%[/color] 概率震露【破绽】",
		ZoCBonusHit = 10, OnHitOpeningPct = 40
	},
	shanhai_kui = {
		Tier = "shanhai", Title = "流波雷音", Icon = "ui/icons/armor_damage.png",
		Text = "一击声闻五百里：近战命中额外震碎 [color=#0a4213]15[/color] 点身甲，重击 [color=#0a4213]50%[/color] 概率震至【失衡】",
		OnHitArmorBurn = 15, OnHitOffbalanceHeavyPct = 50
	},
	shanhai_bo = {
		Tier = "shanhai", Title = "食虎碎骨", Icon = "ui/icons/armor_damage.png",
		Text = "铁驳螺旋钢角隔甲震髓：破甲伤害 [color=#0a4213]+10%[/color]，命中抽散目标 [color=#0a4213]6[/color] 点内息且 [color=#0a4213]35%[/color] 概率破开【破绽】",
		ArmorDmgBonus = 0.10, OnHitDrainQi = 6, OnHitOpeningPct = 35
	},
	shanhai_chiyou = {
		Tier = "shanhai", Title = "五兵煞主", Icon = "ui/icons/armor_damage.png",
		Text = "万古兵主凶锋：破甲伤害 [color=#0a4213]+10%[/color]、劈盾额外 [color=#0a4213]+12[/color] 碎盾伤，斩敌回复 [color=#0a4213]+4[/color] 内息与 [color=#0a4213]+8[/color] 气血",
		ArmorDmgBonus = 0.10, ShieldBreakBonus = 12, OnKillQiRegen = 4, OnKillHealHP = 8, KillHealCap = 2
	},
	shanhai_mingshe = {
		Tier = "shanhai", Title = "四翼磬音", Icon = "ui/icons/fatigue.png",
		Text = "挥鞭声如古磬乱人心脉：命中抽散目标 [color=#0a4213]7[/color] 点内息，且有 [color=#0a4213]40%[/color] 概率令其【失衡】",
		OnHitDrainQi = 7, OnHitOffbalancePct = 40
	},
	shanhai_qinyuan_dag = {
		Tier = "shanhai", Title = "蜇石穿心", Icon = "ui/icons/health.png",
		Text = "刺中受控【破绽/失衡/点穴/眩晕】猎物汲取 [color=#0a4213]+8[/color] 气血（每轮限 2 次），伤血 ≥4 时 [color=#0a4213]50%[/color] 概率注入【暗器奇毒】",
		VsControlledDrainHP = 8, OnHitPoisonPct = 50
	},
	shanhai_hujiao = {
		Tier = "shanhai", Title = "蛟牙裂胄", Icon = "ui/icons/armor_damage.png",
		Text = "三枚蛟首钢锤越盾砸落：命中额外震损 [color=#0a4213]8[/color] 点身甲，伤血 ≥4 时 [color=#0a4213]40%[/color] 概率注入【暗器奇毒】",
		OnHitArmorBurn = 8, OnHitPoisonPct = 40
	},
	shanhai_yingzhao = {
		Tier = "shanhai", Title = "四海巡天", Icon = "ui/icons/ranged_skill.png",
		Text = "九石神弓贯云破甲：远程箭矢命中额外贯损目标 [color=#0a4213]12[/color] 点身甲，且有 [color=#0a4213]40%[/color] 概率震露【破绽】",
		OnHitArmorBurn = 12, OnHitOpeningPct = 40
	},
	shanhai_gudiao = {
		Tier = "shanhai", Title = "婴啼贯颅", Icon = "ui/icons/ranged_skill.png",
		Text = "攻击动摇/崩溃之敌远程命中 [color=#0a4213]+8[/color]，重矢伤血 ≥6 时有 [color=#0a4213]50%[/color] 概率撕开流血创口",
		VsShakenHit = 8, OnHitBleedPct = 50
	},
	shanhai_jinwu = {
		Tier = "shanhai", Title = "厌火焚甲", Icon = "ui/icons/armor_damage.png",
		Text = "南荒食炭凶犬烈焰铅砂：火铳轰击命中每个目标额外灼毁 [color=#0a4213]12[/color] 点身甲耐久并蒸干 [color=#0a4213]4[/color] 点内息",
		OnHitArmorBurn = 12, OnHitDrainQi = 4
	},
	shanhai_tiangou = {
		Tier = "shanhai", Title = "坠星连扑", Icon = "ui/icons/ranged_skill.png",
		Text = "≤3 格近中距投掷命中 [color=#0a4213]+8[/color]；投梭斩杀敌手时自动回收 [color=#0a4213]1[/color] 发备弹",
		CloseRangeHit = 8, OnKillRefundAmmo = 1
	},

	// ==================== Tier B2: 山海神通 · 14 领山海宝甲 ====================
	shanhai_armor_zhuyan = {
		Tier = "shanhai", Title = "沸血战意", Icon = "ui/icons/health.png",
		Text = "凶猿血核护心：气血上限 [color=#0a4213]+12[/color]；气血低于 60% 时沸血总伤 [color=#0a4213]+10%[/color]、定力 [color=#0a4213]+10[/color]",
		Stats = { Hitpoints = 12 }, LowHpThreshold = 0.60, LowHpDmgPct = 0.10, LowHpResolve = 10
	},
	shanhai_armor_feiyi = {
		Tier = "shanhai", Title = "赤鳞辟瘴", Icon = "ui/icons/armor_body.png",
		Text = "免疫山海大妖毒火灼甲光环与酸液蚀甲，受近战攻击时旱火逆鳞反灼来敌 [color=#0a4213]8[/color] 点身甲",
		ImmuneAcidAndFireAura = true, ThornsMeleeArmor = 8
	},
	shanhai_armor_qiongqi = {
		Tier = "shanhai", Title = "乘风掠影", Icon = "ui/icons/initiative.png",
		Text = "轻若鸿毛（契合《金蝉卸力》）：常驻身法 [color=#0a4213]+10[/color]，开场首轮额外暴涨 [color=#0a4213]+10[/color] 身法",
		Stats = { Initiative = 10 }, FirstRoundInit = 10
	},
	shanhai_armor_jumang = {
		Tier = "shanhai", Title = "生生建木", Icon = "ui/icons/health.png",
		Text = "都广神木灵脉流转：战斗中每回合初自动恢复 [color=#0a4213]+6[/color] 受损气血并生长修复 [color=#0a4213]+5[/color] 身甲",
		TurnRegenHP = 6, TurnRegenBodyArmor = 5
	},
	shanhai_armor_xuangui = {
		Tier = "shanhai", Title = "镇海磐岳", Icon = "ui/icons/ranged_defense.png",
		Text = "六角玄龟古甲镇护心脉：承受远程伤害 [color=#0a4213]-20%[/color]，外伤触发承受阈值提高 [color=#0a4213]+25%[/color]",
		RangedDmgMult = 0.80, InjuryThresholdMult = 1.25
	},
	shanhai_armor_yinglong = {
		Tier = "shanhai", Title = "真龙护体", Icon = "ui/icons/fatigue.png",
		Text = "应龙蓄水灵韵贯通周天：定力 [color=#0a4213]+8[/color]、每回合额外回气 [color=#0a4213]+2[/color]，受近战反震来敌 [color=#0a4213]5[/color] 点身甲",
		Stats = { Bravery = 8, FatigueRecoveryRate = 2 }, ThornsMeleeArmor = 5
	},
	shanhai_armor_chiyou = {
		Tier = "shanhai", Title = "兵主横练", Icon = "ui/icons/armor_body.png",
		Text = "古铜兽面硬抗万兵：气血上限 [color=#0a4213]+12[/color]，承受的护甲破损消耗降低 [color=#0a4213]-15%[/color]",
		Stats = { Hitpoints = 12 }, ArmorDmgTakenMult = 0.85
	},
	shanhai_armor_kui = {
		Tier = "shanhai", Title = "紫电鸣鼓", Icon = "ui/icons/fatigue.png",
		Text = "刀兵击中革铠声如雷鼓：定力 [color=#0a4213]+8[/color]，受近战攻击反震攻击者 [color=#0a4213]6[/color] 点内息",
		Stats = { Bravery = 8 }, ThornsMeleeQi = 6
	},
	shanhai_armor_luwu = {
		Tier = "shanhai", Title = "司天虎威", Icon = "ui/icons/bravery.png",
		Text = "昆仑九部帝威凛然：定力 [color=#0a4213]+10[/color]、抗惊骇检定 [color=#0a4213]+12[/color]，每回合初修复 [color=#0a4213]+4[/color] 身甲",
		Stats = { Bravery = 10 }, AntiFearBonus = 12, TurnRegenBodyArmor = 4
	},
	shanhai_armor_zhuyin = {
		Tier = "shanhai", Title = "寒暑轮转", Icon = "ui/icons/special.png",
		Text = "视为昼、瞑为夜：单数轮【瞑夜】近远双防 [color=#0a4213]+5[/color]、回气 [color=#0a4213]+3[/color]；双数轮【赤昼】攻击总伤 [color=#0a4213]+10%[/color]",
		CycleZhuyin = true
	},
	shanhai_armor_feilian = {
		Tier = "shanhai", Title = "御风千里", Icon = "ui/icons/initiative.png",
		Text = "风伯青翎御气乘风（契合《金蝉卸力》）：常驻身法 [color=#0a4213]+12[/color]，承受远程伤害 [color=#0a4213]-15%[/color]",
		Stats = { Initiative = 12 }, RangedDmgMult = 0.85
	},
	shanhai_armor_bifang = {
		Tier = "shanhai", Title = "讹火燎衣", Icon = "ui/icons/initiative.png",
		Text = "常驻身法 [color=#0a4213]+8[/color]，免疫山海大妖毒火光环与酸液蚀甲，受近战反灼来敌 [color=#0a4213]6[/color] 点身甲",
		Stats = { Initiative = 8 }, ImmuneAcidAndFireAura = true, ThornsMeleeArmor = 6
	},
	shanhai_armor_baize = {
		Tier = "shanhai", Title = "瑞兽逢凶", Icon = "ui/icons/melee_defense.png",
		Text = "通玄雪裘趋吉避凶（契合《金蝉卸力》）：招架 [color=#0a4213]+4[/color]、避暗 [color=#0a4213]+4[/color]，外伤承受阈值 [color=#0a4213]+20%[/color]",
		Stats = { MeleeDefense = 4, RangedDefense = 4 }, InjuryThresholdMult = 1.20
	},
	shanhai_armor_xiangliu = {
		Tier = "shanhai", Title = "九首毒鳞", Icon = "ui/icons/ranged_defense.png",
		Text = "以毒攻毒令穿戴者百毒不侵（免疫蛛毒与奇毒），且滑鳞卸力令远程受击伤害 [color=#0a4213]-15%[/color]",
		PoisonImmune = true, RangedDmgMult = 0.85
	},

	// ==================== Tier B3: 山海神通 · 8 顶山海宝冠战胄 ====================
	shanhai_helm_taotie = {
		Tier = "shanhai", Title = "吞天铜额", Icon = "ui/icons/armor_head.png",
		Text = "内置【铜头铁额】免疫头部额外暴击倍率，近战斩杀活物吸取 [color=#0a4213]+8[/color] 气血（每轮限 1 次）",
		SteelBrow = true, OnKillHealHP = 8, KillHealCap = 1
	},
	shanhai_helm_bashe = {
		Tier = "shanhai", Title = "灵蛇听风", Icon = "ui/icons/vision.png",
		Text = "青鳞轻束丝毫不掩耳目：避暗 [color=#0a4213]+6[/color]，视野 [color=#0a4213]+1[/color]",
		Stats = { RangedDefense = 6, Vision = 1 }
	},
	shanhai_helm_kaiming = {
		Tier = "shanhai", Title = "九首怒目", Icon = "ui/icons/bravery.png",
		Text = "内置【铜头铁额】免爆头额外暴击，定力 [color=#0a4213]+10[/color] 且抗惊骇检定额外 [color=#0a4213]+15[/color]",
		SteelBrow = true, Stats = { Bravery = 10 }, AntiFearBonus = 15
	},
	shanhai_helm_chiyou = {
		Tier = "shanhai", Title = "铜头铁额", Icon = "ui/icons/armor_head.png",
		Text = "内置【铜头铁额】免疫头部额外暴击倍率，且全身甲胄承受破甲损耗降低 [color=#0a4213]-10%[/color]",
		SteelBrow = true, ArmorDmgTakenMult = 0.90
	},
	shanhai_helm_jinwu = {
		Tier = "shanhai", Title = "大日金睛", Icon = "ui/icons/vision.png",
		Text = "赤金火翎映照百步：夜战视物如昼（免除黑夜视野与射艺惩罚），常驻身法 [color=#0a4213]+8[/color]",
		NightOwl = true, Stats = { Initiative = 8 }
	},
	shanhai_helm_dijiang = {
		Tier = "shanhai", Title = "幻空听风", Icon = "ui/icons/ranged_defense.png",
		Text = "六足四翼空间灵觉：避暗 [color=#0a4213]+8[/color]，承受远程箭矢与火器伤害 [color=#0a4213]-15%[/color]",
		Stats = { RangedDefense = 8 }, RangedDmgMult = 0.85
	},
	shanhai_helm_siwang = {
		Tier = "shanhai", Title = "独角镇岳", Icon = "ui/icons/health.png",
		Text = "青兕巨角桩功如岳：气血上限 [color=#0a4213]+10[/color]，且彻底免疫击退与钩拉位移",
		Stats = { Hitpoints = 10 }, ImmuneKnockback = true
	},
	shanhai_helm_bingyi = {
		Tier = "shanhai", Title = "寒髓清心", Icon = "ui/icons/fatigue.png",
		Text = "从极冰髓醒神养气：内息上限 [color=#0a4213]+8[/color]，每回合额外回气 [color=#0a4213]+2[/color]",
		Stats = { Stamina = 8, FatigueRecoveryRate = 2 }
	},

	// ==================== Tier B4: 山海神通 · 6 面山海传世神盾 ====================
	shanhai_shd_xuangui = {
		Tier = "shanhai", Title = "玄甲镇海", Icon = "ui/icons/ranged_defense.png",
		Text = "杻阳千年古龟甲：承受远程伤害 [color=#0a4213]-20%[/color]，受近战劈砍反震攻击者 [color=#0a4213]5[/color] 点内息",
		RangedDmgMult = 0.80, ThornsMeleeQi = 5
	},
	shanhai_shd_zaochi = {
		Tier = "shanhai", Title = "凶牙反噬", Icon = "ui/icons/armor_damage.png",
		Text = "盾圈密布六尺凿齿骨刺：每次受近战攻击时反削攻击者 [color=#0a4213]10[/color] 点身甲耐久",
		ThornsMeleeArmor = 10
	},
	shanhai_shd_kui = {
		Tier = "shanhai", Title = "雷鼓震心", Icon = "ui/icons/fatigue.png",
		Text = "敌刃砍中声若苍穹惊雷：定力 [color=#0a4213]+8[/color]，受近战攻击反震攻击者 [color=#0a4213]7[/color] 点内息",
		Stats = { Bravery = 8 }, ThornsMeleeQi = 7
	},
	shanhai_shd_jumang = {
		Tier = "shanhai", Title = "生生灵木", Icon = "ui/icons/shield_damage.png",
		Text = "建木生机流转不息：每回合初自动修复 [color=#0a4213]+6[/color] 盾牌耐久并自愈 [color=#0a4213]+4[/color] 受损气血",
		TurnRegenShield = 6, TurnRegenHP = 4
	},
	shanhai_shd_fangfeng = {
		Tier = "shanhai", Title = "专车壁垒", Icon = "ui/icons/ranged_defense.png",
		Text = "防风巨骨立盾成城：承受远程伤害 [color=#0a4213]-20%[/color]，且持盾时彻底免疫击退与抓取位移",
		RangedDmgMult = 0.80, ImmuneKnockback = true
	},
	shanhai_shd_yinglong = {
		Tier = "shanhai", Title = "旋水卸刃", Icon = "ui/icons/shield_damage.png",
		Text = "逆鳞弧面旋水化劲：每回合初修复 [color=#0a4213]+4[/color] 盾牌耐久，且承受甲胄破损消耗降低 [color=#0a4213]-15%[/color]",
		TurnRegenShield = 4, ArmorDmgTakenMult = 0.85
	}
};

// Tier A: 12 Mid-Tier Wild-Beast Weapons, Shield, Armors & Helmets + 4 Beast Armor Upgrades
::Wuxia.Config.BeastGear <- {
	wx_beast_fist = {
		ID = "wx_beast_fist", Kind = "weapon", Family = "Fist", Name = "百工·狍鸮裂骨虎齿拳", Value = 1650,
		Script = "scripts/items/weapons/wx_beast_fist", BaseScript = "scripts/items/weapons/wx_fist_base",
		Icon = "weapons/melee/wx_beast_fist_70x70.png", IconLarge = "weapons/melee/wx_beast_fist.png", ArmBrush = "arm_wx_beast_fist",
		Condition = 72.0, StaminaModifier = -7, RegularDamage = 38, RegularDamageMax = 54, ArmorDamageMult = 1.05, DirectDamageMult = 0.42,
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
		BonusText = "护甲耐久 [color=#0a4213]+20[/color]、零额外负重，且提纵身法 [color=#0a4213]+8[/color]",
		Description = "编缀赤炎妖禽翎与毕方灵灰的烈火红披风。右键镶缀于任意身甲之上：增加 20 点护甲且不增丝毫负重，并提升 8 点身法。"
	},
	wx_up_xuanlin = {
		ID = "wx_up_xuanlin", Kind = "upgrade", Name = "百工·寒渊真龙护心镜", Value = 1500,
		Script = "scripts/items/armor_upgrades/wx_up_xuanlin", BackBrush = "wx_up_xuanlin",
		ArmorBonus = 45, StaminaModifier = -2, InitiativeBonus = 0, BraveryBonus = 0, RangedMult = 0.85, ArmorDmgMult = 1.0, PoisonImmune = false,
		BonusText = "护甲耐久 [color=#0a4213]+45[/color]（负重 -2），承受远程箭矢暗器伤害 [color=#0a4213]-15%[/color]",
		Description = "以寒渊真龙逆鳞合肥遗重鳞锻成的护心背甲。右键镶缀于身甲：耐久 +45，且令远程受击伤害降低 15%。"
	},
	wx_up_shagu = {
		ID = "wx_up_shagu", Kind = "upgrade", Name = "百工·战神煞骨吞肩甲", Value = 1600,
		Script = "scripts/items/armor_upgrades/wx_up_shagu", BackBrush = "wx_up_shagu",
		ArmorBonus = 55, StaminaModifier = -3, InitiativeBonus = 0, BraveryBonus = 0, RangedMult = 1.0, ArmorDmgMult = 0.85, PoisonImmune = false,
		BonusText = "护甲耐久 [color=#0a4213]+55[/color]（负重 -3），承受破甲损耗降低 [color=#0a4213]-15%[/color]",
		Description = "以万钧战神煞骨配朱厌铁骨精制的狰狞护肩。右键镶缀于身甲：耐久 +55，且受到的护甲损耗降低 15%。"
	},
	wx_up_gujing = {
		ID = "wx_up_gujing", Kind = "upgrade", Name = "百工·幽冥毒晶辟邪囊", Value = 1350,
		Script = "scripts/items/armor_upgrades/wx_up_gujing", BackBrush = "wx_up_gujing",
		ArmorBonus = 25, StaminaModifier = 0, InitiativeBonus = 0, BraveryBonus = 8, RangedMult = 1.0, ArmorDmgMult = 1.0, PoisonImmune = true,
		BonusText = "护甲耐久 [color=#0a4213]+25[/color]、定力 [color=#0a4213]+8[/color]，且以毒攻毒令穿戴者百毒不侵",
		Description = "内封幽冥蚀骨毒晶与五毒腺囊的护身奇门腰肩囊。右键镶缀于身甲：耐久 +25、定力 +8 且免疫蛛毒与暗器奇毒。"
	}
};

// Non-destructively attach `TraitID` onto all 22 Shan-Hai Relic Weapons (preserving all custom icons & brushes!)
if ("RelicWeapons" in ::Wuxia.Config)
{
	local relicTraitMap = {
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
		wx_shd_yinglong   = "shanhai_shd_yinglong"
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
	}
};
