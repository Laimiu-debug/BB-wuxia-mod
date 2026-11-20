// Historical Famous Rare Weapon: 传世·昆吾割玉弯刀 (Saber)

this.wx_relic_kunwu <- this.inherit("scripts/items/weapons/named/named_two_handed_scimitar", {
	m = {},

	function create()
	{
		this.named_two_handed_scimitar.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_kunwu");
	}

	function onDeserialize( _in )
	{
		this.named_two_handed_scimitar.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_kunwu");
	}
});
