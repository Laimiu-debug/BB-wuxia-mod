// Historical Famous Rare Weapon: 传世·薛家震天铁胎神弓 (Bow)

this.wx_relic_zhentiangong <- this.inherit("scripts/items/weapons/named/named_warbow", {
	m = {},

	function create()
	{
		this.named_warbow.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_zhentiangong");
	}

	function onDeserialize( _in )
	{
		this.named_warbow.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_zhentiangong");
	}
});
