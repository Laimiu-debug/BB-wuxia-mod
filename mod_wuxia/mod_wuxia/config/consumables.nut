// 22 Jianghu & Shan Hai Alchemy Spirit Pills + 49《山海本草》Spirit Herbs (expanded in wx_alchemy.nut -> 50 Pills + 49 Herbs)
// Zero permanent stat bloat: all battle-prep pills & raw herb field buffs expire automatically after 1 combat.

::Wuxia.Config.MarrowWash <- {
	BaseChance = {
		[0] = 45, // 0★ -> 1★ (Replace old star or fill open star slot)
		[1] = 30, // 1★ -> 2★
		[2] = 15  // 2★ -> 3★
	},
	MaxPrepBonus            = 22, // Combined cap from Resolve, HP health, Main Neigong Tier, Protect Pill
	ProtectPillChanceBonus  = 5,
	SupremeProtectBonus     = 9,
	HighStarPermInjuryPct   = 18, // 15~20% permanent internal injury risk on 2★/3★ fail without Protect Pill
	ShockDurationDays       = 5
};

::Wuxia.Config.Pills <- {
	wx_pill_jinchuang = {
		ID          = "wx_pill_jinchuang",
		Name        = "金疮散",
		SubLabel    = "外伤跌打",
		Quality     = "common",
		Description = "外敷内服皆宜的跌打良药，在行囊或武学面板点击服药，可立即解除一处临时外伤。",
		Kind        = "heal_external",
		Icon        = "consumables/wx_pill_jinchuang.png",
		Value       = 180
	},
	wx_pill_huoluo = {
		ID          = "wx_pill_huoluo",
		Name        = "易筋活络膏",
		SubLabel    = "重创良膏",
		Quality     = "sect",
		Description = "奇门跌打秘炼黑玉药膏，服敷后可一次解除至多 2 处临时外伤，并立即调理恢复至多 35 点受损气血。",
		Kind        = "heal_external_plus",
		Icon        = "consumables/wx_pill_huoluo.png",
		Value       = 420
	},
	wx_pill_longxue = {
		ID          = "wx_pill_longxue",
		Name        = "血竭续骨圣膏",
		SubLabel    = "接骨痊伤",
		Quality     = "secret",
		Description = "苍梧千年血竭配朱厌铁骨秘熬的接骨圣膏：敷服后一次性拔除角色身上全部临时外伤，并恢复至多 65 点受损气血！",
		Kind        = "heal_all_wounds",
		Icon        = "consumables/wx_pill_longxue.png",
		Value       = 980
	},
	wx_pill_huxin = {
		ID          = "wx_pill_huxin",
		Name        = "护心丹",
		SubLabel    = "调息化伤",
		Quality     = "sect",
		Description = "温养心脉的灵丹，在行囊或武学面板点击服用，可立即化解「散功虚弱」、「内伤」与「经脉震荡」。",
		Kind        = "heal_internal",
		Icon        = "consumables/wx_pill_huxin.png",
		Value       = 450
	},
	wx_pill_bingxin = {
		ID          = "wx_pill_bingxin",
		Name        = "天山雪莲冰心丹",
		SubLabel    = "清脉凝霜",
		Quality     = "secret",
		Description = "天山寒玉雪莲配冰魄草精炼的清脉宝丹：立即化解「散功虚弱」与「内伤/经脉震荡」，令下战免奇毒免夜盲；【丹武催化·阴柔脉】主修阴柔内功时受近战反凝寒霜减敌先攻并散其 3 点内息（战后消散）。",
		Kind        = "heal_internal_plus",
		Icon        = "consumables/wx_pill_bingxin.png",
		Value       = 1150
	},
	wx_pill_shennong = {
		ID          = "wx_pill_shennong",
		Name        = "神农百草返魂丹",
		SubLabel    = "起死回生",
		Quality     = "unique",
		Description = "汇集山海奇草炼就的杏林救命至宝：立即补满全部受损气血，并一次性清除所有临时外伤、临时内伤与散功虚弱！",
		Kind        = "heal_full_recovery",
		Icon        = "consumables/wx_pill_shennong.png",
		Value       = 2200
	},
	wx_pill_qingxin = {
		ID          = "wx_pill_qingxin",
		Name        = "清心解毒丹",
		SubLabel    = "化毒回元",
		Quality     = "sect",
		Description = "百草药庐秘制碧玉解毒丸：下场战斗全程免疫吹箭奇毒与蛛蝎剧毒；【丹武催化·奇门内功脉】立于沼泽毒瘴或遭毒击时反借药力每轮恢复 +3 内息（战后消散）。",
		Kind        = "buff_qingxin",
		Icon        = "consumables/wx_pill_qingxin.png",
		Value       = 380
	},
	wx_pill_hugu = {
		ID          = "wx_pill_hugu",
		Name        = "虎骨壮气丸",
		SubLabel    = "催阳震甲",
		Quality     = "sect",
		Description = "边塞烈酒浸陈年虎骨炼制的壮气大丸：补满当前气血，下战 +12 内息、+2 回气；【丹武催化·阳刚外功脉】主修阳刚内功或施展震甲重招时近战命中额外崩损目标 6 点身甲（战后消散）。",
		Kind        = "buff_hugu",
		Icon        = "consumables/wx_pill_hugu.png",
		Value       = 520
	},
	wx_pill_dingshen = {
		ID          = "wx_pill_dingshen",
		Name        = "明目定神散",
		SubLabel    = "勘雾定魄",
		Quality     = "sect",
		Description = "玄门朱砂琥珀研制的清心灵散：下战 +10 定力、免除夜盲；【丹武催化·奇门射艺脉】处于烟幕、夜雾或青丘迷障中近远命中额外 +6（战后消散）。",
		Kind        = "buff_dingshen",
		Icon        = "consumables/wx_pill_dingshen.png",
		Value       = 480
	},
	wx_pill_zhuyu = {
		ID          = "wx_pill_zhuyu",
		Name        = "祝余辟谷丹",
		SubLabel    = "吐纳生息",
		Quality     = "secret",
		Description = "采《南山经》祝余仙草炼制：补满气血，下战 +16 内息、+3 回气；【丹武催化·中正吐纳脉】施展「调息吐纳」额外多回 +8 内息，已耗内息过半时出招耗气 -10%（战后消散）。",
		Kind        = "buff_zhuyu",
		Icon        = "consumables/wx_pill_zhuyu.png",
		Value       = 780
	},
	wx_pill_duheng = {
		ID          = "wx_pill_duheng",
		Name        = "杜衡追风丸",
		SubLabel    = "乘风游身",
		Quality     = "secret",
		Description = "采《西山经》杜衡走马草秘炼：下战 +18 身法、+5 远防；【丹武催化·轻功身法脉】装备轻功秘籍且施展穿步/步进招式后，本轮近远双防额外 +3（战后消散）。",
		Kind        = "buff_duheng",
		Icon        = "consumables/wx_pill_duheng.png",
		Value       = 760
	},
	wx_pill_dixiu = {
		ID          = "wx_pill_dixiu",
		Name        = "帝休定岳丹",
		SubLabel    = "镇岳护甲",
		Quality     = "secret",
		Description = "采《中山经》少室帝休黄华枝炼制：下战 +14 定力且免疫震晕击晕；【丹武催化·横练守阵脉】装备横练硬功时承受破甲损耗额外降低 -12%（战后消散）。",
		Kind        = "buff_dixiu",
		Icon        = "consumables/wx_pill_dixiu.png",
		Value       = 880
	},
	wx_pill_guiyuan = {
		ID          = "wx_pill_guiyuan",
		Name        = "首乌归元培气丸",
		SubLabel    = "周天培元",
		Quality     = "secret",
		Description = "云梦千年首乌配山海兽髓久蒸九晒：立回 40 气血，下战 +18 气血、+2 回气；【丹武催化·双内功脉】辅修第 2 门内功时每回合初额外温养自愈 +4 气血、回气 +2（战后消散）。",
		Kind        = "buff_guiyuan",
		Icon        = "consumables/wx_pill_guiyuan.png",
		Value       = 820
	},
	wx_pill_baishe = {
		ID          = "wx_pill_baishe",
		Name        = "五毒百草辟瘴丸",
		SubLabel    = "毒瘴反噬",
		Quality     = "secret",
		Description = "嘉荣草配五毒腺囊以毒攻毒炼就：下战全程免毒且近远双防 +4；【丹武催化·五毒奇门脉】遭受近战攻击时护体药瘴有 30% 概率反染来敌【暗器奇毒】（战后消散）。",
		Kind        = "buff_baishe",
		Icon        = "consumables/wx_pill_baishe.png",
		Value       = 850
	},
	wx_pill_jinzun = {
		ID          = "wx_pill_jinzun",
		Name        = "金刚铁骨护体丸",
		SubLabel    = "横练反震",
		Quality     = "secret",
		Description = "少室护体金丸：下战气血与护甲受击减免 12%（严守 60% 总减伤封顶）且免击退抓取；【丹武催化·横练硬功脉】装配横练秘籍受近战打击时罡气反削攻击者 6 点身甲（战后消散）。",
		Kind        = "buff_jinzun",
		Icon        = "consumables/wx_pill_jinzun.png",
		Value       = 960
	},
	wx_pill_ningshen = {
		ID          = "wx_pill_ningshen",
		Name        = "凝神丸",
		SubLabel    = "灌注火候",
		Quality     = "sect",
		Description = "凝聚心神的修炼丹药。拖拽至任意未满重武学插槽（或右键快灌），立即灌注 +150 点火候。",
		Kind        = "infuse_exp",
		ExpAmount   = 150,
		Icon        = "consumables/wx_pill_ningshen.png",
		Value       = 600
	},
	wx_pill_jiuhua = {
		ID          = "wx_pill_jiuhua",
		Name        = "九花玉露丸",
		SubLabel    = "清灵灌顶",
		Quality     = "secret",
		Description = "东海名门采集九种奇花晨露精制的灵丹。拖入武学插槽立即灌注 +230 点火候，并温养恢复角色 30 点气血。",
		Kind        = "infuse_exp",
		HealHP      = 30,
		ExpAmount   = 230,
		Icon        = "consumables/wx_pill_jiuhua.png",
		Value       = 1050
	},
	wx_pill_dahuan = {
		ID          = "wx_pill_dahuan",
		Name        = "九转大还丹",
		SubLabel    = "宗师圣丹",
		Quality     = "secret",
		Description = "名门秘传九转金丹。拖拽至任意未满重武学插槽立即灌注 +320 点火候，并顺带平复散功虚弱！",
		Kind        = "infuse_exp",
		CuresScatter = true,
		ExpAmount   = 320,
		Icon        = "consumables/wx_pill_dahuan.png",
		Value       = 1600
	},
	wx_pill_zijin = {
		ID           = "wx_pill_zijin",
		Name         = "太虚紫金大丹",
		SubLabel     = "天人造化",
		Quality      = "unique",
		Description  = "山海内丹配九叶紫芝炼成的无上仙丹！拖入任意未满重武学插槽立即灌注 +480 点火候，并同时涤清散功虚弱与临时内伤！",
		Kind         = "infuse_exp",
		CuresScatter = true,
		CuresInternal = true,
		ExpAmount    = 480,
		Icon         = "consumables/wx_pill_zijin.png",
		Value        = 2800
	},
	wx_pill_humai = {
		ID           = "wx_pill_humai",
		Name         = "护脉丹",
		SubLabel     = "洗髓护经",
		Quality      = "secret",
		ProtectBonus = 5,
		Description  = "洗经伐髓前辅服的护脉宝丹：提升 +5% 洗髓成功率，并在失败时免除永久经脉暗疾风险。",
		Kind         = "wash_protect",
		Icon         = "consumables/wx_pill_humai.png",
		Value        = 1500
	},
	wx_pill_zaohua = {
		ID           = "wx_pill_zaohua",
		Name         = "山海造化护脉金丹",
		SubLabel     = "至尊护脉",
		Quality      = "unique",
		ProtectBonus = 9,
		AvoidShock   = true,
		Description  = "融山海瑞兽内丹与沙棠金果炼制的护脉圣丹：洗经伐髓时提升 +9% 成功率，且纵使冲星未果亦彻底免除永久暗疾与经脉震荡！",
		Kind         = "wash_protect",
		Icon         = "consumables/wx_pill_zaohua.png",
		Value        = 2600
	},
	wx_pill_xisui = {
		ID          = "wx_pill_xisui",
		Name        = "洗髓丹",
		SubLabel    = "伐毛洗髓",
		Quality     = "unique",
		Description = "极稀有的伐毛洗髓奇药，在武学面板点击或开启「洗经伐髓」即可重塑根骨（冲星或易筋换星）。",
		Kind        = "marrow_wash",
		Icon        = "consumables/wx_pill_xisui.png",
		Value       = 4500
	}
};

