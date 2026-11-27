// Shan Hai Jing Apex Boss Entity (北山经): 【山海凶神】少咸山·龙首猰貐血尊

this.wx_boss_yayu <- this.inherit("scripts/entity/tactical/enemies/ghoul_high", {
	m = {},

	function onInit()
	{
		this.ghoul_high.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_yayu");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.ghoul_high.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_yayu", _tile);
	}
});
