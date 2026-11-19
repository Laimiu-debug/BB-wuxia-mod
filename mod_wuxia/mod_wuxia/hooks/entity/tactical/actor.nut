// Hook scripts/entity/tactical/actor: attach martial container & enforce 11 AP permanent hard cap

::Wuxia.HooksMod.hook("scripts/entity/tactical/actor", function( q )
{
	q.getActionPointsMax = @(__original) function()
	{
		local baseMax = __original();
		local container = this.getSkills().getSkillByID("special.wx_martial_container");
		if (container != null)
		{
			local bonus = container.getPermanentAPBonus();
			if (bonus > 0)
			{
				local cap = ::Wuxia.Config.Constants.MaxPermanentAP;
				return ::Math.min(cap, baseMax + bonus);
			}
		}
		return baseMax;
	};
});
