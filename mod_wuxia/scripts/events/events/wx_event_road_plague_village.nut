// Road Strange-Tales Event 59: 瘟村白布封道（疫瘴荒村与投毒疑云）

this.wx_event_road_plague_village <- this.inherit("scripts/events/event", {
	m = {
		Healer = null
	},

	function create()
	{
		this.m.ID = "event.wx_road_plague_village";
		this.m.Title = "瘟村白布封道";
		this.m.Cooldown = 40.0 * this.World.getTime().SecondsPerDay;

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

				local hl = _event.m.Healer;
				if (::Wuxia.Events.isAlive(hl)) this.Characters.push(hl.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_27.png[/img]官道拐弯处横着几道刷满石灰的木栅，挂着一长串被风吹得猎猎作响的惨白招魂布幡。栅栏里头是一座鸦雀无声的村落，只有屋檐下零星传出撕心裂肺的咳喘声。两名裹着湿布蒙面的村老远远挥舞竹竿，嘶声喊道：『好汉莫近！半月前不知打哪儿飘来一股怪瘴，村里水井发绿，沾了水的人浑身起紫斑，官府早已封村等死……若贵队有多余伤药，求隔墙抛些进来，村里愿出全部凑下的私房银！』";

				this.Options.push({
					Text = "隔墙抛入 10 份伤药补给救人（不进村染疫）",
					function getResult( _ev )
					{
						if (::World.Assets.getMedicine() < 10) return "NoMeds";
						return "GiveMeds";
					}
				});
				if (::Wuxia.Events.isAlive(hl))
				{
					this.Options.push({
						Text = "令 " + ::Wuxia.Events.shortName(hl) + " 蒙湿巾入村验看井水，查明是天疫还是人祸！",
						function getResult( _ev ) { return "InspectWell"; }
					});
				}
				this.Options.push({
					Text = "事关人命瘟疫，全队掩住口鼻从上风口疾驰绕行。",
					function getResult( _ev ) { return "RideAway"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "GiveMeds",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "愿他们熬过这一劫。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addSupplies(0, -10, 0, this.List);
				::Wuxia.Events.addMoney(240, this.List);
				::Wuxia.Events.givePill("wx_pill_huxin", this.List);
				::Wuxia.Events.addSectRel("xinglin_yi", 22, this.List);
				::Wuxia.Events.addReputation(25, 8, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "赠药救疫村，不愧江湖义士", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_27.png[/img]众人将十包金疮草药与雄黄散包紧抛过石灰栅栏。村老们扑跪在地上连连叩首，用长竹竿挑出一只熏过烈酒艾烟的竹篮递回栅外——里头是全村凑出的二百四十两银子，还有一位曾在此留宿的杏林游医留下的【护心丹】。日后此事传至【杏林济世堂】，诸位大夫皆对你们赞不绝口。";
			}
		});

		this.m.Screens.push({
			ID = "InspectWell",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "原来不是天灾，是邪毒作祟！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local hl = _event.m.Healer;
				if (::Wuxia.Events.isAlive(hl)) this.Characters.push(hl.getImagePath());

				::Wuxia.Events.giveItem("scripts/items/misc/poison_gland_item", this.List);
				::Wuxia.Events.givePill("wx_pill_qingxin", this.List);
				::Wuxia.Events.addSectRel("xinglin_yi", 18, this.List);
				::Wuxia.Events.addReputation(20, 8, this.List);
				if (::Wuxia.Events.isAlive(hl))
				{
					::Wuxia.Events.addMastery(hl, 55, this.List);
					::Wuxia.Events.addMood(hl, 1.0, "查出投毒祸首，挽救一村性命", this.List);
				}

				this.Text = "[img]gfx/ui/events/wx_ev_27.png[/img]" + ::Wuxia.Events.fmtName(hl) + " 以烈酒浸湿面巾，携铁钩探查村中大井，果然在井壁暗缝里勾起一只腐烂发黑的异兽五毒腺囊——这根本不是什么无药可医的瘟疫，而是邪派毒手或是流窜妖虫污染了水源！他立刻教村民封井改饮山泉，并以草木灰配绿豆煎汤解毒；村民感激涕零，你则将那只罕见毒囊妥善封罐带走。";
			}
		});

		this.m.Screens.push({
			ID = "NoMeds",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "只得绕道而行。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_27.png[/img]清点随队伤药竟凑不足十份，眼下泥菩萨过江自身难保。你朝栅栏内遥遥拱手致歉，带队从上风口默默绕了过去。";
			}
		});

		this.m.Screens.push({
			ID = "RideAway",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "莫回头，快走。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_27.png[/img]乱世瘟瘴专吞活人，刀剑砍不死病气。你下令全队拉高衣领从上风坡迅速绕过，身后那片在冷风中翻飞的惨白布幡许久才淡出视线。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (this.World.getTime().Days < 10) return;
		this.m.Healer = ::Wuxia.Events.findByBackgrounds([
			"background.anatomist", "background.monk", "background.witchhunter", "background.historian"
		]);
		this.m.Score = 13;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Healer = null;
	}
});
