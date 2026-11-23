// Declarative Registry for Shan Hai Jing Mythic Resonance Sets (7 大山海神系共鸣套 + 百工猎妖过渡套 + 11 组同源本命真魂彩蛋)
// Strictly adheres to AGENTS.md D100 & Low-Magic Wuxia Redlines:
//   - Zero permanent AP bloat, zero flat MeleeSkill/RangedSkill/MeleeDefense/RangedDefense stacking!
//   - Global extra armor penetration strictly clamped <= +25%; regular HP damage mitigation strictly clamped >= 0.40 (max 60%)!
//   - Zero save-game footprint (`IsSerialized = false` runtime evaluation with 2H/paired weapon deduplication).
//   - Covers 100% of all 62 Shan-Hai Red Relics/Armors/Crowns/Shields/Talismans + all 16 Tier-A Beast Craft items!

::Wuxia.Config.ShanHaiSetOrder <- [
	"wx_set_bingzhu",
	"wx_set_canglong",
	"wx_set_jinwu",
	"wx_set_xiangliu",
	"wx_set_kunlun",
	"wx_set_qingqiu",
	"wx_set_beiming",
	"wx_set_baigong"
];

::Wuxia.Config.ShanHaiSets <- {
	// 1. 兵主凶煞套 (11 pieces: 4 Weapons + 3 Armors + 2 Helmets + 1 Shield + 1 Accessory)
	wx_set_bingzhu = {
		ID        = "wx_set_bingzhu",
		Name      = "兵主凶煞套",
		ShortName = "兵主凶煞",
		Tier      = "shanhai",
		StyleTag     = "狂战破甲 · 浴血戮神",
		Color        = "#e06b50",
		TooltipColor = "#721010",
		Icon      = "ui/perks/wx_boss_trait_chiyou.png",
		Lore      = "汇集兵主蚩尤、常羊刑天、穷奇、饕餮、檮杌、朱厌、凿齿与猰貐八大凶煞战魄，越战越狂、碎甲裂胆。",
		Pieces    = [
			"wx_relic_chiyoufu", "wx_relic_xingtianqi", "wx_relic_taowudao", "wx_relic_qiongqizhao",
			"wx_armor_chiyou", "wx_armor_zhuyan", "wx_armor_qiongqi",
			"wx_helm_chiyou", "wx_helm_taotie",
			"wx_shd_zaochi",
			"wx_acc_yayu"
		],
		Bonuses   = [
			{
				Need  = 2,
				Title = "凶煞噬血",
				Text  = "斩杀敌军时立即回复 8 点内息，若目标为血肉活物额外恢复 6 点气血（每回合限 1 次）"
			},
			{
				Need  = 3,
				Title = "兵主破军",
				Text  = "对总护甲高于 50% 的目标破甲伤害 +15%；每场战斗首次近战重击（伤血≥12 或损甲≥25）震慑敌胆，触发 -15 定力动摇检定并施加【失衡】"
			}
		]
	},

	// 2. 苍龙雷泽套 (9 pieces: 3 Weapons + 2 Armors + 1 Helmet + 2 Shields + 1 Accessory)
	wx_set_canglong = {
		ID        = "wx_set_canglong",
		Name      = "苍龙雷泽套",
		ShortName = "苍龙雷泽",
		Tier      = "shanhai",
		StyleTag     = "雷霆真伤 · 镇军统帅",
		Color        = "#5da9e9",
		TooltipColor = "#0e3969",
		Icon      = "ui/perks/wx_boss_trait_yinglong.png",
		Lore      = "取凶犁应龙、东海雷兽夔牛、鲜山鸣蛇、苍梧青兕与发鸠精卫之沧海雷泽灵韵，引雷贯甲、稳镇中军。",
		Pieces    = [
			"wx_relic_yinglongjian", "wx_relic_kuiguchui", "wx_relic_mingshebian",
			"wx_armor_yinglong", "wx_armor_kui",
			"wx_helm_siwang",
			"wx_shd_yinglong", "wx_shd_kui",
			"wx_acc_jingwei"
		],
		Bonuses   = [
			{
				Need  = 2,
				Title = "雷泽蓄势",
				Text  = "每回合首次武器攻击命中敌军时引落苍龙惊雷，额外震损目标 8 点身甲并贯入 8 点无视护甲雷震内劲"
			},
			{
				Need  = 3,
				Title = "苍龙镇岳",
				Text  = "彻底免疫击退抓取与棒槌震晕（Stun），且令自身与周身 2 格内友军定力 +8（同源光环不叠加）"
			}
		]
	},

	// 3. 大荒金乌套 (8 pieces: 3 Weapons + 2 Armors + 1 Helmet + 2 Accessories)
	wx_set_jinwu = {
		ID        = "wx_set_jinwu",
		Name      = "大荒金乌套",
		ShortName = "大荒金乌",
		Tier      = "shanhai",
		StyleTag     = "纯阳炽脉 · 焚邪破煞",
		Color        = "#f0a830",
		TooltipColor = "#5e2c00",
		Icon      = "ui/perks/wx_boss_trait_jinwu.png",
		Lore      = "融汤谷三足金乌、章莪毕方、厌火祸斗、逐日夸父、太华肥遗、钦山当康与招摇狌狌之大日阳炎，专焚尸傀邪祟。",
		Pieces    = [
			"wx_relic_jinwudao", "wx_relic_kuafuzhang", "wx_relic_huodouchong",
			"wx_armor_bifang", "wx_armor_feiyi",
			"wx_helm_jinwu",
			"wx_acc_dangkang", "wx_acc_xingxing"
		],
		Bonuses   = [
			{
				Need  = 2,
				Title = "纯阳炽脉",
				Text  = "攻击处于【流血 / 中毒 / 散功虚弱】状态的目标时，额外穿甲率 +10%（受全身总额外穿甲 +25% 硬上限约束）"
			},
			{
				Need  = 3,
				Title = "十日焚邪",
				Text  = "命中尸傀、古墓机关与山海首领时额外灼伤 12 点身甲与 12 点纯阳实伤；自身抗惊骇检定定力 +20，每回合初自动驱散【散功虚弱 / 寒凝封穴】"
			}
		]
	},

	// 4. 幽冥相柳套 (8 pieces: 4 Weapons + 1 Armor + 1 Helmet + 2 Accessories)
	wx_set_xiangliu = {
		ID        = "wx_set_xiangliu",
		Name      = "幽冥相柳套",
		ShortName = "幽冥相柳",
		Tier      = "shanhai",
		StyleTag     = "九首奇毒 · 蚀骨破甲",
		Color        = "#9d6ee8",
		TooltipColor = "#4b1c76",
		Icon      = "ui/perks/wx_boss_trait_xiangliuwang.png",
		Lore      = "凝共工相柳、昆仑毒皇钦原、北山强良、鹿吴蛊雕、苍梧巴蛇、青丘九尾与基山猼訑之幽冥奇毒，蚀铁销骨。",
		Pieces    = [
			"wx_relic_xiangliuqiang", "wx_relic_qinyuanbi", "wx_relic_qiangliangge", "wx_relic_gudiaonu",
			"wx_armor_xiangliu",
			"wx_helm_bashe",
			"wx_acc_jiuwei", "wx_acc_boshi"
		],
		Bonuses   = [
			{
				Need  = 2,
				Title = "九首蚀脉",
				Text  = "自身百毒不侵；攻击伤血 ≥4 时有 45% 概率注入【暗器奇毒】（若目标已中毒则刷新毒伤回合，并额外抽散其 6 点内息）"
			},
			{
				Need  = 3,
				Title = "万毒蚀甲",
				Text  = "攻击身负 ≥2 种负面状态（中毒/流血/破绽/失衡/点穴/散功/寒凝/眩晕/网缚）的敌军时，每击额外腐蚀 15 点身甲与 10 点头甲"
			}
		]
	},

	// 5. 昆仑瑞兽套 (10 pieces: 2 Weapons + 3 Armors + 1 Helmet + 2 Shields + 2 Accessories)
	wx_set_kunlun = {
		ID        = "wx_set_kunlun",
		Name      = "昆仑瑞兽套",
		ShortName = "昆仑瑞兽",
		Tier      = "shanhai",
		StyleTag     = "玄甲磐石 · 万法不侵",
		Color        = "#d9b45b",
		TooltipColor = "#533200",
		Icon      = "ui/perks/wx_boss_trait_luwu.png",
		Lore      = "聚昆仑司天陆吾、杻阳玄龟、东望白泽、开明虎神、中曲铁驳、会稽防风与天山浑沌之镇岳瑞气，不动如山。",
		Pieces    = [
			"wx_relic_luwuzhao", "wx_relic_bojian",
			"wx_armor_luwu", "wx_armor_xuangui", "wx_armor_baize",
			"wx_helm_kaiming",
			"wx_shd_xuangui", "wx_shd_fangfeng",
			"wx_acc_baize", "wx_acc_hundun"
		],
		Bonuses   = [
			{
				Need  = 2,
				Title = "玄甲卸劲",
				Text  = "头甲与身甲总负重惩罚减轻 15%（返还对应内息上限与身法），且内置【铜头铁额】免疫命中头部的额外暴击倍率"
			},
			{
				Need  = 3,
				Title = "昆仑磐石",
				Text  = "开场首轮及回合结束未移动时凝结 1 层【玄龟护体】：下回合开始前首次受击气血实伤 -25%（严守 60% 实伤减免硬上限）并修复 8 点身甲"
			}
		]
	},

	// 6. 青丘风翎套 (8 pieces: 2 Weapons + 2 Armors + 1 Helmet + 1 Shield + 2 Accessories)
	wx_set_qingqiu = {
		ID        = "wx_set_qingqiu",
		Name      = "青丘风翎套",
		ShortName = "青丘风翎",
		Tier      = "shanhai",
		StyleTag     = "扶摇御风 · 千里追星",
		Color        = "#5ec4a8",
		TooltipColor = "#094039",
		Icon      = "ui/perks/wx_boss_trait_yingzhao.png",
		Lore      = "采昆仑英招、阴山天狗、风伯飞廉、都广句芒、天山帝江、青要武罗与白民乘黄之御风灵羽，箭破重霄、步履无痕。",
		Pieces    = [
			"wx_relic_yingzhaogong", "wx_relic_tiangoubiao",
			"wx_armor_feilian", "wx_armor_jumang",
			"wx_helm_dijiang",
			"wx_shd_jumang",
			"wx_acc_wuluo", "wx_acc_chenghuang"
		],
		Bonuses   = [
			{
				Need  = 2,
				Title = "扶摇借风",
				Text  = "常驻视野 +1，且所有远程射击/暗器招式与轻功身法招式的内息消耗降低 20%"
			},
			{
				Need  = 3,
				Title = "重明洞察",
				Text  = "夜战双目如昼（免除夜间视野与射艺惩罚）；占据高地或距离 ≥4 格攻击命中时，令目标陷入【失衡】（身法 -15、招架 -10）并有 50% 概率震露【破绽】"
			}
		]
	},

	// 7. 北溟寒渊套 (8 pieces: 4 Weapons + 1 Armor + 1 Helmet + 2 Accessories)
	wx_set_beiming = {
		ID        = "wx_set_beiming",
		Name      = "北溟寒渊套",
		ShortName = "北溟寒渊",
		Tier      = "shanhai",
		StyleTag     = "寒潮凝脉 · 弱水封穴",
		Color        = "#6cc3e0",
		TooltipColor = "#0c3f57",
		Icon      = "ui/perks/wx_boss_trait_gonggong.png",
		Lore      = "纳钟山烛九阴、不周共工、北极九凤、玉山虎蛟、从极冰夷、淮水无支祁与敖岸夫诸之万载玄冰寒髓，封筋截脉。",
		Pieces    = [
			"wx_relic_zhuyinjian", "wx_relic_gonggongshuo", "wx_relic_jiufengji", "wx_relic_hujiaobian",
			"wx_armor_zhuyin",
			"wx_helm_bingyi",
			"wx_acc_wuzhiqi", "wx_acc_fuzhu"
		],
		Bonuses   = [
			{
				Need  = 2,
				Title = "寒渊凝脉",
				Text  = "攻击命中处于【失衡 / 破绽 / 点穴 / 寒凝 / 眩晕】状态的敌军时，汲取寒气回复自身 5 点内息（每回合限 2 次）"
			},
			{
				Need  = 3,
				Title = "弱水封穴",
				Text  = "每场战斗前 2 次重击命中（伤血≥10 或损甲≥22）时，侵入【寒凝封穴】（目标下回合行动点 -2、身法 -25）并抽散活物 8 点内息"
			}
		]
	},

	// 8. 百工猎妖录 (16 pieces: 6 Weapons + 1 Shield + 3 Armors + 2 Helmets + 4 Inlaid Beast Armor Upgrades)
	wx_set_baigong = {
		ID        = "wx_set_baigong",
		Name      = "百工猎妖录",
		ShortName = "百工猎妖",
		Tier      = "beast",
		StyleTag     = "猎妖采材 · 前中期开荒",
		Color        = "#5ec47a",
		TooltipColor = "#0a4213",
		Icon      = "ui/perks/wx_shanhai_boss_trait.png",
		Lore      = "百工丹坊以山泽异兽奇材精制的猎妖制式兵甲与护心镶片（镶缀于身甲上的百工护甲片亦计入件数！），专为搜山伐祟打造。",
		Pieces    = [
			"wx_beast_fist", "wx_beast_sword", "wx_beast_saber", "wx_beast_spear", "wx_beast_hammer", "wx_beast_bow",
			"wx_beast_shield",
			"wx_beast_armor_light", "wx_beast_armor_med", "wx_beast_armor_heavy",
			"wx_beast_helm_light", "wx_beast_helm_heavy",
			"wx_up_chiling", "wx_up_xuanlin", "wx_up_shagu", "wx_up_gujing"
		],
		Bonuses   = [
			{
				Need  = 2,
				Title = "熟谙兽性",
				Text  = "迎战山泽异兽与山海秘境首领时攻击总伤 +10%，且对抗异兽邪祟惊骇检定定力 +10"
			},
			{
				Need  = 4,
				Title = "百工庖丁",
				Text  = "战斗中每回合初自动修复 5 点身甲并回复 2 点内息；亲手斩杀野外山泽异兽时，额外获得 35% 独立掉率再剥取 1 份【百工奇材】"
			}
		]
	}
};

