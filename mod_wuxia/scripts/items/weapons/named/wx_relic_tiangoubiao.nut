// Shan Hai Divine Red Weapon: 传世·阴山天狗坠星飞梭 (Throwing)
this.wx_relic_tiangoubiao <- this.inherit("scripts/items/weapons/named/named_javelin", {
	m = {},
	function create()
	{
		this.named_javelin.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_tiangoubiao");
	}
	function onDeserialize( _in )
	{
		this.named_javelin.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_tiangoubiao");
	}
});
