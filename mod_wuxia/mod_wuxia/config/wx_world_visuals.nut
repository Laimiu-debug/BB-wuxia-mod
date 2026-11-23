// Pure Data Configuration for Row 4:
//   1. Chinese Prefectures, Garrisons, Villages, Oasis Cities & Sect Mountain Gates (`wx_settlement_0.brush` + `gfx/ui/settlements/`)
//   2. 32 World Map Marching Chess Pieces & Caravans (`wx_world_entity_0.brush`)
//   3. 16 Chinese Vertical Long War Standards (`gfx/ui/banners/` + `wx_world_entity_0.brush` + `wx_banners_0.brush`)

::Wuxia.Config.WorldVisuals <- {
	// 12 Player-Selectable Jianghu Vertical Long War Standards (prepended to ::Const.PlayerBanners)
	PlayerBanners = [
		"banner_51", "banner_52", "banner_53", "banner_54",
		"banner_55", "banner_56", "banner_57", "banner_58",
		"banner_59", "banner_60", "banner_61", "banner_62"
	],

	// TerrainType index -> Chinese Landscape Backdrop (`ui/settlements/wx_bg_*`)
	// Vanilla TerrainType indices: 1=Ocean, 2=Plains, 3=Swamp, 4=Hills, 5=Forest, 6=SnowyForest,
	// 7=LeaveForest, 8=AutumnForest, 9=Mountains, 12=Snow, 14=Tundra, 15=Steppe, 17=Desert, 18=Oasis
	TerrainBackdropMap = {
		[1]  = "ui/settlements/wx_bg_coast",
		[2]  = "ui/settlements/wx_bg_plains",
		[3]  = "ui/settlements/wx_bg_swamp",
		[4]  = "ui/settlements/wx_bg_mountains",
		[5]  = "ui/settlements/wx_bg_forest",
		[6]  = "ui/settlements/wx_bg_snow",
		[7]  = "ui/settlements/wx_bg_forest",
		[8]  = "ui/settlements/wx_bg_steppe",
		[9]  = "ui/settlements/wx_bg_mountains",
		[12] = "ui/settlements/wx_bg_snow",
		[14] = "ui/settlements/wx_bg_steppe",
		[15] = "ui/settlements/wx_bg_steppe",
		[16] = "ui/settlements/wx_bg_coast",
		[17] = "ui/settlements/wx_bg_desert",
		[18] = "ui/settlements/wx_bg_desert"
	},

	// 14 Clickable Town Shop Buildings -> [UIImageBase, ChineseName, ChineseDescription]
	BuildingMap = {
		["building.crowd"]         = ["ui/settlements/wx_bldg_crowd",         "江湖招贤茶摊", "各路带刀游侠、走镖好手与苦力脚夫在此歇脚候雇，可招纳志同道合之士入伙。"],
		["building.marketplace"]   = ["ui/settlements/wx_bldg_marketplace",   "州县百货集市", "车马辐辏的城乡市集，粮秣布帛、跌打灵丹与江湖大路货拳谱秘籍一应俱全。"],
		["building.tavern"]        = ["ui/settlements/wx_bldg_tavern",        "迎客飞檐酒肆", "三教九流痛饮烈酒、探听山海异闻与武林秘事的热闹酒楼。"],
		["building.temple"]        = ["ui/settlements/wx_bldg_temple",        "济世药师禅祠", "香烟袅袅的清修医祠，寺中禅医精擅正骨拔毒、调治重创外伤。"],
		["building.weaponsmith"]   = ["ui/settlements/wx_bldg_weaponsmith",   "百炼炉火铸剑坊", "炉火昼夜不熄的名匠铁铺，打制刀剑枪戟、精铁指虎与破甲重兵。"],
		["building.armorsmith"]    = ["ui/settlements/wx_bldg_armorsmith",    "精工甲胄制革局", "专营山文重铠、步人札甲、劲装道袍与包铁藤牌的官准甲坊。"],
		["building.fletcher"]      = ["ui/settlements/wx_bldg_fletcher",      "神臂弓弩机巧坊", "选老桑牛角与精铁机括精制劲弓、踏张强弩与破甲羽箭。"],
		["building.training_hall"] = ["ui/settlements/wx_bldg_training_hall", "讲武演武木人馆", "设木人桩与十八般兵器的老字号武馆，可指点门人实战火候。"],
		["building.taxidermist"]   = ["ui/settlements/wx_bldg_taxidermist",   "百工丹坊",       "悬满异兽骨革、内设青铜八卦丹炉与百炼铁砧的百工坊，可在此盲投试丹参悟丹经、按方炼丹、重锻神兵及取放百草药柜奇材。"],
		["building.alchemist"]     = ["ui/settlements/wx_bldg_alchemist",     "西域火器奇珍局", "搜罗西域丹散、猛火油雷与神机火药秘器的奇巧铺面。"],
		["building.arena"]         = ["ui/settlements/wx_bldg_arena",         "红绸生死演武擂", "战鼓雷动的生死擂台，各路高手登台搏命以赢取重金与武林威名。"],
		["building.port"]          = ["ui/settlements/wx_bldg_port",          "漕运硬帆官渡口", "停泊硬帆福船与江海快船的水陆码头，可雇船横渡重洋水道。"],
		["building.barber"]        = ["ui/settlements/wx_bldg_barber",        "铜镜江湖易容阁", "精擅千面易容、改换冠发相貌与伪造通关路引的奇门秘阁，可为麾下侠客改头换面并敛息消解江湖追杀令。"],
		["building.kennel"]        = ["ui/settlements/wx_bldg_kennel",        "塞外猛獒驯犬坊", "圈养凶悍关外猛獒与护院猎犬，战时可放犬追咬残敌。"]
	},

	// Attached Locations around Settlements -> [WuxiaWorldSprite (or null to keep terrain sprite), ChineseName, ChineseDescription]
	AttachedLocationMap = {
		["attached_location.wooden_watchtower"]             = ["wx_att_watchtower", "官道望火木哨楼", "矗立于州县要道高坡的木构望火哨楼，戍卒昼夜瞭望绿林匪踪以保商路平安。"],
		["attached_location.stone_watchtower"]              = ["wx_att_watchtower", "青砖烽火戍楼",   "以青条石与城砖砌筑的坚固烽火墩台，遇强寇压境即举狼烟传讯百里。"],
		["attached_location.stone_watchtower_oriental"]     = ["wx_att_watchtower", "西域黄土烽燧",   "大漠丝路要冲夯筑的边塞烽燧高台，扼守商旅水源与绿洲咽喉。"],
		["attached_location.fortified_outpost"]             = ["wx_set_outpost_01", "关隘驻防营垒",   "重木鹿角与石垣围护的州府外围屯兵大营，驻有披甲官兵拱卫城池。"],
		["attached_location.guarded_checkpoint"]            = ["wx_set_outpost_01", "官道盘查关卡",   "横跨官道要津的税关隘口，盘查过往镖车行旅并征讨路引商税。"],
		["attached_location.militia_trainingcamp"]          = ["wx_att_sect_dojo",  "团练演武校场",   "乡勇团练与武馆弟子操演长枪刀盾的露天校场，城中可招募粗通武艺的庄客。"],
		["attached_location.militia_trainingcamp_oriental"] = ["wx_att_sect_dojo",  "都护府演武场",   "西域城邦操练弯刀轻骑与强弓手的大校场，金鼓之声终日不绝。"],
		["attached_location.herbalists_grove"]              = ["wx_att_sect_dojo",  "百草悬壶药庄",   "依山傍水辟出的灵草药圃与晒药庄院，源源不断向城中供应金疮丹散与汤药。"],
		["attached_location.fletchers_hut"]                 = ["wx_att_sect_dojo",  "削竹制箭匠庄",   "专司烘烤硬竹、修治雕翎羽箭与弩矢的百工匠户，使城中箭匣充盈。"],
		["attached_location.amber_collector"]               = [null, "沧海拾珀寮棚", "海滨渔户趁大潮退去拾取松脂古珀与海奇珍宝的茅棚集散处。"],
		["attached_location.beekeeper"]                     = [null, "百花养蜂山庄", "山麓林间错落排布的木桶蜂场，出产甘醇崖蜜与封刀蜂蜡。"],
		["attached_location.blast_furnace"]                 = [null, "官办百炼铁冶所", "炉火彻夜通明的巨型水排鼓风高炉，熔铸精铁百炼钢以供兵甲锻造。"],
		["attached_location.brewery"]                       = [null, "古法曲蘖酒坊", "酒旗高悬、大缸泥封的酿酒作坊，所酿烈酒最受刀口舔血的江湖豪客喜爱。"],
		["attached_location.dye_maker"]                     = [null, "青蓝锦缎染坊", "满院竹架高挂靛青、茜红绸布的印染工坊，为富商大贾染制华服锦缎。"],
		["attached_location.dye_maker_oriental"]            = [null, "西域绯紫染坊", "以西域胡茜与矿彩浸染丝绸毯罽的名贵染肆，色泽历久弥新。"],
		["attached_location.fishing_huts"]                  = [null, "江海晒网渔村", "乌篷渔舟云集、竹架晾晒咸鱼水产的临水渔埠，为州县补充行军鱼干。"],
		["attached_location.fishing_huts_oriental"]         = [null, "沧溟采珠渔埠", "南洋海湾舟楫往来的渔村渡埠，盛产海味鱼获与蚌珠。"],
		["attached_location.gatherers_hut"]                 = [null, "山林采山寮屋", "山民入林采摘山菌野果、山药葛根的林间木寮。"],
		["attached_location.gem_mine"]                      = [null, "深山琳琅玉矿", "深嵌绝壁岩脉的宝玉矿硐，偶有温润奇玉与晶石原矿出产。"],
		["attached_location.goat_herd"]                     = [null, "山坡牧羊草场", "依陡峭山坡围栏放牧山羊的草甸牧场，产出鲜肉、羊乳与熟皮。"],
		["attached_location.goat_herd_oriental"]            = [null, "沙洲胡羊牧场", "绿洲边缘水草丰美处的胡羊牧群，为往来驼队供应肉食皮囊。"],
		["attached_location.gold_mine"]                     = [null, "官督沙金矿场", "重兵看守的金脉矿坑，矿夫日夜淘洗金砂，令城池商贸豪奢繁盛。"],
		["attached_location.harbor"]                        = [null, "千帆漕运海港", "深水栈桥林立、海舶云集的官办漕港，四方奇货皆由此吞吐集散。"],
		["attached_location.hunters_cabin"]                 = [null, "深林猎户庄寨", "世代巡山设套的老猎户聚居木寨，常有熏制兽肉与上等毛皮出售。"],
		["attached_location.incense_dryer"]                 = [null, "沉檀晾香庄园", "遍植乳香瑞木、竹匾晾晒沉檀香料的西域庄园，异香十里可闻。"],
		["attached_location.leather_tanner"]                = [null, "熟皮硝革作坊", "浸泡硝水、刮脂鞣制牛皮兽革的匠作坊，是缝制皮甲护腕的根基。"],
		["attached_location.lumber_camp"]                   = [null, "深山伐木木场", "斧锯叮当、顺溪放排运送巨木良材的山林木场，供应修械筑城之需。"],
		["attached_location.mushroom_grove"]                = [null, "幽泽灵蕈菌圃", "湿润林泽间培植肥厚山菌与药芝的菌寮，可充行军耐饥干粮。"],
		["attached_location.orchard"]                       = [null, "锦绣百果林园", "梨枣桃杏满枝的城郊果园，秋收果脯蜜饯可供远行镖队解渴充饥。"],
		["attached_location.ore_smelters"]                  = [null, "炭火炼铁炉场", "引山泉水锤锻打生铁锭的冶铁炉坊，为城中刀铺甲坊直供精铁。"],
		["attached_location.peat_pit"]                      = [null, "泽国采炭泥场", "自古泽黑泥中掘取耐燃泥炭晾干成砖的采掘场，供严冬炉火锻冶之用。"],
		["attached_location.pig_farm"]                      = [null, "乡间圈豕肉庄", "圈栏肥猪成群的乡间庄户，腌制腊肉火腿最为行伍武人补益气力。"],
		["attached_location.plantation"]                    = [null, "江南桑麻庄田", "阡陌纵横的棉麻种植庄园，织造细密布帛以供裁衣裹伤。"],
		["attached_location.salt_mine"]                     = [null, "官督井盐盐场", "架设天车竹笕汲卤熬盐的官督盐井，盐引之利甲于一方。"],
		["attached_location.silk_farm"]                     = [null, "桑林缫丝织庄", "翠桑成林、机杼声声的江南蚕桑丝庄，所出云锦轻韧华贵。"],
		["attached_location.surface_copper_vein"]           = [null, "露天青铜矿脉", "裸露山表的孔雀石铜矿采坑，所出精铜可铸内家铜兵与护心镜。"],
		["attached_location.surface_iron_vein"]             = [null, "露天玄铁矿脉", "黑褐色铁矿裸露山脊的采石矿场，盛产锻打重刃的乌钢原矿。"],
		["attached_location.trapper"]                       = [null, "雪原捕貂猎寮", "深入苦寒林莽下套捕猎狐貂珍裘的皮货寮子。"],
		["attached_location.wheat_fields"]                  = [null, "千里良田麦庄", "金浪翻滚的膏腴官屯麦田，岁熟粮仓满溢，市集米面低廉。"],
		["attached_location.winery"]                        = [null, "琥珀蒲桃酒庄", "遍植西域蒲桃、地窖陈酿美酒的庄园，名酿远销南北重镇。"],
		["attached_location.wool_spinner"]                  = [null, "毡绒纺绩工坊", "纺锤飞转、擀制御寒毛毡与战袍内衬的纺织作坊。"],
		["attached_location.workshop"]                      = [null, "百工修械木坊", "木匠铁工云集、专制车轴盾牌与修甲百工器具的官督匠坊。"]
	},

	// Authentic Chinese Settlement Name Pools (used non-destructively when a settlement still has ASCII/European names)
	SettlementNames = {
		prefecture = [
			"洛阳府", "汴梁城", "襄阳重府", "长安故都", "临安大府", "金陵雄州", "成都锦城", "太原晋阳府",
			"江陵荆州", "扬州广陵府", "苏州平江府", "青州益都府", "真定常山府", "凤翔西府", "南阳宛城", "汉中兴元府"
		],
		town = [
			"清河镇", "汝南县", "淮阳城", "陈留县", "兰陵镇", "洛水驿", "颍川城", "谯县古城",
			"彭城集", "历城县", "河间镇", "博陵县", "浔阳江镇", "汉川镇", "绵竹县", "剑阁关镇",
			"华阴山镇", "登封嵩阳镇", "均州草店", "光州固始镇", "亳州药市", "磁州窑镇", "德州水驿", "沧州武镇"
		],
		village = [
			"杏花村", "柳林庄", "青石坞", "白水村", "桃源屯", "竹溪庄", "石桥铺", "稻香屯",
			"桑园村", "枫林渡", "黄泥岗", "野猪林庄", "翠微村", "槐树屯", "清溪庄", "芦花荡村",
			"牛家村", "太平庄", "落雁坡", "卧牛屯", "松溪村", "白鹤庄", "青牛峪", "七里铺"
		],
		sect_town = [
			"少室山麓", "太和云麓", "华岳仙峪", "青城幽镇", "峨眉山门镇", "嵩阳讲武镇",
			"终南古观镇", "武夷茶溪镇", "衡阳回雁镇", "恒山悬空镇", "昆仑雪麓镇", "点苍试剑镇"
		],
		water_town = [
			"云梦泽市", "震泽乌篷镇", "洞庭舵口", "鄱阳渡埠", "瓜洲古渡", "周庄水市",
			"微山湖镇", "白洋水寨", "沧溟海埠", "泉州刺桐港", "明州海门镇", "登州蓬莱埠"
		],
		fort_small = [
			"黑水烽燧", "白狼木寨", "望火戍堡", "断魂山口", "铁门关哨", "饮马河堡",
			"风陵渡寨", "虎牢前哨", "飞狐口堡", "青石关塞", "野狐岭堡", "柳条边哨"
		],
		fort_medium = [
			"居庸军镇", "紫荆卫城", "娘子关城", "潼关卫所", "武胜关镇", "散关铁城",
			"古北口镇", "喜峰卫城", "杀虎口镇", "偏头关城", "平型军堡", "倒马关镇"
		],
		fort_large = [
			"雁门镇北雄关", "山海镇东帅城", "嘉峪镇西雄城", "玉门铁壁要塞",
			"宣府节度帅城", "大同镇朔雄城", "榆林九边帅府", "宁远铁瓮重城"
		],
		oasis_city = [
			"敦煌沙州城", "高昌琉璃城", "龟兹安西府", "于阗玉州城", "疏勒都护城", "楼兰绿洲城"
		]
	},

	NobleHouseNames = [
		"陇西李氏藩府", "太原王氏节镇", "清河崔氏经略府", "琅琊王氏留守司",
		"博陵崔氏宣慰府", "弘农杨氏都督府", "范阳卢氏镇抚司", "河东裴氏节度府",
		"颍川陈氏安抚司", "汝南袁氏招讨府"
	],

	MercenaryCompanyNames = [
		"长风振威镖队", "铁血断水刀团", "苍狼逐日游骑", "七星联珠剑社",
		"黑旗破阵义从", "虎贲捉刀武团", "寒江孤雁侠社", "震山铁臂行营",
		"流星飞羽劲旅", "玄甲靖边义军"
	],

	// Authentic Chinese Wuxia Geographic Region Names (mapped onto ::Const.World.LocationNames & world map region labels)
	RegionNames = {
		coast = [
			"沧溟烟海", "东溟潮水道", "万里扶桑洋", "登莱海湾", "瓯越风涛洋", "刺桐海门道",
			"琼州碧波海", "渤澥重溟", "沧浪外洋", "星宿瀚海湾", "蓬莱仙雾海", "黑水惊涛洋"
		],
		plains = [
			"河洛平原", "关中沃野", "江汉平畴", "淮右千里原", "汴洛膏腴地", "华北桑麻野",
			"陈留古原", "汝颍平川", "河北九州野", "成都天府原", "清河广陌", "徐兖大平原",
			"南阳盆原", "晋南平阳川", "齐鲁桑梓原", "江淮沃壤"
		],
		steppe = [
			"塞上荒原", "敕勒苍原", "阴山牧野", "河套草滩", "雁北风沙原", "察哈尔荒草甸",
			"黄羊古牧场", "乌兰大荒原", "折箭古战原", "白狼荒莽原", "大青山南麓原", "古长城外野",
			"鸣镝荒原", "饮马草甸"
		],
		tundra = [
			"朔北寒原", "黑水冻原", "柳条边荒", "苦寒霜草地", "弱水寒荒", "辽北冻土原",
			"绝塞玄冰甸", "白草折风原", "玄冥荒寒野", "铁勒旧冻原", "孤雁苦寒川", "北溟荒甸"
		],
		snow = [
			"千里冰封雪原", "长白苦寒林海", "昆仑积雪境", "祁连寒雪川", "天山琼瑶界", "玄冰绝域",
			"朔风万里雪野", "松花江冰原", "玉龙寒雪原", "飞狐风雪岭", "饮冰苦寒境", "银装绝塞原"
		],
		mountains = [
			"太行险峰", "秦岭崇山", "嵩岳群峰", "终南叠嶂", "华岳绝壁", "巴山剑阁岭",
			"太岳千仞山", "武当云岭", "昆仑万山祖", "恒山悬崖脉", "祁连铁壁山", "五台寒山脉",
			"大别苍莽山", "衡岳回雁峰"
		],
		hills = [
			"邙山丘陵", "崤函山岗", "陇右黄土塬", "淮南冈峦", "江南烟雨丘", "铜官赤石岗",
			"落雁乱石坡", "五丈古原岗", "青石叠岭", "栖霞丘壑", "虎牢险坡", "马陵古丘",
			"狼牙断岗", "巴陵烟岚坡"
		],
		forest = [
			"终南幽林", "云梦古林", "巴蜀老林", "神农苍莽林", "武夷翠竹林", "大兴黑松林",
			"野猪古樟林", "括苍迷雾林", "木兰秋狝林", "桐柏深林", "幕阜幽谷林", "点苍古木林",
			"青城幽篁林", "九嶷瘴雾林"
		],
		swamp = [
			"云梦大泽", "震泽泥淖", "梁山水泊", "鄱阳芦苇荡", "白洋迷津泽", "雷泽毒瘴滩",
			"大野黑水泽", "洞庭烟瘴洲", "孟诸古泽", "淮上苇泽", "黑泥腐草滩", "南疆百蛊泽"
		],
		desert = [
			"瀚海大漠", "流沙绝域", "白龙堆沙海", "莫贺延碛", "塔里木赤沙原", "鸣沙万里漠",
			"罗布荒沙海", "阳关断魂漠", "玉门风沙碛", "赤金火焰漠", "古丝路狂沙海", "黑风流沙原"
		],
		oasis = [
			"月牙清泉洲", "疏勒绿洲", "蒲昌翠柳洲", "车师水草甸",
			"伊吾甘泉洲", "精绝古绿洲", "居延芦花海", "焉耆芳草洲"
		]
	},

	// Authentic Low-Magic Wuxia Wilderness Enemy Camps & Ancient Ruins (aligned with AGENTS.md Section 4.3)
	WildCampNames = {
		bandits = [
			"黑风响马山寨", "二龙山聚义寨", "断魂岭剪径寨", "野猪林劫道坞", "白虎堂分舵寨", "卧牛山悍匪寨",
			"鹰愁涧响马巢", "落草黑旗木寨", "飞虎峪强人寨", "赤发鬼占山营", "黄泥岗瓢把子寨", "独龙岗草寇营",
			"青州桃花匪寨", "清风寨强人坞"
		],
		nomads = [
			"流沙弯刀马贼营", "瀚海黑帐响马营", "白驼流寇沙寨", "红柳滩胡骑贼帐", "枯井劫商沙匪窝",
			"黑水城马贼前哨", "鸣沙口响马驼营", "罗布荒原匪帐", "断水滩沙盗营", "古驿废堡马贼巢"
		],
		barbarians = [
			"黑水部骨幡大营", "靺鞨狂徒皮帐寨", "白狼山战帮营盘", "寒原裂颅血祭坛", "铁弗悍匪兽皮营",
			"室韦蛮兵前哨寨", "冻原巨斧狂战营", "朔北披发战帮窟", "饮血荒原骨帐营", "绝塞重锤蛮兵寨"
		],
		goblins = [
			"南疆五毒百蛊寨", "瘴林吹箭苗伏哨", "赤蝎藤楼奇门寨", "黑竹沟毒网暗巢", "万蛇谷五毒分坛",
			"迷雾林淬毒木寨", "百足岭奇门伏兵坞", "碧磷瘴毒烟暗营", "鬼见愁苗疆竹寨", "断肠崖五毒哨垒"
		],
		orcs = [
			"邪宗炼体药人窟", "血煞铜皮巨汉营", "百炼尸血药人坛", "失心狂魔铁索营", "赤煞催筋炼魔寨",
			"黑煞门药人深渊", "裂石狂躯血池营", "断骨重斧药人巢", "魔教外堂兽血窟", "凶煞炼体试药场"
		],
		undead = [
			"前朝玄宫守陵墓", "湘西赶尸阴煞坛", "古战场白骨义庄", "千年青铜兵俑冢", "荒山鬼火乱葬岗",
			"前朝镇国将军冢", "阴山控魂招尸窟", "残碑古刹尸傀巢", "沉沙折戟古战冢", "幽冥地脉玄石墓",
			"绝魂谷前朝秘陵", "荒村纸人停尸庄"
		],
		ruins = [
			"前朝残垣荒城址", "兵燹断壁古驿台", "荒草倾颓旧卫城", "湮没黄沙古戍堡", "前朝废毁讲武坛",
			"断碑残柱古祠址", "百年战火焦土砦", "荒芜山神古庙墟", "坍塌古道烽火墟", "秘境残破石殿址"
		]
	},

	// Player `World.Assets.updateLook(_look)` -> Wuxia Chess Figurine
	PlayerLookMap = {
		[1]  = "wx_fig_player_01",
		[2]  = "wx_fig_player_02",
		[3]  = "wx_fig_player_03",
		[4]  = "wx_fig_player_02",
		[5]  = "wx_fig_northern_warband",
		[6]  = "wx_fig_player_03",
		[7]  = "wx_fig_xiangxi_corpse",
		[8]  = "wx_fig_militia",
		[9]  = "wx_cart_escort_01",
		[10] = "wx_fig_player_01",
		[11] = "wx_fig_player_01",
		[12] = "wx_fig_garrison_foot",
		[13] = "wx_fig_shenji_army",
		[14] = "wx_fig_garrison_foot",
		[15] = "wx_fig_garrison_general",
		[16] = "wx_fig_player_03",
		[17] = "wx_fig_sect_sword",
		[18] = "wx_fig_player_02",
		[19] = "wx_fig_sect_sword",
		[20] = "wx_fig_sect_tangmen"
	},

	// 44 Jianghu Sects / VendettaParty -> [WuxiaFigurine, WorldBanner]
	VendettaVisualMap = {
		wx_shaolin_monks      = ["wx_fig_sect_monk",        "banner_53"],
		wx_qingfeng_hunters   = ["wx_fig_sect_sword",       "banner_54"],
		wx_tangmen_skirmishers= ["wx_fig_sect_tangmen",     "banner_59"],
		wx_wudu_ambushers     = ["wx_fig_wudu",             "wx_fbanner_outlaw_01"],
		wx_gaibang_guards     = ["wx_fig_sect_gaibang",     "banner_60"],
		wx_weiyuan_escorts    = ["wx_fig_player_02",        "banner_51"],
		wx_heifeng_raiders    = ["wx_fig_sect_xuesha",      "wx_fbanner_outlaw_01"],
		wx_shenji_gunners     = ["wx_fig_shenji_army",      "wx_fbanner_south_01"],
		wx_pishan_axemen      = ["wx_fig_northern_warband", "banner_58"],
		wx_zhenyue_hammers    = ["wx_fig_garrison_general", "banner_55"],
		wx_jiujie_whips       = ["wx_fig_sect_xuanbing",    "banner_57"],
		wx_yinsha_assassins   = ["wx_fig_sect_tangmen",     "banner_61"]
	},

	// Exact & Prefix Remapping for ALL Vanilla World Map Party Figurines (`world_entity_0.brush` -> `wx_world_entity_0.brush`)
	PartyExactMap = {
		cart_01 = "wx_cart_escort_01",
		cart_02 = "wx_cart_escort_01",
		cart_03 = "wx_cart_camel_02",
		ship_03 = "wx_ship_junk_01",
		ship_04 = "wx_ship_junk_01",
		world_ship_01 = "wx_ship_junk_01",
		world_ship_02 = "wx_ship_junk_01",
		figure_siege_01 = "wx_fig_garrison_general"
	},

	PartyPrefixMap = [
		["figure_noble_03",   "wx_fig_garrison_general"],
		["figure_noble_",     "wx_fig_garrison_foot"],
		["figure_southern_",  "wx_fig_shenji_army"],
		["figure_militia_",   "wx_fig_militia"],
		["figure_civilian_",  "wx_fig_civilian"],
		["figure_refugee_",   "wx_fig_civilian"],
		["figure_slave_",     "wx_fig_civilian"],
		["figure_mercenary_", "wx_fig_mercenary"],
		["figure_bandit_",    "wx_fig_bandit"],
		["figure_nomad_",     "wx_fig_nomad"],
		["figure_goblin_",    "wx_fig_wudu"],
		["figure_orc_",       "wx_fig_yaoren"],
		["figure_golem_",     "wx_fig_yaoren"],
		["figure_wildman_",   "wx_fig_northern_warband"],
		["figure_skeleton_",  "wx_fig_tomb_guard"],
		["figure_vampire_",   "wx_fig_tomb_guard"],
		["figure_zombie_",    "wx_fig_xiangxi_corpse"],
		["figure_necromancer_","wx_fig_xiangxi_corpse"],
		["figure_ghost_",     "wx_fig_xiangxi_corpse"],
		["figure_werewolf_",  "wx_fig_beast_tiangou"],
		["figure_hyena_",     "wx_fig_beast_gudiao"],
		["figure_spider_",    "wx_fig_beast_chizhu"],
		["figure_unhold_",    "wx_fig_beast_zhuyan"],
		["figure_lindwurm_",  "wx_fig_beast_feiyi"],
		["figure_kraken_",    "wx_fig_beast_xiangliu"],
		["figure_serpent_",   "wx_fig_beast_bashe"],
		["figure_hexe_",      "wx_fig_beast_yaomei"],
		["figure_alp_",       "wx_fig_beast_eshou"],
		["figure_ghoul_",     "wx_fig_beast_taotie"],
		["figure_schrat_",    "wx_fig_beast_jianmu"],
		["figure_player_",    "wx_fig_player_01"]
	]
};
