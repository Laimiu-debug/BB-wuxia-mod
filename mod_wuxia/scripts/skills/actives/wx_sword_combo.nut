// Active Move: 清风连环剑 (Sword, 4 AP, 15 Qi, +10% hit, inflicts 破绽)

this.wx_sword_combo <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_combo";
		this.m.WX_VfxBrush <- "wx_vfx_01";
		this.m.WX_AnimID <- "wx_anim_01";
		this.m.WX_AnimMode <- "combo3";
		this.m.WX_ChoreoID <- "wx_sword_combo";
		this.m.Name = "清风连环剑";
		this.m.Description = "清风剑派精妙连剑。命中 +10%，击中后可留下「破绽」，使下次受击伤害提高 15%。修习《清风连环剑》时，破绽概率随重数提升。";
		this.m.Icon = "skills/wx_sword_combo.png";
		this.m.IconDisabled = "skills/wx_sword_combo_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_combo";
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
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening", "InflictOpeningPct");
		}
		return hit;
	}
});
