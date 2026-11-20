// Shan Hai Ferocious Relic Weapon: 传世·穷奇裂风血骨爪 (Fist)

this.wx_relic_qiongqizhao <- this.inherit("scripts/items/weapons/named/wx_named_fist", {
	m = {},

	function create()
	{
		this.wx_named_fist.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_qiongqizhao");
	}

	function onDeserialize( _in )
	{
		this.wx_named_fist.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_qiongqizhao");
	}
});
