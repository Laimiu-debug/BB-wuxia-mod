// Shan Hai Jing Apex Boss Entity (南山经): 【山海凶兽】苍梧渊·吞象巴蛇王

this.wx_boss_bashe <- this.inherit("scripts/entity/tactical/enemies/serpent", {
	m = {},

	function onInit()
	{
		this.serpent.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_bashe");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.serpent.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_bashe", _tile, this, _killer, _fatalityType);
	}
});
