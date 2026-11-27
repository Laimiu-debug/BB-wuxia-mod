// Active Move: 阿鼻修罗斩
this.wx_saber_abi <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_abi";
		this.m.Name = "阿鼻修罗斩";
		this.m.Description = "魔刀孤本灭世狂斩：消耗 6 AP 与 28 内息，阿鼻地狱血煞横扫身前 3 敌（总伤 +22%，每命中一敌汲取 6 点气血并震慑心胆）。";
		this.m.Icon = "skills/wx_saber_abi.png";
		this.m.IconDisabled = "skills/wx_saber_abi_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_abi";
		this.m.WX_VfxBrush <- "wx_vfx_06";
		this.m.WX_AnimID <- "wx_anim_88";
		this.m.WX_AnimMode <- "aoe_abi";
		this.m.WX_ChoreoID <- "wx_saber_abi";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.IsAOE = true;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 28;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber", "Sword"];
		this.m.DirectDamageMult = 0.32;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.DamageTotalMult *= 1.22; _properties.DamageArmorMult *= 1.20;
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
				if ("Streams" in ::Wuxia) ::Wuxia.Streams.triggerBloodBlade(_user, target);
				if (target.isAlive() && !::Wuxia.CombatRules.isUndeadOrConstruct(target))
					target.checkMorale(-1, -12);
			}
		}
		return anyHit;
	}
});
