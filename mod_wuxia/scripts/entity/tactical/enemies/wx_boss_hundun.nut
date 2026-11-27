// Shan Hai Jing Apex Boss Entity (西山经): 【山海四凶】天山渊·六足无面浑沌

this.wx_boss_hundun <- this.inherit("scripts/entity/tactical/enemies/unhold_frost_armored", {
	m = {},

	function onInit()
	{
		this.unhold_frost_armored.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_hundun");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.unhold_frost_armored.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_hundun", _tile);
	}
});
