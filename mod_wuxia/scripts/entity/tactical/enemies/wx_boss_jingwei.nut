// Shan Hai Jing Apex Boss Entity (东山经): 【山海怨魂】发鸠山·东海溺魂精卫妖主

this.wx_boss_jingwei <- this.inherit("scripts/entity/tactical/enemies/ghost_knight", {
	m = {},

	function onInit()
	{
		this.ghost_knight.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_jingwei");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.ghost_knight.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_jingwei", _tile, this, _killer, _fatalityType);
	}
});
