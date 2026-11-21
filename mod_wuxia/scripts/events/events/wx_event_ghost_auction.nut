// M3 World Event: 无常鬼市压轴拍卖（高价竞拍绝学、江湖孤本或稀世洗髓丹）

this.wx_event_ghost_auction <- this.inherit("scripts/events/event", {
	m = {
		LotKind = "manual",
		LotID   = "wx_manual_huifeng",
		LotName = "",
		BidPrice = 4500
	},

	function create()
	{
		this.m.ID = "event.wx_ghost_auction";
		this.m.Title = "无常鬼市压轴拍卖";
		this.m.Cooldown = 28.0 * this.World.getTime().SecondsPerDay;
		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "直接高价拍下压轴奇珍",
					function getResult( _event )
					{
						local item;
						if (_event.m.LotKind == "pill")
						{
							item = ::new("scripts/items/misc/wx_pill_item");
							item.initPill(_event.m.LotID);
						}
						else if (_event.m.LotKind == "relic_weapon" || _event.m.LotKind == "shanhai_item")
						{
							item = ::new(_event.m.LotID);
						}
						else
						{
							item = ::new("scripts/items/misc/wx_manual_item");
							item.initManual(_event.m.LotID);
						}
						return ::Wuxia.Loot.purchaseEventItem(item, _event.m.BidPrice, "Won");
					}
				},
				{
					Text = "囊中羞涩，冷眼旁观退场。",
					function getResult( _event ) { return 0; }
				}
			],
			function start( _event )
			{
				local roll = ::Math.rand(1, 100);
				if (roll <= 18)
				{
					local pOpts = [
						["wx_pill_xisui", "稀世奇药【洗髓丹】", 5200],
						["wx_pill_zijin", "仙品圣丹【太虚紫金大丹】", 3400],
						["wx_pill_zaohua", "护脉圣药【山海造化护脉金丹】", 3100],
						["wx_pill_shennong", "救命仙药【神农百草返魂丹】", 2700]
					];
					local pPick = pOpts[::Math.rand(0, pOpts.len() - 1)];
					_event.m.LotKind = "pill";
					_event.m.LotID = pPick[0];
					_event.m.LotName = pPick[1];
					_event.m.BidPrice = pPick[2];
				}
				else if (roll <= 32)
				{
					local sovPool = ::Wuxia.ShanHai.getSovereignCoreIDs();
					if (sovPool.len() > 0)
					{
						local cid = sovPool[::Math.rand(0, sovPool.len() - 1)];
						local ccfg = ::Wuxia.Config.ShanHaiCores[cid];
						_event.m.LotKind = "shanhai_item";
						_event.m.LotID = "scripts/items/misc/" + cid;
						_event.m.LotName = "太古神丹" + ccfg.Name;
						_event.m.BidPrice = ccfg.Value + 900;
					}
					else
					{
						_event.m.LotKind = "pill";
						_event.m.LotID = "wx_pill_xisui";
						_event.m.LotName = "稀世奇药【洗髓丹】";
						_event.m.BidPrice = 5200;
					}
				}
				else if (roll <= 52)
				{
					local rPool = ::Wuxia.Relics.getRelicIDs();
					local rid = rPool[::Math.rand(0, rPool.len() - 1)];
					local rcfg = ::Wuxia.Config.RelicWeapons[rid];
					_event.m.LotKind = "relic_weapon";
					_event.m.LotID = rcfg.Script;
					_event.m.LotName = (("IsShanHai" in rcfg && rcfg.IsShanHai) ? "山海神兵" : "传世神兵") + "【传世·" + rcfg.Name + "】";
					_event.m.BidPrice = rcfg.MinValue;
				}
				else if (roll <= 62)
				{
					local uniques = ::Wuxia.Loot.getManualIDsByQuality("unique");
					local mid = uniques[::Math.rand(0, uniques.len() - 1)];
					local def = ::Wuxia.Slots.getManualDef(mid);
					_event.m.LotKind = "manual";
					_event.m.LotID = mid;
					_event.m.LotName = "江湖孤本《" + def.Name + "》";
					_event.m.BidPrice = 11500;
				}
				else
				{
					local secrets = ::Wuxia.Loot.getManualIDsByQuality("secret");
					local mid = secrets[::Math.rand(0, secrets.len() - 1)];
					local def = ::Wuxia.Slots.getManualDef(mid);
					_event.m.LotKind = "manual";
					_event.m.LotID = mid;
					_event.m.LotName = "镇派绝学《" + def.Name + "》";
					_event.m.BidPrice = 4800;
				}

				this.Text = "[img]gfx/ui/events/wx_ev_04.png[/img]子夜三更，无常鬼市灯火幽微。戴着青铜面具的司仪揭开红绸，台下各路豪客顿时屏息——今晚压轴之物竟是 " + _event.m.LotName + "！几轮竞价过后，眼下只需出到 " + _event.m.BidPrice + " 银两便可一锤定音。";
				this.Options[0].Text = "豪掷 " + _event.m.BidPrice + " 银两拍下 " + _event.m.LotName;
			}
		});

		this.m.Screens.push({
			ID = "Won",
			Text = "[img]gfx/ui/events/wx_ev_04.png[/img]铜锣三响，压轴奇珍归入囊中！四周投来数道灼热目光，你们压低斗笠迅速隐入夜色。",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "速速离场。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});

		this.m.Screens.push(::Wuxia.Loot.makeNoRoomScreen());
		this.m.Screens.push({
			ID = "NoMoney",
			Text = "[img]gfx/ui/events/wx_ev_04.png[/img]银两不够竞拍价，只能眼睁睁看着奇珍落入他人之手。",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "扼腕退场。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});
	}

	function onUpdateScore()
	{
		if (this.World.getTime().Days < 15) return;
		if (this.World.Assets.getMoney() < 3500) return;
		this.m.Score = 12;
	}
});
