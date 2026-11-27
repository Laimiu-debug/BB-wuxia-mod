// Shan Hai Jing Apex Boss Entity (南山经): 【山海大妖】招摇山·白耳狌狌老祖

this.wx_boss_xingxing <- this.inherit("scripts/entity/tactical/enemies/unhold", {
	m = {},

	function onInit()
	{
		this.unhold.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_xingxing");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.unhold.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_xingxing", _tile);
	}
});
