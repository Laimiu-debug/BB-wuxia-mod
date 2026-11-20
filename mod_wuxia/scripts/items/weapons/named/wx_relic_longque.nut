// Historical Famous Rare Weapon: 传世·大夏龙雀宝刀 (Saber)

this.wx_relic_longque <- this.inherit("scripts/items/weapons/named/named_cleaver", {
	m = {},

	function create()
	{
		this.named_cleaver.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_longque");
	}

	function onDeserialize( _in )
	{
		this.named_cleaver.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_longque");
	}
});
