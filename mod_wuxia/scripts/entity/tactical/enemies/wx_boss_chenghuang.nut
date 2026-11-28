// Shan Hai Jing Apex Boss Entity (海外西经): 【山海神兽】白民国·背角神狐乘黄
this.wx_boss_chenghuang <- this.inherit("scripts/entity/tactical/enemies/hyena_high", {
	m = {},
	function onInit()
	{
		this.hyena_high.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_chenghuang");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.hyena_high.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_chenghuang", _tile, this, _killer, _fatalityType);
	}
});
