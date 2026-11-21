// Shan Hai Divine Red Weapon: 传世·昆仑英招四海巡狩弓 (Bow)
this.wx_relic_yingzhaogong <- this.inherit("scripts/items/weapons/named/named_warbow", {
	m = {},
	function create()
	{
		this.named_warbow.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_yingzhaogong");
	}
	function onDeserialize( _in )
	{
		this.named_warbow.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_yingzhaogong");
	}
});
