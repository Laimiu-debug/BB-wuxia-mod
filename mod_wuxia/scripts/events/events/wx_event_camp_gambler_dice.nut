// Batch E1 Event 06: 营火骰局（赌坊老千在火堆旁设局疑似灌铅，捕快/武僧/守誓侠客可当场拿赃）

this.wx_event_camp_gambler_dice <- this.inherit("scripts/events/event", {
	m = {
		BroA = null,
		BroB = null,
		BroC = null
	},

	function create()
	{
		this.m.ID = "event.wx_camp_gambler_dice";
		this.m.Title = "营火骰局";
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
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);

				local watcherLine = "";
				if (::Wuxia.Events.isAlive(_event.m.BroC))
				{
					watcherLine = "\n\n唯独站在外圈抱臂冷看的 " + ::Wuxia.Events.fmtName(_event.m.BroC) + " 始终没出声，一双利眼像盯田鼠的苍鹰般死死锁在 " + nameA + " 那截松垮垮的左袖口上，冲你极轻微地递了个眼色。";
				}

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]半营人都挤在一只翻扣过来的旧骡鞍前，一口破铜盔里堆着叮当作响的碎银角子与铜板。" + nameA + " 拿一只缺口粗瓷碗摇着三颗泛黄牛骨骰，笑得活像偷进了鸡窝的老狐狸；对面的 " + nameB + " 脑门青筋直跳、脸色黑得赛过锅底——连着三把『豹子通杀』，他连押箱底的铜带扣都快输干净了。\n\n人群里有人小声嘀咕：正常骨骰落碗清脆利落，这三颗砸下去却闷声闷气，透着股说不出的沉劲。" + nameA + " 耳尖极灵，立刻干笑两声拍着胸脯赌咒发誓说纯靠手气旺，偏巧左手小指不动声色往袖筒里缩了半寸。" + watcherLine;

				this.Options = [];
				if (::Wuxia.Events.isAlive(_event.m.BroC))
				{
					local shortC = ::Wuxia.Events.shortName(_event.m.BroC);
					this.Options.push({
						Text = "给 " + shortC + " 递个暗号，当场按腕抓他个灌铅老千！",
						function getResult( _event ) { return "CaughtCold"; }
					});
				}
				this.Options.push({
					Text = "营中私赌按规矩充公！桌上的银钱全数收了给全队买酒！",
					function getResult( _event ) { return "Confiscate"; }
				});
				this.Options.push({
					Text = "手气真有这么旺？我押 180 两，当面换碗换骰赌一把大的！",
					function getResult( _event )
					{
						if (::World.Assets.getMoney() < 180) return "NoMoney";
						if (::Math.rand(1, 2) == 1) return "GambleWin";
						return "GambleLose";
					}
				});
				this.Options.push({
					Text = "一脚踢翻骡鞍散局！谁敢再在营里耍钱，扣三天口粮！",
					function getResult( _event ) { return "CrackDown"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "CaughtCold",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "敢在自家碗里耍千，活该吃瘪！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroC)) this.Characters.push(_event.m.BroC.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);
				local nameC = ::Wuxia.Events.fmtName(_event.m.BroC);

				::Wuxia.Events.addMoney(140, this.List);
				::Wuxia.Events.addMood(_event.m.BroB, 1.5, "识破老千讨回血汗钱", this.List);
				::Wuxia.Events.addMood(_event.m.BroC, 1.0, "明察秋毫当场拿赃", this.List);
				::Wuxia.Events.addMood(_event.m.BroA, -1.0, "灌铅出千被当众拿住", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]你微微颔首，" + nameC + " 身形如铁塔般骤然跨前一步，铁钳似的五指稳稳扣住 " + nameA + " 的左腕脉门，另一手拔出剑柄重重一砸——瓷碗崩裂，三颗骨骰应声粉碎，几粒亮晶晶的细铅珠滚得满鞍子都是！\n\n营地霎时炸了锅。" + nameA + " 脸白得像刚刷过灰的土墙，赔着笑脸不仅把赢走的银钱如数退还给 " + nameB + "，还乖乖掏出 140 两『赔罪酒资』交进公账，方才躲过一顿乱拳。";
			}
		});

		this.m.Screens.push({
			ID = "Confiscate",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "独乐乐不如众乐乐。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);

				::Wuxia.Events.addMoney(110, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "充公赌资添了全队酒水", this.List);
				::Wuxia.Events.addMood(_event.m.BroA, -0.75, "到手的彩头被充了公", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]你抢在 " + nameA + " 缩手前一把抄起那口装满碎银的破铜盔。他张口想辩两句，撞上你冷冰冰的眼神，只得挤出个比哭还难看的干笑，默默把手背到身后。\n\n你随手抓了一小把散钱丢回给眼眶发红的 " + nameB + "，余下银两全数归公，宣布下回进镇给大伙买两坛好烧酒润润嗓子，营里登时响起一片哄笑喝彩。";
			}
		});

		this.m.Screens.push({
			ID = "GambleWin",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "敢在东家面前耍滑头，你还嫩了点！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addMoney(180, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "东家豪赌赢翻了老千", this.List);
				::Wuxia.Events.addMood(_event.m.BroA, -0.75, "赔了夫人又折兵", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]你啪地把银袋拍在骡鞍上，偏不碰他的旧瓷碗，当众换了自己的铁饭缸和三颗新木骰。" + nameA + " 笑容顿时僵在脸上，硬着头皮摇出个寒酸的四点；轮到你倒扣铁缸，啪嗒一声竟是清一色大红六！\n\n四周弟兄吹起口哨大声叫好。你笑吟吟把赢来的 180 两收进怀里，" + nameA + " 肉痛得直抽冷气，连称东家吉星高照。";
			}
		});

		this.m.Screens.push({
			ID = "GambleLose",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "愿赌服输，拿去吧！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addMoney(-180, this.List);
				::Wuxia.Events.addMood(_event.m.BroA, 1.5, "连东家的银子都赢了个痛快", this.List);
				::Wuxia.Events.addCompanyMood(0.5, "瞧见东家吃瘪满营乐不可支", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]纵然当众换了铁饭缸与新木骰，今夜的霉运偏偏缠上了你的指头。那颗临尾打转的骰子撞在鞍沿皮带上诡异地一翻，硬生生替 " + nameA + " 凑出了三颗五点！\n\n" + nameA + " 乐得眉开眼笑，装模作样朝你打了个长揖，喜滋滋将 180 两银子拢入袖中；旁边看热闹的弟兄们笑得前仰后合，倒把原本紧绷的火药味全冲散了。";
			}
		});

		this.m.Screens.push({
			ID = "CrackDown",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "规矩立住了，省得日后因财反目。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);

				::Wuxia.Events.addCompanyMood(-0.5, "营中严禁赌博扫了兴致", this.List);
				::Wuxia.Events.addMood(_event.m.BroB, 0.75, "保住了剩下的卖命钱", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]你铁青着脸一脚踹翻骡鞍，骨骰与铜钱劈里啪啦滚进泥草丛里。火堆旁霎时鸦雀无声，众人默默各自散开擦兵器去了。虽扫了不少人的兴，可 " + nameB + " 暗地里松了老大一口气，好歹没把下半年的棺材本全输光。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "换个法子处置。", function getResult( _event ) { return "A"; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]你往怀里一掏，竟凑不出 180 两现银下桌押注，只好另作打算。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		this.m.BroA = null;
		this.m.BroB = null;
		this.m.BroC = null;

		local gambler = ::Wuxia.Events.findByBackgrounds([
			"background.gambler",
			"background.pimp",
			"background.thief"
		]);
		if (gambler == null) return;

		local mark = ::Wuxia.Events.findRandomBro(gambler);
		if (mark == null) return;

		local enforcer = ::Wuxia.Events.findByBackgrounds([
			"background.manhunter",
			"background.monk",
			"background.oathtaker"
		], [gambler, mark]);

		this.m.BroA = gambler;
		this.m.BroB = mark;
		this.m.BroC = enforcer;
		this.m.Score = 18;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.BroA))
		{
			this.m.BroA = ::Wuxia.Events.findByBackgrounds([
				"background.gambler",
				"background.pimp",
				"background.thief"
			]);
		}
		if (!::Wuxia.Events.isAlive(this.m.BroB))
			this.m.BroB = ::Wuxia.Events.findRandomBro(this.m.BroA);
		if (this.m.BroC != null && !::Wuxia.Events.isAlive(this.m.BroC))
		{
			this.m.BroC = ::Wuxia.Events.findByBackgrounds([
				"background.manhunter",
				"background.monk",
				"background.oathtaker"
			], [this.m.BroA, this.m.BroB]);
		}
	}

	function onPrepareVariables( _vars )
	{
		_vars.push(["gambler", ::Wuxia.Events.shortName(this.m.BroA)]);
		_vars.push(["mark", ::Wuxia.Events.shortName(this.m.BroB)]);
	}

	function onClear()
	{
		this.m.BroA = null;
		this.m.BroB = null;
		this.m.BroC = null;
	}
});
