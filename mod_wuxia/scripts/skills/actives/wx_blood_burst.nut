// Active Move: 燃血催劲 (Evil Secret Neigong Tier 3: 0 AP, costs 12% HP, grants +2 temporary AP this turn)

this.wx_blood_burst <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown = 0
	},

	function create()
	{
		this.m.ID = "actives.wx_blood_burst";
		this.m.WX_VfxBrush <- "wx_vfx_20";
		this.m.WX_AnimID <- "wx_anim_70";
		this.m.WX_AnimMode <- "blood_flame";
		this.m.WX_ChoreoID <- "wx_blood_burst";
		this.m.Name = "燃血催劲";
		this.m.Description = "燃烧自身 12% 气血，本回合立即临时 +2 AP。下次行动开始时自然回气减半，冷却 3 回合。";
		this.m.Icon = "skills/wx_blood_burst.png";
		this.m.IconDisabled = "skills/wx_blood_burst_sw.png";
		this.m.Overlay = "wx_ov_wx_blood_burst";
		this.m.SoundOnUse = [
			"sounds/combat/shieldwall_01.wav",
			"sounds/combat/shieldwall_03.wav"
		];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 0;
		this.m.FatigueCost = 0;
		this.m.MinRange = 0;
		this.m.MaxRange = 0;
	}

	function isUsable()
	{
		local actor = this.getContainer().getActor();
		if (actor == null) return false;
		local hpCost = ::Math.max(6, ::Math.floor(actor.getHitpointsMax() * 0.12));
		return this.skill.isUsable() && this.m.Cooldown <= 0 && actor.getHitpoints() > hpCost + 2;
	}

	function onUpdate( _properties )
	{
		if (this.m.Cooldown == 3) _properties.FatigueRecoveryRateMult *= 0.5;
	}

	function onTurnStart()
	{
		if (this.m.Cooldown > 0) this.m.Cooldown -= 1;
	}

	function onCombatStarted()
	{
		this.m.Cooldown = 0;
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		local hpCost = ::Math.max(6, ::Math.floor(_user.getHitpointsMax() * 0.12));
		_user.setHitpoints(::Math.max(1, _user.getHitpoints() - hpCost));
		local c = ::Wuxia.Slots.getContainer(_user);
		local amount = (c != null && c.m.CachedAggFlags != null && c.m.CachedAggFlags.BloodBurstAP > 0) ? c.m.CachedAggFlags.BloodBurstAP : 2;
		local before = _user.getActionPoints();
		if (c != null) c.grantTemporaryAP(amount);
		else _user.setActionPoints(::Math.min(::Wuxia.Config.Constants.MaxTemporaryAP, before + amount));
		local gained = _user.getActionPoints() - before;
		this.m.Cooldown = 3;
		this.getContainer().update();
		this.Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_user) + " 损耗 " + hpCost + " 气血，本回合临时 +" + gained + " AP！");
		return true;
	}
});
