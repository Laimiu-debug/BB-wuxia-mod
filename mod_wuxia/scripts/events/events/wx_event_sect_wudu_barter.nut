// Batch E4 Event 45: 苗疆毒婆易物（南疆五毒奇门 / 湘西辰州符水门）

this.wx_event_sect_wudu_barter <- this.inherit("scripts/events/event", {
	m = {
		SectID    = null,
		ZealotBro = null,
		Bro       = null
	},

	function create()
	{
		this.m.ID = "event.wx_sect_wudu_barter";
		this.m.Title = "瘴雾药篓 · 苗疆毒婆易物";
		this.m.Cooldown = 34.0 * this.World.getTime().SecondsPerDay;

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
				local showBro = ::Wuxia.Events.isAlive(_event.m.ZealotBro) ? _event.m.ZealotBro : _event.m.Bro;
				if (::Wuxia.Events.isAlive(showBro)) this.Characters.push(showBro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]乳白湿雾漫过" + regionLabel + "的杉树林隙，枯叶堆边坐着个裹着蓝印花布头巾、耳坠暗银铃的老妪。她脚畔那只密编竹篓里时不时发出细微的「沙沙」爬动声，谁也没兴致凑近细看。\n\n老妪掀起半角黑纱，露出嚼槟榔染黑的牙龈，往石板上摆出两只黑漆药瓶和一卷烙有【" + sect.Name + "】虫纹火印的油纸残卷，声音像干竹叶摩擦：『中原郎中既解不了林子里的吹箭奇毒，也接不回震断的筋骨。拿银子换，别打听药引子是从哪条死溪沟里捞出来的。』";

				this.Options.push({
					Text = "花 320 银两买下两瓶奇门秘药（清心解毒丹 + 易筋活络膏）",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 320) return "NoMoney";
						return "BuyVials";
					}
				});

				this.Options.push({
					Text = "花 520 银两购下那卷【" + sect.Name + "】秘录残页",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 520) return "NoMoney";
						return "BuyPage";
					}
				});

				if (::Wuxia.Events.isAlive(_event.m.ZealotBro))
				{
					this.Options.push({
						Text = "让" + ::Wuxia.Events.shortName(_event.m.ZealotBro) + "当场喝斥，驱离这邪门毒婆！",
						function getResult( _ev ) { return "DriveAway"; }
					});
				}

				this.Options.push({
					Text = "掩鼻退开，不与奇门瘴毒沾边。",
					function getResult( _ev ) { return 0; }
				});
			}
		});

		this.m.Screens.push({
			ID = "BuyVials",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收妥药瓶，趁雾散赶路。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				::Wuxia.Events.addMoney(-320, this.List);
				::Wuxia.Events.givePill("wx_pill_qingxin", this.List);
				::Wuxia.Events.givePill("wx_pill_huoluo", this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 12, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]三百二十两银子落进干枯手掌，老妪嘎嘎低笑两声，将碧玉解毒丸与黑玉活络膏推到石板边沿。拔塞轻嗅，药味刺鼻却隐透清凉，确是以毒攻毒的【" + sect.Name + "】真传货色。待你们抬头，人连同那只沙沙作响的竹篓早已融进白雾里。";
			}
		});

		this.m.Screens.push({
			ID = "BuyPage",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "仔细封存残页，尽快离林。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				::Wuxia.Events.addMoney(-520, this.List);
				::Wuxia.Events.givePage("sect", 1, this.List, _event.m.SectID);
				::Wuxia.Events.addSectRel(_event.m.SectID, 10, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]老妪用指甲逐块掐验银锭成色，满意地解开系着五色丝线的油纸卷。那叶【" + sect.Name + "】秘录残页以虫胶防潮，墨迹奇崛古怪，透着一股南疆林泽特有的阴森气味。老妪嘶声叮嘱『莫用湿手翻页』，背起竹篓叮当作响地拐入了浓雾深处。";
			}
		});

		this.m.Screens.push({
			ID = "DriveAway",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "驱邪明志，整队前行。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local zealot = _event.m.ZealotBro;
				if (::Wuxia.Events.isAlive(zealot)) this.Characters.push(zealot.getImagePath());

				::Wuxia.Events.addReputation(0, 5, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, -15, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "驱逐邪派毒婆，正气提神", this.List);
				::Wuxia.Events.addStat(zealot, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]" + ::Wuxia.Events.fmtName(zealot) + "面色一沉，跨步上前一脚踢翻石板旁的艾草炭盆，厉声喝道：『【" + sect.Name + "】的阴毒妖物，也敢在光天化日下兜售害人蛊药！滚回瘴林去，否则今日便叫你人篓俱焚！』\n\n老妪眸光阴狠地剜了众人一眼，嘴里叽里咕噜吐出一串恶毒苗咒，终究忌惮你们刀剑齐出，抓起药篓狼狈遁入密林。弟兄们只觉胸中郁闷雾气一扫而空，胆气倍增。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "退离林隙。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]钱袋里现银不足。老妪冷冷扫了一眼，把漆瓶与油纸卷重新塞回怀中，头也不抬地摆了摆干瘦的手掌。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::Wuxia.Events.getAliveBros().len() == 0) return;
		local pool = ["wudu", "xiangxi_ganshi"];
		this.m.SectID = pool[::Math.rand(0, pool.len() - 1)];
		this.m.ZealotBro = ::Wuxia.Events.findByBackgrounds([
			"background.witchhunter",
			"background.monk"
		]);
		this.m.Bro = ::Wuxia.Events.findRandomBro();
		this.m.Score = 15;
	}

	function onPrepare()
	{
		if (this.m.SectID == null || !(this.m.SectID in ::Wuxia.Config.Sects))
		{
			local pool = ["wudu", "xiangxi_ganshi"];
			this.m.SectID = pool[::Math.rand(0, pool.len() - 1)];
		}
		if (!::Wuxia.Events.isAlive(this.m.ZealotBro))
		{
			this.m.ZealotBro = ::Wuxia.Events.findByBackgrounds([
				"background.witchhunter",
				"background.monk"
			]);
		}
		if (!::Wuxia.Events.isAlive(this.m.Bro))
			this.m.Bro = ::Wuxia.Events.findRandomBro();
	}

	function onPrepareVariables( _vars ) {}

	function onClear()
	{
		this.m.SectID = null;
		this.m.ZealotBro = null;
		this.m.Bro = null;
	}
});
