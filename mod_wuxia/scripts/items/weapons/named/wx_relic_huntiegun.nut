// Historical Famous Rare Weapon: 传世·紧那罗混铁盘龙棍 (Staff)

this.wx_relic_huntiegun <- this.inherit("scripts/items/weapons/named/named_two_handed_mace", {
	m = {},

	function create()
	{
		this.named_two_handed_mace.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_huntiegun");
	}

	function onDeserialize( _in )
	{
		this.named_two_handed_mace.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_huntiegun");
	}
});
