// Road Dilemma Event 57: 荒年流民乞食（乱世人情与口粮抉择）

this.wx_event_road_starving_refugees <- this.inherit("scripts/events/event", {
	m = {
		SoftBro = null
	},

	function create()
	{
		this.m.ID = "event.wx_road_starving_refugees";
		this.m.Title = "荒年流民乞食";
		this.m.Cooldown = 34.0 * this.World.getTime().SecondsPerDay;

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

				local bro = _event.m.SoftBro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_27.png[/img]官道石桥两端挤满衣衫褴褛的逃难流民。连月大旱加上藩镇加征辽饷，乡里早已树皮啃尽。见你们牵着驮满行囊的健骡经过，几十双空洞发绿的眼睛齐刷刷望了过来；几名面颊深陷的妇人怀里抱着连哭都哭不出声的婴孩，跪在泥地里颤声讨一口碎饼活命。\n\n队里的 " + ::Wuxia.Events.fmtName(bro) + " 默默攥紧缰绳，偏过头去不忍细看。";

				this.Options.push({
					Text = "分出 120 银两买粮散粥，济这一桥苦命人",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 120) return "NoMoney";
						return "Charity";
					}
				});
				this.Options.push({
					Text = "花 50 银两与一顿饱饭，雇几名还有气力的青壮帮营里修鞍打铁",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 50) return "NoMoney";
						return "HireHands";
					}
				});
				this.Options.push({
					Text = "乱世人命如草，我们自己的弟兄也要吃饭——横刀开道，径直过桥！",
					function getResult( _ev ) { return "ColdPass"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "Charity",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "但行好事，莫问前程。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.SoftBro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(-120, this.List);
				::Wuxia.Events.addReputation(25, 10, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "施银济荒，心中敞亮", this.List);
				if (::Math.rand(1, 100) <= 55)
					::Wuxia.Events.giveManual("common", this.List);
				else
					::Wuxia.Events.givePill("wx_pill_jinchuang", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_27.png[/img]你掏出一百二十两碎银和几包干粮交与流民中尚能主事的族老，嘱咐他们绕开前方匪道南下投亲。临别时，一名落魄老拳师哆嗦着从怀里摸出祖传的旧物硬塞进你掌心：『大爷仁义，老朽留着这些也换不来命，拿去防身罢！』众弟兄虽少了盘缠，步子却迈得格外敞亮。";
			}
		});

		this.m.Screens.push({
			ID = "HireHands",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "各取所需，两不相欠。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addMoney(-50, this.List);
				::Wuxia.Events.addSupplies(14, 8, 0, this.List);
				::Wuxia.Events.addReputation(10, 4, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_27.png[/img]你挑出几名原是铁匠、药童出身的逃难汉子，管饱一顿热粥并付了五十两工钱。他们拼命干了整整半日，把队里松动的甲绳、缺口马掌与跌打药包收拾得妥妥帖帖，临行前千恩万谢地拿着银钱去给家里买粮了。";
			}
		});

		this.m.Screens.push({
			ID = "ColdPass",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "低头赶路。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.SoftBro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addReputation(0, -6, this.List);
				if (::Wuxia.Events.isAlive(bro))
					::Wuxia.Events.addMood(bro, -0.75, "眼看流民受苦却冷漠离去", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_27.png[/img]前排长枪平端，冷铁寒光一晃，哀求的人群立刻鸦雀无声地往桥栏两边缩去。队伍踏过石板桥头，背后那股死一般的寂静压在每个人心头，" + ::Wuxia.Events.fmtName(bro) + " 一路上闷声不吭，连晚饭都少扒了半碗。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "叹息离去。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_27.png[/img]翻遍钱袋也凑不出富余银两，众人只得低着头默默绕过石桥，各自心里沉甸甸的。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (this.World.getTime().Days < 5) return;
		local bro = ::Wuxia.Events.findByBackgrounds([
			"background.monk", "background.refugee", "background.farmhand", "background.oathtaker", "background.beggar"
		]);
		if (bro == null) bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.SoftBro = bro;
		this.m.Score = 13;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.SoftBro = null;
	}
});
