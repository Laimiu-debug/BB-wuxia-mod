// Shan Hai Jing Apex Boss Entity (东山经): 【山海凶兽】北岳山·四角人目诸怀王

this.wx_boss_zhuhuai <- this.inherit("scripts/entity/tactical/enemies/orc_berserker", {
	m = {},

	function onInit()
	{
		this.orc_berserker.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_zhuhuai");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.orc_berserker.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_zhuhuai", _tile, this, _killer, _fatalityType);
	}
});
