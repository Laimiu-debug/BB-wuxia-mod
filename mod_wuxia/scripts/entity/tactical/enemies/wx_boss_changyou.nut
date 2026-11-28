// Shan Hai Jing Apex Boss Entity (北山经): 【山海大妖】小侯山·四耳长右水猿

this.wx_boss_changyou <- this.inherit("scripts/entity/tactical/enemies/unhold_bog", {
	m = {},

	function onInit()
	{
		this.unhold_bog.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_changyou");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.unhold_bog.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_changyou", _tile, this, _killer, _fatalityType);
	}
});
