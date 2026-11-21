this.wx_bp_pill_zaohua <- this.inherit("scripts/crafting/blueprint", {
	function makePreview()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_zaohua");
		return pill;
	}
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_zaohua";
		this.m.PreviewCraftable = this.makePreview();
		this.m.Cost = 950;
		this.init([
			{ Script = "scripts/items/misc/wx_herb_shatang", Num = 1 },
			{ Script = "scripts/items/misc/wx_herb_bili", Num = 1 },
			{ Script = "scripts/items/misc/unhold_heart_item", Num = 1 }
		]);
	}
	function onCraft( _stash )
	{
		local p = ::new("scripts/items/misc/wx_pill_item");
		p.initPill("wx_pill_zaohua");
		_stash.add(p);
	}
});
