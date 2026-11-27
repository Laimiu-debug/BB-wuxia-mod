// Shan Hai Boss Bespoke Active (`boss_xiangliuwang` #2): 所抵成泽·噬山崩撞 (Locked when `噬山铁首` is Severed!)

this.wx_boss_xiangliu_mire_ram <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown    = 0,
		WX_VfxBrush = "wx_vfx_05",
		WX_ChoreoID = "wx_boss_xiangliu_mire_ram"
	},

	function create()
	{
		this.m.ID = "actives.wx_boss_xiangliu_mire_ram";
		this.m.Name = "所抵成泽·噬山崩撞";
		this.m.Description = "《海外北经》相柳之所抵，厥为泽溪：催动【噬山铁首】猛烈冲抵阵线，崩碎目标盾牌 35 点耐久、震退失衡，并将受击处塌陷为【苦毒腐泽】（斩断『噬山铁首』即可永久封印此招！）。";
		this.m.Icon = "skills/wx_hammer_quake.png";
		this.m.IconDisabled = "skills/wx_hammer_quake_sw.png";
		this.m.Overlay = "wx_ov_wx_hammer_quake";
		this.m.SoundOnUse = ["sounds/combat/bash_02.wav"];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsAttack = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 15;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.DirectDamageMult = 0.30;
	}

	function isUsable()
	{
		if (this.m.Cooldown > 0 || !this.skill.isUsable()) return false;
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor != null && ::Wuxia.ShanHaiMultiBody.isSkillLocked(actor, this.m.ID))
			return false;
		return true;
	}

	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 14;
			_properties.DamageRegularMin += 44;
			_properties.DamageRegularMax += 66;
			_properties.DamageArmorMult *= 1.30;
		}
	}

	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		local target = _targetTile.getEntity();
		::Wuxia.TileField.setField(_targetTile, "bitter_mire", 4, _user);
		if (target == null || !target.isAlive()) return false;

		local hit = this.attackEntity(_user, target);
		if (hit && target.isAlive())
		{
			if (target.getItems() != null)
			{
				local off = target.getItems().getItemAtSlot(::Const.ItemSlot.Offhand);
				if (off != null && ::Wuxia.hasMember(off, "isItemType") && off.isItemType(::Const.Items.ItemType.Shield))
					off.applyShieldDamage(35);
			}
			if (target.getSkills() != null && !target.getSkills().hasSkill("effects.wx_status_offbalance"))
				target.getSkills().add(::new("scripts/skills/effects/wx_status_offbalance"));
		}
		return hit;
	}
});
