// The engine clamps current AP to this getter on every skill refresh.

::Wuxia.HooksMod.hook("scripts/entity/tactical/actor", function( q )
{
	q.onAttackOfOpportunity = @(__original) function( _entity, _isOnEnter )
	{
		local c = this.getSkills().getSkillByID("special.wx_martial_container");
		if (c == null || c.m.CachedAggFlags == null || c.m.CachedAggFlags.ZoCBonusHit == 0)
			return __original(_entity, _isOnEnter);
		c.m.IsIntercepting = true;
		local hit;
		try { hit = __original(_entity, _isOnEnter); }
		catch (error) { c.m.IsIntercepting = false; throw error; }
		c.m.IsIntercepting = false;
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
});
