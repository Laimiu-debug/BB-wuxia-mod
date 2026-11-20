// Historical Famous Rare Weapon: 传世·玄铁沉水重宝刀 (Cleaver)

this.wx_relic_tulong <- this.inherit("scripts/items/weapons/named/named_rusty_warblade", {
	m = {},

	function create()
	{
		this.named_rusty_warblade.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_tulong");
	}

	function onDeserialize( _in )
	{
		this.named_rusty_warblade.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_tulong");
	}
});
