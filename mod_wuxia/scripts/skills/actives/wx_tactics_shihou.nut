// Active Skill: 金刚狮子吼 (2-tile AoE Sonic Morale Shock, 5 AP, 28 Qi, 2-turn cooldown)
this.wx_tactics_shihou <- this.inherit("scripts/skills/skill", {
	m = { Cooldown = 0, WX_VfxBrush = "wx_vfx_23", WX_AnimID = "wx_anim_35", WX_AnimMode = "lion_roar" },
	function create()
	{
		this.m.ID = "actives.wx_tactics_shihou";
		this.m.Name = "金刚狮子吼";
		this.m.Description = "禅门无上音功：消耗 5 AP 与 28 内息，吐气发声如晴空霹雳，令周身 2 格内全体敌军承受战意动摇检定并陷入失衡（冷却 2 回合）。";
		this.m.Icon = "skills/wx_tactics_shihou.png";
		this.m.IconDisabled = "skills/wx_tactics_shihou_sw.png";
		this.m.Overlay = "wx_ov_wx_tactics_shihou";
		this.m.WX_AnimID <- "wx_anim_35";
		this.m.WX_AnimMode <- "lion_roar";
		this.m.WX_ChoreoID <- "wx_tactics_shihou";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.ActionPointCost = 5;
		this.m.FatigueCost = 28;
	}
	function getTooltip() { return this.getDefaultUtilityTooltip(); }
	function isUsable() { return this.m.Cooldown <= 0 && this.skill.isUsable(); }
	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }
	function onCombatFinished() { this.m.Cooldown = 0; }
	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		local myTile = _user.getTile();
		::Wuxia.VFX.playSkillVfx(this, _user, myTile, this.m.WX_VfxBrush);
		if (myTile != null && ("TileField" in ::Wuxia))
			::Wuxia.TileField.dispelFieldsInRadius(myTile, 3, ["mirage_mist"]);
		local pen = -8 - ::Math.floor(_user.getBravery() * 0.12);
		foreach (ent in ::Tactical.Entities.getAllInstancesAsArray())
		{
			if (ent == null || !ent.isAlive() || !ent.isPlacedOnMap() || _user.isAlliedWith(ent)) continue;
			if (myTile.getDistanceTo(ent.getTile()) <= 2)
			{
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(ent)) ent.checkMorale(-1, pen);
				local sk = ent.getSkills();
				if (sk != null && !sk.hasSkill("effects.wx_status_offbalance"))
					sk.add(::new("scripts/skills/effects/wx_status_offbalance"));
			}
		}
		return true;
	}
});
