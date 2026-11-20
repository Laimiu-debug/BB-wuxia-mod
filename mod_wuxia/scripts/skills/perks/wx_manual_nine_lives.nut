// Wrapper around vanilla perk_nine_lives so actor.onDamageReceived lethal-hit interception works natively.
// Upgrades at Tier 2 (clears Wuxia dart poison & off-balance) and Tier 3 (restores +8 HP and +10 Qi on trigger).

this.wx_manual_nine_lives <- this.inherit("scripts/skills/perks/perk_nine_lives", {
	m = {},

	function setSpent( _f )
	{
		local wasSpent = this.m.IsSpent;
		this.perk_nine_lives.setSpent(_f);

		if (_f && !wasSpent)
		{
			local container = this.getContainer();
			if (container == null) return;
			local actor = container.getActor();
			local c = container.getSkillByID("special.wx_martial_container");
			local tier = (c != null && c.m.CachedAggFlags != null) ? c.m.CachedAggFlags.GuixiTier : 1;

			if (tier >= 2)
			{
				container.removeByID("effects.wx_status_poison_dart");
				container.removeByID("effects.wx_status_offbalance");
			}
			if (tier >= 3 && actor != null && actor.isAlive())
			{
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + 8));
				::Wuxia.CombatRules.restoreQi(actor, 10);
			}
		}
	}
});
