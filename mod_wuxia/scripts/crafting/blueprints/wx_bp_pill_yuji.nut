// Town Alchemy Blueprint: 2x 玉肌止血散 (Bleeding immunity + injury threshold + HP regen)

this.wx_bp_pill_yuji <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_yuji");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_yuji";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 240;
		this.init([
			{ Script = "scripts/items/misc/glowing_resin_item", Num = 1 },
			{ Script = "scripts/items/misc/werewolf_pelt_item", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		for (local i = 0; i < 2; i = ++i)
			_stash.add(this.makePill());
	}
});
