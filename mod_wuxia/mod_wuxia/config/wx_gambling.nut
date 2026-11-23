// Pure Data Configuration for Wuxia Tavern Gambling (`迎客酒肆 · 长乐赌桌`) & Martial Arts Tournament Betting (`武林大会 · 演武签表与外围红盘`)
// Zero stock-market / world-party bloat; 100% integrated with Wuxia silver (`两纹银`), 44 Sects, and ShanHai folkloric ecology.

::Wuxia.Config.Gambling <- {
	// 1. Tavern Corner Gambler Patrons (`酒肆雅座博戏豪客`)
	Patrons = [
		{
			Name    = "独耳老刀客",
			Opening = "炭盆旁，一名缺了半只左耳的关外老刀客正拢起一叠磨得发亮的明制马吊叶子牌，用刀鞘把对面的空竹凳轻轻拨向你：\n\n「掌门请坐！酒楼外头刀剑无眼赌的是身家性命，这张榆木桌只赌几锭官铸纹银——可有雅兴摸上两把？」",
			Asking  = "老刀客哈哈一笑，将马吊叶子牌、三颗泛黄牛骨骰与一方绘着江湖六象的楠木盘推到烛火下：\n\n「叶子牌讲心算，牛骨骰凭气运。少侠点个彩头，老夫今晚奉陪到底！」"
		},
		{
			Name    = "锦袍丝路豪商",
			Opening = "临窗雅座上，一位袖口微沾大漠风沙的西域豪商正将几锭雪花纹银排成一列，见你驻足相望，便含笑举起手中紫铜骰盅：\n\n「长夜漫漫，水酒寡淡。东家若不嫌弃，不妨入席博个彩头？输赢皆凭手气与胆魄！」",
			Asking  = "豪商将青瓷酒盏挪开，露出桌心的骨骰与闯关木图：\n\n「老夫走南闯北，塞外中原的博戏规矩皆略通一二。不知东家今晚想借哪般玩意分这锭银子？」"
		},
		{
			Name    = "断指快活林老客",
			Opening = "角落阴影里，一名左手少了半截尾指的老江湖洗起叶子牌快若穿花蝴蝶，抬眼瞥了瞥你的行囊，笑眯眯拍了拍身旁条凳：\n\n「莫按剑柄，兵刃留在鞘里。今夜只凭牌面与骰点论英雄——敢不敢下桌过两招？」",
			Asking  = "断指老客用粗壮指节叩了叩桌面：\n\n「要斗心眼便起四家叶子戏，要试胆色便掷牛骨骰与黑风闯关。划下道来罢！」"
		},
		{
			Name    = "云梦竹笠女侠",
			Opening = "戴着青竹斗笠的江湖奇女子独据一桌，剑穗垂在桌沿，指尖三颗红点牛骨骰转得滴溜溜脆响：\n\n「江湖路远，难得今夜无风无雨。掌门既然进了这迎风酒楼，何不坐下赌几把酒钱？」",
			Asking  = "竹笠女侠微抬帽檐，唇角轻扬：\n\n「廿一点、四家叶子、双鲤抢单、六合花旗——掌门挑一门顺手的便是。」"
		}
	],

	// 2. Seven Authentic Wuxia Tavern Games (`七大江湖博戏`)
	Tables = [
		{
			ID    = "blackjack",
			Name  = "马吊廿一点",
			Short = "廿一点",
			Reply = "「摆开马吊叶子牌，来几手廿一点！」",
			Rule  = "庄家摊开五十二叶博牌：「点数以廿一点为尊，切莫贪多爆点！『天罡(A)』可作 1 点或 11 点，『少侠(J)/掌门(Q)/宗师(K)』皆作 10 点。老夫不足 17 点必补牌，满 17 点即封手。起手两叶直成廿一点天胡，按赌注 2.5 倍连本奉还；寻常胜出连本返 2 倍；平点原银退回。唯有起手前两叶可『孤注加倍』，再押同额纹银且只补最后一叶！」"
		},
		{
			ID    = "holdem",
			Name  = "四家叶子戏",
			Short = "四家叶子",
			Reply = "「凑齐四人同桌，开一局四家叶子戏！」",
			Rule  = "庄家按住牌叠：「四人围坐，各发两张暗叶。先下小盲、大盲底银，随后依次翻开三叶、第四叶、第五叶公共明牌，每轮皆可跟注、加注、观望或扣牌弃局。七叶之中任选五叶成势：天罡同花顺 ＞ 四象轰雷(四条) ＞ 满堂红(葫芦) ＞ 清一色(同花) ＞ 五连珠(顺子) ＞ 三绝(三条) ＞ 连双(两对) ＞ 双星(一对) ＞ 散叶(高牌)。银两不足可倾囊全押，另结边池，赌坊分文不抽水！」"
		},
		{
			ID    = "size",
			Name  = "牛骨骰 · 押大小",
			Short = "骨骰大小",
			Reply = "「拿紫铜骰盅来，就押牛骨骰大小！」",
			Rule  = "庄家托起三颗红四牛骨骰：「买定离手！三骰合计 4 至 10 点为【小】，11 至 17 点为【大】。若摇出三颗同点『豹子』，无论押大押小皆归庄家通杀！押中大小，纹银连本翻倍奉还！」"
		},
		{
			ID    = "symbols",
			Name  = "六合花旗盘",
			Short = "六合花旗",
			Reply = "「铺开六合花旗盘，我挑一门江湖图腾！」",
			Rule  = "庄家展开楠木六象盘：「盘绘【名剑、藤盾、镖旗、斗笠、酒坛、鬼首】六门图腾。择定一门押下纹银，连掷三枚花旗骰：所押图腾现出一枚连本返 2 倍，现出两枚连本返 3 倍，三枚齐出天彩连本暴返 12 倍！若一枚未见，赌本归庄。」"
		},
		{
			ID    = "riffa",
			Name  = "双鲤抢单骰",
			Short = "双鲤抢单",
			Reply = "「比一把双鲤抢单骰，看谁点子硬！」",
			Rule  = "庄家拢起六颗骨骰：「庄闲各执一对同点『双鲤骰』，外加一枚『戏珠单骰』，三颗合计比高低！点数相同和局退本；少侠点数压过庄家即胜，赌坊仅抽四厘茶水钱，连本奉还 1.96 倍纹银（零头抹去）。」"
		},
		{
			ID    = "hazard",
			Name  = "天门追点骰",
			Short = "天门追点",
			Reply = "「摇天门追点骰，我来定个天门主点！」",
			Rule  = "庄家轻叩铜盅：「先从 5 至 9 点择定【天门主点】掷出双骰：首掷即中主点立赢（主点选 6 或 8 时首掷 12 亦赢；主点选 7 时首掷 11 亦赢）；首掷 2、3 点或其余 11、12 点立输。若掷出他数则锁为【机缘点】继续免注连掷——机缘点先至连本赢 2 倍，天门主点先出则落败！」"
		},
		{
			ID    = "raid",
			Name  = "夜走黑风道",
			Short = "夜走黑风",
			Reply = "「摆出夜走黑风道舆图，我来闯四关！」",
			Rule  = "庄家推开四关险道木图：「动身前只押一次镖银，共闯【黑风山口 1.15倍 → 迷雾苦竹林 1.38倍 → 断魂一线天 1.65倍 → 满载入州城 1.98倍】四程险关！每程掷骨骰一枚：2 至 6 点平安过关，头三关过关后皆可随时『收缰结账』落袋为安，亦可催马再闯；一旦掷出 1 点便是撞上响马劫道，镖本尽失！」"
		}
	],

	// 3. Hold'em AI Opponents (`四家叶子戏同桌酒客`)
	HoldemSeats = ["少侠（你）", "独耳老刀客", "断指老江湖", "锦袍丝路商"],

	// 4. Tournament Divisions (`天下武林大会四象分榜`)
	Regions64 = ["东岳青龙榜", "南疆朱雀榜", "西塞白虎榜", "北境玄武榜", "盟主决战坛"],

	// 5. Sect Squad Archetypes for Tournament (`武林大会各派五人代表队编制`)
	SectSquadMap = {
		shaolin  = { Suffix = "罗汉护法队", Banner = "banner_53", Roster = ["shaolin_bronze", "monk_fighter", "monk_fighter", "staff_guard", "staff_guard"] },
		taihe    = { Suffix = "紫霄两仪剑阵", Banner = "banner_54", Roster = ["taihe_elder", "emei_sword", "disciple", "disciple", "escort"] },
		qingfeng = { Suffix = "翠屏试剑五子", Banner = "banner_52", Roster = ["emei_sword", "emei_sword", "disciple", "disciple", "disciple"] },
		tangmen  = { Suffix = "暴雨机括堂", Banner = "banner_59", Roster = ["tangmen_killer", "tangmen_killer", "dartist", "dartist", "shadow_dagger"] },
		gaibang  = { Suffix = "九袋护舵队", Banner = "banner_60", Roster = ["gaibang_elder", "staff_guard", "staff_guard", "monk_fighter", "escort"] },
		weiyuan  = { Suffix = "金牌镇镖队", Banner = "banner_51", Roster = ["weiyuan_captain", "escort", "escort", "axe_vanguard", "hammer_adept"] },
		xuanbing = { Suffix = "昆仑寒玉剑卫", Banner = "banner_56", Roster = ["taihe_elder", "emei_sword", "emei_sword", "disciple", "disciple"] },
		pishan   = { Suffix = "长白开山斧卫", Banner = "banner_58", Roster = ["liaodong_boss", "axe_vanguard", "axe_vanguard", "hammer_adept", "escort"] },
		zhenyue  = { Suffix = "太行碎甲锤堂", Banner = "banner_55", Roster = ["garrison_general", "hammer_adept", "hammer_adept", "escort", "axe_vanguard"] },
		jiujie   = { Suffix = "云梦烟波鞭队", Banner = "banner_57", Roster = ["dongting_pirate", "whip_stalker", "whip_stalker", "escort", "staff_guard"] },
		shenji   = { Suffix = "红夷神机卫", Banner = "banner_51", Roster = ["garrison_general", "shenji_musketeer", "shenji_musketeer", "escort", "escort"] },
		wudu     = { Suffix = "万蛊奇兵队", Banner = "banner_61", Roster = ["wudu_gushaman", "wudu_blowgun", "wudu_blowgun", "whip_stalker", "dartist"] },
		heifeng  = { Suffix = "血煞狂刀堂", Banner = "banner_62", Roster = ["blood_chief", "axe_vanguard", "hammer_adept", "dartist", "shadow_dagger"] },
		yinsha   = { Suffix = "幽冥索命五鬼", Banner = "banner_61", Roster = ["dongchang_agent", "shadow_dagger", "shadow_dagger", "tangmen_killer", "dartist"] }
	},

	// Regional fallback rosters for the remaining 30 Wuxia Sects
	RegionSquadFallbacks = {
		plains    = { Suffix = "总堂演武队", Banner = "banner_51", Roster = ["weiyuan_captain", "escort", "escort", "staff_guard", "hammer_adept"] },
		mountains = { Suffix = "入室试剑队", Banner = "banner_54", Roster = ["taihe_elder", "emei_sword", "disciple", "disciple", "monk_fighter"] },
		forest    = { Suffix = "幽林奇门队", Banner = "banner_59", Roster = ["tangmen_killer", "shadow_dagger", "dartist", "emei_sword", "disciple"] },
		swamp     = { Suffix = "江淮分水队", Banner = "banner_57", Roster = ["dongting_pirate", "liushan_bailiff", "whip_stalker", "escort", "staff_guard"] },
		snow      = { Suffix = "塞北铁衣队", Banner = "banner_58", Roster = ["liaodong_boss", "axe_vanguard", "axe_vanguard", "hammer_adept", "emei_sword"] },
		desert    = { Suffix = "瀚海弯刀队", Banner = "banner_62", Roster = ["mobei_centurion", "mingzun_fawang", "shenji_musketeer", "escort", "dartist"] }
	},

	// 6. Exotic Jianghu, Ancient Tomb & ShanHai Guest Entries (`奇门异兽与秘境闯擂客队`)
	GuestPrefixes = [
		"黑风", "赤月", "断魂", "风蚀", "玄石", "荒冢", "暮影", "寒泉",
		"焦土", "苍岩", "古塞", "绝壁", "枯涧", "寒鸦", "朔风", "流沙"
	],

	ExoticGuests = [
		{
			id = "greenwood_raiders", title = "绿林响马五虎", faction = "绿林山寨", unit = "人", human = true, solo = false,
			troops = ["enemies/bandit_raider", "enemies/bandit_raider", "enemies/bandit_raider", "enemies/bandit_marksman", "enemies/bandit_marksman"],
			story = "五名啸聚山林的绿林好汉将雁翎刀与硬弓拍在知客案上，扬言只为武林大会彩头而来，绝不在城内劫道滋事。监擂执事验明兵刃后准其登台，此队五人上阵。"
		},
		{
			id = "desert_blades", title = "瀚海弯刀游侠", faction = "西域马贼", unit = "人", human = true, solo = false,
			troops = ["humans/nomad_outlaw", "humans/nomad_outlaw", "humans/nomad_cutthroat", "humans/nomad_archer", "humans/nomad_slinger"],
			story = "五名头缠黄沙巾帕的西域刀客横跨瀚海赶赴盛会，弯刀如新月、飞蝗石百发百中，不求驿馆锦榻，只问开擂金锣何时敲响。此队五人上阵。"
		},
		{
			id = "yaoren_pack", title = "黑水炼体狂徒", faction = "邪派药人", unit = "名", human = false, solo = false,
			troops = ["enemies/orc_young", "enemies/orc_young", "enemies/orc_young", "enemies/orc_young"],
			story = "四名服食虎狼秘药的关外狂徒在铁栏外焦躁低吼，青筋暴起如虬龙。护擂武师以精铁长杆隔开众人，为演武台额外加钉两道粗木横梁。此队四名药人上阵。"
		},
		{
			id = "yaoren_iron", title = "玄铁重甲药人", faction = "邪派药人", unit = "名", human = false, solo = false,
			troops = ["enemies/orc_warrior", "enemies/orc_warrior", "enemies/orc_young"],
			story = "两具披挂百斤玄铁重甲的魁梧药人踏裂青砖缓步入场，身后紧随一名执斧凶徒。单看石阶上深逾寸许的足印，外围豪客便纷纷倒吸凉气。此队三名重装药人上阵。"
		},
		{
			id = "yaoren_berserk", title = "血煞疯魔双凶", faction = "邪派药人", unit = "名", human = false, solo = false,
			troops = ["enemies/orc_berserker", "enemies/orc_berserker"],
			story = "两名遍体刀疤的疯魔药人赤膊捶胸，闷响恍若擂鼓撞钟，凭狂暴气血便敢硬撼名门五人剑阵。此队两名疯魔狂战上阵。"
		},
		{
			id = "yaoren_overlord", title = "炼体魔尊霸主", faction = "邪派霸主", unit = "尊", human = false, solo = true,
			troops = ["enemies/orc_warlord"],
			story = "身高九尺的邪派炼体霸主单手将百斤巨斧砸在签案上，震落四枚空木牌！知客执事战战兢兢询问同伙何在，那魔尊狞笑一声指向台心——霸主独身闯擂，本队仅一尊！"
		},
		{
			id = "wudu_ambush", title = "密林吹箭伏兵", faction = "南疆五毒", unit = "名", human = false, solo = false,
			troops = ["enemies/goblin_fighter", "enemies/goblin_fighter", "enemies/goblin_fighter", "enemies/goblin_ambusher", "enemies/goblin_ambusher"],
			story = "五名身形鬼魅的南疆五毒伏兵蹲踞廊柱暗影，短刃与吹筒泛着幽蓝寒芒，专克大意冒进的重甲武人。此队五名伏兵上阵。"
		},
		{
			id = "wudu_captain", title = "万蛊督战奇兵", faction = "南疆五毒", unit = "名", human = false, solo = false,
			troops = ["enemies/goblin_leader", "enemies/goblin_fighter", "enemies/goblin_fighter", "enemies/goblin_ambusher"],
			story = "头戴银饰冠冕的五毒头目率三名贴身死士押签入册，身法诡谲难测，袖中捕网暗器防不胜防。此队四名奇兵上阵。"
		},
		{
			id = "tomb_bronze", title = "前朝青铜剑俑", faction = "玄宫机关", unit = "具", human = false, solo = false,
			troops = ["enemies/skeleton_light", "enemies/skeleton_light", "enemies/skeleton_light", "enemies/skeleton_light", "enemies/skeleton_medium"],
			story = "方外摸金客自前朝秘冢运来五具刻满符文的青铜机关剑俑，机括咬合严丝合缝，不惧疼痛亦无战意动摇。此队五具青铜俑上阵。"
		},
		{
			id = "tomb_spears", title = "玄宫长戈战阵", faction = "玄宫机关", unit = "具", human = false, solo = false,
			troops = ["enemies/skeleton_medium", "enemies/skeleton_medium", "enemies/skeleton_medium_polearm"],
			story = "三具手持古戈的玄宫重俑踏上石阶，阵列进退竟比藩镇禁军更为森严齐整，专教轻功剑客无隙可乘。此队三具战俑上阵。"
		},
		{
			id = "tomb_goldguard", title = "镇陵金甲双卫", faction = "玄宫机关", unit = "具", human = false, solo = false,
			troops = ["enemies/skeleton_heavy", "enemies/skeleton_heavy_polearm"],
			story = "两尊覆面乌金重甲的前朝镇陵宿卫静立栏外，胸腹经脉死寂无声，寻常刀剑难伤分毫。此队两具金甲卫上阵。"
		},
		{
			id = "shanhai_tiangou", title = "阴山白首天狗群", faction = "山海异兽", unit = "头", human = false, solo = false,
			troops = ["enemies/direwolf", "enemies/direwolf", "enemies/direwolf", "enemies/direwolf_high"],
			story = "塞外驯兽异人牵来四道精铁锁链，笼中四头白首天狗凶睛死锁演武场，疾扑撕咬快似奔雷。此队四头天狗上阵。"
		},
		{
			id = "shanhai_gudiao", title = "西山裂齿蛊雕群", faction = "山海异兽", unit = "头", human = false, solo = false,
			troops = ["enemies/hyena", "enemies/hyena", "enemies/hyena_high"],
			story = "三头嗜血凶兽在铁笼中发出骇人怪啼，利齿专撕甲缝血肉，一旦见血便凶性暴涨。此队三头凶兽上阵。"
		},
		{
			id = "shanhai_bashe", title = "苍梧黑鳞巨蟒群", faction = "山海异兽", unit = "条", human = false, solo = false,
			troops = ["enemies/serpent", "enemies/serpent", "enemies/serpent"],
			story = "三只玄铁兽笼内各盘一条水桶粗的苍梧巨蟒，鳞甲刮擦铁栏铮铮作响，缠拽绞杀之力骇人听闻。此队三条巨蟒上阵。"
		},
		{
			id = "shanhai_chizhu", title = "幽林织毒赤蛛群", faction = "山海异兽", unit = "只", human = false, solo = false,
			troops = ["enemies/spider", "enemies/spider", "enemies/spider", "enemies/spider"],
			story = "南疆蛊客揭开黑布，四只磨盘大小的山海赤蛛吐丝如网，毒牙见血封喉。此队四只毒蛛上阵。"
		},
		{
			id = "shanhai_shanxiao", title = "荒冢食腐山魈群", faction = "山海异兽", unit = "头", human = false, solo = false,
			troops = ["enemies/ghoul", "enemies/ghoul", "enemies/ghoul_medium"],
			story = "四头潜伏古战场的凶残山魈扒住铁栏贪婪窥伺，越战越狂，令台下看客背脊发凉。此队四头山魈上阵。"
		},
		{
			id = "titan_mountain", title = "荒岭独尊 · 裂岳巨猿", faction = "山海凶兽", unit = "尊", human = false, solo = true,
			troops = ["enemies/unhold"],
			story = "知客执事仰首望向高出木栏半截的狰狞猿首，颤手划去其余四行空名：「此一头荒岭巨猿便抵千军，再塞几头进来，演武台怕要塌了！」巨猿独身闯擂，本队仅一尊。"
		},
		{
			id = "titan_bog", title = "黑沼独霸 · 瘴骨凶猿", faction = "山海凶兽", unit = "尊", human = false, solo = true,
			troops = ["enemies/unhold_bog"],
			story = "腥臭沼气未散，山岳般的黑毛凶猿已撞得铁笼乱颤，周身骨肉自愈惊人。兽师抱拳道：「它独占一签，诸位掌门小心了！」瘴骨凶猿独身闯擂，本队仅一尊。"
		},
		{
			id = "titan_zhuyan", title = "小次山独行 · 白首朱厌", faction = "山海大妖", unit = "尊", human = false, solo = true,
			troops = ["enemies/unhold_frost"],
			story = "《山海经》有云：白首赤足，名曰朱厌，见则大兵！那双比铁圆盾还大的霜毛巨拳往栏上一搭，满场鸦雀无声。监擂长老亲自盖印：白首朱厌独身闯擂，本队仅一尊！"
		}
	]
};
