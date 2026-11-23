// Strange-Tales Event 56: 幽谷讹兽幻音（雾中听见故人呼唤的山海妖障）

this.wx_event_weird_shanhai_mirage <- this.inherit("scripts/events/event", {
	m = {
		Shooter = null,
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_weird_shanhai_mirage";
		this.m.Title = "幽谷讹兽幻音";
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

				local sh = _event.m.Shooter;
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(sh)) this.Characters.push(sh.getImagePath());
				else if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_33.png[/img]入暮时分，一阵乳白浓雾毫无征兆地漫过山谷，五步之外只剩灰蒙蒙的人影。正当队伍缩紧阵型缓行，左侧崖壁的雾墙后竟响起熟悉的唤声——有人听见早年战死的老伙计在喊自己小名，有人听见家乡老娘在催着回家吃热面，声声凄切，直往人心缝里钻！\n\n" + ::Wuxia.Events.fmtName(bro) + " 脸色煞白，脚步已不受控制地往悬崖边挪了半步——老江湖瞬间醒悟，这是山野「幽谷梦魇讹兽」吐雾惑人、诱杀落单行旅的妖伎！";

				this.Options.push({
					Text = "麻绳连腰捆紧全队，击盾报数稳步冲出白雾！",
					function getResult( _ev ) { return "RopeMarch"; }
				});
				if (::Wuxia.Events.isAlive(sh))
				{
					this.Options.push({
						Text = "令 " + ::Wuxia.Events.shortName(sh) + " 盯死雾中微光妖目，齐射十支箭矢破幻！",
						function getResult( _ev )
						{
							if (::World.Assets.getAmmo() < 10) return "NoAmmo";
							return "ShootMist";
						}
					});
				}
				this.Options.push({
					Text = "派 " + ::Wuxia.Events.shortName(bro) + " 举火把上前探清究竟。",
					function getResult( _ev ) { return "ScoutMist"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "RopeMarch",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "莫信耳边鬼话，只信身边袍泽。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				if (::Wuxia.Events.isAlive(bro))
				{
					::Wuxia.Events.addStat(bro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
					::Wuxia.Events.addMood(bro, 0.75, "同袍相扶冲出讹兽幻雾", this.List);
				}
				::Wuxia.Events.addCompanyMood(0.5, "众志成城破除山谷迷障", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_33.png[/img]你一巴掌扇醒发愣的 " + ::Wuxia.Events.fmtName(bro) + "，当机立断拿拴马麻绳将全队腰带串成一串，刀背敲盾齐声报数。任凭雾里哭笑声愈发凄厉尖锐，众人咬紧牙关一步不乱，硬生生踩着官道石板冲出了三里白雾，回头望去时山谷里只剩一片死寂。";
			}
		});

		this.m.Screens.push({
			ID = "ShootMist",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "好眼力，好准头！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local sh = _event.m.Shooter;
				if (::Wuxia.Events.isAlive(sh)) this.Characters.push(sh.getImagePath());

				::Wuxia.Events.addSupplies(0, 0, -10, this.List);
				::Wuxia.Events.giveItem("scripts/items/misc/third_eye_item", this.List);
				::Wuxia.Events.givePill("wx_pill_dingshen", this.List);
				if (::Wuxia.Events.isAlive(sh))
				{
					::Wuxia.Events.addMastery(sh, 50, this.List);
					::Wuxia.Events.addMood(sh, 1.0, "一箭惊退讹兽夺得诡眼", this.List);
				}

				this.Text = "[img]gfx/ui/events/wx_ev_33.png[/img]" + ::Wuxia.Events.fmtName(sh) + " 眯起左眼，死死锁定雾墙高处一点若隐若现的惨绿萤火，挽满硬弓连珠疾射！雾中骤然发出一声似兔似婴的惨嚎，白障瞬间溃散如潮。众人提灯摸上乱石堆，只见血迹旁留下一颗晶莹诡异的讹兽妖目，外加一包早年遇害方士遗落的【明目定神散】。";
			}
		});

		this.m.Screens.push({
			ID = "NoAmmo",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "改用麻绳结阵突围。", function getResult( _event ) { return "RopeMarch"; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_33.png[/img]箭囊已空，连十支齐射的羽箭都凑不齐。眼看雾气越逼越紧，只得立刻改用麻绳串队强行冲谷！";
			}
		});

		this.m.Screens.push({
			ID = "ScoutMist",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "吃一堑长一智。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				if (::Wuxia.Events.isAlive(bro))
				{
					::Wuxia.Events.applyLightHurt(bro, 0.18, this.List);
					::Wuxia.Events.addMood(bro, -0.75, "落入讹兽幻音险些坠崖", this.List);
				}

				this.Text = "[img]gfx/ui/events/wx_ev_33.png[/img]" + ::Wuxia.Events.fmtName(bro) + " 举着松明刚踏入白雾十步，火光便如被冷风吞没，紧接着崖边传来一声闷响与碎石滚落声！众人急忙抛下缆绳将满身擦伤的他拽回官道。他浑身发抖地嘟囔着雾里什么活人都没有，唯有两只惨白巨眼紧贴着自己鼻尖发笑。";
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
		this.m.Shooter = ::Wuxia.Events.findByBackgrounds([
			"background.hunter", "background.poacher", "background.bowyer", "background.beast_hunter", "background.witchhunter"
		], bro);
		this.m.Score = ::Wuxia.Events.isNight() ? 18 : 11;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Shooter = null;
		this.m.Bro = null;
	}
});
