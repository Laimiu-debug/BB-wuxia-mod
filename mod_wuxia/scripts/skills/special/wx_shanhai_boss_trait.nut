// Bespoke Tactical Mechanics for the 9 Shan Hai Jing Mythical Apex Bosses (志怪武侠尺度)

this.wx_shanhai_boss_trait <- this.inherit("scripts/skills/skill", {
	m = {
		BossID     = "zhuyan",
		KillAPUsed = false
	},

	function create()
	{
		this.m.ID = "special.wx_shanhai_boss_trait";
		this.m.Name = "山海凶威";
		this.m.Description = "《山海经》上古异兽与生俱来的凶煞异禀。";
		this.m.Icon = "ui/perks/perk_40.png";
		this.m.Type = this.Const.SkillType.Special | this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.Trait;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsHidden = false;
		this.m.IsSerialized = false;
	}

	function setBossID( _bossID )
	{
		this.m.BossID = _bossID;
		if ("ShanHaiBosses" in ::Wuxia.Config && (_bossID in ::Wuxia.Config.ShanHaiBosses))
		{
			local cfg = ::Wuxia.Config.ShanHaiBosses[_bossID];
			this.m.Name = cfg.TraitName;
			this.m.Description = cfg.TraitDesc;
		}
	}

	function onTurnStart()
	{
		this.m.KillAPUsed = false;
		local container = this.getContainer();
		local actor = container == null ? null : container.getActor();
		if (actor == null || !actor.isAlive()) return;

		local bid = this.m.BossID;
		if (bid == "zhuyan")
		{
			local poisoned = container.hasSkill("effects.wx_status_poison_dart") || container.hasSkill("effects.spider_poison") || container.hasSkill("effects.goblin_poison") || container.hasSkill("effects.bleeding");
			local heal = poisoned ? 8 : 25;
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + heal));
		}
		else if (bid == "jumang")
		{
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + 20));
		}
		else if (bid == "feiyi" && ("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive() && actor.isPlacedOnMap())
		{
			local myTile = actor.getTile();
			local allEntities = ::Tactical.Entities.getAllInstancesAsArray();
			foreach (ent in allEntities)
			{
				if (ent == null || !ent.isAlive() || !ent.isPlacedOnMap() || actor.isAlliedWith(ent)) continue;
				if (myTile.getDistanceTo(ent.getTile()) > 2) continue;
				if ("getItems" in ent && ent.getItems() != null)
				{
					local body = ent.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (body != null && body.getArmor() > 0)
						body.setArmor(::Math.max(0, body.getArmor() - 12));
				}
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(ent) && ("getFatigue" in ent))
					ent.setFatigue(::Math.min(ent.getFatigueMax(), ent.getFatigue() + 8));
			}
		}
		else if (bid == "jiuwei" && ("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive() && actor.isPlacedOnMap())
		{
			local myTile2 = actor.getTile();
			local allEntities2 = ::Tactical.Entities.getAllInstancesAsArray();
			foreach (ent2 in allEntities2)
			{
				if (ent2 == null || !ent2.isAlive() || !ent2.isPlacedOnMap() || actor.isAlliedWith(ent2)) continue;
				if (myTile2.getDistanceTo(ent2.getTile()) > 3) continue;
				local resolve = ent2.getCurrentProperties().Bravery;
				if (::Math.rand(1, 100) > resolve && ("getSkills" in ent2) && ent2.getSkills() != null)
				{
					local sk = ent2.getSkills();
					local ob = sk.getSkillByID("effects.wx_status_offbalance");
					if (ob == null) sk.add(::new("scripts/skills/effects/wx_status_offbalance"));
					else ob.resetDuration();
				}
			}
		}
	}

	function onUpdate( _properties )
	{
		local container = this.getContainer();
		local actor = container == null ? null : container.getActor();
		local bid = this.m.BossID;

		if (bid == "zhuyan")
		{
			if (actor != null && actor.getHitpointsMax() > 0 && (actor.getHitpoints().tofloat() / actor.getHitpointsMax().tofloat()) < 0.60)
			{
				_properties.MeleeSkill += 12;
				_properties.DamageTotalMult *= 1.25;
				_properties.IsImmuneToStun = true;
				_properties.IsImmuneToDisarm = true;
			}
		}
		else if (bid == "feiyi")
		{
			_properties.MeleeDefense += 6;
			_properties.RangedDefense += 10;
		}
		else if (bid == "qiongqi")
		{
			if (_properties.ActionPoints < 11) _properties.ActionPoints = 11;
			_properties.Initiative += 35;
			_properties.MeleeSkill += 10;
			_properties.MeleeDefense += 10;
		}
		else if (bid == "taotie")
		{
			_properties.MeleeSkill += 12;
			_properties.MeleeDefense += 8;
		}
		else if (bid == "jiuwei")
		{
			_properties.MeleeDefense += 18;
			_properties.RangedDefense += 28;
			_properties.Bravery += 35;
			_properties.DamageReceivedRegularMult *= 0.65;
		}
		else if (bid == "bashe")
		{
			_properties.MeleeSkill += 12;
			_properties.MeleeDefense += 10;
			_properties.RangedDefense += 15;
			_properties.DamageReceivedRangedMult *= 0.70;
		}
		else if (bid == "wuzhiqi")
		{
			_properties.MeleeSkill += 12;
			_properties.MeleeDefense += 10;
			_properties.Initiative += 15;
		}
		else if (bid == "xingtian")
		{
			_properties.MeleeSkill += 14;
			_properties.MeleeDefense += 10;
			_properties.IsImmuneToStun = true;
			_properties.IsImmuneToDisarm = true;
			if (actor != null && actor.getHitpointsMax() > 0 && (actor.getHitpoints().tofloat() / actor.getHitpointsMax().tofloat()) < 0.50)
			{
				_properties.DamageTotalMult *= 1.30;
			}
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (this.m.BossID == "qiongqi" && _skill != null && _skill.isAttack() && _targetEntity != null && ("getCurrentProperties" in _targetEntity))
		{
			if (_targetEntity.getCurrentProperties().Bravery >= 65)
			{
				_properties.MeleeSkill += 12;
				_properties.DamageTotalMult *= 1.15;
			}
		}
	}

	function onBeforeDamageReceived( _attacker, _skill, _hitInfo, _properties )
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (this.m.BossID == "jumang" && actor != null && _attacker != null && _attacker.getID() != actor.getID() && _attacker.isAlive() && _skill != null && !_skill.isRanged())
		{
			local mainW = ("getItems" in _attacker && _attacker.getItems() != null) ? _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand) : null;
			if (!::Wuxia.CombatRules.matchesWeapon(mainW, ["Axe"]))
			{
				if ("getItems" in _attacker && _attacker.getItems() != null)
				{
					local body = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (body != null && body.getArmor() > 0)
						body.setArmor(::Math.max(0, body.getArmor() - 10));
				}
				if (_attacker.getHitpoints() > 6)
					_attacker.setHitpoints(_attacker.getHitpoints() - 5);
			}
		}
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null || _targetEntity == null || !_targetEntity.isAlive() || actor.isAlliedWith(_targetEntity)) return;

		local bid = this.m.BossID;
		local tsk = _targetEntity.getSkills();
		if (tsk == null) return;

		if (bid == "qiongqi" && _damageInflictedHitpoints >= 5 && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
		{
			local bleed = ::new("scripts/skills/effects/bleeding_effect");
			bleed.setDamage(8);
			tsk.add(bleed);
		}
		else if (bid == "taotie" && _damageInflictedHitpoints > 0)
		{
			local drainHP = ::Math.min(35, _damageInflictedHitpoints);
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + drainHP));
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && ("getFatigue" in _targetEntity))
				_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + 10));
		}
		else if (bid == "bashe")
		{
			if (!::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
			{
				local p = tsk.getSkillByID("effects.wx_status_poison_dart");
				if (p == null) tsk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
				else if ("resetDuration" in p) p.resetDuration();
			}
			local ob = tsk.getSkillByID("effects.wx_status_offbalance");
			if (ob == null) tsk.add(::new("scripts/skills/effects/wx_status_offbalance"));
			else ob.resetDuration();
		}
		else if (bid == "wuzhiqi")
		{
			if (!::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity))
			{
				local acu = tsk.getSkillByID("effects.wx_status_acupoint");
				if (acu == null) tsk.add(::new("scripts/skills/effects/wx_status_acupoint"));
				else if ("resetDuration" in acu) acu.resetDuration();
			}
			local ob2 = tsk.getSkillByID("effects.wx_status_offbalance");
			if (ob2 == null) tsk.add(::new("scripts/skills/effects/wx_status_offbalance"));
			else ob2.resetDuration();
		}
	}

	function onTargetKilled( _targetEntity, _skill )
	{
		if (this.m.BossID == "xingtian" && !this.m.KillAPUsed)
		{
			local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
			if (actor != null && actor.isAlive())
			{
				this.m.KillAPUsed = true;
				actor.setActionPoints(::Math.min(12, actor.getActionPoints() + 3));
			}
		}
	}
});
