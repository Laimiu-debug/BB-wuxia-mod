// Shan Hai Jing Apex Boss Entity (南山经): 【山海凶兽】单狐山·豹尾猪建王

this.wx_boss_zhujian <- this.inherit("scripts/entity/tactical/enemies/orc_berserker", {
	m = {},

	function onInit()
	{
		this.orc_berserker.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_zhujian");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.orc_berserker.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_zhujian", _tile);
	}
});
