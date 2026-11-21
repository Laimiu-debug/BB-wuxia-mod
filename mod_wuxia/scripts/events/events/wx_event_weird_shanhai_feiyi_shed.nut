// Strange-Tales Event 53: 赤旱焦谷·肥遗蜕鳞（山海异兽蜕鳞奇遇）

this.wx_event_weird_shanhai_feiyi_shed <- this.inherit("scripts/events/event", {
	m = {
		Expert = null,
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_weird_shanhai_feiyi_shed";
		this.m.Title = "赤旱焦谷·肥遗蜕鳞";
		this.m.Cooldown = 36.0 * this.World.getTime().SecondsPerDay;

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

				local exp = _event.m.Expert;
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(exp)) this.Characters.push(exp.getImagePath());
				else if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_23.png[/img]转过一道乱石赤崖，山谷里的溪床竟龟裂如焦炭，枯死的野草根部还冒着淡淡硫磺白烟。前方半干的泥洼里，一道丈余宽的拖痕蜿蜒通向绝壁深涧，沿途散落着十几片碗口大小的赤黑重鳞，阳光照上去泛着暗紫金属冷光——看这寸草枯焦的旱象，多半是《山海经》所载的「太华六足肥遗蛟」或「苍梧巴蛇」昨夜在此蜕鳞！\n\n鳞片边缘尚沾着微沸的紫黑残涎，隔着两步便熏得人眼眶发酸。这些异兽奇材送去百工坊或药铺可是实打实的重宝，却也藏着蚀肉烂铁的凶险。";

				if (::Wuxia.Events.isAlive(exp))
				{
					this.Options.push({
						Text = "让 " + ::Wuxia.Events.shortName(exp) + " 用桐油布与冷灰稳妥剥收蜕鳞",
						function getResult( _ev ) { return "ExpertHarvest"; }
					});
				}
				this.Options.push({
					Text = "叫 " + ::Wuxia.Events.shortName(bro) + " 裹上破麻布快手抢收几片",
					function getResult( _ev ) { return "RoughHarvest"; }
				});
				this.Options.push({
					Text = "大妖走远未久，莫要贪财送命，速速绕出焦谷。",
					function getResult( _ev ) { return "Leave"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "ExpertHarvest",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "识货行家抵得上半支镖队。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local exp = _event.m.Expert;
				if (::Wuxia.Events.isAlive(exp)) this.Characters.push(exp.getImagePath());

				::Wuxia.Events.giveItem("scripts/items/misc/serpent_skin_item", this.List);
				::Wuxia.Events.giveItem("scripts/items/misc/glistening_scales_item", this.List);
				::Wuxia.Events.addMoney(120, this.List);
				if (::Wuxia.Events.isAlive(exp))
				{
					::Wuxia.Events.addMood(exp, 1.0, "稳妥收得山海异兽蜕鳞", this.List);
					::Wuxia.Events.addMastery(exp, 40, this.List);
				}

				this.Text = "[img]gfx/ui/events/wx_ev_23.png[/img]" + ::Wuxia.Events.fmtName(exp) + " 摆手示意众人退开上风口，先抓一把枯草灰撒去残涎烈性，再用浸过桐油的厚帆布夹起最完好的青黑蜕皮与微光逆鳞，动作行云流水，连指甲缝都没沾上半星毒汁。临走时还在石缝里翻出一只遇害猎户遗落的钱袋，众人满载而归。";
			}
		});

		this.m.Screens.push({
			ID = "RoughHarvest",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "财帛动人心，好在命保住了。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.giveItem("scripts/items/misc/serpent_skin_item", this.List);
				if (::Wuxia.Events.isAlive(bro))
				{
					::Wuxia.Events.applyLightHurt(bro, 0.16, this.List);
					::Wuxia.Events.addMood(bro, -0.5, "徒手收鳞被毒涎灼伤", this.List);
				}

				this.Text = "[img]gfx/ui/events/wx_ev_23.png[/img]" + ::Wuxia.Events.fmtName(bro) + " 拿两条旧绑腿草草缠住双手，猫着腰扑进泥洼撬下大片坚韧妖鳞。谁知一片倒刺猛地划破麻布，炙热的紫毒残涎顿时在手背滋滋作响，烧出两块焦红水泡！众人忙拿清水猛冲包扎，好在抢出的鳞皮货真价实。";
			}
		});

		this.m.Screens.push({
			ID = "Leave",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "紧赶行程。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_23.png[/img]你抬手止住几个眼红的弟兄：能把整条山溪蒸干的凶物，未必离此地超过十里。全队勒紧兵器快步翻过焦岭，直到听见山外正常的鸟鸣声，众人紧绷的脊背才松弛下来。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (this.World.getTime().Days < 8) return;
		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Expert = ::Wuxia.Events.findByBackgrounds([
			"background.beast_hunter", "background.beast_slayer", "background.lindwurm_slayer",
			"background.anatomist", "background.hunter"
		]);
		this.m.Score = 14;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Expert = null;
		this.m.Bro = null;
	}
});
