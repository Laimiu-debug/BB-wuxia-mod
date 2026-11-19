// Core Combat Rules: AP cap (11), 4-element Neigong Qi recovery, True Qi Shield, Light/Heavy mitigation

::Wuxia.CombatRules.getAggregateFlags <- function( _container )
{
	local agg = {
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
		InflictOpeningPct    = 0,
		InflictOffBalancePct = 0,
		HasFragmentManual    = false
	};

	if (_container == null) return agg;

	foreach (s in _container.m.Slots)
	{
		if (s.ManualID == null || s.Tier <= 0) continue;
		if (s.IsFragment) agg.HasFragmentManual = true;

		local def = ::Wuxia.Slots.getManualDef(s.ManualID);
		if (def == null) continue;
		local tierIdx = ::Math.min(s.Tier, def.Levels.len()) - 1;
		local f = def.Levels[tierIdx].Flags;

		if ("PermanentAPBonus" in f)     agg.PermanentAPBonus += f.PermanentAPBonus;
		if ("OnHitQiRegen" in f)         agg.OnHitQiRegen = ::Math.max(agg.OnHitQiRegen, f.OnHitQiRegen);
		if ("OnHitQiCap" in f)           agg.OnHitQiCap = ::Math.max(agg.OnHitQiCap, f.OnHitQiCap);
		if ("OnDodgeQiRegen" in f)       agg.OnDodgeQiRegen = ::Math.max(agg.OnDodgeQiRegen, f.OnDodgeQiRegen);
		if ("OnDodgeQiCap" in f)         agg.OnDodgeQiCap = ::Math.max(agg.OnDodgeQiCap, f.OnDodgeQiCap);
		if ("OnKillQiRegen" in f)        agg.OnKillQiRegen += f.OnKillQiRegen;
		if ("OnKillAPRefund" in f)       agg.OnKillAPRefund = ::Math.max(agg.OnKillAPRefund, f.OnKillAPRefund);
		if ("QiShieldPct" in f && f.QiShieldPct > agg.QiShieldPct)                         agg.QiShieldPct = f.QiShieldPct;
		if ("LightArmorMitigation" in f && f.LightArmorMitigation > agg.LightArmorMitigation) agg.LightArmorMitigation = f.LightArmorMitigation;
		if ("HeavyArmorScale" in f && f.HeavyArmorScale > agg.HeavyArmorScale)             agg.HeavyArmorScale = f.HeavyArmorScale;
		if ("InitToDefRatio" in f && f.InitToDefRatio > agg.InitToDefRatio)                agg.InitToDefRatio = f.InitToDefRatio;
		if ("TerrainCostHalved" in f && f.TerrainCostHalved) agg.TerrainCostHalved = true;
		if ("ElevationDiscount" in f && f.ElevationDiscount) agg.ElevationDiscount = true;
		if ("QuickHands" in f && f.QuickHands) agg.QuickHands = true;
		if ("InjuryThresholdMult" in f && f.InjuryThresholdMult > agg.InjuryThresholdMult) agg.InjuryThresholdMult = f.InjuryThresholdMult;
		if ("WeaponQiDiscount" in f && f.WeaponQiDiscount > agg.WeaponQiDiscount)          agg.WeaponQiDiscount = f.WeaponQiDiscount;
		if ("ArmorDmgBonus" in f)        agg.ArmorDmgBonus += f.ArmorDmgBonus;
		if ("DirectDmgBonus" in f)       agg.DirectDmgBonus += f.DirectDmgBonus;
		if ("InflictOpeningPct" in f)    agg.InflictOpeningPct = ::Math.max(agg.InflictOpeningPct, f.InflictOpeningPct);
		if ("InflictOffBalancePct" in f) agg.InflictOffBalancePct = ::Math.max(agg.InflictOffBalancePct, f.InflictOffBalancePct);
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
