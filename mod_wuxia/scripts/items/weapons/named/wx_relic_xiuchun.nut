// Historical Famous Rare Weapon: 传世·御赐龙鳞绣春刀 (Saber)

this.wx_relic_xiuchun <- this.inherit("scripts/items/weapons/named/named_cleaver", {
	m = {},

	function create()
	{
		this.named_cleaver.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_xiuchun");
	}

	function onDeserialize( _in )
	{
		this.named_cleaver.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_xiuchun");
	}
});
