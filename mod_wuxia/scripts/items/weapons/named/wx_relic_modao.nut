// Historical Famous Rare Weapon: 传世·大唐嗣业斩马陌刀 (Cleaver)

this.wx_relic_modao <- this.inherit("scripts/items/weapons/named/named_crypt_cleaver", {
	m = {},

	function create()
	{
		this.named_crypt_cleaver.create();
		::Wuxia.Relics.applyRelic(this, "wx_relic_modao");
	}

	function onDeserialize( _in )
	{
		this.named_crypt_cleaver.onDeserialize(_in);
		::Wuxia.Relics.applyArtOverridesOnly(this, "wx_relic_modao");
	}
});
