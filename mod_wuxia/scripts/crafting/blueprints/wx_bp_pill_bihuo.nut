// Town Alchemy Blueprint: 2x 玄冰辟火丸 (ShanHai fire/miasma aura immunity)

this.wx_bp_pill_bihuo <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_bihuo");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_bihuo";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 260;
		this.init([
			{ Script = "scripts/items/misc/serpent_skin_item", Num = 1 },
			{ Script = "scripts/items/misc/glistening_scales_item", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		for (local i = 0; i < 2; i = ++i)
			_stash.add(this.makePill());
	}
});
