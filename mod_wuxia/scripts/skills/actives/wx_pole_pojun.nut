// Active Move: 破军龙骧戟
this.wx_pole_pojun <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_pole_pojun";
		this.m.Name = "破军龙骧戟";
		this.m.Description = "藩镇节度大戟绝杀：消耗 6 AP 与 26 内息，长戟横扫身前扇面 3 敌（破甲 +28%，总伤 +15%）。";
		this.m.Icon = "skills/wx_pole_pojun.png";
		this.m.IconDisabled = "skills/wx_pole_pojun_sw.png";
		this.m.Overlay = "wx_ov_wx_pole_pojun";
		this.m.WX_VfxBrush <- "wx_vfx_02";
		this.m.WX_AnimID <- "wx_anim_115";
		this.m.WX_AnimMode <- "aoe_pojun";
		this.m.WX_ChoreoID <- "wx_pole_pojun";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.IsAOE = true;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 26;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Polearm", "Spear"];
		this.m.DirectDamageMult = 0.30;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 7; _properties.DamageArmorMult *= 1.28; _properties.DamageTotalMult *= 1.15;
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
				if (target.isAlive()) {  }
			}
		}
		return anyHit;
	}
});
