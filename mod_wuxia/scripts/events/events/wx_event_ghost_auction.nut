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
						else if (_event.m.LotKind == "named_fist")
						{
							item = ::new("scripts/items/weapons/named/wx_named_fist");
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
				if (roll <= 22)
				{
					_event.m.LotKind = "pill";
					_event.m.LotID = "wx_pill_xisui";
					_event.m.LotName = "稀世奇药【洗髓丹】";
					_event.m.BidPrice = 5200;
				}
				else if (roll <= 37)
				{
					_event.m.LotKind = "named_fist";
					_event.m.LotID = "weapon.wx_named_fist";
					_event.m.LotName = "传世名器【百炼拳掌护手】";
					_event.m.BidPrice = 5600;
				}
				else if (roll <= 55)
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

				this.Text = "[img]gfx/ui/events/event_45.png[/img]子夜三更，无常鬼市灯火幽微。戴着青铜面具的司仪揭开红绸，台下各路豪客顿时屏息——今晚压轴之物竟是 " + _event.m.LotName + "！几轮竞价过后，眼下只需出到 " + _event.m.BidPrice + " 银两便可一锤定音。";
				this.Options[0].Text = "豪掷 " + _event.m.BidPrice + " 银两拍下 " + _event.m.LotName;
			}
		});

		this.m.Screens.push({
			ID = "Won",
			Text = "[img]gfx/ui/events/event_45.png[/img]铜锣三响，压轴奇珍归入囊中！四周投来数道灼热目光，你们压低斗笠迅速隐入夜色。",
			Image = "",
			List = [],
			Characters = [],
			Options = [{ Text = "速速离场。", function getResult( _event ) { return 0; } }],
			function start( _event ) {}
		});

		this.m.Screens.push(::Wuxia.Loot.makeNoRoomScreen());
		this.m.Screens.push({
			ID = "NoMoney",
			Text = "[img]gfx/ui/events/event_45.png[/img]银两不够竞拍价，只能眼睁睁看着奇珍落入他人之手。",
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
