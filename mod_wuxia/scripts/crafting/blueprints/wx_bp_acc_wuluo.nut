this.wx_bp_acc_wuluo <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_acc_wuluo";
		this.m.PreviewCraftable = ::new("scripts/items/accessory/wx_acc_wuluo");
		this.m.Cost = 1600;
		this.init([
			{ Script = "scripts/items/misc/wx_core_wuluo", Num = 1 },
			{ Script = "scripts/items/misc/spider_silk_item", Num = 1 }
		]);
	}
	function onCraft( _stash ) { _stash.add(::new("scripts/items/accessory/wx_acc_wuluo")); }
});
