// Historical Famous Rare Weapon: 传世·七星龙渊剑 (Sword)

this.wx_relic_longyuan <- this.inherit("scripts/items/weapons/named/named_sword", {
	m = {},

	function create()
	{
		this.named_sword.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_longyuan");
	}

	function onDeserialize( _in )
	{
		this.named_sword.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_longyuan");
	}
});
