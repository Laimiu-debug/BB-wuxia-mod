// Historical Famous Rare Weapon: 传世·温侯方天画戟 (Polearm)

this.wx_relic_huaji <- this.inherit("scripts/items/weapons/named/named_billhook", {
	m = {},

	function create()
	{
		this.named_billhook.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_huaji");
	}

	function onDeserialize( _in )
	{
		this.named_billhook.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_huaji");
	}
});
