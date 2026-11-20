// Shared base for paired Fist / Gauntlet weapons (occupies both Mainhand & Offhand to prevent shield pairing, 4 AP fast strikes)

this.wx_fist_base <- this.inherit("scripts/items/weapons/weapon", {
	m = {},

	function create()
	{
		this.weapon.create();
		this.m.Categories = "拳掌护手, 双手";
		this.m.SlotType = this.Const.ItemSlot.Mainhand;
		this.m.BlockedSlotType = this.Const.ItemSlot.Offhand;
		this.m.ItemType = this.Const.Items.ItemType.Weapon | this.Const.Items.ItemType.MeleeWeapon | this.Const.Items.ItemType.TwoHanded;
		this.m.IsDoubleGrippable = false;
		this.m.IsAgainstShields = false;
		this.m.IsAoE = false;
		this.m.AddGenericSkill = true;
		this.m.ShowQuiver = false;
		this.m.ShowArmamentIcon = false;
		this.m.ArmamentIcon = "";
		this.m.ChanceToHitHead = 5;
	}

	function wxInitPlaceholderVisual( _vanillaWeaponName )
	{
		local ref = ::new("scripts/items/weapons/" + _vanillaWeaponName);
		this.m.IconLarge = ref.m.IconLarge;
		this.m.Icon = ref.m.Icon;
		this.m.EquipSound = ref.m.EquipSound;
	}

	function onEquip()
	{
		this.weapon.onEquip();

		local jab = ::new("scripts/skills/actives/wx_fist_jab");
		jab.m.DirectDamageMult = this.m.DirectDamageMult;
		this.addSkill(jab);

		local shock = ::new("scripts/skills/actives/wx_fist_shock");
		shock.m.DirectDamageMult = this.m.DirectDamageMult;
		this.addSkill(shock);
	}
});
