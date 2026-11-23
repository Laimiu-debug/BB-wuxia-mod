// Core per-actor Martial Container: owns 7 slots, mastery exp, wash chances, stat hooks & save serialization

this.wx_martial_container <- this.inherit("scripts/skills/skill", {
	m = {
		SchemaVersion      = 4,
		Slots              = [],
		LearnedManuals     = {},
		PendingWashChances = 0,
		UsedUniqueEffects  = {},
		MarrowWashCount    = 0,
		FaceIdx            = 0,  // 0 = auto-seed; 1..48 = wx_head_01..48
		HairIdx            = -1, // -1 = auto-seed; 0 = shaved bald; 1..24 = wx_hair_01..24
		HairToneIdx        = -1, // -1 = auto-seed; 0..3 = black/brown/grey/white
		BeardIdx           = -1, // -1 = auto-seed; 0 = clean-shaven; 1..24 = wx_beard_01..24
		ScarIdx            = -1, // -1 = auto-seed; 0 = unscarred; 1..12 = wx_scar_01..12
		BackIdx            = -1, // -1 = auto-seed; 0 = none; 1..16 = wx_back_01..16
		GrantedSkills      = {},
		TemporaryAPOverflow = 0,
		HitsRegenThisTurn  = 0,
		DodgeRegenThisTurn = 0,
		KillHealsThisTurn  = 0,
		KillAPUsedThisTurn = false,
		IsIntercepting     = false,
		SupportShotUsed     = false,
		FastAdaptStacks     = 0,
		CachedAggFlags      = null,
		WX_ElevationApplied = false
	},

	function create()
	{
		this.m.ID = "special.wx_martial_container";
		this.m.Name = "武学修为";
		this.m.Description = "记录侠客所修习的七大武学插槽、重数火候与洗髓机缘。";
		this.m.Icon = "ui/perks/wx_martial_container.png";
		this.m.Type = this.Const.SkillType.Special;
		this.m.Order = this.Const.SkillOrder.First;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsHidden = true;
		this.m.IsSerialized = true;
		this.m.LearnedManuals = {};

		this.initEmptySlots();
	}

	function hasLearnedManual( _manualID )
	{
		return _manualID != null && (_manualID in this.m.LearnedManuals);
	}

	function getLearnedEntry( _manualID )
	{
		if (_manualID != null && (_manualID in this.m.LearnedManuals))
			return this.m.LearnedManuals[_manualID];
		return null;
	}

	function syncSlotToLearned( _slotIndex )
	{
		if (_slotIndex < 0 || _slotIndex >= this.m.Slots.len()) return;
		local s = this.m.Slots[_slotIndex];
		if (s.ManualID == null || s.Tier <= 0) return;
		this.m.LearnedManuals[s.ManualID] <- {
			Tier       = s.Tier,
			Exp        = s.Exp,
			IsFragment = s.IsFragment
		};
	}

	function ensureSlotsRegisteredInLearned()
	{
		for (local i = 0; i < this.m.Slots.len(); i = ++i)
		{
			local s = this.m.Slots[i];
			if (s.ManualID == null || s.Tier <= 0) continue;
			if (!(s.ManualID in this.m.LearnedManuals))
			{
				this.syncSlotToLearned(i);
			}
			else
			{
				local prev = this.m.LearnedManuals[s.ManualID];
				if (s.Tier > prev.Tier || (s.Tier == prev.Tier && s.Exp > prev.Exp))
				{
					prev.Tier = s.Tier;
					prev.Exp  = s.Exp;
				}
				if (!s.IsFragment) prev.IsFragment = false;
			}
		}
	}

	function initEmptySlots()
	{
		this.m.Slots = [];
		foreach (cfg in ::Wuxia.Config.SlotLayout)
		{
			this.m.Slots.push({
				SlotIndex   = cfg.Index,
				SlotType    = cfg.SlotType,
				UnlockLevel = cfg.UnlockLevel,
				ManualID    = null,
				Tier        = 0,
				Exp         = 0,
				IsFragment  = false
			});
		}
	}

	function getPermanentAPBonus()
	{
		return this.m.CachedAggFlags == null ? 0 : this.m.CachedAggFlags.PermanentAPBonus;
	}

	function syncGrantedSkills()
	{
		local container = this.getContainer();
		if (container == null) return;

		// Remove previously granted skills no longer backed by equipped manuals
		local desired = {};
		local agg = ::Wuxia.CombatRules.getAggregateFlags(this);

		foreach (s in this.m.Slots)
		{
			if (s.ManualID == null || s.Tier <= 0) continue;
			local def = ::Wuxia.Slots.getPracticedDef(this, s);
			if (def == null) continue;
			local tierIdx = ::Math.min(s.Tier, def.Levels.len()) - 1;
			if (def.Category == "neigong") desired["actives.recover"] <- true;
			foreach (skillID in def.Levels[tierIdx].GrantSkills)
			{
				desired[skillID] <- true;
			}
		}

		// Reuse vanilla engine-native perks cleanly for Quick Hands & Pathfinder
		if (agg.QuickHands)        desired["perk.quick_hands"] <- true;
		if (agg.TerrainCostHalved) desired["perk.pathfinder"]  <- true;

		foreach (id, skill in this.m.GrantedSkills)
		{
			if (!(id in desired)) container.remove(skill);
		}

		local nextGranted = {};
		foreach (skillID, _ in desired)
		{
			local existing = container.getSkillByID(skillID);
			if (existing == null)
			{
				local scriptPath = this.resolveSkillScriptPath(skillID);
				if (scriptPath != null)
				{
					local sk = ::new(scriptPath);
					sk.m.IsSerialized = false; // Managed dynamically by wx_martial_container
					container.add(sk);
					nextGranted[skillID] <- sk;
				}
			}
			else if (skillID in this.m.GrantedSkills && this.m.GrantedSkills[skillID] == existing)
				nextGranted[skillID] <- existing;
		}
		this.m.GrantedSkills = nextGranted;
	}

	function resolveSkillScriptPath( _skillID )
	{
		if (_skillID.find("actives.wx_") == 0) return "scripts/skills/actives/" + _skillID.slice(8);
		if (_skillID == "actives.footwork")         return "scripts/skills/actives/footwork";
		if (_skillID == "actives.rotation")         return "scripts/skills/actives/rotation";
		if (_skillID == "actives.recover")          return "scripts/skills/actives/recover_skill";
		if (_skillID == "actives.indomitable")      return "scripts/skills/actives/indomitable";
		if (_skillID == "perk.brawny")              return "scripts/skills/perks/perk_brawny";
		if (_skillID == "perk.steel_brow")          return "scripts/skills/perks/perk_steel_brow";
		if (_skillID == "perk.fearsome")            return "scripts/skills/perks/perk_fearsome";
		if (_skillID == "perk.quick_hands")         return "scripts/skills/perks/perk_quick_hands";
		if (_skillID == "perk.nine_lives")          return "scripts/skills/perks/wx_manual_nine_lives";
		if (_skillID == "perk.pathfinder")          return "scripts/skills/perks/wx_manual_pathfinder";
		return null;
	}

	function grantTemporaryAP( _amount )
	{
		local actor = this.getContainer().getActor();
		local next = ::Math.min(::Wuxia.Config.Constants.MaxTemporaryAP, actor.getActionPoints() + _amount);
		this.m.TemporaryAPOverflow = 0;
		local permanentMax = actor.getActionPointsMax();
		this.m.TemporaryAPOverflow = ::Math.max(0, next - permanentMax);
		actor.setActionPoints(next);
	}

	function onNewRound()
	{
		// onRoundStart refills AP immediately after this callback.
		this.m.TemporaryAPOverflow = 0;
	}

	function onTurnEnd()
	{
		this.m.TemporaryAPOverflow = 0;
	}

	function wxIsFirstCombatRound()
	{
		return ("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive()
			&& ("TurnSequenceBar" in ::Tactical) && ::Tactical.TurnSequenceBar != null
			&& ::Tactical.TurnSequenceBar.getCurrentRound() <= 1;
	}

	function onTurnStart()
	{
		this.m.HitsRegenThisTurn = 0;
		this.m.DodgeRegenThisTurn = 0;
		this.m.KillHealsThisTurn = 0;
		this.m.KillAPUsedThisTurn = false;
		this.m.SupportShotUsed = false;

		// Conflict / Fragment mishap roll in combat
		local actor = this.getContainer().getActor();
		if (actor == null || !actor.isAlive()) return;

		local agg = ::Wuxia.CombatRules.getAggregateFlags(this);
		if (agg.TurnStartCleansePct > 0 && ::Math.rand(1, 100) <= agg.TurnStartCleansePct)
		{
			local sk = this.getContainer();
			foreach (cid in ["effects.bleeding", "effects.wx_status_poison_dart", "effects.spider_poison", "effects.goblin_poison"])
			{
				if (sk.hasSkill(cid)) { sk.removeByID(cid); break; }
			}
			if (actor.getHitpoints() < actor.getHitpointsMax())
			{
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + 3));
			}
		}
		local pBuffTurn = this.getContainer().getSkillByID("effects.wx_pill_battle_buff");
		local zhenmoCalm = (pBuffTurn != null && ("HasZhenmo" in pBuffTurn.m) && pBuffTurn.m.HasZhenmo);

		if (!zhenmoCalm && ::Wuxia.Slots.hasNeigongConflict(actor))
		{
			local resolve = actor.getCurrentProperties().Bravery;
			local risk = ::Math.max(5, 25 - ::Math.floor(resolve / 4));
			if (agg.AntiInternalInjury) risk = risk / 2;
			if (::Math.rand(1, 100) <= risk)
			{
				::Wuxia.CombatRules.spendQi(actor, 10);
				this.Tactical.EventLog.log(::Const.UI.getColorizedEntityName(actor) + " 体内阴阳/正邪内息逆冲，损耗 10 点内息！");
			}
		}
		else if (!zhenmoCalm && agg.HasFragmentManual && ::Math.rand(1, 100) <= (agg.AntiInternalInjury ? 5 : 10))
		{
			::Wuxia.CombatRules.spendQi(actor, 6);
			this.Tactical.EventLog.log(::Const.UI.getColorizedEntityName(actor) + " 强运残本功法行气不畅，散逸 6 点内息。");
		}
	}

	function onUpdate( _properties )
	{
		local container = this.getContainer();
		local actor = container == null ? null : container.getActor();
		local agg = ::Wuxia.CombatRules.getAggregateFlags(this);
		this.m.CachedAggFlags = agg;

		foreach (stat, delta in agg.Stats) _properties[stat] += delta;
		_properties.MovementAPCostAdditional -= agg.MoveAPDiscount;
		if ((agg.StaffGuard || agg.UnderdogGuard) && (container == null || !container.hasSkill("perk.underdog")))
			_properties.SurroundedDefense += 5;
		if (agg.DodgeRangedBonus > 0)
			_properties.RangedDefense += agg.DodgeRangedBonus;
		if (agg.NightOwl && ("IsAffectedByNight" in _properties))
			_properties.IsAffectedByNight = false;
		if (agg.FirstRoundInit > 0 && this.wxIsFirstCombatRound())
			_properties.Initiative += agg.FirstRoundInit;
		if (agg.PolearmMastery && ("IsSpecializedInPolearms" in _properties))
			_properties.IsSpecializedInPolearms = true;
		if (actor != null && (::Wuxia.hasMember(actor, "isArmedWithShield")) && actor.isArmedWithShield())
		{
			if (agg.ShieldDefBonus > 0)
			{
				_properties.MeleeDefense += agg.ShieldDefBonus;
				_properties.RangedDefense += agg.ShieldDefBonus;
			}
			if (agg.ShieldWallExpert && ("IsProficientWithShieldSkills" in _properties))
			{
				_properties.IsProficientWithShieldSkills = true;
			}
		}

		// Light Armor Mitigation (Nimble-style)
		if (agg.LightArmorMitigation > 0.0 && actor != null)
		{
			_properties.DamageReceivedRegularMult *= ::Wuxia.CombatRules.getLightArmorDamageMult(actor, agg.LightArmorMitigation);
		}

		// Injury threshold bonus
		if (agg.InjuryThresholdMult > 1.0)
		{
			_properties.ThresholdToReceiveInjuryMult *= agg.InjuryThresholdMult;
		}

		// Elevation AP discount (when Pathfinder is not active; restore original cost cleanly on unequip!)
		if (actor != null && ::Wuxia.hasMember(actor, "m") && actor.m != null && ::Wuxia.hasMember(actor.m, "LevelActionPointCost"))
		{
			if (!::Wuxia.hasMember(actor.m, "WX_OrigLevelAPCost"))
				actor.m.WX_OrigLevelAPCost <- actor.m.LevelActionPointCost;
			if (!agg.TerrainCostHalved && agg.ElevationDiscount)
			{
				actor.m.LevelActionPointCost = 0;
				this.m.WX_ElevationApplied = true;
			}
			else if (this.m.WX_ElevationApplied && !agg.TerrainCostHalved && (container == null || !container.hasSkill("perk.pathfinder")))
			{
				actor.m.LevelActionPointCost = actor.m.WX_OrigLevelAPCost;
				this.m.WX_ElevationApplied = false;
			}
			else if (agg.TerrainCostHalved)
			{
				this.m.WX_ElevationApplied = false;
			}
		}

		// Direct / Armor damage bonuses (EmptyOffhandPen + DirectDmgBonus hard-capped at +25% per AGENTS.md)
		if (agg.ArmorDmgBonus > 0.0) _properties.DamageArmorMult += agg.ArmorDmgBonus;
		local directAdd = agg.DirectDmgBonus;
		if (agg.EmptyOffhandPen > 0.0 && ::Wuxia.CombatRules.hasSingleHandEmptyOffhand(actor))
		{
			directAdd = ::Math.minf(0.25, directAdd + agg.EmptyOffhandPen);
		}
		if (directAdd > 0.0) _properties.DamageDirectAdd += directAdd;
		if (agg.SurroundHitBonus > 0 && ("SurroundedBonus" in _properties))
		{
			_properties.SurroundedBonus += agg.SurroundHitBonus;
		}
		if (agg.PoisonImmune)
		{
			_properties.IsImmuneToPoison = true;
			if (container != null && container.hasSkill("effects.wx_status_poison_dart"))
				container.removeByID("effects.wx_status_poison_dart");
		}
		if (agg.AntiFearAura && ("MoraleCheckBravery" in _properties) && typeof _properties.MoraleCheckBravery == "array" && _properties.MoraleCheckBravery.len() > 0)
		{
			_properties.MoraleCheckBravery[0] += 15;
		}
	}

	function onAfterUpdate( _properties )
	{
		local actor = this.getContainer().getActor();
		if (actor == null || this.m.CachedAggFlags == null) return;
		local agg = this.m.CachedAggFlags;

		// Qinggong Initiative-to-Defense conversion (post-fatigue effective Initiative)
		if (agg.InitToDefRatio > 0.0)
		{
			local effInit = ::Math.max(0, actor.getInitiative());
			local defBonus = ::Math.floor(effInit * agg.InitToDefRatio);
			_properties.MeleeDefense += defBonus;
			_properties.RangedDefense += defBonus;
		}

		// Command Aura, Lone Wolf & Formation Bond positional checks
		if ("Tactical" in getroottable() && ::Tactical != null && ::Tactical.isActive() && actor.isPlacedOnMap())
		{
			local myTile = actor.getTile();
			local bestResolveBonus = 0;
			local adjAllies = 0;
			local within2Allies = 0;
			local hasBanner = this.getContainer().hasSkill("effects.player_banner");
			local allies = ::Tactical.Entities.getInstancesOfFaction(actor.getFaction());
			foreach (ally in allies)
			{
				if (ally == null || ally.getID() == actor.getID() || !ally.isAlive() || !ally.isPlacedOnMap()) continue;
				local dist = myTile.getDistanceTo(ally.getTile());
				if (dist <= 2) within2Allies += 1;
				if (ally.getMoraleState() == ::Const.MoraleState.Fleeing) continue;
				if (dist == 1) adjAllies += 1;
				if (!hasBanner && dist <= 4)
				{
					local ac = ally.getSkills().getSkillByID("special.wx_martial_container");
					if (ac != null && ac.m.CachedAggFlags != null && ac.m.CachedAggFlags.CommandAuraPct > 0.0)
					{
						local cmdBravery = ally.getBaseProperties().Bravery + (("Bravery" in ac.m.CachedAggFlags.Stats) ? ac.m.CachedAggFlags.Stats.Bravery : 0);
						local bonus = ::Math.floor(cmdBravery * ac.m.CachedAggFlags.CommandAuraPct);
						if (bonus > bestResolveBonus) bestResolveBonus = bonus;
					}
				}
			}
			if (bestResolveBonus > 0) _properties.Bravery += bestResolveBonus;
			if (agg.LoneWolfBonus > 0 && within2Allies == 0)
			{
				_properties.MeleeSkill += agg.LoneWolfBonus;
				_properties.RangedSkill += agg.LoneWolfBonus;
				_properties.MeleeDefense += agg.LoneWolfBonus;
				_properties.RangedDefense += agg.LoneWolfBonus;
			}
			if (agg.FormationBondDef > 0 && adjAllies >= 2)
			{
				_properties.MeleeDefense += agg.FormationBondDef;
				_properties.RangedDefense += agg.FormationBondDef;
				_properties.Bravery += agg.FormationBondDef;
			}
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		local f = this.m.CachedAggFlags;
		if (f == null || _skill == null || !_skill.isAttack() || !_skill.m.IsWeaponSkill) return;
		local adaptHit = (f.FastAdaptBonus > 0 && this.m.FastAdaptStacks > 0) ? (this.m.FastAdaptStacks * f.FastAdaptBonus) : 0;
		local firstRoundHit = (f.FirstRoundHit > 0 && this.wxIsFirstCombatRound()) ? f.FirstRoundHit : 0;
		if (_targetEntity != null)
		{
			if (f.VsUndeadDmg > 0.0 && ::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
				_properties.DamageTotalMult *= (1.0 + f.VsUndeadDmg);
			if (f.ExecuteLowHpDmg > 0.0 && (::Wuxia.hasMember(_targetEntity, "getHitpoints")) && (::Wuxia.hasMember(_targetEntity, "getHitpointsMax")) && _targetEntity.getHitpointsMax() > 0)
			{
				if ((_targetEntity.getHitpoints().tofloat() / _targetEntity.getHitpointsMax().tofloat()) < 0.50)
					_properties.DamageTotalMult *= (1.0 + f.ExecuteLowHpDmg);
			}
			if (f.UnbrokenArmorBonus > 0.0 && (::Wuxia.hasMember(_targetEntity, "getArmor")) && (::Wuxia.hasMember(_targetEntity, "getArmorMax")))
			{
				local curA = _targetEntity.getArmor(::Const.BodyPart.Body) + _targetEntity.getArmor(::Const.BodyPart.Head);
				local maxA = _targetEntity.getArmorMax(::Const.BodyPart.Body) + _targetEntity.getArmorMax(::Const.BodyPart.Head);
				if (maxA >= 80 && curA * 2 >= maxA)
					_properties.DamageArmorMult *= (1.0 + f.UnbrokenArmorBonus);
			}
			if (f.UnarmoredBonusDmg > 0.0 && (::Wuxia.hasMember(_targetEntity, "getArmor")) && _targetEntity.getArmor(::Const.BodyPart.Body) <= 0)
			{
				_properties.DamageRegularMult *= (1.0 + f.UnarmoredBonusDmg);
			}
			if (f.VsPoisonedHit > 0 && ::Wuxia.hasMember(_targetEntity, "getSkills") && _targetEntity.getSkills() != null)
			{
				local tsk = _targetEntity.getSkills();
				if (tsk.hasSkill("effects.wx_status_poison_dart") || tsk.hasSkill("effects.spider_poison") || tsk.hasSkill("effects.goblin_poison"))
					adaptHit += f.VsPoisonedHit;
			}
		}
		if (!_skill.isRanged())
		{
			_properties.MeleeSkill += f.HitChanceBonus + adaptHit + firstRoundHit + (this.m.IsIntercepting ? f.ZoCBonusHit : 0);
			_properties.HitChance[::Const.BodyPart.Head] += f.CritHeadBonus;
			return;
		}
		if (adaptHit + firstRoundHit > 0) _properties.RangedSkill += adaptHit + firstRoundHit;
		if (f.RangedHeadshotBonus > 0) _properties.HitChance[::Const.BodyPart.Head] += f.RangedHeadshotBonus;
		local myActor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (myActor != null && _targetEntity != null && (::Wuxia.hasMember(myActor, "isPlacedOnMap")) && myActor.isPlacedOnMap() && (::Wuxia.hasMember(_targetEntity, "isPlacedOnMap")) && _targetEntity.isPlacedOnMap())
		{
			local rDist = myActor.getTile().getDistanceTo(_targetEntity.getTile());
			if (f.LongRangeAccBonus > 0 && rDist >= 4)  _properties.RangedSkill += f.LongRangeAccBonus;
			if (f.CloseRangeShotBonus > 0 && rDist <= 3) _properties.RangedSkill += f.CloseRangeShotBonus;
		}
		if (f.ThrowingDmgBonus > 0) _properties.DamageTotalMult *= 1.0 + f.ThrowingDmgBonus;
		if (f.IgnoreDodgeHalf && _targetEntity != null && _targetEntity.isPlacedOnMap() && _targetEntity.getTile().IsOccupiedByActor)
		{
			local skills = _targetEntity.getSkills();
			local init = ::Math.max(0, _targetEntity.getInitiative());
			local dodge = skills.hasSkill("effects.dodge") ? ::Math.floor(init * 0.15) : 0;
			local target = skills.getSkillByID("special.wx_martial_container");
			if (target != null && target.m.CachedAggFlags != null)
				dodge += ::Math.floor(init * target.m.CachedAggFlags.InitToDefRatio);
			_properties.RangedSkill += ::Math.floor(dodge * 0.5);
		}
	}

	function onBeforeDamageReceived( _attacker, _skill, _hitInfo, _properties )
	{
		local actor = this.getContainer().getActor();
		if (actor == null || this.m.CachedAggFlags == null) return;
		local agg = this.m.CachedAggFlags;

		// Iron Shirt / Golden Bell heavy armor mitigation & melee armor reflection
		if (agg.HeavyArmorScale > 0.0)
		{
			local totalArmor = actor.getArmor(::Const.BodyPart.Body) + actor.getArmor(::Const.BodyPart.Head);
			local mult = 1.0 - (totalArmor * agg.HeavyArmorScale * 0.01);
			if (mult < 0.50) mult = 0.50;
			_properties.DamageReceivedArmorMult *= mult;
		}
		if (agg.ReflectArmorDmg > 0 && _attacker != null && _attacker.getID() != actor.getID() && _attacker.isAlive() && _skill != null && !_skill.isRanged() && ::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
		{
			local atkBody = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
			if (atkBody != null && atkBody.getArmor() > 0)
			{
				atkBody.setArmor(::Math.max(0, atkBody.getArmor() - agg.ReflectArmorDmg));
				if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(actor, "wx_vfx_17", "wx_fx_golden_bell", 0, 0, 1.06);
			}
		}
		if (agg.FrostChillOnHit && _attacker != null && _attacker.getID() != actor.getID() && _attacker.isAlive() && _skill != null && !_skill.isRanged() && ::Wuxia.hasMember(_attacker, "getSkills") && _attacker.getSkills() != null)
		{
			local ask = _attacker.getSkills();
			local ob = ask.getSkillByID("effects.wx_status_offbalance");
			if (ob == null) ask.add(::new("scripts/skills/effects/wx_status_offbalance"));
			else ob.resetDuration();
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_attacker, "wx_vfx_21", "wx_fx_ice_spikes", 0, 0, 1.06);
		}

		// True Qi Shield (阴柔内功护体: 1 Qi mitigates 2 HP damage, capped by QiShieldPct)
		if (agg.QiShieldPct > 0.0 && _hitInfo.DamageRegular > 0)
		{
			local light = agg.LightArmorMitigation > 0 ? ::Wuxia.CombatRules.getLightArmorDamageMult(actor, agg.LightArmorMitigation) : 1.0;
			if (light < 1.0)
				_properties.DamageReceivedRegularMult = ::Math.maxf(0.40, _properties.DamageReceivedRegularMult);
			local availQi = ::Math.max(0, actor.getFatigueMax() - actor.getFatigue());
			if (availQi > 0)
			{
				local shieldPct = agg.QiShieldPct;
				if (light < 1.0)
				{
					local current = ::Math.minf(_properties.DamageReceivedRegularMult, light);
					shieldPct = current <= 0.40 ? 0.0 : ::Math.minf(shieldPct, 1.0 - 0.40 / current);
				}
				local maxMitigate = ::Math.floor(_hitInfo.DamageRegular * shieldPct);
				local qiNeeded = ::Math.ceil(maxMitigate / 2.0);
				local qiSpent = ::Math.min(availQi, qiNeeded);
				if (qiSpent > 0)
				{
					local actualMitigated = ::Math.min(maxMitigate, qiSpent * 2);
					local ratio = 1.0 - (actualMitigated.tofloat() / _hitInfo.DamageRegular.tofloat());
					if (ratio < 0.50) ratio = 0.50;
					_properties.DamageReceivedRegularMult *= ratio;
					::Wuxia.CombatRules.spendQi(actor, qiSpent);
					if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(actor, "wx_vfx_18", "wx_fx_bagua", -18, 90, 1.02);
				}
			}
		}
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		if (this.m.CachedAggFlags == null || _skill == null) return;
		if (_skill.isAttack()) this.m.FastAdaptStacks = 0;
		local agg = this.m.CachedAggFlags;
		local actor = this.getContainer().getActor();
		local validEnemy = (_targetEntity != null && _targetEntity.isAlive() && actor != null && !actor.isAlliedWith(_targetEntity));

		if (validEnemy && _skill.isAttack())
		{
			local tsk0 = _targetEntity.getSkills();
			if (agg.WuduPoisonPct > 0 && _damageInflictedHitpoints >= 4 && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
			{
				if (::Math.rand(1, 100) <= agg.WuduPoisonPct)
				{
					local p = tsk0.getSkillByID("effects.wx_status_poison_dart");
					if (p == null) tsk0.add(::new("scripts/skills/effects/wx_status_poison_dart"));
					else if ("resetDuration" in p) p.resetDuration();
					if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_28", "wx_fx_poison_skull", -24, 0, 1.02);
				}
			}
			if (agg.BleedOnHitPct > 0 && _damageInflictedHitpoints >= 6 && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity) && ::Math.rand(1, 100) <= agg.BleedOnHitPct)
			{
				local bleed = ::new("scripts/skills/effects/bleeding_effect");
				bleed.setDamage(5);
				tsk0.add(bleed);
			}
			if (agg.ExposeOnHitPct > 0 && ::Math.rand(1, 100) <= agg.ExposeOnHitPct)
			{
				local open0 = tsk0.getSkillByID("effects.wx_status_opening");
				if (open0 == null) tsk0.add(::new("scripts/skills/effects/wx_status_opening"));
				else open0.resetDuration();
			}
			if (agg.AcupointOnCritPct > 0 && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
			{
				if ((_bodyPart == ::Const.BodyPart.Head || tsk0.hasSkill("effects.wx_status_opening")) && ::Math.rand(1, 100) <= agg.AcupointOnCritPct)
				{
					local acu = tsk0.getSkillByID("effects.wx_status_acupoint");
					if (acu == null) tsk0.add(::new("scripts/skills/effects/wx_status_acupoint"));
					else if ("resetDuration" in acu) acu.resetDuration();
					if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_16", "wx_fx_lotus_seal", 0, 110, 1.04);
				}
			}
			if (!_skill.isRanged())
			{
				if (agg.DazeOnHeavyHitPct > 0 && (_damageInflictedHitpoints >= 14 || _damageInflictedArmor >= 28) && ::Math.rand(1, 100) <= agg.DazeOnHeavyHitPct)
				{
					local ob0 = tsk0.getSkillByID("effects.wx_status_offbalance");
					if (ob0 == null) tsk0.add(::new("scripts/skills/effects/wx_status_offbalance"));
					else ob0.resetDuration();
				}
				if (agg.ShieldBreakBonus > 0 && (::Wuxia.hasMember(_targetEntity, "isArmedWithShield")) && _targetEntity.isArmedWithShield())
				{
					local sh = _targetEntity.getItems().getItemAtSlot(::Const.ItemSlot.Offhand);
					if (sh != null) sh.applyShieldDamage(agg.ShieldBreakBonus);
				}
				if (agg.OnHitDrainQi > 0 && (_damageInflictedHitpoints >= 1 || _damageInflictedArmor >= 10) && !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && (::Wuxia.hasMember(_targetEntity, "getFatigue")))
				{
					_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + agg.OnHitDrainQi));
					if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_19", null, 0, 150, 0.96);
				}

				// Bidirectional Martial Internal Injury: heavy direct-HP melee strikes from Tier 2+ martial artists / Fist / Hammer
				// can shock living human meridians (making 护心丹 & Ancient Temple Clinics genuinely relevant after tough fights!)
				if (_damageInflictedHitpoints >= 14 && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
				{
					local tMaxHP = ::Math.max(1, _targetEntity.getHitpointsMax());
					if ((_damageInflictedHitpoints.tofloat() / tMaxHP.tofloat()) >= 0.22)
					{
						local atkTier = (this.m.Slots.len() > 0 && this.m.Slots[0].ManualID != null) ? this.m.Slots[0].Tier : 0;
						local mainW = (::Wuxia.hasMember(actor, "getItems") && actor.getItems() != null) ? actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand) : null;
						local isConcussive = (mainW != null && ::Wuxia.CombatRules.matchesWeapon(mainW, ["Fist", "Hammer", "Staff"]));
						if (atkTier >= 2 || isConcussive || _skill.getID().find("actives.wx_") == 0)
						{
							local injChance = isConcussive ? 28 : 18;
							local tCont = tsk0.getSkillByID("special.wx_martial_container");
							if (tCont != null && tCont.m.CachedAggFlags != null)
							{
								if (tCont.m.CachedAggFlags.AntiInternalInjury) injChance = ::Math.floor(injChance * 0.5);
								if (tCont.m.CachedAggFlags.HeavyArmorScale > 0.0 && !isConcussive) injChance -= 5;
							}
							if (injChance > 0 && ::Math.rand(1, 100) <= injChance)
							{
								local inj = tsk0.getSkillByID("effects.wx_internal_injury");
								if (inj == null)
								{
									inj = ::new("scripts/skills/effects/wx_internal_injury");
									tsk0.add(inj);
								}
								inj.applySeverity(1, 2);
								if ("Tactical" in getroottable() && ::Tactical != null && ::Tactical.isActive() && "EventLog" in ::Tactical)
									::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_targetEntity) + " 遭刚猛内劲透体震伤经脉，染上「内伤」！");
							}
						}
					}
				}
			}
		}
		if (_skill.isRanged())
		{
			if (agg.FirearmDazePct > 0 && _targetEntity != null && _targetEntity.isAlive() && actor != null && !actor.isAlliedWith(_targetEntity) && ::Math.rand(1, 100) <= agg.FirearmDazePct)
			{
				local tsk = _targetEntity.getSkills();
				local ob = tsk.getSkillByID("effects.wx_status_offbalance");
				if (ob == null) tsk.add(::new("scripts/skills/effects/wx_status_offbalance"));
				else ob.resetDuration();
			}
			if (agg.SupportShotChance == 0 || this.m.SupportShotUsed || _targetEntity == null || !_targetEntity.isAlive()) return;
			local shot = _skill.getID();
			if (shot != "actives.quick_shot" && shot != "actives.aimed_shot" && shot != "actives.shoot_bolt") return;
			if (actor.isAlliedWith(_targetEntity)) return;
			local tile = _targetEntity.getTile();
			for (local d = 0; d < ::Const.Direction.COUNT; ++d)
			{
				if (!tile.hasNextTile(d)) continue;
				local next = tile.getNextTile(d);
				if (!next.IsOccupiedByActor) continue;
				local ally = next.getEntity();
				if (!ally.isAlive() || ally.getID() == actor.getID() || !actor.isAlliedWith(ally)) continue;
				if (::Math.rand(1, 100) <= agg.SupportShotChance)
				{
					local sk = _targetEntity.getSkills(), open = sk.getSkillByID("effects.wx_status_opening");
					if (open == null) sk.add(::new("scripts/skills/effects/wx_status_opening"));
					else open.resetDuration();
					this.m.SupportShotUsed = true;
				}
				break;
			}
			return;
		}

		if (agg.OnHitQiRegen > 0 && this.m.HitsRegenThisTurn < agg.OnHitQiCap)
		{
			this.m.HitsRegenThisTurn += 1;
			::Wuxia.CombatRules.restoreQi(actor, agg.OnHitQiRegen);
		}
	}

	function onMissed( _attacker, _skill )
	{
		if (this.m.CachedAggFlags == null || _skill == null) return;
		local agg = this.m.CachedAggFlags;
		local actor = this.getContainer().getActor();

		if (_skill.isRanged())
		{
			if (agg.DodgeRangedBonus > 0 && this.m.DodgeRegenThisTurn < agg.OnDodgeQiCap)
			{
				this.m.DodgeRegenThisTurn += 1;
				::Wuxia.CombatRules.restoreQi(actor, 2);
			}
			return;
		}

		if (agg.OnDodgeQiRegen > 0 && this.m.DodgeRegenThisTurn < agg.OnDodgeQiCap)
		{
			this.m.DodgeRegenThisTurn += 1;
			::Wuxia.CombatRules.restoreQi(actor, agg.OnDodgeQiRegen);
		}
	}

	function onTargetKilled( _targetEntity, _skill )
	{
		if (this.m.CachedAggFlags == null) return;
		local agg = this.m.CachedAggFlags;
		local actor = this.getContainer().getActor();
		if (actor == null) return;

		if (agg.OnKillQiRegen > 0)
		{
			::Wuxia.CombatRules.restoreQi(actor, agg.OnKillQiRegen);
		}

		if (agg.OnKillHealHP > 0 && this.m.KillHealsThisTurn < 2 && (_targetEntity == null || !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity)))
		{
			this.m.KillHealsThisTurn += 1;
			if (actor.getHitpoints() < actor.getHitpointsMax())
			{
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + agg.OnKillHealHP));
			}
		}

		// Conditional temporary AP burst on kill (can exceed 11 AP temporarily!)
		if (agg.OnKillAPRefund > 0 && !this.m.KillAPUsedThisTurn)
		{
			this.m.KillAPUsedThisTurn = true;
			this.grantTemporaryAP(agg.OnKillAPRefund);
		}
	}

	function onTargetMissed( _skill, _targetEntity )
	{
		if (this.m.CachedAggFlags == null || _skill == null || !_skill.isAttack()) return;
		if (this.m.CachedAggFlags.FastAdaptBonus > 0)
		{
			this.m.FastAdaptStacks = ::Math.min(4, this.m.FastAdaptStacks + 1);
		}
	}

	function onCombatStarted()
	{
		this.m.TemporaryAPOverflow = 0;
		this.m.FastAdaptStacks = 0;
	}

	function onCombatFinished()
	{
		this.m.TemporaryAPOverflow = 0;
		this.m.FastAdaptStacks = 0;
	}

	function onSerialize( _out )
	{
		this.skill.onSerialize(_out);
		this.ensureSlotsRegisteredInLearned();
		_out.writeU8(4);
		_out.writeU8(this.m.Slots.len());
		foreach (s in this.m.Slots)
		{
			_out.writeString(s.ManualID != null ? s.ManualID : "");
			_out.writeU8(s.Tier);
			_out.writeI32(s.Exp);
			_out.writeBool(s.IsFragment);
		}
		_out.writeU8(this.m.PendingWashChances);
		_out.writeU16(this.m.MarrowWashCount);

		local usedKeys = [];
		foreach (k, _ in this.m.UsedUniqueEffects) usedKeys.push(k);
		_out.writeU8(usedKeys.len());
		foreach (k in usedKeys) _out.writeString(k);

		// SchemaVersion >= 2: 1000-Faces Modular Appearance indices
		_out.writeI8(this.m.FaceIdx);
		_out.writeI8(this.m.HairIdx);
		_out.writeI8(this.m.BeardIdx);
		_out.writeI8(this.m.ScarIdx);

		// SchemaVersion >= 3: Per-character LearnedManuals library & preserved mastery
		local learnedKeys = [];
		foreach (mid, _ in this.m.LearnedManuals) learnedKeys.push(mid);
		_out.writeU16(learnedKeys.len());
		foreach (mid in learnedKeys)
		{
			local entry = this.m.LearnedManuals[mid];
			_out.writeString(mid);
			_out.writeU8(entry.Tier);
			_out.writeI32(entry.Exp);
			_out.writeBool(entry.IsFragment);
		}

		// SchemaVersion >= 4: Hair/Beard color tone (0..3) & Back cloak/sword-box/banner (0..16)
		_out.writeI8(this.m.HairToneIdx);
		_out.writeI8(this.m.BackIdx);
	}

	function onDeserialize( _in )
	{
		this.skill.onDeserialize(_in);
		this.initEmptySlots();
		this.m.LearnedManuals = {};

		local savedVer = _in.readU8();
		local slotCount = _in.readU8();
		for (local i = 0; i < slotCount; i = ++i)
		{
			local mid = _in.readString();
			local tier = _in.readU8();
			local exp = _in.readI32();
			local isFrag = _in.readBool();
			if (i < this.m.Slots.len())
			{
				this.m.Slots[i].ManualID   = (mid != "") ? mid : null;
				this.m.Slots[i].Tier       = tier;
				this.m.Slots[i].Exp        = exp;
				this.m.Slots[i].IsFragment = isFrag;
			}
		}

		this.m.PendingWashChances = _in.readU8();
		this.m.MarrowWashCount = _in.readU16();

		this.m.UsedUniqueEffects = {};
		local usedCount = _in.readU8();
		for (local j = 0; j < usedCount; j = ++j)
		{
			local key = _in.readString();
			this.m.UsedUniqueEffects[key] <- true;
		}

		if (savedVer >= 2)
		{
			this.m.FaceIdx  = _in.readI8();
			this.m.HairIdx  = _in.readI8();
			this.m.BeardIdx = _in.readI8();
			this.m.ScarIdx  = _in.readI8();
		}
		else
		{
			this.m.FaceIdx  = 0;
			this.m.HairIdx  = -1;
			this.m.BeardIdx = -1;
			this.m.ScarIdx  = -1;
		}

		if (savedVer >= 3)
		{
			local learnedCount = _in.readU16();
			for (local k = 0; k < learnedCount; k = ++k)
			{
				local lmid  = _in.readString();
				local ltier = _in.readU8();
				local lexp  = _in.readI32();
				local lfrag = _in.readBool();
				if (lmid != "" && ltier > 0)
				{
					this.m.LearnedManuals[lmid] <- {
						Tier       = ltier,
						Exp        = lexp,
						IsFragment = lfrag
					};
				}
			}
		}

		if (savedVer >= 4)
		{
			this.m.HairToneIdx = _in.readI8();
			this.m.BackIdx     = _in.readI8();
		}
		else
		{
			this.m.HairToneIdx = -1;
			this.m.BackIdx     = -1;
		}

		this.ensureSlotsRegisteredInLearned();
		this.m.SchemaVersion = 4;
	}
});
