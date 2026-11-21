// Shan Hai Divine Red Weapon: 传世·共工相柳九首蚀骨枪 (Spear)
this.wx_relic_xiangliuqiang <- this.inherit("scripts/items/weapons/named/named_spear", {
	m = {},
	function create()
	{
		this.named_spear.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_xiangliuqiang");
	}
	function onDeserialize( _in )
	{
		this.named_spear.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_xiangliuqiang");
	}
});
