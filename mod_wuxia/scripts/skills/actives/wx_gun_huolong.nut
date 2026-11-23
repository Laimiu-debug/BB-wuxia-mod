// Active Move: 神机火龙炮
this.wx_gun_huolong <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_gun_huolong";
		this.m.Name = "神机火龙炮";
		this.m.Description = "神机营镇营重火器绝学：消耗 6 AP 与 26 内息，火龙出水般轰穿敌阵目标及周遭群敌（总伤 +20%，破甲 +35%，散劲虚弱）。";
		this.m.Icon = "skills/wx_gun_huolong.png";
		this.m.IconDisabled = "skills/wx_gun_huolong_sw.png";
		this.m.Overlay = "wx_ov_wx_gun_huolong";
		this.m.WX_VfxBrush <- "wx_vfx_29";
		this.m.WX_AnimID <- "wx_anim_142";
		this.m.WX_AnimMode <- "earth_huolong";
		this.m.WX_ChoreoID <- "wx_gun_huolong";
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Huochongdan;
		this.m.IsProjectileRotated = true;
		this.m.ProjectileTimeScale = 1.25;
		this.m.SoundOnUse = ::Const.DLC.Desert ? ["sounds/combat/dlc6/fire_gonne_01.wav"] : ["sounds/combat/bolt_shot_01.wav"];
		this.m.IsAOE = true;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 26;
		this.m.MinRange = 2;
		this.m.MaxRange = 5;
		this.m.RequiredWeaponTypes = ["Firearm", "Crossbow"];
		this.m.DirectDamageMult = 0.42;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 12; _properties.DamageTotalMult *= 1.20; _properties.DamageArmorMult *= 1.35;
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
				if (target.isAlive()) { this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness"); if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.checkMorale(-1, -15); }
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
					if (target.isAlive()) { this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness"); if (!::Wuxia.CombatRules.isUndeadOrConstruct(target)) target.checkMorale(-1, -15); }
				}
				extraCnt += 1;
				if (extraCnt >= 2) break;
			}
		}
		return anyHit;
	}
});
