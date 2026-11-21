// Shan Hai Jing Apex Boss Entity (中山经): 【山海神木】都广野·句芒建木王

this.wx_boss_jumang <- this.inherit("scripts/entity/tactical/enemies/schrat", {
	m = {},

	function onInit()
	{
		this.schrat.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_jumang");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.schrat.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_jumang", _tile);
	}
});
