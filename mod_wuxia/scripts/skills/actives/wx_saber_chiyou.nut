// Active Move: 蚩尤破阵斩
this.wx_saber_chiyou <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_chiyou";
		this.m.Name = "蚩尤破阵斩";
		this.m.Description = "上古兵主五兵神技：消耗 6 AP 与 28 内息，百兵凶煞合一劈碎敌阵（总伤 +22%，破甲 +35%，穿甲 +12%）。";
		this.m.Icon = "skills/wx_saber_chiyou.png";
		this.m.IconDisabled = "skills/wx_saber_chiyou_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_chiyou";
		this.m.WX_VfxBrush <- "wx_vfx_02";
		this.m.WX_AnimID <- "wx_anim_98";
		this.m.WX_AnimMode <- "sky_chiyou";
		this.m.WX_ChoreoID <- "wx_saber_chiyou";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 6;
		this.m.FatigueCost = 28;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Sword", "Saber", "Cleaver", "Spear", "Polearm", "Axe", "Hammer"];
		this.m.DirectDamageMult = 0.35;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 10; _properties.DamageTotalMult *= 1.22; _properties.DamageArmorMult *= 1.35; _properties.DamageDirectAdd += 0.12;
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
		}
		return hit;
	}
});
