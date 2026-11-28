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
	},
	// ==================== Track I: 阴阳逆命隐藏奇丹 & 山海大妖本命秘传古丹 ====================
	wx_pill_liangyi = {
		ID          = "wx_pill_liangyi",
		Name        = "两仪逆命混元丹",
		SubLabel    = "阴阳逆炼",
		Quality     = "unique",
		Description = "【阴阳逆命奇丹】以山海大妖内丹镇压鼎心、引武火强行逆炼赤阳与玄阴相克而成的旷世混元宝丹！令下场战斗彻底化消「双内功阴阳逆冲」并转为【混元共振】：攻击破甲 +12%、每轮回气 +3，且催化主修内功（阳刚近战额外灼甲 +6 / 阴柔受近战反凝寒霜散敌 5 内息）！",
		Kind        = "buff_liangyi",
		Icon        = "consumables/wx_pill_xiantian.png",
		Value       = 2400
	},
	wx_pill_zhuyin = {
		ID          = "wx_pill_zhuyin",
		Name        = "烛阴昼夜轮转丹",
		SubLabel    = "古神本命",
		Quality     = "unique",
		Description = "【钟山烛阴本命古丹】唯以《钟山烛阴昼夜龙珠》为君药方能合炼：令下场战斗随单双回合催化内外武学——奇数轮【瞑夜寒冬】近远双防 +5、每轮回气 +4；偶数轮【开目赤昼】攻击总伤 +10%、近战命中灼毁目标 10 点护甲（战后消散）！",
		Kind        = "buff_zhuyin",
		Icon        = "consumables/wx_pill_zijin.png",
		Value       = 2650
	},
	wx_pill_kurong = {
		ID          = "wx_pill_kurong",
		Name        = "枯荣生死涅槃丸",
		SubLabel    = "阴阳逆炼",
		Quality     = "unique",
		Description = "【阴阳逆命奇丹】以山海内丹镇鼎、武火逆炼生机与奇毒两极冲克而成：令下场战斗自身身负流血或中毒时反激潜能（近远双防 +4、每轮回气 +4），且气血首次跌破 35% 时触发【枯荣涅槃】涤尽流血奇毒并急回 22 点气血（战后消散）！",
		Kind        = "buff_kurong",
		Icon        = "consumables/wx_pill_shengsheng.png",
		Value       = 2450
	},
	wx_pill_shenmo = {
		ID          = "wx_pill_shenmo",
		Name        = "神魔一念辟邪丹",
		SubLabel    = "阴阳逆炼",
		Quality     = "unique",
		Description = "【阴阳逆命奇丹】以山海内丹镇鼎、武火逆炼镇魂与奇毒相激而成：令下场战斗镇压邪派内功与残本散气反噬，攻击动摇/崩溃/魅惑目标命中 +8，斩敌额外回气 +6（每轮限 2 次，战后消散）！",
		Kind        = "buff_shenmo",
		Icon        = "consumables/wx_pill_zhenmo.png",
		Value       = 2420
	},
	wx_pill_baize = {
		ID          = "wx_pill_baize",
		Name        = "白泽通玄勘破丹",
		SubLabel    = "古神本命",
		Quality     = "unique",
		Description = "【东望白泽本命古丹】唯以《东望白泽通玄宝丹》为君药合炼：催化奇门与剑宗武学——下场战斗每轮首次借机拦击或反击命中 +12 且必破开【破绽】，战后全身武学参战火候额外 +25%（战后消散）！",
		Kind        = "buff_baize",
		Icon        = "consumables/wx_pill_tihu.png",
		Value       = 2580
	},
	wx_pill_jianmu = {
		ID          = "wx_pill_jianmu",
		Name        = "建木枯木逢春丹",
		SubLabel    = "古神本命",
		Quality     = "unique",
		Description = "【都广建木本命古丹】唯以《都广建木神心》为君药合炼：催化横练硬功脉——下场战斗每回合初自愈 +6 气血并修复 +6 点身甲（若装配横练功法则额外多修 +4 身甲，战后消散）！",
		Kind        = "buff_jianmu",
		Icon        = "consumables/wx_pill_zaohua.png",
		Value       = 2600
	},
	wx_pill_taotie = {
		ID          = "wx_pill_taotie",
		Name        = "饕餮吞元化气丸",
		SubLabel    = "古神本命",
		Quality     = "unique",
		Description = "【饕餮凶神本命古丹】唯以《饕餮噬元凶丹》为君药合炼：催化刚猛外功与邪功脉——下场战斗近战重创活物（伤血≥12）时鲸吞敌方 5 点内息化归己用（每轮限 2 次，战后消散）！",
		Kind        = "buff_taotie",
		Icon        = "consumables/wx_pill_shixue.png",
		Value       = 2550
	},
	wx_pill_yinglong = {
		ID          = "wx_pill_yinglong",
		Name        = "应龙行云御雷丹",
		SubLabel    = "古神本命",
		Quality     = "unique",
		Description = "【凶犁应龙本命古丹】唯以《凶犁应龙真灵逆鳞珠》为君药合炼：催化轻功与枪剑长兵脉——下场战斗移动行气消耗降低 35%，且施展【穿步】或【贯线刺】招式命中时返还 +3 内息（每轮限 2 次，战后消散）！",
		Kind        = "buff_yinglong",
		Icon        = "consumables/wx_pill_lingfeng.png",
		Value       = 2620
	},
	wx_pill_chiyou = {
		ID          = "wx_pill_chiyou",
		Name        = "蚩尤兵主百战丹",
		SubLabel    = "古神本命",
		Quality     = "unique",
		Description = "【万古兵主本命古丹】唯以《冀州蚩尤五兵煞主丹》为君药合炼：催化刚猛外功与重兵脉——下场战斗破甲效能 +15%、碎盾 +10，斩敌立回 +5 内息并震慑相邻敌军检定 -8 定力（战后消散）！",
		Kind        = "buff_chiyou",
		Icon        = "consumables/wx_pill_fengmo.png",
		Value       = 2650
	},
	wx_pill_jinwu = {
		ID          = "wx_pill_jinwu",
		Name        = "金乌十日纯阳丹",
		SubLabel    = "古神本命",
		Quality     = "unique",
		Description = "【汤谷金乌本命古丹】唯以《汤谷三足金乌大日真丹》为君药合炼：催化阳刚内功脉——下场战斗每轮自涤寒霜迟缓，近战命中真火灼毁目标 10 点身甲，迎战尸傀机关总伤 +16%（战后消散）！",
		Kind        = "buff_jinwu",
		Icon        = "consumables/wx_pill_chunyang.png",
		Value       = 2640
	},
	wx_pill_xiangliu = {
		ID          = "wx_pill_xiangliu",
		Name        = "相柳九首万蛊丹",
		SubLabel    = "古神本命",
		Quality     = "unique",
		Description = "【共工相柳本命古丹】唯以《共工相柳九首苦毒丹》为君药合炼：催化五毒邪功脉——下场战斗百毒不侵，攻击 55% 注入奇毒，击中已中毒目标时毒雾传染相邻 1 名敌军（战后消散）！",
		Kind        = "buff_xiangliu",
		Icon        = "consumables/wx_pill_kongque.png",
		Value       = 2620
	},
	wx_pill_xuangui = {
		ID          = "wx_pill_xuangui",
		Name        = "玄龟镇海不坏丹",
		SubLabel    = "古神本命",
		Quality     = "unique",
		Description = "【杻阳玄龟本命古丹】唯以《杻阳玄龟镇海神丹》为君药合炼：催化横练守阵脉——下场战斗远伤 -18%、免疫击退震晕，每轮首次受重击额外减免 12% 气血实伤（严守 60% 上限，战后消散）！",
		Kind        = "buff_xuangui",
		Icon        = "consumables/wx_pill_jinzun.png",
		Value       = 2600
	},
	wx_pill_dijiang = {
		ID          = "wx_pill_dijiang",
		Name        = "帝江幻空缩地丹",
		SubLabel    = "古神本命",
		Quality     = "unique",
		Description = "【天山帝江本命古丹】唯以《天山帝江空间混沌丹》为君药合炼：催化轻功游剑脉——下场战斗身法 +16，每轮首次受远程或重击触发幻空折跃偏折 22% 气血实伤（严守 60% 上限，战后消散）！",
		Kind        = "buff_dijiang",
		Icon        = "consumables/wx_pill_duheng.png",
		Value       = 2620
	},
	wx_pill_jiuwei = {
		ID          = "wx_pill_jiuwei",
		Name        = "九尾青丘摄魂丹",
		SubLabel    = "古神本命",
		Quality     = "unique",
		Description = "【青丘九尾本命古丹】唯以《青丘九尾天狐幻丹》为君药合炼：催化奇门精神脉——下场战斗定力 +14、免疫魅惑梦魇，攻击伤血时迫使敌手执行 -10 定力动摇检定（战后消散）！",
		Kind        = "buff_jiuwei",
		Icon        = "consumables/wx_pill_dingshen.png",
		Value       = 2580
	},
	wx_pill_xingtian = {
		ID          = "wx_pill_xingtian",
		Name        = "刑天常羊战魂丹",
		SubLabel    = "古神本命",
		Quality     = "unique",
		Description = "【常羊刑天本命古丹】唯以《常羊刑天不灭战魂丹》为君药合炼：催化狂战斧盾脉——下场战斗免疫击晕，气血低于 60% 时激发无首战魂令总伤 +14%、每轮回气 +4（战后消散）！",
		Kind        = "buff_xingtian",
		Icon        = "consumables/wx_pill_baoming.png",
		Value       = 2640
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

	// Six Auxiliary Herb/Core Nature Side-Effects (`【药引丹韵 · 四脉武学催化】` imbued by Cauldron臣佐辅药!)
	AuxInfusions = {
		vital = {
			ID = "vital", Title = "生机丹韵", Color = "#5ec47a", TooltipColor = "#0a4213", Bit = 1,
			PrepDesc   = "服药立回 15 气血，下战每轮初自愈 +3 气血（装配横练功法额外修甲 +4）",
			InfuseDesc = "灌注【横练硬功】插槽触发木元共鸣，额外 +15% 火候",
			HealDesc   = "草木生机加持，服敷时额外多恢复 +20 受损气血"
		},
		yang = {
			ID = "yang", Title = "赤阳丹韵", Color = "#e87a42", TooltipColor = "#6c1f04", Bit = 2,
			PrepDesc   = "纯阳催劲，下战破甲效能 +8%（主修阳刚内功近战额外灼损目标 5 点身甲）",
			InfuseDesc = "灌注【阳刚内功 / 外功套路】触发火元共鸣，额外 +15% 火候",
			HealDesc   = "纯阳活血通络，服敷时额外恢复 +15 气血"
		},
		yin = {
			ID = "yin", Title = "玄阴丹韵", Color = "#6db4e8", TooltipColor = "#0e3969", Bit = 4,
			PrepDesc   = "寒髓润脉，下战每轮回气 +2（主修阴柔内功受近战反凝寒气震散来敌 4 内息）",
			InfuseDesc = "灌注【阴柔内功 / 轻功身法】触发水元共鸣，额外 +15% 火候",
			HealDesc   = "清寒涤脉，额外消减 1 日内伤或散功调息天数"
		},
		spirit = {
			ID = "spirit", Title = "镇魂丹韵", Color = "#b58ae6", TooltipColor = "#4b1c76", Bit = 8,
			PrepDesc   = "灵台澄明，下战定力 +6、抗惊骇 +8，且攻击落空自动凝神补下次命中 +5",
			InfuseDesc = "灌注【中正内功 / 奇门杂学】触发识海共鸣，额外 +15% 火候",
			HealDesc   = "宁心定魄，服敷时额外恢复 +15 气血"
		},
		venom = {
			ID = "venom", Title = "奇毒丹韵", Color = "#95c44b", TooltipColor = "#2d3f06", Bit = 16,
			PrepDesc   = "以毒淬劲，下战伤血 ≥5 时 25% 附【暗器奇毒】，攻击已中毒猎物破甲 +10%",
			InfuseDesc = "灌注【邪派内功 / 奇门杂学】触发蛊元共鸣，额外 +15% 火候",
			HealDesc   = "以毒攻毒催发淤血，外伤膏散可额外多解 1 处外伤"
		},
		origin = {
			ID = "origin", Title = "造化丹韵", Color = "#f0bc42", TooltipColor = "#5e2c00", Bit = 32,
			PrepDesc   = "混元护体，下战临时气血 +8、内息 +6，且战后武学参战火候额外 +15%",
			InfuseDesc = "灌注任意【绝学 / 江湖孤本】触发造化共鸣，额外 +15% 火候",
			HealDesc   = "夺天地造化，服敷时额外恢复 +30 受损气血"
		}
	},

	// 12 Archetypes + Full 64-Boss (96-Core) Bespoke Inner-Core Imprints (`【本命妖丹丹韵】`: every Boss Neidan used as 君药 imprints unique soul power!)
	CoreImprintModes = {
		feral_might  = { Color = "#e87a42", TooltipColor = "#6c1f04", PrepDesc = "近战重击额外崩损目标 6 点身甲，并对蓄力凶兽注入 +1 破招值" },
		solar_scorch = { Color = "#ff9642", TooltipColor = "#6c1f04", PrepDesc = "催动纯阳真火：近战灼损 6 点身甲，迎战尸傀机关总伤 +8%" },
		abyssal_frost= { Color = "#6db4e8", TooltipColor = "#0e3969", PrepDesc = "寒渊凝髓：每轮额外回气 +2，受近战反凝寒霜削减来敌先攻" },
		bitter_venom = { Color = "#95c44b", TooltipColor = "#2d3f06", PrepDesc = "源毒蚀脉：伤血 ≥4 时 30% 附【暗器奇毒】，对中毒目标近远命中 +4" },
		thunder_shock= { Color = "#c896ff", TooltipColor = "#4b1c76", PrepDesc = "雷音贯腑：近战重击额外震散敌手 5 点内息" },
		gale_stride  = { Color = "#7ee29a", TooltipColor = "#0a4213", PrepDesc = "裂空御风：常驻身法 +8，开场首轮额外再 +6 身法" },
		bastion_shell= { Color = "#d7b174", TooltipColor = "#533200", PrepDesc = "古甲镇脉：承受破甲损耗 -10%，定力 +6" },
		sacred_wood  = { Color = "#5ec47a", TooltipColor = "#0a4213", PrepDesc = "神木生机：每回合初温养自愈 +3 气血并修复 +4 身甲" },
		oracle_sight = { Color = "#b58ae6", TooltipColor = "#4b1c76", PrepDesc = "通玄破妄：夜雾烟幕命中 +5，战后全身武学参战火候额外 +15%" },
		war_spirit   = { Color = "#ff7864", TooltipColor = "#721010", PrepDesc = "不灭战魂：气血低于 60% 时总伤 +8%、定力 +8" },
		devour_qi    = { Color = "#e06666", TooltipColor = "#721010", PrepDesc = "噬元化气：近战重创或斩杀活物时汲回 +3 内息（每轮限 2 次）" },
		sonic_rattle = { Color = "#f0bc42", TooltipColor = "#5e2c00", PrepDesc = "古磬摄魄：攻击伤血 ≥8 时迫使敌手执行 -6 定力检定并散气 3 点" }
	},

	CoreImprints = {
		// === 全 64 尊山海秘境大妖内丹一对一本命丹韵（拒绝沦为普通药力白板！） ===
		wx_core_zhuyan      = { Title = "朱厌狂猿本命韵", Mode = "feral_might" },
		wx_core_feiyi       = { Title = "肥遗六足毒火韵", Mode = "bitter_venom" },
		wx_core_qiongqi     = { Title = "穷奇裂风助恶韵", Mode = "gale_stride" },
		wx_core_taotie      = { Title = "饕餮吞天噬元韵", Mode = "devour_qi" },
		wx_core_jiuwei      = { Title = "青丘九尾摄魂韵", Mode = "oracle_sight" },
		wx_core_bashe       = { Title = "苍梧巴蛇吞象韵", Mode = "abyssal_frost" },
		wx_core_jumang      = { Title = "句芒建木长春韵", Mode = "sacred_wood" },
		wx_core_wuzhiqi     = { Title = "淮涡无支祁定水韵", Mode = "abyssal_frost" },
		wx_core_xingtian    = { Title = "常羊刑天干戚韵", Mode = "war_spirit" },
		wx_core_bifang      = { Title = "章莪毕方讹火韵", Mode = "solar_scorch" },
		wx_core_gudiaowang  = { Title = "鹿吴蛊雕裂创韵", Mode = "feral_might" },
		wx_core_xingxing    = { Title = "招摇狌狌知往韵", Mode = "oracle_sight" },
		wx_core_zhujian     = { Title = "北岳诸犍狂飙韵", Mode = "gale_stride" },
		wx_core_xuangui     = { Title = "杻阳玄龟镇海韵", Mode = "bastion_shell" },
		wx_core_yuanchu     = { Title = "南海鹓鶵丹凤韵", Mode = "solar_scorch" },
		wx_core_yingzhao    = { Title = "昆仑英招巡天韵", Mode = "oracle_sight" },
		wx_core_luwu        = { Title = "昆仑陆吾司天韵", Mode = "thunder_shock" },
		wx_core_qinyuan     = { Title = "昆仑钦原蜇石韵", Mode = "bitter_venom" },
		wx_core_tiangouwang = { Title = "阴山天狗坠星韵", Mode = "gale_stride" },
		wx_core_zheng       = { Title = "章峨赤狰五尾韵", Mode = "feral_might" },
		wx_core_hundun      = { Title = "天山浑沌无窍韵", Mode = "bastion_shell" },
		wx_core_yayu        = { Title = "少咸猰貐逆命韵", Mode = "feral_might" },
		wx_core_zhuyin      = { Title = "钟山烛阴昼夜韵", Mode = "solar_scorch" },
		wx_core_dijiang     = { Title = "天山帝江幻空韵", Mode = "gale_stride" },
		wx_core_paoxiaowang = { Title = "钩吾狍鸮贪食韵", Mode = "devour_qi" },
		wx_core_changyou    = { Title = "尧光长右洪水韵", Mode = "sacred_wood" },
		wx_core_mengji      = { Title = "石者孟极隐猎韵", Mode = "gale_stride" },
		wx_core_kui         = { Title = "流波夔牛紫电韵", Mode = "thunder_shock" },
		wx_core_fei         = { Title = "太山灾兽枯疫韵", Mode = "bitter_venom" },
		wx_core_yinglong    = { Title = "凶犁应龙沧海韵", Mode = "thunder_shock" },
		wx_core_taowu       = { Title = "荒西梼杌傲狠韵", Mode = "feral_might" },
		wx_core_hujiao      = { Title = "祷过虎蛟鸳音韵", Mode = "sonic_rattle" },
		wx_core_zhuhuai     = { Title = "北岳诸怀四角韵", Mode = "war_spirit" },
		wx_core_shebishi    = { Title = "大国奢比尸毒耳韵", Mode = "bitter_venom" },
		wx_core_jingwei     = { Title = "发鸠精卫衔石韵", Mode = "oracle_sight" },
		wx_core_jiuying     = { Title = "凶水九婴水火韵", Mode = "bitter_venom" },
		wx_core_feilian     = { Title = "鹿台飞廉御风韵", Mode = "gale_stride" },
		wx_core_baize       = { Title = "东望白泽通玄韵", Mode = "oracle_sight" },
		wx_core_shanhui     = { Title = "狱法山挥善投韵", Mode = "gale_stride" },
		wx_core_bo          = { Title = "中曲铁驳食虎韵", Mode = "thunder_shock" },
		wx_core_huodou      = { Title = "厌火祸斗吞炎韵", Mode = "solar_scorch" },
		wx_core_xiangliuwang= { Title = "共工相柳九首韵", Mode = "bitter_venom" },
		wx_core_kuafu       = { Title = "成都夸父逐日韵", Mode = "sacred_wood" },
		wx_core_chiyou      = { Title = "冀州蚩尤兵主韵", Mode = "war_spirit" },
		wx_core_zaochi      = { Title = "畴华凿齿破军韵", Mode = "bastion_shell" },
		wx_core_erfu        = { Title = "疏属贰负盘枷韵", Mode = "bastion_shell" },
		wx_core_nvchou      = { Title = "十日女丑赤旱韵", Mode = "solar_scorch" },
		wx_core_fangfeng    = { Title = "会稽防风专车韵", Mode = "bastion_shell" },
		wx_core_kaiming     = { Title = "昆仑开明九首韵", Mode = "thunder_shock" },
		wx_core_jinwu       = { Title = "汤谷金乌十日韵", Mode = "solar_scorch" },
		wx_core_zouyu       = { Title = "林氏驺虞仁虎韵", Mode = "gale_stride" },
		wx_core_gonggong    = { Title = "不周共工黑水韵", Mode = "abyssal_frost" },
		wx_core_wuluo       = { Title = "青要武罗鸣环韵", Mode = "gale_stride" },
		wx_core_siwang      = { Title = "苍梧青兕独角韵", Mode = "bastion_shell" },
		wx_core_jiufeng     = { Title = "北极九凤泣血韵", Mode = "war_spirit" },
		wx_core_mingshe     = { Title = "鲜山鸣蛇磬音韵", Mode = "sonic_rattle" },
		wx_core_huashe      = { Title = "阳山化蛇玄水韵", Mode = "abyssal_frost" },
		wx_core_fuzhu       = { Title = "敖岸夫诸凝霜韵", Mode = "abyssal_frost" },
		wx_core_chenghuang  = { Title = "白民乘黄寿元韵", Mode = "sacred_wood" },
		wx_core_dangkang    = { Title = "钦山当康丰穰韵", Mode = "bastion_shell" },
		wx_core_boshi       = { Title = "基山猼訑背目韵", Mode = "oracle_sight" },
		wx_core_jiao        = { Title = "玉山神狡破甲韵", Mode = "thunder_shock" },
		wx_core_bingyi      = { Title = "从极冰夷御龙韵", Mode = "abyssal_frost" },
		wx_core_qiangliang  = { Title = "北山强良衔蛇韵", Mode = "thunder_shock" },
		// === 32 枚山泽异兽 / 太古四圣内丹丹韵全覆盖 ===
		wx_core_esha        = { Title = "幽谷讹兽幻雾韵", Mode = "oracle_sight" },
		wx_core_chizhu      = { Title = "毒谷赤蛛万丝韵", Mode = "bitter_venom" },
		wx_core_canglang    = { Title = "阴山苍狼啸月韵", Mode = "gale_stride" },
		wx_core_shuiyuan    = { Title = "云梦水猿寒瘴韵", Mode = "abyssal_frost" },
		wx_core_shujing     = { Title = "都广树精盘根韵", Mode = "sacred_wood" },
		wx_core_yaomei      = { Title = "青丘妖魅惑心韵", Mode = "oracle_sight" },
		wx_core_paoxiao     = { Title = "北山狍鸮裂骨韵", Mode = "devour_qi" },
		wx_core_gudiao      = { Title = "西山蛊雕风刃韵", Mode = "feral_might" },
		wx_core_mangshe     = { Title = "苍梧巨蟒蜕骨韵", Mode = "abyssal_frost" },
		wx_core_jianmo      = { Title = "古墓剑魔血影韵", Mode = "war_spirit" },
		wx_core_shiwang     = { Title = "湘西尸王铜骨韵", Mode = "bastion_shell" },
		wx_core_yuanling    = { Title = "荒冢怨灵凝魄韵", Mode = "sonic_rattle" },
		wx_core_zelong      = { Title = "大泽毒触九首韵", Mode = "bitter_venom" },
		wx_core_shenlu      = { Title = "昆仑神鹿幻彩韵", Mode = "sacred_wood" },
		wx_core_yaoren      = { Title = "魔窟药人血髓韵", Mode = "feral_might" },
		wx_core_jiguanyong  = { Title = "玄宫墨家枢机韵", Mode = "bastion_shell" },
		wx_core_qilin       = { Title = "昆仑麒麟祥瑞韵", Mode = "sacred_wood" },
		wx_core_fenghuang   = { Title = "丹穴凤凰涅槃韵", Mode = "solar_scorch" },
		wx_core_xuanwu      = { Title = "北冥玄武龟蛇韵", Mode = "bastion_shell" },
		wx_core_baihu       = { Title = "西极白虎庚金韵", Mode = "feral_might" },
		wx_core_qinglong    = { Title = "东极苍龙岁星韵", Mode = "thunder_shock" },
		wx_core_suanyu      = { Title = "景山酸与惊魂韵", Mode = "sonic_rattle" },
		wx_core_feifei      = { Title = "霍山腓腓忘忧韵", Mode = "oracle_sight" },
		wx_core_tianma      = { Title = "马成天马飞雪韵", Mode = "gale_stride" },
		wx_core_shuhu       = { Title = "崦嵫孰湖翼马韵", Mode = "gale_stride" },
		wx_core_xiezhi      = { Title = "东望獬豸明断韵", Mode = "thunder_shock" },
		wx_core_bixi        = { Title = "沧海赑屃负岳韵", Mode = "bastion_shell" },
		wx_core_jiaolong    = { Title = "洞庭走蛟化龙韵", Mode = "thunder_shock" },
		wx_core_chimi       = { Title = "南荒魑魅古瘴韵", Mode = "bitter_venom" },
		wx_core_guiche      = { Title = "荆楚鬼车滴血韵", Mode = "devour_qi" },
		wx_core_yingyu      = { Title = "东海赢鱼洪涛韵", Mode = "abyssal_frost" },
		wx_core_zhulong     = { Title = "钟山烛龙创世韵", Mode = "solar_scorch" }
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
		["misc.wx_mat_gujing"]       = { Kind = "trophy", Nature = "venom",  Potency = 3, Script = "scripts/items/misc/wx_mat_gujing" },
		["misc.wx_pmat_longni"]      = { Kind = "trophy", Nature = "yin",    Potency = 4, Script = "scripts/items/misc/wx_pmat_longni" },
		["misc.wx_pmat_jiushou"]     = { Kind = "trophy", Nature = "venom",  Potency = 4, Script = "scripts/items/misc/wx_pmat_jiushou" },
		["misc.wx_pmat_xuanjia"]     = { Kind = "trophy", Nature = "vital",  Potency = 4, Script = "scripts/items/misc/wx_pmat_xuanjia" },
		["misc.wx_pmat_jinwu_yu"]    = { Kind = "trophy", Nature = "yang",   Potency = 4, Script = "scripts/items/misc/wx_pmat_jinwu_yu" },
		["misc.wx_pmat_fengyi"]      = { Kind = "trophy", Nature = "spirit", Potency = 4, Script = "scripts/items/misc/wx_pmat_fengyi" },
		["misc.wx_pmat_bingzhu_jiao"]= { Kind = "trophy", Nature = "yang",   Potency = 4, Script = "scripts/items/misc/wx_pmat_bingzhu_jiao" },
		["misc.wx_pmat_leigu"]       = { Kind = "trophy", Nature = "yang",   Potency = 4, Script = "scripts/items/misc/wx_pmat_leigu" },
		["misc.wx_pmat_baize_tong"]  = { Kind = "trophy", Nature = "spirit", Potency = 4, Script = "scripts/items/misc/wx_pmat_baize_tong" },
		["misc.wx_pmat_qinyuan_zhen"]= { Kind = "trophy", Nature = "venom",  Potency = 4, Script = "scripts/items/misc/wx_pmat_qinyuan_zhen" },
		["misc.wx_pmat_taotie_chi"]  = { Kind = "trophy", Nature = "yang",   Potency = 4, Script = "scripts/items/misc/wx_pmat_taotie_chi" },
		["misc.wx_pmat_xingtian_sui"]= { Kind = "trophy", Nature = "origin", Potency = 4, Script = "scripts/items/misc/wx_pmat_xingtian_sui" },
		["misc.wx_pmat_jianmu_zhi"]  = { Kind = "trophy", Nature = "vital",  Potency = 4, Script = "scripts/items/misc/wx_pmat_jianmu_zhi" }
	},

	// Three Furnace Fire Control Modes (`文火温养 / 中火守正 / 武火催霞`)
	FireModes = {
		gentle = {
			ID = "gentle", Title = "文火温养", Short = "文火", Color = "#7ee29a", CostMult = 0.90,
			Grade2Bonus = 8, Grade3Bonus = -4, DoubleBonus = -5, MinPotencyFloor = 98, AllowTribulation = false,
			Desc = "炭火徐温、稳产零丹劫（炉资九折，保底药效≥98%，最宜炼制珍稀洗髓丹与调理圣药）"
		},
		balanced = {
			ID = "balanced", Title = "中火守正", Short = "中火", Color = "#dda21f", CostMult = 1.00,
			Grade2Bonus = 0, Grade3Bonus = 0, DoubleBonus = 0, MinPotencyFloor = 92, AllowTribulation = false,
			Desc = "文武适中、阴阳均衡（标准品阶与紫气双丹率，零丹劫走火风险）"
		},
		fierce = {
			ID = "fierce", Title = "武火催霞", Short = "武火", Color = "#ff825c", CostMult = 1.20,
			Grade2Bonus = 4, Grade3Bonus = 18, DoubleBonus = 15, MinPotencyFloor = 95, AllowTribulation = true,
			Desc = "风箱猛催！【丹霞极品率 +18% · 双丹率 +15%】，可逆炼【阴阳逆命奇丹】；惟药性失衡时有丹劫异变为《暴烈奇毒散》之险"
		}
	},

	// Six-Meridian Generating (`相生`) & Overcoming (`相克`) Matrix
	MeridianRelations = {
		Generates = {
			vital  = ["yang", "origin"],
			yang   = ["spirit", "origin"],
			spirit = ["origin", "vital"],
			origin = ["yin", "vital", "yang", "spirit"],
			yin    = ["vital", "venom"],
			venom  = ["yin"]
		},
		Overcomes = {
			yang   = ["yin"],
			yin    = ["yang"],
			vital  = ["venom"],
			venom  = ["vital", "spirit"],
			spirit = ["venom"]
		}
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
		},
		{
			ID = "f_zhuyin_lunzhuan", Category = "prep", PillID = "wx_pill_zhuyin", BaseYield = 1, RequiredCoreKey = "core:wx_core_zhuyin",
			JunNatures = ["origin", "yang", "yin"], MinJunPotency = 5, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 10, SilverCost = 680,
			FormulaNote = "【大妖本命古方】须以《钟山烛阴昼夜龙珠》坐镇君药鼎位，辅以两味奇珍调和寒暑，炼就昼夜轮转催功圣丹！"
		},
		{
			ID = "f_liangyi_niming", Category = "prep", PillID = "wx_pill_liangyi", BaseYield = 1, IsHiddenMutation = true,
			JunNatures = ["origin", "yang", "yin"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 10, SilverCost = 640,
			FormulaNote = "【阴阳逆命奇方】鼎中须含山海大妖内丹，并令【赤阳】与【玄阴】两极药材同炉激撞、以【武火催霞】逆炼混元！"
		},
		{
			ID = "f_kurong_niepan", Category = "prep", PillID = "wx_pill_kurong", BaseYield = 1, IsHiddenMutation = true,
			JunNatures = ["origin", "vital", "venom"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 11, SilverCost = 660,
			FormulaNote = "【阴阳逆命奇方】鼎中须含山海大妖内丹，并令【生机】与【奇毒】两极药材同炉激撞、以【武火催霞】逆炼枯荣！"
		},
		{
			ID = "f_shenmo_bixie", Category = "prep", PillID = "wx_pill_shenmo", BaseYield = 1, IsHiddenMutation = true,
			JunNatures = ["origin", "spirit", "venom"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 11, SilverCost = 660,
			FormulaNote = "【阴阳逆命奇方】鼎中须含山海大妖内丹，并令【镇魂】与【奇毒】两极药材同炉激撞、以【武火催霞】逆炼辟邪！"
		},
		{
			ID = "f_baize_kanpo", Category = "prep", PillID = "wx_pill_baize", BaseYield = 1, RequiredCoreKey = "core:wx_core_baize",
			JunNatures = ["origin", "spirit", "vital"], MinJunPotency = 5, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 10, SilverCost = 660,
			FormulaNote = "【大妖本命古方】须以《东望白泽通玄宝丹》坐镇君药鼎位，辅以两味灵药开悟神目，催化奇门反击与武学参悟！"
		},
		{
			ID = "f_jianmu_fengchun", Category = "prep", PillID = "wx_pill_jianmu", BaseYield = 1, RequiredCoreKey = "core:wx_core_jumang",
			JunNatures = ["origin", "vital", "yin", "spirit"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 10, SilverCost = 660,
			FormulaNote = "【大妖本命古方】须以《都广建木神心》坐镇君药鼎位，辅以两味生机灵引，催化横练硬功生肌修甲！"
		},
		{
			ID = "f_taotie_tunyuan", Category = "prep", PillID = "wx_pill_taotie", BaseYield = 1, RequiredCoreKey = "core:wx_core_taotie",
			JunNatures = ["origin", "yang", "venom", "vital"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 10, SilverCost = 660,
			FormulaNote = "【大妖本命古方】须以《饕餮噬元凶丹》坐镇君药鼎位，辅以两味凶煞奇材，催化外功重击鲸吞敌气！"
		},
		{
			ID = "f_yinglong_xingyun", Category = "prep", PillID = "wx_pill_yinglong", BaseYield = 1, RequiredCoreKey = "core:wx_core_yinglong",
			JunNatures = ["origin", "yin", "yang"], MinJunPotency = 5, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 10, SilverCost = 680,
			FormulaNote = "【大妖本命古方】须以《凶犁应龙真灵逆鳞珠》坐镇君药鼎位，辅以两味水雷灵材，催化轻功与穿刺长兵！"
		},
		{
			ID = "f_chiyou_baizhan", Category = "prep", PillID = "wx_pill_chiyou", BaseYield = 1, RequiredCoreKey = "core:wx_core_chiyou",
			JunNatures = ["origin", "yang", "vital", "spirit"], MinJunPotency = 5, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 10, SilverCost = 680,
			FormulaNote = "【大妖本命古方】须以《冀州蚩尤五兵煞主丹》坐镇君药鼎位，催化外功重兵破甲碎盾与斩敌威慑！"
		},
		{
			ID = "f_jinwu_chunyang", Category = "prep", PillID = "wx_pill_jinwu", BaseYield = 1, RequiredCoreKey = "core:wx_core_jinwu",
			JunNatures = ["origin", "yang"], MinJunPotency = 5, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 10, SilverCost = 680,
			FormulaNote = "【大妖本命古方】须以《汤谷三足金乌大日真丹》坐镇君药鼎位，催化纯阳真气焚甲诛邪、自涤寒霜！"
		},
		{
			ID = "f_xiangliu_wangu", Category = "prep", PillID = "wx_pill_xiangliu", BaseYield = 1, RequiredCoreKey = "core:wx_core_xiangliuwang",
			JunNatures = ["origin", "venom", "yin"], MinJunPotency = 5, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 10, SilverCost = 660,
			FormulaNote = "【大妖本命古方】须以《共工相柳九首苦毒丹》坐镇君药鼎位，催化五毒邪功免毒传蛊！"
		},
		{
			ID = "f_xuangui_buhuai", Category = "prep", PillID = "wx_pill_xuangui", BaseYield = 1, RequiredCoreKey = "core:wx_core_xuangui",
			JunNatures = ["origin", "yin", "vital"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 10, SilverCost = 660,
			FormulaNote = "【大妖本命古方】须以《杻阳玄龟镇海神丹》坐镇君药鼎位，催化横练磐石抗远免晕卸重击！"
		},
		{
			ID = "f_dijiang_suodi", Category = "prep", PillID = "wx_pill_dijiang", BaseYield = 1, RequiredCoreKey = "core:wx_core_dijiang",
			JunNatures = ["origin", "spirit", "yang"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 10, SilverCost = 670,
			FormulaNote = "【大妖本命古方】须以《天山帝江空间混沌丹》坐镇君药鼎位，催化轻功幻空折跃偏折重伤！"
		},
		{
			ID = "f_jiuwei_shehun", Category = "prep", PillID = "wx_pill_jiuwei", BaseYield = 1, RequiredCoreKey = "core:wx_core_jiuwei",
			JunNatures = ["origin", "spirit", "yin"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 10, SilverCost = 650,
			FormulaNote = "【大妖本命古方】须以《青丘九尾天狐幻丹》坐镇君药鼎位，催化奇门清心免魅惑并动摇敌魄！"
		},
		{
			ID = "f_xingtian_zhanhun", Category = "prep", PillID = "wx_pill_xingtian", BaseYield = 1, RequiredCoreKey = "core:wx_core_xingtian",
			JunNatures = ["origin", "yang", "vital", "spirit"], MinJunPotency = 4, RequireRareJun = true, MinAuxCount = 2, TargetPotency = 10, SilverCost = 680,
			FormulaNote = "【大妖本命古方】须以《常羊刑天不灭战魂丹》坐镇君药鼎位，催化狂战免晕与残血战魂回气增伤！"
		}
	]
};
