// Batch E2 Event 17: 暗室机括（营造石匠/深井矿工在残破边塞烽燧敲出空心暗格）

this.wx_event_bg_mason_ruin <- this.inherit("scripts/events/event", {
	m = {
		Mason = null
	},

	function create()
	{
		this.m.ID = "event.wx_bg_mason_ruin";
		this.m.Title = "暗室机括";
		this.m.Cooldown = 38.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "「你懂石作门道，拿铁楔卡死石齿，慢慢拆开！」",
					function getResult( _event ) { return "CarefulWedge"; }
				},
				{
					Text = "「哪来那么多讲究？拎重锤直接把这堵破砖墙砸塌！」",
					function getResult( _event ) { return "SmashThrough"; }
				},
				{
					Text = "「塌了旧烟台压死人不划算，留给山鼠作窝吧。」",
					function getResult( _event ) { return "Ignore"; }
				}
			],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Mason;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "那名匠人弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_17.png[/img]风沙渐紧，队伍暂避在一座塌了半边顶的前朝边塞烽燧里。弟兄们忙着踢开羊粪铺草席，唯有 " + bName + " 贴着熏黑的砖墙一路走一路拿匕首柄轻叩——「笃、笃、咚！」\n\n他猛地收手，抠下一点灰缝在指腹捻开细闻，眼神陡亮：『糯米灰浆后补的活砖，底下藏着半尺深的石枢暗室！前朝戍边把总多半把私银或兵甲物件砌在了里头——不过这号砖缝留了泄劲眼，里头十有八九还绷着防贼的暗箭机括。』";
			}
		});

		this.m.Screens.push({
			ID = "CarefulWedge",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "干得漂亮，打包装车！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Mason;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "匠人弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(220, this.List);
				::Wuxia.Events.addSupplies(15, 0, 0, this.List);
				::Wuxia.Events.addMood(bro, 1.0, "巧破前朝石括", this.List);

				local extraText = "";
				if (::Math.rand(0, 1) == 0)
				{
					::Wuxia.Events.givePill("wx_pill_jinchuang", this.List);
					extraText = "外加一瓷瓶封蜡未干的上好【金疮散】";
				}
				else
				{
					::Wuxia.Events.givePage("sect", 1, this.List);
					extraText = "夹层里竟还压着一页字迹苍劲的门派武学残页";
				}

				this.Text = "[img]gfx/ui/events/wx_ev_17.png[/img]" + bName + " 削了两根硬枣木楔，先顺着泄劲眼慢慢顶进青砖背后，再把铁钉卡入石轮牙口。「咯吱」一声闷响，暗槽里锈迹斑斑的机簧卡得死死的，连一根弩箭都没崩出来。\n\n活砖整块抽离后，暗格里整整齐齐躺着几个油布包：发黑的旧银碎锭、浸满桐油的精铁甲叶铆钉，" + extraText + "。众弟兄围着石窟啧啧称奇，直夸这手艺比十把大锤管用。";
			}
		});

		this.m.Screens.push({
			ID = "SmashThrough",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "快把铁蒺藜拔了上药！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Mason;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "匠人弟兄";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.applyLightHurt(bro, 0.16, this.List);
				::Wuxia.Events.addMoney(140, this.List);
				::Wuxia.Events.addMood(bro, -0.75, "蛮拆砖墙挨了暗箭", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_17.png[/img]三记势大力沉的重锤下去，半面砖墙轰然垮塌，烟尘呛得人睁不开眼——就在青砖碎落的刹那，墙腹内一根绷紧多年的牛筋弦骤然弹断！数支三寸长的锈铁短箭贴着灰雾呼啸窜出，" + bName + " 躲闪慢了半拍，肩头被划开一道血口，痛得骂了一声粗口。\n\n待灰尘落定，弟兄们从碎砖烂木里翻出些砸散的银角子，可原本装药与器物的匣子早已被锤头砸得稀烂。";
			}
		});

		this.m.Screens.push({
			ID = "Ignore",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "天亮拔营。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Mason;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_17.png[/img]这破烽燧墙体早已歪斜，真要捅塌了承重石柱，半队人都得埋在砖堆里给前朝校尉陪葬。你摆手叫众人别动那面活砖，安安稳稳避了一夜风沙便即上路。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Mason = null;
		if (!::Wuxia.Events.isWorldReady()) return;

		local bro = ::Wuxia.Events.findByBackgrounds([
			"background.mason",
			"background.miner"
		]);
		if (bro == null) return;

		this.m.Mason = bro;
		this.m.Score = 15;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Mason = null;
	}
});
