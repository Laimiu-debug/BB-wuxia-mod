this.wx_bp_pill_zijin <- this.inherit("scripts/crafting/blueprint", {
	function makePreview()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_zijin");
		return pill;
	}
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_zijin";
		this.m.PreviewCraftable = this.makePreview();
		this.m.Cost = 900;
		this.init([
			{ Script = "scripts/items/misc/wx_herb_zizhi", Num = 1 },
			{ Script = "scripts/items/misc/wx_herb_huolingzhi", Num = 1 }
		]);
	}
	function onCraft( _stash )
	{
		local p = ::new("scripts/items/misc/wx_pill_item");
		p.initPill("wx_pill_zijin");
		_stash.add(p);
	}
});
