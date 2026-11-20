// Historical Famous Rare Weapon: 传世·辽东玄铁开山长斧 (Axe)

this.wx_relic_kaitian_changfu <- this.inherit("scripts/items/weapons/named/named_poleaxe", {
	m = {},

	function create()
	{
		this.named_poleaxe.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_kaitian_changfu");
	}

	function onDeserialize( _in )
	{
		this.named_poleaxe.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_kaitian_changfu");
	}
});
