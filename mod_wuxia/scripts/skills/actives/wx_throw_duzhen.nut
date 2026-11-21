// Active Move: 五毒丧门钉
this.wx_throw_duzhen <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_throw_duzhen";
		this.m.Name = "五毒丧门钉";
		this.m.Description = "南疆唐门喂毒暗器：消耗 4 AP 与 18 内息，悄无声息射出碧璘毒钉（命中 +12，令血肉之躯中奇毒蚀血损气）。";
		this.m.Icon = "skills/wx_throw_duzhen.png";
		this.m.IconDisabled = "skills/wx_throw_duzhen_sw.png";
		this.m.Overlay = "wx_ov_wx_throw_duzhen";
		this.m.WX_VfxBrush <- "wx_vfx_28";
		this.m.WX_AnimID <- "wx_anim_67";
		this.m.WX_AnimMode <- "venom_spikes";
		this.m.WX_ChoreoID <- "wx_throw_duzhen";
		this.m.SoundOnUse = ["sounds/combat/javelin_throw_01.wav", "sounds/combat/javelin_throw_02.wav"];
		this.m.SoundOnHit = ["sounds/combat/javelin_hit_01.wav"];
		this.m.SoundOnMiss = ["sounds/combat/javelin_miss_01.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 2;
		this.m.MaxRange = 4;
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Sangmending;
		this.m.IsProjectileRotated = true;
		this.m.ProjectileTimeScale = 1.22;
		this.m.RequiredWeaponTypes = ["Throwing"];
		this.m.DirectDamageMult = 0.42;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 12;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.wxThrowAt(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
		}
		return hit;
	}
});
