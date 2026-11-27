// Hook scripts/factions/faction_manager: enforce 64 Faction ID engine safety guardrail

::Wuxia.HooksMod.hook("scripts/factions/faction_manager", function( q )
{
	if (::Wuxia.qHas(q, "getFaction"))
	{
		q.getFaction = @(__original) function( _i )
		{
			if (_i == null || _i < 0 || _i >= this.m.Factions.len())
				return null;
			return __original(_i);
		};
	}

	if (::Wuxia.qHas(q, "onDeserialize"))
	{
		q.onDeserialize = @(__original) function( _in )
		{
			local res = __original(_in);
			if (::Wuxia.hasWorldField("EntityManager") && ::Wuxia.hasMember(::World.EntityManager, "getSettlements"))
			{
				foreach (s in ::World.EntityManager.getSettlements())
				{
					if (s != null && s.isAlive())
					{
						if (::Wuxia.hasMember(s, "WX_EnsureDisguisePavilion"))
						{
							try { s.WX_EnsureDisguisePavilion(); } catch (_eW) {}
						}
						if (::Wuxia.hasMember(s, "WX_ApplyArchVisuals"))
						{
							try { s.WX_ApplyArchVisuals(false); } catch (_eS) {}
						}
					}
				}
			}
			return res;
		};
	}

	q.createFactions = @(__original) function()
	{
		if ("WorldVisuals" in ::Wuxia && "balanceWorldSettlementDistribution" in ::Wuxia.WorldVisuals)
		{
			try { ::Wuxia.WorldVisuals.balanceWorldSettlementDistribution(true); } catch (_eBal) {}
		}

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
