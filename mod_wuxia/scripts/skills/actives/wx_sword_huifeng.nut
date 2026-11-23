// Active Move: 回锋惊鸿刺
this.wx_sword_huifeng <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_huifeng";
		this.m.Name = "回锋惊鸿刺";
		this.m.Description = "回锋剑派奇险反刺：消耗 4 AP 与 17 内息，剑势半途折返直刺胁下（命中 +12，留破绽并回复自身 4 点内息）。";
		this.m.Icon = "skills/wx_sword_huifeng.png";
		this.m.IconDisabled = "skills/wx_sword_huifeng_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_huifeng";
		this.m.WX_VfxBrush <- "wx_vfx_01";
		this.m.WX_AnimID <- "wx_anim_84";
		this.m.WX_AnimMode <- "flurry_huifeng";
		this.m.WX_ChoreoID <- "wx_sword_huifeng";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 17;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.30;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 12; _properties.DamageTotalMult *= 1.08;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening"); _user.setFatigue(::Math.max(0, _user.getFatigue() - 4));
		}
		return hit;
	}
});
