// Shan Hai Jing Apex Boss Entity (大荒海内经): 【山海旱魃】十日炙山·青衣赤魃女丑魂 (1+3 Floating Sun Corona Totems + Directional Sleeve Parry)

this.wx_boss_nvchou <- this.inherit("scripts/entity/tactical/enemies/hexe", {
	m = {},

	function onInit()
	{
		this.hexe.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_nvchou");
	}

	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		if ("ShanHaiMultiBody" in ::Wuxia)
			::Wuxia.ShanHaiMultiBody.onMasterDeath(this);
		this.hexe.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_nvchou", _tile);
	}
});
