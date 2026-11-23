// Active Move: 少室擒龙爪
this.wx_fist_longzhao <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_longzhao";
		this.m.Name = "少室擒龙爪";
		this.m.Description = "少室刚猛鹰爪擒拿：消耗 4 AP 与 17 内息，五指如铁钩扣裂护腕肩甲（破甲 +30%，命中 +8，留破绽）。";
		this.m.Icon = "skills/wx_fist_longzhao.png";
		this.m.IconDisabled = "skills/wx_fist_longzhao_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_longzhao";
		this.m.WX_VfxBrush <- "wx_vfx_09";
		this.m.WX_AnimID <- "wx_anim_103";
		this.m.WX_AnimMode <- "pierce_longzhao";
		this.m.WX_ChoreoID <- "wx_fist_longzhao";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 17;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.36;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.DamageArmorMult *= 1.30;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
		}
		return hit;
	}
});
