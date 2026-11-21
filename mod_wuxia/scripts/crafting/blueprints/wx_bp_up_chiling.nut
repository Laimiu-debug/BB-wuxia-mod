this.wx_bp_up_chiling <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		::Wuxia.BeastCraft.initBlueprint(this, "wx_bp_up_chiling");
	}

	function onCraft( _stash )
	{
		::Wuxia.BeastCraft.craftBlueprintProduct("wx_bp_up_chiling", _stash);
	}
});
