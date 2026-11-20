// Historical Famous Rare Weapon: 传世·莫邪流水阴剑 (Sword)

this.wx_relic_moye <- this.inherit("scripts/items/weapons/named/named_shamshir", {
	m = {},

	function create()
	{
		this.named_shamshir.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_moye");
	}

	function onDeserialize( _in )
	{
		this.named_shamshir.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_moye");
	}
});
