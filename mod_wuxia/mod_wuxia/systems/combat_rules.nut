// Core Combat Rules: AP cap (11), 4-element Neigong Qi recovery, True Qi Shield, Light/Heavy mitigation

::Wuxia.CombatRules.matchesWeapon <- function( _weapon, _types )
{
	if (_types.len() == 0) return true;
	if (_weapon == null) return false;

	local wid = _weapon.getID().tolower();
	local cats = ("Categories" in _weapon.m && _weapon.m.Categories != null) ? _weapon.m.Categories.tolower() : "";

	foreach (wtName in _types)
	{
		// Path 1: MSU WeaponType if MSU is installed
		if ("WeaponType" in ::Const.Items && wtName in ::Const.Items.WeaponType)
		{
			if ("isWeaponType" in _weapon && _weapon.isWeaponType(::Const.Items.WeaponType[wtName]))
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
			if (wid.find("spear") != null || wid.find("pike") != null || wid.find("bill") != null || wid.find("halberd") != null || wid.find("spetum") != null || wid.find("pole") != null || wid.find("glaive") != null || wid.find("trident") != null || cats.find("spear") != null || cats.find("polearm") != null || cats.find("矛") != null || cats.find("枪") != null || cats.find("长柄") != null)
				return true;
		}
		else if (wtName == "Throwing")
		{
			if (wid.find("throwing") != null || wid.find("javelin") != null || wid.find("bolas") != null || cats.find("throwing") != null || cats.find("投掷") != null || cats.find("暗器") != null)
				return true;
		}
		else if (wtName == "Bow" && wid.find("bow") != null && wid.find("crossbow") == null) return true;
		else if (wtName == "Crossbow" && wid.find("crossbow") != null) return true;
		else if (wtName == "Staff" && (wid == "weapon.wooden_stick" || wid == "weapon.bludgeon" || wid == "weapon.goedendag")) return true;
		else if (wtName == "Fist" && (wid.find("wx_fist") != null || wid.find("wx_named_fist") != null || cats.find("fist") != null || cats.find("拳") != null || cats.find("掌") != null)) return true;
		else if (wtName == "Hammer" && (wid.find("hammer") != null || wid == "weapon.military_pick" || wid == "weapon.pickaxe" || wid == "weapon.heavy_mining_pick" || cats.find("hammer") != null || cats.find("锤") != null)) return true;
		else if (wtName == "Axe" && wid != "weapon.pickaxe" && (wid.find("axe") != null || wid.find("hatchet") != null || wid.find("bardiche") != null || cats.find("axe") != null || cats.find("斧") != null)) return true;
		else if (wtName == "Flail" && (wid.find("flail") != null || wid.find("whip") != null || cats.find("flail") != null || cats.find("连枷") != null || cats.find("鞭") != null)) return true;
		else if (wtName == "Dagger" && (wid.find("dagger") != null || wid == "weapon.knife" || wid.find("qatal") != null || wid == "weapon.goblin_notched_blade" || cats.find("dagger") != null || cats.find("匕") != null)) return true;
		else if (wtName == "Firearm" && (wid.find("handgonne") != null || wid.find("firelance") != null || wid.find("firearm") != null || cats.find("firearm") != null || cats.find("火器") != null || cats.find("火铳") != null)) return true;
	}
	return false;
};

::Wuxia.CombatRules.hasSingleHandEmptyOffhand <- function( _actor )
{
	if (_actor == null || !("getItems" in _actor)) return false;
	local items = _actor.getItems();
	if (items == null) return false;
	local main = items.getItemAtSlot(::Const.ItemSlot.Mainhand);
	if (main == null) return false;
	if (items.getItemAtSlot(::Const.ItemSlot.Offhand) != null || items.hasBlockedSlot(::Const.ItemSlot.Offhand))
		return false;
	if ("getBlockedSlotType" in main && main.getBlockedSlotType() != null)
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
		foreach (key in ["AntiInternalInjury", "IgnoreDodgeHalf", "StaffGuard", "PoisonImmune", "AntiFearAura", "FrostChillOnHit"])
			if (key in f && f[key]) agg[key] = true;
		foreach (key in ["BloodBurstAP", "CounterBonus", "CritHeadBonus", "HitChanceBonus",
			"MoveAPDiscount", "ThrowingDmgBonus", "ZoCBonusHit", "SupportShotChance",
			"FastAdaptBonus", "SurroundHitBonus", "GuixiTier", "EmptyOffhandPen",
			"CommandAuraPct", "RallyBonus", "JingangStunPct", "DisarmHitBonus",
			"WuduPoisonPct", "VsPoisonedHit", "ReflectArmorDmg", "VsUndeadDmg", "FirearmDazePct"])
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
	local actual = ::Math.min(avail, _amount);
	if (actual > 0)
	{
		_actor.setFatigue(_actor.getFatigue() + actual);
	}
	return actual;
};
