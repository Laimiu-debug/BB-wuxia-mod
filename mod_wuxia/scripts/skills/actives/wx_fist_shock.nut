// Shaolin / Internal Palm Flagship Move #1: 寸劲震脉 · 隔山打牛 (True Through-Tank Rear Shockwave + `寸劲伏脉` Stacking!)

this.wx_fist_shock <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_shock";
		this.m.WX_VfxBrush <- "wx_vfx_11";
		this.m.WX_AnimID <- "wx_anim_49";
		this.m.WX_AnimMode <- "inch_pulse";
		this.m.WX_ChoreoID <- "wx_fist_shock";
		this.m.Name = "隔山寸劲掌";
		this.m.Description = "内家『隔山打牛·寸劲伏脉』绝技：消耗 4 AP 与 18 内息，正面轻叩前排肉盾，将浑厚掌力透体而出轰穿正后方 1~2 格敌军（透甲直伤 + 震散内息 + 失衡）！同时向目标经脉打入【寸劲伏脉】（满三重轰然爆裂五脏），并为自身积蓄 1 层【潜龙叠浪】！";
		this.m.KilledString = "隔山寸劲震毙";
		this.m.Icon = "skills/wx_fist_shock.png";
		this.m.IconDisabled = "skills/wx_fist_shock_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_shock";
		this.m.SoundOnUse = [
			"sounds/combat/hand_01.wav",
			"sounds/combat/hand_02.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/bash_hit_01.wav",
			"sounds/combat/bash_hit_02.wav",
			"sounds/combat/bash_hit_03.wav"
		];
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.InjuriesOnBody = this.Const.Injury.BluntBody;
		this.m.InjuriesOnHead = this.Const.Injury.BluntHead;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.38;
		this.m.IsIgnoredAsAOO = true;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			// Front conduit takes softer external impact while internal wave pierces through!
			_properties.MeleeSkill += 8;
			_properties.DamageTotalMult *= 0.85;
			local room = ::Math.maxf(0.0, 0.25 - _properties.DamageDirectAdd);
			_properties.DamageDirectAdd += ::Math.minf(room, 0.10);
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		local hit = this.attackEntity(_user, target);
		if (hit)
		{
			if ("Streams" in ::Wuxia)
			{
				local st = ::Wuxia.Streams.getOrCreateState(_user);
				if (st != null) st.addDragonWave(1, 2);
				if (target != null && target.isAlive())
					::Wuxia.Streams.applyHiddenForce(target, 1, _user);
				::Wuxia.Streams.transmitThroughForce(_user, target, _targetTile);
			}
		}
		return hit;
	}
});
