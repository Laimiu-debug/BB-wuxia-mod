// Batch E3-26: 阴阳逆冲·走火危机（双内功相克触发的深夜经脉暴走事件）

this.wx_event_martial_conflict_crisis <- this.inherit("scripts/events/event", {
	m = {
		Bro = null,
		Healer = null
	},

	function wxGetConflictText( _bro )
	{
		if (!::Wuxia.Events.isAlive(_bro)) return "两门相冲心法";
		local c = ::Wuxia.Slots.getContainer(_bro);
		if (c == null) return "两门相冲心法";
		local names = [];
		foreach (s in c.m.Slots)
		{
			if (s.ManualID == null || s.Tier <= 0) continue;
			local def = ::Wuxia.Slots.getManualDef(s.ManualID);
			if (def != null && def.Category == "neigong")
			{
				names.push("《" + def.Name + "》");
			}
		}
		if (names.len() >= 2) return names[0] + "与" + names[1];
		if (names.len() == 1) return names[0] + "与体内异种真气";
		return "两门相冲心法";
	}

	function create()
	{
		this.m.ID = "event.wx_martial_conflict_crisis";
		this.m.Title = "阴阳逆冲·走火危机";
		this.m.Cooldown = 22.0 * this.World.getTime().SecondsPerDay;

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
				local healer = _event.m.Healer;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				if (::Wuxia.Events.isAlive(healer)) this.Characters.push(healer.getImagePath());

				local bName = ::Wuxia.Events.fmtName(bro);
				local clash = _event.wxGetConflictText(bro);
				local meds = ::World.Assets.getMedicine();

				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]三更梆子早歇，营火烧得只剩一层惨白灰烬。车辕底下忽然传来风箱拉扯般的粗喘，你披衣寻去，只见" + bName + "僵硬地盘坐在冷露里，左半张脸涨得如炭火紫红，右半边脖颈却结着一层冰凉黏汗。\n\n十指死死抠进木轮辐条，指甲缝渗出血珠——" + clash + "本就水火不容，子夜行功一个岔念，两股霸道真气竟在膻中穴迎头撞作一团！若不立时处置，轻则经脉寸损，重则立成废人。";

				if (::Wuxia.Events.isAlive(healer))
				{
					local hName = ::Wuxia.Events.shortName(healer);
					this.Options.push({
						Text = "急唤 " + hName + " 上前点穴施针，借禅理医道疏导逆气！",
						function getResult( _ev ) { return "HealerGuide"; }
					});
				}

				this.Options.push({
					Text = "取 8 份伤药化温汤护心，按穴强行平复经脉（现有伤药：" + meds + "）",
					function getResult( _ev )
					{
						if (::World.Assets.getMedicine() < 8) return "NoMedicine";
						return "MedGuide";
					}
				});

				this.Options.push({
					Text = "令其咬碎钢牙，凭自身定力硬将两股逆气镇压入丹田！",
					function getResult( _ev )
					{
						return ::Math.rand(1, 100) <= 50 ? "ForceSuccess" : "ForceFail";
					}
				});

				this.Options.push({
					Text = "别冒险！拎一桶冷井水劈头浇下，硬逼他散掉浮气。",
					function getResult( _ev ) { return "ColdWater"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "HealerGuide",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "险些铸成大错，多亏有行家在侧。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				local healer = _event.m.Healer;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				if (::Wuxia.Events.isAlive(healer)) this.Characters.push(healer.getImagePath());

				local bName = ::Wuxia.Events.fmtName(bro);
				local hName = ::Wuxia.Events.fmtName(healer);

				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]" + hName + "赶到时面色沉静如水，并未蛮干硬压，只伸两指快如穿花，连点" + bName + "百会、神庭、灵台三处大穴，口中低声喝破行气节拍，引着那股暴烈热流顺督脉缓泻，阴寒之气则绕任脉回环。\n\n半柱香后，" + bName + "长长吐出一口带焦腥味的白浊，周身冷热潮红尽退。经此一劫，反把两门内息的关窍摸得透亮了几分，心胆亦愈发沉稳。";

				::Wuxia.Events.addMastery(bro, 70, this.List);
				::Wuxia.Events.addStat(bro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
			}
		});

		this.m.Screens.push({
			ID = "MedGuide",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "药石虽贵，终究保住了根基。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]你立即撕开药囊，抓出烈性安神草与温经散胡乱碾碎，拿滚烫的炭火水冲成一碗苦黑浓汤撬开" + bName + "牙关灌下，又让两名力大的弟兄按住其肩井，死死护住心口不教逆气上冲泥丸。\n\n煎熬至五更天边泛青，" + bName + "浑身湿透如从河底捞出，胸中那两头恶虎终于被药力强按回笼。喘定之后，眼中竟闪过几分劫后余生的清明，对内息火候的拿捏大进。";

				::Wuxia.Events.addSupplies(0, -8, 0, this.List);
				::Wuxia.Events.addMastery(bro, 70, this.List);
				::Wuxia.Events.addStat(bro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);
			}
		});

		this.m.Screens.push({
			ID = "ForceSuccess",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "真是个不要命的狠角色！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]你喝止众人上前，只让" + bName + "咬住一截浸湿的硬皮带，自己死死守住灵台清明。" + bName + "喉间爆出一声野兽般的低吼，额角青筋条条凸起，硬是不退半步，拿血肉经脉作炉鼎，把冰火两股叛逆真气死死压回气海。\n\n喀喇一声轻响，皮带竟被生生咬断。待白雾从头顶百会袅袅散去，" + bName + "睁开双眼精光慑人——不仅化险为夷，竟在生死压榨间冲破了多日苦修不得的关隘！";

				::Wuxia.Events.addMastery(bro, 100, this.List);
				::Wuxia.Events.addMood(bro, 1.0, "强压阴阳逆冲反得武学大悟", this.List);
			}
		});

		this.m.Screens.push({
			ID = "ForceFail",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "扶进帐里歇着，莫再逞强。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]" + bName + "死咬牙关硬顶了十来息，终究敌不过两股异种内劲在胸腹间轰然炸开。哇地一声，一口暗红淤血喷在车轮上，整个人如断线风筝般向后仰倒。\n\n好在命是保住了，只是经脉被震得七零八落，短时间里怕是连提一口真气都要隐隐作痛。";

				::Wuxia.Events.applyInternalStrain(bro, 3, this.List);
			}
		});

		this.m.Screens.push({
			ID = "ColdWater",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "落个风寒总比走火入魔强。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());
				local bName = ::Wuxia.Events.fmtName(bro);

				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]哗啦一声，满桶透骨的冷井水劈头盖脸浇了下去。" + bName + "激灵灵打了个寒颤，正欲暴走的真气被这一桶刺骨寒意惊得瞬间溃散，人也彻底清醒过来。\n\n性命经脉算是毫发无损，可被你在大冷夜里浇成落汤鸡，" + bName + "裹着湿毯子蹲在灶坑边咳了半宿，脸色黑得像锅底。";

				::Wuxia.Events.addMood(bro, -0.85, "子夜行功被一桶冷水浇散", this.List);
			}
		});

		this.m.Screens.push({
			ID = "NoMedicine",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "另寻他法！", function getResult( _ev ) { return "A"; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.Bro)) this.Characters.push(_event.m.Bro.getImagePath());
				this.Text = "[img]gfx/ui/events/wx_ev_08.png[/img]你翻遍药匣，残存的伤药不足 8 份，根本凑不齐护心汤的分量，只得赶紧改用别法救人！";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		local bro = ::Wuxia.Events.findBroWithConflict();
		if (bro == null) return;

		this.m.Bro = bro;
		this.m.Healer = ::Wuxia.Events.findByBackgrounds(["background.monk", "background.anatomist"], bro);
		this.m.Score = 30;
	}

	function onClear()
	{
		this.m.Bro = null;
		this.m.Healer = null;
	}
});
