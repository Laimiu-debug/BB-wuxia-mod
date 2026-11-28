// Shan Hai Jing Apex Boss Entity (南山经): 【山海异兽】杻阳山·鸟首玄龟皇

this.wx_boss_xuangui <- this.inherit("scripts/entity/tactical/enemies/unhold_armored", {
	m = {},

	function onInit()
	{
		this.unhold_armored.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_xuangui");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.unhold_armored.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_xuangui", _tile, this, _killer, _fatalityType);
	}
});
