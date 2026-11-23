// Active Move: 裂岳开天钺
this.wx_axe_kaitian <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_axe_kaitian";
		this.m.Name = "裂岳开天钺";
		this.m.Description = "劈山盟镇派重斧：消耗 6 AP 与 26 内息，巨钺当头裂石破甲（总伤 +20%，破甲 +38%，击退目标一格）。";
		this.m.Icon = "skills/wx_axe_kaitian.png";
		this.m.IconDisabled = "skills/wx_axe_kaitian_sw.png";
		this.m.Overlay = "wx_ov_wx_axe_kaitian";
		this.m.WX_VfxBrush <- "wx_vfx_02";
		this.m.WX_AnimID <- "wx_anim_127";
		this.m.WX_AnimMode <- "sky_kaitian";
		this.m.WX_ChoreoID <- "wx_axe_kaitian";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 26;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Axe"];
		this.m.DirectDamageMult = 0.32;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 7; _properties.DamageTotalMult *= 1.20; _properties.DamageArmorMult *= 1.38;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxTryKnockback(_user, target);
		}
		return hit;
	}
});
