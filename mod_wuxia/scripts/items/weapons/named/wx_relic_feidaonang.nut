// Historical Famous Rare Weapon: 传世·百炼寒星柳叶飞刀 (Throwing)

this.wx_relic_feidaonang <- this.inherit("scripts/items/weapons/named/named_javelin", {
	m = {},

	function create()
	{
		this.named_javelin.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_feidaonang");
	}

	function onDeserialize( _in )
	{
		this.named_javelin.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_feidaonang");
	}
});
