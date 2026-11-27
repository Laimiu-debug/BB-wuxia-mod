// Active Move: 沙州雷火铳
this.wx_gun_leihuo <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_gun_leihuo";
		this.m.Name = "沙州雷火铳";
		this.m.Description = "边军神机三眼火铳轰击：消耗 5 AP 与 20 内息，近中距喷射赤焰铅砂轰击目标及相邻 2 敌（破甲 +25%，剧烈震慑定力）。";
		this.m.Icon = "skills/wx_gun_leihuo.png";
		this.m.IconDisabled = "skills/wx_gun_leihuo_sw.png";
		this.m.Overlay = "wx_ov_wx_gun_leihuo";
		this.m.WX_VfxBrush <- "wx_vfx_29";
		this.m.WX_AnimID <- "wx_anim_141";
		this.m.WX_AnimMode <- "aoe_leihuo";
		this.m.WX_ChoreoID <- "wx_gun_leihuo";
		this.m.IsRanged = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Huochongdan;
		this.m.IsProjectileRotated = true;
		this.m.ProjectileTimeScale = 1.25;
		this.m.SoundOnUse = ::Const.DLC.Desert ? ["sounds/combat/dlc6/fire_hit_05.wav", "sounds/combat/dlc6/fire_gonne_hit_03.wav"] : ["sounds/combat/shatter_hit_02.wav"];
		this.m.IsAOE = true;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 2;
		this.m.MaxRange = 4;
		this.m.MaxLevelDifference = 4;
		this.m.RequiredWeaponTypes = ["Firearm", "Crossbow"];
		this.m.DirectDamageMult = 0.38;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 10; _properties.DamageArmorMult *= 1.25;
		}
	}

	function onUse( _user, _targetTile )
	{
		local mainTarget = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local anyHit = false;
		if (mainTarget != null && mainTarget.isAlive())
		{
			local h0 = this.wxShootBowAt(_user, mainTarget);
			if (h0)
			{
				anyHit = true;
				local target = mainTarget;
				if (target.isAlive()) { this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance"); if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.checkMorale(-1, -12); }
			}
		}
		local extraCnt = 0;
		for (local d = 0; d < this.Const.Direction.COUNT; d = ++d)
		{
			if (!_targetTile.hasNextTile(d)) continue;
			local adj = _targetTile.getNextTile(d);
			if (!adj.IsOccupiedByActor) continue;
			local target = adj.getEntity();
			if (target != null && target.isAlive() && !_user.isAlliedWith(target))
			{
				::Wuxia.VFX.playAoESecondaryVfx(this, _user, adj, 60);
				if (this.attackEntity(_user, target))
				{
					anyHit = true;
					if (target.isAlive()) { this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance"); if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.checkMorale(-1, -12); }
				}
				extraCnt += 1;
				if (extraCnt >= 2) break;
			}
		}
		if (anyHit && _targetTile != null && ("TileField" in ::Wuxia))
			::Wuxia.TileField.setField(_targetTile, "drought_scorch", 2, _user);
		return anyHit;
	}
});
