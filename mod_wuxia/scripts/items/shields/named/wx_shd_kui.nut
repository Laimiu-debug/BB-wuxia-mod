// Shan Hai Famed Shield: 山海·东海夔牛雷音皮盾
this.wx_shd_kui <- this.inherit("scripts/items/shields/named/wx_shanhai_shield_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_shield_base.create();
		this.initShanHaiShield("wx_shd_kui", false);
	}
});
