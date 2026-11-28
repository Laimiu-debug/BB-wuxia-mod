// Non-Destructive Wuxia Contracts, Company Ambitions (江湖志向), Perkless Mastery/Rally Adaptation & Crisis/System Event Narrative Overhaul
// Ensures all 50 Town/Noble/Southern Contracts, all 48 Company Ambitions, and all Crisis/Special System Events
// present authentic Ming/Tang low-fantasy Wuxia Jianghu stories while preserving 100% of vanilla quest logic & save compatibility.

::Wuxia.Contracts <- {
	// 50 Contract Types -> [ChineseTitle, EventArtImg, TaskBriefingBody, SuccessTurnInBody]
	// Placeholders like %employer%, %townname%, %reward% are safely resolved via `buildText` or live contract context!
	SpecMap = {
		["contract.drive_away_bandits"]         = ["清剿绿林响马山寨", "gfx/ui/events/wx_ev_05.png",
			"州县衙署外张贴着墨迹未干的捕盗红榜。主事 %employer% 将你迎入签押房，拍案叹道：\n\n『近日有一股凶悍的绿林响马在 %townname% 近郊占山立寨，频频拦路剪径、劫掠往来粮车，搅得城外村户鸡犬不宁。本城守备兵微将寡，特请贵社仗剑出城，将那座匪寨连根拔除！』",
			"你们携染血的匪首腰牌与折断的压寨黑旗踏回 %townname%。%employer% 验明正身，抚掌大喜，当场命账房捧出纹银托盘：\n\n『好利落的江湖身手！匪患既除，四乡商路总算能喘口气了——这是事先议定的酬银，请诸位壮士笑纳！』"],
		["contract.drive_away_nomads"]          = ["扫荡塞外沙路马贼", "gfx/ui/events/wx_ev_14.png",
			"丝路驿馆内风沙扑面，%employer% 指着羊皮舆图上的一处红圈沉声道：\n\n『一伙弯刀狠辣的塞外沙路马贼近日在 %townname% 水源商道旁扎下黑帐，接连洗劫驼队。若不尽早拔去这颗钉子，往来胡汉商贾谁还敢踏足此城？还望贵社出手荡平贼帐！』",
			"大漠烟尘未散，你们已提着马贼头领的镔铁弯刀凯旋而归。%employer% 亲自奉上美酒与足色纹银：\n\n『沙海响马一除，丝路驼铃又可畅行无阻！诸位侠名必将传遍西域诸城！』"],
		["contract.drive_away_barbarians"]      = ["痛击关外犯边战帮", "gfx/ui/events/wx_ev_15.png",
			"朔风凛冽，%employer% 披着厚重貂裘立于堂前，神色凝重：\n\n『关外黑水战帮的狂暴莽汉近日越过山口，在 %townname% 外围立起骨幡营盘，肆意屠戮猎户樵夫。那帮恶汉力大无穷、悍不畏死，唯有仰仗贵社这等武林精锐前去踏平敌营！』",
			"你们踏着冰雪重返 %townname%，甲叶上犹带关外狂寇的血霜。%employer% 肃然拱手，命人奉上重赏纹银：\n\n『壮哉！关外凶徒经此重创，数月内绝不敢再窥边塞半步！』"],
		["contract.return_item"]                = ["千里追缉失窃秘宝", "gfx/ui/events/wx_ev_08.png",
			"%employer% 屏退左右随从，压低声音向你道出隐情：\n\n『惭愧，昨夜一伙轻功狡诈的黑道毛贼潜入 %townname%，盗走了一件干系重大的传家信物，正往荒野深处逃窜。官差脚力不及江湖草莽，恳请贵社循迹急追，诛杀群贼并将原物完璧归赵！』",
			"你将夺回的锦匣稳稳置于桌案之上。%employer% 掀盖细验，长舒一口浊气，连声称谢并双手奉上酬银：\n\n『分毫无损！贵社不仅武艺高强，更兼守信重诺，当真无愧侠义二字！』"],
		["contract.escort_caravan"]             = ["威远走镖护送商队", "gfx/ui/events/wx_ev_06.png",
			"车马行院内骡马嘶鸣，满载绸缎盐铁的大车已捆扎停当。账房总管 %employer% 拱手迎上前：\n\n『乱世道途不靖，绿林响马与山泽异兽随时可能扑出劫道。这趟由 %townname% 发出的重货镖车干系全城生计，特聘贵社随车亮镖护行，平安送抵目的地即刻结清镖银！』",
			"一路风餐露宿、兵刃护航，沉重的镖车终于稳稳驶入城门。镖局管事清点货箱分毫不差，笑着将沉甸甸的镖银交入你手中：\n\n『有贵社一路压阵，沿途宵小果然望风披靡！日后走镖定当再请诸位捧场！』"],
		["contract.patrol"]                     = ["巡防州县千里官道", "gfx/ui/events/wx_ev_16.png",
			"藩镇军前文书案头堆满急报，%employer% 将一枚铜铸巡防令箭递到你面前：\n\n『近来各路流寇、邪派药人与荒山凶兽四处流窜，官军主力分身乏术。现委派贵社按令箭所示路线依次巡视各州镇要冲；凡沿途遭遇拦路贼寇，每斩首一级皆另计军功赏银！』",
			"你们踏遍既定各处州镇关隘，沿途剪除匪患无数，顺利缴还巡防令箭。%employer% 核验斩获军功，欣然命军需官按约拨付全额饷银：\n\n『有贵社替本府弹压地方，这几条官道清朗多矣！』"],
		["contract.hunting_webknechts"]         = ["入林除害清剿毒蛛", "gfx/ui/events/wx_ev_19.png",
			"%employer% 面带惊悸地指向城外幽暗密林：\n\n『近月以来，入林伐木采药的乡民接连失踪，昨日逃回的猎户只见林间挂满惨白巨网，碗口大的五毒巨蛛成群结队！再不铲除蛛巢，只怕毒物便要摸进 %townname% 伤人了！』",
			"你们砍断盘根错节的毒网、捣毁虫卵，携巨蛛毒腺返回 %townname%。街坊百姓夹道称庆，%employer% 感激涕零地奉上赏银：\n\n『林间大患终除，采药樵夫总算敢进山讨生活了！』"],
		["contract.hunting_unholds"]            = ["踏雪搜山诛杀巨猿", "gfx/ui/events/wx_ev_20.png",
			"%employer% 领你看过城门外被连根拔起的碗口粗木桩，倒吸一口凉气：\n\n『荒山深处窜出数头身高丈余、力能扛鼎的凶暴白猿巨怪，寻常刀箭射在它厚皮上犹如挠痒，气血愈战愈合！唯有请贵社这等身怀绝技的武林豪杰进山除凶！』",
			"当你们抬着巨猿骇人的头颅踏入 %townname% 时，满街百姓无不哗然喝彩。%employer% 惊叹不已，立即奉上厚赏：\n\n『连这等山海凶物皆能斩于马下，诸位真乃天神下凡！』"],
		["contract.hunting_lindwurms"]          = ["斩蛟除恶平靖大泽", "gfx/ui/events/wx_ev_21.png",
			"%employer% 脸色煞白，声音发颤：\n\n『大祸临头！城外水泽荒原近日现出岭南毒蛟踪迹——此獠披青鳞重甲、尾扫千钧，连伤它之血亦带蚀铁化骨奇毒！本城无人敢撄其锋，重金礼聘贵社前往屠蛟靖难！』",
			"腥风血雨过后，毒蛟巨首终于坠地。%employer% 望着你们带回的蛟鳞奇骨，双手奉上重金酬银：\n\n『屠蛟大功，足以载入本州县志！请受全城父老一拜！』"],
		["contract.hunting_schrats"]            = ["深林伐祟斩灭木魅", "gfx/ui/events/wx_ev_22.png",
			"%employer% 叹息着递过一柄被古藤拧断的铁斧：\n\n『城外古林中成了气候的千年树妖木魅近日苏醒作祟，藤根钻地破盾，刀剑难砍，伐木匠户死伤惨重。听闻唯有利斧重刃方能劈碎其木心，还望贵社入林斩妖！』",
			"古林重归寂静，你们携温润奇异的古木灵心归城复命。%employer% 大喜过望，痛快付清赏银：\n\n『木魅伏诛，山林重开，贵社功莫大焉！』"],
		["contract.hunting_hexen"]              = ["破除迷魂妖姬邪术", "gfx/ui/events/wx_ev_23.png",
			"%employer% 眼圈深陷，满面惶恐与悲愤：\n\n『城中接连有孩童与青壮夜半神魂颠倒、自行走入深山荒林不知所踪！老道士断定是修炼摄魂媚术的邪派妖姬在暗中驱兽害人。恳请贵社挑选定力深厚之士进山诛杀妖妇！』",
			"邪雾消散，妖姬伏诛。%employer% 听闻喜讯热泪盈眶，连连作揖并奉上重金：\n\n『若非诸位侠士定力如山、斩断妖邪，本城不知还要多少人家骨肉分离！』"],
		["contract.hunting_alps"]               = ["夜巡捉鬼诛灭魇魅", "gfx/ui/events/wx_ev_24.png",
			"%employer% 捧着浓茶的手仍在微颤：\n\n『怪事连连……近来 %townname% 每逢子夜便有人在睡梦中窒息暴毙，面露极度惊骇之色。江湖异人言此乃食人梦境的阴煞魇魅作祟，须于黑夜迎战斩除，特请贵社坐镇破邪！』",
			"子夜阴霾尽扫，噬梦邪祟灰飞烟灭。全城百姓终于得享安眠，%employer% 恭敬奉上厚礼纹银：\n\n『一夜之间涤荡阴霾，诸位高义本城永世不忘！』"],
		["contract.hunting_serpents"]           = ["沙海搜穴斩杀巨蟒", "gfx/ui/events/wx_ev_19.png",
			"%employer% 指着商道旁残留的巨大鳞痕蹙眉道：\n\n『大漠石窟中盘踞着一群水桶粗细的噬人沙蟒，专伺落单行旅缠卷吞噬。还请贵社携利刃前往清剿蛇窟，为往来客商除去心腹大患！』",
			"群莽伏诛，腥血染红黄沙。%employer% 验看蛇胆鳞皮后欣然结清酬银：\n\n『痛快！沙道总算不必再提心吊胆了！』"],
		["contract.hunting_sand_golems"]        = ["大漠靖沙碎灭石灵", "gfx/ui/events/wx_ev_20.png",
			"%employer% 凝望漫天黄沙沉声道：\n\n『瀚海古迹周围聚起由狂沙顽石凝成的荒漠石傀，聚散无常、重击碎骨，商队屡遭覆灭。唯有仰仗贵社重锤硬功前往击碎其沙核！』",
			"黄沙平息，顽石崩解。%employer% 钦佩万分地奉上赏银：\n\n『连大漠天地异种亦挡不住诸位神威！』"],
		["contract.roaming_beasts"]             = ["搜山清剿食人凶兽", "gfx/ui/events/wx_ev_18.png",
			"%employer% 忧心忡忡地向你抱拳：\n\n『近日 %townname% 田庄牧场屡遭成群荒野凶兽夜袭，牛羊被撕碎、庄客亦死伤数人。恳请贵社出城搜山，将那群孽畜尽数诛除！』",
			"你们提着凶兽皮毛尖牙归城复命，%employer% 喜笑颜开地双手奉上赏银：\n\n『恶兽既除，庄户们总算能安心下田耕作了！』"],
		["contract.roaming_beasts_desert"]      = ["绿洲除凶肃清荒兽", "gfx/ui/events/wx_ev_18.png",
			"%employer% 抚须叹道：\n\n『绿洲水草外围近日聚起成群饥饿凶兽，频频袭扰挑水农人与放牧羊群。特请贵社出城猎杀群兽，还城郊一片安宁！』",
			"荒漠群兽尽数授首，%employer% 欣然奉上足额纹银以酬辛劳。"],
		["contract.investigate_cemetery"]       = ["夜探荒冢荡平尸傀", "gfx/ui/events/wx_ev_11.png",
			"%employer% 压低嗓门，神色凛然：\n\n『城外前朝义庄与古冢近日鬼火森森，守墓老卒亲眼撞见腐尸披甲爬出坟茔，显是有湘西邪道或地脉阴煞作乱！趁尸群尚未成势攻城，恳请贵社即刻前往古冢斩妖除祟！』",
			"古冢阴煞荡涤一空，腐尸邪道尽化焦土。%employer% 如释重负，立即命人奉上重金纹银：\n\n『幸得贵社雷霆出手，否则酿成尸傀屠城大祸便悔之晚矣！』"],
		["contract.root_out_undead"]            = ["踏平前朝玄宫尸巢", "gfx/ui/events/wx_ev_12.png",
			"%employer% 展开一卷泛黄的州府堪舆图，肃容道：\n\n『探马急报，深山一处前朝废墟古墓阴气冲天，青铜守陵机关兵俑与控魂尸傀正向四方蔓延！本府特发靖邪军帖，重金聘请贵社深入魔窟，彻底捣毁阴煞源头！』",
			"地宫崩塌，千年冥俑与控魂妖邪尽数授首。%employer% 亲自出堂相迎，双手奉上丰厚赏银：\n\n『荡平玄宫魔巢，救活一方生灵，贵社威名必震动天下！』"],
		["contract.destroy_goblin_camp"]        = ["深入瘴林捣毁五毒寨", "gfx/ui/events/wx_ev_09.png",
			"%employer% 取出一支淬着幽绿毒液的细竹吹箭置于案上：\n\n『南疆五毒奇门伏兵已在近处密林扎下竹寨，暗箭伤人、布设毒网，官兵入林屡吃暗亏。贵社轻功暗器与武学俱佳，特请诸位奇袭毒寨，拔旗斩首！』",
			"毒瘴竹寨化为灰烬，五毒妖人死伤殆尽。%employer% 验明斩获，欣然拨付重赏纹银！"],
		["contract.destroy_orc_camp"]           = ["浴血焚平邪派药人窟", "gfx/ui/events/wx_ev_10.png",
			"%employer% 眉宇间杀气凛然：\n\n『斥候探明，一处邪宗炼体药人聚居魔窟就在本境荒野，那群铜皮铁骨的失心狂汉正磨砺重斧准备血洗州县！请贵社趁其未发，一举踏平魔窟！』",
			"药人魔窟烈焰冲天，邪派凶徒尽伏刀下。%employer% 击节赞叹，如数奉上厚赏纹银！"],
		["contract.discover_location"]          = ["踏勘迷雾寻访古迹", "gfx/ui/events/wx_ev_04.png",
			"%employer% 取出一卷残缺古籍与罗盘交予你手：\n\n『古志记载 %direction% 荒野迷雾之中藏有一处前朝遗落秘境，只是山高林密无人探明方位。特请贵社轻骑深入荒野查勘确切坐落，绘入舆图即可回城领赏！』",
			"你将绘有秘境坐落的详尽堪舆图交还 %employer%。对方细细展卷核验，满面喜色地奉上纹银：\n\n『方位分毫不差！有劳诸位跋山涉水了！』"],
		["contract.obtain_item"]                = ["孤身入险夺取古墓秘宝", "gfx/ui/events/wx_ev_07.png",
			"%employer% 屏退堂下闲杂人等，郑重嘱托：\n\n『本府急需一件埋藏于荒野险地古迹中的前朝秘宝信物。那处险地必有凶徒或机关尸傀盘踞，还望贵社披荆斩棘夺宝归来，切莫擅自损毁遗失！』",
			"古匣重见天日，%employer% 摩挲着失而复得的秘宝，连声称善并奉上丰厚赏金！"],
		["contract.find_artifact"]              = ["西域探秘寻回前朝圣物", "gfx/ui/events/wx_ev_07.png",
			"%employer% 抚胸行礼，神情庄重：\n\n『瀚海黄沙掩埋的前朝地宫中，遗落着一尊干系都护府正统的传世古器。特聘贵社深入大漠遗迹诛灭守陵冥卫，取回古器重宝！』",
			"传世重器安然归还，%employer% 盛赞贵社神勇守信，奉上大笔足色纹银！"],
		["contract.deliver_item"]               = ["星夜兼程押送机密匣", "gfx/ui/events/wx_ev_06.png",
			"%employer% 将一只火漆封口、加锁精铜的紫檀密匣郑重交入你怀中：\n\n『此匣干系重大，万不可落入外人之手，更不可私自拆封。烦请贵社星夜启程，将密匣亲手送交目的地主事大人，切勿延误！』",
			"紫檀密匣火漆完好无损地呈交到位，收件大人核验印信无误，当即命人奉上押送酬银！"],
		["contract.escort_envoy"]               = ["贴身护卫钦差使节", "gfx/ui/events/wx_ev_17.png",
			"%employer% 指着厢房内整装待发的紫衣使者肃然道：\n\n『这位大人身负要务需赶赴邻境会盟，途中恐有敌对势力的江湖死士与马贼设伏截杀。特请贵社全程贴身护卫，务保使节大人毫发无损抵达！』",
			"一路化解数波凶险窥探，使节大人安然踏入驿馆大门，含笑命随从奉上厚赏纹银！"],
		["contract.defend_settlement_bandits"]  = ["协防乡梓迎击绿林巨寇", "gfx/ui/events/wx_ev_05.png",
			"城头梆声急促，%employer% 手按腰刀快步迎上：\n\n『探马来报，大股绿林悍匪正打着火把扑向 %townname%，妄图洗劫周边庄园作坊！请贵社留驻城郊严阵以待，与本城互为犄角击溃来犯群寇！』",
			"来犯悍匪尸横遍野、狼狈溃逃，%townname% 坊市安然无恙！%employer% 携全城父老奉上犒军重赏！"],
		["contract.defend_settlement_greenskins"]= ["死守孤城抗击药人五毒", "gfx/ui/events/wx_ev_10.png",
			"烽烟四起，%employer% 甲胄染尘，急切抱拳：\n\n『南疆五毒奇兵与狂暴炼体药人正朝 %townname% 蜂拥杀来！存亡危急之秋，恳请贵社助本城死守外围防线，寸土必争！』",
			"浴血奋战之下，五毒与药人攻势终告瓦解！%employer% 紧握你手，奉上丰厚犒赏纹银！"],
		["contract.arena"]                      = ["红绸生死擂三雄争锋", "gfx/ui/events/wx_ev_25.png",
			"演武擂台四周战鼓雷鸣、旌旗蔽日！擂台总管高声喝道：\n\n『生死状一签，只许三名好手携随身兵甲登台搏杀！无论是西域刀客、囚笼狂徒还是大荒凶兽，立到最后者便是今日擂主，彩头纹银与满城喝彩唾手可得！』",
			"满场欢呼震耳欲聋！你们浴血屹立于红绸演武台中央，擂台总管高举钱袋当众奉上今日彩头纹银！"],
		["contract.arena_tournament"]           = ["天下英雄生死大擂会", "gfx/ui/events/wx_ev_25.png",
			"今日演武场彩旗十里、座无虚席！擂台总管朗声笑道：\n\n『今日乃数月一遇的三轮连战英雄大擂！唯有连闯三关而不倒的绝顶好手，方能夺得压轴传世重宝与千金彩头——诸位可敢登台一战？』",
			"连闯三关、血染红绸，全场万众起立高呼贵社字号！擂台总管双手奉上压轴彩头与重宝！"],
		["contract.barbarian_king"]             = ["塞外讨逆诛灭黑水汗王", "gfx/ui/events/wx_ev_15.png",
			"%employer% 面色严峻地递过北境军报：\n\n『塞外黑水诸部近日推举出一名武勇绝伦的狂暴大头领，正纠集各部悍匪图谋南侵。若能趁其羽翼未丰一举斩其首级，必能瓦解塞外群寇！特请贵社北上擒贼擒王！』",
			"塞外悍首伏诛，诸部树倒猢狲散！%employer% 抚掌大赞贵社盖世奇功，奉上千金厚赏！"],
		["contract.big_game_hunt"]              = ["奉命围猎荒原珍禽凶兽", "gfx/ui/events/wx_ev_18.png",
			"%employer% 设下酒席相待，笑道：\n\n『大府近日急需大批山泽异兽首级与奇肉以充军宴药库。贵社出城狩猎荒原群兽，猎获愈多、赏格愈厚！』",
			"满载异兽猎获归城，%employer% 逐一清点过秤，痛快结清丰厚猎赏！"],
		["contract.marauding_greenskins"]       = ["截击四出劫掠之五毒药人", "gfx/ui/events/wx_ev_09.png",
			"藩镇帅帐内军情紧急，%employer% 沉声下令：\n\n『多股五毒游骑与狂暴药人已渗入本镇腹地烧杀抢掠。现命贵社火速出击，追剿境内游弋的邪派劫掠队！』",
			"游弋境内的五毒与药人先锋尽被肃清，%employer% 嘉奖贵社神速战功，当堂发下军饷重赏！"],
		["contract.break_greenskin_siege"]      = ["千里驰援解救被围孤城", "gfx/ui/events/wx_ev_10.png",
			"%employer% 拍案而起，神情激愤：\n\n『急报！五毒与炼体药人大军正重重围困我方重镇，城中粮尽矢绝、危在旦夕！命贵社即刻星夜驰援，内外夹击杀散围城恶寇！』",
			"铁骑突围、血战解困，危城终得保全！%employer% 对贵社救城大恩感佩莫名，奉上重金厚赏！"],
		["contract.free_greenskin_prisoners"]   = ["劫营救回被掳黎庶百姓", "gfx/ui/events/wx_ev_09.png",
			"%employer% 满面悲戚地拱手道：\n\n『邪派药人与五毒匪众掳走了本境大批乡民百姓押往荒野营寨，若迟上几日只怕尽遭炼药毒手！恳请贵社仗义追击，破营救回父老妇孺！』",
			"枷锁劈断，被掳乡民平安归家与亲人相拥而泣。%employer% 代表合城百姓奉上重金酬谢！"],
		["contract.decisive_battle"]            = ["藩镇会战正面决死破阵", "gfx/ui/events/wx_ev_16.png",
			"帅帐内甲光如雪，藩镇监军 %employer% 按剑喝道：\n\n『两镇主力大军已于旷野摆开决死战阵！战鼓一响，正需贵社这等悍勇武林奇兵投入沙场中坚，协同本镇玄甲大军一举击溃敌军帅旗！』",
			"旌旗斩落、敌阵崩摧，旷野尸骸枕藉！%employer% 于凯旋大帐中亲自为贵社记下头功并犒赏重金！"],
		["contract.siege_fortification"]        = ["拔城夺寨协攻敌镇营垒", "gfx/ui/events/wx_ev_16.png",
			"%employer% 指着沙盘上的敌方关城冷声道：\n\n『敌镇倚仗坚城营垒负隅顽抗，本府大军已将其团团合围！现调贵社担任攻城尖刀，随军猛攻拔下敌方关隘！』",
			"敌方关隘火起城破，大纛易主！%employer% 论功行赏，拨付丰厚破城军资！"],
		["contract.raid_caravan"]               = ["奉令截断敌镇粮道辎重", "gfx/ui/events/wx_ev_06.png",
			"%employer% 压低声音冷笑道：\n\n『兵马未动，粮草先行。敌对藩镇正有一批军资粮车经官道暗运前线——贵社只管出马将其押运护兵尽数歼灭、焚夺军资，断敌命脉！』",
			"敌军粮道断绝、辎重尽归囊中！%employer% 大赞贵社用兵老辣，爽快奉上重金酬劳！"],
		["contract.raze_attached_location"]     = ["奇袭敌境焚毁军资工坊", "gfx/ui/events/wx_ev_14.png",
			"%employer% 在沙盘上连点三处敌境庄园矿冶：\n\n『欲挫敌军锐气，先毁其钱粮根基！现委贵社轻骑深入敌方腹地，将其城外矿冶粮庄焚毁殆尽，令敌军无米下锅、无铁铸甲！』",
			"敌境狼烟滚滚、军资庄坊尽成焦土。%employer% 抚掌大笑，如约奉上厚赏纹银！"],
		["contract.intercept_raiding_parties"]  = ["迎头痛击敌镇劫掠游骑", "gfx/ui/events/wx_ev_16.png",
			"%employer% 怒拍帅案：\n\n『敌镇卑鄙无耻，竟派轻骑绕过关防潜入我境焚掠村屯！命贵社即刻披甲追击，将这伙犯境游骑尽数歼灭于国门之内！』",
			"犯境敌骑全军覆没，乡梓转危为安！%employer% 欣然命军需官奉上重金犒赏！"],
		["contract.hold_chokepoint"]            = ["一夫当关死守咽喉险隘", "gfx/ui/events/wx_ev_15.png",
			"%employer% 神色凛然地指向险要山口：\n\n『敌军数路先锋正欲抢渡咽喉要道，我方大军尚需时日集结布防。特命贵社扼守险隘，接连挫败来犯敌锋，绝不可放一兵一卒越雷池半步！』",
			"血染关口、寸步未退，数波强敌尽折于贵社兵锋之下！%employer% 敬佩万分地奉上重赏！"],
		["contract.last_stand"]                 = ["孤城血战力挽狂澜", "gfx/ui/events/wx_ev_12.png",
			"%employer% 双目赤红，拔剑誓师：\n\n『强敌压境，四面楚歌！退后一步便是万劫不复，唯有与城池共存亡、死战到底！还望贵社与本镇将士并肩血战，杀出一条生路！』",
			"九死一生、力挽狂澜，强敌终于鸣金败退！劫后余生的 %employer% 奉上重金与崇高敬意！"],
		["contract.confront_warlord"]           = ["阵前斩将讨伐叛军渠帅", "gfx/ui/events/wx_ev_16.png",
			"%employer% 沉声道：\n\n『乱军渠帅拥兵自重、祸乱一方，如今其帅帐行踪已露！特请贵社率精锐直捣中军，斩下逆首以正视听！』",
			"逆帅授首、叛军瓦解！%employer% 盛赞贵社万军取首之威，奉上重金厚赏！"],
		["contract.privateering"]               = ["远走敌疆纵横破袭", "gfx/ui/events/wx_ev_14.png",
			"%employer% 递过一纸盖有帅印的便宜行事密令：\n\n『两军交兵，不拘一格！贵社可持此密令深入敌镇辖境，凡截杀敌军巡骑、劫夺商队或焚毁外围据点，皆按战果论功重赏！』",
			"你们在敌境搅得天翻地覆、满载而归，%employer% 核计赫赫战果，痛快拨付重金！"],
		["contract.restore_location"]           = ["收复故垒护卫百工重筑", "gfx/ui/events/wx_ev_17.png",
			"%employer% 叹息道：\n\n『前番兵灾过后，城外要塞废墟已被流寇邪祟盘踞。现请贵社护送工匠前往肃清残敌、重修壁垒，复我藩篱！』",
			"残敌肃清、新垒重立，%employer% 欣慰不已，如数奉上丰厚酬银！"],
		["contract.conquer_holy_site"]          = ["北伐古迹争夺龙脉圣地", "gfx/ui/events/wx_ev_16.png",
			"%employer% 剑指舆图上的上古遗迹：\n\n『那处前朝龙脉古迹乃南北气运所系，绝不容异邦都护染指！现命贵社充任先锋，攻占古迹并击退一切来犯敌军！』",
			"龙脉古迹旌旗高悬，强敌败退！%employer% 大喜过望，赐下重金犒赏！"],
		["contract.conquer_holy_site_southern"] = ["奉都护令夺取上古圣迹", "gfx/ui/events/wx_ev_14.png",
			"%employer% 抚胸肃立：\n\n『北方藩镇强占先贤古迹，都护府大军誓要将其夺回！特聘贵社随军攻坚，拔下敌军营垒夺回圣迹！』",
			"古迹重归都护府掌控，%employer% 盛赞贵社锋芒无匹，奉上重金！"],
		["contract.defend_holy_site"]           = ["镇守龙脉古迹迎击强敌", "gfx/ui/events/wx_ev_16.png",
			"%employer% 沉声下令：\n\n『敌方大军正昼夜疾驰反扑前朝古迹！命贵社即刻开赴遗迹驻防，死守阵地直至击溃全部反扑敌军！』",
			"古迹稳如泰山，反扑敌军折戟沉沙！%employer% 论功重赏贵社全体豪杰！"],
		["contract.defend_holy_site_southern"]  = ["固守西域圣迹抗击北军", "gfx/ui/events/wx_ev_14.png",
			"%employer% 郑重嘱托：\n\n『北方藩镇重甲铁军正扑向圣迹企图翻盘！特请贵社驻守圣迹要冲，迎头痛击来犯北军！』",
			"北军攻势尽碎于圣迹之下，%employer% 双手奉上优渥赏银！"],
		["contract.slave_uprising"]             = ["平息矿场苦役暴动", "gfx/ui/events/wx_ev_05.png",
			"%employer% 焦头烂额地迎上前：\n\n『城外苦役营矿场突发暴乱，大批亡命囚徒夺取兵刃占了场院！特请贵社火速前往弹压平乱，夺回矿场控制！』",
			"矿场暴乱平息，秩序重归安定，%employer% 如约奉上酬银！"],
		["contract.tutorial_contract"]          = ["初入江湖：肃清匪首余孽", "gfx/ui/events/wx_ev_05.png",
			"%employer% 审视着你们这支重整旗鼓的江湖义社，沉声道：\n\n『那伙重创你们的绿林匪首仍盘踞在近郊荒野苟延残喘。血债唯有血偿——提着他的首级回来见我，这笔赏银便是贵社东山再起的第一桶金！』",
			"大仇得报，匪首伏诛！%employer% 欣然奉上赏银，你们的江湖传奇自此正式拉开帷幕！"]
	},

	// Deep Wuxia Narrative & Option Rewriter for all dynamic / mid-quest contract & event texts
	NarrativePairs = [
		["你打算出多少克朗", "这趟差事打算出多少纹银"],
		["多少克朗",         "多少纹银"],
		["这不是我们要找的活儿", "眼下另有要事，恕难从命"],
		["贵族家族", "藩镇世家"],
		["贵族战争", "藩镇节度争霸"],
		["贵族",     "世家大人"],
		["领主",     "节度大人"],
		["男爵",     "镇抚大人"],
		["伯爵",     "经略大人"],
		["公爵",     "节度使大人"],
		["骑士",     "玄甲武卫"],
		["步兵",     "军镇步卒"],
		["雇佣兵团", "江湖义社"],
		["佣兵团",   "江湖义社"],
		["雇佣兵",   "江湖豪客"],
		["战场兄弟", "同袍弟兄"],
		["克朗",     "两纹银"],
		["绿皮入侵", "南疆五毒与药人犯境"],
		["绿皮部落", "五毒与药人营寨"],
		["绿皮",     "五毒与炼体药人"],
		["哥布林",   "五毒密林伏兵"],
		["兽人军阀", "邪宗药人魔尊"],
		["兽人狂战士","狂暴炼体药人"],
		["兽人青年", "初炼药人凶徒"],
		["兽人战士", "重甲炼体药人"],
		["兽人",     "邪派炼体药人"],
		["亡灵灾祸", "前朝玄宫尸傀浩劫"],
		["亡灵巫师", "湘西控魂妖道"],
		["死灵法师", "湘西控魂妖道"],
		["死灵侍僧", "玄宫血煞尸魔"],
		["吸血鬼",   "玄宫血煞尸魔"],
		["僵尸",     "符水行尸"],
		["骷髅",     "前朝青铜兵俑"],
		["亡灵",     "尸傀与机关兵俑"],
		["圣战",     "西域都护与中原兵燹"],
		["南方城邦", "西域丝路都护府"],
		["城邦",     "西域重城"],
		["游牧民",   "塞外沙路马贼"],
		["野蛮人",   "关外黑水战帮"],
		["强盗头目", "绿林压寨大当家"],
		["强盗劫掠者","绿林悍匪"],
		["强盗暴徒", "绿林喽啰"],
		["强盗",     "绿林响马"],
		["林德虫",   "岭南毒蛟"],
		["巨魔",     "荒山巨猿"],
		["树精",     "千年木魅"],
		["蛛魔",     "五毒巨蛛"],
		["食尸鬼",   "食腐山魈"],
		["女巫",     "迷魂妖姬"],
		["梦魇",     "噬梦魇魅"],
		["剥制工坊", "百工丹坊"],
		["剥制匠",   "百工丹师"],
		["修道院",   "古刹山门"],
		["大教堂",   "大雄宝殿"],
		["教堂",     "古刹道观"],
		["神殿",     "古刹医馆"],
		["牧师",     "游方高僧"],
		["修女",     "清修女冠"],
		["十字军",   "伏魔侠客"],
		["酒馆",     "迎风酒楼"],
		["市政厅",   "州县衙署"],
		["议事会成员", "州县乡绅管事"],
		["议事会",   "州县乡绅公所"],
		["议会",     "州衙堂官"]
	]
};

