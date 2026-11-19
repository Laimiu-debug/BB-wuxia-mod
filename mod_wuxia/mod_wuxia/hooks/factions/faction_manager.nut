// Hook scripts/factions/faction_manager: enforce 64 Faction ID engine safety guardrail

::Wuxia.HooksMod.hook("scripts/factions/faction_manager", function( q )
{
	q.createFactions = @(__original) function()
	{
		__original();

		local maxID = 0;
		foreach (f in this.m.Factions)
		{
			if (f != null && f.getID() > maxID)
			{
				maxID = f.getID();
			}
		}

		local limit = ::Wuxia.Config.Constants.MaxFactionIDSafeLimit;
		if (maxID >= limit)
		{
			::logError("[mod_wuxia] CRITICAL: Max Faction ID (" + maxID + ") reached/exceeded engine limit (" + limit + ")! Combat ZoC may break.");
		}
		else
		{
			::logInfo("[mod_wuxia] Faction ID check OK: maxID = " + maxID + " / " + limit + " (headroom: " + (limit - 1 - maxID) + ").");
		}
	};
});
