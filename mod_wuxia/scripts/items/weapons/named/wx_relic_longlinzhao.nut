// Historical Famous Rare Weapon: 传世·天蚕乌金龙鳞爪 (Fist)

this.wx_relic_longlinzhao <- this.inherit("scripts/items/weapons/named/wx_named_fist", {
	m = {},

	function create()
	{
		this.wx_named_fist.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_longlinzhao");
	}

	function onDeserialize( _in )
	{
		this.wx_named_fist.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_longlinzhao");
	}
});
