// Sect Fist Move: 金刚摧心掌 (5 AP, 18 Qi, +5% dmg, +8% armor pen, drains 12 Qi; Tier 3 has 50% stun chance)

this.wx_fist_jingang <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_jingang";
		this.m.WX_VfxBrush <- "wx_vfx_09";
		this.m.WX_AnimID <- "wx_anim_21";
		this.m.WX_AnimMode <- "buddha_palm";
		this.m.WX_ChoreoID <- "wx_fist_jingang";
		this.m.Name = "金刚摧心掌";
		this.m.Description = "少室刚猛掌力透甲摧脉：总伤害 +5%、穿甲率 +8%，命中震散目标 12 点内息并致「失衡」；大成后有 50% 几率当场震晕目标 1 回合。";
		this.m.KilledString = "一掌震碎心脉";
		this.m.Icon = "skills/wx_fist_jingang.png";
		this.m.IconDisabled = "skills/wx_fist_jingang_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_jingang";
		this.m.SoundOnUse = [
			"sounds/combat/bash_01.wav",
			"sounds/combat/bash_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/bash_hit_01.wav",
			"sounds/combat/bash_hit_02.wav"
		];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.InjuriesOnBody = this.Const.Injury.BluntBody;
		this.m.InjuriesOnHead = this.Const.Injury.BluntHead;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.36;
		this.m.IsIgnoredAsAOO = true;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.DamageTotalMult *= 1.05;
			_properties.DamageDirectAdd += 0.08;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive())
		{
			target.setFatigue(::Math.min(target.getFatigueMax(), target.getFatigue() + 12));
			this.wxApplyStatusToTarget(target, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");

			local c = _user.getSkills().getSkillByID("special.wx_martial_container");
			local stunPct = (c != null && c.m.CachedAggFlags != null) ? c.m.CachedAggFlags.JingangStunPct : 0;
			if (stunPct > 0 && !target.getCurrentProperties().IsImmuneToStun && ::Math.rand(1, 100) <= stunPct)
			{
				if (!target.getSkills().hasSkill("effects.stunned"))
				{
					target.getSkills().add(::new("scripts/skills/effects/stunned_effect"));
					this.Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_user) + " 一记金刚摧心掌将 " + ::Const.UI.getColorizedEntityName(target) + " 震晕当场！");
				}
			}
		}
		return hit;
	}
});
