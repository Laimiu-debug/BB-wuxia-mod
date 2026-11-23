// Sequential Jianghu Event Chain 1 (Stage 3/3): 残卷血案 · 剑宗寻踪
this.wx_event_chain_scroll_3 <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_chain_scroll_3";
		this.m.Title = "残卷血案（终）· 完璧归宗";
		this.m.Cooldown = 999.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "「原卷完璧归赵！只求太和玄门记住我等一份江湖情义。」",
					function getResult( _ev ) { return "ReturnToSect"; }
				},
				{
					Text = "「血战才护下来的奇谱，自当由我们留存参悟！」",
					function getResult( _ev ) { return "KeepCodex"; }
				}
			],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_07.png[/img]连日参详之下，那封血印残卷中的隐墨经脉终于被烘烤显形，赫然是一部极精妙的名门真传全谱！恰在此时，营外松林中缓步走来一位须发皆白的太和玄门传功长老，稽首长叹：\n\n『那晚遇害的乃是老朽门下最忠义的弟子。多谢诸位冒死护住本门遗失的秘谱！若肯完璧归还，太和山门必奉上厚银灵药，视贵社为生死之交；若诸位执意留阅，老朽亦不愿与恩人动武，唯有一声长叹罢了。』";
			}
		});

		this.m.Screens.push({
			ID = "ReturnToSect",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "江湖路远，后会有期！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_scroll", 4);
				::Wuxia.Events.addSectRel("taihe", 25, this.List);
				::Wuxia.Events.addMoney(1000, this.List);
				::Wuxia.Events.addReputation(80, 20, this.List);
				::Wuxia.Events.giveItem("scripts/items/misc/wx_marrow_herb", this.List);
				::Wuxia.Events.addCompanyMood(1.0, "完璧归宗，博得名门盛赞", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_07.png[/img]你双手奉还血封原卷，白发长老动容良久，当场奉上一千两谢仪、一株珍藏的太和洗髓灵草与太和玄门贵宾玉佩。一桩牵连数月的残卷血案至此尘埃落定，你们的侠义之名传遍武林！";
			}
		});

		this.m.Screens.push({
			ID = "KeepCodex",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "既得全本真传，即刻收入藏经阁！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_scroll", 4);
				::Wuxia.Events.giveManual("sect", this.List, "taihe");
				::Wuxia.Events.givePage("secret", 1, this.List);
				::Wuxia.Events.addCompanyMastery(80, this.List);
				::Wuxia.Events.addSectRel("taihe", -8, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_07.png[/img]白发长老默然注视你们良久，最终微微摇头，收剑转身消失在山雾之中。营火旁，众弟兄连夜将显形的完整功谱与绝学残页细细抄录归档，全队武学感悟大进！";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Bro = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::World.Flags.getAsInt("wx_chain_scroll") != 3) return;
		local lastDay = ::World.Flags.getAsInt("wx_chain_scroll_day");
		if (::World.getTime().Days < lastDay + 10) return;

		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Score = 32;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.Bro = null; }
});
