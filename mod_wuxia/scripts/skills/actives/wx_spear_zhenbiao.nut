// Active Move: 定鼎镇岳枪
this.wx_spear_zhenbiao <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_spear_zhenbiao";
		this.m.Name = "定鼎镇岳枪";
		this.m.Description = "威远总镖头镇场神枪：消耗 5 AP 与 22 内息，大枪沉稳攒刺两格强敌（总伤 +18%，破甲 +22%，逼退一格）。";
		this.m.Icon = "skills/wx_spear_zhenbiao.png";
		this.m.IconDisabled = "skills/wx_spear_zhenbiao_sw.png";
		this.m.Overlay = "wx_ov_wx_spear_zhenbiao";
		this.m.WX_VfxBrush <- "wx_vfx_24";
		this.m.WX_AnimID <- "wx_anim_112";
		this.m.WX_AnimMode <- "pierce_zhenbiao";
		this.m.WX_ChoreoID <- "wx_spear_zhenbiao";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Spear", "Polearm"];
		this.m.DirectDamageMult = 0.30;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 8; _properties.DamageTotalMult *= 1.18; _properties.DamageArmorMult *= 1.22;
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
