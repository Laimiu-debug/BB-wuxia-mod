// Historical Famous Rare Weapon: 传世·承影细剑 (Sword)

this.wx_relic_chengying <- this.inherit("scripts/items/weapons/named/named_fencing_sword", {
	m = {},

	function create()
	{
		this.named_fencing_sword.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_chengying");
	}

	function onDeserialize( _in )
	{
		this.named_fencing_sword.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_chengying");
	}
});
