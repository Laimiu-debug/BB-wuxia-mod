// Shan Hai Jing Apex Boss Entity (中山经): 【山海神女】青要山·豹纹武罗妖神
this.wx_boss_wuluo <- this.inherit("scripts/entity/tactical/enemies/hexe", {
	m = {},
	function onInit()
	{
		this.hexe.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_wuluo");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.hexe.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_wuluo", _tile, this, _killer, _fatalityType);
	}
});
