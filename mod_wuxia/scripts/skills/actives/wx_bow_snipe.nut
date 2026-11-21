// Sect/Secret Bow Move: 流星追月箭 (5 AP, 20 Qi, range 2-7: +12 RangedSkill, +15% pen, leaves Opening)

this.wx_bow_snipe <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_bow_snipe";
		this.m.WX_VfxBrush <- "wx_vfx_03";
		this.m.WX_AnimID <- "wx_anim_12";
		this.m.WX_AnimMode <- "sonic_arrow";
		this.m.WX_ChoreoID <- "wx_bow_snipe";
		this.m.Name = "流星追月箭";
		this.m.Description = "屏息开满弓弦贯注内息（2~7 格）：射艺命中 +12、穿甲率 +15%，一箭破开目标「破绽」供前排重创！";
		this.m.KilledString = "流星一箭贯脑";
		this.m.Icon = "skills/wx_bow_snipe.png";
		this.m.IconDisabled = "skills/wx_bow_snipe_sw.png";
		this.m.Overlay = "wx_ov_wx_bow_snipe";
		this.m.SoundOnUse = [
			"sounds/combat/aimed_shot_01.wav",
			"sounds/combat/aimed_shot_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/arrow_hit_01.wav",
			"sounds/combat/arrow_hit_02.wav"
		];
		this.m.SoundOnMiss = [
			"sounds/combat/arrow_miss_01.wav",
			"sounds/combat/arrow_miss_02.wav"
		];
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Liuxingjian;
		this.m.IsProjectileRotated = true;
		this.m.ProjectileTimeScale = 1.38;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsDoingForwardMove = false;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 2;
		this.m.MaxRange = 7;
		this.m.MaxLevelDifference = 4;
		this.m.InjuriesOnBody = this.Const.Injury.PiercingBody;
		this.m.InjuriesOnHead = this.Const.Injury.PiercingHead;
		this.m.RequiredWeaponTypes = ["Bow"];
		this.m.DirectDamageMult = 0.45;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 12;
			_properties.DamageDirectAdd += 0.15;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.wxShootBowAt(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
		}
		return hit;
	}
});
