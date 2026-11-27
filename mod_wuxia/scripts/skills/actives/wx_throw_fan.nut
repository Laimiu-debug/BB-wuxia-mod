// Secret Throwing Move: 漫天花雨 (5 AP, 20 Qi, range 2-3: fans darts onto target + up to 2 adjacent enemies, leaves Opening)

this.wx_throw_fan <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_throw_fan";
		this.m.WX_VfxBrush <- "wx_vfx_27";
		this.m.WX_AnimID <- "wx_anim_66";
		this.m.WX_AnimMode <- "fan_knives7";
		this.m.WX_ChoreoID <- "wx_throw_fan";
		this.m.Name = "漫天花雨";
		this.m.Description = "十指齐弹将暗器化作扇面花雨洒向目标及其身旁紧邻敌军（最多 3 人）：命中 +8，中招者尽皆露出「破绽」！";
		this.m.KilledString = "漫天飞镖穿身";
		this.m.Icon = "skills/wx_throw_fan.png";
		this.m.IconDisabled = "skills/wx_throw_fan_sw.png";
		this.m.Overlay = "wx_ov_wx_throw_fan";
		this.m.SoundOnUse = [
			"sounds/combat/javelin_throw_01.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/javelin_hit_01.wav"
		];
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = true;
		this.m.ProjectileType = ::Const.ProjectileType.WX_Liuyefeidao;
		this.m.IsProjectileRotated = true;
		this.m.ProjectileTimeScale = 1.25;
		this.m.IsAOE = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.IsDoingForwardMove = false;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 3;
		this.m.MaxLevelDifference = 4;
		this.m.RequiredWeaponTypes = ["Throwing"];
		this.m.DirectDamageMult = 0.40;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 8;
			_properties.DamageTotalMult *= 0.85;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local mainTarget = _targetTile.getEntity();
		local anyHit = false;
		if (mainTarget != null)
		{
			local h0 = this.wxThrowAt(_user, mainTarget);
			if (h0)
			{
				anyHit = true;
				if (mainTarget.isAlive())
					this.wxApplyStatusToTarget(mainTarget, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			}
		};
			local extraCount = 0;
		for (local d = 0; d < this.Const.Direction.COUNT; ++d)
		{
			if (!_targetTile.hasNextTile(d)) continue;
			local adj = _targetTile.getNextTile(d);
			if (!adj.IsOccupiedByActor) continue;
			local ent = adj.getEntity();
			if (ent == null || !ent.isAlive() || _user.isAlliedWith(ent)) continue;
			::Wuxia.VFX.playAoESecondaryVfx(this, _user, adj, 70 + extraCount * 45);
			local h = this.attackEntity(_user, ent);
			if (h)
			{
				anyHit = true;
				if (ent.isAlive())
					this.wxApplyStatusToTarget(ent, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			}
			extraCount += 1;
			if (extraCount >= 2) break;
		}
		if ("Streams" in ::Wuxia)
			::Wuxia.Streams.recallTangmenCaltrops(_user, _targetTile);
		this.wxTriggerTagPostMechanic(_user, mainTarget, _targetTile, anyHit);
		return anyHit;
	}
});
