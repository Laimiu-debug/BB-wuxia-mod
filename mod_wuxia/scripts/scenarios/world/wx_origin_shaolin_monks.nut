// Pure Wuxia Origin 3: 「少室下山 · 护法行者」
// 3 Shaolin martial monks / lay disciples descending the mountain with paired gauntlets & iron-capped staffs.

this.wx_origin_shaolin_monks <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},

	function create()
	{
		this.m.ID = "scenario.wx_origin_shaolin_monks";
		this.m.Name = "少室下山 · 护法行者";
		this.m.Description = "[p=c][img]gfx/ui/events/wx_ev_03.png[/img][/p][p]乱世妖氛四起，三名奉方丈法旨下山历练的少室武院行者，携成对精铁护手与齐眉棍踏入红尘。禅门拳掌隔甲震腑、空手夺刃，硬功护体金刚不坏。[/p][p][color=#bcad8c]• 开局阵容：3 名少室护法行者（兼修拳掌《罗汉散手》、长棍与《铁布衫》）\n• 宗门渊源：少室禅院初始交情 +35，茶肆可直接请教禅门上乘绝学\n• 起始资财：2,000 两纹银，附护心丹与金疮散[/color][/p]";
		this.m.Difficulty = 2;
		this.m.Order = 3;
	}

	function onSpawnAssets()
	{
		local roster = this.World.getPlayerRoster();
		local monks = [
			{ Pool = "monk", Bg = "monk_background",    Wpn = "weapons/wx_fist_iron",  NeiQual = "sect",   WaiQual = "common", Extras = ["wx_manual_tiebushan"] },
			{ Pool = "monk", Bg = "brawler_background", Wpn = "weapons/wx_fist_wraps", NeiQual = "common", WaiQual = "common", Extras = [] },
			{ Pool = "monk", Bg = "militia_background", Wpn = "weapons/wooden_stick",  NeiQual = "common", WaiQual = "common", Extras = ["wx_manual_yingpi", "wx_manual_tiebushan"] }
		];

		local usedNames = {};
		local usedManuals = {};

		::Wuxia.Backgrounds.SuppressAutoAssign = true;
		try
		{
			for (local i = 0; i < monks.len(); i = ++i)
			{
				local mk = monks[i];
				local bro = roster.create("scripts/entity/tactical/player");
				bro.setStartValuesEx([mk.Bg]);
				::Wuxia.Backgrounds.rollUniqueActorName(bro, usedNames, mk.Pool);
				bro.setPlaceInFormation(i + 3);
				bro.m.HireTime = this.Time.getVirtualTimeF();
				bro.m.BaseProperties.MeleeSkill += 6;
				bro.m.BaseProperties.Bravery += 8;
				bro.m.BaseProperties.Hitpoints += 6;
				bro.m.Hitpoints = bro.getHitpointsMax();
				bro.m.PerkPoints = 0;

				local items = bro.getItems();
				if (items.getItemAtSlot(this.Const.ItemSlot.Mainhand) != null)
					items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
				if (items.getItemAtSlot(this.Const.ItemSlot.Offhand) != null)
					items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
				local mainWpn = ::new("scripts/items/" + mk.Wpn);
				items.equip(mainWpn);

				local neiID = ::Wuxia.Backgrounds.pickCatalogManual("neigong", mk.NeiQual, null, usedManuals, mk.NeiQual == "sect" ? "wx_manual_guiyuan" : "wx_manual_tuna");
				local waiID = ::Wuxia.Backgrounds.pickCatalogManual("waigong", mk.WaiQual, mainWpn, usedManuals, "wx_manual_luohan");
				::Wuxia.Slots.equipManual(bro, 0, neiID, false);
				::Wuxia.Slots.equipManual(bro, 1, waiID, false);
				foreach (exMid in mk.Extras)
					::Wuxia.Slots.learnManual(bro, exMid, false);
				if (bro.getBackground() != null && ("WX_RefreshStarterNote" in bro.getBackground()))
					bro.getBackground().WX_RefreshStarterNote([::Wuxia.Slots.getManualDef(neiID).Name, ::Wuxia.Slots.getManualDef(waiID).Name]);
				bro.getSkills().update();
			}
		}
		catch (err)
		{
			::Wuxia.Backgrounds.SuppressAutoAssign = false;
			throw err;
		}
		::Wuxia.Backgrounds.SuppressAutoAssign = false;

		if ("SectRelations" in ::Wuxia && "addRelation" in ::Wuxia.SectRelations)
			::Wuxia.SectRelations.addRelation("shaolin", 35);

		local stash = this.World.Assets.getStash();
		foreach (pid in ["wx_pill_jinchuang", "wx_pill_jinchuang", "wx_pill_huxin"])
		{
			local pill = ::new("scripts/items/misc/wx_pill_item");
			pill.initPill(pid);
			stash.add(pill);
		}

		this.World.Assets.m.Money = 2000;
		this.World.Assets.addBusinessReputation(120);

		local food = ::new("scripts/items/supplies/ground_grains_item");
		food.setAmount(25);
		stash.add(food);
		this.World.Assets.updateFood();
	}

	function onSpawnPlayer()
	{
		::Wuxia.spawnPlayerNearSettlement();
	}
});
