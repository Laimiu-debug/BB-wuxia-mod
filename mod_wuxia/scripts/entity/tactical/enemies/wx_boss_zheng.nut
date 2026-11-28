// Shan Hai Jing Apex Boss Entity (西山经): 【山海凶兽】章峨山·五尾独角狰王

this.wx_boss_zheng <- this.inherit("scripts/entity/tactical/enemies/hyena_high", {
	m = {},

	function onInit()
	{
		this.hyena_high.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_zheng");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.hyena_high.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_zheng", _tile, this, _killer, _fatalityType);
	}
});
