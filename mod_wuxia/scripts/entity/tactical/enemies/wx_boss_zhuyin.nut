// Shan Hai Jing Apex Boss Entity (北山经): 【山海古神】钟山巅·烛九阴寒螟裔 (3-Tile Coiled True Dragon + Day/Night Winter/Summer Domain)

this.wx_boss_zhuyin <- this.inherit("scripts/entity/tactical/enemies/lindwurm", {
	m = {},

	function onInit()
	{
		this.lindwurm.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_zhuyin");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.lindwurm.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_zhuyin", _tile);
	}
});
