// Shan Hai Jing Apex Boss Entity (大荒海内经): 【山海缚神】疏属山·桎梏龙身贰负尸皇

this.wx_boss_erfu <- this.inherit("scripts/entity/tactical/enemies/zombie_betrayer", {
	m = {},

	function onInit()
	{
		this.zombie_betrayer.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_erfu");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.zombie_betrayer.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_erfu", _tile, this, _killer, _fatalityType);
	}
});
