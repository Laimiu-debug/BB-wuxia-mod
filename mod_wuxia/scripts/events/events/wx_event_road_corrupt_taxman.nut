// Road Dilemma Event 58: 贪吏勒索茶盐税（关卡横征暴敛与江湖硬气）

this.wx_event_road_corrupt_taxman <- this.inherit("scripts/events/event", {
	m = {
		OfficialBro = null,
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_road_corrupt_taxman";
		this.m.Title = "贪吏勒索茶盐税";
		this.m.Cooldown = 35.0 * this.World.getTime().SecondsPerDay;

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

				local off = _event.m.OfficialBro;
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(off)) this.Characters.push(off.getImagePath());
				else if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_26.png[/img]刚行至官渡木卡，几根包铁拒马便吱呀横在路心。一名挺着圆滚肚腩的藩镇税吏斜倚在太师椅上磕瓜子，身旁十余名挎着锈刀的衙役狐假虎威地敲打木栏。税吏眯着三角眼把你们从头打量到脚，尖着嗓子拉长调门：『新任节度使大人有令！凡带刀过境的江湖行帮，一律先缴二百八十两「护道茶盐助饷银」，少一文就地以私盐匪党论处！』\n\n卡口外头，十几个挑柴进城的乡民已被抢光了铜板，正蹲在路边抹泪。";

				if (::Wuxia.Events.isAlive(off))
				{
					this.Options.push({
						Text = "让 " + ::Wuxia.Events.shortName(off) + " 搬出官场门路与军镇黑话，镇住这厮！",
						function getResult( _ev ) { return "BluffOfficial"; }
					});
				}
				this.Options.push({
					Text = "破财免灾，甩下 280 银两打发这帮吸血衙虫。",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 280) return "NoMoney";
						return "PayToll";
					}
				});
				this.Options.push({
					Text = "刀剑出鞘砸烂卡门，把他的黑账簿扔进河里！",
					function getResult( _ev ) { return "SmashGate"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "BluffOfficial",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "恶人自有官话治。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local off = _event.m.OfficialBro;
				if (::Wuxia.Events.isAlive(off)) this.Characters.push(off.getImagePath());

				::Wuxia.Events.addReputation(25, 4, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "不费一文银子唬退贪婪税吏", this.List);
				if (::Wuxia.Events.isAlive(off))
					::Wuxia.Events.addMood(off, 1.0, "借官场门路戏耍税吏", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_26.png[/img]" + ::Wuxia.Events.fmtName(off) + " 负手踱步上前，不紧不慢报出藩镇幕府里几位真管事的讳号与暗账规矩，顺口冷笑问这税吏『收的银子入的是哪房私库，可曾报备过兵备道？』胖税吏听得冷汗顺着肥腮往下淌，立马换副哈巴狗笑脸挥手撤开拒马，连声赔罪恭送你们过渡，引得全队哄堂大笑。";
			}
		});

		this.m.Screens.push({
			ID = "PayToll",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "忍一时风平浪静。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addMoney(-280, this.List);
				::Wuxia.Events.addCompanyMood(-0.5, "被贪婪税吏白白勒索银两", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_26.png[/img]你按下跃跃欲试的众弟兄，咬牙抛出一袋纹银。胖税吏笑眯眯咬了口银角子才放行；走出半里远，身后还传来众弟兄压低嗓子的骂娘声。";
			}
		});

		this.m.Screens.push({
			ID = "SmashGate",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "痛快！上路！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addMoney(180, this.List);
				::Wuxia.Events.addReputation(30, 6, this.List);
				::Wuxia.Events.addCompanyMood(1.0, "掀翻黑卡痛惩贪吏，大快人心", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_26.png[/img]锵啷数声清响，十余口明晃晃的战刀长枪同时亮出寒光！那些平日只敢欺压挑夫的衙役见真撞上了硬茬，立马丢掉水火棍一哄而散；胖税吏滚下太师椅连帽翅都跌歪了。众弟兄一脚踹翻木卡、把黑账撕进大河，分还乡民碎铜后将税吏藏在椅垫下的百八十两赃银收归军费，扬长而去！";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "既没钱，便凭手里铁家伙说话！", function getResult( _event ) { return "SmashGate"; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_26.png[/img]你们身上压根凑不出二百八十两现银，那贪吏竟挥手叫衙役上前搜马鞍——这下连最沉稳的弟兄都忍无可忍，干脆掀了他的黑卡！";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (this.World.getTime().Days < 7) return;
		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.OfficialBro = ::Wuxia.Events.findByBackgrounds([
			"background.adventurous_noble", "background.kings_guard", "background.manhunter",
			"background.eunuch", "background.disowned_noble", "background.retired_soldier"
		]);
		this.m.Score = 13;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.OfficialBro = null;
		this.m.Bro = null;
	}
});
