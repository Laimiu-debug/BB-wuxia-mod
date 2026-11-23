// Sequential Jianghu Event Chain 2 (Stage 3/3): 无名老丐传艺 · 月夜演武
this.wx_event_chain_beggar_3 <- this.inherit("scripts/events/event", {
	m = {
		Champ = null
	},

	function create()
	{
		this.m.ID = "event.wx_chain_beggar_3";
		this.m.Title = "无名老丐（终）· 九指传艺";
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
				local bro = _event.m.Champ;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "队中高手";
				local sName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.shortName(bro) : "高手";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Options.push({
					Text = "「请前辈单独指点 " + sName + " 一夜拆招，助其破境！」",
					function getResult( _ev ) { return "SingleMaster"; }
				});
				this.Options.push({
					Text = "「请前辈在篝火前向全队讲授行气步法，令众弟兄同受教益！」",
					function getResult( _ev ) { return "WholeCompany"; }
				});

				this.Text = "[img]gfx/ui/events/wx_ev_25.png[/img]皓月当空，那位衣衫破旧的九指老丐如约踏露步入营地。只见他随手折下一截枯松枝，凌空轻点三下，竟震得十步外碗口粗的老松簌簌落雪——赫然正是退隐江湖二十载的前代丐帮传功宗师「九指神丐」！\n\n老宗师拂须含笑：『一饭之恩、渡口之义，老夫岂敢忘怀？今夜天明之前，是让老夫亲自替 " + bName + " 喂招拔高，还是给你们全队演练一堂行气总纲，由你这当家的来定！』";
			}
		});

		this.m.Screens.push({
			ID = "SingleMaster",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "拜谢九指前辈大恩！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Champ;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::World.Flags.set("wx_chain_beggar", 3);
				::Wuxia.Events.addMastery(bro, 220, this.List);
				::Wuxia.Events.addStat(bro, "Bravery", 2, "定力", "ui/icons/bravery.png", this.List);
				::Wuxia.Events.addStat(bro, "Initiative", 2, "身法", "ui/icons/initiative.png", this.List);
				::Wuxia.Events.givePill("wx_pill_ningshen", this.List);
				::Wuxia.Events.addSectRel("gaibang", 15, this.List);
				::Wuxia.Events.addReputation(50, 0, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_25.png[/img]竹影翻飞、掌风激荡，老宗师整整喂招三个时辰，将发劲转折、呼吸吐纳的关窍尽数点破！待东方既白，老丐早已乘风而去，唯留 " + ::Wuxia.Events.fmtName(bro) + " 满身大汗却双目炯炯，武学火候与临阵身法皆脱胎换骨！";
			}
		});

		this.m.Screens.push({
			ID = "WholeCompany",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "全队铭记前辈教诲！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_beggar", 3);
				::Wuxia.Events.addCompanyMastery(90, this.List);
				::Wuxia.Events.givePage("sect", 1, this.List, "gaibang");
				::Wuxia.Events.givePill("wx_pill_ningshen", this.List);
				::Wuxia.Events.addSectRel("gaibang", 15, this.List);
				::Wuxia.Events.addCompanyMood(1.25, "蒙隐世宗师月夜传艺，士气大振", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_25.png[/img]老宗师盘坐篝火之畔，由浅入深拆解天下武学共通的换气、借力与合击步法，临别更留下一张亲笔批注的丐帮上乘残页。晨光映照下，全队上下人人如醍醐灌顶、武意勃发！";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Champ = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::World.Flags.getAsInt("wx_chain_beggar") != 2) return;
		local lastDay = ::World.Flags.getAsInt("wx_chain_beggar_day");
		if (::World.getTime().Days < lastDay + 12) return;

		// Pick highest-level alive brother as primary disciple
		local best = null;
		foreach (bro in ::Wuxia.Events.getAliveBros())
		{
			if (best == null || bro.getLevel() > best.getLevel())
				best = bro;
		}
		if (best == null) return;
		this.m.Champ = best;
		this.m.Score = 34;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.Champ = null; }
});
