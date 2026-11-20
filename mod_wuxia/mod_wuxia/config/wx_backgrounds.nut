// Non-destructive Wuxia mapping for vanilla & DLC Character Backgrounds.
// IMPORTANT: Vanilla background IDs ("background.farmhand", etc.) are NEVER altered, preserving all 300+ road/camp events!
// Tier: 0 = 底层苦力 (0 manuals), 1 = 江湖行当 (1 common manual), 2 = 成名高手 (1 sect + 1 common manual).

::Wuxia.Config.Backgrounds <- {
	// =========================================================================
	// Tier 0: 底层苦力 / 市井平民（雇佣低廉，0 本预装功法，纯看根骨盲盒）
	// =========================================================================
	["background.beggar"] = { Tier = 0, Name = "行乞人",     Desc = "常年混迹城隍庙与街角施粥棚，熟知市井暗巷与落脚破庙，虽体弱气虚，偶有根骨清奇之辈。" },
	["background.cripple"] = { Tier = 0, Name = "负伤江湖客", Desc = "早年争斗落下旧疾，如今靠帮闲糊口。虽身带残损，阅历尚在。" },
	["background.daytaler"] = { Tier = 0, Name = "走脚短工",   Desc = "在码头、车马行与作坊间打零工谋生，筋骨耐劳，肯为银钱卖命。" },
	["background.eunuch"] = { Tier = 0, Name = "净身内侍",   Desc = "自深宅大院或旧内廷流落民间，察言观色极精，不惹是非。" },
	["background.farmhand"] = { Tier = 0, Name = "庄稼把式",   Desc = "自幼在田垄间挑担挥锄，气血浑厚、耐力惊人，是打熬横练外功的好胚子。" },
	["background.fisherman"] = { Tier = 0, Name = "江津渔夫",   Desc = "常年在风浪渡口撒网谋生，下盘稳健，熟识水路汛情与捕网手法。" },
	["background.gravedigger"] = { Tier = 0, Name = "义庄掘土人", Desc = "终日与荒冢义庄打交道，胆气异于常人，见惯尸骸邪祟亦面不改色。" },
	["background.historian"] = { Tier = 0, Name = "访古书生",   Desc = "穷经皓首校勘残碑旧谱的落魄文人，不通拳脚，却认得前朝古篆与秘境典籍。" },
	["background.juggler"] = { Tier = 0, Name = "天桥卖艺人", Desc = "走街串巷耍飞刀吞火丸讨赏钱，手眼协调敏捷，颇具暗器与轻身天分。" },
	["background.mason"] = { Tier = 0, Name = "营造石匠",   Desc = "常年开山凿石修筑寨墙，双臂沉稳有力，精熟机关石锁。" },
	["background.messenger"] = { Tier = 0, Name = "急脚驿使",   Desc = "沿官道驿站昼夜奔走递送羽檄，肺活气长，最擅翻山赶路。" },
	["background.miller"] = { Tier = 0, Name = "乡集磨坊主", Desc = "经手四乡粮秣碾磨与采买，身板敦实，熟稔粮道行情。" },
	["background.miner"] = { Tier = 0, Name = "深井矿工",   Desc = "在幽暗矿洞中抡镐掘铁，臂力过人，习惯狭窄死斗。" },
	["background.minstrel"] = { Tier = 0, Name = "江湖说书人", Desc = "混迹茶楼酒肆拍醒木讲武林轶闻，三教九流皆能攀谈几句。" },
	["background.peddler"] = { Tier = 0, Name = "走街货郎",   Desc = "挑担穿村走巷贩卖针头线脑与跌打药散，精于算计议价。" },
	["background.pimp"] = { Tier = 0, Name = "市井掮客",   Desc = "在烟花巷陌与地下赌坊牵线搭桥，深谙三教九流的人情暗规。" },
	["background.ratcatcher"] = { Tier = 0, Name = "地窖捕鼠人", Desc = "专在粮仓暗渠追捕毒虫硕鼠，手脚麻利，眼疾手快。" },
	["background.refugee"] = { Tier = 0, Name = "流离饥民",   Desc = "因兵燹匪祸背井离乡的逃难百姓，只求一口饱饭安身。" },
	["background.servant"] = { Tier = 0, Name = "大宅家仆",   Desc = "曾在世家门阀伺候车马起居，懂得高门规矩与行囊打理。" },
	["background.shepherd"] = { Tier = 0, Name = "山坡牧羊人", Desc = "在荒山草甸放牧驱狼，惯使飞石投索，耳目灵通。" },
	["background.slave"] = { Tier = 0, Name = "负债苦役",   Desc = "因欠下印子钱或官司沦为苦役，只要给条活路便敢拼死向前。" },
	["background.tailor"] = { Tier = 0, Name = "巧手裁缝",   Desc = "熟稔锦缎软革剪裁缝补，对内衬软甲与衣袍负重颇有心得。" },
	["background.vagabond"] = { Tier = 0, Name = "四海漂泊客", Desc = "餐风露宿走遍南北州府，耐饥寒、识野径。" },

	// =========================================================================
	// Tier 1: 江湖行当 / 习武散人（入队自动预装 1 本契合行当的一重大路货）
	// =========================================================================
	["background.anatomist"] = { Tier = 1, Name = "验方医者",   Desc = "专研经络穴位、奇毒脏腑与异兽药理的游医，略通吐纳护脉之法。", CommonPool = ["wx_manual_tuna", "wx_manual_xiushou"] },
	["background.apprentice"] = { Tier = 1, Name = "武馆学徒",   Desc = "在城中武馆擦拭兵器、跟着教头蹲桩练拳的年轻弟子，底子干净扎实。", CommonPool = ["wx_manual_jichujian", "wx_manual_liuheqiang", "wx_manual_luohan"] },
	["background.bastard"] = { Tier = 1, Name = "世家庶子",   Desc = "名门大族不入族谱的外室庶子，偷学过几手家传把式，急欲在江湖扬名。", CommonPool = ["wx_manual_jichujian", "wx_manual_wuhudao", "wx_manual_tuna"] },
	["background.belly_dancer"] = { Tier = 1, Name = "西域舞伎",   Desc = "随丝路商帮东来的舞者，腰肢轻灵柔韧，袖中偶藏防身飞针。", CommonPool = ["wx_manual_jianbu", "wx_manual_xiushou", "wx_manual_tuna"] },
	["background.bowyer"] = { Tier = 1, Name = "制弓匠人",   Desc = "世代鞣木削竹制强弓硬弩，自己亦练有一手百步调息准头。", CommonPool = ["wx_manual_tuna", "wx_manual_xingqi"] },
	["background.brawler"] = { Tier = 1, Name = "市井拳师",   Desc = "在码头野擂与酒肆打行靠双拳吃饭的硬汉，筋骨粗壮，擅长贴身肉搏。", CommonPool = ["wx_manual_luohan", "wx_manual_xingqi"], GrantWraps = true },
	["background.butcher"] = { Tier = 1, Name = "市肆屠户",   Desc = "终日操持厚背斩骨刀庖解牛羊，下刀稳准狠辣，见血不惊。", CommonPool = ["wx_manual_wuhudao", "wx_manual_xingqi"] },
	["background.caravan_hand"] = { Tier = 1, Name = "走镖趟子手", Desc = "常年随镖车走南闯北喊镖护货，习得一手实用的护身枪刀与吐纳桩功。", CommonPool = ["wx_manual_liuheqiang", "wx_manual_wuhudao", "wx_manual_tuna"] },
	["background.companion"] = { Tier = 1, Name = "旧日同袍",   Desc = "曾与你在生死关头并肩闯荡的江湖故交，知根知底、默契十足。", CommonPool = ["wx_manual_tuna", "wx_manual_liuheqiang", "wx_manual_wuhudao"] },
	["background.cultist"] = { Tier = 1, Name = "秘教信徒",   Desc = "信奉幽冥邪神的狂热教众，心志偏执诡谲，无惧皮肉伤痛。", CommonPool = ["wx_manual_xingqi", "wx_manual_tuna"] },
	["background.deserter"] = { Tier = 1, Name = "离营逃卒",   Desc = "从地方卫所或藩镇兵营私逃出来的兵油子，懂战阵刀枪却胆气略怯。", CommonPool = ["wx_manual_liuheqiang", "wx_manual_wuhudao", "wx_manual_jichujian"] },
	["background.disowned_noble"] = { Tier = 1, Name = "逐门子弟",   Desc = "因触犯家规被世家大族除名逐出的落魄少爷，尚留几分家传剑法底子。", CommonPool = ["wx_manual_jichujian", "wx_manual_tuna"] },
	["background.executioner"] = { Tier = 1, Name = "衙门行刑手", Desc = "曾在州府刑场掌鬼头大刀，双臂沉猛，最擅一刀断首。", CommonPool = ["wx_manual_wuhudao", "wx_manual_xingqi"] },
	["background.flagellant"] = { Tier = 1, Name = "苦行头陀",   Desc = "以荆条自笞锤炼皮肉定力的苦修武人，外门抗打功夫颇有火候。", CommonPool = ["wx_manual_xingqi", "wx_manual_luohan"], GrantWraps = true },
	["background.gambler"] = { Tier = 1, Name = "赌坊老千",   Desc = "混迹骰宝牌九场的机灵鬼，手指翻飞极快，颇擅藏镖甩袖。", CommonPool = ["wx_manual_tuna", "wx_manual_jichujian"] },
	["background.graverobber"] = { Tier = 1, Name = "摸金盗墓客", Desc = "专下前朝荒冢探穴取宝，身手矫捷且熟悉古墓尸傀习性。", CommonPool = ["wx_manual_tuna", "wx_manual_wuhudao"] },
	["background.houndmaster"] = { Tier = 1, Name = "山庄驯犬师", Desc = "善豢养猛犬追索山林匪迹，懂得驱犬合围策应之术。", CommonPool = ["wx_manual_liuheqiang", "wx_manual_tuna"] },
	["background.hunter"] = { Tier = 1, Name = "山林老猎户", Desc = "背硬弓钻深山追索虎豹的成名猎手，眼力毒辣，呼吸绵长。", CommonPool = ["wx_manual_tuna", "wx_manual_xingqi"] },
	["background.killer_on_the_run"] = { Tier = 1, Name = "负案亡命客", Desc = "背着人命海捕文书隐姓埋名的凶徒，出手狠毒不留余地。", CommonPool = ["wx_manual_wuhudao", "wx_manual_jichujian", "wx_manual_xingqi"] },
	["background.lumberjack"] = { Tier = 1, Name = "深山樵夫",   Desc = "终日挥重斧砍伐合抱巨木，腰背神力惊人，习惯势大力沉的劈砍。", CommonPool = ["wx_manual_xingqi", "wx_manual_wuhudao"] },
	["background.manhunter"] = { Tier = 1, Name = "捉刀捕快",   Desc = "拿官府花红千里缉拿逃犯的外班捕手，精通锁拿困敌之技。", CommonPool = ["wx_manual_wuhudao", "wx_manual_liuheqiang", "wx_manual_xingqi"] },
	["background.militia"] = { Tier = 1, Name = "团练乡勇",   Desc = "村寨宗族凑钱操练的护庄团丁，经历过剿匪守寨的真刀真枪。", CommonPool = ["wx_manual_liuheqiang", "wx_manual_wuhudao", "wx_manual_tuna"] },
	["background.monk"] = { Tier = 1, Name = "游方行脚僧", Desc = "云游四方的禅门僧侣，心志澄明平和，习有基础禅宗吐纳与罗汉散手。", CommonPool = ["wx_manual_tuna", "wx_manual_luohan"], GrantWraps = true },
	["background.poacher"] = { Tier = 1, Name = "山野私猎人", Desc = "潜入官山禁苑偷猎谋生的轻身弓手，擅长借林木掩护放冷箭。", CommonPool = ["wx_manual_tuna", "wx_manual_xingqi"] },
	["background.raider"] = { Tier = 1, Name = "金盆绿林客", Desc = "曾啸聚山林吃黑道饭的悍匪，如今洗心革面或换地讨生活，刀口舔血经验老辣。", CommonPool = ["wx_manual_wuhudao", "wx_manual_liuheqiang", "wx_manual_xingqi"] },
	["background.retired_soldier"] = { Tier = 1, Name = "退伍边军老卒", Desc = "在边关死人堆里滚过来的老兵，气血虽衰，战阵枪刀与定力犹存。", CommonPool = ["wx_manual_liuheqiang", "wx_manual_jichujian", "wx_manual_tuna"] },
	["background.squire"] = { Tier = 1, Name = "名门随侍弟子", Desc = "追随成名侠客背剑牵马的入室小徒，已得正统内外功入门真传。", CommonPool = ["wx_manual_jichujian", "wx_manual_tuna", "wx_manual_liuheqiang"] },
	["background.thief"] = { Tier = 1, Name = "梁上飞贼",   Desc = "夜行高墙瓦脊的轻身窃客，身法灵巧，极善闪避脱身。", CommonPool = ["wx_manual_jichujian", "wx_manual_tuna"] },
	["background.wildman"] = { Tier = 1, Name = "深山野人",   Desc = "茹毛饮血长于荒莽绝谷的异人，气血内息浑如凶兽，不通文墨却天生神力。", CommonPool = ["wx_manual_xingqi", "wx_manual_luohan"], GrantWraps = true },
	["background.witchhunter"] = { Tier = 1, Name = "靖邪缉异人", Desc = "专司查办邪派妖道、苗疆蛊毒与湘西尸傀的冷面行家，心志坚如磐石。", CommonPool = ["wx_manual_tuna", "wx_manual_jichujian"] },

	// =========================================================================
	// Tier 2: 成名高手 / 门派真传（入队自动预装 1 本门派上乘 + 1 本大路货，双槽即战力）
	// =========================================================================
	["background.adventurous_noble"] = { Tier = 2, Name = "游历世家公子", Desc = "钟鸣鼎食之家仗剑出游的嫡系子弟，自幼有名师指点上乘心法与枪剑。", SectPool = ["wx_manual_songtao", "wx_manual_qingfeng", "wx_manual_weiyuan"], CommonPool = ["wx_manual_tuna", "wx_manual_jichujian", "wx_manual_liuheqiang"] },
	["background.assassin"] = { Tier = 2, Name = "隐杀楼刺客",   Desc = "拿人钱财替人消灾的顶尖暗杀高手，身负阴柔内息与快剑绝技。", SectPool = ["wx_manual_guiyuan", "wx_manual_qingfeng"], CommonPool = ["wx_manual_tuna", "wx_manual_jichujian"] },
	["background.assassin_southern"] = { Tier = 2, Name = "西域影刺客",   Desc = "来自大漠灰袍杀手组织的绝顶快刀刺客，出手如鬼魅电光。", SectPool = ["wx_manual_guiyuan", "wx_manual_qingfeng", "wx_manual_heifeng"], CommonPool = ["wx_manual_tuna", "wx_manual_jichujian", "wx_manual_wuhudao"] },
	["background.barbarian"] = { Tier = 2, Name = "塞北狂战悍勇", Desc = "关外苦寒战帮走出的百战勇士，筋骨如铁，刀法狂野霸道。", SectPool = ["wx_manual_heifeng", "wx_manual_songtao"], CommonPool = ["wx_manual_xingqi", "wx_manual_wuhudao"] },
	["background.beast_hunter"] = { Tier = 2, Name = "山泽猎妖客",   Desc = "常年深入绝岭毒泽猎杀白猿毒蛟取胆炼药的成名猎手，武艺精湛。", SectPool = ["wx_manual_weiyuan", "wx_manual_yanxing", "wx_manual_songtao"], CommonPool = ["wx_manual_xingqi", "wx_manual_liuheqiang"] },
	["background.beast_slayer"] = { Tier = 2, Name = "山泽猎妖客",   Desc = "常年深入绝岭毒泽猎杀白猿毒蛟取胆炼药的成名猎手，武艺精湛。", SectPool = ["wx_manual_weiyuan", "wx_manual_yanxing", "wx_manual_songtao"], CommonPool = ["wx_manual_xingqi", "wx_manual_liuheqiang"] },
	["background.converted_crusader"] = { Tier = 2, Name = "还俗护法武僧", Desc = "曾任名刹戒律院护法，历尽红尘劫波后带艺投身江湖。", SectPool = ["wx_manual_jingang", "wx_manual_songtao"], CommonPool = ["wx_manual_xingqi", "wx_manual_luohan"], GrantWraps = true },
	["background.crucified"] = { Tier = 2, Name = "还俗护法武僧", Desc = "曾任名刹戒律院护法，历尽红尘劫波后带艺投身江湖。", SectPool = ["wx_manual_jingang", "wx_manual_songtao"], CommonPool = ["wx_manual_xingqi", "wx_manual_luohan"], GrantWraps = true },
	["background.crusader"] = { Tier = 2, Name = "少室护法武僧", Desc = "古刹禅院下山降魔卫道的精锐武僧，内外兼修，掌风刚猛正大。", SectPool = ["wx_manual_jingang", "wx_manual_songtao"], CommonPool = ["wx_manual_xingqi", "wx_manual_luohan"], GrantWraps = true },
	["background.gladiator"] = { Tier = 2, Name = "百胜打擂宗师", Desc = "在南北地下生死擂台连胜数十场的顶尖好手，招招皆为实战搏命所铸。", SectPool = ["wx_manual_heifeng", "wx_manual_jingang", "wx_manual_qingfeng"], CommonPool = ["wx_manual_xingqi", "wx_manual_wuhudao", "wx_manual_luohan"] },
	["background.hedge_knight"] = { Tier = 2, Name = "独行披甲悍将", Desc = "身披重甲纵横绿林与边关的沙场万人敌，兼具霸道外功与深厚内息。", SectPool = ["wx_manual_heifeng", "wx_manual_weiyuan", "wx_manual_songtao"], CommonPool = ["wx_manual_xingqi", "wx_manual_wuhudao", "wx_manual_liuheqiang"] },
	["background.kings_guard"] = { Tier = 2, Name = "前朝大内侍卫", Desc = "昔日皇城禁苑贴身护驾的一等高手，正统心法与刀剑造诣皆属一流。", SectPool = ["wx_manual_qingfeng", "wx_manual_songtao", "wx_manual_weiyuan"], CommonPool = ["wx_manual_tuna", "wx_manual_jichujian"] },
	["background.lindwurm_slayer"] = { Tier = 2, Name = "斩蛟豪侠",     Desc = "曾亲手屠戮岭南巨型毒蛟而声名大噪的奇侠，胆魄武功冠绝一时。", SectPool = ["wx_manual_weiyuan", "wx_manual_songtao"], CommonPool = ["wx_manual_xingqi", "wx_manual_liuheqiang"] },
	["background.nomad"] = { Tier = 2, Name = "大漠弯刀客",   Desc = "纵横瀚海沙暴间的西域成名刀客，步履诡奇，弯刀狠辣。", SectPool = ["wx_manual_heifeng", "wx_manual_guiyuan"], CommonPool = ["wx_manual_xingqi", "wx_manual_wuhudao"] },
	["background.oathtaker"] = { Tier = 2, Name = "守誓侠客",     Desc = "恪守先师重誓扶危济困的名门传人，正气凛然，剑胆琴心。", SectPool = ["wx_manual_songtao", "wx_manual_qingfeng"], CommonPool = ["wx_manual_tuna", "wx_manual_jichujian"] },
	["background.orc_slayer"] = { Tier = 2, Name = "破寨悍侠",     Desc = "专门清剿邪派药人巨汉与重装匪寨的百战豪杰，最擅硬碰硬破甲。", SectPool = ["wx_manual_heifeng", "wx_manual_songtao"], CommonPool = ["wx_manual_xingqi", "wx_manual_wuhudao"] },
	["background.paladin"] = { Tier = 2, Name = "守誓侠客",     Desc = "恪守先师重誓扶危济困的名门传人，正气凛然，剑胆琴心。", SectPool = ["wx_manual_songtao", "wx_manual_qingfeng"], CommonPool = ["wx_manual_tuna", "wx_manual_jichujian"] },
	["background.sellsword"] = { Tier = 2, Name = "受雇名刀客",   Desc = "在江湖上明码标价接红货死契的成名老手，刀枪剑戟皆有上乘传承。", SectPool = ["wx_manual_heifeng", "wx_manual_weiyuan", "wx_manual_qingfeng"], CommonPool = ["wx_manual_xingqi", "wx_manual_tuna", "wx_manual_wuhudao"] },
	["background.swordmaster"] = { Tier = 2, Name = "退隐剑宗名宿", Desc = "昔年名动江湖的一流剑客，虽年岁渐长气血微衰，一柄快剑已臻化境。", SectPool = ["wx_manual_qingfeng", "wx_manual_guiyuan"], CommonPool = ["wx_manual_tuna", "wx_manual_jichujian"] }
};
