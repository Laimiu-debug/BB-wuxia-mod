// Shan Hai Jing Apex Boss Entity (西山经): 【山海凶星】阴山顶·奔星天狗皇

this.wx_boss_tiangouwang <- this.inherit("scripts/entity/tactical/enemies/direwolf_high", {
	m = {},

	function onInit()
	{
		this.direwolf_high.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_tiangouwang");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.direwolf_high.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_tiangouwang", _tile);
	}
});
