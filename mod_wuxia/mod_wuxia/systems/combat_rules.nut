// Core Combat Rules: AP cap (11), 4-element Neigong Qi recovery, True Qi Shield, Light/Heavy mitigation

::Wuxia.CombatRules.TacticalAuraEpoch <- 1;

::Wuxia.CombatRules.bumpTacticalAuraEpoch <- function()
{
	::Wuxia.CombatRules.TacticalAuraEpoch += 1;
};

::Wuxia.CombatRules.matchesWeapon <- function( _weapon, _types )
{
	if (_types.len() == 0) return true;
	if (_weapon == null) return false;

	local wid = _weapon.getID().tolower();
	local cats = (::Wuxia.hasMember(_weapon.m, "Categories") && _weapon.m.Categories != null) ? _weapon.m.Categories.tolower() : "";

	if (wid.find("weapon.wx_relic_") == 0 && ("RelicWeapons" in ::Wuxia.Config))
	{
		local rKey = wid.slice(7);
		if (rKey in ::Wuxia.Config.RelicWeapons)
		{
			local rFam = ::Wuxia.Config.RelicWeapons[rKey].Family;
			foreach (wtName in _types)
			{
				if (wtName == rFam) return true;
				if ((rFam == "Saber" || rFam == "Cleaver") && (wtName == "Saber" || wtName == "Cleaver")) return true;
				if ((rFam == "Spear" || rFam == "Polearm") && (wtName == "Spear" || wtName == "Polearm")) return true;
			}
			return false;
		}
	}

	foreach (wtName in _types)
	{
		// Path 1: MSU WeaponType if MSU is installed
		if ("WeaponType" in ::Const.Items && wtName in ::Const.Items.WeaponType)
		{
			if (::Wuxia.hasMember(_weapon, "isWeaponType") && _weapon.isWeaponType(::Const.Items.WeaponType[wtName]))
				return true;
		}

		// Path 2: Vanilla zero-MSU weapon matching by English ID & localized/English Categories
		if (wtName == "Sword")
		{
			if (wid.find("sword") != null || wid.find("rapier") != null || wid.find("shamshir") != null || wid.find("falchion") != null || cats.find("sword") != null || cats.find("剑") != null)
				return true;
		}
		else if (wtName == "Cleaver" || wtName == "Saber")
		{
			if (wid.find("cleaver") != null || wid.find("scimitar") != null || wid.find("khopesh") != null || wid.find("chopper") != null || wid.find("saber") != null || wid.find("scramasax") != null || cats.find("cleaver") != null || cats.find("刀") != null)
				return true;
		}
		else if (wtName == "Spear" || wtName == "Polearm")
		{
			if (wid.find("spear") != null || wid.find("pike") != null || wid.find("bill") != null || wid.find("halberd") != null || wid.find("spetum") != null || wid.find("pole") != null || wid.find("glaive") != null || wid.find("trident") != null || wid.find("banner") != null || wid.find("pitchfork") != null || wid.find("warfork") != null || wid.find("hooked_blade") != null || wid.find("warscythe") != null || wid.find("swordlance") != null || wid.find("firelance") != null || cats.find("spear") != null || cats.find("polearm") != null || cats.find("矛") != null || cats.find("枪") != null || cats.find("长柄") != null || cats.find("长杆") != null || cats.find("长兵") != null || cats.find("战旗") != null)
				return true;
		}
		else if (wtName == "Throwing")
		{
			if (wid.find("throwing") != null || wid.find("javelin") != null || wid.find("bolas") != null || cats.find("throwing") != null || cats.find("投掷") != null || cats.find("暗器") != null)
				return true;
		}
		else if (wtName == "Bow" && wid.find("bow") != null && wid.find("crossbow") == null) return true;
		else if (wtName == "Crossbow" && wid.find("crossbow") != null) return true;
		else if (wtName == "Staff" && (wid == "weapon.wooden_stick" || wid == "weapon.bludgeon" || wid == "weapon.goedendag" || wid.find("staff") != null || cats.find("staff") != null || cats.find("棍") != null || cats.find("杖") != null)) return true;
		else if (wtName == "Fist" && (wid.find("wx_fist") != null || wid.find("wx_beast_fist") != null || wid.find("wx_named_fist") != null || cats.find("fist") != null || cats.find("拳") != null || cats.find("掌") != null)) return true;
		else if (wtName == "Hammer" && wid != "weapon.wooden_stick" && wid != "weapon.bludgeon" && wid != "weapon.goedendag" && wid.find("staff") == null && (wid.find("hammer") != null || wid == "weapon.military_pick" || wid == "weapon.pickaxe" || wid == "weapon.heavy_mining_pick" || cats.find("hammer") != null || cats.find("锤") != null)) return true;
		else if (wtName == "Axe" && wid != "weapon.pickaxe" && (wid.find("axe") != null || wid.find("hatchet") != null || wid.find("bardiche") != null || cats.find("axe") != null || cats.find("斧") != null)) return true;
		else if (wtName == "Flail" && (wid.find("flail") != null || wid.find("whip") != null || wid.find("chain") != null || cats.find("flail") != null || cats.find("连枷") != null || cats.find("鞭") != null || cats.find("链") != null)) return true;
		else if (wtName == "Dagger" && (wid.find("dagger") != null || wid == "weapon.knife" || wid.find("qatal") != null || wid == "weapon.goblin_notched_blade" || cats.find("dagger") != null || cats.find("匕") != null)) return true;
		else if (wtName == "Firearm" && (wid.find("handgonne") != null || wid.find("firelance") != null || wid.find("firearm") != null || cats.find("firearm") != null || cats.find("火器") != null || cats.find("火铳") != null)) return true;
	}
	return false;
};

