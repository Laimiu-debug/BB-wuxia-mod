// Core per-actor Martial Container: owns 7 slots, mastery exp, wash chances, stat hooks & save serialization

this.wx_martial_container <- this.inherit("scripts/skills/skill", {
	m = {
		SchemaVersion      = 1,
		Slots              = [],
		PendingWashChances = 0,
		UsedUniqueEffects  = {},
		MarrowWashCount    = 0,
		GrantedSkillIDs    = [],
		HitsRegenThisTurn  = 0,
		DodgeRegenThisTurn = 0,
		KillAPUsedThisTurn = false,
		CachedAggFlags     = null
	},

	function create()
	{
		this.m.ID = "special.wx_martial_container";
		this.m.Name = "武学修为";
		this.m.Description = "记录侠客所修习的七大武学插槽、重数火候与洗髓机缘。";
		this.m.Icon = "ui/perks/perk_54.png";
		this.m.Type = this.Const.SkillType.Special;
		this.m.Order = this.Const.SkillOrder.First;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsHidden = true;
		this.m.IsSerialized = true;

		this.initEmptySlots();
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
		local agg = ::Wuxia.CombatRules.getAggregateFlags(this);
		return agg.PermanentAPBonus;
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
			local def = ::Wuxia.Slots.getManualDef(s.ManualID);
			if (def == null) continue;
			local tierIdx = ::Math.min(s.Tier, def.Levels.len()) - 1;
			foreach (skillID in def.Levels[tierIdx].GrantSkills)
			{
				desired[skillID] <- true;
			}
		}

		// Reuse vanilla engine-native perks cleanly for Quick Hands & Pathfinder
		if (agg.QuickHands)        desired["perk.quick_hands"] <- true;
		if (agg.TerrainCostHalved) desired["perk.pathfinder"]  <- true;

		foreach (oldID in this.m.GrantedSkillIDs)
		{
			if (!(oldID in desired))
			{
				container.removeByID(oldID);
			}
		}

		local nextGranted = [];
		foreach (skillID, _ in desired)
		{
			nextGranted.push(skillID);
			if (!container.hasSkill(skillID))
			{
				local scriptPath = this.resolveSkillScriptPath(skillID);
				if (scriptPath != null)
				{
					local sk = ::new(scriptPath);
					sk.m.IsSerialized = false; // Managed dynamically by wx_martial_container
					container.add(sk);
				}
			}
		}
		this.m.GrantedSkillIDs = nextGranted;
	}

	function resolveSkillScriptPath( _skillID )
	{
		if (_skillID == "actives.wx_meditate")      return "scripts/skills/actives/wx_meditate";
		if (_skillID == "actives.wx_sword_combo")   return "scripts/skills/actives/wx_sword_combo";
		if (_skillID == "actives.wx_sword_counter") return "scripts/skills/actives/wx_sword_counter";
		if (_skillID == "actives.wx_sword_tianwai") return "scripts/skills/actives/wx_sword_tianwai";
		if (_skillID == "actives.wx_saber_cleave")  return "scripts/skills/actives/wx_saber_cleave";
		if (_skillID == "actives.wx_saber_duanyue") return "scripts/skills/actives/wx_saber_duanyue";
		if (_skillID == "actives.wx_spear_guard")   return "scripts/skills/actives/wx_spear_guard";
		if (_skillID == "actives.wx_throwing_rain") return "scripts/skills/actives/wx_throwing_rain";
		if (_skillID == "actives.wx_blood_burst")   return "scripts/skills/actives/wx_blood_burst";
		if (_skillID == "actives.footwork")         return "scripts/skills/actives/footwork";
		if (_skillID == "actives.rotation")         return "scripts/skills/actives/rotation";
		if (_skillID == "perk.quick_hands")         return "scripts/skills/perks/perk_quick_hands";
		if (_skillID == "perk.pathfinder")          return "scripts/skills/perks/perk_pathfinder";
		return null;
	}

	function onTurnStart()
	{
		this.m.HitsRegenThisTurn = 0;
		this.m.DodgeRegenThisTurn = 0;
		this.m.KillAPUsedThisTurn = false;

		// Conflict / Fragment mishap roll in combat
		local actor = this.getContainer().getActor();
		if (actor == null || !actor.isAlive()) return;

		local agg = ::Wuxia.CombatRules.getAggregateFlags(this);
		if (::Wuxia.Slots.hasNeigongConflict(actor))
		{
			local resolve = actor.getCurrentProperties().Bravery;
			local risk = ::Math.max(5, 25 - ::Math.floor(resolve / 4));
			if (::Math.rand(1, 100) <= risk)
			{
				::Wuxia.CombatRules.spendQi(actor, 10);
				this.Tactical.EventLog.log(::Const.UI.getColorizedEntityName(actor) + " 体内阴阳/正邪内息逆冲，损耗 10 点内息！");
			}
		}
		else if (agg.HasFragmentManual && ::Math.rand(1, 100) <= 10)
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

		// Apply flat stat bonuses from all equipped manuals
		foreach (s in this.m.Slots)
		{
			if (s.ManualID == null || s.Tier <= 0) continue;
			local def = ::Wuxia.Slots.getManualDef(s.ManualID);
			if (def == null) continue;
			local tierIdx = ::Math.min(s.Tier, def.Levels.len()) - 1;
			local st = def.Levels[tierIdx].Stats;

			if ("Hitpoints" in st)           _properties.Hitpoints += st.Hitpoints;
			if ("Bravery" in st)             _properties.Bravery += st.Bravery;
			if ("Stamina" in st)             _properties.Stamina += st.Stamina;
			if ("Initiative" in st)          _properties.Initiative += st.Initiative;
			if ("MeleeSkill" in st)          _properties.MeleeSkill += st.MeleeSkill;
			if ("RangedSkill" in st)         _properties.RangedSkill += st.RangedSkill;
			if ("MeleeDefense" in st)        _properties.MeleeDefense += st.MeleeDefense;
			if ("RangedDefense" in st)       _properties.RangedDefense += st.RangedDefense;
			if ("FatigueRecoveryRate" in st) _properties.FatigueRecoveryRate += st.FatigueRecoveryRate;
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

		// Elevation AP discount (when Pathfinder is not active)
		if (!agg.TerrainCostHalved && agg.ElevationDiscount && actor != null)
		{
			actor.m.LevelActionPointCost = 0;
		}

		// Direct / Armor damage bonuses
		if (agg.ArmorDmgBonus > 0.0)  _properties.DamageArmorMult += agg.ArmorDmgBonus;
		if (agg.DirectDmgBonus > 0.0) _properties.DamageDirectAdd += agg.DirectDmgBonus;
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
	}

	function onBeforeDamageReceived( _attacker, _skill, _hitInfo, _properties )
	{
		local actor = this.getContainer().getActor();
		if (actor == null || this.m.CachedAggFlags == null) return;
		local agg = this.m.CachedAggFlags;

		// Iron Shirt / Battle Forged heavy armor mitigation
		if (agg.HeavyArmorScale > 0.0)
		{
			local totalArmor = actor.getArmor(::Const.BodyPart.Body) + actor.getArmor(::Const.BodyPart.Head);
			local mult = 1.0 - (totalArmor * agg.HeavyArmorScale * 0.01);
			if (mult < 0.50) mult = 0.50;
			_properties.DamageReceivedArmorMult *= mult;
		}

		// True Qi Shield (阴柔内功护体: 1 Qi mitigates 2 HP damage, capped by QiShieldPct)
		if (agg.QiShieldPct > 0.0 && _hitInfo.DamageRegular > 0)
		{
			local availQi = ::Math.max(0, actor.getFatigueMax() - actor.getFatigue());
			if (availQi > 0)
			{
				local maxMitigate = ::Math.floor(_hitInfo.DamageRegular * agg.QiShieldPct);
				local qiNeeded = ::Math.ceil(maxMitigate / 2.0);
				local qiSpent = ::Math.min(availQi, qiNeeded);
				if (qiSpent > 0)
				{
					local actualMitigated = ::Math.min(maxMitigate, qiSpent * 2);
					local ratio = 1.0 - (actualMitigated.tofloat() / _hitInfo.DamageRegular.tofloat());
					if (ratio < 0.50) ratio = 0.50;
					_properties.DamageReceivedRegularMult *= ratio;
					::Wuxia.CombatRules.spendQi(actor, qiSpent);
				}
			}
		}
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		if (this.m.CachedAggFlags == null) return;
		local agg = this.m.CachedAggFlags;
		local actor = this.getContainer().getActor();

		if (agg.OnHitQiRegen > 0 && this.m.HitsRegenThisTurn < agg.OnHitQiCap)
		{
			this.m.HitsRegenThisTurn += 1;
			::Wuxia.CombatRules.restoreQi(actor, agg.OnHitQiRegen);
		}
	}

	function onMissed( _attacker, _skill )
	{
		if (this.m.CachedAggFlags == null) return;
		local agg = this.m.CachedAggFlags;
		local actor = this.getContainer().getActor();

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

		// Conditional temporary AP burst on kill (can exceed 11 AP temporarily!)
		if (agg.OnKillAPRefund > 0 && !this.m.KillAPUsedThisTurn)
		{
			this.m.KillAPUsedThisTurn = true;
			actor.setActionPoints(actor.getActionPoints() + agg.OnKillAPRefund);
		}
	}

	function onCombatFinished()
	{
		local actor = this.getContainer().getActor();
		if (actor != null && actor.isAlive() && actor.isPlayerControlled())
		{
			::Wuxia.Mastery.onCombatFinished(actor, 35);
		}
	}

	function onSerialize( _out )
	{
		this.skill.onSerialize(_out);
		_out.writeU8(this.m.SchemaVersion);
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
	}

	function onDeserialize( _in )
	{
		this.skill.onDeserialize(_in);
		this.initEmptySlots();

		this.m.SchemaVersion = _in.readU8();
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
	}
});
