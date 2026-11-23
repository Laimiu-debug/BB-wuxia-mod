// Active Move: 宣花碎车劈
this.wx_axe_poche <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_axe_poche";
		this.m.Name = "宣花碎车劈";
		this.m.Description = "边军破盾重斧绝技：消耗 5 AP 与 19 内息，若目标持盾则直接重创其盾牌耐久并解除盾墙，同时劈斩敌身（破甲 +25%）。";
		this.m.Icon = "skills/wx_axe_poche.png";
		this.m.IconDisabled = "skills/wx_axe_poche_sw.png";
		this.m.Overlay = "wx_ov_wx_axe_poche";
		this.m.WX_VfxBrush <- "wx_vfx_02";
		this.m.WX_AnimID <- "wx_anim_129";
		this.m.WX_AnimMode <- "sky_poche";
		this.m.WX_ChoreoID <- "wx_axe_poche";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 19;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Axe"];
		this.m.DirectDamageMult = 0.30;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 6; _properties.DamageArmorMult *= 1.25;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			local off = target.getItems() != null ? target.getItems().getItemAtSlot(::Const.ItemSlot.Offhand) : null; if (off != null && off.isItemType(::Const.Items.ItemType.Shield)) off.applyShieldDamage(24); local tsk = target.getSkills(); if (tsk != null) tsk.removeByID("effects.shieldwall");
		}
		return hit;
	}
});
