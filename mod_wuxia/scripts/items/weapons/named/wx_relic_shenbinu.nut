// Historical Famous Rare Weapon: 传世·大宋克敌神臂重弩 (Crossbow)

this.wx_relic_shenbinu <- this.inherit("scripts/items/weapons/named/named_crossbow", {
	m = {},

	function create()
	{
		this.named_crossbow.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_shenbinu");
	}

	function onDeserialize( _in )
	{
		this.named_crossbow.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_shenbinu");
	}
});
