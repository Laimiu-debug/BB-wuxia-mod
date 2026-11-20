// M3 World Event: 门派传人拜会（查看/提升轻量化门派交情，交情达标兑换门派上乘秘籍）

this.wx_event_sect_exchange <- this.inherit("scripts/events/event", {
	m = {
		SectID = "qingfeng",
		OfferIndex = 0
	},

	function create()
	{
		this.m.ID = "event.wx_sect_exchange";
		this.m.Title = "门派传人拜会";
		this.m.Cooldown = 20.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "[img]gfx/ui/events/event_80.png[/img]城中茶楼偶遇一名佩剑行客，寒暄之下方知对方乃是名门传人。对方打量你们一行人，拱手笑道：『久闻贵队在江湖上颇有声名，若与敝派交情深厚，些许上乘武学抄本亦非不可商议。』",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "凭交情兑换门派上乘秘籍",
					function getResult( _event )
					{
						local sect = ::Wuxia.Config.Sects[_event.m.SectID];
						local offer = sect.ShopManuals[_event.m.OfferIndex];
						local rel = ::Wuxia.SectRelations.getRelation(_event.m.SectID);
						if (rel < offer.MinRel) return "LowRel";
						local mItem = ::new("scripts/items/misc/wx_manual_item");
						mItem.initManual(offer.ManualID);
						return ::Wuxia.Loot.purchaseEventItem(mItem, offer.Price, "Exchanged");
					}
				},
				{
					Text = "设宴款待并赠礼（花 500 银两，该门派交情 +15）",
					function getResult( _event )
					{
						if (this.World.Assets.getMoney() < 500) return "NoMoney";
						this.World.Assets.addMoney(-500);
						::Wuxia.SectRelations.addRelation(_event.m.SectID, 15);
						return "Befriended";
					}
				},
				{
					Text = "当面撕下门帖（该派交情 -35，交恶后可能遭到追缉）",
					function getResult( _event )
					{
						::Wuxia.SectRelations.addRelation(_event.m.SectID, -35);
						return "Offended";
					}
				},
				{
					Text = "拱手辞别。",
					function getResult( _event ) { return 0; }
				}
			],
			function start( _event )
			{
				local keys = ::Wuxia.SectRelations.getExchangeSects();
				_event.m.SectID = keys[::Math.rand(0, keys.len() - 1)];
				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				_event.m.OfferIndex = ::Math.rand(0, sect.ShopManuals.len() - 1);
				local offer = sect.ShopManuals[_event.m.OfferIndex];
				local def = ::Wuxia.Slots.getManualDef(offer.ManualID);
				local rel = ::Wuxia.SectRelations.getRelation(_event.m.SectID);

				this.Text = "[img]gfx/ui/events/event_80.png[/img]城中茶楼偶遇【" + sect.Name + "】传人（当前门派交情：" + rel + "）。对方笑道：『我手头带有一册《" + def.Name + "》（需交情 ≥ " + offer.MinRel + "，作价 " + offer.Price + " 银两），不知诸位意下如何？』";
				this.Options[0].Text = "兑换《" + def.Name + "》（需交情 " + offer.MinRel + " / " + offer.Price + " 银两）";
			}
		});

		this.m.Screens.push({
			ID = "Exchanged",
			Text = "[img]gfx/ui/events/event_80.png[/img]银货两讫，对方郑重将门派上乘秘籍交托予你，并叮嘱切莫轻传宵小。",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "抱拳谢过。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});

		this.m.Screens.push({
			ID = "Befriended",
			Text = "[img]gfx/ui/events/event_80.png[/img]一席好酒畅谈江湖掌故，双方相谈甚欢，门派交情大增（+15）！",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "后会有期。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});

		this.m.Screens.push({
			ID = "LowRel",
			Text = "[img]gfx/ui/events/event_80.png[/img]对方微微摇头：『贵队与敝派尚欠渊源，门中上乘功法恕难轻授。』",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "来日方长。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});

		this.m.Screens.push(::Wuxia.Loot.makeNoRoomScreen());
		this.m.Screens.push({
			ID = "Offended", Text = "传人拾起撕碎的门帖，记下了你们的旗号。这笔账，门中自会有人过问。",
			Image = "", List = [], Characters = [],
			Options = [{ Text = "出城。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});
		this.m.Screens.push({
			ID = "NoMoney",
			Text = "[img]gfx/ui/events/event_80.png[/img]手头银两不足，只得作罢。",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "告辞。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Loot.isNearMarketTown() || ::Wuxia.SectRelations.getExchangeSects().len() == 0) return;
		this.m.Score = 14;
	}
});
