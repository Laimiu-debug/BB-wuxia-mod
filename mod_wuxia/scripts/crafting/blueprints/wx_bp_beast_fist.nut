this.wx_bp_beast_fist <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		::Wuxia.BeastCraft.initBlueprint(this, "wx_bp_beast_fist");
	}

	function onCraft( _stash )
	{
		::Wuxia.BeastCraft.craftBlueprintProduct("wx_bp_beast_fist", _stash);
	}
});
