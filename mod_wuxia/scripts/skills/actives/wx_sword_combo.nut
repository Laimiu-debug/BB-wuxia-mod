// Active Move: 清风连环剑 (Sword, 4 AP, 15 Qi, +10% hit, inflicts 破绽)

this.wx_sword_combo <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_combo";
		this.m.Name = "清风连环剑";
		this.m.Description = "清风剑派精妙连剑：命中 +10%，击中目标后在其守势上留下「破绽」（下次受击伤害 +15%）。";
		this.m.Icon = "skills/active_01.png";
		this.m.IconDisabled = "skills/active_01_sw.png";
		this.m.Overlay = "active_01";
		this.m.SoundOnUse = [
			"sounds/combat/slash_01.wav",
			"sounds/combat/slash_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/slash_hit_01.wav",
			"sounds/combat/slash_hit_02.wav"
		];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 15;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.25;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
		}
		return hit;
	}
});
