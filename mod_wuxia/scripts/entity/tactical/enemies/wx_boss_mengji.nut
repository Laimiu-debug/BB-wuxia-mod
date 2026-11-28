// Shan Hai Jing Apex Boss Entity (北山经): 【山海异兽】石者山·白豹孟极兽皇

this.wx_boss_mengji <- this.inherit("scripts/entity/tactical/enemies/direwolf_high", {
	m = {},

	function onInit()
	{
		this.direwolf_high.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_mengji");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.direwolf_high.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_mengji", _tile, this, _killer, _fatalityType);
	}
});
