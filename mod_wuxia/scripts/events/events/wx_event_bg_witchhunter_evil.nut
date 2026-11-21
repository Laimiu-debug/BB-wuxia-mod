// Batch E2 Event 13: 正邪不容（正道卫道士与秘教/邪功同袍的深夜营地对峙）

this.wx_event_bg_witchhunter_evil <- this.inherit("scripts/events/event", {
	m = {
		Zealot  = null,
		EvilBro = null
	},

	function create()
	{
		this.m.ID = "event.wx_bg_witchhunter_evil";
		this.m.Title = "正邪不容";
		this.m.Cooldown = 38.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "「收起家伙！进了我的营盘，不论佛魔邪正，只认一条江湖规矩。」",
					function getResult( _event ) { return "MercenaryLaw"; }
				},
				{
					Text = "「立下血誓约法三章：行功吐纳须离营百步，绝不祸及同袍。」",
					function getResult( _event ) { return "BloodOath"; }
				},
				{
					Text = "「嘴上争不出是非——去营外空地过三招，谁站着谁有理！」",
					function getResult( _event ) { return "ThreeBouts"; }
				}
			],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local zealot = _event.m.Zealot;
				local evilBro = _event.m.EvilBro;
				local zName = ::Wuxia.Events.isAlive(zealot) ? ::Wuxia.Events.fmtName(zealot) : "那名正道弟兄";
				local eName = ::Wuxia.Events.isAlive(evilBro) ? ::Wuxia.Events.fmtName(evilBro) : "那名邪派弟兄";

				if (::Wuxia.Events.isAlive(zealot)) this.Characters.push(zealot.getImagePath());
				if (::Wuxia.Events.isAlive(evilBro)) this.Characters.push(evilBro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]三更寒露压熄了半堆柴火，营外荒草间忽然飘来一阵湿冷的喃喃低咒，夹着铁锈与坟土般的阴浊气味。你掀开帐帘，只见 " + eName + " 正蹲在马车阴影里掐诀调息，指缝间隐约缠着几缕灰雾。\n\n三步之外，" + zName + " 根本没睡，提着一盏昏黄油灯站在风口，指节攥得发白，兵刃已出鞘两寸：『头儿，你瞧见了！这厮半夜念的哪门子阴司鬼咒，再留他在营里吞吐邪气，早晚连累满营弟兄撞煞失心！』" + eName + " 缓缓抬眼，嘴角扯出半丝冷笑：『杀贼卖命的钱我少挣了一文，还是挡刀的时候我少挨了一枪？偏你这正人君子鼻孔长在头顶上！』\n\n帐篷里几个装睡的弟兄悄悄摸向了靴筒里的匕首，火堆火星哔剥一跳，眼看便要见血。";
			}
		});

		this.m.Screens.push({
			ID = "MercenaryLaw",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "各自回帐歇息。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local zealot = _event.m.Zealot;
				local evilBro = _event.m.EvilBro;
				local zName = ::Wuxia.Events.isAlive(zealot) ? ::Wuxia.Events.fmtName(zealot) : "正道弟兄";
				local eName = ::Wuxia.Events.isAlive(evilBro) ? ::Wuxia.Events.fmtName(evilBro) : "邪派弟兄";

				if (::Wuxia.Events.isAlive(zealot)) this.Characters.push(zealot.getImagePath());
				if (::Wuxia.Events.isAlive(evilBro)) this.Characters.push(evilBro.getImagePath());

				::Wuxia.Events.addMood(zealot, 0.5, "暂服营规约束", this.List);
				::Wuxia.Events.addMood(evilBro, 0.5, "未遭同袍构陷", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]你一脚踢散火堆边缘一块烧红的枯枝，火星溅在两人鞋尖前，谁也没敢挪步。『咱们不是名门讲经堂，也不是阴山祭坛，是一口锅里捞干饭、一条泥路上搏命的雇佣弟兄。白日上阵谁替你挡暗箭，夜里就别拿圣人尺子去量他喉咙；至于你，念咒行功别熏着旁人睡觉，否则明早滚蛋。』\n\n" + zName + " 盯着炭火沉默半晌，缓缓按回刀镡；" + eName + " 嗤笑一声拍拍膝头草屑，收起骨签转身钻回了偏帐。两人虽仍互看不顺眼，到底各自咽下了这口恶气。";
			}
		});

		this.m.Screens.push({
			ID = "BloodOath",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "既立重誓，便依约行事。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local zealot = _event.m.Zealot;
				local evilBro = _event.m.EvilBro;
				local zName = ::Wuxia.Events.isAlive(zealot) ? ::Wuxia.Events.fmtName(zealot) : "正道弟兄";
				local eName = ::Wuxia.Events.isAlive(evilBro) ? ::Wuxia.Events.fmtName(evilBro) : "邪派弟兄";

				if (::Wuxia.Events.isAlive(zealot)) this.Characters.push(zealot.getImagePath());
				if (::Wuxia.Events.isAlive(evilBro)) this.Characters.push(evilBro.getImagePath());

				::Wuxia.Events.addMood(zealot, 1.25, "邪气受血誓约束", this.List);
				::Wuxia.Events.addStat(evilBro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
				::Wuxia.Events.addMood(evilBro, -0.5, "被迫立誓受制", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]你叫人端来半碗冷酒，当着火光定下铁律：往后行运阴诡功法须远出营地百步，绝不得对同袍与良善苦主施展邪术。\n\n" + eName + " 眼皮都没眨一下，咬破拇指挤出三滴血坠入酒碗，仰脖饮尽后抹抹嘴角：『誓言这玩意儿比草纸还轻，偏你们正道人信得要命。行，既吃了这碗血酒，我守你的规矩便是。』那股面不改色的狠劲反倒压住了场子；" + zName + " 盯着碗底残红微微颔首，紧绷的肩头终于松了半分。";
			}
		});

		this.m.Screens.push({
			ID = "ThreeBouts",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "打痛快了就去包扎伤口。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local zealot = _event.m.Zealot;
				local evilBro = _event.m.EvilBro;
				local zName = ::Wuxia.Events.isAlive(zealot) ? ::Wuxia.Events.fmtName(zealot) : "正道弟兄";
				local eName = ::Wuxia.Events.isAlive(evilBro) ? ::Wuxia.Events.fmtName(evilBro) : "邪派弟兄";

				if (::Wuxia.Events.isAlive(zealot)) this.Characters.push(zealot.getImagePath());
				if (::Wuxia.Events.isAlive(evilBro)) this.Characters.push(evilBro.getImagePath());

				::Wuxia.Events.addMastery(zealot, 60, this.List);
				::Wuxia.Events.addMastery(evilBro, 60, this.List);
				::Wuxia.Events.applyLightHurt(zealot, 0.14, this.List);
				::Wuxia.Events.applyLightHurt(evilBro, 0.14, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]『拿麻布缠了刃口，三招定高下，生死不论休怪旁人！』话音未落，两人已在冻硬的泥地里撞作一团。\n\n第一合硬撼拳风，惊起林梢宿鸦；第二合 " + zName + " 刚猛劈落震裂对方护腕，" + eName + " 却如毒蛇贴身一肘撞得他气血翻涌；第三合彼此各挨实了一记，齐齐退开五步，啐出一口带血的唾沫。月光下两张淤青的脸瞪了半晌，竟都没再骂娘——江湖上不认嘴皮子，这一架打完，反倒各自摸透了对方几分真实斤两。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Zealot = null;
		this.m.EvilBro = null;
		if (!::Wuxia.Events.isWorldReady()) return;

		local zealot = ::Wuxia.Events.findByBackgrounds([
			"background.witchhunter",
			"background.crusader",
			"background.oathtaker",
			"background.paladin",
			"background.monk"
		]);
		if (zealot == null) return;

		local evilBro = null;
		if (::Math.rand(0, 1) == 0)
		{
			evilBro = ::Wuxia.Events.findByBackgrounds(["background.cultist"], zealot);
			if (evilBro == null) evilBro = ::Wuxia.Events.findBroWithElement("evil", zealot);
		}
		else
		{
			evilBro = ::Wuxia.Events.findBroWithElement("evil", zealot);
			if (evilBro == null) evilBro = ::Wuxia.Events.findByBackgrounds(["background.cultist"], zealot);
		}
		if (evilBro == null) return;

		this.m.Zealot = zealot;
		this.m.EvilBro = evilBro;
		this.m.Score = 16;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Zealot = null;
		this.m.EvilBro = null;
	}
});
