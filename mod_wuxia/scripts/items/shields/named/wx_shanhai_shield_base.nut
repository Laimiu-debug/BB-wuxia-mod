// Base Class for Famed Shan Hai Masterwork Shields (山海百工传世神盾)
// Inherits proven `heater_shield`, adds Named famed item status, rolled red-tier bonuses, custom `shd_*` paperdoll brush & full save serialization!

this.wx_shanhai_shield_base <- this.inherit("scripts/items/shields/heater_shield", {
	m = {
		GearID = ""
	},

	function create()
	{
		this.heater_shield.create();
		this.m.ItemType = this.m.ItemType | this.Const.Items.ItemType.Named;
	}

	function initShanHaiShield( _gearID, _onDeserializeOnly = false )
	{
		this.m.GearID = _gearID;
		if (!(_gearID in ::Wuxia.Config.ShanHaiGear)) return;
		local cfg = ::Wuxia.Config.ShanHaiGear[_gearID];

		this.m.ID = "shield." + cfg.ID;
		this.m.Name = cfg.Name;
		this.m.Description = cfg.Description;
		this.m.Value = cfg.Value;

		if (!_onDeserializeOnly)
		{
			local condRoll = ::Math.rand(0, 14);
			local mdefRoll = ::Math.rand(1, 3);
			local rdefRoll = ::Math.rand(1, 3);
			local baseMDef = ("BaseMDef" in cfg) ? cfg.BaseMDef : (("MeleeDefense" in cfg) ? cfg.MeleeDefense : 20);
			local baseRDef = ("BaseRDef" in cfg) ? cfg.BaseRDef : (("RangedDefense" in cfg) ? cfg.RangedDefense : 24);
			this.m.ConditionMax = cfg.MinCondition + condRoll;
			this.m.Condition = this.m.ConditionMax;
			this.m.MeleeDefense = baseMDef + mdefRoll;
			this.m.RangedDefense = baseRDef + rdefRoll;
			this.m.StaminaModifier = cfg.MaxStamPen;
		}

		if (cfg.CustomIcon != null) this.m.Icon = cfg.CustomIcon;
		if (cfg.CustomIconLarge != null) this.m.IconLarge = cfg.CustomIconLarge;
		this.m.WX_ShieldBrush <- "shd_" + cfg.ID;
		this.m.WX_GearTraitID <- ("TraitID" in cfg) ? cfg.TraitID : null;
		this.m.WX_MappedID <- this.m.ID;
		this.m.WX_ExpectedIcon <- this.m.Icon;
		if ("BeastCraft" in ::Wuxia && "bindTraitMethods" in ::Wuxia.BeastCraft)
			::Wuxia.BeastCraft.bindTraitMethods(this);
		if ("BeastCraft" in ::Wuxia) ::Wuxia.BeastCraft.bindTraitMethods(this);
	}

	function updateVariant()
	{
		if (this.m.GearID != "" && (this.m.GearID in ::Wuxia.Config.ShanHaiGear))
		{
			local cfg = ::Wuxia.Config.ShanHaiGear[this.m.GearID];
			if (cfg.CustomIcon != null) this.m.Icon = cfg.CustomIcon;
			if (cfg.CustomIconLarge != null) this.m.IconLarge = cfg.CustomIconLarge;
			this.m.WX_ShieldBrush <- "shd_" + cfg.ID;
			this.m.WX_GearTraitID <- ("TraitID" in cfg) ? cfg.TraitID : null;
		}
	}

	function onSerialize( _out )
	{
		this.heater_shield.onSerialize(_out);
		_out.writeU16(this.m.ConditionMax);
		_out.writeI16(this.m.MeleeDefense);
		_out.writeI16(this.m.RangedDefense);
		_out.writeI16(this.m.StaminaModifier);
	}

	function onDeserialize( _in )
	{
		this.heater_shield.onDeserialize(_in);
		this.m.ConditionMax = _in.readU16();
		this.m.MeleeDefense = _in.readI16();
		this.m.RangedDefense = _in.readI16();
		this.m.StaminaModifier = _in.readI16();
		if (this.m.Condition > this.m.ConditionMax) this.m.Condition = this.m.ConditionMax;
		this.initShanHaiShield(this.m.GearID, true);
		if ("Forge" in ::Wuxia && "syncDeserializedShield" in ::Wuxia.Forge)
			::Wuxia.Forge.syncDeserializedShield(this);
	}
});
