// Bespoke Shan Hai Mythic Trait: 【十日炙山·青衣赤魃女丑魂】《以袂蔽面·十日居上》
//《海外西经》：“女丑之尸，生而十日炙杀之，在丈夫北。以右手鄣其面。十日居上，女丑居山之上。”

this.wx_boss_trait_nvchou <- this.inherit("scripts/skills/skill", {
	m = {
		WX_IsShanHaiBossTrait = true,
		BossKey               = "nvchou",
		IsChargingApocalypse  = false,
		SunsShotDown          = 0
	},

	function create()
	{
		this.m.ID = "special.wx_boss_trait_nvchou";
		this.m.Name = "以袂蔽面·十日居上";
		this.m.Description = "《海外西经》十日炙杀之女丑尸魂：战场高悬 3 轮【汤谷炙魂日冕】阵眼。每存 1 轮日冕，每回合蒸干敌军 4 点内息并为女丑提供 18% 大日阳炎减伤；女丑以右手青袂障面，正面受击额外卸劲 35%，唯侧背盲区无遮挡。远程『后羿射日』点灭日冕可破除阳炎护障并当场打断其大旱灭世咒！";
		this.m.Icon = "skills/wx_bow_luori.png";
		this.m.IconMini = "status_effect_74_mini";
		this.m.Type = this.Const.SkillType.Special | this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.Trait;
		this.m.IsActive = false;
		this.m.IsHidden = false;
		this.m.IsSerialized = false;
	}

	function getTotemSpecs()
	{
		return [
			{ Key = "sun_1", Name = "汤谷炙魂日冕·东曦", Hitpoints = 85, RangedDef = 4, MeleeDef = 8, Brush = "wx_totem_sun_corona", TintHex = "#fff4d2", RoleHint = "射落此日可削去女丑一层阳炎障" },
			{ Key = "sun_2", Name = "汤谷炙魂日冕·南明", Hitpoints = 85, RangedDef = 4, MeleeDef = 8, Brush = "wx_totem_sun_corona", TintHex = "#ffe0a8", RoleHint = "射落此日可削去女丑一层阳炎障" },
			{ Key = "sun_3", Name = "汤谷炙魂日冕·西昊", Hitpoints = 85, RangedDef = 4, MeleeDef = 8, Brush = "wx_totem_sun_corona", TintHex = "#ffcb8e", RoleHint = "射落此日可削去女丑一层阳炎障" }
		];
	}

	function getAliveSunCount()
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null) return ::Math.max(0, 3 - this.m.SunsShotDown);
		local rec = ::Wuxia.ShanHaiMultiBody.getRecord(actor);
		if (rec == null) return ::Math.max(0, 3 - this.m.SunsShotDown);
		if (rec.Totems.len() == 0 && !::Wuxia.ShanHaiMultiBody.isLiveMap(actor))
			return ::Math.max(0, 3 - this.m.SunsShotDown);
		return ::Wuxia.ShanHaiMultiBody.getAliveTotems(actor).len();
	}

	function onCombatStarted()
	{
		this.m.IsChargingApocalypse = false;
		this.m.SunsShotDown = 0;
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor != null)
			::Wuxia.ShanHaiMultiBody.spawnDomainTotems(actor, this.getTotemSpecs(), 2, 4);
	}

	function onTotemDestroyed( _partKey, _killer, _tile )
	{
		this.m.SunsShotDown += 1;
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null || !actor.isAlive()) return;

		// Solar link backlash to Nvchou!
		if (actor.getHitpoints() > 31) actor.setHitpoints(actor.getHitpoints() - 30);
		else actor.setHitpoints(1);

		if (_tile != null)
			::Wuxia.TileField.dispelFieldsInRadius(_tile, 2, ["drought_scorch"]);

		if (this.m.IsChargingApocalypse)
		{
			this.m.IsChargingApocalypse = false;
			if (actor.getHitpoints() > 41) actor.setHitpoints(actor.getHitpoints() - 40);
			else actor.setHitpoints(1);
			local sk = actor.getSkills();
			if (sk != null)
			{
				if (!sk.hasSkill("effects.wx_status_offbalance"))
					sk.add(::new("scripts/skills/effects/wx_status_offbalance"));
				if (!sk.hasSkill("effects.wx_status_opening"))
					sk.add(::new("scripts/skills/effects/wx_status_opening"));
			}
			if (::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
				::Tactical.EventLog.log("[color=#166b2f]【射日破咒】一轮炙魂日冕应弦坠落，女丑『十日同炙咒』当场崩解反噬！[/color]");
		}
		else if (::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
		{
			::Tactical.EventLog.log("[color=#166b2f]【后羿射日】一轮炙魂日冕被击碎，十日酷暑消退一分！[/color]");
		}
	}

	function onTurnStart()
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null || !actor.isAlive()) return;
		if (this.m.SunsShotDown == 0)
			::Wuxia.ShanHaiMultiBody.spawnDomainTotems(actor, this.getTotemSpecs(), 2, 4);

		local suns = this.getAliveSunCount();
		if (suns > 0 && ::Wuxia.isOnMap(actor))
		{
			local myTile = actor.getTile();
			local actors = ::Tactical.Entities.getAllInstancesAsArray();
			foreach (ent in actors)
			{
				if (ent == null || !ent.isAlive() || !ent.isPlacedOnMap() || actor.isAlliedWith(ent)) continue;
				if (myTile.getDistanceTo(ent.getTile()) <= 4 && !::Wuxia.CombatRules.isUndeadOrConstruct(ent))
					::Wuxia.CombatRules.spendQi(ent, suns * 4);
			}
		}
	}

	function onUpdate( _properties )
	{
		local suns = this.getAliveSunCount();
		if (suns > 0)
			_properties.DamageReceivedRegularMult *= ::Math.maxf(0.35, 1.0 - 0.18 * suns);
		_properties.MeleeDefense += 14;
		_properties.RangedDefense += 18;
	}

	function onBeforeDamageReceived( _attacker, _skill, _hitInfo, _properties )
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null || _attacker == null || !::Wuxia.isOnMap(actor) || !::Wuxia.isOnMap(_attacker)) return;

		// `以右手鄣其面`: Frontal/right-sleeve directions (0, 1, 5) deflect 35% damage; rear/left (2, 3, 4) take +10%!
		local dir = actor.getTile().getDirectionTo(_attacker.getTile());
		if (dir == 0 || dir == 1 || dir == 5)
		{
			if (this.getAliveSunCount() > 0)
				_properties.DamageReceivedRegularMult *= 0.65;
		}
		else
		{
			_properties.DamageReceivedRegularMult *= 1.10;
		}
	}

	function getTooltip()
	{
		local suns = this.getAliveSunCount();
		return [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() },
			{ id = 10, type = "text", icon = "ui/icons/special.png", text = "高悬炙魂日冕：[color=#d94b2b]" + suns + " / 3 轮[/color]（提供 " + (suns * 18) + "% 阳炎减伤）" },
			{ id = 11, type = "text", icon = "ui/icons/warning.png", text = this.m.IsChargingApocalypse ? "[color=#c9382b]【十日同炙蓄咒中】速射落至少 1 轮日冕打断灭世旱火！[/color]" : "【破局要诀】弓弩暗器优先射落空中日冕，近战绕至其左后盲区背刺，勿站日冕与女丑连线！" }
		];
	}
});
