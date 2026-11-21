this.wx_up_gujing <- this.inherit("scripts/items/armor_upgrades/wx_beast_upgrade_base", {
	m = {},

	function create()
	{
		this.wx_beast_upgrade_base.create();
		this.initBeastUpgrade("wx_up_gujing");
	}
});