::Wuxia.CombatRules.hasSingleHandEmptyOffhand <- function( _actor )
{
	if (_actor == null || !(::Wuxia.hasMember(_actor, "getItems"))) return false;
	local items = _actor.getItems();
	if (items == null) return false;
	local main = items.getItemAtSlot(::Const.ItemSlot.Mainhand);
	if (main == null) return false;
	if (items.getItemAtSlot(::Const.ItemSlot.Offhand) != null || items.hasBlockedSlot(::Const.ItemSlot.Offhand))
		return false;
	if (::Wuxia.hasMember(main, "getBlockedSlotType") && main.getBlockedSlotType() != null)
		return false;
	return main.isItemType(::Const.Items.ItemType.MeleeWeapon) || ::Wuxia.CombatRules.matchesWeapon(main, ["Throwing"]);
};

::Wuxia.CombatRules.getAggregateFlags <- function( _container )
{
	local agg = {
		Stats                = {},
		PermanentAPBonus     = 0,
		OnHitQiRegen         = 0,
		OnHitQiCap           = 2,
		OnDodgeQiRegen       = 0,
		OnDodgeQiCap         = 2,
		OnKillQiRegen        = 0,
		OnKillAPRefund       = 0,
		QiShieldPct          = 0.0,
		LightArmorMitigation = 0.0,
		HeavyArmorScale      = 0.0,
		InitToDefRatio       = 0.0,
		TerrainCostHalved    = false,
		ElevationDiscount    = false,
		QuickHands           = false,
		InjuryThresholdMult  = 1.0,
		WeaponQiDiscount     = 0.0,
		ArmorDmgBonus        = 0.0,
		DirectDmgBonus       = 0.0,
		AntiInternalInjury   = false,
		BloodBurstAP         = 0,
		CounterBonus         = 0,
		CritHeadBonus        = 0,
		HitChanceBonus       = 0,
		IgnoreDodgeHalf      = false,
		MoveAPDiscount       = 0,
		ThrowingDmgBonus     = 0.0,
		ZoCBonusHit          = 0,
		SupportShotChance    = 0,
		StaffGuard           = false,
		FastAdaptBonus       = 0,
		SurroundHitBonus     = 0,
		GuixiTier            = 0,
		EmptyOffhandPen      = 0.0,
		CommandAuraPct       = 0.0,
		RallyBonus           = 0,
		JingangStunPct       = 0,
		DisarmHitBonus       = 0,
		WuduPoisonPct        = 0,
		PoisonImmune         = false,
		VsPoisonedHit        = 0,
		ReflectArmorDmg      = 0,
		VsUndeadDmg          = 0.0,
		AntiFearAura         = false,
		FirearmDazePct       = 0,
		FrostChillOnHit      = false,
		InflictOpeningPct    = null,
		InflictOffBalancePct = null,
		ExecuteLowHpDmg      = 0.0,
		FirstRoundInit       = 0,
		FirstRoundHit        = 0,
		UnbrokenArmorBonus   = 0.0,
		UnarmoredBonusDmg    = 0.0,
		BleedOnHitPct        = 0,
		DazeOnHeavyHitPct    = 0,
		ExposeOnHitPct       = 0,
		AcupointOnCritPct    = 0,
		ShieldBreakBonus     = 0,
		ShieldDefBonus       = 0,
		ShieldWallExpert     = false,
		PolearmMastery       = false,
		UnderdogGuard        = false,
		LoneWolfBonus        = 0,
		FormationBondDef     = 0,
		OnKillHealHP         = 0,
		OnHitDrainQi         = 0,
		RangedHeadshotBonus  = 0,
		LongRangeAccBonus    = 0,
		CloseRangeShotBonus  = 0,
		NightOwl             = false,
		DodgeRangedBonus     = 0,
		TurnStartCleansePct  = 0,
		HasFragmentManual    = false
	};

	if (_container == null) return agg;
	local skills = _container.getContainer();
	local actor = skills == null ? null : skills.getActor();
	local items = actor == null ? null : actor.getItems();
	local weapon = items == null ? null : items.getItemAtSlot(::Const.ItemSlot.Mainhand);

	foreach (s in _container.m.Slots)
	{
		if (s.ManualID == null || s.Tier <= 0) continue;
		local def = ::Wuxia.Slots.getPracticedDef(_container, s);
		if (def == null) continue;
		if (s.IsFragment) agg.HasFragmentManual = true;
		local tierIdx = ::Math.min(s.Tier, def.Levels.len()) - 1;
		local level = def.Levels[tierIdx];
		local f = level.Flags;
		// Quick Hands also applies when switching *to* the throwing weapon.
		if ("QuickHands" in f && f.QuickHands) agg.QuickHands = true;
		if (!::Wuxia.CombatRules.matchesWeapon(weapon, def.WeaponTypes)) continue;
		if (def.Category == "waigong" && def.WeaponTypes.find("Polearm") != null)
		{
			local isBannerWpn = (weapon != null && ::Wuxia.hasMember(weapon, "getID") && weapon.getID() != null && weapon.getID().tolower().find("banner") != null);
			if (s.Tier >= 2 || isBannerWpn) agg.PolearmMastery = true;
		}
		foreach (stat, delta in level.Stats)
		{
			local value = delta;
			if (def.Category == "neigong" && s.SlotIndex != 0 && (stat == "Stamina" || stat == "FatigueRecoveryRate"))
				value = ::Math.floor(value * 0.5);
			if (!(stat in agg.Stats)) agg.Stats[stat] <- value;
			else if (stat == "MeleeSkill" || stat == "MeleeDefense" || stat == "RangedSkill" || stat == "RangedDefense")
				agg.Stats[stat] = ::Math.max(agg.Stats[stat], value);
			else agg.Stats[stat] += value;
		}

		if ("PermanentAPBonus" in f)     agg.PermanentAPBonus += f.PermanentAPBonus;
		if ("OnHitQiRegen" in f)         agg.OnHitQiRegen = ::Math.max(agg.OnHitQiRegen, f.OnHitQiRegen);
		if ("OnHitQiCap" in f)           agg.OnHitQiCap = ::Math.max(agg.OnHitQiCap, f.OnHitQiCap);
		if ("OnDodgeQiRegen" in f)       agg.OnDodgeQiRegen = ::Math.max(agg.OnDodgeQiRegen, f.OnDodgeQiRegen);
		if ("OnDodgeQiCap" in f)         agg.OnDodgeQiCap = ::Math.max(agg.OnDodgeQiCap, f.OnDodgeQiCap);
		if ("OnKillQiRegen" in f)        agg.OnKillQiRegen = ::Math.max(agg.OnKillQiRegen, f.OnKillQiRegen);
		if ("OnKillAPRefund" in f)       agg.OnKillAPRefund = ::Math.max(agg.OnKillAPRefund, f.OnKillAPRefund);
		if ("QiShieldPct" in f && f.QiShieldPct > agg.QiShieldPct)                         agg.QiShieldPct = f.QiShieldPct;
		if ("LightArmorMitigation" in f && f.LightArmorMitigation > agg.LightArmorMitigation) agg.LightArmorMitigation = f.LightArmorMitigation;
		if ("HeavyArmorScale" in f && f.HeavyArmorScale > agg.HeavyArmorScale)             agg.HeavyArmorScale = f.HeavyArmorScale;
		if ("InitToDefRatio" in f && f.InitToDefRatio > agg.InitToDefRatio)                agg.InitToDefRatio = f.InitToDefRatio;
		if ("TerrainCostHalved" in f && f.TerrainCostHalved) agg.TerrainCostHalved = true;
		if ("ElevationDiscount" in f && f.ElevationDiscount) agg.ElevationDiscount = true;
		if ("InjuryThresholdMult" in f && f.InjuryThresholdMult > agg.InjuryThresholdMult) agg.InjuryThresholdMult = f.InjuryThresholdMult;
		if ("WeaponQiDiscount" in f && f.WeaponQiDiscount > agg.WeaponQiDiscount)          agg.WeaponQiDiscount = f.WeaponQiDiscount;
		if ("ArmorDmgBonus" in f && f.ArmorDmgBonus > agg.ArmorDmgBonus) agg.ArmorDmgBonus = f.ArmorDmgBonus;
		if ("DirectDmgBonus" in f && f.DirectDmgBonus > agg.DirectDmgBonus) agg.DirectDmgBonus = f.DirectDmgBonus;
		if ("ArmorPenBonus" in f && f.ArmorPenBonus > agg.DirectDmgBonus) agg.DirectDmgBonus = f.ArmorPenBonus;
		// These bonuses use the strongest equipped source, including fractional damage.
		foreach (key in ["AntiInternalInjury", "IgnoreDodgeHalf", "StaffGuard", "PoisonImmune",
			"AntiFearAura", "FrostChillOnHit", "ShieldWallExpert", "PolearmMastery", "UnderdogGuard", "NightOwl"])
			if (key in f && f[key]) agg[key] = true;
		foreach (key in ["BloodBurstAP", "CounterBonus", "CritHeadBonus", "HitChanceBonus",
			"MoveAPDiscount", "ThrowingDmgBonus", "ZoCBonusHit", "SupportShotChance",
			"FastAdaptBonus", "SurroundHitBonus", "GuixiTier", "EmptyOffhandPen",
			"CommandAuraPct", "RallyBonus", "JingangStunPct", "DisarmHitBonus",
			"WuduPoisonPct", "VsPoisonedHit", "ReflectArmorDmg", "VsUndeadDmg", "FirearmDazePct",
			"ExecuteLowHpDmg", "FirstRoundInit", "FirstRoundHit", "UnbrokenArmorBonus",
			"UnarmoredBonusDmg", "BleedOnHitPct", "DazeOnHeavyHitPct", "ExposeOnHitPct",
			"AcupointOnCritPct", "ShieldBreakBonus", "ShieldDefBonus", "LoneWolfBonus",
			"FormationBondDef", "OnKillHealHP", "OnHitDrainQi", "RangedHeadshotBonus",
			"LongRangeAccBonus", "CloseRangeShotBonus", "DodgeRangedBonus", "TurnStartCleansePct"])
			if (key in f && f[key] > agg[key]) agg[key] = f[key];
		if ("InflictOpeningPct" in f && (agg.InflictOpeningPct == null || f.InflictOpeningPct > agg.InflictOpeningPct))
			agg.InflictOpeningPct = f.InflictOpeningPct;
		if ("InflictOffBalancePct" in f && (agg.InflictOffBalancePct == null || f.InflictOffBalancePct > agg.InflictOffBalancePct))
			agg.InflictOffBalancePct = f.InflictOffBalancePct;
	}

	// Enforce hard permanent AP bonus cap (+2 -> 11 AP max)
	agg.PermanentAPBonus = ::Math.min(::Wuxia.Config.Constants.MaxPermanentAPBonus, agg.PermanentAPBonus);
	return agg;
};

