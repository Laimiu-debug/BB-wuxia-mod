// Active Move: 回锋架势 (Sword, 4 AP, 18 Qi, Cooldown 2, enables capped auto-counter on missed melee attacks)

this.wx_sword_counter <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {
		Cooldown = 0
	},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_counter";
		this.m.WX_VfxBrush <- "wx_vfx_01";
		this.m.WX_AnimID <- "wx_anim_38";
		this.m.WX_AnimMode <- "counter";
		this.m.WX_ChoreoID <- "wx_sword_counter";
		this.m.Name = "回锋架势";
		this.m.Description = "横剑立势：至下回合开始前招架 +4，敌方近身落空时自动回锋反击（每轮限 1 次，剑道大成限 2 次且次击衰减；每次耗 8~10 内息，与普通格反互斥，冷却 2 回合）。";
		this.m.Icon = "skills/wx_sword_counter.png";
		this.m.IconDisabled = "skills/wx_sword_counter_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_counter";
		this.m.SoundOnUse = [
			"sounds/combat/riposte_01.wav"
		];
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
		this.m.MinRange = 0;
		this.m.MaxRange = 0;
		this.m.RequiredWeaponTypes = ["Sword"];
	}

	function onTurnStart()
	{
		if (this.m.Cooldown > 0) this.m.Cooldown -= 1;
	}

	function onCombatStarted() { this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.Cooldown = 0; }

	function isUsable()
	{
		return this.wx_move_base.isUsable()
			&& !this.getContainer().hasSkill("effects.wx_status_counter_stance")
			&& !this.getContainer().hasSkill("effects.riposte");
	}

	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		if (this.getContainer().hasSkill("effects.riposte"))
			this.getContainer().removeByID("effects.riposte");
		this.getContainer().add(::new("scripts/skills/effects/wx_status_counter_stance"));
		this.Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_user) + " 摆开回锋架势！");
		return true;
	}
});
