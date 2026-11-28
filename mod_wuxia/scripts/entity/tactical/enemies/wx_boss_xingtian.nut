// Shan Hai Jing Apex Boss Entity (大荒海内经): 【山海凶煞】常羊山·刑天无首战魂

this.wx_boss_xingtian <- this.inherit("scripts/entity/tactical/enemies/skeleton_boss", {
	m = {},

	function onInit()
	{
		this.skeleton_boss.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_xingtian");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.skeleton_boss.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_xingtian", _tile, this, _killer, _fatalityType);
	}
});
