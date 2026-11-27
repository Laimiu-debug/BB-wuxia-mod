this.wx_tact_qinyuangao <- this.inherit("scripts/items/misc/wx_tactical_consumable_base", {
	m = {},
	function create()
	{
		this.wx_tactical_consumable_base.create();
		this.initTacticalConsumable("wx_tact_qinyuangao");
	}
});
