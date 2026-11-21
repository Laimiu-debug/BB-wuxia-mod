// The engine clamps current AP to this getter on every skill refresh.

::Wuxia.HooksMod.hook("scripts/entity/tactical/actor", function( q )
{
	q.onAttackOfOpportunity = @(__original) function( _entity, _isOnEnter )
	{
		local c = this.getSkills().getSkillByID("special.wx_martial_container");
		this.m.WX_IsIntercepting <- true;
		if (c != null) c.m.IsIntercepting = true;
		local hit;
		try { hit = __original(_entity, _isOnEnter); }
		catch (error)
		{
			this.m.WX_IsIntercepting = false;
			if (c != null) c.m.IsIntercepting = false;
			throw error;
		}
		this.m.WX_IsIntercepting = false;
		if (c != null) c.m.IsIntercepting = false;
		return hit;
	};

	q.getActionPointsMax = @(__original) function()
	{
		local baseMax = __original();
		local skills = this.getSkills();
		local container = skills == null ? null : skills.getSkillByID("special.wx_martial_container");
		if (container == null) return baseMax;
		return ::Math.min(::Wuxia.Config.Constants.MaxPermanentAP, baseMax + container.getPermanentAPBonus()) + container.m.TemporaryAPOverflow;
	};

	q.onDeath = @(__original) function( _killer, _skill, _tile, _fatalityType )
	{
		local isHandled = ("WX_DeathHandled" in this.m) && this.m.WX_DeathHandled;
		local wxSnap = isHandled ? null : ::Wuxia.Appearance.captureDeathLayers(this);
		local canDropBeast = (!this.isPlayerControlled() && _tile != null && _killer != null && _killer.isPlayerControlled() && !this.isAlliedWith(_killer));
		if (!isHandled && wxSnap != null)
			::Wuxia.Appearance.restoreVanillaBrushesForDeath(this);
		__original(_killer, _skill, _tile, _fatalityType);
		if (!isHandled && wxSnap != null)
			::Wuxia.Appearance.applyWuxiaCorpseDecals(this, _tile, _fatalityType, wxSnap);
		if (canDropBeast && ("ShanHai" in ::Wuxia) && ("tryDropWildBeastLoot" in ::Wuxia.ShanHai))
			::Wuxia.ShanHai.tryDropWildBeastLoot(this, _tile);
		if (canDropBeast && ("BeastCraft" in ::Wuxia))
			::Wuxia.BeastCraft.tryDropWildBeastMaterial(this, _killer, _tile);
	};

	q.getTooltip = @(__original) function( _targetedWithSkill = null )
	{
		local ret = __original(_targetedWithSkill);
		if (ret == null || typeof ret != "array") return ret;
		local skills = this.getSkills();
		if (skills == null) return ret;

		local shTrait = skills.getSkillByID("special.wx_shanhai_boss_trait");
		if (shTrait != null)
		{
			ret.push({
				id = 97,
				type = "text",
				icon = "ui/perks/wx_shanhai_boss_trait.png",
				text = "[color=#e6b447]【山海凶威】" + shTrait.getName() + "[/color]"
			});
		}

		local c = skills.getSkillByID("special.wx_martial_container");
		if (c != null)
		{
			local cnt = 0;
			for (local i = 0; i < c.m.Slots.len(); i = ++i)
			{
				if (c.m.Slots[i].ManualID != null && c.m.Slots[i].Tier > 0) cnt += 1;
			}
			if (cnt > 0)
			{
				local elTxt = "外家把式";
				if (c.m.Slots[0].ManualID != null)
				{
					local mdef = ::Wuxia.Slots.getManualDef(c.m.Slots[0].ManualID);
					if (mdef != null && mdef.Element != null && (mdef.Element in ::Wuxia.Text.Elements))
						elTxt = ::Wuxia.Text.Elements[mdef.Element] + "内息";
				}
				local apBonus = c.getPermanentAPBonus();
				local apNote = apBonus > 0 ? (" · 破境 " + (9 + apBonus) + " AP") : "";
				ret.push({
					id = 96,
					type = "text",
					icon = "ui/wx_icons/wx_icon_qi.png",
					text = "[color=#8ed1c8]【武学气象】" + elTxt + " · 身怀 " + cnt + " 门功法" + apNote + "[/color]"
				});
			}
		}
		return ret;
	};
});
