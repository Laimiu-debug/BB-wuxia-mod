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
		"前朝古墓机关俑与湘西符水尸傀经脉已绝，免疫点穴封气与暗器奇毒，宜以重锤大斧或纯阳刀罡破之。",
		"行囊中闲置的武学残页既可集齐拼合成书，亦可直接拖入未满重插槽『参悟化功』转化为火候（同脉与同名更有共鸣加成）。",
		"在藏经阁或修为页中，可将任意两张同品阶闲置残页以二合一『融会补缺』，定向补齐急需秘籍的最后一页。",
		"洗经伐髓分为『冲星增赋』与『易筋移星』，全身最多维持三项带星天赋；事先服食护脉丹可免失败留下永久暗疾。",
		"行至各州府城池迎风茶楼，可按当地水土地貌同时拜会三家门派行客，凭门派交情请教独门上乘与绝学秘籍。",
		"与江湖门派交恶过深时，对方将定期派出门派寻仇队沿官道追缉；亦可在茶楼寻觅折冲说客破财消灾。",
		"荒村酒肆偶遇独臂老猎妖师，奉上酒资即可在世界舆图迷雾中探明一处尚未讨伐的《山海经》上古凶兽秘境。",
		"斩杀山海大妖必得专属【山海内丹】，既可拖入武学槽炼化灌注巨额火候，亦可携往城中百工剥制师处锻造传世红装。",
		"子夜无常鬼市压轴竞拍偶有镇派绝学、江湖孤本、洗髓神丹乃至三十九柄古典传世名兵现世，宜预留纹银以待机缘。"
	],
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
	}
};

::Wuxia.Screens.applyScreensAndTips();

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
};

// Hook Retinue Follower base class so every camp follower uses Wuxia seated art (`wx_*`) & Jianghu title
::Wuxia.HooksMod.hook("scripts/retinue/follower", function( q )
{
	q.WX_ApplyCampfireVisuals <- function()
	{
		::Wuxia.Screens.applyFollowerVisuals(this);
	};

	if ("getID" in q)
	{
		q.getID = @(__original) function()
		{
			this.WX_ApplyCampfireVisuals();
			return __original();
		};
	}

	if ("getName" in q)
	{
		q.getName = @(__original) function()
		{
			this.WX_ApplyCampfireVisuals();
			return __original();
		};
	}

	if ("getCost" in q)
	{
		q.getCost = @(__original) function()
		{
			this.WX_ApplyCampfireVisuals();
			return __original();
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
		if ("create" in q)
		{
			q.create = @(__original) function()
			{
				__original();
				this.WX_ApplyCampfireVisuals();
			};
		}
	});
}
