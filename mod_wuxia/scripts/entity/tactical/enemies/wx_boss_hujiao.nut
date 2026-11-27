// Shan Hai Jing Apex Boss Entity (东山经): 【山海毒蛟】玉山涧·四足虎纹虎蛟王

this.wx_boss_hujiao <- this.inherit("scripts/entity/tactical/enemies/serpent", {
	m = {},

	function onInit()
	{
		this.serpent.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_hujiao");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.serpent.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_hujiao", _tile);
	}
});
