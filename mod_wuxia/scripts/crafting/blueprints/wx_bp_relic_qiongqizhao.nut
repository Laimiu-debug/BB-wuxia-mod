this.wx_bp_relic_qiongqizhao <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_relic_qiongqizhao";
		this.m.PreviewCraftable = ::new("scripts/items/weapons/named/wx_relic_qiongqizhao");
		this.m.Cost = 2200;
		this.init([
			{ Script = "scripts/items/misc/wx_core_qiongqi", Num = 1 },
			{ Script = "scripts/items/misc/ghoul_horn_item", Num = 1 }
		]);
	}
	function onCraft( _stash ) { _stash.add(::new("scripts/items/weapons/named/wx_relic_qiongqizhao")); }
});
