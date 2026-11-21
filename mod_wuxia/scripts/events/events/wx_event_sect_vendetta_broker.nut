// Batch E4 Event 39: 说客调停血仇（化解交恶门派追缉与血仇）

this.wx_event_sect_vendetta_broker <- this.inherit("scripts/events/event", {
	m = {
		SectID  = null,
		Haggler = null,
		Bro     = null
	},

	function create()
	{
		this.m.ID = "event.wx_sect_vendetta_broker";
		this.m.Title = "茶楼说客 · 调停血仇";
		this.m.Cooldown = 24.0 * this.World.getTime().SecondsPerDay;

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
				local rel = ::Wuxia.SectRelations.getRelation(_event.m.SectID);
				local regionLabel = ::Wuxia.Events.getRegionLabel();
				local showBro = ::Wuxia.Events.isAlive(_event.m.Haggler) ? _event.m.Haggler : _event.m.Bro;
				if (::Wuxia.Events.isAlive(showBro)) this.Characters.push(showBro.getImagePath());

				this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]在" + regionLabel + "路边茶棚歇脚时，一名穿宝蓝绸衫、满身槟榔与桂花油味儿的矮胖掮客不请自来，自顾往长凳上一坐，将一张压着暗印的红边拜帖推到你们茶碗旁。\n\n『诸位与【" + sect.Name + "】结下的梁子（当前交情：" + rel + "），如今三州六县的茶馆都传遍了。夜夜提防冷箭毒砂，弟兄们连觉都睡不安稳。』说客眯眼拨弄着玉扳指，『巧了，小人与贵仇家的执事堂能说上几句话——只要备足 600 两赔礼茶钱，小人跑这一趟腿，替诸位把红帖压进旧账里，从今往后两清！』";

				this.Options.push({
					Text = "花 600 银两托他代递赔礼，化解与【" + sect.Name + "】的血仇",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 600) return "NoMoney";
						return "PayFull";
					}
				});

				if (::Wuxia.Events.isAlive(_event.m.Haggler))
				{
					this.Options.push({
						Text = "让" + ::Wuxia.Events.shortName(_event.m.Haggler) + "上桌盘道砍价（仅需 320 银两）",
						function getResult( _ev )
						{
							if (::World.Assets.getMoney() < 320) return "NoMoney";
							return "Haggle";
						}
					});
				}

				this.Options.push({
					Text = "当面撕碎红帖，往酒碗里狠啐一口——要债便拿刀来取！",
					function getResult( _ev ) { return "Defy"; }
				});

				this.Options.push({
					Text = "多一事不如少一事，冷眼送客。",
					function getResult( _ev ) { return 0; }
				});
			}
		});

		this.m.Screens.push({
			ID = "PayFull",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "少一桩背后冷箭，倒也清净。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				::Wuxia.Events.addMoney(-600, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 35, this.List);
				::Wuxia.Events.addReputation(20, 0, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]六百两雪花官银一字排开，说客脸上的笑纹顿时堆成了菊花。他取出一枚火漆印将银票封妥，三日后便托驿卒送回半张撕角的回执——【" + sect.Name + "】执事堂已收下茶礼，往日悬在头顶的追杀暗令暂且搁置。虽说肉疼了些，好歹能安心走官道了。";
			}
		});

		this.m.Screens.push({
			ID = "Haggle",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "省下一笔真金白银，痛快！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local hag = _event.m.Haggler;
				if (::Wuxia.Events.isAlive(hag)) this.Characters.push(hag.getImagePath());

				::Wuxia.Events.addMoney(-320, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 30, this.List);
				::Wuxia.Events.addReputation(15, 0, this.List);
				::Wuxia.Events.addMood(hag, 0.75, "舌战说客砍下近半赔礼", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]" + ::Wuxia.Events.fmtName(hag) + "嘿嘿一笑，反手端起茶壶替说客满上，嘴里却如连珠炮般报出三州平事的行价、堂口抽成的暗数，甚至连【" + sect.Name + "】二管事爱喝哪家烧刀子都抖了个底朝天。\n\n说客额角渗汗，眼看瞒不过行家里手，咬牙把价码一路让到了三百二十两。银子点清，这桩烫手血仇总算花小钱平了下来。";
			}
		});

		this.m.Screens.push({
			ID = "Defy",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "磨刀以待！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local bro = _event.m.Bro;
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				::Wuxia.Events.addSectRel(_event.m.SectID, -15, this.List);
				::Wuxia.Events.addCompanyMood(1.0, "宁折不弯，全队血性大振", this.List);
				::Wuxia.Events.addStat(bro, "Bravery", 1, "定力", "ui/icons/bravery.png", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]你一把抓过红帖撕成漫天碎屑，朝那碗浑浊浊酒里狠狠啐了一口，冷笑道：『滚回去告诉【" + sect.Name + "】，想要赔礼银子，叫他们提着脑袋自己来刀口上取！』\n\n说客吓得跌下条凳，连滚带爬逃出茶棚。满棚弟兄拍案狂笑，连日来被追缉压出的闷气一扫而空。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "暂且作罢。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_13.png[/img]手头现银不够凑齐赔礼。说客见你们掏不出响声，收起玉扳指干笑两声，拱拱手一溜烟没了影儿。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::Wuxia.Events.getAliveBros().len() == 0) return;
		local hostile = ::Wuxia.Events.pickHostileSect(-15);
		if (hostile == null) return;
		this.m.SectID = hostile;
		this.m.Haggler = ::Wuxia.Events.findByBackgrounds([
			"background.peddler",
			"background.minstrel",
			"background.adventurous_noble",
			"background.pimp"
		]);
		this.m.Bro = ::Wuxia.Events.findRandomBro();
		this.m.Score = 26;
	}

	function onPrepare()
	{
		if (this.m.SectID == null || !(this.m.SectID in ::Wuxia.Config.Sects))
		{
			local hostile = ::Wuxia.Events.pickHostileSect(-15);
			this.m.SectID = hostile != null ? hostile : ::Wuxia.Events.pickLocalSect("outlaw");
		}
		if (!::Wuxia.Events.isAlive(this.m.Haggler))
		{
			this.m.Haggler = ::Wuxia.Events.findByBackgrounds([
				"background.peddler",
				"background.minstrel",
				"background.adventurous_noble",
				"background.pimp"
			]);
		}
		if (!::Wuxia.Events.isAlive(this.m.Bro))
			this.m.Bro = ::Wuxia.Events.findRandomBro();
	}

	function onPrepareVariables( _vars ) {}

	function onClear()
	{
		this.m.SectID = null;
		this.m.Haggler = null;
		this.m.Bro = null;
	}
});
