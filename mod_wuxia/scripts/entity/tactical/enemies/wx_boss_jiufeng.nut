// Shan Hai Jing Apex Boss Entity (大荒北经): 【山海妖皇】大荒北极·九首鬼车九凤
this.wx_boss_jiufeng <- this.inherit("scripts/entity/tactical/enemies/vampire", {
	m = {},
	function onInit()
	{
		this.vampire.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_jiufeng");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.vampire.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_jiufeng", _tile);
	}
});
