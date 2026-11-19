// Base class for weapon-bound Wuxia active moves

this.wx_move_base <- this.inherit("scripts/skills/skill", {
	m = {
		RequiredWeaponTypes = [],
		InflictStatusID     = null,
		InflictStatusScript = null,
		InflictChancePct    = 100
	},

	function create()
	{
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsStacking = false;
		this.m.IsAttack = true;
		this.m.IsWeaponSkill = true;
		this.m.InjuriesOnBody = this.Const.Injury.CuttingBody;
		this.m.InjuriesOnHead = this.Const.Injury.CuttingHead;
		this.m.DirectDamageMult = 0.25;
	}

	function wxHasRequiredWeapon()
	{
		if (this.m.RequiredWeaponTypes.len() == 0) return true;
		local container = this.getContainer();
		local actor = container == null ? null : container.getActor();
		if (actor == null) return false;
		local weapon = actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
		if (weapon == null) return false;

		local wid = weapon.getID().tolower();
		local cats = ("Categories" in weapon.m && weapon.m.Categories != null) ? weapon.m.Categories.tolower() : "";

		foreach (wtName in this.m.RequiredWeaponTypes)
		{
			// Path 1: MSU WeaponType if MSU is installed
			if ("WeaponType" in ::Const.Items && wtName in ::Const.Items.WeaponType)
			{
				if ("isWeaponType" in weapon && weapon.isWeaponType(::Const.Items.WeaponType[wtName]))
					return true;
			}

			// Path 2: Vanilla zero-MSU weapon matching by English ID & localized/English Categories
			if (wtName == "Sword")
			{
				if (wid.find("sword") != null || wid.find("rapier") != null || wid.find("shamshir") != null || wid.find("falchion") != null || cats.find("sword") != null || cats.find("剑") != null)
					return true;
			}
			else if (wtName == "Cleaver" || wtName == "Saber")
			{
				if (wid.find("cleaver") != null || wid.find("scimitar") != null || wid.find("khopesh") != null || wid.find("chopper") != null || wid.find("saber") != null || wid.find("scramasax") != null || cats.find("cleaver") != null || cats.find("刀") != null)
					return true;
			}
			else if (wtName == "Spear" || wtName == "Polearm")
			{
				if (wid.find("spear") != null || wid.find("pike") != null || wid.find("bill") != null || wid.find("halberd") != null || wid.find("spetum") != null || wid.find("pole") != null || wid.find("glaive") != null || wid.find("trident") != null || cats.find("spear") != null || cats.find("polearm") != null || cats.find("矛") != null || cats.find("枪") != null || cats.find("长柄") != null)
					return true;
			}
			else if (wtName == "Throwing")
			{
				if (wid.find("throwing") != null || wid.find("javelin") != null || wid.find("bolas") != null || cats.find("throwing") != null || cats.find("投掷") != null || cats.find("暗器") != null)
					return true;
			}
		}
		return false;
	}

	function isHidden()
	{
		return this.skill.isHidden() || !this.wxHasRequiredWeapon();
	}

	function isUsable()
	{
		return this.skill.isUsable() && this.wxHasRequiredWeapon();
	}

	function getFatigueCost()
	{
		local cost = this.skill.getFatigueCost();
		local actor = this.getContainer().getActor();
		local c = ::Wuxia.Slots.getContainer(actor);
		if (c != null && c.m.CachedAggFlags != null && c.m.CachedAggFlags.WeaponQiDiscount > 0.0)
		{
			cost = ::Math.max(1, ::Math.floor(cost * (1.0 - c.m.CachedAggFlags.WeaponQiDiscount)));
		}
		return cost;
	}

	function wxApplyStatusToTarget( _target, _effectID, _effectScript )
	{
		if (_target == null || !_target.isAlive() || _effectID == null || _effectScript == null)
			return;
		local sk = _target.getSkills();
		if (sk == null) return;
		local eff = sk.getSkillByID(_effectID);
		if (eff == null)
		{
			eff = ::new(_effectScript);
			sk.add(eff);
		}
		else if ("resetDuration" in eff)
		{
			eff.resetDuration();
		}
	}

	function getTooltip()
	{
		local ret = this.getDefaultTooltip();
		if (this.m.RequiredWeaponTypes.len() > 0)
		{
			local joined = "";
			for (local i = 0; i < this.m.RequiredWeaponTypes.len(); i = ++i)
			{
				if (i > 0) joined += " / ";
				joined += this.m.RequiredWeaponTypes[i];
			}
			ret.push({
				id = 15,
				type = "text",
				icon = "ui/icons/regular_damage.png",
				text = "兵器要求：" + joined
			});
		}
		return ret;
	}
});
