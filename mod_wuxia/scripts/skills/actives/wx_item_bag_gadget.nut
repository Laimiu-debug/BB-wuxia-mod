// HUD-Safe Converged Active Skill for All Belt-Slot Tactical Gadgets (`奇门机括`)
// No matter how many `wx_gadget_*` items a brother carries in Bag slots, ONLY 1 active HUD icon is added!

this.wx_item_bag_gadget <- this.inherit("scripts/skills/skill", {
	m = {
		ActiveGadgetID = "wx_gadget_duanlong"
	},

	function create()
	{
		this.m.ID = "actives.wx_item_bag_gadget";
		this.m.Name = "奇门机括";
		this.m.Description = "催动随身腰包内的百工墨家/唐门战术器械破除大妖护体妖障、打断天灾蓄势或封锁走位。";
		this.m.Icon = "skills/wx_throw_duzhen.png";
		this.m.IconDisabled = "skills/wx_throw_duzhen_sw.png";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.UtilityTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = true;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.IsRanged = true;
		this.m.IsWeaponSkill = false;
		this.m.IsIgnoredAsAOO = true;
		this.m.ActionPointCost = 3;
		this.m.FatigueCost = 10;
		this.m.MinRange = 1;
		this.m.MaxRange = 4;
	}

	function resolveReadyGadget()
	{
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor == null || !("CraftBridge" in ::Wuxia)) return null;
		return ::Wuxia.CraftBridge.findActiveBagItem(actor, "gadget");
	}

	function syncWithBag( _actor = null )
	{
		local act = _actor;
		if (act == null && this.getContainer() != null)
			act = this.getContainer().getActor();
		if (act == null || !("CraftBridge" in ::Wuxia)) return;

		local gItem = ::Wuxia.CraftBridge.findActiveBagItem(act, "gadget");
		if (gItem == null) return;
		local cfg = gItem.getGadgetCfg();
		if (cfg == null) return;

		this.m.ActiveGadgetID  = cfg.ID;
		this.m.Name            = "机括：" + cfg.Name + "（×" + gItem.getCharges() + "）";
		this.m.Description     = cfg.Description;
		this.m.Icon            = cfg.SkillIcon;
		this.m.IconDisabled    = cfg.SkillIcon.slice(0, cfg.SkillIcon.len() - 4) + "_sw.png";
		this.m.ActionPointCost = cfg.APCost;
		this.m.FatigueCost     = cfg.QiCost;
		this.m.MinRange        = cfg.MinRange;
		this.m.MaxRange        = cfg.MaxRange;
		this.m.IsTargetingActor = cfg.TargetEnemy;
	}

	function onUpdate( _properties )
	{
		this.syncWithBag();
	}

	function isUsable()
	{
		if (!this.skill.isUsable()) return false;
		return this.resolveReadyGadget() != null;
	}

	function getTooltip()
	{
		this.syncWithBag();
		local ret = this.getDefaultUtilityTooltip();
		local gItem = this.resolveReadyGadget();
		if (gItem != null)
		{
			ret.push({
				id = 10,
				type = "text",
				icon = "ui/icons/special.png",
				text = "当前待发器械：[color=#0a4213]" + gItem.getName() + "[/color]（剩余充能 " + gItem.getCharges() + "）"
			});
		}
		return ret;
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		if (_originTile == null || _targetTile == null) return false;
		local dist = _originTile.getDistanceTo(_targetTile);
		if (dist < this.m.MinRange || dist > this.m.MaxRange) return false;

		local gItem = this.resolveReadyGadget();
		if (gItem == null) return false;
		local cfg = gItem.getGadgetCfg();
		if (cfg != null && cfg.TargetEnemy)
		{
			if (!_targetTile.IsOccupiedByActor || _targetTile.getEntity() == null) return false;
			local user = this.getContainer().getActor();
			if (user != null && user.isAlliedWith(_targetTile.getEntity())) return false;
		}
		return true;
	}

	function executeGadgetOnTile( _user, _targetTile )
	{
		local gItem = this.resolveReadyGadget();
		if (gItem == null || _user == null || _targetTile == null) return false;
		local gid = gItem.m.GadgetID;

		if (gid == "wx_gadget_duanlong")
		{
			local tgt = _targetTile.IsOccupiedByActor ? _targetTile.getEntity() : null;
			if (tgt == null || !tgt.isAlive()) return false;

			local rawDmg = ::Math.rand(18, 26);
			if (tgt.getHitpoints() > 1)
				tgt.setHitpoints(::Math.max(1, tgt.getHitpoints() - ::Math.round(rawDmg * 0.50).tointeger()));
			if (::Wuxia.hasMember(tgt, "getItems") && tgt.getItems() != null)
			{
				local bArm = tgt.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (bArm != null && ::Wuxia.hasMember(bArm, "getArmor") && bArm.getArmor() > 0)
					bArm.setArmor(::Math.max(0, bArm.getArmor() - rawDmg));
			}
			::Wuxia.CraftBridge.applyBossCounterHit(_user, tgt, {
				BreakPts      = 2,
				CorrodeShell  = 1,
				ExposeOpening = true
			});
		}
		else if (gid == "wx_gadget_tiejili")
		{
			local hitTiles = [_targetTile];
			if (::Wuxia.hasMember(_targetTile, "hasNextTile"))
			{
				for (local d = 0; d < 6; d = ++d)
				{
					if (_targetTile.hasNextTile(d))
						hitTiles.push(_targetTile.getNextTile(d));
				}
			}
			foreach (ht in hitTiles)
			{
				if (ht == null) continue;
				if ("Properties" in ht && ht.Properties != null)
				{
					ht.Properties.Effect = {
						Type       = "wx_caltrops",
						Timeout    = 2,
						IsPositive = false
					};
				}
				if ("IsOccupiedByActor" in ht && ht.IsOccupiedByActor && ht.getEntity() != null)
				{
					local victim = ht.getEntity();
					if (victim.isAlive() && !_user.isAlliedWith(victim))
					{
						if (::Wuxia.hasMember(victim, "getItems") && victim.getItems() != null)
						{
							local vArm = victim.getItems().getItemAtSlot(::Const.ItemSlot.Body);
							if (vArm != null && ::Wuxia.hasMember(vArm, "getArmor") && vArm.getArmor() > 0)
								vArm.setArmor(::Math.max(0, vArm.getArmor() - 15));
						}
						if (::Wuxia.hasMember(victim, "getSkills") && victim.getSkills() != null && !victim.getSkills().hasSkill("effects.wx_status_offbalance"))
							victim.getSkills().add(::new("scripts/skills/effects/wx_status_offbalance"));
					}
				}
			}
		}
		else if (gid == "wx_gadget_zimuxia")
		{
			local tgtZ = _targetTile.IsOccupiedByActor ? _targetTile.getEntity() : null;
			if (tgtZ == null || !tgtZ.isAlive()) return false;

			local needleDmg = ::Math.rand(14, 20);
			if (tgtZ.getHitpoints() > 1)
				tgtZ.setHitpoints(::Math.max(1, tgtZ.getHitpoints() - needleDmg));
			if (::Wuxia.hasMember(tgtZ, "getItems") && tgtZ.getItems() != null)
			{
				local zArm = tgtZ.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (zArm != null && ::Wuxia.hasMember(zArm, "getArmor") && zArm.getArmor() > 0)
					zArm.setArmor(::Math.max(0, zArm.getArmor() - 12));
			}
			local zSk = ::Wuxia.hasMember(tgtZ, "getSkills") ? tgtZ.getSkills() : null;
			if (zSk != null)
			{
				if (!::Wuxia.CombatRules.isImmuneToMeridianAndPoison(tgtZ) && !zSk.hasSkill("effects.wx_status_poison_dart"))
					zSk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
				if (!zSk.hasSkill("effects.wx_status_opening"))
					zSk.add(::new("scripts/skills/effects/wx_status_opening"));
				if (zSk.hasSkill("effects.wx_status_smoke_screen"))
					zSk.removeByID("effects.wx_status_smoke_screen");
			}
		}
		else if (gid == "wx_gadget_zhentianlei")
		{
			local leiTiles = [_targetTile];
			if (::Wuxia.hasMember(_targetTile, "hasNextTile"))
			{
				for (local dl = 0; dl < 6; dl = ++dl)
				{
					if (_targetTile.hasNextTile(dl))
						leiTiles.push(_targetTile.getNextTile(dl));
				}
			}
			foreach (lt in leiTiles)
			{
				if (lt == null) continue;
				if ("Properties" in lt && lt.Properties != null && ("Effect" in lt.Properties) && lt.Properties.Effect != null)
				{
					local etp = ("Type" in lt.Properties.Effect && lt.Properties.Effect.Type != null) ? lt.Properties.Effect.Type : "";
					if (etp == "web" || etp == "wx_caltrops" || etp.find("vine") != null)
						lt.Properties.Effect = null;
				}
				if ("IsOccupiedByActor" in lt && lt.IsOccupiedByActor && lt.getEntity() != null)
				{
					local vicL = lt.getEntity();
					if (vicL.isAlive() && !_user.isAlliedWith(vicL))
					{
						local armBlast = ::Math.rand(26, 36);
						if (::Wuxia.hasMember(vicL, "getItems") && vicL.getItems() != null)
						{
							local lBody = vicL.getItems().getItemAtSlot(::Const.ItemSlot.Body);
							if (lBody != null && ::Wuxia.hasMember(lBody, "getArmor") && lBody.getArmor() > 0)
								lBody.setArmor(::Math.max(0, lBody.getArmor() - armBlast));
							if (::Wuxia.hasMember(vicL, "isArmedWithShield") && vicL.isArmedWithShield())
							{
								local lShd = vicL.getItems().getItemAtSlot(::Const.ItemSlot.Offhand);
								if (lShd != null && ::Wuxia.hasMember(lShd, "applyShieldDamage"))
									lShd.applyShieldDamage(18);
							}
						}
						if (vicL.getHitpoints() > 1)
							vicL.setHitpoints(::Math.max(1, vicL.getHitpoints() - 10));
						::Wuxia.CraftBridge.applyBossCounterHit(_user, vicL, { BreakPts = 1 });
					}
				}
			}
		}
		else if (gid == "wx_gadget_zhangqiweng")
		{
			local wengTiles = [_targetTile];
			if (::Wuxia.hasMember(_targetTile, "hasNextTile"))
			{
				for (local dw = 0; dw < 6; dw = ++dw)
				{
					if (_targetTile.hasNextTile(dw))
						wengTiles.push(_targetTile.getNextTile(dw));
				}
			}
			foreach (wt in wengTiles)
			{
				if (wt == null) continue;
				if ("Properties" in wt && wt.Properties != null)
				{
					wt.Properties.Effect = { Type = "miasma", Timeout = 2, IsPositive = false };
				}
				if ("IsOccupiedByActor" in wt && wt.IsOccupiedByActor && wt.getEntity() != null)
				{
					local vicW = wt.getEntity();
					if (vicW.isAlive() && !_user.isAlliedWith(vicW))
					{
						local wSk = ::Wuxia.hasMember(vicW, "getSkills") ? vicW.getSkills() : null;
						if (wSk != null && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(vicW) && !wSk.hasSkill("effects.wx_status_poison_dart"))
							wSk.add(::new("scripts/skills/effects/wx_status_poison_dart"));
						::Wuxia.CraftBridge.applyBossCounterHit(_user, vicW, { SealRegenTurns = 2 });
					}
				}
			}
		}
		else if (gid == "wx_gadget_modouwang")
		{
			local tgtM = _targetTile.IsOccupiedByActor ? _targetTile.getEntity() : null;
			if (tgtM == null || !tgtM.isAlive()) return false;

			local mSk = ::Wuxia.hasMember(tgtM, "getSkills") ? tgtM.getSkills() : null;
			if (mSk != null)
			{
				if (!mSk.hasSkill("effects.wx_status_offbalance"))
					mSk.add(::new("scripts/skills/effects/wx_status_offbalance"));
				if (!mSk.hasSkill("effects.wx_status_opening"))
					mSk.add(::new("scripts/skills/effects/wx_status_opening"));
				local cpM = ::Wuxia.hasMember(tgtM, "getCurrentProperties") ? tgtM.getCurrentProperties() : null;
				local immRoot = (cpM != null && ("IsImmuneToRoot" in cpM) && cpM.IsImmuneToRoot);
				if (!immRoot && !mSk.hasSkill("effects.rooted"))
				{
					try { mSk.add(::new("scripts/skills/effects/rooted_effect")); } catch (_re) {}
				}
			}
			if (::Wuxia.CombatRules.isUndeadOrConstruct(tgtM))
			{
				if (tgtM.getHitpoints() > 1)
					tgtM.setHitpoints(::Math.max(1, tgtM.getHitpoints() - 22));
				if ("m" in tgtM && tgtM.m != null)
					tgtM.m.IsResurrectable = false;
			}
			::Wuxia.CraftBridge.applyBossCounterHit(_user, tgtM, { SealRegenTurns = 2, ExposeOpening = true });
		}

		gItem.consumeCharge();
		::Wuxia.CraftBridge.syncBagTacticalSkills(_user);
		return true;
	}

	function onUse( _user, _targetTile )
	{
		return this.executeGadgetOnTile(_user, _targetTile);
	}
});
