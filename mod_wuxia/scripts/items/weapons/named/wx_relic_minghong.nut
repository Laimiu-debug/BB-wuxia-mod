// Historical Famous Rare Weapon: 传世·鸣鸿古刀 (Saber)

this.wx_relic_minghong <- this.inherit("scripts/items/weapons/named/named_khopesh", {
	m = {},

	function create()
	{
		this.named_khopesh.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_minghong");
	}

	function onDeserialize( _in )
	{
		this.named_khopesh.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_minghong");
	}
});
