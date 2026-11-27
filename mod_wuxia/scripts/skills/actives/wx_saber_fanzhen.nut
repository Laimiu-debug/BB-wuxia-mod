// Active Move: 两仪合璧斩
this.wx_saber_fanzhen <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_saber_fanzhen";
		this.m.Name = "两仪合璧斩";
		this.m.Description = "正派双刀呼应阵斩：消耗 5 AP 与 20 内息，身旁有同袍并肩作战时命中 +12、额外穿甲 +15%。";
		this.m.Icon = "skills/wx_saber_fanzhen.png";
		this.m.IconDisabled = "skills/wx_saber_fanzhen_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_fanzhen";
		this.m.WX_VfxBrush <- "wx_vfx_21";
		this.m.WX_AnimID <- "wx_anim_20";
		this.m.WX_AnimMode <- "twin_cross";
		this.m.WX_ChoreoID <- "wx_saber_fanzhen";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.SoundOnHit = ["sounds/combat/slash_hit_01.wav"];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 20;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.RequiredWeaponTypes = ["Cleaver", "Sword"];
		this.m.DirectDamageMult = 0.30;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			this.wxApplyTagPreHitProps(_targetEntity, _properties);
			local u = this.getContainer().getActor();
			if (u != null && ::Wuxia.isOnMap(u) && u.getTile() != null)
			{
				local ut = u.getTile();
				local hasAlly = false;
				for (local d = 0; d < 6; d = ++d)
				{
					if (!ut.hasNextTile(d)) continue;
					local nt = ut.getNextTile(d);
					if (nt != null && nt.IsOccupiedByActor && nt.getEntity() != null && nt.getEntity().isAlive() && u.isAlliedWith(nt.getEntity()))
					{
						hasAlly = true;
						break;
					}
				}
				if (hasAlly)
				{
					_properties.MeleeSkill += 12;
					if ("Streams" in ::Wuxia) ::Wuxia.Streams.addCappedPen(_properties, 0.14);
				}
			}
		}
	}

	function onUse( _user, _targetTile )
	{
		local target = _targetTile.getEntity();
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		local hit = this.attackEntity(_user, target);
		if (hit && _targetTile != null && ("TileField" in ::Wuxia))
		{
			if (::Wuxia.TileField.hasField(_targetTile, "abyss_frost") || ::Wuxia.TileField.hasField(_targetTile, "drought_scorch"))
			{
				::Wuxia.TileField.removeField(_targetTile);
				if (target != null && target.isAlive() && target.getHitpoints() > 13)
					target.setHitpoints(target.getHitpoints() - 12);
				::Wuxia.CombatRules.restoreQi(_user, 6);
			}
		}
		this.wxTriggerTagPostMechanic(_user, target, _targetTile, hit);
		return hit;
	}
});
