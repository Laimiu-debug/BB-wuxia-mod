// Non-destructive hooks for Wuxia Loading Screens, Gameplay Tips, and Campfire Retinue Followers

::Wuxia.Screens <- {
	MenuBackgrounds = [
		"ui/screens/wx_menu_bg_01.jpg",
		"ui/screens/wx_menu_bg_02.jpg",
		"ui/screens/wx_menu_bg_03.jpg",
		"ui/screens/wx_menu_bg_04.jpg"
	],
	LoadingScrolls = [
		"ui/screens/wx_loading_01.jpg",
		"ui/screens/wx_loading_02.jpg",
		"ui/screens/wx_loading_03.jpg",
		"ui/screens/wx_loading_04.jpg",
		"ui/screens/wx_loading_05.jpg",
		"ui/screens/wx_loading_06.jpg",
		"ui/screens/wx_loading_07.jpg",
		"ui/screens/wx_loading_08.jpg",
		"ui/screens/wx_menu_bg_01.jpg",
		"ui/screens/wx_menu_bg_02.jpg",
		"ui/screens/wx_menu_bg_03.jpg",
		"ui/screens/wx_menu_bg_04.jpg"
	],
	EpilogueScrolls = {
		game_lost     = "ui/screens/wx_game_lost.jpg",
		retirement_01 = "ui/screens/wx_retirement_01.jpg",
		retirement_02 = "ui/screens/wx_retirement_02.jpg",
		retirement_03 = "ui/screens/wx_retirement_03.jpg",
		retirement_04 = "ui/screens/wx_retirement_04.jpg"
	},
	Tips = [
		"每位侠客满级共解锁七大武学插槽（1/3/5/7/9/11级），其中 7 级进阶槽可在外功与横练杂学间自由择路。",
		"全身最多同时装配 2 门内功（1 主 1 辅，辅修常驻内息与回气折半）与 2 门轻功，切忌贪多嚼不烂。",
		"多门外功或同系功法的常驻攻防面板与穿甲破甲词条遵循『取最高值』法则，但所有已装招式皆可合并入实战技栏。",
		"轻装侠客依仗《金蝉卸力》与真气护体化劲，总气血减伤最高封顶六成；重甲猛士则赖《铁布衫》披甲行气与铜头铁额。",
		"拳掌武学需佩成对护手或指虎方可施展，4 点行动点轻快出招，专擅隔甲透劲、截脉封穴与空手夺白刃。",
		"单手持剑刀而空出副手者，除享双手握持增伤外，辅以杂学《孤锋诀》可补足穿甲锋芒，克制铁甲劲敌。",
		"统帅杂学《聚义令》不绑死战旗兵器，定力深厚者修习后持本命刀剑即可振奋同袍军心、抵御尸傀邪祟惊魂。",
		"各大武林宗门皆在名山幽林、江湖大漠间立有独立【山门 / 山庄 / 总舵】，可在城镇迎客酒肆向酒保打探山门方位。",
		"城镇【百工丹坊】内设青铜八卦丹炉、百炼铁砧与百草药柜：盲投试丹首次炼成即永久载入随身只读《丹经手札》，亦可重锻神兵与寄存奇草！",
		"在城池【铜镜江湖易容阁】不仅可精修四十八相男女侠容、冠发胡须与名号，还可耗银『易容敛息』消解门派追杀令。",
		"洗经伐髓分为『冲星增赋』与『易筋移星』，全身最多维持三项带星天赋；事先服食护脉丹可免失败留下永久暗疾。",
		"累积『江湖威名』不仅可令地方藩镇节度府刮目相看（1,050 威名），还能在行营篝火延请丹鼎方士、百炼随匠等十八路江湖幕僚。",
		"荒村酒肆偶遇独臂老猎妖师，奉上酒资即可在世界舆图迷雾中探明一处尚未讨伐的《山海经》上古凶兽秘境。",
		"斩杀山海大妖必得专属【山海内丹】，既可拖入武学槽炼化灌注巨额火候，亦可入八卦丹炉参悟天品灵丹或铸造传世红装。",
		"子夜无常鬼市压轴竞拍偶有镇派绝学、江湖孤本、洗髓神丹乃至三十九柄古典传世名兵现世，宜预留纹银以待机缘。",
		"各城迎客酒肆一楼设有『长乐赌桌』（马吊廿一点、四家叶子戏、红四牛骨骰、夜走黑风道等七门博戏），闲暇之时可与江湖豪客小赌怡情。",
		"繁华大州府与红绸演武城皆定期召开『天下武林大会（64强）』与『群英演武擂（16强）』，可携五位侠客登台争魁（不伤性命），亦可买单场或六场连环红盘银票入席观战！",
		"所有武功秘籍与残页皆可归入零占格『藏经阁』管理：闲置残页支持一键拼合成书、2:1 同阶融会补缺，或直接拖入未满重槽位『参悟化功』注入火候。",
		"打开右上角『江湖录 (R)』可随时翻阅《江湖宗门名刺》与《山海本草·丹经手札》；结交请教可赴酒肆茶座或独立山门，开炉炼丹与神兵重锻请赴城镇【百工丹坊】。"
	],
	BusinessReputationTitles = [
		"籍籍无名", "初涉江湖", "崭露头角", "小有名气", "侠名渐起",
		"名动一方", "威震州府", "豪杰景从", "名满九州", "威加海内",
		"一代名宿", "武林泰斗", "盖世无双", "震古烁今", "千古传奇", "万世景仰"
	],
	RetinueEffectsMap = {
		alchemist_01     = [
			"八卦丹炉紫气双丹率额外 +20%，开炉炭火纹银八折",
			"城镇百工丹坊炼制器物丹散时有 25% 概率不消耗珍稀异材",
			"解锁西域蛇油奇方制作"
		],
		blacksmith_01    = [
			"百工神兵重锻高品率显著提升，重淬纹银八折",
			"行营修缮全队兵刃、甲胄与盾牌速度提升 33%",
			"纵使传世名器与盾牌在血战中耐久归零碎裂，战后亦能完好重铸保住"
		],
		cook_01          = [
			"随军五味药膳调养，全队所有行军干粮保质期延长 4 日",
			"同袍在行营中的气血自愈恢复速度提升 33%"
		],
		drill_01         = [
			"督导新晋门人早晚拆招喂招，1 级侠客获 +35% 实战历练（每升 1 级递减 5%）",
			"麾下侠客修习一至二重武学功法时，战后功法火候获取额外 +25%",
			"坐镇后备席的同袍心情永不因未能上阵而跌落"
		],
		surgeon_01       = [
			"杏林金针续命：每一名尚未染有永久伤残的侠客首次战败重创必免一死",
			"全队所有临时刀剑外伤、经脉内伤与散功虚弱痊愈所需天数均缩短 1 日"
		],
		scout_01         = [
			"谙熟山川林泽捷径，义社在全地形行军脚力提升 15%",
			"行经密林沼泽与雪原险地时，全队免受瘴疠暗病侵袭"
		],
		lookout_01       = [
			"苍鹰盘空瞭望，大地图行军视野半径拓宽 25%",
			"提前探破敌营与行军队伍的详细兵种编制虚实"
		],
		quartermaster_01 = [
			"统筹骡马镖车：金疮灵药与箭矢火药携行上限各 +100，百工修械铁料上限 +150",
			"每日行军干粮损耗小幅节省"
		],
		paymaster_01     = [
			"精打细算打理义社账房，全队侠客每日月俸饷银总支出降低 15%",
			"彻底杜绝高阶成名侠客借故索要加饷之纷扰"
		],
		recruiter_01     = [
			"各州县招贤茶摊每次刷新额外多引荐 2~4 名待募江湖好手",
			"未试招亦可一眼相破侠客身怀之入门自带武学，切磋看相费减半、入伙盘缠九折"
		],
		trader_01        = [
			"各城集市与商铺产出的西域丝绸、玉璞、香料与盐铁商货数量增加 50%",
			"熟稔南北商行情势，买卖大宗商货差价更占利头"
		],
		cartographer_01  = [
			"每当在荒野迷雾中首次踏勘发现古墓、匪寨与秘境据点，当场获官府舆图赏银 100~400 两",
			"距起行之地愈远、秘境愈凶险，所得堪舆赏银愈丰厚"
		],
		bounty_hunter_01 = [
			"沿途各路敌营出现成名匪首与身怀【传世名器红装】头目的概率显著提升",
			"每斩杀一名成名头目首级，额外向六扇门兑领 350 两悬赏花红"
		],
		minstrel_01      = [
			"琵琶评书传唱九州，义社完成委托与获胜所得『江湖威名』提升 15%",
			"在各地迎客酒肆请酒保打探江湖秘闻时，更容易获知高价值秘宝与险地风声"
		],
		negotiator_01    = [
			"舌灿莲花周旋东家，议价委托酬银时可多争取一轮优厚加价而不伤和气",
			"九州四十四宗门拜会交情涨幅额外 +20%，且酒肆茶座与山门拜访冷却缩短 1 日"
		],
		scavenger_01     = [
			"每场胜仗过后从战场残破甲械中额外拆解回收百工修械铁料",
			"回收本场消耗的部分雕翎箭矢、弩矢与投掷暗器"
		],
		agent_01         = [
			"玄衣耳目遍布九州：在大地图悬停任意城池，无论远近皆可实时洞悉其当前时局状态与悬赏差事",
			"结盟城池的动向与肥差一目了然，免跑冤枉路"
		],
		brigand_01       = [
			"熟知黑白两道暗桩眼线，可在大地图迷雾外实时标示过往商旅镖车与军资粮队行踪",
			"便于绿林路线义社精准设伏截镖"
		]
	},
	RetinueTitleMap = {
		alchemist_01     = "丹鼎方士",
		blacksmith_01    = "百炼随匠",
		cook_01          = "五味行厨",
		drill_01         = "演武总教头",
		surgeon_01       = "杏林医官",
		scout_01         = "踏雪夜斥",
		lookout_01       = "苍鹰望哨",
		quartermaster_01 = "掌印辎重官",
		paymaster_01     = "铁算账房",
		recruiter_01     = "江湖牙人",
		trader_01        = "丝路奇商",
		cartographer_01  = "山海舆图师",
		bounty_hunter_01 = "六扇门快捕",
		minstrel_01      = "盲眼琵琶客",
		negotiator_01    = "茶楼折冲客",
		scavenger_01     = "摸金拾遗客",
		agent_01         = "玄衣密谍",
		brigand_01       = "识途响马"
	},
	RetinueDescMap = {
		alchemist_01     = "精研西域丹火与奇物炼制之术的随行方士，在百工炼丹房炼制丹药器物时有概率省下珍稀异材。",
		blacksmith_01    = "世代执锤淬火的随营百炼铁匠，日夜修缮麾下兵甲藤牌，纵使兵刃护甲在血战中碎裂亦能完好重铸。",
		cook_01          = "擅调五味药膳的走镖老行厨，令行军干粮更加经久耐饥，并加快同袍气血调养愈合。",
		drill_01         = "武馆出身、棍棒严苛的演武总教头，督导新晋弟子早晚操演，大幅加快低阶侠客实战历练晋升。",
		surgeon_01       = "悬壶济世、精通正骨金针的杏林老医官，首次垂死重伤必得救回性命而不留永久暗疾，并缩短疗伤时日。",
		scout_01         = "轻功卓绝、谙熟山林水泽捷径的踏雪夜斥，大幅提升义社在荒野山林间的行军脚力，免受险地暗病。",
		lookout_01       = "蓄养苍鹰、目力及远的边塞老望哨，拓宽大地图行军视野，提前洞察潜伏匪类与敌营虚实。",
		quartermaster_01 = "统管车马骡队的掌印辎重官，扩充箭矢、百工资材与金疮灵药的随军携行上限。",
		paymaster_01     = "算盘精明、账目分毫不差的铁算老账房，妥善打理日常银钱月俸，杜绝索要加饷之纷扰。",
		recruiter_01     = "交游三教九流、识人毒辣的江湖老牙人，令各州县茶摊待募豪客更多，且切磋看相与入伙盘缠更为低廉。",
		trader_01        = "久走西域与江南商道的丝路奇商，令各城集市奇货商产更加充盈，买卖交易更占利头。",
		cartographer_01  = "踏遍荒山古迹的山海舆图师，每每探明荒野秘境与古墓贼巢皆能向官府与藏家换取丰厚赏银。",
		bounty_hunter_01 = "曾任六扇门紫衣捕头的老辣快捕，引诱各路成名匪首与持红装头目现身，每斩首级皆有额外悬赏。",
		minstrel_01      = "怀抱铁拨琵琶、传唱侠义评书的江湖艺人，助义社威名远播九州，并在迎风酒楼打探更多江湖秘闻。",
		negotiator_01    = "舌灿莲花、深谙官场门派人情世故的茶楼说客，议价委托酬银更为优渥，且令各方冷淡敌意更快消解。",
		scavenger_01     = "眼明手快、专精战地搜刮拆解的摸金客，每战过后皆能从残破甲械中回收更多百工资材与完好箭矢。",
		agent_01         = "耳目遍布各州府驿站的玄衣密谍，随时掌握各大藩镇重城与门派驻地的当前时局与肥差悬赏。",
		brigand_01       = "洗手归正、熟知黑道暗桩的绿林老响马，可实时标示官道商旅镖车行踪以供伺机截击。"
	},
	VanillaLoadingScreens = null,
	VanillaTips           = null
};

