// Batch E3-25: 黄昏拆招（营地双人木刃过招，磨砺火候）

this.wx_event_martial_sparring <- this.inherit("scripts/events/event", {
	m = {
		BroA = null,
		BroB = null
	},

	function create()
	{
		this.m.ID = "event.wx_martial_sparring";
		this.m.Title = "黄昏拆招";
		this.m.Cooldown = 16.0 * this.World.getTime().SecondsPerDay;

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

				local a = _event.m.BroA;
				local b = _event.m.BroB;
				if (::Wuxia.Events.isAlive(a)) this.Characters.push(a.getImagePath());
				if (::Wuxia.Events.isAlive(b)) this.Characters.push(b.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(a);
				local nameB = ::Wuxia.Events.fmtName(b);
				local manA = ::Wuxia.Events.pickManualName(a);
				local manB = ::Wuxia.Events.pickManualName(b);

				this.Text = "[img]gfx/ui/events/wx_ev_11.png[/img]暮色压上荒坡，炖肉锅里的腥香还没煮透，营地空地上先响起削木头的嚓嚓声。" + nameA + "拿短刀剥去两根老桑木的粗皮，顺手把沉的那根抛给" + nameB + "：『昨儿夜里翻来覆去琢磨" + manA + "里那记转腕变招，总觉得差着半寸劲口。你那手" + manB + "刁钻，来替我喂上几合？』\n\n" + nameB + "掂了掂桑木棍的分量，嘴角一咧，顺势把外袍系进腰带。几名歇脚的弟兄闻声围拢过来，捧着糙瓷碗起哄叫好，还有人已经摸出几枚铜钱在靴筒边押起输赢。";

				this.Options.push({
					Text = "放开手脚，按真搏命的路数实打实拆上三十合！",
					function getResult( _ev )
					{
						return ::Math.rand(1, 100) <= 30 ? "FullHurt" : "FullClean";
					}
				});
				this.Options.push({
					Text = "收住力道慢拆喂招，一式一式抠准破绽与步眼。",
					function getResult( _ev ) { return "SlowCheck"; }
				});
				this.Options.push({
					Text = "天色将暗、明日还要赶路，收了木棍趁热吃饭。",
					function getResult( _ev ) { return "CallOff"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "FullClean",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "痛快！开饭喝酒。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local a = _event.m.BroA;
				local b = _event.m.BroB;
				if (::Wuxia.Events.isAlive(a)) this.Characters.push(a.getImagePath());
				if (::Wuxia.Events.isAlive(b)) this.Characters.push(b.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(a);
				local nameB = ::Wuxia.Events.fmtName(b);
				local manA = ::Wuxia.Events.pickManualName(a);
				local manB = ::Wuxia.Events.pickManualName(b);

				this.Text = "[img]gfx/ui/events/wx_ev_11.png[/img]两根桑木棍撞在一处，噼啪脆响惊飞了林梢暮鸦。" + nameA + "抢先进步，把" + manA + "的连环杀招使了个七八分真劲；" + nameB + "也不退让，脚底碾碎枯草，凭着" + manB + "的架势硬生生斜格反撩。三十余合下来，木屑飞溅满肩，两人竟未伤及分毫，反在生死一线般的抢攻里摸清了彼此换气的死穴。\n\n收势时二人满头白汽，相视大笑。围观弟兄看得出神，好些人端着饭碗还在比划方才那记错步回身，营中练武之风顿时炽盛起来。";

				::Wuxia.Events.addMastery(a, 75, this.List);
				::Wuxia.Events.addMastery(b, 75, this.List);
				::Wuxia.Events.addCompanyMastery(25, this.List);
			}
		});

		this.m.Screens.push({
			ID = "FullHurt",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "去抹点跌打药膏，下回留点分寸。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local a = _event.m.BroA;
				local b = _event.m.BroB;
				if (::Wuxia.Events.isAlive(a)) this.Characters.push(a.getImagePath());
				if (::Wuxia.Events.isAlive(b)) this.Characters.push(b.getImagePath());

				local victim = (::Math.rand(0, 1) == 0) ? a : b;
				local victor = (victim == a) ? b : a;
				local nameV = ::Wuxia.Events.fmtName(victim);
				local nameW = ::Wuxia.Events.fmtName(victor);

				this.Text = "[img]gfx/ui/events/wx_ev_11.png[/img]拆到第二十余合，两人都打出了真火，木棍扫过耳畔呼呼带风。" + nameW + "卖个空门诱敌，待" + nameV + "踏步抢入的刹那猛然沉肘反扫，桑木梢啪地抽在" + nameV + "肋侧，直把硬木震裂出一条长缝。\n\n" + nameV + "闷哼一声踉跄半步，朝草窠里啐了口带血丝的唾沫，却咧嘴笑道：『好阴毒的暗劲！这一记算我记在骨头上了，下回上阵绝不再露这个空当。』一旁众人倒吸凉气，却也从这番真刀真枪的破招里各自瞧出了门道。";

				::Wuxia.Events.addMastery(a, 75, this.List);
				::Wuxia.Events.addMastery(b, 75, this.List);
				::Wuxia.Events.addCompanyMastery(25, this.List);
				::Wuxia.Events.applyLightHurt(victim, 0.14, this.List);
			}
		});

		this.m.Screens.push({
			ID = "SlowCheck",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "细水长流，方能炼真功。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local a = _event.m.BroA;
				local b = _event.m.BroB;
				if (::Wuxia.Events.isAlive(a)) this.Characters.push(a.getImagePath());
				if (::Wuxia.Events.isAlive(b)) this.Characters.push(b.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(a);
				local nameB = ::Wuxia.Events.fmtName(b);
				local manA = ::Wuxia.Events.pickManualName(a);
				local manB = ::Wuxia.Events.pickManualName(b);

				this.Text = "[img]gfx/ui/events/wx_ev_11.png[/img]你抬手压了压声势，嘱咐二人只论架势、不拼蛮劲。" + nameA + "放慢出招，将" + manA + "的起手转折一一拆开；" + nameB + "则用" + manB + "的步法贴身封堵，每遇滞涩处便停棍细抠，连肩胛沉几分、脚跟碾哪块土都掰扯得清清楚楚。\n\n暮鼓声般低沉的晚风吹过火堆，两人收棍抱拳，眉眼间尽是豁然开朗的快意。";

				::Wuxia.Events.addMastery(a, 45, this.List);
				::Wuxia.Events.addMastery(b, 45, this.List);
				::Wuxia.Events.addMood(a, 0.75, "黄昏细拆招式颇有所得", this.List);
				::Wuxia.Events.addMood(b, 0.75, "黄昏细拆招式颇有所得", this.List);
			}
		});

		this.m.Screens.push({
			ID = "CallOff",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "养足气力要紧。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local a = _event.m.BroA;
				local b = _event.m.BroB;
				if (::Wuxia.Events.isAlive(a)) this.Characters.push(a.getImagePath());
				if (::Wuxia.Events.isAlive(b)) this.Characters.push(b.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(a);
				local nameB = ::Wuxia.Events.fmtName(b);

				this.Text = "[img]gfx/ui/events/wx_ev_11.png[/img]你敲了敲锅沿，把蠢蠢欲动的两人叫回火堆旁。" + nameA + "嘀咕两句，到底还是把桑木棍丢进了柴垛，同" + nameB + "蹲在风口里捧着热汤啃起干饼——江湖路滑，少受一回无谓的磕碰，总比逞一时意气强。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		local a = ::Wuxia.Events.findBroWithManual(null);
		if (a == null) return;
		local b = ::Wuxia.Events.findBroWithManual(null, a);
		if (b == null) return;

		this.m.BroA = a;
		this.m.BroB = b;
		this.m.Score = 14;
	}

	function onClear()
	{
		this.m.BroA = null;
		this.m.BroB = null;
	}
});