// Canonical whitelist of all recognized manual Flags (validated in selftest.nut to catch any typo!)
::Wuxia.CombatRules.KnownFlags <- {
	PermanentAPBonus = true, OnHitQiRegen = true, OnHitQiCap = true, OnDodgeQiRegen = true,
	OnDodgeQiCap = true, OnKillQiRegen = true, OnKillAPRefund = true, QiShieldPct = true,
	LightArmorMitigation = true, HeavyArmorScale = true, InitToDefRatio = true,
	TerrainCostHalved = true, ElevationDiscount = true, QuickHands = true,
	InjuryThresholdMult = true, WeaponQiDiscount = true, ArmorDmgBonus = true,
	DirectDmgBonus = true, ArmorPenBonus = true, AntiInternalInjury = true,
	BloodBurstAP = true, CounterBonus = true, CritHeadBonus = true, HitChanceBonus = true,
	IgnoreDodgeHalf = true, MoveAPDiscount = true, ThrowingDmgBonus = true, ZoCBonusHit = true,
	SupportShotChance = true, StaffGuard = true, FastAdaptBonus = true, SurroundHitBonus = true,
	GuixiTier = true, EmptyOffhandPen = true, CommandAuraPct = true, RallyBonus = true,
	JingangStunPct = true, DisarmHitBonus = true, WuduPoisonPct = true, PoisonImmune = true,
	VsPoisonedHit = true, ReflectArmorDmg = true, VsUndeadDmg = true, AntiFearAura = true,
	FirearmDazePct = true, FrostChillOnHit = true, InflictOpeningPct = true,
	InflictOffBalancePct = true, ExecuteLowHpDmg = true, FirstRoundInit = true,
	FirstRoundHit = true, UnbrokenArmorBonus = true, UnarmoredBonusDmg = true,
	BleedOnHitPct = true, DazeOnHeavyHitPct = true, ExposeOnHitPct = true,
	AcupointOnCritPct = true, ShieldBreakBonus = true, ShieldDefBonus = true,
	ShieldWallExpert = true, PolearmMastery = true, UnderdogGuard = true, LoneWolfBonus = true,
	FormationBondDef = true, OnKillHealHP = true, OnHitDrainQi = true,
	RangedHeadshotBonus = true, LongRangeAccBonus = true, CloseRangeShotBonus = true,
	NightOwl = true, DodgeRangedBonus = true, TurnStartCleansePct = true,
	HarmonizeConflict = true, GrantWashChance = true
};

