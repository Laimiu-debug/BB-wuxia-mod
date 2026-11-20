// Secret Saber/Cleaver AOE Move: 八方狂澜斩 (6 AP, 24 Qi: sweeps target + adjacent front-arc enemies, +15% armor dmg)

this.wx_saber_sweep <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_sweep";
		this.m.Name = "八方狂澜斩";
		this.m.Description = "催动狂猛刀气横扫身前扇面（主目标及两侧紧邻敌军最多 3 人）：破甲伤害 +15%，命中令敌陷入「失衡」。";
		this.m.KilledString = "拦腰斩断";
		this.m.Icon = "skills/active_08.png";
		this.m.IconDisabled = "skills/active_08_sw.png";
		this.m.Overlay = "active_08";
		this.m.SoundOnUse = [
			"sounds/combat/cleave_01.wav",
			"sounds/combat/cleave_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/cleave_hit_hitpoints_01.wav"
		];
		this.m.IsAOE = true;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 24;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber"];
		this.m.DirectDamageMult = 0.25;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageArmorMult *= 1.15;
		}
	}

	function onUse( _user, _targetTile )
	{
		local targets = [];
		local mainTarget = _targetTile.getEntity();
		if (mainTarget != null) targets.push(mainTarget);

		local myTile = _user.getTile();
		for (local d = 0; d < this.Const.Direction.COUNT; ++d)
		{
			if (!_targetTile.hasNextTile(d)) continue;
			local adj = _targetTile.getNextTile(d);
			if (adj.getDistanceTo(myTile) != 1 || !adj.IsOccupiedByActor) continue;
			local ent = adj.getEntity();
			if (ent != null && ent.isAlive() && !_user.isAlliedWith(ent))
			{
				targets.push(ent);
				if (targets.len() >= 3) break;
			}
		}

		local anyHit = false;
		foreach (t in targets)
		{
			if (!t.isAlive()) continue;
			local hit = this.attackEntity(_user, t);
			if (hit)
			{
				anyHit = true;
				if (t.isAlive())
				{
					this.wxApplyStatusToTarget(t, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
				}
			}
		}
		return anyHit;
	}
});