::Wuxia.Contracts.RewriteCache <- {};
::Wuxia.Contracts.RewriteCacheCount <- 0;
::Wuxia.Contracts.RewriteCacheWorldSalt <- -1;

::Wuxia.Contracts.rewriteText <- function( _str )
{
	if (_str == null || typeof _str != "string" || _str == "") return _str;
	local salt = ("Purify" in ::Wuxia && "getWorldCacheSalt" in ::Wuxia.Purify) ? ::Wuxia.Purify.getWorldCacheSalt() : 0;
	if (salt != ::Wuxia.Contracts.RewriteCacheWorldSalt)
	{
		::Wuxia.Contracts.RewriteCache = {};
		::Wuxia.Contracts.RewriteCacheCount = 0;
		::Wuxia.Contracts.RewriteCacheWorldSalt = salt;
	}
	if (_str.len() <= 768 && (_str in ::Wuxia.Contracts.RewriteCache))
		return ::Wuxia.Contracts.RewriteCache[_str];

	local s = _str;
	foreach (pair in ::Wuxia.Contracts.NarrativePairs)
	{
		if (s.find(pair[0]) != null)
			s = ::Wuxia.Purify.strReplace(s, pair[0], pair[1]);
	}
	s = ::Wuxia.Purify.strReplace(s, "两两纹银", "两纹银");
	if ("fixLocatedChineseNames" in ::Wuxia.Purify)
		s = ::Wuxia.Purify.fixLocatedChineseNames(s);
	if (_str.len() <= 768)
	{
		if (::Wuxia.Contracts.RewriteCacheCount >= 512)
		{
			::Wuxia.Contracts.RewriteCache = {};
			::Wuxia.Contracts.RewriteCacheCount = 0;
		}
		::Wuxia.Contracts.RewriteCache[_str] <- s;
		::Wuxia.Contracts.RewriteCacheCount += 1;
	}
	return s;
};

