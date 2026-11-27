// Shan Hai Jing Apex Boss Entity (东山经): 【山海四凶】荒中凶兽·人面虎足檮杌王

this.wx_boss_taowu <- this.inherit("scripts/entity/tactical/enemies/unhold_frost_armored", {
	m = {},

	function onInit()
	{
		this.unhold_frost_armored.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_taowu");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.unhold_frost_armored.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_taowu", _tile);
	}
});
