// Historical Famous Rare Weapon: 传世·虎头湛金长枪 (Spear)

this.wx_relic_hutouqiang <- this.inherit("scripts/items/weapons/named/named_spetum", {
	m = {},

	function create()
	{
		this.named_spetum.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_hutouqiang");
	}

	function onDeserialize( _in )
	{
		this.named_spetum.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_hutouqiang");
	}
});
