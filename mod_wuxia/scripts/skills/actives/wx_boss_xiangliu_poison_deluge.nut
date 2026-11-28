// Shan Hai Boss Bespoke Active (`boss_xiangliuwang` #3): 禹厥三沮·苦泉漫灌 (Global Mire Eruption — Locked when `苦毒瘴首` is Severed!)

this.wx_boss_xiangliu_poison_deluge <- this.inherit("scripts/skills/skill", {
	m = {
		Cooldown    = 0,
		WX_VfxBrush = "wx_vfx_28",
		WX_ChoreoID = "wx_boss_xiangliu_poison_deluge"
	},

	function create()
	{
		this.m.ID = "actives.wx_boss_xiangliu_poison_deluge";
		this.m.Name = "禹厥三沮·苦泉漫灌";
		this.m.Description = "《海外北经》禹厥之，三仞三沮：催动【苦毒瘴首】引爆全场所有【苦毒腐泽】喷发腥臭毒泉，对平地泥沼中的敌军造成 16 蚀甲、14 实伤并染奇毒（登上高台『众帝之台』或斩断『苦毒瘴首』可破此招！）。";
		this.m.Icon = "skills/wx_neigong_wudu.png";
		this.m.IconDisabled = "skills/wx_neigong_wudu_sw.png";
		this.m.Overlay = "wx_ov_wx_neigong_wudu";
		this.m.SoundOnUse = ["sounds/combat/bash_01.wav"];
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.NonTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsAttack = false;
		this.m.IsAOE = true;
		this.m.ActionPointCost = 4;
		this.m.FatigueCost = 16;
	}

	function isUsable()
	{
		if (this.m.Cooldown > 0 || !this.skill.isUsable()) return false;
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor != null && ::Wuxia.ShanHaiMultiBody.isSkillLocked(actor, this.m.ID))
			return false;
		return true;
	}

	function onTurnStart() { if (this.m.Cooldown > 0) this.m.Cooldown -= 1; }
	function onCombatStarted() { this.m.Cooldown = 0; }

	function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 3;
		local mires = ::Wuxia.TileField.getFieldsByKind("bitter_mire");
		// Seed 2 adjacent mires if battlefield is currently dry
		if (mires.len() == 0 && ::Wuxia.isOnMap(_user))
		{
			local uTile = _user.getTile();
			local seeded = 0;
			for (local d = 0; d < 6 && seeded < 2; d = ++d)
			{
				if (!uTile.hasNextTile(d)) continue;
				local nt = uTile.getNextTile(d);
				::Wuxia.TileField.setField(nt, "bitter_mire", 4, _user);
				seeded += 1;
			}
			mires = ::Wuxia.TileField.getFieldsByKind("bitter_mire");
		}

		local uLevel = ::Wuxia.isOnMap(_user) ? _user.getTile().Level : 0;
		foreach (f in mires)
		{
			local t = f.TileRef;
			if (t == null) continue;
			::Wuxia.TileField.renderFieldVisual(t, "bitter_mire", 0);
			if (!::Wuxia.isTileOccupiedByActor(t)) continue;
			local ent = t.getEntity();
			if (ent == null || !ent.isAlive() || _user.isAlliedWith(ent)) continue;
			// High ground ("众帝之台") avoids low-ground poison flood!
			if (t.Level > uLevel) continue;

			if (ent.getItems() != null)
			{
				local bArm = ent.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (bArm != null && bArm.getArmor() > 0)
					bArm.setArmor(::Math.max(0, bArm.getArmor() - 16));
			}
			if (ent.getHitpoints() > 15) ent.setHitpoints(ent.getHitpoints() - 14);
			else ent.setHitpoints(1);
			if (ent.getSkills() != null && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(ent) && !ent.getSkills().hasSkill("effects.wx_status_poison_dart"))
				ent.getSkills().add(::new("scripts/skills/effects/wx_status_poison_dart"));
		}

		if (::Wuxia.TileField.isLiveTactical() && ::Tactical.EventLog != null)
			::Tactical.EventLog.log("[color=#2b8a3e]【禹厥三沮·苦泉漫灌】苦毒腐泽齐齐喷涌腥泉，侵蚀低洼阵线！[/color]");
		return true;
	}
});
