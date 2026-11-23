// Active Move: 八宝亮寅刺 (1~2 tile precision tiger-star spear lunge, 5 AP, 22 Qi)
this.wx_spear_liangyin <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_spear_liangyin";
		this.m.Name = "八宝亮寅刺";
		this.m.Description = "幽燕奇侠秘传寅虎寒星枪：消耗 5 AP 与 22 内息，虚晃八宝枪花惑敌耳目，突施冷枪直取 1~2 格敌手咽喉面门（命中 +12，总伤 +15%，穿甲 +12%，击头率 +15%，命中施加破绽与失衡；对破绽或失衡目标伤害再 +15%）。";
		this.m.KilledString = "亮寅寒枪穿喉";
		this.m.Icon = "skills/wx_spear_liangyin.png";
		this.m.IconDisabled = "skills/wx_spear_liangyin_sw.png";
		this.m.Overlay = "wx_ov_wx_spear_liangyin";
		this.m.WX_VfxBrush <- "wx_vfx_03";
		this.m.WX_AnimID <- "wx_anim_74";
		this.m.WX_AnimMode <- "silver_tiger_spear";
		this.m.WX_ChoreoID <- "wx_spear_liangyin";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.InjuriesOnBody = this.Const.Injury.PiercingBody;
		this.m.InjuriesOnHead = this.Const.Injury.PiercingHead;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Spear", "Polearm"];
		this.m.DirectDamageMult = 0.32;
		this.m.IsIgnoredAsAOO = true;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 12;
			_properties.DamageTotalMult *= 1.15;
			_properties.DamageDirectAdd += 0.12;
			_properties.HitChance[::Const.BodyPart.Head] += 15;
			if (_targetEntity != null && ::Wuxia.hasMember(_targetEntity, "getSkills") && _targetEntity.getSkills() != null)
			{
				local tsk = _targetEntity.getSkills();
				if (tsk.hasSkill("effects.wx_status_opening") || tsk.hasSkill("effects.wx_status_offbalance"))
					_properties.DamageTotalMult *= 1.15;
			}
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
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		return hit;
	}
});
