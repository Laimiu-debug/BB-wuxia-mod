// Batch E1 Event 11: 荒野孤獒（驯犬师/牧羊人在营外荆棘丛安抚一头满身旧刀疤的流浪恶獒）

this.wx_event_camp_houndmaster_stray <- this.inherit("scripts/events/event", {
	m = {
		BroA = null,
		BroB = null
	},

	function create()
	{
		this.m.ID = "event.wx_camp_houndmaster_stray";
		this.m.Title = "荒野孤獒";
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
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				this.Text = "[img]gfx/ui/events/wx_ev_32.png[/img]火光照不到的酸枣棘丛里，忽地亮起两粒琥珀似的幽黄兽瞳。一头瘦得肋骨毕露的黑背大獒伏低身子缓缓逼近——它左耳被箭镞削去了半截，胁下结着几道发黑的陈年刀疤，脖子上还拖着半尺嚼烂的麻绳，只要营里有人稍动脚步，喉咙深处便滚出一串慑人的低吼。\n\n守夜弟兄刚要挺矛驱赶，" + nameA + " 却轻轻抬手按住枪杆。他不直视恶犬双眼，侧着身子缓步蹲下，舌尖抵齿发出一连串古怪而柔和的三短哨音。那孤獒竖起的脊毛竟缓缓落下去半寸，湿润黑鼻抽动着，盯向 " + nameA + " 掌心那块油亮腊肉皮。\n\n" + nameA + " 头也不回地低声道：『是头正经上过血阵的悍獒，旧主八成已烂在荒沟里了。肯花 140 两买齐熟肉干、铆钉硬皮颈圈和铁链，两日内我就能驯它认主上阵咬贼；若嫌行军累赘，赏它几根肉骨头今夜替大伙守营也成。』";

				this.Options = [
					{
						Text = "拨 140 银两置办肉干与铁铆皮圈，收进营里驯成战犬！",
						function getResult( _event )
						{
							if (::World.Assets.getMoney() < 140) return "NoMoney";
							return "AdoptDog";
						}
					},
					{
						Text = "带犬赶路太费粮，丢几根肉骨头让它今夜蹲在营口守夜。",
						function getResult( _event ) { return "GuardTonight"; }
					},
					{
						Text = "荒山野犬怕带疯毒，扔支火把把它远远惊走！",
						function getResult( _event ) { return "DriveAway"; }
					}
				];
			}
		});

		this.m.Screens.push({
			ID = "AdoptDog",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "多一张利口，阵上少流一升血。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addMoney(-140, this.List);
				::Wuxia.Events.giveItem("scripts/items/accessory/wardog_item", this.List);
				::Wuxia.Events.addMood(_event.m.BroA, 1.5, "亲手收服了一头血性好獒", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_32.png[/img]" + nameA + " 一小块一小块喂着肉干，任由恶獒嗅遍自己满是旧血味与羊膻气的袖口，待它浑身戒备的颤抖止住，方才稳稳套上沉甸甸的铜钉硬牛皮颈圈。\n\n次日晌午拔营时，这头伤痕累累的黑背恶獒已不声不响跟在队尾，一双冷眼死死扫视着道旁树林，随时准备扑断任何敢近身贼人的脚筋。";
			}
		});

		this.m.Screens.push({
			ID = "GuardTonight",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "一宿无警，皆大欢喜。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local guardBro = ::Wuxia.Events.isAlive(_event.m.BroB) ? _event.m.BroB : _event.m.BroA;

				::Wuxia.Events.addCompanyMood(0.75, "孤獒蹲守营口睡了个难得安稳觉", this.List);
				::Wuxia.Events.addStat(guardBro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_32.png[/img]" + nameA + " 往草坡上抛去两根带着残肉的棒骨。孤獒狼吞虎咽啃净，竟真的通灵般趴在营地迎风口，面朝荒野一动不动；后半夜林梢刚有野狐惊鸟响动，它便发出一声震得树叶沙沙作响的凶吠。\n\n有这么一头恶兽蹲在暗处替大伙放哨，连平日值夜最易惊悸的 " + ::Wuxia.Events.fmtName(guardBro) + " 也稳住了心神。待晨雾散去时，黑背大獒早已悄无声息没入荒山，只留下草窝里一道尚温的印子。";
			}
		});

		this.m.Screens.push({
			ID = "DriveAway",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "荒野里少惹野物，省得招灾。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addMood(_event.m.BroA, -0.5, "眼睁睁赶走了一条通灵好獒", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_32.png[/img]你随手扬出一根燃烧的松枝，火星在湿草丛里炸开一片碎光。孤獒无声地龇了龇发黄獠牙，连半声呜咽都没发，缓缓退回漆黑荆棘深处不见了踪影。" + nameA + " 望着空荡荡的山坡轻叹一声，拿鞋底碾灭了余火。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "换个处置法子。", function getResult( _event ) { return "A"; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_32.png[/img]囊中羞涩，凑不出 140 两银子置办肉干与皮圈铁链，只好另作计较。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		this.m.BroA = null;
		this.m.BroB = null;

		local master = ::Wuxia.Events.findByBackgrounds([
			"background.houndmaster",
			"background.shepherd"
		]);
		if (master == null) return;

		this.m.BroA = master;
		this.m.BroB = ::Wuxia.Events.findRandomBro(master);
		this.m.Score = 15;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.BroA))
		{
			this.m.BroA = ::Wuxia.Events.findByBackgrounds([
				"background.houndmaster",
				"background.shepherd"
			]);
		}
		if (this.m.BroB != null && !::Wuxia.Events.isAlive(this.m.BroB))
			this.m.BroB = ::Wuxia.Events.findRandomBro(this.m.BroA);
	}

	function onPrepareVariables( _vars )
	{
		_vars.push(["houndmaster", ::Wuxia.Events.shortName(this.m.BroA)]);
	}

	function onClear()
	{
		this.m.BroA = null;
		this.m.BroB = null;
	}
});
