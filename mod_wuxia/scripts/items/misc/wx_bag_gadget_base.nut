// Base Item for Belt-Slot Tactical Gadgets (`百工奇门 · 腰包战术器械`)
// Equipped in ItemSlot.Bag; converges into a single HUD-safe active skill `actives.wx_item_bag_gadget`!

this.wx_bag_gadget_base <- this.inherit("scripts/items/item", {
	m = {
		GadgetID        = "wx_gadget_duanlong",
		Charges         = 2,
		MaxCharges      = 2,
		WX_IsBagGadget  = true
	},

	function create()
	{
		this.item.create();
		this.m.SlotType = this.Const.ItemSlot.Bag;
		this.m.ItemType = this.Const.Items.ItemType.Tool | this.Const.Items.ItemType.Misc;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = true;
		this.m.StaminaModifier <- -2;
		this.m.Value = 1500;
	}

	function initGadget( _gadgetID )
	{
		this.m.GadgetID = _gadgetID;
		this.m.ID = "misc." + _gadgetID;
		this.m.WX_IsBagGadget = true;
		if ("BagGadgets" in ::Wuxia.Config && (_gadgetID in ::Wuxia.Config.BagGadgets))
		{
			local cfg = ::Wuxia.Config.BagGadgets[_gadgetID];
			this.m.Name = cfg.Name;
			this.m.Description = cfg.Description;
			this.m.Value = cfg.Value;
			this.m.Icon = cfg.Icon;
			this.m.MaxCharges = cfg.MaxCharges;
			this.m.Charges = cfg.MaxCharges;
		}
	}

	function getGadgetCfg()
	{
		if ("BagGadgets" in ::Wuxia.Config && (this.m.GadgetID in ::Wuxia.Config.BagGadgets))
			return ::Wuxia.Config.BagGadgets[this.m.GadgetID];
		return null;
	}

	function getCharges()
	{
		return this.m.Charges;
	}

	function consumeCharge()
	{
		this.m.Charges = ::Math.max(0, this.m.Charges - 1);
	}

	function refillCharges()
	{
		this.m.Charges = this.m.MaxCharges;
	}

	function getTooltip()
	{
		local ret = this.item.getTooltip();
		local cfg = this.getGadgetCfg();
		if (cfg != null)
		{
			ret.push({
				id = 15,
				type = "text",
				icon = "ui/icons/action_points.png",
				text = "[color=#094039]【腰包奇门器械】[/color]耗 [color=#0a4213]" + cfg.APCost + " AP[/color] · 射程 [color=#0a4213]" + cfg.MinRange + "~" + cfg.MaxRange + " 格[/color] · 单场剩余机括：[color=#0a4213]" + this.m.Charges + "/" + this.m.MaxCharges + "[/color]（战后自动整备补满）"
			});
			ret.push({
				id = 16,
				type = "text",
				icon = "ui/icons/special.png",
				text = "底栏防溢出收敛：全身多件腰包器械共用单个【奇门机括】技能图标，按腰包格顺序依次激发"
			});
		}
		return ret;
	}

	function syncOwnerBagSkill()
	{
		local cont = this.getContainer();
		local actor = (cont != null && ::Wuxia.hasMember(cont, "getActor")) ? cont.getActor() : null;
		if (actor != null && ("CraftBridge" in ::Wuxia))
			::Wuxia.CraftBridge.syncBagTacticalSkills(actor);
	}

	function onEquip()
	{
		this.item.onEquip();
		this.refillCharges();
		this.syncOwnerBagSkill();
	}

	function onUnequip()
	{
		this.item.onUnequip();
		this.syncOwnerBagSkill();
	}

	function onPutIntoBag()
	{
		this.item.onPutIntoBag();
		this.refillCharges();
		this.syncOwnerBagSkill();
	}

	function onRemovedFromBag()
	{
		this.item.onRemovedFromBag();
		this.syncOwnerBagSkill();
	}

	function onCombatFinished()
	{
		this.refillCharges();
	}
});
