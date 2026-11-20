// Historical Famous Rare Weapon: 传世·沥泉盘龙神枪 (Spear)

this.wx_relic_liquan <- this.inherit("scripts/items/weapons/named/named_spear", {
	m = {},

	function create()
	{
		this.named_spear.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_liquan");
	}

	function onDeserialize( _in )
	{
		this.named_spear.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_liquan");
	}
});
