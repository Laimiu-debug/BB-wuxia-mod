// Shan Hai Talisman: 山海·淮水辟毒寒渊珠
this.wx_acc_wuzhiqi <- this.inherit("scripts/items/accessory/wx_shanhai_acc_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_acc_base.create();
		this.initShanHaiAccessory("wx_acc_wuzhiqi");
	}
});
