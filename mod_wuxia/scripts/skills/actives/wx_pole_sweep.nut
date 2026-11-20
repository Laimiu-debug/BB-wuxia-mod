// Sect/Secret Polearm & Staff AOE Move: 横扫千军 (6 AP, 22 Qi, range 1-2: sweeps target + adjacent enemy in reach, inflicts Off-Balance)

this.wx_pole_sweep <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_pole_sweep";
		this.m.Name = "横扫千军";
		this.m.Description = "双手抡起长兵或齐眉重棍横扫 1~2 格弧面（主目标及紧邻敌军最多 3 人）：命中令群敌陷入「失衡」，专破人海合围。";
		this.m.KilledString = "长杆扫碎脑门";
		this.m.Icon = "skills/active_45.png";
		this.m.IconDisabled = "skills/active_45_sw.png";
		this.m.Overlay = "active_45";
		this.m.SoundOnUse = [
			"sounds/combat/slash_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/slash_hit_02.wav"
		];
		this.m.IsAOE = true;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 22;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Polearm", "Spear", "Staff"];
		this.m.DirectDamageMult = 0.25;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 5;
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
			local dist = adj.getDistanceTo(myTile);
			if (dist < 1 || dist > 2 || !adj.IsOccupiedByActor) continue;
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
