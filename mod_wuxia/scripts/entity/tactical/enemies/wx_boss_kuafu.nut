// Shan Hai Jing Apex Boss Entity (大荒海内经): 【山海巨神】成都载天·逐日夸父枯骸

this.wx_boss_kuafu <- this.inherit("scripts/entity/tactical/enemies/skeleton_heavy_polearm", {
	m = {},

	function onInit()
	{
		this.skeleton_heavy_polearm.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_kuafu");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.skeleton_heavy_polearm.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_kuafu", _tile);
	}
});
