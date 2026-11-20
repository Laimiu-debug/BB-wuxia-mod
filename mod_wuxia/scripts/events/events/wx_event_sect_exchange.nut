// Upgraded M4 Regional Sect Tea-House Event:
// Displays 3 regionally-anchored sects at once so 42 sects feel geographically rich without RNG dilution!

this.wx_event_sect_exchange <- this.inherit("scripts/events/event", {
	m = {
		Choices      = ["weiyuan", "qingfeng", "shaolin"],
		SectID       = "qingfeng",
		OfferIndices = [0]
	},

	function wxPickTwoOffers( _sect )
	{
		local total = _sect.ShopManuals.len();
		if (total <= 3)
		{
			local all = [];
			for (local i = 0; i < total; ++i) all.push(i);
			this.m.OfferIndices = all;
			return;
		}
		// Pick 3 distinct offers spanning entry, sect-core, and secret prestige tiers!
		local pool = [];
		for (local j = 0; j < total; ++j) pool.push(j);
		local picked = [];
		for (local k = 0; k < 3 && pool.len() > 0; ++k)
		{
			local r = ::Math.rand(0, pool.len() - 1);
			picked.push(pool[r]);
			pool.remove(r);
		}
		picked.sort();
		this.m.OfferIndices = picked;
	}

	function create()
	{
		this.m.ID = "event.wx_sect_exchange";
		this.m.Title = "城中茶楼 · 江湖各派行客";
		this.m.Cooldown = 8.0 * this.World.getTime().SecondsPerDay;

		// Screen A: Choose which of the 3 local/roaming sect tables to approach!
		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "拜会第一桌门派行客",
					function getResult( _event )
					{
						_event.m.SectID = _event.m.Choices[0];
						_event.wxPickTwoOffers(::Wuxia.Config.Sects[_event.m.SectID]);
						return "Visit";
					}
				},
				{
					Text = "拜会第二桌门派行客",
					function getResult( _event )
					{
						_event.m.SectID = _event.m.Choices[1];
						_event.wxPickTwoOffers(::Wuxia.Config.Sects[_event.m.SectID]);
						return "Visit";
					}
				},
				{
					Text = "拜会第三桌门派行客",
					function getResult( _event )
					{
						_event.m.SectID = _event.m.Choices[2];
						_event.wxPickTwoOffers(::Wuxia.Config.Sects[_event.m.SectID]);
						return "Visit";
					}
				},
				{
					Text = "饮尽粗茶，不多生枝节。",
					function getResult( _event ) { return 0; }
				}
			],
			function start( _event )
			{
				local region = ::Wuxia.SectRelations.getLocalRegion();
				local regionLabel = ::Wuxia.SectRelations.getRegionLabel(region);
				local trio = ::Wuxia.SectRelations.pickRegionalTrio(region);
				while (trio.len() < 3) trio.push("weiyuan");
				_event.m.Choices = trio;

				this.Text = "[img]gfx/ui/events/event_80.png[/img]行至【" + regionLabel + "】地界城池，迎风茶楼二层人声鼎沸，刀剑兵刃斜靠桌畔。跑堂茶博士低声指点——今日楼中恰好坐着三拨不同门户的江湖传人，正欲寻哪一桌递帖叙话？";

				for (local i = 0; i < 3; i = ++i)
				{
					local sid = trio[i];
					local s = ::Wuxia.Config.Sects[sid];
					local rel = ::Wuxia.SectRelations.getRelation(sid);
					local rName = ::Wuxia.SectRelations.getRegionLabel(("Region" in s) ? s.Region : "plains");
					this.Options[i].Text = "走向【" + s.Name + "】席位（" + rName + " · 当前交情：" + rel + "）";
				}
			}
		});

		// Screen Visit: Interact with the selected sect (2 manual exchange slots + Banquet +20 rel + Tear card -35 rel)
		this.m.Screens.push({
			ID = "Visit",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [],
			function start( _event )
			{
				this.Options = [];
				local sect = ::Wuxia.Config.Sects[_event.m.SectID];
				local rel = ::Wuxia.SectRelations.getRelation(_event.m.SectID);

				local indices = _event.m.OfferIndices;

				local bookDesc = "";
				foreach (oi in indices)
				{
					local idx = oi;
					local offer = sect.ShopManuals[idx];
					local def = ::Wuxia.Slots.getManualDef(offer.ManualID);
					if (bookDesc != "") bookDesc += "；";
					bookDesc += "《" + def.Name + "》（需交情≥" + offer.MinRel + "，" + offer.Price + " 两）";

					this.Options.push({
						Text = "请教兑换《" + def.Name + "》（需交情 " + offer.MinRel + " / " + offer.Price + " 银两）",
						function getResult( _ev )
						{
							local sc = ::Wuxia.Config.Sects[_ev.m.SectID];
							local of = sc.ShopManuals[idx];
							if (::Wuxia.SectRelations.getRelation(_ev.m.SectID) < of.MinRel) return "LowRel";
							local mItem = ::new("scripts/items/misc/wx_manual_item");
							mItem.initManual(of.ManualID);
							return ::Wuxia.Loot.purchaseEventItem(mItem, of.Price, "Exchanged");
						}
					});
				}

				this.Options.push({
					Text = "设美酒佳肴款待论交（花 500 银两，【" + sect.Name + "】交情 +20）",
					function getResult( _ev )
					{
						if (this.World.Assets.getMoney() < 500) return "NoMoney";
						this.World.Assets.addMoney(-500);
						::Wuxia.SectRelations.addRelation(_ev.m.SectID, 20);
						return "Befriended";
					}
				});

				this.Options.push({
					Text = "当面折辱撕毁门帖（交情 -35，交恶后将招致该门派追缉）",
					function getResult( _ev )
					{
						::Wuxia.SectRelations.addRelation(_ev.m.SectID, -35);
						return "Offended";
					}
				});

				this.Options.push({
					Text = "拱手别过。",
					function getResult( _ev ) { return 0; }
				});

				this.Text = "[img]gfx/ui/events/event_80.png[/img]你来到【" + sect.Name + "】传人席前抱拳落座（当前交情：" + rel + "）。\n\n" + sect.Description + "\n\n对方抚掌笑道：『既是有缘相会，敝门此行携有抄本：" + bookDesc + "。不知诸位意欲何为？』";
			}
		});

		this.m.Screens.push({
			ID = "Exchanged",
			Text = "[img]gfx/ui/events/event_80.png[/img]银货两讫，对方郑重将本门武学抄本交托予你，并叮嘱切莫轻传宵小。",
			Image = "", List = [], Characters = [],
			Options = [{ Text = "抱拳谢过。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});

		this.m.Screens.push({
			ID = "Befriended",
			Text = "[img]gfx/ui/events/event_80.png[/img]一席好酒畅谈武林掌故，双方引为知己，门派交情大增（+20）！",
			Image = "", List = [], Characters = [],
			Options = [{ Text = "后会有期。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});

		this.m.Screens.push({
			ID = "LowRel",
			Text = "[img]gfx/ui/events/event_80.png[/img]对方微微摇头：『贵队与敝派尚欠渊源，门中真传功法恕难轻授，不妨日后多走动往来。』",
			Image = "", List = [], Characters = [],
			Options = [{ Text = "来日方长。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});

		this.m.Screens.push(::Wuxia.Loot.makeNoRoomScreen());
		this.m.Screens.push({
			ID = "Offended",
			Text = "传人拾起撕碎的门帖，冷冷记下了你们的旗号。这笔梁子结下了，道上自会有本门高手前来了断。",
			Image = "", List = [], Characters = [],
			Options = [{ Text = "出城。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});
		this.m.Screens.push({
			ID = "NoMoney",
			Text = "[img]gfx/ui/events/event_80.png[/img]手头银两不足，只得作罢。",
			Image = "", List = [], Characters = [],
			Options = [{ Text = "告辞。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});
	}

	function onUpdateScore()
	{
		if (!::Wuxia.Loot.isNearMarketTown() || ::Wuxia.SectRelations.getExchangeSects().len() == 0) return;
		this.m.Score = 18;
	}
});
