// Shan Hai Jing Apex Boss Entity (西山经): 【山海毒尊】昆仑阳·蜇石钦原蛊皇

this.wx_boss_qinyuan <- this.inherit("scripts/entity/tactical/enemies/spider", {
	m = {},

	function onInit()
	{
		this.spider.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_qinyuan");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.spider.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_qinyuan", _tile);
	}
});