::Wuxia.Screens.applyScreensAndTips <- function()
{
	if ("Const" in getroottable())
	{
		if ("LoadingScreens" in ::Const && typeof ::Const.LoadingScreens == "array")
		{
			if (::Wuxia.Screens.VanillaLoadingScreens == null)
				::Wuxia.Screens.VanillaLoadingScreens = clone ::Const.LoadingScreens;
			::Const.LoadingScreens = clone ::Wuxia.Screens.LoadingScrolls;
		}
		if ("TipOfTheDay" in ::Const && typeof ::Const.TipOfTheDay == "array")
		{
			if (::Wuxia.Screens.VanillaTips == null)
				::Wuxia.Screens.VanillaTips = clone ::Const.TipOfTheDay;
			::Const.TipOfTheDay = clone ::Wuxia.Screens.Tips;
		}
		if ("Strings" in ::Const && ::Const.Strings != null && "BusinessReputation" in ::Const.Strings && typeof ::Const.Strings.BusinessReputation == "array")
		{
			local repArr = ::Const.Strings.BusinessReputation;
			local wxRep = ::Wuxia.Screens.BusinessReputationTitles;
			for (local i = 0; i < repArr.len() && i < wxRep.len(); i = ++i)
				repArr[i] = wxRep[i];
		}
	}
};

