// Shan Hai Jing Apex Boss Entity (海内西经): 【山海镇神】昆仑虚·九首开明兽
this.wx_boss_kaiming <- this.inherit("scripts/entity/tactical/enemies/unhold_armored", {
	m = {},
	function onInit()
	{
		this.unhold_armored.onInit();
		::Wuxia.ShanHai.initBossEntity(this, "boss_kaiming");
	}
	function onDeath( _killer, _skill, _tile, _fatalityType )
	{
		this.unhold_armored.onDeath(_killer, _skill, _tile, _fatalityType);
		::Wuxia.ShanHai.dropBossCore("boss_kaiming", _tile);
	}
});
