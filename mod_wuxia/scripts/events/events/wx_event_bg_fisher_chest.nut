// Batch E2 Event 16: 沉江铁匣（渔夫/短工在废弃渡口沉桩下发现铅封铁匣）

this.wx_event_bg_fisher_chest <- this.inherit("scripts/events/event", {
	m = {
		Fisher     = null,
		TargetSect = "weiyuan"
	},

	function create()
	{
		this.m.ID = "event.wx_bg_fisher_chest";
		this.m.Title = "沉江铁匣";
		this.m.Cooldown = 40.0 * this.World.getTime().SecondsPerDay;

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

				local bro = _event.m.Fisher;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "那名熟水性的弟兄";
				local sName = (_event.m.TargetSect in ::Wuxia.Config.Sects) ? ::Wuxia.Config.Sects[_event.m.TargetSect].Name : "威远总镖局";

				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Options.push({
					Text = "「下水捞上来，砸开铅封看看里头是银子还是秘本！」",
					function getResult( _ev ) { return "PryOpen"; }
				});
				this.Options.push({
					Text = "「匣上刻着【" + sName + "】的暗记，原封送还联络人，换份稳当人情。」",
					function getResult( _ev ) { return "DeliverSealed"; }
				});
				this.Options.push({
					Text = "「江底沉铁多沾水鬼晦气，莫去惊动，赶路！」",
					function getResult( _ev ) { return "LeaveIt"; }
				});

				this.Text = "[img]gfx/ui/events/wx_ev_29.png[/img]枯水时节，一座废弃多年的旧渡口露出成排黑烂的木桩，像半截朽坏的兽肋插在黄泥滩里。众人牵骡饮水之际，" + bName + " 却蹲在岸石上死死盯着一处打旋的水花，压低嗓门道：『头儿，水势不对，烂桩底下卡着件沉铁家伙！』\n\n拿长枪挑开腐朽苇草，借着浑水隐约可见一只巴掌厚、爬满江螺青苔的铅封铁匣，棱角处隐隐压着【" + sName + "】的旧日水火暗印——也不知是哪年翻船沉江的红货，还是黑吃黑后留下的脏物。";
			}
		});

		this.m.Screens.push({
			ID = "PryOpen",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "拭干水渍，收入行囊。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Fisher;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(240, this.List);
				::Wuxia.Events.givePage("sect", 1, this.List);

				local chillText = "";
				if (::Math.rand(1, 100) <= 45)
				{
					::Wuxia.Events.addMood(bro, -0.75, "寒江浸水，浑身发冷", this.List);
					chillText = "只是江水刺骨，" + bName + " 爬上岸时嘴唇冻得发紫，连打三个喷嚏，裹了两件干棉袄才缓过神来。";
				}
				else
				{
					::Wuxia.Events.addMood(bro, 0.75, "捞获沉江暗财", this.List);
					chillText = bName + " 甩干发梢泥水，掂着湿漉漉的银锭乐得直搓手。";
				}

				this.Text = "[img]gfx/ui/events/wx_ev_29.png[/img]" + bName + " 脱去外袍咬着短刀扎进回水涡，拴上麻绳连拽带撬，费了九牛二虎之力才把那只沉甸甸的铁匣拖上沙洲。铁凿几锤砸崩锈锁，匣内厚厚的桐油蜡纸竟还护得严实——里头整整齐齐码着发黑的散碎银锭，夹层里更压着一卷微潮的门派武学残页！\n\n" + chillText;
			}
		});

		this.m.Screens.push({
			ID = "DeliverSealed",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "山水相逢，这份人情记下了。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Fisher;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "弟兄";
				local sName = (_event.m.TargetSect in ::Wuxia.Config.Sects) ? ::Wuxia.Config.Sects[_event.m.TargetSect].Name : "威远总镖局";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addSectRel(_event.m.TargetSect, 18, this.List);
				::Wuxia.Events.addMoney(150, this.List);
				::Wuxia.Events.addMood(bro, 0.5, "顺水送出好人情", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_29.png[/img]" + bName + " 小心翼翼将铁匣起出水面，未动分毫铅封。行至前方水驿茶棚，你托船老大递了句口信，不消半日，便有两名【" + sName + "】的干练管事披蓑赶来。\n\n见匣口蜡印完好如初，领头管事紧锁的眉头顿时舒展开来，郑重抱拳道：『诸位路见遗珍而不贪，这份讲究敝派铭记在心！』当即奉上一百五十两酬银与一枚通行木牌。";
			}
		});

		this.m.Screens.push({
			ID = "LeaveIt",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "离渡口远些再歇脚。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Fisher;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMood(bro, 0.5, "避开水煞晦气", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_29.png[/img]『沉江的铁匣多半压着人命冤债，捞上来怕招惹水底不干净的东西。』" + bName + " 朝浅滩啐了一口辟邪，收起枪杆。一阵河风吹过，黄浪翻卷，很快便把那抹铁影重新吞没在浑水之下。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Fisher = null;
		this.m.TargetSect = "weiyuan";
		if (!::Wuxia.Events.isWorldReady()) return;

		local bro = ::Wuxia.Events.findByBackgrounds([
			"background.fisherman",
			"background.daytaler",
			"background.vagabond"
		]);
		if (bro == null) return;

		local sectID = ::Math.rand(0, 1) == 0 ? "weiyuan" : "dongting_shuizhai";
		if (!(sectID in ::Wuxia.Config.Sects)) sectID = "weiyuan";

		this.m.Fisher = bro;
		this.m.TargetSect = sectID;
		this.m.Score = 15;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Fisher = null;
		this.m.TargetSect = "weiyuan";
	}
});
