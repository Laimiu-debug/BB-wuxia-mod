// HUD-Safe Converged Active Skill for Mid-Battle Powders & Multi-Sect Blade Coatings (`奇药涂散`)
// Unifies all `wx_tact_*` bag consumables into a single active skill icon (`<= 9` HUD active skills).

this.wx_item_tactical_powder <- this.inherit("scripts/skills/skill", {
	m = {
		ActiveTactID = "wx_tact_xuanshuang"
	},

	function create()
	{
		this.m.ID = "actives.wx_item_tactical_powder";
		this.m.Name = "奇药涂散";
		this.m.Description = "施展随身腰包内的战中破局灵散（净化天灾地脉、瞬发破穴提气）或涂抹主手门派奇膏。";
		this.m.Icon = "skills/wx_smoke_cast.png";
		this.m.IconDisabled = "skills/wx_smoke_cast_sw.png";
		this.m.Type = this.Const.SkillType.Active;
		this.m.Order = this.Const.SkillOrder.UtilityTargeted;
		this.m.IsSerialized = false;
		this.m.IsActive = true;
		this.m.IsTargeted = false;
		this.m.IsStacking = false;
		this.m.IsAttack = false;
		this.m.IsWeaponSkill = false;
		this.m.IsIgnoredAsAOO = true;
		this.m.ActionPointCost = 2;
		this.m.FatigueCost = 4;
		this.m.MinRange = 0;
		this.m.MaxRange = 0;
	}

	function resolveReadyItem()
	{
		local cont = this.getContainer();
		local actor = cont != null ? cont.getActor() : null;
		if (actor == null || !("CraftBridge" in ::Wuxia)) return null;
		return ::Wuxia.CraftBridge.findActiveBagItem(actor, "powder");
	}

	function syncWithBag( _actor = null )
	{
		local act = _actor;
		if (act == null && this.getContainer() != null)
			act = this.getContainer().getActor();
		if (act == null || !("CraftBridge" in ::Wuxia)) return;

		local pItem = ::Wuxia.CraftBridge.findActiveBagItem(act, "powder");
		if (pItem == null) return;
		local cfg = pItem.getTactCfg();
		if (cfg == null) return;

		this.m.ActiveTactID    = cfg.ID;
		this.m.Name            = "奇药：" + cfg.Name + "（×" + pItem.getCharges() + "）";
		this.m.Description     = cfg.Description;
		this.m.Icon            = cfg.SkillIcon;
		this.m.IconDisabled    = cfg.SkillIcon.slice(0, cfg.SkillIcon.len() - 4) + "_sw.png";
		this.m.ActionPointCost = cfg.APCost;
		this.m.FatigueCost     = cfg.QiCost;
		this.m.IsTargeted      = cfg.IsTargeted;
		this.m.MinRange        = cfg.MinRange;
		this.m.MaxRange        = cfg.MaxRange;
	}

	function onUpdate( _properties )
	{
		this.syncWithBag();
	}

	function isUsable()
	{
		if (!this.skill.isUsable()) return false;
		local pItem = this.resolveReadyItem();
		if (pItem == null) return false;
		local cfg = pItem.getTactCfg();
		local actor = this.getContainer() != null ? this.getContainer().getActor() : null;
		if (cfg == null || actor == null) return false;

		if (cfg.SubMode == "coating")
		{
			local mainW = (::Wuxia.hasMember(actor, "getItems") && actor.getItems() != null)
				? actor.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand)
				: null;
			if (mainW == null) return false;
		}
		else if (cfg.SubMode == "oral" && ::Wuxia.hasMember(actor, "getSkills") && actor.getSkills() != null)
		{
			local buff = actor.getSkills().getSkillByID("effects.wx_pill_battle_buff");
			local prepCnt = (buff != null && ::Wuxia.hasMember(buff, "countActiveBuffs")) ? buff.countActiveBuffs() : 0;
			local midCnt  = ("m" in actor && actor.m != null && ("WX_MidBattleOralDoses" in actor.m)) ? actor.m.WX_MidBattleOralDoses : 0;
			if (prepCnt + midCnt >= 3) return false;
		}
		return true;
	}

	function getTooltip()
	{
		this.syncWithBag();
		local ret = this.getDefaultUtilityTooltip();
		local pItem = this.resolveReadyItem();
		if (pItem != null)
		{
			ret.push({
				id = 10,
				type = "text",
				icon = "ui/icons/special.png",
				text = "当前待用奇药：[color=#0a4213]" + pItem.getName() + "[/color]（剩余剂量 " + pItem.getCharges() + "）"
			});
		}
		return ret;
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.m.IsTargeted) return true;
		if (_originTile == null || _targetTile == null) return false;
		local dist = _originTile.getDistanceTo(_targetTile);
		return (dist >= this.m.MinRange && dist <= this.m.MaxRange);
	}

	function executeTacticalPowder( _user, _targetTile = null )
	{
		local pItem = this.resolveReadyItem();
		if (pItem == null || _user == null) return false;
		local cfg = pItem.getTactCfg();
		if (cfg == null) return false;

		local skills = ::Wuxia.hasMember(_user, "getSkills") ? _user.getSkills() : null;

		if (cfg.ID == "wx_tact_xuanshuang")
		{
			local center = (_targetTile != null) ? _targetTile : (::Wuxia.hasMember(_user, "getTile") ? _user.getTile() : null);
			::Wuxia.CraftBridge.purifyHazardousTiles(center, _user, 1);
		}
		else if (cfg.ID == "wx_tact_longhusan")
		{
			local doseRes = ::Wuxia.CraftBridge.tryConsumeBattleOralDose(_user, cfg.ID);
			if (!doseRes.Ok) return false;

			if (skills != null)
			{
				foreach (ccID in [
					"effects.wx_status_acupoint",
					"effects.wx_status_offbalance",
					"effects.wx_scatter_weakness",
					"effects.stunned",
					"effects.dazed",
					"effects.staggered"
				])
				{
					if (skills.hasSkill(ccID)) skills.removeByID(ccID);
				}
			}
			::Wuxia.CombatRules.restoreQi(_user, 18);
			if (::Wuxia.hasMember(_user, "getMoraleState") && _user.getMoraleState() == ::Const.MoraleState.Wavering)
				_user.setMoraleState(::Const.MoraleState.Steady);
		}
		else if (cfg.ID == "wx_tact_qingfenglu")
		{
			local doseResQ = ::Wuxia.CraftBridge.tryConsumeBattleOralDose(_user, cfg.ID);
			if (!doseResQ.Ok) return false;

			if (skills != null)
			{
				foreach (trapID in ["effects.web", "effects.net", "effects.rooted", "effects.kraken_ensnare", "effects.serpent_ensnare", "effects.goblin_shaman_ensnare"])
				{
					if (skills.hasSkill(trapID)) skills.removeByID(trapID);
				}
			}
			::Wuxia.CombatRules.restoreQi(_user, 10);
			if ("m" in _user && _user.m != null)
				_user.m.WX_FreeDisengageRound <- ::Wuxia.CraftBridge.getCurrentRound();
		}
		else if (cfg.ID == "wx_tact_pohuanxiang")
		{
			local centerP = (_targetTile != null) ? _targetTile : (::Wuxia.hasMember(_user, "getTile") ? _user.getTile() : null);
			::Wuxia.CraftBridge.purifyMindAndMirageTiles(centerP, _user);
		}
		else if (cfg.SubMode == "coating")
		{
			local mainWpn = (::Wuxia.hasMember(_user, "getItems") && _user.getItems() != null)
				? _user.getItems().getItemAtSlot(::Const.ItemSlot.Mainhand)
				: null;
			if (mainWpn == null || skills == null) return false;

			local extraHits = ("m" in mainWpn && mainWpn.m != null && ("WX_WeaponModID" in mainWpn.m) && mainWpn.m.WX_WeaponModID == "wx_wmod_dagger_groove") ? 2 : 0;
			local coat = skills.getSkillByID("effects.wx_status_blade_coating");
			if (coat == null)
			{
				coat = ::new("scripts/skills/effects/wx_status_blade_coating");
				coat.applyCoating(cfg.ID, 4 + extraHits, cfg.Name);
				skills.add(coat);
			}
			else
			{
				coat.applyCoating(cfg.ID, 4 + extraHits, cfg.Name);
			}
		}
		else if (cfg.ID == "wx_tact_danjiesan")
		{
			local tCenter = (_targetTile != null) ? _targetTile : (::Wuxia.hasMember(_user, "getTile") ? _user.getTile() : null);
			if (tCenter == null) return false;
			local blastTiles = [tCenter];
			if (::Wuxia.hasMember(tCenter, "hasNextTile"))
			{
				for (local d = 0; d < 6; d = ++d)
					if (tCenter.hasNextTile(d)) blastTiles.push(tCenter.getNextTile(d));
			}
			foreach (bt in blastTiles)
			{
				if (bt == null || !("IsOccupiedByActor" in bt) || !bt.IsOccupiedByActor || bt.getEntity() == null) continue;
				local e = bt.getEntity();
				if (!e.isAlive() || _user.isAlliedWith(e)) continue;
				if (::Wuxia.hasMember(e, "getItems") && e.getItems() != null)
				{
					local eb = e.getItems().getItemAtSlot(::Const.ItemSlot.Body);
					if (eb != null && eb.getArmor() > 0) eb.setArmor(::Math.max(0, eb.getArmor() - 16));
				}
				if (!::Wuxia.CombatRules.isImmuneToMeridianAndPoison(e) && ::Wuxia.hasMember(e, "getSkills") && e.getSkills() != null && !e.getSkills().hasSkill("effects.wx_status_poison_dart"))
					e.getSkills().add(::new("scripts/skills/effects/wx_status_poison_dart"));
			}
		}

		pItem.consumeCharge();
		::Wuxia.CraftBridge.syncBagTacticalSkills(_user);
		return true;
	}

	function onUse( _user, _targetTile )
	{
		return this.executeTacticalPowder(_user, _targetTile);
	}
});
