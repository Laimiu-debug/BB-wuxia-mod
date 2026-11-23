// Data-driven Base Class for Shan Hai Jing Mythical Talismans & Accessories (山海百工奇珍异佩)
// Strictly adheres to AGENTS.md anti-bloat guardrails: zero MeleeSkill/RangedSkill bloat, MeleeDef/RangedDef <= +5!
// Supports Forging Stat Ranges & 0-byte Variant-packed Save Persistence via `::Wuxia.Forge`!

this.wx_shanhai_acc_base <- this.inherit("scripts/items/accessory/accessory", {
	m = {
		GearID            = "",
		RolledBonuses     = null,
		RolledTooltipRows = null
	},

	function create()
	{
		this.accessory.create();
		local ref = ::new("scripts/items/accessory/hexen_trophy_item");
		this.m.Icon = ref.m.Icon;
		this.m.SlotType = this.Const.ItemSlot.Accessory;
		this.m.ItemType = this.Const.Items.ItemType.Accessory;
		this.m.IsDroppedAsLoot = true;
		this.m.ShowOnCharacter = false;
		this.m.Value = 5000;
	}

	function initShanHaiAccessory( _gearID )
	{
		this.m.GearID = _gearID;
		this.m.WX_ShanHaiGearID <- _gearID;
		if (!(_gearID in ::Wuxia.Config.ShanHaiGear)) return;
		local cfg = ::Wuxia.Config.ShanHaiGear[_gearID];
		this.m.ID = "accessory." + cfg.ID;
		this.m.Name = cfg.Name;
		this.m.Description = cfg.Description;
		this.m.Value = cfg.Value;
		if (cfg.CustomIcon != null) this.m.Icon = cfg.CustomIcon;
		this.m.WX_MappedID <- this.m.ID;
		this.m.WX_ExpectedIcon <- this.m.Icon;
	}

	function updateVariant()
	{
		if (this.m.GearID != "" && (this.m.GearID in ::Wuxia.Config.ShanHaiGear))
		{
			local cfg = ::Wuxia.Config.ShanHaiGear[this.m.GearID];
			if (cfg.CustomIcon != null) this.m.Icon = cfg.CustomIcon;
		}
	}

	function getEffectiveBonuses()
	{
		if (this.m.RolledBonuses != null)
			return this.m.RolledBonuses;
		if (this.m.GearID in ::Wuxia.Config.ShanHaiGear)
		{
			local cfg = ::Wuxia.Config.ShanHaiGear[this.m.GearID];
			if ("Bonuses" in cfg && cfg.Bonuses != null)
				return cfg.Bonuses;
		}
		return null;
	}

	function getTooltip()
	{
		local ret = this.accessory.getTooltip();
		if (!(this.m.GearID in ::Wuxia.Config.ShanHaiGear)) return ret;
		local cfg = ::Wuxia.Config.ShanHaiGear[this.m.GearID];
		local lines = (this.m.RolledTooltipRows != null)
			? this.m.RolledTooltipRows
			: (("TooltipLines" in cfg) ? cfg.TooltipLines : null);
		if (lines != null)
		{
			local tid = 11;
			foreach (row in lines)
			{
				ret.push({
					id = tid,
					type = "text",
					icon = row.Icon,
					text = row.Text
				});
				tid += 1;
			}
		}
		if ("Forge" in ::Wuxia && "injectForgeTooltip" in ::Wuxia.Forge)
		{
			ret = ::Wuxia.Forge.injectForgeTooltip(this, ret);
		}
		if ("ShanHaiSets" in ::Wuxia && "injectSetTooltip" in ::Wuxia.ShanHaiSets)
		{
			ret = ::Wuxia.ShanHaiSets.injectSetTooltip(this, ret);
		}
		return ret;
	}

	function onUpdateProperties( _properties )
	{
		this.accessory.onUpdateProperties(_properties);
		local b = this.getEffectiveBonuses();
		if (b == null) return;

		if ("Hitpoints" in b) _properties.Hitpoints += b.Hitpoints;
		if ("Stamina" in b) _properties.Stamina += b.Stamina;
		if ("FatigueRecoveryRate" in b) _properties.FatigueRecoveryRate += b.FatigueRecoveryRate;
		if ("Bravery" in b) _properties.Bravery += b.Bravery;
		if ("Initiative" in b) _properties.Initiative += b.Initiative;
		if ("MeleeDefense" in b) _properties.MeleeDefense += ::Math.min(5, b.MeleeDefense);
		if ("RangedDefense" in b) _properties.RangedDefense += ::Math.min(5, b.RangedDefense);
		if ("Vision" in b) _properties.Vision += b.Vision;
		if ("XPGainMult" in b) _properties.XPGainMult *= b.XPGainMult;
		if ("RangedReceivedMult" in b) _properties.DamageReceivedRangedMult *= b.RangedReceivedMult;
		if (("NightOwl" in b) && b.NightOwl)
			_properties.IsAffectedByNight = false;
		if (("ImmuneStun" in b) && b.ImmuneStun)
			_properties.IsImmuneToStun = true;
		if (("ImmuneKnockback" in b) && b.ImmuneKnockback)
			_properties.IsImmuneToKnockBackAndGrab = true;
		if (("PoisonImmune" in b) && b.PoisonImmune)
			_properties.IsImmuneToPoison = true;
		if (("AntiFearBravery" in b) && typeof _properties.MoraleCheckBravery == "array" && _properties.MoraleCheckBravery.len() > 0)
			_properties.MoraleCheckBravery[0] += b.AntiFearBravery;
	}

	function onDeserialize( _in )
	{
		this.accessory.onDeserialize(_in);
		this.initShanHaiAccessory(this.m.GearID);
		if ("Forge" in ::Wuxia && "restoreFromVariant" in ::Wuxia.Forge)
			::Wuxia.Forge.restoreFromVariant(this);
	}
});
