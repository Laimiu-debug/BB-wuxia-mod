// Sect Shield Henglian Move: 铁壁震山靠 (4 AP, 16 Qi, requires Shield: +15 hit blunt bash, knocks back 1 tile & inflicts Off-Balance)

this.wx_shield_bash_qi <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_shield_bash_qi";
		this.m.Name = "铁壁震山靠";
		this.m.Description = "运起横练内劲以藤牌或铁盾猛撞贴身强敌：命中 +15，将其震退 1 格、陷入「失衡」并损耗 12 点内息！";
		this.m.KilledString = "铁盾震碎心脉";
		this.m.Icon = "skills/active_33.png";
		this.m.IconDisabled = "skills/active_33_sw.png";
		this.m.Overlay = "active_33";
		this.m.SoundOnUse = [
			"sounds/combat/hand_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/hand_hit_03.wav"
		];
		this.m.IsWeaponSkill = false;
		this.m.IsIgnoredAsAOO = true;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.InjuriesOnBody = this.Const.Injury.BluntBody;
		this.m.InjuriesOnHead = this.Const.Injury.BluntHead;
		this.m.RequiredWeaponTypes = [];
		this.m.DirectDamageMult = 0.45;
	}

	function wxHasShield()
	{
		local container = this.getContainer();
		local actor = container == null ? null : container.getActor();
		return actor != null && ("isArmedWithShield" in actor) && actor.isArmedWithShield();
	}

	function isHidden()
	{
		return this.skill.isHidden() || !this.wxHasShield();
	}

	function isUsable()
	{
		return this.skill.isUsable() && this.wxHasShield();
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 15;
			_properties.DamageRegularMin = 15;
			_properties.DamageRegularMax = 25;
			_properties.DamageArmorMult *= 0.60;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(target))
			{
				target.setFatigue(::Math.min(target.getFatigueMax(), target.getFatigue() + 12));
			}
			this.wxTryKnockback(_user, target);
		}
		return hit;
	}
});
