// Shan Hai Jing Apex Boss Entity (大荒海内经): 【山海兵主】凶黎古冢·铜头铁额蚩尤战魄

this.wx_boss_chiyou <- this.inherit("scripts/entity/tactical/enemies/orc_warlord", {
	m = {},

	function onInit()
	{
		this.orc_warlord.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_chiyou");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.orc_warlord.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_chiyou", _tile);
	}
});
