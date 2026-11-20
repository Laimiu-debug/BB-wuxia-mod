// Shan Hai Ferocious Relic Weapon: 传世·刑天舞干断首戚 (Axe)

this.wx_relic_xingtianqi <- this.inherit("scripts/items/weapons/named/named_heavy_rusty_axe", {
	m = {},

	function create()
	{
		this.named_heavy_rusty_axe.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_xingtianqi");
	}

	function onDeserialize( _in )
	{
		this.named_heavy_rusty_axe.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_xingtianqi");
	}
});
