// Historical Famous Rare Weapon: 传世·徐夫人淬血寒匕 (Dagger)

this.wx_relic_xufuren <- this.inherit("scripts/items/weapons/named/named_qatal_dagger", {
	m = {},

	function create()
	{
		this.named_qatal_dagger.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_xufuren");
	}

	function onDeserialize( _in )
	{
		this.named_qatal_dagger.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_xufuren");
	}
});
