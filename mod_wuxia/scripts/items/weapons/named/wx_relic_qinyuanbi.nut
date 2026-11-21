// Shan Hai Divine Red Weapon: 传世·昆仑钦原蜇石蚀骨刺 (Dagger)
this.wx_relic_qinyuanbi <- this.inherit("scripts/items/weapons/named/named_qatal_dagger", {
	m = {},
	function create()
	{
		this.named_qatal_dagger.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_qinyuanbi");
	}
	function onDeserialize( _in )
	{
		this.named_qatal_dagger.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_qinyuanbi");
	}
});
