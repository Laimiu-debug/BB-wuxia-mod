// Town Alchemy Blueprint: 2x 疯魔燃血丸 (Berserk headshot/armor-pen elixir with post-battle light injury)

this.wx_bp_pill_fengmo <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_fengmo");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_fengmo";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 380;
		this.init([
			{ Script = "scripts/items/misc/lindwurm_blood_item", Num = 1 },
			{ Script = "scripts/items/misc/ghoul_horn_item", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		for (local i = 0; i < 2; i = ++i)
			_stash.add(this.makePill());
	}
});
