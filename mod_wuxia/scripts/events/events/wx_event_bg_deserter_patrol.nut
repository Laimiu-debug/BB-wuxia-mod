// Batch E2 Event 22: 旧营逃卒（卫所巡哨路卡设障，眯眼盯上队中旧逃卒/亡命客/苦役）

this.wx_event_bg_deserter_patrol <- this.inherit("scripts/events/event", {
	m = {
		WantedBro = null,
		BluffBro  = null
	},

	function create()
	{
		this.m.ID = "event.wx_bg_deserter_patrol";
		this.m.Title = "旧营逃卒";
		this.m.Cooldown = 42.0 * this.World.getTime().SecondsPerDay;

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

				local wanted = _event.m.WantedBro;
				local bluffer = _event.m.BluffBro;
				local wName = ::Wuxia.Events.isAlive(wanted) ? ::Wuxia.Events.fmtName(wanted) : "那名弟兄";

				if (::Wuxia.Events.isAlive(wanted)) this.Characters.push(wanted.getImagePath());
				if (::Wuxia.Events.isAlive(bluffer)) this.Characters.push(bluffer.getImagePath());

				if (::World.Assets.getMoney() >= 200)
				{
					this.Options.push({
						Text = "「军爷看走眼了，这二百两茶水钱给弟兄们润润嗓子，抬杆放行吧。」",
						function getResult( _ev ) { return "Bribe"; }
					});
				}

				if (::Wuxia.Events.isAlive(bluffer))
				{
					this.Options.push({
						Text = "「让 " + ::Wuxia.Events.shortName(bluffer) + " 上前摆出官面派头，把这帮卫所丘八唬住！」",
						function getResult( _ev ) { return "Bluff"; }
					});
				}

				this.Options.push({
					Text = "全队齐刷刷按住刀柄逼上前去：「军爷，你再仔细瞧瞧像不像？」",
					function getResult( _ev ) { return "DrawSteel"; }
				});

				this.Text = "[img]gfx/ui/events/wx_ev_26.png[/img]官道石桥头横着一排削尖的拒马木障，六名身穿旧棉甲的州府巡卒斜扛长枪拦住去路。领头的麻脸什长抖开一张发黄的木刻海捕文书，眯缝着三角眼从队列里一路扫过去，目光骤然死死钉在了 " + wName + " 脸上。\n\n" + wName + " 呼吸微微一窒，右手悄悄往衣领处挪去，似要遮住颈侧旧疤。麻脸什长冷笑两声，枪杆一横：『慢着！后头那个缩着脖子的，怎么越瞧越像前年在卫所溜号、官府挂红的那个杂种？把斗笠摘了，跟老子进卡棚细验！』";
			}
		});

		this.m.Screens.push({
			ID = "Bribe",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "破财免灾，速过石桥。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local wanted = _event.m.WantedBro;
				local wName = ::Wuxia.Events.isAlive(wanted) ? ::Wuxia.Events.fmtName(wanted) : "弟兄";
				if (::Wuxia.Events.isAlive(wanted)) this.Characters.push(wanted.getImagePath());

				::Wuxia.Events.addMoney(-200, this.List);
				::Wuxia.Events.addMood(wanted, 0.75, "主事花钱消灾，免陷官狱", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_26.png[/img]你满脸堆笑迎上前，借着拱手的功夫将一卷沉甸甸的麻布银筒顺进什长袖口。那麻脸军汉手腕微沉，拇指隔着布角一捏便知分量十足，脸上横肉立时松弛下来。\n\n『嗯……今日天阴日头暗，老子一时眼拙，把你家老伙计认成逃犯了！』他飞快收起海捕纸，挥手叫兵丁移开拒马木桩。过了桥头，" + wName + " 长长吐出一口浊气，朝你郑重抱了抱拳。";
			}
		});

		this.m.Screens.push({
			ID = "Bluff",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "大摇大摆过卡！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local wanted = _event.m.WantedBro;
				local bluffer = _event.m.BluffBro;
				local wName = ::Wuxia.Events.isAlive(wanted) ? ::Wuxia.Events.fmtName(wanted) : "弟兄";
				local bName = ::Wuxia.Events.isAlive(bluffer) ? ::Wuxia.Events.fmtName(bluffer) : "老手";

				if (::Wuxia.Events.isAlive(wanted)) this.Characters.push(wanted.getImagePath());
				if (::Wuxia.Events.isAlive(bluffer)) this.Characters.push(bluffer.getImagePath());

				::Wuxia.Events.addCompanyMood(1.0, "官腔压阵，分文未花震退路卡", this.List);
				::Wuxia.Events.addStat(wanted, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
				::Wuxia.Events.addMood(bluffer, 1.0, "旧日威势犹在，唬住卫所巡卒", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_26.png[/img]不等你开口，" + bName + " 已大步踏前，反手推开拦路枪杆，沉声喝出两句边军旧日口令与本省都司衙门的堂官讳号，随即冷着脸反问：『哪个卫所的狗胆，敢拦办差私镖？耽搁了上头急务，你这颗顶戴够砍几回？』\n\n麻脸什长听得口令门儿清，又见对方气度森严，顿时慌了神，哪还顾得上细瞧 " + wName + "，忙不迭收起告示躬身移开木障，目送你们扬长而去。走出半里地，全队人终于憋不住齐声大笑起来。";
			}
		});

		this.m.Screens.push({
			ID = "DrawSteel",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "江湖儿女，岂能把弟兄拱手送官！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local wanted = _event.m.WantedBro;
				local wName = ::Wuxia.Events.isAlive(wanted) ? ::Wuxia.Events.fmtName(wanted) : "弟兄";
				if (::Wuxia.Events.isAlive(wanted)) this.Characters.push(wanted.getImagePath());

				::Wuxia.Events.addCompanyMood(0.75, "齐心亮刃护袍泽，胆气豪壮", this.List);
				::Wuxia.Events.addStat(wanted, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
				::Wuxia.Events.addMood(wanted, 1.25, "主事宁抗官差亦不弃我", this.List);

				local repText = "";
				if (::Math.rand(1, 100) <= 45)
				{
					::Wuxia.Events.addReputation(-10, -3, this.List);
					repText = "只是这帮丘八回头免不了去州府嚼舌根，说你们是群目无王法的悍匪。";
				}
				else
				{
					repText = "那麻脸什长生怕吃官司担责，灰溜溜把这茬吞进了肚里，竟没敢上报。";
				}

				this.Text = "[img]gfx/ui/events/wx_ev_26.png[/img]「锵啷！」数口久经血战的钢刀齐齐拔出半寸，凛冽杀气顺着桥风扑面而来。" + wName + " 索性抬起头不再躲闪，冷冷盯着什长咽喉。\n\n六个巡卒拿的不过是每月几斗陈米的死饷，哪肯真拿命跟你们这群满身伤疤的狠人硬拼？众人互相递了个眼色，默不作声退到了桥栏边，眼睁睁看着你们踢开拒马扬长过桥。" + repText;
			}
		});
	}

	function onUpdateScore()
	{
		this.m.WantedBro = null;
		this.m.BluffBro = null;
		if (!::Wuxia.Events.isWorldReady()) return;

		local wanted = ::Wuxia.Events.findByBackgrounds([
			"background.deserter",
			"background.killer_on_the_run",
			"background.slave"
		]);
		if (wanted == null) return;

		local bluffer = ::Wuxia.Events.findByBackgrounds([
			"background.retired_soldier",
			"background.kings_guard",
			"background.adventurous_noble",
			"background.manhunter"
		], wanted);

		this.m.WantedBro = wanted;
		this.m.BluffBro = bluffer;
		this.m.Score = 15;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.WantedBro = null;
		this.m.BluffBro = null;
	}
});
