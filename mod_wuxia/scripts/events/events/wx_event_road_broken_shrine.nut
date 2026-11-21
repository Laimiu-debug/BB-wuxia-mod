// Road Encounter: 残破山神庙 · 夜雨论武（行军避雨调息）

this.wx_event_road_broken_shrine <- this.inherit("scripts/events/event", {
	m = {
		Bro1 = null,
		Bro2 = null
	},

	function create()
	{
		this.m.ID = "event.wx_road_broken_shrine";
		this.m.Title = "残破山神庙 · 夜雨论武";
		this.m.Cooldown = 15.0 * this.World.getTime().SecondsPerDay;

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
				local b1 = _event.m.Bro1;
				local b2 = _event.m.Bro2;
				if (::Wuxia.Events.isAlive(b1)) this.Characters.push(b1.getImagePath());
				if (::Wuxia.Events.isAlive(b2)) this.Characters.push(b2.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_01.png[/img]暮色四合，豆大的冷雨骤然砸落官道。幸而前方山坳露出一角飞檐坍塌的古旧山神庙，众弟兄连忙牵马入殿避雨，拢起干柴生起旺火。\n\n檐外风雨如晦，殿内火光跃动，烘烤着淋湿的战袍。众弟兄盘膝围火而坐，一时谈兴大起。";

				this.Options.push({
					Text = "督导众弟兄趁夜雨静心打坐吐纳，温养丹田内息。",
					function getResult( _ev ) { return "Meditate"; }
				});
				this.Options.push({
					Text = "温起水酒纵谈天下英雄轶事，稳固同袍胆魄军心！",
					function getResult( _ev ) { return "Toast"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "Meditate",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "雨歇天明，精神百倍！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local b1 = _event.m.Bro1;
				if (::Wuxia.Events.isAlive(b1)) this.Characters.push(b1.getImagePath());
				::Wuxia.Events.addCompanyMastery(24, this.List);
				::Wuxia.Events.addCompanyMood(0.4, "古庙听雨打坐调息", this.List);
				this.Text = "[img]gfx/ui/events/wx_ev_01.png[/img]听着庙外潇潇雨声，众弟兄屏息凝神运转周天。待东方既白、云收雨霁之时，人人真气充盈、目蕴精光！";
			}
		});

		this.m.Screens.push({
			ID = "Toast",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "风停雨住，策马扬鞭！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local b1 = _event.m.Bro1;
				if (::Wuxia.Events.isAlive(b1))
				{
					this.Characters.push(b1.getImagePath());
					::Wuxia.Events.addStat(b1, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
				}
				::Wuxia.Events.addCompanyMood(0.85, "古庙夜雨把酒论英雄", this.List);
				this.Text = "[img]gfx/ui/events/wx_ev_01.png[/img]水囊传饮，笑语豪歌驱散了荒野秋寒。" + ::Wuxia.Events.fmtName(b1) + " 拍着胸脯立誓要随义社闯出一番惊天动地的名头，满殿弟兄轰然叫好！";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (this.World.getTime().Days < 2) return;
		local b1 = ::Wuxia.Events.findRandomBro();
		if (b1 == null) return;
		this.m.Bro1 = b1;
		this.m.Bro2 = ::Wuxia.Events.findRandomBro(b1);
		this.m.Score = 22;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Bro1 = null;
		this.m.Bro2 = null;
	}
});
