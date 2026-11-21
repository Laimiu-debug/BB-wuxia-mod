// Active Move: 一阳贯脉指
this.wx_fist_yiyang <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_yiyang";
		this.m.Name = "一阳贯脉指";
		this.m.Description = "南诏皇室纯阳点穴绝学：消耗 5 AP 与 24 内息，凝全身纯阳真气于食指隔空两格点穴（命中 +12，极高穿甲并封脉点穴）。";
		this.m.Icon = "skills/wx_fist_yiyang.png";
		this.m.IconDisabled = "skills/wx_fist_yiyang_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_yiyang";
		this.m.WX_VfxBrush <- "wx_vfx_12";
		this.m.WX_AnimID <- "wx_anim_07";
		this.m.WX_AnimMode <- "sun_laser";
		this.m.WX_ChoreoID <- "wx_fist_yiyang";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 24;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.52;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 12; _properties.DamageDirectAdd += 0.20;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_acupoint", "scripts/skills/effects/wx_status_acupoint");
		}
		return hit;
	}
});
