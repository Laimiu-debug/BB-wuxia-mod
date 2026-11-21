// Shan Hai Jing Apex Boss Entity (北山经): 【山海四凶】钩吾山·吞天饕餮王

this.wx_boss_taotie <- this.inherit("scripts/entity/tactical/enemies/ghoul_high", {
	m = {},

	function onInit()
	{
		this.ghoul_high.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_taotie");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.ghoul_high.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_taotie", _tile);
	}
});
