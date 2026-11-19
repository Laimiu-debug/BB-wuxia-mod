// Combat Status: 蓄势 (Next attack +15% hit and +20% damage; broken if heavily damaged)

this.wx_status_poise_charge <- this.inherit("scripts/skills/skill", {
	m = {},

	function create()
	{
		this.m.ID = "effects.wx_status_poise_charge";
		this.m.Name = "蓄势";
		this.m.Description = "沉气蓄势：下一次主动攻势命中 +15%、伤害 +20%；若在此前遭受重创则蓄势被打断。";
		this.m.Icon = "skills/status_effect_74.png";
		this.m.IconMini = "status_effect_74_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill != null && _skill.isAttack())
		{
			_properties.MeleeSkill += 15;
			_properties.RangedSkill += 15;
			_properties.DamageTotalMult *= 1.20;
		}
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		if (_skill != null && _skill.isAttack()) this.removeSelf();
	}

	function onTargetMissed( _skill, _targetEntity )
	{
		if (_skill != null && _skill.isAttack()) this.removeSelf();
	}

	function onDamageReceived( _attacker, _damageHitpoints, _damageArmor )
	{
		if (_damageHitpoints >= 15)
		{
			this.Tactical.EventLog.log(::Const.UI.getColorizedEntityName(this.getContainer().getActor()) + " 遭重创，蓄势被打断！");
			this.removeSelf();
		}
	}
});
