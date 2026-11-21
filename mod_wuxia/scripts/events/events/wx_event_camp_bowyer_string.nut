// Batch E1 Event 05: 削竹揉弦（制弓匠人趁雨歇削竹制箭、揉蜡上弦或刨制弓胚换银）

this.wx_event_camp_bowyer_string <- this.inherit("scripts/events/event", {
	m = {
		BroA = null,
		BroB = null
	},

	function create()
	{
		this.m.ID = "event.wx_camp_bowyer_string";
		this.m.Title = "削竹揉弦";
		this.m.Cooldown = 35.0 * this.World.getTime().SecondsPerDay;

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
				local partnerLine = ::Wuxia.Events.isAlive(_event.m.BroB)
					? ("\n\n" + ::Wuxia.Events.fmtName(_event.m.BroB) + " 蹲在木屑堆旁，单眼眯成一条缝，正举着一支刚粘好鹅羽的竹箭对着暮光看直不直，大拇指在箭杆重心处轻轻一掂，啧啧称赞。")
					: "";

				this.Text = "[img]gfx/ui/events/wx_ev_30.png[/img]山岚湿气最毁弓胶与旧弦。趁傍晚歇脚的工夫，" + nameA + " 在辎重车棚下支起一把简陋木马，将两里外风折崖柏与阴干老山毛竹剖成细条。弯月削刀推过，卷曲的刨花簌簌落地，散出一股淡淡的松脂清香，膝边还盘着几束刚浸过蜂蜡的熟牛筋与生丝合股弦。" + partnerLine + "\n\n" + nameA + " 吹掉眉梢沾着的竹末，抬头冲你扬了扬手里几根笔直坚韧的料子：\n\n『这批木竹纹路密实不走形，是可遇不可求的好胚。东家拿主意——是趁火炭没熄，全揉成新弦、削足重箭供营里备战，顺便校准手头准星；还是把多余直料粗刨成五张硬弓胚，过两日进集镇卖给乡团或山民换笔现银？』";

				this.Options = [
					{
						Text = "好料留着自家用！连夜揉弦削箭，顺带校一校射艺准头。",
						function getResult( _event ) { return "CraftAmmo"; }
					},
					{
						Text = "箭壶暂时不缺，粗刨成硬弓胚捆在车底，下个集镇换银子！",
						function getResult( _event ) { return "SellStaves"; }
					}
				];
			}
		});

		this.m.Screens.push({
			ID = "CraftAmmo",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "弦紧箭直，上阵才敢往死里放。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local target = ::Wuxia.Events.isAlive(_event.m.BroB) ? _event.m.BroB : _event.m.BroA;

				::Wuxia.Events.addSupplies(0, 0, 25, this.List);
				::Wuxia.Events.addMastery(target, 50, this.List);
				::Wuxia.Events.addStat(target, "RangedSkill", 1, "射艺", "ui/icons/ranged_skill.png", this.List);

				if (::Wuxia.Events.isAlive(_event.m.BroB))
				{
					local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);
					::Wuxia.Events.addMood(_event.m.BroB, 1.0, "得趁手新弦与重羽利箭", this.List);
					::Wuxia.Events.addMood(_event.m.BroA, 0.75, "匠艺得遇懂行之人", this.List);
					this.Text = "[img]gfx/ui/events/wx_ev_30.png[/img]炭盆温热了鱼鳔胶，" + nameA + " 将每一根新弦擦蜡拉直，绷在弓梢上轻轻一弹，发出清越如龙吟的嗡鸣；二十余支分量匀称的新箭也齐刷刷码进了干牛皮箭壶。\n\n趁天色未全黑，" + nameA + " 与 " + nameB + " 在营外四十步处钉了块破木牌，一个调磅数、一个试撒放，连射半个时辰，箭簇竟几乎全咬在巴掌大小的圆圈里。";
				}
				else
				{
					::Wuxia.Events.addMood(_event.m.BroA, 1.0, "亲手制出趁手新弦利箭", this.List);
					this.Text = "[img]gfx/ui/events/wx_ev_30.png[/img]炭盆温热了鱼鳔胶，" + nameA + " 一丝不苟给弓弩换上涂满蜂蜡的新丝筋弦，又将削直绑羽的新箭一一试过重心，整齐归入弹药箱。趁着暮色他亲自往四十步外的枯树桩连放三箭，箭尾齐齐震颤如蜂，连自己也忍不住满意地咧了咧嘴。";
				}
			}
		});

		this.m.Screens.push({
			ID = "SellStaves",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "手艺换铜钱，行军少操一份心。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addMoney(190, this.List);
				::Wuxia.Events.addMood(_event.m.BroA, 0.5, "山野竹木换回实在纹银", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_30.png[/img]" + nameA + " 去皮修节、烤火定型，又拿熔化的羊油仔细封住两头截口防裂，把五根笔挺匀称的粗弓胚牢牢绑在马车底盘阴干。\n\n不出两日路过乡集，正碰上县里乡团采买军械的管事，那人顺着木纹一摸便知是行家手笔，没还半句价，当场痛快数出 190 两纹银尽数收走。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		this.m.BroA = null;
		this.m.BroB = null;

		local bowyer = ::Wuxia.Events.findByBackgrounds(["background.bowyer"]);
		if (bowyer == null) return;

		this.m.BroA = bowyer;
		this.m.BroB = ::Wuxia.Events.findByBackgrounds([
			"background.hunter",
			"background.poacher",
			"background.shepherd"
		], bowyer);
		this.m.Score = 16;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.BroA))
			this.m.BroA = ::Wuxia.Events.findByBackgrounds(["background.bowyer"]);
		if (this.m.BroB != null && !::Wuxia.Events.isAlive(this.m.BroB))
		{
			this.m.BroB = ::Wuxia.Events.findByBackgrounds([
				"background.hunter",
				"background.poacher",
				"background.shepherd"
			], this.m.BroA);
		}
	}

	function onPrepareVariables( _vars )
	{
		_vars.push(["bowyer", ::Wuxia.Events.shortName(this.m.BroA)]);
	}

	function onClear()
	{
		this.m.BroA = null;
		this.m.BroB = null;
	}
});
