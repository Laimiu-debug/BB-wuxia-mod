// Batch E5 Event 50: 夜雾湘西赶尸队

this.wx_event_weird_xiangxi_corpses <- this.inherit("scripts/events/event", {
	m = {
		Confronter = null,
		SteadyBro  = null
	},

	function create()
	{
		this.m.ID = "event.wx_weird_xiangxi_corpses";
		this.m.Title = "夜雾湘西 · 赶尸铃响";
		this.m.Cooldown = 42.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Options = [];

				local confronter = _event.m.Confronter;
				local steady = _event.m.SteadyBro;
				if (::Wuxia.Events.isAlive(confronter)) this.Characters.push(confronter.getImagePath());
				else if (::Wuxia.Events.isAlive(steady)) this.Characters.push(steady.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_18.png[/img]三更荒径浓雾锁山，连马蹄声都被湿土吞得发闷。忽有清越凄厉的铜摄魂铃自雾深处三声一顿地荡来——『叮铃、叮铃、叮铃』，紧接着是一声拉得极长的沙哑唱喝：『阴人借道——阳人回避——』\n\n未及挪步，乳白夜雾中已浮出一盏蒙着惨绿桑皮纸的竹竿灯笼。提灯者身披褪色杏黄道袍，面皮枯瘦如腊；他身后五步，六具身着粗麻寿衣、额贴朱砂黄符的苍白身影以两根细竹竿穿过腋下，双脚并拢、膝弯不曲，正随着铃声整齐划一地向前蹦跳，空气里漫过一股生石灰、桐油与陈年坟土混杂的冷腥。";

				this.Options.push({
					Text = "熄灭火把、贴崖屏息，待赶尸队彻底远去再动身。",
					function getResult( _ev ) { return "HoldBreath"; }
				});

				this.Options.push({
					Text = "按道上规矩奉上 150 银两，求换一包辰州辟煞灵散。",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 150) return "NoMoney";
						return "TradeDraft";
					}
				});

				if (::Wuxia.Events.isAlive(confronter))
				{
					this.Options.push({
						Text = "让 " + ::Wuxia.Events.shortName(confronter) + " 持械横道，逼问妖道是否私驱邪傀害人！",
						function getResult( _ev ) { return "Confront"; }
					});
				}
			}
		});

		this.m.Screens.push({
			ID = "HoldBreath",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "重新点起火折，加快脚程离去。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.SteadyBro;
				if (!::Wuxia.Events.isAlive(bro)) bro = ::Wuxia.Events.findRandomBro();
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "一名弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addStat(bro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
				::Wuxia.Events.addMood(bro, 0.5, "夜遇赶尸镇定自若", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_18.png[/img]你立即打手势将火把按灭在湿泥里，勒紧牲口口嚼，领着弟兄们死贴冰冷石壁垂眼屏息。绿纸灯笼幽幽擦过三尺外的碎石道，末尾那具高大尸首眉心的黄符被山风掀开半角，露出一双翻白未瞑的浑浊眼睛，却只在原地僵停一息便随着铃音蹦进了暗雾。\n\n不少弟兄后背冷汗湿透中衣，唯有 " + bName + " 自始至终按剑静立、呼吸半分未乱，经此一遭胆气愈发沉凝。";
			}
		});

		this.m.Screens.push({
			ID = "TradeDraft",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收妥灵散，目送绿灯隐入山雾。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				::Wuxia.Events.addMoney(-150, this.List);
				::Wuxia.Events.givePill("wx_pill_dingshen", this.List);
				::Wuxia.Events.addSectRel("xiangxi_ganshi", 12, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_18.png[/img]你未敢横挡竿头，只远远拱手一揖，把一百五十两碎银包进红布轻抛在道旁青石上，扬声道：『走江湖讨口饭，愿求道爷一贴辰州定魂散压压夜路晦气。』\n\n杏黄袍赶尸匠脚步未停，头也不回，干瘦左手只朝路边草丛一弹，一包蜡纸封紧、散发朱砂与龙脑清苦气的药散稳稳落入尘土。雾中遥遥传来半声哑笑：『懂规矩的活人不多了，拿去护眼定魂吧。』铃声渐远，辰州符水门记下了你们这份敬意。";
			}
		});

		this.m.Screens.push({
			ID = "Confront",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "捡起战利品，提防湘西邪宗报复。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local confronter = _event.m.Confronter;
				if (!::Wuxia.Events.isAlive(confronter)) confronter = ::Wuxia.Events.findRandomBro();
				local cName = ::Wuxia.Events.isAlive(confronter) ? ::Wuxia.Events.fmtName(confronter) : "正道弟兄";
				if (::Wuxia.Events.isAlive(confronter)) this.Characters.push(confronter.getImagePath());

				::Wuxia.Events.givePill("wx_pill_huxin", this.List);
				::Wuxia.Events.givePage("sect", 1, this.List, "xiangxi_ganshi");
				::Wuxia.Events.addSectRel("xiangxi_ganshi", -20, this.List);
				::Wuxia.Events.addStat(confronter, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
				::Wuxia.Events.addCompanyMood(0.5, "喝退赶尸妖道胆气大壮", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_18.png[/img]" + cName + " 眼神如刀，一步抢出雾障，兵刃指地发出清脆金铁声，厉喝道：『休拿返乡送葬糊弄鬼！末尾那具寿衣下露着新锈锁子甲，分明是拿死战武人私炼阴傀！』\n\n赶尸妖道脸色骤青，急摇摄魂铃催动两具行尸扑上，却被 " + cName + " 迎面一记狠招连竹竿带尸肩一并震翻！妖道见你们阵脚森严、杀气逼人，不敢久缠，猛甩出一把黑烟灰渣掩护，弃下腰间一只朱砂药瓶与半卷符水秘录残页，急摇破铃领着残尸遁入绝壑。这梁子算是与湘西辰州符水门结实了，但满营弟兄瞧着那妖道仓皇逃命的背影，心头阴霾顿扫一空。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "暂且退避，静候雾散。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_18.png[/img]一摸行囊凑不齐一百五十两现银，你只得压低帽檐退至坡下。杏黄袍赶尸匠冷哼一声，连绿灯都未偏过半寸，摇着摄魂铃径直领着阴森队伍没入了漫山寒雾。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Confronter = null;
		this.m.SteadyBro = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (!::Wuxia.Events.isNight()) return;
		if (::Wuxia.Events.getAliveBros().len() < 1) return;

		this.m.Confronter = ::Wuxia.Events.findByBackgrounds([
			"background.witchhunter",
			"background.monk",
			"background.gravedigger",
			"background.crusader"
		]);
		this.m.SteadyBro = ::Wuxia.Events.findRandomBro();
		this.m.Score = 18;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.Confronter))
		{
			this.m.Confronter = ::Wuxia.Events.findByBackgrounds([
				"background.witchhunter",
				"background.monk",
				"background.gravedigger",
				"background.crusader"
			]);
		}
		if (!::Wuxia.Events.isAlive(this.m.SteadyBro))
			this.m.SteadyBro = ::Wuxia.Events.findRandomBro();
	}

	function onPrepareVariables( _vars ) {}

	function onClear()
	{
		this.m.Confronter = null;
		this.m.SteadyBro = null;
	}
});
