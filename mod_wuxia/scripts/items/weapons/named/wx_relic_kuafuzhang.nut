// Shan Hai Divine Red Weapon: 传世·逐日夸父邓林盘桃杖 (Staff)
this.wx_relic_kuafuzhang <- this.inherit("scripts/items/weapons/named/named_two_handed_mace", {
	m = {},
	function create()
	{
		this.named_two_handed_mace.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_kuafuzhang");
	}
	function onDeserialize( _in )
	{
		this.named_two_handed_mace.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_kuafuzhang");
	}
});
