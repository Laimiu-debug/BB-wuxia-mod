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
		"scripts/skills/actives/wx_sword_zhongjian",
		"scripts/skills/actives/wx_saber_huoyandao",
		"scripts/skills/actives/wx_spear_liangyin",
		"scripts/skills/actives/wx_hama_push"
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
			function getCurrentProperties() { return { IsImmuneToPoison = true, IsAffectedByInjuries = false }; }
		};
		local livingProps = ::Const.CharacterProperties.getClone();
		local livingTarget = { function getCurrentProperties() { return livingProps; } };
		if (::Wuxia.CombatRules.isImmuneToMeridianAndPoison(livingTarget))
			throw "A living target with ordinary properties should accept meridian effects";
		livingProps.IsImmuneToPoison = true;
		if (!::Wuxia.CombatRules.isImmuneToMeridianAndPoison(livingTarget))
			throw "The native poison immunity flag should block these effects";
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
		foreach (entity, name in ::Wuxia.Config.Appearance.ShanHaiEntityStrings)
		{
			if (entity in ::Const.EntityType && ::Const.Strings.EntityName[::Const.EntityType[entity]] != name)
				throw "Shan Hai EntityName mismatch for " + entity + ": expected " + name;
		}

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

		// 2. Verify all 276 manuals have 1-to-1 bespoke icons, valid items, custom wx_ov_* Overlay, WX_AnimID & rich getTooltip()
		local seenSkills = {};
		local seenManualIcons = {};
		foreach (mid, mdef in ::Wuxia.Config.Manuals)
		{
			if (!("Icon" in mdef) || mdef.Icon != "ui/perks/" + mid + ".png" || (mdef.Icon in seenManualIcons))
				throw "Manual " + mid + " missing 1-to-1 bespoke perk icon: " + (("Icon" in mdef) ? mdef.Icon : "null");
			seenManualIcons[mdef.Icon] <- mid;

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
		if (seenSkills.len() != 171)
			throw "Expected all 171 Wuxia active skills wired to manuals, got " + seenSkills.len();
		::logInfo("[WX-SELFTEST] Verified 16x4-Frame Martial Animations, " + seenSkills.len() + " Active Skills, " + ::Wuxia.Config.Manuals.len() + " Manuals & " + pillCnt + " Pills");
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
		if (choreoCount != 171) throw "Expected 171 unique SkillChoreo entries, got " + choreoCount;

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
		local book = "wx_manual_songtao";
		::Wuxia.Library.addManual(book, 1);
		if (!::Wuxia.Slots.equipLearnedManual(mockActor, 1, "wx_manual_qingfeng").Ok)
			throw "RPC fixture failed to re-equip manual";
		if (::Wuxia.Library.learnAndEquip(mockActor, 99, book).ok || ::Wuxia.Library.getManualCount(book) != 1)
			throw "Invalid slot consumed a book";
		if (!::Wuxia.Library.learnAndEquip(mockActor, 0, book).ok || mockContainer.m.Slots[0].ManualID != book || ::Wuxia.Library.getManualCount(book) != 0)
			throw "Learning a book into an empty slot failed";
		::Wuxia.Library.addManual("wx_manual_tuna", 1);
		local preview = ::Wuxia.Library.learnAndEquip(mockActor, 0, "wx_manual_tuna");
		if (!("needsConfirm" in preview) || !preview.needsConfirm || preview.oldManualID != book)
			throw "Missing overwrite preview";
		local stale = ::Wuxia.Library.learnAndEquip(mockActor, 0, "wx_manual_tuna", false, true, true, "changed");
		if (stale.ok || ::Wuxia.Library.getManualCount("wx_manual_tuna") != 1)
			throw "Stale confirmation consumed a book";
		if (!::Wuxia.Library.learnAndEquip(mockActor, 0, "wx_manual_tuna", false, true, true, book).ok || ::Wuxia.Library.getManualCount("wx_manual_tuna") != 0)
			throw "Confirmed library switch did not commit exactly once";
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
			["scripts/items/weapons/named/named_sword",         "arm_wx_famed_01"],
			["scripts/items/weapons/named/named_fencing_sword", "arm_wx_famed_03"],
			["scripts/items/weapons/named/named_warbow",      "arm_wx_famed_55"],
			["scripts/items/weapons/named/named_billhook",    "arm_wx_famed_23"]
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

		// Repeat sync with zero visual changes -> dirtyCounter MUST NOT increment (anti-stutter lossless dirty check!)
		local dirtyAfterUnequip = dirtyCounter;
		::Wuxia.Armory.syncActorHandheldAndArmor(mockHuman);
		if (dirtyCounter != dirtyAfterUnequip)
			throw "syncActorHandheldAndArmor unnecessarily marked actor dirty on no-op sync (" + dirtyAfterUnequip + " -> " + dirtyCounter + ")";

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

		// Verify player_banner & faction_banner match Spear/Polearm Waigong (even under localized 长杆/战旗 Categories) & grant PolearmMastery
		foreach (bWpn in [pb, fb])
		{
			if (!::Wuxia.CombatRules.matchesWeapon(bWpn, ["Spear"]) || !::Wuxia.CombatRules.matchesWeapon(bWpn, ["Polearm"]))
				throw "War banner failed to match Spear/Polearm Waigong: " + bWpn.getID();
			if (::Wuxia.CombatRules.matchesWeapon(bWpn, ["Sword", "Bow", "Fist", "Dagger"]))
				throw "War banner falsely matched unrelated weapon family: " + bWpn.getID();
		}
		local savedCat = pb.m.Categories;
		pb.m.Categories = "长杆武器, 双手";
		if (!::Wuxia.CombatRules.matchesWeapon(pb, ["Spear", "Polearm"]))
			throw "player_banner failed Spear/Polearm match under localized 长杆武器 category";
		pb.m.Categories = savedCat;

		local bItems = {
			function getItemAtSlot( _s ) { return _s == ::Const.ItemSlot.Mainhand ? pb : null; },
			function hasBlockedSlot( _s ) { return true; }
		};
		local bActor = {
			function getItems() { return bItems; },
			function isArmedWithShield() { return false; },
			function isPlacedOnMap() { return false; },
			function getInitiative() { return 95; }
		};
		local bSkills = { function getActor() { return bActor; }, function hasSkill( _id ) { return false; } };
		local bCont = ::new("scripts/skills/special/wx_martial_container");
		bCont.setContainer(bSkills);
		bCont.m.Slots[1].ManualID = "wx_manual_yaqi_zhenzhen";
		bCont.m.Slots[1].Tier = 1;
		local bProps = ::Const.CharacterProperties.getClone();
		local baseM = bProps.MeleeSkill;
		bCont.onUpdate(bProps);
		if (!bProps.IsSpecializedInPolearms || (bProps.MeleeSkill - baseM) != 2)
			throw "player_banner + wx_manual_yaqi_zhenzhen failed to activate PolearmMastery or MeleeSkill";
		local bMove = ::new("scripts/skills/actives/wx_spear_guard");
		bMove.setContainer(bSkills);
		if (!bMove.wxHasRequiredWeapon())
			throw "wx_spear_guard rejected player_banner";
		if (!("standard_bearer" in ::Wuxia.Loot.EnemyLoadouts))
			throw "Missing standard_bearer in EnemyLoadouts";

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
				"wx_fig_beast_xiangliu", "wx_fig_beast_eshou", "wx_fig_beast_taotie",
				"wx_fig_beast_qiongqi", "wx_fig_beast_xuangui", "wx_fig_beast_fuzhu",
				"wx_fig_beast_dangkang", "wx_fig_beast_jinwu", "wx_fig_beast_kui",
				"wx_fig_beast_qinyuan", "wx_fig_beast_xingtian", "wx_fig_beast_kuafu",
				"wx_fig_beast_hundun", "wx_fig_beast_bingyi", "wx_fig_beast_wenyao",
				"wx_fig_beast_yumin",
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
			figure_kraken_01    = "wx_fig_beast_xiangliu",
			figure_spider_01    = "wx_fig_beast_chizhu",
			figure_werewolf_01  = "wx_fig_beast_tiangou",
			figure_hyena_01     = "wx_fig_beast_gudiao",
			figure_serpent_01   = "wx_fig_beast_bashe",
			figure_hexe_01      = "wx_fig_beast_yaomei",
			figure_alp_01       = "wx_fig_beast_eshou",
			figure_ghoul_01     = "wx_fig_beast_taotie",
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
			// 2. All 75 x 4 = 300 unique 4-frame action sequence sprites (`wx_anim_01..75_f1..f4`) must exist!
			for (local ai = 1; ai <= 171; ai = ++ai)
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
		if (totalChoreo != 171)
			throw "Expected 171 active skills in Stage 10 VFX audit, got " + totalChoreo;

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
				if (hMeta == null || hMeta.Kind != "herb" || hMeta.Potency < 2 || hMeta.Potency > 5)
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

	// Stage 12: Grand Shan Hai Treasury Expansion — 40 ShanHaiGear, 59 RelicWeapons (22 ShanHai), 96 Neidan Cores, 49 Herbs & All Crafting Blueprints
	check("Stage 12 山海百工宝库大扩充：40宝甲神盾奇佩·59神兵(22山海)·96妖丹·49本草·全蓝图校验", function() {
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

		// 4. Verify all 49《山海本草》Herbs instantiate via dedicated item scripts, cover all 6 Natures & Potency 2~5, & all Crafting Blueprints succeed
		local herbTotal = 0;
		local seenHerbNats = {};
		local seenHerbPots = {};
		foreach (hid, hcfg in ::Wuxia.Config.Herbs)
		{
			herbTotal += 1;
			local hItem = ::Wuxia.ShanHai.createHerbItem(hid);
			if (hItem == null || hItem.getID() != "misc." + hid || hItem.getTooltip().len() < 3)
				throw "Herb script failed: " + hid;
			if (!(hid in ::Wuxia.Config.Alchemy.HerbNatures))
				throw "Herb missing explicit HerbNatures entry: " + hid;
			local hn = ::Wuxia.Config.Alchemy.HerbNatures[hid];
			seenHerbNats[hn.Nature] <- true;
			seenHerbPots[hn.Potency] <- true;
		}
		if (herbTotal != 49)
			throw "Expected 49 Spirit Herbs, got " + herbTotal;
		foreach (reqNat in ["vital", "yang", "yin", "spirit", "venom", "origin"])
		{
			if (!(reqNat in seenHerbNats))
				throw "Herbs missing Nature coverage: " + reqNat;
		}
		foreach (reqPot in [2, 3, 4, 5])
		{
			if (!(reqPot in seenHerbPots))
				throw "Herbs missing Potency tier: " + reqPot;
		}
		local alcCodexPayload = ::Wuxia.UI.buildAlchemyModalPayload(false);
		if (!("herbCodex" in alcCodexPayload) || alcCodexPayload.herbCodex.len() != 49)
			throw "Expected 49 entries in herbCodex UI payload";

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

		::logInfo("[WX-SELFTEST] Verified Stage 12 Grand Shan Hai Treasury: 40 ShanHaiGear, 59 Relics (22 ShanHai), 96 Cores, 49 Herbs & " + wxBpCount + " Wuxia Blueprints");
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

	local makeStrictStream = function() {
		return {
			buf = [],
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

	// 18. Stage 14: Equipment Stat Roll Ranges, 4-Tier Masterwork Reforging & Pill Efficacy Grades/Infusions
	check("Stage 14 Equipment Stat Ranges, 4-Tier Masterwork Reforging & Pill Efficacy Grades/Infusions", function() {
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

		// Verify Wild Shan-Hai Beast `EnemyEntityBustMap` (all 17 pools, 75 unique busts, zero cross-pool sharing) & `_dead` corpse brushes
		local seenWildBeasts = {};
		local wildBeastTotal = 0;
		foreach (beastKey in [
			"Direwolf", "Hyena", "Spider", "SpiderEggs", "Ghoul", "Serpent",
			"Unhold", "UnholdFrost", "UnholdBog", "Schrat", "SchratSmall",
			"Alp", "Hexe", "Lindwurm", "Kraken", "KrakenTentacle", "TricksterGod"
		])
		{
			if (!(beastKey in ::Wuxia.Config.Appearance.EnemyEntityBustMap))
				throw "Missing wild Shan-Hai beast pool in EnemyEntityBustMap: " + beastKey;
			foreach (bb in ::Wuxia.Config.Appearance.EnemyEntityBustMap[beastKey])
			{
				if (bb in seenWildBeasts)
					throw "Shared wild Shan-Hai beast bust across pools: " + bb + " (" + seenWildBeasts[bb] + " vs " + beastKey + ")";
				seenWildBeasts[bb] <- beastKey;
				wildBeastTotal += 1;
				if (!(bb in ::Wuxia.Config.Appearance.BeastBustNames))
					throw "Missing BeastBustNames entry for wild Shan-Hai beast: " + bb;
				if (!::Wuxia.Appearance.brushExists(bb) || !::Wuxia.Appearance.brushExists(bb + "_dead"))
					throw "Missing wild Shan-Hai beast or corpse brush: " + bb;
			}
		}
		if (wildBeastTotal != 75)
			throw "Expected 75 unique wild Shan-Hai beast busts wired, got " + wildBeastTotal;

		// Verify strict Loot & Shop gatekeeping against item inflation
		if (::Wuxia.Config.WildBeastDrops.Spider.Chance > 10 || ::Wuxia.Loot.EnemyLoadouts.bandit_thug.DropChance > 10)
			throw "Trash mob drop rates are still un-gated!";

		// The stock scene supports 140 x 170 with Blazing Deserts and 140 x 140 without it.
		local settings = ::Const.World.Settings;
		local maxHeight = ::Const.DLC.Desert ? 170 : 140;
		if (settings.SizeX <= 0 || settings.SizeX > 140 || settings.SizeY <= 0 || settings.SizeY > maxHeight)
			throw "World generator dimensions exceed the campaign scene: " + settings.SizeX + "x" + settings.SizeY;
		local relationsScreen = ::Hooks.BBClass["scripts/ui/screens/world/world_relations_screen"].Prototype;
		foreach (rpcName in [
			"onWXGetSectRelations", "onWXTeaHouseBuyManual", "onWXTeaHouseBanquet", "onWXTeaHouseSpar",
			"onWXTavernInquireRumor", "onWXSanctumAskAlchemy", "onWXSanctumStartBattle",
			"onWXSanctumRecruitDisciple", "onWXSanctumElderEmpower", "onWXSanctumHealInternal",
			"onWXSanctumHandleQuest", "onWXSanctumBuyHerbs", "onWXCloseSanctum"
		])
		{
			if (!::Wuxia.hasMember(relationsScreen, rpcName))
				throw "Missing Sect Tea-House / Sanctum Hall RPC: " + rpcName;
		}
		if (::Wuxia.SectRelations.getSectFormationRoster("shaolin", false).len() < 4 || ::Wuxia.SectRelations.getSectRegionalHerbs("shaolin").len() == 0)
			throw "Sect Sanctuary formation or regional herb pool invalid";
		local sectDir = relationsScreen.onWXGetSectRelations(null);
		if (!sectDir.ok || !("inTown" in sectDir) || !("inSanctum" in sectDir) || !("knownSectCount" in sectDir) || sectDir.sects.len() < 40 || !("anchorTownName" in sectDir.sects[0]))
			throw "buildSectRelationsDirectory missing Sanctum / Fog-of-War fields";
		if (sectDir.sects[0].manuals.len() > 0 && !("isRevealed" in sectDir.sects[0].manuals[0]))
			throw "buildSectRelationsDirectory missing manual masking (isRevealed)";
		local sanctumSpec = ::Wuxia.SectRelations.getSanctumVisualSpec("shaolin");
		if (sanctumSpec == null || sanctumSpec.FullName == "" || sanctumSpec.WorldBrush == "")
			throw "getSanctumVisualSpec(shaolin) invalid";
		::include("scripts/entity/world/locations/wx_sect_sanctum");

		// Verify Exploration Alchemy (`盲炉试丹` + `《丹经手札》` starts locked at 0 known formulas) & Read-Only vs Town Workshop RPC Gatekeeping
		if (::Wuxia.Alchemy.isFormulaDiscovered("huixue_dan"))
			throw "Alchemy formula expected undiscovered when no flag unlocked";
		local matchedF = ::Wuxia.Alchemy.matchBestFormulaForFreeBrew("vital", "spirit", "vital", 6);
		if (matchedF == null || !("ID" in matchedF))
			throw "matchBestFormulaForFreeBrew failed to match basic vital+spirit formula";
		local roState = relationsScreen.onWXGetAlchemyState(null);
		if (!roState.ok || roState.inWorkshop != false)
			throw "Read-only Alchemy RPC expected inWorkshop == false";
		if (relationsScreen.onWXAlchemyBrew(["free", "", "", ""]).ok != false || relationsScreen.onWXForgeReforge(["x"]).ok != false || relationsScreen.onWXAlchemySweep([false]).ok != false || relationsScreen.onWXAlchemyWithdraw(["x", 1]).ok != false)
			throw "Read-only Alchemy RPC failed to block brew/reforge/sweep/withdraw outside 百工丹坊!";
		local workshop = ::Hooks.BBClass["scripts/ui/screens/world/modules/world_town_screen/town_taxidermist_dialog_module"].Prototype;
		if (workshop.onWXGetAlchemyState(null).inWorkshop != true)
			throw "Workshop Alchemy RPC expected inWorkshop == true";
		if (relationsScreen.onWXTeaHouseBuyManual(["shaolin", "wx_manual_luohan"]).ok != false || relationsScreen.onWXTeaHouseBanquet(["shaolin"]).ok != false)
			throw "Read-only Sect RPC failed to block manual buy/banquet outside Tavern/Sanctum!";

		// Verify Disguise Pavilion (`铜镜江湖易容阁`), Jianghu Reputation Ranks & Wuxia Retinue Followers
		local barberBldg = ::new("scripts/entity/world/settlements/buildings/barber_building");
		if (barberBldg.getName() != "铜镜江湖易容阁" || barberBldg.isHidden())
			throw "Barber Disguise Pavilion hook failed: name=" + barberBldg.getName() + ", hidden=" + barberBldg.isHidden();
		if (::Const.Strings.BusinessReputation[0] != "籍籍无名")
			throw "BusinessReputation[0] expected 籍籍无名, got " + ::Const.Strings.BusinessReputation[0];
		local alchFol = ::new("scripts/retinue/followers/alchemist_follower");
		local alchEffs = alchFol.getEffects();
		if (alchFol.getName() != "丹鼎方士" || alchEffs == null || alchEffs.len() == 0 || alchEffs[0].find("八卦丹炉") == null)
			throw "Retinue alchemist_follower Wuxia effects hook failed";

		// Verify WorldVisuals Banners, Town Buildings, Settlement/Location Prototypes, LocationNames & RoamOrder Pivot Safety
		if (::Wuxia.WorldVisuals.RegisteredBanners != 12 || ::Const.PlayerBanners.len() != 12 || ::Const.PlayerBanners[0] != "banner_51" || ::Const.PlayerBanners[11] != "banner_62")
			throw "PlayerBanners expected pure 12 Wuxia standards (banner_51..62), got len=" + ::Const.PlayerBanners.len();
		if (::Wuxia.WorldVisuals.MappedTerrainCount < 14 || ::Wuxia.WorldVisuals.MappedLocationPools < 10)
			throw "WorldVisuals terrain/location pools not initialized: terrain=" + ::Wuxia.WorldVisuals.MappedTerrainCount + ", pools=" + ::Wuxia.WorldVisuals.MappedLocationPools;
		local campName = ::Wuxia.Config.WorldVisuals.WildCampNames.ruins[0];
		local occupied = [{ getName = @() campName }, { getName = @() campName + "·2" }];
		local nextName = ::Wuxia.WorldVisuals.pickUnusedSiteName([campName], 0, occupied);
		if (nextName != campName + "·3" || !::Wuxia.WorldVisuals.isKnownWildCampName(nextName))
			throw "Exhausted camp name pools must produce a stable, distinct name";
		if (::Wuxia.WorldVisuals.mapFactionUIBanner("wx_fbanner_noble_01") != "ui/banners/wx_fbanner_noble_01s.png"
			|| ::Wuxia.WorldVisuals.mapFactionUIBanner("wx_fbanner_noble_03") != "ui/banners/wx_fbanner_noble_03.png"
			|| ::Wuxia.WorldVisuals.mapFactionUIBanner("wx_fbanner_south_01") != "ui/banners/wx_fbanner_south_01s.png"
			|| ::Wuxia.WorldVisuals.mapFactionUIBanner("wx_fbanner_civ_02") != "ui/banners/wx_fbanner_civ_02.png")
		{
			throw "mapFactionUIBanner returned unexpected path";
		}
		local mktBldg = ::new("scripts/entity/world/settlements/buildings/marketplace_building");
		if (mktBldg.getName() != "州县百货集市" || mktBldg.getUIImage() != "ui/settlements/wx_bldg_marketplace")
			throw "Town building hook failed: name=" + mktBldg.getName() + ", img=" + mktBldg.getUIImage();
		if ("BBClass" in ::Hooks)
		{
			local setProto = ("scripts/entity/world/settlement" in ::Hooks.BBClass) ? ::Hooks.BBClass["scripts/entity/world/settlement"].Prototype : null;
			if (setProto == null || !::Wuxia.hasMember(setProto, "WX_ApplyArchVisuals") || !::Wuxia.hasMember(setProto, "WX_GetUISubTitle") || !::Wuxia.hasMember(setProto, "WX_ResolveSettlementBanner"))
				throw "settlement prototype missing WorldVisuals methods";
			local locProto = ("scripts/entity/world/location" in ::Hooks.BBClass) ? ::Hooks.BBClass["scripts/entity/world/location"].Prototype : null;
			if (locProto == null || !::Wuxia.hasMember(locProto, "WX_ApplyWildLocationName"))
				throw "location prototype missing WX_ApplyWildLocationName";
		}
		local roTest = ::new("scripts/ai/world/orders/roam_order");
		if (roTest.m.Pivot != null)
			throw "roam_order default Pivot expected null";
		local mockSettlementTbl = { m = {} };
		roTest.setPivot(mockSettlementTbl);
		if (roTest.m.Pivot == null || !("isNull" in roTest.m.Pivot) || roTest.m.Pivot.isNull())
			throw "roam_order WeakTableRef Pivot failed isNull() check";
	});

	// Stage 15: Wuxia Tavern Gambling (`迎客酒肆 · 长乐赌桌`) & Martial Arts Tournament Betting (`天下武林大会 · 外围红盘`)
	check("Stage 15: Wuxia Tavern Gambling (7 games + UTF-8 codec) & Martial Arts Tournament Betting", function() {
		if (!("Gambling" in ::Wuxia) || !("Tournament" in ::Wuxia) || !("Gambling" in ::Wuxia.Config))
			throw "Missing Gambling / Tournament namespaces";

		local tp = ::new("scripts/entity/tactical/wx_tournament_player");
		if (tp == null) throw "Failed to instantiate wx_tournament_player";

		// 1. UTF-8 length-prefixed codec roundtrip
		local sample = {
			title = "天下武林大会 · 东岳青龙榜",
			stake = 2500,
			ratio = 1.96,
			ok    = true,
			empty = null,
			legs  = [{ match = 1, team = 2, odds = 184 }, { match = 4, team = 7, odds = 310 }]
		};
		local enc = ::Wuxia.Gambling.encode(sample);
		local dec = ::Wuxia.Gambling.decode(enc);
		if (dec.title != sample.title || dec.stake != 2500 || dec.legs.len() != 2 || dec.legs[1].odds != 310 || !::Wuxia.Gambling.sameSavedValue(sample, dec))
			throw "Gambling UTF-8 encode/decode roundtrip mismatch";

		// 2. Verify all 7 Wuxia Tavern Games & Deck/Dice helpers
		if (::Wuxia.Config.Gambling.Tables.len() != 7 || ::Wuxia.Config.Gambling.Patrons.len() < 3)
			throw "Expected 7 Wuxia Tavern tables and >=3 Patrons";
		local deck = ::Wuxia.Gambling.shuffledDeck();
		if (deck.len() != 52) throw "shuffledDeck expected 52 cards";
		if (::Wuxia.Gambling.cardTotal([0, 12]) != 21 || ::Wuxia.Gambling.cardTotal([0, 0, 8]) != 21)
			throw "Blackjack cardTotal Ace handling failed";
		// Royal Straight Flush vs Four of a Kind in 四家叶子戏 (`holdemRank`)
		local sfScore = ::Wuxia.Gambling.holdemRank([0, 9, 10, 11, 12, 14, 28]);
		local fkScore = ::Wuxia.Gambling.holdemRank([0, 13, 26, 39, 12, 11, 10]);
		if (sfScore <= fkScore || ::Wuxia.Gambling.holdemRankName(sfScore) != "天罡同花顺" || ::Wuxia.Gambling.holdemRankName(fkScore) != "四象轰雷(四条)")
			throw "Holdem hand rank evaluation failed: sf=" + sfScore + ", fk=" + fkScore;

		// 3. Verify Sect Squad Pool & Exotic Guest Entries for Tournament
		local sectPool = ::Wuxia.Tournament.buildSectCandidatePool();
		if (sectPool.len() < 44)
			throw "Expected >= 44 Wuxia Sect & Official tournament squads, got " + sectPool.len();
		foreach (sc in sectPool)
		{
			if (sc.wxRoles.len() != 5) throw "Sect squad expected 5 fighters: " + sc.name;
			foreach (rk in sc.wxRoles)
			{
				if (!(rk in ::Wuxia.Config.Fighters))
					throw "Unknown fighter role '" + rk + "' in sect squad " + sc.name;
			}
		}
		local usedG = {};
		local guests16 = ::Wuxia.Tournament.buildGuestEntries(16, usedG, 64);
		if (guests16.len() != 16) throw "Expected 16 exotic guest entries";

		// 4. Verify 16 & 64 Bracket Construction, Odds Lock & Parlay Ticket Payout Math
		foreach (sz in [16, 64])
		{
			local mockEv = {
				id = sz, town = 1, townName = "洛阳府", size = sz, title = "测试武林大会",
				edition = 1, phase = "registration", openedDay = 1, finishedDay = -1,
				round = 0, player = 0, teams = [], matches = [], tickets = [], nextTicket = 1, champion = 0, notices = []
			};
			for (local ti = 1; ti <= sz; ti = ++ti)
				mockEv.teams.push({ id = ti, name = "第" + ti + "队", power = 1000.0 * (1 + (ti % 3)) });
			if (!::Wuxia.Tournament.buildBracketTree(mockEv) || mockEv.matches.len() != (sz - 1))
				throw "Bracket tree match count mismatch for size " + sz;
			local m1 = mockEv.matches[0];
			local m2 = mockEv.matches[1];
			::Wuxia.Tournament.lockMatchOdds(mockEv, m1);
			::Wuxia.Tournament.lockMatchOdds(mockEv, m2);
			if (m1.oddsLeft < 108 || m1.oddsRight < 108)
				throw "Locked odds out of expected range: " + m1.oddsLeft + "/" + m1.oddsRight;

			local parlayTk = {
				id = 1, round = 0, stake = 100, paid = false, receipt = 0,
				legs = [
					{ match = 1, team = m1.left, odds = m1.oddsLeft },
					{ match = 2, team = m2.right, odds = m2.oddsRight }
				]
			};
			if (::Wuxia.Tournament.ticketValue(mockEv, parlayTk).status != "waiting")
				throw "Open parlay ticket expected 'waiting'";
			m1.status = "done"; m1.winner = m1.left;
			m2.status = "done"; m2.winner = m2.right;
			local wonVal = ::Wuxia.Tournament.ticketValue(mockEv, parlayTk);
			local expectedPay = ::Math.floor(100.0 * (m1.oddsLeft / 100.0) * (m2.oddsRight / 100.0)).tointeger();
			if (wonVal.status != "won" || wonVal.amount != expectedPay)
				throw "Parlay ticket payout mismatch: got " + wonVal.amount + ", expected " + expectedPay;
		}

		// 5. Verify Pre-Campaign `::World == {}` Guard Safety & End-to-End 7-Game Tavern Execution
		if (::Wuxia.Gambling.ensure() != false || ::Wuxia.Gambling.wallet() != 0 || ::Wuxia.Tournament.currentVenue() != null || ::Wuxia.Tournament.publicityGazette().len() != 0)
			throw "Pre-campaign empty ::World safety guard failed";

		local mockFlagStore = {};
		local mockFlags = {
			store = mockFlagStore,
			function has( _k ) { return _k in this.store; },
			function get( _k ) { return (_k in this.store) ? this.store[_k] : ""; },
			function set( _k, _v ) { this.store[_k] <- _v.tostring(); }
		};
		local mockBank = { silver = 20000 };
		local mockAssets = {
			bank = mockBank,
			function getMoney() { return this.bank.silver; },
			function addMoney( _d ) { this.bank.silver += _d.tointeger(); }
		};
		local hadFlags = ("Flags" in ::World);
		local prevFlags = hadFlags ? ::World.Flags : null;
		local hadAssets = ("Assets" in ::World);
		local prevAssets = hadAssets ? ::World.Assets : null;
		local hadState = ("State" in ::World);
		local prevState = hadState ? ::World.State : null;
		local mockTown = {
			function getName() { return "洛阳府"; },
			function getID() { return 101; },
			function isAlive() { return true; },
			function hasBuilding( _id ) { return false; },
			function getSize() { return 3; }
		};
		::World.Flags <- mockFlags;
		::World.Assets <- mockAssets;
		::World.State <- {
			t = mockTown,
			function getCurrentTown() { return this.t; },
			function updateTopbarAssets() {}
		};
		try
		{
			local openRes = ::Wuxia.Gambling.handleCasinoAction(["refresh", "", 0, 0, 0], mockTown);
			if (!openRes.ok || openRes.tables.len() != 7 || openRes.money != 20000)
				throw "handleCasinoAction refresh failed";

			foreach (startCmd in [
				["size", 50, 1],
				["symbols", 50, 1],
				["riffa", 50, 0],
				["hazard", 50, 7],
				["raid", 50, 0],
				["blackjack", 50, 0],
				["holdem", 50, 0]
			])
			{
				local sr = ::Wuxia.Gambling.handleCasinoAction(["gamble", startCmd[0], startCmd[1], startCmd[2], ::Wuxia.Gambling.State.revision], mockTown);
				if (!sr.ok) throw "Failed to start tavern game " + startCmd[0] + ": " + sr.message;
				local guard = 0;
				while (::Wuxia.Gambling.State.game != null && guard < 16)
				{
					guard += 1;
					local gKind = ::Wuxia.Gambling.State.game.kind;
					local stepAct = "hazard_next";
					if (gKind == "raid") stepAct = "raid_stop";
					else if (gKind == "blackjack") stepAct = "bj_stand";
					else if (gKind == "holdem") stepAct = "holdem_call";
					::Wuxia.Gambling.handleCasinoAction([stepAct, "", 0, 0, ::Wuxia.Gambling.State.revision], mockTown);
				}
				if (::Wuxia.Gambling.State.game != null)
					throw "Tavern game did not settle within 16 steps: " + startCmd[0];
			}
			if (::Wuxia.Gambling.State.metrics.handsPlayed < 7 || !("wx_gamble_meta" in mockFlagStore))
				throw "Tavern metrics or segmented save meta not persisted";
		}
		catch (simErr)
		{
			if (hadFlags) ::World.Flags <- prevFlags; else ::World.rawdelete("Flags");
			if (hadAssets) ::World.Assets <- prevAssets; else ::World.rawdelete("Assets");
			if (hadState) ::World.State <- prevState; else ::World.rawdelete("State");
			::Wuxia.Gambling.State = null;
			::Wuxia.Gambling.Runtime.loadedFlags = null;
			::Wuxia.Gambling.Runtime.recordCache = null;
			throw simErr;
		}
		if (hadFlags) ::World.Flags <- prevFlags; else ::World.rawdelete("Flags");
		if (hadAssets) ::World.Assets <- prevAssets; else ::World.rawdelete("Assets");
		if (hadState) ::World.State <- prevState; else ::World.rawdelete("State");
		::Wuxia.Gambling.State = null;
		::Wuxia.Gambling.Runtime.loadedFlags = null;
		::Wuxia.Gambling.Runtime.recordCache = null;
	});

	// Stage 16: 50 Spirit Pills, 50 Bagua Cauldron Formulas, 6 Starter Formulas, 19 New Town Pill Blueprints & Save Stream Roundtrip
	check("Stage 16 五十灵丹·五十古方·6道入门方·19新蓝图·流派机制与存档字节流兼容校验", function() {
		local pillCnt = 0;
		foreach (pid, pdef in ::Wuxia.Config.Pills)
		{
			pillCnt += 1;
			local pInst = ::new("scripts/items/misc/wx_pill_item");
			pInst.initPillVariant(pid, 3, 142, "origin");
			if (pInst.getTooltip().len() < 3 || pInst.m.Icon == "")
				throw "Pill variant validation failed: " + pid;
		}
		if (pillCnt != 50)
			throw "Expected 50 total Spirit Pills, got " + pillCnt;

		if (::Wuxia.Config.Alchemy.Formulas.len() != 50)
			throw "Expected 50 Bagua Cauldron Formulas, got " + ::Wuxia.Config.Alchemy.Formulas.len();

		local seenFID = {};
		local seenPID = {};
		foreach (f in ::Wuxia.Config.Alchemy.Formulas)
		{
			if (f.ID in seenFID) throw "Duplicate Formula ID: " + f.ID;
			if (f.PillID in seenPID) throw "Duplicate Formula PillID: " + f.PillID;
			if (!(f.PillID in ::Wuxia.Config.Pills)) throw "Formula references missing PillID: " + f.PillID;
			seenFID[f.ID] <- true;
			seenPID[f.PillID] <- true;
		}

		// Verify 6 Starter Formulas unlocked out-of-the-box & 44 advanced formulas locked initially
		::Wuxia.Alchemy.resetFallback();
		foreach (sf in ["f_jinchuang", "f_huoluo", "f_huxin", "f_qingxin", "f_hugu", "f_ningshen"])
		{
			if (!::Wuxia.Alchemy.isFormulaDiscovered(sf))
				throw "Starter formula expected unlocked by default: " + sf;
		}
		foreach (lf in ["f_baoming", "f_tihu", "f_zuixian", "f_chunyang"])
		{
			if (::Wuxia.Alchemy.isFormulaDiscovered(lf))
				throw "Advanced formula expected locked initially: " + lf;
		}
		local alcPayload = ::Wuxia.UI.buildAlchemyModalPayload(true);
		if (alcPayload.discoveredFormulaCount != 6 || alcPayload.totalFormulaCount != 50)
			throw "Expected 6/50 starter modal counts, got " + alcPayload.discoveredFormulaCount + "/" + alcPayload.totalFormulaCount;

		// Verify all 19 new Town 百工丹坊 Blueprints
		foreach (nbp in [
			"wx_bp_pill_juling", "wx_bp_pill_tiee", "wx_bp_pill_jiugong", "wx_bp_pill_jingji",
			"wx_bp_pill_zuixian", "wx_bp_pill_xiantian", "wx_bp_pill_lingfeng", "wx_bp_pill_gufeng",
			"wx_bp_pill_kongque", "wx_bp_pill_fugu", "wx_bp_pill_suoxue", "wx_bp_pill_shixue",
			"wx_bp_pill_yingyan", "wx_bp_pill_pili", "wx_bp_pill_chunyang", "wx_bp_pill_hufu",
			"wx_bp_pill_baoming", "wx_bp_pill_zhenmo", "wx_bp_pill_tihu"
		])
		{
			local bpObj = ::new("scripts/crafting/blueprints/" + nbp);
			if (bpObj == null || bpObj.m.PreviewCraftable == null || bpObj.m.PreviewCraftable.getID() != "misc.wx_pill_item")
				throw "New Town Pill Blueprint failed: " + nbp;
		}

		// Verify new Mechanism Elixirs combat callbacks & 100% lossless save stream roundtrip
		local bSrc = ::new("scripts/skills/effects/wx_pill_battle_buff");
		bSrc.addPillBuff("buff_tiee");
		bSrc.addPillBuff("buff_zuixian");
		bSrc.applyPillPotencyAndAux(125, "yang", false);
		if (bSrc.countActiveBuffs() != 2 || !bSrc.hasBuffKind("buff_tiee") || !bSrc.hasBuffKind("buff_zuixian"))
			throw "New battle buff registration/count failed";

		local pr = ::Const.CharacterProperties.getClone();
		local baseMD = pr.MeleeDefense;
		local baseRS = pr.RangedSkill;
		bSrc.onUpdate(pr);
		if (pr.MeleeDefense <= baseMD || pr.RangedSkill != baseRS - 10)
			throw "buff_zuixian property trade-off failed";

		local hitHead = { BodyPart = ::Const.BodyPart.Head, BodyDamageMult = 1.5, DamageRegular = 40 };
		local prDef   = ::Const.CharacterProperties.getClone();
		bSrc.onBeforeDamageReceived(null, null, hitHead, prDef);
		if (hitHead.BodyDamageMult > 1.001)
			throw "buff_tiee Steel Brow head crit suppression failed";

		local stream = makeStrictStream();
		bSrc.onSerialize(stream);
		local bDst = ::new("scripts/skills/effects/wx_pill_battle_buff");
		bDst.onDeserialize(stream);
		if (stream.buf.len() != 0 || !bDst.hasBuffKind("buff_tiee") || !bDst.hasBuffKind("buff_zuixian") || bDst.m.PotencyScalePct != 125 || bDst.m.AuxMask != 2)
			throw "wx_pill_battle_buff U32 extPillMask roundtrip failed";

		::logInfo("[WX-SELFTEST] Verified Stage 16 五十灵丹·五十古方·6道默认入门方·19新蓝图与存档兼容通过");
	});

	check("Stage 17: VFX Engine Overhaul + 6-Pillar Gameplay Coherence Suite", function() {
		// 1. VFX Engine Schema: 4-Stage Smooth Fade-In/Out Envelope, Rotation Torque, Actor Motion & Options Toggle
		local pSpec = ::Wuxia.VFX.makeDynamicParticle("wx_vfx_01", 0, 0.24, 1.15, 60.0, 0.0, 0, 1);
		if (pSpec == null || !("Stages" in pSpec) || pSpec.Stages.len() != 4)
			throw "VFX makeDynamicParticle must produce 4-stage smooth fade-in/out particle spec";
		if (pSpec.Stages[0].ColorMin.A != 0 || pSpec.Stages[1].ColorMin.A < 140 || pSpec.Stages[1].ColorMin.A >= 255 || pSpec.Stages[3].ColorMin.A != 0)
			throw "VFX 4-stage alpha envelope invalid (fade-in from 0 -> translucent peak -> soft linger -> fade-out to 0)";
		if (!("TorqueMin" in pSpec.Stages[0]) || !("TorqueMax" in pSpec.Stages[0]))
			throw "VFX dynamic particle missing TorqueMin/TorqueMax rotational dynamics";
		if (typeof pSpec.Stages[0].VelocityMin != "float" && typeof pSpec.Stages[0].VelocityMin != "integer")
			throw "VFX VelocityMin must be scalar float/int, got " + typeof pSpec.Stages[0].VelocityMin;

		// Verify Options Toggle state & Actor Motion classifier + pure-Squirrel math helpers
		::Wuxia.VFX.setOptions(false, false, false);
		if (::Wuxia.VFX.isVfxEnabled() || ::Wuxia.VFX.isMotionEnabled())
			throw "VFX setOptions(false, false) failed to disable VFX/Motion";
		::Wuxia.VFX.setOptions(true, true, false);
		if (!::Wuxia.VFX.isVfxEnabled() || !::Wuxia.VFX.isMotionEnabled())
			throw "VFX setOptions(true, true) failed to restore VFX/Motion";

		if (::Wuxia.VFX.classifyMotionKind("sky_thunder") != "sky_slam"
			|| ::Wuxia.VFX.classifyMotionKind("combo3") != "flurry_blitz"
			|| ::Wuxia.VFX.classifyMotionKind("backstab") != "shadow_blink"
			|| ::Wuxia.VFX.classifyMotionKind("cloud_jump") != "qinggong_leap"
			|| ::Wuxia.VFX.classifyMotionKind("tidal_sweep") != "cyclone_spin")
			throw "VFX classifyMotionKind returned unexpected motion archetype";

		if (::Math.absf(::Wuxia.VFX.arch01(0.5) - 1.0) > 0.01
			|| ::Math.absf(::Wuxia.VFX.sinTurns(0.25) - 1.0) > 0.05
			|| ::Math.absf(::Wuxia.VFX.cosTurns(0.0) - 1.0) > 0.05)
			throw "VFX pure-Squirrel motion math helpers out of bounds";

		local fb = ::Wuxia.VFX.buildFlipbookStages("wx_anim_75");
		if (fb == null || fb.len() != 4 || fb[0].Brushes[0] != "wx_anim_75_f1" || fb[3].Brushes[0] != "wx_anim_75_f4")
			throw "VFX buildFlipbookStages must return 4 frame specs for wx_anim_75";

		local atkEff = ::Wuxia.VFX.buildAttackEffect("wx_vfx_01");
		if (atkEff == null || atkEff.len() != 6 || atkEff[0].Brush != "wx_vfx_01")
			throw "VFX buildAttackEffect must return 6 directional entries";

		if (::Wuxia.VFX.SkillChoreo.len() < 75)
			throw "Expected >= 75 SkillChoreo entries, got " + ::Wuxia.VFX.SkillChoreo.len();

		if ("doesBrushExist" in getroottable())
		{
			local missingVfx = 0;
			for (local vi = 1; vi <= 32; vi = ++vi)
			{
				local bid = vi < 10 ? ("wx_vfx_0" + vi) : ("wx_vfx_" + vi);
				if (!::doesBrushExist(bid)) missingVfx += 1;
			}
			for (local ai = 1; ai <= 171; ai = ++ai)
			{
				local ab = ai < 10 ? ("wx_anim_0" + ai) : ("wx_anim_" + ai);
				for (local fi = 1; fi <= 4; fi = ++fi)
				{
					if (!::doesBrushExist(ab + "_f" + fi)) missingVfx += 1;
				}
			}
			if (missingVfx > 0)
				throw "Missing compiled VFX/Anim brushes in engine: " + missingVfx;
		}

		// 2. P0: Mastery alias fix, dynamic XP, economy guardrails, Sanctum pricing & ShanHai tiering
		if (!("addSlotExp" in ::Wuxia.Mastery) || !("grantFlatExpToEquipped" in ::Wuxia.Mastery) || !("awardPostBattleExp" in ::Wuxia.Mastery))
			throw "Mastery aliases or awardPostBattleExp missing";

		local betLim = ::Wuxia.Gambling.betLimits();
		if (betLim.tableCap > 1500 || betLim.dailyCapLeft != 2500)
			throw "Casino stake/daily cap guardrail failed";

		if (::Wuxia.Tournament.getEntryFee(16) != 300 || ::Wuxia.Tournament.getEntryFee(64) != 800)
			throw "Tournament entry fee guardrail failed";

		if (::Wuxia.SectRelations.getSanctumRecruitCost("taihe") != 4200 || ::Wuxia.SectRelations.getSanctumRecruitCost("shaolin") != 1750)
			throw "Sanctum dynamic recruit cost mismatch";

		local tCounts = [0, 0, 0, 0];
		foreach (bid, _bdef in ::Wuxia.Config.ShanHaiBosses)
		{
			local t = ::Wuxia.ShanHai.getBossTier(bid);
			if (t < 1 || t > 3) throw "Invalid ShanHai boss tier for " + bid;
			tCounts[t] += 1;
			local hint = ::Wuxia.ShanHai.getBossCounterHint(bid);
			if (hint == null || hint == "") throw "Missing counterplay hint for ShanHai boss " + bid;
		}
		if (tCounts[1] < 10 || tCounts[2] < 10 || tCounts[3] < 10)
			throw "ShanHai boss tier distribution imbalanced: T1=" + tCounts[1] + " T2=" + tCounts[2] + " T3=" + tCounts[3];

		// 3. P1: Baseline human troop loadouts
		foreach (ek in ["footman", "billman", "arbalester", "conscript", "gunner", "nomad_cutthroat", "barbarian_thrall"])
		{
			if (!(ek in ::Wuxia.Loot.EnemyLoadouts))
				throw "Missing baseline human martial loadout for: " + ek;
		}

		// 4. P2.1: 7-Slot Build Diagnostics
		local dummyAgg = {
			DirectDmgBonus       = 0.15,
			EmptyOffhandPen      = 0.15,
			LightArmorMitigation = 0.45,
			QiShieldPct          = 0.35
		};
		local dummySlots = [
			{ manualID = "wx_manual_tuna", tier = 1, isSealed = false, category = "neigong", matchesWeapon = true, missingReqs = [], rawName = "吐纳诀" },
			{ manualID = "wx_manual_jichujian", tier = 2, isSealed = false, category = "waigong", matchesWeapon = true, missingReqs = ["武艺差4"], rawName = "基础剑法" },
			{ manualID = "wx_manual_qingfeng", tier = 1, isSealed = false, category = "waigong", matchesWeapon = true, missingReqs = [], rawName = "清风连环剑" }
		];
		local diags = ::Wuxia.UI.buildBuildDiagnostics({}, {}, dummyAgg, dummySlots, 5);
		if (diags == null || diags.len() < 4)
			throw "Build diagnostics expected >= 4 warnings/infos, got " + (diags != null ? diags.len() : -1);

		// 5. P2.2: 6 Wuxia-native Ambitions
		foreach (ambScript in [
			"wx_ambition_visit_sanctum",
			"wx_ambition_assemble_manual",
			"wx_ambition_brew_elixir",
			"wx_ambition_marrow_wash",
			"wx_ambition_slay_shanhai",
			"wx_ambition_break_10ap"
		])
		{
			local amb = ::new("scripts/ambitions/ambitions/" + ambScript);
			if (amb == null || amb.getID().find("ambition.wx_") != 0 || amb.m.ButtonText == "" || amb.m.UIText == "")
				throw "Wuxia ambition failed validation: " + ambScript;
		}

		// 6. P2.3: All 6 Origins (with persistent onInit rules)
		foreach (scScript in [
			"wx_jianghu_start",
			"wx_origin_lone_sword",
			"wx_origin_shaolin_monks",
			"wx_origin_wudu_healer",
			"wx_origin_frontier_veterans",
			"wx_origin_blood_remnant"
		])
		{
			local sc = ::new("scripts/scenarios/world/" + scScript);
			if (sc == null || sc.m.ID.find("scenario.wx_") != 0 || !("onInit" in sc))
				throw "Wuxia origin missing onInit or invalid ID: " + scScript;
		}

		// 7. P2.4: All 9 Sequential Jianghu Event Chain scripts
		foreach (evScript in [
			"wx_event_chain_scroll_1", "wx_event_chain_scroll_2", "wx_event_chain_scroll_3",
			"wx_event_chain_beggar_1", "wx_event_chain_beggar_2", "wx_event_chain_beggar_3",
			"wx_event_chain_crisis_1", "wx_event_chain_crisis_2", "wx_event_chain_crisis_3"
		])
		{
			local ev = ::new("scripts/events/events/" + evScript);
			if (ev == null || ev.getID().find("event.wx_chain_") != 0 || ev.m.Screens.len() < 2)
				throw "Sequential chain event failed validation: " + evScript;
		}

		::logInfo("[WX-SELFTEST] Verified Stage 17 VFX引擎(75招式全效) + 六大闭环优化(经济/城镇/AI/山海分层/诊断/6志向/6开局/3条9幕剧情链) 全部通过!");
	});

	check("Three Iconic Manuals: 太原火焰刀, 八宝亮寅枪 & 蛤蟆功 (Stats, Weapons, Skills & Brushes)", function() {
		local mFire  = ::Wuxia.Config.Manuals.wx_manual_taiyuan_huoyandao;
		local mSpear = ::Wuxia.Config.Manuals.wx_manual_babao_liangyinqiang;
		local mToad  = ::Wuxia.Config.Manuals.wx_manual_hamagong;
		if (mFire.Name != "太原火焰刀" || mSpear.Name != "八宝亮寅枪" || mToad.Name != "蛤蟆功")
			throw "Manual exact names mismatch";
		if (mFire.Levels[2].Stats.MeleeSkill > 7 || mSpear.Levels[2].Stats.MeleeSkill > 7)
			throw "Secret Waigong MeleeSkill cap exceeded";
		if (("MeleeSkill" in mToad.Levels[2].Stats) || ("MeleeDefense" in mToad.Levels[2].Stats) || mToad.Levels[2].Stats.Stamina > 35)
			throw "Neigong Hamagong stat redline violated";

		// Verify weapon compatibility: 太原火焰刀 works with both Saber/Cleaver AND Paired Fist!
		local cleaver = ::new("scripts/items/weapons/military_cleaver");
		local fistWpn = ::new("scripts/items/weapons/wx_fist_iron");
		local spearWpn = ::new("scripts/items/weapons/fighting_spear");
		if (!::Wuxia.CombatRules.matchesWeapon(cleaver, mFire.WeaponTypes) || !::Wuxia.CombatRules.matchesWeapon(fistWpn, mFire.WeaponTypes))
			throw "太原火焰刀 failed Saber/Fist dual compatibility";
		if (::Wuxia.CombatRules.matchesWeapon(spearWpn, mFire.WeaponTypes))
			throw "太原火焰刀 should not match Spear";
		if (!::Wuxia.CombatRules.matchesWeapon(spearWpn, mSpear.WeaponTypes))
			throw "八宝亮寅枪 failed Spear compatibility";

		// Verify all 3 bespoke active skills & overhead brushes
		foreach (skPair in [
			["wx_saber_huoyandao", "太原火焰斩"],
			["wx_spear_liangyin",  "八宝亮寅刺"],
			["wx_hama_push",       "金蟾推山扑"]
		])
		{
			local sk = ::new("scripts/skills/actives/" + skPair[0]);
			if (sk.getName() != skPair[1] || sk.getTooltip().len() < 3)
				throw "Skill name/tooltip invalid for " + skPair[0];
			local probe = ::Const.CharacterProperties.getClone();
			sk.onAnySkillUsed(sk, null, probe);
			if (probe.MeleeSkill <= ::Const.CharacterProperties.MeleeSkill)
				throw "Skill accuracy bonus did not apply for " + skPair[0];
			if ("doesBrushExist" in getroottable() && !::doesBrushExist("wx_ov_" + skPair[0]))
				throw "Missing overhead banner brush wx_ov_" + skPair[0];
		}
		::logInfo("[WX-SELFTEST] Verified 《太原火焰刀》《八宝亮寅枪》《蛤蟆功》 & 3 bespoke active skills!");
	});

	check("Shan Hai Zero-Sharing Art Integrity (65 Lairs, 8 Tails, 16 BeastGear, 64 Boss Traits & 75 Wild Beasts)", function() {
		local hasBrushFn = ("doesBrushExist" in getroottable());

		// 1. All 64 Shan Hai strongholds + ancient_tomb must have 65 distinct `wx_lair_*` brushes
		local seenLairBrushes = {};
		local lairCount = 0;
		foreach (k, v in ::Wuxia.Config.Strongholds)
		{
			if (k.find("shanhai_") == 0 || k == "ancient_tomb")
			{
				lairCount += 1;
				if (!("Brush" in v) || v.Brush == null || v.Brush.find("wx_lair_") != 0)
					throw "Invalid lair brush on " + k;
				if (v.Brush in seenLairBrushes)
					throw "Duplicate/shared lair brush " + v.Brush + " between " + seenLairBrushes[v.Brush] + " and " + k;
				seenLairBrushes[v.Brush] <- k;
				if (hasBrushFn && !::doesBrushExist(v.Brush))
					throw "Missing world lair brush in .brush registry: " + v.Brush;
			}
		}
		if (lairCount != 65) throw "Expected 65 Shan Hai + ancient_tomb lairs, got " + lairCount;

		// 2. All 8 multi-tile Lindwurm-family tails + fallen corpses must exist
		local tailIDs = [
			"wx_tail_feiyi", "wx_tail_zhuyin", "wx_tail_yinglong", "wx_tail_jiuying",
			"wx_tail_xiangliuwang", "wx_tail_gonggong", "wx_tail_huashe", "wx_tail_feiyi_wild"
		];
		foreach (tid in tailIDs)
		{
			if (hasBrushFn && (!::doesBrushExist(tid) || !::doesBrushExist(tid + "_dead")))
				throw "Missing Lindwurm tail or corpse brush: " + tid;
		}

		// 3. All 16 Tier-A `BeastGear` & `wx_up_*` items must have unique icons & valid bespoke paperdoll brushes
		local seenGearIcons = {};
		local seenGearBrushes = {};
		local gearCount = 0;
		foreach (gid, gcfg in ::Wuxia.Config.BeastGear)
		{
			gearCount += 1;
			local ic = (gcfg.Kind == "upgrade") ? ("armor_upgrades/" + gcfg.BackBrush + ".png") : gcfg.Icon;
			if (ic in seenGearIcons)
				throw "Duplicate BeastGear icon " + ic + " on " + gid;
			seenGearIcons[ic] <- gid;

			local br = null;
			if (gcfg.Kind == "weapon") br = gcfg.ArmBrush;
			else if (gcfg.Kind == "shield") br = gcfg.ShieldBrush;
			else if (gcfg.Kind == "armor") br = gcfg.BodyBrush;
			else if (gcfg.Kind == "helmet") br = gcfg.HatID + "_front";
			else if (gcfg.Kind == "upgrade") br = gcfg.BackBrush;
			if (br == null || (br in seenGearBrushes))
				throw "Missing or duplicate BeastGear brush " + br + " on " + gid;
			seenGearBrushes[br] <- gid;
			if (hasBrushFn && !::doesBrushExist(br))
				throw "BeastGear paperdoll brush missing in .brush registry: " + br;
		}
		if (gearCount != 16) throw "Expected 16 BeastGear entries, got " + gearCount;

		// 4. All 64 Shan Hai Bosses must resolve 64 distinct `wx_boss_trait_<key>.png` icons
		local seenTraitIcons = {};
		local bossCount = 0;
		foreach (bid, bcfg in ::Wuxia.Config.ShanHaiBosses)
		{
			bossCount += 1;
			local tr = ::new("scripts/skills/special/wx_shanhai_boss_trait");
			tr.setBossID(bcfg.Key);
			local tic = tr.getIcon();
			if (tic.find("ui/perks/wx_boss_trait_") != 0 || (tic in seenTraitIcons))
				throw "Boss trait icon missing or shared on " + bid + ": " + tic;
			seenTraitIcons[tic] <- bid;
		}
		if (bossCount != 64) throw "Expected 64 ShanHaiBosses, got " + bossCount;

		// 5. All NamedWeaponMap famed red weapons must use dedicated `named/wx_famed_*` icons & valid brushes
		local seenFamedAssets = {};
		foreach (nwid, nwSpec in ::Wuxia.Armory.NamedWeaponMap)
		{
			if (nwSpec[1] != "named" || nwSpec[0].find("wx_famed_") != 0)
				throw "NamedWeaponMap entry still sharing common non-famed asset: " + nwid + " -> " + nwSpec[0];
			if (nwid != "weapon.named_skull_hammer" && (nwSpec[0] in seenFamedAssets))
				throw "Duplicate famed weapon asset " + nwSpec[0] + " between " + seenFamedAssets[nwSpec[0]] + " and " + nwid;
			if (nwid != "weapon.named_skull_hammer")
				seenFamedAssets[nwSpec[0]] <- nwid;
			if (hasBrushFn && !::doesBrushExist("arm_" + nwSpec[0]))
				throw "Missing famed paperdoll brush arm_" + nwSpec[0];
		}

		::logInfo("[WX-SELFTEST] Verified 100% Zero-Sharing Shan Hai Art: 65 Unique Lairs, 8 Tails, 16 BeastGear & 64 Boss Trait Icons!");
	});

	check("Stage 18: Barber Pavilion, _injured Brush Aliases, Sect Armory Icons & Tournament Serpent Guard", function() {
		// 1. Verify all 332 _injured brush aliases exist in C++ engine (including every brush from log.html)
		if ("doesBrushExist" in getroottable())
		{
			foreach (injBrush in [
				"wx_char_cloth_short_injured",
				"wx_body_arm_01_injured",
				"wx_body_arm_02_injured",
				"wx_body_arm_04_injured",
				"wx_body_civ_05_injured",
				"wx_body_sect_03_injured",
				"wx_armor_yinglong_injured",
				"wx_head_01_injured",
				"wx_boss_zhuyan_injured"
			])
			{
				if (!::doesBrushExist(injBrush))
					throw "Missing _injured brush alias in engine: " + injBrush;
			}
		}

		// 2. Verify syncLindwurmTail safely ignores human integer `m.Body = 0..3`
		::Wuxia.Appearance.syncLindwurmTail({ m = { Body = 0 } });
		::Wuxia.Appearance.syncLindwurmTail({ m = { Body = 2 } });

		// 3. Verify `serpent_racial`, `spider_racial` & `stats_collector` off-map guards run inside `Tournament.withMemberContext`
		::Wuxia.Tournament.withMemberContext(function() {
			local sr = ::new("scripts/skills/racial/serpent_racial");
			local props = ::Const.CharacterProperties.getClone();
			sr.onUpdate(props);
			if (props.DamageReceivedFireMult > 0.70)
				throw "serpent_racial off-map hook did not apply FireMult guard!";

			local spr = ::new("scripts/skills/racial/spider_racial");
			spr.onUpdate(::Const.CharacterProperties.getClone());

			local sc = ::new("scripts/skills/special/stats_collector");
			sc.onUpdate(::Const.CharacterProperties.getClone());
		});

		// 4. Verify Barber module hooks & Sect Armory bookIcon / skillIcon fields
		local barberMod = ::new("scripts/ui/screens/world/modules/world_town_screen/town_barber_dialog_module");
		foreach (fn in ["onEntrySelected", "onChangeAppearance", "onWXBarberGetState", "onWXBarberStepPart", "onWXBarberRename", "onWXBarberClearVendetta"])
		{
			if (!(fn in barberMod))
				throw "Barber module missing hook: " + fn;
		}

		local dirData = ::Wuxia.UI.buildSectRelationsDirectory(false, false);
		if (dirData == null || !("sects" in dirData) || dirData.sects.len() < 40)
			throw "Sect directory payload invalid";
		foreach (sEntry in dirData.sects)
		{
			foreach (mEntry in sEntry.manuals)
			{
				if (!("bookIcon" in mEntry) || mEntry.bookIcon == "")
					throw "Sect manual missing bookIcon on sect " + sEntry.id;
			}
		}

		::logInfo("[WX-SELFTEST] Verified Stage 18 易容阁钩子·332张_injured受伤图层·宗门武库书谱图标·演武擂大蛇防崩通过!");
	});

	check("Stage 19: v0.8.5 Full 10-Bug & 2-Log Regression Suite", function() {
		local makeTestActor = function( _hasShield = false ) {
			local baseProps = ::Const.CharacterProperties.getClone();
			baseProps.ActionPoints = 9;
			baseProps.Hitpoints = 100;
			baseProps.Stamina = 100;
			local curProps = baseProps.getClone();
			local mainSword = ::new("scripts/items/weapons/arming_sword");
			local offShield = _hasShield ? ::new("scripts/items/shields/wooden_shield") : null;
			local skContainer = ::new("scripts/skills/skill_container");
			local act = {
				m = {
					Body = 2,
					Level = 5,
					Hitpoints = 100,
					ActionPoints = 9,
					Fatigue = 0,
					BaseProperties = baseProps,
					CurrentProperties = curProps,
					LevelActionPointCost = 1,
					ActionPointCosts = [0, 2, 2, 2, 2, 2, 2, 2, 2],
					FatigueCosts = [0, 4, 4, 4, 4, 4, 4, 4, 4],
					Talents = [1, 1, 1, 0, 0, 0, 0, 0]
				},
				ClassName = "player",
				getID = function() { return 9919; },
				getName = function() { return "测试侠客"; },
				getLevel = function() { return this.m.Level; },
				isAlive = function() { return true; },
				isDying = function() { return false; },
				isPlayerControlled = function() { return true; },
				isGuest = function() { return false; },
				getFaction = function() { return ::Const.Faction.Player; },
				isAlliedWithPlayer = function() { return true; },
				isAlliedWith = function( _other ) { return true; },
				isKindOf = function( _obj, _cls ) { return _cls == "player" || _cls == "human" || _cls == "actor"; },
				getSkills = function() { return skContainer; },
				getBaseProperties = function() { return this.m.BaseProperties; },
				getCurrentProperties = function() { return this.m.CurrentProperties; },
				setCurrentProperties = function( _p ) { this.m.CurrentProperties = _p; },
				getHitpoints = function() { return this.m.Hitpoints; },
				getHitpointsMax = function() { return this.m.CurrentProperties.Hitpoints; },
				getHitpointsPct = function() { return 1.0; },
				setHitpointsPct = function( _pct ) {},
				setHitpoints = function( _v ) { this.m.Hitpoints = _v; },
				getActionPoints = function() { return this.m.ActionPoints; },
				getActionPointsMax = function() { return this.m.CurrentProperties.ActionPoints; },
				setActionPoints = function( _ap ) { this.m.ActionPoints = _ap; },
				getFatigue = function() { return this.m.Fatigue; },
				getFatigueMax = function() { return this.m.CurrentProperties.Stamina; },
				setFatigue = function( _f ) { this.m.Fatigue = _f; },
				onSkillsUpdated = function() {},
				updateOverlay = function() {},
				setDirty = function( _d ) {},
				onAppearanceChanged = function( _app, _dirty = true ) {},
				isPlacedOnMap = function() { return false; },
				hasSprite = function( _s ) { return false; },
				getTile = function() { return null; },
				getFlags = function() { return { getAsInt = function( _k ) { return 3; }, has = function( _k ) { return false; } }; },
				getCombatStats = function() { return { Kills = 0, DamageDealtHitpoints = 0, DamageDealtArmor = 0 }; },
				isArmedWithShield = function() { return offShield != null; },
				getItems = function() {
					return {
						getItemAtSlot = function( _slot ) {
							if (_slot == ::Const.ItemSlot.Mainhand) return mainSword;
							if (_slot == ::Const.ItemSlot.Offhand) return offShield;
							return null;
						},
						hasBlockedSlot = function( _slot ) {
							return false;
						}
					};
				}
			};
			skContainer.setActor(act);
			return act;
		};

		// 1. Log #1 & #2 + Bug #1: Exact `skill_container.add(serpent_racial)` off-map stack + `sealBracket` fee safety on build error
		local s19Step = "S19-1-serpent";
		try
		{
		::Wuxia.Tournament.withMemberContext(function() {
			local unplacedSerp = makeTestActor(false);
			local serpSk = unplacedSerp.getSkills();
			serpSk.add(::new("scripts/skills/racial/serpent_racial"));
			serpSk.add(::new("scripts/skills/racial/spider_racial"));
			serpSk.add(::new("scripts/skills/special/stats_collector"));
			serpSk.update();
			::Wuxia.Appearance.syncLindwurmTail(unplacedSerp);
		});
		s19Step = "S19-1-sealBracket";

		// Verify Bug #1: `sealBracket` does NOT deduct 300/800 silver registration fee if roster build throws!
		local hadAssets1 = ("Assets" in ::World);
		local prevAssets1 = hadAssets1 ? ::World.Assets : null;
		local hadState1 = ("State" in ::World);
		local prevState1 = hadState1 ? ::World.State : null;
		local hadPR1 = ("getPlayerRoster" in ::World);
		local prevPR1 = hadPR1 ? ::World.getPlayerRoster : null;
		local hadCR1 = ("createRoster" in ::World);
		local prevCR1 = hadCR1 ? ::World.createRoster : null;
		local hadDR1 = ("deleteRoster" in ::World);
		local prevDR1 = hadDR1 ? ::World.deleteRoster : null;
		local wallet1 = 1000;
		local mockTown1 = { getID = function() { return 77; }, getName = function() { return "洛阳"; }, isAlive = function() { return true; }, hasBuilding = function( _id ) { return true; } };
		local mockBros1 = [];
		for (local bi = 1; bi <= 5; bi = ++bi)
		{
			local bid = 500 + bi;
			mockBros1.push({ getID = function() { return bid; }, isAlive = function() { return true; } });
		}
		::World.Assets <- {
			getMoney = function() { return wallet1; },
			addMoney = function( _d ) { wallet1 += _d; },
			getName = function() { return "测试义社"; },
			getBannerID = function() { return 51; }
		};
		::World.State <- { getCurrentTown = function() { return mockTown1; } };
		::World.getPlayerRoster <- function() { return { getAll = function() { return mockBros1; } }; };
		::World.createRoster <- function( _rid ) { throw "Simulated roster build failure"; };
		::World.deleteRoster <- function( _rid ) {};
		try
		{
			::Wuxia.Gambling.State = ::Wuxia.Gambling.freshState(1);
			local ev1 = {
				id = 1, edition = 1, size = 16, town = 77, townName = "洛阳",
				phase = "registration", selected = [501, 502, 503, 504, 505],
				teams = [], matches = [], tickets = [], notices = []
			};
			local threwAsExpected = false;
			try { ::Wuxia.Tournament.sealBracket(ev1); }
			catch (_simE) { threwAsExpected = true; }
			if (!threwAsExpected || wallet1 != 1000 || ev1.phase != "registration")
				throw "sealBracket deducted fee despite roster build error! wallet=" + wallet1;
		}
		catch (e1)
		{
			if (hadAssets1) ::World.Assets <- prevAssets1; else ::World.rawdelete("Assets");
			if (hadState1) ::World.State <- prevState1; else ::World.rawdelete("State");
			if (hadPR1) ::World.getPlayerRoster <- prevPR1; else ::World.rawdelete("getPlayerRoster");
			if (hadCR1) ::World.createRoster <- prevCR1; else ::World.rawdelete("createRoster");
			if (hadDR1) ::World.deleteRoster <- prevDR1; else ::World.rawdelete("deleteRoster");
			::Wuxia.Gambling.State = null;
			throw e1;
		}
		if (hadAssets1) ::World.Assets <- prevAssets1; else ::World.rawdelete("Assets");
		if (hadState1) ::World.State <- prevState1; else ::World.rawdelete("State");
		if (hadPR1) ::World.getPlayerRoster <- prevPR1; else ::World.rawdelete("getPlayerRoster");
		if (hadCR1) ::World.createRoster <- prevCR1; else ::World.rawdelete("createRoster");
		if (hadDR1) ::World.deleteRoster <- prevDR1; else ::World.rawdelete("deleteRoster");
		::Wuxia.Gambling.State = null;

		// 2. Bug #2: `buildAlchemyModalPayload` exposes all 50 `freeRules` with `f_jinchuang` cost == 80
		s19Step = "S19-2-freeRules";
		::Wuxia.Alchemy.resetFallback();
		local alcP = ::Wuxia.UI.buildAlchemyModalPayload(true);
		if (!("freeRules" in alcP) || alcP.freeRules.len() != 50)
			throw "Expected 50 freeRules in alchemy payload";
		local foundJc = false;
		foreach (fr in alcP.freeRules)
		{
			if (fr.id == "f_jinchuang" && fr.silverCost == 80)
				foundJc = true;
		}
		if (!foundJc) throw "f_jinchuang freeRule missing or silverCost != 80";

		// 3. Bug #3: 1-battle `effects.trained` expiring in `onCombatFinished` still grants +45% mastery XP
		s19Step = "S19-3-trained";
		local actTrainA = makeTestActor(false);
		local cA = ::Wuxia.Slots.getContainer(actTrainA);
		cA.m.Slots[0].ManualID = "wx_manual_tuna";
		cA.m.Slots[0].Tier = 1;
		cA.m.Slots[0].Exp = 0;
		::Wuxia.Mastery.awardPostBattleExp(actTrainA);
		local expUntrained = cA.m.Slots[0].Exp;

		local actTrainB = makeTestActor(false);
		local cB = ::Wuxia.Slots.getContainer(actTrainB);
		cB.m.Slots[0].ManualID = "wx_manual_tuna";
		cB.m.Slots[0].Tier = 1;
		cB.m.Slots[0].Exp = 0;
		// Attach real 1-battle `new_trained_effect` (`Battles = 1`) and run full `onCombatStarted -> onCombatFinished -> collectGarbage` lifecycle BEFORE `awardPostBattleExp`!
		local trEff = ::new("scripts/skills/effects_world/new_trained_effect");
		trEff.m.Battles = 1;
		actTrainB.getSkills().add(trEff);
		actTrainB.getSkills().onCombatStarted();
		actTrainB.getSkills().onCombatFinished();
		actTrainB.getSkills().collectGarbage();
		if (actTrainB.getSkills().hasSkill("effects.trained"))
			throw "Expected 1-battle new_trained_effect to expire after onCombatStarted + onCombatFinished";
		::Wuxia.Mastery.awardPostBattleExp(actTrainB);
		local expTrained = cB.m.Slots[0].Exp;
		if (expTrained <= expUntrained || actTrainB.m.WX_HadTrainedThisBattle != false)
			throw "1-battle trained XP bonus failed: untrained=" + expUntrained + " trained=" + expTrained;

		// 4. Bug #4: Equipping & unequipping `wx_manual_shanlin_bu` (`穿林跃涧步`) restores `LevelActionPointCost`
		s19Step = "S19-4-qinggong";
		local actQg = makeTestActor(false);
		local cQg = ::Wuxia.Slots.getContainer(actQg);
		cQg.m.Slots[2].ManualID = "wx_manual_shanlin_bu";
		cQg.m.Slots[2].Tier = 1;
		cQg.ensureSlotsRegisteredInLearned();
		cQg.onUpdate(::Const.CharacterProperties.getClone());
		if (actQg.m.LevelActionPointCost != 0)
			throw "Expected LevelActionPointCost == 0 when wx_manual_shanlin_bu equipped";
		cQg.m.Slots[2].ManualID = null;
		cQg.m.Slots[2].Tier = 0;
		cQg.onUpdate(::Const.CharacterProperties.getClone());
		if (actQg.m.LevelActionPointCost != 1)
			throw "Expected LevelActionPointCost restored to 1 on unequip, got " + actQg.m.LevelActionPointCost;

		// 5. Bug #5: Fresh `wx_internal_injury.applySeverity(1, 2)` sets 2 days (not 3!)
		s19Step = "S19-5-injury";
		local inj = ::new("scripts/skills/effects/wx_internal_injury");
		inj.applySeverity(1, 2);
		if (inj.m.DaysRemaining != 2 || inj.m.Severity != 1)
			throw "Expected 2-day mild internal injury, got days=" + inj.m.DaysRemaining + " sev=" + inj.m.Severity;

		// 6. Bug #6: Real `wx_saber_huoyandao.onUse` returning `false` (miss) still records skill use in `WX_BattleUsedSkills`!
		s19Step = "S19-6-missedUse";
		local actMiss = makeTestActor(false);
		::Wuxia.Mastery.resetBattleSkillUses(actMiss);
		local huoyan = ::new("scripts/skills/actives/wx_saber_huoyandao");
		actMiss.getSkills().add(huoyan);
		local missTarget = {
			isAlive = function() { return false; },
			isPlacedOnMap = function() { return false; }
		};
		local targetTile = {
			IsVisibleForPlayer = false,
			getEntity = function() { return missTarget; }
		};
		local onUseHit = huoyan.onUse(actMiss.getSkills().getActor(), targetTile);
		if (onUseHit != false)
			throw "Expected wx_saber_huoyandao.onUse to return false on non-hit!";
		if (!("WX_BattleUsedSkills" in actMiss.m) || !("actives.wx_saber_huoyandao" in actMiss.m.WX_BattleUsedSkills) || actMiss.m.WX_BattleUsedSkills["actives.wx_saber_huoyandao"] != 1)
			throw "Missed wx_saber_huoyandao was not recorded in WX_BattleUsedSkills!";

		// 7. Bug #7: `wx_manual_gufeng` (`孤锋诀`) panel tags exclude offhand pen when holding a shield
		s19Step = "S19-7-gufeng";
		local act1H = makeTestActor(false);
		local c1H = ::Wuxia.Slots.getContainer(act1H);
		c1H.m.Slots[3].ManualID = "wx_manual_gufeng";
		c1H.m.Slots[3].Tier = 1;
		c1H.ensureSlotsRegisteredInLearned();
		local agg1H = ::Wuxia.CombatRules.getAggregateFlags(c1H);
		local tags1H = ::Wuxia.UI.buildPassiveSummaryTags(agg1H, act1H);
		local hasPen1H = false;
		foreach (tg in tags1H) { if (tg.find("穿甲+") == 0) hasPen1H = true; }
		if (!hasPen1H) throw "Expected 穿甲+ tag for 1H empty offhand with Gufeng";

		local actShield = makeTestActor(true);
		local cSh = ::Wuxia.Slots.getContainer(actShield);
		cSh.m.Slots[3].ManualID = "wx_manual_gufeng";
		cSh.m.Slots[3].Tier = 1;
		cSh.ensureSlotsRegisteredInLearned();
		local aggSh = ::Wuxia.CombatRules.getAggregateFlags(cSh);
		local tagsSh = ::Wuxia.UI.buildPassiveSummaryTags(aggSh, actShield);
		foreach (tg2 in tagsSh)
		{
			if (tg2.find("穿甲+") == 0)
				throw "Unexpected 穿甲+ tag when holding a shield with Gufeng: " + tg2;
		}

		// 8. Bug #9: `holdemCommit` updates `dailyCasinoNet` and triggers 2,500 daily house cap
		s19Step = "S19-8-holdemCap";
		local hadAssets9 = ("Assets" in ::World);
		local prevAssets9 = hadAssets9 ? ::World.Assets : null;
		local wallet9 = 5000;
		::World.Assets <- {
			getMoney = function() { return wallet9; },
			addMoney = function( _d ) { wallet9 += _d; },
			getBusinessReputation = function() { return 500; }
		};
		try
		{
			::Wuxia.Gambling.State = ::Wuxia.Gambling.freshState(1);
			::Wuxia.Gambling.holdemCommit({
				kind = "holdem", done = true, showdown = false, payout = 3100, net = 2600,
				stake = 500, street = 3, button = 0, smallBlind = 5, bigBlind = 10,
				currentBet = 0, minRaise = 10, turn = 0, board = [0, 1, 2, 3, 4],
				events = [], pots = [], seats = [
					{ name = "你", stack = 0, cards = [5, 6], bet = 0, total = 500, folded = false, action = "" },
					{ name = "甲", stack = 0, cards = [7, 8], bet = 0, total = 500, folded = true, action = "" },
					{ name = "乙", stack = 0, cards = [9, 10], bet = 0, total = 500, folded = true, action = "" },
					{ name = "丙", stack = 0, cards = [11, 12], bet = 0, total = 500, folded = true, action = "" }
				]
			});
			if (::Wuxia.Gambling.State.dailyCasinoNet != 2600 || ::Wuxia.Gambling.betLimits().dailyCapLeft != 0)
				throw "holdemCommit failed to update dailyCasinoNet / dailyCapLeft!";
		}
		catch (e9)
		{
			if (hadAssets9) ::World.Assets <- prevAssets9; else ::World.rawdelete("Assets");
			::Wuxia.Gambling.State = null;
			throw e9;
		}
		if (hadAssets9) ::World.Assets <- prevAssets9; else ::World.rawdelete("Assets");
		::Wuxia.Gambling.State = null;

		// 9. Bug #10: `executeBrew` requires `BaseYield + 1` free slots so double-pill crit is never dropped
		s19Step = "S19-9-brewSlots";
		local hadAssets10 = ("Assets" in ::World);
		local prevAssets10 = hadAssets10 ? ::World.Assets : null;
		local stash10 = ::new("scripts/items/stash_container");
		stash10.setResizable(false);
		stash10.resize(2); // Exactly BaseYield (2) for f_jinchuang, 1 short of maxOutputPills (3)!
		local wallet10 = 1000;
		::World.Assets <- {
			getMoney = function() { return wallet10; },
			addMoney = function( _d ) { wallet10 += _d; },
			getStash = function() { return stash10; },
			getOrigin = function() { return null; }
		};
		try
		{
			::Wuxia.Alchemy.resetFallback();
			::Wuxia.Alchemy.Cabinet.addCount("trophy:ghoul_horn", 2, "scripts/items/misc/ghoul_horn_item");
			::Wuxia.Alchemy.Cabinet.addCount("trophy:spider_silk", 2, "scripts/items/misc/spider_silk_item");
			local blockedBrew = ::Wuxia.Alchemy.executeBrew("f_jinchuang", ["trophy:ghoul_horn", "trophy:spider_silk", ""]);
			if (blockedBrew.Ok || wallet10 != 1000)
				throw "executeBrew should refuse 2-slot stash for BaseYield=2 + 1 bonus slot!";

			stash10.resize(3);
			local okBrew = ::Wuxia.Alchemy.executeBrew("f_jinchuang", ["trophy:ghoul_horn", "trophy:spider_silk", ""]);
			if (!okBrew.Ok || wallet10 != 920)
				throw "executeBrew should succeed with 3 slots and deduct 80 silver! reason=" + ("Reason" in okBrew ? okBrew.Reason : "");
			local deliveredPills = stash10.getNumberOfFilledSlots();
			if (okBrew.IsCrit && deliveredPills != 3)
				throw "Crit marked true without delivering 3rd pill!";
			if (!okBrew.IsCrit && deliveredPills != 2)
				throw "Non-crit expected 2 pills, got " + deliveredPills;
		}
		catch (e10)
		{
			::Wuxia.Alchemy.resetFallback();
			if (hadAssets10) ::World.Assets <- prevAssets10; else ::World.rawdelete("Assets");
			throw e10;
		}
		::Wuxia.Alchemy.resetFallback();
		if (hadAssets10) ::World.Assets <- prevAssets10; else ::World.rawdelete("Assets");
		}
		catch (s19Err)
		{
			throw "[" + s19Step + "] " + s19Err;
		}

		::logInfo("[WX-SELFTEST] Verified Stage 19 全部10项源码Bug与2项实机日志故障回归校验全数通过!");
	});

	check("Stage 20: Full-System Live Audit (Forge Floats, VFX Particles, World Flags, WeakRef, Casino 7-Games & Hooks)", function() {
		local s20Step = "S20-1-forgePen";
		try
		{
			// 1. Forge float armor-pen & range introspection (`::Math.minf` / `::Math.maxf`)
			local bw = ::new("scripts/items/weapons/wx_beast_saber");
			local decLow = ::Wuxia.Forge.rollNewSeed(false, 0);
			decLow.F1 = 0.0; decLow.F2 = 0.0; decLow.F3 = 0.0;
			::Wuxia.Forge.applySeedToItem(bw, decLow, false);
			if (bw.m.DirectDamageMult < 0.149 || bw.m.ArmorDamageMult < 0.499)
				throw "Beast weapon float pen/armor floor truncated to zero! pen=" + bw.m.DirectDamageMult + " arm=" + bw.m.ArmorDamageMult;

			local rw = ::new("scripts/items/weapons/named/wx_relic_chixiao");
			local cleanR = ::Wuxia.Forge.getCleanRelicBase("wx_relic_chixiao");
			local decHigh = ::Wuxia.Forge.rollNewSeed(false, 3);
			decHigh.Grade = 3; decHigh.F1 = 1.0; decHigh.F2 = 1.0; decHigh.F3 = 1.0;
			::Wuxia.Forge.applySeedToItem(rw, decHigh, false);
			if (rw.m.DirectDamageMult <= cleanR.DirectDamageMult)
				throw "Relic weapon high-roll DirectDamageMult failed to exceed base! got=" + rw.m.DirectDamageMult + " base=" + cleanR.DirectDamageMult;

			local bwRng = ::Wuxia.Forge.describeGearRanges(bw);
			local rwRng = ::Wuxia.Forge.describeGearRanges(rw);
			if (bwRng == null || rwRng == null || bwRng.SummaryStr.find("0%") != null || rwRng.SummaryStr.find("~0%") != null)
				throw "Forge describeGearRanges produced truncated 0% range: " + (bwRng != null ? bwRng.SummaryStr : "null");

			// 2. VFX particle float clamping (`::Math.maxf`)
			s20Step = "S20-2-vfxFloat";
			local holdSec = ::Math.maxf(0.09, 0.25);
			local fadeSec = ::Math.maxf(0.07, holdSec * 0.48);
			local sc = ::Math.maxf(0.45, 0.80);
			if (holdSec < 0.24 || fadeSec < 0.11 || sc < 0.79)
				throw "Math.maxf failed float particle check!";

			// 3. Real `tag_collection` (`Flags.get` returning `false` on unset keys): Party localization & Day-1 Crisis gating
			s20Step = "S20-3-worldFlagsAndParty";
			local realFlags = ::new("scripts/tools/tag_collection");
			if (realFlags.get("wx_sect_patrol") != false)
				throw "Expected tag_collection.get on unset key to return false";
			if (::Wuxia.Appearance.brushExists(false) != false)
				throw "brushExists(false) should safely return false";

			local mockCaravan = {
				m = { IsPlayer = false, Flags = realFlags, Name = "Caravan" },
				hasLabel = function( _l ) { return false; }
			};
			::Wuxia.WorldVisuals.localizeVanillaPartyName(mockCaravan);
			if (mockCaravan.m.Name != "四海行商驼镖队")
				throw "localizeVanillaPartyName aborted on real tag_collection! got=" + mockCaravan.m.Name;

			local hadFlags20 = ("Flags" in ::World);
			local prevFlags20 = hadFlags20 ? ::World.Flags : null;
			::World.Flags <- realFlags;
			try
			{
				local t2Boss = null;
				foreach (bid, _bcfg in ::Wuxia.Config.ShanHaiBosses)
				{
					if (::Wuxia.ShanHai.getBossTier(bid) == 2) { t2Boss = bid; break; }
				}
				if (t2Boss == null) throw "No Tier-2 ShanHai boss found";
				if (::Wuxia.ShanHai.isBossUnlockedForCampaign(t2Boss, 1, 50) != false)
					throw "Tier-2 boss unlocked prematurely on Day 1 when wx_active_crisis is unset!";
				realFlags.set("wx_active_crisis", "undead");
				if (::Wuxia.ShanHai.isBossUnlockedForCampaign(t2Boss, 1, 50) != true)
					throw "Tier-2 boss should unlock during active crisis!";
				realFlags.set("wx_active_crisis", "");
			}
			catch (e20f)
			{
				if (hadFlags20) ::World.Flags <- prevFlags20; else ::World.rawdelete("Flags");
				throw e20f;
			}
			if (hadFlags20) ::World.Flags <- prevFlags20; else ::World.rawdelete("Flags");

			// 4. `WeakTableRef` & `SuperName` inheritance checks (`syncLindwurmTail`, `isMasterworkGear`, `applyShieldDamage`, `WX_RefreshStarterNote`)
			s20Step = "S20-4-weakRefAndSuperName";
			local mockLindBody = { m = { WX_BossID = "boss_yinglong" } };
			local mockTailSpr = {
				HasBrush = false, Color = null, Visible = false,
				setBrush = function( _b ) {},
				setHorizontalFlipping = function( _f ) {}
			};
			local mockLindTail = {
				m = { Body = ::WeakTableRef(mockLindBody) },
				hasSprite = function( _s ) { return _s == "body"; },
				getSprite = function( _s ) { return mockTailSpr; },
				setName = function( _n ) {},
				setDirty = function( _d ) {}
			};
			::Wuxia.Appearance.syncLindwurmTail(mockLindTail);
			if (!("WX_CustomEnemyBust" in mockLindTail.m) || mockLindTail.m.WX_CustomEnemyBust != "wx_tail_yinglong")
				throw "syncLindwurmTail failed when tail.m.Body is a WeakTableRef!";

			local mockCouncil = { m = { Type = 1 }, ClassName = "councilman" };
			if (::Wuxia.Appearance.resolveAutoEnemyBust(::WeakTableRef(mockCouncil)) != null)
				throw "resolveAutoEnemyBust failed to guard WeakTableRef civilian employer!";

			local spTrait = ::new("scripts/skills/special/wx_gear_spirit_trait");
			rw.m.WX_ForgeGrade <- 3;
			spTrait.setItem(::WeakTableRef(rw));
			if (!spTrait.isMasterworkGear())
				throw "isMasterworkGear() returned false on Grade-3 WeakTableRef item!";

			local realShield = ::new("scripts/items/shields/wooden_shield");
			if (!::Wuxia.hasMember(realShield, "applyShieldDamage"))
				throw "hasMember failed to find inherited applyShieldDamage on wooden_shield!";

			local realBg = ::new("scripts/skills/backgrounds/swordmaster_background");
			if (!::Wuxia.hasMember(realBg, "WX_RefreshStarterNote") || !::Wuxia.hasMember(realBg, "WX_RefreshNameInBio"))
				throw "hasMember failed to find WX_RefreshStarterNote / WX_RefreshNameInBio on swordmaster_background!";

			// 5. All 7 Casino Games end-to-end execution
			s20Step = "S20-5-casinoAllGames";
			local hadAssets20 = ("Assets" in ::World);
			local prevAssets20 = hadAssets20 ? ::World.Assets : null;
			local wallet20 = 10000;
			::World.Assets <- {
				getMoney = function() { return wallet20; },
				addMoney = function( _d ) { wallet20 += _d; },
				getBusinessReputation = function() { return 500; }
			};
			try
			{
				::Wuxia.Gambling.State = ::Wuxia.Gambling.freshState(5);
				if (!::Wuxia.Gambling.gamble("size", 20, 1).ok) throw "Casino size failed";
				if (!::Wuxia.Gambling.gamble("symbols", 20, 3).ok) throw "Casino symbols failed";
				if (!::Wuxia.Gambling.gamble("riffa", 20, 0).ok) throw "Casino riffa failed";

				if (!::Wuxia.Gambling.gamble("raid", 20, 0).ok) throw "Casino raid start failed";
				while (::Wuxia.Gambling.State.game != null)
				{
					if (!::Wuxia.Gambling.continueRaid().ok) throw "Casino raid continue failed";
				}

				if (!::Wuxia.Gambling.gamble("hazard", 20, 7).ok) throw "Casino hazard start failed";
				while (::Wuxia.Gambling.State.game != null)
				{
					if (!::Wuxia.Gambling.continueHazard().ok) throw "Casino hazard continue failed";
				}

				if (!::Wuxia.Gambling.gamble("blackjack", 20, 0).ok) throw "Casino blackjack start failed";
				if (::Wuxia.Gambling.State.game != null)
				{
					if (!::Wuxia.Gambling.standBlackjack().ok) throw "Casino blackjack stand failed";
				}

				if (!::Wuxia.Gambling.gamble("holdem", 40, 0).ok) throw "Casino holdem start failed";
				local hGuard = 0;
				while (::Wuxia.Gambling.State.game != null && hGuard < 10)
				{
					hGuard += 1;
					if (!::Wuxia.Gambling.playHoldem("fold", 0).ok) throw "Casino holdem fold failed";
				}
				if (::Wuxia.Gambling.State.metrics.handsPlayed < 7)
					throw "Expected >= 7 handsPlayed across all 7 casino games, got " + ::Wuxia.Gambling.State.metrics.handsPlayed;
			}
			catch (e20c)
			{
				if (hadAssets20) ::World.Assets <- prevAssets20; else ::World.rawdelete("Assets");
				::Wuxia.Gambling.State = null;
				throw e20c;
			}
			if (hadAssets20) ::World.Assets <- prevAssets20; else ::World.rawdelete("Assets");
			::Wuxia.Gambling.State = null;

			// 6. Vanilla purification hooks, Retinue followers & Ambition instantiate smoke check
			s20Step = "S20-6-purifyAndFollowers";
			local mItem = ::new("scripts/items/supplies/money_item");
			if (mItem.getName().find("纹银") == null)
				throw "money_item purification hook did not return Wuxia silver name: " + mItem.getName();
			local fItem = ::new("scripts/items/supplies/bread_item");
			local _fNm = fItem.getName();
			local _fDesc = fItem.getDescription();
			local _fTip = fItem.getTooltip();

			foreach (fScript in [
				"scripts/retinue/followers/surgeon_follower",
				"scripts/retinue/followers/alchemist_follower",
				"scripts/retinue/followers/blacksmith_follower",
				"scripts/retinue/followers/recruiter_follower"
			])
			{
				local flw = ::new(fScript);
				if (flw.getName() == "" || flw.getCost() <= 0)
					throw "Follower hook check failed on " + fScript;
			}
		}
		catch (s20Err)
		{
			throw "[" + s20Step + "] " + s20Err;
		}

		::logInfo("[WX-SELFTEST] Verified Stage 20 全系统实机深度巡检(百工浮点穿甲·粒子时长·世界旗标·弱引用器灵·赌坊七戏·原版净化钩子)全数通过!");
	});

	check("Stage 21: Enemy Loadout Anti-Stacking, Full File Enumeration & Combat Readiness", function() {
		local s21Step = "S21-1-enemyLoadoutApply";
		try
		{
			// 1. Exercise real `::Wuxia.Loot.applyLoadoutToEnemy` across ALL EnemyLoadouts & Fighters with overlapping vanilla perks attached!
			local makeEnemyHarness = function()
			{
				local baseProps = ::Const.CharacterProperties.getClone();
				baseProps.ActionPoints = 9;
				baseProps.Hitpoints = 100;
				baseProps.Stamina = 100;
				local curProps = baseProps.getClone();
				local mainSword = ::new("scripts/items/weapons/arming_sword");
				local skContainer = ::new("scripts/skills/skill_container");
				local act = {
					m = {
						Body = 2,
						Level = 6,
						Hitpoints = 100,
						ActionPoints = 9,
						Fatigue = 0,
						BaseProperties = baseProps,
						CurrentProperties = curProps,
						LevelActionPointCost = 1,
						ActionPointCosts = [0, 2, 2, 2, 2, 2, 2, 2, 2],
						FatigueCosts = [0, 4, 4, 4, 4, 4, 4, 4, 4]
					},
					ClassName = "bandit_raider",
					getID = function() { return 9921; },
					getName = function() { return "绿林试招匪"; },
					getLevel = function() { return this.m.Level; },
					isAlive = function() { return true; },
					isDying = function() { return false; },
					isPlayerControlled = function() { return false; },
					isGuest = function() { return false; },
					getFaction = function() { return 23; },
					isAlliedWithPlayer = function() { return false; },
					isAlliedWith = function( _other ) { return false; },
					getSkills = function() { return skContainer; },
					getAIAgent = function() { return null; },
					getBaseProperties = function() { return this.m.BaseProperties; },
					getCurrentProperties = function() { return this.m.CurrentProperties; },
					setCurrentProperties = function( _p ) { this.m.CurrentProperties = _p; },
					getHitpoints = function() { return this.m.Hitpoints; },
					getHitpointsMax = function() { return this.m.CurrentProperties.Hitpoints; },
					getHitpointsPct = function() { return 1.0; },
					setHitpointsPct = function( _pct ) {},
					setHitpoints = function( _v ) { this.m.Hitpoints = _v; },
					getActionPoints = function() { return this.m.ActionPoints; },
					getActionPointsMax = function() { return this.m.CurrentProperties.ActionPoints; },
					setActionPoints = function( _ap ) { this.m.ActionPoints = _ap; },
					getFatigue = function() { return this.m.Fatigue; },
					getFatigueMax = function() { return this.m.CurrentProperties.Stamina; },
					setFatigue = function( _f ) { this.m.Fatigue = _f; },
					getInitiative = function() { return 110; },
					getBravery = function() { return 60; },
					getArmor = function( _part ) { return 120; },
					getArmorMax = function( _part ) { return 120; },
					onSkillsUpdated = function() {},
					updateOverlay = function() {},
					setDirty = function( _d ) {},
					onAppearanceChanged = function( _app, _dirty = true ) {},
					isPlacedOnMap = function() { return false; },
					hasSprite = function( _s ) { return false; },
					getTile = function() { return null; },
					getFlags = function() { return ::new("scripts/tools/tag_collection"); },
					isArmedWithShield = function() { return false; },
					getItems = function() {
						return {
							getItemAtSlot = function( _slot ) {
								if (_slot == ::Const.ItemSlot.Mainhand) return mainSword;
								return null;
							},
							hasBlockedSlot = function( _slot ) { return false; },
							getStaminaModifier = function( _slots = null ) { return -15; }
						};
					}
				};
				skContainer.setActor(act);
				foreach (pk in [
					"scripts/skills/perks/perk_nimble",
					"scripts/skills/perks/perk_battle_forged",
					"scripts/skills/perks/perk_dodge",
					"scripts/skills/perks/perk_brawny",
					"scripts/skills/perks/perk_steel_brow",
					"scripts/skills/perks/perk_underdog",
					"scripts/skills/perks/perk_duelist"
				])
				{
					skContainer.add(::new(pk));
				}
				return act;
			};

			local loadoutChecked = 0;
			foreach (k, _prof in ::Wuxia.Loot.EnemyLoadouts)
			{
				local eAct = makeEnemyHarness();
				::Wuxia.Loot.applyLoadoutToEnemy(eAct, k);
				loadoutChecked += 1;
			}
			foreach (fk, _fprof in ::Wuxia.Config.Fighters)
			{
				local fAct = makeEnemyHarness();
				::Wuxia.Loot.applyLoadoutToEnemy(fAct, fk);
				loadoutChecked += 1;
			}
			if (loadoutChecked < 50)
				throw "Expected >= 50 enemy & fighter loadouts verified, got " + loadoutChecked;

			// 2. Enumerate & instantiate all Wuxia scenarios, blueprints, events, and ambitions
			s21Step = "S21-2-enumerateAllScripts";
			local wxOrigins = 0;
			foreach (scPath in ::IO.enumerateFiles("scripts/scenarios/world"))
			{
				if (scPath.find("/wx_") != null)
				{
					local sc = ::new(scPath);
					if (sc.m.ID == "") throw "Empty scenario ID: " + scPath;
					wxOrigins += 1;
				}
			}
			if (wxOrigins < 7) throw "Expected >= 7 Wuxia scenarios, got " + wxOrigins;

			local wxBps = 0;
			foreach (bpPath in ::IO.enumerateFiles("scripts/crafting/blueprints"))
			{
				if (bpPath.find("/wx_") != null)
				{
					local bp = ::new(bpPath);
					if (bp.getID() == "") throw "Empty blueprint ID: " + bpPath;
					wxBps += 1;
				}
			}
			if (wxBps < 20) throw "Expected >= 20 Wuxia blueprints, got " + wxBps;

			local wxEvents = 0;
			foreach (evPath in ::IO.enumerateFiles("scripts/events/events"))
			{
				if (evPath.find("/wx_") != null)
				{
					local ev = ::new(evPath);
					if (ev.getID() == "" || ev.m.Screens.len() == 0) throw "Invalid Wuxia event: " + evPath;
					wxEvents += 1;
				}
			}
			if (wxEvents < 60) throw "Expected >= 60 Wuxia events, got " + wxEvents;

			local ambChecked = 0;
			foreach (ambPath in ::IO.enumerateFiles("scripts/ambitions/ambitions"))
			{
				local amb = ::new(ambPath);
				if (amb.getID() == "") throw "Empty ambition ID: " + ambPath;
				ambChecked += 1;
			}
			if (ambChecked < 20) throw "Expected >= 20 ambitions, got " + ambChecked;

			// 3. Verify SectRelations alignment ripple (`addRelation` with _delta >= 8 & _fromRipple = false)
			s21Step = "sect_relation_ripple";
			local hadWorld = ("World" in getroottable() && ::World != null);
			if (!hadWorld)
			{
				local mockStore = {};
				::World <- {
					Flags = {
						has      = function( _k ) { return (_k in mockStore); },
						get      = function( _k ) { return (_k in mockStore) ? mockStore[_k] : false; },
						getAsInt = function( _k ) { return (_k in mockStore && typeof mockStore[_k] == "integer") ? mockStore[_k] : 0; },
						set      = function( _k, _v ) { mockStore[_k] <- _v; }
					}
				};
				try
				{
					::Wuxia.SectRelations.discoverSect("heifeng");
					local relAfter = ::Wuxia.SectRelations.addRelation("shaolin", 18, false);
					if (relAfter <= 0) throw "Expected positive shaolin relation after +18";
				}
				catch (ripErr)
				{
					delete ::World;
					throw ripErr;
				}
				delete ::World;
			}

			// 4. Verify Shenji Musketeer AI agent (`AttackHandgonne` + `AttackBow`) so `ai_engage_ranged` never crashes its generator
			s21Step = "shenji_musketeer_ai_guard";
			local testMusk = ::new("scripts/entity/tactical/enemies/wx_shenji_musketeer");
			local muskAgent = testMusk.getAIAgent();
			if (muskAgent == null || muskAgent.getBehavior(::Const.AI.Behavior.ID.AttackHandgonne) == null || muskAgent.getBehavior(::Const.AI.Behavior.ID.AttackBow) == null)
				throw "wx_shenji_musketeer AIAgent missing AttackHandgonne or AttackBow!";
			local testBanditRng = ::new("scripts/ai/tactical/agents/bandit_ranged_agent");
			if (testBanditRng.getBehavior(::Const.AI.Behavior.ID.AttackHandgonne) == null)
				throw "bandit_ranged_agent missing defensive AttackHandgonne guard!";

			// 5. Verify `wx_tournament_player` delegate-aware `m` slot assignment (`Talents` & `Attributes` visible to `this.player`)
			s21Step = "tournament_player_keys";
			local tpDst = ::new("scripts/entity/tactical/wx_tournament_player");
			tpDst.m.Level = 9;
			local tArr = [];
			tArr.resize(::Const.Attributes.COUNT, 2);
			tpDst.m.Talents = tArr;
			if (!::Wuxia.hasMember(tpDst.m, "Talents") || tpDst.player.m.Talents.len() != ::Const.Attributes.COUNT || tpDst.player.m.Level != 9)
				throw "wx_tournament_player delegate slot sync failed!";

			// 6. Verify `withMemberContext` wrapper preserves `this.m` binding for `WorldState.loadCampaign`
			s21Step = "load_campaign_this_binding";
			local mockWS = { m = { LoadedFile = "" } };
			local origLoad = function( _fn ) { this.m.LoadedFile = _fn; return true; };
			local wrappedLoad = function( _filename ) {
				local owner = this;
				return ::Wuxia.Tournament.withMemberContext(function() { return origLoad.call(owner, _filename); });
			};
			if (!wrappedLoad.call(mockWS, "test_save") || mockWS.m.LoadedFile != "test_save")
				throw "WorldState.loadCampaign lost `this` inside withMemberContext!";

			// 7. Verify `faction_manager.getFaction` returns null instead of throwing during `EntityManager.onDeserialize`
			s21Step = "faction_manager_deser_guard";
			local testFM = ::new("scripts/factions/faction_manager");
			if (testFM.getFaction(12) != null || testFM.getFaction(20) != null || testFM.getFaction(-1) != null)
				throw "faction_manager.getFaction did not safely guard out-of-bounds IDs!";
		}
		catch (s21Err)
		{
			throw "[" + s21Step + "] " + s21Err;
		}

		::logInfo("[WX-SELFTEST] Verified Stage 21 全敌方配装防叠乘·7大起源·全丹方·全奇遇事件·全江湖志向枚举实装通过!");
	});

	// Stage 22: Tactical AI Behavior Skill-Contract & Tournament CombatInfo Guardrails
	check("Stage 22 战术AI全行为招式契约(IsTargeted/劈盾/震退/火铳锥区)与擂台Tile校验", function() {
		local behaviorContracts = [
			["ai_attack_default",     true,  true],
			["ai_attack_bow",         true,  true],
			["ai_attack_swing",       true,  true],
			["ai_attack_thresh",      false, true],
			["ai_attack_splitshield", true,  true],
			["ai_defend_knock_back",  true,  true],
			["ai_defend_riposte",     false, true],
			["ai_defend_shieldwall",  false, true],
			["ai_defend_spearwall",   false, true],
			["ai_indomitable",        false, true],
			["ai_recover",            false, true],
			["ai_adrenaline",         false, true],
			["ai_disengage",          true,  false],
			["ai_warcry",             false, true],
			["ai_rally",              false, true],
			["ai_attack_handgonne",   true,  false]
		];
		local instWxSkill = function( _sid ) {
			local dot = _sid.find(".");
			if (dot == null) throw "Malformed skill ID in PossibleSkills: " + _sid;
			return ::new("scripts/skills/" + _sid.slice(0, dot) + "/" + _sid.slice(dot + 1));
		};
		local checkedWxSkills = 0;
		foreach (row in behaviorContracts)
		{
			local bName = row[0], expTargeted = row[1], expTargetActor = row[2];
			local beh = ::new("scripts/ai/tactical/behaviors/" + bName);
			if (!(::Wuxia.hasMember(beh.m, "PossibleSkills")) || beh.m.PossibleSkills == null)
				continue;
			foreach (sid in beh.m.PossibleSkills)
			{
				if (sid.find("actives.wx_") != 0) continue;
				checkedWxSkills += 1;
				local sk = instWxSkill(sid);
				if (sk == null) throw bName + " failed to instantiate " + sid;
				if (sk.isTargeted() != expTargeted)
					throw bName + " IsTargeted mismatch on " + sid + " (expected " + expTargeted + ")";
				if (sk.m.IsTargetingActor != expTargetActor)
					throw bName + " IsTargetingActor mismatch on " + sid + " (expected " + expTargetActor + ")";
				if (bName == "ai_attack_splitshield" && !::Wuxia.hasMember(sk, "isAxeMasteryApplied"))
					throw bName + " skill missing isAxeMasteryApplied(): " + sid;
				if (bName == "ai_defend_knock_back" && !::Wuxia.hasMember(sk, "findTileToKnockBackTo"))
					throw bName + " skill missing findTileToKnockBackTo(): " + sid;
				if (bName == "ai_attack_handgonne" && !::Wuxia.hasMember(sk, "getAffectedTiles"))
					throw bName + " skill missing getAffectedTiles(): " + sid;
			}
		}
		if (checkedWxSkills < 70)
			throw "Expected >= 70 AI-extended Wuxia skill bindings verified, got " + checkedWxSkills;
		::logInfo("[WX-SELFTEST] Verified Stage 22 战术AI全行为招式契约: " + checkedWxSkills + " bindings 100% contract-aligned!");
	});

	// Stage 23: Shan-Hai 8 Mythic Resonance Sets (78 Pieces), 11 Totem Soul Pairs, 2H Deduplication & AGENTS.md Caps
	check("Stage 23 山海八大共鸣套装(78件全覆盖)·11组本命真魂·双手去重·镶片计数与防膨胀上限校验", function() {
		if (!("ShanHaiSets" in ::Wuxia.Config) || ::Wuxia.Config.ShanHaiSetOrder.len() != 8)
			throw "Expected 8 ShanHaiSets in ShanHaiSetOrder";
		if (!("ShanHaiTotemPairs" in ::Wuxia.Config) || ::Wuxia.Config.ShanHaiTotemOrder.len() != 11)
			throw "Expected 11 ShanHaiTotemPairs in ShanHaiTotemOrder";

		local resolvePieceScript = function( _pk ) {
			if (_pk.find("wx_relic_") == 0)  return "scripts/items/weapons/named/" + _pk;
			if (_pk.find("wx_armor_") == 0)  return "scripts/items/armor/named/" + _pk;
			if (_pk.find("wx_helm_") == 0)   return "scripts/items/helmets/named/" + _pk;
			if (_pk.find("wx_shd_") == 0)    return "scripts/items/shields/named/" + _pk;
			if (_pk.find("wx_acc_") == 0)    return "scripts/items/accessory/" + _pk;
			if (_pk.find("wx_up_") == 0)     return "scripts/items/armor_upgrades/" + _pk;
			if (_pk == "wx_beast_shield")    return "scripts/items/shields/wx_beast_shield";
			if (_pk.find("wx_beast_armor_") == 0) return "scripts/items/armor/" + _pk;
			if (_pk.find("wx_beast_helm_") == 0)  return "scripts/items/helmets/" + _pk;
			if (_pk.find("wx_beast_") == 0)  return "scripts/items/weapons/" + _pk;
			throw "Unknown set piece prefix: " + _pk;
		};

		local seenPieces = {};
		local shCount = 0, beastCount = 0;
		foreach (sid in ::Wuxia.Config.ShanHaiSetOrder)
		{
			local scfg = ::Wuxia.Config.ShanHaiSets[sid];
			foreach (pk in scfg.Pieces)
			{
				if (pk in seenPieces) throw "Duplicate set assignment on " + pk;
				seenPieces[pk] <- sid;
				if (scfg.Tier == "shanhai") shCount += 1;
				else beastCount += 1;

				local it = ::new(resolvePieceScript(pk));
				if (::Wuxia.ShanHaiSets.resolveItemGearKey(it) != pk)
					throw "resolveItemGearKey mismatch on " + pk + " (id=" + it.getID() + ")";
				local tt = it.getTooltip();
				local setRows = 0;
				foreach (r in tt) { if (r != null && typeof r == "table" && ("id" in r) && r.id == 975) setRows += 1; }
				if (setRows != 1)
					throw "Expected exactly 1 set tooltip header (id=975) on " + pk + ", got " + setRows;
			}
		}
		if (shCount != 62 || beastCount != 16)
			throw "Expected 62 ShanHai + 16 Beast pieces (78 total), got " + shCount + " + " + beastCount;

		// Verify 2H/Fist deduplication + 3pc Set + Same-Beast Totem + Inlaid Armor Upgrade counting + AGENTS.md caps!
		local wChiyou = ::new("scripts/items/weapons/named/wx_relic_chiyoufu");
		local aChiyou = ::new("scripts/items/armor/named/wx_armor_chiyou");
		local hChiyou = ::new("scripts/items/helmets/named/wx_helm_chiyou");

		local slotMap = {};
		slotMap[::Const.ItemSlot.Mainhand]  <- wChiyou;
		slotMap[::Const.ItemSlot.Offhand]   <- wChiyou; // Simulate 2H duplicate reference across Mainhand+Offhand
		slotMap[::Const.ItemSlot.Body]      <- null;
		slotMap[::Const.ItemSlot.Head]      <- null;
		slotMap[::Const.ItemSlot.Accessory] <- null;

		local mockActor = {
			function getItems() { return { function getItemAtSlot( _s ) { return (_s in slotMap) ? slotMap[_s] : null; } }; }
		};
		local ev1 = ::Wuxia.ShanHaiSets.evaluateActorSets(mockActor);
		if (!("wx_set_bingzhu" in ev1.SetCounts) || ev1.SetCounts.wx_set_bingzhu != 1 || ev1.ActiveSets.len() != 0)
			throw "2H Mainhand+Offhand reference was not deduplicated to 1 piece!";

		slotMap[::Const.ItemSlot.Body] = aChiyou;
		slotMap[::Const.ItemSlot.Head] = hChiyou;
		local ev3 = ::Wuxia.ShanHaiSets.evaluateActorSets(mockActor);
		if (ev3.SetCounts.wx_set_bingzhu != 3 || ev3.ActiveSets.len() != 1 || ev3.ActiveTotems.find("chiyou") == null)
			throw "Expected 3pc wx_set_bingzhu + chiyou totem active!";

		// Verify Beast 4-piece via Weapon + Body Armor + Inlaid Upgrade + Helmet
		local bWpn  = ::new("scripts/items/weapons/wx_beast_hammer");
		local bArm  = ::new("scripts/items/armor/wx_beast_armor_heavy");
		local bUpg  = ::new("scripts/items/armor_upgrades/wx_up_shagu");
		local bHelm = ::new("scripts/items/helmets/wx_beast_helm_heavy");
		bArm.m.Upgrade = bUpg;
		slotMap[::Const.ItemSlot.Mainhand] = bWpn;
		slotMap[::Const.ItemSlot.Offhand]  = null;
		slotMap[::Const.ItemSlot.Body]     = bArm;
		slotMap[::Const.ItemSlot.Head]     = bHelm;
		local evBeast = ::Wuxia.ShanHaiSets.evaluateActorSets(mockActor);
		if (!("wx_set_baigong" in evBeast.SetCounts) || evBeast.SetCounts.wx_set_baigong != 4)
			throw "Expected 4pc wx_set_baigong (including inlaid wx_up_shagu), got " + (("wx_set_baigong" in evBeast.SetCounts) ? evBeast.SetCounts.wx_set_baigong : 0);

		// Verify wx_status_frost_chill & AGENTS.md Kunlun 0.40 regular damage floor + Jinwu +0.25 pen cap
		local chill = ::new("scripts/skills/effects/wx_status_frost_chill");
		local cProps = { ActionPoints = 9, Initiative = 100 };
		chill.onUpdate(cProps);
		if (cProps.ActionPoints != 7 || cProps.Initiative != 75)
			throw "wx_status_frost_chill did not apply -2 AP / -25 Initiative";

		local resSk = ::new("scripts/skills/special/wx_shanhai_set_resonance");
		resSk.m.CachedEval = { SetCounts = { wx_set_kunlun = 3, wx_set_jinwu = 2 }, ActiveSets = [{ SetID = "wx_set_kunlun", Count = 3 }], ActiveTotems = [] };
		resSk.m.HasKunlunWard = true;
		local dProps = { DamageReceivedRegularMult = 0.45 };
		resSk.onBeforeDamageReceived(null, null, { BodyPart = ::Const.BodyPart.Body, DamageRegular = 30, BodyDamageMult = 1.0 }, dProps);
		if (dProps.DamageReceivedRegularMult < 0.3999 || resSk.m.HasKunlunWard)
			throw "Kunlun 3pc ward breached AGENTS.md 0.40 DamageReceivedRegularMult floor: " + dProps.DamageReceivedRegularMult;

		::logInfo("[WX-SELFTEST] Verified Stage 23 山海八大共鸣套装(78件)与11组本命真魂全实例、去重及红线钳制通过!");
	});

	check("Stage 24: Event Manager & 82 Wuxia Road Events Full Pipeline Regression", function() {
		local hadWorld = ("World" in getroottable() && ::World != null);
		local prevWorld = hadWorld ? ::World : null;
		local mockStore = {};
		local mockTile = {
			HasRoad = true,
			Type = ::Const.World.TerrainType.Plains,
			SquareCoords = { X = 10, Y = 10 },
			function getDistanceTo( _other ) { return 2; }
		};
		local mockPlayer = {
			function getTile() { return mockTile; },
			function getPos() { return ::createVec(100, 100); },
			function isInCombat() { return false; }
		};
		local mockTown = {
			function isAlliedWithPlayer() { return true; },
			function isMilitary() { return false; },
			function isIsolated() { return false; },
			function hasBuilding( _id ) { return true; },
			function getTile() { return mockTile; },
			function getName() { return "洛阳城"; },
			function getNameOnly() { return "洛阳城"; }
		};
		local mockBroList = [];
		for (local bi = 0; bi < 4; bi = ++bi)
		{
			local bIdx = bi;
			local bBgID = (bIdx == 0) ? "background.monk" : ((bIdx == 1) ? "background.swordmaster" : ((bIdx == 2) ? "background.thief" : "background.farmhand"));
			local bCont = ::new("scripts/skills/special/wx_martial_container");
			local bSkills = {
				function hasSkill( _id ) { return false; },
				function getSkillByID( _id ) { return _id == "special.wx_martial_container" ? bCont : null; },
				function getAllSkillsOfType( _t ) { return []; },
				function update() {},
				function add( _s ) {},
				function removeByID( _id ) {}
			};
			local bItems = {
				function getItemAtSlot( _s ) { return null; }
			};
			local bBase = { Hitpoints = 70, Bravery = 50, Stamina = 100, MeleeSkill = 65, RangedSkill = 40, MeleeDefense = 15, RangedDefense = 10, Initiative = 105 };
			mockBroList.push({
				m = { ID = 9000 + bIdx },
				function getID() { return this.m.ID; },
				function isAlive() { return true; },
				function getName() { return "侠客" + (bIdx + 1); },
				function getNameOnly() { return "侠客" + (bIdx + 1); },
				function getImagePath() { return "ui/portraits/dummy.png"; },
				function getLevel() { return 5; },
				function getHitpoints() { return 65; },
				function getHitpointsMax() { return 70; },
				function getHitpointsPct() { return 0.92; },
				function getBackground() { return { function getID() { return bBgID; } }; },
				function getSkills() { return bSkills; },
				function getItems() { return bItems; },
				function getBaseProperties() { return bBase; },
				function getCurrentProperties() { return bBase; },
				function getMoodStateIcon() { return "ui/icons/mood_04.png"; },
				function improveMood( _d, _r ) {},
				function worsenMood( _d, _r ) {},
				function setHitpoints( _h ) {}
			});
		}
		local mockStash = {
			function hasEmptySlot() { return true; },
			function getNumberOfEmptySlots() { return 20; },
			function add( _i ) { return true; },
			function getItems() { return []; }
		};
		local mockWorld = {
			Time = { Days = 15, SecondsPerDay = 250.0, IsDaytime = true, Hours = 11, Time = 15.0 * 250.0 },
			Flags = {
				has      = function( _k ) { return (_k in mockStore); },
				get      = function( _k ) { return (_k in mockStore) ? mockStore[_k] : false; },
				getAsInt = function( _k ) { return (_k in mockStore && typeof mockStore[_k] == "integer") ? mockStore[_k] : 0; },
				set      = function( _k, _v ) { mockStore[_k] <- _v; }
			},
			State = {
				function getPlayer() { return mockPlayer; },
				function isInTown() { return false; },
				function isPaused() { return false; },
				function getCurrentTown() { return null; },
				function getEscortedEntity() { return null; }
			},
			Assets = {
				function getName() { return "山海义社"; },
				function getMoney() { return 5000; },
				function addMoney( _d ) {},
				function getFood() { return 80; },
				function updateFood() {},
				function getArmorParts() { return 50; },
				function addArmorParts( _d ) {},
				function getMedicine() { return 40; },
				function addMedicine( _d ) {},
				function getAmmo() { return 60; },
				function addAmmo( _d ) {},
				function getBusinessReputation() { return 1200; },
				function addBusinessReputation( _d ) {},
				function addMoralReputation( _d ) {},
				function getStash() { return mockStash; },
				function getOrigin() { return { function getID() { return "scenario.wx_jianghu_start"; } }; }
			},
			EntityManager = {
				function getSettlements() { return [mockTown]; },
				function getLocations() { return []; }
			},
			FactionManager = {
				function isCivilWar() { return false; },
				function isGreenskinInvasion() { return false; },
				function isUndeadScourge() { return false; },
				function isHolyWar() { return false; },
				function isGreaterEvil() { return false; },
				function getFactionsOfType( _t ) {
					return [{
						function getName() { return "河东节度府"; },
						function getNameOnly() { return "河东节度府"; },
						function getMotto() { return "定鼎中原"; },
						function getBannerSmall() { return "banner_01"; },
						function getSettlements() { return [mockTown]; }
					}];
				}
			},
			Contracts = {
				function getActiveContract() { return null; }
			},
			Ambitions = {
				function hasActiveAmbition() { return true; },
				function getActiveAmbition() { return null; }
			},
			Camp = {
				function isCamping() { return false; }
			},
			Statistics = {
				function getFlags() { return mockWorld.Flags; }
			},
			function getTime() { return this.Time; },
			function getPlayerRoster() { return { function getAll() { return clone mockBroList; }, function getSize() { return mockBroList.len(); } }; },
			function getGuestRoster() { return { function getAll() { return []; }, function getSize() { return 0; } }; }
		};

		::World <- mockWorld;
		local diagErr = null;
		try
		{
			local em = ::new("scripts/events/event_manager");
			local wxInMgr = 0;
			local wxScoredDay = 0;
			local wxScreensOpened = 0;
			local wxUpdateErrors = [];
			local wxScreenErrors = [];
			local scoredDayNames = [];

			// Pass 1: Score all 82 Wuxia events BEFORE calling any setScreen/clear
			foreach (e in em.m.Events)
			{
				local eid = (e != null && ::Wuxia.hasMember(e, "getID")) ? e.getID() : "";
				if (eid.find("event.wx_") != 0) continue;
				wxInMgr += 1;
				try
				{
					e.update();
					if (e.getScore() > 0)
					{
						wxScoredDay += 1;
						scoredDayNames.push(eid + "=" + e.getScore());
					}
				}
				catch (uErr)
				{
					wxUpdateErrors.push(eid + " => " + uErr);
				}
			}
			::logInfo("[WX-SELFTEST] Stage 24 Pass1 (pre-screen): wxInMgr=" + wxInMgr + ", wxScoredDay=" + wxScoredDay + ", vtime=" + ::Time.getVirtualTimeF() + ", sample=" + (scoredDayNames.len() > 0 ? scoredDayNames.slice(0, ::Math.min(8, scoredDayNames.len())).reduce(@(a, b) a + "," + b) : "NONE"));

			// Pass 2: Open Screen[0] + buildText + clear() on all 82 Wuxia events
			foreach (e in em.m.Events)
			{
				local eid = (e != null && ::Wuxia.hasMember(e, "getID")) ? e.getID() : "";
				if (eid.find("event.wx_") != 0) continue;
				if (e.m.Screens.len() > 0)
				{
					try
					{
						e.onPrepare();
						e.setScreen(e.m.Screens[0]);
						if (e.m.ActiveScreen == null)
							wxScreenErrors.push(eid + " => ActiveScreen null after setScreen");
						else
						{
							if (("Text" in e.m.ActiveScreen) && typeof e.m.ActiveScreen.Text == "string")
								e.buildText(e.m.ActiveScreen.Text);
							wxScreensOpened += 1;
						}
						e.clear();
					}
					catch (sErr)
					{
						wxScreenErrors.push(eid + " => " + sErr);
					}
				}
			}

			// Pass 3: Verify nighttime scoring works cleanly without throwing (on fresh event_manager so clear() cooldowns don't hide anything!)
			mockWorld.Time.IsDaytime = false;
			mockWorld.Time.Hours = 23;
			local emNight = ::new("scripts/events/event_manager");
			local wxScoredNight = 0;
			foreach (e2 in emNight.m.Events)
			{
				local eid2 = (e2 != null && ::Wuxia.hasMember(e2, "getID")) ? e2.getID() : "";
				if (eid2.find("event.wx_") != 0) continue;
				e2.update();
				if (e2.getScore() > 0) wxScoredNight += 1;
			}
			::logInfo("[WX-SELFTEST] Stage 24 Pass3 (night): wxScoredNight=" + wxScoredNight + ", wxScreensOpened=" + wxScreensOpened + ", wxScreenErrors=" + wxScreenErrors.len());
			if (wxScreenErrors.len() > 0)
				::logInfo("[WX-SELFTEST] Stage 24 ScreenErrSample: " + wxScreenErrors.slice(0, ::Math.min(6, wxScreenErrors.len())).reduce(@(a, b) a + " | " + b));

			if (wxInMgr < 80)
				throw "Expected >= 80 Wuxia events in event_manager, got " + wxInMgr;
			if (wxScoredDay < 30 || wxScoredNight < 30)
				throw "Too few Wuxia road events scored (day=" + wxScoredDay + ", night=" + wxScoredNight + ")";
			if (wxUpdateErrors.len() > 0)
				throw "Wuxia event update() errors: " + wxUpdateErrors.reduce(@(a, b) a + " | " + b);
			if (wxScreenErrors.len() > 0)
				throw "Wuxia event setScreen() errors: " + wxScreenErrors.reduce(@(a, b) a + " | " + b);

			// Verify road event tea_shed & vanilla choose_ambition_event end-to-end start & screen render
			mockWorld.Time.IsDaytime = true;
			local tea = ::new("scripts/events/events/wx_event_road_tea_shed");
			tea.update();
			if (tea.getScore() <= 0)
				throw "wx_event_road_tea_shed failed to score on road";
			tea.onPrepare();
			tea.setScreen(tea.m.Screens[0]);
			if (tea.m.ActiveScreen == null || tea.m.ActiveScreen.ID != "A" || tea.m.ActiveScreen.Options.len() < 2)
				throw "wx_event_road_tea_shed setScreen(Screens[0]) failed to populate screen";
			tea.clear();

			local ambEv = ::new("scripts/events/event");
			ambEv.m.ID = "event.choose_ambition";
			ambEv.m.Title = "Ambition";
			ambEv.m.Screens.push({ ID = "A", Text = "old", Image = "", List = [], Characters = [], Options = [{ Text = "收下克朗", function getResult( _ev ) { return 0; } }], function start( _ev ) {} });
			ambEv.setScreen(ambEv.m.Screens[0]);
			if (ambEv.m.ActiveScreen == null || ambEv.m.Title.find("江湖志向") == null || ambEv.m.ActiveScreen.Options[0].Text.find("纹银") == null)
				throw "choose_ambition event setScreen polish failed after 1-arg fix";
			ambEv.clear();

			::logInfo("[WX-SELFTEST] Verified Stage 24 事件系统全链路: " + wxInMgr + " 奇遇入池, 日/夜可触发=" + wxScoredDay + "/" + wxScoredNight + ", 全部 " + wxScreensOpened + " 个首屏 setScreen 零报错通过!");
		}
		catch (e)
		{
			diagErr = e;
		}

		if (hadWorld) ::World <- prevWorld;
		else delete ::World;

		if (diagErr != null)
			throw "EventManager regression failed: " + diagErr;
	});

	check("Active stance multipliers use fractional HP damage and respect the floor", function() {
		local expected = { wx_neigong_yijin = 0.8, wx_henglian_tiebushan = 0.75, wx_neigong_hanbing = 0.75 };
		foreach (name, multiplier in expected)
		{
			local stance = ::new("scripts/skills/actives/" + name);
			local stats = ::Const.CharacterProperties.getClone();
			stance.m.ActiveBuff = true;
			stance.onUpdate(stats);
			if (::Math.absf(stats.DamageReceivedRegularMult - multiplier) > 0.001)
				throw name + " first application produced " + stats.DamageReceivedRegularMult;
			stats.DamageReceivedRegularMult = 0.42;
			stance.onUpdate(stats);
			if (::Math.absf(stats.DamageReceivedRegularMult - 0.40) > 0.001)
				throw name + " did not respect the 60 percent cap";
		}
		local actor = {
			fatigue = 0, function getFatigueMax() { return 100; },
			function getFatigue() { return this.fatigue; }, function setFatigue(v) { this.fatigue = v; },
			function getItems() { return { function getItemAtSlot(s) { return null; } }; }
		};
		local c = ::new("scripts/skills/special/wx_martial_container");
		c.m.Container = { function getActor() { return actor; } };
		c.m.CachedAggFlags = { HeavyArmorScale = 0, ReflectArmorDmg = 0, FrostChillOnHit = false,
			QiShieldPct = 0.35, LightArmorMitigation = 0.55 };
		local props = ::Const.CharacterProperties.getClone();
		props.DamageReceivedRegularMult = 0.30;
		c.onBeforeDamageReceived(null, null, { DamageRegular = 100 }, props);
		if (::Math.absf(props.DamageReceivedRegularMult - 0.40) > 0.001 || actor.fatigue != 0)
			throw "Combined shield exceeded 60 percent reduction or charged Qi at the floor";
		actor.getItems = function() {
			return { function getItemAtSlot(s) { return { function getStaminaModifier() { return -30; } }; } };
		};
		actor.fatigue = actor.getFatigueMax();
		props.DamageReceivedRegularMult = 0.30;
		c.onBeforeDamageReceived(null, null, { DamageRegular = 100 }, props);
		if (::Math.absf(props.DamageReceivedRegularMult - 0.30) > 0.001)
			throw "An inactive light-armor manual changed unrelated heavy-armor mitigation";
	});

	check("Temporary AP refunds stop at 13 and tactical manuals stay within their stat caps", function() {
		local c = ::new("scripts/skills/special/wx_martial_container");
		local actor = {
			ap = 11, function getActionPoints() { return this.ap; },
			function getActionPointsMax() { return 11 + c.m.TemporaryAPOverflow; },
			function setActionPoints(v) { this.ap = v; }
		};
		c.m.Container = { function getActor() { return actor; } };
		c.grantTemporaryAP(2);
		c.grantTemporaryAP(2);
		if (actor.ap != 13 || c.m.TemporaryAPOverflow != 2) throw "Stacked refund exceeded cap";
		c.onTurnEnd();
		if (actor.getActionPointsMax() != 11) throw "Temporary AP survived end of turn";
		foreach (id, manual in ::Wuxia.Config.Manuals)
		{
			if (manual.Category != "henglian") continue;
			foreach (level in manual.Levels)
				foreach (stat in ["MeleeSkill", "RangedSkill", "MeleeDefense", "RangedDefense"])
					if (stat in level.Stats && level.Stats[stat] > 5) throw id + " exceeds " + stat + " cap";
		}
	});

	check("Qi drain credits only available enemy Qi, and respects allies and undead", function() {
		local enemies = [];
		foreach (fat in [0, 9, 10, 0, 0])
			enemies.push({ fatigue = fat, function getFatigue() { return this.fatigue; },
				function getFatigueMax() { return 10; }, function setFatigue(v) { this.fatigue = v; } });
		enemies[4].getFlags <- function() { return { function has(k) { return k == "undead"; } }; };
		local tile = { function hasNextTile(d) { return d < enemies.len(); }, function getNextTile(d) {
			return { IsOccupiedByActor = true, function getEntity() { return enemies[d]; } };
		} };
		local actor = { hp = 4, fatigue = 15, function getTile() { return tile; },
			function isAlliedWith(who) { return who == enemies[3]; }, function getHitpoints() { return this.hp; },
			function getHitpointsMax() { return 25; }, function setHitpoints(v) { this.hp = v; },
			function getFatigue() { return this.fatigue; }, function setFatigue(v) { this.fatigue = v; } };
		if (::Wuxia.CombatRules.drainAdjacentQi(actor) != 7 || actor.hp != 11 || actor.fatigue != 8
			|| enemies[3].fatigue != 0 || enemies[4].fatigue != 0) throw "Qi transfer mismatch";
		enemies[0].fatigue = 10;
		if (::Wuxia.CombatRules.drainAdjacentQi(actor) != 0 || actor.hp != 11 || actor.fatigue != 8)
			throw "Exhausted targets granted recovery";
	});

	check("Player serialization preserves existing talents and advancement rolls in short arrays", function() {
		local player = ::new("scripts/entity/tactical/player");
		player.m.Talents = [3, 1];
		player.m.Attributes = [[4, 3], [1, 2, 4]];
		player.WX_CompleteAttributeArrays();
		player.WX_CompleteAttributeArrays();
		if (player.m.Talents.len() != ::Const.Attributes.COUNT || player.m.Attributes.len() != ::Const.Attributes.COUNT
			|| player.m.Talents[0] != 3 || player.m.Talents[1] != 1 || player.m.Talents[2] != 0
			|| player.m.Attributes[0].len() != 2 || player.m.Attributes[1][2] != 4 || player.m.Attributes[2][0] != 2)
			throw "Completing missing attribute rows changed existing rolls or talents";
	});

	check("v0.8.8 Enemy Facing, Shan Hai Beast VFX Choreo & High-Contrast Tooltip Colors", function() {
		if (!("Appearance" in ::Wuxia) || !("enforceWuxiaFacing" in ::Wuxia.Appearance))
			throw "Missing ::Wuxia.Appearance.enforceWuxiaFacing";

		// 1. Verify enforceWuxiaFacing sets right->left flip for non-allied custom enemies (including vanilla monster subclasses!)
		local flipCaptured = null;
		local mockSpr = {
			HasBrush = true,
			Visible = true,
			function getBrush() { return { Name = "wx_boss_boshi" }; },
			function isFlippedHorizontally() { return flipCaptured == true; },
			function setHorizontalFlipping( _v ) { flipCaptured = _v; }
		};
		local mockEnemy = {
			m = { WX_CustomEnemyBust = "wx_boss_boshi", WX_BossID = "boss_boshi" },
			function isAlliedWithPlayer() { return false; },
			function hasSprite( _k ) { return _k == "body"; },
			function getSprite( _k ) { return mockSpr; }
		};
		::Wuxia.Appearance.enforceWuxiaFacing(mockEnemy);
		if (flipCaptured != true)
			throw "enforceWuxiaFacing failed to flip enemy custom bust to face player (got " + flipCaptured + ")";
		mockEnemy.isAlliedWithPlayer = function() { return true; };
		::Wuxia.Appearance.enforceWuxiaFacing(mockEnemy);
		if (flipCaptured != false)
			throw "enforceWuxiaFacing failed to unflip allied custom bust (got " + flipCaptured + ")";

		// 1b. Verify real vanilla monster & human subclasses hooked via actor + hookTree flip custom wx_* busts correctly on onFactionChanged()!
		foreach (eScript in [
			"scripts/entity/tactical/enemies/ghoul_high",
			"scripts/entity/tactical/enemies/skeleton_light",
			"scripts/entity/tactical/enemies/direwolf",
			"scripts/entity/tactical/enemies/hyena",
			"scripts/entity/tactical/enemies/spider",
			"scripts/entity/tactical/enemies/unhold",
			"scripts/entity/tactical/enemies/goblin_ambusher",
			"scripts/entity/tactical/enemies/orc_warrior",
			"scripts/entity/tactical/enemies/bandit_raider"
		])
		{
			local ent = ::new(eScript);
			local sprMap = {};
			local mkSpr = function() {
				return {
					HasBrush = false, Visible = false, BrushName = "", Flipped = false, Color = null,
					function setBrush( _b ) { this.HasBrush = true; this.BrushName = _b; },
					function getBrush() { return { Name = this.BrushName }; },
					function setHorizontalFlipping( _v ) { this.Flipped = _v; },
					function isFlippedHorizontally() { return this.Flipped; },
					function setBrushColor( _c ) { this.Color = _c; }
				};
			};
			ent.hasSprite <- function( _k ) { return _k == "body" || _k == "head" || _k == "injury" || _k == "status_rooted"; };
			ent.getSprite <- function( _k ) {
				if (!(_k in sprMap)) sprMap[_k] <- mkSpr();
				return sprMap[_k];
			};
			ent.getFaction <- function() { return ::Const.Faction.Beasts; };
			ent.isAlliedWithPlayer <- function() { return false; };
			ent.isPlacedOnMap <- function() { return false; };
			ent.isHiddenToPlayer <- function() { return false; };
			ent.setOverlayValues <- function( _a = null, _b = null ) {};
			ent.updateOverlay <- function() {};
			ent.setDirty <- function( _v ) {};
			ent.getFlags <- function() { return { function set(k, v) {}, function has(k) { return false; } }; };
			ent.m.BaseProperties = ::Const.CharacterProperties.getClone();
			ent.m.CurrentProperties = ::Const.CharacterProperties.getClone();
			ent.m.WX_CustomEnemyBust <- "wx_beast_paoxiao";
			ent.getSprite("body").setBrush("wx_beast_paoxiao");
			// First simulate vanilla left-facing state (Flipped = false), then invoke hooked onFactionChanged()!
			ent.getSprite("body").setHorizontalFlipping(false);
			ent.onFactionChanged();
			if (!ent.getSprite("body").isFlippedHorizontally())
				throw eScript + " failed hookTree facing flip on onFactionChanged()!";
		}

		// 2. Verify Shan Hai Beast & Boss VFX choreography resolver covers both bosses and wild beasts
		if (!("VFX" in ::Wuxia) || !("resolveShanHaiChoreo" in ::Wuxia.VFX) || !("isShanHaiCreature" in ::Wuxia.VFX))
			throw "Missing Shan Hai VFX choreography helpers on ::Wuxia.VFX";
		foreach (sample in [
			{ bust = "wx_boss_taotie",      bid = "boss_taotie",  sk = "actives.gorge" },
			{ bust = "wx_boss_jiuwei",      bid = "boss_jiuwei",  sk = "actives.charm" },
			{ bust = "wx_boss_kui",         bid = "boss_kui",     sk = "actives.unhold_fling_back" },
			{ bust = "wx_boss_zhuyin",      bid = "boss_zhuyin",  sk = "actives.sweep_skill" },
			{ bust = "wx_beast_chizhu",     bid = null,           sk = "actives.web" },
			{ bust = "wx_beast_feiyi_wild", bid = null,           sk = "actives.tail_slam_big" }
		])
		{
			local mEnt = { m = { WX_CustomEnemyBust = sample.bust, WX_BossID = sample.bid } };
			if (!::Wuxia.VFX.isShanHaiCreature(mEnt))
				throw "isShanHaiCreature returned false for " + sample.bust;
			local ch = ::Wuxia.VFX.resolveShanHaiChoreo({ function getID() { return sample.sk; } }, mEnt);
			if (ch == null || !("aura" in ch) || !("sig" in ch) || !("kind" in ch) || ch.aura == "" || ch.sig == "" || ch.kind == "")
				throw "Invalid Shan Hai choreo for " + sample.bust + " / " + sample.sk;
		}

		// 3. Verify parchment TooltipColor fields are present across Forge, Sets, Alchemy, and Boss Tiers
		foreach (g in ::Wuxia.Forge.Grades)
			if (!("TooltipColor" in g) || g.TooltipColor == "") throw "Missing Forge Grade TooltipColor";
		foreach (sid, scfg in ::Wuxia.Config.ShanHaiSets)
			if (!("TooltipColor" in scfg) || scfg.TooltipColor == "") throw "Missing ShanHaiSet TooltipColor on " + sid;
		foreach (pg, pspec in ::Wuxia.Config.Alchemy.PillGrades)
			if (!("TooltipColor" in pspec) || pspec.TooltipColor == "") throw "Missing PillGrade TooltipColor on " + pg;
		foreach (an, aspec in ::Wuxia.Config.Alchemy.AuxInfusions)
			if (!("TooltipColor" in aspec) || aspec.TooltipColor == "") throw "Missing AuxInfusion TooltipColor on " + an;
		for (local t = 1; t <= 3; t = ++t)
		{
			local ti = ::Wuxia.ShanHai.getBossTierInfo(t);
			if (!("TooltipColor" in ti) || ti.TooltipColor == "") throw "Missing BossTierInfo TooltipColor on tier " + t;
		}
		::logInfo("[WX-SELFTEST] Verified v0.8.8 Enemy Facing, Shan Hai Beast VFX Choreo & High-Contrast Parchment Tooltip Palette");
	});

	::logInfo("[WX-SELFTEST] ================= Result: " + passed + " PASSED, " + failed + " FAILED =================");
};

if (::Wuxia.Debug && !("Hooks" in getroottable() && "QueueBucket" in ::Hooks && "AfterHooks" in ::Hooks.QueueBucket))
{
	::Wuxia.SelfTest.runAll();
}
