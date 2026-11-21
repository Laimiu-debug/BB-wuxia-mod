this.wx_bp_relic_chiyoufu <- this.inherit("scripts/crafting/blueprint", {
	function create()
	{
		this.blueprint.create();
		this.m.ID = "blueprint.wx_bp_relic_chiyoufu";
		this.m.PreviewCraftable = ::new("scripts/items/weapons/named/wx_relic_chiyoufu");
		this.m.Cost = 2400;
		this.init([
			{ Script = "scripts/items/misc/wx_core_chiyou", Num = 1 },
			{ Script = "scripts/items/misc/unhold_heart_item", Num = 1 }
		]);
	}
	function onCraft( _stash ) { _stash.add(::new("scripts/items/weapons/named/wx_relic_chiyoufu")); }
});
