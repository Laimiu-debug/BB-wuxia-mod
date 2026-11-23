// Sequential Jianghu Event Chain 3 (Stage 2/3): 劫灰余烬 · 盟使驰援
this.wx_event_chain_crisis_2 <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_chain_crisis_2";
		this.m.Title = "劫灰余烬（二）· 抗劫盟使";
		this.m.Cooldown = 999.0 * this.World.getTime().SecondsPerDay;

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
				if (::Wuxia.Events.isAlive(bro)) this.Characters.push(bro.getImagePath());

				if (::World.Assets.getMoney() >= 300)
				{
					this.Options.push({
						Text = "「大劫当前岂能袖手！拨出 300 两军饷助诸派稳住前线防线！」",
						function getResult( _ev ) { return "FundAlliance"; }
					});
				}
				if (::World.Assets.getArmorParts() >= 12)
				{
					this.Options.push({
						Text = "「军资比现银更紧要——调拨 12 箱百炼修械铁料与箭药随使者驰援！」",
						function getResult( _ev ) { return "DonateSupplies"; }
					});
				}
				this.Options.push({
					Text = "「粮草自顾不暇，可遣轻功斥候协助盟军探清敌营虚实。」",
					function getResult( _ev ) { return "SendScouts"; }
				});

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]一匹浑身白沫的骏马冲进你们营寨，马背上翻身跃下一名身披青铜羽箭擦痕的「九州抗劫盟使」。他抱拳急声道：\n\n『久闻贵社前日救护流民、深明大义！眼下少室、太和与丐帮联军正在前线死守要隘，然甲械损毁极重、粮饷告急！特奉盟主令箭前来筹措军资——凡肯雪中送炭者，三大正宗必铭记在心，战后更有重赏相报！』";
			}
		});

		this.m.Screens.push({
			ID = "FundAlliance",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "愿联军旗开得胜！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_crisis", 2);
				::World.Flags.set("wx_chain_crisis_day", ::World.getTime().Days);
				::Wuxia.Events.addMoney(-300, this.List);
				::Wuxia.Events.addSectRel("shaolin", 12, this.List);
				::Wuxia.Events.addSectRel("taihe", 12, this.List);
				::Wuxia.Events.addSectRel("gaibang", 12, this.List);
				::Wuxia.Events.givePill("wx_pill_longhu", this.List);
				::Wuxia.Events.addReputation(45, 12, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]三百两军饷迅速装袋交割，盟使动容深揖，解下怀中一枚随军备用的龙虎大力丸留作回礼，纵马疾驰而去！三大名门皆闻贵社义举，交情大涨！";
			}
		});

		this.m.Screens.push({
			ID = "DonateSupplies",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "众志成城，共克时艰！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_crisis", 2);
				::World.Flags.set("wx_chain_crisis_day", ::World.getTime().Days);
				::Wuxia.Events.addSupplies(-12, 0, 0, this.List);
				::Wuxia.Events.addSectRel("shaolin", 14, this.List);
				::Wuxia.Events.addSectRel("taihe", 14, this.List);
				::Wuxia.Events.addSectRel("gaibang", 14, this.List);
				::Wuxia.Events.givePill("wx_pill_longhu", this.List);
				::Wuxia.Events.addReputation(50, 14, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]整整十二箱百炼修械铁料犹如久旱甘霖！盟使喜出望外，奉上一枚龙虎大力丸作为信物，誓言待大破敌锋后必亲率仪仗送来联军重赏！";
			}
		});

		this.m.Screens.push({
			ID = "SendScouts",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "探清虚实，方能百战不殆。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_crisis", 2);
				::World.Flags.set("wx_chain_crisis_day", ::World.getTime().Days);
				::Wuxia.Events.addSectRel("shaolin", 6, this.List);
				::Wuxia.Events.addSectRel("gaibang", 8, this.List);
				::Wuxia.Events.addCompanyMastery(55, this.List);
				::Wuxia.Events.addReputation(25, 6, this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_14.png[/img]你们派出轻功好手随盟使潜行前线两昼夜，摸清了敌军粮道暗哨并安然折返。此番惊险侦察既助了联军一臂之力，也让众弟兄实战火候大增！";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Bro = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::World.Flags.getAsInt("wx_chain_crisis") != 1) return;
		local lastDay = ::World.Flags.getAsInt("wx_chain_crisis_day");
		if (::World.getTime().Days < lastDay + 8) return;

		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Score = 34;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.Bro = null; }
});
