// Shared Base for Craftable Beast Armor Attachments (`armor_upgrade.wx_up_*`)
// Supports Forging Stat Ranges & 0-byte Variant-packed Save Persistence via `::Wuxia.Forge`!

this.wx_beast_upgrade_base <- this.inherit("scripts/items/armor_upgrades/armor_upgrade", {
	m = {
		UpgID              = "",
		RolledInitBonus    = null,
		RolledBraveryBonus = null,
		RolledRangedMult   = null,
		RolledArmorDmgMult = null,
		RolledBonusText    = null
	},

	function create()
	{
		this.armor_upgrade.create();
		local ref = ::new("scripts/items/armor_upgrades/direwolf_pelt_upgrade");
		if (::Wuxia.hasMember(ref.m, "InventorySound")) this.m.InventorySound = ref.m.InventorySound;
		if (::Wuxia.hasMember(ref.m, "Type")) this.m.Type = ref.m.Type;
	}

	function initBeastUpgrade( _upgID )
	{
		this.m.UpgID = _upgID;
		::Wuxia.BeastCraft.applyBeastUpgrade(this, _upgID, false);
	}

	function updateVariant()
	{
		local cfg = this.getUpgCfg();
		if (cfg != null)
			this.m.Icon = "armor_upgrades/" + cfg.BackBrush + ".png";
	}

	function getUpgCfg()
	{
		if ("BeastGear" in ::Wuxia.Config && (this.m.UpgID in ::Wuxia.Config.BeastGear))
			return ::Wuxia.Config.BeastGear[this.m.UpgID];
		return null;
	}

	function getEffectiveBonusText()
	{
		if (this.m.RolledBonusText != null && this.m.RolledBonusText != "")
			return this.m.RolledBonusText;
		local cfg = this.getUpgCfg();
		return cfg != null ? cfg.BonusText : "";
	}

	function getTooltip()
	{
		local ret = this.armor_upgrade.getTooltip();
		local cfg = this.getUpgCfg();
		if (cfg != null)
		{
			ret.push({
				id = 69,
				type = "text",
				icon = "ui/icons/special.png",
				text = "[color=#094039]【百工镶缀】[/color]" + this.getEffectiveBonusText()
			});
		}
		if ("Forge" in ::Wuxia && "injectForgeTooltip" in ::Wuxia.Forge)
			ret = ::Wuxia.Forge.injectForgeTooltip(this, ret);
		return ret;
	}

	function onArmorTooltip( _result )
	{
		local cfg = this.getUpgCfg();
		if (cfg != null && _result != null)
		{
			local gradeTag = "";
			if (("WX_ForgeGradeTitle" in this.m) && this.m.WX_ForgeGradeTitle != null && this.m.WX_ForgeGradeTitle != "")
				gradeTag = this.m.WX_ForgeGradeTitle + "·";
			_result.push({
				id = 69,
				type = "text",
				icon = "ui/icons/special.png",
				text = "[color=#094039]【" + gradeTag + cfg.Name + "】[/color]" + this.getEffectiveBonusText()
			});
		}
	}

	function onUpdateProperties( _properties )
	{
		this.armor_upgrade.onUpdateProperties(_properties);
		local cfg = this.getUpgCfg();
		if (cfg == null) return;
		local initB = (this.m.RolledInitBonus != null) ? this.m.RolledInitBonus : cfg.InitiativeBonus;
		local bravB = (this.m.RolledBraveryBonus != null) ? this.m.RolledBraveryBonus : cfg.BraveryBonus;
		local rngM  = (this.m.RolledRangedMult != null) ? this.m.RolledRangedMult : cfg.RangedMult;
		local armM  = (this.m.RolledArmorDmgMult != null) ? this.m.RolledArmorDmgMult : cfg.ArmorDmgMult;

		if (initB != 0) _properties.Initiative += initB;
		if (bravB != 0) _properties.Bravery += bravB;
		if (rngM != 1.0) _properties.DamageReceivedRangedMult *= rngM;
		if (armM != 1.0) _properties.DamageReceivedArmorMult *= armM;
		if (cfg.PoisonImmune) _properties.IsImmuneToPoison = true;
	}

	function onDeserialize( _in )
	{
		this.armor_upgrade.onDeserialize(_in);
		::Wuxia.BeastCraft.applyBeastUpgrade(this, this.m.UpgID, true);
		if ("Forge" in ::Wuxia && "restoreFromVariant" in ::Wuxia.Forge)
			::Wuxia.Forge.restoreFromVariant(this);
	}
});
