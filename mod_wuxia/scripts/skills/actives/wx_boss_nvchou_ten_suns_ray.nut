// Shan Hai Boss Bespoke Active (`boss_nvchou` #1): 十日焦山·交叉阳炎线 (Triangulated Sun-to-Nvchou Ray Scorch Lines!)

this.wx_boss_nvchou_ten_suns_ray <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown    = 0,
		WX_VfxBrush = "wx_vfx_02",
		WX_ChoreoID = "wx_boss_nvchou_ten_suns_ray"
	},

	function create()
	{
		this.m.ID = "actives.wx_boss_nvchou_ten_suns_ray";
		this.m.Name = "十日焦山·交叉阳炎线";
		this.m.Description = "女丑招引空中所有存活【炙魂日冕】投射交叉大日火线：灼穿目标格及『日冕—女丑』连线上的敌军（熔甲 18 点、直伤 16 点并铺设赤旱焦土）。射灭日冕或走位避开三点一线即可规避交叉射线！";
		this.m.Icon = "skills/wx_bow_luori.png";
		this.m.IconDisabled = "skills/wx_bow_luori_sw.png";
		this.m.Overlay = "wx_ov_wx_bow_luori";
		this.m.SoundOnUse = ["sounds/combat/slash_02.wav"];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsAttack = true;
		this.m.IsAOE = true;
		this.m.IsRanged = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 16;
		this.m.MinRange = 1;
		this.m.MaxRange = 4;
		this.m.DirectDamageMult = 0.35;
	}

	function isUsable() { return this.m.Cooldown <= 0 && this.skill.isUsable(); }
	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }

	function traceRayTiles( _fromTile, _toTile )
	{
		local out = [];
		if (_fromTile == null || _toTile == null || !::Wuxia.hasMember(_fromTile, "getDirectionTo")) return out;
		local cur = _fromTile;
		for (local i = 0; i < 5; i = ++i)
		{
			if (cur == null || cur.ID == _toTile.ID) break;
			local dir = cur.getDirectionTo(_toTile);
			if (dir < 0 || !cur.hasNextTile(dir)) break;
			cur = cur.getNextTile(dir);
			if (cur != null && cur.ID != _toTile.ID)
				out.push(cur);
		}
		return out;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.RangedSkill += 18;
			_properties.DamageRegularMin += 32;
			_properties.DamageRegularMax += 48;
		}
	}

	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		local rayMap = {};
		if (_targetTile != null) rayMap["" + _targetTile.ID] <- _targetTile;

		if (::Wuxia.isOnMap(_user))
		{
			local uTile = _user.getTile();
			local totems = ::Wuxia.ShanHaiMultiBody.getAliveTotems(_user);
			foreach (tot in totems)
			{
				if (!tot.isPlacedOnMap()) continue;
				foreach (rt in this.traceRayTiles(tot.getTile(), uTile))
					rayMap["" + rt.ID] <- rt;
			}
		}

		local anyHit = false;
		foreach (_, t in rayMap)
		{
			::Wuxia.TileField.setField(t, "drought_scorch", 3, _user);
			if (t.IsOccupiedByActor)
			{
				local ent = t.getEntity();
				if (ent != null && ent.isAlive() && !_user.isAlliedWith(ent))
				{
					anyHit = true;
					if (ent.getItems() != null)
					{
						local bArm = ent.getItems().getItemAtSlot(::Const.ItemSlot.Body);
						if (bArm != null && bArm.getArmor() > 0)
							bArm.setArmor(::Math.max(0, bArm.getArmor() - 18));
					}
					if (ent.getHitpoints() > 17) ent.setHitpoints(ent.getHitpoints() - 16);
					else ent.setHitpoints(1);
				}
			}
		}
		return anyHit || rayMap.len() > 0;
	}
});
