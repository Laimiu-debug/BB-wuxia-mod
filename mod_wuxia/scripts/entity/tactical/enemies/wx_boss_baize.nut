// Shan Hai Jing Apex Boss Entity (中山经): 【山海瑞煞】东望山·通万物情白泽古兽

this.wx_boss_baize <- this.inherit("scripts/entity/tactical/enemies/unhold_frost_armored", {
	m = {},

	function onInit()
	{
		this.unhold_frost_armored.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_baize");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.unhold_frost_armored.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_baize", _tile);
	}
});
