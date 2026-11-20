// Historical Famous Rare Weapon: 传世·混金八卦宣花大斧 (Axe)

this.wx_relic_xuanhuafu <- this.inherit("scripts/items/weapons/named/named_greataxe", {
	m = {},

	function create()
	{
		this.named_greataxe.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_xuanhuafu");
	}

	function onDeserialize( _in )
	{
		this.named_greataxe.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_xuanhuafu");
	}
});
