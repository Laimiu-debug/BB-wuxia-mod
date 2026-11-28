// Combat Status: 暗器剧毒 (Deals HP damage + drains Qi on turn end / wait for 3 turns, matching vanilla DoT lifecycle)

this.wx_status_poison_dart <- this.inherit("scripts/skills/skill", {
	m = {
		TurnsLeft = 3,
		DamagePerTurn = 8,
		QiDrainPerTurn = 5,
		LastRoundApplied = -1
	},

	function create()
	{
		this.m.ID = "effects.wx_status_poison_dart";
		this.m.Name = "暗器剧毒";
		this.m.Description = "毒针入血，每回合结束或等待时损失 8 点气血并散逸 5 点内息。";
		this.m.Icon = "skills/wx_status_poison_dart.png";
		this.m.IconMini = "status_effect_54_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
	}

	function resetDuration( _turns = 3 )
	{
		this.m.TurnsLeft = ::Math.max(this.m.TurnsLeft, _turns);
	}

	function applyDamage()
	{
		local curRound = this.Time.getRound();
		if (this.m.LastRoundApplied == curRound) return;
		this.m.LastRoundApplied = curRound;

		local container = this.getContainer();
		local actor = container != null ? container.getActor() : null;
		if (actor != null && actor.isAlive() && !actor.isDying() && actor.isPlacedOnMap())
		{
			local hitInfo = clone ::Const.Tactical.HitInfo;
			hitInfo.DamageRegular = this.m.DamagePerTurn;
			hitInfo.DamageDirect = 1.0;
			hitInfo.BodyPart = ::Const.BodyPart.Body;
			hitInfo.BodyDamageMult = 1.0;
			hitInfo.FatalityChanceMult = 0.0;
			actor.onDamageReceived(actor, this, hitInfo);
			if (actor.isAlive() && !actor.isDying())
				::Wuxia.CombatRules.spendQi(actor, this.m.QiDrainPerTurn);
		}

		this.m.TurnsLeft -= 1;
		if (this.m.TurnsLeft <= 0) this.removeSelf();
	}

	function onTurnEnd()
	{
		this.applyDamage();
	}

	function onWaitTurn()
	{
		this.applyDamage();
	}
});
