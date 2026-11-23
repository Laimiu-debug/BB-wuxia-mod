// Active Move: 图穷匕见刺
this.wx_dagger_jingke <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_dagger_jingke";
		this.m.Name = "图穷匕见刺";
		this.m.Description = "刺道孤本绝命一击：消耗 5 AP 与 24 内息，瞬息欺近暴起一刺（命中 +15，穿甲 +25%，总伤 +22%）。";
		this.m.Icon = "skills/wx_dagger_jingke.png";
		this.m.IconDisabled = "skills/wx_dagger_jingke_sw.png";
		this.m.Overlay = "wx_ov_wx_dagger_jingke";
		this.m.WX_VfxBrush <- "wx_vfx_07";
		this.m.WX_AnimID <- "wx_anim_130";
		this.m.WX_AnimMode <- "shadow_jingke";
		this.m.WX_ChoreoID <- "wx_dagger_jingke";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 24;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Dagger"];
		this.m.DirectDamageMult = 0.45;
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 15; _properties.DamageDirectAdd += 0.25; _properties.DamageTotalMult *= 1.22;
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
