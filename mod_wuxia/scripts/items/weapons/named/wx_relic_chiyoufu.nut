// Shan Hai Divine Red Weapon: 传世·凶黎蚩尤五兵裂天钺 (Axe)
this.wx_relic_chiyoufu <- this.inherit("scripts/items/weapons/named/named_bardiche", {
	m = {},
	function create()
	{
		this.named_bardiche.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_chiyoufu");
	}
	function onDeserialize( _in )
	{
		this.named_bardiche.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_chiyoufu");
	}
});
