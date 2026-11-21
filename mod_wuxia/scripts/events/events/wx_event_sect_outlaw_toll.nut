// Batch E4 Event 47: 绿林剪径买路财（地域绿林邪道门派拦路索银）

this.wx_event_sect_outlaw_toll <- this.inherit("scripts/events/event", {
	m = {
		SectID  = null,
		CantBro = null,
		Bro     = null
	},

	function create()
	{
		this.m.ID = "event.wx_sect_outlaw_toll";
		this.m.Title = "横松断路 · 绿林剪径";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;

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

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local regionLabel = ::Wuxia.Events.getRegionLabel();
				local showBro = ::Wuxia.Events.isAlive(_event.m.CantBro) ? _event.m.CantBro : _event.m.Bro;
				if (::Wuxia.Events.isAlive(showBro)) this.Characters.push(showBro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]「咔嚓」一声巨响，两棵早已锯断半边树干的碗口老松轰然砸落，死死封住" + regionLabel + "这条下凹车辙窄道，松针与红尘腾起半丈高。两侧乱石堆后齐刷刷探出七八顶破斗笠，几簇铁箭尖在树影间冷冷发亮。\n\n高岩上一个破锣嗓子高声报出【" + sect.Name + "】的山头名号：『山高路滑，寨里弟兄在林子喝西北风也不容易！识相的留下 240 两买路茶水钱，咱们替你们挪开倒木，保这一路少挨暗箭！』";

				this.Options.push({
					Text = "掷出 240 银两买路钱，换个干脆放行",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 240) return "NoMoney";
						return "PayToll";
					}
				});

				if (::Wuxia.Events.isAlive(_event.m.CantBro))
				{
					this.Options.push({
						Text = "让" + ::Wuxia.Events.shortName(_event.m.CantBro) + "抱拳盘黑道切口，攀个道上交情（免银过关）",
						function getResult( _ev ) { return "SpeakCant"; }
					});
				}

				this.Options.push({
					Text = "全队铿锵拔刃列阵，喝骂剪径贼子有种现身硬碰！",
					function getResult( _ev ) { return "DrawSteel"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "PayToll",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "破财消灾，策马过坎。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				::Wuxia.Events.addMoney(-240, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 15, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]一袋沉甸甸的银两划过半空稳稳落在松树干上。林梢响起一声清脆竹哨，几名精壮汉子从羊齿草丛钻出来掂了掂分量，咧嘴笑道：『爽快人！往后进了【" + sect.Name + "】的地界，报上今日的号子，没人再拦你们的马头！』说罢七手八脚将倒松滚入沟边，放你们安然通行。";
			}
		});

		this.m.Screens.push({
			ID = "SpeakCant",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "相视一笑，分文未花过关！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local cant = _event.m.CantBro;
				if (::Wuxia.Events.isAlive(cant)) this.Characters.push(cant.getImagePath());

				::Wuxia.Events.addSectRel(_event.m.SectID, 14, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "黑道切口对答如流，免银借道", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]" + ::Wuxia.Events.fmtName(cant) + "左手拇指往腰带里一勾，笑嘻嘻踏前两步，张口便吐出一串连珠黑道切口——从江河春点问到寒冬暗码，末了还顺口问候了【" + sect.Name + "】后山隘口某位爱喝浑酒的把兄弟。\n\n高岩上静默了三息，随即爆出一阵大笑：『大水冲了龙王庙！自家道上踩盘子的老哥们，收买路钱岂不叫人笑掉大牙？』伏兵纷纷现身挪开松干，临走还抛下一只酸梅烈酒葫芦权当赔罪。";
			}
		});

		this.m.Screens.push({
			ID = "DrawSteel",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "掀开倒木，扬长而去！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addSectRel(_event.m.SectID, -15, this.List);
				::Wuxia.Events.addReputation(35, 0, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "拔刃震慑绿林伏兵，全队胆气如虹", this.List);
				::Wuxia.Events.addStat(bro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]「呛啷」一片寒铁齐鸣！你们不退反进，瞬间散成半月杀阵压向两侧石坡，甲叶铿锵，刀刃上还留着旧战崩口。石堆上弓弦咯吱拉满却迟迟不敢放箭——这帮【" + sect.Name + "】的哨探本是蹲守肥硕商队的，哪料撞上一群眼神比野狼还凶、巴不得冲上山坡剁碎骨头的亡命煞星。\n\n骂骂咧咧的脚步声渐渐退入深林。弟兄们放声大笑，合力掀翻倒松大摇大摆穿道而过。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "只得绕道荒坡而行。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]抖开钱袋竟凑不够二百四十两。林间暗哨见你们寒酸得叮当响，哄笑两声骂你们『穷鬼也敢走大路』，你们只得憋着一肚子火绕道荒岭泥坡多走了半日冤枉路。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::Wuxia.Events.getAliveBros().len() == 0) return;
		this.m.SectID = ::Wuxia.Events.pickLocalSect("outlaw");
		this.m.CantBro = ::Wuxia.Events.findByBackgrounds([
			"background.raider",
			"background.killer_on_the_run",
			"background.brawler",
			"background.thief"
		]);
		this.m.Bro = ::Wuxia.Events.findRandomBro();
		this.m.Score = 16;
	}

	function onPrepare()
	{
		if (this.m.SectID == null || !(this.m.SectID in ::Wuxia.Config.Sects))
			this.m.SectID = ::Wuxia.Events.pickLocalSect("outlaw");
		if (!::Wuxia.Events.isAlive(this.m.CantBro))
		{
			this.m.CantBro = ::Wuxia.Events.findByBackgrounds([
				"background.raider",
				"background.killer_on_the_run",
				"background.brawler",
				"background.thief"
			]);
		}
		if (!::Wuxia.Events.isAlive(this.m.Bro))
			this.m.Bro = ::Wuxia.Events.findRandomBro();
	}

	function onPrepareVariables( _vars ) {}

	function onClear()
	{
		this.m.SectID = null;
		this.m.CantBro = null;
		this.m.Bro = null;
	}
});
