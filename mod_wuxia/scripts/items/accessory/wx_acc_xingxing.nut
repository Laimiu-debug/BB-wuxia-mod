// Shan Hai Talisman: 山海·招摇狌狌通晓往事佩
this.wx_acc_xingxing <- this.inherit("scripts/items/accessory/wx_shanhai_acc_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_acc_base.create();
		this.initShanHaiAccessory("wx_acc_xingxing");
	}
});
