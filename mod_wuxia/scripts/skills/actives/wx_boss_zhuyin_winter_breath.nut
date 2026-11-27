// Shan Hai Boss Bespoke Active (`boss_zhuyin` #1): 吹为冬·玄冥霜息 (3-Hex Fan Frost Breath + `abyss_frost` Terrain)

this.wx_boss_zhuyin_winter_breath <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown    = 0,
		WX_VfxBrush = "wx_vfx_10",
		WX_ChoreoID = "wx_boss_zhuyin_winter_breath"
	},

	function create()
	{
		this.m.ID = "actives.wx_boss_zhuyin_winter_breath";
		this.m.Name = "吹为冬·玄冥霜息";
		this.m.Description = "烛龙吹气成严冬：向正前方扇形 3 格喷吐太古玄冥寒潮，冻结经脉（削减 12 内息并挂点穴封气），并将扇面化为【玄冥冻土】（若轰在赤旱焦土上立即引发寒暑崩裂蒸汽爆！）。";
		this.m.Icon = "skills/wx_fist_xuanming.png";
		this.m.IconDisabled = "skills/wx_fist_xuanming_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_xuanming";
		this.m.SoundOnUse = ["sounds/combat/bash_01.wav"];
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
		this.m.DirectDamageMult = 0.35;
	}

	function isUsable()
	{
		return this.m.Cooldown <= 0 && this.skill.isUsable();
	}

	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }

	function collectFanTiles( _originTile, _targetTile )
	{
		local out = [_targetTile];
		if (_originTile == null || _targetTile == null || !::Wuxia.hasMember(_originTile, "getDirectionTo")) return out;
		local dir = _originTile.getDirectionTo(_targetTile);
		local leftDir = (dir + 5) % 6;
		local rightDir = (dir + 1) % 6;
		if (_originTile.hasNextTile(leftDir)) out.push(_originTile.getNextTile(leftDir));
		if (_originTile.hasNextTile(rightDir)) out.push(_originTile.getNextTile(rightDir));
		return out;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 12;
			_properties.DamageRegularMin += 38;
			_properties.DamageRegularMax += 58;
			_properties.DamageArmorMult *= 1.10;
		}
	}

	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		local uTile = _user.getTile();
		local fan = this.collectFanTiles(uTile, _targetTile);
		local anyHit = false;

		foreach (t in fan)
		{
			if (t == null) continue;
			::Wuxia.TileField.setField(t, "abyss_frost", 3, _user);
			if (t.IsOccupiedByActor)
			{
				local ent = t.getEntity();
				if (ent != null && ent.isAlive() && !_user.isAlliedWith(ent))
				{
					local hit = this.attackEntity(_user, ent);
					if (hit && ent.isAlive())
					{
						anyHit = true;
						if (!::Wuxia.CombatRules.isUndeadOrConstruct(ent))
							::Wuxia.CombatRules.spendQi(ent, 12);
						local sk = ent.getSkills();
						if (sk != null && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(ent) && !sk.hasSkill("effects.wx_status_acupoint"))
							sk.add(::new("scripts/skills/effects/wx_status_acupoint"));
					}
				}
			}
		}
		return anyHit || fan.len() > 0;
	}
});
