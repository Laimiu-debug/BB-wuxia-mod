// Historical Famous Rare Weapon: 传世·赵氏神机五雷连铳 (Firearm)

this.wx_relic_xunleichong <- this.inherit("scripts/items/weapons/named/named_handgonne", {
	m = {},

	function create()
	{
		this.named_handgonne.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_xunleichong");
	}

	function onDeserialize( _in )
	{
		this.named_handgonne.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_xunleichong");
	}
});
