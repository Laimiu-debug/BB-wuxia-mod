// Shan Hai Talisman: 山海·青丘定魂辟邪佩 (+12 Bravery, Night Owl, +15 Anti-Fear/Charm Morale Check)

this.wx_acc_jiuwei <- this.inherit("scripts/items/accessory/accessory", {
	m = {},

	function create()
	{
		this.accessory.create();
		local ref = ::new("scripts/items/accessory/hexen_trophy_item");
		local cfg = ::Wuxia.Config.ShanHaiGear.wx_acc_jiuwei;
		this.m.ID = "accessory.wx_acc_jiuwei";
		this.m.Name = cfg.Name;
		this.m.Description = cfg.Description;
		this.m.Icon = cfg.CustomIcon != null ? cfg.CustomIcon : ref.m.Icon;
		this.m.SlotType = this.Const.ItemSlot.Accessory;
		this.m.ItemType = this.Const.Items.ItemType.Accessory;
		this.m.IsDroppedAsLoot = true;
		this.m.ShowOnCharacter = false;
		this.m.Value = cfg.Value;
	}

	function getTooltip()
	{
		local ret = this.accessory.getTooltip();
		ret.push({ id = 11, type = "text", icon = "ui/icons/bravery.png", text = "[color=" + this.Const.UI.Color.PositiveValue + "]+12[/color] 定力，且对抗惊骇与魅惑检定额外 [color=" + this.Const.UI.Color.PositiveValue + "]+15[/color]" });
		ret.push({ id = 12, type = "text", icon = "ui/icons/vision.png", text = "夜战心明如昼（免除夜间视野与射艺惩罚）" });
		return ret;
	}

	function onUpdateProperties( _properties )
	{
		this.accessory.onUpdateProperties(_properties);
		_properties.Bravery += 12;
		if ("IsAffectedByNight" in _properties) _properties.IsAffectedByNight = false;
		if (("MoraleCheckBravery" in _properties) && typeof _properties.MoraleCheckBravery == "array" && _properties.MoraleCheckBravery.len() > 0)
		{
			_properties.MoraleCheckBravery[0] += 15;
		}
	}
});
