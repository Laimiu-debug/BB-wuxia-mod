// Shan Hai Famed Shield: 山海·都广建木盘根藤牌
this.wx_shd_jumang <- this.inherit("scripts/items/shields/named/wx_shanhai_shield_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_shield_base.create();
		this.initShanHaiShield("wx_shd_jumang", false);
	}
});
