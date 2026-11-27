// Shan Hai Jing Apex Boss Entity (中山经): 【山海凶蟒】鲜山·四翼磐音鸣蛇
this.wx_boss_mingshe <- this.inherit("scripts/entity/tactical/enemies/serpent", {
	m = {},
	function onInit()
	{
		this.serpent.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_mingshe");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.serpent.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_mingshe", _tile);
	}
});
