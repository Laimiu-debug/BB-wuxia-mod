// Historical Famous Rare Weapon: 传世·擂鼓瓮金巨锤 (Hammer)

this.wx_relic_wengjinchui <- this.inherit("scripts/items/weapons/named/named_two_handed_hammer", {
	m = {},

	function create()
	{
		this.named_two_handed_hammer.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_wengjinchui");
	}

	function onDeserialize( _in )
	{
		this.named_two_handed_hammer.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_wengjinchui");
	}
});
