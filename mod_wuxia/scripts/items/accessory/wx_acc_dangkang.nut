// Shan Hai Talisman: 山海·钦山当康丰穰青玉牙
this.wx_acc_dangkang <- this.inherit("scripts/items/accessory/wx_shanhai_acc_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_acc_base.create();
		this.initShanHaiAccessory("wx_acc_dangkang");
	}
});
