// Shan Hai Jing Apex Boss Entity (西山经): 【山海异兽】玉山·豹纹牛角神狡
this.wx_boss_jiao <- this.inherit("scripts/entity/tactical/enemies/direwolf_high", {
	m = {},
	function onInit()
	{
		this.direwolf_high.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_jiao");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.direwolf_high.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_jiao", _tile, this, _killer, _fatalityType);
	}
});
