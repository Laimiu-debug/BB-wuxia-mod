// Historical Famous Rare Weapon: 传世·达摩伏虎金刚护腕 (Fist)

this.wx_relic_jingangwan <- this.inherit("scripts/items/weapons/named/wx_named_fist", {
	m = {},

	function create()
	{
		this.wx_named_fist.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_jingangwan");
	}

	function onDeserialize( _in )
	{
		this.wx_named_fist.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_jingangwan");
	}
});
