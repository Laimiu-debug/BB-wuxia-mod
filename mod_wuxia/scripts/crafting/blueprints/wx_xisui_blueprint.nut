this.wx_xisui_blueprint <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_xisui");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_xisui";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 1800;
		this.init([
			{ Script = "scripts/items/misc/wx_marrow_herb", Num = 1 },
			{ Script = "scripts/items/misc/unhold_heart_item", Num = 1 },
			{ Script = "scripts/items/misc/lindwurm_bones_item", Num = 1 }
		]);
	}

	function onCraft( _stash ) { _stash.add(this.makePill()); }
});
