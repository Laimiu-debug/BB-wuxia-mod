// Town Alchemy Blueprint: 易筋锻骨丸 (+20% bonus for 0★ -> 1★ Marrow Wash star opening/replacement)

this.wx_bp_pill_yijin_wan <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_yijin_wan");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_yijin_wan";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 850;
		this.init([
			{ Script = "scripts/items/misc/unhold_heart_item", Num = 1 },
			{ Script = "scripts/items/misc/unhold_bones_item", Num = 1 },
			{ Script = "scripts/items/misc/glowing_resin_item", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		_stash.add(this.makePill());
	}
});
