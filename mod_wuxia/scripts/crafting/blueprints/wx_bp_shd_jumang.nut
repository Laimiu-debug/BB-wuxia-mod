this.wx_bp_shd_jumang <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_shd_jumang";
		this.m.PreviewCraftable = ::new("scripts/items/shields/named/wx_shd_jumang");
		this.m.Cost = 1900;
		this.init([
			{ Script = "scripts/items/misc/wx_core_jumang", Num = 1 },
			{ Script = "scripts/items/misc/glowing_resin_item", Num = 1 }
		]);
	}
	function onCraft( _stash ) { _stash.add(::new("scripts/items/shields/named/wx_shd_jumang")); }
});
