// Shan Hai Jing Apex Boss Entity (大荒海内经): 【山海巨灵】会稽古冢·守风防风氏巨骨

this.wx_boss_fangfeng <- this.inherit("scripts/entity/tactical/enemies/unhold_armored", {
	m = {},

	function onInit()
	{
		this.unhold_armored.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_fangfeng");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.unhold_armored.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_fangfeng", _tile);
	}
});
