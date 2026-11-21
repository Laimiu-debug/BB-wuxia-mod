// Active Move: 透骨分筋刺
this.wx_dagger_fuxue <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_dagger_fuxue";
		this.m.Name = "透骨分筋刺";
		this.m.Description = "贴身短匕认穴绝杀：消耗 4 AP 与 18 内息，对已露破绽、失衡或被封穴之敌命中 +18、穿甲 +22%。";
		this.m.Icon = "skills/wx_dagger_fuxue.png";
		this.m.IconDisabled = "skills/wx_dagger_fuxue_sw.png";
		this.m.Overlay = "wx_ov_wx_dagger_fuxue";
		this.m.WX_VfxBrush <- "wx_vfx_25";
		this.m.WX_AnimID <- "wx_anim_61";
		this.m.WX_AnimMode <- "backstab";
		this.m.WX_ChoreoID <- "wx_dagger_fuxue";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Dagger"];
		this.m.DirectDamageMult = 0.45;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			if (_targetEntity != null) { local sk = _targetEntity.getSkills(); if (sk != null && (sk.hasSkill("effects.wx_status_opening") || sk.hasSkill("effects.wx_status_offbalance") || sk.hasSkill("effects.wx_status_acupoint") || sk.hasSkill("effects.stunned"))) { _properties.MeleeSkill += 18; _properties.DamageDirectAdd += 0.22; _properties.DamageTotalMult *= 1.20; } }
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		return hit;
	}
});
