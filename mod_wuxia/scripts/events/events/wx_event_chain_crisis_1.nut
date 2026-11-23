// Sequential Jianghu Event Chain 3 (Stage 1/3): 劫灰余烬 · 烽烟流民
this.wx_event_chain_crisis_1 <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_chain_crisis_1";
		this.m.Title = "劫灰余烬（一）· 烽烟南渡";
		this.m.Cooldown = 999.0 * this.World.getTime().SecondsPerDay;

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

				if (::World.Assets.getMedicine() >= 6)
				{
					this.Options.push({
						Text = "「分出 6 份金疮药材救治伤民，护送他们过官道隘口！」",
						function getResult( _ev ) { return "AidRefugees"; }
					});
				}
				if (::World.Assets.getMoney() >= 150)
				{
					this.Options.push({
						Text = "「给他们一百五十两安家银，细细问清前线敌军动向与山门告急消息。」",
						function getResult( _ev ) { return "BuyIntel"; }
					});
				}
				this.Options.push({
					Text = "「施舍些随身干粮指引前路，我们亦须赶赴战局。」",
					function getResult( _ev ) { return "QuickHelp"; }
				});

				local cr = ::Wuxia.Events.getActiveCrisis();
				local crDesc = "九州兵燹四起、大劫将临";
				if (cr == "undead") crDesc = "前朝玄宫尸傀破土成灾";
				else if (cr == "greenskins") crDesc = "南疆五毒与炼体药人大举犯境";
				else if (cr == "holywar") crDesc = "西域都护与北方藩镇万里征战";
				else if (cr == "civilwar") crDesc = "各路藩镇节度使挥师争霸";

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]官道尽头尘烟滚滚，" + crDesc + "，一大队衣衫褴褛、携老扶幼的逃难乡民与几名负伤的小派弟子正跌跌撞撞迎面而来。领头的老药农跪地求援：\n\n『恩公行行好！前头驿站已被乱兵邪祟焚毁，我们一路藏着几卷抢救出来的药图与敌情密报，只求些伤药与护持，熬过前面这段荒山！』";
			}
		});

		this.m.Screens.push({
			ID = "AidRefugees",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "但愿九州苍生早日重见太平。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_crisis", 1);
				::World.Flags.set("wx_chain_crisis_day", ::World.getTime().Days);
				::Wuxia.Events.addSupplies(0, -6, 0, this.List);
				::Wuxia.Events.addReputation(35, 16, this.List);
				::Wuxia.Events.giveItem("scripts/items/misc/wx_herb_heshouwu", this.List);
				::Wuxia.Events.addCompanyMood(0.75, "乱世援手扶危济困", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]你们分出伤药替老弱包扎，又一路护送难民穿过险隘。临别之际，那老药农硬将自己贴身藏着的一株百年何首乌塞进你们行囊，负伤的小派弟子更记下了贵社字号，誓言向抗劫同盟禀明义举！";
			}
		});

		this.m.Screens.push({
			ID = "BuyIntel",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收妥敌情与残卷，严阵以待！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_crisis", 1);
				::World.Flags.set("wx_chain_crisis_day", ::World.getTime().Days);
				::Wuxia.Events.addMoney(-150, this.List);
				::Wuxia.Events.addReputation(25, 8, this.List);
				::Wuxia.Events.givePage("sect", 1, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]一百五十两雪花纹银足以让这群逃难百姓在后方州城安身。那名小派弟子千恩万谢，不仅将沿途侦得的敌军兵力布防和盘托出，还将怀中抢救出的一张上乘武学残页拱手相赠！";
			}
		});

		this.m.Screens.push({
			ID = "QuickHelp",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "乱世多艰，各自珍重。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_crisis", 1);
				::World.Flags.set("wx_chain_crisis_day", ::World.getTime().Days);
				::Wuxia.Events.addReputation(15, 6, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]你们为难民指明了尚算安稳的近城小径，双方就此别过。听着远方传来的隐隐号角与烽烟消息，众弟兄深知这场席卷武林的大劫才刚刚开始。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Bro = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::World.Flags.getAsInt("wx_chain_crisis") != 0) return;
		local cr = ::Wuxia.Events.getActiveCrisis();
		if (cr == "" && ::World.getTime().Days < 55) return;

		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Score = (cr != "") ? 36 : 22;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.Bro = null; }
});