::Wuxia.Screens.applyScreensAndTips();

::Wuxia.Screens.rewriteRetinueRequirement <- function( _text )
{
	if (_text == null || typeof _text != "string" || _text == "") return _text;
	local s = _text;
	if ("Contracts" in ::Wuxia && "rewriteText" in ::Wuxia.Contracts)
		s = ::Wuxia.Contracts.rewriteText(s);
	local pairs = [
		["军团声望", "江湖威名"],
		["战团声望", "江湖威名"],
		["佣兵团",   "江湖义社"],
		["战团",     "义社"],
		["雇佣兵",   "江湖豪客"],
		["佣兵",     "侠客"],
		["弟兄",     "同袍"],
		["贵族家族", "地方藩镇"],
		["贵族",     "藩镇世家"],
		["南方城邦", "西域都护府"],
		["哥布林",   "南疆五毒"],
		["兽人",     "邪派药人"],
		["绿皮",     "五毒与药人"],
		["亡灵",     "玄宫尸傀"],
		["不死族",   "玄宫尸傀"],
		["野蛮人",   "关外战帮"],
		["强盗",     "绿林响马"],
		["红装",     "传世名器"],
		["传奇物品", "传世名器"],
		["商队",     "走镖商队"]
	];
	if ("Purify" in ::Wuxia && "strReplace" in ::Wuxia.Purify)
	{
		for (local i = 0; i < pairs.len(); i = ++i)
			s = ::Wuxia.Purify.strReplace(s, pairs[i][0], pairs[i][1]);
	}
	return s;
};

