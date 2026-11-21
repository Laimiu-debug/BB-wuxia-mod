// Batch E1 Event 02: 月下喂招（宿老名家深夜以柳枝指点新丁招法步架）

this.wx_event_camp_swordmaster_lesson <- this.inherit("scripts/events/event", {
	m = {
		BroA = null,
		BroB = null
	},

	function create()
	{
		this.m.ID = "event.wx_camp_swordmaster_lesson";
		this.m.Title = "月下喂招";
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
				local manualB = ::Wuxia.Events.pickManualName(_event.m.BroB);

				this.Text = "[img]gfx/ui/events/wx_ev_11.png[/img]三更寒露压白了营外枯艾，你起夜往车辕旁放水，忽听暗处传来一阵急促破风声。借着残火余光望去，" + nameB + " 正光着膀子拎一根剥了皮的白蜡杆，在草垛边咬牙演练 " + manualB + "，只是两肩端得僵硬如石磨，每出一式脚跟都微微离地。\n\n暗影里飘出一缕辛辣的旱烟味。" + nameA + " 靠在骡车轮毂上蹲了不知多久，磕掉烟锅里的余灰，声音沙哑得像砂纸擦铁：\n\n『下盘虚得跟风吹草垛似的，肘窝敞这么大个窟窿——真撞上山西绿林的快刀手，你这一棍还没递出去半尺，肠子就得挂在腰带上。』\n\n老手折了根细韧的干柳枝在掌心抽得啪啪作响，斜眼看着那满脸涨红的后生，显然动了深夜喂招的念头。";

				this.Options = [
					{
						Text = "难得前辈肯开金口，点起两支松明，往死里喂招！",
						function getResult( _event ) { return "FullDrill"; }
					},
					{
						Text = "明早还要拔营赶路，不必动真格，坐下拆讲几句要诀便好。",
						function getResult( _event ) { return "GentleTalk"; }
					},
					{
						Text = "三更半夜折腾坏了身子明日怎么打仗？都滚回去睡！",
						function getResult( _event ) { return "Sleep"; }
					}
				];
			}
		});

		this.m.Screens.push({
			ID = "FullDrill",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "好钢总得在火里敲打出来。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);

				::Wuxia.Events.applyLightHurt(_event.m.BroB, 0.10, this.List);
				::Wuxia.Events.addMastery(_event.m.BroB, 70, this.List);
				::Wuxia.Events.addMastery(_event.m.BroA, 30, this.List);
				if (::Math.rand(1, 2) == 1)
					::Wuxia.Events.addStat(_event.m.BroB, "MeleeSkill", 1, "武艺", "ui/icons/melee_skill.png", this.List);
				else
					::Wuxia.Events.addStat(_event.m.BroB, "MeleeDefense", 1, "近防", "ui/icons/melee_defense.png", this.List);
				::Wuxia.Events.addMood(_event.m.BroB, 0.75, "得前辈深夜倾囊喂招", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_11.png[/img]两支松明插在冻土里噼啪冒烟。" + nameA + " 半点不留情面——" + nameB + " 只要肩头微耸、腕口稍偏，那根干柳枝便如毒蛇吐信般抽在肋骨与小臂上，留下一道道火辣辣的红楞子。\n\n一直折腾到远村头遍鸡啼，" + nameB + " 掌心磨出两颗血泡、衣衫被冷汗浸透贴在背上，可再次架起木杆时，原本虚浮的步子竟已沉稳收紧，护胸门户严丝合缝。" + nameA + " 扔掉打烂的柳枝哼了一声：『笨是笨了点，倒还算块肯吃苦的料子。』";
			}
		});

		this.m.Screens.push({
			ID = "GentleTalk",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "听君一席话，胜似闷头瞎练。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);

				::Wuxia.Events.addMastery(_event.m.BroB, 45, this.List);
				::Wuxia.Events.addMood(_event.m.BroA, 0.75, "后生虚心可教", this.List);
				::Wuxia.Events.addMood(_event.m.BroB, 1.0, "得前辈点拨豁然开朗", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_11.png[/img]" + nameA + " 扯过一只旧马鞍席地坐下，拿柳枝在灰土里划出几道三角步位，慢条斯理拆解起临敌保命的门道——泥地里后脚如何生根、遇上长柄劈砸怎样侧肩泄劲、何时吐气发力才不至于岔了胸口。\n\n" + nameB + " 捧着半碗温热的姜汤蹲在火边，眼睛一眨不眨，嘴里默念着口诀连比划了七八遍，脸上紧绷的惶恐渐渐化作了实打实的笃定。";
			}
		});

		this.m.Screens.push({
			ID = "Sleep",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "养足精神最要紧。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);
				local nameB = ::Wuxia.Events.fmtName(_event.m.BroB);

				::Wuxia.Events.healBro(_event.m.BroB, 0.15, this.List);
				::Wuxia.Events.addMood(_event.m.BroB, -0.5, "深夜练功被喝止", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_11.png[/img]你一脚踢起半铲湿土压熄残火。" + nameA + " 嗤笑一声，将柳枝折断丢进草丛，嘟囔着『活狗强过死英雄』，拢着袖子回帐篷去了。" + nameB + " 虽有些不甘，还是乖乖把白蜡杆靠在车辕上，钻回补丁棉被里沉沉睡去。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		this.m.BroA = null;
		this.m.BroB = null;

		local master = ::Wuxia.Events.findByBackgrounds([
			"background.swordmaster",
			"background.retired_soldier",
			"background.kings_guard",
			"background.oathtaker",
			"background.hedge_knight"
		]);
		if (master == null) return;

		local rookie = ::Wuxia.Events.findByBackgrounds([
			"background.apprentice",
			"background.farmhand",
			"background.squire",
			"background.militia",
			"background.daytaler",
			"background.refugee"
		], master);
		if (rookie == null) return;

		this.m.BroA = master;
		this.m.BroB = rookie;
		this.m.Score = 17;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.BroA))
		{
			this.m.BroA = ::Wuxia.Events.findByBackgrounds([
				"background.swordmaster",
				"background.retired_soldier",
				"background.kings_guard",
				"background.oathtaker",
				"background.hedge_knight"
			]);
		}
		if (!::Wuxia.Events.isAlive(this.m.BroB))
		{
			this.m.BroB = ::Wuxia.Events.findByBackgrounds([
				"background.apprentice",
				"background.farmhand",
				"background.squire",
				"background.militia",
				"background.daytaler",
				"background.refugee"
			], this.m.BroA);
		}
	}

	function onPrepareVariables( _vars )
	{
		_vars.push(["master", ::Wuxia.Events.shortName(this.m.BroA)]);
		_vars.push(["rookie", ::Wuxia.Events.shortName(this.m.BroB)]);
	}

	function onClear()
	{
		this.m.BroA = null;
		this.m.BroB = null;
	}
});
