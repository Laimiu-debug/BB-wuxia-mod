// Batch E4 Event 44: 酒楼比武踢馆（城镇酒肆木刃赌斗）

this.wx_event_sect_tavern_challenge <- this.inherit("scripts/events/event", {
	m = {
		SectID    = null,
		ChampBro  = null,
		WinChance = 50
	},

	function wxPickChampion()
	{
		local champ = ::Wuxia.Events.findVeteranBro(1);
		foreach (b in ::Wuxia.Events.getAliveBros())
		{
			if (champ == null
				|| b.getLevel() > champ.getLevel()
				|| (b.getLevel() == champ.getLevel() && b.getCurrentProperties().MeleeSkill > champ.getCurrentProperties().MeleeSkill))
			{
				champ = b;
			}
		}
		return champ;
	}

	function create()
	{
		this.m.ID = "event.wx_sect_tavern_challenge";
		this.m.Title = "酒楼拍木刀 · 少侠邀战";
		this.m.Cooldown = 28.0 * this.World.getTime().SecondsPerDay;

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
				local champ = _event.m.ChampBro;
				if (!::Wuxia.Events.isAlive(champ))
				{
					champ = _event.wxPickChampion();
					_event.m.ChampBro = champ;
				}
				if (::Wuxia.Events.isAlive(champ))
				{
					this.Characters.push(champ.getImagePath());
					local mAtk = champ.getCurrentProperties().MeleeSkill;
					_event.m.WinChance = ::Math.min(88, ::Math.max(25, 22 + champ.getLevel() * 4 + ::Math.floor((mAtk - 50) * 0.8)));
				}
				else
				{
					_event.m.WinChance = 40;
				}

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]「啪」地一声脆响，一柄沉甸甸的白蜡木练功刀横拍在你们酒桌上，震得酱牛肉碟子直打转！出手的是个双颊泛红、浑身酒气的年轻武人，腰系【" + sect.Name + "】的亮缎束带，身后三名同门正抱着胳膊起哄。\n\n少年把一袋沉甸甸的银两往桌心一掼，扬着下巴冲" + regionLabel + "满楼食客喊道：『听闻贵队在道上很吃得开！三百两彩头，敢不敢出个头号人物与我拿木刃过十招？赢了银子拿走，输了只要一百两酒钱——别叫满楼好汉看轻了！』";

				this.Options.push({
					Text = "遣" + ::Wuxia.Events.shortName(champ) + "提木刃下场切磋（胜算约 " + _event.m.WinChance + "%）",
					function getResult( _ev )
					{
						if (::Math.rand(1, 100) <= _ev.m.WinChance)
							return "SparWin";
						return "SparLose";
					}
				});

				this.Options.push({
					Text = "花 120 银两叫一桌好酒佳肴请他同饮，一笑化锋",
					function getResult( _ev )
					{
						if (::World.Assets.getMoney() < 120) return "NoMoney";
						return "TreatWine";
					}
				});

				this.Options.push({
					Text = "权当醉汉喧闹，埋头吃菜不予理会。",
					function getResult( _ev ) { return 0; }
				});
			}
		});

		this.m.Screens.push({
			ID = "SparWin",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "收下彩头，满堂喝彩！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local champ = _event.m.ChampBro;
				if (::Wuxia.Events.isAlive(champ)) this.Characters.push(champ.getImagePath());

				::Wuxia.Events.addMoney(300, this.List);
				::Wuxia.Events.addMastery(champ, 65, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 12, this.List);
				::Wuxia.Events.addReputation(35, 0, this.List);
				::Wuxia.Events.addMood(champ, 0.75, "酒楼木刃轻取少侠，扬威四座", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]桌椅推开尺许宽的空地，少年抢先使出三招颇具章法的【" + sect.Name + "】快攻，木风呼呼作响。" + ::Wuxia.Events.fmtName(champ) + "却稳如钉桩，连架两记虚招后骤然贴身进半步，木脊精准磕在少年腕脉麻筋上，顺手一把抄住脱手飞出的木刀，竟没伤他半寸皮肉！\n\n满楼顿时爆出雷鸣喝彩。那少年呆立片刻，红着耳根深深一揖，心服口服地奉上三百两彩头，直说回山定要向师兄长辈称道今日领教的高招。";
			}
		});

		this.m.Screens.push({
			ID = "SparLose",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "认赌服输，揉着淤青离席。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local champ = _event.m.ChampBro;
				if (::Wuxia.Events.isAlive(champ)) this.Characters.push(champ.getImagePath());

				::Wuxia.Events.applyLightHurt(champ, 0.18, this.List);
				::Wuxia.Events.addMoney(-100, this.List);
				::Wuxia.Events.addMood(champ, -0.5, "酒楼切磋失手吃瘪", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]没料到这少年虽爱逞口舌，脚下【" + sect.Name + "】的变步却刁钻非常。" + ::Wuxia.Events.fmtName(champ) + "一招抢攻稍露空门，被对方矮身顺势一记木柄猛捣肋下，顿时岔气踉跄撞翻条凳。\n\n满楼哄笑声里，你黑着脸按约数出一百两酒钱掷在桌上，扶着捂肋冷哼的" + ::Wuxia.Events.fmtName(champ) + "拂袖下楼。";
			}
		});

		this.m.Screens.push({
			ID = "TreatWine",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "杯酒论交，畅快离去。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];

				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				::Wuxia.Events.addMoney(-120, this.List);
				::Wuxia.Events.addSectRel(_event.m.SectID, 16, this.List);
				::Wuxia.Events.addCompanyMood(0.5, "酒楼化锋为友，饮酒尽欢", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]你不动声色地把木刀轻轻推回他手边，扬声叫掌柜添两坛十年花雕与一盘卤肘子，拱手笑道：『【" + sect.Name + "】的高足登门，哪能以木棒待客？且坐下来先干三碗，再讲武林掌故！』\n\n伸手不打笑脸人，少年一腔火气顿时泄了大半，三杯落肚后反倒拍着胸脯称兄道弟起来。";
			}
		});

		this.m.Screens.push({
			ID = "NoMoney",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "低头吃菜，免生枝节。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]摸了摸钱袋，竟掏不出一百二十两请酒钱。你干咳一声摆摆手，少年撇撇嘴收起木刀自回邻桌吃酒去了。";
			}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		if (!::Wuxia.Events.isNearTown(4)) return;
		if (::Wuxia.Events.getAliveBros().len() == 0) return;
		this.m.SectID = ::Wuxia.Events.pickLocalSect();
		this.m.ChampBro = this.wxPickChampion();
		this.m.Score = 16;
	}

	function onPrepare()
	{
		if (this.m.SectID == null || !(this.m.SectID in ::Wuxia.Config.Sects))
			this.m.SectID = ::Wuxia.Events.pickLocalSect();
		if (!::Wuxia.Events.isAlive(this.m.ChampBro))
			this.m.ChampBro = this.wxPickChampion();
	}

	function onPrepareVariables( _vars ) {}

	function onClear()
	{
		this.m.SectID = null;
		this.m.ChampBro = null;
		this.m.WinChance = 50;
	}
});
