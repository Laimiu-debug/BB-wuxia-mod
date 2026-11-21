// Shan Hai Talisman: 山海·白泽达知万物图谱佩
this.wx_acc_baize <- this.inherit("scripts/items/accessory/wx_shanhai_acc_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_acc_base.create();
		this.initShanHaiAccessory("wx_acc_baize");
	}
});
