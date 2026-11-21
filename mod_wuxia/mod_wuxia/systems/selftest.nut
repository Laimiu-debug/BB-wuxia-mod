// Automated In-Engine Self-Test Suite for mod_wuxia
// Checks skill, item and origin initialization and martial stat aggregation in the game VM.

::Wuxia.SelfTest <- {};

::Wuxia.SelfTest.runAll <- function()
{
	local passed = 0;
	local failed = 0;

	local check = function( _label, _fn )
	{
		try
		{
			_fn();
			passed += 1;
			::logInfo("[WX-SELFTEST] PASS: " + _label);
		}
		catch (err)
		{
			failed += 1;
			::logError("[WX-SELFTEST] FAIL: " + _label + " -> " + err);
		}
	};

	::logInfo("[WX-SELFTEST] ================= Starting In-Engine Self-Test =================");

	// 1. Instantiate all active skills + special container
	local skillScripts = [
		"scripts/skills/special/wx_martial_container",
		"scripts/skills/actives/wx_meditate",
		"scripts/skills/actives/wx_sword_combo",
		"scripts/skills/actives/wx_sword_counter",
		"scripts/skills/actives/wx_sword_tianwai",
		"scripts/skills/actives/wx_saber_cleave",
		"scripts/skills/actives/wx_saber_duanyue",
		"scripts/skills/actives/wx_spear_guard",
		"scripts/skills/actives/wx_throwing_rain",
		"scripts/skills/actives/wx_blood_burst",
		"scripts/skills/actives/wx_staff_challenge",
		"scripts/skills/actives/wx_rally_command",
		"scripts/skills/actives/wx_fist_jab",
		"scripts/skills/actives/wx_fist_shock",
		"scripts/skills/actives/wx_fist_jingang",
		"scripts/skills/actives/wx_fist_acupoint",
		"scripts/skills/actives/wx_fist_disarm",
		"scripts/skills/actives/wx_hammer_shatter",
		"scripts/skills/actives/wx_hammer_quake",
		"scripts/skills/actives/wx_axe_split",
		"scripts/skills/actives/wx_axe_whirl",
		"scripts/skills/actives/wx_flail_lash",
		"scripts/skills/actives/wx_flail_entangle",
		"scripts/skills/actives/wx_dagger_vital",
		"scripts/skills/actives/wx_dagger_execute",
		"scripts/skills/actives/wx_sword_pierce",
		"scripts/skills/actives/wx_saber_sweep",
		"scripts/skills/actives/wx_spear_thrust2",
		"scripts/skills/actives/wx_pole_sweep",
		"scripts/skills/actives/wx_fist_grapple",
		"scripts/skills/actives/wx_bow_snipe",
		"scripts/skills/actives/wx_throw_fan",
		"scripts/skills/actives/wx_shield_bash_qi",
		"scripts/skills/actives/wx_tactics_jinzhen",
		"scripts/skills/actives/wx_tactics_shihou",
		"scripts/skills/actives/wx_neigong_xixing",
		"scripts/skills/actives/wx_neigong_jinzhong",
		"scripts/skills/actives/wx_qinggong_zongyue",
		"scripts/skills/actives/wx_qinggong_lingbo",
		"scripts/skills/actives/wx_shield_tiebi",
		"scripts/skills/actives/wx_throw_duzhen",
		"scripts/skills/actives/wx_throw_pilidan",
		"scripts/skills/actives/wx_crossbow_shenji",
		"scripts/skills/actives/wx_bow_liuxing",
		"scripts/skills/actives/wx_dagger_fuxue",
		"scripts/skills/actives/wx_whip_suohou",
		"scripts/skills/actives/wx_axe_kaishan",
		"scripts/skills/actives/wx_hammer_leiting",
		"scripts/skills/actives/wx_fist_taiji",
		"scripts/skills/actives/wx_fist_qishang",
		"scripts/skills/actives/wx_fist_jiuyin",
		"scripts/skills/actives/wx_fist_yiyang",
		"scripts/skills/actives/wx_fist_xuanming",
		"scripts/skills/actives/wx_fist_xianglong",
		"scripts/skills/actives/wx_staff_dagou",
		"scripts/skills/actives/wx_pole_goulian",
		"scripts/skills/actives/wx_pole_fangtian",
		"scripts/skills/actives/wx_spear_bawang",
		"scripts/skills/actives/wx_spear_liuhua",
		"scripts/skills/actives/wx_saber_modao",
		"scripts/skills/actives/wx_saber_fanzhen",
		"scripts/skills/actives/wx_saber_xuehai",
		"scripts/skills/actives/wx_saber_ranmu",
		"scripts/skills/actives/wx_saber_kuangfeng",
		"scripts/skills/actives/wx_sword_dugu",
		"scripts/skills/actives/wx_sword_feixian",
		"scripts/skills/actives/wx_sword_taiji",
		"scripts/skills/actives/wx_sword_cuixin",
		"scripts/skills/actives/wx_sword_duoming",
		"scripts/skills/actives/wx_sword_zhongjian"
	];

	foreach (sp in skillScripts)
	{
		local path = sp;
		check("Instantiate skill " + path, function() {
			local sk = ::new(path);
			if (sk.getID() == "") throw "Empty skill ID";
		});
	}

	// 2. Instantiate all 9 status effects & verify onUpdate(_properties)
	local effectScripts = [
		"scripts/skills/effects/wx_scatter_weakness",
		"scripts/skills/effects/wx_internal_injury",
		"scripts/skills/effects/wx_status_opening",
		"scripts/skills/effects/wx_status_offbalance",
		"scripts/skills/effects/wx_status_acupoint",
		"scripts/skills/effects/wx_status_counter_stance",
		"scripts/skills/effects/wx_status_poise_charge",
		"scripts/skills/effects/wx_status_poison_dart",
		"scripts/skills/effects/wx_status_smoke_screen"
	];

	foreach (ep in effectScripts)
	{
		local path = ep;
		check("Instantiate & onUpdate effect " + path, function() {
			local ef = ::new(path);
			local props = ::Const.CharacterProperties.getClone();
			if (::Wuxia.hasMember(ef, "onUpdate")) ef.onUpdate(props);
			if (::Wuxia.hasMember(ef, "getTooltip")) ef.getTooltip();
		});
	}

	// 3. Instantiate all 3 item classes & test all 250+ manuals + AGENTS.md caps + 5 pills
	check("Manual catalog: 250+ manuals, unique names, KnownFlags & AGENTS.md redlines", function() {
		local minimum = { common = 50, sect = 90, secret = 50, unique = 15 };
		local counts = { common = 0, sect = 0, secret = 0, unique = 0 };
		local totalManuals = 0;
		local seenNames = {};
		local grants = {};
		local stamCap = { common = 15, sect = 25, secret = 35, unique = 40 };
		local initCap = { common = 12, sect = 18, secret = 24, unique = 30 };
		local props = ::Const.CharacterProperties.getClone();
		local c = ::new("scripts/skills/special/wx_martial_container");
		foreach (mid, def in ::Wuxia.Config.Manuals)
		{
			totalManuals += 1;
			if (mid != def.ID || def.Levels.len() != ::Wuxia.Config.Constants.MaxManualTier) throw mid;
			if (def.Name in seenNames) throw "Duplicate manual Name: " + def.Name + " (" + mid + ")";
			seenNames[def.Name] <- mid;
			counts[def.Quality] += 1;
			foreach (level in def.Levels)
			{
				foreach (stat, value in level.Stats)
					if (!(stat in props)) throw "Unknown stat: " + stat + " in " + mid;
				foreach (fk, _ in level.Flags)
					if (!(fk in ::Wuxia.CombatRules.KnownFlags)) throw "Unknown flag: " + fk + " in " + mid;
				foreach (id in level.GrantSkills) grants[id] <- true;

				if (def.Category == "neigong")
				{
					if (("MeleeSkill" in level.Stats) || ("MeleeDefense" in level.Stats) || ("RangedSkill" in level.Stats))
						throw "Neigong combat stat forbidden in " + mid;
					if (("Stamina" in level.Stats) && level.Stats.Stamina > stamCap[def.Quality])
						throw "Neigong stamina cap exceeded in " + mid;
					if (("FatigueRecoveryRate" in level.Stats) && level.Stats.FatigueRecoveryRate > 6)
						throw "Neigong recovery cap exceeded in " + mid;
				}
				else if (def.Category == "qinggong")
				{
					if (("Initiative" in level.Stats) && level.Stats.Initiative > initCap[def.Quality])
						throw "Qinggong Init cap exceeded in " + mid;
					if (("InitToDefRatio" in level.Flags) && level.Flags.InitToDefRatio > (def.Quality == "unique" ? 0.201 : 0.181))
						throw "Qinggong InitToDefRatio exceeded in " + mid;
				}
				else if (def.Category == "henglian")
				{
					if (("Hitpoints" in level.Stats) && level.Stats.Hitpoints > 20)
						throw "Henglian HP cap exceeded in " + mid;
				}
				if (("PermanentAPBonus" in level.Flags) && level.Flags.PermanentAPBonus > 1)
					throw "PermanentAPBonus > 1 in " + mid;
			}
			local mItem = ::new("scripts/items/misc/wx_manual_item");
			mItem.initManual(mid);
			local tt = mItem.getTooltip();
			if (tt.len() < 3) throw "Tooltip too short for " + mid;

			if (def.FragmentsNeeded > 0)
			{
				local pItem = ::new("scripts/items/misc/wx_page_item");
				pItem.initPages(mid, 2);
				pItem.getTooltip();
			}
		}
		if (totalManuals < 250) throw "Expected >= 250 manuals, got " + totalManuals;
		foreach (quality, count in minimum)
			if (counts[quality] < count) throw "Insufficient manuals for " + quality + ": " + counts[quality];
		foreach (id, _ in grants)
		{
			local path = c.resolveSkillScriptPath(id);
			if (path == null || ::new(path).getID() != id) throw "Unresolvable skill: " + id;
		}
		::logInfo("[WX-SELFTEST] Verified " + totalManuals + " total manuals (common=" + counts.common + ", sect=" + counts.sect + ", secret=" + counts.secret + ", unique=" + counts.unique + ")");
	});

	check("Instantiate & validate all 5 pills via wx_pill_item", function() {
		foreach (pid, pdef in ::Wuxia.Config.Pills)
		{
			local pill = ::new("scripts/items/misc/wx_pill_item");
			pill.initPill(pid);
			pill.getTooltip();
		}
	});

	// 4. Instantiate scenarios, blueprints and endgame tournament event
	local scenarioScripts = [
		"scripts/scenarios/world/wx_debug_arena",
		"scripts/scenarios/world/wx_jianghu_start",
		"scripts/scenarios/world/wx_origin_lone_sword",
		"scripts/scenarios/world/wx_origin_shaolin_monks",
		"scripts/scenarios/world/wx_origin_wudu_healer",
		"scripts/scenarios/world/wx_origin_frontier_veterans"
	];
	foreach (scp in scenarioScripts)
	{
		local path = scp;
		check("Instantiate scenario " + path, function() {
			local sc = ::new(path);
			if (sc.m.ID == "" || sc.m.ID.find("scenario.wx_") != 0) throw "Invalid Wuxia scenario ID: " + sc.m.ID;
		});
	}

	check("Vanilla item & currency purification (纹银 / 修械铁料 / 干粮)", function() {
		local money = ::new("scripts/items/supplies/money_item");
		local tools = ::new("scripts/items/supplies/armor_parts_item");
		local bread = ::new("scripts/items/supplies/bread_item");
		if (money.getName() != "官铸足色纹银") throw "Money name not purified: " + money.getName();
		if (tools.getName() != "百炼修械铁料箱") throw "Tools name not purified: " + tools.getName();
		if (bread.getName() != "潼关千层焦香锅盔") throw "Bread name not purified: " + bread.getName();
		local replaced = ::Wuxia.Purify.rewriteCurrencyAndSupplyTerms("价值 250 克朗，消耗维修工具修复佣兵团护甲");
		if (replaced.find("克朗") != null || replaced.find("维修工具") != null || replaced.find("佣兵团") != null)
			throw "Currency/supply term rewrite failed: " + replaced;
	});

	check("Alchemy blueprints, beast trophy remapping and grand tournament event", function() {
		foreach (bp in ["wx_xisui_blueprint", "wx_ningshen_blueprint", "wx_humai_blueprint"])
		{
			local b = ::new("scripts/crafting/blueprints/" + bp);
			if (b.getID() == "") throw "Empty blueprint ID: " + bp;
		}
		local heart = ::new("scripts/items/misc/unhold_heart_item");
		local brain = ::new("scripts/items/misc/ghoul_brain_item");
		if (heart.getID() != "misc.unhold_heart" || heart.getName() != "朱厌心头赤血核") throw "Unhold heart Shan Hai remap failed: " + heart.getName();
		if (brain.getID() != "misc.ghoul_brain" || brain.getName() != "狍鸮颅内髓珠") throw "Ghoul brain Shan Hai remap failed: " + brain.getName();

		local ev = ::new("scripts/events/events/wx_event_grand_tournament");
		if (ev.getID() != "event.wx_grand_tournament" || ev.m.Screens.len() < 4) throw "Tournament event invalid";
	});

	// 5. Check the seven slots, manual stat bonuses and combat flags
	check("7-slot container: manual stats and aggregate combat flags", function() {
		local c = ::new("scripts/skills/special/wx_martial_container");
		if (c.m.Slots.len() != 7) throw "Expected 7 slots";

		// Taixu and Lingbo each grant +1 permanent AP at tier 3.
		c.m.Slots[0].ManualID = "wx_manual_taixu";
		c.m.Slots[0].Tier = 3;
		c.m.Slots[2].ManualID = "wx_manual_lingbo";
		c.m.Slots[2].Tier = 3;
		c.m.Slots[3].ManualID = "wx_manual_jinchan";
		c.m.Slots[3].Tier = 3;

		local agg = ::Wuxia.CombatRules.getAggregateFlags(c);
		if (agg.PermanentAPBonus != 2) throw "Expected +2 AP bonus, got " + agg.PermanentAPBonus;
		if (agg.QiShieldPct != 0.35) throw "Expected 35% QiShield, got " + agg.QiShieldPct;
		if (agg.LightArmorMitigation != 0.55) throw "Expected 55% LightArmorMitigation";

		local props = ::Const.CharacterProperties.getClone();
		local baseStamina = props.Stamina;
		c.onUpdate(props);
		local expectedStamina = baseStamina + ::Wuxia.Config.Manuals.wx_manual_taixu.Levels[2].Stats.Stamina;
		if (props.Stamina != expectedStamina) throw "Expected stamina " + expectedStamina + ", got " + props.Stamina;
	});

	check("Full stash: refuse without spending pages; replace an exhausted stack", function() {
		local stash = ::new("scripts/items/stash_container");
		stash.setResizable(false);
		stash.resize(1);
		local pages = ::new("scripts/items/misc/wx_page_item");
		pages.initPages("wx_manual_heifeng", 4);
		stash.add(pages);
		if (::Wuxia.Slots.craftManualFromStash(stash, pages.getManualID()).Ok || pages.getPageCount() != 4)
			throw "Spent pages without room for the manual";
		stash.resize(2);
		local one = ::new("scripts/items/misc/wx_page_item");
		one.initPages(pages.getManualID(), 1);
		stash.add(one);
		if (!::Wuxia.Slots.craftManualFromStash(stash, pages.getManualID()).Ok || pages.getPageCount() != 2)
			throw "Did not consume exactly three pages";
		if (stash.getItemByID("misc.wx_manual_item") == null || stash.getNumberOfFilledSlots() != 2)
			throw "Missing crafted manual";
	});

	check("Enemy and sect tables resolve; only equipped books can drop", function() {
		foreach (id, sect in ::Wuxia.Config.Sects)
			foreach (offer in sect.ShopManuals)
				if (!(offer.ManualID in ::Wuxia.Config.Manuals)) throw "Unknown sect offer: " + id;
		foreach (id, profile in ::Wuxia.Loot.EnemyLoadouts)
			foreach (entry in profile.Manuals)
				if (!(entry.ManualID in ::Wuxia.Config.Manuals) || entry.Weight <= 0 || entry.Tier < 1 || entry.Tier > 3)
					throw "Invalid enemy loadout: " + id;
		local c = ::new("scripts/skills/special/wx_martial_container");
		local actor = { function getSkills() { return this; }, function getSkillByID( _id ) { return c; } };
		c.m.Slots[0].ManualID = "wx_manual_tuna";
		c.m.Slots[0].Tier = 1;
		local pool = ::Wuxia.Loot.getEquippedDropPool(actor, ::Wuxia.Loot.EnemyLoadouts.bandit_thug);
		if (pool.len() != 1 || ::Wuxia.Loot.pickWeightedManual(pool) != "wx_manual_tuna") throw "Unworn manual in drop pool";
	});

	check("Marrow wash keeps pending rolls, other attributes and queue size", function() {
		local actor = {
			m = { Attributes = [[99, 0, 0], [7, 8, 9]], Talents = [3, 0], LevelUps = 1 },
			function getLevel() { return 3; }
		};
		::Wuxia.MarrowWash.refreshFutureRolls(actor, 0);
		local rolls = actor.m.Attributes[0];
		local range = ::Const.AttributesLevelUp[0];
		if (rolls.len() != 3 || rolls[0] != 99 || actor.m.Attributes[1][1] != 8) throw "Existing rolls changed";
		for (local i = 1; i < rolls.len(); ++i)
			if (rolls[i] < range.Min + 2 || rolls[i] > range.Max + 1) throw "Wrong star range";
	});

	check("Weapon swap: sword and cleaver passives follow the main hand", function() {
		local held = ::new("scripts/items/weapons/arming_sword");
		local actor = { function getItems() { return this; }, function getItemAtSlot( _slot ) { return held; } };
		local skills = { function getActor() { return actor; } };
		local equipped = {
			m = { Slots = [
				{ ManualID = "wx_manual_qingfeng", Tier = 2, IsFragment = false },
				{ ManualID = "wx_manual_wuhudao", Tier = 3, IsFragment = false }
			] },
			function getContainer() { return skills; }
		};
		local sword = ::Wuxia.CombatRules.getAggregateFlags(equipped);
		if (sword.Stats.MeleeSkill != 3 || sword.InflictOpeningPct != 45 || sword.DirectDmgBonus != 0.08 || sword.WeaponQiDiscount != 0.0)
			throw "Wrong sword bonuses";
		held = ::new("scripts/items/weapons/military_cleaver");
		local cleaver = ::Wuxia.CombatRules.getAggregateFlags(equipped);
		if (cleaver.InflictOpeningPct != null || cleaver.DirectDmgBonus != 0.0 || cleaver.WeaponQiDiscount != 0.15)
			throw "Wrong cleaver bonuses";
		held = null;
		if (::Wuxia.CombatRules.getAggregateFlags(equipped).Stats.len() != 0) throw "Weapon bonuses while unarmed";
	});

	check("Auxiliary internal training and preserved legacy third manual", function() {
		local c = ::new("scripts/skills/special/wx_martial_container");
		foreach (i, mid in { [0] = "wx_manual_tuna", [5] = "wx_manual_songtao", [6] = "wx_manual_taixu" })
		{
			c.m.Slots[i].ManualID = mid;
			c.m.Slots[i].Tier = 3;
		}
		local f = ::Wuxia.CombatRules.getAggregateFlags(c);
		if (f.Stats.Stamina != 27 || f.Stats.FatigueRecoveryRate != 4 || !f.AntiInternalInjury || f.PermanentAPBonus != 0)
			throw "Incorrect auxiliary or dormant bonuses";
		c.m.Slots[5].ManualID = null;
		if (::Wuxia.CombatRules.getAggregateFlags(c).PermanentAPBonus != 1 || c.m.Slots[6].Tier != 3)
			throw "Dormant manual did not reactivate";
	});
	check("Encounter profiles, school rosters and named rewards", function() {
		foreach (id, school in ::Wuxia.Config.Sects)
			if (!(school.VendettaParty in ::Wuxia.Config.Vendettas)) throw id;
		foreach (id, fighter in ::Wuxia.Config.Fighters)
		{
			if (!(fighter.BaseTroop in ::Const.World.Spawn.Troops)) throw id;
			foreach (entry in fighter.Manuals)
				if (entry.Tier < 1 || entry.Tier > 3 || ::Wuxia.Slots.getManualDef(entry.ManualID) == null) throw id;
		}
		foreach (specs in [::Wuxia.Config.Vendettas, ::Wuxia.Config.Strongholds])
			foreach (key, spec in specs)
			{
				if ("RewardManual" in spec && spec.RewardManual != null && ::Wuxia.Slots.getManualDef(spec.RewardManual) == null)
					throw "Invalid RewardManual in " + key;
				if ("ExtraManual" in spec && spec.ExtraManual != null && ::Wuxia.Slots.getManualDef(spec.ExtraManual) == null)
					throw "Invalid ExtraManual in " + key;
				foreach (role in spec.Troops)
					if (!(role in ::Wuxia.Config.Fighters) && !(role in ::Wuxia.Config.ShanHaiBosses) && !(role in ::Const.World.Spawn.Troops))
						throw "Unresolvable encounter troop: " + role + " in " + key;
			}
	});
	check("Weapon families and per-quality martial stat budgets", function() {
		local weapons = {
			short_bow = "Bow", crossbow = "Crossbow",
			wooden_stick = "Staff", goedendag = "Staff", bludgeon = "Staff",
			wx_fist_wraps = "Fist", wx_fist_iron = "Fist", wx_fist_heavy = "Fist",
			warhammer = "Hammer", military_pick = "Hammer",
			hand_axe = "Axe", greataxe = "Axe",
			flail = "Flail", battle_whip = "Flail",
			rondel_dagger = "Dagger", ["oriental/qatal_dagger"] = "Dagger",
			["oriental/handgonne"] = "Firearm"
		};
		foreach (id, family in weapons)
		{
			local w = ::new("scripts/items/weapons/" + id);
			foreach (test in ["Bow", "Crossbow", "Staff", "Fist", "Hammer", "Axe", "Flail", "Dagger", "Firearm"])
				if (::Wuxia.CombatRules.matchesWeapon(w, [test]) != (test == family)) throw id + " " + test;
		}
		local namedFist = ::new("scripts/items/weapons/named/wx_named_fist");
		if (!::Wuxia.CombatRules.matchesWeapon(namedFist, ["Fist"]) || namedFist.getBlockedSlotType() != ::Const.ItemSlot.Offhand || namedFist.m.Icon == "" || namedFist.m.Name.find("·") == null)
			throw "Invalid wx_named_fist initialization";
		local attack = { common = 3, sect = 5, secret = 7, unique = 10 };
		local defense = { common = 2, sect = 3, secret = 5, unique = 6 };
		foreach (id, def in ::Wuxia.Config.Manuals)
		{
			if (def.Category != "waigong") continue;
			foreach (lv in def.Levels)
			{
				foreach (k in ["MeleeSkill", "RangedSkill"]) if (k in lv.Stats && lv.Stats[k] > attack[def.Quality]) throw id + " " + k;
				foreach (k in ["MeleeDefense", "RangedDefense"]) if (k in lv.Stats && lv.Stats[k] > defense[def.Quality]) throw id + " " + k;
				foreach (k in ["DirectDmgBonus", "ArmorPenBonus"]) if (k in lv.Flags && lv.Flags[k] > (def.Quality == "unique" ? 0.20 : 0.15)) throw id + " " + k;
				if ("ArmorDmgBonus" in lv.Flags && lv.Flags.ArmorDmgBonus > 0.25) throw id + " armor";
			}
		}
	});

	check("Tactical manuals: Gufeng 25% cap, paired-fist offhand block and Chanzi adaptation", function() {
		local heldMain = ::new("scripts/items/weapons/arming_sword");
		local heldOff = null;
		local items = {
			function getItemAtSlot( _s ) { return _s == ::Const.ItemSlot.Mainhand ? heldMain : (_s == ::Const.ItemSlot.Offhand ? heldOff : null); },
			function hasBlockedSlot( _s ) { return heldMain != null && heldMain.getBlockedSlotType() == _s; }
		};
		local actor = { function getItems() { return items; }, function getInitiative() { return 100; } };
		local c = ::new("scripts/skills/special/wx_martial_container");
		local skills = {
			function getActor() { return actor; },
			function hasSkill( _id ) { return false; }
		};
		c.setContainer(skills);
		// Equip Tianwai (+20% pen) + Gufeng (+25% empty-offhand pen) -> total extra pen must clamp at 0.25!
		c.m.Slots[1].ManualID = "wx_manual_tianwai"; c.m.Slots[1].Tier = 3;
		c.m.Slots[3].ManualID = "wx_manual_gufeng";  c.m.Slots[3].Tier = 3;
		c.m.Slots[4].ManualID = "wx_manual_chanzi";  c.m.Slots[4].Tier = 3;

		local props = ::Const.CharacterProperties.getClone();
		local baseDirect = props.DamageDirectAdd;
		c.onUpdate(props);
		if (::Math.abs((props.DamageDirectAdd - baseDirect) - 0.25) > 0.001)
			throw "Expected +0.25 capped DirectDamageAdd, got " + (props.DamageDirectAdd - baseDirect);

		// Paired Fist blocks Offhand -> EmptyOffhandPen must NOT activate!
		heldMain = ::new("scripts/items/weapons/wx_fist_iron");
		if (::Wuxia.CombatRules.hasSingleHandEmptyOffhand(actor))
			throw "Paired fist weapon wrongly treated as single-hand empty offhand";

		// Chanzi adaptation stacks on miss and clears on hit
		local mockAtk = { m = { IsWeaponSkill = true }, function isAttack() { return true; }, function isRanged() { return false; } };
		c.onTargetMissed(mockAtk, null);
		c.onTargetMissed(mockAtk, null);
		if (c.m.FastAdaptStacks != 2) throw "Expected 2 FastAdaptStacks";
		local atkProps = ::Const.CharacterProperties.getClone();
		local baseMatk = atkProps.MeleeSkill;
		c.onAnySkillUsed(mockAtk, null, atkProps);
		if (atkProps.MeleeSkill - baseMatk < 20) throw "FastAdaptBonus did not apply +20 MeleeSkill";
		c.onTargetHit(mockAtk, null, 0, 5, 0);
		if (c.m.FastAdaptStacks != 0) throw "FastAdaptStacks did not reset on hit";
	});

	check("Background Wuxia remapping preserves vanilla IDs and assigns 0/1/2 starter manuals", function() {
		foreach (bgID, cfg in ::Wuxia.Config.Backgrounds)
		{
			if ("CommonPool" in cfg) foreach (m in cfg.CommonPool) if (::Wuxia.Slots.getManualDef(m) == null) throw bgID + ":" + m;
			if ("SectPool" in cfg)   foreach (m in cfg.SectPool)   if (::Wuxia.Slots.getManualDef(m) == null) throw bgID + ":" + m;
		}

		local makeMockBro = function( _bgScript, _weaponScript )
		{
			local bg = ::new("scripts/skills/backgrounds/" + _bgScript);
			local main = _weaponScript != null ? ::new("scripts/items/weapons/" + _weaponScript) : null;
			local skillMap = {};
			local c = ::new("scripts/skills/special/wx_martial_container");
			skillMap[c.getID()] <- c;
			local items = {
				function getItemAtSlot( _s ) { return _s == ::Const.ItemSlot.Mainhand ? main : null; },
				function equip( _w ) { main = _w; return true; }
			};
			local actorRef = null;
			local skills = {
				function getActor() { return actorRef; },
				function getSkillByID( _id ) { return (_id in skillMap) ? skillMap[_id] : null; },
				function hasSkill( _id ) { return (_id in skillMap); },
				function add( _sk ) { skillMap[_sk.getID()] <- _sk; },
				function remove( _sk ) { if (_sk.getID() in skillMap) delete skillMap[_sk.getID()]; },
				function update() {}
			};
			c.setContainer(skills);
			actorRef = {
				function getBackground() { return bg; },
				function getItems() { return items; },
				function getSkills() { return skills; }
			};
			return { Bro = actorRef, Bg = bg, Container = c, Items = items };
		};

		local f = makeMockBro("farmhand_background", null);
		if (f.Bg.getID() != "background.farmhand" || ::Wuxia.Backgrounds.getEntry(f.Bg.getID()).Name != "庄稼把式") throw "Farmhand remap mismatch";
		if (("WX_ApplyMapping" in f.Bg) && f.Bg.getName() != "庄稼把式") throw "Farmhand hook name mismatch";
		if (::Wuxia.Backgrounds.assignStarterManuals(f.Bro).len() != 0) throw "Tier 0 should get 0 starter manuals";

		local b = makeMockBro("brawler_background", null);
		if (b.Bg.getID() != "background.brawler" || ::Wuxia.Backgrounds.getEntry(b.Bg.getID()).Name != "市井拳师") throw "Brawler remap mismatch";
		if (("WX_ApplyMapping" in b.Bg) && b.Bg.getName() != "市井拳师") throw "Brawler hook name mismatch";
		if (::Wuxia.Backgrounds.assignStarterManuals(b.Bro).len() != 1) throw "Tier 1 should get 1 starter manual";
		if (b.Items.getItemAtSlot(::Const.ItemSlot.Mainhand) == null) throw "Brawler did not receive starter wraps";

		local s = makeMockBro("swordmaster_background", "noble_sword");
		if (s.Bg.getID() != "background.swordmaster" || ::Wuxia.Backgrounds.getEntry(s.Bg.getID()).Name != "退隐剑宗名宿") throw "Swordmaster remap mismatch";
		if (("WX_ApplyMapping" in s.Bg) && s.Bg.getName() != "退隐剑宗名宿") throw "Swordmaster hook name mismatch";
		if (::Wuxia.Backgrounds.assignStarterManuals(s.Bro).len() != 2) throw "Tier 2 should get 2 starter manuals";
		if (s.Container.m.Slots[0].ManualID == null || s.Container.m.Slots[1].ManualID == null) throw "Tier 2 did not fill both Lv1 slots";
	});

	check("M4.2 Ecology: EntityName table, enemy scripts, undead acupoint immunity and Zhenhun bonus", function() {
		if (::Wuxia.Ecology.MappedEntityCount < 55)
			throw "Expected >= 55 mapped EntityNames, got " + ::Wuxia.Ecology.MappedEntityCount;
		if (::Const.Strings.EntityName[::Const.EntityType.OrcWarlord] != "炼体药人总瓢把子")
			throw "OrcWarlord name mismatch";
		if (::Const.Strings.EntityName[::Const.EntityType.SkeletonHeavy] != "前朝镇陵金甲卫")
			throw "SkeletonHeavy name mismatch";

		foreach (key, profile in ::Wuxia.Loot.EnemyLoadouts)
		{
			if (::Wuxia.Loot.resolveEnemyScript(profile) == null)
				throw "Unresolved EnemyLoadouts script: " + key;
		}
		foreach (loc in ["wx_blood_keep", "wx_sword_retreat", "wx_ancient_tomb", "wx_wudu_sanctum"])
		{
			local site = ::new("scripts/entity/world/locations/" + loc);
			if (site.getTypeID() == "") throw "Invalid location: " + loc;
		}

		// Verify undead/construct target blocks acupoint & dart poison, and receives Zhenhun +18% damage
		local undeadSkills = {
			Added = false,
			function getSkillByID( _id ) { return null; },
			function hasSkill( _id ) { return false; },
			function add( _sk ) { this.Added = true; }
		};
		local undeadFlags = { function has( _k ) { return _k == "undead"; } };
		local undeadTarget = {
			function isAlive() { return true; },
			function getFlags() { return undeadFlags; },
			function getSkills() { return undeadSkills; },
			function getCurrentProperties() { return { IsAffectedByPoison = false, IsAffectedByInjuries = false }; }
		};
		local acupointMove = ::new("scripts/skills/actives/wx_fist_acupoint");
		acupointMove.wxApplyStatusToTarget(undeadTarget, "effects.wx_status_acupoint", "scripts/skills/effects/wx_status_acupoint");
		if (undeadSkills.Added) throw "Undead should be immune to acupoint status";

		local c = ::new("scripts/skills/special/wx_martial_container");
		c.m.Slots[3].ManualID = "wx_manual_zhenhun";
		c.m.Slots[3].Tier = 3;
		local props = ::Const.CharacterProperties.getClone();
		c.onUpdate(props);
		local atkProps = ::Const.CharacterProperties.getClone();
		local mockAtk = { m = { IsWeaponSkill = true }, function isAttack() { return true; }, function isRanged() { return false; } };
		c.onAnySkillUsed(mockAtk, undeadTarget, atkProps);
		if (::Math.abs(atkProps.DamageTotalMult - 1.18) > 0.001)
			throw "Expected 1.18x VsUndeadDmg, got " + atkProps.DamageTotalMult;
	});

	check("M4.1b 44-Sect regional network & tea-house trio picker", function() {
		local sectCount = 0;
		foreach (sid, sdef in ::Wuxia.Config.Sects)
		{
			sectCount += 1;
			if (sid != sdef.ID || !("Region" in sdef) || !(sdef.Region in ::Wuxia.Config.SectRegions))
				throw "Invalid sect region: " + sid;
			if (sdef.ShopManuals.len() == 0)
				throw "Empty ShopManuals: " + sid;
		}
		if (sectCount < 44) throw "Expected >= 44 sects, got " + sectCount;

		foreach (reg, _ in ::Wuxia.Config.SectRegions)
		{
			local trio = ::Wuxia.SectRelations.pickRegionalTrio(reg);
			if (trio.len() != 3 || trio[0] == trio[1] || trio[1] == trio[2] || trio[0] == trio[2])
				throw "Invalid regional trio for " + reg;
		}

		local ev = ::new("scripts/events/events/wx_event_sect_exchange");
		if (ev.getID() != "event.wx_sect_exchange" || ev.m.Screens.len() < 7)
			throw "Invalid upgraded sect exchange event";
		foreach (sid2, sdef2 in ::Wuxia.Config.Sects)
			if (sdef2.ShopManuals.len() < 5) throw "Expected >= 5 exclusive manuals in sect " + sid2;
	});

	check("v0.5.0 Page anti-bloat: 参悟化功 resonance & 2:1 wildcard page completion", function() {
		// 1. Test Page Infusion (参悟化功) with cross-category, same-category (+25%), and same-manual (+50%)
		local c = ::new("scripts/skills/special/wx_martial_container");
		local actorRef = null;
		local skills = {
			function getActor() { return actorRef; },
			function getSkillByID( _id ) { return _id == "special.wx_martial_container" ? c : null; },
			function hasSkill( _id ) { return false; },
			function add( _sk ) {},
			function remove( _sk ) {},
			function update() {}
		};
		c.setContainer(skills);
		actorRef = {
			function getSkills() { return skills; },
			function getItems() { return null; },
			function getBaseProperties() { return ::Const.CharacterProperties.getClone(); }
		};
		c.m.Slots[0].ManualID = "wx_manual_zixia_gong"; // sect neigong (ExpNeeded = 160 for Tier 2)
		c.m.Slots[0].Tier = 1;
		c.m.Slots[0].Exp = 0;

		local rCross = ::Wuxia.Mastery.infuseWithPage(actorRef, 0, "wx_manual_qingfeng"); // sect waigong -> 40
		if (!rCross.Ok || rCross.ExpAmount != 40 || c.m.Slots[0].Exp != 40)
			throw "Expected +40 cross-category page exp, got " + rCross.ExpAmount;

		local rSameCat = ::Wuxia.Mastery.infuseWithPage(actorRef, 0, "wx_manual_songtao"); // sect neigong -> 50
		if (!rSameCat.Ok || rSameCat.ExpAmount != 50 || c.m.Slots[0].Exp != 90)
			throw "Expected +50 same-category page exp, got " + rSameCat.ExpAmount;

		local rSameBook = ::Wuxia.Mastery.infuseWithPage(actorRef, 0, "wx_manual_zixia_gong"); // exact same -> 60 -> total 150
		if (!rSameBook.Ok || rSameBook.ExpAmount != 60 || c.m.Slots[0].Exp != 150)
			throw "Expected +60 same-manual page exp, got " + rSameBook.ExpAmount;

		// 2. Test 2:1 Same-Quality Wildcard Page Completion
		local stash = ::new("scripts/items/stash_container");
		stash.resize(6);
		local pOwn = ::new("scripts/items/misc/wx_page_item");
		pOwn.initPages("wx_manual_zixia_gong", 2); // needs 3, missing 1 -> needs 2 spare sect pages
		stash.add(pOwn);

		local sp1 = ::new("scripts/items/misc/wx_page_item");
		sp1.initPages("wx_manual_shuofang_jingua", 1);
		stash.add(sp1);

		// Only 1 spare page so far -> wildcard must refuse!
		if (::Wuxia.Slots.craftManualFromStash(stash, "wx_manual_zixia_gong", true).Ok)
			throw "Wildcard craft should refuse with only 1 spare page";

		local sp2 = ::new("scripts/items/misc/wx_page_item");
		sp2.initPages("wx_manual_mobei_taoma_bian", 2);
		stash.add(sp2);

		local preview = ::Wuxia.Slots.previewWildcardCraft(stash, "wx_manual_zixia_gong");
		if (!preview.ok || !preview.needsWildcard || preview.spareNeeded != 2)
			throw "Wildcard preview mismatch";

		local res = ::Wuxia.Slots.craftManualFromStash(stash, "wx_manual_zixia_gong", true);
		if (!res.Ok || !res.UsedWildcard || res.SacrificedCount != 2)
			throw "Wildcard craft failed";
		if (stash.getItemByID("misc.wx_manual_item") == null || sp2.getPageCount() != 1)
			throw "Wildcard craft did not consume smallest 1-page stack first and 1 from sp2";
	});

	check("v0.5.0 All 37 Historical Famous Rare Weapons instantiate, roll red stats & match families", function() {
		local relicCount = 0;
		foreach (rid, cfg in ::Wuxia.Config.RelicWeapons)
		{
			relicCount += 1;
			local w = ::new(cfg.Script);
			if (w.getID() != "weapon." + rid) throw "Relic ID mismatch: " + w.getID();
			if (w.getName().find("传世·") != 0) throw "Relic prefix missing: " + w.getName();
			if (w.m.Icon == "" || w.m.Value < cfg.MinValue) throw "Relic icon/value invalid: " + rid;
			if (!w.isItemType(::Const.Items.ItemType.Named)) throw "Relic missing Named flag: " + rid;
			if (!::Wuxia.CombatRules.matchesWeapon(w, [cfg.Family]))
				throw "Relic did not match expected family " + cfg.Family + ": " + rid;
			local unrelated = (cfg.Family == "Sword") ? "Hammer" : "Sword";
			if (::Wuxia.CombatRules.matchesWeapon(w, [unrelated]))
				throw "Relic falsely matched unrelated family " + unrelated + ": " + rid;
		}
		if (relicCount < 35) throw "Expected >= 35 historical relic weapons, got " + relicCount;
		::logInfo("[WX-SELFTEST] Verified " + relicCount + " Historical Famous Rare Weapons");
	});

	check("v0.5.0 Composable combat flags aggregate via Math.max without linear inflation", function() {
		local held = ::new("scripts/items/weapons/named/wx_relic_yuchang");
		local items = {
			function getItemAtSlot( _s ) { return _s == ::Const.ItemSlot.Mainhand ? held : null; },
			function hasBlockedSlot( _s ) { return false; }
		};
		local actor = {
			function getItems() { return items; },
			function isArmedWithShield() { return false; },
			function getInitiative() { return 110; }
		};
		local skills = { function getActor() { return actor; }, function hasSkill( _id ) { return false; } };
		local c = ::new("scripts/skills/special/wx_martial_container");
		c.setContainer(skills);
		// Equip two manuals that both grant ExecuteLowHpDmg (0.20 and 0.15) -> must take Math.max(0.20), NEVER 0.35!
		c.m.Slots[0].ManualID = "wx_manual_yinsha_guixi";   c.m.Slots[0].Tier = 3; // ExecuteLowHpDmg = 0.15
		c.m.Slots[1].ManualID = "wx_manual_kuaiji_zhuanzhu"; c.m.Slots[1].Tier = 3; // ExecuteLowHpDmg = 0.20 (Dagger matches yuchang!)
		local agg = ::Wuxia.CombatRules.getAggregateFlags(c);
		if (::Math.abs(agg.ExecuteLowHpDmg - 0.20) > 0.001)
			throw "ExecuteLowHpDmg stacked instead of Math.max: " + agg.ExecuteLowHpDmg;
		local props = ::Const.CharacterProperties.getClone();
		c.onUpdate(props);
		local lowHpEnemy = {
			function getHitpoints() { return 30; },
			function getHitpointsMax() { return 100; },
			function getArmor( _p ) { return 50; },
			function getArmorMax( _p ) { return 50; },
			function getSkills() { return null; }
		};
		local atkProps = ::Const.CharacterProperties.getClone();
		local mockAtk = { m = { IsWeaponSkill = true }, function isAttack() { return true; }, function isRanged() { return false; } };
		c.onAnySkillUsed(mockAtk, lowHpEnemy, atkProps);
		if (::Math.abs(atkProps.DamageTotalMult - 1.20) > 0.001)
			throw "Expected 1.20x ExecuteLowHpDmg on <50% HP target, got " + atkProps.DamageTotalMult;
	});

	check("v0.6.1 Shan Hai Jing: 64 Apex Bosses, 64 Neidan Cores, 8 Red Gear/Talismans, 9 Blueprints & Rumor Event", function() {
		if (::Const.Strings.EntityName[::Const.EntityType.Unhold] != "小次山朱厌巨猿" || ::Const.Strings.EntityName[::Const.EntityType.Lindwurm] != "太华六足肥遗蛟")
			throw "Shan Hai EntityName mapping mismatch";

		// 1. Verify all 9 Boss configs, traits, locations & Neidan Cores
		local bossCount = 0;
		foreach (bid, bcfg in ::Wuxia.Config.ShanHaiBosses)
		{
			bossCount += 1;
			if (!(bcfg.BaseTroop in ::Const.World.Spawn.Troops) || !(bcfg.EntityType in ::Const.EntityType))
				throw "Invalid Boss BaseTroop/EntityType: " + bid;
			local trait = ::new("scripts/skills/special/wx_shanhai_boss_trait");
			trait.setBossID(bcfg.Key);
			local p = ::Const.CharacterProperties.getClone();
			trait.onUpdate(p);
			if (bcfg.Key == "qiongqi" && p.ActionPoints < 11) throw "Qiongqi did not reach 11 AP";

			local core = ::new("scripts/items/misc/" + bcfg.CoreID);
			if (core.getID() != "misc." + bcfg.CoreID || core.getName() == "" || core.m.Icon == "")
				throw "Invalid Shan Hai Core item: " + bcfg.CoreID;
			core.getTooltip();

			local lair = ::new("scripts/entity/world/locations/wx_" + bcfg.LairID);
			if (lair.getTypeID() != "location.wx_" + bcfg.LairID)
				throw "Invalid Shan Hai Lair location: " + bcfg.LairID;
		}
		if (bossCount != 64) throw "Expected 64 Shan Hai Apex Bosses, got " + bossCount;

		// 2. Instantiate all 8 Shan Hai Red Armors / Helmets / Talismans
		foreach (gid, gcfg in ::Wuxia.Config.ShanHaiGear)
		{
			local path = gcfg.Kind == "armor" ? ("scripts/items/armor/named/" + gid)
				: (gcfg.Kind == "helmet" ? ("scripts/items/helmets/named/" + gid)
				: (gcfg.Kind == "shield" ? ("scripts/items/shields/named/" + gid)
				: ("scripts/items/accessory/" + gid)));
			local gear = ::new(path);
			if (gear.getName() != gcfg.Name || gear.m.Icon == "")
				throw "Invalid Shan Hai Gear item: " + gid;
			gear.getTooltip();
			if (gid == "wx_armor_qiongqi" && gear.m.StaminaModifier < -9)
				throw "Qiongqi nimble armor exceeded -9 stamina penalty: " + gear.m.StaminaModifier;
			if (gid == "wx_acc_jiuwei")
			{
				local p1 = ::Const.CharacterProperties.getClone();
				local b0 = p1.Bravery;
				gear.onUpdateProperties(p1);
				if (p1.Bravery - b0 != 12) throw "Jiuwei talisman did not add +12 Bravery";
			}
			if (gid == "wx_acc_wuzhiqi")
			{
				local p2 = ::Const.CharacterProperties.getClone();
				gear.onUpdateProperties(p2);
				if (!p2.IsImmuneToPoison || p2.FatigueRecoveryRate < 2)
					throw "Wuzhiqi pearl did not grant Poison Immunity & Qi recovery (poison=" + p2.IsImmuneToPoison + ", fr=" + p2.FatigueRecoveryRate + ", gid=" + gear.m.GearID + ")";
			}
		}

		// 3. Instantiate all 9 Shan Hai Taxidermist Blueprints & Rumor Event
		foreach (bpName in [
			"wx_bp_armor_zhuyan", "wx_bp_armor_feiyi", "wx_bp_armor_qiongqi", "wx_bp_armor_jumang",
			"wx_bp_helm_taotie", "wx_bp_helm_bashe", "wx_bp_acc_jiuwei", "wx_bp_acc_wuzhiqi",
			"wx_bp_relic_xingtianqi"
		])
		{
			local bp = ::new("scripts/crafting/blueprints/" + bpName);
			if (bp.getID() != "blueprint." + bpName) throw "Invalid Shan Hai blueprint: " + bpName;
		}

		local rumor = ::new("scripts/events/events/wx_event_shanhai_rumor");
		if (rumor.getID() != "event.wx_wx_shanhai_rumor" && rumor.getID() != "event.wx_shanhai_rumor" || rumor.m.Screens.len() < 3)
			throw "Invalid Shan Hai rumor event";
		for (local vi = 1; vi <= 32; vi = ++vi)
		{
			local vid = vi < 10 ? ("wx_vfx_0" + vi) : ("wx_vfx_" + vi);
			if (::Wuxia.VFX.buildAttackEffect(vid) == null) throw "VFX buildAttackEffect returned null for " + vid;
		}
		::logInfo("[WX-SELFTEST] Verified 64 Shan Hai Apex Bosses, 64 Cores, 32 Skill VFX Brushes, 8 Red Gear/Talismans & 9 Blueprints");
	});

	check("v0.8.0 16x4-Frame Martial Animations, 72 Active Move Tooltips, 10 Alchemy Pills & Manual/Page Icons", function() {
		// 1. Verify all 16 4-frame flipbook stage timelines
		for (local ai = 1; ai <= 16; ai = ++ai)
		{
			local aid = ai < 10 ? ("wx_anim_0" + ai) : ("wx_anim_" + ai);
			local seq = ::Wuxia.VFX.buildFlipbookStages(aid);
			if (seq == null || seq.len() != 4)
				throw "Invalid 4-frame flipbook stages for " + aid;
		}

		// 2. Verify all active skills assigned in all 272 manuals instantiate, have custom wx_ov_* Overlay, WX_AnimID & rich getTooltip()
		local seenSkills = {};
		foreach (mid, mdef in ::Wuxia.Config.Manuals)
		{
			local mItem = ::new("scripts/items/misc/wx_manual_item");
			mItem.initManual(mid);
			if (mItem.m.Icon.find("wx_book_") == null || mItem.getTooltip().len() < 3)
				throw "Invalid manual item icon/tooltip for " + mid;

			if (mdef.FragmentsNeeded > 0)
			{
				local pItem = ::new("scripts/items/misc/wx_page_item");
				pItem.initPages(mid, 2);
				if (pItem.m.Icon.find("wx_page_") == null || pItem.getTooltip().len() < 4)
					throw "Invalid page item icon/tooltip for " + mid;
			}

			foreach (lv in mdef.Levels)
			{
				foreach (gid in lv.GrantSkills)
				{
					if (gid in seenSkills) continue;
					local shortName = gid.slice(8); // strip "actives."
					if (shortName.find("wx_") != 0) continue;
					seenSkills[gid] <- true;
					local sk = ::new("scripts/skills/actives/" + shortName);
					if (sk.m.Overlay != "wx_ov_" + shortName)
						throw "Skill " + shortName + " still has generic Overlay: " + sk.m.Overlay;
					if (!(::Wuxia.hasMember(sk.m, "WX_AnimID")) || sk.m.WX_AnimID == null || !(sk.m.WX_AnimID in ::Wuxia.VFX.AnimLabels))
						throw "Skill " + shortName + " missing valid WX_AnimID";
					if ("wxFormatWeaponList" in sk)
					{
						local tt = sk.getTooltip();
						if (tt == null || tt.len() < 2)
							throw "Skill " + shortName + " returned invalid tooltip";
					}
				}
			}
		}

		// 3. Verify all 10 Jianghu Alchemy Pills & temporary single-battle pill buff effect
		local pillCnt = 0;
		foreach (pid, pdef in ::Wuxia.Config.Pills)
		{
			pillCnt += 1;
			local pill = ::new("scripts/items/misc/wx_pill_item");
			pill.initPill(pid);
			if (pill.getName() != pdef.Name || pill.getTooltip().len() < 3)
				throw "Invalid pill item or tooltip: " + pid;
		}
		if (pillCnt < 10) throw "Expected >= 10 Jianghu Pills, got " + pillCnt;

		local bEff = ::new("scripts/skills/effects/wx_pill_battle_buff");
		bEff.addPillBuff("buff_qingxin");
		bEff.addPillBuff("buff_hugu");
		bEff.addPillBuff("buff_dingshen");
		local bp = ::Const.CharacterProperties.getClone();
		local s0 = bp.Stamina;
		local br0 = bp.Bravery;
		bEff.onUpdate(bp);
		if (!bp.IsImmuneToPoison || bp.IsAffectedByNight || (bp.Stamina - s0) != 12 || (bp.Bravery - br0) != 10 || bEff.getSummaryLabels().len() != 3)
			throw "wx_pill_battle_buff properties mismatch";
		if (seenSkills.len() != 72)
			throw "Expected all 72 Wuxia active skills wired to manuals, got " + seenSkills.len();
		::logInfo("[WX-SELFTEST] Verified 16x4-Frame Martial Animations, " + seenSkills.len() + " Active Skills, 272 Manuals & 10 Pills");
	});

	// Verify Wuxia OST music remap
	check("Wuxia OST ::Const.Music playlist remap", function() {
		local cfg = ::Wuxia.Config.Music;
		if (!("Music" in ::Const))
			throw "::Const.Music missing";
		local keysLog = "";
		foreach (k, v in ::Const.Music)
		{
			local sample = "";
			if (typeof v == "array" && v.len() > 0) sample = "" + v[0];
			else if (typeof v == "string") sample = v;
			if (sample != "") keysLog += k + "=" + sample + "; ";
		}
		::logInfo("[WX-SELFTEST] Const.Music active mapping (applied=" + cfg.AppliedKeys.len() + "): " + keysLog);
		if ("BattleTracks" in ::Const.Music && typeof ::Const.Music.BattleTracks == "array")
		{
			local btLog = "";
			for (local bi = 0; bi < ::Const.Music.BattleTracks.len(); bi++)
			{
				local entry = ::Const.Music.BattleTracks[bi];
				if (typeof entry == "array" && entry.len() > 0)
				{
					btLog += "[" + bi + "]=" + entry[0] + "; ";
					if (entry[0].find("wx_") == null)
						throw "BattleTracks[" + bi + "] was not remapped in-place: " + entry[0];
				}
			}
			::logInfo("[WX-SELFTEST] Const.Music.BattleTracks verified in-place: " + btLog);
		}
		if (cfg.AppliedKeys.len() < 8)
			throw "Expected >= 8 ::Const.Music playlists remapped, got " + cfg.AppliedKeys.len();
	});

	// Verify 500 Independent Wuxia Character Biographies, Chinese Names & All 66 Events
	check("500 Independent Wuxia Biographies, Chinese Names/Titles & All 66 Jianghu Events", function() {
		local bioTotal = 0;
		local seenBioIDs = {};
		foreach (bgID, _ in ::Wuxia.Config.Backgrounds)
		{
			if (!(bgID in ::Wuxia.Config.BackgroundBios) || ::Wuxia.Config.BackgroundBios[bgID].len() == 0)
				throw "Missing bio pool for background: " + bgID;
			if (!(bgID in ::Wuxia.Config.BackgroundNames))
				throw "Missing Chinese name config for background: " + bgID;
			foreach (bio in ::Wuxia.Config.BackgroundBios[bgID])
			{
				bioTotal += 1;
				if (bio.ID in seenBioIDs) throw "Duplicate bio ID: " + bio.ID;
				seenBioIDs[bio.ID] <- true;
				if (bio.Text.find("%name%") == null) throw "Missing %name% token in " + bio.ID;
			}
		}
		if (bioTotal != 500)
			throw "Expected exactly 500 independent biographies, got " + bioTotal;

		local rendered = ::Wuxia.Backgrounds.renderBioTemplate("在城隍庙前，%name%笑了一声。", "沈寒江");
		if (rendered.find("沈寒江") == null || rendered.find("%name%") != null)
			throw "renderBioTemplate failed: " + rendered;

		local eventScripts = [
			"wx_event_bookshop", "wx_event_famous_physician", "wx_event_ghost_auction",
			"wx_event_grand_tournament", "wx_event_sect_exchange", "wx_event_shanhai_rumor",
			"wx_event_camp_monk_brawl", "wx_event_camp_swordmaster_lesson", "wx_event_camp_historian_stele",
			"wx_event_camp_tailor_lining", "wx_event_camp_bowyer_string", "wx_event_camp_gambler_dice",
			"wx_event_camp_butcher_feast", "wx_event_camp_ratcatcher_stew", "wx_event_camp_noble_peasant",
			"wx_event_camp_minstrel_ballad", "wx_event_camp_houndmaster_stray", "wx_event_camp_gravedigger_omen",
			"wx_event_bg_witchhunter_evil", "wx_event_bg_anatomist_venom", "wx_event_bg_executioner_edge",
			"wx_event_bg_fisher_chest", "wx_event_bg_mason_ruin", "wx_event_bg_messenger_shortcut",
			"wx_event_bg_juggler_market", "wx_event_bg_brawler_armwrestle", "wx_event_bg_thief_pickpocket",
			"wx_event_bg_deserter_patrol", "wx_event_bg_eunuch_rumor", "wx_event_bg_lumberjack_ironwood",
			"wx_event_martial_sparring", "wx_event_martial_conflict_crisis", "wx_event_martial_fragment_demon",
			"wx_event_martial_wash_afterglow", "wx_event_martial_fake_manual", "wx_event_martial_old_beggar",
			"wx_event_martial_waterfall_epiphany", "wx_event_martial_herbalist_cauldron", "wx_event_martial_internal_meditation",
			"wx_event_martial_broken_sword_grave", "wx_event_martial_night_watch_breath", "wx_event_martial_page_exchange",
			"wx_event_sect_wounded_courier", "wx_event_sect_rival_clash", "wx_event_sect_vendetta_broker",
			"wx_event_sect_escort_wreck", "wx_event_sect_gaibang_tip", "wx_event_sect_tangmen_peddler",
			"wx_event_sect_shaolin_alms", "wx_event_sect_tavern_challenge", "wx_event_sect_wudu_barter",
			"wx_event_sect_escort_banquet", "wx_event_sect_outlaw_toll", "wx_event_sect_wandering_elder",
			"wx_event_weird_black_inn", "wx_event_weird_xiangxi_corpses", "wx_event_weird_fox_temple",
			"wx_event_weird_ancient_tomb_door", "wx_event_weird_shanhai_feiyi_shed", "wx_event_weird_shanhai_zhuyan_tracks",
			"wx_event_weird_shanhai_baize_shrine", "wx_event_weird_shanhai_mirage", "wx_event_road_starving_refugees",
			"wx_event_road_corrupt_taxman", "wx_event_road_plague_village", "wx_event_crisis_jianghu_omen"
		];
		local seenEventIDs = {};
		foreach (es in eventScripts)
		{
			local ev = ::new("scripts/events/events/" + es);
			local eid = ev.getID();
			if (eid == "" || eid in seenEventIDs) throw "Invalid or duplicate event ID: " + es + " -> " + eid;
			seenEventIDs[eid] <- true;
			if (ev.m.Screens.len() < 2) throw "Event has < 2 screens: " + es;
			if (::Wuxia.hasMember(ev, "onClear")) ev.onClear();
		}
		::logInfo("[WX-SELFTEST] Verified " + bioTotal + " Independent Wuxia Biographies (72 Backgrounds) & " + eventScripts.len() + " Jianghu Events");
	});

	// v0.9.0: Verify 72/72 Zero-Duplicate Skill Choreographies, Paperdoll Armory, 1000-Faces Schema v2 & 32 Jianghu Fighters
	check("v0.9.0 72 Unique Skill Choreos, Paperdoll Armory, 1000-Faces Schema v2 & 32 Fighters", function() {
		// 1. Assert 72/72 strictly unique SkillChoreo entries & labels (ZERO duplicate move labels!)
		local choreoLabels = {};
		local choreoCount = 0;
		foreach (cid, spec in ::Wuxia.VFX.SkillChoreo)
		{
			choreoCount += 1;
			local lbl = spec[0];
			if (lbl in choreoLabels) throw "Duplicate SkillChoreo label: " + lbl + " on " + cid;
			choreoLabels[lbl] <- true;
			local sk = ::new("scripts/skills/actives/" + cid);
			if (!(::Wuxia.hasMember(sk.m, "WX_ChoreoID")) || sk.m.WX_ChoreoID != cid)
				throw "Skill " + cid + " missing matching WX_ChoreoID";
			if (::Wuxia.VFX.getSkillChoreoLabel(sk) != lbl)
				throw "getSkillChoreoLabel mismatch on " + cid;
		}
		if (choreoCount != 72) throw "Expected 72 unique SkillChoreo entries, got " + choreoCount;

		// 2. Verify SchemaVersion = 2 round-trip AND backward-compatible v1 migration!
		local makeStream = function() {
			local q = [];
			return {
				buf = q,
				function getMetaData() { return { function getVersion() { return 66; } }; },
				function writeU8(v) { this.buf.push(v); },
				function writeI8(v) { this.buf.push(v); },
				function writeU16(v) { this.buf.push(v); },
				function writeI16(v) { this.buf.push(v); },
				function writeU32(v) { this.buf.push(v); },
				function writeI32(v) { this.buf.push(v); },
				function writeF32(v) { this.buf.push(v); },
				function writeBool(v) { this.buf.push(v); },
				function writeString(v) { this.buf.push(v); },
				function readU8() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readI8() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readU16() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readI16() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readU32() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readI32() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readF32() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readBool() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readString() { local v = this.buf[0]; this.buf.remove(0); return v; }
			};
		};
		local cSrc = ::new("scripts/skills/special/wx_martial_container");
		cSrc.m.FaceIdx = 35;
		cSrc.m.HairIdx = 14;
		cSrc.m.BeardIdx = 0;
		cSrc.m.ScarIdx = 8;
		local st2 = makeStream();
		cSrc.onSerialize(st2);
		local cDst = ::new("scripts/skills/special/wx_martial_container");
		cDst.onDeserialize(st2);
		if (cDst.m.SchemaVersion < 2 || cDst.m.FaceIdx != 35 || cDst.m.HairIdx != 14 || cDst.m.BeardIdx != 0 || cDst.m.ScarIdx != 8)
			throw "SchemaVersion >= 2 appearance round-trip failed";

		// 3. Verify 1000-Faces Appearance labels, seeding & stepping
		if (::Wuxia.Appearance.FaceLabels.len() != 49 || ::Wuxia.Appearance.HairLabels.len() != 25 || ::Wuxia.Appearance.BeardLabels.len() != 25 || ::Wuxia.Appearance.ScarLabels.len() != 13)
			throw "Appearance label table length mismatch";
		local dummyActor = {
			m = {},
			function getID() { return 108; },
			function getNameOnly() { return "裴惊鸿"; },
			function getBackground() { return null; },
			function getSkills() { return null; }
		};
		local a1 = ::Wuxia.Appearance.stepAppearance(dummyActor, "face", 1);
		local a2 = ::Wuxia.Appearance.stepAppearance(dummyActor, "hair", -1);
		if (a1 == null || a2 == null || a1.faceIdx < 1 || a1.faceIdx > 48)
			throw "Appearance stepAppearance failed";

		// 4. Verify Paperdoll Armory visual remapping across vanilla & Wuxia weapons, shields, armors & helmets
		local wSword = ::new("scripts/items/weapons/arming_sword");
		wSword.getName();
		if (!("WX_ArmBrush" in wSword.m) || wSword.m.WX_ArmBrush != "arm_wx_wpn_sword_03" || wSword.getIcon().find("wx_wpn_sword_03") == null)
			throw "Arming sword paperdoll remap failed";

		local wGun = ::new("scripts/items/weapons/oriental/handgonne");
		wGun.getName();
		if (!("WX_ArmBrush" in wGun.m) || wGun.m.WX_ArmBrush != "arm_wx_wpn_gun_01")
			throw "Handgonne paperdoll remap failed";

		local wFist = ::new("scripts/items/weapons/wx_fist_iron");
		wFist.getName();
		if (wFist.m.ArmamentIcon != "arm_wx_fist_iron" || !wFist.m.ShowArmamentIcon)
			throw "wx_fist_iron handheld brush missing";

		local shd = ::new("scripts/items/shields/heater_shield");
		shd.getName();
		if (!("WX_ShieldBrush" in shd.m) || shd.m.WX_ShieldBrush != "shd_wx_shd_05")
			throw "Heater shield paperdoll remap failed";

		local arm = ::new("scripts/items/armor/mail_hauberk");
		arm.getName();
		if (!("WX_BodyBrush" in arm.m) || arm.m.WX_BodyBrush != "wx_body_arm_08")
			throw "Mail hauberk paperdoll remap failed";

		local redArm = ::new("scripts/items/armor/named/wx_armor_zhuyan");
		if (!("WX_BodyBrush" in redArm.m) || redArm.m.WX_BodyBrush != "wx_armor_zhuyan")
			throw "Shan Hai red armor WX_BodyBrush missing";

		local hlm = ::new("scripts/items/helmets/kettle_hat");
		hlm.getName();
		if (!("WX_HatFrontBrush" in hlm.m) || hlm.m.WX_HatFrontBrush != "wx_hat_26_front")
			throw "Kettle hat boolean front brush failed";

		local redHlm = ::new("scripts/items/helmets/named/wx_helm_taotie");
		if (!("WX_HatFrontBrush" in redHlm.m) || redHlm.m.WX_HatFrontBrush != "wx_helm_taotie_front")
			throw "Shan Hai red helmet WX_HatFrontBrush missing";

		// 5. Verify all 32 Jianghu/Imperial/Folkloric Fighters, weapons, manuals & Vendetta squads!
		local fCnt = 0;
		foreach (fid, fcfg in ::Wuxia.Config.Fighters)
		{
			fCnt += 1;
			if (!(fcfg.BaseTroop in ::Const.World.Spawn.Troops))
				throw "Unknown BaseTroop in Fighter " + fid + ": " + fcfg.BaseTroop;
			local fw = ::new("scripts/items/weapons/" + fcfg.Weapon);
			if (fw == null) throw "Unresolvable weapon in Fighter " + fid;
			foreach (mEntry in fcfg.Manuals)
			{
				if (!(mEntry.ManualID in ::Wuxia.Config.Manuals))
					throw "Unknown ManualID in Fighter " + fid + ": " + mEntry.ManualID;
			}
		}
		if (fCnt != 32) throw "Expected 32 Jianghu Fighter archetypes, got " + fCnt;

		foreach (vid, vcfg in ::Wuxia.Config.Vendettas)
		{
			foreach (tid in vcfg.Troops)
			{
				if (!(tid in ::Wuxia.Config.Fighters) && !(tid in ::Const.World.Spawn.Troops))
					throw "Unknown troop in Vendetta " + vid + ": " + tid;
			}
		}
		::logInfo("[WX-SELFTEST] Verified 72/72 Unique Choreos, Paperdoll Armory (138 handheld), 1000-Faces Schema v2 & 32 Jianghu Fighters");
	});

	// Verify Consumable Manuals, Per-Character LearnedManuals (Schema v3) & Company 藏经阁 Vault
	check("Consumable manuals, LearnedManuals mastery retention (Schema v3) & 藏经阁 Library", function() {
		::Wuxia.Library.resetFallback();

		// Mock actor with real skill_container-like methods for slot_manager & mastery_manager
		local skillsMap = {};
		local mockContainer = null;
		local mockActor = null;
		local mockSkills = {
			function getActor() { return mockActor; },
			function getSkillByID( _id ) { return (_id in skillsMap) ? skillsMap[_id] : null; },
			function hasSkill( _id ) { return (_id in skillsMap); },
			function add( _sk ) {
				skillsMap[_sk.getID()] <- _sk;
				if ("m" in _sk) _sk.m.Container = this;
			},
			function remove( _sk ) {
				if (_sk != null && (_sk.getID() in skillsMap)) delete skillsMap[_sk.getID()];
			},
			function removeByID( _id ) {
				if (_id in skillsMap) delete skillsMap[_id];
			},
			function update() {}
		};
		mockActor = {
			m = { Talents = [2, 2, 2, 0, 0, 0, 0, 0] },
			function getID() { return 777; },
			function getName() { return "沈清风"; },
			function getLevel() { return 11; },
			function getSkills() { return mockSkills; },
			function getItems() { return null; },
			function getBaseProperties() { return ::Const.CharacterProperties.getClone(); }
		};

		mockContainer = ::Wuxia.Slots.getContainer(mockActor);
		if (mockContainer == null) throw "Failed to create wx_martial_container on mockActor";

		// 1. Cannot equip an unlearned manual via equipLearnedManual
		if (::Wuxia.Slots.canEquipLearnedManual(mockActor, 1, "wx_manual_qingfeng").Ok)
			throw "Allowed equipping unlearned manual!";

		// 2. Consumable wx_manual_item teaches manual once and blocks duplicate consumption
		local bookQingfeng = ::new("scripts/items/misc/wx_manual_item");
		bookQingfeng.initManual("wx_manual_qingfeng");
		if (!bookQingfeng.isUsable()) throw "wx_manual_item must have IsUsable = true";
		if (!bookQingfeng.onUse(mockActor)) throw "First onUse(mockActor) should succeed";
		if (bookQingfeng.onUse(mockActor)) throw "Duplicate onUse(mockActor) must return false so book is not wasted!";

		// 3. Fragment learn -> upgraded cleanly by consuming full manual
		if (!::Wuxia.Slots.learnManual(mockActor, "wx_manual_heifeng", true).Ok)
			throw "Fragment learn failed";
		if (!mockContainer.getLearnedEntry("wx_manual_heifeng").IsFragment)
			throw "Expected IsFragment == true";
		local bookHeifeng = ::new("scripts/items/misc/wx_manual_item");
		bookHeifeng.initManual("wx_manual_heifeng");
		if (!bookHeifeng.onUse(mockActor) || mockContainer.getLearnedEntry("wx_manual_heifeng").IsFragment)
			throw "Full manual onUse did not upgrade fragment entry";

		// 4. Equip learned manual, gain mastery exp, swap out to another learned manual, verify Tier & Exp preserved!
		if (!::Wuxia.Slots.equipLearnedManual(mockActor, 1, "wx_manual_qingfeng").Ok)
			throw "Failed to equip learned wx_manual_qingfeng";
		::Wuxia.Mastery.addExpToSlot(mockActor, 1, 260); // Advances past Tier 1 -> Tier 2 with leftover exp!
		local savedTier = mockContainer.m.Slots[1].Tier;
		local savedExp  = mockContainer.m.Slots[1].Exp;
		if (savedTier < 2) throw "Expected Tier >= 2 after +260 exp, got " + savedTier;

		// Swap slot 1 to wx_manual_heifeng -> wx_manual_qingfeng must remain in LearnedManuals with full Tier & Exp!
		local swapRes = ::Wuxia.Slots.equipLearnedManual(mockActor, 1, "wx_manual_heifeng");
		if (!swapRes.Ok || !swapRes.IsOverwrite) throw "Slot switch failed";
		if (!mockSkills.hasSkill("effects.wx_scatter_weakness")) throw "Expected brief scatter weakness on slot switch";
		local preserved = mockContainer.getLearnedEntry("wx_manual_qingfeng");
		if (preserved == null || preserved.Tier != savedTier || preserved.Exp != savedExp)
			throw "Outgoing learned manual lost its Tier/Exp on switch!";

		// Swap back to wx_manual_qingfeng and verify Tier & Exp restored into slot!
		if (!::Wuxia.Slots.equipLearnedManual(mockActor, 1, "wx_manual_qingfeng").Ok)
			throw "Failed to re-equip wx_manual_qingfeng";
		if (mockContainer.m.Slots[1].Tier != savedTier || mockContainer.m.Slots[1].Exp != savedExp)
			throw "Re-equipped manual did not restore saved Tier/Exp!";

		// Unequip slot 1 -> preserves Tier & Exp and clears slot
		if (!::Wuxia.Slots.unequipSlot(mockActor, 1).Ok || mockContainer.m.Slots[1].ManualID != null)
			throw "unequipSlot failed";

		// 5. SchemaVersion 3 serialization round-trip preserves unequipped LearnedManuals!
		local qBuf = [];
		local stream3 = {
			buf = qBuf,
			function getMetaData() { return { function getVersion() { return 66; } }; },
			function writeU8(v) { this.buf.push(v); },
			function writeI8(v) { this.buf.push(v); },
			function writeU16(v) { this.buf.push(v); },
			function writeI16(v) { this.buf.push(v); },
			function writeU32(v) { this.buf.push(v); },
			function writeI32(v) { this.buf.push(v); },
			function writeF32(v) { this.buf.push(v); },
			function writeBool(v) { this.buf.push(v); },
			function writeString(v) { this.buf.push(v); },
			function readU8() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readI8() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readU16() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readI16() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readU32() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readI32() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readF32() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readBool() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readString() { local v = this.buf[0]; this.buf.remove(0); return v; }
		};
		mockContainer.onSerialize(stream3);
		local cLoaded = ::new("scripts/skills/special/wx_martial_container");
		cLoaded.onDeserialize(stream3);
		local lEntry = cLoaded.getLearnedEntry("wx_manual_qingfeng");
		if (cLoaded.m.SchemaVersion < 3 || lEntry == null || lEntry.Tier != savedTier || lEntry.Exp != savedExp)
			throw "SchemaVersion >= 3 LearnedManuals round-trip failed";

		// 6. Company 藏经阁 (::Wuxia.Library): Stash sweep, Sale withdrawal protection, Exact & 2:1 Wildcard Craft, Library Teach!
		local stash = ::new("scripts/items/stash_container");
		stash.setResizable(false);
		stash.resize(6);

		local bLoot = ::new("scripts/items/misc/wx_manual_item");
		bLoot.initManual("wx_manual_taxue");
		stash.add(bLoot);

		local bSale = ::new("scripts/items/misc/wx_manual_item");
		bSale.initManual("wx_manual_jianbu");
		bSale.m.WX_WithdrawnForSale = true;
		stash.add(bSale);

		local pLoot = ::new("scripts/items/misc/wx_page_item");
		pLoot.initPages("wx_manual_songtao", 3);
		stash.add(pLoot);

		// Auto-sweep (includeWithdrawn = false) moves bLoot & pLoot, leaves bSale in Stash!
		local autoMoved = ::Wuxia.Library.storeAllFromStash(stash, false);
		if (autoMoved.booksMoved != 1 || autoMoved.pagesMoved != 3 || stash.getNumberOfFilledSlots() != 1)
			throw "Auto-sweep did not respect WX_WithdrawnForSale";

		// Explicit sweep (includeWithdrawn = true) sweeps bSale too!
		local fullMoved = ::Wuxia.Library.storeAllFromStash(stash, true);
		if (fullMoved.booksMoved != 1 || stash.getNumberOfFilledSlots() != 0)
			throw "Explicit storeAllFromStash did not clear Stash";

		// Batch exact craft in Library (3/3 wx_manual_songtao -> 1 whole book, 0 Stash slots used!)
		local batchRes = ::Wuxia.Library.craftAllExact();
		if (batchRes.booksCrafted != 1 || ::Wuxia.Library.getManualCount("wx_manual_songtao") != 1 || ::Wuxia.Library.getPageCount("wx_manual_songtao") != 0)
			throw "Library craftAllExact failed";

		// 2:1 Wildcard craft in Library
		::Wuxia.Library.addPages("wx_manual_zixia_gong", 2);
		::Wuxia.Library.addPages("wx_manual_weiyuan", 1);
		::Wuxia.Library.addPages("wx_manual_guiyuan", 1);
		local wildRes = ::Wuxia.Library.craftManual("wx_manual_zixia_gong", true);
		if (!wildRes.Ok || !wildRes.UsedWildcard || ::Wuxia.Library.getManualCount("wx_manual_zixia_gong") != 1)
			throw "Library 2:1 wildcard craft failed";

		// Teach from Library & Withdraw to Stash
		if (!::Wuxia.Library.learnFromLibrary(mockActor, "wx_manual_taxue", false).Ok || ::Wuxia.Library.getManualCount("wx_manual_taxue") != 0)
			throw "learnFromLibrary failed";
		if (!::Wuxia.Library.withdrawManualToStash(stash, "wx_manual_songtao").Ok || stash.getNumberOfFilledSlots() != 1)
			throw "withdrawManualToStash failed";

		::Wuxia.Library.resetFallback();
		::logInfo("[WX-SELFTEST] Verified Consumable Manuals, Schema v3 LearnedManuals Mastery Retention & 藏经阁 Vault");
	});

	// Verify 100% Brush Registration, Variant Persistence, Missing/Named Gear Coverage & Live Actor Sprite Equip/Unequip Sync
	check("Equipment visual pipeline: .brush registration, updateVariant persistence, named/DLC coverage & actor sprite equip/unequip", function() {
		// 1. Verify C++ engine loaded every brush in wx_busts_0.brush & wx_weapons_0.brush!
		if ("doesBrushExist" in getroottable())
		{
			local mustExist = [
				"wx_head_01", "wx_head_48", "wx_hair_01", "wx_hair_01_tucked", "wx_beard_01", "wx_scar_01",
				"wx_char_cloth_short", "wx_body_civ_01", "wx_body_sect_01", "wx_body_arm_08", "wx_body_hvy_04",
				"wx_armor_zhuyan", "wx_armor_feiyi", "wx_armor_qiongqi", "wx_armor_jumang",
				"wx_hat_01_front", "wx_hat_01_back", "wx_hat_26_front", "wx_hat_26_back",
				"wx_helm_taotie_front", "wx_helm_taotie_back", "wx_helm_bashe_front", "wx_helm_bashe_back",
				"arm_wx_fist_wraps", "arm_wx_fist_iron", "arm_wx_fist_heavy", "arm_wx_wpn_fist_06",
				"arm_wx_wpn_sword_03", "arm_wx_wpn_saber_03", "arm_wx_wpn_bow_03", "arm_wx_wpn_xbow_03",
				"arm_wx_wpn_axe_01", "arm_wx_wpn_flail_01", "arm_wx_relic_shenbinu", "arm_wx_relic_dashenbian",
				"arm_wx_relic_chixiao", "arm_wx_relic_zhentiangong",
				"shd_wx_shd_01", "shd_wx_shd_03", "shd_wx_shd_12", "shd_wx_wpn_tool_01",
				"shd_wx_tool_fire_bomb", "shd_wx_tool_smoke_bomb", "shd_wx_tool_daze_bomb",
				"shd_wx_tool_acid_flask", "shd_wx_tool_holy_water"
			];
			foreach (bId in mustExist)
			{
				if (!::doesBrushExist(bId))
					throw "Missing compiled C++ brush: " + bId;
			}
		}

		// 2. Verify previously unmapped base/DLC/named weapons & offhand net map cleanly AND survive updateVariant()!
		local gearChecks = [
			["scripts/items/weapons/winged_mace",             "arm_wx_wpn_hammer_04"],
			["scripts/items/weapons/military_pick",           "arm_wx_wpn_hammer_05"],
			["scripts/items/weapons/goedendag",               "arm_wx_wpn_staff_03"],
			["scripts/items/weapons/oriental/saif",           "arm_wx_wpn_saber_07"],
			["scripts/items/weapons/lute",                    "arm_wx_wpn_sword_01"],
			["scripts/items/weapons/named/named_sword",         "arm_wx_wpn_sword_04"],
			["scripts/items/weapons/named/named_fencing_sword", "arm_wx_wpn_sword_06"],
			["scripts/items/weapons/named/named_warbow",      "arm_wx_wpn_bow_03"],
			["scripts/items/weapons/named/named_billhook",    "arm_wx_wpn_pole_07"]
		];
		foreach (pair in gearChecks)
		{
			local it = ::new(pair[0]);
			it.getIcon();
			if (::Wuxia.hasMember(it, "updateVariant")) it.updateVariant();
			if (!("WX_ArmBrush" in it.m) || it.m.WX_ArmBrush != pair[1] || it.getIcon().find("wx_") == null || it.getIconLarge().find("wx_") == null)
				throw "Weapon mapping or updateVariant persistence failed on " + pair[0] + " (icon=" + it.getIcon() + ")";
		}

		local net = ::new("scripts/items/tools/throwing_net");
		net.getIcon();
		if (!("WX_ShieldBrush" in net.m) || net.m.WX_ShieldBrush != "shd_wx_wpn_tool_01" || net.getIconLarge().find("wx_wpn_tool_01") == null)
			throw "Throwing net offhand visual mapping failed";

		local bombChecks = [
			["scripts/items/tools/fire_bomb_item",  "tools/wx_tool_fire_bomb_70x70.png",  "shd_wx_tool_fire_bomb"],
			["scripts/items/tools/smoke_bomb_item", "tools/wx_tool_smoke_bomb_70x70.png", "shd_wx_tool_smoke_bomb"],
			["scripts/items/tools/daze_bomb_item",  "tools/wx_tool_daze_bomb_70x70.png",  "shd_wx_tool_daze_bomb"],
			["scripts/items/tools/acid_flask_item", "tools/wx_tool_acid_flask_70x70.png", "shd_wx_tool_acid_flask"],
			["scripts/items/tools/holy_water_item", "tools/wx_tool_holy_water_70x70.png", "shd_wx_tool_holy_water"]
		];
		foreach (bc in bombChecks)
		{
			local bItem = ::new(bc[0]);
			if (bItem.getIcon() != bc[1] || !("WX_ShieldBrush" in bItem.m) || bItem.m.WX_ShieldBrush != bc[2] || bItem.m.ShowArmamentIcon)
				throw "Offhand bomb/flask mapping failed on " + bc[0] + " (icon=" + bItem.getIcon() + ")";
		}

		local ammoChecks = [
			["scripts/items/ammo/quiver_of_arrows", "ammo/wx_ammo_arrows.png"],
			["scripts/items/ammo/quiver_of_bolts",  "ammo/wx_ammo_bolts.png"],
			["scripts/items/ammo/powder_bag",       "ammo/wx_ammo_powder.png"]
		];
		foreach (ac in ammoChecks)
		{
			local amItem = ::new(ac[0]);
			if (amItem.getIcon() != ac[1])
				throw "Ammo icon mapping failed on " + ac[0] + ": " + amItem.getIcon();
		}

		local pBanner = ::new("scripts/items/tools/player_banner");
		pBanner.setVariant(52);
		::Wuxia.Armory.ensureItemMapped(pBanner, true);
		if (pBanner.getIcon().find("banner_52") == null || ("WX_ArmBrush" in pBanner.m))
			throw "Armory overwrote player_banner Chinese vertical standard: " + pBanner.getIcon();

		local varArmor = ::new("scripts/items/armor/mail_shirt");
		varArmor.getIcon();
		varArmor.setVariant(1);
		if (varArmor.getIcon().find("wx_body_arm_07") == null || varArmor.getIconLarge().find("wx_body_arm_07") == null)
			throw "Armor setVariant overwrote Wuxia icon: " + varArmor.getIcon();

		local varHelm = ::new("scripts/items/helmets/kettle_hat");
		varHelm.getIcon();
		varHelm.setVariant(1);
		if (varHelm.getIcon().find("wx_hat_26") == null || !("WX_HatBackBrush" in varHelm.m) || varHelm.m.WX_HatBackBrush != "wx_hat_26_back")
			throw "Helmet setVariant overwrote Wuxia icon/back-brush: " + varHelm.getIcon();

		// 3. Simulate full Human Actor sprite stack across equip, swap & unequip!
		local makeSpr = function( _initName = "" ) {
			return {
				BrushName = _initName,
				HasBrush = (_initName != ""),
				Visible = false,
				Color = null,
				DirtyStamp = 0,
				function setBrush( _n ) { this.BrushName = _n; this.HasBrush = (_n != ""); },
				function getBrush() { local n = this.BrushName; return { Name = n }; }
			};
		};
		local sprMap = {
			body = makeSpr("bust_naked_body_01"),
			armor = makeSpr("bust_body_01"),
			surcoat = makeSpr(""),
			armor_upgrade_back = makeSpr(""),
			armor_upgrade_front = makeSpr(""),
			head = makeSpr("bust_head_01"),
			tattoo_head = makeSpr(""),
			tattoo_body = makeSpr(""),
			dirt = makeSpr(""),
			beard = makeSpr(""),
			beard_top = makeSpr(""),
			hair = makeSpr("hair_black_01"),
			helmet = makeSpr(""),
			helmet_damage = makeSpr(""),
			arms_icon = makeSpr(""),
			shield_icon = makeSpr("")
		};
		local slotMap = {};
		slotMap[::Const.ItemSlot.Mainhand] <- null;
		slotMap[::Const.ItemSlot.Offhand]  <- null;
		slotMap[::Const.ItemSlot.Body]     <- null;
		slotMap[::Const.ItemSlot.Head]     <- null;

		local dirtyCounter = 0;
		local mockHuman = {
			m = { WX_TempAppearance = { FaceIdx = 1, HairIdx = 1, BeardIdx = 2, ScarIdx = 1 } },
			function getID() { return 888; },
			function getNameOnly() { return "陆沉舟"; },
			function isAlive() { return true; },
			function getFlags() { return { function has(_f) { return false; } }; },
			function getSkills() { return null; },
			function hasSprite( _k ) { return (_k in sprMap); },
			function getSprite( _k ) { return sprMap[_k]; },
			function getItems() {
				return {
					function getItemAtSlot( _s ) { return (_s in slotMap) ? slotMap[_s] : null; }
				};
			},
			function setDirty( _b ) { if (_b) dirtyCounter += 1; }
		};

		// Equip Armor + Helmet + Sword + Shield -> verify ALL layers update!
		slotMap[::Const.ItemSlot.Body]     = varArmor;
		slotMap[::Const.ItemSlot.Head]     = varHelm;
		slotMap[::Const.ItemSlot.Mainhand] = ::new("scripts/items/weapons/named/wx_relic_chixiao");
		slotMap[::Const.ItemSlot.Offhand]  = ::new("scripts/items/shields/oriental/southern_light_shield");
		::Wuxia.Armory.syncActorHandheldAndArmor(mockHuman);

		if (sprMap.body.BrushName != "wx_body_arm_07" || sprMap.armor.Visible)
			throw "Equipped body armor did not switch body brush & hide vanilla armor";
		if (sprMap.helmet.BrushName != "wx_hat_26_front" || !sprMap.helmet.Visible || sprMap.armor_upgrade_back.BrushName != "wx_hat_26_back" || !sprMap.armor_upgrade_back.Visible)
			throw "Equipped helmet did not apply both hat_front and hat_back";
		if (sprMap.hair.BrushName != "wx_hair_01_tucked" || !sprMap.hair.Visible)
			throw "Closed helmet did not switch hair to boolean _tucked";
		if (sprMap.arms_icon.BrushName != "arm_wx_relic_chixiao" || !sprMap.arms_icon.Visible)
			throw "Equipped relic weapon did not show arm_wx_relic_chixiao on arms_icon";
		if (sprMap.shield_icon.BrushName != "shd_wx_shd_03" || !sprMap.shield_icon.Visible)
			throw "Equipped rattan shield did not show shd_wx_shd_03 on shield_icon";

		// Unequip Weapon & Shield & Helmet & Armor -> verify arms_icon, shield_icon, helmet & hat_back hide cleanly and body returns to wx_char_cloth_short!
		local prevDirty = dirtyCounter;
		slotMap[::Const.ItemSlot.Mainhand] = null;
		slotMap[::Const.ItemSlot.Offhand]  = null;
		slotMap[::Const.ItemSlot.Head]     = null;
		slotMap[::Const.ItemSlot.Body]     = null;
		::Wuxia.Armory.syncActorHandheldAndArmor(mockHuman);

		if (sprMap.arms_icon.Visible || sprMap.shield_icon.Visible)
			throw "Unequipping weapon/shield left arms_icon or shield_icon visible!";
		if (sprMap.helmet.Visible || sprMap.armor_upgrade_back.Visible)
			throw "Unequipping helmet left helmet or hat_back visible!";
		if (sprMap.body.BrushName != "wx_char_cloth_short" || sprMap.hair.BrushName != "wx_hair_01")
			throw "Unequipping armor/helmet did not restore cloth torso & full untucked hair!";
		if (dirtyCounter <= prevDirty)
			throw "syncActorHandheldAndArmor did not mark actor dirty!";

		::logInfo("[WX-SELFTEST] Verified C++ .brush registration, updateVariant persistence & live actor equip/unequip sprite sync");
	});

	// Verify 16 Standalone Wuxia Flying Projectiles (`wx_projectiles_0.brush` & `::Wuxia.Projectiles`)
	check("Standalone Wuxia Flying Projectiles: 16 ::Const.ProjectileType brushes, weapons, manuals & skills", function() {
		if (::Wuxia.Projectiles.RegisteredCount != 16)
			throw "Expected 16 registered Wuxia projectiles, got " + ::Wuxia.Projectiles.RegisteredCount;

		foreach (pid in ::Wuxia.Config.ProjectileOrder)
		{
			local def = ::Wuxia.Config.Projectiles[pid];
			if (!(def.Key in ::Const.ProjectileType))
				throw "Missing ::Const.ProjectileType." + def.Key;
			local tIdx = ::Const.ProjectileType[def.Key];
			if (::Wuxia.Projectiles.getRegisteredSprite(tIdx) != def.Brush)
				throw "ProjectileSprite mismatch for " + pid + ": expected " + def.Brush + ", got " + ::Wuxia.Projectiles.getRegisteredSprite(tIdx);
		}

		// Check weapon & manual resolution on mock actor (use mutable table ref for Squirrel 3.0 closure!)
		local eqProj = { main = null };
		local cProj = ::new("scripts/skills/special/wx_martial_container");
		local pActorRef = { ref = null };
		local pItems = { function getItemAtSlot( _s ) { return _s == ::Const.ItemSlot.Mainhand ? eqProj.main : null; } };
		local pSkills = {
			function getActor() { return pActorRef.ref; },
			function getSkillByID( _id ) { return _id == "special.wx_martial_container" ? cProj : null; }
		};
		cProj.setContainer(pSkills);
		local pActor = {
			m = {},
			function getItems() { return pItems; },
			function getSkills() { return pSkills; }
		};
		pActorRef.ref = pActor;

		local dummyThrow = ::new("scripts/skills/actives/throw_javelin");
		eqProj.main = ::new("scripts/items/weapons/oriental/nomad_sling");
		if (::Wuxia.Projectiles.resolveProjectileID(::new("scripts/skills/actives/sling_stone_skill"), pActor) != "feihuangshi")
			throw "Sling did not resolve to feihuangshi";

		eqProj.main = ::new("scripts/items/weapons/named/wx_relic_feidaonang");
		if (::Wuxia.Projectiles.resolveProjectileID(dummyThrow, pActor) != "liuyefeidao")
			throw "Feidaonang did not resolve to liuyefeidao";

		eqProj.main = ::new("scripts/items/weapons/javelin");
		cProj.m.Slots[3].ManualID = "wx_manual_xiushou"; cProj.m.Slots[3].Tier = 1;
		if (::Wuxia.Projectiles.resolveProjectileID(dummyThrow, pActor) != "xiujian")
			throw "Xiushou manual did not upgrade dart to xiujian";

		cProj.m.Slots[1].ManualID = "wx_manual_tangmen_guanyin_lei"; cProj.m.Slots[1].Tier = 1;
		if (::Wuxia.Projectiles.resolveProjectileID(dummyThrow, pActor) != "kongqueling")
			throw "Tangmen Guanyin Lei did not upgrade dart to kongqueling";
		if (::Wuxia.Projectiles.resolveProjectileID(::new("scripts/skills/actives/wx_throwing_rain"), pActor) != "kongqueling")
			throw "Tangmen Guanyin Lei did not upgrade wx_throwing_rain to kongqueling";

		eqProj.main = ::new("scripts/items/weapons/oriental/handgonne");
		if (::Wuxia.Projectiles.resolveProjectileID(::new("scripts/skills/actives/fire_handgonne_skill"), pActor) != "huochongdan")
			throw "Handgonne did not resolve to huochongdan";

		eqProj.main = ::new("scripts/items/weapons/light_crossbow");
		if (::Wuxia.Projectiles.resolveProjectileID(::new("scripts/skills/actives/shoot_bolt"), pActor) != "xiujian")
			throw "Light crossbow did not resolve to xiujian";

		foreach (rSk in ["wx_throwing_rain", "wx_throw_fan", "wx_throw_duzhen", "wx_throw_pilidan", "wx_smoke_cast", "wx_bow_snipe", "wx_bow_liuxing", "wx_crossbow_shenji"])
		{
			local skObj = ::new("scripts/skills/actives/" + rSk);
			if (!skObj.m.IsShowingProjectile || skObj.m.ProjectileType <= 0)
				throw "Ranged Wuxia skill missing standalone projectile config: " + rSk;
		}
		::logInfo("[WX-SELFTEST] Verified 16 Standalone Wuxia Flying Projectiles (wx_projectiles_0.brush)");
	});

	// Stage 3 (`3_characters`): Verify 8-Layer 1000-Faces Paperdoll, Multi-Tone Hair/Beard, 16 Back Gear, Armor Upgrades, Safe Death Restore & All 50 Enemy Busts
	check("Stage 3 千人千面: 8-layer paperdoll, 4 hair tones, 16 back gear, Schema v4, safe death restore & 50 enemy busts", function() {
		local cfg = ::Wuxia.Config.Appearance;
		if (cfg.FaceLabels.len() != 49 || cfg.HairLabels.len() != 25 || cfg.HairTones.len() != 4 || cfg.BeardLabels.len() != 25 || cfg.ScarLabels.len() != 13 || cfg.BackLabels.len() != 17)
			throw "Appearance config table length mismatch";

		if ("doesBrushExist" in getroottable())
		{
			for (local fi = 1; fi <= 48; fi = ++fi)
			{
				local fb = "wx_head_" + ::Wuxia.Appearance.pad2(fi);
				if (!::doesBrushExist(fb)) throw "Missing face brush: " + fb;
			}
			for (local hi = 1; hi <= 24; hi = ++hi)
			{
				local hp = ::Wuxia.Appearance.pad2(hi);
				foreach (tn in cfg.HairTones)
				{
					if (!::doesBrushExist("wx_hair_" + hp + tn.Suffix)) throw "Missing hair tone brush: wx_hair_" + hp + tn.Suffix;
					if (!::doesBrushExist("wx_hair_" + hp + "_tucked" + tn.Suffix)) throw "Missing tucked hair tone brush: wx_hair_" + hp + "_tucked" + tn.Suffix;
					if (!::doesBrushExist("wx_beard_" + hp + tn.Suffix)) throw "Missing beard tone brush: wx_beard_" + hp + tn.Suffix;
				}
			}
			for (local bki = 1; bki <= 16; bki = ++bki)
			{
				local bb = "wx_back_" + ::Wuxia.Appearance.pad2(bki);
				if (!::doesBrushExist(bb)) throw "Missing back gear brush: " + bb;
			}
			foreach (chHat in ["wx_char_hat_bamboo", "wx_char_hat_topknot", "wx_char_hat_taoist", "wx_char_hat_helm_fengchi"])
			{
				if (!::doesBrushExist(chHat + "_front") || !::doesBrushExist(chHat + "_back"))
					throw "Missing boolean hat pair for " + chHat;
			}
			foreach (eKey, pool in cfg.EnemyEntityBustMap)
			{
				foreach (eb in pool)
					if (!::doesBrushExist(eb)) throw "Missing enemy bust brush for " + eKey + ": " + eb;
			}
		}

		// SchemaVersion = 4 round-trip serialization (`HairToneIdx` & `BackIdx`)
		local buf4 = [];
		local stream4 = {
			buf = buf4,
			function getMetaData() { return { function getVersion() { return 66; } }; },
			function writeU8(v) { this.buf.push(v); },
			function writeI8(v) { this.buf.push(v); },
			function writeU16(v) { this.buf.push(v); },
			function writeI16(v) { this.buf.push(v); },
			function writeU32(v) { this.buf.push(v); },
			function writeI32(v) { this.buf.push(v); },
			function writeF32(v) { this.buf.push(v); },
			function writeBool(v) { this.buf.push(v); },
			function writeString(v) { this.buf.push(v); },
			function readU8() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readI8() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readU16() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readI16() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readU32() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readI32() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readF32() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readBool() { local v = this.buf[0]; this.buf.remove(0); return v; },
			function readString() { local v = this.buf[0]; this.buf.remove(0); return v; }
		};
		local cOut = ::new("scripts/skills/special/wx_martial_container");
		cOut.m.FaceIdx     = 15;
		cOut.m.HairIdx     = 9;
		cOut.m.HairToneIdx = 3;
		cOut.m.BeardIdx    = 14;
		cOut.m.ScarIdx     = 4;
		cOut.m.BackIdx     = 9;
		cOut.onSerialize(stream4);

		local cIn = ::new("scripts/skills/special/wx_martial_container");
		cIn.onDeserialize(stream4);
		if (cIn.m.SchemaVersion != 4 || cIn.m.HairToneIdx != 3 || cIn.m.BackIdx != 9 || cIn.m.FaceIdx != 15)
			throw "SchemaVersion 4 appearance round-trip failed";

		// Verify 8-layer rendering: hair tone + back sword-box + permanent injury eyepatch + armor_upgrade override + safe death restore!
		local mkSpr = function( _init = "" ) {
			return {
				BrushName = _init,
				HasBrush  = (_init != ""),
				Visible   = (_init != ""),
				Color     = null,
				function setBrush( _n ) { this.BrushName = _n; this.HasBrush = (_n != ""); },
				function resetBrush() { this.BrushName = ""; this.HasBrush = false; },
				function getBrush() { local n = this.BrushName; return { Name = n }; }
			};
		};
		local sp = {
			body                = mkSpr("bust_naked_body_01"),
			armor               = mkSpr("bust_body_01"),
			surcoat             = mkSpr(""),
			tattoo_body         = mkSpr(""),
			armor_upgrade_back  = mkSpr(""),
			armor_upgrade_front = mkSpr(""),
			head                = mkSpr("bust_head_01"),
			tattoo_head         = mkSpr(""),
			injury              = mkSpr("bust_head_injury_01"),
			permanent_injury_1  = mkSpr("permanent_injury_01"),
			beard               = mkSpr(""),
			beard_top           = mkSpr(""),
			hair                = mkSpr("hair_black_01"),
			helmet              = mkSpr(""),
			helmet_damage       = mkSpr(""),
			dirt                = mkSpr(""),
			injury_body         = mkSpr("")
		};
		local eqHero = { body = null, head = null };
		local hero = {
			m = {
				WX_TempAppearance = { FaceIdx = 9, HairIdx = 9, HairToneIdx = 3, BeardIdx = 14, ScarIdx = 0, BackIdx = 4 }
			},
			function getID() { return 901; },
			function getNameOnly() { return "叶孤城"; },
			function isAlive() { return true; },
			function getFlags() { return { function has(_f) { return false; } }; },
			function getBackground() { return { function getID() { return "background.swordmaster"; } }; },
			function getSkills() {
				return {
					function getSkillByID(_id) { return null; },
					function hasSkill(_id) { return _id == "injury.missing_eye"; }
				};
			},
			function hasSprite(_k) { return (_k in sp); },
			function getSprite(_k) { return sp[_k]; },
			function getItems() {
				return {
					function getItemAtSlot(_s) {
						if (_s == ::Const.ItemSlot.Body) return eqHero.body;
						if (_s == ::Const.ItemSlot.Head) return eqHero.head;
						return null;
					}
				};
			},
			function setDirty(_b) {}
		};

		eqHero.head = ::new("scripts/items/helmets/hunters_hat");
		eqHero.head.getIcon();
		::Wuxia.Appearance.refreshActorSprites(hero);

		if (sp.body.BrushName != "wx_char_robe_swordsman")
			throw "Unarmored swordmaster did not wear wx_char_robe_swordsman: " + sp.body.BrushName;
		if (sp.surcoat.Visible || sp.tattoo_body.Visible)
			throw "Jianghu back ornaments were not suppressed on character surcoat/tattoo_body";
		if (sp.armor_upgrade_back.BrushName != "wx_char_hat_bamboo_back" || sp.helmet.BrushName != "wx_char_hat_bamboo_front")
			throw "Wanderer bamboo hat did not split into _back and _front";
		if (sp.hair.BrushName != "wx_hair_09_tucked_white" || sp.beard.BrushName != "wx_beard_14_white")
			throw "Multi-tone tucked hair / beard mismatch: " + sp.hair.BrushName + " / " + sp.beard.BrushName;
		if (sp.tattoo_head.BrushName != "wx_scar_04" || !sp.tattoo_head.Visible || sp.permanent_injury_1.Visible)
			throw "Permanent injury.missing_eye did not map to wx_scar_04 eyepatch & hide vanilla overlay";

		// Female heroine step locks beard to 0
		local femLbl = ::Wuxia.Appearance.stepAppearance(hero, "random_fem", 1);
		if (!femLbl.isFemale || femLbl.beardIdx != 0 || sp.beard.Visible)
			throw "Female heroine allowed visible beard";

		// Armor upgrade mapping & paperdoll priority
		local pelt = ::new("scripts/items/armor_upgrades/direwolf_pelt_upgrade");
		pelt.getIcon();
		if (!("WX_BackBrush" in pelt.m) || pelt.m.WX_BackBrush != "wx_back_03" || pelt.getIcon().find("wx_back_03") == null)
			throw "Direwolf pelt upgrade did not map to wx_back_03";

		// Safe death restore prevents missing `wx_*_dead` brushes!
		::Wuxia.Appearance.restoreVanillaBrushesForDeath(hero);
		if (sp.body.BrushName != "bust_naked_body_01" || sp.head.BrushName != "bust_head_01" || sp.surcoat.HasBrush || sp.hair.HasBrush)
			throw "restoreVanillaBrushesForDeath left wx_* brushes on corpse sprites";

		::logInfo("[WX-SELFTEST] Verified Stage 3 千人千面 (8-layer paperdoll, 4 hair tones, 16 back gear, Schema v4 & 50 enemy busts)");
	});

	// Stage 6 (Row 4): Verify Chinese Settlements, Sect Mountain Gates, 32 World Figurines & 16 Vertical War Banners
	check("Stage 6 Chinese Settlements, 14 Town Shops, 32 World Chess Pieces & 16 Vertical War Standards", function() {
		if (::Wuxia.WorldVisuals.RegisteredBanners != 12 || ::Const.PlayerBanners[0] != "banner_51")
			throw "PlayerBanners missing Wuxia vertical banners at head";
		for (local b = 51; b <= 62; b = ++b)
		{
			if (::Const.PlayerBanners.find("banner_" + b) == null)
				throw "Missing banner_" + b + " in ::Const.PlayerBanners";
		}

		// Verify player_banner & legacy BannerID normalization (1..34 -> 51..62)
		local pb = ::new("scripts/items/tools/player_banner");
		pb.setVariant(51);
		if (pb.m.Variant != 51 || pb.getIconLarge() != "weapons/banner/banner_51.png" || pb.getIcon() != "weapons/banner/banner_51_70x70.png")
			throw "player_banner variant 51 icon mismatch: " + pb.getIconLarge();
		pb.setVariant(5);
		if (pb.m.Variant != 55 || pb.getName() != "镇团聚义竖幅大纛")
			throw "player_banner legacy variant normalization failed: " + pb.m.Variant;

		local fb = ::new("scripts/items/tools/faction_banner");
		if (fb.getName() != "藩镇帅字牙旗")
			throw "faction_banner Chinese name mismatch: " + fb.getName();

		// Verify all 14 town shop buildings remap onto `ui/settlements/wx_bldg_*`
		local bldgScripts = [
			"marketplace_building", "tavern_building", "temple_building", "weaponsmith_building",
			"armorsmith_building", "fletcher_building", "training_hall_building", "taxidermist_building",
			"alchemist_building", "arena_building", "port_building", "barber_building", "kennel_building"
		];
		foreach (bs in bldgScripts)
		{
			local bObj = ::new("scripts/entity/world/settlements/buildings/" + bs);
			bObj.WX_ApplyBuildingVisuals();
			if (bObj.m.UIImage.find("ui/settlements/wx_bldg_") != 0 || ::Wuxia.WorldVisuals.isAsciiName(bObj.m.Name))
				throw "Town building remap failed on " + bs + ": " + bObj.m.UIImage;
		}
		if ("doesBrushExist" in getroottable())
		{
			foreach (bId in [
				"wx_set_village_01", "wx_set_town_02", "wx_set_prefecture_03",
				"wx_set_outpost_01", "wx_set_garrison_02", "wx_set_citadel_03",
				"wx_set_oasis_city_01", "wx_set_sect_mountain", "wx_set_sect_monastery", "wx_set_water_market",
				"wx_houses_01_01", "wx_houses_03_02", "wx_houses_04_01", "wx_att_watchtower", "wx_att_sect_dojo",
				"wx_camp_01", "wx_ship_junk_01",
				"wx_fig_player_01", "wx_fig_player_03", "wx_cart_escort_01", "wx_cart_camel_02",
				"wx_fig_sect_sword", "wx_fig_sect_monk", "wx_fig_garrison_general", "wx_fig_shenji_army",
				"wx_fig_wudu", "wx_fig_yaoren", "wx_fig_tomb_guard", "wx_fig_xiangxi_corpse",
				"wx_fig_beast_zhuyan", "wx_fig_beast_feiyi", "wx_fig_beast_yaomei",
				"banner_51", "banner_62", "wx_fbanner_noble_01", "wx_fbanner_outlaw_01",
				"player_banner_51", "player_banner_51_shaft", "wx_faction_banner_01", "wx_faction_banner_shaft"
			])
			{
				if (!::doesBrushExist(bId))
					throw "Missing C++ brush in Stage 6 atlas: " + bId;
			}
		}
		if (::Wuxia.WorldVisuals.MappedTerrainCount < 14)
			throw "TerrainSettlementImages landscape remap incomplete: " + ::Wuxia.WorldVisuals.MappedTerrainCount;

		// Verify world party figurine & faction banner mappings across caravans, armies, sects & Shan Hai beasts
		local samplePartyMap = {
			cart_01             = "wx_cart_escort_01",
			cart_03             = "wx_cart_camel_02",
			ship_03             = "wx_ship_junk_01",
			figure_noble_01_01  = "wx_fig_garrison_foot",
			figure_noble_03_05  = "wx_fig_garrison_general",
			figure_southern_01  = "wx_fig_shenji_army",
			figure_bandit_02    = "wx_fig_bandit",
			figure_goblin_01    = "wx_fig_wudu",
			figure_orc_03       = "wx_fig_yaoren",
			figure_wildman_02   = "wx_fig_northern_warband",
			figure_skeleton_01  = "wx_fig_tomb_guard",
			figure_necromancer_01 = "wx_fig_xiangxi_corpse",
			figure_unhold_01    = "wx_fig_beast_zhuyan",
			figure_lindwurm_01  = "wx_fig_beast_feiyi",
			figure_spider_01    = "wx_fig_beast_chizhu",
			figure_werewolf_01  = "wx_fig_beast_tiangou",
			figure_hyena_01     = "wx_fig_beast_gudiao",
			figure_serpent_01   = "wx_fig_beast_bashe",
			figure_hexe_01      = "wx_fig_beast_yaomei",
			figure_schrat_01    = "wx_fig_beast_jianmu"
		};
		foreach (srcBrush, expected in samplePartyMap)
		{
			local got = ::Wuxia.WorldVisuals.mapPartyBodyBrush(srcBrush);
			if (got != expected)
				throw "Party figurine remap mismatch for " + srcBrush + ": got " + got + ", expected " + expected;
		}
		if (::Wuxia.WorldVisuals.mapWorldBannerBrush("banner_noble_02") != "wx_fbanner_noble_02"
			|| ::Wuxia.WorldVisuals.mapWorldBannerBrush("banner_bandits_03") != "wx_fbanner_outlaw_01"
			|| ::Wuxia.WorldVisuals.mapWorldBannerBrush("banner_03") != "banner_53")
			throw "World banner brush remap failed";

		foreach (sid, sect in ::Wuxia.Config.Sects)
		{
			if (!(sect.VendettaParty in ::Wuxia.Config.WorldVisuals.VendettaVisualMap))
				throw "Missing VendettaVisualMap entry for sect " + sid + " (" + sect.VendettaParty + ")";
		}
		::logInfo("[WX-SELFTEST] Verified Stage 6 Chinese Settlements, 14 Town Shops, 32 World Figurines & 16 Vertical War Standards");
	});

	// Stage 7 (`7_scenes`): Verify 32 Event Illustrations (`wx_ev_01..32`), Loading Scrolls, Wuxia Tips & 18 Campfire Retinue Followers
	check("Stage 7 奇遇插画与过场画卷: 32 event illustrations, 12 loading scrolls, Wuxia tips & 18 retinue followers", function() {
		if (!("Screens" in ::Wuxia))
			throw "::Wuxia.Screens table missing";
		::Wuxia.Screens.applyScreensAndTips();

		if (::Const.LoadingScreens.len() != 12 || ::Const.LoadingScreens[0].find("ui/screens/wx_") != 0)
			throw "::Const.LoadingScreens was not updated to 12 Wuxia scrolls";
		if (::Const.TipOfTheDay.len() < 16 || ::Const.TipOfTheDay[0].find("武学插槽") == null)
			throw "::Const.TipOfTheDay was not updated to Wuxia gameplay tips";

		// Check Retinue Followers (`m.Image` -> `ui/campfire/wx_*` & `getName()` -> Jianghu Chinese title)
		local followerChecks = [
			["alchemist_follower",      "ui/campfire/wx_alchemist_01",     "丹鼎方士"],
			["blacksmith_follower",     "ui/campfire/wx_blacksmith_01",    "百炼随匠"],
			["minstrel_follower",       "ui/campfire/wx_minstrel_01",      "盲眼琵琶客"],
			["bounty_hunter_follower",  "ui/campfire/wx_bounty_hunter_01", "六扇门快捕"],
			["drill_sergeant_follower", "ui/campfire/wx_drill_01",         "演武总教头"],
			["agent_follower",          "ui/campfire/wx_agent_01",         "玄衣密谍"]
		];
		foreach (fc in followerChecks)
		{
			local fObj = ::new("scripts/retinue/followers/" + fc[0]);
			local fName = fObj.getName();
			if (fObj.m.Image.find(fc[1]) != 0)
				throw "Follower " + fc[0] + " image mismatch: " + fObj.m.Image;
			if (fName != fc[2])
				throw "Follower " + fc[0] + " name mismatch: " + fName;
		}

		// Check custom Wuxia events & starting scenarios use `gfx/ui/events/wx_ev_*.png` with zero `event_XX.png`
		local evSamples = [
			["wx_event_sect_exchange",           "gfx/ui/events/wx_ev_01.png"],
			["wx_event_ghost_auction",           "gfx/ui/events/wx_ev_04.png"],
			["wx_event_grand_tournament",        "gfx/ui/events/wx_ev_05.png"],
			["wx_event_martial_wash_afterglow",  "gfx/ui/events/wx_ev_07.png"],
			["wx_event_weird_ancient_tomb_door", "gfx/ui/events/wx_ev_17.png"],
			["wx_event_shanhai_rumor",           "gfx/ui/events/wx_ev_21.png"]
		];
		foreach (es in evSamples)
		{
			local ev = ::new("scripts/events/events/" + es[0]);
			if (ev.m.Screens.len() == 0)
				throw "Event " + es[0] + " has empty Screens";
			local combined = "";
			foreach (sc in ev.m.Screens)
			{
				if ("start" in sc)
				{
					try { sc.start(ev); } catch (_e) {}
				}
				if ("Text" in sc && sc.Text != null)
					combined += sc.Text;
			}
			if (combined.find(es[1]) == null || combined.find("gfx/ui/events/event_") != null)
				throw "Event " + es[0] + " did not bind " + es[1];
		}

		local scStart = ::new("scripts/scenarios/world/wx_jianghu_start");
		if (scStart.m.Description.find("gfx/ui/events/wx_ev_06.png") == null || scStart.m.Description.find("gfx/ui/events/event_") != null)
			throw "Scenario wx_jianghu_start did not bind wx_ev_06.png";

		::logInfo("[WX-SELFTEST] Verified Stage 7 奇遇插画与过场画卷 (wx_ev_01..32, LoadingScrolls, Tips & 18 Campfire Followers)");
	});

	// Stage 8: Global Ming-Era Ebony, Xuan-Paper & Bronze UI Overhaul + 44-Sect Directory RPC + Cross-Screen Vault Sync
	check("Stage 8 全局明代乌木宣纸青铜 UI 体系、跨界面藏经阁馆藏同步与九州 44 门派名刺录", function() {
		::Wuxia.Library.resetFallback();
		::Wuxia.Library.addManual("wx_manual_qingfeng", 2);
		::Wuxia.Library.addPages("wx_manual_songtao", 2);

		local ownQf = ::Wuxia.Library.getOwnershipSummary("wx_manual_qingfeng");
		if (ownQf.bookCount != 2)
			throw "getOwnershipSummary bookCount mismatch: " + ownQf.bookCount;

		local dir = ::Wuxia.UI.buildSectRelationsDirectory();
		if (!dir.ok || dir.sects.len() < 44 || dir.regions.len() < 6)
			throw "buildSectRelationsDirectory returned incomplete payload: " + dir.sects.len();
		local firstSect = dir.sects[0];
		if (!("name" in firstSect) || !("manuals" in firstSect) || firstSect.manuals.len() < 5 || !("vaultBooks" in firstSect.manuals[0]))
			throw "Sect directory entry missing manuals vault metadata: " + firstSect.id;

		local mNew = ::new("scripts/items/misc/wx_manual_item");
		mNew.initManual("wx_manual_tuna");
		local ttNew = mNew.getTooltip();
		local foundNewTag = false;
		foreach (row in ttNew)
		{
			if (("text" in row) && row.text.find("未收录新篇") != null)
				foundNewTag = true;
		}
		if (!foundNewTag)
			throw "Unowned manual tooltip missing 未收录新篇 indicator";

		local mOwned = ::new("scripts/items/misc/wx_manual_item");
		mOwned.initManual("wx_manual_qingfeng");
		local ttOwned = mOwned.getTooltip();
		local foundOwnedTag = false;
		foreach (row2 in ttOwned)
		{
			if (("text" in row2) && row2.text.find("藏经阁存书：2 册") != null)
				foundOwnedTag = true;
		}
		if (!foundOwnedTag)
			throw "Owned manual tooltip missing live 藏经阁存书 count";

		::Wuxia.Library.resetFallback();
		::logInfo("[WX-SELFTEST] Verified Stage 8 Global Wuxia UI Overhaul, Cross-Screen Vault Tooltips & 44-Sect Directory (" + dir.sects.len() + " sects)");
	});

	check("Stage 9 Polish: Corpses, World Lead Busts, Hover Descriptions, Contracts, Ambitions & Road Events", function() {
		foreach (bName in [
			"wx_body_civ_01_dead",
			"wx_head_01_dead",
			"wx_char_hat_bamboo_front_dead",
			"wm_wx_body_civ_01",
			"wm_wx_head_01",
			"wm_wx_char_hat_bamboo_front"
		])
		{
			if (!::Wuxia.Appearance.brushExists(bName))
				throw "Missing compiled brush in C++ registry: " + bName;
		}

		local sw = ::new("scripts/items/weapons/arming_sword");
		if (sw.getName().find("剑") == null || sw.getDescription().find("百炼") == null)
			throw "Weapon Wuxia description not applied: " + sw.getDescription();

		local sh = ::new("scripts/items/shields/buckler_shield");
		if (sh.getDescription().find("藤牌") == null)
			throw "Shield Wuxia description not applied: " + sh.getDescription();

		local fol = ::new("scripts/retinue/followers/alchemist_follower");
		::Wuxia.Screens.applyFollowerVisuals(fol);
		if (fol.m.Name != "丹鼎方士" || fol.m.Description.find("炼丹房") == null)
			throw "Retinue follower Wuxia description not applied: " + fol.m.Name;

		local con = ::new("scripts/contracts/contracts/drive_away_bandits_contract");
		local conCaravan = ::new("scripts/contracts/contracts/escort_caravan_contract");
		local conPatrol = ::new("scripts/contracts/contracts/patrol_contract");
		if (con.getName() != "清剿绿林响马山寨" || conCaravan.getName() != "威远走镖护送商队" || conPatrol.getName() != "巡防州县千里官道")
			throw "Contract Wuxia title mismatch: " + con.getName();
		if (!::Wuxia.hasMember(con, "WX_PolishContractScreen"))
			throw "Lazy Modern Hooks bridge did not attach WX_PolishContractScreen to contract!";

		local nobleFac = ::new("scripts/factions/noble_faction");
		if (!::Wuxia.hasMember(nobleFac, "WX_ApplyNobleLore"))
			throw "Lazy Modern Hooks bridge did not attach WX_ApplyNobleLore to noble_faction!";

		local allContractFiles = ::IO.enumerateFiles("scripts/contracts/contracts");
		foreach (cPath in allContractFiles)
		{
			local leaf = split(cPath, "/").top();
			local probeContract = { m = { Type = "" }, ClassName = leaf };
			if (::Wuxia.Contracts.resolveSpec(probeContract, cPath) == null)
				throw "Unmapped contract spec for: " + cPath;
		}

		local ambStd = ::new("scripts/ambitions/ambitions/battle_standard_ambition");
		local ambSgt = ::new("scripts/ambitions/ambitions/sergeant_ambition");
		local ambHam = ::new("scripts/ambitions/ambitions/hammer_mastery_ambition");
		if (ambStd.getButtonText().find("大纛") == null || ambSgt.getButtonTooltip().find("聚义令") == null || ambHam.getButtonText().find("锤杖") == null)
			throw "Ambition Wuxia localization mismatch: " + ambStd.getButtonText();

		foreach (evName in [
			"wx_event_road_tea_shed",
			"wx_event_road_wounded_courier",
			"wx_event_road_sword_stone",
			"wx_event_road_herbal_cliff",
			"wx_event_road_wandering_blacksmith",
			"wx_event_road_broken_shrine",
			"wx_event_road_escort_campfire"
		])
		{
			local ev = ::new("scripts/events/events/" + evName);
			if (ev == null || ev.m.Screens.len() < 2)
				throw "Road event failed to instantiate: " + evName;
		}

		::logInfo("[WX-SELFTEST] Verified Stage 9 Corpses, World Busts, Hover Descriptions, 50 Contracts, 48 Ambitions & Road Events");
	});

	// Stage 10: Verify 72/72 Strictly Unique 4-Frame Action Sequences (`wx_anim_01..72`), All 32 Qi-Auras (`wx_vfx_01..32`),
	// 16 Hand-Painted Dharma/Array FX (`wx_fx_*`), & Basic Weapon Qi-Aura Practitioner Integration!
	check("Stage 10 招式气芒与72式零重复动作特效全接入校验 (wx_effects_0..1.brush)", function() {
		if (!("VFX" in ::Wuxia) || !("SkillChoreo" in ::Wuxia.VFX))
			throw "::Wuxia.VFX.SkillChoreo missing";

		if ("doesBrushExist" in getroottable())
		{
			// 1. All 32 hand-painted Qi-Auras (`wx_vfx_01..32`) must exist in C++ brush registry
			for (local vi = 1; vi <= 32; vi = ++vi)
			{
				local vId = "wx_vfx_" + (vi < 10 ? "0" : "") + vi;
				if (!::doesBrushExist(vId))
					throw "Missing Qi-Aura brush in C++ registry: " + vId;
			}
			// 2. All 72 x 4 = 288 unique 4-frame action sequence sprites (`wx_anim_01..72_f1..f4`) must exist!
			for (local ai = 1; ai <= 72; ai = ++ai)
			{
				local aBase = "wx_anim_" + (ai < 10 ? "0" : "") + ai;
				for (local fi = 1; fi <= 4; fi = ++fi)
				{
					local fBrush = aBase + "_f" + fi;
					if (!::doesBrushExist(fBrush))
						throw "Missing 4-frame action brush in C++ registry: " + fBrush;
				}
			}
			// 3. All 16 hand-painted Dharma/Array FX elements (`wx_fx_*`) must exist!
			foreach (fxId in [
				"wx_fx_bagua", "wx_fx_golden_bell", "wx_fx_dragon_head", "wx_fx_sword_phantom",
				"wx_fx_ice_spikes", "wx_fx_blood_orb", "wx_fx_sonic_ring", "wx_fx_gold_needle",
				"wx_fx_whip_arc", "wx_fx_thunder_bolt", "wx_fx_earth_fissure", "wx_fx_banner_crest",
				"wx_fx_poison_skull", "wx_fx_lotus_seal", "wx_fx_buddha_palm", "wx_fx_claw_slash"
			])
			{
				if (!::doesBrushExist(fxId))
					throw "Missing hand-painted FX element brush in C++ registry: " + fxId;
			}
		}

		// 4. Verify 72/72 active skills have strictly unique AnimID, Mode, Label & valid QiAura + SigFx!
		local seenAnimIDs = {};
		local seenModes   = {};
		local seenLabels  = {};
		local totalChoreo = 0;
		foreach (skPath in ::IO.enumerateFiles("scripts/skills/actives"))
		{
			local leaf = split(skPath, "/").top();
			if (leaf == "wx_move_base" || leaf.find("wx_") != 0) continue;
			local skObj = ::new(skPath);
			if (!(::Wuxia.hasMember(skObj.m, "WX_ChoreoID")) || !(skObj.m.WX_ChoreoID in ::Wuxia.VFX.SkillChoreo))
				throw "Active skill missing SkillChoreo entry: " + leaf;
			if (!(::Wuxia.hasMember(skObj.m, "WX_VfxBrush")) || skObj.m.WX_VfxBrush == null || skObj.m.WX_VfxBrush == "")
				throw "Active skill missing WX_VfxBrush: " + leaf;

			local spec = ::Wuxia.VFX.SkillChoreo[skObj.m.WX_ChoreoID];
			local lbl = spec[0];
			local animId = spec[1];
			local mode = spec[2];
			if (skObj.m.WX_AnimID != animId)
				throw "Active skill WX_AnimID mismatch vs SkillChoreo for " + leaf + ": " + skObj.m.WX_AnimID + " != " + animId;
			if (animId in seenAnimIDs)
				throw "Duplicate 4-frame AnimID across skills: " + animId + " (" + seenAnimIDs[animId] + " vs " + leaf + ")";
			if (mode in seenModes)
				throw "Duplicate choreography Mode across skills: " + mode + " (" + seenModes[mode] + " vs " + leaf + ")";
			if (lbl in seenLabels)
				throw "Duplicate choreography Label across skills: " + lbl;

			seenAnimIDs[animId] <- leaf;
			seenModes[mode]     <- leaf;
			seenLabels[lbl]     <- leaf;
			totalChoreo += 1;
		}
		if (totalChoreo != 72)
			throw "Expected 72 active skills in Stage 10 VFX audit, got " + totalChoreo;

		// 5. Verify basic weapon attack Qi-Aura resolver for martial practitioners
		local cTest = ::new("scripts/skills/special/wx_martial_container");
		cTest.m.Slots[0].ManualID = "wx_manual_chanzong_zuo";
		cTest.m.Slots[0].Tier = 2;
		local swordItem = ::new("scripts/items/weapons/arming_sword");
		local slashSkill = ::new("scripts/skills/actives/slash");
		local mockPractitioner = {
			function getItems() { return { function getItemAtSlot(_s) { return _s == ::Const.ItemSlot.Mainhand ? swordItem : null; } }; },
			function getSkills() { return { function getSkillByID(_id) { return _id == "special.wx_martial_container" ? cTest : null; } }; }
		};
		local auraGot = ::Wuxia.VFX.resolvePractitionerWeaponVfx(slashSkill, mockPractitioner);
		if (auraGot != "wx_vfx_02")
			throw "Yang-Neigong sword slash did not resolve to wx_vfx_02 fiery aura: " + auraGot;

		::logInfo("[WX-SELFTEST] Verified Stage 10 招式气芒与动作特效: 72/72 zero-duplicate 4-frame sequences (288 frames), 32 Qi-Auras, 16 Dharma FX & Practitioner Weapon Auras");
	});

	// Stage 11: Deepened Alchemy System — 31 Pills, Zero-Slot Herb/Core Cabinet, 28 Bagua Cauldron Formulas, 8 Town Pill Blueprints & +25% ArmorPen Cap
	check("Stage 11 百草药柜·八卦丹炉·31灵丹·续脉造化与丹毒防膨胀校验", function() {
		if (!("Alchemy" in ::Wuxia) || !("Cabinet" in ::Wuxia.Alchemy))
			throw "::Wuxia.Alchemy.Cabinet missing";

		// 1. Verify all 31 registered Pills & all 8 new Town Pill Blueprints
		local totalPills = 0;
		foreach (pid, pdef in ::Wuxia.Config.Pills)
		{
			totalPills += 1;
			local pi = ::new("scripts/items/misc/wx_pill_item");
			pi.initPill(pid);
			if (pi.getName() != pdef.Name || pi.getTooltip().len() < 3)
				throw "Pill failed validation: " + pid;
		}
		if (totalPills < 31)
			throw "Expected >= 31 deepened pills, got " + totalPills;

		foreach (bpName in [
			"wx_bp_pill_shengsheng", "wx_bp_pill_duanxu", "wx_bp_pill_zijin_xisui", "wx_bp_pill_yijin_wan",
			"wx_bp_pill_wangchen", "wx_bp_pill_bihuo", "wx_bp_pill_yuji", "wx_bp_pill_fengmo"
		])
		{
			local bp = ::new("scripts/crafting/blueprints/" + bpName);
			if (bp == null || bp.m.PreviewCraftable == null)
				throw "Alchemy blueprint failed: " + bpName;
		}

		// 2. Verify Universal Classifier & Exact Cabinet Reconstruction across Herbs, Cores & Beast Materials
		::Wuxia.Alchemy.resetFallback();
		if ("Herbs" in ::Wuxia.Config)
		{
			foreach (hid, _hd in ::Wuxia.Config.Herbs)
			{
				local hObj = ::new("scripts/items/misc/wx_herb_base");
				hObj.initHerb(hid);
				local hMeta = ::Wuxia.Alchemy.classifyItem(hObj);
				if (hMeta == null || hMeta.Kind != "herb" || hMeta.Potency < 3)
					throw "Herb failed alchemy classification: " + hid + " (id=" + hObj.getID() + ", name=" + hObj.getName() + ", meta=" + (hMeta == null ? "null" : (hMeta.Kind + "/" + hMeta.Potency + "/" + hMeta.Nature)) + ")";
				local rebuilt = ::Wuxia.Alchemy.instantiateByCabinetKey(hMeta.Key, hMeta.Script, hMeta.SubID);
				if (rebuilt == null || rebuilt.getName() == "")
					throw "Herb failed Cabinet reconstruction: " + hid;
			}
		}

		local coreProbe = ::new("scripts/items/misc/wx_core_yinglong");
		local coreMeta = ::Wuxia.Alchemy.classifyItem(coreProbe);
		if (coreMeta == null || coreMeta.Kind != "core" || coreMeta.Potency < 5)
			throw "Yinglong core failed alchemy classification";

		// 3. Verify Bagua Cauldron Formula Registry & Smart Auto-Fill / Brew Preview
		::Wuxia.Alchemy.Cabinet.addCount("core:wx_core_yinglong", 2, coreMeta.Script, coreMeta.SubID);
		::Wuxia.Alchemy.Cabinet.addCount("herb:wx_marrow_herb", 2, "scripts/items/misc/wx_marrow_herb", "");
		local autoSlots = ::Wuxia.Alchemy.autoPickIngredients("f_zijin_xisui");
		local brewPv = ::Wuxia.Alchemy.previewBrew("f_zijin_xisui", autoSlots);
		if (!brewPv.Ok || brewPv.PillID != "wx_pill_zijin_xisui")
			throw "Bagua Cauldron f_zijin_xisui preview failed: " + ("Reason" in brewPv ? brewPv.Reason : "unknown");
		::Wuxia.Alchemy.resetFallback();

		// 4. Verify 疯魔燃血丸 strictly respects global +25% extra Armor-Pen ceiling (AGENTS.md) & Dan-Toxin penalty
		local buffEx = ::new("scripts/skills/effects/wx_pill_battle_buff");
		buffEx.addPillBuff("buff_bihuo");
		buffEx.addPillBuff("buff_fengmo");
		local propEx = ::Const.CharacterProperties.getClone();
		propEx.DamageDirectAdd = 0.20;
		buffEx.onUpdate(propEx);
		if (propEx.DamageDirectAdd > 0.2501 || propEx.DamageDirectAdd < 0.2499)
			throw "buff_fengmo violated +25% extra armor pen cap: " + propEx.DamageDirectAdd;

		buffEx.applyDanToxinOverload();
		local propTox = ::Const.CharacterProperties.getClone();
		local stamBase = propTox.Stamina;
		buffEx.onUpdate(propTox);
		if (propTox.Stamina != stamBase - 15)
			throw "Dan-Toxin overload did not apply -15 Stamina penalty";

		local graceSk = ::new("scripts/skills/effects/wx_wangchen_grace");
		if (graceSk.getTooltip().len() < 3)
			throw "wx_wangchen_grace tooltip invalid";

		::logInfo("[WX-SELFTEST] Verified Stage 11 百草药柜·八卦丹炉: " + totalPills + " Pills, " + ::Wuxia.Config.Alchemy.Formulas.len() + " Cauldron Formulas, 8 New Blueprints & 25% ArmorPen/Dan-Toxin Guardrails");
	});

	// Stage 12: Grand Shan Hai Treasury Expansion — 40 ShanHaiGear, 59 RelicWeapons (22 ShanHai), 96 Neidan Cores, 17 Herbs & All Crafting Blueprints
	check("Stage 12 山海百工宝库大扩充：40宝甲神盾奇佩·59神兵(22山海)·96妖丹·17本草·全蓝图校验", function() {
		// 1. Verify 40 ShanHaiGear items (14 armors, 8 helmets, 6 famed shields, 12 accessories) + AGENTS.md anti-bloat caps
		local cntArmor = 0, cntHelm = 0, cntShield = 0, cntAcc = 0;
		foreach (gid, gcfg in ::Wuxia.Config.ShanHaiGear)
		{
			local gPath = gcfg.Kind == "armor" ? ("scripts/items/armor/named/" + gid)
				: (gcfg.Kind == "helmet" ? ("scripts/items/helmets/named/" + gid)
				: (gcfg.Kind == "shield" ? ("scripts/items/shields/named/" + gid)
				: ("scripts/items/accessory/" + gid)));
			local gItem = ::new(gPath);
			if (gItem == null || gItem.getName() != gcfg.Name || gItem.m.Icon == "")
				throw "ShanHaiGear invalid: " + gid;
			gItem.getTooltip();
			if (gcfg.Kind == "armor") cntArmor += 1;
			else if (gcfg.Kind == "helmet") cntHelm += 1;
			else if (gcfg.Kind == "shield")
			{
				cntShield += 1;
				if (!gItem.isItemType(::Const.Items.ItemType.Named) || gItem.m.Condition < gcfg.MinCondition)
					throw "ShanHai famed shield missing Named flag or Condition floor: " + gid;
			}
			else if (gcfg.Kind == "accessory")
			{
				cntAcc += 1;
				local pBase = ::Const.CharacterProperties.getClone();
				local ms0 = pBase.MeleeSkill, rs0 = pBase.RangedSkill, md0 = pBase.MeleeDefense, rd0 = pBase.RangedDefense;
				gItem.onUpdateProperties(pBase);
				if (pBase.MeleeSkill != ms0 || pBase.RangedSkill != rs0 || (pBase.MeleeDefense - md0) > 5 || (pBase.RangedDefense - rd0) > 5)
					throw "ShanHai accessory violated AGENTS.md stat cap: " + gid;
			}
		}
		if (cntArmor != 14 || cntHelm != 8 || cntShield != 6 || cntAcc != 12)
			throw "Expected 14/8/6/12 ShanHaiGear breakdown, got " + cntArmor + "/" + cntHelm + "/" + cntShield + "/" + cntAcc;

		// 2. Verify 59 RelicWeapons (including 22 IsShanHai across all 13 weapon families & paired Fist Offhand block)
		local totalRelics = 0, shanhaiRelics = 0;
		foreach (rid, rcfg in ::Wuxia.Config.RelicWeapons)
		{
			totalRelics += 1;
			if (("IsShanHai" in rcfg) && rcfg.IsShanHai)
				shanhaiRelics += 1;
		}
		if (totalRelics != 59 || shanhaiRelics != 22)
			throw "Expected 59 total relics (22 ShanHai), got " + totalRelics + " (" + shanhaiRelics + " ShanHai)";

		local luwu = ::new("scripts/items/weapons/named/wx_relic_luwuzhao");
		if (luwu.m.BlockedSlotType != ::Const.ItemSlot.Offhand)
			throw "wx_relic_luwuzhao paired gauntlet did not block Offhand slot";
		local rndShRelic = ::Wuxia.Relics.createRandomShanHaiRelic();
		if (rndShRelic == null || rndShRelic.getID().find("weapon.wx_relic_") != 0)
			throw "createRandomShanHaiRelic returned invalid weapon";

		// 3. Verify all 96 ShanHaiCores (64 boss + 16 wild + 16 sovereign) & Affinity Resonance (+0 / +100 / +180)
		local coreTotal = 0, wildCnt = 0, sovCnt = 0;
		foreach (cid, ccfg in ::Wuxia.Config.ShanHaiCores)
		{
			coreTotal += 1;
			if (("TierGroup" in ccfg) && ccfg.TierGroup == "wild") wildCnt += 1;
			if (("TierGroup" in ccfg) && ccfg.TierGroup == "sovereign") sovCnt += 1;
			local cObj = ::new("scripts/items/misc/" + cid);
			if (cObj.getID() != "misc." + cid || cObj.getName() == "" || cObj.getTooltip().len() < 4)
				throw "ShanHaiCore failed instantiation/tooltip: " + cid;
			local cMeta = ::Wuxia.Alchemy.classifyItem(cObj);
			if (cMeta == null || cMeta.Kind != "core")
				throw "ShanHaiCore failed Alchemy classification: " + cid + " (id=" + cObj.getID() + ", meta=" + (cMeta == null ? "null" : cMeta.Kind) + ")";
		}
		if (coreTotal != 96 || wildCnt != 16 || sovCnt != 16)
			throw "Expected 96 cores (16 wild, 16 sovereign), got " + coreTotal + " (" + wildCnt + "/" + sovCnt + ")";

		local resNormal  = ::Wuxia.ShanHai.getCoreInfuseExp("wx_core_baihu", "wx_manual_tuna");            // mismatch -> +0
		local resLineage = ::Wuxia.ShanHai.getCoreInfuseExp("wx_core_baihu", "wx_manual_qingfeng");        // waigong -> +100
		local resShanHai = ::Wuxia.ShanHai.getCoreInfuseExp("wx_core_baihu", "wx_manual_shanhai_chiyou");// shanhai waigong -> +180
		if (resLineage - resNormal != 100 || resShanHai - resNormal != 180)
			throw "Core Affinity Resonance math mismatch: " + resNormal + " / " + resLineage + " / " + resShanHai;

		// 4. Verify all 17《山海本草》Herbs instantiate via dedicated item scripts & all Crafting Blueprints succeed
		local herbTotal = 0;
		foreach (hid, hcfg in ::Wuxia.Config.Herbs)
		{
			herbTotal += 1;
			local hItem = ::Wuxia.ShanHai.createHerbItem(hid);
			if (hItem == null || hItem.getID() != "misc." + hid || hItem.getTooltip().len() < 3)
				throw "Herb script failed: " + hid;
		}
		if (herbTotal != 17)
			throw "Expected 17 Spirit Herbs, got " + herbTotal;

		local bpFiles = ::IO.enumerateFiles("scripts/crafting/blueprints");
		local wxBpCount = 0;
		foreach (bpPath in bpFiles)
		{
			local leaf = split(bpPath, "/").top();
			if (leaf.find("wx_bp_") != 0) continue;
			wxBpCount += 1;
			local bp = ::new(bpPath);
			local comps = (bp != null && ::Wuxia.hasMember(bp.m, "PreviewComponents")) ? bp.m.PreviewComponents : [];
			if (bp == null || bp.m.PreviewCraftable == null || comps.len() == 0)
				throw "Blueprint invalid: " + bpPath;
		}
		if (wxBpCount < 85)
			throw "Expected >= 85 Wuxia Baigong & Alchemy blueprints, got " + wxBpCount;

		// 5. Verify new Paperdoll C++ Brushes exist in compiled atlases
		if ("doesBrushExist" in getroottable())
		{
			foreach (br in [
				"wx_armor_xuangui", "wx_armor_yinglong", "wx_armor_feilian",
				"wx_helm_kaiming_front", "wx_helm_chiyou_front", "wx_helm_jinwu_front",
				"shd_wx_shd_xuangui", "shd_wx_shd_yinglong",
				"arm_wx_relic_yinglongjian", "arm_wx_relic_luwuzhao", "arm_wx_relic_yingzhaogong", "arm_wx_relic_gudiaonu"
			])
			{
				if (!::doesBrushExist(br))
					throw "Missing C++ brush for Wave 63-69 item: " + br;
			}
		}

		::logInfo("[WX-SELFTEST] Verified Stage 12 Grand Shan Hai Treasury: 40 ShanHaiGear, 59 Relics (22 ShanHai), 96 Cores, 17 Herbs & " + wxBpCount + " Wuxia Blueprints");
	});

	// Stage 13: Monster-Hunter-Style Beast Loot, Forging Materials, Tier-A Beast Gear/Upgrades & 50 Shan-Hai Divine Passives
	check("Stage 13 猎妖采材·百工铸兵·山海神通全闭环校验：6异兽奇材·16百工兵甲镶件·50山海神通被动·药柜直炼", function() {
		// 1. Verify all 6 Forging Materials (`wx_mat_*`) instantiate, classify for Alchemy/Cabinet, and render tooltips
		local matCount = 0;
		foreach (mid, mcfg in ::Wuxia.Config.BeastMaterials)
		{
			matCount += 1;
			local mItem = ::new("scripts/items/misc/" + mid);
			if (mItem == null || mItem.getID() != "misc." + mid || !mItem.isItemType(::Const.Items.ItemType.Crafting))
				throw "BeastMaterial failed instantiation/ItemType: " + mid;
			if (mItem.getTooltip().len() < 3)
				throw "BeastMaterial tooltip invalid: " + mid;
			local mMeta = ::Wuxia.Alchemy.classifyItem(mItem);
			if (mMeta == null || mMeta.Kind != "trophy")
				throw "BeastMaterial failed Alchemy classification: " + mid + " (id=" + mItem.getID() + ", meta=" + (mMeta == null ? "null" : mMeta.Kind) + ")";
			local mRebuilt = ::Wuxia.Alchemy.instantiateByCabinetKey(mMeta.Key, mMeta.Script, mMeta.SubID);
			if (mRebuilt == null || mRebuilt.getID() != "misc." + mid)
				throw "BeastMaterial failed Cabinet reconstruction: " + mid;
		}
		if (matCount != 6) throw "Expected 6 BeastMaterials, got " + matCount;

		// 2. Verify all 64 ShanHaiBosses have valid BossBonusLoot (`Mat` + `Trophy` instantiate cleanly)
		foreach (_bid, bcfg in ::Wuxia.Config.ShanHaiBosses)
		{
			if (!(bcfg.Key in ::Wuxia.Config.BossBonusLoot))
				throw "ShanHaiBoss missing BossBonusLoot entry: " + bcfg.Key;
			local bl = ::Wuxia.Config.BossBonusLoot[bcfg.Key];
			local bMat = ::new("scripts/items/misc/" + bl.Mat);
			local bTr  = ::new("scripts/items/misc/" + bl.Trophy);
			if (bMat == null || bTr == null)
				throw "BossBonusLoot failed item instantiation for boss: " + bcfg.Key;
		}

		// 3. Verify all 16 Tier-A BeastGear items (`wx_beast_*` x12 + `wx_up_*` x4) instantiate, match weapon families, brushes & tooltips
		local beastGearCnt = 0;
		foreach (gid, gcfg in ::Wuxia.Config.BeastGear)
		{
			beastGearCnt += 1;
			local gObj = ::new(gcfg.Script);
			if (gObj == null || gObj.getName() != gcfg.Name || gObj.m.Icon == "")
				throw "BeastGear failed instantiation: " + gid;
			local tt = gObj.getTooltip();
			local hasSpiritText = false;
			foreach (row in tt)
			{
				if (("text" in row) && row.text != null && (row.text.find("【百工兽魄") != null || row.text.find("【百工镶缀】") != null))
					hasSpiritText = true;
			}
			if (!hasSpiritText)
				throw "BeastGear missing 百工兽魄/百工镶缀 tooltip line: " + gid;

			if (gcfg.Kind == "weapon")
			{
				if (!::Wuxia.CombatRules.matchesWeapon(gObj, [gcfg.Family]))
					throw "Beast weapon failed CombatRules.matchesWeapon(" + gcfg.Family + "): " + gid;
				if (gid == "wx_beast_fist" && gObj.m.BlockedSlotType != ::Const.ItemSlot.Offhand)
					throw "wx_beast_fist did not block Offhand slot";
				if (("doesBrushExist" in getroottable()) && !::doesBrushExist(gcfg.ArmBrush))
					throw "Missing weapon brush for " + gid + ": " + gcfg.ArmBrush;
			}
			else if (gcfg.Kind == "shield" && ("doesBrushExist" in getroottable()) && !::doesBrushExist(gcfg.ShieldBrush))
				throw "Missing shield brush for " + gid + ": " + gcfg.ShieldBrush;
			else if (gcfg.Kind == "armor" && ("doesBrushExist" in getroottable()) && !::doesBrushExist(gcfg.BodyBrush))
				throw "Missing armor brush for " + gid + ": " + gcfg.BodyBrush;
			else if (gcfg.Kind == "helmet" && ("doesBrushExist" in getroottable()) && !::doesBrushExist(gcfg.HatID + "_front"))
				throw "Missing helmet brush for " + gid + ": " + gcfg.HatID + "_front";
		}
		if (beastGearCnt != 16) throw "Expected 16 BeastGear items, got " + beastGearCnt;

		// 4. Verify all 22 Shan-Hai RelicWeapons & all 28 Shan-Hai Armors/Helmets/Shields carry `【山海神通】` passive & tooltip!
		local shWpnTraits = 0, shGearTraits = 0;
		foreach (rid, rcfg in ::Wuxia.Config.RelicWeapons)
		{
			if (!("IsShanHai" in rcfg) || !rcfg.IsShanHai) continue;
			local rItem = ::new(rcfg.Script);
			if (!("WX_GearTraitID" in rItem.m) || rItem.m.WX_GearTraitID == null || !(rItem.m.WX_GearTraitID in ::Wuxia.Config.GearTraits))
				throw "ShanHai Relic missing valid WX_GearTraitID: " + rid;
			local hasDivine = false;
			foreach (row in rItem.getTooltip())
			{
				if (("text" in row) && row.text != null && row.text.find("【山海神通") != null)
					hasDivine = true;
			}
			if (!hasDivine) throw "ShanHai Relic missing 【山海神通】 tooltip: " + rid;
			shWpnTraits += 1;
		}
		foreach (sgid, sgcfg in ::Wuxia.Config.ShanHaiGear)
		{
			if (sgcfg.Kind == "accessory") continue;
			local sgPath = sgcfg.Kind == "armor" ? ("scripts/items/armor/named/" + sgid)
				: (sgcfg.Kind == "helmet" ? ("scripts/items/helmets/named/" + sgid) : ("scripts/items/shields/named/" + sgid));
			local sgItem = ::new(sgPath);
			if (!("WX_GearTraitID" in sgItem.m) || sgItem.m.WX_GearTraitID == null || !(sgItem.m.WX_GearTraitID in ::Wuxia.Config.GearTraits))
				throw "ShanHai Gear missing valid WX_GearTraitID: " + sgid;
			local hasDivineG = false;
			foreach (row in sgItem.getTooltip())
			{
				if (("text" in row) && row.text != null && row.text.find("【山海神通") != null)
					hasDivineG = true;
			}
			if (!hasDivineG) throw "ShanHai Gear missing 【山海神通】 tooltip: " + sgid;
			shGearTraits += 1;
		}
		if (shWpnTraits != 22 || shGearTraits != 28)
			throw "Expected 22 ShanHai weapon traits & 28 ShanHai gear traits, got " + shWpnTraits + " / " + shGearTraits;

		// 5. Verify all 16 `CraftBlueprints` (`wx_bp_beast_*` & `wx_bp_up_*`) craft their exact target item
		local bpCrafted = [];
		local mockStash = { Items = bpCrafted, function add( _it ) { this.Items.push(_it); } };
		foreach (bpid, bpcfg in ::Wuxia.Config.CraftBlueprints)
		{
			local bpObj = ::new("scripts/crafting/blueprints/" + bpid);
			bpObj.onCraft(mockStash);
			if (bpCrafted.len() == 0 || bpCrafted.top() == null)
				throw "CraftBlueprint failed onCraft: " + bpid;
		}
		if (bpCrafted.len() != 16) throw "Expected 16 crafted BeastGear products, got " + bpCrafted.len();

		// 6. Verify runtime `wx_gear_spirit_trait` mechanics (SteelBrow, CycleZhuyin, AuraWard) & 0 AP bloat
		local spBrow = ::new("scripts/skills/special/wx_gear_spirit_trait");
		spBrow.setTraitID("shanhai_helm_taotie");
		local hitHead = { BodyPart = ::Const.BodyPart.Head, BodyDamageMult = 1.5 };
		spBrow.onBeforeDamageReceived(null, null, hitHead, ::Const.CharacterProperties.getClone());
		if (::Math.abs(hitHead.BodyDamageMult - 1.0) > 0.001)
			throw "SteelBrow passive failed to neutralize headshot crit multiplier: " + hitHead.BodyDamageMult;

		local spZhuyin = ::new("scripts/skills/special/wx_gear_spirit_trait");
		spZhuyin.setTraitID("shanhai_armor_zhuyin");
		local pZhu = ::Const.CharacterProperties.getClone();
		local ap0 = pZhu.ActionPoints, md0 = pZhu.MeleeDefense, fr0 = pZhu.FatigueRecoveryRate;
		spZhuyin.onUpdate(pZhu);
		if (pZhu.ActionPoints != ap0 || (pZhu.MeleeDefense - md0) != 5 || (pZhu.FatigueRecoveryRate - fr0) != 3)
			throw "CycleZhuyin round-1 passive math or AP guardrail failed";

		local feiyiArmor = ::new("scripts/items/armor/named/wx_armor_feiyi");
		local mockWardActor = {
			function getItems() {
				return {
					BodyRef = feiyiArmor,
					function getItemAtSlot( _slot ) { return _slot == ::Const.ItemSlot.Body ? this.BodyRef : null; }
				};
			}
		};
		if (!::Wuxia.BeastCraft.hasAuraWard(mockWardActor))
			throw "hasAuraWard failed to recognize wx_armor_feiyi aura immunity";

		::logInfo("[WX-SELFTEST] Verified Stage 13 Beast Loot & Forging: 6 Materials, 64 Boss Bonus Drops, 16 Beast Gear/Upgrades & 50 Shan-Hai Divine Passives");
	});

	// 18. Stage 14: Equipment Stat Roll Ranges, 4-Tier Masterwork Reforging & Pill Efficacy Grades/Infusions
	check("Stage 14 Equipment Stat Ranges, 4-Tier Masterwork Reforging & Pill Efficacy Grades/Infusions", function() {
		local makeStrictStream = function() {
			local q = [];
			return {
				buf = q,
				function getMetaData() { return { function getVersion() { return 66; } }; },
				function writeU8(v) { if (v < 0 || v > 255) throw "writeU8 out of bounds: " + v; this.buf.push(v); },
				function writeI8(v) { this.buf.push(v); },
				function writeU16(v) { if (v < 0 || v > 65535) throw "writeU16 out of bounds: " + v; this.buf.push(v); },
				function writeI16(v) { this.buf.push(v); },
				function writeU32(v) { this.buf.push(v); },
				function writeI32(v) { this.buf.push(v); },
				function writeF32(v) { this.buf.push(v); },
				function writeBool(v) { this.buf.push(v ? true : false); },
				function writeString(v) { this.buf.push(v); },
				function readU8() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readI8() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readU16() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readI16() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readU32() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readI32() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readF32() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readBool() { local v = this.buf[0]; this.buf.remove(0); return v; },
				function readString() { local v = this.buf[0]; this.buf.remove(0); return v; }
			};
		};

		// 1. Verify Blueprint Preview Tooltips (`WX_IsBlueprintPreview`) inject quality odds & [Min~Max] stat ranges
		local bpBeast = ::new("scripts/crafting/blueprints/wx_bp_beast_sword");
		local bpAcc   = ::new("scripts/crafting/blueprints/wx_bp_acc_wuzhiqi");
		if (bpBeast.m.PreviewCraftable == null || !("WX_IsBlueprintPreview" in bpBeast.m.PreviewCraftable.m))
			throw "Blueprint preview missing WX_IsBlueprintPreview flag on wx_bp_beast_sword";
		if (bpAcc.m.PreviewCraftable == null || !("WX_IsBlueprintPreview" in bpAcc.m.PreviewCraftable.m))
			throw "Blueprint preview missing WX_IsBlueprintPreview flag on wx_bp_acc_wuzhiqi";
		local bpTips = bpBeast.m.PreviewCraftable.getTooltip();
		local hasOdds = false, hasRange = false;
		foreach (row in bpTips)
		{
			if (row != null && ("id" in row) && row.id == 969) hasOdds = true;
			if (row != null && ("id" in row) && row.id == 970) hasRange = true;
		}
		if (!hasOdds || !hasRange)
			throw "Blueprint preview tooltip missing id 969/970 quality & stat range lines";

		// 2. Verify Named Weapon `getCleanRelicBase` prevents stat drift across 8 consecutive reforges
		local relicSword = ::new("scripts/items/weapons/named/wx_relic_yinglongjian");
		local cleanBase  = ::Wuxia.Forge.getCleanRelicBase("wx_relic_yinglongjian");
		if (cleanBase == null)
			throw "getCleanRelicBase returned null for wx_relic_yinglongjian";
		local cleanMax = cleanBase.RegularDamageMax;
		for (local rf = 0; rf < 8; rf = ++rf)
		{
			local decR = ::Wuxia.Forge.decodeVariantSeed(100 + rf * 20);
			::Wuxia.Forge.applySeedToItem(relicSword, decR, false);
		}
		local maxExpect = ::Math.round(cleanMax * 1.28);
		if (relicSword.m.RegularDamageMax > maxExpect || relicSword.m.RegularDamageMax < ::Math.round(cleanMax * 1.03))
			throw "Named weapon reforge drifted outside [103%..128%] clean bounds: " + relicSword.m.RegularDamageMax;

		// 3. Verify 5-Hammer Pity (`wx_forge_pity == 5` -> guaranteed Grade >= 2)
		::Wuxia.Forge.setPity(5);
		local pitySeed = ::Wuxia.Forge.rollNewSeed(true, 0);
		if (pitySeed.Grade < 2 || !pitySeed.UsedPity || ::Wuxia.Forge.getPity() != 0)
			throw "5-hammer pity guarantee failed: grade=" + pitySeed.Grade + ", pity=" + ::Wuxia.Forge.getPity();

		// 4. Verify U8-safe `Variant` (100..255) serialization round-trip on Beast Weapon, Upgrade & ShanHai Accessory
		local mwDec = ::Wuxia.Forge.decodeVariantSeed(255); // Grade 3 神工 (100% perfection)
		local bSword = ::new("scripts/items/weapons/wx_beast_sword");
		::Wuxia.Forge.applySeedToItem(bSword, mwDec, false);
		if (bSword.m.WX_ForgeGrade != 3 || bSword.getName().find("【神工】") == null)
			throw "Masterwork Grade 3 prefix missing on wx_beast_sword: " + bSword.getName();

		local s1 = makeStrictStream();
		bSword.onSerialize(s1);
		local bSwordLoaded = ::new("scripts/items/weapons/wx_beast_sword");
		bSwordLoaded.onDeserialize(s1);
		if (s1.buf.len() != 0 || bSwordLoaded.m.RegularDamageMax != bSword.m.RegularDamageMax || bSwordLoaded.m.WX_ForgeGrade != 3)
			throw "wx_beast_sword forged Variant round-trip mismatch";

		local bUp = ::new("scripts/items/armor_upgrades/wx_up_chiling");
		::Wuxia.Forge.applySeedToItem(bUp, mwDec, false);
		local s2 = makeStrictStream();
		bUp.onSerialize(s2);
		local bUpLoaded = ::new("scripts/items/armor_upgrades/wx_up_chiling");
		bUpLoaded.onDeserialize(s2);
		if (s2.buf.len() != 0 || bUpLoaded.m.ConditionModifier != bUp.m.ConditionModifier || bUpLoaded.getEffectiveBonusText().find(bUp.m.ConditionModifier + "") == null)
			throw "wx_up_chiling forged Variant round-trip mismatch";

		local accWl = ::new("scripts/items/accessory/wx_acc_wuluo");
		::Wuxia.Forge.applySeedToItem(accWl, mwDec, false);
		if (accWl.m.RolledBonuses.RangedDefense > 5)
			throw "wx_acc_wuluo RangedDefense exceeded AGENTS.md +5 cap on Masterwork roll: " + accWl.m.RolledBonuses.RangedDefense;
		local s3 = makeStrictStream();
		accWl.onSerialize(s3);
		local accWlLoaded = ::new("scripts/items/accessory/wx_acc_wuluo");
		accWlLoaded.onDeserialize(s3);
		if (s3.buf.len() != 0 || accWlLoaded.m.RolledBonuses.Initiative != accWl.m.RolledBonuses.Initiative || accWlLoaded.m.WX_ForgeGrade != 3)
			throw "wx_acc_wuluo forged Variant round-trip mismatch";

		// 5. Verify Pill Grades (`成丹 / 灵纹 / 丹霞`), `【药引丹韵】` Resonance & Single-String Legacy Save Compatibility
		local pBase = ::new("scripts/items/misc/wx_pill_item");
		pBase.initPill("wx_pill_ningshen");
		local sp0 = makeStrictStream();
		pBase.onSerialize(sp0);
		local pBaseLoaded = ::new("scripts/items/misc/wx_pill_item");
		pBaseLoaded.onDeserialize(sp0);
		if (sp0.buf.len() != 0 || pBaseLoaded.getPillID() != "wx_pill_ningshen" || pBaseLoaded.getPillGrade() != 1 || pBaseLoaded.getPotencyPct() != 100)
			throw "Legacy plain PillID round-trip failed";

		local pDanxia = ::new("scripts/items/misc/wx_pill_item");
		pDanxia.initPillVariant("wx_pill_ningshen", 3, 148, "yang");
		if (pDanxia.getPillID() != "wx_pill_ningshen" || pDanxia.getName().find("丹霞·") == null)
			throw "Danxia pill initPillVariant failed: " + pDanxia.getName();

		local cInf = ::new("scripts/skills/special/wx_martial_container");
		cInf.m.Slots[0].ManualID = "wx_manual_guiyuan";  cInf.m.Slots[0].Tier = 1; // yin neigong -> no yang resonance
		cInf.m.Slots[1].ManualID = "wx_manual_qingfeng"; cInf.m.Slots[1].Tier = 1; // waigong -> +15% yang resonance!
		local mockInfBro = {
			function getSkills() {
				return {
					Ref = cInf,
					function getSkillByID( _id ) { return _id == "special.wx_martial_container" ? this.Ref : null; }
				};
			}
		};
		local baseInfExp = pDanxia.getEffectiveExpAmount();
		local resYinSlot = pDanxia.getInfuseExpForSlot(mockInfBro, 0).ExpAmount;
		local resWaiSlot = pDanxia.getInfuseExpForSlot(mockInfBro, 1).ExpAmount;
		if (resYinSlot != baseInfExp || resWaiSlot != ::Math.round(baseInfExp * 1.15).tointeger())
			throw "Danxia + yang AuxNature martial slot resonance (+15% on waigong only) failed: " + resYinSlot + " / " + resWaiSlot;

		local sp1 = makeStrictStream();
		pDanxia.onSerialize(sp1);
		local pDanxiaLoaded = ::new("scripts/items/misc/wx_pill_item");
		pDanxiaLoaded.onDeserialize(sp1);
		if (sp1.buf.len() != 0 || pDanxiaLoaded.getPillGrade() != 3 || pDanxiaLoaded.getPotencyPct() != 148 || pDanxiaLoaded.getAuxNature() != "yang")
			throw "Danxia pill variant serialization round-trip failed";

		// 6. Verify Cauldron `previewBrew` returns `GradeChances` & `AuxNature` distinction
		::Wuxia.Alchemy.resetFallback();
		::Wuxia.Alchemy.Cabinet.addCount("core:wx_core_zhuyan", 2, "scripts/items/misc/wx_core_zhuyan", "wx_core_zhuyan");
		::Wuxia.Alchemy.Cabinet.addCount("core:wx_core_jinwu", 1, "scripts/items/misc/wx_core_jinwu", "wx_core_jinwu");
		::Wuxia.Alchemy.Cabinet.addCount("core:wx_core_wuzhiqi", 1, "scripts/items/misc/wx_core_wuzhiqi", "wx_core_wuzhiqi");
		local pvYang = ::Wuxia.Alchemy.previewBrew("f_longhu", ["core:wx_core_zhuyan", "core:wx_core_jinwu", ""]);
		local pvYin  = ::Wuxia.Alchemy.previewBrew("f_longhu", ["core:wx_core_zhuyan", "core:wx_core_wuzhiqi", ""]);
		::Wuxia.Alchemy.resetFallback();
		if (!pvYang.Ok || !pvYin.Ok || pvYang.AuxNature != "yang" || pvYin.AuxNature != "yin" || pvYang.AuxDesc == pvYin.AuxDesc)
			throw "Cauldron AuxNature efficacy distinction failed between yang and yin auxiliaries";
		if (pvYang.GradeChances[0] + pvYang.GradeChances[1] + pvYang.GradeChances[2] != 100)
			throw "Cauldron GradeChances must sum to 100%";

		// 7. Verify `wx_pill_battle_buff` 5-byte extended serialization, legacy 1-byte compat & +25% ArmorPen guardrail
		local buffExt = ::new("scripts/skills/effects/wx_pill_battle_buff");
		buffExt.addPillBuff("buff_longhu");
		buffExt.addPillBuff("buff_fengmo");
		buffExt.applyPillPotencyAndAux(150, "yang", true);
		buffExt.applyPillPotencyAndAux(150, "yin", true);
		local pBuff = ::Const.CharacterProperties.getClone();
		pBuff.DamageDirectAdd = 0.20;
		local apBefore = pBuff.ActionPoints;
		buffExt.onUpdate(pBuff);
		if (pBuff.ActionPoints != apBefore)
			throw "wx_pill_battle_buff violated permanent AP guardrail";
		if (pBuff.DamageDirectAdd > 0.2501)
			throw "wx_pill_battle_buff violated +25% global extra ArmorPen guardrail: " + pBuff.DamageDirectAdd;

		local sbExt = makeStrictStream();
		buffExt.onSerialize(sbExt);
		local buffLoaded = ::new("scripts/skills/effects/wx_pill_battle_buff");
		buffLoaded.onDeserialize(sbExt);
		if (sbExt.buf.len() != 0 || buffLoaded.m.PotencyScalePct != 150 || !buffLoaded.m.FengmoNoInjury || (buffLoaded.m.AuxMask & 6) != 6)
			throw "wx_pill_battle_buff 5-byte extended varint round-trip failed";

		::logInfo("[WX-SELFTEST] Verified Stage 14 Forging Stat Ranges, 4-Tier Masterwork Reforge, 5-Hammer Pity & Pill Grade/Aux Efficacy");
	});

	// 30. End-to-End Weapon Equip, Subtable Closure Binding (`getRangeMax` / `getAdditionalAccuracy`), Tooltip Validity & Non-Zero Combat Damage
	check("End-to-end weapon equip, C++ bindenv preservation & non-zero CurrentProperties damage", function() {
		local testWeapons = [
			"scripts/items/weapons/short_bow",
			"scripts/items/weapons/boar_spear",
			"scripts/items/weapons/arming_sword",
			"scripts/items/weapons/wx_fist_iron",
			"scripts/items/weapons/wx_beast_sword",
			"scripts/items/weapons/named/wx_relic_yinglongjian"
		];

		foreach (wPath in testWeapons)
		{
			local baseProps = ::Const.CharacterProperties.getClone();
			local curProps  = ::Const.CharacterProperties.getClone();
			local actorRef  = null;
			local itemCont  = ::new("scripts/items/item_container");
			local skillCont = ::new("scripts/skills/skill_container");

			actorRef = {
				m = {
					BaseProperties    = baseProps,
					CurrentProperties = curProps,
					Hitpoints         = 100,
					ActionPoints      = 9,
					Fatigue           = 0,
					IsAlive           = true
				},
				ClassName = "player",
				function isAlive() { return this.m.IsAlive; },
				function isDying() { return false; },
				function isPlayerControlled() { return true; },
				function getFaction() { return ::Const.Faction.Player; },
				function isAlliedWithPlayer() { return true; },
				function isAlliedWith( _other ) { return true; },
				function isKindOf( _obj, _cls ) { return _cls == "player" || _cls == "human" || _cls == "actor"; },
				function getID() { return 9001; },
				function getName() { return "演武测试木人"; },
				function getItems() { return itemCont; },
				function getSkills() { return skillCont; },
				function getBaseProperties() { return this.m.BaseProperties; },
				function getCurrentProperties() { return this.m.CurrentProperties; },
				function setCurrentProperties( _p ) { this.m.CurrentProperties = _p; },
				function getHitpoints() { return this.m.Hitpoints; },
				function getHitpointsMax() { return this.m.CurrentProperties.Hitpoints; },
				function getHitpointsPct() { return 1.0; },
				function setHitpointsPct( _pct ) {},
				function getActionPoints() { return this.m.ActionPoints; },
				function getActionPointsMax() { return this.m.CurrentProperties.ActionPoints; },
				function setActionPoints( _ap ) { this.m.ActionPoints = _ap; },
				function getFatigue() { return this.m.Fatigue; },
				function getFatigueMax() { return this.m.CurrentProperties.Stamina; },
				function setFatigue( _f ) { this.m.Fatigue = _f; },
				function onSkillsUpdated() {},
				function updateOverlay() {},
				function setDirty( _d ) {},
				function onAppearanceChanged( _app, _dirty = true ) {},
				function isPlacedOnMap() { return false; },
				function hasSprite( _s ) { return false; }
			};

			itemCont.setActor(actorRef);
			skillCont.setActor(actorRef);

			local wpn = ::new(wPath);
			local tt = wpn.getTooltip();
			if (tt == null || typeof tt != "array" || tt.len() == 0)
				throw "Invalid tooltip returned by " + wPath;

			if (!itemCont.equip(wpn))
				throw "Failed to equip " + wPath;

			skillCont.update();
			if (skillCont.m.IsUpdating)
				throw "skill_container.m.IsUpdating stuck true after equipping " + wPath;

			local finalProps = actorRef.getCurrentProperties();
			if (finalProps.DamageRegularMin <= 0 || finalProps.DamageRegularMax <= 0)
				throw "Zero weapon damage after equipping " + wPath + ": min=" + finalProps.DamageRegularMin + ", max=" + finalProps.DamageRegularMax;

			if (wPath == "scripts/items/weapons/short_bow")
			{
				local qs = skillCont.getSkillByID("actives.quick_shot");
				if (qs == null || qs.getItem() == null || !::Wuxia.hasMember(qs.getItem(), "getRangeMax") || qs.getItem().getRangeMax() <= 0)
					throw "short_bow quick_shot.getItem() lost getRangeMax binding";
			}

			local useProps = skillCont.buildPropertiesForUse(skillCont.m.Skills[skillCont.m.Skills.len() - 1], null);
			if (useProps.DamageRegularMin <= 0 || useProps.DamageRegularMax <= 0 || useProps.DamageTotalMult <= 0.0)
				throw "buildPropertiesForUse produced 0 damage for " + wPath;
		}

		// Verify escort_caravan_contract & deliver_item_contract preserve leaf methods (`spawnCaravan` / `onPrepareVariables`) & parent hooks (`WX_PolishContractScreen`)
		local caravanCon = ::new("scripts/contracts/contracts/escort_caravan_contract");
		if (!::Wuxia.hasMember(caravanCon, "spawnCaravan") || !::Wuxia.hasMember(caravanCon, "WX_PolishContractScreen"))
			throw "escort_caravan_contract missing spawnCaravan or WX_PolishContractScreen";
		caravanCon.m.States.push({ ID = "WX_TestState", function start() {} });
		try { caravanCon.setState("WX_TestState"); } catch (_e) {}
		if (caravanCon.m.ActiveState == null || !("Contract" in caravanCon.m.ActiveState) || !::Wuxia.hasMember(caravanCon.m.ActiveState.Contract, "spawnCaravan"))
			throw "escort_caravan_contract ActiveState.Contract lost spawnCaravan binding!";
		local optRewritten = ::Wuxia.Contracts.rewriteText("你打算出多少克朗？");
		if (optRewritten.find("克朗") != null || optRewritten.find("纹银") == null)
			throw "Contract option rewrite failed: " + optRewritten;
		local probeEv = ::new("scripts/events/events/wx_event_road_tea_shed");
		if (probeEv == null || !::Wuxia.hasMember(probeEv, "WX_PolishSystemOrCrisisEvent"))
			throw "scripts/events/event missing WX_PolishSystemOrCrisisEvent hook";
		probeEv.m.ID = "event.choose_ambition";
		local mockAmbScr = { Text = "old", Options = [{ Text = "流进金库的克朗" }] };
		probeEv.WX_PolishSystemOrCrisisEvent(mockAmbScr);
		if (probeEv.m.Title.find("江湖志向") == null || mockAmbScr.Text.find("gfx/ui/events/wx_ev_01.png") == null || mockAmbScr.Options[0].Text.find("纹银") == null)
			throw "choose_ambition_event polish failed: " + probeEv.m.Title;

		// Verify Library in-memory cache consistency & O(1) summary invalidation
		::Wuxia.Library.resetFallback();
		::Wuxia.Library.addManual("wx_manual_qingfeng", 2);
		::Wuxia.Library.addPages("wx_manual_duanyue", 5);
		local sumLib = ::Wuxia.Library.getSummaryCounts();
		if (sumLib.totalManuals != 2 || sumLib.totalPages != 5 || ::Wuxia.Library.getManualCount("wx_manual_qingfeng") != 2)
			throw "Library cache summary mismatch";
		local libUI = ::Wuxia.UI.buildLibraryUIData(null);
		if (libUI.items.len() != 2)
			throw "buildLibraryUIData owned-only iteration expected 2 items, got " + libUI.items.len();
		::Wuxia.Library.resetFallback();

		// Verify Tooltip Fatigue -> 内息 override even when wrapped over localization mod (`mod_bbmod_zhcn`)
		local mockTipEvents = {
			function general_queryUIElementTooltipData( _eid, _elId, _owner ) {
				return [
					{ id = 1, type = "title", text = "疲劳" },
					{ id = 2, type = "description", text = "每次挥动武器都会累积疲劳。" }
				];
			},
			function tactical_queryUIItemTooltipData( _eid, _iid, _owner ) {
				return [
					{ id = 1, type = "text", text = "最大疲劳 -14" },
					{ id = 2, type = "text", text = "武器技能产生 10 疲劳" }
				];
			}
		};
		::Wuxia.UI.bindTooltipEventsInstance(mockTipEvents);
		local fatTip = mockTipEvents.general_queryUIElementTooltipData(1, "character-stats.Fatigue", "");
		if (fatTip[0].text != "丹田内息" || fatTip[0].text.find("疲劳") != null || fatTip[1].text.find("内息") == null)
			throw "Fatigue stat tooltip failed to override 疲劳 -> 丹田内息: " + fatTip[0].text;
		local itemTip = mockTipEvents.tactical_queryUIItemTooltipData(1, "x", "");
		if (itemTip[0].text.find("疲劳") != null || itemTip[1].text.find("疲劳") != null || itemTip[0].text.find("内息上限") == null)
			throw "Item tooltip failed to harmonize 疲劳 -> 内息: " + itemTip[0].text + " / " + itemTip[1].text;

		// Verify 19 Distinct World Faction/Settlement Banners (`wx_fbanner_noble_01..10`, `south_01..03`, `civ_01..06`)
		local seenNobles = {};
		for (local nb = 1; nb <= 10; nb = ++nb)
		{
			local bKey = "banner_noble_" + ::Wuxia.Appearance.pad2(nb);
			local mapped = ::Wuxia.WorldVisuals.mapWorldBannerBrush(bKey);
			if (mapped != "wx_fbanner_noble_" + ::Wuxia.Appearance.pad2(nb) || (mapped in seenNobles) || !::Wuxia.Appearance.brushExists(mapped))
				throw "Noble world banner mapping failed for " + bKey + " -> " + mapped;
			seenNobles[mapped] <- true;
		}
		if (::Wuxia.WorldVisuals.mapWorldBannerBrush("banner_noble_11") != "wx_fbanner_civ_01")
			throw "Civilian banner_noble_11 did not map onto wx_fbanner_civ_01";
		for (local sb = 12; sb <= 14; sb = ++sb)
		{
			local sm = ::Wuxia.WorldVisuals.mapWorldBannerBrush("banner_noble_" + sb);
			if (sm != "wx_fbanner_south_0" + (sb - 11) || !::Wuxia.Appearance.brushExists(sm))
				throw "Southern city-state banner mapping failed for banner_noble_" + sb + " -> " + sm;
		}
		for (local cb = 1; cb <= 6; cb = ++cb)
		{
			if (!::Wuxia.Appearance.brushExists("wx_fbanner_civ_0" + cb))
				throw "Missing civilian settlement banner brush: wx_fbanner_civ_0" + cb;
		}

		// Verify Wild Shan-Hai Beast `EnemyEntityBustMap` & `_dead` corpse brushes
		foreach (beastKey in ["Direwolf", "Hyena", "Spider", "Ghoul", "Serpent", "Unhold", "Schrat", "Alp", "Hexe"])
		{
			if (!(beastKey in ::Wuxia.Config.Appearance.EnemyEntityBustMap))
				throw "Missing wild Shan-Hai beast pool in EnemyEntityBustMap: " + beastKey;
			foreach (bb in ::Wuxia.Config.Appearance.EnemyEntityBustMap[beastKey])
			{
				if (!::Wuxia.Appearance.brushExists(bb) || !::Wuxia.Appearance.brushExists(bb + "_dead"))
					throw "Missing wild Shan-Hai beast or corpse brush: " + bb;
			}
		}

		// Verify strict Loot & Shop gatekeeping against item inflation
		if (::Wuxia.Config.WildBeastDrops.Spider.Chance > 10 || ::Wuxia.Loot.EnemyLoadouts.bandit_thug.DropChance > 10)
			throw "Trash mob drop rates are still un-gated!";

		// Verify Interactive Town Tea-House (`江湖茶肆`) & Sect Anchor RPC wiring
		local mockQ = {};
		::Wuxia.UI.attachSectTeaHouseRPCs(mockQ);
		foreach (rpcName in ["onWXGetSectRelations", "onWXTeaHouseBuyManual", "onWXTeaHouseBanquet", "onWXTeaHouseSpar"])
		{
			if (!(rpcName in mockQ))
				throw "Missing Sect Tea-House RPC: " + rpcName;
		}
		local sectDir = mockQ.onWXGetSectRelations(null);
		if (!sectDir.ok || !("inTown" in sectDir) || !("money" in sectDir) || sectDir.sects.len() < 40 || !("anchorTownName" in sectDir.sects[0]))
			throw "buildSectRelationsDirectory missing Tea-House / Anchor fields";
	});

	::logInfo("[WX-SELFTEST] ================= Result: " + passed + " PASSED, " + failed + " FAILED =================");
};

if (::Wuxia.Debug && !("Hooks" in getroottable() && "QueueBucket" in ::Hooks && "AfterHooks" in ::Hooks.QueueBucket))
{
	::Wuxia.SelfTest.runAll();
}
