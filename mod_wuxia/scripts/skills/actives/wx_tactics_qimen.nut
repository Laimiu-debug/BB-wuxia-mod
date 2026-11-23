// Active Skill: 奇门遁甲雾
this.wx_tactics_qimen <- this.inherit("scripts/skills/skill", {
	m = { ActiveBuff = false, Cooldown = 0, WX_VfxBrush = "wx_vfx_25", WX_AnimID = "wx_anim_168", WX_AnimMode = "stance_qimen" },
	function create()
	{
		this.m.ID = "actives.wx_tactics_qimen";
		this.m.Name = "奇门遁甲雾";
		this.m.Description = "墨家唐门奇门秘术：消耗 4 AP 与 18 内息，于自身及周身 1 格布下奇门隐遁烟阵，清除友军破绽并获本回合远防 +20（冷却 3 回合）。";
		this.m.Icon = "skills/wx_tactics_qimen.png";
		this.m.IconDisabled = "skills/wx_tactics_qimen_sw.png";
		this.m.Overlay = "wx_ov_wx_tactics_qimen";
		this.m.WX_AnimID <- "wx_anim_168";
		this.m.WX_AnimMode <- "stance_qimen";
		this.m.WX_ChoreoID <- "wx_tactics_qimen";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 18;
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function isUsable()
	{
		if (this.m.Cooldown > 0 || this.m.ActiveBuff || !this.skill.isUsable()) return false;
		return true;
	}
	function onUpdate( _properties )
	{
		if (this.m.ActiveBuff)
		{
			_properties.RangedDefense += 20; _properties.MeleeDefense += 8;
		}
	}
	function onTurnStart() { this.m.ActiveBuff = false; if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.ActiveBuff = false; this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.ActiveBuff = false; this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		this.m.ActiveBuff = true;
		this.m.Cooldown = 3;
		::Wuxia.VFX.playSkillVfx(this, _user, _user.getTile(), this.m.WX_VfxBrush);
		local myT = _user.getTile(); local usk = _user.getSkills(); if (usk != null) usk.removeByID("effects.wx_status_opening"); for (local d = 0; d < ::Const.Direction.COUNT; d = ++d) { if (!myT.hasNextTile(d)) continue; local nt = myT.getNextTile(d); if (nt.IsOccupiedByActor && _user.isAlliedWith(nt.getEntity())) { local ask = nt.getEntity().getSkills(); if (ask != null) ask.removeByID("effects.wx_status_opening"); } }
		this.getContainer().update();
		return true;
	}
});
