this.wx_bp_acc_baize <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_acc_baize";
		this.m.PreviewCraftable = ::new("scripts/items/accessory/wx_acc_baize");
		this.m.Cost = 1600;
		this.init([
			{ Script = "scripts/items/misc/wx_core_baize", Num = 1 },
			{ Script = "scripts/items/misc/wx_herb_migu", Num = 1 }
		]);
	}
	function onCraft( _stash ) { _stash.add(::new("scripts/items/accessory/wx_acc_baize")); }
});
