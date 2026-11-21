// Batch E5 Event 51: 破庙青丘孤灯

this.wx_event_weird_fox_temple <- this.inherit("scripts/events/event", {
	m = {
		Exorcist     = null,
		CuriosityBro = null
	},

	function create()
	{
		this.m.ID = "event.wx_weird_fox_temple";
		this.m.Title = "破庙青丘 · 孤灯红帐";
		this.m.Cooldown = 44.0 * this.World.getTime().SecondsPerDay;

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

				local exorcist = _event.m.Exorcist;
				local cBro = _event.m.CuriosityBro;
				if (!::Wuxia.Events.isAlive(cBro)) cBro = ::Wuxia.Events.findRandomBro();
				local cName = ::Wuxia.Events.isAlive(cBro) ? ::Wuxia.Events.fmtName(cBro) : "一名守夜弟兄";

				if (::Wuxia.Events.isAlive(exorcist)) this.Characters.push(exorcist.getImagePath());
				if (::Wuxia.Events.isAlive(cBro)) this.Characters.push(cBro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_19.png[/img]半塌的山神破庙里寒风穿梁，神龛上那尊泥塑山神早已剥落半边金漆，只剩一只黑洞洞的泥眼俯视正殿。子夜过后，原本死寂的偏殿破窗竟透出一豆暖融融的杏黄灯火，轻柔婉转的吴侬小调随风钻进耳膜，夹杂着一股温热梨花酿与脂粉交织的异香。\n\n" + cName + " 不知何时脱了铁靴，像丢了魂似的赤脚踩在霜地上，直勾勾走向偏殿门楣挂着的一幅簇新猩红锦帐。偏巧一阵穿堂冷风卷过灯芯，红帐后那道纤细女子的剪影映上斑驳白墙——垂袖之下，竟有三条毛茸茸的长尾正慢悠悠地左右轻摆！分明是山野作祟的青丘妖魅！";

				if (::Wuxia.Events.isAlive(exorcist))
				{
					this.Options.push({
						Text = "让 " + ::Wuxia.Events.shortName(exorcist) + " 暴喝破妄，一刀斩裂红帐逐杀青丘妖魅！",
						function getResult( _ev ) { return "BreakGlamour"; }
					});
				}

				this.Options.push({
					Text = "一把扯回迷糊弟兄，用断梁顶死偏殿木门，猛添干柴枯守到天亮。",
					function getResult( _ev ) { return "BarHall"; }
				});

				this.Options.push({
					Text = "暂按兵不动，任由 " + ::Wuxia.Events.shortName(cBro) + " 掀帐一窥虚实。",
					function getResult( _ev ) { return "Curiosity"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "BreakGlamour",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收妥妖发与定神散，破晓拔营。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local exorcist = _event.m.Exorcist;
				if (!::Wuxia.Events.isAlive(exorcist)) exorcist = ::Wuxia.Events.findRandomBro();
				local eName = ::Wuxia.Events.isAlive(exorcist) ? ::Wuxia.Events.fmtName(exorcist) : "伏魔弟兄";
				if (::Wuxia.Events.isAlive(exorcist)) this.Characters.push(exorcist.getImagePath());

				try
				{
					::Wuxia.Events.giveItem("scripts/items/misc/witch_hair_item", this.List);
				}
				catch (_e)
				{
					::Wuxia.Events.addMoney(240, this.List);
				}
				::Wuxia.Events.givePill("wx_pill_dingshen", this.List);
				::Wuxia.Events.addStat(exorcist, "Bravery", 2, "定力", "ui/icons/bravery.png", this.List);
				::Wuxia.Events.addCompanyMood(0.75, "破除青丘妖魅大振军心", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_19.png[/img]" + eName + " 咬破舌尖，一口阳血喷在兵刃锋口，步罡踏斗抢入偏殿，发出一声震落梁灰的断喝，寒芒顺势将那幅猩红锦帐一劈两半！\n\n帐后骤响一声刺耳狐啸，杏黄孤灯哗啦碎灭，方才醇香扑鼻的暖酒转眼现了原形，竟是一只盛满臭雨水与枯叶的破瓦盆。一道雪白残影撞破朽窗窜上荒岭，只留下断帐边缠着异香的一束雪白妖发，以及旧供桌下不知哪位遇害道长遗留的檀木小盒——里面整整齐齐码着一贴完好无损的明目定神散。";
			}
		});

		this.m.Screens.push({
			ID = "BarHall",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "鸡鸣天明，速速离开这座邪庙。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local cBro = _event.m.CuriosityBro;
				local cName = ::Wuxia.Events.isAlive(cBro) ? ::Wuxia.Events.fmtName(cBro) : "那名弟兄";
				if (::Wuxia.Events.isAlive(cBro)) this.Characters.push(cBro.getImagePath());

				::Wuxia.Events.addCompanyMood(-0.25, "破庙夜闻狐笑心头微寒", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_19.png[/img]你两步上前死拽着后领把 " + cName + " 拖回火堆边，狠狠泼了半瓢凉水才让他打了个寒战清醒过来。众人合力搬起两根腐朽殿梁死死顶住偏殿隔门，又将所有干松柴一股脑塞进火坑烧得噼啪作响。\n\n隔着朽木门板，那阵细碎柔媚的轻笑声贴着门缝转了半夜，间或夹杂几下利爪刮擦木板的刺耳沙沙声，直熬到远村公鸡叫了头遍，偏殿里才彻底沉寂下来。虽未损兵折将，天亮推门时人人脊背仍觉发凉。";
			}
		});

		this.m.Screens.push({
			ID = "Curiosity",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "替他披上棉袍，扶上骡车休养。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local cBro = _event.m.CuriosityBro;
				if (!::Wuxia.Events.isAlive(cBro)) cBro = ::Wuxia.Events.findRandomBro();
				local cName = ::Wuxia.Events.isAlive(cBro) ? ::Wuxia.Events.fmtName(cBro) : "那名弟兄";
				if (::Wuxia.Events.isAlive(cBro)) this.Characters.push(cBro.getImagePath());

				::Wuxia.Events.applyInternalStrain(cBro, 2, this.List);
				::Wuxia.Events.addMoney(300, this.List);
				::Wuxia.Events.addMood(cBro, -0.75, "误入狐魅幻梦元气大亏", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_19.png[/img]" + cName + " 刚一掀开红帐钻进去，那盏杏黄孤灯便啪地熄灭，满院重归死寂。众人举着火把冲进偏殿，却只见断垣残草与满地厚灰，哪有半点红帐酒席的影子？\n\n直到破晓霜降，你们才在庙后荒坟泥坑里寻到冻得嘴唇青紫、浑身筛糠似的 " + cName + "。他经脉阴寒岔乱、神思恍惚，嘴里只含糊念叨着『好暖的酒』；可掰开他死攥不放的冰凉五指，掌心里竟握着一块沁色温润的前朝古羊脂玉佩，拿到市肆足能换回三百两纹银。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Exorcist = null;
		this.m.CuriosityBro = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (!::Wuxia.Events.isNight()) return;
		if (::Wuxia.Events.getAliveBros().len() < 2) return;

		this.m.Exorcist = ::Wuxia.Events.findByBackgrounds([
			"background.witchhunter",
			"background.monk",
			"background.oathtaker",
			"background.crusader"
		]);
		this.m.CuriosityBro = ::Wuxia.Events.findRandomBro(this.m.Exorcist);
		if (this.m.CuriosityBro == null) this.m.CuriosityBro = ::Wuxia.Events.findRandomBro();
		this.m.Score = 16;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.Exorcist))
		{
			this.m.Exorcist = ::Wuxia.Events.findByBackgrounds([
				"background.witchhunter",
				"background.monk",
				"background.oathtaker",
				"background.crusader"
			]);
		}
		if (!::Wuxia.Events.isAlive(this.m.CuriosityBro))
			this.m.CuriosityBro = ::Wuxia.Events.findRandomBro(this.m.Exorcist);
		if (!::Wuxia.Events.isAlive(this.m.CuriosityBro))
			this.m.CuriosityBro = ::Wuxia.Events.findRandomBro();
	}

	function onPrepareVariables( _vars ) {}

	function onClear()
	{
		this.m.Exorcist = null;
		this.m.CuriosityBro = null;
	}
});
