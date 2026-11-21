// Town Alchemy Blueprint: 2x 忘尘归元散 (Waives next manual switch/unequip scatter penalty)

this.wx_bp_pill_wangchen <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_wangchen");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_wangchen";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 260;
		this.init([
			{ Script = "scripts/items/misc/vampire_dust_item", Num = 1 },
			{ Script = "scripts/items/misc/spider_silk_item", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		for (local i = 0; i < 2; i = ++i)
			_stash.add(this.makePill());
	}
});
