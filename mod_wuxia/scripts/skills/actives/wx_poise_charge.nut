this.wx_poise_charge <- this.inherit("scripts/skills/actives/wx_move_base", {
	m = {},

	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_poise_charge";
		this.m.WX_VfxBrush <- "wx_vfx_24";
		this.m.WX_AnimID <- "wx_anim_42";
		this.m.WX_AnimMode <- "poise_draw";
		this.m.WX_ChoreoID <- "wx_poise_charge";
		this.m.Name = "沉刀蓄势";
		this.m.Description = "按锷纳刀聚劲：下一次主动攻势命中 +15、总伤 +20%；刀系招式额外进入【纳刀藏锋】（升格为『拔刀一闪』，穿甲 +10%、击头率 +15%，当击斩敌立触发『残心归鞘』返还蓄势，每轮限 1 次）。单次受至少 15 点气血伤会被打断。";
		this.m.Icon = "skills/wx_poise_charge.png";
		this.m.IconDisabled = "skills/wx_poise_charge_sw.png";
		this.m.Overlay = "wx_ov_wx_poise_charge";
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsAttack = false;
		this.m.IsTargeted = false;
		this.m.IsIgnoredAsAOO = true;
		this.m.ActionPointCost = 2;
		this.m.FatigueCost = 8;
		this.m.MinRange = 0;
		this.m.MaxRange = 0;
		this.m.RequiredWeaponTypes = ["Cleaver", "Saber"];
	}

	function isUsable()
	{
		return this.wx_move_base.isUsable() && !this.getContainer().hasSkill("effects.wx_status_poise_charge");
	}

	function onUse( _user, _tile )
	{
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		this.getContainer().add(::new("scripts/skills/effects/wx_status_poise_charge"));
		if ("Streams" in ::Wuxia)
			::Wuxia.Streams.triggerIaidoSheathe(_user);
		return true;
	}
});
