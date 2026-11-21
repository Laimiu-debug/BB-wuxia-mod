// Secret Dagger Move: 追魂透骨刺 (4 AP, 16 Qi: +15% armor pen; against targets with Opening/OffBalance/Acupoint/Stun/Net, +12 hit & +35% total dmg)

this.wx_dagger_execute <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_dagger_execute";
		this.m.WX_VfxBrush <- "wx_vfx_30";
		this.m.WX_AnimID <- "wx_anim_62";
		this.m.WX_AnimMode <- "night_exec";
		this.m.WX_ChoreoID <- "wx_dagger_execute";
		this.m.Name = "追魂透骨刺";
		this.m.Description = "幽冥隐杀楼绝命短刃：穿甲率 +15%；若目标处于「破绽 / 失衡 / 点穴 / 眩晕 / 困网」任一受制状态，命中额外 +12 且总伤害暴涨 35%！";
		this.m.KilledString = "短刃透心毙命";
		this.m.Icon = "skills/wx_dagger_execute.png";
		this.m.IconDisabled = "skills/wx_dagger_execute_sw.png";
		this.m.Overlay = "wx_ov_wx_dagger_execute";
		this.m.SoundOnUse = [
			"sounds/combat/stab_01.wav",
			"sounds/combat/stab_02.wav",
			"sounds/combat/stab_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/stab_hit_01.wav",
			"sounds/combat/stab_hit_02.wav",
			"sounds/combat/stab_hit_03.wav"
		];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.InjuriesOnBody = this.Const.Injury.PiercingBody;
		this.m.InjuriesOnHead = this.Const.Injury.PiercingHead;
		this.m.RequiredWeaponTypes = ["Dagger"];
		this.m.DirectDamageMult = 0.25;
	}

	function wxIsTargetVulnerable( _target )
	{
		if (_target == null || !(::Wuxia.hasMember(_target, "getSkills")) || _target.getSkills() == null) return false;
		local sk = _target.getSkills();
		return sk.hasSkill("effects.wx_status_opening")
			|| sk.hasSkill("effects.wx_status_offbalance")
			|| sk.hasSkill("effects.wx_status_acupoint")
			|| sk.hasSkill("effects.stunned")
			|| sk.hasSkill("effects.dazed")
			|| sk.hasSkill("effects.net")
			|| sk.hasSkill("effects.sleeping");
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageDirectAdd += 0.15;
			if (this.wxIsTargetVulnerable(_targetEntity))
			{
				_properties.MeleeSkill += 12;
				_properties.DamageTotalMult *= 1.35;
			}
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		return this.attackEntity(_user, _targetTile.getEntity());
	}
});
