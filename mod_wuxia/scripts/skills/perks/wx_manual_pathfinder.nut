// Native Pathfinder writes directly to the actor's movement tables. A manual can be unlearned.
this.wx_manual_pathfinder <- this.inherit("scripts/skills/perks/perk_pathfinder", {
	m = { PreviousMovement = null },

	function onAdded()
	{
		this.perk_pathfinder.onAdded();
		local actor = this.getContainer().getActor();
		this.m.PreviousMovement = {
			ActionPointCosts = actor.m.ActionPointCosts,
			FatigueCosts = actor.m.FatigueCosts,
			LevelActionPointCost = actor.m.LevelActionPointCost
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
