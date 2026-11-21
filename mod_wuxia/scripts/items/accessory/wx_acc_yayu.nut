// Shan Hai Talisman: 山海·少咸猰貐贰负续命珏
this.wx_acc_yayu <- this.inherit("scripts/items/accessory/wx_shanhai_acc_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_acc_base.create();
		this.initShanHaiAccessory("wx_acc_yayu");
	}
});
