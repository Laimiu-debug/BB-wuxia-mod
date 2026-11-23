// Active Move: 九曜破城锤
this.wx_hammer_pocheng <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_hammer_pocheng";
		this.m.Name = "九曜破城锤";
		this.m.Description = "重锤孤本摧城绝杀：消耗 6 AP 与 30 内息，万钧流星锤轰塌护甲并震波及邻敌（破甲 +60%，穿甲 +15%，内伤）。";
		this.m.Icon = "skills/wx_hammer_pocheng.png";
		this.m.IconDisabled = "skills/wx_hammer_pocheng_sw.png";
		this.m.Overlay = "wx_ov_wx_hammer_pocheng";
		this.m.WX_VfxBrush <- "wx_vfx_05";
		this.m.WX_AnimID <- "wx_anim_122";
		this.m.WX_AnimMode <- "earth_pocheng";
		this.m.WX_ChoreoID <- "wx_hammer_pocheng";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.IsAOE = true;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 30;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Hammer"];
		this.m.DirectDamageMult = 0.45;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.DamageArmorMult *= 1.60; _properties.DamageDirectAdd += 0.15;
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
				if (target.isAlive()) { this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury"); }
			}
		}
		return anyHit;
	}
});