::Wuxia.Screens.applyFollowerVisuals <- function( _f )
{
	if (_f == null || !("m" in _f)) return;
	local img = null;
	try { img = _f.m.Image; } catch (_e) { img = null; }
	if (img == null || img == "")
		return;
	local rawStem = "";
	if (img.find("ui/campfire/wx_") == 0)
		rawStem = img.slice(("ui/campfire/wx_").len());
	else if (img.find("ui/campfire/") == 0)
	{
		rawStem = img.slice(("ui/campfire/").len());
		_f.m.Image = "ui/campfire/wx_" + rawStem;
	}
	else
		return;

	local lookupStem = rawStem;
	if (lookupStem.len() > 4 && lookupStem.slice(-4) == ".png")
		lookupStem = lookupStem.slice(0, -4);
	if (lookupStem in ::Wuxia.Screens.RetinueTitleMap)
		_f.m.Name = ::Wuxia.Screens.RetinueTitleMap[lookupStem];
	if (lookupStem in ::Wuxia.Screens.RetinueDescMap)
		_f.m.Description = ::Wuxia.Screens.RetinueDescMap[lookupStem];
	if ((lookupStem in ::Wuxia.Screens.RetinueEffectsMap) && ::Wuxia.hasMember(_f.m, "Effects"))
		_f.m.Effects = clone ::Wuxia.Screens.RetinueEffectsMap[lookupStem];
};

