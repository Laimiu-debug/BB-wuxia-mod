this.wx_poise_charge <- this.inherit("scripts/skills/actives/wx_move_base", {
	function create()
	{
		this.wx_move_base.create();
		this.m.ID = "actives.wx_poise_charge";
		this.m.Name = "沉刀蓄势";
		this.m.Description = "收刀聚劲。下次主动攻势命中 +15、伤害 +20%，命中或落空均消耗蓄势。单次受到至少 15 点气血伤害会被打断。";
		this.m.Icon = "skills/active_34.png";
		this.m.IconDisabled = "skills/active_34_sw.png";
		this.m.Overlay = "active_34";
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
		this.getContainer().add(::new("scripts/skills/effects/wx_status_poise_charge"));
		return true;
	}
});
