// Active Move: 圣火奇令刺
this.wx_dagger_shenghuo <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_dagger_shenghuo";
		this.m.Name = "圣火奇令刺";
		this.m.Description = "西域拜火诡异短刃法：消耗 4 AP 与 15 内息，奇令怪招颠倒敌手重心（命中 +10，致敌失衡与散劲虚弱）。";
		this.m.Icon = "skills/wx_dagger_shenghuo.png";
		this.m.IconDisabled = "skills/wx_dagger_shenghuo_sw.png";
		this.m.Overlay = "wx_ov_wx_dagger_shenghuo";
		this.m.WX_VfxBrush <- "wx_vfx_02";
		this.m.WX_AnimID <- "wx_anim_133";
		this.m.WX_AnimMode <- "flurry_shenghuo";
		this.m.WX_ChoreoID <- "wx_dagger_shenghuo";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 15;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Dagger"];
		this.m.DirectDamageMult = 0.34;
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
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance"); this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
		}
		return hit;
	}
});
