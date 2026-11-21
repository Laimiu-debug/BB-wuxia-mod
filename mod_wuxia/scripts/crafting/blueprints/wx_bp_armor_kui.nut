this.wx_bp_armor_kui <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_armor_kui";
		this.m.PreviewCraftable = ::new("scripts/items/armor/named/wx_armor_kui");
		this.m.Cost = 2200;
		this.init([
			{ Script = "scripts/items/misc/wx_core_kui", Num = 1 },
			{ Script = "scripts/items/misc/unhold_hide_item", Num = 1 }
		]);
	}
	function onCraft( _stash ) { _stash.add(::new("scripts/items/armor/named/wx_armor_kui")); }
});
