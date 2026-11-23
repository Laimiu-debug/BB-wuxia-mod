// Active Move: 八荒六合斩
this.wx_saber_kuanglan <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_kuanglan";
		this.m.Name = "八荒六合斩";
		this.m.Description = "中原金刀宗师绝学：消耗 6 AP 与 26 内息，金刀霸气横扫身前 3 敌（命中 +8，总伤 +15%，并留破绽）。";
		this.m.Icon = "skills/wx_saber_kuanglan.png";
		this.m.IconDisabled = "skills/wx_saber_kuanglan_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_kuanglan";
		this.m.WX_VfxBrush <- "wx_vfx_24";
		this.m.WX_AnimID <- "wx_anim_92";
		this.m.WX_AnimMode <- "aoe_kuanglan";
		this.m.WX_ChoreoID <- "wx_saber_kuanglan";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.IsAOE = true;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 26;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber", "Sword"];
		this.m.DirectDamageMult = 0.28;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.DamageTotalMult *= 1.15;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local targets = [];
		local mainTarget = _targetTile.getEntity();
		if (mainTarget != null) targets.push(mainTarget);
		local myTile = _user.getTile();
		for (local d = 0; d < this.Const.Direction.COUNT; d = ++d)
		{
			if (!_targetTile.hasNextTile(d)) continue;
			local adj = _targetTile.getNextTile(d);
			if (!adj.IsOccupiedByActor || adj.getDistanceTo(myTile) > this.m.MaxRange) continue;
			local ent = adj.getEntity();
			if (ent != null && ent.isAlive() && !_user.isAlliedWith(ent))
			{
				targets.push(ent);
				if (targets.len() >= 3) break;
			}
		}
		local anyHit = false;
		foreach (target in targets)
		{
			if (!target.isAlive()) continue;
			if (mainTarget == null || target.getID() != mainTarget.getID())
				::Wuxia.VFX.playAoESecondaryVfx(this, _user, target.getTile(), 55);
			local hit = this.attackEntity(_user, target);
			if (hit)
			{
				anyHit = true;
				if (target.isAlive()) { this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening"); }
			}
		}
		return anyHit;
	}
});
