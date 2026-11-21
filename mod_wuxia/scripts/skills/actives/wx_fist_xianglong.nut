// Active Move: 亢龙有悔掌
this.wx_fist_xianglong <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_xianglong";
		this.m.Name = "亢龙有悔掌";
		this.m.Description = "天下至刚阳掌绝诣：消耗 6 AP 与 28 内息，掌力吐出三分留七分，刚猛透甲（总伤 +25%，穿甲 +20%，并震退敌手）。";
		this.m.Icon = "skills/wx_fist_xianglong.png";
		this.m.IconDisabled = "skills/wx_fist_xianglong_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_xianglong";
		this.m.WX_VfxBrush <- "wx_vfx_09";
		this.m.WX_AnimID <- "wx_anim_05";
		this.m.WX_AnimMode <- "dragon_coil";
		this.m.WX_ChoreoID <- "wx_fist_xianglong";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 28;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.48;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.DamageTotalMult *= 1.25; _properties.DamageDirectAdd += 0.20;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxTryKnockback(_user, target); this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury");
		}
		return hit;
	}
});
