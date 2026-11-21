// Shan Hai Divine Red Weapon: 传世·玉山虎蛟裂甲铁链枷 (Flail)
this.wx_relic_hujiaobian <- this.inherit("scripts/items/weapons/named/named_three_headed_flail", {
	m = {},
	function create()
	{
		this.named_three_headed_flail.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_hujiaobian");
	}
	function onDeserialize( _in )
	{
		this.named_three_headed_flail.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_hujiaobian");
	}
});