::Wuxia.CombatRules.getArmorStaminaPenalty <- function( _actor )
{
	if (_actor == null) return 0;
	local pen = 0;
	local body = _actor.getItems().getItemAtSlot(::Const.ItemSlot.Body);
	local head = _actor.getItems().getItemAtSlot(::Const.ItemSlot.Head);
	if (body != null) pen += ::Math.abs(body.getStaminaModifier());
	if (head != null) pen += ::Math.abs(head.getStaminaModifier());
	return pen;
};

::Wuxia.CombatRules.getLightArmorDamageMult <- function( _actor, _maxMitigation )
{
	if (_maxMitigation <= 0.0) return 1.0;
	local pen = ::Wuxia.CombatRules.getArmorStaminaPenalty(_actor);
	if (pen <= 15) return 1.0 - _maxMitigation;
	// Smooth decay above 15 fatigue penalty (matching vanilla Nimble philosophy)
	local excess = pen - 15;
	local reduced = _maxMitigation - (excess * 0.025);
	if (reduced < 0.0) reduced = 0.0;
	return 1.0 - reduced;
};

::Wuxia.CombatRules.restoreQi <- function( _actor, _amount )
{
	if (_actor == null || _amount <= 0) return;
	// In BB, Fatigue = used Qi; reducing Fatigue restores available Qi!
	local curFat = _actor.getFatigue();
	local nextFat = ::Math.max(0, curFat - _amount);
	_actor.setFatigue(nextFat);
};

::Wuxia.CombatRules.spendQi <- function( _actor, _amount )
{
	if (_actor == null || _amount <= 0) return 0;
	local avail = _actor.getFatigueMax() - _actor.getFatigue();
	local actual = ::Math.max(0, ::Math.min(avail, _amount));
	if (actual > 0)
	{
		_actor.setFatigue(_actor.getFatigue() + actual);
	}
	return actual;
};

::Wuxia.CombatRules.drainAdjacentQi <- function( _actor )
{
	local tile = _actor.getTile();
	local drained = 0;
	for (local dir = 0; dir < ::Const.Direction.COUNT; ++dir)
	{
		if (!tile.hasNextTile(dir)) continue;
		local adjacent = tile.getNextTile(dir);
		if (!adjacent.IsOccupiedByActor) continue;
		local target = adjacent.getEntity();
		if (_actor.isAlliedWith(target) || this.isUndeadOrConstruct(target)) continue;
		drained += this.spendQi(target, 6);
	}
	if (drained > 0)
	{
		this.restoreQi(_actor, drained);
		_actor.setHitpoints(::Math.min(_actor.getHitpointsMax(), _actor.getHitpoints() + drained));
	}
	return drained;
};

