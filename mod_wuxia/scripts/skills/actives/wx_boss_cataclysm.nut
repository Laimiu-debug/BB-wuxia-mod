// Active Mythic Boss Skill: 山海天灾 · 荒神怒击 (Unleashed when a Shan Hai Boss's telegraphed charge is NOT broken!)

this.wx_boss_cataclysm <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown = 0
	},

	function create()
	{
		this.m.ID = "actives.wx_boss_cataclysm";
		this.m.Name = "荒神天灾";
		this.m.Description = "山海大妖蓄满凶煞后倾泻的毁天灭地冲击，震伤周围 2 格内全体敌军护甲、气血与内息。";
		this.m.Icon = "skills/wx_tactics_kuiniu.png";
		this.m.IconDisabled = "skills/wx_tactics_kuiniu_sw.png";
		this.m.Overlay = "wx_ov_wx_tactics_kuiniu";
		this.m.SoundOnUse = [
			"sounds/combat/shatter_hit_01.wav",
			"sounds/combat/crush_armor_03.wav"
		];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.OffensiveTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = true;
		this.m.IsAOE = true;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 0;
		this.m.MinRange = 0;
		this.m.MaxRange = 0;
	}

	function onTurnStart()
	{
		if (this.m.Cooldown > 0) this.m.Cooldown -= 1;
	}

	function isUsable()
	{
		if (this.m.Cooldown > 0 || !this.skill.isUsable()) return false;
		local cont = this.getContainer();
		if (cont == null) return false;
		local trait = cont.getSkillByID("special.wx_shanhai_boss_trait");
		if (trait == null || !("m" in trait) || !trait.m.CataclysmReady) return false;
		local actor = cont.getActor();
		if (actor == null || !::Wuxia.isOnMap(actor)) return false;
		local myTile = actor.getTile();
		local all = ::Tactical.Entities.getAllInstancesAsArray();
		foreach (ent in all)
		{
			if (ent != null && ent.isAlive() && ::Wuxia.isOnMap(ent) && !actor.isAlliedWith(ent) && myTile.getDistanceTo(ent.getTile()) <= 2)
				return true;
		}
		return false;
	}

	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		local cont = _user.getSkills();
		local trait = cont != null ? cont.getSkillByID("special.wx_shanhai_boss_trait") : null;
		if (trait != null && ("m" in trait))
			trait.m.CataclysmReady = false;

		local myTile = _user.getTile();
		if ("VFX" in ::Wuxia)
			::Wuxia.VFX.playTriggerVfx(myTile, "wx_vfx_20", "wx_fx_earth_fissure", -20, 120, 1.55);

		if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
			::Tactical.EventLog.log("【山海天灾】" + ::Const.UI.getColorizedEntityName(_user) + " 倾泻蓄满的太古凶煞，天地剧震！");

		local all = ::Tactical.Entities.getAllInstancesAsArray();
		foreach (ent in all)
		{
			if (ent == null || !ent.isAlive() || !::Wuxia.isOnMap(ent) || _user.isAlliedWith(ent)) continue;
			local dist = myTile.getDistanceTo(ent.getTile());
			if (dist > 2) continue;

			local mult = (dist == 1) ? 1.0 : 0.65;
			local eProps = ent.getCurrentProperties();
			local dmgMult = ::Math.maxf(0.35, eProps.DamageReceivedRegularMult);
			local hpLoss = ::Math.max(6, ::Math.round(26.0 * mult * dmgMult));
			local armLoss = ::Math.round(34.0 * mult);

			if (::Wuxia.hasMember(ent, "getItems") && ent.getItems() != null)
			{
				local body = ent.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (body != null && body.getArmor() > 0)
					body.setArmor(::Math.max(0, body.getArmor() - armLoss));
			}
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(ent))
				::Wuxia.CombatRules.spendQi(ent, ::Math.round(14.0 * mult));

			if (ent.getHitpoints() > hpLoss + 1)
				ent.setHitpoints(ent.getHitpoints() - hpLoss);
			else
				ent.setHitpoints(1);

			local esk = ent.getSkills();
			if (esk != null && dist == 1 && !esk.hasSkill("effects.wx_status_offbalance"))
				esk.add(::new("scripts/skills/effects/wx_status_offbalance"));
			if ("VFX" in ::Wuxia)
				::Wuxia.VFX.shakeEntityFrom(ent, myTile, 8.0);
		}
		return true;
	}
});
