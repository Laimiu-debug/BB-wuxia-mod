// Active Move: 拈花擒拿手
this.wx_fist_nianhua <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_nianhua";
		this.m.Name = "拈花擒拿手";
		this.m.Description = "禅门精妙分筋错骨手：消耗 4 AP 与 16 内息，指拈金莲巧卸关节（命中 +12，令敌失衡并削减其 10 点内息）。";
		this.m.Icon = "skills/wx_fist_nianhua.png";
		this.m.IconDisabled = "skills/wx_fist_nianhua_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_nianhua";
		this.m.WX_VfxBrush <- "wx_vfx_16";
		this.m.WX_AnimID <- "wx_anim_106";
		this.m.WX_AnimMode <- "taiji_nianhua";
		this.m.WX_ChoreoID <- "wx_fist_nianhua";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.36;
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
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance"); if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.setFatigue(::Math.min(target.getFatigueMax(), target.getFatigue() + 10));
		}
		return hit;
	}
});
