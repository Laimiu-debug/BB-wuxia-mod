// Shan Hai Jing Apex Boss Entity (大荒东经): 【山海神禽】汤谷扶桑·三足金乌皇
this.wx_boss_jinwu <- this.inherit("scripts/entity/tactical/enemies/vampire", {
	m = {},
	function onInit()
	{
		this.vampire.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_jinwu");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.vampire.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_jinwu", _tile, this, _killer, _fatalityType);
	}
});
