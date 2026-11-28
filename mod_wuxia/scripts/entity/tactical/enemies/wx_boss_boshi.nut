// Shan Hai Jing Apex Boss Entity (南山经): 【山海异兽】基山·背目九尾猼訑
this.wx_boss_boshi <- this.inherit("scripts/entity/tactical/enemies/unhold", {
	m = {},
	function onInit()
	{
		this.unhold.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_boshi");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.unhold.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_boshi", _tile, this, _killer, _fatalityType);
	}
});
