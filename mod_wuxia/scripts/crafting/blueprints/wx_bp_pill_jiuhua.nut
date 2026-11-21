this.wx_bp_pill_jiuhua <- this.inherit("scripts/crafting/blueprint", {
	function makePreview()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_jiuhua");
		return pill;
	}
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_jiuhua";
		this.m.PreviewCraftable = this.makePreview();
		this.m.Cost = 450;
		this.init([
			{ Script = "scripts/items/misc/wx_herb_xuncao", Num = 1 },
			{ Script = "scripts/items/misc/wx_herb_migu", Num = 1 }
		]);
	}
	function onCraft( _stash )
	{
		for (local i = 0; i < 2; i = ++i)
		{
			local p = ::new("scripts/items/misc/wx_pill_item");
			p.initPill("wx_pill_jiuhua");
			_stash.add(p);
		}
	}
});
