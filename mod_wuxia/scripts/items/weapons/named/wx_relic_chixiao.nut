// Historical Famous Rare Weapon: 传世·赤霄斩蛇长剑 (Sword)

this.wx_relic_chixiao <- this.inherit("scripts/items/weapons/named/named_warbrand", {
	m = {},

	function create()
	{
		this.named_warbrand.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_chixiao");
	}

	function onDeserialize( _in )
	{
		this.named_warbrand.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_chixiao");
	}
});
