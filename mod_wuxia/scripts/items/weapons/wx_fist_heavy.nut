// Tier 3 Paired Fist Weapon: 玄铁拳套 (High-tier heavy gauntlets, Weaponsmith / Shaolin elite gear)

this.wx_fist_heavy <- this.inherit("scripts/items/weapons/wx_fist_base", {
	m = {},

	function create()
	{
		this.wx_fist_base.create();
		this.wxInitPlaceholderVisual("goedendag");
		this.m.ID = "weapon.wx_fist_heavy";
		this.m.Name = "玄铁拳套";
		this.m.Description = "名炉百炼的沉重成对玄铁护手，拳锋暗藏破甲棱刺，掌力雄浑者戴之可硬撼铁甲重兵。";
		this.m.IconLarge = "weapons/melee/wx_fist_heavy.png";
		this.m.Icon = "weapons/melee/wx_fist_heavy_70x70.png";
		this.m.ShowArmamentIcon = true;
		this.m.ArmamentIcon = "arm_wx_fist_heavy";
		this.m.WX_ArmBrush <- "arm_wx_fist_heavy";
		this.m.Value = 2300;
		this.m.Condition = 80.0;
		this.m.ConditionMax = 80.0;
		this.m.StaminaModifier = -10;
		this.m.RegularDamage = 44;
		this.m.RegularDamageMax = 62;
		this.m.ArmorDamageMult = 1.10;
		this.m.DirectDamageMult = 0.45;
	}
});
