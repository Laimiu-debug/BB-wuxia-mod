// Sect/Secret Fist Move: 擒龙探爪 (4 AP, 18 Qi, range 1-2: +10 hit, pulls range-2 enemy into melee & applies Opening)

this.wx_fist_grapple <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_grapple";
		this.m.WX_VfxBrush <- "wx_vfx_09";
		this.m.WX_AnimID <- "wx_anim_51";
		this.m.WX_AnimMode <- "vacuum_pull";
		this.m.WX_ChoreoID <- "wx_fist_grapple";
		this.m.Name = "擒龙探爪";
		this.m.Description = "吐气纵步探爪扣肩（1~2 格）：命中 +10，将 2 格外的敌方后排硬生生拽至身前 1 格并扯出「破绽」！";
		this.m.KilledString = "鹰爪碎喉";
		this.m.Icon = "skills/wx_fist_grapple.png";
		this.m.IconDisabled = "skills/wx_fist_grapple_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_grapple";
		this.m.SoundOnUse = [
			"sounds/combat/hand_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/hand_hit_03.wav"
		];
		this.m.IsIgnoredAsAOO = true;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.InjuriesOnBody = this.Const.Injury.BluntBody;
		this.m.InjuriesOnHead = this.Const.Injury.BluntHead;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.40;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10;
			_properties.DamageTotalMult *= 0.80;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxTryPullToAdjacent(_user, target);
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
		}
		return hit;
	}
});
