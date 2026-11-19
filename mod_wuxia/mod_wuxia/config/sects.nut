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
			{ ManualID = "wx_manual_tiebushan", MinRel = 35, Price = 2200 }
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
	}
};
