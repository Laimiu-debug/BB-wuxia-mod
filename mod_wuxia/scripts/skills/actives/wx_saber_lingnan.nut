// Active Move: 南岭滚堂刀
this.wx_saber_lingnan <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_lingnan";
		this.m.Name = "南岭滚堂刀";
		this.m.Description = "南疆矮步掠地快刀：消耗 4 AP 与 15 内息，贴地旋滚削斩脚筋（命中 +10，解除盾墙并致目标失衡）。";
		this.m.Icon = "skills/wx_saber_lingnan.png";
		this.m.IconDisabled = "skills/wx_saber_lingnan_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_lingnan";
		this.m.WX_VfxBrush <- "wx_vfx_01";
		this.m.WX_AnimID <- "wx_anim_97";
		this.m.WX_AnimMode <- "taiji_lingnan";
		this.m.WX_ChoreoID <- "wx_saber_lingnan";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 15;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber", "Sword"];
		this.m.DirectDamageMult = 0.28;
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
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			local tsk = target.getSkills(); if (tsk != null) tsk.removeByID("effects.shieldwall"); this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		return hit;
	}
});
