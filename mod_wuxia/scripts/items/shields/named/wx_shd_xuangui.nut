// Shan Hai Famed Shield: 山海·杻阳玄龟不坏巨盾
this.wx_shd_xuangui <- this.inherit("scripts/items/shields/named/wx_shanhai_shield_base", {
	m = {},
	function create()
	{
		this.wx_shanhai_shield_base.create();
		this.initShanHaiShield("wx_shd_xuangui", false);
	}
});
