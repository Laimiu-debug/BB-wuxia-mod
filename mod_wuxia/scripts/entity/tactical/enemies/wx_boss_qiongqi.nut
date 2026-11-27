// Shan Hai Jing Apex Boss Entity (北山经): 【山海四凶】邽山·裂风穷奇

this.wx_boss_qiongqi <- this.inherit("scripts/entity/tactical/enemies/hyena_high", {
	m = {},

	function onInit()
	{
		this.hyena_high.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_qiongqi");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.hyena_high.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_qiongqi", _tile);
	}
});
