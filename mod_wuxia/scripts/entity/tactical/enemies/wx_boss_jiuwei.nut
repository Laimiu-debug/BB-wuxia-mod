// Shan Hai Jing Apex Boss Entity (南山经): 【山海大妖】青丘山·九尾天狐主

this.wx_boss_jiuwei <- this.inherit("scripts/entity/tactical/enemies/hexe", {
	m = {},

	function onInit()
	{
		this.hexe.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_jiuwei");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.hexe.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_jiuwei", _tile, this, _killer, _fatalityType);
	}
});
