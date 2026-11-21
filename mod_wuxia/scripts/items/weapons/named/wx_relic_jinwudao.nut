// Shan Hai Divine Red Weapon: 传世·汤谷金乌十日焚天刀 (Saber)
this.wx_relic_jinwudao <- this.inherit("scripts/items/weapons/named/named_khopesh", {
	m = {},
	function create()
	{
		this.named_khopesh.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_jinwudao");
	}
	function onDeserialize( _in )
	{
		this.named_khopesh.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_jinwudao");
	}
});
