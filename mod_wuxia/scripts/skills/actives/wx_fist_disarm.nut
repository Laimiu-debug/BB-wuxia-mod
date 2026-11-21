// Secret Fist Move 2: 空手夺白刃 (5 AP, 22 Qi, 1-turn cooldown, disarms enemy mainhand weapon for 1 turn)

this.wx_fist_disarm <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {
		Cooldown = 0
	},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_fist_disarm";
		this.m.WX_VfxBrush <- "wx_vfx_15";
		this.m.WX_AnimID <- "wx_anim_50";
		this.m.WX_AnimMode <- "disarm_grab";
		this.m.WX_ChoreoID <- "wx_fist_disarm";
		this.m.Name = "空手夺白刃";
		this.m.Description = "欺身切腕反扣兵刃：造成四成擒拿伤，命中后夺卸目标主手兵器 1 回合（使其无法使用武器招式，隔回合冷却）。";
		this.m.Icon = "skills/wx_fist_disarm.png";
		this.m.IconDisabled = "skills/wx_fist_disarm_sw.png";
		this.m.Overlay = "wx_ov_wx_fist_disarm";
		this.m.SoundOnUse = [
			"sounds/combat/hand_03.wav"
		];
		this.m.SoundOnHit = [
			"sounds/combat/hand_hit_03.wav"
		];
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 22;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
		this.m.InjuriesOnBody = this.Const.Injury.BluntBody;
		this.m.InjuriesOnHead = this.Const.Injury.BluntHead;
		this.m.RequiredWeaponTypes = ["Fist"];
		this.m.DirectDamageMult = 0.40;
		this.m.IsIgnoredAsAOO = true;
	}

	function onTurnStart()
	{
		if (this.m.Cooldown > 0) this.m.Cooldown -= 1;
	}

	function onCombatStarted()
	{
		this.m.Cooldown = 0;
	}

	function onCombatFinished()
	{
		this.m.Cooldown = 0;
	}

	function isUsable()
	{
		return this.m.Cooldown <= 0 && this.wx_move_base.isUsable();
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile)) return false;
		local target = _targetTile.getEntity();
		if (target == null || target.getCurrentProperties().IsImmuneToDisarm) return false;
		return target.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand) != null;
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == this)
		{
			local c = this.getContainer().getSkillByID("special.wx_martial_container");
			local bonus = (c != null && c.m.CachedAggFlags != null) ? c.m.CachedAggFlags.DisarmHitBonus : 0;
			_properties.MeleeSkill += bonus;
			_properties.DamageTotalMult *= 0.40;
		}
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local target = _targetTile.getEntity();
		this.m.Cooldown = 2; // Decrements on next turn start -> 1 full turn cooldown
		local hit = this.attackEntity(_user, target);
		if (hit && target != null && target.isAlive() && !target.getCurrentProperties().IsImmuneToDisarm)
		{
			target.getSkills().add(::new("scripts/skills/effects/disarmed_effect"));
			this.Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_user) + " 使出空手夺白刃，锁住并卸去 " + ::Const.UI.getColorizedEntityName(target) + " 的兵刃！");
		}
		return hit;
	}
});
