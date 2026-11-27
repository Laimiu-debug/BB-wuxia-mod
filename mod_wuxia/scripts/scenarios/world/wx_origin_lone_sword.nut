// Pure Wuxia Origin 2: 「孤剑独行 · 天涯浪客」
// Elite lone-swordsman start (inspired by Lone Wolf, adapted to 7-Slot Martial Cultivation).
// Fully randomized blind-box replayability (traits, root-bone stars, light/heavy sword gear & 4-slot manuals), tuned stronger for solo survival.

this.wx_origin_lone_sword <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},

	function create()
	{
		this.m.ID = "scenario.wx_origin_lone_sword";
		this.m.Name = "孤剑独行 · 天涯浪客";
		this.m.Description = "[p=c][img]gfx/ui/events/wx_ev_01.png[/img][/p][p]你曾是名山剑宗门下最惊才绝艳的异徒，携师门秘传独自踏入乱世江湖。或一袭轻裘快剑潇洒游斗，或横执重剑披甲破阵——你无需供养庞大冗兵，只择真正入眼的生死知己结伴同行。[/p][p][color=#bcad8c]• 开局阵容：1 名 5 级精锐剑客（高根骨随机特质，随配精良名剑甲胄与充裕盘缠丹药）\n• 师门绝艺：开局贯通四槽，随机身怀 1 门镇派绝学与 3 门上乘武学（其中两门已臻二重小成）\n• 精兵悟道：全队战后武学熟稔度获取 +25%，城池购置秘籍军械享 92 折优惠\n• 孤锋铁律：花名册上限硬锁 12 人，唯求个个皆为独当一面之高手[/color][/p]";
		this.m.Difficulty = 2;
		this.m.Order = 2;
	}

	function onInit()
	{
		if (this.World.Assets.m.BrothersMax > 12)
			this.World.Assets.m.BrothersMax = 12;
		if ("BuyPriceMult" in this.World.Assets.m)
			this.World.Assets.m.BuyPriceMult *= 0.92;
	}

	function WX_RollStartingTalents( _talents )
	{
		_talents.clear();
		_talents.resize(this.Const.Attributes.COUNT, 0);
		_talents[this.Const.Attributes.MeleeSkill] = (::Math.rand(1, 100) <= 55) ? 3 : 2;
		local candidates = [
			this.Const.Attributes.MeleeDefense,
			this.Const.Attributes.Initiative,
			this.Const.Attributes.Fatigue,
			this.Const.Attributes.Hitpoints,
			this.Const.Attributes.Bravery
		];
		for (local i = 0; i < 2; ++i)
		{
			local attr = candidates.remove(::Math.rand(0, candidates.len() - 1));
			_talents[attr] = (::Math.rand(1, 100) <= 45) ? 3 : 2;
		}
	}

	function WX_RollStartingTiers( _baseActives, _manuals )
	{
		// Try the six possible pairs so the sword and field supplies keep their native actions.
		local pairs = [[0, 1], [0, 2], [0, 3], [1, 2], [1, 3], [2, 3]];
		while (pairs.len() > 0)
		{
			local pair = pairs.remove(::Math.rand(0, pairs.len() - 1));
			local tiers = [1, 1, 1, 1];
			tiers[pair[0]] = 2;
			tiers[pair[1]] = 2;
			local actives = clone _baseActives;
			actives["actives.recover"] <- true; // Always granted by the internal manual
			foreach (i, mid in _manuals)
			{
				foreach (id in ::Wuxia.Slots.getManualDef(mid).Levels[tiers[i] - 1].GrantSkills)
					if (id.find("actives.") == 0) actives[id] <- true;
			}
			if (actives.len() <= 9) return tiers;
		}

		// A greatsword and field supplies can already fill five buttons. With a passive
		// fourth manual, these tiers grant at most one action per other manual plus Recover.
		_manuals[3] = "wx_manual_hanhai_guke";
		return [1, 1, 2, 2];
	}

	function onSpawnAssets()
	{
		local roster = this.World.getPlayerRoster();
		::Wuxia.Backgrounds.SuppressAutoAssign = true;
		try
		{
			local bro = roster.create("scripts/entity/tactical/player");
			local bgPool = [
				"swordmaster_background",
				"swordmaster_background",
				"adventurous_noble_background",
				"sellsword_background",
				"assassin_background"
			];
			local chosenBg = bgPool[::Math.rand(0, bgPool.len() - 1)];
			// Suppress negative trait rolls; roll 2 distinct positive martial traits below instead
			bro.setStartValuesEx([chosenBg], false);

			local usedNames = {};
			local usedManuals = {};
			::Wuxia.Backgrounds.rollUniqueActorName(bro, usedNames, "master");
			local loneTitles = ["天涯孤剑", "断水青锋", "孤鸿剑客", "寒江独钓", "折柳惊鸿", "松风弃徒", "仗剑浪子", "落雪惊鸿"];
			bro.setTitle(loneTitles[::Math.rand(0, loneTitles.len() - 1)]);
			bro.setPlaceInFormation(4);
			bro.m.HireTime = this.Time.getVirtualTimeF();

			// Roll 2 distinct positive combat traits from a curated Jianghu prodigy pool
			local traitPool = [
				"scripts/skills/traits/dexterous_trait",
				"scripts/skills/traits/sure_footing_trait",
				"scripts/skills/traits/iron_lungs_trait",
				"scripts/skills/traits/determined_trait",
				"scripts/skills/traits/quick_trait",
				"scripts/skills/traits/fearless_trait",
				"scripts/skills/traits/tough_trait",
				"scripts/skills/traits/strong_trait"
			];
			for (local tc = 0; tc < 2 && traitPool.len() > 0; tc = ++tc)
			{
				local tIdx = ::Math.rand(0, traitPool.len() - 1);
				local tPath = traitPool.remove(tIdx);
				bro.getSkills().add(::new(tPath));
			}

			// Keep appearance randomized, only preventing elderly white-haired default on young/prime outcast
			if ("Appearance" in ::Wuxia && "getOrInitState" in ::Wuxia.Appearance)
			{
				local app = ::Wuxia.Appearance.getOrInitState(bro);
				if (app != null && app.HairToneIdx >= 2)
					app.HairToneIdx = ::Math.rand(0, 1);
			}

			this.WX_RollStartingTalents(bro.m.Talents);
			bro.m.Attributes.clear();
			bro.fillAttributeLevelUpValues(this.Const.XP.MaxLevelWithPerkpoints - 1);

			// Randomized stronger base stats (patches swordmaster frailty while keeping natural roll variance + 4 LevelUps at Lv 5!)
			local b = bro.m.BaseProperties;
			if (chosenBg == "swordmaster_background")
			{
				b.Hitpoints  += ::Math.rand(12, 18);
				b.Stamina    += ::Math.rand(14, 20);
				b.Initiative += ::Math.rand(14, 20);
			}
			b.Hitpoints     = ::Math.max(64, b.Hitpoints + ::Math.rand(6, 12));
			b.Stamina       = ::Math.max(102, b.Stamina + ::Math.rand(6, 14));
			b.Bravery       = ::Math.max(50, b.Bravery + ::Math.rand(5, 12));
			b.Initiative    = ::Math.max(106, b.Initiative + ::Math.rand(6, 14));
			b.MeleeSkill    = ::Math.max(68, b.MeleeSkill + ::Math.rand(4, 8));
			b.MeleeDefense  = ::Math.max(15, b.MeleeDefense + ::Math.rand(4, 8));
			b.RangedDefense = ::Math.max(8, b.RangedDefense + ::Math.rand(3, 8));

			bro.m.Level = 5;
			bro.m.XP = this.Const.LevelXP[4];
			bro.m.LevelUps = 4;
			bro.m.PerkPoints = 0;

			// Randomized Equipment: 70% Agile Light-Armor Sword style (weight <= 15) vs 30% Heavy-Greatsword Vanguard style
			local items = bro.getItems();
			foreach (eqSlot in [
				this.Const.ItemSlot.Mainhand,
				this.Const.ItemSlot.Offhand,
				this.Const.ItemSlot.Body,
				this.Const.ItemSlot.Head,
				this.Const.ItemSlot.Accessory
			])
			{
				local prev = items.getItemAtSlot(eqSlot);
				if (prev != null) items.unequip(prev);
			}

			local isHeavyStyle = (::Math.rand(1, 100) <= 30);
			local mainSword = null;
			local bodyArmor = null;
			local headArmor = null;

			if (!isHeavyStyle)
			{
				local rollWpn = ::Math.rand(1, 100);
				local wpnScript = "scripts/items/weapons/noble_sword";
				if (rollWpn <= 18)
				{
					local famed1H = ["scripts/items/weapons/named/named_sword", "scripts/items/weapons/named/named_fencing_sword"];
					wpnScript = famed1H[::Math.rand(0, famed1H.len() - 1)];
				}
				else
				{
					local fine1H = [
						"scripts/items/weapons/noble_sword",
						"scripts/items/weapons/fencing_sword",
						"scripts/items/weapons/shamshir",
						"scripts/items/weapons/wx_beast_sword"
					];
					wpnScript = fine1H[::Math.rand(0, fine1H.len() - 1)];
				}
				mainSword = ::new(wpnScript);

				local lightBodies = [
					"scripts/items/armor/padded_leather",
					"scripts/items/armor/leather_lamellar",
					"scripts/items/armor/mail_shirt",
					"scripts/items/armor/wx_beast_armor_light"
				];
				local lightHeads = [
					"scripts/items/helmets/hunters_hat",
					"scripts/items/helmets/feathered_hat",
					"scripts/items/helmets/wx_beast_helm_light"
				];
				bodyArmor = ::new(lightBodies[::Math.rand(0, lightBodies.len() - 1)]);
				headArmor = ::new(lightHeads[::Math.rand(0, lightHeads.len() - 1)]);

				// If a beast-crafted piece was rolled, give it a randomized良工/百炼 roll
				if ("Forge" in ::Wuxia && "rollNewSeed" in ::Wuxia.Forge && "applySeedToItem" in ::Wuxia.Forge)
				{
					if (mainSword.getID() == "weapon.wx_beast_sword")
						::Wuxia.Forge.applySeedToItem(mainSword, ::Wuxia.Forge.rollNewSeed(false, 1), false);
					if (bodyArmor.getID() == "armor.body.wx_beast_armor_light")
						::Wuxia.Forge.applySeedToItem(bodyArmor, ::Wuxia.Forge.rollNewSeed(false, 1), false);
					if (headArmor.getID() == "armor.head.wx_beast_helm_light")
						::Wuxia.Forge.applySeedToItem(headArmor, ::Wuxia.Forge.rollNewSeed(false, 1), false);
				}

				// Ensure light-style head + body total weight stays <= 15 so LightArmorMitigation manuals work at full strength
				if (-(bodyArmor.getStaminaModifier() + headArmor.getStaminaModifier()) > 15)
					headArmor = ::new("scripts/items/helmets/hunters_hat");
			}
			else
			{
				local rollWpn2H = ::Math.rand(1, 100);
				local wpnScript2H = "scripts/items/weapons/longsword";
				if (rollWpn2H <= 18)
				{
					wpnScript2H = "scripts/items/weapons/named/named_greatsword";
				}
				else
				{
					local fine2H = [
						"scripts/items/weapons/longsword",
						"scripts/items/weapons/greatsword",
						"scripts/items/weapons/warbrand"
					];
					wpnScript2H = fine2H[::Math.rand(0, fine2H.len() - 1)];
				}
				mainSword = ::new(wpnScript2H);

				local medBodies = [
					"scripts/items/armor/mail_hauberk",
					"scripts/items/armor/wx_beast_armor_med"
				];
				local medHeads = [
					"scripts/items/helmets/kettle_hat",
					"scripts/items/helmets/padded_kettle_hat",
					"scripts/items/helmets/wx_beast_helm_heavy"
				];
				bodyArmor = ::new(medBodies[::Math.rand(0, medBodies.len() - 1)]);
				headArmor = ::new(medHeads[::Math.rand(0, medHeads.len() - 1)]);

				if ("Forge" in ::Wuxia && "rollNewSeed" in ::Wuxia.Forge && "applySeedToItem" in ::Wuxia.Forge)
				{
					if (bodyArmor.getID() == "armor.body.wx_beast_armor_med")
						::Wuxia.Forge.applySeedToItem(bodyArmor, ::Wuxia.Forge.rollNewSeed(false, 1), false);
					if (headArmor.getID() == "armor.head.wx_beast_helm_heavy")
						::Wuxia.Forge.applySeedToItem(headArmor, ::Wuxia.Forge.rollNewSeed(false, 1), false);
				}
			}

			items.equip(mainSword);
			items.equip(bodyArmor);
			items.equip(headArmor);
			local accPool = ["scripts/items/accessory/bandage_item", "scripts/items/accessory/antidote_item"];
			items.equip(::new(accPool[::Math.rand(0, accPool.len() - 1)]));

			// Randomized 4-Slot Martial Loadout:
			//   - Pick 1 random slot among Neigong / Sword Waigong / Qinggong to upgrade to a random Secret (绝学) manual!
			//   - Remaining 3 slots draw random Sect (门派上乘) manuals matching weapon & armor style.
			//   - 2 random slots start at Tier 2 (二重·小成), 2 slots start at Tier 1 with partial mastery XP!
			local secretSlot = ::Math.rand(0, 2);
			local neiID  = ::Wuxia.Backgrounds.pickCatalogManual("neigong",  secretSlot == 0 ? "secret" : "sect", null, usedManuals, "wx_manual_songtao");
			local waiID  = ::Wuxia.Backgrounds.pickCatalogManual("waigong",  secretSlot == 1 ? "secret" : "sect", mainSword, usedManuals, "wx_manual_qingfeng");
			local qingID = ::Wuxia.Backgrounds.pickCatalogManual("qinggong", secretSlot == 2 ? "secret" : "sect", null, usedManuals, "wx_manual_taxue");

			local hengCandidates = isHeavyStyle
				? ["wx_manual_tiebushan", "wx_manual_hengshan_tiebi", "wx_manual_shaolin_tongren", "wx_manual_hanhai_guke", "wx_manual_xinglin_jinshen", "wx_manual_zhongzhou_wuzong"]
				: ["wx_manual_jinchan", "wx_manual_taihe_mianjin", "wx_manual_gufeng", "wx_manual_kuaiji_duanjian", "wx_manual_hanhai_guke", "wx_manual_xinglin_jinshen", "wx_manual_zhongzhou_wuzong"];
			local validHeng = [];
			foreach (hid in hengCandidates)
			{
				if ((hid in ::Wuxia.Config.Manuals) && !(hid in usedManuals))
					validHeng.push(hid);
			}
			local hengID = (validHeng.len() > 0)
				? validHeng[::Math.rand(0, validHeng.len() - 1)]
				: ::Wuxia.Backgrounds.pickCatalogManual("henglian", "sect", mainSword, usedManuals, isHeavyStyle ? "wx_manual_tiebushan" : "wx_manual_jinchan");
			local slotManuals = [neiID, waiID, qingID, hengID];
			bro.getSkills().update();
			local nativeActives = {};
			foreach (skill in bro.getSkills().queryActives()) nativeActives[skill.getID()] <- true;
			local tierMap = this.WX_RollStartingTiers(nativeActives, slotManuals);
			usedManuals[slotManuals[3]] <- true;

			local c = ::Wuxia.Slots.getContainer(bro);
			local noteParts = [];
			for (local si = 0; si < 4; si = ++si)
			{
				local mid = slotManuals[si];
				local tr = tierMap[si];
				::Wuxia.Slots.equipManual(bro, si, mid, false);
				if (c != null && si < c.m.Slots.len() && c.m.Slots[si].ManualID == mid)
				{
					c.m.Slots[si].Tier = tr;
					c.m.Slots[si].Exp  = (tr >= 2) ? ::Math.rand(20, 60) : ::Math.rand(45, 95);
					c.syncSlotToLearned(si);
				}
				local mDef = ::Wuxia.Slots.getManualDef(mid);
				if (mDef != null)
					noteParts.push((tr >= 2 ? "二重" : "一重") + "《" + mDef.Name + "》");
			}

			// Also roll 1 random unequipped spare manual in personal LearnedManuals pool
			local spareCat = (::Math.rand(1, 100) <= 50) ? "waigong" : "henglian";
			local extraLearnID = ::Wuxia.Backgrounds.pickCatalogManual(spareCat, "sect", mainSword, usedManuals, "wx_manual_gufeng");
			if (extraLearnID != null)
				::Wuxia.Slots.learnManual(bro, extraLearnID, false);

			if (c != null)
				c.syncGrantedSkills();

			local bg = bro.getBackground();
			if (bg != null && ::Wuxia.hasMember(bg, "WX_FormatDescription") && noteParts.len() > 0)
			{
				local joined = "";
				for (local ni = 0; ni < noteParts.len(); ni = ++ni)
				{
					if (ni > 0) joined += "、";
					joined += noteParts[ni];
				}
				bg.m.WX_StarterManualNames <- [];
				bg.m.WX_SavedStarterSuffix <- "\n\n[color=#8f6b29]【随身武学】出山即修有" + joined + "。[/color]";
				bg.m.Description = bg.WX_FormatDescription(bg.m.Description);
			}

			if ("Appearance" in ::Wuxia && "refreshActorSprites" in ::Wuxia.Appearance)
				::Wuxia.Appearance.refreshActorSprites(bro);
			if ("Armory" in ::Wuxia && "syncActorHandheldAndArmor" in ::Wuxia.Armory)
				::Wuxia.Armory.syncActorHandheldAndArmor(bro);
			bro.getSkills().update();
			bro.m.Hitpoints = bro.getHitpointsMax();
		}
		catch (err)
		{
			::Wuxia.Backgrounds.SuppressAutoAssign = false;
			throw err;
		}
		::Wuxia.Backgrounds.SuppressAutoAssign = false;

		local stash = this.World.Assets.getStash();
		local pillIds = ["wx_pill_jinchuang", "wx_pill_huxin", "wx_pill_ningshen"];
		local bonusPillPool = ["wx_pill_jinchuang", "wx_pill_huxin", "wx_pill_ningshen", "wx_pill_wangchen", "wx_pill_longhu", "wx_pill_yuji"];
		for (local bp = 0; bp < 2; bp = ++bp)
			pillIds.push(bonusPillPool[::Math.rand(0, bonusPillPool.len() - 1)]);

		foreach (pid in pillIds)
		{
			if (pid in ::Wuxia.Config.Pills)
			{
				local pill = ::new("scripts/items/misc/wx_pill_item");
				pill.initPill(pid);
				stash.add(pill);
			}
		}

		this.World.Assets.m.Money = ::Math.rand(21, 25) * 100;
		this.World.Assets.m.ArmorParts = 25;
		this.World.Assets.m.Medicine = 12;
		this.World.Assets.addBusinessReputation(220);

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
