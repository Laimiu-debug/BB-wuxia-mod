// Town Alchemy Blueprint: 生生造化丹 (Cures 1 permanent 经脉暗疾)

this.wx_bp_pill_shengsheng <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_shengsheng");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_shengsheng";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 1100;
		this.init([
			{ Script = "scripts/items/misc/heart_of_the_forest_item", Num = 1 },
			{ Script = "scripts/items/misc/unhold_heart_item", Num = 1 },
			{ Script = "scripts/items/misc/glowing_resin_item", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		_stash.add(this.makePill());
	}
});