// 49《山海本草》Spirit Herbs (craftable into Spirit Pills at 百工丹坊·八卦丹炉, or usable raw in emergencies!)
::Wuxia.Config.Herbs <- {
	wx_marrow_herb = {
		ID          = "wx_marrow_herb",
		Name        = "洗髓血芝",
		Chapter     = "山海本草",
		SubLabel    = "洗髓主药",
		Quality     = "unique",
		Kind        = "herb_infuse",
		ExpAmount   = 110,
		Icon        = "misc/wx_marrow_herb.png",
		Value       = 1400,
		Description = "血煞总寨与山海秘境珍藏的千年赤血灵芝：在百工炼丹房配朱厌血核与肥遗龙骨可炼出「洗髓丹」，亦可拖入武学插槽生服参悟（+110 火候）。"
	},
	wx_herb_zhuyu = {
		ID          = "wx_herb_zhuyu",
		Name        = "招摇祝余仙草",
		Chapter     = "南山经",
		SubLabel    = "食之不饥",
		Quality     = "sect",
		Kind        = "herb_hp",
		HealAmount  = 28,
		Icon        = "misc/wx_herb_zhuyu.png",
		Value       = 520,
		Description = "《南山经》招摇之山奇草，状如韭而青华，食之不饥：可在百工坊主炼「祝余辟谷丹」，行囊直接生嚼亦可立即恢复 28 点受损气血。"
	},
	wx_herb_migu = {
		ID          = "wx_herb_migu",
		Name        = "招摇迷榖神枝",
		Chapter     = "南山经",
		SubLabel    = "佩之不迷",
		Quality     = "sect",
		Kind        = "herb_calm",
		Icon        = "misc/wx_herb_migu.png",
		Value       = 560,
		Description = "《南山经》黑理四照奇木花枝，佩之夜行不迷：可在百工坊辅炼「明目定神散」与「九花玉露丸」，生服可令下场战斗夜战无盲且定力 +6。"
	},
	wx_herb_bili = {
		ID          = "wx_herb_bili",
		Name        = "小华山萆荔血藤",
		Chapter     = "西山经",
		SubLabel    = "已心腹痛",
		Quality     = "sect",
		Kind        = "herb_internal",
		Icon        = "misc/wx_herb_bili.png",
		Value       = 620,
		Description = "《西山经》生于太华石崖之赤红乌韭奇藤，食之已心痛：可在百工坊炼制「护心丹」与「护脉丹」，生服可当场平复「散功虚弱」或轻度内伤。"
	},
	wx_herb_xuncao = {
		ID          = "wx_herb_xuncao",
		Name        = "天帝山荀草朱实",
		Chapter     = "西山经",
		SubLabel    = "活血润肌",
		Quality     = "sect",
		Kind        = "herb_hp",
		HealAmount  = 35,
		CureOneWound = true,
		Icon        = "misc/wx_herb_xuncao.png",
		Value       = 580,
		Description = "《西山经》白华赤实灵草，气芳生肌：可在百工坊合炼「九花玉露丸」与「易筋活络膏」，急用捣敷可解除 1 处外伤并恢复 35 点气血。"
	},
	wx_herb_shatang = {
		ID          = "wx_herb_shatang",
		Name        = "昆仑沙棠金果",
		Chapter     = "西山经",
		SubLabel    = "御水通脉",
		Quality     = "secret",
		Kind        = "herb_infuse",
		ExpAmount   = 95,
		Icon        = "misc/wx_herb_shatang.png",
		Value       = 980,
		Description = "《西山经》昆仑之丘黄华赤实无核神果，食之使人不溺：乃百工坊炼制「山海造化护脉金丹」之核心仙果，亦可拖入插槽灌注 +95 火候。"
	},
	wx_herb_dixiu = {
		ID          = "wx_herb_dixiu",
		Name        = "少室帝休黄华枝",
		Chapter     = "中山经",
		SubLabel    = "服者不怒",
		Quality     = "secret",
		Kind        = "herb_calm",
		Icon        = "misc/wx_herb_dixiu.png",
		CalmBravery = 8,
		Value       = 680,
		Description = "《中山经》少室山黑文黄华神木枝，服者心平不怒：可在百工坊主炼「帝休定岳丹」，直接含服亦可令下场战斗定力 +8、夜战清明。"
	},
	wx_herb_duheng = {
		ID          = "wx_herb_duheng",
		Name        = "天帝杜衡走马草",
		Chapter     = "西山经",
		SubLabel    = "食之善走",
		Quality     = "sect",
		Kind        = "herb_swift",
		Icon        = "misc/wx_herb_duheng.png",
		Value       = 600,
		Description = "《西山经》状如葵而臭如蘼芜之奇草，食之使人善走：可在百工坊主炼「杜衡追风丸」，临阵生嚼可令下场战斗临时 +10 身法。"
	},
	wx_herb_jiarong = {
		ID          = "wx_herb_jiarong",
		Name        = "半石山嘉荣碧草",
		Chapter     = "中山经",
		SubLabel    = "辟雷解蛊",
		Quality     = "secret",
		Kind        = "herb_detox",
		Icon        = "misc/wx_herb_jiarong.png",
		Value       = 700,
		Description = "《中山经》赤茎层叶微泛雷纹之灵草：可在百工坊主炼「五毒百草辟瘴丸」，生服可令下场战斗全程免疫蛛蝎五毒侵害。"
	},
	wx_herb_zhichu = {
		ID          = "wx_herb_zhichu",
		Name        = "敖岸植楮醒神叶",
		Chapter     = "中山经",
		SubLabel    = "食之不眯",
		Quality     = "secret",
		Kind        = "herb_calm",
		Icon        = "misc/wx_herb_zhichu.png",
		Value       = 660,
		Description = "《中山经》血脉叶纹奇枝，食之耳目清明不魇：可在百工坊主炼「金刚铁骨护体丸」，生嚼可令下场战斗定力 +6 且免夜盲。"
	},
	wx_herb_guicao = {
		ID          = "wx_herb_guicao",
		Name        = "姑媱帝女鬼草",
		Chapter     = "中山经",
		SubLabel    = "通幽凝魄",
		Quality     = "secret",
		Kind        = "herb_infuse",
		ExpAmount   = 85,
		Icon        = "misc/wx_herb_guicao.png",
		Value       = 780,
		Description = "《中山经》赤茎秀如禾之幽紫奇草，蕴藏精纯阴灵：可在百工坊合炼「凝神丸」与「九转大还丹」，亦可拖入插槽灌注 +85 火候。"
	},
	wx_herb_longxuejie = {
		ID           = "wx_herb_longxuejie",
		Name         = "苍梧千年血竭晶",
		Chapter      = "海内南经",
		SubLabel     = "续筋接骨",
		Quality      = "secret",
		Kind         = "herb_hp",
		HealAmount   = 45,
		CureOneWound = true,
		Icon         = "misc/wx_herb_longxuejie.png",
		Value        = 820,
		Description  = "苍梧古林龙血神木凝结千年的深红脂晶：乃百工坊熬炼「血竭续骨圣膏」之主材，外敷内服可立愈 1 处外伤并恢复 45 点气血。"
	},
	wx_herb_xuelian = {
		ID          = "wx_herb_xuelian",
		Name        = "天山绝顶寒玉雪莲",
		Chapter     = "西山经",
		SubLabel    = "涤脉清髓",
		Quality     = "secret",
		Kind        = "herb_internal",
		Icon        = "misc/wx_herb_xuelian.png",
		Value       = 960,
		Description = "天山冰峰绝壁盛开的寒玉雪莲：可在百工坊主炼「天山雪莲冰心丹」与「神农百草返魂丹」，生服可立即化解临时内伤与散功虚弱。"
	},
	wx_herb_heshouwu = {
		ID          = "wx_herb_heshouwu",
		Name        = "云梦千年人形首乌",
		Chapter     = "中山经",
		SubLabel    = "乌发益寿",
		Quality     = "secret",
		Kind        = "herb_hp",
		HealAmount  = 50,
		Icon        = "misc/wx_herb_heshouwu.png",
		Value       = 880,
		Description = "云梦大泽深处成形的千年何首乌块根，药气醇厚：可在百工坊主炼「首乌归元培气丸」与「九转大还丹」，生服可补足 50 点气血。"
	},
	wx_herb_zizhi = {
		ID          = "wx_herb_zizhi",
		Name        = "华岳九叶紫金灵芝",
		Chapter     = "西山经",
		SubLabel    = "紫气东来",
		Quality     = "unique",
		Kind        = "herb_infuse",
		ExpAmount   = 120,
		Icon        = "misc/wx_herb_zizhi.png",
		Value       = 1350,
		Description = "太华危崖吸收紫霞日精而生的九层紫金灵芝：可在百工坊炼制仙品「太虚紫金大丹」与「神农百草返魂丹」，亦可拖入插槽灌注 +120 火候。"
	},
	wx_herb_huolingzhi = {
		ID          = "wx_herb_huolingzhi",
		Name        = "太华旱渊赤火芝",
		Chapter     = "西山经",
		SubLabel    = "纯阳火精",
		Quality     = "secret",
		Kind        = "herb_infuse",
		ExpAmount   = 100,
		Icon        = "misc/wx_herb_huolingzhi.png",
		Value       = 1100,
		Description = "伴生于肥遗与祸斗焦岩裂谷的纯阳赤火灵芝：可在百工坊淬炼火系山海神兵或炼制「洗髓丹」，亦可拖入插槽灌注 +100 火候。"
	},
	wx_herb_bingpocao = {
		ID          = "wx_herb_bingpocao",
		Name        = "从极渊万载冰魄草",
		Chapter     = "海内北经",
		SubLabel    = "玄冥寒髓",
		Quality     = "secret",
		Kind        = "herb_infuse",
		ExpAmount   = 100,
		Icon        = "misc/wx_herb_bingpocao.png",
		Value       = 1100,
		Description = "从极寒渊冰夷潜居处生出的剔透冰晶兰草：可在百工坊合炼「天山雪莲冰心丹」或淬炼寒系山海重宝，亦可拖入插槽灌注 +100 火候。"
	},

	// ==================== 卷二：五藏山经 · 道地本草与山泽灵卉（16 味） ====================
	wx_herb_huangguan = {
		ID          = "wx_herb_huangguan",
		Name        = "北岳黄雚辟浴草",
		Chapter     = "北山经",
		SubLabel    = "浴之已疥",
		Quality     = "common",
		Kind        = "herb_ward_fire",
		Icon        = "misc/wx_herb_huangguan.png",
		Value       = 340,
		Description = "《北山经》泰器与北岳山谷常生奇草，圆叶绿茎、白华紫颖，浴之已疥清火：可入八卦丹炉作玄阴臣佐辅药，临阵捣敷可令下场战斗免疫山海灼甲毒火光环。"
	},
	wx_herb_tiaocao = {
		ID          = "wx_herb_tiaocao",
		Name        = "独山条草白缕茎",
		Chapter     = "东山经",
		SubLabel    = "食之不惑",
		Quality     = "common",
		Kind        = "herb_calm",
		CalmBravery = 5,
		Icon        = "misc/wx_herb_tiaocao.png",
		Value       = 330,
		Description = "《东山经》独山与姑儿山道地灵草，状如葵而赤华黄实如婴儿舌，食之使人不惑：可入八卦丹炉配炼镇魂定神散剂，生嚼可令下场战斗定力 +5 且免夜盲。"
	},
	wx_herb_pincao = {
		ID          = "wx_herb_pincao",
		Name        = "太行薲草青华叶",
		Chapter     = "北山经",
		SubLabel    = "食之已疠",
		Quality     = "common",
		Kind        = "herb_hp",
		HealAmount  = 22,
		Icon        = "misc/wx_herb_pincao.png",
		Value       = 310,
		Description = "《北山经》太行水泽四叶奇草，青华白实，食之已疠疏风：乃八卦丹炉熬炼「金疮止血散」「易筋活络膏」之良善生机本草，生嚼亦可立回 22 点气血。"
	},
	wx_herb_mangcao = {
		ID          = "wx_herb_mangcao",
		Name        = "蕀山芒草麻叶枝",
		Chapter     = "中山经",
		SubLabel    = "可以毒鱼",
		Quality     = "common",
		Kind        = "herb_detox",
		Icon        = "misc/wx_herb_mangcao.png",
		Value       = 350,
		Description = "《中山经》蕀山与朝歌山奇木枝，状如棠而锯齿赤叶、汁带微麻，可以毒鱼辟虫：可入八卦丹炉充任奇毒药引，微量含服以毒攻毒令下战免疫奇毒。"
	},
	wx_herb_wutiao = {
		ID           = "wx_herb_wutiao",
		Name         = "高氏山无条圆草",
		Chapter      = "东山经",
		SubLabel     = "行血消瘿",
		Quality      = "common",
		Kind         = "herb_hp",
		HealAmount   = 20,
		CureOneWound = true,
		Icon         = "misc/wx_herb_wutiao.png",
		Value        = 360,
		Description  = "《东山经》高氏山阳坡灵草，赤茎白华状如山樱，食之活血消瘿：可入八卦丹炉辅炼赤阳疗伤膏散，急用外敷可化去 1 处临时外伤并恢复 20 点气血。"
	},
	wx_herb_gurong = {
		ID          = "wx_herb_gurong",
		Name        = "幡冢山蓇蓉香草",
		Chapter     = "南山经",
		SubLabel    = "壮气健骨",
		Quality     = "common",
		Kind        = "herb_qi",
		Icon        = "misc/wx_herb_gurong.png",
		Value       = 370,
		Description = "《山海经》幡冢山奇草，叶如兰蕙、根似桔梗而开玄黑奇花，佩服壮气强筋：可入八卦丹炉合炼「虎骨壮气丸」，临战嚼服令下场战斗内息 +12、回气 +2。"
	},
	wx_herb_jiancao = {
		ID          = "wx_herb_jiancao",
		Name        = "伦山葌草紫茸株",
		Chapter     = "北山经",
		SubLabel    = "清寒敛脉",
		Quality     = "common",
		Kind        = "herb_internal",
		Icon        = "misc/wx_herb_jiancao.png",
		Value       = 360,
		Description = "《北山经》伦山寒涧奇草，紫茎青华状如霜韭，药性清冽敛血：可入八卦丹炉辅炼「护心丹」「忘尘归元散」，生服可平复散功虚弱或临时内伤。"
	},
	wx_herb_gouwen = {
		ID          = "wx_herb_gouwen",
		Name        = "南荒钩吻断肠藤",
		Chapter     = "海内南经",
		SubLabel    = "以毒攻毒",
		Quality     = "sect",
		Kind        = "herb_detox",
		Icon        = "misc/wx_herb_gouwen.png",
		Value       = 590,
		Description = "《海内南经》南荒瘴林紫蔓黄花剧毒奇藤，俗称野葛断肠草：入八卦丹炉正是熬炼「南疆孔雀胆淬毒膏」「五仙腐骨散」的上乘奇毒主引，微量淬服反辟五毒。"
	},
	wx_herb_longchu = {
		ID          = "wx_herb_longchu",
		Name        = "东海龙刍骏骨草",
		Chapter     = "东山经",
		SubLabel    = "日行千里",
		Quality     = "sect",
		Kind        = "herb_swift",
		Icon        = "misc/wx_herb_longchu.png",
		Value       = 610,
		Description = "《东山经》东海洲岛赤节盘须灵草，传为骏马食之日行千里之神刍：可在八卦丹炉主炼「杜衡追风丸」「龙虎提纵散」，生嚼可令下场战斗临时 +10 身法。"
	},
	wx_herb_baiman = {
		ID          = "wx_herb_baiman",
		Name        = "泰戏山白䔄凝血根",
		Chapter     = "北山经",
		SubLabel    = "凝肌封创",
		Quality     = "sect",
		Kind        = "herb_staunch",
		Icon        = "misc/wx_herb_baiman.png",
		Value       = 580,
		Description = "《北山经》泰戏山白华玉根奇草，津液凝红如脂，专擅封疮止血：可在八卦丹炉主炼「玉肌止血散」，临阵敷服令下场战斗全程免疫流血割裂。"
	},
	wx_herb_xuanji = {
		ID          = "wx_herb_xuanji",
		Name        = "北嚣山玄棘寒实",
		Chapter     = "北山经",
		SubLabel    = "冰实涤火",
		Quality     = "sect",
		Kind        = "herb_ward_fire",
		Icon        = "misc/wx_herb_xuanji.png",
		Value       = 620,
		Description = "《北山经》北嚣寒岭黑刺铁木所结幽蓝冰果，寒气彻骨：可在八卦丹炉主炼「玄冰辟火丸」「踏雪凌风露」，生吞令下场战斗免疫毒火灼甲光环并减远伤。"
	},
	wx_herb_yaocao = {
		ID          = "wx_herb_yaocao",
		Name        = "姑媱山帝女蘨草",
		Chapter     = "中山经",
		SubLabel    = "凝魂忘忧",
		Quality     = "sect",
		Kind        = "herb_calm",
		CalmBravery = 7,
		Icon        = "misc/wx_herb_yaocao.png",
		Value       = 630,
		Description = "《中山经》姑媱之山帝女精魂所化奇草，叠叶黄华、实如菟丝，服之忘忧定魄：可入八卦丹炉主炼「太清镇魔定脉丹」「九宫磐石丸」，含服令下战定力 +7 免夜盲。"
	},
	wx_herb_guimu = {
		ID          = "wx_herb_guimu",
		Name        = "东荒鬼目蚀骨蕈",
		Chapter     = "东山经",
		SubLabel    = "瘴蕈淬蛊",
		Quality     = "sect",
		Kind        = "herb_detox",
		Icon        = "misc/wx_herb_guimu.png",
		Value       = 640,
		Description = "《东山经》阴湿幽谷腐骨上丛生的赤伞黑瞳奇蕈，孢雾腥冽：乃八卦丹炉炼制「五仙腐骨蚀甲散」「透骨寻隙封脉散」的奇毒灵材，焙干吞服可辟蛇蝎蛊毒。"
	},
	wx_herb_zhugu = {
		ID          = "wx_herb_zhugu",
		Name        = "钟山朱果赤丹实",
		Chapter     = "西山经",
		SubLabel    = "食之不倦",
		Quality     = "sect",
		Kind        = "herb_qi",
		Icon        = "misc/wx_herb_zhugu.png",
		Value       = 620,
		Description = "《西山经》钟山钦䴔与鼓所守赤丹酸枣灵果，热力绵长食之不倦：可在八卦丹炉主炼「巨灵披甲行气丸」「醉仙望月狂酒」，生食令下战内息 +12、回气 +2。"
	},
	wx_herb_hanshui = {
		ID          = "wx_herb_hanshui",
		Name        = "敦薨寒水玉藻",
		Chapter     = "北山经",
		SubLabel    = "清渊护脉",
		Quality     = "sect",
		Kind        = "herb_internal",
		Icon        = "misc/wx_herb_hanshui.png",
		Value       = 600,
		Description = "《北山经》敦薨寒潭赤鲑潜游处采得的碧玉冰藻，柔韧清润：可在八卦丹炉合炼「护脉丹」「先天真气护体丹」，生服可立解临时内伤与散功虚弱。"
	},
	wx_herb_sutiao = {
		ID          = "wx_herb_sutiao",
		Name        = "劳山夙条长青木",
		Chapter     = "东山经",
		SubLabel    = "四时不凋",
		Quality     = "sect",
		Kind        = "herb_infuse",
		ExpAmount   = 70,
		Icon        = "misc/wx_herb_sutiao.png",
		Value       = 680,
		Description = "《东山经》东海劳山苍皮碧芽长青古木枝，四时吞吐海岳元气：可在八卦丹炉合炼「凝神丸」「九转大还丹」，亦可拖入武学插槽生服参悟（+70 火候）。"
	},

	// ==================== 卷三：海外·海内·大荒经 · 秘境奇珍与天地仙株（16 味） ====================
	wx_herb_zhenyu = {
		ID          = "wx_herb_zhenyu",
		Name        = "羽山鸩羽紫毒兰",
		Chapter     = "海外南经",
		SubLabel    = "霸毒续骨",
		Quality     = "secret",
		Kind        = "herb_infuse",
		ExpAmount   = 95,
		Icon        = "misc/wx_herb_zhenyu.png",
		Value       = 980,
		Description = "《海外南经》羽山绝壑受鸩鸟毒羽浸染而生的黑紫孔雀奇兰：其霸道奇毒药力正是八卦丹炉催炼「黑玉断续膏」根除永久残废之绝佳君药，亦可灌注 +95 火候。"
	},
	wx_herb_xiangliuxue = {
		ID           = "wx_herb_xiangliuxue",
		Name         = "共工台相柳腥血蕈",
		Chapter      = "海外北经",
		SubLabel     = "九首毒芝",
		Quality      = "secret",
		Kind         = "herb_hp",
		HealAmount   = 42,
		CureOneWound = true,
		Icon         = "misc/wx_herb_xiangliuxue.png",
		Value        = 1020,
		Description  = "《海外北经》共工之台外围相柳毒血浸土三载凝出的九瓣腥红妖蕈：高阶奇毒与狂暴血气交融，可主炼「黑玉断续膏」「疯魔燃血丸」，急敷愈 1 处外伤并回 42 血。"
	},
	wx_herb_wuzhi = {
		ID          = "wx_herb_wuzhi",
		Name        = "巫咸山登葆百巫草",
		Chapter     = "海外西经",
		SubLabel    = "通天定识",
		Quality     = "secret",
		Kind        = "herb_infuse",
		ExpAmount   = 95,
		Icon        = "misc/wx_herb_wuzhi.png",
		Value       = 950,
		Description = "《海外西经》巫咸国登葆山群巫采药通灵之紫叶星纹仙草：乃八卦丹炉炼制「紫芝醍醐悟道丹」「九转大还丹」之上品镇魂君药，亦可拖入插槽灌注 +95 火候。"
	},
	wx_herb_danmu = {
		ID           = "wx_herb_danmu",
		Name         = "峚山丹木五色玉膏",
		Chapter      = "西山经",
		SubLabel     = "黄帝所食",
		Quality      = "secret",
		Kind         = "herb_hp",
		HealAmount   = 52,
		CureOneWound = true,
		Icon         = "misc/wx_herb_danmu.png",
		Value        = 960,
		Description  = "《西山经》峚山赤茎圆叶丹木伴沸涌白玉膏凝结的五色灵脂，味甘如饴：可主炼「易筋锻骨丸」「洗髓丹」与「血竭续骨圣膏」，内服立愈 1 处外伤并回 52 气血。"
	},
	wx_herb_xunmu = {
		ID          = "wx_herb_xunmu",
		Name        = "大荒寻木千里灵蕊",
		Chapter     = "海外北经",
		SubLabel     = "垂荫千里",
		Quality     = "secret",
		Kind        = "herb_hp",
		HealAmount  = 55,
		Icon        = "misc/wx_herb_xunmu.png",
		Value       = 940,
		Description = "《海外北经》生于河上长千里之巨神木金绿花蕊，蕴藏磅礴生机：乃八卦丹炉主炼「生生造化丹」「天王吊命保心丹」之上品生机主药，生服直补 55 点气血。"
	},
	wx_herb_yushu = {
		ID          = "wx_herb_yushu",
		Name        = "昆仑开明琪花玉树",
		Chapter     = "海内西经",
		SubLabel    = "琼枝涤髓",
		Quality     = "secret",
		Kind        = "herb_internal",
		Icon        = "misc/wx_herb_yushu.png",
		Value       = 990,
		Description = "《海内西经》昆仑开明兽北侧文玉琪树折下的琼枝珠花，冰清彻骨：可在八卦丹炉主炼「天山雪莲冰心丹」「先天真气护体丹」，生服立消临时内伤与散功虚弱。"
	},
	wx_herb_ruomu = {
		ID          = "wx_herb_ruomu",
		Name        = "灰野若木青叶赤华",
		Chapter     = "大荒北经",
		SubLabel    = "夕照神华",
		Quality     = "secret",
		Kind        = "herb_infuse",
		ExpAmount   = 100,
		Icon        = "misc/wx_herb_ruomu.png",
		Value       = 1080,
		Description = "《大荒北经》大荒灰野日落神树之青叶赤花，光华下照九地：可在八卦丹炉主炼「龙虎纯阳破邪丹」「孤锋破玉淬劲散」或「洗髓丹」，亦可插槽灌注 +100 火候。"
	},
	wx_herb_yinglu = {
		ID          = "wx_herb_yinglu",
		Name        = "沃民之野甘露嘉果",
		Chapter     = "海外西经",
		SubLabel    = "百凤衔露",
		Quality     = "secret",
		Kind        = "herb_staunch",
		Icon        = "misc/wx_herb_yinglu.png",
		Value       = 920,
		Description = "《海外西经》沃民之国鸾歌凤舞处甘露凝成的双生金果：可在八卦丹炉主炼「神农百草返魂丹」「生生造化丹」，生食令下场战斗免流血割裂并持续回血。"
	},
	wx_herb_youduhua = {
		ID          = "wx_herb_youduhua",
		Name        = "幽都玄冥引魂冥花",
		Chapter     = "海内经",
		SubLabel    = "北海镇魄",
		Quality     = "secret",
		Kind        = "herb_calm",
		CalmBravery = 10,
		Icon        = "misc/wx_herb_youduhua.png",
		Value       = 960,
		Description = "《海内经》北海黑水幽都山玄虎守御的苍蓝引魂彼岸奇花：可在八卦丹炉主炼「太清镇魔定脉丹」「帝休定岳丹」，生服令下场战斗定力 +10 且暗夜明目。"
	},
	wx_herb_langgan = {
		ID          = "wx_herb_langgan",
		Name        = "昆仑琅玕凤食碧实",
		Chapter     = "海内西经",
		SubLabel    = "凤凰所食",
		Quality     = "secret",
		Kind        = "herb_infuse",
		ExpAmount   = 105,
		Icon        = "misc/wx_herb_langgan.png",
		Value       = 1120,
		Description = "《海内西经》昆仑山三头人伺守的琅玕碧玉树珠实，唯凤凰食之：乃炼制「山海造化护脉金丹」「紫芝醍醐悟道丹」之造化奇珍，亦可插槽灌注 +105 火候。"
	},
	wx_herb_zhusang = {
		ID          = "wx_herb_zhusang",
		Name        = "空桑冰蚕寒丝雪椹",
		Chapter     = "东山经",
		SubLabel    = "霜雪凝丝",
		Quality     = "secret",
		Kind        = "herb_ward_fire",
		Icon        = "misc/wx_herb_zhusang.png",
		Value       = 950,
		Description = "《东山经》空桑山千年霜雪与冰蚕寒丝裹结的晶白桑椹：可主炼「天山雪莲冰心丹」「透骨寻隙封脉散」，临战吞服令下场战斗免疫毒火灼甲光环并减远伤。"
	},
	wx_herb_panmu = {
		ID          = "wx_herb_panmu",
		Name        = "度索山蟠桃仙枝",
		Chapter     = "海外东经",
		SubLabel    = "万鬼辟易",
		Quality     = "secret",
		Kind        = "herb_qi",
		Icon        = "misc/wx_herb_panmu.png",
		Value       = 980,
		Description = "《山海经》东海度索山盘曲三千里大桃木之向阳花果灵枝，神荼郁垒立于其下：可主炼「天王吊命保心丹」「易筋锻骨丸」，生服令下战内息 +12、回气 +2。"
	},
	wx_herb_fusang = {
		ID          = "wx_herb_fusang",
		Name        = "汤谷十日扶桑赤椹",
		Chapter     = "大荒东经",
		SubLabel    = "十日所浴",
		Quality     = "unique",
		Kind        = "herb_infuse",
		ExpAmount   = 125,
		Icon        = "misc/wx_herb_fusang.png",
		Value       = 1450,
		Description = "《海外东经·大荒东经》汤谷十日沐浴之扶桑神木九千年赤金桑椹，纯阳药力冠绝山海：可主炼「洗髓丹」「易筋锻骨丸」，或直接拖入插槽灌顶 +125 火候！"
	},
	wx_herb_busicao = {
		ID          = "wx_herb_busicao",
		Name        = "员丘不死长生仙草",
		Chapter     = "海外南经",
		SubLabel    = "赤泉长生",
		Quality     = "unique",
		Kind        = "herb_infuse",
		ExpAmount   = 125,
		Icon        = "misc/wx_herb_busicao.png",
		Value       = 1480,
		Description = "《海外南经》员丘赤泉畔不死神树下伴生的金叶玉茎长生仙草：乃炼制「生生造化丹」「神农百草返魂丹」「洗髓丹」的无上圣药，亦可插槽灌顶 +125 火候！"
	},
	wx_herb_jianmu = {
		ID          = "wx_herb_jianmu",
		Name        = "都广天梯建木青叶",
		Chapter     = "海内经",
		SubLabel    = "天地之中",
		Quality     = "unique",
		Kind        = "herb_infuse",
		ExpAmount   = 130,
		Icon        = "misc/wx_herb_jianmu.png",
		Value       = 1520,
		Description = "《海内经》天地之中都广之野众帝上下天梯「建木」的紫茎青叶黄实：禀极致造化药力，可直接主炼天品「太乙紫金洗髓丹」「太虚紫金大丹」，或灌顶 +130 火候！"
	},
	wx_herb_yuegui = {
		ID          = "wx_herb_yuegui",
		Name        = "大荒广寒月桂冰魄花",
		Chapter     = "大荒西经",
		SubLabel    = "太阴月魄",
		Quality     = "unique",
		Kind        = "herb_infuse",
		ExpAmount   = 125,
		Icon        = "misc/wx_herb_yuegui.png",
		Value       = 1450,
		Description = "《大荒西经》日月所入大荒绝巅沐太阴月华万载而开的银桂冰花，至阴涤髓：乃玄阴绝品仙株，可合炼一切冰寒护脉仙丹，或拖入武学插槽灌顶 +125 火候！"
	}
};
