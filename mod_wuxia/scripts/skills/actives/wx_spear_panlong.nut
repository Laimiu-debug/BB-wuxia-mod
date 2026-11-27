// Active Move: 长风追魂枪
this.wx_spear_panlong <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {  },

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_spear_panlong";
		this.m.Name = "长风追魂枪";
		this.m.Description = "洛阳镖局八步赶蝉快枪：消耗 5 AP 与 20 内息，枪走游龙直取两格敌喉（命中 +10，击头率 +14%）。";
		this.m.Icon = "skills/wx_spear_panlong.png";
		this.m.IconDisabled = "skills/wx_spear_panlong_sw.png";
		this.m.Overlay = "wx_ov_wx_spear_panlong";
		this.m.WX_VfxBrush <- "wx_vfx_03";
		this.m.WX_AnimID <- "wx_anim_110";
		this.m.WX_AnimMode <- "pierce_panlong";
		this.m.WX_ChoreoID <- "wx_spear_panlong";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav", "sounds/combat/slash_02.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.RequiredWeaponTypes = ["Spear", "Polearm"];
		this.m.DirectDamageMult = 0.30;
		this.m.WX_ComboForms = [
			{
				Name = "长风追魂·一式穿喉",
				Description = "八步赶蝉快枪（5 AP / 19 内息）：枪走游龙直取两格敌喉（命中 +10，击头率 +14%），命中后同槽递进为【二式盘龙挑】。",
				AP = 5, Qi = 19, Hit = 10, Dmg = 1.10
			},
			{
				Name = "长风追魂·二式盘龙挑",
				Description = "盘龙挑背变式（4 AP / 18 内息）：顺杆抖枪（命中 +14，总伤 +16%），贴身可将对手【挑飞过肩换位】摔入身后或挂破绽！",
				AP = 4, Qi = 18, Hit = 14, Dmg = 1.16
			}
		];
	}
	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			local cf = this.wxGetActiveComboForm();
			_properties.MeleeSkill += (cf != null ? cf.Hit : 10);
			_properties.HitChance[::Const.BodyPart.Head] += 14;
			_properties.DamageTotalMult *= (cf != null ? cf.Dmg : 1.10);
		}
	}

	function onUse( _user, _targetTile )
	{
		local stg = ("Streams" in ::Wuxia) ? ::Wuxia.Streams.getComboStage(_user, this.m.ID) : 0;
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit)
		{
			if (stg == 1 && target != null && target.isAlive())
			{
				local flipped = ("Streams" in ::Wuxia) && ::Wuxia.Streams.vaultFlipOverShoulder(_user, target);
				if (!flipped)
					this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			}
			if ("Streams" in ::Wuxia) ::Wuxia.Streams.advanceComboStage(_user, this.m.ID, 2, true);
		}
		else if ("Streams" in ::Wuxia)
		{
			::Wuxia.Streams.resetComboStage(_user, this.m.ID);
		}
		this.wxTriggerTagPostMechanic(_user, target, _targetTile, hit);
		return hit;
	}
});
