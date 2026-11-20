// Historical Famous Rare Weapon: 传世·破虏神机钩镰枪 (Polearm)

this.wx_relic_goulianqiang <- this.inherit("scripts/items/weapons/named/named_bladed_pike", {
	m = {},

	function create()
	{
		this.named_bladed_pike.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_goulianqiang");
	}

	function onDeserialize( _in )
	{
		this.named_bladed_pike.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_goulianqiang");
	}
});
