// Shan Hai Jing Apex Boss Entity (南山经): 【山海妖尊】丹穴山·堕火鹓鶵古妖

this.wx_boss_yuanchu <- this.inherit("scripts/entity/tactical/enemies/skeleton_priest", {
	m = {},

	function onInit()
	{
		this.skeleton_priest.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_yuanchu");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.skeleton_priest.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_yuanchu", _tile, this, _killer, _fatalityType);
	}
});
