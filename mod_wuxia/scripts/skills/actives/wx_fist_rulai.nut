// Active Move: 如来千手印
this.wx_fist_rulai <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_rulai";
		this.m.Name = "如来千手印";
		this.m.Description = "禅宗掌道至高孤本：消耗 6 AP 与 28 内息，幻化漫天金莲千手掌影轰击身前 3 敌（命中 +10，穿甲 +18%，震散敌手劲力）。";
		this.m.Icon = "skills/wx_fist_rulai.png";
		this.m.IconDisabled = "skills/wx_fist_rulai_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_rulai";
		this.m.WX_VfxBrush <- "wx_vfx_09";
		this.m.WX_AnimID <- "wx_anim_99";
		this.m.WX_AnimMode <- "sky_rulai";
		this.m.WX_ChoreoID <- "wx_fist_rulai";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.IsAOE = true;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 28;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.45;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10; _properties.DamageDirectAdd += 0.18; _properties.DamageTotalMult *= 1.20;
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
				if (target.isAlive()) { this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness"); }
			}
		}
		return anyHit;
	}
});
