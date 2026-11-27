// Shan Hai Jing Apex Boss Entity (东山经): 【山海雷兽】东海流波山·独足雷神夔牛

this.wx_boss_kui <- this.inherit("scripts/entity/tactical/enemies/unhold_armored", {
	m = {},

	function onInit()
	{
		this.unhold_armored.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_kui");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.unhold_armored.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_kui", _tile);
	}
});
