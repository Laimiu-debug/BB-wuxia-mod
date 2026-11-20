// Historical Famous Rare Weapon: 传世·商周饕餮青铜重钺 (Axe)

this.wx_relic_pochengyue <- this.inherit("scripts/items/weapons/named/named_bardiche", {
	m = {},

	function create()
	{
		this.named_bardiche.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_pochengyue");
	}

	function onDeserialize( _in )
	{
		this.named_bardiche.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_pochengyue");
	}
});
