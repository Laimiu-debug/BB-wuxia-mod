// Shan Hai Jing Apex Boss Entity (南山经): 【山海凶禽】章莪山·独足毕方妖皇

this.wx_boss_bifang <- this.inherit("scripts/entity/tactical/enemies/vampire", {
	m = {},

	function onInit()
	{
		this.vampire.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_bifang");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.vampire.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_bifang", _tile);
	}
});
