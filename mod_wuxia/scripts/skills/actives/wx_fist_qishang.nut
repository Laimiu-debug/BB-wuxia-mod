// Active Move: 七伤总诀拳
this.wx_fist_qishang <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_qishang";
		this.m.Name = "七伤总诀拳";
		this.m.Description = "一拳既出七股刚柔暗劲齐发：消耗 5 AP、22 内息和 6 点气血（气血须大于 6），总伤 +18%、穿甲 +10%，命中附内伤与破绽。";
		this.m.Icon = "skills/wx_fist_qishang.png";
		this.m.IconDisabled = "skills/wx_fist_qishang_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_qishang";
		this.m.WX_VfxBrush <- "wx_vfx_11";
		this.m.WX_AnimID <- "wx_anim_22";
		this.m.WX_AnimMode <- "prism5_hit";
		this.m.WX_ChoreoID <- "wx_fist_qishang";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.40;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			_properties.DamageTotalMult *= 1.18;
			if ("Streams" in ::Wuxia) ::Wuxia.Streams.addCappedPen(_properties, 0.10);
		}
	}

	function isUsable()
	{
		return this.wx_move_base.isUsable() && this.getContainer().getActor().getHitpoints() > 6;
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		local hp = _user.getHitpoints();
		if (target == null || hp <= 6) return false;
		local elem = ("TileField" in ::Wuxia) ? ::Wuxia.TileField.getPrimaryNeigongElement(_user) : "";
		local recoil = (elem == "yang" || elem == "harmony") ? 2 : 6;
		_user.setHitpoints(hp - recoil);

		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && target.isAlive())
		{
			this.wxApplyStatusToTarget(target, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury");
			this.wxApplyStatusToTarget(target, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			this.wxApplyStatusToTarget(target, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
		}
		this.wxTriggerTagPostMechanic(_user, target, _targetTile, hit);
		return hit;
	}
});
