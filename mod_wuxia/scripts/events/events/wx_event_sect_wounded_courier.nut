// Batch E4 Event 37: 负伤门派信使（地域门派互动）

this.wx_event_sect_wounded_courier <- this.inherit("scripts/events/event", {
	m = {
		SectID   = null,
		Bro      = null,
		PaidWith = ""
	},

	function create()
	{
		this.m.ID = "event.wx_sect_wounded_courier";
		this.m.Title = "血染竹筒 · 负伤门派信使";
		this.m.Cooldown = 28.0 * this.World.getTime().SecondsPerDay;

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
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				local hasMeds = ::World.Assets.getMedicine() >= 8;
				local healLabel = hasMeds
					? "耗 8 份伤药替他包扎，护送人信前往下个暗桩"
					: "花 100 银两购药救治，护送人信前往下个暗桩";

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]一匹空鞍惊马嘶鸣着掠过" + regionLabel + "的泥泞官道，马镫上还拖着半截折断的雕翎箭。往前走出半里，路旁排水沟里爬出个满身泥血的年轻信使，左肋衣襟早已浸透发黑，右手却死死抠着一截油蜡封口的青竹筒，指节发白得像要嵌进竹皮里。\n\n" + ::Wuxia.Events.fmtName(bro) + "一眼认出他衣领内侧绣着【" + sect.Name + "】的暗纹。那信使咳出一口血沫，嘶哑着嗓子抬头哀求：『追兵……至多半柱香便到！求诸位好汉行个方便，把这截急信连我这条残命送到前头分舵……』";

				this.Options.push({
					Text = healLabel,
					function getResult( _ev )
					{
						if (::World.Assets.getMedicine() >= 8)
						{
							_ev.m.PaidWith = "meds";
							return "Shield";
						}
						if (::World.Assets.getMoney() >= 100)
						{
							_ev.m.PaidWith = "money";
							return "Shield";
						}
						return "NoMoney";
					}
				});

				this.Options.push({
					Text = "先议护镖酬金，给够现银便保你平安。",
					function getResult( _ev ) { return "Fee"; }
				});

				this.Options.push({
					Text = "趁他失血晕厥，顺手搜刮行囊与暗袋。",
					function getResult( _ev ) { return "Rob"; }
				});

				this.Options.push({
					Text = "江湖是非沾不得，绕过泥沟径直赶路。",
					function getResult( _ev ) { return 0; }
				});
			}
		});

		this.m.Screens.push({
			ID = "Shield",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "抱拳别过，继续上路。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				if (_event.m.PaidWith == "meds")
					::Wuxia.Events.addSupplies(0, -8, 0, this.List);
				else
					::Wuxia.Events.addMoney(-100, this.List);

				::Wuxia.Events.addSectRel(_event.m.SectID, 22, this.List);
				::Wuxia.Events.addReputation(30, 0, this.List);

				local giftLine = "";
				if (::Math.rand(1, 100) <= 50)
				{
					::Wuxia.Events.givePill("wx_pill_huxin", this.List);
					giftLine = "管事连声道谢，郑重取出门中常备的一枚灵药相赠。";
				}
				else
				{
					::Wuxia.Events.givePage("sect", 1, this.List, _event.m.SectID);
					giftLine = "管事感念雪中送炭之情，破例取出一叶本门旧抄残页作谢。";
				}

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]众人扯下干净布条替信使勒紧创口，又将他扶上驮马藏在斗笠下。半道上果然撞见几名黑衣骑手迎面盘查，见你们列阵按刀、杀气沉沉，对方掂量片刻终究没敢发作。\n\n将人安稳送到【" + sect.Name + "】暗桩时，油蜡封口完好无损。" + giftLine;
			}
		});

		this.m.Screens.push({
			ID = "Fee",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "银货两讫，各不相欠。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(160, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 10, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]『弟兄们的命也是拿刀口换的，救人护信可以，得先讲价。』\n\n信使咬着牙扯开贴身腰带，摸出一包沾血的散碎银子抛过来。你们收银办事丝毫不打折扣，一路将人护送至【" + sect.Name + "】外围接应处。对方虽嫌你们市侩，却也敬你们拿钱真办事、半点未动那截竹筒。";
			}
		});

		this.m.Screens.push({
			ID = "Rob",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "趁追兵未至，速离此地。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(240, this.List);
				::Wuxia.Events.givePage("sect", 1, this.List, _event.m.SectID);
				::Wuxia.Events.addSectRel(_event.m.SectID, -30, this.List);
				::Wuxia.Events.addReputation(0, -8, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]雨水顺着信使苍白的额角淌进眼睛，他连挣扎的力气都散尽了。有人默不作声地撬开他僵硬的指缝，又从他贴身夹层里翻出一袋盘缠银两和一叶夹在油纸里的门派练功残页。\n\n把人拖到荒碑后头草草一丢，你们催步离去。只是那信使临昏前死死盯住了你们的旗号，待【" + sect.Name + "】查明今日旧账，这笔黑账绝不会善罢甘休。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "爱莫能助，叹息离去。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]翻遍药囊既凑不够伤药，钱袋里也拮据得拿不出买药的现银。你们只得留下一口清水，眼看雨幕渐浓，无奈离开泥沟。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::Wuxia.Events.getAliveBros().len() == 0) return;
		this.m.SectID = ::Wuxia.Events.pickLocalSect();
		this.m.Bro = ::Wuxia.Events.findRandomBro();
		this.m.Score = 16;
	}

	function onPrepare()
	{
		if (this.m.SectID == null || !(this.m.SectID in ::Wuxia.Config.Sects))
			this.m.SectID = ::Wuxia.Events.pickLocalSect();
		if (!::Wuxia.Events.isAlive(this.m.Bro))
			this.m.Bro = ::Wuxia.Events.findRandomBro();
	}

	function onPrepareVariables( _vars ) {}

	function onClear()
	{
		this.m.SectID = null;
		this.m.Bro = null;
		this.m.PaidWith = "";
	}
});
