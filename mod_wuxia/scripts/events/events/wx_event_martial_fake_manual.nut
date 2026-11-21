// Batch E3-29: 茶棚兜售假秘籍（镇郊茶棚识破江湖骗子或赌一把夹页机缘）

this.wx_event_martial_fake_manual <- this.inherit("scripts/events/event", {
	m = {
		Inspector = null,
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_martial_fake_manual";
		this.m.Title = "茶棚兜售假秘籍";
		this.m.Cooldown = 18.0 * this.World.getTime().SecondsPerDay;

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

				local insp = _event.m.Inspector;
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(insp)) this.Characters.push(insp.getImagePath());
				else if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]官道旁的草棚茶肆里弥漫着焦麦茶和骡马汗味。你们刚坐下歇脚，一名穿着油亮蓝布长衫、留着两撇鼠须的瘦汉子便紧挨长凳蹭了过来，贼眉鼠眼地四下瞟了一圈，从油腻袖筒里摸出一本泛黄线装破册。\n\n封皮上歪歪扭扭涂着七个朱砂大字：《九天玄女无敌剑谱》。那汉子压低嗓门神神秘秘道：『瞧诸位爷杀气内敛，定是行家！这可是前朝大内失窃的真迹，小的急着凑盘缠回乡奔丧，忍痛只要二百六十两现银……』";

				this.Options.push({
					Text = "宁可信其有，掏 260 银两直接把这册秘籍买下！",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 260) return "NoMoney";
						return ::Math.rand(1, 100) <= 40 ? "HiddenGem" : "FakeDoodles";
					}
				});

				if (::Wuxia.Events.isAlive(insp))
				{
					local iName = ::Wuxia.Events.shortName(insp);
					this.Options.push({
						Text = "别急着掏银子，先递给 " + iName + " 仔细验看纸质、墨色与装订。",
						function getResult( _ev ) { return "InspectTruth"; }
					});
				}

				this.Options.push({
					Text = "摆手赶苍蝇似的轰走他，专心喝茶。",
					function getResult( _ev ) { return "ShooOff"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "FakeDoodles",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "晦气！拿去生火点灶吧。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.Bro)) this.Characters.push(_event.m.Bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]银子刚过手，那油衫汉子抓起银袋一溜烟钻进门外赶集的人堆里没了影儿。你兴冲冲翻开封皮，只见头一页画着两个火柴棍小人举着大萝卜对捅，后头几页干脆是半本腌咸菜方子加三张缺角旧黄历，封皮上的陈年黄斑还透着一股新鲜隔夜茶水的馊味。\n\n满桌弟兄面面相觑，茶棚跑堂的躲在灶台后头笑得肩膀直抖，大伙儿这顿茶喝得憋屈透顶。";

				::Wuxia.Events.addMoney(-260, this.List);
				::Wuxia.Events.addCompanyMood(-0.65, "花冤枉钱买了本鬼画符假秘籍", this.List);
			}
		});

		this.m.Screens.push({
			ID = "HiddenGem",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "歪打正着，这买卖血赚！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.Bro)) this.Characters.push(_event.m.Bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]刚翻开第一页，你便险些拔刀追人——里头全是些胡涂乱抹的蠢画与胡诌口诀。可正要恼火撕书时，指尖却摸出厚纸封底有些不对劲！\n\n拿匕首挑开浆糊粘死的夹层，两张薄如蝉翼、字迹铁画银钩的油纸旧页竟飘落桌案——那蠢骗子不知从哪个旧货摊顺手捡了真武林旧纸拿来垫书壳，白白便宜了你们！";

				::Wuxia.Events.addMoney(-260, this.List);
				::Wuxia.Events.givePage("sect", 2, this.List);
				::Wuxia.Events.addCompanyMood(0.6, "假书封底竟藏着货真价实的门派残页", this.List);
			}
		});

		this.m.Screens.push({
			ID = "InspectTruth",
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

				local insp = _event.m.Inspector;
				if (::Wuxia.Events.isAlive(insp)) this.Characters.push(insp.getImagePath());
				local iName = ::Wuxia.Events.fmtName(insp);

				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]" + iName + "接过破册子，迎着日头捻了捻纸角，又凑到鼻尖一嗅，冷笑一声：『粗草纸浸的隔夜浓茶，朱砂里掺的砖红泥，装订的麻线连毛刺都没磨平——昨儿晚上刚糊出来的玩意儿吧？』\n\n那骗子脸色霎时煞白，拔腿就想溜，却被" + iName + "眼疾手快反扣住腕子。拉扯间，他破棉袍暗袋里滑出半截真正磨出包浆的旧武学抄本，吓得他连声告饶。";

				this.Options.push({
					Text = "扣住他别放，只丢 120 银两强行收下怀里那本真大路货抄本！",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 120) return "NoMoney";
						return "ForceReal";
					}
				});

				this.Options.push({
					Text = "不要他的脏书，当着满棚茶客掀他老底，把这江湖骗子轰得抱头鼠窜！",
					function getResult( _ev ) { return "LaughHimOut"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "ForceReal",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "算你小子识相，滚吧！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.Inspector)) this.Characters.push(_event.m.Inspector.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]你把 120 银两往桌上一拍，顺手把那册真正的旧抄本抽了出来。骗子瞅了瞅你们腰间寒光闪闪的钢刀，哭丧着脸不敢吭声，抓起碎银连滚带爬逃出了茶棚。大伙儿翻看一番，虽不是什么旷世神功，却也是字字扎实的正经门路。";

				::Wuxia.Events.addMoney(-120, this.List);
				::Wuxia.Events.giveManual("common", this.List);
			}
		});

		this.m.Screens.push({
			ID = "LaughHimOut",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "茶钱我请了，大伙儿喝个痛快！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.Inspector)) this.Characters.push(_event.m.Inspector.getImagePath());

				local iName = ::Wuxia.Events.fmtName(_event.m.Inspector);
				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]" + iName + "抖开那本《九天玄女无敌剑谱》，当众念出里头狗屁不通的胡话，逗得整座茶棚的客商、脚夫拍着大腿哄堂大笑。油衫骗子满脸臊红，被人拿茶碗泼了一身冷水，抱着脑袋灰溜溜逃进了土路烟尘里。弟兄们笑得前仰后合，赶路的乏意一扫而空！";

				::Wuxia.Events.addCompanyMood(0.9, "当众揭穿假秘籍骗子，满棚哄堂大笑", this.List);
			}
		});

		this.m.Screens.push({
			ID = "ShooOff",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "喝完茶继续上路。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]你连眼皮都没抬，刀鞘往条凳上一顿，沉声喝了句『滚远些』。那瘦汉子讪讪缩回袖子，扭头便去哄骗邻桌几个刚进城的货郎了。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "罢了，上路吧。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_03.png[/img]摸摸银袋，眼下手头现银不够数。那油衫汉子见捞不到油水，翻了个白眼揣好破书，一溜烟钻进街角没影了。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (!::Wuxia.Events.isNearTown(4)) return;

		this.m.Inspector = ::Wuxia.Events.findByBackgrounds([
			"background.historian",
			"background.peddler",
			"background.gambler",
			"background.swordmaster"
		]);
		this.m.Bro = ::Wuxia.Events.findRandomBro(this.m.Inspector);
		if (this.m.Bro == null) this.m.Bro = ::Wuxia.Events.findRandomBro();
		this.m.Score = 15;
	}

	function onClear()
	{
		this.m.Inspector = null;
		this.m.Bro = null;
	}
});
