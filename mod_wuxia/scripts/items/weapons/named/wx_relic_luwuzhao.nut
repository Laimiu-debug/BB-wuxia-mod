// Shan Hai Divine Red Weapon: 传世·昆仑陆吾司天九尾爪 (Fist)
this.wx_relic_luwuzhao <- this.inherit("scripts/items/weapons/named/wx_named_fist", {
	m = {},
	function create()
	{
		this.wx_named_fist.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_luwuzhao");
	}
	function onDeserialize( _in )
	{
		this.wx_named_fist.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_luwuzhao");
	}
});
