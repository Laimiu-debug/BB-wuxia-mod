// Tier 2 Paired Fist Weapon: 精铁指虎 (Mid-tier iron knuckles/bracers, Weaponsmith stock)

this.wx_fist_iron <- this.inherit("scripts/items/weapons/wx_fist_base", {
	m = {},

	function create()
	{
		this.wx_fist_base.create();
		this.wxInitPlaceholderVisual("bludgeon");
		this.m.ID = "weapon.wx_fist_iron";
		this.m.Name = "精铁指虎";
		this.m.Description = "配乌皮护腕的成对精铁指虎，出拳力透重衣，兼顾拆招格挡与透甲钝劲。";
		this.m.IconLarge = "weapons/melee/wx_fist_iron.png";
		this.m.Icon = "weapons/melee/wx_fist_iron_70x70.png";
		this.m.ShowArmamentIcon = true;
		this.m.ArmamentIcon = "arm_wx_fist_iron";
		this.m.WX_ArmBrush <- "arm_wx_fist_iron";
		this.m.Value = 850;
		this.m.Condition = 64.0;
		this.m.ConditionMax = 64.0;
		this.m.StaminaModifier = -6;
		this.m.RegularDamage = 34;
		this.m.RegularDamageMax = 48;
		this.m.ArmorDamageMult = 0.95;
		this.m.DirectDamageMult = 0.40;
	}
});
