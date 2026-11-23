// Active Move: 孔雀翎绝杀
this.wx_throw_kongque <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_throw_kongque";
		this.m.Name = "孔雀翎绝杀";
		this.m.Description = "蜀中唐门镇派机括绝杀：消耗 5 AP 与 24 内息，金筒开处漫天七彩毫针攒射目标及相邻 2 敌（射艺 +14，穿甲 +20%，附破绽与奇毒）。";
		this.m.Icon = "skills/wx_throw_kongque.png";
		this.m.IconDisabled = "skills/wx_throw_kongque_sw.png";
		this.m.Overlay = "wx_ov_wx_throw_kongque";
		this.m.WX_VfxBrush <- "wx_vfx_27";
		this.m.WX_AnimID <- "wx_anim_170";
		this.m.WX_AnimMode <- "flurry_kongque";
		this.m.WX_ChoreoID <- "wx_throw_kongque";
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Kongqueling;
		this.m.IsProjectileRotated = true;
		this.m.ProjectileTimeScale = 1.25;
		this.m.SoundOnUse = ["sounds/combat/javelin_throw_01.wav", "sounds/combat/javelin_throw_02.wav"];
		this.m.IsAOE = true;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 24;
		this.m.MinRange = 2;
		this.m.MaxRange = 4;
		this.m.RequiredWeaponTypes = ["Throwing"];
		this.m.DirectDamageMult = 0.46;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 14; _properties.DamageDirectAdd += 0.20; _properties.DamageTotalMult *= 1.15;
		}
	}

	function onUse( _user, _targetTile )
	{
		local mainTarget = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local anyHit = false;
		if (mainTarget != null && mainTarget.isAlive())
		{
			if (this.wxThrowAt(_user, mainTarget))
			{
				anyHit = true;
				local target = mainTarget;
				if (target.isAlive()) { this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening"); this.wxApplyStatusToTarget(target, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart"); }
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
				::Wuxia.VFX.playAoESecondaryVfx(this, _user, adj, 55);
				if (this.attackEntity(_user, target))
				{
					anyHit = true;
					if (target.isAlive()) { this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening"); this.wxApplyStatusToTarget(target, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart"); }
				}
				extraCnt += 1;
				if (extraCnt >= 2) break;
			}
		}
		return anyHit;
	}
});
