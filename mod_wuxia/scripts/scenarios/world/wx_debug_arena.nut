// M0/M1 Debug Testing Origin: 「演武试剑台」
// Spawns multi-level test heroes + full set of manuals, pages & pills to verify the entire framework on Day 1.

this.wx_debug_arena <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},

	function create()
	{
		this.m.ID = "scenario.wx_debug_arena";
		this.m.Name = "演武试剑台（全武学体验）";
		this.m.Description = "[p=c][img]gfx/ui/events/wx_ev_05.png[/img][/p][p]武侠江湖沙盒演武开局。开局即配备 1/5/9/11 级测试侠客、藏经阁收录全套 270+ 本武学秘籍、传世历史与山海神兵红装、残页与五种核心灵丹，供各位掌门自由搭配流派、试招验武。[/p]";
		this.m.Difficulty = 1;
		this.m.Order = 99;
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

		// Equip first hero with starter manuals + extra learned manuals to test Perk-page slot selection right away
		local brothers = roster.getAll();
		if (brothers.len() > 0)
		{
			::Wuxia.Slots.equipManual(brothers[0], 0, "wx_manual_guiyuan", false);
			::Wuxia.Slots.equipManual(brothers[0], 1, "wx_manual_qingfeng", false);
			::Wuxia.Slots.learnManual(brothers[0], "wx_manual_taxue", false);
			::Wuxia.Slots.learnManual(brothers[0], "wx_manual_jinchan", false);
			::Wuxia.Slots.learnManual(brothers[0], "wx_manual_huifeng", false);
		}

		// Populate Stash cleanly with gear, relics, Shan Hai cores & pills (while all 268+ manuals & pages live in 藏经阁!)
		local stash = this.World.Assets.getStash();
		stash.resize(117);

		foreach (wp in [
			"weapons/wx_fist_wraps", "weapons/wx_fist_iron", "weapons/wx_fist_heavy", "weapons/named/wx_named_fist",
			"weapons/named/wx_relic_taie", "weapons/named/wx_relic_modao", "weapons/named/wx_relic_huaji",
			"weapons/named/wx_relic_huntiegun", "weapons/named/wx_relic_longlinzhao", "weapons/named/wx_relic_wengjinchui",
			"weapons/named/wx_relic_yuchang", "weapons/named/wx_relic_zhentiangong", "weapons/named/wx_relic_xingtianqi",
			"armor/named/wx_armor_zhuyan", "armor/named/wx_armor_feiyi", "armor/named/wx_armor_qiongqi", "armor/named/wx_armor_jumang",
			"helmets/named/wx_helm_taotie", "helmets/named/wx_helm_bashe",
			"accessory/wx_acc_jiuwei", "accessory/wx_acc_wuzhiqi",
			"weapons/wx_beast_sword", "armor/wx_beast_armor_med", "armor_upgrades/wx_up_chiling",
			"misc/wx_core_zhuyan", "misc/wx_core_feiyi", "misc/wx_herb_zizhi", "misc/wx_herb_xuelian",
			"misc/wx_mat_chiling", "misc/wx_mat_xuanlin", "misc/wx_mat_xiongjiao",
			"misc/wx_mat_shagu", "misc/wx_mat_renjin", "misc/wx_mat_gujing"
		])
		{
			stash.add(::new("scripts/items/" + wp));
		}

		local stdBanner = ::new("scripts/items/tools/player_banner");
		stdBanner.setVariant(this.World.Assets.getBannerID());
		stash.add(stdBanner);

		// Store all 268+ manuals & sample pages into 藏经阁 (zero Stash clutter!)
		local sampleManuals = [];
		foreach (id, def in ::Wuxia.Config.Manuals) sampleManuals.push(id);
		sampleManuals.sort();

		foreach (mid in sampleManuals)
		{
			::Wuxia.Library.addManual(mid, 1);
		}

		// Also keep 2 sample consumable manuals in Stash so right-click Stash learning can be tested immediately
		foreach (stMid in ["wx_manual_jianbu", "wx_manual_wuhudao"])
		{
			local mItem = ::new("scripts/items/misc/wx_manual_item");
			mItem.initManual(stMid);
			::Wuxia.markWithdrawnForSale(mItem);
			stash.add(mItem);
		}

		// Sample pages in 藏经阁: 3/3 exact craftable + 2/3 wildcard-craftable + two 1/3 spare sect pages + 3/5 secret page
		::Wuxia.Library.addPages("wx_manual_heifeng", 3);
		::Wuxia.Library.addPages("wx_manual_zixia_gong", 2);
		::Wuxia.Library.addPages("wx_manual_shuofang_jingua", 1);
		::Wuxia.Library.addPages("wx_manual_mobei_taoma_bian", 1);
		::Wuxia.Library.addPages("wx_manual_duanyue", 3);

		// Core & deepened alchemy pills
		local pillStocks = [
			{ ID = "wx_pill_jinchuang",   Qty = 3 },
			{ ID = "wx_pill_huxin",       Qty = 4 },
			{ ID = "wx_pill_ningshen",    Qty = 6 },
			{ ID = "wx_pill_xisui",       Qty = 3 },
			{ ID = "wx_pill_zijin_xisui", Qty = 2 },
			{ ID = "wx_pill_yijin_wan",   Qty = 2 },
			{ ID = "wx_pill_humai",       Qty = 3 },
			{ ID = "wx_pill_wangchen",    Qty = 2 },
			{ ID = "wx_pill_bihuo",       Qty = 2 },
			{ ID = "wx_pill_fengmo",      Qty = 2 }
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
