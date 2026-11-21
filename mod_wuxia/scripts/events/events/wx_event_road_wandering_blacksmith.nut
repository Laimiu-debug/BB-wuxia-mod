// Road Encounter: 古柳铁担 · 游方百炼匠（官道整备兵甲）

this.wx_event_road_wandering_blacksmith <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_road_wandering_blacksmith";
		this.m.Title = "古柳铁担 · 游方百炼匠";
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

				this.Text = "[img]gfx/ui/events/wx_ev_17.png[/img]官道里程碑旁叮当脆响，一位赤膊虬髯的老铁匠挑着风箱炭炉担子歇在柳荫下，正在青石水上飞快磨砺一柄缺口朴刀，火星四溅。\n\n老匠人瞥见你们马鞍上磨损的甲叶兵刃，咧嘴笑道：『老汉走南闯北专替镖局武人淬火拾掇家伙！添几文炭火钱，包教诸位刀快甲坚！』";

				this.Options.push({
					Text = "奉上 85 两纹银，请老匠人添补百炼铁料并打磨全队兵刃。",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 85) return "ChatOnly";
						return "BuyTools";
					}
				});
				this.Options.push({
					Text = "请教保养兵刃甲叶的诀窍，歇息片刻上路。",
					function getResult( _ev ) { return "ChatOnly"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "BuyTools",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "好手艺！告辞！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addMoney(-85, this.List);
				::Wuxia.Events.addSupplies(24, 0, 15, this.List);
				::Wuxia.Events.addCompanyMood(0.5, "兵刃开锋、甲叶齐整", this.List);
				this.Text = "[img]gfx/ui/events/wx_ev_17.png[/img]风箱呼呼拉动，老铁匠手锤起落如雨，不消一个时辰便替众弟兄校直了卷刃刀剑，又匀出一箱上好精铁甲片与三棱铁簇相售，物超所值！";
			}
		});

		this.m.Screens.push({
			ID = "ChatOnly",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "受教了，后会有期。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addSupplies(6, 0, 0, this.List);
				this.Text = "[img]gfx/ui/events/wx_ev_17.png[/img]老铁匠大方地送了你们两块青浆磨刀石与少许桐油皮绳，叮嘱雨天行军切莫忘了给刀脊抹油防锈。";
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
		this.m.Score = 21;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.Bro = null; }
});
