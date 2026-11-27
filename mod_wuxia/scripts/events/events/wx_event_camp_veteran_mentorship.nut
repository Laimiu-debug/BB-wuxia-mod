// Camp Dynamic Mentorship Event: 篝火传功 · 宗师拆招指点新秀（队内拥有三重大成前辈时，夜间宿营指点低辈同袍精进武学火候）

this.wx_event_camp_veteran_mentorship <- this.inherit("scripts/events/event", {
	m = {
		Master   = null,
		Disciple = null
	},

	function create()
	{
		this.m.ID = "event.wx_camp_veteran_mentorship";
		this.m.Title = "篝火夜话传功";
		this.m.Cooldown = 20.0 * this.World.getTime().SecondsPerDay;

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
				if (::Wuxia.Events.isAlive(_event.m.Master)) this.Characters.push(_event.m.Master.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.Disciple)) this.Characters.push(_event.m.Disciple.getImagePath());

				local masterName = ::Wuxia.Events.fmtName(_event.m.Master);
				local discName = ::Wuxia.Events.fmtName(_event.m.Disciple);
				local masterArt = ::Wuxia.Events.pickManualName(_event.m.Master);
				local discArt = ::Wuxia.Events.pickManualName(_event.m.Disciple);

				this.Text = "[img]gfx/ui/events/wx_ev_04.png[/img]夜露渐浓，营盘外松涛轻响。新入行伍不久的 " + discName + " 仍借着篝火余光反复演练所修的" + discArt + "，只是每逢换气转势之际总滞涩半拍，额角汗珠直滚。\n\n早已将" + masterArt + "修至炉火纯青的 " + masterName + " 抱臂立于阴影中看了良久，忽然拾起一截枯枝缓步上前：\n\n『劲发于足、行于腰背而贯于指梢——你方才第三式强提丹田，未曾伤敌倒先自损三分内息。今夜既未入睡，是要老夫替你细细拆解行气关窍，还是索性下场真刀真枪喂上三十合，逼一逼你的生死潜能？』";

				this.Options = [
					{
						Text = "循序渐进，请前辈拆解招理、指点经脉行气关窍。",
						function getResult( _event ) { return "SteadyGuide"; }
					},
					{
						Text = "真传须经实战！放开手脚喂招三十合，在重压之下破境开窍！",
						function getResult( _event ) { return "HardSpar"; }
					},
					{
						Text = "明日尚需赶路迎敌，点到为止，早些歇息养神罢。",
						function getResult( _event ) { return "RestNow"; }
					}
				];
			}
		});

		this.m.Screens.push({
			ID = "SteadyGuide",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "名师一言，胜过闭门苦练数月。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.Master)) this.Characters.push(_event.m.Master.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.Disciple)) this.Characters.push(_event.m.Disciple.getImagePath());

				local masterName = ::Wuxia.Events.fmtName(_event.m.Master);
				local discName = ::Wuxia.Events.fmtName(_event.m.Disciple);

				::Wuxia.Events.addMastery(_event.m.Disciple, 110, this.List);
				::Wuxia.Events.addMood(_event.m.Disciple, 1.0, "得队内宗师前辈悉心指点武学", this.List);
				::Wuxia.Events.addMood(_event.m.Master, 0.5, "薪火相传指点后进同袍", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_04.png[/img]" + masterName + " 以枯枝代刃，一招一式引着 " + discName + " 体会吐纳换劲的微妙节点，连平日苦思不解的几处经脉滞塞也在三言两语间豁然贯通。\n\n收势吐出一口浊气时，" + discName + " 双目湛然有神，再出招时已多了几分沉稳老练的气度。";
			}
		});

		this.m.Screens.push({
			ID = "HardSpar",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "皮肉吃些苦头，手底真功夫却扎实多了！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.Master)) this.Characters.push(_event.m.Master.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.Disciple)) this.Characters.push(_event.m.Disciple.getImagePath());

				local masterName = ::Wuxia.Events.fmtName(_event.m.Master);
				local discName = ::Wuxia.Events.fmtName(_event.m.Disciple);

				::Wuxia.Events.addMastery(_event.m.Disciple, 165, this.List);
				::Wuxia.Events.addMastery(_event.m.Master, 45, this.List);
				::Wuxia.Events.applyLightHurt(_event.m.Disciple, 0.14, this.List);
				::Wuxia.Events.addMood(_event.m.Disciple, 0.75, "苦战喂招突破武学瓶颈", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_04.png[/img]篝火火星四溅，两道身影在空地上疾走交击！" + masterName + " 虽压了七分内劲，招式间凌厉无匹的破空劲风仍逼得 " + discName + " 险象环生、肩背连挨数记重拍。\n\n直到第廿九合绝境之下，" + discName + " 福至心灵变招卸力，竟硬生生接下收官一击！虽累得跌坐泥地浑身青紫，体内真气运转却比先前快了何止一筹，连 " + masterName + " 亦不禁抚掌微笑。";
			}
		});

		this.m.Screens.push({
			ID = "RestNow",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "留得青山在，来日切磋不迟。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.Master)) this.Characters.push(_event.m.Master.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.Disciple)) this.Characters.push(_event.m.Disciple.getImagePath());

				::Wuxia.Events.addMastery(_event.m.Disciple, 35, this.List);
				::Wuxia.Events.addCompanyMood(0.25, "篝火夜歇精神饱满", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_04.png[/img]前辈只随口点拨了两句吐纳收功的口诀，便催促众人各自归帐安歇。一夜好眠，次日拔营启程时全队神完气足。";
			}
		});
	}

	function wxFindMasterAndDisciple()
	{
		local masters = [];
		local disciples = [];
		foreach (bro in ::Wuxia.Events.getAliveBros())
		{
			local c = ::Wuxia.Slots.getContainer(bro);
			if (c == null) continue;
			local hasTier3 = false;
			local hasGrowing = false;
			foreach (s in c.m.Slots)
			{
				if (s.ManualID == null || s.Tier <= 0 || s.IsFragment) continue;
				if (s.Tier >= 3) hasTier3 = true;
				else if (s.Tier < 3) hasGrowing = true;
			}
			if (bro.getLevel() >= 5 && hasTier3) masters.push(bro);
			if (bro.getLevel() <= 6 && hasGrowing) disciples.push(bro);
		}
		if (masters.len() == 0 || disciples.len() == 0) return null;
		local mBro = masters[::Math.rand(0, masters.len() - 1)];
		local validD = [];
		foreach (dBro in disciples)
		{
			if (dBro.getID() != mBro.getID()) validD.push(dBro);
		}
		if (validD.len() == 0) return null;
		return {
			Master   = mBro,
			Disciple = validD[::Math.rand(0, validD.len() - 1)]
		};
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		this.m.Master = null;
		this.m.Disciple = null;

		local pair = this.wxFindMasterAndDisciple();
		if (pair == null) return;

		this.m.Master = pair.Master;
		this.m.Disciple = pair.Disciple;
		this.m.Score = ::Wuxia.Events.isNight() ? 22 : 15;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.Master) || !::Wuxia.Events.isAlive(this.m.Disciple))
		{
			local pair = this.wxFindMasterAndDisciple();
			if (pair != null)
			{
				this.m.Master = pair.Master;
				this.m.Disciple = pair.Disciple;
			}
			else
			{
				this.m.Master = ::Wuxia.Events.findVeteranBro(4);
				if (this.m.Master == null) this.m.Master = ::Wuxia.Events.findRandomBro();
				this.m.Disciple = ::Wuxia.Events.findRookieBro(6, this.m.Master);
				if (this.m.Disciple == null) this.m.Disciple = ::Wuxia.Events.findRandomBro(this.m.Master);
			}
		}
	}

	function onPrepareVariables( _vars )
	{
		_vars.push(["master", ::Wuxia.Events.shortName(this.m.Master)]);
		_vars.push(["disciple", ::Wuxia.Events.shortName(this.m.Disciple)]);
	}

	function onClear()
	{
		this.m.Master = null;
		this.m.Disciple = null;
	}
});
