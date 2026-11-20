// Historical Famous Rare Weapon: 传世·青龙冷艳锯 (Polearm)

this.wx_relic_yanyue <- this.inherit("scripts/items/weapons/named/named_swordlance", {
	m = {},

	function create()
	{
		this.named_swordlance.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_yanyue");
	}

	function onDeserialize( _in )
	{
		this.named_swordlance.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_yanyue");
	}
});
