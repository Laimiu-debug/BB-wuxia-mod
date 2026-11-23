// Strange-Tales Event 54: 林海巨猿足印（小次山朱厌踪迹与山村求援）

this.wx_event_weird_shanhai_zhuyan_tracks <- this.inherit("scripts/events/event", {
	m = {
		Tracker = null,
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_weird_shanhai_zhuyan_tracks";
		this.m.Title = "林海巨猿足印";
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
				this.Options = [];

				local trk = _event.m.Tracker;
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(trk)) this.Characters.push(trk.getImagePath());
				else if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_34.png[/img]深山伐木小村外，十几株合抱粗的老松竟像枯芦苇般被拦腰拗断，泥地上深深印着一串斗笠大小的五趾巨足印，树皮上还挂着几缕粗如铁丝的霜白兽毛。村口木栅后头，七八名老幼紧攥着柴刀发抖——昨夜一头白首赤足的「小次山朱厌巨猿」掠过山坳，单掌便拍塌了半边羊圈。\n\n白发村正隔着栅栏连连作揖，恳请你们帮村里加固木栅，或是顺着兽踪探明那凶猿是否已经翻过西岭。";

				this.Options.push({
					Text = "耗费 10 份修甲器械帮村里加固木栅与陷坑",
					function getResult( _ev )
					{
						if (::World.Assets.getArmorParts() < 10) return "NoTools";
						return "Fortify";
					}
				});
				if (::Wuxia.Events.isAlive(trk))
				{
					this.Options.push({
						Text = "遣 " + ::Wuxia.Events.shortName(trk) + " 循足印悄然搜寻朱厌蜕毛与遗材",
						function getResult( _ev ) { return "TrackTrail"; }
					});
				}
				this.Options.push({
					Text = "凶猿现世主大兵灾，趁天未黑绕出林海。",
					function getResult( _ev ) { return "Leave"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "Fortify",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "江湖路远，留一份善缘。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::Wuxia.Events.addSupplies(-10, 0, 0, this.List);
				::Wuxia.Events.addMoney(240, this.List);
				::Wuxia.Events.givePill("wx_pill_huxin", this.List);
				::Wuxia.Events.addReputation(25, 8, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "帮山村修寨防猿，受百姓敬重", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_34.png[/img]众弟兄卸下行囊，拿铁钉、削尖硬木和火油罐替山村重新扎紧半里木寨，又教乡勇如何用硫磺烟筒驱赶夜兽。傍晚动身时，全村凑出二百四十两谢银，村正还捧出一颗早年救过江湖客留下的【护心丹】郑重相赠。";
			}
		});

		this.m.Screens.push({
			ID = "TrackTrail",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "山海奇材到手，速速回营。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				local trk = _event.m.Tracker;
				if (::Wuxia.Events.isAlive(trk)) this.Characters.push(trk.getImagePath());

				::Wuxia.Events.giveItem("scripts/items/misc/unhold_hide_item", this.List);
				::Wuxia.Events.givePill("wx_pill_hugu", this.List);
				if (::Wuxia.Events.isAlive(trk))
				{
					::Wuxia.Events.addMastery(trk, 50, this.List);
					::Wuxia.Events.addMood(trk, 1.0, "循朱厌踪迹满载而归", this.List);
				}

				this.Text = "[img]gfx/ui/events/wx_ev_34.png[/img]" + ::Wuxia.Events.fmtName(trk) + " 伏身嗅了嗅树皮血迹，确认那头朱厌是与山中老熊恶斗后负伤西遁。他顺着血痕悄无声息摸到三里外乱石坡，不仅捡回一大张被熊爪扯落的坚韧朱厌白首厚革，还在残破猎户背篓里翻出一枚完好的【虎骨壮气丸】，村民听闻巨猿已远走西岭，也长舒了一口气。";
			}
		});

		this.m.Screens.push({
			ID = "NoTools",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "只得作罢。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_34.png[/img]清点行囊才发现随队修甲铁料与钉斧不足十份，巧妇难为无米之炊。你叮嘱村正夜里多点几堆湿松烟火，便带着众人继续上路。";
			}
		});

		this.m.Screens.push({
			ID = "Leave",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "加快脚步。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_34.png[/img]《西山经》言朱厌见则天下大兵，寻常江湖队伍没必要在暮色里招惹这等巨凶。你挥手令众人收声疾行，身后的木寨与断松很快隐没在青灰林雾之中。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (this.World.getTime().Days < 6) return;
		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Tracker = ::Wuxia.Events.findByBackgrounds([
			"background.beast_hunter", "background.beast_slayer", "background.hunter", "background.poacher", "background.lumberjack"
		]);
		this.m.Score = 14;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear()
	{
		this.m.Tracker = null;
		this.m.Bro = null;
	}
});
