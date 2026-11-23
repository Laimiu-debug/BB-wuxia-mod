// Native Pathfinder writes directly to the actor's movement tables. A manual can be unlearned.
this.wx_manual_pathfinder <- this.inherit("scripts/skills/perks/perk_pathfinder", {
	m = { PreviousMovement = null },

	function onAdded()
	{
		local actor = this.getContainer().getActor();
		local hasActorM = (actor != null && ::Wuxia.hasMember(actor, "m") && actor.m != null && ::Wuxia.hasMember(actor.m, "LevelActionPointCost"));
		local origLevelCost = (hasActorM && ::Wuxia.hasMember(actor.m, "WX_OrigLevelAPCost"))
			? actor.m.WX_OrigLevelAPCost
			: (hasActorM ? actor.m.LevelActionPointCost : this.Const.Movement.LevelDifferenceActionPointCost);
		if (hasActorM && !::Wuxia.hasMember(actor.m, "WX_OrigLevelAPCost"))
			actor.m.WX_OrigLevelAPCost <- origLevelCost;
		local origAPCosts = hasActorM ? actor.m.ActionPointCosts : null;
		local origFatCosts = hasActorM ? actor.m.FatigueCosts : null;
		this.perk_pathfinder.onAdded();
		this.m.PreviousMovement = {
			ActionPointCosts = origAPCosts,
			FatigueCosts = origFatCosts,
			LevelActionPointCost = origLevelCost
		};
	}

	function onRemoved()
	{
		local actor = this.getContainer().getActor(), movement = this.m.PreviousMovement;
		if (movement != null)
		{
			actor.m.ActionPointCosts = movement.ActionPointCosts;
			actor.m.FatigueCosts = movement.FatigueCosts;
			actor.m.LevelActionPointCost = movement.LevelActionPointCost;
		}
		this.perk_pathfinder.onRemoved();
	}
});
