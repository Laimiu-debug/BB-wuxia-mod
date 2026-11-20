// Base Item for Shan Hai Jing Mythical Beast Neidan Cores (山海凶兽内丹)

this.wx_shanhai_core_base <- this.inherit("scripts/items/item", {
	m = {
		CoreID = "wx_core_zhuyan"
	},

	function create()
	{
		this.item.create();
		local ref = ::new("scripts/items/misc/unhold_heart_item");
		this.m.Icon = ref.m.Icon;
		this.m.SlotType = this.Const.ItemSlot.None;
		this.m.ItemType = this.Const.Items.ItemType.Misc | this.Const.Items.ItemType.Crafting;
		this.m.IsDroppedAsLoot = true;
		this.m.Value = 1800;
	}

	function initCore( _coreID )
	{
		this.m.CoreID = _coreID;
		this.m.ID = "misc." + _coreID;
		if ("ShanHaiCores" in ::Wuxia.Config && (_coreID in ::Wuxia.Config.ShanHaiCores))
		{
			local cfg = ::Wuxia.Config.ShanHaiCores[_coreID];
			this.m.Name = cfg.Name;
			this.m.Description = cfg.Description;
			this.m.Value = cfg.Value;
			if (cfg.CustomIcon != null) this.m.Icon = cfg.CustomIcon;
		}
	}
});
