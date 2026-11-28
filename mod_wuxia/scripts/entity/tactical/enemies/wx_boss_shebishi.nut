// Shan Hai Jing Apex Boss Entity (东山经): 【山海尸神】大荒东·青蛇贯耳奢比尸

this.wx_boss_shebishi <- this.inherit("scripts/entity/tactical/enemies/zombie_boss", {
	m = {},

	function onInit()
	{
		this.zombie_boss.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_shebishi");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.zombie_boss.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_shebishi", _tile, this, _killer, _fatalityType);
	}
});
