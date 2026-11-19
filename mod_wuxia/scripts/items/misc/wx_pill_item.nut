// Generic Wuxia Pill Item (data-driven from ::Wuxia.Config.Pills)

this.wx_pill_item <- this.inherit("scripts/items/item", {
	m = {
		PillID = "wx_pill_huxin"
	},

	function create()
	{
		this.item.create();
		this.m.ID = "misc.wx_pill_item";
		this.m.Name = "江湖丹药";
		this.m.Description = "武林丹药。";
		this.m.Icon = "consumables/potion_01.png";
		this.m.SlotType = this.Const.ItemSlot.None;
		this.m.ItemType = this.Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsUsable = true;
		this.m.Value = 300;
	}

	function initPill( _pillID )
	{
		this.m.PillID = _pillID;
		this.refreshFromConfig();
	}

	function getPillID()
	{
		return this.m.PillID;
	}

	function refreshFromConfig()
	{
		if (!(this.m.PillID in ::Wuxia.Config.Pills)) return;
		local def = ::Wuxia.Config.Pills[this.m.PillID];
		this.m.Name = def.Name;
		this.m.Description = def.Description;
		this.m.Icon = def.Icon;
		this.m.Value = def.Value;
		// Healing pills can be consumed directly in inventory; infuse/wash pills are used inside the Wuxia tab
		this.m.IsUsable = (def.Kind == "heal_external" || def.Kind == "heal_internal");
	}

	function onUse( _actor, _item = null )
	{
		if (_actor == null || !(this.m.PillID in ::Wuxia.Config.Pills)) return false;
		local def = ::Wuxia.Config.Pills[this.m.PillID];
		local skills = _actor.getSkills();

		if (def.Kind == "heal_internal")
		{
			local cured = false;
			if (skills.hasSkill("effects.wx_scatter_weakness"))
			{
				skills.removeByID("effects.wx_scatter_weakness");
				cured = true;
			}
			local inj = skills.getSkillByID("effects.wx_internal_injury");
			if (inj != null && inj.m.Severity > 0)
			{
				inj.cureTemporary();
				cured = true;
			}
			if (cured) skills.update();
			return cured;
		}

		if (def.Kind == "heal_external")
		{
			local wounds = skills.getAllSkillsOfType(::Const.SkillType.TemporaryInjury);
			if (wounds.len() > 0)
			{
				wounds[0].removeSelf();
				skills.update();
				return true;
			}
			return false;
		}

		return false;
	}

	function onSerialize( _out )
	{
		this.item.onSerialize(_out);
		_out.writeString(this.m.PillID);
	}

	function onDeserialize( _in )
	{
		this.item.onDeserialize(_in);
		this.m.PillID = _in.readString();
		this.refreshFromConfig();
	}
});
