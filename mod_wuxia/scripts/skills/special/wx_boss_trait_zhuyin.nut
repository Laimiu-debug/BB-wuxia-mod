// Bespoke Shan Hai Mythic Trait: 【钟山古神·烛九阴】《视为昼·瞑为夜·呼吸寒暑》
//《海外北经》：“视为昼，瞑为夜，吹为冬，呼为夏，不饮，不食，不息，息为风，身长千里。”

this.wx_boss_trait_zhuyin <- this.inherit("scripts/skills/skill", {
	m = {
		WX_IsShanHaiBossTrait = true,
		BossKey               = "zhuyin",
		IsDayPhase            = true,
		IsInhalingWind        = false,
		WindCharged           = false,
		WindBreakProgress     = 0,
		BodyBroken            = false,
		TailBroken            = false
	},

	function create()
	{
		this.m.ID = "special.wx_boss_trait_zhuyin";
		this.m.Name = "视为昼瞑为夜·千里真龙躯";
		this.m.Description = "《海外北经》钟山古神烛龙真相：三格蜿蜒真龙躯（神首·赤鳞龙躯·盘山龙尾）。单数轮【视为昼】全场视野大明、正面神瞳灼目（正面攻其首者命中-8）；双数轮【瞑为夜】夜幕低垂敛息蓄风（露出七寸破绽，以点穴/纯阳内劲/破气剑重击 3 点破招值可震断太古朔风！）。击碎龙躯鳞甲可破盘山绞，击碎龙尾鳞甲削其近防！";
		this.m.Icon = "skills/wx_neigong_hanbing.png";
		this.m.IconMini = "status_effect_74_mini";
		this.m.Type = this.Const.SkillType.Special | this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.Trait;
		this.m.IsActive = false;
		this.m.IsHidden = false;
		this.m.IsSerialized = false;
	}

	function getSegmentSpecs()
	{
		return [
			{ Key = "body_seg", Name = "烛九阴·赤鳞龙躯", BodyArmor = 260, HeadArmor = 190, MeleeDef = 10, Brush = "wx_part_zhuyin_body" },
			{ Key = "tail_seg", Name = "烛九阴·盘山龙尾", BodyArmor = 210, HeadArmor = 150, MeleeDef = 12, Brush = "wx_tail_zhuyin" }
		];
	}

	function onCombatStarted()
	{
		this.m.IsDayPhase = true;
		this.m.IsInhalingWind = false;
		this.m.WindCharged = false;
		this.m.WindBreakProgress = 0;
		this.m.BodyBroken = false;
		this.m.TailBroken = false;
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor != null)
		{
			::Wuxia.ShanHaiMultiBody.spawnCoiledSegments(actor, this.getSegmentSpecs());
			::Wuxia.TileField.setWeather("zhuyin_day", actor.getID(), 2);
		}
	}

	function onSubPartBroken( _partKey )
	{
		if (_partKey == "body_seg")
		{
			this.m.BodyBroken = true;
			local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
			if (actor != null)
			{
				local rec = ::Wuxia.ShanHaiMultiBody.getOrCreateRecord(actor, "segments");
				if (rec != null) rec.LockedSkills["actives.wx_boss_zhuyin_coil_crush"] <- true;
			}
		}
		else if (_partKey == "tail_seg")
		{
			this.m.TailBroken = true;
		}
	}

	function onTurnStart()
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null || !actor.isAlive()) return;
		::Wuxia.ShanHaiMultiBody.spawnCoiledSegments(actor, this.getSegmentSpecs());

		local round = (("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive() && ::Tactical.TurnSequenceBar != null)
			? ::Tactical.TurnSequenceBar.getCurrentRound() : (this.m.IsDayPhase ? 2 : 1);

		if (this.m.IsInhalingWind && this.m.WindBreakProgress < 3)
			this.m.WindCharged = true;

		this.m.IsDayPhase = (round % 2 == 1);
		if (this.m.IsDayPhase)
		{
			this.m.IsInhalingWind = false;
			this.m.WindBreakProgress = 0;
			::Wuxia.TileField.setWeather("zhuyin_day", actor.getID(), 2);
			if (::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
				::Tactical.EventLog.log("[color=#d9822b]【烛阴开目·视为昼】钟山赤芒映照四野，直视龙首者双目生眩！[/color]");
		}
		else
		{
			this.m.IsInhalingWind = true;
			this.m.WindBreakProgress = 0;
			::Wuxia.TileField.setWeather("zhuyin_night", actor.getID(), 2);
			if (::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
				::Tactical.EventLog.log("[color=#5c7cfa]【烛阴阖目·瞑为夜】天地骤陷永夜，烛龙敛息吞纳朔风（七寸破绽已露，速以点穴/纯阳/破气断招）！[/color]");
		}
	}

	function onUpdate( _properties )
	{
		_properties.IsImmuneToStun = true;
		_properties.IsImmuneToDisarm = true;
		_properties.ActionPoints = ::Math.max(_properties.ActionPoints, 10);
		if (this.m.IsDayPhase)
		{
			_properties.MeleeSkill += 12;
			_properties.DamageTotalMult *= 1.15;
		}
		else
		{
			_properties.RangedDefense += 15;
		}
		if (this.m.TailBroken)
			_properties.MeleeDefense -= 10;
	}

	function onBeforeDamageReceived( _attacker, _skill, _hitInfo, _properties )
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null || _attacker == null || _skill == null) return;

		// Day Phase: Blinding Dragon Gaze penalizes frontal melee strikes unless Body/Tail was broken
		if (this.m.IsDayPhase && !_skill.isRanged() && ::Wuxia.isOnMap(actor) && ::Wuxia.isOnMap(_attacker))
		{
			local dir = actor.getTile().getDirectionTo(_attacker.getTile());
			if (dir == 0 || dir == 1 || dir == 5)
				_properties.DamageReceivedRegularMult *= 0.85;
		}

		// Night Phase Inhale Window: Counterplay break check!
		if (this.m.IsInhalingWind && _hitInfo != null && _hitInfo.DamageRegular + _hitInfo.DamageArmor > 0)
		{
			local pts = 1;
			local sid = ::Wuxia.hasMember(_skill, "getID") && _skill.getID() != null ? _skill.getID() : "";
			if (sid.find("acupoint") != null || sid == "actives.wx_sword_dugu" || sid == "actives.wx_fist_yiyang"
				|| ::Wuxia.TileField.getPrimaryNeigongElement(_attacker) == "yang")
				pts = 2;
			this.m.WindBreakProgress += pts;
			if (this.m.WindBreakProgress >= 3)
			{
				this.m.IsInhalingWind = false;
				this.m.WindCharged = false;
				this.m.WindBreakProgress = 0;
				if (actor.getHitpoints() > 46) actor.setHitpoints(actor.getHitpoints() - 45);
				else actor.setHitpoints(1);
				local sk = actor.getSkills();
				if (sk != null && !sk.hasSkill("effects.wx_status_offbalance"))
					sk.add(::new("scripts/skills/effects/wx_status_offbalance"));
				if (::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
					::Tactical.EventLog.log("[color=#166b2f]【七寸截息】烛九阴吞风气机被一击震断，太古朔风反噬龙腑！[/color]");
			}
		}
	}

	function getTooltip()
	{
		local phaseTxt = this.m.IsDayPhase ? "【当前天象：视为昼（神瞳灼目·攻势炽烈）】" : "【当前天象：瞑为夜（永夜降临·吞风破绽期）】";
		local ret = [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() },
			{ id = 10, type = "text", icon = "ui/icons/special.png", text = phaseTxt },
			{ id = 11, type = "text", icon = "ui/icons/armor_body.png", text = "真龙体节：赤鳞龙躯[" + (this.m.BodyBroken ? "已破鳞" : "完好") + "] · 盘山龙尾[" + (this.m.TailBroken ? "已断势" : "完好") + "]" },
			{ id = 12, type = "text", icon = "ui/icons/warning.png", text = "【破局要诀】重兵先碎龙躯/龙尾破其盘绞，切勿留在玄冥冻土格上硬接夏炎吐息，趁偶轮阖目以纯阳/点穴截断朔风！" }
		];
		return ret;
	}
});
