// Batch E1 Event 01: 破戒劝架（行脚僧/武僧与火爆汉子在破庙因口粮起争执）

this.wx_event_camp_monk_brawl <- this.inherit("scripts/events/event", {
	m = {
		BroA = null,
		BroB = null
	},

	function create()
	{
		this.m.ID = "event.wx_camp_monk_brawl";
		this.m.Title = "破戒劝架";
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
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);
				local shortA = ::Wuxia.Events.shortName(_event.m.BroA);

				this.Text = "[img]gfx/ui/events/wx_ev_15.png[/img]连绵秋雨顺着漏风的关帝庙檐角滴答砸在青砖上，柴烟呛得人睁不开眼。" + nameB + " 灌了半葫芦浑浊烧刀子，正拎着一根啃了一半的咸肋骨满庙骂娘，嫌火头分给他的那块干牛肉少了二两秤。他一巴掌拍翻了缺口瓦钵，滚烫的菜汤劈头盖脸泼了出去，不偏不倚全淋在盘膝烤鞋的 " + nameA + " 那身百衲旧袍上。\n\n满屋弟兄顿时噤了声，有人下意识往腰间刀柄摸去。谁知 " + nameA + " 既没破口回骂，也没急着念阿弥陀佛，只是慢条斯理放下手里那只裂了缝的木钵，拿袖口揩了揩下巴上的油星，指节捏得嘎巴作响：\n\n『出家人本不该动无明火——可经上也说过，菩萨低眉是度善人，金刚怒目才好敲打顽石。施主这身酒气太重，不如让贫僧替你松松皮肉？』\n\n" + nameB + " 闻言眼珠子瞪得像铜铃，扯开襟口露出胸前几道旧刀疤，吐了口浓痰在手心里，眼看就要把供桌掀翻。";

				this.Options = [
					{
						Text = "都给我住手，让 " + shortA + " 念几句经把火气压下去。",
						function getResult( _event ) { return "Mediate"; }
					},
					{
						Text = "别砸了遮风挡雨的破庙——画个圈，脱了铁甲赤手打三合！",
						function getResult( _event ) { return "Spar"; }
					},
					{
						Text = "这混账确实欠收拾——大和尚，替我教训教训他！",
						function getResult( _event ) { return "MonkScrap"; }
					}
				];
			}
		});

		this.m.Screens.push({
			ID = "Mediate",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "相安无事便好。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);

				::Wuxia.Events.addMood(_event.m.BroA, 1.0, "化干戈为玉帛", this.List);
				::Wuxia.Events.addMood(_event.m.BroB, 0.75, "消了酒火没惹大祸", this.List);
				::Wuxia.Events.addStat(_event.m.BroA, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
				::Wuxia.Events.addMastery(_event.m.BroA, 35, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_15.png[/img]听你发话，" + nameA + " 垂下眼睑轻吐出一口长气，竟伸出两根粗厚指头径直拈起滚烫的瓦钵沿放正，皮肉连个水泡都没起。他盯着 " + nameB + " 淡淡一笑：『刀口舔血的弟兄，明日还不知是谁替谁收尸，为二两牛肉伤了和气，传出去叫阎王爷笑掉大牙。』\n\n那几句话说得不轻不重，倒把 " + nameB + " 满脑子酒意浇醒了大半。汉子搓了搓胡茬，闷声弯腰捡起木勺，又从怀里摸出半块烤焦的干饼塞进僧人手里，一场风波总算压在了冷雨里。";
			}
		});

		this.m.Screens.push({
			ID = "Spar",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "打出汗来，倒比喝闷酒强。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);

				::Wuxia.Events.applyLightHurt(_event.m.BroB, 0.12, this.List);
				::Wuxia.Events.addMastery(_event.m.BroA, 55, this.List);
				::Wuxia.Events.addMastery(_event.m.BroB, 55, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "看了一场痛快的赤手较量", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_15.png[/img]你拿烧黑的木炭头在泥地上画了个丈许方圆，立下铁规矩：不许抄家伙、不许抠眼珠子、三合见分晓。" + nameB + " 吼了一声如疯牛般沉肩撞进圈里，一记摆拳带着酒风直奔面门；" + nameA + " 不闪不避，脚下扎死四平马步，双臂硬生生架住来拳，顺势一记铁靠把大汉顶得连退三步，后背撞碎了半截腐朽供桌。\n\n三合过后两人都喘得像拉风箱，嘴角挂了血丝却偏偏瞪着眼笑出声来。围观的弟兄拍腿叫好，先前那点阴郁烦闷一扫而空，两人也从彼此拳脚里品出了几分真火候。";
			}
		});

		this.m.Screens.push({
			ID = "MonkScrap",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "往后看他还敢不敢借酒撒疯。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);

				::Wuxia.Events.applyLightHurt(_event.m.BroB, 0.18, this.List);
				::Wuxia.Events.addStat(_event.m.BroA, "MeleeSkill", 1, "武艺", "ui/icons/melee_skill.png", this.List);
				::Wuxia.Events.addMood(_event.m.BroA, 1.25, "难得松快了一回筋骨", this.List);
				::Wuxia.Events.addMood(_event.m.BroB, -0.5, "被僧人一肘放翻颜面挂不住", this.List);
				::Wuxia.Events.addMastery(_event.m.BroB, 40, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_15.png[/img]得了你的准信，" + nameA + " 脖子歪得咔吧一声，低声念了句『酒肉穿肠过，拳脚照脸来，罪过罪过』，竟抢先一步踏进 " + nameB + " 的中门！汉子挥出的老拳还没砸实，肋下已结结实实挨了一记沉肘，整个人腾空仰翻，一头栽进了墙角潮湿的干草堆里，惊得两只耗子吱吱乱窜。\n\n满庙轰然大笑。" + nameB + " 揉着发紫的颧骨爬起来，酒醒得一干二净，虽满脸挂不住，望着僧人那双铁钳似的手腕却不得不服软拱了拱手。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		this.m.BroA = null;
		this.m.BroB = null;

		local monk = ::Wuxia.Events.findByBackgrounds([
			"background.monk",
			"background.crusader",
			"background.flagellant",
			"background.converted_crusader"
		]);
		if (monk == null) return;

		local rowdy = ::Wuxia.Events.findByBackgrounds([
			"background.brawler",
			"background.raider",
			"background.butcher",
			"background.barbarian",
			"background.gladiator"
		], monk);
		if (rowdy == null) return;

		this.m.BroA = monk;
		this.m.BroB = rowdy;
		this.m.Score = 16;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.BroA))
		{
			this.m.BroA = ::Wuxia.Events.findByBackgrounds([
				"background.monk",
				"background.crusader",
				"background.flagellant",
				"background.converted_crusader"
			]);
		}
		if (!::Wuxia.Events.isAlive(this.m.BroB))
		{
			this.m.BroB = ::Wuxia.Events.findByBackgrounds([
				"background.brawler",
				"background.raider",
				"background.butcher",
				"background.barbarian",
				"background.gladiator"
			], this.m.BroA);
		}
	}

	function onPrepareVariables( _vars )
	{
		_vars.push(["monk", ::Wuxia.Events.shortName(this.m.BroA)]);
		_vars.push(["rowdy", ::Wuxia.Events.shortName(this.m.BroB)]);
	}

	function onClear()
	{
		this.m.BroA = null;
		this.m.BroB = null;
	}
});
