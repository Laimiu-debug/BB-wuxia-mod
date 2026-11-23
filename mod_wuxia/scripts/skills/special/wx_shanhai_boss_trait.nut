// Composable Tactical Mechanics Engine for All 48 Shan Hai Jing Mythical Apex Bosses

this.wx_shanhai_boss_trait <- this.inherit("scripts/skills/skill", {
	m = {
		BossID     = "zhuyan",
		KillAPUsed = false,
		ReviveUsed = false,
		RoundNum   = 0
	},

	function create()
	{
		this.m.ID = "special.wx_shanhai_boss_trait";
		this.m.Name = "山海凶威";
		this.m.Description = "《山海经》上古异兽与生俱来的凶煞异禀。";
		this.m.Icon = "ui/perks/wx_shanhai_boss_trait.png";
		this.m.Type = this.Const.SkillType.Special | this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.Trait;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsHidden = false;
		this.m.IsSerialized = false;
	}

	function getMechanics()
	{
		local fullKey = "boss_" + this.m.BossID;
		if ("ShanHaiBosses" in ::Wuxia.Config)
		{
			if (fullKey in ::Wuxia.Config.ShanHaiBosses)
				return ::Wuxia.Config.ShanHaiBosses[fullKey].Mechanics;
			if (this.m.BossID in ::Wuxia.Config.ShanHaiBosses)
				return ::Wuxia.Config.ShanHaiBosses[this.m.BossID].Mechanics;
		}
		return {};
	}

	function setBossID( _bossID )
	{
		this.m.BossID = _bossID;
		this.m.Icon = "ui/perks/wx_boss_trait_" + _bossID + ".png";
		this.m.IconDisabled = "ui/perks/wx_boss_trait_" + _bossID + "_sw.png";
		local fullKey = "boss_" + _bossID;
		if ("ShanHaiBosses" in ::Wuxia.Config && (fullKey in ::Wuxia.Config.ShanHaiBosses))
		{
			local cfg = ::Wuxia.Config.ShanHaiBosses[fullKey];
			this.m.Name = cfg.TraitName;
			this.m.Description = cfg.TraitDesc;
		}
	}

	function applyDebuffSafe( _targetSkills, _effectID, _scriptPath )
	{
		if (_targetSkills == null) return;
		local ex = _targetSkills.getSkillByID(_effectID);
		if (ex == null) _targetSkills.add(::new(_scriptPath));
		else if ("resetDuration" in ex) ex.resetDuration();
	}

	function onTurnStart()
	{
		this.m.KillAPUsed = false;
		this.m.RoundNum += 1;
		local container = this.getContainer();
		local actor = container == null ? null : container.getActor();
		if (actor == null || !actor.isAlive()) return;

		local mech = this.getMechanics();

		// 1. Vitality Regeneration
		if ("RegenHP" in mech && mech.RegenHP > 0 && actor.getHitpoints() < actor.getHitpointsMax())
		{
			local heal = mech.RegenHP;
			if ("PoisonCutsRegen" in mech)
			{
				local poisoned = container.hasSkill("effects.wx_status_poison_dart") || container.hasSkill("effects.spider_poison") || container.hasSkill("effects.goblin_poison") || container.hasSkill("effects.bleeding");
				if (poisoned) heal = mech.PoisonCutsRegen;
			}
			actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + heal));
		}

		// 2. Tactical Domain Auras & Odd/Even Cycles
		if (("AuraRadius" in mech) && ("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive() && actor.isPlacedOnMap())
		{
			local rad = mech.AuraRadius;
			local armorDmg = ("AuraArmorDmg" in mech) ? mech.AuraArmorDmg : 0;
			local fatAdd = ("AuraFatigue" in mech) ? mech.AuraFatigue : 0;
			local hpDmg = ("AuraHpDmg" in mech) ? mech.AuraHpDmg : 0;
			local addPoison = ("AuraPoison" in mech) ? mech.AuraPoison : false;
			local resolveCheck = ("AuraResolveOffbalance" in mech) ? mech.AuraResolveOffbalance : false;

			if ("CycleMode" in mech)
			{
				local isOdd = (this.m.RoundNum % 2) == 1;
				if (mech.CycleMode == "zhuyin")
				{
					if (isOdd) { fatAdd = 12; resolveCheck = true; }
				}
				else if (mech.CycleMode == "jiuying")
				{
					if (isOdd) { hpDmg = 8; addPoison = true; }
					else { armorDmg = 16; }
				}
			}

			local myTile = actor.getTile();
			if ("VFX" in ::Wuxia)
			{
				local bossAura = armorDmg > 0 ? "wx_vfx_02" : (addPoison ? "wx_vfx_28" : (hpDmg > 0 ? "wx_vfx_21" : (resolveCheck ? "wx_vfx_30" : "wx_vfx_19")));
				::Wuxia.VFX.playTriggerVfx(myTile, bossAura, null, -25, 80, 1.24);
			}
			local allEntities = ::Tactical.Entities.getAllInstancesAsArray();
			foreach (ent in allEntities)
			{
				if (ent == null || !ent.isAlive() || !ent.isPlacedOnMap() || actor.isAlliedWith(ent)) continue;
				if (myTile.getDistanceTo(ent.getTile()) > rad) continue;

				local entSk = (::Wuxia.hasMember(ent, "getSkills")) ? ent.getSkills() : null;
				local entBuff = entSk != null ? entSk.getSkillByID("effects.wx_pill_battle_buff") : null;
				local hasBihuo = (entBuff != null && (::Wuxia.hasMember(entBuff.m, "HasBihuo")) && entBuff.m.HasBihuo)
					|| (("BeastCraft" in ::Wuxia) && ::Wuxia.BeastCraft.hasAuraWard(ent));

				if (!hasBihuo && armorDmg > 0 && (::Wuxia.hasMember(ent, "getItems")) && ent.getItems() != null)
				{
					local body = ent.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (body != null && body.getArmor() > 0)
						body.setArmor(::Math.max(0, body.getArmor() - armorDmg));
				}
				if (!hasBihuo && fatAdd > 0 && !::Wuxia.CombatRules.isUndeadOrConstruct(ent) && (::Wuxia.hasMember(ent, "getFatigue")))
					ent.setFatigue(::Math.min(ent.getFatigueMax(), ent.getFatigue() + fatAdd));
				if (!hasBihuo && hpDmg > 0 && ent.getHitpoints() > hpDmg + 1)
					ent.setHitpoints(ent.getHitpoints() - hpDmg);
				if (addPoison && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(ent) && (::Wuxia.hasMember(ent, "getSkills")))
					this.applyDebuffSafe(ent.getSkills(), "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
				if (resolveCheck && (::Wuxia.hasMember(ent, "getCurrentProperties")) && (::Wuxia.hasMember(ent, "getSkills")))
				{
					if (::Math.rand(1, 100) > ent.getCurrentProperties().Bravery)
						this.applyDebuffSafe(ent.getSkills(), "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
				}
			}
		}
	}

	function onUpdate( _properties )
	{
		local container = this.getContainer();
		local actor = container == null ? null : container.getActor();
		local mech = this.getMechanics();

		if ("MinAP" in mech && _properties.ActionPoints < mech.MinAP)
			_properties.ActionPoints = mech.MinAP;
		if ("BonusInit" in mech) _properties.Initiative += mech.BonusInit;
		if ("BonusMSkill" in mech) _properties.MeleeSkill += mech.BonusMSkill;
		if ("BonusMDef" in mech) _properties.MeleeDefense += mech.BonusMDef;
		if ("BonusRDef" in mech) _properties.RangedDefense += mech.BonusRDef;
		if ("BonusBravery" in mech) _properties.Bravery += mech.BonusBravery;
		if ("RangedMult" in mech) _properties.DamageReceivedRangedMult *= mech.RangedMult;
		if ("RegularMult" in mech) _properties.DamageReceivedRegularMult *= mech.RegularMult;
		if ("ImmuneStun" in mech && mech.ImmuneStun) _properties.IsImmuneToStun = true;
		if ("ImmuneDisarm" in mech && mech.ImmuneDisarm) _properties.IsImmuneToDisarm = true;

		if ("CycleMode" in mech && mech.CycleMode == "zhuyin" && (this.m.RoundNum % 2) == 0 && this.m.RoundNum > 0)
		{
			_properties.MeleeSkill += 18;
			_properties.DamageTotalMult *= 1.25;
		}

		if ("EnrageBelowPct" in mech && actor != null && actor.getHitpointsMax() > 0)
		{
			local ratio = actor.getHitpoints().tofloat() / actor.getHitpointsMax().tofloat();
			if (ratio < mech.EnrageBelowPct)
			{
				if ("EnrageMSkill" in mech) _properties.MeleeSkill += mech.EnrageMSkill;
				if ("EnrageDmgMult" in mech) _properties.DamageTotalMult *= mech.EnrageDmgMult;
				if ("EnrageImmuneCC" in mech && mech.EnrageImmuneCC)
				{
					_properties.IsImmuneToStun = true;
					_properties.IsImmuneToDisarm = true;
				}
			}
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == null || !_skill.isAttack() || _targetEntity == null || !(::Wuxia.hasMember(_targetEntity, "getCurrentProperties"))) return;
		local mech = this.getMechanics();
		local tBravery = _targetEntity.getCurrentProperties().Bravery;

		if ("VsHighResolve" in mech && mech.VsHighResolve && tBravery >= 65)
		{
			_properties.MeleeSkill += 12;
			_properties.DamageTotalMult *= 1.15;
		}
		if ("VsShaken" in mech && mech.VsShaken && tBravery < 55)
		{
			_properties.MeleeSkill += 15;
			_properties.DamageTotalMult *= 1.25;
		}
	}

	function onBeforeDamageReceived( _attacker, _skill, _hitInfo, _properties )
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null) return;
		local mech = this.getMechanics();

		local mainW = (_attacker != null && ::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
			? _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand) : null;

		if ("HammerWeakOnly" in mech && mech.HammerWeakOnly)
		{
			if (_skill != null && (_skill.isRanged() || !::Wuxia.CombatRules.matchesWeapon(mainW, ["Hammer"])))
				_properties.DamageReceivedTotalMult *= 0.55;
		}

		if (_attacker != null && _attacker.getID() != actor.getID() && _attacker.isAlive() && _skill != null && !_skill.isRanged())
		{
			if ("ThornsNonAxe" in mech && mech.ThornsNonAxe && !::Wuxia.CombatRules.matchesWeapon(mainW, ["Axe"]))
			{
				if (::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
				{
					local body = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (body != null && body.getArmor() > 0) body.setArmor(::Math.max(0, body.getArmor() - 10));
				}
				if (_attacker.getHitpoints() > 6) _attacker.setHitpoints(_attacker.getHitpoints() - 5);
			}
			local atkSk = (::Wuxia.hasMember(_attacker, "getSkills")) ? _attacker.getSkills() : null;
			local atkBuff = atkSk != null ? atkSk.getSkillByID("effects.wx_pill_battle_buff") : null;
			local atkHasBihuo = (atkBuff != null && (::Wuxia.hasMember(atkBuff.m, "HasBihuo")) && atkBuff.m.HasBihuo);
			if (!atkHasBihuo && "ThornsMeleeFire" in mech && mech.ThornsMeleeFire)
			{
				if (::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
				{
					local body2 = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (body2 != null && body2.getArmor() > 0) body2.setArmor(::Math.max(0, body2.getArmor() - 12));
				}
				if (_attacker.getHitpoints() > 7) _attacker.setHitpoints(_attacker.getHitpoints() - 6);
			}
			if ("ThornsMeleeQi" in mech && mech.ThornsMeleeQi > 0 && !::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && (::Wuxia.hasMember(_attacker, "getFatigue")))
			{
				_attacker.setFatigue(::Math.min(_attacker.getFatigueMax(), _attacker.getFatigue() + mech.ThornsMeleeQi));
			}
			if ("ThornsAoE" in mech && mech.ThornsAoE > 0 && _attacker.getHitpoints() > mech.ThornsAoE + 1)
			{
				_attacker.setHitpoints(_attacker.getHitpoints() - mech.ThornsAoE);
			}
		}
	}

	function onDamageReceived( _attacker, _damageHitpoints, _damageArmor )
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null) return;
		local mech = this.getMechanics();
		if ("ReviveOnceHP" in mech && !this.m.ReviveUsed && actor.getHitpoints() <= 15 && actor.getHitpoints() > 0)
		{
			this.m.ReviveUsed = true;
			actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + mech.ReviveOnceHP));
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(actor, "wx_vfx_20", "wx_fx_blood_orb", -25, 110, 1.28);
		}
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null || _targetEntity == null || !_targetEntity.isAlive() || actor.isAlliedWith(_targetEntity)) return;

		local mech = this.getMechanics();
		local tsk = _targetEntity.getSkills();
		if (tsk == null) return;
		local immuneBio = ::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity);
		local tBuff = tsk.getSkillByID("effects.wx_pill_battle_buff");
		local tHasYuji  = (tBuff != null && (::Wuxia.hasMember(tBuff.m, "HasYuji")) && tBuff.m.HasYuji);
		local tHasBihuo = (tBuff != null && (::Wuxia.hasMember(tBuff.m, "HasBihuo")) && tBuff.m.HasBihuo);

		if ("OnHitBleed" in mech && _damageInflictedHitpoints >= 5 && !immuneBio && !tHasYuji)
		{
			local bleed = ::new("scripts/skills/effects/bleeding_effect");
			bleed.setDamage(mech.OnHitBleed);
			tsk.add(bleed);
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_13", "wx_fx_claw_slash", 0, 0, 1.12);
		}
		if ("OnHitDrainHP" in mech && _damageInflictedHitpoints > 0)
		{
			local drainHP = ::Math.min(mech.OnHitDrainHP, _damageInflictedHitpoints);
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + drainHP));
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_06", "wx_fx_blood_orb", 0, 140, 1.12);
		}
		if ("OnHitDrainQi" in mech && !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && (::Wuxia.hasMember(_targetEntity, "getFatigue")))
		{
			_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + mech.OnHitDrainQi));
		}
		if (!tHasBihuo && "OnHitArmorBurn" in mech && (::Wuxia.hasMember(_targetEntity, "getItems")) && _targetEntity.getItems() != null)
		{
			local body = _targetEntity.getItems().getItemAtSlot(::Const.ItemSlot.Body);
			if (body != null && body.getArmor() > 0)
			{
				body.setArmor(::Math.max(0, body.getArmor() - mech.OnHitArmorBurn));
				if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_05", "wx_fx_earth_fissure", 0, 0, 1.14);
			}
		}
		if ("OnHitPoison" in mech && mech.OnHitPoison && !immuneBio)
		{
			this.applyDebuffSafe(tsk, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_28", "wx_fx_poison_skull", -20, 0, 1.06);
		}
		if ("OnHitInternalInjury" in mech && mech.OnHitInternalInjury && !immuneBio)
		{
			this.applyDebuffSafe(tsk, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury");
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_11", "wx_fx_blood_orb", 0, 0, 1.08);
		}
		if ("OnHitAcupoint" in mech && mech.OnHitAcupoint && !immuneBio)
		{
			this.applyDebuffSafe(tsk, "effects.wx_status_acupoint", "scripts/skills/effects/wx_status_acupoint");
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_16", "wx_fx_lotus_seal", 0, 100, 1.06);
		}
		if ("OnHitScatter" in mech && mech.OnHitScatter && !immuneBio)
		{
			this.applyDebuffSafe(tsk, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_19", "wx_fx_bagua", 0, -90, 1.08);
		}
		if ("OnHitOffbalance" in mech && mech.OnHitOffbalance)
		{
			this.applyDebuffSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_14", "wx_fx_sonic_ring", 0, 0, 1.06);
		}
		if ("OnHitOpening" in mech && mech.OnHitOpening)
		{
			this.applyDebuffSafe(tsk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_07", "wx_fx_sword_phantom", 0, 0, 1.06);
		}
	}

	function onTargetKilled( _targetEntity, _skill )
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null || !actor.isAlive()) return;
		local mech = this.getMechanics();

		if ("KillHealHP" in mech && mech.KillHealHP > 0 && actor.getHitpoints() < actor.getHitpointsMax())
			actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + mech.KillHealHP));

		if ("KillSmoke" in mech && mech.KillSmoke && actor.getSkills() != null)
			this.applyDebuffSafe(actor.getSkills(), "effects.wx_status_smoke_screen", "scripts/skills/effects/wx_status_smoke_screen");

		if ("KillRefundAP" in mech && !this.m.KillAPUsed)
		{
			this.m.KillAPUsed = true;
			actor.setActionPoints(::Math.min(actor.getActionPointsMax(), actor.getActionPoints() + mech.KillRefundAP));
		}
	}
});
