// Shan Hai Divine Red Weapon: 传世·中曲铁驳食虎独角锏 (Hammer)
this.wx_relic_bojian <- this.inherit("scripts/items/weapons/named/named_warhammer", {
	m = {},
	function create()
	{
		this.named_warhammer.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_bojian");
	}
	function onDeserialize( _in )
	{
		this.named_warhammer.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_bojian");
	}
});
