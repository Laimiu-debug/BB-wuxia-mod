// Shan Hai Famed Shield: 山海·畴华凿齿破军戈盾
this.wx_shd_zaochi <- this.inherit("scripts/items/shields/named/wx_shanhai_shield_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_shield_base.create();
		this.initShanHaiShield("wx_shd_zaochi", false);
	}
});
