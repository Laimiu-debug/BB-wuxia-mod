// Late-Game Jianghu Crisis Event: 名门山门血书求援（武林浩劫期间正道/中立宗门山门遭围，义社择策驰援或按兵不动）

this.wx_event_crisis_sanctum_aid <- this.inherit("scripts/events/event", {
	m = {
		SectID = null,
		BroA   = null
	},

	function create()
	{
		this.m.ID = "event.wx_crisis_sanctum_aid";
		this.m.Title = "山门血书求援";
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
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local sid = (_event.m.SectID != null && (_event.m.SectID in ::Wuxia.Config.Sects)) ? _event.m.SectID : "shaolin";
				local sName = ::Wuxia.Config.Sects[sid].Name;
				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]暮色苍茫，一骑浑身浴血的快马撞入营门，背插三支折断黑羽急翎的【" + sName + "】外门信使翻身滚落鞍下，将一封火漆混着血指印的求援羽书塞入你掌中。\n\n" + nameA + " 扶住气息奄奄的信使，展卷急读：\n\n『浩劫烽烟四起，大股邪派凶徒与乱军先锋正昼夜猛扑【" + sName + "】外围关隘，护山弟子伤亡枕藉、箭矢金疮药几近告罄！贵社威名素著，恳请速拨银粮器械或遣精锐好手驰援侧翼，共渡山门倾覆之厄！』";

				this.Options = [];
				if (::Wuxia.Events.isWorldReady() && ::World.Assets.getMoney() >= 350)
				{
					this.Options.push({
						Text = "同气连枝，岂能坐视！拨出 350 两纹银与军资药材星夜驰援【" + sName + "】！",
						function getResult( _event ) { return "FullAid"; }
					});
				}
				this.Options.push({
					Text = "命精锐好手轻装奇袭敌军侧翼，替【" + sName + "】解外围燃眉之急！",
					function getResult( _event ) { return "VanguardAid"; }
				});
				this.Options.push({
					Text = "乱世兵凶战危，本社尚需保全实力，只能婉言谢绝。",
					function getResult( _event ) { return "DeclineAid"; }
				});
			}
		});

		this.m.Screens.push({
			ID = "FullAid",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "侠义立身，患难见真情。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local sid = (_event.m.SectID != null && (_event.m.SectID in ::Wuxia.Config.Sects)) ? _event.m.SectID : "shaolin";
				local sName = ::Wuxia.Config.Sects[sid].Name;

				::Wuxia.Events.addMoney(-350, this.List);
				::Wuxia.Events.addSupplies(-10, -5, 0, this.List);
				::Wuxia.Events.addSectRel(sid, 24, this.List);
				::Wuxia.Events.addReputation(65, 3, this.List);
				::Wuxia.Events.giveManual("sect", this.List, sid);
				::Wuxia.Events.addCompanyMood(1.0, "仗义驰援名门山门，侠名远播", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]你们连夜押送足色纹银、修械铁料与金疮良药直抵【" + sName + "】山门侧隘，并与守山执事里应外合击退来犯凶徒。\n\n战火稍歇，掌门长老亲自迎出山门长揖致谢，不仅将贵社奉为生死之交，更自藏经阁内郑重取出一卷本门秘传武学相赠，四方同道闻讯无不肃然起敬。";
			}
		});

		this.m.Screens.push({
			ID = "VanguardAid",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "痛快一战，不辱本社字号！", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local sid = (_event.m.SectID != null && (_event.m.SectID in ::Wuxia.Config.Sects)) ? _event.m.SectID : "shaolin";
				local sName = ::Wuxia.Config.Sects[sid].Name;
				local nameA = ::Wuxia.Events.fmtName(_event.m.BroA);

				if (::Wuxia.Events.isAlive(_event.m.BroA))
				{
					::Wuxia.Events.applyLightHurt(_event.m.BroA, 0.15, this.List);
					::Wuxia.Events.addMastery(_event.m.BroA, 65, this.List);
				}
				::Wuxia.Events.addSectRel(sid, 16, this.List);
				::Wuxia.Events.addMoney(220, this.List);
				::Wuxia.Events.givePage("sect", 2, this.List, sid);
				::Wuxia.Events.addCompanyMood(0.5, "奇袭解围大涨威风", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]" + nameA + " 率队借夜色掩护直插围山敌寇后阵，刀光剑气纵横之下焚毁敌军粮草鹿角，逼得来犯之敌仓皇退却。\n\n虽在乱军中添了几道皮肉轻伤，实战印证之下武学火候却精进不少；【" + sName + "】知客长老感念援手之德，特奉上犒军纹银与两页门派秘籍残卷聊表寸心。";
			}
		});

		this.m.Screens.push({
			ID = "DeclineAid",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "乱世行路，先顾自家弟兄性命。", function getResult( _event ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				if (::Wuxia.Events.isAlive(_event.m.BroA)) this.Characters.push(_event.m.BroA.getImagePath());

				local sid = (_event.m.SectID != null && (_event.m.SectID in ::Wuxia.Config.Sects)) ? _event.m.SectID : "shaolin";
				local sName = ::Wuxia.Config.Sects[sid].Name;

				::Wuxia.Events.addSectRel(sid, -12, this.List);
				::Wuxia.Events.addCompanyMood(-0.25, "见死不救令部分同袍心下黯然", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_16.png[/img]你替信使裹好箭创、赠了一袋干粮，却终究婉拒了出兵驰援之请。信使长叹一声，咬牙翻上马背隐入沉沉夜霭。\n\n数日后江湖风闻【" + sName + "】虽惨胜守住山门，门中上下对昔日袖手旁观之辈却颇有微词。";
			}
		});
	}

	function wxPickTargetSect()
	{
		local preferred = [];
		local fallback = [];
		foreach (id, sect in ::Wuxia.Config.Sects)
		{
			local al = ("Alignment" in sect) ? sect.Alignment : "neutral";
			if (al == "outlaw") continue;
			fallback.push(id);
			if (::Wuxia.SectRelations.getRelation(id) >= 5)
				preferred.push(id);
		}
		if (preferred.len() > 0) return preferred[::Math.rand(0, preferred.len() - 1)];
		if (fallback.len() > 0) return fallback[::Math.rand(0, fallback.len() - 1)];
		return "shaolin";
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Events.isWorldReady()) return;
		this.m.SectID = null;
		this.m.BroA = null;

		local crisisActive = (::Wuxia.Events.getActiveCrisis() != "");
		if (!crisisActive && ("FactionManager" in ::World) && ::World.FactionManager != null && ::Wuxia.hasMember(::World.FactionManager, "isGreaterEvil"))
		{
			try { crisisActive = ::World.FactionManager.isGreaterEvil(); } catch (_e) {}
		}
		if (!crisisActive && ::World.getTime().Days < 70) return;

		local bro = ::Wuxia.Events.findVeteranBro(5);
		if (bro == null) return;

		this.m.BroA = bro;
		this.m.SectID = this.wxPickTargetSect();
		this.m.Score = crisisActive ? 22 : 12;
	}

	function onPrepare()
	{
		if (!::Wuxia.Events.isAlive(this.m.BroA))
			this.m.BroA = ::Wuxia.Events.findVeteranBro(4);
		if (!::Wuxia.Events.isAlive(this.m.BroA))
			this.m.BroA = ::Wuxia.Events.findRandomBro();
		if (this.m.SectID == null || !(this.m.SectID in ::Wuxia.Config.Sects))
			this.m.SectID = this.wxPickTargetSect();
	}

	function onPrepareVariables( _vars )
	{
		local sid = (this.m.SectID != null && (this.m.SectID in ::Wuxia.Config.Sects)) ? this.m.SectID : "shaolin";
		_vars.push(["sectname", ::Wuxia.Config.Sects[sid].Name]);
		_vars.push(["veteran", ::Wuxia.Events.shortName(this.m.BroA)]);
	}

	function onClear()
	{
		this.m.SectID = null;
		this.m.BroA = null;
	}
});
