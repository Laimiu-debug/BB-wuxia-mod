this.wx_bp_pill_shennong <- this.inherit("scripts/crafting/blueprint", {
	function makePreview()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_shennong");
		return pill;
	}
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_shennong";
		this.m.PreviewCraftable = this.makePreview();
		this.m.Cost = 850;
		this.init([
			{ Script = "scripts/items/misc/wx_herb_xuelian", Num = 1 },
			{ Script = "scripts/items/misc/wx_herb_heshouwu", Num = 1 },
			{ Script = "scripts/items/misc/wx_herb_zhuyu", Num = 1 }
		]);
	}
	function onCraft( _stash )
	{
		local p = ::new("scripts/items/misc/wx_pill_item");
		p.initPill("wx_pill_shennong");
		_stash.add(p);
	}
});
