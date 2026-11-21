// Shan Hai Jing Apex Boss Entity (北山经): 【山海凶兽】钩吾北·腋目狍鸮老祖

this.wx_boss_paoxiaowang <- this.inherit("scripts/entity/tactical/enemies/unhold_bog", {
	m = {},

	function onInit()
	{
		this.unhold_bog.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_paoxiaowang");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.unhold_bog.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_paoxiaowang", _tile);
	}
});
