// Shan Hai Jing Apex Boss Entity (西山经): 【山海古神】昆仑丘·九尾虎神陆吾

this.wx_boss_luwu <- this.inherit("scripts/entity/tactical/enemies/unhold_armored", {
	m = {},

	function onInit()
	{
		this.unhold_armored.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_luwu");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.unhold_armored.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_luwu", _tile);
	}
});
