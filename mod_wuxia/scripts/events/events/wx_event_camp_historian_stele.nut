// Batch E1 Event 03: 残碑拓古（访古书生于营旁崖壁发现前朝残碑墨拓）

this.wx_event_camp_historian_stele <- this.inherit("scripts/events/event", {
	m = {
		BroA = null,
		BroB = null
	},

	function create()
	{
		this.m.ID = "event.wx_camp_historian_stele";
		this.m.Title = "残碑拓古";
		this.m.Cooldown = 42.0 * this.World.getTime().SecondsPerDay;

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
				local finderLead = ::Wuxia.Events.isAlive(_event.m.BroB)
					? (::Wuxia.Events.fmtName(_event.m.BroB) + " 去营旁青石崖根拾干柴时，脚底打滑蹭掉了一大片厚厚的黑苔")
					: ("营旁青石崖根被雨水冲塌了一角，露出半截斜插在乱石缝里的风化断碑");

				this.Text = "[img]gfx/ui/events/wx_ev_29.png[/img]" + finderLead + "，石面上赫然留着深浅不一的旧刀痕，以及几行瘦硬如铁钩的前朝古篆。" + nameA + " 凑上去瞧了一眼，激动得差点把鼻梁上的破布缠边眼镜摔进泥坑。\n\n他从行军锅底刮下黑亮锅烟灰，调了半碗冷稀饭浆糊，借着两张防潮粗油纸趴在湿崖上敲打了足足两个时辰，硬是拓出一卷墨迹分明的拓片。展开一看，碑阳原是某位失考边将的纪功铭，碑阴狭缝里竟暗藏了一小段劲气换步与吐纳诀窍，只是下半截早不知哪年崩进了深涧。\n\n" + nameA + " 沾满黑烟的手指微微发颤，问你这卷残碑拓片打算如何处置。";

				this.Options = [
					{
						Text = "连夜逐字释读古篆，把那段武理誊抄作队内秘藏残页！",
						function getResult( _event ) { return "DecipherPage"; }
					},
					{
						Text = "别死抠艰深古字了，把里头浅显的步法要旨讲给大伙听听。",
						function getResult( _event ) { return "ShareNotes"; }
					},
					{
						Text = "装进油竹筒，下个集镇卖给附庸风雅的乡绅老爷换现银！",
						function getResult( _event ) { return "SellRubbing"; }
					}
				];
			}
		});

		this.m.Screens.push({
			ID = "DecipherPage",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "古人笔墨，留给后人救命。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.givePage("sect", 1, this.List);
				::Wuxia.Events.addMood(_event.m.BroA, 1.25, "考据前朝残碑大有所获", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_29.png[/img]一盏牛油小灯从初更燃到五更。" + nameA + " 熏得两眼通红、连连呛咳，对照着腹中杂学旧典，将那些似字非字的古篆偏旁一一校出，用蝇头小楷工工整整誊写在麻纸上。\n\n虽因原碑崩毁只剩残章，可仅存的几句发劲转折已颇具名门气象，妥妥能当作一页上乘武学残章收藏研习。";
			}
		});

		this.m.Screens.push({
			ID = "ShareNotes",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "能活命的学问才是好学问。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addCompanyMastery(40, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "听古碑武理颇受启发", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_29.png[/img]" + nameA + " 将乌黑拓片钉在骡车挡板上，手执半截竹筷把晦涩碑文掰碎了讲成市井大白话——雨天烂泥里如何垫步不滑、迎着重枪怎生斜肩卸力。连几个大字不识一斗的糙汉也听得频频点头，围着火堆比划了半宿，众人平日练功滞涩之处竟隐隐松动了几分。";
			}
		});

		this.m.Screens.push({
			ID = "SellRubbing",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "古董不能当饭吃，纹银才实在。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addMoney(220, this.List);
				::Wuxia.Events.addMood(_event.m.BroA, -0.75, "心爱古拓被换作俗银", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_29.png[/img]" + nameA + " 脸皮抽搐了一下，那神情活像见你拿《兰亭序》去擦马屁股，可到底还是叹着气把拓片卷进腊封竹筒。\n\n行至下处驿集茶楼，一名专替州府大户收罗金石的管事只扫了一眼墨色，当场拍案叫绝，利索点出二百二十两沉甸甸的碎银买下。" + nameA + " 捧着茶碗坐在一旁，半晌没说一句话。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		this.m.BroA = null;
		this.m.BroB = null;

		local hist = ::Wuxia.Events.findByBackgrounds(["background.historian"]);
		if (hist == null) return;

		this.m.BroA = hist;
		this.m.BroB = ::Wuxia.Events.findRandomBro(hist);
		this.m.Score = 16;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.BroA))
			this.m.BroA = ::Wuxia.Events.findByBackgrounds(["background.historian"]);
		if (this.m.BroB != null && !::Wuxia.Events.isAlive(this.m.BroB))
			this.m.BroB = ::Wuxia.Events.findRandomBro(this.m.BroA);
	}

	function onPrepareVariables( _vars )
	{
		_vars.push(["historian", ::Wuxia.Events.shortName(this.m.BroA)]);
	}

	function onClear()
	{
		this.m.BroA = null;
		this.m.BroB = null;
	}
});
