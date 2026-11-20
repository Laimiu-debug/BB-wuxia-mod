// Historical Famous Rare Weapon: 传世·专诸鱼肠短剑 (Dagger)

this.wx_relic_yuchang <- this.inherit("scripts/items/weapons/named/named_dagger", {
	m = {},

	function create()
	{
		this.named_dagger.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_yuchang");
	}

	function onDeserialize( _in )
	{
		this.named_dagger.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_yuchang");
	}
});
