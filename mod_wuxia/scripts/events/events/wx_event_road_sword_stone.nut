// Road Encounter: 古道试剑石 · 前辈剑痕（行路悟武）

this.wx_event_road_sword_stone <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_road_sword_stone";
		this.m.Title = "古道试剑石 · 前辈剑痕";
		this.m.Cooldown = 16.0 * this.World.getTime().SecondsPerDay;

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
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]山道拐角耸立着一块丈许高的青黑摩崖巨石，石面纵横交错着三道深逾寸许的陈年兵刃劈痕——一剑斜掠如惊鸿，一刀沉猛如劈岳，一枪中宫透石三分。历经百年风雨冲刷，凛冽武意犹扑面而来。\n\n" + ::Wuxia.Events.fmtName(bro) + " 不由自主驻足凝视，手指顺着石上刻痕缓缓摩挲。";

				this.Options.push({
					Text = "命全队驻马半个时辰，各自印证兵刃发力招法。",
					function getResult( _ev ) { return "GroupStudy"; }
				});
				this.Options.push({
					Text = "让 " + ::Wuxia.Events.shortName(bro) + " 独自静心揣摩石上破甲劲理。",
					function getResult( _ev ) { return "SoloStudy"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "GroupStudy",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "前辈风采，令人神往！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addCompanyMastery(20, this.List);
				::Wuxia.Events.addCompanyMood(0.5, "观摩古道试剑石前辈遗痕", this.List);
				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]众弟兄围聚青石之下比划拆解，印证各自所修外功心诀，虽未得整篇秘传，却也洗去了不少出招滞涩之处。";
			}
		});

		this.m.Screens.push({
			ID = "SoloStudy",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收剑入鞘，继续起行！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro))
				{
					this.Characters.push(bro.getImagePath());
					::Wuxia.Events.addMastery(bro, 45, this.List);
					::Wuxia.Events.addMood(bro, 1.0, "于古道试剑石顿悟发力精要", this.List);
				}
				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]" + ::Wuxia.Events.fmtName(bro) + " 闭目凝神良久，骤然拔刃凌空虚劈一式，破空清啸竟与石上古痕隐隐呼应，周身武学火候大有精进！";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (this.World.getTime().Days < 3) return;
		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Score = 22;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.Bro = null; }
});