::Wuxia.Contracts.rewriteEventImage <- function( _imgOrText, _fallbackImg )
{
	if (_imgOrText == null || typeof _imgOrText != "string") return _imgOrText;
	if (_imgOrText.find("[img]gfx/ui/events/wx_ev_") != null) return _imgOrText;
	local openIdx = _imgOrText.find("[img]gfx/ui/events/");
	if (openIdx != null)
	{
		local closeIdx = _imgOrText.find("[/img]", openIdx);
		if (closeIdx != null)
		{
			return _imgOrText.slice(0, openIdx) + "[img]" + _fallbackImg + "[/img]" + _imgOrText.slice(closeIdx + 6);
		}
	}
	return "[img]" + _fallbackImg + "[/img]" + _imgOrText;
};

// =============================================================================
// 2. All 48 Company Ambitions (江湖志向 / 声望目标) + Perkless 7-Slot Adaptation
// =============================================================================
::Wuxia.Ambitions <- {
	// ambitionID -> [ButtonText, TooltipText, UIText, SuccessText]
	Map = {
		["ambition.none"]                         = ["暂不立誓（休整三日后再议）", "眼下先养精蓄锐、打理行囊，三日后再召集众同袍共议下一桩江湖志向。", "", ""],
		["ambition.no_ambition"]                  = ["暂不立誓（休整三日后再议）", "眼下先养精蓄锐、打理行囊，三日后再召集众同袍共议下一桩江湖志向。", "", ""],
		["ambition.allied_civilians"]             = ["与一处州县百姓结为知交", "为州县村镇或西域城邦完成委托，使任一地与战团的交情达到 70。", "与任一州县村镇或西域城邦的交情达到 70", "[img]gfx/ui/events/wx_ev_17.png[/img]你们锄强扶弱、屡保一方平安，城中父老自发送来万民伞与美酒犒军。自此在这座城池采买招贤皆如归家一般！"],
		["ambition.make_nobles_aware"]            = ["闯出名号，令藩镇节度府刮目相看", "累积『江湖声望』至 1,050（名震一方），令各大地方藩镇节度使主动向义社敞开军前重托。", "累积江湖声望至 1,050，引藩镇节度府瞩目", "[img]gfx/ui/events/wx_ev_16.png[/img]茶楼酒肆间尽是传唱贵社战绩的评书，连眼高于顶的藩镇节度使幕府亦遣使送来名刺——从今往后，各大藩镇的肥差军令皆向你们敞开大门！"],
		["ambition.allied_nobles"]                = ["成为一方藩镇节度使的座上客卿", "为地方藩镇世家办事，使任一家的交情达到 90。", "与任一藩镇世家的交情达到 90", "[img]gfx/ui/events/wx_ev_16.png[/img]节度使大人亲自设大宴款待贵社掌门，赐下客卿金印！军镇甲库与神兵铁坊自此任由诸位挑选！"],
		["ambition.battle_standard"]              = ["攒足二千两纹银，立起镇团聚义大纛", "积蓄至少 2,000 两足色纹银，并在行囊中留出至少 1 格空位，定制一杆绣有义社名号的丝绸竖幅聚义大纛。", "积攒 2,000 两纹银定制聚义大纛（须留 1 格行囊空位）", "[img]gfx/ui/events/wx_ev_25.png[/img]老绣娘与铜匠耗时数日，终于将这杆龙头横杆、红缨猎猎的【镇团聚义竖幅大纛】捧至帐前！大纛迎风招展，众弟兄齐声欢呼，豪气直冲云霄！"],
		["ambition.sergeant"]                     = ["培养一名坐镇军心的总瓢把子掌旗官", "令麾下至少 1 名侠客研习统帅号令杂学（如《聚义令》《白马军阵号令》《六韬统军帅印篇》《鬼谷纵横兵策》），或达 5 级且定力 ≥ 65，并留出 1 格行囊空位获赐虎符腰牌。", "令 1 名侠客习得统帅号令杂学（或 5 级且定力 ≥ 65），并留 1 格空位", "[img]gfx/ui/events/wx_ev_17.png[/img]%rallybrother% 气沉丹田、声若洪钟，临阵一呼便令众弟兄胆气倍增！你当众将一枚精铜镌虎【聚义总瓢把子腰牌】佩于其腰间，军心自此稳若磐石！"],
		["ambition.roster_of_12"]                 = ["招兵买马，聚齐十二名江湖好手", "在各州县招贤茶摊广纳贤才，使麾下在册同袍人数达到 12 人，足以摆开完整十二人战阵。", "招募同袍，使在册人数达到 12 人", "[img]gfx/ui/events/wx_ev_01.png[/img]篝火旁刀枪林立、坐满了十二名各怀绝技的江湖好汉！人强马壮，从此纵横山泽再无惧群寇合围！"],
		["ambition.roster_of_16"]                 = ["广开山门，扩充至十六名同袍弟兄", "延揽四方豪杰，使义社在册侠客人数达到 16 人（主力与替补轮换无忧）。", "招募同袍，使在册人数达到 16 人", "[img]gfx/ui/events/wx_ev_01.png[/img]义社声势日隆，麾下已有十六名好手听候调遣，纵是连场恶战亦有生力军轮番上阵！"],
		["ambition.roster_of_20"]                 = ["群雄毕至，汇聚二十名武林豪杰", "在允许 20 人编制的流派下，聚齐整整 20 名在册江湖豪客共襄盛举。", "招募同袍，使在册人数达到 20 人", "[img]gfx/ui/events/wx_ev_01.png[/img]二十骑并辔而行、旌旗蔽日，沿途山寨宵小望尘而逃，俨然一方武林大宗气象！"],
		["ambition.contracts"]                    = ["连办差事，在江湖上立稳守信字号", "在各州县与藩镇接取并圆满完成指定数量的榜文委托差事（当前进度见顶部目标提示）。", "圆满完成州县或藩镇委托差事", "[img]gfx/ui/events/wx_ev_06.png[/img]一桩桩差事干得干净漂亮，各州府主事提起贵社字号无不竖起大拇指，威名更上一层楼！"],
		["ambition.fulfill_x_southern_contracts"] = ["远走西域，扬威丝路诸大都护城", "在西域瀚海绿洲城邦接取并圆满完成指定数量的委托差事（当前进度见顶部目标提示）。", "在西域绿洲诸城圆满完成委托差事", "[img]gfx/ui/events/wx_ev_14.png[/img]驼铃声里，你们的名字传遍了敦煌、高昌与龟兹各大绿洲重镇，胡汉豪商争相奉上厚礼结交！"],
		["ambition.visit_settlements"]            = ["策马九州，遍访天下州府城池", "率队踏足九州大地图上每一座州府、军镇与村落，熟稔四方风土行情。", "踏遍九州大地图所有州府与村镇", "[img]gfx/ui/events/wx_ev_04.png[/img]自江南烟雨渡埠至塞北风雪雄关，天下城池尽留诸位马蹄剑影，胸中自有万里山河！"],
		["ambition.discover_locations"]           = ["搜山寻迹，探明荒野贼巢与古迹", "深入大地图迷雾荒野，探明指定数量的隐秘山寨、古墓废墟或异兽巢穴。", "在荒野迷雾中探明隐秘营寨与古迹", "[img]gfx/ui/events/wx_ev_04.png[/img]舆图之上密密麻麻标出数处隐秘巢穴与前朝遗迹，进退攻守尽在掌握！"],
		["ambition.discover_unique_locations"]    = ["踏破迷津，寻访上古绝世秘境", "深入荒野迷雾，探明新的上古秘境奇观、宗门山门或传说险地。", "在荒野迷雾中探明传说级秘境或奇地", "[img]gfx/ui/events/wx_ev_07.png[/img]拨开重重瘴雾，传说中的旷世奇观赫然映入眼帘，众弟兄无不心潮澎湃！"],
		["ambition.discover_all_unique_locations"]= ["穷极山海，探明十一处传说秘境", "探索荒野，使战团累计发现的传说秘境达到 11 处。", "累计发现 11 处传说秘境", "[img]gfx/ui/events/wx_ev_07.png[/img]凡尘九州再无一片迷雾能阻挡你们的脚步，山海奇景尽收眼底！"],
		["ambition.find_and_destroy_location"]    = ["主动出击，踏平荒野匪巢魔窟", "不接官府悬赏榜文，自行在荒野搜寻并攻破任意 1 座敌方营寨据点（须在无对应委托下主动踏平）。", "自行搜山并攻破 1 座荒野敌方营寨（非委托差事）", "[img]gfx/ui/events/wx_ev_05.png[/img]火光映红天际，又一座凶名昭著的荒野贼巢被你们夷为平地，缴获资财无数！"],
		["ambition.defeat_bandits"]               = ["除暴安良，连破绿林山寨群寇", "在野外或山寨接连击溃指定次数的绿林响马或塞外马贼匪帮。", "击溃绿林响马或塞外马贼匪帮", "[img]gfx/ui/events/wx_ev_05.png[/img]绿林道上闻贵社旗号无不胆寒，群寇纷纷收敛锋芒！"],
		["ambition.defeat_beasts"]                = ["搜山猎妖，诛除荒野凶禽猛兽", "率队猎杀指定次数的荒野凶禽猛兽群，采获异兽奇材。", "击溃荒野凶禽猛兽群", "[img]gfx/ui/events/wx_ev_18.png[/img]虎豹毒蛛尽伏刀下，行囊中满载异兽珍材，众弟兄胆魄愈发豪壮！"],
		["ambition.defeat_undead"]                = ["斩妖除魔，荡涤古墓机关与尸傀", "接连击溃指定次数的前朝青铜机关兵俑或湘西符水尸傀群。", "击溃前朝机关兵俑或湘西尸傀群", "[img]gfx/ui/events/wx_ev_11.png[/img]阴风散尽、冥俑碎裂，众弟兄面对邪祟鬼物早已面不改色！"],
		["ambition.defeat_undead_location"]       = ["深入地宫，捣毁四处尸傀古墓巢穴", "率队攻破 4 座盘踞着尸傀或前朝青铜机关兵俑的地宫古墓据点。", "攻破 4 处前朝古墓或尸傀据点", "[img]gfx/ui/events/wx_ev_12.png[/img]连破四座千年凶墓，金戈铁马踏碎阴司鬼气，天下正道莫不钦服！"],
		["ambition.defeat_goblin_location"]       = ["深入瘴林，连拔四座南疆五毒竹寨", "清剿并摧毁 4 座隐匿山林的南疆五毒奇门伏兵营寨。", "摧毁 4 座南疆五毒伏兵营寨", "[img]gfx/ui/events/wx_ev_09.png[/img]毒箭捕网皆难阻诸位兵锋，四座五毒黑寨尽化飞灰！"],
		["ambition.defeat_orc_location"]          = ["浴血攻坚，踏平四处邪派炼体药人窟", "强攻并焚毁 4 座盘踞着狂暴炼体药人的魔窟大营。", "焚毁 4 座邪派炼体药人魔窟", "[img]gfx/ui/events/wx_ev_10.png[/img]哪怕是铜皮铁骨的炼体巨汉亦在你们阵前纷纷授首，四座魔窟荡然无存！"],
		["ambition.defeat_mercenaries"]           = ["江湖争锋，击败同行敌对镖局豪客", "在实战中正面击败至少 1 支受雇于敌方的江湖武人或镖局豪客队伍。", "在实战中击败 1 支敌对江湖豪客队伍", "[img]gfx/ui/events/wx_ev_25.png[/img]同行过招，高下立判！手下败将抱拳认栽，你们的名头在江湖同道中愈发响亮！"],
		["ambition.defeat_kraken"]                = ["沧溟屠妖，斩杀大泽深渊覆舟巨怪", "深入大泽深渊上古秘境，讨伐传说中的深海触手巨怪（泽龙覆舟巨妖）。", "深入秘境斩杀深海触手巨怪", "[img]gfx/ui/events/wx_ev_21.png[/img]惊涛骇浪间巨触断绝，旷世凶妖终殒于诸位神兵之下，此战足以流芳百世！"],
		["ambition.defeat_civilwar"]              = ["靖平兵燹，终结藩镇节度争霸乱局", "投身各大藩镇会战与军前重托，坚持并推动平息这场席卷中原的『藩镇节度争霸』大劫。", "平息『藩镇节度争霸』天下大势", "[img]gfx/ui/events/wx_ev_16.png[/img]烽烟散尽、盟书重订，饱经战火的中原百姓终于重见太平，而贵社大名已镌入青史！"],
		["ambition.defeat_greenskins"]            = ["力挽狂澜，击退南疆五毒与药人犯境", "浴血奋战，粉碎『南疆五毒与药人犯境』联军席卷中原的天下浩劫。", "击退『南疆五毒与药人犯境』浩劫", "[img]gfx/ui/events/wx_ev_10.png[/img]残存的五毒与药人残部仓皇逃回瘴林塞外，九州苍生因诸位死战而免遭涂炭！"],
		["ambition.defeat_undead_scourge"]        = ["涤荡乾坤，平定前朝玄宫尸傀浩劫", "斩灭控魂妖道与古墓冥军，彻底终结『前朝玄宫尸傀浩劫』天下大劫。", "平定『前朝玄宫尸傀浩劫』", "[img]gfx/ui/events/wx_ev_12.png[/img]地脉阴霾消散、朝阳重照山河，无数亡魂终归安息，贵社救世功德震烁古今！"],
		["ambition.defeat_holywar"]               = ["止戈定边，平息西域与中原万里兵燹", "在南北大战中鼎定乾坤，终结『西域都护与中原兵燹』的旷日血战。", "终结『西域都护与中原兵燹』大势", "[img]gfx/ui/events/wx_ev_14.png[/img]南北罢兵、丝路重通，贵社在万里黄沙与雄关间闯出了不世威名！"],
		["ambition.cart"]                         = ["添置辎重骡车，扩充行囊", "攒足 7,500 两纹银。志向达成时花费 5,000 两添置骡车，行囊增加 27 格。", "攒足 7,500 两纹银添置骡车", "[img]gfx/ui/events/wx_ev_06.png[/img]新添的包铁大骡车轱辘滚滚，从此缴获再多兵甲奇珍亦装得满满当当！"],
		["ambition.wagon"]                        = ["打造重装大镖车，再度扩充行囊", "攒足 15,000 两纹银。志向达成时花费 10,000 两添置镖车，行囊增加 27 格。", "攒足 15,000 两纹银添置镖车", "[img]gfx/ui/events/wx_ev_06.png[/img]四轮重装大镖车气派非凡，粮草、神兵与山海奇材尽可从容随行！"],
		["ambition.hire_follower"]                = ["礼贤下士，延请一位随营江湖奇人", "达成解锁条件并在『篝火行营』界面延揽任意 1 位随营幕僚（如丹鼎方士、五味行厨、百炼随匠等）。", "在篝火行营延请任意 1 位随营幕僚", "[img]gfx/ui/events/wx_ev_03.png[/img]得此奇人入幕襄助，义社行军打仗、炼丹修械顿时如虎添翼！"],
		["ambition.taxidermist"]                  = ["百工开炉，在百工丹坊炼制三件丹药或奇物", "携奇草或异兽奇材前往城中【百工丹坊】，按图炼制或在【八卦丹炉】开炉累计满 3 次（丹药、护具与山海神兵皆计）。", "在百工丹坊或八卦丹炉炼制物品", "[img]gfx/ui/events/wx_ev_03.png[/img]百工丹坊内紫烟袅袅、炉火正旺，奇草异材化作护身灵宝与上乘灵丹，众弟兄实力大增！"],
		["ambition.armor"]                        = ["精甲利兵，备齐三副重铠铁胄", "备齐最大耐久均达 230 的身甲和头盔各 3 件。队员身上与行囊中的装备均可计入。", "拥有最大耐久达 230 的身甲和头盔各 3 件", "[img]gfx/ui/events/wx_ev_16.png[/img]寒光凛凛的山文重铠披挂上身，刀砍箭射只溅火星，前排猛士气吞万里如虎！"],
		["ambition.have_armor_upgrades"]          = ["披挂百工护具，为战甲镶缀护肩披风内衬", "为多件战甲装配百工护甲挂件（如护肩兽吞、轻丝内衬、异兽皮披风等；所需件数见顶部目标提示）。", "为战甲镶缀百工护甲挂件", "[img]gfx/ui/events/wx_ev_16.png[/img]麾下弟兄衣甲鲜明、披风猎猎，行止间尽显一流武林劲旅风范！"],
		["ambition.named_item"]                   = ["寻获一件名动江湖的传世红装神兵", "通过踏平荒野险地、斩杀成名巨寇、百工锻造山海神兵或城坊奇遇，拥有至少 1 件传世红装（神兵/宝甲/宝盾/奇冠）。", "拥有至少 1 件传世红装神兵或宝甲", "[img]gfx/ui/events/wx_ev_07.png[/img]神物出匣、寒芒映月！这件传世至宝落入贵社囊中，必将助麾下高手笑傲群雄！"],
		["ambition.named_item_set"]               = ["神兵宝甲俱全，集齐整套传世红装", "同时拥有传世武器、盾牌、身甲和头盔各 1 件。", "集齐传世武器、盾牌、身甲和头盔各 1 件", "[img]gfx/ui/events/wx_ev_07.png[/img]头顶宝冠、身披神甲、手执名兵——举目九州武林，谁人敢撄其锋！"],
		["ambition.trade"]                        = ["南北行商，做成二十五笔特产生意", "立下志向后，累计买入至少 25 件特产商货，并累计卖出至少 25 件。", "买入和卖出特产商货各 25 件", "[img]gfx/ui/events/wx_ev_06.png[/img]算盘珠响、白银入库！乱世之中既能提刀立威，亦懂行商生财，何愁大事不成！"],
		["ambition.have_y_crowns"]                = ["广积粮饷，存下万两雪花纹银", "精打细算、广接肥差，使义社现存纹银达到 10,000 两以上。", "积蓄现银达到 10,000 两纹银", "[img]gfx/ui/events/wx_ev_06.png[/img]一口口樟木钱箱装满雪花官银，财大气粗之下，神兵秘籍与名家好手皆可从容延揽！"],
		["ambition.have_z_crowns"]                = ["富甲一方，坐拥五万两巨额库银", "使义社现存纹银突破 50,000 两，富可敌城。", "积蓄现银达到 50,000 两纹银", "[img]gfx/ui/events/wx_ev_06.png[/img]五万两白银堆满库房，纵是地方藩镇节度使见了贵社财力亦要礼让三分！"],
		["ambition.have_y_renown"]                = ["名动江湖，累积显赫武林声望", "连战皆捷、广行大事，将义社江湖声望提升至新的名号境界。", "提升义社江湖声望至更高名号", "[img]gfx/ui/events/wx_ev_25.png[/img]说书先生醒木一拍，满堂茶客皆为贵社名号喝彩，天下谁人不识君！"],
		["ambition.have_z_renown"]                = ["威震华夏，登顶泰山北斗级传奇声望", "铸就不朽武林威名，令义社江湖声望登顶震古烁今的传奇之境。", "将江湖声望推升至传奇境界", "[img]gfx/ui/events/wx_ev_25.png[/img]自市井孩童至朝堂重臣，九州之内无人不敬畏贵社赫赫侠名！"],
		["ambition.have_all_provisions"]          = ["粮秣充盈，备齐各色山珍美酒口粮", "在行囊中同时备齐多种不同种类的行军干粮与美酒佳肴（所需种类数见顶部目标提示）。", "在行囊中同时备齐多种不同干粮美酒", "[img]gfx/ui/events/wx_ev_02.png[/img]锅盔、火腿、鹿脯与陈年美酒摆满篝火长席，众弟兄大快朵颐，士气高涨！"],
		["ambition.have_talent"]                  = ["慧眼识珠，延揽或培育一名三星根骨奇才", "招揽或通过『洗经伐髓』冲星，使麾下至少 1 名侠客在任一属性上拥有 3★（三星）根骨资质。", "拥有 1 名任一属性达 3★ 根骨的奇才侠客", "[img]gfx/ui/events/wx_ev_03.png[/img]经脉通透、骨骼精奇！假以时日悉心栽培，此子必成一代开宗立派的大宗师！"],
		["ambition.hammer_mastery"]               = ["苦修重兵，令同袍将锤杖或横练修至二重", "令麾下至少 1 名侠客将锤/杖/钝器外功或任意【横练/杂学】修至二重（炉火纯青）以上，或手持重锤且外功达二重以上。", "令 1 名侠客将锤杖或横练功法修至二重以上", "[img]gfx/ui/events/wx_ev_16.png[/img]%masterbrother% 手中重锤挥洒自如、举重若轻，一锤砸下连精铁胸甲亦应声凹陷！"],
		["ambition.ranged_mastery"]               = ["百步穿杨，培育炉火纯青之神射暗器名家", "令麾下至少 1 名侠客将弓/弩/暗器/火器外功修至二重（炉火纯青）以上，或射艺 ≥ 68 且任一武学达二重以上。", "令 1 名侠客将弓弩或暗器功法修至二重以上", "[img]gfx/ui/events/wx_ev_09.png[/img]%masterbrother% 抬手箭出如电、百步取敌咽喉，军中神射之名当之无愧！"],
		["ambition.weapon_mastery"]               = ["武风鼎盛，门下三名好手外功臻至二重", "令麾下至少 3 名侠客将各自所修的【外功套路】锤炼至二重（炉火纯青）以上境界。", "令至少 3 名侠客将外功套路修至二重以上", "[img]gfx/ui/events/wx_ev_25.png[/img]演武场上刀光剑影、拳风呼啸，门下多名好手外功皆已臻至炉火纯青之境，切磋拆招蔚然成风！"],
		["ambition.win_against_x"]                = ["以寡敌众，正面击溃十二人以上强敌", "在单场实战中正面击败人数不少于 12 名的敌军队伍。", "单场击败不少于 12 人的敌军队伍", "[img]gfx/ui/events/wx_ev_05.png[/img]面对成群强寇依然阵脚不乱、大获全胜，众弟兄实战默契更胜往昔！"],
		["ambition.win_against_y"]                = ["千军辟易，单场大破二十四人以上敌阵", "在单场血战中正面击溃人数不少于 24 名的浩大敌军。", "单场击败不少于 24 人的浩大敌军", "[img]gfx/ui/events/wx_ev_16.png[/img]任凭敌众如潮，在诸位精妙武学与严整战阵面前皆如土鸡瓦狗般灰飞烟灭！"],
		["ambition.win_x_arena_fights"]           = ["扬威红绸擂，在生死演武场取五胜", "立下志向后，在西域城邦的红绸生死演武擂累计再赢 5 场。", "在红绸生死演武擂再胜 5 场", "[img]gfx/ui/events/wx_ev_25.png[/img]五战五捷、血染红绸！西域看客提起你们的擂台威名无不沸腾欢呼！"],
		["ambition.raid_caravans"]                = ["黑道立威，拦路劫夺官商粮草镖车", "立下志向后，在大地图截击贸易商队或补给车队，完成 4 次劫掠。", "劫掠贸易商队或补给车队 4 次", "[img]gfx/ui/events/wx_ev_06.png[/img]横刀立马截断官道，满车绸缎银箱尽归囊中——只是官府捕快怕也已记下了你们的字号。"]
	}
};

