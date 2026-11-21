// Shan Hai Jing Apex Boss Entity (海内南经): 【山海凶兽】苍梧野·独角青兕王
this.wx_boss_siwang <- this.inherit("scripts/entity/tactical/enemies/unhold_armored", {
	m = {},
	function onInit()
	{
		this.unhold_armored.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_siwang");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.unhold_armored.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_siwang", _tile);
	}
});
