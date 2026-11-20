// Shan Hai Jing Apex Boss Entity: 【山海凶兽】小次山·朱厌猿王

this.wx_boss_zhuyan <- this.inherit("scripts/entity/tactical/enemies/unhold_frost_armored", {
	m = {},

	function onInit()
	{
		this.unhold_frost_armored.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_zhuyan");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.unhold_frost_armored.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_zhuyan", _tile);
	}
});
