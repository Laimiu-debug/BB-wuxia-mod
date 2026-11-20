// Historical Famous Rare Weapon: 传世·天下丐帮绿玉竹杖 (Staff)

this.wx_relic_lvzhuzhang <- this.inherit("scripts/items/weapons/named/named_mace", {
	m = {},

	function create()
	{
		this.named_mace.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_lvzhuzhang");
	}

	function onDeserialize( _in )
	{
		this.named_mace.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_lvzhuzhang");
	}
});
