// Shan Hai Jing Apex Boss Entity (南山经): 【山海凶禽】鹿吴山·攒角蛊雕王

this.wx_boss_gudiaowang <- this.inherit("scripts/entity/tactical/enemies/hyena_high", {
	m = {},

	function onInit()
	{
		this.hyena_high.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_gudiaowang");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.hyena_high.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_gudiaowang", _tile);
	}
});
