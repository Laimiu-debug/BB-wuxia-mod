// Active Move: 梨花暴雨枪
this.wx_spear_liuhua <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_spear_liuhua";
		this.m.Name = "梨花暴雨枪";
		this.m.Description = "将门快枪攒刺绝艺：消耗 5 AP 与 22 内息，枪花如梨花瑞雪笼罩两格敌身（命中 +10，必留破绽）。";
		this.m.Icon = "skills/wx_spear_liuhua.png";
		this.m.IconDisabled = "skills/wx_spear_liuhua_sw.png";
		this.m.Overlay = "wx_ov_wx_spear_liuhua";
		this.m.WX_VfxBrush <- "wx_vfx_03";
		this.m.WX_AnimID <- "wx_anim_54";
		this.m.WX_AnimMode <- "petal_storm";
		this.m.WX_ChoreoID <- "wx_spear_liuhua";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Spear", "Polearm"];
		this.m.DirectDamageMult = 0.30;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10; _properties.DamageTotalMult *= 1.10;
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
