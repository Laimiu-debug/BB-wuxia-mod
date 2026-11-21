// Tier 1 Paired Fist Weapon: 麻布缠手 (Common starter wraps, Marketplace stock)

this.wx_fist_wraps <- this.inherit("scripts/items/weapons/wx_fist_base", {
	m = {},

	function create()
	{
		this.wx_fist_base.create();
		this.wxInitPlaceholderVisual("wooden_stick");
		this.m.ID = "weapon.wx_fist_wraps";
		this.m.Name = "麻布缠手";
		this.m.Description = "浸过药汁的粗麻缠手布，成对裹紧双拳指节以防挫伤。轻便灵巧，适合施展各路拳掌功夫。";
		this.m.IconLarge = "weapons/melee/wx_fist_wraps.png";
		this.m.Icon = "weapons/melee/wx_fist_wraps_70x70.png";
		this.m.ShowArmamentIcon = true;
		this.m.ArmamentIcon = "arm_wx_fist_wraps";
		this.m.WX_ArmBrush <- "arm_wx_fist_wraps";
		this.m.Value = 160;
		this.m.Condition = 48.0;
		this.m.ConditionMax = 48.0;
		this.m.StaminaModifier = -2;
		this.m.RegularDamage = 22;
		this.m.RegularDamageMax = 32;
		this.m.ArmorDamageMult = 0.75;
		this.m.DirectDamageMult = 0.35;
	}
});
