this.wx_bp_relic_hujiaobian <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_relic_hujiaobian";
		this.m.PreviewCraftable = ::new("scripts/items/weapons/named/wx_relic_hujiaobian");
		this.m.Cost = 2400;
		this.init([
			{ Script = "scripts/items/misc/wx_core_hujiao", Num = 1 },
			{ Script = "scripts/items/misc/lindwurm_scales_item", Num = 1 }
		]);
	}
	function onCraft( _stash ) { _stash.add(::new("scripts/items/weapons/named/wx_relic_hujiaobian")); }
});
