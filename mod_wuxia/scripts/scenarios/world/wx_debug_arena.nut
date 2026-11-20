// M0/M1 Debug Testing Origin: 「演武试剑台」
// Spawns multi-level test heroes + full set of manuals, pages & pills to verify the entire framework on Day 1.

this.wx_debug_arena <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},

	function create()
	{
		this.m.ID = "scenario.wx_debug_arena";
		this.m.Name = "【调试】演武试剑台";
		this.m.Description = "[p=c][img]gfx/ui/events/event_80.png[/img][/p][p]武侠 Mod 底座框架测试开局。开局即配备 1/5/9/11 级测试侠客、全套 24 本秘籍、残页与五种核心丹药（含洗髓丹、护脉丹、凝神丸），用于直接检验七大图标插槽拖拽、散功覆盖、火候升重、突破 9 AP 与洗经伐髓。[/p]";
		this.m.Difficulty = 1;
		this.m.Order = 200;
	}

	function onSpawnAssets()
	{
		local roster = this.World.getPlayerRoster();

		// Create 4 test heroes at Levels 1, 5, 9, 11 to test every slot unlock tier immediately
		local presets = [
			{ Name = "沈清风", Level = 11, Bg = "swordmaster_background" },
			{ Name = "雷震山", Level = 9,  Bg = "sellsword_background" },
			{ Name = "柳青衣", Level = 5,  Bg = "militia_background" },
			{ Name = "陈小镖", Level = 1,  Bg = "caravan_hand_background" }
		];

		::Wuxia.Backgrounds.SuppressAutoAssign = true;
		try
		{
			for (local i = 0; i < presets.len(); i = ++i)
			{
				local p = presets[i];
				local bro = roster.create("scripts/entity/tactical/player");
				bro.setStartValuesEx([p.Bg]);
				bro.setName(p.Name);
				bro.setPlaceInFormation(i + 2);
				bro.m.HireTime = this.Time.getVirtualTimeF();

				// Safely advance level directly without calling updateLevel() in a loop!
				if (p.Level > 1)
				{
					local extraLevels = p.Level - 1;
					bro.m.Level = p.Level;
					bro.m.XP = this.Const.LevelXP[p.Level - 1];
					bro.m.LevelUps = 0;
					bro.m.BaseProperties.Hitpoints += extraLevels * 2;
					bro.m.BaseProperties.Stamina += extraLevels * 3;
					bro.m.BaseProperties.Bravery += extraLevels * 2;
					bro.m.BaseProperties.Initiative += extraLevels * 3;
					bro.m.BaseProperties.MeleeSkill += extraLevels * 3;
					bro.m.BaseProperties.MeleeDefense += extraLevels * 2;
					bro.m.Hitpoints = bro.getHitpointsMax();
				}
				bro.m.PerkPoints = 0;
				bro.getSkills().update();
			}
		}
		catch (err)
		{
			::Wuxia.Backgrounds.SuppressAutoAssign = false;
			throw err;
		}
		::Wuxia.Backgrounds.SuppressAutoAssign = false;

		// Equip first hero with starter manuals to showcase loaded slots right away
		local brothers = roster.getAll();
		if (brothers.len() > 0)
		{
			::Wuxia.Slots.equipManual(brothers[0], 0, "wx_manual_guiyuan", false);
			::Wuxia.Slots.equipManual(brothers[0], 1, "wx_manual_qingfeng", false);
		}

		// Populate Stash with all manuals, paired Fist weapons, pages, and all 5 pills
		local stash = this.World.Assets.getStash();
		stash.resize(140);

		foreach (wp in ["weapons/wx_fist_wraps", "weapons/wx_fist_iron", "weapons/wx_fist_heavy", "weapons/named/wx_named_fist"])
		{
			stash.add(::new("scripts/items/" + wp));
		}

		local sampleManuals = [];
		foreach (id, def in ::Wuxia.Config.Manuals) sampleManuals.push(id);
		sampleManuals.sort();

		foreach (mid in sampleManuals)
		{
			local mItem = ::new("scripts/items/misc/wx_manual_item");
			mItem.initManual(mid);
			stash.add(mItem);
		}

		// Sample pages: 3/3 craftable + 3/5 partial for risky fragment learn
		local pCraft = ::new("scripts/items/misc/wx_page_item");
		pCraft.initPages("wx_manual_heifeng", 3);
		stash.add(pCraft);

		local pPartial = ::new("scripts/items/misc/wx_page_item");
		pPartial.initPages("wx_manual_duanyue", 3);
		stash.add(pPartial);

		// All 5 core pills
		local pillStocks = [
			{ ID = "wx_pill_jinchuang", Qty = 3 },
			{ ID = "wx_pill_huxin",     Qty = 4 },
			{ ID = "wx_pill_ningshen",  Qty = 6 },
			{ ID = "wx_pill_xisui",     Qty = 4 },
			{ ID = "wx_pill_humai",     Qty = 3 }
		];

		foreach (ps in pillStocks)
		{
			for (local q = 0; q < ps.Qty; q = ++q)
			{
				local pill = ::new("scripts/items/misc/wx_pill_item");
				pill.initPill(ps.ID);
				stash.add(pill);
			}
		}

		this.World.Assets.m.Money = 15000;
		this.World.Assets.addBusinessReputation(300);

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
