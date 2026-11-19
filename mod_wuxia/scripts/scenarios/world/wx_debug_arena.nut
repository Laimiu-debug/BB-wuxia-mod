// M0/M1 Debug Testing Origin: 「演武试剑台」
// Spawns multi-level test heroes + full set of manuals, pages & pills to verify the entire framework on Day 1.

this.wx_debug_arena <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},

	function create()
	{
		this.m.ID = "scenario.wx_debug_arena";
		this.m.Name = "【调试】演武试剑台";
		this.m.Description = "[p=c][img]gfx/ui/events/event_80.png[/img][/p][p]武侠 Mod 底座框架测试开局。开局即配备各等级侠客、全品阶秘籍、残页与五种核心丹药（含洗髓丹、护脉丹、凝神丸），用于直接检验七大图标插槽拖拽、散功覆盖、火候升重、突破 9 AP 与洗经伐髓。[/p]";
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

		for (local i = 0; i < presets.len(); i = ++i)
		{
			local p = presets[i];
			local bro = roster.create("scripts/entity/tactical/player");
			bro.setStartValuesEx([p.Bg]);
			bro.setName(p.Name);
			bro.setPlaceInFormation(i + 2);

			// Advance to preset level so slots unlock immediately
			while (bro.getLevel() < p.Level)
			{
				bro.m.XP = ::Const.LevelXP[bro.getLevel()];
				bro.updateLevel();
			}
			bro.m.PerkPoints = 0;
		}

		// Equip one hero with starter manual to showcase loaded slot right away
		local brothers = roster.getAll();
		if (brothers.len() > 0)
		{
			::Wuxia.Slots.equipManual(brothers[0], 0, "wx_manual_guiyuan", false);
			::Wuxia.Slots.equipManual(brothers[0], 1, "wx_manual_qingfeng", false);
		}

		// Populate Stash with sample manuals across all 4 tiers, pages, and all 5 pills
		local stash = this.World.Assets.getStash();
		stash.resize(120);

		local sampleManuals = [
			"wx_manual_tuna", "wx_manual_xingqi", "wx_manual_jichujian", "wx_manual_wuhudao",
			"wx_manual_liuheqiang", "wx_manual_jianbu", "wx_manual_yingpi", "wx_manual_xiushou",
			"wx_manual_songtao", "wx_manual_guiyuan", "wx_manual_qingfeng", "wx_manual_weiyuan",
			"wx_manual_heifeng", "wx_manual_taxue", "wx_manual_jinchan", "wx_manual_tiebushan",
			"wx_manual_xuesha", "wx_manual_huifeng", "wx_manual_duanyue", "wx_manual_baoyu", "wx_manual_suodi",
			"wx_manual_taixu", "wx_manual_lingbo", "wx_manual_tianwai"
		];

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
	}

	function onSpawnPlayer()
	{
		local settlements = this.World.EntityManager.getSettlements();
		if (settlements.len() > 0)
		{
			this.World.State.getPlayer().setPos(settlements[0].getPos());
		}
	}
});