// Hook Retinue Follower base class so every camp follower uses Wuxia seated art (`wx_*`), Jianghu title, effects & requirements
::Wuxia.HooksMod.hook("scripts/retinue/follower", function( q )
{
	q.WX_ApplyCampfireVisuals <- function()
	{
		::Wuxia.Screens.applyFollowerVisuals(this);
	};

	if (::Wuxia.qHas(q, "getID"))
	{
		q.getID = @(__original) function()
		{
			this.WX_ApplyCampfireVisuals();
			return __original();
		};
	}

	if (::Wuxia.qHas(q, "getName"))
	{
		q.getName = @(__original) function()
		{
			this.WX_ApplyCampfireVisuals();
			return __original();
		};
	}

	if (::Wuxia.qHas(q, "getCost"))
	{
		q.getCost = @(__original) function()
		{
			this.WX_ApplyCampfireVisuals();
			return __original();
		};
	}

	if (::Wuxia.qHas(q, "getEffects"))
	{
		q.getEffects = @(__original) function()
		{
			this.WX_ApplyCampfireVisuals();
			return __original();
		};
	}

	if (::Wuxia.qHas(q, "getRequirements"))
	{
		q.getRequirements = @(__original) function()
		{
			this.WX_ApplyCampfireVisuals();
			local reqs = __original();
			if (reqs != null && typeof reqs == "array")
			{
				for (local i = 0; i < reqs.len(); i = ++i)
				{
					local r = reqs[i];
					if (r != null && typeof r == "table" && ("Text" in r) && typeof r.Text == "string")
						r.Text = ::Wuxia.Screens.rewriteRetinueRequirement(r.Text);
				}
			}
			return reqs;
		};
	}
});

local _wxFollowerScripts = [
	"scripts/retinue/followers/agent_follower",
	"scripts/retinue/followers/alchemist_follower",
	"scripts/retinue/followers/blacksmith_follower",
	"scripts/retinue/followers/bounty_hunter_follower",
	"scripts/retinue/followers/brigand_follower",
	"scripts/retinue/followers/cartographer_follower",
	"scripts/retinue/followers/cook_follower",
	"scripts/retinue/followers/drill_sergeant_follower",
	"scripts/retinue/followers/lookout_follower",
	"scripts/retinue/followers/minstrel_follower",
	"scripts/retinue/followers/negotiator_follower",
	"scripts/retinue/followers/paymaster_follower",
	"scripts/retinue/followers/quartermaster_follower",
	"scripts/retinue/followers/recruiter_follower",
	"scripts/retinue/followers/scavenger_follower",
	"scripts/retinue/followers/scout_follower",
	"scripts/retinue/followers/surgeon_follower",
	"scripts/retinue/followers/trader_follower"
];

foreach (_fPath in _wxFollowerScripts)
{
	::Wuxia.HooksMod.hook(_fPath, function( q )
	{
		if (::Wuxia.qHas(q, "create", false))
		{
			q.create = @(__original) function()
			{
				__original();
				this.WX_ApplyCampfireVisuals();
			};
		}
	});
}
