// Shan Hai Jing Apex Boss Entity (中山经): 【山海凶蛟】阳山·人面鸟翼化蛇
this.wx_boss_huashe <- this.inherit("scripts/entity/tactical/enemies/lindwurm", {
	m = {},
	function onInit()
	{
		this.lindwurm.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_huashe");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.lindwurm.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_huashe", _tile, this, _killer, _fatalityType);
	}
});
