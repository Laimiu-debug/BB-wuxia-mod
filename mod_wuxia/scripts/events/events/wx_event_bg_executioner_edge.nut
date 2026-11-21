// Batch E2 Event 15: 刑场磨刀客（行刑手/亡命客独坐磨刀，新丁窃窃私语）

this.wx_event_bg_executioner_edge <- this.inherit("scripts/events/event", {
	m = {
		BladeBro = null,
		Watcher  = null
	},

	function create()
	{
		this.m.ID = "event.wx_bg_executioner_edge";
		this.m.Title = "刑场磨刀客";
		this.m.Cooldown = 34.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "拎一坛烈酒走过去，坐在石墩旁陪他喝上两碗。",
					function getResult( _event ) { return "ShareWine"; }
				},
				{
					Text = "「藏着掖着作甚？叫弟兄们围过来，教两手最利落的断骨落刀法！」",
					function getResult( _event ) { return "ShowAngles"; }
				},
				{
					Text = "由他自个儿静静磨刀，不必多管。",
					function getResult( _event ) { return "LeaveAlone"; }
				}
			],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.BladeBro;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "那名刀客";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_30.png[/img]「嚓——嗤。嚓——嗤。」\n\n夜雾沉沉，火堆旁本该热闹划拳，几个新入伙的年轻人却缩着脖子压低了嗓门。离火光十步远的青石墩上，" + bName + " 独个儿蹲着，脚边放一碗浑水，双手稳稳压着沉甸甸的厚背刃在青砺石上来回推磨。他动作不急不躁，偶有铁屑沾手便随口吹落，再用拇指肚轻轻试过刃口，仿佛磨的不是杀人的钢刀，而是切瓜的菜刃。\n\n有人小声嘀咕起菜市口秋后问斩的旧闻，也有人偷偷瞥向他袖口洗不净的暗褐旧渍。" + bName + " 似有所觉，却连眼皮都没抬一下。";
			}
		});

		this.m.Screens.push({
			ID = "ShareWine",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "干了碗底这口，回营歇息。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.BladeBro;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "刀客";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addStat(bro, "Bravery", 2, "定力", "ui/icons/bravery.png", this.List);
				::Wuxia.Events.addMood(bro, 1.5, "得主事对饮相知", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_30.png[/img]你拎着一坛烧刀子坐到湿冷的草地上，也没问他早年砍过多少颗脑袋，只把满碗烈酒推到砺石边上。\n\n" + bName + " 愣了片刻，擦干手上的铁泥接过碗一饮而尽，喉结滚了两下，沙哑笑道：『旁人见我不是躲着走，便是当我是阎王殿里跑出来的屠狗辈。其实世道烂成这样，利利索索一刀给个痛快，反倒是天大的慈悲。』两碗烈酒落肚，他脊背挺得更直，眼底那股沉郁孤冷也散了不少。";
			}
		});

		this.m.Screens.push({
			ID = "ShowAngles",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "活命的本事从来都不体面。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.BladeBro;
				local watcher = _event.m.Watcher;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "刀客";
				local wName = ::Wuxia.Events.isAlive(watcher) ? ::Wuxia.Events.fmtName(watcher) : "年轻弟兄";

				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				if (::Wuxia.Events.isAlive(watcher)) this.Characters.push(watcher.getImagePath());

				::Wuxia.Events.addCompanyMastery(40, this.List);
				::Wuxia.Events.addMood(bro, 0.75, "压箱底的刀法有人受教", this.List);
				if (::Wuxia.Events.isAlive(watcher))
					::Wuxia.Events.addMood(watcher, -0.75, "听闻断骨落刃之术，心下发寒", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_30.png[/img]" + bName + " 拖过一段碗口粗的湿柳木立在火前，语声平淡得像私塾先生讲书：『砍人最忌猛劈卡骨。肩窝锁骨往里三寸，甲片必有缝隙；下刃前手腕微扣半寸，顺着骨缝滑进去，一分力能劈出三分狠劲。』话音未落，寒光斜掠，湿木齐根裂开两半，切口光洁如镜。\n\n几个老卒频频点头，暗自记下这手凶狠窍门；站在一旁的 " + wName + " 却听得脸色发白，端着肉粥碗半天没咽下一口。";
			}
		});

		this.m.Screens.push({
			ID = "LeaveAlone",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "各安其分。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.BladeBro;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "刀客";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMastery(bro, 25, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_30.png[/img]有些人的心事只肯说给磨刀石听。你摆手止住新丁们的窃窃私语，任由 " + bName + " 守着孤灯磨到三更。次日拔营时，他背上那口钢刃已冷得照得出人影。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.BladeBro = null;
		this.m.Watcher = null;
		if (!::Wuxia.Events.isWorldReady()) return;

		local bro = ::Wuxia.Events.findByBackgrounds([
			"background.executioner",
			"background.killer_on_the_run"
		]);
		if (bro == null) return;

		local watcher = ::Wuxia.Events.findRookieBro(4, bro);
		if (watcher == null) watcher = ::Wuxia.Events.findRandomBro(bro);

		this.m.BladeBro = bro;
		this.m.Watcher = watcher;
		this.m.Score = 15;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.BladeBro = null;
		this.m.Watcher = null;
	}
});
