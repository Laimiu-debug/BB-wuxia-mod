// M3 World Event: 市镇书肆与武馆演武（买大路货/花银子集体灌注火候）

this.wx_event_bookshop <- this.inherit("scripts/events/event", {
	m = {
		OfferedManualID = "wx_manual_tuna"
	},

	function create()
	{
		this.m.ID = "event.wx_bookshop";
		this.m.Title = "市镇书肆与武馆";
		this.m.Cooldown = 14.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_78.png[/img]行经城中坊市，街角一间旧书肆门前挂着“武学抄本”木牌，隔壁武馆里拳风呼啸。掌柜认出你们是走江湖的好手，迎出来问道：『诸位可是要添置几册实用功夫，或是请馆里教头带弟兄们演武打磨火候？』",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "花 450 银两请武馆教头演武（全队未满重功法各得 +60 火候）",
					function getResult( _event )
					{
						if (this.World.Assets.getMoney() < 450) return "NoMoney";
						this.World.Assets.addMoney(-450);
						foreach (bro in this.World.getPlayerRoster().getAll())
						{
							::Wuxia.Mastery.addExpToEquipped(bro, 60);
						}
						return "Trained";
					}
				},
				{
					Text = "买下书肆抄本（350 银两）",
					function getResult( _event )
					{
						local mItem = ::new("scripts/items/misc/wx_manual_item");
						mItem.initManual(_event.m.OfferedManualID);
						return ::Wuxia.Loot.purchaseEventItem(mItem, 350, "Bought");
					}
				},
				{
					Text = "今日盘缠吃紧，改日再看。",
					function getResult( _event ) { return 0; }
				}
			],
			function start( _event )
			{
				local commons = ::Wuxia.Loot.getManualIDsByQuality("common");
				if (commons.len() > 0)
				{
					_event.m.OfferedManualID = commons[::Math.rand(0, commons.len() - 1)];
					local def = ::Wuxia.Slots.getManualDef(_event.m.OfferedManualID);
					if (def != null)
					{
						this.Options[1].Text = "买下抄本《" + def.Name + "》（350 银两）";
					}
				}
			}
		});

		this.m.Screens.push({
			ID = "Trained",
			Text = "[img]gfx/ui/events/event_78.png[/img]众人进武馆对拆演练了整整半日，彼此拆招补缺，各自修习的武学火候都有精进！",
			Image = "",
			List = [{ id = 1, icon = "ui/icons/xp_received.png", text = "全队已装配的未满重功法获得 +60 火候" }],
			Characters = [],
			Options = [{ Text = "收功上路。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});

		this.m.Screens.push({
			ID = "Bought",
			Text = "[img]gfx/ui/events/event_78.png[/img]你付过银两，将秘籍妥善收入行囊，随时可在「武学修为」页拖拽装槽。",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "妥善收好。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});

		this.m.Screens.push(::Wuxia.Loot.makeNoRoomScreen());
		this.m.Screens.push({
			ID = "NoMoney",
			Text = "[img]gfx/ui/events/event_78.png[/img]摸了摸怀中银袋，眼下盘缠尚不够数，只得作罢。",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "下次再来。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Loot.isNearMarketTown()) return;
		this.m.Score = 18;
	}
});
