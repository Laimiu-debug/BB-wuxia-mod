// Non-destructive Wuxia World & Item Purification System:
//   1. Filters New Campaign Origin Picker to show ONLY curated pure Wuxia origins (`scenario.wx_*`) while keeping old saves loadable.
//   2. Suppresses out-of-place vanilla medieval European random road/town events (`m.Score = 0`) while keeping crisis/contract direct fires & boosting 66 Wuxia events.
//   3. Localizes all vanilla Noble Houses (`藩镇节度使世家`), Southern City-States (`西域丝路都护府`), and Faction Relations descriptions/mottos even under `mod_bbmod_zhcn`.
//   4. Replaces all vanilla Currency (`克朗 -> 纹银`), Repair Tools (`维修工具 -> 百炼修械铁料箱`), Supplies, Medicine, Ammo, Trade Goods & Utility Tools names & descriptions.

::Wuxia.Purify <- {
	// Known authentic Wuxia town names (built lazily once from `::Wuxia.Config.WorldVisuals.SettlementNames`)
	KnownTownNames = null,

	// 10 Authentic Tang/Ming Regional Warlord Noble Houses: [Name, Motto, Description]
	NobleHouses = [
		["陇西李氏藩府", "铁马秋风，靖安河洛", "世镇关陇的百年将门望族，麾下玄甲步槊与强弩营军纪森严，与朝堂及各路藩镇暗争雄长。"],
		["太原王氏节镇", "执戈卫社，威加并州", "盘踞北境雄关的节度使巨室，广蓄甲兵良马，常年征募江湖好手协防塞外战帮与绿林马贼。"],
		["清河崔氏经略府", "礼乐传家，暗掌枢机", "门生故吏遍布州县的百年世家大族，府中供养无数剑客幕僚，外示儒雅而内握重兵。"],
		["琅琊王氏留守司", "江左风流，铁壁东南", "坐拥江淮漕运富庶之地的名门留守府，水陆军械精良，广发官榜悬赏清剿水陆巨寇。"],
		["博陵崔氏宣慰府", "秉钺靖乱，令行九州", "奉旨督办地方团练与盐铁转运的宣慰大府，赏罚分明，最重守信重诺之镖局义社。"],
		["弘农杨氏都督府", "四世戎马，气吞崤函", "世代执掌险关要隘的勋贵都督府，崇尚硬功重甲与堂堂正正之战阵冲杀。"],
		["范阳卢氏镇抚司", "朔风鸣镝，先发制人", "久历边塞烽火的强悍军镇世家，帐下多蓄善射游骑与神机火器营，行事果决狠辣。"],
		["河东裴氏节度府", "紫绶金章，经略四方", "文武兼资的名臣将相世家，辖内商旅辐辏，常委托江湖义社护送珍稀军资与贡品。"],
		["颍川陈氏安抚司", "明德慎罚，抚定中原", "坐镇中原腹地大州的安抚使衙门，致力于安定城乡坊市、剪除邪派尸傀与山泽凶兽。"],
		["汝南袁氏招讨府", "门生故吏，威震淮南", "声势显赫的豪门招讨大府，喜结交天下成名豪杰，出手阔绰而门规森严。"]
	],

	// Authentic Silk-Road Oasis Protectorates (replacing Southern City-States): [Name, Description]
	OasisStates = [
		["敦煌沙州都护府", "扼守西域咽喉的丝路雄城，胡汉商队云集，城中设有演武生死擂与西域火器秘坊，胡商豪富重金雇请护镖好手。"],
		["高昌琉璃经略城", "大漠绿洲之上的繁华都护重镇，盛产孔雀蓝琉璃、奇门火药与西域香料，都护大军皆佩镔铁弯刀与三眼火铳。"],
		["于阗昆仑都督城", "背靠昆仑雪山、富甲西域的美玉雄州，往来驼队络绎不绝，城中常有塞外奇人与山海秘闻流传。"],
		["龟兹安西铁关城", "统摄沙海诸道的安西军镇雄城，甲仗精良、赏格丰厚，常发悬赏清剿沙路响马与古墓机关异变。"]
	],

	// Other Faction Type Display Names & Descriptions for Relations / Logs
	FactionTypeText = {
		bandits          = ["绿林山寨群寇", "啸聚山林、拦路剪径的绿林悍匪与江洋大盗。"],
		oriental_bandits = ["塞外沙路响马", "纵横大漠绿洲与丝路商道的凶悍弯刀马贼。"],
		barbarians       = ["关外黑水战帮", "盘踞苦寒塞北、崇尚血气蛮力与巨斧重锤的关外战帮。"],
		goblins          = ["南疆五毒伏兵", "隐匿瘴林深谷、精擅吹箭奇毒与捕网暗器的奇门苗寨伏兵。"],
		orcs             = ["邪派炼体药人", "经邪宗秘药催谷得铜皮铁骨、狂暴嗜血的失心炼体巨汉群。"],
		undead           = ["前朝古墓机关军", "长眠地宫千年、不知疲倦恐惧的前朝守陵青铜甲士。"],
		zombies          = ["湘西符水尸傀宗", "摇铃驱尸、借阴煞符水操控战殁尸骸的邪道宗派。"],
		beasts           = ["大荒山海异兽", "栖息荒山大泽、身怀异种内丹与奇材的《山海经》凶禽猛兽。"]
	},

	// Comprehensive Vanilla Supplies, Tools, Currency, Trade Goods & Consumables Wuxia Remap:
	// item.m.ID -> [ChineseWuxiaName, ChineseWuxiaDescription]
	ItemTextMap = {
		// Currency & Strategic Assets
		["supplies.money"]                = ["官铸足色纹银", "通行九州州府、茶肆书坊与无常鬼市的足色雪花纹银，可用于延揽豪杰、购置兵甲秘籍与悬壶问药。"],
		["supplies.armor_parts"]          = ["百炼修械铁料箱", "装有精铁甲片、牛筋束带、磨刀青石与桐油木炭的匠作木箱，供随队匠人修补受损兵刃与衣甲冠胄。"],
		["supplies.medicine"]             = ["杏林行军金疮箱", "备齐三七止血散、正骨竹夹板、艾绒银针与烈酒净布的医家药箱，供伤员在营帐中调理创口、恢复元气。"],
		["supplies.ammo"]                 = ["精翎羽箭暗器匣", "成捆雕翎破甲箭、踏张铁簇弩矢、铅子火药与飞刀镖囊，供队中神射与奇门暗器手临阵补给。"],
		["ammo.arrows"]                   = ["雕翎狼牙箭壶", "精选白桦箭杆配三棱破甲铁簇的满壶羽箭。"],
		["ammo.large_quiver_of_arrows"]   = ["重装牛皮大箭囊", "加宽熟牛皮精制的大号箭囊，可额外收纳更多雕翎羽箭。"],
		["ammo.bolts"]                    = ["神臂破甲铁弩匣", "专为踏张强弩打造的沉重精铁弩矢匣，专破重铠。"],
		["ammo.large_quiver_of_bolts"]    = ["军制双层铁弩匣", "藩镇强弩营制式双层弩矢木匣，备弹更为充裕。"],
		["ammo.powder_bag"]               = ["神机猛火药铅囊", "防潮油布包裹的颗粒黑火药与精铅弹丸，专供神机火铳装填轰击。"],

		// Food & Provisions (行军干粮酒水)
		["supplies.ground_grains"]        = ["炒熟行军粟米袋", "耐储易携的炒熟黄粟与麦糁，加水煮沸即成充饥热粥，乃走镖行伍最常备的基础口粮。"],
		["supplies.bread"]                = ["潼关千层焦香锅盔", "文火慢烤得外酥内实的大圆白面锅盔，久放不坏，顶饿耐饥。"],
		["supplies.roots_and_berries"]    = ["山野茯苓干果篓", "采自山林间的野山药、葛根与酸甜山茱萸，虽清淡粗砺亦可果腹。"],
		["supplies.dried_fruits"]         = ["西域琥珀葡萄干", "吐鲁番与沙州晾晒的蜜甜葡萄干与红枣杏脯，轻便生津，久行大漠不败。"],
		["supplies.dried_fish"]           = ["江淮风干咸鱼鲞", "江海渔埠海盐腌透晒干的青鱼鲞，咸鲜下饭。"],
		["supplies.dried_lamb"]           = ["塞外风干牛羊肉脯", "关外牧人以胡盐花椒腌制风干的紧实肉条，嚼劲十足、大补气力。"],
		["supplies.cured_venison"]        = ["陈年酱卤野鹿脯", "取山林健鹿精肉佐八角桂皮慢卤风干，气血双补之上等肉食。"],
		["supplies.smoked_ham"]           = ["金华松烟陈火腿", "松枝暗火熏制经年的上好带骨火腿，脂香浓郁，最慰风尘劳顿。"],
		["supplies.goat_cheese"]          = ["塞上酥油奶豆腐", "北境牧民熬煮凝成的醇厚奶酪饼，耐寒扛饿。"],
		["supplies.pickled_mushrooms"]    = ["巴蜀山珍盐渍菌坛", "泥封小坛腌渍的松茸与野山菌，脆嫩鲜美。"],
		["supplies.cured_rations"]        = ["九边精制牛肉干粮", "边镇帅府特制的油茶炒面与五香牛肉干，分量扎实、极耐远征。"],
		["supplies.rice"]                 = ["江南雪白香粳米", "太湖与江淮水乡出产的新收香粳米，粒粒晶莹。"],
		["supplies.beer"]                 = ["江湖大碗浑麦酒", "乡野酒肆自酿的醇厚浊酒，行路歇脚痛饮一碗最解乏气。"],
		["supplies.mead"]                 = ["桂花陈酿蜜露酒", "山野百花蜜佐丹桂封坛陈酿，甘洌回甜。"],
		["supplies.wine"]                 = ["兰陵琥珀郁金香酒", "泥封小瓮盛装的名酿美酒，酒香醇冽，侠客豪饮顿生豪情。"],
		["supplies.strange_meat"]         = ["腥臊异兽生肉块", "自荒山凶兽身上割下的粗粝兽肉，非穷途断粮不可轻易下咽。"],
		["supplies.fermented_unhold_heart"] = ["秘渍朱厌血髓脯", "以烈酒奇药浸渍凶猿血肉而成的刚猛补物。"],

		// Tactical Utility Tools, Nets, Bombs & Bandages (both `tool.*`/`weapon.*` and `tools.*` aliases)
		["item.bandage"]                  = ["金创止血白绢绷", "浸过白药粉的洁净棉绢长布条，临阵可在战场上为同袍包扎止血。"],
		["tools.bandage_item"]            = ["金创止血白绢绷", "浸过白药粉的洁净棉绢长布条，临阵可在战场上为同袍包扎止血。"],
		["accessory.bandage"]             = ["金创止血白绢绷", "浸过白药粉的洁净棉绢长布条，临阵可在战场上为同袍包扎止血。"],
		["accessory.antidote"]            = ["百草清瘴解毒散", "南疆药师秘配的清凉丹散，服之立解奇毒与蛊障。"],
		["tools.antidote_item"]           = ["百草清瘴解毒散", "南疆药师秘配的清凉丹散，服之立解奇毒与蛊障。"],
		["accessory.poison"]              = ["五步断肠淬刃毒膏", "南疆五毒秘炼奇毒，涂抹于兵刃箭簇之上可令受创之敌血脉麻痹、持续折损气血。"],
		["accessory.spider_poison"]       = ["黑寡妇麻痹毒囊液", "萃取自山泽毒蛛的阴寒毒液，淬于刀剑暗器之上可蚀伤经脉。"],
		["accessory.night_vision_elixir"] = ["夜枭明目灵露", "百草堂秘炼清凉眼药，夜战服之双目炯炯如昼，免受黑夜遮目之苦。"],
		["accessory.iron_will_potion"]    = ["虎骨壮胆行气酒", "猛药浸酿的霸道烈酒，服后酣战不知伤痛疲乏。"],
		["accessory.cat_potion"]          = ["灵猫踏雪轻身散", "辅以奇花异草炼制的提气丹散，服后身法暴涨如飞猫走壁。"],
		["accessory.lionheart_potion"]    = ["正气固心镇魂汤", "百年老参配朱砂熬制的定神汤药，服后定力如山、百邪难侵。"],
		["accessory.recovery_potion"]     = ["玉露回元调息散", "生津回气的灵药丹散，酣战中调息回气倍增。"],
		["accessory.sergeant_badge"]      = ["聚义总瓢把子虎符腰牌", "镌刻义社名号与猛虎纹章的精铜帅印腰牌，佩者振臂一呼即可稳住四方同袍军心。"],
		["tool.throwing_net"]             = ["牛筋铁坠困龙网", "浸油麻绳混编牛筋、四角缀铅铁重锤的罩网，掷出可死死缠住强敌身法。"],
		["tools.throwing_net"]            = ["牛筋铁坠困龙网", "浸油麻绳混编牛筋、四角缀铅铁重锤的罩网，掷出可死死缠住强敌身法。"],
		["tool.reinforced_throwing_net"]  = ["乌金毒刺天罗网", "掺入韧铁细丝与倒刺铁钩的奇门重网，寻常刀剑极难一击割破。"],
		["tools.reinforced_throwing_net"] = ["乌金毒刺天罗网", "掺入韧铁细丝与倒刺铁钩的奇门重网，寻常刀剑极难一击割破。"],
		["weapon.smoke_bomb"]             = ["唐门迷影障目烟弹", "内藏硝磺艾叶的薄壳陶丸，掷地爆开浓密白烟，遮蔽敌方弓弩视线并助己方脱身。"],
		["tools.smoke_bomb_item"]         = ["唐门迷影障目烟弹", "内藏硝磺艾叶的薄壳陶丸，掷地爆开浓密白烟，遮蔽敌方弓弩视线并助己方脱身。"],
		["weapon.daze_bomb"]              = ["霹雳堂震魂雷火弹", "轰然炸响、强光夺目的奇门火药铁丸，能震得周遭强敌耳鸣目眩、阵脚大乱。"],
		["tools.daze_bomb_item"]          = ["霹雳堂震魂雷火弹", "轰然炸响、强光夺目的奇门火药铁丸，能震得周遭强敌耳鸣目眩、阵脚大乱。"],
		["weapon.fire_bomb"]              = ["神机猛火油燃烧瓮", "装满西域猛火油与磷砂的陶瓮，碎裂后烈焰铺地，焚甲灼身。"],
		["tools.fire_bomb_item"]          = ["神机猛火油燃烧瓮", "装满西域猛火油与磷砂的陶瓮，碎裂后烈焰铺地，焚甲灼身。"],
		["weapon.acid_flask"]             = ["五毒蚀铁化甲毒瓶", "盛有百毒腐骨浓液的琉璃瓶，泼洒之处精铁重铠亦被迅速蚀穿。"],
		["tools.acid_flask_item"]         = ["五毒蚀铁化甲毒瓶", "盛有百毒腐骨浓液的琉璃瓶，泼洒之处精铁重铠亦被迅速蚀穿。"],
		["weapon.holy_water"]             = ["龙虎山天师紫金符水", "朱砂符箓加持的纯阳辟邪灵水，泼中湘西尸傀与前朝冥俑如滚汤泼雪。"],
		["tools.holy_water_item"]         = ["龙虎山天师紫金符水", "朱砂符箓加持的纯阳辟邪灵水，泼中湘西尸傀与前朝冥俑如滚汤泼雪。"],

		// Trade Goods & Loot Valuables (行商奇货与缴获财帛)
		["misc.cloth_rolls"]              = ["苏杭织造素锦绸匹", "江南机坊织就的细密绸缎布匹，运往北方大镇与边塞最受追捧。"],
		["misc.furs"]                     = ["关外紫貂雪狐皮货", "塞北猎户硝制妥帖的厚实兽裘，运往繁华州府可获厚利。"],
		["misc.salt"]                     = ["淮南官引雪花精盐", "洁白细密的官场大包食盐，乱世之中堪比硬通白银。"],
		["misc.amber_shards"]             = ["沧海松脂千年琥珀", "温润澄黄的天然老琥珀原石，富商大贾与方士皆喜收购。"],
		["misc.peat_bricks"]              = ["乌金耐燃石炭砖", "火力绵长的上好无烟石炭，铁匠铸剑与北境御寒皆离不开。"],
		["misc.copper_ingots"]            = ["官炉精铸赤铜锭", "沉甸甸的足斤赤铜料锭，乃铸造钱币与青铜器皿的紧俏官料。"],
		["misc.dies"]                     = ["蜀中五彩矿物颜料", "朱砂、石青、藤黄研磨分装的名贵丹青色料。"],
		["misc.uncut_gems"]               = ["昆仑未琢羊脂玉璞", "采自西域河床的温润玉石与宝石原矿，一经名匠雕琢价值连城。"],
		["misc.spices"]                   = ["南海番舶龙脑丁香", "自远洋海舶与丝路驼队运抵的珍奇香料，王侯酒席千金难求。"],
		["misc.silk"]                     = ["云锦织金天蚕丝绸", "流光溢彩的顶级织锦华绸，寸锦寸金。"],
		["misc.incense"]                  = ["海南沉水奇楠名香", "焚之清气满室、凝神静气的名贵沉檀香木。"],
		["loot.silverware"]               = ["缴获錾花纯银酒器", "自豪强营寨缴获的精巧银壶银盏，可在城中市集折换纹银。"],
		["loot.golden_chalice"]           = ["缴获错金镶玉爵杯", "镶嵌美玉的纯金古爵，价值不菲。"],
		["loot.signet_ring"]              = ["藩镇将校蟠龙金印戒", "镌有私印纹章的沉重赤金扳指，可在商肆变现。"],
		["loot.ancient_gold_coins"]       = ["前朝秘冢五铢金饼", "地宫古墓中出土的足赤古金饼，成色极佳。"],
		["loot.valuable_furs"]            = ["极品雪山银狐大氅料", "罕见无瑕的珍稀异兽毛皮。"],
		["loot.jeweled_crown"]            = ["前朝嵌宝紫金礼冠", "缀满明珠宝石的古墓王侯金冠，堪称价值连城之重宝。"],

		// Wardogs & Falcons
		["accessory.wardog"]              = ["关外护院细犬", "机警凶悍的猎犬，战时可解索放犬追袭残敌。"],
		["accessory.armored_wardog"]      = ["披甲塞外猛獒", "披挂熟皮铁叶护胸甲的凶猛藏獒，悍不畏死。"],
		["accessory.warhound"]            = ["黑水裂喉巨獒", "北境战帮驯养的巨型猛犬，扑咬之力惊人。"],
		["accessory.armored_warhound"]    = ["重甲铁刺巨獒", "披乌铁护甲的塞北巨獒。"],
		["accessory.falcon"]              = ["塞上苍羽海东青", "神骏敏锐的猎鹰，临阵放飞可盘旋高空探破林间伏兵视野。"],

		// Vanilla Taxidermist Armor Upgrades, Potions & Dyes (防止百工丹坊出现原版英文配方名)
		["armor_upgrade.direwolf_pelt"]             = ["阴山天狗苍狼披肩", "硝制凶狼厚裘披挂于肩甲之上，威慑四周敌胆。"],
		["armor_upgrade.lindwurm_scales"]           = ["太华毒蛟重鳞披风", "缀连大泽肥遗毒蛟坚鳞而成的护背披挂，刀箭难伤且不惧毒液蚀甲。"],
		["armor_upgrade.unhold_fur_upgrade"]        = ["雪山朱厌白毛大氅", "取巨猿厚实白革缝制的护身大氅，大幅消减远矢穿刺冲击。"],
		["armor_upgrade.bone_platings"]             = ["千钧异兽护心骨板", "以凶兽铁骨打磨捆扎的外挂护板，可硬生生替身甲抵挡首次重击。"],
		["armor_upgrade.horn_plate"]                = ["荒原巨犀角质胸甲片", "坚韧无比的异兽角质护胸甲片，减轻近身劈砍受损。"],
		["armor_upgrade.light_padding_replacement"] = ["天蚕软丝减重内衬", "以江南天蚕丝絮替换沉重麻布内衬，显著减轻披甲内息负担。"],
		["armor_upgrade.additional_padding"]        = ["双层绵甲卸力内衬", "加厚丝绵内衬以缓冲钝器与穿甲内劲震荡。"],
		["armor_upgrade.protective_runes"]          = ["玄门镇魂护身符箓", "道门朱砂绘就的护甲符布，稳固穿戴者心神定力。"],
		["armor_upgrade.hyena_fur"]                 = ["西山蛊雕斑革肩披", "轻捷凶悍的荒漠异兽皮披挂，助长抢攻先机身法。"],
		["armor_upgrade.serpent_skin"]              = ["苍梧巴蛇避火鳞衬", "滑腻冰凉的巨蟒青鳞内衬，减轻烈火与硝烟灼伤。"],
		["accessory.berserker_mushrooms"]           = ["黑水疯魔赤伞菌", "塞北战帮秘传毒菌，嚼服后痛觉尽失、劈杀凶威暴涨而疏于守御。"],
		["accessory.happy_powder"]                  = ["极乐忘忧迷仙散", "奇门秘制欢喜丹粉，强提心气却暗损体魄。"],
		["misc.paint_set"]                          = ["百工矿物绘甲丹青匣", "调配齐备的天然矿物油彩，可为冠胄盾甲重染门派色泽。"],
		["misc.paint_black"]                        = ["徽州松烟玄墨漆", "深沉凝重的乌黑甲胄桐油漆料。"],
		["misc.paint_red"]                          = ["辰州朱砂赤丹漆", "鲜亮肃杀的丹红甲胄漆料。"],
		["misc.paint_orange_red"]                   = ["西域雄黄赤金漆", "灿若烈火的橙红甲胄矿物漆料。"],
		["misc.paint_white_blue"]                   = ["景德青花瓷白漆", "素雅清冷的白底青蓝甲胄漆料。"],
		["misc.paint_white_green_yellow"]           = ["蜀锦翠黄三彩漆", "明快鲜明的白绿藤黄甲胄漆料。"]
	}
};

