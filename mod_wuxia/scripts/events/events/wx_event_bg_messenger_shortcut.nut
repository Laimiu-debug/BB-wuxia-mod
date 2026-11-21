// Batch E2 Event 18: 旧驿密道（急脚驿使/货郎/漂泊客识得绕过塌方的旧驿暗道与废弃干爽地窖）

this.wx_event_bg_messenger_shortcut <- this.inherit("scripts/events/event", {
	m = {
		Guide = null
	},

	function create()
	{
		this.m.ID = "event.wx_bg_messenger_shortcut";
		this.m.Title = "旧驿密道";
		this.m.Cooldown = 35.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "「就信你一回！全队轻装上坡，抄旧驿密道！」",
					function getResult( _event ) { return "TakeShortcut"; }
				},
				{
					Text = "「荒山小径容易撞见埋伏，老实踩官道泥浆绕过去。」",
					function getResult( _event ) { return "MudRoad"; }
				}
			],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Guide;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "那名熟路的弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_28.png[/img]连日苦雨把官道泡成了没过脚踝的红泥汤，前头峡口又滑下几丈宽的塌方，折断的松树和乱石把大路堵得严严实实。众人正骂着娘准备拆车扛货，" + bName + " 却吐掉嘴里叼着的草茎，抬手指向残破界碑后一条被葛藤遮掩的青石骡道：\n\n『别往泥潭里喂蚂蟥了！前朝急脚递在山腰凿过一条备用的旧驿密道，能直接绕开这段塌方。转过山嘴还有个藏在涵洞里的干爽地窖，往年驿卒总在里头屯些防潮伤药和腊鱼干粮，说不定还能捡个现成！』";
			}
		});

		this.m.Screens.push({
			ID = "TakeShortcut",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "有熟路人在队里真省大事！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Guide;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "熟路弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addSupplies(0, 10, 0, this.List);
				::Wuxia.Events.giveFood("scripts/items/supplies/dried_fish_item", "驿站腊鱼干粮", this.List);
				::Wuxia.Events.addCompanyMood(0.75, "抄近道免涉泥潭，还得了旧驿存货", this.List);
				::Wuxia.Events.addStat(bro, "Initiative", 1, "身法", "ui/icons/initiative.png", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_28.png[/img]" + bName + " 提刀开路，领着队伍单列贴崖而行。青石小道虽然窄得只容一骡通过，路面却顺着山势排尽了积水，脚下竟干爽得很。\n\n转过山梁，果真在野藤后面寻见那座木板护壁的旧驿地窖。虽已荒废多时，窖内仍留着两捆包扎严实的荷叶腊鱼与几罐封腊完好的金疮草药。弟兄们烤火烤干了袜子，个个赞不绝口，" + bName + " 这一趟翻崖探路下来，步履也越发轻快利索。";
			}
		});

		this.m.Screens.push({
			ID = "MudRoad",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "湿就湿吧，命还在要紧。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Guide;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addCompanyMood(-0.35, "泥道绕行半日，靴袜尽湿", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_28.png[/img]野道窄崖最易遭滚石埋伏，你思忖片刻还是决定走官道绕行。整整半日功夫，全队人推车拽骡深一脚浅一脚踩过烂泥滩，虽未撞上贼寇，入夜歇脚时人人腿肚子上都糊着三斤黄泥，连骂人的力气都没剩多少。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Guide = null;
		if (!::Wuxia.Events.isWorldReady()) return;

		local bro = ::Wuxia.Events.findByBackgrounds([
			"background.messenger",
			"background.peddler",
			"background.vagabond"
		]);
		if (bro == null) return;

		this.m.Guide = bro;
		this.m.Score = 16;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Guide = null;
	}
});