// Perkless 7-Slot Helper Checkers for Mastery & Rally Ambitions
::Wuxia.Ambitions.pickFallbackBro <- function()
{
	if (!("World" in getroottable()) || ::World == null || ::World.getPlayerRoster() == null) return null;
	local best = null;
	local bestScore = -1;
	foreach (bro in ::World.getPlayerRoster().getAll())
	{
		if (bro == null || (::Wuxia.hasMember(bro, "isAlive") && !bro.isAlive())) continue;
		local sc = (::Wuxia.hasMember(bro, "getLevel") ? bro.getLevel() * 10 : 0)
			+ (bro.getBaseProperties() != null ? bro.getBaseProperties().Bravery : 0);
		if (best == null || sc > bestScore)
		{
			best = bro;
			bestScore = sc;
		}
	}
	return best;
};

::Wuxia.Ambitions.findSergeantBro <- function()
{
	if (!("World" in getroottable()) || ::World == null || ::World.getPlayerRoster() == null) return null;
	local bestManual = null;
	local bestManualBrv = -1;
	local bestStat = null;
	local bestStatBrv = -1;
	foreach (bro in ::World.getPlayerRoster().getAll())
	{
		if (bro == null || (::Wuxia.hasMember(bro, "isAlive") && !bro.isAlive())) continue;
		local brvBase = (bro.getBaseProperties() != null) ? bro.getBaseProperties().Bravery : 0;
		local brvCur = (::Wuxia.hasMember(bro, "getBravery")) ? bro.getBravery() : brvBase;
		local brv = ::Math.max(brvBase, brvCur);
		local hasRally = false;
		local c = ::Wuxia.Slots.getContainer(bro);
		if (c != null)
		{
			c.ensureSlotsRegisteredInLearned();
			foreach (cmdId in [
				"wx_manual_juyiling",
				"wx_juyi_ling",
				"wx_manual_wuwei_shuaiqi",
				"wx_manual_baima_zhenshu",
				"wx_manual_guigu_zongheng"
			])
			{
				if (c.getLearnedEntry(cmdId) != null)
				{
					hasRally = true;
					break;
				}
			}
			if (!hasRally && c.m.CachedAggFlags != null && ("CommandAuraPct" in c.m.CachedAggFlags) && c.m.CachedAggFlags.CommandAuraPct > 0.0)
				hasRally = true;
		}
		if (!hasRally && bro.getSkills() != null && (
			bro.getSkills().hasSkill("actives.wx_rally_command")
			|| bro.getSkills().hasSkill("actives.wx_tactics_bamen")
			|| bro.getSkills().hasSkill("actives.wx_tactics_guigu")
			|| bro.getSkills().hasSkill("perk.rally_the_troops")))
			hasRally = true;

		if (hasRally)
		{
			if (bestManual == null || brv > bestManualBrv)
			{
				bestManual = bro;
				bestManualBrv = brv;
			}
		}
		else if (bro.getLevel() >= 5 && brv >= 65)
		{
			if (bestStat == null || brv > bestStatBrv)
			{
				bestStat = bro;
				bestStatBrv = brv;
			}
		}
	}
	return bestManual != null ? bestManual : bestStat;
};

