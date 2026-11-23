// Pure Wuxia Origin 2: 「孤剑独行 · 天涯浪客」
// Elite lone-swordsman start (inspired by Lone Wolf, adapted to 7-Slot Martial Cultivation).

this.wx_origin_lone_sword <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},

	function create()
	{
		this.m.ID = "scenario.wx_origin_lone_sword";
		this.m.Name = "孤剑独行 · 天涯浪客";
		this.m.Description = "[p=c][img]gfx/ui/events/wx_ev_01.png[/img][/p][p]你曾是名山剑宗门下最惊才绝艳的弃徒。一袭竹笠青衫、三尺松纹寒铁，独自仗剑踏入乱世江湖。你无需供养庞大冗兵，只择真正入眼的生死知己结伴同行。[/p][p][color=#bcad8c]• 开局阵容：1 名 4 级成名剑客（自带上乘《松涛心法》《清风连环剑》《踏雪无痕》）\n• 精兵悟道：全队战后武学熟稔度获取 +25%，城池购置秘籍军械享 92 折优惠\n• 孤锋铁律：花名册上限硬锁 12 人，唯求个个皆为独当一面之高手[/color][/p]";
		this.m.Difficulty = 3;
		this.m.Order = 2;
	}

	function onInit()
	{
		if (this.World.Assets.m.BrothersMax > 12)
			this.World.Assets.m.BrothersMax = 12;
		if ("BuyPriceMult" in this.World.Assets.m)
			this.World.Assets.m.BuyPriceMult *= 0.92;
	}

	function onSpawnAssets()
	{
		local roster = this.World.getPlayerRoster();
		::Wuxia.Backgrounds.SuppressAutoAssign = true;
		try
		{
			local bro = roster.create("scripts/entity/tactical/player");
			bro.setStartValuesEx(["swordmaster_background"]);
			local usedNames = {};
			local usedManuals = {};
			::Wuxia.Backgrounds.rollUniqueActorName(bro, usedNames, "master");
			local loneTitles = ["天涯孤剑", "断水青锋", "孤鸿剑客", "寒江独钓", "折柳惊鸿", "松风弃徒"];
			bro.setTitle(loneTitles[::Math.rand(0, loneTitles.len() - 1)]);
			bro.setPlaceInFormation(4);
			bro.m.HireTime = this.Time.getVirtualTimeF();

			// Advance to Level 4 cleanly: unlocks 3rd Qinggong slot immediately AND grants 3 full Level-Up attribute picks!
			bro.m.Level = 4;
			bro.m.XP = this.Const.LevelXP[3];
			bro.m.LevelUps = 3;
			bro.m.BaseProperties.Hitpoints += 4;
			bro.m.BaseProperties.Bravery += 4;
			bro.m.Hitpoints = bro.getHitpointsMax();
			bro.m.PerkPoints = 0;

			local items = bro.getItems();
			if (items.getItemAtSlot(this.Const.ItemSlot.Mainhand) != null)
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
			if (items.getItemAtSlot(this.Const.ItemSlot.Offhand) != null)
				items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
			local mainSword = ::new("scripts/items/weapons/noble_sword");
			items.equip(mainSword);

			local neiID = ::Wuxia.Backgrounds.pickCatalogManual("neigong", "sect", null, usedManuals, "wx_manual_songtao");
			local waiID = ::Wuxia.Backgrounds.pickCatalogManual("waigong", "sect", mainSword, usedManuals, "wx_manual_qingfeng");
			local qingID = ::Wuxia.Backgrounds.pickCatalogManual("qinggong", "sect", null, usedManuals, "wx_manual_taxue");
			::Wuxia.Slots.equipManual(bro, 0, neiID, false);
			::Wuxia.Slots.equipManual(bro, 1, waiID, false);
			::Wuxia.Slots.equipManual(bro, 2, qingID, false);
			::Wuxia.Slots.learnManual(bro, "wx_manual_gufeng", false);
			if (bro.getBackground() != null && ::Wuxia.hasMember(bro.getBackground(), "WX_RefreshStarterNote"))
			{
				bro.getBackground().WX_RefreshStarterNote([
					::Wuxia.Slots.getManualDef(neiID).Name,
					::Wuxia.Slots.getManualDef(waiID).Name,
					::Wuxia.Slots.getManualDef(qingID).Name
				]);
			}
			bro.getSkills().update();
		}
		catch (err)
		{
			::Wuxia.Backgrounds.SuppressAutoAssign = false;
			throw err;
		}
		::Wuxia.Backgrounds.SuppressAutoAssign = false;

		local stash = this.World.Assets.getStash();
		foreach (pid in ["wx_pill_jinchuang", "wx_pill_huxin", "wx_pill_ningshen"])
		{
			local pill = ::new("scripts/items/misc/wx_pill_item");
			pill.initPill(pid);
			stash.add(pill);
		}

		this.World.Assets.m.Money = 1800;
		this.World.Assets.addBusinessReputation(200);

		local food = ::new("scripts/items/supplies/cured_rations_item");
		food.setAmount(25);
		stash.add(food);
		this.World.Assets.updateFood();
	}

	function onSpawnPlayer()
	{
		::Wuxia.spawnPlayerNearSettlement();
		this.World.Assets.updateLook(17);
	}
});
