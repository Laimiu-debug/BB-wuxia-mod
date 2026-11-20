// Lightweight Sect configurations (stored in World.Flags, zero Faction ID cost)

::Wuxia.Config.Sects <- {
	weiyuan = {
		ID            = "weiyuan",
		Name          = "威远镖局",
		Description   = "以中正内功与护镖枪刀立世的老牌镖局，讲究信用与稳健配合。",
		DefaultRel    = 15,
		ShopManuals   = [
			{ ManualID = "wx_manual_songtao",  MinRel = 15, Price = 1600 },
			{ ManualID = "wx_manual_weiyuan",  MinRel = 25, Price = 2000 },
			{ ManualID = "wx_manual_tiebushan", MinRel = 35, Price = 2200 },
			{ ManualID = "wx_manual_juyiling", MinRel = 40, Price = 2300 }
		],
		VendettaRel   = -50,
		VendettaParty = "wx_weiyuan_escorts"
	},
	qingfeng = {
		ID            = "qingfeng",
		Name          = "清风剑派",
		Description   = "名门正派剑宗，精研阴柔内息、轻身快剑与反击拆招。",
		DefaultRel    = 0,
		ShopManuals   = [
			{ ManualID = "wx_manual_guiyuan",  MinRel = 20, Price = 1900 },
			{ ManualID = "wx_manual_qingfeng", MinRel = 30, Price = 2300 },
			{ ManualID = "wx_manual_gufeng",   MinRel = 35, Price = 2400 },
			{ ManualID = "wx_manual_taxue",    MinRel = 40, Price = 2500 },
			{ ManualID = "wx_manual_jinchan",  MinRel = 45, Price = 2600 }
		],
		VendettaRel   = -35,
		VendettaParty = "wx_qingfeng_hunters"
	},
	heifeng = {
		ID            = "heifeng",
		Name          = "黑风寨 / 血煞帮",
		Description   = "盘踞山险的绿林与邪派合流，崇尚阳刚破甲狂刀、毒暗器与血煞邪功。",
		DefaultRel    = -25,
		ShopManuals   = [
			{ ManualID = "wx_manual_heifeng",  MinRel = 25, Price = 2100 },
			{ ManualID = "wx_manual_baoyu",    MinRel = 45, Price = 3800 },
			{ ManualID = "wx_manual_xuesha",   MinRel = 60, Price = 4800 }
		],
		VendettaRel   = -20,
		VendettaParty = "wx_heifeng_raiders"
	},
	tangmen = {
		ID = "tangmen", Name = "唐家堡", Description = "暗器世家，与前排合击的弩手和施烟的投手同出一门。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_tangmen_skirmishers",
		ShopManuals = [
			{ ManualID = "wx_manual_yanxing", MinRel = 15, Price = 2100 },
			{ ManualID = "wx_manual_baoyu", MinRel = 45, Price = 3800 }
		]
	},
	gaibang = {
		ID = "gaibang", Name = "丐帮", Description = "各地分舵以棍棒守阵，讲究护住身边的同伴与号令聚义。",
		DefaultRel = 5, VendettaRel = -40, VendettaParty = "wx_gaibang_guards",
		ShopManuals = [
			{ ManualID = "wx_manual_chanzi",   MinRel = 0,  Price = 320 },
			{ ManualID = "wx_manual_yingpi",   MinRel = 5,  Price = 350 },
			{ ManualID = "wx_manual_huzhen",   MinRel = 15, Price = 1750 },
			{ ManualID = "wx_manual_juyiling", MinRel = 35, Price = 2300 }
		]
	},
	shaolin = {
		ID = "shaolin", Name = "少室禅院", Description = "中岳古刹武学泰斗，外修罗汉金刚掌指，内修护体硬功，专克披甲悍匪与外门横练。",
		DefaultRel = 5, VendettaRel = -40, VendettaParty = "wx_shaolin_monks",
		ShopManuals = [
			{ ManualID = "wx_manual_luohan",    MinRel = 5,  Price = 340 },
			{ ManualID = "wx_manual_jingang",   MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_tiebushan", MinRel = 35, Price = 2300 },
			{ ManualID = "wx_manual_nianhua",   MinRel = 55, Price = 4600 }
		]
	},
	wudu = {
		ID = "wudu", Name = "五毒奇门", Description = "盘踞南疆密林的奇门毒派，精研吹箭奇毒、烟幕暗器与百毒不侵之术。",
		DefaultRel = -10, VendettaRel = -25, VendettaParty = "wx_wudu_ambushers",
		ShopManuals = [
			{ ManualID = "wx_manual_xiushou", MinRel = 5,  Price = 350 },
			{ ManualID = "wx_manual_wudu",    MinRel = 25, Price = 2300 },
			{ ManualID = "wx_manual_baoyu",   MinRel = 50, Price = 4000 }
		]
	}
};
