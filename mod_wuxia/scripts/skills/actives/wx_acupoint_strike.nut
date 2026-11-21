this.wx_acupoint_strike <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_acupoint_strike";
		this.m.WX_VfxBrush <- "wx_vfx_12";
		this.m.WX_AnimID <- "wx_anim_37";
		this.m.WX_AnimMode <- "acupoint";
		this.m.WX_ChoreoID <- "wx_acupoint_strike";
		this.m.Name = "清风点穴";
		this.m.Description = "以剑尖封住气脉。造成七成伤害，命中后两回合内目标每回合少回 8 内息，出招内息消耗增加 35%。";
		this.m.Icon = "skills/wx_acupoint_strike.png";
		this.m.IconDisabled = "skills/wx_acupoint_strike_sw.png";
		this.m.Overlay = "wx_ov_wx_acupoint_strike";
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
		::Wuxia.VFX.playSkillVfx(this, _user, _tile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit) this.wxApplyStatusToTarget(target, "effects.wx_status_acupoint", "scripts/skills/effects/wx_status_acupoint");
		return hit;
	}
});
