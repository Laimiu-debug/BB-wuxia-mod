// Shan Hai Jing Apex Boss Entity (东山经): 【山海瑞凶】钦山·巨牙当康兽王
this.wx_boss_dangkang <- this.inherit("scripts/entity/tactical/enemies/orc_berserker", {
	m = {},
	function onInit()
	{
		this.orc_berserker.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_dangkang");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.orc_berserker.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_dangkang", _tile, this, _killer, _fatalityType);
	}
});
