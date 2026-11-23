// Sequential Jianghu Event Chain 2 (Stage 1/3): 无名老丐传艺 · 浊酒结缘
this.wx_event_chain_beggar_1 <- this.inherit("scripts/events/event", {
	m = {
		Bro = null
	},

	function create()
	{
		this.m.ID = "event.wx_chain_beggar_1";
		this.m.Title = "无名老丐（一）· 浊酒一碗";
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

				if (::World.Assets.getMoney() >= 80)
				{
					this.Options.push({
						Text = "「小二，添两斤酱牛肉与一壶烫酒！再赠老人家八十两盘缠！」",
						function getResult( _ev ) { return "TreatBeggar"; }
					});
				}
				this.Options.push({
					Text = "「军资吃紧，恕难施舍，请另寻别桌吧。」",
					function getResult( _ev ) { return "Refuse"; }
				});

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]城郊茶酒摊檐下秋风萧瑟，一名断了左小指、衣衫褴褛的邋遢老丐拄着磨得发亮的竹杖凑到桌边，笑嘻嘻嗅了嗅你们桌上的酱肉香：\n\n『好汉们行色匆匆，身上带着一股真气煞火呀！老叫花子走南闯北饿了三天，不知各位可舍得请一顿热酒肉，再匀几两碎银买双草鞋？』他目光浑浊却隐隐透着精芒，掌心满是常年握棍磨出的厚茧。";
			}
		});

		this.m.Screens.push({
			ID = "TreatBeggar",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "江湖相逢皆是缘，老人家慢用！", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_beggar", 1);
				::World.Flags.set("wx_chain_beggar_day", ::World.getTime().Days);
				::Wuxia.Events.addMoney(-80, this.List);
				::Wuxia.Events.addSectRel("gaibang", 8, this.List);
				::Wuxia.Events.addReputation(10, 10, this.List);
				::Wuxia.Events.addCompanyMood(0.75, "仗义疏财款待老丐", this.List);

				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]老丐毫不客气地风卷残云吃光两斤酱肉，抹着油嘴哈哈大笑：『痛快！痛快！诸位小友心肠热、底子正，今日这碗酒老叫花子记下了——九州不大，咱们早晚还要再见！』话音刚落，他足尖在青石板上一沾即离，转眼竟已没入街角人潮。";
			}
		});

		this.m.Screens.push({
			ID = "Refuse",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "继续整顿行囊。", function getResult( _ev ) { return 0; } }],
			function start( _event )
			{
				this.Characters = [];
				this.List = [];
				::World.Flags.set("wx_chain_beggar", 9);
				this.Text = "[img]gfx/ui/events/wx_ev_02.png[/img]老丐耸了耸肩，哼着不知名的俚曲拄杖离去。街市喧嚣如常，很快便无人再记得这位过客。";
			}
		});
	}

	function onUpdateScore()
	{
		this.m.Bro = null;
		if (!::Wuxia.Events.isWorldReady()) return;
		if (::World.getTime().Days < 10) return;
		if (::World.Flags.getAsInt("wx_chain_beggar") != 0) return;
		if (!::Wuxia.Events.isNearTown(5)) return;

		local bro = ::Wuxia.Events.findRandomBro();
		if (bro == null) return;
		this.m.Bro = bro;
		this.m.Score = 24;
	}

	function onPrepare() {}
	function onPrepareVariables( _vars ) {}
	function onClear() { this.m.Bro = null; }
});