// Bug 7 Fix: Rebalance vanilla Sword `actives.riposte` & `effects.riposte` so players can NEVER stack
// double counter-stances (`riposte` + `wx_status_counter_stance`) or infinitely counter solo armies!
if ("HooksMod" in ::Wuxia && ::Wuxia.HooksMod != null)
{
	::Wuxia.HooksMod.hook("scripts/skills/actives/riposte", function( q )
	{
		q.m.WX_Cooldown <- 0;

		if (::Wuxia.qHas(q, "isUsable"))
		{
			q.isUsable = @(__original) function()
			{
				if (("WX_Cooldown" in this.m) && this.m.WX_Cooldown > 0)
					return false;
				if (this.getContainer() != null && this.getContainer().hasSkill("effects.wx_status_counter_stance"))
					return false;
				return __original();
			};
		}

		if (::Wuxia.qHas(q, "onUse"))
		{
			q.onUse = @(__original) function( _user, _targetTile )
			{
				if (this.getContainer() != null && this.getContainer().hasSkill("effects.wx_status_counter_stance"))
					this.getContainer().removeByID("effects.wx_status_counter_stance");
				local ok = __original(_user, _targetTile);
				if (ok) this.m.WX_Cooldown <- 2;
				return ok;
			};
		}

		if (::Wuxia.qHas(q, "onTurnStart"))
		{
			q.onTurnStart = @(__original) function()
			{
				__original();
				if (("WX_Cooldown" in this.m) && this.m.WX_Cooldown > 0)
					this.m.WX_Cooldown -= 1;
			};
		}
		else
		{
			q.onTurnStart <- function()
			{
				if (("WX_Cooldown" in this.m) && this.m.WX_Cooldown > 0)
					this.m.WX_Cooldown -= 1;
			};
		}
		q.onCombatStarted <- function() { this.m.WX_Cooldown <- 0; };
		q.onCombatFinished <- function() { this.m.WX_Cooldown <- 0; };
	});

	::Wuxia.HooksMod.hook("scripts/skills/skill", function( q )
	{
		if (::Wuxia.qHas(q, "use"))
		{
			q.use = @(__original) function( _targetTile, _forFree = false )
			{
				local ret = __original(_targetTile, _forFree);
				::Wuxia.CombatRules.bumpTacticalAuraEpoch();
				return ret;
			};
		}
	});

	::Wuxia.HooksMod.hook("scripts/skills/effects/riposte_effect", function( q )
	{
		q.m.WX_CountersUsed <- 0;
		q.m.WX_InRiposteSwing <- false;

		q.onAdded <- function()
		{
			this.m.WX_CountersUsed <- 0;
			this.m.WX_InRiposteSwing <- false;
			if (this.getContainer() != null && this.getContainer().hasSkill("effects.wx_status_counter_stance"))
				this.getContainer().removeByID("effects.wx_status_counter_stance");
		};

		if (::Wuxia.qHas(q, "onAnySkillUsed"))
		{
			q.onAnySkillUsed = @(__original) function( _skill, _targetEntity, _properties )
			{
				__original(_skill, _targetEntity, _properties);
				if (("WX_InRiposteSwing" in this.m) && this.m.WX_InRiposteSwing)
				{
					local used = ("WX_CountersUsed" in this.m) ? this.m.WX_CountersUsed : 0;
					if (used <= 0)
						_properties.DamageTotalMult *= 0.85;
					else
					{
						_properties.MeleeSkill -= 12;
						_properties.DamageTotalMult *= 0.65;
					}
				}
			};
		}

		if (::Wuxia.qHas(q, "onMissed"))
		{
			q.onMissed = @(__original) function( _attacker, _skill )
			{
				local cont = this.getContainer();
				if (cont == null) return;
				if (cont.hasSkill("effects.wx_status_counter_stance"))
				{
					this.removeSelf();
					return;
				}
				local actor = cont.getActor();
				if (actor == null || !actor.isAlive()) return;
				local used = ("WX_CountersUsed" in this.m) ? this.m.WX_CountersUsed : 0;
				if (used >= 2)
				{
					this.removeSelf();
					return;
				}
				local qiCost = (used == 0) ? 8 : 10;
				local availQi = actor.getFatigueMax() - actor.getFatigue();
				if (availQi < qiCost)
				{
					this.removeSelf();
					return;
				}
				::Wuxia.CombatRules.spendQi(actor, qiCost);
				this.m.WX_InRiposteSwing <- true;
				try { __original(_attacker, _skill); }
				catch (err) { this.m.WX_InRiposteSwing <- false; throw err; }
				this.m.WX_InRiposteSwing <- false;
				this.m.WX_CountersUsed <- used + 1;
				if (this.m.WX_CountersUsed >= 2)
				{
					if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
						::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(actor) + " 格反剑势已尽，收剑回防。");
					this.removeSelf();
				}
			};
		}
	});
}

