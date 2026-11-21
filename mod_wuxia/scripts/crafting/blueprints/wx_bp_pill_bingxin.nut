this.wx_bp_pill_bingxin <- this.inherit("scripts/crafting/blueprint", {
	function makePreview()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_bingxin");
		return pill;
	}
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_bingxin";
		this.m.PreviewCraftable = this.makePreview();
		this.m.Cost = 480;
		this.init([
			{ Script = "scripts/items/misc/wx_herb_xuelian", Num = 1 },
			{ Script = "scripts/items/misc/wx_herb_bingpocao", Num = 1 }
		]);
	}
	function onCraft( _stash )
	{
		for (local i = 0; i < 2; i = ++i)
		{
			local p = ::new("scripts/items/misc/wx_pill_item");
			p.initPill("wx_pill_bingxin");
			_stash.add(p);
		}
	}
});
