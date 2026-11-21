// Road Encounter: 绝壁灵草 · 提气采药（轻功身法行路奇遇）

this.wx_event_road_herbal_cliff <- this.inherit("scripts/events/event", {
	m = {
		AgileBro = null
	},

	function create()
	{
		this.m.ID = "event.wx_road_herbal_cliff";
		this.m.Title = "绝壁灵草 · 提气采药";
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
				local bro = _event.m.AgileBro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_04.png[/img]行经一处云雾缭绕的险峻山涧，忽闻幽香浮动。抬头望去，数丈高的湿滑青苔岩缝间竟生着几株紫茎赤叶的野生血竭三七与石斛灵草！只是峭壁猿猱难攀，稍有失足便要跌入乱石涧底。";

				this.Options.push({
					Text = "让身法灵便的 " + ::Wuxia.Events.shortName(bro) + " 施展轻功攀崖采药！",
					function getResult( _ev ) { return "ClimbCliff"; }
				});
				this.Options.push({
					Text = "只采涧边寻常草药充实药箱，不必涉险。",
					function getResult( _ev ) { return "SafeGather"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "ClimbCliff",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "好俊的轻功身法！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.AgileBro;
				if (::Wuxia.Events.isAlive(bro))
				{
					this.Characters.push(bro.getImagePath());
					::Wuxia.Events.addMastery(bro, 25, this.List);
					::Wuxia.Events.addMood(bro, 0.75, "绝壁提气摘得灵草", this.List);
				}
				::Wuxia.Events.addSupplies(0, 18, 0, this.List);
				if ("World" in getroottable() && ::World != null && ::World.Assets != null && ::World.Assets.getStash() != null)
				{
					local herb = ::Wuxia.ShanHai.createRandomHerb(true);
					if (herb != null && ::World.Assets.getStash().add(herb) != null)
					{
						this.List.push({ id = 14, icon = "ui/items/" + herb.getIcon(), text = "采得山海奇草【" + herb.getName() + "】" });
					}
				}

				this.Text = "[img]gfx/ui/events/wx_ev_04.png[/img]" + ::Wuxia.Events.fmtName(bro) + " 深吸一口真气，足尖在凸岩老藤上连点三下，如苍鹰掠壁般探手将几株百年血竭三七连根采入药篓，随即借势飘然落地，引来众弟兄一片喝彩！";
			}
		});

		this.m.Screens.push({
			ID = "SafeGather",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "积少成多，聊胜于无。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addSupplies(0, 8, 0, this.List);
				this.Text = "[img]gfx/ui/events/wx_ev_04.png[/img]众弟兄在溪畔草丛间采摘了不少止血艾叶与三七苗，妥善晒干收入随军药箱。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (this.World.getTime().Days < 3) return;
		local best = null;
		local bestInit = -999;
		foreach (b in ::Wuxia.Events.getAliveBros())
		{
			local ini = b.getBaseProperties().Initiative;
			if (ini > bestInit) { bestInit = ini; best = b; }
		}
		if (best == null) return;
		this.m.AgileBro = best;
		this.m.Score = 20;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.AgileBro = null; }
});
