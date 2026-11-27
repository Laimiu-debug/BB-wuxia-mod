// Sword Stream Flagship Move #2: 万剑归宗诀 (Hex-Line Convergence Recall of All Field `气剑残影`!)

this.wx_sword_wanjian <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_wanjian";
		this.m.Name = "万剑归宗诀";
		this.m.Description = "剑道无上孤本绝杀：消耗 6 AP 与 28 内息，剑气化虹攒刺 2 格内主目标及相邻 2 敌（命中 +12，穿甲 +16%）；同时号令场上所有己方【驻场气剑残影】沿六角格直线飞掠归宗，贯穿沿途敌阵并每剑回补 4 点内息！";
		this.m.Icon = "skills/wx_sword_wanjian.png";
		this.m.IconDisabled = "skills/wx_sword_wanjian_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_wanjian";
		this.m.WX_VfxBrush <- "wx_vfx_08";
		this.m.WX_AnimID <- "wx_anim_76";
		this.m.WX_AnimMode <- "flurry_wanjian";
		this.m.WX_ChoreoID <- "wx_sword_wanjian";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.IsAOE = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.MaxLevelDifference = 2;
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 28;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.36;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 12;
			_properties.DamageDirectAdd += 0.16;
			_properties.DamageTotalMult *= 1.16;
		}
	}

	function getTooltip()
	{
		local ret = this.wx_move_base.getTooltip();
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor != null && ("TileField" in ::Wuxia) && ::Wuxia.hasMember(actor, "getID"))
		{
			local cnt = ::Wuxia.TileField.getFieldsByKind("sword_node", actor.getID()).len();
			ret.push({
				id = 25,
				type = "text",
				icon = "ui/icons/special.png",
				text = "当前可召回【驻场气剑】：[color=#127896]" + cnt + " / 5 柄[/color]" + (cnt > 0 ? ("（施展即触发飞剑穿阵并回补 " + ::Math.min(16, cnt * 4) + " 内息！）") : "（先以连剑/两仪剑在场内布下气剑威能倍增）")
			});
		}
		return ret;
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
				if (target.isAlive())
					this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			}
		}

		// Recall all active `sword_node` constructs along hex lines!
		if ("Streams" in ::Wuxia)
		{
			local recRes = ::Wuxia.Streams.recallSwordNodes(_user, _targetTile);
			if (recRes.recalled > 0) anyHit = true;
		}
		return anyHit;
	}
});
