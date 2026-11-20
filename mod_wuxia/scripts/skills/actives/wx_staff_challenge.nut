this.wx_staff_challenge <- this.inherit("scripts/skills/actives/taunt", {
	function create()
	{
		this.taunt.create();
		this.m.ID = "actives.wx_staff_challenge";
		this.m.Name = "横杖叫阵";
		this.m.Description = "以棍杖叫阵，令敌人转攻自己。沿用嘲讽的目标限制，消耗 4 AP、15 内息。";
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 15;
	}

	function isHidden()
	{
		local skills = this.getContainer();
		if (skills == null) return true;
		local main = skills.getActor().getItems().getItemAtSlot(::Const.ItemSlot.Mainhand);
		return this.taunt.isHidden() || !::Wuxia.CombatRules.matchesWeapon(main, ["Staff"]);
	}

	function isUsable() { return !this.isHidden() && this.taunt.isUsable(); }
});
