// Shan Hai Jing Apex Boss Entity (大荒北经): 【山海尸神】大荒北山·虎首衔蛇强良
this.wx_boss_qiangliang <- this.inherit("scripts/entity/tactical/enemies/orc_warlord", {
	m = {},
	function onInit()
	{
		this.orc_warlord.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_qiangliang");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.orc_warlord.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_qiangliang", _tile);
	}
});
