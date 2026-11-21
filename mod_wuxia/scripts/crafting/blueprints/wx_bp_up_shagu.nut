this.wx_bp_up_shagu <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		::Wuxia.BeastCraft.initBlueprint(this, "wx_bp_up_shagu");
	}

	function onCraft( _stash )
	{
		::Wuxia.BeastCraft.craftBlueprintProduct("wx_bp_up_shagu", _stash);
	}
});
