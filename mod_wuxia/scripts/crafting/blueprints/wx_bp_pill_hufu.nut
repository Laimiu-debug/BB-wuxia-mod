// Town Alchemy Blueprint: 2x wx_pill_hufu

this.wx_bp_pill_hufu <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_hufu");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_hufu";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 260;
		this.init([
			{ Script = "scripts/items/misc/wx_mat_renjin", Num = 1 },
			{ Script = "scripts/items/misc/ghoul_teeth_item", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		for (local i = 0; i < 2; i = ++i)
			_stash.add(this.makePill());
	}
});
