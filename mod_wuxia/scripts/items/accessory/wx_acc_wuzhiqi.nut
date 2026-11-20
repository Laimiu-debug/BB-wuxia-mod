// Shan Hai Talisman: 山海·淮水辟毒寒渊珠 (+10 Stamina, +2 Qi Recovery, Poison Immunity)

this.wx_acc_wuzhiqi <- this.inherit("scripts/items/accessory/accessory", {
	m = {},

	function create()
	{
		this.accessory.create();
		local ref = ::new("scripts/items/accessory/alp_trophy_item");
		local cfg = ::Wuxia.Config.ShanHaiGear.wx_acc_wuzhiqi;
		this.m.ID = "accessory.wx_acc_wuzhiqi";
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
		ret.push({ id = 11, type = "text", icon = "ui/icons/fatigue.png", text = "[color=" + this.Const.UI.Color.PositiveValue + "]+10[/color] 内息上限，每回合额外回气 [color=" + this.Const.UI.Color.PositiveValue + "]+2[/color]" });
		ret.push({ id = 12, type = "text", icon = "ui/icons/special.png", text = "百毒不侵（免疫蛛毒、五毒瘴气与暗器奇毒）" });
		return ret;
	}

	function onUpdateProperties( _properties )
	{
		this.accessory.onUpdateProperties(_properties);
		_properties.Stamina += 10;
		_properties.FatigueRecoveryRate += 2;
		_properties.IsImmuneToPoison = true;
	}
});
