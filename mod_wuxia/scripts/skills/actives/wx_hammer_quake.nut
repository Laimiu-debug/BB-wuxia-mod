// Secret Hammer Move: 裂地崩山锤 (6 AP, 24 Qi: +40% armor dmg, shockwaves adjacent enemies with Off-Balance & Qi drain)

this.wx_hammer_quake <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_hammer_quake";
		this.m.WX_VfxBrush <- "wx_vfx_05";
		this.m.WX_AnimID <- "wx_anim_10";
		this.m.WX_AnimMode <- "earth_wave";
		this.m.WX_ChoreoID <- "wx_hammer_quake";
		this.m.Name = "裂地崩山锤";
		this.m.Description = "双臂贯注内力轰击重锤：破甲伤害提升 40%，命中后地裂余波震荡目标周遭紧邻敌军，令其全数陷入「失衡」并散气 10 点！";
		this.m.KilledString = "重锤轰成肉泥";
		this.m.Icon = "skills/wx_hammer_quake.png";
		this.m.IconDisabled = "skills/wx_hammer_quake_sw.png";
		this.m.Overlay = "wx_ov_wx_hammer_quake";
		this.m.SoundOnUse = [
			"sounds/combat/shatter_01.wav",
			"sounds/combat/shatter_02.wav",
			"sounds/combat/shatter_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/shatter_hit_01.wav",
			"sounds/combat/shatter_hit_02.wav",
			"sounds/combat/shatter_hit_03.wav"
		];
		this.m.IsAOE = true;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 24;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.InjuriesOnBody = this.Const.Injury.BluntBody;
		this.m.InjuriesOnHead = this.Const.Injury.BluntHead;
		this.m.RequiredWeaponTypes = ["Hammer"];
		this.m.DirectDamageMult = 0.50;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageArmorMult *= 1.40;
			_properties.DamageMinimum += 12;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit)
		{
			if (target != null && target.isAlive())
			{
				this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
			for (local d = 0; d < this.Const.Direction.COUNT; ++d)
			{
				if (!_targetTile.hasNextTile(d)) continue;
				local adj = _targetTile.getNextTile(d);
				if (!adj.IsOccupiedByActor) continue;
				local ent = adj.getEntity();
				if (ent == null || !ent.isAlive() || _user.isAlliedWith(ent)) continue;
				this.wxApplyStatusToTarget(ent, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(ent))
				{
					ent.setFatigue(::Math.min(ent.getFatigueMax(), ent.getFatigue() + 10));
				}
			}
		}
		return hit;
	}
});
