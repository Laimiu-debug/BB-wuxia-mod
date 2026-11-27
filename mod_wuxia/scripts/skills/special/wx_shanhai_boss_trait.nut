// Composable Tactical Mechanics & Brain-Teasing Puzzle Engine for All 64 Shan Hai Jing Mythical Apex Bosses
// Combines bespoke per-boss stats/auras with:
//   1. Five Mythic Puzzle Phases (`yinyang` 两仪昼夜 / `bastion` 太古玄甲 / `devour` 饕餮血祭 / `hexmark` 凶妖锁魂 / `berserk` 狂战沸血)
//   2. Telegraphed Cataclysm Charge (`凶煞蓄势`) + Player Stagger-Break Counterplay (`破招反噬`)!

this.wx_shanhai_boss_trait <- this.inherit("scripts/skills/skill", {
	m = {
		BossID          = "zhuyan",
		PuzzleType      = "berserk",
		KillAPUsed      = false,
		ReviveUsed      = false,
		HalfHpShellUsed = false,
		HalfHpCharge    = false,
		RoundNum        = 0,
		ShellStacks     = 0,
		ShellBrokenLeft = 0,
		IsCharging      = false,
		BreakThreshold  = 3,
		BreakProgress   = 0,
		CataclysmReady  = false,
		BacklashLeft    = 0,
		BloodPactActive = false,
		HexTargetID     = -1
	},

	function create()
	{
		this.m.ID = "special.wx_shanhai_boss_trait";
		this.m.Name = "山海凶威";
		this.m.Description = "《山海经》上古异兽与生俱来的凶煞异禀。";
		this.m.Icon = "ui/perks/wx_shanhai_boss_trait.png";
		this.m.Type = this.Const.SkillType.Special | this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.Trait;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsHidden = false;
		this.m.IsSerialized = false;
	}

	function getMechanics()
	{
		local fullKey = "boss_" + this.m.BossID;
		if ("ShanHaiBosses" in ::Wuxia.Config)
		{
			if (fullKey in ::Wuxia.Config.ShanHaiBosses)
				return ::Wuxia.Config.ShanHaiBosses[fullKey].Mechanics;
			if (this.m.BossID in ::Wuxia.Config.ShanHaiBosses)
				return ::Wuxia.Config.ShanHaiBosses[this.m.BossID].Mechanics;
		}
		return {};
	}

	function resolvePuzzleArchetype( _bossID, _mech )
	{
		if ("CycleMode" in _mech || _bossID == "zhuyin" || _bossID == "yinglong" || _bossID == "bingyi" || _bossID == "jiufeng"
			|| _bossID == "dijiang" || _bossID == "jimeng" || _bossID == "jinwu" || _bossID == "烛九阴")
			return "yinyang";

		if (_bossID == "zhuyan" || ("EnrageBelowPct" in _mech && !("HammerWeakOnly" in _mech)))
			return "berserk";

		if ("VsShaken" in _mech || "OnHitScatter" in _mech || "AuraResolveOffbalance" in _mech
			|| _bossID == "jiuwei" || _bossID == "baize" || _bossID == "bifang" || _bossID == "gudiao"
			|| _bossID == "qinyuan" || _bossID == "feilian" || _bossID == "tiangou" || _bossID == "mingshe")
			return "hexmark";

		if (("HammerWeakOnly" in _mech && _mech.HammerWeakOnly) || ("RegularMult" in _mech && _mech.RegularMult <= 0.78)
			|| _bossID == "xuangui" || _bossID == "bo" || _bossID == "chiyou" || _bossID == "xingtian"
			|| _bossID == "luwu" || _bossID == "kaiming" || _bossID == "kuafu" || _bossID == "dangkang")
			return "bastion";

		if ("RegenHP" in _mech || "OnHitDrainHP" in _mech || "OnHitBleed" in _mech
			|| _bossID == "taotie" || _bossID == "xiangliu" || _bossID == "jiuying" || _bossID == "qiongqi"
			|| _bossID == "taowu" || _bossID == "bashe" || _bossID == "paoxiao")
			return "devour";

		return "berserk";
	}

	function getPuzzleHintText()
	{
		local pt = this.m.PuzzleType;
		if (pt == "yinyang")
			return "【两仪昼夜相】奇数轮『昼阳护体』反震贴身近战，宜用弓弩长兵远攻（受伤+20%）；偶数轮『玄冥吞矢』吸收远箭回血，宜贴身近战强攻（受伤+25%）！";
		if (pt == "bastion")
			return "【太古玄甲相】凝有 3 层玄壳减伤 45%；唯『重锤/棍杖/拳掌寸劲/破盾巨斧』每次可震碎 2 层玄壳，尽碎后陷入 2 回合『玄壳崩裂（近防-18·受穿甲+20%）』！";
		if (pt == "devour")
			return "【饕餮血祭相】每 2 轮凝起血祭图谋吞血大愈；趁血祭期间对其施以『奇毒』或『点穴封脉』，可令其下轮血祭反噬倒扣气血并染内伤！";
		if (pt == "hexmark")
			return "【凶妖锁魂相】点名侠客种下锁魂印；下轮初若被点名者周围不足 2 名同袍护法将遭噬魂重创，若有 ≥2 名同袍紧贴结阵则震碎妖印反噬大妖！";
		return "【荒神沸血相】越战越勇，每 3 轮及半血时开启『凶煞蓄势』图谋毁天灭地；当轮以『点穴/失衡/重锤拳掌』累计达 3 点破招值即可打断并令其反噬虚弱！";
	}

	function setBossID( _bossID )
	{
		this.m.BossID = _bossID;
		this.m.Icon = "ui/perks/wx_boss_trait_" + _bossID + ".png";
		this.m.IconDisabled = "ui/perks/wx_boss_trait_" + _bossID + "_sw.png";
		local fullKey = "boss_" + _bossID;
		local mech = this.getMechanics();
		this.m.PuzzleType = this.resolvePuzzleArchetype(_bossID, mech);
		if (this.m.PuzzleType == "bastion")
			this.m.ShellStacks = 3;
		if ("ShanHaiBosses" in ::Wuxia.Config && (fullKey in ::Wuxia.Config.ShanHaiBosses))
		{
			local cfg = ::Wuxia.Config.ShanHaiBosses[fullKey];
			this.m.Name = cfg.TraitName;
			this.m.Description = cfg.TraitDesc + "\n\n" + this.getPuzzleHintText();
		}
	}

	function getTooltip()
	{
		local ret = [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() }
		];
		if (this.m.IsCharging)
		{
			local rem = ::Math.max(0, 3 - this.m.BreakProgress);
			ret.push({
				id = 10, type = "text", icon = "ui/icons/warning.png",
				text = "[color=" + ::Const.UI.Color.NegativeValue + "]【凶煞蓄势中！】[/color]下回合将释放『荒神天灾』！本轮还需 [color=" + ::Const.UI.Color.PositiveValue + "]" + rem + "[/color] 点破招值（重锤/拳掌/点穴计 2 点，普攻计 1 点）即可打断反噬！"
			});
		}
		if (this.m.BacklashLeft > 0)
		{
			ret.push({
				id = 11, type = "text", icon = "ui/icons/melee_defense.png",
				text = "[color=" + ::Const.UI.Color.PositiveValue + "]【破招反噬·大破绽】[/color]真气逆行，近防/远防 -18，造成伤害 -25%！"
			});
		}
		if (this.m.PuzzleType == "yinyang" && this.m.RoundNum > 0)
		{
			local isOdd = (this.m.RoundNum % 2) == 1;
			ret.push({
				id = 12, type = "text", icon = "ui/icons/special.png",
				text = isOdd
					? "当前相位：【昼阳相】（贴身近战受反震，宜远程/两格长兵攻击 +20% 伤）"
					: "当前相位：【夜阴相】（远程箭矢被吞噬回血，宜贴身近战围攻 +25% 伤）"
			});
		}
		if (this.m.PuzzleType == "bastion")
		{
			if (this.m.ShellStacks > 0)
				ret.push({ id = 13, type = "text", icon = "ui/icons/armor_body.png", text = "【太古玄壳】剩余层数：[color=" + ::Const.UI.Color.NegativeValue + "]" + this.m.ShellStacks + "[/color]（以锤/杖/拳掌/破盾斧击碎）" });
			else if (this.m.ShellBrokenLeft > 0)
				ret.push({ id = 13, type = "text", icon = "ui/icons/direct_damage.png", text = "[color=" + ::Const.UI.Color.PositiveValue + "]【玄壳崩裂】[/color]近防 -18，受穿甲伤害 +20%（余 " + this.m.ShellBrokenLeft + " 回合）" });
		}
		if (this.m.BloodPactActive)
		{
			ret.push({
				id = 14, type = "text", icon = "ui/icons/health.png",
				text = "【凶饕血祭】已凝起：速施『奇毒』或『点穴封脉』污染血祭令其下轮反噬！"
			});
		}
		return ret;
	}

	function applyDebuffSafe( _targetSkills, _effectID, _scriptPath )
	{
		if (_targetSkills == null) return;
		local ex = _targetSkills.getSkillByID(_effectID);
		if (ex == null) _targetSkills.add(::new(_scriptPath));
		else if ("resetDuration" in ex) ex.resetDuration();
	}

	function triggerChargeBreak( _actor )
	{
		this.m.IsCharging = false;
		this.m.BreakProgress = 0;
		this.m.CataclysmReady = false;
		this.m.BacklashLeft = 1;
		if (_actor == null || !_actor.isAlive()) return;

		local recoil = ::Math.max(15, ::Math.round(_actor.getHitpointsMax() * 0.07));
		if (_actor.getHitpoints() > recoil + 1)
			_actor.setHitpoints(_actor.getHitpoints() - recoil);
		local sk = _actor.getSkills();
		if (sk != null)
		{
			this.applyDebuffSafe(sk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			this.applyDebuffSafe(sk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		if ("VFX" in ::Wuxia)
			::Wuxia.VFX.playTriggerVfx(_actor, "wx_vfx_16", "wx_fx_bagua", -20, 160, 1.35);
		if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
			::Tactical.EventLog.log("【破招成功！】众侠精准击破凶煞气门，" + ::Const.UI.getColorizedEntityName(_actor) + " 遭真气反噬（损血 " + recoil + "）露出大破绽！");
	}

	function onTurnStart()
	{
		this.m.KillAPUsed = false;
		this.m.RoundNum += 1;
		if (this.m.BacklashLeft > 0) this.m.BacklashLeft -= 1;
		if (this.m.ShellBrokenLeft > 0) this.m.ShellBrokenLeft -= 1;

		local container = this.getContainer();
		local actor = container == null ? null : container.getActor();
		if (actor == null || !actor.isAlive()) return;

		local mech = this.getMechanics();
		local hasTac = ("Tactical" in getroottable()) && ::Tactical != null && ::Tactical.isActive() && actor.isPlacedOnMap();

		// Resolve un-broken Cataclysm Charge from previous round!
		if (this.m.IsCharging)
		{
			this.m.IsCharging = false;
			this.m.BreakProgress = 0;
			this.m.CataclysmReady = true;
			if (hasTac && "EventLog" in ::Tactical && ::Tactical.EventLog != null)
				::Tactical.EventLog.log("【凶威降临】" + ::Const.UI.getColorizedEntityName(actor) + " 蓄势已满，即将倾泻荒神天灾！");
		}
		else if (hasTac && (this.m.RoundNum % 3) == 2)
		{
			this.m.IsCharging = true;
			this.m.BreakProgress = 0;
			if ("VFX" in ::Wuxia)
				::Wuxia.VFX.playTriggerVfx(actor, "wx_vfx_20", "wx_fx_sonic_ring", -24, 120, 1.32);
			if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
				::Tactical.EventLog.log("【凶威预警】" + ::Const.UI.getColorizedEntityName(actor) + " 周身凶煞暴涨正在蓄力天灾！本轮内以『重锤/拳掌/点穴』破招打断可令其反噬！");
		}

		// Resolve Devour Blood Pact Puzzle (`devour`)
		if (this.m.PuzzleType == "devour")
		{
			if (this.m.BloodPactActive)
			{
				this.m.BloodPactActive = false;
				local corrupted = container.hasSkill("effects.wx_status_poison_dart") || container.hasSkill("effects.wx_status_acupoint")
					|| container.hasSkill("effects.spider_poison") || container.hasSkill("effects.goblin_poison");
				local deltaHP = ::Math.max(18, ::Math.round(actor.getHitpointsMax() * 0.07));
				if (corrupted)
				{
					if (actor.getHitpoints() > deltaHP + 1)
						actor.setHitpoints(actor.getHitpoints() - deltaHP);
					this.applyDebuffSafe(container, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
					if (hasTac && "EventLog" in ::Tactical && ::Tactical.EventLog != null)
						::Tactical.EventLog.log("【毒封破血祭！】" + ::Const.UI.getColorizedEntityName(actor) + " 吞入奇毒封脉浊血，反噬损血 " + deltaHP + " 点！");
				}
				else if (actor.getHitpoints() < actor.getHitpointsMax())
				{
					actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + deltaHP));
					if (hasTac && "EventLog" in ::Tactical && ::Tactical.EventLog != null)
						::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(actor) + " 血祭大成，吞吸精血恢复 " + deltaHP + " 点生机！");
				}
			}
			else if ((this.m.RoundNum % 2) == 1)
			{
				this.m.BloodPactActive = true;
				if (hasTac && "EventLog" in ::Tactical && ::Tactical.EventLog != null)
					::Tactical.EventLog.log("【血祭预警】" + ::Const.UI.getColorizedEntityName(actor) + " 凝起凶饕血祭（速施奇毒或点穴封脉可令其反噬）！");
			}
		}

		// Resolve Hex Mark Formation Puzzle (`hexmark`)
		if (this.m.PuzzleType == "hexmark" && hasTac)
		{
			local allUnits = ::Tactical.Entities.getAllInstancesAsArray();
			if (this.m.HexTargetID != -1)
			{
				local victim = null;
				foreach (u in allUnits)
				{
					if (u != null && u.isAlive() && ::Wuxia.isOnMap(u) && u.getID() == this.m.HexTargetID)
					{
						victim = u;
						break;
					}
				}
				this.m.HexTargetID = -1;
				if (victim != null)
				{
					local vTile = victim.getTile();
					local guardCnt = 0;
					for (local d = 0; d < 6; d = ++d)
					{
						if (!vTile.hasNextTile(d)) continue;
						local adjT = vTile.getNextTile(d);
						if (adjT.IsOccupiedByActor && adjT.getEntity() != null && adjT.getEntity().isAlive() && victim.isAlliedWith(adjT.getEntity()))
							guardCnt += 1;
					}
					if (guardCnt >= 2)
					{
						this.m.BacklashLeft = 1;
						this.applyDebuffSafe(container, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
						if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(vTile, "wx_vfx_18", "wx_fx_bagua", 0, 90, 1.15);
						if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
							::Tactical.EventLog.log("【结阵破妖印！】众同袍紧贴护法震碎锁魂印，妖力倒卷反噬 " + ::Const.UI.getColorizedEntityName(actor) + "！");
					}
					else
					{
						if (victim.getHitpoints() > 23) victim.setHitpoints(victim.getHitpoints() - 22);
						if (!::Wuxia.CombatRules.isUndeadOrConstruct(victim)) ::Wuxia.CombatRules.spendQi(victim, 16);
						this.applyDebuffSafe(victim.getSkills(), "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
						if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(vTile, "wx_vfx_30", null, -18, 0, 1.20);
						if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
							::Tactical.EventLog.log("【锁魂噬体】" + ::Const.UI.getColorizedEntityName(victim) + " 孤身无援遭妖印发作重创！");
					}
				}
			}
			else if ((this.m.RoundNum % 2) == 1)
			{
				local cands = [];
				foreach (u2 in allUnits)
				{
					if (u2 != null && u2.isAlive() && ::Wuxia.isOnMap(u2) && !actor.isAlliedWith(u2) && actor.getTile().getDistanceTo(u2.getTile()) <= 5)
						cands.push(u2);
				}
				if (cands.len() > 0)
				{
					local pick = cands[::Math.rand(0, cands.len() - 1)];
					this.m.HexTargetID = pick.getID();
					if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(pick, "wx_vfx_30", "wx_fx_lotus_seal", -16, 80, 1.15);
					if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
						::Tactical.EventLog.log("【锁魂预警】" + ::Const.UI.getColorizedEntityName(actor) + " 将凶妖锁魂印种在 " + ::Const.UI.getColorizedEntityName(pick) + " 身上（速派 2 名同袍贴身结阵可破印反噬）！");
				}
			}
		}

		// 1. Vitality Regeneration
		if ("RegenHP" in mech && mech.RegenHP > 0 && actor.getHitpoints() < actor.getHitpointsMax())
		{
			local heal = mech.RegenHP;
			if ("PoisonCutsRegen" in mech)
			{
				local poisoned = container.hasSkill("effects.wx_status_poison_dart") || container.hasSkill("effects.spider_poison") || container.hasSkill("effects.goblin_poison") || container.hasSkill("effects.bleeding");
				if (poisoned) heal = mech.PoisonCutsRegen;
			}
			actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + heal));
		}

		// 2. Tactical Domain Auras & Odd/Even Cycles
		if (("AuraRadius" in mech) && hasTac)
		{
			local rad = mech.AuraRadius;
			local armorDmg = ("AuraArmorDmg" in mech) ? mech.AuraArmorDmg : 0;
			local fatAdd = ("AuraFatigue" in mech) ? mech.AuraFatigue : 0;
			local hpDmg = ("AuraHpDmg" in mech) ? mech.AuraHpDmg : 0;
			local addPoison = ("AuraPoison" in mech) ? mech.AuraPoison : false;
			local resolveCheck = ("AuraResolveOffbalance" in mech) ? mech.AuraResolveOffbalance : false;

			if ("CycleMode" in mech)
			{
				local isOdd = (this.m.RoundNum % 2) == 1;
				if (mech.CycleMode == "zhuyin")
				{
					if (isOdd) { fatAdd = 12; resolveCheck = true; }
				}
				else if (mech.CycleMode == "jiuying")
				{
					if (isOdd) { hpDmg = 8; addPoison = true; }
					else { armorDmg = 16; }
				}
			}

			local myTile = actor.getTile();
			if ("VFX" in ::Wuxia)
			{
				local bossAura = armorDmg > 0 ? "wx_vfx_02" : (addPoison ? "wx_vfx_28" : (hpDmg > 0 ? "wx_vfx_21" : (resolveCheck ? "wx_vfx_30" : "wx_vfx_19")));
				::Wuxia.VFX.playTriggerVfx(myTile, bossAura, null, -25, 80, 1.24);
			}
			local allEntities = ::Tactical.Entities.getAllInstancesAsArray();
			foreach (ent in allEntities)
			{
				if (ent == null || !ent.isAlive() || !ent.isPlacedOnMap() || actor.isAlliedWith(ent)) continue;
				if (myTile.getDistanceTo(ent.getTile()) > rad) continue;

				local entSk = (::Wuxia.hasMember(ent, "getSkills")) ? ent.getSkills() : null;
				local entBuff = entSk != null ? entSk.getSkillByID("effects.wx_pill_battle_buff") : null;
				local hasBihuo = (entBuff != null && (::Wuxia.hasMember(entBuff.m, "HasBihuo")) && entBuff.m.HasBihuo)
					|| (("BeastCraft" in ::Wuxia) && ::Wuxia.BeastCraft.hasAuraWard(ent));

				if (!hasBihuo && armorDmg > 0 && (::Wuxia.hasMember(ent, "getItems")) && ent.getItems() != null)
				{
					local body = ent.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (body != null && body.getArmor() > 0)
						body.setArmor(::Math.max(0, body.getArmor() - armorDmg));
				}
				if (!hasBihuo && fatAdd > 0 && !::Wuxia.CombatRules.isUndeadOrConstruct(ent) && (::Wuxia.hasMember(ent, "getFatigue")))
					ent.setFatigue(::Math.min(ent.getFatigueMax(), ent.getFatigue() + fatAdd));
				if (!hasBihuo && hpDmg > 0 && ent.getHitpoints() > hpDmg + 1)
					ent.setHitpoints(ent.getHitpoints() - hpDmg);
				if (addPoison && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(ent) && (::Wuxia.hasMember(ent, "getSkills")))
					this.applyDebuffSafe(ent.getSkills(), "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
				if (resolveCheck && (::Wuxia.hasMember(ent, "getCurrentProperties")) && (::Wuxia.hasMember(ent, "getSkills")))
				{
					if (::Math.rand(1, 100) > ent.getCurrentProperties().Bravery)
						this.applyDebuffSafe(ent.getSkills(), "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
				}
			}
		}
	}

	function onUpdate( _properties )
	{
		local container = this.getContainer();
		local actor = container == null ? null : container.getActor();
		local mech = this.getMechanics();

		if ("MinAP" in mech && _properties.ActionPoints < mech.MinAP)
			_properties.ActionPoints = mech.MinAP;
		if ("BonusInit" in mech) _properties.Initiative += mech.BonusInit;
		if ("BonusMSkill" in mech) _properties.MeleeSkill += mech.BonusMSkill;
		if ("BonusMDef" in mech) _properties.MeleeDefense += mech.BonusMDef;
		if ("BonusRDef" in mech) _properties.RangedDefense += mech.BonusRDef;
		if ("BonusBravery" in mech) _properties.Bravery += mech.BonusBravery;
		if ("RangedMult" in mech) _properties.DamageReceivedRangedMult *= mech.RangedMult;
		if ("RegularMult" in mech) _properties.DamageReceivedRegularMult *= mech.RegularMult;
		if ("ImmuneStun" in mech && mech.ImmuneStun) _properties.IsImmuneToStun = true;
		if ("ImmuneDisarm" in mech && mech.ImmuneDisarm) _properties.IsImmuneToDisarm = true;

		if ("CycleMode" in mech && mech.CycleMode == "zhuyin" && (this.m.RoundNum % 2) == 0 && this.m.RoundNum > 0)
		{
			_properties.MeleeSkill += 18;
			_properties.DamageTotalMult *= 1.25;
		}

		if (this.m.PuzzleType == "yinyang" && (this.m.RoundNum % 2) == 1)
		{
			_properties.RangedDefense -= 15;
		}
		if (this.m.ShellBrokenLeft > 0)
		{
			_properties.MeleeDefense -= 18;
		}
		if (this.m.BacklashLeft > 0)
		{
			_properties.MeleeDefense -= 18;
			_properties.RangedDefense -= 18;
			_properties.DamageTotalMult *= 0.75;
		}

		if ("EnrageBelowPct" in mech && actor != null && actor.getHitpointsMax() > 0)
		{
			local ratio = actor.getHitpoints().tofloat() / actor.getHitpointsMax().tofloat();
			if (ratio < mech.EnrageBelowPct)
			{
				if ("EnrageMSkill" in mech) _properties.MeleeSkill += mech.EnrageMSkill;
				if ("EnrageDmgMult" in mech) _properties.DamageTotalMult *= mech.EnrageDmgMult;
				if ("EnrageImmuneCC" in mech && mech.EnrageImmuneCC)
				{
					_properties.IsImmuneToStun = true;
					_properties.IsImmuneToDisarm = true;
				}
			}
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == null || !_skill.isAttack() || _targetEntity == null || !(::Wuxia.hasMember(_targetEntity, "getCurrentProperties"))) return;
		local mech = this.getMechanics();
		local tBravery = _targetEntity.getCurrentProperties().Bravery;

		if ("VsHighResolve" in mech && mech.VsHighResolve && tBravery >= 65)
		{
			_properties.MeleeSkill += 12;
			_properties.DamageTotalMult *= 1.15;
		}
		if ("VsShaken" in mech && mech.VsShaken && tBravery < 55)
		{
			_properties.MeleeSkill += 15;
			_properties.DamageTotalMult *= 1.25;
		}
	}

	function onBeforeDamageReceived( _attacker, _skill, _hitInfo, _properties )
	{
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor == null) return;
		local mech = this.getMechanics();

		local mainW = (_attacker != null && ::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
			? _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand) : null;
		local isHeavyBreaker = (mainW != null && ::Wuxia.CombatRules.matchesWeapon(mainW, ["Hammer", "Staff", "Fist"]))
			|| (_skill != null && (_skill.getID().find("split") != null || _skill.getID().find("kaishan") != null || _skill.getID().find("poche") != null));

		// 1. Telegraphed Charge Stagger-Break Check!
		if (this.m.IsCharging && _attacker != null && _attacker.getID() != actor.getID() && _skill != null && _skill.isAttack())
		{
			local pts = isHeavyBreaker ? 2 : 1;
			if (_skill.getID().find("acupoint") != null || _skill.getID().find("fuxue") != null || _skill.getID().find("yiyang") != null)
				pts = 2;
			this.m.BreakProgress += pts;
			if (this.m.BreakProgress >= 3)
				this.triggerChargeBreak(actor);
		}

		// 2. Bastion Shell Puzzle (`bastion`)
		if (this.m.PuzzleType == "bastion")
		{
			if (this.m.ShellStacks > 0)
			{
				if (isHeavyBreaker)
				{
					this.m.ShellStacks = ::Math.max(0, this.m.ShellStacks - 2);
					if (this.m.ShellStacks == 0)
					{
						this.m.ShellBrokenLeft = 2;
						local crackLoss = ::Math.max(14, ::Math.round(actor.getHitpointsMax() * 0.06));
						if (actor.getHitpoints() > crackLoss + 1)
							actor.setHitpoints(actor.getHitpoints() - crackLoss);
						if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(actor, "wx_vfx_14", "wx_fx_earth_fissure", 0, 0, 1.30);
						if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
							::Tactical.EventLog.log("【玄壳崩裂！】" + ::Const.UI.getColorizedEntityName(actor) + " 的太古玄甲被刚猛重击彻底震碎，弱点尽露！");
					}
				}
				else
				{
					_properties.DamageReceivedTotalMult *= 0.55;
				}
			}
			else if (this.m.ShellBrokenLeft > 0)
			{
				_properties.DamageReceivedDirectMult *= 1.20;
			}
		}

		// 3. Yin-Yang Dual Phase Puzzle (`yinyang`)
		if (this.m.PuzzleType == "yinyang" && _attacker != null && _attacker.getID() != actor.getID() && _skill != null && this.m.RoundNum > 0)
		{
			local isOdd = (this.m.RoundNum % 2) == 1;
			local dist = (::Wuxia.isOnMap(actor) && ::Wuxia.isOnMap(_attacker)) ? actor.getTile().getDistanceTo(_attacker.getTile()) : 1;
			if (isOdd)
			{
				// Day/Yang Phase: rewards ranged & 2-tile polearms (+20% dmg); punishes adjacent 1-tile melee!
				if (_skill.isRanged() || dist >= 2)
				{
					_properties.DamageReceivedTotalMult *= 1.20;
				}
				else if (_attacker.isAlive() && !::Wuxia.CombatRules.isUndeadOrConstruct(_attacker))
				{
					::Wuxia.CombatRules.spendQi(_attacker, 8);
				}
			}
			else
			{
				// Night/Yin Phase: devours ranged arrows; rewards 1-tile melee (+25% dmg)!
				if (_skill.isRanged())
				{
					_properties.DamageReceivedTotalMult *= 0.25;
					if (actor.getHitpoints() < actor.getHitpointsMax())
						actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + 14));
				}
				else if (dist == 1)
				{
					_properties.DamageReceivedTotalMult *= 1.25;
				}
			}
		}

		if ("HammerWeakOnly" in mech && mech.HammerWeakOnly)
		{
			if (_skill != null && (_skill.isRanged() || !::Wuxia.CombatRules.matchesWeapon(mainW, ["Hammer", "Fist", "Staff"])))
				_properties.DamageReceivedTotalMult *= 0.55;
		}

		if (_attacker != null && _attacker.getID() != actor.getID() && _attacker.isAlive() && _skill != null && !_skill.isRanged())
		{
			if ("ThornsNonAxe" in mech && mech.ThornsNonAxe && !::Wuxia.CombatRules.matchesWeapon(mainW, ["Axe"]))
			{
				if (::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
				{
					local body = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (body != null && body.getArmor() > 0) body.setArmor(::Math.max(0, body.getArmor() - 10));
				}
				if (_attacker.getHitpoints() > 6) _attacker.setHitpoints(_attacker.getHitpoints() - 5);
			}
			local atkSk = (::Wuxia.hasMember(_attacker, "getSkills")) ? _attacker.getSkills() : null;
			local atkBuff = atkSk != null ? atkSk.getSkillByID("effects.wx_pill_battle_buff") : null;
			local atkHasBihuo = (atkBuff != null && (::Wuxia.hasMember(atkBuff.m, "HasBihuo")) && atkBuff.m.HasBihuo);
			if (!atkHasBihuo && "ThornsMeleeFire" in mech && mech.ThornsMeleeFire)
			{
				if (::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
				{
					local body2 = _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (body2 != null && body2.getArmor() > 0) body2.setArmor(::Math.max(0, body2.getArmor() - 12));
				}
				if (_attacker.getHitpoints() > 7) _attacker.setHitpoints(_attacker.getHitpoints() - 6);
			}
			if ("ThornsMeleeQi" in mech && mech.ThornsMeleeQi > 0 && !::Wuxia.CombatRules.isUndeadOrConstruct(_attacker) && (::Wuxia.hasMember(_attacker, "getFatigue")))
			{
				_attacker.setFatigue(::Math.min(_attacker.getFatigueMax(), _attacker.getFatigue() + mech.ThornsMeleeQi));
			}
			if ("ThornsAoE" in mech && mech.ThornsAoE > 0 && _attacker.getHitpoints() > mech.ThornsAoE + 1)
			{
				_attacker.setHitpoints(_attacker.getHitpoints() - mech.ThornsAoE);
			}
		}
	}

	function onDamageReceived( _attacker, _damageHitpoints, _damageArmor )
	{
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor == null || !actor.isAlive()) return;
		local mech = this.getMechanics();

		if (this.m.IsCharging && cont.hasSkill("effects.wx_status_acupoint"))
		{
			this.triggerChargeBreak(actor);
		}

		if (this.m.PuzzleType == "bastion" && !this.m.HalfHpShellUsed && actor.getHitpointsPct() <= 0.50)
		{
			this.m.HalfHpShellUsed = true;
			this.m.ShellStacks = 3;
			this.m.ShellBrokenLeft = 0;
			if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
				::Tactical.EventLog.log("【凶兽护命】" + ::Const.UI.getColorizedEntityName(actor) + " 剧痛咆哮，再度凝起 3 层太古玄壳！");
		}
		else if (!this.m.HalfHpCharge && actor.getHitpointsPct() <= 0.50 && !this.m.IsCharging)
		{
			this.m.HalfHpCharge = true;
			this.m.IsCharging = true;
			this.m.BreakProgress = 0;
			if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
				::Tactical.EventLog.log("【半血狂暴蓄势】" + ::Const.UI.getColorizedEntityName(actor) + " 凶血沸腾，开始蓄力荒神天灾（速以点穴或重兵打断）！");
		}

		if ("ReviveOnceHP" in mech && !this.m.ReviveUsed && actor.getHitpoints() <= 15 && actor.getHitpoints() > 0)
		{
			this.m.ReviveUsed = true;
			actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + mech.ReviveOnceHP));
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(actor, "wx_vfx_20", "wx_fx_blood_orb", -25, 110, 1.28);
		}
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null || _targetEntity == null || !_targetEntity.isAlive() || actor.isAlliedWith(_targetEntity)) return;

		local mech = this.getMechanics();
		local tsk = _targetEntity.getSkills();
		if (tsk == null) return;
		local immuneBio = ::Wuxia.CombatRules.isImmuneToMeridianAndPoison(_targetEntity);
		local tBuff = tsk.getSkillByID("effects.wx_pill_battle_buff");
		local tHasYuji  = (tBuff != null && (::Wuxia.hasMember(tBuff.m, "HasYuji")) && tBuff.m.HasYuji);
		local tHasBihuo = (tBuff != null && (::Wuxia.hasMember(tBuff.m, "HasBihuo")) && tBuff.m.HasBihuo);

		if ("OnHitBleed" in mech && _damageInflictedHitpoints >= 5 && !immuneBio && !tHasYuji)
		{
			local bleed = ::new("scripts/skills/effects/bleeding_effect");
			bleed.setDamage(mech.OnHitBleed);
			tsk.add(bleed);
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_13", "wx_fx_claw_slash", 0, 0, 1.12);
		}
		if ("OnHitDrainHP" in mech && _damageInflictedHitpoints > 0)
		{
			local drainHP = ::Math.min(mech.OnHitDrainHP, _damageInflictedHitpoints);
			if (actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + drainHP));
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_06", "wx_fx_blood_orb", 0, 140, 1.12);
		}
		if ("OnHitDrainQi" in mech && !::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity) && (::Wuxia.hasMember(_targetEntity, "getFatigue")))
		{
			_targetEntity.setFatigue(::Math.min(_targetEntity.getFatigueMax(), _targetEntity.getFatigue() + mech.OnHitDrainQi));
		}
		if (!tHasBihuo && "OnHitArmorBurn" in mech && (::Wuxia.hasMember(_targetEntity, "getItems")) && _targetEntity.getItems() != null)
		{
			local body = _targetEntity.getItems().getItemAtSlot(::Const.ItemSlot.Body);
			if (body != null && body.getArmor() > 0)
			{
				body.setArmor(::Math.max(0, body.getArmor() - mech.OnHitArmorBurn));
				if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_05", "wx_fx_earth_fissure", 0, 0, 1.14);
			}
		}
		if ("OnHitPoison" in mech && mech.OnHitPoison && !immuneBio)
		{
			this.applyDebuffSafe(tsk, "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_28", "wx_fx_poison_skull", -20, 0, 1.06);
		}
		if ("OnHitInternalInjury" in mech && mech.OnHitInternalInjury && !immuneBio)
		{
			this.applyDebuffSafe(tsk, "effects.wx_internal_injury", "scripts/skills/effects/wx_internal_injury");
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_11", "wx_fx_blood_orb", 0, 0, 1.08);
		}
		if ("OnHitAcupoint" in mech && mech.OnHitAcupoint && !immuneBio)
		{
			this.applyDebuffSafe(tsk, "effects.wx_status_acupoint", "scripts/skills/effects/wx_status_acupoint");
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_16", "wx_fx_lotus_seal", 0, 100, 1.06);
		}
		if ("OnHitScatter" in mech && mech.OnHitScatter && !immuneBio)
		{
			this.applyDebuffSafe(tsk, "effects.wx_scatter_weakness", "scripts/skills/effects/wx_scatter_weakness");
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_19", "wx_fx_bagua", 0, -90, 1.08);
		}
		if ("OnHitOffbalance" in mech && mech.OnHitOffbalance)
		{
			this.applyDebuffSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_14", "wx_fx_sonic_ring", 0, 0, 1.06);
		}
		if ("OnHitOpening" in mech && mech.OnHitOpening)
		{
			this.applyDebuffSafe(tsk, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(_targetEntity, "wx_vfx_07", "wx_fx_sword_phantom", 0, 0, 1.06);
		}
	}

	function onTargetKilled( _targetEntity, _skill )
	{
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (actor == null || !actor.isAlive()) return;
		local mech = this.getMechanics();

		if ("KillHealHP" in mech && mech.KillHealHP > 0 && actor.getHitpoints() < actor.getHitpointsMax())
			actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + mech.KillHealHP));

		if ("KillSmoke" in mech && mech.KillSmoke && actor.getSkills() != null)
			this.applyDebuffSafe(actor.getSkills(), "effects.wx_status_smoke_screen", "scripts/skills/effects/wx_status_smoke_screen");

		if ("KillRefundAP" in mech && !this.m.KillAPUsed)
		{
			this.m.KillAPUsed = true;
			actor.setActionPoints(::Math.min(actor.getActionPointsMax(), actor.getActionPoints() + mech.KillRefundAP));
		}
	}
});
