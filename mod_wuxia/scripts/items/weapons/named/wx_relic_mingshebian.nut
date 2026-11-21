// Shan Hai Divine Red Weapon: 传世·鲜山鸣蛇四翼磬音鞭 (Flail)
this.wx_relic_mingshebian <- this.inherit("scripts/items/weapons/named/named_battle_whip", {
	m = {},
	function create()
	{
		this.named_battle_whip.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_mingshebian");
	}
	function onDeserialize( _in )
	{
		this.named_battle_whip.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_mingshebian");
	}
});
