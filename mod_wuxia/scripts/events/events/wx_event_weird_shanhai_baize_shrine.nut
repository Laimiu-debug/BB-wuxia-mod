// Strange-Tales Event 55: 山海古碑·白泽旧祠（献香祈灵或拓录百兽破绽图）

this.wx_event_weird_shanhai_baize_shrine <- this.inherit("scripts/events/event", {
	m = {
		Scholar = null,
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_weird_shanhai_baize_shrine";
		this.m.Title = "山海古碑·白泽旧祠";
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

				local sch = _event.m.Scholar;
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(sch)) this.Characters.push(sch.getImagePath());
				else if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_24.png[/img]拨开缠满枯藤的山崖石缝，一座不知何朝遗留的青石古祠悄然立在云雾里。神龛中既非佛祖也非关帝，而是一尊羊身独角、双目似笑非笑的石雕异兽——相传通晓天下万物鬼神情状的「白泽」。\n\n石座四周密密麻麻阴刻着上古妖兽的筋骨要害与辟邪诀窍，虽经百年风雨剥蚀，仍有不少笔画清晰可辨；香案上则静静摆着一只包浆温润的鎏金铜炉。";

				this.Options.push({
					Text = "洒净水焚香祈安（花费 100 银两香火与清酒，全队静心参悟）",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 100) return "NoMoney";
						return "OfferIncense";
					}
				});
				if (::Wuxia.Events.isAlive(sch))
				{
					this.Options.push({
						Text = "令 " + ::Wuxia.Events.shortName(sch) + " 仔细拓录石座上的百兽要害图谱",
						function getResult( _ev ) { return "StudyGlyphs"; }
					});
				}
				this.Options.push({
					Text = "死石头能值几个钱？撬走那只鎏金铜香炉换银子！",
					function getResult( _ev ) { return "LootCenser"; }
				});
				this.Options.push({
					Text = "恭敬揖礼后退出古祠。",
					function getResult( _ev ) { return 0; }
				});
			}
		});

		this.m.Screens.push({
			ID = "OfferIncense",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "神明虽远，人心得安。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(-100, this.List);
				::Wuxia.Events.addCompanyMastery(50, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "于白泽古祠焚香静心", this.List);
				if (::Wuxia.Events.isAlive(bro))
					::Wuxia.Events.addStat(bro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_24.png[/img]众人清扫落叶，以清水洒地，插上三炷沉香并浇下几盏好酒。山风穿堂而过，香烟竟笔直向上凝而不散；众弟兄盘坐石阶调息半个时辰，平日滞涩的经脉招路竟隐隐生出几分通透之感，" + ::Wuxia.Events.fmtName(bro) + " 更是顿觉心境沉稳许多。";
			}
		});

		this.m.Screens.push({
			ID = "StudyGlyphs",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "知己知彼，方敢入大荒。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local sch = _event.m.Scholar;
				if (::Wuxia.Events.isAlive(sch)) this.Characters.push(sch.getImagePath());

				if (::Wuxia.Events.isAlive(sch))
				{
					::Wuxia.Events.addMastery(sch, 85, this.List);
					::Wuxia.Events.addMood(sch, 1.0, "拓得古祠白泽百兽破绽图", this.List);
				}
				::Wuxia.Events.addCompanyMastery(30, this.List);
				::Wuxia.Events.givePill("wx_pill_dingshen", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_24.png[/img]" + ::Wuxia.Events.fmtName(sch) + " 拂去青苔，拿炭条在粗纸上飞快勾勒出石座上『畏火、忌重钝、破幻目』等古篆秘诀，又从暗格里摸出一只蜡封完好的前人辟邪药瓶。众人围着火堆细听拆解，对日后周旋妖异与悍敌都添了十足底气。";
			}
		});

		this.m.Screens.push({
			ID = "LootCenser",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "揣好铜炉，快步下山。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(260, this.List);
				::Wuxia.Events.addReputation(0, -6, this.List);
				::Wuxia.Events.addCompanyMood(-0.5, "盗取古祠铜炉，心里发毛", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_24.png[/img]几名手脚麻利的汉子拿刀背撬松底座，把那只沉甸甸的鎏金铜炉塞进麻袋。刚走出祠门，身后石雕眼眶里忽地滚落两粒碎石，嗒嗒作响，听得胆小的弟兄后颈发凉，一连两宿都没睡踏实——好在进镇后铜炉实打实换回二百六十两雪花银。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "合十离去。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_24.png[/img]摸摸腰包竟连百两香火酒钱都凑不齐，众人只得恭敬鞠了三躬，悄然退出石祠。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (this.World.getTime().Days < 10) return;
		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Scholar = ::Wuxia.Events.findByBackgrounds([
			"background.historian", "background.beast_hunter", "background.beast_slayer", "background.witchhunter", "background.monk"
		]);
		this.m.Score = 13;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Scholar = null;
		this.m.Bro = null;
	}
});
