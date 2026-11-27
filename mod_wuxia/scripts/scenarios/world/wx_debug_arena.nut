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

		// Equip test heroes with starter & showcase kinetic manuals so all 5 next-gen VFX skills can be tested immediately!
		local brothers = roster.getAll();
		local setSlotTier = function( _bro, _slotIdx, _manualID, _tier )
		{
			::Wuxia.Slots.equipManual(_bro, _slotIdx, _manualID, false);
			local c = ::Wuxia.Slots.getContainer(_bro);
			if (c != null && _slotIdx < c.m.Slots.len() && c.m.Slots[_slotIdx].ManualID == _manualID)
			{
				c.m.Slots[_slotIdx].Tier = _tier;
				c.m.Slots[_slotIdx].Exp = 999;
				c.syncGrantedSkills();
				_bro.getSkills().update();
			}
		};
		local equipMainWeapon = function( _bro, _scriptPath )
		{
			local items = _bro.getItems();
			if (items == null) return;
			local curM = items.getItemAtSlot(::Const.ItemSlot.Mainhand);
			if (curM != null) items.unequip(curM);
			local curO = items.getItemAtSlot(::Const.ItemSlot.Offhand);
			if (curO != null) items.unequip(curO);
			items.equip(::new(_scriptPath));
		};

		if (brothers.len() > 0)
		{
			// 沈清风 (Lv 11): 清风连环剑 + 天外一剑 (太阿剑)
			equipMainWeapon(brothers[0], "scripts/items/weapons/named/wx_relic_taie");
			setSlotTier(brothers[0], 0, "wx_manual_guiyuan", 3);
			setSlotTier(brothers[0], 1, "wx_manual_qingfeng", 3);
			setSlotTier(brothers[0], 4, "wx_manual_tianwai", 3);
			::Wuxia.Slots.learnManual(brothers[0], "wx_manual_taxue", false);
			::Wuxia.Slots.learnManual(brothers[0], "wx_manual_jinchan", false);
			::Wuxia.Slots.learnManual(brothers[0], "wx_manual_huifeng", false);
		}
		if (brothers.len() > 1)
		{
			// 雷震山 (Lv 9): 燃木烈阳劈 (陌刀主手) + 雷霆碎岳锤 (瓮金锤副袋可切换)
			equipMainWeapon(brothers[1], "scripts/items/weapons/named/wx_relic_modao");
			brothers[1].getItems().addToBag(::new("scripts/items/weapons/named/wx_relic_wengjinchui"));
			setSlotTier(brothers[1], 0, "wx_manual_guiyuan", 2);
			setSlotTier(brothers[1], 1, "wx_manual_shaolin_jiedao", 3);
			setSlotTier(brothers[1], 4, "wx_manual_jiuyao_pocheng", 2);
		}
		if (brothers.len() > 2)
		{
			// 柳青衣 (Lv 5): 亢龙有悔掌 (成对拳套)
			equipMainWeapon(brothers[2], "scripts/items/weapons/named/wx_named_fist");
			setSlotTier(brothers[2], 0, "wx_manual_guiyuan", 2);
			setSlotTier(brothers[2], 1, "wx_manual_gaibang_xianglong", 3);
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
