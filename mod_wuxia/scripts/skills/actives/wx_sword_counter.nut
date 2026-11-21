// Active Move: 回锋架势 (Sword, 3 AP, 14 Qi, enables auto-counter on missed melee attacks)

this.wx_sword_counter <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_sword_counter";
		this.m.WX_VfxBrush <- "wx_vfx_01";
		this.m.WX_AnimID <- "wx_anim_38";
		this.m.WX_AnimMode <- "counter";
		this.m.WX_ChoreoID <- "wx_sword_counter";
		this.m.Name = "回锋架势";
		this.m.Description = "横剑立势：至下回合开始前招架 +5，敌方近身攻势落空时自动回锋反击（每次耗 4 内息）。";
		this.m.Icon = "skills/wx_sword_counter.png";
		this.m.IconDisabled = "skills/wx_sword_counter_sw.png";
		this.m.Overlay = "wx_ov_wx_sword_counter";
		this.m.SoundOnUse = [
			"sounds/combat/riposte_01.wav"
		];
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 3;
		this.m.FatigueCost = 14;
		this.m.MinRange = 0;
		this.m.MaxRange = 0;
		this.m.RequiredWeaponTypes = ["Sword"];
	}

	function isUsable()
	{
		return this.wx_move_base.isUsable() && !this.getContainer().hasSkill("effects.wx_status_counter_stance");
	}

	function onUse( _user, _targetTile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, (::Wuxia.hasMember(this.m, "WX_VfxBrush")) ? this.m.WX_VfxBrush : null);
		this.getContainer().add(::new("scripts/skills/effects/wx_status_counter_stance"));
		this.Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_user) + " 摆开回锋架势！");
		return true;
	}
});
