// Shan Hai Divine Red Weapon: 传世·厌火祸斗喷炎神铳 (Firearm)
this.wx_relic_huodouchong <- this.inherit("scripts/items/weapons/named/named_handgonne", {
	m = {},
	function create()
	{
		this.named_handgonne.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_huodouchong");
	}
	function onDeserialize( _in )
	{
		this.named_handgonne.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_huodouchong");
	}
});
