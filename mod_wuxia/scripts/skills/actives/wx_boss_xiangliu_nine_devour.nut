// Shan Hai Boss Bespoke Active (`boss_xiangliuwang` #1): 九首食于九山 (Multi-Head Voracious Devour Scaling with Surviving Heads)

this.wx_boss_xiangliu_nine_devour <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown    = 0,
		WX_VfxBrush = "wx_vfx_28",
		WX_ChoreoID = "wx_boss_xiangliu_nine_devour"
	},

	function create()
	{
		this.m.ID = "actives.wx_boss_xiangliu_nine_devour";
		this.m.Name = "九首食于九山";
		this.m.Description = "《海外北经》九首以食于九山：相柳催动所有存活凶首向周遭敌军发起连环噬咬（每存 1 具副首多噬 1 口，最多 4 口），每击汲取 12 点气血回哺盘环主躯并注入奇毒！";
		this.m.Icon = "skills/wx_fist_qianzhu.png";
		this.m.IconDisabled = "skills/wx_fist_qianzhu_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_qianzhu";
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
		this.m.DirectDamageMult = 0.32;
	}

	function isUsable() { return this.m.Cooldown <= 0 && this.skill.isUsable(); }
	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			_properties.MeleeSkill += 12;
			_properties.DamageRegularMin += 30;
			_properties.DamageRegularMax += 46;
		}
	}

	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		local aliveHeads = ::Wuxia.ShanHaiMultiBody.getAliveAppendageCount(_user);
		local maxBites = ::Math.max(1, ::Math.min(4, 1 + aliveHeads));

		local candidates = [];
		if (_targetTile != null && _targetTile.IsOccupiedByActor)
		{
			local prim = _targetTile.getEntity();
			if (prim != null && prim.isAlive() && !_user.isAlliedWith(prim))
				candidates.push(prim);
		}
		if (::Wuxia.isOnMap(_user))
		{
			local uTile = _user.getTile();
			for (local d = 0; d < 6; d = ++d)
			{
				if (!uTile.hasNextTile(d)) continue;
				local nt = uTile.getNextTile(d);
				if (nt.IsOccupiedByActor && nt.getEntity() != null && nt.getEntity().isAlive() && !_user.isAlliedWith(nt.getEntity()))
					candidates.push(nt.getEntity());
			}
		}
		if (candidates.len() == 0) return false;

		local anyHit = false;
		for (local i = 0; i < maxBites; i = ++i)
		{
			local tgt = candidates[i % candidates.len()];
			if (tgt == null || !tgt.isAlive()) continue;
			local hit = this.attackEntity(_user, tgt);
			if (hit)
			{
				anyHit = true;
				if (_user.getHitpoints() < _user.getHitpointsMax())
					_user.setHitpoints(::Math.min(_user.getHitpointsMax(), _user.getHitpoints() + 12));
				if (tgt.isAlive() && tgt.getSkills() != null && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(tgt) && !tgt.getSkills().hasSkill("effects.wx_status_poison_dart"))
					tgt.getSkills().add(::new("scripts/skills/effects/wx_status_poison_dart"));
			}
		}
		return anyHit;
	}
});
