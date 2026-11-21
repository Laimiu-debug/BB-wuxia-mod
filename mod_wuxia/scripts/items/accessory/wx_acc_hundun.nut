// Shan Hai Talisman: 山海·浑沌无窍定岳黄囊
this.wx_acc_hundun <- this.inherit("scripts/items/accessory/wx_shanhai_acc_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_acc_base.create();
		this.initShanHaiAccessory("wx_acc_hundun");
	}
});
