this.wx_bp_armor_qiongqi <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_armor_qiongqi";
		this.m.PreviewCraftable = ::new("scripts/items/armor/named/wx_armor_qiongqi");
		this.m.Cost = 2000;
		this.init([
			{ Script = "scripts/items/misc/wx_core_qiongqi", Num = 1 },
			{ Script = "scripts/items/misc/hyena_fur_item", Num = 1 }
		]);
	}

	function onCraft( _stash ) { _stash.add(::new("scripts/items/armor/named/wx_armor_qiongqi")); }
});
