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
			local qLabel = ("Quality" in cfg && cfg.Quality in ::Wuxia.Text.Qualities) ? ::Wuxia.Text.Qualities[cfg.Quality] : "奇珍";
			ret.push({
				id = 15,
				type = "text",
				icon = "ui/icons/special.png",
				text = "本草品阶：【《" + cfg.Chapter + "》· " + qLabel + " · " + cfg.SubLabel + "】"
			});
			if (cfg.Kind == "herb_infuse")
			{
				ret.push({
					id = 16,
					type = "text",
					icon = "ui/icons/xp_received.png",
					text = "双途妙用：可在「百工猎妖炼丹房」入炉炼制仙丹，亦可拖入武学插槽生服参悟（[color=" + ::Const.UI.Color.PositiveValue + "]+" + cfg.ExpAmount + "[/color] 火候）"
				});
			}
			else
			{
				ret.push({
					id = 16,
					type = "text",
					icon = "ui/icons/health.png",
					text = "双途妙用：可在「百工猎妖炼丹房」入炉倍增药效炼成灵丹，亦可在行囊或丹药页应急生服"
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

		if (cfg.Kind == "herb_detox" || cfg.Kind == "herb_swift" || cfg.Kind == "herb_calm")
		{
			local bKind = (cfg.Kind == "herb_detox") ? "buff_qingxin" : cfg.Kind;
			local buff = skills.getSkillByID("effects.wx_pill_battle_buff");
			if (buff != null && buff.hasBuffKind(bKind))
				return { Ok = false, Reason = _actor.getName() + " 体内已有同类奇草药力流转。" };
			if (buff == null)
			{
				buff = ::new("scripts/skills/effects/wx_pill_battle_buff");
				skills.add(buff);
			}
			buff.addPillBuff(bKind);
			skills.update();
			return { Ok = true, Message = _actor.getName() + " 生服奇草「" + cfg.Name + "」，下场战斗药效已生发！" };
		}

		return { Ok = false, Reason = "此仙株请拖入武学插槽参悟，或携往百工猎妖炼丹房入炉炼制仙丹。" };
	}

	function onUse( _actor, _item = null )
	{
		return this.applyToActorWithMessage(_actor).Ok;
	}
});
