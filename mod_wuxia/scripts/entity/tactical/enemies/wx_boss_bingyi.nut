// Shan Hai Jing Apex Boss Entity (海内北经): 【山海河伯】从极渊·御龙冰夷水君
this.wx_boss_bingyi <- this.inherit("scripts/entity/tactical/enemies/skeleton_boss", {
	m = {},
	function onInit()
	{
		this.skeleton_boss.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_bingyi");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.skeleton_boss.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_bingyi", _tile);
	}
});