// =============================================================================
// Issue 9 Overhaul: 12-Archetype Martial Skill Mechanics Registry & Qinggong Arrival Traits
// Eliminates skill homogenization across all weapon families while strictly obeying AGENTS.md caps!
// =============================================================================
::Wuxia.CombatRules.SkillMechanics <- {
	// 1. 掠影过身 (`step_through`): Vault through enemy into empty hex behind them
	["actives.wx_sword_feixian"]   = "step_through",
	["actives.wx_sword_kuangfeng"] = "step_through",
	["actives.wx_sword_duoming"]   = "step_through",
	["actives.wx_dagger_yingci"]   = "step_through",
	["actives.wx_dagger_shenghuo"] = "step_through",
	["actives.wx_dagger_vital"]    = "step_through",

	// 2. 燕返脱兔 (`backstep`): Skirmisher 1-hex disengage backflip after striking/shooting
	["actives.wx_sword_yunv"]      = "backstep",
	["actives.wx_sword_huifeng"]   = "backstep",
	["actives.wx_spear_liuhua"]    = "backstep",
	["actives.wx_bow_yanxing"]     = "backstep",
	["actives.wx_bow_liuxing"]     = "backstep",
	["actives.wx_throw_liuyedao"]  = "backstep",
	["actives.wx_throw_fan"]       = "backstep",

	// 3. 摧锋踏进 (`push_advance`): Break stance, knock target back 1 hex, and step into vacated hex
	["actives.wx_saber_baji"]      = "push_advance",
	["actives.wx_saber_podao"]     = "push_advance",
	["actives.wx_saber_zhanlang"]  = "push_advance",
	["actives.wx_spear_bawang"]    = "push_advance",
	["actives.wx_spear_zhenbiao"]  = "push_advance",
	["actives.wx_fist_nuchao"]     = "push_advance",
	["actives.wx_hama_push"]       = "push_advance",
	["actives.wx_axe_kaitian"]     = "push_advance",
	["actives.wx_henglian_tongtou"]= "push_advance",
	["actives.wx_shield_bash_qi"]  = "push_advance",

	// 4. 破绽引爆 (`detonate_opening`): Ignore shield & +8 Hit vs Opening; detonate Opening for +8 Qi & +10 direct dmg
	["actives.wx_sword_dugu"]      = "detonate_opening",
	["actives.wx_sword_qinggang"]  = "detonate_opening",
	["actives.wx_sword_miejian"]   = "detonate_opening",
	["actives.wx_sword_zixia"]     = "detonate_opening",
	["actives.wx_sword_pierce"]    = "detonate_opening",
	["actives.wx_sword_cuixin"]    = "detonate_opening",
	["actives.wx_dagger_jingke"]   = "detonate_opening",
	["actives.wx_dagger_zhuanzhu"] = "detonate_opening",
	["actives.wx_dagger_execute"]  = "detonate_opening",
	["actives.wx_dagger_fuxue"]    = "detonate_opening",

	// 5. 血煞催创 (`detonate_bleed`): Rupture bleeding targets for +14 burst HP damage & +6 self-heal
	["actives.wx_saber_shishen"]   = "detonate_bleed",
	["actives.wx_saber_xuehai"]    = "detonate_bleed",
	["actives.wx_saber_tuxiong"]   = "detonate_bleed",
	["actives.wx_saber_duanyue"]   = "detonate_bleed",
	["actives.wx_saber_xinyue"]    = "detonate_bleed",
	["actives.wx_sword_yinsha"]    = "detonate_bleed",
	["actives.wx_axe_xueming"]     = "detonate_bleed",
	["actives.wx_fist_xiongzhao"]  = "detonate_bleed",
	["actives.wx_fist_jiuyin"]     = "detonate_bleed",
	["actives.wx_pole_fenjiang"]   = "detonate_bleed",

	// 6. 隔甲寸劲 (`concuss_armor`): Shock up to 18 Qi proportional to enemy armor weight; heavy armor -> Offbalance
	["actives.wx_fist_tiegang"]    = "concuss_armor",
	["actives.wx_fist_heisha"]     = "concuss_armor",
	["actives.wx_fist_piaoxue"]    = "concuss_armor",
	["actives.wx_fist_luohan"]     = "concuss_armor",
	["actives.wx_fist_qishang"]    = "concuss_armor",
	["actives.wx_fist_jingang"]    = "concuss_armor",
	["actives.wx_fist_shock"]      = "concuss_armor",
	["actives.wx_fist_xianglong"]  = "concuss_armor",
	["actives.wx_hammer_jingua"]   = "concuss_armor",
	["actives.wx_hammer_qianjun"]  = "concuss_armor",
	["actives.wx_hammer_shatter"]  = "concuss_armor",
	["actives.wx_hammer_leiting"]  = "concuss_armor",
	["actives.wx_hammer_polu"]     = "concuss_armor",
	["actives.wx_hammer_faqiu"]    = "concuss_armor",
	["actives.wx_staff_weituo"]    = "concuss_armor",
	["actives.wx_staff_fengmo"]    = "concuss_armor",

	// 7. 隔山贯阵 (`pierce_line`): Skewer enemy directly behind primary target along attack vector
	["actives.wx_spear_panlong"]   = "pierce_line",
	["actives.wx_spear_xuelong"]   = "pierce_line",
	["actives.wx_spear_thrust2"]   = "pierce_line",
	["actives.wx_spear_liangyin"]  = "pierce_line",
	["actives.wx_fist_canhezhi"]   = "pierce_line",
	["actives.wx_fist_yiyang"]     = "pierce_line",
	["actives.wx_bow_jiuxing"]     = "pierce_line",
	["actives.wx_crossbow_shenji"] = "pierce_line",
	["actives.wx_saber_huoyandao"] = "pierce_line",

	// 8. 蛊毒蔓生 (`spread_venom`): Contagious venom cloud spreads poison & -12 armor to up to 2 adjacent foes
	["actives.wx_fist_qianzhu"]    = "spread_venom",
	["actives.wx_fist_xuanming"]   = "spread_venom",
	["actives.wx_sword_xuanbing"]  = "spread_venom",
	["actives.wx_flail_jinshe"]    = "spread_venom",
	["actives.wx_crossbow_liannu"] = "spread_venom",
	["actives.wx_throw_duzhen"]    = "spread_venom",
	["actives.wx_throw_kongque"]   = "spread_venom",
	["actives.wx_smoke_cast"]      = "spread_venom",

	// 9. 断盾余威 (`shatter_shield`): Crush shield (-26 cond); if unshielded or broken, spillover -18 body armor + Offbalance
	["actives.wx_axe_poche"]       = "shatter_shield",
	["actives.wx_axe_split"]       = "shatter_shield",
	["actives.wx_axe_kaishan"]     = "shatter_shield",
	["actives.wx_saber_chiyou"]    = "shatter_shield",
	["actives.wx_saber_modao"]     = "shatter_shield",
	["actives.wx_sword_zhongjian"] = "shatter_shield",
	["actives.wx_flail_panlong"]   = "shatter_shield",
	["actives.wx_flail_liuxing"]   = "shatter_shield",
	["actives.wx_flail_lash"]      = "shatter_shield",

	// 10. 擒龙摄影 (`pull_closer`): Drag 2-hex target into adjacent ZoC or drain 8 Qi in melee
	["actives.wx_fist_longzhao"]   = "pull_closer",
	["actives.wx_fist_grapple"]    = "pull_closer",
	["actives.wx_fist_nianhua"]    = "pull_closer",
	["actives.wx_fist_taiji"]      = "pull_closer",
	["actives.wx_pole_goulian"]    = "pull_closer",
	["actives.wx_whip_xiangxi"]    = "pull_closer",
	["actives.wx_whip_suohou"]     = "pull_closer",
	["actives.wx_flail_entangle"]  = "pull_closer",
	["actives.wx_staff_lianhua"]   = "pull_closer",
	["actives.wx_staff_dagou"]     = "pull_closer",

	// 11. 困兽破围 (`surround_scale`): Gain +4 Hit & +8% Armor Dmg per extra surrounding foe + restore 5 Qi on hit
	["actives.wx_sword_wanjian"]   = "surround_scale",
	["actives.wx_sword_taiji"]     = "surround_scale",
	["actives.wx_sword_zhenwu"]    = "surround_scale",
	["actives.wx_sword_combo"]     = "surround_scale",
	["actives.wx_saber_abi"]       = "surround_scale",
	["actives.wx_saber_kuanglan"]  = "surround_scale",
	["actives.wx_saber_sweep"]     = "surround_scale",
	["actives.wx_saber_bagua"]     = "surround_scale",
	["actives.wx_saber_fanzhen"]   = "surround_scale",
	["actives.wx_fist_rulai"]      = "surround_scale",
	["actives.wx_pole_pojun"]      = "surround_scale",
	["actives.wx_pole_fangtian"]   = "surround_scale",
	["actives.wx_pole_sweep"]      = "surround_scale",
	["actives.wx_staff_qingou"]    = "surround_scale",
	["actives.wx_staff_zhenjiang"] = "surround_scale",
	["actives.wx_hammer_pocheng"]  = "surround_scale",
	["actives.wx_hammer_quake"]    = "surround_scale",
	["actives.wx_axe_whirl"]       = "surround_scale",

	// 12. 天外凌空 (`high_ground`): +6 Hit & +6% Pen per elevation advantage + shred 14 armor on hit
	["actives.wx_sword_tianwai"]   = "high_ground",
	["actives.wx_bow_luori"]       = "high_ground",
	["actives.wx_bow_snipe"]       = "high_ground",
	["actives.wx_gun_huolong"]     = "high_ground",
	["actives.wx_gun_leihuo"]      = "high_ground",
	["actives.wx_throw_pilidan"]   = "high_ground",
	["actives.wx_throwing_rain"]   = "high_ground",
	["actives.wx_saber_ranmu"]     = "high_ground"
};

