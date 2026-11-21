// Town Alchemy Blueprint: 太乙紫金洗髓丹 (+12% Marrow Wash chance & avoids heavy meridian shock)

this.wx_bp_pill_zijin_xisui <- this.inherit("scripts/crafting/blueprint", {
	function makePill()
	{
		local pill = ::new("scripts/items/misc/wx_pill_item");
		pill.initPill("wx_pill_zijin_xisui");
		return pill;
	}

	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_pill_zijin_xisui";
		this.m.PreviewCraftable = this.makePill();
		this.m.Cost = 2400;
		this.init([
			{ Script = "scripts/items/misc/wx_core_yinglong", Num = 1 },
			{ Script = "scripts/items/misc/wx_marrow_herb", Num = 1 },
			{ Script = "scripts/items/misc/lindwurm_bones_item", Num = 1 }
		]);
	}

	function onCraft( _stash )
	{
		_stash.add(this.makePill());
	}
});
