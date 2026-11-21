// Batch E3-33: 运功疗伤（同袍以深厚内家真气贴背渡气，化解内伤与散功虚弱）

this.wx_event_martial_internal_meditation <- this.inherit("scripts/events/event", {
	m = {
		SickBro = null,
		HelperBro = null
	},

	function create()
	{
		this.m.ID = "event.wx_martial_internal_meditation";
		this.m.Title = "运功疗伤";
		this.m.Cooldown = 14.0 * this.World.getTime().SecondsPerDay;

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

				local sick = _event.m.SickBro;
				local helper = _event.m.HelperBro;
				if (::Wuxia.Events.isAlive(sick)) this.Characters.push(sick.getImagePath());
				if (::Wuxia.Events.isAlive(helper)) this.Characters.push(helper.getImagePath());

				local sName = ::Wuxia.Events.fmtName(sick);
				local hName = ::Wuxia.Events.fmtName(helper);
				local hShort = ::Wuxia.Events.shortName(helper);
				local neiName = ::Wuxia.Events.pickManualName(helper, "neigong");
				local meds = ::World.Assets.getMedicine();

				this.Text = "[img]gfx/ui/events/wx_ev_09.png[/img]避风坡下的篝火映着一张张疲惫面孔。" + sName + "缩在草垛边掩口低咳，手帕上虽未见鲜血，可胸口郁滞如压磨盘，连深吸一口夜气都皱紧眉头——体内散功虚弱与旧内伤正隐隐作祟。\n\n" + hName + "放下手里磨了一半的刀石，将双掌在火旁烘热，走过去沉声道：『这么干耗着，明儿真撞上硬茬你连刀都举不稳。解开中衣盘腿坐直，我催动" + neiName + "的一缕温醇真气贴背渡入，替你把淤在灵台穴里的浊气逼出来。』";

				this.Options.push({
					Text = "令 " + hShort + " 沉心静气，直接贴背运功替他逼出淤滞！",
					function getResult( _ev )
					{
						return ::Math.rand(1, 100) <= 75 ? "ChannelClean" : "ChannelTaxing";
					}
				});

				this.Options.push({
					Text = "取 8 份伤药化温膏敷贴经穴，辅以真气导引（现有伤药：" + meds + "，稳妥无损）",
					function getResult( _ev )
					{
						if (::World.Assets.getMedicine() < 8) return "NoMedicine";
						return "MedAssist";
					}
				});

				this.Options.push({
					Text = "渡气最忌心浮气躁、且行军在即，还是令他自行静养。",
					function getResult( _ev ) { return "RestNatural"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "ChannelClean",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "袍泽相护，正是立身之本！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sick = _event.m.SickBro;
				local helper = _event.m.HelperBro;
				if (::Wuxia.Events.isAlive(sick)) this.Characters.push(sick.getImagePath());
				if (::Wuxia.Events.isAlive(helper)) this.Characters.push(helper.getImagePath());

				local sName = ::Wuxia.Events.fmtName(sick);
				local hName = ::Wuxia.Events.fmtName(helper);
				local neiName = ::Wuxia.Events.pickManualName(helper, "neigong");

				this.Text = "[img]gfx/ui/events/wx_ev_09.png[/img]两人在帐帘后一前一后盘坐。" + hName + "双掌轻抵" + sName + "背心命门，将" + neiName + "的真气拆成细丝般徐徐探入，如温水融冰，一寸寸化开经脉里凝结的暗滞。\n\n一炷香后，" + sName + "头顶冒出细密白汽，哇地吐出一口腥苦黑痰，顿觉肺腑豁然一轻，原本滞涩的内伤与虚弱竟化去了个干净！" + hName + "收掌调息，经此一番精细控气，对自身心法的火候也多了几分体悟。";

				::Wuxia.Events.cureInternalStrain(sick, this.List);
				::Wuxia.Events.addMood(sick, 0.85, "得同袍运功渡气，尽化内伤淤滞", this.List);
				::Wuxia.Events.addMood(helper, 0.65, "运功替同袍疗伤顺利收功", this.List);
				::Wuxia.Events.addMastery(helper, 35, this.List);
			}
		});

		this.m.Screens.push({
			ID = "ChannelTaxing",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "快替他敷上冷巾歇息！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sick = _event.m.SickBro;
				local helper = _event.m.HelperBro;
				if (::Wuxia.Events.isAlive(sick)) this.Characters.push(sick.getImagePath());
				if (::Wuxia.Events.isAlive(helper)) this.Characters.push(helper.getImagePath());

				local sName = ::Wuxia.Events.fmtName(sick);
				local hName = ::Wuxia.Events.fmtName(helper);

				this.Text = "[img]gfx/ui/events/wx_ev_09.png[/img]渡气行至最紧要关头，" + sName + "胸口那团顽固浊气竟猛然反噬！" + hName + "眼见抽手便会前功尽弃，干脆咬牙沉肩，硬生生拿自己的手厥阴经脉将那股阴毒余劲兜底吸了过来。\n\n" + sName + "长吐一口郁气，脸色立时红润如常，一身内伤尽除；" + hName + "却闷哼一声震退半步，嘴角溢出一道血线，捂着隐隐生疼的胸口喘息笑道：『没事，皮肉震了一下……总算把你小子拽回来了。』";

				::Wuxia.Events.cureInternalStrain(sick, this.List);
				::Wuxia.Events.applyLightHurt(helper, 0.12, this.List);
			}
		});

		this.m.Screens.push({
			ID = "MedAssist",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "药到气顺，安心睡个好觉。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sick = _event.m.SickBro;
				local helper = _event.m.HelperBro;
				if (::Wuxia.Events.isAlive(sick)) this.Characters.push(sick.getImagePath());
				if (::Wuxia.Events.isAlive(helper)) this.Characters.push(helper.getImagePath());

				local sName = ::Wuxia.Events.fmtName(sick);
				local hName = ::Wuxia.Events.fmtName(helper);

				this.Text = "[img]gfx/ui/events/wx_ev_09.png[/img]先将 8 份伤药煎成温热药泥敷在" + sName + "膻中与背俞大穴上，待药力渗入皮肉松活了筋络，" + hName + "这才稳稳贴掌渡气。\n\n有良药托底护脉，整场导引行云流水、毫无半点凶险。不多时，" + sName + "周身僵冷散尽，原本缠绵难愈的内伤与虚弱彻底冰消瓦解，两人相视一笑，各自精神大好。";

				::Wuxia.Events.addSupplies(0, -8, 0, this.List);
				::Wuxia.Events.cureInternalStrain(sick, this.List);
				::Wuxia.Events.addMood(sick, 0.85, "伤药辅以真气导引，内伤尽愈", this.List);
				::Wuxia.Events.addMood(helper, 0.65, "护脉疗伤顺遂无损", this.List);
			}
		});

		this.m.Screens.push({
			ID = "RestNatural",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "明早再看情形。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.SickBro)) this.Characters.push(_event.m.SickBro.getImagePath());

				local sName = ::Wuxia.Events.fmtName(_event.m.SickBro);
				local hName = ::Wuxia.Events.fmtName(_event.m.HelperBro);
				this.Text = "[img]gfx/ui/events/wx_ev_09.png[/img]你摇了摇头，让" + hName + "留着内息应对明日路途，只替" + sName + "多加了一床厚毛毡，嘱其静卧歇息、徐图缓愈。";
			}
		});

		this.m.Screens.push({
			ID = "NoMedicine",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "另作打算。", function getResult( _ev ) { return "A"; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.SickBro)) this.Characters.push(_event.m.SickBro.getImagePath());
				this.Text = "[img]gfx/ui/events/wx_ev_09.png[/img]清点药箱后才发现，手头伤药尚不足 8 份，不够敷贴护脉之用，只得改选他法。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		local sick = ::Wuxia.Events.findBroWithInternalStrain();
		if (sick == null) return;
		local helper = ::Wuxia.Events.findBroWithManual("neigong", sick);
		if (helper == null) return;

		this.m.SickBro = sick;
		this.m.HelperBro = helper;
		this.m.Score = 30;
	}

	function onClear()
	{
		this.m.SickBro = null;
		this.m.HelperBro = null;
	}
});
