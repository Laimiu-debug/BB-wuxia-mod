// Batch E1 Event 12: 义庄听土（掘土人/摸金客在荒道湿坟旁听见棺榫异响与阴沉药气）

this.wx_event_camp_gravedigger_omen <- this.inherit("scripts/events/event", {
	m = {
		BroA = null,
		BroB = null
	},

	function create()
	{
		this.m.ID = "event.wx_camp_gravedigger_omen";
		this.m.Title = "义庄听土";
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
				local shortA = ::Wuxia.Events.shortName(_event.m.BroA);
				local worriedLine = ::Wuxia.Events.isAlive(_event.m.BroB)
					? ("\n\n远处的火堆边，" + ::Wuxia.Events.fmtName(_event.m.BroB) + " 早已缩紧了脖子，手里死死攥着一枚磨得发亮的铜钱平安符，小声嘀咕着荒郊野坟沾了准没好果子吃。")
					: "";

				this.Text = "[img]gfx/ui/events/wx_ev_18.png[/img]入夜后白雾贴地漫过营外三十步的一座无名塌坟，坟头长满苦艾与发黑的野枸杞。旁人巴不得离这晦气地方越远越好，" + nameA + " 却独自跪在湿泥里，把一只风霜满布的耳朵紧紧贴在半截塌陷的青砖上听了良久，又拈起一撮阴冷黑土放到鼻端轻嗅。\n\n他站起身拍去膝头泥水，嗓音干巴巴得像枯木摩擦棺板：\n\n『土色发青，草根发黑，底下透出一丝极淡的陈年沉香混着阴尸气……方才地底还轻轻叩了三下——不是野獾打洞，是老柏木棺材受潮崩榫，多半是前朝走阴人物的偏穴，侧耳室里还压着镇魂陪葬的药匣与散银。要动铁锹得趁鸡叫前，只撬耳室不惊主棺；不然就烧叠黄纸敬碗薄酒，免得冲撞了地气。』" + worriedLine;

				this.Options = [
					{
						Text = "既摸准了偏穴门道，点起艾草让 " + shortA + " 小心起土探一探！",
						function getResult( _event ) { return "DigMound"; }
					},
					{
						Text = "入土为安，莫贪这点阴财——焚一刀黄裱纸、洒半壶浊酒求个平安。",
						function getResult( _event ) { return "OfferWine"; }
					},
					{
						Text = "这鬼地方邪门得很！立刻扑灭篝火拔营，连夜走出十里再歇！",
						function getResult( _event ) { return "BreakCamp"; }
					}
				];
			}
		});

		this.m.Screens.push({
			ID = "DigMound",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "死人的银子，照样买得到活人的干粮。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addMoney(180, this.List);
				::Wuxia.Events.givePill("wx_pill_dingshen", this.List);
				::Wuxia.Events.addMood(_event.m.BroA, 0.75, "听土摸穴稳准无失", this.List);
				if (::Wuxia.Events.isAlive(_event.m.BroB))
					::Wuxia.Events.addMood(_event.m.BroB, -0.75, "夜掘荒冢听见雾里怪响心头直发毛", this.List);

				local spookText = ::Wuxia.Events.isAlive(_event.m.BroB)
					? ("\n\n偏生起出匣子那一刻，坑底涌出一阵刺骨冷风，夹着腐朽线香与湿骨气味直扑面门。" + ::Wuxia.Events.fmtName(_event.m.BroB) + " 浑身打了个寒战，死活发誓自己听见白雾深处传来了一声干枯的轻笑，这一宿再没敢合眼。")
					: "\n\n起出匣子后坑底涌出一阵刺骨冷风，你让人速速回填湿土踩实，带着战利品匆匆退回火光之中。";

				this.Text = "[img]gfx/ui/events/wx_ev_18.png[/img]" + nameA + " 下锹极有章法，避开正中漆黑腐朽的主棺板，只斜斜掏开一尺见方的青砖偏龛。里头那只松香封口的铜匣竟还严实，撬开一看，除了几锭发乌的旧银锞子，还有一只蜡封完好的细颈瓷瓶——倒出少许朱砂琥珀细末一闻，正是道门秘传、夜战镇魂的【明目定神散】！" + spookText;
			}
		});

		this.m.Screens.push({
			ID = "OfferWine",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "敬鬼神而远之，夜路走得踏实。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addStat(_event.m.BroA, "Bravery", 2, "定力", "ui/icons/bravery.png", this.List);
				::Wuxia.Events.addMood(_event.m.BroA, 1.0, "依古礼安抚荒冢，心境愈发沉定", this.List);
				::Wuxia.Events.addCompanyMood(0.5, "焚纸敬酒后心头安稳了许多", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_18.png[/img]" + nameA + " 从行囊角落摸出一叠发皱的粗黄裱纸，在坟前掘出浅坑引火点燃，又提着粗瓷酒壶凌空划了三道弧，把半壶辛辣米酒稳稳洒进青草丛里，口中低声念着几句义庄老人流传下来的镇土词。\n\n说来也怪，纸灰随风打着旋儿升起后，缠绕营盘的阴冷白雾竟渐渐退回了山沟。" + nameA + " 负手立于暗夜之中，眉宇间沉淀出一股见惯生死方有的铁石静气。";
			}
		});

		this.m.Screens.push({
			ID = "BreakCamp",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "宁可多走十里冤枉路，不沾荒坟半点邪气。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());
				if (::Wuxia.Events.isAlive(_event.m.BroB)) this.Characters.push(_event.m.BroB.getImagePath());

				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				::Wuxia.Events.addMood(_event.m.BroA, -0.5, "可惜白白错过了土里的门道", this.List);
				if (::Wuxia.Events.isAlive(_event.m.BroB))
					::Wuxia.Events.addMood(_event.m.BroB, 0.75, "远离邪门荒坟总算松了口气", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_18.png[/img]没人提出异议。众人手忙脚乱拿湿土闷死篝火、套紧骡车鞍具，摸黑沿着泥泞荒道一口气赶出十来里地，直到那股苦艾与陈年腐木味彻底甩在身后才重新喘匀气。" + nameA + " 回头望了眼黑沉沉的雾岭，撇撇嘴虽觉可惜，倒也承认小心驶得万年船。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		this.m.BroA = null;
		this.m.BroB = null;

		local digger = ::Wuxia.Events.findByBackgrounds([
			"background.gravedigger",
			"background.graverobber"
		]);
		if (digger == null) return;

		this.m.BroA = digger;
		this.m.BroB = ::Wuxia.Events.findRandomBro(digger);
		this.m.Score = 16;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.BroA))
		{
			this.m.BroA = ::Wuxia.Events.findByBackgrounds([
				"background.gravedigger",
				"background.graverobber"
			]);
		}
		if (this.m.BroB != null && !::Wuxia.Events.isAlive(this.m.BroB))
			this.m.BroB = ::Wuxia.Events.findRandomBro(this.m.BroA);
	}

	function onPrepareVariables( _vars )
	{
		_vars.push(["gravedigger", ::Wuxia.Events.shortName(this.m.BroA)]);
	}

	function onClear()
	{
		this.m.BroA = null;
		this.m.BroB = null;
	}
});
