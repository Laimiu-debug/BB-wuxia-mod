this.wx_bp_helm_taotie <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_helm_taotie";
		this.m.PreviewCraftable = ::new("scripts/items/helmets/named/wx_helm_taotie");
		this.m.Cost = 1800;
		this.init([
			{ Script = "scripts/items/misc/wx_core_taotie", Num = 1 },
			{ Script = "scripts/items/misc/ghoul_horn_item", Num = 1 }
		]);
	}

	function onCraft( _stash ) { _stash.add(::new("scripts/items/helmets/named/wx_helm_taotie")); }
});
