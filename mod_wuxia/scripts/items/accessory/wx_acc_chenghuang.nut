// Shan Hai Talisman: 山海·白民乘黄二千岁琥珀
this.wx_acc_chenghuang <- this.inherit("scripts/items/accessory/wx_shanhai_acc_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_acc_base.create();
		this.initShanHaiAccessory("wx_acc_chenghuang");
	}
});
