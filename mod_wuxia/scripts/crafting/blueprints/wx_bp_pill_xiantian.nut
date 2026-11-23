// Town Alchemy Blueprint: 2x wx_pill_xiantian

this.wx_bp_pill_xiantian <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_xiantian");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_xiantian";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 440;
		this.init([
			{ Script = "scripts/items/misc/wx_herb_bingpocao", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_xuanlin", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		for (local i = 0; i < 2; i = ++i)
			_stash.add(this.makePill());
	}
});
