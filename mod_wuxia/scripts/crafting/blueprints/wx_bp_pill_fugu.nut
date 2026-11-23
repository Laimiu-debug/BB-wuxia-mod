// Town Alchemy Blueprint: 2x wx_pill_fugu

this.wx_bp_pill_fugu <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_fugu");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_fugu";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 360;
		this.init([
			{ Script = "scripts/items/misc/lindwurm_blood_item", Num = 1 },
			{ Script = "scripts/items/misc/wx_mat_gujing", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		for (local i = 0; i < 2; i = ++i)
			_stash.add(this.makePill());
	}
});
