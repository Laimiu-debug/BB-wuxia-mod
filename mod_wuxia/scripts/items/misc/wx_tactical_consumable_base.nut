// Base Item for Mid-Battle Tactical Powders & Multi-Sect Blade Coatings (`战中破局灵散 · 兵刃涂膏`)
// Equipped in ItemSlot.Bag; converges into a single HUD-safe active skill `actives.wx_item_tactical_powder`!

this.wx_tactical_consumable_base <- this.inherit("scripts/items/item", {
	m = {
		TactID                  = "wx_tact_xuanshuang",
		Charges                 = 2,
		MaxCharges              = 2,
		WX_IsTacticalConsumable = true
	},

	function create()
	{
		this.item.create();
		this.m.SlotType = this.Const.ItemSlot.Bag;
		this.m.ItemType = this.Const.Items.ItemType.Misc | this.Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = true;
		this.m.IsUsable = false;
		this.m.StaminaModifier <- -1;
		this.m.Value = 680;
	}

	function initTacticalConsumable( _tactID )
	{
		this.m.TactID = _tactID;
		this.m.ID = "misc." + _tactID;
		this.m.WX_IsTacticalConsumable = true;
		if ("TacticalConsumables" in ::Wuxia.Config && (_tactID in ::Wuxia.Config.TacticalConsumables))
		{
			local cfg = ::Wuxia.Config.TacticalConsumables[_tactID];
			this.m.Name = cfg.Name;
			this.m.Description = cfg.Description;
			this.m.Value = cfg.Value;
			this.m.Icon = cfg.Icon;
			this.m.MaxCharges = cfg.MaxCharges;
			this.m.Charges = cfg.MaxCharges;
		}
	}

	function getTactCfg()
	{
		if ("TacticalConsumables" in ::Wuxia.Config && (this.m.TactID in ::Wuxia.Config.TacticalConsumables))
			return ::Wuxia.Config.TacticalConsumables[this.m.TactID];
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

	function getTooltip()
	{
		local ret = this.item.getTooltip();
		local cfg = this.getTactCfg();
		if (cfg != null)
		{
			local modeTxt = (cfg.SubMode == "oral")
				? "战中内服瞬发（计入单场人体丹毒阈值！）"
				: ((cfg.SubMode == "coating") ? "战中主手兵刃涂抹（持续 4 次命中，不增体内丹毒）" : "战中外抛改地破局（不增体内丹毒）");
			ret.push({
				id = 15,
				type = "text",
				icon = "ui/icons/action_points.png",
				text = "[color=#094039]【腰包战中奇药】[/color]耗 [color=#0a4213]" + cfg.APCost + " AP[/color] · 剩余药囊剂量：[color=#0a4213]" + this.m.Charges + "/" + this.m.MaxCharges + "[/color]"
			});
			ret.push({
				id = 16,
				type = "text",
				icon = "ui/icons/special.png",
				text = "药理法度：" + modeTxt + "（装入角色腰包格即可于战中施展）"
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
		this.syncOwnerBagSkill();
	}

	function onRemovedFromBag()
	{
		this.item.onRemovedFromBag();
		this.syncOwnerBagSkill();
	}

	function onCombatFinished()
	{
		if (this.m.Charges <= 0 && this.getContainer() != null)
		{
			this.getContainer().removeFromBag(this);
		}
	}

	function onSerialize( _out )
	{
		this.item.onSerialize(_out);
		_out.writeU8(::Math.max(0, ::Math.min(10, this.m.Charges)));
	}

	function onDeserialize( _in )
	{
		this.item.onDeserialize(_in);
		this.m.Charges = _in.readU8();
	}
});
