// Combat Status: 回锋 / 太极借力 / 斗转星移架势 (`effects.wx_status_counter_stance`)
// Upgraded from plain riposte to support:
//   - Standard Sword Counter (`回锋架势`): Capped 1~2 melee counters/round
//   - Taiji Sticky Deflection (`IsTaiji = true`): Redirects missed melee attack onto an adjacent 2nd enemy (`85%` force) or flings lone attacker!
//   - Douzhuan Star-Shift (`IsDouzhuan = true`): Redirects missed melee attack onto an adjacent 2nd enemy (`100%` force, up to 2/round)!

this.wx_status_counter_stance <- this.inherit("scripts/skills/skill", {
	m = {
		IsCountering     = false,
		IsDouzhuan       = false,
		IsTaiji          = false,
		CountersUsed     = 0,
		MaxCounters      = 1,
		QiCostPerCounter = 8
	},

	function create()
	{
		this.m.ID = "effects.wx_status_counter_stance";
		this.m.Name = "回锋架势";
		this.m.Description = "凝神守势：直至下回合开始前近防 +4，敌方近战落空时自动回锋或借力偏转（每回合限 1~2 次，与普通格反互斥）。";
		this.m.Icon = "skills/wx_status_counter_stance.png";
		this.m.IconMini = "status_effect_33_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
	}

	function setDouzhuanMode( _flag )
	{
		this.m.IsDouzhuan = _flag ? true : false;
		if (this.m.IsDouzhuan)
		{
			this.m.Name = "斗转星移架势";
			this.m.Description = "以彼之道还施彼身：近战落空时优先将攻击者招式 100% 原封偏转轰向其身旁另一名敌军（无邻敌则借力甩撞），每轮最多触发 2 次！";
			this.m.MaxCounters = 2;
		}
	}

	function setTaijiMode( _flag )
	{
		this.m.IsTaiji = _flag ? true : false;
		if (this.m.IsTaiji)
		{
			this.m.Name = "太极听劲粘势";
			this.m.Description = "四两拨千斤：敌方近战落空时圆转粘连，将其力道 85% 借力偏转轰击相邻另一名敌军，或将其甩掷撞障失衡！";
			this.m.MaxCounters = 2;
		}
	}

	function resolveMaxCounters()
	{
		if (this.m.IsDouzhuan || this.m.IsTaiji) return 2;
		local c = this.getContainer() != null ? this.getContainer().getSkillByID("special.wx_martial_container") : null;
		if (c != null && c.m.CachedAggFlags != null && c.m.CachedAggFlags.CounterBonus >= 12)
			return 2;
		return 1;
	}

	function onAdded()
	{
		local cont = this.getContainer();
		if (cont != null && cont.hasSkill("effects.riposte"))
			cont.removeByID("effects.riposte");
		this.m.CountersUsed = 0;
		this.m.MaxCounters = this.resolveMaxCounters();
	}

	function getTooltip()
	{
		local maxC = this.resolveMaxCounters();
		local rem = ::Math.max(0, maxC - this.m.CountersUsed);
		return [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() },
			{ id = 10, type = "text", icon = "ui/icons/melee_defense.png", text = "近战招架：[color=" + ::Const.UI.Color.PositiveValue + "]+" + (this.m.IsTaiji ? 6 : 4) + "[/color]" },
			{ id = 11, type = "text", icon = "ui/icons/special.png", text = "本轮剩余拆招次数：[color=" + ::Const.UI.Color.PositiveValue + "]" + rem + " / " + maxC + "[/color]" }
		];
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (!this.m.IsCountering || _skill == null || _skill.isRanged()) return;
		local c = this.getContainer().getSkillByID("special.wx_martial_container");
		local bonus = (c != null && c.m.CachedAggFlags != null) ? ::Math.min(6, ::Math.floor(c.m.CachedAggFlags.CounterBonus * 0.5)) : 0;
		if (this.m.CountersUsed <= 0)
		{
			_properties.MeleeSkill += bonus;
			_properties.DamageTotalMult *= 0.85;
		}
		else
		{
			_properties.MeleeSkill += (bonus - 12);
			_properties.DamageTotalMult *= 0.65;
		}
	}

	function onUpdate( _properties )
	{
		_properties.MeleeDefense += (this.m.IsTaiji ? 6 : 4);
	}

	function onMissed( _attacker, _skill )
	{
		if (_attacker == null || !_attacker.isAlive() || _skill == null || _skill.isRanged() || _skill.isIgnoringRiposte())
			return;

		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor == null || !actor.isAlive() || this.m.IsCountering) return;

		if (cont.hasSkill("effects.riposte"))
			cont.removeByID("effects.riposte");

		local c = cont.getSkillByID("special.wx_martial_container");
		local hasBonus = this.m.IsDouzhuan || this.m.IsTaiji || (c != null && c.m.CachedAggFlags != null && c.m.CachedAggFlags.CounterBonus > 0);
		if (!hasBonus) return;

		local maxC = this.resolveMaxCounters();
		if (this.m.CountersUsed >= maxC)
		{
			this.removeSelf();
			return;
		}

		if (("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive() && ::Tactical.TurnSequenceBar != null)
		{
			local active = ::Tactical.TurnSequenceBar.getActiveEntity();
			if (active == null || active.getID() != _attacker.getID()) return;
		}
		if (actor.isAlliedWith(_attacker)) return;
		if (actor.getTile() != null && _attacker.getTile() != null && actor.getTile().getDistanceTo(_attacker.getTile()) > 1) return;

		local qiCost = (this.m.CountersUsed == 0) ? this.m.QiCostPerCounter : (this.m.QiCostPerCounter + 2);
		// Standing inside Taiji `ancient_ward` reduces counter Qi cost by 3!
		if (actor.getTile() != null && ("TileField" in ::Wuxia) && ::Wuxia.TileField.hasField(actor.getTile(), "ancient_ward"))
			qiCost = ::Math.max(4, qiCost - 3);

		local availQi = actor.getFatigueMax() - actor.getFatigue();
		if (availQi < qiCost)
		{
			this.removeSelf();
			return;
		}

		// Path A: True Taiji / Douzhuan `借力打力` Redirection onto Adjacent 2nd Enemy or Wall-Toss!
		if ((this.m.IsTaiji || this.m.IsDouzhuan) && ("Streams" in ::Wuxia))
		{
			::Wuxia.CombatRules.spendQi(actor, qiCost);
			local defRes = ::Wuxia.Streams.tryDeflectMeleeAttack(actor, _attacker, this.m.IsDouzhuan);
			if (defRes.mode != "none")
			{
				this.m.CountersUsed += 1;
				if (::Wuxia.TileField.getPrimaryNeigongElement(actor) == "harmony")
					::Wuxia.CombatRules.restoreQi(actor, 4);
				if (this.m.CountersUsed >= maxC) this.removeSelf();
				return;
			}
		}

		// Path B: Standard Sword Counter Riposte
		local counterSkill = cont.getAttackOfOpportunity();
		if (counterSkill != null)
		{
			::Wuxia.CombatRules.spendQi(actor, qiCost);
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(actor, "wx_vfx_01", "wx_fx_bagua", 0, 140, 1.08);
			this.m.IsCountering = true;
			try { counterSkill.useForFree(_attacker.getTile()); }
			catch (error) { this.m.IsCountering = false; throw error; }
			this.m.IsCountering = false;
			this.m.CountersUsed += 1;
			if (this.m.CountersUsed >= maxC)
			{
				if (("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.EventLog != null)
					::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(actor) + " 回锋剑势已尽，收剑归守。");
				this.removeSelf();
			}
		}
	}

	function onTurnStart()
	{
		this.removeSelf();
	}
});
