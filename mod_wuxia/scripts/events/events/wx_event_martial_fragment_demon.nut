// Batch E3-27: 残篇心魔（强练残页秘籍引发的深夜幻觉与鼻血危机）

this.wx_event_martial_fragment_demon <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function wxPickFragmentName( _bro )
	{
		if (!::Wuxia.Events.isAlive(_bro)) return "残缺秘籍";
		local c = ::Wuxia.Slots.getContainer(_bro);
		if (c != null)
		{
			foreach (s in c.m.Slots)
			{
				if (s.ManualID != null && s.IsFragment)
				{
					local def = ::Wuxia.Slots.getManualDef(s.ManualID);
					if (def != null) return "《" + def.Name + "》残篇";
				}
			}
		}
		return ::Wuxia.Events.pickManualName(_bro) + "残篇";
	}

	function create()
	{
		this.m.ID = "event.wx_martial_fragment_demon";
		this.m.Title = "残篇心魔";
		this.m.Cooldown = 20.0 * this.World.getTime().SecondsPerDay;

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

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				local bName = ::Wuxia.Events.fmtName(bro);
				local fragName = _event.wxPickFragmentName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]半夜值哨的弟兄铁青着脸把你摇醒，指了指拴骡马的矮林。暗影里，" + bName + "正蹲在一块青石前，捏着半截烧焦木炭疯了似地乱画歪斜经脉图，嘴里翻来覆去念叨着" + fragName + "上缺失的半句口诀。\n\n两道乌黑鼻血顺着人中淌进胡茬里，他却浑然不觉，双瞳散大，冲着空无一人的荒草连连出招——硬靠臆测去补残章断页，心神已被血雾幻象缠住了！";

				this.Options.push({
					Text = "花 180 银两向路经药贩讨安神草与陈年浊酒替他压惊定魂",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 180) return "NoMoney";
						return "SoothHerbs";
					}
				});

				this.Options.push({
					Text = "莫惊动他，且看他能否凭狠劲杀穿这片血雾幻境！",
					function getResult( _ev )
					{
						return ::Math.rand(1, 100) <= 50 ? "BloodEpiphany" : "BloodBackfire";
					}
				});

				this.Options.push({
					Text = "一巴掌抽醒，收了木炭押回铺盖卷里强令安睡。",
					function getResult( _ev ) { return "SlapAwake"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "SoothHerbs",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "留得神智清明，比什么奇功都金贵。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]你赶忙派人骑快马奔去近处野驿，花 180 银两敲开药铺后门，购回酸枣仁、朱砂安神散与一坛老烧酒。煎汤配酒灌下去不过两刻，" + bName + "紧绷如铁的肩背便一点点松软下来，鼻血止住，眼中血丝渐退。\n\n待次日天亮，他盯着石板上昨晚乱画的鬼画符一阵后怕，却也从此识破了魔障虚实，心性较往日更沉稳了一分。";

				::Wuxia.Events.addMoney(-180, this.List);
				::Wuxia.Events.addStat(bro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
				::Wuxia.Events.addMood(bro, 0.4, "安神药酒化去残篇魔障", this.List);
			}
		});

		this.m.Screens.push({
			ID = "BloodEpiphany",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "疯魔一线间，竟真被他摸出条活路！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);
				local fragName = _event.wxPickFragmentName(bro);

				local isSkill = (::Math.rand(0, 1) == 0);
				if (isSkill)
				{
					this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]你按剑立在三步外替他挡风，任由" + bName + "对着月影疯劈乱刺。忽然间，他凌乱的步子骤然一顿，木炭从指间咔嗒折断——在无数重叠交错的虚影里，他竟凭着尸山血海里磨出的直觉，硬从" + fragName + "的缺口中斩出了一记最利落的收锋！\n\n血雾散尽，他擦掉唇边血迹仰天长笑，出招的狠准竟无形间又利落了一筹。";
					::Wuxia.Events.addStat(bro, "MeleeSkill", 1, "武艺", "ui/icons/melee_skill.png", this.List);
				}
				else
				{
					this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]你按剑守在一旁，冷眼看着" + bName + "在虚空里同无形恶鬼厮杀。眼看他额头青筋暴跳、几欲癫狂，却听他陡然爆喝一声，竟把满脑子撕扯耳膜的怪啸硬生生喝散！\n\n一屁股坐回冷露草皮上，他擦净鼻血长舒一口气：见识过" + fragName + "招来的心魔，世间寻常鬼魅刀兵倒显得不值一提了。";
					::Wuxia.Events.addStat(bro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
				}

				::Wuxia.Events.addMood(bro, 1.0, "杀穿残篇血雾，心境陡然通明", this.List);
			}
		});

		this.m.Screens.push({
			ID = "BloodBackfire",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "残篇害人，赶紧抬回去照看！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]血雾非但没散，反越裹越紧。" + bName + "猛然嘶喊一声，一头撞向树干，手臂在粗树皮上擦得血肉模糊，紧接着胸口如遭重锤闷击，捂着心窝跪倒在地干呕不止。\n\n众人七手八脚将他按住抬回营帐。皮外擦伤倒还好说，经脉里蹿乱的邪气却得靠好几日调养才压得下去。";

				::Wuxia.Events.applyLightHurt(bro, 0.14, this.List);
				::Wuxia.Events.applyInternalStrain(bro, 2, this.List);
			}
		});

		this.m.Screens.push({
			ID = "SlapAwake",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "睡死过去倒也清净。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]你大步上前，啪地甩出一记清脆耳光，打得林子里回声阵阵。" + bName + "捂着火辣辣的腮帮子愣在原地，浑浊眼神顿时清明了大半，再看满手黑灰与鼻血，讪讪地低下了头。\n\n你一把夺过木炭丢进暗沟，盯着他灌了半瓢凉水钻回毛毡。不多时，帐里便响起了沉实如雷的鼾声。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "银两不够，只得另想办法。", function getResult( _ev ) { return "A"; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.Bro)) this.Characters.push(_event.m.Bro.getImagePath());
				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]摸摸腰囊，现银尚不足 180 两，半夜里药贩可不会赊账。眼看状况吃紧，只能再作计较。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		local bro = ::Wuxia.Events.findBroWithFragment();
		if (bro == null) return;

		this.m.Bro = bro;
		this.m.Score = 28;
	}

	function onClear()
	{
		this.m.Bro = null;
	}
});
