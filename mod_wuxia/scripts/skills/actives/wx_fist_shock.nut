// Paired Fist Basic Move 2: 寸劲震脉 (4 AP, 16 Qi, +10% armor ignore, drains 8 Qi & inflicts off-balance on solid HP hit)

this.wx_fist_shock <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_shock";
		this.m.Name = "寸劲震脉";
		this.m.Description = "贴身吐劲透甲伤腑：穿甲率额外 +10%，击伤气血达 6 点时震散目标 8 点内息并令其「失衡」。";
		this.m.KilledString = "寸劲震毙";
		this.m.Icon = "skills/active_02.png";
		this.m.IconDisabled = "skills/active_02_sw.png";
		this.m.Overlay = "active_02";
		this.m.SoundOnUse = [
			"sounds/combat/hand_01.wav",
			"sounds/combat/hand_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/mace_01.wav",
			"sounds/combat/mace_02.wav"
		];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.InjuriesOnBody = this.Const.Injury.BluntBody;
		this.m.InjuriesOnHead = this.Const.Injury.BluntHead;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.35;
		this.m.IsIgnoredAsAOO = true;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageDirectAdd += 0.10;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		local hpBefore = target != null ? target.getHitpoints() : 0;
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive() && (hpBefore - target.getHitpoints()) >= 6)
		{
			target.setFatigue(::Math.min(target.getFatigueMax(), target.getFatigue() + 8));
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		return hit;
	}
});
