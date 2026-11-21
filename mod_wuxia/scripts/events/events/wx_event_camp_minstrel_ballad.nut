// Batch E1 Event 10: 江湖打油词（说书人/卖艺人将队里血战窘事编成朗朗上口的莲花落小调）

this.wx_event_camp_minstrel_ballad <- this.inherit("scripts/events/event", {
	m = {
		BroA = null
	},

	function create()
	{
		this.m.ID = "event.wx_camp_minstrel_ballad";
		this.m.Title = "江湖打油词";
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
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]火星顺着暮风旋上半空，" + nameA + " 两片油亮竹板在膝盖上敲得劈啪带响，摇头晃脑哼起一段新编的江湖莲花落。词儿糙得满嘴荤素不忌，偏偏句句踩在你们前些日子那几场恶战的节骨眼上——唱到绿林寨主见了咱们的横刀吓湿了裤裆，又唱到某位弟兄冲阵时被猪槽绊了个狗啃泥却顺势捅翻俩匪徒，押着血锈与浊酒的韵脚，惹得满营糙汉拍着大腿笑出了眼泪。\n\n一曲刚收尾，" + nameA + " 眨着精明的眼珠子凑过来压低嗓门：\n\n『东家，咱们刀口讨饭，靠的不光是铁家伙，还得靠茶馆酒肆里那些闲汉的嘴！下回进镇若肯赏 80 两酒水钱，让我请几桌脚夫、跑堂和同行说书先生喝个痛快，把这支打油词顺着官道唱出去——不出三天，方圆百里的镖局商行都得念叨咱们的大名！』";

				this.Options = [
					{
						Text = "赏你 80 银两！下回进镇请酒肆闲汉喝两壶，把这曲子唱响！",
						function getResult( _event )
						{
							if (::World.Assets.getMoney() < 80) return "NoMoney";
							return "SpreadBallad";
						}
					},
					{
						Text = "花那冤枉钱作甚？留着今夜围着火堆再唱两段，图大伙儿一乐！",
						function getResult( _event ) { return "CampfireLaugh"; }
					},
					{
						Text = "少在营里编排荤词惹是非，有这闲工夫不如把腰刀磨快些！",
						function getResult( _event ) { return "ShutUp"; }
					}
				];
			}
		});

		this.m.Screens.push({
			ID = "SpreadBallad",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "名声响了，往后谈红货价钱才硬气。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addMoney(-80, this.List);
				::Wuxia.Events.addReputation(40, 0, this.List);
				::Wuxia.Events.addCompanyMood(1.0, "自家血战事迹传唱茶楼酒肆", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]到了下处市集，" + nameA + " 揣着银子一头扎进最热闹的骡马店酒棚，见人就筛黄酒、拍竹板，把你们那几场血糊糊的恶仗添油加醋唱得活色生香。不出数日，连县衙班房的捕快与过路行商嘴里都哼起了那几句打油副歌，看你们旗号的眼神顿时多了几分忌惮与敬重。";
			}
		});

		this.m.Screens.push({
			ID = "CampfireLaugh",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "难得有一夜不用惦记明天的死活。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addCompanyMood(1.0, "火堆旁听打油词笑翻了天", this.List);
				::Wuxia.Events.addMood(_event.m.BroA, 0.75, "满营喝彩过足了说书瘾", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]" + nameA + " 干脆爬上粮草车顶，借着火光连编带唱又添了三段，把大伙的呼噜声、臭脚丫、赌输当裤子全编进了词里，末了连你这个东家也没放过，惹来一阵鞋底与欢呼齐飞。荒郊冷夜里，紧绷了许久的弟兄们难得笑得直不起腰来。";
			}
		});

		this.m.Screens.push({
			ID = "ShutUp",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "少说废话，多活两天才是正经。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addMood(_event.m.BroA, -0.75, "满腹好词无人赏识", this.List);
				::Wuxia.Events.addMastery(_event.m.BroA, 30, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]" + nameA + " 啪嗒合起竹板，朝你煞有介事打了个千，悻悻缩回车厢暗处摸出磨刀石。嘴里虽不敢再唱，却仍小声嘀咕着『铁面冷脸的头儿，历来进不了好戏本子』，闷头练了半宿手腕劲。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "换个法子安排。", function getResult( _event ) { return "A"; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_31.png[/img]掂了掂行囊，竟连 80 两请酒钱都挤不出来，只好作罢另选。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		this.m.BroA = null;

		local bard = ::Wuxia.Events.findByBackgrounds([
			"background.minstrel",
			"background.juggler"
		]);
		if (bard == null) return;

		this.m.BroA = bard;
		this.m.Score = 16;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.BroA))
		{
			this.m.BroA = ::Wuxia.Events.findByBackgrounds([
				"background.minstrel",
				"background.juggler"
			]);
		}
	}

	function onPrepareVariables( _vars )
	{
		_vars.push(["minstrel", ::Wuxia.Events.shortName(this.m.BroA)]);
	}

	function onClear()
	{
		this.m.BroA = null;
	}
});
