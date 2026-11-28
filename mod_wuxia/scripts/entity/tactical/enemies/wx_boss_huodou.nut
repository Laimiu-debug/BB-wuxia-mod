// Shan Hai Jing Apex Boss Entity (中山经): 【山海火妖】厌火南荒·食炭喷炎祸斗王

this.wx_boss_huodou <- this.inherit("scripts/entity/tactical/enemies/direwolf_high", {
	m = {},

	function onInit()
	{
		this.direwolf_high.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_huodou");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.direwolf_high.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_huodou", _tile, this, _killer, _fatalityType);
	}
});
