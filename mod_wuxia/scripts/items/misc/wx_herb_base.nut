// Base Item for《山海本草》Rare Spirit Herbs (usable both as Taxidermist Alchemy ingredients AND emergency raw field remedies!)

this.wx_herb_base <- this.inherit("scripts/items/item", {
	m = {
		HerbID = "wx_herb_zhuyu"
	},

	function create()
	{
		this.item.create();
		this.m.SlotType = this.Const.ItemSlot.None;
		this.m.ItemType = this.Const.Items.ItemType.Misc | this.Const.Items.ItemType.Crafting | this.Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsUsable = true;
		this.m.Value = 600;
	}

	function initHerb( _herbID )
	{
		this.m.HerbID = _herbID;
		this.m.ID = "misc." + _herbID;
		if ("Herbs" in ::Wuxia.Config && (_herbID in ::Wuxia.Config.Herbs))
		{
			local cfg = ::Wuxia.Config.Herbs[_herbID];
			this.m.Name = cfg.Name;
			this.m.Description = cfg.Description;
			this.m.Icon = cfg.Icon;
			this.m.Value = cfg.Value;
			this.m.IsUsable = (cfg.Kind != "herb_infuse");
		}
	}

	function getHerbID()
	{
		return this.m.HerbID;
	}

	function getTooltip()
	{
		local ret = this.item.getTooltip();
		if ("Herbs" in ::Wuxia.Config && (this.m.HerbID in ::Wuxia.Config.Herbs))
		{
			local cfg = ::Wuxia.Config.Herbs[this.m.HerbID];
			local qKey = ("Quality" in cfg) ? cfg.Quality : "common";
			local qLabel = (qKey in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[qKey] : "奇珍";
			local qCol = ("UI" in ::Wuxia && "getQualityTooltipColor" in ::Wuxia.UI) ? ::Wuxia.UI.getQualityTooltipColor(qKey) : "#0b4a1e";
			local natSuffix = "";
			if ("Alchemy" in ::Wuxia.Config && "HerbNatures" in ::Wuxia.Config.Alchemy && (this.m.HerbID in ::Wuxia.Config.Alchemy.HerbNatures))
			{
				local hn = ::Wuxia.Config.Alchemy.HerbNatures[this.m.HerbID];
				local nName = ("Natures" in ::Wuxia.Config.Alchemy && hn.Nature in ::Wuxia.Config.Alchemy.Natures)
					? ::Wuxia.Config.Alchemy.Natures[hn.Nature].Name
					: hn.Nature;
				local nCol = ("UI" in ::Wuxia && "getNatureTooltipColor" in ::Wuxia.UI) ? ::Wuxia.UI.getNatureTooltipColor(hn.Nature) : "#094039";
				natSuffix = " · [color=" + nCol + "][b]" + nName + "（药力 " + hn.Potency + "）[/b][/color]";
			}
			ret.push({
				id = 15,
				type = "text",
				icon = "ui/icons/special.png",
				text = "[color=#3a3052][b]本草品阶：[/b][/color][color=" + qCol + "][b]【《" + cfg.Chapter + "》· " + qLabel + " · " + cfg.SubLabel + "】[/b][/color]" + natSuffix
			});
			if (cfg.Kind == "herb_infuse")
			{
				ret.push({
					id = 16,
					type = "text",
					icon = "ui/icons/xp_received.png",
					text = "[color=#094a44][b]双途妙用：[/b][/color]可在「百工丹坊」入炉炼制仙丹，亦可拖入武学插槽生服参悟（[color=#0b4a1e][b]+" + cfg.ExpAmount + "[/b][/color] 火候）"
				});
			}
			else
			{
				ret.push({
					id = 16,
					type = "text",
					icon = "ui/icons/health.png",
					text = "[color=#094a44][b]双途妙用：[/b][/color]可在「百工丹坊」入炉倍增药效炼成灵丹，亦可在行囊或丹药页应急生服"
				});
			}
		}
		return ret;
	}

	function applyToActorWithMessage( _actor )
	{
		if (_actor == null || !("Herbs" in ::Wuxia.Config) || !(this.m.HerbID in ::Wuxia.Config.Herbs))
			return { Ok = false, Reason = "无效的侠客或奇草配置。" };

		local cfg = ::Wuxia.Config.Herbs[this.m.HerbID];
		local skills = _actor.getSkills();
		if (skills == null)
			return { Ok = false, Reason = "无法读取角色状态。" };

		if (cfg.Kind == "herb_hp")
		{
			local wounds = (("CureOneWound" in cfg) && cfg.CureOneWound) ? skills.getAllSkillsOfType(::Const.SkillType.TemporaryInjury) : [];
			local curedWound = false;
			if (wounds.len() > 0)
			{
				wounds[0].removeSelf();
				curedWound = true;
			}
			local hpNeed = ::Math.max(0, _actor.getHitpointsMax() - _actor.getHitpoints());
			local gain = ::Math.min(cfg.HealAmount, hpNeed);
			if (!curedWound && gain <= 0)
				return { Ok = false, Reason = _actor.getName() + " 当前气血充盈无伤，建议留存「" + cfg.Name + "」入炉炼丹。" };
			if (gain > 0) _actor.setHitpoints(_actor.getHitpoints() + gain);
			skills.update();
			return { Ok = true, Message = _actor.getName() + " 嚼服奇草「" + cfg.Name + "」，恢复气血生机！" };
		}

		if (cfg.Kind == "herb_internal")
		{
			local ok = false;
			if (skills.hasSkill("effects.wx_scatter_weakness"))
			{
				skills.removeByID("effects.wx_scatter_weakness");
				ok = true;
			}
			local inj = skills.getSkillByID("effects.wx_internal_injury");
			if (inj != null && inj.m.Severity > 0)
			{
				inj.cureTemporary();
				ok = true;
			}
			if (!ok)
				return { Ok = false, Reason = _actor.getName() + " 当前经脉并无散功或临时内伤，建议留存「" + cfg.Name + "」入炉炼丹。" };
			skills.update();
			return { Ok = true, Message = _actor.getName() + " 服下奇草「" + cfg.Name + "」，温润药气抚平了经脉内患！" };
		}

		if (cfg.Kind == "herb_detox" || cfg.Kind == "herb_swift" || cfg.Kind == "herb_calm" || cfg.Kind == "herb_qi" || cfg.Kind == "herb_ward_fire" || cfg.Kind == "herb_staunch")
		{
			local bKind = cfg.Kind;
			if (cfg.Kind == "herb_detox") bKind = "buff_qingxin";
			else if (cfg.Kind == "herb_qi") bKind = "buff_hugu";
			else if (cfg.Kind == "herb_ward_fire") bKind = "buff_bihuo";
			else if (cfg.Kind == "herb_staunch") bKind = "buff_yuji";
			local buff = skills.getSkillByID("effects.wx_pill_battle_buff");
			local check = buff != null ? buff.canAcceptBattlePill(bKind, _actor.getName()) : null;
			if (check != null && !check.Ok) return check;
			if (buff == null)
			{
				buff = ::new("scripts/skills/effects/wx_pill_battle_buff");
				skills.add(buff);
			}
			buff.addPillBuff(bKind, ("CalmBravery" in cfg) ? cfg.CalmBravery : 6);
			buff.applyPillPotencyAndAux(100);
			local warning = (check != null && check.WillTriggerToxin) ? buff.applyDanToxinOverload() : "";
			skills.update();
			return { Ok = true, Message = _actor.getName() + " 生服奇草「" + cfg.Name + "」，下场战斗药效已生发！" + warning };
		}

		return { Ok = false, Reason = "此仙株请拖入武学插槽参悟，或携往城镇【百工丹坊】入炉炼制仙丹。" };
	}

	function onUse( _actor, _item = null )
	{
		return this.applyToActorWithMessage(_actor).Ok;
	}
});
