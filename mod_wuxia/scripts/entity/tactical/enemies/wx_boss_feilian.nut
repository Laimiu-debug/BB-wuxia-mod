// Shan Hai Jing Apex Boss Entity (中山经): 【山海风伯】鹿台山·雀首蛇尾飞廉妖尊

this.wx_boss_feilian <- this.inherit("scripts/entity/tactical/enemies/vampire", {
	m = {},

	function onInit()
	{
		this.vampire.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_feilian");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.vampire.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_feilian", _tile, this, _killer, _fatalityType);
	}
});
