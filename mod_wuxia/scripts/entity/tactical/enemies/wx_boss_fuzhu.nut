// Shan Hai Jing Apex Boss Entity (中山经): 【山海异兽】敖岸山·四角白鹿夫诸
this.wx_boss_fuzhu <- this.inherit("scripts/entity/tactical/enemies/unhold_frost", {
	m = {},
	function onInit()
	{
		this.unhold_frost.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_fuzhu");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.unhold_frost.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_fuzhu", _tile);
	}
});
