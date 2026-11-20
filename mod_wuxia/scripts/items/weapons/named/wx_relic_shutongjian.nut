// Historical Famous Rare Weapon: 传世·四棱熟铜瓦面锏 (Hammer)

this.wx_relic_shutongjian <- this.inherit("scripts/items/weapons/named/named_warhammer", {
	m = {},

	function create()
	{
		this.named_warhammer.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_shutongjian");
	}

	function onDeserialize( _in )
	{
		this.named_warhammer.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_shutongjian");
	}
});
