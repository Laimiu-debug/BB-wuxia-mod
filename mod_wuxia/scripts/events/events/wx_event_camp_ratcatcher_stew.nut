// Batch E1 Event 08: 地窖野味锅（捕鼠人/乞丐/流浪客熬制一锅来历可疑却奇香的杂烩锅，验方医者可辨毒理）

this.wx_event_camp_ratcatcher_stew <- this.inherit("scripts/events/event", {
	m = {
		BroA = null,
		BroB = null,
		BroC = null
	},

	function create()
	{
		this.m.ID = "event.wx_camp_ratcatcher_stew";
		this.m.Title = "地窖野味锅";
		this.m.Cooldown = 38.0 * this.World.getTime().SecondsPerDay;

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

				local docLine = "";
				if (::Wuxia.Events.isAlive(_event.m.BroC))
				{
					docLine = "\n\n旁边的 " + ::Wuxia.Events.fmtName(_event.m.BroC) + " 倒丝毫不嫌晦气，正摸出一把细长银镊，饶有兴致地盯着锅里翻滚的汤花。";
				}

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]野营土灶上咕嘟咕嘟滚着一口黑铁大锅，飘出一股极其霸道的辛香——野蒜、老姜、焦猪油里偏偏还混着一丝说不清道不明的土腥气。" + nameA + " 正拿半截断矛杆搅得起劲，冷不丁从浓汤里捞起几块白嫩带骨的细肉：论个头绝不是猪羊，论骨节又实在不像山兔。\n\n" + nameB + " 凑近锅沿盯了半晌，喉结艰难地上下滚了滚，声音发飘地问道：『……敢问这几块嫩肉，生前是不是生着四条短腿、两条尖嘴长须？』\n\n" + nameA + " 拿小臂一抹鼻尖，露出一口黄牙得意大笑：『客官莫问出身！山谷粮仓边抓的胖田鼠，吃的全是陈谷草根，比城里酒楼的糟鸭还嫩滑！我剥皮去脏焯了三遍水，又扔进去三大把辣蓼草，神仙闻了都得咽唾沫！』" + docLine;

				this.Options = [];
				if (::Wuxia.Events.isAlive(_event.m.BroC))
				{
					local shortC = ::Wuxia.Events.shortName(_event.m.BroC);
					this.Options.push({
						Text = "先让 " + shortC + " 验验毒理脏腑，确认无瘟疫再动勺！",
						function getResult( _event ) { return "AnatomistTest"; }
					});
				}
				this.Options.push({
					Text = "走江湖讲究什么斯文！趁热盛碗尝鲜，剩下的烩干粮装袋！",
					function getResult( _event ) { return "EatStew"; }
				});
				this.Options.push({
					Text = "把这锅鬼东西给我倒沟里去！真吃出瘟病来谁兜得住？",
					function getResult( _event ) { return "DumpPot"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "AnatomistTest",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "郎中开了口，闭着眼也算吃得踏实。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroC)) this.Characters.push(_event.m.BroC.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameC = ::Wuxia.Events.fmtName(_event.m.BroC);

				::Wuxia.Events.giveFood("scripts/items/supplies/ground_grains_item", "祛湿杂烩肉汤干粮", this.List);
				::Wuxia.Events.addSupplies(0, 6, 0, this.List);
				::Wuxia.Events.addMood(_event.m.BroA, 1.25, "手艺得了郎中亲口背书", this.List);
				::Wuxia.Events.addMood(_event.m.BroC, 1.0, "考证了一味奇特行军药膳", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]" + nameC + " 用银镊夹出一片嫩肉，就着火光细察肌理，又滴了半勺汤汁在野葱白上揉搓片刻，竟露出一脸近乎痴迷的赞叹：\n\n『确系山野硕鼠与石蛙杂烩，肝胆淋巴已摘除净尽，绝无疫腐之毒；反倒因投了辣蓼、野姜与苍术，极合湿冷行军驱瘴暖胃之效！』\n\n众人虽仍觉得后脊梁发凉，听见医者这般一本正经的背书，倒也壮着胆子喝了个底朝天。" + nameA + " 得意得下巴都快翘上天，又把采剩的驱湿草药全交给了 " + nameC + " 充作伤药。";
			}
		});

		this.m.Screens.push({
			ID = "EatStew",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "只要不问锅里是啥，味道其实还真不赖。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);

				::Wuxia.Events.giveFood("scripts/items/supplies/ground_grains_item", "杂烩肉汤干粮", this.List);
				::Wuxia.Events.addMood(_event.m.BroA, 1.25, "秘制野味锅大受东家赏识", this.List);
				::Wuxia.Events.addMood(_event.m.BroB, -0.75, "咬到了极其可疑的细小趾骨", this.List);

				local other = ::Wuxia.Events.findRandomBro([_event.m.BroA, _event.m.BroB]);
				if (::Wuxia.Events.isAlive(other))
					::Wuxia.Events.addMood(other, 0.75, "管它是啥肉，热乎顶饱就行", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]你带头盛了一碗呼噜呼噜喝下去——抛开那些细得离谱的肋骨不谈，辛辣滚烫的肉汤顺着食道滑进空腹，竟意外鲜美得让人冒汗。几个饿红了眼的糙汉立刻蜂拥而上，把余汤泡了粗麦干粮装满一整袋。\n\n唯有 " + nameB + " 强撑着咬了一口，咔嚓一声吐出半截形迹可疑的细小指节，耳根子瞬间绿得像发了霉，蹲在树后嚼了半个时辰松针才勉强压住反胃。" + nameA + " 却乐呵呵收起铁锅，连称这群人有口福。";
			}
		});

		this.m.Screens.push({
			ID = "DumpPot",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "宁可啃冷干饼，也别拿肚皮赌命。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);

				::Wuxia.Events.addMood(_event.m.BroA, -1.0, "苦心熬好的野味锅被倒进泥沟", this.List);
				::Wuxia.Events.addMood(_event.m.BroB, 1.0, "逃过一顿令人毛骨悚然的晚饭", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]哗啦一声白雾腾空，一整锅浓汤全泼进了路旁排水沟里，没过片刻便引来两只黑老鸹，为了争夺一条细长灰尾在泥水里啄得羽毛乱飞。\n\n" + nameA + " 气呼呼往火堆里踢了块土坷垃，嘀咕着『荒年饿死的时候看你们挑不挑嘴』；" + nameB + " 却长长舒出一口气，神情活像刚从法场刀下捡回一条命。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		this.m.BroA = null;
		this.m.BroB = null;
		this.m.BroC = null;

		local cook = ::Wuxia.Events.findByBackgrounds([
			"background.ratcatcher",
			"background.beggar",
			"background.vagabond"
		]);
		if (cook == null) return;

		local taster = ::Wuxia.Events.findByBackgrounds([
			"background.adventurous_noble",
			"background.disowned_noble",
			"background.bastard",
			"background.historian"
		], cook);
		if (taster == null) taster = ::Wuxia.Events.findRandomBro(cook);
		if (taster == null) return;

		local doc = ::Wuxia.Events.findByBackgrounds(["background.anatomist"], [cook, taster]);

		this.m.BroA = cook;
		this.m.BroB = taster;
		this.m.BroC = doc;
		this.m.Score = 16;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.BroA))
		{
			this.m.BroA = ::Wuxia.Events.findByBackgrounds([
				"background.ratcatcher",
				"background.beggar",
				"background.vagabond"
			]);
		}
		if (!::Wuxia.Events.isAlive(this.m.BroB))
		{
			this.m.BroB = ::Wuxia.Events.findByBackgrounds([
				"background.adventurous_noble",
				"background.disowned_noble",
				"background.bastard",
				"background.historian"
			], this.m.BroA);
			if (this.m.BroB == null) this.m.BroB = ::Wuxia.Events.findRandomBro(this.m.BroA);
		}
		if (this.m.BroC != null && !::Wuxia.Events.isAlive(this.m.BroC))
			this.m.BroC = ::Wuxia.Events.findByBackgrounds(["background.anatomist"], [this.m.BroA, this.m.BroB]);
	}

	function onPrepareVariables( _vars )
	{
		_vars.push(["cook", ::Wuxia.Events.shortName(this.m.BroA)]);
		_vars.push(["taster", ::Wuxia.Events.shortName(this.m.BroB)]);
	}

	function onClear()
	{
		this.m.BroA = null;
		this.m.BroB = null;
		this.m.BroC = null;
	}
});
