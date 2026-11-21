// Batch E4 Event 42: 暗器匣客（蜀中唐家堡 / 神机火器营匠师行商）

this.wx_event_sect_tangmen_peddler <- this.inherit("scripts/events/event", {
	m = {
		SectID  = null,
		TechBro = null,
		Bro     = null
	},

	function create()
	{
		this.m.ID = "event.wx_sect_tangmen_peddler";
		this.m.Title = "黄铜百宝匣 · 暗器匠客";
		this.m.Cooldown = 30.0 * this.World.getTime().SecondsPerDay;

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

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local regionLabel = ::Wuxia.Events.getRegionLabel();
				local showBro = ::Wuxia.Events.isAlive(_event.m.TechBro) ? _event.m.TechBro : _event.m.Bro;
				if (::Wuxia.Events.isAlive(showBro)) this.Characters.push(showBro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]" + regionLabel + "野渡口破草棚下，一名戴牛皮指套、十指沾满铁锈与松香油的清瘦匠人正慢条斯理地擦拭一口包铜楠木行匣。见你们兵甲齐整，他啪嗒一声弹开铜扣——格子里码着泛蓝光的淬火钢弩矢、修甲钢锉、细机簧，角落里还立着两只弥漫冰片与朱砂苦香的青瓷小瓶。\n\n匠人压低眉眼亮出一块暗纹铜牌，示意自己替【" + sect.Name + "】跑外活：『工坊余料，绝不记官账。买箭买药都好说，只收现银，莫问来路。』";

				this.Options.push({
					Text = "花 240 银两购入精制弩箭与修甲机簧箱（+35 箭矢弹药、+14 修甲器械）",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 240) return "NoMoney";
						return "BuyKit";
					}
				});

				this.Options.push({
					Text = "花 480 银两买下那两瓶战前奇药（清心解毒丹 + 明目定神散）",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 480) return "NoMoney";
						return "BuyPills";
					}
				});

				if (::Wuxia.Events.isAlive(_event.m.TechBro))
				{
					this.Options.push({
						Text = "让" + ::Wuxia.Events.shortName(_event.m.TechBro) + "上前与匠客探讨机簧绞力与射艺手法",
						function getResult( _ev ) { return "Discuss"; }
					});
				}

				this.Options.push({
					Text = "囊中不宽裕，谢绝买卖上路。",
					function getResult( _ev ) { return 0; }
				});
			}
		});

		this.m.Screens.push({
			ID = "BuyKit",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收妥军械，抱拳告辞。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				::Wuxia.Events.addMoney(-240, this.List);
				::Wuxia.Events.addSupplies(14, 0, 35, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 10, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]匠人麻利地清点银两，把三捆涂满防潮牛油的破甲弩箭和一匣精钢铆钉锉刀推过来。箭杆笔直、尾羽削得齐如刀裁，确是【" + sect.Name + "】工坊才出得了的手艺。他合上木匣冲你们微微颔首，转眼便没入官道行人之中。";
			}
		});

		this.m.Screens.push({
			ID = "BuyPills",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "贴身藏好，以备恶战。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				::Wuxia.Events.addMoney(-480, this.List);
				::Wuxia.Events.givePill("wx_pill_qingxin", this.List);
				::Wuxia.Events.givePill("wx_pill_dingshen", this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 12, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]四百八十两纹银递过，匠人小心翼翼将两只蜡封青瓷瓶包进油布递来：『一瓶避南疆毒烟吹箭，一瓶破荒冢夜雾鬼啸——都是【" + sect.Name + "】外勤弟子压箱底的保命货。下回碰上难缠的邪门硬茬，开战前吞下去，准保谢我！』";
			}
		});

		this.m.Screens.push({
			ID = "Discuss",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "相见恨晚，拱手别过。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local tech = _event.m.TechBro;
				if (::Wuxia.Events.isAlive(tech)) this.Characters.push(tech.getImagePath());

				::Wuxia.Events.addMastery(tech, 55, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 8, this.List);
				::Wuxia.Events.addMood(tech, 0.5, "与奇门匠客切磋机巧，豁然开朗", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]" + ::Wuxia.Events.fmtName(tech) + "蹲在木匣旁只扫了一眼，便点出那枚铜望山削角偏轻、连发时恐卡机括。匠人原本波澜不惊的眉梢猛地一挑，当即扯来半截炭条在青石板上画起图样。\n\n一老一少就着扳机回弹、甩腕蓄劲和偏风修正聊了足足半个时辰，【" + sect.Name + "】的匠人直叹行家难遇，顺口点拨了几句稳腕借力的门道，听得" + ::Wuxia.Events.fmtName(tech) + "茅塞顿开。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "待攒够盘缠再说。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]清点钱袋后发觉银两差了一截。匠人不恼也不催，轻轻扣回黄铜搭扣：『好铁不贱卖，下回带足现银再叙。』";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::Wuxia.Events.getAliveBros().len() == 0) return;
		local pool = ["tangmen", "shenji"];
		this.m.SectID = pool[::Math.rand(0, pool.len() - 1)];
		this.m.TechBro = ::Wuxia.Events.findByBackgrounds([
			"background.bowyer",
			"background.juggler",
			"background.hunter"
		]);
		this.m.Bro = ::Wuxia.Events.findRandomBro();
		this.m.Score = 15;
	}

	function onPrepare()
	{
		if (this.m.SectID == null || !(this.m.SectID in ::Wuxia.Config.Sects))
		{
			local pool = ["tangmen", "shenji"];
			this.m.SectID = pool[::Math.rand(0, pool.len() - 1)];
		}
		if (!::Wuxia.Events.isAlive(this.m.TechBro))
		{
			this.m.TechBro = ::Wuxia.Events.findByBackgrounds([
				"background.bowyer",
				"background.juggler",
				"background.hunter"
			]);
		}
		if (!::Wuxia.Events.isAlive(this.m.Bro))
			this.m.Bro = ::Wuxia.Events.findRandomBro();
	}

	function onPrepareVariables( _vars ) {}

	function onClear()
	{
		this.m.SectID = null;
		this.m.TechBro = null;
		this.m.Bro = null;
	}
});
