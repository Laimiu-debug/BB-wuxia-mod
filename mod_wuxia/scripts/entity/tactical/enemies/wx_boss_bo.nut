// Shan Hai Jing Apex Boss Entity (中山经): 【山海猛兽】中曲山·独角食虎铁驳王

this.wx_boss_bo <- this.inherit("scripts/entity/tactical/enemies/unhold_armored", {
	m = {},

	function onInit()
	{
		this.unhold_armored.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_bo");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.unhold_armored.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_bo", _tile);
	}
});
