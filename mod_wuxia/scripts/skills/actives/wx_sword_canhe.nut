// Active Move: 柳絮随风剑
this.wx_sword_canhe <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_canhe";
		this.m.Name = "柳絮随风剑";
		this.m.Description = "江南世家借势快剑：消耗 4 AP 与 15 内息，如柳絮随风粘剑顺刺（命中 +8，命中令敌手散劲虚弱）。";
		this.m.Icon = "skills/wx_sword_canhe.png";
		this.m.IconDisabled = "skills/wx_sword_canhe_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_canhe";
		this.m.WX_VfxBrush <- "wx_vfx_15";
		this.m.WX_AnimID <- "wx_anim_78";
		this.m.WX_AnimMode <- "taiji_canhe";
		this.m.WX_ChoreoID <- "wx_sword_canhe";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 15;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.28;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.DamageTotalMult *= 1.08;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
		}
		return hit;
	}
});