// 11 Same-Beast Totem Soul Pairs (`【本命真魂】` 2-piece Easter Egg when combining Lair Drop + Forged Core item of the same Apex Boss!)
::Wuxia.Config.ShanHaiTotemOrder <- [
	"chiyou", "yinglong", "kui", "qiongqi", "jinwu",
	"xiangliu", "luwu", "xuangui", "baize", "jumang", "zhuyin"
];

::Wuxia.Config.ShanHaiTotemPairs <- {
	chiyou = {
		ID     = "chiyou",
		Title  = "本命真魂·兵主蚩尤",
		Need   = 2,
		Pieces = ["wx_relic_chiyoufu", "wx_armor_chiyou", "wx_helm_chiyou"],
		Text   = "定力 +5，近战劈击持盾目标额外 +6 碎盾伤害",
		Bravery = 5, ShieldBreak = 6
	},
	yinglong = {
		ID     = "yinglong",
		Title  = "本命真魂·苍龙应龙",
		Need   = 2,
		Pieces = ["wx_relic_yinglongjian", "wx_armor_yinglong", "wx_shd_yinglong"],
		Text   = "定力 +5，战斗中每回合初额外恢复 2 点内息",
		Bravery = 5, TurnQi = 2
	},
	kui = {
		ID     = "kui",
		Title  = "本命真魂·流波夔牛",
		Need   = 2,
		Pieces = ["wx_relic_kuiguchui", "wx_armor_kui", "wx_shd_kui"],
		Text   = "定力 +5，受近战攻击时雷音反震攻击者 4 点内息",
		Bravery = 5, ThornsQi = 4
	},
	qiongqi = {
		ID     = "qiongqi",
		Title  = "本命真魂·西极穷奇",
		Need   = 2,
		Pieces = ["wx_relic_qiongqizhao", "wx_armor_qiongqi"],
		Text   = "定力 +5，常驻提纵身法 +6",
		Bravery = 5, Initiative = 6
	},
	jinwu = {
		ID     = "jinwu",
		Title  = "本命真魂·汤谷金乌",
		Need   = 2,
		Pieces = ["wx_relic_jinwudao", "wx_helm_jinwu"],
		Text   = "定力 +5，武器攻击命中额外灼损目标 4 点身甲",
		Bravery = 5, OnHitArmor = 4
	},
	xiangliu = {
		ID     = "xiangliu",
		Title  = "本命真魂·九首相柳",
		Need   = 2,
		Pieces = ["wx_relic_xiangliuqiang", "wx_armor_xiangliu"],
		Text   = "定力 +5，战斗中每回合初自动修复 4 点身甲",
		Bravery = 5, TurnBodyArmor = 4
	},
	luwu = {
		ID     = "luwu",
		Title  = "本命真魂·昆仑陆吾",
		Need   = 2,
		Pieces = ["wx_relic_luwuzhao", "wx_armor_luwu"],
		Text   = "定力 +6，外伤承受阈值额外提高 +10%",
		Bravery = 6, InjuryMult = 1.10
	},
	xuangui = {
		ID     = "xuangui",
		Title  = "本命真魂·杻阳玄龟",
		Need   = 2,
		Pieces = ["wx_armor_xuangui", "wx_shd_xuangui"],
		Text   = "定力 +5，每回合初自动修复 4 点身甲与 4 点盾牌耐久",
		Bravery = 5, TurnBodyArmor = 4, TurnShield = 4
	},
	baize = {
		ID     = "baize",
		Title  = "本命真魂·东望白泽",
		Need   = 2,
		Pieces = ["wx_armor_baize", "wx_acc_baize"],
		Text   = "定力 +6，通晓万象令常驻视野 +1",
		Bravery = 6, Vision = 1
	},
	jumang = {
		ID     = "jumang",
		Title  = "本命真魂·都广句芒",
		Need   = 2,
		Pieces = ["wx_armor_jumang", "wx_shd_jumang"],
		Text   = "定力 +5，战斗中每回合初额外自愈 3 点受损气血",
		Bravery = 5, TurnHP = 3
	},
	zhuyin = {
		ID     = "zhuyin",
		Title  = "本命真魂·钟山烛阴",
		Need   = 2,
		Pieces = ["wx_relic_zhuyinjian", "wx_armor_zhuyin"],
		Text   = "定力 +5，战斗中每回合初额外恢复 2 点内息",
		Bravery = 5, TurnQi = 2
	}
};

// Build fast O(1) reverse lookup maps: canonical gear key -> SetID / TotemID
::Wuxia.Config.ShanHaiItemToSet <- {};
foreach (_sid, _scfg in ::Wuxia.Config.ShanHaiSets)
{
	foreach (_pk in _scfg.Pieces)
	{
		::Wuxia.Config.ShanHaiItemToSet[_pk] <- _sid;
	}
}

::Wuxia.Config.ShanHaiItemToTotem <- {};
foreach (_tid, _tcfg in ::Wuxia.Config.ShanHaiTotemPairs)
{
	foreach (_pk in _tcfg.Pieces)
	{
		::Wuxia.Config.ShanHaiItemToTotem[_pk] <- _tid;
	}
}
