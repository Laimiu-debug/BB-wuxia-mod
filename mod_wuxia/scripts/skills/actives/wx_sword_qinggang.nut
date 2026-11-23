// Active Move: 青釭透甲剑
this.wx_sword_qinggang <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_qinggang";
		this.m.Name = "青釭透甲剑";
		this.m.Description = "名门破甲重刺剑式：消耗 5 AP 与 19 内息，凝劲于剑尖专破重甲护心镜（破甲 +32%，穿甲 +12%）。";
		this.m.Icon = "skills/wx_sword_qinggang.png";
		this.m.IconDisabled = "skills/wx_sword_qinggang_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_qinggang";
		this.m.WX_VfxBrush <- "wx_vfx_03";
		this.m.WX_AnimID <- "wx_anim_86";
		this.m.WX_AnimMode <- "pierce_qinggang";
		this.m.WX_ChoreoID <- "wx_sword_qinggang";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 19;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword"];
		this.m.DirectDamageMult = 0.34;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 6; _properties.DamageArmorMult *= 1.32; _properties.DamageDirectAdd += 0.12;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			
		}
		return hit;
	}
});
