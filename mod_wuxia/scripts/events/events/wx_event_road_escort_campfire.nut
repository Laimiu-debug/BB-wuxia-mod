// Road Encounter: 夜遇走镖驼队 · 合营守望（官道商旅奇遇）

this.wx_event_road_escort_campfire <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_road_escort_campfire";
		this.m.Title = "夜遇镖队 · 合营守望";
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
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_06.png[/img]夕阳西沉，官道开阔处已有几辆插着三角镖旗的大车围成圆阵，七八名风尘仆仆的趟子手正持枪警戒。领头的掌旗镖师见你们打着正经江湖义社大纛，紧绷的脸色顿时缓和下来，主动抱拳高喊：\n\n『前头野狼坡近日不太平，诸位同道不如与敝局合营扎寨、轮流守夜，彼此也好有个照应！』";

				this.Options.push({
					Text = "欣然应允，派精干弟兄与镖局趟子手并肩值夜并互通消息。",
					function getResult( _ev ) { return "ShareCamp"; }
				});
				this.Options.push({
					Text = "拿多余银两向镖局匀购一些随车干粮与箭矢补给（60 银两）。",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 60) return "ShareCamp";
						return "TradeSupplies";
					}
				});
			}
		});

		this.m.Screens.push({
			ID = "ShareCamp",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "江湖路远，青山不改！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addReputation(15, 2, this.List);
				::Wuxia.Events.addCompanyMood(0.6, "与同行镖队合营安稳度夜", this.List);
				::Wuxia.Events.giveFood("scripts/items/supplies/cured_venison_item", "陈年酱卤野鹿脯", this.List);
				this.Text = "[img]gfx/ui/events/wx_ev_06.png[/img]两拨江湖人马合在一处，火把通明、刀枪森严，林间窥伺的宵小终夜未敢露头。次日天明拔营时，掌旗镖师感激地送上一包酱卤鹿脯以谢协防之谊。";
			}
		});

		this.m.Screens.push({
			ID = "TradeSupplies",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "补给齐备，分道起行！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addMoney(-60, this.List);
				::Wuxia.Events.addSupplies(8, 0, 25, this.List);
				::Wuxia.Events.giveFood("scripts/items/supplies/ground_grains_item", "炒熟行军粟米袋", this.List);
				this.Text = "[img]gfx/ui/events/wx_ev_06.png[/img]看在同道合营守夜的情分上，镖师按成本价匀给你们一袋粟米口粮与成捆雕翎羽箭，解了荒野行军补给之急。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (this.World.getTime().Days < 2) return;
		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Score = 23;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.Bro = null; }
});
