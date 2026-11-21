// Shan Hai Divine Red Weapon: 传世·不周共工怒触天倾槊 (Spear)
this.wx_relic_gonggongshuo <- this.inherit("scripts/items/weapons/named/named_spetum", {
	m = {},
	function create()
	{
		this.named_spetum.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_gonggongshuo");
	}
	function onDeserialize( _in )
	{
		this.named_spetum.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_gonggongshuo");
	}
});
