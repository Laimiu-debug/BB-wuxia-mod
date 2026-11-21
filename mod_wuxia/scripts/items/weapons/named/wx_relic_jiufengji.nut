// Shan Hai Divine Red Weapon: 传世·北极九凤泣血摄魂戟 (Polearm)
this.wx_relic_jiufengji <- this.inherit("scripts/items/weapons/named/named_swordlance", {
	m = {},
	function create()
	{
		this.named_swordlance.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_jiufengji");
	}
	function onDeserialize( _in )
	{
		this.named_swordlance.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_jiufengji");
	}
});