::Wuxia.Purify.isWuxiaTownName <- function( _name )
{
	if (_name == null || _name == "") return false;
	if (::Wuxia.Purify.KnownTownNames == null)
	{
		::Wuxia.Purify.KnownTownNames = {};
		if ("WorldVisuals" in ::Wuxia.Config && "SettlementNames" in ::Wuxia.Config.WorldVisuals)
		{
			foreach (_poolKey, arr in ::Wuxia.Config.WorldVisuals.SettlementNames)
			{
				foreach (nm in arr)
					::Wuxia.Purify.KnownTownNames[nm] <- true;
			}
		}
	}
	return (_name in ::Wuxia.Purify.KnownTownNames);
};

::Wuxia.Purify.applyItemText <- function( _item, _scriptName = "" )
{
	if (_item == null || !("m" in _item)) return;
	if (!("WX_PurifyWrapped" in _item))
	{
		_item.WX_PurifyWrapped <- true;
		if (::Wuxia.hasMember(_item, "getName") && typeof _item.getName == "function")
		{
			_item.WX_OrigItemGetName <- _item.getName;
			_item.getName <- (function()
			{
				::Wuxia.Purify.applyItemText(this);
				return this.WX_OrigItemGetName();
			}).bindenv(_item);
		}
		if (::Wuxia.hasMember(_item, "getDescription") && typeof _item.getDescription == "function")
		{
			_item.WX_OrigItemGetDesc <- _item.getDescription;
			_item.getDescription <- (function()
			{
				::Wuxia.Purify.applyItemText(this);
				return ::Wuxia.Purify.rewriteCurrencyAndSupplyTerms(this.WX_OrigItemGetDesc());
			}).bindenv(_item);
		}
	}
	local id = (::Wuxia.hasMember(_item.m, "ID") && _item.m.ID != null) ? _item.m.ID : "";
	if (!(id in ::Wuxia.Purify.ItemTextMap) && id.len() > 5 && id.slice(-5) == "_item")
	{
		local strippedId = id.slice(0, -5);
		if (strippedId in ::Wuxia.Purify.ItemTextMap)
			id = strippedId;
	}
	if (!(id in ::Wuxia.Purify.ItemTextMap) && id.len() > 5 && id.slice(id.len() - 5) == "_item")
	{
		local baseId = id.slice(0, id.len() - 5);
		if (baseId in ::Wuxia.Purify.ItemTextMap) id = baseId;
	}
	if (!(id in ::Wuxia.Purify.ItemTextMap) && _scriptName != "" && _scriptName.find("scripts/items/") == 0)
	{
		local rel = ::Wuxia.Purify.strReplace(_scriptName.slice(14), "/", ".");
		if (rel in ::Wuxia.Purify.ItemTextMap)
			id = rel;
		else if (rel.len() > 5 && rel.slice(rel.len() - 5) == "_item")
		{
			local relBase = rel.slice(0, rel.len() - 5);
			if (relBase in ::Wuxia.Purify.ItemTextMap)
				id = relBase;
		}
		else if (rel == "ammo.quiver_of_arrows")
			id = "ammo.arrows";
		else if (rel == "ammo.quiver_of_bolts")
			id = "ammo.bolts";
	}
	if (!(id in ::Wuxia.Purify.ItemTextMap))
	{
		local curNm = (::Wuxia.hasMember(_item.m, "Name") && _item.m.Name != null) ? _item.m.Name : "";
		local curIc = (::Wuxia.hasMember(_item.m, "Icon") && _item.m.Icon != null) ? _item.m.Icon : "";
		local clsNm = ("ClassName" in _item && _item.ClassName != null) ? _item.ClassName : "";
		if (clsNm == "money_item" || _scriptName.find("money_item") != null || curNm == "克朗" || curNm == "Crowns" || curIc.find("money") != null)
			id = "supplies.money";
		else if (clsNm == "armor_parts_item" || _scriptName.find("armor_parts_item") != null || curIc.find("armor_parts") != null)
			id = "supplies.armor_parts";
		else if (clsNm != "" && clsNm.find("wx_") != 0)
		{
			local clsBase = (clsNm.len() > 5 && clsNm.slice(clsNm.len() - 5) == "_item") ? clsNm.slice(0, clsNm.len() - 5) : clsNm;
			foreach (pfx in ["supplies.", "misc.", "loot.", "tools.", "accessory.", "ammo.", "weapon.", "tool.", "item."])
			{
				if ((pfx + clsNm) in ::Wuxia.Purify.ItemTextMap) { id = pfx + clsNm; break; }
				if ((pfx + clsBase) in ::Wuxia.Purify.ItemTextMap) { id = pfx + clsBase; break; }
			}
		}
	}
	if (id in ::Wuxia.Purify.ItemTextMap)
	{
		local entry = ::Wuxia.Purify.ItemTextMap[id];
		if (!("WX_TextPurified" in _item.m) || _item.m.WX_TextPurified != id || _item.m.Name != entry[0])
		{
			_item.m.Name = entry[0];
			_item.m.Description = entry[1];
			_item.m.WX_TextPurified <- id;
			if (id == "supplies.money")
			{
				local moneyDesc = entry[1];
				_item.getName <- (function()
				{
					if (::Wuxia.hasMember(this.m, "Amount") && this.m.Amount > 0)
						return this.m.Amount + " 两官铸足色纹银";
					return "官铸足色纹银";
				}).bindenv(_item);
				_item.getDescription <- (function()
				{
					return moneyDesc;
				}).bindenv(_item);
			}
			else
			{
				local itemPureName = entry[0];
				local itemPureDesc = entry[1];
				_item.getName <- (function()
				{
					this.m.Name = itemPureName;
					this.m.Description = itemPureDesc;
					return itemPureName;
				}).bindenv(_item);
				_item.getDescription <- (function()
				{
					this.m.Name = itemPureName;
					this.m.Description = itemPureDesc;
					return itemPureDesc;
				}).bindenv(_item);
			}
		}
	}
};

