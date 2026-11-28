// Shan Hai Jing Apex Boss Entity (海内北经): 【山海仁瑞】林氏国·五采驺虞王
this.wx_boss_zouyu <- this.inherit("scripts/entity/tactical/enemies/hyena_high", {
	m = {},
	function onInit()
	{
		this.hyena_high.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_zouyu");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.hyena_high.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_zouyu", _tile, this, _killer, _fatalityType);
	}
});
