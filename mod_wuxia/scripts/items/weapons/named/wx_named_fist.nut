// Tier 4 Named Red Fist Weapon: 传世名器护手 (100% native BB named_weapon random roll integration + custom paperdoll gauntlets!)

this.wx_named_fist <- this.inherit("scripts/items/weapons/named/named_weapon", {
	m = {
		WX_VariantIdx = 4
	},

	function create()
	{
		this.named_weapon.create();
		local ref = ::new("scripts/items/weapons/goedendag");
		this.m.EquipSound = ref.m.EquipSound;

		this.m.ID = "weapon.wx_named_fist";
		this.m.NameList = ["龙鳞护手", "乌金铁掌套", "玄铁缠丝腕", "伏虎金刚拳套", "寒铁擒龙爪", "裂山鹰爪套"];
		this.m.PrefixList = ["传世", "百炼", "破岳", "碎甲", "镇派", "无双"];
		this.m.Categories = "拳掌护手, 双手";
		this.m.SlotType = this.Const.ItemSlot.Mainhand;
		this.m.BlockedSlotType = this.Const.ItemSlot.Offhand;
		this.m.ItemType = this.Const.Items.ItemType.Named | this.Const.Items.ItemType.Weapon | this.Const.Items.ItemType.MeleeWeapon | this.Const.Items.ItemType.TwoHanded;
		this.m.IsDoubleGrippable = false;
		this.m.IsAgainstShields = false;
		this.m.IsAoE = false;
		this.m.AddGenericSkill = true;
		this.m.ShowQuiver = false;
		this.m.ChanceToHitHead = 5;

		this.m.Value = 4800;
		this.m.Condition = 80.0;
		this.m.ConditionMax = 80.0;
		this.m.StaminaModifier = -10;
		this.m.RegularDamage = 44;
		this.m.RegularDamageMax = 62;
		this.m.ArmorDamageMult = 1.10;
		this.m.DirectDamageMult = 0.45;

		this.m.WX_VariantIdx = ::Math.rand(4, 9);
		this.wxApplyFistVisual();
		this.randomizeValues();
		local pfx = this.m.PrefixList[::Math.rand(0, this.m.PrefixList.len() - 1)];
		local baseTitle = this.m.NameList[::Math.rand(0, this.m.NameList.len() - 1)];
		this.m.Name = pfx + "·" + baseTitle;
	}

	function wxApplyFistVisual()
	{
		local v = "wx_wpn_fist_0" + this.m.WX_VariantIdx;
		this.m.ID = "weapon.wx_named_fist";
		this.m.IconLarge = "weapons/melee/" + v + ".png";
		this.m.Icon = "weapons/melee/" + v + "_70x70.png";
		this.m.ShowArmamentIcon = true;
		this.m.ArmamentIcon = "arm_" + v;
		this.m.WX_ArmBrush <- "arm_" + v;
		this.m.WX_MappedID <- this.m.ID;
		this.m.WX_ExpectedIcon <- this.m.Icon;
	}

	function onEquip()
	{
		this.named_weapon.onEquip();

		local jab = ::new("scripts/skills/actives/wx_fist_jab");
		jab.m.DirectDamageMult = this.m.DirectDamageMult;
		this.addSkill(jab);

		local shock = ::new("scripts/skills/actives/wx_fist_shock");
		shock.m.DirectDamageMult = this.m.DirectDamageMult;
		this.addSkill(shock);
	}

	function onDeserialize( _in )
	{
		this.named_weapon.onDeserialize(_in);
		this.wxApplyFistVisual();
	}
});
