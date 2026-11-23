// Shared Composable Equipment Passive Skill (`百工兽魄` & `山海神通`)
// Attached dynamically by Beast/Shan-Hai weapons, shields, armors & helmets in `onEquip()`,
// and automatically removed by Battle Brothers' native `item.onUnequip()`!

this.wx_gear_spirit_trait <- this.inherit("scripts/skills/skill", {
	m = {
		TraitID           = "",
		KillHealsThisTurn = 0,
		SelfQiThisTurn    = 0,
		DrainHpThisTurn   = 0,
		IsIntercepting    = false
	},

	function create()
	{
		this.m.ID = "special.wx_gear_spirit_trait";
		this.m.Name = "山海灵蕴";
		this.m.Description = "异兽奇材与山海内丹淬入兵甲所凝的本命神通。";
		this.m.Icon = "ui/perks/wx_shanhai_boss_trait.png";
		this.m.Type = this.Const.SkillType.Special;
		this.m.Order = this.Const.SkillOrder.Trait;
		this.m.IsActive = false;
		this.m.IsStacking = true;
		this.m.IsHidden = true;
		this.m.IsSerialized = false;
	}

	function setTraitID( _traitID )
	{
		this.m.TraitID = _traitID;
		local cfg = this.getTraitCfg();
		if (cfg != null)
		{
			this.m.Name = cfg.Title;
			this.m.Description = cfg.Text;
		}
	}

	function getTraitCfg()
	{
		if ("GearTraits" in ::Wuxia.Config && (this.m.TraitID in ::Wuxia.Config.GearTraits))
			return ::Wuxia.Config.GearTraits[this.m.TraitID];
		return null;
	}

	function isMasterworkGear()
	{
		local it = this.getItem();
		return (it != null && ::Wuxia.hasMember(it, "m") && ("WX_ForgeGrade" in it.m) && it.m.WX_ForgeGrade >= 3);
	}

	function wxGetCurrentRound()
	{
		if (("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive()
			&& ("TurnSequenceBar" in ::Tactical) && ::Tactical.TurnSequenceBar != null)
		{
			return ::Tactical.TurnSequenceBar.getCurrentRound();
		}
		return 1;
	}

	function wxApplyStatusSafe( _tsk, _effectID, _scriptPath )
	{
		if (_tsk == null) return;
		local ex = _tsk.getSkillByID(_effectID);
		if (ex == null) _tsk.add(::new(_scriptPath));
		else if (::Wuxia.hasMember(ex, "resetDuration")) ex.resetDuration();
	}

	function onTurnStart()
	{
		this.m.KillHealsThisTurn = 0;
		this.m.SelfQiThisTurn = 0;
		this.m.DrainHpThisTurn = 0;

		local cfg = this.getTraitCfg();
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		if (cfg == null || actor == null || !actor.isAlive()) return;

		if (("ImmuneAcidAndFireAura" in cfg) && cfg.ImmuneAcidAndFireAura && cont != null)
		{
			foreach (acidID in ["effects.acid", "effects.lindwurm_acid"])
			{
				if (cont.hasSkill(acidID)) cont.removeByID(acidID);
			}
		}

		local mwBonus = this.isMasterworkGear() ? 2 : 0;

		if (("TurnRegenHP" in cfg) && cfg.TurnRegenHP > 0 && actor.getHitpoints() < actor.getHitpointsMax())
		{
			actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + cfg.TurnRegenHP + (mwBonus > 0 ? 1 : 0)));
		}

		local items = (::Wuxia.hasMember(actor, "getItems")) ? actor.getItems() : null;
		if (items != null)
		{
			if (("TurnRegenBodyArmor" in cfg) && cfg.TurnRegenBodyArmor > 0)
			{
				local body = items.getItemAtSlot(::Const.ItemSlot.Body);
				if (body != null && (::Wuxia.hasMember(body, "getArmor")) && (::Wuxia.hasMember(body, "getArmorMax")) && body.getArmor() < body.getArmorMax())
				{
					body.setArmor(::Math.min(body.getArmorMax(), body.getArmor() + cfg.TurnRegenBodyArmor + mwBonus));
				}
			}
			if (("TurnRegenShield" in cfg) && cfg.TurnRegenShield > 0)
			{
				local shd = items.getItemAtSlot(::Const.ItemSlot.Offhand);
				if (shd != null && (::Wuxia.hasMember(shd.m, "Condition")) && (::Wuxia.hasMember(shd.m, "ConditionMax")) && shd.m.Condition > 0 && shd.m.Condition < shd.m.ConditionMax)
				{
					shd.m.Condition = ::Math.min(shd.m.ConditionMax, shd.m.Condition + cfg.TurnRegenShield + mwBonus);
					if (::Wuxia.hasMember(shd, "updateAppearance")) shd.updateAppearance();
				}
			}
		}
	}

	function onUpdate( _properties )
	{
		local cfg = this.getTraitCfg();
		if (cfg == null) return;

		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();

		if ("Stats" in cfg)
		{
			foreach (stat, delta in cfg.Stats)
			{
				_properties[stat] += delta;
			}
		}

		local round = this.wxGetCurrentRound();
		if (("FirstRoundInit" in cfg) && cfg.FirstRoundInit > 0 && round <= 1)
		{
			_properties.Initiative += cfg.FirstRoundInit;
		}

		if ("RangedDmgMult" in cfg)
			_properties.DamageReceivedRangedMult *= cfg.RangedDmgMult;
		if ("ArmorDmgTakenMult" in cfg)
			_properties.DamageReceivedArmorMult *= cfg.ArmorDmgTakenMult;
		if ("ArmorDmgBonus" in cfg)
			_properties.DamageArmorMult += cfg.ArmorDmgBonus;
		if ("InjuryThresholdMult" in cfg)
			_properties.ThresholdToReceiveInjuryMult *= cfg.InjuryThresholdMult;
		if (("PoisonImmune" in cfg) && cfg.PoisonImmune)
			_properties.IsImmuneToPoison = true;
		if (("ImmuneKnockback" in cfg) && cfg.ImmuneKnockback)
			_properties.IsImmuneToKnockBackAndGrab = true;
		if (("NightOwl" in cfg) && cfg.NightOwl)
			_properties.IsAffectedByNight = false;
		if (("AntiFearBonus" in cfg) && cfg.AntiFearBonus > 0 && typeof _properties.MoraleCheckBravery == "array" && _properties.MoraleCheckBravery.len() > 0)
			_properties.MoraleCheckBravery[0] += cfg.AntiFearBonus;

		if (("LowHpThreshold" in cfg) && actor != null && (::Wuxia.hasMember(actor, "getHitpoints")) && (::Wuxia.hasMember(actor, "getHitpointsMax")) && actor.getHitpointsMax() > 0)
		{
			if ((actor.getHitpoints().tofloat() / actor.getHitpointsMax().tofloat()) < cfg.LowHpThreshold)
			{
				if ("LowHpDmgPct" in cfg) _properties.DamageTotalMult *= (1.0 + cfg.LowHpDmgPct);
				if ("LowHpResolve" in cfg) _properties.Bravery += cfg.LowHpResolve;
			}
		}

		if (("CycleZhuyin" in cfg) && cfg.CycleZhuyin)
		{
			if ((round % 2) == 1)
			{
				_properties.MeleeDefense += 5;
				_properties.RangedDefense += 5;
				_properties.FatigueRecoveryRate += 3;
			}
			else
			{
				_properties.DamageTotalMult *= 1.10;
			}
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		local cfg = this.getTraitCfg();
		if (cfg == null || _skill == null || !_skill.isAttack() || !(::Wuxia.hasMember(_skill.m, "IsWeaponSkill")) || !_skill.m.IsWeaponSkill)
			return;

		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();

		local intercepting = this.m.IsIntercepting || (actor != null && ::Wuxia.hasMember(actor, "m") && actor.m != null && ("WX_IsIntercepting" in actor.m) && actor.m.WX_IsIntercepting);
		if (!_skill.isRanged() && ("ZoCBonusHit" in cfg) && cfg.ZoCBonusHit > 0 && intercepting)
		{
			_properties.MeleeSkill += cfg.ZoCBonusHit;
		}

		if (_targetEntity != null)
		{
			if (("VsShakenHit" in cfg) && cfg.VsShakenHit > 0 && (::Wuxia.hasMember(_targetEntity, "getMoraleState")) && _targetEntity.getMoraleState() <= ::Const.MoraleState.Wavering)
			{
				if (_skill.isRanged()) _properties.RangedSkill += cfg.VsShakenHit;
				else _properties.MeleeSkill += cfg.VsShakenHit;
			}
			if (("VsHighResolveHit" in cfg) && cfg.VsHighResolveHit > 0 && (::Wuxia.hasMember(_targetEntity, "getCurrentProperties")) && _targetEntity.getCurrentProperties() != null)
			{
				if (_targetEntity.getCurrentProperties().Bravery >= 60)
					_properties.MeleeSkill += cfg.VsHighResolveHit;
			}
			if (_skill.isRanged() && ("CloseRangeHit" in cfg) && cfg.CloseRangeHit > 0 && actor != null && (::Wuxia.hasMember(actor, "isPlacedOnMap")) && actor.isPlacedOnMap() && (::Wuxia.hasMember(_targetEntity, "isPlacedOnMap")) && _targetEntity.isPlacedOnMap())
			{
				if (actor.getTile().getDistanceTo(_targetEntity.getTile()) <= 3)
					_properties.RangedSkill += cfg.CloseRangeHit;
			}
		}
	}

	function onBeforeDamageReceived( _attacker, _skill, _hitInfo, _properties )
	{
		local cfg = this.getTraitCfg();
		if (cfg == null) return;

		if (("SteelBrow" in cfg) && cfg.SteelBrow && _hitInfo != null && ("BodyPart" in _hitInfo) && _hitInfo.BodyPart == ::Const.BodyPart.Head)
		{
			if (("BodyDamageMult" in _hitInfo) && _hitInfo.BodyDamageMult > 1.0)
				_hitInfo.BodyDamageMult = 1.0;
		}

		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		if (_attacker != null && actor != null && _attacker.getID() != actor.getID() && _attacker.isAlive() && _skill != null && !_skill.isRanged())
		{
			if (("ThornsMeleeArmor" in cfg) && cfg.ThornsMeleeArmor > 0 && (::Wuxia.hasMember(_attacker, "getItems")) && _attacker.getItems() != null)
			{
				local atkBody = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (atkBody != null && (::Wuxia.hasMember(atkBody, "getArmor")) && atkBody.getArmor() > 0)
					atkBody.setArmor(::Math.max(0, atkBody.getArmor() - cfg.ThornsMeleeArmor));
			}
			if (("ThornsMeleeQi" in cfg) && cfg.ThornsMeleeQi > 0 && !::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && (::Wuxia.hasMember(_attacker, "getFatigue")))
			{
				_attacker.setFatigue(::Math.min(_attacker.getFatigueMax(), _attacker.getFatigue() + cfg.ThornsMeleeQi));
			}
		}
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		local cfg = this.getTraitCfg();
		if (cfg == null || _skill == null || !_skill.isAttack()) return;

		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		if (actor == null || _targetEntity == null || !_targetEntity.isAlive() || actor.isAlliedWith(_targetEntity))
			return;

		local tsk = (::Wuxia.hasMember(_targetEntity, "getSkills")) ? _targetEntity.getSkills() : null;
		local mwFlat = this.isMasterworkGear() ? 2 : 0;
		local mwPct  = this.isMasterworkGear() ? 8 : 0;

		if (("OnHitArmorBurn" in cfg) && cfg.OnHitArmorBurn > 0 && (::Wuxia.hasMember(_targetEntity, "getItems")) && _targetEntity.getItems() != null)
		{
			local tBody = _targetEntity.getItems().getItemAtSlot(::Const.ItemSlot.Body);
			if (tBody != null && (::Wuxia.hasMember(tBody, "getArmor")) && tBody.getArmor() > 0)
				tBody.setArmor(::Math.max(0, tBody.getArmor() - (cfg.OnHitArmorBurn + mwFlat)));
		}

		if (("OnHitDrainQi" in cfg) && cfg.OnHitDrainQi > 0 && !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && (::Wuxia.hasMember(_targetEntity, "getFatigue")))
		{
			_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + cfg.OnHitDrainQi + (mwFlat > 0 ? 1 : 0)));
		}

		if (("OnHitSelfQi" in cfg) && cfg.OnHitSelfQi > 0 && this.m.SelfQiThisTurn < 2)
		{
			this.m.SelfQiThisTurn += 1;
			::Wuxia.CombatRules.restoreQi(actor, cfg.OnHitSelfQi);
		}

		if (!_skill.isRanged() && ("ShieldBreakBonus" in cfg) && cfg.ShieldBreakBonus > 0 && (::Wuxia.hasMember(_targetEntity, "isArmedWithShield")) && _targetEntity.isArmedWithShield())
		{
			local sh = _targetEntity.getItems().getItemAtSlot(::Const.ItemSlot.Offhand);
			if (sh != null && ::Wuxia.hasMember(sh, "applyShieldDamage"))
				sh.applyShieldDamage(cfg.ShieldBreakBonus + mwFlat);
		}

		if (tsk != null)
		{
			if (("OnHitPoisonPct" in cfg) && cfg.OnHitPoisonPct > 0 && _damageInflictedHitpoints >= 4 && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
			{
				if (::Math.rand(1, 100) <= (cfg.OnHitPoisonPct + mwPct))
					this.wxApplyStatusSafe(tsk, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
			}
			if (("OnHitBleedPct" in cfg) && cfg.OnHitBleedPct > 0 && _damageInflictedHitpoints >= 6 && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
			{
				if (::Math.rand(1, 100) <= (cfg.OnHitBleedPct + mwPct))
				{
					local bleed = ::new("scripts/skills/effects/bleeding_effect");
					bleed.setDamage(5);
					tsk.add(bleed);
				}
			}
			if (("OnHitOpeningPct" in cfg) && cfg.OnHitOpeningPct > 0 && ::Math.rand(1, 100) <= (cfg.OnHitOpeningPct + mwPct))
			{
				this.wxApplyStatusSafe(tsk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			}
			if (("OnHitOffbalancePct" in cfg) && cfg.OnHitOffbalancePct > 0 && ::Math.rand(1, 100) <= (cfg.OnHitOffbalancePct + mwPct))
			{
				this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			if (("OnHitOffbalanceHeavyPct" in cfg) && cfg.OnHitOffbalanceHeavyPct > 0 && (_damageInflictedHitpoints >= 14 || _damageInflictedArmor >= 25))
			{
				if (::Math.rand(1, 100) <= (cfg.OnHitOffbalanceHeavyPct + mwPct))
					this.wxApplyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			if (("VsControlledDrainHP" in cfg) && cfg.VsControlledDrainHP > 0 && this.m.DrainHpThisTurn < 2 && !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
			{
				local controlled = tsk.hasSkill("effects.wx_status_opening")
					|| tsk.hasSkill("effects.wx_status_offbalance")
					|| tsk.hasSkill("effects.wx_status_acupoint")
					|| tsk.hasSkill("effects.stunned")
					|| tsk.hasSkill("effects.dazed")
					|| tsk.hasSkill("effects.net");
				if (controlled && actor.getHitpoints() < actor.getHitpointsMax())
				{
					this.m.DrainHpThisTurn += 1;
					actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + cfg.VsControlledDrainHP));
				}
			}
		}
	}

	function onTargetKilled( _targetEntity, _skill )
	{
		local cfg = this.getTraitCfg();
		local cont = this.getContainer();
		local actor = cont == null ? null : cont.getActor();
		if (cfg == null || actor == null || !actor.isAlive()) return;

		if (("OnKillQiRegen" in cfg) && cfg.OnKillQiRegen > 0)
		{
			::Wuxia.CombatRules.restoreQi(actor, cfg.OnKillQiRegen);
		}

		local cap = ("KillHealCap" in cfg) ? cfg.KillHealCap : 1;
		if (("OnKillHealHP" in cfg) && cfg.OnKillHealHP > 0 && this.m.KillHealsThisTurn < cap && (_targetEntity == null || !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity)))
		{
			this.m.KillHealsThisTurn += 1;
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + cfg.OnKillHealHP));
		}

		if (("OnKillRefundAmmo" in cfg) && cfg.OnKillRefundAmmo > 0)
		{
			local item = this.getItem();
			if (item != null && ::Wuxia.hasMember(item, "m") && (::Wuxia.hasMember(item.m, "Ammo")) && (::Wuxia.hasMember(item.m, "AmmoMax")) && item.m.Ammo < item.m.AmmoMax)
			{
				item.m.Ammo = ::Math.min(item.m.AmmoMax, item.m.Ammo + cfg.OnKillRefundAmmo);
			}
		}
	}
});
