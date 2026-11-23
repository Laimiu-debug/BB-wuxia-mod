// Town Alchemy Blueprint: 1x wx_pill_tihu

this.wx_bp_pill_tihu <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_tihu");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_tihu";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 780;
		this.init([
			{ Script = "scripts/items/misc/wx_herb_zizhi", Num = 1 },
			{ Script = "scripts/items/misc/witch_hair_item", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		_stash.add(this.makePill());
	}
});
