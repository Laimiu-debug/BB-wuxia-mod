this.wx_smoke_cast <- this.inherit("scripts/skills/actives/wx_move_base", {
	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_smoke_cast";
		this.m.Name = "掷烟蔽目";
		this.m.Description = "以暗器击破烟囊。命中造成半数伤害，使目标两回合视野 -2、射艺 -25、武艺 -10。";
		this.m.Icon = "skills/active_48.png";
		this.m.IconDisabled = "skills/active_48_sw.png";
		this.m.Overlay = "active_48";
		this.m.IsRanged = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsDoingForwardMove = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 14;
		this.m.MinRange = 1;
		this.m.MaxRange = 3;
		this.m.RequiredWeaponTypes = ["Throwing"];
	}

	function onAnySkillUsed( _skill, _target, _properties )
	{
		if (_skill == this) _properties.DamageTotalMult *= 0.50;
	}

	function onUse( _user, _tile )
	{
		local target = _tile.getEntity();
		local hit = this.wxThrowAt(_user, target);
		if (hit) this.wxApplyStatusToTarget(target, "effects.wx_status_smoke_screen", "scripts/skills/effects/wx_status_smoke_screen");
		return hit;
	}
});