::Wuxia.CombatRules.triggerQinggongDistinctiveEffect <- function( _skillID, _user, _originTile, _destTile )
{
	if (_user == null || !_user.isAlive() || !::Wuxia.isOnMap(_user)) return;
	if ("Streams" in ::Wuxia)
	{
		local stW = ::Wuxia.Streams.getOrCreateState(_user);
		if (stW != null) stW.addWindSteps(2);
	}
	local usk = _user.getSkills();
	if (_skillID == "actives.wx_qinggong_meiying")
	{
		if (usk != null && !usk.hasSkill("effects.wx_status_smoke_screen"))
			usk.add(::new("scripts/skills/effects/wx_status_smoke_screen"));
	}
	else if (_skillID == "actives.wx_qinggong_xuelian" && _originTile != null)
	{
		for (local d = 0; d < 6; d = ++d)
		{
			if (!_originTile.hasNextTile(d)) continue;
			local nt = _originTile.getNextTile(d);
			if (nt.IsOccupiedByActor && nt.getEntity() != null && nt.getEntity().isAlive() && !_user.isAlliedWith(nt.getEntity()) && !this.isUndeadOrConstruct(nt.getEntity()))
				this.spendQi(nt.getEntity(), 8);
		}
	}
	else if (_skillID == "actives.wx_qinggong_feiyan" && _originTile != null && _destTile != null)
	{
		if (_destTile.Level > _originTile.Level)
			this.restoreQi(_user, 8);
	}
	else if (_skillID == "actives.wx_qinggong_yanxing" && _originTile != null)
	{
		local adjFoes = 0;
		for (local d2 = 0; d2 < 6; d2 = ++d2)
		{
			if (!_originTile.hasNextTile(d2)) continue;
			local nt2 = _originTile.getNextTile(d2);
			if (nt2.IsOccupiedByActor && nt2.getEntity() != null && nt2.getEntity().isAlive() && !_user.isAlliedWith(nt2.getEntity()))
				adjFoes += 1;
		}
		if (adjFoes >= 2)
			this.restoreQi(_user, 6);
	}
	else if (_skillID == "actives.wx_qinggong_suodi" && usk != null)
	{
		usk.removeByID("effects.wx_status_opening");
	}
};

// =============================================================================
// Dynamic Jianghu Campaign Threat & Enemy Progression (`动态江湖武道演进`)
// Scales enemy martial tiers, slot depth, and monster/camp stats across 5 Eras (0..4)
// while strictly honoring AGENTS.md caps (7 slots, Math.max passives, <= 11 AP, D100 bounds).
// =============================================================================
::Wuxia.CombatRules.ForcedThreatEra <- -1;
::Wuxia.CombatRules.ThreatLabels <- ["初入江湖", "崭露头角", "名动一方", "威震九州", "武林浩劫"];

::Wuxia.CombatRules.getCampaignThreatProfile <- function()
{
	if (::Wuxia.CombatRules.ForcedThreatEra >= 0)
	{
		local fe = ::Math.min(4, ::Wuxia.CombatRules.ForcedThreatEra);
		return {
			era   = fe,
			days  = 1 + fe * 28,
			avgLv = 1.0 + fe * 2.5,
			score = fe * 28.0,
			label = ::Wuxia.CombatRules.ThreatLabels[fe]
		};
	}

	if (!("World" in getroottable()) || ::World == null || !("getTime" in ::World))
		return { era = 0, days = 1, avgLv = 1.0, score = 0.0, label = "初入江湖" };

	local tObj = null;
	try { tObj = ::World.getTime(); } catch (_eT) { tObj = null; }
	if (tObj == null || !("Days" in tObj))
		return { era = 0, days = 1, avgLv = 1.0, score = 0.0, label = "初入江湖" };

	local days = ::Math.max(1, tObj.Days);
	local avgLv = 1.0;
	if ("getPlayerRoster" in ::World)
	{
		try
		{
			local roster = ::World.getPlayerRoster();
			if (roster != null && ::Wuxia.hasMember(roster, "getAll"))
			{
				local bros = roster.getAll();
				if (bros != null && bros.len() > 0)
				{
					local lvs = [];
					foreach (b in bros)
					{
						if (b != null && ::Wuxia.hasMember(b, "getLevel"))
							lvs.push(b.getLevel());
					}
					if (lvs.len() > 0)
					{
						lvs.sort(@(a, b) b <=> a);
						local topN = ::Math.min(8, lvs.len());
						local sumLv = 0.0;
						for (local k = 0; k < topN; ++k) sumLv += lvs[k];
						avgLv = sumLv / topN;
					}
				}
			}
		}
		catch (_eR) {}
	}

	local crisisBonus = 0.0;
	if ("Flags" in ::World && ::World.Flags != null && ::Wuxia.hasMember(::World.Flags, "has") && ::World.Flags.has("wx_active_crisis"))
	{
		local cr = ::World.Flags.get("wx_active_crisis");
		if (typeof cr == "string" && cr != "")
			crisisBonus = 12.0;
	}

	local powerScore = ::Math.max(days.tofloat(), (avgLv - 1.0) * 9.5) + crisisBonus;
	local era = 0;
	if (powerScore >= 88.0) era = 4;
	else if (powerScore >= 58.0) era = 3;
	else if (powerScore >= 34.0) era = 2;
	else if (powerScore >= 16.0) era = 1;

	return {
		era   = era,
		days  = days,
		avgLv = avgLv,
		score = powerScore,
		label = ::Wuxia.CombatRules.ThreatLabels[era]
	};
};

