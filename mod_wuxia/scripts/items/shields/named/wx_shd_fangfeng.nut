// Shan Hai Famed Shield: 山海·会稽防风专车骨橹
this.wx_shd_fangfeng <- this.inherit("scripts/items/shields/named/wx_shanhai_shield_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_shield_base.create();
		this.initShanHaiShield("wx_shd_fangfeng", false);
	}
});
