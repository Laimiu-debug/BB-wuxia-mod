// Shan Hai Jing Apex Boss Entity (中山经): 【山海大妖】龟山寒渊·淮水无支祁

this.wx_boss_wuzhiqi <- this.inherit("scripts/entity/tactical/enemies/unhold_bog", {
	m = {},

	function onInit()
	{
		this.unhold_bog.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_wuzhiqi");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.unhold_bog.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_wuzhiqi", _tile);
	}
});
