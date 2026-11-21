// Batch E1 Event 09: 寒门与朱门（泥坯打尖小店里，世家子弟与泥腿子因吃相起口角）

this.wx_event_camp_noble_peasant <- this.inherit("scripts/events/event", {
	m = {
		BroA = null,
		BroB = null
	},

	function create()
	{
		this.m.ID = "event.wx_camp_noble_peasant";
		this.m.Title = "寒门与朱门";
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
				local shortB = ::Wuxia.Events.shortName(_event.m.BroB);

				this.Text = "[img]gfx/ui/events/wx_ev_26.png[/img]官道旁的泥坯打尖小店飘着一股陈醋与湿稻草味，全店只有一张晃悠悠的榆木长桌和一盆酸萝卜咸菜。" + nameB + " 赶了一天泥路饿极了，伸出指甲缝还嵌着黑泥的大手就往公盆里捞，顺口把指头上的菜汤唆得山响。\n\n长凳对面，" + nameA + " 轻轻放下竹箸，两指捏着洗得发白却仍讲究纹样的旧绸袖口，慢条斯理掸掉一滴溅上去的菜汁，嘴角扯出半寸冷笑：『先父庄子后院养的槽头猪，倒还知道等食槽倒稳了再拱。』\n\n话音未落，条凳在夯土地上刺耳地向后一划。" + nameB + " 脖子粗红如猪肝，指节咔咔作响：『少爷既这么金贵，何苦落魄到跟咱们泥腿子在一口锅里刨食？真躺进乱葬岗，你血管里淌出来的血难不成比咱的香出二两？』\n\n两人手都按在了腰间，吓得瘸腿店掌柜一缩头躲到了腌菜大缸后头。";

				this.Options = [
					{
						Text = "把两人的碗推到一起，各斟半碗最辣的浑酒，喝干了再开口！",
						function getResult( _event ) { return "ShareBowl"; }
					},
					{
						Text = "别掀人家穷掌柜的饭桌——滚到院外烂泥地里摔一跤，谁服算谁输！",
						function getResult( _event ) { return "MudWrestle"; }
					},
					{
						Text = "出门在外总得讲点体面规矩，让 " + shortB + " 洗干净爪子再上桌。",
						function getResult( _event ) { return "BackNoble"; }
					}
				];
			}
		});

		this.m.Screens.push({
			ID = "ShareBowl",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "江湖路上，命拴在一根绳上。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);

				::Wuxia.Events.addMood(_event.m.BroA, 1.0, "放下身段同饮一碗烈酒", this.List);
				::Wuxia.Events.addMood(_event.m.BroB, 1.0, "咽下怨气结了同袍情分", this.List);
				::Wuxia.Events.addStat(_event.m.BroA, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
				::Wuxia.Events.addStat(_event.m.BroB, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_26.png[/img]你拎过一只豁口土酒壶砰地墩在桌心，给一只粗瓷大碗倒满呛喉咙的浑浊酸烧酒，冷声道：『既进了这支队伍，同吃一锅糙饭，便是同扛一条性命。谁嫌谁脏，今夜自去牛棚抱草睡！』\n\n" + nameA + " 盯着那缺口碗沿足足沉默了三息，忽地端起碗仰头灌下大半，眼皮都没眨一下，啪地推到对面。" + nameB + " 愣了愣，咧嘴恶狠狠一仰脖将余酒喝得滴水不剩，拿袖口狠抹嘴巴：『成！算你小子骨头里没长霉，往后背交给我了！』";
			}
		});

		this.m.Screens.push({
			ID = "MudWrestle",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "泥水滚一回，谁也别装体面人。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);

				::Wuxia.Events.applyLightHurt(_event.m.BroA, 0.10, this.List);
				::Wuxia.Events.applyLightHurt(_event.m.BroB, 0.10, this.List);
				::Wuxia.Events.addMastery(_event.m.BroA, 45, this.List);
				::Wuxia.Events.addMastery(_event.m.BroB, 45, this.List);
				::Wuxia.Events.addMood(_event.m.BroA, 0.75, "泥地里打出了几分真交情", this.List);
				::Wuxia.Events.addMood(_event.m.BroB, 0.75, "泥地里打出了几分真交情", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_26.png[/img]半盏茶后，院外积水的黄泥地里已滚作两尊分不清眉眼的泥菩萨，廊檐下挤满起哄吹口哨的弟兄。" + nameA + " 那件宝贝绸衣早扯成了布条，可几手家传小擒拿刁钻毒辣，扣得 " + nameB + " 嗷嗷直叫；" + nameB + " 挨了两肘子却硬靠一身蛮力把少爷拦腰抱起，双双砸进水坑溅起三尺泥花。\n\n等你让人把这对活宝拉开时，两人一边往外吐泥沫子，一边看着对方狼狈模样忍不住哈哈大笑——世间化解门第怨气的法子千百种，最管用的还是互吃几记老拳。";
			}
		});

		this.m.Screens.push({
			ID = "BackNoble",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "吃顿饭而已，倒落了个冷场。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);

				::Wuxia.Events.addMood(_event.m.BroA, 1.0, "东家替自己撑了门面规矩", this.List);
				::Wuxia.Events.addMood(_event.m.BroB, -1.25, "受了朱门子弟与东家的冷眼", this.List);
				::Wuxia.Events.addMastery(_event.m.BroA, 30, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_26.png[/img]" + nameB + " 死死盯着你，牙关咬得咯吱作响，终究没敢顶撞，抓起两张冷荞麦饼便大步跨进雨帘里，蹲在驴棚檐下闷头干嚼。" + nameA + " 整了整衣襟重新执箸，神色颇为受用，只是满桌弟兄突然都埋头扒饭，屋里气氛比外头的秋雨还凉。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		this.m.BroA = null;
		this.m.BroB = null;

		local noble = ::Wuxia.Events.findByBackgrounds([
			"background.adventurous_noble",
			"background.disowned_noble",
			"background.bastard"
		]);
		if (noble == null) return;

		local peasant = ::Wuxia.Events.findByBackgrounds([
			"background.farmhand",
			"background.beggar",
			"background.miner",
			"background.daytaler",
			"background.refugee"
		], noble);
		if (peasant == null) return;

		this.m.BroA = noble;
		this.m.BroB = peasant;
		this.m.Score = 17;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.BroA))
		{
			this.m.BroA = ::Wuxia.Events.findByBackgrounds([
				"background.adventurous_noble",
				"background.disowned_noble",
				"background.bastard"
			]);
		}
		if (!::Wuxia.Events.isAlive(this.m.BroB))
		{
			this.m.BroB = ::Wuxia.Events.findByBackgrounds([
				"background.farmhand",
				"background.beggar",
				"background.miner",
				"background.daytaler",
				"background.refugee"
			], this.m.BroA);
		}
	}

	function onPrepareVariables( _vars )
	{
		_vars.push(["noble", ::Wuxia.Events.shortName(this.m.BroA)]);
		_vars.push(["peasant", ::Wuxia.Events.shortName(this.m.BroB)]);
	}

	function onClear()
	{
		this.m.BroA = null;
		this.m.BroB = null;
	}
});