::Wuxia.Purify.strReplace <- function( _str, _old, _new )
{
	if (_str == null || _old == null || _old == "") return _str;
	local pos = _str.find(_old);
	if (pos == null) return _str;
	local out = "";
	local start = 0;
	local oldLen = _old.len();
	while (pos != null)
	{
		out += _str.slice(start, pos) + _new;
		start = pos + oldLen;
		pos = _str.find(_old, start);
	}
	out += _str.slice(start);
	return out;
};

::Wuxia.Purify.rewriteCurrencyAndSupplyTerms <- function( _str )
{
	if (_str == null || typeof _str != "string" || _str == "") return _str;
	local s = _str;
	s = ::Wuxia.Purify.strReplace(s, "克朗", "两纹银");
	s = ::Wuxia.Purify.strReplace(s, "两两纹银", "两纹银");
	s = ::Wuxia.Purify.strReplace(s, "维修工具", "修械铁料");
	s = ::Wuxia.Purify.strReplace(s, "工具与补给", "修械铁料");
	s = ::Wuxia.Purify.strReplace(s, "工具和补给", "修械铁料");
	s = ::Wuxia.Purify.strReplace(s, "医疗物资", "金疮药材");
	s = ::Wuxia.Purify.strReplace(s, "医药补给", "金疮药材");
	s = ::Wuxia.Purify.strReplace(s, "佣兵团", "江湖义社");
	s = ::Wuxia.Purify.strReplace(s, "军团声望", "江湖威名");
	s = ::Wuxia.Purify.strReplace(s, "战团声望", "江湖威名");
	s = ::Wuxia.Purify.strReplace(s, "公司声望", "江湖威名");
	s = ::Wuxia.Purify.strReplace(s, "雇用随从", "延揽江湖幕僚");
	s = ::Wuxia.Purify.strReplace(s, "非战斗随从", "江湖幕僚");
	s = ::Wuxia.Purify.strReplace(s, "随从栏位", "幕僚席位");
	s = ::Wuxia.Purify.strReplace(s, "随从席位", "幕僚席位");
	s = ::Wuxia.Purify.strReplace(s, "名随从", "名江湖幕僚");
	s = ::Wuxia.Purify.strReplace(s, "每回合疲劳恢复", "每回合内息恢复");
	s = ::Wuxia.Purify.strReplace(s, "疲劳值恢复率", "内息调息恢复");
	s = ::Wuxia.Purify.strReplace(s, "疲劳恢复率", "内息调息恢复");
	s = ::Wuxia.Purify.strReplace(s, "疲劳值上限", "内息上限");
	s = ::Wuxia.Purify.strReplace(s, "最大疲劳值", "内息上限");
	s = ::Wuxia.Purify.strReplace(s, "最大疲劳", "内息上限");
	s = ::Wuxia.Purify.strReplace(s, "疲劳上限", "内息上限");
	s = ::Wuxia.Purify.strReplace(s, "可用疲劳值", "可用内息");
	s = ::Wuxia.Purify.strReplace(s, "可用疲劳", "可用内息");
	s = ::Wuxia.Purify.strReplace(s, "累积疲劳值", "消耗内息");
	s = ::Wuxia.Purify.strReplace(s, "累积疲劳", "消耗内息");
	s = ::Wuxia.Purify.strReplace(s, "产生疲劳", "消耗内息");
	s = ::Wuxia.Purify.strReplace(s, "当前疲劳值", "当前已耗内息");
	s = ::Wuxia.Purify.strReplace(s, "当前疲劳", "当前已耗内息");
	s = ::Wuxia.Purify.strReplace(s, "疲劳恢复", "内息调息恢复");
	s = ::Wuxia.Purify.strReplace(s, "疲劳惩罚", "内息负重折损");
	s = ::Wuxia.Purify.strReplace(s, "疲劳消耗", "内息消耗");
	s = ::Wuxia.Purify.strReplace(s, "疲劳值", "内息");
	s = ::Wuxia.Purify.strReplace(s, "疲劳", "内息");
	s = ::Wuxia.Purify.strReplace(s, "Maximum Fatigue", "内息上限");
	s = ::Wuxia.Purify.strReplace(s, "Max. Fatigue", "内息上限");
	s = ::Wuxia.Purify.strReplace(s, "Fatigue", "内息");
	return s;
};

