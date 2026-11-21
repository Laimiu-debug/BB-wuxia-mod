// Base Item for Shan Hai & Wild Beast Forging Materials (`misc.wx_mat_*`)

this.wx_beast_material_base <- this.inherit("scripts/items/item", {
	m = {
		MatID = "wx_mat_shagu"
	},

	function create()
	{
		this.item.create();
		local ref = ::new("scripts/items/misc/unhold_bones_item");
		this.m.Icon = ref.m.Icon;
		this.m.SlotType = this.Const.ItemSlot.None;
		this.m.ItemType = this.Const.Items.ItemType.Misc | this.Const.Items.ItemType.Crafting;
		this.m.IsDroppedAsLoot = true;
		this.m.Value = 450;
	}

	function initMaterial( _matID )
	{
		this.m.MatID = _matID;
		this.m.ID = "misc." + _matID;
		if ("BeastMaterials" in ::Wuxia.Config && (_matID in ::Wuxia.Config.BeastMaterials))
		{
			local cfg = ::Wuxia.Config.BeastMaterials[_matID];
			this.m.Name = cfg.Name;
			this.m.Description = cfg.Description;
			this.m.Value = cfg.Value;
			this.m.Icon = cfg.Icon;
		}
	}
});
