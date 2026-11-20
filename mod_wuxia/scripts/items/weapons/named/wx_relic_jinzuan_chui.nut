// Historical Famous Rare Weapon: 传世·八宝震山长柄金锤 (Hammer)

this.wx_relic_jinzuan_chui <- this.inherit("scripts/items/weapons/named/named_polehammer", {
	m = {},

	function create()
	{
		this.named_polehammer.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_jinzuan_chui");
	}

	function onDeserialize( _in )
	{
		this.named_polehammer.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_jinzuan_chui");
	}
});
