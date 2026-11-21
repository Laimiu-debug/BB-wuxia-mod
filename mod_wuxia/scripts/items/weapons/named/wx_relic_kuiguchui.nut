// Shan Hai Divine Red Weapon: 传世·流波夔牛震天雷骨锤 (Hammer)
this.wx_relic_kuiguchui <- this.inherit("scripts/items/weapons/named/named_two_handed_hammer", {
	m = {},
	function create()
	{
		this.named_two_handed_hammer.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_kuiguchui");
	}
	function onDeserialize( _in )
	{
		this.named_two_handed_hammer.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_kuiguchui");
	}
});
