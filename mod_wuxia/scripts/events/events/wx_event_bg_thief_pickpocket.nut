// Batch E2 Event 21: 妙手反扒（梁上飞贼/老千/捕快/内侍在街巷当场擒住割包小贼）

this.wx_event_bg_thief_pickpocket <- this.inherit("scripts/events/event", {
	m = {
		Catcher = null
	},

	function create()
	{
		this.m.ID = "event.wx_bg_thief_pickpocket";
		this.m.Title = "妙手反扒";
		this.m.Cooldown = 34.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "「松手吧，买俩热肉包子塞他怀里，叫他滚远些别再摸刀客的腰包。」",
					function getResult( _event ) { return "FeedKid"; }
				},
				{
					Text = "「小崽子背后必有贼窝！拎到暗巷拧胳膊，逼他吐出同伙藏银的坑！」",
					function getResult( _event ) { return "ShakeDown"; }
				},
				{
					Text = "「扭送县衙见官，挣个官面上的清白名声和赏钱。」",
					function getResult( _event ) { return "Yamen"; }
				}
			],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Catcher;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "那名眼尖的弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_28.png[/img]西门外菜市口人肩摩肩，两辆运萝卜的独轮车刚把巷口挤住，一双枯瘦如鸡爪的小手便借着推搡贴上了你的钱袋系绳。你尚未来得及低头，身侧 " + bName + " 已如苍鹭啄鱼般探掌一扣，生生攥住那只细手腕往上一翻！\n\n「当啷」一声，半片磨得雪亮的竹叶铁片掉在青石板上。被拎在半空的是个十二三岁的黑瘦小乞儿，破棉袄漏着黑絮，肋骨根根可见。他自知逃不脱，却死咬着嘴唇不肯求饶，一双野猫似的眼睛滴溜溜打量着你们腰间的钢刀。";
			}
		});

		this.m.Screens.push({
			ID = "FeedKid",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "市井草莽里也有知恩图报的。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Catcher;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addSectRel("gaibang", 14, this.List);
				::Wuxia.Events.addReputation(0, 5, this.List);

				local lootDesc = "";
				if (::Math.rand(0, 1) == 0)
				{
					::Wuxia.Events.addMoney(160, this.List);
					lootDesc = "果真在发霉的瓦罐底掏出一包一百六十两赃银";
				}
				else
				{
					::Wuxia.Events.giveManual("common", this.List);
					lootDesc = "竟在破瓦罐里摸出一本沾着油星的实用武学抄本";
				}

				this.Text = "[img]gfx/ui/events/wx_ev_28.png[/img]" + bName + " 哂笑一声松开手，顺路从街角蒸笼买来两个烫手的肉包子塞进小孩怀里，顺手弹了他一个脑瓜崩：『下次长点眼，摸到煞神身上可没人给你买包子。』\n\n小乞儿三口吞下半个包子，抹抹油嘴压低声音飞快道：『爷讲究！前街那姓赵的黑心班头昨夜喝花酒醉晕了，把一包赃物藏在破土地庙供桌底下的烂瓦罐里，原本打算明早去取——小的不敢吞，孝敬诸位大爷！』说罢泥鳅般钻入人群。傍晚你们顺道摸去破庙一瞧，" + lootDesc + "，连城隍庙口几个丐帮老乞丐见了你们也破天荒抱了抱拳。";
			}
		});

		this.m.Screens.push({
			ID = "ShakeDown",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "拿钱走人，莫在城里久留。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Catcher;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(220, this.List);
				::Wuxia.Events.addSectRel("gaibang", -12, this.List);
				::Wuxia.Events.addReputation(0, -4, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_28.png[/img]" + bName + " 把小贼拖进臭气熏天的死胡同，反剪双臂略施巧劲，那小子疼得眼泪混着泥灰往下淌，没撑过十息便招出同伙藏赃的去处。\n\n你们顺着他指的荒窑墙洞撬开半块活砖，果然抄出二百二十两剪边碎银与散钱。只是回街时，巷尾墙根下两个拎着竹杖的破衣老汉冷冷扫了你们一眼，转身便消失在茶摊后头——这笔梁子怕是记在当地丐帮分舵账上了。";
			}
		});

		this.m.Screens.push({
			ID = "Yamen",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "领完花红，出衙办正事。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Catcher;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addReputation(20, 0, this.List);
				::Wuxia.Events.addMoney(120, this.List);
				::Wuxia.Events.addMood(bro, 0.5, "拿贼领赏，干脆利落", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_28.png[/img]" + bName + " 像拎小鸡仔似的把扒手送到了县衙班房。当值捕头一见这小子竟是近月连割七名布商荷包的惯犯，顿时眉开眼笑，痛痛快快支出一百二十两赏银，连夸你们这支江湖人马守规矩、替官府分了忧。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Catcher = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (!::Wuxia.Events.isNearTown(3)) return;

		local bro = ::Wuxia.Events.findByBackgrounds([
			"background.thief",
			"background.gambler",
			"background.manhunter",
			"background.eunuch"
		]);
		if (bro == null) return;

		this.m.Catcher = bro;
		this.m.Score = 17;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Catcher = null;
	}
});
