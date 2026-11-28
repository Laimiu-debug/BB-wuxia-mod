// Shan Hai Jing Apex Boss Entity (中山经): 【山海疾兽】狱法山·犬形人面山挥王

this.wx_boss_shanhui <- this.inherit("scripts/entity/tactical/enemies/goblin_wolfrider", {
	m = {},

	function onInit()
	{
		this.goblin_wolfrider.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_shanhui");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.goblin_wolfrider.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_shanhui", _tile, this, _killer, _fatalityType);
	}
});
