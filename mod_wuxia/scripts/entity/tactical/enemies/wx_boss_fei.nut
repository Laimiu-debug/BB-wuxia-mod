// Shan Hai Jing Apex Boss Entity (东山经): 【山海灾兽】太山渊·一目白首蜚皇

this.wx_boss_fei <- this.inherit("scripts/entity/tactical/enemies/orc_warlord", {
	m = {},

	function onInit()
	{
		this.orc_warlord.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_fei");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.orc_warlord.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_fei", _tile);
	}
});
