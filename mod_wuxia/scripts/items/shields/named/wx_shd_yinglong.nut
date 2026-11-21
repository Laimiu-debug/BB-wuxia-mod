// Shan Hai Famed Shield: 山海·应龙蓄水逆鳞团牌
this.wx_shd_yinglong <- this.inherit("scripts/items/shields/named/wx_shanhai_shield_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_shield_base.create();
		this.initShanHaiShield("wx_shd_yinglong", false);
	}
});
