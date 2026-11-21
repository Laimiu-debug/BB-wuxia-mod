// Authentic Dark-Wuxia Chinese Character Names & Jianghu Epithets (Titles)
// Applied non-destructively in wx_background_system.nut so recruits match the 500 Wuxia biographies.

::Wuxia.Config.NamePools <- {
	// 底层市井 / 村野俗名 (Tier 0 commoners)
	folk = [
		"王二狗", "陈铁牛", "周大锤", "李阿四", "赵石头", "张麻子", "刘栓柱", "孙长生",
		"吴老实", "马二愣", "朱大碗", "胡黑子", "林木根", "郭铁蛋", "何泥鳅", "高瘦猴",
		"郑大脚", "梁三斤", "宋柴禾", "唐破鞋", "许二赖", "韩老蔫", "冯哑巴", "曹歪嘴",
		"彭大壮", "曾阿福", "肖二毛", "田耕牛", "董拉车", "袁满仓", "潘臭手", "于旱烟",
		"蒋大嘴", "蔡小七", "余瘸子", "杜黑皮", "叶草鞋", "程锅巴", "苏老幺", "魏大膀",
		"吕水生", "丁铜钱", "任二傻", "沈瓦片", "姚扁担", "卢糙汉", "姜大蒜", "崔铁锹",
		"钟老六", "谭泥腿", "陆苦瓜", "汪阿宝", "范二柱", "金算盘", "石磨盘", "廖黑炭",
		"贾阿狗", "夏麦穗", "韦土根", "付老三", "方大勺", "白面团", "邹豁牙", "孟大个",
		"熊笨手", "秦老五", "邱小顺", "江河娃", "尹破袄", "薛灶王", "闫二黑", "段麻绳"
	],

	// 江湖行当 / 习武散人名 (Tier 1 jianghu trades & wanderers)
	jianghu = [
		"沈追风", "陆断水", "顾铁衣", "裴青锋", "周镇海", "陈百战", "林惊雷", "韩无咎",
		"赵长河", "徐破军", "郑烈火", "谢孤鸿", "杨斩浪", "孟啸天", "程赤胆", "宋寒鸦",
		"许横江", "魏苍狼", "方问渠", "杜绝尘", "袁震山", "钟离恨", "高不平", "孙快刀",
		"曹饮血", "秦铁臂", "姜九幽", "卢惊蛰", "崔冷月", "石破天", "段飞羽", "唐暗影",
		"严铁面", "白无常", "纪长风", "罗震岳", "狄青衫", "柴孤舟", "凌九霄", "霍云龙",
		"雷万钧", "岳沉舟", "傅苍松", "戚烈阳", "祝融火", "穆寒星", "殷铁索", "曲幽冥",
		"章落雁", "苗断魂", "聂冷锋", "常胜军", "关千里", "邢无影", "庞大力", "辛疾风",
		"易长夜", "陶醉翁", "钱万贯", "贺拔山", "龚百毒", "焦铁掌", "莫问天", "楚狂生"
	],

	// 名门世家 / 成名高手雅名 (Tier 2 elites, nobles, swordmasters)
	master = [
		"沈寒江", "谢千山", "顾清秋", "萧孤舟", "陆青崖", "裴景行", "林疏桐", "秦惊鸿",
		"苏折柳", "燕十三", "傅红雪", "叶孤城", "温如玉", "楚留云", "慕容绝", "独孤岳",
		"上官明", "南宫烈", "欧阳锋", "司徒空", "公孙策", "令狐冲", "柳随风", "江枫眠",
		"晏几道", "季沧海", "容若渊", "谢必安", "岑参商", "闻人昭", "东方朔", "西门寒",
		"皇甫铮", "长孙凛", "宇文拓", "段誉清", "云中鹤", "风清扬", "花满楼", "陆小凤",
		"唐伯虎", "宋玉致", "卫庄肃", "韩非墨", "白起苍", "李寻欢", "张无忌", "岳不群"
	],

	// 禅门行脚僧 / 护法武僧 / 苦行头陀法号
	monk = [
		"慧明", "悟能", "寂空", "苦禅", "智深", "法海", "圆觉", "玄悲",
		"空闻", "了因", "净尘", "戒痴", "无相", "广智", "澄观", "渡厄",
		"普渡", "明心", "德海", "宏忍", "觉远", "行痴", "道济", "不戒",
		"玄慈", "空智", "灵虚", "定逸", "本因", "枯荣", "印光", "铁头陀"
	],

	// 西域大漠 / 丝路商道 / 影刺客名
	western = [
		"沙里飞", "阿史那", "巴图尔", "霍青桐", "铁木真", "胡尔察", "古力罕", "穆萨",
		"阿克苏", "哈桑", "伊犁客", "卡西姆", "达瓦", "桑吉", "扎西", "班禅客",
		"赫连勃", "尉迟恭", "拓跋野", "吐谷浑", "安禄客", "康居生", "米脂郎", "史思明",
		"苏定沙", "阿卜杜", "赛义德", "乌兰巴", "赤那思", "楼兰影", "月氏客", "龟兹手"
	],

	// 西域舞伎 / 女子化名
	dancer = [
		"古丽娜", "阿依夏", "苏合香", "楼兰月", "西施影", "柳如烟", "红拂女", "花解语",
		"白芍药", "玉玲珑", "沈秋娘", "胡旋儿", "沙棠花", "阿娜尔", "云霓裳", "翠微娘"
	],

	// 关外塞北狂战悍勇名
	northern = [
		"完颜烈", "耶律狂", "阿骨打", "斡离不", "巴特尔", "哲别", "速不台", "博尔术",
		"呼延赞", "拔都儿", "铁勒雄", "黑水狼", "白山熊", "兀术", "粘罕", "乌古论",
		"拓跋雄", "慕容恪", "宇文护", "尔朱荣", "高长恭", "贺六浑", "独孤信", "斛律光"
	],

	// 净身内侍 / 深宅家仆名
	eunuch = [
		"小桂子", "安德海", "王振安", "李莲福", "陈矩", "冯保儿", "高力顺", "魏忠良",
		"张永宁", "刘瑾儿", "曹正淳", "雨化田", "小顺子", "全福儿", "来喜儿", "进宝"
	],

	// 访古书生 / 验方医者 / 说书人文雅名
	scholar = [
		"孔乙己", "范进之", "陈抟生", "沈括舟", "徐霞客", "李时珍", "宋慈安", "蒲松龄",
		"纪晓岚", "袁枚卿", "顾炎武", "黄宗羲", "王夫之", "唐顺之", "归有光", "冯梦龙",
		"凌濛初", "张岱青", "周密轩", "洪迈翁", "孙思邈", "华佗徒", "葛洪生", "陶弘景"
	]
};

