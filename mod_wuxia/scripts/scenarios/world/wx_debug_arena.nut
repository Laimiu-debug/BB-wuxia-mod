// M0/M1 Debug Testing Origin: 「演武试剑台」
// Spawns multi-level test heroes + full set of manuals, pages & pills to verify the entire framework on Day 1.

this.wx_debug_arena <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},

	function create()
	{
		this.m.ID = "scenario.wx_debug_arena";
		this.m.Name = "【调试】演武试剑台";
		this.m.Description = "[p=c][img]gfx/ui/events/event_80.png[/img][/p][p]武侠 Mod 底座框架测试开局。开局即配备 1/5/9/11 级测试侠客、全套 260+ 本武学秘籍、传世历史神兵红武、残页（含满额拼合/同阶补缺/参悟化功样本）与五种核心丹药，用于直接检验七大插槽、组合词条、残页化功与洗经伐髓。[/p]";
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

		// Populate Stash with all 268 manuals, Fist weapons, sample Historical Relics, Shan Hai Red Gear & Cores, pages, and pills
		local stash = this.World.Assets.getStash();
		stash.resize(415);

		foreach (wp in [
			"weapons/wx_fist_wraps", "weapons/wx_fist_iron", "weapons/wx_fist_heavy", "weapons/named/wx_named_fist",
			"weapons/named/wx_relic_taie", "weapons/named/wx_relic_modao", "weapons/named/wx_relic_huaji",
			"weapons/named/wx_relic_huntiegun", "weapons/named/wx_relic_longlinzhao", "weapons/named/wx_relic_wengjinchui",
			"weapons/named/wx_relic_yuchang", "weapons/named/wx_relic_zhentiangong", "weapons/named/wx_relic_xingtianqi",
			"armor/named/wx_armor_zhuyan", "armor/named/wx_armor_feiyi", "armor/named/wx_armor_qiongqi", "armor/named/wx_armor_jumang",
			"helmets/named/wx_helm_taotie", "helmets/named/wx_helm_bashe",
			"accessory/wx_acc_jiuwei", "accessory/wx_acc_wuzhiqi",
			"misc/wx_core_zhuyan", "misc/wx_core_feiyi"
		])
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

		// Sample pages: 3/3 exact craftable + 2/3 wildcard-craftable + two 1/3 spare sect pages (for 2:1 wildcard & 参悟化功!) + 3/5 secret page
		local pCraft = ::new("scripts/items/misc/wx_page_item");
		pCraft.initPages("wx_manual_heifeng", 3);
		stash.add(pCraft);

		local pWild = ::new("scripts/items/misc/wx_page_item");
		pWild.initPages("wx_manual_zixia_gong", 2);
		stash.add(pWild);

		foreach (spID in ["wx_manual_shuofang_jingua", "wx_manual_mobei_taoma_bian"])
		{
			local pSp = ::new("scripts/items/misc/wx_page_item");
			pSp.initPages(spID, 1);
			stash.add(pSp);
		}

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