::Wuxia.Ambitions.getHammerMasterBros <- function()
{
	local out = [];
	if (!("World" in getroottable()) || ::World == null || ::World.getPlayerRoster() == null) return out;
	foreach (bro in ::World.getPlayerRoster().getAll())
	{
		if (bro == null || (::Wuxia.hasMember(bro, "isAlive") && !bro.isAlive())) continue;
		if (bro.getSkills() != null && bro.getSkills().hasSkill("perk.mastery.hammer"))
		{
			out.push(bro);
			continue;
		}
		local c = ::Wuxia.Slots.getContainer(bro);
		if (c == null) continue;
		c.ensureSlotsRegisteredInLearned();
		local mh = bro.getItems() != null ? bro.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand) : null;
		local hasHeavyWpn = (mh != null && (::Wuxia.hasMember(mh, "isWeaponType")) && (mh.isWeaponType(::Const.Items.WeaponType.Hammer) || mh.isWeaponType(::Const.Items.WeaponType.Mace)));
		local matched = false;
		foreach (mid, entry in c.m.LearnedManuals)
		{
			if (entry == null || entry.Tier < 2) continue;
			local def = ::Wuxia.Slots.getManualDef(mid);
			if (def == null) continue;
			if (def.Category == "henglian" || (hasHeavyWpn && def.Category == "waigong"))
			{
				matched = true;
				break;
			}
			if ("WeaponTypes" in def && def.WeaponTypes != null)
			{
				foreach (wf in def.WeaponTypes)
				{
					local wfl = wf.tolower();
					if (wfl == "hammer" || wfl == "mace" || wfl == "staff")
					{
						matched = true;
						break;
					}
				}
				if (matched) break;
			}
		}
		if (matched) out.push(bro);
	}
	return out;
};

::Wuxia.Ambitions.findHammerMasterBro <- function()
{
	local bros = ::Wuxia.Ambitions.getHammerMasterBros();
	return bros.len() > 0 ? bros[0] : null;
};

::Wuxia.Ambitions.getRangedMasterBros <- function()
{
	local out = [];
	if (!("World" in getroottable()) || ::World == null || ::World.getPlayerRoster() == null) return out;
	foreach (bro in ::World.getPlayerRoster().getAll())
	{
		if (bro == null || (::Wuxia.hasMember(bro, "isAlive") && !bro.isAlive())) continue;
		if (bro.getSkills() != null && (bro.getSkills().hasSkill("perk.mastery.bow") || bro.getSkills().hasSkill("perk.mastery.crossbow") || bro.getSkills().hasSkill("perk.mastery.throwing")))
		{
			out.push(bro);
			continue;
		}
		local c = ::Wuxia.Slots.getContainer(bro);
		if (c == null) continue;
		c.ensureSlotsRegisteredInLearned();
		local rBase = (bro.getBaseProperties() != null) ? bro.getBaseProperties().RangedSkill : 0;
		local rCur = (::Wuxia.hasMember(bro, "getRangedSkill")) ? bro.getRangedSkill() : rBase;
		local rSkill = ::Math.max(rBase, rCur);
		local matched = false;
		foreach (mid, entry in c.m.LearnedManuals)
		{
			if (entry == null || entry.Tier < 2) continue;
			local def = ::Wuxia.Slots.getManualDef(mid);
			if (def == null) continue;
			if ("WeaponTypes" in def && def.WeaponTypes != null)
			{
				foreach (wf in def.WeaponTypes)
				{
					local wfl = wf.tolower();
					if (wfl == "bow" || wfl == "crossbow" || wfl == "throwing" || wfl == "firearm")
					{
						matched = true;
						break;
					}
				}
				if (matched) break;
			}
			if (rSkill >= 68)
			{
				matched = true;
				break;
			}
		}
		if (matched) out.push(bro);
	}
	return out;
};

::Wuxia.Ambitions.findRangedMasterBro <- function()
{
	local bros = ::Wuxia.Ambitions.getRangedMasterBros();
	return bros.len() > 0 ? bros[0] : null;
};

::Wuxia.Ambitions.getTier2WaigongBros <- function()
{
	local out = [];
	if (!("World" in getroottable()) || ::World == null || ::World.getPlayerRoster() == null) return out;
	foreach (bro in ::World.getPlayerRoster().getAll())
	{
		if (bro == null || (::Wuxia.hasMember(bro, "isAlive") && !bro.isAlive())) continue;
		local c = ::Wuxia.Slots.getContainer(bro);
		if (c == null) continue;
		c.ensureSlotsRegisteredInLearned();
		local qualified = false;
		foreach (mid, entry in c.m.LearnedManuals)
		{
			if (entry != null && entry.Tier >= 2)
			{
				local def = ::Wuxia.Slots.getManualDef(mid);
				if (def != null && def.Category == "waigong")
				{
					qualified = true;
					break;
				}
			}
		}
		if (qualified)
			out.push(bro);
	}
	return out;
};

::Wuxia.Ambitions.getTier2WaigongBroNames <- function()
{
	local names = [];
	foreach (bro in ::Wuxia.Ambitions.getTier2WaigongBros())
		names.push(bro.getName());
	return names;
};

::Wuxia.Ambitions.findThreeStarBro <- function()
{
	local roster = ::World.getPlayerRoster();
	if (roster == null) return null;
	foreach (bro in roster.getAll())
	{
		foreach (stars in bro.getTalents())
			if (stars == 3) return bro;
	}
	return null;
};

::Wuxia.Ambitions.getTaxidermistCraftCount <- function()
{
	local statCnt = 0;
	if (::Wuxia.hasWorldField("Statistics") && ::Wuxia.hasMember(::World.Statistics, "getFlags") && ::World.Statistics.getFlags() != null)
		statCnt = ::World.Statistics.getFlags().getAsInt("ItemsCrafted");

	local bpCnt = 0;
	if (::Wuxia.hasWorldField("Crafting") && ::Wuxia.hasMember(::World.Crafting, "m") && ::Wuxia.hasMember(::World.Crafting.m, "Blueprints"))
	{
		foreach (bp in ::World.Crafting.m.Blueprints)
		{
			bpCnt += bp.m.TimesCrafted;
		}
	}
	return ::Math.max(statCnt, bpCnt);
};

