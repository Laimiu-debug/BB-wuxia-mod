// Active Move: 大荒落日箭
this.wx_bow_luori <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_bow_luori";
		this.m.Name = "大荒落日箭";
		this.m.Description = "神射孤本旷世绝学：消耗 6 AP 与 26 内息，满挽雕弓一矢贯日（射程 2~8 格，射艺 +14，穿甲 +22%，总伤 +25%）。";
		this.m.Icon = "skills/wx_bow_luori.png";
		this.m.IconDisabled = "skills/wx_bow_luori_sw.png";
		this.m.Overlay = "wx_ov_wx_bow_luori";
		this.m.WX_VfxBrush <- "wx_vfx_02";
		this.m.WX_AnimID <- "wx_anim_137";
		this.m.WX_AnimMode <- "pierce_luori";
		this.m.WX_ChoreoID <- "wx_bow_luori";
		this.m.IsRanged = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Liuxingjian;
		this.m.IsProjectileRotated = true;
		this.m.ProjectileTimeScale = 1.25;
		this.m.SoundOnUse = ["sounds/combat/quick_shot_01.wav", "sounds/combat/quick_shot_02.wav", "sounds/combat/quick_shot_03.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 26;
		this.m.MinRange = 2;
		this.m.MaxRange = 8;
		this.m.MaxLevelDifference = 4;
		this.m.RequiredWeaponTypes = ["Bow", "Crossbow"];
		this.m.DirectDamageMult = 0.50;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			_properties.RangedSkill += 14;
			if ("Streams" in ::Wuxia) ::Wuxia.Streams.addCappedPen(_properties, 0.22);
			_properties.DamageTotalMult *= 1.25;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.wxShootBowAt(_user, target);
		if (hit)
		{
			if (target != null && target.isAlive())
				this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury");
			if (_targetTile != null && ("TileField" in ::Wuxia))
				::Wuxia.TileField.setField(_targetTile, "drought_scorch", 2, _user);
		}
		this.wxTriggerTagPostMechanic(_user, target, _targetTile, hit);
		return hit;
	}
});
