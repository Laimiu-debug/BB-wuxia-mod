// Active Move: 九星贯日箭
this.wx_bow_jiuxing <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_bow_jiuxing";
		this.m.Name = "九星贯日箭";
		this.m.Description = "白马义从镇军神射：消耗 5 AP 与 22 内息，九星连珠劲矢破甲穿胸（射程 2~7 格，射艺 +12，破甲 +28%）。";
		this.m.Icon = "skills/wx_bow_jiuxing.png";
		this.m.IconDisabled = "skills/wx_bow_jiuxing_sw.png";
		this.m.Overlay = "wx_ov_wx_bow_jiuxing";
		this.m.WX_VfxBrush <- "wx_vfx_03";
		this.m.WX_AnimID <- "wx_anim_138";
		this.m.WX_AnimMode <- "flurry_jiuxing";
		this.m.WX_ChoreoID <- "wx_bow_jiuxing";
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Liuxingjian;
		this.m.IsProjectileRotated = true;
		this.m.ProjectileTimeScale = 1.25;
		this.m.SoundOnUse = ["sounds/combat/aimed_shot_01.wav", "sounds/combat/aimed_shot_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 2;
		this.m.MaxRange = 7;
		this.m.RequiredWeaponTypes = ["Bow"];
		this.m.DirectDamageMult = 0.42;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 12; _properties.DamageArmorMult *= 1.28; _properties.DamageTotalMult *= 1.14;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.wxShootBowAt(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
		}
		return hit;
	}
});