::Wuxia.Contracts.resolveSpec <- function( _c, _scriptName = "" )
{
	if (_c == null || !("m" in _c)) return null;
	local t = (::Wuxia.hasMember(_c.m, "Type") && _c.m.Type != null) ? _c.m.Type : "";
	if (t in ::Wuxia.Contracts.SpecMap) return ::Wuxia.Contracts.SpecMap[t];
	if (t.len() > 9 && t.slice(-9) == "_contract")
	{
		local trimmed = t.slice(0, -9);
		if (trimmed in ::Wuxia.Contracts.SpecMap) return ::Wuxia.Contracts.SpecMap[trimmed];
	}
	if (t != "" && ("contract." + t) in ::Wuxia.Contracts.SpecMap)
		return ::Wuxia.Contracts.SpecMap["contract." + t];

	local cands = [];
	if ("ClassName" in _c && typeof _c.ClassName == "string" && _c.ClassName != "")
		cands.push(_c.ClassName);
	if (_scriptName != null && _scriptName != "")
	{
		local parts = split(_scriptName, "/");
		if (parts.len() > 0) cands.push(parts[parts.len() - 1]);
	}
	foreach (cn in cands)
	{
		if (("contract." + cn) in ::Wuxia.Contracts.SpecMap)
			return ::Wuxia.Contracts.SpecMap["contract." + cn];
		if (cn.len() > 9 && cn.slice(-9) == "_contract")
		{
			local stem = "contract." + cn.slice(0, -9);
			if (stem in ::Wuxia.Contracts.SpecMap)
				return ::Wuxia.Contracts.SpecMap[stem];
		}
	}
	return null;
};

::Wuxia.Contracts.applyContractMeta <- function( _c, _scriptName = "" )
{
	if (_c == null || !("m" in _c)) return;
	local spec = ::Wuxia.Contracts.resolveSpec(_c, _scriptName);
	if (spec != null)
	{
		_c.m.Name = spec[0];
		local fixedTitle = spec[0];
		_c.getName <- (function() { return fixedTitle; }).bindenv(_c);
	}
	else if (::Wuxia.hasMember(_c.m, "Name") && typeof _c.m.Name == "string")
	{
		_c.m.Name = ::Wuxia.Contracts.rewriteText(_c.m.Name);
	}
	if (::Wuxia.hasMember(_c.m, "BulletpointsObjectives") && typeof _c.m.BulletpointsObjectives == "array")
	{
		for (local i = 0; i < _c.m.BulletpointsObjectives.len(); i = ++i)
		{
			if (typeof _c.m.BulletpointsObjectives[i] == "string")
				_c.m.BulletpointsObjectives[i] = ::Wuxia.Contracts.rewriteText(_c.m.BulletpointsObjectives[i]);
		}
	}
};

::Wuxia.Ambitions.applyAmbitionText <- function( _a, _scriptName = "" )
{
	if (_a == null || !("m" in _a)) return;
	local id = (::Wuxia.hasMember(_a.m, "ID") && _a.m.ID != null) ? _a.m.ID : "";
	local spec = (id in ::Wuxia.Ambitions.Map) ? ::Wuxia.Ambitions.Map[id] : null;
	if (spec == null)
	{
		local cands = [];
		if ("ClassName" in _a && typeof _a.ClassName == "string" && _a.ClassName != "")
			cands.push(_a.ClassName);
		if (_scriptName != null && _scriptName != "")
		{
			local parts = split(_scriptName, "/");
			if (parts.len() > 0) cands.push(parts[parts.len() - 1]);
		}
		foreach (cn in cands)
		{
			if (("ambition." + cn) in ::Wuxia.Ambitions.Map)
			{
				spec = ::Wuxia.Ambitions.Map["ambition." + cn];
				break;
			}
			if (cn.len() > 9 && cn.slice(-9) == "_ambition" && (("ambition." + cn.slice(0, -9)) in ::Wuxia.Ambitions.Map))
			{
				spec = ::Wuxia.Ambitions.Map["ambition." + cn.slice(0, -9)];
				break;
			}
		}
	}
	if (spec != null)
	{
		if (::Wuxia.hasMember(_a.m, "ButtonText") && spec[0] != "") _a.m.ButtonText = spec[0];
		if (::Wuxia.hasMember(_a.m, "TooltipText") && spec[1] != "") _a.m.TooltipText = spec[1];
		if (::Wuxia.hasMember(_a.m, "UIText") && spec[2] != "") _a.m.UIText = spec[2];
		if (::Wuxia.hasMember(_a.m, "SuccessText") && spec[3] != "") _a.m.SuccessText = spec[3];
		if (::Wuxia.hasMember(_a.m, "SuccessButtonText")) _a.m.SuccessButtonText = "好！壮哉我辈江湖儿女！";
		if (::Wuxia.hasMember(_a.m, "RewardTooltip") && typeof _a.m.RewardTooltip == "string" && _a.m.RewardTooltip != "")
			_a.m.RewardTooltip = ::Wuxia.Contracts.rewriteText(_a.m.RewardTooltip);
		if (::Wuxia.hasMember(_a.m, "TaskTooltip") && typeof _a.m.TaskTooltip == "string" && _a.m.TaskTooltip != "")
			_a.m.TaskTooltip = ::Wuxia.Contracts.rewriteText(_a.m.TaskTooltip);

		if (!("WX_TextApplied" in _a) || !_a.WX_TextApplied)
		{
			_a.WX_TextApplied <- true;
			local bTxt = spec[0];
			local bTip = spec[1];
			local uiTxt = spec[2];
			local sucTxt = spec[3];
			if (bTxt != "") _a.getButtonText <- (function() { return bTxt; }).bindenv(_a);
			// The event button expects the native array of task, reward and renown rows.
			if (bTip != "") _a.getTooltipText <- (function() { return bTip; }).bindenv(_a);
			if (sucTxt != "") _a.getSuccessText <- (function() { return sucTxt; }).bindenv(_a);
			_a.getSuccessButtonText <- (function() { return "好！壮哉我辈江湖儿女！"; }).bindenv(_a);
			if (uiTxt != "" && !("WX_OrigGetUIText" in _a))
			{
				local origUI = (::Wuxia.hasMember(_a, "getUIText")) ? _a.getUIText : null;
				_a.WX_OrigGetUIText <- origUI;
				_a.getUIText <- (function()
				{
					this.m.UIText = uiTxt;
					if (this.m.ID == "ambition.hammer_mastery")
						return uiTxt + " (" + ::Math.min(1, ::Wuxia.Ambitions.getHammerMasterBros().len()) + "/1)";
					if (this.m.ID == "ambition.ranged_mastery")
						return uiTxt + " (" + ::Math.min(1, ::Wuxia.Ambitions.getRangedMasterBros().len()) + "/1)";
					if (this.m.ID == "ambition.weapon_mastery")
						return uiTxt + " (" + ::Math.min(3, ::Wuxia.Ambitions.getTier2WaigongBros().len()) + "/3)";
					if (this.m.ID == "ambition.taxidermist")
						return uiTxt + " (" + ::Math.min(3, ::Wuxia.Ambitions.getTaxidermistCraftCount()) + "/3)";
					if (this.WX_OrigGetUIText != null)
					{
						local raw = "";
						try { raw = this.WX_OrigGetUIText(); } catch (_e) { raw = ""; }
						local pIdx = (raw != null && typeof raw == "string") ? raw.find(" (") : null;
						if (pIdx != null && raw.find(uiTxt) == null)
							return uiTxt + raw.slice(pIdx);
						if (raw != null && typeof raw == "string" && raw.find(uiTxt) == 0)
							return ::Wuxia.Contracts.rewriteText(raw);
					}
					return uiTxt;
				}).bindenv(_a);
			}
		}
	}
	else
	{
		if (::Wuxia.hasMember(_a.m, "ButtonText") && typeof _a.m.ButtonText == "string")
			_a.m.ButtonText = ::Wuxia.Contracts.rewriteText(_a.m.ButtonText);
		if (::Wuxia.hasMember(_a.m, "ButtonTooltip") && typeof _a.m.ButtonTooltip == "string")
			_a.m.ButtonTooltip = ::Wuxia.Contracts.rewriteText(_a.m.ButtonTooltip);
		if (::Wuxia.hasMember(_a.m, "TooltipText") && typeof _a.m.TooltipText == "string")
			_a.m.TooltipText = ::Wuxia.Contracts.rewriteText(_a.m.TooltipText);
		if (::Wuxia.hasMember(_a.m, "UIText") && typeof _a.m.UIText == "string")
			_a.m.UIText = ::Wuxia.Contracts.rewriteText(_a.m.UIText);
		if (::Wuxia.hasMember(_a.m, "SuccessText") && typeof _a.m.SuccessText == "string")
			_a.m.SuccessText = ::Wuxia.Contracts.rewriteEventImage(::Wuxia.Contracts.rewriteText(_a.m.SuccessText), "gfx/ui/events/wx_ev_25.png");
	}
};

