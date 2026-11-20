// Historical Famous Rare Weapon: 传世·呼延乌金竹节钢鞭 (Flail)

this.wx_relic_wujinbian <- this.inherit("scripts/items/weapons/named/named_three_headed_flail", {
	m = {},

	function create()
	{
		this.named_three_headed_flail.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_wujinbian");
	}

	function onDeserialize( _in )
	{
		this.named_three_headed_flail.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_wujinbian");
	}
});
