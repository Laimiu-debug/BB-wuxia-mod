// Active Move: 揽雀借力掌
this.wx_fist_taiji <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_taiji";
		this.m.Name = "揽雀借力掌";
		this.m.Description = "四两拨千斤太极推手：消耗 4 AP 与 16 内息，圆转卸力推震来敌（命中 +12，震退目标并致散劲虚弱）。";
		this.m.Icon = "skills/wx_fist_taiji.png";
		this.m.IconDisabled = "skills/wx_fist_taiji_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_taiji";
		this.m.WX_VfxBrush <- "wx_vfx_15";
		this.m.WX_AnimID <- "wx_anim_52";
		this.m.WX_AnimMode <- "taiji_orb";
		this.m.WX_ChoreoID <- "wx_fist_taiji";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.35;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 12;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxTryKnockback(_user, target); this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
		}
		return hit;
	}
});
