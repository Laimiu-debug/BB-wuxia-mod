// Non-Intrusive Boss Regeneration & Revive Seal Status (`断续封生`)
// Applied by《钦原断续蚀壳膏》or specialized anti-regen strikes; executes at SkillOrder.Last so it
// cleanly clamps any turn-start HP regeneration from Shan-Hai Boss traits without modifying Boss scripts!

this.wx_status_regen_seal <- this.inherit("scripts/skills/skill", {
	m = {
		TurnsLeft       = 2,
		LockedCeilingHP = 999999
	},

	function create()
	{
		this.m.ID = "effects.wx_status_regen_seal";
		this.m.Name = "断续封生";
		this.m.Description = "钦原奇毒深入骨髓，彻底截断血肉自愈生机与血契复生，每回合初无法再生恢复气血。";
		this.m.Icon = "skills/wx_status_poison_dart.png";
		this.m.IconMini = "status_effect_54_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.Last;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsSerialized = false;
		this.m.IsRemovedAfterBattle = true;
	}

	function setTurns( _turns )
	{
		this.m.TurnsLeft = ::Math.max(1, _turns);
	}

	function resetDuration( _turns = 2 )
	{
		this.m.TurnsLeft = ::Math.max(this.m.TurnsLeft, _turns);
	}

	function lockCurrentHP()
	{
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor != null && ::Wuxia.hasMember(actor, "getHitpoints"))
			this.m.LockedCeilingHP = actor.getHitpoints();
	}

	function onAdded()
	{
		this.lockCurrentHP();
	}

	function onDamageReceived( _attacker, _damageHitpoints, _damageArmor )
	{
		this.lockCurrentHP();
	}

	function getTooltip()
	{
		return [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() },
			{ id = 10, type = "text", icon = "ui/icons/special.png", text = "剩余持续回合：[color=" + ::Const.UI.Color.NegativeValue + "]" + this.m.TurnsLeft + "[/color]" }
		];
	}

	function onTurnStart()
	{
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor != null && actor.isAlive() && ::Wuxia.hasMember(actor, "getHitpoints"))
		{
			if (actor.getHitpoints() > this.m.LockedCeilingHP)
			{
				actor.setHitpoints(this.m.LockedCeilingHP);
				if (("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive() && ("EventLog" in ::Tactical) && ::Tactical.EventLog != null)
					::Tactical.EventLog.log("【断续封生】奇膏截断生机，" + ::Const.UI.getColorizedEntityName(actor) + " 无法自愈回血！");
			}
			this.m.LockedCeilingHP = actor.getHitpoints();
		}
		this.m.TurnsLeft -= 1;
		if (this.m.TurnsLeft <= 0)
			this.removeSelf();
	}

	function onTurnEnd()
	{
		this.lockCurrentHP();
	}
});
