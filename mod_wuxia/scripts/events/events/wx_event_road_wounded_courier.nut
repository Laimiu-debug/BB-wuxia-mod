// Road Encounter: 血染驿骑 · 六扇门急递（官道侠义抉择）

this.wx_event_road_wounded_courier <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_road_wounded_courier";
		this.m.Title = "血染驿骑 · 六扇门急递";
		this.m.Cooldown = 18.0 * this.World.getTime().SecondsPerDay;

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

				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]官道芦苇丛旁倒着一匹口吐白沫的快马，一名身着皂青劲装、腰悬铜牌的六扇门急递快骑倚着界碑喘息，肩窝插着半截淬黑吹箭，怀里仍死死护着一只火漆铜管。\n\n见你们靠近，快骑强提一口真气握住刀柄：『来者何人……我乃州府捕房急递，遭邪派暗桩伏击……若肯以金疮药救我一命，官府必有厚报！』";

				this.Options.push({
					Text = "消耗 8 份金疮药材为他拔箭敷药，护送他上马脱险。",
					function getResult( _ev )
					{
						if (::World.Assets.getMedicine() < 8) return "NoMeds";
						return "SaveCourier";
					}
				});
				this.Options.push({
					Text = "无药可分，替他包扎止血并指明最近的镇甸方向。",
					function getResult( _ev ) { return "BandageOnly"; }
				});
				this.Options.push({
					Text = "乱世各安天命，顺手搜走他鞍袋里的盘缠与武学抄本。",
					function getResult( _ev ) { return "RobCourier"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "SaveCourier",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "侠义当先，一路保重！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addSupplies(0, -8, 0, this.List);
				::Wuxia.Events.addMoney(240, this.List);
				::Wuxia.Events.addReputation(30, 6, this.List);
				::Wuxia.Events.givePage("common", 1, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "拔刀相助救下六扇门急递", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]" + ::Wuxia.Events.fmtName(bro) + " 手起刀落剜去毒血，敷上三七金疮散死死裹紧创口。那快骑缓过气来，郑重抱拳记下你们的义社名号，当场解下官银袋与一卷缴自黑道高手的武学残页相赠，翻身借马绝尘而去。";
			}
		});

		this.m.Screens.push({
			ID = "BandageOnly",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "但愿他能撑回州城。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addMoney(90, this.List);
				::Wuxia.Events.addReputation(15, 2, this.List);
				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]你们撕下干净布条替他勒住伤口止血，又分了一壶清水。快骑感激地留下一小袋碎银作为谢礼，咬牙扶着路标踉跄前行。";
			}
		});

		this.m.Screens.push({
			ID = "NoMeds",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "只能先替他简单止血了。", function getResult( _event ) { return "BandageOnly"; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]翻遍随军药箱，现存的金疮药材已不足八份，只得改用寻常布条替他应急包扎。";
			}
		});

		this.m.Screens.push({
			ID = "RobCourier",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "莫留首尾，速速赶路。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addMoney(310, this.List);
				::Wuxia.Events.addReputation(0, -8, this.List);
				::Wuxia.Events.addCompanyMood(-0.4, "趁人之危搜刮重伤公人，部分弟兄心生不齿", this.List);
				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]你们冷眼摘走他鞍囊中的三百余两密饷银锭扬长而去。背后传来快骑悲愤嘶哑的咒骂，队中几名重义气的汉子一路沉默不语。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (this.World.getTime().Days < 4) return;
		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Score = 20;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.Bro = null; }
});
