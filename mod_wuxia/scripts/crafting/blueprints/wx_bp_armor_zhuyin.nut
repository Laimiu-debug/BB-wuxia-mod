this.wx_bp_armor_zhuyin <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_armor_zhuyin";
		this.m.PreviewCraftable = ::new("scripts/items/armor/named/wx_armor_zhuyin");
		this.m.Cost = 2200;
		this.init([
			{ Script = "scripts/items/misc/wx_core_zhuyin", Num = 1 },
			{ Script = "scripts/items/misc/serpent_skin_item", Num = 1 }
		]);
	}
	function onCraft( _stash ) { _stash.add(::new("scripts/items/armor/named/wx_armor_zhuyin")); }
});
