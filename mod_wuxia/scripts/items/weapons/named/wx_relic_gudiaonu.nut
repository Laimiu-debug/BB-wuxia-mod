// Shan Hai Divine Red Weapon: 传世·鹿吴蛊雕裂颅重弩 (Crossbow)
this.wx_relic_gudiaonu <- this.inherit("scripts/items/weapons/named/named_crossbow", {
	m = {},
	function create()
	{
		this.named_crossbow.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_gudiaonu");
	}
	function onDeserialize( _in )
	{
		this.named_crossbow.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_gudiaonu");
	}
});
