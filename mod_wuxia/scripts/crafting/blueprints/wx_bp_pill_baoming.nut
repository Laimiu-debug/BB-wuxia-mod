// Town Alchemy Blueprint: 1x wx_pill_baoming

this.wx_bp_pill_baoming <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_baoming");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_baoming";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 750;
		this.init([
			{ Script = "scripts/items/misc/heart_of_the_forest_item", Num = 1 },
			{ Script = "scripts/items/misc/wx_herb_heshouwu", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		_stash.add(this.makePill());
	}
});
