// Shan Hai Jing Apex Boss Entity (大荒西经): 【山海古神】不周山·共工怒涛水煞
this.wx_boss_gonggong <- this.inherit("scripts/entity/tactical/enemies/lindwurm", {
	m = {},
	function onInit()
	{
		this.lindwurm.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_gonggong");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.lindwurm.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_gonggong", _tile);
	}
});
