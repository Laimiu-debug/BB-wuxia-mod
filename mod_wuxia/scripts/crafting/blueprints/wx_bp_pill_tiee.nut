// Town Alchemy Blueprint: 2x wx_pill_tiee

this.wx_bp_pill_tiee <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_tiee");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_tiee";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 280;
		this.init([
			{ Script = "scripts/items/misc/wx_mat_xuanlin", Num = 1 },
			{ Script = "scripts/items/misc/unhold_hide_item", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		for (local i = 0; i < 2; i = ++i)
			_stash.add(this.makePill());
	}
});
