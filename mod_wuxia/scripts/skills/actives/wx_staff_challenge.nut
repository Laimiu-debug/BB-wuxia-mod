this.wx_staff_challenge <- this.inherit("scripts/skills/actives/taunt", {
	m = {
		UsedThisTurn = false
	},

	function create()
	{
		this.taunt.create();
		this.m.ID = "actives.wx_staff_challenge";
		this.m.WX_VfxBrush <- "wx_vfx_14";
		this.m.WX_AnimID <- "wx_anim_56";
		this.m.WX_AnimMode <- "taunt_slam";
		this.m.WX_ChoreoID <- "wx_staff_challenge";
		this.m.Name = "横杖叫阵";
		this.m.Description = "以棍杖叫阵，令敌人转攻自己。沿用嘲讽的目标限制，消耗 4 AP、15 内息（每回合限施展 1 次）。";
		this.m.Icon = "skills/wx_staff_challenge.png";
		this.m.IconDisabled = "skills/wx_staff_challenge_sw.png";
		this.m.Overlay = "wx_ov_wx_staff_challenge";
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

	function isUsable() { return !this.m.UsedThisTurn && !this.isHidden() && this.taunt.isUsable(); }
	function onTurnStart() { this.m.UsedThisTurn = false; }
	function onCombatStarted() { this.m.UsedThisTurn = false; }
	function onCombatFinished() { this.m.UsedThisTurn = false; }

	function onUse( _user, _targetTile )
	{
		if (_targetTile == null || !_targetTile.IsOccupiedByActor) return false;
		local target = _targetTile.getEntity();
		if (target == null || _user.isAlliedWith(target)) return false;
		this.m.UsedThisTurn = true;
		::Wuxia.VFX.playSkillVfx(this, _user, _targetTile, this.m.WX_VfxBrush);
		return this.taunt.onUse(_user, _targetTile);
	}
});
