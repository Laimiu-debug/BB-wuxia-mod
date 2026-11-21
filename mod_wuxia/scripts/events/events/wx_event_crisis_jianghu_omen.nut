// Late-Game Crisis Event 60: 武林大势·风云变色（动态响应四大武林危机或中后期乱世风云）

this.wx_event_crisis_jianghu_omen <- this.inherit("scripts/events/event", {
	m = {
		CrisisKey = "",
		VetBro = null
	},

	function create()
	{
		this.m.ID = "event.wx_crisis_jianghu_omen";
		this.m.Title = "武林大势·风云变色";
		this.m.Cooldown = 48.0 * this.World.getTime().SecondsPerDay;

		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "趁乱打扫沿途残阵，收集精铁甲片、伤药与遗落盘缠",
					function getResult( _ev ) { return "Salvage"; }
				},
				{
					Text = "借烽火立誓整军，彻夜演武提振战意！（全队火候大涨 + 士气高昂）",
					function getResult( _ev ) { return "WarOath"; }
				},
				{
					Text = "向溃散军医花 420 银两急购战备灵丹（虎骨壮气丸 + 易筋活络膏）",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 420) return "NoMoney";
						return "BuyWarPills";
					}
				}
			],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local vet = _event.m.VetBro;
				if (::Wuxia.Events.isAlive(vet)) this.Characters.push(vet.getImagePath());

				local ck = _event.m.CrisisKey;
				local intro = "";
				if (ck == "greenskins")
					intro = "远方天际升起数股浓黑狼烟，道旁尽是惊惶南逃的商旅——【邪派炼体药人与五毒奇门联军】已破开三处关隘，狂暴药人如恶潮般横扫乡野，所过之处铁盾碎裂、毒瘴蔽日！";
				else if (ck == "undead")
					intro = "白昼竟似黄昏般晦暗，荒野吹来的寒风裹着浓郁腐土与旧铜锈气——【前朝古墓金甲卫与湘西赶尸邪宗】趁地脉阴变倾巢而出，死寂不惧痛楚的尸傀大军正在逼近州府！";
				else if (ck == "civilwar")
					intro = "官道两侧旗幡倒伏、焦木尚燃，【地方藩镇节度使与门阀世家】已彻底撕破脸皮陈兵死斗，长戟强弩与世家供奉剑客在各州城下日夜厮杀，遍地皆是溃兵与伤员！";
				else if (ck == "holywar")
					intro = "南北道统之争终于演成血火大劫！中原群雄与西域军镇火器营在关隘前杀得血流成河，连平日高坐云端的各大宗门也纷纷尽遣精锐下山入局！";
				else
					intro = "秋风萧瑟，官道上逃难的车马与负伤的江湖游侠络绎不绝。各方藩镇、邪派魔窟与大荒山海异兽似乎在同一时节齐齐躁动起来，一场席卷整座江湖的大风暴已迫在眉睫！";

				this.Text = "[img]gfx/ui/events/wx_ev_25.png[/img]" + intro + "\n\n前方断坡下横七竖八停着几辆遭劫的军需大车，一名跌断腿的随军郎中正抱紧药箱缩在车底喘息。" + ::Wuxia.Events.fmtName(vet) + " 按着刀柄望向远方滚滚烟尘，低声问你：『大势既乱，咱们这支队伍接下来该如何备战？』";
			}
		});

		this.m.Screens.push({
			ID = "Salvage",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "粮草兵甲足，乱世方能活。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addSupplies(20, 12, 15, this.List);
				::Wuxia.Events.addMoney(220, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_25.png[/img]众弟兄手脚麻利地拆下翻覆军车上的完好甲叶、强弩箭匣与止血药包，又从散落钱箱里捡起二百余两官银。乱世之中仁义难当饭吃，先把刀磨快、把甲补牢才是硬道理。";
			}
		});

		this.m.Screens.push({
			ID = "WarOath",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "大风起兮，正好试剑！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local vet = _event.m.VetBro;
				if (::Wuxia.Events.isAlive(vet)) this.Characters.push(vet.getImagePath());

				::Wuxia.Events.addCompanyMastery(60, this.List);
				::Wuxia.Events.addCompanyMood(1.0, "烽火前同饮血酒立誓，斗志如虹", this.List);
				if (::Wuxia.Events.isAlive(vet))
					::Wuxia.Events.addStat(vet, "Bravery", 2, "定力", "ui/icons/bravery.png", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_25.png[/img]你在篝火旁砸开烈酒坛，与众弟兄共饮壮行血酒，随即便地按阵形拆招演武至深夜。越是山雨欲来，这群从死人堆里爬出来的江湖汉子眼中反而越亮，全队武学火候与胆魄齐齐拔高一截！";
			}
		});

		this.m.Screens.push({
			ID = "BuyWarPills",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "有丹在手，硬仗不慌。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addMoney(-420, this.List);
				::Wuxia.Events.givePill("wx_pill_hugu", this.List);
				::Wuxia.Events.givePill("wx_pill_huoluo", this.List);
				::Wuxia.Events.addReputation(15, 4, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_25.png[/img]你付给惊魂未定的随军郎中四百二十两路费，还帮他把断腿打好夹板送上了顺路驴车。老郎中千恩万谢，将压箱底的【虎骨壮气丸】与【易筋活络膏】尽数交予你们备战之用。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "改拾残阵军需罢。", function getResult( _event ) { return "Salvage"; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_25.png[/img]摸摸银袋凑不出四百二十两现银，老郎中叹了口气背着药箱一瘸一拐走了，你们转而收拾路旁散落的军需器械。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		local ck = ::Wuxia.Events.getActiveCrisis();
		if (ck == "" && this.World.getTime().Days < 55) return;
		local vet = ::Wuxia.Events.findVeteranBro(1);
		if (vet == null) return;
		this.m.CrisisKey = ck;
		this.m.VetBro = vet;
		this.m.Score = ck != "" ? 20 : 12;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.CrisisKey = "";
		this.m.VetBro = null;
	}
});