if ("HooksMod" in ::Wuxia && ::Wuxia.HooksMod != null)
{
	// 1. Hook `scripts/items/item` so every vanilla supply/tool/trade/loot item displays Wuxia Name & Description
	::Wuxia.HooksMod.hook("scripts/items/item", function( q )
	{
		if (::Wuxia.qHas(q, "getName"))
		{
			q.getName = @(__original) function()
			{
				::Wuxia.Purify.applyItemText(this);
				return __original();
			};
		}

		if (::Wuxia.qHas(q, "getDescription"))
		{
			q.getDescription = @(__original) function()
			{
				::Wuxia.Purify.applyItemText(this);
				return ::Wuxia.Purify.rewriteCurrencyAndSupplyTerms(__original());
			};
		}

		if (::Wuxia.qHas(q, "getTooltip"))
		{
			q.getTooltip = @(__original) function()
			{
				::Wuxia.Purify.applyItemText(this);
				local ret = __original();
				if (ret != null && typeof ret == "array")
				{
					for (local i = 0; i < ret.len(); i = ++i)
					{
						local row = ret[i];
						if (row != null && typeof row == "table" && ("text" in row) && typeof row.text == "string")
							row.text = ::Wuxia.Purify.rewriteCurrencyAndSupplyTerms(row.text);
					}
				}
				return ret;
			};
		}
	});

	// 1b. Hook `scripts/items/supplies/money_item` directly because subclass overrides `getName()` & `getTooltip()`
	::Wuxia.HooksMod.hook("scripts/items/supplies/money_item", function( q )
	{
		if (::Wuxia.qHas(q, "getName", false))
		{
			q.getName = @(__original) function()
			{
				::Wuxia.Purify.applyItemText(this);
				if (::Wuxia.hasMember(this.m, "Amount") && this.m.Amount > 0)
					return this.m.Amount + " 两官铸足色纹银";
				return "官铸足色纹银";
			};
		}

		if (::Wuxia.qHas(q, "getDescription", false))
		{
			q.getDescription = @(__original) function()
			{
				::Wuxia.Purify.applyItemText(this);
				return this.m.Description;
			};
		}

		if (::Wuxia.qHas(q, "getTooltip", false))
		{
			q.getTooltip = @(__original) function()
			{
				::Wuxia.Purify.applyItemText(this);
				local ret = __original();
				if (ret != null && typeof ret == "array")
				{
					for (local i = 0; i < ret.len(); i = ++i)
					{
						local row = ret[i];
						if (row != null && typeof row == "table" && ("text" in row) && typeof row.text == "string")
							row.text = ::Wuxia.Purify.rewriteCurrencyAndSupplyTerms(row.text);
					}
				}
				return ret;
			};
		}
	});

	// 1c. Hook `scripts/items/supplies/food_item` directly so localized food overrides (e.g. `mod_bbmod_zhcn`) also purify cleanly
	::Wuxia.HooksMod.hook("scripts/items/supplies/food_item", function( q )
	{
		if (::Wuxia.qHas(q, "getName", false))
		{
			q.getName = @(__original) function()
			{
				::Wuxia.Purify.applyItemText(this);
				if ("WX_TextPurified" in this.m)
					return this.m.Name;
				return __original();
			};
		}

		if (::Wuxia.qHas(q, "getDescription", false))
		{
			q.getDescription = @(__original) function()
			{
				::Wuxia.Purify.applyItemText(this);
				if ("WX_TextPurified" in this.m)
					return this.m.Description;
				return ::Wuxia.Purify.rewriteCurrencyAndSupplyTerms(__original());
			};
		}

		if (::Wuxia.qHas(q, "getTooltip", false))
		{
			q.getTooltip = @(__original) function()
			{
				::Wuxia.Purify.applyItemText(this);
				local ret = __original();
				if (ret != null && typeof ret == "array")
				{
					for (local i = 0; i < ret.len(); i = ++i)
					{
						local row = ret[i];
						if (row != null && typeof row == "table" && ("text" in row) && typeof row.text == "string")
							row.text = ::Wuxia.Purify.rewriteCurrencyAndSupplyTerms(row.text);
					}
				}
				return ret;
			};
		}
	});

	// 2. Pure Wuxia Starting Origins Filter: hide out-of-place medieval Western origins in New Campaign UI
	//    while preserving all scenarios in `m.Scenarios` so existing saves load cleanly!
	::Wuxia.HooksMod.hook("scripts/scenarios/scenario_manager", function( q )
	{
		if (::Wuxia.qHas(q, "getScenariosForUI"))
		{
			q.getScenariosForUI = @(__original) function()
			{
				local raw = __original();
				if (raw == null || typeof raw != "array") return raw;
				local pure = [];
				foreach (entry in raw)
				{
					if (entry != null && typeof entry == "table" && ("ID" in entry) && typeof entry.ID == "string")
					{
						if (entry.ID.find("scenario.wx_") == 0)
							pure.push(entry);
					}
				}
				return pure.len() > 0 ? pure : raw;
			};
		}
	});

	// 3. Suppress Out-of-Place Vanilla Medieval Random Events (`m.Score = 0`), Keep Wuxia Events, Ambition/Retinue System Events & Crisis Progression!
	::Wuxia.HooksMod.hook("scripts/events/event", function( q )
	{
		if (::Wuxia.qHas(q, "update"))
		{
			q.update = @(__original) function()
			{
				local id = (::Wuxia.hasMember(this.m, "ID") && this.m.ID != null) ? this.m.ID : "";
				if (id.find("event.wx_") == 0)
				{
					__original();
					if (this.m.Score > 0)
						this.m.Score = ::Math.floor(this.m.Score * 1.45) + 8;
					return;
				}
				// Preserve essential campaign progression events (Ambitions, Retinue unlocks, Desertion, Dismissals, Crisis state events)
				if (id.find("event.crisis.") == 0
					|| id == "event.choose_ambition"
					|| id == "event.ambition_fulfilled"
					|| id == "event.ambition_failed"
					|| id == "event.retinue_slot"
					|| id == "event.desertion"
					|| id == "event.helped_caravan"
					|| id.find("event.dismiss_") == 0)
				{
					__original();
					return;
				}
				this.m.Score = 0;
			};
		}
	});

	// 4. Full Faction Localization (Noble Houses -> 藩镇节度使世家, City-States -> 西域丝路都护府, Minor Factions)
	::Wuxia.HooksMod.hook("scripts/factions/noble_faction", function( q )
	{
		q.WX_ApplyNobleLore <- function()
		{
			local list = ::Wuxia.Purify.NobleHouses;
			local entry = list[::Math.abs(this.getID()) % list.len()];
			this.m.Name = entry[0];
			if (::Wuxia.hasMember(this.m, "Motto")) this.m.Motto = entry[1];
			if (::Wuxia.hasMember(this.m, "Description")) this.m.Description = entry[2];
		};

		if (::Wuxia.qHas(q, "getMotto"))
		{
			q.getMotto = @(__original) function()
			{
				this.WX_ApplyNobleLore();
				return __original();
			};
		}

		if (::Wuxia.qHas(q, "getDescription"))
		{
			q.getDescription = @(__original) function()
			{
				this.WX_ApplyNobleLore();
				return __original();
			};
		}
	});

	::Wuxia.HooksMod.hook("scripts/factions/city_state_faction", function( q )
	{
		q.WX_ApplyOasisLore <- function()
		{
			local list = ::Wuxia.Purify.OasisStates;
			local entry = list[::Math.abs(this.getID()) % list.len()];
			this.m.Name = entry[0];
			if (::Wuxia.hasMember(this.m, "Description")) this.m.Description = entry[1];
		};

		if (::Wuxia.qHas(q, "getName"))
		{
			q.getName = @(__original) function()
			{
				this.WX_ApplyOasisLore();
				return __original();
			};
		}

		if (::Wuxia.qHas(q, "getDescription"))
		{
			q.getDescription = @(__original) function()
			{
				this.WX_ApplyOasisLore();
				return __original();
			};
		}

		if (::Wuxia.qHas(q, "onDeserialize"))
		{
			q.onDeserialize = @(__original) function( _in )
			{
				__original(_in);
				this.WX_ApplyOasisLore();
			};
		}
	});

	// 5. Guard `createRandomName` on Named items when instantiated before World.FactionManager exists (e.g. Blueprints / Arena / SelfTest)
	foreach (namedBase in [
		"scripts/items/weapons/named/named_weapon",
		"scripts/items/armor/named/named_armor",
		"scripts/items/helmets/named/named_helmet",
		"scripts/items/shields/named/named_shield"
	])
	{
		::Wuxia.HooksMod.hook(namedBase, function( q )
		{
			if (::Wuxia.qHas(q, "createRandomName"))
			{
				q.createRandomName = @(__original) function()
				{
					if (!("World" in ::getroottable()) || ::World == null || !("FactionManager" in ::World) || ::World.FactionManager == null)
						return "传世百炼神兵";
					try { return __original(); } catch (_e) { return "传世百炼神兵"; }
				};
			}
		});
	}

	// 6. Rewrite Topbar Asset & Strategic Tooltips (`克朗 -> 纹银`, `维修工具 -> 修械铁料`, `佣兵团 -> 江湖义社`)
	::Wuxia.HooksMod.hook("scripts/ui/screens/tooltip/tooltip_events", function( q )
	{
		foreach (fnName in ["general_queryUIElementTooltipData", "strategic_queryUIElementTooltipData", "tactical_queryUIElementTooltipData"])
		{
			if (::Wuxia.qHas(q, fnName))
			{
				q[fnName] = @(__original) function( _entityId, _elementId, _elementOwner )
				{
					local ret = __original(_entityId, _elementId, _elementOwner);
					if (ret != null && typeof ret == "array")
					{
						for (local i = 0; i < ret.len(); i = ++i)
						{
							local row = ret[i];
							if (row != null && typeof row == "table" && ("text" in row) && typeof row.text == "string")
								row.text = ::Wuxia.Purify.rewriteCurrencyAndSupplyTerms(row.text);
						}
					}
					return ret;
				};
			}
		}
	});
}
