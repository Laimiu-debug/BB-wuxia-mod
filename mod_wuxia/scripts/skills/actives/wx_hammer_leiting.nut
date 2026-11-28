// Active Move: 雷霆碎岳锤
this.wx_hammer_leiting <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_hammer_leiting";
		this.m.Name = "雷霆碎岳锤";
		this.m.Description = "万钧重兵破甲绝杀：消耗 6 AP 与 28 内息，挟风雷之威猛砸重铠（破甲伤害 +50%，并震荡目标内腑）。";
		this.m.Icon = "skills/wx_hammer_leiting.png";
		this.m.IconDisabled = "skills/wx_hammer_leiting_sw.png";
		this.m.Overlay = "wx_ov_wx_hammer_leiting";
		this.m.WX_VfxBrush <- "wx_vfx_14";
		this.m.WX_AnimID <- "wx_anim_29";
		this.m.WX_AnimMode <- "sky_thunder";
		this.m.WX_ChoreoID <- "wx_hammer_leiting";
		this.m.SoundOnUse = ["sounds/combat/shatter_01.wav", "sounds/combat/shatter_03.wav"];
		this.m.SoundOnHit = ["sounds/combat/shatter_hit_01.wav", "sounds/combat/bash_hit_02.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 28;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.IsDoingForwardMove = false;
		this.m.RequiredWeaponTypes = ["Hammer", "Mace"];
		this.m.DirectDamageMult = 0.38;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageArmorMult *= 1.50; _properties.DamageTotalMult *= 1.15;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury");
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			if ("CraftBridge" in ::Wuxia)
				::Wuxia.CraftBridge.applyBossCounterHit(_user, target, { CorrodeShell = 1, BreakPts = 2 });
			if (_targetTile != null && ("TileField" in ::Wuxia) && ::Wuxia.TileField.hasField(_targetTile, "thunder_pool") && ::Wuxia.hasMember(_targetTile, "hasNextTile"))
			{
				for (local d = 0; d < 6; d = ++d)
				{
					if (!_targetTile.hasNextTile(d)) continue;
					local adj = _targetTile.getNextTile(d);
					if (adj != null && adj.IsOccupiedByActor && adj.getEntity() != null && adj.getEntity().isAlive() && !_user.isAlliedWith(adj.getEntity()))
					{
						local ae = adj.getEntity();
						if (ae.getHitpoints() > 16) ae.setHitpoints(ae.getHitpoints() - 15);
						this.wxApplyStatusToTarget(ae, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
					}
				}
			}
		}
		return hit;
	}
});
