// Historical Famous Rare Weapon: 传世·云梦软金九节龙鞭 (Flail)

this.wx_relic_dashenbian <- this.inherit("scripts/items/weapons/named/named_battle_whip", {
	m = {},

	function create()
	{
		this.named_battle_whip.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_dashenbian");
	}

	function onDeserialize( _in )
	{
		this.named_battle_whip.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_dashenbian");
	}
});