// =============================================================================
// 3. Modern Hooks: Contracts, Ambitions & Special/Crisis System Events
// =============================================================================
if ("HooksMod" in ::Wuxia && ::Wuxia.HooksMod != null)
{
	// This contract fields a second orc clan under the native Enemy faction.
	::Wuxia.HooksMod.hook("scripts/entity/tactical/tactical_entity_manager", function( q )
	{
		q.spawn = @(__original) function( _properties )
		{
			local result = __original(_properties);
			if (_properties == null || !("CombatID" in _properties) || _properties.CombatID != "OrcAttack") return result;
			local contract = this.World.Contracts.getActiveContract();
			if (contract == null || contract.getType() != "contract.destroy_orc_camp" || !contract.m.Flags.get("IsOrcsAgainstOrcs")) return result;

			local campFaction = this.World.FactionManager.getFactionOfType(this.Const.FactionType.Orcs);
			if (campFaction == null) return result;
			local types = this.Const.EntityType;
			local orcs = [types.OrcYoung, types.OrcWarrior, types.OrcBerserker, types.OrcWarlord];
			foreach (faction in [campFaction.getID(), this.Const.Faction.Enemy])
			{
				local prefix = faction == campFaction.getID() ? "守寨·" : "攻寨·";
				foreach (actor in this.getInstancesOfFaction(faction))
					if (orcs.find(actor.getType()) != null) actor.setName(prefix + actor.getNameOnly());
			}
			return result;
		};
	});

	// A. Contracts Overhaul (`scripts/contracts/contract` + subclasses)
	::Wuxia.HooksMod.hook("scripts/contracts/contract", function( q )
	{
		q.WX_ResolveContractSpec <- function()
		{
			return ::Wuxia.Contracts.resolveSpec(this);
		};

		q.WX_ApplyContractMeta <- function()
		{
			::Wuxia.Contracts.applyContractMeta(this);
		};

		q.WX_PolishContractScreen <- function( _scr )
		{
			if (_scr == null || typeof _scr != "table") return;
			local spec = this.WX_ResolveContractSpec();
			local evImg = spec != null ? spec[1] : "gfx/ui/events/wx_ev_06.png";
			local sid = ("ID" in _scr && _scr.ID != null) ? _scr.ID : "";

			if ("Title" in _scr && _scr.Title != null && _scr.Title != "")
				_scr.Title = (spec != null) ? spec[0] : ::Wuxia.Contracts.rewriteText(_scr.Title);
			if (sid == "OrcsAgainstOrcs" && this.getType() == "contract.destroy_orc_camp")
				_scr.Title = "药人窟 · 守寨与攻寨两帮火并";

			if ("Text" in _scr && typeof _scr.Text == "string" && _scr.Text != "")
			{
				// Replace Task / Success1 / Negotiation with authentic Wuxia contract prose where matched,
				// while preserving variable interpolation (`buildText`) and mid-quest branching twists!
				local sidLow = sid.tolower();
				if (spec != null && (sid == "Task" || sidLow == "task"))
				{
					_scr.Text = "[img]" + evImg + "[/img]" + this.buildText(spec[2]);
				}
				else if (spec != null && (sid == "Success1" || sid == "Success" || sidLow == "success1"))
				{
					_scr.Text = "[img]" + evImg + "[/img]" + this.buildText(spec[3]);
				}
				else if (sid == "Negotiation" || sidLow.find("negotiat") != null)
				{
					local bodyTxt = ::Wuxia.Contracts.rewriteText(::Wuxia.Purify.strReplace(_scr.Text, "[img]", "[wx_skip_img]"));
					local skIdx = bodyTxt.find("[wx_skip_img]");
					if (skIdx != null)
					{
						local endSk = bodyTxt.find("[/img]", skIdx);
						if (endSk != null)
							bodyTxt = bodyTxt.slice(0, skIdx) + bodyTxt.slice(endSk + 6);
					}
					if (bodyTxt.find("捻须沉吟片刻") == null)
					{
						local intro = this.buildText("%employer% 捻须沉吟片刻，伸出手指与你商议这趟差事的纹银价码与预付盘缠：\n\n");
						bodyTxt = intro + bodyTxt;
					}
					_scr.Text = "[img]" + evImg + "[/img]" + bodyTxt;
				}
				else
				{
					_scr.Text = ::Wuxia.Contracts.rewriteEventImage(::Wuxia.Contracts.rewriteText(_scr.Text), evImg);
				}
			}

			if ("Options" in _scr && typeof _scr.Options == "array")
			{
				for (local i = 0; i < _scr.Options.len(); i = ++i)
				{
					local opt = _scr.Options[i];
					if (opt != null && typeof opt == "table" && ("Text" in opt) && typeof opt.Text == "string")
					{
						opt.Text = ::Wuxia.Contracts.rewriteText(opt.Text);
					}
				}
			}
		};

		if (::Wuxia.qHas(q, "getName"))
		{
			q.getName = @(__original) function()
			{
				this.WX_ApplyContractMeta();
				return __original();
			};
		}

		if (::Wuxia.qHas(q, "getTitle"))
		{
			q.getTitle = @(__original) function()
			{
				this.WX_ApplyContractMeta();
				return ::Wuxia.Contracts.rewriteText(__original());
			};
		}

		if (::Wuxia.qHas(q, "getUICharacterImage"))
		{
			q.getUICharacterImage = @(__original) function( _index = 0 )
			{
				local roster = ("World" in getroottable() && ::World != null) ? ::World.getPlayerRoster() : null;
				local bros = (roster != null) ? roster.getAll() : null;
				local leadBro = (bros != null && bros.len() > 0) ? bros[0] : null;
				local orig0 = __original(0);

				if (_index == 0)
				{
					if (leadBro != null && ::Wuxia.hasMember(leadBro, "getImagePath"))
						return { Image = leadBro.getImagePath(), IsProcedural = true };
					return orig0;
				}
				else if (_index == 1)
				{
					local orig1 = __original(1);
					if (orig1 != null)
						return orig1;
					if (orig0 != null && (leadBro == null || orig0.Image != leadBro.getImagePath()))
						return orig0;
					return null;
				}
				return __original(_index);
			};
		}

		if (::Wuxia.qHas(q, "getUIBulletpoints"))
		{
			q.getUIBulletpoints = @(__original) function( _objectives = true, _payment = true )
			{
				this.WX_ApplyContractMeta();
				local ret = __original(_objectives, _payment);
				if (ret != null && typeof ret == "array")
				{
					for (local i = 0; i < ret.len(); i = ++i)
					{
						if (typeof ret[i] == "table" && ("items" in ret[i]) && typeof ret[i].items == "array")
						{
							if ("title" in ret[i] && typeof ret[i].title == "string")
								ret[i].title = ::Wuxia.Contracts.rewriteText(ret[i].title);
							for (local j = 0; j < ret[i].items.len(); j = ++j)
							{
								if (typeof ret[i].items[j] == "string")
									ret[i].items[j] = ::Wuxia.Contracts.rewriteText(ret[i].items[j]);
								else if (typeof ret[i].items[j] == "table" && ("text" in ret[i].items[j]))
									ret[i].items[j].text = ::Wuxia.Contracts.rewriteText(ret[i].items[j].text);
							}
						}
						else if (typeof ret[i] == "string")
						{
							ret[i] = ::Wuxia.Contracts.rewriteText(ret[i]);
						}
					}
				}
				return ret;
			};
		}

		if (::Wuxia.qHas(q, "setScreen"))
		{
			q.setScreen = @(__original) function( _screen, _restartIfAlreadyActive = true )
			{
				__original(_screen, _restartIfAlreadyActive);
				this.WX_ApplyContractMeta();
				if (this.m.ActiveScreen != null)
				{
					this.WX_PolishContractScreen(this.m.ActiveScreen);
					local sid = ("ID" in this.m.ActiveScreen && typeof this.m.ActiveScreen.ID == "string") ? this.m.ActiveScreen.ID : "";
					if ((sid.find("Success") == 0 || sid == "Payment") && this.m.Flags != null && !this.m.Flags.get("wx_sect_contract_rep")
						&& ("Home" in this.m) && this.m.Home != null && ("SectRelations" in ::Wuxia) && ("getSettlementSects" in ::Wuxia.SectRelations))
					{
						local hSects = ::Wuxia.SectRelations.getSettlementSects(this.m.Home);
						if (hSects.len() > 0 && (hSects[0] in ::Wuxia.Config.Sects))
						{
							this.m.Flags.set("wx_sect_contract_rep", true);
							local sObj = ::Wuxia.Config.Sects[hSects[0]];
							local nextRel = ::Wuxia.SectRelations.addRelation(hSects[0], 5);
							if (("List" in this.m.ActiveScreen) && typeof this.m.ActiveScreen.List == "array")
							{
								this.m.ActiveScreen.List.push({
									id   = 91,
									icon = "ui/wx_icons/wx_glyph_sect_token.png",
									text = "驻地宗门【" + sObj.Name + "】感念义社护境安民，交情 +5（当前：" + nextRel + "）"
								});
							}
						}
					}
				}
			};
		}

		if (::Wuxia.qHas(q, "buildText"))
		{
			q.buildText = @(__original) function( _text )
			{
				return ::Wuxia.Contracts.rewriteText(__original(_text));
			};
		}

		if (::Wuxia.qHas(q, "onDeserialize"))
		{
			q.onDeserialize = @(__original) function( _in )
			{
				__original(_in);
				this.WX_ApplyContractMeta();
			};
		}
	});

	::Wuxia.HooksMod.hookTree("scripts/contracts/contract", function( q )
	{
		if (::Wuxia.qHas(q, "create", false))
		{
			q.create = @(__original) function()
			{
				__original();
				this.WX_ApplyContractMeta();
			};
		}
	});

	// B. Company Ambitions Overhaul (`scripts/ambitions/ambition` + Perkless Mastery/Rally Adaptation)
	::Wuxia.HooksMod.hook("scripts/ambitions/ambition", function( q )
	{
		q.WX_ApplyAmbitionText <- function()
		{
			::Wuxia.Ambitions.applyAmbitionText(this);
		};

		foreach (fn in ["getButtonText", "getTooltipText", "getUIText", "getSuccessText", "getSuccessButtonText", "getRewardTooltip"])
		{
			if (::Wuxia.qHas(q, fn))
			{
				local methodName = fn;
				q[methodName] = @(__original) function()
				{
					this.WX_ApplyAmbitionText();
					return ::Wuxia.Contracts.rewriteText(__original());
				};
			}
		}

		if (::Wuxia.qHas(q, "update"))
		{
			q.update = @(__original) function()
			{
				this.WX_ApplyAmbitionText();
				__original();
			};
		}

		if (::Wuxia.qHas(q, "onDeserialize"))
		{
			q.onDeserialize = @(__original) function( _in )
			{
				__original(_in);
				this.WX_TextApplied <- false;
				this.WX_ApplyAmbitionText();
			};
		}
	});

	::Wuxia.HooksMod.hookTree("scripts/ambitions/ambition", function( q )
	{
		if (::Wuxia.qHas(q, "create", false))
		{
			q.create = @(__original) function()
			{
				__original();
				this.WX_ApplyAmbitionText();
			};
		}
	});

	// Perkless 7-Slot Adaptation for `sergeant_ambition` (`《聚义令》` / Lv5+ Bravery>=65 instead of `perk.rally_the_troops`)
	::Wuxia.HooksMod.hook("scripts/ambitions/ambitions/sergeant_ambition", function( q )
	{
		if (::Wuxia.qHas(q, "onUpdateScore"))
		{
			q.onUpdateScore = @(__original) function()
			{
				__original();
				if (this.m.IsDone) return;
				if (::World.getTime().Days >= 10)
					this.m.Score = ::Math.max(this.m.Score, 1 + ::Math.rand(0, 5));
			};
		}
		if (::Wuxia.qHas(q, "onCheckSuccess"))
		{
			q.onCheckSuccess = @(__original) function()
			{
				return ::World.Assets.getStash().hasEmptySlot() && ::Wuxia.Ambitions.findSergeantBro() != null;
			};
		}
		if (::Wuxia.qHas(q, "onReward"))
		{
			q.onReward = @(__original) function()
			{
				local item = ::new("scripts/items/accessory/sergeant_badge_item");
				::World.Assets.getStash().add(item);
				this.m.SuccessList.push({
					id = 10,
					icon = "ui/items/" + item.getIcon(),
					text = "获赐统帅信物【" + item.getName() + "】"
				});
				local bro = ::Wuxia.Ambitions.findSergeantBro();
				if (bro != null && ::Wuxia.hasMember(bro, "getTitle") && ::Wuxia.hasMember(bro, "setTitle") && bro.getTitle() == "")
				{
					bro.setTitle("总瓢把子");
					local shortNm = ::Wuxia.hasMember(bro, "getNameOnly") ? bro.getNameOnly() : bro.getName();
					this.m.SuccessList.push({
						id = 11,
						icon = "ui/icons/special.png",
						text = shortNm + "获封掌旗尊号【总瓢把子】"
					});
				}
			};
		}
		if (::Wuxia.qHas(q, "onPrepareVariables"))
		{
			// Vanilla looks up the Rally perk again while formatting the reward screen.
			// Resolve its placeholders from the same candidate as the Wuxia success and reward checks.
			q.onPrepareVariables = @(__original) function( _vars )
			{
				local bro = ::Wuxia.Ambitions.findSergeantBro();
				local fullName = (bro != null) ? bro.getName() : "掌旗执事";
				local shortName = (bro != null && ::Wuxia.hasMember(bro, "getNameOnly")) ? bro.getNameOnly() : fullName;
				_vars.push(["rallybrother", fullName]);
				_vars.push(["sergeantbrother", shortName]);
				_vars.push(["sergeantbrotherfull", fullName]);
			};
		}
	});

	// Perkless 7-Slot Adaptation for `hammer_mastery_ambition`
	::Wuxia.HooksMod.hook("scripts/ambitions/ambitions/hammer_mastery_ambition", function( q )
	{
		if (::Wuxia.qHas(q, "onUpdateScore"))
		{
			q.onUpdateScore = @(__original) function()
			{
				__original();
				if (this.m.IsDone) return;
				if (::Wuxia.Ambitions.findHammerMasterBro() != null)
				{
					this.m.Score = 0;
					return;
				}
				if (::World.getTime().Days >= 15)
					this.m.Score = ::Math.max(this.m.Score, 1 + ::Math.rand(0, 4));
			};
		}
		if (::Wuxia.qHas(q, "onCheckSuccess"))
		{
			q.onCheckSuccess = @(__original) function()
			{
				return (::Wuxia.Ambitions.findHammerMasterBro() != null) || __original();
			};
		}
		if (::Wuxia.qHas(q, "getBrosWithMastery"))
		{
			q.getBrosWithMastery = @(__original) function()
			{
				return ::Wuxia.Ambitions.getHammerMasterBros().len();
			};
		}
		if (::Wuxia.qHas(q, "onPrepareVariables"))
		{
			// Do NOT invoke vanilla __original(_vars): without `perk.mastery.hammer`, vanilla indexes empty array `[0]` and crashes!
			q.onPrepareVariables = @(__original) function( _vars )
			{
				local bros = ::Wuxia.Ambitions.getHammerMasterBros();
				local bro1 = bros.len() > 0 ? bros[0] : ::Wuxia.Ambitions.pickFallbackBro();
				local bro2 = bros.len() > 1 ? bros[1] : bro1;
				local full1 = (bro1 != null) ? bro1.getName() : "重兵好手";
				local short1 = (bro1 != null && ::Wuxia.hasMember(bro1, "getNameOnly")) ? bro1.getNameOnly() : full1;
				local short2 = (bro2 != null && ::Wuxia.hasMember(bro2, "getNameOnly")) ? bro2.getNameOnly() : short1;
				_vars.push(["masterbrother", full1]);
				_vars.push(["brother1", short1]);
				_vars.push(["brother2", short2]);
				_vars.push(["hammerbrother", short1]);
				_vars.push(["hammerbrotherfull", full1]);
			};
		}
	});

	// Perkless 7-Slot Adaptation for `ranged_mastery_ambition`
	::Wuxia.HooksMod.hook("scripts/ambitions/ambitions/ranged_mastery_ambition", function( q )
	{
		if (::Wuxia.qHas(q, "onUpdateScore"))
		{
			q.onUpdateScore = @(__original) function()
			{
				__original();
				if (this.m.IsDone) return;
				if (::Wuxia.Ambitions.findRangedMasterBro() != null)
				{
					this.m.Score = 0;
					return;
				}
				if (::World.getTime().Days >= 15)
					this.m.Score = ::Math.max(this.m.Score, 1 + ::Math.rand(0, 4));
			};
		}
		if (::Wuxia.qHas(q, "onCheckSuccess"))
		{
			q.onCheckSuccess = @(__original) function()
			{
				return (::Wuxia.Ambitions.findRangedMasterBro() != null) || __original();
			};
		}
		if (::Wuxia.qHas(q, "getBrosWithMastery"))
		{
			q.getBrosWithMastery = @(__original) function()
			{
				return ::Wuxia.Ambitions.getRangedMasterBros().len();
			};
		}
		if (::Wuxia.qHas(q, "onPrepareVariables"))
		{
			q.onPrepareVariables = @(__original) function( _vars )
			{
				local bros = ::Wuxia.Ambitions.getRangedMasterBros();
				local bro1 = bros.len() > 0 ? bros[0] : ::Wuxia.Ambitions.pickFallbackBro();
				local full1 = (bro1 != null) ? bro1.getName() : "神射好手";
				local short1 = (bro1 != null && ::Wuxia.hasMember(bro1, "getNameOnly")) ? bro1.getNameOnly() : full1;
				_vars.push(["masterbrother", full1]);
				_vars.push(["brother1", short1]);
				_vars.push(["rangedbrother", short1]);
				_vars.push(["rangedbrotherfull", full1]);
			};
		}
	});

	// Perkless 7-Slot Adaptation for `weapon_mastery_ambition` (3+ brothers with Tier 2+ Waigong)
	::Wuxia.HooksMod.hook("scripts/ambitions/ambitions/weapon_mastery_ambition", function( q )
	{
		if (::Wuxia.qHas(q, "onUpdateScore"))
		{
			q.onUpdateScore = @(__original) function()
			{
				__original();
				if (this.m.IsDone) return;
				if (::Wuxia.Ambitions.getTier2WaigongBros().len() >= 3)
				{
					this.m.Score = 0;
					return;
				}
				if (::World.getTime().Days >= 18)
					this.m.Score = ::Math.max(this.m.Score, 1 + ::Math.rand(0, 5));
			};
		}
		if (::Wuxia.qHas(q, "onCheckSuccess"))
		{
			q.onCheckSuccess = @(__original) function()
			{
				return (::Wuxia.Ambitions.getTier2WaigongBros().len() >= 3) || __original();
			};
		}
		if (::Wuxia.qHas(q, "getBrosWithMastery"))
		{
			q.getBrosWithMastery = @(__original) function()
			{
				return ::Wuxia.Ambitions.getTier2WaigongBros().len();
			};
		}
		if (::Wuxia.qHas(q, "onPrepareVariables"))
		{
			// Do NOT invoke vanilla __original(_vars): without vanilla weapon mastery perks, vanilla indexes `[0]` and crashes!
			q.onPrepareVariables = @(__original) function( _vars )
			{
				local bros = ::Wuxia.Ambitions.getTier2WaigongBros();
				local bro1 = bros.len() > 0 ? bros[0] : ::Wuxia.Ambitions.pickFallbackBro();
				local bro2 = bros.len() > 1 ? bros[1] : bro1;
				local full1 = (bro1 != null) ? bro1.getName() : "外功好手";
				local short1 = (bro1 != null && ::Wuxia.hasMember(bro1, "getNameOnly")) ? bro1.getNameOnly() : full1;
				local short2 = (bro2 != null && ::Wuxia.hasMember(bro2, "getNameOnly")) ? bro2.getNameOnly() : short1;
				_vars.push(["masterbrother", full1]);
				_vars.push(["brother1", short1]);
				_vars.push(["brother2", short2]);
			};
		}
	});

	::Wuxia.HooksMod.hook("scripts/ambitions/ambitions/have_talent_ambition", function( q )
	{
		q.onUpdateScore = @(__original) function()
		{
			__original();
			if (this.m.Score > 0 && ::Wuxia.Ambitions.findThreeStarBro() != null)
				this.m.Score = 0;
		};
		q.onCheckSuccess = @(__original) function()
		{
			return ::Wuxia.Ambitions.findThreeStarBro() != null;
		};
		q.onPrepareVariables = @(__original) function( _vars )
		{
			local bro = ::Wuxia.Ambitions.findThreeStarBro();
			if (bro != null) _vars.push(["star", bro.getName()]);
		};
	});

	// Count both town blueprints and Bagua Cauldron brews.
	::Wuxia.HooksMod.hook("scripts/ambitions/ambitions/taxidermist_ambition", function( q )
	{
		if (::Wuxia.qHas(q, "onUpdateScore"))
		{
			q.onUpdateScore = @(__original) function()
			{
				__original();
				if (this.m.IsDone) return;
				if (::Wuxia.Ambitions.getTaxidermistCraftCount() >= 3)
					this.m.Score = 0;
			};
		}
		if (::Wuxia.qHas(q, "onCheckSuccess"))
		{
			q.onCheckSuccess = @(__original) function()
			{
				return (::Wuxia.Ambitions.getTaxidermistCraftCount() >= 3) || __original();
			};
		}
	});

	// Bug 5 Fix: Guarantee `choose_ambition_event` ALWAYS presents at least 3 distinct playable Jianghu ambitions!
	// Vanilla BB restricts Day 1 (`getDone() == 0`) to a single `allied_civilians` option, gates most mid-game ambitions
	// behind `battle_standard.isDone()`, and dries up in late game once one-shot ambitions are completed.
	::Wuxia.Ambitions.ensureMinimumSelection <- function( _mgr, _minChoices = 3 )
	{
		if (_mgr == null || !("m" in _mgr) || _mgr.m == null) return;
		if (!("Ambitions" in _mgr.m) || _mgr.m.Ambitions == null || _mgr.m.Ambitions.len() < _minChoices) return;
		if (!("Selection" in _mgr.m) || _mgr.m.Selection == null)
			_mgr.m.Selection = [];
		if (_mgr.m.Selection.len() >= _minChoices) return;

		local picked = {};
		foreach (s in _mgr.m.Selection)
		{
			if (s != null && ::Wuxia.hasMember(s, "getID"))
				picked[s.getID()] <- true;
		}

		local days = ::Wuxia.hasWorldField("getTime") ? ::World.getTime().Days : (::World != null ? ::World.getTime().Days : 1);
		local rosterSz = (::World != null && ::World.getPlayerRoster() != null) ? ::World.getPlayerRoster().getSize() : 0;

		local canOfferFallback = function( _amb )
		{
			if (_amb == null || !("m" in _amb)) return false;
			local aid = _amb.getID();
			if (aid == null || aid == "" || aid == "ambition.none" || aid == "ambition.no_ambition" || (aid in picked))
				return false;
			if (_amb.isDone()) return false;
			local ok = false;
			try { ok = !_amb.isSuccess(); } catch (_eS) { ok = true; }
			if (!ok) return false;

			if (aid == "ambition.wx_visit_sanctum" || aid == "ambition.wx_assemble_manual") return true;
			if (aid == "ambition.allied_civilians" || aid == "ambition.contracts" || aid == "ambition.defeat_bandits") return true;
			if (aid == "ambition.roster_of_12") return rosterSz < 12;
			if (aid == "ambition.battle_standard") return (::World.Assets != null && ::World.Assets.getMoney() < 2000);
			if (aid == "ambition.sergeant") return days >= 3 && ::Wuxia.Ambitions.findSergeantBro() == null;
			if (aid == "ambition.wx_brew_elixir") return days >= 2;
			if (aid == "ambition.defeat_beasts" || aid == "ambition.find_and_destroy_location" || aid == "ambition.trade") return days >= 3;
			if (aid == "ambition.taxidermist") return days >= 5 && ::Wuxia.Ambitions.getTaxidermistCraftCount() < 3;
			if (aid == "ambition.wx_marrow_wash" || aid == "ambition.hammer_mastery" || aid == "ambition.ranged_mastery" || aid == "ambition.weapon_mastery") return days >= 8;
			if (aid == "ambition.wx_slay_shanhai" || aid == "ambition.wx_break_10ap") return days >= 15;
			return false;
		};

		// Priority order: stage-appropriate Wuxia & core mercenary goals
		local priorityIDs = [
			"ambition.wx_visit_sanctum",
			"ambition.wx_assemble_manual",
			"ambition.allied_civilians",
			"ambition.contracts",
			"ambition.roster_of_12",
			"ambition.defeat_bandits",
			"ambition.wx_brew_elixir",
			"ambition.battle_standard",
			"ambition.sergeant",
			"ambition.defeat_beasts",
			"ambition.find_and_destroy_location",
			"ambition.taxidermist",
			"ambition.weapon_mastery",
			"ambition.wx_marrow_wash",
			"ambition.hammer_mastery",
			"ambition.ranged_mastery",
			"ambition.wx_slay_shanhai",
			"ambition.wx_break_10ap",
			"ambition.trade"
		];

		foreach (pid in priorityIDs)
		{
			if (_mgr.m.Selection.len() >= _minChoices) break;
			local cand = ::Wuxia.hasMember(_mgr, "getAmbition") ? _mgr.getAmbition(pid) : null;
			if (cand != null && canOfferFallback(cand))
			{
				cand.WX_ApplyAmbitionText();
				_mgr.m.Selection.push(cand);
				picked[pid] <- true;
			}
		}

		// Late-game safety net: if every single one-shot ambition in the campaign is already `IsDone`,
		// recycle repeatable Jianghu patrol/contract ambitions so the ambition pool never dries up!
		if (_mgr.m.Selection.len() < _minChoices)
		{
			foreach (repID in ["ambition.contracts", "ambition.defeat_bandits", "ambition.defeat_beasts", "ambition.find_and_destroy_location", "ambition.trade"])
			{
				if (_mgr.m.Selection.len() >= _minChoices) break;
				if (repID in picked) continue;
				local repAmb = ::Wuxia.hasMember(_mgr, "getAmbition") ? _mgr.getAmbition(repID) : null;
				if (repAmb != null && repAmb.isDone() && ::Wuxia.hasMember(repAmb, "reset"))
				{
					try
					{
						repAmb.reset();
						repAmb.m.IsDone = false;
						repAmb.WX_ApplyAmbitionText();
						_mgr.m.Selection.push(repAmb);
						picked[repID] <- true;
					}
					catch (_eR) {}
				}
			}
		}
	};

	::Wuxia.HooksMod.hook("scripts/events/events/special/choose_ambition_event", function( q )
	{
		if (::Wuxia.qHas(q, "fire"))
		{
			q.fire = @(__original) function()
			{
				if ("World" in getroottable() && ::World != null && ("Ambitions" in ::World) && ::World.Ambitions != null)
					::Wuxia.Ambitions.ensureMinimumSelection(::World.Ambitions, 3);
				return __original();
			};
		}
	});

	// C. Special System Events & Late-Game Crisis Events Wuxia Localization (`scripts/events/event`)
	::Wuxia.HooksMod.hook("scripts/events/event", function( q )
	{
		q.WX_PolishSystemOrCrisisEvent <- function( _scr )
		{
			if (_scr == null || typeof _scr != "table") return;
			local id = this.getID() != null ? this.getID() : "";
			if (id == "" || id.find("event.wx_") == 0) return;

			if (id == "event.choose_ambition")
			{
				this.m.Title = "聚义篝火 · 共议江湖志向";
				if ("Text" in _scr)
				{
					_scr.Text = "[img]gfx/ui/events/wx_ev_01.png[/img]夜幕低垂，行营篝火噼啪作响。麾下众弟兄擦拭着兵刃围坐一圈，目光灼灼地望向你这位当家掌门。\n\n乱世江湖犹如逆水行舟，若无一桩响当当的志向凝聚人心，队伍便易失了锐气。眼下正是立誓定策之时——下一步，我们要在九州武林闯出怎样的名堂？";
				}
			}
			else if (id == "event.ambition_fulfilled")
			{
				this.m.Title = "夙愿得偿 · 威名远播";
				if ("Text" in _scr && typeof _scr.Text == "string")
					_scr.Text = ::Wuxia.Contracts.rewriteEventImage(::Wuxia.Contracts.rewriteText(_scr.Text), "gfx/ui/events/wx_ev_25.png");
			}
			else if (id == "event.ambition_failed")
			{
				this.m.Title = "时移世易 · 另图良策";
				if ("Text" in _scr && typeof _scr.Text == "string")
					_scr.Text = "[img]gfx/ui/events/wx_ev_04.png[/img]江湖风云变幻莫测，原先立下的志向因时局变迁已难以为继。众弟兄虽略感惋惜，却也明白留得青山在、自可另谋宏图之理。";
			}
			else if (id == "event.retinue_slot")
			{
				this.m.Title = "名声渐显 · 幕府开席";
				if ("Text" in _scr && typeof _scr.Text == "string")
					_scr.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]随着义社在九州道上的名头愈发响亮，不少怀才不遇的丹鼎方士、杏林医官与百工巧匠纷纷闻风而来。篝火行营之中，现已腾出新的幕僚席位以延揽随营奇人！";
			}
			else if (id.find("event.crisis.") == 0)
			{
				local crisisImg = "gfx/ui/events/wx_ev_16.png";
				if (id.find("greenskins") != null)
				{
					this.m.Title = "武林大势 · 南疆五毒与药人犯境";
					crisisImg = "gfx/ui/events/wx_ev_10.png";
				}
				else if (id.find("undead") != null)
				{
					this.m.Title = "武林大势 · 前朝玄宫尸傀浩劫";
					crisisImg = "gfx/ui/events/wx_ev_12.png";
				}
				else if (id.find("holywar") != null)
				{
					this.m.Title = "武林大势 · 西域都护与中原兵燹";
					crisisImg = "gfx/ui/events/wx_ev_14.png";
				}
				else
				{
					this.m.Title = "武林大势 · 藩镇节度争霸";
				}
				if ("Text" in _scr && typeof _scr.Text == "string")
					_scr.Text = ::Wuxia.Contracts.rewriteEventImage(::Wuxia.Contracts.rewriteText(_scr.Text), crisisImg);
			}
			else
			{
				if (this.m.Title != null && typeof this.m.Title == "string")
					this.m.Title = ::Wuxia.Contracts.rewriteText(this.m.Title);
				if ("Text" in _scr && typeof _scr.Text == "string")
					_scr.Text = ::Wuxia.Contracts.rewriteEventImage(::Wuxia.Contracts.rewriteText(_scr.Text), "gfx/ui/events/wx_ev_04.png");
			}

			if ("Options" in _scr && typeof _scr.Options == "array")
			{
				for (local i = 0; i < _scr.Options.len(); i = ++i)
				{
					local opt = _scr.Options[i];
					if (opt != null && typeof opt == "table" && ("Text" in opt) && typeof opt.Text == "string")
						opt.Text = ::Wuxia.Contracts.rewriteText(opt.Text);
				}
			}
		};

		if (::Wuxia.qHas(q, "setScreen"))
		{
			q.setScreen = @(__original) function( _screen )
			{
				__original(_screen);
				if (this.m.ActiveScreen != null)
					this.WX_PolishSystemOrCrisisEvent(this.m.ActiveScreen);
			};
		}

		if (::Wuxia.qHas(q, "buildText"))
		{
			q.buildText = @(__original) function( _text )
			{
				local raw = __original(_text);
				local id = this.getID() != null ? this.getID() : "";
				if (id != "" && id.find("event.wx_") != 0)
					return ::Wuxia.Contracts.rewriteText(raw);
				return raw;
			};
		}
	});
}
