this.wx_bp_helm_dijiang <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_helm_dijiang";
		this.m.PreviewCraftable = ::new("scripts/items/helmets/named/wx_helm_dijiang");
		this.m.Cost = 1800;
		this.init([
			{ Script = "scripts/items/misc/wx_core_dijiang", Num = 1 },
			{ Script = "scripts/items/misc/spider_silk_item", Num = 1 }
		]);
	}
	function onCraft( _stash ) { _stash.add(::new("scripts/items/helmets/named/wx_helm_dijiang")); }
});