// Map every vanilla/DLC background ID to a curated Chinese NamePool + authentic Jianghu Titles (江湖绰号)
::Wuxia.Config.BackgroundNames <- {
	// Tier 0
	["background.beggar"]        = { Pool = "folk",    Titles = ["破碗", "花子头", "讨饭龙", "丐中仙", "泥腿子", "打狗手"] },
	["background.cripple"]       = { Pool = "folk",    Titles = ["独眼", "残臂", "瘸腿", "旧伤客", "半条命", "铁拐"] },
	["background.daytaler"]      = { Pool = "folk",    Titles = ["扛大包", "短工头", "苦力王", "糙汉", "码头脚", "老黄牛"] },
	["background.eunuch"]        = { Pool = "eunuch",  Titles = ["公公", "旧内侍", "厂卫遗孤", "深宅客", "净身人"] },
	["background.farmhand"]      = { Pool = "folk",    Titles = ["铁牛", "犁地虎", "大把式", "麦田熊", "铁肩", "庄稼汉"] },
	["background.fisherman"]     = { Pool = "folk",    Titles = ["浪里白条", "老艄公", "江上飘", "撒网手", "水鬼", "渔父"] },
	["background.gravedigger"]   = { Pool = "folk",    Titles = ["挖坟手", "义庄客", "夜掘人", "白骨铲", "守冢翁", "阴山铲"] },
	["background.historian"]     = { Pool = "scholar", Titles = ["酸秀才", "老书蠹", "拓碑客", "穷书生", "访古翁", "青衫客"] },
	["background.juggler"]       = { Pool = "jianghu", Titles = ["千手猴", "天桥客", "飞刀手", "吞火郎", "耍把式", "花蝴蝶"] },
	["background.mason"]         = { Pool = "folk",    Titles = ["石敢当", "铁锤手", "开山匠", "修墙虎", "凿石翁"] },
	["background.messenger"]     = { Pool = "jianghu", Titles = ["神行太保", "飞毛腿", "八百里", "急脚鬼", "追风驿", "千里马"] },
	["background.miller"]        = { Pool = "folk",    Titles = ["白面虎", "推磨牛", "粮仓客", "磨坊主", "铁臂磨"] },
	["background.miner"]         = { Pool = "folk",    Titles = ["穿山甲", "井下鬼", "铁镐王", "黑面炭", "掘金手"] },
	["background.minstrel"]      = { Pool = "scholar", Titles = ["醒木客", "百晓生", "茶楼嘴", "铁口舌", "说书翁", "江湖通"] },
	["background.peddler"]       = { Pool = "folk",    Titles = ["摇鼓郎", "铁算盘", "串巷客", "药担子", "油嘴滑"] },
	["background.pimp"]          = { Pool = "jianghu", Titles = ["花街鬼", "牵线手", "笑面虎", "老鸨客", "烟花通"] },
	["background.ratcatcher"]    = { Pool = "folk",    Titles = ["地沟蛇", "捕鼠鬼", "暗渠手", "五毒怕", "耗子王"] },
	["background.refugee"]       = { Pool = "folk",    Titles = ["逃荒客", "流民", "断炊汉", "北逃人", "孤雁"] },
	["background.servant"]       = { Pool = "eunuch",  Titles = ["老管家", "车马奴", "朱门仆", "跑堂手", "旧家丁"] },
	["background.shepherd"]      = { Pool = "folk",    Titles = ["飞石手", "牧羊汉", "山坡鹰", "赶狼鞭", "野草客"] },
	["background.slave"]         = { Pool = "folk",    Titles = ["戴枷人", "苦役", "断链汉", "卖身契", "血汗奴"] },
	["background.tailor"]        = { Pool = "scholar", Titles = ["金剪手", "绣花针", "巧裁缝", "软甲匠", "补天手"] },
	["background.vagabond"]      = { Pool = "jianghu", Titles = ["浪子", "四海客", "野孤云", "无根草", "漂泊汉", "天涯客"] },

	// Tier 1
	["background.anatomist"]       = { Pool = "scholar", Titles = ["毒手药王", "割脉手", "验尸郎", "怪郎中", "试毒翁", "银针客"] },
	["background.apprentice"]      = { Pool = "jianghu", Titles = ["小师弟", "练桩童", "武馆徒", "后起秀", "少年郎"] },
	["background.bastard"]         = { Pool = "master",  Titles = ["庶出子", "私生郎", "不羁少", "野公子", "外室龙"] },
	["background.belly_dancer"]    = { Pool = "dancer",  Titles = ["胡旋舞", "飞天袖", "西域花", "藏针姬", "沙海月"] },
	["background.bowyer"]          = { Pool = "jianghu", Titles = ["神弓匠", "削竹手", "弯弓翁", "强弩师", "百步匠"] },
	["background.brawler"]         = { Pool = "jianghu", Titles = ["铁拳", "打行虎", "野擂王", "碎骨拳", "码头霸", "赤手熊"] },
	["background.butcher"]         = { Pool = "folk",    Titles = ["杀猪匠", "剔骨刀", "血屠夫", "镇关西", "斩肉虎", "白刀进"] },
	["background.caravan_hand"]    = { Pool = "jianghu", Titles = ["老镖头", "趟子手", "喊镖虎", "官道龙", "护车将", "铁杆镖"] },
	["background.companion"]       = { Pool = "jianghu", Titles = ["老伙计", "生死交", "旧同袍", "过命弟", "老把兄弟"] },
	["background.cultist"]         = { Pool = "jianghu", Titles = ["拜幽客", "狂信徒", "血祭人", "无生老母徒", "疯魔教众"] },
	["background.deserter"]        = { Pool = "jianghu", Titles = ["逃兵", "断旗卒", "兵油子", "滑脚将", "夜遁客"] },
	["background.disowned_noble"]  = { Pool = "master",  Titles = ["逐门少", "落魄公子", "破落户", "断谱郎", "败家剑"] },
	["background.executioner"]     = { Pool = "jianghu", Titles = ["鬼头刀", "断首客", "法场煞", "行刑官", "刽子手"] },
	["background.flagellant"]      = { Pool = "monk",    Titles = ["苦头陀", "血荆僧", "疯行者", "铁皮僧", "自笞罗汉"] },
	["background.gambler"]         = { Pool = "jianghu", Titles = ["千王", "快手骰", "红眼赌徒", "牌九鬼", "袖里乾坤"] },
	["background.graverobber"]     = { Pool = "jianghu", Titles = ["摸金校尉", "发丘中郎", "倒斗手", "卸岭力士", "寻龙客", "搬山道人"] },
	["background.houndmaster"]     = { Pool = "jianghu", Titles = ["恶犬王", "驯獒客", "呼啸山庄", "猎犬头", "放狗手"] },
	["background.hunter"]          = { Pool = "jianghu", Titles = ["穿杨手", "打虎将", "老猎户", "深山鹰", "百步穿杨", "箭无虚发"] },
	["background.killer_on_the_run"] = { Pool = "jianghu", Titles = ["海捕凶", "亡命徒", "血手人屠", "过江凶", "夜奔客", "断命煞"] },
	["background.lumberjack"]      = { Pool = "folk",    Titles = ["开山斧", "伐木熊", "大力樵", "断松手", "铁腰斧"] },
	["background.manhunter"]       = { Pool = "jianghu", Titles = ["铁捕头", "追命锁", "捉刀客", "冷面捕", "花红猎手", "神捕"] },
	["background.militia"]         = { Pool = "folk",    Titles = ["乡勇头", "守庄枪", "团练丁", "保甲虎", "土枪手"] },
	["background.monk"]            = { Pool = "monk",    Titles = ["行脚僧", "云游禅", "托钵僧", "苦行僧", "扫地僧", "花和尚"] },
	["background.poacher"]         = { Pool = "jianghu", Titles = ["冷箭鬼", "私猎手", "密林狐", "偷鹿客", "暗箭手"] },
	["background.raider"]          = { Pool = "jianghu", Titles = ["过山风", "金盆客", "黑道狼", "截道虎", "独眼龙", "山大王"] },
	["background.retired_soldier"] = { Pool = "jianghu", Titles = ["老边军", "九边卒", "断戟老兵", "百战残兵", "铁甲老卒"] },
	["background.squire"]          = { Pool = "master",  Titles = ["剑童", "背剑郎", "随侍徒", "少侠", "入门弟子"] },
	["background.thief"]           = { Pool = "jianghu", Titles = ["鼓上蚤", "踏雪贼", "妙手空空", "夜行狸", "飞檐客", "梁上君子"] },
	["background.wildman"]         = { Pool = "northern", Titles = ["山魈汉", "野人王", "绝谷熊", "赤足蛮", "茹毛客"] },
	["background.witchhunter"]     = { Pool = "jianghu", Titles = ["斩妖客", "靖邪使", "镇尸人", "驱魔手", "冷面道", "捉鬼判官"] },

	// Tier 2
	["background.adventurous_noble"] = { Pool = "master",  Titles = ["玉面郎君", "锦衣侠", "游侠公子", "白衣少卿", "翩翩剑客"] },
	["background.assassin"]          = { Pool = "jianghu", Titles = ["无常影", "金牌刺客", "夺命匕", "血滴子", "夜无声", "追魂影"] },
	["background.assassin_southern"] = { Pool = "western", Titles = ["灰袍鬼", "大漠暗刃", "流沙刺", "西域影", "弯月杀手"] },
	["background.barbarian"]         = { Pool = "northern", Titles = ["塞北狼王", "狂战斧", "雪原悍将", "黑水魔", "铁骑煞"] },
	["background.beast_hunter"]      = { Pool = "jianghu", Titles = ["猎妖名家", "山海客", "剥蛟手", "伏猿客", "百兽克星"] },
	["background.beast_slayer"]      = { Pool = "jianghu", Titles = ["屠妖宗师", "猎山海", "斩魅人", "凶兽煞", "大荒猎主"] },
	["background.converted_crusader"] = { Pool = "monk",   Titles = ["还俗罗汉", "破戒武僧", "伏魔僧", "怒目金刚"] },
	["background.crucified"]         = { Pool = "monk",    Titles = ["劫余僧", "断枷行者", "苦难罗汉", "不死禅"] },
	["background.crusader"]          = { Pool = "monk",    Titles = ["戒律护法", "降龙武僧", "金刚护法", "伏虎罗汉", "少室铁僧"] },
	["background.gladiator"]         = { Pool = "western", Titles = ["百胜擂主", "生死霸王", "铁笼战神", "无败宗师", "擂台修罗"] },
	["background.hedge_knight"]      = { Pool = "master",  Titles = ["铁浮屠", "独行悍将", "重甲修罗", "万人敌", "陌刀霸王", "黑甲魔"] },
	["background.kings_guard"]       = { Pool = "master",  Titles = ["御前带刀", "大内高手", "禁苑遗卫", "锦衣镇抚", "龙渊卫"] },
	["background.lindwurm_slayer"]   = { Pool = "master",  Titles = ["斩蛟豪侠", "屠龙手", "太华煞", "断鳞客", "降蛟圣手"] },
	["background.nomad"]             = { Pool = "western", Titles = ["瀚海刀客", "新月弯刀", "沙暴狼", "大漠孤鹰", "西域刀神"] },
	["background.oathtaker"]         = { Pool = "master",  Titles = ["重誓剑客", "义薄云天", "守诺大侠", "忠义双全", "青天剑"] },
	["background.orc_slayer"]        = { Pool = "jianghu", Titles = ["破寨悍侠", "药人克星", "碎甲魔", "斩巨手", "荡魔先锋"] },
	["background.paladin"]           = { Pool = "master",  Titles = ["铁血戒律", "正道护法", "斩邪大侠", "重誓铁卫"] },
	["background.sellsword"]         = { Pool = "jianghu", Titles = ["红货名刀", "死契客", "江湖老鬼", "银刀客", "雇佣刀王", "冷血老手"] },
	["background.swordmaster"]       = { Pool = "master",  Titles = ["退隐剑圣", "白发剑宗", "一剑光寒", "剑痴", "老剑神", "青霜名宿"] }
};

// Apply global fallback Chinese character names onto vanilla Const.Strings so any unmapped recruit is still Chinese Wuxia
::Wuxia.ApplyGlobalChineseNames <- function()
{
	if (!("Strings" in ::Const) || ::Const.Strings == null) return;
	local combined = [];
	foreach (n in ::Wuxia.Config.NamePools.folk)    combined.push(n);
	foreach (n in ::Wuxia.Config.NamePools.jianghu) combined.push(n);
	foreach (n in ::Wuxia.Config.NamePools.master)  combined.push(n);

	if ("CharacterNames" in ::Const.Strings)
		::Const.Strings.CharacterNames = clone combined;
	if ("SouthernNames" in ::Const.Strings)
		::Const.Strings.SouthernNames = clone ::Wuxia.Config.NamePools.western;
	if ("BarbarianNames" in ::Const.Strings)
		::Const.Strings.BarbarianNames = clone ::Wuxia.Config.NamePools.northern;
	if ("KnightNames" in ::Const.Strings)
		::Const.Strings.KnightNames = clone ::Wuxia.Config.NamePools.master;
	if ("CharacterNamesFemale" in ::Const.Strings)
		::Const.Strings.CharacterNamesFemale = clone ::Wuxia.Config.NamePools.dancer;
};
