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
		"scripts/skills/actives/wx_shield_bash_qi"
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
			if ("onUpdate" in ef) ef.onUpdate(props);
			if ("getTooltip" in ef) ef.getTooltip();
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
		"scripts/scenarios/world/wx_jianghu_start"
	];
	foreach (scp in scenarioScripts)
	{
		local path = scp;
		check("Instantiate scenario " + path, function() {
			local sc = ::new(path);
			if (sc.m.ID == "") throw "Empty scenario ID";
		});
	}

	check("Alchemy blueprints, beast trophy remapping and grand tournament event", function() {
		foreach (bp in ["wx_xisui_blueprint", "wx_ningshen_blueprint", "wx_humai_blueprint"])
		{
			local b = ::new("scripts/crafting/blueprints/" + bp);
			if (b.getID() == "") throw "Empty blueprint ID: " + bp;
		}
		local heart = ::new("scripts/items/misc/unhold_heart_item");
		local brain = ::new("scripts/items/misc/ghoul_brain_item");
		if (heart.getID() != "misc.unhold_heart" || heart.getName() != "白猿心头血核") throw "Unhold heart remap failed";
		if (brain.getID() != "misc.ghoul_brain" || brain.getName() != "食腐山魈脑髓") throw "Ghoul brain remap failed";

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
				foreach (role in spec.Troops)
					if (!(role in ::Wuxia.Config.Fighters) && !(role in ::Const.World.Spawn.Troops)) throw role;
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
	::logInfo("[WX-SELFTEST] ================= Result: " + passed + " PASSED, " + failed + " FAILED =================");
};

if (::Wuxia.Debug && !("Hooks" in getroottable() && "QueueBucket" in ::Hooks && "AfterHooks" in ::Hooks.QueueBucket))
{
	::Wuxia.SelfTest.runAll();
}
