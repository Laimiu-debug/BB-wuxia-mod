this.wx_bp_beast_bow <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		::Wuxia.BeastCraft.initBlueprint(this, "wx_bp_beast_bow");
	}

	function onCraft( _stash )
	{
		::Wuxia.BeastCraft.craftBlueprintProduct("wx_bp_beast_bow", _stash);
	}
});
