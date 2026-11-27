// Shan Hai Boss Bespoke Active (`boss_zhuyin` #4): 息为风·太古移岳 (Unleashed after Even-Round Wind Inhale if Unbroken!)

this.wx_boss_zhuyin_primordial_wind <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown    = 0,
		WX_VfxBrush = "wx_vfx_26",
		WX_ChoreoID = "wx_boss_zhuyin_primordial_wind"
	},

	function create()
	{
		this.m.ID = "actives.wx_boss_zhuyin_primordial_wind";
		this.m.Name = "息为风·太古移岳";
		this.m.Description = "《海外北经》不息，息为风：烛九阴阖目蓄满太古朔风后呼啸而出，席卷周遭 4 格敌军将其震飞击退、抽散 14 内息并卷起裂风沙暴！";
		this.m.Icon = "skills/wx_tactics_kuiniu.png";
		this.m.IconDisabled = "skills/wx_tactics_kuiniu_sw.png";
		this.m.Overlay = "wx_ov_wx_tactics_kuiniu";
		this.m.SoundOnUse = ["sounds/combat/bash_02.wav"];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.IsAOE = true;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 15;
	}

	function isUsable()
	{
		if (this.m.Cooldown > 0 || !this.skill.isUsable()) return false;
		local cont = this.getContainer();
		if (cont == null) return false;
		local tr = cont.getSkillByID("special.wx_boss_trait_zhuyin");
		return tr != null && tr.m.WindCharged;
	}

	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }

	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		local cont = this.getContainer();
		local tr = cont != null ? cont.getSkillByID("special.wx_boss_trait_zhuyin") : null;
		if (tr != null) tr.m.WindCharged = false;

		if (!::Wuxia.isOnMap(_user)) return true;
		local myTile = _user.getTile();
		local allActors = ::Tactical.Entities.getAllInstancesAsArray();
		foreach (ent in allActors)
		{
			if (ent == null || !ent.isAlive() || !ent.isPlacedOnMap() || _user.isAlliedWith(ent)) continue;
			local eTile = ent.getTile();
			if (myTile.getDistanceTo(eTile) > 4) continue;
			::Wuxia.TileField.setField(eTile, "gale_sandstorm", 2, _user);
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(ent))
				::Wuxia.CombatRules.spendQi(ent, 14);
			local props = ent.getCurrentProperties();
			if (!props.IsImmuneToKnockBackAndGrab && !props.IsRooted)
			{
				local dir = myTile.getDirectionTo(eTile);
				if (eTile.hasNextTile(dir))
				{
					local dst = eTile.getNextTile(dir);
					if (dst.IsEmpty && !dst.IsOccupiedByActor && ::Math.abs(dst.Level - eTile.Level) <= 1)
						::Tactical.getNavigator().teleport(ent, dst, null, null, true);
				}
			}
		}
		if (::Tactical.EventLog != null)
			::Tactical.EventLog.log("[color=#d94b2b]【息为风·太古移岳】烛九阴一息吐出，万里罡风吹飞敌阵！[/color]");
		return true;
	}
});
