// Active Move: 暴雨毒针 (Throwing Secret Art, 3 AP, 14 Qi, range 2-3, high pierce + poison dart)

this.wx_throwing_rain <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_throwing_rain";
		this.m.WX_VfxBrush <- "wx_vfx_27";
		this.m.WX_AnimID <- "wx_anim_13";
		this.m.WX_AnimMode <- "needle24";
		this.m.WX_ChoreoID <- "wx_throwing_rain";
		this.m.Name = "暴雨毒针";
		this.m.Description = "暴雨暗器谱杀招：3 AP 疾射 2~3 格，准头 +15%（专克高招架轻装），命中注入「暗器剧毒」持续损血散气。";
		this.m.Icon = "skills/wx_throwing_rain.png";
		this.m.IconDisabled = "skills/wx_throwing_rain_sw.png";
		this.m.Overlay = "wx_ov_wx_throwing_rain";
		this.m.SoundOnUse = [
			"sounds/combat/javelin_throw_01.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/javelin_hit_01.wav"
		];
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Lihuazhen;
		this.m.IsProjectileRotated = true;
		this.m.ProjectileTimeScale = 1.35;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsDoingForwardMove = false;
		this.m.ActionPointCost = 3;
		this.m.FatigueCost = 14;
		this.m.MinRange = 1;
		this.m.MaxRange = 3;
		this.m.MaxLevelDifference = 4;
		this.m.RequiredWeaponTypes = ["Throwing"];
		this.m.DirectDamageMult = 0.45;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			_properties.RangedSkill += 15;
			if ("Streams" in ::Wuxia) ::Wuxia.Streams.addCappedPen(_properties, 0.15);
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.wxThrowAt(_user, target);
		if (hit)
		{
			if (target != null && target.isAlive())
				this.wxApplyStatusToTarget(target, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
			if ("Streams" in ::Wuxia)
				::Wuxia.Streams.plantTangmenCaltrop(_user, _targetTile);
		}
		return hit;
	}
});
