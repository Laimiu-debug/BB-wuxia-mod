this.wx_acupoint_strike <- this.inherit("scripts/skills/actives/wx_move_base", {
	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_acupoint_strike";
		this.m.Name = "清风点穴";
		this.m.Description = "以剑尖封住气脉。造成七成伤害，命中后两回合内目标每回合少回 8 内息，出招内息消耗增加 35%。";
		this.m.Icon = "skills/active_03.png";
		this.m.IconDisabled = "skills/active_03_sw.png";
		this.m.Overlay = "active_03";
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 14;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.IsIgnoredAsAOO = true;
	}

	function onAnySkillUsed( _skill, _target, _properties )
	{
		if (_skill == this) _properties.DamageTotalMult *= 0.70;
	}

	function onUse( _user, _tile )
	{
		local target = _tile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit) this.wxApplyStatusToTarget(target, "effects.wx_status_acupoint", "scripts/skills/effects/wx_status_acupoint");
		return hit;
	}
});
