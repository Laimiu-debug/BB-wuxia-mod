// Shan Hai Divine Red Weapon: 传世·烛九阴寒暑两仪巨剑 (Sword)
this.wx_relic_zhuyinjian <- this.inherit("scripts/items/weapons/named/named_greatsword", {
	m = {},
	function create()
	{
		this.named_greatsword.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_zhuyinjian");
	}
	function onDeserialize( _in )
	{
		this.named_greatsword.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_zhuyinjian");
	}
});
