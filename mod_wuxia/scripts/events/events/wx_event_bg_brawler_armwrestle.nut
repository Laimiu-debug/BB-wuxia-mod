// Batch E2 Event 20: 酒肆扳腕（盐帮恶汉酒肆摆下三百两赌局，队内猛汉登桌较力）

this.wx_event_bg_brawler_armwrestle <- this.inherit("scripts/events/event", {
	m = {
		Champ = null
	},

	function create()
	{
		this.m.ID = "event.wx_bg_brawler_armwrestle";
		this.m.Title = "酒肆扳腕";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;

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

				local bro = _event.m.Champ;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "那名猛汉";
				local shortN = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.shortName(bro) : "好汉";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Options.push({
					Text = "「三百两？接了！" + shortN + "，上去把这盐枭的腕骨按进桌面！」",
					function getResult( _ev )
					{
						if (::Math.rand(1, 100) <= 75) return "WinNormal";
						return "LoseNormal";
					}
				});

				if (::World.Assets.getMoney() >= 300)
				{
					this.Options.push({
						Text = "「三百两太小家子气——翻倍下六百两，敢不敢接？」",
						function getResult( _ev )
						{
							if (::Math.rand(1, 100) <= 60) return "WinDouble";
							return "LoseDouble";
						}
					});
				}

				this.Options.push({
					Text = "「少跟地头蛇斗气，低头喝咱们的浊酒。」",
					function getResult( _ev ) { return "DrinkQuietly"; }
				});

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]城外老榆树酒肆里油烟呛人，一桌光着膀子、肩头刺着靛青过江龙的盐帮恶汉正拍桌子吆喝。为首那黑铁塔似的壮汉「砰」地把一只鼓囊囊的粗布银袋砸在八仙桌上，震翻了半碟酱豆：\n\n『三百两现银摆在这儿！哪路过江龙敢跟老子扳一局手腕？赢了银子端走，输了掏一半茶水钱，再绕着酒坛学三声驴叫！』满堂酒客哄笑起哄，所有人的目光齐刷刷扫向你们桌边——只见 " + bName + " 已经慢条斯理卷起了袖筒，十指捏得咯嘣作响，像掰断一把干竹竿。";
			}
		});

		this.m.Screens.push({
			ID = "WinNormal",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "替盐帮兄弟结碗醒酒茶，哈哈！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Champ;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "猛汉";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(300, this.List);
				::Wuxia.Events.addStat(bro, "Stamina", 1, "内息上限", "ui/icons/fatigue.png", this.List);
				::Wuxia.Events.addCompanyMood(1.0, "酒肆力压盐枭，赢银又长脸", this.List);
				::Wuxia.Events.addMastery(bro, 45, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]两只铁钳般的大手甫一扣死，榆木桌腿便在青砖地上发出刺耳的咯吱哀鸣。盐帮恶汉额头青筋暴起如蚯蚓，使出吃奶的力气往下一压，却见 " + bName + " 纹丝不动，嘴角甚至还勾起一丝坏笑。\n\n待对方一口浊气泄了半截，" + bName + " 丹田沉喝一声，肩背发力如推磨盘，「轰」地把那恶汉的拳背狠狠摁进了空酒碗里，碎瓷四溅！满堂酒客拍桌狂叫，盐帮头子捂着手腕脸涨成猪肝色，咬着后槽牙把三百两银袋推了过来。";
			}
		});

		this.m.Screens.push({
			ID = "LoseNormal",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "快走，别再提驴叫的事了！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Champ;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "猛汉";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(-150, this.List);
				::Wuxia.Events.applyLightHurt(bro, 0.12, this.List);
				::Wuxia.Events.addMood(bro, -1.0, "酒肆阴沟翻船，臊得满脸通红", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]起初势均力敌，眼看就要把那盐枭压弯腰，谁料桌子角落不知何时泼了一汪猪油！" + bName + " 手肘猛地一滑，重心骤失，「咚」地一声反被对方借势把整条小臂砸在厚桌沿上，震得虎口发麻。\n\n盐帮众人顿时爆出震天嘲笑，连店小二都憋笑憋得直抽搐。你赶紧丢下一百五十两银子堵住对方要学驴叫的臭嘴，拽着满脸通红、恨不得把八仙桌劈成柴火的 " + bName + " 灰头土脸出了酒肆。";
			}
		});

		this.m.Screens.push({
			ID = "WinDouble",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "六百两入袋，今夜不醉不归！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Champ;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "猛汉";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(600, this.List);
				::Wuxia.Events.addStat(bro, "Stamina", 1, "内息上限", "ui/icons/fatigue.png", this.List);
				::Wuxia.Events.addCompanyMood(1.5, "翻倍豪赌力劈盐枭，满堂惊服", this.List);
				::Wuxia.Events.addMastery(bro, 60, this.List);
				::Wuxia.Events.addReputation(15, 0, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]一听翻倍赌六百两，酒肆里连算账的掌柜都爬上了条凳看热闹。盐帮恶汉眼睛血红，拼死僵持了足足一炷香功夫，汗珠顺着下巴滴答砸在桌面上。\n\n就在全场屏息之际，" + bName + " 鼻孔喷出两道白气，腰胯一拧，浑身筋骨如弓弦崩响，生生把那铁塔汉子的整条臂膀压塌下去——「咔嚓」一声，竟连寸厚的榆木桌面都压裂出一道指宽缝隙！盐枭服气得直抽冷气，老老实实凑齐六百两双手奉上，从此方圆十里酒肆无人不知你们这帮煞神的名号。";
			}
		});

		this.m.Screens.push({
			ID = "LoseDouble",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "认赌服输，这笔账日后再算。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Champ;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "猛汉";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addMoney(-300, this.List);
				::Wuxia.Events.applyLightHurt(bro, 0.18, this.List);
				::Wuxia.Events.addMood(bro, -1.25, "翻倍豪赌惨败，颜面扫地", this.List);
				::Wuxia.Events.addCompanyMood(-0.5, "输了大注银钱，酒也没了滋味", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]真动了六百两的狠注，那盐帮恶汉反倒收起了轻狂，从汗巾底下露出一条绑了十几年的乌铁护腕，浑身死肉一绷竟沉如生铁！僵持半晌，" + bName + " 旧劲已老、新气未续，腕骨被压得咔咔作响，终究敌不过对方扛盐包练出的死力，砰然落败。\n\n你忍痛点了三百两现银扔在桌上，盐帮众人哄堂大笑拍桌敬酒；" + bName + " 捂着肿成萝卜的手腕闷坐了一路，发誓下回再见定要砸碎他两块护腕。";
			}
		});

		this.m.Screens.push({
			ID = "DrinkQuietly",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "结账上路。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Champ;
				local bName = ::Wuxia.Events.isAlive(bro) ? ::Wuxia.Events.fmtName(bro) : "猛汉";
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]你按住 " + bName + " 跃跃欲试的胳膊肘：『人家一帮子地头蛇就等着找茬掀桌，赢了银子也未必带得出镇口。』他哼了一声仰脖灌干碗里浊酒，任那帮盐枭在角落里吹得唾沫横飞，大伙儿吃饱喝足径直结账走人。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Champ = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (!::Wuxia.Events.isNearTown(4)) return;
		if (::World.Assets.getMoney() < 150) return;

		local bro = ::Wuxia.Events.findByBackgrounds([
			"background.brawler",
			"background.lumberjack",
			"background.farmhand",
			"background.gladiator",
			"background.barbarian",
			"background.wildman",
			"background.hedge_knight"
		]);
		if (bro == null) return;

		this.m.Champ = bro;
		this.m.Score = 18;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Champ = null;
	}
});
