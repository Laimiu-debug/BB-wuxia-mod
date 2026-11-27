// Racial Tactical Mechanics for All 11 Wild Shan Hai Beast Families (Non-Boss Wilderness Monsters)
// Gives every wild monster species a bespoke Shan Hai ability AND clear tactical counterplay!

this.wx_wild_beast_trait <- this.inherit("scripts/skills/skill", {
	m = {
		FamilyKey    = "",
		BoneShell    = 0,
		LastGrownSz  = 1,
		ShedSkinUsed = false,
		RoundNum     = 0,
		ScalesBroken = false
	},

	function create()
	{
		this.m.ID = "special.wx_wild_beast_trait";
		this.m.Name = "山海异种";
		this.m.Description = "山泽荒兽受大荒灵煞侵染而生的异种本能。";
		this.m.Icon = "ui/perks/wx_shanhai_boss_trait.png";
		this.m.Type = this.Const.SkillType.Special | this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.Trait;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsHidden = false;
		this.m.IsSerialized = false;
	}

	function initByFamily( _key )
	{
		this.m.FamilyKey = _key;
		if (_key == "direwolf")
		{
			this.m.Name = "荒原群噬 · 裂筋";
			this.m.Description = "【山海荒兽】合围猎物时每多 1 名友军额外获得 +4 命中与 +6% 穿甲；咬中「流血/失衡」目标时扯裂脚筋，耗散其 8 点内息并挂「失衡」。\n【破招对策】结盾防合围，优先生擒头狼震慑兽群。";
		}
		else if (_key == "hyena")
		{
			this.m.Name = "攒角泣音 · 乘怯";
			this.m.Description = "【山海荒兽】回合初发出婴啼凶音，震散 2 格内定力不足（<55）敌军 7 点内息并可能挂「破绽」；扑击动摇或带破绽者总伤 +20%。\n【破招对策】以《聚义令》稳固军心定力即可废其凶威。";
		}
		else if (_key == "spider")
		{
			this.m.Name = "腐甲蛛涎 · 爆囊";
			this.m.Description = "【山海荒兽】噬咬被蛛网缠住的目标时额外腐蚀 18 点护甲；巨蛛毙命时毒囊爆裂，溅射邻格敌军挂「奇毒」。\n【破招对策】先行挥剑斩网，宜用长兵或弓弩击杀免沾爆毒。";
		}
		else if (_key == "ghoul")
		{
			this.m.Name = "饕食凶骸 · 骨膜";
			this.m.Description = "【山海荒兽】开局及每次吞尸进化凝结 1 层「凶骸骨膜」（受普通刀剑箭矢首击减伤 45%）。\n【破招对策】用重锤、棍杖或拳掌寸劲击中可一击震碎骨膜并反震其 12 点气血！";
			this.m.BoneShell = 1;
		}
		else if (_key == "unhold")
		{
			this.m.Name = "刚毛卸矢 · 擂胸震岳";
			this.m.Description = "【山海荒兽】厚重刚毛令远程伤害减免 30%；每逢偶数回合初擂胸震地，震散贴身敌军 8 点内息并推退未架盾墙者。\n【破招对策】重甲盾卫架盾顶线，以流血奇毒克制其再生。";
		}
		else if (_key == "lindwurm")
		{
			this.m.Name = "蛟涎蚀甲 · 颈下逆鳞";
			this.m.Description = "【山海荒兽】尾部横扫带起恶风令目标陷入「失衡」；但颈下藏有逆鳞弱点。\n【破招对策】当回合先以弓弩暗器射中或施以「点穴封脉」，即可揭开逆鳞令其本轮近防 -15、受穿甲伤 +15%！";
		}
		else if (_key == "schrat")
		{
			this.m.Name = "盘根汲气 · 畏斧惧火";
			this.m.Description = "【山海荒兽】木盾完好时根须每回合汲取 2 格内敌军 7 点内息化为生机。\n【破招对策】斧钺劈砍或火铳轰击可对其额外造成 +30% 破盾与本体重创！";
		}
		else if (_key == "serpent")
		{
			this.m.Name = "盘绞夺息 · 金蝉蜕鳞";
			this.m.Description = "【山海荒兽】噬咬缠绕时抽干目标 10 点内息；气血首次跌破 50% 时蜕鳞净除负面状态并短暂提升闪避。\n【破招对策】留点穴与爆发绝招待其蜕鳞后一鼓作气斩杀。";
		}
		else if (_key == "alp")
		{
			this.m.Name = "噬梦摄魂 · 畏阳惧吼";
			this.m.Description = "【山海荒兽】专侵定力薄弱者抽干内息。\n【破招对策】一旦遭阳刚战吼（如《狮吼功》）或重击震荡，立即显形暴露「破绽 + 失衡」！";
		}
		else if (_key == "hexe")
		{
			this.m.Name = "血蛊同命 · 气机反噬";
			this.m.Description = "【山海荒兽】以妖术驭兽摄魂，气血低于 65% 时护身妖气紊乱自动暴露「破绽」。\n【破招对策】远程神射越阵狙杀，或趁其气血受损破绽毕露时突进斩首。";
		}
		else if (_key == "sand_golem")
		{
			this.m.Name = "聚沙石躯 · 唯钝碎核";
			this.m.Description = "【山海荒兽】黄沙凝石之躯对刀剑穿刺与弓矢减伤 30%。\n【破招对策】使用重锤、棍杖或拳掌内劲可直震石核造成 1.35 倍碎裂伤害！";
		}
	}

	function getTooltip()
	{
		local ret = [
			{ id = 1, type = "title", text = this.getName() },
			{ id = 2, type = "description", text = this.getDescription() }
		];
		if (this.m.FamilyKey == "ghoul" && this.m.BoneShell > 0)
			ret.push({ id = 10, type = "text", icon = "ui/icons/armor_body.png", text = "当前【凶骸骨膜】层数：[color=" + ::Const.UI.Color.NegativeValue + "]" + this.m.BoneShell + "[/color]（钝器/拳掌一击即碎）" });
		if (this.m.FamilyKey == "lindwurm" && this.m.ScalesBroken)
			ret.push({ id = 11, type = "text", icon = "ui/icons/direct_damage.png", text = "【逆鳞受创】已触发：本回合近防 -15，受穿甲伤 +15%！" });
		return ret;
	}

	function applyStatusSafe( _sk, _id, _script )
	{
		if (_sk == null) return;
		local e = _sk.getSkillByID(_id);
		if (e == null) _sk.add(::new(_script));
		else if ("resetDuration" in e) e.resetDuration();
	}

	function onTurnStart()
	{
		this.m.RoundNum += 1;
		this.m.ScalesBroken = false;
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor == null || !actor.isAlive() || !::Wuxia.isOnMap(actor)) return;

		local fk = this.m.FamilyKey;
		local myTile = actor.getTile();

		if (fk == "ghoul" && ::Wuxia.hasMember(actor, "getSize"))
		{
			local curSz = actor.getSize();
			if (curSz > this.m.LastGrownSz)
			{
				this.m.LastGrownSz = curSz;
				this.m.BoneShell = ::Math.min(2, this.m.BoneShell + 1);
			}
		}
		else if (fk == "hyena")
		{
			local all = ::Tactical.Entities.getAllInstancesAsArray();
			foreach (ent in all)
			{
				if (ent == null || !ent.isAlive() || !::Wuxia.isOnMap(ent) || actor.isAlliedWith(ent)) continue;
				if (myTile.getDistanceTo(ent.getTile()) > 2) continue;
				if (ent.getCurrentProperties().Bravery < 55)
				{
					if (!::Wuxia.CombatRules.isUndeadOrConstruct(ent))
						::Wuxia.CombatRules.spendQi(ent, 7);
					if (::Math.rand(1, 100) <= 55 && ent.getSkills() != null)
						this.applyStatusSafe(ent.getSkills(), "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
				}
			}
		}
		else if (fk == "unhold" && (this.m.RoundNum % 2) == 0)
		{
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(myTile, "wx_vfx_14", "wx_fx_earth_fissure", 0, 0, 1.15);
			for (local d = 0; d < 6; d = ++d)
			{
				if (!myTile.hasNextTile(d)) continue;
				local adj = myTile.getNextTile(d);
				if (!adj.IsOccupiedByActor) continue;
				local ent = adj.getEntity();
				if (ent == null || !ent.isAlive() || actor.isAlliedWith(ent)) continue;
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(ent))
					::Wuxia.CombatRules.spendQi(ent, 8);
				local eSk = ent.getSkills();
				local braced = (eSk != null && (eSk.hasSkill("effects.shieldwall") || eSk.hasSkill("effects.indomitable")))
					|| ent.getCurrentProperties().IsImmuneToKnockBackAndGrab;
				if (!braced && adj.hasNextTile(d))
				{
					local dst = adj.getNextTile(d);
					if (dst != null && dst.IsEmpty && !dst.IsOccupiedByActor && ::Math.abs(dst.Level - adj.Level) <= 1)
						::Tactical.getNavigator().teleport(ent, dst, null, null, true);
				}
			}
		}
		else if (fk == "schrat" && ::Wuxia.hasMember(actor, "isArmedWithShield") && actor.isArmedWithShield())
		{
			local drained = 0;
			local all2 = ::Tactical.Entities.getAllInstancesAsArray();
			foreach (ent2 in all2)
			{
				if (ent2 == null || !ent2.isAlive() || !::Wuxia.isOnMap(ent2) || actor.isAlliedWith(ent2)) continue;
				if (myTile.getDistanceTo(ent2.getTile()) > 2 || ::Wuxia.CombatRules.isUndeadOrConstruct(ent2)) continue;
				drained += ::Wuxia.CombatRules.spendQi(ent2, 7);
			}
			if (drained > 0 && actor.getHitpoints() < actor.getHitpointsMax())
				actor.setHitpoints(::Math.min(actor.getHitpointsMax(), actor.getHitpoints() + drained));
		}
	}

	function onUpdate( _properties )
	{
		local fk = this.m.FamilyKey;
		if (fk == "unhold")
		{
			_properties.DamageReceivedRangedMult *= 0.70;
		}
		else if (fk == "lindwurm" && this.m.ScalesBroken)
		{
			_properties.MeleeDefense -= 15;
		}
	}

	function onAnySkillUsed( _skill, _targetEntity, _properties )
	{
		if (_skill == null || !_skill.isAttack() || _targetEntity == null || !_targetEntity.isAlive()) return;
		local fk = this.m.FamilyKey;
		if (fk == "direwolf" && ::Wuxia.isOnMap(_targetEntity))
		{
			local tTile = _targetEntity.getTile();
			local actor = this.getContainer().getActor();
			local alliesAdj = 0;
			for (local d = 0; d < 6; d = ++d)
			{
				if (!tTile.hasNextTile(d)) continue;
				local nt = tTile.getNextTile(d);
				if (nt.IsOccupiedByActor && nt.getEntity() != null && nt.getEntity().getID() != actor.getID() && actor.isAlliedWith(nt.getEntity()))
					alliesAdj += 1;
			}
			if (alliesAdj > 0)
			{
				_properties.MeleeSkill += alliesAdj * 4;
				_properties.DamageDirectAdd += alliesAdj * 0.06;
			}
		}
		else if (fk == "hyena")
		{
			local tsk = _targetEntity.getSkills();
			local shaken = (_targetEntity.getMoraleState() <= ::Const.MoraleState.Wavering)
				|| (tsk != null && tsk.hasSkill("effects.wx_status_opening"));
			if (shaken) _properties.DamageTotalMult *= 1.20;
		}
	}

	function onTargetHit( _skill, _targetEntity, _bodyPart, _damageInflictedHitpoints, _damageInflictedArmor )
	{
		if (_targetEntity == null || !_targetEntity.isAlive()) return;
		local fk = this.m.FamilyKey;
		local tsk = _targetEntity.getSkills();
		if (tsk == null) return;

		if (fk == "direwolf")
		{
			if (tsk.hasSkill("effects.bleeding") || tsk.hasSkill("effects.wx_status_offbalance"))
			{
				if (!::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
					::Wuxia.CombatRules.spendQi(_targetEntity, 8);
				this.applyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
		}
		else if (fk == "spider")
		{
			if (tsk.hasSkill("effects.web") && ::Wuxia.hasMember(_targetEntity, "getItems") && _targetEntity.getItems() != null)
			{
				local body = _targetEntity.getItems().getItemAtSlot(::Const.ItemSlot.Body);
				if (body != null && body.getArmor() > 0)
					body.setArmor(::Math.max(0, body.getArmor() - 18));
			}
		}
		else if (fk == "lindwurm")
		{
			this.applyStatusSafe(tsk, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
		}
		else if (fk == "serpent" || fk == "alp")
		{
			if (!::Wuxia.CombatRules.isUndeadOrConstruct(_targetEntity))
				::Wuxia.CombatRules.spendQi(_targetEntity, 10);
		}
	}

	function onBeforeDamageReceived( _attacker, _skill, _hitInfo, _properties )
	{
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor == null || _skill == null) return;
		local fk = this.m.FamilyKey;
		local mainW = (_attacker != null && ::Wuxia.hasMember(_attacker, "getItems") && _attacker.getItems() != null)
			? _attacker.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand) : null;
		local isBluntOrFist = (mainW != null && ::Wuxia.CombatRules.matchesWeapon(mainW, ["Hammer", "Staff", "Fist"]));

		if (fk == "ghoul" && this.m.BoneShell > 0)
		{
			if (isBluntOrFist)
			{
				this.m.BoneShell = 0;
				if (actor.getHitpoints() > 14) actor.setHitpoints(actor.getHitpoints() - 12);
				if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
					::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(actor) + " 的凶骸骨膜被刚猛寸劲一击震碎！");
			}
			else
			{
				this.m.BoneShell -= 1;
				_properties.DamageReceivedTotalMult *= 0.55;
			}
		}
		else if (fk == "lindwurm")
		{
			if (_skill.isRanged() || (cont != null && cont.hasSkill("effects.wx_status_acupoint")))
			{
				if (!this.m.ScalesBroken)
				{
					this.m.ScalesBroken = true;
					if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
						::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(actor) + " 颈下逆鳞受创，破绽大开！");
				}
			}
			if (this.m.ScalesBroken)
				_properties.DamageReceivedDirectMult *= 1.15;
		}
		else if (fk == "schrat")
		{
			local isAxeOrFire = (mainW != null && ::Wuxia.CombatRules.matchesWeapon(mainW, ["Axe", "Firearm"]));
			if (isAxeOrFire)
				_properties.DamageReceivedTotalMult *= 1.30;
		}
		else if (fk == "sand_golem")
		{
			if (isBluntOrFist)
				_properties.DamageReceivedTotalMult *= 1.35;
			else
				_properties.DamageReceivedTotalMult *= 0.70;
		}
		else if (fk == "alp")
		{
			if (isBluntOrFist || _skill.getID().find("shihou") != null || _skill.getID().find("kuiniu") != null)
			{
				this.applyStatusSafe(cont, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
				this.applyStatusSafe(cont, "effects.wx_status_offbalance", "scripts/skills/effects/wx_status_offbalance");
			}
		}
	}

	function onDamageReceived( _attacker, _damageHitpoints, _damageArmor )
	{
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor == null || !actor.isAlive()) return;
		local fk = this.m.FamilyKey;

		if (fk == "serpent" && !this.m.ShedSkinUsed && actor.getHitpointsPct() <= 0.50)
		{
			this.m.ShedSkinUsed = true;
			foreach (negId in ["effects.bleeding", "effects.wx_status_poison_dart", "effects.wx_status_acupoint", "effects.wx_status_opening", "effects.wx_status_offbalance"])
			{
				if (cont.hasSkill(negId)) cont.removeByID(negId);
			}
			if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(actor, "wx_vfx_28", null, 0, 120, 1.12);
			if ("EventLog" in ::Tactical && ::Tactical.EventLog != null)
				::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(actor) + " 剧痛蜕去旧鳞，挣脱周身负面状态！");
		}
		else if (fk == "hexe" && actor.getHitpointsPct() <= 0.65)
		{
			this.applyStatusSafe(cont, "effects.wx_status_opening", "scripts/skills/effects/wx_status_opening");
		}
	}

	function onDeath( _fatalityType )
	{
		if (this.m.FamilyKey != "spider") return;
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor == null || !::Wuxia.isOnMap(actor)) return;
		local tile = actor.getTile();
		if ("VFX" in ::Wuxia) ::Wuxia.VFX.playTriggerVfx(tile, "wx_vfx_28", "wx_fx_poison_skull", -18, 0, 1.15);
		for (local d = 0; d < 6; d = ++d)
		{
			if (!tile.hasNextTile(d)) continue;
			local adj = tile.getNextTile(d);
			if (!adj.IsOccupiedByActor) continue;
			local ent = adj.getEntity();
			if (ent != null && ent.isAlive() && !actor.isAlliedWith(ent) && !::Wuxia.CombatRules.isImmuneToMeridianAndPoison(ent))
				this.applyStatusSafe(ent.getSkills(), "effects.wx_status_poison_dart", "scripts/skills/effects/wx_status_poison_dart");
		}
	}
});
