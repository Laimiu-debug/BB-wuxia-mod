// Shan Hai Jing Apex Boss Entity (大荒海内经): 【山海凶魔】畴华野·丈齿持盾凿齿王

this.wx_boss_zaochi <- this.inherit("scripts/entity/tactical/enemies/skeleton_boss", {
	m = {},

	function onInit()
	{
		this.skeleton_boss.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_zaochi");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.skeleton_boss.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_zaochi", _tile, this, _killer, _fatalityType);
	}
});
