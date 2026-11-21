// Shan Hai Jing Apex Boss Entity (北山经): 【山海异神】天山北·丹红六足帝江

this.wx_boss_dijiang <- this.inherit("scripts/entity/tactical/enemies/vampire", {
	m = {},

	function onInit()
	{
		this.vampire.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_dijiang");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.vampire.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_dijiang", _tile);
	}
});
