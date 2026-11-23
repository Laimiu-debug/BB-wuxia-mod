// Sequential Jianghu Event Chain 3 (Stage 3/3): 劫灰余烬 · 论功行赏
this.wx_event_chain_crisis_3 <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_chain_crisis_3";
		this.m.Title = "劫灰余烬（终）· 凯旋颁赏";
		this.m.Cooldown = 999.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "「同袍浴血所得，自当笑纳盟军重赏与缴获绝学残卷！」",
					function getResult( _ev ) { return "ClaimReward"; }
				}
			],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_25.png[/img]红旗猎猎、捷报飞传！前番那名九州抗劫盟使率着一队押车武僧与道门剑客专程赶到你们营前，高声宣读联军嘉奖令：\n\n『前线大捷，贵社昔日雪中送炭之军资与密报居功至伟！盟中诸位掌门公议，将此役缴获的千二百两战利官银、两张罕见绝学残页与一株雪山灵莲尽数颁赐贵社，以彰武林忠义！』";
			}
		});

		this.m.Screens.push({
			ID = "ClaimReward",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "大杯满饮，共贺九州大捷！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_crisis", 3);
				::Wuxia.Events.addMoney(1200, this.List);
				::Wuxia.Events.addReputation(120, 15, this.List);
				::Wuxia.Events.givePage("secret", 2, this.List);
				::Wuxia.Events.giveItem("scripts/items/misc/wx_herb_xuelian", this.List);
				::Wuxia.Events.addCompanyMood(1.5, "获九州抗劫同盟重赏，全队欢腾", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_25.png[/img]箱笼开启，银光耀目、丹草飘香，更有两张罕见绝学残页妥帖封在檀木匣中！营中欢呼震天，经历此番大劫淬炼，贵社之名已然成为九州武林响当当的一面大旗！";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Bro = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::World.Flags.getAsInt("wx_chain_crisis") != 2) return;
		local lastDay = ::World.Flags.getAsInt("wx_chain_crisis_day");
		if (::World.getTime().Days < lastDay + 10) return;

		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Score = 36;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.Bro = null; }
});
