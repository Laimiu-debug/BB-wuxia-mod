// Base Item for Craftable Mainhand Weapon Attachments / Spirit Inscriptions (`misc.wx_wmod_*`)
// Right-click in Character Inventory to inlay onto the selected brother's matching Mainhand weapon!

this.wx_wmod_base <- this.inherit("scripts/items/item", {
	m = {
		ModID = "wx_wmod_sword_tassel"
	},

	function create()
	{
		this.item.create();
		this.m.SlotType = this.Const.ItemSlot.None;
		this.m.ItemType = this.Const.Items.ItemType.Usable | this.Const.Items.ItemType.Misc;
		this.m.IsDroppedAsLoot = true;
		this.m.IsUsable = true;
		this.m.Value = 1350;
	}

	function initWeaponMod( _modID )
	{
		this.m.ModID = _modID;
		this.m.ID = "misc." + _modID;
		if ("WeaponAttachments" in ::Wuxia.Config && (_modID in ::Wuxia.Config.WeaponAttachments))
		{
			local cfg = ::Wuxia.Config.WeaponAttachments[_modID];
			this.m.Name = cfg.Name;
			this.m.Description = cfg.Description;
			this.m.Value = cfg.Value;
			this.m.Icon = cfg.Icon;
		}
	}

	function getModCfg()
	{
		if ("WeaponAttachments" in ::Wuxia.Config && (this.m.ModID in ::Wuxia.Config.WeaponAttachments))
			return ::Wuxia.Config.WeaponAttachments[this.m.ModID];
		return null;
	}

	function getTooltip()
	{
		local ret = this.item.getTooltip();
		local cfg = this.getModCfg();
		if (cfg != null)
		{
			ret.push({
				id = 15,
				type = "text",
				icon = "ui/icons/melee_skill.png",
				text = "[color=#0e3969][b]适配兵刃：[/b][/color]【" + cfg.FamilyLabel + "】"
			});
			ret.push({
				id = 16,
				type = "text",
				icon = "ui/icons/special.png",
				text = "[color=#094039][b]铭配神效：[/b][/color]" + cfg.BonusText
			});
			ret.push({
				id = 17,
				type = "text",
				icon = "ui/icons/asset_supplies.png",
				text = "用法：让侠客主手装备对应兵刃后，在行囊右键点击本配件即可镶缀（旧配件自动无损拆回行囊）"
			});
		}
		return ret;
	}

	function applyToActorWeapon( _actor )
	{
		if (_actor == null || !::Wuxia.hasMember(_actor, "getItems") || _actor.getItems() == null)
			return { Ok = false, Reason = "无效的侠客实例。" };
		local mainWpn = _actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
		if (mainWpn == null)
			return { Ok = false, Reason = _actor.getName() + " 主手尚未装备兵刃。" };
		local stash = ::Wuxia.hasWorldField("Assets") ? ::World.Assets.getStash() : null;
		local res = ::Wuxia.Forge.applyWeaponAttachment(mainWpn, this.m.ModID, stash);
		if (res.Ok && ::Wuxia.hasMember(_actor, "getSkills") && _actor.getSkills() != null)
			_actor.getSkills().update();
		return res;
	}

	function onUse( _actor, _item = null )
	{
		local res = this.applyToActorWeapon(_actor);
		return res.Ok;
	}
});
