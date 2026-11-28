// Shan Hai Jing Apex Boss Entity (大荒海内经): 【山海凶神】共工台·九首毒渊相柳皇 (5-Tile Severable Multi-Head Boss + Bitter Mire Alchemy)

this.wx_boss_xiangliuwang <- this.inherit("scripts/entity/tactical/enemies/lindwurm", {
	m = {},

	function onInit()
	{
		this.lindwurm.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_xiangliuwang");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.lindwurm.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_xiangliuwang", _tile, this, _killer, _fatalityType);
	}
});
