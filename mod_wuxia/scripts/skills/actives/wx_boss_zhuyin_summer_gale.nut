// Shan Hai Boss Bespoke Active (`boss_zhuyin` #2): 呼为夏·钟山炎风 (3-Hex Piercing Line Scorch Breath + Thermal Steam Detonation)

this.wx_boss_zhuyin_summer_gale <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown    = 0,
		WX_VfxBrush = "wx_vfx_02",
		WX_ChoreoID = "wx_boss_zhuyin_summer_gale"
	},

	function create()
	{
		this.m.ID = "actives.wx_boss_zhuyin_summer_gale";
		this.m.Name = "呼为夏·钟山炎风";
		this.m.Description = "烛龙呼气化酷暑：沿直线贯通 3 格喷射钟山赤炎（熔毁 22 点身甲并蒸干内息），将整条走廊化为【赤旱焦土】；若贯入已有【玄冥冻土】之格，当场引爆寒暑蒸汽崩裂重创周遭！";
		this.m.Icon = "skills/wx_saber_ranmu.png";
		this.m.IconDisabled = "skills/wx_saber_ranmu_sw.png";
		this.m.Overlay = "wx_ov_wx_saber_ranmu";
		this.m.SoundOnUse = ["sounds/combat/slash_01.wav"];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsAttack = true;
		this.m.IsAOE = true;
		this.m.IsIgnoredAsAOO = true;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 18;
		this.m.MinRange = 1;
		this.m.MaxRange = 2;
		this.m.DirectDamageMult = 0.30;
	}

	function isUsable()
	{
		return this.m.Cooldown <= 0 && this.skill.isUsable();
	}

	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }

	function collectLineTiles( _originTile, _targetTile )
	{
		local out = [];
		if (_originTile == null || _targetTile == null || !::Wuxia.hasMember(_originTile, "getDirectionTo"))
			return [_targetTile];
		local dir = _originTile.getDirectionTo(_targetTile);
		local cur = _originTile;
		for (local step = 0; step < 3; step = ++step)
		{
			if (cur == null || !cur.hasNextTile(dir)) break;
			cur = cur.getNextTile(dir);
			if (cur != null) out.push(cur);
		}
		if (out.len() == 0) out.push(_targetTile);
		return out;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 14;
			_properties.DamageRegularMin += 42;
			_properties.DamageRegularMax += 64;
			_properties.DamageArmorMult *= 1.35;
		}
	}

	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		local line = this.collectLineTiles(_user.getTile(), _targetTile);
		local anyHit = false;

		foreach (t in line)
		{
			if (t == null) continue;
			if (t.IsOccupiedByActor)
			{
				local ent = t.getEntity();
				if (ent != null && ent.isAlive() && !_user.isAlliedWith(ent))
				{
					local hit = this.attackEntity(_user, ent);
					if (hit && ent.isAlive())
					{
						anyHit = true;
						if (ent.getItems() != null)
						{
							local bArm = ent.getItems().getItemAtSlot(::Const.ItemSlot.Body);
							if (bArm != null && bArm.getArmor() > 0)
								bArm.setArmor(::Math.max(0, bArm.getArmor() - 22));
						}
					}
				}
			}
			::Wuxia.TileField.setField(t, "drought_scorch", 3, _user);
		}
		return anyHit || line.len() > 0;
	}
});
