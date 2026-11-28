// Shan Hai Jing Apex Boss Entity (西山经): 【山海凶兽】太华山·六足肥遗王

this.wx_boss_feiyi <- this.inherit("scripts/entity/tactical/enemies/lindwurm", {
	m = {},

	function onInit()
	{
		this.lindwurm.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_feiyi");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.lindwurm.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_feiyi", _tile, this, _killer, _fatalityType);
	}
});