::Wuxia.CombatRules.applyDynamicEnemyScaling <- function( _actor )
{
	if (_actor == null || !_actor.isAlive() || _actor.isPlayerControlled())
		return;
	if (("WX_IsBossSubEntity" in _actor.m) && _actor.m.WX_IsBossSubEntity)
		return;
	if (("WX_DynScaled" in _actor.m) && _actor.m.WX_DynScaled)
		return;
	if (::Wuxia.hasMember(_actor, "isAlliedWithPlayer") && _actor.isAlliedWithPlayer())
		return;
	if ("Faction" in ::Const && ::Wuxia.hasMember(_actor, "getFaction"))
	{
		local af = _actor.getFaction();
		if (af == ::Const.Faction.Player || ("PlayerAnimals" in ::Const.Faction && af == ::Const.Faction.PlayerAnimals))
			return;
	}

	local threat = ::Wuxia.CombatRules.getCampaignThreatProfile();
	if (threat.era <= 0)
		return;

	local era = threat.era;
	_actor.m.WX_DynScaled <- true;
	_actor.m.WX_DynEra <- era;
	_actor.m.WX_DynLabel <- threat.label;

	local skills = _actor.getSkills();
	local isShanHaiBoss = (skills != null && (("ShanHai" in ::Wuxia && "findBossTrait" in ::Wuxia.ShanHai) ? (::Wuxia.ShanHai.findBossTrait(skills) != null) : skills.hasSkill("special.wx_shanhai_boss_trait")));
	local hasManuals = false;
	if (skills != null)
	{
		local mc = skills.getSkillByID("special.wx_martial_container");
		if (mc != null)
		{
			foreach (sl in mc.m.Slots)
			{
				if (sl.ManualID != null && sl.Tier > 0) { hasManuals = true; break; }
			}
		}
	}

	local bp = _actor.m.BaseProperties;
	if (bp == null) return;
	local prevMaxHP = ::Math.max(1, _actor.getHitpointsMax());
	local prevCurHP = _actor.getHitpoints();
	local hpRatio = ::Math.min(1.0, prevCurHP.tofloat() / prevMaxHP.tofloat());

	local hpMult = 1.0;
	if (isShanHaiBoss)
	{
		if (era >= 2)
		{
			local bStep = era - 1;
			hpMult = 1.0 + 0.08 * bStep;
			bp.MeleeSkill = ::Math.min(102, bp.MeleeSkill + 2 * bStep);
			bp.RangedSkill = ::Math.min(96, bp.RangedSkill + 2 * bStep);
			bp.Bravery += 5 * bStep;
		}
	}
	else if (hasManuals)
	{
		// Martial humans already gain upgraded Manual Tiers & extra Slots; apply crisp D100-safe veteran tempering
		hpMult = 1.0 + 0.06 * era;
		bp.MeleeSkill = ::Math.min(96, bp.MeleeSkill + 2 * era);
		bp.RangedSkill = ::Math.min(94, bp.RangedSkill + 2 * era);
		bp.MeleeDefense = ::Math.min(48, bp.MeleeDefense + 1 * era);
		bp.RangedDefense = ::Math.min(45, bp.RangedDefense + 1 * era);
		bp.Bravery += 3 * era;
		bp.Stamina += 4 * era;
	}
	else
	{
		// Wild ShanHai beasts, zombies, skeletons & monsters without 7-slot manuals scale to match Wuxia progression
		hpMult = 1.0 + 0.11 * era;
		bp.MeleeSkill = ::Math.min(95, bp.MeleeSkill + 3 * era);
		bp.RangedSkill = ::Math.min(92, bp.RangedSkill + 3 * era);
		bp.MeleeDefense = ::Math.min(45, bp.MeleeDefense + 2 * era);
		bp.RangedDefense = ::Math.min(45, bp.RangedDefense + 2 * era);
		bp.Bravery += 5 * era;
		bp.Stamina += 6 * era;
		if ("DamageRegularMin" in bp && bp.DamageRegularMax > 0)
		{
			bp.DamageRegularMin = ::Math.round(bp.DamageRegularMin * (1.0 + 0.04 * era)).tointeger();
			bp.DamageRegularMax = ::Math.round(bp.DamageRegularMax * (1.0 + 0.05 * era)).tointeger();
		}
	}

	if (hpMult > 1.001)
		bp.Hitpoints = ::Math.max(bp.Hitpoints + 2 * era, ::Math.round(bp.Hitpoints * hpMult).tointeger());

	// Temper non-named enemy armor durability in Era 2..4 so late-game garrisons hold the line
	if (era >= 2 && ::Wuxia.hasMember(_actor, "getItems") && _actor.getItems() != null)
	{
		local armMult = 1.0 + 0.06 * (era - 1);
		foreach (slotType in [::Const.ItemSlot.Body, ::Const.ItemSlot.Head])
		{
			local ar = _actor.getItems().getItemAtSlot(slotType);
			if (ar != null && !(::Wuxia.hasMember(ar, "isNamed") && ar.isNamed())
				&& ("ConditionMax" in ar.m) && ar.m.ConditionMax > 20 && !("WX_EraTempered" in ar.m))
			{
				ar.m.WX_EraTempered <- true;
				local oldMax = ar.m.ConditionMax;
				local newMax = ::Math.round(oldMax * armMult).tointeger();
				local delta = ::Math.max(0, newMax - oldMax);
				ar.m.ConditionMax = newMax;
				ar.m.Condition = ::Math.min(newMax, ar.m.Condition + delta);
			}
		}
	}

	if (skills != null)
		skills.update();
	if (hpMult > 1.001)
		_actor.setHitpoints(::Math.max(1, ::Math.round(_actor.getHitpointsMax() * hpRatio).tointeger()));
};
