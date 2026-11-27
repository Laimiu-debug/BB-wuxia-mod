// Shaolin / Internal Palm Delayed Meridian Rupture Status: 【寸劲伏脉】 (`1~3` Stacks -> Organ Rupture Explosion!)
// Faithfully captures《太吾绘卷 / 紫塞秋风》internal寸劲暗伤: harmless at first glance, detonates violently inside organs at 3 stacks!

this.wx_status_hidden_force <- this.inherit("scripts/skills/skill", {
	m = {
		Stacks    = 1,
		TurnsLeft = 3
	},

	function create()
	{
		this.m.ID = "effects.wx_status_hidden_force";
		this.m.Name = "寸劲伏脉（一重）";
		this.m.Description = "内家暗劲潜伏奇经八脉之中：每层使目标内息恢复 -2；叠满三重（或遭刚猛掌法催引）时，暗劲在五脏六腑内轰然炸裂，造成无视护甲的脏腑实伤并引发【内伤】与战意动摇！";
		this.m.Icon = "skills/wx_fist_shock.png";
		this.m.IconMini = "status_effect_54_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsSerialized = false;
		this.m.IsRemovedAfterBattle = true;
	}

	function syncTitle()
	{
		local cn = this.m.Stacks >= 3 ? "三重·将爆" : (this.m.Stacks == 2 ? "二重" : "一重");
		this.m.Name = "寸劲伏脉（" + cn + "）";
	}

	function addStacks( _delta, _instigator = null )
	{
		this.m.TurnsLeft = 3;
		this.m.Stacks += _delta;
		this.syncTitle();
		if (this.m.Stacks >= 3)
		{
			return this.detonate(_instigator);
		}
		return 0;
	}

	function detonate( _instigator = null )
	{
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor == null || !actor.isAlive())
		{
			this.removeSelf();
			return 0;
		}
		local burst = 10 + this.m.Stacks * 6; // 3 stacks -> 28 armor-ignoring organ rupture damage!
		if (actor.getHitpoints() > burst + 1)
			actor.setHitpoints(actor.getHitpoints() - burst);
		else
			actor.setHitpoints(1);

		if (cont != null && !::Wuxia.CombatRules.isUndeadOrConstruct(actor))
		{
			if (!cont.hasSkill("effects.wx_internal_injury"))
				cont.add(::new("scripts/skills/effects/wx_internal_injury"));
		}
		if (::Wuxia.hasMember(actor, "checkMorale"))
			actor.checkMorale(-1, -12);

		if ("VFX" in ::Wuxia)
			::Wuxia.VFX.playTriggerVfx(actor, "wx_vfx_11", "wx_fx_buddha_palm", 0, 120, 1.18);
		if (("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive() && ::Tactical.EventLog != null)
			::Tactical.EventLog.log("[color=#c9382b]【寸劲爆五脏】" + ::Const.UI.getColorizedEntityName(actor) + " 体内三重伏脉暗劲齐爆，五脏剧震吐血！[/color]");

		if (cont != null && ::Wuxia.hasMember(cont, "removeByID"))
			cont.removeByID(this.m.ID);
		this.removeSelf();
		return burst;
	}

	function resetDuration()
	{
		this.addStacks(1, null);
	}

	function onUpdate( _properties )
	{
		_properties.FatigueRecoveryRate = ::Math.max(0, _properties.FatigueRecoveryRate - (this.m.Stacks * 2));
	}

	function onTurnEnd()
	{
		this.m.TurnsLeft -= 1;
		if (this.m.TurnsLeft <= 0)
			this.removeSelf();
	}

	function getTooltip()
	{
		this.syncTitle();
		return [
			{ id = 1, type = "title", text = this.m.Name },
			{ id = 2, type = "description", text = this.getDescription() },
			{ id = 10, type = "text", icon = "ui/icons/special.png", text = "当前潜伏层数：[color=#c9382b]" + this.m.Stacks + " / 3 重[/color]（满 3 重立爆 28 点透甲脏腑伤）" }
		];
	}
});
