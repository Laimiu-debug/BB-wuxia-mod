// 42 Lightweight Jianghu Sects, Martial Clans, Escort Bureaus & Outlaw Halls
// Stored in World.Flags (wx_sect_rel_<id>) -> ZERO engine Faction ID cost (strictly < 64 Faction ID limit!).
// Bound to 6 geographic regions (plains / mountains / forest / swamp / snow / desert) for regional town discovery.

::Wuxia.Config.SectRegions <- {
	plains    = "中原官道",
	mountains = "名山险岳",
	forest    = "巴蜀密林",
	swamp     = "江淮水泽",
	snow      = "关外北境",
	desert    = "西域大漠"
};

::Wuxia.Config.Sects <- {
	// =========================================================================
	// 一、十四大核心武林宗门（Major Sects — 承载各系镇派上乘与绝学）
	// =========================================================================

	shaolin = {
		ID = "shaolin", Name = "少室禅院", Region = "mountains", Alignment = "righteous",
		Description = "中岳古刹武学泰斗，外修罗汉金刚掌指，内修护体硬功，专克披甲悍匪。",
		DefaultRel = 5, VendettaRel = -40, VendettaParty = "wx_shaolin_monks",
		ShopManuals = [
			{ ManualID = "wx_manual_chanzong_zuo", MinRel = 0, Price = 370 },
			{ ManualID = "wx_manual_shaolin_qimeigun", MinRel = 0, Price = 280 },
			{ ManualID = "wx_manual_chanyang_gong", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_shaolin_jiedao", MinRel = 25, Price = 2260 },
			{ ManualID = "wx_manual_shaolin_longzhao", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_shaolin_tongren", MinRel = 25, Price = 2260 },
			{ ManualID = "wx_manual_shaolin_weituogun", MinRel = 25, Price = 2260 },
			{ ManualID = "wx_manual_shaolin_yipiao", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_shaolin_fengmogun", MinRel = 55, Price = 4540 },
			{ ManualID = "wx_manual_shaolin_jinzhong", MinRel = 55, Price = 4630 },
			{ ManualID = "wx_manual_yijin_chan", MinRel = 55, Price = 4660 }
		]
	},
	taihe = {
		ID = "taihe", Name = "太和玄门", Region = "mountains", Alignment = "righteous",
		Description = "丹江云顶道门祖庭，尚冲和自然、以柔克刚，所传《太和纯阳功》冠绝玄门。",
		DefaultRel = 5, VendettaRel = -40, VendettaParty = "wx_qingfeng_hunters",
		ShopManuals = [
			{ ManualID = "wx_manual_zuowang_tu", MinRel = 0, Price = 400 },
			{ ManualID = "wx_manual_taihe_liangyi", MinRel = 25, Price = 2260 },
			{ ManualID = "wx_manual_taihe_mianjin", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_taihe_mianzhang", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_taihe_xuanxu", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_taihe_yunbu", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_jiutian_fuyao", MinRel = 55, Price = 4540 },
			{ ManualID = "wx_manual_taiji_zhenjian", MinRel = 55, Price = 4630 }
		]
	},
	qingfeng = {
		ID = "qingfeng", Name = "清风剑派", Region = "mountains", Alignment = "righteous",
		Description = "名门正派剑宗，精研阴柔内息、轻身快剑与反击拆招。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_qingfeng_hunters",
		ShopManuals = [
			{ ManualID = "wx_manual_gufeng", MinRel = 25, Price = 2400 },
			{ ManualID = "wx_manual_guiyuan", MinRel = 25, Price = 1900 },
			{ ManualID = "wx_manual_qingfeng", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_taxue", MinRel = 25, Price = 2400 },
			{ ManualID = "wx_manual_huifeng", MinRel = 55, Price = 4500 },
			{ ManualID = "wx_manual_qingfeng_liufeng", MinRel = 55, Price = 4570 }
		]
	},
	tangmen = {
		ID = "tangmen", Name = "蜀中唐家堡", Region = "forest", Alignment = "neutral",
		Description = "巴蜀机关暗器世家，弩箭合击与暴雨毒针令江湖闻风丧胆。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_tangmen_skirmishers",
		ShopManuals = [
			{ ManualID = "wx_manual_tangmen_duxin", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_tangmen_guiying", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_tangmen_liannu", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_tangmen_mantian", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_tangmen_guanyin_lei", MinRel = 55, Price = 4660 },
			{ ManualID = "wx_manual_tangmen_liuxing", MinRel = 55, Price = 4570 },
			{ ManualID = "wx_manual_tangmen_qimen", MinRel = 55, Price = 4540 }
		]
	},
	wudu = {
		ID = "wudu", Name = "南疆五毒奇门", Region = "swamp", Alignment = "outlaw",
		Description = "盘踞南疆密林毒泽的奇门毒派，精研吹箭奇毒、烟幕暗器与百毒不侵之术。",
		DefaultRel = -10, VendettaRel = -25, VendettaParty = "wx_wudu_ambushers",
		ShopManuals = [
			{ ManualID = "wx_manual_xiushou", MinRel = 0, Price = 350 },
			{ ManualID = "wx_manual_wudu_chuijian", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_wudu_qianzhu", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_wudu_shehang", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_wudu_zhangqi", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_wudu_jinshe_bian", MinRel = 55, Price = 4660 },
			{ ManualID = "wx_manual_wudu_wanxian", MinRel = 55, Price = 4570 }
		]
	},
	gaibang = {
		ID = "gaibang", Name = "天下丐帮", Region = "plains", Alignment = "righteous",
		Description = "九州南北分舵遍布的第一大帮，以棍棒守阵、缠斗合围与聚义号令闻达天下。",
		DefaultRel = 5, VendettaRel = -40, VendettaParty = "wx_gaibang_guards",
		ShopManuals = [
			{ ManualID = "wx_manual_chanzi", MinRel = 0, Price = 320 },
			{ ManualID = "wx_manual_zui_babu", MinRel = 0, Price = 370 },
			{ ManualID = "wx_manual_gaibang_lianhua", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_huzhen", MinRel = 25, Price = 1750 },
			{ ManualID = "wx_manual_gaibang_qingou", MinRel = 55, Price = 4540 },
			{ ManualID = "wx_manual_gaibang_qinlong", MinRel = 55, Price = 4660 },
			{ ManualID = "wx_manual_gaibang_xianglong", MinRel = 55, Price = 4540 }
		]
	},
	weiyuan = {
		ID = "weiyuan", Name = "威远总镖局", Region = "plains", Alignment = "righteous",
		Description = "通达南北九省的老字号总镖局，讲究枪阵守线、硬功护体与总镖头号令。",
		DefaultRel = 15, VendettaRel = -50, VendettaParty = "wx_weiyuan_escorts",
		ShopManuals = [
			{ ManualID = "wx_manual_zhanma_tongpao", MinRel = 0, Price = 310 },
			{ ManualID = "wx_manual_juyiling", MinRel = 25, Price = 2300 },
			{ ManualID = "wx_manual_songtao", MinRel = 25, Price = 1800 },
			{ ManualID = "wx_manual_tiebushan", MinRel = 25, Price = 2500 },
			{ ManualID = "wx_manual_weiyuan", MinRel = 25, Price = 2000 },
			{ ManualID = "wx_manual_yaqi_zhenzhen", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_weiyuan_zhenbiao", MinRel = 55, Price = 4540 },
			{ ManualID = "wx_manual_wuwei_shuaiqi", MinRel = 55, Price = 4660 }
		]
	},
	heifeng = {
		ID = "heifeng", Name = "黑风血煞宗", Region = "mountains", Alignment = "outlaw",
		Description = "盘踞荒山险寨的绿林与邪派总盟，崇尚破甲狂刀、炼体金钟与血煞吞元邪功。",
		DefaultRel = -25, VendettaRel = -20, VendettaParty = "wx_heifeng_raiders",
		ShopManuals = [
			{ ManualID = "wx_manual_shixue_kuang", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_heifeng", MinRel = 25, Price = 2100 },
			{ ManualID = "wx_manual_duanyue", MinRel = 55, Price = 4600 },
			{ ManualID = "wx_manual_heifeng_xuedao", MinRel = 55, Price = 4630 },
			{ ManualID = "wx_manual_jinzhong", MinRel = 55, Price = 4900 },
			{ ManualID = "wx_manual_xuesha", MinRel = 55, Price = 4800 }
		]
	},
	shenji = {
		ID = "shenji", Name = "神机火器营", Region = "desert", Alignment = "neutral",
		Description = "边镇工部匠师与退伍神机千总私建的火器堂口，精研三眼火铳、神臂强弩与震雷弹。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_shenji_gunners",
		ShopManuals = [
			{ ManualID = "wx_manual_junzhong_jin_nu", MinRel = 0, Price = 310 },
			{ ManualID = "wx_manual_juyiling", MinRel = 25, Price = 2300 },
			{ ManualID = "wx_manual_shenji", MinRel = 25, Price = 2400 },
			{ ManualID = "wx_manual_shenji_huoyao", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_yanxing", MinRel = 25, Price = 2100 },
			{ ManualID = "wx_manual_shenji_huolong", MinRel = 55, Price = 4660 }
		]
	},
	pishan = {
		ID = "pishan", Name = "辽东劈山盟", Region = "snow", Alignment = "neutral",
		Description = "关外林海樵客与边军猛士结成的巨斧同盟，一柄开山大斧专碎盾墙铁阵。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_pishan_axemen",
		ShopManuals = [
			{ ManualID = "wx_manual_fumu_qiaofu", MinRel = 0, Price = 280 },
			{ ManualID = "wx_manual_kaishan_fu", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_pishan_fu", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_pishan_xuanfeng", MinRel = 25, Price = 2260 },
			{ ManualID = "wx_manual_tiebushan", MinRel = 25, Price = 2500 },
			{ ManualID = "wx_manual_pishan_kaitian", MinRel = 55, Price = 4630 }
		]
	},
	zhenyue = {
		ID = "zhenyue", Name = "太行震岳门", Region = "mountains", Alignment = "neutral",
		Description = "太行绝壁之上锤炼千钧神力的重锤宗门，锤风过处重甲俱裂。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_zhenyue_hammers",
		ShopManuals = [
			{ ManualID = "wx_manual_hanshan_chui", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_zhenyue_bapi", MinRel = 25, Price = 2260 },
			{ ManualID = "wx_manual_zhenyue_chui", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_jinzhong", MinRel = 55, Price = 4900 },
			{ ManualID = "wx_manual_zhenyue_qianjun", MinRel = 55, Price = 4540 }
		]
	},
	jiujie = {
		ID = "jiujie", Name = "云梦软鞭门", Region = "swamp", Alignment = "neutral",
		Description = "云梦大泽奇兵门派，门人惯使九节软鞭与三首流星锤，专克持盾守卫。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_jiujie_whips",
		ShopManuals = [
			{ ManualID = "wx_manual_chanzi", MinRel = 0, Price = 320 },
			{ ManualID = "wx_manual_chansi_bian", MinRel = 25, Price = 2150 },
			{ ManualID = "wx_manual_jiujie_liuxing", MinRel = 25, Price = 2260 },
			{ ManualID = "wx_manual_taxue", MinRel = 25, Price = 2400 },
			{ ManualID = "wx_manual_jiujie_panlong_bian", MinRel = 55, Price = 4630 }
		]
	},
	yinsha = {
		ID = "yinsha", Name = "幽冥隐杀楼", Region = "desert", Alignment = "outlaw",
		Description = "大漠鬼市背后的金牌刺客组织，精修短匕透甲绝杀与缩地夜行身法。",
		DefaultRel = -10, VendettaRel = -30, VendettaParty = "wx_yinsha_assassins",
		ShopManuals = [
			{ ManualID = "wx_manual_anxiang_bici", MinRel = 0, Price = 370 },
			{ ManualID = "wx_manual_fenshui_ci", MinRel = 0, Price = 350 },
			{ ManualID = "wx_manual_yeying_biqi", MinRel = 0, Price = 310 },
			{ ManualID = "wx_manual_jinchan", MinRel = 25, Price = 2500 },
			{ ManualID = "wx_manual_suodi", MinRel = 55, Price = 4500 },
			{ ManualID = "wx_manual_yinsha_guixi", MinRel = 55, Price = 4600 },
			{ ManualID = "wx_manual_youming_guibu", MinRel = 55, Price = 4630 }
		]
	},
	xuanbing = {
		ID = "xuanbing", Name = "昆仑玄冰宫", Region = "snow", Alignment = "neutral",
		Description = "极北雪峰之巅的隐世寒宗，以内修《寒冰护脉诀》、外踏飞雪轻身步闻名。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_qingfeng_hunters",
		ShopManuals = [
			{ ManualID = "wx_manual_hanbing", MinRel = 25, Price = 2000 },
			{ ManualID = "wx_manual_xuanbing_feixue", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_tianchan_yi", MinRel = 55, Price = 4540 },
			{ ManualID = "wx_manual_xuanbing_hanhong", MinRel = 55, Price = 4570 },
			{ ManualID = "wx_manual_xuanbing_hanjian", MinRel = 55, Price = 4660 },
			{ ManualID = "wx_manual_xuanbing_hanzhang", MinRel = 55, Price = 4570 },
			{ ManualID = "wx_manual_xuannv_bing", MinRel = 55, Price = 4540 }
		]
	},

	// =========================================================================
	// 二、二十八方地域世家、行当帮会与绿林邪道（Regional Clans, Guilds & Outlaw Halls）
	// =========================================================================

	// --- 中原官道 (Plains: +6) ---
	luoyang_biao = {
		ID = "luoyang_biao", Name = "洛阳长风镖局", Region = "plains", Alignment = "righteous",
		Description = "雄踞洛阳水陆码头的名门镖局，以快马轻枪与稳健吐纳护送皇纲重宝。",
		DefaultRel = 10, VendettaRel = -45, VendettaParty = "wx_weiyuan_escorts",
		ShopManuals = [
			{ ManualID = "wx_manual_jianbu", MinRel = 0, Price = 320 },
			{ ManualID = "wx_manual_luoyang_kuaiqiang", MinRel = 0, Price = 280 },
			{ ManualID = "wx_manual_shilin_yingzhao", MinRel = 0, Price = 370 },
			{ ManualID = "wx_manual_shuyuan_junzijian", MinRel = 0, Price = 400 },
			{ ManualID = "wx_manual_luoyang_changfeng", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_luoyang_panlong", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_luoyang_zongma", MinRel = 25, Price = 2230 }
		]
	},
	zhongzhou_wuguan = {
		ID = "zhongzhou_wuguan", Name = "中州振武堂", Region = "plains", Alignment = "neutral",
		Description = "开封城内规模最大的民间武馆联盟，广授各路入门枪刀拳剑与固本桩功。",
		DefaultRel = 10, VendettaRel = -45, VendettaParty = "wx_gaibang_guards",
		ShopManuals = [
			{ ManualID = "wx_manual_jianghu_feibiao", MinRel = 0, Price = 370 },
			{ ManualID = "wx_manual_jichujian", MinRel = 0, Price = 350 },
			{ ManualID = "wx_manual_shaozi_gun", MinRel = 0, Price = 310 },
			{ ManualID = "wx_manual_zhongzhou_changquan", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_zhongzhou_peijian", MinRel = 0, Price = 400 },
			{ ManualID = "wx_manual_zhongzhou_wulang_gun", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_zhongzhou_wuzong", MinRel = 25, Price = 2170 }
		]
	},
	hebei_qiang = {
		ID = "hebei_qiang", Name = "河北神枪崔家", Region = "plains", Alignment = "righteous",
		Description = "世代将门演武传家的枪法大族，家传枪阵最擅卡位拦截突骑。",
		DefaultRel = 5, VendettaRel = -35, VendettaParty = "wx_weiyuan_escorts",
		ShopManuals = [
			{ ManualID = "wx_manual_liuheqiang", MinRel = 0, Price = 350 },
			{ ManualID = "wx_manual_hebei_cuijia", MinRel = 25, Price = 2260 },
			{ ManualID = "wx_manual_juyiling", MinRel = 25, Price = 2300 },
			{ ManualID = "wx_manual_weiyuan", MinRel = 25, Price = 2000 },
			{ ManualID = "wx_manual_cuijia_liuhua", MinRel = 55, Price = 4570 },
			{ ManualID = "wx_manual_babao_liangyinqiang", MinRel = 55, Price = 4680 }
		]
	},
	xinglin_yi = {
		ID = "xinglin_yi", Name = "杏林济世堂", Region = "plains", Alignment = "righteous",
		Description = "悬壶济世的游方郎中与药师行会，深谙经脉护心、龟息保命与调息养元之术。",
		DefaultRel = 15, VendettaRel = -50, VendettaParty = "wx_weiyuan_escorts",
		ShopManuals = [
			{ ManualID = "wx_manual_guixi", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_shijing_bodao", MinRel = 0, Price = 400 },
			{ ManualID = "wx_manual_tuna", MinRel = 0, Price = 300 },
			{ ManualID = "wx_manual_yangsheng_jue", MinRel = 0, Price = 280 },
			{ ManualID = "wx_manual_songtao", MinRel = 25, Price = 1800 },
			{ ManualID = "wx_manual_xinglin_bencao", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_xinglin_jinshen", MinRel = 25, Price = 2200 }
		]
	},
	huaiyang_dao = {
		ID = "huaiyang_dao", Name = "淮阳金刀门", Region = "plains", Alignment = "neutral",
		Description = "中原豪商巨贾重金供奉的刀客门户，门风讲究快刀立威、单手空拳潇洒破甲。",
		DefaultRel = 5, VendettaRel = -35, VendettaParty = "wx_heifeng_raiders",
		ShopManuals = [
			{ ManualID = "wx_manual_wuhudao", MinRel = 0, Price = 350 },
			{ ManualID = "wx_manual_gufeng", MinRel = 25, Price = 2400 },
			{ ManualID = "wx_manual_heifeng", MinRel = 25, Price = 2100 },
			{ ManualID = "wx_manual_huaiyang_jindao", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_huaiyang_kuanglan", MinRel = 55, Price = 4600 }
		]
	},
	baima_yi = {
		ID = "baima_yi", Name = "白马义从营", Region = "plains", Alignment = "righteous",
		Description = "由退伍边镇精骑结成的巡路义社，长于步弓掩射与战阵号令配合。",
		DefaultRel = 5, VendettaRel = -40, VendettaParty = "wx_tangmen_skirmishers",
		ShopManuals = [
			{ ManualID = "wx_manual_junzhong_jixing", MinRel = 0, Price = 400 },
			{ ManualID = "wx_manual_baima_lianzhugong", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_baima_yinqiang", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_baima_zhenshu", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_juyiling", MinRel = 25, Price = 2300 },
			{ ManualID = "wx_manual_baima_luori_jian", MinRel = 55, Price = 4630 },
			{ ManualID = "wx_manual_pojun_shenji", MinRel = 55, Price = 4540 }
		]
	},

	// --- 名山险岳 (Mountains: +5) ---
	songyang_jian = {
		ID = "songyang_jian", Name = "嵩阳铁剑门", Region = "mountains", Alignment = "neutral",
		Description = "崇尚重剑无锋、硬桥硬马的嵩山支脉，剑路刚猛直取中宫。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_qingfeng_hunters",
		ShopManuals = [
			{ ManualID = "wx_manual_jichujian", MinRel = 0, Price = 350 },
			{ ManualID = "wx_manual_songyang_tiejian_ru", MinRel = 0, Price = 370 },
			{ ManualID = "wx_manual_qingfeng", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_songyang_gang", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_songyang_zhongjian", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_tiebushan", MinRel = 25, Price = 2500 }
		]
	},
	taihang_zhai = {
		ID = "taihang_zhai", Name = "太行十八寨", Region = "mountains", Alignment = "outlaw",
		Description = "扼守太行陉道的绿林连环山寨，寨丁擅长乱斧劈山与合围缠斗。",
		DefaultRel = -15, VendettaRel = -30, VendettaParty = "wx_pishan_axemen",
		ShopManuals = [
			{ ManualID = "wx_manual_chanzi", MinRel = 0, Price = 320 },
			{ ManualID = "wx_manual_kaishan_fu", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_qunjia_ce", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_taihang_luanfu", MinRel = 0, Price = 400 },
			{ ManualID = "wx_manual_pishan_fu", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_taihang_duanhun_fu", MinRel = 25, Price = 2230 }
		]
	},
	huashan_qi = {
		ID = "huashan_qi", Name = "西岳紫霞观", Region = "mountains", Alignment = "righteous",
		Description = "西岳奇险峰顶的炼气剑宗，以内养绵长紫气、外使孤锋回风快剑著称。",
		DefaultRel = 5, VendettaRel = -35, VendettaParty = "wx_qingfeng_hunters",
		ShopManuals = [
			{ ManualID = "wx_manual_gufeng", MinRel = 25, Price = 2400 },
			{ ManualID = "wx_manual_huashan_duoming", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_songtao", MinRel = 25, Price = 1800 },
			{ ManualID = "wx_manual_zixia_gong", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_dugu_pojian", MinRel = 55, Price = 4600 },
			{ ManualID = "wx_manual_huifeng", MinRel = 55, Price = 4500 },
			{ ManualID = "wx_manual_zixia_shen", MinRel = 55, Price = 4600 }
		]
	},
	hengshan_yi = {
		ID = "hengshan_yi", Name = "北岳守塞堂", Region = "mountains", Alignment = "righteous",
		Description = "驻守恒山隘口抗击马贼的苦修门户，擅长重锤破甲与守线枪法。",
		DefaultRel = 5, VendettaRel = -40, VendettaParty = "wx_zhenyue_hammers",
		ShopManuals = [
			{ ManualID = "wx_manual_hanshan_chui", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_junying_changmao", MinRel = 0, Price = 370 },
			{ ManualID = "wx_manual_pijia_zhuang", MinRel = 0, Price = 370 },
			{ ManualID = "wx_manual_hengshan_polu_chui", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_hengshan_shouguan", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_hengshan_tiebi", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_weiyuan", MinRel = 25, Price = 2000 },
			{ ManualID = "wx_manual_taiyuan_huoyandao", MinRel = 55, Price = 4680 }
		]
	},
	zhongnan_yin = {
		ID = "zhongnan_yin", Name = "终南活死人庐", Region = "mountains", Alignment = "neutral",
		Description = "隐于终南古墓幽林的清修奇人，专研龟息闭气、阴柔真气与轻灵步法。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_qingfeng_hunters",
		ShopManuals = [
			{ ManualID = "wx_manual_guixi", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_guiyuan", MinRel = 25, Price = 1900 },
			{ ManualID = "wx_manual_taxue", MinRel = 25, Price = 2400 },
			{ ManualID = "wx_manual_zhongnan_bi", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_zhongnan_feiyan", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_zhongnan_yunv", MinRel = 25, Price = 2200 }
		]
	},

	// --- 巴蜀密林 (Forest: +5) ---
	qingcheng_guan = {
		ID = "qingcheng_guan", Name = "青城幽谷观", Region = "forest", Alignment = "neutral",
		Description = "深藏川西幽林的道家剑观，剑走偏锋迅捷诡奇，尤擅分水短刺与轻身游斗。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_yinsha_assassins",
		ShopManuals = [
			{ ManualID = "wx_manual_fenshui_ci", MinRel = 0, Price = 350 },
			{ ManualID = "wx_manual_qingcheng_kuaijian", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_shanlin_bu", MinRel = 0, Price = 370 },
			{ ManualID = "wx_manual_qingcheng_meipiao", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_qingcheng_songfeng", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_qingcheng_xuan", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_qingcheng_yingci", MinRel = 55, Price = 4570 }
		]
	},
	emei_ci = {
		ID = "emei_ci", Name = "峨眉金顶庵", Region = "forest", Alignment = "righteous",
		Description = "秀甲天下的蜀中禅门，兼修阴柔护体心法、点穴掌指与灵巧剑式。",
		DefaultRel = 5, VendettaRel = -40, VendettaParty = "wx_shaolin_monks",
		ShopManuals = [
			{ ManualID = "wx_manual_emei_chanyun", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_emei_dianxue", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_emei_huaying", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_emei_linji", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_emei_piaoxue", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_guiyuan", MinRel = 25, Price = 1900 },
			{ ManualID = "wx_manual_emei_mie_jian", MinRel = 55, Price = 4600 }
		]
	},
	bashu_yanbang = {
		ID = "bashu_yanbang", Name = "川江袍哥盐帮", Region = "forest", Alignment = "neutral",
		Description = "把持巴蜀盐井与纤夫水码头的义气帮会，重情护短，惯使齐眉棒与护脉硬功。",
		DefaultRel = 5, VendettaRel = -35, VendettaParty = "wx_gaibang_guards",
		ShopManuals = [
			{ ManualID = "wx_manual_jinzhong_rumen", MinRel = 0, Price = 370 },
			{ ManualID = "wx_manual_paoge_kuaidao", MinRel = 0, Price = 400 },
			{ ManualID = "wx_manual_qianfu_bang", MinRel = 0, Price = 280 },
			{ ManualID = "wx_manual_yingpi", MinRel = 0, Price = 320 },
			{ ManualID = "wx_manual_bashu_huzhen", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_bashu_zhenjiang_bang", MinRel = 25, Price = 2260 },
			{ ManualID = "wx_manual_huzhen", MinRel = 25, Price = 1750 }
		]
	},
	lingnan_tengpai = {
		ID = "lingnan_tengpai", Name = "岭南藤牌悍卒营", Region = "forest", Alignment = "neutral",
		Description = "常年在南岭密林抗击毒蛟山匪的藤牌短刀劲旅，最擅密林行军与刀盾缠斗。",
		DefaultRel = 5, VendettaRel = -35, VendettaParty = "wx_heifeng_raiders",
		ShopManuals = [
			{ ManualID = "wx_manual_jianbu", MinRel = 0, Price = 320 },
			{ ManualID = "wx_manual_lingnan_duandao", MinRel = 0, Price = 370 },
			{ ManualID = "wx_manual_tengpai_shu", MinRel = 0, Price = 280 },
			{ ManualID = "wx_manual_wuhudao", MinRel = 0, Price = 350 },
			{ ManualID = "wx_manual_lingnan_tengdun", MinRel = 25, Price = 2260 },
			{ ManualID = "wx_manual_lingnan_zhandao", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_lingnan_xuandun", MinRel = 55, Price = 4600 }
		]
	},
	wuyishan_cha = {
		ID = "wuyishan_cha", Name = "武夷碧水轩", Region = "forest", Alignment = "righteous",
		Description = "闽北茶山武林隐族，门下子弟身轻如燕，精熟卸力巧劲与林间掩射。",
		DefaultRel = 5, VendettaRel = -40, VendettaParty = "wx_tangmen_skirmishers",
		ShopManuals = [
			{ ManualID = "wx_manual_jianbu", MinRel = 0, Price = 320 },
			{ ManualID = "wx_manual_nuannuo_bu", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_jinchan", MinRel = 25, Price = 2500 },
			{ ManualID = "wx_manual_wuyi_bixue", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_wuyi_chaxin", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_wuyi_chuanlin_jian", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_wuyi_tingfeng", MinRel = 25, Price = 2200 }
		]
	},

	// --- 江淮水泽 (Swamp: +5) ---
	gusumu = {
		ID = "gusumu", Name = "姑苏慕氏剑庄", Region = "swamp", Alignment = "neutral",
		Description = "太湖烟波中的江南百年武学世家，博采众长，尤精回锋拆招与孤锋快剑。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_qingfeng_hunters",
		ShopManuals = [
			{ ManualID = "wx_manual_gufeng", MinRel = 25, Price = 2400 },
			{ ManualID = "wx_manual_gusumu_canhe", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_gusumu_nei", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_qingfeng", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_gusumu_canhezhi", MinRel = 55, Price = 4570 },
			{ ManualID = "wx_manual_gusumu_douzhuan", MinRel = 55, Price = 4600 },
			{ ManualID = "wx_manual_huifeng", MinRel = 55, Price = 4500 }
		]
	},
	qianjiang_bang = {
		ID = "qianjiang_bang", Name = "钱塘怒潮帮", Region = "swamp", Alignment = "neutral",
		Description = "盘踞浙东海塘与盐场的大帮，帮众赤膊练桩、掌风浑猛如钱塘大潮。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_shaolin_monks",
		ShopManuals = [
			{ ManualID = "wx_manual_chaoxi_xin", MinRel = 0, Price = 370 },
			{ ManualID = "wx_manual_luohan", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_qianjiang_kaibei", MinRel = 0, Price = 310 },
			{ ManualID = "wx_manual_xingqi", MinRel = 0, Price = 320 },
			{ ManualID = "wx_manual_jingang", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_qianjiang_chao", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_qianjiang_nuchao_zhang", MinRel = 25, Price = 2200 }
		]
	},
	dongting_shuizhai = {
		ID = "dongting_shuizhai", Name = "洞庭连环水寨", Region = "swamp", Alignment = "outlaw",
		Description = "八百里洞庭芦苇荡中的绿林水寇总寨，精熟分水蛾眉刺与软鞭锁拿。",
		DefaultRel = -10, VendettaRel = -28, VendettaParty = "wx_jiujie_whips",
		ShopManuals = [
			{ ManualID = "wx_manual_chanzi", MinRel = 0, Price = 320 },
			{ ManualID = "wx_manual_fenshui_ci", MinRel = 0, Price = 350 },
			{ ManualID = "wx_manual_shuishang_piao", MinRel = 0, Price = 400 },
			{ ManualID = "wx_manual_shuixi_gong", MinRel = 0, Price = 400 },
			{ ManualID = "wx_manual_dongting_fenjiang_cha", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_dongting_langdao", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_dongting_shuijiao_bian", MinRel = 25, Price = 2260 }
		]
	},
	kuaiji_duanren = {
		ID = "kuaiji_duanren", Name = "会稽鱼肠剑庐", Region = "swamp", Alignment = "neutral",
		Description = "秉承越女与欧冶遗风的铸匕名庐，专研三寸短刃破甲穿心之术。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_yinsha_assassins",
		ShopManuals = [
			{ ManualID = "wx_manual_fenshui_ci", MinRel = 0, Price = 350 },
			{ ManualID = "wx_manual_gufeng", MinRel = 25, Price = 2400 },
			{ ManualID = "wx_manual_kuaiji_duanjian", MinRel = 25, Price = 2260 },
			{ ManualID = "wx_manual_kuaiji_yuchang_ci", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_kuaiji_zhuanzhu", MinRel = 55, Price = 4630 },
			{ ManualID = "wx_manual_youming_bi", MinRel = 55, Price = 4600 },
			{ ManualID = "wx_manual_yuchang_cisha", MinRel = 55, Price = 4540 }
		]
	},
	xiangxi_ganshi = {
		ID = "xiangxi_ganshi", Name = "湘西辰州符水门", Region = "swamp", Alignment = "outlaw",
		Description = "行走湘西瘴雾荒冢间的奇门方士，既通御毒辟瘴，亦懂克制行尸怨灵之法。",
		DefaultRel = -5, VendettaRel = -30, VendettaParty = "wx_wudu_ambushers",
		ShopManuals = [
			{ ManualID = "wx_manual_duzhang_bi", MinRel = 0, Price = 280 },
			{ ManualID = "wx_manual_guixi", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_poxie_fushui", MinRel = 0, Price = 280 },
			{ ManualID = "wx_manual_hanbing", MinRel = 25, Price = 2000 },
			{ ManualID = "wx_manual_xiangxi_ganhun_bian", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_xiangxi_ganling", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_xiangxi_shiyin", MinRel = 25, Price = 2170 }
		]
	},

	// --- 关外北境 (Snow: +4) ---
	changbai_shen = {
		ID = "changbai_shen", Name = "长白采参客帮", Region = "snow", Alignment = "righteous",
		Description = "结伴深入林海雪原寻觅老山参异材的把头行帮，最擅雪地健步与护脉内功。",
		DefaultRel = 10, VendettaRel = -45, VendettaParty = "wx_pishan_axemen",
		ShopManuals = [
			{ ManualID = "wx_manual_caishen_nuannu", MinRel = 0, Price = 400 },
			{ ManualID = "wx_manual_changbai_liecha", MinRel = 0, Price = 400 },
			{ ManualID = "wx_manual_guixi", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_jianbu", MinRel = 0, Price = 320 },
			{ ManualID = "wx_manual_shanlin_liegong", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_xueyuan_zong", MinRel = 0, Price = 280 },
			{ ManualID = "wx_manual_changbai_xuelong", MinRel = 55, Price = 4540 }
		]
	},
	heishui_tieqi = {
		ID = "heishui_tieqi", Name = "黑水战帮盟", Region = "snow", Alignment = "outlaw",
		Description = "苦寒黑水流域的悍勇猎手与重斧武夫部落，崇尚以血换命的狂猛劈杀。",
		DefaultRel = -10, VendettaRel = -28, VendettaParty = "wx_pishan_axemen",
		ShopManuals = [
			{ ManualID = "wx_manual_xingqi", MinRel = 0, Price = 320 },
			{ ManualID = "wx_manual_heishui_kuangfu", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_heishui_xiongzhao", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_heishui_xue", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_heishui_zhandao", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_pishan_fu", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_heishui_xueming_fu", MinRel = 55, Price = 4630 }
		]
	},
	yanmen_jun = {
		ID = "yanmen_jun", Name = "雁门戍边义勇", Region = "snow", Alignment = "righteous",
		Description = "九边重镇退伍老兵与边民自发结成的守关义军，精通铁布衫、强弩与聚义军令。",
		DefaultRel = 10, VendettaRel = -45, VendettaParty = "wx_weiyuan_escorts",
		ShopManuals = [
			{ ManualID = "wx_manual_junwu_nei", MinRel = 0, Price = 310 },
			{ ManualID = "wx_manual_pojia_changbing", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_yanyun_zhandao", MinRel = 0, Price = 310 },
			{ ManualID = "wx_manual_yanmen_fangtian", MinRel = 25, Price = 2170 },
			{ ManualID = "wx_manual_yaqi_zhenzhen", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_yanmen_poche_fu", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_yanmen_podao", MinRel = 55, Price = 4600 },
			{ ManualID = "wx_manual_yanmen_zhenjun", MinRel = 55, Price = 4540 }
		]
	},
	shuofang_chui = {
		ID = "shuofang_chui", Name = "朔方金瓜力士堂", Region = "snow", Alignment = "neutral",
		Description = "西北与北境交界专练双锤破甲的外门武馆，门徒个个膀大腰圆、力能扛鼎。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_zhenyue_hammers",
		ShopManuals = [
			{ ManualID = "wx_manual_hanshan_chui", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_tiejiang_duanchui", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_tongtou_gong", MinRel = 0, Price = 280 },
			{ ManualID = "wx_manual_yingpi", MinRel = 0, Price = 320 },
			{ ManualID = "wx_manual_shuofang_jingua", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_zhenyue_chui", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_shuofang_leishen", MinRel = 55, Price = 4570 }
		]
	},
	mobei_canglang = {
		ID = "mobei_canglang", Name = "漠北苍狼部", Region = "snow", Alignment = "outlaw",
		Description = "逐水草而居的塞北游猎骑射部族，善使硬弓合击与九节马鞭套索。",
		DefaultRel = -5, VendettaRel = -30, VendettaParty = "wx_jiujie_whips",
		ShopManuals = [
			{ ManualID = "wx_manual_mabei_changbian", MinRel = 0, Price = 400 },
			{ ManualID = "wx_manual_chansi_bian", MinRel = 25, Price = 2150 },
			{ ManualID = "wx_manual_mobei_diaoling_gong", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_mobei_langben", MinRel = 25, Price = 2200 },
			{ ManualID = "wx_manual_mobei_taoma_bian", MinRel = 25, Price = 2260 },
			{ ManualID = "wx_manual_yanxing", MinRel = 25, Price = 2100 },
			{ ManualID = "wx_manual_mobei_langwang_she", MinRel = 55, Price = 4660 }
		]
	},

	// --- 西域大漠 (Desert: +4) ---
	mingzun_jiao = {
		ID = "mingzun_jiao", Name = "西域圣火明尊教", Region = "desert", Alignment = "neutral",
		Description = "自波斯大漠东传的神秘大教，圣火心法诡奇炽烈，护教法王兼具挪移轻身与护体神功。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_yinsha_assassins",
		ShopManuals = [
			{ ManualID = "wx_manual_jinchan", MinRel = 25, Price = 2500 },
			{ ManualID = "wx_manual_mingzun_huo", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_mingzun_shenghuoling", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_mingzun_nuoyi", MinRel = 55, Price = 4660 },
			{ ManualID = "wx_manual_mingzun_qishang", MinRel = 55, Price = 4660 },
			{ ManualID = "wx_manual_shenghuo_zong", MinRel = 55, Price = 4570 },
			{ ManualID = "wx_manual_suodi", MinRel = 55, Price = 4500 }
		]
	},
	hanhai_dao = {
		ID = "hanhai_dao", Name = "瀚海弯刀盟", Region = "desert", Alignment = "outlaw",
		Description = "横行大漠绿洲商道的马帮刀客联盟，弯刀如新月掠沙，最擅追亡逐北一刀断岳。",
		DefaultRel = -10, VendettaRel = -28, VendettaParty = "wx_heifeng_raiders",
		ShopManuals = [
			{ ManualID = "wx_manual_hanhai_wandao_ru", MinRel = 0, Price = 310 },
			{ ManualID = "wx_manual_wuhudao", MinRel = 0, Price = 350 },
			{ ManualID = "wx_manual_hanhai_guke", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_hanhai_xinyue", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_heifeng", MinRel = 25, Price = 2100 },
			{ ManualID = "wx_manual_duanyue", MinRel = 55, Price = 4600 },
			{ ManualID = "wx_manual_hanhai_shishen", MinRel = 55, Price = 4600 }
		]
	},
	shazhou_tuobang = {
		ID = "shazhou_tuobang", Name = "沙州驼铃商帮", Region = "desert", Alignment = "neutral",
		Description = "往返玉门关与西域诸城的豪商护卫团，兼收火铳、暗器与流沙行军秘术。",
		DefaultRel = 10, VendettaRel = -45, VendettaParty = "wx_shenji_gunners",
		ShopManuals = [
			{ ManualID = "wx_manual_bianzhen_huochong", MinRel = 0, Price = 310 },
			{ ManualID = "wx_manual_jianbu", MinRel = 0, Price = 320 },
			{ ManualID = "wx_manual_kuaishou_nang", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_liesha_tuna", MinRel = 0, Price = 340 },
			{ ManualID = "wx_manual_liusha_bu", MinRel = 0, Price = 400 },
			{ ManualID = "wx_manual_xiushou", MinRel = 0, Price = 350 },
			{ ManualID = "wx_manual_shazhou_leihuo_chong", MinRel = 25, Price = 2230 }
		]
	},
	loulan_mojin = {
		ID = "loulan_mojin", Name = "楼兰摸金商会", Region = "desert", Alignment = "neutral",
		Description = "专在瀚海流沙古国废墟发丘探宝的冒险行帮，精熟破墓重锤、分水刺与辟邪古卷。",
		DefaultRel = 0, VendettaRel = -35, VendettaParty = "wx_zhenyue_hammers",
		ShopManuals = [
			{ ManualID = "wx_manual_fenshui_ci", MinRel = 0, Price = 350 },
			{ ManualID = "wx_manual_kuanggong_gao", MinRel = 0, Price = 370 },
			{ ManualID = "wx_manual_yexiao_yan", MinRel = 0, Price = 280 },
			{ ManualID = "wx_manual_yexing_shu", MinRel = 0, Price = 370 },
			{ ManualID = "wx_manual_loulan_faqiu_chui", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_loulan_fenjin_ci", MinRel = 25, Price = 2230 },
			{ ManualID = "wx_manual_loulan_youmu", MinRel = 25, Price = 2140 },
			{ ManualID = "wx_manual_hamagong", MinRel = 55, Price = 4750 }
		]
	}
};
