// Batch E2 Event 14: 以毒试脉（验方医者熬制五毒解药，请硬汉同袍以身试方）

this.wx_event_bg_anatomist_venom <- this.inherit("scripts/events/event", {
	m = {
		Doc       = null,
		Volunteer = null
	},

	function create()
	{
		this.m.ID = "event.wx_bg_anatomist_venom";
		this.m.Title = "以毒试脉";
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
				this.Options = [];

				local doc = _event.m.Doc;
				local vol = _event.m.Volunteer;
				local dName = ::Wuxia.Events.isAlive(doc) ? ::Wuxia.Events.fmtName(doc) : "那名医者";
				local vName = ::Wuxia.Events.isAlive(vol) ? ::Wuxia.Events.fmtName(vol) : "那名壮汉";

				if (::Wuxia.Events.isAlive(doc)) this.Characters.push(doc.getImagePath());
				if (::Wuxia.Events.isAlive(vol)) this.Characters.push(vol.getImagePath());

				this.Options.push({
					Text = "「准了！让 " + (::Wuxia.Events.isAlive(vol) ? ::Wuxia.Events.shortName(vol) : "他") + " 试药，真要试出好歹拿你抵命。」",
					function getResult( _ev ) { return "TestVolunteer"; }
				});

				if (::World.Assets.getMoney() >= 160)
				{
					this.Options.push({
						Text = "「拿弟兄当药罐子？给 160 银两，去买牲畜与正经药材稳妥提炼！」",
						function getResult( _ev ) { return "SafeRefine"; }
					});
				}

				this.Options.push({
					Text = "「把那罐绿汤全倒进土坑！严禁拿营中弟兄试毒！」",
					function getResult( _ev ) { return "Forbid"; }
				});

				this.Text = "[img]gfx/ui/events/wx_ev_12.png[/img]一阵焦腥刺鼻的怪味从营角飘来，熏得拴在树下的骡子直打响鼻。循味找去，只见 " + dName + " 正守着一只豁口砂锅，拿根发黑的竹片搅动锅里冒绿泡的粘稠药浆，身旁摆着晒干的蜈蚣壳、蛇胆与半块朱砂。\n\n『头儿来得正好！』" + dName + " 抹了把额头煤灰，两眼放光，『我照着南疆残方配出一味五毒克星，可禽兽脉象与人不同，得借一副底子够厚的活人筋骨过一遍药性，才敢捏成解毒灵丹。』旁边 " + vName + " 已经卷起了满是旧疤的袖子，咧嘴斜眼打量着黑锅：『先说好，灌完这碗臭汤，晚饭得多赏我两块大肥肉外加一壶酒！』";
			}
		});

		this.m.Screens.push({
			ID = "TestVolunteer",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收好灵丹，让试药的弟兄歇息去。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local doc = _event.m.Doc;
				local vol = _event.m.Volunteer;
				local dName = ::Wuxia.Events.isAlive(doc) ? ::Wuxia.Events.fmtName(doc) : "医者";
				local vName = ::Wuxia.Events.isAlive(vol) ? ::Wuxia.Events.fmtName(vol) : "壮汉";

				if (::Wuxia.Events.isAlive(doc)) this.Characters.push(doc.getImagePath());
				if (::Wuxia.Events.isAlive(vol)) this.Characters.push(vol.getImagePath());

				::Wuxia.Events.givePill("wx_pill_qingxin", this.List);
				::Wuxia.Events.givePill("wx_pill_huxin", this.List);
				::Wuxia.Events.addStat(vol, "Hitpoints", 1, "气血上限", "ui/icons/health.png", this.List);
				::Wuxia.Events.addMood(doc, 1.0, "试方得验，喜不自胜", this.List);

				local strainText = "";
				if (::Math.rand(0, 1) == 0)
				{
					::Wuxia.Events.applyInternalStrain(vol, 2, this.List);
					strainText = "药力猛烈，震得他丹田气脉逆乱，这两日免不了胸闷乏力；";
				}
				else
				{
					::Wuxia.Events.applyLightHurt(vol, 0.16, this.List);
					strainText = "药劲烧得他呕出两口黑血，好半晌才扶着车轮喘匀气；";
				}

				this.Text = "[img]gfx/ui/events/wx_ev_12.png[/img]" + vName + " 捏着鼻子一口闷下那半碗发绿的苦汤，不到十息功夫，整张脸便涨成了发霉的青铜色。他扶着草垛连干呕数声，额头渗出一层带腥味的黑汗，" + strainText + "可待那股毒火褪尽，筋骨反倒被猛药淬得硬实了一分。\n\n" + dName + " 飞快按住他脉门记下数笔，随即回炉加减君臣药味，竟真搓出了两枚温润生香的成品灵丹，笑得合不拢嘴。";
			}
		});

		this.m.Screens.push({
			ID = "SafeRefine",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "稳妥成药，总好过拿人命赌。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local doc = _event.m.Doc;
				local dName = ::Wuxia.Events.isAlive(doc) ? ::Wuxia.Events.fmtName(doc) : "医者";
				if (::Wuxia.Events.isAlive(doc)) this.Characters.push(doc.getImagePath());

				::Wuxia.Events.addMoney(-160, this.List);
				::Wuxia.Events.givePill("wx_pill_qingxin", this.List);
				::Wuxia.Events.addSupplies(0, 8, 0, this.List);
				::Wuxia.Events.addMood(doc, 0.75, "得银购药，稳妥成丹", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_12.png[/img]" + dName + " 嘴上嘟囔着『家禽经络浅陋，哪及武人十二正经来得清楚』，手脚却麻利得很，揣上银子便去沿途集镇买回两只老母鸡、数斤雄黄甘草与净陶药罐。\n\n连熬三个时辰后，虽然省去了活人试脉的凶险，炉底依旧凝出了一枚色泽清透的解毒宝丹，连带着剩下的药渣还配出几大瓶上好伤药，算得上物有所值。";
			}
		});

		this.m.Screens.push({
			ID = "Forbid",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收锅起营。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local doc = _event.m.Doc;
				local vol = _event.m.Volunteer;
				local dName = ::Wuxia.Events.isAlive(doc) ? ::Wuxia.Events.fmtName(doc) : "医者";
				local vName = ::Wuxia.Events.isAlive(vol) ? ::Wuxia.Events.fmtName(vol) : "壮汉";

				if (::Wuxia.Events.isAlive(doc)) this.Characters.push(doc.getImagePath());
				if (::Wuxia.Events.isAlive(vol)) this.Characters.push(vol.getImagePath());

				::Wuxia.Events.addMood(doc, -0.75, "苦心验方遭禁", this.List);
				::Wuxia.Events.addMood(vol, 0.75, "免作试药活靶", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_12.png[/img]你黑着脸端起砂锅倒进营外土坑，绿浆落地滋滋冒烟，眨眼间便把一丛狗尾草烧得枯黄发黑。\n\n" + vName + " 悄悄咽了口唾沫，不动声色地把袖子放了下来；" + dName + " 抱着空锅直叹『良方毁于俗见』，闷闷不乐地收拾药箱去了。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Doc = null;
		this.m.Volunteer = null;
		if (!::Wuxia.Events.isWorldReady()) return;

		local doc = ::Wuxia.Events.findByBackgrounds(["background.anatomist"]);
		if (doc == null) return;

		local vol = ::Wuxia.Events.findByBackgrounds([
			"background.farmhand",
			"background.flagellant",
			"background.brawler",
			"background.wildman",
			"background.barbarian"
		], doc);
		if (vol == null) vol = ::Wuxia.Events.findRandomBro(doc);
		if (vol == null) return;

		this.m.Doc = doc;
		this.m.Volunteer = vol;
		this.m.Score = 16;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Doc = null;
		this.m.Volunteer = null;
	}
});
