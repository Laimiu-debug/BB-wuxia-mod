// Active Move: 流星连珠箭
this.wx_bow_liuxing <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_bow_liuxing";
		this.m.Name = "流星连珠箭";
		this.m.Description = "塞外神射快箭绝技：消耗 4 AP 与 18 内息，搭箭如流星赶月疾射敌阵（远射命中 +8，射程 2 至 6 格）。";
		this.m.Icon = "skills/wx_bow_liuxing.png";
		this.m.IconDisabled = "skills/wx_bow_liuxing_sw.png";
		this.m.Overlay = "wx_ov_wx_bow_liuxing";
		this.m.WX_VfxBrush <- "wx_vfx_02";
		this.m.WX_AnimID <- "wx_anim_34";
		this.m.WX_AnimMode <- "triple_arc";
		this.m.WX_ChoreoID <- "wx_bow_liuxing";
		this.m.SoundOnUse = ["sounds/combat/quick_shot_01.wav", "sounds/combat/quick_shot_02.wav"];
		this.m.SoundOnHit = ["sounds/combat/arrow_hit_01.wav", "sounds/combat/arrow_hit_02.wav"];
		this.m.SoundOnMiss = ["sounds/combat/arrow_miss_01.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 2;
		this.m.MaxRange = 6;
		this.m.MaxLevelDifference = 4;
		this.m.IsRanged = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Liuxingjian;
		this.m.IsProjectileRotated = true;
		this.m.ProjectileTimeScale = 1.38;
		this.m.RequiredWeaponTypes = ["Bow"];
		this.m.DirectDamageMult = 0.35;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 8; _properties.DamageTotalMult *= 1.08;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.wxShootBowAt(_user, target);
		return hit;
	}
});
