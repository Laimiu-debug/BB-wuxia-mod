// 22 Jianghu & Shan Hai Alchemy Spirit Pills + 17《山海本草》Rare Spirit Herbs
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
		SubLabel    = "清脉辟毒",
		Quality     = "secret",
		Description = "天山寒玉雪莲配冰魄草精炼的清脉宝丹：立即化解「散功虚弱」与「内伤/经脉震荡」，并令下场战斗全程免疫奇毒与夜盲（战后消散）。",
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
		SubLabel    = "百毒不侵",
		Quality     = "sect",
		Description = "百草药庐秘制碧玉解毒丸：战前服食可使下场战斗全程免疫吹箭奇毒与蛛蝎剧毒（一场战斗后消散）。",
		Kind        = "buff_qingxin",
		Icon        = "consumables/wx_pill_qingxin.png",
		Value       = 380
	},
	wx_pill_hugu = {
		ID          = "wx_pill_hugu",
		Name        = "虎骨壮气丸",
		SubLabel    = "备战壮气",
		Quality     = "sect",
		Description = "边塞烈酒浸陈年虎骨炼制的壮气大丸：补满当前受损气血，并令下场战斗临时 +12 内息上限、+2 回气（战后消散）。",
		Kind        = "buff_hugu",
		Icon        = "consumables/wx_pill_hugu.png",
		Value       = 520
	},
	wx_pill_dingshen = {
		ID          = "wx_pill_dingshen",
		Name        = "明目定神散",
		SubLabel    = "镇魂夜战",
		Quality     = "sect",
		Description = "玄门朱砂琥珀研制的清心灵散：令下场战斗临时 +10 定力并免除夜战视野惩罚，专克尸傀鬼啸与夜袭（战后消散）。",
		Kind        = "buff_dingshen",
		Icon        = "consumables/wx_pill_dingshen.png",
		Value       = 480
	},
	wx_pill_zhuyu = {
		ID          = "wx_pill_zhuyu",
		Name        = "祝余辟谷丹",
		SubLabel    = "生生行气",
		Quality     = "secret",
		Description = "采《南山经》招摇祝余仙草炼制的辟谷灵丹：补满受损气血，且下场战斗临时 +16 内息上限、+3 每回合回气（战后消散）。",
		Kind        = "buff_zhuyu",
		Icon        = "consumables/wx_pill_zhuyu.png",
		Value       = 780
	},
	wx_pill_duheng = {
		ID          = "wx_pill_duheng",
		Name        = "杜衡追风丸",
		SubLabel    = "提纵善走",
		Quality     = "secret",
		Description = "采《西山经》天帝杜衡走马草秘炼：下场战斗临时 +18 身法、+5 远防，抢占先手与游斗避矢之良药（战后消散）。",
		Kind        = "buff_duheng",
		Icon        = "consumables/wx_pill_duheng.png",
		Value       = 760
	},
	wx_pill_dixiu = {
		ID          = "wx_pill_dixiu",
		Name        = "帝休定岳丹",
		SubLabel    = "镇心免晕",
		Quality     = "secret",
		Description = "采《中山经》少室帝休黄华枝炼制：服后心如止水，下场战斗临时 +14 定力且免疫震晕击晕（战后消散）。",
		Kind        = "buff_dixiu",
		Icon        = "consumables/wx_pill_dixiu.png",
		Value       = 880
	},
	wx_pill_guiyuan = {
		ID          = "wx_pill_guiyuan",
		Name        = "首乌归元培气丸",
		SubLabel    = "固本培元",
		Quality     = "secret",
		Description = "云梦千年人形首乌配山海兽髓久蒸九晒：恢复 40 点气血，并令下场战斗临时 +18 气血上限、+2 回气（战后消散）。",
		Kind        = "buff_guiyuan",
		Icon        = "consumables/wx_pill_guiyuan.png",
		Value       = 820
	},
	wx_pill_baishe = {
		ID          = "wx_pill_baishe",
		Name        = "五毒百草辟瘴丸",
		SubLabel    = "辟瘴护身",
		Quality     = "secret",
		Description = "半石嘉荣草配五毒异兽腺囊以毒攻毒炼就：下场战斗全程免疫中毒，且近防 +4、远防 +4，专克南疆毒瘴与山海毒妖（战后消散）。",
		Kind        = "buff_baishe",
		Icon        = "consumables/wx_pill_baishe.png",
		Value       = 850
	},
	wx_pill_jinzun = {
		ID          = "wx_pill_jinzun",
		Name        = "金刚铁骨护体丸",
		SubLabel    = "横练护体",
		Quality     = "secret",
		Description = "少室秘传护体金丸，以植楮灵叶与建木灵脂调和：下场战斗所受气血与护甲伤害临时减免 12%，且免疫击退抓取（战后消散）。",
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

// 17《山海本草》Rare Spirit Herbs (craftable into Spirit Pills at 百工炼丹房, or usable raw in emergencies!)
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
	}
};
