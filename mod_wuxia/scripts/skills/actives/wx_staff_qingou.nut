// Active Move: 天下无狗棒
this.wx_staff_qingou <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_staff_qingou";
		this.m.Name = "天下无狗棒";
		this.m.Description = "丐帮镇帮绝学总诀：消耗 6 AP 与 26 内息，竹棒幻化漫天青影横扫周身 3 敌（命中 +12，令群敌同陷失衡与破绽）。";
		this.m.Icon = "skills/wx_staff_qingou.png";
		this.m.IconDisabled = "skills/wx_staff_qingou_sw.png";
		this.m.Overlay = "wx_ov_wx_staff_qingou";
		this.m.WX_VfxBrush <- "wx_vfx_15";
		this.m.WX_AnimID <- "wx_anim_117";
		this.m.WX_AnimMode <- "flurry_qingou";
		this.m.WX_ChoreoID <- "wx_staff_qingou";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.IsAOE = true;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 26;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Staff"];
		this.m.DirectDamageMult = 0.32;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 12; _properties.DamageTotalMult *= 1.16;
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
				if (target.isAlive()) { this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance"); this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening"); }
			}
		}
		return anyHit;
	}
});
