// Shan Hai Talisman: 山海·发鸠精卫衔石不屈坠
this.wx_acc_jingwei <- this.inherit("scripts/items/accessory/wx_shanhai_acc_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_acc_base.create();
		this.initShanHaiAccessory("wx_acc_jingwei");
	}
});
