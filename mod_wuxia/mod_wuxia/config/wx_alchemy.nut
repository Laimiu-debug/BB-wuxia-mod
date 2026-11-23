// Deepened Wuxia Alchemy & Herb Cabinet Configuration (百草药柜 · 八卦丹炉 · 五十灵丹 · 四十九本草总谱)
// Unites all 49《山海本草》Spirit Herbs + 96 ShanHai Great Demon Cores + 28 ShanHai Beast Trophies/Materials into a single cohesive system.
// Strictly adheres to AGENTS.md: Zero permanent flat stat inflation, +25% ArmorPen ceiling, 60% HP mitigation ceiling, 2-Pill Dan-Toxin cap!

if (!("Pills" in ::Wuxia.Config))
	::Wuxia.Config.Pills <- {};

// 1. Register 28 Deepened Alchemy Pills (expanding the 22 pills in consumables.nut -> 50 Total Spirit Pills!)
local wxDeepPills = {
	// ==================== Track A: 续脉造化线 (Permanent Injury & Meridian Scar Cure) ====================
	wx_pill_shengsheng = {
		ID          = "wx_pill_shengsheng",
		Name        = "生生造化丹",
		SubLabel    = "枯脉重续",
		Quality     = "unique",
		Description = "夺天地生机精炼而成的碧玉圣丹。服之可彻底拔除角色身上 1 处洗髓失败留下的永久「经脉暗疾」，并涤尽全部临时内伤与散功虚弱、补满气血。",
		Kind        = "cure_perm_scar",
		Icon        = "consumables/wx_pill_shengsheng.png",
		Value       = 3200
	},
	wx_pill_duanxu = {
		ID          = "wx_pill_duanxu",
		Name        = "黑玉断续膏",
		SubLabel    = "断骨重续",
		Quality     = "unique",
		Description = "西域奇门与杏林圣手合炼的旷世黑玉秘膏。敷服后可逆转残躯，直接治愈 1 处原版「永久伤残」（瞎眼、断指、损肺、断膝等），并解除全部临时外伤！",
		Kind        = "cure_perm_injury",
		Icon        = "consumables/wx_pill_duanxu.png",
		Value       = 3800
	},

	// ==================== Track B: 高阶洗髓与无损换功线 ====================
	wx_pill_zijin_xisui = {
		ID              = "wx_pill_zijin_xisui",
		Name            = "太乙紫金洗髓丹",
		SubLabel        = "天品洗髓",
		Quality         = "unique",
		Description     = "融太古大妖内丹与绝品奇草九转而成的紫金龙纹宝丹。开启洗经伐髓选用此丹：成功率额外 +12%（总上限可达 90%），且纵使未成亦免受重度「经脉震荡」（降为 2 日轻调息）、暗疾风险减半！",
		Kind            = "marrow_wash_supreme",
		WashBonus       = 12,
		AvoidHeavyShock = true,
		Icon            = "consumables/wx_pill_zijin_xisui.png",
		Value           = 6800
	},
	wx_pill_yijin_wan = {
		ID            = "wx_pill_yijin_wan",
		Name          = "易筋锻骨丸",
		SubLabel      = "开脉换星",
		Quality       = "secret",
		Description   = "少室禅宗与道门秘传的易筋金丸。专精于为 0★ 属性开脉启星（含三项满星时的「易筋换星」）：用于 0★→1★ 时额外提供 +20% 成功率，助好苗子稳妥改命！（亦可用于常规冲星）",
		Kind          = "marrow_wash_yijin",
		ZeroStarBonus = 20,
		Icon          = "consumables/wx_pill_yijin_wan.png",
		Value         = 2800
	},
	wx_pill_wangchen = {
		ID          = "wx_pill_wangchen",
		Name        = "忘尘归元散",
		SubLabel    = "无损换功",
		Quality     = "sect",
		Description = "青瓷葫芦盛装的清灵秘散。若当前有「散功虚弱」服之立解；若当前无恙，服之凝结一层「归元护脉」——下一次换装或卸下任意品阶武学插槽时，散功调息天数直接归 0！",
		Kind        = "wangchen_grace",
		Icon        = "consumables/wx_pill_wangchen.png",
		Value       = 560
	},

	// ==================== Track C: 山海凶兽对策备战灵丹 ====================
	wx_pill_bihuo = {
		ID          = "wx_pill_bihuo",
		Name        = "玄冰辟火丸",
		SubLabel    = "辟火抗瘴",
		Quality     = "sect",
		Description = "寒玉奇草配玄水妖髓凝成的冰魄宝丸：令下场战斗免疫山海凶兽（肥遗、毕方、鹓鶵、九婴等）毒火灼甲与蒸气光环，远射受击 -15%，每回合回气 +2（战后消散）。",
		Kind        = "buff_bihuo",
		Icon        = "consumables/wx_pill_bihuo.png",
		Value       = 540
	},
	wx_pill_yuji = {
		ID          = "wx_pill_yuji",
		Name        = "玉肌止血散",
		SubLabel    = "凝肌免裂",
		Quality     = "sect",
		Description = "羊脂玉瓶盛装的百草止血圣散：令下场战斗全程免疫「流血割裂」（专克穷奇、陆吾、蛊雕裂创），外伤承受阈值 +25%，每回合初自愈 5 点气血（战后消散）。",
		Kind        = "buff_yuji",
		Icon        = "consumables/wx_pill_yuji.png",
		Value       = 500
	},
	wx_pill_longhu = {
		ID          = "wx_pill_longhu",
		Name        = "龙虎提纵散",
		SubLabel    = "御风生根",
		Quality     = "sect",
		Description = "御风灵草合异兽筋髓秘制的提纵丹散：令下场战斗轻功身法 +15、避暗 +5，且下盘生根免疫击退与巨蟒缠拽（战后消散）。",
		Kind        = "buff_longhu",
		Icon        = "consumables/wx_pill_longhu.png",
		Value       = 520
	},
	wx_pill_fengmo = {
		ID          = "wx_pill_fengmo",
		Name        = "疯魔燃血丸",
		SubLabel    = "凶煞禁药",
		Quality     = "secret",
		Description = "凶兽煞丹与狂草催谷的邪道猛药：令下场战斗取首命中率 +15%、破甲 +15%、额外穿甲 +10%（受全身 25% 封顶约束）；药力酷烈，战后必留 2 日轻度内伤！",
		Kind        = "buff_fengmo",
		Icon        = "consumables/wx_pill_fengmo.png",
		Value       = 780
	},

	// ==================== Track D: 重甲横练与前排守线机制灵丹 ====================
	wx_pill_juling = {
		ID          = "wx_pill_juling",
		Name        = "巨灵披甲行气丸",
		SubLabel    = "披甲减重",
		Quality     = "sect",
		Description = "百炼煞骨合赤阳奇草熬炼的行气重丸：令下场战斗按头盔与身甲总负重返还 22% 内息上限（至多 +18；已具披甲行气者折半互补），且甲胄破损消耗 -10%（战后消散）。",
		Kind        = "buff_juling",
		Icon        = "consumables/wx_pill_juling.png",
		Value       = 560
	},
	wx_pill_tiee = {
		ID          = "wx_pill_tiee",
		Name        = "铜皮铁额护顶膏",
		SubLabel    = "护顶免暴",
		Quality     = "sect",
		Description = "古龟甲胶配铁骨灵脂熬制的护顶秘膏：令下场战斗凝成【铜头铁额】——彻底免除命中头部的额外暴击伤害倍率，且头盔耐久损耗 -20%（战后消散）。",
		Kind        = "buff_tiee",
		Icon        = "consumables/wx_pill_tiee.png",
		Value       = 580
	},
	wx_pill_jiugong = {
		ID          = "wx_pill_jiugong",
		Name        = "九宫磐石守阵丸",
		SubLabel    = "抗围孤胆",
		Quality     = "secret",
		Description = "奇门九宫磁石合镇魂灵草精制的守线宝丸：令下场战斗免受群敌合围近防折损（抗围近防 +5），且控制区借机拦击命中 +10（战后消散）。",
		Kind        = "buff_jiugong",
		Icon        = "consumables/wx_pill_jiugong.png",
		Value       = 780
	},
	wx_pill_jingji = {
		ID          = "wx_pill_jingji",
		Name        = "玄甲反震刺猬散",
		SubLabel    = "震甲散气",
		Quality     = "secret",
		Description = "凿齿凶牙末配刚猛妖髓研成的护体奇散：令下场战斗每次受近战攻击时，罡气反削来敌 8 点身甲耐久并震散其 4 点内息（战后消散）。",
		Kind        = "buff_jingji",
		Icon        = "consumables/wx_pill_jingji.png",
		Value       = 820
	},

	// ==================== Track E: 轻装游斗、先天护体与狂侠名酿 ====================
	wx_pill_zuixian = {
		ID          = "wx_pill_zuixian",
		Name        = "醉仙望月狂酒",
		SubLabel    = "乘醉弄险",
		Quality     = "secret",
		Description = "青花酒葫封藏的百草狂侠烈酿：痛饮入阵令下场战斗定力 +15、招架 +6、近战总伤 +10%；唯微醺朦胧致射艺 -10、视野 -1（战后酒醒消散）。",
		Kind        = "buff_zuixian",
		Icon        = "consumables/wx_pill_zuixian.png",
		Value       = 760
	},
	wx_pill_xiantian = {
		ID          = "wx_pill_xiantian",
		Name        = "先天真气护体丹",
		SubLabel    = "罡气化伤",
		Quality     = "secret",
		Description = "玄门先天玉液凝成的太极宝丹：令下场战斗张开【先天真气护体】，受气血实伤时消耗内息按 1:2 抵消至多 25% 伤害（与轻装卸力合算硬封顶 60%，战后消散）。",
		Kind        = "buff_xiantian",
		Icon        = "consumables/wx_pill_xiantian.png",
		Value       = 880
	},
	wx_pill_lingfeng = {
		ID          = "wx_pill_lingfeng",
		Name        = "踏雪凌风轻身露",
		SubLabel    = "减耗越障",
		Quality     = "secret",
		Description = "飞廉风翎配寒渊灵露萃成的提纵仙露：令下场战斗跋涉沼泽雪山行气消耗减半、上下高低差免额外 AP，且开场首轮先手身法 +15（战后消散）。",
		Kind        = "buff_lingfeng",
		Icon        = "consumables/wx_pill_lingfeng.png",
		Value       = 840
	},
	wx_pill_gufeng = {
		ID          = "wx_pill_gufeng",
		Name        = "孤锋破玉淬劲散",
		SubLabel    = "空手决斗",
		Quality     = "secret",
		Description = "剑宗秘传透甲散：令下场战斗持单手兵刃空副手（或佩成对拳套）时额外穿甲 +12%（受全身 +25% 穿甲上限约束），且对半数以上完好重甲破甲 +15%（战后消散）。",
		Kind        = "buff_gufeng",
		Icon        = "consumables/wx_pill_gufeng.png",
		Value       = 860
	},

	// ==================== Track F: 五毒奇门、寻隙封脉与饮血收割 ====================
	wx_pill_kongque = {
		ID          = "wx_pill_kongque",
		Name        = "南疆孔雀胆淬毒膏",
		SubLabel    = "见血封喉",
		Quality     = "secret",
		Description = "五毒教秘熬孔雀蓝剧毒膏脂：令下场战斗兵刃暗器伤血 ≥4 时有 55% 概率注入【暗器奇毒】，且攻击已中毒猎物近远命中 +6（战后消散）。",
		Kind        = "buff_kongque",
		Icon        = "consumables/wx_pill_kongque.png",
		Value       = 820
	},
	wx_pill_fugu = {
		ID          = "wx_pill_fugu",
		Name        = "五仙腐骨蚀甲散",
		SubLabel    = "蚀铁融甲",
		Quality     = "secret",
		Description = "相柳苦毒配蚀骨寒晶研制的融甲奇散：令下场战斗每次攻击命中额外腐蚀目标 10 点身甲耐久，若目标持盾再蚀 6 点盾牌耐久（战后消散）。",
		Kind        = "buff_fugu",
		Icon        = "consumables/wx_pill_fugu.png",
		Value       = 800
	},
	wx_pill_suoxue = {
		ID          = "wx_pill_suoxue",
		Name        = "透骨寻隙封脉散",
		SubLabel    = "破绽封穴",
		Quality     = "secret",
		Description = "点穴名家秘配透骨寒散：令下场战斗攻击命中时 35% 概率震露目标【破绽】；若击中头部或已露【破绽】之敌，另有 30% 概率触发【点穴封气】（战后消散）。",
		Kind        = "buff_suoxue",
		Icon        = "consumables/wx_pill_suoxue.png",
		Value       = 860
	},
	wx_pill_shixue = {
		ID          = "wx_pill_shixue",
		Name        = "血煞饮血狂战丸",
		SubLabel    = "斩敌回元",
		Quality     = "secret",
		Description = "血煞宗以凶兽心头血炼制的嗜战丹丸：令下场战斗对半血以下残敌总伤害 +12%，且斩杀血肉活物立回 10 点气血与 5 点内息（每轮限 2 次，战后消散）。",
		Kind        = "buff_shixue",
		Icon        = "consumables/wx_pill_shixue.png",
		Value       = 850
	},

	// ==================== Track G: 神射火器、诛邪克傀与同袍战阵 ====================
	wx_pill_yingyan = {
		ID          = "wx_pill_yingyan",
		Name        = "千里破雾鹰眼露",
		SubLabel    = "神射穿云",
		Quality     = "sect",
		Description = "海东青灵髓配明目奇花滴制的金珀眼露：令下场战斗视野 +1、免除夜盲，且 ≥4 格远距射击命中 +6、无视目标 25% 轻功闪避远防（战后消散）。",
		Kind        = "buff_yingyan",
		Icon        = "consumables/wx_pill_yingyan.png",
		Value       = 560
	},
	wx_pill_pili = {
		ID          = "wx_pill_pili",
		Name        = "神机震雷火药引",
		SubLabel    = "轰雷震慑",
		Quality     = "sect",
		Description = "霹雳堂赤硝合雷兽骨粉精制的暴烈药引：令下场战斗远程火器、强弩或重击命中时 40% 概率将敌震至【失衡】，劈射持盾之敌碎盾 +8（战后消散）。",
		Kind        = "buff_pili",
		Icon        = "consumables/wx_pill_pili.png",
		Value       = 580
	},
	wx_pill_chunyang = {
		ID          = "wx_pill_chunyang",
		Name        = "龙虎纯阳破邪丹",
		SubLabel    = "诛邪克傀",
		Quality     = "secret",
		Description = "天师道赤火灵芝合雷击朱砂九炼的辟邪金丹：令下场战斗对古墓机关与湘西尸傀总伤害 +18%、命中额外焚毁邪祟 8 点护甲，且抗惊骇检定 +15（战后消散）。",
		Kind        = "buff_chunyang",
		Icon        = "consumables/wx_pill_chunyang.png",
		Value       = 840
	},
	wx_pill_hufu = {
		ID          = "wx_pill_hufu",
		Name        = "聚义虎符壮胆丸",
		SubLabel    = "稳阵协防",
		Quality     = "sect",
		Description = "义社中军出征前分服的壮胆红丸：令下场战斗必定以【战意高昂】满志入阵，且身旁有 ≥2 名同袍相邻结阵时近远双防 +4、定力 +8（战后消散）。",
		Kind        = "buff_hufu",
		Icon        = "consumables/wx_pill_hufu.png",
		Value       = 540
	},

	// ==================== Track H: 绝境锁血、镇魔驭残与醍醐顿悟奇丹 ====================
	wx_pill_baoming = {
		ID          = "wx_pill_baoming",
		Name        = "天王吊命保心丹",
		SubLabel    = "九命锁血",
		Quality     = "unique",
		Description = "杏林夺命护心圣药：令下场战斗遭受致命一击时必定锁血 1 点不死（单场 1 次），触发瞬间涤清流血与奇毒并急回 12 点气血与 10 点内息（战后消散）！",
		Kind        = "buff_baoming",
		Icon        = "consumables/wx_pill_baoming.png",
		Value       = 1650
	},
	wx_pill_zhenmo = {
		ID          = "wx_pill_zhenmo",
		Name        = "太清镇魔定脉丹",
		SubLabel    = "稳驭残本",
		Quality     = "secret",
		Description = "太和宫清心镇魔宝丹：令下场战斗彻底镇压「双内功相克逆冲」与「残本强修散气」反噬，且每次攻击落空自动凝神补正下次命中 +6 直至击中（战后消散）。",
		Kind        = "buff_zhenmo",
		Icon        = "consumables/wx_pill_zhenmo.png",
		Value       = 760
	},
	wx_pill_tihu = {
		ID          = "wx_pill_tihu",
		Name        = "紫芝醍醐悟道丹",
		SubLabel    = "顿悟倍功",
		Quality     = "unique",
		Description = "九叶紫芝合白泽通玄灵韵炼就的悟道仙丹：令下场战斗人物历练经验获取 +35%，且战后结算时全身所装武学参战火候额外暴涨 +50%（战后消散）！",
		Kind        = "buff_tihu",
		Icon        = "consumables/wx_pill_tihu.png",
		Value       = 1580
	}
};

