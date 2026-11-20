this.wx_bp_helm_bashe <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_helm_bashe";
		this.m.PreviewCraftable = ::new("scripts/items/helmets/named/wx_helm_bashe");
		this.m.Cost = 1700;
		this.init([
			{ Script = "scripts/items/misc/wx_core_bashe", Num = 1 },
			{ Script = "scripts/items/misc/serpent_skin_item", Num = 1 }
		]);
	}

	function onCraft( _stash ) { _stash.add(::new("scripts/items/helmets/named/wx_helm_bashe")); }
});
