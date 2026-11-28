// Shan Hai Jing Apex Boss Entity (西山经): 【山海神孽】昆仑圃·人面英招巡狩

this.wx_boss_yingzhao <- this.inherit("scripts/entity/tactical/enemies/orc_warlord", {
	m = {},

	function onInit()
	{
		this.orc_warlord.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_yingzhao");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.orc_warlord.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_yingzhao", _tile, this, _killer, _fatalityType);
	}
});
