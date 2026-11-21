// Batch E5 Event 52: 塌方露出前朝墓道

this.wx_event_weird_ancient_tomb_door <- this.inherit("scripts/events/event", {
	m = {
		Expert = null,
		Worker = null
	},

	function create()
	{
		this.m.ID = "event.wx_weird_ancient_tomb_door";
		this.m.Title = "山崩露穴 · 前朝古墓石门";
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

				local expert = _event.m.Expert;
				local worker = _event.m.Worker;
				if (::Wuxia.Events.isAlive(expert)) this.Characters.push(expert.getImagePath());
				else if (::Wuxia.Events.isAlive(worker)) this.Characters.push(worker.getImagePath());

				local regionLabel = ::Wuxia.Events.getRegionLabel();
				local expertLine = "";
				if (::Wuxia.Events.isAlive(expert))
				{
					expertLine = "\n\n" + ::Wuxia.Events.fmtName(expert) + " 伏在湿泥里拿匕首柄轻敲门槛，听出石壁内里中空，低声道：『这是前朝将陵常见的「顶门流沙铜栓」——蛮力一撬就会扯断伏弩与毒灰瓮，但只要找准右槽暗眼拿木楔顶死，能不惊动半点机关！』";
				}

				this.Text = "[img]gfx/ui/events/wx_ev_17.png[/img]连日山雨冲垮了" + regionLabel + "路畔半面红土崖壁，乱石泥浆之间竟赫然露出一座方正宏阔的前朝花岗岩墓门。门扉缝隙严丝合缝，三枚长满绿锈的青铜顶门销死死咬在石槽里，门额阴刻的古篆戒铭已被苔藓吞去大半。\n\n一股微甜发冷的阴风正顺着指宽石缝往外倒灌，将门前十步内的野草都熏得发黑枯萎，隐约还能听见石墙背后似有细沙滑落的轻响。" + expertLine;

				if (::Wuxia.Events.isAlive(expert))
				{
					this.Options.push({
						Text = "让 " + ::Wuxia.Events.shortName(expert) + " 卸掉青铜流沙栓，稳妥探入前室取宝！",
						function getResult( _ev ) { return "DisarmCleanly"; }
					});
				}

				this.Options.push({
					Text = "管它什么死人机括，抄起铁撬杠与重斧硬撬石门！",
					function getResult( _ev ) { return "PryOpen"; }
				});

				this.Options.push({
					Text = "滚石填土重新掩埋墓口，免得阴煞外泄祸及行旅。",
					function getResult( _ev ) { return "BuryDoor"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "DisarmCleanly",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "封紧战利品，退出阴冷墓道。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local expert = _event.m.Expert;
				local eName = ::Wuxia.Events.isAlive(expert) ? ::Wuxia.Events.fmtName(expert) : "熟谙机关的弟兄";
				if (::Wuxia.Events.isAlive(expert)) this.Characters.push(expert.getImagePath());

				::Wuxia.Events.addMoney(420, this.List);
				::Wuxia.Events.givePage("sect", 1, this.List);
				local gotAsh = false;
				try
				{
					::Wuxia.Events.giveItem("scripts/items/misc/shimmering_ashes_item", this.List);
					gotAsh = true;
				}
				catch (_e) {}
				if (!gotAsh)
				{
					try
					{
						::Wuxia.Events.giveItem("scripts/items/misc/vampire_dust_item", this.List);
						gotAsh = true;
					}
					catch (_e2) {}
				}
				if (!gotAsh) ::Wuxia.Events.addMoney(240, this.List);
				::Wuxia.Events.addMood(expert, 1.0, "巧解前朝墓锁满载而归", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_17.png[/img]" + eName + " 削了两根硬栎木楔，卡准石门右下方的暗孔轻轻一顶，又以匕首挑开铜丝，只听墓门内里『咔哒』一声闷响，三百斤流沙暗闸竟被死死锁在墙中！\n\n推开沉重石扉，前室虽被岁月侵蚀得蛛网密布，石案上却仍完好陈放着一匣前朝陪葬银饼、一卷以蜂蜡封在铜筒内的门派古谱残页，还有一只寒玉小罐，里头盛满幽幽发亮的微光灵烬——不知是哪具古墓剑魔溃散后留下的异物。众人见好就收，绝不多碰主墓室棺椁，悄然退了出去。";
			}
		});

		this.m.Screens.push({
			ID = "PryOpen",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "捂着口鼻撤出墓道，替伤员包扎。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local worker = _event.m.Worker;
				if (!::Wuxia.Events.isAlive(worker)) worker = ::Wuxia.Events.findRandomBro();
				local wName = ::Wuxia.Events.isAlive(worker) ? ::Wuxia.Events.fmtName(worker) : "一名弟兄";
				if (::Wuxia.Events.isAlive(worker)) this.Characters.push(worker.getImagePath());

				::Wuxia.Events.applyLightHurt(worker, 0.16, this.List);
				::Wuxia.Events.addMoney(220, this.List);
				::Wuxia.Events.addMood(worker, -0.75, "硬撬墓门误触毒箭瘴灰", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_17.png[/img]铁撬杠卡进石缝猛一发力，青铜顶门销咔嚓崩断！石门刚裂开尺许，墙内暗弦骤鸣，一蓬锈蚀铜簇夹着呛人的黄绿石灰毒烟迎面喷出！" + wName + " 躲闪不及，肩头吃了一支冷箭，又吸入半口腐瘴咳得撕心裂肺。\n\n待烟尘散去，众人铁青着脸拖出前室一只砸裂的漆木陪葬箱，只拢出二百二十两发黑旧银，至于深处黑黢黢的墓道再没人肯多迈半步。";
			}
		});

		this.m.Screens.push({
			ID = "BuryDoor",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "拍净手上黄土，继续赶路。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				::Wuxia.Events.addReputation(0, 5, this.List);
				::Wuxia.Events.addCompanyMood(0.5, "掩埋古冢心安理得", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_17.png[/img]死人地底的钱沾着阴寒晦气，何况如今各地屡传古墓尸变。你挥手令弟兄们从坡顶推下巨石碎土，把那道露出的石门重新掩埋得严严实实，又在土堆前点了三撮干艾草作揖告别。\n\n虽没发什么横财，队里那些信鬼神的老卒倒个个暗松了口气，脚步都轻快了三分。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Expert = null;
		this.m.Worker = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::Wuxia.Events.getAliveBros().len() < 1) return;

		this.m.Expert = ::Wuxia.Events.findByBackgrounds([
			"background.graverobber",
			"background.mason",
			"background.historian"
		]);
		this.m.Worker = ::Wuxia.Events.findRandomBro(this.m.Expert);
		if (this.m.Worker == null) this.m.Worker = ::Wuxia.Events.findRandomBro();
		this.m.Score = 16;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.Expert))
		{
			this.m.Expert = ::Wuxia.Events.findByBackgrounds([
				"background.graverobber",
				"background.mason",
				"background.historian"
			]);
		}
		if (!::Wuxia.Events.isAlive(this.m.Worker))
			this.m.Worker = ::Wuxia.Events.findRandomBro(this.m.Expert);
		if (!::Wuxia.Events.isAlive(this.m.Worker))
			this.m.Worker = ::Wuxia.Events.findRandomBro();
	}

	function onPrepareVariables( _vars ) {}

	function onClear()
	{
		this.m.Expert = null;
		this.m.Worker = null;
	}
});
