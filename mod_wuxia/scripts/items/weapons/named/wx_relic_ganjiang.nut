// Historical Famous Rare Weapon: 传世·干将百炼阳剑 (Sword)

this.wx_relic_ganjiang <- this.inherit("scripts/items/weapons/named/named_estoc", {
	m = {},

	function create()
	{
		this.named_estoc.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_ganjiang");
	}

	function onDeserialize( _in )
	{
		this.named_estoc.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_ganjiang");
	}
});
