// Active Move: 霹雳雷火弹
this.wx_throw_pilidan <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_throw_pilidan";
		this.m.Name = "霹雳雷火弹";
		this.m.Description = "蜀中唐门火器秘宝：消耗 5 AP 与 26 内息，掷出硫磺铁蒺藜雷火弹轰碎目标护甲并震慑定力。";
		this.m.Icon = "skills/wx_throw_pilidan.png";
		this.m.IconDisabled = "skills/wx_throw_pilidan_sw.png";
		this.m.Overlay = "wx_ov_wx_throw_pilidan";
		this.m.WX_VfxBrush <- "wx_vfx_29";
		this.m.WX_AnimID <- "wx_anim_14";
		this.m.WX_AnimMode <- "bomb_arc";
		this.m.WX_ChoreoID <- "wx_throw_pilidan";
		this.m.SoundOnUse = ["sounds/combat/javelin_throw_01.wav", "sounds/combat/javelin_throw_03.wav"];
		this.m.SoundOnHit = ["sounds/combat/javelin_hit_01.wav"];
		this.m.SoundOnMiss = ["sounds/combat/javelin_miss_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 26;
		this.m.MinRange = 2;
		this.m.MaxRange = 4;
		this.m.MaxLevelDifference = 4;
		this.m.IsRanged = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Pilileihuo;
		this.m.IsProjectileRotated = false;
		this.m.ProjectileTimeScale = 0.96;
		this.m.RequiredWeaponTypes = ["Throwing"];
		this.m.DirectDamageMult = 0.38;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 10; _properties.DamageArmorMult *= 1.45; _properties.DamageTotalMult *= 1.20;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.wxThrowAt(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance"); if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.checkMorale(-1, -12);
		}
		return hit;
	}
});
