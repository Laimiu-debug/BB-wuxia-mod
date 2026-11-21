this.wx_bp_shd_yinglong <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_shd_yinglong";
		this.m.PreviewCraftable = ::new("scripts/items/shields/named/wx_shd_yinglong");
		this.m.Cost = 1900;
		this.init([
			{ Script = "scripts/items/misc/wx_core_yinglong", Num = 1 },
			{ Script = "scripts/items/misc/lindwurm_scales_item", Num = 1 }
		]);
	}
	function onCraft( _stash ) { _stash.add(::new("scripts/items/shields/named/wx_shd_yinglong")); }
});
