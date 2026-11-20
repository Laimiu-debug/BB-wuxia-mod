// Historical Famous Rare Weapon: 传世·巨阙至尊大剑 (Sword)

this.wx_relic_juque <- this.inherit("scripts/items/weapons/named/named_greatsword", {
	m = {},

	function create()
	{
		this.named_greatsword.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_juque");
	}

	function onDeserialize( _in )
	{
		this.named_greatsword.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_juque");
	}
});
