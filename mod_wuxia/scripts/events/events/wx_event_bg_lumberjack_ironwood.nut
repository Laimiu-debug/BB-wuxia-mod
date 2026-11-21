// Batch E2 Event 24: 百年铁木（深山樵夫/牧羊人/野人在山岭发现遭雷劈焦的百年铁木）

this.wx_event_bg_lumberjack_ironwood <- this.inherit("scripts/events/event", {
	m = {
		Woodsman = null,
		CharmBro = null
	},

	function create()
	{
		this.m.ID = "event.wx_bg_lumberjack_ironwood";
		this.m.Title = "百年铁木";
		this.m.Cooldown = 38.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "「开斧起料！给全队刨一批硬枪杆、箭挺与修盾木骨！」",
					function getResult( _event ) { return "HewShafts"; }
				},
				{
					Text = "「削一串雷击铁木护身牌分给弟兄们，压压荒野邪气。」",
					function getResult( _event ) { return "CarveCharms"; }
				},
				{
					Text = "「日头偏西了，莫为一段枯木耽误赶路。」",
					function getResult( _event ) { return "MoveOn"; }
				}
			],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Woodsman;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "那名熟山林的弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_22.png[/img]荒岭焦土之间，横亘着一株不知生了多少年岁的合抱古木，半边树干被天雷从头劈裂，外皮焦黑如炭。旁人只当是截烧坏的烂柴，" + bName + " 却绕着树根转了两圈，抡起短斧「铿」地砍出一道白印，虎口竟被反震得微微发麻！\n\n他抠下一点泛着紫铜光泽的木心，兴奋地吹了声哨子：『头儿，撞大运了！这是百年老铁木，经天雷炙烤后油性全逼进了木心，纹路拧得比生铁还韧——削枪杆、刨弩箭、补圆盾骨都是顶格好料！山里老人还讲，雷击铁木佩在胸口最能辟邪定魂，专镇夜路上的不干净东西。』";
			}
		});

		this.m.Screens.push({
			ID = "HewShafts",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "家伙什硬实了，打仗才心里有底！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Woodsman;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addSupplies(16, 0, 20, this.List);
				::Wuxia.Events.addStat(bro, "Stamina", 1, "内息上限", "ui/icons/fatigue.png", this.List);
				::Wuxia.Events.addMastery(bro, 40, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_22.png[/img]" + bName + " 脱去外袄光着膀子抡斧劈料，木屑飞溅得像迸开的铜星，每一斧下去都要沉腰借力、气贯双臂。足足挥汗忙活了大半个下午，直砍得双肩冒白气，竟生生劈出十几根沉实笔直的枪杆盾骨与一大捆上好箭杆。\n\n骡车装得满满当当，这半日与老铁木较劲下来，" + bName + " 只觉肺腑气息比往日更绵长，连运劲出招的火候也顺手精进了不少。";
			}
		});

		this.m.Screens.push({
			ID = "CarveCharms",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "贴身挂好，夜路安行。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Woodsman;
				local target = ::Wuxia.Events.isAlive(_event.m.CharmBro) ? _event.m.CharmBro : bro;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "弟兄";
				local tName = ::Wuxia.Events.isAlive(target) ? ::Wuxia.Events.fmtName(target) : "同袍";

				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				if (::Wuxia.Events.isAlive(target) && (!::Wuxia.Events.isAlive(bro) || target.getID() != bro.getID()))
					this.Characters.push(target.getImagePath());

				::Wuxia.Events.addCompanyMood(1.0, "佩戴雷击铁木护身牌，心神大安", this.List);
				::Wuxia.Events.addStat(target, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_22.png[/img]" + bName + " 挑出雷纹最密的一截木心，就着炭火慢慢削出一排拇指大小、焦香扑鼻的雷击木牌，穿了红麻绳挨个分给弟兄们。嘴上说着不信鬼神的老卒们这回倒一个都没推辞，默默塞进了贴身棉衣里。\n\n" + tName + " 捏着那块温沉沉的焦木牌，闻着淡淡的松烟焦香，连日来在荒冢雾林里攒下的心悸竟悄然散去了几分。";
			}
		});

		this.m.Screens.push({
			ID = "MoveOn",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "加快脚程，天黑前下山。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Woodsman;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_22.png[/img]山岚渐起，寒气逼人，此时停下来劈木头实在耽误脚程。" + bName + " 恋恋不舍地摸了摸焦黑树干，把短斧别回腰间，快步跟上了队伍。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Woodsman = null;
		this.m.CharmBro = null;
		if (!::Wuxia.Events.isWorldReady()) return;

		local bro = ::Wuxia.Events.findByBackgrounds([
			"background.lumberjack",
			"background.shepherd",
			"background.wildman"
		]);
		if (bro == null) return;

		local other = ::Wuxia.Events.findRandomBro(bro);
		this.m.Woodsman = bro;
		this.m.CharmBro = other;
		this.m.Score = 16;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Woodsman = null;
		this.m.CharmBro = null;
	}
});
