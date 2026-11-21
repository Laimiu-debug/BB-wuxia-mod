// Batch E2 Event 23: 深宅密闻（内侍/大宅家仆/掮客/逐门子弟认出豪门暗车徽记，道破一桩丑闻）

this.wx_event_bg_eunuch_rumor <- this.inherit("scripts/events/event", {
	m = {
		Insider = null,
		SectID  = "weiyuan"
	},

	function create()
	{
		this.m.ID = "event.wx_bg_eunuch_rumor";
		this.m.Title = "深宅密闻";
		this.m.Cooldown = 44.0 * this.World.getTime().SecondsPerDay;

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

				local bro = _event.m.Insider;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "那名熟谙内情的弟兄";
				local sName = (_event.m.SectID in ::Wuxia.Config.Sects) ? ::Wuxia.Config.Sects[_event.m.SectID].Name : "威远总镖局";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Options.push({
					Text = "「这种高门腌臜秘辛正值钱，进镇寻茶楼牙人悄悄卖个好价。」",
					function getResult( _ev ) { return "SellTip"; }
				});
				this.Options.push({
					Text = "「莫卖给小人，暗中把车驾行踪报与当地【" + sName + "】。」",
					function getResult( _ev ) { return "TipSect"; }
				});
				this.Options.push({
					Text = "「高门深宅的是非沾一身腥，管紧嘴巴，权当什么也没瞧见。」",
					function getResult( _ev ) { return "KeepQuiet"; }
				});

				this.Text = "[img]gfx/ui/events/wx_ev_28.png[/img]一辆枣红漆面的双骡暗车卷着烟尘疾驰而过，车厢垂着厚实的杭州绛绸帘，四名随行健仆虽穿素布青衣，袖口却个个沉甸甸藏着短铁尺。车轮刚滚出十丈，" + bName + " 便盯着车檐下那盏刻着双蝠暗纹的铜灯，喉咙里滚出一声阴恻恻的干笑：\n\n『哟呵，这不是盐运分司三房私底下往外走的暗车么？方才风掀开帘角，车里那只翠玉扳指可不是他家老太爷的物件——早听说城里某位大族管事勾连黑道倒腾官盐和门派密折，今儿算是亲眼撞破了。头儿，这桩丑闻捏在手里，您打算怎么发落？』";
			}
		});

		this.m.Screens.push({
			ID = "SellTip",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "银子到手，闭口莫言。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Insider;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(280, this.List);
				::Wuxia.Events.addMood(bro, 0.75, "旧日门路换得现银", this.List);
				::Wuxia.Events.addReputation(0, -2, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_28.png[/img]入夜后，" + bName + " 带着你钻进城南茶楼最偏僻的隔间，只报出两个私印记号、三个人名外加车马出城的时辰。对面那位留着山羊胡的江湖牙人听完轻轻吹了声口哨，连茶都没顾上续，当场从袖中摸出二百八十两白银推过桌面：\n\n『好货！这消息搁在几位大爷政敌手里，值十倍价钱。今日之事出你之口入我之耳，天知地知。』";
			}
		});

		this.m.Screens.push({
			ID = "TipSect",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "正道门派果然出手大方。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Insider;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "弟兄";
				local sName = (_event.m.SectID in ::Wuxia.Config.Sects) ? ::Wuxia.Config.Sects[_event.m.SectID].Name : "威远总镖局";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addSectRel(_event.m.SectID, 18, this.List);
				::Wuxia.Events.givePill("wx_pill_ningshen", this.List);
				::Wuxia.Events.addReputation(0, 3, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_28.png[/img]你叫 " + bName + " 将车徽纹样与落脚客栈细细画在纸上，悄悄交与当地【" + sName + "】外堂执事。不过两日功夫，一名青衣信使便快马追至你们营前，递上一封火漆谢函与一只温润小玉瓶：\n\n『多亏诸位及时示警，敝派已截下那批勾结匪寨的密信与脏货。一点薄礼，权表敬意，日后诸位路过敝派地界自有照应！』";
			}
		});

		this.m.Screens.push({
			ID = "KeepQuiet",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "知道得越少，睡得越安稳。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Insider;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMood(bro, 0.75, "明哲保身，心头安稳", this.List);
				::Wuxia.Events.addCompanyMood(0.5, "远离豪门是非，安稳赶路", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_28.png[/img]" + bName + " 听罢微微点头，眼底反倒多了几分佩服：『头儿是个明白人。高门深院里淹死的从来不是瞎子，而是眼太尖、嘴太碎的聪明人。』众人拍拍尘土继续赶路，当夜连守夜的弟兄都睡得格外踏实。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Insider = null;
		this.m.SectID = "weiyuan";
		if (!::Wuxia.Events.isWorldReady()) return;

		local bro = ::Wuxia.Events.findByBackgrounds([
			"background.eunuch",
			"background.servant",
			"background.pimp",
			"background.disowned_noble"
		]);
		if (bro == null) return;

		local sid = ::Wuxia.Events.pickLocalSect("righteous");
		this.m.Insider = bro;
		this.m.SectID = sid;
		this.m.Score = 14;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Insider = null;
		this.m.SectID = "weiyuan";
	}
});
