// Shan Hai Talisman: 山海·基山猼訑背目无畏佩
this.wx_acc_boshi <- this.inherit("scripts/items/accessory/wx_shanhai_acc_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_acc_base.create();
		this.initShanHaiAccessory("wx_acc_boshi");
	}
});
