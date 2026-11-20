// Core per-actor Martial Container: owns 7 slots, mastery exp, wash chances, stat hooks & save serialization

this.wx_martial_container <- this.inherit("scripts/skills/skill", {
	m = {
		SchemaVersion      = 1,
		Slots              = [],
		PendingWashChances = 0,
		UsedUniqueEffects  = {},
		MarrowWashCount    = 0,
		GrantedSkills      = {},
		TemporaryAPOverflow = 0,
		HitsRegenThisTurn  = 0,
		DodgeRegenThisTurn = 0,
		KillAPUsedThisTurn = false,
		IsIntercepting     = false,
		SupportShotUsed    = false,
		FastAdaptStacks    = 0,
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
		local permanentMax = actor.getActionPointsMax() - this.m.TemporaryAPOverflow;
		local next = actor.getActionPoints() + _amount;
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

	function onTurnStart()
	{
		this.m.HitsRegenThisTurn = 0;
		this.m.DodgeRegenThisTurn = 0;
		this.m.KillAPUsedThisTurn = false;
		this.m.SupportShotUsed = false;

		// Conflict / Fragment mishap roll in combat
		local actor = this.getContainer().getActor();
		if (actor == null || !actor.isAlive()) return;

		local agg = ::Wuxia.CombatRules.getAggregateFlags(this);
		if (::Wuxia.Slots.hasNeigongConflict(actor))
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
		else if (agg.HasFragmentManual && ::Math.rand(1, 100) <= (agg.AntiInternalInjury ? 5 : 10))
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
		if (agg.StaffGuard && !container.hasSkill("perk.underdog")) _properties.SurroundedDefense += 5;

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

		// Command Aura from nearby allied 《聚义令》 commander within 4 tiles (does not double-stack with vanilla Banner)
		if ("Tactical" in getroottable() && ::Tactical != null && ::Tactical.isActive() && actor.isPlacedOnMap() && !this.getContainer().hasSkill("effects.player_banner"))
		{
			local myTile = actor.getTile();
			local bestResolveBonus = 0;
			local allies = ::Tactical.Entities.getInstancesOfFaction(actor.getFaction());
			foreach (ally in allies)
			{
				if (ally == null || ally.getID() == actor.getID() || !ally.isAlive() || !ally.isPlacedOnMap()) continue;
				if (ally.getMoraleState() == ::Const.MoraleState.Fleeing) continue;
				if (myTile.getDistanceTo(ally.getTile()) > 4) continue;
				local ac = ally.getSkills().getSkillByID("special.wx_martial_container");
				if (ac != null && ac.m.CachedAggFlags != null && ac.m.CachedAggFlags.CommandAuraPct > 0.0)
				{
					local cmdBravery = ally.getBaseProperties().Bravery + (("Bravery" in ac.m.CachedAggFlags.Stats) ? ac.m.CachedAggFlags.Stats.Bravery : 0);
					local bonus = ::Math.floor(cmdBravery * ac.m.CachedAggFlags.CommandAuraPct);
					if (bonus > bestResolveBonus) bestResolveBonus = bonus;
				}
			}
			if (bestResolveBonus > 0) _properties.Bravery += bestResolveBonus;
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		local f = this.m.CachedAggFlags;
		if (f == null || _skill == null || !_skill.isAttack() || !_skill.m.IsWeaponSkill) return;
		local adaptHit = (f.FastAdaptBonus > 0 && this.m.FastAdaptStacks > 0) ? (this.m.FastAdaptStacks * f.FastAdaptBonus) : 0;
		if (_targetEntity != null)
		{
			if (f.VsUndeadDmg > 0.0 && ::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
				_properties.DamageTotalMult *= (1.0 + f.VsUndeadDmg);
			if (f.VsPoisonedHit > 0 && "getSkills" in _targetEntity && _targetEntity.getSkills() != null)
			{
				local tsk = _targetEntity.getSkills();
				if (tsk.hasSkill("effects.wx_status_poison_dart") || tsk.hasSkill("effects.spider_poison") || tsk.hasSkill("effects.goblin_poison"))
					adaptHit += f.VsPoisonedHit;
			}
		}
		if (!_skill.isRanged())
		{
			_properties.MeleeSkill += f.HitChanceBonus + adaptHit + (this.m.IsIntercepting ? f.ZoCBonusHit : 0);
			_properties.HitChance[::Const.BodyPart.Head] += f.CritHeadBonus;
			return;
		}
		if (adaptHit > 0) _properties.RangedSkill += adaptHit;
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
		if (agg.ReflectArmorDmg > 0 && _attacker != null && _attacker.getID() != actor.getID() && _attacker.isAlive() && _skill != null && !_skill.isRanged() && "getItems" in _attacker && _attacker.getItems() != null)
		{
			local atkBody = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
			if (atkBody != null && atkBody.getArmor() > 0)
			{
				atkBody.setArmor(::Math.max(0, atkBody.getArmor() - agg.ReflectArmorDmg));
			}
		}
		if (agg.FrostChillOnHit && _attacker != null && _attacker.getID() != actor.getID() && _attacker.isAlive() && _skill != null && !_skill.isRanged() && "getSkills" in _attacker && _attacker.getSkills() != null)
		{
			local ask = _attacker.getSkills();
			local ob = ask.getSkillByID("effects.wx_status_offbalance");
			if (ob == null) ask.add(::new("scripts/skills/effects/wx_status_offbalance"));
			else ob.resetDuration();
		}

		// True Qi Shield (阴柔内功护体: 1 Qi mitigates 2 HP damage, capped by QiShieldPct)
		if (agg.QiShieldPct > 0.0 && _hitInfo.DamageRegular > 0)
		{
			local availQi = ::Math.max(0, actor.getFatigueMax() - actor.getFatigue());
			if (availQi > 0)
			{
				local shieldPct = agg.QiShieldPct;
				if (agg.LightArmorMitigation > 0)
				{
					local light = ::Wuxia.CombatRules.getLightArmorDamageMult(actor, agg.LightArmorMitigation);
					shieldPct = ::Math.minf(shieldPct, ::Math.maxf(0.0, 1.0 - 0.40 / light));
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

		if (agg.WuduPoisonPct > 0 && _damageInflictedHitpoints >= 4 && _targetEntity != null && _targetEntity.isAlive() && actor != null && !actor.isAlliedWith(_targetEntity) && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
		{
			if (::Math.rand(1, 100) <= agg.WuduPoisonPct)
			{
				local tsk = _targetEntity.getSkills();
				local p = tsk.getSkillByID("effects.wx_status_poison_dart");
				if (p == null) tsk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
				else if ("resetDuration" in p) p.resetDuration();
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
		if (this.m.CachedAggFlags == null || _skill == null || _skill.isRanged()) return;
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
