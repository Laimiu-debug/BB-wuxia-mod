this.wx_bp_beast_armor_med <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		::Wuxia.BeastCraft.initBlueprint(this, "wx_bp_beast_armor_med");
	}

	function onCraft( _stash )
	{
		::Wuxia.BeastCraft.craftBlueprintProduct("wx_bp_beast_armor_med", _stash);
	}
});
