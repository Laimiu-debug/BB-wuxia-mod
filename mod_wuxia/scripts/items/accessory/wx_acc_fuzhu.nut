// Shan Hai Talisman: 山海·敖岸夫诸四角凝霜佩
this.wx_acc_fuzhu <- this.inherit("scripts/items/accessory/wx_shanhai_acc_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_acc_base.create();
		this.initShanHaiAccessory("wx_acc_fuzhu");
	}
});