foreach (pid, pdef in wxDeepPills)
{
	::Wuxia.Config.Pills[pid] <- pdef;
}

// 2. Six Medicinal Natures, Starter Known Formulas, Explicit Herb/Trophy Metadata & 50 Bagua Cauldron Formulas
::Wuxia.Config.Alchemy <- {
	// 6 Basic Jianghu Formulas unlocked out-of-the-box so the Cauldron is immediately usable in early game!
	StarterFormulas = {
		f_jinchuang = true,
		f_huoluo    = true,
		f_huxin     = true,
		f_qingxin   = true,
		f_hugu      = true,
		f_ningshen  = true
	},

	Natures = {
		vital  = { ID = "vital",  Name = "青木生机", Short = "生机", Color = "#5ec47a", Seal = "ui/wx_icons/wx_seal_vital.png",  Desc = "固本培元、生肌续骨之草木精气。" },
		yang   = { ID = "yang",   Name = "赤阳烈火", Short = "赤阳", Color = "#e87a42", Seal = "ui/wx_icons/wx_seal_yang.png",   Desc = "刚猛燥烈、催动气血奔涌之纯阳火元。" },
		yin    = { ID = "yin",    Name = "玄阴寒髓", Short = "玄阴", Color = "#6db4e8", Seal = "ui/wx_icons/wx_seal_yin.png",    Desc = "清冽彻骨、涤荡毒火灼瘴之寒渊水元。" },
		spirit = { ID = "spirit", Name = "紫府镇魂", Short = "镇魂", Color = "#b58ae6", Seal = "ui/wx_icons/wx_seal_origin.png", Desc = "凝神定魄、澄明百会灵台之通玄药引。" },
		venom  = { ID = "venom",  Name = "奇瘴毒元", Short = "奇毒", Color = "#95c44b", Seal = "ui/wx_icons/wx_seal_vital.png",  Desc = "以毒攻毒、激发奇经潜能之异种蛊毒。" },
		origin = { ID = "origin", Name = "造化混沌", Short = "造化", Color = "#f0bc42", Seal = "ui/wx_icons/wx_seal_origin.png", Desc = "夺天地造化、伐毛洗髓之太古本源。" }
	},

	// Three Refined Pill Quality Grades (成丹 -> 灵纹 -> 丹霞极品)
	PillGrades = {
		[1] = { Grade = 1, Title = "成丹", Prefix = "",      Color = "#d7b174", TooltipColor = "#3f362a", MinPct = 92,  MaxPct = 106, ValueMult = 1.00, WashBonus = 0, ProtectBonus = 0 },
		[2] = { Grade = 2, Title = "灵纹", Prefix = "灵纹·", Color = "#5ec47a", TooltipColor = "#0a4213", MinPct = 114, MaxPct = 130, ValueMult = 1.30, WashBonus = 4, ProtectBonus = 2 },
		[3] = { Grade = 3, Title = "丹霞", Prefix = "丹霞·", Color = "#f0bc42", TooltipColor = "#5e2c00", MinPct = 136, MaxPct = 155, ValueMult = 1.68, WashBonus = 8, ProtectBonus = 5 }
	},

	// Six Auxiliary Herb/Core Nature Side-Effects (`【药引丹韵】` imbued by Cauldron臣佐辅药!)
	AuxInfusions = {
		vital = {
			ID = "vital", Title = "生机丹韵", Color = "#5ec47a", TooltipColor = "#0a4213", Bit = 1,
			PrepDesc   = "服药立回 15 气血，且下战每回合初温养自愈 +3 气血",
			InfuseDesc = "灌注【横练硬功】插槽触发木元共鸣，额外 +15% 火候",
			HealDesc   = "草木生机加持，服敷时额外多恢复 +20 受损气血"
		},
		yang = {
			ID = "yang", Title = "赤阳丹韵", Color = "#e87a42", TooltipColor = "#6c1f04", Bit = 2,
			PrepDesc   = "纯阳催劲，下场战斗攻击破甲效能额外 +8%",
			InfuseDesc = "灌注【阳刚内功 / 外功套路】触发火元共鸣，额外 +15% 火候",
			HealDesc   = "纯阳活血通络，服敷时额外恢复 +15 气血"
		},
		yin = {
			ID = "yin", Title = "玄阴丹韵", Color = "#6db4e8", TooltipColor = "#0e3969", Bit = 4,
			PrepDesc   = "寒髓润脉，下场战斗每回合额外回气 +2 内息",
			InfuseDesc = "灌注【阴柔内功 / 轻功身法】触发水元共鸣，额外 +15% 火候",
			HealDesc   = "清寒涤脉，额外消减 1 日内伤或散功调息天数"
		},
		spirit = {
			ID = "spirit", Title = "镇魂丹韵", Color = "#b58ae6", TooltipColor = "#4b1c76", Bit = 8,
			PrepDesc   = "灵台澄明，下场战斗定力 +6、抗惊骇检定额外 +8",
			InfuseDesc = "灌注【中正内功 / 奇门杂学】触发识海共鸣，额外 +15% 火候",
			HealDesc   = "宁心定魄，服敷时额外恢复 +15 气血"
		},
		venom = {
			ID = "venom", Title = "奇毒丹韵", Color = "#95c44b", TooltipColor = "#2d3f06", Bit = 16,
			PrepDesc   = "以毒淬劲，下场战斗伤血 ≥5 时 25% 概率附着【暗器奇毒】",
			InfuseDesc = "灌注【邪派内功 / 奇门杂学】触发蛊元共鸣，额外 +15% 火候",
			HealDesc   = "以毒攻毒催发淤血，外伤膏散可额外多解 1 处外伤"
		},
		origin = {
			ID = "origin", Title = "造化丹韵", Color = "#f0bc42", TooltipColor = "#5e2c00", Bit = 32,
			PrepDesc   = "混元护体，下场战斗临时气血上限 +8、内息上限 +6",
			InfuseDesc = "灌注任意【绝学 / 江湖孤本】触发造化共鸣，额外 +15% 火候",
			HealDesc   = "夺天地造化，服敷时额外恢复 +30 受损气血"
		}
	},

	// Explicit metadata for all 49《山海本草》Spirit Herbs (Potency 2~5 across all 6 Meridian Natures)
	HerbNatures = {
		wx_marrow_herb      = { Nature = "origin", Potency = 4 },
		wx_herb_zhuyu       = { Nature = "vital",  Potency = 3 },
		wx_herb_migu        = { Nature = "spirit", Potency = 3 },
		wx_herb_bili        = { Nature = "vital",  Potency = 3 },
		wx_herb_xuncao      = { Nature = "vital",  Potency = 3 },
		wx_herb_shatang     = { Nature = "origin", Potency = 4 },
		wx_herb_dixiu       = { Nature = "spirit", Potency = 3 },
		wx_herb_duheng      = { Nature = "yang",   Potency = 3 },
		wx_herb_jiarong     = { Nature = "venom",  Potency = 3 },
		wx_herb_zhichu      = { Nature = "spirit", Potency = 3 },
		wx_herb_guicao      = { Nature = "spirit", Potency = 4 },
		wx_herb_longxuejie  = { Nature = "yang",   Potency = 4 },
		wx_herb_xuelian     = { Nature = "yin",    Potency = 4 },
		wx_herb_heshouwu    = { Nature = "vital",  Potency = 4 },
		wx_herb_zizhi       = { Nature = "origin", Potency = 5 },
		wx_herb_huolingzhi  = { Nature = "yang",   Potency = 4 },
		wx_herb_bingpocao   = { Nature = "yin",    Potency = 4 },
		// 卷二：五藏山经 · 道地奇草与山泽灵卉（16 味）
		wx_herb_huangguan   = { Nature = "yin",    Potency = 2 },
		wx_herb_tiaocao     = { Nature = "spirit", Potency = 2 },
		wx_herb_pincao      = { Nature = "vital",  Potency = 2 },
		wx_herb_mangcao     = { Nature = "venom",  Potency = 2 },
		wx_herb_wutiao      = { Nature = "yang",   Potency = 2 },
		wx_herb_gurong      = { Nature = "yang",   Potency = 2 },
		wx_herb_jiancao     = { Nature = "yin",    Potency = 2 },
		wx_herb_gouwen      = { Nature = "venom",  Potency = 3 },
		wx_herb_longchu     = { Nature = "yang",   Potency = 3 },
		wx_herb_baiman      = { Nature = "vital",  Potency = 3 },
		wx_herb_xuanji      = { Nature = "yin",    Potency = 3 },
		wx_herb_yaocao      = { Nature = "spirit", Potency = 3 },
		wx_herb_guimu       = { Nature = "venom",  Potency = 3 },
		wx_herb_zhugu       = { Nature = "yang",   Potency = 3 },
		wx_herb_hanshui     = { Nature = "yin",    Potency = 3 },
		wx_herb_sutiao      = { Nature = "origin", Potency = 3 },
		// 卷三：海外·海内·大荒经 · 秘境奇珍与天地仙株（16 味）
		wx_herb_zhenyu      = { Nature = "venom",  Potency = 4 },
		wx_herb_xiangliuxue = { Nature = "venom",  Potency = 4 },
		wx_herb_wuzhi       = { Nature = "spirit", Potency = 4 },
		wx_herb_danmu       = { Nature = "yang",   Potency = 4 },
		wx_herb_xunmu       = { Nature = "vital",  Potency = 4 },
		wx_herb_yushu       = { Nature = "yin",    Potency = 4 },
		wx_herb_ruomu       = { Nature = "yang",   Potency = 4 },
		wx_herb_yinglu      = { Nature = "vital",  Potency = 4 },
		wx_herb_youduhua    = { Nature = "spirit", Potency = 4 },
		wx_herb_langgan     = { Nature = "origin", Potency = 4 },
		wx_herb_zhusang     = { Nature = "yin",    Potency = 4 },
		wx_herb_panmu       = { Nature = "vital",  Potency = 4 },
		wx_herb_fusang      = { Nature = "yang",   Potency = 5 },
		wx_herb_busicao     = { Nature = "vital",  Potency = 5 },
		wx_herb_jianmu      = { Nature = "origin", Potency = 5 },
		wx_herb_yuegui      = { Nature = "yin",    Potency = 5 }
	},

	// Explicit metadata for built-in herbs, 22 ShanHai beast trophies & 6 hunted Beast Forging Materials
	KnownMaterials = {
		["misc.wx_marrow_herb"]      = { Kind = "herb",   Nature = "origin", Potency = 4, Script = "scripts/items/misc/wx_marrow_herb" },
		["misc.unhold_heart"]        = { Kind = "trophy", Nature = "yang",   Potency = 3, Script = "scripts/items/misc/unhold_heart_item" },
		["misc.unhold_hide"]         = { Kind = "trophy", Nature = "vital",  Potency = 2, Script = "scripts/items/misc/unhold_hide_item" },
		["misc.unhold_bones"]        = { Kind = "trophy", Nature = "yang",   Potency = 2, Script = "scripts/items/misc/unhold_bones_item" },
		["misc.lindwurm_bones"]      = { Kind = "trophy", Nature = "origin", Potency = 3, Script = "scripts/items/misc/lindwurm_bones_item" },
		["misc.lindwurm_blood"]      = { Kind = "trophy", Nature = "venom",  Potency = 3, Script = "scripts/items/misc/lindwurm_blood_item" },
		["misc.lindwurm_scales"]     = { Kind = "trophy", Nature = "yang",   Potency = 3, Script = "scripts/items/misc/lindwurm_scales_item" },
		["misc.spider_silk"]         = { Kind = "trophy", Nature = "yin",    Potency = 1, Script = "scripts/items/misc/spider_silk_item" },
		["misc.poison_gland"]        = { Kind = "trophy", Nature = "venom",  Potency = 2, Script = "scripts/items/misc/poison_gland_item" },
		["misc.ghoul_brain"]         = { Kind = "trophy", Nature = "spirit", Potency = 2, Script = "scripts/items/misc/ghoul_brain_item" },
		["misc.ghoul_horn"]          = { Kind = "trophy", Nature = "yang",   Potency = 1, Script = "scripts/items/misc/ghoul_horn_item" },
		["misc.ghoul_teeth"]         = { Kind = "trophy", Nature = "yang",   Potency = 1, Script = "scripts/items/misc/ghoul_teeth_item" },
		["misc.werewolf_pelt"]       = { Kind = "trophy", Nature = "yin",    Potency = 1, Script = "scripts/items/misc/werewolf_pelt_item" },
		["misc.hyena_fur"]           = { Kind = "trophy", Nature = "yang",   Potency = 1, Script = "scripts/items/misc/hyena_fur_item" },
		["misc.serpent_skin"]        = { Kind = "trophy", Nature = "yin",    Potency = 2, Script = "scripts/items/misc/serpent_skin_item" },
		["misc.glistening_scales"]   = { Kind = "trophy", Nature = "yin",    Potency = 2, Script = "scripts/items/misc/glistening_scales_item" },
		["misc.heart_of_the_forest"] = { Kind = "trophy", Nature = "vital",  Potency = 4, Script = "scripts/items/misc/heart_of_the_forest_item" },
		["misc.glowing_resin"]       = { Kind = "trophy", Nature = "vital",  Potency = 2, Script = "scripts/items/misc/glowing_resin_item" },
		["misc.witch_hair"]          = { Kind = "trophy", Nature = "spirit", Potency = 3, Script = "scripts/items/misc/witch_hair_item" },
		["misc.parched_skin"]        = { Kind = "trophy", Nature = "yin",    Potency = 2, Script = "scripts/items/misc/parched_skin_item" },
		["misc.shimmering_ashes"]    = { Kind = "trophy", Nature = "spirit", Potency = 2, Script = "scripts/items/misc/vampire_dust_item" },
		["misc.petrified_scream"]    = { Kind = "trophy", Nature = "spirit", Potency = 3, Script = "scripts/items/misc/petrified_scream_item" },
		["misc.third_eye"]           = { Kind = "trophy", Nature = "spirit", Potency = 3, Script = "scripts/items/misc/third_eye_item" },
		["misc.wx_mat_chiling"]      = { Kind = "trophy", Nature = "yang",   Potency = 3, Script = "scripts/items/misc/wx_mat_chiling" },
		["misc.wx_mat_xuanlin"]      = { Kind = "trophy", Nature = "yin",    Potency = 3, Script = "scripts/items/misc/wx_mat_xuanlin" },
		["misc.wx_mat_xiongjiao"]    = { Kind = "trophy", Nature = "yang",   Potency = 3, Script = "scripts/items/misc/wx_mat_xiongjiao" },
		["misc.wx_mat_shagu"]        = { Kind = "trophy", Nature = "vital",  Potency = 3, Script = "scripts/items/misc/wx_mat_shagu" },
		["misc.wx_mat_renjin"]       = { Kind = "trophy", Nature = "vital",  Potency = 3, Script = "scripts/items/misc/wx_mat_renjin" },
		["misc.wx_mat_gujing"]       = { Kind = "trophy", Nature = "venom",  Potency = 3, Script = "scripts/items/misc/wx_mat_gujing" }
	},

	// 50 Bagua Cauldron Formulas (八卦丹炉君臣五十总谱 —— 1 丹 1 方全覆盖全部 50 种灵丹！)
	Formulas = [
		// --- Category: heal (疗伤续脉 · 9 方) ---
		{
			ID = "f_jinchuang", Category = "heal", PillID = "wx_pill_jinchuang", BaseYield = 2,
			JunNatures = ["vital", "yang"], MinJunPotency = 1, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 2, SilverCost = 80,
			FormulaNote = "江湖基础外伤良方：寻常兽皮兽骨或生机药草即可入鼎，一炉成散 2 份，立解临时外伤。"
		},
		{
			ID = "f_huoluo", Category = "heal", PillID = "wx_pill_huoluo", BaseYield = 1,
			JunNatures = ["vital", "yang"], MinJunPotency = 1, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 3, SilverCost = 120,
			FormulaNote = "以生机灵草（荀草/祝余）或猛兽血骨为君，一次解 2 处外伤并回 35 气血。"
		},
		{
			ID = "f_longxue", Category = "heal", PillID = "wx_pill_longxue", BaseYield = 1,
			JunNatures = ["yang", "vital"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 6, SilverCost = 320,
			FormulaNote = "以千年血竭晶或纯阳血核为君，拔除全部临时外伤并恢复 65 点气血！"
		},
		{
			ID = "f_huxin", Category = "heal", PillID = "wx_pill_huxin", BaseYield = 1,
			JunNatures = ["vital", "spirit", "yin"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 4, SilverCost = 140,
			FormulaNote = "取萆荔血藤或温润灵脂为君，平复散功虚弱、内伤与经脉震荡。"
		},
		{
			ID = "f_bingxin", Category = "heal", PillID = "wx_pill_bingxin", BaseYield = 1,
			JunNatures = ["yin"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 7, SilverCost = 380,
			FormulaNote = "采天山雪莲、冰魄草或玄水妖丹凝炼，清尽内患且令下战免毒免夜盲！"
		},
		{
			ID = "f_wangchen", Category = "heal", PillID = "wx_pill_wangchen", BaseYield = 1,
			JunNatures = ["spirit", "yin", "origin"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 4, SilverCost = 180,
			FormulaNote = "采镇魂清阴灵物入鼎，凝结归元护脉，令下一次换装武学 0 天调息！"
		},
		{
			ID = "f_shennong", Category = "heal", PillID = "wx_pill_shennong", BaseYield = 1,
			JunNatures = ["vital", "origin"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 9, SilverCost = 780,
			FormulaNote = "神农汇百草：以高阶生机/造化奇草或瑞兽内丹合炼，内外创伤一扫而空、气血盈满！"
		},
		{
			ID = "f_shengsheng", Category = "heal", PillID = "wx_pill_shengsheng", BaseYield = 1,
			JunNatures = ["vital", "origin"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 9, SilverCost = 1100, BonusByproduct = "wx_pill_huxin",
			FormulaNote = "逆天续脉：须以高阶【生机/造化】仙草、神木灵心或大妖内丹为君，彻底拔除永久经脉暗疾！"
		},
		{
			ID = "f_duanxu", Category = "heal", PillID = "wx_pill_duanxu", BaseYield = 1,
			JunNatures = ["venom", "vital", "origin"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 9, SilverCost = 1300, BonusByproduct = "wx_pill_huoluo",
			FormulaNote = "西域秘传：以霸道【奇毒/生机/造化】仙草或大妖内丹催发断骨重生，根除瞎眼、断指等原版永久伤残！"
		},

		// --- Category: prep (备战对策与流派机制 · 32 方) ---
		{
			ID = "f_qingxin", Category = "prep", PillID = "wx_pill_qingxin", BaseYield = 2,
			JunNatures = ["venom", "yin", "vital"], MinJunPotency = 1, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 3, SilverCost = 130,
			FormulaNote = "以毒攻毒或取清寒药草入炉，一炉成丹 2 枚，战前服之百毒不侵。"
		},
		{
			ID = "f_hugu", Category = "prep", PillID = "wx_pill_hugu", BaseYield = 1,
			JunNatures = ["yang", "vital"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 4, SilverCost = 150,
			FormulaNote = "取猛兽煞骨巨齿浸烈酒入鼎，补满受损气血并令下战 +12 内息、+2 回气。"
		},
		{
			ID = "f_dingshen", Category = "prep", PillID = "wx_pill_dingshen", BaseYield = 1,
			JunNatures = ["spirit", "yin"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 4, SilverCost = 140,
			FormulaNote = "取镇魂髓珠、迷榖枝或灵灰合炼，下战 +10 定力且免除夜战视野惩罚。"
		},
		{
			ID = "f_zhuyu", Category = "prep", PillID = "wx_pill_zhuyu", BaseYield = 1,
			JunNatures = ["vital"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 5, SilverCost = 240,
			FormulaNote = "以招摇祝余仙草或生机奇珍主炼，补满气血并令下战 +16 内息、+3 回气。"
		},
		{
			ID = "f_duheng", Category = "prep", PillID = "wx_pill_duheng", BaseYield = 1,
			JunNatures = ["yang", "spirit"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 5, SilverCost = 240,
			FormulaNote = "以天帝杜衡走马草或风雷妖丹秘炼，下战 +18 身法、+5 远防。"
		},
		{
			ID = "f_dixiu", Category = "prep", PillID = "wx_pill_dixiu", BaseYield = 1,
			JunNatures = ["spirit"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 5, SilverCost = 280,
			FormulaNote = "以少室帝休黄华枝或镇魂妖丹主炼，下战 +14 定力且免疫击晕！"
		},
		{
			ID = "f_guiyuan", Category = "prep", PillID = "wx_pill_guiyuan", BaseYield = 1,
			JunNatures = ["vital", "origin"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 6, SilverCost = 260,
			FormulaNote = "以云梦千年首乌配异兽骨髓，补血 40 点并令下战 +18 气血上限、+2 回气。"
		},
		{
			ID = "f_baishe", Category = "prep", PillID = "wx_pill_baishe", BaseYield = 1,
			JunNatures = ["venom"], MinJunPotency = 3, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 5, SilverCost = 270,
			FormulaNote = "以嘉荣碧草或毒妖内丹/毒血以毒攻毒，下战免毒且双防各 +4。"
		},
		{
			ID = "f_jinzun", Category = "prep", PillID = "wx_pill_jinzun", BaseYield = 1,
			JunNatures = ["spirit", "vital", "yang"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 6, SilverCost = 320,
			FormulaNote = "以敖岸植楮叶或硬功兽王内丹合炼，下战气血护甲减伤 12% 且免击退。"
		},
		{
			ID = "f_bihuo", Category = "prep", PillID = "wx_pill_bihuo", BaseYield = 1,
			JunNatures = ["yin"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 4, SilverCost = 160,
			FormulaNote = "专取【玄阴】寒草、蛇鳞或水妖内丹凝丸，彻底抵御肥遗、毕方、鹓鶵灼甲毒火瘴！"
		},
		{
			ID = "f_yuji", Category = "prep", PillID = "wx_pill_yuji", BaseYield = 1,
			JunNatures = ["vital", "yin"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 4, SilverCost = 150,
			FormulaNote = "取【生机】奇草或灵脂厚革炼散，全程免疫流血割裂，讨伐穷奇、陆吾必备。"
		},
		{
			ID = "f_longhu", Category = "prep", PillID = "wx_pill_longhu", BaseYield = 1,
			JunNatures = ["yang", "spirit"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 4, SilverCost = 160,
			FormulaNote = "合【赤阳/镇魂】筋骨灵药提纵身法 +15、避暗 +5，免除巨猿震退与巴蛇缠拽。"
		},
		{
			ID = "f_fengmo", Category = "prep", PillID = "wx_pill_fengmo", BaseYield = 1,
			JunNatures = ["yang", "venom"], MinJunPotency = 3, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 6, SilverCost = 260,
			FormulaNote = "以凶戾【赤阳/奇毒】妖丹或猛毒血核猛火催炼，极致破甲取首（战后留 2 日轻内伤）。"
		},
		{
			ID = "f_juling", Category = "prep", PillID = "wx_pill_juling", BaseYield = 1,
			JunNatures = ["vital", "yang"], PreferredAuxNatures = ["yang", "vital"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 4, SilverCost = 170,
			FormulaNote = "以战神煞骨或巨猿重骨配赤阳辅药，返还 22% 重甲负重内息并减免破甲损耗。"
		},
		{
			ID = "f_tiee", Category = "prep", PillID = "wx_pill_tiee", BaseYield = 1,
			JunNatures = ["vital", "yin"], PreferredAuxNatures = ["yang", "vital"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 5, SilverCost = 180,
			FormulaNote = "以玄鳞重革熬制护顶硬膏，令下战凝成【铜头铁额】免疫头部额外暴击并护持头盔。"
		},
		{
			ID = "f_jiugong", Category = "prep", PillID = "wx_pill_jiugong", BaseYield = 1,
			JunNatures = ["spirit", "vital"], PreferredAuxNatures = ["spirit"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 6, SilverCost = 280,
			FormulaNote = "取镇魂仙枝或山海奇丹按九宫炼丸，免除合围近防折损且借机拦击命中 +10。"
		},
		{
			ID = "f_jingji", Category = "prep", PillID = "wx_pill_jingji", BaseYield = 1,
			JunNatures = ["yang", "origin"], PreferredAuxNatures = ["yang", "venom"], MinJunPotency = 3, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 6, SilverCost = 280,
			FormulaNote = "取太古凶角、龙鳞与阳刚妖丹炼散，受近战攻击时反削敌甲 8 点并震散敌方 4 点内息。"
		},
		{
			ID = "f_zuixian", Category = "prep", PillID = "wx_pill_zuixian", BaseYield = 1,
			JunNatures = ["yang", "spirit"], PreferredAuxNatures = ["vital"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 5, SilverCost = 210,
			FormulaNote = "以赤阳奇草配百花灵果封坛酿酒，下战定力 +15、招架 +6、近战总伤 +10%（射艺与视野略减）。"
		},
		{
			ID = "f_xiantian", Category = "prep", PillID = "wx_pill_xiantian", BaseYield = 1,
			JunNatures = ["yin", "origin"], PreferredAuxNatures = ["yin", "spirit"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 6, SilverCost = 320,
			FormulaNote = "采冰魄雪莲或玄水瑞兽内丹凝炼，张开【先天真气护体】以 1:2 内息化消至多 25% 气血实伤。"
		},
		{
			ID = "f_lingfeng", Category = "prep", PillID = "wx_pill_lingfeng", BaseYield = 1,
			JunNatures = ["yin", "spirit"], PreferredAuxNatures = ["yang"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 6, SilverCost = 300,
			FormulaNote = "合寒髓灵草与妖禽风翎萃露，下战全地形行气减半、越障免额外 AP 且首轮身法 +15。"
		},
		{
			ID = "f_gufeng", Category = "prep", PillID = "wx_pill_gufeng", BaseYield = 1,
			JunNatures = ["yang", "origin"], PreferredAuxNatures = ["spirit"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 6, SilverCost = 310,
			FormulaNote = "以纯阳血晶或金铁妖丹主炼，单手空副手（或成对拳套）额外穿甲 +12% 且对完好重甲破甲 +15%。"
		},
		{
			ID = "f_kongque", Category = "prep", PillID = "wx_pill_kongque", BaseYield = 1,
			JunNatures = ["venom"], PreferredAuxNatures = ["venom", "yin"], MinJunPotency = 3, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 6, SilverCost = 290,
			FormulaNote = "集南疆毒晶、毒腺与奇毒妖丹熬膏，伤血 55% 概率注入奇毒且对中毒目标命中 +6。"
		},
		{
			ID = "f_fugu", Category = "prep", PillID = "wx_pill_fugu", BaseYield = 1,
			JunNatures = ["venom", "yang"], PreferredAuxNatures = ["venom"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 5, SilverCost = 250,
			FormulaNote = "以毒蛟酸血或蚀骨毒晶入炉，攻击命中额外腐蚀敌方 10 点身甲与 6 点盾牌耐久。"
		},
		{
			ID = "f_suoxue", Category = "prep", PillID = "wx_pill_suoxue", BaseYield = 1,
			JunNatures = ["yin", "venom"], PreferredAuxNatures = ["spirit", "yin"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 6, SilverCost = 310,
			FormulaNote = "采寒玉奇草配通幽药引，攻击 35% 概率震露【破绽】，击头或乘隙另有 30% 概率触发【点穴封气】。"
		},
		{
			ID = "f_shixue", Category = "prep", PillID = "wx_pill_shixue", BaseYield = 1,
			JunNatures = ["yang", "venom"], PreferredAuxNatures = ["vital", "yang"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 7, SilverCost = 320,
			FormulaNote = "以凶兽血核或煞丹猛火炼丸，对残血目标总伤 +12%，斩杀活物立回 10 血 5 气！"
		},
		{
			ID = "f_yingyan", Category = "prep", PillID = "wx_pill_yingyan", BaseYield = 1,
			JunNatures = ["spirit", "yang"], PreferredAuxNatures = ["spirit"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 4, SilverCost = 170,
			FormulaNote = "以妖禽赤翎或三目灵珠萃露，下战视野 +1、免夜盲，远距射击命中 +6 且削减目标轻功避暗。"
		},
		{
			ID = "f_pili", Category = "prep", PillID = "wx_pill_pili", BaseYield = 1,
			JunNatures = ["yang"], PreferredAuxNatures = ["yang", "venom"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 4, SilverCost = 180,
			FormulaNote = "以纯阳火材配凶兽骨角研引，远程火铳强弩或重击 40% 概率震敌【失衡】，且碎盾 +8。"
		},
		{
			ID = "f_chunyang", Category = "prep", PillID = "wx_pill_chunyang", BaseYield = 1,
			JunNatures = ["yang", "spirit"], PreferredAuxNatures = ["yang", "spirit"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 6, SilverCost = 310,
			FormulaNote = "取赤火灵芝或纯阳神禽内丹九炼，专克古墓机关与湘西尸傀（诛邪总伤 +18%、焚甲 +8、抗惊骇 +15）！"
		},
		{
			ID = "f_hufu", Category = "prep", PillID = "wx_pill_hufu", BaseYield = 1,
			JunNatures = ["spirit", "vital"], PreferredAuxNatures = ["yang", "vital"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 4, SilverCost = 160,
			FormulaNote = "合镇魂灵木与壮骨兽材成丸，下战必以【战意高昂】入阵，且邻接 ≥2 同袍时双防 +4、定力 +8。"
		},
		{
			ID = "f_baoming", Category = "prep", PillID = "wx_pill_baoming", BaseYield = 1,
			JunNatures = ["vital", "origin"], PreferredAuxNatures = ["vital", "origin"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 8, SilverCost = 620,
			FormulaNote = "杏林夺命丹方：以高阶【生机/造化】仙草或瑞兽内丹合炼，赋予下战 1 次致命锁血不死并急回血气！"
		},
		{
			ID = "f_zhenmo", Category = "prep", PillID = "wx_pill_zhenmo", BaseYield = 1,
			JunNatures = ["spirit", "yin"], PreferredAuxNatures = ["spirit"], MinJunPotency = 3, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 5, SilverCost = 260,
			FormulaNote = "取清心镇魂灵草或寒晶入鼎，下战彻底镇压内功相克与残本散气反噬，且落空自动叠 +6 命中！"
		},
		{
			ID = "f_tihu", Category = "prep", PillID = "wx_pill_tihu", BaseYield = 1,
			JunNatures = ["origin", "spirit"], PreferredAuxNatures = ["origin", "spirit"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 8, SilverCost = 600,
			FormulaNote = "以紫金灵芝或通玄瑞兽内丹合炼，令下战人物经验 +35% 且战后武学参战火候暴涨 +50%！"
		},

		// --- Category: cultivate (修为洗髓 · 9 方) ---
		{
			ID = "f_ningshen", Category = "cultivate", PillID = "wx_pill_ningshen", BaseYield = 2,
			JunNatures = ["spirit", "vital", "yin"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 4, SilverCost = 220,
			FormulaNote = "以镇魂髓珠或奇草凝丸，一炉双丹（2× 凝神丸），快速贯通前中期功法火候。"
		},
		{
			ID = "f_jiuhua", Category = "cultivate", PillID = "wx_pill_jiuhua", BaseYield = 1,
			JunNatures = ["vital", "spirit"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 5, SilverCost = 340,
			FormulaNote = "采奇花灵草（迷榖/荀草/鬼草）精制九花玉露丸（+230 火候并回 30 气血）。"
		},
		{
			ID = "f_dahuan", Category = "cultivate", PillID = "wx_pill_dahuan", BaseYield = 1,
			JunNatures = ["origin", "vital", "yang", "yin", "spirit"], MinJunPotency = 3, RequireRareJun = true, MinAuxCount = 1, TargetPotency = 6, SilverCost = 460,
			FormulaNote = "取上乘奇草或任意山海内丹为主引，炼成宗门九转大还丹（+320 火候并解散功虚弱）。"
		},
		{
			ID = "f_zijin_exp", Category = "cultivate", PillID = "wx_pill_zijin", BaseYield = 1,
			JunNatures = ["origin", "spirit"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 9, SilverCost = 880,
			FormulaNote = "以九叶紫芝或大妖内丹合炼太虚紫金大丹（+480 火候并涤尽散功与内伤）！"
		},
		{
			ID = "f_humai", Category = "cultivate", PillID = "wx_pill_humai", BaseYield = 1,
			JunNatures = ["vital", "yin", "venom"], MinJunPotency = 2, RequireRareJun = false, MinAuxCount = 1, TargetPotency = 5, SilverCost = 420, BonusByproduct = "wx_pill_huxin",
			FormulaNote = "柔韧护经奇材佐毒腺灵草，炼就洗髓必备护脉宝丹（+5% 胜算并免留永久暗疾）。"
		},
		{
			ID = "f_zaohua_humai", Category = "cultivate", PillID = "wx_pill_zaohua", BaseYield = 1,
			JunNatures = ["origin", "vital"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 9, SilverCost = 920,
			FormulaNote = "融昆仑沙棠金果或瑞兽内丹炼制至尊护脉金丹（洗髓 +9% 胜算且失败零震荡）！"
		},
		{
			ID = "f_yijin", Category = "cultivate", PillID = "wx_pill_yijin_wan", BaseYield = 1,
			JunNatures = ["yang", "vital", "origin"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 8, SilverCost = 900,
			FormulaNote = "以阳刚/生机奇草或大妖内丹锻骨易筋，专为 0★ 属性开星/易筋换星额外 +20% 胜算！"
		},
		{
			ID = "f_xisui", Category = "cultivate", PillID = "wx_pill_xisui", BaseYield = 1,
			JunNatures = ["origin", "yang", "vital"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 9, SilverCost = 1450, BonusByproduct = "wx_pill_huxin",
			FormulaNote = "无需拘泥单一血芝——凡高阶【造化/赤阳/生机】奇草或山海大妖内丹配齐辅药，皆可开炉炼制洗髓丹！"
		},
		{
			ID = "f_zijin_xisui", Category = "cultivate", PillID = "wx_pill_zijin_xisui", BaseYield = 1,
			JunNatures = ["origin"], MinJunPotency = 5, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 12, SilverCost = 2400, BonusByproduct = "wx_pill_humai",
			FormulaNote = "丹道极境：须以太古顶阶【造化】大妖内丹或九叶紫金灵芝为君，辅以两味重宝，九转炼成天品紫金洗髓丹！"
		}
	]
};
